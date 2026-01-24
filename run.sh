#!/bin/bash
./full_ubuntu_configer.sh | tee /tmp/configer.log
./full_web_server.sh | tee /tmp/web_server.log
reboot