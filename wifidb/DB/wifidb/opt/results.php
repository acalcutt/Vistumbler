<?php
include('../lib/database.inc.php');
include('../lib/config.inc.php');
echo '<title>Wireless DataBase *Alpha*'.$ver["wifidb"].' --> Search Results Page</title>';
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
			<h2>Search Results</h2>
<?php
$sql_a=array();
$mac_explode = explode(':', $_POST['mac']);
$mac_post = implode('', $mac_explode);
strip_tags($_POST['ssid']);
strip_tags($mac_post);
strip_tags($_POST['radio']);
strip_tags($_POST['chan']);
strip_tags($_POST['auth']);
strip_tags($_POST['encry']);

if ($_POST['ssid'] !== '')	{ $sql_a[]	=	" `ssid` = '".$_POST['ssid']."' ";}
if ($mac_post !== '')		{ $sql_a[]	=	" `mac` = '".$mac_post."' ";}
if ($_POST['radio'] !== '')	{ $sql_a[]	=	" `radio` = '".$_POST['radio']."' ";}
if ($_POST['chan'] !== '')	{ $sql_a[]	=	" `chan` = '".$_POST['chan']."' ";}
if ($_POST['auth'] !== '')	{ $sql_a[]	=	" `auth` = '".$_POST['auth']."' ";}
if ($_POST['encry'] !== '')	{ $sql_a[]	=	" `encry` = '".$_POST['encry']."' ";}

echo '<table border="1" width="100%" cellspacing="0">'
.'<tr><th>SSID</th>'
.'<th>MAC</th>'
.'<th>Chan</th>'
.'<th>Radio Type</th>'
.'<th>Authentication</th>'
.'<th>Encryption</th></tr>';

$ord   =	$_GET['ord'];
sript_tags($ord);
$sort  =	$_GET['sort'];
sript_tags($sort);
$from  =	$_GET['from'];
sript_tags($from);
$from_ =	$_GET['from'];
sript_tags($from_);
$inc   =	$_GET['to'];
sript_tags($inc);
if ($from==""){$from=0;}
if ($inc==""){$inc=100;}
if ($ord==""){$ord="ASC";}
if ($sort==""){$sort="id";}
$x=0;
$n=0;
$to=$from+$inc;
mysql_select_db($db,$conn);
$sql0 .= "SELECT * FROM $wtable WHERE " . implode(' AND ', $sql_a) ." ORDER BY $sort $ord";
$result = mysql_query($sql0, $conn) or die(mysql_error());
while ($newArray = mysql_fetch_array($result))
{
    $id = $newArray['id'];
	$ssid = $newArray['ssid'];
    $mac = $newArray['mac'];
    $chan = $newArray['chan'];
	$radio = $newArray['radio'];
	$auth = $newArray['auth'];
	$encry = $newArray['encry'];
    echo '<tr><td><a class="links" href="opt/fetch.php?id='.$id.'">'.$ssid.'</a></td>';
    echo '<td>'.$mac.'</td>';
    echo '<td>'.$chan.'</td>';
	if($radio=="a")
	{$radio="802.11a";}
	elseif($radio=="b")
	{$radio="802.11b";}
	elseif($radio=="g")
	{$radio="802.11g";}
	elseif($radio=="n")
	{$radio="802.11n";}
	else
	{$radio="Unknown Radio";}
	echo '<td>'.$radio.'</td>';
	echo '<td>'.$auth.'</td>';
	echo '<td>'.$encry.'</td></tr>';	
}
echo "</table>";


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