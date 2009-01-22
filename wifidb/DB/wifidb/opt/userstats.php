<?php
include('../lib/config.inc.php');
include('../lib/database.inc.php');
echo '<title>Wireless DataBase *Alpha*'.$ver["wifidb"].' --> User Info Page</title>';
?>
<link rel="stylesheet" href="css/site4.0.css">
<body topmargin="10" leftmargin="0" rightmargin="0" bottommargin="10" marginwidth="10" marginheight="10">
<div align="center">
<table border="0" width="75%" cellspacing="10" cellpadding="2">
	<tr>
		<td bgcolor="#315573">
		<p align="center"><b><font size="5" face="Arial" color="#FFFFFF">
		Wireless DataBase *Alpha* <?php echo $ver["wifidb"]; ?></font>
		<font color="#FFFFFF" size="2">
            <a class="links" href="/">[Root] </a>/ <a class="links" href="/wifidb/">[WifiDB] </a>/
		</font></b>
		</td>
	</tr>
</table>
</div>
<div align="center">
<table border="0" width="75%" cellspacing="10" cellpadding="2" height="90">
	<tr>
<td width="17%" bgcolor="#304D80" valign="top">
<?php
mysql_select_db($db,$conn);
$sqls = "SELECT * FROM links ORDER BY ID ASC";
$result = mysql_query($sqls, $conn) or die(mysql_error());
while ($newArray = mysql_fetch_array($result))
{
	$testField = $newArray['links'];
    echo "<p>$testField</p>";
}
?>
</td>
		<td width="80%" bgcolor="#A9C6FA" valign="top" align="center">
			<p align="center">
<?php
$func=$_GET['func'];
if($func==="user")
{
	$user=$_GET['user'];
	echo '<h3>View All Users <a class="links" href="userstats.php?func=usersall">Here</a></h3>';
	echo '<h3>View all Access Points for user: <a class="links" href="../opt/userstats.php?func=allap&user='.$user.'">'.$user.'</a>';
	database::userstats($user);
}elseif($func==="userap")
{
	echo '<h3>View All Users <a class="links" href="userstats.php?func=usersall">Here</a></h3>';
	$row=$_GET['row'];
	database::usersap($row);
}elseif($func==="expkml")
{
	echo '<h3>View All Users <a class="links" href="userstats.php?func=usersall">Here</a></h3>';
	$row = $_GET['row'];
	database::exp_kml_user($row);
}elseif($func==="usersall")
{
	database::allusers();
}elseif($func==="allap")
{
	$user = $_GET['user'];
	database::all_usersap($user);
}else
{
	echo "<h1>Hey you can do that!, Go back and do it right</h1>";
}


$filename = $_SERVER['SCRIPT_FILENAME'];
$file_ex = explode("/", $filename);
$count = count($file_ex);
$file = $file_ex[($count)-1];
if (file_exists($filename)) {
    echo "<h6><i><u>$file</u></i> was last modified: " . date ("F d Y H:i:s.", filemtime($filename)) . "</h6>";
}
?>
</p>
</td>
</tr>
<tr>
<td bgcolor="#315573" height="23"><a href="/pictures/moon.png"><img border="0" src="/pictures/moon_tn.PNG"></a></td>
<td bgcolor="#315573" width="0">
</td>
</tr>
</table>