#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

### --- replace some KDE utilities --- ###

# remove some KDE stuff
dnf5 remove -y plasma-* xwaylandvideobridge kdebugsettings krfb kwin*

# Replace kwrite and kate with mousepad
dnf5 remove -y kwrite kate && dnf5 install -y mousepad

# remove kwallet and polkit-kde. lxqt-policykit already installed from the sway group
dnf5 remove -y kwallet* ksecret* polkit-kde

# I prefer Dolphin to other file managers so no need to replace that for example

### --- remove other unneeded stuff --- ###

# Remove fcitx (input manager) as sway has built in config stuff for that
dnf5 remove -y fcitx*

### --- my desired packages (sway, etc) --- #

# install sway spin stuff
dnf5 install -y sway-config-fedora

# Setup SDDM as it was removed earlier
dnf5 install -y sddm sddm-themes sddm-wayland-sway

# install systemd setup
dnf5 install -y sway-systemd

# install runner (rofi)
dnf5 install -y rofi-wayland rofi

# install notification server
dnf5 install -y mako

# install missing screenshare stuff
dnf5 install -y xdg-desktop-portal-wlr

# audio
dnf5 install -y pavucontrol wireplumber pipewire pamixer pulseaudio-utils

# internet and bluetooth
dnf5 install -y network-manager-applet NetworkManager-openvpn NetworkManager-openvpn-gnome NetworkManager-openconnect NetworkManager-openconnect-gnome bluez bluez-tools blueman firewall-config

# install liquidctl and coolercontrol so I don't have to layer them
dnf5 -y copr enable codifryed/CoolerControl
dnf5 install -y liquidctl coolercontrold coolercontrol
dnf5 -y copr disable codifryed/CoolerControl # Disable copr to avoid clogging the system

# install kitty (preferred terminal) and zsh. don't suchange preferred shell so as not to break anything
dnf5 install -y kitty zsh

# Clipboard management packages
dnf5 install -y clipman wl-paste

# Install dark theme stuff for:
dnf5 install -y gnome-themes-extra adwaita-gtk2-theme  # GTK apps
dnf5 install -y qt6ct kvantum # QT apps (kvantum for extra themes)

# NWG Shell for nwg-look and azote (theme customization for GTK apps, wallpapers)
dnf5 -y copr enable tofik/nwg-shell 
dnf5 -y install nwg-look azote
#### Example for enabling a System Unit File

systemctl enable podman.socket
systemctl enable coolercontrold
systemctl enable sddm
