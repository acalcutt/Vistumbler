<?php
# Usage: bash: php import.php --wifidb="/var/www/wifidb" --user="admin" --notes="These, are the notes!" --title="Import"
#
# All the options are needed, exept for the notes and possibly the title
# if you want all your titles to be "Batch: ". Other wise they will be
# "Batch: Import". or what ever you put as the Batch Import title name
# That will replace 'Import' in this example

$localtimezone = date("T");
echo $localtimezone."\n";
date_default_timezone_set('GMT+0');
$TOTAL_START = date("H:i:s");
error_reporting(E_STRICT|E_ALL);
$debug = 0;
$lastedit="2009.03.19";
$start="2008.06.21.";
$ver="1.0";

echo $argv[0]."\n";
$CLI_script = $argv[0];

if(isset($argv[1]))
{
	echo $argv[1]."\n";
	$CLI_wifidb = explode("=",$argv[1]);
	$argv[1] = $CLI_wifidb[1];
}

if(isset($argv[2]))
{
	echo $argv[2]."\n";
	$CLI_user = explode("=",$argv[2]);
	$argv[2] = $CLI_user[2];
	echo $argv[2]."\n";
}

if(isset($argv[3]))
{
	echo $argv[3]."\n";
	$CLI_notes = explode("=",$argv[3]);
	$argv[3] = $CLI_notes[3];
}

if(isset($argv[4]))
{
	echo $argv[4]."\n";
	$CLI_title = explode("=",$argv[4]);
	$argv[4] = $CLI_title[4];
}

echo "\n==-=-=-=-=-=- WiFiDB VS1 Batch Import Script -=-=-=-=-=-==\nVersion: ".$ver."\nLast Edit: ".$lastedit."\n";
if(isset($argv[1])){$wifidb = $argv[1];}else{echo "You cannot run this with out a config file for this database\n"; die();}
if(isset($argv[2])){$user = $argv[2];}else{echo "You did not define a Username, it will be set to 'Admin'\n"; $user = 'Admin';}
if(isset($argv[3])){$notes = $argv[3];}else{echo "You did not define any notes, it will be set to 'No Notes'\n";$notes = 'No Notes';}
if(isset($argv[4])){$title = $argv[4];}else{echo "You did not define a Title, it will be set to 'Untitled'\n";$title='Untitled';}

$vs1dir = getcwd();
$vs1dir.="/vs1/";

if (file_exists($vs1dir)===FALSE){echo "You need to put some files in a folder named 'vs1' first.\nPlease do this first then run this again.\nDir:".$vs1dir; mkdir($vs1dir);}
// self aware of Script location and where to search for Txt files

echo "Directory: ".$vs1dir."\n\n";
echo "Files to Convert: \n";

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
		if ($file_e[$file_max-1]=='vs1' or $file_e[$file_max-1]=="VS1" or $file_e[$file_max-1]=="Vs1" or $file_e[$file_max-1]=="vS1")
		{
			$file_a[] = $file;
			echo $n." ".$file."\n";
			$n++;
		}else{
			echo "File not supported !\n";
		}
	}
}
echo "\n\n";
closedir($dh);
foreach($file_a as $file)
{
	$source = $vs1dir.$file;
	echo '################=== Start Import of '.$source.' ===################';
	echo "\n";
	import_vs1($source, $user, $notes, $title);
//	function  ( Source file , User that is importing, Notes for import, Title of Batch Import {will have "Batch: *title*" as title} )
}
$TOTAL_END = date("H:i:s");
echo "\nTOTAL Running time::\n\nStart: ".$TOTAL_START."\nStop : ".$TOTAL_END."\n";




