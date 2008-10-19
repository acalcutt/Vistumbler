<?php
$TOTAL_START=date("H:i:s");
#error_reporting(E_ALL);
$debug = 0;
$lastedit="9.22.2008";
$start="6.21.2008";
$ver="1.1";
echo "=-=-=-=-=-=-=-=-=-=-==-=-=-=-=-=-Vistumbler Summery Text to VS1 converter Version: ".$ver."=-=-=-=-=-=-=-=-=-=-==-=-=-=-=-=-\n";

$vs1dir = getcwd();
$vs1dir.="\\vs1\\";
$textdir = getcwd();
$textdir .="\\text\\";


if (file_exists($vs1dir)===FALSE){if(mkdir($vs1dir)){echo "made VS1 folder for the converted VS1 Files\n";}}
if (file_exists($textdir)===FALSE){echo "You need to put some files in a folder named 'text' first.\nPlease do this first then run this again.\nDir:".$vs1dir; mkdir($vs1dir);}
// self aware of Script location and where to search for Txt files


echo "Directory: ".$textdir."\n\n";
echo "Files to Convert: \n";

$file_a = array();
$n=0;
$dh = opendir($textdir) or die("couldn't open directory");
while (!(($file = readdir($dh)) == false))
{
	if ((is_file("$textdir/$file"))) 
	{
		if($file == '.'){continue;}
		if($file == '..'){continue;}
		$file_e = explode('.',$file);
		$file_max = count($file_e);
		if ($file_e[$file_max-1]=='txt' or $file_e[$file_max-1]=="TXT")
		{
			$file_a[$n] = $file;
			echo $n." ".$file."\n";
			$n++;
		}else{
			echo "file not supported !\n";
		}
	}
}
echo "\n\n";
closedir($dh);
foreach($file_a as $file)
{
	$source = $textdir.$file;
	echo '################=== Start conversion of '.$source.' ===################';
	echo "\n";
	convert_vs1($source, "file");
//	function ( Source file , output destination type [ file only at the moment MySQL support soon ] )
}

$TOTAL_END = date("H:i:s");
echo "\nTOTAL Running time::\n\nStart: ".$TOTAL_START."\nStop : ".$TOTAL_END."\n";



function &check_gps_array($gpsarray, $test)
{
foreach($gpsarray as $gps)
{
	$gps_t =  $gps["date"].$gps["time"].$gps["lat"].$gps["long"];
	$test_t = $test["date"].$test["time"].$test["lat"].$test["long"];
#	echo $gps_t."\n".$test_t."\n";
	if (strcmp($gps_t, $test_t)==0)
	{
		// Duplicate GPS
		if ($GLOBALS["debug"] == TRUE ) {
			echo  "  Array data: ".$gps_t."\n";
			echo  "Testing data: ".$test_t."\n.-.-.-.-.=.-.-.-.-.\n";
			echo "-----=-----=-----\n|\n|\n"; 
		}
		$return = 1;
		return $return;
	}else
	{
		// unique GPS
		if ($GLOBALS["debug"] == TRUE ){
			echo  "  Array data: ".$gps_t."\n";
			echo  "Testing data: ".$test_t."\n----\n";
			echo "-----=-----\n";
		}
		$return = 0;
#		return $return;
	}
}
return $return;
}

