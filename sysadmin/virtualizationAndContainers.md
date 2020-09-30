# Virtualisation

I will write information about virtual machines, container (maybe snaps, docker...)

## KVM

### Prerequisites:

- make sure you have vt-d/vt-x/svm or “virtualization” enabled (and your CPU supports it) in your BIOS/UEFI. On my setup, it was called SVM (Secure Virtual Machine)

if you want to use the PCI passthrough technology :


It is important to check if the hardware is able to support virtualization, and if it is enabled in the BIOS.

- make sure you have IOMMU enabled (and your board supports is) in BIOS/UEFI. On my setup it was under “chipset” tab simply called IOMMU

### Software to install

There are several way to install the packages we want.
In the end we want to create virtual machines using QEMU with KVM and to manage it graphically we want to use virt-manager.

    ```
    sudo apt-get install virt-manager qemu-kvm ovmf
    ```
    
This should pull the required additional packages.
Reboot and you should be able to open the software "virt-manager".
In case it doesn't open, there might be privilege problem.
Check your user is part of the `libvirt` (`$groups` should list libvirt). If it isn't, you will have to add your user to the group. you might also have to create the group.

## Set-up PCI passthrough for GPU on ubuntu 20.04

### IOMMU groups:

IOMMU should be enabled in the BIOS.

Check the ID and the groups of the different devices, use the following script:

    ```
    #!/bin/bash
    for d in /sys/kernel/iommu_groups/*/devices/*; do
    n=${d#*/iommu_groups/*}; n=${n%%/*}
    printf 'IOMMU Group %s ' "$n"
    lspci -nns "${d##*/}"
    done
    ```

With this, you should be able to get the ID os the component you want to passthrough.
For only a list of devices with ID without the IOMMU group information, you can run:

   ```
   lspci -nnv | less
   ```
and search for the appropriate line.

The next steps are easy because we have GPU with different ID's

