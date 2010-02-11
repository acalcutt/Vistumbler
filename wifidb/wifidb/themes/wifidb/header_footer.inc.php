<?php
#========================================================================================================================#
#											Header (writes the Headers for all pages)									 #
#========================================================================================================================#

function pageheader($title, $output="detailed")
{
	global $login_check;
	
	$root		= 	$GLOBALS['root'];
	$hosturl	= 	$GLOBALS['hosturl'];
	$conn		=	$GLOBALS['conn'];
	$db			=	$GLOBALS['db'];
	$head		= 	$GLOBALS['header'];
	$half_path	=	$GLOBALS['half_path'];
	include_once($half_path.'/lib/database.inc.php');
	include_once($half_path.'/lib/security.inc.php');
	include_once($half_path.'/lib/config.inc.php');

	$token = session_starter();
	
	$sec = new security();
		
	$login_check = $sec->login_check();
	if(is_array($login_check) or $login_check == "No Cookie"){$login_check = 0;}
	
	if($output == "detailed")
	{
		check_install_folder();
		# START YOUR HTML EDITS HERE #
		?>
		<html><head><title>Wireless DataBase <?php echo $GLOBALS['ver']['wifidb'];?> --> <?php echo $title;?></title><?php echo $head; ?></head>
		<link rel="stylesheet" href="<?php if($root != ''){echo $hosturl.$root;}?>/themes/wifidb/styles.css">
		<body topmargin="10" leftmargin="0" rightmargin="0" bottommargin="10" marginwidth="10" marginheight="10">
		<div align="center">
		<table border="0" width="85%" cellspacing="5" cellpadding="2">
			<tr style="background-color: #315573;"><td colspan="2">
			<table width="100%">
				<tr>
					<td style="width: 215px">
						&nbsp;&nbsp;&nbsp;&nbsp;<a href="/<?php echo $root;?>/"><img border="0" src="/<?php echo $root; ?>/img/logo.png"></a>
					</td>
					<td>
						<p align="center"><b>
						<font style="size: 5;font-family: Arial;color: #FFFFFF;">
						Wireless DataBase<?php echo $GLOBALS['ver']['wifidb'].'<br /><br />'; ?>
						</font>
							<?php breadcrumb($_SERVER["REQUEST_URI"]); ?>
						</b></p>
					</td>
				</tr>
			</table>
			</td></tr>
			<tr>
				<td style="background-color: #304D80;width: 15%;vertical-align: top;">
				<img alt="" src="/wifidb/themes/wifidb/img/1x1_transparent.gif" width="185" height="1" /><br>
				<span class="content_head"><strong><em>[WiFIDB]</em></strong></span><br>
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
				<br>
				<span class="content_head"><strong><em>[Mysticache]</em></strong></span><br>
				<a class="links" href="<?php if($root != ''){echo $hosturl.$root;}?>/caches.php?token=<?php echo $token;?>">View shared Caches</a><br>
				<?php
				if($login_check)
				{
					?>
					<a class="links" href="<?php if($root != ''){echo $hosturl.$root;}?>/cp/?func=boeyes&boeye_func=list_all">List All My Caches</a>
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
						<td>Welcome, <a class="links" href="/<?php echo $root;?>/cp/"><?php echo $username;?></a><font size="1"> (Last Login: <?php echo $last_login;?>)</font></td>
						<td align="right"><a class="links" href="<?php echo $hosturl.$root; ?>/login.php?func=logout_proc">Logout</a></td>
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
						<td></td><td align="right"><a class="links" href="<?php echo $hosturl.$root; ?>/login.php?return=<?php echo $SELF; ?>">Login</a></td>
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
	include_once($half_path.'lib/security.inc.php');
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
				# $privs_a = $GLOBALS['privs_a'];
				list($privs, $priv_name) = security::check_privs(0);
			#	echo $privs;
				if($privs >= 1000)
				{
					?><a class="links" href="/<?php echo $root;?>/cp/?func=admin_cp"><font size="2"><b>Admin Control Panel</b></a></font><?php
				}
				if($privs >= 10)
				{
					?><font size="2">  |-|  <a class="links" href="/<?php echo $root;?>/cp/?func=mod_cp"><b>Moderator Control Panel</b></a></font><?php
				}
				if($privs >= 1)
				{
					?><font size="2">  |-|  <a class="links" href="/<?php echo $root;?>/cp/"><b>User Control Panel</b></font></a><?php
				}
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