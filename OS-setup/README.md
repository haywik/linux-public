> [!WARNING] 
> - Don't remove unused config lines in `dietpi.txt`
> - Avoid editing the hostname or Global password in `dietpi.txt`

## How to setup

1. Flash the RaspberryPi with DietPi OS.
2. Copy the contents of OS-setup, the current directory, into `/boot` on the Raspberry Pis root partion. 
3. Add all your Public-SSH Keys to `authorized_keys`, this will be copied to the primary user.
4. Boot the server.
5. Login into the primary user.

---
---

### Before the login of the primary user
- Default root/dietpi password is `dietpi_dietpi`


### On the first primary user login
- A prompt to modify the hostname and root password is shown.
- The dietpi user is disabled from password login.
