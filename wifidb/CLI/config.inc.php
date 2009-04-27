<?php
global $wifidb_install, $wifidb_tools, $log_level, $verbose;
//path to the folder that wifidb is installed in default is /var/www/wifidb/ , because I use Debian. fuck windows 
$wifidb_install				=		'/var/www/wifidb';

//this is the installed path of the tools folder that comes with WiFiDB
$wifidb_tools				=		'/CLI';

//In seconds 1800 = 30 min interval
$time_interval_to_check		=		"1800";

//The level that you want the log file to write, default is off (0), Errors only (1), Detailed Errors (2). That is all for now.
$log_level	=	0;

//If you are messing with the code, like me, you can turn this on to have things echoed out to the screen for easy well.. debuging.
$debug		=	0;

//The Default time zone is GMT ( Greenwich Time / Zulu Time / UTC )but you can 
//choose what ever the hell you want. It is only this because vistumblers interal 
//clock is also GMT.
$timezn		=	'GMT+0';

//0, one file 'log/wifidbd_log.log'. 1, one file a day 'log/wifidbd_log_[yyyy-mm-dd].log'.
$log_interval				=		0;

//0; no out put, STUF, 1; let me see the world.
$verbose					=		0;
?>