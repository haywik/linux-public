#!/bin/bash
set -e
set -x

source config.txt

echo "creating new folder into home dir"
sleep 2

mkdir -p $dir

cp ./plugins_url_raw.txt $dir

cd $dir

wget $papermc_url

cat > server.jar << EOL
    #!/usr/bin/env sh
    
    java -Xms2560M -Xmx2560M -jar server.jar --nogui
    
EOL
    

mv paper* server.jar



    cat > $dir/setup/mc.haywik.com.service << EOL
[Unit]
Description=Minecraft server, private 
Wants=network-online.target
After=network-online.target

[Service]
WorkingDirectory=$dir
Type=simple
User=mc1
Restart=always
RestartSec=20
TimeoutStartSec=10
ExecStart=/bin/bash $dir/run.sh

[Install]
WantedBy=multi-user.target
EOL

mkdir -p ~/.config/systemd/user

cp ./setup/mc.haywik.com ~/.config/systemd/user/

systemctl --user daemon-reload

mkdir -p $dir/plugins

while IFS= read -r line; do
    wget -P ./plugins/ "$line"
done < url_raw_plugins.txt

systemctl --user enable --now myservice.service
