# Lunova OS 1.0 Aurora — Quality Assurance & Testing

This document details the automated test harness, verification checklists, and quality assurance procedures for Lunova OS.

---

## 1. Test Execution Commands

```bash
# Run static analysis and configuration linting
make lint

# Run QEMU virtual machine boot verification
make test

# Generate formal QA verification checklist
./tests/test_qemu.sh
```

---

## 2. Test Matrix and Acceptance Criteria

Every release candidate is evaluated against the following 17-point test matrix:

| Test Item | Verification Method | Acceptance Standard |
|---|---|---|
| **1. ISO Integrity** | `sha256sum -c SHA256SUMS` | Cryptographic match against generated digest |
| **2. UEFI Boot** | QEMU + OVMF (`OVMF_CODE.fd`) | GRUB boot menu renders without errors |
| **3. Linux Kernel Startup** | `dmesg` / console log | Linux 6.1 kernel boots without kernel panic |
| **4. KDE Plasma Startup** | Wayland session audit | KWin compositor initializes, desktop shell loads |
| **5. SDDM Login Screen** | Greeter inspection | Glass card renders with user list and power controls |
| **6. Lunova Launcher** | Keyboard `Super` / mouse | Branded Kickoff menu opens with search and categories |
| **7. File Manager (Dolphin)** | App launch | Browse root, home, and removable media places |
| **8. Terminal (Konsole)** | CLI execution | Interactive shell spawns, executes commands |
| **9. Web Browser (Firefox ESR)** | Browser test | Renders modern web pages, privacy settings intact |
| **10. System Settings** | Settings panel | KDE System Settings & Lunova Control Center responsive |
| **11. Networking** | `ping -c 3 deb.debian.org` | NetworkManager DHCP lease obtained, DNS resolves |
| **12. Audio Services** | `wpctl status` | PipeWire and WirePlumber daemons running |
| **13. Calamares Installer** | UI check | "Install Lunova OS" wizard starts with Lunova branding |
| **14. Virtual Disk Install** | 25 GB QEMU disk install | Automated partitioning, squashfs unpack, user creation |
| **15. Post-Install Boot** | Cold reboot without ISO | Installed system boots directly from virtual hard drive |
| **16. User Login** | Credentials test | User created during Calamares setup authenticates |
| **17. Package Management** | `apt update` | Official Debian repositories update and install packages |

---

## 3. Reporting States

In accordance with release rules, each item must be recorded as:
- **PASS:** Fully verified and working as expected.
- **FAIL:** Feature failed execution or produced errors.
- **BLOCKED:** Test cannot be completed due to environment or missing prerequisite.
- **NOT RUN:** Test has not yet been executed in the current environment.
