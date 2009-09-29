<?php
echo "\nWiFiDB Channel German Language Sectype Repair script\nVersion: 1.0\n\t(/tools/repair/german_repair.php)\nLast Edit: 2009-09-14\n - By: Phillip Ferland\n - http://www.randomintervals.com\wifidb\n-----------------------------------\n\n";

global $screen_output;
$screen_output = "CLI";

require('daemon/config.inc.php');
$config = $GLOBALS['wifidb_install'].$dim.'lib'.$dim.'config.inc.php';
$database = $GLOBALS['wifidb_install'].$dim.'lib'.$dim.'database.inc.php';
require($config);
require($database);

$filename = "german_repairs_".rand().".log";
$filewrite = fopen($filename, "w");
$fileappend = fopen($filename, "a");

$COLORS = array(
				"LIGHTGRAY"	=>"\033[0;37m",
				"BLUE"		=>"\033[0;34m",
				"GREEN"		=>"\033[0;32m",
				"RED"		=>"\033[0;31m",
				"YELLOW"	=>"\033[1;33m"
				);

$total_APS	= 0;
$corrected	= 0;
$failed		= 0;

$sql1 = "select * from `$db`.`$wtable` WHERE `auth` LIKE 'Offen'";
$result1 = mysql_query($sql1, $conn);

if($result1)
{
	$start = microtime(true);
	while($array = mysql_fetch_array($result1))
	{
		$table_old = $array['ssid'].' - '.$array['mac'].' - '.$array['sectype'].' - '.$array['auth'].' - '.$array['encry'].' - '.$array['chan'];
		$id = $array['id'];
		echo $table_old."\n";
		if($array['auth'] == "Offen")
		{
			if($array['encry'] == "Keine")
			{
				$sectype = "1";
			}elseif($array['encry'] == "WEP")
			{
				$sectype = "2";
			}
		}
		echo $sectype."\n";
		
		#  SANITY CHECK
		if($sectype == $array['sectype']){echo "skipping, this AP is fine\n\n"; continue;}
		
		$ssidss = smart_quotes($array['ssid']);
		$ssidsss = str_split($ssidss,25);	//split SSID in two at is 25th char.
		$ssid_S = $ssidsss[0];				//Use the 25 char long word for the APs table name, this is due to a limitation in MySQL table name lengths, 
											//the rest of the info will suffice for unique table names
		
		$table = $ssid_S.'-'.$array['mac'].'-'.$array['sectype'].'-'.$array['radio'].'-'.$array['chan'];
		$table_gps = $ssid_S.'-'.$array['mac'].'-'.$array['sectype'].'-'.$array['radio'].'-'.$array['chan'].$gps_ext;
		
		$new_table = $ssid_S.'-'.$array['mac'].'-'.$sectype.'-'.$array['radio'].'-'.$array['chan'];
		$new_table_gps = $ssid_S.'-'.$array['mac'].'-'.$sectype.'-'.$array['radio'].'-'.$array['chan'].$gps_ext;
		
		
		$update_chan_ptr = "UPDATE `$db`.`$wtable` SET `sectype` = '$sectype' WHERE `$wtable`.`id` = '$id'";

		echo $update_chan_ptr."\n";
	
		$result = mysql_query($update_chan_ptr, $conn);
		
		if($result=1)
		{
		
			echo $COLORS['GREEN']."Corrected, corrupted German Language Sectype data in pointers table.\n".$COLORS['LIGHTGRAY'];
			fwrite($fileappend, "Corrected, corrupted German Language Sectype data in pointers table.\r\n");
			
			$sql_rename = "RENAME TABLE `$db_st`.`$table` TO `$db_st`.`$new_table`";
			$result_rename = mysql_query($sql_rename, $conn);
			echo $sql_rename."\n";
			if($result_rename=1)
			{
				echo $COLORS['GREEN']."Signal table.\n".$COLORS['LIGHTGRAY'];
				fwrite($fileappend, "Signal table. \r\n");
				
				$sql_rename_gps = "RENAME TABLE `$db_st`.`$table_gps` TO `$db_st`.`$new_table_gps`";
				echo $sql_rename_gps."\n";
				
				$result_rename_gps = mysql_query($sql_rename_gps, $conn);
				if($result_rename_gps=1)
				{
					echo $COLORS['GREEN']."GPS table.\n".$COLORS['LIGHTGRAY'];
					fwrite($fileappend, "GPS table. \r\n");
					$corrected++;
				}else
				{
					echo $COLORS['RED']."FAILED to rename GPS table.\n".$COLORS['LIGHTGRAY'];
					fwrite($fileappend, "FAILED to rename GPS table. \r\n");
					$failed++;
				}
				
			}else
			{
				echo $COLORS['RED']."FAILED to rename Signal table.\n".$COLORS['LIGHTGRAY'];
				fwrite($fileappend, "FAILED to rename Signal table. \r\n");
				$failed++;
			}
		}
		else
		{
			echo $COLORS['RED']."Could not Correct corrupted German Language Sectype data.\nAP: $table\n|\n".$COLORS['LIGHTGRAY'];
			fwrite($fileappend, "Could not Correct corrupted German Language Sectype data. AP: $table\r\n");
			$failed++;
		}
		echo "AP: $table\n|\n";
		$total_APS++;
	}
}
$end = microtime(true);
$total = $end-$start;

echo "\n\n############# SUMMERY ############# 
Log File: $filename

Start: ".$start."
END: ".$end."
Total Run Time: $total
-----------------------

$total_APS APs checked.
Failed: $failed
Corrected: $corrected

";

?>