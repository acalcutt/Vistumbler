<?php
include('../../lib/database.inc.php');
pageheader("Upgrade Page");
?>
</td>
	<td width="80%" bgcolor="#A9C6FA" valign="top" align="center">
		<p align="center">
<form action="patch.php" method="post" enctype="multipart/form-data">
  <h2>WiFiDB Settings for Upgrade</h2>
  <h3>Upgrade DB for 0.15 Build 7x to 0.16 Build 1</h3>
  <h4>Please Read <a target="_blank" href="../notes.html">these notes</a> before installing the Wireless Database</h4>
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
    <td width="100%">SQL root User (to update the wifidb user priv's)</td><td>........................................</td>
    <td><input name="root_sql_user"></td></tr>
  <tr>
    <td>SQL root user Password</td><td>........................................</td>
    <td><input TYPE=PASSWORD name="root_sql_pwd"></td></tr>
  <tr>
  <td>
    <p>MySQL Host (Default `localhost` )</td><td>........................................</td>
    <td><input name="sqlhost"></td></tr>
  <tr>
    <td>WiFiDB SQL Username</td><td>........................................</td>
    <td><input name="sqlu"></td></tr>
  <tr>
    <td>WiFiDB SQL Password</td><td>........................................</td>
    <td><input name="sqlp"></td></tr>
  <tr>
    <td>WiFi DB name (Default `wifi` )</td><td>........................................</td>
    <td><input name="wifi"></td></tr>
  <tr>
    <td>WiFi Storage DB name (Default `wifi_st` )</td><td>........................................</td>
    <td><input name="wifist"></td>
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