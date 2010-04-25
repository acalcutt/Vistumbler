<?php
error_reporting(E_ALL);
global $screen_output, $half_path;
$screen_output = "CLI";
ini_set("memory_limit","3072M"); //lots of GPS cords need lots of memory
#####################
$PHP_OS							=	PHP_OS;
$OS								=	$PHP_OS[0];
if($OS == "WINNT"){$dim = "\\";}else{$dim = "/";}
if(!(require_once 'config.inc.php')){die("You need to create and configure your config.inc.php file in the [tools dir]/daemon/config.inc.php");}
if($GLOBALS['wifidb_install'] == ""){die("You need to edit your daemon config file first in: [tools dir]/daemon/config.inc.php");}
require_once $GLOBALS['wifidb_install']."/lib/database.inc.php";
require_once $GLOBALS['wifidb_install']."/lib/config.inc.php";
require $GLOBALS['wifidb_install']."/lib/config.inc.php";
require_once $GLOBALS['wifidb_install']."/cp/admin/lib/administration.inc.php";
#####################
$conn							= 	$GLOBALS['conn'];
$db								= 	$GLOBALS['db'];
$db_st							= 	$GLOBALS['db_st'];
$wtable							=	$GLOBALS['wtable'];
$users_t						=	$GLOBALS['users_t'];
$gps_ext						=	$GLOBALS['gps_ext'];
$files							=	$GLOBALS['files'];
$user_logins_table				=	$GLOBALS['user_logins_table'];
$root							= 	$GLOBALS['root'];
$half_path						=	$GLOBALS['wifidb_install'];
$verbose						=	$GLOBALS['verbose'];
$screen_output					=	$GLOBALS['screen_output'];
$DBSTATS_time_interval_to_check	=	$GLOBALS['DBSTATS_time_interval_to_check'];
$date_format					=	"Y-m-d H:i:s.u";
$enable_mail_admin				=	0;
$This_is_me						=	getmypid();
$daemon_out						=	'/out/daemon/';
$kml_out						=	'/out/kmz/';
$gpx_out						=	'/out/gpx/';
$graph_out						=	'/out/graph/';
$upload							=	'/import/up/';
$date_format					=	"Y-m-d H:i:s.u";
$BAD_CLI_COLOR					=	$GLOBALS['BAD_DBS_COLOR'];
$GOOD_CLI_COLOR					=	$GLOBALS['GOOD_DBS_COLOR'];
$OTHER_CLI_COLOR				=	$GLOBALS['OTHER_DBS_COLOR'];
#####################
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
###########################
$pid_file						=	$GLOBALS['pid_file_loc'].'dbstatsd.pid';
if(!file_exists($GLOBALS['pid_file_loc'])){mkdir($GLOBALS['pid_file_loc']);}
fopen($pid_file, "w");
$fileappend = fopen($pid_file, "a");
$write_pid = fwrite($fileappend, "$This_is_me");
if(!$write_pid){die($GLOBALS['COLORS'][$BAD_CLI_COLOR]."Could not write pid file, thats not good... >:[".$GLOBALS['COLORS'][$OTHER_CLI_COLOR]);}
###########################
#wait for MySQL to become responsive to the script...
$sql_stat = mysql_stat($conn);
$sql_stat_7 = substr($sql_stat, 0, 6);
while($sql_stat_7 != "Uptime")
{
	$sql_stat = mysql_stat($conn);
	$sql_stat_7 = substr($sql_stat, 0, 6);
	echo $sql_stat_7."\r\n";
}
###########################
###########################
verbosed($GLOBALS['COLORS'][$GOOD_CLI_COLOR]."
WiFiDB 'Database Statistics Daemon'
Version: 1.0.0
- Daemon Start: 2009-12-07
- Last Daemon File Edit: 2010-04-13
( /tools/daemon/wifidbd.php -> daemon_stats() )
- By: Phillip Ferland ( pferland@randomintervals.com )
- http://www.randomintervals.com

PID: [ $This_is_me ]
".$GLOBALS['COLORS'][$OTHER_CLI_COLOR], 1, $screen_output, 1);
$database = new database();

while(TRUE)
{
	$date = date("Y-m-d G:i:s");
	$sql0 = "SELECT `id` FROM `$db`.`$wtable`";
	$result0 = mysql_query($sql0, $conn) or die(mysql_error($conn));
	if($total_aps = mysql_num_rows($result0))
	{verbosed($GLOBALS['COLORS'][$GOOD_CLI_COLOR]."Retreived Total AP count.".$GLOBALS['COLORS'][$OTHER_CLI_COLOR], $verbose, $screen_output, 1);}
	else{verbosed($GLOBALS['COLORS'][$BAD_CLI_COLOR]."Failed to Retreived Total AP count.".$GLOBALS['COLORS'][$OTHER_CLI_COLOR], $verbose, $screen_output, 1);}
	
#############

# NUM WEP
#############
	$sql0 = "SELECT `id` FROM `$db`.`$wtable` WHERE `encry` = 'WEP'";
	$result0 = mysql_query($sql0, $conn) or die(mysql_error($conn));
	if($wep_aps = mysql_num_rows($result0))
	{verbosed($GLOBALS['COLORS'][$GOOD_CLI_COLOR]."Retreived Total WEP AP count.".$GLOBALS['COLORS'][$OTHER_CLI_COLOR], $verbose, $screen_output, 1);}
	else{verbosed($GLOBALS['COLORS'][$BAD_CLI_COLOR]."Failed to Retreived Total WEP AP count.".$GLOBALS['COLORS'][$OTHER_CLI_COLOR], $verbose, $screen_output, 1);}
#############

# NUM WPA2
#############
	$sql0 = "SELECT `id` FROM `$db`.`$wtable` WHERE `auth` LIKE 'WPA2%'";
	$result0 = mysql_query($sql0, $conn) or die(mysql_error($conn));
	if($secure_aps = mysql_num_rows($result0))
	{verbosed($GLOBALS['COLORS'][$GOOD_CLI_COLOR]."Retreived Total Secure AP count.".$GLOBALS['COLORS'][$OTHER_CLI_COLOR], $verbose, $screen_output, 1);}
	else{verbosed($GLOBALS['COLORS'][$BAD_CLI_COLOR]."Failed to Retreived Secure Total AP count.".$GLOBALS['COLORS'][$OTHER_CLI_COLOR], $verbose, $screen_output, 1);}
#############

# NUM OPEN
#############
	$sql0 = "SELECT `id` FROM `$db`.`$wtable` WHERE `encry` = 'None'";
	$result0 = mysql_query($sql0, $conn) or die(mysql_error($conn));
	if($open_aps = mysql_num_rows($result0))
	{verbosed($GLOBALS['COLORS'][$GOOD_CLI_COLOR]."Retreived Total Open AP count.".$GLOBALS['COLORS'][$OTHER_CLI_COLOR], $verbose, $screen_output, 1);}
	else{verbosed($GLOBALS['COLORS'][$BAD_CLI_COLOR]."Failed to Retreived Open Total AP count.".$GLOBALS['COLORS'][$OTHER_CLI_COLOR], $verbose, $screen_output, 1);}
#############
	
# FILE SIZES
#############
	$files_sizes = array();
	$file_num = 0;
	$files_sizes_total = 0;
	
	$sql0 = "SELECT * FROM `$db`.`$files`";
	$result0 = mysql_query($sql0, $conn) or die(mysql_error($conn));
	if($result0){verbosed($GLOBALS['COLORS'][$GOOD_CLI_COLOR]."Retreived Files from the table.".$GLOBALS['COLORS'][$OTHER_CLI_COLOR], $verbose, $screen_output, 1);}
	else{verbosed($GLOBALS['COLORS'][$BAD_CLI_COLOR]."Failed to Retreive Files from the table.".mysql_error($conn).$GLOBALS['COLORS'][$OTHER_CLI_COLOR], $verbose, $screen_output, 1);}

	$files_uploaded = mysql_num_rows($result0);
	$import_path = $half_path.$upload;
#	echo $import_path."\r\n";
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
		$file_num++;
	}
	rsort($files_sizes);
	
	verbosed($GLOBALS['COLORS'][$GOOD_CLI_COLOR]."Sorted Files Array.".$GLOBALS['COLORS'][$OTHER_CLI_COLOR], $verbose, $screen_output, 1);
	
	if(@$files_sizes_total > 0)
	{
		$files_avg = $files_sizes_total/$file_num;
		$files_sizes_total = format_size($files_sizes_total , $round = 2);
		$file_max = format_size($files_sizes[0] , $round = 2);
		$file_min = format_size($files_sizes[$file_num-1] , $round = 2);
		$file_avg = format_size($files_avg , $round = 2);
	}else
	{
		$files_sizes[0] = 0;
		$files_avg = 0;
		
		$files_sizes_total = format_size($files_sizes_total , $round = 2);
		$file_max = format_size($files_sizes[0] , $round = 2);
		$file_min = $file_max;
		$file_avg = format_size($files_avg , $round = 2);
	}
	verbosed($GLOBALS['COLORS'][$GOOD_CLI_COLOR]."Calculated File sizes.".$GLOBALS['COLORS'][$OTHER_CLI_COLOR], $verbose, $screen_output, 1);
#############

# USER MOST APS
#############
	verbosed($GLOBALS['COLORS'][$GOOD_CLI_COLOR]."Starting Users Aps count.".$GLOBALS['COLORS'][$OTHER_CLI_COLOR], $verbose, $screen_output, 1);
	$user_s = array();
	$user_s_ = array();
	$sql10 = "SELECT `username` FROM `$db`.`$users_t`";
	$result10 = mysql_query($sql10, $conn);# or die(mysql_error($conn));
	while($users = mysql_fetch_array($result10))
	{
		$user_s[] = $users['username'];
	}
	
	$user_s = array_merge(array_unique($user_s));
	verbosed($GLOBALS['COLORS'][$GOOD_CLI_COLOR]."Gathered a Users Array.".$GLOBALS['COLORS'][$OTHER_CLI_COLOR], $verbose, $screen_output, 1);
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
		$user_s_[] = array($points, $user);
	}
	rsort($user_s_);
	verbosed($GLOBALS['COLORS'][$GOOD_CLI_COLOR]."Sorted Users APs Array.".$GLOBALS['COLORS'][$OTHER_CLI_COLOR], $verbose, $screen_output, 1);
	$user_s_a = array();
	foreach($user_s_ as $user)
	{
		$user_s_a[] = implode("|", $user);
	}
	$user_s_str = implode('-', $user_s_a);
	if(is_array($user_s_)){verbosed($GLOBALS['COLORS'][$GOOD_CLI_COLOR]."Finished Users AP count.".$GLOBALS['COLORS'][$OTHER_CLI_COLOR], $verbose, $screen_output, 1);}
	else{verbosed($GLOBALS['COLORS'][$BAD_CLI_COLOR]."Failed to Finish Total Users AP count.".$GLOBALS['COLORS'][$OTHER_CLI_COLOR], $verbose, $screen_output, 1);}
