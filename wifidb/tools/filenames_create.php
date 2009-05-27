#!/usr/bin/php
<?php
include('daemon/config.inc.php');
$dbconfig = $GLOBALS['wifidb_install'].$dim.'lib'.$dim.'config.inc.php';
echo $dbconfig."\n";
include($dbconfig);
$conn1	=	mysql_connect($host, $db_user, $db_pwd) or die("Unable to connect to SQL server: $host");
$sql = "SELECT * FROM `$db`.`users` ";
$resul = mysql_query($sql, $conn1);
$filewrite = fopen("filenames.txt", 'w');
$fileappend = fopen("filenames.txt", 'a');
fwrite($fileappend, "#FILENAME | FILE HASH | USERNAME | TITLE | NOTES");
while($arra = mysql_fetch_array($resul))
{
	$id = $arra['id'];
	$sql1 = "select * from `$db`.`files` where `user_row` = '$id'";
	$result1 = mysql_query($sql1, $conn1);
	if($result1)
	{
		while($array = mysql_fetch_array($result1))
		{
			$write = $array['hash']."|".$array['file']."|".$array['user']."|".$array['title']."|".$array['notes']."\r\n";
			echo $write."\n";
			fwrite($fileappend, $write);
		}
	}
}
fclose($fileappend);
?>