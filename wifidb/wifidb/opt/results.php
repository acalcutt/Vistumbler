<?php
include('../lib/database.inc.php');
include('../lib/config.inc.php');
pageheader("Search results Page");
?></td>
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

if ($_POST['ssid']	!== '')	{ $sql_a[]	=	" `ssid` = '".$_POST['ssid']."' ";}
if ($mac_post		!== '')	{ $sql_a[]	=	" `mac` = '".$mac_post."' ";}
if ($_POST['radio']	!== '')	{ $sql_a[]	=	" `radio` = '".$_POST['radio']."' ";}
if ($_POST['chan']	!== '')	{ $sql_a[]	=	" `chan` = '".$_POST['chan']."' ";}
if ($_POST['auth']	!== '')	{ $sql_a[]	=	" `auth` = '".$_POST['auth']."' ";}
if ($_POST['encry']	!== '')	{ $sql_a[]	=	" `encry` = '".$_POST['encry']."' ";}

echo '<table border="1" width="100%" cellspacing="0">'
.'<tr class="style4"><th>SSID</th>'
.'<th>MAC</th>'
.'<th>Chan</th>'
.'<th>Radio Type</th>'
.'<th>Authentication</th>'
.'<th>Encryption</th></tr>';

$ord   =	$_GET['ord'];
strip_tags($ord);
$sort  =	$_GET['sort'];
strip_tags($sort);
$from  =	$_GET['from'];
strip_tags($from);
$from_ =	$_GET['from'];
strip_tags($from_);
$inc   =	$_GET['to'];
strip_tags($inc);
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