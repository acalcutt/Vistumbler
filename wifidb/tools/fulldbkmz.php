<?php
global $screen_output;
$screen_output = "CLI";
ini_set("memory_limit","3072M");
if(!(require_once 'daemon/config.inc.php')){die("You need to create and configure your config.inc.php file in the [tools dir]/daemon/config.inc.php");}
if($GLOBALS['wifidb_install'] == ""){die("You need to edit your daemon config file first in: [tools dir]/daemon/config.inc.php");}
require_once $GLOBALS['wifidb_install']."/lib/database.inc.php";
require_once $GLOBALS['wifidb_install']."/lib/config.inc.php";
$daemon = new daemon();
$daemon->daemon_kml($named = 0, $verbose);
?>