<?php
$start = microtime(1);
error_reporting(E_ALL|E_STRICT);
ini_set("memory_limit","3072M");
global $screen_output, $COLORS;
$ver = '1.0';
$screen_output = "CLI";
if(!(@require_once 'config.inc.php')){die("You need to create and configure your config.inc.php file in the [tools dir]/daemon/config.inc.php");}
if($GLOBALS['wifidb_install'] == ""){die("You need to edit your daemon config file first in: [tools dir]/daemon/config.inc.php");}
require_once $GLOBALS['wifidb_install']."/lib/database.inc.php";
require_once $GLOBALS['wifidb_install']."/lib/wdb_xml.inc.php";
require_once $GLOBALS['wifidb_install']."/lib/config.inc.php";
if($GLOBALS['colors_setting'] == 0 or PHP_OS == "WINNT")
{
	$COLORS = array(
					"LIGHTGRAY"	=> "",
					"BLUE"		=> "",
					"GREEN"		=> "",
					"RED"		=> "",
					"YELLOW"	=> ""
					);
}else
{
	$COLORS = array(
					"LIGHTGRAY"	=> "\033[0;37m",
					"BLUE"		=> "\033[0;34m",
					"GREEN"		=> "\033[0;32m",
					"RED"		=> "\033[0;31m",
					"YELLOW"	=> "\033[1;33m"
					);
}

$BAD_CLI_COLOR = $GLOBALS['BAD_CLI_COLOR'];
$GOOD_CLI_COLOR = $GLOBALS['GOOD_CLI_COLOR'];
$OTHER_CLI_COLOR = $GLOBALS['OTHER_CLI_COLOR'];

$subject						=	"WiFiDB Statistics Daemon";
$type							=	"geonamed";
$pid_file						=	$GLOBALS['pid_file_loc'].'geonamed.pid';
$This_is_me						=	getmypid();
if(!file_exists($GLOBALS['pid_file_loc'])){mkdir($GLOBALS['pid_file_loc']);}
fopen($pid_file, "w");
$fileappend = fopen($pid_file, "a");
$write_pid = fwrite($fileappend, "$This_is_me");

