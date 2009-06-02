<?php
//YAY FUNCTIONS!!!, well they have to tell the daemon how to do something
require_once('config.inc.php');
require $GLOBALS['wifidb_install']."/lib/database.inc.php";
require $GLOBALS['wifidb_install']."/lib/config.inc.php";
date_default_timezone_set($timezn);
global $vers;
$vers = array(
			"WiFiDB_Daemon"				=>	"1.3",
			"Last_Daemon_Core_Edit" 	=> 	"2009-Jun-02",
			"Misc"						=> array(
												"logd"			=>	"1.1",
												"verbosed"		=>	"1.1",
												),
			"daemon_ext_import_vs1"		=>	"1.2"
			);
#========================================================================================================================#
#											verbose (Echos out a message to the screen or page)							 #
#========================================================================================================================#

function verbosed($message = "", $level = 0, $header = 0)
{
	require('config.inc.php');
	$time = time()+$DST;
	$datetime = date("Y-m-d H:i:s",$time);
	if($message != '')
	{
		if($header == 0)
		{
			$message = $datetime."   ->    ".$message;
		}	
		if($level==1)
		{
			echo $message."\n";
		}
	}else
	{
		echo "Verbose was told to write a blank string";
	}
}

function logd($message = '', $log_interval = 0, $details = 0,  $log_level = 0)
{
	require('config.inc.php');
	if($log_level != 0)
	{
		if($message == ''){echo "Logd was told to write a blank string.\nThis has NOT been logged.\nThis will NOT be allowed!\n"; continue;}
		$date = date("y-m-d");
		$time = time()+$DST;
		$datetime = date("Y-m-d H:i:s",$time);
		$message = $datetime."   ->    ".$message."\r\n";
		include('config.inc.php');
		if($log_interval==1)
		{
			$cidir = getcwd();
			$filename = '/CLI/log/wifidbd_log.log';
			if(!is_file($filename))
			{
				fopen($filename, "w");
			}
			$fileappend = fopen($filename, "a");
			if($log_level == 2 && $details == 0){$log_level = 1;}
			if($log_level == 2)
			{
				$message = $message."\n==Details==\n".$detail."\n===========\n";
			}
			$write_message = fwrite($fileappend, $message);
			if(!$write_message){die("Could not write message to the file, thats not good...");}
		}elseif($log_interval==1)
		{
			$cidir = getcwd();
			$filename = '/CLI/log/wifidbd_'.$date.'_log.log';
			if(!is_file($filename))
			{
				fopen($filename, "w");
			}
			$fileappend = fopen($filename, "a");
			if($log_level == 2 && $details == 0){$log_level = 1;}
			if($log_level == 1)
			{
				$message = $message."\n==Details==\n".$detail."\n===========\n";
			}
			$write_message = fwrite($fileappend, $message);
			if(!$write_message){die("Could not write message to the file, thats not good...");}
		}
	}
}

