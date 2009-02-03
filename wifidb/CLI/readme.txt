wiFiDB CLI Folder

1 -> Convert Txt to VS1
2 -> Manufactures Generation script

--------------------------------------------------------------
--------------------------------------------------------------
1			Convert Txt to VS1
--------------------------------------------------------------
--------------------------------------------------------------

This is a converter for the Vistumbler Summery Text file to the VS1 file.

I wrote this script in windows, but it can run on any OS that you have PHP on.

There are two ways to run this, script based PHP or the packaged EXE. The EXE there is no need to have PHP installed, 
the script file, you will need PHP installed.

To run the exe just put the properly formated Txt file from Vistumbler in the TXT folder, double click the converter.exe file to run it. 
Or go to a command propmt and run it via that.


To run this scrip stand-alone all you need to do is download the PHP package from [url]http://us2.php.net/get/php-5.2.6-Win32.zip/from/a/mirror[/url]

Browse to Y:\[Path to PHP]\bin\ 
               -  Where Y is the drive you have PHP installed in and [Path to PHP] is where PHP is stored on the drive.
Type "php X:\[Path to converter]\convert_vs1.php" 
               -  Where X is the drive you have the converter stored and [Path to converter] is the folder that the converter lives in.

The convert_vs1.php file searches the "text\" folder for vistumbler Text Summery files to convert
It is self aware of where it is living so there is no need to configure it


===================================================================

The convert_vs1() function:
This is the function that does all the work

$source : the dir and file that you are converting

"file"  : output the conversion to a VS1 file, [Supports "file", "File", or "FILE"] (I am working on having a database output too, via MySQL)



Example CLI output:
--------------------------------------------

=-=-=-=-=-=-=-=-=-=-==-=-=-=-=-=-Vistumbler Summery Text to VS1 converter=-=-=-=-=-=-=-=-=-=-==-=-=-=-=-=-
Directory: c:\users\pferland\Desktop\vistumbler\wifidb\CLI\text\

Files to Convert:
0 10602.txt


################=== Start conversion of c:\users\pferland\Desktop\vistumbler\wifidb\CLI\text\10602.txt ===################
1% - 2% - 3% -
Line: 365 - Wrong data type, dropping row
4% - 5% - 6% - 7% - 8% - 9% - 10% - 11% - 12% - 13% - 14% - 15% - 
16% - 17% - 18% - 19% - 20% - 21% - 22% - 23% - 24% - 25% - 26% - 
27% - 28% - 29% - 30% - 31% - 32% - 33% - 34% - 35% - 36% - 37% - 
38% - 39% - 40% - 41% - 42% - 43% - 44% - 45% - 46% - 47% - 48% - 
49% - 50% - 51% - 52% - 53% - 54% - 55% - 56% - 57% - 58% - 59% - 
60% - 61% - 62% - 63% - 64% - 65% - 66% - 67% - 68% - 69% - 70% - 
71% - 72% - 73% - 74% - 75% - 76% - 77% - 78% - 79% - 80% - 81% -
Line: 8660 - Wrong data type, dropping row
82% - 83% - 84% - 85% - 86% - 87% - 88% - 89% - 90% - 91% - 92% - 
93% - 94% - 95% - 96% - 97% - 98% - 99% - 100% - 

Total Number of Access Points : 10597
Total Number of GPS Points : 8916

-------
DONE!
Start Time : 11:48:16
 Stop Time : 11:51:38
-------


----------------------------------------
----------------------------------------
VERSION HISTORY
----------------------------------------
----------------------------------------

~~~~~~~~~~~~
~~~~~~~~~~~~
1.0
~~~~~~~~~~~~
~~~~~~~~~~~~
Initial release, no GPS conversion yet, just a file converter.

==============================

~~~~~~~~~~~~
~~~~~~~~~~~~
1.1
~~~~~~~~~~~~
~~~~~~~~~~~~
Fixed most of the GPS issues, is now converting from DD.dddd to DDMM.mmmm(DDDmm.mmmm also supported)
==============================

~~~~~~~~~~~~
~~~~~~~~~~~~
1.2
~~~~~~~~~~~~
~~~~~~~~~~~~
Replaced old GPS conversion function with newer better code.
==============================




--------------------------------------------------------------
--------------------------------------------------------------
2		Manufactures Generation script
--------------------------------------------------------------
--------------------------------------------------------------

All you need to do is run the manufmac.exe or manufmac.php script and it will download the 
text file from: http://standards.ieee.org/regauth/oui/oui.txt

then it converts it to a WiFiDB compatible PHP (manufactures.inc.php) file 
and a Vistumbler compatible INI(manufactures.ini) file.


----------------------------------------
----------------------------------------
VERSION HISTORY
----------------------------------------
----------------------------------------

~~~~~~~~~~~~
~~~~~~~~~~~~
1.1
~~~~~~~~~~~~
~~~~~~~~~~~~
Initial release, was just WiFiDB generation, no Vistumbler yet.

==============================

~~~~~~~~~~~~
~~~~~~~~~~~~
1.1.1
~~~~~~~~~~~~
~~~~~~~~~~~~
1-> Added in Vistumbler output. 
2-> WiFiDB output was missing the ending ?> and had a few parse errors due to 
	non-cancled double quotes in Manufactures name
==============================

~~~~~~~~~~~~
~~~~~~~~~~~~
1.1.2
~~~~~~~~~~~~
~~~~~~~~~~~~
1-> Forgot to add in the Debug variable and wrapper around the line echo, performance was severley hindered.
2-> Changed console header and layout a little
==============================

~~~~~~~~~~~~
~~~~~~~~~~~~
1.1.3
~~~~~~~~~~~~
~~~~~~~~~~~~
1-> Compiled into manufmac.exe for ease of use
==============================
