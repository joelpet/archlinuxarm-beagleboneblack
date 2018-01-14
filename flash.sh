#!/bin/bash

sd_dev="${1?Missing argument: Path to SD card device}"
alarm_rootfs_tgz="${2?Missing argument: Path to Arch Linux ARM root filesystem tarball}"

sd_dev_p1="${sd_dev}p1"

readonly E_ABORTED=1
readonly E_PARTITIONING_FAIL=2
readonly E_CREATE_FS_FAIL=3
readonly E_NO_TMP_DIR=4
readonly E_MOUNT_FAIL=5

trap cleanup INT TERM

function cleanup() {
    umount "${mount_target}"
    rmdir "${mount_target}"
}

function confirm_device() {
    echo "WARNING: All data on the following device will be destroyed:"
    fdisk --list "${sd_dev}"
    read -p "Continue? [y/N] " -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        return 0 # Continue
    else
        return 1 # Abort
    fi
}

function partition_device() {
    # Zero the beginning of the SD card
    dd if=/dev/zero of="${sd_dev}" bs=1M count=8

    # Run fdisk to partition the SD card
    echo "o
n




w

" | fdisk "${sd_dev}"

    if [[ "$?" -ne 0 ]]; then
        echo "Unable to partition device" >&2
        exit "${E_PARTITIONING_FAIL}"
    fi

    sync

    # Create the ext4 filesystem
    if ! mkfs.ext4 "${sd_dev_p1}" ; then
        echo "Unable to create filesystem" >&2
        exit "${E_CREATE_FS_FAIL}"
    fi
}

function install_alarm_on_device() {
    local partition="${sd_dev_p1}"
    mount_target="$(mktemp --directory --suffix=mnt_alarm_bbb)"

    if [[ "$?" -ne 0 ]]; then
        echo "Unable to create temporary mount target directory" >&2
        exit "${E_NO_TMP_DIR}"
    fi

    # Mount the filesystem
    if ! mount "${partition}" "${mount_target}" ; then
        echo "Unable to mount rootfs target" >&2
        exit "${E_MOUNT_FAIL}"
    fi

    # Extract root filesystem
    bsdtar -xpf "${alarm_rootfs_tgz}" -C "${mount_target}"
    sync

    # Prepare for installation to eMMC
    cp "${BASH_SOURCE[0]}" "${alarm_rootfs_tgz}" "${mount_target}/root/"

    # Install the U-Boot bootloader
    dd if="${mount_target}/boot/MLO" of="${sd_dev}" count=1 seek=1 conv=notrunc bs=128k
    dd if="${mount_target}/boot/u-boot.img" of="${sd_dev}" count=2 seek=1 conv=notrunc bs=384k

    cleanup
    sync
}

function main() {
    confirm_device || exit "${E_ABORTED}"
    partition_device
    install_alarm_on_device
}

main
