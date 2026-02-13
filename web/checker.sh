#!/bin/bash

source config.txt
source config_back.txt
set -x

for i in ${names[@]}; do
	dir=$dir_base"/$i"
    echo "checking $i"

    echo "checking HTML"
    for e in "${!names[@]}"; do
	  if [[ "${names[$e]}" = "${i}" ]]; then
            break
        fi
    done
    curl -s ${names_port[$e]}/home | head -5

    echo "updating the git"
    runuser -l gitter-$i -c "bash $dir/auto/git.sh"

    echo "doing systemtl stuff"
	systemctl restart startup-$i --no-pager
	sleep 5
    systemctl status startup-$i --no-pager

    
    #runuser -l runner-$i -c "/home/$i/venv/bin/python /home/$i/repo/wsgi.py"

done
