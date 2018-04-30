@echo off
Setlocal EnableDelayedExpansion

rem setting global variables
rem set PLAYER="X:\Program Files\VLCPortable\VLCPortable.exe"
set PLAYER="X:\PortableApps\GomPlayer\GOM.EXE"

if exist Locker (
	echo Folder is already unlocked
) else (
	echo Unlocking folder
	call locker.bat
)

echo Printing all filenames
dir Locker /b /s /a:-D > filelist.txt

echo keeping only rated movies
set /a filecnt=0
if exist temp.txt del temp.txt
for /f "tokens=*" %%v in ('type filelist.txt') do (
	set filename=%%~nxv
	
	set c=!filename:~0,1!
	if !c! == 3 (
		echo %%v >> temp.txt
		set /a filecnt+=1
	) else if !c! == 4 (
		echo %%v >> temp.txt
		set /a filecnt+=1
	) else if !c! == 5 (
		echo %%v >> temp.txt
		set /a filecnt+=1
	)else if !c! == 6 (
		echo %%v >> temp.txt
		set /a filecnt+=1
	)
)
del filelist.txt
ren temp.txt filelist.txt

rem Playing random file
echo Total file count: %filecnt%
set /a rand=%RANDOM% * %filecnt% / 32768 + 1
echo File number to be played: %rand%
set /a cnt=0
for /f "tokens=*" %%v in ('type filelist.txt') do (
	set /a cnt+=1
	if !cnt! == !rand! (
		set playedfile=%%v
		echo Playing file: %%v
		pause
		%PLAYER% "%%v"
	)
)

:end
rem pause
echo Locking the folder again
echo Y | call locker.bat
del filelist.txt