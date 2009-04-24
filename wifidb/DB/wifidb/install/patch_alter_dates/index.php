<?php
include('../../lib/database.inc.php');
pageheader("Patch (Alter Dates) Page");
?>
</td>
	<td width="80%" bgcolor="#A9C6FA" valign="top" align="center">
		<p align="center">
<form action="patch.php" method="post" enctype="multipart/form-data">
  <h2>WiFiDB Settings for Upgrade</h2>
  <h4>Please Read <a target="_blank" href="notes.html">these notes</a> before Upgrading/fixing the Wireless Database</h4>
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