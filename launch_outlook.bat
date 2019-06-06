@echo off

echo "extract the filename from the path"
for /d %%g in (%1) do set filename=%%~ng%%~xg

echo "Launching outlook..."
"C:\Program Files\WindowsApps\Microsoft.Office.Desktop.Outlook_16051.11629.20196.0_x86__8wekyb3d8bbwe\Office16\OUTLOOK.EXE" /c ipm.note /m "&subject=%filename%" /a %1
