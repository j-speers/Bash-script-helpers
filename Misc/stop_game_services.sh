#!/bin/bash

echo -e "[${txtgrn} OK ${txtnrm}] Stopping Link... wait 2 seconds."
pkill -9 glinkd
sleep 2 # Increase this to provide more safety against Dupe Exploit
echo -e "[${txtgrn} OK ${txtnrm}] Stop Log Service"
pkill -9 logservices
echo -e "[${txtgrn} OK ${txtnrm}] Stop GAuthProxy"
pkill -9 gauthproxy
echo -e "[${txtgrn} OK ${txtnrm}] Stop Auth"
pkill -9 authd
echo -e "[${txtgrn} OK ${txtnrm}] Stop Delivery"
pkill -9 gdeliveryd
echo -e "[${txtgrn} OK ${txtnrm}] Stop Anti Cheat"
pkill -9 gacd
echo -e "[${txtgrn} OK ${txtnrm}] Stop Game Service"
pkill -9 gs
echo -e "[${txtgrn} OK ${txtnrm}] Stop Faction"
pkill -9 gfactiond
echo -e "[${txtgrn} OK ${txtnrm}] Stop Unique Name"
pkill -9 uniquenamed
echo -e "[${txtgrn} OK ${txtnrm}] Stop Data Base"
pkill -9 gamedbd
echo -e "[${txtgrn} OK ${txtnrm}] Stop Java"
pkill -9 java
echo -e "[${txtgrn} OK ${txtnrm}] Stop mono"
pkill -9 mono

