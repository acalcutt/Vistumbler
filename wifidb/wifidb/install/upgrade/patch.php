<?php
include('../../lib/database.inc.php');
pageheader("Upgrade Page");
?>
<link rel="stylesheet" href="../../css/site4.0.css">
<?php
include('../../lib/config.inc.php');
?>
<h3>If one of the steps shows "Duplicate column name '***'," you can ignore this error.</h3>
<table border="1"><tr class="style4"><th>Status</th><th>Step of Install</th></tr>
<tr class="style4"><TH colspan="2">Upgrade DB for 0.16 Build 1 / 2 / 2.1 <b>--></b> 0.16 Build 3</TH><tr>
<?php
$Local_tz=date_default_timezone_get();
$ENG = "InnoDB";
$date = date("Y-m-d");
$root_sql_user	=	addslashes(strip_tags($_POST['root_sql_user']));
$root_sql_pwd	=	addslashes(strip_tags($_POST['root_sql_pwd']));
$sqlhost		=	addslashes(strip_tags($_POST['sqlhost']));
$sqlu			=	addslashes(strip_tags($_POST['sqlu']));
$sqlp			=	addslashes(strip_tags($_POST['sqlp']));
$wifi			=	addslashes(strip_tags($_POST['wifi']));
$wifi_st		=	addslashes(strip_tags($_POST['wifist']));

if(isset($_POST['daemon']))
{
	$daemon		= addslashes(strip_tags($_POST['daemon']));
	$toolsdir	= addslashes(strip_tags($_POST['toolsdir']));
}else
{
	$daemon = "off";
	$toolsdir		=	"NO PATH";
}

if($daemon == "on")
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
$conn = mysql_connect($sqlhost, $root_sql_user, $root_sql_pwd);


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


$sql1 = "CREATE TABLE IF NOT EXISTS `$wifi`.`annunc-comm` (
		`id` INT NOT NULL AUTO_INCREMENT ,
		`author` VARCHAR( 32 ) NOT NULL DEFAULT 'Annon Coward' ,
		`title` VARCHAR( 120 ) NOT NULL DEFAULT 'Blank',
		`body` TEXT NOT NULL ,
		`date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,
		PRIMARY KEY ( `id` ) ,
		INDEX ( `id` ) ,
		UNIQUE ( `title` )
		) ENGINE = InnoDB DEFAULT CHARSET = utf8 AUTO_INCREMENT = 1";

$insert = mysql_query($sql, $conn);
if($insert)
{echo "<tr class=\"good\"><td>Success..........</td><td>Create Announcement Comments table `$wifi`.`annunc-comm`;</td></tr> ";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Create Announcement Comments table `$wifi`.`annunc-comm`;<br>".mysql_error($conn)."</td></tr> ";
}


$sql1 = "CREATE TABLE IF NOT EXISTS `$wifi`.`annunc` (
		`id` INT NOT NULL AUTO_INCREMENT ,
		`auth` VARCHAR( 32 ) NOT NULL DEFAULT 'Annon Coward',
		`title` VARCHAR( 120 ) NOT NULL DEFAULT 'Blank',
		`date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,
		`body` TEXT NOT NULL ,
		`comments` TEXT NOT NULL ,
		PRIMARY KEY ( `id` ) ,
		INDEX ( `id` ) ,
		UNIQUE ( `title` )
		) ENGINE = InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1";
$insert = mysql_query($sql1, $conn);
if($insert)
{echo "<tr class=\"good\"><td>Success..........</td><td>Create Announcements table `$wifi`.`annunc`;</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Create Announcements table `$wifi`.`annunc`;<br>".mysql_error($conn)."</td></tr> ";
}


$sql1 = "CREATE TABLE IF NOT EXISTS `$wifi`.`files` (
		`id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY ,
		`file` varchar(255) NOT NULL ,
		`date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,
		`size` VARCHAR( 12 ) NOT NULL ,
		`aps` INT NOT NULL ,
		`gps` INT NOT NULL ,
		`hash` VARCHAR( 255 ) NOT NULL,
		`user` VARCHAR( 64 ) NOT NULL,
		`title` VARCHAR( 128 ) NOT NULL,
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
		`user` VARCHAR ( 32 ) NOT NULL,
		`notes` TEXT NOT NULL,
		`title` VARCHAR ( 128 ) NOT NULL,
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

$sql1 = "ALTER TABLE `$wifi`.`wifi0` CHANGE `ssid` `ssid` VARCHAR( 32 ), CHANGE `id` `id` INT( 255 ) NOT NULL AUTO_INCREMENT";
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

$sql1 = "ALTER TABLE `$wifi`.`users` ADD `aps` INT NOT NULL";
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

$sql1 = "ALTER TABLE `$wifi`.`users` ADD `title` VARCHAR ( 128 ) NOT NULL";
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

