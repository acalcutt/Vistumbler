<?php
$ft_start = microtime(1);
error_reporting(E_ALL|E_STRICT);
$startdate="02-Oct-2011";
$lastedit="02-Oct-2011";


include('../lib/config.inc.php');
include('../lib/graph.inc.php');
include('../lib/database.inc.php');

$out    = strtolower(filter_input(INPUT_GET, 'out', FILTER_SANITIZE_SPECIAL_CHARS));
$id     =   filter_input(INPUT_GET, 'id', FILTER_SANITIZE_NUMBER_INT)+0;
if($out == "html")
{
    pageheader("Access Point Info Page");
    ?><meta http-equiv="refresh" content="5"><?php
}
$graphs = new graphs();

$live_aps = "live_aps";
$live_gps = "live_gps";




$sql = "SELECT * FROM `$db`.`$live_aps` WHERE `id`='$id'";
$result = mysql_query($sql, $conn);
$array = mysql_fetch_assoc($result);
#var_dump($array);
$sig_exp = explode("|", $array['sig']);
$signals = array();
foreach($sig_exp as $sig)
{
#    echo $sig;
#    echo $out;
    $sig_e = explode("-", $sig);
    switch($out)
    {
        case "img":
            #Lets prep to do some Signal Graphing.
            $signals[] = $sig_e[0];
            break;
        case "maps":
            #echo "#Now lets do some GPS things with Google Maps, if there is valid GPS.";
            $gps_id = $sig_e[1];
            $sql = "SELECT * FROM `$db`.`$live_gps` WHERE `id`='$gps_id'";
            #echo $sql;
            $result_gps = mysql_query($sql);
            while($array_gps = mysql_fetch_assoc($result_gps))
            {
                #var_dump($array_gps);
                $lat = database::convert_dm_dd($array_gps['lat']);
                $long = database::convert_dm_dd($array_gps['long']);
                break;
            }
            break;
        default:

            break;
    }
    break;
}

switch($out)
{
    case "img":
        $signal = implode("-", $signals);
        $name = "Live_AP_".$array['ssid'].'_'.$array['mac'].'-'.$array['username'];
        $filename = $graphs->wifigraphline($array['ssid'], $array['mac'], $manuf, $array['auth'], $array['encry'], $array['radio'], $array['chan'], $lat, $long, str_replace("%20", "-", $array['BTx']), str_replace("%20", "-", $array['OTx']), $fa, $lu, $array['NT'], $array['Label'], $signal, $name, "255:255:255", "rand", "rand", 0 );
        echo '<img src="'.$filename.'" />';
        break;
    case "maps";

            ?><!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="initial-scale=14.0, user-scalable=yes" />
<style type="text/css">
  html { height: 100% }
  body { height: 100%; margin: 0; padding: 0 }
  #map_canvas { height: 100% }
</style>
<script type="text/javascript"
    src="http://maps.googleapis.com/maps/api/js?sensor=false">
</script>
<script type="text/javascript">
  function initialize() {
    var latlng = new google.maps.LatLng(<?php echo $lat; ?>, <?php echo $long; ?>);
    var myOptions = {
      zoom: 14,
      center: latlng,
      mapTypeId: google.maps.MapTypeId.ROADMAP
    };
    var map = new google.maps.Map(document.getElementById("map_canvas"),
        myOptions);
  }

</script>
</head>
<body onload="initialize()">
  <div id="map_canvas" style="width:100%; height:100%"></div>
</body>
</html><?php

        break;
    default:

        break;
}






if($out == "html")footer($_SERVER['SCRIPT_FILENAME']);
?>

