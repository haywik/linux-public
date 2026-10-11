#!/bin/bash
set -x
export primary_user="haywik"

export DEBIAN_FRONTEND=noninteractive

mkdir -p /etc/apt/keyrings/   #this adds the zabby repo
curl -fsSL https://pkgs.zabbly.com/key.asc -o /etc/apt/keyrings/zabbly.asc
echo -e "Enabled: yes\nTypes: deb\nURIs: https://pkgs.zabbly.com/incus/stable\nSuites: $(. /etc/os-release && echo ${VERSION_CODENAME})\nComponents: main\nArchitectures: $(dpkg --print-architecture)\nSigned-By: /etc/apt/keyrings/zabbly.asc" > /etc/apt/sources.list.d/zabbly-incus-stable.sources

apt-get -y update
apt-get -y upgrade
apt-get -y dist-upgrade
apt-get install -y unattended-upgrades incus incus-ui-canonical openssh-sftp-server ovn-central ovn-host nftables

dpkg-reconfigure -plow unattended-upgrades   #ensures the server will stay up to date
incus config unset core.https_address        #ensures the incus ui port has not auto setup from the apt install

cat > /etc/default/dropbear << EOL
DROPBEAR_PORT=22 
DROPBEAR_EXTRA_ARGS="-s -g -l $primary_user"
EOL

useradd "$primary_user" -U -G sudo -m -s /bin/bash -c "primary user"    # Makes the primary user and the files needed for setup
runuser -l $primary_user -c "mkdir -p /home/$primary_user/.ssh/ && echo >> /home/$primary_user/.ssh/authorized_keys && echo >> /home/$primary_user/.first_logon"

echo 'alias aptdo="sudo apt-get update && sudo apt-get -y upgrade"' >> /home/$primary_user/.bashrc   #populates a custom alias cmd and imports the post setup script
echo "bash /home/$primary_user/.first_logon" >> /home/$primary_user/.bashrc
runuser -l $primary_user -c "curl https://raw.githubusercontent.com/haywik/linux-public/refs/heads/dev/OS-setup/post-setup.sh -o /home/$primary_user/.first_logon"

echo "$primary_user ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers   # makes the users sudo password less, setups incus trusted group and remote ssh keys
usermod -aG incus-admin $primary_user
cp /boot/authorized_keys /home/$primary_user/.ssh/authorized_keys

systemctl restart dropbear
