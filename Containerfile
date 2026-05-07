# For building rust packages
FROM docker.io/library/rust:latest as rustcontainer

# Build swaywsr
RUN git clone https://github.com/pedroscaff/swaywsr.git
WORKDIR /swaywsr
RUN cargo build --release

WORKDIR /

# Build autotiling-rs
RUN git clone https://github.com/ammgws/autotiling-rs.git
WORKDIR /autotiling-rs
RUN cargo build --release

# For building meson/ninja packages
FROM docker.io/library/archlinux as archcontainer

# Build still
RUN pacman -Sy --noconfirm git gcc pkg-config meson pixman wayland wayland-protocols && git clone https://github.com/faergeek/still.git
WORKDIR /still
RUN meson setup --buildtype release build && ninja -C build

### --- main image build --- ###

# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx
COPY build_files /

# Base Image
FROM ghcr.io/ublue-os/bazzite-gnome:stable

ARG IMAGE_NAME="bazzite-sway"
ARG IMAGE_VENDOR="ublue-os, JayB"
ARG IMAGE_REF="ostree-image-signed:docker://ghcr.io/smujb/bazzite-sway"
ARG IMAGE_BRANCH="${IMAGE_BRANCH:-stable}"
ARG BASE_IMAGE_NAME="silverblue"
ARG VERSION_TAG="${VERSION_TAG}"
ARG VERSION_PRETTY="${VERSION_PRETTY}"

## Other possible base images include:
# FROM ghcr.io/ublue-os/bazzite:latest
# FROM ghcr.io/ublue-os/bluefin-nvidia:stable
# 
# ... and so on, here are more base images
# Universal Blue Images: https://github.com/orgs/ublue-os/packages
# Fedora base image: quay.io/fedora/fedora-bootc:41
# CentOS base images: quay.io/centos-bootc/centos-bootc:stream10

### [IM]MUTABLE /opt
## Some bootable images, like Fedora, have /opt symlinked to /var/opt, in order to
## make it mutable/writable for users. However, some packages write files to this directory,
## thus its contents might be wiped out when bootc deploys an image, making it troublesome for
## some packages. Eg, google-chrome, docker-desktop.
##
## Uncomment the following line if one desires to make /opt immutable and be able to be used
## by the package manager.

# RUN rm /opt && mkdir /opt

### MODIFICATIONS
## make modifications desired in your image and install packages by modifying the build.sh script
## the following RUN directive does all the things required to run "build.sh" as recommended.

# Copy binaries built earlier
COPY --from=rustcontainer /swaywsr/target/release/swaywsr /usr/bin/swaywsr
COPY --from=rustcontainer /autotiling-rs/target/release/autotiling-rs /usr/bin/autotiling-rs
COPY --from=archcontainer /still/build/still /usr/bin/still

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/10-install-packages.sh

#RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
#    --mount=type=cache,dst=/var/cache \
#    --mount=type=cache,dst=/var/log \
#    --mount=type=tmpfs,dst=/tmp \
#    /ctx/20-build-additional-packages.sh

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/99-image-info.sh
    
### LINTING
## Verify final image and contents are correct.
RUN bootc container lint
