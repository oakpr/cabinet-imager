#!/bin/bash
echo unblocking wifi
rfkill unblock all
echo "Waiting for network..."
until ping -c1 1.1.1.1; do
	sleep 10s
done
echo "Installing software"
apt-get update
apt-get install -y chromium xserver-xorg php-cli
echo "Waiting for opc user to exist, then copying ssh keys..."
until mkdir /home/opc/.ssh; do
	sleep 5s;
done
cp /app/authorized_keys /home/opc/.ssh/authorized_keys
systemctl enable --now kiosk
systemctl disable cabinet-first-boot