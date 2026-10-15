# ==============================================================================
# Lunova OS 1.0.1 - Post-Install Boot Runner (No ISO Attached)
# ==============================================================================
param(
    [string]$Mode = "bios" # Options: "bios" or "uefi"
)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootDir = Split-Path -Parent $ScriptDir

$qemuExe = "C:\Users\alber\.gemini\antigravity\scratch\tools\qemu\qemu-system-x86_64.exe"
$ovmfBios = "C:\Users\alber\.gemini\antigravity\scratch\tools\qemu\share\edk2-x86_64-code.fd"

$diskPath = if ($Mode -eq "uefi") {
    Join-Path $RootDir "tests\vm\lunova-uefi-installed.qcow2"
} else {
    Join-Path $RootDir "tests\vm\lunova-installed.qcow2"
}

if (-not (Test-Path $diskPath)) { throw "Installed virtual disk not found: $diskPath" }

Write-Host "=========================================================="
Write-Host "   Lunova OS 1.0.1 - Post-Install Boot Verification"
Write-Host "=========================================================="
Write-Host "Mode:        $Mode"
Write-Host "Target Disk: $diskPath"
Write-Host "Boot Media:  Hard Disk (No ISO Attached)"
Write-Host "Launching graphical VM window..."

$qemuArgs = @(
    "-m", "4096",
    "-smp", "4",
    "-drive", "file=$diskPath,format=qcow2,if=virtio",
    "-boot", "c",
    "-vga", "virtio",
    "-device", "virtio-net-pci,netdev=net0",
    "-netdev", "user,id=net0"
)

if ($Mode -eq "uefi") {
    $qemuArgs += @("-drive", "if=pflash,format=raw,readonly=on,file=$ovmfBios")
}

Start-Process -FilePath $qemuExe -ArgumentList $qemuArgs
Write-Host "==> QEMU post-install session launched. Verifying GRUB, login, KDE Plasma, networking, and apps."
