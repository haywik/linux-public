#!/bin/bash
read -p "New Hostname:" hostName 
sudo /boot/dietpi/func/change_hostname $hostName
