#!/usr/bin/env bash
set -euo pipefail

echo "Install VirtualGL for optional headless GPU acceleration"

KEY_URL="https://packagecloud.io/dcommander/virtualgl/gpgkey"
KEYRING_PATH="/etc/apt/trusted.gpg.d/VirtualGL.gpg"
SOURCE_LIST_PATH="/etc/apt/sources.list.d/virtualgl.list"

# Fetch and install GPG key
echo "Fetching VirtualGL GPG key..."
wget -q -O- "$KEY_URL" | gpg --dearmor > "$KEYRING_PATH"

if [ ! -f "$KEYRING_PATH" ]; then
    echo "Error: Failed to write VirtualGL GPG keyring to $KEYRING_PATH"
    exit 1
fi

# Configure APT repository
echo "Configuring VirtualGL repository..."
cat > "$SOURCE_LIST_PATH" <<EOL
deb [signed-by=$KEYRING_PATH] https://packagecloud.io/dcommander/virtualgl/any/ any main
EOL

# Update package lists
echo "Updating package lists..."
apt-get update

# Install VirtualGL
echo "Installing VirtualGL..."
if apt-get install -y --no-install-recommends virtualgl; then
    echo "VirtualGL installed successfully"
else
    echo "Warning: VirtualGL installation failed or package unavailable"
    echo "Warning: RENDER_BACKEND=virtualgl will fall back to default rendering"
fi

# Cleanup
apt-get autoremove -y
apt-get clean -y
rm -rf /var/lib/apt/lists/*
