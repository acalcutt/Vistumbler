<?php
include('../lib/database.inc.php');
include('../lib/config.inc.php');
echo '<title>Wireless DataBase *Alpha*'.$ver["wifidb"].' --> Import Page</title>';
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
<?php
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
<?php

if($_POST["user"] !== ''){$user = addslashes($_POST["user"]);}else{$user="Unknown";}
if($_POST["notes"] !== ''){$notes = addslashes($_POST["notes"]);}else{$notes="No Notes";}
if($_POST['title'] !== ''){$title = addslashes($_POST['title']);}else{$title="Untitled";}

$tmp	=	$_FILES['file']['tmp_name'];
$filename	=	$_FILES['file']['name'];

$rand	=	rand();

$user = smart_quotes($user);
$notes = smart_quotes($notes);
$title = smart_quotes($title);

echo "<h1>Imported By: ".$user."<BR></h1>";
echo "<h2>With Title: ".$title."</h2>";
$uploaddir = getcwd()."/up/";
$uploadfile = $uploaddir.$rand.'_'.$filename;

if (!move_uploaded_file($tmp, $uploadfile)) {echo "Failure.<BR>"; die();}
$database = new database();
$database->import_vs1($uploadfile, $user, $notes, $title );
mysql_select_db($db,$conn);

$sqls = "SELECT * FROM `users`";
$result = mysql_query($sqls, $conn) or die(mysql_error());
$row = mysql_num_rows($result);
$database->exp_kml($export="exp_newest_kml");

$file = $_SERVER['SCRIPT_FILENAME'];
footer($file);
mysql_close($conn);
?>