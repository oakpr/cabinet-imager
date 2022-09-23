#!/bin/bash

# Read the target device
TARGET="$1"
SIZE=$(lsblk -bno SIZE $TARGET | head -1)

if mount | grep $TARGET > /dev/null; then
	echo "THE TARGET DEVICE IS MOUNTED!!! Exiting because it's probably not what you're trying to image..."
	exit 1
fi

echo "I'm going to DESTROY ALL OF THE DATA ON $TARGET... I'll wait 10 seconds, this is your last chance to cancel with Ctrl+C.";
sleep 10s
echo "OK, if you're sure, let's get to work..."
if [ ! -f pi.img ]; then
	if [ ! -f pi.img.xz ]; then
		echo "Downloading RasPiOS image..."
		wget -O pi.img.xz https://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2022-09-07/2022-09-06-raspios-bullseye-armhf-lite.img.xz
	fi
	echo "Decompressing RasPiOS image..."
	unxz -d pi.img.xz
fi
echo "I'M ABOUT TO DO IT!!! This is the step that *will* destroy your data if you pointed me at the wrong drive!!!"
sleep 10s
echo "Ok, commencing data destruction... Please input your sudo password if prompted..."
pv pi.img > $TARGET
partprobe

sleep 10s

umount $TARGET*
echo "Let's hope you didn't have anything important on there..."
echo "Creating temporary dirs"
mkdir -p /tmp/cabinet-imager$TARGET/{rootfs,boot}
mount "${TARGET}2" /tmp/cabinet-imager$TARGET/rootfs
mount "${TARGET}1" /tmp/cabinet-imager$TARGET/boot
touch /tmp/cabinet-imager/$TARGET/boot/ssh
echo "Copying first-boot systemd service into place"
cp ./cabinet-first-boot.service /tmp/cabinet-imager$TARGET/rootfs/etc/systemd/system/cabinet-first-boot.service
echo "Enabling first-boot systemd service"
ln -s /tmp/cabinet-imager$TARGET/rootfs/etc/systemd/system/cabinet-first-boot.service /tmp/cabinet-imager$TARGET/rootfs/etc/systemd/system/multi-user.target.wants/cabinet-first-boot.service
echo "Copying scripts into place"
mkdir -p /tmp/cabinet-imager$TARGET/rootfs/app
cp {first-boot,mk-games,go,chromium-kiosk}.sh /tmp/cabinet-imager$TARGET/rootfs/app
echo "Setting permissions"
chmod 777 /tmp/cabinet-imager$TARGET/rootfs/app
chmod +rx /tmp/cabinet-imager$TARGET/rootfs/app/*.sh
echo "Adding crontab jobs"
echo "0 0 * * * /app/mk-games.sh" >> /tmp/cabinet-imager$TARGET/rootfs/etc/crontab
echo "Disabling first-boot configuration"
echo 'opc:$6$wWHtDsSg$mwjJQs4bNizC0fbc9VybaCNRF6OEPQkpwnIZIHGjYq7uKeSYEBnqM3G2lpUGqTr37TaW6S//yoNvHr.HtGjJX1' > /tmp/cabinet-imager$TARGET/boot/userconf.txt
echo "Writing ssh keys"
touch authorized_keys
cp authorized_keys /tmp/cabinet-imager$TARGET/rootfs/app/authorized_keys
echo "Disabling password authentication"
echo "PasswordAuthentication no" >> /tmp/cabinet-imager$TARGET/rootfs/etc/ssh/sshd_config
echo "Writing wpa_supplicant"
touch wpa_supplicant.conf
cp wpa_supplicant.conf /tmp/cabinet-imager$TARGET/rootfs/etc/wpa_supplicant/wpa_supplicant.conf
echo "Writing kiosk service"
cp kiosk.service /tmp/cabinet-imager$TARGET/rootfs/etc/systemd/system/kiosk.service
echo "Sync to disk"
sync
echo "Unmounting"
umount $TARGET*
echo "Done!!!"