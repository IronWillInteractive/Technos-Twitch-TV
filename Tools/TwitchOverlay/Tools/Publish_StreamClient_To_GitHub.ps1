param(
  [string]$ClientFolder = "",
  [string]$GitHubUser = "",
  [string]$RepositoryName = "",
  [string]$StreamFolderName = ""
)

$ErrorActionPreference = "Stop"

function Write-Step($Message) { Write-Host "`n==> $Message" -ForegroundColor Cyan }
function Write-Ok($Message) { Write-Host "[OK] $Message" -ForegroundColor Green }
function Write-Warn($Message) { Write-Host "[WARN] $Message" -ForegroundColor Yellow }
function Require-Command($Name, $WingetId) {
  if (Get-Command $Name -ErrorAction SilentlyContinue) { Write-Ok "$Name found"; return }
  if (-not (Get-Command winget -ErrorAction SilentlyContinue)) { throw "$Name is missing and winget is not available. Install $Name, then rerun." }
  Write-Step "Installing $Name via winget"
  winget install --id $WingetId -e --source winget --accept-package-agreements --accept-source-agreements
  $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
  if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) { throw "$Name still was not found after install. Restart terminal and rerun." }
}
function Safe-Slug($Value, $Fallback) {
  $v = ($Value | Out-String).Trim()
  if (-not $v) { $v = $Fallback }
  $v = $v -replace '[^a-zA-Z0-9_ -]', ''
  $v = $v -replace '\s+', '_'
  $v = $v -replace '_+', '_'
  if (-not $v) { $v = $Fallback }
  return $v
}

Write-Step "Checking dependencies"
Require-Command git "Git.Git"
Require-Command gh "GitHub.cli"

if (-not $GitHubUser) { $GitHubUser = Read-Host "GitHub username" }
if (-not $RepositoryName) { $RepositoryName = Read-Host "Repository name to create/use" }
if (-not $ClientFolder) { $ClientFolder = Read-Host "Path to generated *_StreamClient folder" }

$ClientFolder = (Resolve-Path $ClientFolder).Path
if (-not (Test-Path (Join-Path $ClientFolder "index.html"))) { throw "Client folder must contain root index.html" }
if (-not (Test-Path (Join-Path $ClientFolder "viewer\index.html"))) { throw "Client folder must contain viewer/index.html" }

if (-not $StreamFolderName) { $StreamFolderName = Safe-Slug ((Split-Path $ClientFolder -Leaf) -replace '_StreamClient$','') "stream" }
$StreamFolderName = Safe-Slug $StreamFolderName "stream"

Write-Step "Authenticating GitHub CLI"
try { gh auth status | Out-Null } catch { gh auth login }

$RepoFull = "$GitHubUser/$RepositoryName"
Write-Step "Ensuring public repo exists: $RepoFull"
try {
  gh repo view $RepoFull | Out-Null
  Write-Ok "Repo exists"
} catch {
  gh repo create $RepoFull --public --confirm
}

$WorkRoot = Join-Path $env:TEMP "TwitchOverlayPages_$RepositoryName"
if (Test-Path $WorkRoot) { Remove-Item $WorkRoot -Recurse -Force }
Write-Step "Cloning repo workspace"
gh repo clone $RepoFull $WorkRoot
Set-Location $WorkRoot

Write-Step "Copying selected client to GitHub Pages root"
Get-ChildItem -Force | Where-Object { $_.Name -notin @('.git','.github','streams') } | Remove-Item -Recurse -Force
Copy-Item (Join-Path $ClientFolder '*') $WorkRoot -Recurse -Force

Write-Step "Archiving this stream under streams/$StreamFolderName"
$ArchiveFolder = Join-Path $WorkRoot ("streams\" + $StreamFolderName)
if (Test-Path $ArchiveFolder) { Remove-Item $ArchiveFolder -Recurse -Force }
New-Item -ItemType Directory -Force -Path $ArchiveFolder | Out-Null
Copy-Item (Join-Path $ClientFolder '*') $ArchiveFolder -Recurse -Force

Write-Step "Writing GitHub Pages Actions workflow"
$WorkflowDir = Join-Path $WorkRoot ".github\workflows"
New-Item -ItemType Directory -Force -Path $WorkflowDir | Out-Null
@'
name: Deploy Static Stream Client

on:
  push:
    branches: [ main ]
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: pages
  cancel-in-progress: false

jobs:
  deploy:
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      - name: Setup Pages
        uses: actions/configure-pages@v5
      - name: Upload artifact
        uses: actions/upload-pages-artifact@v3
        with:
          path: '.'
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4
'@ | Set-Content -Encoding UTF8 (Join-Path $WorkflowDir "pages.yml")

Write-Step "Committing and pushing"
git config user.name "$GitHubUser"
git config user.email "$GitHubUser@users.noreply.github.com"
git add .
if (git diff --cached --quiet) { Write-Warn "No changes to commit." } else { git commit -m "Deploy stream client: $StreamFolderName" }
git branch -M main
git push -u origin main

Write-Step "Trying to enable GitHub Pages Actions deployment"
try { gh api -X POST "repos/$RepoFull/pages" -f build_type=workflow | Out-Null } catch { Write-Warn "Pages may already be enabled or needs manual enable in repo Settings > Pages > GitHub Actions." }

$RootUrl = "https://$GitHubUser.github.io/$RepositoryName/"
$ArchiveUrl = "https://$GitHubUser.github.io/$RepositoryName/streams/$StreamFolderName/"
Write-Host "`nPlease wait while GitHub Pages deploys. This can take a few minutes. Polling for up to 5 minutes..." -ForegroundColor Yellow
$deadline = (Get-Date).AddMinutes(5)
$live = $false
while ((Get-Date) -lt $deadline) {
  try {
    $r = Invoke-WebRequest -Uri $RootUrl -UseBasicParsing -TimeoutSec 12
    if ($r.StatusCode -ge 200 -and $r.StatusCode -lt 400) { $live = $true; break }
  } catch {}
  Start-Sleep -Seconds 15
}

if ($live) { Write-Ok "Live root client: $RootUrl" } else { Write-Warn "Deploy may still be building. Check the Actions tab if it is not live yet." }
Write-Host "Share link: $RootUrl" -ForegroundColor Green
Write-Host "Archived stream folder: $ArchiveUrl" -ForegroundColor Green
Start-Process $RootUrl
