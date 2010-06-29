<?php
global $func, $mode;

include('../../lib/config.inc.php');
include('../../lib/database.inc.php');
include('../../lib/security.inc.php');
include('../../lib/wdb_xml.inc.php');

$sec = new security();
$xml = new WDB_XML();
$database = new database();

$func = strtolower(addslashes(@$_GET['func']));
$mode = strtolower(addslashes(@$_GET['mode']));

$login_check = $sec->login_check(1);
if(is_array($login_check) or $login_check == "No Cookie"){$login_check = 0;}else{$login_check = 1;}
if($login_check == 1)
{
	$returns = $sec->check_privs(1);
	list($priv_s1, $priv_name1) = $returns;
	if($priv_s1 >= 1000)
	{
		include('./lib/header_footer.inc.php');
		include('./lib/administration.inc.php');
		
		$admin = new admin();
		
		switch($func)
		{
			case "overview":
				admin_pageheader("Overview");
				$admin->overview($mode);
				admin_footer();
			break;
			
			case "uandp":
				admin_pageheader("Users and Permissions");
				$admin->uandp($mode);
				admin_footer();
			break;
			
			case "maint":
				admin_pageheader("Maintenance");
				$admin->maint($mode);
				admin_footer();
			break;
			
			case "system":
				admin_pageheader("System");
				$admin->sys($mode);
				admin_footer();
			break;
			
			default:
				admin_pageheader("Overview");
				$admin->overview($mode);
				admin_footer();
			break;
		}
	}else
	{
		pageheader('Non privledged User detected! Go away or the droids will be released!');
		echo "Non privledged User detected! Go away before I send out the droids...";
		footer($_SERVER['SCRIPT_FILENAME']);
	}
}else
{
	pageheader('Not logged in! Go get a cookie!');
	echo 'You are trying to access a page that needs a cookie, without having a cookie, you cant do that...<a href="'.$GLOBALS["hosturl"].$GLOBALS["root"].'/cp/?func=admin_cp">Go get a cookie</a>. make it a double stuff.<br>';
	footer($_SERVER['SCRIPT_FILENAME']);
}
?>