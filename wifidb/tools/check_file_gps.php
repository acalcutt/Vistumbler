<?php
$t1 = microtime(1);

error_reporting(E_ALL|E_STRICT);
ini_set("memory_limit","3072M"); //lots of GPS cords need lots of memory

global $screen_output, $dim, $COLORS, $daemon_ver;
$screen_output = "CLI";

if(!(@require_once 'daemon/config.inc.php')){die("You need to create and configure your config.inc.php file in the [tools dir]/daemon/config.inc.php");}
if($GLOBALS['wifidb_install'] == ""){die("You need to edit your daemon config file first in: [tools dir]/daemon/config.inc.php");}
require_once $GLOBALS['wifidb_install']."/lib/database.inc.php";
require_once $GLOBALS['wifidb_install']."/lib/config.inc.php";

$conn = $GLOBALS['conn'];
$db = $GLOBALS['db'];
$db_st = $GLOBALS['db_st'];
$wtable = $GLOBALS['wtable'];
$users_t = $GLOBALS['users_t'];
$database = new database();
$good=0;
$badf=0;
$badfb=0;
$other=0;
$terr=0;
$rows=0;
$missing=0;
if(!function_exists('parseArgs'))
{
	function parseArgs($argv){
		array_shift($argv);
		$out = array();
		foreach ($argv as $arg){
			if (substr($arg,0,2) == '--'){
				$eqPos = strpos($arg,'=');
				if ($eqPos === false){
					$key = substr($arg,2);
					$out[$key] = isset($out[$key]) ? $out[$key] : true;
				} else {
					$key = substr($arg,2,$eqPos-2);
					$out[$key] = substr($arg,$eqPos+1);
				}
			} else if (substr($arg,0,1) == '-'){
				if (substr($arg,2,1) == '='){
					$key = substr($arg,1,1);
					$out[$key] = substr($arg,3);
				} else {
					$chars = str_split(substr($arg,1));
					foreach ($chars as $char){
						$key = $char;
						$out[$key] = isset($out[$key]) ? $out[$key] : true;
					}
				}
			} else {
				$out[] = $arg;
			}
		}
		return $out;
	}
}

$parm = parseArgs($argv);

