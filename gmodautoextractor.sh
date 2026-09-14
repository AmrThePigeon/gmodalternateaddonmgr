#!/bin/bash
convert_to_gitbash() {
    echo "$1" | sed 's|\\|/|g; s|^\([A-Za-z]\):|/\L\1|'
}
if [[ ! -f "config.json" ]]; then
   read -r -p "Garry's Mod path: " gmodpath
   read -r -p "Workshop addons path: " modfolder

   if [[ ! -d "$gmodpath" ]]; then
      echo -e "Garry's Mod path is invalid"
      exit 1
   else
      if [[ ! -d "$gmodpath/garrysmod/addons" ]]; then
         mkdir "$gmodpath/garrysmod/addons"
      fi
   fi

   if [[ ! -d "$modfolder" ]]; then
      echo -e "Workshop path is invalid"
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
      echo -e "Garry's Mod path is invalid"
      exit 1
   else
      if [[ ! -d "$gmodpath/garrysmod/addons" ]]; then
         mkdir "$gmodpath/garrysmod/addons"
      fi
   fi

   if [[ ! -d "$modfolder" ]]; then
      echo -e "Workshop path is invalid"
      exit 1
   fi
fi

gmodpath=$(convert_to_gitbash "$gmodpath")
modfolder=$(convert_to_gitbash "$modfolder")

mapfile -t modfile < <(find "$modfolder" -name "*.gma") # returns "folder/test.gma"

for file in "${modfile[@]}"; do

if [[ "$file" != "null" ]]; then
   ./fastgmad.exe extract -file "$file"
else
   echo -e "Error: file list is empty"
fi

gma_file=$(realpath "$file")
gma_real_dir=${gma_file%.gma}
gma_real_dir_for_json=${gma_file%.gma}
gma_real_dir="$gma_real_dir/"
filename=$(basename "$gma_file")
parent=$(dirname "$gma_file")
parent="$parent/"
json_file="$gma_real_dir_for_json/addon.json"
title=$(./jq.exe -r '.title' "$json_file")
safe=$(echo "$title" | sed 's/[<>:"\/\\|?*]/_/g')

if [[ ! -d "$parent$safe" ]]; then
   if [ -n "$parent$safe" ] && [ "$parent$safe" != "null" ]; then
      mv -f "$gma_real_dir" "$parent$safe"
      if ! mv -f "$parent$safe" "$gmodpath/garrysmod/addons/$safe" 2>/dev/null; then
         echo -e "'$title' already exists"
         rm -rf "$parent$safe"
      fi
   else
      echo "Could not find a 'title' field in $json_file"
   fi
else
  if [[ -d "$gma_real_dir" && -d "$parent$safe" ]]; then
   echo -e "Directory '$title' already exists"
   rm -rf "$gma_real_dir"
   echo -e "$gma_real_dir"
  else
   echo -e "Directory '$title' already exists"
  fi
fi
done
