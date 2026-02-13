#!/bin/bash
set -e
set -x

source config.txt


echo -e "${BLUE} "
echo "ROOT-CHECK"
echo -e "${WHITE} "

if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo -e "${REDB} "
    echo "No Root User, user is $(whoami)."
    echo -e "${WHITE} "
    exit
elif [[ $(/usr/bin/id -u) -eq 0 ]]; then
    echo -e "${GREEN} "
    echo "Root User Accepted, user is $(whoami)."
    echo -e "${WHITE} "
else
    echo "Error when checking for root user"
fi

if [[ $git_token = "ACCESS-TOKEN" ]]; then
    echo e "${REDB} DEFAULT SETUP NOT CHANAGED"
    echo -e "${WHITE}"
    exit
fi

echo -e "${BLUE} "
echo "APT-UPGRADE-&-INSTALL"
echo -e "${WHITE} "

apt-get -y update
apt-get -y install python3
apt-get -y install python3-venv
apt-get -y autoremove
sudo mkdir -p --mode=0755 /usr/share/keyrings && curl -fsSL https://pkg.cloudflare.com/cloudflare-public-v2.gpg | sudo tee /usr/share/keyrings/cloudflare-public-v2.gpg >/dev/null && echo 'deb [signed-by=/usr/share/keyrings/cloudflare-public-v2.gpg] https://pkg.cloudflare.com/cloudflared any main' | sudo tee /etc/apt/sources.list.d/cloudflared.list && sudo apt-get update && sudo apt-get install cloudflared

cad_check=`dpkg -l | grep "caddy" | awk '{print $1}'`
if [[ "$cad_check" = "ii" ]]; then
    echo "CADDY ALREADY EXIST"
else
    apt -y install caddy
    echo "{" > /etc/caddy/Caddyfile
    echo "    http_port 8080" >> /etc/caddy/Caddyfile
    echo "}" >> /etc/caddy/Caddyfile
    systemctl reload caddy
	sleep 2
fi



for i in ${names[@]}; do
    echo -e "${BLUE} "
    echo "Start of $i"
    echo -e "${WHITE} "

    dir=$dir_base"/$i"
	service_name="startup-$i.service"

	if id "gitter-$i" >/dev/null 2>&1; then
        echo -e "${REDB} User already exists, skipping current user"
        echo -e "${WHITE}"
        continue
    else
        echo "USER DOESNT EXIST - good"
    fi

    mkdir -p $dir

    groupadd $i
    useradd "runner-$i" --system -M -N -d $dir -G $i
    useradd "gitter-$i" --system -M -N -d $dir -G $i

    
    chown -R gitter-$i:$i $dir
    chmod -R 770 $dir
	
    runuser -l gitter-$i -c "mkdir -p $dir/repo"
    runuser -l runner-$i -c "mkdir -p $dir/venv"
    runuser -l gitter-$i -c "mkdir -p $dir/auto"
	
    mkdir -p /etc/systemd/user/
    runuser -l gitter-$i -c "mkdir -p $dir/log"    

    date >> $dir/log/runner.log
    date >> $dir/log/gitter.log

    echo -e "${BLUE} "
    echo "GIT-FOR-$i"
    echo -e "${WHITE} "

	runuser -l gitter-$i -c "git clone $git_url$i $dir/repo"
	sleep 2
    echo """echo "GIT for $i" && cd $dir/repo >> $dir/log/git.log && git fetch $git_url$i && git reset --hard && git pull $git_url$i""" > $dir/auto/git.sh
	#runuse -l gitter-$i -c "crontab $dir/auto/git.sh"
	sleep 1
    runuser -l gitter-$i -c "bash $dir/auto/git.sh"

    echo -e "${BLUE} "
    echo "VENV-SETUP"
    echo -e "${WHITE} "

    runuser -l runner-$i -c "python3 -m venv $dir/venv"	

    $dir/venv/bin/python -m pip install -r $dir/repo/depend.txt
    sleep 2

    echo -e "${BLUE} "
    echo "CRON-FILES-$i"
    echo -e "${WHITE} "

    runuser -l gitter-$i -c "echo */10 * * * * $dir/auto/git.sh > $dir/auto/cron_file.txt"
    crontab -u gitter-$i $dir/auto/cron_file.txt

    echo -e "${BLUE} "
    echo "PERMISSIONS-FOR-$i"
    echo -e "${WHITE} "

    # chowm --->
	chown -R runner-$i:$i $dir/venv
    #for runner --->

    chmod 540 -R $dir/venv/*  
    chmod 750 -R $dir/repo/*
	chgrp -R $i $dir

    echo -e "${BLUE} "
    echo "SYSTEMD-RUNNER-$i"
    echo -e "${WHITE} "

    cat > $dir/auto/$service_name << EOL
[Unit]
Description=$i wsgi.py auto startup, made on $date
Wants=network-online.target
After=network-online.target

[Service]
WorkingDirectory=$dir/repo
Type=simple
User=runner-$i
Group=$i
Restart=always
RestartSec=20
TimeoutStartSec=10
ExecStart=$dir/venv/bin/python $dir/repo/wsgi.py

[Install]
WantedBy=multi-user.target
EOL
   	cp $dir/auto /etc/systemd/system/$server_name  

	sleep 2
	
    systemctl daemon-reload
	systemctl enable $service_name

	sleep 3	
    
    echo -e "${BLUE} "
    echo "CADDY"
    echo -e "${WHITE} "

    e=0
    for e in "${!names[@]}"; do
	if [[ "${names[$e]}" = "${i}" ]]; then
	    echo "Found $i at $e"
            break
        fi
    done

    cat > $dir/auto/caddy_config.txt << EOL
	
$i:8080 { reverse_proxy localhost:${names_port[$e]}"
}
EOL
	cat $dir/auto/caddy_config.txt >> /etc/caddy/Caddyfile 

    sleep 1
    systemctl reload caddy 
    sleep 2

    echo -e "${GREEN} "
        echo "$i STARTUP "
    echo -e "${WHITE} "

    sleep 1
    systemctl start startup-$i.service
    sleep 5
    echo -e "${GREEN} "
        echo "$i Finished"
    echo -e "${WHITE} "

done


echo -e "${BLUE} "
echo "END-OF-FILE"
echo -e "${WHITE} "




