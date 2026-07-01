#!/usr/bin/env bash

set -e

echo "=== Setup ROS2 mirror repo ==="
if [ ! -f /usr/share/keyrings/ros.key ]; then
    curl -fsSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key | gpg --dearmor -o /usr/share/keyrings/ros.key
fi

if [ ! -f /etc/apt/sources.list.d/ros2.list ]; then
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros.key] http://packages.ros.org/ros2/ubuntu focal main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null
fi

echo "=== Installing Compilation Dependencies ==="
# We mark these explicitly so we can safely purge them later
apt update
apt install -y --no-install-recommends \
    cmake \
    git \
    build-essential \
    python3-colcon-common-extensions \
    python3-colcon-core \
    python3-colcon-ros \
    pkg-config \
    libfreetype6-dev \
    libx11-dev \
    libxaw7-dev \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    libxrandr-dev \
    libxext-dev \
    ros-foxy-rviz2

echo "=== Creating Workspace and Fetching Source ==="
mkdir -p ~/rviz2_ws/src
cd ~/rviz2_ws/src

RVIZ2_REPO="https://github.com/ros2/rviz.git"
RVIZ2_BRANCH="humble"
if [ ! -d "rviz" ]; then
    git clone -b $RVIZ2_BRANCH $RVIZ2_REPO --depth 1 --single-branch --recurse-submodules
fi

echo "=== Compiling RViz2 (Sequential/Release Mode) ==="
cd ~/rviz2_ws

source /opt/ros/foxy/setup.bash

colcon build --merge-install \
  --cmake-args -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=OFF \
  --event-handlers console_direct+

echo "=== Installing Binaries to System Level (/usr/local) ==="

# Safely copy build targets into the standard system environment paths
cd ~/rviz2_ws/install
cp -r bin/* /usr/local/bin/ || true
cp -r lib/* /usr/local/lib/ || true
cp -r share/* /usr/local/share/ || true

# Refresh dynamic linker runtime bindings
ldconfig

echo "=== Cleaning Up Workspace & Purging Build Tools ==="
# 1. Obliterate the workspace source and temporary caches
rm -rf ~/rviz2_ws

# 2. Force-purge compilation packages that are dead weight at runtime
apt-get purge -y \
    cmake \
    git \
    build-essential \
    python3-colcon-common-extensions \
    python3-colcon-core \
    python3-colcon-ros \
    pkg-config \
    libfreetype6-dev \
    libx11-dev \
    libxaw7-dev \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    libxrandr-dev \
    libxext-dev \
    ros-foxy-rviz2

# 3. Automatically discard dangling dependencies (compilers, headers, development libraries)
apt-get autoremove -y

# 4. Flush the APT local storage cache entirely
apt-get clean
rm -rf /var/lib/apt/lists/*

echo "=== Done! RViz2 system-level installation completed ==="
