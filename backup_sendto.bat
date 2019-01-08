@echo off

set dest=X:\Backup
set temp=C:\temp

rem Setting the path for 7z installation
if exist "C:\Program Files\7-Zip\7zG.exe" (set ZIP="C:\Program Files\7-Zip\7zG.exe") else (
    if exist "X:\PortableApps\7-ZipPortable\App\7-Zip64\7zG.exe" (set ZIP="X:\PortableApps\7-ZipPortable\App\7-Zip64\7zG.exe") else (
        echo "7zip installation path not found"
        goto error
    )
)

echo Checking if parameter is valid 
if not exist %1 goto error
echo Ok

rem get the timestamp
set tim=%time%
if %tim:~0,2% lss 10 set tim=%tim: =0%
for /f "tokens=1-6 delims=-:." %%g in ('echo %date%:%tim%') do set timestamp=%%i%%h%%g_%%j%%k%%l

rem extract the filename from the path
for /d %%g in (%1) do set filename=%%~ng%%~xg

rem quick archive
echo Archiving...
if exist "%temp%\%filename%.zip" del "%temp%\%filename%.zip"
%ZIP% a -tzip -mx1 "%temp%\%filename%.zip" %1 > %temp%\7z.log
if %errorlevel% neq 0 goto error
echo Ok. === YOU CAN CONTINUE YOUR WORK NOW ===

rem Move to backup folder
echo Move to backup folder
if exist "%dest%\%timestamp%_%filename%.zip" goto error
move "%temp%\%filename%.zip" "%dest%\%timestamp%_%filename%.zip"
if %errorlevel% neq 0 goto error
echo Ok

:success
echo === BACKUP SUCCESSFUL ===
goto end

:error
echo === BACKUP FAILED ===
pause

:end
pause