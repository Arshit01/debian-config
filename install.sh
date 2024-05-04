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

# Add other sources list
addSource() {
	# fsearch
	echo 'deb http://download.opensuse.org/repositories/home:/cboxdoerfer/Debian_12/ /' | sudo tee /etc/apt/sources.list.d/home:cboxdoerfer.list
	curl -fsSL https://download.opensuse.org/repositories/home:cboxdoerfer/Debian_12/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/home_cboxdoerfer.gpg > /dev/null
	# brave
	sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
	echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list
}

# install required packages
installReq() {
	sudo apt-get update && xargs apt-get install -y < tobeinstalled.txt
	sudo apt-get autopurge -y
	addSource
	sudo apt-get update && apt-get install -y fsearch brave-browser
	sudo apt-get autopurge -y
}

checkDir() {
	mkdir -pv "/home/$USER/.config/fsearch/"
	mkdir -pv "/home/$USER/.config/qt5ct/{colors,qss}/"
	mkdir -pv "/home/$USER/.config/qterminal.org/"
	mkdir -pv "/home/$USER/.config/Thunar/"
	mkdir -pv "/home/$USER/.config/xfce4/{panel{launcher-5,launcher-7},xfconf/xfce-perchannel-xml}"
}

# Set custom resolution
displayConfig() {
	# Define GRUB settings
	GRUB_GFXMODE="1152x864x32"
	GRUB_GFXPAYLOAD_LINUX="keep"
	GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"

	GRUB_CONFIG="/etc/default/grub"

	# Update the GRUB settings in the configuration file
	sudo sed -i "/^#*GRUB_GFXMODE=/ s/.*/GRUB_GFXMODE=\"$GRUB_GFXMODE\"/" "$GRUB_CONFIG"
	sudo sed -i "/^#*GRUB_CMDLINE_LINUX_DEFAULT=/ s/.*/GRUB_CMDLINE_LINUX_DEFAULT=\"$GRUB_CMDLINE_LINUX_DEFAULT\"/" "$GRUB_CONFIG"
	sudo sed -i "/^#*GRUB_GFXMODE=/ s/.*/&\nGRUB_GFXPAYLOAD_LINUX=\"$GRUB_GFXPAYLOAD_LINUX\"/" "$GRUB_CONFIG"
}

copyFiles() {
	# Fsearch configuration
	cp -bv --suffix=.bak "assets/sda/home/USER/.config/fsearch/fsearch.conf" "/home/$USER/.config/fsearch/"
	# Qt5CT configurations
	cp -bvr --suffix=.bak "assets/sda/home/USER/.config/qt5ct/" "/home/$USER/.config/"
	# Qterminal configuration file
	cp -bv --suffix=.bak "assets/sda/home/USER/.config/qterminal.org/qterminal.ini" "/home/$USER/.config/qterminal.org/"
	# Thunar configuration file
	cp -bvr --suffix=.bak "assets/sda/home/USER/.config/Thunar/" "/home/$USER/.config/"
    # Xfce4 configuration files
	cp -bvr --suffix=.bak "assets/sda/home/USER/.config/xfce4/" "/home/$USER/.config/"
}

if checkRoot; then
	sudo cp "rootInstall.sh" "/root/"
	sudo chmod +x "/root/rootInstall.sh"
	upgradeSys
	installReq
	displayConfig
	# Policies for Debian
	sudo cp -bv --suffix=.bak "assets/sda/usr/share/polkit-1/actions/org.debian.pkexec.policy" "/usr/share/polkit-1/actions/"
fi

checkDir
copyFiles
pkexec x-terminal-emulator -e "bash -c './rootInstall.sh; exec bash'"