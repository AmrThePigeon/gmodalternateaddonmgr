@echo off
set "SCRIPT_DIR=%~dp0"
powershell.exe -Command "& '%SCRIPT_DIR%tools\PortableGit\bin\bash.exe' --login -i -c 'bash script/gmodautoextractor.sh; exit'"
