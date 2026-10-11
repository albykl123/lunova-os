#!/usr/bin/env bash
# ==============================================================================
# Lunova OS 1.0 Aurora - Configuration Validation Test Suite
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

echo "==> Running Configuration Validation Tests..."
FAILED=0

check_file() {
    local file="$1"
    if [ -f "$file" ]; then
        echo "  [PASS] $file exists"
    else
        echo "  [FAIL] $file missing!"
        FAILED=$((FAILED + 1))
    fi
}

check_contains() {
    local file="$1"
    local string="$2"
    if grep -q "$string" "$file" 2>/dev/null; then
        echo "  [PASS] $file contains '$string'"
    else
        echo "  [FAIL] $file does not contain '$string'!"
        FAILED=$((FAILED + 1))
    fi
}

echo "Testing Package Lists..."
check_file "$ROOT_DIR/config/package-lists/lunova-base.list.chroot"
check_file "$ROOT_DIR/config/package-lists/lunova-desktop.list.chroot"
check_file "$ROOT_DIR/config/package-lists/lunova-apps.list.chroot"
check_file "$ROOT_DIR/config/package-lists/lunova-installer.list.chroot"
check_file "$ROOT_DIR/config/package-lists/lunova-drivers.list.chroot"

check_contains "$ROOT_DIR/config/package-lists/lunova-base.list.chroot" "linux-image-amd64"
check_contains "$ROOT_DIR/config/package-lists/lunova-desktop.list.chroot" "kde-plasma-desktop"
check_contains "$ROOT_DIR/config/package-lists/lunova-desktop.list.chroot" "sddm"
check_contains "$ROOT_DIR/config/package-lists/lunova-apps.list.chroot" "dolphin"
check_contains "$ROOT_DIR/config/package-lists/lunova-installer.list.chroot" "calamares"

echo "Testing /etc/os-release..."
OS_RELEASE="$ROOT_DIR/config/includes.chroot/etc/os-release"
check_file "$OS_RELEASE"
check_contains "$OS_RELEASE" "NAME=\"Lunova OS\""
check_contains "$OS_RELEASE" "VERSION_ID=\"1.0.0\""
check_contains "$OS_RELEASE" "ID_LIKE=debian"

echo "Testing Calamares Configuration..."
check_file "$ROOT_DIR/config/includes.chroot/etc/calamares/settings.conf"
check_file "$ROOT_DIR/config/includes.chroot/etc/calamares/branding/lunova/branding.desc"
check_contains "$ROOT_DIR/config/includes.chroot/etc/calamares/settings.conf" "branding: lunova"
check_contains "$ROOT_DIR/config/includes.chroot/etc/calamares/branding/lunova/branding.desc" "productName:         \"Lunova OS\""

echo "Testing Debian Repository Mirrors..."
check_contains "$ROOT_DIR/config/archives/debian.list.chroot" "trixie"
check_contains "$ROOT_DIR/config/archives/debian.list.binary" "trixie"

if [ $FAILED -eq 0 ]; then
    echo "==> All Configuration Validation Tests PASSED."
else
    echo "==> Configuration Validation FAILED with $FAILED errors."
    exit 1
fi
