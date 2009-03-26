<?php
$stime = time();
include('../../lib/config.inc.php');
include('../../lib/database.inc.php');
echo '<title>Wireless DataBase *Alpha*'.$ver["wifidb"].' --> Fix Database Page</title>';
?>
<link rel="stylesheet" href="../../css/site4.0.css">
<body topmargin="10" leftmargin="0" rightmargin="0" bottommargin="10" marginwidth="10" marginheight="10">
<div align="center">
<table border="0" width="75%" cellspacing="10" cellpadding="2">
	<tr>
		<td bgcolor="#315573">
		<p align="center"><b><font size="5" face="Arial" color="#FFFFFF">
		<?php echo 'Wireless DataBase *Alpha* '.$ver["wifidb"].'</font>';?>
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

<td width="80%" bgcolor="#A9C6FA" valign="top" align="center">
<!--BODY-->
<table border="1"><tr class=\"style4\"><th>Status</th><th>Step of Install</th></tr>
<?php
echo '<tr><TH class=\"style4\" colspan="2">Fix Erroneous Data in '.$ver['wifidb'].'</TH><tr>';

$pointers	= array();

$post_user 	=	$_POST['root_sql_user'];
$post_pwd 	=	$_POST['root_sql_pwd'];

$post_wdb_user 	=	$_POST['wdb_sql_user'];
$post_wdb_pwd 	=	$_POST['wdb_sql_pwd'];

if(isset($_POST['replace'])){$replace 	=	$_POST['replace'];}else{$replace =0;}
if(isset($_POST['deleteap'])){$deleteap 	=	$_POST['deleteap'];}else{$deleteap =0;}

if($post_wdb_user !== $db_user && $post_wdb_pwd !== $db_pwd)
{die("You did not enter the correct Username/Password");}

$conn 	=	mysql_pconnect($host, $post_user, $post_pwd) or die("Unable to connect to SQL server: ".$host);
mysql_select_db($db,$conn);

$sql0 = "SELECT * FROM `$wtable`";
$result = mysql_query($sql0, $conn);
while ($newrray = mysql_fetch_array($result))
{
	$pointers[] = array(
					"id" 		=> $newrray['id'],
					"ssid"	 	=> $newrray['ssid'],
					"mac" 		=> $newrray['mac'],
					"chan"	 	=> $newrray['chan'],
					"auth"		=> $newrray['auth'],
					"encry"		=> $newrray['encry'],
					"radio"		=> $newrray['radio'],
					"sectype" 	=> $newrray['sectype']
					);
}

echo '<tr class=\"style4\"><TH colspan="2">Finished Building Array of All Access Points</th></tr>';
foreach($pointers as $ap)
{
	$AP__ID		=	$ap['id'];
	$apssid		=	$ap['ssid'];
	$apmac		=	$ap['mac'];
	$apsec		=	$ap['sectype'];
	$apauth		=	$ap['auth'];
	$apencry	=	$ap['encry'];
	$apchan		=	$ap['chan'];
	$apradio	=	$ap['radio'];
	$table = $apssid.'-'.$apmac.'-'.$apsec.'-'.$apradio.'-'.$apchan;
	$table_gps = $table.$gps_ext;
	
	echo '<tr><td>Checking AP:'.$table.'</td><td>';
	
	mysql_select_db($db_st,$conn);
	
	$resultc = mysql_query("SELECT * FROM `$table_gps`", $conn);

	while ($newArray = mysql_fetch_array($resultc))
	{
		if($newArray['lat'] == '' && $newArray['long'] == '')
		{
			$gpspoints[] = array(
								"id"	=>	$newArray["id"],
								"lat"	=>	$newArray['lat'],
								"long"	=>	$newArray['long'],
								"sats"	=>	$newArray['sats'],
								"date"	=>	$newArray['date'],
								"time"	=>	$newArray['time']
								);
		}
	}

	if(isset($gpspoints)){$gpsfound = count($gpspoints);}else{$gpsfound =0;}
	if($gpsfound != 0)
	{
		echo "Found some bad GPS Points<br>";
		foreach($gpspoints as $gpspoint)
		{
			if($replace=="on")
			{
				$gps_replaced_array = array(
											'id'		=>	$AP__ID,
											'ssid'		=>  $apssid,
											'mac'		=>	$apmac,
											'sectype'	=>	$apsec,
											'auth'		=>	$apauth,
											'encry'		=>	$apencry,
											'radio'		=>	$apradio,
											'chan'		=>	$apchan
											);
				mysql_select_db($db_st,$conn);
				$gpsid = $gpspoint['id'];
				
				$lat = "N 0.0000";
				$long = "E 0.0000";
				$sats = "0";
				if($gpspoint['date']==''){$date = "1971-01-01";}else{$date = $gpspoint['date'];}
				if($gpspoint['time']==''){$time = "00:00:00";}else{$time=$gpspoint['time'];}
				
				$update_gps1 = "DELETE FROM `$table_gps` WHERE `id` = '$gpsid'";
				$update_result1 = mysql_query($update_gps1, $conn);
				if(!$update_result1)
				{echo mysql_error($conn);}
				$update_gps2 = "INSERT INTO `$table_gps` ( `id` , `lat` , `long` , `sats` , `date` , `time` ) VALUES ( '$gpsid', '$lat', '$long', '$sats', '$date', '$time')";
				$update_result2 = mysql_query($update_gps2, $conn);
				if($update_result1)
				{
					echo "<BR>GPS Point rapaired<br>";
				}else{echo mysql_error($conn);}
			}elseif($deleteap=="on")
			{
				$AP_removed_array[] = array(
											'ssid'		=>  $apssid,
											'mac'		=>	$apmac,
											'sectype'	=>	$apsec,
											'auth'		=>	$apauth,
											'encry'		=>	$apencry,
											'radio'		=>	$apradio,
											'chan'		=>	$apchan
											);
				mysql_select_db($db,$conn);
				$remove_pointer = "DELETE FROM `$wtable` WHERE `id`='$APID'";
				$remove_pointer_result = mysql_query($remove_pointer, $conn);
				if($remove_pointer_result)
				{
					echo "Access Point, Pointer removed<br>";
				}else{echo mysql_error($conn);}
				mysql_select_db($db_st,$conn);
				$remove_AP = "DROP TABLE `$table`";
				$remove_AP_result = mysql_query($remove_AP, $conn);
				if($remove_AP_result)
				{
					echo "Access Point removed<br>";
				}else{echo mysql_error($conn);}
				$remove_gps = "DROP TABLE `$table_gps`";
				$remove_gps_result = mysql_query($remove_gps, $conn);
				if($remove_gps_result)
				{
					echo "Access Point, GPS Points removed<br>";
				}else{echo mysql_error($conn);}					
				break;
			}elseif($deleteap=="on" and $replace == "on")
			{
				echo '<h1><font color="red">You cannot repair the GPS and remove an AP at the same time,<br> choose one or the other.</font></h1>';
			}
		}
	}else
	{
		Echo "AP is Clean.";
	}
	echo "</td></tr>";
	if (isset($gpspoints))
	{
		foreach ($gpspoints as $i => $value)
		{
			unset($gpspoints[$i]);
		}
		$gpspoints = array_values($gpspoints);
	}
}
echo "</table>";
$etime = time();
$total_run = $etime - $stime;
echo "<h2>Total run time: ".$total_run."<br>";
echo "<h2>Now you can remove the /install/patch_blank_gps folder from the WiFiDB install root</h2>";

$filename = $_SERVER['SCRIPT_FILENAME'];
footer($filename);
?>