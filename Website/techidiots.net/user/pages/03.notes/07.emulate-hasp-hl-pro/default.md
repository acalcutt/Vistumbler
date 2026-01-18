---
title: 'Emulate HASP HL Pro'
date: '08-11-2012 17:04'
visible: true
published: false
---

Files and Notes
---------------

Download the required tools here
[HaspHL_Tools.zip](HaspHL_Tools.zip)

\*note that haspmon32 tools need to be run from a 32bit machine. I used a x86 version of XP to dump the key. The other tools should work in x64 windows\*

Dump HASP HL usb key to file
----------------------------

**1.)** Install v5.2 hasp hl drivers (HaspHL\_Tools.zip\\HASP key 5.2 driver\\HASPUserSetup.exe). I have not tested, but I read newer drivers may not work.

**2.)** Open 'Toro Aladdin Dongles Monitor' (HaspHL\_Tools.zip\\haspmon32\\Toro Aladdin Dongles Monitor.exe). With the usb hasp connected, go into the application that requires the hasp and perform an action that requires the hasp in the machine.

**3.)** Go back to 'Toro Aladdin Dongles Monitor'. If you program used the HASP you should now see text. Look for a line that looks like this

PW1=**XXXXX** (**0xPW1**) , PW1=**XXXXX** (**0xPW2**)

**4.)** Now that you have the two passwords, use h5dmp.exe (HaspHL\_Tools.zip\\haspmon32\\h5dmp.exe) to dump the usb hasp

Use the command "h5dmp.exe 0xPW1 0xPW2". If all goes well you should tell you it was successful and you should now have two files (hasp.dmp, hhl\_mem.dmp)

Create Multikey registry file from dump
---------------------------------------

**1.)** Use 'UniDumpToReg' (HaspHL\_Tools.zip\\UniDumpToReg\\UniDumpToReg.exe) to export a multikey registry file. Open the hasp dump you just created (make sure hasp.dmp abd hhl\_mem.dmp are in the same directory). Use the 'Chingachguk based Hasp HL' and click 'Go' to export. This will generate a registry key to the same directory as your dump.

**2.)** Edit the generated reg key.

**Change**  
"HKEY\_LOCAL\_MACHINE\\System\\CurrentControlSet\\NEWHASP\\Services\\Emulator\\HASP\\Dump\\"  
to

"HKEY\_LOCAL\_MACHINE\\System\\CurrentControlSet\\MultiKey\\Dumps\\"

**Add**

"DongleType"=dword:00000001

**3.)** Once you make the above changes you should now have what you need to emulate the hasp using multikey. Unplug the usb hasp.

Emulate your hasp using multikey and the created registry file
--------------------------------------------------------------

**1.)** Add the registry key you created to the registry. Install Multikey by running install.cmd

For x86 windows run 'HaspHL\_Tools.zip\\Multikey\\MultiKey32\\install.cmd'

For x64 windows run 'HaspHL\_Tools.zip\\Multikey\\MultiKey64\\install.cmd' (note that you will either need to disable driver signing enforcement or sign the MultiKey.sys file with something like 'Driver Signature Enforcement Overrider' in a x64 OS vista and above)

**2.)** After running install.bat you should see the system install a virtual hasp. It should show up under 'Universal Serial Bus controllers' in device manager as 'Aladdin USB Key' and 'Aladin HASP Key' (this name may be different if you are using a different version of the drivers)

**3.)** you program should now work without the actual usb hasp. DONE!
