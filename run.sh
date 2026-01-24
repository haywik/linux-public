#!/bin/bash
set -e
set -x
bash full_ubuntu_configer.sh | tee /tmp/configer.log &
tail -f /tmp/configer.log
bash full_web_server.sh | tee /tmp/web_server.log
reboot