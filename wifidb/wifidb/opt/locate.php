<?php
global $screen_output;
$screen_output = "CLI";

include('../lib/config.inc.php');
include('../lib/database.inc.php');
$ver = "1.0.3";

$nf_array	= array();
$sig_sort	= array();
$sig_id		= array();
$list		= '';

$list	=	@filter_input(INPUT_GET, 'ActiveBSSIDs', FILTER_SANITIZE_SPECIAL_CHARS);
if($list == ''){ die("Try feeding me some good bits."); }

$listing = explode("-", $list);
foreach($listing as $key=>$item){$t = explode("|", $item);$listing[$key] = array($t[1],$t[0]);}
$listing = subval_sort($listing,1);

$pre_sig = '';
$notfound = 1;
foreach($listing as $key=>$macandsig)
{
	$sig = $macandsig[0];
	$mac = str_replace(":" , "" , $macandsig[1]);
	$SQL = "SELECT * FROM `$db`.`$wtable` WHERE `mac` LIKE '$mac' LIMIT 1";
	$result = mysql_query($SQL, $conn) or die(mysql_error($conn));
	$array = mysql_fetch_array($result);
	if($array['mac'] == ''){continue;}
	
	$notfound = 0;
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
	
	$sql1 = "select * from `$db_st`.`$table_gps` WHERE `lat` NOT LIKE 'N 0.0000' ORDER BY date,sats DESC LIMIT 1";
	$result = mysql_query($sql1,$conn);
	#if(!$result){mysql_error($conn); continue;}
	
	$array1 = mysql_fetch_array($result);
	var_dump($array1);
	
	if($array1['long'] == "E 0.0000"){continue;}
	
	if($array1['sats'] >= $pre_sat)
	{
		$use = array(
						'lat'	=> $array1['lat'],
						'long'	=> $array1['long'],
						'date'	=> $array1['date'],
						'time'	=> $array1['time'],
						'sats'	=> $array1['sats']
					);
		break;
	}
	$pre_sat	= $array1['sats'];
	$pre_lat	= $array1['lat'];
	$pre_long	= $array1['long'];
	$pre_date	= $array1['date'];
	$pre_time	= $array1['time'];
}

if(!@count($use))
{
	echo "\r\n+Import some aps";
}else{
	echo $use['lat']."|".$use['long']."|".$use['sats']."|".$use['date']."|".$use['time'];
}


function subval_sort($a,$subkey)
{
	foreach($a as $k=>$v)
	{
		$b[$k] = strtolower($v[$subkey]);
	}
	asort($b);
	foreach($b as $key=>$val)
	{
		$c[] = $a[$key];
	}
	return $c;
}
?>