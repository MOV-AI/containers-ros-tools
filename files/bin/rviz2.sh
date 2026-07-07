#!/bin/bash
# File: rviz2.sh
set -e
if [ -f /opt/ros/foxy/setup.bash ]; then
    echo "Sourcing ROS Foxy setup.bash"
    . /opt/ros/foxy/setup.bash
else
    echo "ROS Foxy setup.bash not found"
fi

ROS2_DDS_DISCOVERY_SERVER="${ROS2_DDS_DISCOVERY_SERVER:-ros2-workspace}"
ROS2_DDS_DISCOVERY_SERVER_PORT="${ROS2_DDS_DISCOVERY_SERVER_PORT:-11811}"

export DISABLE_ROS1_EOL_WARNINGS=1
export ROS_MASTER_URI="http://${ROS_MASTER}:${ROS_MASTER_PORT}"
export RMW_IMPLEMENTATION=rmw_fastrtps_cpp
export ROS_DISCOVERY_SERVER="${ROS2_DDS_DISCOVERY_SERVER}:${ROS2_DDS_DISCOVERY_SERVER_PORT}"

"/opt/ros/foxy/bin/rviz2" "-d" "/headless/ros2-default.rviz"
