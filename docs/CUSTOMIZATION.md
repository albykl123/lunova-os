# Lunova OS Customization Guide

This guide explains how to customize and white-label any aspect of Lunova OS.

---

## 1. Changing the OS Name
- **File:** `config/includes.chroot/etc/os-release`
- Edit the `PRETTY_NAME`, `NAME`, and `ID` fields:
  ```ini
  PRETTY_NAME="My Custom OS 1.0 (Aurora)"
  NAME="My Custom OS"
  ID=myos
  ```
- Also update `config/includes.chroot/etc/issue` and `config/includes.chroot/etc/lsb-release`.

---

## 2. Changing the Logo
- **Source Files:**
  - `branding/logos/lunova-logo-full.svg` (Full branding emblem)
  - `branding/logos/lunova-icon.svg` (Application & launcher icon)
  - `branding/logos/lunova-boot-splash.svg` (Plymouth and SDDM emblem)
  - `branding/logos/lunova-installer.svg` (Calamares header emblem)
- Replace these SVG files with your custom artwork and re-run `make configure`.

---

## 3. Changing the Wallpaper
- **Source Files:**
  - `branding/wallpapers/lunova-aurora-dark.svg`
  - `branding/wallpapers/lunova-aurora-light.svg`
- **Installed Target:**
  - `config/includes.chroot/usr/share/wallpapers/Lunova-Aurora/contents/images/3840x2160.svg`
- Update the default layout script in `config/includes.chroot/usr/share/plasma/look-and-feel/org.lunova.aurora.desktop/contents/layouts/org.kde.plasma.desktop-layout.js` if changing the directory name.

---

## 4. Changing the Desktop Theme & Color Scheme
- **Color Scheme File:**
  - `desktop/themes/LunovaAuroraDark.colors`
  - `config/includes.chroot/usr/share/color-schemes/LunovaAuroraDark.colors`
- Modify the RGB color values (e.g., `BackgroundNormal`, `ForegroundNormal`, `ForegroundActive`).
- **Plasma Look-and-Feel Defaults:**
  - `desktop/plasma/org.lunova.aurora.desktop/contents/defaults`

---

## 5. Changing the Boot Splash (Plymouth)
- **Directory:**
  - `boot/plymouth/theme/`
  - `config/includes.chroot/usr/share/plymouth/themes/lunova-aurora/`
- **Configuration:** `lunova-aurora.plymouth`
- **Script:** `lunova-aurora.script` controls animation, colors, and positioning.

---

## 6. Changing the Login Screen (SDDM)
- **Directory:**
  - `login/sddm/theme/`
  - `config/includes.chroot/usr/share/sddm/themes/lunova-aurora/`
- **Configuration:** `theme.conf` controls background image, accent colors, and font families.
- **QML Source:** `Main.qml` controls the layout of the glass card, user selector, and power buttons.

---

## 7. Changing the Installer Branding (Calamares)
- **Branding Descriptor:**
  - `config/includes.chroot/etc/calamares/branding/lunova/branding.desc`
  - Modify `productName`, `shortProductName`, `version`, `sidebarBackground`, etc.
- **Module Settings:**
  - `config/includes.chroot/etc/calamares/settings.conf`

---

## 8. Changing Default Applications
- **Pinned Dock Applications:**
  - Edit `config/includes.chroot/usr/share/plasma/look-and-feel/org.lunova.aurora.desktop/contents/layouts/org.kde.plasma.desktop-layout.js`
  - In `taskManager.writeConfig("launchers", [...])`, add or remove desktop entry references.
- **Default MIME Associations:**
  - Add `/etc/skel/.config/mimeapps.list` or `/usr/share/applications/mimeapps.list`.

---

## 9. Changing Package Selection
- **Directory:** `config/package-lists/`
- Edit:
  - `lunova-base.list.chroot` (Core utilities, networking, kernel)
  - `lunova-desktop.list.chroot` (Desktop environment & display servers)
  - `lunova-apps.list.chroot` (Default desktop productivity applications)
  - `lunova-drivers.list.chroot` (Firmware and hardware acceleration drivers)
  - `lunova-installer.list.chroot` (Calamares installer packages)

---

## 10. Changing the ISO Version & Name
- **Version File:** `VERSION` (e.g. `1.1.0`)
- **Build Script:** `scripts/build-iso.sh` (Modify `ISO_NAME="Lunova-OS-1.1.0-Aurora-amd64.iso"`)
- **Live-Build Configuration:** `scripts/configure.sh` (Modify `--iso-application` and `--iso-volume`)
