#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "${SCRIPT_DIR}/common.sh"

require_root
require_ubuntu

install_snap_package terraform --classic
install_snap_package aws-cli --classic

if [[ -x /snap/bin/terraform && ! -e /usr/local/bin/terraform ]]; then
  ln -s /snap/bin/terraform /usr/local/bin/terraform
fi

if [[ -x /snap/bin/aws && ! -e /usr/local/bin/aws ]]; then
  ln -s /snap/bin/aws /usr/local/bin/aws
elif [[ -x /snap/bin/aws-cli && ! -e /usr/local/bin/aws ]]; then
  ln -s /snap/bin/aws-cli /usr/local/bin/aws
fi
