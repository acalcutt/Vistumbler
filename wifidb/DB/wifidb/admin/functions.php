<?php
function dirlist($di, $title, $col1 , $wid, $desc)
{
$n=1;
   #if ($desc!=="")
   #{
      $desc_file = file($desc);
   #   $desc_exp  = explode(":" , $desc_file);
      
   #}
echo '<h1>'.$title.'</h1>';
echo '<table border="1" width="'.$wid.'%"><tr><td>'.$col1.'</td><td>Description</td></tr>';
         $dirname = $di;
         $dh = opendir($dirname) or die("couldn't open directory");
		 while (!(($file = readdir($dh)) == false))
         {
            if ((is_dir("$dirname/$file")))
            {
            if ($file == ".")
            continue;
            if ($file == "..")
            continue;
            if ($file == "tmp")
            continue;
            echo '<tr><td><a href="'.$file.'/">'.$file.'</a></td>';
            echo '<td>'.$desc_file[$n].'</td>';
            $n++;
			}
            if ((is_file("$dirname/$file")))
            {
            if ($file == ".")
            continue;
            if ($file == "..")
            continue;
            if ($file == "")
            continue;
	        if ($file == "descriptions.txt")
            continue;
	        if ($file == "sample.PNG")
            continue;
            if ($file == "tmp")
            continue;
	        if ($file == "source.php")
            continue;
	        if ($file == "source.txt")
            continue;
            echo '<tr><td><a href="'.$file.'">'.$file.'</a></td>';
            echo '<td>'.$file.'</td>';
            $n++;
			} 
		 }
         closedir($dh);
         echo '</tr></table>';
}

function imagegrid($image, $w, $h, $s, $color)
 {
  $ws = $w/$s;
  $hs = $h/$s;

  for($iw=0; $iw < $ws; ++$iw)
   {
    imageline($image, ($iw-0)*$s, 60 , ($iw-0)*$s, $w , $color);
   }

  for($ih=0; $ih<$hs; ++$ih)
   {
    imageline($image, 0, $ih*$s, $w , $ih*$s, $color);
   }
 }
 

