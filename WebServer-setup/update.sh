#!/bin/bash
if [[ $(/usr/bin/id -u) -e 0 ]]; then
    echo "Exiting... Avoid running this script as root."
    exit
fi

sudo bash uninstall.sh
git update-index --skip-worktree ./config.txt && git fetch && git pull
sudo bash install.sh
