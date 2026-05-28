#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "${SCRIPT_DIR}/common.sh"

require_root
require_ubuntu

install_apt_packages \
  ca-certificates \
  gnupg \
  lsb-release \
  software-properties-common \
  apt-transport-https \
  git \
  curl \
  wget \
  vim \
  nano \
  tmux \
  tree \
  jq \
  pkg-config \
  libssl-dev \
  clang \
  cmake \
  file \
  xxd \
  bsdextrautils \
  whois \
  texlive-latex-base \
  texlive-latex-recommended \
  texlive-latex-extra \
  texlive-fonts-recommended \
  latexmk \
  build-essential \
  openssh-client \
  openssh-server

systemctl enable ssh >/dev/null 2>&1 || true
