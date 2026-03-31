#!/bin/bash
set -e

admin_ip=192.168.0.204
gateway_ip=192.168.0.1
ssh_port="22220/tcp"

if [ "$EUID" -ne 0 ]; then 
  echo "Must be root"
  exit 1
fi


check=`dpkg -l | grep "ufw" | awk '{print $1}'`
if [[ "$check" = "ii" ]]; then
    echo "UFW is installed"
else
    echo "UFW not installed"
    exit 1
fi

ufw insert 5 deny out to 192.168.0.0/24
ufw insert 4 deny in from 192.168.0.0/24

ufw insert 3 allow out to $gateway_ip

ufw insert 2 allow out to $admin_ip
ufw insert 1 allow in from $admin_ip

ufw insert 1 allow from $admin_ip to any port $ssh_port proto tcp

ufw reload
