<?php
global $pid_file;
$pid_file = "/var/run/wifidbd.pid";
if($_SERVER['OS'] == "Windows_NT"){die("The Daemon will only run on a Linux based OS, go get something better then windows");}

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



function start()
{
	require('daemon/config.inc.php');
	echo "Starting WiFiDB Daemon..\n";
	$command = "php ".$wifidb_tools."/daemon/wifidbd.php&";
	echo $command."\n";
	$start = popen($command, 'r');
	if($start)
	{
		echo "WiFiDB Daemon Started..\n";
	}else
	{
		echo "WiFiDB Daemon Could not start\n".$start;
	}
}

function stop()
{
	if(file_exists($GLOBALS['pid_file']))
	{
		echo $GLOBALS['pid_file']."\n";
		$pidfile = file($$GLOBALS['pid_file']);
		echo $pidfile[0]."\n";
		$stop = popen("kill -9 ".$pidfile[0], 'r');
		if(!$stop)
		{echo "Error stoping the WiFiDB Daemon..\n";}
		else{unlink($GLOBALS['pid_file']);}
	}else
	{
		echo "WiFiDB Daemon was not running..\n";
	}
}
?>