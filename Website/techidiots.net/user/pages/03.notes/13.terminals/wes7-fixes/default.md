---
title: 'WES7 Fixes'
date: '03-04-2013 17:02'
visible: true
---

Fixes for termianls using WES7. Tested with HP T510.
---------------------------------------------------------------------------------------------

**Force Auto Logon on terminal when a user logs off**  
Download: [ForceAutoLogon.zip](ForceAutoLogon.zip)  
Prevents a user from logging off the automatically logged on user. If the user does log off the terminal will automatically log back in. Shift must be held to prevent automatic login after this registry key is added.  

This fix uses the "ForceAutoLogon" registry key "In addition to logging on an account automatically, the ForceAutoLogon setting also logs you back on after you log off. It is designed for machines running as kiosks or other publically-accessible scenarios where you want the kiosk account to be the only account available. Even if the user manages to fiddle with the machine and log off the kiosk user, the logon system will just log the kiosk user back on."  
 
**Disable Lock on default hp terminal user**  
Download: [DisableLock.zip](DisableLock.zip)  
Disable lock on the default HP terminal "User" account. This prevents someone from locking the screen with a user they don't have the password for.  
 

**Hide Terminal os drive "C:" and Ramdrive "Z:" so they are not redirected to RDP**  
Download: [HideTerminalDrives.zip](HideTerminalDrives.zip)  
Uses 'NoDrives' registry key to hide the local terminal C: and Z: so they so not get passed through to rdp when drive redirection is enabled for usb thumbdrive passthrough. (used http://www.wisdombay.com/hidedrive/ to calculate the NoDrives value)  