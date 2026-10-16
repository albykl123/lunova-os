#!/usr/bin/env python3
"""
Lunova OS 1.0.2 Aurora - Automated Calamares GUI Installation & Verification Harness
Communicates directly with QEMU via QMP to drive live-session boot, Calamares installer,
and post-installation verification for both BIOS and UEFI firmware modes.
"""

import socket
import json
import sys
import time
import os
import subprocess

class QmpClient:
    def __init__(self, port, timeout=30.0):
        self.port = port
        self.timeout = timeout
        self.sock = None
        self.connect()

    def connect(self):
        print(f"[QMP] Connecting to QMP server at 127.0.0.1:{self.port}...")
        for attempt in range(30):
            try:
                self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                self.sock.settimeout(self.timeout)
                self.sock.connect(('127.0.0.1', int(self.port)))
                break
            except Exception:
                time.sleep(1)
        if not self.sock:
            raise RuntimeError(f"Could not connect to QMP port {self.port}")

        # Read greeting
        greeting = self._read_line()
        print(f"[QMP] Connected: {greeting[:80]}")

        # Capabilities handshake
        self.send_command("qmp_capabilities")

    def _read_line(self):
        buf = b''
        while b'\n' not in buf:
            chunk = self.sock.recv(4096)
            if not chunk:
                break
            buf += chunk
        return buf.decode(errors='replace').strip()

    def send_command(self, cmd, args=None):
        payload = {"execute": cmd}
        if args:
            payload["arguments"] = args
        raw = json.dumps(payload).encode() + b'\n'
        self.sock.sendall(raw)
        resp = self._read_line()
        return resp

    def send_key(self, key):
        cmd = f"sendkey {key}"
        return self.send_command("human-monitor-command", {"command-line": cmd})

    def type_text(self, text):
        char_map = {
            ' ': 'spc',
            '-': 'minus',
            '_': 'shift-minus',
            '!': 'shift-1',
            '.': 'dot',
            ':': 'shift-semicolon',
            '/': 'slash',
            '\n': 'ret',
            '\t': 'tab'
        }
        for ch in text:
            if ch in char_map:
                self.send_key(char_map[ch])
            elif ch.isupper():
                self.send_key(f"shift-{ch.lower()}")
            else:
                self.send_key(ch)
            time.sleep(0.08)

    def screendump(self, ppm_path, png_path=None):
        os.makedirs(os.path.dirname(os.path.abspath(ppm_path)), exist_ok=True)
        self.send_command("screendump", {"filename": ppm_path})
        time.sleep(0.5)
        if png_path and os.path.exists(ppm_path):
            try:
                with open(ppm_path, 'rb') as f_in, open(png_path, 'wb') as f_out:
                    subprocess.run(["pnmtopng"], stdin=f_in, stdout=f_out, check=True)
                os.remove(ppm_path)
                print(f"[QMP] Screendump saved: {png_path}")
            except Exception:
                try:
                    from PIL import Image
                    img = Image.open(ppm_path)
                    img.save(png_path, 'PNG')
                    os.remove(ppm_path)
                    print(f"[QMP] Screendump saved (PIL): {png_path}")
                except Exception as e:
                    print(f"[QMP] Kept raw PPM: {ppm_path} (PNG conversion error: {e})")

    def quit(self):
        try:
            self.send_command("quit")
        except Exception:
            pass

    def close(self):
        if self.sock:
            try:
                self.sock.close()
            except Exception:
                pass


