#!/bin/bash

IMAGE_NAME=robosim_2026_humble

echo "Building Docker image..."

docker build -t $IMAGE_NAME .
