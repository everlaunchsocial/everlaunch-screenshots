# autofile.ps1 — moves everlaunch-*.png from Downloads into this repo's dated
# folder, commits, and pushes. Run by the Windows scheduled task
# "EverLaunch Screenshot Filer" every 2 minutes. No tokens here: git pushes
# with John's existing Windows credential manager login.

$ErrorActionPreference = 'SilentlyContinue'
$repo      = Split-Path -Parent $PSScriptRoot
$downloads = Join-Path $env:USERPROFILE 'Downloads'

Set-Location $repo

# Only files finished downloading (untouched for 10+ seconds)
$cutoff = (Get-Date).AddSeconds(-10)
$shots = Get-ChildItem -Path $downloads -Filter 'everlaunch-*.png' -File |
         Where-Object { $_.LastWriteTime -lt $cutoff }
if (-not $shots) { exit 0 }

git pull --rebase --quiet origin main

$dateFolder = Join-Path $repo (Get-Date -Format 'yyyy-MM-dd')
if (-not (Test-Path $dateFolder)) { New-Item -ItemType Directory -Path $dateFolder | Out-Null }

$moved = 0
foreach ($f in $shots) {
    $dest = Join-Path $dateFolder $f.Name
    if (Test-Path $dest) { $dest = Join-Path $dateFolder ("dup-" + (Get-Date -Format 'HHmmss') + "-" + $f.Name) }
    Move-Item -Path $f.FullName -Destination $dest
    if ($?) { $moved++ }
}
if ($moved -eq 0) { exit 0 }

git add -A
git commit -m ("screenshots: {0} new ({1})" -f $moved, (Get-Date -Format 'yyyy-MM-dd HH:mm')) --quiet
git push --quiet origin main
