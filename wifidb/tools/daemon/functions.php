<?php
//YAY FUNCTIONS!!!, well they have to tell the daemon how to do something
require_once $GLOBALS['wifidb_install']."/lib/database.inc.php";
function logd($message = '', $log_interval = 0, $details = 0,  $log_level = 0)
{
	if($message == ''){echo "Logd was told to write a blank string, this has NOT been logged.\n and will not be allowed\n"; continue;}
	$date = date("y-m-d");
	$message = date("Y-m-d H:i:s.").microtime(true)."   ->    ".$message."\r\n";
	include('config.inc.php');
	if($log_interval==0)
	{
		$cidir = getcwd();
		$filename = $GLOBALS['wifidb_tools'].'/log/wifidbd_log.log';
		if(!file_exists($filename))
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
		if(!$write_message){die("Could not message to the file, thats not good...");}
	}elseif($log_interval==1)
	{
		$cidir = getcwd();
		$filename = $GLOBALS['wifidb_tools'].'/log/wifidbd_'.$date.'_log.log';
		if(!file_exists($filename))
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
		if(!$write_message){die("Could not message to the file, thats not good...");}
	}
	fclose($fileappend);
}

	function check_file($file = '')
	{
		include($GLOBALS['wifidb_install'].'/lib/config.inc.php');
		$file1 = $GLOBALS['wifidb_install'].'/import/up/'.$file;
		$hash = hash_file('md5', $file);
		$size = (filesize($file)/1024);
		
		$file_exp = explode("/", $file);
		$file_exp_seg = count($file_exp);
		$file1 = $file_exp[$file_exp_seg-1];

		mysql_select_db($db,$GLOBALS['conn']);
		$fileq = mysql_query("SELECT * FROM `files` WHERE `file` LIKE '$file1'", $GLOBALS['conn']);
		$fileqq = mysql_fetch_array($fileq);

		if( $hash != $fileqq['hash'] )
		{
			return 1;
		}else
		{
			return 0;
		}
	}

	function insert_file($file = '', $totalaps = 0, $totalgps = 0, $user="Unknown", $notes="No Notes", $title="Untitled")
	{
		include($GLOBALS['wifidb_install'].'/lib/config.inc.php');
		
		$size = (filesize($file)/1024);
		$hash = hash_file('md5', $file);
		$date = date("y-m-d H:i:s");
		mysql_select_db($db,$GLOBALS['conn']);
		
		$file_exp = explode("/", $file);
		$file_exp_seg = count($file_exp);
		$file1 = $file_exp[$file_exp_seg-1];
		
		$sql = "INSERT INTO `wifi`.`files` ( `id` , `file` , `size` , `date` , `aps` , `gps` , `hash`, `user` , `notes` , `title`	)
									VALUES ( NULL , '$file1', '$size', '$date' , '$totalaps', '$totalgps', '$hash' , '$user' , '$notes' , '$title' )";
		if(mysql_query($sql, $GLOBALS['conn']))
		{
			return 1;
		}else
		{
			$A = array( 0=>'0', 'error' => mysql_error($GLOBALS['conn']));
			return $A;
		}
	}

class daemon extends database
{
	function import_vs1($source="" , $user="Unknown" , $notes="No Notes" , $title="UNTITLED", $verbose = 0 )
	{
		require $GLOBALS['wifidb_install']."/lib/config.inc.php";
		require 'config.inc.php';
		
		$FILENUM = 1;
		$start = microtime(true);
		$times=date('Y-m-d H:i:s');
		
		if ($source == NULL)
		{
			logd("There was an error sending the file name to the function", $log_interval, 0,  $log_level);
			verbose("There was an error sending the file name to the function", $verbose);
			break;
		}

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
		if($count <= 8) 
		{
			logd("You cannot upload an empty VS1 file, at least scan for a few seconds to import some data.", $log_interval, 0,  $log_level);
			verbose("You cannot upload an empty VS1 file, at least scan for a few seconds to import some data.", $verbose);

			break;
		}
		foreach($return as $ret)
		{
			if ($ret[0] == "#"){continue;}
			
			$retexp = explode("|",$ret);
			$ret_len = count($retexp);
			
			if ($ret_len == 12)
			{
				list($gdata[$retexp[0]], $gpscount) = database::gen_gps($retexp, $gpscount);
			}elseif($ret_len == 6)
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
							verbose("This File does not have any APs to import, just a bunch of GPS cords.", $verbose);
							$user_aps = "";
							break;
						}
					}
					$SETFLAGTEST = TRUE;
					$wifi = explode("|",$ret, 13);
					if($wifi[0] == "" && $wifi[1] == "" && $wifi[5] == "" && $wifi[6] == "" && $wifi[7] == ""){continue;}
					mysql_select_db($db,$GLOBALS['conn']);
					$dbsize = mysql_query("SELECT * FROM `$wtable`", $GLOBALS['conn']);
					$size = mysql_num_rows($dbsize);
					$size++;
					
