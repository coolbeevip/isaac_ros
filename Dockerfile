FROM nvcr.io/nvidia/isaac/ros:isaac_ros_28556f8bc78a98822bd08b2d7c6fcf9b-amd64

ARG DEBIAN_FRONTEND=noninteractive
ARG ROS_DISTRO=jazzy

LABEL org.opencontainers.image.title="isaac_ros:base"
LABEL org.opencontainers.image.description="Base Isaac ROS image with common runtime, image pipeline, SLAM, mapping, DNN inference, AprilTag, and benchmark packages"

RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-${ROS_DISTRO}-isaac-ros-common \
    ros-${ROS_DISTRO}-isaac-ros-image-pipeline-examples \
    ros-${ROS_DISTRO}-isaac-ros-dnn-inference-examples \
    ros-${ROS_DISTRO}-isaac-ros-visual-slam-examples \
    ros-${ROS_DISTRO}-isaac-ros-nvblox-examples \
    ros-${ROS_DISTRO}-isaac-ros-apriltag-examples \
    ros-${ROS_DISTRO}-isaac-ros-benchmark \
    && rm -rf /var/lib/apt/lists/*
