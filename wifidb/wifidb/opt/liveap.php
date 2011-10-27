<?php
$ft_start = microtime(1);
error_reporting(E_ALL && E_STRICT);
$startdate="02-Oct-2011";
$lastedit="02-Oct-2011";


include('../lib/config.inc.php');
include('../lib/graph.inc.php');
include('../lib/database.inc.php');

$out    = strtolower(filter_input(INPUT_GET, 'out', FILTER_SANITIZE_SPECIAL_CHARS));
$id     = filter_input(INPUT_GET, 'id', FILTER_SANITIZE_NUMBER_INT)+0;

$graphs = new graphs();

$live_aps = "live_aps";
$live_gps = "live_gps";

$sql = "SELECT * FROM `$db`.`$live_aps` WHERE `id`='$id'";
$result = mysql_query($sql, $conn);
$array = mysql_fetch_assoc($result);
#var_dump($array);
$sig_exp = explode("|", $array['sig']);
$signals = array();

switch($out)
{
    case "img":
        #Lets prep to do some Signal Graphing.

        foreach($sig_exp as $sig_e)
        {
            $sig_e = explode("-", $sig_exp[0]);
            $signals[] = $sig_e[0];
            $gps_id = $sig_e[1];
        }
        $sql = "SELECT * FROM `$db`.`$live_gps` WHERE `id`='$gps_id'";
        #echo $sql;
        $result_gps = mysql_query($sql);
        $array_gps = mysql_fetch_assoc($result_gps);
        #var_dump($array_gps);
        $lat = $array_gps['lat'];
        $long = $array_gps['long'];
        break;
    case "html":
        $n=0;
        $maps_compile_a = array();
        foreach($sig_exp as $sig_e)
        {
            $n++;
            $sig_ep = explode("-", $sig_e);
            $signals[] = $sig_ep[0];
            $gps_id = $sig_ep[1];
            $sql = "SELECT * FROM `$db`.`$live_gps` WHERE `id`='$gps_id'";
            #echo $sql;
            $result_gps = mysql_query($sql);
            $array_gps = mysql_fetch_assoc($result_gps);
            #var_dump($array_gps);
            $lat = database::convert_dm_dd($array_gps['lat']);
            $long = database::convert_dm_dd($array_gps['long']);
            if($lat = "0")
            {
                continue;
            }
            $maps_compile_a[] = "
                               var myLatLng$n = new google.maps.LatLng($lat, $long);
                               var beachMarker$n = new google.maps.Marker({position: myLatLng$n, map: map, icon: image});";
        }
        $maps_compile = implode("", $maps_compile_a);
        break;
    default:
        echo "Ummmmm.....";
        break 2;
}

switch($out)
{
    case "img":

        $signal = implode("-", $signals);
        #var_dump($array);
        #var_dump($signal);
        $manuf = database::manufactures($array['mac']);
        $name = "Live_AP_".$array['ssid'].'_'.$array['mac'].'-'.$array['username'];
        $filename = $graphs->wifigraphline(
                                $array['ssid'],
                                implode(":", str_split($array['mac'],2)),
                                $manuf,
                                $array['auth'],
                                $array['encry'],
                                $array['radio'],
                                $array['chan'],
                                $lat, $long,
                                str_replace("%20", "-", $array['BTx']),
                                str_replace("%20", "-", $array['OTx']),
                                $array['fa'], $array['lu'],
                                $array['NT'],
                                $array['Label'],
                                $signal,
                                $name,
                                "255:255:255", "rand", "rand",
                                0
                            );
        echo '<img src="'.$filename.'" />';
        break;
    case "html";
        pageheader("Live AP Details Page", "maps");
        ?>
        <table border="1" width="100%" cellspacing="0">
            <tr class="style4">
                <td>SSID</td>
                <td>MAC</td>
                <td>Chan</td>
                <td>Radio Type</td>
                <td>Authentication</td>
                <td>Encryption</td>
                <td>Username</td>
                <td>First Seen</td>
                <td>Last Updated</td>
            </tr>
            <tr>
                <td><?php echo $array['ssid']; ?></td>
                <td><?php echo $array['mac']; ?></td>
                <td><?php echo $array['chan']; ?></td>
                <td><?php echo $array['radio']; ?></td>
                <td><?php echo $array['auth']; ?></td>
                <td><?php echo $array['encry']; ?></td>
                <td><?php echo $array['username']; ?></td>
                <td><?php echo $array['fa']; ?></td>
                <td><?php echo $array['lu']; ?></td>
            </tr>
            <tr>
                <td colspan="9">

                    <script type="text/javascript" src="https://maps.googleapis.com/maps/api/js?sensor=false"></script>
                    <script type="text/javascript">
                        function initialize()
                        {
                            var myOptions = {
                              zoom: 16,
                              center: new google.maps.LatLng(<?php echo $lat; ?>, <?php echo $long; ?>),
                              mapTypeId: google.maps.MapTypeId.ROADMAP
                            }
                            var map = new google.maps.Map(document.getElementById("map_canvas"), myOptions);
                            <?php
                            switch($array['sectype'])
                            {
                                case 1:
                                    echo "var image = 'http://vistumbler.sourceforge.net/images/program-images/open.png';";
                                    break;
                                case 2:
                                    echo "var image = 'http://vistumbler.sourceforge.net/images/program-images/secure-wep.png';";
                                    break;
                                case 3:
                                    echo "var image = 'http://vistumbler.sourceforge.net/images/program-images/secure.png';";
                                    break;
                            }
                            echo $maps_compile;
                            ?>
                        }
                        window.onload = initialize;
                    </script>
                    <div style="width:100%;height:500px;" id="map_canvas"></div>
                </td>
            </tr>
            <tr>
                <td colspan="9">
                    <iframe width="100%" height="500px"src="liveap.php?out=img&id=<?php echo $id; ?>"></iframe>
                </td>
            </tr>
        </table>
        <?php
        footer($_SERVER['SCRIPT_FILENAME']);
        break;
    default:
            echo "\r\n</br>oookkaaayyyy.....";
        break;
}
?>