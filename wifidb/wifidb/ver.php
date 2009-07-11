<?php
include('lib/config.inc.php');
include('lib/database.inc.php');
pageheader("Version Page");
?>
<font face="Courier New">
		<div align="left">
		<p align="center"><font size="7"><b>WiFiDB Version History</b></font></p>
		<table border="0" cellpadding="4">
			<tr>
				<td>Project Name(pseudo-name)...</td><td><b>WiFiDB</b> </td>
			</tr>
			<tr>
				<td>Project State...............</td><td><b>Alpha (planning and early dev)</b><td>
			</tr>
			<tr>
				<td>Project Dev(s)..............</td><td><b><a class="links" href="http://forum.techidiots.net/forum/memberlist.php?mode=viewprofile&u=6">PFerland</a></b><td>
			</tr>
		</table>
		
		<table width="100%" border="2" id="16b3">
			<tr><td style="border-style: solid; border-width: 1px" height="26">Author: Phillip Ferland</td>
			<td style="border-style: solid; border-width: 1px" height="26">Version: 0.16 Build 3</td></tr>
			<tr><td style="border-style: solid; border-width: 1px" height="26">Date: 2009-Jul-09</td></tr>
			<tr><td style="border-style: solid; border-width: 1px" height="26">Changes :</td></tr>
			<tr><td style="border-style: solid; border-width: 1px" height="26" colspan="3">
				<OL>
					<LI>Added Token support on almost every page that takes user input, or input from the URL.</LI>
					<LI>Fixed an issue where if you had sent a file from vistumber the token would not be able to be compared.</LI>
					<LI>Added signal strength to Access Point Signal Plot KML export.</LI>
					<LI>Changed Individual User Stat Page to new layout.</LI>
					<LI>Standardized SSID usage, there are three types:</LI>
					<OL>
						<LI>&#60;ny-paq&#62;&#124;sayz oh-my this is fun [ is the unsanitized, but still safe SSID, used to name APs, 32 char limit, no special chars.]</LI>
						<LI>&#60;ny-paq&#62;_sayz oh-my this is fun [safe for file names, no special chars, 32 char limit.]</LI>
						<LI>_ny-paq__sayz oh-my this [safe for table names, max 25 char, no special chars.]</LI>
					</OL>
					<LI>Changed the way WiFiDB looks for the install folder.</LI>
					<LI>Daemon now has all SQL based errors being echoed out to the screen, even if Verbose is off.</LI>
					<LI>Changed the table hide for GPS history, so it is now hidden by default. Has a +/- symbol to either expand or contract the table next to the GPS History Title.</LI>
					<LI>For some reason the Save Search link was missing after 0.16 Build 1, is now back, with a few enhancements.</LI>
					<LI>Fixed the No Token error with imports directly from Vistumbler.</LI>
					<LI>Fixed the formating of the file location that is in the URL from the import directly from Vistumbler that gets printed on the page.</LI>
					<LI>Also made the drop down for selecting the refresh time on the scheduled imports page, so it has a default of the current selection instead of going back to 5 sec.</LI>
					<LI>Fixed the Upgrade script in /install/upgrade/patch.php. (Was broken in Build 2 and 2.1.)</LI>
					<LI>Fixed the Install script in /install/install.php. (Was broken in Build 2 and 2.1.)</LI>
					<LI>Added Daemon Status to the scheduling.php page.</LI>
					<LI>Fixed an issue where the Signal history was being corrupted by being sanitized. The 'special' characters '-' and ',' were being encoded.</LI>
					<LI>Fixed Some Issues with the daemon, details are in the Tools Read-me.</LI>
					<LI>The WiFiDB Web log vars $log_level and $log_interval where interfering with the Daemon vars, they are now changed to $log_level_W and $log_interval_W.</LI>
					<LI>The User-name in the 'Files already imported' table was pointing to the All APs for that user page, when it is supposed to point to the Users stat page.</LI>
					<LI>Fixed an issue where if some AP Pointers are removed from the `wifi0` table, some APs will fail to import or have the same ID as another AP and not be linkable to their data.</LI>
					<LI><b>[ Issues reported by ACalcutt ]</b>
						<OL>
							<LI>"Access" is spelled incorrectly multiple times on Export page.</LI>
							<LI>(Export an Access Point to KML) "User-name" should be "SSID".</LI>
							<LI>Fix the links for Access Points on the All AP page. (Add tokens to the SSID URLs in the "View all APs" page.)</LI>
							<LI>Refresh time on the scheduling page went to 15 seconds when I set it to 5 seconds. On the next refresh it went back to 30 seconds.</LI>
						</OL>
					</LI>
					<LI>Unified the import_vs1() and importvs1d() functions, added an $out var to import_vs1() and verbose(), valid values are "CLI" and "HTML".</LI>
					<LI>Moved the Install folder warning code to the database.inc.php file from config.inc.php.</LI>
					<LI>All Messages in import_vs1 are in a group of variables in the beginning of the function, for easy editing.</LI>
					<LI>Added in some code to handle obscure APs that get tagged as new when they are not new.</LI>
					<LI>There was missing Token links on the Associated Lists section of the AP Fetch page.</LI>
					<LI>Numerous other small fixes that I have forgotten about.</LI>
					<LI>Spell-checked the Ver.php page.</LI>
					<LI>Added sorting and pages to the Search results page.</LI>
					<LI>Rearranged the exports page.</LI>
					<LI>Added MAC , sectype , chan , and radio to Single AP export.</LI>
					<LI>Added Date and number of APs for User list export.</LI>
				</OL>
			</td></tr>
		</table>
		<br>
		<table width="100%" border="2" id="16b21">
			<tr><td style="border-style: solid; border-width: 1px" height="26">Author: Phillip Ferland</td>
			<td style="border-style: solid; border-width: 1px" height="26">Version: 0.16 Build 2.1</td></tr>
			<tr><td style="border-style: solid; border-width: 1px" height="26">Date: 2009-May-05</td></tr>
			<tr><td style="border-style: solid; border-width: 1px" height="26">Changes :</td></tr>
			<tr><td style="border-style: solid; border-width: 1px" height="26" colspan="3">
				<OL>
					<LI>Daemon was unable to remove files from `files_tmp` table and put them into the uploaded `files` table.</LI>
					<LI>The importvs1 function for the daemon was not returning the AP and GPS totals, and 0 was being entered into the users table.</LI>
					<LI>Added a link to the side for "Files Waiting to be imported" (/opt/scheduling.php).</LI>
					<LI>Fixed the issue where the Import page would not switch to 'non-daemon' mode when $daemon var was set to 0.</LI>
					<LI>Rearranged the table for scheduling.php, and added in Current AP, Importing? (Yes/No), Current AP/Total APs.</LI>
					<LI>Added color for Files waiting to be imported, Green = Currently Importing, Yellow = Waiting.</LI>
					<LI>Had to alter SQL statement for Total APs in the Main Stats Page. This is because I have added the next Import run as an element in the `settings` table.</LI>
					<LI>Main Stats Page Last Import list link didn't have a row id in the URL.</LI>
					<LI>The Corrupted dates on GPS cords was, I stupidly moved the Date conversion check outside the GPS array creation, which is dependent on the number of segments returned for the GPS in the VS1 file, so for the newer VS1 file that has 12 segments it was grabbing the wrong data.</LI>
					<LI>Fixed an issue where on windows based systems the file size wouldn't be correct.</LI>
				</OL>
			</td></tr>
		</table>
		<br>
