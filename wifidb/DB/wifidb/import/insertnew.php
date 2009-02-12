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
$conn = mysql_connect($host, $db_user, $db_pwd);
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
$user	=	addslashes($_POST["user"]);
$notes	=	addslashes($_POST["notes"]);
$source	=	$_FILES['file']['tmp_name'];
$dest	=	$_FILES['file']['name'];
$rand	=	rand();
$title	=	addslashes($_POST['title']);
echo "<h1>Imported By: ".$user."<BR></h1>";
echo "<h2>With Title: ".$title."</h2>";
$uploaddir = "C:\wamp\www\wifidb\import\up\\";
$uploadfile = $uploaddir . $rand ."-". basename($dest);

echo '<pre>';
if (!move_uploaded_file($source, $uploadfile)) {echo "Failure.\n";}

print "</pre>";
$database = new database();
$database->import_vs1($uploadfile, $user, $notes, $title );
# database::vs1_2_kml($source);

$filename = $_SERVER['SCRIPT_FILENAME'];
footer($filename);
?>