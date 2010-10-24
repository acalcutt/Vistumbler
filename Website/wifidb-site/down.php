<?php
include('demo/lib/config.inc.php');
include('demo/themes/wifidb/header_footer.inc.php');

	session_start();
	if(!$_SESSION['token'] or !$_GET['token'])
	{
		$token = md5(uniqid(rand(), true));
		$_SESSION['token'] = $token;
	}else
	{
		$token = $_SESSION['token'];
	}
	
	$root	=	$GLOBALS['root'];
	$conn	=	$GLOBALS['conn'];
	$db		=	$GLOBALS['db'];
	$head	= 	$GLOBALS['headers'];
	
	echo "<html>\r\n<head>\r\n<title>Wireless DataBase".$GLOBALS['ver']['wifidb']." --> ".$title."</title>\r\n".$head."\r\n</head>\r\n";
	?>
	<link rel="stylesheet" href="demo/themes/wifidb/styles.css">
	<body topmargin="10" leftmargin="0" rightmargin="0" bottommargin="10" marginwidth="10" marginheight="10">
	<div align="center">
	<table border="0" width="85%" cellspacing="5" cellpadding="2">
		<tr style="background-color: #315573;"><td colspan="2">
		<table width="100%"><tr>
				<td style="width: 215px">
					&nbsp;&nbsp;&nbsp;&nbsp;<a href="http://www.randomintervals.com/wifidb/"><img border="0" src="/wifidb/demo/img/logo.png"></a>
				</td>
				<td>
					<p align="center"><b>
					<font style="size: 5;font-family: Arial;color: #FFFFFF;">
					Wireless DataBase<?php echo $GLOBALS['ver']['wifidb'].'<br /><br />'; ?>
					</font>
					</b></p>
				</td>
		</tr></table>
		</td></tr>
		<tr>
			<td style="background-color: #304D80;width: 15%;vertical-align: top;">
			<img alt="" src="/wifidb/themes/wifidb/img/1x1_transparent.gif" width="185" height="1" /><br>
			<a class="links" href="demo/">Main Page</a><br>
			<a class="links" href="demo/all.php?sort=SSID&ord=ASC&from=0&to=100">View All APs</a><br>
			<a class="links" href="demo/import/">Import</a><br>
			<a class="links" href="demo/opt/scheduling.php">Files Waiting for Import</a><br>
			<a class="links" href="demo/opt/scheduling.php?func=done">Files Already Imported</a><br>
			<a class="links" href="demo/opt/scheduling.php?func=daemon_kml">Daemon Generated KML</a><br>
			<a class="links" href="demo/opt/export.php?func=index">Export</a><br>
			<a class="links" href="demo/opt/search.php">Search</a><br>
			<a class="links" href="demo/themes/">Themes</a><br>
			<a class="links" href="demo/opt/userstats.php?func=allusers">View All Users</a><br>
			<a class="links" href="http://forum.techidiots.net/forum/viewforum.php?f=47">Help / Support</a><br>
			<a class="links" href="demo/ver.php">WiFiDB Version</a><br>
			<a class="links" href="http://www.randomintervals.com/wifidb/down.php">Download WiFiDB</a><br>
		</td>
		<td style="background-color: #A9C6FA;width: 80%;vertical-align: top;" align="center">
								<div align="center">
<font face="Courier New">
<p align="center"><font size="7"><b>WiFiDB Downloads</b></font></p>
<table width="100%" border="2" id="16b3r2">
	<tr><td style="border-style: solid; border-width: 1px" height="26">Author: Phillip Ferland</td>
	<td style="border-style: solid; border-width: 1px" height="26"><a class="links" href="http://www.randomintervals.com/wifidb/demo/ver.php#16b4">Version: 0.16 Build 4</a></td></tr>
	<tr><td style="border-style: solid; border-width: 1px" height="26">Date: 2009-Sept-**</td></tr>
	<tr><td style="border-style: solid; border-width: 1px" height="26">Archives:</td><td><a class="links" href="https:/sourceforge.net/projects/vistumbler/files/WiFiDB/wifidb-alpha-016-b4.tar.gz/download">Tar.Gz</a><br><a class="links" href="https:/sourceforge.net/projects/vistumbler/files/WiFiDB/wifidb-alpha-016-b4.zip/download">Zip</a></td></tr>
	<tr><td style="border-style: solid; border-width: 1px" height="26">SVN:</td><td>SourceForge SVN</td></tr>
</table>
<br>
<table width="100%" border="2" id="16b3r2">
	<tr><td style="border-style: solid; border-width: 1px" height="26">Author: Phillip Ferland</td>
	<td style="border-style: solid; border-width: 1px" height="26"><a class="links" href="http://www.randomintervals.com/wifidb/demo/ver.php#16b3r2">Version: 0.16 Build 3 R2</a></td></tr>
	<tr><td style="border-style: solid; border-width: 1px" height="26">Date: 2009-Jul-23</td></tr>
	<tr><td style="border-style: solid; border-width: 1px" height="26">Archives:</td><td><a class="links" href="https:/sourceforge.net/projects/vistumbler/files/WiFiDB/wifidb-alpha-016-b3-R2.zip/download">Zip</a></td></tr>
	<tr><td style="border-style: solid; border-width: 1px" height="26">SVN:</td><td>SourceForge SVN</td></tr>
