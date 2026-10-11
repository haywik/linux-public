#!/bin/bash
set -x
export DEBIAN_FRONTEND=noninteractive
export branch="main"

apt-get -y update
apt-get -y upgrade
apt-get -y dist-upgrade
apt-get install -y unattended-upgrades nano git python3-pip
dpkg-reconfigure -plow unattended-upgrades

git clone https://github.com/haywik/linux-public
chmod +x ./linux-public/Incus-setup/systemd-generator.sh
