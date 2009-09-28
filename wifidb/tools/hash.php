<?php
$start = microtime(false);
$file1 = '/var/www/wifidb/import/up/10054-WDB_Export.VS1';
$size = (filesize($file1)/1024);

$hash_start = microtime(false);
$hash = hash_file('md5', $file1);
$hash_end = microtime(false);
echo $hash_start."\n".$hash_end."\n";
echo $size."\n";
echo $hash."\n\n";

$md5_start = microtime(false);
$rawhash=md5_file($file1);
$md5_end = microtime(false);
echo $md5_start."\n".$md5_end."\n";
echo $rawhash."\n\n";

$sha1_start = microtime(false);
$rawhash=sha1_file($file1);
$sha1_end = microtime(false);
echo $sha1_start."\n".$sha1_end."\n";
echo $rawhash."\n\n";
?>