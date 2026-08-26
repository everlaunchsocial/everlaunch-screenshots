# everlaunch-screenshots

The "go look" shelf. Screenshots of the EverLaunch app, filed automatically into
dated folders (`YYYY-MM-DD/`), newest date = newest look at the app.

**For any AI reviewing the app's UI:** browse the folder for the date you were
given, e.g. `2026-08-25/`. Filenames are
`everlaunch-<device>-<n>-<HHMMSS>.png` — device simulated, shot number, capture
time (Eastern).

**How files get here:** John captures with the device-simulator tool at
https://app-feel-test.black-hall-0b18.workers.dev (Screenshot button or timer
mode). PNGs auto-download to his Downloads folder; a scheduled task on his
machine (`tools/autofile.ps1`, every 2 minutes) moves them into the dated
folder here, commits, and pushes.

**Rules:** app screenshots only. Never secrets, credentials, or customer data.
