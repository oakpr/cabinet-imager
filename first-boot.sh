#!/bin/bash
echo "Waiting for opc user to exist, then copying ssh keys..."
until mkdir /home/opc/.ssh; do
	sleep 5s;
done
cp /app/authorized_keys /home/opc/.ssh/authorized_keys
hostnamectl set-hostname $(cat /app/hostname)
echo "Unblocking Wi-Fi"
rfkill unblock all
echo "Waiting for network..."
until ping -c1 1.1.1.1; do
	sleep 10s
done
echo "Installing software"
apt-get update
apt-get install -y chromium-browser xserver-xorg php-cli
systemctl enable kiosk
systemctl disable cabinet-first-boot
systemctl reboot