## From Stackoverflow

There's much nicer solution with systemd now. You create a service which depends and is wanted by you media e.g.: 

`/etc/systemd/system/your.service`

```
[Unit]
Description=My flashdrive script trigger
Requires=media-YourMediaLabel.mount
After=media-YourMediaLabel.mount

[Service]
ExecStart=/home/you/bin/triggerScript.sh

[Install]
WantedBy=media-YourMediaLabel.mount
```

Then you have to start/enable the service:

- `sudo systemctl start your.service`
- `sudo systemctl enable your.service`

After mount systemd fires your trigger script. The advantage over udev rule is that the script really fires after mount, not after adding system device.

Use case: I have a crypted partition which I want to backup automatically. After adding the device I have to type-in password. If I hooked the backup script to udev, the script attempts to run at the time when I'm typing password, which will fail.

Resource: Scripting with udev

Note: You can find your device unit with: `sudo systemctl list-units -t mount`

## déjà-dup tip

to start déjà dup en mode graphique: `deja-dup-preferences`

