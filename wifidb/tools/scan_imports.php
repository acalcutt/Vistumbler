<?php
error_reporting(E_ALL|E_STRICT);
global $screen_output, $dim, $COLORS, $daemon_ver;
$screen_output = "CLI";
$starts = microtime(1);
function clearscreen($out=TRUE){$clearscreen=chr(27)."[H".chr(27)."[2J";if($out){print$clearscreen;}else{return$clearscreen;}}

if(!(@require_once 'daemon/config.inc.php')){die("You need to create and configure your config.inc.php file in the [tools dir]/daemon/config.inc.php");}
if($GLOBALS['wifidb_install'] == ""){die("You need to edit your daemon config file first in: [tools dir]/daemon/config.inc.php");}
require_once $GLOBALS['wifidb_install']."/lib/database.inc.php";
require_once $GLOBALS['wifidb_install']."/lib/config.inc.php";

$dir = $GLOBALS['wifidb_install']."/import/up/";
if ($dh = opendir($dir))
{
    while(($file = readdir($dh)) !== false)
    {
        $exp = explode(".", $file);
        $c = count($exp)-1;
        $ext = $exp[$c];
        if(strtolower($ext) != "vs1")
        {
            continue;
        }
        $file_cont = file($dir.$file);
        
        #echo $file_cont[1]."\r\n";

        $exp_line = explode(":", $file_cont[1]);
        
        if(!@$exp_line[1])
        {
            echo $file."\r\n";
            echo $file_cont[1]."\r\n";
            // movie file;
            $source = $dir.$file;
            $dest = "/var/www/1/".$file;
            if(copy($source, $dest))
            {unlink($source);}
            else{echo "failed to move\r\n";}
            continue;
        }

        $line_exp = explode(" ", trim($exp_line[1]));
        $file_part = $line_exp[0];
        if($file_part == "RanInt")
        {
            //move file;
            echo $file."\r\n";
            echo $file_cont[1]."\r\n";
            $source = $dir.$file;
            $dest = "/var/www/1/".$file;
            if(copy($source, $dest))
            {unlink($source);}
            else{echo "failed to move\r\n";}
        }
    }
    closedir($dh);
}
?>