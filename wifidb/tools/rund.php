<?php
$ver  = "1.1";
error_reporting (E_STRICT | E_ALL);
require('daemon/config.inc.php');
global $pid_file;
#echo $GLOBALS['wifidb_tools']."\n";
if ($_SERVER['OS'] == "Windows_NT")
{$pid_file = $GLOBALS['wifidb_tools'].'/daemon/wifidbd.pid';}
else{$pid_file = '/var/run/wifidbd.pid';}

#	if($_SERVER['OS'] == "Windows_NT"){die("The Daemon will only run on a Linux based OS, go get something better then windows");}

//The Daemon is not indened for Windows, it was designed and tested only on Linux (Specifically Debian 5 `Edge`)

if(isset($argv[1])) //parse WiFiDB argument to get value
{
	switch ($argv[1])
	{
		case "restart" :
			if(file_exists($pid_file))
			{
				stop();
				start();
			}else
			{
				echo "WiFiDB Daemon was not running..\n";
				start();
			}
			break;
		
		case "stop" :
			stop();
			break;
			
		case "start" :
			start();
			break;
	}
}else
{
	echo "You need to specify whether you want to start/restart/stop the WiFiDB Daemon\n";
}
# Start and Stop functions for the daemon

function start()
{
	echo "Starting WiFiDB Daemon..\n";
	if ($_SERVER['OS'] == "Windows_NT")
	{$cmd = "start \"WiFiDB Daemon\" C:\wamp\bin\php\php5.2.9-1\php ".$GLOBALS['wifidb_tools']."/daemon/wifidbd.php";}
	else{$cmd = "php ".$GLOBALS['wifidb_tools']."/daemon/wifidbd.php&";}
	
	echo $cmd."\n";
	if(file_exists($GLOBALS['wifidb_tools']."/daemon/wifidbd.php"))
	{
		$start = popen($cmd, 'r');
		if($start)
		{
			echo "WiFiDB Daemon Started..\n";
		}else
		{
			echo "WiFiDB Daemon Could not start\n".$start;
		}
	}else
	{
		echo "Could not find the WiFiDB Daemon file. [wifidbd.php].\n";
	}
}
function stop()
{
	if(file_exists($GLOBALS['pid_file']))
	{
		echo $GLOBALS['pid_file']."\n";
		$pidfile = file($GLOBALS['pid_file']);
		echo $pidfile[0]."\n";
			
			if ($_SERVER['OS'] == "Windows_NT")
			{$cmd = "taskkill /PID ".$pidfile[0];}
			else{$cmd = "kill -9 ".$pidfile[0];}
			
		$stop = popen($cmd, 'r');
		
		if(!$stop)
		{echo "Error stoping the WiFiDB Daemon..\n";}
		else
		{
			chown($GLOBALS['pid_file'],666);
			unlink($GLOBALS['pid_file']);
		}
	}else
	{
		echo "WiFiDB Daemon was not running..\n";
	}
}
?>