#----------FUNCTIONS--------------#

	function import_vs1($source="" , $user="Unknown" , $notes="No Notes" , $title="UNTITLED" )
	{
	$times=date('Y-m-d H:i:s');
	if ($source == NULL){echo "There was an error suppling the file name to the function"; break;}
	include($wifidb.'/lib/config.inc.php');
	//	$gdata [ ID ] [ object ]
	//		   num     lat / long / sats / date / time
	if ($user == ""){$user="Unknown";}
	
	$user_n=0;
	$N=0;
	$n=0;
	$gpscount=0;
	$co=0;
	$cco=0;
	$apdata=array();
	$gpdata=array();
	$signals=array();
	$sats_id=array();
	$fileex=explode(".", $source);
	$return = file($source);
	$table_ptb="-";
	$count = count($return);
	if($count <= 8) { echo "You cannot upload an empty VS1 file, atleast scan for a few seconds to import some data."; break;}
	foreach($return as $ret)
	{
		if ($ret[0] == "#"){continue;}

		$retexp = explode("|",$ret);
		$ret_len = count($retexp);

		if ($ret_len == 6)
		{
			$date_exp = explode("-",$retexp[4]);
			if(strlen($date_exp[0]) <= 2)
			{
				$gpsdate = $date_exp[2]."-".$date_exp[0]."-".$date_exp[1];
			}else
			{
				$gpsdate = $retexp[4];
			}
			$gdata[$retexp[0]] = array("lat"=>$retexp[1], "long"=>$retexp[2],"sats"=>$retexp[3],"date"=>$gpsdate,"time"=>$retexp[5]);
			if ($GLOBALS["debug"]  == 1)
			{
				$gpecho = "GP Data : \r\n"
				."Return length: ".$ret_len."\n+-+-+-+-+\r\n"
				."ID: ".$retexp[0]."\n+-+-+-+-+\r\n"
				."Lat: ".$gdata[$retexp[0]]["lat"]."\n+-+-+-+-+\r\n"
				."Long: ".$gdata[$retexp[0]]["long"]."\n+-+-+-+-+\r\n"
				."Satellites: ".$gdata[$retexp[0]]["sats"]."\n+-+-+-+-+\r\n"
				."Date: ".$gdata[$retexp[0]]["date"]."\n+-+-+-+-+\r\n"
				."Time: ".$gdata[$retexp[0]]["time"]."+-+-+-+-+\r\r\n\n";
				echo $gpecho;
			}
			$gpscount++;
		}elseif($ret_len == 13)
		{
				$wifi = explode("|",$ret, 13);
				mysql_select_db($db,$conn);
				$dbsize = mysql_query("SELECT * FROM `$wtable`", $conn) or die(mysql_error());
				$size = mysql_num_rows($dbsize);
				$size++;
				if ($wifi[0]==""){$wifi[0]="UNNAMED";}
				$wifi[12]=strip_tags(smart_quotes($wifi[12]));
				// sanitize wifi data to be used in table name
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
					if ($GLOBALS["debug"]  ==1)
					{
						echo "	- DB Id => ".$APid." || ";
						echo "DB SSID => ".$ssid_ptb." (".$ssids_ptb.")\n ";
						echo "	- DB Mac => ".$mac_ptb." || ";
						echo "DB Radio => ".$radio_ptb."\n";
						echo "	- DB Auth => ".$sectype_ptb." || ";
						echo "DB Encry => ".$auth_ptb." ".$encry_ptb."\n";
						echo "	- DB Chan => ".$chan_ptb."\n";
						echo $table_ptb."\n";
					}
				}
				mysql_close($conn1);
				
				$btx=$wifi[8];
				$otx=$wifi[9];
				$nt=$wifi[10];
				$label = strip_tags(smart_quotes($wifi[11]));
				
				//create table name to select from, insert into, or create
				$table = $ssids.'-'.$macs.'-'.$sectype.'-'.$radios.'-'.$chan;
				$gps_table = $table.$gps_ext;
				
				if(strcmp($table,$table_ptb)===0)
				{
					// They are the same
					
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
					foreach($signal_exp as $exp)
					{
						//Create GPS Array for each Singal, because the GPS table is growing for each signal you need to re grab it to test the data
#						$DBresult = mysql_query("SELECT * FROM `$gps_table`", $conn);
#						while ($neArray = mysql_fetch_array($DBresult))
#						{
#							$db_gps[$neArray["id"]]["sats"]=$neArray["sats"];
#							$db_gps[$neArray["id"]]["lat"]=$neArray["lat"];
#							$db_gps[$neArray["id"]]["long"]=$neArray["long"];
#							$db_gps[$neArray["id"]]["date"]=$neArray["date"];
#							$db_gps[$neArray["id"]]["time"]=$neArray["time"];
#						}
						
						$esp = explode(",",$exp);
						$vs1_id = $esp[0];
						$signal = $esp[1];
						
						if ($GLOBALS["debug"]  === 1)
						{
							$apecho = "+-+-+-+AP Data+-+-+-+\n VS1 ID:".$vs1_id." \n Next DB ID: ".$gps_id."\n"
							."Lat: ".$gdata[$vs1_id]["lat"]."\n-+-+-+\n"
							."Long: ".$gdata[$vs1_id]["long"]."\n-+-+-+\n"
							."Satellites: ".$gdata[$vs1_id]["sats"]."\n-+-+-+\n"
							."Date: ".$gdata[$vs1_id]["date"]."\n-+-+-+\n"
							."Time: ".$gdata[$vs1_id]["time"]."-+-+-+\n\n\n";
							echo $apecho;
						}
					 #	$gpschk = database::check_gps_array($db_gps,$apdata[$ap_id]);
						
						$lat = $gdata[$vs1_id]["lat"];
						$long = $gdata[$vs1_id]["long"];
						$sats = $gdata[$vs1_id]["sats"];
						$date = $gdata[$vs1_id]["date"];
						$time = $gdata[$vs1_id]["time"];
						
						$comp = $lat.'-'.$long.'-'.$date.'-'.$time;
						
						$sql_gps = "SELECT * FROM `$gps_table` WHERE `time` = '$time' LIMIT 1";
						$GPSresult = mysql_query($sql_gps, $conn);
						#while(
						$gps_resarray = mysql_fetch_array($GPSresult);#)
						#{
#						echo count($gps_resarray);
							$dbsel = $gps_resarray['lat'].'-'.$gps_resarray['long'].'-'.$gps_resarray['date'].'-'.$gps_resarray['time'];
#							echo $dbsel."\n\n".$comp."\n";
#							echo "Lat: ".$gps_resarray['lat']."\nLong: ".$gps_resarray['long']."\nDate: ".$gps_resarray['date']."\nTime: ".$gps_resarray['time']."\n";
							if (strcmp($gps_resarray['date'],$date) && strcmp($gps_resarray['time'],$time) ){$todo = "db"; $db_id[] = $gps_resarray['id']; continue;}
							
							if(strcmp($comp, $dbsel) === 0)
							{
								if($sats > $gps_resarray['sats'])
								{
									$todo = "hi_sats";
									$hi_sats_id[]=$gps_resarray['id'];
								}else
								{
									$todo = "db";
									$db_id[] = $gps_resarray['id'];
								}
							}else
							{
								$todo = "new";
								$newGPS[]=array(
												"lat"=>$lat,
												"long"=>$long,
												"sats"=>$sats,
												"date"=>$date,
												"time"=>$time
												);
							}
						switch ($todo)
						{	
							case "new":
								$sqlitgpsgp = "INSERT INTO `$gps_table` ( `id` , `lat` , `long` , `sats` , `date` , `time` ) VALUES ( '$gps_id', '$lat', '$long', '$sats', '$date', '$time')";
								if (mysql_query($sqlitgpsgp, $conn))
								{
									echo "(3)Insert into [".$db_st."].{".$gps_table."}\n		 => Added GPS History to Table\n";
								}else
								{
									$sqlcgt = "CREATE TABLE `$gps_table` (`id` INT( 255 ) NOT NULL AUTO_INCREMENT ,`lat` VARCHAR( 25 ) NOT NULL , `long` VARCHAR( 25 ) NOT NULL , `sats` INT( 2 ) NOT NULL , `date` VARCHAR( 10 ) NOT NULL , `time` VARCHAR( 8 ) NOT NULL , INDEX ( `id` ) ) CHARACTER SET = latin1";
									if (mysql_query($sqlcgt, $conn))
									{
										echo "(1)Create Table [".$db_st."].{".$gps_table."}\n		 => Thats odd the table was missing, well I added a GPS Table for ".$ssids."\n";
										if (mysql_query($sqlitgpsgp, $conn)){echo "(3)Insert into [".$db_st."].{".$gps_table."}\n		 => Added GPS History to Table\n";}
									}
								}
								$signals[$gps_id] = $gps_id.",".$signal;
								$gps_id++;
								break;
							case "db":
				#				echo "GPS Point already in DB\n----".$db_id[0]."- <- DB ID\n";
								$signals[$gps_id] = $db_id[0].",".$signal;
								$gps_id++;
								break;
							case "hi_sats":
								foreach($hi_sats_id as $sats_id)
								{
									$sqlupgpsgp = "UPDATE `$gps_table` SET `lat`= '$lat' , `long` = '$long', `sats` = '$sats' , `date` = '$date' , `time` = '$time  WHERE `id` = '$sats_id'";
									if (mysql_query($sqlupgpsgp, $conn))
									{echo "(4)Update [".$db_st."].{".$gps_table."}\n		 => Updated GPS History in Table\n";}
									else{echo "A MySQL Update error has occured\n".mysql_error();}
								}
								$signals[$gps_id] = $hi_sats_id[0].",".$signal;
								$gps_id++;
								break;
						}
					}
					$sig = implode("-",$signals);
					$sqlit = "INSERT INTO `$table` ( `id` , `btx` , `otx` , `nt` , `label` , `sig`, `user` ) VALUES ( '', '$btx', '$otx', '$nt', '$label', '$sig', '$user')";
					
					$sqlit_ = "SELECT * FROM `$table`";
					$sqlit_res = mysql_query($sqlit_, $conn) or die(mysql_error());
					$sqlit_num_rows = mysql_num_rows($sqlit_res);
					$sqlit_num_rows++;
					$user_aps[$user_n]="1,".$APid.":".$sqlit_num_rows; //User import tracking //UPDATE AP
					$user_n++;
					
					if (mysql_query($sqlit, $conn))
					{
						echo "(3)Insert into [".$db_st."].{".$table."}\n		 => Add Signal History to Table\n";
					}else
					{
						$sqlct = "CREATE TABLE `$table` (`id` INT( 255 ) NOT NULL AUTO_INCREMENT , `btx` VARCHAR( 10 ) NOT NULL , `otx` VARCHAR( 10 ) NOT NULL , `nt` VARCHAR( 15 ) NOT NULL , `label` VARCHAR( 25 ) NOT NULL , `sig` TEXT NOT NULL , `user` VARCHAR(25) NOT NULL , INDEX ( `id` ) ) CHARACTER SET = latin1";
						if (mysql_query($sqlcgt, $conn) or die(mysql_error()))
						{
							echo "(1)Create Table [".$db_st."].{".$table."}\n		 => Thats odd the table was missing, well I added a Table for ".$ssids."\n";
							if (mysql_query($sqlit, $conn)or die(mysql_error()))
							{echo "(3)Insert into [".$db_st."].{".$table."}\n		 => Added GPS History to Table\n";}
						}
					}
				}else
				{
					mysql_select_db($db_st,$conn)or die(mysql_error());
					
					$sqlct = "CREATE TABLE `$table` (`id` INT( 255 ) NOT NULL AUTO_INCREMENT , `btx` VARCHAR( 10 ) NOT NULL , `otx` VARCHAR( 10 ) NOT NULL , `nt` VARCHAR( 15 ) NOT NULL , `label` VARCHAR( 25 ) NOT NULL , `sig` TEXT NOT NULL , `user` VARCHAR(25) NOT NULL , INDEX ( `id` ) ) CHARACTER SET = latin1";
					mysql_query($sqlct, $conn);
					echo "(1)Create Table [".$db_st."].{".$table."}\n		 => Added new Table for ".$ssids."\n";
					
					$sqlcgt = "CREATE TABLE `$gps_table` (`id` INT( 255 ) NOT NULL AUTO_INCREMENT ,`lat` VARCHAR( 25 ) NOT NULL , `long` VARCHAR( 25 ) NOT NULL , `sats` INT( 2 ) NOT NULL , `date` VARCHAR( 10 ) NOT NULL , `time` VARCHAR( 8 ) NOT NULL , INDEX ( `id` ) ) CHARACTER SET = latin1";
					mysql_query($sqlcgt, $conn);
					echo "(2)Create Table [".$db_st."].{".$gps_table."}\n		 => Added new GPS Table for ".$ssids."\n";
					$signal_exp = explode("-",$wifi[12]);
					$gps_id = 1;
					$N=0;
					foreach($signal_exp as $exp)
					{
						$esp = explode(",",$exp);
						$vs1_id = $esp[0];
						$signal = $esp[1];
						
						if ($GLOBALS["debug"]  ==1)
						{
							$apecho = "+-+-+-+AP Data+-+-+-+\n GPS ID:".$vs1_id." \n ID: ".$gps_id."\n"
							."Lat: ".$gdata[$vs1_id]["lat"]."\n-+-+-+\n"
							."Long: ".$gdata[$vs1_id]["long"]."\n-+-+-+\n"
							."Satellites: ".$gdata[$vs1_id]["sats"]."\n-+-+-+\n"
							."Date: ".$gdata[$vs1_id]["date"]."\n-+-+-+\n"
							."Time: ".$gdata[$vs1_id]["time"]."-+-+-+\n\n\n";
							echo $apecho;
						}
						$lat = $gdata[$vs1_id]["lat"];
						$long = $gdata[$vs1_id]["long"];
						$sats = $gdata[$vs1_id]["sats"];
						$date = $gdata[$vs1_id]["date"];
						$time = $gdata[$vs1_id]["time"];
						$sqlitgpsgp = "INSERT INTO `$gps_table` ( `id` , `lat` , `long` , `sats` , `date` , `time` ) VALUES ( '$gps_id', '$lat', '$long', '$sats', '$date', '$time')";
						if (mysql_query($sqlitgpsgp, $conn))
						{
							echo "(3)Insert into [".$db_st."].{".$gps_table."}\n		 => Added GPS History to Table\n";
						}else
						{
							$sqlcgt = "CREATE TABLE `$gps_table` (`id` INT( 255 ) NOT NULL AUTO_INCREMENT ,`lat` VARCHAR( 25 ) NOT NULL , `long` VARCHAR( 25 ) NOT NULL , `sats` INT( 2 ) NOT NULL , `date` VARCHAR( 10 ) NOT NULL , `time` VARCHAR( 8 ) NOT NULL , INDEX ( `id` ) ) CHARACTER SET = latin1";
							if (mysql_query($sqlcgt, $conn))
							{
								echo "(1)Create Table [".$db_st."].{".$gps_table."}\n		 => Thats odd the table was missing, well I added a GPS Table for ".$ssids."\n";
								if (mysql_query($sqlitgpsgp, $conn)){echo "(3)Insert into [".$db_st."].{".$gps_table."}\n		 => Added GPS History to Table\n";}
							}
						}
						$signals[$gps_id] = $gps_id.",".$signal;
						$gps_id++;

					}
					$sig = implode("-",$signals);
					
					$sqlit = "INSERT INTO `$table` ( `id` , `btx` , `otx` , `nt` , `label` , `sig`, `user` ) VALUES ( '', '$btx', '$otx', '$nt', '$label', '$sig', '$user')";
					mysql_query($sqlit, $conn) or die(mysql_error());
					echo "(3)Insert into [".$db_st."].{".$table."}\n		 => Add Signal History to Table\n";
					
					# pointers
					mysql_select_db($db,$conn);
					$sqlp = "INSERT INTO `$wtable` ( `id` , `ssid` , `mac` ,  `chan`, `radio`,`auth`,`encry`, `sectype` ) VALUES ( '$size', '$ssidss', '$macs','$chan', '$radios', '$authen', '$encryp', '$sectype')";
					if (mysql_query($sqlp, $conn) or die(mysql_error()))
					{
						echo "(1)Insert into [".$db."].{".$wtable."} => Added Pointer Record\n";
						$user_aps[$user_n]="0,".$size.":1";
						$user_n++;
						$sqlup = "UPDATE `$settings_tb` SET `size` = '$size' WHERE `table` = '$wtable' LIMIT 1;";
						if (mysql_query($sqlup, $conn) or die(mysql_error()))
						{
							
							echo 'Updated ['.$db.'].{'.$wtable."} with new Size \n		=> ".$size."\n";
							
						}else
						{
							echo mysql_error()." => Could not Add new pointer to table (this has been logged) \n";
						}
					}else{echo "Something went wrong, I couldn't add in the pointer :-( \n";}
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
			echo "Text files are no longer supported,\nPlease save your list as a VS1 file or use\nthe Extra->Wifidb menu option in Vistumbler \n-> http://www.vistumbler.net";
			$filename = $_SERVER['SCRIPT_FILENAME'];	
			footer($filename);
			die();
		}else{echo "There is something wrong with the file you uploaded,\n check and make sure it is a valid VS1 file \n-> http://vistumbler.wiki.sourceforge.net/VS1+Format";}
	}
	mysql_select_db($db,$conn);
	$user_ap_s = implode("-",$user_aps);
	$notes = addslashes($notes);
	$title = "Batch: ".$title;
	echo $times."\n";
	if (!$user_ap_s == "")
	{$sqlu = "INSERT INTO `users` ( `id` , `username` , `points` ,  `notes`, `date`, `title`) VALUES ( '', '$user', '$user_ap_s','$notes', '$times', '$title')";
	mysql_query($sqlu, $conn) or die(mysql_error());}
	mysql_close($conn);
	echo "\nDONE!";
	}
?>