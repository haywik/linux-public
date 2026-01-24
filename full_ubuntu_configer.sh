#!/bin/bash
set -x
set -e
exec 1>&log.txt

startup_cmd=gtop
#this is only for rdisplay user



if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "No Root User, user is $(whoami)."
    exit
elif [[ $(/usr/bin/id -u) -eq 0 ]]; then
    echo "Root User Accepted, user is $(whoami)."
else
    echo "Error when checking for root user"
fi

apt-get -y update
apt-get -y upgrade
apt-get -y dist-upgrade
apt-get -y install npm nodejs
npm install gtop -g

useradd "rdisplay" -m -s /bin/rbash -c "executes cmd placed in users bash when logged" 

echo "$startup_cmd" >> /home/rdisplay/.profile
echo "$startup_cmd" >> /home/rdisplay/.profile

chattr +i -R /home/rdisplay

{
echo "[Service]"
echo "ExecStart="
echo "ExecStart=-/sbin/agetty --noissue --autologin rdisplay %I $TERM Type=idle"
} > /etc/systemd/system/getty@tty1.service.d/override.conf
#rdisplay is a restriced account for displaying gtop on my tv


mkdir -p /etc/systemd/system/getty@tty1.service.d/
{
echo "ChallengeResponseAuthentication no"
echo "PasswordAuthentication no"
echo "PubkeyAuthentication yes"
echo "PermitRootLogin no"
echo "UsePAM yes"
echo "StrictModes yes"
echo "MaxAuthTries 5"
echo "MaxSessions 10"
echo "LoginGraceTime 1m"
} > /etc/ssh/sshd_config

echo "sshd RESTART"

service sshd restart
