#!/usr/bin/php
<?php
# Binary for starting daemons
#	0001 = Import / Export Daemon
#	0010 = DB Stats Daemon
#	0100 = Daemon Perfmon
#	1000 = All

error_reporting(E_ALL|E_STRICT);
global $screen_output, $dim, $COLORS, $daemon_ver;
$screen_output = "CLI";

if(!(require_once 'config.inc.php')){die("You need to create and configure your config.inc.php file in the [tools dir]/daemon/config.inc.php");}
if($GLOBALS['wifidb_install'] == ""){die("You need to edit your daemon config file first in: [tools dir]/daemon/config.inc.php");}
require_once $GLOBALS['wifidb_install']."/lib/database.inc.php";
require_once $GLOBALS['wifidb_install']."/lib/config.inc.php";

$This_is_me = getmypid();
$PHP_OS = PHP_OS;
$OS = $PHP_OS[0];
$enable_mail_admin = 0;
date_default_timezone_set("UTC");

$CT_daemon_ver	= "1.0.0";
$CT_start_date = "2009-12-07";
$CT_last_edit = "2009-12-11";

if($OS == "WINNT"){$dim = "\\";}else{$dim = "/";}
$pid_file = $GLOBALS['pid_file_loc'];
if(!file_exists($GLOBALS['pid_file_loc']))
{
	mkdir($GLOBALS['pid_file_loc']);
}

#wait for MySQL to become responsive to the script...
$sql_stat = mysql_stat($conn);
echo $sql_stat."\r\n";
$sql_stat_7 = substr($sql_stat, 0, 6);
echo $sql_stat_7."\r\n";
while($sql_stat_7 != "Uptime")
{
	$sql_stat = mysql_stat($conn);
	$sql_stat_7 = substr($sql_stat, 0, 6);
	#echo $sql_stat_7."\r\n";
}
#check for tables
$sql = "select * from `$db`.`DB_stats`";
$return = mysql_query($sql, $conn);
if(!$return)
{
	$sql1 = "CREATE TABLE `$db`.`DB_stats` (
`id` INT( 255 ) NOT NULL auto_increment,
`timestamp` VARCHAR( 60 ) NOT NULL ,
`graph_min` VARCHAR( 255 ) NOT NULL ,
`graph_max` VARCHAR( 255 ) NOT NULL ,
`graph_avg` VARCHAR( 255 ) NOT NULL ,
`kmz_min` VARCHAR( 255 ) NOT NULL ,
`kmz_max` VARCHAR( 255 ) NOT NULL ,
`kmz_avg` VARCHAR( 255 ) NOT NULL ,
`file_min` VARCHAR( 255 ) NOT NULL ,
`file_max` VARCHAR( 255 ) NOT NULL ,
`file_avg` VARCHAR( 255 ) NOT NULL ,
`total_aps` VARCHAR( 255 ) NOT NULL ,
`wep_aps` VARCHAR( 255 ) NOT NULL ,
`open_aps` VARCHAR( 255 ) NOT NULL ,
`secure_aps` VARCHAR( 255 ) NOT NULL ,
`user` BLOB NOT NULL ,
`ap_gps_totals` BLOB NOT NULL ,
`top_ssids` BLOB NOT NULL ,
`nuap` VARCHAR( 255 ) NOT NULL ,
`geos` BLOB NOT NULL ,
INDEX ( `id` ) ,
UNIQUE (`timestamp`)
) ENGINE = InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1";
	$insert = mysql_query($sql1, $conn) or die(mysql_error($conn));
	if($insert){verbosed($GLOBALS['COLORS']['GREEN']."created DB_Stats table.".$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output, 1);}
	else{verbosed($GLOBALS['COLORS']['RED']."Failed to create DB_Stats table.".mysql_error($conn).$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output, 1);}
}else
{
	$sql = "DROP TABLE `$db`.`DB_stats`";
	$insert = mysql_query($sql, $conn) or die(mysql_error($conn));
	$sql1 = "CREATE TABLE `$db`.`DB_stats` (
`id` INT( 255 ) NOT NULL auto_increment,
`timestamp` VARCHAR( 60 ) NOT NULL ,
`graph_min` VARCHAR( 255 ) NOT NULL ,
`graph_max` VARCHAR( 255 ) NOT NULL ,
`graph_avg` VARCHAR( 255 ) NOT NULL ,
`kmz_min` VARCHAR( 255 ) NOT NULL ,
`kmz_max` VARCHAR( 255 ) NOT NULL ,
`kmz_avg` VARCHAR( 255 ) NOT NULL ,
`file_min` VARCHAR( 255 ) NOT NULL ,
`file_max` VARCHAR( 255 ) NOT NULL ,
`file_avg` VARCHAR( 255 ) NOT NULL ,
`total_aps` VARCHAR( 255 ) NOT NULL ,
`wep_aps` VARCHAR( 255 ) NOT NULL ,
`open_aps` VARCHAR( 255 ) NOT NULL ,
`secure_aps` VARCHAR( 255 ) NOT NULL ,
`user` BLOB NOT NULL ,
`ap_gps_totals` BLOB NOT NULL ,
`top_ssids` BLOB NOT NULL ,
`nuap` VARCHAR( 255 ) NOT NULL ,
`geos` BLOB NOT NULL ,
INDEX ( `id` ) ,
UNIQUE (`timestamp`)
) ENGINE = InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1";
	$insert = mysql_query($sql1, $conn) or die(mysql_error($conn));
	if($insert){verbosed($GLOBALS['COLORS']['GREEN']."created DB_Stats table.".$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output, 1);}
	else{verbosed($GLOBALS['COLORS']['RED']."Failed to create DB_Stats table.".mysql_error($conn).$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output, 1);}
}

