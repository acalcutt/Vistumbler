<?php
include('../lib/database.inc.php');
pageheader("Access Point Info Page");
include('../lib/config.inc.php');
$database = new database();
$id = $_GET['id'];
$id = $id + 0;
if(is_int($id)){
	$database->apfetch($id);
}else{echo "<h3>You have entered the wrong type of data in the form, please try again</h3>";}

$filename = $_SERVER['SCRIPT_FILENAME'];
footer($filename);?>