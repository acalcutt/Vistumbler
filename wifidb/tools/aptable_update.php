<?php
echo "\nWiFiDB AP Signal Table User field update script\nVersion: 1.0\n\t(/tools/aptable_update.php)\nLast Edit: 2009-09-14\n - By: Phillip Ferland\n - http://www.randomintervals.com\wifidb\n-----------------------------------\n\n";

global $screen_output;
$screen_output = "CLI";

require('daemon/config.inc.php');
$config = $GLOBALS['wifidb_install'].$dim.'lib'.$dim.'config.inc.php';
$database = $GLOBALS['wifidb_install'].$dim.'lib'.$dim.'database.inc.php';
require($config);
require($database);

$filename = "user_field_update".rand().".log";
$filewrite = fopen($filename, "w");
$fileappend = fopen($filename, "a");

$COLORS = array(
				"LIGHTGRAY"	=>"\033[0;37m",
				"BLUE"		=>"\033[0;34m",
				"GREEN"		=>"\033[0;32m",
				"RED"		=>"\033[0;31m",
				"YELLOW"	=>"\033[1;33m"
				);

$total_APS		= 0;
$total_APS_Bad	= 0;
$total_APS_Good	= 0;
$corrected		= 0;
$failed			= 0;

$sql1 = "select * from `$db`.`$wtable`";
$result1 = mysql_query($sql1, $conn);

if($result1)
{
	$start = microtime(true);
	while($array = mysql_fetch_array($result1))
	{
		$ssidss = smart_quotes($array['ssid']);
		$ssidsss = str_split($ssidss,25);	//split SSID in two at is 25th char.
		$ssid_S = $ssidsss[0];				//Use the 25 char long word for the APs table name, this is due to a limitation in MySQL table name lengths, 
											//the rest of the info will suffice for unique table names
		
		$table = $ssid_S.'-'.$array['mac'].'-'.$array['sectype'].'-'.$array['radio'].'-'.$array['chan'];
		
		$update_user_field = "ALTER TABLE `$db_st`.`$table` CHANGE `user` `user` VARCHAR( 255 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL";

		echo $update_chan_ptr."\n";
	
		$result = mysql_query($update_user_field, $conn);
		
		if($result)
		{
		
			echo $COLORS['GREEN'].$table."\nChanged `user` field.\n".$COLORS['LIGHTGRAY'];
			fwrite($fileappend, $table."\nChanged `user` field.\r\n");
		}else
		{
			echo $COLORS['GREEN'].$table."\nCould not change `user` field.\n".$COLORS['LIGHTGRAY'];
			fwrite($fileappend, $table."\nCould not change `user` field.\r\n");
		}
		
		$update_label_feild = "ALTER TABLE `$db_st`.`$table` CHANGE `label` `label` VARCHAR( 255 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL";
		$result_ = mysql_query($update_user_field, $conn);
		if($result_)
		{
		
			echo $COLORS['GREEN']."Changed `label` field.\n".$COLORS['LIGHTGRAY'];
			fwrite($fileappend, "Changed `label` field.\r\n");
		}else
		{
			echo $COLORS['GREEN']."Could not change `label` field.\n".$COLORS['LIGHTGRAY'];
			fwrite($fileappend, "Could not change `label` field.\r\n");
		}
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

";

?>