#!/bin/bash

checkDir() {
        mkdir -pv "/etc/lightdm/"
        mkdir -pv "/etc/X11/{xord.conf.d,Xsession.d}/"
        mkdir -pv "/etc/xdg/{menus,qt5ct,qterminal.org,xfce4}/"
		mkdir -pv "/etc/xdg/xfce4/xfce-perchannel-xml/"
		mkdir -pv "/usr/local/sbin/"
		mkdir -pv "/usr/share/backgrounds/"
		mkdir -pv "/usr/share/fonts/truetype/FiraCode/"
        mkdir -pv "/usr/share/gtksourceview-4/styles/"
        mkdir -pv "/usr/share/plymouth/themes/"
        mkdir -pv "/usr/share/polkit-1/actions/"
        mkdir -pv "/usr/share/qt5ct/{colors,qss}/"
        mkdir -pv "/usr/share/qtermwidget5/color-schemes/"
        mkdir -pv "/usr/share/xfce4/terminal/colorschemes/"
}

copyFiles() {
	# Exaract icons in icons folder
	tar --lzma -xf "assets/sda/usr/share/icons/Flat-Remix-Dark-icons.tar" "/usr/share/icons/"
	# Exaract themes in themes folder
	tar --lzma -xf "assets/sda/usr/share/themes/Flat-Remix-Dark-themes.tar" "/usr/share/themes/"
	# Login greeter config file
	cp -bv --suffix=.bak "assets/sda/etc/lightdm/lightdm-gtk-greeter.conf" "/etc/lightdm/"
	# Display resolution config file 
	cp -bv --suffix=.bak "assets/sda/etc/X11/xorg.conf.d/10-monitor_120hz_refresh.conf" "/etc/X11/xorg.conf.d/"
	# Environment variable file 
	cp -bv --suffix=.bak "assets/sda/etc/X11/Xsession.d/90debian-themes" "/etc/X11/Xsession.d/"
	# XFCE Settings menu configuration
	cp -bv --suffix=.bak "assets/sda/etc/xdg/menus/xfce-settings-manager.menu" "/etc/xdg/menus/"
	# Qt5 configuration settings
	cp -bv --suffix=.bak "assets/sda/etc/xdg/qt5ct/qt5ct.conf" "/etc/xdg/qt5ct/"
	# Qterminal configuration file
	cp -bv --suffix=.bak "assets/sda/etc/xdg/qterminal.org/qterminal.ini" "/etc/xdg/qterminal.org/"
	# XFCE configurations in XML format
	cp -bvr --suffix=.bak "assets/sda/etc/xdg/xfce4/" "/etc/xdg/"
	# Display VPN IP address in panel
	cp -bv --suffix=.bak "assets/sda/usr/local/sbin/xfce4-panel-genmon-vpnip.sh" "/usr/local/sbin/"
	# Debian wallpaper
	cp -bv --suffix=.bak "assets/sda/usr/share/backgrounds/Debian.jpg" "/usr/share/backgrounds/"
	# FiraCode Nerd fonts
	cp -bvr --suffix=.bak "assets/sda/usr/share/fonts/truetype/FiraCode/" "/usr/share/fonts/truetype/"
	# Mousepad theme or styling
	cp -bv --suffix=.bak "assets/sda/usr/share/gtksourceview-4/styles/Debian-Dark.xml" "/usr/share/gtksourceview-4/styles/"
	# Whisker menu icon
	cp -bv --suffix=.bak "assets/sda/usr/share/icons/desktop-bvase/scalable/emblems/debian-logo.svg" "/usr/share/icons/desktop-bvase/scalable/emblems/"
	# Plymouth themes
	tar --gzip -xf "assets/sda/usr/share/plymouth/themes/square_hud.tar.gz" "/usr/share/plymouth/themes/"
	# Policies for Debian
	cp -bv --suffix=.bak "assets/sda/usr/share/polkit-1/actions/org.debian.pkexec.policy" "/usr/share/polkit-1/actions/"
	# Qt5CT configurations
	cp -bvr --suffix=.bak "assets/sda/usr/share/qt5ct/" "/usr/share/"
	# QTerminal color scheme
	cp -bv --suffix=.bak "assets/sda/usr/share/qtermwidget5/color-schemes/Debian-Dark.colorscheme" "/usr/share/qtermwidget5/color-schemes/"
	# XFCE4 Terminal color scheme
	cp -bv --suffix=.bak "assets/sda/usr/share/xfce4/terminal/colorschemes/Debian-Dark.theme" "/usr/share/xfce4/terminal/colorschemes/"
}

allConfig() {
	# Define zsh settings
	DSHELL=/bin/zsh
	SHELL=/bin/zsh

	NEW_USER="/etc/adduser.conf"
	NEW_USER2="/etc/default/useradd"

	sed -i "/^#*DSHELL=/ s/.*/DSHELL=\"$DSHELL\"/" "$NEW_USER"
	sed -i "/^#*SHELL=/ s/.*/SHELL=\"$SHELL\"/" "$NEW_USER2"

	tar --lzma -xf "assets/sda/opt/oh-my-zsh.tar" "/opt/"

	cp -bv "assets/sda/home/USER/.p10k.zsh" "/etc/skel/"
	cp -bv "assets/sda/home/USER/.zshrc" "/etc/skel/"

	# Update icon cache
	for theme in /usr/share/icons/Fla*; do gtk-update-icon-cache $theme; done
	# Change desktop-base theme
	update-alternatives --set desktop-theme /usr/share/desktop-base/homeworld-theme
	# Set Plymouth theme
	plymouth-set-default-theme -R square_hud 
	# At last update the grub
	update-initramfs -u
	update-grub
}

echo -e "\e[38;5;14mChecking Directories...\e[0m"
checkDir
# Change the location of the 'debian-config' directory accordingly
cd /home/bright_lion/debian-config/
echo -e "\e[38;5;14mCopiying required Files...\e[0m"
copyFiles
echo -e "\e[38;5;10mRequired Files Copied\e[0m"
echo -e "\e[38;5;13mSetting Other configurations\e[0m"
allConfig