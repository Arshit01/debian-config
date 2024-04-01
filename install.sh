#!/bin/bash

# check for root
checkRoot() {
	if [ "$EUID" -eq 0 ]; then
		return 0
	else
		return 1
	fi
}

# update the machine
upgradeSys() {
	sudo apt-get update && apt-get full-upgrade -y
	sudo apt-get autoclean -y
	sudo apt-get autopurge -y
}

# install required packages
installReq() {
	sudo apt-get update && xargs apt-get install -y < tobeinstalled.txt
	sudo apt-get autopurge -y
}

# Set custom resolution
displayConfig() {
	# Define GRUB settings
	GRUB_GFXMODE="1152x864x32"
	GRUB_GFXPAYLOAD_LINUX="keep"
	GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"

	# Check if GRUB configuration file exists
	GRUB_CONFIG="/etc/default/grub"
	if [ -f "$GRUB_CONFIG" ]; then

	# Update the GRUB settings in the configuration file
	sudo sed -i "/^#*GRUB_GFXMODE=/ s/.*/GRUB_GFXMODE=\"$GRUB_GFXMODE\"/" "$GRUB_CONFIG"
	sudo sed -i "/^#*GRUB_CMDLINE_LINUX_DEFAULT=/ s/.*/GRUB_CMDLINE_LINUX_DEFAULT=\"$GRUB_CMDLINE_LINUX_DEFAULT\"/" "$GRUB_CONFIG"
	sudo sed -i "/^#*GRUB_GFXMODE=/ s/.*/&\nGRUB_GFXPAYLOAD_LINUX=\"$GRUB_GFXPAYLOAD_LINUX\"/" "$GRUB_CONFIG"

	# Update GRUB
	sudo update-initramfs -u
	sudo update-grub

    echo "GRUB configuration updated successfully."
	else
		echo "GRUB configuration file not found."
		exit 1
	fi

	# Copy display resolution config file 
	sudo cp -b --suffix=.bak "assets/10-monitor_120hz_refresh.conf" "/etc/X11/xorg.conf.d/"

	# Copy Login greeter config file
	sudo cp -b --suffix=.bak "assets/lightdm-gtk-greeter.conf" "/etc/lightdm/"
	
	# XFCE Settings configuration
	sudo cp -b --suffix=.bak "assets/xfce-settings-manager.menu" "/etc/xdg/menus/"

	sudo cp -b --suffix=.bak "assets/qterminal.ini" "/home/$USER/.config/qterminal.org/"

	sudo cp -b --suffix=.bak "assets/Debian-Dark.colorscheme" "/usr/share/qtermwidget5/color-schemes/"
}

allConfigSudo() {
	# Exaract themes in themes folder
	sudo tar --lzma -xf "assets/themes/Flat-Remix-Dark-themes.tar" "/usr/share/themes/"

	# Exaract icons in icons folder
	sudo tar --lzma -xf "assets/icons/Flat-Remix-Dark-icons.tar" "/usr/share/icons/"

	# Make location bar appear in button form in thunar
	sudo xfconf-query -c thunar -p /last-location-bar -s "ThunarLocationButtons"

	# Set theme and icons
	sudo xfconf-query -c xsettings -p /Net/ThemeName "Flat-Remix-Green-Dark"
	sudo xfconf-query -c xsettings -p /Net/IconThemeName "Flat-Remix-Green-Dark"
	sudo xfconf-query -c xsettings -p /Xfce/SyncThemes -s true

	# Set default terminal
	sudo sed -i "/^TerminalEmulator=/ s/.*/TerminalEmulator=qterminal/" "/etc/xdg/xfce4/helpers.rc"
	sudo update-alternatives --set x-terminal-emulator /usr/bin/qterminal
}


allConfigNormal() {
	# Remove Shade icon option and scroll to rollup
	xfconf-query -c xfwm4 -p /general/button_layout -s "O|HMC"
	xfconf-query -c xfwm4 -p /general/mousewheel_rollup false

	# Make location bar appear in button form in thunar
	xfconf-query -c thunar -p /last-location-bar -s "ThunarLocationButtons"

	# Set XFCE panel icon size 
	xfconf-query -c xfce4-panel -p /panels/panel-1/size -s 35

	# Set theme and icons
	xfconf-query -c xfwm4 -p /general/theme "Flat-Remix-Blue-Dark"
	xfconf-query -c xsettings -p /Net/ThemeName "Flat-Remix-Blue-Dark"
	xfconf-query -c xsettings -p /Net/IconThemeName "Flat-Remix-Green-Dark"
	xfconf-query -c xsettings -p /Xfce/SyncThemes -s true
}

if checkRoot; then
	upgradeSys
	installReq
    displayConfig
    allConfigSudo
fi

allConfigNormal