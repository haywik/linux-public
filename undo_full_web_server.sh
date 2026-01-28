set -x

exit
#make sure the script was opened and the defualt configs where changed

d="EXAMPLE"
names=( "sub1.$d.com" )


if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo -e "${REDB} "
    echo "No Root User, user is $(whoami)."
    echo -e "${WHITE} "
    exit
fi



for i in ${names[@]}; do
    killall -u gitter-$i
    killall -u runner-$i

    groupdel $i
    userdel -f gitter-$i
    userdel -f runner-$i
    rm -rf /home/$i
    systemctl disable startup-$i.service
    
    rm /etc/systemd/system/startup-$i.service
    rm  /etc/systemd/user/webA/startup-$i.service

    sed -i "/$i/I d" /etc/caddy/Caddyfile
    
done

echo "END-OF-FILE"
