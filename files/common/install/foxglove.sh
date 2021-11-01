#!/usr/bin/env bash
### every exit != 0 fails the script
set -e
set -u
FOXGLOVE_VERSION="0.17.0"
echo "Install Foxglove - a web based rviz alternative"
wget https://github.com/foxglove/studio/releases/download/v0.17.0/foxglove-studio-$FOXGLOVE_VERSION-linux-amd64.deb
apt-get install -y ./foxglove-studio-$FOXGLOVE_VERSION-linux-amd64.deb
rm -rf ./foxglove-studio-$FOXGLOVE_VERSION-linux-amd64.deb
