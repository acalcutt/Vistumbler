<?php
// <---mass import to daemon--->
// config.inc.php has all the info for the usernames/notes/titles/filenames for each import.
// Folder that is searched is '/tools/vs1/'
// This scripts home is /tools/mi2d/

include('config.inc.php');

$vs1dir = getcwd(); //get the Current working Folder so that the script knows where the VS1 folder is
$vs1dir.="../vs1/";

$file_a = array();
$n = 0;
$dh = opendir($vs1dir) or die("couldn't open directory: ".$vs1dir);
while (!(($file = readdir($dh)) == false))
{
	if ((is_file("$vs1dir/$file"))) 
	{
		if($file == '.'){continue;}
		if($file == '..'){continue;}
		$file_e = explode('.',$file);
		$file_max = count($file_e);
		if ($file_e[$file_max-1]=='vs1' or $file_e[$file_max-1]=="VS1" or $file_e[$file_max-1]=="tmp" or $file_e[$file_max-1]=="TMP")
		{
			$file_a[] = $file; //if Filename is valid, throw it into an array for later use
			echo $n." ".$file."\n";
			$n++;
		}else{
			echo "File not supported !\n";
		}
	}
}

foreach($file_a as $file_s)
{
	foreach($

}

?>