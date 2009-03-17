<?php
#include('manufactures.inc.php');
$ver=array(
			"wifidb"			=>	"0.16 Build 1",
			"Last_Core_Edit" 	=> 	"2009-Mar-17",
			"database"			=>	array(  
										"import_vs1"		=>	"1.5.2", 
										"apfetch"			=>	"2.4.1",
										"gps_check_array"	=>	"1.0",
										"allusers"			=>	"1.1",
										"userstats"			=>	"1.1",
										"usersap"			=>	"1.1",
										"all_usersap"		=>	"1.1",
										"export_KML"		=>	"2.0",
										"export_KML_user"	=>	"2.0",
										"convert_dm_dd"		=>	"1.2",
										"convert_dd_dm"		=>	"1.2",
										"manufactures"		=>	"1.0"
										),
			"Misc"				=>	array(
										"footer"				=>	"1.1",
										"smart_quotes"			=> 	"1.0",
										"Manufactures-list"		=> 	"2.0"
										),
			);

#========================================================================================================================#
#											Footer (writes the footer for all pages)									 #
#========================================================================================================================#

function footer($filename = $_SERVER['SCRIPT_FILENAME'])
{
	$file_ex = explode("/", $filename);
	$count = count($file_ex);
	$file = $file_ex[($count)-1];
	?>
	</p>
	</td>
	</tr>
	<tr>
	<td bgcolor="#315573" height="23"><a href="/pictures/moon.png"><img border="0" src="/pictures/moon_tn.PNG"></a></td>
	<td bgcolor="#315573" width="0" align="center">
	<?php
	if (file_exists($filename)) {?>
		<h6><i><u><?php echo $file;?></u></i> was last modified:  <?php echo date ("Y F d @ H:i:s", filemtime($filename));?></h6>
	<?php
	}
	?>
	<!-- -->
	<!-- Put your ADs here if you want them, if not just leave this alone -->
	<!-- -->
	</td>
	</tr>
	</table>
	</body>
	</html>
	<?php
}

#========================================================================================================================#
#													Smart Quotes (char filtering)										 #
#========================================================================================================================#

function smart_quotes($text="") {
$pattern = '/"((.)*?)"/i';
$strip = array(
				0=>"'",
				1=>".",
				2=>"*",
				3=>"?",
				4=>"<",
				5=>">",
				6=>'"',
				7=>"'",
				8=>"$",
				9=>"?>",
				10=>";"
			);
$text = preg_replace($pattern,"&#147;\\1&#148;",stripslashes($text));
$text = str_replace($strip,"_",$text);
return $text;
}

class database
{
	#========================================================================================================================#
	#													VS1 File import													     #
	#========================================================================================================================#
	
