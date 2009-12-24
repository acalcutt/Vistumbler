<?php
include('../../lib/database.inc.php');
pageheader("Upgrade Page");
?>
<link rel="stylesheet" href="../../themes/wifidb/styles.css">
<?php
include($half_path.'lib/config.inc.php');
?>
<h3>If one of the steps shows "Duplicate column name '***'," you can ignore this error.</h3>
<table border="1">
<tr class="style4"><TH colspan="2">Upgrade DB for 0.16 Build 1 / 2 - 2.1 / 3 - 3.1 R2 <b>--></b> 0.16 Build 4</TH>
<tr class="style4"><th colspan="2">Upgrade Database Tables</th></tr>
<tr class="style4"><th>Status</th><th>Step of Upgrade</th></tr>
<?php
$ENG = "InnoDB";
$date = date("Y-m-d");

$root_sql_user	=	addslashes(strip_tags($_POST['root_sql_user']));
$root_sql_pwd	=	addslashes(strip_tags($_POST['root_sql_pwd']));
$sqlhost		=	addslashes(strip_tags($_POST['sqlhost']));
$sqlu			=	addslashes(strip_tags($_POST['sqlu']));
$sqlp			=	addslashes(strip_tags($_POST['sqlp']));
$wifi			=	addslashes(strip_tags($_POST['wifi']));
$wifi_st		=	addslashes(strip_tags($_POST['wifist']));
$theme			=	addslashes(strip_tags($_POST['theme']));
$username		=	addslashes(strip_tags($_POST['wdb_admn_username']));
$password		=	addslashes(strip_tags($_POST['wdb_admn_passwrd']));
$email			=	addslashes(strip_tags($_POST['wdb_admn_emailadrs']));
if(!@isset($timeout)){$timeout		=   "(86400 * 365)";}

if(isset($_POST['daemon']))
{
	$daemon		= addslashes(strip_tags($_POST['daemon']));
	$toolsdir	= addslashes(strip_tags($_POST['toolsdir']));
	$httpduser	= addslashes(strip_tags($_POST['httpduser']));
	$httpdgrp	= addslashes(strip_tags($_POST['httpdgrp']));
}else
{
	$daemon 	= FALSE;
	$toolsdir	= "NO PATH";
	$httpduser	= "NOT SET";
	$httpdgrp	= "NOT SET";
}

if($daemon == TRUE)
{
	$daemon = 1;
}else
{
	$daemon = 0;
}

if ($sqlhost !== 'localhost' or $sqlhost !== "127.0.0.1")
{$phphost = 'localhost';}
else{$phphost	=	$_POST['phphost'];}

#Connect with Root priv
$conn = mysql_connect($sqlhost, $root_sql_user, $root_sql_pwd) or die("</table>Could not create MySQL Connection".footer($_SERVER['SCRIPT_FILENAME']));


$sqls =	"REVOKE GRANT OPTION ON  `$wifi` . * FROM  '$sqlu'@'$phphost'";
$GR_US_WF_Re = mysql_query($sqls, $conn);
if($GR_US_WF_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>Alter user: $sqlu @ $phphost for $wifi</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Alter user: $sqlu @ $phphost for $wifi;<br>".mysql_error($conn)."</td></tr>";
}


$sqls =	"REVOKE ALL PRIVILEGES ON  `$wifi` . * FROM  '$sqlu'@'$phphost'";
$GR_US_WF_Re = mysql_query($sqls, $conn);
if($GR_US_WF_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>Alter user: $sqlu @ $phphost for $wifi</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Alter user: $sqlu @ $phphost for $wifi;<br>".mysql_error($conn)."</td></tr>";
}


$sqls =	"GRANT SELECT , 
INSERT ,
UPDATE ,
DELETE ,
CREATE ,
DROP ,
REFERENCES ,
INDEX ,
ALTER ,
LOCK TABLES ,
SHOW VIEW ON  `$wifi` . * TO  '$sqlu'@'$phphost'";
$GR_US_WF_Re = mysql_query($sqls, $conn) or die(mysql_error($conn));
if($GR_US_WF_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>Alter user: $sqlu @ $phphost for $wifi</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Alter user: $sqlu @ $phphost for $wifi;<br>".mysql_error($conn)."</td></tr>";
}


