#!/bin/bash
set -e

source wallet.key
host=$(hostname)
user=$(whoami)
dir_set=/home/$user/monero-haywik

sudo apt-get -y update && sudo apt-get upgrade
sudo apt-get -y install git build-essential cmake libuv1-dev libssl-dev libhwloc-dev

echo "Removing any old scripts"
sudo killall xmrig
sudo systemctl stop monerohaywik_miner.service
sudo ystemctl disable monerohaywik_miner.service
sudo rm /etc/systemd/system/monerohaywik_miner.service


rm -rf dir_set/miner-haywik
mkdir -p /home/$user/monero-haywik
cd $dir_set
git clone https://github.com/xmrig/xmrig.git
cd xmrig
mkdir build
cd build
cmake ..
make

cd $dir_set
echo "nice -n 19 $dir_set/xmrig/build/xmrig -o gulf.moneroocean.stream:10001 -u $address -p $host" > run.sh

{ 
echo "[Unit]" 
echo "Description=Monero miner service"
echo " "
echo "[Service]"
echo "ExecStart=$dir_set/xmrig/run.sh"
echo "Restart=always"
echo "Nice=19"
echo "CPUWeight=1"
echo "User=$user"
echo "Type=simple"
echo " "
echo "[Install]"
echo "WantedBy=multi-user.target"
} > /etc/systemd/system/monerohaywik_miner.service

sudo killall xmrig
sudo systemctl daemon-reload
sudo systemctl enable monerohaywik_miner.service
sudo systemctl start monerohaywik_miner.service


