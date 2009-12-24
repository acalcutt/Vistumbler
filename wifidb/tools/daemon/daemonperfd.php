<?php
error_reporting(E_ALL|E_STRICT);
global $screen_output;
$screen_output = "CLI";
ini_set("memory_limit","3072M"); //lots of GPS cords need lots of memory
###########################
if(!(require_once 'config.inc.php')){die("You need to create and configure your config.inc.php file in the [tools dir]/daemon/config.inc.php");}
if($GLOBALS['wifidb_install'] == ""){die("You need to edit your daemon config file first in: [tools dir]/daemon/config.inc.php");}
require_once $GLOBALS['wifidb_install']."/lib/database.inc.php";
require_once $GLOBALS['wifidb_install']."/lib/config.inc.php";

require $GLOBALS['wifidb_install']."/lib/config.inc.php";
require_once $GLOBALS['wifidb_install']."/cp/admin/lib/administration.inc.php";
$PHP_OS = PHP_OS;
$OS = $PHP_OS[0];
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
if($OS == "WINNT"){$dim = "\\";}else{$dim = "/";}
$conn			= 	$GLOBALS['conn'];
$db				= 	$GLOBALS['db'];
$db_st			= 	$GLOBALS['db_st'];
$wtable			=	$GLOBALS['wtable'];
$users_t		=	$GLOBALS['users_t'];
$gps_ext		=	$GLOBALS['gps_ext'];
$files			=	$GLOBALS['files'];
$user_logins_table= $GLOBALS['user_logins_table'];
$root			= 	$GLOBALS['root'];
$half_path		=	$GLOBALS['half_path'];
$WFDBD_PID		=	$GLOBALS['pid_file_loc'].'imp_exp.pid';
$verbose		=	$GLOBALS['verbose'];
$screen_output	=	$GLOBALS['screen_output'];
$PERF_time_interval_to_check = $GLOBALS['PERF_time_interval_to_check'];

$os				=	PHP_OS;
$enable_mail_admin = 0;
$pid_file = $GLOBALS['pid_file_loc'].'daemonperfd.pid';
$This_is_me = getmypid();
fopen($pid_file, "w");
$fileappend = fopen($pid_file, "a");
$write_pid = fwrite($fileappend, "$This_is_me");
if(!$write_pid){die($GLOBALS['COLORS']['RED']."Could not write pid file, thats not good... >:[".$GLOBALS['COLORS']['LIGHTGRAY']);}

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

