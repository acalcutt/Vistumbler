<script type="text/javascript">
function endisable( ) {
document.forms['WiFiDB_patch'].elements['toolsdir'].disabled =! document.forms['WiFiDB_patch'].elements['daemon'].checked;
document.forms['WiFiDB_patch'].elements['httpduser'].disabled =! document.forms['WiFiDB_patch'].elements['daemon'].checked;
document.forms['WiFiDB_patch'].elements['httpdgrp'].disabled =! document.forms['WiFiDB_patch'].elements['daemon'].checked;
}
</script>

<?php
global $screen_output;
$screen_output = 'CLI';
include('../../lib/config.inc.php');
?>
<title>Wireless DataBase *Alpha* --> Upgrade Page</title>
<link rel="stylesheet" href="../../themes/wifidb/styles.css">
<body topmargin="10" leftmargin="0" marginwidth="10" marginheight="10" onload="document.forms['WiFiDB_patch'].elements['toolsdir'].disabled=true; document.forms['WiFiDB_patch'].elements['httpduser'].disabled=true; document.forms['WiFiDB_patch'].elements['httpdgrp'].disabled=true;">
<div align="center">
<table border="0" width="75%" cellspacing="10" cellpadding="2">
	<tr>
		<td bgcolor="#315573">
		<p align="center"><b><font size="5" face="Arial" color="#FFFFFF">
		Wireless DataBase Upgrade</font>
		<font color="#FFFFFF" size="2">
            <a class="links" href="/">[Root] </a>/ <a class="links" href="/wifidb/">[WifiDB] </a>/
		</font></b>
		</td>
	</tr>
</table>
</div>
<div align="center">
<table border="0" width="75%" cellspacing="10" cellpadding="2" height="90"><tr>
<td width="17%" bgcolor="#304D80" valign="top">
<!--LINKS-->
</td>

<td width="80%" bgcolor="#A9C6FA" valign="top" align="center">
<!--BODY-->

<form name="WiFiDB_patch" action="patch.php" method="post" enctype="multipart/form-data">
  <h2>WiFiDB Settings for Upgrade</h2>
  <h3>Upgrade DB for all 0.16 Builds <b>--></b> 0.20 Build 1</h3>
  <h4>Please Read <a class="links" target="_blank" href="notes.html">these notes</a> before installing the Wireless Database</h4>
<?php

if(@function_exists('gd_info'))
{$gd = @gd_info();	echo '<table><tr class="style4"><td><b><font color=#00ff00>GD Version: '.$gd['GD Version'].', is installed</font></b></td></tr></table>';}
else{ echo '<table><tr class="style4"><td><b><font color=#ff0000>You Do Not Have GD or GD2 installed, please install this or you will not beable to use the graphing feature!</font></b></td></tr></table>';}

if(@class_exists('ZipArchive'))
{echo '<table><tr class="style4"><td><b><font color=#00ff00>ZipArchive class is installed</font></b></td></tr></table>';}
else{ echo '<table><tr class="style4"><td><b><font color=#ff0000>You Do Not Have the ZipArchive class installed, please install this or you will not beable to use the Export Feature or the Daemon Generated KML.</font></b></td></tr></table>';}

if(class_exists('SQLiteDatabase'))
{echo '<table><tr class="style4"><td><b><font color=#00ff00>SQLiteDatabase class is installed</font></b></td></tr></table>';}
else{ echo '<table><tr class="style4"><td><b><font color=#ff0000>You Do Not Have the SQLiteDatabase class installed, please install this or you will not beable to import files from <a href="http://code.google.com/p/wardrive-android/" target="_blank">Wardrive for Android.</a></font></b></td></tr></table>';}

