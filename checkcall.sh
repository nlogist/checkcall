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
  GLOBIGNORE=*
  TIME_CUR=`echo $CURRENTSTAT | cut -d ' ' -f 2-6`
  TIME_BEGIN=`echo $CURRENTSTAT | cut -d ' ' -f 7-11`
  TIME_END=`echo $CURRENTSTAT | cut -d ' ' -f 12-16 | cut -d '<' -f 1`
  INFO=`echo ${CURRENTSTAT:78} | perl -pe 's/<br>//g; s/\s+/ /g; s/^\s+//'`
  unset GLOBIGNORE

  TIME_BEGIN_SEC=`date -d "$TIME_BEGIN" +"%s"`
  TIME_END_SEC=`date -d "$TIME_END" +"%s"`

  DURATION_SEC=`expr $TIME_END_SEC - $TIME_BEGIN_SEC`
  DURATION_HMS=`date -u -d @$DURATION_SEC +"%T"`
  VALUE1="日時: $TIME_CUR"
  VALUE2="通話時間: $DURATION_HMS"
  VALUE3="備考: $INFO"

  wget -q -O - "http://maker.ifttt.com/trigger/$EVENT/with/key/$SECRET_KEY?value1=$VALUE1&value2=$VALUE2&value3=$VALUE3" > /dev/null 2>&1
  echo "$CURRENTSTAT" >> $LOGFILE
fi
