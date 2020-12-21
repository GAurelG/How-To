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
3. create dataset: `sudo zfs create pool/dataset`
4. set recodrsize for the pool `sudo zfs set recordsize=1M pool/dataset`
5. `zpool status` to get the overview of the zpools
6. `zfs list`
7. `zfs list -t snapshot` to list the snapshots
8. `zfs destroy pool/dataset`
9. `zfs destroy pool/dataset@snapshot`

I decided to use syncoid and sanoid tools to make automatic snapshot and synchronization of the snapshot to another pool/dataset.
In ubuntu 20.04 the tools are in the repository. In older ubuntu, you will need to get it from github and manually install it (see the 'INSTALL.md' file in the github repository.

## Sanoid:

create and edit the config file at `/etc/sanoid/sanoid.conf`
We will need two template, one for the main pool with the options `autoprune = yes` and `autosnap = yes`.
As syncoid only sends the datasets and snaphots, but do not delete the older snapshot that were removed from the main pool, we need to use sanoid to remove older snapshots on the pool copy.
To do so, copy the template to have the same retention policy (change the name) and change the option `autosnap = no` but keep `autoprune = yes` this way sanoid will delete snapshots but not create new ones.

## Syncoid:

Syncoid is a command line tool, it has no automatically running job. To use it I do: `syncoid --no-sync-snap origin_pool/origin_dataset destination_pool/destination_dataset`
the `--no-sync-snap` option is used to avoid new snapshots to be taken when I am only interrested in moving datasets with sanoid taking care of the snapshots.
To make Syncoid do a daily synchronization of the datasets, I created a `syncoid.service` and a `syncoid.timer` to make this automatically. Both files have to be placed in `/etc/systemd/system/` and enabled and started.

# transfert pool to other install

1. export pool from old instance:
    ```
    sudo zpool export baleine
    sudo zpool export elephant
    ```
2. check potential pool to import on new instance:
    ```
    sudo zpool import
    ```
3. import pools:
    ```
    sudo zpool import elephant
    sudo zpool import baleine
    ```
# Manage mountpoint:

- `sudo zfs mount`: list pool and dataset and their muontpoint
- `sudo zfs set mountpoint=/SOMETHING/SOMETHING pool/dataset`: mount the dataset at /something/something

# link

Once dataset are mounted, I make link to specific folde in the home directory:
- Documents
- Musique
- Musique_FLAC
- Vidéos
- Anime
- Ansible
- Archive
- DVD
- Téléchargements
- ISO
- Jeux_Rom
- Livres
- Modèles
- Programation
- Bureau

