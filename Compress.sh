echo "Setting global variables"
ZIP="T:/ProgramFiles/7-ZipPortable/App/7-Zip64/7zG.exe"

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
	dir=`echo "$1" | awk 'BEGIN { FS="\\\\" } { print $(NF-1) }'`
	TARGET=`echo "$1" | awk 'BEGIN { FS="\\\\"; ORS="\\\\" } { for(i=1; i<NF; i++) print $i}'`
	TARGET=${TARGET}${dir}.zip
fi

echo -n "Compressing..."
$ZIP a -tzip -mx9 "$TARGET" $*
if [ $? -eq 0 ]
then
	echo "OK"
else
	echo "FAILED"
	read
	exit
fi
