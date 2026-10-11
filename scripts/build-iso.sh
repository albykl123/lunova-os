#!/usr/bin/env bash
# ==============================================================================
# Lunova OS 1.0 Aurora - Master ISO Build Automation Script
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
DIST_DIR="$ROOT_DIR/dist"
ISO_NAME="Lunova-OS-1.0.0-Aurora-amd64.iso"
TARGET_ISO="$DIST_DIR/$ISO_NAME"
BUILD_LOG="$ROOT_DIR/build.log"

echo "=================================================================="
echo "          LUNOVA OS 1.0 AURORA — MASTER ISO BUILD                 "
echo "=================================================================="

# 1. Environment and Privilege Check
if [ "$(id -u)" -ne 0 ]; then
    echo "[-] Error: ISO generation requires root privileges."
    echo "[-] Please run as root: sudo $0"
    exit 1
fi

if [ "$(uname -s)" != "Linux" ]; then
    echo "[-] Error: ISO build requires a native Linux host."
    exit 1
fi

for cmd in lb xorriso debootstrap mcopy; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "[-] Error: Required build tool '$cmd' is not installed."
        echo "[-] Please run: sudo ./scripts/install-dependencies.sh"
        exit 1
    fi
done

mkdir -p "$DIST_DIR"
cd "$ROOT_DIR"

echo "[*] Step 1: Configuring live-build parameters..."
./scripts/configure.sh

echo "[*] Step 2: Executing live-build (bootstrap -> chroot -> binary)..."
START_TIME=$(date +%s)
BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

if lb build 2>&1 | tee "$BUILD_LOG"; then
    echo "[+] live-build completed successfully."
else
    echo "[-] live-build encountered an error. Inspect $BUILD_LOG for details."
    exit 1
fi

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo "[*] Step 3: Locating generated hybrid ISO artifact..."
BUILT_ISO=$(find "$ROOT_DIR" -maxdepth 1 -name "*.iso" | head -n 1)

if [ -z "$BUILT_ISO" ] || [ ! -f "$BUILT_ISO" ]; then
    echo "[-] Error: Expected ISO file was not found in $ROOT_DIR."
    exit 1
fi

echo "[*] Moving $BUILT_ISO -> $TARGET_ISO..."
mv "$BUILT_ISO" "$TARGET_ISO"

echo "[*] Step 4: Computing SHA-256 cryptographic checksum..."
cd "$DIST_DIR"
sha256sum "$ISO_NAME" > SHA256SUMS
SHA256_HASH=$(awk '{print $1}' SHA256SUMS)
ISO_SIZE_BYTES=$(stat -c%s "$ISO_NAME")
ISO_SIZE_MB=$((ISO_SIZE_BYTES / 1024 / 1024))

echo "[*] Step 5: Generating build manifest (dist/build-manifest.json)..."
cat <<EOF > "$DIST_DIR/build-manifest.json"
{
  "os": {
    "name": "Lunova OS",
    "version": "1.0.0",
    "codename": "Aurora",
    "edition": "Desktop",
    "architecture": "x86_64",
    "base": "Debian GNU/Linux 12 (Bookworm)",
    "desktop": "KDE Plasma 5.27 LTS",
    "displayServer": "Wayland (X11 fallback)",
    "displayManager": "SDDM",
    "installer": "Calamares"
  },
  "build": {
    "timestamp": "$BUILD_DATE",
    "durationSeconds": $DURATION,
    "builder": "Debian live-build"
  },
  "artifact": {
    "filename": "$ISO_NAME",
    "sizeBytes": $ISO_SIZE_BYTES,
    "sizeMB": $ISO_SIZE_MB,
    "sha256": "$SHA256_HASH"
  }
}
EOF

echo "[*] Step 6: Generating build report (dist/build-report.md)..."
cat <<EOF > "$DIST_DIR/build-report.md"
# Lunova OS 1.0 Aurora — Build Report

- **Date:** $BUILD_DATE
- **Target ISO:** \`$ISO_NAME\`
- **Size:** ${ISO_SIZE_MB} MB ($ISO_SIZE_BYTES bytes)
- **SHA-256 Checksum:** \`$SHA256_HASH\`
- **Base Distribution:** Debian GNU/Linux 12 (Bookworm)
- **Desktop Environment:** KDE Plasma with Aurora Glass Design
- **Installer:** Calamares 3.2+
- **Build Duration:** ${DURATION} seconds
- **Status:** **SUCCESS**

## Included Lunova Native Applications:
1. \`lunova-welcome\` (v1.0.0)
2. \`lunova-about\` (v1.0.0)
3. \`lunova-control-center\` (v1.0.0)
4. \`lunova-assistant\` (v1.0.0)
5. \`lunova-update\` (v1.0.0)
EOF

echo "=================================================================="
echo "          BUILD COMPLETE!                                         "
echo "  Artifact: $TARGET_ISO"
echo "  SHA256:   $SHA256_HASH"
echo "  Size:     ${ISO_SIZE_MB} MB"
echo "=================================================================="
