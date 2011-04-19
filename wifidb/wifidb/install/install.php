<?php
global $screen_output, $install;
$screen_output = 'CLI';
$install = "installing";
include('../lib/database.inc.php');
global $wifidb_smtp, $wifidb_email_updates, $reserved_users, $login_seed;
echo '<title>Wireless DataBase *Alpha* '.$ver["wifidb"].' --> Install Page</title>';


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


?>
<link rel="stylesheet" href="../themes/wifidb/styles.css">
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
<td style="background-color: #A9C6FA;width: 80%;vertical-align: top;" align="center"><br>

<table border="1">
<tr class="style4"><TH colspan="2">Install WiFiDB <?php echo $ver["wifidb"]; ?></TH></tr>
<tr class="style4"><th>Status</th><th>Step of Install</th></tr>
<?php


if($_POST['daemon'] == TRUE && $_POST['toolsdir'] == "")
{
	echo "<h2>You cannot enable the daemon and not declare a folder for the tools directory. now go back and do it right.</h2>";
	$filename = $_SERVER['SCRIPT_FILENAME'];
	$file_ex = explode("/", $filename);
	$count = count($file_ex);
	$file = $file_ex[($count)-1];
	?>
	</p>
	</td>
	</tr>
	<tr>
	<td bgcolor="#315573" height="23"><a href="../img/moon.png"><img border="0" src="../img/moon_tn.png"></a></td>
	<td bgcolor="#315573" width="0" align="center">
	<?php
	if (file_exists($filename)) {?>
		<h6><i><u><?php echo $file;?></u></i> was last modified:  <?php echo date ("Y F d @ H:i:s", filemtime($filename));?></h6>
	<?php
	}
	?>
	</td>
	</tr>
	</table>
	</body>
	</html>
	<?php
	die();
}
	#========================================================================================================================#
	#													Gather the needed infomation								   	     #
	#========================================================================================================================#
$Local_tz=date_default_timezone_get();
$date = date("Y-m-d");

$root_sql_user	=	addslashes(strip_tags($_POST['root_sql_user']));
$root_sql_pwd	=	addslashes(strip_tags($_POST['root_sql_pwd']));
$root			=	addslashes(strip_tags($_POST['root']));
$hosturl		=	addslashes(strip_tags($_POST['hosturl']));
$sqlhost		=	addslashes(strip_tags($_POST['sqlhost']));
$sqlu			=	addslashes(strip_tags($_POST['sqlu']));
$sqlp			=	addslashes(strip_tags($_POST['sqlp']));
$wifi			=	addslashes(strip_tags($_POST['wifi']));
$wifi_st		=	addslashes(strip_tags($_POST['wifist']));
$theme			=	addslashes(strip_tags($_POST['theme']));
$password		=	addslashes(strip_tags($_POST['wdb_admn_pass']));
$email			=	addslashes(strip_tags($_POST['wdb_admn_emailadrs']));
$wifidb_from	=	addslashes(strip_tags($_POST['wdb_from_emailadrs']));
$wifidb_from_pass	=	addslashes(strip_tags($_POST['wdb_from_pass']));
$wifidb_smtp	=	addslashes(strip_tags($_POST['wdb_smtp']));
$timeout	=   "(86400 * 365)";
$reserved_users	=	'WiFiDB:Recovery';

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

