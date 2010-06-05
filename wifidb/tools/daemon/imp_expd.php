<?php
//Now this is not what I would call a 'true' 'daemon' by any sorts,
//I mean it does have a php script (/tools/rund.php) that can turn 
//the daemon on and off. But it is a php script that is running 
//perpetually in the background. I dont think this is how php was 
//intended to be used. I am hoping to get a C++ version working 
//sometime soon, untill then I am using php.
#error_reporting(E_ALL|E_STRICT);
global $screen_output, $dim, $COLORS, $daemon_ver;
$screen_output = "CLI";
error_reporting(E_ALL|E_STRICT);
if(!(require_once 'config.inc.php')){die("You need to create and configure your config.inc.php file in the [tools dir]/daemon/config.inc.php");}
if($GLOBALS['wifidb_install'] == ""){die("You need to edit your daemon config file first in: [tools dir]/daemon/config.inc.php");}
require_once $GLOBALS['wifidb_install']."/lib/database.inc.php";
require_once $GLOBALS['wifidb_install']."/lib/config.inc.php";
if(PHP_OS == "WINNT"){$dim = "\\";}else{$dim = "/";}


date_default_timezone_set("UTC");
ini_set("memory_limit","3072M"); //lots of GPS cords need lots of memory
#error_reporting(E_ALL); //show all erorrs with strict santex, come on now, we want to know whats going on

$conn					= 	$GLOBALS['conn'];
$db						= 	$GLOBALS['db'];
$db_st					= 	$GLOBALS['db_st'];
$wtable					=	$GLOBALS['wtable'];
$users_t				=	$GLOBALS['users_t'];
$gps_ext				=	$GLOBALS['gps_ext'];
$files					=	$GLOBALS['files'];
$files_tmp				=	$GLOBALS['files_tmp'];
$user_logins_table		=	$GLOBALS['user_logins_table'];
$settings_tb			=	$GLOBALS['settings_tb'];
$console_log			=	$GLOBALS['daemon_log_folder'].'imp_expd.log';
$pid_file				=	$GLOBALS['pid_file_loc'].'imp_expd.pid';
$console_line_limit		=	$GLOBALS['console_line_limit'];
$time_interval_to_check =	$GLOBALS['time_interval_to_check'];
$root					=	$GLOBALS['root'];
$half_path				=	$GLOBALS['half_path'];
$host_url 				=	$GLOBALS['host_url'];
$UPATH	 				=	$GLOBALS['UPATH'];
$console_trim_log		=	$GLOBALS['console_trim_log'];
$console_line_limit		=	$GLOBALS['console_line_limit'];
$date_format			=	"Y-m-d H:i:s.u";
$BAD_IED_COLOR			=	$GLOBALS['BAD_IED_COLOR'];
$GOOD_IED_COLOR			=	$GLOBALS['GOOD_IED_COLOR'];
$OTHER_IED_COLOR		=	$GLOBALS['OTHER_IED_COLOR'];
$This_is_me				=	getmypid();
$PHP_OS					=	PHP_OS;
$OS						=	$PHP_OS[0];

if($GLOBALS['colors_setting'] == 0 or $OS == "W")
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

//Now we need to write the PID file so that the init.d file can control it.
fopen($pid_file, "w");
$fileappend = fopen($pid_file, "a");
$write_pid = fwrite($fileappend, "$This_is_me");
if(!$write_pid){die($GLOBALS['COLORS'][$BAD_IED_COLOR]."Could not write pid file, thats not good... >:[".$GLOBALS['COLORS'][$OTHER_IED_COLOR]);}
logd("Have writen the PID file at ".$pid_file." (".$This_is_me.")", $log_interval,0 ,  $GLOBALS['log_level']);
verbosed($GLOBALS['COLORS'][$GOOD_IED_COLOR]."Have writen the PID file at ".$pid_file." (".$This_is_me.")".$GLOBALS['COLORS'][$OTHER_IED_COLOR], $verbose, $screen_output, 1); 

if($GLOBALS['log_level'] == 0){$de = "Off";}
elseif($GLOBALS['log_level'] == 1){$de = "Errors";}
elseif($GLOBALS['log_level'] == 2){$de = "Detailed Errors (when available)";}

