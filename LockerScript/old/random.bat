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
dir T:\Huwaei /b /s /a:-D >> filelist.txt

echo Counting movies
set /a filecnt=0
if exist temp.txt del temp.txt
for /f "tokens=*" %%v in ('type filelist.txt') do (
	set filename=%%~nxv
	echo %%v >> temp.txt
	set /a filecnt+=1
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

rem Provide rating
set /p rating=Please rate the movie (3-6, 0=delete, 1= skip rating): 
if %rating% == 6 (
	goto rename
	) else (
	if %rating% == 5 ( 
		goto rename 
	) else (
		if %rating% == 4 ( 
			goto rename 
		) else (
			if %rating% == 3 ( 
				goto rename 
			) else (
				if %rating% == 1 ( 
					echo Skip rating
					goto end 
				) else (
					if %rating% == 0 ( 
						goto delete 
						) else (
							echo Invalid input. Skip rating
					)
				)
			)
		)
	)
)

:delete
set /p confirm=Are you sure you want to delete?(y/n): 
if %confirm%==y del "%playedfile%"
goto end

:rename
for /f "tokens=*" %%v in ("%playedfile%") do (
	echo Renaming file
	move "%%v" "%%~dpv%rating% %%~nxv"
)

:end
rem pause
echo Locking the folder again
echo Y | call locker.bat
del filelist.txt