#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

echo "Setup ROS-Tools repo"
sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add -

echo "Install ROS-Tools components"
apt-get update
apt-get install -y ros-noetic-rqt-plot ros-noetic-rqt-tf-tree ros-noetic-rqt-reconfigure --no-install-recommends
apt-get autoremove -y
apt-get clean -y
rm -rf /var/lib/apt/lists/*