class daemon extends database
{
	function importvs1($source="" , $user="Unknown" , $notes="No Notes" , $title="UNTITLED", $verbose = 0 )
	{
		if ($source == NULL)
		{
			logd("There was an error sending the file name to the function", $log_interval, 0,  $log_level);
			verbosed("There was an error sending the file name to the function", $verbose);
			break;
		}
		$return  = file($source);
		$count = count($return);
		
		$file_row =  0;
		require $GLOBALS['wifidb_install']."/lib/config.inc.php";
		require 'config.inc.php';
		
		$file_exp = explode("/", $source);
		$file_exp_seg = count($file_exp);
		$file1 = $file_exp[$file_exp_seg-1];
		
		$FILENUM = 1;
		$start = microtime(true);
		$times=date('Y-m-d H:i:s');
		
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
		
		$file_row =  0;
		if($count <= 8) 
		{
			logd("You cannot upload an empty VS1 file, at least scan for a few seconds to import some data.", $log_interval, 0,  $log_level);
			verbosed("You cannot upload an empty VS1 file, at least scan for a few seconds to import some data.", $verbose);

			break;
		}
		mysql_select_db($db,$conn);
		
		
#		$result = mysql_query("SELECT `row` FROM `$db`.`files_tmp` WHERE `file` LIKE '$file1' LIMIT 1", $conn);
#		$newArray = mysql_fetch_array($result);
		$sqlu = "INSERT INTO `$db`.`users` ( `id` , `username` , `points` ,  `notes`, `date`, `title` , `aps`, `gps`) VALUES ( '', '$user', '','$notes', '', '$title', '', '')";
		$user_row_new_result = mysql_query("SELECT `id` FROM `$db`.`users` ORDER BY `id` DESC LIMIT 1", $conn);
		if(!$user_row_new_result)
		{
			logd("Could not reserve user import row!\r\n".mysql_error($conn), $log_interval, 0,  $log_level);
			verbosed("Could not reserve user import row!\n".mysql_error($conn), $verbose);
			die();
		}
		$user_row_result = mysql_query("SELECT `id` FROM `$db`.`users` ORDER BY `id` DESC LIMIT 1", $conn);
		$user_row_array = mysql_fetch_array($user_row_result);
		$user_row_id = $user_row_array['id'];  //STILL NEED TO IMPLEMENT THIS, ONLY JUST STARTED
		
		foreach($return as $ret)
		{
#			if($file_row != $newArray['row'] AND $newArray['row'] != 0 AND $newArray['row'] >= $file_row )
#			{
#				continue;
#			}else
#			{
#				$file_row++;
#			}
			if ($ret[0] == "#"){continue;}
			
			$retexp = explode("|",$ret);
			$ret_len = count($retexp);
			
			if ($ret_len == 12 or $ret_len == 6)
			{
				list($gdata[$retexp[0]], $gpscount) = database::gen_gps($retexp, $gpscount);
			}elseif($ret_len == 13)
			{
					if(!isset($SETFLAGTEST))
					{
						$count = $count - $gpscount;
						$count = $count - 8;
						if($count == 0) 
						{
							logd("This File does not have any APs to import, just a bunch of GPS cords.", $log_interval, 0,  $log_level);
							verbosed("This File does not have any APs to import, just a bunch of GPS cords.", $verbose);
							$user_aps = "";
							break;
						}
					}
					$SETFLAGTEST = TRUE;
					$wifi = explode("|",$ret, 13);
					if($wifi[0] == "" && $wifi[1] == "" && $wifi[5] == "" && $wifi[6] == "" && $wifi[7] == ""){continue;}
					mysql_select_db($db,$conn);
					$dbsize = mysql_query("SELECT `id` FROM `$wtable` ORDER BY `id` DESC LIMIT 1", $GLOBALS['conn']);
					$size1 = mysql_fetch_array($dbsize);
					$size = $size1['id']+0;
					$size++;
					
					//You cant have any blank data, thats just rude...
					if($wifi[0] == ''){$wifi[0]="UNNAMED";}
					if($wifi[1] == ''){$wifi[1] = "00:00:00:00:00:00";}
					if($wifi[5] == ''){$wifi[5] = "0";}
					if($wifi[6] == ''){$wifi[6] = "u";}
					if($wifi[7] == ''){$wifi[7] = "0";}
					
					// sanitize wifi data to be used in table name
					$ssids = filter_var($wifi[0], FILTER_SANITIZE_SPECIAL_CHARS);
					$ssidss = smart_quotes($ssids);
					$ssidsss = str_split($ssidss,25); //split SSID in two at is 25th char.
					$ssid_S = $ssidsss[0]; //Use the 25 char long word for the APs table name, this is due to a limitation in MySQL table name lengths, 
										  //the rest of the info will suffice for unique table names
					$this_of_this = $FILENUM." / ".$count;
					$sqlup = "UPDATE `files_tmp` SET `importing` = '1', `tot` = '$this_of_this', `ap` = '$ssids', `row` = '$file_row' WHERE `file` = '$file1';";
					if (mysql_query($sqlup, $conn) or die(mysql_error($conn)))
					{
						logd("Updated files_tmp table with this runs data.", $log_interval, 0,  $log_level);
						verbosed("Updated files_tmp table with this runs data.", $verbose);
					}
					
					$mac1 = explode(':', $wifi[1]);
					$macs = $mac1[0].$mac1[1].$mac1[2].$mac1[3].$mac1[4].$mac1[5]; //the APs table doesnt need :'s in its name, nor does the Pointers table, well it could I just dont want to
					
					$authen		=	filter_var($wifi[3], FILTER_SANITIZE_SPECIAL_CHARS);
					$encryp		=	filter_var($wifi[4], FILTER_SANITIZE_SPECIAL_CHARS);
					$sectype	=	filter_var($wifi[5], FILTER_SANITIZE_SPECIAL_CHARS);
					$chan		=	filter_var($wifi[7], FILTER_SANITIZE_SPECIAL_CHARS);
					$chan=$chan+0;
					$btx		=	filter_var($wifi[8], FILTER_SANITIZE_SPECIAL_CHARS);
					$otx		=	filter_var($wifi[9], FILTER_SANITIZE_SPECIAL_CHARS);
					$nt			=	filter_var($wifi[10], FILTER_SANITIZE_SPECIAL_CHARS);
					$label		=	filter_var($wifi[11], FILTER_SANITIZE_SPECIAL_CHARS);
					$san_sig	=	filter_var($wifi[12], FILTER_SANITIZE_SPECIAL_CHARS);
					
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
					
					$conn1 = mysql_connect($host, $db_user, $db_pwd);
					mysql_select_db($db,$conn1);
					$result = mysql_query("SELECT * FROM `$wtable` WHERE `mac` LIKE '$macs'", $conn1) or die(mysql_error($conn1));
					$rows = mysql_num_rows($result);
					$newArray = mysql_fetch_array($result);
					$result_count = count($rows);
					if($result_count > 1)
					{
						$result = mysql_query("SELECT * FROM `$wtable` WHERE `mac` LIKE '$macs' AND `ssid` LIKE '$ssids'", $conn1) or die(mysql_error($conn1));
						$rows = mysql_num_rows($result);
						$newArray = mysql_fetch_array($result);
						$result_count = count($rows);
						if($result_count > 1)
						{	
							$result = mysql_query("SELECT * FROM `$wtable` WHERE `mac` LIKE '$macs' AND `ssid` LIKE '$ssids' AND `chan` LIKE '$chan'", $conn1) or die(mysql_error($conn1));
							$rows = mysql_num_rows($result);
							$newArray = mysql_fetch_array($result);
							$result_count = count($rows);
							if($result_count > 1)
							{	
								$result = mysql_query("SELECT * FROM `$wtable` WHERE `mac` LIKE '$macs' AND `ssid` LIKE '$ssids' AND `chan` LIKE '$chan' AND `sectype` LIKE '$sectype'", $conn1) or die(mysql_error($conn1));
								$rows = mysql_num_rows($result);
								$newArray = mysql_fetch_array($result);
								$result_count = count($rows);
								if($result_count > 1)
								{	
									$result = mysql_query("SELECT * FROM `$wtable` WHERE `mac` LIKE '$macs'  AND `ssid` LIKE '$ssids' AND `chan` LIKE '$chan' AND `sectype` LIKE '$sectype' AND `radio` LIKE '$radios'", $conn1) or die(mysql_error($conn1));
									$rows = mysql_num_rows($result);
									$newArray = mysql_fetch_array($result);
									$result_count = count($rows);
									if($result_count > 1)
									{	
										echo "There are too many Pointers for this one Access Point, defaulting to the first one in the list";
										$result = mysql_query("SELECT * FROM `$wtable` WHERE `mac` LIKE '$macs'  AND `ssid` LIKE '$ssids' AND `chan` LIKE '$chan' AND `sectype` LIKE '$sectype' AND `radio` LIKE '$radios'", $conn1) or die(mysql_error($conn1));
										$rows = mysql_num_rows($result);
										$newArray = mysql_fetch_array($result);
										$APid = $newArray['id'];
										$ssid_ptb_ = $newArray["ssid"];
										$ssids_ptb = str_split(smart_quotes($newArray['ssid']),25);
										$ssid_ptb = $ssids_ptb[0];
										$mac_ptb=$newArray['mac'];
										$radio_ptb=$newArray['radio'];
										$sectype_ptb=$newArray['sectype'];
										$auth_ptb=$newArray['auth'];
										$encry_ptb=$newArray['encry'];
										$chan_ptb=$newArray['chan'];
										$table_ptb = $ssid_ptb.'-'.$mac_ptb.'-'.$sectype_ptb.'-'.$radio_ptb.'-'.$chan_ptb;
									}
								}else
								{
									$APid = $newArray['id'];
									$ssid_ptb_ = $newArray["ssid"];
									$ssids_ptb = str_split(smart_quotes($newArray['ssid']),25);
									$ssid_ptb = $ssids_ptb[0];
									$mac_ptb=$newArray['mac'];
									$radio_ptb=$newArray['radio'];
									$sectype_ptb=$newArray['sectype'];
									$auth_ptb=$newArray['auth'];
									$encry_ptb=$newArray['encry'];
									$chan_ptb=$newArray['chan'];
									$table_ptb = $ssid_ptb.'-'.$mac_ptb.'-'.$sectype_ptb.'-'.$radio_ptb.'-'.$chan_ptb;
								}
							}else
							{
								$APid = $newArray['id'];
								$ssid_ptb_ = $newArray["ssid"];
								$ssids_ptb = str_split(smart_quotes($newArray['ssid']),25);
								$ssid_ptb = $ssids_ptb[0];
								$mac_ptb=$newArray['mac'];
								$radio_ptb=$newArray['radio'];
								$sectype_ptb=$newArray['sectype'];
								$auth_ptb=$newArray['auth'];
								$encry_ptb=$newArray['encry'];
								$chan_ptb=$newArray['chan'];
								$table_ptb = $ssid_ptb.'-'.$mac_ptb.'-'.$sectype_ptb.'-'.$radio_ptb.'-'.$chan_ptb;
							}
						}else
						{
							$APid = $newArray['id'];
							$ssid_ptb_ = $newArray["ssid"];
							$ssids_ptb = str_split(smart_quotes($newArray['ssid']),25);
							$ssid_ptb = $ssids_ptb[0];
							$mac_ptb=$newArray['mac'];
							$radio_ptb=$newArray['radio'];
							$sectype_ptb=$newArray['sectype'];
							$auth_ptb=$newArray['auth'];
							$encry_ptb=$newArray['encry'];
							$chan_ptb=$newArray['chan'];
							$table_ptb = $ssid_ptb.'-'.$mac_ptb.'-'.$sectype_ptb.'-'.$radio_ptb.'-'.$chan_ptb;
						}
					}else
					{
						$APid = $newArray['id'];
						$ssid_ptb_ = $newArray["ssid"];
						$ssids_ptb = str_split(smart_quotes($newArray['ssid']),25);
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
					
					//create table name to select from, insert into, or create
					$table = $ssid_S.'-'.$macs.'-'.$sectype.'-'.$radios.'-'.$chan;
					$gps_table = $table.$gps_ext;
					
					if(!isset($table_ptb)){$table_ptb="";}
					
					if($table == $table_ptb)
					{
						// They are the same
						logd($this_of_this."   ( ".$APid." )   ||   ".$table." - is being updated ", $log_interval, 0,  $log_level);
						verbosed($this_of_this."   ( ".$APid." )   ||   ".$table." - is being updated ", $verbose);
						
						mysql_select_db($db_st,$conn);
						//setup ID number for new GPS cords
						$DB_result = mysql_query("SELECT * FROM `$gps_table`", $conn);
						$gpstableid = mysql_num_rows($DB_result);
						if ( $gpstableid === 0)
						{
							$gps_id = 1;
						}
						else
						{
							//if the table is already populated set it to the last ID's number
							$gps_id = $gpstableid;
							$gps_id++;
						}
						//pull out all GPS rows to be tested against for duplicates
							
						$N=0;
						$prev='';
						$sql_multi = array();
						$signal_exp = explode("-",$san_sig);
						$NNN = 0;
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
							if(!isset($db_gps)){$db_gps = array();}
							list($return_gps, $dbid) = database::check_gps_array($db_gps,$comp, $gps_table);
						#	echo $return_gps."\n";
						#	echo $dbid."\n";
							$DBresult = mysql_query("SELECT * FROM `$gps_table` WHERE `id` = '$dbid'", $conn);
							$GPSDBArray = mysql_fetch_array($DBresult);
							if($return_gps === 0)
							{
								$sql_multi[$NNN] = "INSERT INTO `$gps_table` ( `id` , `lat` , `long` , `sats`, `hdp`, `alt`, `geo`, `kmh`, `mph`, `track` , `date` , `time` ) VALUES ( '$gps_id', '$lat', '$long', '$sats', '$hdp', '$alt', '$geo', '$kmh', '$mph', '$track', '$date', '$time')";
						#		$sqlitgpsgp = "INSERT INTO `$gps_table` ( `id` , `lat` , `long` , `sats`, `hdp`, `alt`, `geo`, `kmh`, `mph`, `track` , `date` , `time` ) VALUES ( '$gps_id', '$lat', '$long', '$sats', '$hdp', '$alt', '$geo', '$kmh', '$mph', '$track', '$date', '$time')";
						#		if (!mysql_query($sqlitgpsgp, $GLOBALS['conn']))
						#		{
						#			logd("There was an Error inserting the GPS information" , $log_interval, 0,  $log_level);
						#			verbosed("There was an Error inserting the GPS information", $verbose);
						#		}
								$signals[$gps_id] = $gps_id.",".$signal;
								
								$gps_id++;
							#	break;
							}elseif($return_gps === 1)
							{
								if($sats > $GPSDBArray['sats'])
								{
									$sql_multi[$NNN] = "DELETE FROM `$db_st`.`$gps_table` WHERE `$gps_table`.`id` = '$dbid' AND `$gps_table`.`lat` LIKE '$lat' AND `$gps_table`.`long` = '$long' LIMIT 1";
									$NNN++;
									$sql_multi[$NNN] = "INSERT INTO `$gps_table` ( `id` , `lat` , `long` , `sats`, `hdp`, `alt`, `geo`, `kmh`, `mph`, `track` , `date` , `time` ) VALUES ( '$gps_id', '$lat', '$long', '$sats', '$hdp', '$alt', '$geo', '$kmh', '$mph', '$track', '$date', '$time')";
						#			$sqlupgpsgp = "UPDATE `$gps_table` SET `lat`= '$lat' , `long` = '$long', `sats` = '$sats', `hdp` = '$hdp', `alt` = '$alt', `geo` = '$geo', `kmh` = '$kmh', `mph` = '$mph', `track` = '$track' , `date` = '$date' , `time` = '$time'  WHERE `id` = '$dbid'";
						#			$resource = mysql_query($sqlupgpsgp, $GLOBALS['conn']);
						#			if (!$resource)
						#			{
						#				logd("A MySQL Update error has occured\r\n".mysql_error($GLOBALS['conn']) , $log_interval, 0,  $log_level);
						#				verbosed("A MySQL Update error has occured\n".mysql_error($GLOBALS['conn']), $verbose);
						#			}
									$signals[$gps_id] = $dbid.",".$signal;
									$gps_id++;
							#		continue;
								}else
								{
									$signals[$gps_id] = $dbid.",".$signal;
									$gps_id++;
								}
							}else
							{
								echo "there was an error running gps check";
								die();
							}
							$NNN++;
							if($verbose == 1){echo ".";}
						}
						if($verbose == 1){echo "\n";}
						$mysqli = new mysqli($host, $db_user, $db_pwd, $db_st);
						if (mysqli_connect_errno())
						{
							printf("Connect failed: %s\n", mysqli_connect_error());
							exit();
						}
						$query = implode(";", $sql_multi);
						if($query != '')
						{
							try {
								$res = $mysqli->query($query);
							}catch (mysqli_sql_exception $e) {
								print "Error Code <br>".$e->getCode();
								print "Error Message <br>".$e->getMessage();
								print "Strack Trace <br>".nl2br($e->getTraceAsString());
								die();
							}
						}
						$sig = implode("-",$signals);
						$sqlit = "INSERT INTO `$table` ( `id` , `btx` , `otx` , `nt` , `label` , `sig`, `user` ) VALUES ( '', '$btx', '$otx', '$nt', '$label', '$sig', '$user')";
						if (!mysql_query($sqlit, $conn))
						{
							logd("FAILED to added GPS History to Table\r\n".mysql_error($conn), $log_interval, 0,  $log_level);
							verbosed("FAILED to added GPS History to Table\n".mysql_error($conn), $verbose);
						}
						
						$sqlit_ = "SELECT * FROM `$table`";
						$sqlit_res = mysql_query($sqlit_, $conn) or die(mysql_error());
						$sqlit_num_rows = mysql_num_rows($sqlit_res);
						$sqlit_num_rows++;
						$user_aps[$user_n]="1,".$APid.":".$sqlit_num_rows; //User import tracking //UPDATE AP
						
						logd($user_aps[$user_n], $log_interval, 0,  $log_level);
						verbosed($user_aps[$user_n], $verbose);
						$user_n++;
						
						$updated++;
					}else
					{
						// NEW AP
						logd($this_of_this."   ( ".$size." )   ||   ".$table." - is Being Imported", $log_interval, 0,  $log_level);
						verbosed($this_of_this."   ( ".$size." )   ||   ".$table." - is Being Imported", $verbose);
						
						mysql_select_db($db_st,$conn)or die(mysql_error($conn));
						$sqlct = "CREATE TABLE `$table` (`id` INT( 255 ) NOT NULL AUTO_INCREMENT , `btx` VARCHAR( 10 ) NOT NULL , `otx` VARCHAR( 10 ) NOT NULL , `nt` VARCHAR( 15 ) NOT NULL , `label` VARCHAR( 25 ) NOT NULL , `sig` TEXT NOT NULL , `user` VARCHAR(25) NOT NULL ,PRIMARY KEY (`id`) ) ENGINE = 'InnoDB' DEFAULT CHARSET='utf8'";
				#		echo "(1)Create Table [".$db_st."].{".$table."}\n		 => Added new Table for ".$ssids."\n";
						if(!mysql_query($sqlct, $conn))
						{
							logd("FAILED to create Signal History Table \r\n".mysql_error($conn), $log_interval, 0,  $log_level);
							verbosed("FAILED to create Signal History Table\n".mysql_error($conn), $verbose);
						}
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
									."INDEX ( `id` ) ) ENGINE = 'InnoDB' DEFAULT CHARSET='utf8'";
						$create_table = mysql_query($sqlcgt, $conn);
						if(!$create_table)
						{
							logd("FAILED to create GPS History Table \r\n".mysql_error($conn), $log_interval, 0,  $log_level);
							verbosed("FAILED to create GPS History Table\n".mysql_error($conn), $verbose);
						}
						$signal_exp = explode("-",$san_sig);
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
												   ."VALUES ( '$gps_id', '$lat', '$long', '$sats', '$hdp', '$alt', '$geo', '$kmh', '$mph', '$track', '$date', '$time')";
							if(!mysql_query($sqlitgpsgp, $conn))
							{
								logd("FAILED to insert the GPS data.\r\n".mysql_error($conn), $log_interval, 0,  $log_level);
								verbosed("FAILED to insert the GPS data.\n".mysql_error($conn), $verbose);
							}
							$signals[$gps_id] = $gps_id.",".$signal;
					#		echo $signals[$gps_id];
							$gps_id++;
							$prev = $vs1_id;
							if($verbose == 1){echo ".";}
						}
						if($verbose == 1){echo "\n";}
						$sig = implode("-",$signals);
						
						$sqlit = "INSERT INTO `$table` ( `id` , `btx` , `otx` , `nt` , `label` , `sig`, `user` ) VALUES ( '', '$btx', '$otx', '$nt', '$label', '$sig', '$user')";
						$insertsqlresult = mysql_query($sqlit, $conn);
		#				echo "(3)Insert into [".$db_st."].{".$table."}\n		 => Add Signal History to Table\n";
						if(!$insertsqlresult)
						{
							logd("FAILED to insert the Signal data.\r\n".mysql_error($conn), $log_interval, 0,  $log_level);
							verbosed("FAILED to insert the Signal data.\n".mysql_error($conn), $verbose);
						}
						# pointers
						mysql_select_db($db,$conn);
						$sqlp = "INSERT INTO `$wtable` ( `id` , `ssid` , `mac` ,  `chan`, `radio`,`auth`,`encry`, `sectype` ) VALUES ( '', '$ssid_S', '$macs','$chan', '$radios', '$authen', '$encryp', '$sectype')";
						if (mysql_query($sqlp, $conn))
						{
			#				echo "(1)Insert into [".$db."].{".$wtable."} => Added Pointer Record\n";
							$user_aps[$user_n]="0,".$size.":1";
							$user_n++;
							$sqlup = "UPDATE `$settings_tb` SET `size` = '$size' WHERE `table` = '$wtable' LIMIT 1;";
							if (mysql_query($sqlup, $conn))
							{
			#					echo 'Updated ['.$db.'].{'.$wtable."} with new Size \n		=> ".$size."\n";
								logd("Updated Settings table with new size", $log_interval, 0,  $log_level);
								verbosed("Updated Settings table with new size", $verbose);
							}else
							{
								logd("Error Updating Settings table with new size\r\n".mysql_error($conn), $log_interval, 0,  $log_level);
								verbosed("Error Updating Settings table with new size\n".mysql_error($conn), $verbose);
							}
						}else
						{
							logd("Error Updating Pointers table with new AP\r\n".mysql_error($conn), $log_interval, 0,  $log_level);
							verbosed("Error Updating Pointers table with new AP\r\n".mysql_error($conn), $verbose);
						}
						$imported++;
					}
					$FILENUM++;
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
				logd("Text files are no longer supported, please save your list as a VS1 file or use the Extra->Wifidb menu option in Vistumbler", $log_interval, 0,  $log_level);
				verbosed("Text files are no longer supported, please save your list as a VS1 file or use the Extra->Wifidb menu option in Vistumbler", $verbose);
				break;
			}elseif($ret_len == 0)
			{
				logd("There is something wrong with the file you uploaded, check and make sure it is a valid VS1 file and try again", $log_interval, 0,  $log_level);
				verbosed("There is something wrong with the file you uploaded, check and make sure it is a valid VS1 file and try again", $verbose);
				break;
			}else
			{
				logd("There is something wrong with the file you uploaded, check and make sure it is a valid VS1 file and try again", $log_interval, 0,  $log_level);
				verbosed("There is something wrong with the file you uploaded, check and make sure it is a valid VS1 file and try again", $verbose);
				break;
			}
		}
		mysql_select_db($db,$conn);
		
