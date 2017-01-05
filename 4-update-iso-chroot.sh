#!/bin/bash

# Linuxium's scripts to create a custom Ubuntu ISO

source include-chroot-variables.txt

# copy new kernel debs
sudo cp development-chroot/usr/src/linux-headers-${LINUXIUM_KERNEL_RELEASE}-${LINUXIUM_KERNEL_VERSION}_${LINUXIUM_KERNEL_RELEASE}-${LINUXIUM_KERNEL_VERSION}-1_amd64.deb iso-chroot/usr/src/
sudo cp development-chroot/usr/src/linux-image-${LINUXIUM_KERNEL_RELEASE}-${LINUXIUM_KERNEL_VERSION}_${LINUXIUM_KERNEL_RELEASE}-${LINUXIUM_KERNEL_VERSION}-1_amd64.deb iso-chroot/usr/src/

# add in UCM files for sound
sudo mkdir -p iso-chroot/usr/share/alsa/ucm
sudo cp -rf ${PATH_TO}/UCM-master/* iso-chroot/usr/share/alsa/ucm

# install new kernel debs and additional packages
sudo mv iso-chroot/etc/apt/sources.list iso-chroot/etc/apt/sources.list.orig
sudo cp ${PATH_TO}/sources.list iso-chroot/etc/apt/
sudo cp /etc/resolv.conf iso-chroot/etc/
sudo mount --bind /dev/ iso-chroot/dev
sudo chroot iso-chroot <<+
mount -t proc none /proc
mount -t sysfs none /sys
mount -t devpts none /dev/pts
export HOME=/root
export LC_ALL=C
dbus-uuidgen > /var/lib/dbus/machine-id
dpkg-divert --local --rename --add /sbin/initctl
ln -s /bin/true /sbin/initctl

dpkg -i /usr/src/linux*.deb 

apt-get update && apt-get -y upgrade

apt-get -y install emacs audacity
apt-get -y install acpica-tools uuid-dev uuid-dev nasm
apt-get -y install git git-email gitk sshpass openssh-server

apt-get clean
apt-get autoclean
apt-get -y autoremove

rm /var/lib/dbus/machine-id
rm /sbin/initctl
dpkg-divert --rename --remove /sbin/initctl

umount /proc || umount -lf /proc
umount /sys
umount /dev/pts
+
sudo umount iso-chroot/dev
sudo mv iso-chroot/etc/apt/sources.list.orig iso-chroot/etc/apt/sources.list
sudo echo -n | sudo tee iso-chroot/etc/resolv.conf > /dev/null
sudo rm -rf iso-chroot/root/.bash_history
sudo rm -rf iso-chroot/run/blkid
sudo rm -rf iso-chroot/run/lock/dmraid
sudo rm -rf iso-chroot/run/lvm/.cache
sudo rm -rf iso-chroot/boot/grub/grub.cfg
sudo rm -rf iso-chroot/etc/mtab
sudo rm -rf iso-chroot/var/lib/dpkg/status-old
sudo rm -rf iso-chroot/dev
sudo rm -rf iso-chroot/run
sudo mkdir iso-chroot/dev
sudo mkdir iso-chroot/run

# update kernel in iso
sudo cp iso-chroot/boot/vmlinuz-${LINUXIUM_KERNEL_RELEASE}-${LINUXIUM_KERNEL_VERSION} iso-directory-structure/casper/vmlinuz.efi
sudo cp iso-chroot/boot/initrd.img-${LINUXIUM_KERNEL_RELEASE}-${LINUXIUM_KERNEL_VERSION} iso-directory-structure/casper/initrd.lz

# unpack initramfs
[ -d initrd ] && rm -rf initrd
mkdir initrd
cd initrd
sudo dd status=none if=../iso-directory-structure/casper/initrd.lz | gzip -d | sudo cpio -id

# add in UCM files for sound in initramfs
sudo mkdir -p usr/share/alsa/ucm
sudo cp -rf ${PATH_TO}/UCM-master/* usr/share/alsa/ucm

# repack initramfs
sudo rm -f ../iso-directory-structure/casper/initrd.lz
sudo find | sudo cpio -o -H newc | gzip | sudo tee ../iso-directory-structure/casper/initrd.lz > /dev/null
cd ..
sudo rm -rf initrd

