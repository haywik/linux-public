#!/bin/bash
source ./config.txt
for i in ${names[@]}; do
    dir=$dir_base"/$i"
    sudo runuser -l "gitter-$i" -c "bash $dir/auto/git.sh"
done
