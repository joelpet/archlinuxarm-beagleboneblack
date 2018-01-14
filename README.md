# Arch Linux ARM on BeagleBone Black

## Usage

Follow the general installation instructions for [Arch Linux ARM on BeagleBone
Black](https://archlinuxarm.org/platforms/armv7/ti/beaglebone-black), but
instead of taking the "SD Card Creation" steps, do:

- Obtain a copy of the [latest Arch Linux ARM rootfs
  tarball](http://os.archlinuxarm.org/os/ArchLinuxARM-am33x-latest.tar.gz)
- Determine what device corresponds to the SD card you want to flash
- Run `./flash.sh /dev/path/to/sd/card /path/to/ArchLinuxARM-am33x-latest.tar.gz`

A copy of this script will be placed on the SD card together with the specified
rootfs tarball, so instead of following the "Installing to eMMC" steps, do:

```bash
su
cd
./flash.sh /dev/mmcblk1 ArchLinuxARM-am33x-latest.tar.gz
poweroff
```
