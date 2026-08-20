#!/bin/bash
# File: rviz2.sh
set -e

ROS2_DISTRO=${ROS2_DISTRO:-foxy}

#shellcheck disable=SC1090
if [ -f /opt/ros/${ROS2_DISTRO}/setup.bash ]; then
    echo "Sourcing ROS ${ROS2_DISTRO} setup.bash"
    . /opt/ros/${ROS2_DISTRO}/setup.bash
else
    echo "ROS ${ROS2_DISTRO} setup.bash not found"
fi

ROS2_DDS_DISCOVERY_SERVER="${ROS2_DDS_DISCOVERY_SERVER:-ros2-workspace}"
ROS2_DDS_DISCOVERY_SERVER_PORT="${ROS2_DDS_DISCOVERY_SERVER_PORT:-11811}"

export DISABLE_ROS1_EOL_WARNINGS=1
export ROS_MASTER_URI="http://${ROS_MASTER}:${ROS_MASTER_PORT}"
export RMW_IMPLEMENTATION=rmw_fastrtps_cpp
export ROS_DISCOVERY_SERVER="${ROS2_DDS_DISCOVERY_SERVER}:${ROS2_DDS_DISCOVERY_SERVER_PORT}"
export FASTRTPS_DEFAULT_PROFILES_FILE=/headless/fastdds_udp_only.xml
export ROS_SUPER_CLIENT=TRUE

"/opt/ros/${ROS2_DISTRO}/bin/rviz2" "-d" "/headless/ros2-default.rviz"
