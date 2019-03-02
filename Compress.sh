#!/usr/bin/env bash

ZIP="T:/ProgramFiles/7-ZipPortable/App/7-Zip64/7zG.exe"
BACKUP_DEST="X:/Backup"
OUTLOOK="C:\Program Files (x86)\Microsoft Office\Office15\OUTLOOK.EXE"

echo "Checking parameters"
[ $# -lt 2 ] && echo "ERROR: insufficient parameters" && exit

echo "Processing the arguments"
command=$1
shift

echo "Setting the compressed filename"
if [ $# -eq 1 ] 
then
	TARGET="$1.zip"
else
	parentdir=`echo "$1" | awk 'BEGIN { FS="\\\\" } { print $(NF-1) }'`
	TARGET=`echo "$1" | awk 'BEGIN { FS="\\\\"; ORS="\\\\" } { for(i=1; i<NF; i++) print $i}'`${parentdir}.zip
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
	"$OUTLOOK" /c ipm.note /a "$TARGET"
	;;
esac
