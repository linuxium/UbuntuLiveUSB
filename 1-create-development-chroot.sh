#!/bin/bash

# Linuxium's scripts to create a custom Ubuntu ISO

source include-chroot-variables.txt

# mount Ubuntu ISO
[ -f mnt ] && rm -f mnt
[ -d mnt ] || mkdir mnt
sudo mount -o loop ${PATH_TO}/${CANONICAL_ISO} mnt 2> /dev/null

# extract development chroot file system from ISO
sudo rm -rf squashfs-root development-chroot
sudo unsquashfs mnt/casper/filesystem.squashfs
mv squashfs-root development-chroot

# unmount Ubuntu ISO
sudo umount mnt
rmdir mnt

# configure networking inside development chroot
sudo cp /etc/resolv.conf development-chroot/etc/

# configure sources and kernel config inside development chroot
sudo cp ${PATH_TO}/sources.list development-chroot/etc/apt/
sudo cp ${PATH_TO}/defconfig development-chroot/

# copy chroot scripts to development chroot
sudo cp 2a-start-compile-linux.source development-chroot
sudo cp 2b-finish-compile-linux.source development-chroot
sudo cp include-chroot-variables.txt development-chroot

# copy additional kernel compilation commands to development chroot
sudo cp *-kernel.sh development-chroot

