<?php
global $screen_output;
$screen_output = "CLI";
error_reporting(E_ALL|E_STRICT);

require('daemon/config.inc.php');

if(PHP_OS == 'WINNT'){$GLOBALS['dim'] = '\\';}
if(PHP_OS == 'Linux'){$GLOBALS['dim'] = '/';}

require($GLOBALS['wifidb_install'].$GLOBALS['dim'].'lib'.$GLOBALS['dim'].'config.inc.php');
require($GLOBALS['wifidb_install'].$GLOBALS['dim'].'lib'.$GLOBALS['dim'].'database.inc.php');

#echo $GLOBALS['wifidb_tools']."\n";
$console_log = $GLOBALS['wifidb_tools'].$GLOBALS['console_log'];
if(isset($argv[1]))
{$command = $argv[1];}
else{$command = "none";}
$command = strtolower($command);
$command = $command[0].$command[1].$command[2].$command[3];
if($command != "none") //parse WiFiDB argument to get value
{
	switch ($command)
	{
		case "rest" :
			if(file_exists($GLOBALS['pid_file_loc']))
			{
				stop();
				start();
			}else
			{
				
				echo "WiFiDB Daemon was not running..\n".$GLOBALS['pid_file_loc']."\n";
				start();
			}
			break;
			
		case "stop" :
			stop();
			break;
			
		case "star" :
			start();
			break;
			
		case "vers" :
			ver();
			break;
			
		case "help" :
			help();
			break;
			
		case "star" :
			status();
			break;
	}
}else
{
	echo "You need to specify whether you want to start/restart/stop/help/ver the WiFiDB Daemon\n";
}

# Start and Stop functions for the daemon

function start()
{
	require('daemon/config.inc.php');
	echo "Starting WiFiDB Daemon..\n";
	$daemon_script = $GLOBALS['wifidb_tools'].$GLOBALS['dim']."daemon".$GLOBALS['dim']."wifidbd.php";
	if (PHP_OS == "WINNT")
	{$cmd = "start ".$GLOBALS['php_install']."\php ".$daemoon_script." > ".$console_log;}
	else{$cmd = "nohup php ".$daemon_script." > ".$console_log." &";}
	
	echo $cmd."\n";
	if(file_exists($daemon_script))
	{
		$start = popen($cmd, 'w');
		if($start)
		{
			echo "WiFiDB Daemon Started..\n";
		}else
		{
			echo "WiFiDB Daemon Could not start\nStatus: ".$start."\n";
			foreach($screen_output as $line)
			{
				echo $line."\n";
			}
		}
	}else
	{
		echo "Could not find the WiFiDB Daemon file. [wifidbd.php].\n";
	}
}

function stop()
{
	require('daemon/config.inc.php');
	if(file_exists($GLOBALS['pid_file_loc']))
	{
		echo $GLOBALS['pid_file_loc']."\n";
		$pidfile = file($GLOBALS['pid_file_loc']);
		echo $pidfile[0]."\n";
			
			if (PHP_OS == "WINNT")
			{$cmd = "taskkill /PID ".$pidfile[0];}
			else{$cmd = "kill -9 ".$pidfile[0];}
			
		$stop = popen($cmd, 'r');
		
		if(!$stop)
		{echo "Error stoping the WiFiDB Daemon..\n";}
		else{unlink($GLOBALS['pid_file_loc']);}
	}else
	{
		echo "WiFiDB Daemon was not running..\n";
	}
}

function status()
{
	$WFDBD_PID = $GLOBALS['wifidb_tools'].'/daemon/wifidbd.pid';
	$os = PHP_OS;
	if ( $os[0] == 'L')
	{
		#echo $os."<br>";
		$output = array();
		if(file_exists($WFDBD_PID))
		{
			$pid_open = file($WFDBD_PID);
			exec('ps vp '.$pid_open[0] , $output, $sta);
			if(isset($output[1]))
			{
				echo "Linux WiFiDB Daemon is running!\n";
			}else
			{
				echo "Linux WiFiDB Daemon is not running!\n";
			}
		}else
		{
			echo "Linux WiFiDB Daemon is not running!\n";
		}
	}elseif( $os[0] == 'W')
	{
		$output = array();
		if(file_exists($WFDBD_PID))
		{
			$pid_open = file($WFDBD_PID);
			exec('tasklist /V /FI "PID eq '.$pid_open[0].'" /FO CSV' , $output, $sta);
			if(isset($output[2]))
			{
				echo "Windows WiFiDB Daemon is running!\n";
			}else
			{
				echo "Windows WiFiDB Daemon is not running!\n";
			}
		}else
		{
			echo "Windows WiFiDB Daemon is not running!\n";
		}
	}else
	{
		echo "Unkown OS WiFiDB Daemon is not running!\n";
	}
}

