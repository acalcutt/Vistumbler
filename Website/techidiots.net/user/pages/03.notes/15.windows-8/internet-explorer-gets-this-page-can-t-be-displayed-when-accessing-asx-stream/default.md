---
title: 'Internet Explorer gets "This page can''t be displayed" when accessing asx stream'
date: '2013-02-05 18:40'
---

When accessing a asx file in internet explorer 10, browser gets a "This page can't be displayed" error. This seems to be the same bug as kb974538 ( <http://support.microsoft.com/kb/974538> ), which seems to be caused by Live Photo Gallery

To fix this in Windows 8 x64 with IE 10, I used the fix for windows 7 that microsoft offered (copied below)

1. <span class="visualHighlight">On an account with Administration privileges, choose Start and type notepad.exe.</span>
2. <span class="visualHighlight">Copy and paste the contents of the box below.</span>
3. <span class="visualHighlight">Save the file as fix.reg.</span>
4. <span class="visualHighlight">Double-click on the fix.reg file to add it to your registry.  
      
    ------------------------------------------------------------------   
    Windows Registry Editor Version 5.00   
      
    \[HKEY\_LOCAL\_MACHINE\\SOFTWARE\\Classes\\.asf\]   
    @="WMP11.AssocFile.ASF"   
    \[HKEY\_LOCAL\_MACHINE\\SOFTWARE\\Classes\\.asx\]   
    @="WMP11.AssocFile.ASX"   
    \[HKEY\_LOCAL\_MACHINE\\SOFTWARE\\Classes\\.avi\]   
    @="WMP11.AssocFile.AVI"   
    \[HKEY\_LOCAL\_MACHINE\\SOFTWARE\\Classes\\.wmv\]   
    @="WMP11.AssocFile.WMV"   
    ------------------------------------------------------------------</span>