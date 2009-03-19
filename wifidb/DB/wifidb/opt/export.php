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
			<h2>Export Access Points to KML</h2>
<?php
$database = new database();

$func=$_GET['func'];

	if(isset($_GET['user'])){$user=$_GET['user'];}elseif(isset($_POST['user'])){$user = $_POST['user'];}
	
	if(isset($_GET['row'])){$row=$_GET['row'];}elseif(isset($_POST['row'])){$row = $_POST['row'];}
	
switch($func)
{
	case "index":
		?>
		
		<form action="export.php?func=exp_user_all_kml" method="post" enctype="multipart/form-data">
		<table border="1" cellspacing="0" cellpadding="3">
		<tr><th colspan="2">Export All Acess Points for a User</th></tr>
		<tr><td>Username</td><td>
			<select name="user">
			<?php
			include('../lib/config.inc.php');
			mysql_select_db($db,$conn);
			$sql = "SELECT `username` FROM `users`";
			$re = mysql_query($sql, $conn) or die(mysql_error());
			while($user_array = mysql_fetch_array($re))
			{
				echo '<option value="'.$user_array["username"].'">'.$user_array["username"]."\r\n";
			}
			?>
			</select>
			</td></tr>
			<tr><td colspan="2" align="right"><input type="submit" value="Export This Users Access points"></td>
		</table>
		</form>
		
		<form action="export.php?func=exp_single_ap" method="post" enctype="multipart/form-data">
		<table border="1" cellspacing="0" cellpadding="3">
		<tr><th colspan="2">Export an Acess Point to KML</th></tr>
		<tr><td>Username</td><td>
			<select name="row">
			<?php
			include('../lib/config.inc.php');
			mysql_select_db($db,$conn);
			$sql = "SELECT `id`,`ssid` FROM `$wtable`";
			$re = mysql_query($sql, $conn) or die(mysql_error());
			while($user_array = mysql_fetch_array($re))
			{
				echo '<option value="'.$user_array["id"].'">'.$user_array["id"].'-'.$user_array["ssid"]."\r\n";
			}
			?>
			</select>
			</td></tr>
			<tr><td colspan="2" align="right"><input type="submit" value="Export This Access Point"></td>
		</table>
		</form>
		
		<table border="1" cellspacing="0" cellpadding="3">
		<tr><th colspan="2">Export All Acess Points in the Database to KML</th></tr>
		<tr><td colspan="2" align="center"><a class="links" href="export.php?func=exp_all_db_kml">Export All Access Points</a></td></tr>
		</table>
		<br>
		<form action="export.php?func=exp_user_list" method="post" enctype="multipart/form-data">
		<table border="1" cellspacing="0" cellpadding="3">
		<tr><th colspan="2">Export a Users Import List to KML</th></tr>
		<tr><td>Username</td><td>
			<select name="row">
			<?php
			include('../lib/config.inc.php');
			mysql_select_db($db,$conn);
			$sql = "SELECT `id`,`title`, `username` FROM `users`";
			$re = mysql_query($sql, $conn) or die(mysql_error());
			while($user_array = mysql_fetch_array($re))
			{
				echo '<option value="'.$user_array["id"].'">User: '.$user_array["username"].' - Title: '.$user_array["title"]."\r\n";
			}
			?>
			</select>
			</td></tr>
			<tr><td colspan="2" align="right"><input type="submit" value="Export This Users List"></td>
		</table>
		</form>
		<?php
		break;
	#--------------------------
	case "exp_user_all_kml":

		$row = 0;
		$database->exp_kml($export="exp_user_all_kml", $user,$row);
		break;
	#--------------------------
	case "exp_all_db_kml": 

		$database->exp_kml($export="exp_all_db_kml");
		break;
	#--------------------------
	case "exp_single_ap":
		$user="";
		$database->exp_kml($export="exp_single_ap",$user,$row);
		break;
	#--------------------------
	case "exp_user_list": 
		$user ="";
		$database->exp_kml($export="exp_user_list",$user,$row);
		break;
	#--------------------------
	case NULL:

	echo "You have done something wrong, go back and try again man.";
	break;
}
$filename = $_SERVER['SCRIPT_FILENAME'];
footer($filename);
?>