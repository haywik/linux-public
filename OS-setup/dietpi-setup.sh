#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive

apt-get -y update
apt-get -y upgrade
apt-get -y dist-upgrade
apt-get install -y unattended-upgrades ufw lxc

dpkg-reconfigure -plow unattended-upgrades

ufw allow ssh
ufw --force enable

cat > /etc/default/dropbear << EOL
DROPBEAR_PORT=22
DROPBEAR_EXTRA_ARGS="-s -g -l haywik"
EOL

useradd "haywik" -U -G sudo -m -s /bin/bash -c "primary user"
runuser -l haywik -c "mkdir -p /home/haywik/.ssh/ && echo >> /home/haywik/.ssh/authorized_keys && echo >> /home/haywik/.first_logon"
cp /boot/authorized_keys /home/haywik/.ssh/authorized_keys

echo "haywik ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

echo "bash /home/haywik/.first_logon" >> /home/haywik/.bashrc

cat > /home/haywik/.first_logon << EOL
sudo su root
sed -i '\|bash /home/haywik/.first_logon|d' /home/haywik/.bashrc
rm /home/haywik/.first_logon
EOL



systemctl restart dropbear
