#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

echo "Install some common tools for further installation"
apt-get update
apt-get install --no-install-recommends -y terminator vim wget net-tools locales bzip2 \
    python-numpy #used for websockify/novnc
apt-get clean -y

echo "generate locales for $LANG"
locale-gen "$LANG"
dpkg-reconfigure locales

