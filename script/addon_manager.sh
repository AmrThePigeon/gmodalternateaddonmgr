convert_to_gitbash() {
    echo "$1" | sed 's|\\|/|g; s|^\([A-Za-z]\):|/\L\1|'
}
echo_red() {
   echo -e "\e[31m$1\e[0m"
}
echo_yellow() {
   echo -e "\033[0;33m$1\033[0m"
}

clear

if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    script="windows"
    exec_file=".exe"
else
    script="linux"
fi

if cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null 2>&1; then
   cd "../"
fi

if [[ ! -f "config.json" ]]; then
   read -r -p "Garry's Mod path: " gmodpath
   clear
   if [[ ! -d "$gmodpath" ]]; then
      echo_red "Garry's Mod path is invalid"
      read -n 1 -s -p "Press any key to continue..."
      exit 1
   else
      if [[ ! -d "$gmodpath/garrysmod" ]]; then
         echo_red "Garry's Mod path is invalid"
         read -n 1 -s -p "Press any key to continue..."
         exit 1
      fi
      if [[ ! -d "$gmodpath/garrysmod/addons" ]]; then
         mkdir "$gmodpath/garrysmod/addons"
      fi
   fi
   
   gmodpath="$(printf '%s' "$gmodpath" | sed 's/\\/\//g')"

   touch "config.json"
   echo -e "{\n\"gmod\": \""$gmodpath"\",\n\"mod\": \"""\"\n}" > "config.json"
fi

if [[ -f "config.json" ]]; then
   cat_config=$(cat "config.json")
   config="$(printf '%s' "$cat_config" | sed 's/\\/\//g')"
   echo -e "$config" > "config.json"
   gmodpath=$(./tools/jq$exec_file -r '.gmod' "config.json" )
   if [[ ! -d "$gmodpath" ]]; then
      echo_red "Garry's Mod path is invalid"
      read -n 1 -s -p "Press any key to continue..."
      exit 1
   else
      if [[ ! -d "$gmodpath/garrysmod" ]]; then
         echo_red "Garry's Mod path is invalid"
         read -n 1 -s -p "Press any key to continue..."
         exit 1
      fi
      if [[ ! -d "$gmodpath/garrysmod/addons" ]]; then
         mkdir "$gmodpath/garrysmod/addons"
      fi
   fi
fi

gmodpath=$(convert_to_gitbash "$gmodpath")

if [[ ! -d "$gmodpath/garrysmod/addons/disabled" ]]; then
   if ! mkdir "$gmodpath/garrysmod/addons/disabled"; then
      echo_red "Error: cannot create \"disabled\" directory in \"$gmodpath/garrysmod/addons/disabled\""
      read -n 1 -s -p "Press any key to continue..."
      exit 1
   fi
fi

findaddons=$(find "$gmodpath/garrysmod/addons" -mindepth 1 -maxdepth 1 -type d ! -name disabled -printf '%f\n')
finddisabled=$(find "$gmodpath/garrysmod/addons/disabled" -mindepth 1 -maxdepth 1 -type d -printf '%f\n')

if [[ -z "$findaddons" && -z "$finddisabled" ]]; then
   echo_yellow "No addons were found"
   read -n 1 -s -p "Press any key to continue..."
   exit 1
fi

while true; do
    mapfile -t enabled  < <(find "$gmodpath/garrysmod/addons" -mindepth 1 -maxdepth 1 -type d ! -name disabled -printf '%f\n')
    mapfile -t disabled < <(find "$gmodpath/garrysmod/addons/disabled" -mindepth 1 -maxdepth 1 -type d -printf '%f\n')

    all=("${enabled[@]}" "${disabled[@]}")
    [[ ${#all[@]} -eq 0 ]] && break

    mapfile -t picks < <(printf '%s\n' "${all[@]}" | ./tools/fzf$exec_file -m --header="Tab = multi-select, Ctrl + C to exit" --layout=reverse)

    for name in "${picks[@]}"; do
        if [[ -d "$gmodpath/garrysmod/addons/$name" ]]; then
            mv -- "$gmodpath/garrysmod/addons/$name" "$gmodpath/garrysmod/addons/disabled/$name(Disabled)"
        elif [[ -d "$gmodpath/garrysmod/addons/disabled/$name" || -d "$gmodpath/garrysmod/addons/disabled/$name(Disabled)" ]]; then
            name=${name%"(Disabled)"}
            mv -- "$gmodpath/garrysmod/addons/disabled/$name(Disabled)" "$gmodpath/garrysmod/addons/$name"
        fi
    done
done
