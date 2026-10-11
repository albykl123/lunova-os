# Installing Lunova OS 1.0 Aurora

Lunova OS features a friendly, modern graphical installation powered by Calamares.

---

## 1. Preparing Bootable Media

### Using USB Flash Drive (Rufus on Windows / BalenaEtcher / dd on Linux)
- Flash drive size: Minimum 8 GB
- **On Linux (dd command):**
  ```bash
  sudo dd if=Lunova-OS-1.0.0-Aurora-amd64.iso of=/dev/sdX bs=4M status=progress oflag=sync
  ```
- **On Windows:** Use Rufus with the following settings:
  - Partition scheme: **GPT**
  - Target system: **UEFI (non-CSM)**
  - Write mode: **Write in DD Image mode**

---

## 2. Booting the Live Session

1. Insert the USB drive and power on your computer.
2. Enter your motherboard's boot menu (commonly `F12`, `F11`, `F8`, or `Del`).
3. Select the UEFI boot entry for **Lunova OS 1.0 Aurora**.
4. The GRUB bootloader will appear. Select **Start Lunova OS Live (Aurora Desktop)**.
5. You will boot directly into the Aurora Glass live desktop without needing to enter a password.

---

## 3. Graphical Installation Process

1. On the desktop, double-click the **Install Lunova OS** icon (or launch it from the floating dock).
2. Follow the 8-step Calamares installation wizard:
   - **Language & Region:** Choose your preferred display language.
   - **Timezone:** Select your geographic location.
   - **Keyboard Layout:** Test and configure your physical keyboard map.
   - **Partitioning:**
     - *Erase disk:* Automatically configures GPT, creates 512 MB EFI system partition, and allocates root ext4 partition.
     - *Manual partitioning:* For advanced users wishing to use Btrfs with subvolumes or dual-boot with existing operating systems.
   - **User Setup:** Enter your name, username, computer name, and secure password.
   - **Summary:** Review disk changes before any modifications are written.
   - **Install:** Watch installation progress while the system unpacks and configures hardware drivers.
   - **Finished:** Check "Restart now" and click Done.
3. Remove the USB installation drive when prompted.
4. Enjoy Lunova OS 1.0 Aurora!
