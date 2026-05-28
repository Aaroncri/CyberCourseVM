#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "${SCRIPT_DIR}/common.sh"

require_root
require_ubuntu

install_apt_packages unzip

if ! command -v terraform >/dev/null 2>&1; then
  install_apt_packages ca-certificates gnupg wget
  if [[ ! -r /usr/share/keyrings/hashicorp-archive-keyring.gpg ]]; then
    wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor --yes -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
  fi

  # shellcheck disable=SC1091
  . /etc/os-release
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com ${UBUNTU_CODENAME} main" > /etc/apt/sources.list.d/hashicorp.list
  if apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y terraform; then
    :
  else
    echo "Terraform apt install failed; falling back to snap." >&2
    rm -f /etc/apt/sources.list.d/hashicorp.list
    apt-get update
    install_snap_package terraform --classic
  fi
fi

if ! command -v aws >/dev/null 2>&1 && [[ ! -x /snap/bin/aws ]]; then
  install_snap_package aws-cli --classic
fi
