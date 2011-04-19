<?php

global $debug, $screen_output;
$screen_output = "CLI";
require 'daemon/config.inc.php';
require $GLOBALS['wifidb_install']."/lib/database.inc.php";
require $GLOBALS['wifidb_install']."/lib/config.inc.php";

$conn = new PDO('mysql:dbname='.$db.';host='.$host, $db_pwd, $db_user);
$conn->query("truncate wifi.wifi0;", $conn);
$conn->query("truncate wifi.files;", $conn);
$conn->query("truncate wifi.files_tmp;", $conn);
$conn->query("truncate wifi.users_imports;", $conn);
$conn->query("update wifi.wifi0;", $conn);


?>
