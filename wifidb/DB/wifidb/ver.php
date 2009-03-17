<?php
include('lib/config.inc.php');
include('lib/database.inc.php');
?>
<title>Wireless DataBase *Alpha*<?php echo $ver["wifidb"]?> --> Main Page</title>
<link rel="stylesheet" href="css/site4.0.css">
<body topmargin="10" leftmargin="0" rightmargin="0" bottommargin="10" marginwidth="10" marginheight="10">
<div align="center">
<table border="0" width="75%" cellspacing="10" cellpadding="2">
	<tr>
		<td bgcolor="#315573">
		<p align="center"><b><font size="5" face="Arial" color="#FFFFFF">
		Wireless DataBase *Alpha* <?php echo $ver["wifidb"]; ?></font>
		<font color="#FFFFFF" size="2">
            <a class="links" href="/">[Root] </a>/ <a class="links" href="/wifidb/">[WifiDB] </a>/
		</font></b>
		</td>
	</tr>
</table>
</div>
<div align="center">
<table border="0" width="75%" cellspacing="10" cellpadding="2" height="90">
	<tr>
<td width="17%" bgcolor="#304D80" valign="top">

<?php
mysql_select_db($db,$conn);
$sql = "SELECT * FROM links ORDER BY ID ASC";
$result = mysql_query($sql, $conn) or die(mysql_error());
while ($newArray = mysql_fetch_array($result))
{
	$testField = $newArray['links'];
    echo "<p>$testField</p>";
}
?>

</td>
		<td width="80%" bgcolor="#A9C6FA" valign="top" align="center">
			<p align="center">
<div align="left">
<font face="Courier New">
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
<br>
<table width="100%" border="2" id="16pb1">
	<tr><td style="border-style: solid; border-width: 1px" height="26">Author: Phillip Ferland</td>
	<td style="border-style: solid; border-width: 1px" height="26">Version: 0.16 Build 1</td></tr>
	<tr><td style="border-style: solid; border-width: 1px" height="26">Date: 2009-Mar-15</td></tr>
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
				&nbsp;&nbsp;Assosiated list <br>
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|_&gt; Signal history for that list <br>
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|_&gt; GPS points for that Signal<br>
				---------------------------------------<br></i></b></LI>
				<LI>Would like to have it so the GPS history is hideable via Javascript or something.</LI>
				<LI>So far the changes are, all the previous seperate functions (fetch gps, fetch assosiate list, and fetch signal) are all now one function (fetch ap).</LI>
				<LI>Unfortunately this is going to require a change in the backend. Previous databases will not be compatible with this update.</LI>
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
		<LI>Dates are now standardized as YYYY-MM-DD, to coincide with Vistumblers save file.</LI>
		
		<LI>Fixed up the List KML export, there is a link to the KML file now.</LI>
		<LI>Finished KML export for entire database.</LI>
		<LI>Added option for a black background on the Signal Graphs.</LI>
		<LI>Empty Imports are no longer allowed (should have been like that since the beginning). Also if there were any empty imports, they will not be printed out on the All Users page.</LI>
		<LI>Added some friendly informational links.</LI>
		<LI>Set the default values for function varibles, incase one value is left out.</LI>
		<LI>Initial code for Export Newest AP to KML is writen, not tested yet.
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
			<LI>Made a rapair script to check the Storage tables for erroneous data, to replace or remove.</LI>
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
			<LI>Extra includes for database.inc.php slipped back in.</LI>
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
			<LI>Some headers had duplicate includes for database.inc.php.</LI>
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
			<LI>There where a few major bugs in the install script that are now fixed</LI>
			<LI>There was no Upgrade script in the install folder to do a safe upgrade from v0.14 to v0.15. go to /install/upgrade.php</LI>
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
			<LI>Added in Security warning incase the /install folder is not removed.</LI>
			<LI>Added some more user input sanitization.</LI>
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
			<LI>Added View all AP's for a given user.</LI>
			<LI>Fixed bug in the import_vs1 function where the page was not rendering right, even though it was importing correctly.</LI>
			<LI>Fixed a bug where the AP fetch page wasnt showing more then one row of signal history even though there was more then one.</LI>
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
			<LI>Added installer for easy setup. Just go to /[WifiDB path]/install/</LI>
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
			<LI>Added in graphing for AP's signal history, one row of history at a time for the moment.</LI>
			<LI>Added in Users Stats page to view what users have imported / updated what AP's.</LI>
			<LI>Added in KML exports, right now its is just a Full DB export, soon to be added is Individual AP's and groups of selected AP's.</LI>
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
			<LI>Fixed the issue where the signal history was getting corrupted and adding in way more signal points then there actually where for the AP. [functions.php->import_vs1()]</LI>
			<LI>Added in a `Users` table to keep track of what users imported/updated AP's.</LI>
			<LI>Added in `notes` for the group of AP's to be added into the `Users` table, by the user appon import.</LI>
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