# ==============================================================================
# Lunova OS 1.0.1 - 180-Second TCG Boot Test
# ==============================================================================
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootDir = Split-Path -Parent $ScriptDir

$qemuExe = "C:\Users\alber\.gemini\antigravity\scratch\tools\qemu\qemu-system-x86_64.exe"
$isoPath = Join-Path $RootDir "dist\Lunova-OS-1.0.1-Aurora-amd64.iso"
$diskPath = Join-Path $RootDir "tests\vm\lunova-installed.qcow2"

Write-Host "==> Starting QEMU for 180-second boot test..."

$qemuArgs = @(
    "-m", "4096",
    "-smp", "4",
    "-cdrom", $isoPath,
    "-drive", "file=$diskPath,format=qcow2,if=virtio",
    "-boot", "d",
    "-vga", "virtio",
    "-display", "none",
    "-qmp", "tcp:127.0.0.1:4448,server,nowait"
)

$proc = Start-Process -FilePath $qemuExe -ArgumentList $qemuArgs -PassThru

try {
    Start-Sleep -Seconds 3
    $tcp = New-Object System.Net.Sockets.TcpClient("127.0.0.1", 4448)
    $stream = $tcp.GetStream()
    $reader = New-Object System.IO.StreamReader($stream)
    $writer = New-Object System.IO.StreamWriter($stream)
    $writer.AutoFlush = $true

    $reader.ReadLine() # Greeting
    $writer.WriteLine('{"execute":"qmp_capabilities"}')
    $reader.ReadLine()

    Start-Sleep -Seconds 2
    Write-Host "==> Sending 'sendkey ret' to bootloader..."
    $writer.WriteLine('{"execute":"human-monitor-command","arguments":{"command-line":"sendkey ret"}}')
    $reader.ReadLine()

    Write-Host "==> Kernel loading. Waiting 180 seconds for KDE Plasma 6 desktop to load..."
    $checkpoint = 0
    while ($checkpoint -lt 180) {
        Start-Sleep -Seconds 30
        $checkpoint += 30
        Write-Host "==> Boot progress: ${checkpoint}s..."
        $ppm = (Join-Path $RootDir "tests\vm\boot-test-${checkpoint}s.ppm") -replace '\\', '/'
        $writer.WriteLine("{`"execute`":`"screendump`",`"arguments`":{`"filename`":`"$ppm`"}}")
        $reader.ReadLine()
    }

    $ppmFinal = (Join-Path $RootDir "tests\vm\boot-180s.ppm") -replace '\\', '/'
    $pngFinal = (Join-Path $RootDir "tests\vm\boot-180s.png")
    $writer.WriteLine("{`"execute`":`"screendump`",`"arguments`":{`"filename`":`"$ppmFinal`"}}")
    $reader.ReadLine()

    powershell -ExecutionPolicy Bypass -File (Join-Path $RootDir "scripts\PpmConverter.ps1") -InputPpm $ppmFinal -OutputPng $pngFinal | Out-Null
    Write-Host "==> Converted: $pngFinal"
} finally {
    if ($proc -and -not $proc.HasExited) {
        Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
    }
}
