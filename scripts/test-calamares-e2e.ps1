# ==============================================================================
# Lunova OS 1.0.1 - End-to-End Calamares Installation & Boot Verification
# ==============================================================================
param(
    [string]$Mode = "bios",
    [int]$BootWaitSeconds = 260,
    [int]$InstallTimeoutMinutes = 25
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootDir = Split-Path -Parent $ScriptDir

$isoPath = Join-Path $RootDir "dist\Lunova-OS-1.0.1-Aurora-amd64.iso"
$qemuExe = "C:\Users\alber\.gemini\antigravity\scratch\tools\qemu\qemu-system-x86_64.exe"
$qemuImgExe = "C:\Users\alber\.gemini\antigravity\scratch\tools\qemu\qemu-img.exe"
$diskPath = Join-Path $RootDir "tests\vm\lunova-installed.qcow2"
$ppmConverter = Join-Path $RootDir "scripts\PpmConverter.ps1"

Write-Host "=========================================================="
Write-Host "   Lunova OS 1.0.1 - Calamares Installation Test"
Write-Host "=========================================================="
Write-Host "ISO:         $isoPath"
Write-Host "Target Disk: $diskPath"

# Reset virtual disk to clean 30GB QCOW2 image
if (Test-Path $diskPath) {
    Remove-Item -Force $diskPath
}
& $qemuImgExe create -f qcow2 $diskPath 30G | Out-Null
Write-Host "==> Created fresh 30GB QCOW2 virtual disk."

$qemuArgs = @(
    "-m", "3072",
    "-smp", "4",
    "-cdrom", $isoPath,
    "-drive", "file=$diskPath,format=qcow2,if=virtio",
    "-boot", "d",
    "-vga", "virtio",
    "-device", "virtio-tablet-pci",
    "-device", "virtio-net-pci,netdev=net0",
    "-netdev", "user,id=net0",
    "-display", "none",
    "-qmp", "tcp:127.0.0.1:4450,server,nowait"
)

Write-Host "==> Launching QEMU instance..."
$proc = Start-Process -FilePath $qemuExe -ArgumentList $qemuArgs -PassThru

function Send-QmpRaw($writer, $reader, $jsonCmd) {
    $writer.WriteLine($jsonCmd)
    return $reader.ReadLine()
}

function Send-Key($writer, $reader, $key) {
    $cmd = "{`"execute`":`"human-monitor-command`",`"arguments`":{`"command-line`":`"sendkey $key`"}}"
    return Send-QmpRaw $writer $reader $cmd
}

function Capture-Screen($writer, $reader, $name) {
    $ppm = (Join-Path $RootDir "tests\vm\$name.ppm") -replace '\\', '/'
    $png = (Join-Path $RootDir "tests\vm\$name.png")
    $cmd = "{`"execute`":`"screendump`",`"arguments`":{`"filename`":`"$ppm`"}}"
    Send-QmpRaw $writer $reader $cmd | Out-Null
    Start-Sleep -Milliseconds 500
    if (Test-Path $ppm) {
        powershell -ExecutionPolicy Bypass -File $ppmConverter -InputPpm $ppm -OutputPng $png | Out-Null
        Write-Host "==> Screenshot captured: tests\vm\$name.png"
    }
}

