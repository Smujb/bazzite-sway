#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
dnf5 install -y tmux

# install sway spin stuff
dnf5 install -y sway-config-fedora

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
dnf5 install -y liquidctl coolercontrol

# install kitty (preferred terminal)
dnf5 install -y kitty

# remove some KDE stuff
dnf5 remove -y plasma-desktop

# Comment out attempt to install everything needed by sway; I'll try Fedora defaults for now
# launcher
# dnf5 install -y rofi-wayland wofi

# environment
# dnf5 install -y fzf tuned-ppd xorg-x11-server-Xwayland headsetcontrol mediainfo polkit xfce-polkit fprintd-pam xdg-user-dirs dbus-tools dbus-daemon wl-clipboard pavucontrol playerctl qt5-qtwayland qt6-qtwayland vulkan-validation-layers vulkan-tools google-noto-emoji-fonts gnome-disk-utility ddcutil openssl vim just alsa-firmware p7zip distrobox steam-devices

# sound
# dnf5 install -y wireplumber pipewire pamixer pulseaudio-utils

# networking
# dnf5 install -y network-manager-applet NetworkManager-openvpn NetworkManager-openvpn-gnome NetworkManager-openconnect NetworkManager-openconnect-gnome bluez bluez-tools blueman firewall-config

# file manager
# dnf5 install -y thunar thunar-archive-plugin thunar-volman xarchiver imv p7zip gvfs-mtp gvfs-gphoto2 gvfs-smb gvfs-nfs gvfs-fuse gvfs-archive android-tools

# screenshot
# dnf5 install -y slurp grim

# display
# dnf5 install -y wlr-randr wlsunset brightnessctl kanshi

# notifications
# dnf5 install -y dunst

# theme and GUI
# dnf5 install -y fontawesome-fonts-all gnome-themes-extra gnome-icon-theme paper-icon-theme breeze-icon-theme papirus-icon-theme

# sway stuff
# dnf5 install -y sway swaylock swayidle foot waybar

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

#### Example for enabling a System Unit File

systemctl enable podman.socket
#systemctl enable coolercontrold
