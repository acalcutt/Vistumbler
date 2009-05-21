WiFiDB CLI [aka Tools] Folder
http://www.randomintervals.com/


GNU Header:
	This program is free software; you can redistribute it and/or modify it under
	the terms of the GNU General Public License version 2, as published by the 
	Free Software Foundation.   This program is distributed in the hope that it 
	will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty 
	of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General 
	Public License for more details. You should have received a copy of the GNU 
	General Public License along with this program; if not, you can get it at: 
	
		Free Software Foundation, Inc.,
		51 Franklin St, Fifth Floor
		Boston, MA  02110-1301 USA
	
	Or go here:  http://www.gnu.org/licenses/gpl-2.0.txt



CONTENTS:

1 -> WiFiDB Daemon (daemon folder in the tools dir)
2 -> Convert Txt to VS1 (Converter.exe | converter.php).
3 -> Manufactures Generation script (manufmac.exe | manufmac.php).
4 -> Wireless Database Batch Import script [command line only].




--------------------------------------------------------------
--------------------------------------------------------------
1		WiFiDB Daemon
--------------------------------------------------------------
--------------------------------------------------------------

  The WiFiDB daemon is just a php script that I wrote that runs in the backgound
  and checks a fils_tmp table to see if there are any files wating to be imported.
  If there is a file or more then one, it will atempt to import them.

  There is a file called rund.php that starts/stops/and restarts the daemon. To use
  type 'php rund.php [start,stop,restart]'. This script will only run on linux 
  based systems. Windows is NOT supported. This is also an optional item it is not
  needed at all to run WiFiDB. To turn it on or off in the DB itself go to the 
  config.inc.php in the lib folder of where you have your WiFiDB installed, and 
  change the variable named sched to 0 (off) or 1 (on).

  To change settings for the daemon itself go to the daemon folder inside the tools 
  folder and open the config.inc.php file and change sleep to the number of seconds
  that you want to sleep before checking the files_tmp again, there is a safety so
  you cannot set it less then 5 min.


Usage: 
	rund.php {start|stop|restart|version(NIY)|help(NIY)}

		start			-	Start The WiFiDB Daemon.

		stop			-	Stop the WiFiDB Daemon.

		restart			-	Restart the WiFiDB Daemon.

		version (NIY)		-	The Version History that is below, just CLI.

		help (NIY)		-	This just on the CLI.

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
Initial release, just scheduled imports.
==============================

~~~~~~~~~~~~
~~~~~~~~~~~~
1.1
~~~~~~~~~~~~
~~~~~~~~~~~~
Windows capable, I still wouldn't recommend it, but it works. Although it has a cmd window of its own, so to stay running it needs to stay open.
Better intergration with scheduling.php, added in Current AP, Importing? (Yes/No), Current AP/Total APs.
==============================

~~~~~~~~~~~~
~~~~~~~~~~~~
1.2
~~~~~~~~~~~~
~~~~~~~~~~~~
There was an issue with it sometimes not skipping a file if the hashes matched up.
Some spelling errors in messages.
For some reason the rund.php script sometimes would not properly execute the daemon 
	script, and result in rund.php saying the daemon has started, yet if you did 
	a ps -ax | grep "wifidbd", there would be no daemon running. Changing 
	popen($cmd, 'r') from 'r' to 'w' fixed this.

==============================


--------------------------------------------------------------
--------------------------------------------------------------
2			Convert Txt to VS1
--------------------------------------------------------------
--------------------------------------------------------------

This is a converter for the Vistumbler Summery Text file to the VS1 file.

I wrote this script in windows, but it can run on any OS that you have PHP on.

There are two ways to run this, script based PHP or the packaged EXE. The EXE there is no need to have PHP installed, 
the script file, you will need PHP installed.

To run the exe just put the properly formated Txt file from Vistumbler in the TXT folder, double click the converter.exe file to run it. 
Or go to a command propmt and run it via that.


