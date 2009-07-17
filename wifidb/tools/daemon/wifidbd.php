<?php
//Now this is not what I would call a 'true' 'daemon' by any sorts,
//I mean it does have a php script (/tools/rund.php) that can turn 
//the daemon on and off. But it is a php script that is running 
//perpetually in the background. I dont think this is how php was 
//intended to be used. I am hoping to get a C++ version working 
//sometime soon, untill then I am using php.
require 'config.inc.php';
$PHP_OS = PHP_OS;
if($GLOBALS['colors_setting'] == 0 or $PHP_OS[0] == "W")
{
	$COLORS = array(
					"BLACK"		=>"",
					"DARKGRAY"	=>"",
					"LIGHTGRAY"	=>"",
					"WHITE"		=>"",
					"BLUE"		=>"",
					"LIGHTBLUE"	=>"",
					"GREEN"		=>"",
					"LIGHTGREEN"=>"",
					"CYAN"		=>"",
					"LIGHTCYAN"	=>"",
					"RED"		=>"",
					"LIGHTRED"	=>"",
					"PURPLE"	=>"",
					"LIGHTPURPLE"=>"",
					"BROWN"		=>"",
					"YELLOW"	=>""
					);
}
global $COLORS;
require $GLOBALS['wifidb_install']."/lib/database.inc.php";
require $GLOBALS['wifidb_install']."/lib/config.inc.php";

$daemon_ver	=	"1.6";
$start_date = "2009-04-23";
$last_edit = "2009-July-04";

date_default_timezone_set($timezn);

if($GLOBALS['log_level'] == 0){$de = "Off";}
elseif($GLOBALS['log_level'] == 1){$de = "Errors";}
elseif($GLOBALS['log_level'] == 2){$de = "Detailed Errors (when available)";}

verbosed($GLOBALS['COLORS']['GREEN']."\nWiFiDB 'Daemon'\nVersion: ".$daemon_ver."\n - Daemon Start: ".$start_date."\n - Last Daemon File Edit: ".$last_edit."\n\t(/tools/daemon/wifidbd.php)\n - By: Phillip Ferland\n - http://www.randomintervals.com\nLog Level is: ".$GLOBALS['log_level']." (".$de.")".$GLOBALS['COLORS']['WHITE'], $verbose, "CLI",1);

if($log_level != 0)
{
	if($GLOBALS['log_interval'] == 0){$de = "One File 'log/wifidbd_log.log'";}
	elseif($GLOBALS['log_interval'] == 1){$de = "one file a day 'log/wifidbd_log_[yyyy-mm-dd].log'";}
	verbosed($GLOBALS['COLORS']['GREEN']."Log Interval is: ".$GLOBALS['log_interval']." (".$de.")".$GLOBALS['COLORS']['WHITE'], $verbose, "CLI");
}
ini_set("memory_limit","3072M"); //lots of GPS cords need lots of memory
error_reporting(E_STRICT|E_ALL); //show all erorrs with strict santex

logd("Have included the WiFiDB Tools Functions file for the 'Daemon'.", $log_interval, 0,  $GLOBALS['log_level']);
verbosed($GLOBALS['COLORS']['GREEN']."Have included the WiFiDB Tools Functions file for the 'Daemon'.".$GLOBALS['COLORS']['WHITE'], $verbose, "CLI"); 

//Before running you will need to edit the config.ini file

$This_is_me = getmypid();

//Now we need to write the PID file so that the init.d file can control it.
if (PHP_OS == "WINNT")
{$pid_file = $GLOBALS['wifidb_tools'].'/daemon/wifidbd.pid';}
else{$pid_file = '/var/run/wifidbd.pid';}
fopen($pid_file, "w");
$fileappend = fopen($pid_file, "a");
$write_pid = fwrite($fileappend, "$This_is_me");
if(!$write_pid){die($GLOBALS['COLORS']['RED']."Could not write pid file, thats not good... :[".$GLOBALS['COLORS']['WHITE']);}
logd("Have writen the PID file at /var/run/wifidbd.pid (".$This_is_me.")", $log_interval,0 ,  $GLOBALS['log_level']);
verbosed($GLOBALS['COLORS']['GREEN']."PID Writen ".$This_is_me.$GLOBALS['COLORS']['WHITE'], $verbose, "CLI"); 

#	if($time_interval_to_check < '300'){$time_interval_to_check = '300';} //its really pointless to check more then 5 min at a time, becuse if it is 
																  //importing something it is probably going to take more then that to imort the file
