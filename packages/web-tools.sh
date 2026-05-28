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

install_zap() {
  install_snap_package zaproxy --classic
  if [[ -x /snap/bin/zaproxy && ! -e /usr/local/bin/zaproxy ]]; then
    ln -s /snap/bin/zaproxy /usr/local/bin/zaproxy
  fi
}

install_burp() {
  install_snap_package burpsuite

  if [[ -x /snap/bin/burpsuite && ! -e /usr/local/bin/burpsuite ]]; then
    ln -s /snap/bin/burpsuite /usr/local/bin/burpsuite
  elif [[ -x /snap/bin/burp-suite && ! -e /usr/local/bin/burpsuite ]]; then
    ln -s /snap/bin/burp-suite /usr/local/bin/burpsuite
  fi

  if ! command -v burpsuite >/dev/null 2>&1 && [[ ! -x /snap/bin/burpsuite && ! -x /snap/bin/burp-suite ]]; then
    echo "Burp Suite snap installed, but no burpsuite command was found." >&2
    exit 1
  fi
}

WEB_PROXY="${COURSE_WEB_PROXY_TOOL:-both}"
case "${WEB_PROXY}" in
  zap)
    install_zap
    ;;
  burp)
    install_burp
    ;;
  both)
    install_zap
    install_burp
    ;;
  none)
    echo "Skipping web proxy tool installation because COURSE_WEB_PROXY_TOOL=none."
    ;;
  *)
    echo "Unknown COURSE_WEB_PROXY_TOOL='${WEB_PROXY}'. Use zap, burp, both, or none." >&2
    exit 1
    ;;
esac
