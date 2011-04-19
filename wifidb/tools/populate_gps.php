<?php
$parm = parseArgs($argv);
$clear = @$parm['clear'];
unset($parm);
$conn = prep();
if($clear)
{
    echo "Going to clear out the GPS data from the pointers table.\r\n";
}
$sep = $GLOBALS['sep'];
$gps_ext = $GLOBALS['gps_ext'];

$sql = "SELECT * FROM `wifi`.`wifi0`";
$result = $conn->query($sql);
while($all = $result->fetch_array(1))
{
    $id = $all['id'];
    if($clear)
    {
        echo "-----------------------\r\n";

        echo ((memory_get_usage(1)/1024)/1024)."M\r\n";
        echo ((memory_get_usage(0)/1024)/1024)."M\r\n";
        
        $sql = "UPDATE `wifi`.`wifi0` set `lat` = 'N 0.0000', `long` = 'W 0.0000' where `id` = '$id'";
        echo $sql."\r\n";
        $conn->query($sql);
        if(!$conn->errno)
        {
        #    echo "UPDATED!!!!!!!!!\r\n";
        }else
        {
        #    echo "UPDATE FAILED!!!!!\r\n".$conn->errno."\r\n";
        }
        echo "-----------------------\r\n";
        $sql = '';
    }else
    {
        echo "-----------------------------\r\n";
        echo ((memory_get_usage(1)/1024)/1024)."M\r\n";
        echo ((memory_get_usage(0)/1024)/1024)."M\r\n";
        list($ssid) = make_ssid($all['ssid']);
        #
        $macs = $all['mac'];
        $sectype = $all['sectype'];
        $radios = $all['radio'];
        $chan = $all['chan'];
        //create table name to select from, insert into, or create
        #
        $table = $ssid.$sep.$macs.$sep.$sectype.$sep.$radios.$sep.$chan.$gps_ext;
        $sql  = "SELECT `id`, `lat`, `long`, `sats` FROM `wifi_st`.`$table` WHERE `lat` != 'N 0.0000' ORDER BY `date`,`sats` DESC";
        $result1 = $conn->query($sql);
        #
        echo $all['id']."\r\n";
        if($result1->num_rows == 0)
        {
            echo "-----------------------------\r\n";
            continue;
        }
        #echo $sql."\r\n".$result1->num_rows."\r\n\r\n";
        #
        #
        $gps = $result1->fetch_array(1);
        #echo $gps['id']."-";
        #
        #
        #var_dump(substr($gps['lat'], 0,1));
        $lat_sub = $gps['lat'][0];

        if($lat_sub != "-" && is_numeric($lat_sub))
        {
           $gps['lat'] = "N ".$gps['lat'];
        }else #if(is_int(substr($gps['lat'], 0,1))+0)
        {
           $gps['lat'] = str_replace("-", "S ", $gps['lat']);
        }
        ######
        ######
        ######
        #var_dump(substr($gps['long'], 0,1));
        $long_sub = $gps['long'][0];

        if($long_sub != "-" && is_numeric($long_sub))
        {
           $gps['long'] = "E ".$gps['long'];
        }else #if(is_int(substr($gps['long'], 0,1)+0))
        {
           $gps['long'] = str_replace("-", "W ", $gps['long']);
        }
        #
        #
        $lat = $gps['lat'];
        $long = $gps['long'];
        if($lat == "N 0000.0000" || $long == "E 0000.0000"){echo "INVALID\r\n"; continue;}
        $sql = "UPDATE `wifi`.`wifi0` set `lat` = '$lat', `long` = '$long' where `id` = '$id'";
        echo $sql."\r\n";
        $conn->query($sql);
        if(!$conn->errno)
        {
            echo "UPDATED!!!!!!!!!\r\n";
        }else
        {
            echo "UPDATE FAILED!!!!!\r\n".mysqli_error($conn);
        }
        unset($result1);
        echo "-----------------------------\r\n";

        $long_sub = '';
        $lat_sub = '';
        $sql = '';
        #$all = array();
        $table = '';
        $macs = '';
        $ssid = '';
        $sectype = '';
        $chan = '';
        #$gps = array();
    }
    unset($gps);
    unset($all);

}



















function prep()
{
    #error_reporting(E_ALL|E_STRICT);
    ini_set("memory_limit", "1024M");
    global $screen_output, $dim, $COLORS, $daemon_ver, $sep, $gps_ext;
    $screen_output = "CLI";
    #$starts = microtime(1);
    if(!(@require_once 'daemon/config.inc.php')){die("You need to create and configure your config.inc.php file in the [tools dir]/daemon/config.inc.php");}
    if($GLOBALS['wifidb_install'] == ""){die("You need to edit your daemon config file first in: [tools dir]/daemon/config.inc.php");}
    require_once $GLOBALS['wifidb_install']."/lib/database.inc.php";
    require_once $GLOBALS['wifidb_install']."/lib/config.inc.php";
    $conn =   new mysqli($host, $db_user, $db_pwd);
    return $conn;
}

#-------------------------------------------------------------------------------------#
#----------------------------------  Parse Arg values  -------------------------------#
#-------------------------------------------------------------------------------------#
function parseArgs($argv){
    array_shift($argv);
    $out = array();
    foreach ($argv as $arg)
    {
        if (substr($arg,0,2) == '--'){
            $eqPos = strpos($arg,'=');
            if ($eqPos === false){
                $key = substr($arg,2);
                $out[$key] = isset($out[$key]) ? $out[$key] : true;
            } else {
                $key = substr($arg,2,$eqPos-2);
                $out[$key] = substr($arg,$eqPos+1);
            }
        } else if (substr($arg,0,1) == '-'){
            if (substr($arg,2,1) == '='){
                $key = substr($arg,1,1);
                $out[$key] = substr($arg,3);
            } else {
                $chars = str_split(substr($arg,1));
                foreach ($chars as $char){
                    $key = $char;
                    $out[$key] = isset($out[$key]) ? $out[$key] : true;
                }
            }
        } else {
            $out[] = $arg;
        }
    }
    return $out;
}
?>