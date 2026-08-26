' Launch the screenshot filer with NO window at all.
'
' The scheduled task called powershell.exe directly with -WindowStyle Hidden. That flag is
' honoured too late: Windows creates the console host first, PowerShell starts, and only
' then hides itself — so a black box flashes on the desktop every two minutes, all day.
'
' WScript.Shell's Run with windowStyle 0 never creates the window in the first place, which
' is why the WorkChats Sync task on this machine has always been silent. Same pattern here.
' The trailing False means fire-and-forget: do not block waiting for the script to finish.
Set s = CreateObject("WScript.Shell")
s.Run "powershell.exe -NoProfile -ExecutionPolicy Bypass -File ""C:\Users\john\Documents\GitHub\everlaunch-screenshots\tools\autofile.ps1""", 0, False
