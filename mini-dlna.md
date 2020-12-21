# Mini-dlna info

after installing minidlna, the deamon should be enabled and start at the next boot. If it doesn4t start, use systemctl.
config file is in:
    ```
    /etc/minidlna.conf
    ```
There you can change the server name.
You can change the user and group for minidlna by editing:
    ```
    /etc/default/minidlna
    ```

firewall:
- 8200, TCP
- 1900, UDP
