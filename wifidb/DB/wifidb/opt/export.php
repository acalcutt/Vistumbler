<?php

function exp_kml_user($row)
{
	include('config.php');
	echo "Start of WiFi DB export to KML<BR>";
	echo "-------------------------------<BR><BR>";
	$open_loc = "http://www.vistumbler.net/images/program-images/open.png";
	$wep_loc = "http://www.vistumbler.net/images/program-images/secure-wep_dead.png";
	$wpa_loc = "http://www.vistumbler.net/images/program-images/secure_dead.png";

	$sql = "SELECT * FROM `users` WHERE `id`='$row'";
	$result = mysql_query($sql, $conn) or die(mysql_error());
	$user_array = mysql_fetch_array($result);
	$aps=explode("-",$user_array["points"]);
	$date=date('YmdHis');
	$file_ext = $$user_array["title"].'-'.$date.'.kml';
	$filename = ('..\out\kml\\'.$file_ext);
	// define initial write and appends
	$filewrite = fopen($filename, "w");
	$fileappend = fopen($filename, "a");
	// open file and write header:
	fwrite($fileappend, '<?xml version="1.0" encoding="UTF-8"?>\r\n<kml xmlns="http://earth.google.com/kml/2.2">\r\n<Document>\r\n<name>RanInt WifiDB KML</name>\r\n');
	fwrite($fileappend, '<Style id="openStyleDead">\r\n<IconStyle>\r\n<scale>0.5</scale>\r\n<Icon>\r\n<href>'.$open_loc.'</href>\r\n</Icon>\r\n</IconStyle>\r\n</Style>\r\n');
	fwrite($fileappend, '<Style id="wepStyleDead">\r\n<IconStyle>\r\n<scale>0.5</scale>\r\n<Icon>\r\n<href>'.$WEP_loc.'</href>\r\n</Icon>\r\n</IconStyle>\r\n</Style>\r\n');
	fwrite($fileappend, '<Style id="secureStyleDead">\r\n<IconStyle>\r\n<scale>0.5</scale>\r\n<Icon>\r\n<href>'.$WPA_loc.'</href>\r\n</Icon>\r\n</IconStyle>\r\n</Style>\r\n');

	$x=0;
	$n=0;

	fwrite( $fileappend, "<Folder>\r\n<name>Access Points</name>\r\n<description>APs:".$total."</description>\r\n");
	fwrite( $fileappend, "	<Folder>\r\n<name>".$title." Access Points</name>\r\n<description>APs:".$open_t."</description>\r\n");


	foreach($aps as $ap)
	{
		$ap_exp = explode("," , $ap);
		$apid = $ap_exp[1];
		$udflag = $ap_exp[0];
		mysql_select_db($db,$conn) or die("Unable to select Database:".$db);
		$sql0 = "SELECT * FROM $wtable WHERE encry='$apid'";
		$result = mysql_query($sql0, $conn) or die(mysql_error());
		while ($newArray = mysql_fetch_array($result))
		{
		    $id = $newArray['id'];
			$ssid = $newArray['ssid'];
		    $mac = $newArray['mac'];
		    $chan = $newArray['chan'];
			$radio = $newArray['radio'];
			$auth = $newArray['auth'];
			$encry = $newArray['encry'];
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
			$table=$ssid.'-'.$mac.'-'.$auth.'-'.$encry.'-'.$radio.'-'.$chan;
			mysql_select_db("$db_st") or die("Unable to select Database:".$db_st);

			$sql6 = "SELECT * FROM $table";
			$result6 = mysql_query($sql6, $conn) or die(mysql_error());
			$max = mysql_num_rows($result6);
			
			$sql = "SELECT * FROM `$table_gps` WHERE `id`='1'";
			$result = mysql_query($sql, $conn) or die(mysql_error());
			$gps_table_first = mysql_fetch_array($result);
			$date_first = $gps_table_first["date"];
			$time_first = $gps_table_first["time"];
			$fa = $date_first." ".$time_first;

			$sql = "SELECT * FROM `$table_gps` WHERE `id`='$max'";
			$result = mysql_query($sql, $conn) or die(mysql_error());
			$gps_table_last = mysql_fetch_array($result);
			$date_last = $gps_table_last["date"];
			$time_last = $gps_table_last["time"];
			$la = $date_last." ".$time_last;
			fwrite( $fileappend, "		<Placemark>\r\n<description><![CDATA[<b>SSID: </b>".$ssid."<br /><b>Mac Address: </b>".$mac."<br /><b>Network Type: </b>".$nt."<br /><b>Radio Type: </b>".$radio."<br /><b>Channel: </b>".$chan."<br /><b>Authentication: </b>".$auth."<br /><b>Encryption: </b>".$encry."<br /><b>Basic Transfer Rates: </b>".$btx."<br /><b>Other Transfer Rates: </b>".$otx."<br /><b>First Active: </b>".$fa."<br /><b>Last Updated: </b>".$la."<br /><b>Latitude: </b>".$lat."<br /><b>Longitude: </b>".$long."<br /><b>Manufacturer: </b>".$man."<br />]]></description>\r\n<styleUrl>#openStyleDead</styleUrl>\r\n<Point>\r\n<coordinates>".$lat.",".$long.",0</coordinates>\r\n</Point>\r\n</Placemark>\r\n");
		}
	}
	fwrite( $fileappend, "</Folder>\r\n");
	fwrite( $fileappend, "</Folder></Document></kml>");
	fclose( $fileappend );
}
?>