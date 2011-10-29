<?php
$ft_start = microtime(1);
error_reporting(E_ALL|E_STRICT);
$startdate="1-Oct-2011";
$lastedit="1-Oct-2011";
include('../lib/config.inc.php');
include('../lib/database.inc.php');
pageheader("Access Point Info Page", "maps");
$theme = $GLOBALS['theme'];

$ord	=	@filter_input(INPUT_GET, 'ord', FILTER_SANITIZE_SPECIAL_CHARS);
$sort	=	@filter_input(INPUT_GET, 'sort', FILTER_SANITIZE_SPECIAL_CHARS);
$from	=	@filter_input(INPUT_GET, 'from', FILTER_SANITIZE_NUMBER_INT)+0;
$from	=	$from+0;
$from_	=	$from+0;
$inc	=	@filter_input(INPUT_GET, 'to', FILTER_SANITIZE_NUMBER_INT)+0;
$inc	=	$inc+0;
$view	=	@filter_input(INPUT_GET, 'view', FILTER_SANITIZE_NUMBER_INT)+0;
if ($view==0 or !is_int($view)){$view=1800;}
if ($from==0 or !is_int($from)){$from=0;}
if ($from_==0 or !is_int($from_)){$from_=0;}
if ($inc==0 or !is_int($inc)){$inc=100;}
if ($ord=="" or !is_string($ord)){$ord="ASC";}
if ($sort=="" or !is_string($sort)){$sort="chan";}
?>

<SCRIPT LANGUAGE="JavaScript">
    // Row Hide function.
    // by tcadieux
    function expandcontract(tbodyid,ClickIcon)
    {
        if (document.getElementById(ClickIcon).innerHTML == "+")
        {
            document.getElementById(tbodyid).style.display = "";
            document.getElementById(ClickIcon).innerHTML = "-";
        }else{
            document.getElementById(tbodyid).style.display = "none";
            document.getElementById(ClickIcon).innerHTML = "+";
        }
    }
</SCRIPT>
<h2>Only the Last 30 Minutes worth of APs are shown at a time.</h2>
<table border="1" width="100%" cellspacing="0">
    <tr class="style4">
        <td>
            Select Window of time to view:
        </td>
        <td>
            <a class="links" href="?sort=<?php echo $sort; ?>&ord=<?php echo $ord; ?>&from=<?php echo $from; ?>&to=<?php echo $to; ?>&view=1800">30 Minutes</a>
        </td>
        <td>
            <a class="links" href="?sort=<?php echo $sort; ?>&ord=<?php echo $ord; ?>&from=<?php echo $from; ?>&to=<?php echo $to; ?>&view=3600">60 Minutes</a>
        </td>
        <td>
            <a class="links" href="?sort=<?php echo $sort; ?>&ord=<?php echo $ord; ?>&from=<?php echo $from; ?>&to=<?php echo $to; ?>&view=7200">2 Hours</a>
        </td>
        <td>
            <a class="links" href="?sort=<?php echo $sort; ?>&ord=<?php echo $ord; ?>&from=<?php echo $from; ?>&to=<?php echo $to; ?>&view=21600">6 Hours</a>
        </td>
        <td>
            <a class="links" href="?sort=<?php echo $sort; ?>&ord=<?php echo $ord; ?>&from=<?php echo $from; ?>&to=<?php echo $to; ?>&view=86400">1 Day</a>
        </td>
        <td>
            <a class="links" href="?sort=<?php echo $sort; ?>&ord=<?php echo $ord; ?>&from=<?php echo $from; ?>&to=<?php echo $to; ?>&view=604800">1 Week</a>
        </td>
    </tr>
