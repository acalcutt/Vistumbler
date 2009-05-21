<?php
include('../../lib/database.inc.php');
pageheader("Upgrade Page");
include('../../lib/config.inc.php');
?>
<table><tr><th>Status</th><th>Step of Install</th></tr>
<tr><TH colspan="2">Upgrade DB for 0.16 Build 1 to 0.16 Build 2</TH><tr>
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
$daemon			=	addslashes(strip_tags($_POST['daemon']));
if($daemon == "on")
{$daemon = 1;}else{$daemon = 0;}

if ($sqlhost !== 'localhost' or $sqlhost !== "127.0.0.1")
{$phphost = 'localhost';}
else{$phphost	=	$_POST['phphost'];}

#Connect with Root priv
$conn = mysql_connect($sqlhost, $root_sql_user, $root_sql_pwd);


$sqls =	"REVOKE GRANT OPTION ON  `$wifi` . * FROM  '$sqlu'@'$phphost'";
$GR_US_WF_Re = mysql_query($sqls, $conn);
if($GR_US_WF_Re)
{echo "<tr><td>Success..........</td><td>Alter user: $sqlu @ $phphost for $wifi</td></tr>";}
else{
echo "<tr><td>Failure..........</td><td>Alter user: $sqlu @ $phphost for $wifi;<br>".mysql_error($conn)."</td></tr>";
}


