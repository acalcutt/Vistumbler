<?php
/////////////////////////////////////////////////////////////////
//  By: Phillip Ferland (Longbow486)                           //
//  Email: longbow486@msn.com                                  //
//  Started on: 2007-Oct-14                                    //
//  Purpose: To generate a PNG graph of a WAP's signals        //
//           from URL driven data                              //
//  Filename: genline.php                                      //
/////////////////////////////////////////////////////////////////

$startdate = "14-Oct-2009";
$lastedit  = "03-Jun-2009";

include('../lib/database.inc.php');
pageheader("Graph AP Signal History Page");
include('../lib/config.inc.php');
include('../lib/graph.inc.php');

?><form action="genline.php?token=<?php echo $_SESSION['token'];?>"" method="post" enctype="multipart/form-data"><?php

$graphs = new graphs();
if($_POST['line']==='line')
{
	$name = $_POST['name'];
	$ssid = $_POST['ssid'];
	$mac = $_POST['mac'];
	$man = $_POST['man'];
	$auth = $_POST['auth'];
	$encry = $_POST['encry'];
	$radio = $_POST['radio'];
	$chan = $_POST['chan'];
	$lat = $_POST['lat'];
	$long = $_POST['long'];
	$btx = $_POST['btx'];
	$otx = $_POST['otx'];
	$fa = $_POST['fa'];
	$lu = $_POST['lu'];
	$nt = $_POST['nt'];
	$label = $_POST['label'];
	$sig = $_POST['sig'];
	$text = $_POST['text'];
	$linec = $_POST['linec'];
	$bgc = $_POST['bgc'];
	
	echo '<input name="ssid" type="hidden" value="'.$ssid.'"/>'
	.'<input name="mac" type="hidden" value="'.$mac.'"/>'
	.'<input name="man" type="hidden" value="'.$man.'"/>'
	.'<input name="auth" type="hidden" value="'.$auth.'"/>'
	.'<input name="encry" type="hidden" value="'.$encry.'"/>'
	.'<input name="radio" type="hidden" value="'.$radio.'"/>'
	.'<input name="chan" type="hidden" value="'.$chan.'"/>'
	.'<input name="lat" type="hidden" value="'.$lat.'"/>'
	.'<input name="long" type="hidden" value="'.$long.'"/>'
	.'<input name="btx" type="hidden" value="'.$btx.'"/>'
	.'<input name="otx" type="hidden" value="'.$otx.'"/>'
	.'<input name="fa" type="hidden" value="'.$fa.'"/>'
	.'<input name="lu" type="hidden" value="'.$lu.'"/>'
	.'<input name="nt" type="hidden" value="'.$nt.'"/>'
	.'<input name="label" type="hidden" value="'.$label.'"/>'
	.'<input name="sig" type="hidden" value="'.$sig.'"/>'
	.'<input name="text" type="hidden" value="'.$text.'"/>'
	.'<input name="linec" type="hidden" value="'.$linec.'"/>'
	.'<input name="bgc" type="hidden" value="'.$bgc.'"/>'
	.'<input name="name" type="hidden" value="'.$name.'"/>'
	.'<input name="line" type="hidden" value=""/>'
	.'<input name="Genline" type="submit" value="Generate Bar Graph" /></form>';
	
	$graphs->wifigraphline($ssid, $mac, $man, $auth, $encry, $radio, $chan, $lat, $long, $btx, $otx, $fa, $lu, $nt, $label, $sig, $name, $bgc, $linec, $text );
	
	echo 'You can find your Wifi Graph here -> <a href="../out/graph/'.$name.'v.png">'.$name.'v.png</a>';

}else
{
	$name = $_POST['name'];
	$ssid = $_POST['ssid'];
	$mac = $_POST['mac'];
	$man = $_POST['man'];
	$auth = $_POST['auth'];
	$encry = $_POST['encry'];
	$radio = $_POST['radio'];
	$chan = $_POST['chan'];
	$lat = $_POST['lat'];
	$long = $_POST['long'];
	$btx = $_POST['btx'];
	$otx = $_POST['otx'];
	$fa = $_POST['fa'];
	$lu = $_POST['lu'];
	$nt = $_POST['nt'];
	$label = $_POST['label'];
	$sig = $_POST['sig'];
	$text = $_POST['text'];
	$linec = $_POST['linec'];
	$bgc = $_POST['bgc'];
	
	echo '<input name="ssid" type="hidden" value="'.$ssid.'"/>'
	.'<input name="mac" type="hidden" value="'.$mac.'"/>'
	.'<input name="man" type="hidden" value="'.$man.'"/>'
	.'<input name="auth" type="hidden" value="'.$auth.'"/>'
	.'<input name="encry" type="hidden" value="'.$encry.'"/>'
	.'<input name="radio" type="hidden" value="'.$radio.'"/>'
	.'<input name="chan" type="hidden" value="'.$chan.'"/>'
	.'<input name="lat" type="hidden" value="'.$lat.'"/>'
	.'<input name="long" type="hidden" value="'.$long.'"/>'
	.'<input name="btx" type="hidden" value="'.$btx.'"/>'
	.'<input name="otx" type="hidden" value="'.$otx.'"/>'
	.'<input name="fa" type="hidden" value="'.$fa.'"/>'
	.'<input name="lu" type="hidden" value="'.$lu.'"/>'
	.'<input name="nt" type="hidden" value="'.$nt.'"/>'
	.'<input name="label" type="hidden" value="'.$label.'"/>'
	.'<input name="sig" type="hidden" value="'.$sig.'"/>'
	.'<input name="text" type="hidden" value="'.$text.'"/>'
	.'<input name="linec" type="hidden" value="'.$linec.'"/>'
	.'<input name="bgc" type="hidden" value="'.$bgc.'"/>'
	.'<input name="name" type="hidden" value="'.$name.'"/>'
	.'<input name="line" type="hidden" value=""/>'
	.'<input name="Genline" type="submit" value="Generate Line Graph" /></form>';
	
	$graphs->wifigraphbar($ssid, $mac, $man, $auth, $encry, $radio, $chan, $lat, $long, $btx, $otx, $fa, $lu, $nt, $label, $sig, $name, $bgc, $linec, $text);

	echo 'You can find your Wifi Graph here -> <a href="../out/graph/'.$name.'.png">'.$name.'.png</a>';

}
footer($_SERVER['SCRIPT_FILENAME']);
?>