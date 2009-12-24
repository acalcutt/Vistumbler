<?php
error_reporting(E_ALL|E_STRICT);
global $screen_output;
$screen_output = "CLI";
ini_set("memory_limit","3072M"); //lots of GPS cords need lots of memory
#####################
if(!(require_once 'config.inc.php')){die("You need to create and configure your config.inc.php file in the [tools dir]/daemon/config.inc.php");}
if($GLOBALS['wifidb_install'] == ""){die("You need to edit your daemon config file first in: [tools dir]/daemon/config.inc.php");}
require_once $GLOBALS['wifidb_install']."/lib/database.inc.php";
require_once $GLOBALS['wifidb_install']."/lib/config.inc.php";

require $GLOBALS['wifidb_install']."/lib/config.inc.php";
require_once $GLOBALS['wifidb_install']."/cp/admin/lib/administration.inc.php";
$PHP_OS = PHP_OS;
$OS = $PHP_OS[0];
if($GLOBALS['colors_setting'] == 0 or $OS == "W")
{
	$COLORS = array(
					"LIGHTGRAY"	=> "",
					"BLUE"		=> "",
					"GREEN"		=> "",
					"RED"		=> "",
					"YELLOW"	=> ""
					);
}else
{
	$COLORS = array(
					"LIGHTGRAY"	=> "\033[0;37m",
					"BLUE"		=> "\033[0;34m",
					"GREEN"		=> "\033[0;32m",
					"RED"		=> "\033[0;31m",
					"YELLOW"	=> "\033[1;33m"
					);
}
if($OS == "WINNT"){$dim = "\\";}else{$dim = "/";}
$conn			= 	$GLOBALS['conn'];
$db				= 	$GLOBALS['db'];
$db_st			= 	$GLOBALS['db_st'];
$wtable			=	$GLOBALS['wtable'];
$users_t		=	$GLOBALS['users_t'];
$gps_ext		=	$GLOBALS['gps_ext'];
$files			=	$GLOBALS['files'];
$user_logins_table = $GLOBALS['user_logins_table'];
$root			= 	$GLOBALS['root'];
$half_path		=	$GLOBALS['wifidb_install'].'/';
$verbose		=	$GLOBALS['verbose'];
$screen_output	=	$GLOBALS['screen_output'];
$DBSTATS_time_interval_to_check = $GLOBALS['DBSTATS_time_interval_to_check'];
$date_format	=	"Y-m-d H:i:s.u";

$enable_mail_admin = 0;
$pid_file = $GLOBALS['pid_file_loc'].'dbstatsd.pid';
$This_is_me = getmypid();
fopen($pid_file, "w");
$fileappend = fopen($pid_file, "a");
$write_pid = fwrite($fileappend, "$This_is_me");
if(!$write_pid){die($GLOBALS['COLORS']['RED']."Could not write pid file, thats not good... >:[".$GLOBALS['COLORS']['LIGHTGRAY']);}
$PHP_OS = PHP_OS;
$OS = $PHP_OS[0];

if($GLOBALS['colors_setting'] == 0 or $OS == "W")
{
	$COLORS = array(
					"LIGHTGRAY"	=> "",
					"BLUE"		=> "",
					"GREEN"		=> "",
					"RED"		=> "",
					"YELLOW"	=> ""
					);
}else
{
	$COLORS = array(
					"LIGHTGRAY"	=> "\033[0;37m",
					"BLUE"		=> "\033[0;34m",
					"GREEN"		=> "\033[0;32m",
					"RED"		=> "\033[0;31m",
					"YELLOW"	=> "\033[1;33m"
					);
}
if($OS == "WINNT"){$dim = "\\";}else{$dim = "/";}
#wait for MySQL to become responsive to the script...
$sql_stat = mysql_stat($conn);
#	echo $sql_stat."\r\n";
$sql_stat_7 = substr($sql_stat, 0, 6);
#	echo $sql_stat_7."\r\n";
while($sql_stat_7 != "Uptime")
{
	$sql_stat = mysql_stat($conn);
	$sql_stat_7 = substr($sql_stat, 0, 6);
	echo $sql_stat_7."\r\n";
}

