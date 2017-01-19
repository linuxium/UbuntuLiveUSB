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
# DEBUG: BEGIN copy previously downloaded aufs support to reduce internet data usage during testing
if [ ! -d kernel_sources/aufs4-standalone.git ]; then
# DEBUG: END copy previously downloaded aufs support to reduce internet data usage during testing
cd kernel_sources
git clone git://github.com/sfjro/aufs4-standalone.git aufs4-standalone.git
cd aufs4-standalone.git
git checkout origin/aufs4.9
cd ../..
# DEBUG: BEGIN copy previously downloaded aufs support to reduce internet data usage during testing
fi
# DEBUG: END copy previously downloaded aufs support to reduce internet data usage during testing
sudo cp -a kernel_sources/aufs4-standalone.git development-chroot/usr/src

# copy kernel definitions to development chroot
for KERNEL in ${LINUXIUM_KERNELS}
do
	sudo cp kernel_sources/${KERNEL}_kernel.source development-chroot/usr/src
	# DEBUG: BEGIN copy previously downloaded kernel sources to reduce internet data usage during testing
	case "${KERNEL}" in
		"mainline")
			if [ -d kernel_sources/linux-${MAINLINE_KERNEL_VERSION} ]; then
				sudo cp -a kernel_sources/linux-${MAINLINE_KERNEL_VERSION} development-chroot/usr/src
				if [ ! -f development-chroot/usr/src/linux-${MAINLINE_KERNEL_VERSION}/REPORTING-BUGS ]; then
					sudo cp include/REPORTING-BUGS development-chroot/usr/src/linux-${MAINLINE_KERNEL_VERSION}
				fi
			fi
			;;
		"stable")
			if [ -d kernel_sources/linux-${STABLE_KERNEL_VERSION} ]; then
				sudo cp -a kernel_sources/linux-${STABLE_KERNEL_VERSION} development-chroot/usr/src
				if [ ! -f development-chroot/usr/src/linux-${STABLE_KERNEL_VERSION}/REPORTING-BUGS ]; then
					sudo cp include/REPORTING-BUGS development-chroot/usr/src/linux-${STABLE_KERNEL_VERSION}
				fi
			fi
			;;
		"drm-intel-nightly")
			if [ -d kernel_sources/drm-intel ]; then
				sudo cp -a kernel_sources/drm-intel development-chroot/usr/src
				if [ ! -f development-chroot/usr/src/drm-intel/REPORTING-BUGS ]; then
					sudo cp include/REPORTING-BUGS development-chroot/usr/src/drm-intel
				fi
			fi
			;;
		"asoc-for-next")
			if [ -d kernel_sources/asoc-sound ]; then
				sudo cp -a kernel_sources/asoc-sound development-chroot/usr/src
				if [ ! -f development-chroot/usr/src/asoc-sound/REPORTING-BUGS ]; then
					sudo cp include/REPORTING-BUGS development-chroot/usr/src/asoc-sound
				fi
			fi
			;;
		"alsa-for-next")
			if [ -d kernel_sources/alsa-sound ]; then
				sudo cp -a kernel_sources/alsa-sound development-chroot/usr/src
				if [ ! -f development-chroot/usr/src/alsa-sound/REPORTING-BUGS ]; then
					sudo cp include/REPORTING-BUGS development-chroot/usr/src/alsa-sound
				fi
			fi
			;;
		"intel-audio-fixes")
			if [ -d kernel_sources/sound-topic-v4.9-fixes ]; then
				sudo cp -a kernel_sources/sound-topic-v4.9-fixes development-chroot/usr/src
				if [ ! -f development-chroot/usr/src/sound-topic-v4.9-fixes/REPORTING-BUGS ]; then
					sudo cp include/REPORTING-BUGS development-chroot/usr/src/sound-topic-v4.9-fixes
				fi
			fi
			;;
		"experimental-codecs")
			if [ -d kernel_sources/sound-experimental-codecs ]; then
				sudo cp -a kernel_sources/sound-experimental-codecs development-chroot/usr/src
				if [ ! -f development-chroot/usr/src/sound-experimental-codecs/REPORTING-BUGS ]; then
					sudo cp include/REPORTING-BUGS development-chroot/usr/src/sound-experimental-codecs
				fi
			fi
			;;
	esac
	# DEBUG: END copy previously downloaded kernel sources to reduce internet data usage during testing
done

