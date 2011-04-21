<?php
error_reporting(E_ALL|E_STRICT);

pcntl_signal(SIGTERM, "signal_handler");
pcntl_signal(SIGINT, "signal_handler");
pcntl_signal(SIGKILL, "signal_handler");

global $screen_output;
$screen_output = "CLI";

if(!(require_once 'config.inc.php')){die("You need to create and configure your config.inc.php file in the [tools dir]/daemon/config.inc.php");}

if($wdb_install == ""){die("You need to edit your daemon config file first in: [tools dir]/daemon/config.inc.php");}
require_once $wdb_install."/lib/database.inc.php";
require_once $wdb_install."/lib/daemon.inc.php";
require_once $wdb_install."/lib/config.inc.php";
if(!file_exists($GLOBALS['daemon_log_folder']))
{
    if(mkdir($GLOBALS['daemon_log_folder']))
    {echo "Made WiFiDB Log Folder [".$GLOBALS['daemon_log_folder']."]\r\n";}
    else{echo "Could not make Log Folder [".$GLOBALS['daemon_log_folder']."]\r\n";}
}
if(!file_exists($GLOBALS['pid_file_loc']))
{
    if(mkdir($GLOBALS['pid_file_loc']))
    {echo "Made WiFiDB PID Folder [".$GLOBALS['pid_file_loc']."]\r\n";}
    else{echo "Could not make PID Folder [".$GLOBALS['pid_file_loc']."]\r\n";}
}
if($GLOBALS['colors_setting'] == 0 or PHP_OS == "WINNT")
{
    $COLORS = array(
                    "LIGHTGRAY"	=> "",
                    "BLUE"		=> "",
                    "GREEN"		=> "",
                    "RED"		=> "",
                    "YELLOW"	=> ""
                    );
}else
{
    $COLORS = array(
                    "LIGHTGRAY"	=> "\033[0;37m",
                    "BLUE"		=> "\033[0;34m",
                    "GREEN"		=> "\033[0;32m",
                    "RED"		=> "\033[0;31m",
                    "YELLOW"	=> "\033[1;33m"
                    );
}
$dim = @DIRECTORY_SEPERATOR;
date_default_timezone_set("UTC");
ini_set("memory_limit","3072M"); //lots of objects need lots of memory, that and shitty programing from a fucking idiot of a developer
if(!file_exists($GLOBALS['pid_file_loc']))
{
    if(mkdir($GLOBALS['pid_file_loc']))
    {echo "Made WiFiDB PID Folder [".$GLOBALS['pid_file_loc']."]\r\n";}
    else{echo "Could not make PID Folder [".$GLOBALS['pid_file_loc']."]\r\n";}
}
$This_is_me     =   getmypid();
$pid_file       =   $GLOBALS['pid_file_loc'].'wifidb_lived.pid';

$fileappend = fopen($pid_file, "w");
$write_pid = fwrite($fileappend, $This_is_me);

verbosed($GLOBALS['COLORS'][$GOOD_IED_COLOR]."
WiFiDB 'Live AP Daemon'
Version: 1.0.0
 - Daemon Start: 20-Apr-2011
 - Last Daemon File Edit: 2011-Apr-2011
	(/tools/daemon/wifidb_lived.php)
 - By: Phillip Ferland ( pferland@randomintervals.com )
 - http://www.randomintervals.com

PID: [ $This_is_me ]".$GLOBALS['COLORS'][$OTHER_IED_COLOR], $verbose, $screen_output, 0);
$daemon = new daemon();
$conn = new mysqli($host, $db_user, $db_pass);
$conn->query("SET NAMES 'utf8'");
while(1)
{
    $sql = "SELECT * FROM `$db`.`$live_aps` ORDER BY `username` ASC";
    $result = $conn->query($sql);
    while($live_table = $result->fetch_array(1))
    {
        if(strtotime($live_table['LA'])+600 <= time())
        {
            if($live_table['username'] != "UNKNOWN")
            {
                $daemon->live_export($live_table['username']);
            }else
            {
                $daemon->live_export("UNKNOWN", 1);
            }
        }else
        {

        }
    }
}







function signal_handler($signal)
{
    switch($signal)
    {
        case SIGTERM:
            print "Caught SIGTERM\n";
            unlinlk($pid_file);
            exit;
        case SIGKILL:
            print "Caught SIGKILL\n";
            unlinlk($pid_file);
            exit;
        case SIGINT:
            print "Caught SIGINT\n";
            unlinlk($pid_file);
            exit;
    }
}
?>
