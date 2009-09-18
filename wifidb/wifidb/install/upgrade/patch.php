<?php
include('../../lib/database.inc.php');
pageheader("Upgrade Page");
?>
<link rel="stylesheet" href="../../themes/wifidb/styles.css">
<?php
include('../../lib/config.inc.php');
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
if(!@isset($timeout)){$timeout		=   "(86400 * 365)";}

if(isset($_POST['daemon']))
{
	$daemon		= addslashes(strip_tags($_POST['daemon']));
	$toolsdir	= addslashes(strip_tags($_POST['toolsdir']));
	$httpduser	= addslashes(strip_tags($_POST['httpduser']));
	$httpdgrp	= addslashes(strip_tags($_POST['httpdgrp']));
	$
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
{echo "<tr class=\"good\"><td>Success..........</td><td>Altered `$wifi`.`users` to add aps, gps, username, notes, and title fields;</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Alter `$wifi`.`users` to add aps, gps, username, notes, and title fields;<br>".mysql_error($conn)."</td></tr>";
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
{echo "<tr class=\"good\"><td>Success..........</td><td>Altered `$wifi`.`users` to add title field;</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Alter `$wifi`.`users` to add aps title field;<br>".mysql_error($conn)."</td></tr>";
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
{echo "<tr class=\"good\"><td>Success..........</td><td>Altered `$wifi`.`users` `username` field to VARCHAR( 64 );</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Alter `$wifi`.`users` `username` field to VARCHAR( 64 );<br>".mysql_error($conn)."</td></tr>";
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






####	UPDATE CONFIG.INC.PHP
?>
<tr class="style4"><TH colspan="2">Config.inc.php File Creation</th></tr>
<tr class="style4"><th>Status</th><th>Step of Upgrade</th></tr>
<?php

$file_ext = 'config.inc.php';
$filename = '../../lib/'.$file_ext;
$filewrite = fopen($filename, "w");
$fileappend = fopen($filename, "a");

if($filewrite)
{echo "<tr class=\"good\"><td>Success..........</td><td>Created Config file</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Creating Config file</td></tr>";}


#Add last edit date and globals
$CR_CF_FL_Re = fwrite($fileappend, "<?php\r\nglobal $"."header, $"."ads, $"."tracker, $"."hosturl;
global $"."WiFiDB_LNZ_User, $"."apache_grp, $"."div, $"."conn, $"."wifidb_tools, $"."daemon, $"."root;
global $"."console_refresh, $"."console_scroll, $"."console_last5, $"."console_lines, $"."default_theme, $"."default_refresh, $"."default_timezone;\r\n$"."lastedit	=	'$date';\r\n\r\n");

if($CR_CF_FL_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>Add Install date</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Add Install date</td></tr>";}


#add default daemon values
$AD_CF_DG_Re = fwrite($fileappend, "#---------------- Daemon Info ----------------#\r\n"
									."$"."daemon		=	".$daemon.";\r\n"
									."$"."debug			=	0;\r\n"
									."$"."log_level		=	0;\r\n"
									."$"."log_interval	=	0;\r\n"
									."$"."wifidb_tools	=	'".$toolsdir."';\r\n"
									."$"."timezn		=	'".$Local_tz."';\r\n"
									."$"."WiFiDB_LNZ_User 	=	'$httpduser';\r\n"
									."$"."apache_grp			=	'$httpdgrp';\r\n\r\n");
if($AD_CF_DG_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>Add default daemon values</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Add default daemon values</td></tr>";}

if($theme == ''){$theme = "wifidb";}
#add default theme values
$AD_CF_DG_Re = fwrite($fileappend, "#-------------Themes Settings--------------#
$"."default_theme		= '$theme';
$"."default_refresh 	= 15;
$"."default_timezone	= 0;
$"."timeout			= $timeout; #(86400 [seconds in a day] * 365 [days in a year]) \r\n\r\n");

if($AD_CF_DG_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>Add default theme values</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Add default theme values</td></tr>";}


$AD_CF_DG_Re = fwrite($fileappend, "#-------------Console Viewer Settings--------------#
$"."console_refresh = 15;
$"."console_scroll  = 1;
$"."console_last5   = 1;
$"."console_lines   = 10;
$"."console_log		= '/var/log/wifidb';\r\n\r\n");

if($AD_CF_DG_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>Add default Console values</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Add default Console values</td></tr>";}

#add default debug values
$AD_CF_DG_Re = fwrite($fileappend, "#---------------- Debug Info ----------------#\r\n"
									."$"."rebuild		=	$rebuild;\r\n"
									."$"."bench			=	$bench;\r\n\r\n");

if($AD_CF_DG_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>Add default debug values</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Add default debug values</td></tr>";}

#add url info
$AD_CF_UR_Re = fwrite($fileappend, "#---------------- URL Info ----------------#\r\n"
									."$"."root		=	'$root';\r\n"
									."$"."hosturl	=	'$hosturl';\r\n\r\n");

if($AD_CF_UR_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>Add PHP Host URL</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Adding PHP Host URL</td></tr>";}


#add sql host info
$AD_CF_SH_Re = fwrite($fileappend, "#---------------- SQL Host ----------------#\r\n"
									."$"."host	=	'$sqlhost';\r\n\r\n");

if($AD_CF_SH_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>Add SQL Host info</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Adding SQL Host info</td></tr>";}

#add Table names
$AD_CF_WT_Re = fwrite($fileappend, "#---------------- Tables ----------------#\r\n"
									."$"."settings_tb 	=	'$settings';\r\n"
									."$"."users_tb 		=	'$users_tb';\r\n"
									."$"."links 			=	'$links';\r\n"
									."$"."wtable 		=	'$wtable';\r\n"
									."$"."gps_ext 		=	'$gps_ext';\r\n"
									."$"."sep 			=	'$sep';\r\n\r\n");
if($AD_CF_WT_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>Add Table names</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Adding Table names</td></tr>";}

#add sql host info
$AD_CF_DB_Re = fwrite($fileappend, "#---------------- DataBases ----------------#\r\n"
									."$"."db			=	'$wifi';\r\n"
									."$"."db_st 		=	'$wifi_st';\r\n\r\n");
if($AD_CF_DB_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>Add DataBase names</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Adding DataBase names</td></tr>";}

#add sql host info
$AD_CF_SU_Re = fwrite($fileappend, "#---------------- SQL User Info ----------------#\r\n"
									."$"."db_user		=	'$sqlu';\r\n"
									."$"."db_pwd			=	'$sqlp';\r\n\r\n");
if($AD_CF_SU_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>Add DataBase names</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Adding DataBase names</td></tr>";}

#add sql Connection info
$AD_CF_SC_Re = fwrite($fileappend, "#---------------- SQL Connection Info ----------------#\r\n"
							."$"."conn 				=	 mysql_pconnect($"."host, $"."db_user, $"."db_pwd) or die(\"Unable to connect to SQL server: $"."host\");\r\n\r\n");
if($AD_CF_SU_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>Add SQL Connection Info</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Adding SQL Connection Info</td></tr>";}

$AD_CF_KM_Re = fwrite($fileappend, "#---------------- Export Info ----------------#\r\n"
							."$"."open_loc 				=	'$open_loc';\r\n"
							."$"."WEP_loc 				=	'$WEP_loc';\r\n"
							."$"."WPA_loc 				=	'$WPA_loc';\r\n"
							."$"."KML_SOURCE_URL		=	'$KML_SOURCE_URL';\r\n"
							."$"."kml_out				=	'$kml_out';\r\n"
							."$"."vs1_out				=	'$vs1_out';\r\n"
							."$"."daemon_out			=	'$daemon_out';\r\n"
							."$"."gpx_out				=	'$gpx_out';\r\n\r\n");
if($AD_CF_KM_Re){echo "<tr class=\"good\"><td>Success..........</td><td>Add KML Info</td></tr>";}
else{echo "<tr class=\"bad\"><td>Failure..........</td><td>Adding KML Info</td></tr>";}


$AD_CF_FI_Re = fwrite($fileappend,"#---------------- Header and Footer Additional Info -----------------#\r\n"
								."$"."ads			= '$ads';"
								."$"."header 		= '$header'; # <-- put the code for your ads in here www.google.com/adsense\r\n"
								."$"."tracker 	= '$tracker'; # <-- put the code for the url tracker that you use here (ie - www.google.com/analytics )\r\n");
if($AD_CF_FI_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>Add Footer Information Info</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Adding Footer Information </td></tr>";}

?></table><h2>Now you can remove the /install folder from the WiFiDB install root</h2><?php


?>