#!/bin/bash

set -ouex pipefail

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

# Clean up any unneeded packages
dnf5 -y autoremove
