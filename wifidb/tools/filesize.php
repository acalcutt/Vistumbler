<?php
error_reporting(E_ALL|E_STRICT);
global $screen_output, $dim, $COLORS, $daemon_ver;
$screen_output = "CLI";

function clearscreen($out = TRUE) {
    $clearscreen = chr(27)."[H".chr(27)."[2J";
    if ($out) print $clearscreen;
    else return $clearscreen;
  }

if(!(@require_once 'daemon/config.inc.php')){die("You need to create and configure your config.inc.php file in the [tools dir]/daemon/config.inc.php");}
if($GLOBALS['wifidb_install'] == ""){die("You need to edit your daemon config file first in: [tools dir]/daemon/config.inc.php");}
require_once $GLOBALS['wifidb_install']."/lib/database.inc.php";
require_once $GLOBALS['wifidb_install']."/lib/config.inc.php";
$sep = $GLOBALS['sep'];
$database = new database();
$daemon	=	new daemon();

while(1)
{
	clearscreen(TRUE);
	echo get_file_size($argv[1])."\r\n";
	sleep(1);
}

function get_file_size($file_)
{
	$handle = popen('/bin/ls -al '.$file_.'>&1', 'r');
	$read = fread($handle, 2096);
	$read_exp = explode(' ', $read);
	$return =  "######\r\n#\r\n#\r\n#\tSize of ( $file_ ) : ".format_size($read_exp[4],8)."\r\n#\t".date("H:m:s")."\r\n#\r\n#\r\n######";
	pclose($handle);
	return $return;
}
?>