$sql = "select * from `$db`.`daemon_perf_mon`";
$return = mysql_query($sql, $conn);
if(!$return)
{
	$sql1 = "CREATE TABLE `$db`.`daemon_perf_mon` (
  `id` int(255) NOT NULL auto_increment,
  `timestamp` datetime NOT NULL,
  `pid` int(255) NOT NULL,
  `uptime` varchar(255) NOT NULL,
  `CMD` varchar(255) NOT NULL,
  `mem` varchar(7) NOT NULL,
  `mesg` varchar(255) NOT NULL,
  UNIQUE KEY `timestamp` (`timestamp`),
  KEY `id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1";
	$insert = mysql_query($sql1, $conn) or die(mysql_error($conn));
	if($insert){verbosed($GLOBALS['COLORS']['GREEN']."created daemon_perf_mon table.".$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output, 1);}
	else{verbosed($GLOBALS['COLORS']['RED']."Failed to create daemon_perf_mon table.".mysql_error($conn).$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output, 1);}
}else
{
	$sql = "DROP TABLE `$db`.`daemon_perf_mon`";
	$insert = mysql_query($sql, $conn) or die(mysql_error($conn));
	$sql1 = "CREATE TABLE `$db`.`daemon_perf_mon` (
  `id` int(255) NOT NULL auto_increment,
  `timestamp` datetime NOT NULL,
  `pid` int(255) NOT NULL,
  `uptime` varchar(255) NOT NULL,
  `CMD` varchar(255) NOT NULL,
  `mem` varchar(7) NOT NULL,
  `mesg` varchar(255) NOT NULL,
  UNIQUE KEY `timestamp` (`timestamp`),
  KEY `id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1";
	$insert = mysql_query($sql1, $conn) or die(mysql_error($conn));
	if($insert){verbosed($GLOBALS['COLORS']['GREEN']."created daemon_perf_mon table.".$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output, 1);}
	else{verbosed($GLOBALS['COLORS']['RED']."Failed to create daemon_perf_mon table.".mysql_error($conn).$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output, 1);}
}

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
verbosed($GLOBALS['COLORS']['GREEN']."
WiFiDB 'Control Daemon'
Version: ".$CT_daemon_ver."
- Daemon Start: ".$CT_start_date."
- Last Daemon File Edit: ".$CT_last_edit."
	( /tools/daemon/wifidbd.php )
- By: Phillip Ferland ( longbow486@gmail.com )
- http://www.randomintervals.com
".$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output, 1);

$database = new database;
$daemon	=	new daemon;



print "Starting The Import/Export Daemon:\n";
$ret = start("imp_exp");
if($ret == 1)
{
	sleep(2);
	$pidfile = file($GLOBALS['pid_file_loc'].'imp_expd.pid');
	$PID =  $pidfile[0];
	verbosed($GLOBALS['COLORS']['GREEN']."STARTED! :-]
WiFiDB 'Import/Export Daemon'
Version: 2.0.0
\t(/tools/daemon/imp_expd.php)
- By: Phillip Ferland
- http://www.randomintervals.com

PID: [ $PID ]
".$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output,1);
}else
{
	echo "Failed to start the Import / Export Daemon :-[\r\n";
}


print "Starting The Statistics Generation Daemon:\n";
$ret = start("daemon_stats");
if($ret == 1)
{
	sleep(2);
	$pidfile = file($GLOBALS['pid_file_loc'].'dbstatsd.pid');
	$PID =  $pidfile[0];
	verbosed($GLOBALS['COLORS']['GREEN']."STARTED! :-]
WiFiDB 'Database Statistics Daemon'
Version: 1.0.0
\t( /tools/daemon/wifidbd.php -> daemon_stats() )
- By: Phillip Ferland ( longbow486@gmail.com )
- http://www.randomintervals.com

PID: [ $PID ]
".$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output, 1);
}else
{
	echo "Failed to start the Database Statistics Daemon :-[\r\n";
}


print "Attempting to start The Perf-Mon Daemon:\n";
$ret = start("daemon_perf");
if($ret == 1)
{
	sleep(2);
	$pidfile = file($GLOBALS['pid_file_loc'].'daemonperfd.pid');
	$PID =  $pidfile[0];
	verbosed($GLOBALS['COLORS']['GREEN']."STARTED! :-]
WiFiDB 'Daemon Performance Montitor'
Version: 1.0.0
\t( /tools/daemon/wifidbd.php -> daemon_perf() )
- By: Phillip Ferland ( longbow486@gmail.com )
- http://www.randomintervals.com

PID: [ $PID ]
".$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output, 1);
}else
{
	
}

#####################
function start($d)
{
	require('config.inc.php');
	require($GLOBALS['wifidb_install'].$GLOBALS['dim'].'lib'.$GLOBALS['dim'].'config.inc.php');
	if (!file_exists("/var/log/wifidb/"))
	{
		mkdir($GLOBALS['daemon_log_folder']);
	}
	switch($d)
	{
		case "imp_exp":
			$console_log = $GLOBALS['daemon_log_folder'].'imp_expd.log';
			echo "Starting WiFiDB 'Import/Export Daemon'..\n";
			$daemon_script = $GLOBALS['wifidb_tools'].$GLOBALS['dim']."daemon".$GLOBALS['dim']."imp_expd.php";
			if (PHP_OS == "WINNT")
			{$cmd = "start ".$GLOBALS['php_install']."\php ".$daemoon_script." > ".$console_log;}
			else{$cmd = "nohup php ".$daemon_script." > ".$console_log." &";}
			
			echo $cmd."\n";
			if(file_exists($daemon_script))
			{
				$start = popen($cmd, 'w');
				if($start)
				{
					echo "WiFiDB 'Import/Export Daemon' Started..\n";
					return 1;
				}else
				{
					echo "WiFiDB 'Import/Export Daemon' Could not start\nStatus: ".$start."\n";
					foreach($screen_output as $line)
					{
						echo $line."\n";
					}
					return 0;
				}
			}else
			{
				echo "Could not find the WiFiDB 'Import/Export Daemon' file. [imp_expd.php].\n";
				return 0;
			}
		break;
		#####
		#####
		case "daemon_perf":
			$console_log = $GLOBALS['daemon_log_folder'].'daemonperfd.log';
			echo "Starting WiFiDB 'Daemon Performance Montitor'..\n";
			$daemon_script = $GLOBALS['wifidb_tools'].$GLOBALS['dim']."daemon".$GLOBALS['dim']."daemonperfd.php";
			if (PHP_OS == "WINNT")
			{$cmd = "start ".$GLOBALS['php_install']."\php ".$daemoon_script." > ".$console_log;}
			else{$cmd = "nohup php ".$daemon_script." > ".$console_log." &";}
			
			echo $cmd."\n";
			if(file_exists($daemon_script))
			{
				$start = popen($cmd, 'w');
				if($start)
				{
					echo "WiFiDB 'Daemon Performance Montitor' Started..\n";
					return 1;
				}else
				{
					echo "WiFiDB 'Daemon Performance Montitor' Could not start\nStatus: ".$start."\n";
					foreach($screen_output as $line)
					{
						echo $line."\n";
					}
					return 0;
				}
			}else
			{
				echo "Could not find the WiFiDB 'Daemon Performance Montitor' file. [daemonperfd.php].\n";
				return 0;
			}
		break;
		#####
		#####
		case "daemon_stats":
			$console_log = $GLOBALS['daemon_log_folder'].'dbstatsd.log';
			echo "Starting WiFiDB 'Database Statistics Daemon'..\n";
			$daemon_script = $GLOBALS['wifidb_tools'].$GLOBALS['dim']."daemon".$GLOBALS['dim']."dbstatsd.php";
			if (PHP_OS == "WINNT")
			{$cmd = "start ".$GLOBALS['php_install']."\php ".$daemoon_script." > ".$console_log;}
			else{$cmd = "nohup php ".$daemon_script." > ".$console_log." &";}
			
			echo $cmd."\n";
			if(file_exists($daemon_script))
			{
				$start = popen($cmd, 'w');
				if($start)
				{
					echo "WiFiDB 'Database Statistics Daemon' Started..\n";
					return 1;
				}else
				{
					echo "WiFiDB 'Database Statistics Daemon' Could not start\nStatus: ".$start."\n";
					foreach($screen_output as $line)
					{
						echo $line."\n";
					}
					return 0;
				}
			}else
			{
				echo "Could not find the WiFiDB 'Database Statistics Daemon' file. [dbstatsd.php].\n";
				return 0;
			}
		break;
		
		default:
			echo "You cannot use the start function without a switch, other wise what does it know to start?\r\n";
			return 0;
		break;
	}
}
######################
?>