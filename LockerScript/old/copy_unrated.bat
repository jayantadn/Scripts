@echo off
Setlocal EnableDelayedExpansion

rem setting global variables
rem set PLAYER="X:\Program Files\VLCPortable\VLCPortable.exe"
set PLAYER="x:\Program Files\GomPlayer\GOM.EXE"

if exist Locker (
	echo Folder is already unlocked
) else (
	echo Unlocking folder
	call locker.bat
)

echo Printing all filenames
dir Locker /b /s /a:-D > filelist.txt

echo Deleting already rated movies
set /a filecnt=0
if exist temp.txt del temp.txt
for /f "tokens=*" %%v in ('type filelist.txt') do (
	set filename=%%~nxv
	
	set c=!filename:~0,1!
	if not !c! == 3 (
		if not !c! == 4 (
			if not !c! == 5 (
				if not !c! == 6 (
					echo %%v >> temp.txt
					set /a filecnt+=1
				)
			)
		)
	)
)
del filelist.txt
ren temp.txt filelist.txt

rem Copying random file
echo Total file count: %filecnt%
set /p cntCopy=How many files do you want to copy?  
FOR /L %%x IN (1,1,%cntCopy%) DO (
	set /a rand=!RANDOM! * !filecnt! / 32768 + 1
	set /a cnt=0
	for /f "tokens=*" %%v in ('type filelist.txt') do (
		set /a cnt+=1
		if !cnt! == !rand! (
			echo Copying file: %%v
			mkdir "c:\temp%%~pv"
			copy "%%v" "c:\temp%%~pv"
		)
	)
)

:end
pause
echo Locking the folder again
echo Y | call locker.bat
del filelist.txt