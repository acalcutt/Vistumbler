<?php
/////////////////////////////////////////////////////////////////
//  By: Phillip Ferland (Longbow486)                           //
//  Email: longbow486@msn.com                                  //
//  Started on: 10.14.07                                       //
//  Purpose: To generate a PNG graph of a WAP's signals        //
//           from URL driven data                              //
//  Filename: genlineurl.php								   //
//	License: GLPv2			                                   //
/////////////////////////////////////////////////////////////////
include('functions.php');
$lastedit="2010-June-13";
?>
<title>Vistumbler to PNG Signal Graph <?php echo $ver['wifi']; ?> Beta - ---RanInt---</title>
<link rel="stylesheet" href="/css/site4.0.css">
<body topmargin="10" leftmargin="0" rightmargin="0" bottommargin="10" marginwidth="10" marginheight="10">
<div align="center">
<table border="0" width="75%" cellspacing="10" cellpadding="2">
	<tr>
		<td bgcolor="#315573">
		<p align="center"><b><font size="5" face="Arial" color="#FFFFFF">
		Vistumbler to PNG Ver <?php echo $ver['wifi']." Beta"; ?> </font>
		<font color="#FFFFFF" size="2">
            <a class="links" href="/">[Root] </a>/ <a class="links" href="/wifi/apps.php">[WiFi Apps] </a>/
		</font></b>
		</td>
	</tr>
</table>
</div>
<div align="center">
<table border="0" width="75%" cellspacing="10" cellpadding="2" height="90">
	<tr>
<td style="width: 170px" bgcolor="#304D80" valign="top">

<?php
#PUT YOUR LINKS HERE#
?>

</td>
		<td width="80%" bgcolor="#A9C6FA" valign="top" align="center">
			<p align="center">
