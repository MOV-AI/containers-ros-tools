[![main](https://github.com/MOV-AI/containers-ros-tools/actions/workflows/docker-ci.yml/badge.svg?branch=main)](https://github.com/MOV-AI/containers-ros-tools/actions/workflows/docker-ci.yml)

# containers-ros-tools

ROS TOOLS Docker image for MOV.AI Framework

Image is built in 3 flavours:

| Flavour | Base Image | Python |
| ------- | ---------- | ------ |
| ros-tools-noetic | movai-base-focal:2.7.8 | 3.8.10 |
| ros-tools-ce | movai-base-focal:2.7.8 | 3.8.10 |
| ros-tools-humble | movai-base-humble:2.7.8 | 3.10.12 |

## About
The containers-ros-tools repository provides Docker images for ROS visualization and debugging tools, designed for the MOV.AI Framework. It offers two main variants:

1. Full ROS Tools (noetic):
    - Complete ROS visualization suite
    - RViz for ROS1 and RViz2 for ROS2
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
  - RViz2
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
- `RENDER_BACKEND`: Rendering mode for RViz in headless images (`default` or `virtualgl`, default: `default`)
- `VGL_DISPLAY`: VirtualGL display target when using `RENDER_BACKEND=virtualgl` (default: `egl`; set `:1` to force Xvnc)

> **Note:** `RENDER_BACKEND` and `VGL_DISPLAY` are supported only in the `noetic` and `humble` variants. The CE (Community Edition) variant does not support these options.
    - `egl` stands for Embedded-System Graphics Library. In this context it uses a headless GPU rendering path without requiring an X11 display server.

## Usage

Build ROS TOOLS image based on ROS noetic:
```bash
docker build -t ros-tools:noetic -f noetic/Dockerfile .
```

The noetic image now includes ROS1 RViz and ROS2 RViz2 on top of the Ubuntu Focal base image.

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

Run the ROS2 humble variant:
```bash
robot_network=$(docker network ls | grep MovaiNetwork | awk '{print $2}')
docker run -it --rm \
    --name ros-tools-humble \
    --network $robot_network \
    --gpus all \
    ros-tools:humble
```

After connecting through noVNC, both RViz and RViz2 are available from the IceWM menu and toolbar. The container ships with dedicated default configurations for each viewer.

### GPU Runtime Support

NVIDIA (all image variants):
- Use `--gpus all` at container runtime.
- Ensure the host has NVIDIA drivers and NVIDIA Container Toolkit configured.

Intel iGPU (all image variants):
- Mount the DRI devices with `--device /dev/dri:/dev/dri`.
- Add supplemental groups so the container user can access device nodes.

Example (Intel iGPU):
```bash
RENDER_NODE=${RENDER_NODE:-$(ls /dev/dri/renderD* 2>/dev/null | head -n1)}
CARD_NODE=${CARD_NODE:-$(ls /dev/dri/card* 2>/dev/null | head -n1)}

RENDER_GID=$(stat -c '%g' "$RENDER_NODE")
CARD_GID=$(stat -c '%g' "$CARD_NODE")

docker run -it --rm \
    --name ros-tools-humble-intel \
    --network $robot_network \
    --device /dev/dri:/dev/dri \
    --group-add $RENDER_GID \
    --group-add $CARD_GID \
    ros-tools:humble
```

For CE, keep the existing X11 flags and add Intel DRI mapping when needed:
```bash
XAUTH=${XAUTHORITY:-$HOME/.Xauthority}
RENDER_NODE=${RENDER_NODE:-$(ls /dev/dri/renderD* 2>/dev/null | head -n1)}
CARD_NODE=${CARD_NODE:-$(ls /dev/dri/card* 2>/dev/null | head -n1)}

RENDER_GID=$(stat -c '%g' "$RENDER_NODE")
CARD_GID=$(stat -c '%g' "$CARD_NODE")

docker run -it --rm \
    --name ros-tools-ce \
    --network host \
    -e DISPLAY=$DISPLAY \
    -e XAUTHORITY=$XAUTH \
    -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
    -v $XAUTH:$XAUTH \
    --device /dev/dri:/dev/dri \
    --group-add $RENDER_GID \
    --group-add $CARD_GID \
    ros-tools:ce
```

### RViz GPU Validation

Check that GPU devices are visible in the container:
```bash
ls -l /dev/dri
ls -l /dev/nvidia* 2>/dev/null || true
```

Check renderer information (for X11/VNC sessions):
```bash
echo "DISPLAY=$DISPLAY"
glxinfo -B | egrep "OpenGL vendor|OpenGL renderer|OpenGL version"
```

NVIDIA-specific check (when available):
```bash
nvidia-smi -L
```

What to expect:
- Hardware acceleration should report a vendor/renderer from your GPU stack.
- Software fallback typically appears as `llvmpipe` in `OpenGL renderer`.

Troubleshooting:
- If `--gpus all` is used but no NVIDIA devices are visible, validate host NVIDIA Container Toolkit setup.
- If Intel devices exist but RViz cannot render, verify `/dev/dri` mapping and group access.
- If `glxinfo` cannot connect to display, check `DISPLAY`, X11 mounts, and Xauthority setup (CE), or VNC startup status (headless images).

Important note for headless images (`noetic`/`humble`):
- These images run applications through TigerVNC/Xvnc (`DISPLAY=:1`). In this mode, GLX demos can render through the virtual X server path and may not generate visible activity in `intel_gpu_top`, even when `/dev/dri` is mounted.
- To validate Intel GPU activity on the host, prefer CE mode with host X11 (`DISPLAY=$DISPLAY`) and `--device /dev/dri:/dev/dri` so rendering uses the host X stack directly.

### Optional VirtualGL Headless Backend

For headless `noetic` and `humble`, you can opt in to a VirtualGL launch path for RViz/RViz2:

```bash
docker run -it --rm \
    --name ros-tools-humble-vgl \
    --network $robot_network \
    --gpus all \
    -e RENDER_BACKEND=virtualgl \
    ros-tools:humble
```

Intel runtime variant:

    RENDER_NODE=${RENDER_NODE:-$(ls /dev/dri/renderD* 2>/dev/null | head -n1)}
    CARD_NODE=${CARD_NODE:-$(ls /dev/dri/card* 2>/dev/null | head -n1)}

    RENDER_GID=$(stat -c '%g' "$RENDER_NODE")
    CARD_GID=$(stat -c '%g' "$CARD_NODE")

    docker run -it --rm \
        --name ros-tools-humble-vgl-intel \
        --network $robot_network \
        --device /dev/dri:/dev/dri \
        --group-add $RENDER_GID \
        --group-add $CARD_GID \
        -e RENDER_BACKEND=virtualgl \
        ros-tools:humble

Notes:
- Default behavior is unchanged. VirtualGL is only used when `RENDER_BACKEND=virtualgl`.
- If `RENDER_BACKEND=virtualgl` is requested but `vglrun` is unavailable, launchers fall back to default rendering.

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
    --network host \
    --gpus all \
    -e DISPLAY=$DISPLAY \
    -e XAUTHORITY=$XAUTH \
    -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
    -v $XAUTH:$XAUTH \
    -v ./rviz/:/headless/.rviz/:rw \
    ros-tools:ce
```
## License

Forked from https://github.com/ConSol/docker-headless-vnc-container

Includes Lichtblick: https://github.com/lichtblick-suite/lichtblick/
