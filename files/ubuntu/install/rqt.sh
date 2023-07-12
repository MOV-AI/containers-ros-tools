#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

echo "Install ROS-Tools components"
apt-get update
apt-get install -y ros-$ROS_DISTRO-rqt-plot ros-$ROS_DISTRO-rqt-tf-tree ros-$ROS_DISTRO-rqt-reconfigure --no-install-recommends
apt-get autoremove -y
apt-get clean -y
rm -rf /var/lib/apt/lists/*
