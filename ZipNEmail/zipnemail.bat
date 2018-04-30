@echo off

set zipfile=%1
set zipfile=%zipfile:~1,-1%

echo Compressing ...
7zg a -tzip -mx1 %zipfile%.zip %zipfile%
echo Ok.


echo Emailing ...
"C:\Program Files (x86)\Microsoft Office\Office15\OUTLOOK.EXE" /c ipm.note /a %zipfile%.zip
echo Ok.
 
timeout 10
echo Deleting compressed file ... 
del /q %zipfile%.zip
echo Ok.
