This repo contains scripts for imaging an Oakton arcade cabinet. To use:

* Fill `./wpa_supplicant.conf`
* Fill `./authorized_keys`
* Fill `./hostname`
* Change the Pi image URL in `image.sh` if you want to use a different image, but make sure it's kinda Raspbian-like so the script doesn't get confused...
* Insert your SD card, take note of its device name (like `/dev/sdd`, not `/dev/sdd1`). Consider `/dev/sdcard` to mean your sd card's name.
* `sudo umount /dev/sdcard*`
* `sudo bash image.sh /dev/sdcard` - This script will give you two chances to cancel if you accidentally pointed it at the wrong drive.
* Eject the SD card and put it in a Pi.
* Be patient - the Pi is downloading everything it needs in the background.
* Eventually, the kiosk view will appear.
* Enable unattended updates or ssh in every once in a while to update the system.