IOMMU should also be enabled in `GRUB` (there are other way to do it with systemd-boot or other bootloaders).

    ```
    sudo vim /etc/default/grub
    ```
    
    edit the paramter row `GRUB_CMDLINE_LINUX_DEFAULT`
    
    - edit the file and add the amd_iommu or intel_iommu depending on your CPU manufacturer.
    - add the kvm.ignore_msrs=1 should help avoid some random problems in the VM by stopping KVM from handling MSRs
    - add iommu=pt to stop linux from touching devices that can't be passed through (not mandatory)
    - add vfio-pci.ids= matching the ID found with the above script for the GPU and the audio interface of the GPU. As these comments pass kernel parameters to linux, we will not have access to the GPU we are giving the IDs in the linux session. TO have access we would need to use hooks at the starts and ends of a VM session. see (https://github.com/bryansteiner/gpu-passthrough-tutorial)[https://github.com/bryansteiner/gpu-passthrough-tutorial]

    for AMD CU you get: `GRUB_CMDLINE_LINUX_DEFAULT=quiet splash amd_iommu=on kvm.ignore_msrs=1 vfio-pci.ids=XXXX:XXXX,XXXX:XXXX`
    then update grub:
    
    ```
    sudo update-grub
    ```
    
    - reboot
    
- Check that everything worked, run:
    
    ```
    lspci -nnv | less
    ```
if everything went well, the driver for the appropriate GPU should read something like `vfio-pci`

It is possible that the bot time becomes quite long if you are trying to passthrough an Nvidia card and you have the Nviodia drivers installed.
This is due to a bug in the Nvidia drivers that don't like to be not assigned to the GPU. To mitigate this, use the `nouveau` driver.

    
### Configuring AppArmor (optional)

Depending on the situation, AppArmor might block us from running the VM with passthrough. In case of a problem this section might be needed.

Before we setup our virtual machine, we need to deal with AppArmor first. App Armor, in a nutshell, prevents programs from doing suspicious things.

    `sudo nano /etc/apparmor.d/abstractions/libvirt-qemu`

find following lines (by pressing CTRL + W and typing usb access) and edit them like so:
    
    ```
    # for usb access
    /dev/bus/usb/** rw,
    /etc/udev/udev.conf r,
    /sys/bus/ r,
    /sys/class/ r,
    /run/udev/data/* rw,
    ```

Note that if you intend to pass through a “real” block device to QEMU/libvirt, you will also need to open up things a bit more, adding lines such as:

    `/dev/sda rw,`

If, for example, you intend to use /dev/sda as a passthrough block device with your virtual machine. If you are using a qcow2 or image file, you don’t need to do this.

save and exit

restart AppArmor with:

    `sudo service apparmor restart

any issues with AppArmor can be found in /var/log or run dmesg and watch for errors related to virtualization

## Setting up VM

### setting the storage pool

In case we want to use a different location as storage pool we need to set this up.
By default Virtmanager should have connected to the default QEMU/KVM session.
1. right click on the connection
2. click "edit"
3. storage tab
4. add storage, you can point to already existing storage location to later import existing VM

### setting a *new* windows VM

Start Virtual Machine Manager and create new VM file -> new virtual machine

Select your installation method - most probably from local media.
Continue and select .ISO file you want to install from.
If you can't access the location of the ISO it could be because the ISO isn't in one of the storage location.

Windows 10 ISO can be downloaded here:

https://www.microsoft.com/software-download/windows10 33

On next screen you can assign CPU threads and amount of RAM your VM will be given.

Next you will be asked for maximum storage size of your VM

Now you’re on last screen make sure to check customize configuration before install.

Continue, a configuration window will pop up.

1. on Overview tab, we need to change Firmware to UEFI and boot loader to the i440FX: dont forget to click Apply
2. in the CPU part, manually assigne the topology, for me it didn't represent the CPU in a good way. (1 socket, 8 cores, 2 thread)
3. add devices if you want to pass USB devices

#### Specific steps for the GPU passthrough:

You will need to remove the VM devices that are managing the video output and then add the GPU PCI device and the GPU audio PCIE device.

1. Remove Display Spice device
2. Remove Video QXL device
3. Remove Channel Spice
4. Now click add hardware at the bottom.
5. A window will pop up.
6. Select PCI Host Device and add your GPU.
7. Repeat this step to add your GPUs AUDIO interface as well
8. Make sure you have monitor plugged in into your passed GPU

Click Begin installation on top and pray it f*cking works

#### Code 43 fix (passed through Nvidia cards needs it)


You may need to edit your VM config manually, using virsh, if you have trouble with Nvidia being ass or for other specific changes.
for me the symptomes were that while I got a graphical output, the GPU wasn't being recognised by the VM and I only got low resolution graphics.

1. run: `sudo virsh`
2. `edit win10`
3. replace *win10* with your VM name. If you installed Windows 10 and did not edit its name, it should be that*
4. you will be asked what editor you want to use, suggest selecting nano. Vim for hardcore oldschool dudes.
5. Nice long config will fill your screen.
6. find `hyperv` section and add following:

    ```
    <vendor_id state='on' value='fknvidia'/>
    ```

7. add new section under features

    ```
    <kvm>
      <hidden state='on'/>
    </kvm>
    ```

this should get your around Nvidia code 43

If your windows installation BSODs (well, reboots), try changing CPU topology from host-passthrough to lets say… EPYC (depends on your cpu model)

The VM should now start.

### Importing a VM created on another computer/installation

Keep in mind that all information attached to the VM has to be re-created aand isn't available and imported when migrating instance.

1. install all the virtualisation tools like described above.
2. if you use the qcow2format, put the qcow2 file of the VM into a storage pool accessible to KVM, you might have to create a new storage pool
3. right click on the qemu/kvm connection
4. select the `details` option
5. `storage` tab
6. add a pool selecting the wished location
7. now we create a new VM
8. select `import an existing image`
9. follow the process
10. before the end, select the `customize configuration before install`
11. adjust the different parameter like you would do for a new VM (also the passthrough options and nvidia code 43).
12. the type of operating system for Windows 10 might be difficult to find, you need to also show the one that are out of date.
13. install the VM
14. start the VM and hope it works.


# Containers

## Docker

This first attempt will be using docker to install a postgresql database and communicate with it.

### Installing Docker from official repositories:

    ```
    sudo apt update
    sudo apt install apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
    sudo apt update
    apt-cache policy docker-ce # to ensure I am getting docker from official repositories and not the distribution repository
    sudo apt install docker-ce
    docker --version
    ```
Now we can check if the docker daemon is running:
    ```
    sudo systemctl status docker
    ```
As docker runs as root, you either need to always use sudo or put yourself in the docker group.
    ```
    sudo usermod -aG docker ${USER}
    ```
now you can log out and in to actually have the group assigned to you.

### Running the postgresql

    `docker pull postgres`

First create a folder that will be mounted in the container and serve as data storage. This will allow to destroy and re-install the container without touching the data.

    ```
    mkdir -p $HOME/docker/volumes/postgres
    ```
    
Then we actually run the container:

    ```
    docker run --rm   --name pg-docker -e POSTGRES_PASSWORD=docker -d -p 5432:5432 -v $HOME/docker/volumes/postgres:/var/lib/postgresql/data  postgres
    ```
    
The options mean:
  - rm: Automatically remove the container and it’s associated file system upon exit. In general, if we are running lots of short term containers, it is good practice to to pass rm flag to the docker run command for automatic cleanup and avoid disk space issues. We can always use the v option (described below) to persist data beyond the lifecycle of a container

  - name: An identifying name for the container. We can choose any name we want. Note that two existing (even if they are stopped) containers cannot have the same name. In order to re-use a name, you would either need pass the rm flag to the docker run command or explicitly remove the container by using the command `docker rm [container name]`

  - e: Expose environment variable of name `POSTGRES_PASSWORD` with value docker to the container. This environment variable sets the superuser password for PostgreSQL. We can set `POSTGRES_PASSWORD` to anything we like. I just choose it to be docker for demonstration. There are additional environment variables you can set. These include `POSTGRES_USER` and `POSTGRES_DB`. `POSTGRES_USER` sets the superuser name. If not provided, the superuser name defaults to postgres. `POSTGRES_DB` sets the name of the default database to setup. If not provided, it defaults to the value of `POSTGRES_USER`

  - d: Launches the container in detached mode or in other words, in the background

  - p: Bind port `5432` on *localhost* to port `5432` within the container. This option enables applications running out side of the container to be able to connect to the Postgres server running inside the container

  - v: Mount `$HOME/docker/volumes/postgres` on the host machine to the container side volume path `/var/lib/postgresql/data` created inside the container. This ensures that postgres data persists even after the container is removed 

  [source](https://hackernoon.com/dont-install-postgres-docker-pull-postgres-bee20e200198)
 
To connect to the instance later, just do it as usual. you can use psql or other tools.

### Managing docker containers:

    - `docker ps`: list active containers, -a flag shows all installed containers (running or not)
    - `docker start d9b100f2f636`: the number is the containerID found when doing ps. This command starts stopped containers
    - `docker stop sharp_volhard`: can use contqinerID or nqme to stop containers
    - `docker rm festive_williams`: remove an installed container

## Tips for virtualization:

- Mobo: ASrock Taichi X370
- CPU ryzen 7 1800X

With this combination the Bios after version 5.10 supporting the first generation of ryzen CPU (Bios 5.60 and 5.50) have a bug in the AGESA (microcode from AMD included in the BIOS) that isn't allowing GPU passthrough.
The bug makes it looks like everything is going as intended with the passthrough, but the GPU never output any picture for the VM.
To get the BIOS to the required version (5.10) I had to downgrade the BIOS.
This operation isn't officially supported through the BIOS tools because ASrock doesn't want people to downgrade and lose the support for 3rd generation ryzen in case they only have a 3rd gen ryzen.
The downgrade method I will present is only working for BIOS made by AMI (American Megatrends Inc).
I will use the excellent video from  [Spaceinvader One, How to Downgrade an AMD Bios & Agesa](https://www.youtube.com/watch?v=ZzqwjVDKAnU)
You will find the appropriate software in the bios downgrade zip folder.
You also need the BIOS file currently installed on the machine and the one you want to downgrade to. go and find it on the motherboards website.O

1. unzip the downgrade.zip folder
2. unzip/extract the files for the BIOS you got on the motherboard website
3. rename the BIOS currently installed to "existingbios.rom"
4. rename the BIOS you want to downgrade to "bios.rom"
5. copy both renamed BIOS files into the extracted "downgrade bios" folder. you should copy them to:
    ```
    downgrade bios/EFI/BOOT/
    ```
6. format the USB flash drive you will use to use a GPT partition using a fat32 partition. (I used gnome disks)
7. copy the folder "EFI/" from inside the biosdowngrade folder, to the root of the USB flash drive (the flash drive should contain only the EFI/ folder and subsequent folders.
8. put the flash drive into the machine and start it into the BIOS
9. from the BIOS boot using the flash drive. There might be two flash drive listed, choose the one with UEFI in front of it
10. you should end up into a shell. If not, there should be a thing that ask to press any keys, then PRESS ANY KEYS!!! otherwise you will turn in circles.
11. then move to the flash drive, it should be listed as "fs..." I had to use the command:
    ```
    cd fs0:
    ```
12. to check I am in the right device, do `ls` and you should see the EFI and other folder inside
13. `cd EFI`
14. `cd BOOT`
15. check we are in the right folder using the `ls command`
16. do a dry-run to check that we are on the right tracks, to do so follow the next steps.
17. `AfuEfix64.exi existingbios.rom /D`
18. at the end of the Dry-run everything should say either **done** or **ok**. If it doesn't and you get some kind of an error, then you need to check that the BIOS files are what you think they are! maybe even download them again.
19. If everything went well, then we can do a dry run for the downgrade BIOS.
20. `AfuEfix64.exi bios.rom /D`
21. You will get a warning message saying that the ROM file doesn't match the BIOS and ask if we want to continue. we say "yes"
22. at the end of the dry run, everything should look with some "ok" or "enabled" status.
23. now we will do it for real!
24. `AfuEfix64.exi bios.rom /P /B /N /K /X`
25. you should get the same warning as in the dry-run. say yes to continue
26. after it finishes, restart the computer and go into the bios. if everything went fine, you should get to the bios, and the version should be the downgraded bios version.
27. In the BIOS, you need to re-check all configuration, as the BIOS downgrade reset all options in the BIOS.
