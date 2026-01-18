---
title: 'Manually remove all printer drivers'
date: '2011-11-16 09:17'
---

<span>Method 1 (Try First) - Force reinstall of a single corrupt driver</span>
==============================================================================

<span> </span>

1. <span>Find your driver name. (ex.“HP LaserJet 4050 Series PCL6”)</span>
2. <span>Remove all printers using the driver from step 1</span>
3. <span>Open Regedit. Remove the folder that matches the printer driver name under the following folder.  
    </span><span>(on 32 bit(x86) computers) </span><span>  
    “HKEY\_LOCAL\_MACHINE\\SYSTEM\\CurrentControlSet\\Control\\Print\\Environments\\Windows NT x86\\Drivers\\Version-3”  
    </span><span>(on 64 bit(x64) computers) </span><span>  
    “HKEY\_LOCAL\_MACHINE\\SYSTEM\\CurrentControlSet\\Control\\Print\\Environments\\Windows x64\\Drivers\\Version-3”</span>
4. <span>Restart the print spooler service</span>
5. <span>Reinstall the printers you removed. Windows should download the correct version of the driver and the printer should now work</span>

  
<span> </span>

<span>Method 2 (Last Resort) - Remove All printer drivers</span>
================================================================

1. <span>Reboot into safemode (you will need the bitlocker key if the machine is encrypted). Log in as Administrator</span>
2. <span>Remove the contents of the following folder  
    </span><span>(on 32 bit(x86) computers) </span><span>  
    “C:\\Windows\\System32\\spool\\drivers\\W32X86”  
    </span><span>(on 64 bit(x64) computers) </span><span>  
    “C:\\Windows\\System32\\spool\\drivers\\x64”</span>
3. <span>Open regedit. Remove all the folders under  
    </span><span>(on 32 bit(x86) computers)   
    </span><span>“HKEY\_LOCAL\_MACHINE\\SYSTEM\\CurrentControlSet\\Control\\Print\\Environments\\Windows NT x86\\Drivers\\Version-3”  
    </span><span>(on 64 bit(x64) computers) </span><span>  
    “HKEY\_LOCAL\_MACHINE\\SYSTEM\\CurrentControlSet\\Control\\Print\\Environments\\Windows x64\\Drivers\\Version-3”</span>
4. <span>Reboot into normal mode and log in as the user. GPO should reinstall the department printers and the proper drivers.</span>
5. <span>Verify All printers </span>