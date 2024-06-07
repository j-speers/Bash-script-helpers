#!/bin/bash

ServerDir=home
GsLogFileDir=$ServerDir
GsLogFileName=GameService_Log

if [ ! -d /$ServerDir/logs/ ]; then
  mkdir /$ServerDir/logs/
fi

echo -e "=== [${txtred} START ${txtnrm}] PW Admin ==="
cd /home/pwadmin
./pwadmin start &>/$ServerDir/logs/pwadmin.log &
cd /home
echo -e "=== [${txtgrn} OK ${txtnrm}] ==="
echo -e ""
sleep 0.5

echo -e "=== [${txtred} START ${txtnrm}] Log Service ==="
cd /$ServerDir/logservice
./logservice logservice.conf &>/$ServerDir/logs/logservice.log &
echo -e "=== [${txtgrn} OK ${txtnrm}] ==="
echo -e ""
sleep 0.5

echo -e "=== [${txtred} START ${txtnrm}] GAuthProxy ==="
cd /$ServerDir/gauthproxy
./gauthproxy gauthproxy.conf &>/$ServerDir/logs/gauthproxy.log &
echo -e "=== [${txtgrn} OK ${txtnrm}] ==="
echo -e ""
sleep 0.5

echo -e "=== [${txtred} START ${txtnrm}] Auth ==="
cd /$ServerDir/authd
./authd start &>/$ServerDir/logs/gauthd.log &
echo -e "=== [${txtgrn} OK ${txtnrm}] ==="
echo -e ""
sleep 0.5

echo -e "=== [${txtred} START ${txtnrm}] Unique Name ==="
cd /$ServerDir/uniquenamed
./uniquenamed gamesys.conf &>/$ServerDir/logs/uniquenamed.log &
echo -e "=== [${txtgrn} OK ${txtnrm}] ==="
echo -e ""
sleep 0.5

echo -e "=== [${txtred} START ${txtnrm}] Data Base ==="
cd /$ServerDir/gamedbd
./gamedbd gamesys.conf &>/$ServerDir/logs/gamedbd.log &
echo -e "=== [${txtgrn} OK ${txtnrm}] ==="
echo -e ""
sleep 0.5

echo -e "=== [${txtred} START ${txtnrm}] Anti Cheat ==="
cd /$ServerDir/gacd
./gacd gamesys.conf &>/$ServerDir/logs/gacd.log &
echo -e "=== [${txtgrn} OK ${txtnrm}] ==="
echo -e ""
sleep 0.5

echo -e "=== [${txtred} START ${txtnrm}] Faction ==="
cd /$ServerDir/gfactiond
./gfactiond gamesys.conf &>/$ServerDir/logs/gfactiond.log &
echo -e "=== [${txtgrn} OK ${txtnrm}] ==="
echo -e ""
sleep 0.5

echo -e "=== [${txtred} START ${txtnrm}] Delivery ==="
cd /$ServerDir/gdeliveryd
./gdeliveryd gamesys.conf &>/$ServerDir/logs/gdeliveryd.log &
echo -e "=== [${txtgrn} OK ${txtnrm}] ==="
echo -e ""
sleep 0.5

echo -e "=== [${txtred} START ${txtnrm}] Game Service ==="
cd /$ServerDir/gamed
# Run all the neccessary maps required for the game, utilise the special libskill.so library
# So that we can inject Lua code into the game engine while it is running!
LD_PRELOAD=/home/lib/libskill.so nohup ./gs gs01 gs.conf gmserver.conf gsalias.conf is01 is02 is05 is06 is07 is08 is09 is10 is11 is12 is13 is14 is15 is16 is17 is18 is19 is20 is21 is22 is23 is24 is25 is26 is27 is28 is29 is31 is32 is33 is34 is35 is38 is43 is44 is45 is46 is50 is61 is69 is70 is77 is80 bg01 bg02 bg03 bg04 bg05 bg06 rand04 arena04 &>/home/logs/gs.log &
echo -e "=== [${txtgrn} OK ${txtnrm}] ==="
echo -e ""
sleep 0.5

echo -e "=== [${txtred} START ${txtnrm}] Auto Chat Announce Service ==="
cd /$ServerDir/chat
./start.sh &
echo -e ""
echo "World Map And Dungeons Starting Now... please wait 10 seconds."
sleep 10

echo -e "=== [${txtred} START ${txtnrm}] Link ==="
cd /$ServerDir/glinkd
./glinkd gamesys.conf 1 &>/$ServerDir/logs/glink1.log 2>&1 &
cd /$ServerDir/glinkd
./glinkd gamesys.conf 2 >>/$ServerDir/logs/glink2.log 2>&1 &
echo -e "=== [${txtgrn} OK ${txtnrm}] ==="
echo -e ""
sleep 0.5

cd /$ServerDir/

echo "[ DONE ] All Services Online, Start Up Completed!"
