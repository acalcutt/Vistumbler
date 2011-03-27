<?php
global $log, $debug, $screen_output;
$screen_output = "CLI";
require 'daemon/config.inc.php';
require $GLOBALS['wifidb_install']."lib/database.inc.php";
require $GLOBALS['wifidb_install']."lib/config.inc.php";
$lastedit="2011.02.16";
$start="2008.05.23";
$ver="1.1";
$localtimezone = date("T");
echo $localtimezone."\n";
global $not, $is;
$not = 0;
$is = 0;
date_default_timezone_set('UTC'); //setting the time zone to GMT(Zulu) for internal keeping, displays will soon be customizable for the users time zone
ini_set("memory_limit","3072M"); //lots of GPS cords need lots of memory
error_reporting(E_STRICT|E_ALL); //show all erorrs with strict santex

$TOTAL_START = date("Y-m-d H:i:s");
$log = 1;
$debug = 0;

echo "\n==-=-=-=-=-=- WiFiDB VS1 Daemoin Prep Script -=-=-=-=-=-==\nVersion: ".$ver."\nLast Edit: ".$lastedit."\n";

$default_user = $GLOBALS['default_user'];
$default_title = $GLOBALS['default_title'];
$default_notes = $GLOBALS['default_notes'];
$vs1dir = $GLOBALS['wifidb_install']."import/up/";
$logdir = $GLOBALS['wifidb_tools']."log/";

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

echo "Directory: ".$vs1dir."\r\n";
fwrite($fileappend, "Logging has been enabled by default, to turn of edit line 24 of import.php\r\n");

#Lets parse out the filenames file.
echo "Parsing Filenames.txt\r\n";
$filenames = file("filenames.txt");
foreach($filenames as $filen)
{
    if($filen[0] == "#"){continue;}
    var_dump($filen);
    $filen_e = explode("|", $filen);
    echo count($filen_e)."\r\n";
    if(count($filen_e)==1){continue;}
    $file_names[$filen_e[0]] = array("hash" => $filen_e[0], "file"=>$filen_e[1],"user"=>$filen_e[2],"title"=>$filen_e[3],"date"=>$filen_e[4],"notes"=>$filen_e[5]);
}

// Go through the VS1 folder and grab all the VS1 and tmp files
// I included tmp because if you dont tell PHP to rename a file on upload to a website, it will give it a random name with a .tmp extension
echo "Going through the import/up folder for the source files...\r\n";
$file_a = array();
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
	if ($fileext=='vs1' or $fileext=="tmp" or $fileext=="db3")
	{
	    
	    #echo $n." ".$file."\n";
	    if(insert_file($file,$file_names,$fileappend))
            {
                $file_a[] = $file; //if Filename is valid, throw it into an array for later use
            }else
            {
                echo "No good... Blehk.\r\n";
            }
	}else
	{
	    echo "EXT: ".$fileext."\r\n";
	    echo "File not supported -->$file\r\n";
	    if($log == 1)
	    {
		fwrite($fileappend, "( ".$file." ) is not a supported file extention of ".$file_e[$file_max-1]."\r\n If the file is a txt file run it through the converter first.\r\n\r\n");
	    }elseif($log == 2)
	    {
		fwrite($fileappend, $file." has vaules of: ".var_dump($file));
	    }
	}
    }
}
echo "Is: $is\r\nNot: $not\r\n";
$TOTAL_END = date("Y-m-d H:i:s");
echo "\nTOTAL Running time::\n\nStart: ".$TOTAL_START."\nStop : ".$TOTAL_END."\n";
closedir($dh);



function insert_file($file, $file_names,$fileappend)
{
    $not = $GLOBALS['not'];
    $is = $GLOBALS['is'];
    $default_user = $GLOBALS['default_user'];
    $default_title = $GLOBALS['default_title'];
    $default_notes = $GLOBALS['default_notes'];
    $db = $GLOBALS['db'];
    $conn= $GLOBALS['conn'];
    $dim = DIRECTORY_SEPARATOR;
    $source = $GLOBALS['wifidb_install'].'import'.$dim.'up'.$dim.$file;

    $hash = hash_file('md5', $source);
    $size1 = format_size(dos_filesize($source));
    if(@is_array($file_names[$hash]))
    {
	$user = $file_names[$hash]['user'];
	$title = $file_names[$hash]['title'];
	$notes = $file_names[$hash]['notes'];
	$date = $file_names[$hash]['date'];
	$hash_ = $file_names[$hash]['hash'];
	echo "Is inside Filenames.txt -->$source\r\n";
	$is++;
	$GLOBALS['is'] = $is;
    }else
    {
        echo "Not in filenames.txt -->$source\r\n";
        
        ### JUST A TRIAL
	return 0;
        /*
        $user = $default_user;
	$title = $default_title;
	$notes = $default_notes;
	$date = date("y-m-d H:i:s");
	$hash_ = 0;
	*/
	$not++;
	$GLOBALS['not'] = $not;
    }
    #echo $user." - ".$title." - ".$notes."\n\t".$hash_.' - '.$hash."\n";

#	echo "\n".$key."\t->\t################=== Start Daemon prep of ".$file." ===################\n";
    if($GLOBALS['log'] == 1 or $GLOBALS['log'] == 2)
    {
	fwrite($fileappend, "\r\n\r\n\t\t################=== Start Daemon Prep of ".$file." ===################\r\n\r\n");
    }
    $sql = "INSERT INTO `$db`.`files_tmp` ( `id`, `file`, `date`, `user`, `notes`, `title`, `size`, `hash`  )
							    VALUES ( '', '$file', '$date', '$user', '$notes', '$title', '$size1', '$hash')";
    $result = mysql_query( $sql , $conn);
    if($result)
    {
#	echo "<h2>File has been inserted for Importing at a later time at a schedualed time.<br>This is a trial to see how well it will work.</h2>";
	return 1;
    }else
    {
    #	echo "<h2>There was an error inserting file for schedualed import.</h2>".mysql_error($conn);
	return 0;
    }
}

?>