#!/bin/bash
set -e
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
sudo curl https://raw.githubusercontent.com/haywik/linux-public/refs/heads/$branch/OS-setup/nftables-firewall.conf -o /etc/nftables.conf
sudo echo $(sudo nft list ruleset) >> /etc/nftables.conf

sudo nft -f /etc/nftables.conf
sudo systemctl start nftables
sudo systemctl enable nftables

echo "Scipt clean up"
sed -i '\|bash /home/$USER/.first_logon|d' /home/$USER/.bashrc
rm /home/$USER/.first_logon

sudo reboot