<table width="100%" border="2" id="16b2">
	<tr><td style="border-style: solid; border-width: 1px" height="26">Author: Phillip Ferland</td>
	<td style="border-style: solid; border-width: 1px" height="26">Version: 0.16 Build 2</td></tr>
	<tr><td style="border-style: solid; border-width: 1px" height="26">Date: 2009-Apr-29</td></tr>
	<tr><td style="border-style: solid; border-width: 1px" height="26">Changes :</td></tr>
	<tr><td style="border-style: solid; border-width: 1px" height="26" colspan="3">
		<OL>
			<LI>Changed the Import Page Layout so that it now summarizes the GPS import into,</LI>
				<OL>
					<LI>New: Good,Bad</LI>
					<LI>Update: Good,Bad</LI>
					<LI>Already in Database: </LI>
				</OL>
			<LI>Finished AP Fetch Page so that GPS can be hidden.</LI>
			<LI>Most, if not all pages now have the footer() and pageheader() function to standardize page layout.</LI>
			<LI>Fixed an issue where if there is no MAC/Sectype/Chan/Radio it would just be blank, and cause errors on fetch. </LI>
				<OL>New Defaults:
					<LI>Mac (00:00:00:00:00:00)</LI>
					<LI>Sectype (0)</LI>
					<LI>Chan (0)</LI>
					<LI>Radio (u)</LI>
				</OL>
			<LI>Added support for Exporting to GPX files, for Garmin Devices.</LI>
			<LI>Moved the code from insertnew.php into the index.php file, this is for the token that has been added for validation.</LI>
			<LI>Added a comment tag to <i>`line 2`</i>of the KML exports to tell if it was a Full DB/Users list/Single AP/All Users APs/All Signal for AP.</LI>
			<LI>Made the tables that hold the page one table so when there is a skew in the page doesn't get deformed like it did before. (I'm not a GUI person).</LI>
			<LI>Fixed some formating issues with the install/upgrade/patching paths.</LI>
			<LI>For Security reasons, temporally will be using hard links for the side links, until further notice.</LI>
			<LI>Added a 'daemon' of sorts. This is optional upon install, and changeable afterwards in the config file. <br>Notes are in the Readme.txt of the tools folder.</LI>
		</OL>
	</td></tr>
