<?php
include('lib/config.inc.php');
include('lib/database.inc.php');
pageheader("Show all Downloads APs");
?>

</td>
		<td width="80%" bgcolor="#A9C6FA" valign="top" align="center">
			<p align="center">
<div align="left">
<font face="Courier New">
<p align="center"><font size="7"><b>WiFiDB Downloads</b></font></p>
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
	<td style="border-style: solid; border-width: 1px" height="26">Version: 0.16 Build 2</td></tr>
	<tr><td style="border-style: solid; border-width: 1px" height="26">Date: 2009-Apr-29</td></tr>
	<tr><td style="border-style: solid; border-width: 1px" height="26">Archives:</td><td><a class="links" href="https://sourceforge.net/project/showfiles.php?group_id=235720&package_id=286323&release_id=669476">SourceForge Download</a></td></tr>
	<tr><td style="border-style: solid; border-width: 1px" height="26">SVN:</td><td><a class="links" href="http://vistumbler.svn.sourceforge.net/viewvc/vistumbler/wifidb/DB/wifidb/?pathrev=310">SourceForge SVN</a></td></tr>
</table>
<br>
<table width="100%" border="2" id="16pb1">
	<tr><td style="border-style: solid; border-width: 1px" height="26">Author: Phillip Ferland</td>
	<td style="border-style: solid; border-width: 1px" height="26">Version: 0.16 Build 1</td></tr>
	<tr><td style="border-style: solid; border-width: 1px" height="26">Date: 2009-Apr-05</td></tr>
	<tr><td style="border-style: solid; border-width: 1px" height="26">Archives:</td><td><a class="links" href="https://sourceforge.net/project/showfiles.php?group_id=235720&package_id=286323&release_id=669476">SourceForge Download</a></td></tr>
	<tr><td style="border-style: solid; border-width: 1px" height="26">SVN:</td><td><a class="links" href="http://vistumbler.svn.sourceforge.net/viewvc/vistumbler/wifidb/DB/wifidb/?pathrev=263">SourceForge SVN</a></td></tr>
</table>
<br>
	<h2><---LINKS---></h2>
	<a class="links" href="http://forum.techidiots.net/forum/viewforum.php?f=22">RanInt Forum</a><br>
	<a class="links" href="http://forum.techidiots.net/forum/viewforum.php?f=44">WiFiDB Forum</a><br>
<br>
<?php

$filename = $_SERVER['SCRIPT_FILENAME'];
footer($filename);
?>