<?php
global $theme;
$theme = ($_COOKIE['wifidb_theme']=='' ? $_COOKIE['wifidb_theme'] : 'wifidb');
include('../lib/database.inc.php');

if(isset($_GET['user'])){pageheader("Stats for User: ".$_GET['user']);}
else{pageheader("Users Stats Page");}
echo '<p align="center">';
include('../lib/config.inc.php');

$database = new database();
if (isset($_GET['token']))
{
	if (isset($_SESSION['token']) && $_GET['token'] == $_SESSION['token'])
	{
		$func=$_GET['func'];
		switch($func)
		{
			case "alluserlists":
				$username_get = $_GET['user'];
				$username_get = strip_tags($username_get);
				$username = smart_quotes($username_get);
				$sql = "SELECT * FROM `$db`.`users` WHERE `username` LIKE '$username' ORDER BY `id` DESC LIMIT 1";
				$user_query = mysql_query($sql, $conn) or die(mysql_error($conn));
				$user_last = mysql_fetch_array($user_query);
				$last_import_id = $user_last['id'];
				$user_aps = $user_last['aps'];
				$user_gps = $user_last['gps'];
				$last_import_title = $user_last['title'];
				$last_import_date = $user_last['date'];
				
				$sql = "SELECT * FROM `$db`.`users` WHERE `username` LIKE '$username' ORDER BY `id` ASC LIMIT 1";
				$user_query = mysql_query($sql, $conn) or die(mysql_error($conn));
				$user_first = mysql_fetch_array($user_query);
				$user_ID = $user_first['id'];
				$first_import_date = $user_first['date'];
				
				$sql = "SELECT * FROM `$db`.`users` WHERE `username` LIKE '$username'";
				$other_imports = mysql_query($sql, $conn) or die(mysql_error($conn));
				while($imports = mysql_fetch_array($other_imports))
				{
					if($imports['points'] == ""){continue;}
					$points = explode("-",$imports['points']);
					foreach($points as $key=>$pt)
					{
						$pt_ex = explode(",", $pt);
						if($pt_ex[0] == 1)
						{
							unset($points[$key]);
						}
					}
					$pts_count = count($points);
					$total_aps[] = $pts_count;
				}
				$total = 0;
				foreach($total_aps as $totals)
				{
					$total += $totals;
				}
				?>
				<table width="90%" border="1" align="center">
				<tr bgcolor="#477DA9"><th colspan="4">Stats for : <?php echo $username;?></th></tr>
				<tr bgcolor="#508FAE"><th>ID</th><th>Total APs</th><th>First Import</th><th>Last Import</th></tr>
				<tr bgcolor="#A9C6FA"><td><?php echo $user_ID;?></td><td><a class="links" href="../opt/userstats.php?func=allap&user=<?php echo $username?>&token=<?php echo $_SESSION['token']?>"><?php echo $total;?></a></td><td><?php echo $first_import_date;?></td><td><?php echo $last_import_date;?></td></tr>
				</table>
				<br>

				<table width="90%" border="1" align="center">
				<tr bgcolor="#477DA9"><th colspan="4">Last Import Details</th></tr>
				<tr bgcolor="#508FAE"><th>ID</th><th colspan="3">Title</th></tr>
				
				<tr bgcolor="#A9C6FA"><td align="center"><?php echo $last_import_id;?></td><td colspan="4" align="center"><a class="links" href="../opt/userstats.php?func=useraplist&row=<?php echo $last_import_id.'&token='.$_SESSION['token'];?>"><?php echo $last_import_title;?></a></td></tr>
				
				<tr bgcolor="#508FAE"><th colspan="2">Date</th><th>Total APs</th><th>Total GPS</th></tr>
				
				<tr bgcolor="#A9C6FA"><td colspan="2" align="center"><?php echo $last_import_date;?></td><td align="center"><?php echo $user_aps; ?></td><td align="center"><?php echo $user_gps;?></td></tr>
				</table>
				<br>
				
				<table width="90%" border="1" align="center">
				<tr bgcolor="#477DA9"><th colspan="4">All Previous Imports</th></tr>
				<tr bgcolor="#508FAE"><th>ID</th><th>Title</th><th>Total APs</th><th>Date</th></tr>
				
				<?php
				$sql = "SELECT * FROM `$db`.`users` WHERE `username` LIKE '$username' AND `id` != '$last_import_id' ORDER BY `id` DESC";
				$other_imports = mysql_query($sql, $conn) or die(mysql_error($conn));
				$other_rows = mysql_num_rows($other_imports);
				
				if($others_rows != "0")
				{
					while($imports = mysql_fetch_array($other_imports))
					{
						if($imports['points'] == ""){continue;}
						$import_id = $imports['id'];
						$import_title = $imports['title'];
						$import_date = $imports['date'];
						$import_ap = $imports['aps'];
						?>
						<tr bgcolor="#A9C6FA"><td><?php echo $import_id;?></td><td><a class="links" href="../opt/userstats.php?func=useraplist&row=<?php echo $import_id.'&token='.$_SESSION['token'];?>"><?php echo $import_title;?></a></td><td><?php echo $import_ap;?></td><td><?php echo $import_date;?></td></tr>
						<?php
					}
				}else
				{
					?>
						<tr bgcolor="#A9C6FA"><td colspan="4" align="center">There are no other Imports. Go get some.</td></tr>
					<?php
				}
				?>
				</table>
				<?php
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
		echo "</p>";
	}else
	{
		echo "<h2>Could not Compare Tokens, try again.</h2>";
	}
}else
{
	echo "<h2>You dont have a token, try again</h2>";
}

$filename = $_SERVER['SCRIPT_FILENAME'];
footer($filename);
?>