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
<tr><TH colspan="2">Upgrade DB for 0.15 Build 78</TH><tr>
<?php

$date = date("m.d.Y");
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
$sql = "DROP TABLE `links`";
$drop = mysql_query($sql, $conn) or die(mysql_error());

if($drop)
{echo "<tr><td>Success..........</td><td>DROP TABLE `links`";}
else{
echo "<tr><td>Failure..........</td><td>DROP TABLE `links`";}


#Create Links table
$sqls =	"CREATE TABLE `links` ("
	."`ID` int(255) NOT NULL auto_increment,"
	."`links` varchar(255) NOT NULL,"
	."KEY `INDEX` (`ID`)"
	.") ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=6 ;";
$CR_TB_LN_Re = mysql_query($sqls, $conn) or die(mysql_error());

if($CR_TB_LN_Re)
{echo "<tr><td>Success..........</td><td>CREATE TABLE `links`</td></tr>";}
else{
echo "<tr><td>Failure..........</td><td>CREATE TABLE `links`</td></tr>";}


#Insert data into links table
if($hosturl !== "" && $root !== "")
{
	$sqls =	"INSERT INTO `links` (`ID`, `links`) VALUES"
		."(1, '<a class=\"links\" href=\"$hosturl/$root/\">Main Page</a>'),"
		."(2, '<a class=\"links\" href=\"$hosturl/$root/all.php?sort=SSID&ord=ASC&from=0&to=100\">View All APs</a>'),"
		."(3, '<a class=\"links\" href=\"$hosturl/$root/import/\">Import APs</a>'),"
		."(4, '<a class=\"links\" href=\"$hosturl/$root/opt/search.php\">Search APs</a>')"
		."(5, '<a class=\"links\" href=\"$hosturl/$root/opt/userstats.php?func=usersall\">View All Users</a>'),"
		."(6, '<a class=\"links\" href=\"$hosturl/$root/ver.php\">WiFiDB Version</a>')";
}elseif($root !== "")
{ 
	$sqls =	"INSERT INTO `links` (`ID`, `links`) VALUES"
		."(1, '<a class=\"links\" href=\"/$root/\">Main Page</a>'),"
		."(2, '<a class=\"links\" href=\"/$root/all.php?sort=SSID&ord=ASC&from=0&to=100\">View All APs</a>'),"
		."(3, '<a class=\"links\" href=\"/$root/import/\">Import APs</a>'),"
		."(4, '<a class=\"links\" href=\"/$root/opt/search.php\">Search APs</a>'),"
		."(5, '<a class=\"links\" href=\"/$root/opt/userstats.php?func=usersall\">View All Users</a>'),"
		."(6, '<a class=\"links\" href=\"/$root/ver.php\">WiFiDB Version</a>')";
}else
{
	$sqls =	"INSERT INTO `links` (`ID`, `links`) VALUES"
		."(1, '<a class=\"links\" href=\"/\">Main Page</a>'),"
		."(2, '<a class=\"links\" href=\"/all.php?sort=SSID&ord=ASC&from=0&to=100\">View All APs</a>'),"
		."(3, '<a class=\"links\" href=\"/import/\">Import APs</a>'),"
		."(4, '<a class=\"links\" href=\"/opt/search.php\">Search APs</a>'),"
		."(5, '<a class=\"links\" href=\"/opt/userstats.php?func=usersall\">View All Users</a>'),"
		."(6, '<a class=\"links\" href=\"/ver.php\">WiFiDB Version</a>')";
}
$IN_TB_LN_Re = mysql_query($sqls, $conn) or die(mysql_error());

if($IN_TB_LN_Re)
{echo "<tr><td>Success..........</td><td>INSERT INTO `links`</td></tr>";}
else{echo "<tr><td>Failure..........</td><td>INSERT INTO `links`</td></tr>";}


echo "</table>";

echo "<h2>Now you can remove the /install folder from the WiFiDB install root</h2>";
$filename = $_SERVER['SCRIPT_FILENAME'];
$file_ex = explode("/", $filename);
$count = count($file_ex);
$file = $file_ex[($count)-1];
if (file_exists($filename)) {
    echo "<h6><i><u>".$file."</u></i> was last modified: " . date ("F d Y H:i:s.", filemtime($filename)) . "</h6>";
}
?>
</p>
</td>
</tr>
<tr>
<td bgcolor="#315573" height="23"><a href="/img/moon.png"><img border="0" src="/img/moon_tn.PNG"></a></td>
<td bgcolor="#315573" width="0">
</td>
</tr>
</table>
</div>
</html>