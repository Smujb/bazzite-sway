#!/bin/bash

set -ouex pipefail

# State that we are building additional packages
echo "::group::Executing build-additional-packages"
trap 'echo "::endgroup::"' EXIT

### --- swaywsr --- ###
SWAYWSR_LOCATION="/usr/share/swaywsr/tmp"

# Install dependencies
dnf5 -y install cargo
rm /root # Root is sym linked to /var/roothome, must remove it and then re-add it later

# Create a temporary directory for storing build files and download the repo
mkdir -p $SWAYWSR_LOCATION && cd $SWAYWSR_LOCATION
git clone https://github.com/pedroscaff/swaywsr.git

# Build swaywsr
cd swaywsr
cargo build --release

# Copy it out of the build directory
cp $SWAYWSR_LOCATION/swaywsr/target/release/swaywsr /usr/bin/swaywsr

# Cleanup
cd /
dnf5 -y remove cargo
rm -rf $SWAYWSR_LOCATION

# Re-create /var/roothome as writeable in the final image
rm -rf /root && ln -s /root /var/roothome

### --- still --- ###
STILL_LOCATION="/usr/share/still/tmp"

# Install dependencies
dnf5 -y install meson pixman-devel wayland-devel wayland-protocols-devel

# Create a temporary directory for storing build files and download the repo
mkdir -p $STILL_LOCATION && cd $STILL_LOCATION
git clone https://github.com/faergeek/still.git

# Build still
cd still
meson setup --buildtype release build
ninja -C build

# Copy it out of the build directory
cp $STILL_LOCATION/still/build/still /usr/bin/still

# Cleanup
cd /
dnf5 -y remove meson pixman-devel wayland-devel wayland-protocols-devel
rm -rf $STILL_LOCATION