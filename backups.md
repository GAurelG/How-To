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
    - The raspberry pi would ssh to the server and open a reverse tunnel
    - The server would backup, and send the backup over the network
to be stored on the Hard drive attached to the raspberry pi.
    - I need to be informed if an error pop up during backup
    - I will need a way to handle changing hard drive to store one in remote
 location
    - The job should probably be triggered using either a cron job or
a systemD timer. Advantage of the timer being that it will be retried if 
the machine was off at the time it should've acted I think.
    - The raspberry pi should not be always connected to the server to
reduce the time window the different ports are open
    - The raspberry pi should probably trigger the backup to avoid the
failure of it due to the remote end point being anavailable (internet 
or electricity outage at home)

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

I will use a reverse tunneling from the raspberry pi on the server and make it trigger a backup script.

I will have to manage to send emails once the script is finished to 
inform myself in case of a problem.

## Raspberry pi set-up

I choose raspbian lite as a base, did the normal installation. I decided to use
 the graphical set-up tool to expand the partition to the full SD card and also
 to set up the keyoard to french layout. I tried to look around a bit, but it 
was taking some time and not really successful at the time.

Once the card is fully set-up, I should do a img of the card so that I can
restore the raspberrypi fast in case of SD card failure.
I could also look into making an ansible playbook or similar type of configuration
 management tool.

Steps done on the pi:
    - change default password
    - create another user
    - set-up ufw firewall
    - install SSH server
    - set-up ssh connection using key from different machines
    - create a new user only for backups, without sudo rights
    - create an ssh key for this user
    - upload the key on the server to make the autentication possible

## Server set-up

 I created a new user to do the backup. It is an account without home or
administrative rights.

Steps done:
    - `sudo adduser --no-create-home save-user` this creates a new user and
 group without home
    - `sudo usermod -a -G save-user myUser` this adds (-a) the group (-G)
save-user to my main user.
    - `sudo chgrp -Rv save-user /var/snap/nextcloud` this change the group 
of belonging of /var/snap/nextcloud. The group rights are read only.
    
