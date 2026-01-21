#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

### --- remove gnome --- ####

dnf5 -y remove *gnome* *mutter* --exclude=gnome-disk-utility,lutris,gnome-desktop3 # Exclude Disks, Lutris, and gnome desktop 3 which Lutris requires

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

# preferred text editor
dnf5 -y install mousepad

# preferred file manager and archive plugin
dnf5 -y install thunar thunar-archive-plugin

# preferred archive tool
dnf5 -y install file-roller

### --- add bazzite-dx packages without using bazzite-dx as a base --- ###

dnf5 install -y \
    android-tools \
    bcc \
    bpftop \
    bpftrace \
    ccache \
    flatpak-builder \
    git-subtree \
    nicstat \
    numactl \
    podman-machine \
    podman-tui \
    python3-ramalama \
    qemu-kvm \
    restic \
    rclone \
    sysprof \
    tiptop \
    usbmuxd

# Install VS Codium
tee /etc/yum.repos.d/vscodium.repo << 'EOF'
[vscodium]
name=VSCodium
baseurl=https://paulcarroty.gitlab.io/vscodium-deb-rpm-repo/rpms/
enabled=1
gpgcheck=1
repo_gpgcheck=0
gpgkey=https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg
metadata_expire=1h
EOF

dnf5 install -y codium

### --- enable system unit files --- ###

systemctl enable podman.socket
systemctl enable coolercontrold
systemctl enable sddm

### --- change build ID --- ###

IMAGE_INFO="/usr/share/ublue-os/image-info.json"
FEDORA_VERSION=$(rpm -E %fedora)

# Image Info File (TODO: fix version stuff)
cat > $IMAGE_INFO <<EOF
{
  "image-name": "$IMAGE_NAME",
  "image-vendor": "$IMAGE_VENDOR",
  "image-ref": "$IMAGE_REF",
  "image-tag": "stable",
  "image-branch": "$IMAGE_BRANCH",
  "base-image-name": "$BASE_IMAGE_NAME",
  "fedora-version": "$FEDORA_VERSION",
  "version": "$VERSION_TAG",
  "version-pretty": "$VERSION_PRETTY"
}
EOF

sed -i "s/^VARIANT_ID=.*/VARIANT_ID=$IMAGE_NAME/" /usr/lib/os-release