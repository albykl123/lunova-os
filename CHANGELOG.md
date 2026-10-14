# Changelog - Lunova OS

All notable changes to the Lunova OS distribution are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.1] - 2026-10-14 - Codename "Aurora (Hardened Release)"

### Security Hardening
- **Lunova Assistant**:
  - Replaced plaintext API key storage in `assistant.conf` with owner-restricted `0600` credential storage in `$XDG_DATA_HOME/lunova/assistant.key`.
  - Eliminated arbitrary `/bin/sh -c` shell invocation for AI actions.
  - Implemented strict allowlisted execution sandbox: only safe, read-only diagnostic utilities (`systemctl status`, `df`, `free`, `uname`, `ip addr`, `uptime`, `lsblk`, `lscpu`, `fastfetch`) without shell metacharacters, piping, or redirections are permitted.
  - Enforced TLS 1.2+ encryption and 15-second network transfer timeouts for all external AI provider connections.
- **Lunova Update**:
  - Eliminated untrusted shell string execution; replaced with structured `QProcess` argument arrays.
  - Switched update mechanism from `dist-upgrade` to non-destructive `upgrade --with-new-pkgs -y` to protect core desktop packages from accidental removal.
  - Added robust detection and recovery advice for interrupted package manager locks (`dpkg --configure -a`).
- **Lunova About**:
  - Replaced `/bin/sh -c` shell pipe GPU detection with direct `lspci` execution and C++ parsing.
  - Updated KDE Plasma fallback baseline to KDE Plasma 6.3+.
- **Lunova Control Center**:
  - Added support for KDE Plasma 6 native `kcmshell6` module launching with `systemsettings` fallback.

### Added & Improved
- Added `udisks2` to core package manifests for automated USB media detection and desktop automounting.
- Added `power-profiles-daemon` and `brightnessctl` for seamless hardware power management and display control.
- Updated all native application versions, build scripts, and installer branding to 1.0.1.

## [1.0.0] - 2026-10-11 - Codename "Aurora"

### Added
- **Base Distribution**: Debian GNU/Linux 13 ("Trixie") stable foundation with Linux 6.12+ kernel (amd64).
- **Desktop Environment**: KDE Plasma 6 / Wayland session with X11 fallback, KWin compositor, and SDDM display manager.
- **Aurora Glass Design Language**:
  - Original geometric Lunova branding (crescent moon, orbital ring, aurora light wave).
  - High-resolution SVG wallpapers in dark and light modes.
  - Custom Lunova Aurora Plasma look-and-feel package (`org.lunova.aurora.desktop`).
  - Floating bottom dock layout with smart auto-hide, category grouping, and active status indicators.
  - Branded Lunova Launcher with rapid fuzzy search, category filtering, and power controls.
  - Aurora Glass color schemes (`LunovaAuroraDark.colors` and `LunovaAuroraLight.colors`).
  - Plymouth boot splash theme (`lunova-aurora`) with smooth orbital spinner.
  - GRUB bootloader theme (`lunova-aurora`) with high-resolution background and iconography.
  - SDDM login theme (`lunova-aurora`) with blurred background and glass card login prompt.
- **Installer**:
  - Calamares 3.2+ graphical installer with Lunova branding and live-environment desktop shortcut.
  - Automated UEFI / GPT and BIOS / MBR partitioning, Btrfs / ext4 filesystem support, and user setup.
  - Hardware clock, locale, and timezone configuration.
- **Applications**:
  - File Manager: Dolphin with customized clean toolbar and Lunova bookmark places.
  - Terminal: Konsole with Aurora dark color scheme and fish/zsh/bash integration.
  - Web Browser: Firefox ESR with privacy defaults.
  - Text Editor: Kate with LSP support and modern editing features.
  - Software Center: KDE Discover with Flatpak and Flathub repository pre-configured.
  - Multimedia: VLC media player, Gwenview image viewer, Okular document viewer.
  - System Utilities: Ark archive tool, Spectacle screenshot utility, KCalc calculator, KDE System Monitor.
- **Original Native Lunova Qt/QML Applications**:
  - `lunova-welcome`: Multi-page onboarding assistant (Overview, Appearance, Connectivity, Software, Updates, Specs, Docs).
  - `lunova-about`: Native hardware & system specification inspector (OS details, Kernel, CPU, RAM, GPU, storage).
  - `lunova-control-center`: Unified dashboard linking KDE System Settings, power profiles, and quick toggles.
  - `lunova-assistant`: Privacy-first desktop assistant client with safe terminal command approvals and configurable endpoints.
  - `lunova-update`: Streamlined APT / PackageKit graphical update manager with transaction safety.
- **Build & Release Automation**:
  - Debian `live-build` configuration scripts (`scripts/configure.sh`, `scripts/build-iso.sh`).
  - Makefile providing `setup`, `configure`, `build`, `test`, and `release` targets.
  - GitHub Actions continuous integration workflow for automated builds on Linux runners.
  - QEMU virtual machine test harness (`scripts/test-iso.sh`).