function convert_vs1($source, $out)
{
$dir = $GLOBALS['vs1dir'];
// dfine time that the script started
$start = date("H:i:s");
// counters
$c=0;
$cc=0;
$n=0;
$nn=0;
$N=0;
$complete=0;
//Break out file into an Array
$return = file($source);
//Access point and GPS Data Array
$apdata=array();
global $gpsdata;
// create file name of VS1 file from the name of the Txt file, 
$src=explode("\\",$source);
$f_max = count($src);
$file_src = explode(".",$src[$f_max-1]);
$file_ext = $dir.$file_src[0].'.vs1';

$filename = $file_ext;
	if($GLOBALS["debug"] == 1 ){echo $file_ext."\n".$filename."\n";}

// define initial write and appends
$filewrite = fopen($filename, "w");
$fileappend = fopen($filename, "a");


//create interval for progress
$line = count($return);
$stat_c = $line/97;
if ($GLOBALS["debug"] ==1){echo $stat_c."\n";}
if ($GLOBALS["debug"] ==1){echo $line."\n";}

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
	if ($cc >= $stat_c)
	{
		$cc=0;
		$complete++;
		echo $complete."% - ";
		if ($complete == 100 ){ echo "\n\n";}
	}
	//format date and time
	$datetime=explode(" ",$wifi[13]);
	$date=$datetime[0];
	$time=$datetime[1];
	
	// This is a temp array of data to be tested against the GPS array
	$gpsdata_t=array(
						"lat"=>$wifi[8],
						"long"=>$wifi[9],
						"sats"=>"0",
						"date"=>$date,
						"time"=>$time
						);
	// Create the Security Type number for the respective Access point
	if ($wifi[4]=="Open"&&$wifi[5]=="None"){$sectype="1";}
	if ($wifi[4]=="Open"&&$wifi[5]=="WEP"){$sectype="2";}
	if ($wifi[4]=="WPA-Personal" or $wifi[4] =="WPA2-Personal"){$sectype="3";}

	if ($GLOBALS["debug"] == 1 )
	{
		echo "\n\n+-+-+-+-+-+-\n".$gpsdata_t["lat"]."+-\n".$gpsdata_t["long"]."+-\n".$gpsdata_t["sats"]."+-\n".$gpsdata_t["date"]."+-\n".$gpsdata_t["time"]."+-\n";	
	}
	
	if (is_null($gpsdata))
	{
		$n++;
		$N++;
		if ($GLOBALS["debug"] ==1)
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
		if ($GLOBALS["debug"] == 1 )
		{
			echo "\n\n+_+_+_+_+_+_\n".$gpsdata[$n]["lat"]."+_\n".$gpsdata[$n]["long"]."+_\n".$gpsdata[$n]["sats"]."+_\n".$gpsdata[$n]["date"]."+_\n".$gpsdata[$n]["time"]."+_\n";	
			echo "Access Point Number: ".$N."\n";
			echo "=-=-=-=-=-=-\n".$apdata[$N]["ssid"]."=-\n".$apdata[$N]["mac"]."=-\n".$apdata[$N]["auth"]."=-\n".$apdata[$N]["encry"]."=-\n".$apdata[$N]["sectype"]."=-\n".$apdata[$N]["radio"]."=-\n".$apdata[$N]["chan"]."=-\n".$apdata[$N]["btx"]."=-\n".$apdata[$N]["otx"]."=-\n".$apdata[$N]["nt"]."=-\n".$apdata[$N]["label"]."=-\n".$apdata[$N]["sig"]."\n";
		}
	}
	else
	{
		$gpschk =& check_gps_array($gpsdata,$gpsdata_t);
		if ($gpschk===0)
		{
			if ($GLOBALS["debug"] ==1)
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
			if ($GLOBALS["debug"] == 1 )
			{
				echo "\n\n+_+_+_+_+_+_\n".$gpsdata[$n]["lat"]."+_\n".$gpsdata[$n]["long"]."+_\n".$gpsdata[$n]["sats"]."+_\n".$gpsdata[$n]["date"]."+_\n".$gpsdata[$n]["time"]."+_\n";	
				echo "Access Point Number: ".$N."\n";
				echo "=-=-=-=-=-=-\n".$apdata[$N]["ssid"]."=-\n".$apdata[$N]["mac"]."=-\n".$apdata[$N]["auth"]."=-\n".$apdata[$N]["encry"]."=-\n".$apdata[$N]["sectype"]."=-\n".$apdata[$N]["radio"]."=-\n".$apdata[$N]["chan"]."=-\n".$apdata[$N]["btx"]."=-\n".$apdata[$N]["otx"]."=-\n".$apdata[$N]["nt"]."=-\n".$apdata[$N]["label"]."=-\n".$apdata[$N]["sig"]."\n";
			}
		}elseif($gpschk===1)
		{
			if ($GLOBALS["debug"] ==1)
			{echo "\$n = ".$n."\n\$N = ".$N."\n";}
			$N++;
			$sig=$n.",".$wifi[3];
			if ($GLOBALS["debug"] ==1 ){echo "\nduplicate GPS data, not entered into array\n";}
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
			if ($GLOBALS["debug"] == 1 )
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
	//	GPS Convertion :
		$latitude = explode(" ", $gps["lat"]);
		$gps["lat"]="";
		$lat_front = explode(".", $latitude[1]);
		$lat_left = strlen($lat_front[0]);
		
		$longitude = explode(" ", $gps["long"]);
		$gps["long"]="";
		$long_front = explode(".",$longitude[1]);
		$long_left = strlen($long_front[0]);
		
		if($lat_left == 2 && $long_left == 2)
		{
			$lat_back = "0.".$lat_front[1]; // add a 0. to the begining of the number to make it a decmal
			$lat_back = $lat_back*60; // multiply the decimal to to convert it to minuets
			
			$Lat_temp  = explode(".",$lat_back); //get the numbers before the decimal place.
			$Lat_temp_ = strlen($Lat_temp[0]); //find out how long it is before the decimal
			$back_lat  = strlen($Lat_temp[1]);
			
			if($back_lat > 4){$Lat_temp[1] = substr_replace($Lat_temp[1],"",4);}
			
			if($Lat_temp_ == 1){$lat_ = $lat_front[0]."0".$lat_back;}
				else{$lat_ = $lat_front[0].$lat_back;}
		//////////////////// END LAT CONVERSION ////////////////////

		//////////////////// START LONG CONVERSION ////////////////////
			$long_back = "0.".$long_front[1]; //// add a 0. to the begining of the number to make it a decmal
			$long_back = $long_back*60; // multiply the decimal to to convert it to minuets
			
			$Long_temp = explode(".",$long_back); //get the numbers before the decimal place.
			$Long_temp_ = strlen($Long_temp[0]);
			$back_long = strlen($Long_temp[1]);
			if($back_long > 4){$Long_temp[1]= substr_replace($Long_temp[1],"",4);}
			
			if($Long_temp_ == 1){$long_ =  $long_front[0]."0".$long_back;}
				else{$long_ =  $long_front[0].$long_back;}
			
			if($latitude[0] == "S"){$la = "-";}
				else{$la="";}
			if($longitude[0]=="W"){$lo = "-";}
				else{$lo="";}
			
			if($lat_==0){$gps["lat"]="0.0000";}
				else{$gps["lat"]=$la.$lat_;}
			
			if($long_==0){$gps["long"]="0.0000";}
				else{$gps["long"]=$lo.$long_;}
		//////////////////// END LONG CONVERSION ////////////////////

		}elseif($lat_left == 4 && $long_left == 4)
		{
			if($latitude[0] == "S"){$la = "-";}
				else{$la="";}			
			if($longitude[0]=="W"){$lo = "-";}
				else{$lo="";}
			
			$long = $lo."".$long_front[0].".".$long_front[1];
			
			$lat = $la."".$lat_front[0].".".$lat_front[1];
			
			if($lat == NULL){$gps["lat"]="N 0.0000";}
				else{$gps["long"]= $long;}
			
			if($long == NULL){$gps["long"]="W 0.0000";}
				else{$gps["lat"]= $lat;}
			
		}elseif($lat_left == 1 && $long_left == 1)
		{
			if($latitude[0] == "S"){$la = "-";}
				else{$la="";}
			
			if($longitude[0]=="W"){$lo = "-";}
				else{$lo="";}
			
			$long = $lo."".$long_front[0].".".$long_front[1];
			
			$lat = $la."".$lat_front[0].".".$lat_front[1];
		
			if($lat == NULL){$gps["lat"]="N 0.0000";}
				else{$gps["long"]= $long;}
			if($long == NULL){$gps["long"]="W 0.0000";}
				else{$gps["lat"]= $lat;}
		}

//	END GPS convert
		
		
		if ($GLOBALS["debug"] ==1 ){echo "Lat : ".$gps['lat']." - Long : ".$gps['long']."\n";}
		
		$gpsd = $n."|".$gps['lat']."|".$gps['long']."|".$gps["sats"]."|".$gps["date"]."|".$gps["time"]."\r\n";
		if($GLOBALS["debug"] == 1){ echo $gpsd;}
		fwrite($fileappend, $gpsd);
		$n++;
	}
	$n=1;
	
	$ap_head = "# ---------------------------------------------------------------------------------------------------------------------------------------------------------\r\n# SSID|BSSID|MANUFACTURER|Authetication|Encryption|Security Type|Radio Type|Channel|Basic Transfer Rates|Other Transfer Rates|Network Type|Label|GpsID,SIGNAL\r\n# ---------------------------------------------------------------------------------------------------------------------------------------------------------\r\n";
	fwrite($fileappend, $ap_head);
	foreach($apdata as $ap)
	{
		$apd = $ap["ssid"]."|".$ap["mac"]."|".$ap["man"]."|".$ap["auth"]."|".$ap["encry"]."|".$ap["sectype"]."|".$ap["radio"]."|".$ap["chan"]."|".$ap["btx"]."|".$ap["otx"]."|".$ap["nt"]."|".$ap["label"]."|".$ap["sig"]."\r\n";
		if($GLOBALS["debug"] == 1){echo $apd;}
		fwrite($fileappend, $apd);
		$n++;

	}
	$end = date("H:i:s");
	$GPSS=count($gpsdata);
	$APS=count($apdata);
	echo "\n\n------------------------------\nTotal Number of Access Points : ".$APS."\nTotal Number of GPS Points : ".$GPSS."\n------------------------------\nDONE!\nStart Time : ".$start."\nStop Time : ".$end."\n-------";
}
}
?>