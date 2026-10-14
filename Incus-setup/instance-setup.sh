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

useradd "$primary_user" -U -G sudo -m -s /bin/bash -c "primary user" 
echo "$primary_user ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
runuser -l haywik -c "cd ~/ && git clone https://github.com/haywik/linux-public -b $branch linux-public"
su haywik
