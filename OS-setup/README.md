[!WARNING] 
Do NOT remove unused config lines in `dietpi.txt`, as the OS recommends against it.
Avoid editing the hostname or Global password in `dietpi.txt`, as on first logon you are prompted to change them.

1. Flash the RaspberryPi with DietPi OS.
2. Copy the contents of OS-setup, the current directory, into `/boot` on the Raspberry Pis root partion. 
3. Add all your Public-SSH Keys to `authorized_keys`, this will be copied to the primary user.
4. Boot the server.
5. SSH into the servers primary user.

- Default root password is `dietpi_dietpi`
- On the first login to the primary user, a prompt to modify the hostname and root password is prompted.
