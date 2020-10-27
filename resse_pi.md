# Set-up info for resse pi

1. download the image I want to flash on the rapsberry-pi.
   I use the ubuntu server images
2. I use gnome disk to flash the image on the SD card as it is a nice graphical tool.
3. The image being smaller than the SD card, we will need to resize it to the size of the SD card. The partition to resize is the partition that isn't labeled as system-boot partition.
4. once the image takes all the space on the SD card, I will change the hostname configuration to not have the raspberry pi named ubuntu (to help with ssh set-up later).
    - mount the SD card partition we just extended (usually in the file explorer by double clicking)
    - I only need to edit the `/Location/of/the/SD/Card/etc/hostname` file on ubuntu server
    - on some other OS I would need to also edit `/Location/of/the/SD/Card/etc/hosts`.
      To know if you need to replace it, look at the content of the file and spot if it specify the default hostname you want to replace.
      If it is written in there, edit the file and replace the hostname by what you wish.
5. insert the SD card into the raspberry pi, connect keyboard, screen and power it up.
6. login the default user (ubuntu, pswd: ubuntu), you will be asked to change the default password for the user ubuntu.
   To login, you have to wait some times before the pi will accept the password. If you write the good combination of user/password, then wait for 30 second and try again.
7. once done with the password change, we want to allow ssh (should be by default, but can make sure it is) and the firewall
8. `sudo ufw allow OpenSSH` or `sudo ufw allow ssh`
9. `sudo ufw default allow outgoing`
10. `sudo ufw default deny incoming`
11. `sudo ufw enable`
12. `sudo ufw status` should give some information with the rules
12. `sudo systemctl enable ssh.service`
13. `sudo shutdown now` to turn off the pi.
14. plug in the pi to the router and power source
15. add the resse entry in the `/etc/ansible/hosts` files to be able to access it with ssh
16. check that you have the programm `sshpass` installed on the main machine to allow ansible to do ssh connection using password in a promptless way.
17. try `ssh ubuntu@resse` to check that the host is reachable and allow the fingerprint. If you get the password prompt, you can CTRL-C and abort the connection. We just wanted to test if we would reach this far.
    it is also important to register the fingerprint when you get asked for it. Otherwise you will get an error message from ansible.
18. In order for Ansible to be able to use the ssh key, you need the ssh agent to have the key registered and unlocked.
    - eval "$(ssh-agent -s)"
    - ssh-add ~/.ssh/id_rsa
    replace id_rsa by the key you want to register in the ssh agent. Now you will be asked to put the ssh key. We could put something in the bashrc to make it happen
19. run the ansible playbook `resse_setup.yaml` by running: `ansible-playbook ansible/resse_setup.yaml --ask-vault-pass`.
20. If everything is going well, the pi should configure itself and reboot. Afterwards you should be able to connect from any device I have through ssh.
    You might get an error for the task upgrading the packages with a message saying something regarding a lock file. This is because ubuntu does unattended upgrade and it is already trying to update itself.
    In this case, wait some time and try again a bit later until everything runs smoothly.
21. Then I will need to go to resse and actually configure plex through the webUI
22. In order for Ansible to be able to use the ssh key, you need the ssh agent to have the key registered and unlocked.
    - eval "$(ssh-agent -s)"
    - ssh-add ~/.ssh/id_rsa
    replace id_rsa by the key you want to register in the ssh agent. Now you will be asked to put the ssh key. We could put something in the bashrc to make it happen
23. To set-up plex, point the browser to http://resse:32400/web/index.html and you should see the plex web page coming up.
24. configure the plex server with DLNA enabled, link it to the plex account, allow local connection without autentication.
25. To make external storage mount on the raspberry pi I have to plug it in.
26. run `sudo blkid` to get the UUID of the hard drive
27. create the mountpoint for the HDD (proposal in `/media/somename`)
28. create an fstab entry of the form: UUID=UUID-number /media/somename ext4 defaults,x-systemd.automount,x-systemd.device-timeout=30 0 2
    - x-systemd.automount should make the mount process automatic when the drive is connected even after boot
    - x-systemd.device-timeout=30 to reduce the number of seconds the boot process waits for the drive to be available, if it isn't then the raspberry pi should continue the boot process.
      could be reduced to 10
    - 0 tells that the filesystem shouldn't be dumped (if it should this should be a 1)
    - 2 tells the fsck (filesystemcheck) order, root filesystems should have 1, 0 is the default and means no fsck will be performed.
