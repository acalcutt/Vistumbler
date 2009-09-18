<?php
global $wifidb_install,$daemon_ver, $start_date, $last_edit, $log_level, $verbose, $dst, $log_interval, $time_interval_to_check, $colors_setting, $default_user, $default_title, $default_notes, $dim;
if(PHP_OS == 'WINNT'){$dim = '\\';}
if(PHP_OS == 'Linux'){$dim = '/';}
$daemon_ver	=	"1.7.0";
$start_date = "2009-April-23";
$last_edit = "2009-Sept-07";
#do not touch above this line unless you know what you are doing.

//Defaults for unclaimed imports
$default_user = 'WiFiDB';
$default_title = 'Recovery';
$default_notes = 'No Notes';

//path to the folder that wifidb is installed in default is /var/www/wifidb/ , because I use Debian. fuck windows 
$wifidb_install		=	'/var/www/wifidb';
$console_log		=	'/var/log/wifidb';
$pid_file_loc		=	'/var/run/wifidbd.pid';

# IF you are running windows you need to define the install path to the PHP binary
$php_install = "C:\php5_install_folder";

//In seconds 1800 = 30 min interval
$time_interval_to_check		=	900;

//The level that you want the log file to write, off (0), Errors only (1), Detailed Errors [when available] (2). That is all for now.
$log_level		=	0;

//0, one file 'log/wifidbd_log.log'. 1, one file a day 'log/wifidbd_log_[yyyy-mm-dd].log'.
$log_interval	=	0;

//The Default time zone is GMT ( Greenwich Time / Zulu Time / UTC )but you can 
//choose what ever the hell you want. It is only this because vistumblers interal 
//clock is also GMT.
$timezn		=	'America/New_York';

//0; no out put, STUF, 1; let me see the world.
$verbose	=	1;

//if you want the CLI output to be color coded 1 = ON, 0 = OFF
//if you ware running windows, this is disabled for you, so even if you turn it on, its not going to work :-p
$colors_setting = 1;

?>
