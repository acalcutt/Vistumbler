<?php
#
# Rund.php for WiFIDB 0.20 Build 1
#
global $screen_output;
$screen_output = "CLI";
error_reporting(E_ALL|E_STRICT);

require('daemon/config.inc.php');

if(PHP_OS == 'WINNT'){$GLOBALS['dim'] = '\\';}
if(PHP_OS == 'Linux'){$GLOBALS['dim'] = '/';}

require_once($GLOBALS['wifidb_install'].$GLOBALS['dim'].'lib'.$GLOBALS['dim'].'config.inc.php');
require_once($GLOBALS['wifidb_install'].$GLOBALS['dim'].'lib'.$GLOBALS['dim'].'database.inc.php');

#echo $GLOBALS['wifidb_tools']."\n";
if(isset($argv[1]))
{$command = $argv[1];}
else
{
	echo "You cannot use start without a switch\r\n\r\n";
	help();
	die();
}
$command = strtolower($command);
$command = substr($command, 0, 4);

if(isset($argv[2]))
{$command1 = $argv[2];}
else
{
	echo "You cannot use start without a switch\r\n\r\n";
	help();
	die();
}
$command1 = strtolower($command1);
$command1 = substr($command1, 0, 3);
#echo "Command : $command\r\nCommand1 : $command1\r\n";
switch ($command)
{
	case "rest" :
		stop($command1);
		start($command1);
		break;
		
	case "stop" :
		stop($command1);
		break;
		
	case "star" :
		start($command1);
		break;
		
	case "vers" :
		ver();
		break;
		
	case "ver" :
		ver();
		break;
		
	case "help" :
		help();
		break;
		
	case "stat" :
		status($command1);
		break;
		
	case 'none':
		echo "You need to specify whether you want to start/restart/stop/help/ver the WiFiDB Daemon\n";
	break;
}

# Start and Stop functions for the daemon

function start($command = '')
{
#	echo $command."\r\n\r\n";
	$daemon_ = '';
	switch($command)
	{
		case 'ied':
	#	echo "alllllll!!!!!!!!\r\n";
			$daemon_ = 'imp_exp';
			break;
		case 'dbs':
	#	echo "alllllll!!!!!!!!\r\n";
			$daemon_ = 'dbstats';
			break;
		case 'dpm':
		#	echo "alllllll!!!!!!!!\r\n";
			$daemon_ = 'daemonperf';
			break;
		case 'all':
		#	echo "alllllll!!!!!!!!\r\n";
			$daemon_ = array(
								0 => 'imp_exp',
								1 => 'dbstats',
								2 => 'daemonperf'
							);
			break;
	}
	require('daemon/config.inc.php');
	require($GLOBALS['wifidb_install'].$GLOBALS['dim'].'lib'.$GLOBALS['dim'].'config.inc.php');
	echo "Starting WiFiDB Daemon..\n";
	
	$is_array = is_array($daemon_);
	if($is_array)
	{
		foreach($daemon_ as $d)
		{
			echo "D: $d \r\n";
			switch($d)
			{
				case 'imp_exp':
					echo "\r\n";
					start('ied');
					break;
				case 'dbstats':
					echo "\r\n";
					start('dbs');
					break;
				case 'daemonperf':
					echo "\r\n";
					start('dpm');
					break;
			}
		}
	}
	
	$console_log = $GLOBALS['daemon_log_folder'].$daemon_.'d.log';
	$daemon_script = $GLOBALS['wifidb_tools'].$GLOBALS['dim']."daemon".$GLOBALS['dim'].$daemon_."d.php";
	echo $daemon_script."\r\n";

	if (PHP_OS == "WINNT")
	{$cmd = "start ".$GLOBALS['php_install']."\php ".$daemon_script." > ".$console_log;}
	else{$cmd = "php ".$daemon_script." > ".$console_log." &";}
	
	#echo $cmd."\n";
	if(file_exists($daemon_script))
	{
		$handle = popen($cmd, 'r');
		if($handle)
		{
			echo "'$handle'; " . gettype($handle) . "\n";
			$read = fread($handle, 2096);
			echo $read;
			sleep(2);
			$pidfile = @file($GLOBALS['pid_file_loc'].'imp_expd.pid');
			if($pidfile)
			{
				$PID =  $pidfile[0];
				echo "WiFiDB Daemon Started... [ $PID ]\r\n";
				return 1;
			}else
			{
				echo "WiFiDB Daemon Failed To Start...\n";
				return 0;
			}
		}else
		{
			echo "WiFiDB Daemon Could not start\nStatus: ".$handle."\n";
			return 0;
		}
	}else
	{
		echo "Could not find the WiFiDB Daemon file. [wifidbd.php].\n";
		return 0;
	}
}

