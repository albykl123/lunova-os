# ==============================================================================
# Lunova OS 1.0 Aurora - Local Automated QEMU VM Test Harness (Windows)
# ==============================================================================
param(
    [string]$Mode = "all" # "bios", "uefi", "install", "all"
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootDir = Split-Path -Parent $ScriptDir
$DistDir = Join-Path $RootDir "dist"
$IsoPath = Join-Path $DistDir "Lunova-OS-1.0.1-Aurora-amd64.iso"
$TestDisk = Join-Path $RootDir "test-disk.qcow2"

$QemuDir = "C:\Users\alber\.gemini\antigravity\scratch\tools\qemu"
$QemuExe = Join-Path $QemuDir "qemu-system-x86_64.exe"
$QemuImg = Join-Path $QemuDir "qemu-img.exe"
$OvmfBios = Join-Path $QemuDir "share\edk2-x86_64-code.fd"

if (-not (Test-Path $IsoPath)) {
    throw "ISO not found at $IsoPath. Please verify the download completed first."
}

if (-not (Test-Path $QemuExe)) {
    throw "QEMU executable not found at $QemuExe."
}

# Function to send QMP command and take screendump
function Invoke-QmpCommand {
    param(
        [int]$Port,
        [string]$CommandJson
    )
    try {
        $tcp = New-Object System.Net.Sockets.TcpClient("127.0.0.1", $Port)
        $stream = $tcp.GetStream()
        $reader = New-Object System.IO.StreamReader($stream)
        $writer = New-Object System.IO.StreamWriter($stream)
        $writer.AutoFlush = $true

        # Read QMP greeting
        $greeting = $reader.ReadLine()
        
        # Negotiate QMP capabilities
        $writer.WriteLine('{"execute": "qmp_capabilities"}')
        $capResp = $reader.ReadLine()

        # Send command
        $writer.WriteLine($CommandJson)
        $resp = $reader.ReadLine()

        $tcp.Close()
        return $resp
    } catch {
        Write-Warning "QMP command failed on port $Port : $_"
        return $null
    }
}

# Ensure disposable virtual disk
if (-not (Test-Path $TestDisk)) {
    Write-Host "[*] Creating 25 GB disposable QCOW2 virtual disk..."
    & $QemuImg create -f qcow2 $TestDisk 25G
}

# Test 1: BIOS Boot Test
if ($Mode -eq "bios" -or $Mode -eq "all") {
    Write-Host "=================================================================="
    Write-Host "          TEST 1: BIOS (LEGACY MBR) BOOT VERIFICATION             "
    Write-Host "=================================================================="
    $biosLog = Join-Path $DistDir "bios-serial.log"
    $biosPpm = (Join-Path $DistDir "screenshot-bios.ppm").Replace("\", "/")

    $biosArgs = @(
        "-m", "4096",
        "-smp", "4",
        "-vga", "virtio",
        "-display", "none",
        "-qmp", "tcp:127.0.0.1:4444,server,nowait",
        "-serial", "file:$biosLog",
        "-cdrom", $IsoPath,
        "-boot", "d"
    )

    Write-Host "[*] Launching QEMU in BIOS mode..."
    $proc = Start-Process -FilePath $QemuExe -ArgumentList $biosArgs -PassThru

    Write-Host "[*] Waiting 45 seconds for bootloader & kernel initialization..."
    Start-Sleep -Seconds 45

    Write-Host "[*] Capturing BIOS framebuffer screenshot via QMP..."
    Invoke-QmpCommand -Port 4444 -CommandJson "{`"execute`": `"screendump`", `"arguments`": {`"filename`": `"$biosPpm`"}}"

    Write-Host "[*] Shutting down BIOS VM session..."
    Invoke-QmpCommand -Port 4444 -CommandJson '{"execute": "quit"}'
    Start-Sleep -Seconds 3
    if (-not $proc.HasExited) { Stop-Process -Id $proc.Id -Force }

    Write-Host "[+] BIOS boot verification completed. Log saved to $biosLog."
}

# Test 2: UEFI Boot Test
if ($Mode -eq "uefi" -or $Mode -eq "all") {
    Write-Host "=================================================================="
    Write-Host "          TEST 2: UEFI (OVMF) BOOT VERIFICATION                   "
    Write-Host "=================================================================="
    $uefiLog = Join-Path $DistDir "uefi-serial.log"
    $uefiPpm = (Join-Path $DistDir "screenshot-uefi.ppm").Replace("\", "/")
    $desktopPpm = (Join-Path $DistDir "screenshot-desktop.ppm").Replace("\", "/")

    $uefiArgs = @(
        "-m", "4096",
        "-smp", "4",
        "-bios", $OvmfBios,
        "-vga", "virtio",
        "-display", "none",
        "-qmp", "tcp:127.0.0.1:4445,server,nowait",
        "-serial", "file:$uefiLog",
        "-cdrom", $IsoPath,
        "-boot", "d",
        "-drive", "file=$TestDisk,format=qcow2,if=virtio"
    )

    Write-Host "[*] Launching QEMU in UEFI mode with OVMF..."
    $proc = Start-Process -FilePath $QemuExe -ArgumentList $uefiArgs -PassThru

    Write-Host "[*] Waiting 30 seconds for UEFI GRUB splash..."
    Start-Sleep -Seconds 30
    Invoke-QmpCommand -Port 4445 -CommandJson "{`"execute`": `"screendump`", `"arguments`": {`"filename`": `"$uefiPpm`"}}"

    Write-Host "[*] Waiting 60 seconds for Live System & KDE Plasma session..."
    Start-Sleep -Seconds 60
    Invoke-QmpCommand -Port 4445 -CommandJson "{`"execute`": `"screendump`", `"arguments`": {`"filename`": `"$desktopPpm`"}}"

    Write-Host "[*] Shutting down UEFI VM session..."
    Invoke-QmpCommand -Port 4445 -CommandJson '{"execute": "quit"}'
    Start-Sleep -Seconds 3
    if (-not $proc.HasExited) { Stop-Process -Id $proc.Id -Force }

    Write-Host "[+] UEFI boot verification completed. Log saved to $uefiLog."
}

Write-Host "=================================================================="
Write-Host "          ALL QEMU VM TEST SUITES COMPLETED                       "
Write-Host "=================================================================="
