<?php
global $screen_output;
$screen_output = "CLI";

include('../lib/config.inc.php');
include('../lib/database.inc.php');
$ver = "1.0.2";

$nf_array	= array();
$sig_sort	= array();
$sig_id		= array();
$list		= '';
$N 			= 0;

$list	=	addslashes(strip_tags($_GET['ActiveBSSIDs']));
if($_GET['ActiveBSSIDs'] == '')
{
	echo "Try feeding me some good bits.";
	die();
}
$listing = explode("-", $list);
$pre_sig = '';
foreach($listing as $key=>$macandsig)
{
	$mac_sig_array = explode("|",$macandsig);
	$sig = $mac_sig_array[1];
	$mac = str_replace(":" , "" , $mac_sig_array[0]);
	$result = mysql_query("SELECT * FROM `$db`.`$wtable` WHERE `mac` LIKE '$mac' LIMIT 1", $conn) or die(mysql_error($conn));
	$array = mysql_fetch_array($result);
	if($array['mac'] == '')
	{
		$nf_array[] = $mac;
		$notfound = 1;
		continue;
	}
	$ssidss = smart_quotes($array['ssid']);
	$ssidsss = str_split($ssidss,25); //split SSID in two at is 25th char.
	$ssid_S = $ssidsss[0]; //Use the 25 char long word for the APs table name, this is due to a limitation in MySQL table name lengths, 
						  //the rest of the info will suffice for unique table names

	$table = $ssid_S.$sep.$array['mac'].$sep.$array['sectype'].$sep.$array['radio'].$sep.$array['chan'];
	$table_gps = $ssid_S.$sep.$array['mac'].$sep.$array['sectype'].$sep.$array['radio'].$sep.$array['chan'].$gps_ext;

	$pre_sat	= '';
	$pre_lat	= '';
	$pre_long	= '';
	$pre_date	= '';
	
	$result_rows = mysql_query("select * from `$db_st`.`$table_gps`",$conn);
	$total_rows = mysql_num_rows($result_rows) or die(mysql_error($conn));

	if($total_rows < 2)
	{
		$sql1 ="select * from `$db_st`.`$table_gps`";
		$testing = "1";
	}else
	{
		$sql1 = "select * from `$db_st`.`$table_gps` ORDER BY `date` DESC";
		$testing = "2";
	}
	$result1 = mysql_query($sql1,$conn);
	if(!$result1){mysql_error($conn); continue;}
	while($array1 = mysql_fetch_array($result1))
	{
		if($array1['sats'] == 0 or $array1['sats'] <= $pre_sats){continue;}
		
		$lat_exp = explode(" ",$array1['lat']);
		$lat = $lat_exp[1];
		if($lat == "0.0000"){continue;}
		
		$long_exp = explode(" ",$array1['long']);
		$long = $long_exp[1];
		if($long == "0.0000"){continue;}
		
		if($array1['sats'] >= $pre_sat)
		{
			$use[$N] = array(
							'lat'	=> $array1['lat'],
							'long'	=> $array1['long'],
							'date'	=> $array1['date'],
							'time'	=> $array1['time'],
							'sats'	=> $array1['sats']
						);
			$sig_sort[$N] = $sig;
			$sig_id[$N]	= $N;
			$N++;
			break;
		}
		$pre_sats	= $array1['sats'];
		$pre_lat	= $array1['lat'];
		$pre_long	= $array1['long'];
		$pre_date	= $array1['date'];
		$pre_time	= $array1['time'];
	}
}

array_multisort($sig_sort, $sig_id);
$count_sig = count($sig_sort);
$array_id = $count_sig-1;

if($array_id != -1)
{
	echo $use[$array_id]['lat']."|".$use[$array_id]['long']."|".$use[$array_id]['sats']."|".$use[$array_id]['date']."|".$use[$array_id]['time'];
}

if($notfound == 1)
{
	echo "\r\n+Import some aps";
}
?>