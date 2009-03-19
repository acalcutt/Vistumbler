<html>
<?php
if(file_exists('lib/config.inc.php'))
{
	include('lib/config.inc.php');
}else{
	die('<h1>You need to install WiFiDB first. Please go <a href="install/">here</a> to do that.</h1>');
}
include('lib/database.inc.php');
echo '<title>Wireless DataBase *Alpha*'.$ver["wifidb"].' --> Main Page</title>';
?>
<link rel="stylesheet" href="css/site4.0.css">
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
<?php
$usersa = array();
mysql_select_db($db,$conn);
$sql = "SELECT * FROM `links` ORDER BY ID ASC";
$result = mysql_query($sql, $conn) or die(mysql_error());
while ($newArray = mysql_fetch_array($result))
{
	$testField = $newArray['links'];
    echo "<p>$testField</p>";
}

$sql = "SELECT `size` FROM `settings`";
$result = mysql_query($sql, $conn) or die(mysql_error());
$DB_size = mysql_fetch_array($result);
$total = $DB_size['size'];

$sql = "SELECT `id` FROM `$wtable` WHERE `sectype`='1'";
$result = mysql_query($sql, $conn) or die(mysql_error());
$open = mysql_num_rows($result);

$sql = "SELECT `id` FROM `$wtable` WHERE `sectype`='2'";
$result = mysql_query($sql, $conn) or die(mysql_error());
$WEP = mysql_num_rows($result);

$sql = "SELECT `id` FROM `$wtable` WHERE `sectype`='3'";
$result = mysql_query($sql, $conn) or die(mysql_error());
$Sec = mysql_num_rows($result);

$sql = "SELECT `id`,`ssid` FROM `$wtable` ORDER BY ID DESC LIMIT 1";
$result = mysql_query($sql, $conn) or die(mysql_error());
$lastap_array = mysql_fetch_array($result);
$lastap_id = $lastap_array['id'];
$lastap_ssid = $lastap_array['ssid'];

$sql = "SELECT `username` FROM `users`";
$result = mysql_query($sql, $conn) or die(mysql_error());
$row_users = mysql_num_rows($result);
while($user_array = mysql_fetch_array($result))
{
	$usersa[]=$user_array['username'];
}

$sql = "SELECT username FROM `users` WHERE `id`='$row_users'";
$result = mysql_query($sql, $conn) or die(mysql_error());
$lastuser = mysql_fetch_array($result);

mysql_close($conn);

$usersa = array_unique($usersa);
$usercount = count($usersa);

if ($usercount == NULL){$lastuser['username'] = "No one has imported any APs yet.";}
?>
</td>
		<td width="80%" bgcolor="#A9C6FA" valign="top" align="center">
			<p align="center">To View all AP's click <a class="links" href="all.php?sort=SSID&ord=ASC&from=0&to=100">Here</a><br><br>
			<?php
			$domain = $_SERVER['HTTP_HOST'];
			if ($domain === "rihq.randomintervals.com")
			{echo '<h2>This is my Development server </h2><H4>(which is unstable because I am always working in it)</H4><H2>Go on over to my <i><a href="http://www.randomintervals.com/wifidb/">\'Production Server\'</i></a> for a more stable enviroment</h2>';}
			?>
<table WIDTH=85% BORDER=1 CELLPADDING=2 CELLSPACING=0>
	<tr>
		<td colspan="4" class="style1"><strong><em>Statistics</em></strong></td>
	</tr>
	<tr><td class="style2" colspan="4" ></td></tr>
	<tr>
		<th class="style3" style="width: 100px">Total AP&#39;s</th>
		<th class="style3">Open AP&#39;s</th>
		<th class="style3">WEP AP&#39;s</th>
		<th class="style3">Secure AP&#39;s</th>
	</tr>
	<tr>
		<td align="center" class="style2" style="width: 100px"><?php echo $total; ?></td>
		<td align="center" class="style2"><?php echo $open; ?></td>
		<td align="center" class="style2"><?php echo $WEP; ?></td>
		<td align="center" class="style2"><?php echo $Sec; ?></td>
	</tr>
	<tr><td class="style2" colspan="4" ></td></tr>
	<tr>
		<th class="style3" style="width: 100px">Total Users</th>
		<th class="style3">Last user to import</th>
		<th class="style3">Last AP added</th>
		<th class="style3">&nbsp;</th>
	</tr>
	<tr>
		<td align="center" class="style2" style="width: 100px"><?php echo $usercount;?></td>
		<td align="center" class="style2"><a class="links" href="opt/userstats.php?func=allap&user=<?php echo $lastuser['username'];?>"><?php echo $lastuser['username'];?></a></td>
		<td align="center" class="style2"><?php if($lastap_ssid==''){echo "No AP";}else{?><a class="links" href="opt/fetch.php?id=<?php echo $lastap_id;?>"><?php echo $lastap_ssid;?></a><?php } ?></td>
		<td align="center" class="style2">&nbsp;</td>
	</tr>
</table>
<?php
$filename = $_SERVER['SCRIPT_FILENAME'];
footer($filename);
?>