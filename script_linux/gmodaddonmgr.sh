#!/bin/bash

sed -i -e 's/\r$//' script/gmodautoextractor.sh
sed -i -e 's/\r$//' script/addon_manager.sh
sed -i -e 's/\r$//' script/updater.sh

chmod +x script/gmodautoextractor.sh
chmod +x script/addon_manager.sh
chmod +x script/updater.sh

chmod +x tools/jq
chmod +x tools/7zzs
chmod +x tools/fastgmad
chmod +x tools/fzf

if ! bash script/gmodautoextractor.sh; then
   clear
   echo -e "There was a problem running the tool"
   read -n 1 -s -p "Press any key to continue..."
   exit 1
fi