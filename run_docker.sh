#!/bin/bash

CONTAINER_NAME=robosim_2026_container
IMAGE_NAME=robosim_2026_humble

# Project root (one level above docker/)
PROJECT_ROOT=$(cd "$(dirname "$0")/.." && pwd)

# Host workspace folder
HOST_WS=${PROJECT_ROOT}/ros2_ws

# Create host workspace if missing
mkdir -p $HOST_WS

# Remove old container if it exists
if [ "$(docker ps -aq -f name=^${CONTAINER_NAME}$)" ]; then
    docker rm -f ${CONTAINER_NAME}
fi

# Allow the docker to access X11
xhost +local:docker

# Run container
docker run -it \
    --name ${CONTAINER_NAME} \
    --net=host \
    --ipc=host \
    --privileged \
    -e DISPLAY=$DISPLAY \
    -e QT_X11_NO_MITSHM=1 \
    -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
    -v ${HOST_WS}:/root/ros2_ws \
    ${IMAGE_NAME} \
    bash -c '
        # If workspace is empty, copy prebuilt workspace from image
        if [ ! -d /root/ros2_ws/src ] || [ -z "$(ls -A /root/ros2_ws/src 2>/dev/null)" ]; then
            echo "Initializing workspace from Docker image..."
            cp -r /root/ros2_ws_image/* /root/ros2_ws/ 2>/dev/null || true
        fi
        
        # Source ROS and workspace
        source /opt/ros/humble/setup.bash
        source /root/ros2_ws/install/setup.bash

        exec bash
    '
