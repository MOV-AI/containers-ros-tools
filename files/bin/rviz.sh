#!/bin/bash
# File: rviz.sh
set -e
if [ -f /opt/ros/$ROS_DISTRO/setup.bash ]; then
    echo "Sourcing ROS $ROS_DISTRO setup.bash"
    . /opt/ros/$ROS_DISTRO/setup.bash
else
    echo "ROS $ROS_DISTRO setup.bash not found"
fi

export DISABLE_ROS1_EOL_WARNINGS=1
ROS_MASTER_URI="http://${ROS_MASTER}:${ROS_MASTER_PORT}" "/opt/ros/$ROS_DISTRO/bin/rviz" "-d" "/headless/default.rviz"
