#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive

useradd "haywik" -U -G sudo -m -s /bin/bash -c "primary user"
apt-get -y update
apt-get -y upgrade
apt-get -y dist-upgrade
apt-get install -y unattended-upgrades
apt-get install -y ufw lxc
dpkg-reconfigure -plow unattended-upgrades
ufw allow ssh
ufw --force enable

cat > /etc/default/dropbear << EOL
DROPBEAR_PORT=22
DROPBEAR_EXTRA_ARGS="-s -g -l haywik"
EOL

systemctl restart dropbear