#############
	
# USER MOST GEO
#############
	verbosed($GLOBALS['COLORS'][$GOOD_CLI_COLOR]."Starting Users Geocaches.".$GLOBALS['COLORS'][$OTHER_CLI_COLOR], $verbose, $screen_output, 1);
	$users = array();
	$sql0 = "SELECT `username` FROM `$db`.`$user_logins_table` WHERE `username` NOT LIKE 'admin%'";
	$result0 = mysql_query($sql0, $conn);# or die(mysql_error($conn));
	while($users_array = mysql_fetch_array($result0))
	{
		$users[] = $users_array['username'];
	}
	$users = array_merge(array_unique($users));
	verbosed($GLOBALS['COLORS'][$GOOD_CLI_COLOR]."Grabbed Users Array.".$GLOBALS['COLORS'][$OTHER_CLI_COLOR], $verbose, $screen_output, 1);
	$geos = array();
	$num_priv_geo = 0;
	$num_pub_geo = 0;
	verbosed($GLOBALS['COLORS'][$GOOD_CLI_COLOR]."Grabbing Users geos count (private and public).".$GLOBALS['COLORS'][$OTHER_CLI_COLOR], $verbose, $screen_output, 1);
	foreach($users as $user)
	{
		if($database->table_exists("waypoints_".$user , $db))
		{
			$sql0 = "SELECT * FROM `$db`.`"."waypoints_".$user."`";
			$result0 = mysql_query($sql0, $conn);
			if($result0) # or die(mysql_error($conn));)
			{
				$geos[] = array(mysql_num_rows($result0), $user);
				while($users_geos = mysql_fetch_array($result0))
				{
					if($users_geos['share'])
					{$num_pub_geo++;}else{$num_priv_geo++;}
				}
			}else
			{
				echo date($date_format,time())." -> ";
				verbosed($GLOBALS['COLORS'][$BAD_CLI_COLOR]."Error -> ".mysql_error($conn).$GLOBALS['COLORS'][$OTHER_CLI_COLOR], $verbose, $screen_output, 1);
			}
		}
	}
	rsort($geos);
	verbosed($GLOBALS['COLORS'][$GOOD_CLI_COLOR]."Sorted Users Geocache Array.".$GLOBALS['COLORS'][$OTHER_CLI_COLOR], $verbose, $screen_output, 1);
	$geo_a = array();
	foreach($geos as $geo)
	{
		$geo_a[] = implode("|", $geo);
	}
	$geos = implode("-", $geo_a);
	if(is_array($geo_a)){verbosed($GLOBALS['COLORS'][$GOOD_CLI_COLOR]."Retreived Total Users Geocaches count.".$GLOBALS['COLORS'][$OTHER_CLI_COLOR], $verbose, $screen_output, 1);}
	else{verbosed($GLOBALS['COLORS'][$BAD_CLI_COLOR]."Failed to Retreived Total Users Geocaches count.".$GLOBALS['COLORS'][$OTHER_CLI_COLOR], $verbose, $screen_output, 1);}
