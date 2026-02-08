#!/bin/bash
set -x

source wallet.key
host=$(hostname)
user=$(whoami)
dir_set=/home/$user/gminer-haywik
service=gminerhaywik_miner.service

echo "Removing any old scripts"
sudo killall gminer
sudo systemctl stop $service
sudo ystemctl disable $service
sudo rm /etc/systemd/system/$service

mkdir -p $dir_set
cd $dir_Set

wget https://github.com/develsoftware/GMinerRelease/releases/download/3.44/gminer_3_44_linux64.tar.xz
tar -xf gminer_3_44_linux64.tar.xz


echo "nice -n 19 $dir_set/miner --algo etchash --server gulf.moneroocean.stream:10001 --user $address --pass $host" > run.sh


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

sudo mv monerohaywik_miner.service /etc/systemd/system/$service
sudo killall xmrig
sudo systemctl daemon-reload
sudo systemctl enable $service
sudo systemctl start $service
