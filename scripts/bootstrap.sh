#!/usr/bin/env bash
# ==============================================================================
# Lunova OS 1.0 Aurora - Host Environment Bootstrap & Validation Script
# ==============================================================================
set -euo pipefail

echo "=================================================================="
echo "          LUNOVA OS 1.0 AURORA — HOST ENVIRONMENT BOOTSTRAP       "
echo "=================================================================="

# 1. Architecture Check
ARCH=$(uname -m)
echo "[*] Checking CPU Architecture: $ARCH"
if [ "$ARCH" != "x86_64" ]; then
    echo "[-] Error: Lunova OS 1.0 requires an x86_64 / amd64 build host."
    exit 1
fi
echo "[+] Architecture verified: x86_64"

# 2. Kernel & OS Check
OS=$(uname -s)
echo "[*] Checking Operating System: $OS"
if [ "$OS" != "Linux" ]; then
    echo "[-] Error: ISO generation with live-build requires a native Linux host or Linux container."
    echo "[-] Host is: $OS"
    exit 1
fi

# 3. Privilege Check
echo "[*] Checking User Privileges..."
if [ "$(id -u)" -ne 0 ]; then
    echo "[!] Notice: live-build requires root privileges for chroot and filesystem mounts."
    echo "[!] Please run with sudo or as root: sudo $0"
    exit 1
fi
echo "[+] Root privileges verified."

# 4. Disk Space Check
echo "[*] Checking Available Disk Space..."
AVAILABLE_KB=$(df -k . | awk 'NR==2 {print $4}')
AVAILABLE_GB=$((AVAILABLE_KB / 1024 / 1024))
echo "[*] Available Disk Space: ${AVAILABLE_GB} GB"
if [ "$AVAILABLE_GB" -lt 20 ]; then
    echo "[-] Warning: live-build requires at least 20 GB free disk space (found ${AVAILABLE_GB} GB)."
    exit 1
fi
echo "[+] Disk space verified: ${AVAILABLE_GB} GB available."

# 5. Memory Check
TOTAL_MEM_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
TOTAL_MEM_GB=$((TOTAL_MEM_KB / 1024 / 1024))
echo "[*] Total Physical Memory: ${TOTAL_MEM_GB} GB"
if [ "$TOTAL_MEM_GB" -lt 3 ]; then
    echo "[-] Warning: At least 4 GB RAM recommended for squashing rootfs."
fi

echo "=================================================================="
echo "[+] Host environment bootstrap check PASSED!"
echo "    Ready to install dependencies: sudo ./scripts/install-dependencies.sh"
echo "=================================================================="
