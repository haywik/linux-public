#!/bin/bash
set -e
set -x
set -u
source config.txt

if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo -e "${REDB} "
    echo "Script exiting... Run as root."
    echo -e "${WHITE} "
    exit
fi

if [[ $git_user = "GIT-USERNAME" ]]; then
    echo -e "${REDB}" 
    echo "Script existing... Change the git varibles in config.txt."
    echo -e "${WHITE}"
    exit
fi

apt-get -y update
apt-get -y install python3 python3-venv python3-pip acl cron
mkdir -p --mode=0755 /usr/share/keyrings && curl -fsSL https://pkg.cloudflare.com/cloudflare-public-v2.gpg | sudo tee /usr/share/keyrings/cloudflare-public-v2.gpg >/dev/null && echo 'deb [signed-by=/usr/share/keyrings/cloudflare-public-v2.gpg] https://pkg.cloudflare.com/cloudflared any main' | sudo tee /etc/apt/sources.list.d/cloudflared.list && sudo apt-get update && sudo apt-get install cloudflared

cad_check=$(dpkg -l | grep "caddy" | awk '{print $1}')
if [[ "$cad_check" != "ii" ]]; then
    apt -y install caddy
    cat > /etc/caddy/Caddyfile << EOL
{
    http_port 58080
    auto_https off
}
EOL
fi


for i in ${domain[@]}; do
	# Defind key varibles
    dir=$install_directory"/$i"
    service_name="startup-$i.service"
    # Find the index of $i within the lise
	index=0
    for index in "${!names[@]}"; do 
        if [[ "${names[$index]}" = "${i}" ]]; then
	        echo "Found $i at $index"
            break
        fi
    done

	# Check if the domain has been intalled already
	if id "gitter-$i" >/dev/null 2>&1; then
        continue
    fi

    #Makes basic directories, group and users.
    groupadd $i
    useradd "runner-$i" --system -M -s "/bin/bash" -N -d $dir -G $i
    useradd "gitter-$i" --system -M -s "/bin/bash" -N -d $dir -G $i
    mkdir -p $dir/repo
    mkdir -p $dir/auto
    mkdir -p $dir/venv
    mkdir -p $dir/log

    #Apply tempory permissions to the whole directory
    chown -R :$i $dir
    chmod -R 770 $dir

    #Setup Git Repo
    git_url="https://$git_user:${domain_token[$index]}@github.com/$git_user/$i"
    runuser -l gitter-$i -c "git clone $git_url $dir/repo"
    runuser -l gitter-$i  -c "git config --global --add safe.directory $dir/repo"
    echo "cd $dir/repo && git fetch && git reset --hard && git pull" > $dir/auto/git.sh

    #Setup Crontab
    runuser -u gitter-$i -- echo '*/10 * * * * $dir/auto/git.sh' > $dir/auto/crontab.txt   #To be updated to a modern webhook
    crontab -u gitter-$i $dir/auto/crontab.txt
    rm $dir/auto/crontab.txt

    #Python Virtual Enviroment
    runuser -u runner-$i -- python3 -m venv "$dir/venv"
	runuser -u runner-$i -- "$dir/venv/bin/python" -m pip install -r "$dir/repo/requirements.txt" 
	runuser -u runner-$i -- "$dir/venv/bin/python" -m pip install --upgrade pip

    ## Primary Permissions
    chgrp -R "$i" $dir/*
    chmod 750 -R $dir/* #All Under the dir
    chmod 750 -R $dir   # The dir it self

    ## Log Files
    echo "" >> $dir/log/runner.log
    echo "" >> $dir/log/gitter.log

    #Venv Final Permissions
    chmod 500 -R $dir/venv/*
   
    # Log Final Permissions
    chown runner-$i:$i $dir/log/runner.log
    chmod 600 $dir/log/runner.log
    chown gitter-$i:$i $dir/log/gitter.log
    chmod 600 $dir/log/gitter.log

    # Auto Final Permissions
    chown gitter-$i:$i $dir/auto/git.sh
    chmod 500 $dir/auto/git.sh

    #Daemon Boot
    cat > /etc/systemd/system/$service_name << EOL
[Unit]
Description=Automatic starting script for $i 
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
ExecStart=bash $dir/repo/run.sh

[Install]
WantedBy=multi-user.target
EOL

	#Setup Caddy reverse proxy
    echo -e "$i:58080 { reverse_proxy ${domain_port[$index]}\n}" >> /etc/caddy/Caddyfile 
    systemctl reload caddy 
    
	#Start up the instance
    systemctl daemon-reload
    systemctl start startup-$i.service
    systemctl enable $service_name
done