</table>

<br>
<table width="100%" border="2" id="16b1">
	<tr><td style="border-style: solid; border-width: 1px" height="26">Author: Phillip Ferland</td>
	<td style="border-style: solid; border-width: 1px" height="26">Version: 0.16 Build 1</td></tr>
	<tr><td style="border-style: solid; border-width: 1px" height="26">Date: 2009-Mar-20</td></tr>
	<tr><td style="border-style: solid; border-width: 1px" height="26">Changes :</td></tr>
	<tr><td style="border-style: solid; border-width: 1px" height="26" colspan="3">
		<OL>
			<LI>Started moving all HTML code outside PHP code.</LI>
			<LI>Fixed an error in the GPS conversion.</LI>
			<LI>Added a footer function to take over the "*THIS PAGE* has been last edited on..." at the end of all forms, to standardize it, seeing how it was on all forms anyway.</LI>
			<LI>Moved the "*THIS PAGE* was last modified on: YYYY-MMM-DD @ HH:MM:SS" to the bottom of the page in the bottom cell.</LI>
			<LI>Working on changing the layout of the AP fetch page. Soon it will be:</LI>
			<OL type="A">
				<LI><b><i><br>---------------------------------------<br>
				&nbsp;&nbsp;Associated list <br>
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|_&gt; Signal history for that list <br>
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|_&gt; GPS points for that Signal<br>
				---------------------------------------<br></i></b></LI>
				<LI>Would like to have it so the GPS history is hide able via Java-script or something.</LI>
				<LI>So far the changes are, all the previous separate functions (fetch GPS, fetch associate list, and fetch signal) are all now one function (fetch AP).</LI>
				<LI>Unfortunately this is going to require a change in the back end. Previous databases will not be compatible with this update.</LI>
				<LI>Reason being, in the previous versions (0.14 &amp; 0.15[all builds]) did not store the signal history row in the Users table.</LI> 
					<OL>
						<LI>Old way ex <font color="red">1</font>,<font color="Yellow">1</font>-<font color="red">0</font>,<font color="Yellow">2</font>-<font color="red">0</font>,<font color="Yellow">6</font>-<font color="red">1</font>,<font color="Yellow">10</font>-... / <font color="red">0</font>,<font color="Yellow">6</font> : <font color="red">0</font> is the update or new flag <font color="red">1</font> = Updated AP  <font color="red">0</font> = New AP, the <font color="Yellow">6</font> is the AP ID number in the Database</LI>
						<LI>New way ex <font color="red">1</font>,<font color="Yellow">6</font>:<font color="Green">1</font>-<font color="red">0</font>,<font color="Yellow">2</font>:<font color="Green">2</font>-<font color="red">0</font>,<font color="Yellow">6</font>:<font color="Green">3</font>-<font color="red">1</font>,<font color="Yellow">10</font>:<font color="Green">1</font>-... /<br> <font color="red">0</font>,<font color="Yellow">6</font>:<font color="Green">2</font> ; <font color="red">0</font> is the update or new flag 1 = Updated AP / 0 = New AP, the <font color="Yellow">6</font> is the Unique Access Point ID (UAPID) in the Database, and the <font color="Green">2</font> is the Signal History row number for the access point.)</LI>
					</OL>
			</OL>
			<LI>The users table holds all the list imports for each user.</LI>
			<LI>Fixed a bug when a search has no results, the page would output a PHP error, now it says "There where no results, please try again".</LI>
			<LI>Fixed an issue, where on install there would be an SQL error and fail to install.</LI>
			<LI>Added link to Last User on Index page.</LI>
			<LI>Cleaned up the tables on the new version page.</LI>
			<LI>Dates are now standardized as YYYY-MM-DD, to coincide with Vistumblers' save file.</LI>
			<LI>Fixed up the List KML export, there is a link to the KML file now.</LI>
			<LI>Finished KML export for entire database.</LI>
			<LI>Added option for a black background on the Signal Graphs.</LI>
			<LI>Empty Imports are no longer allowed (should have been like that since the beginning). Also if there were any empty imports, they will not be printed out on the All Users page.</LI>
			<LI>Added some friendly informational links.</LI>
			<LI>Set the default values for function variables, in case one value is left out.</LI>
			<LI>Initial code for Export Newest AP to KML is written, not tested yet.</LI>
			<LI>Added Export Page at /opt/export.php, also a link on the left hand side.</LI>
				<OL type="A">
					<LI>Have Export users list to KML, all APs for a user to KML, export all APs in the DB to KML, and export a single AP to KML.</LI>
					<LI>Going to add the same for export to VS1.</LI>
				</OL>
			<LI>The warning for the install folder still being available was not added into the installer. It now is, and also in the upgrade too.</LI>
			<LI>Made the Default App internal timezone, GMT+0(Zulu).</LI>
				<OL>
					<LI>Soon you will be able to make the viewing time as your local timezone.</LI>
					<LI><a class="links" href="http://wwp.greenwichmeantime.com/">greenwichmeantime.com</a></LI>
					<LI><a class="links" href="http://en.wikipedia.org/wiki/Greenwich_Mean_Time">wikipedia -> Greenwich_Mean_Time</a></LI>
				</OL>
			<LI></LI>
		</OL>
	</td></tr>
