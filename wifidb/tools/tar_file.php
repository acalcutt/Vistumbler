<?php
global $screen_output, $tarver;
$screen_output = "CLI";
$tarver = array(
				"start_date" => "2010-June-13",
				"last_edit" => "2010-June-13",
				"ver"		=>	"1.0"
			)
if(!(@require_once 'daemon/config.inc.php')){die("You need to create and configure your config.inc.php file in the [tools dir]/daemon/config.inc.php");}
if($GLOBALS['wifidb_install'] == ""){die("You need to edit your daemon config file first in: [tools dir]/daemon/config.inc.php");}
require_once $GLOBALS['wifidb_install']."/lib/database.inc.php";

$parm = parseArgs($argv);
$tarfile = tar_file($parm['file']);
if(!$tarfile)
{
	echo "taring of file failed...";
}else
{
	echo "System tar program returned: ".$tarfile[0]." - RunTime: ".$tarfile[2]." - MBps: ".$tarfile[3]."\r\n";
}
?>