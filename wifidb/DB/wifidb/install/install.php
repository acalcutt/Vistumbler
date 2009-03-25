<?php
include('../lib/database.inc.php');
echo '<title>Wireless DataBase *Alpha* '.$ver["wifidb"].' --> Install Page</title>';
?>
<link rel="stylesheet" href="../css/site4.0.css">
<body topmargin="10" leftmargin="0" rightmargin="0" bottommargin="10" marginwidth="10" marginheight="10">
<div align="center">
<table border="0" width="75%" cellspacing="10" cellpadding="2">
	<tr>
		<td bgcolor="#315573">
		<p align="center"><b><font size="5" face="Arial" color="#FFFFFF">
		Wireless DataBase *Alpha* <?php echo $ver["wifidb"]; ?></font>
		<font color="#FFFFFF" size="2">
            <a class="links" href="/">[Root] </a>/ <a class="links" href="/wifidb/">[WifiDB] </a>/
		</font></b>
		</td>
	</tr>
</table>
</div>
<div align="center">
<table border="0" width="75%" cellspacing="10" cellpadding="2" height="90">
	<tr>
<td width="17%" bgcolor="#304D80" valign="top">

</td>
	<td width="80%" bgcolor="#A9C6FA" valign="top" align="center">
		<p align="center">
<?php
if($ver['wifidb'] !== "0.16 Build 1"){echo '<h1><font color="red">You must have the 0.16 Build 1 Code base.</font></h1>';footer($_SERVER['SCRIPT_FILENAME']); die();}
?>
<table border="1"><tr class="style4"><th>Status</th><th>Step of Install</th></tr>
<?php
	#========================================================================================================================#
	#													Gather the needed infomation								   	     #
	#========================================================================================================================#
	
$timezn = 'GMT+0';
date_default_timezone_set($timezn);
$date = date("Y-m-d");

$root_sql_user	=	$_POST['root_sql_user'];
strip_tags($root_sql_user);
$root_sql_pwd	=	$_POST['root_sql_pwd'];
strip_tags($root_sql_pwd);
$root		=	$_POST['root'];
strip_tags($root);
$hosturl	=	$_POST['hosturl'];
strip_tags($hosturl);
$sqlhost	=	$_POST['sqlhost'];
strip_tags($sqlhost);
$sqlu		=	$_POST['sqlu'];
strip_tags($sqlu);
$sqlp		=	$_POST['sqlp'];
strip_tags($sqlp);
$wifi		=	$_POST['wifidb'];
strip_tags($wifi);
$wifi_st	=	$_POST['wifistdb'];
strip_tags($wifi_st);
echo '<tr class="style4"><th colspan="2">Database Install</th><tr>';
	#========================================================================================================================#
	#													Connect to MySQL with Root											 #
	#									and remove any existing databases and replace with empty ones						 #
	#========================================================================================================================#
$conn = mysql_connect($sqlhost, $root_sql_user, $root_sql_pwd);

#drop exisiting db if it is there and create a new one [this is the install after all / not the upgrade]
$sqls0 =	"DROP DATABASE $wifi_st";
$sqls1 =	"CREATE DATABASE $wifi_st";
$RE_DB_ST_Re = mysql_query($sqls0, $conn);
$RE_DB_ST_Re = mysql_query($sqls1, $conn) or die(mysql_error());

if($RE_DB_ST_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>DROP DATABASE `$wifi_st`; "
		."CREATE DATABASE `$wifi_st`</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>DROP DATABASE `$wifi_st`; "
		."CREATE DATABASE `$wifi_st`</td></tr>";
}

#same thing for the ST db
$sqls0 =	"DROP DATABASE $wifi";
$sqls1 =	"CREATE DATABASE $wifi";
$sqls2 =	"USE $wifi";
$DB_WF_Re = mysql_query($sqls0, $conn);
$DB_WF_Re = mysql_query($sqls1, $conn) or die(mysql_error());
$DB_WF_Re = mysql_query($sqls2, $conn) or die(mysql_error());

