#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

echo "Setup movai ROS-Tools mirror repo"
curl -fsSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key | gpg --dearmor -o /usr/share/keyrings/ros.key
    echo "deb [signed-by=/usr/share/keyrings/ros.key] https://artifacts.aws.cloud.mov.ai/repository/ppa-proxy-ros focal main" | tee /etc/apt/sources.list.d/movai-ros.list > /dev/null

echo "Install ROS-Tools components"
apt-get update
apt-get install --no-install-recommends -y ros-noetic-rviz=1.14.20*
apt-get autoremove -y
apt-get clean -y
rm -rf /var/lib/apt/lists/*
