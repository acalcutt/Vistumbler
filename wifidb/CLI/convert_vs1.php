<?php
// 
echo "=-=-=-=-=-=-=-=-=-=-==-=-=-=-=-=-Vistumbler Summery Text to VS1 converter=-=-=-=-=-=-=-=-=-=-==-=-=-=-=-=-\n";
include('lib\\functions.php');

// self aware of Script location and where to search for Txt files
$dirs=$_SERVER['PHP_SELF'];
$dir_exp = explode("\\", $dirs);
$dir_c= count($dir_exp);
foreach($dir_exp as $d)
{
	if($d == "convert_vs1.php"){continue;}
	$dir .= $d."\\";
}
$dir.="text\\";

/*
$dir = " Place the DIR that you want searched Here after commenting out the above portion " ;
*/

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
//	function ( Source file , output destination type [ file only at the moment MySQL support soon ] )
}

?>