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
$ord   =	$_GET['ord'];
$sort  =	$_GET['sort'];
$from  =	$_GET['from'];
$from_ =	$_GET['from'];
$inc   =	$_GET['to'];
if ($from==""){$from=0;}
if ($inc==""){$inc=100;}
if ($ord==""){$ord="ASC";}
if ($sort==""){$sort="id";}

?>
</td>
		<td width="80%" bgcolor="#A9C6FA" valign="top" align="center">
			<p align="center">
<?php
		echo '<table border="1" width="100%" cellspacing="0">'
		.'<tr><td>SSID<a href="?sort=SSID&ord=ASC&from='.$from.'&to='.$inc.'"><br><img height="20" width="20" border="0"border="0" src="img/down.png"></a><a href="?sort=SSID&ord=DESC&from='.$from.'&to='.$inc.'"><img height="20" width="20" border="0"src="img/up.png"></a></td>'
		.'<td>MAC<a href="?sort=mac&ord=ASC&from='.$from.'&to='.$inc.'"><br><img height="20" width="20" border="0"src="img/down.png"></a><a href="?sort=mac&ord=DESC&from='.$from.'&to='.$inc.'"><img height="20" width="20" border="0"src="img/up.png"></a></td>'
		.'<td>Chan<a href="?sort=chan&ord=ASC&from='.$from.'&to='.$inc.'"><br><img height="20" width="20" border="0"src="img/down.png"></a><a href="?sort=chan&ord=DESC&from='.$from.'&to='.$inc.'"><img height="20" width="20" border="0"src="img/up.png"></a></td>'
		.'<td>Radio Type<a href="?sort=radio&ord=ASC&from='.$from.'&to='.$inc.'"><br><img height="20" width="20" border="0" src="img/down.png"></a><a href="?sort=radio&ord=DESC&from='.$from.'&to='.$inc.'"><img height="20" width="20" border="0"src="img/up.png"></a></td>'
		.'<td>Authentication<a href="?sort=auth&ord=ASC&from='.$from.'&to='.$inc.'"><br><img height="20" width="20" border="0" src="img/down.png"></a><a href="?sort=auth&ord=DESC&from='.$from.'&to='.$inc.'"><img height="20" width="20" border="0"src="img/up.png"></a></td>'
		.'<td>Encryption<a href="?sort=encry&ord=ASC&from='.$from.'&to='.$inc.'"><br><img height="20" width="20" border="0" src="img/down.png"></a><a href="?sort=encry&ord=DESC&from='.$from.'&to='.$inc.'"><img height="20" width="20" border="0"src="img/up.png"></a></td></tr>';

$x=0;
$n=0;
$to=$from+$inc;
mysql_select_db($db,$conn);
$sql0 = "SELECT * FROM $wtable ORDER BY $sort $ord  LIMIT $from , $inc";
$result = mysql_query($sql0, $conn) or die(mysql_error());
while ($newArray = mysql_fetch_array($result))
{
    $id = $newArray['id'];
	$ssid = $newArray['ssid'];
    $mac = $newArray['mac'];
	$mac_exp = str_split($mac,2);
	$mac = implode(":",$mac_exp);
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
?>
</table>
</p>
<?php
echo "<br>Page: ";
$sql1 = "SELECT * FROM $wtable";
$result = mysql_query($sql1, $conn) or die(mysql_error());
$size = mysql_num_rows($result);
$from_fwd=$from;
$from = 0;
$page = 1;
$pages = $size/$inc;
if ($from=0)
{
	$from_back=$to_back-$inc;
	echo '<a class="links" href="?from='.$from_back.'&to='.$$inc.'&sort='.$sort.'&ord='.$ord.'"><- </a> ';
}
else
{
	echo"< -";
}
for($I=0; $I<=$pages; $I++)
{
		echo ' <a class="links" href="?from='.$from.'&to='.$inc.'&sort='.$sort.'&ord='.$ord.'">'.$page.'</a> - ';
		$from=$from+$inc;
		$page++;
}
if ($from_<=$size)
{
	echo">";
}
else
{
	echo '<a class="links" href="?from='.$from_fwd.'&to='.$$inc.'&sort='.$sort.'&ord='.$ord.'">></a>';
}

$filename = $_SERVER['SCRIPT_FILENAME'];
$file_ex = explode("/", $filename);
$count = count($file_ex);
$file = $file_ex[($count)-1];
if (file_exists($filename)) {
    echo "<h6><i><u>$file</u></i> was last modified: " . date ("F d Y H:i:s.", filemtime($filename)) . "</h6>";
}
?>
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
