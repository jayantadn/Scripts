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

echo "Setting the compressed filename"
if [ $# -eq 1 ] 
then
	echo "Remove trailing backslash if any" # This happens when compressing the parent directory
	if [ `echo "${1: -1}"` == "\\" ] 
	then
		filename="${1%?}"
	else
		filename="$1"
	fi
	TARGET="$filename.zip"
else
	# FreeCommander passes \\ as path separator
	filename=$(echo "$1" | sed 's/\\/\//g') # \ to /
	dirpath=$(dirname "$filename")
	dir=$(basename "$dirpath")
	TARGET="$dirpath/$dir.zip"
	TARGET=$(echo "$TARGET" | sed 's/\//\\/g') # / to '\'
fi

echo -n "Compressing..."
if [ $# -gt 1 ]
then
	i=2
	filelist=("$1")
	while [ $i -le $# ]
	do
		filename=$(echo "$1" | sed 's/\\/\//g')
		dir=$(dirname "$filename")
		filename="$dir/${!i}"
		filename=$(echo "$filename" | sed 's/\//\\/g')
		filelist[$(( $i - 1 ))]="$filename"
		let i++
	done
	"$ZIP" a -tzip -mx9 "$TARGET" ${filelist[*]}
else
	"$ZIP" a -tzip -mx9 "$TARGET" "$1"
fi

if [ -f "$TARGET" ]
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
	rm -f "$TARGET"
	;;
esac

