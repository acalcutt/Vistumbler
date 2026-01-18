---
title: 'Enable missing power profiles (Power Saver/High Performance)'
date: '16-11-2014 12:40'
visible: true
---

<span>If you disable connected standby all Windows power plans are displayed and all advanced power functions are available.</span>

Use Regedit and change the below:  
HKEY\_LOCAL\_MACHINE\\SYSTEM\\CurrentControlSet\\Control\\Power  
Change the value of the key CsEnabled from 1 to 0 and reboot.

<span>1 means connected standby enabled and 0 disabled.</span>

<span>  
</span>

<span>Found at (http://en.community.dell.com/support-forums/mobile-devices/f/4586/t/19578910)</span>