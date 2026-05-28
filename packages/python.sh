#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "${SCRIPT_DIR}/common.sh"

require_root
require_ubuntu

install_apt_packages \
  python3 \
  python3-pip \
  python3-venv \
  pipx

USER_NAME="$(target_user)"
if id "${USER_NAME}" >/dev/null 2>&1; then
  sudo -H -u "${USER_NAME}" python3 -m pipx ensurepath >/dev/null 2>&1 || true
fi