</table>
<br>
<table width="100%" border="2" id="16b3">
	<tr><td style="border-style: solid; border-width: 1px" height="26">Author: Phillip Ferland</td>
	<td style="border-style: solid; border-width: 1px" height="26"><a class="links" href="http://www.randomintervals.com/wifidb/demo/ver.php#16b3">Version: 0.16 Build 3</a></td></tr>
	<tr><td style="border-style: solid; border-width: 1px" height="26">Date: 2009-Jul-10</td></tr>
	<tr><td style="border-style: solid; border-width: 1px" height="26">Archives:</td><td><a class="links" href="https:/sourceforge.net/projects/vistumbler/files/WiFiDB/wifidb-alpha-016-b3.tar.gz/download">Tar Gz</a><br><a class="links" href="https:/sourceforge.net/projects/vistumbler/files/WiFiDB/wifidb-alpha-016-b3.zip/download">Zip</a></td></tr>
	<tr><td style="border-style: solid; border-width: 1px" height="26">SVN:</td><td><a class="links" href="http:/vistumbler.svn.sourceforge.net/viewvc/vistumbler/wifidb/?pathrev=414">SourceForge SVN</a></td></tr>
</table>
<br>
<table width="100%" border="2" id="16b2.l">
	<tr><td style="border-style: solid; border-width: 1px" height="26">Author: Phillip Ferland</td>
	<td style="border-style: solid; border-width: 1px" height="26"><a class="links" href="http://www.randomintervals.com/wifidb/demo/ver.php#16b3">Version: 0.16 Build 2.1</a></td></tr>
	<tr><td style="border-style: solid; border-width: 1px" height="26">Date: 2009-May-05</td></tr>
	<tr><td style="border-style: solid; border-width: 1px" height="26">Archives:</td><td><a class="links" href="https:/sourceforge.net/projects/vistumbler/files/WiFiDB/wifidb-alpha-016-build2-1.zip/download">Zip</a></td></tr>
	<tr><td style="border-style: solid; border-width: 1px" height="26">SVN:</td><td><a class="links" href="http:/vistumbler.svn.sourceforge.net/viewvc/vistumbler/wifidb/?pathrev=312">SourceForge SVN</a></td></tr>
</table>
<br>
<table width="100%" border="2" id="16b2">
	<tr><td style="border-style: solid; border-width: 1px" height="26">Author: Phillip Ferland</td>
	<td style="border-style: solid; border-width: 1px" height="26"><a class="links" href="http://www.randomintervals.com/wifidb/demo/ver.php#16b21">Version: 0.16 Build 2</a></td></tr>
	<tr><td style="border-style: solid; border-width: 1px" height="26">Date: 2009-Apr-29</td></tr>
	<tr><td style="border-style: solid; border-width: 1px" height="26">Archives:</td><td><a class="links" href="https:/sourceforge.net/projects/vistumbler/files/WiFiDB/wifidb-alpha-016-b2.tar.gz/download">Tar Gz</a><br><a class="links" href="https:/sourceforge.net/projects/vistumbler/files/WiFiDB/wifidb-alpha-016-b2.zip/download">Zip</a></td></tr>
	<tr><td style="border-style: solid; border-width: 1px" height="26">SVN:</td><td><a class="links" href="http:/vistumbler.svn.sourceforge.net/viewvc/vistumbler/wifidb/?pathrev=310">SourceForge SVN</a></td></tr>
</table>
<br>
<table width="100%" border="2" id="16b1">
	<tr><td style="border-style: solid; border-width: 1px" height="26">Author: Phillip Ferland</td>
	<td style="border-style: solid; border-width: 1px" height="26"><a class="links" href="http://www.randomintervals.com/wifidb/demo/ver.php#16b2">Version: 0.16 Build 1</a></td></tr>
	<tr><td style="border-style: solid; border-width: 1px" height="26">Date: 2009-Apr-05</td></tr>
	<tr><td style="border-style: solid; border-width: 1px" height="26">Archives:</td><td><a class="links" href="https:/sourceforge.net/projects/vistumbler/files/WiFiDB/wifidb-alpha-016-b3.tar.gz/download">Tar Gz</a><br><a class="links" href="https:/sourceforge.net/projects/vistumbler/files/WiFiDB/wifidb-alpha-016-b1.zip/download">Zip</a></td></tr>
	<tr><td style="border-style: solid; border-width: 1px" height="26">SVN:</td><td><a class="links" href="http:/vistumbler.svn.sourceforge.net/viewvc/vistumbler/wifidb/?pathrev=263">SourceForge SVN</a></td></tr>
</table>
<?php 
footer($_SERVER['SCRIPT_FILENAME']);
?>