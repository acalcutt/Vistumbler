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

$PHP_OS = PHP_OS;
$OS = $PHP_OS[0];
$enable_mail_admin = 0;
date_default_timezone_set("UTC");

$CT_daemon_ver	= "1.0.0";
$CT_start_date = "2009-12-07";
$CT_last_edit = "2009-12-11";

$date_format					=	"Y-m-d H:i:s.u";
$BAD_CLI_COLOR					=	$GLOBALS['BAD_CT_COLOR'];
$GOOD_CLI_COLOR					=	$GLOBALS['GOOD_CT_COLOR'];
$OTHER_CLI_COLOR				=	$GLOBALS['OTHER_CT_COLOR'];

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

verbosed($GLOBALS['COLORS'][$GOOD_CLI_COLOR]."
WiFiDB 'Control Daemon'
Version: ".$CT_daemon_ver."
- Daemon Start: ".$CT_start_date."
- Last Daemon File Edit: ".$CT_last_edit."
	( /tools/daemon/wifidbd.php )
- By: Phillip Ferland ( pferland@randomintervals.com )
- http://www.randomintervals.com
".$GLOBALS['COLORS'][$OTHER_CLI_COLOR], $verbose, $screen_output, 1);

$database = new database();
$daemon	=	new daemon();
#
##
###
verbosed($GLOBALS['COLORS'][$GOOD_CLI_COLOR]."Attempting to start The Import/Export Daemon:".$GLOBALS['COLORS'][$OTHER_CLI_COLOR]."\n\n", $verbose, $screen_output,1);
$ret = $daemon->start("imp_exp");
if($ret == 1)
{
	sleep(2);
	$pidfile = file($GLOBALS['pid_file_loc'].'imp_expd.pid');
	$PID =  $pidfile[0];
	verbosed($GLOBALS['COLORS'][$GOOD_CLI_COLOR]."STARTED! :-]
WiFiDB 'Import/Export Daemon'
Version: 2.0.0
\t(/tools/daemon/imp_expd.php)

PID: [ $PID ]
".$GLOBALS['COLORS'][$OTHER_CLI_COLOR]."\n\n", $verbose, $screen_output,1);
}else
{
	verbosed($GLOBALS['COLORS'][$BAD_CLI_COLOR]."Failed to start the Import / Export Daemon :-[".$GLOBALS['COLORS'][$OTHER_CLI_COLOR]."\n\n", $verbose, $screen_output,1);
}
#
##
###
verbosed($GLOBALS['COLORS'][$GOOD_CLI_COLOR]."Attempting to start The Statistics Generation Daemon:".$GLOBALS['COLORS'][$OTHER_CLI_COLOR]."\n\n", $verbose, $screen_output,1);
$ret = $daemon->start("daemon_stats");
if($ret == 1)
{
	sleep(2);
	$pidfile = file($GLOBALS['pid_file_loc'].'dbstatsd.pid');
	$PID =  $pidfile[0];
	verbosed($GLOBALS['COLORS'][$GOOD_CLI_COLOR]."STARTED! :-]
WiFiDB 'Database Statistics Daemon'
Version: 1.0.0
\t( /tools/daemon/dbstatsd.php )

PID: [ $PID ]
".$GLOBALS['COLORS'][$OTHER_CLI_COLOR]."\n\n", $verbose, $screen_output, 1);
}else
{
	verbosed($GLOBALS['COLORS'][$BAD_CLI_COLOR]."Failed to start the Database Statistics Daemon :-[".$GLOBALS['COLORS'][$OTHER_CLI_COLOR]."\n\n", $verbose, $screen_output,1);
}
#
##
###
verbosed($GLOBALS['COLORS'][$GOOD_CLI_COLOR]."Attempting to start The Perf-Mon Daemon:".$GLOBALS['COLORS'][$OTHER_CLI_COLOR]."\n\n", $verbose, $screen_output,1);
$ret = $daemon->start("daemon_perf");
if($ret == 1)
{
	sleep(2);
	$pidfile = file($GLOBALS['pid_file_loc'].'daemonperfd.pid');
	$PID =  $pidfile[0];
	verbosed($GLOBALS['COLORS'][$GOOD_CLI_COLOR]."STARTED! :-]
WiFiDB 'Daemon Performance Montitor'
Version: 1.0.0
\t( /tools/daemon/daemonperfd.php )

PID: [ $PID ]
".$GLOBALS['COLORS'][$OTHER_CLI_COLOR]."\n\n", $verbose, $screen_output, 1);
}else
{
	verbosed($GLOBALS['COLORS'][$BAD_CLI_COLOR]."Failed to start the Daemon Performance Monitor Daemon :-[".$GLOBALS['COLORS'][$OTHER_CLI_COLOR]."\n\n", $verbose, $screen_output,1);
}
#
##
###
#####################

######################
?>