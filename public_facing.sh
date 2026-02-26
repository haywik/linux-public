set -x
set -e


if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "No Root User, user is $(whoami)."
    exit
fi

if [ ! -f ~/.ssh/authorized_keys ]; then
    echo "ERROR: No SSH keys found. Setup keys before disabling passwords!"
    exit 1
fi

apt-get -y update
apt-get -y upgrade
apt-get -y dist-upgrade
apt-get install -y unattended-upgrades && dpkg-reconfigure -plow unattended-upgrades
apt-get -y install ufw

ufw default deny incoming
ufw default allow outgoing
ufw allow 24240/tcp
ufw limit 24240/tcp

cat > /etc/ssh/sshd_config << EOL
ChallengeResponseAuthentication no
PasswordAuthentication no
PubkeyAuthentication yes
PermitRootLogin no
UsePAM yes
StrictModes yes
MaxAuthTries 5
MaxSessions 10
LoginGraceTime 1m
AllowUsers haywik
X11Forwarding no
ClientAliveInterval 300
ClientAliveCountMax 2
Port 24240
DebianBanner no
EOL

if sshd -t; then
    systemctl restart ssh
    echo "SSH security applied successfully."
    systemctl reload ssh
