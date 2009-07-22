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

	include('config.inc.php');
	echo '<title>Wireless DataBase *Alpha*'.$GLOBALS['ver']["wifidb"].' --> '.$title.'</title>';
	$sql = "SELECT `id` FROM `$db`.`files`";
	$result1 = mysql_query($sql, $conn);
	check_install_folder();	
	if(!$result1){echo "<font color=\"red\"><h2>You need to <a class=\"upgrade\" href=\"install/upgrade/\">upgrade</a> before you will be able to properly use WiFiDB Build 3.</h3></font>";}
	if($output == "detailed")
	{
		# START YOUR HTML EDITS HERE #
		?>
		<link rel="stylesheet" href="<?php if($root != ''){echo '/'.$root;}?>/css/site4.0.css">
		<body topmargin="10" leftmargin="0" rightmargin="0" bottommargin="10" marginwidth="10" marginheight="10">
		<div align="center">
		<table border="0" width="85%" cellspacing="5" cellpadding="2">
			<tr style="background-color: #315573;">
				<td colspan="2">
				<p align="center"><b>
				<font style="size: 5;font-family: Arial;color: #FFFFFF;">
				Wireless DataBase *Alpha* <?php echo $GLOBALS['ver']['wifidb'].'<br />'; ?>
				<font size="2">
					<?php breadcrumb($_SERVER["REQUEST_URI"]); ?>
				</font></font></b>
				</td>
			</tr>
			<tr>
				<td style="background-color: #304D80;width: 15%;vertical-align: top;">
				<p><a class="links" href="<?php if($root != ''){echo '/'.$root;}?>/?token=<?php echo $token;?>">Main Page</a></p>
				<p><a class="links" href="<?php if($root != ''){echo '/'.$root;}?>/all.php?sort=SSID&ord=ASC&from=0&to=100&token=<?php echo $token;?>">View All APs</a></p>
				<p><a class="links" href="<?php if($root != ''){echo '/'.$root;}?>/import/?token=<?php echo $token;?>">Import</a></p>
				<p><a class="links" href="<?php if($root != ''){echo '/'.$root;}?>/opt/scheduling.php?token=<?php echo $token;?>">Files Waiting for Import</a></p>
				<p><a class="links" href="<?php if($root != ''){echo '/'.$root;}?>/opt/export.php?func=index&token=<?php echo $token;?>">Export</a></p>
				<p><a class="links" href="<?php if($root != ''){echo '/'.$root;}?>/opt/search.php?token=<?php echo $token;?>">Search</a></p>
				<p><a class="links" href="<?php if($root != ''){echo '/'.$root;}?>/opt/userstats.php?func=allusers&token=<?php echo $token;?>">View All Users</a></p>
				<p><a class="links" href="<?php if($root != ''){echo '/'.$root;}?>/ver.php?token=<?php echo $token;?>">WiFiDB Version</a></p>
				<p><a class="links" href="<?php if($root != ''){echo '/'.$root;}?>/down.php?token=<?php echo $token;?>">Download WiFiDB</a></p>
			</td>
			
		<!-- KEEP BELOW HERE -->
			<td style="background-color: #A9C6FA;width: 80%;vertical-align: top;" align="center"><br>
		<?php
	}
}
?>