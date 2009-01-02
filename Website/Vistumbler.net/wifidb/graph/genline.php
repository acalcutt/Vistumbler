<?php
/////////////////////////////////////////////////////////////////
//  By: Phillip Ferland (Longbow486)                           //
//  Email: longbow486@msn.com                                  //
//  Started on: 10.14.07                                       //
//  Purpose: To generate a PNG graph of a WAP's signals        //
//           from URL driven data                              //
//  Filename: genlineurl.php                                   //
/////////////////////////////////////////////////////////////////
include("../lib/graph.inc.php");
include("../lib/config.inc.php");

$startdate="14-10-2007";
$lastedit="29-10-2008";
echo '<title>WiFiDB PNG Signal Graph *Beta* - ---RanInt---</title>';
?>

<link rel="stylesheet" href="../css/site4.0.css">
<body topmargin="10" leftmargin="0" rightmargin="0" bottommargin="10" marginwidth="10" marginheight="10">
<div align="center">
<table border="0" width="75%" cellspacing="10" cellpadding="2">
	<tr>
		<td bgcolor="#315573">
		<p align="center"><b><font size="5" face="Arial" color="#FFFFFF">
		Wireless DataBase *Alpha* </font>
		<font color="#FFFFFF" size="2">
            <a class="links" href="/">[Root] </a>/
		</font></b>
		</td>
	</tr>
</table>
</div>
<div align="center">
<table border="0" width="75%" cellspacing="10" cellpadding="2" height="90">
	<tr>
<td width="170px" bgcolor="#304D80" valign="top">
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
		<td bgcolor="#A9C6FA" valign="top" align="center">
			<p align="center">
<?php

