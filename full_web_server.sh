#!/bin/bash
set -e

names=( "sub1.example.com" "sub2.example.com" "example.com" )
names_port=( "9002" "9003" "9004" )

git_user="GIT-USERNAME"
git_token="ACCESS-TOKEN"
git_url="https://$git_user:$git_token@github.com/$git_user/"

BLUE='\033[0;34m'
WHITE='\033[0;37m'
GREEN='\033[0;32m'
REDB='\033[0;41m'


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
fi



for i in ${names[@]}; do
    echo -e "${BLUE} "
    echo "Start of $i"
    echo -e "${WHITE} "


    if id "gitter-$i" >/dev/null 2>&1; then
        echo -e "${REDB} User already exists, skipping current user"
        echo -e "${WHITE}"
        continue
    else
        echo "USER DOESNT EXIST - good"
    fi


    groupadd $i
    useradd "runner-$i" --system -M -N -d /home/$i -G $i
    useradd "gitter-$i" --system -M -N -d /home/$i -G $i


    mkdir -p /home/$i/repo
    mkdir -p /home/$i/venv
    mkdir -p /home/$i/auto
    mkdir -p /etc/systemd/user/webA
    mkdir -p /home/$i/log    

    date >> /home/$i/log/runner.log
    date >> /home/$i/log/gitter.log
    

    echo -e "${BLUE} "
    echo "GIT-FOR-$i"
    echo -e "${WHITE} "

    git clone $git_url$i /home/$i/repo
    echo """echo "GIT for $i" && cd /home/$i/repo >> /home/$i/log/git.log && git fetch $git_url$i && git reset --hard && git pull $git_url$i""" > /home/$i/auto/git.sh
    bash /home/$i/auto/git.sh


    echo -e "${BLUE} "
    echo "VENV-SETUP"
    echo -e "${WHITE} "

    python3 -m venv /home/$i/venv	

    /home/$i/venv/bin/python -m pip install -r /home/$i/repo/depend.txt

    echo -e "${BLUE} "
    echo "CRON-FILES-$i"
    echo -e "${WHITE} "

    echo "*/10 * * * * /home/$i/auto/git.sh" > /home/$i/auto/cron_file.txt
    crontab -u gitter-$i /home/$i/auto/cron_file.txt


    echo -e "${BLUE} "
    echo "PERMISSIONS-FOR-$i"
    echo -e "${WHITE} "

    chown -R root:$i /home/$i
    chmod 050 -R /home/$i

    chown -R runner-$i:$i /home/$i/venv
    chmod 500 -R /home/$i/venv

    chown -R gitter-$i:$i /home/$i/repo
    chmod 650 -R /home/$i/repo
    
    chown -R gitter-$i:$i /home/$i/auto
    chmod 500 -R /home/$i/auto
    chown gitter-$i:$i /home/$i/log/gitter.log
    chmod 600 -R /home/$i/log/gitter.log

    chmod 750 /home/$i/.
    chmod 750 /home/$i/repo/.
    chmod 750 /home/$i/venv/.  


    echo -e "${BLUE} "
    echo "SYSTEMD-RUNNER-$i"
    echo -e "${WHITE} "

    {
                echo "[Unit]"
                echo "Description=$i wsgi.py auto startup, made on $date"
		echo "Wants=network-online.target"
		echo "After=network-online.target"
                echo " "
                echo "[Service]"
                echo "Type=simple"
                echo "User=runner-$i"
                echo "Group=$i"
                echo "Restart=on-failure"
                echo "RestartSec=20"
		echo "TimeoutStartSec=10"
                echo "ExecStart=/home/$i/venv/bin/python /home/$i/repo/wsgi.py"
		echo " "
		echo "[Install]"
                echo "WantedBy=multi-user.target"

        } >> /etc/systemd/user/webA/startup-$i.service
    systemctl enable /etc/systemd/user/webA/startup-$i.service


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

    {
		echo " "
		echo "$i:8080 {"
		echo "    reverse_proxy localhost:${names_port[$e]}"
		echo "}" 
    } >> /etc/caddy/Caddyfile

    systemctl reload caddy 


    echo -e "${GREEN} "
        echo "$i STARTUP "
    echo -e "${WHITE} "

    systemctl start startup-central.haywik.com

    echo -e "${GREEN} "
        echo "$i Finished"
    echo -e "${WHITE} "

done


echo -e "${BLUE} "
echo "END-OF-FILE"
echo -e "${WHITE} "




