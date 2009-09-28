<?php
//Now this is not what I would call a 'true' 'daemon' by any sorts,
//I mean it does have a php script (/tools/rund.php) that can turn 
//the daemon on and off. But it is a php script that is running 
//perpetually in the background. I dont think this is how php was 
//intended to be used. I am hoping to get a C++ version working 
//sometime soon, untill then I am using php.
global $screen_output, $dim, $COLORS, $daemon_ver;
$screen_output = "CLI";

if(!(require 'config.inc.php')){die("You need to create and configure your config.inc.php file in the [tools dir]/daemon/config.inc.php");}
if($GLOBALS['wifidb_install'] == ""){die("You need to edit your daemon config file first in: [tools dir]/daemon/config.inc.php");}
require $GLOBALS['wifidb_install']."/lib/database.inc.php";
require $GLOBALS['wifidb_install']."/lib/config.inc.php";

$This_is_me = getmypid();
$PHP_OS = PHP_OS;
$OS = $PHP_OS[0];

date_default_timezone_set("UTC");
ini_set("memory_limit","3072M"); //lots of GPS cords need lots of memory
#error_reporting(E_ALL); //show all erorrs with strict santex, come on now, we want to know whats going on

//Now we need to write the PID file so that the init.d file can control it.
$pid_file = $GLOBALS['pid_file_loc'];
fopen($pid_file, "w");
$fileappend = fopen($pid_file, "a");
$write_pid = fwrite($fileappend, "$This_is_me");
if(!$write_pid){die($GLOBALS['COLORS']['RED']."Could not write pid file, thats not good... >:[".$GLOBALS['COLORS']['LIGHTGRAY']);}
logd("Have writen the PID file at ".$pid_file." (".$This_is_me.")", $log_interval,0 ,  $GLOBALS['log_level']);
verbosed($GLOBALS['COLORS']['GREEN']."Have writen the PID file at ".$pid_file." (".$This_is_me.")".$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output); 

$daemon_ver	= $GLOBALS['daemon_ver'];
$start_date = $GLOBALS['start_date'];
$last_edit = $GLOBALS['last_edit'];
$settings_tb = $GLOBALS['settings_tb'];
$console_log = $GLOBALS['wifidb_tools'].$GLOBALS['console_log'];
$console_line_limit = $GLOBALS['console_line_limit'];

if($OS == "WINNT"){$dim = "\\";}
if($OS == "Linux"){$dim = "/";}

if($GLOBALS['colors_setting'] == 0 or $OS == "W")
{
	$COLORS = array(
					"LIGHTGRAY"	=>"",
					"BLUE"		=>"",
					"GREEN"		=>"",
					"RED"		=>"",
					"YELLOW"	=>""
					);
}else
{
	$COLORS = array(
					"LIGHTGRAY"	=>"\033[0;37m",
					"BLUE"		=>"\033[0;34m",
					"GREEN"		=>"\033[0;32m",
					"RED"		=>"\033[0;31m",
					"YELLOW"	=>"\033[1;33m"
					);
}

if($GLOBALS['log_level'] == 0){$de = "Off";}
elseif($GLOBALS['log_level'] == 1){$de = "Errors";}
elseif($GLOBALS['log_level'] == 2){$de = "Detailed Errors (when available)";}

verbosed($GLOBALS['COLORS']['GREEN']."\nWiFiDB 'Daemon'\nVersion: ".$daemon_ver."\n - Daemon Start: ".$start_date."\n - Last Daemon File Edit: ".$last_edit."\n\t(/tools/daemon/wifidbd.php)\n - By: Phillip Ferland\n - http://www.randomintervals.com\nLog Level is: ".$GLOBALS['log_level']." (".$de.")".$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output,1);

if($log_level != 0)
{
	if($GLOBALS['log_interval'] == 0){$de = "One File 'log/wifidbd_log.log'";}
	elseif($GLOBALS['log_interval'] == 1){$de = "one file a day 'log/wifidbd_log_[yyyy-mm-dd].log'";}
	verbosed($GLOBALS['COLORS']['GREEN']."Log Interval is: ".$GLOBALS['log_interval']." (".$de.")".$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output);
}
#if($time_interval_to_check < '30'){$time_interval_to_check = '30';} //its really pointless to check more then 5 min at a time, becuse if it is 
																	//importing something it is probably going to take more then that to imort the file
																	
