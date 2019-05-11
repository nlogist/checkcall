#!/bin/bash

URL="http://192.168.0.1/cgi-bin/mainte.cgi?st_clog"
OPTS="--http-user=user --http-password=password --auth-no-challenge"
LOGFILE=checkcall.log
PREVIOUSSTAT=`tail -n 1 $LOGFILE`
CURRENTSTAT=`wget -q --tries=1 --timeout=10 -O - $OPTS $URL 2>&1 | sed -n '/CALL.LOG/,\$p' | sed -n 3,8p | iconv -f SJIS | perl -pe 's/\n/<br>/g; s/\s+/ /g'`
EVENT='Phone Call'
SECRET_KEY='your_secret_key_for_ifttt'

if [ "$CURRENTSTAT" = "" ]; then
  CURRENTSTAT="`LC_TIME=C date` Connection timed out."
fi

if [ "$PREVIOUSSTAT" != "$CURRENTSTAT" ]; then
  wget -q -O - "http://maker.ifttt.com/trigger/$EVENT/with/key/$SECRET_KEY?value1=$CURRENTSTAT" > /dev/null 2>&1
  echo "$CURRENTSTAT" >> $LOGFILE
fi
