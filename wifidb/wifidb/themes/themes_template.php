<?php
include('../lib/config.inc.php');
$theme = (@$_COOKIE['wifidb_theme']!='' ? @$_COOKIE['wifidb_theme'] : $default_theme);
?>
<link rel="stylesheet" href="<?php if($root != ''){echo '/'.$root;}?>/<?php echo $theme_page;?>/styles.css">
<?php
if( !isset($_GET['theme']) ) { $_GET['theme'] = ""; }
$theme = strip_tags(addslashes($_GET['theme']));
$theme_tn = $theme."/thumbnail.PNG";
$theme_ss = $theme."/screenshot.PNG";
$theme_details = file($theme.'/details.txt');
$total = count($theme_details);
?><table align="center"><tr><th><?php echo $theme;?></th></tr>
<tr><td align="center"><form action="index.php?func=change&token=<?php echo $_SESSION['token'];?>" method="post" enctype="multipart/form-data">
<input type="hidden" name="theme" value="<?php echo $theme; ?>" />
<INPUT  type="submit" NAME="submit" VALUE="Select This Theme" onclick="this.form.submit(); this.disabled = 1;" >
<!--
 src="<?php #echo $theme_page;?>/img/submit.gif"
 -->

</form>
<a href="<?php echo $theme_ss;?>" target="_blank">
<img src="<?php echo $theme_tn;?>">
</a><br><br>
<tr><td><?php echo $theme_details[0];?></td></tr>
<tr><td><?php 
			$ws_exp = explode(":", $theme_details[1]);
			?><?php echo $ws_exp[0];?>: <a href="<?php echo $ws_exp[1];?>" target="_blank"><?php echo $ws_exp[1];?></a>
			</td></tr>
<tr><td><?php echo $theme_details[2];?></td></tr>
<tr><td><?php echo $theme_details[3];?></td></tr>
<tr><td><?php echo $theme_details[4];?></td></td></tr>
<tr><td>
<?php
echo wordwrap($theme_details[5], 64, "<br />\n");

?>
</td><tr></table>
</td></tr></table>