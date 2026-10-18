> [!NOTE]
> - You must have Password less SUDO
> - This setup script assumes your fastapi directory layout follows a set standard.

WebServer-setup is used to setup a fulling functioning webserver with fastapi, caddy and cloudflare tunnel.
This setup assumes a similar setup found under the [FastAPI Webserver](https://github.com/haywik/minimal-fastapi-webserver).

> ## General Summary of contents
> 
> - `config.txt` Place your config in here, your git token and the domain urls.
>
> - `install.sh` Will install the setup, can also use reinitalise.sh for the first time.
>
> - `uninstall.sh` Will uninstall the current setup.
>
> - `update.sh` Triggers a uninstall, pulls any new repo updates and then installs.
>
> - `git-updater.sh` Will pull the latest from all gits inside config.txt.

## How to setup
1. Clone the repo,
```bash
git clone https://github.com/haywik/linux-public
```
2. Go to this project
```bash
 cd linux-public/WebServer-setup
```
3. Edit the config to your preference
```bash
nano config.txt
```
4. Within the config under `domain` add your URL domains, same for the IP port its bined to, add your read only Git token key. <br>
5. To first run this setup run 
```bash
bash update.sh
```

---
## How it works under the hood

- The script makes a user called `runner-domain-name.com` this user is used for running the `run.sh` file and has no write access to anything.
- The script also makes user `gitter-domain-name.com` this user is used for updating the code, has full write,read and execute access. However cannot read or write to the python virtual environment.
  
- All files are stored in $install_directory under the `config.txt`
- Then its $install_directory/cheese.example.com
- or for example$install_directory/eggs.example.com

- Within each domains directory.
= There is a python virtual environment made (venv), which the runner uses, the runner cannot edit the venv, the git user cannot read or write to venv.

The setup will then make a `systemd` startup script, which runs at system start, called `startup-chesse.example.com.service.

## Other setups

- Caddy

If caddy is not installed, it will be.
The caddy config file will be auto setup based on the subdomains within the config.txt file.
Caddy will not use https as the fastapi files dont nativley support it, this is what cloudflare is used for.
 - git
   
The git repo is auto pulled every 10 minutes, it does not restart the fastapi systemd.
