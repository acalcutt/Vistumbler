<?php
//Now this is not what i would call a 'true' 'daemon' by any sorts
//I mean it does have an init.d/sh script that can turn it on and off,
//but it is a php script that is running perpetually in the background
//I dont think this is how php was intended to be used. I am hoping to
//get a C++ version working sometime soon, until then I am using php.

require('config.inc.php'); // We need config settings so that the Daemon can actaully run.
require('functions.php');  // Need to include the functions file so that the daemon can do things with its spedcial functions...

$start_date = "2009-04-23";
$last_edit = "2009-05-04";
$ver = "1.1";
verbose("\n\t\t###############----Starting WiFiDB 'Daemon'----###############\n- Version: ".$ver."\n- Last Edit: ".$last_edit."\n- By: Phillip Ferland\n- Site: http://www.randomintervals.com\r", 1);

ini_set("memory_limit","3072M"); // Lots of GPS cords need lots of memory
error_reporting(E_STRICT|E_ALL); // Sshow all erorrs with strict santex

// We need config from the DB itself also so that we can connect to the SQL server.
if(!is_file($wifidb_install."/lib/config.inc.php"))// Need to check if the config file for wifidb exists, if it doesnt we cant do anything now can we.
	{die("You need to have a valid Config file installed to run the WiFiDB 'Daemon'\n");}
require_once($wifidb_install."/lib/config.inc.php");
logd("Have included the WiFiDB installed Config.inc.php file at ".$wifidb_install."/lib/ .", $log_interval, 0,  $log_level);
verbose("Have included the WiFiDB installed Config.inc.php file at ".$wifidb_install."/lib/ .", $verbose); 

logd("Have included the WiFiDB Tools Functions file for the 'Daemon'.", $log_interval, 0,  $log_level);
verbose("Have included the WiFiDB Tools Functions file for the 'Daemon'.", $verbose); 

// Before running you will need to edit the config.ini file
date_default_timezone_set($timezn);
$This_is_me = getmypid();

// Now we need to write the PID file so that the init.d file can control it.
if (!$_SERVER['OS'] == "Windows_NT")
{$pid_file = '/var/run/wifidbd.pid';}
else{$pid_file = $GLOBALS['wifidb_tools'].'/daemon/wifidbd.pid';}
fopen($pid_file, "w");
$fileappend = fopen($pid_file, "a");
$write_pid = fwrite($fileappend, "$This_is_me");
fclose($fileappend);
if(!$write_pid){die("Could not write pid file, thats not good...");}
logd("Have writen the PID file at /var/run/wifidbd.pid (".$This_is_me.")", $log_interval,0 ,  $log_level);
verbose("PID Writen ".$This_is_me, $verbose); 

if($time_interval_to_check < '300'){$time_interval_to_check = '300';} // Its really pointless to check more then 5 min at a time, becuse if it is.
																	  // Importing something it is probably going to take more then that to imort the file.
$daemon = new daemon();
$finished = 0;
//Main loop.
while(1) // While my pid file is still in the /var/run/ folder i will still run, this is for the init.d script or crash override.
{
	$result = mysql_query("SELECT * FROM `$db`.`files_tmp`", $conn);
	if($result)// Check to see if I can successfully look at the file_tmp folder.
	{
		while ($files_array = mysql_fetch_array($result))// Got through every row in the table that is returned
		{
			if($files_array['file'] != "")// Make sure there is atleast somthing in the file field
			{
				verbose("Hey look! a valid file waiting to be imported.", $verbose);
				$source = $wifidb_install.'/import/up/'.$files_array['file'];
				$check = check_file($files_array['file']);// Check to see if this file has aleady been imported into the DB
				if($check === 1)
				{
					$user = escapeshellarg($files_array['user']);// Clean up Users Var
					$notes = escapeshellarg($files_array['notes']);// Clean up notes var
					$title = escapeshellarg($files_array['title']);// Clean up title var
					
					$details = "user=>$user,notes=>$notes,Title=>$title";// pput them all in an array
					
					logd("Start Import of :".$files_array['file'], 2, $details,  $log_level); // Write the details array to the log if the level is 2 /this one is hard coded, beuase i wanted to show an example.
					verbose("Start Import of :".$files_array['file'], $verbose); // Default verbose is 0 or none, or STFU, IE dont do shit.
					
					$tmp = $daemon->import_vs1($source, $files_array['user'], $files_array['notes'], $files_array['title'], $verbose);
					$temp = $files_array['file']." | ".$tmp['aps']." - ".$tmp['gps'];
					logd("Finished Import of : ".$files_array['file'] , 2 , $temp ,  $log_level); // Same thing here, hard coded as log_lev 2
					verbose("Finished Import of :".$files_array['file']."" , $verbose);
					
					$remove_file = $files_array['file'];
					$hash = hash_file('md5', $remove_file); // Get the hash of the file, so we can use this to remove the file that was just uploaded
					$del_file_tmp = "DELETE FROM `wifi`.`files_tmp` WHERE `file` = '$remove_file'";
					if(!mysql_query($sql, $conn))
					{
						logd("Error removing ".$remove_file." from the Temp files table\r\n\t".mysql_error($conn), $log_interval, 0,  $log_level);
						verbose("Error removing ".$remove_file." from the Temp files table\r\n\t".mysql_error($conn), 1);
					}else
					{
						insert_file($files_array['file'], $tmp['aps'], $tmp['gps'],$files_array['user'],$files_array['notes'],$files_array['title'] );
						logd("Removed ".$remove_file." from the Temp files table and added it to the Imported Files table.", $log_interval, 0,  $log_level);
						verbose("Removed ".$remove_file." from the Temp files table and added it to the Imported Files table.");
					}
					$finished = 1;
				}elseif($check === 0)
				{
					logd("File has already been successfully imported into the Database, skipping.\r\n".$files_array['file'], $log_interval, 0,  $log_level);
					verbose("File has already been successfully imported into the Database, skipping.\r\n".$files_array['file'], $verbose);
				}
			}else
			{
				$finished = 0;
				logd("File tmp table is empty, go and import something.", $log_interval, 0,  $log_level);
				verbose("File tmp table is empty, go and import something.", $verbose);
			}
		}
	}else
	{
		logd("There was an error trying to look into the files_tmp table.\r\n\t".mysql_error($conn), $log_interval, 0,  $log_level);
		verbose("There was an error trying to look into the files_tmp table.\r\n\t".mysql_error($conn), $verbose);
	}
	
	if($finished == 0)
	{$message = "File tmp table is empty, going to sleep for ".($time_interval_to_check/60)." minuets.";}
	else{$message = "Finished Import of all files in table, going to sleep for ".($time_interval_to_check/60)." minuets.";}
	
	logd($message, $log_interval, 0,  $log_level);
	verbose($message, 1);
	$finished = 0;
	sleep($time_interval_to_check);
}
?>