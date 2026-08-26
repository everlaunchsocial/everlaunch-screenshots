# autofile.ps1 — files EverLaunch screenshots into this repo's dated folder,
# commits, and pushes. Run by the Windows scheduled task
# "EverLaunch Screenshot Filer" every 2 minutes. No tokens here: git pushes
# with John's existing Windows credential manager login.
#
# TWO SOURCES (2026-08-26):
# 1. Downloads\everlaunch-*.png  — the desktop simulator tool's captures.
#    Filed to the shelf, then MOVED to the visible Desktop folder so John
#    can eyeball them (Downloads stays clean).
# 2. Desktop\EverLaunch Walk Shots\*.png|jpg — anything John drops there
#    (phone screenshots, transfers). COPIED to the shelf; the original
#    STAYS visible in the folder. Skip if a file of the same name was
#    already filed anywhere in the repo.

$ErrorActionPreference = 'SilentlyContinue'
$repo      = Split-Path -Parent $PSScriptRoot
$downloads = Join-Path $env:USERPROFILE 'Downloads'
$walkshots = Join-Path $env:USERPROFILE 'Desktop\EverLaunch Walk Shots'
if (-not (Test-Path $walkshots)) { New-Item -ItemType Directory -Path $walkshots | Out-Null }

Set-Location $repo

# Only files finished writing (untouched for 10+ seconds)
$cutoff = (Get-Date).AddSeconds(-10)
$toolShots = Get-ChildItem -Path $downloads -Filter 'everlaunch-*.png' -File |
             Where-Object { $_.LastWriteTime -lt $cutoff }
$dropShots = Get-ChildItem -Path $walkshots -Include '*.png','*.jpg','*.jpeg' -File -Recurse -Depth 0 |
             Where-Object { $_.LastWriteTime -lt $cutoff }

if (-not $toolShots -and -not $dropShots) { exit 0 }

git pull --rebase --quiet origin main

$dateFolder = Join-Path $repo (Get-Date -Format 'yyyy-MM-dd')
if (-not (Test-Path $dateFolder)) { New-Item -ItemType Directory -Path $dateFolder | Out-Null }

$filed = 0

# Source 1: simulator captures — file to shelf, then move original to the visible folder
foreach ($f in $toolShots) {
    $dest = Join-Path $dateFolder $f.Name
    if (Test-Path $dest) { $dest = Join-Path $dateFolder ("dup-" + (Get-Date -Format 'HHmmss') + "-" + $f.Name) }
    Copy-Item -Path $f.FullName -Destination $dest
    if ($?) {
        $filed++
        Move-Item -Path $f.FullName -Destination (Join-Path $walkshots $f.Name) -Force
    }
}

# Source 2: John's drop folder — copy to shelf once, original stays put
foreach ($f in $dropShots) {
    $already = Get-ChildItem -Path $repo -Recurse -Filter $f.Name -File |
               Where-Object { $_.FullName -notlike "*$walkshots*" } | Select-Object -First 1
    if ($already) { continue }
    Copy-Item -Path $f.FullName -Destination (Join-Path $dateFolder $f.Name)
    if ($?) { $filed++ }
}

if ($filed -eq 0) { exit 0 }

git add -A
git commit -m ("screenshots: {0} new ({1})" -f $filed, (Get-Date -Format 'yyyy-MM-dd HH:mm')) --quiet
git push --quiet origin main