#############

# DAEMON KMZ
#############
	verbosed($GLOBALS['COLORS'][$GOOD_CLI_COLOR]."Starting to calculate the Daemon KMZ folder size.".$GLOBALS['COLORS'][$OTHER_CLI_COLOR], $verbose, $screen_output, 1);
#	echo $daemon_out."\r\n";
	$daemon_dir = dirSize($daemon_out, 1);
	list($daemon_size, $daemon_num, $daemon_max, $daemon_min, $daemon_avg) = $daemon_dir;
	$daemon_size = format_size($daemon_size , 2);
	$daemon_max = format_size($daemon_max , 2);
	$daemon_min = format_size($daemon_min , 2);
	$daemon_avg = format_size($daemon_avg , 2);
	if($daemon_avg != "0kb"){verbosed($GLOBALS['COLORS'][$GOOD_CLI_COLOR]."Retreived Total Daemon KMZ file sizes.".$GLOBALS['COLORS'][$OTHER_CLI_COLOR], $verbose, $screen_output, 1);}
	else{verbosed($GLOBALS['COLORS'][$BAD_CLI_COLOR]."Failed to Retreived Total Daemon KMZ file sizes.".$GLOBALS['COLORS'][$OTHER_CLI_COLOR], $verbose, $screen_output, 1);}
