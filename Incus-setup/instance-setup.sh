#!/bin/bash
set -x
export primary_user="haywik"
export branch="dev"
export DEBIAN_FRONTEND=noninteractive

apt-get -y update
apt-get -y upgrade
apt-get -y dist-upgrade
apt-get install -y unattended-upgrades nano git python3-pip
apt-get -y autoremove
dpkg-reconfigure -plow unattended-upgrades
chmod +x ./linux-public/Incus-setup/systemd-generator.sh

useradd "$primary_user" -U -G sudo -m -s /bin/bash -c "primary user" 
su haywik
runuser -l haywik -c "cd ~/ && git clone git clone https://github.com/haywik/linux-public -b $branch linux-public"
