#!/bin/bash
set -x

address=$(cat ./wallet.key)
host=$(hostname)
user=$(whoami)
dir_set=$HOME/monero-haywik
service="monerohaywik_miner.service"

if [ $user -eq "root ]; then
    echo "Dont run this script as root"
fi

sudo apt-get -y update && sudo apt-get upgrade
sudo apt-get -y install git build-essential cmake libuv1-dev libssl-dev libhwloc-dev

echo "Removing any old scripts"
sudo killall xmrig
sudo systemctl stop $service
sudo systemctl disable $service
sudo rm /etc/systemd/system/$service


rm -rf $dir_set/miner-haywik
mkdir -p $dir_set/monero-haywik
cd $dir_set
git clone https://github.com/xmrig/xmrig.git
cd xmrig
mkdir build
cd build
cmake ..
make

cd $dir_set
echo "creation" >> $dir_set/xmrig/build/xmrig.log
echo "nice -n 19 $dir_set/xmrig/build/xmrig -o gulf.moneroocean.stream:10001 -u $address -p $host --log-file $dir_set/xmrig/build/xmrig.log" > run.sh


cat > $service <<EOL
[Unit]
Description=Monero miner service

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
sudo killall xmrig
sudo systemctl daemon-reload
sudo systemctl enable $service
sudo systemctl start $service


