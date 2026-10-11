# Building Lunova OS 1.0 Aurora

This guide provides complete, reproducible instructions for building the bootable Lunova OS live hybrid ISO image (`Lunova-OS-1.0.0-Aurora-amd64.iso`).

---

## 1. Prerequisites and Build Host Requirements

Building a genuine Debian live ISO requires:
- **Architecture:** x86-64 / amd64
- **Operating System:** Native Debian GNU/Linux 13 (Trixie), Ubuntu 24.04 LTS+, or a Linux container/VM with root privileges
- **Storage:** At least 25 GB free disk space
- **Memory:** 4 GB RAM minimum (8 GB recommended)
- **Privileges:** `root` or `sudo` access (required for `debootstrap`, `chroot`, loop devices, and filesystem overlay mounting)

> **Important Note for Windows / macOS Users:**
> Building a live ISO involves low-level Linux kernel operations (`mknod`, ext4/squashfs block generation, chroot environments). You can build Lunova OS using:
> 1. The automated GitHub Actions workflow (`.github/workflows/build-and-test.yml`), which executes on Ubuntu runners.
> 2. A WSL2 Linux instance with systemd enabled and root access.
> 3. A dedicated Debian or Ubuntu virtual machine (VirtualBox, VMware, or QEMU).

---

## 2. Automated One-Command Build

The fastest way to build the complete operating system is using the Makefile:

```bash
# 1. Inspect host environment and verify dependencies
make check-env

# 2. Install live-build, debootstrap, xorriso, and Qt5 development packages
sudo make setup

# 3. Configure the Debian live-build stack
sudo make configure

# 4. Generate the hybrid bootable ISO
sudo make build
```

The resulting ISO and cryptographic checksums will be placed in `dist/`:
- `dist/Lunova-OS-1.0.0-Aurora-amd64.iso`
- `dist/SHA256SUMS`
- `dist/build-manifest.json`
- `dist/build-report.md`

---

## 3. Manual Step-by-Step Compilation

If you prefer to run the scripts directly:

### Step 1: Install Build Tools
```bash
sudo ./scripts/install-dependencies.sh
```

### Step 2: Configure Live-Build
```bash
sudo ./scripts/configure.sh
```
This runs `lb config` targeting Debian 13 Trixie, amd64, Linux 6.12 kernel, KDE Plasma desktop, and synchronizes the Lunova chroot overlays and package lists.

### Step 3: Run the Live Build
```bash
sudo ./scripts/build-iso.sh
```
This builds the root squashfs, builds the native Qt/QML applications, configures the UEFI GRUB stub, and packages the hybrid ISO.

---

## 4. Verification and Checksums

Verify the cryptographic SHA-256 integrity of the compiled ISO:
```bash
cd dist
sha256sum -c SHA256SUMS
```

---

## 5. Cleaning the Build Tree

To purge cached packages and intermediate chroot states:
```bash
sudo make clean
```