</table>
<table border="1" width="100%" cellspacing="0">
<tr class="style4">
    <td>Expand Graph</td>
    <td>Expand Map</td>
    <td>SSID<a href="?sort=SSID&ord=ASC&from=<?php echo $from; ?>&to=<?php echo $inc; ?>"><img height="15" width="15" border="0"border="0" src="../themes/<?php echo $theme; ?>/img/down.png"></a><a href="?sort=SSID&ord=DESC&from=<?php echo $from; ?>&to=<?php echo $inc; ?>"><img height="15" width="15" border="0"src="../themes/<?php echo $theme; ?>/img/up.png"></a></td>
    <td>MAC<a href="?sort=mac&ord=ASC&from=<?php echo $from; ?>&to=<?php echo $inc; ?>"><img height="15" width="15" border="0"src="../themes/<?php echo $theme; ?>/img/down.png"></a><a href="?sort=mac&ord=DESC&from=<?php echo $from; ?>&to=<?php echo $inc; ?>"><img height="15" width="15" border="0"src="../themes/<?php echo $theme; ?>/img/up.png"></a></td>
    <td>Chan<a href="?sort=chan&ord=ASC&from=<?php echo $from; ?>&to=<?php echo $inc; ?>"><img height="15" width="15" border="0"src="../themes/<?php echo $theme; ?>/img/down.png"></a><a href="?sort=chan&ord=DESC&from=<?php echo $from; ?>&to=<?php echo $inc; ?>"><img height="15" width="15" border="0"src="../themes/<?php echo $theme; ?>/img/up.png"></a></td>
    <td>Radio Type<a href="?sort=radio&ord=ASC&from=<?php echo $from; ?>&to=<?php echo $inc; ?>"><img height="15" width="15" border="0" src="../themes/<?php echo $theme; ?>/img/down.png"></a><a href="?sort=radio&ord=DESC&from=<?php echo $from; ?>&to=<?php echo $inc; ?>"><img height="15" width="15" border="0"src="../themes/<?php echo $theme; ?>/img/up.png"></a></td>
    <td>Authentication<a href="?sort=auth&ord=ASC&from=<?php echo $from; ?>&to=<?php echo $inc; ?>"><img height="15" width="15" border="0" src="../themes/<?php echo $theme; ?>/img/down.png"></a><a href="?sort=auth&ord=DESC&from=<?php echo $from; ?>&to=<?php echo $inc; ?>"><img height="15" width="15" border="0"src="../themes/<?php echo $theme; ?>/img/up.png"></a></td>
    <td>Encryption<a href="?sort=encry&ord=ASC&from=<?php echo $from; ?>&to=<?php echo $inc; ?>"><img height="15" width="15" border="0" src="../themes/<?php echo $theme; ?>/img/down.png"></a><a href="?sort=encry&ord=DESC&from=<?php echo $from; ?>&to=<?php echo $inc; ?>"><img height="15" width="15" border="0"src="../themes/<?php echo $theme; ?>/img/up.png"></a></td>
    <td>First Seen<a href="?sort=fa&ord=ASC&from=<?php echo $from; ?>&to=<?php echo $inc; ?>"><img height="15" width="15" border="0" src="../themes/<?php echo $theme; ?>/img/down.png"></a><a href="?sort=fa&ord=DESC&from=<?php echo $from; ?>&to=<?php echo $inc; ?>"><img height="15" width="15" border="0"src="../themes/<?php echo $theme; ?>/img/up.png"></a></td>
    <td>Last Seen<a href="?sort=lu&ord=ASC&from=<?php echo $from; ?>&to=<?php echo $inc; ?>"><img height="15" width="15" border="0" src="../themes/<?php echo $theme; ?>/img/down.png"></a><a href="?sort=lu&ord=DESC&from=<?php echo $from; ?>&to=<?php echo $inc; ?>"><img height="15" width="15" border="0"src="../themes/<?php echo $theme; ?>/img/up.png"></a></td>
    <td>Username<a href="?sort=username&ord=ASC&from=<?php echo $from; ?>&to=<?php echo $inc; ?>"><img height="15" width="15" border="0" src="../themes/<?php echo $theme; ?>/img/down.png"></a><a href="?sort=username&ord=DESC&from=<?php echo $from; ?>&to=<?php echo $inc; ?>"><img height="15" width="15" border="0"src="../themes/<?php echo $theme; ?>/img/up.png"></a></td>
</tr>
<?php

##########

