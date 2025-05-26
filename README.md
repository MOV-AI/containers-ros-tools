[![main](https://github.com/MOV-AI/containers-ros-tools/actions/workflows/docker-ci.yml/badge.svg?branch=main)](https://github.com/MOV-AI/containers-ros-tools/actions/workflows/docker-ci.yml)

# containers-ros-tools

ROS TOOLS Docker image for MOV.AI Framework

Image is built in 3 flavours:

| Flavour      | Base Image | Python |
| ------------ | ---------- | ------ |
| ros-tools-noetic | movai-base-focal:v2.4.3 | 3.8.10 |
| ros-tools-ce | movai-base-focal:v2.4.3 | 3.8.10 |

## About

## Usage

Build ROS TOOLS image based on ROS noetic :

    docker build -t ros-tools:noetic -f noetic/Dockerfile .

Build ROS TOOLS image for CE (contains only Rviz and no ROS components) :

    docker build -t ros-tools:ce -f ce/Dockerfile .

## Run

Run the image with the following command where `robot_network` is the name of the network created by MOV.AI Framework or any other network you want to use.

>Note that the network must be created before running the container and a roscore must be running on the network.

    robot_network=$(docker network ls | grep MovaiNetwork | awk '{print $2}')
    docker run -it --rm \
        --name ros-tools \
        --network $robot_network \
        --gpus all \
        ros-tools:noetic


## License

Forked from https://github.com/ConSol/docker-headless-vnc-container

Includes Lichtblick: https://github.com/lichtblick-suite/lichtblick/
