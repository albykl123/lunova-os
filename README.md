# Lunova OS 1.0 — Aurora

<p align="center">
  <img src="branding/logos/lunova-logo-full.svg" alt="Lunova OS Logo" width="180"/>
</p>

<p align="center">
  <b>Beyond the Desktop.</b><br>
  A genuine Debian-based Linux operating system combining Linux freedom, Windows familiarity, and macOS elegance.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Version-1.0.1--Aurora-5478FF?style=flat-square" alt="Version">
  <img src="https://img.shields.io/badge/Base-Debian%2013%20Trixie-D70A53?style=flat-square" alt="Debian">
  <img src="https://img.shields.io/badge/Desktop-KDE%20Plasma%206-1D99F3?style=flat-square" alt="KDE Plasma">
  <img src="https://img.shields.io/badge/Architecture-x86--64-59D9F8?style=flat-square" alt="Architecture">
  <img src="https://img.shields.io/badge/Design-Aurora%20Glass-9270FF?style=flat-square" alt="Aurora Glass">
  <img src="https://img.shields.io/badge/License-GPL--3.0-green?style=flat-square" alt="License">
</p>

---

## 1. Operating System Identity

| Attribute | Specification |
|---|---|
| **Product Name** | Lunova OS |
| **Edition** | Lunova OS Desktop |
| **Version** | 1.0.1 |
| **Codename** | Aurora |
| **Tagline** | *Beyond the Desktop.* |
| **Architecture** | x86-64 / amd64 |
| **Foundation** | Debian GNU/Linux 13 (Trixie) |
| **Desktop Environment** | KDE Plasma 6 |
| **Display Server** | Wayland (with X11 compatibility fallback) |
| **Window Manager** | KWin |
| **Display Manager** | SDDM |
| **System Installer** | Calamares 3.2+ |
| **Bootloader** | GRUB with UEFI and BIOS support |
| **Package Management** | APT + Flatpak (Flathub pre-configured) |
| **ISO Build System** | Debian live-build |
| **Design Language** | Aurora Glass (Midnight Navy, Aurora Blue, Lunar Violet, Electric Cyan) |

---

## 2. Aurora Glass Design Language

Lunova OS introduces the **Aurora Glass** aesthetic:
- **Geometry & Atmosphere:** Translucent interfaces with soft background blur, rounded window corners (16px), and subtle orbital glows.
- **Floating Dock:** Native Plasma floating bottom dock with dynamic auto-hide, category grouping, and active application indicators.
- **Branded Lunova Launcher:** Quick search, category browsing, pin favorites, and power controls.
- **Color Palette:**
  - *Midnight Navy:* `#080D1C`
  - *Deep Space:* `#10182D`
  - *Aurora Blue:* `#5478FF`
  - *Lunar Violet:* `#9270FF`
  - *Electric Cyan:* `#59D9F8`
  - *Soft White:* `#F5F7FF`
  - *Muted Silver:* `#A7B2C9`
- **Typography:** Modern, open-source typefaces configured via fontconfig:
  - Sans-serif: **Inter**
  - Monospace: **JetBrains Mono**
  - Fallback / International: **Noto Sans** & **Noto Color Emoji**

---

## 3. Original Lunova Native Applications (Qt / QML)

Lunova OS ships with five dedicated native applications written in C++ and Qt/QML:

1. **Lunova Welcome (`apps/lunova-welcome`):** Multi-stage onboarding assistant covering desktop customization, network connectivity, software centers, updates, and documentation.
2. **Lunova About (`apps/lunova-about`):** Detailed hardware and software inspector displaying real system parameters (Kernel, KDE Plasma, CPU, RAM, GPU, storage capacity, and licensing details).
3. **Lunova Control Center (`apps/lunova-control-center`):** Unified preferences dashboard integrating audio volume, display brightness, power profiles, and deep links into native KDE settings.
4. **Lunova Assistant (`apps/lunova-assistant`):** Privacy-first desktop AI client supporting local Ollama / Llama.cpp instances or OpenAI-compatible endpoints with secure credential storage and mandatory user approval for system-altering shell commands.
5. **Lunova Update (`apps/lunova-update`):** Streamlined APT update manager communicating via PolicyKit (`pkexec`) for secure, signed system updates with reboot notifications.

