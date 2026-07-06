FROM nvcr.io/nvidia/isaac/ros:isaac_ros_28556f8bc78a98822bd08b2d7c6fcf9b-amd64

ARG DEBIAN_FRONTEND=noninteractive
ARG ROS_DISTRO=jazzy

LABEL org.opencontainers.image.title="isaac_ros:base"
LABEL org.opencontainers.image.description="Base Isaac ROS image with common runtime, examples, image pipeline, SLAM, mapping, DNN inference, AprilTag, and benchmark packages"

RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
    ros-${ROS_DISTRO}-isaac-ros-common \
    ros-${ROS_DISTRO}-isaac-ros-examples \
    ros-${ROS_DISTRO}-isaac-ros-depth-image-proc \
    ros-${ROS_DISTRO}-isaac-ros-image-proc \
    ros-${ROS_DISTRO}-isaac-ros-stereo-image-proc \
    ros-${ROS_DISTRO}-isaac-ros-dnn-image-encoder \
    ros-${ROS_DISTRO}-isaac-ros-tensor-proc \
    ros-${ROS_DISTRO}-isaac-ros-tensor-rt \
    ros-${ROS_DISTRO}-isaac-ros-triton \
    ros-${ROS_DISTRO}-isaac-ros-visual-slam \
    ros-${ROS_DISTRO}-isaac-ros-nvblox \
    ros-${ROS_DISTRO}-isaac-ros-apriltag \
    ros-${ROS_DISTRO}-isaac-ros-benchmark \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
