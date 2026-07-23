# ROS 2 and Isaac ROS Docker Images

This repository is the GitHub Actions publishing mirror for the reusable Docker
layers defined in the `phys-ros` repository. The canonical Dockerfiles remain in
`phys-ros/docker`; changes must be made there first and then synchronized here.

The published image chains are:

```text
ROS 2 Jazzy
  └── ros-base
      └── ros-dev

NVIDIA Isaac ROS (pinned digest)
  └── isaac-base
      └── isaac-perception
          └── isaac-manipulation
              └── isaac-dev
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
docker/isaac-ros/Dockerfile.dev
docker/scripts/workspace-entrypoint.sh
```

This publishing repository intentionally does not copy the canonical
Dockerfiles' alternate APT mirror configuration. Builds use the package sources
provided by the upstream ROS and Isaac ROS base images.

The self-contained ROS and Isaac ROS development Dockerfiles are both mirrored
and published here.

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

coolbeevip/phys-ros:ros-dev
coolbeevip/phys-ros:ros-dev-jazzy-ros-base-noble
coolbeevip/phys-ros:ros-dev-<git-sha>
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

coolbeevip/phys-ros:isaac-dev
coolbeevip/phys-ros:isaac-dev-isaac_ros_28556f8bc78a98822bd08b2d7c6fcf9b-amd64
coolbeevip/phys-ros:isaac-dev-<git-sha>
```

The former `base`, `perception`, and `manipulation` tags are published as
compatibility aliases. `latest` also remains an alias for the current
`isaac-base` image. Deployments and downstream Dockerfiles should use a commit
tag or image digest instead of a floating tag.

For example, the canonical development Dockerfiles can also be built locally
from the published layers while running from the `phys-ros` source root:

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
change on `main`, or when started manually. Push builds are selective and
cascade only toward dependent layers:

| Changed input | Rebuilt images |
| --- | --- |
| `docker/ros/Dockerfile.base` | `ros-base`, `ros-dev` |
| `docker/ros/Dockerfile.dev` | `ros-dev` |
| `docker/isaac-ros/Dockerfile.base` | Entire Isaac ROS chain |
| `docker/isaac-ros/Dockerfile.perception` | `isaac-perception`, `isaac-manipulation`, `isaac-dev` |
| `docker/isaac-ros/Dockerfile.manipulation` | `isaac-manipulation`, `isaac-dev` |
| `docker/isaac-ros/Dockerfile.dev` | `isaac-dev` |
| `docker/scripts/**` | Both complete chains |
| `.dockerignore` or this workflow | All images |

Manual workflow dispatches rebuild all images. During a selective build, an
unchanged parent is referenced by its published floating tag. A parent rebuilt
in the same run is passed to its child by digest.

The workflow then:

1. Builds and pushes `ros-base`, then passes its digest to the `ros-dev` build.
2. Builds and pushes `isaac-base` independently.
3. Passes the resulting Isaac base digest to the `isaac-perception` build.
4. Passes the resulting `isaac-perception` digest to the
   `isaac-manipulation` build.
5. Passes the resulting `isaac-manipulation` digest to the `isaac-dev` build.
6. Uses separate GitHub Actions caches for all six layers.

Digest chaining ensures every published Isaac image set comes from the same
workflow run even though the floating Docker Hub tags can change.

Required repository secrets:

```text
DOCKER_HUB_USERNAME
DOCKER_HUB_ACCESS_TOKEN
```
