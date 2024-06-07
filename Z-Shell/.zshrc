# Jordans Personal Shell configuration full of many customisations
# Contains many different aliases and functions I've written to make
# My life easier while managing a CentOS server runing Minecraft and various
# Other containerised applications.

# Set PATH variables
export PATH="/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:$PATH"

# Java Setup
export JAVA_HOME=/opt/jdk-17.0.10+7
export PATH=$PATH:$JAVA_HOME/bin
export CLASSPATH=$CLASSPATH:/usr/lib/java/*

# Node Version Manager Setup
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" --no-use # This loads nvm
alias node='unalias node ; unalias npm ; nvm use default ; node $@'
alias npm='unalias node ; unalias npm ; nvm use default ; npm $@'

# Use custom screenrc file
export SCREENRC="$HOME/.screenrc"

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Terminal Theme - See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="shadow-custom"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Auto Update Oh My Zshell every 7 days
zstyle ':omz:update' mode auto
zstyle ':omz:update' frequency 7

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable auto-setting terminal title.
DISABLE_AUTO_TITLE="true"

# Set our own custom terminal tab title
case $TERM in xterm*)
  precmd() {print -Pn "\e]0;[@%n][%~]\a"}
  ;;
esac

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="false"

COMPLETION_WAITING_DOTS="true"
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
plugins=(git
  zsh-autosuggestions
  zsh-syntax-highlighting
  colored-man-pages
  screen)

# Stop ZSH complaining about iDrive having access to minecraft user
ZSH_DISABLE_COMPFIX="true"

# Reload Zshell with Plugins Hooked In
source $ZSH/oh-my-zsh.sh

# User configuration

# Set Default chmod for newly created directorys by minecraft user to be 770
# Set Default chmod for newly created files by minecraft user to be 660
# This is required so that iDrive account can gain proper access to the minecraft home for backups
umask 007

# Use Global VIM Config
#export MYVIMRC="/usr/local/share/vim/.vim/vimrc"
#export VIMINIT=":set runtimepath+=/usr/local/share/vim/.vim|:source $MYVIMRC"

# Allowing editing of folder/file colours produced by ls command
# https://linuxhint.com/ls_colors_bash/ <-- colour codes
# Directorys = Bold Green
# Files = White
# .jars = Bold Underlined White
# .yml = Bold Cyan
# .old or .disabled = Bold and Red Background
# sg= <--- Remove yellow highlighting of every file that has a setgid on it (chmod value beginning with 2)
# All files will now have setgid as part of giving access to the iDrive user, we don't want everything highlighted yellow
export LS_COLORS="$LS_COLORS:di=1;92:fi=97:*.png=97:*.jpg=97:*.sh=91:*.jar=1;4:*.old=1;41:*.disabled=1;41:*.yml=1;96:sg="

# Change Initial Directory Upon Login to Minecraft Servers Dir
cd /home/minecraft/servers

# Old 2020-June2023 MC Backups
export oldmc="/home/iDrive/Backups/OLD_MC_SERVER_BACKUPS_2020_2023/bungee_servers"

#####################
# General Functions #
#####################

start_server() {
  # Server screen session name
  local SERVER_NAME="$1"
  # Server root directory
  local SERVER_DIR="$2"

  # Check Func Was Passed a Value
  if [ -z "$SERVER_NAME" ] || [ -z "$SERVER_DIR" ]; then
    echo -e "\033[1;31mError: stop_server() func did not receive proper args!\033[0m
                 \033[33mServer Startup FAILED!\033[0m"
    return 1 # Return Error Code
  fi

  # Server or Proxy
  local SERVER_TYPE=""
  # Startup Server Command
  cd $SERVER_DIR
  local START_CMD="screen -Sdm $SERVER_NAME sh start.sh"

  # Bungeecord/Waterfall Proxy Detected
  if [[ $SERVER_NAME == *bungee* ]]; then
    SERVER_TYPE="Proxy"
  # Spigot/Paper/Purpur Server Detected
  else
    SERVER_TYPE="Server"
  fi

  # Execute Server Startup Command
  eval $START_CMD

  # Pretty Colour Startup Output For User
  echo -e "\033[1;33m[$SERVER_NAME $SERVER_TYPE] -\033[0;32m
        Startup In Progress!
        Use command \033[36mlog_$SERVER_NAME\033[36m to see more info!\033[0m"
}

stop_server() {
  # Server screen session name
  local SERVER_NAME="$1"

  # Check Func Was Passed a Value
  if [ -z "$SERVER_NAME" ]; then
    echo -e "\033[1;31mError: stop_server() func did not receive proper args!\033[0m
        \033[33mServer Shutdown FAILED!\033[0m"
    return 1 # Return Error Code
  fi

  # Server or Proxy
  local SERVER_TYPE=""
  # Shutdown BungeeCord/Waterfall Server and Close it's Screen
  local SHUTDOWN_CMD_BUNGEE='screen -S '"$SERVER_NAME"' -X stuff "$(echo -ne "end\r")"'
  # Shutdown Spigot/Paper/Purpur Server and Close it's Screen
  local SHUTDOWN_CMD_SPIGOT='screen -S '"$SERVER_NAME"' -X stuff "$(echo -ne "stop\r")"'

  # Bungeecord/Waterfall Proxy Shutdown
  if [[ $SERVER_NAME == *bungee* ]]; then
    SERVER_TYPE="Proxy"
    eval $SHUTDOWN_CMD_BUNGEE
  # Spigot/Paper/Purpur Server Shutdown
  else
    SERVER_TYPE="Server"
    eval $SHUTDOWN_CMD_SPIGOT
  fi

  # Pretty Colour Shutdown Output For User
  echo -e "\033[1;33m[$SERVER_NAME $SERVER_TYPE] -\033[0;31m
        Shutdown In Progress!
        Use command \033[36mlog_$SERVER_NAME\033[36m to see more info!\033[0m"
}

############################################
# Minecraft User File Navigation Shortcuts #
############################################

# Root Directorys
export mc_home="/home/minecraft"         # Minecraft User Home
export mc_serv="$mc_home/servers"        # Main MC Deployment Root
export test_serv="$mc_home/test_servers" # test MC Deployment Root

# Live - Bungeecord Proxy Folders
export mc_bung="$mc_serv/bungee"   # Server Files
export mc_bungl="$mc_bung/logs"    # Log Files
export mc_bungp="$mc_bung/plugins" # Plugin Files
# Live - Velocity Proxy Folders
export mc_velo="$mc_serv/velocity" # Server Files
export mc_velol="$mc_velo/logs"    # Log Files
export mc_velop="$mc_velo/plugins" # Plugin Files
# Live - Hub Server Folders
export mc_hub="$mc_serv/hub"     # Server Files
export mc_hubl="$mc_hub/logs"    # Log Files
export mc_hubp="$mc_hub/plugins" # Plugin Files
# Live - PVE/SMP Server Folders
export mc_pve="$mc_serv/pve"     # Server Files
export mc_pvel="$mc_pve/logs"    # Log Files
export mc_pvep="$mc_pve/plugins" # Plugin Files
# Live - Skyblock Server Folders
export mc_sky="$mc_serv/skyblock" # Server Files
export mc_skyl="$mc_sky/logs"     # Log Files
export mc_skyp="$mc_sky/plugins"  # Plugin Files
# Live - RPG PVE Server Folders
export mc_rpg="$mc_serv/rpg"     # Server Files
export mc_rpgl="$mc_rpg/logs"    # Log Files
export mc_rpgp="$mc_rpg/plugins" # Plugin Files
# Live - Plot Server Folders
export mc_plot="$mc_serv/plot"     # Server Files
export mc_plotl="$mc_plot/logs"    # Log Files
export mc_plotp="$mc_plot/plugins" # Plugin Files

# Test - Bungeecord Proxy Folders
export test_bung="$test_serv/bungee"   # Server Files
export test_bungl="$test_bung/logs"    # Log Files
export test_bungp="$test_bung/plugins" # Plugin Files
# Test - Velocity Proxy Folders
export test_velo="$test_serv/velocity" # Server Files
export test_velol="$test_velo/logs"    # Log Files
export test_velop="$test_velo/plugins" # Plugin Files
# Test - PVE/SMP Server Folders
export test_pve="$test_serv/pve"     # Server Files
export test_pvel="$test_pve/logs"    # Log Files
export test_pvep="$test_pve/plugins" # Plugin Files
# Test - Plot Server Folders
export test_plot="$test_serv/plot"     # Server Files
export test_plotl="$test_plot/logs"    # Log Files
export test_plotp="$test_plot/plugins" # Plugin Files
# Test - Factions Server Folders
export test_fact="$test_serv/plot"     # Server Files
export test_factl="$test_fact/logs"    # Log Files
export test_factp="$test_fact/plugins" # Plugin Files
# Test - Hub Server Folders
export test_hub="$test_serv/hub"     # Server Files
export test_hubl="$test_hub/logs"    # Log Files
export test_hubp="$test_hub/plugins" # Plugin Files
# Live - Skyblock Server Folders
export test_sky="$test_serv/skyblock" # Server Files
export test_skyl="$test_sky/logs"     # Log Files
export test_skyp="$test_sky/plugins"  # Plugin Files
# Live - RPG Server Folders
export test_rpg="$test_serv/rpg"     # Server Files
export test_rpgl="$test_rpg/logs"    # Log Files
export test_rpgp="$test_rpg/plugins" # Plugin Files
##############################################
# Shadows Personal File Navigation Shortcuts #
##############################################

# Root Directorys
export dev_home="$mc_home/dev"
export dev_builds="$dev_home/build_plugins"
export dev_scripts="$dev_home/rc_scripts"

# Build - Docker Build Plugin Folders
export dev_nuvote="$dev_builds/NuVotifier"
export dev_tab="$dev_builds/TAB"

# System Aliases
alias ls='ls -F -X --color=always --group-directories-first'
alias ll='ls -F -o -g -G -h -v --color=always --group-directories-first --time-style=long-iso'
alias lll='ls -F -l -h -A -v --color=always --group-directories-first --time-style=long-iso'
alias ltime='ls -F -o -g -G -l -h -A -t -r --color=always --time-style=long-iso'
alias lsize='ls -F -o -g -G -l -h -A -S -r --color=always --time-style=long-iso'
alias ltree='tree -C -F -s -D -h -L 2 --filelimit=40'
alias treereport='(tree -X -C -F -s -D -h --sort=size |
                   tee -a $PWD/tree_report.xml &&
                   echo "Tree Report saved to $PWD/tree_report.xml")'
alias grepf='grep -Ril'

# Convert Read/Write/Execute Permissions into chmod values
# Ensure chmod values match below to maintain security!
# Dirs/Folder chmod    - 700
# Normal Files chmod   - 600
# *.sh Files chmod     - 700
# Visible Dirs/Files
alias llo='for file in *; do [ -e "$file" ] && stat -c "%a %n" "$file"; done'
# Visible + Hidden Dirs/Files
alias lloh='for file in * .*; do [ -e "$file" ] && stat -c "%a %n" "$file"; done'

##################################################
# Minecraft Servers Start/Stop/Restart Shorcuts  #
##################################################

# Live - Velocity Proxy
for cmd in vel_on velocity_on velo_on; do
  alias $cmd="start_server velocity $mc_velo"
done

for cmd in vel_off velocity_off velo_off; do
  alias $cmd="stop_server velocity $mc_velo"
done

for cmd in vel_restart velocity_restart velo_restart; do
  alias $cmd="velocity_off && velocity_on"
done

# Live - Hub Backend Server
for cmd in hub_on h_on; do
  alias $cmd="start_server hub $mc_hub"
done

for cmd in hub_off h_off; do
  alias $cmd="stop_server hub $mc_hub"
done

for cmd in hub_restart h_restart; do
  alias $cmd="hub_on && hub_off"
done

# Live - SMP Backend Server
for cmd in smp_on pve_on survival_on; do
  alias $cmd="start_server pve $mc_pve"
done

for cmd in smp_off pve_off survival_off; do
  alias $cmd="stop_server pve $mc_pve"
done

for cmd in smp_restart pve_restart survival_restart; do
  alias $cmd="smp_off && smp_on"
done

# Live - Skyblock Backend Server
for cmd in skyblock_on sky_on skyb_on; do
  alias $cmd="start_server skyblock $mc_sky"
done

for cmd in skyblock_off sky_off skyb_off; do
  alias $cmd="stop_server skyblock $mc_sky"
done

for cmd in skyblock_restart sky_restart skyb_restart; do
  alias $cmd="skyblock_off && skyblock_on"
done

# Live - RPG Backend Server
for cmd in rpg_on rpg_on pve2_on; do
  alias $cmd="start_server rpg $mc_rpg"
done

for cmd in rpg_off rpg_off pve2_off; do
  alias $cmd="stop_server rpg $mc_rpg"
done

for cmd in rpg_restart rpg_restart pve2_restart; do
  alias $cmd="rpg_off && rpg_on"
done

# Live - PLOT Backend Server
for cmd in plot_on plot_on pve2_on; do
  alias $cmd="start_server plot $mc_plot"
done

for cmd in plot_off plot_off pve2_off; do
  alias $cmd="stop_server plot $mc_plot"
done

for cmd in plot_restart plot_restart pve2_restart; do
  alias $cmd="plot_off && plot_on"
done

# Live - All Servers
for cmd in all_on live_on; do
  alias $cmd="velo_on && hub_on && smp_on && skyblock_on && rpg_on && plot_on"
done

for cmd in all_off live_off; do
  alias $cmd="velo_off && hub_off && smp_off && skyblock_off && rpg_off && plot_off"
done

for cmd in skyblock_restart sky_restart skyb_restart; do
  alias $cmd="velo_restart && hub_restart && smp_restart && skyblock_restart && rpg_restart && && plot_restart"
done

# Live - Log Tracking

# Velocity
for cmd in log_v log_velo log_vel velo_log vel_log log_velocity; do
  alias $cmd="tail -F --line=10000 $mc_velol/latest.log"
done

# Hub
for cmd in log_hub log_h hub_log h_log; do
  alias $cmd="tail -F --line=10000 $mc_hubl/latest.log"
done
# SMP Survival
for cmd in log_smp log_pve log_survival pve_log smp_log survival_log; do
  alias $cmd="tail -F --line=10000 $mc_pvel/latest.log"
done
# Skyblock
for cmd in log_sky log_skyb log_skyblock skyb_log sky_log; do
  alias $cmd="tail -F --line=10000 $mc_skyl/latest.log"
done
# RPG
for cmd in log_rpg log_mmo rpg_log mmo_log; do
  alias $cmd="tail -F --line=10000 $mc_rpgl/latest.log"
done
# PLOT
for cmd in log_plot plot_log log_creative creative_log; do
  alias $cmd="tail -F --line=10000 $mc_plotl/latest.log"
done

# All Logs In One Window Using Multitail
for cmd in log_all all_log all_l l_all; do
  alias $cmd="multitail -s 2 -sn 2,2 $mc_velol/latest.log $mc_pvel/latest.log $mc_hubl/latest.log $mc_skyl/latest.log"
done

# Test - Velocity Proxy
for cmd in test1_on test_velo_on; do
  alias $cmd="start_server test_velocity $test_velo"
done

for cmd in test1_off test_velo_off; do
  alias $cmd="stop_server test_velocity $test_velo"
done

# Test - Hub Backend Server
for cmd in test2_on test_hub_on; do
  alias $cmd="start_server test_hub $test_hub"
done

for cmd in test2_off test_hub_off; do
  alias $cmd="stop_server test_hub $test_hub"
done

# Test - PVE Backend Server

for cmd in test3_on test_pve_on; do
  alias $cmd="start_server test_pve $test_pve"
done

for cmd in test3_off test_pve_off; do
  alias $cmd="stop_server test_pve $test_pve"
done

# Test - Skyblock Backend Server

for cmd in test4_on test_sky_on; do
  alias $cmd="start_server test_skyblock $test_sky"
done

for cmd in test4_off test_sky_off; do
  alias $cmd="stop_server test_skyblock $test_sky"
done

# Test - RPG Backend Server

for cmd in test5_on test_rpg_on; do
  alias $cmd="start_server test_rpg $test_rpg"
done

for cmd in test5_off test_rpg_off; do
  alias $cmd="stop_server test_rpg $test_RPG"
done

# Test - Velocity + Hub + Skyblock

for cmd in test_all_on; do
  alias $cmd="test1_on && test2_on && test4_on"
done

for cmd in test_all_off; do
  alias $cmd="test1_off && test2_off && test4_off"
done

# Docker Buld Aliases
alias build_dir='cd /home/minecraft/dev/build_plugins/'
alias dcon='docker container'
alias dimg='docker image'
alias dc='docker compose'
alias dc_clean='dcon prune --force && dimg prune --force'
alias dc_build='dc build && dc up -d'
alias dc_restart='dc down && dc up'

alias vi=nvim
alias vim=nvim
alias hist='fc -li 100'
