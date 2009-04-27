<?php
$stime = time();
include('../../lib/config.inc.php');
include('../../lib/database.inc.php');
pageheader("Patch (Alter Dates) Page");
?>
</td>
	<td width="80%" bgcolor="#A9C6FA" valign="top" align="center">
		<p align="center">
<table border="1"><tr><th>Status</th><th>Step of Install</th></tr>
<?php
echo '<tr><TH colspan="2">Fix Erroneous Data in '.$ver['wifidb'].'</TH><tr>';
$id 	= array();
$ssid 	= array();
$mac 	= array();
$chan 	= array();
$radio 	= array();
$auth 	= array();
$encry 	= array();

$post_user 	=	$_POST['root_sql_user'];
$post_pwd 	=	$_POST['root_sql_pwd'];

$post_wdb_user 	=	$_POST['wdb_sql_user'];
$post_wdb_pwd 	=	$_POST['wdb_sql_pwd'];

$replace 	=	$_POST['replace'];
$deleteap 	=	$_POST['deleteap'];

if($post_wdb_user != $db_user && $post_wdb_pwd != $db_pwd)
{die("You did not enter the correct Username/Password");}

$conn 	=	mysql_pconnect($host, $post_user, $post_pwd) or die("Unable to connect to SQL server: $host");
$AP = array();
mysql_select_db($db,$conn);
$sql = "SELECT * FROM `$wtable`";
$result = mysql_query($sql, $conn) or die(mysql_error());
while ($newArray = mysql_fetch_array($result))
{
    $mac = $newArray['mac'];
	$mac_exp = str_split($mac,2);
	$mac = implode(":",$mac_exp);
	
    $AP[] = array(
					'id' => $newArray['id'],
					'ssid' => $newArray['ssid'],
					'mac'	=> $newArray['mac'],
				    'chan' => $newArray['chan'],
					'radio' => $newArray['radio'],
					'sectype' => $newArray['sectype']
				);
}
$count_aps = count($AP);
echo "<table>";
foreach($AP as $ap)
{
	mysql_select_db($db_st,$conn);
	$table_gps = $ap["ssid"].'-'.$ap["mac"].'-'.$ap["sectype"].'-'.$ap["radio"].'-'.$ap["chan"].$gps_ext;
	$sql_ = "SELECT * FROM `$table_gps` WHERE `time` = ''";
	$result_ = mysql_query($sql_, $conn) or die(mysql_error());
	while ($gpstable = mysql_fetch_array($result_))
	{
		echo "<td>";
		$date = explode("-", $gpstable['date']);
		$old_date = $date[0].'-'.$date[1].'-'.$date[2];
		$date_count = strlen($date[0]);
		$lat = $gpstable['lat'];
		$long = $gpstable['long'];
		$time = gpstable['time'];
		$sats = $gpstable['sats'];
		if($date_count == 2)
		{
			$new_date = $date[2].'-'.$date[0].'-'.$date[1];
			echo "Old Date: $old_date<br>";
			echo "New Date: $new_date<br>";
			$update = "UPDATE `$table_gps` SET `lat` = '$lat', `long` = '$long', `sats` = '$sats', `date`='$new_date', `time` = '$time'";
			$update_result = mysql_query($update, $conn) or die(mysql_error());
			if($update_result)
			{
				echo 'GPS Date updated for AP '.$ap["ssid"];
			}else
			{
				echo "Error updating GPS date for AP: ".$ap["ssid"];
			}
		}else
		{
			echo "GPS point for AP: ".$ap['ssid']." Does not need to be updated";
		}
		echo '</td></tr>';
	}
}
mysql_close($conn);
echo "</table>";
$etime = time();
$total_run = $etime - $stime;
echo "<h2>Total run time: ".$total_run."<br>";
echo "<h2>Now you can remove the /install folder from the WiFiDB install root</h2>";

$filename = $_SERVER['SCRIPT_FILENAME'];
footer($filename);
?>