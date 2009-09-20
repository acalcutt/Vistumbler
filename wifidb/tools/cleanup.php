<?php
# Clean-up duplicate files in the /import/up folder, 
# this is so that you dont have any extra files sitting
# in the files_tmp table when you do a rebuild.
global $debug, $screen_output;
$screen_output = "CLI";
require 'daemon/config.inc.php';
require $GLOBALS['wifidb_install']."/lib/database.inc.php";
require $GLOBALS['wifidb_install']."/lib/config.inc.php";

date_default_timezone_set('UTC'); //setting the time zone to GMT(Zulu) for internal keeping, displays will soon be customizable for the users time zone
ini_set("memory_limit","3072M"); //lots of GPS cords need lots of memory
error_reporting(E_STRICT|E_ALL); //show all erorrs with strict santex

$lastedit="2009.July.22";
$start="2009.July.22";
$ver="1.0";

$localtimezone = date("T");
$debug		= 0;
$deleted	= 0;
$text		= 0;
#echo $localtimezone."\n";

$TOTAL_START = date("Y-m-d H:i:s");

echo "\n==-=-=-=-=-=- WiFiDB VS1 Upload folder cleanup Script -=-=-=-=-=-==\nVersion: ".$ver."\nLast Edit: ".$lastedit."\n";

$vs1dir = $GLOBALS['wifidb_install']."/import/up/";

if (!file_exists($vs1dir))
{
	echo "You need to put some files in a folder named 'vs1' first.\nPlease do this first then run this again.\nDir:".$vs1dir;
    die();
}
// self aware of Script location and where to search for Txt files

echo "Directory: ".$vs1dir."\n\n";
echo "Files to Convert: \n";




// Go through the VS1 folder and grab all the VS1 and tmp files
// I included tmp because if you dont tell PHP to rename a file on upload to a website, it will give it a random name with a .tmp extension
$file_a = array();
$n = 0;
$dh = opendir($vs1dir) or die("couldn't open directory");
while (!(($file = readdir($dh)) == false))
{
	$source = "$vs1dir/$file";
	if ((is_file($source))) 
	{
		if($file == '.'){continue;}
		if($file == '..'){continue;}
		$hash = hash_file('md5', $source);
		$check_file = check_hash($hash, $file_a);
		if($check_file == 0)
		{
			#check for txt file, if so, move to 'tools/backups/text/'
			$check_text = file($source);
			$file_text_check = str_split($check_text[0],16);
			echo $file_text_check[0]."\n";
			if($file_text_check[0] == '# Vistumbler TXT')
			{
				$dest  = $GLOBALS['wifidb_tools']."/backups/text/".$file;
				rename($source, $dest);
				echo "!!! MOVED A TEXT FILE TO: $dest !!!\n";
				$text++;
				continue;
			}
			#add file to array
			$file_a[] = array( 'file'=>$file, 'hash'=> $hash); //if Filename is valid, throw it into an array for later use
			echo $n." ".$file."\n";
			echo "    ".$hash."\n";
			$n++;
		}else
		{
			#move file
			$dest  = $GLOBALS['wifidb_tools']."/backups/duplicates/".$file;
			rename($source, $dest);
			echo "!!! MOVED A FILE TO: $dest !!!\n";
			$deleted++;
		
		}
	}
	echo "\n";
}
$TOTAL_END = date("Y-m-d H:i:s");
echo "Duplicate files moved: ".$deleted."\n";
echo "Text files moved:      ".$text."\n";
echo "Start: ".$TOTAL_START."\nEnd: ".$TOTAL_END."\n";


function &check_hash($hash, $array)
{
	foreach($array as $hash_array)
	{
		$hash_check = $hash_array['hash'];
		if ($hash_check===$hash)
		{
			$return = 1;
			return $return;
			break;
		}else
		{
			$return = 0;
		}
	}
	return $return;
}
?>