$live_aps = "live_aps";
$live_gps = "live_gps";
$row_color = 0;
date_default_timezone_set('UTC');
$date = date("Y-m-d H:i:s.u", time()-$view);
#echo $date;
$sql = "SELECT id,ssid,mac,radio,chan,auth,encry,sectype,sig,fa,lu,username,Label FROM $db.$live_aps WHERE lu >= '$date' ORDER BY `$sort` $ord LIMIT $from, $inc";
$result = mysql_query($sql, $conn);
if(mysql_num_rows($result) != 0)
{
    $tablerowid = 0;
    while($array = mysql_fetch_assoc($result))
    {
        $tablerowid++;
        $tablerowid2 = $tablerowid+1;
        if($row_color == 1)
        {$row_color = 0; $color = "light";}
        else{$row_color = 1; $color = "dark";}
        $id = $array['id'];
        $ssid = $array['ssid'];
        $mac = $array['mac'];
        $mac_exp = str_split($mac,2);
        $mac = implode(":",$mac_exp);
        $chan = $array['chan'];
        $radio = $array['radio'];
        $auth = $array['auth'];
        $encry = $array['encry'];
        if($radio=="a")
        {$radio="802.11a";}
        elseif($radio=="b")
        {$radio="802.11b";}
        elseif($radio=="g")
        {$radio="802.11g";}
        elseif($radio=="n")
        {$radio="802.11n";}
        else
        {$radio="Unknown Radio";}
        $sig_exp = explode("|", $array['sig']);
        $maps_compile_a = array();
        $n=0;
        foreach($sig_exp as $sig)
        {
            $n++;
            $sig_e = explode("-", $sig);
            $gps_id = $sig_e[1];
            $sql = "SELECT * FROM `$db`.`$live_gps` WHERE `id`='$gps_id'";
            #echo $sql;
            $result_gps = mysql_query($sql);
            while($array_gps = mysql_fetch_assoc($result_gps))
            {
                #var_dump($array_gps);
                if(str_replace("N ", "", $array_gps['lat']) == "0000.0000"){continue;}
                if(str_replace("E ", "", $array_gps['long']) == "0000.0000"){continue;}
                $lat = database::convert_dm_dd($array_gps['lat']);
                $long = database::convert_dm_dd($array_gps['long']);
                $maps_compile_a[] = "
                               var myLatLng$n = new google.maps.LatLng($lat, $long);
                               var beachMarker$n = new google.maps.Marker({position: myLatLng$n, map: map, icon: image});";
            }
        }
        $maps_compile = implode("\r\n", $maps_compile_a)
        ?>
        <SCRIPT LANGUAGE="JavaScript">
            // Row Hide function.
            // by tcadieux
            function double_func<?php echo $tablerowid2; ?>(one, two)
            {
                expandcontract(one, two);
                initialize<?php echo $tablerowid2; ?>();
            }
        </SCRIPT>

            <tr class="<?php echo $color; ?>">
                <td align="center" onclick="expandcontract('<?php echo $tablerowid;?>','ClickIcon<?php echo $tablerowid;?>')" id="ClickIcon<?php echo $tablerowid;?>" style="cursor: pointer; cursor: hand;">+</td>
                <td align="center" onclick="double_func<?php echo $tablerowid2; ?>('<?php echo $tablerowid2;?>','ClickIcon<?php echo $tablerowid2;?>')" id="ClickIcon<?php echo $tablerowid2;?>" style="cursor: pointer; cursor: hand;">+</td>
                <td align="center"><a class="links" href="liveap.php?out=html&id=<?php echo $id; ?>"><?php echo $ssid; ?></a></td>
                <td align="center"><?php echo $mac; ?></td>
                <td align="center"><?php echo $chan; ?></td>
                <td align="center"><?php echo $radio; ?></td>
                <td align="center"><?php echo $auth; ?></td>
                <td align="center"><?php echo $encry; ?></td>
                <td align="center"><?php echo $array['fa']; ?></td>
                <td align="center"><?php echo $array['lu']; ?></td>
                <td align="center"><?php echo $array['username']; ?></td>
            </tr>
            <tr>
                <tbody id="<?php echo $tablerowid;?>" style="display:none">
                    <td colspan="11">
                        <iframe width="100%" height="500px"src="liveap.php?out=img&id=<?php echo $id; ?>"></iframe>
                    </td>
                </tbody>
                <tbody id="<?php echo $tablerowid2;?>" style="display:none">
                    <td colspan="11">
                        <?php
                        if($lat != "")
                        {
                            ?>
                        <script type="text/javascript" src="https://maps-api-ssl.googleapis.com/maps/api/js?sensor=false"></script>
                        <script type="text/javascript">
                            function initialize<?php echo $tablerowid2;?>() {
                                var myOptions = {
                                  zoom: 16,
                                  center: new google.maps.LatLng(<?php echo $lat; ?>, <?php echo $long; ?>),
                                  mapTypeId: google.maps.MapTypeId.ROADMAP
                                }
                                var map = new google.maps.Map(document.getElementById("map_canvas<?php echo $tablerowid2;?>"), myOptions);
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
                        </script>
                        <?php
                        }
                        ?>
                    <div style="width:100%;height:500px;" id="map_canvas<?php echo $tablerowid2;?>">
                        <?php
                        if($no_gps)
                        {
                            ?>
                        <h2>There is no valid GPS for this AP, so Maps has been disabled.</h2>
                            <?php
                        }
                        ?>
                    </div>
                    </td>
                </tbody>
            </tr>
        <?php
        $tablerowid = $tablerowid2;
        #break;
    }
}else
{
    	?>
            <tr>
                    <td align="center" colspan="11">
                            <b>There are no Access Points imported as of yet, go grab some with Vistumbler and import them.<br />
                            Come on... you know you want too.</b>
                    </td>
            </tr>
	<?php
}
?></table><?php
footer($_SERVER['SCRIPT_FILENAME']);
?>