@echo off
powershell.exe -Command "& \"$env:ProgramFiles\Git\bin\bash.exe\" --login -i -c 'bash script/gmodautoextractor.sh; exit'"