function stop($command = '')
{
	if($command == ''){die("You cannot use start without a switch");}
	if($command == 'ied'){$daemon = 'imp_exp';}
	elseif($command == 'dbs'){$daemon = 'dbstats';}
	elseif($command == 'dbs'){$daemon = 'daemonperf';}
	elseif($command == 'all')
	{
	#############
	#############
	### START OF STOP ALL DAEMONS PORTION
	#############
	#############
		$daemon = 'daemonperf';
		require('daemon/config.inc.php');
		$pid = $GLOBALS['pid_file_loc'].$daemon.'d.pid';
		if(file_exists($pid))
		{
			echo $pid."\n";
			$pidfile = file($pid);
			echo $pidfile[0]."\n";
				
				if (PHP_OS == "WINNT")
				{$cmd = "taskkill /PID ".$pidfile[0];}
				else{$cmd = "kill -9 ".$pidfile[0];}
				
			$stop = popen($cmd, 'r');
			
			if(!$stop)
			{
				echo "Error stoping the $daemon Daemon..\n";
			#	return 0;
			}
			else
			{
				unlink($GLOBALS['pid_file_loc']);
			#	return 1;
			}
		}else
		{
			echo "$daemon Daemon was not running..\n";
		}
		#######################
		$daemon = 'imp_exp';
		require('daemon/config.inc.php');
		$pid = $GLOBALS['pid_file_loc'].$daemon.'d.pid';
		if(file_exists($pid))
		{
			echo $pid."\n";
			$pidfile = file($pid);
			echo $pidfile[0]."\n";
				
				if (PHP_OS == "WINNT")
				{$cmd = "taskkill /PID ".$pidfile[0];}
				else{$cmd = "kill -9 ".$pidfile[0];}
				
			$stop = popen($cmd, 'r');
			
			if(!$stop)
			{
				echo "Error stoping the $daemon Daemon..\n";
			#	return 0;
			}
			else
			{
				unlink($GLOBALS['pid_file_loc']);
			#	return 1;
			}
		}else
		{
			echo "$daemon Daemon was not running..\n";
		}
		#########################
		$daemon = 'dbstats';
		require('daemon/config.inc.php');
		$pid = $GLOBALS['pid_file_loc'].$daemon.'d.pid';
		if(file_exists($pid))
		{
			echo $pid."\n";
			$pidfile = file($pid);
			echo $pidfile[0]."\n";
				
				if (PHP_OS == "WINNT")
				{$cmd = "taskkill /PID ".$pidfile[0];}
				else{$cmd = "kill -9 ".$pidfile[0];}
				
			$stop = popen($cmd, 'r');
			
			if(!$stop)
			{
				echo "Error stoping the $daemon Daemon..\n";
			#	return 0;
			}
			else
			{
				unlink($GLOBALS['pid_file_loc']);
			#	return 1;
			}
		}else
		{
			echo "$daemon Daemon was not running..\n";
		}
	}
	#############
	#############
	### END STOP ALL DAEMONS PORTION
	#############
	#############
	require('daemon/config.inc.php');
	$pid = $GLOBALS['pid_file_loc'].$daemon.'d.pid';
	if(file_exists($pid))
	{
		echo $pid."\n";
		$pidfile = file($pid);
		echo $pidfile[0]."\n";
			
			if (PHP_OS == "WINNT")
			{$cmd = "taskkill /PID ".$pidfile[0];}
			else{$cmd = "kill -9 ".$pidfile[0];}
			
		$stop = popen($cmd, 'r');
		
		if(!$stop)
		{
			echo "Error stoping the $daemon Daemon..\n";
			return 0;
		}
		else
		{
			unlink($GLOBALS['pid_file_loc']);
			return 1;
		}
	}else
	{
		echo "$daemon Daemon was not running..\n";
		return 0;
	}
}