if($_POST['line']==='line')
{
	$name = $_POST['name'];
	$ssid = $_POST['ssid'];
	$mac = $_POST['mac'];
	$man = $_POST['man'];
	$auth = $_POST['auth'];
	$encry = $_POST['encry'];
	$radio = $_POST['radio'];
	$chan = $_POST['chan'];
	$lat = $_POST['lat'];
	$long = $_POST['long'];
	$btx = $_POST['btx'];
	$otx = $_POST['otx'];
	$fa = $_POST['fa'];
	$lu = $_POST['lu'];
	$nt = $_POST['nt'];
	$label = $_POST['label'];
	$sig = $_POST['sig'];
	$text = $_POST['text'];
	$linec = $_POST['linec'];
	echo '<form action="genline.php" method="post" enctype="multipart/form-data">';
	echo '<input name="ssid" type="hidden" value="'.$ssid.'"/>';
	echo '<input name="mac" type="hidden" value="'.$mac.'"/>';
	echo '<input name="man" type="hidden" value="'.$man.'"/>';
	echo '<input name="auth" type="hidden" value="'.$auth.'"/>';
	echo '<input name="encry" type="hidden" value="'.$encry.'"/>';
	echo '<input name="radio" type="hidden" value="'.$radio.'"/>';
	echo '<input name="chan" type="hidden" value="'.$chan.'"/>';
	echo '<input name="lat" type="hidden" value="'.$lat.'"/>';
	echo '<input name="long" type="hidden" value="'.$long.'"/>';
	echo '<input name="btx" type="hidden" value="'.$btx.'"/>';
	echo '<input name="otx" type="hidden" value="'.$otx.'"/>';
	echo '<input name="fa" type="hidden" value="'.$fa.'"/>';
	echo '<input name="lu" type="hidden" value="'.$lu.'"/>';
	echo '<input name="nt" type="hidden" value="'.$nt.'"/>';
	echo '<input name="label" type="hidden" value="'.$label.'"/>';
	echo '<input name="sig" type="hidden" value="'.$sig.'"/>';
	echo '<input name="text" type="hidden" value="'.$text.'"/>';
	echo '<input name="linec" type="hidden" value="'.$linec.'"/>';
	echo '<input name="name" type="hidden" value="'.$name.'"/>';
	echo '<input name="line" type="hidden" value=""/>';
	echo '<input name="Genline" type="submit" value="Generate Bar Graph" />';
	echo '</form>';
	
	graphs::wifigraphline($ssid, $mac, $man, $auth, $encry, $radio, $chan, $lat, $long, $btx, $otx, $fa, $lu, $nt, $label, $sig, $name, $linec, $text );
	
	echo 'You can find your Wifi Graph here -> <a href="../out/graph/'.$name.'v.png">'.$name.'v.png</a>';

}else
{
	$name = $_POST['name'];
	$ssid = $_POST['ssid'];
	$mac = $_POST['mac'];
	$man = $_POST['man'];
	$auth = $_POST['auth'];
	$encry = $_POST['encry'];
	$radio = $_POST['radio'];
	$chan = $_POST['chan'];
	$lat = $_POST['lat'];
	$long = $_POST['long'];
	$btx = $_POST['btx'];
	$otx = $_POST['otx'];
	$fa = $_POST['fa'];
	$lu = $_POST['lu'];
	$nt = $_POST['nt'];
	$label = $_POST['label'];
	$sig = $_POST['sig'];
	$text = $_POST['text'];
	$linec = $_POST['linec'];
	echo '<form action="genline.php" method="post" enctype="multipart/form-data">';
	echo '<input name="ssid" type="hidden" value="'.$ssid.'"/>';
	echo '<input name="mac" type="hidden" value="'.$mac.'"/>';
	echo '<input name="man" type="hidden" value="'.$man.'"/>';
	echo '<input name="auth" type="hidden" value="'.$auth.'"/>';
	echo '<input name="encry" type="hidden" value="'.$encry.'"/>';
	echo '<input name="radio" type="hidden" value="'.$radio.'"/>';
	echo '<input name="chan" type="hidden" value="'.$chan.'"/>';
	echo '<input name="lat" type="hidden" value="'.$lat.'"/>';
	echo '<input name="long" type="hidden" value="'.$long.'"/>';
	echo '<input name="btx" type="hidden" value="'.$btx.'"/>';
	echo '<input name="otx" type="hidden" value="'.$otx.'"/>';
	echo '<input name="fa" type="hidden" value="'.$fa.'"/>';
	echo '<input name="lu" type="hidden" value="'.$lu.'"/>';
	echo '<input name="nt" type="hidden" value="'.$nt.'"/>';
	echo '<input name="label" type="hidden" value="'.$label.'"/>';
	echo '<input name="sig" type="hidden" value="'.$sig.'"/>';
	echo '<input name="text" type="hidden" value="'.$text.'"/>';
	echo '<input name="linec" type="hidden" value="'.$linec.'"/>';
	echo '<input name="name" type="hidden" value="'.$name.'"/>';
	echo '<input name="line" type="hidden" value="line"/>';
	echo '<input name="Genline" type="submit" value="Generate Line Graph" />';
	echo '</form>';
	graphs::wifigraphbar($ssid, $mac, $man, $auth, $encry, $radio, $chan, $lat, $long, $btx, $otx, $fa, $lu, $nt, $label, $sig, $name, $linec, $text);

	echo 'You can find your Wifi Graph here -> <a href="../out/graph/'.$name.'.png">'.$name.'.png</a>';

	}
	
$filename = $_SERVER['SCRIPT_FILENAME'];
$file_ex = explode("/", $filename);
$count = count($file_ex);
$file = $file_ex[($count)-1];
if (file_exists($filename)) {
    echo "<h6><i><u>$file</u></i> was last modified: " . date ("F d Y H:i:s.", filemtime($filename)) . "</h6>";
}
?>
<tr>
<td bgcolor="#315573" height="23"><a href="/pictures/moon.png"><img border="0" src="/pictures/moon_tn.PNG"></a></td>
<td bgcolor="#315573" width="0">
</td>
</tr>
</table>