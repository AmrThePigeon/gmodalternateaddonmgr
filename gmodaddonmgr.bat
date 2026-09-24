@echo off
powershell.exe -NoExit -Command "& \"$env:ProgramFiles\Git\bin\bash.exe\" --login -i -c 'bash script/gmodautoextractor.sh && exit; exec bash'"