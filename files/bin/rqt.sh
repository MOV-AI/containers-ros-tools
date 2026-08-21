#!/bin/bash
# File: rqt.sh
set -e

ROS_DISTRO=${ROS_DISTRO:-noetic}

if [ -f /opt/ros/$ROS_DISTRO/setup.bash ]; then
    echo "Sourcing ROS $ROS_DISTRO setup.bash"
    . /opt/ros/$ROS_DISTRO/setup.bash
else
    echo "ROS $ROS_DISTRO setup.bash not found"
fi

export DISABLE_ROS1_EOL_WARNINGS=1
"/opt/ros/$ROS_DISTRO/bin/rqt"