$sqls =	"REVOKE ALL PRIVILEGES ON  `$wifi` . * FROM  '$sqlu'@'$phphost'";
$GR_US_WF_Re = mysql_query($sqls, $conn);
if($GR_US_WF_Re)
{echo "<tr><td>Success..........</td><td>Alter user: $sqlu @ $phphost for $wifi</td></tr>";}
else{
echo "<tr><td>Failure..........</td><td>Alter user: $sqlu @ $phphost for $wifi;<br>".mysql_error($conn)."</td></tr>";
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
{echo "<tr><td>Success..........</td><td>Alter user: $sqlu @ $phphost for $wifi</td></tr>";}
else{
echo "<tr><td>Failure..........</td><td>Alter user: $sqlu @ $phphost for $wifi;<br>".mysql_error($conn)."</td></tr>";
}


$sqls =	"REVOKE GRANT OPTION ON  `$wifi_st` . * FROM  '$sqlu'@'$phphost'";
$GR_US_WF_Re = mysql_query($sqls, $conn);
if($GR_US_WF_Re)
{echo "<tr><td>Success..........</td><td>Alter user: $sqlu @ $phphost for $wifi_st</td></tr>";}
else{
echo "<tr><td>Failure..........</td><td>Alter user: $sqlu @ $phphost for $wifi_st;<br>".mysql_error($conn)."</td></tr>";
}


$sqls =	"REVOKE ALL PRIVILEGES ON  `$wifi_st` . * FROM  '$sqlu'@'$phphost'";
$GR_US_WF_Re = mysql_query($sqls, $conn);
if($GR_US_WF_Re)
{echo "<tr><td>Success..........</td><td>Alter user: $sqlu @ $phphost for $wifi_st</td></tr>";}
else{
echo "<tr><td>Failure..........</td><td>Alter user: $sqlu @ $phphost for $wifi_st;<br>".mysql_error($conn)."</td></tr>";
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
{echo "<tr><td>Success..........</td><td>Alter user: $sqlu @ $phphost for $wifi_st</td></tr>";}
else{
echo "<tr><td>Failure..........</td><td>Alter user: $sqlu @ $phphost for $wifi_st;<br>".mysql_error($conn)."</td></tr>";
}


$sql = "TRUNCATE TABLE `$wifi`.`links`";
$drop = mysql_query($sql, $conn);
if($drop)
{echo "<tr><td>Success..........</td><td>EMPTY TABLE `links`</td></tr>";}
else{
echo "<tr><td>Failure..........</td><td>EMPTY TABLE `links`;<br>".mysql_error($conn)."</td></tr>";}


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
{echo "<tr><td>Success..........</td><td>Insert new links into `$wifi`.`links`;</td></tr> ";}
else{
echo "<tr><td>Failure..........</td><td>Insert new links into `$wifi`.`links`<br>".mysql_error($conn)."</td></tr>";
}


$sql1 = "CREATE TABLE IF NOT EXISTS `$wifi`.`annunc-comm` (
		`id` INT NOT NULL AUTO_INCREMENT ,
		`author` VARCHAR( 32 ) NOT NULL ,
		`title` VARCHAR( 120 ) NOT NULL ,
		`body` TEXT NOT NULL ,
		`date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,
		PRIMARY KEY ( `id` ) ,
		INDEX ( `id` ) ,
		UNIQUE (
		`title`
		)
		) ENGINE = InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1";

$insert = mysql_query($sql, $conn);
if($insert)
{echo "<tr><td>Success..........</td><td>Create Announcement Comments table `$wifi`.`annunc-comm`;</td></tr> ";}
else{
echo "<tr><td>Failure..........</td><td>Create Announcement Comments table `$wifi`.`annunc-comm`;<br>".mysql_error($conn)."</td></tr> ";
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
		UNIQUE (
		`title`
		)
		) ENGINE = InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1";
$insert = mysql_query($sql1, $conn);
if($insert)
{echo "<tr><td>Success..........</td><td>Create Announcements table `$wifi`.`annunc`;</td></tr>";}
else{
echo "<tr><td>Failure..........</td><td>Create Announcements table `$wifi`.`annunc`;<br>".mysql_error($conn)."</td></tr> ";
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
{echo "<tr><td>Success..........</td><td>Create Files table `$wifi`.`files`;</td></tr>";}
else{
echo "<tr><td>Failure..........</td><td>Create Files table `$wifi`.`files`;<br>".mysql_error($conn)."</td></tr>";
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
{echo "<tr><td>Success..........</td><td>Create tmp File table `$wifi`.`files_tmp`;</td></tr>";}
else{
echo "<tr><td>Failure..........</td><td>Create tmp Files table `$wifi`.`files_tmp`;<br>".mysql_error($conn)."</td></tr>";
}

$sql1 = "ALTER TABLE `$wifi`.`wifi0` CHANGE `ssid` `ssid` VARCHAR( 32 )";
$insert = mysql_query($sql1, $conn);
if($insert)
{echo "<tr><td>Success..........</td><td>Altered `$wifi`.`users` to add aps, gps, username, notes, and title fields;</td></tr>";}
else{
echo "<tr><td>Failure..........</td><td>Alter `$wifi`.`users` to add aps, gps, username, notes, and title fields;<br>".mysql_error($conn)."</td></tr>";
}


$sql1 = "ALTER TABLE `$wifi`.`users` ADD `aps` INT NOT NULL , ADD `gps` INT NOT NULL, ADD `title` VARCHAR ( 128 ) NOT NULL, ADD `notes` TEXT NOT NULL, ADD `user` VARCHAR ( 64 ) NOT NULL";
$insert = mysql_query($sql1, $conn);
if($insert)
{echo "<tr><td>Success..........</td><td>Altered `$wifi`.`users` to add aps, gps, username, notes, and title fields;</td></tr>";}
else{
echo "<tr><td>Failure..........</td><td>Alter `$wifi`.`users` to add aps, gps, username, notes, and title fields;<br>".mysql_error($conn)."</td></tr>";
}


$sql1 = "ALTER TABLE `$wifi`.`files` CHANGE `size` `size` VARCHAR( 14 ), CHANGE `file` `file` VARCHAR( 255 ), ADD `user` VARCHAR ( 32 ) NOT NULL, ADD `notes` TEXT NOT NULL, ADD `title` VARCHAR ( 128 ) NOT NULL, CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL ";
$insert = mysql_query($sql1, $conn);
if($insert)
{echo "<tr><td>Success..........</td><td>Altered `$wifi`.`files` `size` fields, from float to varchar(12), CHANGE `file` `file` VARCHAR( 255 );</td></tr>";}
else{
echo "<tr><td>Failure..........</td><td>Altered `$wifi`.`files` `size` fields, from float to varchar(12);<br>".mysql_error($conn)."</td></tr>";
}


$sql1 = "ALTER TABLE `$wifi`.`files_tmp` CHANGE `size` `size` VARCHAR( 12 ), CHANGE `file` `file` VARCHAR( 255 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL ";
$insert = mysql_query($sql1, $conn);
if($insert)
{echo "<tr><td>Success..........</td><td>Altered `$wifi`.`files_tmp` `size` fields, from float to varchar(12), CHANGE `file` VARCHAR( 255 );</td></tr>";}
else{
echo "<tr><td>Failure..........</td><td>Altered `$wifi`.`files_tmp` `size` fields, from float to varchar(12), CHANGE `file` VARCHAR( 255 );<br>".mysql_error($conn)."</td></tr>";
}


mysql_close($conn);

$file_ext = 'config.inc.php';
$filename = '../../lib/'.$file_ext;
$fileappend = fopen($filename, "a");
$AD_CF_FI_Re = fwrite($fileappend,"<?php\r\n#---------------- Footer Additional Info -----------------#\r\n"
									."$"."ads		=	''; # <-- put the code for your ads in here www.google.com/adsense\r\n"
									."$"."tracker	=	''; # <-- put the code for the url tracker that you use here (ie - www.google.com/analytics )\r\n"
									."$"."kml_out	=	'../out/kml/';\r\n$"."vs1_out	=	'../out/vs1/';\r\n$"."gpx_out				=	'../out/vs1/';"
									."\r\n\r\n date_default_timezone_set('GMT+0');");
if($AD_CF_FI_Re)
{echo "<tr><td>Success..........</td><td>Add Footer Information Info</td></tr>";}
else{
echo "<tr><td>Failure..........</td><td>Adding Footer Information </td></tr>";}

$AD_CF_DG_Re = fwrite($fileappend, "#---------------- Daemon Info ----------------#\r\n$"."rebuild	=	0;\r\n"
									."$"."daemon	=	".$daemon.";\r\n");

if($AD_CF_DG_Re)
{echo "<tr><td>Success..........</td><td>Add default daemon values</td></tr>";}
else{
echo "<tr><td>Failure..........</td><td>Add default daemon values</td></tr>";}


$install_warning = fwrite($fileappend,"if(is_dir('install')){echo '<h2>The install Folder is still there, remove it!</h2>';}\nelseif(is_dir('../install')){echo '<h2>The install Folder is still there, remove it!</h2>';}");
if($install_warning)
{echo "<tr><td>Success..........</td><td>Add Footer Information Info</td></tr>";}
else{
echo "<tr><td>Failure..........</td><td>Adding Footer Information </td></tr>";}

fwrite($fileappend, "\r\n?>");
fclose($fileappend);

echo "</table>";

echo "<h2>Now you can remove the /install folder from the WiFiDB install root</h2>";

$filename = $_SERVER['SCRIPT_FILENAME'];
footer($filename);
?>