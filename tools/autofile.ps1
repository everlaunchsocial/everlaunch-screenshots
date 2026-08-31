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
$toolShots = Get-ChildItem -Path $downloads -File |
             Where-Object { $_.Name -like 'everlaunch-*' -and $_.Extension -in '.png', '.jpg' -and $_.LastWriteTime -lt $cutoff }
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

# Rebuild LATEST.md — the one fixed address an outside AI (the Router) can be
# pointed at. Its models reach GitHub and nothing else, and cannot list a
# folder, so without a written index they have no way to learn what is here.
$raw = 'https://raw.githubusercontent.com/everlaunchsocial/everlaunch-screenshots/main'
$newest = Get-ChildItem -Path $repo -Directory |
          Where-Object { $_.Name -match '^\d{4}-\d{2}-\d{2}$' } |
          Sort-Object Name -Descending | Select-Object -First 1
if ($newest) {
    $shots = Get-ChildItem $newest.FullName -File |
             Where-Object { $_.Extension -in '.png', '.jpg' } | Sort-Object Name
    $reports = Get-ChildItem $newest.FullName -File -Filter 'crawl-report*.md' | Sort-Object Name
    $out = @()
    $out += '# Latest screenshots'
    $out += ''
    $out += "Rebuilt automatically whenever new screenshots are filed. Newest day: **$($newest.Name)** - $($shots.Count) image(s)."
    $out += ''
    $out += 'Every link below is a direct file. Fetch one to read it; no login, no folder listing needed.'
    $out += ''
    if ($reports) {
        $out += '## Crawl reports (plain text - start here)'
        $out += ''
        foreach ($r in $reports) { $out += "- [$($r.Name)]($raw/$($newest.Name)/$($r.Name))" }
        $out += ''
    }
    $out += '## Images'
    $out += ''
    foreach ($s in $shots) { $out += "- [$($s.Name)]($raw/$($newest.Name)/$($s.Name))" }
    $out += ''
    $out += '## Earlier days'
    $out += ''
    $days = Get-ChildItem -Path $repo -Directory |
            Where-Object { $_.Name -match '^\d{4}-\d{2}-\d{2}$' } |
            Sort-Object Name -Descending | Select-Object -First 14
    foreach ($d in $days) { $out += "- $($d.Name)" }
    $out += ''
    Set-Content -Path (Join-Path $repo 'LATEST.md') -Value ($out -join "`n") -Encoding utf8
}

git add -A
git commit -m ("screenshots: {0} new ({1})" -f $filed, (Get-Date -Format 'yyyy-MM-dd HH:mm')) --quiet
git push --quiet origin main