</table>
<br>
<table width="100%" border="2" id="15b80" cellpadding="1">
	<tr><td style="border-style: solid; border-width: 1px;width:50%;" height="26">Author: Phillip Ferland</td>
	<td style="border-style: solid; border-width: 1px;width:50%;" height="26">Version: 0.15 Build 80</td></tr>
	<tr><td style="border-style: solid; border-width: 1px;width:50%;" height="26">Date: 2009-Jan-29</td></tr>
	<tr><td style="border-style: solid; border-width: 1px;width:50%;" height="26">Changes :</td></tr>
	<tr><td style="border-style: solid; border-width: 1px;width:50%;" height="26" colspan="3">
		<OL>
			<LI>Small Code fixes that needed to be fixed. most only showed up if verbose errors was on in PHP.</LI>
			<LI>Fixed Export to KML files from the Users List and Individual Access Points.</LI>
			<LI>Dates are now standardized as YYYY-MM-DD.</LI>
		</OL>
	</td></tr>
</table>
<br>
<table width="100%" border="2" id="15b79" cellpadding="1">
	<tr><td style="border-style: solid; border-width: 1px;width:50%;" height="26">Author: Phillip Ferland</td>
	<td style="border-style: solid; border-width: 1px;width:50%;" height="26">Version: 0.15 Build 79</td></tr>
	<tr><td style="border-style: solid; border-width: 1px;width:50%;" height="26">Date: 2009-Jan-24</td></tr>
	<tr><td style="border-style: solid; border-width: 1px;width:50%;" height="26">Changes :</td></tr>
	<tr><td style="border-style: solid; border-width: 1px;width:50%;" height="26" colspan="3">
		<OL>
			<LI>Made a repair script to check the Storage tables for erroneous data, to replace or remove.</LI>
			<LI>Some other small typos and coding fixes.</LI>
		</OL>
	</td></tr>
