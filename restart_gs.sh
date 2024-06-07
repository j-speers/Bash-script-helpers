#!/bin/bash

# Name of the Developer making the Github Commit
name=$1

echo "Automatically Committing any changed files to Github..."
/home/update_github.sh ${name}
sleep 1
echo -e "=== [${txtgrn} GITHUB UPDATED ${txtnrm}] ==="
echo -e ""

echo "Game server is now shutting down..."
killall -9 gs
echo "Game server shutdown successful."
sleep 0.5
echo -e "=== [${txtred} RESTARTING ${txtnrm}] Game Service ==="
cd /home/gamed
LD_PRELOAD=/home/lib/libskill.so nohup ./gs gs01 gs.conf gmserver.conf gsalias.conf is01 is02 is05 is06 is07 is08 is09 is10 is11 is12 is13 is14 is15 is16 is17 is18 is19 is20 is21 is22 is23 is24 is25 is26 is27 is28 is29 is31 is32 is33 is34 is35 is38 is43 is44 is45 is46 is50 is61 is69 is70 is77 is80 bg01 bg02 bg03 bg04 bg05 bg06 rand04 arena04 &> /home/logs/gs.log &
sleep 0.5
echo -e "=== [${txtgrn} OK ${txtnrm}] ==="
echo -e ""

echo -e "=== [${txtgrn} STOP ${txtnrm}] Auto Chat Announcer Service ==="
pkill -9 mono
sleep 0.5
echo -e "=== [${txtgrn} OK ${txtnrm}] ==="

echo -e "=== [${txtred} START ${txtnrm}] Auto Chat Announce Service ==="
cd /home/chat
./start.sh &
cd /home/
sleep 0.5
echo -e "=== [${txtgrn} OK ${txtnrm}] ==="

echo -e ""
echo "Game Service Back Online!"
echo "World Map And Dungeons Starting Now..."
echo "Wait around 30 seconds, then you should be able to connect!"