$sqls =	"REVOKE GRANT OPTION ON  `$wifi_st` . * FROM  '$sqlu'@'$phphost'";
$GR_US_WF_Re = mysql_query($sqls, $conn);
if($GR_US_WF_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>Alter user: $sqlu @ $phphost for $wifi_st</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Alter user: $sqlu @ $phphost for $wifi_st;<br>".mysql_error($conn)."</td></tr>";
}


$sqls =	"REVOKE ALL PRIVILEGES ON  `$wifi_st` . * FROM  '$sqlu'@'$phphost'";
$GR_US_WF_Re = mysql_query($sqls, $conn);
if($GR_US_WF_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>Alter user: $sqlu @ $phphost for $wifi_st</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Alter user: $sqlu @ $phphost for $wifi_st;<br>".mysql_error($conn)."</td></tr>";
}


$sqls =	"GRANT SELECT , 
INSERT ,
UPDATE ,
DELETE ,
CREATE ,
DROP ,
REFERENCES ,
INDEX ,
ALTER ,
LOCK TABLES ,
SHOW VIEW ON  `$wifi_st` . * TO  '$sqlu'@'$phphost'";
$GR_US_WF_Re = mysql_query($sqls, $conn);
if($GR_US_WF_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>Alter user: $sqlu @ $phphost for $wifi_st</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Alter user: $sqlu @ $phphost for $wifi_st;<br>".mysql_error($conn)."</td></tr>";
}


$sql = "TRUNCATE TABLE `$wifi`.`links`";
$drop = mysql_query($sql, $conn);
if($drop)
{echo "<tr class=\"good\"><td>Success..........</td><td>EMPTY TABLE `links`</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>EMPTY TABLE `links`;<br>".mysql_error($conn)."</td></tr>";}


$sql1 = "INSERT INTO `$wifi`.`links` (`ID`, `links`) VALUES"
		."(1, '<a class=\"links\" href=\"/$root/\">Main Page</a>'),"
		."(2, '<a class=\"links\" href=\"/$root/all.php?sort=SSID&ord=ASC&from=0&to=100\">View All APs</a>'),"
		."(3, '<a class=\"links\" href=\"/$root/import/\">Import</a>'),"
		."(4, '<a class=\"links\" href=\"/$root/opt/export.php?func=index\">Export</a>'),"
		."(6, '<a class=\"links\" href=\"/$root/opt/userstats.php?func=allusers\">View All Users</a>'),"
		."(5, '<a class=\"links\" href=\"/$root/opt/search.php\">Search</a>'),"
		."(7, '<a class=\"links\" href=\"/$root/ver.php\">WiFiDB Version</a>'),"
		."(8, '<a class=\"links\" href=\"/$root/announce.php?func=allusers\">Announcements</a>')";
$insert = mysql_query($sql, $conn);
if($insert)
{echo "<tr class=\"good\"><td>Success..........</td><td>Insert new links into `$wifi`.`links`;</td></tr> ";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Insert new links into `$wifi`.`links`<br>".mysql_error($conn)."</td></tr>";
}

$sql1 = "CREATE TABLE IF NOT EXISTS `$wifi`.`files` (
		`id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY ,
		`file` varchar(255) NOT NULL ,
		`date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,
		`size` VARCHAR( 12 ) NOT NULL ,
		`aps` INT NOT NULL ,
		`gps` INT NOT NULL ,
		`hash` VARCHAR( 255 ) NOT NULL,
		`user` VARCHAR( 255 ) NOT NULL,
		`title` VARCHAR( 255 ) NOT NULL,
		`notes` TEXT NOT NULL,
		`user_row` INT NOT NULL ,
		UNIQUE ( `file` )
		) ENGINE = InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1";
