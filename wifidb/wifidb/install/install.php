<?php
include('../lib/database.inc.php');
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
<td style="background-color: #A9C6FA;width: 80%;vertical-align: top;" align="center"><br>

<table border="1"><tr class="style4"><th>Status</th><th>Step of Install</th></tr>
<?php
	#========================================================================================================================#
	#													Gather the needed infomation								   	     #
	#========================================================================================================================#
$timezn = 'GMT+0';
date_default_timezone_set($timezn);
$date = date("Y-m-d");
$root_sql_user	=	addslashes(strip_tags($_POST['root_sql_user']));

$root_sql_pwd	=	addslashes(strip_tags($_POST['root_sql_pwd']));

$root			=	addslashes(strip_tags($_POST['root']));

$hosturl		=	addslashes(strip_tags($_POST['hosturl']));

$sqlhost		=	addslashes(strip_tags($_POST['sqlhost']));

$sqlu			=	addslashes(strip_tags($_POST['sqlu']));

$sqlp			=	addslashes(strip_tags($_POST['sqlp']));

$wifi			=	addslashes(strip_tags($_POST['wifidb']));

$wifi_st		=	addslashes(strip_tags($_POST['wifistdb']));
if(isset($_POST['daemon'])){$daemon = $_POST['daemon'];}else{$daemon = "off";}
$daemon			=	addslashes(strip_tags($daemon));

if($daemon == "on")
{
	$daemon = 1;
	$tools_dir		=	addslashes(strip_tags($_POST['tools']));
}else
{
	$daemon = 0;
	$tools_dir		=	"NO PATH";
}

echo '<tr class="style4"><TH colspan="2">Database Install</TH><tr>';
	#========================================================================================================================#
	#													Connect to MySQL with Root											 #
	#									and remove any existing databases and replace with empty ones						 #
	#========================================================================================================================#
$conn = mysql_connect($sqlhost, $root_sql_user, $root_sql_pwd);
$ENG = "InnoDB";
#drop exisiting db if it is there and create a new one [this is the install after all / not the upgrade]
$sqls0 =	"DROP DATABASE `$wifi_st`";
$sqls1 =	"CREATE DATABASE `$wifi_st`";
$RE_DB_ST_Re = mysql_query($sqls0, $conn);
$RE_DB_ST_Re = mysql_query($sqls1, $conn) or die(mysql_error());

if($RE_DB_ST_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>DROP DATABASE <b>`$wifi_st`</b>; "
		."CREATE DATABASE IF NOT EXISTS <b>`$wifi_st`.</b></td></tr>";}
else{
	echo "<tr class=\"bad\"><td>Failure..........</td><td>DROP DATABASE <b>`$wifi_st`</b>; "
		."CREATE DATABASE IF NOT EXISTS <b>`$wifi_st`.</b></td></tr>";}

#same thing for the ST db
$sqls0 =	"DROP DATABASE `$wifi`";
$sqls1 =	"CREATE DATABASE `$wifi`";
$sqls2 =	"USE $wifi";
$wifi_WF_Re = mysql_query($sqls0, $conn);
$wifi_WF_Re = mysql_query($sqls1, $conn) or die(mysql_error());
$wifi_WF_Re = mysql_query($sqls2, $conn) or die(mysql_error());

if($wifi_WF_Re)
{	echo "<tr class=\"good\"><td>Success..........</td><td>DROP DATABASE <b>`$wifi`</b>; "
		."CREATE DATABASE <b>`$wifi`.</b></td></tr>";}
else{
	echo "<tr class=\"bad\"><td>Failure..........</td><td>DROP DATABASE <b>`$wifi`</b>; "
		."CREATE DATABASE <b>`$wifi`.</b></td></tr>";}

	#========================================================================================================================#
	#									Create the Settings table and populate it									   	     #
	#========================================================================================================================#
#create Settings table
$sqls =	"CREATE TABLE IF NOT EXISTS `$wifi`.`settings` ("
		."`id` int(255) NOT NULL auto_increment,"
		."`table` varchar(25) NOT NULL,"
		."`size` int(254) default NULL,"
		."UNIQUE KEY `table` (`table`),"
		."KEY `id` (`id`)"
		.") ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1;";
