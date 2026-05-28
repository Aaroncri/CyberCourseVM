#!/usr/bin/env bash
set -euo pipefail

echo "== user =="
id

echo
echo "== os =="
if [[ -r /etc/os-release ]]; then
  cat /etc/os-release
else
  echo "/etc/os-release not found"
fi

echo
echo "== snap command =="
if command -v snap >/dev/null 2>&1; then
  command -v snap
  snap version || true
else
  echo "snap not found"
fi

echo
echo "== snapd services =="
systemctl --no-pager --full status snapd.service snapd.socket 2>&1 || true

echo
echo "== snap changes =="
if command -v snap >/dev/null 2>&1; then
  snap changes || true
fi

echo
echo "== installed target snaps =="
if command -v snap >/dev/null 2>&1; then
  snap list terraform aws-cli burpsuite zaproxy 2>&1 || true
fi

echo
echo "== expected binaries =="
ls -l /snap/bin/terraform /snap/bin/aws /snap/bin/burpsuite /snap/bin/zaproxy 2>&1 || true

echo
echo "== command lookup =="
command -v terraform || true
command -v aws || true
command -v burpsuite || true
command -v zaproxy || true
