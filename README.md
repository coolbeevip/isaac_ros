# Isaac ROS Docker Images

This repository builds layered Isaac ROS images from NVIDIA's Isaac ROS base image:

```text
nvcr.io/nvidia/isaac/ros:isaac_ros_28556f8bc78a98822bd08b2d7c6fcf9b-amd64
```

All image builds run in GitHub Actions. The repository does not require local Docker builds.

## Images

The workflow publishes images to Docker Hub under:

```text
coolbeevip/isaac_ros
```

Published tags:

```text
coolbeevip/isaac_ros:base
coolbeevip/isaac_ros:latest
coolbeevip/isaac_ros:base-isaac_ros_28556f8bc78a98822bd08b2d7c6fcf9b-amd64

coolbeevip/isaac_ros:perception
coolbeevip/isaac_ros:perception-isaac_ros_28556f8bc78a98822bd08b2d7c6fcf9b-amd64

coolbeevip/isaac_ros:manipulation
coolbeevip/isaac_ros:manipulation-isaac_ros_28556f8bc78a98822bd08b2d7c6fcf9b-amd64
```

## Layers

`base` installs common Isaac ROS packages for examples, image processing, DNN inference, visual SLAM, nvblox, AprilTag, and benchmarking.

`perception` extends `base` with object detection, segmentation, FoundationPose, and FoundationStereo packages.

`manipulation` extends `perception` with MoveIt, MoveIt Servo, MoveIt Setup Assistant, cuMotion examples, and Isaac ROS manipulation bringup.

## GitHub Actions

The workflow is defined in:

```text
.github/workflows/docker.yml
```

It runs on pushes to `main` when Docker-related files change, and it can also be started manually with `workflow_dispatch`.

Required repository secrets:

```text
DOCKER_HUB_USERNAME
DOCKER_HUB_ACCESS_TOKEN
```
