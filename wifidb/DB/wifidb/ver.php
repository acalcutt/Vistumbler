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
<table border="0" id="table1" cellpadding="2">
	<tr>
		<th width="90" style="border-style: solid; border-width: 1px" height="26">
		Version</th>
		<th width="175" style="border-style: solid; border-width: 1px">
		Author(s)</th>
		<th style="border-style: solid; border-width: 1px" height="26">
		Date</th>
		<th style="border-style: solid; border-width: 1px" height="26">Fixes</th>
	</tr>
	<tr>
		<td style="border-style: solid; border-width: 1px" height="26">
		0.16 Pre-Build 1</td>
		<td style="border-style: solid; border-width: 1px">
		Phillip Ferland</td>
		<td style="border-style: solid; border-width: 1px" height="26">
		2009-02-12</td>
		<td style="border-style: solid; border-width: 1px" height="26">
		<b>1></b> Started moving all HTML code outside PHP code.<br>
		<b>2></b> Fixed an error in the GPS conversion.<br>
		<b>3></b> Added a footer function to take over the "this file has been last edited on..." at the end of all forms, to standardize it, seeing how it was on all forms anyway.<br>
		<b>4></b> Working on changing the layout of the AP fetch page. Soon it will be:<b><i>
		<br>---------------<br>&nbsp;&nbsp;Assosiated list <br>
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-> Signal history for that list <br>
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-> GPS points for that Signal<br>
		---------------<br></b></i>Would like to have it so the GPS history is hidable via Javascript or something.<br>
		-> Unfortunately this is going to require a change in the backend. Previous databases will not be compatible with this update.
		-> Reason being, in the previous versions (0.14 & 0.15[all builds]) did not store the signal history row in the Users table.<br> 
		-> The users table holds all the list imports for each user. (old way ex 1,1-0,2-0,6-1,10-... / 0,6 : 0 is the update or new flag 1 = Updated AP  0 = New AP, the 6 is the AP ID number in the Database)<br>
		-> New way ex 1,1:1-0,2:2-0,6:3-1,10:1-... /<br> <font color="red">0</font>,<font color="Yellow">6</font>:<font color="Green">2</font> ; <font color="red">0</font> is the update or new flag 1 = Updated AP / 0 = New AP, the <font color="Yellow">6</font> is the Unique Access Point ID (UAPID) in the Database, and the <font color="Green">2</font> is the Signal History row number for the access point.)
		</td>
	</tr>
	<tr>
		<td style="border-style: solid; border-width: 1px" height="26">
		0.15 Build 80</td>
		<td style="border-style: solid; border-width: 1px">
		Phillip Ferland</td>
		<td style="border-style: solid; border-width: 1px" height="26">
		2009-01-29</td>
		<td style="border-style: solid; border-width: 1px" height="26">
		<b>1></b> Small Code fixes that needed to be fixed. most only showed up if verbose errors was on in PHP.<br>
		<b>2></b> Fixed Export to KML files from the Users List and Individual Access Points.<br>
		</td>
	</tr>
	<tr>
		<td style="border-style: solid; border-width: 1px" height="26">
		0.15 Build 79</td>
		<td style="border-style: solid; border-width: 1px">
		Phillip Ferland</td>
		<td style="border-style: solid; border-width: 1px" height="26">
		2009-01-24</td>
		<td style="border-style: solid; border-width: 1px" height="26">
		<b>1></b> Made a rapair script to check the Storage tables for erroneous data, to replace or remove.<br>
		<b>2></b> Some other small typos and coding fixes.<br>
		</td>
	</tr>
	<tr>
		<td style="border-style: solid; border-width: 1px" height="26">
		0.15 Build 78</td>
		<td style="border-style: solid; border-width: 1px">
		Phillip Ferland</td>
		<td style="border-style: solid; border-width: 1px" height="26">
		2009-01-22</td>
		<td style="border-style: solid; border-width: 1px" height="26">
		<b>1></b> Extra includes for database.inc.php slipped back in.<br>
		<b>2></b> Install script had a bug with the Links table.<br>
		</td>
	</tr>
	<tr>
		<td style="border-style: solid; border-width: 1px" height="26">
		0.15 Build 77</td>
		<td style="border-style: solid; border-width: 1px">
		Phillip Ferland</td>
		<td style="border-style: solid; border-width: 1px" height="26">
		2008-01-11</td>
		<td style="border-style: solid; border-width: 1px" height="26">
		<b>1></b> some headers had duplicate includes for database.inc.php.<br>
		<b>2></b> fixed import of GPS points.<br>
		</td>
	</tr>
	
	<tr>
		<td style="border-style: solid; border-width: 1px" height="26">
		0.15 Build 76</td>
		<td style="border-style: solid; border-width: 1px">
		Phillip Ferland</td>
		<td style="border-style: solid; border-width: 1px" height="26">
		2008-12-20</td>
		<td style="border-style: solid; border-width: 1px" height="26">
		<b>1></b> There where a few major bugs in the install script that are now fixed<br>
		<b>2></b> There was no Upgrade script in the install folder to do a safe upgrade from v0.14 to v0.15. go to /install/upgrade.php<br>
		</td>
	</tr>
	<tr>
		<td style="border-style: solid; border-width: 1px" height="26">
		0.15 Build 75</td>
		<td style="border-style: solid; border-width: 1px">
		Phillip Ferland</td>
		<td style="border-style: solid; border-width: 1px" height="26">
		2008-12-19</td>
		<td style="border-style: solid; border-width: 1px" height="26">
		<b>1></b> Added in a very basic (to start) search page, to search for Access Points.<br>
		<b>2></b> (Work in progress) Changing the GPS check so that it checks the DB for the GPS point and from there, if there is a return, point to that GPS, if not add it to the table.<br>
		<b>3></b> Added associated Import list for Access Points.<br>
		<b>4></b> Added in Security warning incase the /install folder is not removed.<br>
		<b>5></b> Added some more user input sanitization.<br>
		</td>
	</tr>	
	<tr>
		<td style="border-style: solid; border-width: 1px" height="26">
		0.15 Build 73</td>
		<td style="border-style: solid; border-width: 1px">
		Phillip Ferland</td>
		<td style="border-style: solid; border-width: 1px" height="26">
		2008-11-28</td>
		<td style="border-style: solid; border-width: 1px" height="26">
		<b>1></b> Changed the import report page to have tables for the output, so that it is more organized and is easier to tell weather the access point is a new or updated <br>
		<b>2></b> (Work in progress) Changed the GPS check so that it checks the DB for the GPS point and from there, if there is a return, point to that GPS, if not add it to the table<br>
		</td>
	</tr>
	<tr>
		<td style="border-style: solid; border-width: 1px" height="26">
		0.15 Build 67</td>
		<td style="border-style: solid; border-width: 1px">
		Phillip Ferland</td>
		<td style="border-style: solid; border-width: 1px" height="26">
		2008-11-19</td>
		<td style="border-style: solid; border-width: 1px" height="26">
		<b>1></b> Added GPS history to Access Point Fetch page<br>
		<b>2></b> Added View all AP's for a given user<br>
		<b>3></b> Fixed bug in the import_vs1 function where the page was not rendering right, even though it was importing correctly<br>
		<b>4></b> Fixed a bug where the AP fetch page wasnt showing more then one row of signal history even though there was more then one<br>
		</td>
	</tr>
	<tr>
		<td style="border-style: solid; border-width: 1px" height="26">
		0.14</td>
		<td style="border-style: solid; border-width: 1px">
		Phillip Ferland</td>
		<td style="border-style: solid; border-width: 1px" height="26">
		2008-11-14</td>
		<td style="border-style: solid; border-width: 1px" height="26">
		<b>1></b> Changed the All users list, so that it displays only the first ID for a user (which is considered the users Unique ID)<br>
		<b>2></b> Fixed an issue where randomly an AP would have more signal history points then GPS history points<br>
		<b>3></b> Added installer for easy setup. Just go to /[WifiDB path]/install/<br>
		<b>4></b> Fixed a few more bugs/PEBKAC errors<br>
		</td>
	</tr>
	<tr>
		<td style="border-style: solid; border-width: 1px" height="26">
		0.13</td>
		<td style="border-style: solid; border-width: 1px">
		Phillip Ferland</td>
		<td style="border-style: solid; border-width: 1px" height="26">
		2008-10-30</td>
		<td style="border-style: solid; border-width: 1px" height="26">
		<b>1></b> Rearranged functions.php into database.inc.php(all database related functions) and graph.inc.php (all graphing and image related functions).<br>
		<b>2></b> Fixed a few more bugs/PEBKAC errors<br>
		</td>
	</tr>
	<tr>
		<td style="border-style: solid; border-width: 1px" height="26">
		0.12</td>
		<td style="border-style: solid; border-width: 1px">
		Phillip Ferland</td>
		<td style="border-style: solid; border-width: 1px" height="26">
		2008-08-19</td>
		<td style="border-style: solid; border-width: 1px" height="26">
		<b>1></b> Added in graphing for AP's signal history, one row of history at a time for the moment.<br>
		<b>2></b> Added in Users Stats page to view what users have imported / updated what AP's.<br>
		<b>3></b> Added in KML exports, right now its is just a Full DB export, soon to be added is Individual AP's and groups of selected AP's.<br>
		</td>
	</tr>
	<tr>
		<td style="border-style: solid; border-width: 1px" height="26">
		0.11</td>
		<td style="border-style: solid; border-width: 1px">
		Phillip Ferland</td>
		<td style="border-style: solid; border-width: 1px" height="26">
		2008-08-12</td>
		<td style="border-style: solid; border-width: 1px" height="26">
		<b>1></b> Fixed the issue where the signal history was getting corrupted and adding in way more signal points then there actually where for the AP. [functions.php->import_vs1()]<br>
		<b>2></b> Added in a `Users` table to keep track of what users imported/updated AP's.<br>
		<b>3></b> Added in `notes` for the group of AP's to be added into the `Users` table, by the user appon import.<br>
		<b>4></b> Fixed most if not all CSS issues<br>
		<b>5></b> Added `VS1` and `VSZ` folders to the `out` dir (exports soon to be added).</td>
	</tr>
	<tr>
		<td style="border-style: solid; border-width: 1px" height="26">
		0.1</td>
		<td style="border-style: solid; border-width: 1px">
		Phillip Ferland</td>
		<td style="border-style: solid; border-width: 1px" height="26">
		2008-06-10</td>
		<td style="border-style: solid; border-width: 1px" height="26">
		<b>1></b> This is a work in progress. Most if not all the features are in their infancy and need much work.
		</td>
	</tr>

	</table>
	<h2><---LINKS---></h2>
	<a class="links" href="">RanInt Forum</a><br>
	<a class="links" href="">WiFiDB Forum</a><br>
<br>
<?php

$filename = $_SERVER['SCRIPT_FILENAME'];
footer($filename);?>