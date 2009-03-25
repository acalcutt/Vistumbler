<?php
include('../../lib/database.inc.php');
echo '<title>Wireless DataBase *Alpha*'.$ver["wifidb"].' --> Upgrade Page</title>';
?>
<link rel="stylesheet" href="../../css/site4.0.css">
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

<form action="patch.php" method="post" enctype="multipart/form-data">
  <h2>WiFiDB Settings for Upgrade</h2>
  <h4>Please Read <a class="links" target="_blank" href="notes.html">these notes</a> before Upgrading/fixing the Wireless Database</h4>
<?php
$gd = gd_info(); 
if(is_null($gd["GD Version"]))
{
	echo "<h4><font color=#ff0000>You Do Not Have GD or GD2 installed, please install this or you will not beable to use the graphing feature!</font></h4>";
}
else
{ 
	echo "<h4><font color=#00ff00>GD Version: ".$gd['GD Version'].", is installed</font></h4>";
}
?>
<table border="0" cellspacing="0" cellpadding="3">
  <tr>
    <td width="100%">1>  SQL Root User To Make the changes)</td><td>........................................</td>
    <td><input name="root_sql_user"></td></tr>
  <tr>
    <td>2>  SQL Root user Password</td><td>........................................</td>
    <td><input TYPE=PASSWORD name="root_sql_pwd"></td></tr>
  <tr>
  <tr>
    <td width="100%">1>  WiFiDB User (To verify that you have access)</td><td>........................................</td>
    <td><input name="wdb_sql_user"></td></tr>
  <tr>
    <td>2>  WiFiDB user Password</td><td>........................................</td>
    <td><input TYPE=PASSWORD name="wdb_sql_pwd"></td></tr>
  <tr>
    <td>3>  Would you like to replace erroneous data with valid blank data?<h5>(eg. N 0.00000 | E 0.00000 | 1-1-1971 | 00:00:00)<h5></td><td>........................................</td>
    <td><INPUT TYPE=CHECKBOX NAME="replace"></td></tr>
  <tr>
    <td>4>  Would you like to delete Access points altogether if they don’t have any 'valid' GPS points?</td><td>........................................</td>
    <td><INPUT TYPE=CHECKBOX NAME="deleteap"></td>
</TR><TR></TR><TD></TD><TD></TD><TR><TD></TD><TD></TD><TD>
<INPUT TYPE=SUBMIT NAME="submit" VALUE="Submit" STYLE="width: 0.71in; height: 0.36in">
</TD>
</TR>
</TABLE>
</form>
</p>

<?php

$filename = $_SERVER['SCRIPT_FILENAME'];
footer($filename);
?>