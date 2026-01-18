List of HASPUserSetup.exe Versions since 5.10 (July 2004)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
This device driver installer supports the Win32 and Windows x64 platforms.

The following list includes improvements, bug fixes, and other relevant
information regarding the HASP HL installer. It is arranged in descending 
chronological order.

Version 5.20 (October 2005)
==========================

Problems Solved
---------------
TD #2330: Driver installation failed when run directly from an installation CD.


Version 5.19 (August 2005)
==========================

New Features
-------------

Enhanced to support Windows x64 operation systems. 


Known Issues
------------

TD#2224: Protected Programs with either the Envelope's overlay support or data file 
         protection enabled, cannot open encrypted data when Symantec AntiVirus Corporate Edition version 10.0.1.1000 
         (Scan engine version 51.1.0.15) runs in the background. This pertains to the Windows 32-bit 
         platform. 
         Workaround - Download and install the following file from Aladdin's FTP site:
         ftp://ftp.ealaddin.com/pub/hasp/support/kb_files/SAV_10.zip 

All items listed below pertain to Windows 64-bit platforms. 

Does not support HASP4 API versions older than version 8.0.
	
Data files cannot be protected using the Envelope program.

No overlay support for applications protected with the Envelope program.

No support for PC-CardHASP (PCMCIA-based HASP) and Hardlock PCMCIA.

Problems Solved
----------------
All items listed below pertain to Windows 32-bit platforms. 

TD#2063: Blue screen displays when using 64-bit Hardware on 
         Windows XP SP2 (32Bit) with McAfee 8.0 Enterprise running in the background.

TD#2052: When the size of the aksdrvsetup.log file was too big, the driver installer 
         suspended. 

TD#1994: Redundant copy of aksusb.sys created in the %windows%\system32\setup\aladdin directory.

TD#1968: Java programs converted to executables with exe4j once protected with Envelope could not 
         run with recent HASP drivers.

TD#1948: Blue screen displayed on Windows 2003 SP1 when running .NET applications Enveloped with 
         IMAGE_EMULATION enabled.

TD#1928: Data encryption/decryption failed on Windows Server 2003 SP1 with McAfee Anti Virus v8 
         installed.

TD#1925: Message "Can not install automatic data protection" displayed when application was restarted 
         immediately after termination.  

TD#1833: Data protection error - "Unknown error" - displayed on Windows Server 2003. 


Version 5.15 (April 2005)
=========================

Problems Solved
---------------
TD#1008: When remotely logging to parallel HASP4 Net key, the API returns a hardware mismatch.

TD#1607: Data files cannot be protected when AVG 7.0 Anti Virus is installed.

TD#1708: Driver crashes when running encrypted data files for protected programs on
Win64 or Sempron machines with Win XP SP2 installed.

TD#1842: When running encryted data files for protected programs, the program sometimes suspends when
         key is unplugged.

TD#1856: Protected programs with encrypted data files crash due to a threading error.

Wi#1796: Protected programs with encrypted data files do not work with McAfee Enterprise 8.0 when the 
         overrun McAfee protection buffer is enabled.

TD#1047: Incorrect termination message when installing on Win 2000 platforms.

TD#1756: Cannot install drivers when another running windows setup is detected.

TD#1870: Reboot request even no update performed on Win9x platforms.


Version 5.12 (Dec 2004)
=========================

New Features
-------------

Drivers signed for Windows 2000 platforms.

Problems Solved
---------------
TD #1557: System crash when Norton Antivirus 2005 is installed and running.


Version 5.11 (Sept 2004)
========================

New Features
-------------
The drivers included support the HASP API version 8.0 onwards and 
all Hardlock API versions. In order to run HASP Applications with API 
versions before 8.0, you must also install the corresponding HASP driver for 
each API version.

Problems Solved
---------------
TD#303: Double generation of log files during installation.

TD#405: Incorrect copyright string.

TD#503: Older device driver installations overwrote the newly installed HASP HL drivers. 

TD#524: Applications protected with overlay support crashed. 

TD#710: Obsolete dialog displayed during installation.

TD#742: "Aladdin Knowledge Systems Key 00" appears instead of "Aladdin Knowledge Systems Key" 
        in Device Manager.

TD#826: Error messages lacking error strings.

TD#895: User not prompted to insert key during installation.

TD#993: Repeated logins on Win9X to (legacy)parallel keys failed.


Version 5.10 (July 2004)
========================

Known Issues
------------
The driver installer, haspdinst.exe, does not install drivers on Windows NT 4.0 and Windows 95 
platforms.

HASP HL drivers are not available for DOS applications. To run protected DOS 
applications you must install the corresponding HASP driver. 

Under Windows XP, a HASP HL key must have been previously connected to the computer to enable 
haspdinst.exe to display the correct HASP HL drivers version.

Under Windows 9x/ME, HL-Server won't detect Hardlock Server USB keys. You should 
install the required Hardlock drivers.

When running the HASP HL driver installer in a Terminal Server environment, the aksdrvsetup.log 
file is generated in the current user’s directory. 

Older device driver installations sometimes overwrite the HASP HL drivers. You should run the
haspdinst installer (haspdinst.exe -i) to fix the HASP HL installation. This scenario is only 
pertinent to Windows XP/2003 platforms. 

The current version of the drivers does not support applications wrapped with HASP HL 
Envelope with overlay encryption enabled. Should you attempt to start these applications, your system 
will crash and display a Blue Screen. 

If you use USB hubs which do not comply with all specifications of the USB standard, your
Aladdin USB keys might occasionally lose their enumeration.  If you plan to 
use USB keys on Microsoft platforms, refer to the Hardware Compatibility Lists
at http://www.microsoft.com/whdc/hcl/default.mspx

Some USB controllers cause Microsoft platforms to hang or
display a Blue Screen. This problem is not related to Aladdin drivers.

There are known limitations with various PCMCIA card reader brands used 
on AMD64 platforms. Check for chipset compatibility in the hardware specifications provided by the
manufacturer the of card reader. 

Due to a problem with the hardware of the PCI crypto programmer card, in some cases a Hardlock key will be 
recognized on the CPC address, however, encryption and read/write memory functions will fail. To avoid this problem,
you should explicitly set the address where to search for the Hardlock key.


Trademarks
----------
Aladdin Knowledge Systems Ltd. (c) 1985 - 2005. All rights reserved.
