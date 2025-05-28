#!/bin/bash
# File: rviz.sh
set -e
if [ -f /opt/ros/noetic/setup.bash ]; then
    echo "Sourcing ROS Noetic setup.bash"
    . /opt/ros/noetic/setup.bash
else
    echo "ROS Noetic setup.bash not found"
fi

export DISABLE_ROS1_EOL_WARNINGS=1
ROS_MASTER_URI="http://${ROS_MASTER}:${ROS_MASTER_PORT}" "/opt/ros/noetic/bin/rviz" "-d" "/headless/default.rviz"
