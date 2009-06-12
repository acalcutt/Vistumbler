<?php
include('daemon/config.inc.php');
$dbconfig = $GLOBALS['wifidb_install'].$dim.'lib'.$dim.'config.inc.php';
echo $dbconfig."\n";
include($dbconfig);
$filewrite = fopen("filenames.txt", 'w');
$fileappend = fopen("filenames.txt", 'a');
fwrite($fileappend, "#FILENAME | FILE HASH | USERNAME | TITLE | NOTES");
$sql1 = "select * from `$db`.`files` ORDER BY `id` ASC";
$result1 = mysql_query($sql1, $conn);
if($result1)
{
	while($array = mysql_fetch_array($result1))
	{
		$write = $array['hash']."|".$array['file']."|".$array['user']."|".$array['title']."|".$array['notes']."\r\n";
		echo $WHITE.$array['id']." -=> ".$write.$BLUE;
		fwrite($fileappend, $write);
	}
}
fclose($fileappend);
echo "\033[41;30mblack on red\033[40;37m\r\n";
echo $WHITE;
?>