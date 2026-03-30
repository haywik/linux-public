#!/bin/bash
set -e

allowed_ssh_user=haywik
startup_cmd=gtop

if [ "$EUID" -ne 0 ]; then 
  echo "Must be root"
  exit 1
fi

echo "Execute gtop on display? (dependcies installing... npm nodjs) [y/n]"
read install_gtop
echo "Add user haywik [y/n]"
read add_haywik

apt-get -y update
apt-get -y upgrade
apt-get -y dist-upgrade
apt-get install -y unattended-upgrades && dpkg-reconfigure -plow unattended-upgrades
apt install -y ufw openssh-server

if [ "$add_haywik" -e "y" ]; then
  useradd "haywik" -U -G sudo -m -s /bin/bash -c "primary user"
  passwd -e haywik
fi

if [ "$install_gtop = "y" ] ; then
  echo "Installing gtop to show on boot"
  apt-get -y install npm nodejs 
  npm install gtop -g
  useradd "rdisplay" -m -s /bin/rbash -c "executes cmd placed in users bash when logged" 
  echo "$startup_cmd" >> /home/rdisplay/.profile
  chattr -R +i /home/rdisplay
  mkdir -p /etc/systemd/system/getty@tty1.service.d/
  cat > /etc/systemd/system/getty@tty1.service.d/override.conf << EOL
  [Service]
  ExecStart=
  ExecStart=-/sbin/agetty --noissue --autologin rdisplay %I $TERM
  Type=idle
  EOL
fi

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
AllowUsers $allowed_ssh_user
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

#ufw allow 25565/tcp  #example for minecraft server
#ufw limit 24240

sed -i 's/REJECT/DROP/g' /etc/default/ufw  #sed scans through file, g is global so everything not just first line and repllaced reject to drop
ufw --force enable

echo "SYSTEM RESTART"

reboot