#############
	
# GPX
#############
	verbosed($GLOBALS['COLORS'][$GOOD_CLI_COLOR]."Starting to calculate the GPX folder size.".$GLOBALS['COLORS'][$OTHER_CLI_COLOR], $verbose, $screen_output, 1);
#	echo $gpx_out."\r\n";
	$gpx_dir = dirSize($gpx_out, 1);
	list($gpx_size, $gpx_num, $gpx_max, $gpx_min, $gpx_avg) = $gpx_dir;
	$gpx_size = format_size($gpx_size , 2);
	$gpx_max = format_size($gpx_max , 2);
	$gpx_min = format_size($gpx_min , 2);
	$gpx_avg = format_size($gpx_avg , 2);
	if($gpx_avg != "0kb"){verbosed($GLOBALS['COLORS'][$GOOD_CLI_COLOR]."Retreived Total GPX file sizes.".$GLOBALS['COLORS'][$OTHER_CLI_COLOR], $verbose, $screen_output, 1);}
	else{verbosed($GLOBALS['COLORS'][$BAD_CLI_COLOR]."Failed to Retreived Total GPX file sizes.".$GLOBALS['COLORS'][$OTHER_CLI_COLOR], $verbose, $screen_output, 1);}
#############	
	
# GRAPHS
#############
	verbosed($GLOBALS['COLORS'][$GOOD_CLI_COLOR]."Starting to calculate the Graphs folder size.".$GLOBALS['COLORS'][$OTHER_CLI_COLOR], $verbose, $screen_output, 1);
