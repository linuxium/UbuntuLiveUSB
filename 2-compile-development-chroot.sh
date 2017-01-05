#!/bin/bash

# Linuxium's scripts to create a custom Ubuntu ISO

CHROOT_ENVIRONMENT="development-chroot"
[ ! -d ${CHROOT_ENVIRONMENT} ] && echo "Chroot environment '${CHROOT_ENVIRONMENT}' not found ... exiting." && exit

# enter chroot
sudo mount --bind /dev/ ${CHROOT_ENVIRONMENT}/dev
sudo chroot ${CHROOT_ENVIRONMENT} <<+
source /2a-start-compile-linux.source
source /2b-finish-compile-linux.source
+

# exit chroot
sudo umount ${CHROOT_ENVIRONMENT}/dev

