<?php
error_reporting(E_ALL | E_STRICT);
$lastedit = "02-Feb-2009";

$ver=array(
			"wifidb"	=>	"0.15 build 80",
			"database"	=>	array(  
							"import_vs1"		=>	"1.4.1", 
							"apfetch"			=>	"2.2",
							"gps_check_array"	=>	"1.0",
							"allusers"			=>	"1.1",
							"userstats"			=>	"1.1",
							"usersap"			=>	"1.1",
							"all_usersap"		=>	"1.1",
							"export_KML"		=>	"1.0",
							"convert_dm_dd"		=>	"1.1",
							"convert_dd_dm"		=>	"1.1"
							),
			"Misc"		=>	array(
							"smart_quotes"		=> 	"1.0",
							"Manufactures"		=> 	"2.0"
							),
			);
class database
{
	#========================================================================================================================#
	#													VS1 File import													     #
	#========================================================================================================================#
	
	function import_vs1($source , $user="Unknown" , $notes="No Notes" , $title="UNTITLED" )
	{
	$times=date('Y-m-d H:i:s');
	if ($source == NULL){echo "<h2>You did not submit a file, please go back and do so.</h2>";die();}
	include('../lib/config.inc.php');
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
	foreach($return as $ret)
	{
		if ($ret[0] == "#"){continue;}

		$retexp = explode("|",$ret);
		$ret_len = count($retexp);

		if ($ret_len == 6)
		{
			$gdata[$retexp[0]] = array("lat"=>$retexp[1], "long"=>$retexp[2],"sats"=>$retexp[3],"date"=>$retexp[4],"time"=>$retexp[5]);
			if ($GLOBALS["debug"]  == 1)
			{
				$gpecho = "GP Data : \r<br>"
				."Return length: ".$ret_len."<br>+-+-+-+-+\r<br>"
				."ID: ".$retexp[0]."<br>+-+-+-+-+\r<br>"
				."Lat: ".$gdata[$retexp[0]]["lat"]."<br>+-+-+-+-+\r<br>"
				."Long: ".$gdata[$retexp[0]]["long"]."<br>+-+-+-+-+\r<br>"
				."Satellites: ".$gdata[$retexp[0]]["sats"]."<br>+-+-+-+-+\r<br>"
				."Date: ".$gdata[$retexp[0]]["date"]."<br>+-+-+-+-+\r<br>"
				."Time: ".$gdata[$retexp[0]]["time"]."+-+-+-+-+\r\r<br><br>";
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
				if ($GLOBALS["debug"]  == 1)
				{
					echo "<br>|<br>|<br>|<br>---- ";
					echo 'Row: '.$cco.' [ '.$co." ] |<br>";
					$co++;
					$cco++;
					echo '- DataBase size: '.$size." <br>";
				}
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
						echo "DB SSID => ".$ssid_ptb." (".$ssids_ptb.")<br> ";
						echo "	- DB Mac => ".$mac_ptb." || ";
						echo "DB Radio => ".$radio_ptb."<br>";
						echo "	- DB Auth => ".$sectype_ptb." || ";
						echo "DB Encry => ".$auth_ptb." ".$encry_ptb."<br>";
						echo "	- DB Chan => ".$chan_ptb."<br>";
						echo $table_ptb."<br>";
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
				
				if(strcmp($table,$table_ptb)==0)
				{
					// They are the same
					
					mysql_select_db($db_st,$conn);
					echo '<table border ="1" class="update"><tr><th>ID</th><th>New/Update</th><th>SSID</th><th>Mac Address</th><th>Authentication</th><th>Encryption</th><th>Radion Type</th><th>Channel</th></tr>';
					echo '<tr><td>'.$APid.'</td><td><b>U</b></td><td>'.$ssids.'</td><td>'.$wifi[1].'</td><td>'.$authen.'</td><td>'.$encryp.'</td><td>'.$radios.'</td><td>'.$chan.'</td></tr>';
					
					$signal_exp = explode("-",$wifi[12]);
					//setup ID number for new GPS cords
					$DB_result = mysql_query("SELECT * FROM `$gps_table`", $conn);
					$gpstableid = mysql_num_rows($DB_result);
					if ($GLOBALS["debug"]  == 1){echo $gpstableid."<br>";}
					if ( $gpstableid === 0)
					{
						$gps_id = 1;
						if ($GLOBALS["debug"]  == 1){echo "0x00000000 <br>";}
					}
					else
					{
						//if the table is already populated set it to the last ID's number
						$gps_id = $gpstableid;
						$gps_id++;
						if ($GLOBALS["debug"]  == 1){echo "0x00000001 <br>";}
					}
					//pull out all GPS rows to be tested against for duplicates
						
					$N=0;
					foreach($signal_exp as $exp)
					{
						//Create GPS Array for each Singal, because the GPS table is growing for each signal you need to re grab it to test the data
						while ($neArray = mysql_fetch_array($DB_result))
						{
							$db_gps[$neArray["id"]]["sats"]=$neArray["sats"];
							$db_gps[$neArray["id"]]["lat"]=$neArray["lat"];
							$db_gps[$neArray["id"]]["long"]=$neArray["long"];
							$db_gps[$neArray["id"]]["date"]=$neArray["date"];
							$db_gps[$neArray["id"]]["time"]=$neArray["time"];
						}
						
						$esp = explode(",",$exp);
						$vs1_id = $esp[0];
						$signal = $esp[1];
						
						if ($GLOBALS["debug"]  == 1)
						{
							$apecho = "+-+-+-+AP Data+-+-+-+<br> VS1 ID:".$vs1_id." <br> DB ID: ".$gps_id."<br>"
							."Lat: ".$gdata[$vs1_id]["lat"]."<br>-+-+-+<br>"
							."Long: ".$gdata[$vs1_id]["long"]."<br>-+-+-+<br>"
							."Satellites: ".$gdata[$vs1_id]["sats"]."<br>-+-+-+<br>"
							."Date: ".$gdata[$vs1_id]["date"]."<br>-+-+-+<br>"
							."Time: ".$gdata[$vs1_id]["time"]."-+-+-+<br><br><br>";
							echo $apecho;
						}
					 #	$gpschk = database::check_gps_array($db_gps,$apdata[$ap_id]);
						
						$lat = $gdata[$vs1_id]["lat"];
						$long = $gdata[$vs1_id]["long"];
						$sats = $gdata[$vs1_id]["sats"];
						$date = $gdata[$vs1_id]["date"];
						$time = $gdata[$vs1_id]["time"];
						
						$comp = $lat.$long.$date.$time;
#						echo "VS1 file: ".$comp."<br>";
						$sql_gps = "SELECT * FROM `$gps_table` WHERE `lat` = '$lat' AND `long` = '$long'";
						$GPSresult = mysql_query($sql_gps, $conn);
						while($gps_resarray = mysql_fetch_array($GPSresult))
						{
							if ($gps_resarray['date'] == $date && $gps_resarray['time'] == $time ){$todo = "db";continue;}
							$dbsel = $gps_resarray['lat'].$gps_resarray['long'].$gps_resarray['date'].$gps_resarray['time'];
#							echo "databse: ".$dbsel."<br>";
							if(strcmp($comp, $dbsel) == 0)
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
						}
						echo '<tr><td colspan="8">';
						switch ($todo)
						{	
							case "new":
								$sqlitgpsgp = "INSERT INTO `$gps_table` ( `id` , `lat` , `long` , `sats` , `date` , `time` ) VALUES ( '$gps_id', '$lat', '$long', '$sats', '$date', '$time')";
								if (mysql_query($sqlitgpsgp, $conn))
								{
									echo "(3)Insert into [".$db_st."].{".$gps_table."}<br>		 => Added GPS History to Table<br>";
								}else
								{
									$sqlcgt = "CREATE TABLE `$gps_table` (`id` INT( 255 ) NOT NULL AUTO_INCREMENT ,`lat` VARCHAR( 25 ) NOT NULL , `long` VARCHAR( 25 ) NOT NULL , `sats` INT( 2 ) NOT NULL , `date` VARCHAR( 10 ) NOT NULL , `time` VARCHAR( 8 ) NOT NULL , INDEX ( `id` ) ) CHARACTER SET = latin1";
									if (mysql_query($sqlcgt, $conn))
									{
										echo "(1)Create Table [".$db_st."].{".$gps_table."}<br>		 => Thats odd the table was missing, well I added a GPS Table for ".$ssids."<br>";
										if (mysql_query($sqlitgpsgp, $conn)){echo "(3)Insert into [".$db_st."].{".$gps_table."}<br>		 => Added GPS History to Table<br>";}
									}
								}
								$signals[$gps_id] = $gps_id.",".$signal;
								$gps_id++;
								break;
							case "db":
								echo "GPS Point already in DB<BR>----".$db_id[0]."- <- DB ID<br>";
								$signals[$gps_id] = $db_id[0].",".$signal;
								$gps_id++;
								break;
							case "hi_sats":
								foreach($hi_sats_id as $sats_id)
								{
									$sqlupgpsgp = "UPDATE `$gps_table` SET `lat`= '$lat' , `long` = '$long', `sats` = '$sats' , `date` = '$date' , `time` = '$time  WHERE `id` = '$sats_id'";
									if (mysql_query($sqlupgpsgp, $conn))
									{echo "(4)Update [".$db_st."].{".$gps_table."}<br>		 => Updated GPS History in Table<br>";}
									else{echo "A MySQL Update error has occured<br>".mysql_error();}
								}
								$signals[$gps_id] = $hi_sats_id[0].",".$signal;
								$gps_id++;
								break;
						}
						echo $todo."<br>";
						echo "</tr><tr>";
					}
					
					echo '<td colspan="8">';
					$sig = implode("-",$signals);
					$sqlit = "INSERT INTO `$table` ( `id` , `btx` , `otx` , `nt` , `label` , `sig`, `user` ) VALUES ( '', '$btx', '$otx', '$nt', '$label', '$sig', '$user')";
					
					$user_aps[$user_n]="1,".$APid; //User import tracking //UPDATE AP
					$user_n++;
					
					if (mysql_query($sqlit, $conn))
					{
						echo "(3)Insert into [".$db_st."].{".$table."}<br>		 => Add Signal History to Table<br>";
					}else
					{
						$sqlct = "CREATE TABLE `$table` (`id` INT( 255 ) NOT NULL AUTO_INCREMENT , `btx` VARCHAR( 10 ) NOT NULL , `otx` VARCHAR( 10 ) NOT NULL , `nt` VARCHAR( 15 ) NOT NULL , `label` VARCHAR( 25 ) NOT NULL , `sig` TEXT NOT NULL , `user` VARCHAR(25) NOT NULL , INDEX ( `id` ) ) CHARACTER SET = latin1";
						if (mysql_query($sqlcgt, $conn) or die(mysql_error()))
						{
							echo "(1)Create Table [".$db_st."].{".$table."}<br>		 => Thats odd the table was missing, well I added a Table for ".$ssids."<br>";
							if (mysql_query($sqlit, $conn)or die(mysql_error()))
							{echo "(3)Insert into [".$db_st."].{".$table."}<br>		 => Added GPS History to Table<br>";}
						}
					}
					echo "</td></tr></table>";
				}else
				{
					echo '<table class="new" border="1"><tr><th>ID</th><th>New/Update</th><th>SSID</th><th>Mac Address</th><th>Authentication</th><th>Encryption</th><th>Radion Type</th><th>Channel</th></tr>';
					echo '<tr><td>'.$size.'</td><td><b>N</b></td><td>'.$ssids.'</td><td>'.$wifi[1].'</td><td>'.$authen.'</td><td>'.$encryp.'</td><td>'.$radios.'</td><td>'.$chan.'</td></tr>';
					echo '<tr><td colspan="8">';
					mysql_select_db($db_st,$conn)or die(mysql_error());
					
					$sqlct = "CREATE TABLE `$table` (`id` INT( 255 ) NOT NULL AUTO_INCREMENT , `btx` VARCHAR( 10 ) NOT NULL , `otx` VARCHAR( 10 ) NOT NULL , `nt` VARCHAR( 15 ) NOT NULL , `label` VARCHAR( 25 ) NOT NULL , `sig` TEXT NOT NULL , `user` VARCHAR(25) NOT NULL , INDEX ( `id` ) ) CHARACTER SET = latin1";
					mysql_query($sqlct, $conn);
					echo "(1)Create Table [".$db_st."].{".$table."}<br>		 => Added new Table for ".$ssids."<br>";
					
					$sqlcgt = "CREATE TABLE `$gps_table` (`id` INT( 255 ) NOT NULL AUTO_INCREMENT ,`lat` VARCHAR( 25 ) NOT NULL , `long` VARCHAR( 25 ) NOT NULL , `sats` INT( 2 ) NOT NULL , `date` VARCHAR( 10 ) NOT NULL , `time` VARCHAR( 8 ) NOT NULL , INDEX ( `id` ) ) CHARACTER SET = latin1";
					mysql_query($sqlcgt, $conn);
					echo "(2)Create Table [".$db_st."].{".$gps_table."}<br>		 => Added new GPS Table for ".$ssids."<br>";
					$signal_exp = explode("-",$wifi[12]);
					$gps_id = 1;
					$N=0;
					foreach($signal_exp as $exp)
					{
						echo '<tr><td colspan="8">';
						$esp = explode(",",$exp);
						$vs1_id = $esp[0];
						$signal = $esp[1];
						
						if ($GLOBALS["debug"]  ==1)
						{
							$apecho = "+-+-+-+AP Data+-+-+-+<br> GPS ID:".$vs1_id." <br> ID: ".$gps_id."<br>"
							."Lat: ".$gdata[$vs1_id]["lat"]."<br>-+-+-+<br>"
							."Long: ".$gdata[$vs1_id]["long"]."<br>-+-+-+<br>"
							."Satellites: ".$gdata[$vs1_id]["sats"]."<br>-+-+-+<br>"
							."Date: ".$gdata[$vs1_id]["date"]."<br>-+-+-+<br>"
							."Time: ".$gdata[$vs1_id]["time"]."-+-+-+<br><br><br>";
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
							echo "(3)Insert into [".$db_st."].{".$gps_table."}<br>		 => Added GPS History to Table<br>";
						}else
						{
							$sqlcgt = "CREATE TABLE `$gps_table` (`id` INT( 255 ) NOT NULL AUTO_INCREMENT ,`lat` VARCHAR( 25 ) NOT NULL , `long` VARCHAR( 25 ) NOT NULL , `sats` INT( 2 ) NOT NULL , `date` VARCHAR( 10 ) NOT NULL , `time` VARCHAR( 8 ) NOT NULL , INDEX ( `id` ) ) CHARACTER SET = latin1";
							if (mysql_query($sqlcgt, $conn))
							{
								echo "(1)Create Table [".$db_st."].{".$gps_table."}<br>		 => Thats odd the table was missing, well I added a GPS Table for ".$ssids."<br>";
								if (mysql_query($sqlitgpsgp, $conn)){echo "(3)Insert into [".$db_st."].{".$gps_table."}<br>		 => Added GPS History to Table<br>";}
							}
						}
						$signals[$gps_id] = $gps_id.",".$signal;
						$gps_id++;
						echo "</td></tr>";
					}
					echo '<tr><td colspan="8">';
					$sig = implode("-",$signals);
					
					$sqlit = "INSERT INTO `$table` ( `id` , `btx` , `otx` , `nt` , `label` , `sig`, `user` ) VALUES ( '', '$btx', '$otx', '$nt', '$label', '$sig', '$user')";
					mysql_query($sqlit, $conn) or die(mysql_error());
					echo "(3)Insert into [".$db_st."].{".$table."}<br>		 => Add Signal History to Table<br>";

					# pointers
					mysql_select_db($db,$conn);
					$sqlp = "INSERT INTO `$wtable` ( `id` , `ssid` , `mac` ,  `chan`, `radio`,`auth`,`encry`, `sectype` ) VALUES ( '$size', '$ssidss', '$macs','$chan', '$radios', '$authen', '$encryp', '$sectype')";
					if (mysql_query($sqlp, $conn) or die(mysql_error()))
					{
						echo "(1)Insert into [".$db."].{".$wtable."} => Added Pointer Record<br>";
						$user_aps[$user_n]="0,".$size;
						$user_n++;
						$sqlup = "UPDATE `$settings_tb` SET `size` = '$size' WHERE `table` = '$wtable' LIMIT 1;";
						if (mysql_query($sqlup, $conn) or die(mysql_error()))
						{
							
							echo 'Updated ['.$db.'].{'.$wtable."} with new Size <br>		=> ".$size."<br>";
							
						}else
						{
							echo mysql_error()." => Could not Add new pointer to table (this has been logged) <br>";
						}
					}else{echo "Something went wrong, I couldn't add in the pointer :-( <br>";}
					echo "</td></tr></table>";
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
		echo "Txt files are no longer supported, please save your list as a VS1 file or use the Extra->Wifidb menu otpion in Vistumbler";	
		$filename = $_SERVER['SCRIPT_FILENAME'];	
		$file_ex = explode("/", $filename);
		$count = count($file_ex);
		$file = $file_ex[($count)-1];
		if (file_exists($filename)) {
			echo "<h6><i><u>$file</u></i> was last modified: " . date ("F d Y H:i:s.", filemtime($filename)) . "</h6>";
		}
		?>
		</p>
		</td>
		</tr>
		<tr>
		<td bgcolor="#315573" height="23"><a href="/pictures/moon.png"><img border="0" src="/pictures/moon_tn.PNG"></a></td>
		<td bgcolor="#315573" width="0">
		</td>
		</tr>
		</table>
		</div>
		</html>
		<?php
		die();
		}else{echo "There is something wrong with the formatting of the data, check it and try running the script again<br>";}
	}
	mysql_select_db($db,$conn);
	$user_ap_s = implode("-",$user_aps);
	$notes = addslashes($notes);
	echo $times."<br>";
	if (!$user_ap_s == "")
	{$sqlu = "INSERT INTO `users` ( `id` , `username` , `points` ,  `notes`, `date`, `title`) VALUES ( '', '$user', '$user_ap_s','$notes', '$times', '$title')";
	mysql_query($sqlu, $conn) or die(mysql_error());}
	mysql_close($conn);
	echo "<br>DONE!";
	}
	
	
	#========================================================================================================================#
	#													Convert GeoCord DM to DD									   	     #
	#========================================================================================================================#
	
	function &convert_dm_dd($geocord_in)
	{
	//	GPS Convertion :
		$neg=FALSE;
		$geocord_exp = explode(".", $geocord_in);//replace any Letter Headings with Numeric Headings
		if($geocord_exp[0][0] === "S" or $geocord_exp[0][0] === "W"){$neg = TRUE;}
		$patterns[0] = '/N /';
		$patterns[1] = '/E /';
		$patterns[2] = '/S /';
		$patterns[3] = '/W /';
		$replacements = "";
		$geocord_exp[0] = preg_replace($patterns, $replacements, $geocord_exp[0]);
		
		if($geocord_exp[0][0] === "-"){$geocord_exp[0] = 0 - $geocord_exp[0];$neg = TRUE;}
		
		// 4208.7753 ---- 4208 - 7753
		$geocord_dec = "0.".$geocord_exp[1];
		// 4208.7753 ---- 4208 - 0.7753
		$geocord_min = str_split($geocord_exp[0],2);
		// 4208.7753 ---- 42 - 8 - 0.7753
		$geocord_min_ = $geocord_min[1]+$geocord_dec;
		// 4208.7753 ---- 42 - 8.7753
		$geocord_div = $geocord_min_/60;
		// 4208.7753 ---- 42 - (8.7753)/60 = 0.146255
		$geocord_add = $geocord_min[0] + $geocord_div;
		// 4208.7753 ---- 42.146255
		if($neg === TRUE){$geocord_add = "-".$geocord_add;}
		return $geocord_add;
	}
	#========================================================================================================================#
	#													Convert GeoCord DD to DM									   	     #
	#========================================================================================================================#
	
	function &convert_dd_dm($geocord_in)
	{
		//	GPS Convertion :
		$neg=FALSE;
		$geocord_exp = explode(".", $geocord_in);
		if($geocord_exp[0][0] == "S" or $geocord_exp[0][0] == "W"){$neg = TRUE;}
		$pattern[0] = '/N /';
		$pattern[1] = '/E /';
		$pattern[2] = '/S /';
		$pattern[3] = '/W /';
		$replacements = "";
		$geocord_exp[0] = preg_replace($pattern, $replacements, $geocord_exp[0]);
		
		if($geocord_exp[0][0] === "-"){$geocord_exp[0] = 0 - $geocord_exp[0];$neg = TRUE;}
		
		// 42.146255 ---- 42 - 146255
		$geocord_dec = "0.".$geocord_exp[1];
		// 42.146255 ---- 42 - 0.146255
		$geocord_mult = $geocord_dec*60;
		// 42.146255 ---- 42 - (0.146255)*60 = 8.7753
		$geocord_mult = "0".$geocord_mult;
		// 42.146255 ---- 42 - 08.7753
		$geocord_add = $geocord_exp[0].$geocord_mult;
		// 42.146255 ---- 4208.7753
		if($neg === TRUE){$geocord_add = "-".$geocord_add;}
		return $geocord_add;
	}
	
	#========================================================================================================================#
	#													GPS check, make sure there are no duplicates						 #
	#========================================================================================================================#

	function &check_gps_array($gpsarray, $test)
	{
	foreach($gpsarray as $gps)
	{
		$gps_t 	=  $gps["lat"]."-".$gps["long"];
		$test_t = $test["lat"]."-".$test["long"]; 
		if (strcmp($gps_t,$test_t)== 0 )
		{
			if ($GLOBALS["debug"]  == 1 ) {
				echo  "  SAME<br>";
				echo  "  Array data: ".$gps_t."<br>";
				echo  "  Testing data: ".$test_t."<br>.-.-.-.-.=.-.-.-.-.<br>";
				echo  "-----=-----=-----<br>|<br>|<br>"; 
			}
			return 1;
			break;
		}else
		{
			if ($GLOBALS["debug"]  == 1){
				echo  "  NOT SAME<br>";
				echo  "  Array data: ".$gps_t."<br>";
				echo  "  Testing data: ".$test_t."<br>----<br>";
				echo  "-----=-----<br>";
			}
			$return = 0;
		}
	}
	return $return;
	}
	
	
	#========================================================================================================================#
	#													AP Fetch														     #
	#========================================================================================================================#

	function apfetch($source)
	{
	include('config.inc.php');
	$table_gps = $source.$gps_ext;
	?>
	<table border="1">
	<tr>
	<th>Row</th><th>Btx</th><th>Otx</th><th>First Active</th><th>Last Update</th><th>Network Type</th><th>Label</th><th>User</th><th>Signal</th>
	</tr>
	<?php
	mysql_select_db($db_st, $conn);
	$result = mysql_query("SELECT * FROM `$source`", $conn) or die(mysql_error());
	while ($field = mysql_fetch_array($result))
	{
		$row = $field["id"];
		$sig_exp = explode("-", $field["sig"]);
		$sig_size = count($sig_exp)-1;

		$first_ID = explode(",",$sig_exp[0]);
		$first = $first_ID[0];

		$last_ID = explode(",",$sig_exp[$sig_size]);
		$last = $last_ID[0];

		$sql1 = "SELECT * FROM `$table_gps` WHERE `id`='$first'";
		$re = mysql_query($sql1, $conn) or die(mysql_error());
		$gps_table_first = mysql_fetch_array($re);

		$date_first = $gps_table_first["date"];
		$time_first = $gps_table_first["time"];
		$fa = $date_first." ".$time_first;

		$sql2 = "SELECT * FROM `$table_gps` WHERE `id`='$last'";
		$res = mysql_query($sql2, $conn) or die(mysql_error());
		$gps_table_last = mysql_fetch_array($res);
		$date_last = $gps_table_last["date"];
		$time_last = $gps_table_last["time"];
		$lu = $date_last." ".$time_last;
		
		echo "<tr><td>".$row."</td><td>"
			.$field["btx"]."</td><td>"
			.$field["otx"]."</td><td>"
			.$fa."</td><td>"
			.$lu."</td><td>"
			.$field["nt"]."</td><td>"
			.$field["label"]."</td><td>"
			.'<a class="links" href="../opt/userstats.php?func=user&user='.$field["user"].'">'.$field["user"].'</a></td><td>'
			.'<a class="links" href="../graph/?row='.$row.'&id='.$GLOBALS['ID'].'">Graph Signal</a></td></tr>';
	}
	echo "</table>";
	#END APFETCH FUNC
	}
	
	
	#========================================================================================================================#
	#													GPS Fetch														     #
	#========================================================================================================================#

	function gpsfetch($source)
	{
	include('config.inc.php');
	?>
	<table border="1">
	<tr>
	<th>Row</th><th>Lat</th><th>Long</th><th>Sats</th><th>Date</th><th>Time</th></tr>
	<?php
	mysql_select_db($db_st, $conn);
	$result = mysql_query("SELECT * FROM `$source`", $conn) or die(mysql_error());
	while ($field = mysql_fetch_array($result)) 
	{
		echo "<tr><td>".$field["id"]."</td><td>"
			.$field["lat"]."</td><td>"
			.$field["long"]."</td><td>"
			.$field["sats"]."</td><td>"
			.$field["date"]."</td><td>"
			.$field["time"]."</td></tr>";
	}
	echo "</table>";
	#END GPSFETCH FUNC
	}
	
	
	#========================================================================================================================#
	#													Associated List Fetch												 #
	#========================================================================================================================#

	function lfetch($source)
	{
	include ('config.inc.php');
	$list = array();
	?>
	<table border="1">
	<tr>
	<th>ID</th><th>User</th><th>Title</th><th>Total APs</th><th>Date</th></tr>
	<?php
	mysql_select_db($db, $conn);
	$result = mysql_query("SELECT * FROM `users`", $conn) or die(mysql_error());
	while ($field = mysql_fetch_array($result)) 
	{
		$APS = explode("-" , $field['points']);
		foreach ($APS as $AP)
		{
			$access = explode(",", $AP);
			if (strcmp($source, $access[1]) == 0 )
			{
				$list[]=$field['id'];
			}
		}
	}
	foreach($list as $aplist)
	{
		$result = mysql_query("SELECT * FROM `users` WHERE `id`='$aplist'", $conn) or die(mysql_error());
		while ($field = mysql_fetch_array($result)) 
		{
			$points = explode('-' , $field['points']);
			$total = count($points);
			echo '<td><a class="links" href="userstats.php?func=userap&row='.$field["id"].'">'.$field["id"].'</a></td><td>'.$field["username"].'</td><td>'.$field["title"].'</td><td>'.$total.'</td><td>'.$field['date'].'</td></tr>';
		}
	}
	?>
	</table>
	<?php
	#END IMPORT LISTS FETCH FUNC
	}
	
	
	#========================================================================================================================#
	#													Grab the stats for All Users										 #
	#========================================================================================================================#
	function allusers()
	{
	$users = array();
	$userarray = array();
	echo '<h1>Stats For: All Users</h1>'
		 .'<table border="1"><tr>'
		 .'<th>ID</th><th>UserName</th><th>Title</th><th>Number of AP\'s</th><th>Imported On</th></tr><tr>';
	include('config.inc.php');
	mysql_select_db($db,$conn);
	$sql = "SELECT * FROM `users` ORDER BY username ASC";
	$result = mysql_query($sql, $conn) or die(mysql_error());
	while ($user_array = mysql_fetch_array($result))
	{
		$users[]=$user_array["username"];
	}
	$users = array_unique($users);
	$pre_user = "";
	$n=0;
	foreach($users as $user)
	{
		$sql = "SELECT * FROM `users` WHERE `username`='$user'";
		$result = mysql_query($sql, $conn) or die(mysql_error());
		while ($user_array = mysql_fetch_array($result))
		{
			$id	=	$user_array['id'];
			$username = $user_array['username'];
			if($pre_user === $username or $pre_user === ""){$n++;}else{$n=0;}
			if ($user_array['title'] === "" or $user_array['title'] === " "){ $user_array['title']="UNTITLED";}
			if ($user_array['date'] === ""){ $user_array['date']="No date, hmm..";}
			if ($user_array['notes'] === " " or $user_array['notes'] === ""){ $user_array['notes']="No Notes, hmm..";}
			$points = explode("-",$user_array['points']);
			$pc = count($points);
			if($pre_user !== $username)
			{
				echo '<tr><td>'.$user_array['id'].'</td><td><a class="links" href="userstats.php?func=user&user='.$username.'">'.$username.'</a></td><td><a class="links" href="userstats.php?func=userap&row='.$user_array["id"].'">'.$user_array['title'].'</a></td><td>'.$pc.'</td><td>'.$user_array['date'].'</td></tr>';
			}
			else
			{
				echo '<tr><td></td><td></td><td><a class="links" href="userstats.php?func=userap&row='.$user_array["id"].'">'.$user_array['title'].'</a></td><td>'.$pc.'</td><td>'.$user_array['date'].'</td></tr>';
			}
			$pre_user = $username;
		}
		echo "<tr></tr>";
	}

echo '</tr></td></table>';
	}
	
	
	#========================================================================================================================#
	#													Grab the stats for a given user										 #
	#========================================================================================================================#
	function userstats($user="")
	{
	if ($user === ""){die("Cannont have blank user.<br>Either there is an error in the code, or you did something wrong.");}
	include('config.inc.php');
	mysql_select_db($db,$conn);
	echo '<h1>Stats For: '.$user.'</h1><table border="1"><tr><th>ID</th><th>Title</th><th>Number of AP\'s</th><th>Imported On</th></tr>';
	$sql = "SELECT * FROM `users` WHERE `username`='$user'";
	$result = mysql_query($sql, $conn) or die(mysql_error());
	while ($user_array = mysql_fetch_array($result))
	{
		$points = explode(",",$user_array['points']);
		$points_c = count($points)-1;
		if ($user_array['title'] === "" or $user_array['title'] === " "){ $user_array['title']="UNTITLED";}
		if ($user_array['date'] === ""){ $user_array['date']="No date, hmm..";}
		if ($user_array['notes'] === " " or $user_array['notes'] === ""){ $user_array['notes']="No Notes, hmm..";}
		echo "<tr><td>".$user_array['id']."</td><td>"
		."<a class=\"links\" href=\"../opt/userstats.php?func=userap&row=".$user_array['id']."\">".$user_array['title']."</a></td><td>"
		.$points_c."</td><td>"
		.$user_array['date']."</td></tr>";
	}
	echo "</table>";
	}
	
	
	#========================================================================================================================#
	#													Grab All the AP's for a given user									 #
	#========================================================================================================================#
	
	function all_usersap($user)
	{
		include('config.inc.php');
		echo '<h1>Access Points For: <a href ="../opt/userstats.php?func=user&user='.$user.'">'.$user.'</a></h1>';
		echo '<table border="1"><tr><th>U/R</th><th>Row</th><th>AP ID</th><th>SSID</th><th>Mac Address</th><th>Authentication</th><th>Encryption</th><th>Radio</th><th>Channel</th></tr><tr>';
		
		$pagerow = 0;
		mysql_select_db($db,$conn);
		$sql = "SELECT * FROM `users` WHERE `username`='$user'";
		$re = mysql_query($sql, $conn) or die(mysql_error());
		while($user_array = mysql_fetch_array($re))
		{
			$aps = explode("-",$user_array["points"]);
			foreach($aps as $ap)
			{
				$ap_exp = explode("," , $ap);
				if($ap_exp[0] == "1"){continue;}
				if($ap_exp[0] == "1"){$Stat="R";}else{$Stat="U";}
				$pagerow++;
				$apid = $ap_exp[1];
				$udflag = $ap_exp[0];
				$sql = "SELECT * FROM `$wtable` WHERE `ID`='$apid'";
				$res = mysql_query($sql, $conn) or die(mysql_error());
				while ($ap_array = mysql_fetch_array($res))
				{
					$ssid = $ap_array['ssid'];
				    $mac = $ap_array['mac'];
				    $chan = $ap_array['chan'];
					$radio = $ap_array['radio'];
					$auth = $ap_array['auth'];
					$encry = $ap_array['encry'];
				    echo '<tr><td>'.$Stat.'</td><td>'.$pagerow.'</td><td>'.$apid.'</td><td><a class="links" href="fetch.php?id='.$apid.'">'.$ssid.'</a></td>';
				    echo '<td>'.$mac.'</td>';
				    echo '<td>'.$auth.'</td>';
					if($radio=="a")
					{$radio="802.11a";}
					elseif($radio=="b")
					{$radio="802.11b";}
					elseif($radio=="g")
					{$radio="802.11g";}
					elseif($radio=="n")
					{$radio="802.11n";}
					else
					{$radio="Unknown Radio";}
					echo '<td>'.$encry.'</td>';
					echo '<td>'.$radio.'</td>';
					echo '<td>'.$chan.'</td></tr>';
				}
			}
		}
#	echo "<a href=../opt/userstats.php?func=expkml&row=".$user_array['id'].">Export To KML File</a>";
	echo "</table>";
	}
	
	
	#========================================================================================================================#
	#													Grab the AP's for a given user's Import								 #
	#========================================================================================================================#

	function usersap($row)
	{
		include('config.inc.php');
		$pagerow =0;
		mysql_select_db($db,$conn);
		$sql = "SELECT * FROM `users` WHERE `id`='$row'";
		$result = mysql_query($sql, $conn) or die(mysql_error());
		$user_array = mysql_fetch_array($result);
		$aps=explode("-",$user_array["points"]);
		echo '<h1>Access Points For: <a class="links" href ="../opt/userstats.php?func=user&user='.$user_array["username"].'">'.$user_array["username"].'</a></h1><h2>With Title: '.$user_array["title"].'</h2><h2>Imported On: '.$user_array["date"].'</h2>';
		
		echo'<table border="1"><tr><th>Row</th><th>AP ID</th><th>SSID</th><th>Mac Address</th><th>Authentication</th><th>Encryption</th><th>Radio</th><th>Channel</th></tr><tr>';
		foreach($aps as $ap)
		{
			$pagerow++;
			$ap_exp = explode("," , $ap);
			$apid = $ap_exp[1];
			$udflag = $ap_exp[0];
			$sql = "SELECT * FROM `$wtable` WHERE `ID`='$apid'";
			$result = mysql_query($sql, $conn) or die(mysql_error());
			while ($ap_array = mysql_fetch_array($result))
			{
				$ssid = $ap_array['ssid'];
			    $mac = $ap_array['mac'];
			    $chan = $ap_array['chan'];
				$radio = $ap_array['radio'];
				$auth = $ap_array['auth'];
				$encry = $ap_array['encry'];
			    echo '<tr><td>'.$pagerow.'</td><td>'.$apid.'</td><td><a class="links" href="fetch.php?id='.$apid.'">'.$ssid.'</a></td>';
			    echo '<td>'.$mac.'</td>';
			    echo '<td>'.$auth.'</td>';
				if($radio=="a")
				{$radio="802.11a";}
				elseif($radio=="b")
				{$radio="802.11b";}
				elseif($radio=="g")
				{$radio="802.11g";}
				elseif($radio=="n")
				{$radio="802.11n";}
				else
				{$radio="Unknown Radio";}
				echo '<td>'.$encry.'</td>';
				echo '<td>'.$radio.'</td>';
				echo '<td>'.$chan.'</td></tr>';
			}
		}
	echo '<a class="links" href=../opt/userstats.php?func=expkml&row='.$user_array["id"].'>Export To KML File</a>';
	echo "</table>";
	}
	
	
	#========================================================================================================================#
	#													Export to Google KML File											 #
	#========================================================================================================================#

	function export_kml($source="full", $file_ext="full_databse.kml")
	{
		include('config.inc.php');
		echo "Start of WiFi DB export to KML\r\n";
		echo "-------------------------------\r\n\r\n";
		if ($source ==="full")
		{
			$file_ext = 'full_database.kml';
			$filename = ('C:/wamp/www/wifidb/out/kml/'.$file_ext);
			// define initial write and appends
			$filewrite = fopen($filename, "w");
			$fileappend = fopen($filename, "a");
			// open file and write header:
			fwrite($fileappend, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n<kml xmlns=\"http://earth.google.com/kml/2.2\">\r\n<Document>\r\n<name>RanInt WifiDB KML</name>\r\n");
			fwrite($fileappend, "<Style id=\"openStyleDead\">\r\n<IconStyle>\r\n<scale>0.5</scale>\r\n<Icon>\r\n<href>http://www.vistumbler.net/images/program-images/open.png</href>\r\n</Icon>\r\n</IconStyle>\r\n</Style>\r\n");
			fwrite($fileappend, "<Style id=\"wepStyleDead\">\r\n<IconStyle>\r\n<scale>0.5</scale>\r\n<Icon>\r\n<href>http://www.vistumbler.net/images/program-images/secure-wep.png</href>\r\n</Icon>\r\n</IconStyle>\r\n</Style>\r\n");
			fwrite($fileappend, "<Style id=\"secureStyleDead\">\r\n<IconStyle>\r\n<scale>0.5</scale>\r\n<Icon>\r\n<href>http://www.vistumbler.net/images/program-images/secure.png</href>\r\n</Icon>\r\n</IconStyle>\r\n</Style>\r\n");
			$x=0;
			$n=0;
			$to=$from+$inc;
			$conn = mysql_pconnect($host, $db_user, $db_pwd);
			mysql_select_db($db,$conn);
			
			echo $WPA_t."\r\n Write AP's to File\r\n";
			fwrite( $fileappend, "<Folder>\r\n<name>Access Points</name>\r\n<Folder>\r\n<name>Open Access Points</name>\r\n");
			echo "Start write of Open AP's\r\n";
			$open_t=0;
			$sql = "SELECT * FROM `$wtable` WHERE `encry`='none'";
			$result = mysql_query($sql, $conn) or die(mysql_error());
			while ($newArray = mysql_fetch_array($result))
			{
				$ssid = $newArray['ssid'];
				$mac = $newArray['mac'];
				$chan = $newArray['chan'];
				$radio = $newArray['radio'];
				$auth = $newArray['auth'];
				$encry = $newArray['encry'];
				$source=$ssid.'_'.$mac.'_'.$auth.'_'.$encry.'_'.$radio.'_'.$chan;
				$macs = str_split($mac,2);
				$mac = $macs[0].':'.$macs[1].':'.$macs[2].':'.$macs[3].':'.$macs[4].':'.$macs[5];
				echo "Fetch Data for AP: ".$source."\r\n";
			#	if ($radio =="U"){continue;}
				if($radio=="a")
				{$radio="802.11a";}
				elseif($radio=="b")
				{$radio="802.11b";}
				elseif($radio=="g")
				{$radio="802.11g";}
				elseif($radio=="n")
				{$radio="802.11n";}
				else
				{$radio="Unknown Radio";}
				mysql_select_db("$db_st") or die("Unable to select database");
				$sql6 = "SELECT * FROM `$source`";
				$result6 = mysql_query($sql6, $conn) or die(mysql_error());
				$max = mysql_num_rows($result6)-1;
				if($max == 0){$max = 1;}
				$sql2 = "SELECT * FROM `$source` WHERE `id`=$max";
				$result2 = mysql_query($sql2, $conn) or die(mysql_error());
				$field = mysql_fetch_array($result2);
				$lat = $field['lat'];
				$long = $field['long'];
				$btx = $field['btx'];
				$otx = $field['otx'];
				$man = $field['man'];
				$fa = $field['fa'];
				$la = $field['la'];
				$nt = $field['nt'];
				$label = $field['lable'];
				if ($lat =="N 0.0000000"){continue;}
				if ($lat =="S 0.0000000"){continue;}
				if ($long =="W 0.0000000"){continue;}
				if ($long =="E 0.0000000"){continue;}
				if ($lat =="N 0000.0000"){continue;}
				if ($lat =="S 0000.0000"){continue;}
				if ($long =="W 0000.0000"){continue;}
				if ($long =="E 0000.0000"){continue;}
				if ($lat =="N 0.0000"){continue;}
				if ($lat =="S 0.0000"){continue;}
				if ($long =="W 0.0000"){continue;}
				if ($long =="E 0.0000"){continue;}
				if ($long ==""){continue;}
				if ($long ==""){continue;}
				$long = str_replace("W ","-",$long);
				$long = str_replace("E ","",$long);
				$lat = str_replace("S ","-",$lat);
				$lat = str_replace("N ","",$lat);
				echo "Writing Data for AP: ".$source."\r\n";
				fwrite( $fileappend, "		<Placemark>\r\n<description><![CDATA[<b>SSID: </b>".$ssid."<br /><b>Mac Address: </b>".$mac."<br /><b>Network Type: </b>".$nt."<br /><b>Radio Type: </b>".$radio."<br /><b>Channel: </b>".$chan."<br /><b>Authentication: </b>".$auth."<br /><b>Encryption: </b>".$encry."<br /><b>Basic Transfer Rates: </b>".$btx."<br /><b>Other Transfer Rates: </b>".$otx."<br /><b>First Active: </b>".$fa."<br /><b>Last Updated: </b>".$la."<br /><b>Latitude: </b>".$lat."<br /><b>Longitude: </b>".$long."<br /><b>Manufacturer: </b>".$man."<br />]]></description>\r\n<styleUrl>#openStyleDead</styleUrl>\r\n<Point>\r\n<coordinates>".$long.",".$lat.",0</coordinates>\r\n</Point>\r\n</Placemark>\r\n");
				$open_t++;
			}
			$WEP_t=0;
			fwrite( $fileappend, "	<description>APs:".$open_t."</description>\r\n</Folder>\r\n<Folder>\r\n<name>WEP Access Points</name>\r\n");
			mysql_select_db($db,$conn);
			$sql = "SELECT * FROM `$w_table` WHERE `encry`='WEP'";
			$result = mysql_query($sql, $conn) or die(mysql_error());
			while ($newArray = mysql_fetch_array($result))
			{
				$ssid = $newArray['ssid'];
				$mac = $newArray['mac'];
				$chan = $newArray['chan'];
				$radio = $newArray['radio'];
				$auth = $newArray['auth'];
				$encry = $newArray['encry'];
				$source=$ssid.'_'.$mac.'_'.$auth.'_'.$encry.'_'.$radio.'_'.$chan;
				$macs = str_split($mac,2);
				$mac = $macs[0].':'.$macs[1].':'.$macs[2].':'.$macs[3].':'.$macs[4].':'.$macs[5];
				echo "Fetch Data for AP: ".$source."\r\n";
			#	if ($radio =="U"){continue;}
				if($radio=="a")
				{$radio="802.11a";}
				elseif($radio=="b")
				{$radio="802.11b";}
				elseif($radio=="g")
				{$radio="802.11g";}
				elseif($radio=="n")
				{$radio="802.11n";}
				else
				{$radio="Unknown Radio";}
				mysql_select_db("$db_st") or die("Unable to select database");
				$sql6 = "SELECT * FROM `$source`";
				$result6 = mysql_query($sql6, $conn) or die(mysql_error());
				$max = mysql_num_rows($result6)-1;
				if($max == 0){$max = 1;}
				$sql2 = "SELECT * FROM `$source` WHERE `id`=$max";
				$result2 = mysql_query($sql2, $conn) or die(mysql_error());
				$field = mysql_fetch_array($result2);
				$lat = $field['lat'];
				$long = $field['long'];
				$btx = $field['btx'];
				$otx = $field['otx'];
				$man = $field['man'];
				$fa = $field['fa'];
				$la = $field['la'];
				$nt = $field['nt'];
				$label = $field['lable'];
				if ($lat =="N 0.0000000"){continue;}
				if ($lat =="S 0.0000000"){continue;}
				if ($long =="W 0.0000000"){continue;}
				if ($long =="E 0.0000000"){continue;}
				if ($lat =="N 0000.0000"){continue;}
				if ($lat =="S 0000.0000"){continue;}
				if ($long =="W 0000.0000"){continue;}
				if ($long =="E 0000.0000"){continue;}
				if ($lat =="N 0.0000"){continue;}
				if ($lat =="S 0.0000"){continue;}
				if ($long =="W 0.0000"){continue;}
				if ($long =="E 0.0000"){continue;}
				if ($long ==""){continue;}
				if ($long ==""){continue;}
				$long = str_replace("W ","-",$long);
				$long = str_replace("E ","",$long);
				$lat = str_replace("S ","-",$lat);
				$lat = str_replace("N ","",$lat);
				echo "Writing Data for AP: ".$source."\r\n";
				fwrite( $fileappend, "<Placemark>\r\n<description><![CDATA[<b>SSID: </b>".$ssid."<br /><b>Mac Address: </b>".$mac."<br /><b>Network Type: </b>".$nt."<br /><b>Radio Type: </b>".$radio."<br /><b>Channel: </b>".$chan."<br /><b>Authentication: </b>".$auth."<br /><b>Encryption: </b>".$encry."<br /><b>Basic Transfer Rates: </b>".$btx."<br /><b>Other Transfer Rates: </b>".$otx."<br /><b>First Active: </b>".$fa."<br /><b>Last Updated: </b>".$la."<br /><b>Latitude: </b>".$lat."<br /><b>Longitude: </b>".$long."<br /><b>Manufacturer: </b>".$man."<br />]]></description>\r\n<styleUrl>#wepStyleDead</styleUrl>\r\n<Point>\r\n<coordinates>".$long.",".$lat.",0</coordinates>\r\n</Point>\r\n</Placemark>\r\n");
				$WEP_t++;
			}
			fwrite( $fileappend, "<description>APs:".$WEP_t."</description></Folder>\r\n");
			$WPA_t=0;
			fwrite( $fileappend, "	<Folder>\r\n<name>Secure Access Points</name>\r\n");
			mysql_select_db($db,$conn);
			$sql = "SELECT * FROM `$w_table` WHERE `auth`='WPA-Personal'";
			$result = mysql_query($sql, $conn) or die(mysql_error());
			while ($newArray = mysql_fetch_array($result))
			{
				$ssid = $newArray['ssid'];
				$mac = $newArray['mac'];
				$chan = $newArray['chan'];
				$radio = $newArray['radio'];
				$auth = $newArray['auth'];
				$encry = $newArray['encry'];
				$source=$ssid.'_'.$mac.'_'.$auth.'_'.$encry.'_'.$radio.'_'.$chan;
				$macs = str_split($mac,2);
				$mac = $macs[0].':'.$macs[1].':'.$macs[2].':'.$macs[3].':'.$macs[4].':'.$macs[5];
				echo "Fetch Data for AP: ".$source."\r\n";
			#	if ($radio =="U"){continue;}
				if($radio=="a")
				{$radio="802.11a";}
				elseif($radio=="b")
				{$radio="802.11b";}
				elseif($radio=="g")
				{$radio="802.11g";}
				elseif($radio=="n")
				{$radio="802.11n";}
				else
				{$radio="Unknown Radio";}
				mysql_select_db("$db_st") or die("Unable to select database");
				$sql6 = "SELECT * FROM `$source`";
				$result6 = mysql_query($sql6, $conn) or die(mysql_error());
				$max = mysql_num_rows($result6)-1;
				if($max == 0){$max = 1;}
				$sql2 = "SELECT * FROM `$source` WHERE `id`=$max";
				$result2 = mysql_query($sql2, $conn) or die(mysql_error());
				$field = mysql_fetch_array($result2);
				$lat = $field['lat'];
				$long = $field['long'];
				$btx = $field['btx'];
				$otx = $field['otx'];
				$man = $field['man'];
				$fa = $field['fa'];
				$la = $field['la'];
				$nt = $field['nt'];
				$label = $field['lable'];
				if ($lat =="N 0.0000000"){continue;}
				if ($lat =="S 0.0000000"){continue;}
				if ($long =="W 0.0000000"){continue;}
				if ($long =="E 0.0000000"){continue;}
				if ($lat =="N 0000.0000"){continue;}
				if ($lat =="S 0000.0000"){continue;}
				if ($long =="W 0000.0000"){continue;}
				if ($long =="E 0000.0000"){continue;}
				if ($lat =="N 0.0000"){continue;}
				if ($lat =="S 0.0000"){continue;}
				if ($long =="W 0.0000"){continue;}
				if ($long =="E 0.0000"){continue;}
				if ($long ==""){continue;}
				if ($long ==""){continue;}
				$long = str_replace("W ","-",$long);
				$long = str_replace("E ","",$long);
				$lat = str_replace("S ","-",$lat);
				$lat = str_replace("N ","",$lat);
				echo "Writing Data for AP: ".$source."\r\n";
				fwrite( $fileappend, "<Placemark>\r\n<description><![CDATA[<b>SSID: </b>".$ssid."<br /><b>Mac Address: </b>".$mac."<br /><b>Network Type: </b>".$nt."<br /><b>Radio Type: </b>".$radio."<br /><b>Channel: </b>".$chan."<br /><b>Authentication: </b>".$auth."<br /><b>Encryption: </b>".$encry."<br /><b>Basic Transfer Rates: </b>".$btx."<br /><b>Other Transfer Rates: </b>".$otx."<br /><b>First Active: </b>".$fa."<br /><b>Last Updated: </b>".$la."<br /><b>Latitude: </b>".$lat."<br /><b>Longitude: </b>".$long."<br /><b>Manufacturer: </b>".$man."<br />]]></description>\r\n<styleUrl>#secureStyleDead</styleUrl>\r\n<Point>\r\n<coordinates>".$long.",".$lat.",0</coordinates>\r\n</Point>\r\n</Placemark>\r\n");
				$WPA_t++;
			}
			$total=$open_t+$WEP_t+$WPA_t;
			echo "Close File out\r\n";
			fwrite( $fileappend, "<description>APs:".$WPA_t."</description></Folder>\r\n<description>APs:".$total."</description>\r\n</Folder>\r\n</Document>\r\n</kml>");
			fclose( $fileappend );
			echo "Done!\r\n";
			mysql_close($conn);
		}elseif($source!=="")
		{
			$filename = ('../out/kml/'.$file_ext);
			// define initial write and appends
			$filewrite = fopen($filename, "w");
			$fileappend = fopen($filename, "a");
			// open file and write header:
			fwrite($fileappend, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n<kml xmlns=\"http://earth.google.com/kml/2.2\">\r\n<Document>\r\n<name>".$file_ext."</name>\r\n");
			fwrite($fileappend, "<Style id=\"openStyleDead\">\r\n<IconStyle>\r\n<scale>0.5</scale>\r\n<Icon>\r\n<href>http://www.vistumbler.net/images/program-images/open.png</href>\r\n</Icon>\r\n</IconStyle>\r\n</Style>\r\n");
			fwrite($fileappend, "<Style id=\"wepStyleDead\">\r\n<IconStyle>\r\n<scale>0.5</scale>\r\n<Icon>\r\n<href>http://www.vistumbler.net/images/program-images/secure-wep.png</href>\r\n</Icon>\r\n</IconStyle>\r\n</Style>\r\n");
			fwrite($fileappend, "<Style id=\"secureStyleDead\">\r\n<IconStyle>\r\n<scale>0.5</scale>\r\n<Icon>\r\n<href>http://www.vistumbler.net/images/program-images/secure.png</href>\r\n</Icon>\r\n</IconStyle>\r\n</Style>\r\n");
			$x=0;
			$n=0;
			mysql_select_db($db,$conn);
			
			echo $WPA_t."\r\n Write AP's to File\r\n";
			fwrite( $fileappend, "<Folder>\r\n<name>Access Points</name>\r\n");
			echo "Start write of AP's\r\n";
			$open_t=0;
			$sql = "SELECT * FROM `$wtable` WHERE `encry`='none'";
			$result = mysql_query($sql, $conn) or die(mysql_error());
			while ($newArray = mysql_fetch_array($result))
			{
				$ssid = $newArray['ssid'];
				$mac = $newArray['mac'];
				$chan = $newArray['chan'];
				$radio = $newArray['radio'];
				$auth = $newArray['auth'];
				$encry = $newArray['encry'];
				$table=$ssid.'-'.$mac.'-'.$auth.'-'.$encry.'-'.$radio.'-'.$chan;
				$table=$ssid.'-'.$mac.'-'.$auth.'-'.$encry.'-'.$radio.'-'.$chan.$gps_ext;
				$macs = str_split($mac,2);
				$mac = $macs[0].':'.$macs[1].':'.$macs[2].':'.$macs[3].':'.$macs[4].':'.$macs[5];
				echo "Fetch Data for AP: ".$source."\r\n";
			#	if ($radio =="U"){continue;}
				if($radio=="a")
				{$radio="802.11a";}
				elseif($radio=="b")
				{$radio="802.11b";}
				elseif($radio=="g")
				{$radio="802.11g";}
				elseif($radio=="n")
				{$radio="802.11n";}
				else
				{$radio="Unknown Radio";}
				mysql_select_db("$db_st") or die("Unable to select database");
				$sql6 = "SELECT * FROM `$source`";
				$result6 = mysql_query($sql6, $conn) or die(mysql_error());
				$max = mysql_num_rows($result6)-1;
				if($max == 0){$max = 1;}
				$sql2 = "SELECT * FROM `$source` WHERE `id`=$max";
				$result2 = mysql_query($sql2, $conn) or die(mysql_error());
				$field = mysql_fetch_array($result2);
				$lat = $field['lat'];
				$long = $field['long'];
				$btx = $field['btx'];
				$otx = $field['otx'];
				$man = $field['man'];
				$fa = $field['fa'];
				$la = $field['la'];
				$nt = $field['nt'];
				$label = $field['lable'];
				if ($lat =="N 0.0000000"){continue;}
				if ($lat =="S 0.0000000"){continue;}
				if ($long =="W 0.0000000"){continue;}
				if ($long =="E 0.0000000"){continue;}
				if ($lat =="N 0000.0000"){continue;}
				if ($lat =="S 0000.0000"){continue;}
				if ($long =="W 0000.0000"){continue;}
				if ($long =="E 0000.0000"){continue;}
				if ($lat =="N 0.0000"){continue;}
				if ($lat =="S 0.0000"){continue;}
				if ($long =="W 0.0000"){continue;}
				if ($long =="E 0.0000"){continue;}
				if ($long ==""){continue;}
				if ($long ==""){continue;}
				$long = str_replace("W ","-",$long);
				$long = str_replace("E ","",$long);
				$lat = str_replace("S ","-",$lat);
				$lat = str_replace("N ","",$lat);
				echo "Writing Data for AP: ".$source."\r\n";
				fwrite( $fileappend, "		<Placemark>\r\n<description><![CDATA[<b>SSID: </b>".$ssid."<br /><b>Mac Address: </b>".$mac."<br /><b>Network Type: </b>".$nt."<br /><b>Radio Type: </b>".$radio."<br /><b>Channel: </b>".$chan."<br /><b>Authentication: </b>".$auth."<br /><b>Encryption: </b>".$encry."<br /><b>Basic Transfer Rates: </b>".$btx."<br /><b>Other Transfer Rates: </b>".$otx."<br /><b>First Active: </b>".$fa."<br /><b>Last Updated: </b>".$la."<br /><b>Latitude: </b>".$lat."<br /><b>Longitude: </b>".$long."<br /><b>Manufacturer: </b>".$man."<br />]]></description>\r\n<styleUrl>#openStyleDead</styleUrl>\r\n<Point>\r\n<coordinates>".$long.",".$lat.",0</coordinates>\r\n</Point>\r\n</Placemark>\r\n");
				$open_t++;
			}
		}
	}
	
	#========================================================================================================================#
	#						Grab the Manuf for a given MAC, print Unknown Manuf if not found								 #
	#========================================================================================================================#
	
	function &manufactures($mac)
	{
		include('manufactures.inc.php');
		$man_mac = str_split($mac,6);
		
		if($manufactures[$man_mac[0]])
		{$manuf = $manufactures[$man_mac[0]];}
		else{$manuf = "Unknown Manufacture";}
		return $manuf;
	
	}
	
	#========================================================================================================================#
	#						Grab the AP's for a given user's Import and throw them into a KML file							 #
	#========================================================================================================================#
	
	function exp_kml_user($row)
	{	
		include('config.inc.php');
		echo "Start of WiFi DB export to KML<BR>";
		echo "-------------------------------<BR><BR>";
		mysql_select_db($db,$conn) or die("Unable to select Database:".$db);
		$sql = "SELECT * FROM `users` WHERE `id`='$row'";
		$result = mysql_query($sql, $conn) or die(mysql_error());
		$user_array = mysql_fetch_array($result);
		$aps = explode("-" , $user_array["points"]);
		
		$date=date('YmdHisu');
		if ($user_array["title"]==""){$title = "UNTITLED";}else{$title=$user_array["title"];}
		$file_ext = $title.'-'.$date.'.kml';
		$filename = ('..\out\kml\\'.$file_ext);
		// define initial write and appends
		$filewrite = fopen($filename, "w");
		$fileappend = fopen($filename, "a");
		// open file and write header:
		fwrite($fileappend, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n	<kml xmlns=\"$KML_SOURCE_URL\">\r\n		<Document>\r\n			<name>RanInt WifiDB KML</name>\r\n");
		fwrite($fileappend, "			<Style id=\"openStyleDead\">\r\n		<IconStyle>\r\n				<scale>0.5</scale>\r\n				<Icon>\r\n			<href>".$open_loc."</href>\r\n			</Icon>\r\n			</IconStyle>\r\n			</Style>\r\n");
		fwrite($fileappend, "<Style id=\"wepStyleDead\">\r\n<IconStyle>\r\n<scale>0.5</scale>\r\n<Icon>\r\n<href>".$WEP_loc."</href>\r\n</Icon>\r\n</IconStyle>\r\n</Style>\r\n");
		fwrite($fileappend, "<Style id=\"secureStyleDead\">\r\n<IconStyle>\r\n<scale>0.5</scale>\r\n<Icon>\r\n<href>".$WPA_loc."</href>\r\n</Icon>\r\n</IconStyle>\r\n</Style>\r\n");
		fwrite($fileappend, '<Style id="Location"><LineStyle><color>7f0000ff</color><width>4</width></LineStyle></Style>');
		echo "Wrote Header to KML File<BR>";
		$x=0;
		$n=0;
		$total = count($aps);
		fwrite( $fileappend, "<Folder>\r\n<name>Access Points</name>\r\n<description>APs: ".$total."</description>\r\n");
		fwrite( $fileappend, "<Folder>\r\n<name>".$title." Access Points</name>\r\n");
		echo "Wrote KML Folder Header<BR>";
		
		foreach($aps as $ap)
		{
			$ap_exp = explode("," , $ap);
			$apid = $ap_exp[1];
			$udflag = $ap_exp[0];
			mysql_select_db($db,$conn) or die("Unable to select Database:".$db);
			$sql0 = "SELECT * FROM `$wtable` WHERE `id`='$apid'";
			$result = mysql_query($sql0, $conn) or die(mysql_error());
			while ($newArray = mysql_fetch_array($result))
			{
			    $id = $newArray['id'];
				$ssid = $newArray['ssid'];
			    $mac = $newArray['mac'];
				$man =& database::manufactures($mac);
			    $chan = $newArray['chan'];
				$r = $newArray["radio"];
				$auth = $newArray['auth'];
				$encry = $newArray['encry'];
				$sectype = $newArray['sectype'];
				switch($sectype)
				{
					case 1:
						$type = "#openStyleDead";
						break;
					case 2:
						$type = "#wepStyleDead";
						break;
					case 3:
						$type = "#secureStyleDead";
						break;
				}
			
				switch($r)
				{
					case "a":
						$radio="802.11a";
						break;
					case "b":
						$radio="802.11b";
						break;
					case "g":
						$radio="802.11g";
						break;
					case "n":
						$radio="802.11n";
						break;
					default:
						$radio="Unknown Radio";
						break;
				}
				
				$table=$ssid.'-'.$mac.'-'.$sectype.'-'.$r.'-'.$chan;
				mysql_select_db("$db_st") or die("Unable to select Database:".$db_st);
				
				$sql = "SELECT * FROM `$table` WHERE `id`='1'";
				$result = mysql_query($sql, $conn);
				$AP_table = mysql_fetch_array($result);
				$otx = $AP_table["otx"];
				$btx = $AP_table["btx"];
				$nt = $AP_table['nt'];
				$label = $AP_table['label'];
				$table_gps = $table."_GPS";
				
				$sql6 = "SELECT * FROM `$table_gps`";
				$result6 = mysql_query($sql6, $conn);
				$max = mysql_num_rows($result6);
				
				$sql = "SELECT * FROM `$table_gps` WHERE `id`='1'";
				$result = mysql_query($sql, $conn);
				$gps_table_first = mysql_fetch_array($result);
				$date_first = $gps_table_first["date"];
				$time_first = $gps_table_first["time"];
				$fa = $date_first." ".$time_first;
				if($gps_table_first['lat']=="0.0000" or $gps_table_first['long'] =="0.0000"){continue;}
				//===================================CONVERT FROM DM TO DD=========================================//
				$lat = $gps_table_first['lat'];
				$long = $gps_table_first['long'];
				if($lat !== "N 0.0000"){
					$lat = database::convert_dm_dd($lat);
					$long = database::convert_dm_dd($long);
				}
				//=====================================================================================================//
				
				$sql = "SELECT * FROM `$table_gps` WHERE `id`='$max'";
				$result = mysql_query($sql, $conn);
				$gps_table_last = mysql_fetch_array($result);
				$date_last = $gps_table_last["date"];
				$time_last = $gps_table_last["time"];
				$la = $date_last." ".$time_last;
				fwrite( $fileappend, "<Placemark id=\"".$mac."\">\r\n	<name></name>\r\n	<description><![CDATA[<b>SSID: </b>".$ssid."<br /><b>Mac Address: </b>".$mac."<br /><b>Network Type: </b>".$nt."<br /><b>Radio Type: </b>".$radio."<br /><b>Channel: </b>".$chan."<br /><b>Authentication: </b>".$auth."<br /><b>Encryption: </b>".$encry."<br /><b>Basic Transfer Rates: </b>".$btx."<br /><b>Other Transfer Rates: </b>".$otx."<br /><b>First Active: </b>".$fa."<br /><b>Last Updated: </b>".$la."<br /><b>Latitude: </b>".$lat."<br /><b>Longitude: </b>".$long."<br /><b>Manufacturer: </b>".$man."<br /><a href=\"http://www.randomintervals.com/wifidb/opt/fetch.php?id=".$id."\">WiFiDB Link</a>]]></description>\r\n	<styleUrl>".$type."</styleUrl>\r\n	");
				fwrite( $fileappend, "<Point id=\"".$mac."_GPS\">\r\n<coordinates>".$long.",".$lat.",0</coordinates>\r\n</Point>\r\n</Placemark>\r\n");
				echo "Wrote AP: ".$ssid."<br>to KML File<BR>";
				unset($gps_table_first["lat"]);
				unset($gps_table_first["long"]);
			}
		}
		fwrite( $fileappend, "	</Folder>\r\n");
		fwrite( $fileappend, "	</Folder>\r\n	</Document>\r\n</kml>");
		fclose( $fileappend );
	mysql_close($conn);
	}
	
	#========================================================================================================================#
	#													Export nestet ap to kml file										 #
	#========================================================================================================================#
	
	function exp_newest_kml()
	{
		include('config.inc.php');
		$file_ext = 'newest_database.kml';
		$filename = ('C:/wamp/www/wifidb/out/kml/'.$file_ext);
		// define initial write and appends
		$filewrite = fopen($filename, "w");
		if($filewrite != FALSE)
		{
			$fileappend = fopen($filename, "a");
			// open file and write header:
			fwrite($fileappend, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n<kml xmlns=\"http://earth.google.com/kml/2.2\">\r\n<Document>\r\n<name>RanInt WifiDB KML</name>\r\n");
			fwrite($fileappend, "<Style id=\"openStyleDead\">\r\n<IconStyle>\r\n<scale>0.5</scale>\r\n<Icon>\r\n<href>http://www.vistumbler.net/images/program-images/open.png</href>\r\n</Icon>\r\n</IconStyle>\r\n</Style>\r\n");
			fwrite($fileappend, "<Style id=\"wepStyleDead\">\r\n<IconStyle>\r\n<scale>0.5</scale>\r\n<Icon>\r\n<href>http://www.vistumbler.net/images/program-images/secure-wep.png</href>\r\n</Icon>\r\n</IconStyle>\r\n</Style>\r\n");
			fwrite($fileappend, "<Style id=\"secureStyleDead\">\r\n<IconStyle>\r\n<scale>0.5</scale>\r\n<Icon>\r\n<href>http://www.vistumbler.net/images/program-images/secure.png</href>\r\n</Icon>\r\n</IconStyle>\r\n</Style>\r\n");
			
			mysql_select_db($db, $conn);
			$sql = "SELECT * FROM `$wtable`";
			$num_rows = mysql_num_rows($sql, $conn) or die(mysql_error());
			
			$sql = "SELECT * FROM `$wtable` WHERE `ID`='$num_rows'";
			$result = mysql_query($sql, $conn) or die(mysql_error());
			$pointer_array = mysql_fetch_array($result);
			
			$APid = $pointer_array['id'];
			$ssid_ptb_ = $pointer_array["ssid"];
			$ssids_ptb = str_split($pointer_array['ssid'],25);
			$ssid_ptb = $ssids_ptb[0];
			$mac_ptb=$pointer_array['mac'];
			$radio_ptb=$pointer_array['radio'];
			$sectype_ptb=$pointer_array['sectype'];
			$auth_ptb=$pointer_array['auth'];
			$encry_ptb=$pointer_array['encry'];
			$chan_ptb=$pointer_array['chan'];
			
			$table = $ssid_ptb.'-'.$mac_ptb.'-'.$sectype_ptb.'-'.$radio_ptb.'-'.$chan_ptb;
			mysql_select_db($db_st, $conn);
			$table_gps = $source.$gps_ext;
			$table_rows = mysql_num_rows("SELECT * FROM `$table`", $conn) or die(mysql_error());
			
			$result = mysql_query("SELECT * FROM `$table` WHERE `id` = '$table_row'", $conn) or die(mysql_error());
			$field = mysql_fetch_array($result); 
			$row = $field["id"];
			$sig_exp = explode("-", $field["sig"]);
			$sig_size = count($sig_exp);
			
			$first_ID = explode(",",$sig_exp[0]);
			$first = $first_ID[0];
			
			$last_ID = explode(",",$sig_exp[$sig_size]);
			$last = $last_ID[0];
			
			$sql = "SELECT * FROM `$table_gps` WHERE `id`='$first'";
			$result = mysql_query($sql, $conn) or die(mysql_error());
			$gps_table_first = mysql_fetch_array($result);
			
			$date_first = $gps_table_first["date"];
			$time_first = $gps_table_first["time"];
			$fa = $date_first." ".$time_first;
			
			$sql = "SELECT * FROM `$table_gps` WHERE `id`='$last'";
			$result = mysql_query($sql, $conn) or die(mysql_error());
			$gps_table_last = mysql_fetch_array($result);
			$date_last = $gps_table_last["date"];
			$time_last = $gps_table_last["time"];
			$lu = $date_last." ".$time_last;
			
		echo "<td>".$row."</td><td>"
			.$field["btx"]."</td><td>"
			.$field["otx"]."</td><td>"
			.$fa."</td><td>"
			.$lu."</td><td>"
			.$field["nt"]."</td><td>"
			.$field["label"]."</td><td>"
			.'<a href="../opt/userstats.php?user='.$field["user"].'">'.$field["user"].'</a></td><td>'
			.'<a href="../graph/?row='.$row.'&id='.$GLOBALS['ID'].'">Graph Signal</a></td></tr>';
		}
	}
#end DATABASE CLASS
}

#========================================================================================================================#
#													Smart Quotes (char filtering)										 #
#========================================================================================================================#

function smart_quotes($text) {
$pattern = '/"((.)*?)"/i';
$strip = array(
				0=>"'",
				1=>".",
				2=>"*",
				3=>"/",
				4=>"?",
				5=>"<",
				6=>">",
				7=>'"',
				8=>"'",
				9=>"$",
			);
$text = preg_replace($pattern,"&#147;\\1&#148;",stripslashes($text));
$text = str_replace($strip,"_",$text);
return $text;
}


?>