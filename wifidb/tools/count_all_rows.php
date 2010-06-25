<?php
error_reporting(E_ALL|E_STRICT);
global $screen_output;
$screen_output = "CLI";

if(!(require_once 'config.inc.php')){die("You need to create and configure your config.inc.php file in the [tools dir]/daemon/config.inc.php");}
if($GLOBALS['wifidb_install'] == ""){die("You need to edit your daemon config file first in: [tools dir]/daemon/config.inc.php");}
require_once $GLOBALS['wifidb_install']."/lib/database.inc.php";
require_once $GLOBALS['wifidb_install']."/lib/config.inc.php";

$sql0 = "SELECT SUM( TABLE_ROWS ) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = '$db_st'";
$result = mysql_query($sql0, $conn);
$newArray = mysql_fetch_array($result);
echo "Aprox number of rows in $db_st: \033[0;31m".$newArray[0]."\033[0;37m";

?>