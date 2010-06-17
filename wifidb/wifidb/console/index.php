<?php
include('../lib/config.inc.php');
include('../lib/database.inc.php');
$func			= '';
if( !isset($_GET['func']) ) { $_GET['func'] = ""; }
$func = strip_tags(addslashes($_GET['func']));
if($GLOBALS['root'] != "" or $GLOBALS['root'] != "/"){$cookie_path = "/$root/console/";}else{$cookie_path = "/console/";}
switch($func)
{
	case 'refresh':
		if( (!isset($_POST['console_refresh'])) or $_POST['console_refresh']=='' ) { $_POST['console_refresh'] = "15"; }
		setcookie( 'console_refresh' , strip_tags(addslashes($_POST['console_refresh'])) , (time()+$timeout), $cookie_path ); // 86400 = 1 day
		header('Location: '.$GLOBALS["UPATH"].'/console/');
	break;
	
	case 'console_scroll':
		if( (!isset($_POST['console_scroll'])) or $_POST['console_scroll']=='' ) { $_POST['console_scroll'] = "1"; }
		setcookie( 'console_scroll' , strip_tags(addslashes($_POST['console_scroll'])) , (time()+$timeout), $cookie_path ); // 86400 = 1 day
		header('Location: '.$GLOBALS["UPATH"].'/console/');
	break;
		
	case 'console_last5':
		if( (!isset($_POST['console_last5'])) or $_POST['console_last5']=='' ) { $_POST['console_last5'] = "1"; }
		setcookie( 'console_last5' , strip_tags(addslashes($_POST['console_last5'])) , (time()+$timeout), $cookie_path ); // 86400 = 1 day
		header('Location: '.$GLOBALS["UPATH"].'/console/');
	break;
			
	case 'console_lines':
		if( (!isset($_POST['console_lines'])) or $_POST['console_lines']=='' ) { $_POST['console_lines'] = "1"; }
		setcookie( 'console_lines' , strip_tags(addslashes($_POST['console_lines'])) , (time()+$timeout), $cookie_path ); // 86400 = 1 day
		header('Location: '.$GLOBALS["UPATH"].'/console/');
	break;
}

$refresh = (@$_COOKIE['console_refresh']!='' ? @$_COOKIE['console_refresh'] : $GLOBALS['console_refresh']);
$scroll = (@$_COOKIE['console_scroll']!='' ? @$_COOKIE['console_scroll'] : $GLOBALS['console_scroll']);
$last5 = (@$_COOKIE['console_last5']!='' ? @$_COOKIE['console_last5'] : $GLOBALS['console_last5']);
$lines = (@$_COOKIE['console_lines']!='' ? @$_COOKIE['console_lines'] : $GLOBALS['console_lines']);
$theme = (@$_COOKIE['wifidb_theme']!='' ? @$_COOKIE['wifidb_theme'] : $GLOBALS['default_theme']);

if($refresh < 5 && !$last5)
{
	setcookie( 'console_refresh' , 5 , (time()+$timeout), $GLOBALS['UPATH']."/console/" );
	header('Location: '.$GLOBALS["UPATH"].'/console/');
}

