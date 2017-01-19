#!/bin/bash

# Linuxium's scripts to create a custom Ubuntu ISO

CHROOT_ENVIRONMENT="development-chroot"
[ ! -d ${CHROOT_ENVIRONMENT} ] && echo "Chroot environment '${CHROOT_ENVIRONMENT}' not found ... exiting." && exit

# enter chroot
sudo mount --bind /dev/ ${CHROOT_ENVIRONMENT}/dev
sudo chroot ${CHROOT_ENVIRONMENT} <<+
source /usr/src/2a-start-compile-linux.source
source /usr/src/2b-finish-compile-linux.source
+

# exit chroot
sudo umount ${CHROOT_ENVIRONMENT}/dev

# save binary debs
cp ${CHROOT_ENVIRONMENT}/usr/src/*.deb deb_binaries/