To run this scrip stand-alone all you need to do is download the PHP package from [http://us2.php.net/get/php-5.2.6-Win32.zip/from/a/mirror]

Browse to Y:\[Path to PHP]\bin\ 
               -  Where Y is the drive you have PHP installed in and [Path to PHP] is where PHP is stored on the drive.
Type "php X:\[Path to converter]\convert_vs1.php" 
               -  Where X is the drive you have the converter stored and [Path to converter] is the folder that the converter lives in.

The convert_vs1.php file searches the "text\" folder for vistumbler Text Summery files to convert.
It is self aware of where it is living so there is no need to configure it.


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
1-> Initial release, no GPS conversion yet, just a file converter.

==============================

~~~~~~~~~~~~
~~~~~~~~~~~~
1.1
~~~~~~~~~~~~
~~~~~~~~~~~~
1-> Fixed most of the GPS issues, is now converting from DD.dddd to DDMM.mmmm(DDDmm.mmmm also supported)
==============================

~~~~~~~~~~~~
~~~~~~~~~~~~
1.2
~~~~~~~~~~~~
~~~~~~~~~~~~
1-> Replaced old GPS conversion function with newer better code.

~~~~~~~~~~~~
~~~~~~~~~~~~
1.3
~~~~~~~~~~~~
~~~~~~~~~~~~
1-> Recompiled the EXE and compressed it down to ~600KB from 1.3MB. No code changes.
==============================




--------------------------------------------------------------
--------------------------------------------------------------
3		Manufactures Generation script
--------------------------------------------------------------
--------------------------------------------------------------

  All you need to do is run the manufmac.exe or manufmac.php script and it 
  will download the text file from: http://standards.ieee.org/regauth/oui/oui.txt

  Then it converts it to a WiFiDB compatible PHP (manufactures.inc.php) file 
  and a Vistumbler compatible INI (manufactures.ini) file.


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
2-> WiFiDB output was missing the ending ?> and had a few parse errors due to.
	non-cancled double quotes in Manufactures name.
==============================

~~~~~~~~~~~~
~~~~~~~~~~~~
1.1.2
~~~~~~~~~~~~
~~~~~~~~~~~~
1-> Forgot to add in the Debug variable and wrapper around the line echo,
	performance was severley hindered.
2-> Changed console header and layout a little.
==============================

~~~~~~~~~~~~
~~~~~~~~~~~~
1.1.3
~~~~~~~~~~~~
~~~~~~~~~~~~
1-> Compiled into manufmac.exe for ease of use.
==============================

~~~~~~~~~~~~
~~~~~~~~~~~~
1.2.0
~~~~~~~~~~~~
~~~~~~~~~~~~
1-> Fixed a bug where I forgot to replace the value of $cwd with getcwd().
2-> Changed the creation of the files so that they are both created at the same time.
==============================





--------------------------------------------------------------
--------------------------------------------------------------
4		Wireless Database Batch Import script [command line only]
--------------------------------------------------------------
--------------------------------------------------------------

Usage: 
	import.php --wifidb="/var/www/wifidb" --user="admin" --notes="These, are the notes!" --title="Import"

	--wifidb	-	The folder that is where WiFiDB is installed
					this is so that we can use the config file to
					connect to MySQL and import the Access points
	--user		-	The User name that will show up as importing
					the all the access points into the database
					for a batch import.
	--notes		-	This will be put in each list that is imported
					into the database.
	--title		-	This will give a title to the batch import,
					each list will have a title of 'Batch: *title*'

All the options are needed, except for the notes and possibly the title if you want 
all your titles to be "Batch: ". Otherwise they will be "Batch: Import", or whatever 
you put as the Batch Import title name that will replace 'Import' in this example.

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
1-> Initial release
==============================

~~~~~~~~~~~~
~~~~~~~~~~~~
1.2
~~~~~~~~~~~~
~~~~~~~~~~~~
1-> Changed layout so it is more readable
2-> Fixed a few bugs with the switches
3-> Added in bad character stripping.
==============================

~~~~~~~~~~~~
~~~~~~~~~~~~
1.3
~~~~~~~~~~~~
~~~~~~~~~~~~
1-> Skipped, was an experimental version

~~~~~~~~~~~~
~~~~~~~~~~~~
1.4
~~~~~~~~~~~~
~~~~~~~~~~~~
1-> Forgot to add Change log for 1.4, 
    logging was added, but not to SVN yet
==============================

~~~~~~~~~~~~
~~~~~~~~~~~~
1.5
~~~~~~~~~~~~
~~~~~~~~~~~~
1-> Added in Support to Skip files if they have already been imported, 
    the comparison is based off the file name and file size. all data 
    is stored in `wifi`.`files`. the only data that is kept is filename, 
    size, and date/time of import.
2-> Fixed up the Loging some more. had some formating issues. 
		There are two logging levels: 
		  1) is just what was updated/imported, 
		  2) is all the details of what was imported/updated
==============================

~~~~~~~~~~~~
~~~~~~~~~~~~
1.5.1
~~~~~~~~~~~~
~~~~~~~~~~~~
1-> The GPS Table for each AP was still being created with the MySQL 
	default storage engine (MyISAM in most cases). The Default is now
	hard coded as InnoDB.
2-> Minor code changes to try something new.
==============================
