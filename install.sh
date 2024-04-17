#!/bin/bash

# check for root
checkRoot() {
	if [ "$EUID" -eq 0 ]; then
		return 0
	else
		return 1
	fi
}

checkDirNormal() {
	mkdir -p "/home/$USER/.config/qterminal.org/"
	mkdir -p "/home/$USER/.config/qt5ct/colors/"
	mkdir -p "/home/$USER/.config/qt5ct/qss/"
	mkdir -p "/home/$USER/.config/xfce4/xfconf/xfce-perchannel-xml/"
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
}

copyFilesSudo() {
	# Login greeter config file
	sudo cp -b --suffix=.bak "assets/sda/etc/lightdm/lightdm-gtk-greeter.conf" "/etc/lightdm/"

	# display resolution config file 
	sudo cp -b --suffix=.bak "assets/sda/etc/X11/xorg.conf.d/10-monitor_120hz_refresh.conf" "/etc/X11/xorg.conf.d/"
	
	# XFCE Settings menu configuration
	sudo cp -b --suffix=.bak "assets/sda/etc/xdg/menus/xfce-settings-manager.menu" "/etc/xdg/menus/"
	
	# Mousepad theme or styling
	sudo cp -b --suffix=.bak "assets/sda/usr/share/gtksourceview-4/styles/Debian-Dark.xml" "/usr/share/gtksourceview-4/styles/"

	# QTerminal color scheme
	sudo cp -b --suffix=.bak "assets/sda/usr/share/qtermwidget5/color-schemes/Debian-Dark.colorscheme" "/usr/share/qtermwidget5/color-schemes/"

	#TODO: add Plymouth themes
}

copyFilesNormal() {
	# Copy Qt color configuration file
	cp -b --suffix=.bak "assets/sda/home/USER/.config/qt5ct/colors/Debian-Dark.conf" "/home/$USER/.config/qt5ct/colors/"

	# Copy Qt scrollbar file
	cp -b --suffix=.bak "assets/sda/home/USER/.config/qt5ct/qss/fusion-simple-scrollbar.qss" "/home/$USER/.config/qt5ct/qss/"

	# Copy Qterminal configuration file
	cp -b --suffix=.bak "assets/sda/home/USER/.config/qterminal.org/qterminal.ini" "/home/$USER/.config/qterminal.org/"

	# Copy to fix tooltip configuration
	cp -b --suffix=.bak "assets/sda/home/USER/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml" "/home/$USER/.config/xfce4/xfconf/xfce-perchannel-xml/"
}

allConfigSudo() {
	# Exaract themes in themes folder
	sudo tar --lzma -xf "assets/sda/usr/share/themes/Flat-Remix-Dark-themes.tar" "/usr/share/themes/"

	# Exaract icons in icons folder
	sudo tar --lzma -xf "assets/sda/usr/share/icons/Flat-Remix-Dark-icons.tar" "/usr/share/icons/"

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
	checkDirSudo
	upgradeSys
	installReq
    displayConfig
    allConfigSudo
fi

checkDirNormal
allConfigNormal


# echo 'deb http://download.opensuse.org/repositories/home:/cboxdoerfer/Debian_12/ /' | sudo tee /etc/apt/sources.list.d/home:cboxdoerfer.list
# curl -fsSL https://download.opensuse.org/repositories/home:cboxdoerfer/Debian_12/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/home_cboxdoerfer.gpg > /dev/null
# sudo apt update
# sudo apt install fsearch