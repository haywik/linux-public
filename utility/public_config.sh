#!/bin/bash

if [ "$EUID" -ne 0 ]; then 
  exit 1
fi

apt-get -y update
apt-get -y upgrade
apt-get -y dist-upgrade

apt install -y ufw

cat > /etc/ssh/sshd_config << EOL
Port 24240
Protocol 2
PermitRootLogin no
MaxAuthTries 5
PubkeyAuthentication yes
PasswordAuthentication no
ChallengeResponseAuthentication no
UsePAM yes
StrictModes yes
AllowUsers haywik
X11Forwarding no
PrintMotd no
DebianBanner no
ClientAliveInterval 300
ClientAliveCountMax 2
MaxSessions 10
LoginGraceTime 1m
EOL

ufw default deny incoming
ufw default allow outgoing
ufw allow 24240/tcp
ufw allow 25565/tcp
ufw --force enable

systemctl restart ssh
