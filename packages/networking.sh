#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "${SCRIPT_DIR}/common.sh"

require_root
require_ubuntu

echo "wireshark-common wireshark-common/install-setuid boolean true" | debconf-set-selections

install_desktop_apt_packages \
  iproute2 \
  net-tools \
  dnsutils \
  traceroute \
  tcpdump \
  tshark \
  wireshark \
  nmap \
  netcat-openbsd \
  socat

if getent group wireshark >/dev/null 2>&1; then
  USER_NAME="$(target_user)"
  if id "${USER_NAME}" >/dev/null 2>&1; then
    ensure_group_membership wireshark "${USER_NAME}"
  fi
fi
