# ==============================================================================
# Lunova OS 1.0.1 - QEMU Automated Boot & Screendump Harness
# ==============================================================================
param(
    [string]$Mode = "bios",
    [int]$DurationSeconds = 40
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootDir = Split-Path -Parent $ScriptDir

$isoPath = Join-Path $RootDir "dist\Lunova-OS-1.0.1-Aurora-amd64.iso"
$diskPath = Join-Path $RootDir "tests\vm\lunova-installed.qcow2"
$qemuExe = "C:\Users\alber\.gemini\antigravity\scratch\tools\qemu\qemu-system-x86_64.exe"
$ovmfBios = "C:\Users\alber\.gemini\antigravity\scratch\tools\qemu\share\edk2-x86_64-code.fd"

if (-not (Test-Path $isoPath)) { throw "ISO not found: $isoPath" }
if (-not (Test-Path $diskPath)) { throw "Virtual disk not found: $diskPath" }

Write-Host "==> Starting QEMU Boot Test (Mode: $Mode)..."

$qemuArgs = @(
    "-m", "4096",
    "-smp", "2",
    "-cdrom", $isoPath,
    "-drive", "file=$diskPath,format=qcow2,if=virtio",
    "-boot", "d",
    "-display", "none",
    "-qmp", "tcp:127.0.0.1:4444,server,nowait"
)

if ($Mode -eq "uefi") {
    $qemuArgs += @("-drive", "if=pflash,format=raw,readonly=on,file=$ovmfBios")
}

$proc = Start-Process -FilePath $qemuExe -ArgumentList $qemuArgs -PassThru

try {
    Start-Sleep -Seconds 3
    Write-Host "==> Connecting to QMP at 127.0.0.1:4444..."
    $tcp = New-Object System.Net.Sockets.TcpClient("127.0.0.1", 4444)
    $stream = $tcp.GetStream()
    $reader = New-Object System.IO.StreamReader($stream)
    $writer = New-Object System.IO.StreamWriter($stream)
    $writer.AutoFlush = $true

    # Read greeting
    $greeting = $reader.ReadLine()
    Write-Host "==> QMP Greeting: $greeting"

    # Send qmp_capabilities
    $writer.WriteLine('{"execute":"qmp_capabilities"}')
    $capResp = $reader.ReadLine()
    Write-Host "==> QMP Capabilities ACK: $capResp"

    Write-Host "==> VM running. Capturing screenshots over $DurationSeconds seconds..."
    $elapsed = 0
    while ($elapsed -lt $DurationSeconds) {
        Start-Sleep -Seconds 10
        $elapsed += 10
        $ppmFile = (Join-Path $RootDir "tests\vm\qemu-$Mode-$elapsed.ppm") -replace '\\', '/'
        $cmd = "{`"execute`":`"screendump`",`"arguments`":{`"filename`":`"$ppmFile`"}}"
        $writer.WriteLine($cmd)
        $resp = $reader.ReadLine()
        Write-Host "==> Screendump at ${elapsed}s: $resp (saved to $ppmFile)"
    }

    # Query VM status
    $writer.WriteLine('{"execute":"query-status"}')
    $statusResp = $reader.ReadLine()
    Write-Host "==> Final VM Status: $statusResp"

    # Stop VM
    $writer.WriteLine('{"execute":"quit"}')
    Start-Sleep -Seconds 2
} finally {
    if (-not $proc.HasExited) {
        Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
    }
}

Write-Host "==> QEMU Boot Test Completed."
