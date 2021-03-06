# Some indications on how to administer personal servers:

## Nextcloud install:

### Create the server:

I choose to run a digital Ocean droplet to install nextcloud. First step is to create the droplet in digital Ocean.
Once the instance is running, I need to get it's IP address, and connect to it using ssh to the root account.
As a first step, we can connect using a password or key.

After logging as root, we need to create a user:
 `#$ adduser UserName`

Once the new user is created, we need to add it to the sudo group to avoid the need for root logging:
`#  usermod -aG sudo UserName`

-a need to be used with the -G option. they are to "append" to groups. we can supply a list of groups

### first firewall set-up:

We will use the ufw firewall (could use iptable, but for now, let's make it simple).
With UFW apps can supply a profile to make ufw allow them. to list apps supplying profiles:
`# ufw app list`

To load profile in ufw: `# ufw allow OpenSSH` #example for openSSH
We need to enable the firewall: `# ufw enable`
We can check the status of ufw: `# ufw status`
The enable option will reload ufw with the new rules and enable it for next starts.

### managing the new user and ssh with keys:

see the [ssh doc](./ssh_info.md)

### I have a domain name:

I decided to use the gandi interface to redirect part of my domain name to the server.
to do so, I need to create a record in their web management interface binding the subdomain
with the DigitalOcean droplet ip address. The changes will require some hours to be effective
In the mean time i will need to continue using the ip address.

### Block storage

I want to add a block storage to the droplet to install nextcloud on it and thus allow the 
document storage to grow with usage.
I will install the storage and configure the /etc/fstab to mount it at boot on /snap
That is what I did and the problem I found when trying to backup, is that nextcloud is using another location for data and configuration. By defalut we can find where they are located by looking at the environment variable:

`$SNAP` for the nextcloud software app data
`$SNAP_DATA` for the apache/PHP/MySQL/Redis logs, keys and certificates, NySQL database, Redis Database, Nextcloud config, nextcloud apps

`$SNAP_COMMON` contains the user data and nextcloud logs

These by default point to:
- `$SNAP` -> `/snap/nextcloud/current/`
- `$SNAP_DATA` -> `/var/snap/nextcloud/current`
- `$SNAP_COMMON` -> `/var/snap/nextcloud/common/`

these information can also be retrieved (and even changed) by looking/editing the file:
`/var/snap/nextcloud/current/nextcloud/config/config.php`

Additional information about snap packages, they are squashfs images stored in `/var/lib/snapd/snaps/` and mounted in `/snaps`.

To correct my mistakes, I did (using sudo when appropriate):

- `cp /etc/fstab /etc/fstab.old_V1`
- `mkdir /media/volume1`
- edit fstab to mount volume on /media/volume1
- `mkdir /home/cloud_bckup`
- `cp /var/snap/nextcloud/* /home/cloud_bckup/` # it saves the config and data from my nextcloud install
- restart the server. If everything wen well, the server started, but we fucked up the snapd install
- to clear the mess, I `apt purge snapd` then `apt install snapd` to reinstall snapd cleanly
- I `sudo snap install nextcloud`
- `sudo snap stop nextcloud` to ensure that nothing happens before I put back all the config.
- `rm -r /media/volume1/*` to clean the volume now mounted in /media/volume1
- `ls -l /media/volume1` to check that we actually cleaned it
- `cp /home/cloud_bckup /media/volume1/` to put the data and config on the external volume (as wished)
- save the actual fstab as fstab.old_2 and edit the fstab to mount the volume in `/var/snap/nextcloud`
- `rm -r /var/snap/nextcloud/*` to clean the config and other things that the new nextcloud install created.
- restart the server and if everything went ok:
    + the server should start
    + the volume should be mounted at `/var/snap/nextcloud` (can check by touching a file in there and
looking if it is also created in /mnt/... (the volume /mnt place)
    + if we tyr to connect to nextcloud, we should see the custom login page, the file should be there and
no warnings should appear (https should also work directly)
- `rm -r /home/cloud_bckup` because we don't need a copy of it anymore now.

I will also need to create an alert in the digital Ocean dashboard to send me an info when
the storage on the block runs low

### Nextcloud install

I will follow the documentation provided by Digital Ocean to install a snap of Nextcloud.

    ```$ sudo snap install nextcloud
       $ snap changes nextcloud #list changes done to the snap to check install
       $ snap info nextcloud
       $ snap interfaces nextcloud
       $ less /snap/nextcloud/current/meta/snap.yaml #optional, to check component in the snap
       
       $ sudo nextcloud.manual-install Nextcloud-Username Nextcloud-password
       #this will create an administrative user and set it's password
       #it prevents malicious attacker to create an administrative account when we will
       #open nextcloud to the internet

       $ sudo nextcloud.occ config:system:get trusted_domains
       #give us a list of trusted domain that can access nextcloud
       
       $ sudo nextcloud.occ config:system:set trusted_domains 1 --value=real.example.com
       #if we look at the trusted domains, we should see 2 trusted domains, localhost and 
       # real.example.com
       # to set other trusted domain I can use the same command and change the "1" to any
       # other number to place the domains in different order
    ```

I will now configure an ssl certificate using lets encrypt. there is a script already 
available in nextcloud.

    ```
    $ sudo ufw allow 80,443/tcp #open the firewall for nextcloud and letsencrypt
    $ sudo nextcloud.enable-https lets-encrypt
    # it will start the script for the certificate, I will need an email address
    # I will also need the server's domain (or subdomain)
    ```

Now the nextcloud instance is ready to be used.
Got to the domain address and enjoy nextcloud!


## APACHE config:

## OpenSSL:

1. To create a self signed OpenSSL certificate see Digital Ocean how to.
I enabeled the a2enmod mode for Apache:

  `sudo a2enmod ssl`

  then restart Apache

2. Create a new key and self signed certificate:

  `sudo openssl req -X509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/apache2/ssl/apache.key -out /etc/apache2/ssl/apache.crt`

    - **openssl**: commande for openssl
    - **req**: This specifies a subcommand for X.509 certificate signing request (CSR) management. X.509 is a public key infrastructure standard that SSL adheres to for its key and certificate managment. Since we are wanting to create a new X.509 certificate, this is what we want.req: 
    - **x509**:  This option specifies that we want to make a self-signed certificate file instead of generating a certificate request.
    - **nodes**: This option tells OpenSSL that we do not wish to secure our key file with a passphrase. Having a password protected key file would get in the way of Apache starting automatically as we would have to enter the password every time the service restarts.
    - **days 365**: specify validity lenght of the certificate
    - **newkey rsa:2048**: This option will create the certificate request and a new private key at the same time. This is necessary since we didn't create a private key in advance. The rsa:2048 tells OpenSSL to generate an RSA key that is 2048 bits long.
    - **keyout**: This parameter names the output file for the private key file that is being created.
    - **out**: This option names the output file for the certificate that we are generating.

  We placed the certificate in ***`/etc/apche2/ssl/apache.crt`***
  We placed the private key in ***`/etc/apache2/ssl/apache.key`***

3. Then configure apache2 (change stuffs in the file `/etc/apache2/sites-available/default-ssl.conf`)

### Renew Self Signed Certificate:

1. We will use the old key (for now located in /etc/apache2/ssl/apache.key)
  and replace the apache.crt file with our new key, then restart apache

2. Create new certificate with existing key:

  `openssl req -key *domain.key* -new -x509 -days 365 -out *domain.crt*`
  
  change domaine.key and domain.crt to the key and certificate i want.

3. restart apache (`sudo service apache2 restart` on ubuntu 14.04)  

Next is the link to a really good openSSL cheatsheet:
[openSSL cheatsheet](https://www.digitalocean.com/community/tutorials/openssl-essentials-working-with-ssl-certificates-private-keys-and-csrs)

