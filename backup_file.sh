#!/usr/bin/env sh

DEST="X:/Backup"

echo "Checking if parameter is valid"
[ -f "$1" ] || { echo "ERROR: Invalid parameter"; read; exit; }

echo "extract the filename from the path"
filename=`basename "$1"`

echo "Move to backup folder"
cp -T "$1" "$DEST/`date +%Y%m%d_%H%M%S`_$filename" # strangely unable to put the timestamp part to a variable
[ $? -eq 0 ] || { echo "ERROR: Could not copy to destination"; read; exit; }
