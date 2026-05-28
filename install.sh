#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=packages/common.sh
source "${SCRIPT_DIR}/packages/common.sh"

require_root
require_ubuntu

echo "Installing Fields Information Security student workstation tools..."

"${SCRIPT_DIR}/packages/base.sh"
"${SCRIPT_DIR}/packages/python.sh"
"${SCRIPT_DIR}/packages/networking.sh"
"${SCRIPT_DIR}/packages/crypto.sh"
"${SCRIPT_DIR}/packages/dev-languages.sh"
"${SCRIPT_DIR}/packages/desktop-apps.sh"
"${SCRIPT_DIR}/packages/web-tools.sh"
"${SCRIPT_DIR}/packages/cloud-tools.sh"

install -m 0755 "${SCRIPT_DIR}/verify.sh" /usr/local/bin/check-course-environment
install -m 0644 "${SCRIPT_DIR}/tests/expected-tools.txt" /etc/course-expected-tools.txt

USER_NAME="$(target_user)"
if id "${USER_NAME}" >/dev/null 2>&1; then
  install -d -m 0755 -o "${USER_NAME}" -g "${USER_NAME}" "/home/${USER_NAME}/course"
else
  echo "Target user '${USER_NAME}' does not exist; skipped /home/${USER_NAME}/course setup." >&2
fi

echo
echo "Installation complete. Run: check-course-environment"
echo "A logout or reboot may be required before Docker and capture group changes apply."
