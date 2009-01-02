<title>Welcome to the Random Intervals Wireless DB</title>
<link rel="stylesheet" href="../css/site4.0.css">
<body topmargin="10" leftmargin="0" rightmargin="0" bottommargin="10" marginwidth="10" marginheight="10">
<div align="center">
<table border="0" width="75%" cellspacing="10" cellpadding="2">
	<tr>
		<td bgcolor="#315573">
		<p align="center"><b><font size="5" face="Arial" color="#FFFFFF">
		Randomintervals.com Wireless DataBase *Alpha* </font>
		<font color="#FFFFFF" size="2">
            
		</font></b>
		</td>
	</tr>
</table>
</div>
<div align="center">
<table border="0" width="75%" cellspacing="10" cellpadding="2" height="90">
	<tr>
<td width="17%" bgcolor="#304D80" valign="top">

<?php
include('../lib/config.inc.php');
include('../lib/functions.inc.php');
mysql_select_db($db,$conn);
$sqls = "SELECT * FROM links ORDER BY ID ASC";
$result = mysql_query($sqls, $conn) or die(mysql_error());
while ($newArray = mysql_fetch_array($result))
{
	$testField = $newArray['links'];
    echo "<p>$testField</p>";
}
?>

</td>
		<td width="80%" bgcolor="#A9C6FA" valign="top" align="center">
			<p align="center">

			<h2>Admin Section</h2>
<?php
if($_GET['function']==='list')
{
mysql_select_db($db,$conn);
$sqls = "SELECT * FROM `$wtable` ORDER BY ID ASC";
$result = mysql_query($sqls, $conn) or die(mysql_error());
echo "<table><tr><td>SSID</td><td>MAC Address</td><td>Chan</td><td>Edit</td><td>Remove</td><td>View</td><tr>";
while ($newArray = mysql_fetch_array($result))
{
	$id=$newArray['id'];
	$ssid= $newArray['ssid'];
	$mac=$newArray['mac'];
	$chan=$newArray['chan'];
	echo '<td>'.$ssid.'</td><td>'.$mac.'</td><td>'.$chan.'</td><td><a href="edit.php?id='.$id.'">Edit</a></td><td><a href="remove.php?id='.$id.'">Remove</a></td><td><a href="../scripts/fetch.php?id='.$id.'">View</a></td></tr>';
}
echo "</table>";
}elseif($_GET['function']==='rwap')
{
$conn = mysql_connect($host, $db_user, $db_pwd);
mysql_select_db($db,$conn);
$sqls = "SELECT * FROM `$wtable` ORDER BY ID ASC";
$result = mysql_query($sqls, $conn) or die(mysql_error());
while ($newArray = mysql_fetch_array($result))
{
	$id=$newArray['id'];
	$ssid= $newArray['ssid'];
	$mac=$newArray['mac'];
	$chan=$newArray['chan'];

    echo '<a href="?remove='.$id.'">'.$ssid.'</a>';
}
}elseif($_GET['function']==='import')
{
?>
<form action="../scripts/insertnew.php" method="post" enctype="multipart/form-data">

<label for="file">Filename:<label>
<input type="file" name="file" id="file" >
<br >

<input type="submit" name="submit" value="Submit" >

</form>
<?php
}else{echo "You did not get to this page the right way, go back and try it again.";}
?>
</p>
</td>
</tr>
<tr>
<td bgcolor="#315573" height="23"><a href="/pictures/moon.png"><img border="0" src="/pictures/moon_tn.PNG"></a></td>
<td bgcolor="#315573" width="0">&nbsp;</td>
</tr>
</table>
</div>
</html>
