<?php
$start = date("Y-m-d G:i:s");
error_reporting(E_ALL|E_STRICT);
ini_set("memory_limit","3072M"); //lots of GPS cords need lots of memory
global $screen_output, $dim, $COLORS, $daemon_ver;
$screen_output = "CLI";

if(!(@require_once 'daemon/config.inc.php')){die("You need to create and configure your config.inc.php file in the [tools dir]/daemon/config.inc.php");}
if($GLOBALS['wifidb_install'] == ""){die("You need to edit your daemon config file first in: [tools dir]/daemon/config.inc.php");}
require_once $GLOBALS['wifidb_install']."/lib/database.inc.php";
require_once $GLOBALS['wifidb_install']."/lib/config.inc.php";
$database = new database();
$lat_er=0;
$long_er=0;
$terr=0;
$rows=0;
$sqls = "SELECT * FROM `$db`.`$wtable`";
$result = mysql_query($sqls, $conn) or die(mysql_error($conn));
while($newArray = mysql_fetch_array($result))
{
	$TB_ID = $newArray['id'];
	$macaddress = $newArray['mac'];
	$radio = $newArray['radio'];
	if($radio == "a")
		{$radio = "802.11a";}
	elseif($radio == "b")
		{$radio = "802.11b";}
	elseif($radio == "g")
		{$radio = "802.11g";}
	elseif($radio == "n")
		{$radio = "802.11n";}
	else
		{$radio = "802.11u";}

	list($ssid_ptb) = make_ssid($newArray["ssid"]);
	
	$table_gps	=	$ssid_ptb.'-'.$newArray["mac"].'-'.$newArray["sectype"].'-'.$newArray["radio"].'-'.$newArray['chan'].$gps_ext;
	echo "[ $TB_ID ]TABLE: ".$table_gps."\n";
	$result1 = mysql_query("SELECT * FROM `$db_st`.`$table_gps`", $conn);
	if(!$result1){$table_error[$terr++] =  array( $TB_ID, $table_gps);}
#	$rows = mysql_num_rows($result1);
	while ($field = mysql_fetch_array($result1)) 
	{
		$id = $field['id'];
		$lat = $field['lat'];
		$long = $field['long'];
		$lat_exp = explode(".", $lat);
		$long_exp = explode(".", $long);
		$long_c = count($long_exp);
		$lat_c = count($lat_exp);
		if($lat == 'N 0.0000' or $long == 'E 0.0000' or $lat == 'N 0.0000000' or $long == 'E 0.0000000')	{continue;}
		if($lat == '' or $long == '' or $lat == '000' or $long == '000')
		{
		#	echo "#########\n\t######\t# LAT: ".$lat."#########\n";
			$up_lat = "UPDATE `$db_st`.`$table_gps` SET `lat` =  'N 0.0000', `long` = 'E 0.0000' WHERE `id` = '$id' LIMIT 1";
			#	UPDATE `wifi_st`.`lu4staff-000000000000-3-U-0_GPS` SET `lat` = 'N 4928.2661', `long` = 'E 826.6060' WHERE `lu4staff-000000000000-3-U-0_GPS`.`id` =1 LIMIT 1 ;
		#	echo $up_lat."\n";
			if(mysql_query($up_lat, $conn))
			{echo "Updated Latitude.\n";}
			else{echo "Error Updating GPS. ".mysql_error($conn)."\n";}
			$lat_er++;
			continue;
		}
	#	echo "[ $TB_ID ]TABLE: ".$table_gps."\n\t LAT: $lat  ( $lat_c )\n\tLONG: $long  ( $long_c )\n";
		
		if($lat_c < 2)
		{
		#	echo "#########\nLAT: ".$lat_exp[0];
			$lat = str_replace("_", ".", $lat);
		#	echo "\nEDIT: ".$lat."#########\n";
			$lat_er++;
		}else
		{
			if($lat_exp[0] != '0')
			{
				$lat_len2 = smart($lat_exp[0]);
				$lat_len = strlen($lat_exp[1]);
				$lat_len2 = strlen($lat_len2);
				if($lat_len > 4 and $lat_len2 < 4)
				{
		#			echo $lat." - ";
					$lat	=	$database->convert_dd_dm($lat);
		#			echo $lat."\n";
				}
				
				if($lat_len2 > 5)
				{
					$neg = FALSE;
		#			echo $lat." - ";
					$lat_exp = explode(".", $lat);
					if($lat_exp[0][0] === "-" or $lat_exp[0][0] === "W" or $lat_exp[0][0] === "S"){$neg = TRUE;}
					
		#			echo substr($lat_exp[0], 0, 4)."\n";
		#			echo substr($lat_exp[0], -2).".".$lat_exp[1]."\n";
					
					$sub = substr($lat_exp[0], 0, 4);
					$calc = substr($lat_exp[0], -2).".".$lat_exp[1];
					$calc+0;
					$sub+0;
		#			echo $sub+($calc/60)."\n";
					$calc = substr(($calc/60),0,6);
					$calc+0;
					$lat = $sub+$calc;
					if($neg == TRUE){$lat = "S ".$lat;}else{$lat = "N ".$lat;}
				#	$lat	=	$database->convert_dm_dd($lat);
		#			echo $lat."\n";
				#	$up_long = "UPDATE `$db_st`.`$table_gps` SET `long` =  '$long' WHERE `id` = '$id' LIMIT 1";
				#	if(mysql_query($up_long, $conn))
				#	{echo "Updated Longitude.\n";}
				#	else{echo "Error Updating GPS. ".mysql_error($conn)."\n";}
				}
			}
		}
		if($long_c < 2)
		{
		#	echo "#########\nLONG: ".$long_exp[0];
			$long = str_replace("_", ".", $long);
		#	echo "\nEDIT: ".$long."#########\n";
			$long_er++;
		}else
		{
			if($long_exp[0] != '0')
			{
				$long_len2 = smart($long_exp[0]);
				$long_len = strlen($long_exp[1]);
				$long_len2 = strlen($long_len2);
				if($long_len > 4 and $long_len2 < 4 )
				{
		#			echo $long." - ";
					$long	=	$database->convert_dd_dm($long);
		#			echo $long."\n";
				}
				
				if($long_len2 > 5)
				{
					$neg = FALSE;
		#			echo $long." - ";
					$long_exp = explode(".", $long);
					if($long_exp[0][0] === "-" or $long_exp[0][0] === "W" or $long_exp[0][0] === "S"){$neg = TRUE;}
					
		#			echo substr($long_exp[0], 0, 4)."\n";
		#			echo substr($long_exp[0], -2).".".$long_exp[1]."\n";
					
					$sub = substr($long_exp[0], 0, 4);
					$calc = substr($long_exp[0], -2).".".$long_exp[1];
					$calc+0;
					$sub+0;
		#			echo $sub+($calc/60)."\n";
					$calc = substr(($calc/60),0,6);
					$calc+0;
					$long = $sub+$calc;
					if($neg == TRUE){$long= "W ".$long;}else{$long = "E ".$long;}
				#	$lat	=	$database->convert_dm_dd($lat);
		#			echo $long."\n";
				}
			}
		}
		
	#	echo $lat."\n";
	#	echo $lat[0]."\n";
		if($lat[0] == "-")
		{
			$lat = str_replace("-", "", $lat);
			$lat = "S ".$lat;
	#		echo $lat."\n";
		}elseif(!is_string($lat[0]))
		{
			$lat = "N ".$lat;
	#		echo $lat."\n";
		}
		
	#	echo $long."\n";
	#	echo $long[0]."\n";
		if($long[0] == "-")
		{
			$long = str_replace("-", "", $long);
			$long = "W ".$long;
	#		echo $long."\n";
		}elseif(!is_string($long[0]))
		{
			$long = "E ".$long;
	#		echo $long."\n";
		}
		$up_long = "UPDATE `$db_st`.`$table_gps` SET `long` =  '$long', `lat` = '$lat' WHERE `id` = '$id' LIMIT 1";
		if(mysql_query($up_long, $conn))
		{echo ".";}
		else{echo mysql_error($conn)."\n";}
		
		$rows++;
#		passthru('clear');
	}
	echo "\n";
}
$stop = date("Y-m-d G:i:s");
foreach($table_error as $error)
{
	echo "Table: ".$error[1]."  -  ID: ".$error[0]."\n";
}
echo "LAT ERRORS: ".$lat_er."\nLONG ERROR: ".$long_er."\nSTART: ".$start."\nSTOP: ".$stop."\nROWS: ".$rows;
?>