pageheader("Daemon Console Viewer");
?>
<h2>WiFiDB Daemon Console Viewer</h2><br>
<table style="width: 100%">
	<tr>
		<td>
		<img src="<?php echo $GLOBALS['UPATH']; ?>/themes/<?php echo $theme; ?>/img/1x1_transparent.gif" width="1" height="480" />
		</td>
		<td>
			<iframe name="daemon_console" src="console.php" style="width: 100%; height: 373px">
				Your browser does not support inline frames or is currently configured not to display inline frames.
			</iframe>
			<br>
			<form action="?func=refresh" method="post" enctype="multipart/form-data">
				<SELECT NAME="console_refresh">
					<?php
					if($last5)
					{
					?>
					<OPTION <?php if($refresh == 1){ echo "selected ";}?> VALUE="1"> 1 Second
					<OPTION <?php if($refresh == 2){ echo "selected ";}?> VALUE="2"> 2 Seconds
					<?php
					}
					?>
					<OPTION <?php if($refresh == 5){ echo "selected ";}?> VALUE="5"> 5 Seconds
					<OPTION <?php if($refresh == 10){ echo "selected ";}?> VALUE="10"> 10 Seconds
					<OPTION <?php if($refresh == 15){ echo "selected ";}?> VALUE="15"> 15 Seconds
					<OPTION <?php if($refresh == 30){ echo "selected ";}?> VALUE="30"> 30 Seconds
					<OPTION <?php if($refresh == 60){ echo "selected ";}?> VALUE="60"> 60 Seconds
					<OPTION <?php if($refresh == 120){ echo "selected ";}?> VALUE="120"> 2 Minutes
					<OPTION <?php if($refresh == 240){ echo "selected ";}?> VALUE="240"> 4 Minutes
					<OPTION <?php if($refresh == 480){ echo "selected ";}?> VALUE="480"> 8 Minutes
					<OPTION <?php if($refresh == 960){ echo "selected ";}?> VALUE="960"> 16 Minutes
					<OPTION <?php if($refresh == 1920){ echo "selected ";}?> VALUE="1920"> 32 Minutes
					<OPTION <?php if($refresh == 3840){ echo "selected ";}?> VALUE="3840"> 64 Minutes
					<OPTION <?php if($refresh == 5760){ echo "selected ";}?> VALUE="5760"> 96 Minutes
					<OPTION <?php if($refresh == 7680){ echo "selected ";}?> VALUE="7680"> 128 Minutes
					<OPTION <?php if($refresh == 30720){ echo "selected ";}?> VALUE="30720"> 512 Minutes
				</SELECT>
				<INPUT TYPE=SUBMIT NAME="submit" VALUE="Submit">
			</form>
			<form action="?func=console_scroll" method="post" enctype="multipart/form-data">
				<input type="hidden" name="console_scroll" value="<?php if($scroll == 1){echo 0;}else{echo 1;} ?>" />
				Toggle Scroll to end: <INPUT TYPE=SUBMIT NAME="scroll_Submit" VALUE="<?php if($scroll == 1){echo 'On';}else{echo 'Off';}?>">
			</form>
			<form action="?func=console_last5" method="post" enctype="multipart/form-data">
				<input type="hidden" name="console_last5" value="<?php if($last5 == 1){echo 0;}else{echo 1;} ?>" />
				Toggle Daemon History: <INPUT TYPE=SUBMIT NAME="scroll_Submit" VALUE="<?php if($last5 == 0){echo 'On';}else{echo 'Off';}?>">
			</form>
			<?php
			if($last5 == 1)
			{
			?>
			<form action="?func=console_lines" method="post" enctype="multipart/form-data">
				Select Daemon History Size: <SELECT NAME="console_lines">
					<OPTION <?php if($lines == 2){ echo "selected ";}?> VALUE="2"> 2 lines
					<OPTION <?php if($lines == 5){ echo "selected ";}?> VALUE="5"> 5 lines
					<OPTION <?php if($lines == 10){ echo "selected ";}?> VALUE="10"> 10 lines
					<OPTION <?php if($lines == 15){ echo "selected ";}?> VALUE="15"> 15 lines
					<OPTION <?php if($lines == 20){ echo "selected ";}?> VALUE="20"> 20 lines
					<OPTION <?php if($lines == 60){ echo "selected ";}?> VALUE="60"> 60 lines
				</SELECT>
				<INPUT TYPE=SUBMIT NAME="lines_Submit" VALUE="Submit">
			</form>
			<?php
			}
			?>
		</td>
	</tr>
</table>
<?php
footer($_SERVER['SCRIPT_FILENAME']);
?>