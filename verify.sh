#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -n "${COURSE_EXPECTED_TOOLS:-}" ]]; then
  EXPECTED_TOOLS="${COURSE_EXPECTED_TOOLS}"
elif [[ -r /etc/course-expected-tools.txt ]]; then
  EXPECTED_TOOLS="/etc/course-expected-tools.txt"
else
  EXPECTED_TOOLS="${SCRIPT_DIR}/tests/expected-tools.txt"
fi

PASS_COUNT=0
FAIL_COUNT=0
WARN_COUNT=0

pass() {
  printf '[PASS] %s\n' "$1"
  PASS_COUNT=$((PASS_COUNT + 1))
}

fail() {
  printf '[FAIL] %s\n' "$1"
  FAIL_COUNT=$((FAIL_COUNT + 1))
}

warn() {
  printf '[WARN] %s\n' "$1"
  WARN_COUNT=$((WARN_COUNT + 1))
}

check_command() {
  local command_name="$1"
  if command -v "${command_name}" >/dev/null 2>&1; then
    pass "command available: ${command_name}"
  else
    fail "missing command: ${command_name}"
  fi
}

if [[ ! -r "${EXPECTED_TOOLS}" ]]; then
  fail "expected tools file not found: ${EXPECTED_TOOLS}"
else
  while IFS= read -r tool_name; do
    [[ -z "${tool_name}" || "${tool_name}" =~ ^# ]] && continue
    check_command "${tool_name}"
  done < "${EXPECTED_TOOLS}"
fi

if python3 -m venv /tmp/course-venv-check >/dev/null 2>&1; then
  pass "Python virtual environment creation works"
  rm -rf /tmp/course-venv-check
else
  fail "Python virtual environment creation failed"
fi

if systemctl is-enabled ssh >/dev/null 2>&1; then
  pass "SSH service is enabled"
else
  warn "SSH service is not enabled"
fi

if systemctl is-enabled nginx >/dev/null 2>&1; then
  pass "nginx service is enabled"
else
  warn "nginx service is not enabled"
fi

if command -v docker >/dev/null 2>&1; then
  if docker info >/dev/null 2>&1; then
    pass "Docker daemon is reachable"
  else
    warn "Docker command exists, but daemon is not reachable by this user; log out and back in after install"
  fi
fi

if command -v terraform >/dev/null 2>&1; then
  terraform version >/dev/null 2>&1 && pass "Terraform executes" || fail "Terraform command failed"
fi

if command -v aws >/dev/null 2>&1; then
  aws --version >/dev/null 2>&1 && pass "AWS CLI executes" || fail "AWS CLI command failed"
fi

if command -v zaproxy >/dev/null 2>&1 || command -v burpsuite >/dev/null 2>&1; then
  pass "web-security proxy command is available"
else
  warn "no ZAP or Burp command found; this is expected only if web proxy installation was skipped"
fi

echo
printf 'Summary: %d passed, %d warning(s), %d failed\n' "${PASS_COUNT}" "${WARN_COUNT}" "${FAIL_COUNT}"

if [[ "${FAIL_COUNT}" -ne 0 ]]; then
  exit 1
fi
