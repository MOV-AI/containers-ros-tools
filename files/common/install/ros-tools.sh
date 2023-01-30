#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

echo "Setup ROS-Tools repo"
sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add -

echo "Install ROS-Tools components"
apt-get update
apt-get install --no-install-recommends -y rviz
# apt-get install --no-install-recommends -y "ros-$ROS_DISTRO-rqt" "ros-$ROS_DISTRO-rqt-common-plugins"
apt-get autoremove -y
apt-get clean -y
