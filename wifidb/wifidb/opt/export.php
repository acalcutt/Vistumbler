<?php
include('../lib/database.inc.php');
pageheader("Exports Page");
include('../lib/config.inc.php');
?>
			<h2>Exports Page</h2>
<?php
$database = new database();
$func=$_GET['func'];

	if(isset($_GET['user'])){$user=$_GET['user'];}elseif(isset($_POST['user'])){$user = $_POST['user'];}
	
	if(isset($_GET['row'])){$row=$_GET['row'];}elseif(isset($_POST['row'])){$row = $_POST['row'];}
	
switch($func)
{
	case "index":
		?>
		<form action="export.php?func=exp_user_list" method="post" enctype="multipart/form-data">
		<table border="1" cellspacing="0" cellpadding="3">
		<tr class="style4"><th colspan="2">Export a Users Import List to KML</th></tr>
		<tr><td>User Import List: </td><td>
			<select name="row">
			<?php
			mysql_select_db($db,$conn);
			$sql = "SELECT `id`,`title`, `username`, `aps`, `date` FROM `users`";
			$re = mysql_query($sql, $conn) or die(mysql_error());
			while($user_array = mysql_fetch_array($re))
			{
				echo '<option value="'.$user_array["id"].'">User: '.$user_array["username"].' - Title: '.$user_array["title"]." - # APs: ".$user_array["aps"]." - # Date: ".$user_array["date"]."\r\n";
			}
			?>
			</select>
			</td></tr>
			<tr><td colspan="2" align="right"><input type="submit" value="Export This Users List"></td>
		</table>
		</form>
		
		<form action="export.php?func=exp_user_all_kml" method="post" enctype="multipart/form-data">
		<table border="1" cellspacing="0" cellpadding="3">
		<tr class="style4"><th colspan="2">Export All Access Points for a User</th></tr>
		<tr><td>Username: </td><td>
			<select name="user">
			<?php
			mysql_select_db($db,$conn);
			$sql = "SELECT `username` FROM `users`";
			$re = mysql_query($sql, $conn) or die(mysql_error());
			while($user_array = mysql_fetch_array($re))
			{
				$USERNAMES[]=$user_array["username"];
			}
			$USERNAMES = array_unique($USERNAMES);
			
			foreach($USERNAMES as $USERN)
			{
				echo '<option value="'.$USERN.'">'.$USERN."\r\n";
			}
			?>
			</select>
			</td></tr>
			<tr><td colspan="2" align="right"><input type="submit" value="Export This Users Access points"></td>
		</table>
		</form>
		
		<table border="1" cellspacing="0" cellpadding="3">
		<tr class="style4"><th colspan="2">Export All Access Points in the Database to KML</th></tr>
		<tr><td colspan="2" align="center"><a class="links" href="export.php?func=exp_all_db_kml">Export All Access Points</a></td></tr>
		</table>
		<br>
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
	case "exp_user_list": 
		$user ="";
		$database->exp_kml($export="exp_user_list",$user,$row);
		break;
	#--------------------------	\
	case "exp_all_signal_gpx": 
		$user ="";
		$database->exp_kml($export="exp_all_signal_gpx",$user,$row);
		break;
	#--------------------------
	case "exp_all_signal": 
		$user ="";
		$database->exp_kml($export="exp_all_signal",$user,$row);
		break;
	#--------------------------
	case NULL:

	echo "You have done something wrong, go back and try again man.";
	break;
}
$filename = $_SERVER['SCRIPT_FILENAME'];
footer($filename);
?>