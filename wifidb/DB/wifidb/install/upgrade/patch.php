<?php
include('../../lib/database.inc.php');
include('../../lib/config.inc.php');
echo '<title>Wireless DataBase *Alpha*'.$ver["wifidb"].' --> Upgrade Page</title>';
?>
<link rel="stylesheet" href="../../css/site4.0.css">
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
</td><td width="80%" bgcolor="#A9C6FA" valign="top" align="center"><p>
<table border="1" width="90%"><tr class="style4"><th>Status</th><th>Step of Install</th></tr>
<tr class="style4"><TH colspan="2">Upgrade DB for 0.15 Build 7x to 0.16 Build 1</TH><tr>
<?php
if($ver['wifidb'] !== "0.16 Build 1"){echo '<h1><font color="red">You must have the 0.16 Build 1 Code base.</font></h1>';footer($_SERVER['SCRIPT_FILENAME']); die();}
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
$remove = $_POST['remove'];
?>
<tr class="style4"><th colspan="2">Database Upgrade Part</td></tr>
<tr class="style4"><td colspan="2">This may take a while depending on the Hardware/OS and how many APs you have.</td></tr>
<?php 

if ($sqlhost !== 'localhost' or $sqlhost !== "127.0.0.1")
{$phphost = 'localhost';}
else{$phphost	=	$_POST['phphost'];}

#Connect with Root priv
$conn = mysql_connect($sqlhost, $root_sql_user, $root_sql_pwd);

$sqls =	"REVOKE ALL PRIVILEGES ON `$wifi` . * FROM '$sqlu'@'$phphost'";
$GR_US_WF_Re = mysql_query($sqls, $conn) or die(mysql_error($conn));

if($GR_US_WF_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>Revoke user: $sqlu @ $phphost for $wifi</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Revoke user: $sqlu @ $phphost for $wifi</td></tr>";
}

$sqls =	"REVOKE ALL PRIVILEGES ON `$wifi_st` . * FROM '$sqlu'@'$phphost'";
$GR_US_WF_Re = mysql_query($sqls, $conn) or die(mysql_error($conn));

if($GR_US_WF_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>Revoke user: $sqlu @ $phphost for $wifi_st</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Revoke user: $sqlu @ $phphost for $wifi_st</td></tr>";
}


$sqls =	"GRANT SELECT , INSERT , UPDATE , DELETE ,CREATE ,DROP ,INDEX ,ALTER ,CREATE TEMPORARY TABLES ,CREATE VIEW ,SHOW VIEW ,CREATE ROUTINE,ALTER ROUTINE,EXECUTE ON `$wifi` . * TO '$sqlu'@'$phphost'";
$GR_US_WF_Re = mysql_query($sqls, $conn) or die(mysql_error($conn));

if($GR_US_WF_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>Re-Created user: $sqlu @ $phphost for $wifi</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Re-Created user: $sqlu @ $phphost for $wifi</td></tr>";
}


$sqls =	"GRANT SELECT , INSERT , UPDATE , DELETE ,CREATE ,DROP ,INDEX ,ALTER ,CREATE TEMPORARY TABLES ,CREATE VIEW ,SHOW VIEW ,CREATE ROUTINE,ALTER ROUTINE,EXECUTE ON `$wifi_st` . * TO '$sqlu'@'$phphost'";
$GR_US_ST_Re = mysql_query($sqls, $conn) or die(mysql_error($conn));