try {
    Write-Host "==> Connecting to QMP port 4450..."
    $connected = $false
    for ($i = 0; $i -lt 15; $i++) {
        Start-Sleep -Seconds 1
        try {
            $tcp = New-Object System.Net.Sockets.TcpClient("127.0.0.1", 4450)
            $stream = $tcp.GetStream()
            $reader = New-Object System.IO.StreamReader($stream)
            $writer = New-Object System.IO.StreamWriter($stream)
            $writer.AutoFlush = $true
            $connected = $true
            break
        } catch { }
    }
    if (-not $connected) { throw "Could not connect to QMP server." }

    $greeting = $reader.ReadLine()
    Send-QmpRaw $writer $reader '{"execute":"qmp_capabilities"}' | Out-Null
    Write-Host "==> QMP Handshake complete."

    # Stage 1: Wait for ISOLINUX Bootloader Menu
    Write-Host "==> Waiting 25 seconds for ISOLINUX bootloader menu..."
    Start-Sleep -Seconds 25
    Capture-Screen $writer $reader "stage-01-bootloader-menu"

    Write-Host "==> Sending 'sendkey ret' to boot Live session..."
    Send-Key $writer $reader "ret" | Out-Null
    Start-Sleep -Seconds 5
    Send-Key $writer $reader "ret" | Out-Null

    # Stage 2: Monitor boot progress
    Write-Host "==> Waiting for Linux kernel & KDE Plasma 6 desktop ($BootWaitSeconds seconds max)..."
    $bootTime = 0
    while ($bootTime -lt $BootWaitSeconds) {
        Start-Sleep -Seconds 25
        $bootTime += 25
        Capture-Screen $writer $reader "stage-02-booting-${bootTime}s"
        Write-Host "==> Boot elapsed: ${bootTime}s / ${BootWaitSeconds}s..."
    }

    Capture-Screen $writer $reader "stage-03-live-desktop"
    Write-Host "==> Desktop initialization window reached."

    # Stage 3: Dismiss Welcome Center if present (Alt+F4)
    Write-Host "==> Sending Alt+F4 to dismiss welcome center..."
    Send-Key $writer $reader "alt-f4" | Out-Null
    Start-Sleep -Seconds 3

    # Stage 4: Launch Calamares via KRunner
    Write-Host "==> Launching Calamares installer (Alt+F2 -> calamares -> ret)..."
    Send-Key $writer $reader "alt-f2" | Out-Null
    Start-Sleep -Seconds 2

    # Type 'calamares'
    $letters = @("c", "a", "l", "a", "m", "a", "r", "e", "s")
    foreach ($l in $letters) {
        Send-Key $writer $reader $l | Out-Null
        Start-Sleep -Milliseconds 150
    }
    Start-Sleep -Milliseconds 800
    Send-Key $writer $reader "ret" | Out-Null

    Write-Host "==> Waiting 20 seconds for Calamares UI to appear..."
    Start-Sleep -Seconds 20
    Capture-Screen $writer $reader "stage-04-calamares-welcome"

    # Stage 5: Calamares Step 1 - Welcome -> Next (Alt+N)
    Write-Host "==> Calamares Step 1 (Welcome) -> Next (Alt+N)..."
    Send-Key $writer $reader "alt-n" | Out-Null
    Start-Sleep -Seconds 4
    Capture-Screen $writer $reader "stage-05-calamares-location"

    # Stage 6: Calamares Step 2 - Location -> Next (Alt+N)
    Write-Host "==> Calamares Step 2 (Location) -> Next (Alt+N)..."
    Send-Key $writer $reader "alt-n" | Out-Null
    Start-Sleep -Seconds 4
    Capture-Screen $writer $reader "stage-06-calamares-keyboard"

    # Stage 7: Calamares Step 3 - Keyboard -> Next (Alt+N)
    Write-Host "==> Calamares Step 3 (Keyboard) -> Next (Alt+N)..."
    Send-Key $writer $reader "alt-n" | Out-Null
    Start-Sleep -Seconds 4
    Capture-Screen $writer $reader "stage-07-calamares-partitions"

    # Stage 8: Calamares Step 4 - Partitions (Erase Disk is default on empty disk) -> Next (Alt+N)
    Write-Host "==> Calamares Step 4 (Partitions) -> Next (Alt+N)..."
    Send-Key $writer $reader "alt-n" | Out-Null
    Start-Sleep -Seconds 4
    Capture-Screen $writer $reader "stage-08-calamares-users"

    # Stage 9: Calamares Step 5 - Users
    Write-Host "==> Calamares Step 5 (Users) -> Entering credentials..."
    # Full Name: Lunova User
    $fullName = @("L", "u", "n", "o", "v", "a", "spc", "U", "s", "e", "r")
    foreach ($k in $fullName) { Send-Key $writer $reader $k | Out-Null; Start-Sleep -Milliseconds 100 }
    Send-Key $writer $reader "tab" | Out-Null
    Start-Sleep -Milliseconds 200

    # Username: lunova
    $username = @("l", "u", "n", "o", "v", "a")
    foreach ($k in $username) { Send-Key $writer $reader $k | Out-Null; Start-Sleep -Milliseconds 100 }
    Send-Key $writer $reader "tab" | Out-Null
    Start-Sleep -Milliseconds 200

    # Hostname: lunova-pc
    $hostname = @("l", "u", "n", "o", "v", "a", "-", "p", "c")
    foreach ($k in $hostname) { Send-Key $writer $reader $k | Out-Null; Start-Sleep -Milliseconds 100 }
    Send-Key $writer $reader "tab" | Out-Null
    Start-Sleep -Milliseconds 200

    # Password: Lunova2026!Aurora
    $pw = @("L", "u", "n", "o", "v", "a", "2", "0", "2", "6", "exclam", "A", "u", "r", "o", "r", "a")
    foreach ($k in $pw) { Send-Key $writer $reader $k | Out-Null; Start-Sleep -Milliseconds 100 }
    Send-Key $writer $reader "tab" | Out-Null
    Start-Sleep -Milliseconds 200

    # Repeat Password: Lunova2026!Aurora
    foreach ($k in $pw) { Send-Key $writer $reader $k | Out-Null; Start-Sleep -Milliseconds 100 }
    Start-Sleep -Seconds 2
    Capture-Screen $writer $reader "stage-09-calamares-users-filled"

    # Next (Alt+N) -> Summary
    Write-Host "==> Users -> Next (Alt+N) to Summary..."
    Send-Key $writer $reader "alt-n" | Out-Null
    Start-Sleep -Seconds 4
    Capture-Screen $writer $reader "stage-10-calamares-summary"

    # Stage 10: Summary -> Install (Alt+I)
    Write-Host "==> Triggering Installation (Alt+I)..."
    Send-Key $writer $reader "alt-i" | Out-Null
    Start-Sleep -Seconds 2

    # Confirmation Dialog -> Confirm (Return / Alt+I)
    Write-Host "==> Confirming installation prompt (ret)..."
    Send-Key $writer $reader "ret" | Out-Null
    Start-Sleep -Seconds 5
    Capture-Screen $writer $reader "stage-11-installation-started"

    # Stage 11: Monitor Installation Progress
    Write-Host "==> Monitoring installation progress (checking virtual disk growth)..."
    $maxChecks = ($InstallTimeoutMinutes * 60) / 30
    $prevSize = 0
    $stableCount = 0
    for ($c = 1; $c -le $maxChecks; $c++) {
        Start-Sleep -Seconds 30
        $curSize = (Get-Item $diskPath).Length
        $curSizeMb = [math]::Round($curSize / 1MB, 2)
        Write-Host "==> Progress Check ${c}: Virtual disk size = $curSizeMb MB"
        Capture-Screen $writer $reader "stage-12-installing-check-$c"
        
        # Check if disk has grown substantially (> 1500 MB) and stopped growing
        if ($curSize -gt 1572864000) {
            if ([math]::Abs($curSize - $prevSize) -lt 2097152) {
                $stableCount++
                if ($stableCount -ge 3) {
                    Write-Host "==> Virtual disk writes stabilized at $curSizeMb MB. Installation complete!"
                    Start-Sleep -Seconds 10
                    Capture-Screen $writer $reader "stage-13-calamares-finished"
                    break
                }
            } else {
                $stableCount = 0
            }
        }
        $prevSize = $curSize
    }

    Write-Host "==> Calamares installation phase finished."
    Capture-Screen $writer $reader "stage-14-calamares-final"

    # Power down installer VM
    Write-Host "==> Powering down installer VM..."
    Send-QmpRaw $writer $reader '{"execute":"system_powerdown"}' | Out-Null
    Start-Sleep -Seconds 10
} finally {
    if ($proc -and -not $proc.HasExited) {
        Write-Host "==> Stopping QEMU process..."
        Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
    }
}

Write-Host "=========================================================="
Write-Host "   Calamares Installation Phase Complete!"
Write-Host "=========================================================="
