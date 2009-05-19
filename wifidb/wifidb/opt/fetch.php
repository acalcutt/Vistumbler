<?php
include('../lib/config.inc.php');
include('../lib/database.inc.php');
pageheader("Access Point Info Page");
$database = new database();
if ($debug === 1 ){echo '<p align="right"><a class="links" href="../opt/debug/fetch.php">Debug</a></p>';}
$id = $_GET['id'];
$id = $id + 0;
if(is_int($id)){
	$database->apfetch($id);
}else{echo "<h3>You have entered the wrong type of data in the form, please try again</h3>";}

$filename = $_SERVER['SCRIPT_FILENAME'];
footer($filename);?>