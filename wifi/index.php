<?php
/////////////////////////////////////////////////////////////////
//  By: Phillip Ferland (Longbow486)                           //
//  Email: longbow486@msn.com                                  //
//  Started on: 10.14.07                                       //
//  Purpose: To generate a PNG graph of a WAP's signals        //
//           from URL driven data                              //
//  Filename: index.php								   //
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
<td width="17%" bgcolor="#304D80" valign="top">

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

<form action="genline.php" method="post" enctype="multipart/form-data">

<?php
echo '<h1>Graphing For Vistumbler '.$ver['wifi'].' *Beta*</h1>';
#$date = date('mdHis');
$ssid = $_GET['SSID'];
$mac = $_GET['Mac'];
$man = $_GET['Manuf'];
$auth = $_GET['Auth'];
$encry = $_GET['Encry'];
$radio = $_GET['radio'];
$chan = $_GET['Chn'];
$lat = $_GET['Lat'];
$long = $_GET['Long'];
$BTx = $_GET['BTx'];
$OTx = $_GET['OTx'];
$FA = $_GET['FA'];
$LU = $_GET['LU'];
$NT = $_GET['NT'];
$label = $_GET['Label'];
$sig = $_GET['Sig'];
	echo '<table style="width: 500px" cellspacing="3" cellpadding="0" class="style3"><tr><td class="style2">';
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
	?>

					Choose Graph Type: 
					<select name="graph_type" style="height: 22px; width: 139px">
	<option value="">Bar (Vertical)</option>
	<option value="line">Line (Horizontal)</option>
	</select>
					</td>
				</tr>
				<tr>
					<td class="style2">
					Choose Text Color: 
					<select name="text" style="height: 22px; width: 147px">
	<option value="255:000:000">Red</option>
	<option value="000:255:000">Green</option>
	<option value="000:000:255">Blue</option>
	<option value="000:000:000">Black</option>
	<option value="255:255:000">Yellow</option>
	<option value="255:128:000">Orange</option>
	<option value="128:064:000">Brown</option>
	<option value="000:255:255">Sky Blue</option>
	<option value="064:000:128">Purple</option>
	<option value="128:128:128">Grey</option>
	<option value="226:012:243">Pink</option>
	<option value="rand">Random</option>
	</select>
					
					</td>
				</tr>
					<tr>
					<td class="style2">
					Choose Background Color:
					<select name="bgc" style="height: 22px; width: 147px">
	<option value="000:000:000">Black</option>
	<option value="255:255:255">White</option>
	</select>
					
					</td>
				</tr>

		<tr>
					<td class="style2">
					Choose Line Color:<select name="linec" style="width: 153px">
	<option value="255:000:000">Red</option>
	<option value="000:255:000">Green</option>
	<option value="000:000:255">Blue</option>
	<option value="000:000:000">Black</option>
	<option value="255:255:000">Yellow</option>
	<option value="255:128:000">Orange</option>
	<option value="128:064:000">Brown</option>
	<option value="000:255:255">Sky Blue</option>
	<option value="064:000:128">Purple</option>
	<option value="128:128:128">Grey</option>
	<option value="226:012:243">Pink</option>
	<option value="rand">Random</option>
	</select>
					
					</td>
				</tr>
				<tr>
					<td class="style2">
					<input name="Submit1" type="submit" value="Generate Graph" />
					</form>
					</td>
				</tr>
			</table>
<br>
<a class="links" href="http://vistumbler.svn.sourceforge.net/viewvc/vistumbler/wifi">Source</a><br>
<a class="links" href="ver.php">Version History</a><br>
<a class="links" href="http://forum.techidiots.net/forum/viewforum.php?f=22">Forum</a><br><font size="1">[located at Techidiots.net]</font><br>


			</td>
</tr>
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
