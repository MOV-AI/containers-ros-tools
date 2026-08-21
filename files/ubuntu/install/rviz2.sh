#!/usr/bin/env bash

set -e

ROS_DISTRO=${ROS_DISTRO:-humble}
ROS2_DISTRO=${ROS2_DISTRO:-humble}

echo "Setup ROS2 mirror repo"
if [ ! -f /usr/share/keyrings/ros.key ]; then
    curl -fsSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key | gpg --dearmor -o /usr/share/keyrings/ros.key
fi

if [ ! -f /etc/apt/sources.list.d/ros2.list ]; then
    if [ "${ROS_DISTRO}" == "noetic" ]; then
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros.key] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null
    elif [ "${ROS_DISTRO}" == "humble" ]; then
        echo "deb [signed-by=/usr/share/keyrings/ros.key] https://artifacts.aws.cloud.mov.ai/repository/ppa-proxy-ros2 $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null
    fi
fi

echo "Install ROS2 RViz2"
apt-get update
apt-get install --no-install-recommends -y "ros-$ROS2_DISTRO-rviz2" "ros-$ROS2_DISTRO-nav2-rviz-plugins"
apt-get autoremove -y
apt-get clean -y

rm -rf /var/lib/apt/lists/*
rm -rf /var/cache/apt/*

if [ "${ROS_DISTRO}" == "noetic" ]; then
    # Comment out the ros2 entry in the sources.list.d to avoid conflicts with ROS1 packages
    sed -i 's/^deb/#deb/g' /etc/apt/sources.list.d/ros2.list
else
    # Point Rviz to Rviz2
    ln -sf "/opt/ros/${ROS2_DISTRO}/bin/rviz2" "/opt/ros/${ROS2_DISTRO}/bin/rviz"
fi
