<?php
global $screen_output;
$screen_output = "CLI";

echo "\033[0;37mStarting WiFiDB Table Checker.\r\n";

$start = microtime(1);

if(!(require_once 'daemon/config.inc.php')){die("You need to create and configure your config.inc.php file in the [tools dir]/daemon/config.inc.php");}
if($GLOBALS['wifidb_install'] == ""){die("You need to edit your daemon config file first in: [tools dir]/daemon/config.inc.php");}
require_once $GLOBALS['wifidb_install']."/lib/database.inc.php";
require_once $GLOBALS['wifidb_install']."/lib/config.inc.php";

echo "Grabbed all the settings that are needed.\r\n";

$db_st = $GLOBALS['db_st'];
$errors = array();
$good = 0;
$bad = 0;
$return = mysql_query("SELECT * FROM `$db`.`$wtable`", $conn);
while($array = mysql_fetch_array($return))
{
	list($ssid_S, $ssids, $ssidss ) = make_ssid($array['ssid'], 1);
	$mac1 = explode(':', $array['mac']);
	$macs = $mac1[0].$mac1[1].$mac1[2].$mac1[3].$mac1[4].$mac1[5];
	$auth		=	htmlentities($array['auth'], ENT_QUOTES);
	$encry		=	htmlentities($array['encry'], ENT_QUOTES);
	$sectype	=	htmlentities($array['sectype'], ENT_QUOTES);
	$chan		=	htmlentities($array['chan'], ENT_QUOTES);
	$radios 	=	htmlentities($array['radio'], ENT_QUOTES);
	$table = $ssid_S.'-'.$macs.'-'.$sectype.'-'.$radios.'-'.$chan;
	$gps_table = $table.$GLOBALS['gps_ext'];
	
	echo "Checking Table `$db_st`.`$table`...\r\n";
	
	if(mysql_query("SELECT `id` FROM `$db_st`.`$table` LIMIT 1", $GLOBALS['conn']))
	{
		echo "\t\t\033[0;32mSignal Table is Good\033[0;37m\r\n";
		if(mysql_query("SELECT `id` FROM `$db_st`.`$gps_table` LIMIT 1", $GLOBALS['conn']))
		{
			echo "\t\t\033[0;32mGPS Table is Good\033[0;37m\r\n";
			$good++;
		}else
		{
			echo "\t\t\033[0;31m**Error querying the GPS table**\033[0;37m\r\n";
			$error[] = array( 'id'=>$array['ID'], 'table'=>$gps_table);
			$bad++;
		}
	}else
	{
		echo "\t\t\033[0;31m**Error querying the Signal table**\033[0;37m\r\n";
		$error[] = array( 'id'=>$array['ID'], 'table'=>$table);
		$bad++;
	}
	echo "|-----|\r\n";
}

echo "\033[0;32mFinished checking, now dumping error array...\033[0;37m\r\n\r\n";
$end = microtime(1);

foreach(@$error as $err)
{
	echo "ID: ".$err['ID']." --- ".$err['table']."\r\n";
}
echo "Runtime: ".($end - $start)."\r\n\033[0;32mGood: $good \033[0;37m--\033[0;31m Bad: $bad\033[0;37m\r\n";

?>