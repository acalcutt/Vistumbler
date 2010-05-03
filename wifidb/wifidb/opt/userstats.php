<?php
global $theme;
$theme = (@$_COOKIE['wifidb_theme']=='' ? @$_COOKIE['wifidb_theme'] : 'wifidb');
include('../lib/database.inc.php');

if(isset($_GET['user'])){pageheader("Stats for User: ".$_GET['user']);}
else{pageheader("Users Stats Page");}
echo '<p align="center">';
include('../lib/config.inc.php');

$func = strip_tags(addslashes(@$_GET['func']));

$database = new database();
		switch($func)
		{
			case "alluserlists":
				$username_get = $_GET['user'];
				$username_get = strip_tags($username_get);
				$username = smart_quotes($username_get);
				
				$database->users_lists($username);
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
footer($_SERVER['SCRIPT_FILENAME']);
?>