?>
<table border="1" cellspacing="0" cellpadding="3">
<tr><th colspan="2" class="style4">Basic WiFiDB Settings</th></tr>
  <tr>
    <td width="100%">SQL root User <font size="1">(to create the WiFiDB user and DB's)</font></td>
    <td><input name="root_sql_user"></td></tr>
  <tr>
    <td>SQL root user Password</td>
    <td><input TYPE=PASSWORD name="root_sql_pwd"></td></tr>
  <tr>
    <td>MySQL Host <font size="1">(Default `localhost` )</font></td>
    <td><input name="sqlhost" value="<?php echo @$GLOBALS['host']; ?>"></td></tr>
  <tr>
    <td>WiFiDB SQL Username</td>
    <td><input name="sqlu" value="<?php echo @$GLOBALS['db_user']; ?>"></td></tr>
  <tr>
    <td>WiFiDB SQL Password</td>
    <td><input type=password name="sqlp" value="<?php echo @$GLOBALS['db_pwd']; ?>"></td></tr>
  <tr>
    <td>Administrator User Password</td>
    <td><input type=password name="wdb_admn_pass"></td></tr>
  <tr>
    <td>Administrator User E-Mail</td>
    <td><input name="wdb_admn_emailadrs" value="<?php echo @$GLOBALS['admin_email']; ?>"></td></tr>
  <tr>
    <td>WiFiDB Email Updates </td>
    <td><input type="checkbox" name="wdb_email_updates"  <?php if(@$GLOBALS['wifidb_email_updates'] === 1){echo "checked";}?>></td></tr>
  <tr>
    <td>WiFiDB Email User Validation </td>
    <td><input type="checkbox" name="email_validation" <?php if(@$GLOBALS['email_validation'] === 1){echo "checked";}?>></td></tr>
  <tr>
    <td>Updates Sending Address</font></td>
    <td><input name="wdb_from_emailadrs" value="<?php echo @$GLOBALS['wifidb_from']; ?>"></td></tr>
  <tr>
    <td>Sending Password</font></td>
    <td><input name="wdb_from_pass" type=PASSWORD value="<?php echo @$GLOBALS['wifidb_from_pass']; ?>"></td></tr>
  <tr>
    <td>SMTP Server</font></td>
    <td><input name="wdb_smtp" value="<?php echo @$GLOBALS['wifidb_smtp']; ?>"></td></tr>
  <tr>
   <td>WiFi DB name <font size="1">(Default `wifi` )</font></td>
    <td><input name="wifi" value="<?php echo @$GLOBALS['db']; ?>"></td></tr>
  <tr>
    <td>WiFi Storage DB name <font size="1">(Default `wifi_st` )</font></td>
    <td><input name="wifist" value="<?php echo @$GLOBALS['db_st']; ?>"></td>
</TR>
  <tr>
    <td>Default Theme</td>
    <td>
		<select name="theme">
		<OPTION selected VALUE=""> Select a Theme.
		<?php
		$themes = "../../themes";
		$dh = opendir($themes) or die("couldn't open directory");
		while (!(($file = readdir($dh)) == false))
		{
			if ((is_dir($themes."/".$file))) 
			{
				$checked = '';
				if($file=="."){continue;}
				if($file==".."){continue;}
				if($file==".svn"){continue;}
				if($file === $GLOBALS['default_theme']){$checked = 'selected';}
				echo '<OPTION VALUE="'.$file.'"> '.$file;
			}
		}
		?>
		</select>
	</td>
</TR>
<tr><th colspan="2" class="style4">WiFiDB Daemon Settings</th></tr>
  <tr>
    <td>Use Daemon?</td>
    <td><input type="checkbox" name="daemon" <?php if($GLOBALS['daemon'] === 1){echo "checked";} ?> onchange="endisable()"></td>
</TR>
  <tr>
    <td>Tools Directory (if you are using the daemon)</td>
    <td><input <?php if($GLOBALS['daemon'] === 1){echo 'value="'.$GLOBALS['wifidb_tools'].'"';} ?> name="toolsdir"></td>
</TR>
</TR>
  <tr>
    <td>HTTPd User</td>
    <td><input <?php if($GLOBALS['daemon'] === 1){echo 'value="'.$GLOBALS['WiFiDB_LNZ_User'].'"';} ?> name="httpduser"></td>
</TR>
</TR>
  <tr>
    <td>HTTPd Group</td>
    <td><input <?php if($GLOBALS['daemon'] === 1){echo 'value="'.$GLOBALS['apache_grp'].'"';} ?> name="httpdgrp"></td>
</TR>
<TR>
<TD></TD>
<TD>
<INPUT TYPE=SUBMIT NAME="submit" VALUE="Submit" STYLE="width: 0.71in; height: 0.36in">
</TD>
</TR>
</TABLE>
</form>
</p>

<?php
$filename = $_SERVER['SCRIPT_FILENAME'];
$file_ex = explode("/", $filename);
$count = count($file_ex);
$file = $file_ex[($count)-1];
?>
</p>
</td>
</tr>
<tr>
<td bgcolor="#315573" height="23"><a href="../../img/moon.png"><img border="0" src="../../img/moon_tn.png"></a></td>
<td bgcolor="#315573" width="0" align="center">
<?php
if (file_exists($filename))
{
	?>
	<h6><i><u><?php echo $file;?></u></i> was last modified:  <?php echo date ("Y F d @ H:i:s", filemtime($filename));?></h6>
	<?php
}
?>
</td>
</tr>
</table>
</body>
</html>