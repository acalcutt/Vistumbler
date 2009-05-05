<?php
include('lib/database.inc.php');
pageheader("Upgrade Page");
?>
</td>
	<td width="80%" bgcolor="#A9C6FA" valign="top" align="center">
		<p align="center">
<table><tr><th>Status</th><th>Step of Install</th></tr>
<tr><TH colspan="2">Upgrade DB for 0.16 Build 1 to 0.16 Build 2</TH><tr>
<?php
$ENG = "InnoDB";
$date = date("Y-m-d");
$root_sql_user	=	$_POST['root_sql_user'];
strip_tags($root_sql_user);
$root_sql_pwd	=	$_POST['root_sql_pwd'];
strip_tags($root_sql_pwd);
$sqlhost	=	$_POST['sqlhost'];
strip_tags($sqlhost);
$sqlu		=	$_POST['sqlu'];
strip_tags($sqlu);
$sqlp		=	$_POST['sqlp'];
strip_tags($sqlp);
$wifi		=	$_POST['wifi'];
strip_tags($wifi);
$wifi_st	=	$_POST['wifist'];
strip_tags($wifi_st);
$daemon	=	$_POST['daemon'];
strip_tags($daemon);
if($daemon == "on")
{$daemon = 1;}else{$daemon = 0;}

if ($sqlhost !== 'localhost' or $sqlhost !== "127.0.0.1")
{$phphost = 'localhost';}
else{$phphost	=	$_POST['phphost'];}

#Connect with Root priv
$conn = mysql_connect($sqlhost, $root_sql_user, $root_sql_pwd);

$sqls =	"REVOKE ALL PRIVILEGES ON `$wifi` . * FROM '$sqlu'@'$phphost'";
$GR_US_WF_Re = mysql_query($sqls, $conn) or die(mysql_error());

if($GR_US_WF_Re)
{echo "<tr><td>Success..........</td><td>Revoke user: $sqlu @ $phphost for $wifi</td></tr>";}
else{
echo "<tr><td>Failure..........</td><td>Revoke user: $sqlu @ $phphost for $wifi</td></tr>";
}

$sqls =	"REVOKE ALL PRIVILEGES ON `$wifi_st` . * FROM '$sqlu'@'$phphost'";
$GR_US_WF_Re = mysql_query($sqls, $conn) or die(mysql_error());

if($GR_US_WF_Re)
{echo "<tr><td>Success..........</td><td>Revoke user: $sqlu @ $phphost for $wifi_st</td></tr>";}
else{
echo "<tr><td>Failure..........</td><td>Revoke user: $sqlu @ $phphost for $wifi_st</td></tr>";
}


$sqls =	"GRANT SELECT , INSERT , UPDATE , DELETE ,CREATE ,DROP ,INDEX ,ALTER ,CREATE TEMPORARY TABLES ,CREATE VIEW ,SHOW VIEW ,CREATE ROUTINE,ALTER ROUTINE,EXECUTE ON `$wifi` . * TO '$sqlu'@'$phphost'";
$GR_US_WF_Re = mysql_query($sqls, $conn) or die(mysql_error());

if($GR_US_WF_Re)
{echo "<tr><td>Success..........</td><td>Re-Created user: $sqlu @ $phphost for $wifi</td></tr>";}
else{
echo "<tr><td>Failure..........</td><td>Re-Created user: $sqlu @ $phphost for $wifi</td></tr>";
}


$sqls =	"GRANT SELECT , INSERT , UPDATE , DELETE ,CREATE ,DROP ,INDEX ,ALTER ,CREATE TEMPORARY TABLES ,CREATE VIEW ,SHOW VIEW ,CREATE ROUTINE,ALTER ROUTINE,EXECUTE ON `$wifi_st` . * TO '$sqlu'@'$phphost'";
$GR_US_ST_Re = mysql_query($sqls, $conn) or die(mysql_error());

if($GR_US_WF_Re)
{echo "<tr><td>Success..........</td><td>Re-Created user: $sqlu @ $phphost for $wifi_st</td></tr>";}
else{
echo "<tr><td>Failure..........</td><td>Re-Created user: $sqlu @ $phphost for $wifi_st</td></tr>";}

mysql_select_db($wifi,$conn);
$sql = "TRUNCATE TABLE `links`";
$drop = mysql_query($sql, $conn) or die(mysql_error());

if($drop)
{echo "<tr><td>Success..........</td><td>EMPTY TABLE `links`</td></tr>";}
else{
echo "<tr><td>Failure..........</td><td>EMPTY TABLE `links`</td></tr>";}

