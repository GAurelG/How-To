# Virtualisation

I will write information about virtual machines, container (maybe snaps, docker...)

## KVM

It is important to check if the hardware is able to support virtualization, and if it is enabled in the BIOS.
Then we install lib-virt qemu and the qemu-kvm package to have the hardware acceleration:

    ```
    sudo apt-get install qemu-kvm libvirt-bin bridge-utils virt-manager
    sudo adduser name libvirtd
    ```

The second step is necessary if the user isn't in the virtd group as it blocks you froom actually running virtualization
software.
You might have to create the group before adding a user to it:
   `sudo addgroup libvirtd`

As we installed the GUI tool 'virt-manager' we can use that to create virtual machine.

## Creating Windows VM with GPU pasdsthrough on ubuntu 18.04

This is a copy of the excellent guide at Level 1 tech forum. I might make some modification once I encounter corner cases.
https://forum.level1techs.com/t/elementary-os-5-0-ubuntu-18-xx-vfio-pcie-passthrough-guide-tutorial/131420

### Virtualization

- make sure you have vt-d/vt-x/svm or “virtualization” enabled (and your CPU supports it) in your BIOS/UEFI. On my setup, it was called SVM (Secure Virtual Machine)
- make sure you have IOMMU enabled (and your board supports is) in BIOS/UEFI. On my setup it was under “chipset” tab simply called IOMMU
- Install Virt-manager and following packages

`sudo apt-get install virt-manager qemu-kvm ovmf`

installation may take a while
don’t try to run virt-manager directly after install, it will most probably end up throwing error at you.

reboot

After you rebooted, open virt manager (should be in list of your installed apps). It should start without any error giving you nice tiny window.
*If you encounter some errors, just google your way out of it, may be missing some packages or having wrong user rights*

There might be a need to enable iommu in GRUB I see IOMMU groups without editing GRUB on KDE Neon

### Enable IOMMU in GRUB

Most Linux distros do not enable IOMMU by default.
You will need to update your grub bootloader config to support IOMMU.

    `sudo nano /etc/default/grub`

and add following to the `GRUB_CMDLINE_LINUX_DEFAULT` line:
A) for Intel CPU:

    `iommu=pt iommu=1 intel_iommu=on`

B) for AMD CPU:

    `iommu=pt iommu=1 amd_iommu=on`

it looks like: GRUB_CMDLINE_LINUX_DEFAULT="quiet splash iommu=pt iommu=1 amd_iommu=on"
save file (ctrl + x, y, ENTER) and run:

    `update-grub`

REBOOT

### Check if IOMMU is working

it is a good idea to check to see that IOMMU grouping is working properly. This script from Wendell will help you:

    ```
    cd ~
    nano iommu-check.sh
    ```

and copy following:

    ```
    #!/bin/bash
    for d in /sys/kernel/iommu_groups/*/devices/*; do
      n=${d#*/iommu_groups/*}; n=${n%%/*}
      printf 'IOMMU Group %s ' "$n"
      lspci -nns "${d##*/}"
    done
    ```

save and exit.

then run:

    `sh iommu-check.sh`

Now you need to find your 2 GPUs (including their audio interfaces).

Possible edge case scenarios:
A) GPUs are sharing same group, or IOMMU is not working, follor this guide:
    https://forum.level1techs.com/t/elementary-os-5-0-beta-vfio-pcie-passthrough-guide-tutorial/131420/17
B) cards with identical IDs (for example, my RX580 and 570 have same ID).

I avoided these cases and will not document them.



### Assigning VFIO driver to a GPU

**FOLLOW THIS STEP ONLY OF YOUR GPUs HAVE DIFFERENT PCI IDs**

otherwise use workaround from this guide: https://forum.level1techs.com/t/vfio-in-2019-pop-os-how-to-general-guide-though-draft/142287 4

We are ready to setup our devices to be used inside a virtual machine.
To do this, we must bind the vfio-pci driver to the device(s) we want to pass through to the virtual machine, and this is most easily done by PCI device ID.
In my case PCI device IDs of my Nvidia 450 and its audio interface are:
[10de:0dc4] and [10de:0be9]

