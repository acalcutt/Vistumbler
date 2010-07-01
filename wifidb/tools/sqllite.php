<?php
error_reporting(E_ALL);
global $screen_output, $debug;
$screen_output = "CLI";

$dim = @DIRECTORY_SEPERATOR;
if(!(require_once 'daemon/config.inc.php')){die("You need to create and configure your config.inc.php file in the [tools dir]/daemon/config.inc.php");}
if($GLOBALS['wifidb_install'] == ""){die("You need to edit your daemon config file first in: [tools dir]/daemon/config.inc.php");}
require_once $GLOBALS['wifidb_install']."/lib/database.inc.php";
require_once $GLOBALS['wifidb_install']."/lib/config.inc.php";
####################################################################################

database::convert_vs1("wardrive.db3");
?>