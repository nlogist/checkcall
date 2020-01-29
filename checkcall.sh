#!/bin/sh

URL="http://192.168.0.1/cgi-bin/mainte.cgi?st_clog"
OPTS="--http-user=user --http-password=password --auth-no-challenge -q --tries=1 --timeout=10"
LOGFILE=checkcall.log
PREVIOUSSTAT=`tail -n 1 $LOGFILE`
CURRENTSTAT=`wget -O - $OPTS $URL 2>&1 | sed -n '/CALL.LOG/,\$p' | sed -n 3,8p | iconv -f SJIS | perl -pe 's/\n/<br>/g; s/\s+/ /g'`
EVENT='Phone Call'
SECRET_KEY='your_secret_key_for_ifttt'

if [ "$CURRENTSTAT" = "" ]; then
  echo "`LC_TIME=C date` Connection timed out." >&2
  exit 1
fi

if [ "$PREVIOUSSTAT" != "$CURRENTSTAT" ]; then
  GLOBIGNORE=*
  DATE_CUR=`echo $CURRENTSTAT | cut -d ' ' -f 2-6`
  CHECK_DATE_BEGIN=`echo $CURRENTSTAT | cut -d ' ' -f 7`
  if [ "$CHECK_DATE_BEGIN" = '**********' ]; then
    DATE_BEGIN=$DATE_CUR
    DATE_END=`echo $CURRENTSTAT | cut -d ' ' -f 8-12 | cut -d '<' -f 1`
    INFO=`echo $CURRENTSTAT | cut -d ' ' -f 13- | perl -pe 's/<br>//g; s/\s+/ /g; s/^\s+//'`
  else
    DATE_BEGIN=`echo $CURRENTSTAT | cut -d ' ' -f 7-11`
    DATE_END=`echo $CURRENTSTAT | cut -d ' ' -f 12-16 | cut -d '<' -f 1`
    INFO=`echo $CURRENTSTAT | cut -d ' ' -f 17- | perl -pe 's/<br>//g; s/\s+/ /g; s/^\s+//'`
  fi
  unset GLOBIGNORE

  DATE_BEGIN_SEC=`date -d "$DATE_BEGIN" +"%s"`
  DATE_END_SEC=`date -d "$DATE_END" +"%s"`

  DURATION_SEC=`expr $DATE_END_SEC - $DATE_BEGIN_SEC`
  DURATION_HMS=`date -u -d @$DURATION_SEC +"%T"`

  VALUE1="日時: $DATE_CUR"
  VALUE2="通話時間: $DURATION_HMS"
  VALUE3="備考: $INFO"

  wget -q -O - "http://maker.ifttt.com/trigger/$EVENT/with/key/$SECRET_KEY?value1=$VALUE1&value2=$VALUE2&value3=$VALUE3" > /dev/null 2>&1
  echo "$CURRENTSTAT" >> $LOGFILE
fi
