#!/bin/bash
source config.txt
source config_back.txt
set -e
set -x

for i in ${names[@]}; do
    echo "Loop for $i"
    dir=$dir_base"/$i"
    sudo runuser -l "gitter-$i" -c "bash $dir/auto/git.sh"
done