$sql1 = "INSERT INTO `links` (`ID`, `links`) VALUES"
		."(1, '<a class=\"links\" href=\"$hosturl/$root/\">Main Page</a>'),"
		."(2, '<a class=\"links\" href=\"$hosturl/$root/all.php?sort=SSID&ord=ASC&from=0&to=100\">View All APs</a>'),"
		."(3, '<a class=\"links\" href=\"$hosturl/$root/import/\">Import</a>'),"
		."(4, '<a class=\"links\" href=\"$hosturl/$root/opt/export.php?func=index\">Export</a>'),"
		."(5, '<a class=\"links\" href=\"$hosturl/$root/opt/search.php\">Search</a>'),"
		."(6, '<a class=\"links\" href=\"$hosturl/$root/opt/userstats.php?func=allusers\">View All Users</a>'),"
		."(7, '<a class=\"links\" href=\"$hosturl/$root/ver.php\">WiFiDB Version</a>'),"
		."(8, '<a class=\"links\" href=\"$hosturl/$root/announce.php?func=allusers\">Announcements</a>')";

$insert = mysql_query($sql, $conn) or die(mysql_error());

if($insert)
{echo "<tr><td>Success..........</td><td>Insert new links into `$db`.`links`;</td></tr> ";
else{
echo "<tr><td>Failure..........</td><td>Insert new links into `$db`.`links`; </td></tr>";
}

$sql1 = "CREATE TABLE `annunc-comm` (
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

$insert = mysql_query($sql, $conn) or die(mysql_error());

if($insert)
{echo "<tr><td>Success..........</td><td>Create Announcement Comments table `$db`.`annunc-comm`;</td></tr> ";
else{
echo "<tr><td>Failure..........</td><td>Create Announcement Comments table `$db`.`annunc-comm`;</td></tr> ";
}

$sql1 = "CREATE TABLE `annunc` (
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

if($insert)
{echo "<tr><td>Success..........</td><td>Create Announcements table `$db`.`annunc`;</td></tr>";
else{
echo "<tr><td>Failure..........</td><td>Create Announcements table `$db`.`annunc`;</td></tr> ";
}

$sql1 = "CREATE TABLE `files` (
		`id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY ,
		`file` TEXT NOT NULL ,
		`date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,
		`size` FLOAT( 12, 12 ) NOT NULL ,
		`aps` INT NOT NULL ,
		`gps` INT NOT NULL ,
		`hash` VARCHAR( 255 ) NOT NULL,
		`user` VARCHAR( 64 ) NOT NULL,
		`title` VARCHAR( 128 ) NOT NULL,
		`notes` TEXT NOT NULL,
		`user_row` INT NOT NULL ,
		PRIMARY KEY ( `id` ) ,
		UNIQUE ( `file` )
		) ENGINE = InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1";

if($insert)
{echo "<tr><td>Success..........</td><td>Create Files table `$db`.`files`;</td></tr>";
else{
echo "<tr><td>Failure..........</td><td>Create Files table `$db`.`files`; </td></tr>";
}

$sql1 = "CREATE TABLE `files_tmp` (
		`id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY ,
		`file` VARCHAR( 255 ) NOT NULL ,
		`user` VARCHAR ( 32 ) NOT NULL,
		`notes` TEXT NOT NULL,
		`title` VARCHAR ( 128 ) NOT NULL,
		`size` FLOAT (12,12 ) NOT NULL ,
		`date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,
		`hash` VARCHAR( 255 ) NOT NULL,
		PRIMARY KEY ( `id` ) ,
		UNIQUE ( `file` )	
		) ENGINE = InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1";

if($insert)
{echo "<tr><td>Success..........</td><td>Create tmp File table `$db`.`files`;</td></tr>";
else{
echo "<tr><td>Failure..........</td><td>Create tmp Files table `$db`.`files`; </td></tr>";
}

$sql1 = "ALTER TABLE `users` ADD `aps` INT NOT NULL , ADD `gps` INT NOT NULL";

if($insert)
{echo "<tr><td>Success..........</td><td>Altered `$db`.`users` to add aps and gps count fields;</td></tr>";
else{
echo "<tr><td>Failure..........</td><td>Alter `$db`.`users` to add aps and gps count fields;</td></tr>";
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
fclose($filewrite);

echo "</table>";

echo "<h2>Now you can remove the /install folder from the WiFiDB install root</h2>";

$filename = $_SERVER['SCRIPT_FILENAME'];
footer($filename);
?>