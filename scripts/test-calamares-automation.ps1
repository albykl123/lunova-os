# ==============================================================================
# Lunova OS 1.0.1 - Automated Calamares GUI Installation Test Harness
# ==============================================================================
param(
    [string]$Mode = "bios",
    [int]$MaxBootWaitSeconds = 90
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootDir = Split-Path -Parent $ScriptDir

$isoPath = Join-Path $RootDir "dist\Lunova-OS-1.0.1-Aurora-amd64.iso"
$qemuExe = "C:\Users\alber\.gemini\antigravity\scratch\tools\qemu\qemu-system-x86_64.exe"
$ovmfBios = "C:\Users\alber\.gemini\antigravity\scratch\tools\qemu\share\edk2-x86_64-code.fd"

$diskPath = if ($Mode -eq "uefi") {
    Join-Path $RootDir "tests\vm\lunova-uefi-installed.qcow2"
} else {
    Join-Path $RootDir "tests\vm\lunova-installed.qcow2"
}

if (-not (Test-Path $isoPath)) { throw "ISO not found: $isoPath" }
if (-not (Test-Path $diskPath)) { throw "Virtual disk not found: $diskPath" }

Write-Host "=========================================================="
Write-Host "   Lunova OS 1.0.1 - Calamares GUI Automation Harness"
Write-Host "=========================================================="
Write-Host "Mode:        $Mode"
Write-Host "Target Disk: $diskPath"

$qemuArgs = @(
    "-m", "4096",
    "-smp", "4",
    "-cdrom", $isoPath,
    "-drive", "file=$diskPath,format=qcow2,if=virtio",
    "-boot", "d",
    "-vga", "virtio",
    "-device", "virtio-tablet-pci",
    "-device", "virtio-net-pci,netdev=net0",
    "-netdev", "user,id=net0",
    "-display", "none",
    "-qmp", "tcp:127.0.0.1:4446,server,nowait"
)

if ($Mode -eq "uefi") {
    $qemuArgs += @("-drive", "if=pflash,format=raw,readonly=on,file=$ovmfBios")
}

$proc = Start-Process -FilePath $qemuExe -ArgumentList $qemuArgs -PassThru

function Send-QmpCommand($writer, $reader, $jsonCmd) {
    $writer.WriteLine($jsonCmd)
    return $reader.ReadLine()
}

function Send-QmpKey($writer, $reader, $qcode) {
    $press = "{`"execute`":`"input-send-event`",`"arguments`":{`"events`":[{`"type`":`"key`",`"data`":{`"down`":true,`"key`":{`"type`":`"qcode`",`"data`":`"$qcode`"}}},{`"type`":`"key`",`"data`":{`"down`":false,`"key`":{`"type`":`"qcode`",`"data`":`"$qcode`"}}}]}}"
    return Send-QmpCommand $writer $reader $press
}

function Capture-Screen($writer, $reader, $stepName) {
    $ppmPath = (Join-Path $RootDir "tests\vm\$stepName.ppm") -replace '\\', '/'
    $pngPath = (Join-Path $RootDir "tests\vm\$stepName.png")
    $cmd = "{`"execute`":`"screendump`",`"arguments`":{`"filename`":`"$ppmPath`"}}"
    $resp = Send-QmpCommand $writer $reader $cmd
    Start-Sleep -Milliseconds 500
    if (Test-Path $ppmPath) {
        powershell -ExecutionPolicy Bypass -File (Join-Path $RootDir "scripts\PpmConverter.ps1") -InputPpm $ppmPath -OutputPng $pngPath | Out-Null
        Write-Host "==> Captured: $pngPath"
    }
}

try {
    Start-Sleep -Seconds 3
    Write-Host "==> Connecting to QMP at 127.0.0.1:4446..."
    $tcp = New-Object System.Net.Sockets.TcpClient("127.0.0.1", 4446)
    $stream = $tcp.GetStream()
    $reader = New-Object System.IO.StreamReader($stream)
    $writer = New-Object System.IO.StreamWriter($stream)
    $writer.AutoFlush = $true

    $greeting = $reader.ReadLine()
    Write-Host "==> QMP Connected: $greeting"

    Send-QmpCommand $writer $reader '{"execute":"qmp_capabilities"}' | Out-Null

    # Step 1: Handle Bootloader Menu
    Start-Sleep -Seconds 2
    Capture-Screen $writer $reader "$Mode-01-bootloader"
    Write-Host "==> Sending 'ret' (Enter) to bootloader menu..."
    Send-QmpKey $writer $reader "ret" | Out-Null

    # Step 2: Wait for Linux kernel and Live Desktop to load
    Write-Host "==> Waiting for kernel boot and KDE Plasma 6 desktop to initialize (up to $MaxBootWaitSeconds seconds)..."
    $elapsed = 0
    while ($elapsed -lt $MaxBootWaitSeconds) {
        Start-Sleep -Seconds 15
        $elapsed += 15
        Capture-Screen $writer $reader "$Mode-02-booting-$elapsed"
    }

    # Step 3: Trigger Calamares Launcher via KRunner / Shortcut
    Write-Host "==> Attempting to launch Calamares installer..."
    # Press Alt+Space (KRunner)
    $altSpace = "{`"execute`":`"input-send-event`",`"arguments`":{`"events`":[{`"type`":`"key`",`"data`":{`"down`":true,`"key`":{`"type`":`"qcode`",`"data`":`"alt`"}}},{`"type`":`"key`",`"data`":{`"down`":true,`"key`":{`"type`":`"qcode`",`"data`":`"spc`"}}},{`"type`":`"key`",`"data`":{`"down`":false,`"key`":{`"type`":`"qcode`",`"data`":`"spc`"}}},{`"type`":`"key`",`"data`":{`"down`":false,`"key`":{`"type`":`"qcode`",`"data`":`"alt`"}}}]}}"
    Send-QmpCommand $writer $reader $altSpace | Out-Null
    Start-Sleep -Seconds 2

    # Type 'calamares' and Enter
    $keys = @("c", "a", "l", "a", "m", "a", "r", "e", "s", "ret")
    foreach ($k in $keys) {
        Send-QmpKey $writer $reader $k | Out-Null
        Start-Sleep -Milliseconds 150
    }

    Start-Sleep -Seconds 10
    Capture-Screen $writer $reader "$Mode-03-calamares-launched"

    # Step 4: Step through Calamares wizard pages with Alt+N (Next)
    Write-Host "==> Stepping through wizard pages (Language, Location, Keyboard, Partitions)..."
    for ($i = 1; $i -le 4; $i++) {
        Write-Host "==> Navigating wizard step $i (Alt+N)..."
        $altN = "{`"execute`":`"input-send-event`",`"arguments`":{`"events`":[{`"type`":`"key`",`"data`":{`"down`":true,`"key`":{`"type`":`"qcode`",`"data`":`"alt`"}}},{`"type`":`"key`",`"data`":{`"down`":true,`"key`":{`"type`":`"qcode`",`"data`":`"n`"}}},{`"type`":`"key`",`"data`":{`"down`":false,`"key`":{`"type`":`"qcode`",`"data`":`"n`"}}},{`"type`":`"key`",`"data`":{`"down`":false,`"key`":{`"type`":`"qcode`",`"data`":`"alt`"}}}]}}"
        Send-QmpCommand $writer $reader $altN | Out-Null
        Start-Sleep -Seconds 3
        Capture-Screen $writer $reader "$Mode-04-wizard-step-$i"
    }

    # Step 5: User Setup Page: Type test user credentials
    Write-Host "==> Entering test user credentials..."
    $userKeys = @(
        "T", "e", "s", "t", "tab",
        "t", "e", "s", "t", "u", "s", "e", "r", "tab",
        "t", "e", "s", "t", "1", "2", "3", "tab",
        "t", "e", "s", "t", "1", "2", "3"
    )
    foreach ($uk in $userKeys) {
        Send-QmpKey $writer $reader $uk | Out-Null
        Start-Sleep -Milliseconds 100
    }
    Start-Sleep -Seconds 2
    Capture-Screen $writer $reader "$Mode-05-user-setup"

    # Step 6: Next to Summary & Click Install
    Write-Host "==> Proceeding to Summary..."
    Send-QmpCommand $writer $reader $altN | Out-Null
    Start-Sleep -Seconds 3
    Capture-Screen $writer $reader "$Mode-06-summary"

    # Press Alt+I (Install)
    Write-Host "==> Triggering Installation (Alt+I)..."
    $altI = "{`"execute`":`"input-send-event`",`"arguments`":{`"events`":[{`"type`":`"key`",`"data`":{`"down`":true,`"key`":{`"type`":`"qcode`",`"data`":`"alt`"}}},{`"type`":`"key`",`"data`":{`"down`":true,`"key`":{`"type`":`"qcode`",`"data`":`"i`"}}},{`"type`":`"key`",`"data`":{`"down`":false,`"key`":{`"type`":`"qcode`",`"data`":`"i`"}}},{`"type`":`"key`",`"data`":{`"down`":false,`"key`":{`"type`":`"qcode`",`"data`":`"alt`"}}}]}}"
    Send-QmpCommand $writer $reader $altI | Out-Null
    Start-Sleep -Seconds 2
    Send-QmpKey $writer $reader "ret" | Out-Null # Confirm dialog
    Start-Sleep -Seconds 5
    Capture-Screen $writer $reader "$Mode-07-installation-progress"

    Write-Host "==> Calamares GUI automation sequence executed successfully."
} finally {
    if ($proc -and -not $proc.HasExited) {
        Write-Host "==> Stopping VM..."
        Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
    }
}
