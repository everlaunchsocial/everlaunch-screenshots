# everlaunch-screenshots

The "go look" shelf. Screenshots of the EverLaunch app, filed automatically into
dated folders (`YYYY-MM-DD/`), newest date = newest look at the app.

**For any AI reviewing the app's UI — start here:**

```
https://raw.githubusercontent.com/everlaunchsocial/everlaunch-screenshots/main/LATEST.md
```

`LATEST.md` is rebuilt every time new screenshots are filed. It lists the newest
day's crawl reports and every image as a direct link, so you never have to list
a folder or guess a filename. Read the crawl report first — it is plain text and
says which pages are broken; the images are there to look at if you can.

Or browse the folder for a date you were given, e.g. `2026-08-25/`. Filenames are
`everlaunch-<device>-<page>-<HHMMSS>.png|jpg` — device simulated, page, capture
time (Eastern).

**How files get here:** John captures with the device-simulator tool at
https://app-feel-test.black-hall-0b18.workers.dev (Screenshot button or timer
mode). PNGs auto-download to his Downloads folder; a scheduled task on his
machine (`tools/autofile.ps1`, every 2 minutes) moves them into the dated
folder here, commits, and pushes.

**Rules:** app screenshots only. Never secrets, credentials, or customer data.
