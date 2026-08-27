#!/bin/bash
# File: rviz2.sh
set -e

ROS2_DISTRO=${ROS2_DISTRO:-foxy}
RENDER_BACKEND=${RENDER_BACKEND:-default}
VGL_DISPLAY=${VGL_DISPLAY:-}

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

if [ "$RENDER_BACKEND" = "virtualgl" ] && command -v vglrun >/dev/null 2>&1; then
    echo "Launching RViz2 with VirtualGL backend"
    # Use VGL_DISPLAY if set, otherwise prefer headless EGL acceleration.
    VGL_TARGET="${VGL_DISPLAY:-egl}"
    exec vglrun -d "$VGL_TARGET" "/opt/ros/${ROS2_DISTRO}/bin/rviz2" "-d" "/headless/ros2-default.rviz"
fi

if [ "$RENDER_BACKEND" = "virtualgl" ]; then
    echo "RENDER_BACKEND=virtualgl requested, but vglrun was not found. Falling back to default rendering."
fi

exec "/opt/ros/${ROS2_DISTRO}/bin/rviz2" "-d" "/headless/ros2-default.rviz"