if($DB_WF_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>DROP DATABASE `$wifi`; "
		."CREATE DATABASE `$wifi`</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>DROP DATABASE `$wifi`; "
		."CREATE DATABASE `$wifi`</td></tr>";
}
	#========================================================================================================================#
	#									Create the Settings table and populate it									   	     #
	#========================================================================================================================#
#create Settings table
$sqls =	"CREATE TABLE `settings` ("
		."`id` int(255) NOT NULL auto_increment,"
		."`table` varchar(25) NOT NULL,"
		."`size` int(254) default NULL,"
		."UNIQUE KEY `table` (`table`),"
		."KEY `id` (`id`)"
		.") ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1;";
$CR_TB_SE_Re = mysql_query($sqls, $conn) or die(mysql_error());


if($CR_TB_SE_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>CREATE TABLE `settings`</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>CREATE TABLE `settings`</td></tr>";}

#insert data into the settings table
$sqls =	"INSERT INTO `settings` (`id`, `table`, `size`) VALUES (0, 'wifi0', 0);";
$IN_TB_SE_Re = mysql_query($sqls, $conn) or die(mysql_error());

if($IN_TB_SE_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>INSERT INTO `settings`</td></tr>";}
else{echo "<tr class=\"bad\"><td>Failure..........</td><td>INSERT INTO `settings`</td></tr>";}

	#========================================================================================================================#
	#													Create Users table											   	     #
	#========================================================================================================================#
#create users table (History for imports)
$sqls =	"CREATE TABLE `users` (`id` INT( 255 ) NOT NULL AUTO_INCREMENT ,`username` VARCHAR( 25 ) NOT NULL ,`points` TEXT NOT NULL ,`notes` TEXT NOT NULL ,`title` varchar(32) NOT NULL ,`date` varchar(25) NOT NULL, INDEX ( `id` )) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;";
$CR_TB_US_Re = mysql_query($sqls, $conn) or die(mysql_error());

if($CR_TB_US_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>CREATE TABLE `users`</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>CREATE TABLE `users`</td></tr>";}

	#========================================================================================================================#
	#													Create WiFi Pointers table									   	     #
	#========================================================================================================================#
#Create Wifi0 table (Pointers to _ST tables
$sqls =	"CREATE TABLE wifi0 ("
  ."  id int(255) default NULL,"
  ."  ssid varchar(25) NOT NULL,"
  ."  mac varchar(25) NOT NULL,"
  ."  chan varchar(3) NOT NULL,"
  ."  sectype varchar(1) NOT NULL,"
  ."  radio varchar(1) NOT NULL,"
  ."  auth varchar(25) NOT NULL,"
  ."  encry varchar(25) NOT NULL,"
  ."  KEY id (id) "
  .") ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;";
$CR_TB_W0_Re = mysql_query($sqls, $conn) or die(mysql_error());

if($CR_TB_W0_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>CREATE TABLE `wifi0`</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>CREATE TABLE `wifi0`</td></tr>";}

	#========================================================================================================================#
	#													Create links table and populate								   	     #
	#========================================================================================================================#
#Create Links table
$sqls =	"CREATE TABLE `links` ("
	."`ID` int(255) NOT NULL auto_increment,"
	."`links` varchar(255) NOT NULL,"
	."KEY `INDEX` (`ID`)"
	.") ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;";
$CR_TB_LN_Re = mysql_query($sqls, $conn) or die(mysql_error());

if($CR_TB_LN_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>CREATE TABLE `links`</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>CREATE TABLE `links`</td></tr>";}


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
		."(7, '<a class=\"links\" href=\"$hosturl/$root/ver.php\">WiFiDB Version</a>')";
}elseif($root !== "")
{ 
	$sqls =	"INSERT INTO `links` (`ID`, `links`) VALUES"
		."(1, '<a class=\"links\" href=\"$root/\">Main Page</a>'),"
		."(2, '<a class=\"links\" href=\"$root/all.php?sort=SSID&ord=ASC&from=0&to=100\">View All APs</a>'),"
		."(3, '<a class=\"links\" href=\"$root/import/\">Import</a>'),"
		."(4, '<a class=\"links\" href=\"$root/opt/export.php?func=index\">Export</a>'),"
		."(5, '<a class=\"links\" href=\"$root/opt/search.php\">Search</a>'),"
		."(6, '<a class=\"links\" href=\"$root/opt/userstats.php?func=allusers\">View All Users</a>'),"
		."(7, '<a class=\"links\" href=\"$root/ver.php\">WiFiDB Version</a>')";
}else
{
	$sqls =	"INSERT INTO `links` (`ID`, `links`) VALUES"
		."(1, '<a class=\"links\" href=\"/wifidb\">Main Page</a>'),"
		."(2, '<a class=\"links\" href=\"/wifidb/all.php?sort=SSID&ord=ASC&from=0&to=100\">View All APs</a>'),"
		."(3, '<a class=\"links\" href=\"/wifidb/import/\">Import</a>'),"
		."(4, '<a class=\"links\" href=\"/wifidb/opt/export.php?func=index\">Export</a>'),"
		."(5, '<a class=\"links\" href=\"/wifidb/opt/search.php\">Search</a>'),"
		."(6, '<a class=\"links\" href=\"/wifidb/opt/userstats.php?func=allusers\">View All Users</a>'),"
		."(7, '<a class=\"links\" href=\"/wifidb/ver.php\">WiFiDB Version</a>')";
}
$IN_TB_LN_Re = mysql_query($sqls, $conn) or die(mysql_error());

if($IN_TB_LN_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>INSERT INTO `links`</td></tr>";}
else{echo "<tr class=\"bad\"><td>Failure..........</td><td>INSERT INTO `links`</td></tr>";}


if ($sqlhost !== 'localhost' or $sqlhost !== "127.0.0.1")
{$phphost = 'localhost';}
else{$phphost	=	$_POST['phphost'];}
	#========================================================================================================================#
	#									Create WiFiDB user for WiFi and WiFi_st										   	     #
	#========================================================================================================================#
#create WifiDB user in  WIFI
$sqls =	"GRANT ALL PRIVILEGES ON $wifi.* TO '$sqlu'@'$phphost' IDENTIFIED BY '$sqlp';";
$GR_US_WF_Re = mysql_query($sqls, $conn) or die(mysql_error());

if($GR_US_WF_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>Created user: $sqlu @ $phphost for $wifi</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Created user: $sqlu @ $phphost for $wifi</td></tr>";
}

#create WifiDB user in  WIFI_ST
$sqls =	"GRANT ALL PRIVILEGES ON $wifi_st.* TO '$sqlu'@'$phphost' IDENTIFIED BY '$sqlp';";
$GR_US_ST_Re = mysql_query($sqls, $conn) or die(mysql_error());

if($GR_US_WF_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>Created user: $sqlu @ $phphost for $wifi_st</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Created user: $sqlu @ $phphost for $wifi_st</td></tr>";}


	#========================================================================================================================#
	#											Create the Config.inc.php file										   	     #
	#========================================================================================================================#
#create config.inc.php file in /lib folder
echo '<tr class="style4"><TH colspan="2">Config.inc.php File Creation</th></tr>';
$file_ext = 'config.inc.php';
$filename = '../lib/'.$file_ext;
$filewrite = fopen($filename, "w");
$fileappend = fopen($filename, "a");

if($filewrite)
{echo "<tr class=\"good\"><td>Success..........</td><td>Created Config file</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Creating Config file</td></tr>";}


#Add last edit date
$CR_CF_FL_Re = fwrite($fileappend, "<?php \r\ndate_default_timezone_set('$timezn');\r\n$"."lastedit	=	'$date';\r\n\r\n");

if($CR_CF_FL_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>Add Install date</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Add Install date</td></tr>";}

#add default debug values
$AD_CF_DG_Re = fwrite($fileappend, "#---------------- Debug Info ----------------#\r\n"
									."$"."rebuild	=	0;\r\n"
									."$"."debug		=	0;\r\n"
									."$"."loglev		=	0;\r\n"
									."$"."bench		=	0;\r\n\r\n");

if($AD_CF_DG_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>Add default debug values</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Add default debug values</td></tr>";}

#add url info
$AD_CF_UR_Re = fwrite($fileappend, "#---------------- URL Info ----------------#\r\n"
									."$"."root		=	'/$root';\r\n"
									."$"."hosturl	=	'$hosturl';\r\n\r\n");

if($AD_CF_UR_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>Add PHP Host URL</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Adding PHP Host URL</td></tr>";}

#add sql host info
$AD_CF_SH_Re = fwrite($fileappend, "#---------------- SQL Related Information ----------------#\r\n"
									."$"."host	=	'$sqlhost';\r\n"
									."$"."settings_tb 	=	'settings';\r\n"
									."$"."users_tb 		=	'users';\r\n"
									."$"."links 			=	'links';\r\n"
									."$"."wtable 		=	'wifi0';\r\n"
									."$"."gps_ext 		=	'_GPS';\r\n"
									."$"."sep 			=	'-';\r\n"
									."$"."db			=	'$wifi';\r\n"
									."$"."db_st 		=	'$wifi_st';\r\n"
									."$"."db_user	=	'$sqlu';\r\n"
									."$"."db_pwd		=	'$sqlp';\r\n"
									."$"."engine		=	'InnoDB';\r\n"
									."$"."charset		=	'utf8';\r\n"
									."$"."conn 	=	mysql_pconnect($"."host, $"."db_user, $"."db_pwd) or die(\"Unable to connect to SQL server: $"."host\");\r\n\r\n");
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
							."$"."vs1_out				=	'../out/vs1/';\r\n\r\n");
if($AD_CF_KM_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>Add KML Info</td></tr>";}
else
{echo "<tr class=\"bad\"><td>Failure..........</td><td>Adding KML Info</td></tr>";}


$AD_CF_FI_Re = fwrite($fileappend,"#---------------- Footer Additional Info -----------------#\r\n"
								."$"."ads 		= ''; # <-- put the code for your ads in here www.google.com/adsense\r\n"
								."$"."tracker	= ''; # <-- put the code for the url tracker that you use here (ie - www.google.com/analytics )\r\n\r\n");
if($AD_CF_FI_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>Add Footer Information Info</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Adding Footer Information </td></tr>";}

$install_warning = fwrite($fileappend,"if(is_dir('install')){echo '<h2><font color=\"red\">The install Folder is still there, remove it!</font></h2>';}\nelseif(is_dir('../install')){echo '<h2><font color=\"red\">The install Folder is still there, remove it!</font></h2>';}\r\n");
if($install_warning){}
fwrite($fileappend, "\r\n?>");

	#========================================================================================================================#
	#													Install has finished										   	     #
	#========================================================================================================================#
fclose($fileappend);
fclose($filewrite);
echo "</table>";
echo "<h2>Install is Finished, if all was Successfull you may now remove the Install Folder</h2>";
$filename = $_SERVER['SCRIPT_FILENAME'];
$file_ex = explode("/", $filename);
$count = count($file_ex);
$file = $file_ex[($count)-1];
?>
</p>
</td>
</tr>
<tr>
<td bgcolor="#315573" height="23"><a href="/<?php echo $root; ?>/img/moon.png"><img border="0" src="/<?php echo $root; ?>/img/moon_tn.png"></a></td>
<td bgcolor="#315573" width="0" align="center">
<?php
if (file_exists($filename)) 
{?>
	<h6><i><u><?php echo $file;?></u></i> was last modified:  <?php echo date ("Y F d @ H:i:s", filemtime($filename));?></h6>
<?php
}
?>
</td>
</tr>
</table>
</body>
</html>

?>