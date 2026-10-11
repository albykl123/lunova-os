#!/usr/bin/env bash
# ==============================================================================
# Lunova OS 1.0 Aurora - Live-Build Configuration Generator (Debian 13 Trixie)
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

echo "=================================================================="
echo "          LUNOVA OS 1.0 AURORA — CONFIGURE LIVE-BUILD             "
echo "               Foundation: Debian 13 (Trixie)                     "
echo "=================================================================="

if [ "$(id -u)" -ne 0 ]; then
    echo "[-] Error: This script must be run as root (or with sudo)."
    exit 1
fi

cd "$ROOT_DIR"

echo "[*] Cleaning any previous live-build state..."
lb clean --purge || true

echo "[*] Initializing Debian live-build for Lunova OS (Debian 13 Trixie, amd64)..."
lb config \
    --mode debian \
    --system live \
    --distribution trixie \
    --parent-distribution trixie \
    --architecture amd64 \
    --archive-areas "main contrib non-free non-free-firmware" \
    --binary-images iso-hybrid \
    --bootloaders "grub-efi,syslinux" \
    --bootappend-live "boot=live components quiet splash username=live hostname=lunova-live" \
    --iso-application "Lunova OS 1.0 Aurora" \
    --iso-publisher "Lunova OS Engineering Team" \
    --iso-volume "LUNOVA_1_0_0" \
    --linux-packages "linux-image linux-headers" \
    --linux-flavours amd64 \
    --memtest none \
    --win32-loader false \
    --apt-indices false \
    --apt-recommends true \
    --security true \
    --updates true

echo "[*] Synchronizing Lunova configurations to live-build..."
mkdir -p "$ROOT_DIR/config/package-lists"
mkdir -p "$ROOT_DIR/config/archives"
mkdir -p "$ROOT_DIR/config/includes.chroot"
mkdir -p "$ROOT_DIR/config/includes.binary"
mkdir -p "$ROOT_DIR/config/hooks/normal"

echo "[*] Packaging Lunova applications for chroot build..."
mkdir -p "$ROOT_DIR/config/includes.chroot/tmp/lunova-apps"
cp -r "$ROOT_DIR/apps/"* "$ROOT_DIR/config/includes.chroot/tmp/lunova-apps/"

echo "=================================================================="
echo "[+] Lunova OS live-build configuration complete!"
echo "    Ready to build ISO: sudo ./scripts/build-iso.sh"
echo "=================================================================="
