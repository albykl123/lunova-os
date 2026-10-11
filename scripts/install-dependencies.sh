#!/usr/bin/env bash
# ==============================================================================
# Lunova OS 1.0 Aurora - Build Dependencies Installer (Debian 13 Trixie)
# ==============================================================================
set -euo pipefail

echo "=================================================================="
echo "          LUNOVA OS 1.0 AURORA — INSTALL BUILD DEPENDENCIES       "
echo "=================================================================="

if [ "$(id -u)" -ne 0 ]; then
    echo "[-] Error: This script must be run as root (or with sudo)."
    exit 1
fi

echo "[*] Updating package repositories..."
apt-get update -y

echo "[*] Installing Debian live-build toolchain, kernel & image tools..."
DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    live-build \
    debootstrap \
    xorriso \
    isolinux \
    syslinux-efi \
    grub-pc-bin \
    grub-efi-amd64-bin \
    mtools \
    dosfstools \
    squashfs-tools \
    rsync \
    git \
    curl \
    wget \
    ca-certificates

echo "[*] Installing C++, Qt6 & CMake toolchains for Lunova Native Apps..."
DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    qt6-base-dev \
    qt6-declarative-dev \
    qt6-tools-dev \
    libqt6quick6 \
    libqt6network6 \
    qml6-module-qtquick \
    qml6-module-qtquick-controls \
    qml6-module-qtquick-layouts || true

echo "[*] Installing QEMU virtual machine test tools (for verification)..."
DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    qemu-system-x86 \
    qemu-utils \
    ovmf || true

echo "=================================================================="
echo "[+] Build dependencies installed successfully!"
echo "    Next step: sudo ./scripts/configure.sh"
echo "=================================================================="
