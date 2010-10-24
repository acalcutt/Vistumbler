<?php
global $screen_output;
$screen_output = "CLI";
include 'demo/lib/config.inc.php' ;
include 'demo/lib/database.inc.php';

$head	= 	$GLOBALS['headers'];

echo $root."<html>\r\n<head>\r\n<title>Wireless DataBase".$GLOBALS['ver']['wifidb']." --> WiFiDB Dir Tree Structure</title>\r\n".$head."\r\n</head>\r\n";

# START YOUR HTML EDITS HERE #
?>
<link rel="stylesheet" href="demo/themes/wifidb/styles.css">
<body topmargin="10" leftmargin="0" rightmargin="0" bottommargin="10" marginwidth="10" marginheight="10">
<div align="center">
<table border="0" width="85%" cellspacing="5" cellpadding="2">
	<tr style="background-color: #315573;"><td colspan="2">
	<table width="100%"><tr>
			<td style="width: 215px">
				&nbsp;&nbsp;&nbsp;&nbsp;<a href="http://www.randomintervals.com/wifidb/"><img border="0" src="/wifidb/demo/img/logo.png"></a>
			</td>
			<td>
				<p align="center"><b>
				<font style="size: 5;font-family: Arial;color: #FFFFFF;">
				Wireless DataBase<?php echo $GLOBALS['ver']['wifidb'].'<br /><br />'; ?>
				</font>
				</b></p>
			</td>
	</tr></table>
	</td></tr>
	<tr>
		<td style="background-color: #304D80;width: 15%;vertical-align: top;">
		<img alt="" src="/wifidb/themes/wifidb/img/1x1_transparent.gif" width="185" height="1" /><br>
		<a class="links" href="demo/">Main Page</a><br>
		<a class="links" href="demo/all.php?sort=SSID&ord=ASC&from=0&to=100">View All APs</a><br>
		<a class="links" href="demo/import/">Import</a><br>
		<a class="links" href="demo/opt/scheduling.php">Files Waiting for Import</a><br>
		<a class="links" href="demo/opt/scheduling.php?func=done">Files Already Imported</a><br>
		<a class="links" href="demo/opt/scheduling.php?func=daemon_kml">Daemon Generated KML</a><br>
		<a class="links" href="demo/opt/export.php?func=index">Export</a><br>
		<a class="links" href="demo/opt/search.php">Search</a><br>
		<a class="links" href="demo/themes/">Themes</a><br>
		<a class="links" href="demo/opt/userstats.php?func=allusers">View All Users</a><br>
		<a class="links" href="http://forum.techidiots.net/forum/viewforum.php?f=47">Help / Support</a><br>
		<a class="links" href="demo/ver.php">WiFiDB Version</a><br>
		<a class="links" href="http://www.randomintervals.com/wifidb/down.php">Download WiFiDB</a><br>
		<form action="https://www.paypal.com/cgi-bin/webscr" method="post">
<input type="hidden" name="cmd" value="_s-xclick">
<input type="hidden" name="hosted_button_id" value="8658233">
<input type="image" src="https://www.paypal.com/en_US/i/btn/btn_donate_LG.gif" border="0" name="submit" alt="PayPal - The safer, easier way to pay online!">
<img alt="" border="0" src="https://www.paypal.com/en_US/i/scr/pixel.gif" width="1" height="1">
</form>

	</td>
	<td style="background-color: #A9C6FA;width: 80%;vertical-align: top;" align="center">
	<br>
	<h2>WiFiDB Dir Tree Structure</h2>
	<p align="center">
	<br>
	<!-- KEEP BELOW HERE -->
<font face="Courier New">
<table><tr><th>Filename</th><th>File Size</th><th>File Info</th></tr>
<?php
$file = file('tree.txt');
foreach($file as $line)
{
	# EXPECTING something similar to: |-- [       4371]  index.php	//The Main Index page for WiFiDB
	if($line == '/wifidb/'){echo "<h2>".$line."</h2>";continue;}
	if($line == '\r\n' or $line == ''){echo "<tr><td colspan=\"3\"></td></tr>";continue;}
	
	preg_match('[\[[ + 0-9]+]', $line, $size);
	#				$line													|=| 	$size
	#	|-- [       4371]  index.php	//The Main Index page for WiFiDB    |=|	[       4371]
	
#	$fileline = preg_replace('[\[[ + 0-9]+]', '');
	#				$line									|=| 	$size
	#	|--  index.php	//The Main Index page for WiFiDB    |=|	[       4371]
	$explode = explode("	//", $line);
	$file = $explode[0];
	$info = $explode[1];
	#		$file		|=| 	$size		|=|	$info
	#	|--  index.php	|=|	[       4371]	|=|	The Main Index page for WiFiDB
	
	$fsize = str_replace("[ ", "", $size[0]);
	$fsize = $fsize+0;
	?><tr><td  class="tree" width="30%"><?php echo $file;?></td><td class="tree" width="20%"><?php echo "[ ".$fsize."KB ]";?></td><td width="50%" class="tree">&nbsp;&nbsp;<?php echo $info;?></td></tr>
	<?php
}
?>
</table>
</font>
<?php
	$tracker = $GLOBALS['tracker'];
	$ads = $GLOBALS['ads'];
	$filename = $_SERVER['SCRIPT_FILENAME'];
	$file_ex = explode("/", $filename);
	$count = count($file_ex);
	$filename = $file_ex[($count)-1];
	?>
	</p>
	<br>
	</td>
	</tr>
	<tr>
	<td bgcolor="#315573" height="23"><a href="demo/themes/wifidb/img/moon.png"><img border="0" src="demo/themes/wifidb/img/moon_tn.png"></a></td>
	<td bgcolor="#315573" width="0" align="center">
	<?php
	if (file_exists($filename)) {?>
		<h6><i><u><?php echo $file;?></u></i> was last modified:  <?php echo date ("Y F d @ H:i:s", filemtime($filename));}?></h6>
	</td>
	</tr>
	<tr>
	<td></td>
	<td align="center">
		<!-- Begin Analytics Tracking Code -->
		<script type="text/javascript">
			var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
			document.write(unescape("%3Cscript src=\'" + gaJsHost + "google-analytics.com/ga.js\' type=\'text/javascript\'%3E%3C/script%3E"));
		</script>
		<script type="text/javascript">
			try {
			var pageTracker = _gat._getTracker("UA-6849049-1");
			pageTracker._trackPageview();
			} catch(err) {}
		</script>
		<!-- End Analytics Tracking Code-->
	</td>
	</tr>
	</table>
	</body>
	</html>