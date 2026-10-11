#!/usr/bin/env bash
# ==============================================================================
# Lunova OS 1.0 Aurora - Branding & Assets Validation Test Suite
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

echo "==> Running Branding & Asset Validation Tests..."
FAILED=0

check_svg() {
    local file="$1"
    if [ -f "$file" ]; then
        if grep -q "<svg" "$file" && grep -q "</svg>" "$file"; then
            echo "  [PASS] SVG Valid: $file"
        else
            echo "  [FAIL] SVG Corrupted: $file"
            FAILED=$((FAILED + 1))
        fi
    else
        echo "  [FAIL] Missing file: $file"
        FAILED=$((FAILED + 1))
    fi
}

echo "Testing Logo Assets..."
check_svg "$ROOT_DIR/branding/logos/lunova-logo-full.svg"
check_svg "$ROOT_DIR/branding/logos/lunova-logo-monochrome-dark.svg"
check_svg "$ROOT_DIR/branding/logos/lunova-logo-monochrome-light.svg"
check_svg "$ROOT_DIR/branding/logos/lunova-icon.svg"
check_svg "$ROOT_DIR/branding/logos/lunova-boot-splash.svg"
check_svg "$ROOT_DIR/branding/logos/lunova-installer.svg"

echo "Testing Wallpaper Assets..."
check_svg "$ROOT_DIR/branding/wallpapers/lunova-aurora-dark.svg"
check_svg "$ROOT_DIR/branding/wallpapers/lunova-aurora-light.svg"

echo "Testing Theme & Sound Specifications..."
if [ -f "$ROOT_DIR/desktop/themes/LunovaAuroraDark.colors" ]; then
    echo "  [PASS] Aurora Dark color scheme present"
else
    echo "  [FAIL] Aurora Dark color scheme missing"
    FAILED=$((FAILED + 1))
fi

if [ -f "$ROOT_DIR/boot/plymouth/theme/lunova-aurora.plymouth" ]; then
    echo "  [PASS] Plymouth theme present"
else
    echo "  [FAIL] Plymouth theme missing"
    FAILED=$((FAILED + 1))
fi

if [ -f "$ROOT_DIR/boot/grub/theme/theme.txt" ]; then
    echo "  [PASS] GRUB theme present"
else
    echo "  [FAIL] GRUB theme missing"
    FAILED=$((FAILED + 1))
fi

if [ $FAILED -eq 0 ]; then
    echo "==> All Branding & Asset Validation Tests PASSED."
else
    echo "==> Branding Validation FAILED with $FAILED errors."
    exit 1
fi
