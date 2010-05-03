<?php
#========================================================================================================================#
#											Header (writes the Headers for all pages)									 #
#========================================================================================================================#

function pageheader($title, $output="detailed")
{
	global $login_check, $host_url;
	
	$root		= 	$GLOBALS['root'];
	$hosturl	= 	$GLOBALS['hosturl'];
	$conn		=	$GLOBALS['conn'];
	$db			=	$GLOBALS['db'];
	$head		= 	$GLOBALS['header'];
	$half_path	=	$GLOBALS['half_path'];
	include_once($half_path.'/lib/database.inc.php');
	include_once($half_path.'/lib/security.inc.php');
	include_once($half_path.'/lib/config.inc.php');
	if($root != '' or $root != '/')
	{
		$max = strlen($hosturl);
		if($hosturl[$max-1] != '/')
		{
			$host_url = $hosturl.'/'.$root;
	#		echo $hosturl."<BR>";
		}
		$host_url = $hosturl.$root;
	#	echo $hosturl."<BR>";
	}
	else
	{
		$host_url = $hosturl;
	}
#	echo $host_url;
	
	$sec = new security();
	
	echo "<html>\r\n<head>\r\n<title>Wireless DataBase".$GLOBALS['ver']['wifidb']." --> ".$title."</title>\r\n".$head."\r\n</head>\r\n";
	check_install_folder();
	if($output == "detailed")
	{
		$login_check = $sec->login_check();
		if(is_array($login_check))
		{
			$login_check = 0;
		}
		# START YOUR HTML EDITS HERE #
		?>
		<link rel="stylesheet" href="<?php echo $host_url; ?>/themes/vistumbler/styles.css">
			<body style="background-color: #145285">
			<table style="width: 100%; " class="no_border" align="center">
				<tr>
					<td>
					<table>
						<tr>
							<td style="width: 228px">
							<a href="http://www.randomintervals.com">
							<img alt="Random Intervals Logo" src="<?php echo $host_url;?>/themes/vistumbler/img/logo.png" class="no_border" /></a></td>
						</tr>
					</table>

					</td>
				</tr>
			</table>
			<table style="width: 90%" align="center">
				<tr>
					<td style="width: 165px; height: 114px" valign="top">
						<table style="width: 100%" cellpadding="0" cellspacing="0">
							<tr>
								<td style="width: 10px; height: 20px" class="cell_top_left">
									<img alt="" src="<?php echo $host_url; ?>/themes/vistumbler/img/1x1_transparent.gif" width="10" height="1" />
								</td>
								<td class="cell_top_mid" style="height: 20px">
									<img alt="" src="<?php echo $host_url; ?>/themes/vistumbler/img/1x1_transparent.gif" width="185" height="1" />
								</td>
								<td style="width: 10px" class="cell_top_right">
									<img alt="" src="<?php echo $host_url; ?>/themes/vistumbler/img/1x1_transparent.gif" width="10" height="1" />
								</td>
							</tr>
							<tr>
								<td class="cell_side_left">&nbsp;</td>
								<td class="cell_color">
									<div class="inside_dark_header">WiFiDB Links</div>
									<div class="inside_text_bold"><strong>
										<a href="<?php echo $host_url;?>/">Main Page</a></strong></div>
									<div class="inside_text_bold"><strong>
										<a href="<?php echo $host_url;?>/all.php?sort=SSID&ord=ASC&from=0&to=100">View All APs</a></strong></div>
									<div class="inside_text_bold"><strong>
										<a href="<?php echo $host_url;?>/import/">Import</a></strong></div>
									<div class="inside_text_bold"><strong>
										<a href="<?php echo $host_url;?>/opt/scheduling.php">Files Waiting for Import</a></strong></div>
									<div class="inside_text_bold"><strong>
										<a href="<?php echo $host_url;?>/opt/scheduling.php?func=done">Files Already Imported</a></strong></div>
									<div class="inside_text_bold"><strong>
										<a href="<?php echo $host_url;?>/opt/scheduling.php?func=daemon_kml">Daemon Generated kml</a></strong></div>
									<div class="inside_text_bold"><strong>
										<a href="<?php echo $host_url;?>/console/">Daemon Console</a></strong></div>
									<div class="inside_text_bold"><strong>
										<a href="<?php echo $host_url;?>/opt/export.php?func=index">Export</a></strong></div>
									<div class="inside_text_bold"><strong>
										<a href="<?php echo $host_url;?>/opt/search.php">Search</a></strong></div>
									<div class="inside_text_bold"><strong>
										<a href="<?php echo $host_url;?>/themes/">Themes</a></strong></div>
									<div class="inside_text_bold"><strong>
										<a href="<?php echo $host_url;?>/opt/userstats.php?func=allusers">View All Users</a></strong></div>
									<div class="inside_text_bold"><strong>
										<a class="links" href="http://forum.techidiots.net/forum/viewforum.php?f=47">Help / Support</a></strong></div>
									<div class="inside_text_bold"><strong>
										<a href="<?php echo $host_url;?>/ver.php">WiFiDB Version</a></strong></div>
									<br>
									<div class="inside_dark_header">[Mysticache]</div>
									<div class="inside_text_bold"><a class="links" href="<?php if($root != ''){echo $hosturl.$root;}?>/caches.php">View shared Caches</a></div>
									<?php
									if($login_check)
									{
									?>
									<div class="inside_text_bold"><a class="links" href="<?php if($root != ''){echo $hosturl.$root;}?>/cp/?func=boeyes&boeye_func=list_all&sort=id&ord=ASC&from=0&to=100">List All My Caches</a></div>
									<?php
									}
									
									?>
								</td>
								<td class="cell_side_right">&nbsp;</td>
							</tr>
							<tr>
								<td class="cell_bot_left">&nbsp;</td>
								<td class="cell_bot_mid">&nbsp;</td>
								<td class="cell_bot_right">&nbsp;</td>
							</tr>
						</table>
					</td>
					<td style="height: 114px" valign="top" class="center">
						<table style="width: 100%" cellpadding="0" cellspacing="0">
							<tr>
								<td style="width: 10px; height: 20px" class="cell_top_left">
									<img alt="" src="<?php echo $host_url;?>/themes/vistumbler/img/1x1_transparent.gif" width="10" height="1" />
								</td>
								<?php
								if($login_check)
								{
									$user_logins_table = $GLOBALS['user_logins_table'];
									list($cookie_pass_seed, $username) = explode(':', $_COOKIE['WiFiDB_login_yes']);
								#	echo $username."<BR>";
									$sql0 = "SELECT * FROM `$db`.`$user_logins_table` WHERE `username` = '$username' LIMIT 1";
								#	echo $sql0;
									$result = mysql_query($sql0, $conn);
									$newArray = mysql_fetch_array($result);
									$last_login = $newArray['last_login'];
									
									
			#						echo $priv."<BR>";
									?>
									<td class="cell_top_mid" style="height: 20px" align="left">Welcome, <a class="links" href="<?php echo $hosturl.$root; ?>/cp/"><?php echo $username;?></a><font size="1"> (Last Logon: <?php echo $last_login;?>)</font></td>
									<td class="cell_top_mid" style="height: 20px" align="right"><a class="links" href="<?php echo $hosturl.$root; ?>/login.php?func=logout_proc">Logout</a></td>
									<?php
								}else
								{
									$filtered = filter_var($_SERVER['QUERY_STRING'],FILTER_SANITIZE_ENCODED);
									$SELF = $_SERVER['PHP_SELF'];
									if($SELF == '/wifidb/login.php')
									{
										$SELF = "/$root/";
										$filtered = '';
									}
									if($filtered != '')
									{$SELF = $SELF.'?'.$filtered;}
									?>
									<td class="cell_top_mid" style="height: 20px" align="left"></td>
									<td class="cell_top_mid" style="height: 20px" align="right"><a class="links" href="<?php echo $hosturl.$root; ?>/login.php">Login</a></td>
									<?php
								}
								?>
								<td style="width: 10px" class="cell_top_right">
									<img alt="" src="<?php echo $host_url;?>/themes/vistumbler/img/1x1_transparent.gif" width="10" height="1" />
								</td>
							</tr>
							<tr>
								<td class="cell_side_left">&nbsp;</td>
								<td class="cell_color_centered" align="center" colspan="2">
								<div align="center">
		<?php
	}
}


#========================================================================================================================#
#											Footer (writes the footer for all pages)									 #
#========================================================================================================================#

function footer($filename = '')
{
	?>
							</div>
							<br>
							</td>
							<td class="cell_side_right">&nbsp;</td>
						</tr>
						<tr>
							<td class="cell_bot_left">&nbsp;</td>
							<td class="cell_bot_mid" colspan="2">&nbsp;</td>
							<td class="cell_bot_right">&nbsp;</td>
						</tr>
					</table>
				<div class="inside_text_center" align=center><strong>
				Random Intervals Wireless DataBase<?php echo $GLOBALS['ver']['wifidb'].'<br />'; ?></strong></div>
				<br />
				<?php
				echo $GLOBALS['tracker'];
				echo $GLOBALS['ads']; 
				?>
				</td>
			</tr>
		</table>
	</body>
	</html>
	<?php
}
?>