# ==============================================================================
# Lunova OS 1.0.1 Aurora - SourceForge FRS Upload Automation
# ==============================================================================
param(
    [string]$Username = "albykl",
    [string]$ProjectName = "lunova-os",
    [string]$ReleaseVersion = "1.0.1"
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootDir = Split-Path -Parent $ScriptDir
$DistDir = Join-Path $RootDir "dist"

$isoPath = (Join-Path $DistDir "Lunova-OS-1.0.1-Aurora-amd64.iso") -replace '\\', '/'
$sumsPath = (Join-Path $DistDir "SHA256SUMS") -replace '\\', '/'
$notesPath = (Join-Path $DistDir "RELEASE_NOTES.md") -replace '\\', '/'
$keyPath = ("$env:USERPROFILE\.ssh\id_ed25519") -replace '\\', '/'

Write-Host "=========================================================="
Write-Host "   Lunova OS 1.0.1 Aurora - SourceForge Delivery Deployer"
Write-Host "=========================================================="
Write-Host "SourceForge User:    $Username"
Write-Host "SourceForge Project: $ProjectName"
Write-Host "Release Directory:   $ReleaseVersion"

if (-not (Test-Path $isoPath)) {
    throw "Monolithic ISO file not found at: $isoPath"
}
if (-not (Test-Path $sumsPath)) {
    throw "Checksum file not found at: $sumsPath"
}
if (-not (Test-Path $notesPath)) {
    throw "Release notes not found at: $notesPath"
}
if (-not (Test-Path $keyPath)) {
    throw "Ed25519 SSH private key not found at: $keyPath"
}

$isoSize = (Get-Item $isoPath).Length
Write-Host "==> Verified ISO to upload: $isoPath ($isoSize bytes / $([math]::Round($isoSize/1MB, 2)) MB)"

$remoteDir = "/home/frs/project/$ProjectName/$ReleaseVersion"
$remoteHost = "frs.sourceforge.net"

Write-Host "==> Target SourceForge FRS destination: $Username@$remoteHost`:$remoteDir"

# Generate SFTP batch file for robust automated delivery
$batchFile = Join-Path $DistDir "sftp_batch.txt"
$batchCommands = @"
-mkdir /home/frs/project/$ProjectName
-mkdir $remoteDir
cd $remoteDir
put "$sumsPath" SHA256SUMS
put "$notesPath" RELEASE_NOTES.md
put "$notesPath" README.md
put "$isoPath" Lunova-OS-1.0.1-Aurora-amd64.iso
ls -la
quit
"@

Set-Content -Path $batchFile -Value $batchCommands -Encoding ASCII

Write-Host "==> Commencing SFTP batch upload to SourceForge File Release System..."
Write-Host "    (Uploading SHA256SUMS, RELEASE_NOTES.md, and the 2.39 GiB monolithic ISO)"

& "C:\Windows\System32\OpenSSH\sftp.exe" -o StrictHostKeyChecking=accept-new -i $keyPath -b $batchFile "$Username@$remoteHost"

if ($LASTEXITCODE -eq 0) {
    Write-Host "=========================================================="
    Write-Host "==> [SUCCESS] Lunova OS 1.0.1 Aurora uploaded to SourceForge!"
    Write-Host "==> Public Download URL:"
    Write-Host "    https://downloads.sourceforge.net/project/$ProjectName/$ReleaseVersion/Lunova-OS-1.0.1-Aurora-amd64.iso"
    Write-Host "=========================================================="
} else {
    Write-Error "SFTP upload failed with exit code $LASTEXITCODE."
}
