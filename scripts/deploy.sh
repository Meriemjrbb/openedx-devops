#!/usr/bin/env bash
# Deploy Open edX to the target VM with Ansible.
# Usage: ./scripts/deploy.sh [extra ansible-playbook args...]
# Requires: .env at repo root (OPENEDX_VM_HOST, OPENEDX_VM_USER).
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ -f "${REPO_ROOT}/.env" ]]; then
  set -a
  # shellcheck disable=SC1091
  source "${REPO_ROOT}/.env"
  set +a
else
  echo "ERROR: ${REPO_ROOT}/.env not found (see README for required variables)" >&2
  exit 1
fi

cd "${REPO_ROOT}/ansible"
ansible-galaxy collection install -r requirements.yml >/dev/null
exec ansible-playbook site.yml "$@"