</table>
<br>
<table width="100%" border="2" id="15b78" cellpadding="1">
	<tr><td style="border-style: solid; border-width: 1px;width:50%;" height="26">Author: Phillip Ferland</td>
	<td style="border-style: solid; border-width: 1px;width:50%;" height="26">Version: 0.15 Build 78</td></tr>
	<tr><td style="border-style: solid; border-width: 1px;width:50%;" height="26">Date: 2009-Jan-22</td></tr>
	<tr><td style="border-style: solid; border-width: 1px;width:50%;" height="26">Changes :</td></tr>
	<tr><td style="border-style: solid; border-width: 1px;width:50%;" height="26" colspan="3">
		<OL>
			<LI>Extra include_once_onces for database.inc.php slipped back in.</LI>
			<LI>Install script had a bug with the Links table.</LI>
		</OL>
	</td></tr>
</table>
<br>
<table width="100%" border="2" id="15b77" cellpadding="1">
	<tr><td style="border-style: solid; border-width: 1px;width:50%;" height="26">Author: Phillip Ferland</td>
	<td style="border-style: solid; border-width: 1px;width:50%;" height="26">Version: 0.15 Build 77</td></tr>
	<tr><td style="border-style: solid; border-width: 1px;width:50%;" height="26">Date: 2009-Jan-11</td></tr>
	<tr><td style="border-style: solid; border-width: 1px;width:50%;" height="26">Changes :</td></tr>
	<tr><td style="border-style: solid; border-width: 1px;width:50%" height="26" colspan="3">
		<OL>
			<LI>Some headers had duplicate include_once_onces for database.inc.php.</LI>
			<LI>Fixed import of GPS points.</LI>
		</OL>
	</td></tr>
</table>
<br>
<table width="100%" border="2" id="15b76" cellpadding="1">
	<tr><td style="border-style: solid; border-width: 1px;width:50%" height="26">Author: Phillip Ferland</td>
	<td style="border-style: solid; border-width: 1px;width:50%" height="26">Version: 0.15 Build 76	</td></tr>
	<tr><td style="border-style: solid; border-width: 1px;width:50%" height="26">Date: 2008-Dec-20</td></tr>
	<tr><td style="border-style: solid; border-width: 1px;width:50%" height="26">Changes :</td></tr>
	<tr><td style="border-style: solid; border-width: 1px;width:50%" height="26" colspan="3">
		<OL>
			<LI>There where a few major bugs in the install script that are now fixed.</LI>
			<LI>There was no Upgrade script in the install folder to do a safe upgrade from v0.14 to v0.15. go to /install/upgrade.php.</LI>
		</OL>
	</td></tr>
