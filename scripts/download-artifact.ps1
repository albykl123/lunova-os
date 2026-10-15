# ==============================================================================
# Lunova OS 1.0 Aurora - Direct Artifact Downloader and Checksum Verifier
# ==============================================================================
param(
    [string]$ArtifactId = "11907905877"
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootDir = Split-Path -Parent $ScriptDir
$DistDir = Join-Path $RootDir "dist"

if (-not (Test-Path $DistDir)) {
    New-Item -ItemType Directory -Path $DistDir -Force | Out-Null
}

$env:PATH = "C:\Users\alber\.gemini\antigravity\scratch\tools\git\cmd;C:\Users\alber\.gemini\antigravity\scratch\tools\gh;" + $env:PATH

Write-Host "==> Obtaining GitHub API token..."
$token = (gh auth token).Trim()
if (-not $token) {
    throw "Failed to acquire GitHub authentication token from gh CLI."
}

Write-Host "==> Fetching direct Azure Blob download URL for artifact $ArtifactId..."
$apiUrl = "https://api.github.com/repos/albykl123/lunova-os/actions/artifacts/$ArtifactId/zip"
$headers = curl.exe -sI -H "Authorization: Bearer $token" -H "Accept: application/vnd.github+json" $apiUrl
$locationLine = $headers | Select-String -Pattern "^Location:\s*(.+)" | Select-Object -First 1

if (-not $locationLine) {
    throw "GitHub API did not return a 302 Location redirect header."
}

$downloadUrl = $locationLine.Matches.Groups[1].Value.Trim()
$targetZip = Join-Path $DistDir "Lunova-OS-1.0.1-Aurora-Release.zip"

Write-Host "==> Downloading artifact archive directly from blob storage..."
Write-Host "    Target: $targetZip"

# Download with curl using resume support (-C -)
& curl.exe -C - -o $targetZip $downloadUrl

if (-not (Test-Path $targetZip)) {
    throw "Expected zip file not found after download."
}

$zipSize = (Get-Item $targetZip).Length
Write-Host "==> Download complete! Zip size: $zipSize bytes ($([math]::Round($zipSize/1MB, 2)) MB)"

Write-Host "==> Extracting ISO from zip archive..."
Expand-Archive -Path $targetZip -DestinationPath $DistDir -Force

$isoPath = Join-Path $DistDir "Lunova-OS-1.0.1-Aurora-amd64.iso"
if (-not (Test-Path $isoPath)) {
    throw "Expected ISO file not found after extraction: $isoPath"
}

$isoSize = (Get-Item $isoPath).Length
Write-Host "==> ISO extracted successfully! Size: $isoSize bytes ($([math]::Round($isoSize/1MB, 2)) MB)"

Write-Host "==> Computing independent SHA-256 cryptographic checksum..."
$hash = (Get-FileHash -Path $isoPath -Algorithm SHA256).Hash.ToLower()
Write-Host "==> Computed SHA-256: $hash"

$expectedHash = "bf5dc42aa3cad3ec408ff4b4c686ee042092eed21e3de1ec67cd352048250fed"
Write-Host "==> Expected SHA-256: $expectedHash"

if ($hash -eq $expectedHash) {
    Write-Host "==> [PASS] CHECKSUM VERIFICATION SUCCESSFUL! The ISO is byte-for-byte verified."
} else {
    Write-Error "==> [FAIL] CHECKSUM MISMATCH! Computed: $hash, Expected: $expectedHash"
}