if($hosturl == '')
{
	$hosturl = (@$_SERVER["SERVER_NAME"]!='' ? $_SERVER["SERVER_NAME"] : $_SERVER["SERVER_ADDR"]);
}else
{
	$count = count($hosturl)-1;
	if($hosturl[$count] != '/')
	{
		$hosturl = $hosturl.'/';
	}
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

echo '<tr class="style4"><TH colspan="2">Database Install</TH></tr>';
	#========================================================================================================================#
	#													Connect to MySQL with Root											 #
	#									and remove any existing databases and replace with empty ones						 #
	#========================================================================================================================#
$conn = mysql_connect($sqlhost, $root_sql_user, $root_sql_pwd);
$ENG = "INNODB";
################################## drop exisiting db if it is there and create a new one [this is the install after all / not the upgrade]
$sqls0 =	"DROP DATABASE IF EXISTS `$wifi_st`";
$wifi_st_WF_drp = mysql_query($sqls0, $conn);
if($wifi_st_WF_drp)
{	
	echo "<tr class=\"good\"><td>Success..........</td><td>CREATE DATABASE <b>`$wifi`.</b></td></tr>";
}
else
{
	echo "<tr class=\"bad\"><td>Failure..........</td><tdCREATE DATABASE <b>`$wifi`.</b><br>".mysql_error($conn)."</td></tr>";
}
$sqls1 =	"CREATE DATABASE IF NOT EXISTS `$wifi_st`";
$wifi_st_WF_Re = mysql_query($sqls1, $conn);
if($wifi_st_WF_Re)
{	
	echo "<tr class=\"good\"><td>Success..........</td><td>CREATE DATABASE <b>`$wifi`.</b></td></tr>";
}
else
{
	echo "<tr class=\"bad\"><td>Failure..........</td><tdCREATE DATABASE <b>`$wifi`.</b><br>".mysql_error($conn)."</td></tr>";
}

####################### same thing for the ST db
$sqls0 =	"DROP DATABASE IF EXISTS `$wifi`";
$wifi_WF_Re = mysql_query($sqls0, $conn);
if($wifi_WF_Re)
{	
	echo "<tr class=\"good\"><td>Success..........</td><td>CREATE DATABASE <b>`$wifi`.</b></td></tr>";
}
else
{
	echo "<tr class=\"bad\"><td>Failure..........</td><tdCREATE DATABASE <b>`$wifi`.</b><br>".mysql_error($conn)."</td></tr>";
}
$sqls1 =	"CREATE DATABASE IF NOT EXISTS `$wifi`";
$wifi_WF_Re = mysql_query($sqls1, $conn);
if($wifi_WF_Re)
{	
	echo "<tr class=\"good\"><td>Success..........</td><td>CREATE DATABASE <b>`$wifi`.</b></td></tr>";
}
else
{
	echo "<tr class=\"bad\"><td>Failure..........</td><tdCREATE DATABASE <b>`$wifi`.</b><br>".mysql_error($conn)."</td></tr>";
}

if ($sqlhost == 'localhost' or $sqlhost == "127.0.0.1")
{$phphost = 'localhost';}
else{$phphost	=	$_SERVER['SERVER_ADDR'];}

#create wifi
$sqls =	"GRANT ALL PRIVILEGES ON $wifi.* TO '$root_sql_user'@'$phphost' IDENTIFIED BY '$root_sql_pwd';";
$GR_US_WF_Re = mysql_query($sqls, $conn);

if($GR_US_WF_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>Created user: $sqlu @ $phphost for <b>`$wifi`</b></td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Created user: $sqlu @ $phphost for <b>`$wifi`</b><br>".mysql_error($conn)."</td></tr>";
}

#create WIFI_ST
$sqls =	"GRANT ALL PRIVILEGES ON $wifi_st.* TO '$root_sql_user'@'$phphost' IDENTIFIED BY '$root_sql_pwd';";
$GR_US_ST_Re = mysql_query($sqls, $conn);

if($GR_US_WF_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>Created user: $sqlu @ $phphost for <b>`$wifi_st`</b></td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Created user: $sqlu @ $phphost for <b>`$wifi_st`</b><br>".mysql_error($conn)."</td></tr>";}


	#========================================================================================================================#
	#									Create the Settings table and populate it									   	     #
	#========================================================================================================================#
############################## create Settings table
$sqls =	"CREATE TABLE IF NOT EXISTS `$wifi`.`settings` ("
		."`id` int(255) NOT NULL auto_increment,"
		."`table` varchar( 25 ) NOT NULL,"
		."`size` varchar( 254 ) default NULL,"
		."UNIQUE (`table`),"
		."KEY `id` ( `id` )"
		.") ENGINE=$ENG DEFAULT CHARSET=utf8 AUTO_INCREMENT=1;";
$CR_TB_SE_Re = mysql_query($sqls, $conn);


if($CR_TB_SE_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>CREATE TABLE <b>`$wifi`</b>.`settings`</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>CREATE TABLE <b>`$wifi`</b>.`settings`<br>".mysql_error($conn)."</td></tr>";}

########################## insert data into the settings table
$sqls =	"INSERT INTO `$wifi`.`settings` (`id`, `table`, `size`) VALUES ('1', 'wifi0', '0');";
$IN_TB_SE_Re = mysql_query($sqls, $conn);

if($IN_TB_SE_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>INSERT INTO <b>`$wifi`</b>.`settings`</td></tr>";}
else{echo "<tr class=\"bad\"><td>Failure..........</td><td>INSERT INTO <b>`$wifi`</b>.`settings`<br>".mysql_error($conn)."</td></tr>";}

###################### insert data into the settings table
$datetime = date("Y-m-d H:i:s");
$sqls =	"INSERT INTO `$wifi`.`settings` (`id`, `table`, `size`) VALUES ('2', 'files', '$datetime');";
$IN_TB_SE_Re = mysql_query($sqls, $conn);

if($IN_TB_SE_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>INSERT INTO <b>`$wifi`</b>.`settings`</td></tr>";}
else{echo "<tr class=\"bad\"><td>Failure..........</td><td>INSERT INTO <b>`$wifi`</b>.`settings`<br>".mysql_error($conn)."</td></tr>";}

	#========================================================================================================================#
	#													Create Users table											   	     #
	#========================================================================================================================#
################################## create users table (History for imports)
$sqls =	"CREATE TABLE IF NOT EXISTS `$wifi`.`users_imports` (
		`id` INT( 255 ) NOT NULL AUTO_INCREMENT,
		`username` VARCHAR( 255 ) NOT NULL,
		`points` TEXT NOT NULL,
		`notes` TEXT NOT NULL,
		`title` VARCHAR ( 255 ) NOT NULL,
		`date` VARCHAR ( 25 ) NOT NULL, 
		`aps` INT NOT NULL, 
		`gps` INT NOT NULL,
		`hash` VARCHAR( 255 ) NOT NULL,
		INDEX ( `id` )) ENGINE=$ENG DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;";
$CR_TB_US_Re = mysql_query($sqls, $conn);

if($CR_TB_US_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>CREATE TABLE <b>`$wifi`</b>.`users`</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>CREATE TABLE <b>`$wifi`</b>.`users`<br>".mysql_error($conn)."</td></tr>";}

	#========================================================================================================================#
	#													Create WiFi Pointers table									   	     #
	#========================================================================================================================#
########################## Create Wifi0 table (Pointers to *_ST tables)
$sqls =	"CREATE TABLE IF NOT EXISTS `$wifi`.`wifi0`
(
    `id` int(255) NOT NULL AUTO_INCREMENT PRIMARY KEY, 
    `ssid` varchar(32) NOT NULL,
    `mac` varchar(25) NOT NULL,
    `chan` varchar(3) NOT NULL,
    `sectype` varchar(1) NOT NULL,
    `radio` varchar(1) NOT NULL,
    `auth` varchar(25) NOT NULL,
    `encry` varchar(25) NOT NULL,
    `countrycode` VARCHAR( 5 ) NOT NULL,
    `countryname` VARCHAR( 64 ) NOT NULL,
    `admincode` VARCHAR( 5 ) NOT NULL,
    `adminname` VARCHAR( 64 ) NOT NULL,
    `iso3166-2` VARCHAR( 3 ) NOT NULL,
    `lat` VARCHAR( 32 ) NOT NULL DEFAULT 'N 0.0000',
    `long` VARCHAR( 32 ) NOT NULL DEFAULT 'E 0.0000',
    `active` tinyint(1) NOT NULL DEFAULT 0,
    INDEX (`id`)) ENGINE=$ENG DEFAULT CHARSET=utf8 AUTO_INCREMENT=1";
$CR_TB_W0_Re = mysql_query($sqls, $conn);

if($CR_TB_W0_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>CREATE TABLE <b>`$wifi`</b>.`wifi0`</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>CREATE TABLE <b>`$wifi`</b>.`wifi0`<br>".mysql_error($conn)."</td></tr>";}

	#========================================================================================================================#
	#													Create links table and populate								   	     #
	#========================================================================================================================#
################## Create Links table
$sqls =	"CREATE TABLE IF NOT EXISTS `$wifi`.`links` ("
	."`ID` int(255) NOT NULL auto_increment,"
	."`links` varchar(255) NOT NULL,"
	."KEY `INDEX` (`ID`)"
	.") ENGINE=$ENG DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;";
$CR_TB_LN_Re = mysql_query($sqls, $conn);

if($CR_TB_LN_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>CREATE TABLE <b>`$wifi`</b>.`links`</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>CREATE TABLE <b>`$wifi`</b>.`links`<br>".mysql_error($conn)."</td></tr>";}


#$$$$$$$$$$$$$##################### Insert data into links table
if($hosturl !== "" && $root !== "")
{
	$sqls =	"INSERT INTO `$wifi`.`links` (`ID`, `links`) VALUES"
		."(1, '<a class=\"links\" href=\"$hosturl/$root/\">Main Page</a>'),"
		."(2, '<a class=\"links\" href=\"$hosturl/$root/all.php?sort=SSID&ord=ASC&from=0&to=100\">View All APs</a>'),"
		."(3, '<a class=\"links\" href=\"$hosturl/$root/import/\">Import</a>'),"
		."(4, '<a class=\"links\" href=\"$hosturl/$root/opt/export.php?func=index\">Export</a>'),"
		."(5, '<a class=\"links\" href=\"$hosturl/$root/opt/search.php\">Search</a>'),"
		."(6, '<a class=\"links\" href=\"$hosturl/$root/opt/userstats.php?func=allusers\">View All Users</a>'),"
		."(7, '<a class=\"links\" href=\"$hosturl/$root/ver.php\">WiFiDB Version</a>'),"
		."(8, '<a class=\"links\" href=\"$hosturl/$root/announce.php?func=allusers\">Announcements</a>')";
}elseif($root !== "")
{ 
	$sqls =	"INSERT INTO `$wifi`.`links` (`ID`, `links`) VALUES"
		."(1, '<a class=\"links\" href=\"/$root/\">Main Page</a>'),"
		."(2, '<a class=\"links\" href=\"/$root/all.php?sort=SSID&ord=ASC&from=0&to=100\">View All APs</a>'),"
		."(3, '<a class=\"links\" href=\"/$root/import/\">Import</a>'),"
		."(4, '<a class=\"links\" href=\"/$root/opt/export.php?func=index\">Export</a>'),"
		."(5, '<a class=\"links\" href=\"/$root/opt/search.php\">Search</a>'),"
		."(6, '<a class=\"links\" href=\"/$root/opt/userstats.php?func=allusers\">View All Users</a>'),"
		."(7, '<a class=\"links\" href=\"/$root/ver.php\">WiFiDB Version</a>'),"
		."(8, '<a class=\"links\" href=\"/$root/announce.php?func=allusers\">Announcements</a>')";
}else
{
	$sqls =	"INSERT INTO `$wifi`.`links` (`ID`, `links`) VALUES"
		."(1, '<a class=\"links\" href=\"/wifidb\">Main Page</a>'),"
		."(2, '<a class=\"links\" href=\"/wifidb/all.php?sort=SSID&ord=ASC&from=0&to=100\">View All APs</a>'),"
		."(3, '<a class=\"links\" href=\"/wifidb/import/\">Import</a>'),"
		."(4, '<a class=\"links\" href=\"/wifidb/opt/export.php?func=index\">Export</a>'),"
		."(5, '<a class=\"links\" href=\"/wifidb/opt/search.php\">Search</a>'),"
		."(6, '<a class=\"links\" href=\"/wifidb/opt/userstats.php?func=allusers\">View All Users</a>'),"
		."(7, '<a class=\"links\" href=\"/wifidb/ver.php\">WiFiDB Version</a>'),"
		."(8, '<a class=\"links\" href=\"/wifidb/announce.php?func=allusers\">Announcements</a>')";
}
$IN_TB_LN_Re = mysql_query($sqls, $conn);

if($IN_TB_LN_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>INSERT INTO <b>`$wifi`</b>.`links`</td></tr>";}
else{echo "<tr class=\"bad\"><td>Failure..........</td><td>INSERT INTO <b>`$wifi`</b>.`links`<br>".mysql_error($conn)."</td></tr>";}
###################################### Announce Comments Table
$sql1 = "CREATE TABLE IF NOT EXISTS `$wifi`.`annunc-comm` (
		`id` INT NOT NULL AUTO_INCREMENT ,
		`author` VARCHAR( 32 ) NOT NULL ,
		`title` VARCHAR( 255 ) NOT NULL ,
		`body` TEXT NOT NULL ,
		`date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,
		PRIMARY KEY ( `id` ) ,
		INDEX ( `id` )
		) ENGINE = $ENG DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ";

$insert = mysql_query($sql1, $conn);

if($insert)
{echo "<tr class=\"good\"><td>Success..........</td><td>Create Announcement Comments table <b>`$wifi`</b>.`annunc-comm`;</td></tr> ";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Create Announcement Comments table <b>`$wifi`</b>.`annunc-comm`;<br>".mysql_error($conn)."</td></tr> ";
}
#$################################################### Announce Table
$sql1 = "CREATE TABLE IF NOT EXISTS `$wifi`.`annunc` (
		`id` INT NOT NULL AUTO_INCREMENT ,
		`auth` VARCHAR( 32 ) NOT NULL DEFAULT 'Annon Coward',
		`title` VARCHAR( 255 ) NOT NULL DEFAULT 'Blank',
		`date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,
		`body` TEXT NOT NULL ,
		`comments` TEXT NOT NULL ,
		PRIMARY KEY ( `id` ) ,
		INDEX ( `id` ) ,
		UNIQUE ( `title` )
		) ENGINE = $ENG DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ";
$insert = mysql_query($sql1, $conn);
if($insert)
{echo "<tr class=\"good\"><td>Success..........</td><td>Create Announcements table <b>`$wifi`</b>.`annunc`;</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Create Announcements table <b>`$wifi`</b>.`annunc`;<br>".mysql_error($conn)." </td></tr>";
}


#$################################################### Announce Table
$sql1 = "CREATE TABLE `wifi`.`validate_table` (
	`id` INT( 255 ) NOT NULL AUTO_INCREMENT ,
	`username` VARCHAR( 255 ) NOT NULL ,
	`code` VARCHAR( 64 ) NOT NULL ,
	`date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,
	UNIQUE (`username`),
	INDEX ( `id` )
	) ENGINE = $ENG DEFAULT CHARSET=utf8 AUTO_INCREMENT=1";
$insert = mysql_query($sql1, $conn);
if($insert)
{echo "<tr class=\"good\"><td>Success..........</td><td>Create email validation table <b>`$wifi`</b>.`validation_table`;</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Create email validation table <b>`$wifi`</b>.`validation_table`;<br>".mysql_error($conn)." </td></tr>";
}

############################################## Finished Files Table
$sql1 = "CREATE TABLE IF NOT EXISTS `$wifi`.`files` (
		`id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY ,
		`file` VARCHAR ( 255 ) NOT NULL ,
		`date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,
		`size` VARCHAR( 12 ) NOT NULL ,
		`aps` INT NOT NULL ,
		`gps` INT NOT NULL ,
		`hash` VARCHAR( 255 ) NOT NULL,
		`user_row` INT NOT NULL ,
		`user` VARCHAR ( 255 ) NOT NULL,
		`notes` TEXT NOT NULL,
		`title` VARCHAR ( 255 ) NOT NULL,
		UNIQUE ( `file` )
		) ENGINE = $ENG DEFAULT CHARSET=utf8 AUTO_INCREMENT=1";
$insert = mysql_query($sql1, $conn);
if($insert)
{echo "<tr class=\"good\"><td>Success..........</td><td>Create Files table <b>`$wifi`</b>.`files`;</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Create Files table <b>`$wifi`</b>.`files`;<br>".mysql_error($conn)."</td></tr> ";
}

############################################### Files Temp Table
$sql1 = "CREATE TABLE IF NOT EXISTS `$wifi`.`files_tmp` (
		`id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY ,
		`file` VARCHAR( 255 ) NOT NULL ,
		`user` VARCHAR ( 255 ) NOT NULL,
		`notes` TEXT NOT NULL,
		`title` VARCHAR ( 255 ) NOT NULL,
		`size` VARCHAR( 12 ) NOT NULL ,
		`date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,
		`hash` VARCHAR ( 255 ) NOT NULL,
		`importing` BOOL NOT NULL,
		`ap` VARCHAR ( 32 ) NOT NULL,
		`tot` VARCHAR ( 128 ) NOT NULL,
		`row` INT ( 255 ) NOT NULL,
		UNIQUE ( `file` )
		) ENGINE = $ENG  DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ";
$insert = mysql_query($sql1, $conn);
if($insert)
{echo "<tr class=\"good\"><td>Success..........</td><td>Create tmp File table <b>`$wifi`</b>.`files`;</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Create tmp Files table <b>`$wifi`</b>.`files`;<br>".mysql_error($conn)."</td></tr> ";
}
############################################# Share Waypoints
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
) ENGINE=$ENG  DEFAULT CHARSET=utf8 AUTO_INCREMENT=1";
$insert = mysql_query($sql1, $conn);
if($insert)
{echo "<tr class=\"good\"><td>Success..........</td><td>Create Shared Geocaches table <b>`$wifi`</b>.`share_waypoints`;</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>To create Shared Geocaches table <b>`$wifi`</b>.`share_waypoints`;<br>".mysql_error($conn)."</td></tr> ";
}
############################################ Daemon Perf Monitor
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
) ENGINE=$ENG DEFAULT CHARSET=utf8 AUTO_INCREMENT=1";
$insert = mysql_query($sql1, $conn);
if($insert)
{echo "<tr class=\"good\"><td>Success..........</td><td>Create Daemon Performance table <b>`$wifi`</b>.`daemon_perf_mon`;</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>To create Daemon Performance table <b>`$wifi`</b>.`daemon_perf_mon`;<br>".mysql_error($conn)."</td></tr> ";
}

########################################## DB_stats
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
) ENGINE = $ENG DEFAULT CHARSET=utf8 AUTO_INCREMENT=1";
$insert = mysql_query($sql1, $conn);
if($insert)
{echo "<tr class=\"good\"><td>Success..........</td><td>Create DB stats table <b>`$wifi`</b>.`DB_stats`;</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>To create DB stats table <b>`$wifi`</b>.`DB_stats`;<br>".mysql_error($conn)."</td></tr> ";
}


############## Users_info
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
) ENGINE=$ENG DEFAULT CHARSET=utf8 AUTO_INCREMENT=1";
$insert = mysql_query($sql1, $conn);
if($insert)
{echo "<tr class=\"good\"><td>Success..........</td><td>Create User Login table <b>`$wifi`</b>.`user_info`;</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>To create User Login table <b>`$wifi`</b>.`user_info`;<br>".mysql_error($conn)."</td></tr> ";
}

	#========================================================================================================================#
	#									Create WiFiDB user for WiFi and WiFi_st										   	     #
	#========================================================================================================================#
#create WifiDB user in  WIFI
$sqls =	"GRANT ALL PRIVILEGES ON $wifi.* TO '$sqlu'@'$phphost' IDENTIFIED BY '$sqlp';";
$GR_US_WF_Re = mysql_query($sqls, $conn);

if($GR_US_WF_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>Created user: $sqlu @ $phphost for <b>`$wifi`</b></td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Created user: $sqlu @ $phphost for <b>`$wifi`</b><br>".mysql_error($conn)."</td></tr>";
}

#create WifiDB user in  WIFI_ST
$sqls =	"GRANT ALL PRIVILEGES ON $wifi_st.* TO '$sqlu'@'$phphost' IDENTIFIED BY '$sqlp';";
$GR_US_ST_Re = mysql_query($sqls, $conn);

if($GR_US_WF_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>Created user: $sqlu @ $phphost for <b>`$wifi_st`</b></td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Created user: $sqlu @ $phphost for <b>`$wifi_st`</b><br>".mysql_error($conn)."</td></tr>";}


	#========================================================================================================================#
	#											Create the Config.inc.php file										   	     #
	#========================================================================================================================#
?>
<tr class="style4"><TH colspan="2">Config.inc.php File Creation</th></tr>
<tr class="style4"><th>Status</th><th>Step of Install</th></tr>
<?php
$file_ext = 'config.inc.php';
$filename = '../lib/'.$file_ext;
$filewrite = fopen($filename, "w");
$fileappend = fopen($filename, "a");

if($filewrite)
{echo "<tr class=\"good\"><td>Success..........</td><td>Created Config file</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Creating Config file</td></tr>";}

function gen_key()
{
	$base			=	'ABCDEFGHKLMNOPQRSTWXYZabcdefghjkmnpqrstwxyz123456789!@#$%^&*()_+-=';
	$max			=	strlen($base)-1;
	$seed_len_gen	=	32;
	$activatecode	=	'';
	mt_srand((double)microtime()*1000000);
	while (strlen($activatecode) < $seed_len_gen+1)
	{$activatecode.=$base{mt_rand(0,$max)};}
	return $activatecode;
}

$login_seed = gen_key();

#Add last edit date and globals
if($root != ''){$wifidb_install_ = $_SERVER['DOCUMENT_ROOT'].$root;}else{$wifidb_install_ = $_SERVER['DOCUMENT_ROOT'];}
$CR_CF_FL_Re = fwrite($fileappend, "<?php
#COOKIE GLOBALS
global $"."console_refresh, $"."console_scroll, $"."console_last5, $"."default_theme, $"."default_refresh, $"."default_dst, $"."default_timezone, $"."timeout, $"."config_fails, $"."login_seed;
#SQL GLOBALS
global $"."wifidb_install, $"."conn, $"."db, $"."db_st, $"."DB_stats_table, $"."daemon_perf_table, $"."users_t, $"."user_logins_table, $"."validate_table, $"."files, $"."files_tmp, $"."annunc, $"."annunc_comm, $"."collate, $"."engine, $"."char_set;
#MISC GLOBALS
global $"."header, $"."ads, $"."tracker, $"."hosturl, $"."dim, $"."admin_email, $"."email_validation, $"."WiFiDB_LNZ_User, $"."apache_grp, $"."div, $"."wifidb_tools, $"."daemon, $"."root, $"."console_lines, $"."console_log, $"."bypass_check, $"."wifidb_email_updates, $"."wifidb_from, $"."wifidb_from_pass;

$"."lastedit	=	'$date';

#----------General Settings------------#
$"."bypass_check	=	0;
$"."wifidb_tools	=	'$toolsdir';
$"."wifidb_install	=	'$wifidb_install_';
$"."timezn			=	'$Local_tz';
$"."root			=	'$root';
$"."hosturl		=	'$hosturl';
$"."dim			=	DIRECTORY_SEPARATOR;
$"."admin_email	=	'$email';
$"."config_fails	=	3;
$"."login_seed		=	'$login_seed';
$"."wifidb_email_updates = '$wifidb_email_updates';
$"."wifidb_from	=	'$wifidb_from';
$"."wifidb_from_pass	=	'$wifidb_from_pass';
$"."wifidb_smtp		=	'';
$"."email_validation =	'$email_validation';
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
$"."console_log		= '/var/log/wifidb';\r\n\r\n");

if($AD_CF_DG_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>Add default Console values</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Add default Console values</td></tr>";}

#add default debug values
$AD_CF_DG_Re = fwrite($fileappend, "#---------------- Debug Info ----------------#
$"."rebuild	=	0;
$"."bench		=	0;
$"."debug		=	0;\r\n\r\n");

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
$"."share_cache		=	'share_waypoints';
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
$"."engine		=	'$ENG';
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
require("../lib/security.inc.php");
$sec = new security();
$create = $sec->create_user('Admin', $password, $email, $user_array=array(1,0,0,1), "", 0);
switch($create)
{
	case 1:
		echo "<tr class=\"good\"><td>Success..........</td><td>Created Default Wifidb Administrator user</td></tr>";
	break;
	
	case is_array($create):
		list($er, $msg) = $create;
		switch($er)
		{
			case "create_tb":
				echo '<tr class="bad"><td>Failure..........</td><td>'.$msg.'<BR>This is a serious error, contact Phil on the <a href="http://forum.techidiots.net/">forums</a><br>MySQL Error Message: '.$msg."<br><h1>D'oh!</h1></td></tr>";
			break;
			
			case "dup_u":
				echo '<tr class="bad"><td>Failure..........</td><td>To create Wifidb Admin User. :-(<br>MySQl Error: '.$msg.'<br><h1>Do`h!</h1></td></tr>';
			break;
		}
	break;
	
	default:
		echo "Errah... therah.. was a problem erah...";
	break;
}

	#========================================================================================================================#
	#													Install has finished										   	     #
	#========================================================================================================================#


?>
</table>
<h2>Install is Finished, if all was Successfull you may now remove the Install Folder</h2>
<?php
$timezn = 'Etc/GMT+5';
date_default_timezone_set($timezn);
$filename = $_SERVER['SCRIPT_FILENAME'];
$file_ex = explode("/", $filename);
$count = count($file_ex);
$file = $file_ex[($count)-1];
?>
</p>
</td>
</tr>
<tr>
<td bgcolor="#315573" height="23"><a href="../img/moon.png"><img border="0" src="../img/moon_tn.png"></a></td>
<td bgcolor="#315573" width="0" align="center">
<?php
if (file_exists($filename)) {?>
	<h6><i><u><?php echo $file;?></u></i> was last modified:  <?php echo date ("Y F d @ H:i:s", filemtime($filename));?></h6>
<?php
}
?>
</td>
</tr>
</table>
</body>