</table>
<br>
<table width="100%" border="2" id="15b75" cellpadding="1">
	<tr><td style="border-style: solid; border-width: 1px;width:50%" height="26">Author: Phillip Ferland</td>
	<td style="border-style: solid; border-width: 1px;width:50%" height="26">Version: 0.15 Build 75	</td></tr>
	<tr><td style="border-style: solid; border-width: 1px;width:50%" height="26">Date: 2008-Dec-19</td></tr>
	<tr><td style="border-style: solid; border-width: 1px;width:50%" height="26">Changes :</td></tr>
	<tr><td style="border-style: solid; border-width: 1px;width:50%" height="26" colspan="3">
		<OL>
			<LI>Added in a very basic (to start) search page, to search for Access Points.</LI>
			<LI>(Work in progress) Changing the GPS check so that it checks the DB for the GPS point and from there, if there is a return, point to that GPS, if not add it to the table.</LI>
			<LI>Added associated Import list for Access Points.</LI>
			<LI>Added in Security warning in case the /install folder is not removed.</LI>
			<LI>Added some more user input sanitation.</LI>
		</OL>
	</td></tr>
</table>
<br>
<table width="100%" border="2" id="15b73" cellpadding="1">
	<tr><td style="border-style: solid; border-width: 1px;width:50%" height="26">Author: Phillip Ferland</td>
	<td style="border-style: solid; border-width: 1px;width:50%" height="26">Version: 0.15 Build 73	</td></tr>
	<tr><td style="border-style: solid; border-width: 1px;width:50%" height="26">Date: 2008-Nov-28</td></tr>
	<tr><td style="border-style: solid; border-width: 1px;width:50%" height="26">Changes :</td></tr>
	<tr><td style="border-style: solid; border-width: 1px;width:50%" height="26" colspan="3">
		<OL>
			<LI>Changed the import report page to have tables for the output, so that it is more organized and is easier to tell weather the access point is a new or updated.</LI>
			<LI>(Work in progress) Changed the GPS check so that it checks the DB for the GPS point and from there, if there is a return, point to that GPS, if not add it to the table.</LI>
		</OL>
	</td></tr>
</table>
<br>
<table width="100%" border="2" id="15b67" cellpadding="1">
	<tr><td style="border-style: solid; border-width: 1px;width:50%" height="26">Author: Phillip Ferland</td>
	<td style="border-style: solid; border-width: 1px;width:50%" height="26">Version: 0.15 Build 67	</td></tr>
	<tr><td style="border-style: solid; border-width: 1px;width:50%" height="26">Date: 2008-Nov-19</td></tr>
	<tr><td style="border-style: solid; border-width: 1px;width:50%" height="26">Changes :</td></tr>
	<tr><td style="border-style: solid; border-width: 1px;width:50%" height="26" colspan="3">
		<OL>
			<LI>Added GPS history to Access Point Fetch page.</LI>
			<LI>Added View all APs for a given user.</LI>
			<LI>Fixed bug in the import_vs1 function where the page was not rendering right, even though it was importing correctly.</LI>
			<LI>Fixed a bug where the AP fetch page wasn't showing more then one row of signal history even though there was more then one.</LI>
		</OL>
	</td></tr>
</table>
<br>
<table width="100%" border="2" id="14" cellpadding="1">
	<tr><td style="border-style: solid; border-width: 1px;width:50%" height="26">Author: Phillip Ferland</td>
	<td style="border-style: solid; border-width: 1px;width:50%" height="26">Version: 0.14	</td></tr>
	<tr><td style="border-style: solid; border-width: 1px;width:50%" height="26">Date: 2008-Nov-14</td></tr>
	<tr><td style="border-style: solid; border-width: 1px;width:50%" height="26">Changes :</td></tr>
	<tr><td style="border-style: solid; border-width: 1px;width:50%" height="26" colspan="3">
		<OL>
			<LI>Changed the All users list, so that it displays only the first ID for a user (which is considered the users Unique ID).</LI>
			<LI>Fixed an issue where randomly an AP would have more signal history points then GPS history points.</LI>
			<LI>Added installer for easy setup. Just go to /[WiFiDB path]/install/.</LI>
			<LI>Fixed a few more bugs/PEBKAC errors.</LI>
		</OL>
	</td></tr>
