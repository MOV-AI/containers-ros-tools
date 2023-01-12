#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

echo "Installing ttf-wqy-zenhei"
apt-get install --no-install-recommends -y ttf-wqy-zenhei
apt-get clean -y
