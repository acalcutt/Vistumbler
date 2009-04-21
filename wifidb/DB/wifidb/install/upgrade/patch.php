<?php
include('lib/database.inc.php');
echo '<title>Wireless DataBase *Alpha*'.$ver["wifidb"].' --> Upgrade Page</title>';
?>
<link rel="stylesheet" href="../css/site4.0.css">
<body topmargin="10" leftmargin="0" rightmargin="0" bottommargin="10" marginwidth="10" marginheight="10">
<div align="center">
<table border="0" width="75%" cellspacing="10" cellpadding="2">
	<tr>
		<td bgcolor="#315573">
		<p align="center"><b><font size="5" face="Arial" color="#FFFFFF">
		<?php echo 'Wireless DataBase *Alpha* '.$ver["wifidb"].'</font>';?>
		<font color="#FFFFFF" size="2">
            <a class="links" href="/">[Root] </a>/ <a class="links" href="/wifidb/">[WifiDB] </a>/
		</font></b>
		</p>
		</td>
	</tr>
</table>
</div>
<div align="center">
<table border="0" width="75%" cellspacing="10" cellpadding="2" height="90">
	<tr>
<td width="17%" bgcolor="#304D80" valign="top">
<table><tr><th>Status</th><th>Step of Install</th></tr>
<tr><TH colspan="2">Upgrade DB for 0.15 Build 7x to 0.16 Build 1</TH><tr>
<?php

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
{echo "<tr><td>Success..........</td><td>EMPTY TABLE `links`";}
else{
echo "<tr><td>Failure..........</td><td>EMPTY TABLE `links`";}

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
{echo "<tr><td>Success..........</td><td>Insert new links into `$db`.`links`; ";
else{
echo "<tr><td>Failure..........</td><td>Insert new links into `$db`.`links`; ";
}

$sql1 = "CREATE TABLE `wifi`.`annunc-comm` (
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
		) ENGINE = InnoDB";

$insert = mysql_query($sql, $conn) or die(mysql_error());

if($insert)
{echo "<tr><td>Success..........</td><td>Create Announcement Comments table `$db`.`annunc-comm`; ";
else{
echo "<tr><td>Failure..........</td><td>Create Announcement Comments table `$db`.`annunc-comm`; ";
}

$sql1 = "CREATE TABLE `wifi`.`annunc` (
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
		) ENGINE = InnoDB";

if($insert)
{echo "<tr><td>Success..........</td><td>Create Announcements table `$db`.`annunc`;";
else{
echo "<tr><td>Failure..........</td><td>Create Announcements table `$db`.`annunc`; ";
}


mysql_close($conn);
$file_ext = 'config.inc.php';
$filename = '../../lib/'.$file_ext;
$fileappend = fopen($filename, "a");
$AD_CF_FI_Re = fwrite($fileappend,"<?php\r\n#---------------- Footer Additional Info -----------------#\r\n"
									."$"."ads		=	''; # <-- put the code for your ads in here www.google.com/adsense\r\n"
									."$"."tracker	=	''; # <-- put the code for the url tracker that you use here (ie - www.google.com/analytics )\r\n"
									."$"."kml_out	=	'../out/kml/';\r\n$"."vs1_out	=	'../out/vs1/';"
									"\r\n\r\n date_default_timezone_set('GMT+0');");
if($AD_CF_FI_Re)
{echo "<tr><td>Success..........</td><td>Add Footer Information Info</td></tr>";}
else{
echo "<tr><td>Failure..........</td><td>Adding Footer Information </td></tr>";}

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