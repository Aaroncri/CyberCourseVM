#!/usr/bin/env bash
set -euo pipefail

require_ubuntu() {
  if [[ ! -r /etc/os-release ]]; then
    echo "Cannot determine operating system: /etc/os-release is missing." >&2
    exit 1
  fi

  # shellcheck disable=SC1091
  source /etc/os-release
  if [[ "${ID:-}" != "ubuntu" ]]; then
    echo "This installer is intended for Ubuntu. Detected: ${PRETTY_NAME:-unknown}." >&2
    exit 1
  fi
}

require_root() {
  if [[ "${EUID}" -ne 0 ]]; then
    echo "Run this script with sudo or as root." >&2
    exit 1
  fi
}

apt_update_once() {
  if [[ "${COURSE_APT_UPDATED:-0}" != "1" ]]; then
    apt-get update
    export COURSE_APT_UPDATED=1
  fi
}

install_apt_packages() {
  apt_update_once
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "$@"
}

install_desktop_apt_packages() {
  apt_update_once
  DEBIAN_FRONTEND=noninteractive apt-get install -y "$@"
}

install_snap_package() {
  local package_name="$1"
  shift

  if ! command -v snap >/dev/null 2>&1; then
    install_apt_packages snapd
  fi

  if snap list "${package_name}" >/dev/null 2>&1; then
    return 0
  fi

  snap install "${package_name}" "$@"
}

ensure_group_membership() {
  local group_name="$1"
  local user_name="$2"

  if id -nG "${user_name}" | tr ' ' '\n' | grep -qx "${group_name}"; then
    return 0
  fi

  usermod -aG "${group_name}" "${user_name}"
}

target_user() {
  if [[ -n "${COURSE_TARGET_USER:-}" ]]; then
    echo "${COURSE_TARGET_USER}"
  elif [[ -n "${SUDO_USER:-}" && "${SUDO_USER}" != "root" ]]; then
    echo "${SUDO_USER}"
  else
    echo "student"
  fi
}
