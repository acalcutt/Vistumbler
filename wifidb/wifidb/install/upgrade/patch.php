<?php
global $screen_output;
$screen_output = "CLI";
include('../../lib/database.inc.php');
pageheader("Upgrade Page", "detailed", 1);

include($half_path.'/lib/config.inc.php');
?>
<h3>If one of the steps shows "Duplicate column name '***'," you can ignore this error.</h3>
<table border="1">
<tr class="style4"><TH colspan="2">Upgrade DB for all versions <b>--&#60;</b> 0.20 Build 1</TH>
<tr class="style4"><th colspan="2">Upgrade Database Tables</th></tr>
<tr class="style4"><th>Status</th><th>Step of Upgrade</th></tr>
<?php

/*

CREATE TABLE  `wifi`.`live_gps` (
`id` INT( 255 ) NOT NULL AUTO_INCREMENT ,
`lat` VARCHAR( 255 ) NOT NULL ,
`long` VARCHAR( 255 ) NOT NULL ,
`sats` INT( 25 ) NOT NULL ,
`hdp` VARCHAR( 255 ) NOT NULL ,
`alt` VARCHAR( 255 ) NOT NULL ,
`geo` VARCHAR( 255 ) NOT NULL ,
`kmh` VARCHAR( 255 ) NOT NULL ,
`mph` VARCHAR( 255 ) NOT NULL ,
`track` VARCHAR( 255 ) NOT NULL ,
`date` VARCHAR( 255 ) NOT NULL ,
`time` VARCHAR( 255 ) NOT NULL ,
PRIMARY KEY (  `id` ) ,
INDEX (  `id` )
) ENGINE = INNODB;





CREATE TABLE  `wifi`.`live_aps` (
`id` INT( 255 ) NOT NULL AUTO_INCREMENT ,
`ssid` VARCHAR( 255 ) NOT NULL ,
`mac` VARCHAR( 255 ) NOT NULL ,
`auth` INT( 25 ) NOT NULL ,
`encry` VARCHAR( 255 ) NOT NULL ,
`sectype` VARCHAR( 255 ) NOT NULL ,
`chan` VARCHAR( 255 ) NOT NULL ,
`radio` VARCHAR( 255 ) NOT NULL ,
`sig` VARCHAR( 255 ) NOT NULL ,
`username` VARCHAR( 255 ) NOT NULL ,
PRIMARY KEY (  `id` ) ,
INDEX (  `id` )
) ENGINE = INNODB;
*/



global $wifidb_smtp, $wifidb_email_updates, $reserved_users;
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
$password		=	addslashes(strip_tags($_POST['wdb_admn_pass']));
$email			=	addslashes(strip_tags($_POST['wdb_admn_emailadrs']));
$wifidb_from			=	addslashes(strip_tags($_POST['wdb_from_emailadrs']));
$wifidb_from_pass		=	addslashes(strip_tags($_POST['wdb_from_pass']));
$wifidb_smtp			=	addslashes(strip_tags($_POST['wdb_smtp']));

$reserved_users		=	'WiFiDB:Recovery';

if($_POST['email_validation'] == 'on')
{
	$email_validation	=	1;
}else
{
	$email_validation	=	0;
}
if($_POST['wdb_email_updates'] == 'on')
{
	$wifidb_email_updates	=	1;
}else
{
	$wifidb_email_updates	=	0;
}

if(!@isset($timeout)){$timeout		=   "(86400 * 365)";}

if($theme == '')
{
	$theme = 'wifidb';
}

if($hosturl == '')
{
	$hosturl = (@$_SERVER["SERVER_NAME"]!='' ? $_SERVER["SERVER_NAME"] : $_SERVER["SERVER_ADDR"]);
}

if($sqlhost == '')
{$sqlhost = '127.0.0.1';}

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
{$phphost = $_SERVER['SERVER_ADDR'];}
else{$phphost	=	$_SERVER['SERVER_ADDR'];}

#Connect with Root priv
$conn1 = mysql_connect($sqlhost, $root_sql_user, $root_sql_pwd) or die("</table>Could not create MySQL Connection".footer($_SERVER['SCRIPT_FILENAME']));


$sqls =	"REVOKE GRANT OPTION ON  `$wifi` . * FROM  '$sqlu'@'$phphost'";
$GR_US_WF_Re = mysql_query($sqls, $conn1);
if($GR_US_WF_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>Alter user: $sqlu @ $phphost for $wifi</td></tr>\r\n\r\n";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Alter user: $sqlu @ $phphost for $wifi;<br>".mysql_error($conn1)."</td></tr>\r\n\r\n";
}


