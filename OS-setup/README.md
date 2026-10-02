> [!WARNING] 
> - Don't remove unused config lines in `dietpi.txt`
> - Don't edit `AUTO_SETUP_NET_HOSTNAME` or `AUTO_SETUP_GLOBAL_PASSWORD` in `dietpi.txt`

## How to setup

1. Flash the RaspberryPi with DietPi OS.
2. Copy the contents of OS-setup, the current directory, into `/boot` on the Raspberry Pis **_root_ partion**. 
3. Add all your Public-SSH keys to `authorized_keys`,this is added into to the primary user's authorized_keys file.
4. Boot the server, with a network connection.
5. Using SSH login to the primary user.

<br>

### Before the login of the primary user
- Default root/dietpi password is `dietpi_dietpi`

### On the first primary user login
- A prompt to modify the hostname and root password is shown.
- The dietpi user is disabled from password login.
