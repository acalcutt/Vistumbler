<?php
global $wifidb_install, $log_level, $verbose, $log_interval, $time_interval_to_check;

if(PHP_OS == "WINNT"){$dim = "\\";}
if(PHP_OS == "Linux"){$dim = "/";}

//path to the folder that wifidb is installed in default is /var/www/wifidb/ , because I use Debian. fuck windows 
$wifidb_install		=	'/var/www/html';

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


$BLACK = "\033[0;30m";
$DARKGRAY="\033[1;30m";
$LIGHTGRAY = "\033[0;37m";
$WHITE= "\033[1;37m";

$BLUE="\033[0;34m";
$LIGHTBLUE="\033[1;34m";

$GREEN="\033[0;32m";
$LIGHTGREEN="\033[1;32m";

$CYAN="\033[0;36m";
$LIGHTCYAN="\033[1;36m";

$RED="\033[0;31m";
$LIGHTRED="\033[1;31m";

$PURPLE="\033[0;35m";
$LIGHTPURPLE="\033[1;35m";

$BROWN="\033[0;33m";
$YELLOW="\033[1;33m";
?>