verbosed($GLOBALS['COLORS'][$GOOD_IED_COLOR]."
WiFiDB 'Import/Export Daemon'
Version: 2.0.0
 - Daemon Start: 2009-April-23
 - Last Daemon File Edit: 2010-01-08
 \t(/tools/daemon/imp_expd.php)
 - By: Phillip Ferland ( pferland@randomintervals.com )
 - http://www.randomintervals.com

PID: [ $This_is_me ]
 Log Level is: ".$GLOBALS['log_level']." (".$de.")".$GLOBALS['COLORS'][$OTHER_IED_COLOR], $verbose, $screen_output, 0);

if($log_level != 0)
{
	if($GLOBALS['log_interval'] == 0){$de = "One File 'log/wifidbd_log.log'";}
	elseif($GLOBALS['log_interval'] == 1){$de = "one file a day 'log/wifidbd_log_[yyyy-mm-dd].log'";}
	verbosed($GLOBALS['COLORS'][$GOOD_IED_COLOR]."Log Interval is: ".$GLOBALS['log_interval']." (".$de.")".$GLOBALS['COLORS'][$OTHER_IED_COLOR], $verbose, $screen_output, 1);
}
if($time_interval_to_check < '30'){$time_interval_to_check = '30';} //its really pointless to check more then 5 min at a time, becuse if it is 
																	//importing something it is probably going to take more then that to imort the file
																	
$finished = 0;
//Main loop

$database	=	new database;
$daemon		=	new daemon;

while(1) //while my pid file is still in the /var/run/ folder i will still run, this is for the init.d script or crash override
{
	$console_log_moved = $GLOBALS['wifidb_tools']."/backups/logs/console_wifidbd_".date('Y-m-d H:i:s').".log";
	$console_log = $console_log."/imp_expd.log"; 
	
	if(@file_exists($console_log))
	{
		$console_log_array = file($console_log);
	}
	else
	{
		$fp = fopen($console_log, 'w');
		fwrite($fp, '');
		$console_log_array = file($console_log);
		
		verbosed($GLOBALS['COLORS'][$OTHER_IED_COLOR]."Wrote placer Log File because it didnt exist.".$GLOBALS['COLORS'][$OTHER_IED_COLOR], $verbose, $screen_output, 1);
	}
	
	$console_lines = count($console_log_array);
	verbosed($GLOBALS['COLORS'][$OTHER_IED_COLOR]."File: ".$console_log." ".$console_lines." limit: ".$console_line_limit.$GLOBALS['COLORS'][$OTHER_IED_COLOR], $verbose, $screen_output, 1);
	if($console_trim_log)
	{
		if($console_lines > $console_line_limit)
		{
			if(copy($console_log, $console_log_moved))
			{
				if(!popen("php ".$GLOBALS['wifidb_tools']."/rund.php restart", "w"))
				{
					mail_users("Daemon_could_not_restart", 1, 1);
				}
			}
		}
	}
	$RUN_SQL = "SELECT `id` FROM `$db`.`$settings_tb` WHERE `table` = 'files'";
	$RUNresult = mysql_query($RUN_SQL, $conn);
	$next_run_id = mysql_fetch_array($RUNresult);
	$NR_ID = $next_run_id['id'];
	$nextrun = date("Y-m-d H:i:s", (time()+$time_interval_to_check));
	$daemon_sql = "SELECT * FROM `$db`.`$files_tmp` ORDER BY `id` ASC";
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
				verbosed("Hey look! a valid file waiting to be imported, lets import it.", $verbose, $screen_output, 1);
				//check to see if this file has aleady been imported into the DB
				$hash_Ce = hash_file('md5', $source);
				
				$file_exp = explode($GLOBALS['dim'], $source);
				$file_exp_seg = count($file_exp);
				$file1 = $file_exp[$file_exp_seg-1];
				
				$sql_check = "SELECT * FROM `$db`.`$files` WHERE `hash` LIKE '$hash_Ce'";
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
					verbosed("Start Import of : (".$files_array['id'].") ".$files_array['file'], $verbose, $screen_output, 1); //default verbise is 0 or none, or STFU, IE dont do shit.
					
					$tmp = $database->import_vs1($source, $files_array['user'], $files_array['notes'], $files_array['title'], $verbose, $screen_output, 1);
					$temp = $files_array['file']." | ".$tmp['aps']." - ".$tmp['gps'];
					logd("Finished Import of : ".$files_array['file'] , 2 , $temp ,  $GLOBALS['log_level']); //same thing here, hard coded as log_lev 2
					verbosed("Finished Import of :".$files_array['file'] , $verbose, $screen_output);
					$remove_file = $files_array['id'];
					
					$hash = hash_file('md5', $source);
					$result1 = mysql_query("SELECT * FROM `$db`.`$users_t` WHERE `hash`='$hash' LIMIT 1", $conn);
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
					
					$sql_insert_file = "INSERT INTO `$db`.`$files` (`id`, `file`, `date`, `size`, `aps`, `gps`, `hash`, `user_row`, `user`, `notes`, `title`) VALUES ('', '$file1', '$date', '$size', '$totalaps', '$totalgps', '$hash', '$user_row', '$user', '$notes', '$title')";
					if(mysql_query($sql_insert_file, $conn))
					{
						logd("Added $source ($remove_file) to the Files table", $log_interval, 0,  $GLOBALS['log_level']);
						verbosed($GLOBALS['COLORS'][$GOOD_IED_COLOR]."Added $source ($remove_file) to the Files table.\n".$GLOBALS['COLORS'][$OTHER_IED_COLOR], 1, $screen_output, 1);
						$del_file_tmp = "DELETE FROM `$db`.`files_tmp` WHERE `id` = '$remove_file'";
						if(!mysql_query($del_file_tmp, $GLOBALS['conn']))
						{
							mail_users("Error removing file: $source ($remove_file)", 0, 1);
							logd("Error removing $source ($remove_file) from the Temp files table\r\n\t".mysql_error($GLOBALS['conn']), $log_interval, 0,  $GLOBALS['log_level']);
							verbosed($GLOBALS['COLORS'][$BAD_IED_COLOR]."Error removing $source ($remove_file) from the Temp files table\n\t".mysql_error($GLOBALS['conn']).$GLOBALS['COLORS'][$OTHER_IED_COLOR], 1, $screen_output, 1);
						}else
						{
							$sel_new = "SELECT `id` FROM `$db`.`$files` ORDER BY `id` DESC";
							$res_new = mysql_query($sel_new, $conn);
							$new_array = mysql_fetch_array($res_new);
							$newrow = $new_array['id'];
							$message = "File has finished importing.\r\nUser: $user\r\nTitle: $title\r\nFile: $source ($remove_file)\r\nLink: ".$UPATH."opt/userstats.php?func=useraplist&row=$newrow \r\n-WiFiDB Daemon.";
							mail_users($message, 0, 0);   # http://192.168.1.27/opt/userstats.php?func=useraplist&row=645
							logd("Removed $source ($remove_file) from the Temp files table.", $log_interval, 0,  $GLOBALS['log_level']);
							verbosed($GLOBALS['COLORS'][$GOOD_IED_COLOR]."Removed ".$remove_file." from the Temp files table.\n".$GLOBALS['COLORS'][$OTHER_IED_COLOR], $verbose, $screen_output, 1);
						}
					}else
					{
						mail_users("Error Adding file to finished table: ".$source, 0, 1);
						logd("Error Adding $source ($remove_file) to the Files table\r\n\t".mysql_error($GLOBALS['conn']), $log_interval, 0,  $GLOBALS['log_level']);
						verbosed($GLOBALS['COLORS'][$BAD_IED_COLOR]."Error Adding $source ($remove_file) to the Files table\n\t".mysql_error($GLOBALS['conn']).$GLOBALS['COLORS'][$OTHER_IED_COLOR],1, $screen_output, 1);
					}
					$finished = 1;
				}else
				{
					logd("File has already been successfully imported into the Database, skipping.\r\n\t\t\t$source ($remove_file)", $log_interval, 0,  $GLOBALS['log_level']);
					verbosed($GLOBALS['COLORS']['YELLOW']."File has already been successfully imported into the Database, skipping.\r\n\t\t\t$source ($remove_file)".$GLOBALS['COLORS'][$OTHER_IED_COLOR], $verbose, $screen_output, 1);
					
					$remove_file = $files_array['id'];
					$del_file_tmp = "DELETE FROM `$db`.`files_tmp` WHERE `id` = '$remove_file'";
					if(!mysql_query($del_file_tmp, $GLOBALS['conn']))
					{
						mail_users("_error_removing_file_tmp:".$remove_file, 1, 1);
						logd("Error removing ".$remove_file." from the Temp files table\r\n\t".mysql_error($GLOBALS['conn']), $log_interval, 0,  $GLOBALS['log_level']);
						verbosed($GLOBALS['COLORS'][$BAD_IED_COLOR]."Error removing ".$remove_file." from the Temp files table\r\n\t".mysql_error($GLOBALS['conn']).$GLOBALS['COLORS'][$OTHER_IED_COLOR], 1, $screen_output, 1);
					}else
					{
						logd("Removed ".$remove_file." from the Temp files table and added it to the Imported Files table.", $log_interval, 0,  $GLOBALS['log_level']);
						verbosed($GLOBALS['COLORS']['YELLOW']."Removed ".$remove_file." from the Temp files table and added it to the Imported Files table.\n".$GLOBALS['COLORS'][$OTHER_IED_COLOR], $verbose, $screen_output, 1);
					}
				}
			}else
			{
				$finished = 0;
				logd("File is empty or not valid, go and import something.\n", $log_interval, 0,  $GLOBALS['log_level']);
				verbosed($GLOBALS['COLORS']['YELLOW']."File is empty, go and import something.\n".$GLOBALS['COLORS'][$OTHER_IED_COLOR], $verbose);
				$remove_file = $files_array['id'];
				$del_file_tmp = "DELETE FROM `$db`.`$files_tmp` WHERE `id` = '$remove_file'";
				if(!mysql_query($del_file_tmp, $GLOBALS['conn']))
				{
					mail_users("_error_removing_file_tmp:".$remove_file, 1, 1);
					logd("Error removing ".$remove_file." from the Temp files table\r\n\t".mysql_error($GLOBALS['conn']), $log_interval, 0,  $GLOBALS['log_level']);
					verbosed($GLOBALS['COLORS'][$BAD_IED_COLOR]."Error removing ".$remove_file." from the Temp files table\r\n\t".mysql_error($GLOBALS['conn']).$GLOBALS['COLORS'][$OTHER_IED_COLOR]."\n", 1, $screen_output, 1);
				}else
				{
					logd("Removed empty ".$remove_file." from the Temp files table.", $log_interval, 0,  $GLOBALS['log_level']);
					verbosed($GLOBALS['COLORS'][$GOOD_IED_COLOR]."Removed empty ".$remove_file." from the Temp files table.\n".$GLOBALS['COLORS'][$OTHER_IED_COLOR], $verbose, $screen_output, 1);
				}
			}
		}
		if($finished == 0)
		{
			
			$message = "File tmp table is empty, go and import something. While your doing that I'm going to sleep for ".($time_interval_to_check/60)." minutes.";
		}
		else
		{
			$result1 = mysql_query($daemon_sql, $conn);   //re-query after a file import to make sure that no one has imported something while im importing APS, so that they can be imported sooner then waiting another sleep loop to get imported.
			$files_arra = mysql_fetch_array($result1);
			if($files_arra['id'] != ''){continue;}
			
			$message = "Finished Import of all files in table, go and import something else. While your doing that I'm going to sleep for ".($time_interval_to_check/60)." minutes.";
			logd("Starting Automated KML Export.", $log_interval, 0,  $GLOBALS['log_level']);
			verbosed($GLOBALS['COLORS'][$GOOD_IED_COLOR]."Starting Automated KML Export.".$GLOBALS['COLORS'][$OTHER_IED_COLOR], $verbose, $screen_output, 1);
			daemon::daemon_kml($named = 0, $verbose);
		}
		
		$nextrun = date("Y-m-d H:i:s", (time()+$time_interval_to_check));
		$sqlup2 = "UPDATE `$db`.`$settings_tb` SET `size` = '$nextrun' WHERE `id` = '$NR_ID'";
		if (mysql_query($sqlup2, $conn))
		{
			logd("Updated settings table with next run time: ".$nextrun, $log_interval, 0,  $GLOBALS['log_level']);
			verbosed($GLOBALS['COLORS'][$GOOD_IED_COLOR]."Updated settings table with next run time: ".$nextrun.$GLOBALS['COLORS'][$OTHER_IED_COLOR], $verbose, $screen_output, 1);
		}else
		{
			mail_users("_error_updating_settings_table:".$remove_file, 1, 1);
			logd("ERROR!! COULD NOT Update settings table with next run time: ".$nextrun, $log_interval, 0,  $GLOBALS['log_level']);
			verbosed($GLOBALS['COLORS'][$BAD_IED_COLOR]."ERROR!! COULD NOT Update settings table with next run time: ".$nextrun.$GLOBALS['COLORS'][$OTHER_IED_COLOR], $verbose, $screen_output, 1);
		}
		$finished = 0;
		logd($message, $log_interval, 0,  $GLOBALS['log_level']);
		verbosed($GLOBALS['COLORS']['YELLOW'].$message.$GLOBALS['COLORS'][$OTHER_IED_COLOR], $verbose, $screen_output, 1);
	}else
	{
		mail_users("_error_looking_for_files:", 1, 1);
		logd("There was an error trying to look into the files_tmp table.\r\n\t".mysql_error($conn), $log_interval, 0,  $GLOBALS['log_level']);
		verbosed($GLOBALS['COLORS'][$BAD_IED_COLOR]."There was an error trying to look into the files_tmp table.\r\n\t".mysql_error($conn).$GLOBALS['COLORS'][$OTHER_IED_COLOR], $verbose, $screen_output, 1);
		die();
	}
	sleep($time_interval_to_check);
}
?>