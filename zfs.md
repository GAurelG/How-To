Info on how to use the zfs filesystem on ubuntu.

# Creating a pool:
1. create the pool with two drives in mirrors. Set the ashift variable for the vdev. We set it up with 12 for performance as it is a sane default for my drivce. look on it for more info regarding the best value. I also specified the mountpoint, it can also be done later. The default creates a mount point under /.
    ```
    sudo zpool create -m /mnt/baleine baleine mirror -oashift=12 /dev/disk/by-id/ata-WDC_WD80EMAZ-00WJTA0_1EHDBGNZ /dev/disk/by-id/ata-WDC_WD80EMAZ-00WJTA0_1EHY7D4Z
    ```
2. we then set variables for the pool:
    ```
    sudo zfs set atime=off baleine
    sudo zfs set compression=lz4 baleine
    ```

for more info about possible good default values see Jim Salter's excellent [website](https://jrs-s.net/2018/08/17/zfs-tuning-cheat-sheet/)


