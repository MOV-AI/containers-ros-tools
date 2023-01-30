#!/bin/bash

FOXGLOVE_VERSION=1.39.0
FOXGLOVE_ARCH=amd64
FOXGLOVE_DEB_URL=https://github.com/foxglove/studio/releases/download/v${FOXGLOVE_VERSION}/foxglove-studio-${FOXGLOVE_VERSION}-linux-${FOXGLOVE_ARCH}.deb

mkdir -p /tmp/foxglove

wget --show-progress --progress=bar:force:noscroll $FOXGLOVE_DEB_URL -q -P /tmp/foxglove

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    /tmp/foxglove/foxglove-studio-${FOXGLOVE_VERSION}-linux-${FOXGLOVE_ARCH}.deb

cat << EOF  > /usr/local/bin/foxglove
export FOXGLOVE_DISABLE_SIGN_IN=true
"/opt/Foxglove Studio/foxglove-studio" --no-sandbox
EOF

chmod +x /usr/local/bin/foxglove

apt-get autoremove -y
apt-get clean -y
rm -rf /var/lib/apt/lists/*
rm -rf /tmp/foxglove