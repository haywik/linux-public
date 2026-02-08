#!/bin/bash
set -x

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


cat > monerohaywik_miner.service <<EOL
[Unit]
Description=Monero miner service

[Service]
WorkingDirectory=$dir_set
ExecStart=$dir_set/xmrig/run.sh
Restart=always
nice=19
CPUWeight=1
User=$user
Type=simple
RestartSec=20
TimoutStartSec=10

[Install]
WantedBy=multi-user.target
EOL

sudo mv monerohaywik_miner.service /etc/systemd/system/monerohaywik_miner.service
sudo killall xmrig
sudo systemctl daemon-reload
sudo systemctl enable monerohaywik_miner.service
sudo systemctl start monerohaywik_miner.service


