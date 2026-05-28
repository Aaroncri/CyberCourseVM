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

ensure_snap_ready() {
  if ! command -v snap >/dev/null 2>&1; then
    install_apt_packages snapd
  fi

  systemctl enable --now snapd.socket >/dev/null 2>&1 || true
  systemctl enable --now snapd.service >/dev/null 2>&1 || true

  if [[ -e /var/lib/snapd/snap && ! -e /snap ]]; then
    ln -s /var/lib/snapd/snap /snap
  fi

  case ":${PATH}:" in
    *":/snap/bin:"*) ;;
    *) export PATH="/snap/bin:${PATH}" ;;
  esac

  local attempt
  for attempt in {1..30}; do
    if snap wait system seed.loaded >/dev/null 2>&1; then
      return 0
    fi
    sleep 2
  done

  echo "snapd did not become ready after waiting." >&2
  systemctl --no-pager --full status snapd.service snapd.socket >&2 || true
  snap changes >&2 || true
  exit 1
}

install_snap_package() {
  local package_name="$1"
  shift

  ensure_snap_ready

  if snap list "${package_name}" >/dev/null 2>&1; then
    return 0
  fi

  echo "Installing snap package: ${package_name}"
  if ! snap install "${package_name}" "$@"; then
    echo "Failed to install snap package: ${package_name}" >&2
    snap changes >&2 || true
    snap tasks --last=install >&2 || true
    exit 1
  fi

  if ! snap list "${package_name}" >/dev/null 2>&1; then
    echo "snap install completed, but package is not listed: ${package_name}" >&2
    snap list >&2 || true
    exit 1
  fi
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
