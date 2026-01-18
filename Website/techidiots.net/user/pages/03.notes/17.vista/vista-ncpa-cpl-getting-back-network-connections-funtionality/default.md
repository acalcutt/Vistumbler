---
title: 'Vista - NCPA.CPL - getting back network connections funtionality'
date: '04-04-2023 10:56'
media_order: 'regedit.jpg,beforeafter.jpg'
visible: true
---

1.) Control Panel Icon
----------------------

In vista the ncpa.cpl file has been purposly removed from apearing in the control panel. You can renable it by deleting a registry key. "HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Control Panel\\don't load\\" is where microsoft puts cpls that it does not want to apear in control panel. You can delete "HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Control Panel\\don't load\\ncpa.cpl" and you will then have a "Network Connections" icon in your start menu.

![regedit](regedit.jpg "regedit")

![beforeafter](beforeafter.jpg "beforeafter")