function status($command = '')
{
	if($command == ''){die("You cannot use start without a switch");}
	if($command == 'ied'){$daemon = 'imp_exp';}
	elseif($command == 'dbs'){$daemon = 'dbstats';}
	elseif($command == 'dbs'){$daemon = 'daemonperf';}
	elseif($command == 'all')
	{
		$daemon = 'imp_exp';
		$WFDBD_PID = $GLOBALS['pid_file_loc'].$daemon.'d.pid';
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
					$msg = "Linux $daemon Daemon is running!\n";
				}else
				{
					$msg = "Linux $daemon Daemon is not running!\n";
				}
			}else
			{
				$msg = "Linux $daemon Daemon is not running!\n";
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
					$msg = "Windows $daemon Daemon is running!\n";
				}else
				{
					$msg = "Windows $daemon Daemon is not running!\n";
				}
			}else
			{
				$msg = "Windows $daemon Daemon is not running!\n";
			}
		}else
		{
			$msg = "Unkown OS $daemon Daemon is not running!\n";
		}
		echo $msg;
		########################
		############
		$daemon = 'dbstats';
		$WFDBD_PID = $GLOBALS['pid_file_loc'].$daemon.'d.pid';
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
					$msg = "Linux $daemon Daemon is running!\n";
				}else
				{
					$msg = "Linux $daemon Daemon is not running!\n";
				}
			}else
			{
				$msg = "Linux $daemon Daemon is not running!\n";
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
					$msg = "Windows $daemon Daemon is running!\n";
				}else
				{
					$msg = "Windows $daemon Daemon is not running!\n";
				}
			}else
			{
				$msg = "Windows $daemon Daemon is not running!\n";
			}
		}else
		{
			$msg = "Unkown OS $daemon Daemon is not running!\n";
		}
		echo $msg;
		########################
		#############
		
		$daemon = 'daemonperf';
		$WFDBD_PID = $GLOBALS['pid_file_loc'].$daemon.'d.pid';
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
					$msg = "Linux $daemon Daemon is running!\n";
				}else
				{
					$msg = "Linux $daemon Daemon is not running!\n";
				}
			}else
			{
				$msg = "Linux $daemon Daemon is not running!\n";
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
					$msg = "Windows $daemon Daemon is running!\n";
				}else
				{
					$msg = "Windows $daemon Daemon is not running!\n";
				}
			}else
			{
				$msg = "Windows $daemon Daemon is not running!\n";
			}
		}else
		{
			$msg = "Unkown OS $daemon Daemon is not running!\n";
		}
		echo $msg;
		return 1;
	}
	
	$WFDBD_PID = $GLOBALS['pid_file_loc'].$daemon.'d.pid';
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
				$msg = "Linux $daemon Daemon is running!\n";
			}else
			{
				$msg = "Linux $daemon Daemon is not running!\n";
			}
		}else
		{
			$msg = "Linux $daemon Daemon is not running!\n";
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
				$msg = "Windows $daemon Daemon is running!\n";
			}else
			{
				$msg = "Windows $daemon Daemon is not running!\n";
			}
		}else
		{
			$msg = "Windows $daemon Daemon is not running!\n";
		}
	}else
	{
		$msg = "Unkown OS $daemon Daemon is not running!\n";
	}
	echo $msg;
	return 1;
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
==============================

~~~~~~~~~~~~
~~~~~~~~~~~~
2.0.0
~~~~~~~~~~~~
~~~~~~~~~~~~

1 -> Made two (2) more daemons.
	a> Database Statistics Daemon
		Calculates the daily statistics for the Database for APs, Geocaches, and Users.
	b> Daemon Performance Monitor
		Watches the CPU/Memory usage of the Import / Export daemon (imp_expd.php: the old wifidbd.php)
2 -> wifidbd.php now is the launcher for all three daemons. right now it only starts them, you must use rund.ph to stop them.
==============================\n\n";
	return 1;
}

function help()
{
	$ver_db_core = $GLOBALS['ver']['wifidb'];
	$ver_Last_Core_Edit = $GLOBALS['ver']['Last_Core_Edit'];
	$ver_d = $GLOBALS['ver_d'];
	echo "\n  WiFiDB Daemon for WiFiDB Version: $ver_db_core\n  Last Core edit: $ver_Last_Core_Edit\n  Daemon Version: $ver_d\n\n";
	echo "   There is a file called rund.php that starts/stops/and restarts the daemon. To use
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
  rund.php { start [dbs/dpm/ied/all] | stop [dbs/dpm/ied/all] | restart [dbs/dpm/ied/all] | ver | help }
Examples:
  rund.php start ied
  rund.php stop dbs
  rund.php help
---------------------------------------
  ied  -  Import / Export Daemon
  dbs  -  DataBase Statistics Daemon
  dpm  -  Daemon Performance Monitor
  all  -  All Three Above
---------------------------------------	
  start		-  Start The WiFiDB Daemon.
  stop		-  Stop the WiFiDB Daemon.
  restart	-  Restart the WiFiDB Daemon.
  version	-  The Version History.
  help		-  This dialog.\n\n";
	return 1;
}
?>