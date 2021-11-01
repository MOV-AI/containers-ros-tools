#!/bin/bash
# File: rviz.sh
set -e

source /opt/ros/${ROS_DISTRO}/setup.bash

ROS_MASTER_URI="http://${ROS_MASTER}:${ROS_MASTER_PORT}" /opt/ros/${ROS_DISTRO}/bin/rviz