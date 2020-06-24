#!/bin/bash
CAM_COUNT=$1
TIMESTAMP=`date "+%Y-%m-%d %H:%M:%S"`
if [[ -z $CAM_COUNT ]];
then
 CAM_COUNT=2
fi

is_camera_running() {
 echo $TIMESTAMP
 echo "########## IS RUNNING? ##########"
 echo "Checking if Camera ${COUNTER} is running"
 SCREEN=$(exec screen -list | grep -oP ".{0,6}stream${COUNTER}")
 SCREEN_COUNT=$(exec echo "${SCREEN}" | sed "/^\s*#/d;/^\s*$/d" | wc -l)
if [[ $SCREEN_COUNT -eq 1 ]];
 then
   printf "\033[0;32mOK\e[0m\n"
 elif [[ $SCREEN_COUNT -gt 1 ]];
 then
   printf "\033[0;33mStream${COUNTER} has ${SCREEN_COUNT} session(s) running.\e[0m\n"
   printf "Killing \033[0;31m$(expr $SCREEN_COUNT - 1)\e[0m redundant screen process for stream${COUNTER}\n"
   SCREEN_KILL_ARRAY=($(exec echo "${SCREEN}" | head -$(expr $SCREEN_COUNT - 1)))
   kill_screen $SCREEN_KILL_ARRAY
else
   printf "\033[0;31mNot Running\e[0m\n"
   exec & /usr/local/bin/start-watching.sh ${COUNTER}
   start_cam
 fi
}

kill_screen() {
 for i in "${SCREEN_KILL_ARRAY[@]}"
 do
   $(exec screen -X -S ${i} quit)
 done
}

start_cam() {
 CYCLE=$(exec & pgrep -fl start-cam.sh)
 
 if [[ -z $CYCLE ]];
 then
  exec & /usr/local/bin/start-cam.sh
 fi
}

COUNTER=1
while [ $COUNTER -le $CAM_COUNT ]
do
 echo "---------------------------------------------------------------"
 is_camera_running $COUNTER
 ((COUNTER++))
 echo "---------------------------------------------------------------"
done
