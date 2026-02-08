#!/bin/bash
set -x
git pull
sudo bash undo_full_web_server.sh
sudo bash web_server_full.sh
