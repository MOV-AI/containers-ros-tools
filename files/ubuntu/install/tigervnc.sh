#!/usr/bin/env bash
set -e

ROS_DISTRO=${ROS_DISTRO:-noetic}
EXTRA_APT_PACKAGES=${EXTRA_APT_PACKAGES:-}

if [ "$ROS_DISTRO" != "noetic" ]; then
    EXTRA_APT_PACKAGES="$EXTRA_APT_PACKAGES tigervnc-tools"
fi

echo "Install TigerVNC server"
apt-get update
apt-get install -y --no-install-recommends tigervnc-standalone-server tigervnc-common $EXTRA_APT_PACKAGES
apt-get autoremove -y
apt-get clean -y
rm -rf /var/lib/apt/lists/*
