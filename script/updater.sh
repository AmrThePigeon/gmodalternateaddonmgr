echo_blue() {
   echo -e "\033[36m$1\033[0m"
}
echo_red() {
   echo -e "\e[31m$1\e[0m"
}

if ! curl -s 'https://raw.githubusercontent.com/AmrThePigeon/gmodalternateaddonmgr/refs/heads/main/version' | cat > /dev/null 2>&1 ; then
   interneterror="1"
   echo_red "Error: Internet Unavailable to update the scripts"
   read -n 1 -s -p "Press any key to continue..."
   exit 1
fi

gmodaddonmgrbat=$(curl -s "https://raw.githubusercontent.com/AmrThePigeon/gmodalternateaddonmgr/refs/heads/main/gmodaddonmgr.bat" | cat)
addon_managersh=$(curl -s "https://raw.githubusercontent.com/AmrThePigeon/gmodalternateaddonmgr/refs/heads/main/script/addon_manager.sh" | cat)
gmodautoextractorsh=$(curl -s "https://raw.githubusercontent.com/AmrThePigeon/gmodalternateaddonmgr/refs/heads/main/script/gmodautoextractor.sh" | cat)
updatescript=$(curl -s "https://raw.githubusercontent.com/AmrThePigeon/gmodalternateaddonmgr/refs/heads/main/script/updater.sh" | cat)

echo -e "$gmodaddonmgrbat" > "../gmodaddonmgr.bat"
echo -e "$gmodaddonmgrbat" > "addon_manager.sh"
echo -e "$gmodaddonmgrbat" > "gmodautoextractor.sh"
echo -e "$updatescript" > "updater.sh"

echo_blue "Update complete"
read -n 1 -s -p "Press any key to continue..."
exit 1