#	echo $graph_out."\r\n";
	$graph_dir = dirSize($graph_out, 1);
	list($graph_size, $graph_num, $graph_max, $graph_min, $graph_avg) = $graph_dir;
	$graph_size = format_size($graph_size , $round = 2);
	$graph_max = format_size($graph_max , $round = 2);
	$graph_min = format_size($graph_min , $round = 2);
	$graph_avg = format_size($graph_avg , $round = 2);
	if($graph_avg != "0kb"){verbosed($GLOBALS['COLORS'][$GOOD_CLI_COLOR]."Retreived Total Graph file sizes.".$GLOBALS['COLORS'][$OTHER_CLI_COLOR], $verbose, $screen_output, 1);}
	else{verbosed($GLOBALS['COLORS'][$BAD_CLI_COLOR]."Failed to Retreived Total Graph file sizes.".$GLOBALS['COLORS'][$OTHER_CLI_COLOR], $verbose, $screen_output, 1);}
#############
	
# KMZ EXPORTED
#############
	verbosed($GLOBALS['COLORS'][$GOOD_CLI_COLOR]."Starting to calculate the Exports folder size.".$GLOBALS['COLORS'][$OTHER_CLI_COLOR], $verbose, $screen_output, 1);
#	echo $kml_out."\r\n";
	$kmz_dir = dirSize($kml_out, 1);
	list($kmz_size, $kmz_num, $kmz_max, $kmz_min, $kmz_avg) = $kmz_dir;
	$kmz_size = format_size($kmz_size , $round = 2);
	$kmz_max = format_size($kmz_max , $round = 2);
	$kmz_min = format_size($kmz_min , $round = 2);
	$kmz_avg = format_size($kmz_avg , $round = 2);
	if($kmz_avg != "0kb"){verbosed($GLOBALS['COLORS'][$GOOD_CLI_COLOR]."Retreived Total KMZ file sizes.".$GLOBALS['COLORS'][$OTHER_CLI_COLOR], $verbose, $screen_output, 1);}
	else{verbosed($GLOBALS['COLORS'][$BAD_CLI_COLOR]."Failed to Retreived Total KMZ file sizes.".$GLOBALS['COLORS'][$OTHER_CLI_COLOR], $verbose, $screen_output, 1);}
################
	
