<?php
error_reporting(E_ALL|E_STRICT);
ini_set("memory_limit","3072M");
global $screen_output;
$screen_output = "CLI";
if(!(@require_once 'daemon/config.inc.php')){die("You need to create and configure your config.inc.php file in the [tools dir]/daemon/config.inc.php");}
if($GLOBALS['wifidb_install'] == ""){die("You need to edit your daemon config file first in: [tools dir]/daemon/config.inc.php");}
require_once $GLOBALS['wifidb_install']."/lib/database.inc.php";
 
if(mail_admin("Multi-Admin Send mail test.", 0))
{echo "SENT!!!!!!!\r\n";}





?>