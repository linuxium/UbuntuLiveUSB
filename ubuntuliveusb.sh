#!/bin/bash

# Linuxium's scripts to create a multiboot Ubuntu LiveUSB

source include-chroot-variables.txt

[ ! -f ${PATH_TO}/${CANONICAL_ISO} ] && echo "ISO file '${PATH_TO}/${CANONICAL_ISO}' not found ... exiting." && exit
[ ! -f ${PATH_TO}/${LINUXIUM_ISO} ] && echo "ISO file '${PATH_TO}/${LINUXIUM_ISO}' not found ... exiting." && exit

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

echo "Creating a multiboot Ubuntu liveUSB on '${USB_DEVICE}' ..."
sleep 5

# wiping USB
sudo umount ${USB_DEVICE}* 2> /dev/null
sudo sgdisk -Z ${USB_DEVICE} > /dev/null 2>&1

# formatting USB
(echo n; echo p; echo 1; echo; echo; echo a; echo 1; echo t; echo c; echo w) | sudo fdisk ${USB_DEVICE} > /dev/null 2>&1
sudo mkfs.vfat -F 32 -n ULIVEUSB ${USB_DEVICE}1 > /dev/null

# mounting USB and adding GRUB to USB
[ -f mnt_usb ] && rm -f mnt_usb
[ -d mnt_usb ] || mkdir mnt_usb
sudo mount ${USB_DEVICE}1 mnt_usb
sudo cp -rf usb_partition/* mnt_usb/

function copy_ISO_to_USB
{
	ISO="$1"
	echo -n "Copying $ISO to USB ... "
	sudo cp ${PATH_TO}/${ISO} mnt_usb/
	sudo mkdir -p mnt_usb/boot/${ISO}
	[ -f mnt_iso ] && rm -f mnt_iso
	mkdir mnt_iso
	[ -f mnt_squashfs ] && rm -f mnt_squashfs
	mkdir mnt_squashfs
	sudo mount ${PATH_TO}/${ISO} mnt_iso 2> /dev/null
	sudo mount mnt_iso/casper/filesystem.squashfs mnt_squashfs
	if [ `ls mnt_squashfs/boot/vmlinuz* 2> /dev/null | wc -l` -gt 0 ] ; then 
		sudo cp mnt_squashfs/boot/vmlinuz* mnt_usb/boot/${ISO}/ 2> /dev/null
		sudo cp mnt_squashfs/boot/initrd.img* mnt_usb/boot/${ISO}/ 2> /dev/null
	else
		sudo cp mnt_iso/casper/vmlinuz.efi mnt_usb/boot/${ISO}/vmlinuz.efi
		sudo cp mnt_iso/casper/initrd.lz mnt_usb/boot/${ISO}/initrd.lz
	fi
	sudo umount mnt_squashfs && rmdir mnt_squashfs
	sudo umount mnt_iso && rmdir mnt_iso
	echo
}

# copying Canonical ISO to USB
copy_ISO_to_USB ${CANONICAL_ISO}

# copying Linuxium ISO to USB
copy_ISO_to_USB ${LINUXIUM_ISO}

# updating GRUB menu on USB
cat <<+ | sudo tee mnt_usb/boot/grub/grub.cfg > /dev/null
if loadfont /boot/grub/font.pf2 ; then
	set gfxmode=auto
	insmod efi_gop
	insmod efi_uga
	insmod gfxterm
	terminal_output gfxterm
fi

set menu_color_normal=white/black
set menu_color_highlight=black/light-gray

+
for ISO_PATH in mnt_usb/boot/*
do
	ISO=${ISO_PATH#mnt_usb/boot/}
	if [ "${ISO}" = "grub" ]; then continue; fi
	ISO_NAME=${ISO%.iso}
	echo "Adding GRUB entries for ISO ${ISO_NAME} to USB ..."
	for KERNEL_PATH in ${ISO_PATH}/vmlinuz*
	do
		KERNEL=${KERNEL_PATH#$ISO_PATH/}
		sudo bash -c "echo -n 'menuentry \"Try kernel ' >> mnt_usb/boot/grub/grub.cfg"
		sudo bash -c "echo -n ${KERNEL} >> mnt_usb/boot/grub/grub.cfg"
		sudo bash -c "echo -n ' from ' >> mnt_usb/boot/grub/grub.cfg"
		sudo bash -c "echo -n ${ISO_NAME} >> mnt_usb/boot/grub/grub.cfg"
		sudo bash -c "echo ' ISO without installing\" {' >> mnt_usb/boot/grub/grub.cfg"
		sudo bash -c "echo -ne '\tset ISO_FILE=\"/' >> mnt_usb/boot/grub/grub.cfg"
		sudo bash -c "echo -n ${ISO} >> mnt_usb/boot/grub/grub.cfg"
		sudo bash -c "echo '\"' >> mnt_usb/boot/grub/grub.cfg"
		sudo bash -c "echo -e '\tset gfxpayload=keep' >> mnt_usb/boot/grub/grub.cfg"
		sudo bash -c "echo -e '\tloopback loop \${ISO_FILE}' >> mnt_usb/boot/grub/grub.cfg"
		sudo bash -c "echo -ne '\tlinux   /boot/' >> mnt_usb/boot/grub/grub.cfg"
		sudo bash -c "echo -n ${ISO} >> mnt_usb/boot/grub/grub.cfg"
		sudo bash -c "echo -n '/' >> mnt_usb/boot/grub/grub.cfg"
		sudo bash -c "echo -n ${KERNEL} >> mnt_usb/boot/grub/grub.cfg"
		sudo bash -c "echo ' iso-scan/filename=\${ISO_FILE} file=/cdrom/preseed/ubuntu.seed boot=casper quiet splash ---' >> mnt_usb/boot/grub/grub.cfg"
		sudo bash -c "echo -ne '\tinitrd  /boot/' >> mnt_usb/boot/grub/grub.cfg"
		sudo bash -c "echo -n ${ISO} >> mnt_usb/boot/grub/grub.cfg"
		sudo bash -c "echo -n '/' >> mnt_usb/boot/grub/grub.cfg"
		KERNEL_VERSION=${KERNEL#vmlinuz-}
		if [ "${KERNEL}" = "vmlinuz.efi" ]; then
			INITRD=initrd.lz
		else
			INITRD=initrd.img-${KERNEL_VERSION}
		fi
		sudo bash -c "echo ${INITRD} >> mnt_usb/boot/grub/grub.cfg"
		sudo bash -c "echo '}' >> mnt_usb/boot/grub/grub.cfg"
		sudo bash -c "echo >> mnt_usb/boot/grub/grub.cfg"
	done
done

# unmounting USB
echo -n "Syncing USB ... "
sudo sync
sudo sync
echo
sudo umount mnt_usb
rmdir mnt_usb

echo "Multiboot Ubuntu liveUSB created."
