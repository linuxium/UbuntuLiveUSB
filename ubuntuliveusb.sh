#!/bin/bash

# Linuxium's scripts to create a multiboot Ubuntu LiveUSB

source include-chroot-variables.txt

[ $# != 1 ] || [ ${1:0:5} != "/dev/" ] || [[ `echo ${#1}` < 6 ]] && echo "Usage: $0 /dev/<usb device>" && exit
USB_DEVICE=$1
VALID_USB=false
FOUND_USB_DEVICES=`for USB in /dev/disk/by-id/usb*; do readlink -f ${USB}; done | grep -v [0-9]`
for USB in ${FOUND_USB_DEVICES}; do
        if [ "${USB_DEVICE}" == "${USB}" ]; then
                VALID_USB=true
                break
        fi
done
if ( ! ${VALID_USB} ); then
        echo "Invalid USB '${USB_DEVICE}' ... exiting." && exit
fi

[ ! -f ${PATH_TO}/ubuntu-16.10-desktop-amd64.iso ] && echo "Using ubuntu-16.10-desktop-amd64.iso from Downnloads." && cp ~/Downloads/ubuntu-16.10-desktop-amd64.iso ${PATH_TO}/

echo "Creating a multiboot Ubuntu liveUSB on '${USB_DEVICE}' ..."
sleep 5

# wiping USB
sudo umount ${USB_DEVICE}*
sudo sgdisk -Z ${USB_DEVICE}

# formatting USB
(echo n; echo p; echo 1; echo; echo; echo a; echo 1; echo t; echo c; echo w) | sudo fdisk ${USB_DEVICE}
sudo mkfs.vfat -F 32 -n ULIVEUSB ${USB_DEVICE}1

# mounting USB and adding GRUB to USB
[ -f mnt ] && rm -f mnt
[ -d mnt ] || mkdir mnt
sudo mount ${USB_DEVICE}1 mnt
sudo cp -rf usb_partition/* mnt/

# copying Canonical ISO to USB
echo -n "Copying Canonical ISO to USB ... "
sudo cp ${PATH_TO}/${CANONICAL_ISO} mnt/
echo

# copying Linuxium ISO to USB
echo -n "Copying Linuxium ISO to USB ... "
sudo cp ${LINUXIUM_ISO} mnt/
echo

# updating GRUB menu on USB
cat usb_partition/boot/grub/grub.cfg | sed "s/CANONICAL_ISO/${CANONICAL_ISO}/" | sed "s/LINUXIUM_ISO/${LINUXIUM_ISO}/" | sudo tee mnt/boot/grub/grub.cfg > /dev/null

# unmounting USB
echo -n "Syncing USB ... "
sudo sync
sudo sync
echo
sudo umount mnt
rmdir mnt

rm ${PATH_TO}/ubuntu-16.10-desktop-amd64.iso

echo "Multiboot Ubuntu liveUSB created."
