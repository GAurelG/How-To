# Repairing Nexus 5X bootloop of the death

## reflowing the board:

To reflow the board, remove the board from the case.
I also removed the metal heat protection around the chips to reflow.
Then take an aluminium paper, make a ball and unfold it flat again shiny side up.
This is to refract the warmth from below the board and avoid focussing the warmth on other chips.
Turn on the oven at 200°C. once it is warm, put in the board on the aluminium for 8 minutes.
After the 8 minutes, turn off the oven and let the board cool down. [source](https://www.computerrepairtips.net/how-to-reflow-a-laptop-motherboard/)

## Installing Android

I went with [lineage OS](https://download.lineageos.org/bullhead) as it supports the Nexus 5X quite well.
As the problem for the nexus 5X comes from overheating when it is using the big cores, there is a way to patch the ROM and teh recovery to only use the small cores. This has for effect to slow down the phone, but makes it less likely to be sensitive to the Bootloop fast.
[There](https://github.com/pawitp/nexus-5x-blod-fix) the script to patch the ROM and recovery ISO.
To use it you have to use the script on the recovery.img file and the boot.img that can be found in the LineageOS zip.

steps to install Android are described on the [lineageOS documentation](https://wiki.lineageos.org/devices/bullhead/install).

  - Download the recovery (I went with TWRP)
  - Download the LineageOS build (it is a zip archive)
  - on ubuntu install the required packages to get "fastboot" and "adb"
  - download the script to create the patched .img for recovery and OS

The next part needs to be done only one time and then it is done forever

  - enable USB debugging on the android phone
    + unlock the developper mode and go into it to find the option
  - enable OEM unlock in teh Developer options if present
  - unlock the bootloader
    + connect the device to the computer via USB
  - in the terminal run `adb reboot bootloader`
    + if you see right problems, run teh commands as 'sudo'
    + alternative is to press the control `Volume Down` + `Power`
  - Once the device is in fastboot, check the computer can connect to the phone
     + run the command `fastboot devices` (might need to run as sudo)
  - run `fastboot flashing unlock`
  - reboot the device if it doesn't reboot automatically.
  - since the device reset completely, you will need to re-enable USB debugging to continue

The next part explain how to install the custom recovery

  - We need to patch the TRWP recovery .img
  - Once you have patched your recovery, you can install it.
  - connect the phone to the computer
  - run `adb reboot bootloader` or turn off and then press `Volume Down` and `Power`
  - test that fastboot can access the phone run `fastboot devices`
  - flash the recovery: `fastboot flash recovery <patched_recovery_filename>.img
  - then we can turn the phone off and then use `Volume Down`+`Power` to come to the bootloader.
  - then choose the Recovery Mode and go into TRWP

Installing LineageOS

  - We will flash Lineage and then unpack the Lineage on the laptop and patch the boot.img. Then use fastboot to flash the boot on the newly installed Lineage.
  - in the recovery use the `Wipe` then use the `Format Data`.
  - the go back in teh recovery menu and in the `advanced Wipe` part, select *Cache and system* and then "swipe to wipe"
  - on the device go to `Advanced` then `ADB sideload` and swipe to start.
  - On the connected computer, run `adb sideload filename.zip`
  - to install additionnal packages, rune the `adb sideload file.zip` for each package.
    + for the google apps, this must be done before the first boot of lineage.
  - You can root the device at this stage by sideloading the `LineageOS AddonSu` for example.
  - Now on the laptop we will flash a patched version of the boot.img to avoid using the big cores:
    + unpack the lineage zip
    + run the patching script on the boot.img found in the unzipped lineage directory
    + to use the fastboot command, we need to restart the phone into fastboot.
    + send the patched boot.img on the phone (before the first reboot of the phone) by running:
      `fastboot flash boot patched_boot.img`
