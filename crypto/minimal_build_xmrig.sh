#!/bin/bash
set -x

source wallet.key
host=$(hostname)
user=$(whoami)
dir_set=/home/$user/monero-haywik
apt-get update && sudo apt-get upgrade
apt-get install git build-essential cmake libuv1-dev libssl-dev libhwloc-dev

echo "Removing any old scripts"
killall xmrig
rm -rf $dir_set

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