if(!$write_pid){die($GLOBALS['COLORS'][$BAD_CLI_COLOR]."Could not write pid file, thats not good... >:[".$GLOBALS['COLORS'][$OTHER_CLI_COLOR]);}
verbosed($GLOBALS['COLORS'][$GOOD_CLI_COLOR]."
WiFiDB 'Geoname Daemon'
Version: 1.0.0
- Daemon Start: 2010-06-23
- Last Daemon File Edit: 2010-06-23
( /tools/daemon/geonamed.php )
- By: Phillip Ferland ( pferland@randomintervals.com )
- http://www.randomintervals.com/wifidb/

PID: [ $This_is_me ]
".$GLOBALS['COLORS'][$OTHER_CLI_COLOR], 1, $screen_output, 1);

##################################################################
##################################################################
##################################################################

$sep = $GLOBALS['sep'];
$wtable = $GLOBALS['wtable'];
$db = $GLOBALS['db'];
$db_st = $GLOBALS['db_st'];
$database = new database();
$WDB_XML = new WDB_XML();
$start = microtime(1);
$date = date('Y-m-d_H-i-s');
$named = 0;
$good = 0;
$bad  = 0;
$total = 0;
$no_gps = 0;

while(1)
{
	echo "Start Gather of WiFiDB GeoNames\r\n";

	$sql = "SELECT * FROM `$db`.`$wtable`"; # ORDER BY `id` DESC";
	$result = mysql_query($sql, $conn) or die(mysql_error($conn));
	$total = mysql_num_rows($result);

	$temp_kml = '/tmp/full_db_export.kml';
	$filewrite = fopen($temp_kml, "w");
	$fileappend = fopen($temp_kml, "a");

	$moved ='/kmz/'.$date.'_fulldb.kmz';

	echo "Gathered Wtable data\r\n";
	$total = 0;
	$x=0;
	$n=0;
	$NN=0;
	while($ap_array = mysql_fetch_array($result))
	{
		$man 		= $database->manufactures($ap_array['mac']);
		$id			= $ap_array['id'];
		list($ssid)  = make_ssid($ap_array['ssid']);
		$mac		= $ap_array['mac'];
		$sectype	= $ap_array['sectype'];
		$radio		= $ap_array['radio'];
		$chan		= $ap_array['chan'];
#		echo "GeoNames.org Data Returned:
#	Country Code: ".$ap_array['countrycode']."--
#	County Name: ".$ap_array['countryname']."--
#	Admin Code: ".$ap_array['admincode']."--
#	Admin Name: ".$ap_array['adminname']."--
#	ISO Code: ".$ap_array['iso3166-2']."--
#	Lat: ".$ap_array['lat']."--
#	Long: ".$ap_array['long']."--\r\n\r\n";

		if(($ap_array['countryname'] != '' || $ap_array['iso3166-2'] != 0) && $ap_array['lat'] != 'N 0.0000')
		{
			echo $id.' - '.$ssid."\r\n Already updated.\r\n";
			continue;
		}
		
		$table = $ssid.'-'.$mac.'-'.$sectype.'-'.$radio.'-'.$chan.$gps_ext;
		
		echo $id.' - '.$ssid."\r\nRunning GeoFilter check....\r\n";
		
		$sql1 = "SELECT * FROM `$db_st`.`$table`";
	#	echo $sql1."\r\n";
		$result1 = mysql_query($sql1, $conn);
		if(!$result1){$bad++;continue;}
		switch($sectype)
		{
			case 1:
				$type = "#openStyleDead";
				$auth = "Open";
				$encry = "None";
				break;
			case 2:
				$type = "#wepStyleDead";
				$auth = "Open";
				$encry = "WEP";
				break;
			case 3:
				$type = "#secureStyleDead";
				$auth = "WPA-Personal";
				$encry = "TKIP-PSK";
				break;
		}
		switch($radio)
		{
			case "a":
				$radio="802.11a";
				break;
			case "b":
				$radio="802.11b";
				break;
			case "g":
				$radio="802.11g";
				break;
			case "n":
				$radio="802.11n";
				break;
			default:
				$radio="Unknown Radio";
				break;
		}
		$zero = 0;
		while($gps_table_first = mysql_fetch_array($result1))
		{
			$lat_exp = explode(" ", $gps_table_first['lat']);
			if(@$lat_exp[1])
			{
				$test = $lat_exp[1]+0;
			}else
			{
				$test = $lat_exp[0]+0;
			}
			if($test == "0"){$zero = 1; $bad++; continue;}
			
			$lat  =& $database->convert_dm_dd($gps_table_first['lat']);
			$long =& $database->convert_dm_dd($gps_table_first['long']);
			$start1 = microtime(1);
			$geo_site = implode("\r\n", file("http://ws.geonames.org/countrySubdivision?lat=$lat&lng=$long"));
			$xml = $WDB_XML->xml2ary($geo_site);
			if(@$xml['geonames']['_c']['countrySubdivision'])
			{
				if(@$xml['geonames']['_c']['countrySubdivision']['_c']['code'][1]['_v'] && !@is_int($xml['geonames']['_c']['countrySubdivision']['_c']['code'][1]['_v']))
				{
					$countryCode = addslashes($xml['geonames']['_c']['countrySubdivision']['_c']['countryCode']['_v']);
					$countryName = mysql_real_escape_string(addslashes($xml['geonames']['_c']['countrySubdivision']['_c']['countryName']['_v']));
					$adminCode = addslashes($xml['geonames']['_c']['countrySubdivision']['_c']['adminCode1']['_v']);
					$adminName = mysql_real_escape_string(addslashes($xml['geonames']['_c']['countrySubdivision']['_c']['adminName1']['_v']));
					$isoCode = addslashes($xml['geonames']['_c']['countrySubdivision']['_c']['code'][1]['_v']);
					$update = "UPDATE `$db`.`$wtable` SET `countrycode` = '$countryCode',
							`countryname` = '$countryName',
							`admincode` = '$adminCode',
							`adminname` = '$adminName',
							`iso3166-2` = '$isoCode',
							`lat` = '$lat',
							`long` = '$long'
							 WHERE `$wtable`.`id` = '$id'  LIMIT 1";
					if(mysql_query($update, $conn))
					{
						echo "Updated!\r\n";
	#	Country Code: ".$xml['geonames']['_c']['countrySubdivision']['_c']['countryCode']['_v']."
	#	County Name: ".$xml['geonames']['_c']['countrySubdivision']['_c']['countryName']['_v']."
	#	Admin Code: ".$xml['geonames']['_c']['countrySubdivision']['_c']['adminCode1']['_v']."
	#	Admin Name: ".$xml['geonames']['_c']['countrySubdivision']['_c']['adminName1']['_v']."
	#	ISO Code: $isoCode
	#	Lat: $lat
	#	Long: $long\r\n\r\n";
					}else
					{
						echo "There was an error inserting the APs Geoname data.\r\n";
						mail_users("There was an error inserting the APs Geoname data. :-(\r\n".mysql_error($conn)."\r\n\r\n-WiFiDB Service", $subject, $type, 1); 
					}
				}else
				{
					$countryCode = addslashes($xml['geonames']['_c']['countrySubdivision']['_c']['countryCode']['_v']);
					$countryName = mysql_real_escape_string(addslashes($xml['geonames']['_c']['countrySubdivision']['_c']['countryName']['_v']));
					$adminCode = addslashes($xml['geonames']['_c']['countrySubdivision']['_c']['adminCode1']['_v']);
					$adminName = mysql_real_escape_string(addslashes($xml['geonames']['_c']['countrySubdivision']['_c']['adminName1']['_v']));
					$isoCode = 0;
					$update = "UPDATE `$db`.`$wtable` SET `countrycode` = '$countryCode',
							`countryname` = '$countryName',
							`admincode` = '$adminCode',
							`adminname` = '$adminName',
							`iso3166-2` = '$isoCode',
							`lat` = '$lat',
							`long` = '$long'
							 WHERE `$wtable`.`id` = '$id'  LIMIT 1";
					#	echo $update."\r\n";
					if(mysql_query($update, $conn))
					{
						echo "Updated!\r\n";
	#	Country Code: ".$xml['geonames']['_c']['countrySubdivision']['_c']['countryCode']['_v']."
	#	County Name: ".$xml['geonames']['_c']['countrySubdivision']['_c']['countryName']['_v']."
	#	Admin Code: ".$xml['geonames']['_c']['countrySubdivision']['_c']['adminCode1']['_v']."
	#	Admin Name: ".$xml['geonames']['_c']['countrySubdivision']['_c']['adminName1']['_v']."
	#	ISO Code: $isoCode
	#	Lat: $lat
	#	Long: $long\r\n\r\n";
					}else
					{
						echo "There was an error inserting the APs Geoname data.\r\n";
						mail_users("There was an error inserting the APs Geoname data. :-(\r\n".mysql_error($conn)."\r\n\r\n-WiFiDB Service", $subject, $type, 1); 
					}
				}
			}else
			{
				echo "Failed to gather GeoNames data.\r\n";
				mail_users("Failed to gather GeoNames data. :-(\r\n\r\n-WiFiDB Service", $subject, $type, 1); 
			}
			$zero = 0;
			$NN++;
			
			
			$stop1 = microtime(1);
			$total = $total + ($stop1  - $start1);
			$avg = $total / $NN;
		#	echo "Run : ".($stop1  - $start1)."\r\nTotal: $total\r\nAPS: $NN\r\nAPs / sec: $avg\r\n";
			echo "##########################\r\n\r\n";
			
			break;
		}
		$total++;
		if($zero == 1)
		{
			$zero == 0;
			$no_gps++;
			echo "No Valid GPS cant GeoFilter...\r\n";
			continue;
		}
		$good++;
	}
	$stop = microtime(1);
	echo "Finished generating location filter data.\r\nStart: $start\r\nStop: $stop\r\nTotal Run: ".($stop - $start)."\r\n";
	mail_users("New Statistics have been ran, go check them out!\r\nLink: ".$UPATH."\r\nLogin and go to the admin panel\r\n-WiFiDB Service", $subject, $type); 
	sleep(86400);
}
?>