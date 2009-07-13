<?php
include('../lib/config.inc.php');
include('../lib/database.inc.php');
$list = $_GET['ActiveBSSIDs'];
$listing = explode("|", $list);
echo $listing[0]."<BR>";

$test = explode("-", $listing[0]);
$test1 = explode(":", $test[0]);

$count = count($test1);

if($count = 8)
{
	$pre_sig = '';
	foreach($listing as $macandsig)
	{
		$mac_sig_array = explode("-",$macandsig);
		$sig = $mac_sig_array[0];
		$mac = str_replace(":" , "" , $mac_sig_array[1]);
		echo $mac."<BR>";
		$result = mysql_query("SELECT * FROM `$db`.`$wtable` WHERE `mac` LIKE '$mac'", $conn) or die(mysql_error($conn));
		if(!$result){continue;}
		
		$array = mysql_fetch_array($result);

		$ssidss = smart_quotes($array['ssid']);
		$ssidsss = str_split($ssidss,25); //split SSID in two at is 25th char.
		$ssid_S = $ssidsss[0]; //Use the 25 char long word for the APs table name, this is due to a limitation in MySQL table name lengths, 
							  //the rest of the info will suffice for unique table names

		$table = $ssid_S.$sep.$array['mac'].$sep.$array['sectype'].$sep.$array['radio'].$sep.$array['chan'];
		$table_gps = $ssid_S.$sep.$array['mac'].$sep.$array['sectype'].$sep.$array['radio'].$sep.$array['chan'].$gps_ext;
		echo $table."<BR>".$table_gps."<BR>";
		$pre_sat	= '';
		$pre_lat	= '';
		$pre_long	= '';
		$pre_date	= '';
		
		$result1 = mysql_query("select * from `$db_st`.`$table_gps`",$conn);
		$total_rows = mysql_num_rows($result1) or die(mysql_error($conn));
		
		if($total_rows < 2)
		{
			$sql ="select * from `$db_st`.`$table_gps`";
			echo $sql."<BR>";
			$result2 = mysql_query($sql,$conn);
			$testing = "1";
		}else
		{
			$sql = "select * from `$db_st`.`$table_gps` ORDER BY `date` DESC";
			echo $sql."<BR>";
			$result2 = mysql_query($sql,$conn);
			$testing = "2";
		}
		echo $testing;
		if(!$result2){mysql_error($conn); continue;}
		while($array1 = mysql_fetch_array($result2))
		{
			if($array1['sat'] == 0){continue;}
			
			$lat_exp = explode(" ",$array1['lat']);
			$lat = $lat_exp[1];
			if($lat == "0.0000"){continue;}
			
			$long_exp = explode(" ",$array1['long']);
			$long = $long_exp[1];
			if($long == "0.0000"){continue;}
			
			if($array1['sat'] > $pre_sat)
			{
				$use_lat	= $array1['lat'];
				$use_long	= $array1['long'];
				$use_date	= $array1['date'];
				$use_time	= $array1['time'];
			}
			$pre_lat	= $array1['lat'];
			$pre_long	= $array1['long'];
			$pre_date	= $array1['date'];
			$pre_time	= $array1['time'];
		}
		$pre_sig = $sig;
		echo "<BR><BR>";
	}
	if(!isset($pre_sat))
	{
		echo "No APs Found, import some.";
	}
}else
{
	echo "Try feeding me some valid data and not that crap that you just tried.";
}


?>