verbosed($GLOBALS['COLORS']['GREEN']."
WiFiDB 'Database Statistics Daemon'
Version: 1.0.0
- Daemon Start: 2009-12-07
- Last Daemon File Edit: 2009-12-12
( /tools/daemon/wifidbd.php -> daemon_stats() )
- By: Phillip Ferland ( longbow486@gmail.com )
- http://www.randomintervals.com

PID: [ $This_is_me ]
".$GLOBALS['COLORS']['LIGHTGRAY'], 1, $screen_output, 1);

#	echo mysql_stat($conn)."\r\n";

while(TRUE)
{
	$date = date("Y-m-d G:i:s");
	$sql0 = "SELECT `id` FROM `$db`.`$wtable`";
#	echo $sql0."\r\n";
	$result0 = mysql_query($sql0, $conn) or die(mysql_error($conn));
	echo date($date_format,time())." -> ";
	if($total_aps = mysql_num_rows($result0))
	{verbosed($GLOBALS['COLORS']['GREEN']."Retreived Total AP count.".$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output, 1);}
	else{verbosed($GLOBALS['COLORS']['RED']."Failed to Retreived Total AP count.".$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output, 1);}
	
	
	#####################
	$sql0 = "SELECT `id` FROM `$db`.`$wtable` WHERE `encry` = 'WEP'";
#	echo $sql0."\r\n";
	$result0 = mysql_query($sql0, $conn) or die(mysql_error($conn));
	echo date($date_format,time())." -> ";
	if($wep_aps = mysql_num_rows($result0))
	{verbosed($GLOBALS['COLORS']['GREEN']."Retreived Total WEP AP count.".$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output, 1);}
	else{verbosed($GLOBALS['COLORS']['RED']."Failed to Retreived Total WEP AP count.".$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output, 1);}
	
	#####################
	$sql0 = "SELECT `id` FROM `$db`.`$wtable` WHERE `auth` LIKE 'WPA2%'";
#	echo $sql0."\r\n";
	$result0 = mysql_query($sql0, $conn) or die(mysql_error($conn));
	echo date($date_format,time())." -> ";
	if($secure_aps = mysql_num_rows($result0))
	{verbosed($GLOBALS['COLORS']['GREEN']."Retreived Total Secure AP count.".$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output, 1);}
	else{verbosed($GLOBALS['COLORS']['RED']."Failed to Retreived Secure Total AP count.".$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output, 1);}
	
	#####################
	$sql0 = "SELECT `id` FROM `$db`.`$wtable` WHERE `encry` = 'None'";
#	echo $sql0."\r\n";
	$result0 = mysql_query($sql0, $conn) or die(mysql_error($conn));
	echo date($date_format,time())." -> ";
	if($open_aps = mysql_num_rows($result0))
	{verbosed($GLOBALS['COLORS']['GREEN']."Retreived Total Open AP count.".$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output, 1);}
	else{verbosed($GLOBALS['COLORS']['RED']."Failed to Retreived Open Total AP count.".$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output, 1);}
	
	
	#####################
	$files_sizes = array();
	$file_num = 0;
	$files_sizes_total = 0;
	
	$sql0 = "SELECT * FROM `$db`.`$files`";
#	echo $sql0."\r\n";
	$result0 = mysql_query($sql0, $conn) or die(mysql_error($conn));
	echo date($date_format,time())." -> ";
	if($result0){verbosed($GLOBALS['COLORS']['GREEN']."Retreived Files from the table.".$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output, 1);}
	else{verbosed($GLOBALS['COLORS']['RED']."Failed to Retreive Files from the table.".mysql_error($conn).$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output, 1);}

	$files_uploaded = mysql_num_rows($result0);
	$import_path = $half_path."import/up/";
	echo $import_path."\r\n".$files_uploaded."\r\n";
	while($files_array = mysql_fetch_array($result0))
	{
		if(file_exists($import_path.$files_array['file']))
		{
			$size_file = dos_filesize($import_path.$files_array['file']);
		}else
		{
			continue;
		}
		$files_sizes_total += $size_file;
		$files_sizes[] = $size_file;
		echo $file_num;
		if($file_num != $files_uploaded){echo " - ";}
		$file_num++;
	}
	rsort($files_sizes);
	
	echo "\r\n".date($date_format,time())." -> ";
	verbosed($GLOBALS['COLORS']['GREEN']."Sorted Files Array.".$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output, 1);
	$count = count($files_sizes);
	if(@$files_sizes_total > 0)
	{
		$files_avg = $files_sizes_total/$file_num;
	#		echo $files_sizes_total.'/'.$file_num."<BR>";
	}else
	{
		$files_sizes[0] = 0;
		$files_sizes[$count-1] = 0;
		$files_avg = 0;
	}
	echo date($date_format,time())." -> ";
	verbosed($GLOBALS['COLORS']['GREEN']."Calculated File sizes.".$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output, 1);
	$files_sizes_total = format_size($files_sizes_total , $round = 2);
	$file_max = format_size($files_sizes[0] , $round = 2);
	$file_min = format_size($files_sizes[$count-1] , $round = 2);
	$file_avg = format_size($files_avg , $round = 2);
	echo date($date_format,time())." -> ";
	if($count > 0){verbosed($GLOBALS['COLORS']['GREEN']."Retreived Total Import File Sizes.".$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output, 1);}
	else{verbosed($GLOBALS['COLORS']['RED']."Failed to Retreived Total Import File Sizes.".$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output, 1);}
	#####################
	
	
	##### (user most APS) ###
	echo "\r\n".date($date_format,time())." -> ";
	verbosed($GLOBALS['COLORS']['GREEN']."Starting Users Aps count.".$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output, 1);
	$user_s = array();
	$user_s_ = array();
	$sql10 = "SELECT `username` FROM `$db`.`$users_t`";
	$result10 = mysql_query($sql10, $conn);# or die(mysql_error($conn));
	while($users = mysql_fetch_array($result10))
	{
		$user_s[] = $users['username'];
	}
	
	$user_s = array_merge(array_unique($user_s));
#			dump(array_merge($user_s));
	echo "\r\n".date($date_format,time())." -> ";
	verbosed($GLOBALS['COLORS']['GREEN']."Gathered a Users Array.".$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output, 1);
	foreach($user_s as $key=>$user)
	{
		$points = 0;
		$sql11 = "SELECT `points` FROM `$db`.`$users_t` where `username` = '$user'";
		$result11 = mysql_query($sql11, $conn);# or die(mysql_error($conn));
		while($user_a = mysql_fetch_array($result11))
		{
			foreach(explode("-",$user_a['points']) as $point)
			{
			#	0,1:1
				$pnt = explode("," , $point);
				if($pnt[0] == 1){continue;}else{$points++;}
			}
		}
#		echo $points.",".$user_s[$key]."<br>";
		$user_s_[] = array($points, $user);
	}
	rsort($user_s_);
	echo "\r\n".date($date_format,time())." -> ";
	verbosed($GLOBALS['COLORS']['GREEN']."Sorted Users APs Array.".$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output, 1);
	$user_s_a = array();
	foreach($user_s_ as $user)
	{
		$user_s_a[] = implode("|", $user);
	}
	$user_s_str = implode('-', $user_s_a);
	echo date($date_format,time())." -> ";
	if(is_array($user_s_)){verbosed($GLOBALS['COLORS']['GREEN']."Finished Users AP count.".$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output, 1);}
	else{verbosed($GLOBALS['COLORS']['RED']."Failed to Finish Total Users AP count.".$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output, 1);}
#		dump($user_s_);
	####
	
	##### (user most geo) ###
	echo "\r\n".date($date_format,time())." -> ";
	verbosed($GLOBALS['COLORS']['GREEN']."Starting Users Geocaches.".$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output, 1);
	$users = array();
	$sql0 = "SELECT `username` FROM `$db`.`$user_logins_table`";
	$result0 = mysql_query($sql0, $conn);# or die(mysql_error($conn));
	while($users_array = mysql_fetch_array($result0))
	{
		$users[] = $users_array['username'];
	}
	$users = array_merge(array_unique($users));
	echo "\r\n".date($date_format,time())." -> ";
	verbosed($GLOBALS['COLORS']['GREEN']."Grabbed Users Array.".$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output, 1);
	$geos = array();
	foreach($users as $user)
	{
		$sql0 = "SELECT `id` FROM `$db`.`".$user."_waypoints`";
		if($result0 = mysql_query($sql0, $conn)); # or die(mysql_error($conn));)
		{
			$geos[] = array( mysql_num_rows($result0), $user);
		}
	}
	#dump($geos);
	rsort($geos);
	echo "\r\n".date($date_format,time())." -> ";
	verbosed($GLOBALS['COLORS']['GREEN']."Sorted Users Geocache Array.".$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output, 1);
	$geo_a = array();
	foreach($geos as $geo)
	{
		$geo_a[] = implode("|", $geo);
	}
	$geos = implode("-", $geo_a);
	echo date($date_format,time())." -> ";
	if(is_array($geo_a)){verbosed($GLOBALS['COLORS']['GREEN']."Retreived Total Users Geocaches count.".$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output, 1);}
	else{verbosed($GLOBALS['COLORS']['RED']."Failed to Retreived Total Users Geocaches count.".$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output, 1);}
	#dump($geos);
#	$geos = gzcompress($geos,9);
	####
	
	##### (number of graphs) ###
	echo "\r\n".date($date_format,time())." -> ";
	verbosed($GLOBALS['COLORS']['GREEN']."Starting to calculate the Graphs folder size.".$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output, 1);
	$graph_dir = dirSize('out/graph/', 1);
	list($graph_size, $graph_num, $graph_max, $graph_min, $graph_avg) = $graph_dir;
	$graph_size = format_size($graph_size , $round = 2);
	$graph_max = format_size($graph_max , $round = 2);
	$graph_min = format_size($graph_min , $round = 2);
	$graph_avg = format_size($graph_avg , $round = 2);
	echo date($date_format,time())." -> ";
	if($graph_avg != "0kb"){verbosed($GLOBALS['COLORS']['GREEN']."Retreived Total Graph file sizes.".$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output, 1);}
	else{verbosed($GLOBALS['COLORS']['RED']."Failed to Retreived Total Graph file sizes.".$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output, 1);}
	####
	
	##### (files exported) ###
	echo "\r\n".date($date_format,time())." -> ";
	verbosed($GLOBALS['COLORS']['GREEN']."Starting to calculate the Exports folder size.".$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output, 1);
	$kmz_dir = dirSize('out/kmz/', 1);
	list($kmz_size, $kmz_num, $kmz_max, $kmz_min, $kmz_avg) = $kmz_dir;
	$kmz_size = format_size($kmz_size , $round = 2);
	$kmz_max = format_size($kmz_max , $round = 2);
	$kmz_min = format_size($kmz_min , $round = 2);
	$kmz_avg = format_size($kmz_avg , $round = 2);
	echo date($date_format,time())." -> ";
	if($kmz_avg != "0kb"){verbosed($GLOBALS['COLORS']['GREEN']."Retreived Total KMZ file sizes.".$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output, 1);}
	else{verbosed($GLOBALS['COLORS']['RED']."Failed to Retreived Total KMZ file sizes.".$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output, 1);}
	###
	
	
	##### (AP with most GPS cords) ####
	echo "\r\n".date($date_format,time())." -> ";
	verbosed($GLOBALS['COLORS']['GREEN']."Starting APs with most GPS.".$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output, 1);
	$aps_gps_totals = array();
	$sql00 = "SELECT * FROM `$db`.`$wtable`";
	$result00 = mysql_query($sql00, $conn);# or die(mysql_error($conn));
	while($all_array = mysql_fetch_array($result00))
	{
		$ssid_pt_s = smart_quotes($all_array['ssid']);
		$ssid_pt_ss[0] = $ssid_pt_s;
		$ssid_pt_ss = str_split($ssid_pt_s,25); //split SSID in two at is 25th char.
		$ssid = $ssid_pt_ss[0];
#		$ssid_s = make_ssid($all_array['ssid']);
#		$ssid = $ssid_s[0];
		$table = $ssid.'-'.$all_array['mac'].'-'.$all_array['sectype'].'-'.$all_array['radio'].'-'.$all_array['chan'].$gps_ext;

		$sql01 = "SELECT `id` FROM `$db_st`.`$table`";
#		echo $sql01.'<br>';
		$result01 = mysql_query($sql01, $conn);# or die(mysql_error($conn));;
		$num_gps = @mysql_num_rows($result01);
#		echo $all_array['ssid']." , ".$num_gps." <br>";
		$aps_gps_totals[] = array($num_gps , $all_array['ssid']);
	}
	echo "\r\n".date($date_format,time())." -> ";
	verbosed($GLOBALS['COLORS']['GREEN']."Sorted APs GPS Array.".$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output, 1);
	rsort($aps_gps_totals);
	$ap_gps_totals_a = array();
	foreach($aps_gps_totals as $gps)
	{	
	#	dump($gps);
		$ap_gps_totals_a[] = implode('|', $gps);
	}
	$ap_gps_totals_s = implode('-', $ap_gps_totals_a);
	echo date($date_format,time())." -> ";
	if(is_array($aps_gps_totals)){verbosed($GLOBALS['COLORS']['GREEN']."Retreived Total GPS cords for each AP.".$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output, 1);}
	else{verbosed($GLOBALS['COLORS']['RED']."Failed to Retreived Total GPS cords for each AP.".$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output, 1);}
	####

	####
	echo date($date_format,time())." -> ";
	verbosed($GLOBALS['COLORS']['GREEN']."Starting to Calculate the Top SSID's.".$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output, 1);
	$top_ssids = top_ssids();
	echo date($date_format,time())." -> ";
	if(is_array($top_ssids)){verbosed($GLOBALS['COLORS']['GREEN']."Finished Calculating the Top SSID's.".$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output, 1);}
	else{verbosed($GLOBALS['COLORS']['RED']."Failed Calculating the Top SSID's.".$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output, 1);}
	echo date($date_format,time())." -> ";
	verbosed($GLOBALS['COLORS']['GREEN']."Starting to Implode the Top SSID's array into a string.".$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output, 1);
	$top_ssids_a = array();
	$count_ssids = 1;
	foreach($top_ssids as $ssid)
	{
		$top_ssids_a[] = implode("|", $ssid);
		$count_ssids++;
	}
	$top_ssids_s = implode('-', $top_ssids_a);
#	$top_ssids_s = '';
	echo date($date_format,time())." -> ";
	if(is_array($top_ssids)){verbosed($GLOBALS['COLORS']['GREEN']."Finished Imploding of Top SSIDs. [ $count_ssids Unique SSIDs ] ".$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output, 1);}
	else{verbosed($GLOBALS['COLORS']['RED']."Failed to Finish Imploding of Top SSIDs.".$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output, 1);}
	#####
	
	#####
	$insert = "INSERT INTO `$db`.`DB_stats`( `id`, `timestamp`, `graph_min`, `graph_max`, `graph_avg`, `kmz_min`, `kmz_max`, `kmz_avg`, `file_min`, `file_max`, `file_avg`, `total_aps`, `wep_aps`, `open_aps`, `secure_aps`,`user`, `ap_gps_totals`, `top_ssids`, `nuap`, `geos`) VALUES('', '$date','$graph_min', '$graph_max', '$graph_avg', '$kmz_min', '$kmz_max', '$kmz_avg', '$file_min', '$file_max', '$file_avg', '$total_aps', '$wep_aps', '$open_aps', '$secure_aps', '$user_s_str', '$ap_gps_totals_s', '$top_ssids_s', '$count_ssids', '$geos')";
	#echo $insert."\r\n";
	$fp = fopen('data.txt', 'w');
	fwrite($fp, $insert."\r\n");
	fclose($fp);
	
	if(!$result_insert = mysql_query($insert, $conn))
	{
		echo date($date_format,time())." -> ";
		mail_admin("There was an error inserting the Database Statistics data into the `DB_stats` table. :-(", $enable_mail_admin, 1);
		verbosed($GLOBALS['COLORS']['RED']."Failed to Insert Data into The Database.".mysql_error($conn).$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output, 1);
	}else
	{
		echo date($date_format,time())." -> ";
		verbosed($GLOBALS['COLORS']['GREEN']."Inserted Data into The Database.".$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output, 1);
	}
	echo date($date_format,time())." -> ";
	verbosed($GLOBALS['COLORS']['GREEN']."Going to sleep for ".($DBSTATS_time_interval_to_check/60)." Minutes.".$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, $screen_output, 1);
	sleep($DBSTATS_time_interval_to_check);
}

?>