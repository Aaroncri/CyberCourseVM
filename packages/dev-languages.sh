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

cat > /etc/profile.d/course-dev-paths.sh <<'EOF'
if [ -d "$HOME/.cargo/bin" ]; then
  case ":$PATH:" in
    *":$HOME/.cargo/bin:"*) ;;
    *) PATH="$HOME/.cargo/bin:$PATH" ;;
  esac
fi

if [ -d "$HOME/.elan/bin" ]; then
  case ":$PATH:" in
    *":$HOME/.elan/bin:"*) ;;
    *) PATH="$HOME/.elan/bin:$PATH" ;;
  esac
fi

if [ -d /snap/bin ]; then
  case ":$PATH:" in
    *":/snap/bin:"*) ;;
    *) PATH="/snap/bin:$PATH" ;;
  esac
fi

export PATH
EOF

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
