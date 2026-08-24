#!/usr/bin/env bash
set -euo pipefail

echo "Install VirtualGL for optional headless GPU acceleration"

KEYRING_PATH="/usr/share/keyrings/virtualgl-archive-keyring.gpg"
SOURCE_LIST_PATH="/etc/apt/sources.list.d/virtualgl.list"
KEY_URL="https://packagecloud.io/dcommander/virtualgl/gpgkey"

if [ -r /etc/os-release ]; then
    . /etc/os-release
else
    echo "Error: /etc/os-release not found"
    exit 1
fi

CODENAME="${VERSION_CODENAME:-}"
if [ -z "$CODENAME" ]; then
    echo "Error: Could not determine Ubuntu codename from VERSION_CODENAME"
    exit 1
fi

install -d -m 0755 /usr/share/keyrings
curl -fsSL "$KEY_URL" | gpg --dearmor -o "$KEYRING_PATH"

cat > "$SOURCE_LIST_PATH" <<EOF
deb [signed-by=$KEYRING_PATH] https://packagecloud.io/dcommander/virtualgl/ubuntu/ $CODENAME main
EOF

apt-get update

if apt-cache show virtualgl >/dev/null 2>&1; then
    apt-get install -y --no-install-recommends virtualgl
else
    echo "Warning: virtualgl package is not available in configured apt repositories."
    echo "Warning: RENDER_BACKEND=virtualgl will fall back to default rendering until VirtualGL is installed."
fi

apt-get autoremove -y
apt-get clean -y
rm -rf /var/lib/apt/lists/*
