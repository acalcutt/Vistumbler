<?php //#last edited -> 2010-Apr-19 20:40:50
global $daemon_ver, $start_date, $last_edit;
global $wifidb_install, $log_level, $log_interval, $verbose, $dst, $time_interval_to_check, $daemon_log, $debug;
global $colors_setting, $default_user, $default_title, $default_notes, $dim, $console_line_limit;
global $PERF_time_interval_to_check, $DBSTATS_time_interval_to_check;
global $BAD_CT_COLOR, $GOOD_CT_COLOR, $OTHER_CT_COLOR, $BAD_DBS_COLOR, $GOOD_DBS_COLOR, $OTHER_DBS_COLOR, $BAD_DPM_COLOR, $GOOD_DPM_COLOR, $OTHER_DPM_COLOR, $BAD_IED_COLOR, $GOOD_IED_COLOR, $OTHER_IED_COLOR;
if(PHP_OS == 'WINNT')
{
	$dim = '\\';
}
else
{
	$dim = '/';
}

#############################################
#############################################
####   DO NOT TOUCH ABOVE THIS BLOCK,    ####
#### UNLESS YOU KNOW WHAT YOU ARE DOING. :)##
#############################################
#############################################


//Defaults for unclaimed imports
$default_user	= 'WiFiDB';
$default_title	= 'Recovery';
$default_notes	= 'WiFiDB Recovery run by an administrator.';

//path to the folder that wifidb is installed in default is /var/www/wifidb/ , because I use Debian. fuck windows 
$wifidb_install		=	'/var/www';
$console_line_limit	=	3000;
$console_trim_log	=	1;
$pid_file_loc		=	'/var/run/wifidbd/';
$daemon_log_folder	=	'/var/log/wifidbd/';

//IF you are running windows you need to define the install path to the PHP binary
$php_install	=	'C:\\program files\\php5\\';

//In seconds 1800 = 30 min interval
	//# Sleep for the Import/Export Daemon
$time_interval_to_check	=	1800;
	//# Sleep for the I/E Daemon Performance Monitor (check every 5 minuets [300 seconds] by default.
$PERF_time_interval_to_check = 450;
	//# Database Statistics Daemon sleep, really should be at once a day (86400 seconds) if you have a very large database.
$DBSTATS_time_interval_to_check = 86400;

//The level that you want the log file to write, off (0), Errors only (1), Detailed Errors [when available] (2). That is all for now.
$log_level	=	0;

//0, one file 'log/wifidbd_log.log'. 1, one file a day 'log/wifidbd_log_[yyyy-mm-dd].log'.
$log_interval	=	0;

//0; no out put, STUF, 1; let me see the world.
$verbose	=	1;

//if you want the CLI output to be color coded 1 = ON, 0 = OFF
//if you ware running windows, this is disabled for you, so even if you turn it on, its not going to work :-p
$colors_setting	=	1;

//Default colors for the CLI
//Allowed colors:
	//LIGHTGRAY, BLUE, GREEN, RED, YELLOW
	//wifidbd.php
$BAD_CT_COLOR	=	'RED';
$GOOD_CT_COLOR	=	'GREEN';
$OTHER_CT_COLOR	=	'YELLOW';
	//dbstatsd.php
$BAD_DBS_COLOR	=	'RED';
$GOOD_DBS_COLOR	=	'GREEN';
$OTHER_DBS_COLOR	=	'YELLOW';
	//daemonperfd.php
$BAD_DPM_COLOR	=	'RED';
$GOOD_DPM_COLOR	=	'GREEN';
$OTHER_DPM_COLOR	=	'YELLOW';
	//imp_expd.php
$BAD_IED_COLOR	=	'RED';
$GOOD_IED_COLOR	=	'GREEN';
$OTHER_IED_COLOR	=	'YELLOW';

//Debug functions turned on, may also include dropping tables and re-createing them 
//so only turn on if you really know what you are doing
$debug = 0;
?>