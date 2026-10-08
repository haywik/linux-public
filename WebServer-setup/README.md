WebServer-setup is used to setup a fulling functioning webserver with fastapi and a cloudflare tunnel.

## Description of each file

- config.txt
Place your config in here, your git token and the website urls.

- reinitalise.sh
This deletes any old setups and reininstall the whole setup from scratch.

- web_server_full.sh
Will install the setup, can also use reinitalise.sh for the first time.

- cleanup/uninstall.sh
Will uninstall the current setup.

- cleanup/update_all_gits.sh
Will pull the latest from all gits inside config.txt.

## How the setup is structured

For each subdomain/URL you enter in `config.txt` under the `names` section it will make.
Under `config.txt` you also to set the port/ip the fastapi web servers are running on, each index of the `names` and `names-port` must be the same, for example the second domain in the `names` must have its port/ip in the second postion in the `names-port` file.

- A user for pulling and updating existing files
- A user for running the fastapi wsgi.py file
Both user live under the same group, but the runner cannot edit nor can the git user execute.

All files are stored in /opt/haywik/web
Then its /opt/haywik/web/cheese.example.com
or       /opt/haywik/web/eggs.example.com

Within each domains directory.
There is a python virtual enviroment made (.venv), which the runner uses, the runner cannot edit the venv, the git user cannot read or write .venv.

The setup will then make a `systemd` startup script, which runs at system start, called `startup-chesse.example.com.service.

## Other setups

- Caddy

If caddy is not installed, it will be.
The caddy config file will be auto setup based on the subdomains within the config.txt file.
Caddy will not use https as the fastapi files dont nativley support it, this is what cloudflare is used for.
 - git
 - 
The git repo is auto pulled every 10 minutes, it does not restart the fastapi systemd.