$finished = 0;
//Main loop
$database = new database;
while(1) //while my pid file is still in the /var/run/ folder i will still run, this is for the init.d script or crash override
{
	$time  = time()+$DST;
	$time+=$time_interval_to_check;
	$nextrun = date("Y-m-d H:i:s", $time);
	$RUNresult = mysql_query("SELECT `id` FROM `$db`.`$settings_tb` WHERE `table` LIKE 'files'", $conn);
	$next_run_id = mysql_fetch_array($RUNresult);
	$IDDD = $next_run_id['id'];
	if($IDDD != '')
	{
		$sqlup = "UPDATE `$db`.`$settings_tb` SET `size` = '$nextrun' WHERE `id` = '$IDDD'";
		if (mysql_query($sqlup, $conn))
		{
			logd("Updated settings table with next run time: ".$nextrun, $log_interval, 0,  $GLOBALS['log_level']);
			verbosed($GLOBALS['COLORS']['GREEN']."Updated settings table with next run time: ".$nextrun.$GLOBALS['COLORS']['WHITE'], $verbose, "CLI");
		}else
		{
			logd("ERROR!! COULD NOT Update settings table with next run time: ".$nextrun, $log_interval, 0,  $GLOBALS['log_level']);
			verbosed($GLOBALS['COLORS']['RED']."ERROR!! COULD NOT Update settings table with next run time: ".$nextrun.$GLOBALS['COLORS']['WHITE'], $verbose, "CLI");
		}
	}else
	{
		$NEXTRUNresult = mysql_query("INSERT INTO `$db`.`$settings_tb` (`id`, `table`, `size`) VALUES ( '1', 'files', '$nextrun') ", $conn);
	}
	$result = mysql_query("SELECT * FROM `$db`.`files_tmp` ORDER BY `id` ASC", $conn);
	if($result)//check to see if i can successfully look at the file_tmp folder
	{
		while ($files_array = mysql_fetch_array($result))//got through every row in the table that is returned
		{
			$source = $wifidb_install.'/import/up/'.$files_array['file'];
			$return  = file($source);
			$count = count($return);
			if(!($count <= 8))//make sure there is at least a valid file in the field
			{
				verbosed("Hey look! a valid file waiting to be imported.", $verbose, "CLI");
				$check = $database->check_file($source);//check to see if this file has aleady been imported into the DB
				if($check == 1)
				{
					$user = escapeshellarg($files_array['user']);//clean up Users Var
					$notes = escapeshellarg($files_array['notes']);//clean up notes var
					$title = escapeshellarg($files_array['title']);//clean up title var
					
					$details = "User=> $user , Notes=> $notes , Title=> $title ";//put them all in an `array`
					
					logd("Start Import of :".$files_array['file'], 2, $details,  $GLOBALS['log_level']); //write the details array to the log if the level is 2 /this one is hard coded, beuase i wanted to show an example.
					verbosed("Start Import of :".$files_array['file'], $verbose, "CLI"); //default verbise is 0 or none, or STFU, IE dont do shit.
					
					$tmp = $database->import_vs1($source, $files_array['user'], $files_array['notes'], $files_array['title'], $verbose);
					$temp = $files_array['file']." | ".$tmp['aps']." - ".$tmp['gps'];
					logd("Finished Import of : ".$files_array['file'] , 2 , $temp ,  $GLOBALS['log_level']); //same thing here, hard coded as log_lev 2
					verbosed("Finished Import of :".$files_array['file'] , $verbose, "CLI");
					$remove_file = $files_array['id'];
					
					$hash = hash_file('md5', $source);
					$result1 = mysql_query("SELECT * FROM `$db`.`users` WHERE `hash` LIKE '$hash' LIMIT 1", $conn);
					$user_array = mysql_fetch_array($result1);
					$user_row = $user_array['id'];
					echo "\n";
					$inserted_new_file = $database->insert_file($source, $tmp['aps'], $tmp['gps'],$files_array['user'],$files_array['notes'],$files_array['title'], $user_row );
					if($inserted_new_file == 1)
					{
						logd("Added ".$remove_file." to the Files table", $log_interval, 0,  $GLOBALS['log_level']);
						verbosed($GLOBALS['COLORS']['GREEN']."Added ".$remove_file." to the Files table".$GLOBALS['COLORS']['WHITE'], 1, "CLI");
						
						$del_file_tmp = "DELETE FROM `$db`.`files_tmp` WHERE `id` = '$remove_file'";
						if(!mysql_query($del_file_tmp, $GLOBALS['conn']))
						{
							logd("Error removing ".$remove_file." from the Temp files table\r\n\t".mysql_error($GLOBALS['conn']), $log_interval, 0,  $GLOBALS['log_level']);
							verbosed($GLOBALS['COLORS']['RED']."Error removing ".$remove_file." from the Temp files table\n\t".mysql_error($GLOBALS['conn']).$GLOBALS['COLORS']['WHITE'], 1);
						}else
						{
							logd("Removed ".$remove_file." from the Temp files table.", $log_interval, 0,  $GLOBALS['log_level']);
							verbosed($GLOBALS['COLORS']['GREEN']."Removed ".$remove_file." from the Temp files table.".$GLOBALS['COLORS']['WHITE'], $verbose, "CLI");
						}
					}else
					{
						logd("Error Adding ".$remove_file." to the Files table\r\n\t".mysql_error($GLOBALS['conn']), $log_interval, 0,  $GLOBALS['log_level']);
						verbosed($GLOBALS['COLORS']['RED']."Error Adding ".$remove_file." to the Files table\n\t".mysql_error($GLOBALS['conn']).$GLOBALS['COLORS']['WHITE'],1, "CLI");
					}
					$finished = 1;
				}else
				{
					logd("File has already been successfully imported into the Database, skipping.\r\n\t\t\t".$files_array['file'], $log_interval, 0,  $GLOBALS['log_level']);
					verbosed($GLOBALS['COLORS']['YELLOW']."File has already been successfully imported into the Database, skipping.\r\n\t\t\t".$files_array['file'].$GLOBALS['COLORS']['WHITE'], $verbose, "CLI");
					
					$remove_file = $files_array['id'];
					$del_file_tmp = "DELETE FROM `$db`.`files_tmp` WHERE `id` = '$remove_file'";
					if(!mysql_query($del_file_tmp, $GLOBALS['conn']))
					{
						logd("Error removing ".$remove_file." from the Temp files table\r\n\t".mysql_error($GLOBALS['conn']), $log_interval, 0,  $GLOBALS['log_level']);
						verbosed($GLOBALS['COLORS']['RED']."Error removing ".$remove_file." from the Temp files table\r\n\t".mysql_error($GLOBALS['conn']).$GLOBALS['COLORS']['WHITE'], 1, "CLI");
					}else
					{
						logd("Removed ".$remove_file." from the Temp files table and added it to the Imported Files table.", $log_interval, 0,  $GLOBALS['log_level']);
						verbosed($GLOBALS['COLORS']['RED']."Removed ".$remove_file." from the Temp files table and added it to the Imported Files table.".$GLOBALS['COLORS']['WHITE'], $verbose, "CLI");
					}
				}
			}else
			{
				$finished = 0;
				logd("File is empty, go and import something.\n", $log_interval, 0,  $GLOBALS['log_level']);
				verbosed($GLOBALS['COLORS']['YELLOW']."File is empty, go and import something.\n".$GLOBALS['COLORS']['WHITE'], $verbose);
				$remove_file = $files_array['id'];
				$del_file_tmp = "DELETE FROM `$db`.`files_tmp` WHERE `id` = '$remove_file'";
				if(!mysql_query($del_file_tmp, $GLOBALS['conn']))
				{
					logd("Error removing ".$remove_file." from the Temp files table\r\n\t".mysql_error($GLOBALS['conn']), $log_interval, 0,  $GLOBALS['log_level']);
					verbosed($GLOBALS['COLORS']['RED']."Error removing ".$remove_file." from the Temp files table\r\n\t".mysql_error($GLOBALS['conn']).$GLOBALS['COLORS']['WHITE'], 1, "CLI");
				}else
				{
					logd("Removed empty ".$remove_file." from the Temp files table.", $log_interval, 0,  $GLOBALS['log_level']);
					verbosed($GLOBALS['COLORS']['GREEN']."Removed empty ".$remove_file." from the Temp files table.".$GLOBALS['COLORS']['WHITE'], $verbose, "CLI");
				}
			}
		#	$result = mysql_query("SELECT * FROM `$db`.`files_tmp` ORDER BY `id` ASC", $conn);//requery after a file import to make sure that no one has imported something while im importing APS, so that they can be imported sooner then waiting another sleep loop to get imported.
			echo "\n";
		}
	}else
	{
		logd("There was an error trying to look into the files_tmp table.\r\n\t".mysql_error($conn), $log_interval, 0,  $GLOBALS['log_level']);
		verbosed($GLOBALS['COLORS']['RED']."There was an error trying to look into the files_tmp table.\r\n\t".mysql_error($conn).$GLOBALS['COLORS']['WHITE'], $verbose, "CLI");
	}
	if($finished == 0)
	{$message = "File tmp table is empty, go and import something. While your doing that I'm going to sleep for ".($time_interval_to_check/60)." minuets.\n";}
	else{$message = "Finished Import of all files in table, go and import something else. While your doing that I'm going to sleep for ".($time_interval_to_check/60)." minuets.\n";}
	
	logd($message, $log_interval, 0,  $GLOBALS['log_level']);
	verbosed($GLOBALS['COLORS']['YELLOW'].$message.$GLOBALS['COLORS']['WHITE'], $verbose, "CLI");
	$finished = 0;
	$sqlup2 = "UPDATE `$db`.`$settings_tb` SET `size` = '$nextrun' WHERE `id` = '$IDDD'";
	if (mysql_query($sqlup2, $conn))
	{
		logd("Updated settings table with next run time: ".$nextrun, $log_interval, 0,  $GLOBALS['log_level']);
		verbosed($GLOBALS['COLORS']['GREEN']."Updated settings table with next run time: ".$nextrun.$GLOBALS['COLORS']['WHITE'], $verbose, "CLI");
	}else
	{
		logd("ERROR!! COULD NOT Update settings table with next run time: ".$nextrun, $log_interval, 0,  $GLOBALS['log_level']);
		verbosed($GLOBALS['COLORS']['RED']."ERROR!! COULD NOT Update settings table with next run time: ".$nextrun.$GLOBALS['COLORS']['WHITE'], $verbose, "CLI");
	}
	sleep($time_interval_to_check);
}
?>