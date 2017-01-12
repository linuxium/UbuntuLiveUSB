#!/bin/bash

# Linuxium's scripts to create a custom Ubuntu ISO

source /include-chroot-variables.txt

CHROOT_KERNEL=`dpkg -l | awk '/^ii +linux-image-[0-9]/ {print $2}'`
CHROOT_KERNEL_VERSION=${CHROOT_KERNEL#linux-image-}

echo "fetching experimental-codecs kernel"

# get kernel source and build experimental-codecs
cd /usr/src
wget https://github.com/plbossart/sound/archive/experimental/codecs.zip
unzip -q codecs.zip
rm codecs.zip
cd sound-experimental-codecs
cp -a ../aufs4-standalone.git/{Documentation,fs} .
cp ../aufs4-standalone.git/include/uapi/linux/aufs_type.h include/uapi/linux/
patch -p1 < ../aufs4-standalone.git/aufs4-kbuild.patch 
patch -p1 < ../aufs4-standalone.git/aufs4-base.patch 
patch -p1 < ../aufs4-standalone.git/aufs4-mmap.patch 
patch -p1 < ../aufs4-standalone.git/aufs4-standalone.patch 
sed 's/CONFIG_CPU_FREQ_GOV_SCHEDUTIL=m/CONFIG_CPU_FREQ_GOV_SCHEDUTIL=y/' /boot/config-${CHROOT_KERNEL_VERSION} > .config
scripts/kconfig/merge_config.sh .config /defconfig

# build debs
make -j `getconf _NPROCESSORS_ONLN` bindeb-pkg LOCALVERSION=-experimental-codecs
