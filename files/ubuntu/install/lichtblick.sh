#!/bin/bash

LICHTBLICK_VERSION=1.11.0
LICHTBLICK_ARCH=amd64
LICHTBLICK_DEB_URL=https://github.com/lichtblick-suite/lichtblick/releases/download/v${LICHTBLICK_VERSION}/lichtblick-${LICHTBLICK_VERSION}-linux-${LICHTBLICK_ARCH}.deb

mkdir -p /tmp/lichtblick

wget --show-progress --progress=bar:force:noscroll "$LICHTBLICK_DEB_URL" -q -P /tmp/lichtblick

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    /tmp/lichtblick/lichtblick-${LICHTBLICK_VERSION}-linux-${LICHTBLICK_ARCH}.deb

cat << EOF  > /usr/local/bin/lichtblick
#!/bin/bash
export LICHTBLICK_DISABLE_SIGN_IN=true
"/opt/Lichtblick/lichtblick" --no-sandbox
EOF

chmod +x /usr/local/bin/lichtblick

apt-get autoremove -y
apt-get clean -y
rm -rf /var/lib/apt/lists/*
rm -rf /tmp/lichtblick