$finished = 0;
//Main loop
$database = new database;
$daemon	=	new daemon;
while(1) //while my pid file is still in the /var/run/ folder i will still run, this is for the init.d script or crash override
{
	$console_log_moved = $GLOBALS['wifidb_tools']."/backups/logs/console_wifidbd_".date('Y-m-d H:i:s').".log";
	$console_log_array = file($console_log);
	$console_lines = count($console_log_array);
#	echo "File: ".$console_log." ".$console_lines."\n";
	if($console_lines > $console_line_limit)
	{
		if(copy($console_log, $console_log_moved))
		{
			popen("php rund.php restart", "w");
		}
	}
	
	$RUN_SQL = "SELECT `id` FROM `$db`.`$settings_tb` WHERE `table` = 'files'";
	$RUNresult = mysql_query($RUN_SQL, $conn);
	$next_run_id = mysql_fetch_array($RUNresult);
	$NR_ID = $next_run_id['id'];
	$nextrun = date("Y-m-d H:i:s", (time()+$time_interval_to_check));
	$daemon_sql = "SELECT * FROM `$db`.`files_tmp` ORDER BY `id` ASC";
	$result = mysql_query($daemon_sql, $conn);
	if($result)//check to see if i can successfully look at the file_tmp folder
	{
		while ($files_array = mysql_fetch_array($result))
		{
			$result_update = mysql_query("UPDATE `$db`.`$settings_tb` SET `size` = '$nextrun' WHERE `id` = '$NR_ID'", $conn);
			$source = $GLOBALS['wifidb_install'].'/import/up/'.$files_array['file'];
#			echo $source."\n";
			$return  = file($source);
			$count = count($return);
			$testing_return = explode("|",$return[0]);
			$txt_or_vs1_count = count($testing_return);
			if(!($count <= 8))//make sure there is at least a valid file in the field
			{
				verbosed("Hey look! a valid file waiting to be imported, lets import it.", $verbose, $screen_output);
				//check to see if this file has aleady been imported into the DB
				$hash_Ce = hash_file('md5', $source);
				
				$file_exp = explode($GLOBALS['dim'], $source);
				$file_exp_seg = count($file_exp);
				$file1 = $file_exp[$file_exp_seg-1];
				
				$sql_check = "SELECT * FROM `$db`.`files` WHERE `hash` LIKE '$hash_Ce'";
				$fileq = mysql_query($sql_check, $GLOBALS['conn']);
				$fileqq = mysql_fetch_array($fileq);
#				echo $fileqq['hash']."\n";
				if( $hash_Ce == $fileqq['hash'])
				{
					$check = 0;
				}else
				{
					$check = 1;
				}
#				echo $check."\n";

				if($check == 1)
				{
					$user = escapeshellarg($files_array['user']);//clean up Users Var
					$notes = escapeshellarg($files_array['notes']);//clean up notes var
					$title = escapeshellarg($files_array['title']);//clean up title var
					
					$details = "User=> $user , Notes=> $notes , Title=> $title ";//put them all in an `array`
					
					logd("Start Import of :(".$files_array['id'].") ".$files_array['file'], 2, $details,  $GLOBALS['log_level']); //write the details array to the log if the level is 2 /this one is hard coded, beuase i wanted to show an example.
					verbosed("Start Import of : (".$files_array['id'].") ".$files_array['file'], $verbose, $screen_output); //default verbise is 0 or none, or STFU, IE dont do shit.
					
					$tmp = $database->import_vs1($source, $files_array['user'], $files_array['notes'], $files_array['title'], $verbose);
					$temp = $files_array['file']." | ".$tmp['aps']." - ".$tmp['gps'];
					logd("Finished Import of : ".$files_array['file'] , 2 , $temp ,  $GLOBALS['log_level']); //same thing here, hard coded as log_lev 2
					verbosed("Finished Import of :".$files_array['file'] , $verbose, $screen_output);
					$remove_file = $files_array['id'];
					
					$hash = hash_file('md5', $source);
					$result1 = mysql_query("SELECT * FROM `$db`.`users` WHERE `hash`='$hash' LIMIT 1", $conn);
					$user_array = mysql_fetch_array($result1);
					$user_row = $user_array['id'];
					if($verbose == 1)
					{echo "\n";}
					
					$file = $source;
					$totalaps = $tmp['aps'];
					$totalgps = $tmp['gps'];
					$user = $files_array['user'];
					$notes = $files_array['notes'];
					$title = $files_array['title'];
					$size = (filesize($file)/1024);
					$hash = hash_file('md5', $file);
					$date = date("y-m-d H:i:s");
					
					$sql_insert_file = "INSERT INTO `$db`.`files` (`id`, `file`, `date`, `size`, `aps`, `gps`, `hash`, `user_row`, `user`, `notes`, `title`) VALUES (NULL, '$file1', '$date', '$size', '$totalaps', '$totalgps', '$hash', '$user_row', '$user', '$notes', '$title')";
					if(mysql_query($sql_insert_file, $conn))
					{
						logd("Added ".$remove_file." to the Files table", $log_interval, 0,  $GLOBALS['log_level']);
						verbosed($GLOBALS['COLORS']['GREEN']."Added ".$remove_file." to the Files table.\n".$GLOBALS['COLORS']['LIGHTGRAY'], 1, $screen_output);
						$del_file_tmp = "DELETE FROM `$db`.`files_tmp` WHERE `id` = '$remove_file'";
						if(!mysql_query($del_file_tmp, $GLOBALS['conn']))
						{
							logd("Error removing ".$remove_file." from the Temp files table\r\n\t".mysql_error($GLOBALS['conn']), $log_interval, 0,  $GLOBALS['log_level']);
							verbosed($GLOBALS['COLORS']['RED']."Error removing ".$remove_file." from the Temp files table\n\t".mysql_error($GLOBALS['conn']).$GLOBALS['COLORS']['LIGHTGRAY'], 1);
						}else
						{
							logd("Removed ".$remove_file." from the Temp files table.", $log_interval, 0,  $GLOBALS['log_level']);
							verbosed($GLOBALS['COLORS']['GREEN']."Removed ".$remove_file." from the Temp files table.\n".$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output);
						}
					}else
					{
						logd("Error Adding ".$remove_file." to the Files table\r\n\t".mysql_error($GLOBALS['conn']), $log_interval, 0,  $GLOBALS['log_level']);
						verbosed($GLOBALS['COLORS']['RED']."Error Adding ".$remove_file." to the Files table\n\t".mysql_error($GLOBALS['conn']).$GLOBALS['COLORS']['LIGHTGRAY'],1, $screen_output);
					}
					$finished = 1;
				}else
				{
					logd("File has already been successfully imported into the Database, skipping.\r\n\t\t\t".$files_array['file'], $log_interval, 0,  $GLOBALS['log_level']);
					verbosed($GLOBALS['COLORS']['YELLOW']."File has already been successfully imported into the Database, skipping.\r\n\t\t\t".$files_array['file'].$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output);
					
					$remove_file = $files_array['id'];
					$del_file_tmp = "DELETE FROM `$db`.`files_tmp` WHERE `id` = '$remove_file'";
					if(!mysql_query($del_file_tmp, $GLOBALS['conn']))
					{
						logd("Error removing ".$remove_file." from the Temp files table\r\n\t".mysql_error($GLOBALS['conn']), $log_interval, 0,  $GLOBALS['log_level']);
						verbosed($GLOBALS['COLORS']['RED']."Error removing ".$remove_file." from the Temp files table\r\n\t".mysql_error($GLOBALS['conn']).$GLOBALS['COLORS']['LIGHTGRAY'], 1, $screen_output);
					}else
					{
						logd("Removed ".$remove_file." from the Temp files table and added it to the Imported Files table.", $log_interval, 0,  $GLOBALS['log_level']);
						verbosed($GLOBALS['COLORS']['YELLOW']."Removed ".$remove_file." from the Temp files table and added it to the Imported Files table.\n".$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output);
					}
				}
			}else
			{
				$finished = 0;
				logd("File is empty or not valid, go and import something.\n", $log_interval, 0,  $GLOBALS['log_level']);
				verbosed($GLOBALS['COLORS']['YELLOW']."File is empty, go and import something.\n".$GLOBALS['COLORS']['LIGHTGRAY'], $verbose);
				$remove_file = $files_array['id'];
				$del_file_tmp = "DELETE FROM `$db`.`files_tmp` WHERE `id` = '$remove_file'";
				if(!mysql_query($del_file_tmp, $GLOBALS['conn']))
				{
					logd("Error removing ".$remove_file." from the Temp files table\r\n\t".mysql_error($GLOBALS['conn']), $log_interval, 0,  $GLOBALS['log_level']);
					verbosed($GLOBALS['COLORS']['RED']."Error removing ".$remove_file." from the Temp files table\r\n\t".mysql_error($GLOBALS['conn']).$GLOBALS['COLORS']['LIGHTGRAY']."\n", 1, $screen_output);
				}else
				{
					logd("Removed empty ".$remove_file." from the Temp files table.", $log_interval, 0,  $GLOBALS['log_level']);
					verbosed($GLOBALS['COLORS']['GREEN']."Removed empty ".$remove_file." from the Temp files table.\n".$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output);
				}
			}
		}
		if($finished == 0)
		{
			
			$message = "File tmp table is empty, go and import something. While your doing that I'm going to sleep for ".($time_interval_to_check/60)." minuets.";
		}
		else
		{
			$result1 = mysql_query($daemon_sql, $conn);   //re-query after a file import to make sure that no one has imported something while im importing APS, so that they can be imported sooner then waiting another sleep loop to get imported.
			$files_arra = mysql_fetch_array($result1);
			if($files_arra['id'] != ''){continue;}
			
			$message = "Finished Import of all files in table, go and import something else. While your doing that I'm going to sleep for ".($time_interval_to_check/60)." minuets.";
			logd("Starting Automated KML Export.", $log_interval, 0,  $GLOBALS['log_level']);
			verbosed($GLOBALS['COLORS']['GREEN']."Starting Automated KML Export.".$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output);
			daemon::daemon_kml($named = 0, $verbose);
		}
		
	#	$date = date('Y-m-d');
	#	$daily_folder = $GLOBALS['wifidb_install']."/out/daemon/".$date."/";
	#	$temp_kml = $daily_folder.'full_db.kml';
	#	$temp_kml_size =@ dos_filesize($temp_kml);
	#	if(!file_exists($temp_kml))
	#	{
	#		daemon::daemon_kml($named = 0, $verbose);
	#	}
		$nextrun = date("Y-m-d H:i:s", (time()+$time_interval_to_check));
		$sqlup2 = "UPDATE `$db`.`$settings_tb` SET `size` = '$nextrun' WHERE `id` = '$NR_ID'";
		if (mysql_query($sqlup2, $conn))
		{
			logd("Updated settings table with next run time: ".$nextrun, $log_interval, 0,  $GLOBALS['log_level']);
			verbosed($GLOBALS['COLORS']['GREEN']."Updated settings table with next run time: ".$nextrun.$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output);
		}else
		{
			logd("ERROR!! COULD NOT Update settings table with next run time: ".$nextrun, $log_interval, 0,  $GLOBALS['log_level']);
			verbosed($GLOBALS['COLORS']['RED']."ERROR!! COULD NOT Update settings table with next run time: ".$nextrun.$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output);
		}
		$finished = 0;
		logd($message, $log_interval, 0,  $GLOBALS['log_level']);
		verbosed($GLOBALS['COLORS']['YELLOW'].$message.$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output);
		sleep($time_interval_to_check);
	}else
	{
		logd("There was an error trying to look into the files_tmp table.\r\n\t".mysql_error($conn), $log_interval, 0,  $GLOBALS['log_level']);
		verbosed($GLOBALS['COLORS']['RED']."There was an error trying to look into the files_tmp table.\r\n\t".mysql_error($conn).$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output);
	}
}
?>