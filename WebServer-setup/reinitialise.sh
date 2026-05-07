#!/bin/bash
set -x

if [[ $(/usr/bin/id -u) -e 0 ]]; then
    echo "Dont run as sudo, as it changes the ownership in the git"
    exit
sudo bash ./cleanup/uninstall.sh
bash git update-index --skip-worktree ./config.txt && git fetch && git pull
sudo bash web_server_full.sh
