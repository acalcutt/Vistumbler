<?php
$TOTAL_START = date("Y-m-d H:i:s");
require 'daemon/config.inc.php';
require $GLOBALS['wifidb_install']."/lib/database.inc.php";
require $GLOBALS['wifidb_install']."/lib/config.inc.php";
$lastedit="2009.07.07";
$start="2008.05.23";
$ver="1.1";
$localtimezone = date("T");
echo $localtimezone."\n";
global $log, $debug;

date_default_timezone_set('GMT+0'); //setting the time zone to GMT(Zulu) for internal keeping, displays will soon be customizable for the users time zone
ini_set("memory_limit","3072M"); //lots of GPS cords need lots of memory
error_reporting(E_STRICT|E_ALL); //show all erorrs with strict santex
$log = 1;
$debug = 0;
echo "\n==-=-=-=-=-=- WiFiDB VS1 Daemoin Prep Script -=-=-=-=-=-==\nVersion: ".$ver."\nLast Edit: ".$lastedit."\n";

$default_user = $GLOBALS['default_user'];
$default_title = $GLOBALS['default_title'];
$default_notes = $GLOBALS['default_notes'];
$vs1dir = $GLOBALS['wifidb_install']."/import/up/";
$logdir = $GLOBALS['wifidb_tools']."/log/";

if($log >= 1)
{
	if (!file_exists($logdir)){mkdir($vs1dir);}
	$logfile = $logdir.date("d-m-Y-H-i-s")."_mass_import.log";
	$filename = ($logfile);
	// define initial write and appends
	$filewrite = fopen($filename, "w");
	$fileappend = fopen($filename, "a");

}
if (!file_exists($vs1dir))
{
	echo "You need to put some files in a folder named 'vs1' first.\nPlease do this first then run this again.\nDir:".$vs1dir;
    die();
}
// self aware of Script location and where to search for Txt files

echo "Directory: ".$vs1dir."\n\n";
echo "Files to Convert: \n";
fwrite($fileappend, "Logging has been enabled by default, to turn of edit line 24 of import.php\r\n");


// Go through the VS1 folder and grab all the VS1 and tmp files
// I included tmp because if you dont tell PHP to rename a file on upload to a website, it will give it a random name with a .tmp extension
$file_a = array();
$n = 0;
$dh = opendir($vs1dir) or die("couldn't open directory");
while (!(($file = readdir($dh)) == false))
{
	if ((is_file("$vs1dir/$file"))) 
	{
		if($file == '.'){continue;}
		if($file == '..'){continue;}
		$file_e = explode('.',$file);
		$file_max = count($file_e);
		$fileext = strtolower($file_e[$file_max-1]);
		if ($fileext=='vs1' or $fileext=="tmp")
		{
			$file_a[] = $file; //if Filename is valid, throw it into an array for later use
			echo $n." ".$file."\n";
			$n++;
		}else{
			echo "File not supported !\n";
			if($log == 1 or 2)
			{
				fwrite($fileappend, $file."	is not a supported file extention of ".$file_e[$file_max-1]."\r\n If the file is a txt file run it through the converter first.\r\n\r\n");
			}elseif($log ==2){fwrite($fileappend, $file." has vaules of: ".var_dump($file));}
		}
	}
}


echo "\n\n";
closedir($dh);

$filenames = file("filenames.txt");
foreach($filenames as $filen)
{
	if($filen[0] == "#"){continue;}
	echo $filen."\n";
	$filen_e = explode("|", $filen);
	$file_names[$filen_e[0]] = array("hash" => $filen_e[0], "file"=>$filen_e[1],"user"=>$filen_e[2],"title"=>$filen_e[3],"notes"=>$filen_e[4]);
}
var_dump($file_names);
//start import of all files in VS1 folder
foreach($file_a as $key => $file)
{
	$source = $GLOBALS['wifidb_install'].$dim.'import'.$dim.'up'.$dim.$file;
	
	$hash = hash_file('md5', $source);
	$size1 = format_size(dos_filesize($source));
	
	if(is_array($file_names[$hash]))
	{
		$user = $file_names[$hash]['user'];
		$title = $file_names[$hash]['title'];
		$notes = $file_names[$hash]['notes'];
	}else
	{
		$user = $default_user;
		$title = $default_title;
		$notes = $default_notes;
	}
	echo $user." - ".$title." - ".$notes."\n\t".$file_names[$hash]['hash'].' - '.$hash."\n";
	echo $source."\n";
#	echo "\n".$key."\t->\t################=== Start Daemon prep of ".$file." ===################\n";
	if($GLOBALS['log'] == 1 or $GLOBALS['log'] == 2)
	{
		fwrite($fileappend, "\r\n\r\n\t".$key."\t->\t################=== Start Daemon Prep of ".$file." ===################\r\n\r\n");
	}
	$date = date("y-m-d H:i:s");
	$sql = "INSERT INTO `$db`.`files_tmp` ( `id`, `file`, `date`, `user`, `notes`, `title`, `size`, `hash`  ) 
								VALUES ( '', '$file', '$date', '$user', '$notes', '$title', '$size1', '$hash')";
	$result = mysql_query( $sql , $conn);
	if($result)
	{
#		echo "<h2>File has been inserted for Importing at a later time at a schedualed time.<br>This is a trial to see how well it will work.</h2>";
	}else
	{
#		echo "<h2>There was an error inserting file for schedualed import.</h2>".mysql_error($conn);
	}
}
$TOTAL_END = date("Y-m-d H:i:s");
echo "\nTOTAL Running time::\n\nStart: ".$TOTAL_START."\nStop : ".$TOTAL_END."\n";

?>