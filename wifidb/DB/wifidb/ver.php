<?php
include('lib/config.inc.php');
include('lib/database.inc.php');
echo '<title>Wireless DataBase *Alpha*'.$ver["wifidb"].' --> Main Page</title>';
?>
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
<table border="0" id="table1" cellpadding="2">
	<tr>
		<td><p>Project Name(pseudo-name):  </p></td><td><p><b>WiFiDB</b></p> </td>
	</tr>
	<tr>
		<td><p>Project State: </p></td><td><p><b>Alpha (planning and early dev)</p></b><td>
	</tr>
	<tr>
		<td><p>Project Dev(s): </P></td><td><p><b><a class="links" href="http://forum.techidiots.net/forum/memberlist.php?mode=viewprofile&u=6">PFerland</P></a></b><td>
	</tr>
</table>
<table border="0" id="table1" cellpadding="2">
	<tr>
		<td width="67" style="border-style: solid; border-width: 1px" height="26">
		Version</td>
		<td width="285" height="26" style="border-style: solid; border-width: 1px">
		Author(s)</td>
		<td style="border-style: solid; border-width: 1px" height="26">
		Date</td>
		<td style="border-style: solid; border-width: 1px" height="26">Fixes</td>
	</tr>	
	<tr>
		<td width="67" style="border-style: solid; border-width: 1px" height="26">
		0.15 Build 76</td>
		<td width="285" height="26" style="border-style: solid; border-width: 1px">
		Phillip Ferland</td>
		<td style="border-style: solid; border-width: 1px" height="26">
		2008-12-20</td>
		<td style="border-style: solid; border-width: 1px" height="26">
		1> There where a few major bugs in the install script that are now fixed
		2> There was no Upgrade script in the install folder to do a safe upgrade from v0.14 to v0.15. go to /install/upgrade.php
		</td>
	</tr>
	<tr>
		<td width="67" style="border-style: solid; border-width: 1px" height="26">
		0.15 Build 75</td>
		<td width="285" height="26" style="border-style: solid; border-width: 1px">
		Phillip Ferland</td>
		<td style="border-style: solid; border-width: 1px" height="26">
		2008-12-19</td>
		<td style="border-style: solid; border-width: 1px" height="26">
		1> Added in a very basic (to start) search page, to search for Access Points.<br>
		2> (Work in progress) Changing the GPS check so that it checks the DB for the GPS point and from there, if there is a return, point to that GPS, if not add it to the table.<br>
		3> Added associated Import list for Access Points.
		4> Added in Security warning incase the /install folder is not removed.
		5> Added some more user input sanitization.
		</td>
	</tr>	
	<tr>
		<td width="67" style="border-style: solid; border-width: 1px" height="26">
		0.15 Build 73</td>
		<td width="285" height="26" style="border-style: solid; border-width: 1px">
		Phillip Ferland</td>
		<td style="border-style: solid; border-width: 1px" height="26">
		2008-11-28</td>
		<td style="border-style: solid; border-width: 1px" height="26">
		1> Changed the import report page to have tables for the output, so that it is more organized and is easier to tell weather the access point is a new or updated <br>
		2> (Work in progress) Changed the GPS check so that it checks the DB for the GPS point and from there, if there is a return, point to that GPS, if not add it to the table<br>
		</td>
	</tr>
	<tr>
		<td width="67" style="border-style: solid; border-width: 1px" height="26">
		0.15 Build 67</td>
		<td width="285" height="26" style="border-style: solid; border-width: 1px">
		Phillip Ferland</td>
		<td style="border-style: solid; border-width: 1px" height="26">
		2008-11-19</td>
		<td style="border-style: solid; border-width: 1px" height="26">
		1> Added GPS history to Access Point Fetch page<br>
		2> Added View all AP's for a given user<br>
		3> Fixed bug in the import_vs1 function where the page was not rendering right, even though it was importing correctly<br>
		4> Fixed a bug where the AP fetch page wasnt showing more then one row of signal history even though there was more then one<br>
		</td>
	</tr>
	<tr>
		<td width="67" style="border-style: solid; border-width: 1px" height="26">
		0.14</td>
		<td width="285" height="26" style="border-style: solid; border-width: 1px">
		Phillip Ferland</td>
		<td style="border-style: solid; border-width: 1px" height="26">
		2008-11-14</td>
		<td style="border-style: solid; border-width: 1px" height="26">
		1> Changed the All users list, so that it displays only the first ID for a user (which is considered the users Unique ID)<br>
		2> Fixed an issue where randomly an AP would have more signal history points then GPS history points<br>
		3> Added installer for easy setup. Just go to /[WifiDB path]/install/<br>
		4> Fixed a few more bugs/PEBKAC errors<br>
		</td>
	</tr>
	<tr>
		<td width="67" style="border-style: solid; border-width: 1px" height="26">
		0.13</td>
		<td width="285" height="26" style="border-style: solid; border-width: 1px">
		Phillip Ferland</td>
		<td style="border-style: solid; border-width: 1px" height="26">
		2008-10-30</td>
		<td style="border-style: solid; border-width: 1px" height="26">
		1> Rearranged functions.php into database.inc.php(all database related functions) and graph.inc.php (all graphing and image related functions).<br>
		2> Fixed a few more bugs/PEBKAC errors<br>
		</td>
	</tr>
	<tr>
		<td width="67" style="border-style: solid; border-width: 1px" height="26">
		0.12</td>
		<td width="285" height="26" style="border-style: solid; border-width: 1px">
		Phillip Ferland</td>
		<td style="border-style: solid; border-width: 1px" height="26">
		2008-08-19</td>
		<td style="border-style: solid; border-width: 1px" height="26">
		1> Added in graphing for AP's signal history, one row of history at a time for the moment.<br>
		2> Added in Users Stats page to view what users have imported / updated what AP's.<br>
		3> Added in KML exports, right now its is just a Full DB export, soon to be added is Individual AP's and groups of selected AP's.<br>
		</td>
	</tr>
	<tr>
		<td width="67" style="border-style: solid; border-width: 1px" height="26">
		0.11</td>
		<td width="285" height="26" style="border-style: solid; border-width: 1px">
		Phillip Ferland</td>
		<td style="border-style: solid; border-width: 1px" height="26">
		2008-08-12</td>
		<td style="border-style: solid; border-width: 1px" height="26">
		1> Fixed the issue where the signal history was getting corrupted and adding in way more signal points then there actually where for the AP. [functions.php->import_vs1()]<br>
		2> Added in a `Users` table to keep track of what users imported/updated AP's.<br>
		3> Added in `notes` for the group of AP's to be added into the `Users` table, by the user appon import.<br>
		4> Fixed most if not all CSS issues<br>
		5> Added `VS1` and `VSZ` folders to the `out` dir (exports soon to be added).</td>
	</tr>
	<tr>
		<td width="67" style="border-style: solid; border-width: 1px" height="26">
		0.1</td>
		<td width="285" height="26" style="border-style: solid; border-width: 1px">
		Phillip Ferland</td>
		<td style="border-style: solid; border-width: 1px" height="26">
		2008-06-10</td>
		<td style="border-style: solid; border-width: 1px" height="26">This is a work in progress. Most if not all the features are in their infancy and need much work.</td>
	</tr>

	</table>
	<h2><---LINKS---></h2>
	<a class="links" href="">RanInt Forum</a><br>
	<a class="links" href="">WiFiDB Forum</a><br>
<br>
<?php
$filename = $_SERVER['SCRIPT_FILENAME'];
$file_ex = explode("/", $filename);
$count = count($file_ex);
$file = $file_ex[($count)-1];
if (file_exists($filename)) {
    echo "<h6><i><u>$file</u></i> was last modified: " . date ("F d Y H:i:s.", filemtime($filename)) . "</h6>";
}
?>
<br>
</font>
</td>
</tr>
<tr>
<td bgcolor="#315573" height="23"><a href="/pictures/moon.png"><img border="0" src="/pictures/moon_tn.PNG"></a></td>
<td bgcolor="#315573" width="0">

</td>
</tr>
</table>
</div>
</html>