<script src="http://www.google-analytics.com/urchin.js" type="text/javascript">
</script>
<script type="text/javascript">
_uacct = "UA-1353860-1";
urchinTracker();
</script>
<?php
if($_POST['graph_type']==='line')
{
$date = date('mdHis');
	$ssid = $_POST['ssid'];
	$mac = $_POST['mac'];
	$man = $_POST['man'];
	$auth = $_POST['auth'];
	$encry = $_POST['encry'];
	$radio = $_POST['radio'];
	$chan = $_POST['chan'];
	$lat = $_POST['lat'];
	$long = $_POST['long'];
	$BTx = $_POST['btx'];
	$OTx = $_POST['otx'];
	$FA = $_POST['FA'];
	$LU = $_POST['LU'];
	$NT = $_POST['NT'];
	$label = $_POST['label'];
	$sig = $_POST['sig'];
	$text = $_POST['text'];
	$linec = $_POST['linec'];
	$bgc = $_POST['bgc'];
	echo '<form action="genline.php" method="post" enctype="multipart/form-data">';
	echo '<input name="ssid" type="hidden" value="'.$ssid.'"/>';
	echo '<input name="mac" type="hidden" value="'.$mac.'"/>';
	echo '<input name="man" type="hidden" value="'.$man.'"/>';
	echo '<input name="auth" type="hidden" value="'.$auth.'"/>';
	echo '<input name="encry" type="hidden" value="'.$encry.'"/>';
	echo '<input name="radio" type="hidden" value="'.$radio.'"/>';
	echo '<input name="chan" type="hidden" value="'.$chan.'"/>';
	echo '<input name="lat" type="hidden" value="'.$lat.'"/>';
	echo '<input name="long" type="hidden" value="'.$long.'"/>';
	echo '<input name="btx" type="hidden" value="'.$BTx.'"/>';
	echo '<input name="otx" type="hidden" value="'.$OTx.'"/>';
	echo '<input name="FA" type="hidden" value="'.$FA.'"/>';
	echo '<input name="LU" type="hidden" value="'.$LU.'"/>';
	echo '<input name="NT" type="hidden" value="'.$NT.'"/>';
	echo '<input name="label" type="hidden" value="'.$label.'"/>';
	echo '<input name="sig" type="hidden" value="'.$sig.'"/>';
	echo '<input name="text" type="hidden" value="'.$text.'"/>';
	echo '<input name="bgc" type="hidden" value="'.$bgc.'"/>';
	echo '<input name="linec" type="hidden" value="'.$linec.'"/>';
	echo '<input name="graph_type" type="hidden" value=""/>';
	echo '<input name="Genline" type="submit" value="Generate Bar Graph" />';
	echo '</form>';
	wifigraphline($ssid, $mac, $man, $auth, $encry, $radio, $chan, $lat, $long, $BTx, $OTx, $FA, $LU, $NT, $label, $sig, $date, $linec, $text, $bgc );
?>
You can find your Wifi Graph here -> <a href="tmp/<?php echo $date;?>v.png"><?php echo$date;?>v.png</a>
<?php
	}else
	{
$date = date('mdHis');
	$ssid = $_POST['ssid'];
	$mac = $_POST['mac'];
	$man = $_POST['man'];
	$auth = $_POST['auth'];
	$encry = $_POST['encry'];
	$radio = $_POST['radio'];
	$chan = $_POST['chan'];
	$lat = $_POST['lat'];
	$long = $_POST['long'];
	$BTx = $_POST['btx'];
	$OTx = $_POST['otx'];
	$FA = $_POST['FA'];
	$LU = $_POST['LU'];
	$NT = $_POST['NT'];
	$label = $_POST['label'];
	$sig = $_POST['sig'];
	$text = $_POST['text'];
	$bgc = $_POST['bgc'];
	$linec = $_POST['linec'];
	echo '<form action="genline.php" method="post" enctype="multipart/form-data">';
	echo '<input name="ssid" type="hidden" value="'.$ssid.'"/>';
	echo '<input name="mac" type="hidden" value="'.$mac.'"/>';
	echo '<input name="man" type="hidden" value="'.$man.'"/>';
	echo '<input name="auth" type="hidden" value="'.$auth.'"/>';
	echo '<input name="encry" type="hidden" value="'.$encry.'"/>';
	echo '<input name="radio" type="hidden" value="'.$radio.'"/>';
	echo '<input name="chan" type="hidden" value="'.$chan.'"/>';
	echo '<input name="lat" type="hidden" value="'.$lat.'"/>';
	echo '<input name="long" type="hidden" value="'.$long.'"/>';
	echo '<input name="btx" type="hidden" value="'.$BTx.'"/>';
	echo '<input name="otx" type="hidden" value="'.$OTx.'"/>';
	echo '<input name="FA" type="hidden" value="'.$FA.'"/>';
	echo '<input name="LU" type="hidden" value="'.$LU.'"/>';
	echo '<input name="NT" type="hidden" value="'.$NT.'"/>';
	echo '<input name="label" type="hidden" value="'.$label.'"/>';
	echo '<input name="sig" type="hidden" value="'.$sig.'"/>';
	echo '<input name="text" type="hidden" value="'.$text.'"/>';
	echo '<input name="linec" type="hidden" value="'.$linec.'"/>';
	echo '<input name="bgc" type="hidden" value="'.$bgc.'"/>';
	echo '<input name="graph_type" type="hidden" value="line"/>';
	echo '<input name="Genline" type="submit" value="Generate Line Graph" />';
	echo '</form>';
	wifigraphbar($ssid, $mac, $man, $auth, $encry, $radio, $chan, $lat, $long, $BTx, $OTx, $FA, $LU, $NT, $label, $sig, $date, $linec, $text, $bgc );
?>
You can find your Wifi Graph here -> <a href="tmp/<?php echo $date;?>.png"><?php echo$date;?>.png</a>
<?php
	}
?>
If your graph is coming up blank or missing data please go <a class="links" href="http://forum.techidiots.net/forum/viewthread.php?tid=7" targe="_blank">Here</a>
<br>Your image will be available for aprox the next 30 min.<br />Source is right <a class="links" href="http://vistumbler.svn.sourceforge.net/viewvc/vistumbler/wifi">here</a><br />
You can view the Version History <a class="links" href="ver.php">here</a><br />
<br />
<font size="1">Please use Vistumbler to gather the data.<br />
You can get it <a class="links" href="http://techidiots.net/project-pages/vistumbler/" target="_blank">here</a></font></td></tr>
<tr>
<td bgcolor="#315573" height="23"><a href="/pictures/moon.png"><img border="0" src="/pictures/moon_tn.PNG"></a></td>
<td bgcolor="#315573" width="0">

<script type="text/javascript"><!--
google_ad_client = "pub-6007574915683746";
/* 728x90, created 9/2/08 */
google_ad_slot = "5238761466";
google_ad_width = 728;
google_ad_height = 90;
//-->
</script>
<script type="text/javascript"
src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
</script>

</td>
</tr>
</table>
</div>
</html>