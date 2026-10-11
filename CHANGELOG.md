# Changelog - Lunova OS

All notable changes to the Lunova OS distribution are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
