<?php
# Usage: bash: php import.php --wifidb="/var/www/wifidb" --user="admin" --notes="These, are the notes!" --title="Import"
#
# All the options are needed, exept for the notes and possibly the title
# if you want all your titles to be "Batch: UNTITLED". Other wise they will be
# "Batch: Import", or what ever you put as the Batch Import title name
# That will replace 'Import' in this example.
#
# To import the older Text files, you have to run them through the converter first.

$lastedit="2009.04.22";
$start="2008.06.21";
$ver="1.5";

$localtimezone = date("T");
echo $localtimezone."\n";

global $wifidb, $user, $notes, $title, $debug ;

date_default_timezone_set('GMT+0'); //setting the time zone to GMT(Zulu) for internal keeping, displays will soon be customizable for the users time zone
ini_set("memory_limit","3072M"); //lots of GPS cords need lots of memory
error_reporting(E_STRICT|E_ALL); //show all erorrs with strict santex

$TOTAL_START = date("H:i:s");

$log = 1;
$debug = 0;


$CLI_script = $argv[0];

if(isset($argv[1])) //parse WiFiDB argument to get value
{
	#echo $argv[1]."\n";
	$CLI_wifidb = explode("=",$argv[1]);
	$CLI_WIFIDB = $CLI_wifidb[1];
	echo "WiFiDB Location: ".$CLI_WIFIDB."\n";
}

if(isset($argv[2])) //parse Username argument to get value
{
	echo $argv[2]."\n";
	$CLI_user = explode("=",$argv[2]);
	$CLI_USER = $CLI_user[1];
	echo "Username of Importer: ".$CLI_USER."\n";
}

if(isset($argv[3])) //parse Notes argument to get value
{
	echo $argv[3]."\n";
	$CLI_notes = explode("=",$argv[3]);
	$CLI_NOTES = $CLI_notes[1];
	echo "Import Notes: ".$CLI_NOTES."\n";
}

if(isset($argv[4])) //parse Title argument to get value
{
	echo $argv[4]."\n";
	$CLI_title = explode("=",$argv[4]);
	$CLI_TITLE = $CLI_title[1];
	echo "Import Title: ".$CLI_TITLE."\n";
}

echo "\n==-=-=-=-=-=- WiFiDB VS1 Batch Import Script -=-=-=-=-=-==\nVersion: ".$ver."\nLast Edit: ".$lastedit."\n";

//test WiFiDB argument, if blank Die
if(isset($CLI_WIFIDB)){$wifidb = $CLI_WIFIDB;}else{echo "You cannot run this with out a config file for this database\n"; die();}
//test User argument, set to Admin if blank
if(isset($CLI_USER)){$user = $CLI_USER;}else{echo "You did not define a Username, it will be set to 'Admin'\n"; $user = 'Admin';}
//test Notes argument, set to 'No Notes' if blank
if(isset($CLI_NOTES)){$notes = $CLI_NOTES;}else{echo "You did not define any notes, it will be set to 'No Notes'\n";$notes = 'No Notes';}
//test Title argument, set to 'UNTITLED' if blank
if(isset($CLI_TITLE)){$title = "Batch: ".$CLI_TITLE;}else{echo "You did not define a Title, it will be set to 'Untitled'\n";$title='Batch: Untitled';}


$vs1dir = getcwd(); //get the Current working Folder so that the script knows where the VS1 folder is
$vs1dir.="/vs1/";
$logdir = getcwd();
if($log >= 1)
{
	$logdir .= "/log/";
	if (!file_exists($logdir)){mkdir($vs1dir);}
	$logfile = $logdir.date("d-m-Y-H-i-s").".log";
	$filename = ($logfile);
	// define initial write and appends
	$filewrite = fopen($filename, "w");
	$fileappend = fopen($filename, "a");

}
if (!file_exists($vs1dir))
{
	echo "You need to put some files in a folder named 'vs1' first.\nPlease do this first then run this again.\nDir:".$vs1dir;
	mkdir($vs1dir);
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
		if ($file_e[$file_max-1]=='vs1' or $file_e[$file_max-1]=="VS1" or $file_e[$file_max-1]=="tmp" or $file_e[$file_max-1]=="TMP")
		{
			$file_a[] = $file; //if Filename is valid, throw it into an array for later use
			echo $n." ".$file."\n";
			$n++;
		}else{
			echo "File not supported !\n";
			if($log >= 1)
			{
				fwrite($fileappend, $file."	is not a supported file extention of ".$file_e[$file_max-1]."\r\n if the file is a txt file run it through the converter first.\r\n");
			}elseif($log >=2){fwrite($fileappend, $file." has vaules of: ".var_dump($file));}
		}
	}
}


