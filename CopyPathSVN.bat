@echo off

for /f "tokens=1,2 delims= " %%x in ('svn info %1') do (
	if %%x==URL: (
		echo %%y| clip
		echo path copied: %%y
	)
)

pause