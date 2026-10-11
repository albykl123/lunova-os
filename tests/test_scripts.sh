#!/usr/bin/env bash
# ==============================================================================
# Lunova OS 1.0 Aurora - Shell Scripts Syntax Validation
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

echo "==> Running Shell Script Syntax Checks..."
FAILED=0

check_syntax() {
    local script="$1"
    if [ -f "$script" ]; then
        if bash -n "$script" 2>/dev/null || sh -n "$script" 2>/dev/null; then
            echo "  [PASS] Syntax OK: $script"
        else
            echo "  [FAIL] Syntax Error in $script"
            FAILED=$((FAILED + 1))
        fi
    fi
}

for s in "$ROOT_DIR"/scripts/*.sh "$ROOT_DIR"/tests/*.sh "$ROOT_DIR"/config/hooks/normal/*.hook.chroot; do
    check_syntax "$s"
done

if [ $FAILED -eq 0 ]; then
    echo "==> All Script Syntax Checks PASSED."
else
    echo "==> Script Checks FAILED with $FAILED errors."
    exit 1
fi