echo "\n\n";
closedir($dh);
$bencha = array();

//start import of all files in VS1 folder
foreach($file_a as $key => $file)
{
	$source = $vs1dir.$file;
	echo "\n".$key."\t->\t################=== Start Import of ".$file." ===################";
	echo "\n";
	$check = check_file($source);
	if($check == 1)
	{
		$bencha[] = import_vs1($source, $user, $notes, $title);
	}elseif($check == 0)
	{
		echo "File has already been successfully imported into the Database, skipping.\n";
	}
//	function  ( Source file , User that is importing, Notes for import, Title of Batch Import {will have "Batch: *title*" as title} )
}
$TOTAL_END = date("H:i:s");
foreach($bencha as $ben)
{
	echo "FileName:	".$ben['name']."\n";
	echo "Start:	".$ben['start']."\n";
	echo "End:	".$ben['end']."\n";
	echo "# of GPS:	".$ben['gdatacount']."\n";
	echo "Total AP:	".$ben['total_ap']."\n";
	echo "Total Import:	".$ben['imp']."\n";
	echo "Total Update:	".$ben['up']."\n";
	
}
echo "\nTOTAL Running time::\n\nStart: ".$TOTAL_START."\nStop : ".$TOTAL_END."\n";




#----------FUNCTIONS--------------#


function smart_quotes($text="")
{
	$pattern = '/"((.)*?)"/i';
	$strip = array(
					0=>".",
					1=>"*",
					2=>"?",
					3=>"<",
					4=>">",
					5=>'"',
					6=>"'",
					7=>"#",
					8=>"&",
					9=>"~",
					10=>"@",
					11=>"\\",
					12=>"ÿ",
					13=>"`",
					14=>"/",
					15=>",",
					16=>":"
				);
	$text = preg_replace($pattern,"&#147;\\1&#148;",$text);
	$text = str_replace($strip,"_",$text);
	$text = addslashes($text);
	$text = strip_tags($text);
	return $text;
}
function smart($text="")
{
	$pattern = '/"((.)*?)"/i';
	$strip = array(
					0=>" ",
					1=>":",
					2=>"-",
					3=>".",
					4=>"N",
					5=>"E",
					6=>"W",
					7=>"S"
				  );
	$text = preg_replace($pattern,"&#147;\\1&#148;",stripslashes($text));
	$text = str_replace($strip,"",$text);
	return $text;
}

function &check_gps_array($gpsarray, $test)
{
	foreach($gpsarray as $gps)
	{
		$id = $gps['id'];
		$lat1 = smart($gps['lat']);
		$long1 = smart($gps['long']);
		$time1 = smart($gps['time']);
		$date1 = smart($gps['date']);
		$gps_t 	= $lat1."".$long1."".$date1."".$time1;
		$gps_t = $gps_t+0;
		$test	 = $test+0;
		$testing = strcasecmp($gps_t,$test);
		if ($testing===0)
		{
			$returns = array(0=>1,1=>$id);
			return $returns;
			break;
		}else
		{
			$return = array(0=>0,1=>0);
		}
	}
	return $return;
}


function check_file($file = '')
{
	$size = (filesize($file)/1024);
	include($GLOBALS['wifidb'].'/lib/config.inc.php');
	$file_exp = explode("/", $file);
	$file_exp_seg = count($file_exp);
	$file1 = $file_exp[$file_exp_seg-1];
	echo $size."KB , ".$file1."\n";
	mysql_select_db($db,$conn);
	$fileq = mysql_query("SELECT * FROM `files` WHERE `file` LIKE '$file1'", $conn) or die(mysql_error($conn));
	$fileqq = mysql_fetch_array($fileq);
	echo $fileqq['size']."KB , ".$fileqq['file']."\n";
	if($fileqq['size'] != $size && $file1 != $fileqq['file'])
	{
		return 1;
	}else
	{
		return 0;
	}
}


