<?php
include('../../lib/database.inc.php');
echo '<title>Wireless DataBase *Alpha*'.$ver["wifidb"].' --> Patch (GPS Table) Page</title>';
?>
<link rel="stylesheet" href="../../css/site4.0.css">
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
<table border="0" width="75%" cellspacing="10" cellpadding="2" height="90"><tr>
<td width="17%" bgcolor="#304D80" valign="top">
<!--LINKS-->
</td>
<td width="80%" bgcolor="#A9C6FA" valign="top" align="center"><br>
<!--BODY-->
  <h2>WiFiDB Patch GPS Tables</h2>
  <h4>This script will alter all the GPS tables. <br>There was an error in how the tables where being created, and wouldn't store some GPS data correctly.</h4>
<table border="0"cellspacing="0" cellpadding="3">
  <tr>
    <td colspan="2" ><a class="links" href="patch_gps_tbl.php">Click here to run the patch.</a></td></tr>
</TABLE>
<?php
$timezn = 'Etc/GMT+5';
date_default_timezone_set($timezn);
$filename = $_SERVER['SCRIPT_FILENAME'];
$file_ex = explode("/", $filename);
$count = count($file_ex);
$file = $file_ex[($count)-1];
?>
</p>
</td>
</tr>
<tr>
<td bgcolor="#315573" height="23"><a href="../img/moon.png"><img border="0" src="../img/moon_tn.png"></a></td>
<td bgcolor="#315573" width="0" align="center">
<?php
if (file_exists($filename)) {?>
	<h6><i><u><?php echo $file;?></u></i> was last modified:  <?php echo date ("Y F d @ H:i:s", filemtime($filename));?></h6>
<?php
}
?>
</td>
</tr>
</table>
</body>
</html>