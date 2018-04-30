@echo off
Setlocal EnableDelayedExpansion

rem setting global variables
rem set PLAYER="X:\Program Files\VLCPortable\VLCPortable.exe"
set PLAYER="x:\Program Files\GomPlayer\GOM.EXE"
set DEST=F:\Android\data\com.termux\files

if exist Locker (
	echo Folder is already unlocked
) else (
	echo Unlocking folder
	call locker.bat
)

echo Printing all filenames
dir Locker /b /s /a:-D > filelist.txt

echo Counting filenames
set /a filecnt=0
if exist temp.txt del temp.txt
for /f "tokens=*" %%v in ('type filelist.txt') do (
	set /a filecnt+=1
)

rem Copying random file
echo Total file count: %filecnt%
echo Destination: %DEST%
set /p cntCopy=How many files do you want to copy?  
FOR /L %%x IN (1,1,%cntCopy%) DO (
	set /a rand=!RANDOM! * !filecnt! / 32768 + 1
	set /a cnt=0
	for /f "tokens=*" %%v in ('type filelist.txt') do (
		set /a cnt+=1
		if !cnt! == !rand! (
			echo Copying file: %%v
			mkdir "!DEST!%%~pv"
			copy "%%v" "!DEST!%%~pv"
		)
	)
)

:end
pause
echo Locking the folder again
echo Y | call locker.bat
del filelist.txt