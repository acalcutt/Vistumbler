<?php
include('../config/config.php');
include('functions.php');
$conn = mysql_connect($host, $db_user, $db_pwd);
mysql_select_db($db,$conn);
$sql = "SELECT * FROM wifi";
$results = mysql_query($sql, $conn) or die(mysql_error());
$n=0;
while ($newArray = mysql_fetch_array($results))
{
$id=$newArray['id'];
$waps[$n]=$id;
$n++;
}
foreach($waps as $wap)
{
$conn = mysql_connect($host, $db_user, $db_pwd);
mysql_select_db($db,$conn);
$sql = "SELECT*FROM`wifi`WHERE`id`=$wap";
$result = mysql_query($sql, $conn) or die(mysql_error());
while ($newArray = mysql_fetch_array($result))
{
$ssid = $newArray['ssid'];
$mac = $newArray['mac'];
$man = $newArray['manuf'];
$auth = $newArray['auth'];
$encry = $newArray['encry'];
$radio = $newArray['radio'];
$chan = $newArray['chan'];
$lat = $newArray['lat'];
$long = $newArray['long'];
$BTx = $newArray['btx'];
$OTx = $newArray['otx'];
$FA = $newArray['fa'];
$LU = $newArray['la'];
$NT = $newArray['nt'];
$label = $newArray['label'];
$sig = $newArray['signal'];
}
$n=0;
$nn=1;
$y=20;
$yy=21;
$u=20;
$uu=21;
if ($ssid==""or$ssid==" " )
{
$ssid="UNNAMED";
}
$signal = explode("-", $sig);
$count = count($signal);
$c1 = 'SSID: '.$ssid.'   Channel: '.$chan.'   Radio: '.$radio.'   Network: '.$NT.'   OTx: '.$OTx;
$check = strlen($c1);
$c2 = 'Mac: '.$mac.'   Auth: '.$auth.' '.$encry.'   BTx: '.$BTx.'   Lat: '.$lat.'   Long: '.$long;
$check2 = strlen($c2);
$c3 = 'Manuf: '.$man.'   Label: '.$label.'   First: '.$FA.'   Last: '.$LU;
$check3 = strlen($c3);
#FIND OUT IF THE IMG NEEDS TO BE WIDER
if(900 < ($count*3))
 {
  $Height = 480;
  $wid    = ($count*6)+38;
 }
elseif(900 < ($check3*6))
 {
  $Height = 480;
  $wid    = ($check3*6)+40;
 }
elseif(900 < ($check2*6))
 {
  $Height = 480;
  $wid    = ($check2*6)+40;
 }
elseif(900 < ($check*6))
 {
  $Height = 480;
  $wid    = ($check*6)+40;
 }
else
 {
  $wid    = 900;
  $Height = 480;
 }
$img    = ImageCreateTrueColor($wid, $Height);
$bg     = imagecolorallocate($img, 255, 255, 255);
$grid   = imagecolorallocate($img,0,0,0);
$color  = imagecolorallocate($img, 255, 0, 0);
$tcolor = imagecolorallocate($img, 0, 0, 255);
$r = rand(25,220);
$g = rand(25,220);
$b = rand(25,220);
$col = imagecolorallocate($img, $r, $g, $b);
imagefill($img,0,0,$bg); #PUT HERE SO THAT THE TEXT DOESNT HAVE BLACK FILLINGS (eww)
imagestring($img, 4, 21, 3, $c1, $tcolor);
imagestring($img, 4, 21, 23, $c2, $tcolor);
imagestring($img, 4, 21, 43, $c3, $tcolor);
#signal strenth numbers--
imagestring($img, 4, 3, 460, "0", $tcolor);
imagestring($img, 4, 3, 440, "5", $tcolor);
imagestring($img, 4, 3, 420, "10", $tcolor);
imagestring($img, 4, 3, 400, "15", $tcolor);
imagestring($img, 4, 3, 380, "20", $tcolor);
imagestring($img, 4, 3, 360, "25", $tcolor);
imagestring($img, 4, 3, 340, "30", $tcolor);
imagestring($img, 4, 3, 320, "35", $tcolor);
imagestring($img, 4, 3, 300, "40", $tcolor);
imagestring($img, 4, 3, 280, "45", $tcolor);
imagestring($img, 4, 3, 260, "50", $tcolor);
imagestring($img, 4, 3, 240, "55", $tcolor);
imagestring($img, 4, 3, 220, "60", $tcolor);
imagestring($img, 4, 3, 200, "65", $tcolor);
imagestring($img, 4, 3, 180, "70", $tcolor);
imagestring($img, 4, 3, 160, "75", $tcolor);
imagestring($img, 4, 3, 140, "80", $tcolor);
imagestring($img, 4, 3, 120, "85", $tcolor);
imagestring($img, 4, 3, 100, "90", $tcolor);
imagestring($img, 4, 3, 80,  "95", $tcolor);
imagestring($img, 4, 2, 60,  "100", $tcolor);
#end signal strenth numbers--
imagesetstyle($img, array($bg, $grid));

$n=$count-1;
$nn=$count-2;
while($count>-1)
{
    imageline($img, $y ,480-($signal[$n]*4), $y=$y+6 ,480-($signal[$nn]*4) ,$col);
    imageline($img, $u ,481-($signal[$n]*4), $u=$u+6 ,481-($signal[$nn]*4) ,$col);
    imageline($img, $yy ,480-($signal[$n]*4), $yy=$yy+6 ,480-($signal[$nn]*4) ,$col);
    imageline($img, $uu ,481-($signal[$n]*4), $uu=$uu+6 ,481-($signal[$nn]*4) ,$col);
$n--;
$nn--;
$count--;
}

imagesetstyle($img,array($bg,$grid));
imagegrid($img,$wid,$Height,19.99,$grid);
$macs=explode(':',$mac);
$MAC=implode('-',$macs);

$name='waps/'.$MAC.'_'.$ssid.'_'.$chan.'_line.png';
echo '<h1>'.$ssid.'</h1><br>';
echo '<img src="waps/'.$MAC.'_'.$ssid.'_'.$chan.'_Line.png"><br />';
ImagePNG($img, $name);

ImageDestroy($img);
}
#end gen graph

?>