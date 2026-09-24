@echo off
setlocal enabledelayedexpansion
set "SCRIPT_DIR=%~dp0"
set "GITBASH=%SCRIPT_DIR%tools\PortableGit\bin\bash.exe"
set "PGIT_URL=https://github.com/git-for-windows/git/releases/download/v2.55.0.windows.5/PortableGit-2.55.0.5-64-bit.7z.exe"
set "PGIT_SFX=%SCRIPT_DIR%tools\PortableGit.7z.exe"

if not exist "%GITBASH%" (
    set "REPLY=Y"
    set /p "REPLY=Do you want to download git bash? (~56MB) [Y/n]: "
    if /i "!REPLY!"=="n" (
        echo Git Bash is required to run this tool. Exiting.
        exit /b 1
    )

    if not exist "%SCRIPT_DIR%tools" mkdir "%SCRIPT_DIR%tools"

    echo Downloading PortableGit...
    powershell -Command "$ProgressPreference='SilentlyContinue'; Invoke-WebRequest -Uri '%PGIT_URL%' -OutFile '%PGIT_SFX%'"

    if not exist "%PGIT_SFX%" (
        echo Download failed. Check your internet connection and try again.
        exit /b 1
    )

    echo Extracting PortableGit, this may take a minute...
    "%PGIT_SFX%" -y -o"%SCRIPT_DIR%tools\PortableGit"

    del "%PGIT_SFX%"

    if not exist "%GITBASH%" (
        echo Extraction failed. Please delete the tools\PortableGit folder and try again.
        exit /b 1
    )

    echo Git Bash installed successfully.
)

powershell.exe -Command "& '%GITBASH%' --login -i -c 'bash script/gmodautoextractor.sh; exit'"