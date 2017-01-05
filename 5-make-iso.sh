#!/bin/bash

# Linuxium's scripts to create a custom Ubuntu ISO

source include-chroot-variables.txt

# add 32-bit bootloader
mkdir mnt
sudo mount iso-directory-structure/boot/grub/efi.img mnt
sudo cp -a mnt/efi .
sudo umount mnt
sudo rm iso-directory-structure/boot/grub/efi.img
sudo dd if=/dev/zero of=iso-directory-structure/boot/grub/efi.img bs=1 count=3091968
sudo mkdosfs iso-directory-structure/boot/grub/efi.img
sudo mount iso-directory-structure/boot/grub/efi.img mnt
sudo cp -a efi mnt
sudo cp ${PATH_TO}/efi_img_bootia32.efi mnt/efi/boot/bootia32.efi
sudo umount mnt
rmdir mnt
sudo rm -rf efi
sudo cp ${PATH_TO}/efi_boot_bootia32.efi iso-directory-structure/EFI/BOOT/bootia32.efi

# create the manifest
sudo chmod +w iso-directory-structure/casper/filesystem.manifest
sudo chroot iso-chroot dpkg-query -W --showformat='${Package} ${Version}\n' | sudo tee iso-directory-structure/casper/filesystem.manifest > /dev/null
sudo cp iso-directory-structure/casper/filesystem.manifest iso-directory-structure/casper/filesystem.manifest-desktop
sudo sed -i '/ubiquity/d' iso-directory-structure/casper/filesystem.manifest-desktop
sudo sed -i '/casper/d' iso-directory-structure/casper/filesystem.manifest-desktop

# create the filesystem
sudo mksquashfs iso-chroot iso-directory-structure/casper/filesystem.squashfs
printf $(sudo du -sx --block-size=1 iso-chroot | cut -f1) | sudo tee iso-directory-structure/casper/filesystem.size > /dev/null
cd iso-directory-structure
sudo rm md5sum.txt
find -type f -print0 | sudo xargs -0 md5sum | grep -v isolinux/boot.cat | sudo tee md5sum.txt > /dev/null
cd ..

# create the iso
sudo rm -f ${LINUXIUM_ISO}
rm -f isohdpfx.bin
dd if=${PATH_TO}/${CANONICAL_ISO} bs=512 count=1 of=isohdpfx.bin
cd iso-directory-structure
sudo xorriso -as mkisofs -iso-level 3 -full-iso9660-filenames -volid "${LINUXIUM_VOLID}" \
-isohybrid-mbr ../isohdpfx.bin \
-eltorito-boot isolinux/isolinux.bin -no-emul-boot -eltorito-catalog isolinux/boot.cat -no-emul-boot \
-boot-load-size 4 -boot-info-table -eltorito-alt-boot -e boot/grub/efi.img -no-emul-boot -isohybrid-gpt-basdat \
-o ../${LINUXIUM_ISO} .
cd ..
rm isohdpfx.bin
echo "ISO created as '${LINUXIUM_ISO}'."

