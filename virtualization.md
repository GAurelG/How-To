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