$sqls =	"REVOKE ALL PRIVILEGES ON  `$wifi` . * FROM  '$sqlu'@'$phphost'";
$GR_US_WF_Re = mysql_query($sqls, $conn1);
if($GR_US_WF_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>Alter user: $sqlu @ $phphost for $wifi</td></tr>\r\n\r\n";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Alter user: $sqlu @ $phphost for $wifi;<br>".mysql_error($conn1)."</td></tr>\r\n\r\n";
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
$GR_US_WF_Re = mysql_query($sqls, $conn1) or die(mysql_error($conn1));
if($GR_US_WF_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>Alter user: $sqlu @ $phphost for $wifi</td></tr>\r\n\r\n";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Alter user: $sqlu @ $phphost for $wifi;<br>".mysql_error($conn1)."</td></tr>\r\n\r\n";
}


$sqls =	"REVOKE GRANT OPTION ON  `$wifi_st` . * FROM  '$sqlu'@'$phphost'";
$GR_US_WF_Re = mysql_query($sqls, $conn1);
if($GR_US_WF_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>Alter user: $sqlu @ $phphost for $wifi_st</td></tr>\r\n\r\n";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Alter user: $sqlu @ $phphost for $wifi_st;<br>".mysql_error($conn1)."</td></tr>\r\n";
}


$sqls =	"REVOKE ALL PRIVILEGES ON  `$wifi_st` . * FROM  '$sqlu'@'$phphost'";
$GR_US_WF_Re = mysql_query($sqls, $conn1);
if($GR_US_WF_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>Alter user: $sqlu @ $phphost for $wifi_st</td></tr>\r\n";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Alter user: $sqlu @ $phphost for $wifi_st;<br>".mysql_error($conn1)."</td></tr>\r\n";
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
$GR_US_WF_Re = mysql_query($sqls, $conn1);
if($GR_US_WF_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>Alter user: $sqlu @ $phphost for $wifi_st</td></tr>\r\n";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Alter user: $sqlu @ $phphost for $wifi_st;<br>".mysql_error($conn1)."</td></tr>\r\n";
}

#######################
$sql = "TRUNCATE TABLE `$wifi`.`links`";
$drop = mysql_query($sql, $conn1);
if($drop)
{echo "<tr class=\"good\"><td>Success..........</td><td>EMPTY TABLE `links`</td></tr>\r\n";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>EMPTY TABLE `links`;<br>".mysql_error($conn1)."</td></tr>\r\n";}

####################
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
$insert = mysql_query($sql1, $conn1);
if($insert)
{echo "<tr class=\"good\"><td>Success..........</td><td>Create Files table `$wifi`.`files`;</td></tr>\r\n";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Create Files table `$wifi`.`files`;<br>".mysql_error($conn1)."</td></tr>\r\n";
}

######################
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
$insert = mysql_query($sql1, $conn1);
if($insert)
{echo "<tr class=\"good\"><td>Success..........</td><td>Create tmp File table `$wifi`.`files_tmp`;</td></tr>\r\n";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Create tmp Files table `$wifi`.`files_tmp`;<br>".mysql_error($conn1)."</td></tr>\r\n";
}
####################
$sql1 = "CREATE TABLE `$wifi`.`validate_table` (
	`id` INT( 255 ) NOT NULL AUTO_INCREMENT,
	`username` VARCHAR( 255 ) NOT NULL ,
	`code` VARCHAR( 64 ) NOT NULL ,
	`date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,
	UNIQUE (`username`),
	INDEX ( `id` )
	) ENGINE = InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1";
$insert = mysql_query($sql1, $conn1);
if($insert)
{echo "<tr class=\"good\"><td>Success..........</td><td>Create email validation table <b>`$wifi`</b>.`validation_table`;</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Create email validation table <b>`$wifi`</b>.`validation_table`;<br>".mysql_error($conn1)." </td></tr>";
}

####################
$sql1 = "ALTER TABLE `$wifi`.`$wtable` CHANGE `ssid` `ssid` VARCHAR( 32 ), CHANGE `chan` `chan` VARCHAR( 3 ), CHANGE `id` `id` INT( 255 ) NOT NULL AUTO_INCREMENT";
$insert = mysql_query($sql1, $conn1);
if($insert)
{echo "<tr class=\"good\"><td>Success..........</td><td>Altered `$wifi`.`$wtable` to change ssid( 32 char max), chan(3 char max), id (numeric 255 not null, auto increment) fields;</td></tr>\r\n";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Alter `$wifi`.`$wtable` to change SSID (32 char max), Chan(3 char max), ID (numeric 255 not null, auto increment) fields;<br>".mysql_error($conn1)."</td></tr>\r\n";
}


$alter_sql = "ALTER TABLE `$wifi`.`wifi0` 
ADD `countrycode` VARCHAR( 5 ) NOT NULL ,
ADD `countryname` VARCHAR( 64 ) NOT NULL ,
ADD `admincode` VARCHAR( 5 ) NOT NULL ,
ADD `adminname` VARCHAR( 64 ) NOT NULL ,
ADD `iso3166-2` VARCHAR( 3 ) NOT NULL ,
ADD `lat` VARCHAR( 32 ) NOT NULL DEFAULT 'N 0.0000' ,
ADD `long` VARCHAR( 32 ) NOT NULL DEFAULT 'E 0.0000',
ADD `active` tinyint(1) NOT NULL DEFAULT 0";
$alter = mysql_query($alter_sql, $conn1);
if($alter)
{echo "<tr class=\"good\"><td>Success..........</td><td>To alter <b>`$wifi`</b>.`wtable` to add location filter data for KML's</td></tr>\r\n";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>To alter <b>`$wifi`</b>.`wtable` to add location filter data for KML's</td></tr>\r\n ";
}
#######################################


################### ALTER $users_t TABLE
$sql = "RENAME TABLE `$wifi`.`users` TO `$wifi`.`users_imports`";
$insert = mysql_query($sql, $conn1);
if($insert)
{echo "<tr class=\"good\"><td>Success..........</td><td>Altered `$wifi`.`users` to new table name `user_imports;</td></tr>\r\n";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Altered `$wifi`.`users` to new table name `user_imports;<br>".mysql_error($conn1)."</td></tr>\r\n";
}
$users_t = 'users_imports';
############################################
$sql1 = "ALTER TABLE `$wifi`.`$users_t` ADD `hash` VARCHAR ( 255 ) NOT NULL";
$insert = mysql_query($sql1, $conn1);
if($insert)
{echo "<tr class=\"good\"><td>Success..........</td><td>Altered `$wifi`.`$users_t` to add file hash field;</td></tr>\r\n";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Alter `$wifi`.`$users_t` to add file hash field;<br>".mysql_error($conn1)."</td></tr>\r\n";
}

$sql1 = "ALTER TABLE `$wifi`.`$users_t` ADD `aps` INT NOT NULL, 
CHANGE `username` `username` VARCHAR( 255 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL ,
CHANGE `title` `title` VARCHAR( 255 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL";
$insert = mysql_query($sql1, $conn1);
if($insert)
{echo "<tr class=\"good\"><td>Success..........</td><td>Altered `$wifi`.`$users_t` to add aps field;</td></tr>\r\n";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Alter `$wifi`.`$users_t` to add aps field;<br>".mysql_error($conn1)."</td></tr>\r\n";
}

$sql1 = "ALTER TABLE `$wifi`.`$users_t` ADD `gps` INT NOT NULL";
$insert = mysql_query($sql1, $conn1);
if($insert)
{echo "<tr class=\"good\"><td>Success..........</td><td>Altered `$wifi`.`$users_t` to add gps field;</td></tr>\r\n";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Alter `$wifi`.`$users_t` to add gps field;<br>".mysql_error($conn1)."</td></tr>\r\n";
}

$sql1 = "ALTER TABLE `$wifi`.`$users_t` CHANGE `title` `title` VARCHAR ( 255 ) NOT NULL";
$insert = mysql_query($sql1, $conn1);
if($insert)
{echo "<tr class=\"good\"><td>Success..........</td><td>Altered `$wifi`.`$users_t` to change title field to 255 chars;</td></tr>\r\n";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Alter `$wifi`.`$users_t` to change title field to 255 chars;<br>".mysql_error($conn1)."</td></tr>\r\n";
}

$sql1 = "ALTER TABLE `$wifi`.`$users_t` ADD `notes` TEXT NOT NULL";
$insert = mysql_query($sql1, $conn1);
if($insert)
{echo "<tr class=\"good\"><td>Success..........</td><td>Altered `$wifi`.`$users_t` to add notes field;</td></tr>\r\n";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Alter `$wifi`.`$users_t` to add notes field;<br>".mysql_error($conn1)."</td></tr>\r\n";
}

$sql1 = "ALTER TABLE `$wifi`.`$users_t` CHANGE `username` `username` VARCHAR ( 255 ) NOT NULL";
$insert = mysql_query($sql1, $conn1);
if($insert)
{echo "<tr class=\"good\"><td>Success..........</td><td>Altered `$wifi`.`$users_t` `username` field to VARCHAR( 255 );</td></tr>\r\n";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Alter `$wifi`.`$users_t` `username` field to VARCHAR( 255 );<br>".mysql_error($conn1)."</td></tr>\r\n";
}
####################################################################



####	ALTER FILES TABLE WITH NEW FIELDS
$sql1 = "ALTER TABLE `$wifi`.`files` CHANGE `size` `size` VARCHAR( 14 )";
$insert = mysql_query($sql1, $conn1);
if($insert)
{echo "<tr class=\"good\"><td>Success..........</td><td>Changed `$wifi`.`files` `size` field, from float to varchar(14);</td></tr>\r\n";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Change `$wifi`.`files` `size` field, from float to varchar(14);<br>".mysql_error($conn1)."</td></tr>\r\n";
}
$sql1 = "ALTER TABLE `$wifi`.`files` CHANGE `file` `file` VARCHAR( 255 )";
$insert = mysql_query($sql1, $conn1);
if($insert)
{echo "<tr class=\"good\"><td>Success..........</td><td>Changed `$wifi`.`files` `file` VARCHAR( 255 );</td></tr>\r\n";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Change `$wifi`.`files` `file` VARCHAR( 255 );<br>".mysql_error($conn1)."</td></tr>\r\n";
}
$sql1 = "ALTER TABLE `$wifi`.`files` CHANGE `title` `title` VARCHAR ( 255 ) NOT NULL, CHARSET=utf8";
$insert = mysql_query($sql1, $conn1);
if($insert)
{echo "<tr class=\"good\"><td>Success..........</td><td>Changed field (Title) to `$wifi`.`files`;</td></tr>\r\n";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Change field (Title) to `$wifi`.`files`;<br>".mysql_error($conn1)."</td></tr>\r\n";
}
$sql1 = "ALTER TABLE `$wifi`.`files` CHANGE `user` `user` VARCHAR ( 255 ) NOT NULL, CHARSET=utf8";
$insert = mysql_query($sql1, $conn1);
if($insert)
{echo "<tr class=\"good\"><td>Success..........</td><td>Added field (user) to `$wifi`.`files`;</td></tr>\r\n";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Added field (user) to `$wifi`.`files`;<br>".mysql_error($conn1)."</td></tr>\r\n";
}
$sql1 = "ALTER TABLE `$wifi`.`files` CHANGE `notes` `notes` TEXT NOT NULL, CHARSET=utf8";
$insert = mysql_query($sql1, $conn1);
if($insert)
{echo "<tr class=\"good\"><td>Success..........</td><td>Changed field (notes) to `$wifi`.`files`;</td></tr>\r\n";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Change field (notes) to `$wifi`.`files`;<br>".mysql_error($conn1)."</td></tr>\r\n";
}
#########################################################





$sql1 = "ALTER TABLE `$wifi`.`files_tmp` CHANGE `title` `title` VARCHAR ( 255 ) NOT NULL, CHARSET=utf8";
$insert = mysql_query($sql1, $conn1);
if($insert)
{echo "<tr class=\"good\"><td>Success..........</td><td>Changed field (Title) to `$wifi`.`files_tmp`;</td></tr>\r\n";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Change field (Title) to `$wifi`.`files_tmp`;<br>".mysql_error($conn1)."</td></tr>\r\n";
}




####	ALTER FILES_TMP TABLE WITH NEW FIELDS
$sql1 = "ALTER TABLE `$wifi`.`files_tmp` CHANGE `size` `size` VARCHAR( 12 ), CHARSET=utf8";
$insert = mysql_query($sql1, $conn1);
if($insert)
{echo "<tr class=\"good\"><td>Success..........</td><td>Altered `$wifi`.`files_tmp` `size` fields, from float to varchar(12);</td></tr>\r\n";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Altered `$wifi`.`files_tmp` `size` fields, from float to varchar(12);<br>".mysql_error($conn1)."</td></tr>\r\n";
}
$sql1 =  "ALTER TABLE `$wifi`.`files_tmp` CHANGE `file` `file` VARCHAR( 255 ), CHARSET=utf8";
$insert = mysql_query($sql1, $conn1);
if($insert)
{echo "<tr class=\"good\"><td>Success..........</td><td>Altered `$wifi`.`files_tmp` CHANGE `file` VARCHAR( 255 );</td></tr>\r\n";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Altered `$wifi`.`files_tmp` CHANGE `file` VARCHAR( 255 );<br>".mysql_error($conn1)."</td></tr>\r\n";
}
###############################################







################################
$sql1 =  "ALTER TABLE `$wifi`.`settings` CHANGE `size` `size` VARCHAR( 255 ), CHARSET=utf8";
$insert = mysql_query($sql1, $conn1);
if($insert)
{echo "<tr class=\"good\"><td>Success..........</td><td>Altered `$wifi`.`settings` CHANGE `size` VARCHAR( 255 );</td></tr>\r\n";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Altered `$wifi`.`settings` CHANGE `size` VARCHAR( 255 );<br>".mysql_error($conn1)."</td></tr>\r\n";
}

$sql_test = "SELECT * FROM `$wifi`.`settings` WHERE `table` LIKE 'files'";
$insert = mysql_query($sql_test, $conn1);
$insert_arry = mysql_fetch_array($insert);
if($insert_arry['table'] != 'files')
{
	$sql1 =  "INSERT INTO `$wifi`.`settings` ( `id`, `table`, `size`) VALUES ( '1', 'files', '')";
	$insert = mysql_query($sql1, $conn1);
	if($insert)
	{echo "<tr class=\"good\"><td>Success..........</td><td>INSERT wifidb Size holder INTO <b>`$wifi`</b>.`settings`, not really used, just like to have it here.</td></tr>\r\n";}
	else{
	echo "<tr class=\"bad\"><td>Failure..........</td><td>INSERT wifidb Size holder INTO <b>`$wifi`</b>.`settings`<br>".mysql_error($conn1)."</td></tr>\r\n";
	}
}else
{
	echo "<tr class=\"good\"><td>Success..........</td><td>wifidb Size holder INTO <b>`$wifi`</b>.`settings` exists no insert needed, not really used, just like to have it here.</td></tr>\r\n";
}

$sql_test = "SELECT * FROM `$wifi`.`settings` WHERE `table` = 'theme'";
$insert = mysql_query($sql_test, $conn1);
$insert_arry = mysql_fetch_array($insert);
if($insert_arry['table'] == 'theme')
{
	$sql1 =  "DELETE FROM `$wifi`.`settings` WHERE `table` = 'theme'";
	$insert = mysql_query($sql1, $conn1);
	if($insert)
	{echo "<tr class=\"good\"><td>Success..........</td><td>Deleted 'themes' Row from <b>`$wifi`</b>.`settings`</td></tr>\r\n";}
	else{
	echo "<tr class=\"bad\"><td>Failure..........</td><td>Failed to deleted 'themes' Row from <b>`$wifi`</b>.`settings`<br>".mysql_error($conn1)."</td></tr>\r\n";
	}
}else
{
	echo "<tr class=\"good\"><td>Success..........</td><td>'themes' Row from <b>`$wifi`</b>.`settings` did not exist, no need to remove</td></tr>\r\n";
}
############################################


#############################################
$sql = "CREATE TABLE IF NOT EXISTS `$wifi`.`share_waypoints` (
  `id` int(255) NOT NULL auto_increment,
  `author` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `gcid` varchar(255) NOT NULL,
  `notes` text NOT NULL,
  `cat` varchar(255) NOT NULL,
  `type` varchar(255) NOT NULL,
  `diff` double(3,2) NOT NULL,
  `terain` double(3,2) NOT NULL,
  `lat` varchar(255) NOT NULL,
  `long` varchar(255) NOT NULL,
  `link` varchar(255) NOT NULL,
  `c_date` datetime NOT NULL,
  `u_date` datetime NOT NULL,
  `pvt_id` int(255) NOT NULL,
  `shared_by` varchar(255) NOT NULL,
  UNIQUE KEY `id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1";
$insert = mysql_query($sql, $conn1) or die(mysql_error());
if($insert)
{echo "<tr class=\"good\"><td>Success..........</td><td>Create Shared Geocaches table <b>`$wifi`</b>.`share_waypoints`;</td></tr>\r\n";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>To create Shared Geocaches table <b>`$wifi`</b>.`share_waypoints`;</td></tr>\r\n ";
}


############################################
$sql1 = "CREATE TABLE IF NOT EXISTS `$wifi`.`daemon_perf_mon` (
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
$insert = mysql_query($sql1, $conn1) or die(mysql_error());
if($insert)
{echo "<tr class=\"good\"><td>Success..........</td><td>Create Daemon Performance table <b>`$wifi`</b>.`daemon_perf_mon`;</td></tr>\r\n";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>To create Daemon Performance table <b>`$wifi`</b>.`daemon_perf_mon`;</td></tr>\r\n ";
}



##########################################
$sql1 = "CREATE TABLE IF NOT EXISTS `$wifi`.`DB_stats` (
`id` INT( 255 ) NOT NULL auto_increment,
`timestamp` VARCHAR( 60 ) NOT NULL ,
`graph_min` VARCHAR( 255 ) NOT NULL ,
`graph_max` VARCHAR( 255 ) NOT NULL ,
`graph_avg` VARCHAR( 255 ) NOT NULL ,
`graph_num` VARCHAR( 255 ) NOT NULL ,
`graph_total` VARCHAR( 255 ) NOT NULL ,
`kmz_min` VARCHAR( 255 ) NOT NULL ,
`kmz_max` VARCHAR( 255 ) NOT NULL ,
`kmz_avg` VARCHAR( 255 ) NOT NULL ,
`kmz_num` VARCHAR( 255 ) NOT NULL ,
`kmz_total` VARCHAR( 255 ) NOT NULL ,
`file_min` VARCHAR( 255 ) NOT NULL ,
`file_max` VARCHAR( 255 ) NOT NULL ,
`file_avg` VARCHAR( 255 ) NOT NULL ,
`file_num` VARCHAR( 255 ) NOT NULL ,
`file_up_totals` VARCHAR( 255 ) NOT NULL ,
`gpx_size` VARCHAR( 255 ) NOT NULL ,
`gpx_num` VARCHAR( 255 ) NOT NULL ,
`gpx_min` VARCHAR( 255 ) NOT NULL ,
`gpx_max` VARCHAR( 255 ) NOT NULL ,
`gpx_avg` VARCHAR( 255 ) NOT NULL ,
`daemon_size` VARCHAR( 255 ) NOT NULL ,
`daemon_num` VARCHAR( 255 ) NOT NULL ,
`daemon_min` VARCHAR( 255 ) NOT NULL ,
`daemon_max` VARCHAR( 255 ) NOT NULL ,
`daemon_avg` VARCHAR( 255 ) NOT NULL ,
`total_aps` VARCHAR( 255 ) NOT NULL ,
`wep_aps` VARCHAR( 255 ) NOT NULL ,
`open_aps` VARCHAR( 255 ) NOT NULL ,
`secure_aps` VARCHAR( 255 ) NOT NULL ,
`nuap` VARCHAR( 255 ) NOT NULL ,
`num_priv_geo` VARCHAR( 255 ) NOT NULL ,
`num_pub_geo` VARCHAR( 255 ) NOT NULL ,
`user` BLOB NOT NULL ,
`ap_gps_totals` BLOB NOT NULL ,
`top_ssids` BLOB NOT NULL ,
`geos` BLOB NOT NULL ,
INDEX ( `id` ) ,
UNIQUE (`timestamp`)
) ENGINE = InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1";
$insert = mysql_query($sql1, $conn1) or die(mysql_error());
if($insert)
{echo "<tr class=\"good\"><td>Success..........</td><td>Create DB stats table <b>`$wifi`</b>.`DB_stats`;</td></tr>\r\n";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>To create DB stats table <b>`$wifi`</b>.`DB_stats`;</td></tr>\r\n ";
}
######################################


#####################################
$sql1 = "CREATE TABLE IF NOT EXISTS `$wifi`.`user_info` (
  `id` int(255) NOT NULL auto_increment,
  `username` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `help` varchar(255) NOT NULL,
  `uid` varchar(255) NOT NULL,
  `disabled` tinyint(1) NOT NULL,
  `validated` tinyint(1) NOT NULL,
  `locked` tinyint(1) NOT NULL,
  `login_fails` int(255) NOT NULL,
  `admins` tinyint(1) NOT NULL,
  `devs` tinyint(1) NOT NULL,
  `mods` tinyint(1) NOT NULL,
  `users` tinyint(1) NOT NULL,
  `last_login` datetime NOT NULL,
  `last_active` datetime NOT NULL,
  `email` varchar(255) NOT NULL,
  `mail_updates` TINYINT( 1 ) NOT NULL DEFAULT '1',
  `schedule` TINYINT( 1 ) NOT NULL DEFAULT '1',
  `imports` TINYINT( 1 ) NOT NULL DEFAULT '1',
  `kmz` TINYINT( 1 ) NOT NULL DEFAULT '1',
  `new_users` TINYINT( 1 ) NOT NULL DEFAULT '1',
  `statistics` TINYINT( 1 ) NOT NULL DEFAULT '1',
  `announcements` TINYINT( 1 ) NOT NULL DEFAULT '1',
  `announce_comment` TINYINT( 1 ) NOT NULL DEFAULT '1',
  `geonamed` TINYINT( 1 ) NOT NULL DEFAULT '1',
  `pub_geocache` TINYINT( 1 ) NOT NULL DEFAULT '1',
  `h_email` tinyint(1) NOT NULL DEFAULT '1',
  `join_date` datetime NOT NULL,
  `friends` text NOT NULL,
  `foes` text NOT NULL,
  `website` varchar(255) NOT NULL,
  `rank` varchar(255) NOT NULL,
  `Vis_ver` varchar(255) NOT NULL,
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `uid` (`uid`),
  UNIQUE KEY `email` (`email`),
  KEY `id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1";
$insert = mysql_query($sql1, $conn1) or die(mysql_error());
if($insert)
{echo "<tr class=\"good\"><td>Success..........</td><td>Create User Login Table table <b>`$wifi`</b>.`user_info`;</td></tr>\r\n";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>To create User Login Table table <b>`$wifi`</b>.`user_info`;</td></tr>\r\n ";
}

####################################

	#========================================================================================================================#
	#											Update the Config.inc.php file										   	     #
	#========================================================================================================================#
?>
<tr class="style4"><TH colspan="2">Config.inc.php File Creation</th></tr>
<tr class="style4"><th>Status</th><th>Step of Upgrade</th></tr>
<?php
$file_ext = 'config.inc.php';
$filename = '../../lib/'.$file_ext;
$filewrite = fopen($filename, "w");
$fileappend = fopen($filename, "a");

if($filewrite)
{echo "<tr class=\"good\"><td>Success..........</td><td>Created Config file</td></tr>\r\n";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Creating Config file</td></tr>\r\n";}
if(!@$login_seed)
{
	$base			=	'ABCDEFGHKLMNOPQRSTWXYZabcdefghjkmnpqrstwxyz123456789!@#$%^&*()_+-=';
	$max			=	strlen($base)-1;
	$seed_len_gen	=	32;
	$activatecode	=	'';
	mt_srand((double)microtime()*1000000);
	while (strlen($activatecode) < $seed_len_gen+1)
	{$activatecode.=$base{mt_rand(0,$max)};}
}else
{
	$activatecode = $login_seed;
}
#Add last edit date and globals
if($root != ''){$wifidb_install_ = $_SERVER['DOCUMENT_ROOT'].$root;}else{$wifidb_install_ = $_SERVER['DOCUMENT_ROOT'];}
$CR_CF_FL_Re = fwrite($fileappend, "<?php
#COOKIE GLOBALS
global $"."console_refresh, $"."console_scroll, $"."console_last5, $"."default_theme, $"."default_refresh, $"."default_dst, $"."default_timezone, $"."timeout, $"."config_fails, $"."login_seed;
#SQL GLOBALS
global $"."wifidb_install, $"."conn, $"."db, $"."db_st, $"."DB_stats_table, $"."daemon_perf_table, $"."users_t, $"."user_logins_table, $"."validate_table, $"."files, $"."files_tmp, $"."annunc, $"."annunc_comm, $"."collate, $"."engine, $"."char_set;
#MISC GLOBALS
global $"."header, $"."ads, $"."tracker, $"."hosturl, $"."dim, $"."admin_email, $"."email_validation, $"."WiFiDB_LNZ_User, $"."apache_grp, $"."div, $"."wifidb_tools, $"."daemon, $"."root, $"."console_lines, $"."console_log, $"."bypass_check, $"."wifidb_email_updates, $"."wifidb_from,$"."wifidb_from_pass;

$"."lastedit	=	'$date';

#----------General Settings------------#
$"."wifidb_tools	=	'$toolsdir';
$"."wifidb_install	=	'".$wifidb_install_."';
$"."timezn			=	'UTC';
$"."root			=	'$root';
$"."hosturl		=	'$hosturl';
$"."dim			=	DIRECTORY_SEPARATOR;
$"."admin_email	=	'$email';
$"."config_fails	=	3;
$"."login_seed		=	'$activatecode';
$"."wifidb_from	=	'$wifidb_from';
$"."wifidb_from_pass	=	'$wifidb_from_pass';
$"."wifidb_smtp		=	'$wifidb_smtp';
$"."email_validation =	$email_validation;
$"."wifidb_email_updates = $wifidb_email_updates;
$"."reserved_users		=	'WiFiDB:Recovery';\r\n\r\n");

if($CR_CF_FL_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>Add Global variables and general variables values.</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Add Global variables and general variables values.</td></tr>";}


#add default daemon values
$AD_CF_DG_Re = fwrite($fileappend, "#---------------- Daemon Info ----------------#
$"."daemon				=	$daemon;
$"."log_level			=	0;
$"."log_interval		=	0;
$"."WiFiDB_LNZ_User 	=	'$httpduser';
$"."apache_grp			=	'$httpdgrp';\r\n\r\n");
if($AD_CF_DG_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>Add default daemon values</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Add default daemon values</td></tr>";}


#add default theme values
$AD_CF_DG_Re = fwrite($fileappend, "#-------------Themes Settings--------------#
$"."default_theme		= '$theme';
$"."default_refresh 	= 15;
$"."default_timezone	= 0;
$"."default_dst		= 0;
$"."timeout			= $timeout; #(86400 [seconds in a day] * 365 [days in a year]) \r\n\r\n");

if($AD_CF_DG_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>Add default theme values</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Add default theme values</td></tr>";}


$AD_CF_DG_Re = fwrite($fileappend, "#-------------Console Viewer Settings--------------#
$"."console_refresh	= 15;
$"."console_scroll		= 1;
$"."console_last5		= 1;
$"."console_lines		= 10;
$"."console_log		= '/var/log/wifidbd';\r\n\r\n");

if($AD_CF_DG_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>Add default Console values</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Add default Console values</td></tr>";}

#add default debug values
$AD_CF_DG_Re = fwrite($fileappend, "#---------------- Debug Info ----------------#
$"."bypass_check	=	0;
$"."rebuild		=	0;
$"."debug		=	0;
$"."bench		=	0;\r\n\r\n");

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
$"."daemon_perf_table	=	'daemon_perf_mon';
$"."DB_stats			=	'DB_stats';
$"."validate_table		=	'validate_table';
$"."share_cache			=	'share_waypoints';
$"."files				=	'files';
$"."files_tmp			=	'files_tmp';
$"."annunc				=	'annunc';
$"."annunc_comm		=	'annunc_comm';
$"."gps_ext			=	'_GPS';
$"."sep				=	'-';\r\n\r\n");

if($AD_CF_UR_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>Add Table variable values</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Adding Table variable values</td></tr>";}



#add sql host info
$AD_CF_DB_Re = fwrite($fileappend, "#---------------- DataBases ----------------#
$"."db		=	'$wifi';
$"."db_st	=	'$wifi_st';\r\n\r\n");
if($AD_CF_DB_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>Add DataBase names</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Adding DataBase names</td></tr>";}

#add sql info
$AD_CF_SH_Re = fwrite($fileappend, "#---------------- SQL Info ----------------#
$"."host		=	'$sqlhost';
$"."db_user	=	'$sqlu';
$"."db_pwd		=	'$sqlp';
$"."conn		=	 mysql_pconnect($"."host, $"."db_user, $"."db_pwd) or die(\"Unable to connect to SQL server: $"."host\");
$"."collate	=	'utf8_bin';
$"."engine		=	'innodb';
$"."char_set	=	'utf8';\r\n\r\n");

if($AD_CF_SH_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>Add SQL Info</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Adding SQL Info</td></tr>";}


$AD_CF_KM_Re = fwrite($fileappend, "#---------------- Export Info ----------------#
$"."open_loc		=	'http://vistumbler.sourceforge.net/images/program-images/open.png';
$"."WEP_loc		=	'http://vistumbler.sourceforge.net/images/program-images/secure-wep.png';
$"."WPA_loc		=	'http://vistumbler.sourceforge.net/images/program-images/secure.png';
$"."KML_SOURCE_URL	=	'http://www.opengis.net/kml/2.2';
$"."kml_out		=	'../out/kml/';
$"."vs1_out		=	'../out/vs1/';
$"."daemon_out		=	'out/daemon/';
$"."gpx_out		=	'../out/gpx/';\r\n\r\n");
if($AD_CF_KM_Re){echo "<tr class=\"good\"><td>Success..........</td><td>Add KML Info</td></tr>";}
else{echo "<tr class=\"bad\"><td>Failure..........</td><td>Adding KML Info</td></tr>";}


$AD_CF_FI_Re = fwrite($fileappend,"#---------------- Header and Footer Additional Info -----------------#
$"."ads		= ''; # <-- put the code for your ads in here www.google.com/adsense
$"."header		= '<meta name=\"description\" content=\"A Wireless Database based off of scans from Vistumbler.\" /><meta name=\"keywords\" content=\"WiFiDB, linux, windows, vistumbler, Wireless, database, db, php, mysql\" />';
$"."tracker	= ''; # <-- put the code for the url tracker that you use here (ie - www.google.com/analytics )\r\n");
if($AD_CF_FI_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>Add Footer Information Info</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Adding Footer Information </td></tr>";}
fclose($fileappend);
fclose($filewrite);

	#========================================================================================================================#
	#										Create WiFiDB Administrator User										   	     #
	#========================================================================================================================#
require_once("../../lib/security.inc.php");
$sec = new security();
$create = $sec->create_user('Admin', $password, $email, $user_array=array(1,0,0,1), "", 0);
switch($create)
{
	case 1:
		echo "<tr class=\"good\"><td>Success..........</td><td>Created Default Wifidb Administrator user</td></tr>\r\n";
	break;
	
	case is_array($create):
		list($er, $msg) = $create;
		switch($er)
		{
			case "create_wpt":
				echo '<tr class="bad"><td>Failure..........</td><td>There was an error in Creating the Geocache table.<BR>This is a serious error, contact Phil on the <a href="http://forum.techidiots.net/">forums</a><br>MySQL Error Message: '.$msg."<br><h1>D'oh!</h1></td></tr>\r\n";
			break;
			
			case "dup_u":
				echo '<tr class="bad"><td>Failure..........</td><td>To create Wifidb Admin User. :-(<br>MySQL Error: '.$msg.'<br><h1>Do`h!</h1></td></tr>';
			break;
			
			case "err_email":
				echo '<tr class="bad"><td>Failure..........</td><td>To create Wifidb Admin User. :-(<br>Email Error: '.$msg.'<br><h1>Do`h!</h1></td></tr>';
			break;
		}
	break;
}
?>
</table>
<h2>Install is Finished, if all was Successfull you may now remove the Install Folder</h2>

<?php
footer($_SERVER['SCRIPT_FILENAME']);
?>

