echo off

setlocal enabledelayedexpansion

set old=%1

rem remove double quotes
set new=!old:"=! 

rem change backslash to forward slash
set new=!new:\=/! 

rem copy to clipboard
echo|set /p=!new!| clip
echo copied to clipboard: !new!