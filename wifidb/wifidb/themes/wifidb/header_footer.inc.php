<?php
#========================================================================================================================#
#											Header (writes the Headers for all pages)									 #
#========================================================================================================================#

function pageheader($title, $output="detailed")
{
	session_start();
	if(!$_SESSION['token'] or !$_GET['token'])
	{
		$token = md5(uniqid(rand(), true));
		$_SESSION['token'] = $token;
	}else
	{
		$token = $_SESSION['token'];
	}
	
	$root	= 	$GLOBALS['root'];
	$hosturl	= 	$GLOBALS['hosturl'];
	$conn	=	$GLOBALS['conn'];
	$db		=	$GLOBALS['db'];
	$head	= 	$GLOBALS['headers'];
	
	echo "<html>\r\n<head>\r\n<title>Wireless DataBase".$GLOBALS['ver']['wifidb']." --> ".$title."</title>\r\n".$head."\r\n</head>\r\n";
	check_install_folder();
	if(!$GLOBALS['default_theme']){echo '<p align="center"><font color="red" size="6">You need to upgrade to Build 4!</font><font color="red" size="3"><br> Please go <a href="http://'.$_SERVER["SERVER_NAME"].'/wifidb/install/index2.php">/[WiFiDB]/install/index2.php</a> to do that.</font></font></p>';}
	$sql = "SELECT `id` FROM `$db`.`files`";
	$result1 = mysql_query($sql, $conn);
	if(!$result1){echo "<p align=\"center\"><font color=\"red\">You need to <a class=\"upgrade\" href=\"install/upgrade/\">upgrade</a> before you will be able to properly use WiFiDB Build 3.</p></font>";}

	if($output == "detailed")
	{
		# START YOUR HTML EDITS HERE #
		?>
		<link rel="stylesheet" href="<?php if($root != ''){echo $hosturl.$root;}?>/themes/wifidb/styles.css">
		<body topmargin="10" leftmargin="0" rightmargin="0" bottommargin="10" marginwidth="10" marginheight="10">
		<div align="center">
		<table border="0" width="85%" cellspacing="5" cellpadding="2">
			<tr style="background-color: #315573;"><td colspan="2">
			<table width="100%"><tr>
					<td style="width: 215px">
						&nbsp;&nbsp;&nbsp;&nbsp;<a href="http://www.randomintervals.com"><img border="0" src="<?php echo $hosturl.$root; ?>/img/logo.png"></a>
					</td>
					<td>
						<p align="center"><b>
						<font style="size: 5;font-family: Arial;color: #FFFFFF;">
						Wireless DataBase<?php echo $GLOBALS['ver']['wifidb'].'<br /><br />'; ?>
						</font>
							<?php breadcrumb($_SERVER["REQUEST_URI"]); ?>
						</b></p>
					</td>
			</tr></table>
			</td></tr>
			<tr>
				<td style="background-color: #304D80;width: 15%;vertical-align: top;">
				<img alt="" src="/wifidb/themes/wifidb/img/1x1_transparent.gif" width="185" height="1" /><br>
				<a class="links" href="<?php if($root != ''){echo $hosturl.$root;}?>/?token=<?php echo $token;?>">Main Page</a><br>
				<a class="links" href="<?php if($root != ''){echo $hosturl.$root;}?>/all.php?sort=SSID&ord=ASC&from=0&to=100&token=<?php echo $token;?>">View All APs</a><br>
				<a class="links" href="<?php if($root != ''){echo $hosturl.$root;}?>/import/?token=<?php echo $token;?>">Import</a><br>
				<a class="links" href="<?php if($root != ''){echo $hosturl.$root;}?>/opt/scheduling.php?token=<?php echo $token;?>">Files Waiting for Import</a><br>
				<a class="links" href="<?php if($root != ''){echo $hosturl.$root;}?>/opt/scheduling.php?func=done&token=<?php echo $token;?>">Files Already Imported</a><br>
				<a class="links" href="<?php if($root != ''){echo $hosturl.$root;}?>/opt/scheduling.php?func=daemon_kml&token=<?php echo $token;?>">Daemon Generated KML</a><br>
				<a class="links" href="<?php if($root != ''){echo $hosturl.$root;}?>/console/?token=<?php echo $token;?>">Daemon Console</a><br>
				<a class="links" href="<?php if($root != ''){echo $hosturl.$root;}?>/opt/export.php?func=index&token=<?php echo $token;?>">Export</a><br>
				<a class="links" href="<?php if($root != ''){echo $hosturl.$root;}?>/opt/search.php?token=<?php echo $token;?>">Search</a><br>
				<a class="links" href="<?php if($root != ''){echo $hosturl.$root;}?>/themes/?token=<?php echo $token;?>">Themes</a><br>
				<a class="links" href="<?php if($root != ''){echo $hosturl.$root;}?>/opt/userstats.php?func=allusers&token=<?php echo $token;?>">View All Users</a><br>
				<a class="links" href="http://forum.techidiots.net/forum/viewforum.php?f=47">Help / Support</a><br>
				<a class="links" href="<?php if($root != ''){echo $hosturl.$root;}?>/ver.php?token=<?php echo $token;?>">WiFiDB Versions</a><br>
			</td>
			<td style="background-color: #A9C6FA;width: 80%;vertical-align: top;" align="center">
			<p align="center">
			<br>
		<!-- KEEP BELOW HERE -->
		<?php
	}
}



#========================================================================================================================#
#									Footer (writes the footer for all pages)								#
#========================================================================================================================#

function footer($filename = '', $output = "detailed")
{
	$tracker = $GLOBALS['tracker'];
	$ads = $GLOBALS['ads'];
	$file_ex = explode("/", $filename);
	$count = count($file_ex);
	$filename = $file_ex[($count)-1];
	if($output == "detailed")
	{
		?>
		</p>
		<br>
		</td>
		</tr>
		<tr>
		<td bgcolor="#315573" height="23"><a href="/<?php echo $GLOBALS['root']; ?>/themes/wifidb/img/moon.png"><img border="0" src="/<?php echo $GLOBALS['root']; ?>/themes/wifidb/img/moon_tn.png"></a></td>
		<td bgcolor="#315573" width="0" align="center">
		<?php
		if (file_exists($filename)) {?>
			<h6><i><u><?php echo $file;?></u></i> was last modified:  <?php echo date ("Y F d @ H:i:s", filemtime($filename));?></h6>
		</td>
		</tr>
		<tr>
		<td></td>
		<td align="center">
		<?php
		}
		echo $tracker;
		echo $ads;
		?>
		</td>
		</tr>

		</table>
		</body>
		</html>
		<?php
	}
}

?>