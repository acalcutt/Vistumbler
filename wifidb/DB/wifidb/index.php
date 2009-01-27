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
$sql = "SELECT * FROM links ORDER BY ID ASC";
$result = mysql_query($sql, $conn) or die(mysql_error());
while ($newArray = mysql_fetch_array($result))
{
	$testField = $newArray['links'];
    echo "<p>$testField</p>";
}

$sql1 = "SELECT size FROM `settings`";
$result = mysql_query($sql1, $conn) or die(mysql_error());
$DB_size = mysql_fetch_array($result);
$total = $DB_size['size'];

$sql2 = "SELECT id FROM `$wtable` WHERE `sectype`='1'";
$result = mysql_query($sql2, $conn) or die(mysql_error());
$open = mysql_num_rows($result);

$sql3 = "SELECT id FROM `$wtable` WHERE `sectype`='2'";
$result = mysql_query($sql3, $conn) or die(mysql_error());
$WEP = mysql_num_rows($result);

$sql4 = "SELECT id FROM `$wtable` WHERE `sectype`='3'";
$result = mysql_query($sql4, $conn) or die(mysql_error());
$Sec = mysql_num_rows($result);

$sql5 = "SELECT id,ssid FROM `$wtable` ORDER BY ID DESC LIMIT 1";
$result = mysql_query($sql5, $conn) or die(mysql_error());
$lastap_array = mysql_fetch_array($result);
$lastap_id = $lastap_array['id'];
$lastap_ssid = $lastap_array['ssid'];

$sql6 = "SELECT username FROM `users`";
$result1 = mysql_query($sql6, $conn) or die(mysql_error());
while($user_array = mysql_fetch_array($result1))
{
echo $user_array['username'];
	$usersa[]=$user_array['username'];
}
mysql_close($conn);
var_dump($usersa);
$usercount = count($usersa);
if ($usercount == NULL)
{$lastUs="No one has imported any APs yet.";}
else
{$lastUs = $usersa[$usercount-1];}

$users = array_unique($usersa);
$user_count = count($usersa);

?>
</td>
		<td width="80%" bgcolor="#A9C6FA" valign="top" align="center">
			<p align="center">			To View all AP's click <a href="all.php">Here</a><br><br>
			<?php
			$domain = $_SERVER['HTTP_HOST'];
			if ($domain === "rihq.randomintervals.com" or $domain === "lanncafe.dynu.com")
			{echo '<h2>This is my Development server </h2><H4>(which is unstable because I am always working in it)</H4><H2>Go on over to my <i><a href="http://www.randomintervals.com/wifidb/">\'Production Server\'</i></a> for a more stable enviroment</h2>';}
			?>
<table WIDTH=75% BORDER=1 CELLPADDING=2 CELLSPACING=0>
	<tr>
		<td colspan="4" class="style1"><strong><em>Statistics</em></strong></td>
	</tr>
	<tr>
		<td class="style9" style="width: 200px">Total AP&#39;s</td>
		<td class="style12">Open AP&#39;s</td>
		<td class="style12">WEP AP&#39;s</td>
		<td class="style11">Secure AP&#39;s</td>
	</tr>
	<tr>
		<td class="style5" style="width: 200px"><?php echo $total; ?></td>
		<td class="style13"><?php echo $open; ?></td>
		<td class="style13"><?php echo $WEP; ?></td>
		<td class="style8"><?php echo $Sec; ?></td>
	</tr>
	<tr>
		<td class="style14" style="width: 200px">Total Users</td>
		<td class="style16">Last user to import</td>
		<td class="style16">Last AP added</td>
		<td class="style18">&nbsp;</td>
	</tr>
	<tr>
		<td class="style9" style="width: 200px"><?php echo $user_count;?></td>
		<td class="style12"><?php echo $lastUs;?></td>
		<td class="style12"><?php if($lastap_ssid==''){echo "No AP";}else{echo '<a class="links" href="opt/fetch.php?id='.$lastap_id.'">'.$lastap_ssid.'</a>';}?></td>
		<td class="style11">&nbsp;</td>
	</tr>
</table>
<?php
$filename = $_SERVER['SCRIPT_FILENAME'];
$file_ex = explode("/", $filename);
$count = count($file_ex);
$file = $file_ex[($count)-1];
if (file_exists($filename)) {
    echo "<h6><i><u>$file</u></i> was last modified: " . date ("F d Y H:i:s.", filemtime($filename)) . "</h6>";
}
?>
</p>
</td>
</tr>
<tr>
<td bgcolor="#315573" height="23"><a href="/pictures/moon.png"><img border="0" src="/pictures/moon_tn.PNG"></a></td>
<td bgcolor="#315573" width="0">

</td>
</tr>
</table>
</div>
</html>
