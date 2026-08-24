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

if [ "$ROS_DISTRO" != "noetic" ]; then
    ROS2_DDS_DISCOVERY_SERVER="${ROS2_DDS_DISCOVERY_SERVER:-ros2-workspace}"
    ROS2_DDS_DISCOVERY_SERVER_PORT="${ROS2_DDS_DISCOVERY_SERVER_PORT:-11811}"
    export RMW_IMPLEMENTATION=rmw_fastrtps_cpp
    export ROS_DISCOVERY_SERVER="${ROS2_DDS_DISCOVERY_SERVER}:${ROS2_DDS_DISCOVERY_SERVER_PORT}"
    export FASTRTPS_DEFAULT_PROFILES_FILE=/headless/fastdds_udp_only.xml
    export ROS_SUPER_CLIENT=TRUE
else
    export DISABLE_ROS1_EOL_WARNINGS=1
    export ROS_MASTER_URI="http://${ROS_MASTER}:${ROS_MASTER_PORT}"
fi
"/opt/ros/$ROS_DISTRO/bin/rqt"
