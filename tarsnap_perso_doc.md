I will try to write my tarsnap doc here first.
To start I will mainly have extra t from their wonderful website.
I will probably make some kind of a summary at the end, but the main documents is basically copy/paste from the tarsnap website.

# Summary 
# install the tarsnap client and make the initial configuration

1. Install tarsnap using one of the Deb they have on their website

1.2. I will run the tarsnap client to get an estimate of the GB I will be sending them. This helps me calculate the price I will pay.
The interesting value is the "compressed" one.

```tarsnap --dry-run --no-default-config --print-stats --humanize-numbers -c /MY/DATADIR

Replace /MY/DATADIR with the name of the directory which contains the files you wish to back up. You may also list multiple directories to back up. For example, you may wish to back up:

/etc /home /var/www```

The price can be calculated using the tarsnap prices on the website (there is part of the price for uploading and part of the price for the long term storage.

The tarsnap client does deduplication so the next backups won't really add much to the price.

2. Set up the configuration file

    We recommend that you begin with the default configuration file:
    If you are using the deb packages, then this file is already located in

        /etc/tarsnap.conf

You may check this text file (comments are indicated with the # character). Do not worry about the keyfile; that will be created in step 5. 

3. Sign up for a Tarsnap account

    - Sign up on the Tarsnap registration page. (Can be found on their website)
    - You will receive an email asking you to confirm your registration.
    - Email confirmation serves two purposes, as it:
          + Checks for mistyped or otherwise undeliverable email addresses.
          + Ensures that people can't be registered against their will. 

4. Deposit funds into your account

   - Log into the Tarsnap account management interface and add funds to your account.
    - The initial deposit must be $5 or more.
   -  Tarsnap operates on a prepaid basis (like many mobile phones), so you must add funds to your account before you can use it

5. Register the machine(s) on which you will be using Tarsnap

    To register a machine with the Tarsnap server,
    On most systems (Linux, macOS, etc.)

    `sudo tarsnap-keygen \
    	--keyfile /root/tarsnap.key \
    	--user me@example.com \
    	--machine mybox`

with appropriate values substituted:

    **/root/tarsnap.key**: file in which to store the keys used to create and access archives.
   **me@example.com**: the email address you used to sign up with Tarsnap.
    **mybox**: a name which is displayed in accounting reports so that you know how much data each machine is storing.

    Enter your Tarsnap account password when prompted.
    The *tarsnap-keygen* utility registers a machine with the Tarsnap server, which:
        - Confirms that the machine's usage should be charged to your account.
        - Generates cryptographic keys used to store, restore, and (optionally) delete the machine's backups.

6. Keep your key file safe

- Store your **/root/tarsnap.key** somewhere safe.
    ***If you lose tarsnap.key, you will not be able to access your archived data.***

- There are many ways to keep it safe:

    + Copy it to a different system.
    + Put it on a USB disk.
    + Give it to a friend.
    + Print it out (it is printable text).
    + Store it in a bank vault.

Once you've created your key file(s), you're ready to start using Tarsnap.
Remember: If you have multiple machines, you almost certainly want to create a separate key file for each machine. Repeat steps 5 and 6 as appropriate. 

# Backing up using tarsnap

## General info from tarsnap:

Even the world's best backup service is useless if it's not used properly. Fortunately, there's only two steps to proper backups:

    1. Making backups
    2. Testing / restoring backups

Remember that thanks to deduplication, only unique data will be uploaded. It's better to create "too many" backups rather than "not enough"! 

## Step 1

First, create a backup script; this may be run manually, or scheduled to run automatically.

### Step 1A: Backup script

    1. Create a */root/tarsnap-backup.sh* script containing:

   ``` #!/bin/sh
    /usr/local/bin/tarsnap -c \
    	-f "$(uname -n)-$(date +%Y-%m-%d_%H-%M-%S)" \
    	/MY/DATADIR```

    Please note:
        - We recommend using the full path, as this avoids potential problems with $PATH and crontab.
        - Replace /MY/DATADIR as appropriate.
        - You may also list multiple directories to back up. For example, you may wish to back up:

        "/etc /home /var/www*

        - The *-f* command defines the "archive name" in which your data is stored on the Tarsnap servers.
        - Each keyfile defines a new namespace for archive names, so don't worry about using the same naming scheme as somebody else!
            - The command *`$(uname -n)`* automatically turns into your computer's $HOSTNAME.
            - Optionally, change the format of the timestamp.
            The above command produces names in the form:

            `mybackup-2015-08-07_13-52-46`

 2. Make the script executable, then run it whenever you want:

    ```chmod u+x /root/tarsnap-backup.sh`
    /root/tarsnap-backup.sh```

    - tarsnap does not print any "progress" or "completion" messages unless the user requests them with the -v or --print-stats command-line arguments.

 Check that you can restore these backups with Step 2: Testing / restoring backups. 

### Step 1B: Automatic backups (optional)

1. Add this to your crontab:

    `27 0 * * * /root/tarsnap-backup.sh`

  This sets up a daily backup task, but note:
        - The time shown above is generated randomly each time this page loads.
        - Please do not use the same time on large numbers of systems, in order to avoid creating load bursts.

2. Wait a day for the script to run automatically.
3. Check that you can restore these backups with Step 2: Testing / restoring backups.
I
    It is not enough to check that tarsnap-backup.sh works when you run it manually! Check the automatic backups, in case there is any problem with cron. 

# General tips from tarsnap website

1. You can print statistics about all archives with:

tarsnap --print-stats -f '*'

2. `tarsnap-keymgmt` creates new keys with (optionally) reduced permissions. In particular, it can create "write-only" keys:

tarsnap-keymgmt --outkeyfile write-only-key.txt -w ~/tarsnap-main-key-file.txt

This allows you to create a write-only key (without a passphrase) which is used to create archives automatically, and a key with more permissions (requiring a passphrase) which is used for restoring or deleting archives. In this system, if an intruder breaks into your server, she would be able to halt your backups (or add new archives with faulty data), but not delete your existing archives.

If you want to keep your full keys on a different (more secure) system and only use them there, or use keys on multiple systems for any other reason, things get more complicated.


