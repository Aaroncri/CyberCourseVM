#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "${SCRIPT_DIR}/common.sh"

require_root
require_ubuntu

install_apt_packages \
  ca-certificates \
  curl \
  gnupg \
  unzip \
  wget

machine_arch="$(uname -m)"

terraform_arch() {
  case "${machine_arch}" in
    x86_64 | amd64)
      echo "amd64"
      ;;
    aarch64 | arm64)
      echo "arm64"
      ;;
    *)
      echo "Unsupported Terraform architecture: ${machine_arch}" >&2
      exit 1
      ;;
  esac
}

aws_arch() {
  case "${machine_arch}" in
    x86_64 | amd64)
      echo "x86_64"
      ;;
    aarch64 | arm64)
      echo "aarch64"
      ;;
    *)
      echo "Unsupported AWS CLI architecture: ${machine_arch}" >&2
      exit 1
      ;;
  esac
}

install_terraform_from_zip() {
  local version="${COURSE_TERRAFORM_VERSION:-}"
  local arch
  local tmpdir

  arch="$(terraform_arch)"

  if [[ -z "${version}" ]]; then
    version="$(curl -fsSL https://checkpoint-api.hashicorp.com/v1/check/terraform | sed -n 's/.*"current_version":"\([^"]*\)".*/\1/p')"
  fi

  if [[ -z "${version}" ]]; then
    echo "Could not determine Terraform version. Set COURSE_TERRAFORM_VERSION and retry." >&2
    exit 1
  fi

  tmpdir="$(mktemp -d)"
  curl -fsSL "https://releases.hashicorp.com/terraform/${version}/terraform_${version}_linux_${arch}.zip" -o "${tmpdir}/terraform.zip"
  unzip -q -o "${tmpdir}/terraform.zip" -d "${tmpdir}"
  install -m 0755 "${tmpdir}/terraform" /usr/local/bin/terraform
  rm -rf "${tmpdir}"
}

install_terraform() {
  if command -v terraform >/dev/null 2>&1 && terraform version >/dev/null 2>&1; then
    return 0
  fi

  if [[ "${COURSE_TERRAFORM_INSTALL:-zip}" == "apt" ]]; then
    if [[ ! -r /usr/share/keyrings/hashicorp-archive-keyring.gpg ]]; then
      wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor --yes -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    fi

    # shellcheck disable=SC1091
    . /etc/os-release
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com ${UBUNTU_CODENAME} main" > /etc/apt/sources.list.d/hashicorp.list

    if apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y terraform; then
      return 0
    fi

    echo "Terraform apt install failed; using official release zip instead." >&2
    rm -f /etc/apt/sources.list.d/hashicorp.list
    apt-get update
  fi

  install_terraform_from_zip
}

install_aws_cli() {
  local arch
  local tmpdir

  if command -v aws >/dev/null 2>&1 && aws --version >/dev/null 2>&1; then
    return 0
  fi

  arch="$(aws_arch)"
  tmpdir="$(mktemp -d)"
  curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-${arch}.zip" -o "${tmpdir}/awscliv2.zip"
  unzip -q -o "${tmpdir}/awscliv2.zip" -d "${tmpdir}"
  "${tmpdir}/aws/install" --update -i /usr/local/aws-cli -b /usr/local/bin
  rm -rf "${tmpdir}"
}

install_terraform
install_aws_cli
