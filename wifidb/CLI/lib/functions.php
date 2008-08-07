<?php
$lastedit="8.6.2008";
$start="6.21.2008";
$ver=array("Txt2VS1"=>"1.0", "chkgps"=>"1.0");


function check_gps_array($gpsarray, $test)
{
$debug = 0;
foreach($gpsarray as $gps)
{
	$gps_t =  $gps["date"]. "-".$gps["time"]. "-".$gps["lat"]. "-".$gps["long"];
	$test_t = $test["date"]."-".$test["time"]."-".$test["lat"]."-".$test["long"]; 
	if ( $gps_t == $test_t )
	{
		if ($debug == 1 ) {
			echo  "  Array data: ".$gps_t."\n";
			echo  "Testing data: ".$test_t."\n.-.-.-.-.=.-.-.-.-.\n";
			echo "-----=-----=-----\n|\n|\n"; 
		}
		return 1;
		break;
	}else
	{
		if ($debug == 1){
			echo  "  Array data: ".$gps_t."\n";
			echo  "Testing data: ".$test_t."\n----\n";
			echo "-----=-----\n";
		}
		$return = 0;
	}
}
return $return;
}


function convert_vs1($source, $out)
{
// dfine time that the script started
$start = date("H:i:s");
$debug = 0;

// counters
$c=0;
$cc=0;
$n=0;
$nn=0;
$N=0;
$complete=0;

//Access point Data Array (GPS is not defined here, because of a bug when it was.)
$apdata=array();

// create file name of VS1 file from the name of the Txt file, 
$src=explode("\\",$source);
$f_max = count($src);
$file_src = explode(".",$src[$f_max-1]);
$file_ext = $file_src[0].'.vs1';
$filename = ('C:\\imp\\text\\vs1\\'.$file_ext);
	if($debug == 1 ){echo $file_ext."\n".$filename."\n";}

// define initial write and appends
$filewrite = fopen($filename, "w");
$fileappend = fopen($filename, "a");

//Break out file into an Array
$return = file($source);

//create interval for progress
$line = count($return);
$stat_c = $line/100;
if ($debug ==1){echo $stat_c."\n";}
if ($debug ==1){echo $line."\n";}

// Start the main loop
foreach($return as $ret)
{
	$c++;
	$cc++;
	if ($ret[0] == "#"){continue;}
	$wifi = explode("|",$ret);
	$ret_count = count($wifi);
if ($ret_count == 17)// test to see if the data is in correct format
{	
	if ($cc == $stat_c)
	{
		$cc=0;
		$complete++;
		echo $complete."% - ";
	}
	
	if ($debug ==1)
	{
		echo $total."\n";
	}
	//format date and time
	$datetime=explode(" ",$wifi[13]);
	$date=$datetime[0];
	$time=$datetime[1];
	
	if ($debug ==1)
	{echo $nn."\n";}
	
	// This is a temp array of data to be tested against the GPS array
	$gpsdata_t[0]=array(
						"lat"=>$wifi[8],
						"long"=>$wifi[9],
						"sats"=>"0",
						"date"=>$date,
						"time"=>$time
						);
	// Create the Security Type number for the respective Access point
	if ($wifi[4]=="Open"&&$wifi[5]=="None"){$sectype="1";}
	if ($wifi[4]=="Open"&&$wifi[5]=="WEP"){$sectype="2";}
	if ($wifi[4]=="WPA-Personal"){$sectype="3";}

	if ($debug == 1 )
	{
		echo "\n\n+-+-+-+-+-+-\n".$gpsdata_t[0]["lat"]."+-\n".$gpsdata_t[0]["long"]."+-\n".$gpsdata_t[0]["sats"]."+-\n".$gpsdata_t[0]["date"]."+-\n".$gpsdata_t[0]["time"]."+-\n";	
	}
	
	if (is_null($gpsdata))
	{
		$n++;
		$N++;
		if ($debug ==1)
		{echo "\$n = ".$n."\n\$N = ".$N."\n";}
		$sig=$n.",".$wifi[3];
		$gpsdata[$n]=array(
							"lat"=>$wifi[8],
							"long"=>$wifi[9],
							"sats"=>$wifi[3],
							"date"=>$date,
							"time"=>$time
						);
							
		$apdata[$N]=array(
							"ssid"=>$wifi[0],
							"mac"=>$wifi[1],
							"man"=>$wifi[2],
							"auth"=>$wifi[4],
							"encry"=>$wifi[5],
							"sectype"=>$sectype,
							"radio"=>$wifi[6],
							"chan"=>$wifi[7],
							"btx"=>$wifi[10],
							"otx"=>$wifi[11],
							"nt"=>$wifi[14],
							"label"=>$wifi[15],
							"sig"=>$sig
						);
		if ($debug == 1 )
		{
			echo "\n\n+_+_+_+_+_+_\n".$gpsdata[$n]["lat"]."+_\n".$gpsdata[$n]["long"]."+_\n".$gpsdata[$n]["sats"]."+_\n".$gpsdata[$n]["date"]."+_\n".$gpsdata[$n]["time"]."+_\n";	
			echo "Access Point Number: ".$N."\n";
			echo "=-=-=-=-=-=-\n".$apdata[$N]["ssid"]."=-\n".$apdata[$N]["mac"]."=-\n".$apdata[$N]["auth"]."=-\n".$apdata[$N]["encry"]."=-\n".$apdata[$N]["sectype"]."=-\n".$apdata[$N]["radio"]."=-\n".$apdata[$N]["chan"]."=-\n".$apdata[$N]["btx"]."=-\n".$apdata[$N]["otx"]."=-\n".$apdata[$N]["nt"]."=-\n".$apdata[$N]["label"]."=-\n".$apdata[$N]["sig"]."\n";
		}
	}
	else
	{
		$gpschk = check_gps_array($gpsdata,$gpsdata_t[$nn]);
		if ($gpschk===0)
		{
			if ($debug ==1)
			{echo "\$n = ".$n."\n\$N = ".$N."\n";}
			$n++;
			$N++;
			$sig=$n.",".$wifi[3];
			$gpsdata[$n]=array(
								"lat"=>$wifi[8],
								"long"=>$wifi[9],
								"sats"=>"0",
								"date"=>$date,
								"time"=>$time
							);

			$apdata[$N]=array(
								"ssid"=>$wifi[0],
								"mac"=>$wifi[1],
								"man"=>$wifi[2],
								"auth"=>$wifi[4],
								"encry"=>$wifi[5],
								"sectype"=>$sectype,
								"radio"=>$wifi[6],
								"chan"=>$wifi[7],
								"btx"=>$wifi[10],
								"otx"=>$wifi[11],
								"nt"=>$wifi[14],
								"label"=>$wifi[15],
								"sig"=>$sig
							);
			if ($debug == 1 )
			{
				echo "\n\n+_+_+_+_+_+_\n".$gpsdata[$n]["lat"]."+_\n".$gpsdata[$n]["long"]."+_\n".$gpsdata[$n]["sats"]."+_\n".$gpsdata[$n]["date"]."+_\n".$gpsdata[$n]["time"]."+_\n";	
				echo "Access Point Number: ".$N."\n";
				echo "=-=-=-=-=-=-\n".$apdata[$N]["ssid"]."=-\n".$apdata[$N]["mac"]."=-\n".$apdata[$N]["auth"]."=-\n".$apdata[$N]["encry"]."=-\n".$apdata[$N]["sectype"]."=-\n".$apdata[$N]["radio"]."=-\n".$apdata[$N]["chan"]."=-\n".$apdata[$N]["btx"]."=-\n".$apdata[$N]["otx"]."=-\n".$apdata[$N]["nt"]."=-\n".$apdata[$N]["label"]."=-\n".$apdata[$N]["sig"]."\n";
			}
		}elseif($gpschk===1)
		{
			if ($debug ==1)
			{echo "\$n = ".$n."\n\$N = ".$N."\n";}
			$N++;
			$sig=$n.",".$wifi[3];
			if ($debug ==1 ){echo "\nduplicate GPS data, not entered into array\n";}
			$apdata[$N]=array("ssid"=>$wifi[0],
							"mac"=>$wifi[1],
							"man"=>$wifi[2],
							"auth"=>$wifi[4],
							"encry"=>$wifi[5],
							"sectype"=>$sectype,
							"radio"=>$wifi[6],
							"chan"=>$wifi[7],
							"btx"=>$wifi[10],
							"otx"=>$wifi[11],
							"nt"=>$wifi[14],
							"label"=>$wifi[15],
							"sig"=>$sig);
			if ($debug == 1 )
			{
				echo "Access Point Number: ".$N."\n";
				echo "=-=-=-=-=-=-\n".$apdata[$N]["ssid"]."=-\n".$apdata[$N]["mac"]."=-\n".$apdata[$N]["auth"]."=-\n".$apdata[$N]["encry"]."=-\n".$apdata[$N]["sectype"]."=-\n".$apdata[$N]["radio"]."=-\n".$apdata[$N]["chan"]."=-\n".$apdata[$N]["btx"]."=-\n".$apdata[$N]["otx"]."=-\n".$apdata[$N]["nt"]."=-\n".$apdata[$N]["label"]."=-\n".$apdata[$N]["sig"]."\n";
			}

		}
	}
}else{echo "\nLine: ".$c." - Wrong data type, dropping row\n";}
unset($gpsdata_t[0]);
}
if ($out == "file" or $out == "File" or $out=="FILE")
{
	$n = 1;
	# Dump GPS data to VS1 File
	$h1 = "# Vistumbler VS1 - Detailed Export Version 1.0\r\n# Created By: RanInt WiFi DB Alpha \r\n# -------------------------------------------------\r\n# GpsID|Latitude|Longitude|NumOfSatalites|Date|Time\r\n# -------------------------------------------------\r\n";
	fwrite($fileappend, $h1);
	foreach( $gpsdata as $gps )
	{
		$latitude = explode(" ", $gps["lat"]);
		$lat_front = explode(".", $latitude[1]);
		$lat_back = ".".$lat_front[1];
		$lat_back = $lat_back*10;
		$lat_back = $lat_back*60;
		
		$longitude = explode(" ", $gps["long"]);
		$long_front = explode(".",$longitude[1]);
		$long_back = '.'.$long_front[1];
		$long_back = $long_back*10;
		$long_back = $long_back*60;
		
		$lat_ = $lat_front[0].$lat_back;
		$long_ =  $long_front[0].$long_back;
		if($latitude[0] == "S")
		{$la = "-";}
		if($longitude[0]=="W")
		{$lo = "-";}
		if($lat_=="00"){$lat="0.0000";}else{
		$lat=$la.$lat_;}
		if($long_=="00"){$long="0.0000";}else{
		$long=$lo.$long_;}

		if ($debug ==1 ){echo "Lat : ".$lat." - Long : ".$long."\n";}
		
		$gpsd = $n."|".$lat."|".$long."|".$gps["sats"]."|".$gps["date"]."|".$gps["time"]."\r\n";
		if($debug == 1){ echo $gpsd;}
		fwrite($fileappend, $gpsd);
		$n++;
	}
	$n=1;
	
	$ap_head = "# ---------------------------------------------------------------------------------------------------------------------------------------------------------\r\n# SSID|BSSID|MANUFACTURER|Authetication|Encryption|Security Type|Radio Type|Channel|Basic Transfer Rates|Other Transfer Rates|Network Type|Label|GpsID,SIGNAL\r\n# ---------------------------------------------------------------------------------------------------------------------------------------------------------\r\n";
	foreach($apdata as $ap)
	{
		$apd = $ap["ssid"]."|".$ap["mac"]."|".$ap["man"]."|".$ap["auth"]."|".$ap["encry"]."|".$ap["sectype"]."|".$ap["radio"]."|".$ap["chan"]."|".$ap["btx"]."|".$ap["otx"]."|".$ap["nt"]."|".$ap["label"]."|".$ap["sig"]."\r\n";
		if($debug == 1){echo $apd;}
		fwrite($fileappend, $apd);
		$n++;

	}
	$end = date("H:i:s");
	$GPSS=count($gpsdata);
	$APS=count($apdata);
	echo "Total Number of Access Points : ".$APS."\nTotal Number of GPS Points : ".$GPSS."\n\n-------\nDONE!\n".$start."\n".$end."\n-------";
}
}