<?php
include('../lib/config.inc.php');
include('../lib/database.inc.php');
echo '<title>Wireless DataBase *Alpha*'.$ver["wifidb"].' --> Access Point Info Page</title>';
?>
<link rel="stylesheet" href="../css/site4.0.css">
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
$sqls = "SELECT * FROM links ORDER BY ID ASC";
$result = mysql_query($sqls, $conn) or die(mysql_error());
while ($newArray = mysql_fetch_array($result))
{
	$testField = $newArray['links'];
    echo "<p>$testField</p>";
}
?>
</td>
		<td width="80%" bgcolor="#A9C6FA" valign="top" align="center">
			<p align="center">
<?php
if ($debug == 1 ){echo '<p align="right"><a class="links" href="../opt/debug/fetch.php">Debug</a></p>';}
$id = $_GET['id'];
mysql_select_db($db,$conn);
$sqls = "SELECT * FROM `$wtable` WHERE id='$id'";
$result = mysql_query($sqls, $conn) or die(mysql_error());
$newArray = mysql_fetch_array($result);
$ID = $newArray['id'];
$ssid = $newArray['ssid'];
$macaddress = $newArray['mac'];
$mac = str_split($macaddress,2);
$mac_full = $mac[0].":".$mac[1].":".$mac[2].":".$mac[3].":".$mac[4].":".$mac[5];

$man_mac = str_split($macaddress, 6);
$manmac = $man_mac[0];
if($manufactures[$manmac] == ""){$man = "UNKNOWN Manufacture";}else{$man = $manufactures[$manmac];}
$chan = $newArray['chan'];
$radio = $newArray['radio'];
$auth = $newArray['auth'];
$encry = $newArray['encry'];
if($radio == "a")
	{$radio = "802.11a";}
elseif($radio == "b")
	{$radio = "802.11b";}
elseif($radio == "g")
	{$radio = "802.11g";}
elseif($radio == "n")
	{$radio = "802.11n";}
else
	{$radio = "802.11u";}
echo '<h1>'.$ssid.'</h1><TABLE WIDTH=569 BORDER=1 CELLPADDING=4 CELLSPACING=0 STYLE="page-break-before: always"><COL WIDTH=112><COL WIDTH=439>'
		.'<TR VALIGN=TOP><TD WIDTH=112><P>MAC Address</P></TD><TD WIDTH=439><P>'.$mac_full.'</P></TD></TR>'
		.'<TR VALIGN=TOP><TD WIDTH=112><P>Manufacture</P></TD><TD WIDTH=439><P>'.$man.'</P></TD></TR>'
		.'<TR VALIGN=TOP><TD WIDTH=112 HEIGHT=26><P>Authentication</P></TD><TD WIDTH=439><P>'.$auth.'</P></TD></TR>'
		.'<TR VALIGN=TOP><TD WIDTH=112><P>Encryption Type</P></TD><TD WIDTH=439><P>'.$encry.'</P></TD></TR>'
		.'<TR VALIGN=TOP><TD WIDTH=112><P>Radio Type</P></TD><TD WIDTH=439><P>'.$radio.'</P></TD></TR>'
		.'<TR VALIGN=TOP><TD WIDTH=112><P>Channel #</P></TD><TD WIDTH=439><P>'.$chan.'</P></TD></TR></TABLE>';
			
$table=$ssid.'-'.$newArray["mac"].'-'.$newArray["sectype"].'-'.$newArray["radio"].'-'.$chan;
$table_gps=$ssid.'-'.$newArray["mac"].'-'.$newArray["sectype"].'-'.$newArray["radio"].'-'.$chan.$gps_ext;
echo "<h3>Signal History</h3>";
database::apfetch($table);
echo "<h3>GPS History</h3>";
database::gpsfetch($table_gps);

echo "<h3>Associated Lists</h3>";
database::lfetch($ID);

$filename = $_SERVER['SCRIPT_FILENAME'];
$file_ex = explode("/", $filename);
$count = count($file_ex);
$file = $file_ex[($count)-1];
if (file_exists($filename)) {
    echo "<h6><i><u>$file</u></i> was last modified: " . date ("F d Y H:i:s.", filemtime($filename)) . "</h6>";
}

?>
</p>
</td>
</tr>
<tr>
<td bgcolor="#315573" height="23"><a href="/pictures/moon.png"><img border="0" src="/pictures/moon_tn.PNG"></a></td>
<td bgcolor="#315573" width="0">
</td>
</tr>
</table>