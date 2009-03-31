<?php
include('../lib/database.inc.php');
include('../lib/config.inc.php');

pageheader("Search Results Page");
	?>
	</td>
			<td width="80%" bgcolor="#A9C6FA" valign="top" align="center">
				<p align="center">
			<h2>Search Results</h2>
<?php

if (isset($_POST['ssid']))	{$ssid = $_POST['ssid'];  }elseif(isset($_GET['ssid'])){$ssid = $_GET['ssid'];}
if (isset($_POST['mac']))	{$mac = $_POST['mac'];}elseif(isset($_GET['mac'])){$mac = $_GET['mac'];}
if (isset($_POST['radio']))	{$radio = $_POST['radio']; }elseif(isset($_GET['radio'])){$radio = $_GET['radio'];}
if (isset($_POST['chan']))	{$chan = $_POST['chan']; }elseif(isset($_GET['chan'])){$chan = $_GET['chan'];}
if (isset($_POST['auth']))	{$auth = $_POST['auth']; }elseif(isset($_GET['auth'])){$auth = $_GET['auth'];}
if (isset($_POST['encry']))	{$encry = $_POST['encry'];  }elseif(isset($_GET['encry'])){$encry = $_GET['encry'];}

$ord   =	$_GET['ord'];
$sort  =	$_GET['sort'];
$from  =	$_GET['from'];
$from_ =	$_GET['from'];
$inc   =	$_GET['to'];

strip_tags($ord);
strip_tags($sort);
strip_tags($from);
strip_tags($from_);
strip_tags($inc);

strip_tags($ssid);
strip_tags($mac);
strip_tags($radio);
strip_tags($chan);
strip_tags($auth);
strip_tags($encry);

$mac_explode = explode(':', $mac);
$mac_co = count($mac_explode);
if($mac_co > 1){$mac = implode('', $mac_explode);}

$sql_a[0]	=	" `ssid` like '".$ssid."%' ";
$sql_a[1]	=	" `mac` like '".$mac."%' ";
$sql_a[2]	=	" `radio` like '".$radio."%' ";
$sql_a[3]	=	" `chan` like '".$chan."%' ";
$sql_a[4]	=	" `auth` like '".$auth."%' ";
$sql_a[5]	=	" `encry` like '".$encry."%' ";

echo '<table border="1" width="100%" cellspacing="0">'
.'<tr><td align="center" colspan="6"><a class="links" href="results.php?ord='.$ord.'&sort='.$sort.'&from='.$from.'&to='.$inc.'&ssid='.$ssid.'&mac='.$mac.'&radio='.$radio.'&chan='.$chan.'&auth='.$auth.'&encry='.$encry.'">Save this search</a></td></tr>'
.'<tr class="style4"><th>SSID</th>'
.'<th>MAC</th>'
.'<th>Chan</th>'
.'<th>Radio Type</th>'
.'<th>Authentication</th>'
.'<th>Encryption</th></tr>';


if ($from==""){$from=0;}
if ($inc==""){$inc=100;}
if ($ord==""){$ord="ASC";}
if ($sort==""){$sort="id";}
$x=0;
$n=0;
$to=$from+$inc;

if(!$sql_a)
{
	echo '<tr><td colspan="6" align="center">There where no results, please try again</td></tr></table>'; 
	$filename = $_SERVER['SCRIPT_FILENAME'];
	footer($filename);
	die();
}
mysql_select_db($db,$conn);
$sql0 = "SELECT * FROM $wtable WHERE " . implode(' AND ', $sql_a) ." ORDER BY $sort $ord";
$result = mysql_query($sql0, $conn) or die(mysql_error());
$total_rows = mysql_num_rows($result);
if($total_rows === 0)
{
	echo '<tr><td colspan="6" align="center">There where no results, please try again</td></tr></table>'; 
	$filename = $_SERVER['SCRIPT_FILENAME'];
	footer($filename);
	die();
}

while ($newArray = mysql_fetch_array($result))
{
    $id = $newArray['id'];
	$ssid = $newArray['ssid'];
    $mac = $newArray['mac'];
    $chan = $newArray['chan'];
	$radio = $newArray['radio'];
	$auth = $newArray['auth'];
	$encry = $newArray['encry'];
    echo '<tr><td><a class="links" href="fetch.php?id='.$id.'">'.$ssid.'</a></td>';
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
footer($filename);
?>