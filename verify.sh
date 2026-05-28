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
  local candidate

  if candidate="$(command -v "${command_name}" 2>/dev/null)"; then
    pass "command available: ${command_name} (${candidate})"
    return 0
  fi

  for candidate in \
    "/snap/bin/${command_name}" \
    "${HOME}/.cargo/bin/${command_name}" \
    "${HOME}/.elan/bin/${command_name}"; do
    if [[ -x "${candidate}" ]]; then
      pass "command available: ${command_name} (${candidate})"
      return 0
    fi
  done

  if [[ "${command_name}" == "burpsuite" ]]; then
    for candidate in /snap/bin/burpsuite /snap/bin/burp-suite; do
      if [[ -x "${candidate}" ]]; then
        pass "command available: ${command_name} (${candidate})"
        return 0
      fi
    done
  fi

  if [[ "${command_name}" == "aws" ]]; then
    for candidate in /snap/bin/aws /snap/bin/aws-cli; do
      if [[ -x "${candidate}" ]]; then
        pass "command available: ${command_name} (${candidate})"
        return 0
      fi
    done
  fi

  if [[ "${command_name}" == "terraform" ]]; then
    for candidate in /snap/bin/terraform; do
      if [[ -x "${candidate}" ]]; then
        pass "command available: ${command_name} (${candidate})"
        return 0
      fi
    done
  fi

  fail "missing command: ${command_name}"
}

run_tool() {
  local command_name="$1"
  shift
  local candidate

  if candidate="$(command -v "${command_name}" 2>/dev/null)"; then
    "${candidate}" "$@"
    return $?
  fi

  for candidate in \
    "/snap/bin/${command_name}" \
    "${HOME}/.cargo/bin/${command_name}" \
    "${HOME}/.elan/bin/${command_name}"; do
    if [[ -x "${candidate}" ]]; then
      "${candidate}" "$@"
      return $?
    fi
  done

  return 127
}

check_any_command() {
  local display_name="$1"
  shift
  local command_name

  for command_name in "$@"; do
    if command -v "${command_name}" >/dev/null 2>&1 || [[ -x "/snap/bin/${command_name}" ]]; then
      pass "command available: ${display_name} (${command_name})"
      return 0
    fi
  done

  fail "missing command: ${display_name}"
}

check_standard_command() {
  local command_name="$1"
  if [[ "${command_name}" == "burpsuite" ]]; then
    check_any_command "burpsuite" burpsuite burp-suite
  elif [[ "${command_name}" == "aws" ]]; then
    check_any_command "aws" aws aws-cli
  else
    check_command "${command_name}"
  fi
}

check_web_proxy() {
  if command -v zaproxy >/dev/null 2>&1 || [[ -x /snap/bin/zaproxy ]]; then
    pass "ZAP command is available"
  else
    warn "ZAP command was not found"
  fi

  if command -v burpsuite >/dev/null 2>&1 || [[ -x /snap/bin/burpsuite ]] || [[ -x /snap/bin/burp-suite ]]; then
    pass "Burp Suite command is available"
  else
    fail "Burp Suite command was not found"
  fi
}

if [[ ! -r "${EXPECTED_TOOLS}" ]]; then
  fail "expected tools file not found: ${EXPECTED_TOOLS}"
else
  while IFS= read -r tool_name; do
    [[ -z "${tool_name}" || "${tool_name}" =~ ^# ]] && continue
    check_standard_command "${tool_name}"
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

if run_tool terraform version >/dev/null 2>&1; then
  pass "Terraform executes"
elif command -v terraform >/dev/null 2>&1 || [[ -x /snap/bin/terraform ]]; then
  fail "Terraform command failed"
fi

if run_tool aws --version >/dev/null 2>&1 || run_tool aws-cli --version >/dev/null 2>&1; then
  pass "AWS CLI executes"
elif command -v aws >/dev/null 2>&1 || command -v aws-cli >/dev/null 2>&1 || [[ -x /snap/bin/aws ]] || [[ -x /snap/bin/aws-cli ]]; then
  fail "AWS CLI command failed"
fi

check_web_proxy

echo
printf 'Summary: %d passed, %d warning(s), %d failed\n' "${PASS_COUNT}" "${WARN_COUNT}" "${FAIL_COUNT}"

if [[ "${FAIL_COUNT}" -ne 0 ]]; then
  exit 1
fi
