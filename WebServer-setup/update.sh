#!/bin/bash
if [[ $(/usr/bin/id -u) -e 0 ]]; then
    echo "Exiting... Avoid running this script as root."
    exit
fi

sudo bash uninstall.sh
config=$(cat config.txt; printf '.')
config=${var%.}
git reset --hard
git pull
echo $config > config.txt
config=""
sudo bash install.sh
