#!/bin/bash
# File: rviz.sh
set -e
. /opt/ros/noetic/setup.bash
export DISABLE_ROS1_EOL_WARNINGS=1
ROS_MASTER_URI="http://${ROS_MASTER}:${ROS_MASTER_PORT}" "/opt/ros/noetic/bin/rviz" "-d" "/headless/default.rviz"
