#!/bin/bash
#set -x

BING="/tmp/bing-wallpaper.md"
DEST="/Users/young/Pictures/bing-wallpaper"
curl -fsSL https://github.com/niumoo/bing-wallpaper/blob/main/bing-wallpaper.md -o $BING

LIST=`cat $BING | grep -v '^$' |awk -F 'https' '{print "https"$2}' | sed 's/)//g'`

cd $DEST

for i in $LIST
do
FILE=`echo $i | awk -F 'OHR.' '{print $2}'`
if [ ! -f $FILE ]; then
  curl -fsSL $i -o $FILE
fi
done
