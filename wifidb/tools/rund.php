<?php
require('daemon/config.inc.php');
require($GLOBALS['wifidb_install'].'/lib/config.inc.php');
global $pid_file;
#echo $GLOBALS['wifidb_tools']."\n";
if (PHP_OS == "WINNT")
{$pid_file = $GLOBALS['wifidb_tools'].'/daemon/wifidbd.pid';}
else{$pid_file = '/var/run/wifidbd.pid';}
if(isset($argv[1]))
{$command = $argv[1];}
else{$command = "none";}
$command = strtolower($command);
if($command != "none") //parse WiFiDB argument to get value
{
	switch ($command)
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
			
		case "version" :
			ver();
			break;
			
		case "help" :
			help();
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
	if (PHP_OS == "WINNT")
	{$cmd = "start C:\wamp\bin\php\php5.2.9-1\php ".$GLOBALS['wifidb_tools']."/daemon/wifidbd.php";}
	else{$cmd = "php ".$GLOBALS['wifidb_tools']."/daemon/wifidbd.php&";}
	
	echo $cmd."\n";
	if(file_exists($GLOBALS['wifidb_tools']."/daemon/wifidbd.php"))
	{
		$start = popen($cmd, 'w');
		#exec($cmd, $screen_output , $start);
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
		else{unlink($GLOBALS['pid_file']);}
	}else
	{
		echo "WiFiDB Daemon was not running..\n";
	}
}

function ver()
{
}

function help()
{
}
?>