#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "${SCRIPT_DIR}/common.sh"

require_root
require_ubuntu

install_snap_package terraform --classic
install_snap_package aws-cli --classic

if [[ -x /snap/bin/terraform ]]; then
  ln -sf /snap/bin/terraform /usr/local/bin/terraform
else
  cat > /usr/local/bin/terraform <<'EOF'
#!/usr/bin/env sh
exec snap run terraform "$@"
EOF
  chmod 0755 /usr/local/bin/terraform
fi

if [[ -x /snap/bin/aws ]]; then
  ln -sf /snap/bin/aws /usr/local/bin/aws
elif snap run aws-cli.aws --version >/dev/null 2>&1; then
  cat > /usr/local/bin/aws <<'EOF'
#!/usr/bin/env sh
exec snap run aws-cli.aws "$@"
EOF
  chmod 0755 /usr/local/bin/aws
else
  cat > /usr/local/bin/aws <<'EOF'
#!/usr/bin/env sh
exec snap run aws-cli "$@"
EOF
  chmod 0755 /usr/local/bin/aws
fi

/usr/local/bin/terraform version >/dev/null
/usr/local/bin/aws --version >/dev/null