verbosed($GLOBALS['COLORS']['GREEN']."
WiFiDB 'Daemon Performance Montitor'
Version: 1.0.0
- Daemon Start: 2009-12-07
- Last Daemon File Edit: 2009-12-12
( /tools/daemon/wifidbd.php -> daemon_perf() )
- By: Phillip Ferland ( longbow486@gmail.com )
- http://www.randomintervals.com

PID: [ $This_is_me ]
".$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output, 1);

while(TRUE)
{
	$date	=	date("Y-m-d G:i:s");
	if ( $os[0] == 'L')
	{
		$os_type = "Linux Based WiFiDB Daemon";
		$output = array();
#		echo $WFDBD_PID."\r\n";
		if(file_exists($WFDBD_PID))
		{
			$pid_open = file($WFDBD_PID);
			exec('ps v '.$pid_open[0] , $output, $sta);
			if(isset($output[1]))
			{
				$start = trim($output[1], " ");
				preg_match_all("/(\d+?)(\.)(\d+?)/", $start, $match);
				$mem = $match[0][0];
				
				preg_match_all("/(php.*)/", $start, $matc);
				$CMD = $matc[0][0];
				
				preg_match_all("/(\d+)(\:)(\d+)/", $start, $mat);
				$time = $mat[0][0];
				
				$patterns[1] = '/  /';
				$patterns[2] = '/ /';
				$ps_stats = preg_replace($patterns , "|" , $start);
				$ps_Sta_exp = explode("|", $ps_stats);
				$pid = str_replace(' ?',"",$ps_Sta_exp[0]);
				
				$insert = "INSERT INTO `$db`.`daemon_perf_mon` (`id`, `timestamp`, `pid`, `uptime`, `CMD`, `mem`, `mesg`) VALUES ('', '$date', '$pid', '$time', '$CMD', '$mem', '')";
			#	echo $insert."\r\n";
				if(!$result = mysql_query($insert, $conn))
				{
					mail_admin("There was an error inserting the Daemon Performance data into the `daemon_perf_mon` table. :-(\r\n".mysql_error($conn), $enable_mail_admin, 1);echo "FAILURE!\r\n";
				}else{
					verbosed($GLOBALS['COLORS']['GREEN']."Success!".$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output, 1);
				}
			}else
			{
				$insert = "INSERT INTO `$db`.`daemon_perf_mon` (`id`, `timestamp`, `pid`, `uptime`, `CMD`, `mem`, `mesg`) VALUES ('', '$date', '00000', '0', '', '0.00', 'NOT RUNNING!')";
			#	echo $insert."\r\n";
				if(!$result = mysql_query($insert, $conn))
				{
					mail_admin("There was an error inserting the Daemon Performance data into the `daemon_perf_mon` table. 
Also, The Daemon is configured to run, but is not!. Fix it quick before imports start to pile up on the lawn. :-(\r\n".mysql_error($conn), $enable_mail_admin, 1);
					verbosed($GLOBALS['COLORS']['GREEN']."FAILURE!\r\n".mysql_error($conn).$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output, 1);
				}else{
					mail_admin("The Daemon is configured to run, but is not!. Fix it quick before imports start to pile up on the lawn. :-(",$enable_mail_admin, 1);
					verbosed($GLOBALS['COLORS']['GREEN']."Success!".$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output, 1);
				}
			}
		}else
		{
			$insert = "INSERT INTO `$db`.`daemon_perf_mon` (`id`, `timestamp`, `pid`, `uptime`, `CMD`, `mem`, `mesg`) VALUES ('', '$date', '00000', '0', '', '0.00', 'NOT RUNNING!')";
		#	echo $insert."\r\n";
			if(!$result = mysql_query($insert, $conn))
			{
				mail_admin("There was an error inserting the Daemon Performance data into the `daemon_perf_mon` table. 
Also, The Daemon is configured to run, but is not!. Fix it quick before imports start to pile up on the lawn. :-(\r\n".mysql_error($conn), $enable_mail_admin, 1);
				verbosed($GLOBALS['COLORS']['GREEN']."FAILURE!\r\n".mysql_error($conn).$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output, 1);
			}
			else{
				mail_admin("The Daemon is configured to run, but is not!. Fix it quick before imports start to pile up on the lawn. :-(", $enable_mail_admin, 1);
				verbosed($GLOBALS['COLORS']['GREEN']."Success!".$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output, 1);
			}
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
				$ps_stats = explode("," , $output[2]);
				
				$proc =  str_replace('"',"",$ps_stats[0]);
				$pid =  str_replace('"',"",$ps_stats[1]);
				$mem =  str_replace('"',"",$ps_stats[4]).','.str_replace('"',"",$ps_stats[5]);
				$time =  str_replace('"',"",$ps_stats[8]);

				$insert = "INSERT INTO `$db`.`daemon_perf_mon` (`id`, `timestamp`, `pid`, `uptime`, `CMD`, `mem`, `mesg`) VALUES ('', '$date', '$pid', '$time', '$proc', '$mem', '')";
				if(!$result = mysql_query($insert, $conn))
				{
					mail_admin("There was an error inserting the Daemon Performance data into the `daemon_perf_mon` table. :-(\r\n".mysql_error($conn), $enable_mail_admin, 1);
					verbosed($GLOBALS['COLORS']['GREEN']."FAILURE!\r\n".mysql_error($conn).$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output, 1);
				}				
			}else
			{
				$insert = "INSERT INTO `$db`.`daemon_perf_mon` (`id`, `timestamp`, `pid`, `uptime`, `CMD`, `mem`, `mesg`) VALUES ('', '', '00000', '0', '', '0.00', 'NOT RUNNING!')";
				if(!$result = mysql_query($insert, $conn))
				{
					mail_admin("There was an error inserting the Daemon Performance data into the `daemon_perf_mon` table. 
Also, The Daemon is configured to run, but is not!. Fix it quick before imports start to pile up on the lawn. :-(\r\n".mysql_error($conn), $enable_mail_admin, 1);
					verbosed($GLOBALS['COLORS']['GREEN']."FAILURE!\r\n".mysql_error($conn).$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output, 1);
				}else{
					mail_admin("The Daemon is configured to run, but is not!. Fix it quick before imports start to pile up on the lawn. :-(", $enable_mail_admin, 1);
					verbosed($GLOBALS['COLORS']['GREEN']."DAEMON NOT RUNNING FAILURE!\r\n".mysql_error($conn).$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output, 1);
				}
			}
		}else
		{
			$insert = "INSERT INTO `$db`.`daemon_perf_mon` (`id`, `timestamp`, `pid`, `uptime`, `CMD`, `mem`, `mesg`) VALUES ('', '', '00000', '0', '', '0.00', 'NOT RUNNING!')";
			if(!$result = mysql_query($insert, $conn))
			{
				mail_admin("There was an error inserting the Daemon Performance data into the `daemon_perf_mon` table. 
Also, The Daemon is configured to run, but is not!. Fix it quick before imports start to pile up on the lawn. :-(\r\n".mysql_error($conn), $enable_mail_admin, 1);
				verbosed($GLOBALS['COLORS']['GREEN']."FAILURE!\r\n".mysql_error($conn).$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output, 1);
			}else{
				mail_admin("The Daemon is configured to run, but is not!. Fix it quick before imports start to pile up on the lawn. :-(", $enable_mail_admin, 1);
				verbosed($GLOBALS['COLORS']['GREEN']."DAEMON NOT RUNNING FAILURE!\r\n".mysql_error($conn).$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output, 1);
			}
		}
	}else
	{
		$insert = "INSERT INTO `$db`.`daemon_perf_mon` (`id`, `timestamp`, `pid`, `uptime`, `CMD`, `mem`, `mesg`) VALUES ('', '', '00000', '0', '', '0.00', 'NOT RUNNING!')";
		if(!$result = mysql_query($insert, $conn))
		{
			mail_admin("There was an error inserting the Daemon Performance data into the `daemon_perf_mon` table. 
Also, The Daemon is configured to run, but is not!. Fix it quick before imports start to pile up on the lawn. :-(\r\n".mysql_error($conn), $enable_mail_admin, 1);
			verbosed($GLOBALS['COLORS']['GREEN']."FAILURE!\r\n".mysql_error($conn).$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output, 1);
		}else{
			mail_admin("The Daemon is configured to run, but is not!. Fix it quick before imports start to pile up on the lawn. :-(", $enable_mail_admin, 1);
			verbosed($GLOBALS['COLORS']['GREEN']."DAEMON NOT RUNNING FAILURE!\r\n".mysql_error($conn).$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output, 1);
		}
	}
	echo $date." -> Daemon Performance Monitor is going to sleep for ".($PERF_time_interval_to_check/60)." Minuets\r\n";
	sleep($PERF_time_interval_to_check);
}
?>