# AP WITH MOST GPS
################
	verbosed($GLOBALS['COLORS'][$GOOD_CLI_COLOR]."Starting APs with most GPS.".$GLOBALS['COLORS'][$OTHER_CLI_COLOR], $verbose, $screen_output, 1);
	$aps_gps_totals = array();
	$sql00 = "SELECT * FROM `$db`.`$wtable`";
	$result00 = mysql_query($sql00, $conn);# or die(mysql_error($conn));
	while($all_array = mysql_fetch_array($result00))
	{
		$ssid_pt_s = smart_quotes($all_array['ssid']);
		$ssid_pt_ss[0] = $ssid_pt_s;
		$ssid_pt_ss = str_split($ssid_pt_s,25); //split SSID in two at is 25th char.
		$ssid = $ssid_pt_ss[0];
		$table = $ssid.'-'.$all_array['mac'].'-'.$all_array['sectype'].'-'.$all_array['radio'].'-'.$all_array['chan'].$gps_ext;

		$sql01 = "SELECT `id` FROM `$db_st`.`$table`";
		$result01 = mysql_query($sql01, $conn);# or die(mysql_error($conn));;
		$num_gps = @mysql_num_rows($result01);
		$aps_gps_totals[] = array($num_gps , $all_array['ssid']);
	}
	verbosed($GLOBALS['COLORS'][$GOOD_CLI_COLOR]."Sorted APs GPS Array.".$GLOBALS['COLORS'][$OTHER_CLI_COLOR], $verbose, $screen_output, 1);
	rsort($aps_gps_totals);
	$ap_gps_totals_a = array();
	foreach($aps_gps_totals as $gps)
	{	
		$ap_gps_totals_a[] = implode('|', $gps);
	}
	$ap_gps_totals_s = implode('-', $ap_gps_totals_a);
	if(is_array($aps_gps_totals)){verbosed($GLOBALS['COLORS'][$GOOD_CLI_COLOR]."Retreived Total GPS cords for each AP.".$GLOBALS['COLORS'][$OTHER_CLI_COLOR], $verbose, $screen_output, 1);}
	else{verbosed($GLOBALS['COLORS'][$BAD_CLI_COLOR]."Failed to Retreived Total GPS cords for each AP.".$GLOBALS['COLORS'][$OTHER_CLI_COLOR], $verbose, $screen_output, 1);}
###############

# TOP SSID
###############
	verbosed($GLOBALS['COLORS'][$GOOD_CLI_COLOR]."Starting to Calculate the Top SSID's.".$GLOBALS['COLORS'][$OTHER_CLI_COLOR], $verbose, $screen_output, 1);
	$top_ssids = top_ssids();
	if(is_array($top_ssids)){verbosed($GLOBALS['COLORS'][$GOOD_CLI_COLOR]."Finished Calculating the Top SSID's.".$GLOBALS['COLORS'][$OTHER_CLI_COLOR], $verbose, $screen_output, 1);}
	else{verbosed($GLOBALS['COLORS'][$BAD_CLI_COLOR]."Failed Calculating the Top SSID's.".$GLOBALS['COLORS'][$OTHER_CLI_COLOR], $verbose, $screen_output, 1);}
	verbosed($GLOBALS['COLORS'][$GOOD_CLI_COLOR]."Starting to Implode the Top SSID's array into a string.".$GLOBALS['COLORS'][$OTHER_CLI_COLOR], $verbose, $screen_output, 1);
	$top_ssids_a = array();
	$count_ssids = 1;
	foreach($top_ssids as $ssid)
	{
		$top_ssids_a[] = implode("|", $ssid);
		$count_ssids++;
	}
	$top_ssids_s = implode('-', $top_ssids_a);
	if(is_array($top_ssids)){verbosed($GLOBALS['COLORS'][$GOOD_CLI_COLOR]."Finished Imploding of Top SSIDs. [ $count_ssids Unique SSIDs ] ".$GLOBALS['COLORS'][$OTHER_CLI_COLOR], $verbose, $screen_output, 1);}
	else{verbosed($GLOBALS['COLORS'][$BAD_CLI_COLOR]."Failed to Finish Imploding of Top SSIDs.".$GLOBALS['COLORS'][$OTHER_CLI_COLOR], $verbose, $screen_output, 1);}
################
	
