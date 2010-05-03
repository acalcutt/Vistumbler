<?php
include('../lib/database.inc.php');
pageheader("Exports Page");
include('../lib/config.inc.php');

$conn			= 	$GLOBALS['conn'];
$db				= 	$GLOBALS['db'];
$db_st			= 	$GLOBALS['db_st'];
$wtable			=	$GLOBALS['wtable'];
$users_t		=	$GLOBALS['users_t'];
$gps_ext		=	$GLOBALS['gps_ext'];
$root			= 	$GLOBALS['root'];
$half_path		=	$GLOBALS['half_path'];
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
		<table border="1" cellspacing="0" cellpadding="3" align="center">
		<tr class="style4"><th colspan="2">Export a Users Import List to KML</th></tr>
		<tr class="light">
			<td>User Import List: </td>
			<td>
				<select name="row">
				<?php
				$rows = 0;
				mysql_select_db($db,$conn);
				$sql = "SELECT `id`,`title`, `username`, `aps`, `date` FROM `$db`.`$users_t`";
				$re = mysql_query($sql, $conn) or die(mysql_error());
				$rowsl = mysql_num_rows($re);
				if($rowsl < 1)
				{
					echo '<option selected value""> No Imports to export.';
				}else
				{
					while($user_array = mysql_fetch_array($re))
					{
						echo '<option value="'.$user_array["id"].'">User: '.$user_array["username"].' - Title: '.$user_array["title"]." - # APs: ".$user_array["aps"]." - # Date: ".$user_array["date"]."\r\n";
						$rows++;
					}
				}
				?>
				</select>
				</td>
			</tr>
			<tr class="light">
				<td colspan="2" align="right">
				<?php
				if($rowsl)
				{
				?>
					<input type="submit" value="Export This Users List">
				<?php
				}
				?>
				</td>
			</tr>
		</table>
		</form>
		
		<form action="export.php?func=exp_user_all_kml" method="post" enctype="multipart/form-data">
		<table border="1" cellspacing="0" cellpadding="3" align="center">
		<tr class="style4"><th colspan="2">Export All Access Points for a User</th></tr>
		<tr class="light"><td>Username: </td><td>
			<select name="user">
			<?php
			mysql_select_db($db,$conn);
			$sql = "SELECT `username` FROM `$db`.`$users_t`";
			$re = mysql_query($sql, $conn) or die(mysql_error());
			$rowsu = mysql_num_rows($re);
			if($rowsu < 1)
			{
				$USERNAMES[]="No Users";
			}else
			{
				while($user_array = mysql_fetch_array($re))
				{
					$USERNAMES[]=$user_array["username"];
				}
			}
			$USERNAMES = array_unique($USERNAMES);
			
			foreach($USERNAMES as $USERN)
			{
				echo '<option value="'.$USERN.'">'.$USERN."\r\n";
			}
			?>
			</select>
			</td></tr>
			<tr class="light"><td colspan="2" align="right">
			<?php
			if($rowsu)
			{
			?>
				<input type="submit" value="Export This Users Access points">
			<?php
			}
			?>
			</td>
		</table>
		</form>
		<?php
		break;
	#--------------------------
	case "exp_user_all_kml":
		$row = 0;
		$database->exp_kml($export="exp_user_all_kml", $user,$row, $named=0);
		break;
	#--------------------------
	case "exp_all_db_kml": 
		$user ='';
		$row = 0;
		$database->exp_kml($export="exp_all_db_kml",$user,$row, $named=0);
		break;
	#--------------------------
	case "exp_user_list": 
		$user ="";
		$database->exp_kml($export="exp_user_list",$user,$row, $named=0);
		break;
	#--------------------------	\
	case "exp_all_signal_gpx": 
		$user ="";
		$database->exp_kml($export="exp_all_signal_gpx",$user,$row, $named=0);
		break;
	#--------------------------
	case "exp_all_signal": 
		$user ="";
		$database->exp_kml($export="exp_all_signal",$user,$row, $named=0);
		break;
	#--------------------------
	case "exp_single_ap": 
		$user ="";
		$database->exp_kml($export="exp_single_ap",$user,$row, $named=0);
		break;
	#--------------------------
	case NULL:

	echo "You have done something wrong, go back and try again man.";
	break;
}
$filename = $_SERVER['SCRIPT_FILENAME'];
footer($filename);
?>