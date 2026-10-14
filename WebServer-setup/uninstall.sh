#!/bin/bash
set -x
source ./config.txt

if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "Script exiting... Run as Root."
    exit 1
fi

for i in ${names[@]}; do
    dir=$dir_base"/$i"
    killall -u gitter-$i
    killall -u runner-$i
    groupdel $i
    userdel -f gitter-$i
    userdel -f runner-$i
    rm -rf "$dir/" #scary!
    systemctl stop startup-$i.service
    systemctl disable startup-$i.service
    rm /etc/systemd/system/startup-$i.service
    sed -i "/$i/,/}/I d" /etc/caddy/Caddyfile 
done