if(isset($parm['file']))
{
	$ID = $parm['file']+0;
	echo "Single AP Table check [ `$ID` ]\r\n";
	$sqls = "SELECT * FROM `$db`.`files` where `id` = '$ID'";

}elseif(isset($parm['help']))
{
die("
WiFiDB Check AP GPS Table against Source File.
Version: 1.0
Author: Phillip Ferland
Email: pferland@randomintervals.com
To use:
	To Run a Full DB check just run the script with no arguments.
		wifidb:~ # php check_file_gps.php
	
	To do a Single File check use --file= then find the ID number 
	of the import that you want to check in the 'Files already imported' page.
	If you have a MySQL adminstration app (ie phpmyadmin) this would be the `id`
	column in the `wifi`.`files` table.
		wifidb:~ # php check_file_gps.php --file=554
:-p");
}
else
{
	echo "Running Full DB check...\r\n";
	$sqls = "SELECT * FROM `$db`.`files`";
}



$result = mysql_query($sqls, $conn) or die(mysql_error($conn));
if($result)
{
	while($newArray = mysql_fetch_array($result))
	{
		if(mysql_query("TRUNCATE TABLE `$db`.`gps_table`", $conn))
		{
			$trunc = date("Y-m-d G:i:s");
			echo "$trunc - Truncated Temp table.\n";
		}
		else
		{
			$trunc = date("Y-m-d G:i:s");
			echo "Could not truncate table, this is not allowed, exiting....\r\n".mysql_error($conn);
		}
		
		$file_ID = $newArray['id'];
		$source = $newArray['file'];
		echo "[ $file_ID ] File: $source\n";
		
		$file_ext = explode(".", $source);
		$ext = strtolower($file_ext[1]);
		if($ext == "txt")
		{
			$file_source = $database->convert_vs1($GLOBALS['wifidb_install']."/import/up/".$source, "file");
		}
		else
		{	
			$file_source = $GLOBALS['wifidb_install']."/import/up/".$source;
		}
		
		$return  = file($file_source);
		
		
		if($return[0][0] != "#")
		{
			$file_source = $database->convert_vs1($GLOBALS['wifidb_install']."/import/up/".$source, "file");
			$return  = file($file_source);
		}
		$count = count($return);
		$gps_array_n_tmp=0;
		foreach($return as $ret)
		{		
			echo ".";
			if ($ret[0] == "#"){continue;}
			$retexp = explode("|",$ret);
			$ret_len = count($retexp);
			if ($ret_len == 12 or $ret_len == 6)
			{
				list($temp_gps) = $database->gen_gps($retexp);
				
				$gps_array_n_tmp++;
				$date = $temp_gps['date'];
				$time = trim($temp_gps['time']);
				
				$insert = "INSERT INTO `wifi`.`gps_table` ( `id` ,`lat` ,`long` ,`date`,`time`,`sats` ,`hdp` ,`alt` ,`geo` ,`kmh` ,`mph` ,`track`) 
													VALUES ('', '".$temp_gps['lat']."', '".$temp_gps['long']."', '".$date."' , '".$time."', '".$temp_gps['sats']."', '".$temp_gps['hdp']."', '".$temp_gps['alt']."', '".$temp_gps['geo']."', '".$temp_gps['kmh']."', '".$temp_gps['mph']."', '".$temp_gps['track']."' )";
				mysql_query($insert, $conn) or die("insert error, faital\n\t".mysql_error($conn));
			}
		}
		echo "\n";
		$end_import = date("Y-m-d G:i:s");
		echo "\n$end_import\nDone importing into temp table.\r\n";
		if(!$gps_array_n_tmp>0){echo "ZERO\r\n\r\n";continue;}
		$gps_array_n_tmp=0;
		$gps_array_n = 1;
		
		$row = $newArray['user_row'];
		$user_row_return = mysql_query("SELECT * FROM `$db`.`$users_t` WHERE `id`='$row' LIMIT 1", $conn);
		echo "Selected points for APs to check...\r\n";
		$user_row_array = mysql_fetch_array($user_row_return);
		$points = $user_row_array['points'];
		$point_exp = explode("-", $points);
		foreach($point_exp as $point)
		{
			$pnt_exp = explode(",", $point);
			$pt_exp = explode(":", $pnt_exp[1]);
			$PT_ID = $pt_exp[0];
			$sqls = "SELECT * FROM `$db`.`$wtable` WHERE `id`='$PT_ID' LIMIT 1";
			$PT_result = mysql_query($sqls, $conn) or die(mysql_error($conn));
			$pt_array = mysql_fetch_array($PT_result);
			$TB_ID = $pt_array['id'];
			$macaddress = $pt_array['mac'];
			$radio = $pt_array['radio'];
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
			
			list($ssid_ptb) = make_ssid($pt_array["ssid"]);
			
			$table_gps	=	$ssid_ptb.'-'.$pt_array["mac"].'-'.$pt_array["sectype"].'-'.$pt_array["radio"].'-'.$pt_array['chan'].$gps_ext;
			echo "[ $PT_ID ]TABLE: ".$table_gps."\r\n";
			$result1 = mysql_query("SELECT * FROM `$db_st`.`$table_gps`", $conn);
			if(!$result1)
			{
				$sqlct = "CREATE TABLE `$db_st`.`$table` (
									`id` INT( 255 ) NOT NULL AUTO_INCREMENT ,
									`btx` VARCHAR( 10 ) NOT NULL ,
									`otx` VARCHAR( 10 ) NOT NULL ,
									`nt` VARCHAR( 15 ) NOT NULL ,
									`label` VARCHAR( 25 ) NOT NULL ,
									`sig` TEXT NOT NULL ,
									`user` VARCHAR(255) NOT NULL ,
									INDEX ( `id` ), 
									UNIQUE( `id` )
									) ENGINE = 'InnoDB' DEFAULT CHARSET='utf8'";
				if(mysql_query($sqlct, $conn))
				{
					$sqlcgt = "CREATE TABLE `$db_st`.`$gps_table` (
								`id` INT( 255 ) NOT NULL AUTO_INCREMENT ,
								`lat` VARCHAR( 25 ) NOT NULL ,
								`long` VARCHAR( 25 ) NOT NULL ,
								`sats` INT( 2 ) NOT NULL ,
								`hdp` FLOAT NOT NULL ,
								`alt` FLOAT NOT NULL ,
								`geo` FLOAT NOT NULL ,
								`kmh` FLOAT NOT NULL ,
								`mph` FLOAT NOT NULL ,
								`track` FLOAT NOT NULL ,
								`date` VARCHAR( 10 ) NOT NULL ,
								`time` VARCHAR( 8 ) NOT NULL ,
								INDEX ( `id` ), 
								UNIQUE( `id` )
								) ENGINE = 'InnoDB' DEFAULT CHARSET='utf8'";
					if(!mysql_query($sqlcgt, $conn))
					{
						echo "=======CREATE MISSING TABLES======= :-(\r\n";
						continue;
					}
				}
				
			}
			while ($field = mysql_fetch_array($result1)) 
			{
				$GPS_ID = $field['id'];
				$date = $field['date'];
				$time = $field['time'];
				$lat = $field['lat'];
				$long = $field['long'];
				
				
				$gps_sql = "SELECT `lat`,`long`,`date`,`time` FROM `$db`.`gps_table` WHERE `date` = '$date' AND `time` LIKE '$time' LIMIT 1";
				$gps_return = mysql_query($gps_sql, $conn);
				$fieldf = mysql_fetch_array($gps_return);
				$datef = $fieldf['date'];
				$timef = $fieldf['time'];
				$datef = $datef." ".$timef;
				$latf = $fieldf['lat'];
				$longf = $fieldf['long'];
				
				if($datef == '' or $latf == ''){echo "/"; $other++; continue;}
				if($lat == $latf and $long != $longf)
				{
					$up_long = "UPDATE `$db_st`.`$table_gps` SET `long` =  '$longf', `lat` =  '$latf' WHERE `id` = '$GPS_ID' LIMIT 1";
					if(mysql_query($up_long, $conn))
					{echo "-";$badf++;}
					else
					{
						echo "LAT: $lat  -  LONG: $long  -  DATE: $date $time\r\n";
						echo "LAT F: $latf  -  LONG F: $longf  -  DATE F: $datef\r\n";
						echo mysql_error($conn)."\r\n";
						$badb++;
					}
				}else
				{
					echo "+";
					$good++;
				}
			}
			echo "\r\n";
		}
	}
}else
{
	echo "Main SQL error.";
	die();
}
$t2 = microtime(1);
echo "Good : $good (no fix needed)\r\nBad Fixed: $bad (was bad, but is now fixed)\r\nBad still bad: $badb(Is still bad, failed to fix)\r\nOther: $other (Just null gps data, nothing horrable)\r\nRuntime: ".($t2 - $t1)."\r\n:-p\r\n";
?>