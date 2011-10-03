<?php
$ft_start = microtime(1);
error_reporting(E_ALL|E_STRICT);
$startdate="1-Oct-2011";
$lastedit="1-Oct-2011";
include('../lib/config.inc.php');
include('../lib/database.inc.php');
pageheader("Access Point Info Page");
$theme = $GLOBALS['theme'];

$ord	=	@filter_input(INPUT_GET, 'ord', FILTER_SANITIZE_SPECIAL_CHARS);
$sort	=	@filter_input(INPUT_GET, 'sort', FILTER_SANITIZE_SPECIAL_CHARS);
$from	=	@filter_input(INPUT_GET, 'from', FILTER_SANITIZE_NUMBER_INT)+0;
$from	=	$from+0;
$from_	=	$from+0;
$inc	=	@filter_input(INPUT_GET, 'to', FILTER_SANITIZE_NUMBER_INT)+0;
$inc	=	$inc+0;
if ($from=="" or !is_int($from)){$from=0;}
if ($from_=="" or !is_int($from_)){$from_=0;}
if ($inc=="" or !is_int($inc)){$inc=100;}
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
    <td>Username<a href="?sort=username&ord=ASC&from=<?php echo $from; ?>&to=<?php echo $inc; ?>"><img height="15" width="15" border="0" src="../themes/<?php echo $theme; ?>/img/down.png"></a><a href="?sort=username&ord=DESC&from=<?php echo $from; ?>&to=<?php echo $inc; ?>"><img height="15" width="15" border="0"src="../themes/<?php echo $theme; ?>/img/up.png"></a></td>
</tr>
<?php

##########

$live_aps = "live_aps";
$live_gps = "live_gps";
$row_color = 0;
date_default_timezone_set('UTC');
$date = date("Y-m-d H:i:s.u", time()-1800);
#echo $date;
$sql = "SELECT id,ssid,mac,radio,chan,auth,encry,username,Label FROM $db.$live_aps WHERE la >= '$date' ORDER BY `$sort` $ord LIMIT $from, $inc";
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

        ?>
            <tr class="<?php echo $color; ?>">
                <td align="center" onclick="expandcontract('Row<?php echo $tablerowid;?>','ClickIcon<?php echo $tablerowid;?>')" id="ClickIcon<?php echo $tablerowid;?>" style="cursor: pointer; cursor: hand;">+</td>
                <td align="center" onclick="expandcontract('Row<?php echo $tablerowid2;?>','ClickIcon<?php echo $tablerowid2;?>')" id="ClickIcon<?php echo $tablerowid2;?>" style="cursor: pointer; cursor: hand;">+</td>
                <td><a class="links" href="liveap.php?out=html&id=<?php echo $id; ?>"><?php echo $ssid; ?></a></td>
                <td><?php echo $mac; ?></td>
                <td><?php echo $chan; ?></td>
                <td><?php echo $radio; ?></td>
                <td><?php echo $auth; ?></td>
                <td><?php echo $encry; ?></td>
                <td><?php echo $array['username']; ?></td>
            </tr>
            <tr>
               <tbody id="Row<?php echo $tablerowid;?>" style="display:none">
               <td colspan="9"><iframe width="100%" height="500px"src="liveap.php?out=img&id=<?php echo $id; ?>"></iframe></td>
               </tbody>
               <tbody id="Row<?php echo $tablerowid2;?>" style="display:none">
               <td colspan="9"><iframe width="100%" height="500px"src="liveap.php?out=maps&id=<?php echo $id; ?>"></iframe></td>
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
                    <td align="center" colspan="9">
                            <b>There are no Access Points imported as of yet, go grab some with Vistumbler and import them.<br />
                            Come on... you know you want too.</b>
                    </td>
            </tr>
	<?php
}
?></table><?php
footer($_SERVER['SCRIPT_FILENAME']);
?>