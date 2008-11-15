<?php
include('../config/config.php');
include('functions.php');
$conn = mysql_connect($host, $db_user, $db_pwd);
mysql_select_db($db,$conn);
$sql = "SELECT * FROM wifi ORDER BY id ASC";
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
  $wid    = ($count*3)+38;
 }
elseif(900 < ($check3*8))
 {
  $Height = 480;
  $wid    = ($check3*8)+40;
 }
elseif(900 < ($check2*8))
 {
  $Height = 480;
  $wid    = ($check2*8)+40;
 }
elseif(900 < ($check*8))
 {
  $Height = 480;
  $wid    = ($check*8)+40;
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


$X=20;
while($count>=0)
{
  imageline($img, $X ,459, $X, 459-($signal[$count]*4), $col);
  $X++;
  imageline($img, $X ,459, $X, 459-($signal[$count]*4), $col);
  $X=$X+2;
$count--;
}

imagesetstyle($img,array($bg,$grid));
imagegrid($img,$wid,$Height,19.99,$grid);
$macs=explode(':',$mac);
$MAC=implode('-',$macs);

$name='waps/'.$MAC.'_'.$ssid.'_'.$chan.'.png';
echo '<h1>'.$ssid.'</h1><br>';
echo '<img src="waps/'.$MAC.'_'.$ssid.'_'.$chan.'.png"><br />';
ImagePNG($img, $name);

ImageDestroy($img);
}
#end gen graph

?>