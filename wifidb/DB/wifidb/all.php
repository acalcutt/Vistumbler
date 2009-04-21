<?php
include('lib/config.inc.php');
include('lib/database.inc.php');
pageheader("Show all APs");

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
footer($filename);?>