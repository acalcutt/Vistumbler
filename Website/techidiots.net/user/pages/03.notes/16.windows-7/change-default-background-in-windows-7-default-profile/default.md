---
title: 'Change default background in Windows 7 default profile'
date: '2010-06-07 16:30'
---

REG.EXE LOAD HKU\\TempDefaultUser "C:\\Users\\Default\\ntuser.dat"

REG.EXE ADD "HKU\\TempDefaultUser\\Software\\Policies\\Microsoft\\Windows\\Personalization" /v ThemeFile /d "C:\\Windows\\Resources\\Themes\\aero.theme" /f

 REG.EXE UNLOAD HKU\\TempDefaultUser