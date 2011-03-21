<?php
error_reporting(E_ALL|E_STRICT);


while(1)
{
	clearscreen(TRUE);
	echo get_file_size($argv[1])."\r\n";
	sleep(1);
}


function clearscreen($out = TRUE) {
    $clearscreen = chr(27)."[H".chr(27)."[2J";
    if ($out) print $clearscreen;
    else return $clearscreen;
  }

function get_file_size($file_)
{
	$handle = popen('/bin/ls -al '.$file_.'>&1', 'r');
	$read = fread($handle, 2096);
	$read_exp = explode(' ', $read);
	$return =  "######\r\n#\r\n#\r\n#\tSize of ( $file_ ) : ".format_size($read_exp[4],8)."\r\n#\t".date("H:m:s")."\r\n#\r\n#\r\n######";
	pclose($handle);
	return $return;
}

function format_size($size, $round = 2)
{
	//Size must be bytes!

	$sizes = array('B', 'kB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB');

	for ($i=0; $size > 1024 && $i < (count($sizes)-1); $i++)
	{
		$size = $size/1024;
	}
	#echo $size."<BR>";
	return round($size,$round).$sizes[$i];
}

?>