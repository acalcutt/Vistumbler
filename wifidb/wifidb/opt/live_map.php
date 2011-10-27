<?php
$ft_start = microtime(1);
error_reporting(E_ALL && E_STRICT);
$startdate="16-Oct-2011";
$lastedit="16-Oct-2011";

include('../lib/config.inc.php');
include('../lib/database.inc.php');

$live_aps = "live_aps";
$live_gps = "live_gps";
$n=0;
$maps_compile_a = array();
$sql = "SELECT ssid, sectype, sig FROM `$db`.`$live_aps`";
$result = mysql_query($sql, $conn);
while($array = mysql_fetch_assoc($result))
{
    #var_dump($array);
    $ssid = $array['ssid'];
    $sig_exp = explode("|", $array['sig']);
    foreach($sig_exp as $sig_e)
    {
        $sig_ep = explode("-", $sig_e);
        $signals[] = $sig_ep[0];
        $gps_id = $sig_ep[1];
        $sql = "SELECT * FROM `$db`.`$live_gps` WHERE `id`='$gps_id'";
        #echo $sql;
        $result_gps = mysql_query($sql);
        $array_gps = mysql_fetch_assoc($result_gps);
        #var_dump($array_gps);
        if($array_gps['lat'] == "N 0000.0000")
        {
            continue;
        }
        
        $lat = database::convert_dm_dd($array_gps['lat']);
        $long = database::convert_dm_dd($array_gps['long']);
        if($lat == "0")
        {
            continue;
        }
        
        switch($array['sectype'])
        {
            case 1:
                $img = "open";
                break;
            case 2:
                $img = "wep";
                break;
            case 3:
                $img = "secure";
                break;
        }
        $maps_compile_a[] = $img."
                           var myLatLng$n = new google.maps.LatLng($lat, $long);
                           var beachMarker$n = new google.maps.Marker({position: myLatLng$n, map: map, icon: $img, title: \"$ssid\"});\r\n";
        $n++;
        break;
    }
    if($lat == "0")
    {
        $nn++;
    }
}
#var_dump($maps_compile_a);
$maps_compile = implode("", $maps_compile_a);
$ft_stop = microtime(1);
echo $ft_stop-$ft_start."\r\n";
echo $n."\r\n".$nn;
#exit();
?>
<html>
    <head>
        <meta name="viewport" content="initial-scale=1.0, user-scalable=yes" />
        <meta http-equiv="content-type" content="text/html; charset=UTF-8"/>
        <link href="https://code.google.com/apis/maps/documentation/javascript/examples/default.css" rel="stylesheet" type="text/css" />
        <script type="text/javascript" src="https://maps.googleapis.com/maps/api/js?sensor=false"></script>
        <style type="text/css">
            .maps_label {background-color:#ffffff;font-weight:bold;border:2px #006699 solid;}
        </style>
        <script type="text/javascript">
            function initialize()
            {
                var myOptions = {
                  zoom: 16,
                  center: new google.maps.LatLng(<?php echo $lat; ?>, <?php echo $long; ?>),
                  mapTypeId: google.maps.MapTypeId.ROADMAP
                }
                var open = 'http://vistumbler.sourceforge.net/images/program-images/open.png';
                var wep = 'http://vistumbler.sourceforge.net/images/program-images/secure-wep.png';
                var secure = 'http://vistumbler.sourceforge.net/images/program-images/secure.png';
                var map = new google.maps.Map(document.getElementById("map_canvas"), myOptions);
                <?php
                echo $maps_compile;
                ?>
            }
            window.onload = initialize;
        </script>
    </head>
    <body>
        <div style="width:100%;height:100%;" id="map_canvas"></div>
    </body>
</html>
<?php

?>