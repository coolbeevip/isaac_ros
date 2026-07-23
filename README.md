# ROS 2 and Isaac ROS Docker Images

This repository is the GitHub Actions publishing mirror for the reusable Docker
layers defined in the `phys-ros` repository. The canonical Dockerfiles remain in
`phys-ros/docker`; changes must be made there first and then synchronized here.

The published image chains are:

```text
ROS 2 Jazzy
  └── ros-base

NVIDIA Isaac ROS (pinned digest)
  └── isaac-base
      └── isaac-perception
          └── isaac-manipulation
```

Visual perception is a required part of the robot manipulation stack, so the
`isaac-manipulation` image intentionally extends `isaac-perception`.

## Source boundary

The following files are synchronized from their canonical `phys-ros`
counterparts:

```text
docker/ros/Dockerfile.base
docker/ros/Dockerfile.dev
docker/isaac-ros/Dockerfile.base
docker/isaac-ros/Dockerfile.perception
docker/isaac-ros/Dockerfile.manipulation
docker/scripts/workspace-entrypoint.sh
```

This publishing repository intentionally does not copy the canonical
Dockerfiles' alternate APT mirror configuration. Builds use the package sources
provided by the upstream ROS and Isaac ROS base images.

The project-specific `docker/ros/Dockerfile.dev` is mirrored for use with the
complete `phys-ros` build context, but the current workflow does not publish it.
The similarly project-specific `docker/isaac-ros/Dockerfile.dev` is not mirrored
or published here. Both development images depend on the complete `phys-ros`
source tree, Orbbec driver, Piper dependencies, and development requirements.

## Published images

The GitHub Actions workflow publishes images to Docker Hub under:

```text
coolbeevip/phys-ros
```

The native ROS 2 base receives a floating tag, an upstream base-version tag,
and a source-commit-specific tag:

```text
coolbeevip/phys-ros:ros-base
coolbeevip/phys-ros:ros-base-jazzy-ros-base-noble
coolbeevip/phys-ros:ros-base-<git-sha>
```

Each Isaac ROS layer receives a floating tag, an Isaac ROS base-version tag,
and a source-commit-specific tag:

```text
coolbeevip/phys-ros:isaac-base
coolbeevip/phys-ros:isaac-base-isaac_ros_28556f8bc78a98822bd08b2d7c6fcf9b-amd64
coolbeevip/phys-ros:isaac-base-<git-sha>

coolbeevip/phys-ros:isaac-perception
coolbeevip/phys-ros:isaac-perception-isaac_ros_28556f8bc78a98822bd08b2d7c6fcf9b-amd64
coolbeevip/phys-ros:isaac-perception-<git-sha>

coolbeevip/phys-ros:isaac-manipulation
coolbeevip/phys-ros:isaac-manipulation-isaac_ros_28556f8bc78a98822bd08b2d7c6fcf9b-amd64
coolbeevip/phys-ros:isaac-manipulation-<git-sha>
```

The former `base`, `perception`, and `manipulation` tags are published as
compatibility aliases. `latest` also remains an alias for the current
`isaac-base` image. Deployments and downstream Dockerfiles should use a commit
tag or image digest instead of a floating tag.

For example, the project-specific development images can be built from the
published reusable layers while running from the canonical `phys-ros` source
root:

```bash
docker buildx build \
  --build-arg BASE_IMAGE=coolbeevip/phys-ros:ros-base-<git-sha> \
  --file docker/ros/Dockerfile.dev \
  --tag phys-ros:ros-dev \
  --load \
  .

docker buildx build \
  --build-arg BASE_IMAGE=coolbeevip/phys-ros:isaac-manipulation-<git-sha> \
  --file docker/isaac-ros/Dockerfile.dev \
  --tag phys-ros:isaac-dev \
  --load \
  .
```

## GitHub Actions

The workflow in `.github/workflows/docker.yml` runs when mirrored Docker files
change on `main`, or when started manually. It:

1. Builds and pushes the independent `ros-base` image.
2. Builds and pushes `isaac-base`.
3. Passes the resulting digest to the `isaac-perception` build.
4. Passes the resulting `isaac-perception` digest to the
   `isaac-manipulation` build.
5. Uses separate GitHub Actions caches for all four layers.

Digest chaining ensures every published Isaac image set comes from the same
workflow run even though the floating Docker Hub tags can change.

Required repository secrets:

```text
DOCKER_HUB_USERNAME
DOCKER_HUB_ACCESS_TOKEN
```