function wifigraphline($ssid, $mac, $man, $auth, $encry, $radio, $chan, $lat, $long, $BTx, $OTx, $FA, $LU, $NT, $label, $sig, $date, $linec, $text )
{
$n=0;
$nn=1;
$y=20;
$yy=21;
$u=20;
$uu=21;
if ($text == 'rand')
{
$tr = rand(25,220);
$tg = rand(25,220);
$tb = rand(25,220);
}else{
$text_color = explode(':', $text);
$tr=$text_color[0];
$tg=$text_color[1];
$tb=$text_color[2];
}
if ($linec== 'rand')
{
$r = rand(25,220);
$g = rand(25,220);
$b = rand(25,220);
}else{
$line_color = explode(':', $linec);
$r=$line_color[0];
$g=$line_color[1];
$b=$line_color[2];
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
if(900 < ($count*6))
 {
  $Height = 480;
  $wid    = ($count*6)+40;
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
$tcolor = imagecolorallocate($img, $tr, $tg, $tb);
$col = imagecolorallocate($img, $r, $g, $b);
imagefill($img,0,0,$bg); #PUT HERE SO THAT THE TEXT DOESNT HAVE BLACK FILLINGS (eww)
imagestring($img, 4, 21, 3, $c1, $tcolor);
imagestring($img, 4, 21, 23, $c2, $tcolor);
imagestring($img, 4, 21, 43, $c3, $tcolor);
#signal strenth numbers--
$p=460;
$I=0;
while($I<105)
{
imagestring($img, 4, 3, $p, $I, $tcolor);
$I=$I+5;
$p=$p-20;
}

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
$name='../graph/waps/'.$date.'v.png';
echo '<h1>'.$ssid.'</h1><br>';
echo '<img src="'.$name.'"><br />';
ImagePNG($img, $name);
ImageDestroy($img);
}


#==============================================================================================================================================================#
#													WiFi Graph Bargraph													         #
#==============================================================================================================================================================#


function wifigraphbar($ssid, $mac, $man, $auth, $encry, $radio, $chan, $lat, $long, $BTx, $OTx, $FA, $LU, $NT, $label, $sig, $date, $linec, $text)
{
$p=460;
$I=0;

if ($text == 'rand')
{
$tr = rand(50,200);
$tg = rand(50,200);
$tb = rand(50,200);
}else{
$text_color = explode(':', $text);
$tr=$text_color[0];
$tg=$text_color[1];
$tb=$text_color[2];
}
if ($linec == 'rand')
{
$r = rand(50,200);
$g = rand(50,200);
$b = rand(50,200);
}else{
$line_color = explode(':', $linec);
$r=$line_color[0];
$g=$line_color[1];
$b=$line_color[2];
}
if ($ssid==""or$ssid==" ")
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
$tcolor = imagecolorallocate($img, $tr, $tg, $tb);
$col = imagecolorallocate($img, $r, $g, $b);
imagefill($img,0,0,$bg); #PUT HERE SO THAT THE TEXT DOESNT HAVE BLACK FILLINGS (eww)
imagestring($img, 4, 21, 3, $c1, $tcolor);
imagestring($img, 4, 21, 23, $c2, $tcolor);
imagestring($img, 4, 21, 43, $c3, $tcolor);
#signal strenth numbers--
while($I<105)
{
imagestring($img, 4, 3, $p, $I, $tcolor);
$I=$I+5;
$p=$p-20;
}

#imagestring($img, 4, 3, 440, "5", $tcolor);
#imagestring($img, 4, 3, 420, "10", $tcolor);
#imagestring($img, 4, 3, 400, "15", $tcolor);
#imagestring($img, 4, 3, 380, "20", $tcolor);
#imagestring($img, 4, 3, 360, "25", $tcolor);
#imagestring($img, 4, 3, 340, "30", $tcolor);
#imagestring($img, 4, 3, 320, "35", $tcolor);
#imagestring($img, 4, 3, 300, "40", $tcolor);
#imagestring($img, 4, 3, 280, "45", $tcolor);
#imagestring($img, 4, 3, 260, "50", $tcolor);
#imagestring($img, 4, 3, 240, "55", $tcolor);
#imagestring($img, 4, 3, 220, "60", $tcolor);
#imagestring($img, 4, 3, 200, "65", $tcolor);
#imagestring($img, 4, 3, 180, "70", $tcolor);
#imagestring($img, 4, 3, 160, "75", $tcolor);
#imagestring($img, 4, 3, 140, "80", $tcolor);
#imagestring($img, 4, 3, 120, "85", $tcolor);
#imagestring($img, 4, 3, 100, "90", $tcolor);
#imagestring($img, 4, 3, 80,  "95", $tcolor);
#imagestring($img, 4, 2, 60,  "100", $tcolor);

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
$name='tmp/'.$date.'.png';
echo '<h1>'.$ssid.'</h1><br>';
echo '<img src="'.$name.'"><br />';
ImagePNG($img, $name);
ImageDestroy($img);
}


function import($source)
{

$return = file($source);
include('../config/config.php');
$conn = mysql_connect($host, $db_user, $db_pwd);
mysql_select_db($db,$conn);
foreach($return as $ret)
{
	$wifi = explode ("|", $ret, 17);
	$sql = "SELECT*FROM `wifi` WHERE mac='$wifi[1]'";
	$result = mysql_query($sql, $conn) or die(mysql_error());
	while ($newArray = mysql_fetch_array($result))
	{
		$ssid=$newArray['ssid'];
		$mac=$newArray['mac'];
		$encry=$newArray['encry'];
		$chan=$newArray['chan'];
	}
	if ($mac!==$wifi[1]and$encry!==$wifi[4]and$chan!==$wifi[6]and$$wifi[0]!==$ssid)
	{
		if ($wifi[0]=="")
		{
		$wifi[0]="UNNAMED";
		}
		$sqlss = "INSERT INTO `wifi` ( `id` , `ssid` , `mac` , `manuf` , `auth` , `encry` , `radio` , `chan` , `lat` , `long` , `btx` , `otx` , `fa` , `la` , `nt` , `label` , `signal` ) VALUES ( '', '$wifi[0]', '$wifi[1]', '$wifi[2]', '$wifi[4]', '$wifi[5]', '$wifi[6]', '$wifi[7]', '$wifi[8]', '$wifi[9]', '$wifi[10]', '$wifi[11]', '$wifi[12]', '$wifi[13]', '$wifi[14]', '$wifi[15]' , '$wifi[16]')";
		if (mysql_query($sqlss, $conn) or die(mysql_error()))
		{
			echo $wifi[0].'-'.$wifi[1].'<br>text record added!<br>';
		}else{
			echo mysql_error();
		}
	}
	else
	{
		update($wifi);
	}
}

}

function update($source)
{

$source=$wifi;
	include('../config/config.php');
	$conn = mysql_connect($host, $db_user, $db_pwd);
	$sql = "SELECT * FROM `wifi` WHERE mac='$wifi[1]'";
	$result = mysql_query($sql, $conn) or die(mysql_error());
	while ($newArray = mysql_fetch_array($result))
	{
		$id=$newArray['id'];
		$ssid=$newArray['ssid'];
		$mac=$newArray['mac'];
		$encry=$newArray['encry'];
		$manuf=$newArray['manuf'];
		$auth=$newArray['auth'];
		$chan=$newArray['chan'];
		$radio=$newArray['radio'];
		$lat=$newArray['lat'];
		$long=$newArray['long'];
		$btx=$newArray['btx'];
		$otx=$newArray['otx'];
		$fa=$newArray['fa'];
		$la=$newArray['la'];
		$nt=$newArray['nt'];
		$label=$newArray['label'];
		$sig=$newArray['sig'];
	}
	if ($mac==$wifi[1]and$encry==$wifi[4]and$chan==$wifi[6]and$$wifi[0]==$ssid)
	{
		if ($wifi[13]!=$la)
		{
			$signal=$wifi[13].'^'.$la.'-'.$sig;
			echo $wifi[0].' '.$wifi[1].'<br>';
			$sqls ="UPDATE `wifi` SET `ssid` = '$wifi[0]', `manuf`='$wifi[2]', `auth`='$wifi[4]', `sig`='$signal' WHERE `id` = $id";
			if (mysql_query($sqls, $conn) or die(mysql_error()))
			{
				echo "AP record added!<br>";
			}
			else
			{
				echo mysql_error();
			}
		}
	}
	else
	{
		echo "---------------------<br>Could not Import or Update an Error must have orrured<br>";
		echo $wifi[0]."<br>";
		echo $wifi[1]."<br>";
		echo $wifi[2]."<br>";
		echo $wifi[3]."<br>";
		echo $wifi[4]."<br>";
		echo $wifi[5]."<br>";
		echo $wifi[6]."<br>";
		echo $wifi[7]."<br>";
		echo $wifi[8]."<br>";
		echo $wifi[9]."<br>";
		echo $wifi[10]."<br>";
		echo $wifi[11]."<br>";
		echo $wifi[12]."<br>";
		echo $wifi[13]."<br>";
		echo $wifi[14]."<br>";
		echo $wifi[15]."<br>---------------------<br>";
		continue;
	}
}

?>