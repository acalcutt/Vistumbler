<?php
include('lib/database.inc.php');
echo '<title>Wireless DataBase *Alpha*'.$ver["wifidb"].' --> Upgrade Page</title>';
?>
<link rel="stylesheet" href="../css/site4.0.css">
<body topmargin="10" leftmargin="0" rightmargin="0" bottommargin="10" marginwidth="10" marginheight="10">
<div align="center">
<table border="0" width="75%" cellspacing="10" cellpadding="2">
	<tr>
		<td bgcolor="#315573">
		<p align="center"><b><font size="5" face="Arial" color="#FFFFFF">
		<?php echo 'Wireless DataBase *Alpha* '.$ver["wifidb"].'</font>';?>
		<font color="#FFFFFF" size="2">
            <a class="links" href="/">[Root] </a>/ <a class="links" href="/wifidb/">[WifiDB] </a>/
		</font></b>
		</p>
		</td>
	</tr>
</table>
</div>
<div align="center">
<table border="0" width="75%" cellspacing="10" cellpadding="2" height="90">
	<tr>
<td width="17%" bgcolor="#304D80" valign="top">
<?php
echo '<h3>If you have GPS points that are blank, go <a class="links" href="patch_blank_gps">here</a><h3>';
echo '<h3>If your GPS dates are in the format [MM-DD-YYYY], Alter them to [YYYY-MM-DD] <a class="links" href="patch_alter_date">here</a>';

$filename = $_SERVER['SCRIPT_FILENAME'];
footer($filename);
?>