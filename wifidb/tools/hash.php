<?php
$file1 = '/var/www/wifidb/import/up/special_10602.vs1';
$size = (filesize($file1)/1024);
$hash = hash_file('md5', $file1);
echo $hash."\n";
$size = (filesize($file1)/1024);
echo $size."\n";
?>