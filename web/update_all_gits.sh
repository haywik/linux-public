#!/bin/bash
source config.txt
set -e
set -x

for i in ${names[@]}; do
    echo "Loop for $i"
    sudo runuser -u "gitter-$i" -c "bash $dir/auto/git.sh"
done
