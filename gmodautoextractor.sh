convert_to_gitbash() {
    echo "$1" | sed 's|\\|/|g; s|^\([A-Za-z]\):|/\L\1|'
}
echo_red() {
   echo -e "\e[31m$1\e[0m"
}
echo_blue() {
   echo -e "\033[0;34m$1\033[0m"
}
echo_yellow() {
   echo -e "\033[0;33m$1\033[0m"
}
if [[ ! -f "config.json" ]]; then
   read -r -p "Garry's Mod path: " gmodpath
   read -r -p "Workshop addons path: " modfolder

   if [[ ! -d "$gmodpath" ]]; then
      echo_red "Garry's Mod path is invalid"
      read -n 1 -s -p "Press any key to continue..."
      exit 1
   else
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

   touch "config.json"
   echo -e "{\n\"gmod\": \""$gmodpath"\",\n\"mod\": \""$modfolder"\"\n}" > "config.json"
fi
if [[ -f "config.json" ]]; then
   cat_config=$(cat "config.json")
   config="$(printf '%s' "$cat_config" | sed 's/\\/\//g')"
   echo -e "$config" > "config.json"
   gmodpath=$(./jq.exe -r '.gmod' "config.json" )
   modfolder=$(./jq.exe -r '.mod' "config.json")
   if [[ ! -d "$gmodpath" ]]; then
      echo_red "Garry's Mod path is invalid"
      read -n 1 -s -p "Press any key to continue..."
      exit 1
   else
      if [[ ! -d "$gmodpath/garrysmod/addons" ]]; then
         mkdir "$gmodpath/garrysmod/addons"
      fi
   fi

   if [[ ! -d "$modfolder" ]]; then
      echo_red "Workshop path is invalid"
      read -n 1 -s -p "Press any key to continue..."
      exit 1
   fi
fi

gmodpath=$(convert_to_gitbash "$gmodpath")
modfolder=$(convert_to_gitbash "$modfolder")

mapfile -t legacymodfile < <(find "$modfolder" -name "*.bin")

for legacyfilebin in "${legacymodfile[@]}"; do
if [[ "$legacyfilebin" != "null" ]]; then
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

if [[ "$file" != "null" ]]; then
   if ! ./fastgmad.exe extract -file "$file" 2>/dev/null; then
      echo_red "An error occurred on fastgmad tool"
   fi
else
   echo_red "Error: file list is empty"
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
title=$(./jq.exe -r '.title' "$json_file")
safe=$(echo "$title" | sed 's/[<>:"\/\\|?*]/_/g')

if [[ ! -d "$parent$safe" ]]; then
   if [ -n "$parent$safe" ] && [ "$parent$safe" != "null" ]; then
      echo_blue "Extracting \"$title\""
      mv -f "$gma_real_dir" "$parent$safe"
      if ! mv -f "$parent$safe" "$gmodpath/garrysmod/addons/$safe" 2>/dev/null; then
         echo_yellow "'$title' already exists"
         rm -rf "$parent$safe"
      fi
   else
      echo_red "Could not find a 'title' field in $json_file"
   fi
else
  if [[ -d "$gma_real_dir" && -d "$parent$safe" ]]; then
   echo_yellow "Directory '$title' already exists"
   rm -rf "$gma_real_dir"
  else
   echo_yellow "Directory '$title' already exists"
  fi
fi
if [[ -f "$legacyfile.gma" ]]; then
   rm -f "$legacyfile.gma"
fi
legacyfile=''
done
echo_blue "Extraction complete"
read -n 1 -s -p "Press any key to continue..."
