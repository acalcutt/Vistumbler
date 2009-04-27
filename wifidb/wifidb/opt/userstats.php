<?php
include('../lib/config.inc.php');
include('../lib/database.inc.php');
pageheader("Users Stats Page");
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