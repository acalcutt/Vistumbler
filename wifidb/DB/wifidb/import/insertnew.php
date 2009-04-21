<?php
include('../lib/database.inc.php');
include('../lib/config.inc.php');
pageheader("Import Page");
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

$uploaddir = getcwd()."/up/";
$uploadfile = $uploaddir.$rand.'_'.$filename;

$return  = file($tmp);
$VS1Test = str_split($return[0], 12);
$file_e = explode('.',$filename);
$file_max = count($file_e);

if($file_e[$file_max-1] == 'gpx' )
{
	if (!move_uploaded_file($tmp, $uploadfile))
	{
		echo "Failure to Move file to Upload Dir (/import/up/), check the folder permisions if you are using Linux.<BR>";
		die();
	}

	echo "<h2>Importing GPX File</h2><h1>Imported By: ".$user."<BR></h1>";
	echo "<h2>With Title: ".$title."</h2>";
#	echo $uploadfile;
	$database = new database();
	$database->import_gpx($uploadfile, $user, $notes, $title );
}
elseif($VS1Test[0] == "# Vistumbler" )
{
	if (!move_uploaded_file($tmp, $uploadfile))
	{
		echo "Failure to Move file to Upload Dir (/import/up/), check the folder permisions if you are using Linux.<BR>";
		die();
	}

	echo "<h2>Importing VS1 File</h2><h1>Imported By: ".$user."<BR></h1>";
	echo "<h2>With Title: ".$title."</h2>";

	$database = new database();
	$database->import_vs1($uploadfile, $user, $notes, $title );
}else
{
	echo '<H1>Hey! You have to upload a valid VS1 or GPX File <A HREF="javascript:history.go(-1)"> [Go Back]</A> and do it again the right way.</h1>';
	footer($_SERVER['SCRIPT_FILENAME']);
	die();
}

mysql_select_db($db,$conn);

$sqls = "SELECT * FROM `users`";
$result = mysql_query($sqls, $conn) or die(mysql_error());
$row = mysql_num_rows($result);
#$database->exp_kml($export="exp_newest_kml");

$file = $_SERVER['SCRIPT_FILENAME'];
footer($file);
mysql_close($conn);
?>