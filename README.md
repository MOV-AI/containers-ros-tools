[![main](https://github.com/MOV-AI/containers-ros-tools/actions/workflows/docker-ci.yml/badge.svg?branch=main)](https://github.com/MOV-AI/containers-ros-tools/actions/workflows/docker-ci.yml)

# containers-ros-tools

ROS TOOLS Docker image for MOV.AI Framework

Image is built in 2 flavours:

| Flavour | Base Image | Python |
| ------- | ---------- | ------ |
| ros-tools-noetic | movai-base-focal:v2.5.0 | 3.8.10 |
| ros-tools-ce | movai-base-focal:v2.5.0 | 3.8.10 |

## About
The containers-ros-tools repository provides Docker images for ROS visualization and debugging tools, designed for the MOV.AI Framework. It offers two main variants:

1. Full ROS Tools (noetic):
   - Complete ROS visualization suite
   - Headless VNC support
   - RQT tools
   - Integrated IceWM interface
   - Lichtblick integration

2. CE (Community Edition):
   - Lightweight variant
   - RViz only
   - Minimal dependencies
   - Optimized for basic visualization needs

## Features
- Headless operation with VNC support (noetic variant)
  - VNC port: 5901
  - noVNC web interface: 6901
  - Configurable resolution (default: 1600x1200)
  - Password protection
- ROS Integration
  - Automatic ROS master discovery
  - Configurable ROS master URI
- Tool Suite (noetic variant)
  - RViz
  - RQT
  - IceWM window manager
  - Lichtblick toolkit

## Configuration
Environment variables:
- `VNC_PASSWORD`: VNC authentication password (default: movai)
- `VNC_RESOLUTION`: Screen resolution (default: 1600x1200)
- `ROS_MASTER`: ROS master hostname (default: ros-master)
- `ROS_MASTER_PORT`: ROS master port (default: 11311)
- `VNC_VIEW_ONLY`: Enable view-only mode (default: false)

## Usage

Build ROS TOOLS image based on ROS noetic:
```bash
docker build -t ros-tools:noetic -f noetic/Dockerfile .
```

Build ROS TOOLS image for CE (contains only Rviz and no ROS components):
```bash
docker build -t ros-tools:ce -f ce/Dockerfile .
```

### Basic Run
Run the image with the following command where `robot_network` is the name of the network created by MOV.AI Framework or any other network you want to use.

>Note that the network must be created before running the container and a roscore must be running on the network.

```bash
robot_network=$(docker network ls | grep MovaiNetwork | awk '{print $2}')
docker run -it --rm \
    --name ros-tools \
    --network $robot_network \
    --gpus all \
    ros-tools:noetic
```

### Advanced Usage Examples

#### Custom VNC Password:
```bash
docker run -it --rm \
    -e VNC_PASSWORD=mypassword \
    ros-tools:noetic
```

#### Custom Resolution:
```bash
docker run -it --rm \
    -e VNC_RESOLUTION=1920x1080 \
    ros-tools:noetic
```

## Health Monitoring
This image include a check every 5 seconds on noVNC proxy and vncserver processes to ensure they are running correctly. If the checks fail, the container will be marked as unhealthy thanks to the `HEALTHCHECK` instruction in the Dockerfile which is configured as follows:

- noVNC accessibility check (port 6901)
- 30-second interval checks
- 10-second timeout
- 3 retries before marking unhealthy

## CE (Community Edition) Usage
Run the CE variant with the following command:

```bash
docker run -it --rm \
    --name ros-tools-ce \
    --network $robot_network \
    ros-tools:ce
```

## License

Forked from https://github.com/ConSol/docker-headless-vnc-container

Includes Lichtblick: https://github.com/lichtblick-suite/lichtblick/
