#!/bin/bash
FILE="/home/pi/cctv/cctv.ini"

cycle_cameras() {
 data=$(<$FILE)
 MAIN=$(exec grep -Po '(?<=MAIN=).*' <<< $data)
 MINI=$(exec grep -Po '(?<=MINI=).*' <<< $data)

 echo $MAIN
 echo $MINI
 if [ -z "$MAIN" ];
 then
  MAIN="1"
  MINI="2"
 fi

 if [ $MINI == 2 ];
 then
  VIDEOPOS="0 0 400 200"
 else
  VIDEOPOS="900 0 1280 200"
 fi

  exec & /usr/local/bin/cam${MINI}control.sh setvideopos 0 0 1280 720
  exec & /usr/local/bin/cam${MINI}control.sh setlayer 1
  exec & /usr/local/bin/cam${MAIN}control.sh setvideopos $VIDEOPOS
  exec & /usr/local/bin/cam${MAIN}control.sh setlayer 2
  TEMP_MAIN="MAIN=$MINI"
  TEMP_MINI="MINI=$MAIN"
  echo $TEMP_MAIN > $FILE
  echo $TEMP_MINI >> $FILE
}

cycle_cameras
