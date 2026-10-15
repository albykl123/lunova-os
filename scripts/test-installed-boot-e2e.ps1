# ==============================================================================
# Lunova OS 1.0.1 - Post-Install Boot & App Verification (No ISO Attached)
# ==============================================================================
param(
    [int]$BootWaitSeconds = 180
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootDir = Split-Path -Parent $ScriptDir

$diskPath = Join-Path $RootDir "tests\vm\lunova-installed.qcow2"
$qemuExe = "C:\Users\alber\.gemini\antigravity\scratch\tools\qemu\qemu-system-x86_64.exe"
$ppmConverter = Join-Path $RootDir "scripts\PpmConverter.ps1"

Write-Host "=========================================================="
Write-Host "   Lunova OS 1.0.1 - Post-Install Boot Verification"
Write-Host "=========================================================="
Write-Host "Boot Disk:   $diskPath (Installed OS, No ISO)"

if (-not (Test-Path $diskPath)) { throw "Installed virtual disk not found: $diskPath" }

$qemuArgs = @(
    "-m", "3072",
    "-smp", "4",
    "-drive", "file=$diskPath,format=qcow2,if=virtio",
    "-boot", "c",
    "-vga", "virtio",
    "-device", "virtio-tablet-pci",
    "-device", "virtio-net-pci,netdev=net0",
    "-netdev", "user,id=net0",
    "-display", "none",
    "-qmp", "tcp:127.0.0.1:4451,server,nowait"
)

Write-Host "==> Launching post-install QEMU VM..."
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
    Write-Host "==> Connecting to QMP port 4451..."
    $connected = $false
    for ($i = 0; $i -lt 10; $i++) {
        Start-Sleep -Seconds 1
        try {
            $tcp = New-Object System.Net.Sockets.TcpClient("127.0.0.1", 4451)
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

    # Stage 1: Installed GRUB bootloader menu
    Write-Host "==> Checking GRUB boot menu..."
    Start-Sleep -Seconds 5
    Capture-Screen $writer $reader "postinstall-01-grub-menu"
    Send-Key $writer $reader "ret" | Out-Null

    # Stage 2: Wait for installed OS to boot to login / desktop
    Write-Host "==> Waiting for installed system to boot ($BootWaitSeconds seconds max)..."
    $bootTime = 0
    while ($bootTime -lt $BootWaitSeconds) {
        Start-Sleep -Seconds 20
        $bootTime += 20
        Capture-Screen $writer $reader "postinstall-02-booting-${bootTime}s"
        Write-Host "==> Post-install boot elapsed: ${bootTime}s..."
    }

    Capture-Screen $writer $reader "postinstall-03-desktop-or-login"

    # If login screen, enter password 'lunova'
    Write-Host "==> Entering credentials (lunova / ret)..."
    $pw = @("l", "u", "n", "o", "v", "a")
    foreach ($k in $pw) { Send-Key $writer $reader $k | Out-Null; Start-Sleep -Milliseconds 100 }
    Send-Key $writer $reader "ret" | Out-Null
    Start-Sleep -Seconds 15
    Capture-Screen $writer $reader "postinstall-04-desktop-active"

    # Stage 3: Launch Native Lunova Applications
    Write-Host "==> Launching Lunova Welcome (Alt+F2 -> lunova-welcome)..."
    Send-Key $writer $reader "alt-f2" | Out-Null
    Start-Sleep -Seconds 2
    $appKeys = @("l", "u", "n", "o", "v", "a", "-", "w", "e", "l", "c", "o", "m", "e")
    foreach ($k in $appKeys) { Send-Key $writer $reader $k | Out-Null; Start-Sleep -Milliseconds 100 }
    Send-Key $writer $reader "ret" | Out-Null
    Start-Sleep -Seconds 10
    Capture-Screen $writer $reader "postinstall-05-app-welcome"

    Write-Host "==> Launching Lunova Control Center (Alt+F2 -> lunova-control-center)..."
    Send-Key $writer $reader "alt-f2" | Out-Null
    Start-Sleep -Seconds 2
    $appKeys2 = @("l", "u", "n", "o", "v", "a", "-", "c", "o", "n", "t", "r", "o", "l", "-", "c", "e", "n", "t", "e", "r")
    foreach ($k in $appKeys2) { Send-Key $writer $reader $k | Out-Null; Start-Sleep -Milliseconds 100 }
    Send-Key $writer $reader "ret" | Out-Null
    Start-Sleep -Seconds 10
    Capture-Screen $writer $reader "postinstall-06-app-control-center"

    Write-Host "==> Clean shutdown..."
    Send-QmpRaw $writer $reader '{"execute":"system_powerdown"}' | Out-Null
    Start-Sleep -Seconds 5
} finally {
    if ($proc -and -not $proc.HasExited) {
        Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
    }
}

Write-Host "=========================================================="
Write-Host "   Post-Install Boot Verification Complete!"
Write-Host "=========================================================="
