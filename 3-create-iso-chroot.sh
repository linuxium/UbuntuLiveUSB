#!/bin/bash

# Linuxium's scripts to create a custom Ubuntu ISO

source chroot-variables.txt

# mount Ubuntu ISO
[ -f mnt ] && rm -f mnt
[ -d mnt ] || mkdir mnt
sudo mount -o loop ${PATH_TO}/${CANONICAL_ISO} mnt 2> /dev/null

# extract iso directory structure from ISO
sudo rm -rf iso-directory-structure
sudo rsync --exclude=/casper/filesystem.squashfs -a mnt/ iso-directory-structure

# extract iso chroot file system from ISO
sudo rm -rf squashfs-root iso-chroot
sudo unsquashfs mnt/casper/filesystem.squashfs
sudo mv squashfs-root iso-chroot

# unmount Ubuntu ISO
sudo umount mnt
rmdir mnt