---

## 4. Project Structure

```
lunova-os/
├── README.md                      # Project documentation and introduction
├── Makefile                       # Master automation (setup, configure, build, test, release)
├── VERSION                        # Current OS version (1.0.1)
├── CHANGELOG.md                   # Detailed change history
├── .gitignore                     # Git build artifacts ignore list
├── LICENSES/                      # Open-source licenses (GPLv3, LGPLv3, MIT, Debian DFSG)
├── .github/
│   └── workflows/
│       └── build-and-test.yml     # Automated CI/CD pipeline for GitHub Actions
├── config/                        # Debian live-build stack
│   ├── package-lists/             # Package definitions (base, desktop, apps, installer, drivers)
│   ├── includes.chroot/           # Chroot rootfs overlay (/etc/os-release, sddm, plasma themes)
│   ├── includes.binary/           # Binary bootloader overlay (GRUB themes)
│   ├── hooks/normal/              # Chroot customization hooks (branding, calamares, flatpak)
│   └── archives/                  # Debian repository mirror configurations
├── branding/                      # Vector assets & design
│   ├── logos/                     # Geometric SVG logos, icons, and emblems
│   ├── wallpapers/                # 4K Aurora Dark and Aurora Light vector wallpapers
│   ├── icons/                     # Lunova Aurora icon theme specifications
│   ├── cursors/                   # Cursor theme specifications
│   ├── fonts/                     # Fontconfig rules (Inter, JetBrains Mono)
│   └── sounds/                    # Freedesktop sound theme descriptor
├── desktop/                       # Plasma workspace integration
│   ├── plasma/                    # org.lunova.aurora.desktop Look-and-Feel package
│   ├── themes/                    # Aurora Dark and Light color schemes
│   └── layouts/                   # Desktop and floating dock JavaScript automation
├── boot/
│   ├── grub/                      # GRUB bootloader theme (theme.txt, background)
│   └── plymouth/                  # Plymouth boot splash theme and script
├── login/
│   └── sddm/                      # SDDM glass card login theme and QML
├── installer/
│   └── calamares/                 # Calamares installer descriptor and module configs
├── apps/                          # Native C++ / Qt / QML applications
│   ├── lunova-welcome/
│   ├── lunova-about/
│   ├── lunova-control-center/
│   ├── lunova-assistant/
│   └── lunova-update/
├── scripts/                       # Executable engineering scripts
│   ├── bootstrap.sh               # Environment detection and resource verification
│   ├── install-dependencies.sh    # live-build & toolchain package installation
│   ├── configure.sh               # live-build parameters generator
│   ├── build-iso.sh               # Master ISO compilation script
│   ├── test-iso.sh                # QEMU virtual machine test harness
│   └── release.sh                 # Release verification and checksum generator
├── tests/                         # Automated validation and QA checklists
├── upstream/                      # Upstream repository manifest and versions
├── docs/                          # In-depth technical guides
└── dist/                          # Target directory for ISO and release checksums
```

---

## 5. Build and Execution Instructions

### Option A: Building on a Linux Host / Container / VM
```bash
# Verify host system
make check-env

# Install build dependencies
sudo make setup

# Configure Debian live-build
sudo make configure

# Compile the bootable ISO
sudo make build

# Run automated tests in QEMU
make test
```

### Option B: Automated Build via GitHub Actions
A pre-configured GitHub Actions workflow (`.github/workflows/build-and-test.yml`) is included. Pushing this repository to GitHub automatically triggers a build on an `ubuntu-latest` runner with `sudo`, compiles the Qt/QML applications, builds the Debian live ISO, verifies SHA-256 digests, and publishes the ISO as an artifact for download.

---

## 6. Upstream Attribution and Licensing

Lunova OS is proud to be built upon Debian GNU/Linux, the KDE Project, and the Calamares installer.
- Custom Lunova artwork and applications are licensed under GPL-3.0 and MIT.
- Upstream software licenses (GPLv2, GPLv3, LGPLv3, MIT, BSD) are preserved intact in `LICENSES/` and `upstream/manifest.json`.