function ver()
{
	$ver_db_core = $GLOBALS['ver']['wifidb'];
	$ver_Last_Core_Edit = $GLOBALS['ver']['Last_Core_Edit'];
	$ver_d = $GLOBALS['daemon_ver'];
	echo "\nWiFiDB Daemon for WiFiDB Version: $ver_db_core\nLast Core edit: $ver_Last_Core_Edit\nCurrent Daemon Version: $ver_d\n\n";
	echo "----------------------------------------
----------------------------------------
VERSION HISTORY
----------------------------------------
----------------------------------------

~~~~~~~~~~~~
~~~~~~~~~~~~
1.0
~~~~~~~~~~~~
~~~~~~~~~~~~
1 -> Initial release, just scheduled imports.
==============================

~~~~~~~~~~~~
~~~~~~~~~~~~
1.1
~~~~~~~~~~~~
~~~~~~~~~~~~
1 -> Windows capable, I still wouldn't recommend it, but it works. Although it has a 
	 cmd window of its own, so to stay running it needs to stay open.
2 -> Better intergration with scheduling.php, added in Current AP, Importing? (Yes/No),
	 Current AP/Total APs.
==============================

~~~~~~~~~~~~
~~~~~~~~~~~~
1.2
~~~~~~~~~~~~
~~~~~~~~~~~~
1 -> There was an issue with it sometimes not skipping a file if the hashes matched up.
2 -> Some spelling errors in messages.
3 -> For some reason the rund.php script sometimes would not properly execute the daemon 
	 script, and result in rund.php saying the daemon has started, yet if you did 
	 a ps -ax | grep \"wifidbd\", there would be no daemon running. Changing 
	 popen($"."cmd, 'r') from 'r' to 'w' fixed this.

==============================

~~~~~~~~~~~~
~~~~~~~~~~~~
1.3-1.5
~~~~~~~~~~~~
~~~~~~~~~~~~
1 -> Was a very unstable time for the daemon,
	 documentation wasnt kept and the only truly known changes are 
	 the addition of colors for linux to the output, windows does not support color.
==============================

~~~~~~~~~~~~
~~~~~~~~~~~~
1.6
~~~~~~~~~~~~
~~~~~~~~~~~~
1 -> The daemon was being killed off by a stray die() in the failsafe section
	 for text based files that are no longer supported on import.
==============================

~~~~~~~~~~~~
~~~~~~~~~~~~
1.6.1
~~~~~~~~~~~~
~~~~~~~~~~~~
1 -> Replaced the insert_file() and check_file() functions with their code, 
     was causing random errors with not inserting the file into its table 
	 after an import was finished.
2 -> Check_file was useing the file name to check to see if a file existed 
     in the files table, this was stupid because the file name may not be 
	 even close to the other file and have the same contents. Changed it 
	 so that it looks for the hash of the file.
==============================

~~~~~~~~~~~~
~~~~~~~~~~~~
1.7.0
~~~~~~~~~~~~
~~~~~~~~~~~~

1 -> Fixed a bug where the daemon would have to wait till after a sleep
	 in order to find a file that was inserted into the files_tmp table
	 while it was in the middle of an import.
2 -> Added in Daemon Generated KML exports.
3 -> Daemon now checks if the log file is longer then 500 lines, if so
	 the file is moved to [tools_dir]/backups/logs/console_wifidbd_[date-time].log
4 -> Added a bash script writen by Andrew, was adpated from the 
	 plone startup bash script. Use either wifidbd or wifidbd.sh
==============================\n\n";

}

function help()
{
	$ver_db_core = $GLOBALS['ver']['wifidb'];
	$ver_Last_Core_Edit = $GLOBALS['ver']['Last_Core_Edit'];
	$ver_d = $GLOBALS['ver_d'];
	echo "\n  WiFiDB Daemon for WiFiDB Version: $ver_db_core\n  Last Core edit: $ver_Last_Core_Edit\n  Daemon Version: $ver_d\n\n";
	echo "  There is a file called rund.php that starts/stops/and restarts the daemon. To use
  type 'php rund.php [start,stop,restart]'. This script will only run on linux 
  based systems. Windows is NOT supported. This is also an optional item it is not
  needed at all to run WiFiDB. To turn it on or off in the DB itself go to the 
  config.inc.php in the lib folder of where you have your WiFiDB installed, and 
  change the variable named sched to 0 (off) or 1 (on).

  To change settings for the daemon itself go to the daemon folder inside the tools 
  folder and open the config.inc.php file and change sleep to the number of seconds
  that you want to sleep before checking the files_tmp again, there is a safety so
  you cannot set it less then 5 min.


  Usage: 
	rund.php {start|stop|restart|ver|help}

		start			-	Start The WiFiDB Daemon.

		stop			-	Stop the WiFiDB Daemon.

		restart			-	Restart the WiFiDB Daemon.

		version (NIY)		-	The Version History.

		help (NIY)		-	This dialog.\n\n";
}
?>