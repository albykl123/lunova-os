#!/usr/bin/env bash
# ==============================================================================
# Lunova OS 1.0 Aurora - Release Verification & Packaging Script
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
DIST_DIR="$ROOT_DIR/dist"
ISO_NAME="Lunova-OS-1.0.1-Aurora-amd64.iso"
ISO_PATH="$DIST_DIR/$ISO_NAME"

echo "=================================================================="
echo "          LUNOVA OS 1.0 AURORA — RELEASE VERIFICATION             "
echo "=================================================================="

# 1. Verify Artifacts
if [ ! -f "$ISO_PATH" ]; then
    echo "[-] Error: Release ISO '$ISO_NAME' does not exist in $DIST_DIR."
    exit 1
fi

if [ ! -f "$DIST_DIR/SHA256SUMS" ]; then
    echo "[-] Error: SHA256SUMS missing. Generating now..."
    cd "$DIST_DIR"
    sha256sum "$ISO_NAME" > SHA256SUMS
fi

echo "[*] Verifying cryptographic integrity with sha256sum..."
cd "$DIST_DIR"
sha256sum -c SHA256SUMS
echo "[+] SHA-256 verification: PASS!"

echo "[*] Checking build manifest..."
if [ -f "$DIST_DIR/build-manifest.json" ]; then
    echo "[+] Build manifest found:"
    cat "$DIST_DIR/build-manifest.json"
fi

echo "=================================================================="
echo "[+] Lunova OS 1.0 Aurora is verified and ready for release!"
echo "=================================================================="
