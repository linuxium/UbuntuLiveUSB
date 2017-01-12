#!/bin/bash

# Linuxium's scripts to create a custom Ubuntu ISO

source /include-chroot-variables.txt

CHROOT_KERNEL=`dpkg -l | awk '/^ii +linux-image-[0-9]/ {print $2}'`
CHROOT_KERNEL_VERSION=${CHROOT_KERNEL#linux-image-}

# get kernel source and build stable
cd /usr/src
wget https://www.kernel.org/finger_banner -O ${PATH_TO}/finger_banner
VERSION=$(head -1 ${PATH_TO}/finger_banner | awk -F':' '{print $2}' | sed 's/ //g')
echo "fetching mainline $VERSION"

wget https://cdn.kernel.org/pub/linux/kernel/v4.x/testing/linux-${VERSION}.tar.xz
tar xf linux-${VERSION}.tar.xz
rm linux-${VERSION}.tar.xz
cd linux-${VERSION}
cp -a ../aufs4-standalone.git/{Documentation,fs} .
cp ../aufs4-standalone.git/include/uapi/linux/aufs_type.h include/uapi/linux/
patch -p1 < ../aufs4-standalone.git/aufs4-kbuild.patch 
patch -p1 < ../aufs4-standalone.git/aufs4-base.patch 
patch -p1 < ../aufs4-standalone.git/aufs4-mmap.patch

# FIXME the previous patch fails on v4.10-rc3
#patch -p1 < ../aufs4-standalone.git/aufs4-standalone.patch
#sed 's/CONFIG_CPU_FREQ_GOV_SCHEDUTIL=m/CONFIG_CPU_FREQ_GOV_SCHEDUTIL=y/' /boot/config-${CHROOT_KERNEL_VERSION} > .config
#scripts/kconfig/merge_config.sh .config /defconfig

# build debs
#make -j `getconf _NPROCESSORS_ONLN` bindeb-pkg LOCALVERSION=-stable