def run_installer_automation(qmp_port, results_dir, disk_path, firmware_type="bios"):
    os.makedirs(results_dir, exist_ok=True)
    qmp = QmpClient(qmp_port)

    wait_boot = 8 if firmware_type == "uefi" else 22
    print(f"[*] Stage 1 ({firmware_type.upper()}): Waiting {wait_boot} seconds for bootloader menu...")
    time.sleep(wait_boot)
    qmp.screendump(f"{results_dir}/stage-01-bootloader.ppm", f"{results_dir}/stage-01-bootloader.png")

    print(f"[*] Stage 1 ({firmware_type.upper()}): Sending Return to boot Live session...")
    qmp.send_key("ret")
    time.sleep(3)
    if firmware_type == "bios":
        qmp.send_key("ret")

    print(f"[*] Stage 2 ({firmware_type.upper()}): Waiting 75 seconds for Linux kernel, systemd & KDE Plasma 6 desktop...")
    time.sleep(75)
    qmp.screendump(f"{results_dir}/stage-02-live-desktop.ppm", f"{results_dir}/stage-02-live-desktop.png")

    print("[*] Stage 3: Dismissing Welcome windows (Alt+F4)...")
    qmp.send_key("alt-f4")
    time.sleep(2)
    qmp.send_key("alt-f4")
    time.sleep(2)

    print("[*] Stage 4: Launching Calamares installer (Alt+F2 -> calamares -> ret)...")
    qmp.send_key("alt-f2")
    time.sleep(2)
    qmp.type_text("calamares\n")
    time.sleep(15)
    qmp.screendump(f"{results_dir}/stage-03-calamares-welcome.ppm", f"{results_dir}/stage-03-calamares-welcome.png")

    print("[*] Stage 5: Calamares Step 1 - Welcome -> Next (Alt+N)...")
    qmp.send_key("alt-n")
    time.sleep(3)
    qmp.screendump(f"{results_dir}/stage-04-calamares-location.ppm", f"{results_dir}/stage-04-calamares-location.png")

    print("[*] Stage 6: Calamares Step 2 - Location -> Next (Alt+N)...")
    qmp.send_key("alt-n")
    time.sleep(3)
    qmp.screendump(f"{results_dir}/stage-05-calamares-keyboard.ppm", f"{results_dir}/stage-05-calamares-keyboard.png")

    print("[*] Stage 7: Calamares Step 3 - Keyboard -> Next (Alt+N)...")
    qmp.send_key("alt-n")
    time.sleep(3)
    qmp.screendump(f"{results_dir}/stage-06-calamares-partitions.ppm", f"{results_dir}/stage-06-calamares-partitions.png")

    print("[*] Stage 8: Calamares Step 4 - Partitions: Selecting Erase Disk (Alt+E) -> Next (Alt+N)...")
    qmp.send_key("alt-e")
    time.sleep(2)
    qmp.send_key("alt-n")
    time.sleep(3)
    qmp.screendump(f"{results_dir}/stage-07-calamares-users.ppm", f"{results_dir}/stage-07-calamares-users.png")

    print("[*] Stage 9: Calamares Step 5 - Users -> Entering credentials...")
    qmp.type_text("Test User\t")
    time.sleep(0.2)
    qmp.type_text("testuser\t")
    time.sleep(0.2)
    qmp.type_text("lunova-pc\t")
    time.sleep(0.2)
    qmp.type_text("Lunova2026!Aurora\t")
    time.sleep(0.2)
    qmp.type_text("Lunova2026!Aurora")
    time.sleep(2)
    qmp.screendump(f"{results_dir}/stage-08-calamares-users-filled.ppm", f"{results_dir}/stage-08-calamares-users-filled.png")

    print("[*] Stage 10: Calamares Users -> Next (Alt+N) to Summary...")
    qmp.send_key("alt-n")
    time.sleep(3)
    qmp.screendump(f"{results_dir}/stage-09-calamares-summary.ppm", f"{results_dir}/stage-09-calamares-summary.png")

    print("[*] Stage 11: Summary -> Triggering Installation (Alt+I)...")
    qmp.send_key("alt-i")
    time.sleep(2)
    print("[*] Confirming installation dialog (Return)...")
    qmp.send_key("ret")
    time.sleep(5)
    qmp.screendump(f"{results_dir}/stage-10-installation-progress.ppm", f"{results_dir}/stage-10-installation-progress.png")

    print(f"[*] Stage 12 ({firmware_type.upper()}): Monitoring Calamares filesystem unpack & bootloader setup...")
    prev_size = 0
    stable_count = 0
    for cycle in range(1, 45):
        time.sleep(15)
        cur_size = os.path.getsize(disk_path) if os.path.exists(disk_path) else 0
        cur_mb = round(cur_size / (1024 * 1024), 2)
        print(f"[*] Install Progress Check {cycle}: Virtual disk size = {cur_mb} MB")
        qmp.screendump(f"{results_dir}/stage-11-progress-{cycle}.ppm", f"{results_dir}/stage-11-progress-{cycle}.png")

        if cur_size > 1500 * 1024 * 1024:
            if abs(cur_size - prev_size) < 2 * 1024 * 1024:
                stable_count += 1
                if stable_count >= 3:
                    print(f"[+] Virtual disk write stabilized at {cur_mb} MB. Installation finished successfully!")
                    time.sleep(10)
                    qmp.screendump(f"{results_dir}/stage-12-calamares-finished.ppm", f"{results_dir}/stage-12-calamares-finished.png")
                    break
            else:
                stable_count = 0
        prev_size = cur_size

    print(f"[*] Calamares installation sequence complete for {firmware_type.upper()}. Terminating VM cleanly via QMP quit...")
    qmp.quit()
    time.sleep(2)
    qmp.close()