</table>
<br>
<table width="100%" border="2" id="13" cellpadding="1">
	<tr><td style="border-style: solid; border-width: 1px;width:50%" height="26">Author: Phillip Ferland</td>
	<td style="border-style: solid; border-width: 1px;width:50%" height="26">Version: 0.13	</td></tr>
	<tr><td style="border-style: solid; border-width: 1px;width:50%" height="26">Date: 2008-Oct-30</td></tr>
	<tr><td style="border-style: solid; border-width: 1px;width:50%" height="26">Changes :</td></tr>
	<tr><td style="border-style: solid; border-width: 1px;width:50%" height="26" colspan="3">
		<OL>
			<LI>Rearranged functions.php into database.inc.php(all database related functions) and graph.inc.php (all graphing and image related functions).</LI>
			<LI>Fixed a few more bugs/PEBKAC errors.</LI>
		</OL>
	</td></tr>
</table>
<br>
<table width="100%" border="2" id="12" cellpadding="1">
	<tr><td style="border-style: solid; border-width: 1px;width:50%" height="26">Author: Phillip Ferland</td>
	<td style="border-style: solid; border-width: 1px;width:50%" height="26">Version: 0.12</td></tr>
	<tr><td style="border-style: solid; border-width: 1px;width:50%" height="26">Date: 2008-Aug-19</td></tr>
	<tr><td style="border-style: solid; border-width: 1px;width:50%" height="26">Changes :</td></tr>
	<tr><td style="border-style: solid; border-width: 1px;width:50%" height="26" colspan="3">
		<OL>
			<LI>Added in graphing for APs signal history, one row of history at a time for the moment.</LI>
			<LI>Added in Users Stats page to view what users have imported / updated what APs.</LI>
			<LI>Added in KML exports, right now its is just a Full DB export, soon to be added is Individual APs and groups of selected APs.</LI>
		</OL>
	</td></tr>
</table>
<br>
<table width="100%" border="2" id="11" cellpadding="1">
	<tr><td style="border-style: solid; border-width: 1px;width:50%" height="26">Author: Phillip Ferland</td>
	<td style="border-style: solid; border-width: 1px;width:50%" height="26">Version: 0.11</td></tr>
	<tr><td style="border-style: solid; border-width: 1px;width:50%" height="26">Date: 2008-Aug-12</td></tr>
	<tr><td style="border-style: solid; border-width: 1px;width:50%" height="26">Changes :</td></tr>
	<tr><td style="border-style: solid; border-width: 1px;width:50%" height="26" colspan="3">
		<OL>
			<LI>Fixed the issue where the signal history was getting corrupted and adding in way more signal points then there actually where for the AP. [functions.php->import_vs1()].</LI>
			<LI>Added in a `Users` table to keep track of what users imported/updated APs.</LI>
			<LI>Added in `notes` for the group of APs to be added into the `Users` table, by the user upon import.</LI>
			<LI>Fixed most if not all CSS issues.</LI>
			<LI>Added `VS1` and `VSZ` folders to the `out` dir (exports soon to be added).</LI>
		</OL>
	</td></tr>
</table>
<br>
<table width="100%" border="2" id="1" cellpadding="1">
	<tr><td style="border-style: solid; border-width: 1px;width:50%" height="26">Author: Phillip Ferland</td><td style="border-style: solid; border-width: 1px;width:50%" height="26">Version: 0.1	</td></tr>
	<tr><td style="border-style: solid; border-width: 1px;width:50%" height="26">Date: 2008-Jun-10</td></tr>
	<tr><td style="border-style: solid; border-width: 1px;width:50%" height="26">Changes :</td></tr>
	<tr><td style="border-style: solid; border-width: 1px;width:50%" height="26" colspan="3">
		<OL>
			<LI>This is a work in progress. Most if not all the features are in their infancy and need much work.</LI>
		</OL>
	</td></tr>
</table>
<br>

	<h2><---LINKS---></h2>
	<a class="links" href="http://forum.techidiots.net/forum/viewforum.php?f=22">RanInt Forum</a><br>
	<a class="links" href="http://forum.techidiots.net/forum/viewforum.php?f=38">WiFiDB Forum</a><br>
<br>
<?php

$filename = $_SERVER['SCRIPT_FILENAME'];
footer($filename);
?>
