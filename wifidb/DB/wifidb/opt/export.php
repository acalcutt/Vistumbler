<?php
include('../lib/config.inc.php');
include('../lib/database.inc.php');

pageheader("Export To File");
	?>
	</td>
			<td width="80%" bgcolor="#A9C6FA" valign="top" align="center">
				<p align="center">
			<h2>Export Access Points to File</h2>
<?php
$database = new database();

	if(isset($_GET['func'])){$func=$_GET['func'];}elseif(isset($_POST['func'])){$func = $_POST['func'];}else{$func="";}

	if(isset($_GET['user'])){$user=$_GET['user'];}elseif(isset($_POST['user'])){$user = $_POST['user'];}else{$user="";}
	
	if(isset($_GET['row'])){$row=$_GET['row'];}elseif(isset($_POST['row'])){$row = $_POST['row'];}else{$row=0;}
	
switch($func)
{
	case "index":
		?>
		
		<form action="export.php?func=exp_user_all_kml" method="post" enctype="multipart/form-data">
		<table border="1" cellspacing="0" cellpadding="3">
		<tr class="style4"><th colspan="2">Export All Acess Points for a User</th></tr>
		<tr><td>Username</td><td>
			<select name="user">
			<?php
			include('../lib/config.inc.php');
			mysql_select_db($db,$conn);
			$sql = "SELECT * FROM `users` ORDER BY username ASC";
			$re = mysql_query($sql, $conn) or die(mysql_error());
			while($user_array = mysql_fetch_array($re))
			{
				$users[]=$user_array['username'];
			}
			$users = array_unique($users);
			if($users==NULL)
			{
				echo '<option value="">There are no Users<option value="">import something first';
			}else
			{
				foreach($users as $user)
				{
					echo '<option value="'.$user.'">'.$user."\r\n";
				}
			}
			?>
			</select>
			</td></tr>
			<tr><td colspan="2" align="right"><input type="submit" value="Export This Users Access points"></td>
		</table>
		</form>
		
		<form action="export.php?func=exp_single_ap" method="post" enctype="multipart/form-data">
		<table border="1" cellspacing="0" cellpadding="3">
		<tr class="style4"><th colspan="2">Export an Acess Point to KML</th></tr>
		<tr><td>Access Point</td><td>
			<select name="row">
			<?php
			include('../lib/config.inc.php');
			mysql_select_db($db,$conn);
			$sql = "SELECT `id`,`ssid` FROM `$wtable` order by id asc";
			$re = mysql_query($sql, $conn) or die(mysql_error());
			$rows = mysql_num_rows($re);
			if($rows ==0)
			{
				echo '<option value="">There are no APs<option value="">import something first';
			}else
			{
				while($user_array = mysql_fetch_array($re))
				{
					echo '<option value="'.$user_array["id"].'">'.$user_array["id"].'-'.$user_array["ssid"]."\r\n";
				}
			}
			?>
			</select>
			</td></tr>
			<tr><td colspan="2" align="right"><input type="submit" value="Export This Access Point"></td>
		</table>
		</form>
		
		<table border="1" cellspacing="0" cellpadding="3">
		
		<tr class="style4"><th colspan="2">Export All Acess Points in the Database to KML</th></tr>
		<tr><td colspan="2" align="center">
		<?php
		$rows = mysql_num_rows($re);
		if($rows ==0)
		{
			echo 'There are no APs to Export to a KML file';
		}else
		{
			?>
				<a class="links" href="export.php?func=exp_all_db_kml">Export All Access Points</a>
			<?php
		}
		?>
		</td></tr>
		</table>
		<br>
		<form action="export.php?func=exp_user_list" method="post" enctype="multipart/form-data">
		<table border="1" cellspacing="0" cellpadding="3">
		<tr class="style4"><th colspan="2">Export a Users Import List to KML</th></tr>
		<tr><td>User List</td><td>
			<select name="row">
			<?php
			include('../lib/config.inc.php');
			mysql_select_db($db,$conn);
			$sql = "SELECT * FROM `users` order by username asc";
			$re = mysql_query($sql, $conn) or die(mysql_error());
			$rows = mysql_num_rows($re);
			if($rows == 0)
			{
				echo '<option value="">There are no Users<option value="">import something first';
			}else
			{
				while($user_array = mysql_fetch_array($re))
				{
					$points = explode("-", $user_array['points']);
					$totalap = count($points);
					if($user_array['title']==''){$title = "Untitled";}else{$title = $user_array['title'];}
					echo '<option value="'.$user_array["id"].'">User: '.$user_array["username"].' - Title: '.$title." - APs: ".$totalap."\r\n";
				}
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
	case "exp_all_db_vs1":
		echo "<h2>Export All Aps to VS1</h2>";
		$database->exp_vs1("exp_all_db_vs1",$user,$row);
		break;
	#--------------------------
	case "exp_all_signal":
		echo "<h2>Plot all signals for import to KML</h2>";
		$database->exp_kml("exp_all_signal",$user,$row);
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
	case '':
		echo "You have done something wrong, go back and try again man.";
		break;
}
$filename = $_SERVER['SCRIPT_FILENAME'];
footer($filename);
?>