function insert_file($file = '')
{
	$size = (filesize($file)/1024);
	include($GLOBALS['wifidb'].'/lib/config.inc.php');
	mysql_select_db($db,$conn);
		
	$file_exp = explode("/", $file);
	$file_exp_seg = count($file_exp);
	$file = $file_exp[$file_exp_seg-1];
	
	$fileq = mysql_query("INSERT INTO `files` ( `id` , `file`, `size`, `date`) VALUES ('', '$file', '$size', '')", $conn) or die(mysql_error($conn));
	if(!$fileq)
	{
		$A = array( 0=>0, 'error' => mysql_error($conn));
		return $A;
	}else
	{
		return 1;
	}
}

function import_vs1($source="" , $user="Unknown" , $notes="No Notes" , $title="UNTITLED" )
{
	$FILENUM = 1;
	
	$start = microtime(true);
	$times=date('Y-m-d H:i:s');
	if ($source == NULL)
		{
			echo "There was an error sending the file name to the function\n";
			if($GLOBALS['log'] >= 1)
		{
				fwrite($fileappend, "	The source was corrupted or something before it could be parsed, try importing again.\r\n");
			}
			break;
		}
	include($GLOBALS['wifidb'].'/lib/config.inc.php');
	//	$gdata [ ID ] [ object ]
	//		   num     lat / long / sats / date / time
	$user_n	 = 0;
	$N		 = 0;
	$n		 = 0;
	$gpscount= 0;
	$co		 = 0;
	$cco	 = 0;
	$updated = 0;
	$imported = 0;
	$apdata  = array();
	$gpdata  = array();
	$signals = array();
	$sats_id = array();
	
	$return  = file($source);
	$count = count($return);
	if($count <= 8) { echo "You cannot upload an empty VS1 file, at least scan for a few seconds to import some data.\n"; break;}
	foreach($return as $ret)
	{

		if ($ret[0] == "#"){continue;}
		
		$retexp = explode("|",$ret);
		$ret_len = count($retexp);
		
		if ($ret_len == 12)
		{
			$date_exp = explode("-",$retexp[10]);
			if(strlen($date_exp[0]) <= 2)
			{
				$gpsdate = $date_exp[2]."-".$date_exp[0]."-".$date_exp[1];
			}else
			{
				$gpsdate = $retexp[10];
			}
			# GpsID|Latitude|Longitude|NumOfSatalites|HorDilPitch|Alt|Geo|Speed(km/h)|Speed(MPH)|TrackAngle|Date(UTC y-m-d)|Time(UTC h:m:s)
			$gdata[$retexp[0]] = array(
										"lat"=>$retexp[1],
										"long"=>$retexp[2],
										"sats"=>$retexp[3],
										"hdp"=>$retexp[4],
										"alt"=>$retexp[5],
										"geo"=>$retexp[6],
										"kmh"=>$retexp[7],
										"mph"=>$retexp[8],
										"track"=>$retexp[9],
										"date"=>$gpsdate,
										"time"=>$retexp[11]
										);
			$gpscount++;
		}elseif($ret_len == 6)
		{
			$date_exp = explode("-",$retexp[4]);
			if(strlen($date_exp[0]) <= 2)
			{
				$gpsdate = $date_exp[2]."-".$date_exp[0]."-".$date_exp[1];
			}else
			{
				$gpsdate = $retexp[4];
			}
			# GpsID|Latitude|Longitude|NumOfSatalites|HorDilPitch|Alt|Geo|Speed(km/h)|Speed(MPH)|TrackAngle|Date(UTC y-m-d)|Time(UTC h:m:s)
			$gdata[$retexp[0]] = array(
										"lat"=>$retexp[1],
										"long"=>$retexp[2],
										"sats"=>$retexp[3],
										"hdp"=>0.0,
										"alt"=>0.0,
										"geo"=>-0.0,
										"kmh"=>0.0,
										"mph"=>0.0,
										"track"=>0.0,
										"date"=>$gpsdate,
										"time"=>$retexp[5]
										);
			$gpscount++;
		}elseif($ret_len == 13)
		{
				if(!isset($SETFLAGTEST))
				{
					$count = $count - $gpscount;
					$count = $count - 8;
				}
				$SETFLAGTEST = TRUE;
				$wifi = explode("|",$ret, 13);
				if($wifi[0] === "" && $wifi[1] === "" && $wifi[5] === "" && $wifi[6] === "" && $wifi[7] === ""){continue;}
				mysql_select_db($db,$conn);
				$dbsize = mysql_query("SELECT * FROM `$wtable`", $conn) or die(mysql_error($conn));
				$size = mysql_num_rows($dbsize);
				$size++;
				if ($wifi[0]==""){$wifi[0]="UNNAMED";}
		#		$wifi[12] = strip_tags($wifi[12]);
				// sanitize wifi data to be used in table name
				if($wifi[1] == ''){$wifi[1] = "00:00:00:00:00:00";}
				$ssidss = strip_tags(smart_quotes($wifi[0]));
				$ssidsss = str_split($ssidss,25);
				$ssids = $ssidsss[0];
				
				$mac1 = explode(':', $wifi[1]);
				$macs = $mac1[0].$mac1[1].$mac1[2].$mac1[3].$mac1[4].$mac1[5];
				
				$authen = strip_tags(smart_quotes($wifi[3]));
				$encryp = strip_tags(smart_quotes($wifi[4]));
				$sectype=$wifi[5];
				if($wifi[6] == "802.11a")
					{$radios = "a";}
				elseif($wifi[6] == "802.11b")
					{$radios = "b";}
				elseif($wifi[6] == "802.11g")
					{$radios = "g";}
				elseif($wifi[6] == "802.11n")
					{$radios = "n";}
				else
					{$radios = "U";}
				
				$chan = $wifi[7];
				
				$conn1 = mysql_connect($host, $db_user, $db_pwd);
				mysql_select_db($db,$conn1);
				$result = mysql_query("SELECT * FROM `$wtable` WHERE `mac` LIKE '$macs' AND `chan` LIKE '$chan' AND `sectype` LIKE '$sectype' AND `ssid` LIKE '$ssids' AND `radio` LIKE '$radios' LIMIT 1", $conn1) or die(mysql_error());
				while ($newArray = mysql_fetch_array($result))
				{

					$APid = $newArray['id'];
					$ssid_ptb_ = $newArray["ssid"];
					$ssids_ptb = str_split($newArray['ssid'],25);
					$ssid_ptb = $ssids_ptb[0];
					$mac_ptb=$newArray['mac'];
					$radio_ptb=$newArray['radio'];
					$sectype_ptb=$newArray['sectype'];
					$auth_ptb=$newArray['auth'];

					$encry_ptb=$newArray['encry'];
					$chan_ptb=$newArray['chan'];

					$table_ptb = $ssid_ptb.'-'.$mac_ptb.'-'.$sectype_ptb.'-'.$radio_ptb.'-'.$chan_ptb;
				}
				mysql_close($conn1);
				
				$btx=$wifi[8];
				$otx=$wifi[9];
				$nt=$wifi[10];
				$label = strip_tags(smart_quotes($wifi[11]));
				
				
				//create table name to select from, insert into, or create
				$table = $ssids.'-'.$macs.'-'.$sectype.'-'.$radios.'-'.$chan;
				$gps_table = $table.$gps_ext;
				
				if(!isset($table_ptb)){$table_ptb="";}
				
				if(strcmp($table,$table_ptb)===0)
				{
					// They are the same
					echo "\n".$FILENUM." / ".$count."   ( ".$APid." )   ||   ".$table." - is being updated ";
					if($GLOBALS['log'] >= 1)
						{
							fwrite($fileappend, $FILENUM." / ".$count."   ( ".$APid." )   ||   ".$table." - is being updated \r\n");
						}elseif($GLOBALS['log'] >=2)
						{
							fwrite($fileappend, $file." has vaules of: ".var_dump($file));
						}
					mysql_select_db($db_st,$conn);
					$signal_exp = explode("-",$wifi[12]);
					//setup ID number for new GPS cords
					$DB_result = mysql_query("SELECT * FROM `$gps_table`", $conn);
					$gpstableid = mysql_num_rows($DB_result);
					if ($GLOBALS["debug"]  == 1){echo $gpstableid."\n";}
					if ( $gpstableid === 0)
					{
						$gps_id = 1;
						if ($GLOBALS["debug"]  === 1){echo "0x00 \n";}
					}
					else
					{
						//if the table is already populated set it to the last ID's number
						$gps_id = $gpstableid;
						$gps_id++;
						if ($GLOBALS["debug"]  === 1){echo "0x01 \n";}
					}
					//pull out all GPS rows to be tested against for duplicates
						
					$N=0;
					$todo=array();
					$prev='';
					
					foreach($signal_exp as $exp)
					{
				#		echo ".";
						//Create GPS Array for each Singal, because the GPS table is growing for each signal you need to re grab it to test the data
						$DBresult = mysql_query("SELECT * FROM `$gps_table`", $conn);
						while ($neArray = mysql_fetch_array($DBresult))
						{
							$db_gps[$neArray["id"]]["id"]=$neArray["id"];
							$db_gps[$neArray["id"]]["lat"]=$neArray["lat"];
							$db_gps[$neArray["id"]]["long"]=$neArray["long"];
							$db_gps[$neArray["id"]]["sats"]=$neArray["sats"];
							$db_gps[$neArray["id"]]["date"]=$neArray["date"];
							$db_gps[$neArray["id"]]["time"]=$neArray["time"];
						}
						
						$esp = explode(",",$exp);
						$vs1_id = $esp[0];
						$signal = $esp[1];
						
						if ($prev == $vs1_id)
						{
							$gps_id_ = $gps_id-1;
							$signals[$gps_id] = $gps_id_.",".$signal;
							continue;
						}
						$lat = $gdata[$vs1_id]["lat"];
						$long = $gdata[$vs1_id]["long"];
						$sats = $gdata[$vs1_id]["sats"];
						$date = $gdata[$vs1_id]["date"];
						$time = $gdata[$vs1_id]["time"];
						$hdp = $gdata[$vs1_id]["hdp"];
						$alt = $gdata[$vs1_id]["alt"];
						$geo = $gdata[$vs1_id]["geo"];
						$kmh = $gdata[$vs1_id]["kmh"];
						$mph = $gdata[$vs1_id]["mph"];
						$track = $gdata[$vs1_id]["track"];
						
						$lat1 = smart($lat);
						
						$long1 = smart($long);
						
						$time1 = smart($time);
						
						$date1 = smart($date);
						
						$comp = $lat1."".$long1."".$date1."".$time1;
						
						$gpschk = check_gps_array($db_gps,$comp);
						list($return_gps, $dbid) = $gpschk;
						$DBresult = mysql_query("SELECT * FROM `$gps_table` WHERE `id` = '$dbid'", $conn);
						$GPSDBArray = mysql_fetch_array($DBresult);
						
						if($return_gps === 0)
						{
							$sqlitgpsgp = "INSERT INTO `$gps_table` ( `id` , `lat` , `long` , `sats`, `hdp`, `alt`, `geo`, `kmh`, `mph`, `track` , `date` , `time` ) VALUES ( '$gps_id', '$lat', '$long', '$sats', '$hdp', '$alt', '$geo', '$kmh', '$mph', '$track', '$date', '$time')";
							if (mysql_query($sqlitgpsgp, $conn))
							{
								if($GLOBALS['log'] >= 1)
									{
										fwrite($fileappend, "	- Successful import of GPS data \r\n".'$gps_id', '$lat', '$long', '$sats', '$hdp', '$alt', '$geo', '$kmh', '$mph', '$track', '$date', '$time'."\r\n");
									}
							}else
							{
								echo "There was an Error inserting the GPS information";
								if($GLOBALS['log'] >= 1)
								{
										fwrite($fileappend, "	- Failed import of GPS data \r\n".'$gps_id', '$lat', '$long', '$sats', '$hdp', '$alt', '$geo', '$kmh', '$mph', '$track', '$date', '$time'."\r\n"."	".mysql_error($conn)."\r\n");
								}
							}
							$signals[$gps_id] = $gps_id.",".$signal;
							if($GLOBALS['log'] >= 1)
								{
									fwrite($fileappend, $signals[$gps_id]."\r\n");
								}
							
							$gps_id++;
						#	break;
						}else
						{
							if($sats > $GPSDBArray['sats'])
							{
								$sqlupgpsgp = "UPDATE `$gps_table` SET `lat`= '$lat' , `long` = '$long', `sats` = '$sats', `hdp` = '$hdp', `alt` = '$alt', `geo` = '$geo', `kmh` = '$kmh', `mph` = '$mph', `track` = '$track' , `date` = '$date' , `time` = '$time'  WHERE `id` = '$dbid'";
								$resource = mysql_query($sqlupgpsgp, $conn);
								if ($resource)
								{
								if($GLOBALS['log'] >= 1)
									{
										fwrite($fileappend, "	- Successful Update of GPS data \r\n".'$gps_id', '$lat', '$long', '$sats', '$hdp', '$alt', '$geo', '$kmh', '$mph', '$track', '$date', '$time'."\r\n");
									}
								}else
								{
									echo "A MySQL Update error has occured\n";echo mysql_error($conn);
									
									if($GLOBALS['log'] >= 1)
										{
											fwrite($fileappend, "	- Failed Update of GPS data \r\n".'$gps_id', '$lat', '$long', '$sats', '$hdp', '$alt', '$geo', '$kmh', '$mph', '$track', '$date', '$time'."\r\n"."	".mysql_error($conn)."\r\n");
										}								}
								$signals[$gps_id] = $dbid.",".$signal;
								$gps_id++;
						#		continue;
							}else
							{
								$signals[$gps_id] = $dbid.",".$signal;
								$gps_id++;
						if($GLOBALS['log'] >= 1)
									{
										fwrite($fileappend, "	- GPS already in the database\r\n".var_dump($gdata[$vs1_id])."\r\n");
									}
							}
						}
					}
					echo ".";
					$sig = implode("-",$signals);
					$sqlit = "INSERT INTO `$table` ( `id` , `btx` , `otx` , `nt` , `label` , `sig`, `user` ) VALUES ( '', '$btx', '$otx', '$nt', '$label', '$sig', '$user')";
					
					$sqlit_ = "SELECT * FROM `$table`";
					$sqlit_res = mysql_query($sqlit_, $conn) or die(mysql_error());
					$sqlit_num_rows = mysql_num_rows($sqlit_res);
					$sqlit_num_rows++;
					$user_aps[$user_n]="1,".$APid.":".$sqlit_num_rows; //User import tracking //UPDATE AP
					if($GLOBALS['log'] >= 1)
					{
						fwrite($fileappend, $user_aps[$user_n]."\r\n");
					}
					$user_n++;
					
					if (mysql_query($sqlit, $conn))
					{
						if($GLOBALS['log'] >= 1)
						{
							fwrite($fileappend, "Insert into [".$db_st."].{".$table."}\n		 => Add Signal History to Table\r\n".mysql_error($conn)."\r\n");
						}
					}else
					{
						$sqlct = "CREATE TABLE `$table` (`id` INT( 255 ) NOT NULL AUTO_INCREMENT , `btx` VARCHAR( 10 ) NOT NULL , `otx` VARCHAR( 10 ) NOT NULL , `nt` VARCHAR( 15 ) NOT NULL , `label` VARCHAR( 25 ) NOT NULL , `sig` TEXT NOT NULL , `user` VARCHAR(25) NOT NULL , INDEX ( `id` ), PRIMARY KEY (`id`) )  ENGINE = 'InnoDB' DEFAULT CHARSET='utf8'";
						if (mysql_query($sqlcgt, $conn) or die(mysql_error()))
						{
#							echo "(1)Create Table [".$db_st."].{".$table."}\n		 => Thats odd the table was missing, well I added a Table for ".$ssids."\n";
							if (mysql_query($sqlit, $conn)or die(mysql_error()))
							{
								if($GLOBALS['log'] >= 1)
								{
									fwrite($fileappend, "(3)Insert into [".$db_st."].{".$table."}\n		 => Failed to added GPS History to Table\n".mysql_error($conn)."\r\n");
								}
							}
						}
					}
					$updated++;
					$FILENUM++;
				}else
				{
					
					echo "\n".$FILENUM." / ".$count."   ( ".$size." )   ||   ".$table." - is Being Imported";
					if($GLOBALS['log'] >= 1)
					{
						fwrite($fileappend, $FILENUM." / ".$count."   ( ".$size." )   ||   ".$table." - is Being Imported\r\n");
					}
					mysql_select_db($db_st,$conn)or die(mysql_error($conn));
					$sqlct = "CREATE TABLE `$table` (`id` INT( 255 ) NOT NULL AUTO_INCREMENT , `btx` VARCHAR( 10 ) NOT NULL , `otx` VARCHAR( 10 ) NOT NULL , `nt` VARCHAR( 15 ) NOT NULL , `label` VARCHAR( 25 ) NOT NULL , `sig` TEXT NOT NULL , `user` VARCHAR(25) NOT NULL ,PRIMARY KEY (`id`) ) ENGINE = 'InnoDB' DEFAULT CHARSET='utf8'";
					mysql_query($sqlct, $conn);
#					echo "(1)Create Table [".$db_st."].{".$table."}\n		 => Added new Table for ".$ssids."\n";
					
					$sqlcgt = "CREATE TABLE `$gps_table` ("
								."`id` INT( 255 ) NOT NULL AUTO_INCREMENT ,"
								."`lat` VARCHAR( 25 ) NOT NULL , "
								."`long` VARCHAR( 25 ) NOT NULL , "
								."`sats` INT( 2 ) NOT NULL , "
								."`hdp` FLOAT NOT NULL ,"
								."`alt` FLOAT NOT NULL ,"
								."`geo` FLOAT NOT NULL ,"
								."`kmh` FLOAT NOT NULL ,"
								."`mph` FLOAT NOT NULL ,"
								."`track` FLOAT NOT NULL ,"
								."`date` VARCHAR( 10 ) NOT NULL , "
								."`time` VARCHAR( 8 ) NOT NULL , "
								."INDEX ( `id` ) ) CHARACTER SET = latin1";
					mysql_query($sqlcgt, $conn);
					$create_table = mysql_query($sqlcgt, $conn);
					if($GLOBALS['log'] >= 1 && !$create_table)
					{
						fwrite($fileappend, "[".$db_st."].{".$table."}\n		 => Failed to create Signal History Table \r\n".mysql_error($conn)."\r\n");
					}
					$signal_exp = explode("-",$wifi[12]);
				#	echo $wifi[12]."\n";
					$gps_id = 1;
					$N=0;
					$prev = '';
					foreach($signal_exp as $exp)
					{
				#		echo ".";
						$esp = explode(",",$exp);
						$vs1_id = $esp[0];
						$signal = $esp[1];
						if ($prev == $vs1_id)
						{
							$gps_id_ = $gps_id-1;
							$signals[$gps_id] = $gps_id_.",".$signal;
		#					echo "GPS Point already in DB\n----".$gps_id_."- <- DB ID\n";
							continue;
						}
						$lat = $gdata[$vs1_id]["lat"];
						$long = $gdata[$vs1_id]["long"];
						$sats = $gdata[$vs1_id]["sats"];
						$date = $gdata[$vs1_id]["date"];
						$time = $gdata[$vs1_id]["time"];
						$hdp = $gdata[$vs1_id]["hdp"];
						$alt = $gdata[$vs1_id]["alt"];
						$geo = $gdata[$vs1_id]["geo"];
						$kmh = $gdata[$vs1_id]["kmh"];
						$mph = $gdata[$vs1_id]["mph"];
						$track = $gdata[$vs1_id]["track"];
						
						$sqlitgpsgp = "INSERT INTO `$gps_table` ( `id` , `lat` , `long` , `sats`, `hdp`, `alt`, `geo`, `kmh`, `mph`, `track` , `date` , `time` ) "
											   ."VALUES ( '$gps_id', '$lat', '$long', '$sats', $hdp, $alt, $geo, $kmh, $mph, $track, '$date', '$time')";
						if (mysql_query($sqlitgpsgp, $conn))
						{
				#			echo "(3)Insert into [".$db_st."].{".$gps_table."}\n		 => Added GPS History to Table";
						}else
						{
							echo "There was an error inserting the GPS data.\n".mysql_error($conn);
							if($GLOBALS['log'] >= 1)
							{
								fwrite($fileappend, "Insert into [".$db_st."].{".$table_gps."}\n		 => Failed to added GPS History to Table\n".mysql_error($conn));
							}
						}
						$signals[$gps_id] = $gps_id.",".$signal;
				#		echo $signals[$gps_id];
						$gps_id++;
						$prev = $vs1_id;
					}
					echo ".";
					$sig = implode("-",$signals);
					
					$sqlit = "INSERT INTO `$table` ( `id` , `btx` , `otx` , `nt` , `label` , `sig`, `user` ) VALUES ( '', '$btx', '$otx', '$nt', '$label', '$sig', '$user')";
					$insertsqlresult = mysql_query($sqlit, $conn) or die(mysql_error($conn));
	#				echo "(3)Insert into [".$db_st."].{".$table."}\n		 => Add Signal History to Table\n";
					if($insertsqlresult)
					{
						if($GLOBALS['log'] >= 1)
						{
							fwrite($fileappend, "Insert Signal History into [".$db_st."].{".$table."}\n		 => Failed to added GPS History to Table\n".mysql_error($conn));
						}
					}else
					{
						if($GLOBALS['log'] >= 1)
						{
							fwrite($fileappend, "Insert Signal History into [".$db_st."].{".$table."} FAILED!\n		 => Failed to added GPS History to Table\n".mysql_error($conn));
						}
					}
					# pointers
					mysql_select_db($db,$conn);
					$sqlp = "INSERT INTO `$wtable` ( `id` , `ssid` , `mac` ,  `chan`, `radio`,`auth`,`encry`, `sectype` ) VALUES ( '$size', '$ssidss', '$macs','$chan', '$radios', '$authen', '$encryp', '$sectype')";
					if (mysql_query($sqlp, $conn) or die(mysql_error($conn)))
					{
		#				echo "(1)Insert into [".$db."].{".$wtable."} => Added Pointer Record\n";
						$user_aps[$user_n]="0,".$size.":1";
						$user_n++;
						$sqlup = "UPDATE `$settings_tb` SET `size` = '$size' WHERE `table` = '$wtable' LIMIT 1;";
						if (mysql_query($sqlup, $conn) or die(mysql_error($conn)))
						{
		#					echo 'Updated ['.$db.'].{'.$wtable."} with new Size \n		=> ".$size."\n";
							if($insertsqlresult)
							{
								if($GLOBALS['log'] >= 1)
								{
									fwrite($fileappend, "Insert Signal History into [".$db_st."].{".$table."}\n		 => Failed to added GPS History to Table\n".mysql_error($conn));
								}
							}else
							{
								if($GLOBALS['log'] >= 1)
								{
									fwrite($fileappend, "Insert Signal History into [".$db_st."].{".$table."} FAILED!\n		 => Failed to added GPS History to Table\n".mysql_error($conn));
								}
							}
							
						}else
						{
							echo mysql_error($conn)." => Could not Add new pointer to table (this has been logged) \n";
						}
					}else{echo "Something went wrong, I couldn't add in the pointer :-( \n";}
	#				echo "</td></tr></table>\n";
					$imported++;
					$FILENUM++;
				}
				unset($ssid_ptb);
				unset($mac_ptb);
				unset($sectype_ptb);
				unset($radio_ptb);
				unset($chan_ptb);
				unset($table_ptb);
				
				if(!is_null($signals))
				{
					foreach ($signals as $i => $value)
					{
						unset($signals[$i]);
					}
					$signals = array_values($signals);
				}
		}elseif($ret_len == 17)
		{
			echo "Text files are no longer supported, please save your list as a VS1 file or use the Extra->Wifidb menu option in Vistumbler\n";
			break;
		}elseif($ret_len == 0)
		{
			echo "There is something wrong with the file you uploaded, check and make sure it is a valid VS1 file and try again\n"; die();
		}else
		{
			echo "There is something wrong with the file you uploaded, check and make sure it is a valid VS1 file and try again\n"; die();
		}
	}
	mysql_select_db($db,$conn);
	
	if(isset($user_aps)){$user_ap_s = implode("-",$user_aps);}else{$user_ap_s = "";}
	$notes = addslashes($notes);
	
	if($title === ''){$title = "Untitled";}
	if($user === ''){$user="Unknown";}
	if($notes === ''){$notes="No Notes";}

	if ($user_ap_s != "")
	{
		$sqlu = "INSERT INTO `users` ( `id` , `username` , `points` ,  `notes`, `date`, `title`) VALUES ( '', '$user', '$user_ap_s','$notes', '$times', '$title')";
		mysql_query($sqlu, $conn) or die(mysql_error($conn));
		$inserted = insert_file($source);
		if(is_array($inserted))
		{
			echo "Error Inserting File (".$source.") into Table for later checking\n".$inserted[1];
			die();
		}
	}
	
	mysql_close($conn);
	$total_ap = count($user_aps);
	$gdatacount = count($gdata);
	echo "\nFile DONE!\n|\n|\n";
	$end = microtime(true);
	$times = array(
					"name"	=> $source,
					"start" => $start,
					"end"	=> $end,
					"gdatacount" => $gdatacount,
					"total_ap"	=> $total_ap,
					"up"		=> $updated,
					"imp"		=> $imported
					);
	return $times;
}
?>