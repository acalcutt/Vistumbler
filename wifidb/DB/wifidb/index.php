<html>
<?php
if(file_exists('lib/config.inc.php'))
{
	include('lib/config.inc.php');
}else{
	die('<h1>You need to install WiFiDB first. Please go <a href="install/">here</a> to do that.</h1>');
}
include('lib/database.inc.php');
pageheader("Main Page");

$sql = "SELECT `size` FROM `settings`";
$result = mysql_query($sql, $conn) or die(mysql_error($conn));
$DB_size = mysql_fetch_array($result);
$total = $DB_size['size'];

$sql = "SELECT `id` FROM `$wtable` WHERE `sectype`='1'";
$result = mysql_query($sql, $conn) or die(mysql_error($conn));
$open = mysql_num_rows($result);

$sql = "SELECT `id` FROM `$wtable` WHERE `sectype`='2'";
$result = mysql_query($sql, $conn) or die(mysql_error($conn));
$WEP = mysql_num_rows($result);

$sql = "SELECT `id` FROM `$wtable` WHERE `sectype`='3'";
$result = mysql_query($sql, $conn) or die(mysql_error($conn));
$Sec = mysql_num_rows($result);

$sql = "SELECT `id`,`ssid` FROM `$wtable` ORDER BY ID DESC LIMIT 1";
$result = mysql_query($sql, $conn) or die(mysql_error($conn));
$lastap_array = mysql_fetch_array($result);
$lastap_id = $lastap_array['id'];
$lastap_ssid = $lastap_array['ssid'];

$sql = "SELECT `username` FROM `users`";
$result = mysql_query($sql, $conn) or die(mysql_error($conn));
$row_users = mysql_num_rows($result);
while($user_array = mysql_fetch_array($result))
{
	$usersa[]=$user_array['username'];
}
$sql_row = "SELECT * FROM `users` ORDER BY `users`.`id` DESC LIMIT 1";
$result_row = mysql_query($sql_row, $conn) or die(mysql_error($conn));
$users_rows = mysql_fetch_array($result_row);
$row_users = $users_rows['id'];

$sql1 = "SELECT * FROM `users` WHERE `id`='$row_users'";
$result1 = mysql_query($sql1, $conn) or die(mysql_error($conn));
$lastuser = mysql_fetch_array($result1);

mysql_close($conn);

$usersa = array_unique($usersa);
$usercount = count($usersa);

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
	<tr class="style4">
		<td align="left" colspan="4"><strong><em>Statistics</em></strong></td>
	</tr>
	<tr><td class="style2" colspan="4" ></td></tr>
	<tr class="style4">
		<th>Total AP&#39;s</th>
		<th>Open AP&#39;s</th>
		<th>WEP AP&#39;s</th>
		<th>Secure AP&#39;s</th>
	</tr>
	<tr>
		<td align="center" class="style2" style="width: 100px"><?php echo $total; ?></td>
		<td align="center" class="style2"><?php echo $open; ?></td>
		<td align="center" class="style2"><?php echo $WEP; ?></td>
		<td align="center" class="style2"><?php echo $Sec; ?></td>
	</tr>
	<tr><td class="style2" colspan="4" ></td></tr>
	<tr class="style4">
		<th>Total Users</th>
		<th>Last user to import</th>
		<th>Last AP added</th>
		<th>Last Import List</th>
	</tr>
	<tr>
		<td align="center" class="style2" style="width: 100px"><?php echo $usercount;?></td>
		<td align="center" class="style2"><?php if ($usercount == NULL){echo "No one has imported any APs yet.";}else{?><a class="links" href="opt/userstats.php?func=alluserlists&user=<?php echo $lastuser['username'];?>"><?php echo $lastuser['username'];?></a><?php } ?></td>
		<td align="center" class="style2"><?php if($lastap_ssid==''){echo "No AP";}else{?><a class="links" href="opt/fetch.php?id=<?php echo $lastap_id;?>"><?php echo $lastap_ssid;?></a><?php } ?></td>
		<td align="center" class="style2"><?php if(!isset($lastuser['title'])){echo "No Imports";}else{?><a class="links" href="opt/userstats.php?func=useraplist&row=<?php echo $lastuser['id'];?>"><?php echo $lastuser['title'] ;?></a><?php } ?></td>
	</tr>
</table>
<?php
$filename = $_SERVER['SCRIPT_FILENAME'];
footer($filename);
?>