> [!WARNING]
> - Always proceed with caution when installing crypto miners on your machine, some may be malicious.
> - Always verify your machine will support the current setup without long term damage.

Crypto-setup is used for debian based operating systems, to setup a monero miner.

> ## General Summary of contents
> 
> - `xmrig-source.build.sh` Removes any old instances, then builds xmrig from source
>
> - `xmrig-source-build_daemon.sh` Removes any old instances, then builds xmrig from source and sets up a daemon to start on boot.

## How to setup
1. Clone this git repo `git clone https://github.com/haywik/linux-public`
2. Move into the git repo `cd linux-public`
3. Allow executing scripts, `chmod +x [Your script of choosing]`
4. Add your waller key to 'nano wallet.key' (make it if it doesn't exist)
5. Execute via the, `./run.sh` or use systemd `sudo systemctl status monero-miner.serice`

## Other notes
- When any of the scripts are ran they assume youve configed then within the .sh files, (by deafult they work all good).
- All scrits will remove and stop any old instances.

## Further infomation
- This project is not massivley maintained, but the scripts stand there as the commands I would execute everytime to setup a xmrig miner, feel free to check to out of to modify.
- Any questions, my contact details are on my profile
