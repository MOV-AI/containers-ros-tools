[![main](https://github.com/MOV-AI/containers-ros-tools/actions/workflows/docker-ci.yml/badge.svg?branch=main)](https://github.com/MOV-AI/containers-ros-tools/actions/workflows/docker-ci.yml)

# containers-ros-tools

ROS TOOLS Docker image for MOV.AI Framework

Image is built in 3 flavours:

| Flavour      | Base Image | Python |
| ------------ | ---------- | ------ |
| ros-tools-melodic | ros:melodic-robot | 3.6.9 |
| ros-tools-noetic | ros:noetic-robot | 3.8.10 |
| ros-tools-ce | movai-base-focal:v1.2.0 | 3.8.10 |

## About

## Usage

Build ROS TOOLS image based on ROS melodic :

    docker build -t ros-tools:melodic -f melodic/Dockerfile .

Build ROS TOOLS image based on ROS noetic :

    docker build -t ros-tools:noetic -f noetic/Dockerfile .

Build ROS TOOLS image for CE (contains only Rviz and no ROS components) :

    docker build -t ros-tools:ce -f ce/Dockerfile .
