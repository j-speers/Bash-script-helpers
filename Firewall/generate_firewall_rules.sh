#!/bin/bash

# 10/09/24 Jordan - Setup strict Linux firewall using iptables and fail2ban
# Block majority of ports except essential ones
# Adds DDoS protection throughout for various services

################## [Initial Setup Section] #####################

# Purge All Existing Firewall Rules - Start from scratch
echo -e "[ OK ] Clearing all existing firewall rules!"
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X

# Blacklisting all inbound/outbound/forwarded connections
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

#################################################################

#################### [IP Blacklist Section] #####################

# Add Specific IPs To Block From ALL PORTS In This Section. Two Examples Below.

iptables -A INPUT -s 70.10.20.30,20.30.250.90 -j DROP
iptables -A INPUT -s 172.50.255.255/32,172.50.0.0/16,172.50.200.255/32 -j DROP

#################################################################

#################### [IP Whitelist Section] #####################

# Special IPs Allowed to connect to any port.

# Localhost/127.0.0.1 Loopback Traffic (TCP/UDP)
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Local IPs
iptables -A INPUT -p tcp -s 192.168.1.0/24 -j ACCEPT

# Cloudflare DNS IPs
for ip in 173.245.48.0/20 103.21.244.0/22 103.22.200.0/22 103.31.4.0/22 \
  141.101.64.0/18 108.162.192.0/18 190.93.240.0/20 188.114.96.0/20 \
  197.234.240.0/22 198.41.128.0/17 162.158.0.0/15 104.16.0.0/13 \
  104.24.0.0/14 172.64.0.0/13 131.0.72.0/22; do
  iptables -A INPUT -p tcp -s $ip -j ACCEPT
done

#################################################################

############## [Critical Ports Whitelist Section] ###############

# Incredibly unlikely any of these should ever be changed, leave this section as is.

# SSH (TCP)
# Changed from port 22 to 9504 for security.
iptables -A INPUT -p tcp --dport 9504 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --sport 9504 -m conntrack --ctstate ESTABLISHED -j ACCEPT

# SSH brute-force protection
iptables -A INPUT -p tcp --dport 9504 -m conntrack --ctstate NEW -m recent --set
iptables -A INPUT -p tcp --dport 9504 -m conntrack --ctstate NEW -m recent --update --seconds 60 --hitcount 10 -j DROP

# Ping Requests (ICMP)
iptables -A INPUT -p icmp --icmp-type 8 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p icmp --icmp-type 0 -m conntrack --ctstate ESTABLISHED -j ACCEPT

# ICMP rate limiting
iptables -A INPUT -p icmp --icmp-type echo-request -m limit --limit 1/second -j ACCEPT

# HTTP (TCP)
iptables -A INPUT -p tcp --dport 80 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --sport 80 -m conntrack --ctstate ESTABLISHED -j ACCEPT

# HTTP rate limiting
iptables -A INPUT -p tcp --dport 80 -m connlimit --connlimit-above 20 --connlimit-mask 32 -j REJECT

# HTTPS (TCP)
iptables -A INPUT -p tcp --dport 443 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --sport 443 -m conntrack --ctstate ESTABLISHED -j ACCEPT

# HTTPS rate limiting
iptables -A INPUT -p tcp --dport 443 -m connlimit --connlimit-above 20 --connlimit-mask 32 -j REJECT

# FTP (TCP)
iptables -A INPUT -p tcp --dport 21 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --sport 21 -m conntrack --ctstate ESTABLISHED -j ACCEPT

# RDP (TCP)
iptables -A INPUT -p tcp --dport 3389 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --sport 3389 -m conntrack --ctstate ESTABLISHED -j ACCEPT

# NTP Time Sync (UDP)
iptables -A INPUT -p udp --dport 123 -j ACCEPT
iptables -A OUTPUT -p udp --sport 123 -j ACCEPT

echo -e "[ OK ] Set up protection for services ports!"

#################################################################

################## [Ports Whitelist Section] ####################

# Variables
LinkPorts="9523,9524" # Game Server Ports
LinkTimer=300         # 5 minutes
LinkLimit=20          # How many connections allowed within LinkTimer seconds
MaxAccounts=10        # Maximum number of concurrent connections allowed

# Protect the game server ports with rate limiting and connection limits

# Create a set for blacklisted IPs (if not already created)
ipset create blacklistip hash:ip -exist

# Drop packets from blacklisted IPs
iptables -A INPUT -p tcp -m multiport --dports $LinkPorts -m set --match-set blacklistip src -j DROP

# Track new connections to the game server ports
iptables -A INPUT -p tcp -m multiport --dports $LinkPorts -m conntrack --ctstate NEW -m recent --name LINK1 --set

# Drop connections that exceed the limit within the specified timer
iptables -A INPUT -p tcp -m multiport --dports $LinkPorts -m conntrack --ctstate NEW -m recent --name LINK1 --update --seconds $LinkTimer --hitcount $LinkLimit -j DROP

# Limit the maximum number of concurrent connections per IP to the game server ports
iptables -A INPUT -p tcp -m multiport --dports $LinkPorts -m connlimit --connlimit-above $MaxAccounts -j REJECT

# Accept valid connections
iptables -A INPUT -p tcp -m multiport --dports $LinkPorts -j ACCEPT

echo -e "[ OK ] Set up DDoS protection for PW Links!"

# PWAdmin Admin Panel (TCP)
iptables -A INPUT -p tcp --dport 1500 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --sport 1500 -m conntrack --ctstate ESTABLISHED -j ACCEPT

################### [Finishing Up Section] #####################

echo -e "[ OK ] Allowing established connections!"
iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

# Write to logs when connection attempts were blocked by Firewall rules
iptables -A INPUT -m limit --limit 5/min -j LOG --log-prefix "[Firewall Blocked]: " --log-level 7
iptables -A INPUT -j DROP

echo -e "[ OK ] Set up Firewall Logging!"

# Save the rules
# Remember they wont be activated until you manually restart iptables!!
iptables-save >/etc/iptables/rules.v4
systemctl restart iptables
echo -e "[ DONE ] Saved Firewall Rules And Restarted iptables!"

#################################################################

# Integration with Fail2Ban (requires Fail2Ban to be installed and configured)
# The following configuration allows integration with Fail2Ban to dynamically block IPs
# that exhibit malicious behavior.

# Create Fail2Ban jail for SSH
cat <<EOF >/etc/fail2ban/jail.local
[sshd]
enabled = true
port = 9504
filter = sshd
logpath = /var/log/auth.log
maxretry = 5
bantime = 3600
findtime = 600
EOF

[http-get-dos]
enabled = true
port = http,https
filter = http-get-dos
logpath = /var/log/nginx/website.app-access.log
maxretry = 3
bantime = 90
findtime = 300

Create the filter for HTTP GET DoS protection
cat <<EOF >/etc/fail2ban/filter.d/http-get-dos.conf
[Definition]
_daemon = nginx
failregex = ^<HOST> -.*"GET .*\$
ignoreregex =
EOF

# Restart Fail2Ban to apply changes
systemctl restart fail2ban

#################################################################

echo -e "[ DONE ] Added Fail2Ban Config And Restarted Fail2Ban!"
