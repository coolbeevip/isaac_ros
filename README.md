# Isaac ROS Docker Images

This repository is the GitHub Actions publishing mirror for the reusable Docker
layers defined in the `phys-ros` repository. The canonical Dockerfiles remain in
`phys-ros/docker`; changes must be made there first and then synchronized here.

The published image chain is:

```text
NVIDIA Isaac ROS (pinned digest)
  └── base
      └── perception
          └── manipulation
```

Visual perception is a required part of the robot manipulation stack, so the
`manipulation` image intentionally extends `perception`.

## Source boundary

The following files are byte-for-byte mirrors of their canonical `phys-ros`
counterparts:

```text
docker/Dockerfile.base
docker/Dockerfile.perception
docker/Dockerfile.manipulation
```

The project-specific `phys-ros:dev` image is not mirrored or published here. It
depends on the `phys-ros` source tree, Orbbec driver, Piper dependencies, and
development requirements, so it remains owned and built by `phys-ros`.

## Published images

The GitHub Actions workflow publishes images to Docker Hub under:

```text
coolbeevip/isaac_ros
```

Each layer receives a floating tag, an Isaac ROS base-version tag, and a
source-commit-specific tag:

```text
coolbeevip/isaac_ros:base
coolbeevip/isaac_ros:base-isaac_ros_28556f8bc78a98822bd08b2d7c6fcf9b-amd64
coolbeevip/isaac_ros:base-<git-sha>

coolbeevip/isaac_ros:perception
coolbeevip/isaac_ros:perception-isaac_ros_28556f8bc78a98822bd08b2d7c6fcf9b-amd64
coolbeevip/isaac_ros:perception-<git-sha>

coolbeevip/isaac_ros:manipulation
coolbeevip/isaac_ros:manipulation-isaac_ros_28556f8bc78a98822bd08b2d7c6fcf9b-amd64
coolbeevip/isaac_ros:manipulation-<git-sha>
```

`latest` remains an alias for the current `base` image for backward
compatibility. Deployments and downstream Dockerfiles should use a commit tag or
image digest instead of a floating tag.

For example, `phys-ros:dev` can be built from a published manipulation image
without changing its canonical Dockerfile:

```bash
docker buildx build \
  --build-arg BASE_IMAGE=coolbeevip/isaac_ros:manipulation-<git-sha> \
  --file docker/Dockerfile.dev \
  --tag phys-ros:dev \
  --load \
  .
```

## GitHub Actions

The workflow in `.github/workflows/docker.yml` runs when mirrored Docker files
change on `main`, or when started manually. It:

1. Builds and pushes `base`.
2. Passes the resulting image digest to the `perception` build.
3. Passes the resulting `perception` digest to the `manipulation` build.
4. Uses separate GitHub Actions caches for all three layers.

Digest chaining ensures every published image set comes from the same workflow
run even though the floating Docker Hub tags can change.

Required repository secrets:

```text
DOCKER_HUB_USERNAME
DOCKER_HUB_ACCESS_TOKEN
```
