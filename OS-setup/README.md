> [!WARNING] 
> - Don't remove unused config lines in `dietpi.txt`
> - Don't edit `AUTO_SETUP_NET_HOSTNAME` or `AUTO_SETUP_GLOBAL_PASSWORD` in `dietpi.txt`
<br>

OS-setup contains scripts and other files used to further setup a DietPi OS install, inspired by the commands always executed on a first setup after first boot.

> ## General Summary of contents
>
> - `archive` Contains all old scripts from previous versions, is used a reference for newer scripts sometimes.
> - `README.md` Well your looking at it.
> - `authorized_keys` Paste your Public-SSH keys into the when following the setup.
> - `dietpi-setup.sh` Contains the main script which sets up the server.
> - `dietpi.txt` Is the config used by DietPi OS just without all the comments and notes.
> - `post-setup.sh` Script that runs on the primary user on first login, to finalize any configs.
> - `nftables-firewall.conf` Contains the default firewall policy for a barebone protection.


## How to setup, before booting the server.

1. Flash the RaspberryPi with DietPi OS.
2. Copy `dietpi.txt` and `authorized_keys` into `/boot` on the Raspberry Pis **_root_ partion**. 
3. Add all your Public-SSH keys to `authorized_keys`.
4. Boot the server, with a network connection.
5. Login to the primary user. (SSH or hardware terminal)

<br>

## How to setup, from an already booted server.
We assume here you are using an installer and the original USB didn't contain a dietpi.txt file.
- Do not click install when prompted
1. Change your TTY terminal, `CTRL+ALT+[1-9]` (if nothing happened choose a different number)
2. Plug a external USB containing your `authorized_keys` and `dietpi.txt` configs
3. Mount and copy the files
```bash
lsblk #Find the name of your drive, in this example we assume its sba1
mount /dev/sba/sba1 /mnt
cp /mnt/authorized_keys /boot/
cp /mnt/dietpi.txt /boot/
```
4. Return back to your original TTY via `CTRL+ALT+[1-9]`
5. Finish the setup prompted by the system.

### Before the login of the primary user
- Default root/dietpi password is `dietpi_dietpi`
- The `authorized_keys` file was added into to the primary user's authorized_keys file.

### On the first primary user login
- A prompt to modify the hostname and root password is shown.
- The dietpi user is disabled from password login.

<br>

### Description of each file

- `archive` Contains all old scripts from previous versions, is used a reference for newer scripts sometimes.
- `README.md` Well your looking at it.
- `authorized_keys` Paste your Public-SSH keys into the when following the setup.
- `dietpi-setup.sh` Contains the main script which sets up the server.
- `dietpi.txt` Is the config used by DietPi OS just without all the comments and notes.
- `post-setup.sh` Script that runs on the primary user on first login, to finalize any configs. 
- `nftables-firewall.conf` Contains the default firewall policy for a barebone protection.