To get around system using its own Nvidia (or AMD) driver. Wendell wrote us yet again nice tiny guide.
But first, you have to check, which driver is used for your GPU:
run:

     `lspci -nnv |less`

and finda GPU you want to pass in the list:

Notice the Kernel driver in use is nvidia. Thats what you have to use while editing following config file

    `sudo nano /etc/initramfs-tools/modules`

and add following lines at the end of file.
Replace nvidia on first and last line, if your kernel driver in use is different. Replace your PCI IDs with the GPU and its audio interface you want to use for virtual machine. Example:

    ```
    softdep nvidia pre: vfio vfio_pci
    
    vfio
    vfio_iommu_type1
    vfio_virqfd
    options vfio_pci ids=10de:0dc4,10de:0be9
    vfio_pci ids=10de:0dc4,10de:0be9
    vfio_pci
    nvidia
    ```

save and exit.
Now edit:

    `sudo nano /etc/modules`

and add following and don’t forget to change IDs again

    ```
    vfio
    vfio_iommu_type1
    vfio_pci ids=10de:0dc4,10de:0be9
    ```

save and exit

We will also create explicit configurations for the modules in `/etc/modprobe.d`
A) for AMD GPU:

    `sudo nano /etc/modprobe.d/amdgpu.conf `

and add following:

    `softdep amdgpu pre: vfio vfio_pci`

B) for NVIDIA GPU

    `sudo nano /etc/modprobe.d/nvidiagpu.conf `

and add following:

    `softdep nvidia pre: vfio vfio_pci`

even more configs to edit!
    `sudo nano /etc/modprobe.d/vfio_pci.conf`

and add following: *REPLACE IDS*,**AGAIN**

    `options vfio_pci ids=10de:0dc4,10de:0be9`

then run:

    `sudo grub-mkconfig; sudo update-grub; sudo update-initramfs -k all -c`

REBOOT AND PRAY

after reboot run:

     `lspci -nnv |less`

and look for GPU you want to pass to a VM.

If all went well, it should be using `vfio-pci` driver now

### Configuring AppArmor

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

### Setting up VM

Start Virtual Machine Manager and create new VM file -> new virtual machine

Select your installation method - most probably from local media.
Continue and select .ISO file you want to install from.

Windows 10 ISO can be downloaded here:

https://www.microsoft.com/software-download/windows10 33

On next screen you can assign CPU threads and amount of RAM your VM will be given.

Next you will be asked for maximum storage size of your VM

Now you’re on last screen make sure to check customize configuration before install

continue, config window will pop up

First, on Overview tab, we need to change Firmware to UEFI: dont forget to click Apply


Remove Display Spice device
Remove Video QXL device
Remove Channel Spice

Now click add hardware at the bottom.

Window will pop up.

Select PCI Host Device and add your GPU.
Repeat this step to add your GPUs AUDIO interface as well

Make sure you have monitor plugged in into your passed GPU

Click Begin installation on top and pray it f*cking works

### Code 43 fix (Nvidia cards)

You may need to edit your VM config manually, using virsh, if you have trouble with Nvidia being ass or for other specific changes.

run:

    `sudo virsh`

then type

    `edit win10`

replace *win10* with your VM name. If you installed Windows 10 and did not edit its name, it should be that*

you will be asked what editor you want to use, suggest selecting nano. Vim for hardcore oldschool dudes.

Nice long config will fill your screen.

find `hyperv` section and add following:

    ```
    <vendor_id state='on' value='fknvidia'/>
    ```

and add new section under features

    ```
    <kvm>
      <hidden state='on'/>
    </kvm>
    ```

so it all looks like this: 

this should get your around Nvidia code 43

If your windows installation BSODs (well, reboots), try changing CPU topology from host-passthrough to lets say… EPYC (depends on your cpu model)

Now let's hope it works. :)

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
