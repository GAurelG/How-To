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

### KVM and hardware passthrough

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
Now we can check if the docker ddaemon is running:
    ```
    sudo systemctl status docker
    ```
As docker runs as root, you either need to always use sudo or put yourself in the docker group.
    ```
    sudo usermod -aG docker ${USER}
    ```
now you can log out and in to actually have the group assigned to you.

###
    
    
