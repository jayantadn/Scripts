@echo off

set OUTLOOK="C:\Program Files (x86)\Microsoft Office\Office16\OUTLOOK.EXE"

echo Checking number of arguments
set argC=0
for %%x in (%*) do Set /A argC+=1
if %argC% gtr 1 (
	echo Cannot attach more than one file. Please use zip n email
	pause
	exit
)

echo Extract the filename from the path
for /d %%g in (%1) do set filename=%%~ng%%~xg

echo Launching outlook...
%OUTLOOK% /c ipm.note /m "&subject=%filename%" /a %1
