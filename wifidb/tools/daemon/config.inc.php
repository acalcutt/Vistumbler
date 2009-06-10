<?php
global $wifidb_install, $log_level, $verbose, $log_interval, $time_interval_to_check;

if(PHP_OS == "WINNT"){$dim = "\\";}
if(PHP_OS == "Linux"){$dim = "/";}

//path to the folder that wifidb is installed in default is /var/www/wifidb/ , because I use Debian. fuck windows 
$wifidb_install		=	'/var/www/wifidb';

//In seconds 1800 = 30 min interval
$time_interval_to_check		=	"800";

//The level that you want the log file to write, off (0), Errors only (1), Detailed Errors [when available] (2). That is all for now.
$log_level		=	0;
//0, one file 'log/wifidbd_log.log'. 1, one file a day 'log/wifidbd_log_[yyyy-mm-dd].log'.
$log_interval	=	0;

//The Default time zone is GMT ( Greenwich Time / Zulu Time / UTC )but you can 
//choose what ever the hell you want. It is only this because vistumblers interal 
//clock is also GMT.
$timezn		=	'EST';

//0; no out put, STUF, 1; let me see the world.
$verbose	=	1;

//in seconds how much off the Dayligh savings time is (3600 is 1 hour forward, -3600 is 1 hour backwards)
$DST		=	3600;


require $GLOBALS['wifidb_install']."/lib/database.inc.php";
require $GLOBALS['wifidb_install']."/lib/config.inc.php";

?>