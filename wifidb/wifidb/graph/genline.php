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

?><form action="genline.php" method="post" enctype="multipart/form-data"><?php

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
	
	echo "<input name=\"ssid\" type=\"hidden\" value=\"".$ssid."\"/>\r\n"
	."<input name=\"mac\" type=\"hidden\" value=\"".$mac."\"/>\r\n"
	."<input name=\"man\" type=\"hidden\" value=\"".$man."\"/>\r\n"
	."<input name=\"auth\" type=\"hidden\" value=\"".$auth."\"/>\r\n"
	."<input name=\"encry\" type=\"hidden\" value=\"".$encry."\"/>\r\n"
	."<input name=\"radio\" type=\"hidden\" value=\"".$radio."\"/>\r\n"
	."<input name=\"chan\" type=\"hidden\" value=\"".$chan."\"/>\r\n"
	."<input name=\"lat\" type=\"hidden\" value=\"".$lat."\"/>\r\n"
	."<input name=\"long\" type=\"hidden\" value=\"".$long."\"/>\r\n"
	."<input name=\"btx\" type=\"hidden\" value=\"".$btx."\"/>\r\n"
	."<input name=\"otx\" type=\"hidden\" value=\"".$otx."\"/>\r\n"
	."<input name=\"fa\" type=\"hidden\" value=\"".$fa."\"/>\r\n"
	."<input name=\"lu\" type=\"hidden\" value=\"".$lu."\"/>\r\n"
	."<input name=\"nt\" type=\"hidden\" value=\"".$nt."\"/>\r\n"
	."<input name=\"label\" type=\"hidden\" value=\"".$label."\"/>\r\n"
	."<input name=\"sig\" type=\"hidden\" value=\"".$sig."\"/>\r\n"
	."<input name=\"text\" type=\"hidden\" value=\"".$text."\"/>\r\n"
	."<input name=\"linec\" type=\"hidden\" value=\"".$linec."\"/>\r\n"
	."<input name=\"bgc\" type=\"hidden\" value=\"".$bgc."\"/>\r\n"
	."<input name=\"name\" type=\"hidden\" value=\"".$name."\"/>\r\n"
	."<input name=\"line\" type=\"hidden\" value=\"\"/>\r\n"
	."<input name=\"Genline\" type=\"submit\" value=\"Generate Bar Graph\"/>\r\n</form>\r\n";
	
	$graphs->wifigraphline($ssid, $mac, $man, $auth, $encry, $radio, $chan, $lat, $long, $btx, $otx, $fa, $lu, $nt, $label, $sig, $name, $bgc, $linec, $text );
	
	echo 'You can find your Wifi Graph here -> <a class="links" href="../out/graph/'.$name.'v.png">'.$name.'v.png</a>';

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
	
	echo "<input name=\"ssid\" type=\"hidden\" value=\"".$ssid."\"/>\r\n"
	."<input name=\"mac\" type=\"hidden\" value=\"".$mac."\"/>\r\n"
	."<input name=\"man\" type=\"hidden\" value=\"".$man."\"/>\r\n"
	."<input name=\"auth\" type=\"hidden\" value=\"".$auth."\"/>\r\n"
	."<input name=\"encry\" type=\"hidden\" value=\"".$encry."\"/>\r\n"
	."<input name=\"radio\" type=\"hidden\" value=\"".$radio."\"/>\r\n"
	."<input name=\"chan\" type=\"hidden\" value=\"".$chan."\"/>\r\n"
	."<input name=\"lat\" type=\"hidden\" value=\"".$lat."\"/>\r\n"
	."<input name=\"long\" type=\"hidden\" value=\"".$long."\"/>\r\n"
	."<input name=\"btx\" type=\"hidden\" value=\"".$btx."\"/>\r\n"
	."<input name=\"otx\" type=\"hidden\" value=\"".$otx."\"/>\r\n"
	."<input name=\"fa\" type=\"hidden\" value=\"".$fa."\"/>\r\n"
	."<input name=\"lu\" type=\"hidden\" value=\"".$lu."\"/>\r\n"
	."<input name=\"nt\" type=\"hidden\" value=\"".$nt."\"/>\r\n"
	."<input name=\"label\" type=\"hidden\" value=\"".$label."\"/>\r\n"
	."<input name=\"sig\" type=\"hidden\" value=\"".$sig."\"/>\r\n"
	."<input name=\"text\" type=\"hidden\" value=\"".$text."\"/>\r\n"
	."<input name=\"linec\" type=\"hidden\" value=\"".$linec."\"/>\r\n"
	."<input name=\"bgc\" type=\"hidden\" value=\"".$bgc."\"/>\r\n"
	."<input name=\"name\" type=\"hidden\" value=\"".$name."\"/>\r\n"
	."<input name=\"line\" type=\"hidden\" value=\"line\"/>\r\n"
	."<input name=\"Genline\" type=\"submit\" value=\"Generate Line Graph\" />\r\n</form>\r\n";
	
	$graphs->wifigraphbar($ssid, $mac, $man, $auth, $encry, $radio, $chan, $lat, $long, $btx, $otx, $fa, $lu, $nt, $label, $sig, $name, $bgc, $linec, $text);

	echo 'You can find your Wifi Graph here -> <a class="links" href="../out/graph/'.$name.'.png">'.$name.'.png</a>';

}
footer($_SERVER['SCRIPT_FILENAME']);
?>