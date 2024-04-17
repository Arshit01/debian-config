#!/bin/bash

checkDir() {
        sudo mkdir -p "/etc/lightdm/"
        sudo mkdir -p "/etc/X11/{xord.conf.d,Xsession.d}/"
        sudo mkdir -p "/etc/xdg/{menus,qt5ct,xfce4}/"
		sudo mkdir -p "/etc/xdg/xfce4/xfce-perchannel-xml/"
		sudo mkdir -p "/usr/local/sbin/"
		sudo mkdir -p "/usr/share/backgrounds/"
		sudo mkdir -p "/usr/share/fonts/truetype/FiraCode/"
        sudo mkdir -p "/usr/share/gtksourceview-4/styles/"
        sudo mkdir -p "/usr/share/plymouth/themes/"
        sudo mkdir -p "/usr/share/polkit-1/actions/"
        sudo mkdir -p "/usr/share/qt5ct/{colors,qss}/"
        sudo mkdir -p "/usr/share/qtermwidget5/color-schemes/"
        sudo mkdir -p "/usr/share/xfce4/terminal/colorschemes/"
}

copyFiles() {
	# Exaract icons in icons folder
	sudo tar --lzma -xf "assets/sda/usr/share/icons/Flat-Remix-Dark-icons.tar" "/usr/share/icons/"
	# Exaract themes in themes folder
	sudo tar --lzma -xf "assets/sda/usr/share/themes/Flat-Remix-Dark-themes.tar" "/usr/share/themes/"
	# Login greeter config file
	sudo cp -b --suffix=.bak "assets/sda/etc/lightdm/lightdm-gtk-greeter.conf" "/etc/lightdm/"
	# Display resolution config file 
	sudo cp -b --suffix=.bak "assets/sda/etc/X11/xorg.conf.d/10-monitor_120hz_refresh.conf" "/etc/X11/xorg.conf.d/"
	# Environment variable file 
	sudo cp -b --suffix=.bak "assets/sda/etc/X11/Xsession.d/90debian-themes" "/etc/X11/Xsession.d/"
	# XFCE Settings menu configuration
	sudo cp -b --suffix=.bak "assets/sda/etc/xdg/menus/xfce-settings-manager.menu" "/etc/xdg/menus/"
	# Qt5 configuration settings
	sudo cp -b --suffix=.bak "assets/sda/etc/xdg/qt5ct/qt5ct.conf" "/etc/xdg/qt5ct/"
	# XFCE configurations in XML format
	sudo cp -br --suffix=.bak "assets/sda/etc/xdg/xfce4/" "/etc/xdg/"
	# Display VPN IP address in panel
	sudo cp -b --suffix=.bak "assets/sda/usr/local/sbin/xfce4-panel-genmon-vpnip.sh" "/usr/local/sbin/"
	# Debian wallpaper
	sudo cp -b --suffix=.bak "assets/sda/usr/share/backgrounds/Debian.jpg" "/usr/share/backgrounds/"
	# FiraCode Nerd fonts
	sudo cp -br --suffix=.bak "assets/sda/usr/share/fonts/truetype/FiraCode/" "/usr/share/fonts/truetype/"
	# Mousepad theme or styling
	sudo cp -b --suffix=.bak "assets/sda/usr/share/gtksourceview-4/styles/Debian-Dark.xml" "/usr/share/gtksourceview-4/styles/"
	# Whisker menu icon
	sudo cp -b --suffix=.bak "assets/sda/usr/share/icons/desktop-base/scalable/emblems/debian-logo.svg" "/usr/share/icons/desktop-base/scalable/emblems/"
	# Plymouth themes
	sudo tar --gzip -xf "assets/sda/usr/share/plymouth/themes/square_hud.tar.gz" "/usr/share/plymouth/themes/"
	# Policies for Debian
	sudo cp -b --suffix=.bak "assets/sda/usr/share/polkit-1/actions/org.debian.pkexec.policy" "/usr/share/polkit-1/actions/"
	# Qt5CT configurations
	sudo cp -br --suffix=.bak "assets/sda/usr/share/qt5ct/" "/usr/share/"
	# QTerminal color scheme
	sudo cp -b --suffix=.bak "assets/sda/usr/share/qtermwidget5/color-schemes/Debian-Dark.colorscheme" "/usr/share/qtermwidget5/color-schemes/"
	# XFCE4 Terminal color scheme
	sudo cp -b --suffix=.bak "assets/sda/usr/share/xfce4/terminal/colorschemes/Debian-Dark.theme" "/usr/share/xfce4/terminal/colorschemes/"
}

allConfig() {
	# Update icon cache
	for theme in /usr/share/icons/Fla*; do sudo gtk-update-icon-cache $theme; done
	# Make location bar appear in button form in thunar
	sudo xfconf-query -c thunar -p /last-location-bar -s "ThunarLocationButtons"
	# Change desktop-base theme
	sudo update-alternatives --set desktop-theme /usr/share/desktop-base/homeworld-theme
	# Set Plymouth theme
	sudo plymouth-set-default-theme -R square_hud 
	# At last update the grub
	sudo update-grub
}