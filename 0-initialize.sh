#!/bin/bash

# Linuxium's scripts to create a custom Ubuntu ISO or multiboot Ubuntu LiveUSB

# initialize sudo
sudo echo -n

# copy files used by scripts to location defined by chroot-variables.txt
[ ! -f /tmp/ubuntu-16.10-desktop-amd64.iso ] && echo "Using ubuntu-16.10-desktop-amd64.iso from Downloads." && cp ~/Downloads/ubuntu-16.10-desktop-amd64.iso /tmp
[ ! -f /tmp/sources.list ] && echo "Using sources.list from git." && cp include/sources.list /tmp
[ ! -f /tmp/defconfig ] && echo "Using defconfig from git." && cp include/defconfig /tmp
[ ! -f /tmp/efi_img_bootia32.efi ] && echo "Using efi_img_bootia32.efi from git." && cp include/efi_img_bootia32.efi /tmp
[ ! -f /tmp/efi_boot_bootia32.efi ] && echo "Using efi_boot_bootia32.efi from git." && cp include/efi_boot_bootia32.efi /tmp
[ ! -d /tmp/UCM-master ] && echo "Fetching UCM files." && wget https://github.com/plbossart/UCM/archive/master.zip -O /tmp/master.zip && unzip -d /tmp /tmp/master.zip && rm /tmp/master.zip
[ ! -f /tmp/finger_banner ] && echo "Fetching kernel.org banner." && wget https://www.kernel.org/finger_banner -O /tmp/finger_banner

