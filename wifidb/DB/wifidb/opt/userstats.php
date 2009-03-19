<?php
include('../lib/config.inc.php');
include('../lib/database.inc.php');
?>
<title>Wireless DataBase *Alpha*<?php echo $ver["wifidb"];?> --> Access Point Info Page</title>
<link rel="stylesheet" href="../css/site4.0.css">
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
$database = new database();
$func=$_GET['func'];
switch($func)
{
	case "alluserlists":
		$user=$_GET['user'];
		$database->users_lists($user);
		break;
	#-------------
	
	case "useraplist":
		$row=$_GET['row'];
		$database->user_ap_list($row);
		break;
	#-------------
	
	case "allusers":
		$database->all_users();
		break;
	#-------------
	
	case "allap":
		$user = $_GET['user'];
		$database->all_users_ap($user);
		break;
	#-------------
	
	case "":
		?>
		<h1>Hey you can do that!, Go back and do it right</h1>
		<?php
}
$filename = $_SERVER['SCRIPT_FILENAME'];
footer($filename);
?>