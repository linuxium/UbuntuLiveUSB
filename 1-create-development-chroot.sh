#!/bin/bash

# Linuxium's scripts to create a custom Ubuntu ISO

source chroot-variables.txt

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

# copy kernel.org banner to development chroot
sudo cp ${PATH_TO}/finger_banner development-chroot/${PATH_TO}/finger_banner

# configure networking inside development chroot
sudo cp /etc/resolv.conf development-chroot/etc/

# copy required files to development chroot
sudo cp chroot-variables.txt development-chroot/usr/src
sudo cp 2a-start-compile-linux.source development-chroot/usr/src
sudo cp 2b-finish-compile-linux.source development-chroot/usr/src
sudo cp include/aufs4-v4.10-fix1.patch development-chroot/usr/src
sudo cp include/aufs4-v4.10-fix2.patch development-chroot/usr/src
sudo cp ${PATH_TO}/sources.list development-chroot/etc/apt/
sudo cp ${PATH_TO}/defconfig development-chroot/usr/src
sudo cp include/REPORTING-BUGS development-chroot/usr/src

# add support for aufs
rm -rf kernel_sources/aufs4-standalone.git
cd kernel_sources
git clone git://github.com/sfjro/aufs4-standalone.git aufs4-standalone.git
cd aufs4-standalone.git
git checkout origin/aufs4.9
cd ../..
sudo cp -a kernel_sources/aufs4-standalone.git development-chroot/usr/src

# copy kernel definitions to development chroot
for KERNEL in ${LINUXIUM_KERNELS}
do
	sudo cp kernel_sources/${KERNEL}_kernel.source development-chroot/usr/src
done

