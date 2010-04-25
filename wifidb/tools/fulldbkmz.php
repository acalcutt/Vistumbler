<?php
error_reporting(E_ALL|E_STRICT);
global $screen_output, $dim, $COLORS, $daemon_ver,$users_t;
$users_t			=	'users';
$screen_output = "CLI";
ini_set("memory_limit","3072M");
if(!(require_once 'config.inc.php')){die("You need to create and configure your config.inc.php file in the [tools dir]/daemon/config.inc.php");}
if($GLOBALS['wifidb_install'] == ""){die("You need to edit your daemon config file first in: [tools dir]/daemon/config.inc.php");}
require_once $GLOBALS['wifidb_install']."/lib/database.inc.php";
require_once $GLOBALS['wifidb_install']."/lib/config.inc.php";
$daemon = new daemon();
$daemon->daemon_kml($named = 0, $verbose);
?>