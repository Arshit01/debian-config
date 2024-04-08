#!/bin/bash


checkDir() {
        sudo mkdir -p "/etc/lightdm/"
        sudo mkdir -p "/etc/X11/xord.conf.d/"
        sudo mkdir -p "/etc/xdg/menus/"
	sudo mkdir -p "/etc/xdg/qt5ct/"
	sudo mkdir -p "/etc/xdg/xfce4/xfce-perchannel-xml"
	sudo mkdir -p "/usr/local/sbin"
        sudo mkdir -p "/usr/share/gtksourceview-4/styles/"
        sudo mkdir -p "/usr/share/plymouth/themes/"
        sudo mkdir -p "/usr/share/qtermwidget5/color-schemes/"
}
