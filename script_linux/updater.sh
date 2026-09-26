clear

echo_blue() {
   echo -e "\033[36m$1\033[0m"
}
echo_red() {
   echo -e "\e[31m$1\e[0m"
}

if cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null 2>&1; then
   cd "../"
fi

currentversion=$(cat "script/version")
latest=$(curl -s 'https://raw.githubusercontent.com/AmrThePigeon/gmodalternateaddonmgr/refs/heads/main/script_linux/version' | cat)
if [[ "$latest" == "$currentversion" ]]; then
   echo_blue "The tool is up to date"
   read -n 1 -s -p "Press any key to continue..."
   exit 1
fi

if ! curl -s 'https://raw.githubusercontent.com/AmrThePigeon/gmodalternateaddonmgr/refs/heads/main/script_linux/version' | cat > /dev/null 2>&1 ; then
   interneterror="1"
   echo_red "Error: Unable to update the scripts due to a network problem"
   read -n 1 -s -p "Press any key to continue..."
   exit 1
fi

gmodaddonmgrsh=$(curl -s "https://raw.githubusercontent.com/AmrThePigeon/gmodalternateaddonmgr/refs/heads/main/script_linux/gmodaddonmgr.sh" | cat)
addon_managersh=$(curl -s "https://raw.githubusercontent.com/AmrThePigeon/gmodalternateaddonmgr/refs/heads/main/script_linux/addon_manager.sh" | cat)
gmodautoextractorsh=$(curl -s "https://raw.githubusercontent.com/AmrThePigeon/gmodalternateaddonmgr/refs/heads/main/script_linux/gmodautoextractor.sh" | cat)
updatescript=$(curl -s "https://raw.githubusercontent.com/AmrThePigeon/gmodalternateaddonmgr/refs/heads/main/script_linux/updater.sh" | cat)


echo "$gmodaddonmgrsh" > "gmodaddonmgr.sh"
echo "$addon_managersh" > "script/addon_manager.sh"
echo "$gmodautoextractorsh" > "script/gmodautoextractor.sh"
echo "$updatescript" > "script/updater.sh"
echo "$latest" > "script/version"

echo_blue "Update complete"
read -n 1 -s -p "Press any key to continue..."
exit 1