if($GR_US_WF_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>Re-Created user: $sqlu @ $phphost for $wifi_st</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Re-Created user: $sqlu @ $phphost for $wifi_st</td></tr>";}

mysql_select_db($wifi,$conn);
$sql = "DROP TABLE `links`";
$drop = mysql_query($sql, $conn);

if($drop)
{echo "<tr class=\"good\"><td>Success..........</td><td>DROP TABLE `links`";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>DROP TABLE `links`";}


$sql0 = "CREATE TABLE `links` (`ID` int(255) NOT NULL auto_increment,`links` varchar(255) NOT NULL, KEY `INDEX` (`ID`) ) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=6";
$create = mysql_query($sql0, $conn) or die(mysql_error($conn));

if($create)
{echo "<tr class=\"good\"><td>Success..........</td><td>CREATE TABLE `links`; ";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>CREATE TABLE `links`";}

if($hosturl !== "" && $root !== "")
{
	$sqls =	"INSERT INTO `links` (`ID`, `links`) VALUES"
		."(1, '<a class=\"links\" href=\"$hosturl/$root/\">Main Page</a>'),"
		."(2, '<a class=\"links\" href=\"$hosturl/$root/all.php?sort=SSID&ord=ASC&from=0&to=100\">View All APs</a>'),"
		."(3, '<a class=\"links\" href=\"$hosturl/$root/import/\">Import APs</a>'),"
		."(4, '<a class=\"links\" href=\"$hosturl/$root/opt/search.php\">Search APs</a>'),"
		."(5, '<a class=\"links\" href=\"$hosturl/$root/opt/userstats.php?func=allusers\">View All Users</a>'),"
		."(6, '<a class=\"links\" href=\"$hosturl/$root/ver.php\">WiFiDB Version</a>')";
}elseif($root !== "")
{ 
	$sqls =	"INSERT INTO `links` (`ID`, `links`) VALUES"
		."(1, '<a class=\"links\" href=\"$root/\">Main Page</a>'),"
		."(2, '<a class=\"links\" href=\"$root/all.php?sort=SSID&ord=ASC&from=0&to=100\">View All APs</a>'),"
		."(3, '<a class=\"links\" href=\"$root/import/\">Import APs</a>'),"
		."(4, '<a class=\"links\" href=\"$root/opt/search.php\">Search APs</a>'),"
		."(5, '<a class=\"links\" href=\"$root/opt/userstats.php?func=allusers\">View All Users</a>'),"
		."(6, '<a class=\"links\" href=\"$root/ver.php\">WiFiDB Version</a>')";
}else
{
	$sqls =	"INSERT INTO `links` (`ID`, `links`) VALUES"
		."(1, '<a class=\"links\" href=\"/\">Main Page</a>'),"
		."(2, '<a class=\"links\" href=\"/all.php?sort=SSID&ord=ASC&from=0&to=100\">View All APs</a>'),"
		."(3, '<a class=\"links\" href=\"/import/\">Import APs</a>'),"
		."(4, '<a class=\"links\" href=\"/opt/search.php\">Search APs</a>'),"
		."(5, '<a class=\"links\" href=\"/opt/userstats.php?func=allusers\">View All Users</a>'),"
		."(6, '<a class=\"links\" href=\"/ver.php\">WiFiDB Version</a>')";
}
$insert = mysql_query($sqls, $conn) or die(mysql_error($conn));

if($insert)
{echo "<tr class=\"good\"><td>Success..........</td><td>Created new Links for 0.16 Build 1.</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>To insert new links into database.</td></tr>";
}

$sql2 = "ALTER TABLE  `$wtable` CHANGE  `chan`  `chan` VARCHAR( 3 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL";
$alter_chan = mysql_query($sql2, $conn);

if($alter_chan)
{echo "<tr class=\"good\"><td>Success..........</td><td>Alter `Chan` column in WiFi Pointers table `".$wtable."`, to allow 3 digits (for 802.11a channels.)</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>To alter `Chan` column in WiFi Pointers table `".$wtable."`.</td></tr>";
}

$sql_		= "SELECT * FROM `$wtable`";
$result_	= mysql_query($sql_, $conn) or die(mysql_error($conn));
while($ap_array = mysql_fetch_array($result_))
{
	$aps[]	= array(
					'id'		=>	$ap_array['id'],
					'ssid'		=>	$ap_array['ssid'],
					'mac'		=>	$ap_array['mac'],
					'sectype'	=>	$ap_array['sectype'],
					'r'			=>	$ap_array['radio'],
					'chan'		=>	$ap_array['chan']
					);
}

foreach($aps as $ap)
{
	$table_gps			=	$ap['ssid'].'-'.$ap['mac'].'-'.$ap['sectype'].'-'.$ap['r'].'-'.$ap['chan'].$gps_ext;
	$alter_gpstables	=	"ALTER TABLE  `$wifi_st`.`$table_gps` "
							."add  `hdp` FLOAT NOT NULL ,"
							."add  `alt` FLOAT NOT NULL ,"
							."add  `geo` FLOAT NOT NULL ,"
							."add  `kmh` FLOAT NOT NULL ,"
							."add  `mph` FLOAT NOT NULL ,"
							."add  `track` FLOAT NOT NULL ";
	$alter_chan = mysql_query($alter_gpstables, $conn);
	if($alter_chan){
		echo '<tr class="good"><td>Success..........</td><td>Access Point GPS tables Updated with new columns<br>'.$table_gps.'</td></tr>';
	}
	else{
		echo '<tr class="bad"><td>Failure..........</td><td>Access Point GPS tables Not Updated with new columns.<br>Either not needed, or MySQL error.<BR>'.$table_gps.'</td></tr>';
	}	
}

mysql_select_db($db,$conn) or die("Unable to select Database: ".$db);
$sql_		= "SELECT * FROM `users`";
$result_	= mysql_query($sql_, $conn) or die(mysql_error($conn));
while($users_array = mysql_fetch_array($result_))
{
	$users[]	= array(
					'id'			=>	$users_array['id'],
					'username'		=>	$users_array['username'],
					'points'		=>	$users_array['points'],
					'date'			=>	$users_array['date'],
					'title'			=>	$users_array['title']
					);
}
foreach($users as $user)
{
mysql_select_db($db,$conn) or die("Unable to select Database: ".$db);
	$id = $user['id'];
	$username = $user['username'];
	$title = $user['title'];
	$date = $user['date'];
	$points_new = array();
	$points = explode("-" , $user['points']);
#	echo '<TR><TD colspan="2">'.$user["points"]."<BR>";
	$point_len = strlen($user['points'])+1;
#	echo $point_len.'<br>'.$remove.'</td></tr>';
	if($remove == "on" && $point_len == 1)
	{
		$alter_user = "DELETE FROM `users` WHERE `id` = '$id'";
		$alter_usertable = mysql_query($alter_user, $conn) or die(mysql_error($conn));
		if($alter_usertable){
			echo '<tr class="good"><td>Success..........</td><td>User List: '.$username.' - '.$title.' at row: '.$id.' - was set to be removed</td></tr>';
		}
		else{
			echo '<tr class=\"bad\"><td>Failure..........</td><td>User List: '.$username.' - '.$title.' at row: '.$id.' - was not removed</td></tr>';
		}
	}else
	{
		foreach($points as $point)
		{
			$points_new[] = $point.":1";
		}
		$points_n = implode("-", $points_new);
		$alter_user = "UPDATE `users` SET `username` = '$username', `points` = '$points_n', `title` = '$title', `date` = '$date' WHERE `id` = '$id'";
		$alter_usertable = mysql_query($alter_user, $conn) or die(mysql_error($conn));
		if($alter_usertable){
			echo '<tr class="good"><td>Success..........</td><td>User tables Updated with Pointers<br>User: '.$username.' - Title: '.$title.'</td></tr>';
		}
		else{
			echo '<tr class=\"bad\"><td>Failure..........</td><td>User tables Updated with Pointers<br>User: '.$username.' - Title: '.$title.'</td></tr>';
		}	
	}
}
?>
<tr class="style4"><th colspan="2">Config File Upgrade Part</td></tr>
<?php
mysql_close($conn);
$file_ext = 'config.inc.php';
$filename = '../../lib/'.$file_ext;
$fileappend = fopen($filename, "a");
$AD_CF_FI_Re = fwrite($fileappend,"<?php\r\n#---------------- Footer Additional Info -----------------#\r\n"
									."$"."ads		=	''; # <-- put the code for your ads in here www.google.com/adsense\r\n"
									."$"."tracker	=	''; # <-- put the code for the url tracker that you use here (ie - www.google.com/analytics )\r\n"
									."$"."kml_out	=	'../out/kml/';\r\n"
									."$"."vs1_out	=	'../out/vs1/';\r\n"
									."$"."bench		=	0;\r\n"
									."\r\n\r\n date_default_timezone_set('GMT+0');");
if($AD_CF_FI_Re)
{echo "<tr class=\"good\"><td>Success..........</td><td>Add Footer Information Info</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>Adding Footer Information </td></tr>";}

$install_warning = fwrite($fileappend,"\r\n\r\nif(is_dir('install')){echo '<h2><font color=\"red\">The install Folder is still there, remove it!</font></h2>';}\nelseif(is_dir('../install')){echo '<h2><font color=\"red\">The install Folder is still there, remove it!</font></h2>';}");
if($install_warning)
{echo "<tr class=\"good\"><td>Success..........</td><td>Warning headers if 'install' folder is found in the 'wifidb' folder.</td></tr>";}
else{
echo "<tr class=\"bad\"><td>Failure..........</td><td>To add 'insall' folder warning header.</td></tr>";}

fwrite($fileappend, "\r\n?>");
fclose($fileappend);

echo "</table>";

echo "<h2>Now you can remove the /install folder from the WiFiDB install root</h2>";
	$file_ex = explode("/", $_SERVER['SCRIPT_FILENAME']);
	$count = count($file_ex);
	$file = $file_ex[($count)-1];
	?>
	</p>
	</td>
	</tr>
	<tr>
	<td bgcolor="#315573" height="23"><a href="<?php echo $root; ?>/img/moon.png"><img border="0" src="<?php echo $root; ?>/img/moon_tn.png"></a></td>
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