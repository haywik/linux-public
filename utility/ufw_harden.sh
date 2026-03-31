#!/bin/bash
set -e

admin_ip=192.168.0.204
gateway_ip=192.168.0.1

if [ "$EUID" -ne 0 ]; then 
  echo "Must be root"
  exit 1
fi

ufw insert 1 deny out to 192.168.0.0/24
ufw insert 1 deny in from 192.168.0.0/24

ufw insert 1 allow out to $gateway_ip

ufw insert 1 allow out to $admin_ip
ufw insert 1 allow in from $admin_ip
