<?php
include('daemon/config.inc.php');
$dbconfig = $GLOBALS['wifidb_install'].$dim.'lib'.$dim.'config.inc.php';
echo $dbconfig."\n";
include($dbconfig);
$filewrite = fopen("filenames.txt", 'w');
$fileappend = fopen("filenames.txt", 'a');
fwrite($fileappend, "# FILE HASH						| FILENAME 				| USERNAME | TITLE | DATE | NOTES\r\n");
$sql1 = "select * from `$db`.`files` ORDER BY `id` ASC";
$result1 = mysql_query($sql1, $conn);
if($result1)
{
	while($array = mysql_fetch_array($result1))
	{
		$write = $array['hash']."|".$array['file']."|".$array['user']."|".$array['title']."|".$array['date']."|".$array['notes']."\r\n";
		echo $array['id']." -=> ".$write;
		fwrite($fileappend, $write);
	}
}
fclose($fileappend);
?>