$insert = mysql_query($sql1, $conn);
if($insert)
{echo "<tr class=\"good\"><td>Success..........</td><td>Create Files table `$wifi`.`files`;</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Create Files table `$wifi`.`files`;<br>".mysql_error($conn)."</td></tr>";
}


$sql1 = "CREATE TABLE IF NOT EXISTS `$wifi`.`files_tmp` (
		`id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY ,
		`file` VARCHAR( 255 ) NOT NULL ,
		`user` VARCHAR ( 255 ) NOT NULL,
		`notes` TEXT NOT NULL,
		`title` VARCHAR ( 255 ) NOT NULL,
		`size` VARCHAR( 12 ) NOT NULL ,
		`date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,
		`hash` VARCHAR( 255 ) NOT NULL,
		`importing` BOOL NOT NULL,
		`ap` VARCHAR ( 32 ) NOT NULL,
		`tot` VARCHAR ( 128 ) NOT NULL,
		`file_row` INT ( 255 ) NOT NULL,
		UNIQUE ( `file` )	
		) ENGINE = InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1";
$insert = mysql_query($sql1, $conn);
if($insert)
{echo "<tr class=\"good\"><td>Success..........</td><td>Create tmp File table `$wifi`.`files_tmp`;</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Create tmp Files table `$wifi`.`files_tmp`;<br>".mysql_error($conn)."</td></tr>";
}

$sql1 = "ALTER TABLE `$wifi`.`$wtable` CHANGE `ssid` `ssid` VARCHAR( 32 ), CHANGE `chan` `chan` VARCHAR( 3 ), CHANGE `id` `id` INT( 255 ) NOT NULL AUTO_INCREMENT";
$insert = mysql_query($sql1, $conn);
if($insert)
{echo "<tr class=\"good\"><td>Success..........</td><td>Altered `$wifi`.`users` to change aps, gps, username, notes, and title fields;</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Alter `$wifi`.`users` to change SSID (32 char max), Chan(3 char max), ID (numeric 255 not null, auto increment) fields;<br>".mysql_error($conn)."</td></tr>";
}



####	ALTER USERS TABLE
$sql1 = "ALTER TABLE `$wifi`.`users` ADD `hash` VARCHAR ( 255 ) NOT NULL";
$insert = mysql_query($sql1, $conn);
if($insert)
{echo "<tr class=\"good\"><td>Success..........</td><td>Altered `$wifi`.`users` to add file hash field;</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Alter `$wifi`.`users` to add file hash field;<br>".mysql_error($conn)."</td></tr>";
}

