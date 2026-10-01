#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive

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
apt-get install -y unattended-upgrades ufw lxc incus incus-ui-canonical openssh-sftp-server

dpkg-reconfigure -plow unattended-upgrades

ufw allow ssh
ufw allow 8443
ufw --force enable

incus config set core.https_address=:8443

cat > /etc/default/dropbear << EOL
DROPBEAR_PORT=22
DROPBEAR_EXTRA_ARGS="-s -g -l haywik"
EOL

useradd "haywik" -U -G sudo -m -s /bin/bash -c "primary user"
runuser -l haywik -c "mkdir -p /home/haywik/.ssh/ && echo >> /home/haywik/.ssh/authorized_keys && echo >> /home/haywik/.first_logon"
cp /boot/authorized_keys /home/haywik/.ssh/authorized_keys

echo "haywik ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

sudo usermod -aG incus-admin haywik

echo "bash /home/haywik/.first_logon" >> /home/haywik/.bashrc

cat > /home/haywik/.first_logon << EOL
#!/bin/bash
read -p "New Hostname: " hostName < /dev/tty
sudo /boot/dietpi/func/change_hostname $hostName
sudo su root
sed -i '\|bash /home/haywik/.first_logon|d' /home/haywik/.bashrc
rm /home/haywik/.first_logon
EOL



systemctl restart dropbear