		if(is_array($user_aps))
		{
			$user_ap_s = implode("-",$user_aps);
		}else
		{
			$user_ap_s = "";
		}
		$notes = addslashes($notes);
		
		if($title === ''){$title = "Untitled";}
		if($user === ''){$user="Unknown";}
		if($notes === ''){$notes="No Notes";}
		$hash = hash_file('md5', $source);
		$total_ap = count($user_aps);
		$gdatacount = count($gdata);
#		if($user_ap_s != "")
#		{
			$sqlu = "INSERT INTO `$db`.`users` ( `id` , `username` , `points` ,  `notes`, `date`, `title` , `aps`, `gps`, `hash`) VALUES ( '', '$user', '$user_ap_s','$notes', '$times', '$title', '$total_ap', '$gdatacount', '$hash')";
			if(!mysql_query($sqlu, $conn))
			{
				logd("Failed to Insert User data into Users table\n".mysql_error($conn), $log_interval, 0,  $log_level);
				verbosed("Failed to Insert User data into Users table\n".mysql_error($conn), $verbose);
				die();
			}else
			{
				logd("Succesfully Inserted User data into Users table", $log_interval, 0,  $log_level);
				verbosed("Succesfully Inserted User data into Users table", $verbose);
			}
			
#		}
		echo "\nFile DONE!\n|\n|\n";
		$end = microtime(true);
		$times = array(
						"aps"	=> $total_ap,
						"gps" => $gdatacount
						);
		return $times;
	}
}
?>