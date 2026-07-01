#!/usr/bin/env bash

set -e

echo "Setup ROS2 mirror repo"
if [ ! -f /usr/share/keyrings/ros.key ]; then
    curl -fsSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key | gpg --dearmor -o /usr/share/keyrings/ros.key
fi

if [ ! -f /etc/apt/sources.list.d/ros2.list ]; then
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros.key] http://packages.ros.org/ros2/ubuntu focal main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null
fi

echo "Install ROS2 RViz2"
apt-get update
apt-get install --no-install-recommends -y ros-foxy-rviz2
apt-get autoremove -y
apt-get clean -y

rm -rf /var/lib/apt/lists/*
rm -rf /var/cache/apt/*

# Comment out the ros2 entry in the sources.list.d to avoid conflicts with ROS1 packages
sed -i 's/^deb/#deb/g' /etc/apt/sources.list.d/ros2.list
