<?php
#========================================================================================================================#
#											Header (writes the Headers for all pages)									 #
#========================================================================================================================#

function pageheader($title, $output="detailed")
{
	session_start();
	if(!isset($_SESSION['token']) or !isset($_GET['token']))
	{
		$token = md5(uniqid(rand(), true));
		$_SESSION['token'] = $token;
	}else
	{
		$token = $_SESSION['token'];
	}
	
	$root = $GLOBALS['root'];
	
	$conn	= $GLOBALS['conn'];
	$db		= $GLOBALS['db'];
	$head = $GLOBALS['headers'];
	echo "<html>\r\n<head>\r\n<title>Wireless DataBase *Alpha*".$GLOBALS['ver']['wifidb']." --> ".$title."</title>".$head."\r\n</head>\r\n";
	$sql = "SELECT `id` FROM `$db`.`files`";
	$result1 = mysql_query($sql, $conn);
	check_install_folder();	
	if(!$result1){echo "<p align=\"center\"><font color=\"red\">You need to <a class=\"upgrade\" href=\"install/upgrade/\">upgrade</a> before you will be able to properly use WiFiDB Build 3.</p></font>";}
	if($output == "detailed")
	{
		# START YOUR HTML EDITS HERE #
		?>
		<link rel="stylesheet" href="<?php if($root != ''){echo '/'.$root;}?>/css/site4.0.css">
		<body topmargin="10" leftmargin="0" rightmargin="0" bottommargin="10" marginwidth="10" marginheight="10">
		<div align="center">
		<table border="0" width="85%" cellspacing="5" cellpadding="2">
			<tr style="background-color: #315573;"><td colspan="2">
			<table width="100%"><tr>
					<td style="width: 215px">
						&nbsp;&nbsp;&nbsp;&nbsp;<a href="http://www.randomintervals.com"><img border="0" src="/<?php echo $root; ?>/img/logo.png"></a>
					</td>
					<td>
						<p align="center"><b>
						<font style="size: 5;font-family: Arial;color: #FFFFFF;">
						Wireless DataBase *Alpha* <?php echo $GLOBALS['ver']['wifidb'].'<br /><br />'; ?>
						</font>
							<?php breadcrumb($_SERVER["REQUEST_URI"]); ?>
						</b></p>
					</td>
			</tr></table>
			</td></tr>
			<tr>
				<td style="background-color: #304D80;width: 15%;vertical-align: top;">
				<img alt="" src="/wifidb/themes/wifidb/img/1x1_transparent.gif" width="185" height="1" />
				<p><a class="links" href="<?php if($root != ''){echo '/'.$root;}?>/?token=<?php echo $token;?>">Main Page</a></p>
				<p><a class="links" href="<?php if($root != ''){echo '/'.$root;}?>/all.php?sort=SSID&ord=ASC&from=0&to=100&token=<?php echo $token;?>">View All APs</a></p>
				<p><a class="links" href="<?php if($root != ''){echo '/'.$root;}?>/import/?token=<?php echo $token;?>">Import</a></p>
				<p><a class="links" href="<?php if($root != ''){echo '/'.$root;}?>/opt/scheduling.php?token=<?php echo $token;?>">Files Waiting for Import</a></p>
				<p><a class="links" href="<?php if($root != ''){echo '/'.$root;}?>/opt/export.php?func=index&token=<?php echo $token;?>">Export</a></p>
				<p><a class="links" href="<?php if($root != ''){echo '/'.$root;}?>/opt/search.php?token=<?php echo $token;?>">Search</a></p>
				<p><a class="links" href="<?php if($root != ''){echo '/'.$root;}?>/themes/?token=<?php echo $token;?>">Themes</a></p>
				<p><a class="links" href="<?php if($root != ''){echo '/'.$root;}?>/opt/userstats.php?func=allusers&token=<?php echo $token;?>">View All Users</a></p>
				<p><a class="links" href="http://forum.techidiots.net/forum/viewforum.php?f=47">Help / Support</a></p>
				<p><a class="links" href="<?php if($root != ''){echo '/'.$root;}?>/ver.php?token=<?php echo $token;?>">WiFiDB Version</a></p>
				<p><a class="links" href="<?php if($root != ''){echo '/'.$root;}?>/down.php?token=<?php echo $token;?>">Download WiFiDB</a></p>
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
		<td bgcolor="#315573" height="23"><a href="/<?php echo $root; ?>/img/moon.png"><img border="0" src="/<?php echo $root; ?>/img/moon_tn.png"></a></td>
		<td bgcolor="#315573" width="0" align="center">
		<?php
		if (file_exists($filename)) {?>
			<h6><i><u><?php echo $file;?></u></i> was last modified:  <?php echo date ("Y F d @ H:i:s", filemtime($filename));?></h6>
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