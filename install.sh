#!/bin/bash

# check for root
if [ "$EUID" -ne 0 ]; then
	echo "This script must be run as root"
	exit 1
fi

# update the machine
upgradeSys() {
	apt-get update && apt-get full-upgrade -y
	apt-get autoclean -y
	apt-get autopurge -y
}

# install required packages
installReq() {
	apt-get update && xargs apt-get install -y < tobeinstalled.txt
	apt-get autopurge -y
}

# Set custom resolution
setResolution() {
	# Define GRUB settings
	GRUB_GFXMODE="1024x768x32"
	GRUB_GFXPAYLOAD_LINUX="keep"
	GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"

	# Check if GRUB configuration file exists
	GRUB_CONFIG="/etc/default/grub"
	if [ -f "$GRUB_CONFIG" ]; then

    # Update the GRUB settings in the configuration file
	sed -i "/^#*GRUB_GFXMODE=/ s/.*/GRUB_GFXMODE=\"$GRUB_GFXMODE\"/" "$GRUB_CONFIG"
	sed -i "/^#*GRUB_GFXMODE=/ s/.*/&\nGRUB_GFXPAYLOAD_LINUX=\"$GRUB_GFXPAYLOAD_LINUX\"/" "$GRUB_CONFIG"
	sed -i "/^#*GRUB_CMDLINE_LINUX_DEFAULT=/ s/.*/GRUB_CMDLINE_LINUX_DEFAULT=\"$GRUB_CMDLINE_LINUX_DEFAULT\"/" "$GRUB_CONFIG"

    # Update GRUB
	update-initramfs -u
    update-grub

    echo "GRUB configuration updated successfully."
	else
		echo "GRUB configuration file not found."
		exit 1
	fi

	cp -b --suffix=.bak "assets/10-monitor_120hz_refresh.conf" "/etc/X11/xorg.conf.d/"
}

setLoginDM() {
	cp -b --suffix=.bak "assets/lightdm-gtk-greeter.conf" "/etc/lightdm/"
}

changePanelIconSize() {
	xfconf-query -c xfce4-panel -p /panels/panel-1/icon-size -s 25
}