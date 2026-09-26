clear

echo_blue() {
   echo -e "\033[36m$1\033[0m"
}
echo_red() {
   echo -e "\e[31m$1\e[0m"
}

if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    pingcmd=$(ping -n 1 -w 2000 8.8.8.8 > /dev/null 2>&1)
    script="windows"
else
    pingcmd=$(ping -c 1 -W 2 8.8.8.8 > /dev/null 2>&1)
    script="linux"
fi

if cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null 2>&1; then
   cd "../"
fi

currentversion=$(cat "script/version")
if [[ "$script" == "windows" ]]; then
   latest=$(curl -s 'https://raw.githubusercontent.com/AmrThePigeon/gmodalternateaddonmgr/refs/heads/main/script/version' | cat)
else
   latest=$(curl -s 'https://raw.githubusercontent.com/AmrThePigeon/gmodalternateaddonmgr/refs/heads/main/script_linux/version' | cat)
fi

if [[ "$latest" == "$currentversion" ]]; then
   echo_blue "The tool is up to date"
   read -n 1 -s -p "Press any key to continue..."
   exit 1
fi

if $pingcmd; then
   interneterror="0"
else
   interneterror="1"
   echo_red "Error: Unable to update the scripts due to a network problem"
   read -n 1 -s -p "Press any key to continue..."
   exit 1
fi
if [[ script == "windows" ]]; then
   gmodaddonmgrbat=$(curl -s "https://raw.githubusercontent.com/AmrThePigeon/gmodalternateaddonmgr/refs/heads/main/gmodaddonmgr.bat" | cat)
   addon_managersh=$(curl -s "https://raw.githubusercontent.com/AmrThePigeon/gmodalternateaddonmgr/refs/heads/main/script/addon_manager.sh" | cat)
   gmodautoextractorsh=$(curl -s "https://raw.githubusercontent.com/AmrThePigeon/gmodalternateaddonmgr/refs/heads/main/script/gmodautoextractor.sh" | cat)
   updatescript=$(curl -s "https://raw.githubusercontent.com/AmrThePigeon/gmodalternateaddonmgr/refs/heads/main/script/updater.sh" | cat)

   echo "$gmodaddonmgrbat" > "gmodaddonmgr.bat"
   echo "$addon_managersh" > "script/addon_manager.sh"
   echo "$gmodautoextractorsh" > "script/gmodautoextractor.sh"
   echo "$updatescript" > "script/updater.sh"
   echo "$latest" > "script/version"
else
   gmodaddonmgrsh=$(curl -s "https://raw.githubusercontent.com/AmrThePigeon/gmodalternateaddonmgr/refs/heads/main/script_linux/gmodaddonmgr.sh" | cat)
   addon_managersh=$(curl -s "https://raw.githubusercontent.com/AmrThePigeon/gmodalternateaddonmgr/refs/heads/main/script_linux/addon_manager.sh" | cat)
   gmodautoextractorsh=$(curl -s "https://raw.githubusercontent.com/AmrThePigeon/gmodalternateaddonmgr/refs/heads/main/script_linux/gmodautoextractor.sh" | cat)
   updatescript=$(curl -s "https://raw.githubusercontent.com/AmrThePigeon/gmodalternateaddonmgr/refs/heads/main/script_linux/updater.sh" | cat)

   echo "$gmodaddonmgrsh" > "gmodaddonmgr.sh"
   echo "$addon_managersh" > "script/addon_manager.sh"
   echo "$gmodautoextractorsh" > "script/gmodautoextractor.sh"
   echo "$updatescript" > "script/updater.sh"
   echo "$latest" > "script/version"
fi

echo_blue "Update complete"
read -n 1 -s -p "Press any key to continue..."
exit 1
