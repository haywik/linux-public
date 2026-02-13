set -x
#make sure the script was opened and the defualt configs where changed

source config.txt
source config_back.txt

if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo -e "${REDB} "
    echo "No Root User, user is $(whoami)."
    echo -e "${WHITE} "
    exit
fi



for i in ${names[@]}; do
    dir=$dir_base"/$i"
    killall -u gitter-$i
    killall -u runner-$i
    groupdel $i
    userdel -f gitter-$i
    userdel -f runner-$i
    rm -rf "$dir/" #scary!

    systemctl stop startup-$i.service
    systemctl disable startup-$i.service
    rm /etc/systemd/system/startup-$i.service

    sed -i "/$i/,/}/I d" /etc/caddy/Caddyfile

    
done

echo "END-OF-FILE"
