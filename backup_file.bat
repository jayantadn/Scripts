@echo off

set dest=X:\Backup

echo Checking if parameter is valid 
if not exist %1 goto error

rem get the timestamp
set tim=%time%
if %tim:~0,2% lss 10 set tim=%tim: =0%
for /f "tokens=1-6 delims=-:." %%g in ('echo %date%:%tim%') do set timestamp=%%i%%h%%g_%%j%%k%%l

rem extract the filename from the path
for /d %%g in (%1) do set filename=%%~ng%%~xg

rem Move to backup folder
echo Move to backup folder
if exist "%dest%\%timestamp%_%filename%" goto error
copy "%1" "%dest%\%timestamp%_%filename%"
if %errorlevel% neq 0 goto error

:success
echo === BACKUP SUCCESSFUL ===
goto end

:error
echo === BACKUP FAILED ===
pause

:end
rem pause