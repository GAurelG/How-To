the autosuspend USB devices feature for energy saving also stops older scanner to work.
To temporarily disable the USB autosuspend function run:
    ```
    echo "-1" > /sys/module/usbcore/parameters/autosuspend
    ```
