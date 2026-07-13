#!/usr/bin/env bash
# Definition of Done for WP-07: a second playbook run must report changed=0.
# Runs the playbook twice and fails if the second run changed anything.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "── First run ──────────────────────────────────────────"
"${REPO_ROOT}/scripts/deploy.sh" "$@"

echo "── Second run (must be changed=0) ─────────────────────"
OUTPUT="$("${REPO_ROOT}/scripts/deploy.sh" "$@" | tee /dev/stderr)"

if echo "${OUTPUT}" | grep -qE 'changed=[1-9]'; then
  echo "FAIL: playbook is NOT idempotent (risk R5)" >&2
  exit 1
fi
echo "OK: playbook is idempotent (changed=0 on second run)"
