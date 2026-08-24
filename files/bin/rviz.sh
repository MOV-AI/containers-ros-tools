#!/bin/bash
# File: rviz.sh
set -e

ROS_DISTRO=${ROS_DISTRO:-noetic}
RENDER_BACKEND=${RENDER_BACKEND:-default}
VGL_DISPLAY=${VGL_DISPLAY:-}

#shellcheck disable=SC1090
if [ -f /opt/ros/$ROS_DISTRO/setup.bash ]; then
    echo "Sourcing ROS $ROS_DISTRO setup.bash"
    . /opt/ros/$ROS_DISTRO/setup.bash
else
    echo "ROS $ROS_DISTRO setup.bash not found"
fi

export DISABLE_ROS1_EOL_WARNINGS=1
export ROS_MASTER_URI="http://${ROS_MASTER}:${ROS_MASTER_PORT}"

if [ "$RENDER_BACKEND" = "virtualgl" ] && command -v vglrun >/dev/null 2>&1; then
    echo "Launching RViz with VirtualGL backend"
    # Use VGL_DISPLAY if set, otherwise prefer headless EGL acceleration.
    VGL_TARGET="${VGL_DISPLAY:-egl}"
    exec vglrun -d "$VGL_TARGET" "/opt/ros/$ROS_DISTRO/bin/rviz" "-d" "/headless/default.rviz"
fi

if [ "$RENDER_BACKEND" = "virtualgl" ]; then
    echo "RENDER_BACKEND=virtualgl requested, but vglrun was not found. Falling back to default rendering."
fi

exec "/opt/ros/$ROS_DISTRO/bin/rviz" "-d" "/headless/default.rviz"
