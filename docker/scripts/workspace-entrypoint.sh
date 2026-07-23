#!/usr/bin/env bash
set -euo pipefail

target_user="admin"
target_home="/home/${target_user}"
host_uid="${HOST_USER_UID:-}"
host_gid="${HOST_USER_GID:-}"

if [[ -n "${host_gid}" ]]; then
  if [[ ! "${host_gid}" =~ ^[0-9]+$ ]]; then
    echo "HOST_USER_GID must be numeric: ${host_gid}" >&2
    exit 2
  fi

  existing_group="$(getent group "${host_gid}" | cut -d: -f1 || true)"
  if [[ -n "${existing_group}" ]]; then
    usermod --gid "${existing_group}" "${target_user}"
  elif [[ "$(id -g "${target_user}")" != "${host_gid}" ]]; then
    groupmod --gid "${host_gid}" "$(id -gn "${target_user}")"
  fi
fi

if [[ -n "${host_uid}" ]]; then
  if [[ ! "${host_uid}" =~ ^[0-9]+$ ]]; then
    echo "HOST_USER_UID must be numeric: ${host_uid}" >&2
    exit 2
  fi

  existing_user="$(getent passwd "${host_uid}" | cut -d: -f1 || true)"
  if [[ -n "${existing_user}" && "${existing_user}" != "${target_user}" ]]; then
    echo "HOST_USER_UID ${host_uid} already belongs to ${existing_user}" >&2
    exit 2
  fi
  if [[ "$(id -u "${target_user}")" != "${host_uid}" ]]; then
    usermod --uid "${host_uid}" "${target_user}"
  fi
fi

mkdir -p "${target_home}"
chown -R "${target_user}:$(id -gn "${target_user}")" "${target_home}"

export HOME="${target_home}"
export USER="${target_user}"
export LOGNAME="${target_user}"

if [[ -n "${ROS_DISTRO:-}" && -f "/opt/ros/${ROS_DISTRO}/setup.bash" ]]; then
  # shellcheck disable=SC1090
  source "/opt/ros/${ROS_DISTRO}/setup.bash"
fi

exec gosu "${target_user}" "$@"
