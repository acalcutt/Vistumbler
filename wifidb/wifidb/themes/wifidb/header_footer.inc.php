<?php
#========================================================================================================================#
#											Header (writes the Headers for all pages)									 #
#========================================================================================================================#

function pageheader($title, $output="detailed", $install=0)
{
	global $login_check, $install;
	include_once($GLOBALS['half_path'].'/lib/database.inc.php');
	include_once($GLOBALS['half_path'].'/lib/config.inc.php');
	$head		= 	$GLOBALS['header'];
	$half_path	=	$GLOBALS['half_path'];
	if($output == "detailed")
	{
		if(!$install)
		{
			include_once($GLOBALS['half_path'].'/lib/security.inc.php');
			$sec = new security();
			$login_check = $sec->login_check();
			if(is_array($login_check) or $login_check == "No Cookie"){$login_check = 0;}
			check_install_folder();
		}else
		{
			$login_check = 0;
		}
		echo '<html><head><title>Wireless DataBase '.$GLOBALS["ver"]["wifidb"].' --> '.$title.'</title>'.$head.'</head>';
		# START YOUR HTML EDITS HERE #
		?>
		
		<link rel="stylesheet" href="<?php echo $GLOBALS['UPATH'];?>/themes/wifidb/styles.css">
		<body>
		<div align="center">
		<table width="100%" border="0" cellspacing="5" cellpadding="2">
			<tr style="background-color: #315573;">
				<td colspan="2">
					<table>
					<tr>
							<td style="width: 215px">
								<a href="<?php echo $GLOBALS['UPATH'];?>"><img border="0" src="<?php echo $GLOBALS['UPATH']; ?>/img/logo.png"></a>
							</td>
							<td width="100%" align="center">
								<b>
								<font style="size: 5;font-family: Arial;color: #FFFFFF;">
								Wireless DataBase<?php echo $GLOBALS['ver']['wifidb'].'<br /><br />'; ?>
								</font>
									<?php breadcrumb($_SERVER["REQUEST_URI"]); ?>
								</b>
							</td>
						</tr>
					</table>
				</td>
			</tr>
			<tr>
				<td style="background-color: #304D80;width: 15%;vertical-align: top;">
				<img alt="" src="/wifidb/themes/wifidb/img/1x1_transparent.gif" width="185" height="1" /><br>
				<span class="content_head"><strong><em>[WiFIDB]</em></strong></span><br>
				<a class="links" href="<?php echo $GLOBALS['UPATH'];?>">Main Page</a><br>
				<a class="links" href="<?php echo $GLOBALS['UPATH'];?>/all.php?sort=SSID&ord=ASC&from=0&to=100">View All APs</a><br>
				<a class="links" href="<?php echo $GLOBALS['UPATH'];?>/import/">Import</a><br>
				<a class="links" href="<?php echo $GLOBALS['UPATH'];?>/opt/scheduling.php">Files Waiting for Import</a><br>
				<a class="links" href="<?php echo $GLOBALS['UPATH'];?>/opt/scheduling.php?func=done">Files Already Imported</a><br>
				<a class="links" href="<?php echo $GLOBALS['UPATH'];?>/opt/scheduling.php?func=daemon_kml">Daemon Generated KML</a><br>
				<a class="links" href="<?php echo $GLOBALS['UPATH'];?>/console/">Daemon Console</a><br>
				<a class="links" href="<?php echo $GLOBALS['UPATH'];?>/opt/export.php?func=index">Export</a><br>
				<a class="links" href="<?php echo $GLOBALS['UPATH'];?>/opt/search.php">Search</a><br>
				<a class="links" href="<?php echo $GLOBALS['UPATH'];?>/themes/">Themes</a><br>
				<a class="links" href="<?php echo $GLOBALS['UPATH'];?>/opt/userstats.php?func=allusers">View All Users</a><br>
				<a class="links" href="http://forum.techidiots.net/forum/viewforum.php?f=47">Help / Support</a><br>
				<a class="links" href="<?php echo $GLOBALS['UPATH'];?>/ver.php">WiFiDB Versions</a><br>
				<br>
				<span class="content_head"><strong><em>[Mysticache]</em></strong></span><br>
				<a class="links" href="<?php echo $GLOBALS['UPATH'];?>/caches.php">View shared Caches</a><br>
				<!---- User Mysicache Link ---->
				<?php my_caches("wifidb") ?>
				<!----------------------------->
			</td>
			<td style="background-color: #A9C6FA;width: 80%;vertical-align: top;" align="center">
			<table width="100%">
				<tr>
					<!-------- WiFiDB Login Bar ------>
					<?php login_bar("wifidb"); ?>
					<!-------------------------------->
				</tr>
			</table>
			<p align="center">
			<br>
		<?php
	}
}



#========================================================================================================================#
#									Footer (writes the footer for all pages)								#
#========================================================================================================================#

function footer($filename = '', $output = "detailed")
{
	$half_path	=	$GLOBALS['half_path'];
	include_once($half_path.'/lib/security.inc.php');
	include_once($half_path.'/lib/database.inc.php');
	include_once($half_path.'/lib/config.inc.php');
	$filename = str_replace($GLOBALS['half_path'], "", $filename);
	$root = $GLOBALS['root'];
	$tracker = $GLOBALS['tracker'];
	$ads = $GLOBALS['ads'];
	if($output == "detailed")
	{
		?>
		</p>
		<br>
		</td>
		</tr>
		<tr>
		<td bgcolor="#315573" height="23"></td>
		<td bgcolor="#315573" width="0" align="center">
		<h6><i><u><?php echo $filename;?></u></i> was last modified:  <?php echo date ("Y F d @ H:i:s", getlastmod());?></h6>
		<?php
#		echo $GLOBALS['privs'];
		if(@$GLOBALS['login_check'])
		{
			?>
			<font size="2"><b>
			<?php
			$privs = $GLOBALS['privs'];
			$priv_name = $GLOBALS['priv_name'];
			if($privs >= 1000)
			{
				?><a class="links" href="<?php echo $GLOBALS['UPATH'];?>/cp/?func=admin_cp">Admin Control Panel</a>  |-|  <?php
			}
			if($privs >= 10)
			{
				?><a class="links" href="<?php echo $GLOBALS['UPATH'];?>/cp/?func=mod_cp">Moderator Control Panel</a>  |-|  <?php
			}
			if($privs >= 1)
			{
				?><a class="links" href="<?php echo $GLOBALS['UPATH'];?>/cp/">User Control Panel</a><?php
			}
			?>
			</b></font>
			<?php
		}
		?>
		</td>
		</tr>
		<tr>
		<td></td>
		<!--  ADS AND TRACKER" -->
		<td align="center">
		<?php
		echo $tracker;
		echo $ads;
		?>
		</td>
		<!-- END ADS AND TRACKER" -->
		</tr>
		</table>
		</body>
		</html>
		<?php
	}
}

?>