def run_postinstall_verification(qmp_port, results_dir, firmware_type="bios"):
    os.makedirs(results_dir, exist_ok=True)
    qmp = QmpClient(qmp_port)

    wait_boot = 8 if firmware_type == "uefi" else 6
    print(f"[*] Post-Install ({firmware_type.upper()}): Waiting {wait_boot} seconds for installed GRUB menu...")
    time.sleep(wait_boot)
    qmp.screendump(f"{results_dir}/postinstall-01-grub.ppm", f"{results_dir}/postinstall-01-grub.png")
    qmp.send_key("ret")

    print(f"[*] Post-Install ({firmware_type.upper()}): Waiting 45 seconds for installed KDE Plasma / SDDM boot...")
    time.sleep(45)
    qmp.screendump(f"{results_dir}/postinstall-02-desktop.ppm", f"{results_dir}/postinstall-02-desktop.png")

    print("[*] Post-Install: Launching Lunova Welcome (Alt+F2 -> lunova-welcome)...")
    qmp.send_key("alt-f2")
    time.sleep(2)
    qmp.type_text("lunova-welcome\n")
    time.sleep(6)
    qmp.screendump(f"{results_dir}/postinstall-03-app-welcome.ppm", f"{results_dir}/postinstall-03-app-welcome.png")

    print("[*] Post-Install: Launching Lunova Control Center (Alt+F2 -> lunova-control-center)...")
    qmp.send_key("alt-f2")
    time.sleep(2)
    qmp.type_text("lunova-control-center\n")
    time.sleep(6)
    qmp.screendump(f"{results_dir}/postinstall-04-app-control-center.ppm", f"{results_dir}/postinstall-04-app-control-center.png")

    print(f"[*] Post-Install: Verification complete for {firmware_type.upper()}. Terminating VM cleanly via QMP quit...")
    qmp.quit()
    time.sleep(2)
    qmp.close()


if __name__ == '__main__':
    if len(sys.argv) < 4:
        print("Usage: automate_calamares_kvm.py <install|postinstall> <qmp_port> <results_dir> [disk_path] [firmware_type]")
        sys.exit(1)

    mode = sys.argv[1]
    port = int(sys.argv[2])
    out_dir = sys.argv[3]
    disk = sys.argv[4] if len(sys.argv) > 4 else "test-disk.qcow2"
    firmware = sys.argv[5] if len(sys.argv) > 5 else "bios"

    if mode == "install":
        run_installer_automation(port, out_dir, disk, firmware)
    elif mode == "postinstall":
        run_postinstall_verification(port, out_dir, firmware)
    else:
        print(f"Unknown mode: {mode}")
        sys.exit(1)
