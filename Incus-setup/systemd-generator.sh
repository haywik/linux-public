#!/bin/bash

read -p "File name: " name
read -p "Description: " des
read -p "Work Dir: " dir
read -p "User: " user
read -p "Group: " group
read -p "Execute: " exe

mkdir -p $dir/setup_log

cat > /etc/systemd/system/${name}.service  << EOL
[Unit]
Description=$des
Wants=network-online.target
After=network-online.target

[Service]
WorkingDirectory=$dir
Type=simple
User=$user
Group=$group
Restart=always
RestartSec=20
TimeoutStartSec=10
ExecStart=$exe

[Install]
WantedBy=multi-user.target
EOL

cp /etc/systemd/system/${name}.service $dir/setup_log/${name}.service

echo "Done, and added to the systemd directory."
echo "/etc/systemd/system/${name}.service" >> made.log

cat /etc/systemd/system/${name}.service
