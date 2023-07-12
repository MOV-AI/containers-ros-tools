#!/bin/bash
# File: rviz.sh
set -e
. /opt/ros/noetic/setup.bash
ROS_MASTER_URI="http://${ROS_MASTER}:${ROS_MASTER_PORT}" "/opt/ros/noetic/bin/rviz" "-d" "/headless/default.rviz"