$sql1 = "ALTER TABLE `$wifi`.`users` ADD `aps` INT NOT NULL, 
CHANGE `username` `username` VARCHAR( 255 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL ,
CHANGE `title` `title` VARCHAR( 255 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL";
$insert = mysql_query($sql1, $conn);
if($insert)
{echo "<tr class=\"good\"><td>Success..........</td><td>Altered `$wifi`.`users` to add aps field;</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Alter `$wifi`.`users` to add aps field;<br>".mysql_error($conn)."</td></tr>";
}

$sql1 = "ALTER TABLE `$wifi`.`users` ADD `gps` INT NOT NULL";
$insert = mysql_query($sql1, $conn);
if($insert)
{echo "<tr class=\"good\"><td>Success..........</td><td>Altered `$wifi`.`users` to add gps field;</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Alter `$wifi`.`users` to add gps field;<br>".mysql_error($conn)."</td></tr>";
}

$sql1 = "ALTER TABLE `$wifi`.`users` CHANGE `title` `title` VARCHAR ( 255 ) NOT NULL";
$insert = mysql_query($sql1, $conn);
if($insert)
{echo "<tr class=\"good\"><td>Success..........</td><td>Altered `$wifi`.`users` to change title field to 255 chars;</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Alter `$wifi`.`users` to change title field to 255 chars;<br>".mysql_error($conn)."</td></tr>";
}

$sql1 = "ALTER TABLE `$wifi`.`users` ADD `notes` TEXT NOT NULL";
$insert = mysql_query($sql1, $conn);
if($insert)
{echo "<tr class=\"good\"><td>Success..........</td><td>Altered `$wifi`.`users` to add notes field;</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Alter `$wifi`.`users` to add notes field;<br>".mysql_error($conn)."</td></tr>";
}

$sql1 = "ALTER TABLE `$wifi`.`users` CHANGE `username` `username` VARCHAR ( 255 ) NOT NULL";
$insert = mysql_query($sql1, $conn);
if($insert)
{echo "<tr class=\"good\"><td>Success..........</td><td>Altered `$wifi`.`users` `username` field to VARCHAR( 255 );</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Alter `$wifi`.`users` `username` field to VARCHAR( 255 );<br>".mysql_error($conn)."</td></tr>";
}

$sql1 = "RENAME TABLE `$wifi`.`users` TO `$wifi`.`users_imports`";
$insert = mysql_query($sql1, $conn);
if($insert)
{echo "<tr class=\"good\"><td>Success..........</td><td>Renamed table `$wifi`.`users` to `users_imports`;</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Renamed table `$wifi`.`users` to `users_imports`;<br>".mysql_error($conn)."</td></tr>";
}



####	ALTER FILES TABLE WITH NEW FIELDS
$sql1 = "ALTER TABLE `$wifi`.`files` CHANGE `size` `size` VARCHAR( 14 )";
$insert = mysql_query($sql1, $conn);
if($insert)
{echo "<tr class=\"good\"><td>Success..........</td><td>Changed `$wifi`.`files` `size` field, from float to varchar(14);</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Change `$wifi`.`files` `size` field, from float to varchar(14);<br>".mysql_error($conn)."</td></tr>";
}
$sql1 = "ALTER TABLE `$wifi`.`files` CHANGE `file` `file` VARCHAR( 255 )";
$insert = mysql_query($sql1, $conn);
if($insert)
{echo "<tr class=\"good\"><td>Success..........</td><td>Changed `$wifi`.`files` `file` VARCHAR( 255 );</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Change `$wifi`.`files` `file` VARCHAR( 255 );<br>".mysql_error($conn)."</td></tr>";
}
$sql1 = "ALTER TABLE `$wifi`.`files` CHANGE `title` `title` VARCHAR ( 255 ) NOT NULL, CHARSET=utf8";
$insert = mysql_query($sql1, $conn);
if($insert)
{echo "<tr class=\"good\"><td>Success..........</td><td>Changed field (Title) to `$wifi`.`files`;</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Change field (Title) to `$wifi`.`files`;<br>".mysql_error($conn)."</td></tr>";
}
$sql1 = "ALTER TABLE `$wifi`.`files` CHANGE `user` `user` VARCHAR ( 255 ) NOT NULL, CHARSET=utf8";
$insert = mysql_query($sql1, $conn);
if($insert)
{echo "<tr class=\"good\"><td>Success..........</td><td>Added field (user) to `$wifi`.`files`;</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Added field (user) to `$wifi`.`files`;<br>".mysql_error($conn)."</td></tr>";
}
$sql1 = "ALTER TABLE `$wifi`.`files` CHANGE `notes` `notes` TEXT NOT NULL, CHARSET=utf8";
$insert = mysql_query($sql1, $conn);
if($insert)
{echo "<tr class=\"good\"><td>Success..........</td><td>Changed field (notes) to `$wifi`.`files`;</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Change field (notes) to `$wifi`.`files`;<br>".mysql_error($conn)."</td></tr>";
}

$sql1 = "ALTER TABLE `$wifi`.`files_tmp` CHANGE `title` `title` VARCHAR ( 255 ) NOT NULL, CHARSET=utf8";
$insert = mysql_query($sql1, $conn);
if($insert)
{echo "<tr class=\"good\"><td>Success..........</td><td>Changed field (Title) to `$wifi`.`files_tmp`;</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Change field (Title) to `$wifi`.`files_tmp`;<br>".mysql_error($conn)."</td></tr>";
}




####	ALTER FILES_TMP TABLE WITH NEW FIELDS
$sql1 = "ALTER TABLE `$wifi`.`files_tmp` CHANGE `size` `size` VARCHAR( 12 ), CHARSET=utf8";
$insert = mysql_query($sql1, $conn);
if($insert)
{echo "<tr class=\"good\"><td>Success..........</td><td>Altered `$wifi`.`files_tmp` `size` fields, from float to varchar(12);</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Altered `$wifi`.`files_tmp` `size` fields, from float to varchar(12);<br>".mysql_error($conn)."</td></tr>";
}
$sql1 =  "ALTER TABLE `$wifi`.`files_tmp` CHANGE `file` `file` VARCHAR( 255 ), CHARSET=utf8";
$insert = mysql_query($sql1, $conn);
if($insert)
{echo "<tr class=\"good\"><td>Success..........</td><td>Altered `$wifi`.`files_tmp` CHANGE `file` VARCHAR( 255 );</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Altered `$wifi`.`files_tmp` CHANGE `file` VARCHAR( 255 );<br>".mysql_error($conn)."</td></tr>";
}

$sql1 =  "ALTER TABLE `$wifi`.`settings` CHANGE `size` `size` VARCHAR( 255 ), CHARSET=utf8";
$insert = mysql_query($sql1, $conn);
if($insert)
{echo "<tr class=\"good\"><td>Success..........</td><td>Altered `$wifi`.`settings` CHANGE `size` VARCHAR( 255 );</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Altered `$wifi`.`settings` CHANGE `size` VARCHAR( 255 );<br>".mysql_error($conn)."</td></tr>";
}

$sql1 =  "ALTER TABLE `$wifi`.`settings` CHANGE `size` `size` VARCHAR( 255 ), CHARSET=utf8";
$insert = mysql_query($sql1, $conn);
if($insert)
{echo "<tr class=\"good\"><td>Success..........</td><td>Altered `$wifi`.`settings` CHANGE `size` VARCHAR( 255 );</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Altered `$wifi`.`settings` CHANGE `size` VARCHAR( 255 );<br>".mysql_error($conn)."</td></tr>";
}

$sql1 =  "INSERT INTO `$wifi`.`settings` ( `id`, `table`, `size`) VALUES ( '1', 'files', '')";
$insert = mysql_query($sql1, $conn);
if($insert)
{echo "<tr class=\"good\"><td>Success..........</td><td>INSERT wifidb time holder INTO <b>`$wifi`</b>.`settings`<br></td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>INSERT wifidb time holder INTO <b>`$wifi`</b>.`settings`<br>".mysql_error($conn)."</td></tr>";
}

$sql1 =  "INSERT INTO `$wifi`.`settings` ( `id`, `table`, `size`) VALUES ( '2', 'theme', 'wifidb')";
$insert = mysql_query($sql1, $conn);
if($insert)
{echo "<tr class=\"good\"><td>Success..........</td><td>INSERT Theme setting INTO <b>`$wifi`</b>.`settings`</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>INSERT Theme setting INTO <b>`$wifi`</b>.`settings`<br>".mysql_error($conn)."</td></tr>";
}
#############################################
$sql = "CREATE TABLE IF NOT EXISTS `share_waypoints` (
  `id` int(255) NOT NULL auto_increment,
  `author` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `gcid` varchar(255) NOT NULL,
  `notes` text NOT NULL,
  `cat` set('home','family','medical','police','fire','fastfood','finefood','gas','geocache','think of more...') NOT NULL,
  `type` varchar(255) NOT NULL,
  `diff` varchar(4) NOT NULL,
  `terain` varchar(4) NOT NULL,
  `lat` varchar(255) NOT NULL,
  `long` varchar(255) NOT NULL,
  `link` varchar(255) NOT NULL,
  `c_date` datetime NOT NULL,
  `u_date` datetime NOT NULL,
  `pvt_id` int(255) NOT NULL,
  `shared_by` varchar(255) NOT NULL,
  UNIQUE KEY `id` (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=1";
$insert = mysql_query($sql1, $conn) or die(mysql_error());
if($insert)
{echo "<tr class=\"good\"><td>Success..........</td><td>Create Shared Geocaches table <b>`$wifi`</b>.`share_waypoints`;</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>To create Shared Geocaches table <b>`$wifi`</b>.`share_waypoints`;</td></tr> ";
}
############################################
$sql1 = "CREATE TABLE IF NOT EXISTS `daemon_perf_mon` (
  `id` int(255) NOT NULL auto_increment,
  `timestamp` datetime NOT NULL,
  `pid` int(255) NOT NULL,
  `uptime` varchar(255) NOT NULL,
  `CMD` varchar(255) NOT NULL,
  `mem` varchar(7) NOT NULL,
  `mesg` varchar(255) NOT NULL,
  UNIQUE KEY `timestamp` (`timestamp`),
  KEY `id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1";
$insert = mysql_query($sql1, $conn) or die(mysql_error());
if($insert)
{echo "<tr class=\"good\"><td>Success..........</td><td>Create Daemon Performance table <b>`$wifi`</b>.`daemon_perf_mon`;</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>To create Daemon Performance table <b>`$wifi`</b>.`daemon_perf_mon`;</td></tr> ";
}

##########################################
$sql1 = "CREATE TABLE `$wifi`.`DB_stats` (
`id` INT( 255 ) NOT NULL ,
`timestamp` VARCHAR( 60 ) NOT NULL ,
`graph_min` VARCHAR( 255 ) NOT NULL ,
`graph_max` VARCHAR( 255 ) NOT NULL ,
`graph_avg` VARCHAR( 255 ) NOT NULL ,
`kmz_min` VARCHAR( 255 ) NOT NULL ,
`kmz_max` VARCHAR( 255 ) NOT NULL ,
`kmz_avg` VARCHAR( 255 ) NOT NULL ,
`file_min` VARCHAR( 255 ) NOT NULL ,
`file_max` VARCHAR( 255 ) NOT NULL ,
`file_avg` VARCHAR( 255 ) NOT NULL ,
`total_aps` VARCHAR( 255 ) NOT NULL ,
`wep_aps` VARCHAR( 255 ) NOT NULL ,
`open_aps` VARCHAR( 255 ) NOT NULL ,
`secure_aps` VARCHAR( 255 ) NOT NULL ,
`user` BLOB NOT NULL ,
`ap_gps_totals` BLOB NOT NULL ,
`top_ssids` BLOB NOT NULL ,
`geos` BLOB NOT NULL ,
INDEX ( `id` ) ,
UNIQUE (`timestamp`)
) ENGINE = InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1";
$insert = mysql_query($sql1, $conn) or die(mysql_error());
if($insert)
{echo "<tr class=\"good\"><td>Success..........</td><td>Create DB stats table <b>`$wifi`</b>.`DB_stats`;</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>To create DB stats table <b>`$wifi`</b>.`DB_stats`;</td></tr> ";
}
##############
$sql1 = "CREATE TABLE IF NOT EXISTS `user_info` (
  `id` int(255) NOT NULL auto_increment,
  `username` varchar(32) NOT NULL,
  `password` varchar(32) NOT NULL,
  `help` varchar(255) NOT NULL,
  `uid` varchar(32) NOT NULL,
  `disabled` tinyint(1) NOT NULL,
  `locked` tinyint(1) NOT NULL,
  `login_fails` int(255) NOT NULL,
  `member` text NOT NULL,
  `last_login` datetime NOT NULL,
  `email` varchar(255) NOT NULL,
  `h_email` tinyint(1) NOT NULL,
  `join_date` datetime NOT NULL,
  `friends` text NOT NULL,
  `foes` text NOT NULL,
  `website` varchar(255) NOT NULL,
  `Vis_ver` varchar(255) NOT NULL,
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `uid` (`uid`),
  UNIQUE KEY `email` (`email`),
  KEY `id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1";
$insert = mysql_query($sql1, $conn) or die(mysql_error());
if($insert)
{echo "<tr class=\"good\"><td>Success..........</td><td>Create User Login Table table <b>`$wifi`</b>.`user_info`;</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>To create User Login Table table <b>`$wifi`</b>.`user_info`;</td></tr> ";
}
	#========================================================================================================================#
	#										Create WiFiDB Administrator User										   	     #
	#========================================================================================================================#
require("../../lib/security.inc.php");
$sec = new security();
$insert = $sec->create_user($username, $password, $email);
switch($create)
{
	case 1:
		echo "<tr class=\"good\"><td>Success..........</td><td>Create DB stats table <b>`$wifi`</b>.`DB_stats`;</td></tr>";
	break;
	
	case is_array($create):
		list($er, $msg) = $create;
		switch($er)
		{
			case "create_wpt":
				echo '<tr class="bad"><td>Failure..........</td><td>There was an error in Creating the Geocache table.<BR>This is a serious error, contact Phil on the <a href="http://forum.techidiots.net/">forums</a><br>MySQL Error Message: '.$msg."<br><h1>D'oh!</h1></td></tr>";
			break;
			
			case "dup_u":
				echo '<tr class="bad"><td>Failure..........</td><td>To create Wdb Admin User. :-(<br>MySQl Error: '.$msg.'<br><h1>Do`h!</h1></td></tr>';
			break;
		}
	break;
}


	#========================================================================================================================#
	#											Update the Config.inc.php file										   	     #
	#========================================================================================================================#
?>
<tr class="style4"><TH colspan="2">Config.inc.php File Creation</th></tr>
<tr class="style4"><th>Status</th><th>Step of Upgrade</th></tr>
<?php
$file_ext = 'config.inc.php';
$filename = '../lib/'.$file_ext;
$filewrite = fopen($filename, "w");
$fileappend = fopen($filename, "a");

if($filewrite)
{echo "<tr class=\"good\"><td>Success..........</td><td>Created Config file</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Creating Config file</td></tr>";}


#Add last edit date and globals
$CR_CF_FL_Re = fwrite($fileappend, "<?php\r\nglobal $"."header, $"."ads, $"."tracker, $"."hosturl;
global $"."WiFiDB_LNZ_User, $"."apache_grp, $"."div, $"."conn, $"."wifidb_tools, $"."daemon, $"."root, $"."users_t, $"."user_logins_table, $"."files, $"."files_tmp, $"."annunc, $"."annunc_comm;
global $"."console_refresh, $"."console_scroll, $"."console_last5, $"."console_lines, $"."console_log;
global $"."default_theme, $"."default_refresh, $"."default_dst, $"."default_timezone, $"."timeout, $"."bypass_check;\r\n
\r\n$"."lastedit	=	'$date';\r\n
\r\n#----------General Settings------------#
$"."bypass_check	=	1;
$"."wifidb_tools	=	'$toolsdir';
$"."timezn			=	'$Local_tz';
$"."root			=	'$root';
$"."hosturl		=	'$hosturl';");

if($CR_CF_FL_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>Add Global variables and general variables values.</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Add Global variables and general variables values.</td></tr>";}


#add default daemon values
$AD_CF_DG_Re = fwrite($fileappend, "#---------------- Daemon Info ----------------#
$"."daemon				=	$daemon;
$"."debug				=	0;
$"."log_level			=	0;
$"."log_interval		=	0;
$"."WiFiDB_LNZ_User 	=	'$httpduser';
$"."apache_grp			=	'$httpdgrp';");
if($AD_CF_DG_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>Add default daemon values</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Add default daemon values</td></tr>";}


#add default theme values
$AD_CF_DG_Re = fwrite($fileappend, "#-------------Themes Settings--------------#
$"."default_theme	= '$theme';
$"."default_refresh 	= 15;
$"."default_timezone	= 0;
$"."default_dst		= 0;
$"."timeout		= $timeout; #(86400 [seconds in a day] * 365 [days in a year]) \r\n\r\n");

if($AD_CF_DG_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>Add default theme values</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Add default theme values</td></tr>";}


$AD_CF_DG_Re = fwrite($fileappend, "#-------------Console Viewer Settings--------------#
$"."console_refresh	= 15;
$"."console_scroll	= 1;
$"."console_last5	= 1;
$"."console_lines	= 10;
$"."console_log		= '/var/log/wifidb';\r\n\r\n");

if($AD_CF_DG_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>Add default Console values</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Add default Console values</td></tr>";}

#add default debug values
$AD_CF_DG_Re = fwrite($fileappend, "#---------------- Debug Info ----------------#\r\n"
									."$"."rebuild	=	0;\r\n"
									."$"."bench		=	0;\r\n\r\n");

if($AD_CF_DG_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>Add default debug values</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Add default debug values</td></tr>";}

#add Table names
$AD_CF_UR_Re = fwrite($fileappend, "#---------------- Tables ----------------#
$"."settings_tb		=	'settings';
$"."users_t			=	'users_imports';
$"."links				=	'links';
$"."wtable				=	'wifi0';
$"."user_logins_table	=	'user_info';
$"."share_cache		=	'share_waypoints';
$"."files				=	'files';
$"."files_tmp			=	'files_tmp';
$"."annunc				=	'annunc';
$"."annunc_comm		=	'annunc_comm';
$"."gps_ext			=	'_GPS';
$"."sep				=	'-';");

if($AD_CF_UR_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>Add Table variable values</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Adding Table variable values</td></tr>";}



#add sql host info
$AD_CF_DB_Re = fwrite($fileappend, "#---------------- DataBases ----------------#\r\n"
									."$"."db		=	'$wifi';\r\n"
									."$"."db_st		=	'$wifi_st';\r\n\r\n");
if($AD_CF_DB_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>Add DataBase names</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Adding DataBase names</td></tr>";}

#add sql info
$AD_CF_SH_Re = fwrite($fileappend, "#---------------- SQL Info ----------------#\r\n"
									."$"."host		=	'$sqlhost';\r\n"
									."$"."db_user	=	'$sqlu';\r\n"
									."$"."db_pwd	=	'$sqlp';\r\n"
									."$"."conn		=	 mysql_pconnect($"."host, $"."db_user, $"."db_pwd) or die(\"Unable to connect to SQL server: $"."host\");\r\n\r\n");

if($AD_CF_SH_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>Add SQL Info</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Adding SQL Info</td></tr>";}


$AD_CF_KM_Re = fwrite($fileappend, "#---------------- Export Info ----------------#\r\n"
							."$"."open_loc		=	'http://vistumbler.sourceforge.net/images/program-images/open.png';\r\n"
							."$"."WEP_loc		=	'http://vistumbler.sourceforge.net/images/program-images/secure-wep.png';\r\n"
							."$"."WPA_loc		=	'http://vistumbler.sourceforge.net/images/program-images/secure.png';\r\n"
							."$"."KML_SOURCE_URL	=	'http://www.opengis.net/kml/2.2';\r\n"
							."$"."kml_out		=	'../out/kml/';\r\n"
							."$"."vs1_out		=	'../out/vs1/';\r\n"
							."$"."daemon_out		=	'out/daemon/';\r\n"
							."$"."gpx_out		=	'../out/gpx/';\r\n\r\n");
if($AD_CF_KM_Re){echo "<tr class=\"good\"><td>Success..........</td><td>Add KML Info</td></tr>";}
else{echo "<tr class=\"bad\"><td>Failure..........</td><td>Adding KML Info</td></tr>";}


$AD_CF_FI_Re = fwrite($fileappend,"#---------------- Header and Footer Additional Info -----------------#\r\n"
								."$"."ads		= ''; # <-- put the code for your ads in here www.google.com/adsense\r\n"
								."$"."header	= '<meta name=\"description\" content=\"A Wireless Database based off of scans from Vistumbler.\" /><meta name=\"keywords\" content=\"WiFiDB, linux, windows, vistumbler, Wireless, database, db, php, mysql\" />';\r\n"
								."$"."tracker	= ''; # <-- put the code for the url tracker that you use here (ie - www.google.com/analytics )\r\n");
if($AD_CF_FI_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>Add Footer Information Info</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Adding Footer Information </td></tr>";}

?></table><h2>Now you can remove the /install folder from the WiFiDB install root</h2><?php


?>