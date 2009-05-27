<?php
include('../lib/database.inc.php');
#pageheader("Search results Page");
include('../lib/config.inc.php');
$_GET['id']+=0;
if(is_int($_GET['id'])){$id = $_GET['id'];}else{$id = 0;}

$result = mysql_query("SELECT * FROM `$db`.`$wtable` WHERE `id` = '$id' LIMIT 1", $conn);
$newArray = mysql_fetch_array($result) or die(mysql_error($GLOBALS['conn']));

$APid = $newArray['id'];
$ssid_ptb_ = $newArray["ssid"];
$ssids_ptb = str_split($newArray['ssid'],25);
$ssid_ptb = smart_quotes($ssids_ptb[0]);
$mac_ptb=$newArray['mac'];
$radio_ptb=$newArray['radio'];
$sectype_ptb=$newArray['sectype'];
$auth_ptb=$newArray['auth'];
$encry_ptb=$newArray['encry'];
$chan_ptb=$newArray['chan'];

$table_ptb = $ssid_ptb.'-'.$mac_ptb.'-'.$sectype_ptb.'-'.$radio_ptb.'-'.$chan_ptb;
echo "	- DB Id => ".$APid." || DB SSID => ".$ssid_ptb." (".$ssid_ptb_.")<br> ";
echo "	- DB Mac => ".$mac_ptb." || DB Radio => ".$radio_ptb."<br>";
echo "	- DB Auth => ".$sectype_ptb." || DB Encry => ".$auth_ptb." ".$encry_ptb."<br>";
echo "	- DB Chan => ".$chan_ptb."<br>";
echo $table_ptb."<br>";

echo "#====Signal Table for : $table_ptb  ====#<table border=\"1\"><tr><td>Row ID</td><td>Signal</td></tr>";
$sql = "SELECT * FROM `wifi_st`.`$table_ptb`";
$result = mysql_query($sql, $conn) or die(mysql_error($GLOBALS['conn']));
while($newArray = mysql_fetch_array($result))
{
echo "<tr><td>".$newArray['id']."</td>";
echo "<td>".$newArray['sig']."</td></tr>";
}
echo "</table>";




?>