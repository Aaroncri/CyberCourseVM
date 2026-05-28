#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "${SCRIPT_DIR}/common.sh"

require_root
require_ubuntu

install_snap_package terraform --classic
install_snap_package aws-cli --classic

if [[ ! -x /snap/bin/terraform ]]; then
  echo "Terraform snap installed, but /snap/bin/terraform does not exist." >&2
  snap list terraform >&2 || true
  snap info terraform >&2 || true
  exit 1
fi

if [[ ! -x /snap/bin/aws ]]; then
  echo "AWS CLI snap installed, but /snap/bin/aws does not exist." >&2
  snap list aws-cli >&2 || true
  snap info aws-cli >&2 || true
  exit 1
fi

ln -sf /snap/bin/terraform /usr/local/bin/terraform
ln -sf /snap/bin/aws /usr/local/bin/aws

/usr/local/bin/terraform version >/dev/null
/usr/local/bin/aws --version >/dev/null
