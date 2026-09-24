convert_to_gitbash() {
    echo "$1" | sed 's|\\|/|g; s|^\([A-Za-z]\):|/\L\1|'
}
echo_red() {
   echo -e "\e[31m$1\e[0m"
}
echo_blue() {
   echo -e "\033[36m$1\033[0m"
}
echo_yellow() {
   echo -e "\033[0;33m$1\033[0m"
}
echo_green() {
   echo -e "\e[1;32m$1\e[0m"
}

cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null 2>&1

if [[ ! -f "addon_manager.sh" && ! -f "fzf.exe" && ! -f "gmodautoextractor.sh" && ! -f "7zr.exe" && ! -f "fastgmad.exe" && ! -f "jq.exe" ]]; then
   echo_red "Error: There is something wrong with the installation. Re-download the tool & try again"
   read -n 1 -s -p "Press any key to continue..."
   exit 1
fi

version="1.2.0"
latest=$(curl -s "https://raw.githubusercontent.com/AmrThePigeon/gmodalternateaddonmgr/refs/heads/main/script/version" | cat)

if ! curl -s 'https://raw.githubusercontent.com/AmrThePigeon/gmodalternateaddonmgr/refs/heads/main/script/version' | cat > /dev/null 2>&1 ; then
   interneterror="1"
fi

if [[ -f "addon_manager.sh" ]]; then
   clear
   echo_blue "Garry's Mod alternate addons manager [v$version] by fancy pigeon :)"
   if [[ "$version" == "$latest" && "$interneterror" != "1" ]]; then
      echo_blue "The tool is up to date"
   fi
   if [[ "$version" != "$latest" && "$interneterror" != "1" ]]; then
      echo_yellow "New update available [v$latest]"
   fi
   if [[ "$interneterror" == "1" ]]; then
      echo_yellow "Internet Unavailable to fetch update version"
   fi
   echo_blue "Select an option:"
   echo_yellow "[1] Extract & Install addons\n[2] Enable/Disable addons\n[3] Clear path cache\n[4] Update"
   read -r -p "Select: " selection
   if [[ -z "$selection" || ("$selection" != "1" && "$selection" != "2" && "$selection" != "3" && "$selection" != "4") ]]; then
   clear
   echo_red "Error: please select a valid option"
   sleep 1
   exec bash "gmodautoextractor.sh"
   fi
   if [[ "$selection" == "1" ]]; then
   clear
   elif [[ "$selection" == "2" ]]; then
      exec bash "addon_manager.sh"
      exit 0
   elif [[ "$selection" == "3" ]]; then
        if [[ -f "../config.json" ]]; then
           rm -f "../config.json"
        fi
        clear
        echo_yellow "Deleted all path cache"
        sleep 1
        exec bash "gmodautoextractor.sh"
   elif [[ "$selection" == "4" ]]; then
        if [[ "$version" == "$latest" && "$interneterror" != "1" ]]; then
           clear
           echo_blue "The tool is up to date"
           sleep 1
           exec bash "gmodautoextractor.sh"
        fi
        if [[ "$version" != "$latest" && "$interneterror" != "1" ]]; then
           exec bash "updater.sh"
           exit 0
        fi
        if [[ "$interneterror" == "1" ]]; then
           clear
           echo_yellow "Internet Unavailable to fetch update version"
           sleep 1
           exec bash "gmodautoextractor.sh"
        fi
   fi
fi

if [[ ! -f "../config.json" ]]; then
   read -r -p "Garry's Mod path: " gmodpath
   read -r -p "Workshop addons path: " modfolder

   if [[ ! -d "$gmodpath" ]]; then
      echo_red "Garry's Mod path is invalid"
      read -n 1 -s -p "Press any key to continue..."
      exit 1
   else
      if [[ ! -f "$gmodpath/gmod.exe" ]]; then
         echo_red "Garry's Mod path is invalid"
         read -n 1 -s -p "Press any key to continue..."
         exit 1
      fi
      if [[ ! -d "$gmodpath/garrysmod/addons" ]]; then
         mkdir "$gmodpath/garrysmod/addons"
      fi
   fi

   if [[ ! -d "$modfolder" ]]; then
      echo_red "Workshop path is invalid"
      read -n 1 -s -p "Press any key to continue..."
      exit 1
   fi
   
   gmodpath="$(printf '%s' "$gmodpath" | sed 's/\\/\//g')"
   modfolder="$(printf '%s' "$modfolder" | sed 's/\\/\//g')"

   touch "../config.json"
   echo -e "{\n\"gmod\": \""$gmodpath"\",\n\"mod\": \""$modfolder"\"\n}" > "../config.json"