# INSERT INTO DB
################
	$insert = "INSERT INTO `$db`.`DB_stats`( `id`, `timestamp`,  `file_num`,  `kmz_num`,  `graph_num`,  `graph_min`,  `graph_max`,  `graph_avg`,  `kmz_min`,  `kmz_max`,  `kmz_avg`,  `file_min`,  `file_max`,  `file_avg`,     `file_up_totals`, `kmz_total`, `graph_total`,  `total_aps`, `wep_aps`,   `open_aps`,  `secure_aps`,        `user`,    `ap_gps_totals`,    `top_ssids`,         `nuap`,  `geos`,  `num_priv_geo`,  `num_pub_geo`,  `gpx_size`,  `gpx_num`,  `gpx_max`,  `gpx_min`,  `gpx_avg`,  `daemon_size`,  `daemon_num`,  `daemon_max`,  `daemon_min`,  `daemon_avg`) 
									VALUES(    '',     '$date', '$file_num', '$kmz_num', '$graph_num', '$graph_min', '$graph_max', '$graph_avg', '$kmz_min', '$kmz_max', '$kmz_avg', '$file_min', '$file_max', '$file_avg', '$files_sizes_total', '$kmz_size', '$graph_size', '$total_aps', '$wep_aps', '$open_aps', '$secure_aps', '$user_s_str', '$ap_gps_totals_s', '$top_ssids_s', '$count_ssids', '$geos', '$num_priv_geo', '$num_pub_geo', '$gpx_size', '$gpx_num', '$gpx_max', '$gpx_min', '$gpx_avg', '$daemon_size', '$daemon_num', '$daemon_max', '$daemon_min', '$daemon_avg')";

	if(!mysql_query($insert, $conn))
	{
		mail_admin("There was an error inserting the Database Statistics data into the `DB_stats` table. :-(", $enable_mail_admin, 1);
		verbosed($GLOBALS['COLORS'][$BAD_CLI_COLOR]."Failed to Insert Data into The Database.".mysql_error($conn).$GLOBALS['COLORS'][$OTHER_CLI_COLOR], $verbose, $screen_output, 1);
	}else
	{
		verbosed($GLOBALS['COLORS'][$GOOD_CLI_COLOR]."Inserted Data into The Database.\r\n".$GLOBALS['COLORS'][$OTHER_CLI_COLOR], $verbose, $screen_output, 1);
	}
#############

