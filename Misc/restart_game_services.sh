#!/bin/bash

# Kill Glink - Disconnects all players
echo -e "=== [${txtred} STOPPING ${txtnrm}] Glink Service ==="
pkill -9 glinkd
echo -e "=== [${txtgrn} STOPPED ${txtnrm}] ==="
echo -e "Waiting 2 minutes for all character data to be fully syncd to prevent rollback and dupe exploits"

# Pause script to gave the game database time to fully save all player item data after disconnecting them.
# This prevents players duplicating items by abusing failed save states after a server restart!
sleep 120
echo -e "All Character Data should now be sucessfully syncd!"
echo -e ""

# Kill Game Service
echo -e "=== [${txtred} STOPPING ${txtnrm}] Game Service ==="
pkill -9 gs
echo -e "=== [${txtgrn} STOPPED ${txtnrm}] ==="
echo -e ""
sleep 5

# Start Logging
echo -e "=== [${txtred} STARTING ${txtnrm}] Log Service ==="
cd /home/logservice
./logservice logservice.conf &>/home/logs/logservice.log &
sleep 1
echo -e "=== [${txtgrn} STARTED ${txtnrm}] ==="
echo -e ""

# Start Game Service
echo -e "=== [${txtred} STARTING ${txtnrm}] Game Service ==="
cd /home/gamed

# Run all the neccessary maps required for the game, utilise the special libskill.so library
# So that we can inject Lua code into the game engine while it is running!
LD_PRELOAD=/home/lib/libskill.so nohup ./gs gs01 gs.conf gmserver.conf gsalias.conf is01 is02 is05 is06 is07 is08 is09 is10 is11 is12 is13 is14 is15 is16 is17 is18 is19 is20 is21 is22 is23 is24 is25 is26 is27 is28 is29 is31 is32 is33 is34 is35 is38 is43 is44 is45 is46 is50 is61 is69 is70 is77 is80 bg01 bg02 bg03 bg04 bg05 bg06 rand04 arena04 &>/home/logs/gs.log &
sleep 1
echo -e "=== [${txtgrn} STARTED ${txtnrm}] ==="
echo -e ""

# Start Glink
echo -e "=== [${txtred} STARTING ${txtnrm}] Glink Service ==="
cd /home/glinkd
./glinkd gamesys.conf 1 &>/home/logs/glink1.log 2>&1 &
sleep 1
echo -e "=== [${txtgrn} STARTED ${txtnrm}] ==="
echo -e ""

# Restart Auto-chat
echo -e "=== [${txtgrn} STOPPING ${txtnrm}] Auto Chat Announcer Service ==="
pkill -9 mono
sleep 1
echo -e "=== [${txtgrn} STOPPED ${txtnrm}] ==="
echo -e ""

echo -e "=== [${txtred} STARTING ${txtnrm}] Auto Chat Announce Service ==="
cd /home/chat
./start.sh &
cd /home/
sleep 0.5
echo -e "=== [${txtgrn} STARTED ${txtnrm}] ==="
echo -e ""

# Finished Messages
echo "All Game Services Back Online!"
echo "World Map And Dungeons Starting Now..."
echo "Wait around 30 seconds, then you should be able to connect!"
echo "ANTI DUPE PROTECTED RESTART HAS BEEN APPLIED"
