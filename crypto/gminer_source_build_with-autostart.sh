#!/bin/bash
set -x

source wallet.key
host=$(hostname)
user=$(whoami)
dir_set=$HOME/gminer-haywik
service=gminerhaywik_miner.service
address=$(cat wallet.key)

sudo apt-get -y update && sudo apt-get -y upgrade
sudo apt-get -y install git build-essential cmake libuv1-dev libssl-dev libhwloc-dev tar cat

echo "Removing any old scripts"
sudo killall gminer
sudo systemctl stop $service
sudo systemctl disable $service
sudo rm /etc/systemd/system/$service

mkdir -p $dir_set/files
cd $dir_set/files

wget https://github.com/develsoftware/GMinerRelease/releases/download/3.44/gminer_3_44_linux64.tar.xz
tar -xf gminer_3_44_linux64.tar.xz
cd ..

echo "nice -n 19 $dir_set/files/miner --algo etchash --server gulf.moneroocean.stream:10128 --user $address --pass $host" > run.sh


cat > $service <<EOL
[Unit]
Description=gminer miner service

[Service]
WorkingDirectory=$dir_set
ExecStart=/bin/bash $dir_set/run.sh
Restart=always
Nice=19
CPUWeight=1
User=$user
Type=simple
RestartSec=20
TimeoutStartSec=10

[Install]
WantedBy=multi-user.target
EOL

sudo mv $service /etc/systemd/system/$service
sudo killall gminer
sudo systemctl daemon-reload
sudo systemctl enable $service
sudo systemctl start $service