verbosed($GLOBALS['COLORS'][$GOOD_CLI_COLOR]."Starting Users Statistics.".$GLOBALS['COLORS'][$OTHER_CLI_COLOR], $verbose, $screen_output, 1);
	foreach($users as $user)
	{
		verbosed($GLOBALS['COLORS'][$GOOD_CLI_COLOR]."Starting for user: $user.\r\n\t\t\tAP With Most GPS Points.".$GLOBALS['COLORS'][$OTHER_CLI_COLOR], $verbose, $screen_output, 1);
# MAX GPS FOR AP
#############
		$max = 0;
		$max_ssid = '';
		$sql = "SELECT * FROM `$db`.`$users_t` WHERE `username` LIKE '$user' ORDER BY `id` DESC";
		$user_query = mysql_query($sql, $conn) or die(mysql_error($conn));
		while($user_ap_l = mysql_fetch_array($user_query))
		{
			$pnts_exp = explode("-",$user_ap_l['points']);
			
			foreach($pnts_exp as $key=>$point)
			{
			#	echo $point."-";
				$pnt_exp = explode(":",$point);
				$pnt = explode(",",$pnt_exp[0]);
				$pnt_id = $pnt[1];
			#	echo '<BR>'.$pnt_id.'<BR>';
				$sql = "SELECT * FROM `$db`.`$wtable` WHERE `id` = '$pnt_id' LIMIT 1";
				$ap_qry = mysql_query($sql, $conn) or die(mysql_error($conn));
				$ap_ary = mysql_fetch_array($ap_qry);
				$id = $ap_ary['id'];
				$ssid_ptb_ = $ap_ary["ssid"];
				$ssids_ptb = str_split($ap_ary['ssid'],25);
				$ssid_ptb = smart_quotes($ssids_ptb[0]);
				$table		=	$ssid_ptb.'-'.$ap_ary["mac"].'-'.$ap_ary["sectype"].'-'.$ap_ary["radio"].'-'.$ap_ary['chan'];
				$table_gps	=	$table.$gps_ext;
				
				$sql = "SELECT * FROM `$db_st`.`$table_gps`";
				$ap_qry = mysql_query($sql, $conn);
				$rows = @mysql_num_rows($ap_qry);
				if($rows == 0){continue;}
#				echo $rows."<br>";
				if($rows > $max){$max = $rows; $largest = $ap_ary['ssid']."( ".$rows." )";}
			}
		}
		verbosed($GLOBALS['COLORS'][$GOOD_CLI_COLOR]."Finished AP With Most GPS Points.".$GLOBALS['COLORS'][$OTHER_CLI_COLOR], $verbose, $screen_output, 1);
#############
		verbosed($GLOBALS['COLORS'][$GOOD_CLI_COLOR]."Finding The Newest AP.".$GLOBALS['COLORS'][$OTHER_CLI_COLOR], $verbose, $screen_output, 1);
# NEWEST AP
#############
		$sql = "SELECT * FROM `$db`.`$users_t` WHERE `username` LIKE '$user' ORDER BY `id` DESC LIMIT 1";
		$user_query = mysql_query($sql, $conn) or die(mysql_error($conn));
		$user_ap_l = mysql_fetch_array($user_query);
	#	echo $user_ap_l['points']."<BR>";
		$pnts_exp = explode("-",$user_ap_l['points']);
		$pnts_exp = array_reverse($pnts_exp);
		foreach($pnts_exp as $key => $points_ex)
		{
#				echo $points_ex." - ";
			$pnt_e = explode(",",$points_ex);
		#	echo $pnt_e[0]." - ";
			if($pnt_e[0] == "1"){continue;}
			$pnt = explode(":",$pnt_e[1]);
			$pnt_id = $pnt[0];
			$sql = "SELECT `ssid` FROM `$db`.`$wtable` WHERE `id` = '$pnt_id' LIMIT 1";
	#		echo $sql."<BR>";
			$ap_qry = mysql_query($sql, $conn) or die(mysql_error($conn));
			$ap_ary = mysql_fetch_array($ap_qry);
			$newest = $ap_ary["ssid"]." ( $pnt_id )";
#				echo $new_ssid."<BR>";
			break;
		}
		$insert_user = "INSERT INTO `$db`.`stats_$user` (`id`, `newest`, `largest`) VALUES ('', '$newest', '$largest')";
		if(!mysql_query($insert_user, $conn))
		{
			mail_admin("There was an error inserting the Database Statistics data. :-(\r\n\r\n".mysql_error($conn), $enable_mail_admin, 1);
			verbosed($GLOBALS['COLORS'][$BAD_CLI_COLOR]."Failed to Insert Data into The Database.".mysql_error($conn).$GLOBALS['COLORS'][$OTHER_CLI_COLOR], $verbose, $screen_output, 1);
		}else
		{
			verbosed($GLOBALS['COLORS'][$GOOD_CLI_COLOR]."Inserted Statistics Data for User: $user.".$GLOBALS['COLORS'][$OTHER_CLI_COLOR], $verbose, $screen_output, 1);
		}
		verbosed($GLOBALS['COLORS'][$GOOD_CLI_COLOR]."Finished for user: $user\r\n.".$GLOBALS['COLORS'][$OTHER_CLI_COLOR], $verbose, $screen_output, 1);
	}
################

# SLEEP FOR DEFINED TIME
#############
	verbosed($GLOBALS['COLORS'][$GOOD_CLI_COLOR]."Going to sleep for ".($DBSTATS_time_interval_to_check/60)." Minutes.\r\n\r\n".$GLOBALS['COLORS'][$OTHER_CLI_COLOR], $verbose, $screen_output, 1);
	sleep($DBSTATS_time_interval_to_check);
}
?>