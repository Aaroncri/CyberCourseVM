#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run this script with sudo or as root." >&2
  exit 1
fi

if [[ "${COURSE_UNINSTALL_CONFIRM:-}" != "yes" ]]; then
  cat >&2 <<'EOF'
This removes packages and system files installed by the course environment scripts.

Run with:

  sudo COURSE_UNINSTALL_CONFIRM=yes ./uninstall.sh

To also remove Rust and Lean toolchains from the target user's home directory:

  sudo COURSE_UNINSTALL_CONFIRM=yes COURSE_REMOVE_USER_TOOLCHAINS=yes COURSE_TARGET_USER="$USER" ./uninstall.sh

EOF
  exit 1
fi

target_user() {
  if [[ -n "${COURSE_TARGET_USER:-}" ]]; then
    echo "${COURSE_TARGET_USER}"
  elif [[ -n "${SUDO_USER:-}" && "${SUDO_USER}" != "root" ]]; then
    echo "${SUDO_USER}"
  else
    echo ""
  fi
}

remove_snap_if_installed() {
  local package_name="$1"
  if command -v snap >/dev/null 2>&1 && snap list "${package_name}" >/dev/null 2>&1; then
    snap remove "${package_name}"
  fi
}

apt_remove_if_installed() {
  local packages=("$@")
  local installed=()
  local package_name

  for package_name in "${packages[@]}"; do
    if dpkg-query -W -f='${Status}' "${package_name}" 2>/dev/null | grep -q "install ok installed"; then
      installed+=("${package_name}")
    fi
  done

  if [[ "${#installed[@]}" -gt 0 ]]; then
    DEBIAN_FRONTEND=noninteractive apt-get remove -y "${installed[@]}"
  fi
}

remove_snap_if_installed terraform
remove_snap_if_installed aws-cli
remove_snap_if_installed burpsuite
remove_snap_if_installed zaproxy
remove_snap_if_installed obsidian
remove_snap_if_installed code

rm -f \
  /usr/local/bin/aws \
  /usr/local/bin/terraform \
  /usr/local/bin/burpsuite \
  /usr/local/bin/zaproxy \
  /usr/local/bin/check-course-environment \
  /etc/course-expected-tools.txt \
  /etc/profile.d/course-dev-paths.sh

apt_remove_if_installed \
  john \
  hashcat \
  nginx \
  docker.io \
  docker-compose-v2 \
  wireshark \
  tshark \
  tcpdump \
  nmap \
  netcat-openbsd \
  socat \
  traceroute \
  dnsutils \
  net-tools \
  whois \
  texlive-latex-base \
  texlive-latex-recommended \
  texlive-latex-extra \
  texlive-fonts-recommended \
  latexmk

if [[ "${COURSE_REMOVE_USER_TOOLCHAINS:-}" == "yes" ]]; then
  USER_NAME="$(target_user)"
  if [[ -n "${USER_NAME}" && -d "/home/${USER_NAME}" ]]; then
    sudo -H -u "${USER_NAME}" bash -lc '
      set -euo pipefail
      if [[ -x "$HOME/.cargo/bin/rustup" ]]; then
        "$HOME/.cargo/bin/rustup" self uninstall -y || true
      fi
      if [[ -x "$HOME/.elan/bin/elan" ]]; then
        "$HOME/.elan/bin/elan" self uninstall -y || true
      fi
    '
  fi
fi

apt-get autoremove -y

echo "Course environment uninstall complete."
