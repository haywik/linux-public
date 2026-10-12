> [!WARNING]
> - Always proceed with caution when installing crypto miners on your machine, some may be malicious.
> - Always verify your machine will support the current setup without long term damage.

<br>

Crypto-setup contrains scripts to setup primarly a monero mining server.

### Description of each file

- `wallet.key` put your **public** wallet key here

- `monoreoocean-install.sh` Uses the standard monoreo ocean install script.

- `xmrig-source.build.sh` Build xmrig from source

- `xmrig-source-build_and-cleanup.sh` Will delete the old instance and reinstall a new one. Will also add a systemd file to start the miner on boot.
