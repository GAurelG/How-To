# tips regarding the raspberry pi

## Netdata set-up

to get the temperature sensor to show up in netdata:

install lm-sensors
the sensors detect doesn't seem to show anything on the raspberry pi.
But the lm-sensors backend should help netdata.
we need to edit a config file and uncomment the row to have: `sensors=force`
to do so:

    ```
    cd /etc/netdata
    sudo ./edit-config charts.d.conf
    ```

uncomment the row for `sensors=force`

then restart netdata `sudo systemctl restart netdata.service` or reboot the raspberrypi.
A new category should appear at as the last category with the name: "sensors"


