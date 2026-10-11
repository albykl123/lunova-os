# Lunova OS 1.0 Aurora — Technical Architecture

This document describes the architectural layers, system components, and integration topology of Lunova OS.

---

## 1. Architectural Stack Overview

```
┌─────────────────────────────────────────────────────────────┐
│                 LUNOVA DESKTOP APPLICATIONS                 │
│  Lunova Welcome | Lunova About | Control Center | Assistant  │
│  Dolphin | Konsole | Firefox ESR | Kate | Discover | VLC    │
├─────────────────────────────────────────────────────────────┤
│              AURORA GLASS DESKTOP EXPERIENCE                │
│  KDE Plasma 5.27 LTS | KWin Wayland Compositor | SDDM       │
│  Floating Dock | Lunova Launcher | Breeze Theme Engine      │
├─────────────────────────────────────────────────────────────┤
│                 CORE SYSTEM SERVICES & APIS                 │
│  PipeWire & WirePlumber (Audio) | NetworkManager (Network)  │
│  systemd (Init & Process Management) | D-Bus (IPC)          │
│  UDisks2 | UPower | BlueZ | Polkit Security Engine          │
├─────────────────────────────────────────────────────────────┤
│              PACKAGE & SOFTWARE MANAGEMENT                  │
│  APT (Debian Stable Repositories) | Flatpak & Flathub       │
├─────────────────────────────────────────────────────────────┤
│                LINUX KERNEL & HARDWARE STACK                │
│  Linux 6.1 LTS Kernel | Mesa Vulkan/OpenGL Drivers          │
│  Non-free Wireless/Bluetooth Firmware Modules               │
└─────────────────────────────────────────────────────────────┘
```

---

## 2. Core Subsystems

### Base Operating System & Packaging
- **Foundation:** Debian 13 ("Trixie") stable distribution.
- **Kernel:** `linux-image-amd64` (Linux 6.12 LTS).
- **Init System:** `systemd` v252 with `systemd-timesyncd` and `systemd-resolved`.
- **Package Management:** `apt` / `dpkg` with official Debian stable and security mirrors. Flatpak integration enabled by default with Flathub access.

### Display & Graphics
- **Display Server:** Wayland as primary session with XWayland and native X11 fallback.
- **Compositor:** KWin Wayland with hardware-accelerated blur effects, window snapping, and desktop animations.
- **Display Manager:** SDDM themed with `lunova-aurora` (blurred glass card aesthetic).
- **Graphics Acceleration:** Mesa Gallium drivers with Vulkan support for Intel, AMD, and NVIDIA hardware.

### Audio & Connectivity
- **Audio Stack:** PipeWire with WirePlumber session manager, providing PulseAudio and ALSA emulation.
- **Networking:** NetworkManager with `plasma-nm` frontend for Wi-Fi, Ethernet, and VPN connections.
- **Bluetooth:** BlueZ 5 with `bluedevil` tray integration.

### System Installer
- **Installer Engine:** Calamares 3.2+ configured with Lunova branding and automatic UEFI/GPT disk partitioning.
- **Live Bootstrap:** Debian `live-boot` and `live-config` configuring a live user session with passwordless sudo for installation.
