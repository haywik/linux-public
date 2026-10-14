#!/bin/bash

if [[ $(/usr/bin/id -u) -e 0 ]]; then
    echo "Exting script... Run as an unprivledged user."
    exit
fi

sudo bash uninstall.sh
bash git update-index --skip-worktree ./config.txt 
git fetch
git reset --hard 
git pull
sudo bash install.sh
