#!/usr/bin/env bash

CURDIR=`dirname $0`
ZIP="T:/ProgramFiles/7-ZipPortable/App/7-Zip64/7zG.exe"
BACKUP_DEST="X:/Backup"
OUTLOOK="$CURDIR/launch_outlook.bat"

echo "Checking parameters"
[ $# -lt 2 ] && echo "ERROR: insufficient parameters" && exit

echo "Processing the arguments"
command=$1
shift

echo "Remove trailing backslash if any"
if [ `echo "${1: -1}"` == "\\" ] 
then
	filename="${1%?}"
else
	filename="$1"
fi

echo "Setting the compressed filename"
if [ $# -eq 1 ] 
then
	TARGET="$filename.zip"
else
	parentdir=`echo "$filename" | awk 'BEGIN { FS="\\\\" } { print $(NF-1) }'`
	TARGET=`echo "$filename" | awk 'BEGIN { FS="\\\\"; ORS="\\\\" } { for(i=1; i<NF; i++) print $i}'`${parentdir}.zip
fi

echo -n "Compressing..."
"$ZIP" a -tzip -mx9 "$TARGET" "$@"
if [ $? -eq 0 ]
then
	echo "OK"
else
	echo "FAILED" && read && exit
fi

case $command in
"compress")
	# nothing more to do
	;;
	
"backup")
	mv "$TARGET" "$BACKUP_DEST/`date +%Y%m%d_%H%M%S`_`echo $TARGET | awk 'BEGIN { FS="\\\\" } { print $(NF) }'`"
	[ $? -ne 0 ] && echo "ERROR: move failed" && read && exit
	;;
	
"zipnemail")
	"$OUTLOOK" "$TARGET"
	echo "DO NOT CLOSE the window yet. It will be closed automatically in 5s."
	sleep 5
	rm -f "$TARGET"
	;;
esac