fi
if [[ -f "../config.json" ]]; then
   cat_config=$(cat "../config.json")
   config="$(printf '%s' "$cat_config" | sed 's/\\/\//g')"
   echo -e "$config" > "../config.json"
   gmodpath=$(./jq.exe -r '.gmod' "../config.json" )
   modfolder=$(./jq.exe -r '.mod' "../config.json")
   if [[ ! -d "$gmodpath" ]]; then
      echo_red "Garry's Mod path is invalid"
      read -n 1 -s -p "Press any key to continue..."
      exit 1
   else
      if [[ ! -d "$gmodpath/garrysmod/addons" ]]; then
         mkdir "$gmodpath/garrysmod/addons"
      fi
      if [[ ! -f "$gmodpath/gmod.exe" ]]; then
         echo_red "Garry's Mod path is invalid"
         read -n 1 -s -p "Press any key to continue..."
         exit 1
      fi
      if [[ -z "$modfolder" ]]; then
         read -r -p "Workshop addons path: " modfolder
         modfolder="$(printf '%s' "$modfolder" | sed 's/\\/\//g')"
         if [[ ! -d "$modfolder" ]]; then
            echo_red "Workshop path is invalid"
            read -n 1 -s -p "Press any key to continue..."
            exit 1
         else
            echo -e "{\n\"gmod\": \""$gmodpath"\",\n\"mod\": \""$modfolder"\"\n}" > "../config.json"
         fi
      fi
   fi
fi

gmodpath=$(convert_to_gitbash "$gmodpath")
modfolder=$(convert_to_gitbash "$modfolder")

mapfile -t legacymodfile < <(find "$modfolder" -name "*.bin")

if [[ -n "$legacymodfile" ]]; then
      echo_blue "Extracting legacy files"
fi

for legacyfilebin in "${legacymodfile[@]}"; do
if [[ -n "$legacyfilebin" ]]; then
   legacyfilename=$(basename "$legacyfilebin")
   legacyparent=$(dirname "$legacyfilebin")
   legacyparent="$legacyparent/"
   ./7zr.exe x "$legacyfilebin" -y -o"$legacyparent" > /dev/null 2>&1 || true
   legacyfile=${legacyfilebin%.bin}
   if [[ -f "$legacyfile" ]]; then
      mv "$legacyfile" "$legacyfile.gma"
   fi
fi
done

mapfile -t modfile < <(find "$modfolder" -name "*.gma")

for file in "${modfile[@]}"; do

if [[ -n "$file" ]]; then
   if ! ./fastgmad.exe extract -file "$file" 2>/dev/null; then
      echo_red "An error occurred on fastgmad tool"
   fi
else
   echo_red "Error: no files detected"
   exit 1
fi

gma_file=$(realpath "$file")
gma_real_dir_for_json=${gma_file%.gma}
gma_real_dir=${gma_file%.gma}
gma_real_dir="$gma_real_dir/"
filename=$(basename "$gma_file")
parent=$(dirname "$gma_file")
parent="$parent/"
json_file="$gma_real_dir_for_json/addon.json"
safe=$(echo "$title" | sed 's/[<>:"\/\\|?*]/_/g')
title=$(./jq.exe -r '.title' "$json_file")

if [[ ! -d "$parent$safe" ]]; then
   if [ -n "$parent$safe" ] && [ "$parent$safe" != "null" ]; then
      if [[ -d "$gmodpath/garrysmod/addons/$safe" ]]; then
         echo_yellow "Directory '$safe' already exists"
      fi
      mv -f "$gma_real_dir" "$parent$safe"
      echo_blue "Extracting \"$title\""
      if ! mv -f "$parent$safe" "$gmodpath/garrysmod/addons/$safe" 2>/dev/null; then
         rm -rf "$parent$safe"
      fi
   else
      echo_red "Could not find a 'title' field in $json_file"
   fi
else
  if [[ -d "$gma_real_dir" && -d "$gmodpath/garrysmod/addons/$safe" ]]; then
   rm -rf "$gma_real_dir"
  fi
fi
done

mapfile -t legacymodfile2 < <(find "$modfolder" -name "*.bin")
for legacyfilebin2 in "${legacymodfile2[@]}"; do
if [[ -n "$legacyfilebin2" ]]; then
   legacyfile2=${legacyfilebin2%.bin}
   if [[ -f "$legacyfile2.gma" ]]; then
      rm -f "$legacyfile2.gma"
   fi
fi
done

echo_green "Extraction complete"
read -n 1 -s -p "Press any key to continue..."