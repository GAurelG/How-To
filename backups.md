The goal of this document is to documents the steps I am taking to backups the Nextcloud instance.
I am going for a backup from home as I don't want to spend money on a monthly cloud backups.
The other advantage of the raspberry pi is that I will also use it to do a secondary backup of my
home data.
Ideally I would have 2 hard drives that I could interchange to bring one to a remote location.

In the first part I am only going to talk about the set-up for the Nextcloud backup as other 
strategy haven't been think through for now.

# Nextcloud backup

## What to backup

The server installation is Ok described to allow me to install it relatively fast.
The main things to backups are:
    - the nextcloud user data
    - the nextcloud configuration data

Ideally on a new install, one should just need to `sudo snap stop nextcloud`, 
copy the saved data in the appropriate location and start the nextcloud snap again.
In case the server has a different IP address, I would also need to adjust my DNS
redirection on Gandi (or the domain name company).

The environment variable containing the Nextcloud data are described below:

    - `$SNAP` for the nextcloud software app data
    - `$SNAP_DATA` for the apache/PHP/MySQL/Redis logs, keys and certificates,
 NySQL database, Redis Database, Nextcloud config, nextcloud apps
    - `$SNAP_COMMON` contains the user data and nextcloud logs

These by default point to:
    - `$SNAP` -> `/snap/nextcloud/current/`
    - `$SNAP_DATA` -> `/var/snap/nextcloud/current`
    - `$SNAP_COMMON` -> `/var/snap/nextcloud/common/`

these information can also be retrieved (and even changed) by looking/editing the file:
`/var/snap/nextcloud/current/nextcloud/config/config.php`

## The Backup strategy

I am behind my ISP provided router and have no motivation to open a port in it. 
I also want to avoid possible change of my IP address by the ISP.

On the strategic level, I don't want to rely on a monthly subscription for data 
that has a sentimental and practical value, but not much value in themself.
That is why I wanted to go the self hosted route, I ionly invest in Hardware 
for a limited amount of money and, due to the low amount of disk stress my
backup scenario have, it should costs less than monthly based subscription.

I also want to avoid any storage of the backup on the server as this data will cost
money if stored there. I also want to have my data secure during transfert.
I will also consider encrypting the backups, but am not sure if I do it at the 
disk level or on a file level. File level might be simpler to run as I could 
change the disk and still get encrypted backups using the same passcode...

The strategy:

    - a raspberry pi with external storage running at home
    - access to the nextcloud server for the raspberry pi 
    - backup of the nextcloud data to the storage attached to the raspberry pi
    - The job can be scheduled using either a cron job or
a systemD timer. Advantage of the timer being that it will be retried if 
the machine was off at the time it should've acted I think.
    - The raspberry pi should not be always connected to the server to
reduce the time window the different ports are open

## The software stack

My first choice is to go with duplicity as a backup tool.
I used it on Ubuntu through the GUI Deja-dup and it worked well.
Duplicity also has the possibility to directly store the backups on 
a remote location using scp (or another network protocol).
Duplicity is also able to encrypt the data ad uses rsync for incremental
 backups. Whiole it doesn't offers the deduplication of Tarsnap, for 
lowvalue data it should be efficient enough.

    `duplicity --full-if-older-than <time> /folder/to/backup scp://host.net/target_dir`

    - <time> is a number and a letter describing the regularity of full backups
, every other backups should be incremental: D for days, M for month

Other options I will/could use:
    - --include /directory  I can use several inclue parameters on one command
    - --exclude /directory  same as include, can use several one
    - --remove-older-than <time> [-force] <url_path_backups>
    - --remove-all-but-n-full <time> [-force] <url_path_backups> the force option is
necessary to remove backups

    - --encrypt-key to use the GpG encryption.

I will use an sshfs connection from the raspberrypi to the nextcloud server to have
 "local" access to the nextcloud data from the raspberry pi for the backup.
It might not be the most performing solution, but it is good enough for my scale.

    - remove all backups except the last full and the incremental

    `duplicity remove-all-but-n-full 1 file:///path/to/backup`

    - remove all incremental except for the last full backupsand set of incrementals:
    
    `duplicity remove-all-inc-of-but-n-full 1 file:///path/to/backup`

## Raspberry pi set-up

Second Iteration using a raspberry pi 4 for the faster ethernet and usb bus.
I am also now using an ansible playbook for most of the set-up. it was successfully
tested for reproducability several times.

Steps before the ansible script:
  1. download the ubuntu ISO
  2. flash the ISO on the SD card. I used gnome disks.
  3. extend the partitions on the SD card (also done using gnome disks)
  4. if I need wifi then configure netplan:
	`sudo cp /usr/share/doc/netplan/example/wireless.yaml /etc/netplan/`
        `sudo vim /etc/netplanwireless.yaml`
     tip: add `optional: true` below the `dhcp4: true` line
     need to rename the wireless interface as ubuntu is using wlan0 name and not the
     same standard as the example in the file.
  5. add OpenSSH and enable it using ufw:
        ```
        sudo ufw allow OpenSSH
        sudo ufw enable
        sudo ufw status
        ```
  6. update if want to and reboot the raspberry pi
  7. from main machine, add ssh key on the raspberry pi:
    `ssh-copy-id -i ~/.ssh/key.pub username@remote`
  8. if needed edit `~/.ssh/config` on the main machine to add an entry for the 
     raspberry pi and change `~/.ssh/known_hosts` to remove older entry with the same
     hostname to avoid the "possible man in the middle attack!" warning message at the 
     first ssh connection.
  9. try to ssh on the raspberrypi using the ssh key.
  10. adjust the ssh parameters of the ssh daemon on the raspberry pi:
      `sudo vim /etc/ssh/sshd_config`
      change the parameters to:
      `PermitRootLogin no`
      `PasswordAuthentical no`
  11.  reboot and test the ssh connection with the new parameters
  12. run the ansible playbook:
      `ansible-playbook playbook.yaml --ask-vault-pass`
  13. shut down the raspberry pi manually,
       plug it in the rooteur, the hard drive and turn it on.
  14. test if the sshfs is mounted and if the harddrive is accessible.
  15. when connecting to the raspberry pi via ssh, there might be a dns problem with
      the routeur if you re-build the raspberry pi several times for tests purposes.
      Use the routeur interface to check if the routeur is actually up and connected.
      Do not rely on pinging the hostname. Or don't be lazy and run your own DNS server.
  16. can also add ssh keys from other devices that needs access to the raspberrypi.

## nextcloud server set-up

 I created a new user to do the backup. It is an account without home or
administrative rights.

Steps done:
    - `sudo adduser --no-create-home save-user` this creates a new user and
 group without home
    - `sudo usermod -a -G save-user myUser` this adds (-a) the group (-G)
save-user to my main user.
    - `sudo chgrp -Rv save-user /var/snap/nextcloud` this change the group 
of belonging of /var/snap/nextcloud. The group rights are read only.
    
