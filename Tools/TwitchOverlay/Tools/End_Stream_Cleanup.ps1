param(
  [string]$RepositoryFolder = "",
  [string]$StreamFolderName = ""
)
$ErrorActionPreference = "Stop"
function Write-Step($Message) { Write-Host "`n==> $Message" -ForegroundColor Cyan }
function Safe-Slug($Value, $Fallback) {
  $v = ($Value | Out-String).Trim()
  if (-not $v) { $v = $Fallback }
  $v = $v -replace '[^a-zA-Z0-9_ -]', ''
  $v = $v -replace '\s+', '_'
  $v = $v -replace '_+', '_'
  if (-not $v) { $v = $Fallback }
  return $v
}
if (-not (Get-Command git -ErrorAction SilentlyContinue)) { throw "git is required." }
if (-not $RepositoryFolder) { $RepositoryFolder = Read-Host "Path to local GitHub Pages repo folder" }
$RepositoryFolder = (Resolve-Path $RepositoryFolder).Path
if (-not (Test-Path (Join-Path $RepositoryFolder ".git"))) { throw "Repository folder must contain .git" }
if (-not $StreamFolderName) { $StreamFolderName = Read-Host "Stream folder to remove from streams/" }
$StreamFolderName = Safe-Slug $StreamFolderName "stream"
Set-Location $RepositoryFolder
$Target = Join-Path $RepositoryFolder ("streams\" + $StreamFolderName)
if (-not (Test-Path $Target)) { Write-Host "No stream folder found at $Target" -ForegroundColor Yellow; exit 0 }
Write-Step "Removing ended stream folder: streams/$StreamFolderName"
Remove-Item $Target -Recurse -Force
git add -A
if (git diff --cached --quiet) { Write-Host "No cleanup changes to commit." -ForegroundColor Yellow; exit 0 }
git commit -m "End stream cleanup: $StreamFolderName"
git push
Write-Host "Cleaned up and pushed stream folder deletion." -ForegroundColor Green