$sql1 = "ALTER TABLE `$wifi`.`users` CHANGE `username` `username` VARCHAR ( 64 ) NOT NULL";
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
{echo "<tr class=\"good\"><td>Success..........</td><td>Altered `$wifi`.`files` `size` field, from float to varchar(14);</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Altered `$wifi`.`files` `size` field, from float to varchar(14);<br>".mysql_error($conn)."</td></tr>";
}
$sql1 = "ALTER TABLE `$wifi`.`files` CHANGE `file` `file` VARCHAR( 255 )";
$insert = mysql_query($sql1, $conn);
if($insert)
{echo "<tr class=\"good\"><td>Success..........</td><td>Changed `$wifi`.`files` `file` VARCHAR( 255 );</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Changed `$wifi`.`files` `file` VARCHAR( 255 );<br>".mysql_error($conn)."</td></tr>";
}
$sql1 = "ALTER TABLE `$wifi`.`files` ADD `title` VARCHAR ( 128 ) NOT NULL, CHARSET=utf8";
$insert = mysql_query($sql1, $conn);
if($insert)
{echo "<tr class=\"good\"><td>Success..........</td><td>Added field (Title) to `$wifi`.`files`;</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Added field (Title) to `$wifi`.`files`;<br>".mysql_error($conn)."</td></tr>";
}
$sql1 = "ALTER TABLE `$wifi`.`files` ADD `user` VARCHAR ( 32 ) NOT NULL, CHARSET=utf8";
$insert = mysql_query($sql1, $conn);
if($insert)
{echo "<tr class=\"good\"><td>Success..........</td><td>Added field (user) to `$wifi`.`files`;</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Added field (user) to `$wifi`.`files`;<br>".mysql_error($conn)."</td></tr>";
}
$sql1 = "ALTER TABLE `$wifi`.`files` ADD `notes` TEXT NOT NULL, CHARSET=utf8";
$insert = mysql_query($sql1, $conn);
if($insert)
{echo "<tr class=\"good\"><td>Success..........</td><td>Added field (notes) to `$wifi`.`files`;</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Added field (notes) to `$wifi`.`files`;<br>".mysql_error($conn)."</td></tr>";
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
####	UPDATE CONFIG.INC.PHP
echo '<tr><TH colspan="2"></th></tr><tr class="style4"><TH colspan="2">Config.inc.php File Creation</th><tr>';
$file_ext = 'config.inc.php';
$filename = '../../lib/'.$file_ext;
$filewrite = fopen($filename, "w");
$fileappend = fopen($filename, "a");

if($filewrite)
{echo "<tr class=\"good\"><td>Success..........</td><td>Created Config file</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Creating Config file</td></tr>";}


#Add last edit date
$CR_CF_FL_Re = fwrite($fileappend, "<?php\r\nglobal $"."conn, $"."wifidb_tools, $"."daemon;\r\ndate_default_timezone_set('GMT+0');\r\n$"."lastedit	=	'$date';\r\n\r\n");

if($CR_CF_FL_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>Add Install date</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Add Install date</td></tr>";}

if(!isset($loglev)){$loglev = 0;}
#add default debug values
$AD_CF_DG_Re = fwrite($fileappend, "#---------------- Daemon Info ----------------#\r\n"
									."$"."daemon		=	".$daemon.";\r\n"
									."$"."debug			=	$debug;\r\n"
									."$"."log_level		=	$loglev;\r\n"
									."$"."log_interval	=	0;\r\n"
									."$"."wifidb_tools	=	'".$toolsdir."';\r\n"
									."$"."DST			=	'".$Local_tz."';\r\n");

if($AD_CF_DG_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>Add default daemon values</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Add default daemon values</td></tr>";}

#add default debug values
$AD_CF_DG_Re = fwrite($fileappend, "#---------------- Debug Info ----------------#\r\n"
									."$"."rebuild		=	$rebuild;\r\n"
									."$"."bench			=	0;\r\n");

if($AD_CF_DG_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>Add default debug values</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Add default debug values</td></tr>";}
if($root[0] == "/"){$root = preg_replace("/", "", $root);}
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
									."$"."settings_tb 	=	'$settings_tb';\r\n"
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
							."$"."open_loc 				=	'http://vistumbler.sourceforge.net/images/program-images/open.png';\r\n"
							."$"."WEP_loc 				=	'http://vistumbler.sourceforge.net/images/program-images/secure-wep.png';\r\n"
							."$"."WPA_loc 				=	'http://vistumbler.sourceforge.net/images/program-images/secure.png';\r\n"
							."$"."KML_SOURCE_URL			=	'http://www.opengis.net/kml/2.2';\r\n"
							."$"."kml_out				=	'../out/kml/';\r\n"
							."$"."vs1_out				=	'../out/vs1/';\r\n"
							."$"."gpx_out				=	'../out/gpx/';\r\n\r\n");
if($AD_CF_KM_Re){echo "<tr class=\"good\"><td>Success..........</td><td>Add KML Info</td></tr>";}
else{echo "<tr class=\"bad\"><td>Failure..........</td><td>Adding KML Info</td></tr>";}


$AD_CF_FI_Re = fwrite($fileappend,"#---------------- Footer Additional Info -----------------#\r\n"
								."$"."ads 		= '<meta name=\"description\" content=\"A Wireless Database based off of scans from Vistumbler.\" />
<meta name=\"keywords\" content=\"WiFiDB, linux, windows, vistumbler, Wireless, database, db, php, mysql\" />'; # <-- put the code for your ads in here www.google.com/adsense\r\n"
								."$"."tracker 	= ''; # <-- put the code for the url tracker that you use here (ie - www.google.com/analytics )\r\n");
if($AD_CF_FI_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>Add Footer Information Info</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Adding Footer Information </td></tr>";}

?></table><h2>Now you can remove the /install folder from the WiFiDB install root</h2><?php

$filename = $_SERVER['SCRIPT_FILENAME'];
footer($filename);
?>