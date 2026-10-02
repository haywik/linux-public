#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive
export primary_user="haywik"

curl -fsSL https://pkgs.zabbly.com/key.asc | gpg --show-keys --fingerprint
sh -c 'cat <<EOF > /etc/apt/sources.list.d/zabbly-incus-stable.sources
Enabled: yes
Types: deb
URIs: https://pkgs.zabbly.com/incus/stable
Suites: $(. /etc/os-release && echo ${VERSION_CODENAME})
Components: main
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/zabbly.asc

EOF'

apt-get -y update
apt-get -y upgrade
apt-get -y dist-upgrade
apt-get install -y unattended-upgrades ufw incus incus-ui-canonical openssh-sftp-server

ufw allow ssh
ufw allow 8443
ufw --force enable

dpkg-reconfigure -plow unattended-upgrades
incus config set core.https_address=:8443

cat > /etc/default/dropbear << EOL
DROPBEAR_PORT=22
DROPBEAR_EXTRA_ARGS="-s -g -l $primary_user"
EOL

useradd "$primary_user" -U -G sudo -m -s /bin/bash -c "primary user"
runuser -l $primary_user -c "mkdir -p /home/$primary_user/.ssh/ && echo >> /home/$primary_user/.ssh/authorized_keys && echo >> /home/$primary_user/.first_logon"
cp /boot/authorized_keys /home/$primary_user/.ssh/authorized_keys

echo "$primary_user ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
usermod -aG incus-admin $primary_user

echo 'alias aptdo="sudo apt-get update && sudo apt-get -y upgrade"' >> /home/$primary_user/.bashrc

echo "bash /home/$primary_user/.first_logon" >> /home/$primary_user/.bashrc
cat > /home/$primary_user/.first_logon << EOL
#!/bin/bash
read -p "New Hostname: " hostName < /dev/tty
sudo /boot/dietpi/func/change_hostname $hostName

echo "New Root Password"
sudo passwd root
echo "Disabling password logins for the dietpi user"
sudo passwd -l dietpi

sed -i '\|bash /home/$primary_user/.first_logon|d' /home/$primary_user/.bashrc
rm /home/$primary_user/.first_logon

EOL

chmod 755 /home/$primary_user/.first_logon 

systemctl restart dropbear
