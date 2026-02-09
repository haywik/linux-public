#!/bin/bash
set -x
set -e

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


mkdir -p /etc/systemd/system/getty@tty1.service.d/
{
echo "[Service]"
echo "ExecStart="
echo "ExecStart=-/sbin/agetty --noissue --autologin rdisplay %I $TERM Type=idle"
} > /etc/systemd/system/getty@tty1.service.d/override.conf
#rdisplay is a restriced account for displaying gtop on my tv


cat > sshd_config << EOL
ChallengeResponseAuthentication no
PasswordAuthentication no
PubkeyAuthentication yes
PermitRootLogin no
UsePAM yes
StrictModes yes
MaxAuthTries 5
MaxSessions 10
LoginGraceTime 1m
EOL
mv sshd_config /etc/ssh/sshd_config

echo "SYSTEM RESTART"

reboot
