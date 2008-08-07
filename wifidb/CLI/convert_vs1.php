<?php
// 
echo "=-=-=-=-=-=-=-=-=-=-==-=-=-=-=-=-Vistumbler Summery Text to VS1 converter=-=-=-=-=-=-=-=-=-=-==-=-=-=-=-=-\n";
include('lib\\functions.php');
$dir="C:\\imp\\text\\";

echo "Directory: ".$dir."\n\n";
echo "Files to Convert: \n";

$file_a = array();
$n=0;
$dh = opendir($dir) or die("couldn't open directory");
while (!(($file = readdir($dh)) == false))
{
	if ((is_file("$dir/$file"))) 
	{
		if($file == '.'){continue;}
		if($file == '..'){continue;}
		$file_e = explode('.',$file);
		$file_max = count($file_e);
		if ($file_e[$file_max-1]=='txt' or $file_e[$file_max-1]=="TXT")
		{
			$file_a[$n] = $file;
			echo $n." ".$file."\n";
			$n++;
		}else{
			echo "file not supported !\n";
		}
	}
}
echo "\n\n";
closedir($dh);
$n=0;
foreach($file_a as $file)
{
	$source = $dir.$file;
	echo '################=== Start conversion of '.$source.' ===################';
	echo "\n";
	convert_vs1($source, "file");
//	function ( Source file , output destination type [file only at the moment MySQL support soon])
}

?>