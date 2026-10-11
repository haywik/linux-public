#!/bin/bash

read -p "New Hostname:" hostName
export hostName=$(echo "$hostName" | xargs)
sudo /boot/dietpi/func/change_hostname $hostName

echo "New Root Password"
sudo passwd root

echo "Disabling password logins for the dietpi user"
sudo passwd -l dietpi

echo "INCUS Setup"
incus admin init
incus config set core.https_address=[::]:8443

sed -i '\|bash /home/$USER/.first_logon|d' /home/$USER/.bashrc
rm /home/$USER/.first_logon

sudo reboot
