#!/usr/bin/env bash
# Apply one Terraform stack from a laptop, after its change is merged.
#
# Usage: scripts/apply.sh <stack-id>
#
# Reads ci/terraform-stacks.json so this wrapper and CI cannot disagree
# about where a stack lives or how it is applied. Refuses to act on a dirty
# checkout, on a checkout that is not at origin/main, or without a typed
# confirmation.

set -euo pipefail

REPO_ROOT=$(git rev-parse --show-toplevel)
REGISTRY="${REPO_ROOT}/ci/terraform-stacks.json"

STACK=${1:-}
if [[ -z "$STACK" ]]; then
    echo "usage: scripts/apply.sh <stack-id>" >&2
    echo >&2
    echo "stacks:" >&2
    python3 -c "
import json, sys
reg = json.load(open('${REGISTRY}'))
for s in reg['stacks']:
    print('  {:<14} {:<10} {}'.format(s['id'], s['apply']['mode'], s['path']))
" >&2
    exit 2
fi

read -r STACK_PATH APPLY_MODE < <(python3 -c "
import json, sys
reg = json.load(open('${REGISTRY}'))
for s in reg['stacks']:
    if s['id'] == '${STACK}':
        print(s['path'], s['apply']['mode'])
        sys.exit(0)
sys.exit(1)
") || { echo "unknown stack: ${STACK}" >&2; exit 2; }

if [[ "$APPLY_MODE" == "automatic" ]]; then
    echo "refusing: ${STACK} is applied by CI on merge. See its OPERATIONS.md" >&2
    echo "for the break-glass procedure if CI apply is unavailable." >&2
    exit 2
fi

PIN=$(python3 -c "import json; print(json.load(open('${REGISTRY}'))['terraform_version'])")
LOCAL_TF=$(terraform version -json | python3 -c "import json,sys; print(json.load(sys.stdin)['terraform_version'])")
if [[ "$LOCAL_TF" != "$PIN" ]]; then
    echo "refusing: terraform ${LOCAL_TF} does not match the pinned ${PIN}." >&2
    exit 2
fi

if [[ -n "$(git -C "$REPO_ROOT" status --porcelain)" ]]; then
    echo "refusing: the checkout has uncommitted changes." >&2
    exit 2
fi

git -C "$REPO_ROOT" fetch --quiet origin main
if [[ "$(git -C "$REPO_ROOT" rev-parse HEAD)" != "$(git -C "$REPO_ROOT" rev-parse origin/main)" ]]; then
    echo "refusing: HEAD is not at origin/main. An apply from stale code is a" >&2
    echo "real risk, not a formality. Update the checkout and try again." >&2
    exit 2
fi

cd "${REPO_ROOT}/${STACK_PATH}"
terraform init -input=false
terraform plan -input=false -out=tfplan

echo
echo "Stack:  ${STACK}"
echo "Path:   ${STACK_PATH}"
echo "Commit: $(git -C "$REPO_ROOT" rev-parse --short HEAD)"
echo
read -r -p 'Type apply to continue: ' CONFIRM
if [[ "$CONFIRM" != "apply" ]]; then
    echo "aborted." >&2
    rm -f tfplan
    exit 2
fi

terraform apply -input=false tfplan
rm -f tfplan

echo
echo "Re-checking for drift."
terraform plan -input=false -detailed-exitcode
