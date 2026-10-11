# Lunova OS Release Engineering & Distribution

This document defines the release lifecycle, distribution artifacts, and release verification standards.

---

## 1. Official Release Metadata

- **Product Name:** Lunova OS
- **Version:** 1.0.0
- **Codename:** Aurora
- **Edition:** Lunova OS Desktop
- **Architecture:** x86-64 / amd64
- **Base:** Debian GNU/Linux 12 ("Bookworm")
- **Target ISO File:** `Lunova-OS-1.0.0-Aurora-amd64.iso`

---

## 2. Release Directory Artifacts

Every completed build generates the following files in `dist/`:

| Artifact | Purpose |
|---|---|
| `Lunova-OS-1.0.0-Aurora-amd64.iso` | Bootable hybrid ISO image for USB and DVD media |
| `SHA256SUMS` | Cryptographic SHA-256 checksums file |
| `build-manifest.json` | Detailed JSON machine-readable build metadata |
| `build-report.md` | Human-readable build report and package inventory |

---

## 3. Release Verification Procedure

Before any release artifact is published:
1. Verify SHA-256 checksum:
   ```bash
   sha256sum -c dist/SHA256SUMS
   ```
2. Test UEFI booting in QEMU:
   ```bash
   ./scripts/test-iso.sh
   ```
3. Run the automated QA checklist:
   ```bash
   ./tests/test_qemu.sh
   ```
4. Confirm all upstream attributions and license texts are present in `LICENSES/` and `upstream/manifest.json`.
