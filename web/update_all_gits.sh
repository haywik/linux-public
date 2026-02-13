#!/bin/bash
source config.txt
set -e
set -x

for i in ${names[@]}; do
    echo "Loop for $i"
    sudo runuser -l "gitter-$i" -c "bash $dir/auto/git.sh"
done
