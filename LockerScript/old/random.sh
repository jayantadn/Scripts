# declaring all constants
readonly FOLDER="Huawei"

echo "Printing all filenames"
find $FOLDER -type f > filelist.txt

echo "Counting movies"
filecnt=`wc -l filelist.txt | cut -f1 -d' '`

# Playing random file
echo Total file count: $filecnt
rand=`expr $RANDOM % $filecnt`
echo File number to be played: $rand
cnt=0
while IFS= read line
do
	if [ $cnt -eq $rand ]
	then
		echo Playing file: $line
		termux-share "$line"
		break
	else
		cnt=`expr $cnt + 1`
	fi
done < "filelist.txt"

# Provide rating
#read -p "rating=Please rate the movie (2-6, 0=delete, 1= skip rating):" ans
#case $ans in
#	[1]* ) echo "You typed 1";;
#	[023456]* ) echo "You typed 2-6";;
#	* ) echo "Invalid rating";;
#esac