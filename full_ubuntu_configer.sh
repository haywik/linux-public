#!/bin/bash
set -e

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

apt-get update
apt-get upgrade
apt-get dist-upgrade

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
