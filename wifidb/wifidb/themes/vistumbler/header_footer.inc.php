<?php
#========================================================================================================================#
#											Header (writes the Headers for all pages)									 #
#========================================================================================================================#

function pageheader($title, $output="detailed", $install=0)
{
	global $login_check;
	include_once($GLOBALS['half_path'].'/lib/database.inc.php');
	include_once($GLOBALS['half_path'].'/lib/config.inc.php');
	$head		= 	$GLOBALS['header'];
	$half_path	=	$GLOBALS['half_path'];
	if(!$install)
	{
		include_once($GLOBALS['half_path'].'/lib/security.inc.php');
		$sec = new security();
		$login_check = $sec->login_check();
		if(is_array($login_check) or $login_check == "No Cookie"){$login_check = 0;}
	}else{$login_check = 0;}
	if($output == "detailed")
	{
		check_install_folder();
		echo '<html><head><title>Wireless DataBase '.$GLOBALS["ver"]["wifidb"].' --> '.$title.'</title>'.$head.'</head>';
		# START YOUR HTML EDITS HERE #
		?>
		
		<link rel="stylesheet" href="<?php echo $GLOBALS['UPATH']; ?>/themes/vistumbler/styles.css">
			<body style="background-color: #145285">
			<table style="width: 100%; " class="no_border" align="center">
				<tr>
					<td>
						<table>
							<tr>
								<td style="width: 228px">
								<a href="http://www.randomintervals.com">
								<img alt="Random Intervals Logo" src="<?php echo $GLOBALS['UPATH'];?>/themes/vistumbler/img/logo.png" class="no_border" /></a></td>
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
									<img alt="" src="<?php echo $GLOBALS['UPATH']; ?>/themes/vistumbler/img/1x1_transparent.gif" width="10" height="1" />
								</td>
								<td class="cell_top_mid" style="height: 20px">
									<img alt="" src="<?php echo $GLOBALS['UPATH']; ?>/themes/vistumbler/img/1x1_transparent.gif" width="185" height="1" />
								</td>
								<td style="width: 10px" class="cell_top_right">
									<img alt="" src="<?php echo $GLOBALS['UPATH']; ?>/themes/vistumbler/img/1x1_transparent.gif" width="10" height="1" />
								</td>
							</tr>
							<tr>
								<td class="cell_side_left">&nbsp;</td>
								<td class="cell_color">
									<div class="inside_dark_header">WiFiDB Links</div>
									<div class="inside_text_bold"><strong>
										<a href="<?php echo $GLOBALS['UPATH'];?>/">Main Page</a></strong></div>
									<div class="inside_text_bold"><strong>
										<a href="<?php echo $GLOBALS['UPATH'];?>/all.php?sort=SSID&ord=ASC&from=0&to=100">View All APs</a></strong></div>
									<div class="inside_text_bold"><strong>
										<a href="<?php echo $GLOBALS['UPATH'];?>/import/">Import</a></strong></div>
									<div class="inside_text_bold"><strong>
										<a href="<?php echo $GLOBALS['UPATH'];?>/opt/scheduling.php">Files Waiting for Import</a></strong></div>
									<div class="inside_text_bold"><strong>
										<a href="<?php echo $GLOBALS['UPATH'];?>/opt/scheduling.php?func=done">Files Already Imported</a></strong></div>
									<div class="inside_text_bold"><strong>
										<a href="<?php echo $GLOBALS['UPATH'];?>/opt/scheduling.php?func=daemon_kml">Daemon Generated kml</a></strong></div>
									<div class="inside_text_bold"><strong>
										<a href="<?php echo $GLOBALS['UPATH'];?>/console/">Daemon Console</a></strong></div>
									<div class="inside_text_bold"><strong>
										<a href="<?php echo $GLOBALS['UPATH'];?>/opt/export.php?func=index">Export</a></strong></div>
									<div class="inside_text_bold"><strong>
										<a href="<?php echo $GLOBALS['UPATH'];?>/opt/search.php">Search</a></strong></div>
									<div class="inside_text_bold"><strong>
										<a href="<?php echo $GLOBALS['UPATH'];?>/themes/">Themes</a></strong></div>
									<div class="inside_text_bold"><strong>
										<a href="<?php echo $GLOBALS['UPATH'];?>/opt/userstats.php?func=allusers">View All Users</a></strong></div>
									<div class="inside_text_bold"><strong>
										<a class="links" href="http://forum.techidiots.net/forum/viewforum.php?f=47">Help / Support</a></strong></div>
									<div class="inside_text_bold"><strong>
										<a href="<?php echo $GLOBALS['UPATH'];?>/ver.php">WiFiDB Version</a></strong></div>
									<br>
									<div class="inside_dark_header">[Mysticache]</div>
									<div class="inside_text_bold"><a class="links" href="<?php echo $GLOBALS['UPATH'];?>/caches.php">View shared Caches</a></div>
									
									<!---- User Mysicache Link ---->
									<?php my_caches("vistumbler") ?>
									<!----------------------------->
								
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
									<img alt="" src="<?php echo $GLOBALS['UPATH'];?>/themes/vistumbler/img/1x1_transparent.gif" width="10" height="1" />
								</td>
								
								<!-------- WiFiDB Login Bar ------>
								<?php login_bar("vistumbler"); ?>
								<!-------------------------------->
								
								<td style="width: 10px" class="cell_top_right">
									<img alt="" src="<?php echo $GLOBALS['UPATH'];?>/themes/vistumbler/img/1x1_transparent.gif" width="10" height="1" />
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