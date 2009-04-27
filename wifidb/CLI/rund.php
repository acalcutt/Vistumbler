<?php
$filename = "/var/run/wifidbd.pid";
$CLI_script = $argv[0];

if(isset($argv[1])) //parse WiFiDB argument to get value
{
	$cmd_exp = explode("=",$argv[1]);
	$cmd = $cmd_exp[1];

	switch ($cmd)
	{
		case "restart" :
			if(file_exists($filename))
			{
				stop();
				start();
			}else
			{
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
	echo "Ypu need to specify weather you want to start/restart/stop the WiFiDB Daemon\n";
}

function start()
{
	$filename = "/var/run/wifidbd.pid";
	require 'config.inc.php';
	echo "Starting WiFiDB Daemon..\n";
	$command = "php ".$wifidb_tools."/wifidbd.php&";
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
	$filename = "/var/run/wifidbd.pid";
	require 'config.inc.php';
	if(file_exists($filename))
	{
		echo $filename."\n";
		$pidfile = file($filename);
		echo $pidfile[0]."\n";
		$stop = popen("kill -9 ".$pidfile[0], 'r');
		if(!$stop)
		{echo "Error stoping the WiFiDB Daemon..\n";}
		else{unlink($filename);}
	}else
	{
		echo "WiFiDB Daemon was not running..\n";
	}
}
?>