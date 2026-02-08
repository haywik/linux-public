#!/bin/bash
set -e
set -x

source wallet.key

sudo apt-get update && sudo apt-get upgrade
sudo apt-get install git build-essential cmake libuv1-dev libssl-dev libhwloc-dev

git clone https://github.com/xmrig/xmrig.git
cd xmrig
mkdir build
cd build
cmake ..
make

cd ..
host=$(hostname)
echo "nice -n 19 ./build/xmrig -o gulf.moneroocean.stream:10001 -u $address -p $host

