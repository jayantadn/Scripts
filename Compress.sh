ZIP="T:/ProgramFiles/7-ZipPortable/App/7-Zip64/7zG.exe"

[ $# -lt 2 ] && echo "ERROR: insufficient parameters" && exit

command=$1

shift

$ZIP a -tzip -mx9 "$1.zip" $*