	function import_vs1($source="" , $user="Unknown" , $notes="No Notes" , $title="UNTITLED" )
	{
	$times=date('Y-m-d H:i:s');
	if ($source == NULL){?><h2>You did not submit a file, please go back and do so.</h2> <?php die();}
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
	$count = count($return);
	if($count <= 8) { echo "<h3>You cannot upload an empty VS1 file, atleast scan for a few seconds to import some data.</h3><a href=\"index.php\">Go back and do it again</a>"; footer("../import/insertnew.php");die();}
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
					?>
					<br>|<br>|<br>|<br>----<br>
					Row: <?php echo $cco;?> [ <?php echo $co;?> ] |<br>
					<?
					$co++;
					$cco++;
					?>
					- DataBase size: <?php echo " ".$size;?> <br>
					<?php
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
				
				if(strcmp($table,$table_ptb)===0)
				{
					// They are the same
					
					mysql_select_db($db_st,$conn);
					?><table border ="1" class="update"><tr><th>ID</th><th>New/Update</th><th>SSID</th><th>Mac Address</th><th>Authentication</th><th>Encryption</th><th>Radion Type</th><th>Channel</th></tr>
					<tr><td><?php echo $APid; ?></td><td><b>U</b></td><td><?php echo $ssids; ?></td><td><?php echo $wifi[1]; ?></td><td><?php echo $authen; ?></td><td><?php echo $encryp; ?></td><td><?php echo $radios; ?></td><td><?php echo $chan; ?></td></tr>
					<?php
					$signal_exp = explode("-",$wifi[12]);
					//setup ID number for new GPS cords
					$DB_result = mysql_query("SELECT * FROM `$gps_table`", $conn);
					$gpstableid = mysql_num_rows($DB_result);
					if ($GLOBALS["debug"]  == 1){echo $gpstableid."<br>";}
					if ( $gpstableid === 0)
					{
						$gps_id = 1;
						if ($GLOBALS["debug"]  === 1){echo "0x00 <br>";}
					}
					else
					{
						//if the table is already populated set it to the last ID's number
						$gps_id = $gpstableid;
						$gps_id++;
						if ($GLOBALS["debug"]  === 1){echo "0x01 <br>";}
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
							$apecho = "+-+-+-+AP Data+-+-+-+<br> VS1 ID:".$vs1_id." <br> Next DB ID: ".$gps_id."<br>"
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
						
						$comp = $lat.'-'.$long.'-'.$date.'-'.$time;
						
						$sql_gps = "SELECT * FROM `$gps_table` WHERE `time` = '$time' LIMIT 1";
						$GPSresult = mysql_query($sql_gps, $conn);
						#while(
						$gps_resarray = mysql_fetch_array($GPSresult);#)
						#{
#						echo count($gps_resarray);
							$dbsel = $gps_resarray['lat'].'-'.$gps_resarray['long'].'-'.$gps_resarray['date'].'-'.$gps_resarray['time'];
							echo $dbsel."<br><br>".$comp."<br>";
#							echo "Lat: ".$gps_resarray['lat']."<br>Long: ".$gps_resarray['long']."<br>Date: ".$gps_resarray['date']."<br>Time: ".$gps_resarray['time']."<br>";
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
						#}
						?>
						<tr><td colspan="8">
						<?php
						echo $todo."<br>";
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
						?>
						<br></tr><tr>
						<?php
					}
					
					?>
					<td colspan="8">
					<?php
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
					?>
					</td></tr></table>
					<?php
				}else
				{
					?><table class="new" border="1"><tr><th>ID</th><th>New/Update</th><th>SSID</th><th>Mac Address</th><th>Authentication</th><th>Encryption</th><th>Radion Type</th><th>Channel</th></tr>
					<tr><td><?php echo $size;?></td><td><b>N</b></td><td><?php echo $ssids;?></td><td><?php echo $wifi[1];?></td><td><?php echo $authen;?></td><td><?php echo $encryp;?></td><td><?php echo $radios;?></td><td><?php echo $chan;?></td></tr>
					<?php
					?>
					<tr><td colspan="8">
					<?php
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
						?>
						<tr><td colspan="8">
						<?php
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
						?>
						</td></tr>
						<?php
					}
					?>
					<tr><td colspan="8">
					<?php
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
						$user_aps[$user_n]="0,".$size.":1";
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
			echo 'Text files are no longer supported, please save your list as a VS1 file or use the Extra->Wifidb menu option in <a href="www.vistumbler.net" target="_blank">Vistumbler</a>';
			$filename = $_SERVER['SCRIPT_FILENAME'];	
			footer($filename);
			die();
		}else{echo 'There is something wrong with the file you uploaded, check and make sure it is a <a href="http://vistumbler.wiki.sourceforge.net/VS1+Format">valid VS1</a> file and try again<br>';}
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
	
	function &convert_dm_dd($geocord_in="")
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
	
	function &convert_dd_dm($geocord_in="")
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

	function &check_gps_array($gpsarrayarray(0=>array('lat'=>"","long"=>"")), $test=array('lat'=>"","long"=>""))
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
	#													AP History Fetch													 #
	#========================================================================================================================#

