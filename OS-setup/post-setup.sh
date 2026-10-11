#!/bin/bash
export branch="main"

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

echo "Final firewall setup"
echo $(sudo nft list ruleset) >> /etc/nftables.conf

sudo nft -f /etc/nftables.conf
sudo systemctl start nftables
sudo systemctl enable nftables

echo "Scipt clean up"
sed -i '\|bash /home/$USER/.first_logon|d' /home/$USER/.bashrc
rm /home/$USER/.first_logon

sudo reboot
