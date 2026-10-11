#!/usr/bin/env bash
# ==============================================================================
# Lunova OS 1.0 Aurora - Containerized ISO Build Script (Debian 13 Trixie)
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

echo "=================================================================="
echo "      LUNOVA OS 1.0 AURORA — CONTAINERIZED DEBIAN BUILD           "
echo "=================================================================="

echo "[*] Updating apt package lists and installing build tools..."
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y --no-install-recommends \
    live-build \
    debootstrap \
    debian-archive-keyring \
    debian-keyring \
    xorriso \
    isolinux \
    syslinux-efi \
    grub-pc-bin \
    grub-efi-amd64-bin \
    mtools \
    dosfstools \
    squashfs-tools \
    dos2unix \
    ca-certificates

cd "$ROOT_DIR"

echo "[*] Normalizing file line endings..."
find . -name "*.sh" -exec dos2unix {} +
find . -name "*.hook.chroot" -exec dos2unix {} +
chmod +x scripts/*.sh tests/*.sh config/hooks/normal/*.hook.chroot

echo "[*] Launching Master ISO Build..."
./scripts/build-iso.sh
