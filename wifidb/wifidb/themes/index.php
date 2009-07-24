<?php
include('../lib/config.inc.php');
global $theme;

$func = '';
$theme_post = '';

if( !isset($_GET['func']) ) { $_GET['func'] = ""; }
$func = strip_tags(addslashes($_GET['func']));

if($func == 'change')
{
	if( !isset($_POST['theme']) ) { $_POST['theme'] = ""; }
	$theme_post = strip_tags(addslashes($_POST['theme']));
	$sql = "UPDATE `$db`.`$settings_tb` SET `size` = '$theme_post' WHERE `table` = 'theme'";
	$result = mysql_query($sql, $conn);
	if(!$result)
	{
		echo "Could not update the field with the new theme value.";
	}else
	{
	}
	setcookie( 'wifidb_theme' , $theme_post , (time()+(86400 * 7)), "/".$root."/" ); // 86400 = 1 day
	header('Location: index.php?token='.$_SESSION['token']);
}
$theme = ($_COOKIE['wifidb_theme']!='' ? $_COOKIE['wifidb_theme'] : $default_theme);
#echo $theme."1<BR>";
include('../lib/database.inc.php');

pageheader("Themes Switchboard");
?>
<h2>Themes Switchboard</h2>
<table align="center"><tr style="style4"><th colspan="2">Choose a Theme</th></tr>
<form action="index.php?func=change&token=<?php echo $_SESSION['token'];?>" method="post" enctype="multipart/form-data">
<tr><td>
<input type="hidden" name="token" value="<?php echo $token; ?>" />
<SELECT NAME="theme">
<?php

$dh = opendir(".") or die("couldn't open directory");
while (($file = readdir($dh)) == true)
{
	if (!is_file($textdir."/".$file)) 
	{
		if($file == '.'){continue;}
		if($file == '..'){continue;}
		if($file == '.svn'){continue;}
		if($file == 'index.php'){continue;}
		if($file == 'theme.txt'){continue;}
		echo $file." ".$theme;
		?>
		<OPTION <?php if($GLOBALS['theme'] == $file){echo "SELECTED";}?> VALUE="<?php echo $file;?>"><?php	echo $file."</OPTION><BR>";
		
	}
}
?>
</select>
<INPUT TYPE=SUBMIT NAME="submit" VALUE="Submit">
</form>

</td></tr></table>
<?php
$filename = $_SERVER['SCRIPT_FILENAME'];
footer($filename);
?>