					//You cant have any blank data, thats just rude...
					if($wifi[0] == ''){$wifi[0]="UNNAMED";}
					if($wifi[1] == ''){$wifi[1] = "00:00:00:00:00:00";}
					if($wifi[5] == ''){$wifi[5] = "0";}
					if($wifi[6] == ''){$wifi[6] = "u";}
					if($wifi[7] == ''){$wifi[7] = "0";}
					// sanitize wifi data to be used in table name
					$ssidss = filter_var($wifi[0], FILTER_SANITIZE_SPECIAL_CHARS);

					$ssidsss = str_split($ssidss,25); //split SSID in two on is 25 char long.
					$ssids = $ssidsss[0]; //use the 25 char long word for the APs table name, 
										  //this is due to a limitation in MySQL table name lengths
					
					$mac1 = explode(':', $wifi[1]);
					$macs = $mac1[0].$mac1[1].$mac1[2].$mac1[3].$mac1[4].$mac1[5]; //the APs table doesnt need :'s in its name, nor does the Pointers table, well it could I just dont want to
					
					$authen	=	filter_var($wifi[3], FILTER_SANITIZE_SPECIAL_CHARS);
					$encryp	=	filter_var($wifi[4], FILTER_SANITIZE_SPECIAL_CHARS);
					$sectype=	filter_var($wifi[5], FILTER_SANITIZE_SPECIAL_CHARS);
					$chan	=	filter_var($wifi[7], FILTER_SANITIZE_SPECIAL_CHARS);
					$btx	=	filter_var($wifi[8], FILTER_SANITIZE_SPECIAL_CHARS);
					$otx	=	filter_var($wifi[9], FILTER_SANITIZE_SPECIAL_CHARS);
					$nt		=	filter_var($wifi[10], FILTER_SANITIZE_SPECIAL_CHARS);
					$label	=	filter_var($wifi[11], FILTER_SANITIZE_SPECIAL_CHARS);
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
					$result = mysql_query("SELECT * FROM `$wtable` WHERE `mac` LIKE '$macs' AND `chan` LIKE '$chan' AND `sectype` LIKE '$sectype' AND `ssid` LIKE '$ssids' AND `radio` LIKE '$radios' LIMIT 1", $conn1) or die(mysql_error($conn1));
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
					
					//create table name to select from, insert into, or create
					$table = $ssids.'-'.$macs.'-'.$sectype.'-'.$radios.'-'.$chan;
					$gps_table = $table.$gps_ext;
					
					if(!isset($table_ptb)){$table_ptb="";}
					
