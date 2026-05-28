#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "${SCRIPT_DIR}/common.sh"

require_root
require_ubuntu

install_desktop_apt_packages \
  nginx \
  docker.io \
  docker-compose-v2

systemctl enable nginx >/dev/null 2>&1 || true
systemctl enable docker >/dev/null 2>&1 || true

USER_NAME="$(target_user)"
if id "${USER_NAME}" >/dev/null 2>&1 && getent group docker >/dev/null 2>&1; then
  ensure_group_membership docker "${USER_NAME}"
fi

WEB_PROXY="${COURSE_WEB_PROXY_TOOL:-both}"
case "${WEB_PROXY}" in
  zap)
    install_snap_package zaproxy --classic
    ;;
  burp)
    install_snap_package burpsuite
    ;;
  both)
    install_snap_package zaproxy --classic
    install_snap_package burpsuite
    ;;
  none)
    echo "Skipping web proxy tool installation because COURSE_WEB_PROXY_TOOL=none."
    ;;
  *)
    echo "Unknown COURSE_WEB_PROXY_TOOL='${WEB_PROXY}'. Use zap, burp, both, or none." >&2
    exit 1
    ;;
esac
