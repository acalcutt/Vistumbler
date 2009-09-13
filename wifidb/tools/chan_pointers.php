<?php
echo "\nWiFiDB Channel Pointer Repair script\nVersion: 1.0\n\t(/tools/repair/chan_pointers.php)\n - By: Phillip Ferland\n - http://www.randomintervals.com\wifidb\n-----------------------------------\n\n";

global $screen_output;
ini_set("memory_limit","3072M"); //lots of GPS cords need lots of memory

$screen_output = "CLI";
include('daemon/config.inc.php');

$config = $GLOBALS['wifidb_install'].$dim.'lib'.$dim.'config.inc.php';
$database = $GLOBALS['wifidb_install'].$dim.'lib'.$dim.'database.inc.php';

include($config);
include($database);
$total_size = 0;
$filename = "chan_repairs_".rand().".log";
$filewrite = fopen($filename, "w");
$fileappend = fopen($filename, "a");

$COLORS = array(
					"LIGHTGRAY"	=>"\033[0;37m",
					"BLUE"		=>"\033[0;34m",
					"GREEN"		=>"\033[0;32m",
					"RED"		=>"\033[0;31m",
					"YELLOW"	=>"\033[1;33m"
					);

$FILENUM	= 1;
$FILES		= 0;
$total_APS	= 0;
$gpscount	= 0;
$corrected	= 0;
$failed		= 0;

$sql_alter = "ALTER TABLE `$db`.`$wtable` CHANGE `chan` `chan` VARCHAR( 3 )";
$alter = mysql_query($sql_alter, $conn);
if($alter)
{
	echo $COLORS['GREEN']."Corrected the chan char length bug. Chan is now 3 chars, not 2\n".$COLORS['LIGHTGRAY'];
	fwrite($fileappend, "Corrected the chan char length bug. Chan is now 3 chars, not 2\r\n");
}
else
{
	echo $COLORS['RED']."ERROR correcting the chan char length bug. Chan is not 3 chars\n".mysql_error($conn).$COLORS['LIGHTGRAY'];
	fwrite($fileappend, "ERROR correcting the chan char length bug. Chan is not 3 chars\r\n".mysql_error($conn));
}

$sql1 = "select * from `$db`.`files` ORDER BY `id` ASC";
$result1 = mysql_query($sql1, $conn);

if($result1)
{
	$start = microtime(true);
	while($array = mysql_fetch_array($result1))
	{
		$source = $GLOBALS['wifidb_install'].$dim."import".$dim."up".$dim.$array['file'];
		$size = str_replace("kB", "", $array['size']);
		$size = $size+0;
		$total_size = $total_size+$size;
		echo "File: ".$array['id']." -- ".$source."\n";
		$return  = file($source);
		$count = count($return);
		
		foreach($return as $ret)
		{
			if ($ret[0] == "#"){continue;}
			
			$wifi = explode("|",$ret);
			$ret_len = count($wifi);
			
			if ($ret_len == 12 or $ret_len == 6)
			{
				
				list($gdata[$wifi[0]], $gpscount) = database::gen_gps($wifi, $gpscount);
				
			}elseif($ret_len == 13)
			{
				
				if(!isset($SETFLAGTEST))
				{
					
					$count1 = $count - $gpscount;
					$count1 = $count1 - 8;
					
					if($count1 == 0){continue;}
					
					$SETFLAGTEST = TRUE;
					
				}
				
				if($wifi[0] == ''){$wifi[0]="UNNAMED";}
				if($wifi[1] == ''){$wifi[1] = "00:00:00:00:00:00";}
				if($wifi[5] == ''){$wifi[5] = "0";}
				if($wifi[6] == ''){$wifi[6] = "u";}
				if($wifi[7] == ''){$wifi[7] = "0";}
				
				if($wifi[6] == "802.11a")
						{$radios = "a";}
					elseif($wifi[6] == "802.11b")
						{$radios = "b";}
					elseif($wifi[6] == "802.11g")
						{$radios = "g";}
					elseif($wifi[6] == "802.11n")
						{$radios = "n";}
					else
						{$radios = "U";}
				
				// sanitize wifi data to be used in table name
				$ssids = filter_var($wifi[0], FILTER_SANITIZE_SPECIAL_CHARS);
				$ssidss = smart_quotes($ssids);
				$ssidsss = str_split($ssidss,25); //split SSID in two at is 25th char.
				$ssid_S = $ssidsss[0]; //Use the 25 char long word for the APs table name, this is due to a limitation in MySQL table name lengths, 
									   //the rest of the info will suffice for unique table names
				$mac1 = explode(':', $wifi[1]);
				$macs = $mac1[0].$mac1[1].$mac1[2].$mac1[3].$mac1[4].$mac1[5]; //the APs table doesnt need :'s in its name, nor does the Pointers table, well it could I just dont want to

				$sectype	=	filter_var($wifi[5], FILTER_SANITIZE_SPECIAL_CHARS);
				$chan		=	filter_var($wifi[7], FILTER_SANITIZE_SPECIAL_CHARS);				
				$chan		=	$chan+0;
				$chan_count	=	strlen($chan);
				
				$table = $ssids.' - '.$macs.' - '.$sectype.' - '.$radios.' - '.$chan;
				
				if($chan_count >= 3 AND ($radios == "a" OR $radios == "n"))
				{
					
					$pt_res = mysql_query("SELECT * FROM `$db`.`$wtable` WHERE `mac` LIKE '$macs' AND `ssid` LIKE '$ssidss' AND `sectype` LIKE '$sectype' AND `radio` LIKE '$radios' LIMIT 1", $conn) or die(mysql_error($conn));
					$rows = mysql_num_rows($pt_res);
		#			echo $rows."\n";
					
					$newArray = mysql_fetch_array($pt_res);
					$id = $newArray['id'];
					
					$update_chan_ptr = "UPDATE `$db`.`$wtable` SET `chan` = '$chan' WHERE `$wtable`.`id` = '$id'";
		#			echo $update_chan_ptr."\n";
					$result = mysql_query($update_chan_ptr, $conn);
					if($result)
					{
					
						echo $COLORS['GREEN']."Corrected, corrupted Chan data, you will now beable to find this AP's data tables.\nAP: $table\n|\n".$COLORS['LIGHTGRAY'];
						fwrite($fileappend, "Corrected, corrupted Chan data, you will now beable to find this AP's data tables. AP: $table\r\n");
						$corrected++;
					}
					else
					{
					
						echo $COLORS['RED']."Could not correct this APs corrupt Chan data.\nAP: $table\n|\n".$COLORS['LIGHTGRAY'];
						fwrite($fileappend, "Could not correct this APs corrupt Chan data. AP: $table\r\n");
						$failed++;
					}
					echo "Found a AP with a chan of 3 or more chars.\n";
					
				}
				$FILENUM++;
			}
		}
		$total_APS = $total_APS+$FILENUM;
		echo "Number of APs checked: $FILENUM\n";
		$FILES++;
		$FILENUM = 1;
	}
	
}
$end = microtime(true);
$total = $end-$start;

$total_size = $total_size/1024;
$total_s_exp = explode(".", $total_size);
$total_size_spl = str_split($total_s_exp[1], 2);
$total_size_new = $total_s_exp[0].".".$total_size_spl[0];
echo "\n\n############# SUMMERY ############# 
Log File: $filename

Start: ".$start."
END: ".$end."
Total Run Time: $total
-----------------------
To have ".$FILES." files to be checked.
For a grand total of $total_size_new MB of data.
For $total_APS APs. (Guaranteed duplicated count)
Failed: $failed
Corrected: $corrected

";
?>