					if(strcmp($table,$table_ptb)===0)
					{
						// They are the same
						
						logd($FILENUM." / ".$count."   ( ".$APid." )   ||   ".$table." - is being updated ", $log_interval, 0,  $log_level);
						verbose($FILENUM." / ".$count."   ( ".$APid." )   ||   ".$table." - is being updated ", $verbose);
						
						mysql_select_db($db_st,$GLOBALS['conn']);
						//setup ID number for new GPS cords
						$DB_result = mysql_query("SELECT * FROM `$gps_table`", $GLOBALS['conn']);
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
						$todo=array();
						$prev='';
						$sql_multi = array();
						$signal_exp = explode("-",$san_sig);
						$NNN = 0;
						foreach($signal_exp as $exp)
						{
					#		echo ".";
							//Create GPS Array for each Singal, because the GPS table is growing for each signal you need to re grab it to test the data
							$DBresult = mysql_query("SELECT * FROM `$gps_table`", $GLOBALS['conn']);
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
							
							$gpschk = database::check_gps_array($db_gps,$comp);
							list($return_gps, $dbid) = $gpschk;
							$DBresult = mysql_query("SELECT * FROM `$gps_table` WHERE `id` = '$dbid'", $GLOBALS['conn']);
							$GPSDBArray = mysql_fetch_array($DBresult);
							if($return_gps === 0)
							{
								$sql_multi[$NNN] = "INSERT INTO `$gps_table` ( `id` , `lat` , `long` , `sats`, `hdp`, `alt`, `geo`, `kmh`, `mph`, `track` , `date` , `time` ) VALUES ( '$gps_id', '$lat', '$long', '$sats', '$hdp', '$alt', '$geo', '$kmh', '$mph', '$track', '$date', '$time')";
						#		$sqlitgpsgp = "INSERT INTO `$gps_table` ( `id` , `lat` , `long` , `sats`, `hdp`, `alt`, `geo`, `kmh`, `mph`, `track` , `date` , `time` ) VALUES ( '$gps_id', '$lat', '$long', '$sats', '$hdp', '$alt', '$geo', '$kmh', '$mph', '$track', '$date', '$time')";
						#		if (!mysql_query($sqlitgpsgp, $GLOBALS['conn']))
						#		{
						#			logd("There was an Error inserting the GPS information" , $log_interval, 0,  $log_level);
						#			verbose("There was an Error inserting the GPS information", $verbose);
						#		}
								$signals[$gps_id] = $gps_id.",".$signal;
								
								$gps_id++;
							#	break;
							}elseif($return_gps === 1)
							{
								if($sats > $GPSDBArray['sats'])
								{
									$sql_multi[$NNN] = "UPDATE `$gps_table` SET `lat`= '$lat' , `long` = '$long', `sats` = '$sats', `hdp` = '$hdp', `alt` = '$alt', `geo` = '$geo', `kmh` = '$kmh', `mph` = '$mph', `track` = '$track' , `date` = '$date' , `time` = '$time'  WHERE `id` = '$dbid'";
						#			$sqlupgpsgp = "UPDATE `$gps_table` SET `lat`= '$lat' , `long` = '$long', `sats` = '$sats', `hdp` = '$hdp', `alt` = '$alt', `geo` = '$geo', `kmh` = '$kmh', `mph` = '$mph', `track` = '$track' , `date` = '$date' , `time` = '$time'  WHERE `id` = '$dbid'";
						#			$resource = mysql_query($sqlupgpsgp, $GLOBALS['conn']);
						#			if (!$resource)
						#			{
						#				logd("A MySQL Update error has occured\r\n".mysql_error($GLOBALS['conn']) , $log_interval, 0,  $log_level);
						#				verbose("A MySQL Update error has occured\n".mysql_error($GLOBALS['conn']), $verbose);
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
						if (!mysql_query($sqlit, $GLOBALS['conn']))
						{
							logd("FAILED to added GPS History to Table\r\n".mysql_error($GLOBALS['conn']), $log_interval, 0,  $log_level);
							verbose("FAILED to added GPS History to Table\n".mysql_error($GLOBALS['conn']), $verbose);
						}
						
						$sqlit_ = "SELECT * FROM `$table`";
						$sqlit_res = mysql_query($sqlit_, $GLOBALS['conn']) or die(mysql_error());
						$sqlit_num_rows = mysql_num_rows($sqlit_res);
						$sqlit_num_rows++;
						$user_aps[$user_n]="1,".$APid.":".$sqlit_num_rows; //User import tracking //UPDATE AP
						
						logd($user_aps[$user_n], $log_interval, 0,  $log_level);
						verbose($user_aps[$user_n], $verbose);
						$user_n++;
						
						$updated++;
						$FILENUM++;
					}else
					{
						// NEW AP
						logd($FILENUM." / ".$count."   ( ".$size." )   ||   ".$table." - is Being Imported", $log_interval, 0,  $log_level);
						verbose($FILENUM." / ".$count."   ( ".$size." )   ||   ".$table." - is Being Imported", $verbose);
						
						mysql_select_db($db_st,$GLOBALS['conn'])or die(mysql_error($GLOBALS['conn']));
						$sqlct = "CREATE TABLE `$table` (`id` INT( 255 ) NOT NULL AUTO_INCREMENT , `btx` VARCHAR( 10 ) NOT NULL , `otx` VARCHAR( 10 ) NOT NULL , `nt` VARCHAR( 15 ) NOT NULL , `label` VARCHAR( 25 ) NOT NULL , `sig` TEXT NOT NULL , `user` VARCHAR(25) NOT NULL ,PRIMARY KEY (`id`) ) ENGINE = 'InnoDB' DEFAULT CHARSET='utf8'";
				#		echo "(1)Create Table [".$db_st."].{".$table."}\n		 => Added new Table for ".$ssids."\n";
						if(!mysql_query($sqlct, $GLOBALS['conn']))
						{
							logd("FAILED to create Signal History Table \r\n".mysql_error($GLOBALS['conn']), $log_interval, 0,  $log_level);
							verbose("FAILED to create Signal History Table\n".mysql_error($GLOBALS['conn']), $verbose);
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
						$create_table = mysql_query($sqlcgt, $GLOBALS['conn']);
						if(!$create_table)
						{
							logd("FAILED to create GPS History Table \r\n".mysql_error($GLOBALS['conn']), $log_interval, 0,  $log_level);
							verbose("FAILED to create GPS History Table\n".mysql_error($GLOBALS['conn']), $verbose);
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
												   ."VALUES ( '$gps_id', '$lat', '$long', '$sats', $hdp, $alt, $geo, $kmh, $mph, $track, '$date', '$time')";
							if(!mysql_query($sqlitgpsgp, $GLOBALS['conn']))
							{
								logd("FAILED to insert the GPS data.\r\n".mysql_error($GLOBALS['conn']), $log_interval, 0,  $log_level);
								verbose("FAILED to insert the GPS data.\n".mysql_error($GLOBALS['conn']), $verbose);
							}
							$signals[$gps_id] = $gps_id.",".$signal;
					#		echo $signals[$gps_id];
							$gps_id++;
							$prev = $vs1_id;
						}
						$sig = implode("-",$signals);
						
						$sqlit = "INSERT INTO `$table` ( `id` , `btx` , `otx` , `nt` , `label` , `sig`, `user` ) VALUES ( '', '$btx', '$otx', '$nt', '$label', '$sig', '$user')";
						$insertsqlresult = mysql_query($sqlit, $GLOBALS['conn']);
		#				echo "(3)Insert into [".$db_st."].{".$table."}\n		 => Add Signal History to Table\n";
						if(!$insertsqlresult)
						{
							logd("FAILED to insert the Signal data.\r\n".mysql_error($GLOBALS['conn']), $log_interval, 0,  $log_level);
							verbose("FAILED to insert the Signal data.\n".mysql_error($GLOBALS['conn']), $verbose);
						}
						# pointers
						mysql_select_db($db,$GLOBALS['conn']);
						$sqlp = "INSERT INTO `$wtable` ( `id` , `ssid` , `mac` ,  `chan`, `radio`,`auth`,`encry`, `sectype` ) VALUES ( '$size', '$ssidss', '$macs','$chan', '$radios', '$authen', '$encryp', '$sectype')";
						if (mysql_query($sqlp, $GLOBALS['conn']))
						{
			#				echo "(1)Insert into [".$db."].{".$wtable."} => Added Pointer Record\n";
							$user_aps[$user_n]="0,".$size.":1";
							$user_n++;
							$sqlup = "UPDATE `$settings_tb` SET `size` = '$size' WHERE `table` = '$wtable' LIMIT 1;";
							if (mysql_query($sqlup, $GLOBALS['conn']))
							{
			#					echo 'Updated ['.$db.'].{'.$wtable."} with new Size \n		=> ".$size."\n";
								logd("Updated Settings table with new size", $log_interval, 0,  $log_level);
								verbose("Updated Settings table with new size", $verbose);
							}else
							{
								logd("Error Updating Settings table with new size\r\n".mysql_error($GLOBALS['conn']), $log_interval, 0,  $log_level);
								verbose("Error Updating Settings table with new size\n".mysql_error($GLOBALS['conn']), $verbose);
							}
						}else
						{
							logd("Error Updating Pointers table with new AP\r\n".mysql_error($GLOBALS['conn']), $log_interval, 0,  $log_level);
							verbose("Error Updating Pointers table with new AP\r\n".mysql_error($GLOBALS['conn']), $verbose);
						}
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
				logd("Text files are no longer supported, please save your list as a VS1 file or use the Extra->Wifidb menu option in Vistumbler", $log_interval, 0,  $log_level);
				verbose("Text files are no longer supported, please save your list as a VS1 file or use the Extra->Wifidb menu option in Vistumbler", $verbose);
				break;
			}elseif($ret_len == 0)
			{
				logd("There is something wrong with the file you uploaded, check and make sure it is a valid VS1 file and try again", $log_interval, 0,  $log_level);
				verbose("There is something wrong with the file you uploaded, check and make sure it is a valid VS1 file and try again", $verbose);
				break;
			}else
			{
				logd("There is something wrong with the file you uploaded, check and make sure it is a valid VS1 file and try again", $log_interval, 0,  $log_level);
				verbose("There is something wrong with the file you uploaded, check and make sure it is a valid VS1 file and try again", $verbose);
				break;
			}
		}
		mysql_select_db($db,$GLOBALS['conn']);
		
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

		$total_ap = count($user_aps);
		$gdatacount = count($gdata);
		if($user_ap_s != "")
		{
			$sqlu = "INSERT INTO `users` ( `id` , `username` , `points` ,  `notes`, `date`, `title` , `aps`, `gps`) VALUES ( '', '$user', '$user_ap_s','$notes', '$times', '$title', '$total_ap', '$gdatacount')";
			mysql_query($sqlu, $GLOBALS['conn']);
		}
		mysql_close($GLOBALS['conn']);
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
}
?>