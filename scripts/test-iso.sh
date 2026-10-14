#!/usr/bin/env bash
# ==============================================================================
# Lunova OS 1.0 Aurora - Automated Virtual Machine Test Harness
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
DIST_DIR="$ROOT_DIR/dist"
ISO_NAME="Lunova-OS-1.0.1-Aurora-amd64.iso"
ISO_PATH="$DIST_DIR/$ISO_NAME"
TEST_DISK="$ROOT_DIR/test-disk.qcow2"

echo "=================================================================="
echo "          LUNOVA OS 1.0 AURORA — VIRTUAL MACHINE TEST HARNESS     "
echo "=================================================================="

# 1. Verify ISO Existence
if [ ! -f "$ISO_PATH" ]; then
    echo "[-] Error: Lunova OS ISO was not found at: $ISO_PATH"
    echo "[-] Please build the ISO first using: sudo ./scripts/build-iso.sh"
    exit 1
fi

echo "[+] Located ISO: $ISO_PATH ($(stat -c%s "$ISO_PATH") bytes)"

# 2. Check QEMU availability
if ! command -v qemu-system-x86_64 >/dev/null 2>&1; then
    echo "[-] Error: qemu-system-x86_64 is not installed."
    echo "[-] Please install QEMU using: sudo apt-get install qemu-system-x86 ovmf"
    exit 1
fi

# 3. Create disposable test disk if not already present
if [ ! -f "$TEST_DISK" ]; then
    echo "[*] Creating 25 GB disposable QEMU test disk (test-disk.qcow2)..."
    qemu-img create -f qcow2 "$TEST_DISK" 25G
fi

# 4. Check for KVM Hardware Acceleration
KVM_FLAG=""
if [ -e /dev/kvm ] && [ -w /dev/kvm ]; then
    echo "[+] Hardware KVM acceleration is available and enabled."
    KVM_FLAG="-enable-kvm -cpu host"
else
    echo "[!] Warning: /dev/kvm not accessible. Falling back to QEMU TCG software emulation."
    KVM_FLAG="-cpu max"
fi

# 5. Check for UEFI OVMF Firmware
OVMF_OPTS=""
for ovmf_path in \
    /usr/share/OVMF/OVMF_CODE.fd \
    /usr/share/ovmf/OVMF.fd \
    /usr/share/edk2-ovmf/x64/OVMF_CODE.fd; do
    if [ -f "$ovmf_path" ]; then
        echo "[+] Found UEFI OVMF firmware at: $ovmf_path"
        OVMF_OPTS="-bios $ovmf_path"
        break
    fi
done

echo "=================================================================="
echo "          STARTING VIRTUAL MACHINE BOOT VERIFICATION              "
echo "  RAM:     4096 MB"
echo "  SMP:     4 Cores"
echo "  Video:   VirtIO-GPU (High Performance)"
echo "  Audio:   Intel HDA Duplex"
echo "  Network: VirtIO User NAT"
echo "=================================================================="

# Launch QEMU
# shellcheck disable=SC2086
qemu-system-x86_64 \
    $KVM_FLAG \
    $OVMF_OPTS \
    -m 4096 \
    -smp 4 \
    -vga virtio \
    -display default \
    -device virtio-net-pci,netdev=net0 \
    -netdev user,id=net0 \
    -device intel-hda -device hda-duplex \
    -drive file="$TEST_DISK",format=qcow2,if=virtio \
    -cdrom "$ISO_PATH" \
    -boot d

echo "=================================================================="
echo "[+] QEMU Virtual Machine session closed."
echo "=================================================================="
