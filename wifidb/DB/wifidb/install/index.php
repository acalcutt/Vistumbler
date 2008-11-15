<title>Welcome to the Random Intervals Wireless DB --> Import Page</title>
<link rel="stylesheet" href="../css/site4.0.css">
<body topmargin="10" leftmargin="0" rightmargin="0" bottommargin="10" marginwidth="10" marginheight="10">
<div align="center">
<table border="0" width="75%" cellspacing="10" cellpadding="2">
	<tr>
		<td bgcolor="#315573">
		<p align="center"><b><font size="5" face="Arial" color="#FFFFFF">
		Randomintervals.com Wireless DataBase *Alpha* </font>
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


<form action="" method="post" enctype="multipart/form-data">
  <h2>WiFiDB Settings for Install</h2>
  <h4>Please Read <a target="_blank" href="notes.html">these notes</a> before installing the Wireless Database</h4>
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
    <td width="100%">SQL root User (to create the WiFiDB user and DB's)</td><td>........................................</td>
    <td><input name="root_sql_user"></td></tr>
  <tr>
    <td>SQL root user Password</td><td>........................................</td>
    <td><input name="root_sql_pwd"></td></tr>
  <tr> 
  <tr>
    <td width="100%">WiFiDB Root (Default `wifidb` )</td><td>........................................</td>
    <td><input name="root"></td></tr>
  <tr>
    <td>Host URL</td><td>........................................</td>
    <td><input name="hosturl"></td></tr>
  <tr>
    <td>
      <p>MySQL Host (Default `localhost` )</td><td>........................................</td>
    <td><input name="sqlhost"></td></tr>
  <tr>
    <td>MySQL Username</td><td>........................................</td>
    <td><input name="sqlu"></td></tr>
  <tr>
    <td>MySQL Password</td><td>........................................</td>
    <td><input name="sqlp"></td></tr>
  <tr>
    <td>WiFi DB name (Default `wifi` )</td><td>........................................</td>
    <td><input name="wifidb"></td></tr>
  <tr>
    <td>WiFi Storage DB name (Default `wifi_st` )</td><td>........................................</td>
    <td><input name="wifistdb"></td>
</TR><TR></TR><TD></TD><TD></TD><TR><TD></TD><TD></TD><TD>
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
if (file_exists($filename)) {
    echo "<h6><i><u>$file</u></i> was last modified: " . date ("F d Y H:i:s.", filemtime($filename)) . "</h6>";
}?>
</body>
</html>
</p>
</td>
</tr>
<tr>
<td bgcolor="#315573" height="23"><a href="/pictures/moon.png"><img border="0" src="/pictures/moon_tn.PNG"></a></td>
<td bgcolor="#315573" width="0">
</td>
</tr>
</table>
</div>
</html>