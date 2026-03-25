#!/bin/bash
set -x
sudo bash undo_full_web_server.sh
bash git update-index --skip-worktree ./config.txt && git fetch && git pull
sudo bash web_server_full.sh