$CR_TB_SE_Re = mysql_query($sqls, $conn) or die(mysql_error());


if($CR_TB_SE_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>CREATE TABLE <b>`$wifi`</b>.`settings`</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>CREATE TABLE <b>`$wifi`</b>.`settings`</td></tr>";}

#insert data into the settings table
$sqls =	"INSERT INTO `$wifi`.`settings` (`id`, `table`, `size`) VALUES (0, 'wifi0', 0);";
$IN_TB_SE_Re = mysql_query($sqls, $conn) or die(mysql_error());

if($IN_TB_SE_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>INSERT INTO <b>`$wifi`</b>.`settings`</td></tr>";}
else{echo "<tr class=\"bad\"><td>Failure..........</td><td>INSERT INTO <b>`$wifi`</b>.`settings`</td></tr>";}

	#========================================================================================================================#
	#													Create Users table											   	     #
	#========================================================================================================================#
#create users table (History for imports)
$sqls =	"CREATE TABLE IF NOT EXISTS `$wifi`.`users` (
		`id` INT( 255 ) NOT NULL AUTO_INCREMENT,
		`username` VARCHAR( 25 ) NOT NULL,
		`points` TEXT NOT NULL,
		`notes` TEXT NOT NULL,
		`title` VARCHAR ( 32 ) NOT NULL,
		`date` VARCHAR ( 25 ) NOT NULL, 
		`aps` INT NOT NULL, 
		`gps` INT NOT NULL,
		INDEX ( `id` )) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;";
$CR_TB_US_Re = mysql_query($sqls, $conn) or die(mysql_error());

if($CR_TB_US_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>CREATE TABLE <b>`$wifi`</b>.`users`</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>CREATE TABLE <b>`$wifi`</b>.`users`</td></tr>";}

	#========================================================================================================================#
	#													Create WiFi Pointers table									   	     #
	#========================================================================================================================#
#Create Wifi0 table (Pointers to _ST tables
$sqls =	"CREATE TABLE IF NOT EXISTS `$wifi`.`wifi0` ("
  ."  id int(255) NOT NULL AUTO_INCREMENT PRIMARY KEY, "
  ."  ssid varchar(32) NOT NULL,"
  ."  mac varchar(25) NOT NULL,"
  ."  chan varchar(2) NOT NULL,"
  ."  sectype varchar(1) NOT NULL,"
  ."  radio varchar(1) NOT NULL,"
  ."  auth varchar(25) NOT NULL,"
  ."  encry varchar(25) NOT NULL,"
  ."  KEY id (id) "
  .") ENGINE=InnoDB 
  DEFAULT CHARSET=utf8 
  AUTO_INCREMENT=1 ;";
$CR_TB_W0_Re = mysql_query($sqls, $conn) or die(mysql_error());

if($CR_TB_W0_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>CREATE TABLE <b>`$wifi`</b>.`wifi0`</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>CREATE TABLE <b>`$wifi`</b>.`wifi0`</td></tr>";}

	#========================================================================================================================#
	#													Create links table and populate								   	     #
	#========================================================================================================================#
#Create Links table
$sqls =	"CREATE TABLE IF NOT EXISTS `$wifi`.`links` ("
	."`ID` int(255) NOT NULL auto_increment,"
	."`links` varchar(255) NOT NULL,"
	."KEY `INDEX` (`ID`)"
	.") ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=9 ;";
$CR_TB_LN_Re = mysql_query($sqls, $conn) or die(mysql_error());

if($CR_TB_LN_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>CREATE TABLE <b>`$wifi`</b>.`links`</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>CREATE TABLE <b>`$wifi`</b>.`links`</td></tr>";}


#Insert data into links table
if($hosturl !== "" && $root !== "")
{
	$sqls =	"INSERT INTO `links` (`ID`, `links`) VALUES"
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
	$sqls =	"INSERT INTO `links` (`ID`, `links`) VALUES"
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
	$sqls =	"INSERT INTO `links` (`ID`, `links`) VALUES"
		."(1, '<a class=\"links\" href=\"/wifidb\">Main Page</a>'),"
		."(2, '<a class=\"links\" href=\"/wifidb/all.php?sort=SSID&ord=ASC&from=0&to=100\">View All APs</a>'),"
		."(3, '<a class=\"links\" href=\"/wifidb/import/\">Import</a>'),"
		."(4, '<a class=\"links\" href=\"/wifidb/opt/export.php?func=index\">Export</a>'),"
		."(5, '<a class=\"links\" href=\"/wifidb/opt/search.php\">Search</a>'),"
		."(6, '<a class=\"links\" href=\"/wifidb/opt/userstats.php?func=allusers\">View All Users</a>'),"
		."(7, '<a class=\"links\" href=\"/wifidb/ver.php\">WiFiDB Version</a>'),"
		."(8, '<a class=\"links\" href=\"/wifidb/announce.php?func=allusers\">Announcements</a>')";
}
$IN_TB_LN_Re = mysql_query($sqls, $conn) or die(mysql_error());

if($IN_TB_LN_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>INSERT INTO <b>`$wifi`</b>.`links`</td></tr>";}
else{echo "<tr class=\"bad\"><td>Failure..........</td><td>INSERT INTO <b>`$wifi`</b>.`links`</td></tr>";}

$sql1 = "CREATE TABLE IF NOT EXISTS `$wifi`.`annunc-comm` (
		`id` INT NOT NULL AUTO_INCREMENT ,
		`author` VARCHAR( 32 ) NOT NULL ,
		`title` VARCHAR( 120 ) NOT NULL ,
		`body` TEXT NOT NULL ,
		`date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,
		PRIMARY KEY ( `id` ) ,
		INDEX ( `id` ) ,
		UNIQUE (`title` )
		) ENGINE = InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ";

$insert = mysql_query($sql1, $conn) or die(mysql_error());

if($insert)
{echo "<tr class=\"good\"><td>Success..........</td><td>Create Announcement Comments table <b>`$wifi`</b>.`annunc-comm`;</td></tr> ";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Create Announcement Comments table <b>`$wifi`</b>.`annunc-comm`;</td></tr> ";
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
		) ENGINE = InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ";
$insert = mysql_query($sql1, $conn) or die(mysql_error());
if($insert)
{echo "<tr class=\"good\"><td>Success..........</td><td>Create Announcements table <b>`$wifi`</b>.`annunc`;</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Create Announcements table <b>`$wifi`</b>.`annunc`; </td></tr>";
}

$sql1 = "CREATE TABLE IF NOT EXISTS `$wifi`.`files` (
		`id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY ,
		`file` VARCHAR ( 255 ) NOT NULL ,
		`date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,
		`size` VARCHAR( 12 ) NOT NULL ,
		`aps` INT NOT NULL ,
		`gps` INT NOT NULL ,
		`hash` VARCHAR( 255 ) NOT NULL,
		`user_row` INT NOT NULL ,
		`user` VARCHAR ( 32 ) NOT NULL,
		`notes` TEXT NOT NULL,
		`title` VARCHAR ( 128 ) NOT NULL,
		UNIQUE ( `file` )
		) ENGINE = InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1";
$insert = mysql_query($sql1, $conn) or die(mysql_error());
if($insert)
{echo "<tr class=\"good\"><td>Success..........</td><td>Create Files table <b>`$wifi`</b>.`files`;</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Create Files table <b>`$wifi`</b>.`files`;</td></tr> ";
}


$sql1 = "CREATE TABLE IF NOT EXISTS `$wifi`.`files_tmp` (
		`id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY ,
		`file` VARCHAR( 255 ) NOT NULL ,
		`user` VARCHAR ( 32 ) NOT NULL,
		`notes` TEXT NOT NULL,
		`title` VARCHAR ( 128 ) NOT NULL,
		`size` VARCHAR( 12 ) NOT NULL ,
		`date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,
		`hash` VARCHAR ( 255 ) NOT NULL,
		`importing` BOOL NOT NULL,
		`ap` VARCHAR ( 32 ) NOT NULL,
		`tot` VARCHAR ( 128 ) NOT NULL,
		`row` INT ( 255 ) NOT NULL,
		UNIQUE ( `file` )
		) ENGINE = $ENG  DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ";
$insert = mysql_query($sql1, $conn) or die(mysql_error());
if($insert)
{echo "<tr class=\"good\"><td>Success..........</td><td>Create tmp File table <b>`$wifi`</b>.`files`;</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Create tmp Files table <b>`$wifi`</b>.`files`;</td></tr> ";
}
	#========================================================================================================================#
	#									Create WiFiDB user for WiFi and WiFi_st										   	     #
	#========================================================================================================================#
if ($sqlhost !== 'localhost' or $sqlhost !== "127.0.0.1")
{$phphost = 'localhost';}
else{$phphost	=	$_POST['phphost'];}

#create WifiDB user in  WIFI
$sqls =	"GRANT ALL PRIVILEGES ON $wifi.* TO '$sqlu'@'$phphost' IDENTIFIED BY '$sqlp';";
$GR_US_WF_Re = mysql_query($sqls, $conn) or die(mysql_error());

if($GR_US_WF_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>Created user: $sqlu @ $phphost for <b>`$wifi`</b></td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Created user: $sqlu @ $phphost for <b>`$wifi`</b></td></tr>";
}

#create WifiDB user in  WIFI_ST
$sqls =	"GRANT ALL PRIVILEGES ON $wifi_st.* TO '$sqlu'@'$phphost' IDENTIFIED BY '$sqlp';";
$GR_US_ST_Re = mysql_query($sqls, $conn) or die(mysql_error());

if($GR_US_WF_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>Created user: $sqlu @ $phphost for <b>`$wifi_st`</b></td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Created user: $sqlu @ $phphost for <b>`$wifi_st`</b></td></tr>";}


	#========================================================================================================================#
	#											Create the Config.inc.php file										   	     #
	#========================================================================================================================#
#create config.inc.php file in /lib folder
echo '<tr><TH colspan="2"></th></tr><tr class="style4"><TH colspan="2">Config.inc.php File Creation</th><tr>';
$file_ext = 'config.inc.php';
$filename = '../lib/'.$file_ext;
$filewrite = fopen($filename, "w");
$fileappend = fopen($filename, "a");

if($filewrite)
{echo "<tr class=\"good\"><td>Success..........</td><td>Created Config file</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Creating Config file</td></tr>";}


#Add last edit date
$CR_CF_FL_Re = fwrite($fileappend, "<?php \r\nglobal $"."conn, $"."wifidb_tools, $"."daemon\r\ndate_default_timezone_set('$timezn');\r\n$"."lastedit	=	'$date';\r\n\r\n");

if($CR_CF_FL_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>Add Install date</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Add Install date</td></tr>";}


#add default debug values
$AD_CF_DG_Re = fwrite($fileappend, "#---------------- Daemon Info ----------------#\r\n"
									."$"."daemon	=	".$daemon.";\r\n"
									."$"."debug			=	$debug;\r\n"
									."$"."log_level		=	$loglev;\r\n");

if($AD_CF_DG_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>Add default daemon values</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Add default daemon values</td></tr>";}


#add default debug values
$AD_CF_DG_Re = fwrite($fileappend, "#---------------- Debug Info ----------------#\r\n"
									."$"."rebuild		=	0;\r\n"
									."$"."debug			=	0;\r\n"
									."$"."bench			=	0;\r\n");

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
									."$"."settings_tb 	=	'settings';\r\n"
									."$"."users_tb 		=	'users';\r\n"
									."$"."links 			=	'links';\r\n"
									."$"."wtable 		=	'wifi0';\r\n"
									."$"."gps_ext 		=	'_GPS';\r\n"
									."$"."sep 			=	'-';\r\n\r\n");
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

	#========================================================================================================================#
	#													Install has finished										   	     #
	#========================================================================================================================#
fclose($fileappend);
fclose($filewrite);
echo "</table>";
echo "<h2>Install is Finished, if all was Successfull you may now remove the Install Folder</h2>";
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
	</html>