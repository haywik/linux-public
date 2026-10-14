#!/bin/bash
set -x

if [[ $(/usr/bin/id -u) -e 0 ]]; then
    echo "Do not run this script as ROOT"
    exit
fi
sudo bash ./cleanup/uninstall.sh
bash git update-index --skip-worktree ./config.txt && git fetch && git pull
sudo bash web_server_full.sh
