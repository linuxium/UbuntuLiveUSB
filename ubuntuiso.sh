#!/bin/bash

# Linuxium's scripts to create a custom Ubuntu ISO

source chroot-variables.txt

[ ! -f ${PATH_TO}/ubuntu-16.10-desktop-amd64.iso ] && echo "Using ubuntu-16.10-desktop-amd64.iso from Downloads." && cp ~/Downloads/ubuntu-16.10-desktop-amd64.iso ${PATH_TO}/
[ ! -f ${PATH_TO}/sources.list ] && echo "Using sources.list from git." && cp include/sources.list ${PATH_TO}/
[ ! -f ${PATH_TO}/defconfig ] && echo "Using defconfig from git." && cp include/defconfig ${PATH_TO}/
[ ! -f ${PATH_TO}/efi_img_bootia32.efi ] && echo "Using efi_img_bootia32.efi from git." && cp include/efi_img_bootia32.efi ${PATH_TO}/
[ ! -f ${PATH_TO}/efi_boot_bootia32.efi ] && echo "Using efi_boot_bootia32.efi from git." && cp include/efi_boot_bootia32.efi ${PATH_TO}/
[ ! -d ${PATH_TO}/UCM-master ] && echo "Fetching UCM files." && wget https://github.com/plbossart/UCM/archive/master.zip -O ${PATH_TO}/master.zip && unzip -d ${PATH_TO} ${PATH_TO}/master.zip && rm ${PATH_TO}/master.zip
[ ! -f ${PATH_TO}/finger_banner ] && echo "Fetching kernel.org banner." && wget https://www.kernel.org/finger_banner -O ${PATH_TO}/finger_banner

MAINLINE_KERNEL_VERSION=$(cat ${PATH_TO}/finger_banner | grep -m 1 "mainline" ${PATH_TO}/finger_banner | sed 's/.*:[ ]*//')
STABLE_KERNEL_VERSION=$(cat ${PATH_TO}/finger_banner | grep -m 1 "stable" ${PATH_TO}/finger_banner | sed 's/.*:[ ]*//')

./1-create-development-chroot.sh
./2-compile-development-chroot.sh
./3-create-iso-chroot.sh
./4-update-iso-chroot.sh
./5-make-iso.sh

sudo rm -rf development-chroot/
sudo rm -rf iso-chroot/
sudo rm -rf iso-directory-structure/
sudo rm -rf deb_binaries/*.deb

rm ${PATH_TO}/ubuntu-16.10-desktop-amd64.iso
rm ${PATH_TO}/sources.list
rm ${PATH_TO}/defconfig
rm ${PATH_TO}/efi_img_bootia32.efi
rm ${PATH_TO}/efi_boot_bootia32.efi
rm -rf ${PATH_TO}/UCM-master/
rm ${PATH_TO}/finger_banner

