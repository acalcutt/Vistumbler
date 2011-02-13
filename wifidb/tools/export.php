<?php
error_reporting(E_ALL|E_STRICT);
global $screen_output;
$screen_output = "CLI";
$start = microtime(1);
$table_error = array();

if(!(require_once 'daemon/config.inc.php')){die("You need to create and configure your config.inc.php file in the [tools dir]/daemon/config.inc.php");}
if($GLOBALS['wifidb_install'] == ""){die("You need to edit your daemon config file first in: [tools dir]/daemon/config.inc.php");}
require_once $GLOBALS['wifidb_install']."/lib/database.inc.php";
require_once $GLOBALS['wifidb_install']."/lib/config.inc.php";
$file = "SSID,BSSID,MANUFACTURER,SIGNAL,AUTHENTICATION,ENCRYPTION,RADIO TYPE,CHANNEL,BTX,OTX,NETWORK TYPE,"
."LABEL,LATITUDE,LONGITUDE,SATELLITES,HDOP,ALTITUDE,HEIGHT OF GEOID,SPEED(km/h),SPEED(MPH),TRACK ANGLE,DATE(UTC),TIME(UTC)\r\n";

$sql0 = "SELECT * FROM wifi.wifi0";
$result = mysql_query($sql0, $conn);
while($newArray = mysql_fetch_array($result))
{
    list($ssid_ptb) = make_ssid($newArray["ssid"]);
    $table = $ssid_ptb.'-'.$newArray["mac"].'-'.$newArray["sectype"].'-'.$newArray["radio"].'-'.$newArray['chan'];
    $table_gps = $table.$gps_ext;
    echo "[ ".$newArray['id']." ]TABLE: ".$table."\r\n";

    $sql1 = "SELECT `otx`,`btx`,`nt`,`label` FROM `$db_st`.`$table` order by `id` desc limit 1";
    #echo $sql1."\r\n";
    $result1 = mysql_query($sql1, $conn);
    if(!$result1){echo "***ERRROR***\r\n\r\n";$table_error[] =  array( $newArray["id"], $table);}
    $field = mysql_fetch_array($result1);

    $sql2 = "SELECT `date`,`time` FROM `$db_st`.`$table_gps` order by `id` desc limit 1";
    #echo $sql2."\r\n";
    $result2 = mysql_query($sql2, $conn);
    if(!$result2){echo "***ERRROR***\r\n\r\n";$table_error[] =  array( $newArray["id"], $table_gps);}
    $date = mysql_fetch_array($result2);

    @$file .= '"'.$newArray['ssid'].'",'.$newArray['mac'].',"'.database::manufactures($newArray['mac']).'",0,'.$newArray['auth'].','.$newArray['encry'].','
    .$newArray['radio'].','.$newArray['chan'].','.$field['btx'].','.$field['otx'].','.$field['nt'].','.$field['label'].','.$newArray['lat'].','.$newArray['long']
    .',0,0,0,0,0,0,0,'.$date['date'].','.$date['time']."\r\n";
}
echo "Dumping to CSV file...\r\n";
file_put_contents("./csv/export".date('Y-m-d').".csv", $file);
$end = microtime(1);
echo "Done, it took : ".($end - $start)." seconds\r\n";
?>