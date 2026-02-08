#!/bin/bash

source config.txt
se -x

for i in ${names[@]}; do
    echo "checking $i"

    echo "checking HTML"
    for e in "${!names[@]}"; do
	  if [[ "${names[$e]}" = "${i}" ]]; then
            break
        fi
    done
    curl -s localhost:${names_port[$e]}/home | head -5

    echo "doing systemtl stuff"
    systemctl status startup-$i

    echo "running additonal cmds manually as domain user"
    runuser -l gitter-$i -c "bash /home/$i/auto/git.sh"
    runuser -l runner-$i-c "/home/$i/venv/bin/python /home/$i/repo/wsgi.py"

done
