#!/bin/bash
read -p "New Hostname:" hostName
export hostName=$(echo "$hostName" | xargs)
sudo /boot/dietpi/func/change_hostname $hostName
