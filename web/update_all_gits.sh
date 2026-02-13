#!/bin/bash
source config.txt

for i in ${name[@]}; do
    sudo runuser -u "gitter-$i" -c "bash $dir/auto/git.sh"
done
