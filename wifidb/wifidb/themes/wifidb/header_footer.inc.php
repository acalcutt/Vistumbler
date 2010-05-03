<?php
#========================================================================================================================#
#											Header (writes the Headers for all pages)									 #
#========================================================================================================================#

function pageheader($title, $output="detailed")
{
	global $login_check,$host_url;
	
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
	
	$sec = new security();
		
	$login_check = $sec->login_check();
	if(is_array($login_check) or $login_check == "No Cookie"){$login_check = 0;}
	
	if($output == "detailed")
	{
		check_install_folder();
		# START YOUR HTML EDITS HERE #
		?>
		<html><head><title>Wireless DataBase <?php echo $GLOBALS['ver']['wifidb'];?> --> <?php echo $title;?></title><?php echo $head; ?></head>
		<link rel="stylesheet" href="<?php echo $host_url;?>/themes/wifidb/styles.css">
		<body>
		<div align="center">
		<table width="100%" border="0" cellspacing="5" cellpadding="2">
			<tr style="background-color: #315573;">
				<td colspan="2">
					<table>
					<tr>
							<td style="width: 215px">
								<a href="<?php echo $host_url;?>"><img border="0" src="<?php echo $host_url; ?>/img/logo.png"></a>
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
				<a class="links" href="<?php echo $host_url;?>">Main Page</a><br>
				<a class="links" href="<?php echo $host_url;?>/all.php?sort=SSID&ord=ASC&from=0&to=100">View All APs</a><br>
				<a class="links" href="<?php echo $host_url;?>/import/">Import</a><br>
				<a class="links" href="<?php echo $host_url;?>/opt/scheduling.php">Files Waiting for Import</a><br>
				<a class="links" href="<?php echo $host_url;?>/opt/scheduling.php?func=done">Files Already Imported</a><br>
				<a class="links" href="<?php echo $host_url;?>/opt/scheduling.php?func=daemon_kml">Daemon Generated KML</a><br>
				<a class="links" href="<?php echo $host_url;?>/console/">Daemon Console</a><br>
				<a class="links" href="<?php echo $host_url;?>/opt/export.php?func=index">Export</a><br>
				<a class="links" href="<?php echo $host_url;?>/opt/search.php">Search</a><br>
				<a class="links" href="<?php echo $host_url;?>/themes/">Themes</a><br>
				<a class="links" href="<?php echo $host_url;?>/opt/userstats.php?func=allusers">View All Users</a><br>
				<a class="links" href="http://forum.techidiots.net/forum/viewforum.php?f=47">Help / Support</a><br>
				<a class="links" href="<?php echo $host_url;?>/ver.php">WiFiDB Versions</a><br>
				<br>
				<span class="content_head"><strong><em>[Mysticache]</em></strong></span><br>
				<a class="links" href="<?php if($root != '' or $root != '/'){echo $hosturl.$root;}else{echo $hosturl;}?>/caches.php">View shared Caches</a><br>
				<?php
				if($login_check)
				{
					?>
					<a class="links" href="<?php if($root != '' or $root != '/'){echo $hosturl.$root;}else{echo $hosturl;}?>/cp/?func=boeyes&boeye_func=list_all&sort=id&ord=ASC&from=0&to=100">List All My Caches</a>
					<?php
				}
				?>
			</td>
			<td style="background-color: #A9C6FA;width: 80%;vertical-align: top;" align="center">
			<table width="100%">
				<tr>
					<?php
					if($login_check)
					{
						$user_logins_table = $GLOBALS['user_logins_table'];
						list($cookie_pass_seed, $username) = explode(':', $_COOKIE['WiFiDB_login_yes']);
						$sql0 = "SELECT * FROM `$db`.`$user_logins_table` WHERE `username` = '$username' LIMIT 1";
						$result = mysql_query($sql0, $conn);
						$newArray = mysql_fetch_array($result);
						$last_login = $newArray['last_login'];
						?>
						<td>Welcome, <a class="links" href="<?php echo $host_url;?>/cp/"><?php echo $username;?></a><font size="1"> (Last Login: <?php echo $last_login;?>)</font></td>
						<td align="right"><a class="links" href="<?php  echo $host_url; ?>/login.php?func=logout_proc">Logout</a></td>
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
						<td></td><td align="right"><a class="links" href="<?php  echo $host_url; ?>/login.php?return=<?php echo $SELF; ?>">Login</a></td>
						<?php
					}
					?>
				</tr>
			</table>
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
	$half_path	=	$GLOBALS['half_path'];
	include_once($half_path.'/lib/security.inc.php');
	include_once($half_path.'/lib/database.inc.php');
	include_once($half_path.'/lib/config.inc.php');

	$root = $GLOBALS['root'];
	$tracker = $GLOBALS['tracker'];
	$ads = $GLOBALS['ads'];
	$file_ex = explode("/", $filename);
	$count = count($file_ex);
	$filename_1 = $file_ex[($count)-1];
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
		<?php
		if (file_exists($filename_1)) 
		{
		?>
			<h6><i><u><?php echo $filename_1;?></u></i> was last modified:  <?php echo date ("Y F d @ H:i:s", getlastmod());?></h6>
			
			<?php
	#		echo $GLOBALS['privs'];
			if($GLOBALS['login_check'])
			{
				?>
				<font size="2"><b>
				<?php
				$privs = $GLOBALS['privs'];
				$priv_name = $GLOBALS['priv_name'];
				if($privs >= 1000)
				{
					?><a class="links" href="<?php echo $GLOBALS['host_url'];?>/cp/?func=admin_cp">Admin Control Panel</a>  |-|  <?php
				}
				if($privs >= 10)
				{
					?><a class="links" href="<?php echo $GLOBALS['host_url'];?>/cp/?func=mod_cp">Moderator Control Panel</a>  |-|  <?php
				}
				if($privs >= 1)
				{
					?><a class="links" href="<?php echo $GLOBALS['host_url'];?>/cp/">User Control Panel</a><?php
				}
				?>
				</b></font>
				<?php
			}
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