	function apfetch($id=0)
	{
		include('../lib/config.inc.php');
		mysql_select_db($db,$conn);
		$sqls = "SELECT * FROM `$wtable` WHERE id='$id'";
		$result = mysql_query($sqls, $conn) or die(mysql_error());
		$newArray = mysql_fetch_array($result);
		$ID = $newArray['id'];
		
		$macaddress = $newArray['mac'];
		$manuf = database::manufactures($macaddress);
		$mac = str_split($macaddress,2);
		$mac_full = $mac[0].":".$mac[1].":".$mac[2].":".$mac[3].":".$mac[4].":".$mac[5];
		$radio = $newArray['radio'];
		if($radio == "a")
			{$radio = "802.11a";}
		elseif($radio == "b")
			{$radio = "802.11b";}
		elseif($radio == "g")
			{$radio = "802.11g";}
		elseif($radio == "n")
			{$radio = "802.11n";}
		else
			{$radio = "802.11u";}
		$table		=	$newArray['ssid'].'-'.$newArray["mac"].'-'.$newArray["sectype"].'-'.$newArray["radio"].'-'.$newArray['chan'];
		$table_gps	=	$newArray['ssid'].'-'.$newArray["mac"].'-'.$newArray["sectype"].'-'.$newArray["radio"].'-'.$newArray['chan'].$gps_ext;
		?>
				<h1><?php echo $newArray['ssid'];?></h1><TABLE WIDTH=569 BORDER=1 CELLPADDING=4 CELLSPACING=0 STYLE="page-break-before: always"><COL WIDTH=112><COL WIDTH=439>
				<TR VALIGN=TOP><TD WIDTH=112><P>MAC Address</P></TD><TD WIDTH=439><P><?php echo $mac_full;?></P></TD></TR>
				<TR VALIGN=TOP><TD WIDTH=112><P>Manufacture</P></TD><TD WIDTH=439><P><?php echo $manuf;?></P></TD></TR>
				<TR VALIGN=TOP><TD WIDTH=112 HEIGHT=26><P>Authentication</P></TD><TD WIDTH=439><P><?php echo $newArray['auth'];?></P></TD></TR>
				<TR VALIGN=TOP><TD WIDTH=112><P>Encryption Type</P></TD><TD WIDTH=439><P><?php echo $newArray['encry'];?></P></TD></TR>
				<TR VALIGN=TOP><TD WIDTH=112><P>Radio Type</P></TD><TD WIDTH=439><P><?php echo $radio;?></P></TD></TR>
				<TR VALIGN=TOP><TD WIDTH=112><P>Channel #</P></TD><TD WIDTH=439><P><?php echo $newArray['chan'];?></P></TD></TR></TABLE>
		<?php
		?>
		<h3>Signal History</h3>
		<table border="1">
		<tr>
		<th>Row</th><th>Btx</th><th>Otx</th><th>First Active</th><th>Last Update</th><th>Network Type</th><th>Label</th><th>User</th><th>Signal</th>
		</tr>
		<?php
		mysql_select_db($db_st, $conn);
		$result = mysql_query("SELECT * FROM `$table`", $conn) or die(mysql_error());
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
			?>
			<tr><td><?php echo $row; ?></td><td>
				<?php echo $field["btx"]; ?></td><td>
				<?php echo $field["otx"]; ?></td><td>
				<?php echo $fa; ?></td><td>
				<?php echo $lu; ?></td><td>
				<?php echo $field["nt"]; ?></td><td>
				<?php echo $field["label"]; ?></td><td>
				<a class="links" href="../opt/userstats.php?func=user&user=<?php echo $field["user"]; ?>"><?php echo $field["user"]; ?></a></td><td>
				<a class="links" href="../graph/?row=<?php echo $row; ?>&id=<?php echo $ID; ?>">Graph Signal</a></td></tr>
			<?php
		}
		?>
		</table>
		<?php
		#END APFETCH FUNC
		?>
		<h3>GPS History</h3>
		<table border="1">
		<tr>
		<th>Row</th><th>Lat</th><th>Long</th><th>Sats</th><th>Date</th><th>Time</th></tr>
		<?php
		$result = mysql_query("SELECT * FROM `$table_gps`", $conn) or die(mysql_error());
		while ($field = mysql_fetch_array($result)) 
		{
			?>
			<tr><td>
			<?php echo $field["id"]; ?></td><td>
			<?php echo $field["lat"]; ?></td><td>
			<?php echo $field["long"]; ?></td><td>
			<?php echo $field["sats"]; ?></td><td>
			<?php echo $field["date"]; ?></td><td>
			<?php echo $field["time"]; ?></td></tr>
			<?php
		}
		?>
		</table>
		<?php
		#END GPSFETCH FUNC
		$list = array();
		?>
		<h3>Associated Lists</h3>
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
				$access1 = explode(":",$access[1]);
				if (strcmp($ID, $access1[0]) == 0 )
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
				if (!is_null($field["title"])){$field["title"]="Untitled";}
				$points = explode('-' , $field['points']);
				$total = count($points);
				?>
				<td><a class="links" href="userstats.php?func=userap&row=<?php echo $field["id"];?>"><?php echo $field["id"];?></a></td><td><?php echo $field["username"];?></td><td><?php echo $field["title"];?></td><td><?php echo $total;?></td><td><?php echo $field['date'];?></td></tr>
				<?php
			}
		}
		mysql_close($conn);
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
	include('config.inc.php');
	$users = array();
	$userarray = array();
	?>
		<h1>Stats For: All Users</h1>
		<table border="1"><tr>
		<th>ID</th><th>UserName</th><th>Title</th><th>Number of APs</th><th>Imported On</th></tr><tr>
	<?php
	
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
			if($user_array['points'] === ""){continue;}
			if($pre_user !== $username)
			{
				echo '<tr><td>'.$user_array['id'].'</td><td><a class="links" href="userstats.php?func=user&user='.$username.'">'.$username.'</a></td><td><a class="links" href="userstats.php?func=userap&row='.$user_array["id"].'">'.$user_array['title'].'</a></td><td>'.$pc.'</td><td>'.$user_array['date'].'</td></tr>';
			}
			else
			{
				?>
				<tr><td></td><td></td><td><a class="links" href="userstats.php?func=userap&row=<?php echo $user_array["id"];?>"><?php echo $user_array['title'];?></a></td><td><?php echo $pc;?></td><td><?php echo $user_array['date'];?></td></tr>
				<?php
			}
			$pre_user = $username;
		}
		?>
		<tr></tr>
		<?php
	}

	?>
	</tr></td></table>
	<?php
	}
	
	
	#========================================================================================================================#
	#													Grab the stats for a given user										 #
	#========================================================================================================================#
	function userstats($user="")
	{
	if ($user === ""){die("Cannont have blank user.<br>Either there is an error in the code, or you did something wrong.");}
	include('config.inc.php');
	mysql_select_db($db,$conn);
	?>
	<h1>Stats For:<?php echo " ".$user;?></h1><table border="1"><tr><th>ID</th><th>Title</th><th>Number of AP's</th><th>Imported On</th></tr>
	<?php
	$sql = "SELECT * FROM `users` WHERE `username`='$user'";
	$result = mysql_query($sql, $conn) or die(mysql_error());
	while ($user_array = mysql_fetch_array($result))
	{
		$points = explode(",",$user_array['points']);
		$points_c = count($points)-1;
		if ($user_array['title'] === "" or $user_array['title'] === " "){ $user_array['title']="UNTITLED";}
		if ($user_array['date'] === ""){ $user_array['date']="No date, hmm..";}
		if ($user_array['notes'] === " " or $user_array['notes'] === ""){ $user_array['notes']="No Notes, hmm..";}
		?>
		<tr><td><?php echo $user_array['id'];?></td><td>
		<a class="links" href="../opt/userstats.php?func=userap&row=<?php echo $user_array['id'];?>"><?php echo $user_array['title'];?></a></td><td>
		<?php echo $points_c;?></td><td>
		<?php echo $user_array['date'];?></td></tr>
		<?php
	}
	echo "</table>";
	}
	
	
	#========================================================================================================================#
	#													Grab All the AP's for a given user									 #
	#========================================================================================================================#
	
	function all_usersap($user="")
	{
		include('config.inc.php');
		mysql_select_db($db,$conn);
		$sql = "SELECT * FROM `users` WHERE `username`='$user'";
		$re = mysql_query($sql, $conn) or die(mysql_error());
		#<h3><a href="../opt/userstats.php?func=expkml&row=echo $user;">Export To KML File</a></h3>
		?>
		<h1>Access Points For: <a href ="../opt/userstats.php?func=user&user=<?php echo $user;?>"><?php echo $user;?></a></h1>
		
		<table border="1"><tr><th>New/Update</th><th>Row</th><th>AP ID</th><th>SSID</th><th>Mac Address</th><th>Authentication</th><th>Encryption</th><th>Radio</th><th>Channel</th></tr><tr>
		<?php
		mysql_select_db($db,$conn);
		$sql = "SELECT * FROM `users` WHERE `username`='$user'";
		$re = mysql_query($sql, $conn) or die(mysql_error());
		while($user_array = mysql_fetch_array($re))
		{
			$aps = explode("-",$user_array["points"]);
			foreach($aps as $ap)
			{
				$ap_exp = explode("," , $ap);
				#if($ap_exp[0] == "1"){continue;}
				if($ap_exp[0] == "1"){$Stat="U";}else{$Stat="N";}
				
				$apid = $ap_exp[1];
				$exp_apid = explode(":",$apid);
				
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
					?>
					<tr><td align="center">
					<?php
					echo $Stat;
					?></td><td align="center">
					<?php
					echo $exp_apid[1];
					?>
					</td><td align="center">
					<?php
					echo $exp_apid[0];
					?>
					</td><td><a class="links" href="fetch.php?id=<?php echo $apid;?>"><?php echo $ssid;?></a></td>
					<td>
					<?php echo $mac;?></td><td>
					<?php echo $auth;?></td><td>
					<?php echo $encry;?></td><td>
					<?php echo $radio;?></td><td>
					<?php echo $chan;?></td></tr>
				<?php
				}
			}
		}
	echo "</table>";
	}
	
	
	#========================================================================================================================#
	#													Grab the AP's for a given user's Import								 #
	#========================================================================================================================#

	function usersap($row=0)
	{
		include('config.inc.php');
		$pagerow =0;
		mysql_select_db($db,$conn);
		$sql = "SELECT * FROM `users` WHERE `id`='$row'";
		$result = mysql_query($sql, $conn) or die(mysql_error());
		$user_array = mysql_fetch_array($result);
		$aps=explode("-",$user_array["points"]);
		echo '<h1>Access Points For: <a class="links" href ="../opt/userstats.php?func=user&user='.$user_array["username"].'">'.$user_array["username"].'</a></h1><h2>With Title: '.$user_array["title"].'</h2><h2>Imported On: '.$user_array["date"].'</h2>';
		
		echo'<table border="1"><tr><th>AP ID</th><th>Row</th><th>SSID</th><th>Mac Address</th><th>Authentication</th><th>Encryption</th><th>Radio</th><th>Channel</th></tr><tr>';
		foreach($aps as $ap)
		{
			#$pagerow++;
			$ap_exp = explode("," , $ap);
			$udflag = $ap_exp[0];
			$ap_and_row = explode(":",$ap_exp[1]);
			$apid = $ap_and_row[0];
			$row = $ap_and_row[1];
			
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
			    echo '<tr><td>'.$apid.'</td><td>'.$row.'</td><td><a class="links" href="fetch.php?id='.$apid.'">'.$ssid.'</a></td>';
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

	function export_kml()
	{
		include('config.inc.php');
		include('manufactures.inc.php');
		echo '<table><tr><th style="border-style: solid; border-width: 1px">Start of WiFi DB export to KML</th></tr>';
		
		mysql_select_db($db,$conn) or die("Unable to select Database:".$db);
		$sql = "SELECT * FROM `$wtable`";
		$result = mysql_query($sql, $conn) or die(mysql_error());
		while($ap_array = mysql_fetch_array($result))
		{
			$man_mac = str_split($ap_array['mac'],6);
			if(!is_null($manufactures[$man_mac[0]]))
			{
				$manuf = $manufactures[$man_mac[0]];
			}
			else
			{
				$manuf = "Unknown Manufacture";
			}
			$aps[] = array(
							'id' => $ap_array['id'],
							'ssid' => $ap_array['ssid'],
							'mac' => $ap_array['mac'],
							'sectype' => $ap_array['sectype'],
							'radio' => $ap_array['radio'],
							'chan' => $ap_array['chan'],
							'man'	=> $manuf
						   );
		}
		
		$date=date('Y-m-d');
		
		$file_ext = $date."_full_databse.kml";
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
		echo '<tr><td style="border-style: solid; border-width: 1px">Wrote Header to KML File</td><td></td></tr>';
		$x=0;
		$n=0;
		$total = count($aps);
		fwrite( $fileappend, "<Folder>\r\n<name>Access Points</name>\r\n<description>APs: ".$total."</description>\r\n");
		fwrite( $fileappend, "<Folder>\r\n<name>WiFiDB Access Points</name>\r\n");
		echo '<tr><td style="border-style: solid; border-width: 1px">Wrote KML Folder Header</td><td></td></tr>';
		
		foreach($aps as $ap)
		{
			echo '<tr><td style="border-style: solid; border-width: 1px">';
			$table=$ap['ssid'].'-'.$ap['mac'].'-'.$ap['sectype'].'-'.$ap['radio'].'-'.$ap['chan'];
			$table_gps = $table.$gps_ext;
			mysql_select_db($db_st,$conn) or die("Unable to select Database:".$db);
#			echo $table."<br>";
			$sql = "SELECT * FROM `$table`";
			$result = mysql_query($sql, $conn) or die(mysql_error());
			$rows = mysql_num_rows($result);
#			echo $rows."<br>";
			$sql = "SELECT * FROM `$table` WHERE `id`='1'";
			$result1 = mysql_query($sql, $conn) or die(mysql_error());
#			echo $ap['mac']."<BR>";
			while ($newArray = mysql_fetch_array($result1))
			{
				switch($ap['sectype'])
				{
					case 1:
						$type = "#openStyleDead";
						$auth = "Open";
						$encry = "None";
						break;
					case 2:
						$type = "#wepStyleDead";
						$auth = "Open";
						$encry = "WEP";
						break;
					case 3:
						$type = "#secureStyleDead";
						$auth = "WPA-Personal";
						$encry = "TKIP-PSK";
						break;
				}
				
				switch($ap['radio'])
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
				
				$otx = $newArray["otx"];
				$btx = $newArray["btx"];
				$nt = $newArray['nt'];
				$label = $newArray['label'];
				
				$sql6 = "SELECT * FROM `$table_gps`";
				$result6 = mysql_query($sql6, $conn);
				$max = mysql_num_rows($result6);
				
				$sql = "SELECT * FROM `$table_gps` WHERE `id`='1'";
				$result = mysql_query($sql, $conn);
				$gps_table_first = mysql_fetch_array($result);
				
				$date_first = $gps_table_first["date"];
				$time_first = $gps_table_first["time"];
				$fa = $date_first." ".$time_first;
				
				#if($gps_table_first['lat'] == "N 0.0000" or $gps_table_first['long'] == "E 0.0000"){continue;}
				//===================================CONVERT FROM DM TO DD=========================================//
				$lat = $gps_table_first['lat'];
				$long = $gps_table_first['long'];
				if($lat !== "N 0.0000" && $long !== "E 0.0000"){
					$lat &= database::convert_dm_dd($lat);
					$long &= database::convert_dm_dd($long);
				}
				//=====================================================================================================//
				
				$sql = "SELECT * FROM `$table_gps` WHERE `id`='$max'";
				$result = mysql_query($sql, $conn);
				$gps_table_last = mysql_fetch_array($result);
				$date_last = $gps_table_last["date"];
				$time_last = $gps_table_last["time"];
				$la = $date_last." ".$time_last;
				fwrite( $fileappend, "<Placemark id=\"".$ap['mac']."\">\r\n	<name></name>\r\n	<description><![CDATA[<b>SSID: </b>".$ap['ssid']."<br /><b>Mac Address: </b>".$ap['mac']."<br /><b>Network Type: </b>".$nt."<br /><b>Radio Type: </b>".$radio."<br /><b>Channel: </b>".$ap['chan']."<br /><b>Authentication: </b>".$auth."<br /><b>Encryption: </b>".$encry."<br /><b>Basic Transfer Rates: </b>".$btx."<br /><b>Other Transfer Rates: </b>".$otx."<br /><b>First Active: </b>".$fa."<br /><b>Last Updated: </b>".$la."<br /><b>Latitude: </b>".$lat."<br /><b>Longitude: </b>".$long."<br /><b>Manufacturer: </b>".$manuf."<br /><a href=\"".$hosturl."/".$root."/opt/fetch.php?id=".$ap['id']."\">WiFiDB Link</a>]]></description>\r\n	<styleUrl>".$type."</styleUrl>\r\n<Point id=\"".$ap['mac']."_GPS\">\r\n<coordinates>".$long.",".$lat.",0</coordinates>\r\n</Point>\r\n</Placemark>\r\n");
				echo 'Wrote AP: '.$ap['ssid'].'</td></tr>';
				
				unset($gps_table_first["lat"]);
				unset($gps_table_first["long"]);
			}
		}
		fwrite( $fileappend, "	</Folder>\r\n");
		fwrite( $fileappend, "	</Folder>\r\n	</Document>\r\n</kml>");
		fclose( $fileappend );
		echo '<tr><td style="border-style: solid; border-width: 1px">Your Google Earth KML file is ready,<BR>you can download it from <a href="'.$filename.'">Here</a></td><td></td></tr></table>';
		mysql_close($conn);
	}
	
	#========================================================================================================================#
	#						Grab the Manuf for a given MAC, return Unknown Manuf if not found								 #
	#========================================================================================================================#
	
	function &manufactures($mac="")
	{
		include('manufactures.inc.php');
		$man_mac = str_split($mac,6);
		if(!is_null($manufactures[$man_mac[0]]))
		{
			$manuf = $manufactures[$man_mac[0]];
		}
		else
		{
			$manuf = "Unknown Manufacture";
		}
		return $manuf;
	}
	
	#========================================================================================================================#
	#						Grab the AP's for a given user's Import and throw them into a KML file							 #
	#========================================================================================================================#
	
	function exp_kml_user($row=0)
	{	
		echo "<table>";
		include('config.inc.php');
		echo '<tr><th style="border-style: solid; border-width: 1px">Start of WiFi DB export to KML</th></tr>';
		#echo "-------------------------------<BR><BR>";
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
		echo '<tr><td style="border-style: solid; border-width: 1px">Wrote Header to KML File</td><td></td></tr>';
		$x=0;
		$n=0;
		$total = count($aps);
		fwrite( $fileappend, "<Folder>\r\n<name>Access Points</name>\r\n<description>APs: ".$total."</description>\r\n");
		fwrite( $fileappend, "<Folder>\r\n<name>".$title." Access Points</name>\r\n");
		echo '<tr><td style="border-style: solid; border-width: 1px">Wrote KML Folder Header</td><td></td></tr>';
		
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
				mysql_select_db($db_st) or die("Unable to select Database: ".$db_st);
				
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
				echo '<tr><td style="border-style: solid; border-width: 1px">Wrote AP: '.$ssid.'</td></tr>';
				unset($gps_table_first["lat"]);
				unset($gps_table_first["long"]);
			}
		}
		fwrite( $fileappend, "	</Folder>\r\n");
		fwrite( $fileappend, "	</Folder>\r\n	</Document>\r\n</kml>");
		fclose( $fileappend );
		echo '<tr><td style="border-style: solid; border-width: 1px">Your Google Earth KML file is ready,<BR>you can download it from <a href="'.$filename.'">Here</a></td><td></td></tr></table>';
	mysql_close($conn);
	}
	
	#========================================================================================================================#
	#													Export nestet ap to kml file										 #
	#========================================================================================================================#
	
	function exp_newest_kml()
	{
		include('config.inc.php');
		include('manufactures.inc.php');
		$file_ext = 'newest_import.kml';
		$filename = ('../out/kml/'.$file_ext);
		// define initial write and appends
		$filewrite = fopen($filename, "w");
#		echo '<tr><td style="border-style: solid; border-width: 1px">Wrote Header to KML File</td><td></td></tr>';
		if($filewrite != FALSE)
		{
			$file_data = ("");
			$file_data .= ("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n<kml xmlns=\"http://earth.google.com/kml/2.2\">\r\n<Document>\r\n<name>RanInt WifiDB KML</name>\r\n");
			$file_data .= ("<Style id=\"openStyleDead\">\r\n<IconStyle>\r\n<scale>0.5</scale>\r\n<Icon>\r\n<href>http://www.vistumbler.net/images/program-images/open.png</href>\r\n</Icon>\r\n</IconStyle>\r\n</Style>\r\n");
			$file_data .= ("<Style id=\"wepStyleDead\">\r\n<IconStyle>\r\n<scale>0.5</scale>\r\n<Icon>\r\n<href>http://www.vistumbler.net/images/program-images/secure-wep.png</href>\r\n</Icon>\r\n</IconStyle>\r\n</Style>\r\n");
			$file_data .= ("<Style id=\"secureStyleDead\">\r\n<IconStyle>\r\n<scale>0.5</scale>\r\n<Icon>\r\n<href>http://www.vistumbler.net/images/program-images/secure.png</href>\r\n</Icon>\r\n</IconStyle>\r\n</Style>\r\n");
			$file_data .= ('<Style id="Location"><LineStyle><color>7f0000ff</color><width>4</width></LineStyle></Style>');
			// open file and write header:
			
			mysql_select_db($db,$conn) or die("Unable to select Database:".$db);
			$sql = "SELECT * FROM `$wtable`";
			$num_rows = mysql_num_rows($sql, $conn) or die(mysql_error());
			
			$sql = "SELECT * FROM `$wtable` WHERE `ID`='$num_rows'";
			$result = mysql_query($sql, $conn) or die(mysql_error());
			while($ap_array = mysql_fetch_array($result))
			{
				$man_mac = str_split($ap_array['mac'],6);
				if(!is_null($manufactures[$man_mac[0]]))
				{
					$manuf = $manufactures[$man_mac[0]];
				}
				else
				{
					$manuf = "Unknown Manufacture";
				}
				$aps[] = array(
								'id' => $ap_array['id'],
								'ssid' => $ap_array['ssid'],
								'mac' => $ap_array['mac'],
								'sectype' => $ap_array['sectype'],
								'radio' => $ap_array['radio'],
								'chan' => $ap_array['chan'],
								'man'	=> $manuf
							   );
			}
			
			$table=$ap['ssid'].'-'.$ap['mac'].'-'.$ap['sectype'].'-'.$ap['radio'].'-'.$ap['chan'];
			$table_gps = $table.$gps_ext;
			mysql_select_db($db_st,$conn) or die("Unable to select Database:".$db);
#			echo $table."<br>";
			$sql = "SELECT * FROM `$table`";
			$result = mysql_query($sql, $conn) or die(mysql_error());
			$rows = mysql_num_rows($result);
#			echo $rows."<br>";
			$sql = "SELECT * FROM `$table` WHERE `id`='1'";
			$result1 = mysql_query($sql, $conn) or die(mysql_error());
#			echo $ap['mac']."<BR>";
			while ($newArray = mysql_fetch_array($result1))
			{
				switch($ap['sectype'])
				{
					case 1:
						$type = "#openStyleDead";
						$auth = "Open";
						$encry = "None";
						break;
					case 2:
						$type = "#wepStyleDead";
						$auth = "Open";
						$encry = "WEP";
						break;
					case 3:
						$type = "#secureStyleDead";
						$auth = "WPA-Personal";
						$encry = "TKIP-PSK";
						break;
				}
				
				switch($ap['radio'])
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
				
				$otx = $newArray["otx"];
				$btx = $newArray["btx"];
				$nt = $newArray['nt'];
				$label = $newArray['label'];
				
				$sql6 = "SELECT * FROM `$table_gps`";
				$result6 = mysql_query($sql6, $conn);
				$max = mysql_num_rows($result6);
				
				$sql = "SELECT * FROM `$table_gps` WHERE `id`='1'";
				$result = mysql_query($sql, $conn);
				$gps_table_first = mysql_fetch_array($result);
				
				$date_first = $gps_table_first["date"];
				$time_first = $gps_table_first["time"];
				$fa = $date_first." ".$time_first;
				
				#if($gps_table_first['lat'] == "N 0.0000" or $gps_table_first['long'] == "E 0.0000"){continue;}
				//===================================CONVERT FROM DM TO DD=========================================//
				$lat = $gps_table_first['lat'];
				$long = $gps_table_first['long'];
				if($lat !== "N 0.0000" && $long !== "E 0.0000"){
					$lat &= database::convert_dm_dd($lat);
					$long &= database::convert_dm_dd($long);
				}
				//=====================================================================================================//
				
				$sql = "SELECT * FROM `$table_gps` WHERE `id`='$max'";
				$result = mysql_query($sql, $conn);
				$gps_table_last = mysql_fetch_array($result);
				$date_last = $gps_table_last["date"];
				$time_last = $gps_table_last["time"];
				$la = $date_last." ".$time_last;
				$file_data .= ("<Placemark id=\"".$ap['mac']."\">\r\n	<name></name>\r\n	<description><![CDATA[<b>SSID: </b>".$ap['ssid']."<br /><b>Mac Address: </b>".$ap['mac']."<br /><b>Network Type: </b>".$nt."<br /><b>Radio Type: </b>".$radio."<br /><b>Channel: </b>".$ap['chan']."<br /><b>Authentication: </b>".$auth."<br /><b>Encryption: </b>".$encry."<br /><b>Basic Transfer Rates: </b>".$btx."<br /><b>Other Transfer Rates: </b>".$otx."<br /><b>First Active: </b>".$fa."<br /><b>Last Updated: </b>".$la."<br /><b>Latitude: </b>".$lat."<br /><b>Longitude: </b>".$long."<br /><b>Manufacturer: </b>".$manuf."<br /><a href=\"".$hosturl."/".$root."/opt/fetch.php?id=".$ap['id']."\">WiFiDB Link</a>]]></description>\r\n	<styleUrl>".$type."</styleUrl>\r\n<Point id=\"".$ap['mac']."_GPS\">\r\n<coordinates>".$long.",".$lat.",0</coordinates>\r\n</Point>\r\n</Placemark>\r\n");
#				echo 'Wrote AP: '.$ap['ssid'].'</td></tr>';
			}
		}else
		{
#			echo "Failed to write KML File, Check the permissions on the wifidb folder, and make sure that Apache (or what ever HTTP server you are using) has permissions to write";
		}
		$fileappend = fopen($filename, "a");
		fwrite($fileappend, $filedata);
	}

}#end DATABASE CLASS
?>