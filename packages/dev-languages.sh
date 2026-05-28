#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "${SCRIPT_DIR}/common.sh"

require_root
require_ubuntu

install_apt_packages \
  curl \
  build-essential \
  pkg-config \
  libssl-dev \
  clang \
  cmake

USER_NAME="$(target_user)"
if ! id "${USER_NAME}" >/dev/null 2>&1; then
  echo "Target user '${USER_NAME}' does not exist; skipped Rust and Lean setup." >&2
  exit 0
fi

sudo -H -u "${USER_NAME}" bash -lc '
  set -euo pipefail

  if [[ ! -x "$HOME/.cargo/bin/rustup" ]]; then
    curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --profile default
  fi

  "$HOME/.cargo/bin/rustup" component add rustfmt clippy

  if [[ ! -x "$HOME/.elan/bin/elan" ]]; then
    curl https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh -sSf | sh -s -- -y
  fi

  "$HOME/.elan/bin/elan" default stable
'
