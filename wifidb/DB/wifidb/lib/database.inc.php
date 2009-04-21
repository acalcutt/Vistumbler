<?php
#include('manufactures.inc.php');
global $ver;
$ver = array(
			"wifidb"			=>	"0.16 Build 1",
			"Last_Core_Edit" 	=> 	"2009-Apr-12",
			"database"			=>	array(  
										"import_vs1"		=>	"1.5.6", 
										"apfetch"			=>	"2.5.0",
										"gps_check_array"	=>	"1.1",
										"all_users"			=>	"1.2",
										"users_lists"		=>	"1.2",
										"user_ap_list"		=>	"1.2",
										"all_users_ap"		=>	"1.3",
										"exp_KML"			=>	"3.3.0",
										"convert_dm_dd"		=>	"1.3.0",
										"convert_dd_dm"		=>	"1.3.1",
										"manufactures"		=>	"1.0"
										),
			"Misc"				=>	array(
										"pageheader"			=>  "1.0",
										"footer"				=>	"1.2",
										"smart_quotes"			=> 	"1.0",
										"smart"					=> 	"1.0",
										"Manufactures-list"		=> 	"2.0",
										"Languages-List"		=>	"1.0"
										),
			);


function pageheader($title)
{
	include('config.inc.php');
	echo '<title>Wireless DataBase *Alpha*'.$GLOBALS['ver']["wifidb"].' --> '.$title.'</title>';
	?>
	<link rel="stylesheet" href="<?php echo $root;?>/css/site4.0.css">
	<body topmargin="10" leftmargin="0" rightmargin="0" bottommargin="10" marginwidth="10" marginheight="10">
	<div align="center">
	<table border="0" width="75%" cellspacing="10" cellpadding="2">
		<tr>
			<td colspan="2" bgcolor="#315573">
			<p align="center"><b><font size="5" face="Arial" color="#FFFFFF">
			Wireless DataBase *Alpha* <?php echo $GLOBALS['ver']["wifidb"]; ?></font>
			<font color="#FFFFFF" size="2">
				<a class="links" href="/">[Root] </a>/ <a class="links" href="/wifidb/">[WifiDB] </a>/
			</font></b>
			</td>
		</tr>
		<tr>
	<td width="17%" bgcolor="#304D80" valign="top">
	<?php
	mysql_select_db($db,$conn);
	$sqls = "SELECT * FROM links ORDER BY ID ASC";
	$result = mysql_query($sqls, $conn) or die(mysql_error());
	while ($newArray = mysql_fetch_array($result))
	{
		$testField = $newArray['links'];
		echo "<p>$testField</p>";
	}
}

#========================================================================================================================#
#											Footer (writes the footer for all pages)									 #
#========================================================================================================================#

function footer($filename = '')
{
	include('config.inc.php');
	$file_ex = explode("/", $filename);
	$count = count($file_ex);
	$file = $file_ex[($count)-1];
	?>
	</p>
	</td>
	</tr>
	<tr>
	<td bgcolor="#315573" height="23"><a href="<?php echo $root; ?>/img/moon.png"><img border="0" src="<?php echo $root; ?>/img/moon_tn.png"></a></td>
	<td bgcolor="#315573" width="0" align="center">
	<?php
	if (file_exists($filename)) {?>
		<h6><i><u><?php echo $file;?></u></i> was last modified:  <?php echo date ("Y F d @ H:i:s", filemtime($filename));?></h6>
	<?php
	}
	echo $tracker;
	echo $ads;
	?>
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
					7=>"$",
					8=>"?>",
					9=>";",
					10=>"#",
					11=>"&",
					12=>"=",
					13=>"~",
					14=>"^",
					15=>"`",
					16=>"+",
					17=>"%",
					18=>"!",
					19=>"@",
					20=>"-",
					21=>"/"
				);
	$text = preg_replace($pattern,"&#147;\\1&#148;",stripslashes($text));
	$text = str_replace($strip,"_",$text);
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



class database
{
	#========================================================================================================================#
	#						Grab the Manuf for a given MAC, return Unknown Manuf if not found								 #
	#========================================================================================================================#
	function &manufactures($mac="")
	{
		include('manufactures.inc.php');
		$man_mac = str_split($mac,6);
		if(isset($manufactures[$man_mac[0]]))
		{
			$manuf = $manufactures[$man_mac[0]];
		}
		else
		{
			$manuf = "Unknown Manufacture";
		}
		return $manuf;
	}

	function import_gpx($source="" , $user="Unknown" , $notes="No Notes" , $title="UNTITLED" )
	{
		$start = microtime(true);
		$times=date('Y-m-d H:i:s');
		
		if ($source == NULL){?><h2>You did not submit a file, please <A HREF="javascript:history.go(-1)"> [Go Back]</A> and do so.</h2> <?php die();}
		
		include('../lib/config.inc.php');
		
		$apdata  = array();
		$gpdata  = array();
		$signals = array();
		$sats_id = array();
		
		$fileex  = explode(".", $source);
		$return  = file($source);
		$count = count($return);
		$rettest = substr($return[1], 1, -1);
		
		if ($rettest = 'gpx xmlns="http://www.topografix.com/GPX/1/1" creator="Vistumbler 9.3 Beta 2" version="1.1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd"')
		{	
			echo $rettest."<br>";
		}else
		{
			echo '<h1>You need to upload a valid GPX file, go look up the santax for it, or the file that you saved is corrupted</h1>';
		}
	}
	#========================================================================================================================#
	#													VS1 File import													     #
	#========================================================================================================================#
	
	function import_vs1($source="" , $user="Unknown" , $notes="No Notes" , $title="UNTITLED" )
	{
		$start = microtime(true);
		$times=date('Y-m-d H:i:s');
		if ($source == NULL){?><h2>You did not submit a file, please <A HREF="javascript:history.go(-1)"> [Go Back]</A> and do so.</h2> <?php die();}
		include('../lib/config.inc.php');
		//	$gdata [ ID ] [ object ]
		//		   num     lat / long / sats / date / time
		if ($user == ""){$user="Unknown";}
		
		$user_n	 = 0;
		$N		 = 0;
		$n		 = 0;
		$gpscount= 0;
		$co		 = 0;
		$cco	 = 0;
		$apdata  = array();
		$gpdata  = array();
		$signals = array();
		$sats_id = array();
		$fileex  = explode(".", $source);
		$return  = file($source);
		$count = count($return);
		if($count <= 8) { echo "<h3>You cannot upload an empty VS1 file, atleast scan for a few seconds to import some data.</h3><a href=\"index.php\"><A HREF=\"javascript:history.go(-1)\"> [Go Back]</A> and do it again</a>"; footer("../import/insertnew.php");die();}
		
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
					if($wifi[0] === "" && $wifi[1] === "" && $wifi[5] === "" && $wifi[6] === "" && $wifi[7] === ""){continue;}
					mysql_select_db($db,$conn);
					$dbsize = mysql_query("SELECT * FROM `$wtable`", $conn) or die(mysql_error($conn));
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
			#		$wifi[12] = strip_tags($wifi[12]);
					// sanitize wifi data to be used in table name
					$ssidss = strip_tags(smart_quotes($wifi[0]));
					$ssidsss = str_split($ssidss,25);
					$ssids = $ssidsss[0];
					if($wifi[1] == ''){$wifi[1] = "00:00:00:00:00:00";}
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
					if(!isset($table_ptb)){$table_ptb="";}
					if(strcmp($table,$table_ptb)===0)
					{
						// They are the same
						
						mysql_select_db($db_st,$conn);
						?><table border="1" width="90%" class="update"><tr class="style4"><th>ID</th><th>New/Update</th><th>SSID</th><th>Mac Address</th><th>Authentication</th><th>Encryption</th><th>Radion Type</th><th>Channel</th></tr>
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
						$todo=array();
						$prev='';
						?>
							<tr><td colspan="8">
						<?php
						$sig_stats = array();
						$sig_stats['db'] = 0;
						$sig_stats['newf'] = 0;
						$sig_stats['news'] = 0;
						$sig_stats['updatef'] = 0;
						$sig_stats['updates'] = 0;
						foreach($signal_exp as $exp)
						{
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
							
							if($prev == $vs1_id)
							{
								$gps_id_ = $gps_id-1;
								$signals[$gps_id] = $gps_id_.",".$signal;
								continue;
							}
							if($GLOBALS["debug"]  === 1)
							{
								$apecho = "+-+-+-+AP Data+-+-+-+<br> VS1 ID:".$vs1_id." <br> Next DB ID: ".$gps_id."<br>"
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
							$DBresult = mysql_query("SELECT * FROM `$gps_table` WHERE `id` = '$dbid'", $conn);
							$GPSDBArray = mysql_fetch_array($DBresult);
							
							if($return_gps === 0)
							{
								$sqlitgpsgp = "INSERT INTO `$gps_table` ( `id` , `lat` , `long` , `sats`, `hdp`, `alt`, `geo`, `kmh`, `mph`, `track` , `date` , `time` ) "
											   ."VALUES ( '$gps_id', '$lat', '$long', '$sats', $hdp, $alt, $geo, $kmh, $mph, $track, '$date', '$time')";
								if (mysql_query($sqlitgpsgp, $conn))
								{
									$sig_stats['news']++;
						#			echo "(3)Insert into [".$db_st."].{".$gps_table."}<br>		 => Added GPS History to Table<br>";
								}else
								{
									$sig_stats['newf']++;
						#			echo "There was an Error inserting the GPS information";
								}
								$signals[$gps_id] = $gps_id.",".$signal;
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
										$sig_stats['updates']++;
						#				echo "(4)Update [".$db_st."].{".$gps_table."} (ID: ".$hi_sats_id."<br>		 => Updated GPS History in Table<br>";
									}else
									{
										$sig_stats['updatef']++;
						#				echo "A MySQL Update error has occured<br>";echo mysql_error($conn);
									}
									$signals[$gps_id] = $dbid.",".$signal;
									$gps_id++;
							#		continue;
								}else
								{
									$sig_stats['db']++;
						#			echo "GPS Point already in DB<BR>----".$dbid."- <- DB ID<br>";
									$signals[$gps_id] = $dbid.",".$signal;
									$gps_id++;
							#		break;
								}
							}
						}
						echo "GPS in DB: ".$sig_stats['db']."<br>GPS New That failed import: ".$sig_stats['newf']."<br>GPS Imports that are good: ".$sig_stats['news']."<br>GPS That failed update: ".$sig_stats['updatef']."<br>GPS Updates that are good: ".$sig_stats['updates'];
						?>
							</td></tr>
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
							$sqlct = "CREATE TABLE `$table` (`id` INT( 255 ) NOT NULL AUTO_INCREMENT , `btx` VARCHAR( 10 ) NOT NULL , `otx` VARCHAR( 10 ) NOT NULL , `nt` VARCHAR( 15 ) NOT NULL , `label` VARCHAR( 25 ) NOT NULL , `sig` TEXT NOT NULL , `user` VARCHAR(25) NOT NULL , INDEX ( `id` ), PRIMARY KEY (`id`) )  ENGINE = 'InnoDB' DEFAULT CHARSET='utf8'";
							if (mysql_query($sqlcgt, $conn) or die(mysql_error()))
							{
								echo "(1)Create Table [".$db_st."].{".$table."}<br>		 => Thats odd the table was missing, well I added a Table for ".$ssids."<br>";
								if (mysql_query($sqlit, $conn)or die(mysql_error()))
								{
									echo "(3)Insert into [".$db_st."].{".$table."}<br>		 => Added GPS History to Table<br>";
								}
							}
						}
						?>
						</td></tr></table><br>
						<?php
					}else
					{
						?><table border="1" width="90%" class="new"><tr class="style4"><th>ID</th><th>New/Update</th><th>SSID</th><th>Mac Address</th><th>Authentication</th><th>Encryption</th><th>Radion Type</th><th>Channel</th></tr>
						<tr><td><?php echo $size;?></td><td><b>N</b></td><td><?php echo $ssids;?></td><td><?php echo $wifi[1];?></td><td><?php echo $authen;?></td><td><?php echo $encryp;?></td><td><?php echo $radios;?></td><td><?php echo $chan;?></td></tr>
						<?php
						?>
						<tr><td colspan="8">
						<?php
						mysql_select_db($db_st,$conn)or die(mysql_error($conn));
						
						$sqlct = "CREATE TABLE `$table` (`id` INT( 255 ) NOT NULL AUTO_INCREMENT , `btx` VARCHAR( 10 ) NOT NULL , `otx` VARCHAR( 10 ) NOT NULL , `nt` VARCHAR( 15 ) NOT NULL , `label` VARCHAR( 25 ) NOT NULL , `sig` TEXT NOT NULL , `user` VARCHAR(25) NOT NULL ,PRIMARY KEY (`id`) ) ENGINE = 'InnoDB' DEFAULT CHARSET='utf8'";
						mysql_query($sqlct, $conn);
						echo "(1)Create Table [".$db_st."].{".$table."}<br>		 => Added new Table for ".$ssids."<br>";
						
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
						echo "(2)Create Table [".$db_st."].{".$gps_table."}<br>		 => Added new GPS Table for ".$ssids."<br>";
						$signal_exp = explode("-",$wifi[12]);
					#	echo $wifi[12]."<BR>";
						$gps_id = 1;
						$N=0;
						$prev = '';
						foreach($signal_exp as $exp)
						{
							
							?>
							<tr><td colspan="8">
							<?php
							$esp = explode(",",$exp);
							$vs1_id = $esp[0];
							$signal = $esp[1];
							if ($prev == $vs1_id)
							{
								$gps_id_ = $gps_id-1;
								$signals[$gps_id] = $gps_id_.",".$signal;
								echo "GPS Point already in DB<BR>----".$gps_id_."- <- DB ID<br>";
								continue;
							}
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
								echo "(3)Insert into [".$db_st."].{".$gps_table."}<br>		 => Added GPS History to Table";
							}else
							{
								echo "There was an error inserting the GPS data.<br>".mysql_error($conn);
							}
							$signals[$gps_id] = $gps_id.",".$signal;
					#		echo $signals[$gps_id];
							$gps_id++;
							?>
							</td></tr>
							<?php
							$prev = $vs1_id;
						}
						?>
						<tr><td colspan="8">
						<?php
						$sig = implode("-",$signals);
						
						$sqlit = "INSERT INTO `$table` ( `id` , `btx` , `otx` , `nt` , `label` , `sig`, `user` ) VALUES ( '', '$btx', '$otx', '$nt', '$label', '$sig', '$user')";
						mysql_query($sqlit, $conn) or die(mysql_error($conn));
						echo "(3)Insert into [".$db_st."].{".$table."}<br>		 => Add Signal History to Table<br>";
						
						# pointers
						mysql_select_db($db,$conn);
						$sqlp = "INSERT INTO `$wtable` ( `id` , `ssid` , `mac` ,  `chan`, `radio`,`auth`,`encry`, `sectype` ) VALUES ( '$size', '$ssidss', '$macs','$chan', '$radios', '$authen', '$encryp', '$sectype')";
						if (mysql_query($sqlp, $conn) or die(mysql_error($conn)))
						{
							echo "(1)Insert into [".$db."].{".$wtable."} => Added Pointer Record<br>";
							$user_aps[$user_n]="0,".$size.":1";
							$user_n++;
							$sqlup = "UPDATE `$settings_tb` SET `size` = '$size' WHERE `table` = '$wtable' LIMIT 1;";
							if (mysql_query($sqlup, $conn) or die(mysql_error($conn)))
							{
								
								echo 'Updated ['.$db.'].{'.$wtable."} with new Size <br>		=> ".$size."<br>";
								
							}else
							{
								echo mysql_error()." => Could not Add new pointer to table (this has been logged) <br>";
							}
						}else{echo "Something went wrong, I couldn't add in the pointer :-( <br>";}
						echo "</td></tr></table><br>";
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
		if($title === ''){$title = "Untitled";}
		if($user === ''){$user="Unknown";}
		if($notes === ''){$notes="No Notes";}
		if (!$user_ap_s == "")
		{$sqlu = "INSERT INTO `users` ( `id` , `username` , `points` ,  `notes`, `date`, `title`) VALUES ( '', '$user', '$user_ap_s','$notes', '$times', '$title')";
		mysql_query($sqlu, $conn) or die(mysql_error($conn));}
		mysql_close($conn);
		$total_ap = count($user_aps);
		$gdatacount = count($gdata);
		echo "<br>DONE!";
		$end = microtime(true);
		if ($GLOBALS["bench"]  == 1)
		{
			echo '<table border="1">'
				 .'<tr class="style4"><th colspan="2">Benchmark Times</th></tr>'
				 .'<tr><td colspan="2">Time is [Unix Epoc]</td></tr>'
				 .'<tr><td>Start Time:</td><td>'.$start.'</td></tr>'
				 .'<tr><td>  End Time:</td><td>'.$end.'</td></tr>'
				 .'<tr><td> Total GPS:</td><td>'.$gdatacount.'</td></tr>'
				 .'<tr><td> Total APs:</td><td>'.$total_ap.'</td></tr>'
				 .'</table>';
		}
	}
	
	
	#========================================================================================================================#
	#													Convert GeoCord DM to DD									   	     #
	#========================================================================================================================#
	
	function &convert_dm_dd($geocord_in = "")
	{
		$start = microtime(true);
	//	GPS Convertion :
		$neg=FALSE;
		$geocord_exp = explode(".", $geocord_in);//replace any Letter Headings with Numeric Headings
		$geocord_front = explode(" ", $geocord_exp[0]);
		if($geocord_exp[0][0] === "S" or $geocord_exp[0][0] === "W"){$neg = TRUE;}
		$patterns[0] = '/N /';
		$patterns[1] = '/E /';
		$patterns[2] = '/S /';
		$patterns[3] = '/W /';
		$replacements = "";
		$geocord_in = preg_replace($patterns, $replacements, $geocord_in);
		$geocord_exp = explode(".", $geocord_in);
		if($geocord_exp[0][0] === "-"){$geocord_exp[0] = 0 - $geocord_exp[0];$neg = TRUE;}
		// 428.7753 ---- 428 - 7753
		$geocord_dec = "0.".$geocord_exp[1];
		// 428.7753 ---- 428 - 0.7753
		$len = strlen($geocord_exp[0]);
#		echo $len.'<BR>';
		$geocord_min = substr($geocord_exp[0],-2,3);
#		echo $geocord_min.'<BR>';
		// 428.7753 ---- 4 - 28 - 0.7753
		$geocord_min = $geocord_min+$geocord_dec;
		// 428.7753 ---- 4 - 28.7753
		$geocord_div = $geocord_min/60;
		// 428.7753 ---- 4 - (28.7753)/60 = 0.4795883
		if($len ==3)
		{
			$geocord_deg = substr($geocord_exp[0], 0,1);
#			echo $geocord_deg.'<br>';
		}elseif($len == 4)
		{
			$geocord_deg = substr($geocord_exp[0], 0,2);
#			echo $geocord_deg.'<br>';
		}elseif($len == 5)
		{
			$geocord_deg = substr($geocord_exp[0], 0,3);
#			echo $geocord_deg.'<br>';
		}
		$geocord_out = $geocord_deg + $geocord_div;
		// 428.7753 ---- 4.4795883
		if($neg === TRUE){$geocord_out = "-".$geocord_out;}
		$end = microtime(true);
		if ($GLOBALS["bench"]  == 1)
		{
			echo "Time is [Unix Epoc]<BR>";
			echo "Start Time: ".$start."<BR>";
			echo "  End Time: ".$end."<BR>";
		}
		$geocord_out = substr($geocord_out, 0,10);
		return $geocord_out;
	}
	#========================================================================================================================#
	#													Convert GeoCord DD to DM									   	     #
	#========================================================================================================================#
	
	function &convert_dd_dm($geocord_in="")
	{
		$start = microtime(true);
		//	GPS Convertion :
#		echo $geocord_in.'<BR>';
		$neg=FALSE;
		$geocord_exp = explode(".", $geocord_in);
		$geocord_front = explode(" ", $geocord_exp[0]);
		
		if($geocord_exp[0][0] == "S" or $geocord_exp[0][0] == "W"){$neg = TRUE;}
		$pattern[0] = '/N /';
		$pattern[1] = '/E /';
		$pattern[2] = '/S /';
		$pattern[3] = '/W /';
		$replacements = "";
		$geocord_exp[0] = preg_replace($pattern, $replacements, $geocord_exp[0]);
		
		if($geocord_exp[0][0] === "-"){$geocord_exp[0] = 0 - $geocord_exp[0];$neg = TRUE;}
		// 4.146255 ---- 4 - 146255
#		echo $geocord_exp[1].'<br>';
		$geocord_dec = "0.".$geocord_exp[1];
		// 4.146255 ---- 4 - 0.146255
#		echo $geocord_dec.'<br>';
		$geocord_mult = $geocord_dec*60;
		// 4.146255 ---- 4 - (0.146255)*60 = 8.7753
#		echo $geocord_mult.'<br>';
		$mult = explode(".",$geocord_mult);
#		echo $len.'<br>';
		if( strlen($mult[0]) < 2 )
		{
			$geocord_mult = "0".$geocord_mult;
		}
		// 4.146255 ---- 4 - 08.7753
		$geocord_out = $geocord_exp[0].$geocord_mult;
		// 4.146255 ---- 408.7753
		$geocord_o = explode(".", $geocord_out);
		if( strlen($geocord_o[1]) > 4 ){ $geocord_o[1] = substr($geocord_o[1], 0 , 4); $geocord_out = implode('.', $geocord_o); }
		
		if($neg === TRUE){$geocord_out = "-".$geocord_out;}
		$end = microtime(true);
		if ($GLOBALS["bench"]  == 1)
		{
			echo "Time is [Unix Epoc]<BR>";
			echo "Start Time: ".$start."<BR>";
			echo "  End Time: ".$end."<BR>";
		}
		return $geocord_out;
	}
	
	#========================================================================================================================#
	#													GPS check, make sure there are no duplicates						 #
	#========================================================================================================================#

	function &check_gps_array($gpsarray, $test)
	{
		$start = microtime(true);
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
		#	echo $test."<BR>".$gps_t."<BR>";
			$testing = strcasecmp($gps_t,$test);
		#	echo $testing."<BR>";
			if ($testing===0)
			{
				if ($GLOBALS["debug"]  == 1 ) {
					echo  "  SAME<br>";
					echo  "  Array data: ".$gps_t."<br>";
					echo  "  Testing data: ".$test."<br>.-.-.-.-.=.-.-.-.-.<br>";
					echo  "-----=-----=-----<br>|<br>|<br>"; 
				}
				$returns = array(0=>1,1=>$id);
				return $returns;
				break;
			}else
			{
				if ($GLOBALS["debug"]  == 1){
					echo  "  NOT SAME<br>";
					echo  "  Array data: ".$gps_t."<br>";
					echo  "  Testing data: ".$test."<br>----<br>";
					echo  "-----=-----<br>";
				}
				$return = array(0=>0,1=>0);
			}
		}
		$end = microtime(true);
		if ($GLOBALS["bench"]  == 1)
		{
			#echo "Time is [Unix Epoc]<BR>";
			#echo "Start Time: ".$start."<BR>";
			#echo "  End Time: ".$end."<BR>";
		}
		return $return;
	}
	
	
	#========================================================================================================================#
	#													AP History Fetch													 #
	#========================================================================================================================#

	function apfetch($id=0)
	{
		$start = microtime(true);
		include('../lib/config.inc.php');
		mysql_select_db($db,$conn);
		$sqls = "SELECT * FROM `$wtable` WHERE id='$id'";
		$result = mysql_query($sqls, $conn) or die(mysql_error());
		$newArray = mysql_fetch_array($result);
		$ID = $newArray['id'];
		$tablerowid = 0;
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
				<h1><?php echo $newArray['ssid'];?></h1>
				<TABLE WIDTH=569 BORDER=1 CELLPADDING=4 CELLSPACING=0>
				<TABLE WIDTH=569 BORDER=1 CELLPADDING=4 CELLSPACING=0>
				<COL WIDTH=112><COL WIDTH=439>
				<TR VALIGN=TOP><TD class="style4" WIDTH=112><P>MAC Address</P></TD><TD WIDTH=439><P><?php echo $mac_full;?></P></TD></TR>
				<TR VALIGN=TOP><TD class="style4" WIDTH=112><P>Manufacture</P></TD><TD WIDTH=439><P><?php echo $manuf;?></P></TD></TR>
				<TR VALIGN=TOP><TD class="style4" WIDTH=112 HEIGHT=26><P>Authentication</P></TD><TD WIDTH=439><P><?php echo $newArray['auth'];?></P></TD></TR>
				<TR VALIGN=TOP><TD class="style4" WIDTH=112><P>Encryption Type</P></TD><TD WIDTH=439><P><?php echo $newArray['encry'];?></P></TD></TR>
				<TR VALIGN=TOP><TD class="style4" WIDTH=112><P>Radio Type</P></TD><TD WIDTH=439><P><?php echo $radio;?></P></TD></TR>
				<TR VALIGN=TOP><TD class="style4" WIDTH=112><P>Channel #</P></TD><TD WIDTH=439><P><?php echo $newArray['chan'];?></P></TD></TR>
		<?php
		?>
		<tr><td colspan="2" align="center" ><a class="links" href="../opt/export.php?func=exp_single_ap&row=<?php echo $ID;?>">Export this AP to KML</a></td></tr>
		</table>
		<TABLE WIDTH=569 BORDER=1 CELLPADDING=4 CELLSPACING=0>
		<tr><td colspan="10" class="style4">Signal History</td></tr>
		<tr class="style4"><th>Row</th><th>Btx</th><th>Otx</th><th>First Active</th><th>Last Update</th><th>Network Type</th><th>Label</th><th>User</th><th>Signal</th><th>Plot</th></tr>
		<?php
		$start1 = microtime(true);
		mysql_select_db($db_st, $conn);
		$result = mysql_query("SELECT * FROM `$table` ORDER BY `id`", $conn) or die(mysql_error());
		while ($field = mysql_fetch_array($result))
		{
			$row = $field["id"];
			$row_id = $row.','.$id;
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
				<tr><td align="center"><?php echo $row; ?></td><td>
				<?php echo $field["btx"]; ?></td><td>
				<?php echo $field["otx"]; ?></td><td>
				<?php echo $fa; ?></td><td>
				<?php echo $lu; ?></td><td>
				<?php echo $field["nt"]; ?></td><td>
				<?php echo $field["label"]; ?></td><td>
				<a class="links" href="../opt/userstats.php?func=allap&user=<?php echo $field["user"]; ?>"><?php echo $field["user"]; ?></a></td><td>
				<a class="links" href="../graph/?row=<?php echo $row; ?>&id=<?php echo $ID; ?>">Graph Signal</a></td><td><a class="links" href="export.php?func=exp_all_signal&row=<?php echo $row_id;?>">Plot Signal</a></td></tr>
				<tr><td colspan="10" align="center">
				<script type="text/javascript">
				function displayRow<?php print ($tablerowid);?>()
				{
					var row = document.getElementById("captionRow<?php echo $tablerowid;?>");
					if (row.style.display == '') row.style.display = 'none';
					else row.style.display = '';
				}
				</script>
				<button onclick="displayRow<?php echo $tablerowid;?>()" >Show / Hide GPS</button>
				<table id="captionRow<?php echo $tablerowid;?>" WIDTH=569 BORDER=1 CELLPADDING=4 CELLSPACING=0>
				<th colspan="6" class="style4">GPS History</th></tr>
				<tr class="style4">		<th>Row</th><th>Lat</th><th>Long</th><th>Sats</th><th>Date</th><th>Time</th></tr>
				<?php
				$tablerowid++;
				$signals = explode('-',$field['sig']);
				foreach($signals as $signal)
				{
					$sig_exp = explode(',',$signal);
					$id = $sig_exp[0];
					$start2 = microtime(true);
					$result1 = mysql_query("SELECT * FROM `$table_gps` WHERE `id` = '$id'", $conn) or die(mysql_error());
					while ($field = mysql_fetch_array($result1)) 
					{
						?>
						<tr><td align="center">
						<?php echo $field["id"]; ?></td><td>
						<?php echo $field["lat"]; ?></td><td>
						<?php echo $field["long"]; ?></td><td align="center">
						<?php echo $field["sats"]; ?></td><td>
						<?php echo $field["date"]; ?></td><td>
						<?php echo $field["time"]; ?></td></tr>
						<?php
					}
					$end2 = microtime(true);
				}
				?>
				</table>
				</td></tr>
				<?php
		}
		$end1 = microtime(true);
		?>
		</table>
		<TABLE WIDTH=569 BORDER=1 CELLPADDING=4 CELLSPACING=0>
		<?php
		#END GPSFETCH FUNC
		?>
		<tr><td align="center" colspan="5" class="style4">Associated Lists</td></tr>
		<tr class="style4"><th>ID</th><th>User</th><th>Title</th><th>Total APs</th><th>Date</th></tr>
		<?php
		$start3 = microtime(true);
		mysql_select_db($db, $conn);
		$result = mysql_query("SELECT * FROM `users`", $conn);
		while ($field = mysql_fetch_array($result)) 
		{
			$APS = explode("-" , $field['points']);
			foreach ($APS as $AP)
			{
				$access = explode(",", $AP);
				$access1 = explode(":",$access[1]);
				if($access[0] == 1){continue;}
				if ( $ID  ==  $access1[0] )
				{
					$list[]=$field['id'];
				}
			}
		}
		if(isset($list))
		{
			foreach($list as $aplist)
			{
				$result = mysql_query("SELECT * FROM `users` WHERE `id`='$aplist'", $conn);
				while ($field = mysql_fetch_array($result)) 
				{
					if($field["title"]==''){$field["title"]="Untitled";}
					$points = explode('-' , $field['points']);
					$total = count($points);
					?>
					<td align="center"><a class="links" href="userstats.php?func=useraplist&row=<?php echo $field["id"];?>"><?php echo $field["id"];?></a></td><td><a class="links" href="userstats.php?func=alluserlists&user=<?php echo $field["username"];?>"><?php echo $field["username"];?></a></td><td><a class="links" href="userstats.php?func=useraplist&row=<?php echo $field["id"];?>"><?php echo $field["title"];?></a></td><td align="center"><?php echo $total;?></td><td><?php echo $field['date'];?></td></tr>
					<?php
				}
			}
		}else
		{
			?>
			<td colspan="5" align="center">There are no Other Lists with this AP in it.</td></tr>
			<?php
			
		}
		$end3 = microtime(true);
		mysql_close($conn);
		?>
		</table><br>
		<?php
		$end = microtime(true);
		if ($GLOBALS["bench"]  == 1)
		{
			echo "Time is [Unix Epoc]<BR>";
			echo "Total Start Time: ".$start."<BR>";
			echo "Total  End Time: ".$end."<BR>";
			echo "Start Time 1: ".$start1."<BR>";
			echo "  End Time 1: ".$end1."<BR>";
			echo "Start Time 2: ".$start2."<BR>";
			echo "  End Time 2: ".$end2."<BR>";
			echo "Start Time 3: ".$start3."<BR>";
			echo "  End Time 3: ".$end3."<BR>";
		}
		#END IMPORT LISTS FETCH FUNC
	}
	
	
	#========================================================================================================================#
	#													Grab the stats for All Users										 #
	#========================================================================================================================#
	function all_users()
	{
		$start = microtime(true);
		include('config.inc.php');
		$users = array();
		$userarray = array();
		?>
			<h1>Stats For: All Users</h1>
			<table border="1"><tr class="style4">
			<th>ID</th><th>UserName</th><th>Title</th><th>Number of APs</th><th>Imported On</th></tr><tr>
		<?php
		
		mysql_select_db($db,$conn);
		$sql = "SELECT * FROM `users` ORDER BY username ASC";
		$result = mysql_query($sql, $conn) or die(mysql_error());
		$num = mysql_num_rows($result);
		if($num == 0)
		{
			echo '<tr><td colspan="5" align="center">There no Users, Import something.</td></tr></table>'; 
			$filename = $_SERVER['SCRIPT_FILENAME'];
			footer($filename);
			die();
		}
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
					echo '<tr><td>'.$user_array['id'].'</td><td><a class="links" href="userstats.php?func=alluserlists&user='.$username.'">'.$username.'</a></td><td><a class="links" href="userstats.php?func=useraplist&row='.$user_array["id"].'">'.$user_array['title'].'</a></td><td>'.$pc.'</td><td>'.$user_array['date'].'</td></tr>';
				}
				else
				{
					?>
					<tr><td></td><td></td><td><a class="links" href="userstats.php?func=useraplist&row=<?php echo $user_array["id"];?>"><?php echo $user_array['title'];?></a></td><td><?php echo $pc;?></td><td><?php echo $user_array['date'];?></td></tr>
					<?php
				}
				$pre_user = $username;
			}
			?>
			<tr></tr>
			<?php
		}
		
		?>
		</tr></td></table><br>
		<?php
		$end = microtime(true);
				if ($GLOBALS["bench"]  == 1)
				{
					echo "Time is [Unix Epoc]<BR>";
					echo "Start Time: ".$start."<BR>";
					echo "  End Time: ".$end."<BR>";
				}
	}
	
	
	#========================================================================================================================#
	#													Grab All the AP's for a given user									 #
	#========================================================================================================================#
	
	function all_users_ap($user="")
	{
		$start = microtime(true);
		?>
		<h3>View All Users <a class="links" href="userstats.php?func=allusers">Here</a></h3>
		<h1>Access Points For: <a class="links" href ="../opt/userstats.php?func=alluserlists&user=<?php echo $user;?>"><?php echo $user;?></a></h1>
		<h3><a class="links" href="../opt/export.php?func=exp_user_all_kml&user=<?php echo $user;?>">Export To KML File</a></h3>
		<table border="1"><tr class="style4"><th>AP ID</th><th>Row</th><th>SSID</th><th>Mac Address</th><th>Authentication</th><th>Encryption</th><th>Radio</th><th>Channel</th></tr>
		<?php
		include('config.inc.php');
		mysql_select_db($db,$conn);
		$sql = "SELECT * FROM `users` WHERE `username`='$user'";
		$re = mysql_query($sql, $conn) or die(mysql_error());
		while($user_array = mysql_fetch_array($re))
		{
			$explode = explode("-",$user_array["points"]);
			foreach($explode as $explo)
			{
				$exp = explode(",",$explo);
				$flag = $exp[0];
				$ap_exp = explode(":",$exp[1]);
				$aps[] = array(
								"flag"=>$flag,
								"apid"=>$ap_exp[0],
								"row"=>$ap_exp[1]
								);
			}
		}
		foreach($aps as $ap)
		{
			if($ap['flag'] == "1"){continue;}
			$apid = $ap['apid'];
			$row = $ap['row'];
			
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
				echo $apid;
				?>
				</td><td align="center">
				<?php
				echo $row;
				?>
				</td><td align="center"><a class="links" href="fetch.php?id=<?php echo $apid;?>"><?php echo $ssid;?></a></td>
				<td>
				<?php echo $mac;?></td><td align="center">
				<?php echo $auth;?></td><td align="center">
				<?php echo $encry;?></td><td align="center">
				<?php echo $radio;?></td><td align="center">
				<?php echo $chan;?></td></tr>
				<?php
			}
		}
		echo "</table><br>";
		$end = microtime(true);
				if ($GLOBALS["bench"]  == 1)
				{
					echo "Time is [Unix Epoc]<BR>";
					echo "Start Time: ".$start."<BR>";
					echo "  End Time: ".$end."<BR>";
				}
	}
	
	#========================================================================================================================#
	#													Grab all user Import lists											 #
	#========================================================================================================================#

	function users_lists($user="")
	{
		$start = microtime(true);
		include('config.inc.php');
		echo '<h1>Import Lists For: <a class="links" href ="../opt/userstats.php?func=allap&user='.$user.'">'.$user.'</a></h1>';		
		echo '<h3>View All Users <a class="links" href="userstats.php?func=allusers">Here</a></h3>';
		echo '<h3>View all Access Points for user: <a class="links" href="../opt/userstats.php?func=allap&user='.$user.'">'.$user.'</a>';
		echo '<h2><a class="links" href=../opt/export.php?func=exp_user_all_kml&user='.$user.'>Export To KML File</a></h2>';
		echo '<table border="1"><tr class="style4"><th>ID</th><th>Title</th><th># of APs</th><th>Imported on</th></tr><tr>';
		mysql_select_db($db,$conn);
		$sql = "SELECT * FROM `users` WHERE `username` = '$user'";
		$result = mysql_query($sql, $conn) or die(mysql_error());
		while($user_array = mysql_fetch_array($result))
		{
			if($user_array['title']==''){$title = "Untitled";}else{$title = $user_array['title'];}
			$points = explode('-',$user_array['points']);
			$total = count($points);
			echo '<tr><td align="center">'.$user_array["id"].'</td><td align="center"><a class="links" href="../opt/userstats.php?func=useraplist&row='.$user_array["id"].'">'.$title.'</a></td><td align="center">'.$total.'</td><td align="center">'.$user_array["date"].'</td></tr>';
			
		}
		echo "</table><br>";
		$end = microtime(true);
				if ($GLOBALS["bench"]  == 1)
				{
					echo "Time is [Unix Epoc]<BR>";
					echo "Start Time: ".$start."<BR>";
					echo "  End Time: ".$end."<BR>";
				}
	}
	
	#========================================================================================================================#
	#													Grab the AP's for a given user's Import								 #
	#========================================================================================================================#

	function user_ap_list($row=0)
	{
		$start = microtime(true);
		include('config.inc.php');
		$pagerow =0;
		mysql_select_db($db,$conn);
		$sql = "SELECT * FROM `users` WHERE `id`='$row'";
		$result = mysql_query($sql, $conn) or die(mysql_error());
		$user_array = mysql_fetch_array($result);
		$aps=explode("-",$user_array["points"]);
		echo '<h1>Access Points For: <a class="links" href ="../opt/userstats.php?func=allap&user='.$user_array["username"].'">'.$user_array["username"].'</a></h1><h2>With Title: '.$user_array["title"].'</h2><h2>Imported On: '.$user_array["date"].'</h2>';
		?>
		<h3>View All Users <a class="links" href="userstats.php?func=allusers">Here</a></h3>
		<?php
		echo '<a class="links" href=../opt/export.php?func=exp_user_list&row='.$user_array["id"].'>Export To KML File</a>';
		echo '<table border="1"><tr class="style4"><th>New/Update</th><th>AP ID</th><th>Row</th><th>SSID</th><th>Mac Address</th><th>Authentication</th><th>Encryption</th><th>Radio</th><th>Channel</th></tr><tr>';
		foreach($aps as $ap)
		{
			#$pagerow++;
			$ap_exp = explode("," , $ap);
			if($ap_exp[0]==0){$flag = "N";}else{$flag = "U";}
			
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
			    echo '<tr><td align="center">'.$flag.'</td><td align="center">'.$apid.'</td><td align="center">'.$row.'</td><td align="center"><a class="links" href="fetch.php?id='.$apid.'">'.$ssid.'</a></td>';
			    echo '<td align="center">'.$mac.'</td>';
			    echo '<td align="center">'.$auth.'</td>';
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
				echo '<td align="center">'.$encry.'</td>';
				echo '<td align="center">'.$radio.'</td>';
				echo '<td align="center">'.$chan.'</td></tr>';
			}
		}
		echo "</table><br>";
		$end = microtime(true);
				if ($GLOBALS["bench"]  == 1)
				{
					echo "Time is [Unix Epoc]<BR>";
					echo "Start Time: ".$start."<BR>";
					echo "  End Time: ".$end."<BR>";
				}
	}
	
	
	#========================================================================================================================#
	#													Export to Google KML File											 #
	#========================================================================================================================#

	function exp_kml($export = "", $user = "", $row = 0)
	{
		include('config.inc.php');
		include('manufactures.inc.php');
		switch ($export)
		{
			case "exp_all_db_kml":
				$start = microtime(true);
				echo '<table style="border-style: solid; border-width: 1px"><tr class="style4"><th colspan="2" style="border-style: solid; border-width: 1px">Start of WiFi DB export to KML</th></tr>';
				mysql_select_db($db,$conn) or die("Unable to select Database:".$db);
				$sql = "SELECT * FROM `$wtable`";
				$result = mysql_query($sql, $conn) or die(mysql_error($conn));
				$total = mysql_num_rows($result);
				$date=date('Y-m-d_H-i-s');
				$file_ext = $date."_full_databse.kml";
				$filename = ($kml_out.$file_ext);
				// define initial write and appends
				$filewrite = fopen($filename, "w");
				$fileappend = fopen($filename, "a");
				// open file and write header:
				fwrite($fileappend, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n	<kml xmlns=\"$KML_SOURCE_URL\">\r\n		<Document>\r\n			<name>RanInt WifiDB KML</name>\r\n");
				fwrite($fileappend, "			<Style id=\"openStyleDead\">\r\n		<IconStyle>\r\n				<scale>0.5</scale>\r\n				<Icon>\r\n			<href>".$open_loc."</href>\r\n			</Icon>\r\n			</IconStyle>\r\n			</Style>\r\n");
				fwrite($fileappend, "<Style id=\"wepStyleDead\">\r\n<IconStyle>\r\n<scale>0.5</scale>\r\n<Icon>\r\n<href>".$WEP_loc."</href>\r\n</Icon>\r\n</IconStyle>\r\n</Style>\r\n");
				fwrite($fileappend, "<Style id=\"secureStyleDead\">\r\n<IconStyle>\r\n<scale>0.5</scale>\r\n<Icon>\r\n<href>".$WPA_loc."</href>\r\n</Icon>\r\n</IconStyle>\r\n</Style>\r\n");
				fwrite($fileappend, '<Style id="Location"><LineStyle><color>7f0000ff</color><width>4</width></LineStyle></Style>');
				echo '<tr><td style="border-style: solid; border-width: 1px" colspan="2">Wrote Header to KML File</td><td></td></tr>';
				$x=0;
				$n=0;
				$NN=0;
				fwrite( $fileappend, "<Folder>\r\n<name>Access Points</name>\r\n<description>APs: ".$total."</description>\r\n");
				fwrite( $fileappend, "<Folder>\r\n<name>WiFiDB Access Points</name>\r\n");
				echo '<tr><td colspan="2" style="border-style: solid; border-width: 1px">Wrote KML Folder Header</td></tr>';
				while($ap_array = mysql_fetch_array($result))
				{
					$man 		= database::manufactures($ap_array['mac']);
					$id			= $ap_array['id'];
					$ssid		= $ap_array['ssid'];
					$mac		= $ap_array['mac'];
					$sectype	= $ap_array['sectype'];
					$radio		= $ap_array['radio'];
					$chan		= $ap_array['chan'];
					
					$table = $ssid.'-'.$mac.'-'.$sectype.'-'.$radio.'-'.$chan;
					$table_gps = $table.$gps_ext;
					$ssid = smart_quotes($ssid);
					mysql_select_db($db_st,$conn) or die("Unable to select Database:".$db);
		#			echo $table."<br>";
					$sql1 = "SELECT * FROM `$table`";
					$result1 = mysql_query($sql1, $conn) or die(mysql_error($conn));
					$rows = mysql_num_rows($result1);
		#			echo $rows."<br>";
					$sql = "SELECT * FROM `$table` WHERE `id`='1'";
		#			echo $ap['mac']."<BR>";
		#			while (
					$newArray = mysql_fetch_array($result1);
		#			){
						switch($sectype)
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
						switch($radio)
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
						
						$sql_1 = "SELECT * FROM `$table_gps`";
						$result_1 = mysql_query($sql_1, $conn);
						$zero = 0;
						while($gps_table_first = mysql_fetch_array($result_1))
						{
							$lat_exp = explode(" ", $gps_table_first['lat']);
							
							$test = $lat_exp[1]+0;
							
							if($test == "0.0000"){$zero = 1; continue;}
							
							$date_first = $gps_table_first["date"];
							$time_first = $gps_table_first["time"];
							$fa   = $date_first." ".$time_first;
							$alt  = $gps_table_first['alt'];
							$lat  =& database::convert_dm_dd($gps_table_first['lat']);
							$long =& database::convert_dm_dd($gps_table_first['long']);
							$zero = 0;
							$NN++;
							break;
						}
						if($zero == 1){echo '<tr><td colspan="2" style="border-style: solid; border-width: 1px">No GPS Data, Skipping Access Point: '.$ssid.'</td></tr>'; $zero == 0; continue;}
						//=====================================================================================================//
						
						$sql_2 = "SELECT * FROM `$table_gps` WHERE `id`='$max'";
						$result_2 = mysql_query($sql_2, $conn);
						$gps_table_last = mysql_fetch_array($result_2);
						$date_last = $gps_table_last["date"];
						$time_last = $gps_table_last["time"];
						$la = $date_last." ".$time_last;
						fwrite( $fileappend, "<Placemark id=\"".$mac."\">\r\n	<name>".$ssid."</name>\r\n	<description><![CDATA[<b>SSID: </b>".$ssid."<br /><b>Mac Address: </b>".$mac."<br /><b>Network Type: </b>".$nt."<br /><b>Radio Type: </b>".$radio."<br /><b>Channel: </b>".$ap['chan']."<br /><b>Authentication: </b>".$auth."<br /><b>Encryption: </b>".$encry."<br /><b>Basic Transfer Rates: </b>".$btx."<br /><b>Other Transfer Rates: </b>".$otx."<br /><b>First Active: </b>".$fa."<br /><b>Last Updated: </b>".$la."<br /><b>Latitude: </b>".$lat."<br /><b>Longitude: </b>".$long."<br /><b>Manufacturer: </b>".$manuf."<br /><a href=\"".$hosturl."/".$root."/opt/fetch.php?id=".$id."\">WiFiDB Link</a>]]></description>\r\n	<styleUrl>".$type."</styleUrl>\r\n<Point id=\"".$mac."_GPS\">\r\n<coordinates>".$long.",".$lat.",".$alt."</coordinates>\r\n</Point>\r\n</Placemark>\r\n");
						echo '<tr><td style="border-style: solid; border-width: 1px">'.$NN.'<td style="border-style: solid; border-width: 1px">Wrote AP: '.$ssid.'</td></tr>';
						unset($lat);
						unset($long);
						unset($gps_table_first["lat"]);
						unset($gps_table_first["long"]);
#					}
				}
				fwrite( $fileappend, "	</Folder>\r\n");
				fwrite( $fileappend, "	</Folder>\r\n	</Document>\r\n</kml>");
				fclose( $fileappend );
				echo '<tr class="style4"><td colspan="2" style="border-style: solid; border-width: 1px">Your Google Earth KML file is ready,<BR>you can download it from <a class="links" href="'.$filename.'">Here</a></td></tr></table>';
				mysql_close($conn);
				$end = microtime(true);
				if ($GLOBALS["bench"]  == 1)
				{
					echo "Time is [Unix Epoc]<BR>";
					echo "Start Time: ".$start."<BR>";
					echo "  End Time: ".$end."<BR>";
				}
				break;
			#---------------------#
			#---------------------#
			case "exp_user_list":
				$start = microtime(true);
				echo '<table style="border-style: solid; border-width: 1px"><tr class="style4"><th style="border-style: solid; border-width: 1px" colspan="2">Start of export Users List to KML</th></tr>';
				if($row == 0)
				{
					$sql_row = "SELECT * FROM `users` ORDER BY `id` DESC";
					$result_row = mysql_query($sql_row, $conn) or die(mysql_error());
					$row_array = mysql_fetch_array($result_row);
					$row = $row_array['id'];
				}
				mysql_select_db($db,$conn) or die("Unable to select Database:".$db);
				$sql = "SELECT * FROM `users` WHERE `id`='$row'";
				$result = mysql_query($sql, $conn) or die(mysql_error());
				$user_array = mysql_fetch_array($result);
				
				$aps = explode("-" , $user_array["points"]);
				
				$date=date('Y-m-d_H-i-s');
				
				if ($user_array["title"]==""){$title = "UNTITLED";}else{$title=$user_array["title"];}
				if ($user_array["username"]==""){$user = "Uknnown";}else{$user=$user_array["username"];}
				echo '<tr class="style4"><td colspan="2" align="center" style="border-style: solid; border-width: 1px">Username: '.$user.'</td></tr>'
					.'<tr class="style4"><td colspan="2" align="center" style="border-style: solid; border-width: 1px">Title: '.$title.'</td></tr>';
				$file_ext = $title.'-'.$date.'.kml';
				$filename = ($kml_out.$file_ext);
				// define initial write and appends
				$filewrite = fopen($filename, "w");
				$fileappend = fopen($filename, "a");
				// open file and write header:
				fwrite($fileappend, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n	<kml xmlns=\"$KML_SOURCE_URL\">\r\n		<Document>\r\n			<name>User: ".$user." - Title: ".$title."</name>\r\n");
				fwrite($fileappend, "			<Style id=\"openStyleDead\">\r\n		<IconStyle>\r\n				<scale>0.5</scale>\r\n				<Icon>\r\n			<href>".$open_loc."</href>\r\n			</Icon>\r\n			</IconStyle>\r\n			</Style>\r\n");
				fwrite($fileappend, "<Style id=\"wepStyleDead\">\r\n<IconStyle>\r\n<scale>0.5</scale>\r\n<Icon>\r\n<href>".$WEP_loc."</href>\r\n</Icon>\r\n</IconStyle>\r\n</Style>\r\n");
				fwrite($fileappend, "<Style id=\"secureStyleDead\">\r\n<IconStyle>\r\n<scale>0.5</scale>\r\n<Icon>\r\n<href>".$WPA_loc."</href>\r\n</Icon>\r\n</IconStyle>\r\n</Style>\r\n");
				fwrite($fileappend, '<Style id="Location"><LineStyle><color>7f0000ff</color><width>4</width></LineStyle></Style>');
				echo '<tr><td colspan="2" style="border-style: solid; border-width: 1px">Wrote Header to KML File</td><td></td></tr>';
				$x=0;
				$n=0;
				$total = count($aps);
				fwrite( $fileappend, "<Folder>\r\n<name>Access Points</name>\r\n<description>APs: ".$total."</description>\r\n");
				fwrite( $fileappend, "<Folder>\r\n<name>".$title." Access Points</name>\r\n");
				echo '<tr><td colspan="2" style="border-style: solid; border-width: 1px">Wrote KML Folder Header</td></tr>';
				$NN=0;
				foreach($aps as $ap)
				{
					$ap_exp = explode("," , $ap);
					$apid_exp = explode(":",$ap_exp[1]);
					if($ap_exp[0] == 1){continue;}
					$apid = $apid_exp[0];
					$update_row = $apid_exp[1];
					$udflag = $ap_exp[0];
					
					mysql_select_db($db,$conn) or die("Unable to select Database:".$db);
					$sql0 = "SELECT * FROM `$wtable` WHERE `id`='$apid'";
					$result0 = mysql_query($sql0, $conn) or die(mysql_error());
					$newArray = mysql_fetch_array($result0);
					
					$id = $newArray['id'];
					$ssid = smart_quotes($newArray['ssid']);
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
							$encry = "TIKP";
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
					
					$table=$newArray['ssid'].'-'.$mac.'-'.$sectype.'-'.$r.'-'.$chan;
					mysql_select_db($db_st) or die("Unable to select Database: ".$db_st);
					
					$sql = "SELECT * FROM `$table` WHERE `id`='$update_row'";
					$result = mysql_query($sql, $conn);
					$AP_table = mysql_fetch_array($result);
					$otx = $AP_table["otx"];
					$btx = $AP_table["btx"];
					$nt = $AP_table['nt'];
					$label = $AP_table['label'];
					$table_gps = $table.$gps_ext;
					
					$sql6 = "SELECT * FROM `$table_gps`";
					$result6 = mysql_query($sql6, $conn);
					$max = mysql_num_rows($result6);
					
					$sql = "SELECT * FROM `$table_gps`";
					$result = mysql_query($sql, $conn);
					while($gps_table_first = mysql_fetch_array($result))
					{
						$lat_exp = explode(" ", $gps_table_first['lat']);
						
						$test = $lat_exp[1]+0;
						
						if($test == "0.0000"){$zero = 1; continue;}
						
						$date_first = $gps_table_first["date"];
						$time_first = $gps_table_first["time"];
						$fa = $date_first." ".$time_first;
						$alt = $gps_table_first['alt'];
						$lat =& database::convert_dm_dd($gps_table_first['lat']);
						$long =& database::convert_dm_dd($gps_table_first['long']);
						$zero = 0;
						$NN++;
						break;
					}
					if($zero == 1){echo '<tr><td colspan="2" style="border-style: solid; border-width: 1px">No GPS Data, Skipping Access Point: '.$ssid.'</td></tr>'; $zero == 0; continue;}
					
					$sql_1 = "SELECT * FROM `$table_gps` WHERE `id`='$max'";
					$result_1 = mysql_query($sql_1, $conn);
					$gps_table_last = mysql_fetch_array($result_1);
					$date_last = $gps_table_last["date"];
					$time_last = $gps_table_last["time"];
					$la = $date_last." ".$time_last;
					fwrite( $fileappend, "<Placemark id=\"".$mac."\">\r\n	<name>".$ssid."</name>\r\n	<description><![CDATA[<b>SSID: </b>".$ssid."<br /><b>Mac Address: </b>".$mac."<br /><b>Network Type: </b>".$nt."<br /><b>Radio Type: </b>".$radio."<br /><b>Channel: </b>".$chan."<br /><b>Authentication: </b>".$auth."<br /><b>Encryption: </b>".$encry."<br /><b>Basic Transfer Rates: </b>".$btx."<br /><b>Other Transfer Rates: </b>".$otx."<br /><b>First Active: </b>".$fa."<br /><b>Last Updated: </b>".$la."<br /><b>Latitude: </b>".$lat."<br /><b>Longitude: </b>".$long."<br /><b>Manufacturer: </b>".$man."<br /><a href=\"<a href=\"".$hosturl."/".$root."/opt/fetch.php?id=".$id."\">WiFiDB Link</a>]]></description>\r\n	<styleUrl>".$type."</styleUrl>\r\n	");
					fwrite( $fileappend, "<Point id=\"".$mac."_GPS\">\r\n<coordinates>".$long.",".$lat.",".$alt."</coordinates>\r\n</Point>\r\n</Placemark>\r\n");
					echo '<tr><td style="border-style: solid; border-width: 1px">'.$NN.'</td><td style="border-style: solid; border-width: 1px">Wrote AP: '.$ssid.'</td></tr>';
					unset($gps_table_first["lat"]);
					unset($gps_table_first["long"]);
					
				}
				fwrite( $fileappend, "	</Folder>\r\n");
				fwrite( $fileappend, "	</Folder>\r\n	</Document>\r\n</kml>");
				fclose( $fileappend );
				echo '<tr class="style4"><td colspan="2" style="border-style: solid; border-width: 1px">Your Google Earth KML file is ready,<BR>you can download it from <a class="links" href="'.$filename.'">Here</a></td></tr></table>';
				mysql_close($conn);
				$end = microtime(true);
				if ($GLOBALS["bench"]  == 1)
				{
					echo "Time is [Unix Epoc]<BR>";
					echo "Start Time: ".$start."<BR>";
					echo "  End Time: ".$end."<BR>";
				}
				break;
			#--------------------#
			#--------------------#
			case "exp_single_ap":
				$start = microtime(true);
				$NN=0;
				$date=date('Y-m-d_H-i-s');
				$sql = "SELECT * FROM `$wtable` WHERE `ID`='$row'";
				$result = mysql_query($sql, $conn) or die(mysql_error());
				$aparray = mysql_fetch_array($result);
				
				$file_ext = $aparray['ssid']."-".$aparray['mac']."-".$aparray['sectype']."-".$date.".kml";
				echo '<table style="border-style: solid; border-width: 1px"><tr class="style4"><th style="border-style: solid; border-width: 1px">Start export of Single AP: '.$aparray["ssid"].'</th></tr>';
				$filename = ($kml_out.$file_ext);
				// define initial write and appends
				$filewrite = fopen($filename, "w");
				if($filewrite != FALSE)
				{
					$file_data  = ("");
					$file_data .= ("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n<kml xmlns=\"$KML_SOURCE_URL\">\r\n<Document>\r\n<name>RanInt WifiDB KML</name>\r\n");
					$file_data .= ("<Style id=\"openStyleDead\">\r\n<IconStyle>\r\n<scale>0.5</scale>\r\n<Icon>\r\n<href>http://www.vistumbler.net/images/program-images/open.png</href>\r\n</Icon>\r\n</IconStyle>\r\n</Style>\r\n");
					$file_data .= ("<Style id=\"wepStyleDead\">\r\n<IconStyle>\r\n<scale>0.5</scale>\r\n<Icon>\r\n<href>http://www.vistumbler.net/images/program-images/secure-wep.png</href>\r\n</Icon>\r\n</IconStyle>\r\n</Style>\r\n");
					$file_data .= ("<Style id=\"secureStyleDead\">\r\n<IconStyle>\r\n<scale>0.5</scale>\r\n<Icon>\r\n<href>http://www.vistumbler.net/images/program-images/secure.png</href>\r\n</Icon>\r\n</IconStyle>\r\n</Style>\r\n");
					$file_data .= ('<Style id="Location"><LineStyle><color>7f0000ff</color><width>4</width></LineStyle></Style>');
					echo '<tr><td style="border-style: solid; border-width: 1px">Wrote Header to KML File</td><td></td></tr>';
					// open file and write header:
					
					$manuf =& database::manufactures($aparray['mac']);
					$ssid = smart_quotes($aparray['ssid']);
					$table=$aparray['ssid'].'-'.$aparray['mac'].'-'.$aparray['sectype'].'-'.$aparray['radio'].'-'.$aparray['chan'];
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
						switch($aparray['sectype'])
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
						
						switch($aparray['radio'])
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
						
						$sql_1 = "SELECT * FROM `$table_gps`";
						$result_1 = mysql_query($sql_1, $conn);
						while($gps_table_first = mysql_fetch_array($result_1))
						{
							$lat_exp = explode(" ", $gps_table_first['lat']);
							
							$test = $lat_exp[1]+0;
							
							if($test == "0.0000"){$zero = 1; continue;}
							
							$date_first = $gps_table_first["date"];
							$time_first = $gps_table_first["time"];
							$fa = $date_first." ".$time_first;
							$alt = $gps_table_first['alt'];
							$lat =& database::convert_dm_dd($gps_table_first['lat']);
							$long =& database::convert_dm_dd($gps_table_first['long']);
							$zero = 0;
							$NN++;
							break;
						}
						if($zero == 1){echo '<tr><td style="border-style: solid; border-width: 1px">No GPS Data, Skipping Access Point: '.$ssid.'</td></tr>'; $zero == 0; continue;}
						
						$sql_2 = "SELECT * FROM `$table_gps` WHERE `id`='$max'";
						$result_2 = mysql_query($sql_2, $conn);
						$gps_table_last = mysql_fetch_array($result_2);
						$date_last = $gps_table_last["date"];
						$time_last = $gps_table_last["time"];
						$la = $date_last." ".$time_last;
						$file_data .= ("<Placemark id=\"".$aparray['mac']."\">\r\n	<name>".$ssid."</name>\r\n	<description><![CDATA[<b>SSID: </b>".$ssid."<br /><b>Mac Address: </b>".$aparray['mac']."<br /><b>Network Type: </b>".$nt."<br /><b>Radio Type: </b>".$radio."<br /><b>Channel: </b>".$aparray['chan']."<br /><b>Authentication: </b>".$aparray['auth']."<br /><b>Encryption: </b>".$aparray['encry']."<br /><b>Basic Transfer Rates: </b>".$btx."<br /><b>Other Transfer Rates: </b>".$otx."<br /><b>First Active: </b>".$fa."<br /><b>Last Updated: </b>".$la."<br /><b>Latitude: </b>".$lat."<br /><b>Longitude: </b>".$long."<br /><b>Manufacturer: </b>".$manuf."<br /><a href=\"".$hosturl."/".$root."/opt/fetch.php?id=".$aparray['id']."\">WiFiDB Link</a>]]></description>\r\n	<styleUrl>".$type."</styleUrl>\r\n<Point id=\"".$aparray['mac']."_GPS\">\r\n<coordinates>".$long.",".$lat.",".$alt."</coordinates>\r\n</Point>\r\n</Placemark>\r\n");
						echo '<tr><td style="border-style: solid; border-width: 1px">Wrote AP: '.$ssid.'</td></tr>';
					}
				}else
				{
					echo "Failed to write KML File, Check the permissions on the wifidb folder, and make sure that Apache (or what ever HTTP server you are using) has permissions to write";
				}
				$fileappend = fopen($filename, "a");
				fwrite($fileappend, $file_data);
				fwrite( $fileappend, "	</Document>\r\n</kml>");
				
				fclose( $fileappend );
				echo '<tr class="style4"><td style="border-style: solid; border-width: 1px">Your Google Earth KML file is ready,<BR>you can download it from <a class="links" href="'.$filename.'">Here</a></td></tr></table>';
				mysql_close($conn);
				$end = microtime(true);
				if ($GLOBALS["bench"]  == 1)
				{
					echo "Time is [Unix Epoc]<BR>";
					echo "Start Time: ".$start."<BR>";
					echo "  End Time: ".$end."<BR>";
				}
				break;
			#----------------------#
			#----------------------#
			case "exp_user_all_kml":
				include('config.inc.php');
				$start = microtime(true);
				mysql_select_db($db,$conn) or die("Unable to select Database:".$db);
				echo '<table style="border-style: solid; border-width: 1px"><tr class="style4"><th style="border-style: solid; border-width: 1px" colspan="2">Start export of all APs for User: '.$user.', to KML</th></tr>';
				$ap_id = array();
				$sql = "SELECT `points` FROM `users` WHERE `username`='$user'";
				$result = mysql_query($sql, $conn);
				while($points = mysql_fetch_array($result))
				{
					$points_exp = explode("-",$points['points']);
					foreach($points_exp as $point)
					{
						$points2 = explode(",", $point);
						if($points2[0] == 1){continue;}
						$point_ = explode(":", $points2[1]);
						$ap_id[] = array(
											'id'	=> $point_[0],
											'row'	=> $point_[1]
										  );
					}
				}
				#var_dump($ap_id);
				$date=date('Y-m-d_H-i-s');
				
				$file_ext = $date."_".$user."_all_AP.kml";
				$filename = ($kml_out.$file_ext);
				// define initial write and appends
				$filewrite = fopen($filename, "w");
				$fileappend = fopen($filename, "a");
				// open file and write header:
				$total = count($ap_id);
				fwrite($fileappend, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n	<kml xmlns=\"".$KML_SOURCE_URL."\">\r\n<Document>\r\n<name>RanInt WifiDB KML</name>\r\n");
				fwrite($fileappend, "<Style id=\"openStyleDead\">\r\n<IconStyle>\r\n<scale>0.5</scale>\r\n<Icon>\r\n<href>".$open_loc."</href>\r\n</Icon>\r\n</IconStyle>\r\n</Style>\r\n");
				fwrite($fileappend, "<Style id=\"wepStyleDead\">\r\n<IconStyle>\r\n<scale>0.5</scale>\r\n<Icon>\r\n<href>".$WEP_loc."</href>\r\n</Icon>\r\n</IconStyle>\r\n</Style>\r\n");
				fwrite($fileappend, "<Style id=\"secureStyleDead\">\r\n<IconStyle>\r\n<scale>0.5</scale>\r\n<Icon>\r\n<href>".$WPA_loc."</href>\r\n</Icon>\r\n</IconStyle>\r\n</Style>\r\n");
				fwrite($fileappend, '<Style id="Location"><LineStyle><color>7f0000ff</color><width>4</width></LineStyle></Style>');
				fwrite( $fileappend, "<Folder>\r\n<name>WiFiDB Access Points</name>\r\n<description>Total Number of APs: ".$total."</description>\r\n");
				fwrite( $fileappend, "<Folder>\r\n<name>Access Points for User: ".$user."</name>\r\n");
				echo '<tr><td colspan="2" style="border-style: solid; border-width: 1px">Wrote Header to KML File</td></tr>';
				$NN = 0;
				foreach($ap_id as $ap)
				{
					mysql_select_db($db,$conn) or die("Unable to select Database:".$db);
					$id = $ap['id'];
					$rows = $ap['row'];
					
					$sql = "SELECT * FROM `$wtable` WHERE `id`='$id'";
					$result = mysql_query($sql, $conn);
					$aps = mysql_fetch_array($result);
					
					$ssid = smart_quotes($aps['ssid']);
					$mac = $aps['mac'];
					$sectype = $aps['sectype'];
					$r = $aps['radio'];
					$chan = $aps['chan'];
					$manuf =& database::manufactures($mac);
					
					$table = $aps['ssid'].'-'.$mac.'-'.$sectype.'-'.$r.'-'.$chan;
					$table_gps = $table.$gps_ext;
					
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
							case "u":
								$radio="802.11u";
								break;
							default:
							$radio="Unknown Radio";
								break;
						}
					switch($sectype)
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
					mysql_select_db($db_st,$conn) or die("Unable to select Database:".$db_st);
					$sql = "SELECT * FROM `$table` WHERE `id`='$rows'";
					$result1 = mysql_query($sql, $conn) or die(mysql_error());
					
					while ($newArray = mysql_fetch_array($result1))
					{
						$otx = $newArray["otx"];
						$btx = $newArray["btx"];
						$nt = $newArray['nt'];
						$label = $newArray['label'];
						
						$signal_exp = explode("-", $newArray['sig']);
						$sig_count = count($signal_exp);
						
						$exp_first = explode("," , $signal_exp[0]);
						$first_sig_gps_id = $exp_first[1];
						
						$exp_last = explode("," , $signal_exp[$sig_count-1]);
						$last_sig_gps_id = $exp_last[1];
						
						$sql6 = "SELECT * FROM `$table_gps`";
						$result6 = mysql_query($sql6, $conn);
						$max = mysql_num_rows($result6);
						
						$sql_1 = "SELECT * FROM `$table_gps`";
						$result_1 = mysql_query($sql_1, $conn);
						$zero = 0;
						while($gps_table_first = mysql_fetch_array($result_1))
						{
							$lat_exp = explode(" ", $gps_table_first['lat']);
							$date_first = $gps_table_first["date"];
							$time_first = $gps_table_first["time"];
							$fa = $date_first." ".$time_first;
							$test = $lat_exp[1]+0;
							
							if($test == "0.0000"){$zero = 1; continue;}
							
							
							$alt = $gps_table_first['alt'];
							$lat =& database::convert_dm_dd($gps_table_first['lat']);
							$long =& database::convert_dm_dd($gps_table_first['long']);
							$zero = 0;
							$NN++;
							break;
						}
						if($zero == 1){echo '<tr><td colspan="2" style="border-style: solid; border-width: 1px">No GPS Data, Skipping Access Point: '.$ssid.'</td></tr>'; $zero == 0; continue;}
						
						$sql_2 = "SELECT * FROM `$table_gps` WHERE `id`='$last_sig_gps_id'";
						$result_2 = mysql_query($sql_2, $conn);
						$gps_table_last = mysql_fetch_array($result_2);
						$date_last = $gps_table_last["date"];
						$time_last = $gps_table_last["time"];
						$la = $date_last." ".$time_last;
						fwrite( $fileappend, "<Placemark id=\"".$mac."\">\r\n	<name>".$ssid."</name>\r\n	<description><![CDATA[<b>SSID: </b>".$ssid."<br /><b>Mac Address: </b>".$mac."<br /><b>Network Type: </b>".$nt."<br /><b>Radio Type: </b>".$radio."<br /><b>Channel: </b>".$chan."<br /><b>Authentication: </b>".$auth."<br /><b>Encryption: </b>".$encry."<br /><b>Basic Transfer Rates: </b>".$btx."<br /><b>Other Transfer Rates: </b>".$otx."<br /><b>First Active: </b>".$fa."<br /><b>Last Updated: </b>".$la."<br /><b>Latitude: </b>".$lat."<br /><b>Longitude: </b>".$long."<br /><b>Manufacturer: </b>".$manuf."<br /><a href=\"".$hosturl."/".$root."/opt/fetch.php?id=".$id."\">WiFiDB Link</a>]]></description>\r\n	<styleUrl>".$type."</styleUrl>\r\n<Point id=\"".$mac."_GPS\">\r\n<coordinates>".$long.",".$lat.",".$alt."</coordinates>\r\n</Point>\r\n</Placemark>\r\n");
						echo '<tr><td style="border-style: solid; border-width: 1px">'.$NN.'</td><td style="border-style: solid; border-width: 1px">Wrote AP: '.$ssid.'</td></tr>';
						
						unset($gps_table_first["lat"]);
						unset($gps_table_first["long"]);
					}
				}
				fwrite( $fileappend, "	</Folder>\r\n");
				fwrite( $fileappend, "	</Folder>\r\n	</Document>\r\n</kml>");
				fclose( $fileappend );
				echo '<tr class="style4"><td colspan="2" style="border-style: solid; border-width: 1px">Your Google Earth KML file is ready,<BR>you can download it from <a class="links" href="'.$filename.'">Here</a></td></tr></table>';
				mysql_close($conn);
				$end = microtime(true);
				if ($GLOBALS["bench"]  == 1)
				{
					echo "Time is [Unix Epoc]<BR>";
					echo "Start Time: ".$start."<BR>";
					echo "  End Time: ".$end."<BR>";
				}
				break;
			#--------------------#
			#--------------------#
			case "exp_newest_kml":
				$date=date('Y-m-d_H-i-s');
				$start = microtime(true);
				$sql = "SELECT * FROM `$wtable`";
				$result = mysql_query($sql, $conn) or die(mysql_error());
				$rows = mysql_num_rows($result);
				
				$sql = "SELECT * FROM `$wtable` WHERE `id`='$rows'";
				$result = mysql_query($sql, $conn) or die(mysql_error());
				$ap_array = mysql_fetch_array($result);
				$manuf =& database::manufactures($ap_array['mac']);
				$file_ext = "Newest_AP_".$date.".kml";
				echo '<table style="border-style: solid; border-width: 1px"><tr class="style4"><th style="border-style: solid; border-width: 1px">Start export of Newest AP: '.$ap_array["ssid"].'</th></tr>';
				$filename = ($kml_out.$file_ext);
				// define initial write and appends
				$filewrite = fopen($filename, "w");
				if($filewrite != FALSE)
				{
					$file_data  = ("");
					$file_data .= ("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n<kml xmlns=\"$KML_SOURCE_URL\">\r\n<Document>\r\n<name>RanInt WifiDB KML</name>\r\n");
					$file_data .= ("<Style id=\"openStyleDead\">\r\n<IconStyle>\r\n<scale>0.5</scale>\r\n<Icon>\r\n<href>http://www.vistumbler.net/images/program-images/open.png</href>\r\n</Icon>\r\n</IconStyle>\r\n</Style>\r\n");
					$file_data .= ("<Style id=\"wepStyleDead\">\r\n<IconStyle>\r\n<scale>0.5</scale>\r\n<Icon>\r\n<href>http://www.vistumbler.net/images/program-images/secure-wep.png</href>\r\n</Icon>\r\n</IconStyle>\r\n</Style>\r\n");
					$file_data .= ("<Style id=\"secureStyleDead\">\r\n<IconStyle>\r\n<scale>0.5</scale>\r\n<Icon>\r\n<href>http://www.vistumbler.net/images/program-images/secure.png</href>\r\n</Icon>\r\n</IconStyle>\r\n</Style>\r\n");
					$file_data .= ('<Style id="Location"><LineStyle><color>7f0000ff</color><width>4</width></LineStyle></Style>');
					echo '<tr><td style="border-style: solid; border-width: 1px">Wrote Header to KML File</td></tr>';
					// open file and write header:
					
					$table=$ap_array['ssid'].'-'.$ap_array['mac'].'-'.$ap_array['sectype'].'-'.$ap_array['radio'].'-'.$ap_array['chan'];
					$table_gps = $table.$gps_ext;
					mysql_select_db($db_st,$conn) or die("Unable to select Database:".$db);
		#			echo $table."<br>";
					$sql = "SELECT * FROM `$table`";
					$result = mysql_query($sql, $conn) or die(mysql_error());
					$rows = mysql_num_rows($result);
		#			echo $rows."<br>";
					$sql = "SELECT * FROM `$table` WHERE `id`='1'";
					$result1 = mysql_query($sql, $conn) or die(mysql_error());
					$newArray = mysql_fetch_array($result1);
		#			echo $ap['mac']."<BR>";
					switch($ap_array['sectype'])
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
						
					switch($ap_array['radio'])
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
					
					$sql_1 = "SELECT * FROM `$table_gps`";
					$result_1 = mysql_query($sql_1, $conn);
					while($gps_table_first = mysql_fetch_array($result_1))
					{
						$lat_exp = explode(" ", $gps_table_first['lat']);
						
						$test = $lat_exp[1]+0;
						
						if($test == "0.0000"){$zero = 1; continue;}
						
						$date_first = $gps_table_first["date"];
						$time_first = $gps_table_first["time"];
						$fa = $date_first." ".$time_first;
						$alt = $gps_table_first['alt'];
						$lat =& database::convert_dm_dd($gps_table_first['lat']);
						$long =& database::convert_dm_dd($gps_table_first['long']);
						$zero = 0;
						break;
					}
					if($zero == 1){echo '<tr><td style="border-style: solid; border-width: 1px">No GPS Data, Skipping Access Point: '.$ap['ssid'].'</td></tr>'; $zero == 0; continue;}
					{
						?>
						<tr>
							<td style="border-style: solid; border-width: 1px">No GPS Data, Skipping Access Point:
							<?php
							echo $ap_array["ssid"];
							?>
							</td>
						</tr>
						<tr>
							<td style="border-style: solid; border-width: 1px">Your Google Earth KML file is not ready, 
																				There where no GPS cords to plot.</td>
							<td></td>
						</tr>
						</table>
						<?php
						$end = microtime(true);
						if ($GLOBALS["bench"]  == 1)
						{
							echo "Time is [HH:MM:SS.UU]<BR>";
							echo "Start Time: ".$start."<BR>";
							echo "  End Time: ".$end."<BR>";
						}
						continue;
					}
					
					$sql_2 = "SELECT * FROM `$table_gps` WHERE `id`='$max'";
					$result_2 = mysql_query($sql_2, $conn);
					$gps_table_last = mysql_fetch_array($result_2);
					$date_last = $gps_table_last["date"];
					$time_last = $gps_table_last["time"];
					$la = $date_last." ".$time_last;
					$file_data .= ("<Placemark id=\"".$ap_array['mac']."\">\r\n	<name>".$ap_array['ssid']."</name>\r\n	<description><![CDATA[<b>SSID: </b>".$ap_array['ssid']."<br /><b>Mac Address: </b>".$ap_array['mac']."<br /><b>Network Type: </b>".$nt."<br /><b>Radio Type: </b>".$radio."<br /><b>Channel: </b>".$ap_array['chan']."<br /><b>Authentication: </b>".$auth."<br /><b>Encryption: </b>".$encry."<br /><b>Basic Transfer Rates: </b>".$btx."<br /><b>Other Transfer Rates: </b>".$otx."<br /><b>First Active: </b>".$fa."<br /><b>Last Updated: </b>".$la."<br /><b>Latitude: </b>".$lat."<br /><b>Longitude: </b>".$long."<br /><b>Manufacturer: </b>".$manuf."<br /><a href=\"".$hosturl."/".$root."/opt/fetch.php?id=".$ap_array['id']."\">WiFiDB Link</a>]]></description>\r\n	<styleUrl>".$type."</styleUrl>\r\n<Point id=\"".$ap_array['mac']."_GPS\">\r\n<coordinates>".$long.",".$lat.",".$alt."</coordinates>\r\n</Point>\r\n</Placemark>\r\n");
					echo '<tr><td style="border-style: solid; border-width: 1px">Wrote AP: '.$ap_array['ssid'].'</td></tr>';
				}else
				{
					echo "Failed to write KML File, Check the permissions on the wifidb folder, and make sure that Apache (or what ever HTTP server you are using) has permissions to write";
				}
				$fileappend = fopen($filename, "a");
				fwrite($fileappend, $filedata);
				fclose( $fileappend );
				echo '<tr class="style4"><td style="border-style: solid; border-width: 1px" colspan="2">Your Google Earth KML file is ready,<BR>you can download it from <a class="links" href="'.$filename.'">Here</a></td></tr></table>';
				mysql_close($conn);
				$end = microtime(true);
				if ($GLOBALS["bench"]  == 1)
				{
					echo "Time is [Unix Epoc]<BR>";
					echo "Start Time: ".$start."<BR>";
					echo "  End Time: ".$end."<BR>";
				}
			case "exp_all_signal":
				$start = microtime(true);
				$NN=0;
				$signal_image ='';
				$row_id_exp = explode(",",$row);
				$id = $row_id_exp[1];
				$row = $row_id_exp[0];
				$date=date('Y-m-d_H-i-s');
				$sql = "SELECT * FROM `$wtable` WHERE `ID`='$id'";
				$result = mysql_query($sql, $conn) or die(mysql_error());
				$aparray = mysql_fetch_array($result);
				$ssid = smart_quotes($aparray['ssid']);
				$file_ext = $ssid."-".$aparray['mac']."-".$aparray['sectype']."-".$date.".kml";
				echo '<table style="border-style: solid; border-width: 1px"><tr class="style4"><th style="border-style: solid; border-width: 1px">Start export of Single AP: '.$ssid.'\'s Signal History</th></tr>';
				$filename = ($kml_out.$file_ext);
				// define initial write and appends
				$filewrite = fopen($filename, "w");
				if($filewrite != FALSE)
				{
					$table=$aparray['ssid'].'-'.$aparray['mac'].'-'.$aparray['sectype'].'-'.$aparray['radio'].'-'.$aparray['chan'];
					$table_gps = $table.$gps_ext;
					
					$file_data  = ("");
					$file_data .= ("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n<kml xmlns=\"".$KML_SOURCE_URL."\">\r\n<Document>\r\n<name>".$table."</name>\r\n");
					$file_data .= ("<Style id=\"openStyleDead\">\r\n<IconStyle>\r\n<scale>0.5</scale>\r\n<Icon>\r\n<href>http://www.vistumbler.net/images/program-images/open.png</href>\r\n</Icon>\r\n</IconStyle>\r\n</Style>\r\n");
					$file_data .= ("<Style id=\"wepStyleDead\">\r\n<IconStyle>\r\n<scale>0.5</scale>\r\n<Icon>\r\n<href>http://www.vistumbler.net/images/program-images/secure-wep.png</href>\r\n</Icon>\r\n</IconStyle>\r\n</Style>\r\n");
					$file_data .= ("<Style id=\"secureStyleDead\">\r\n<IconStyle>\r\n<scale>0.5</scale>\r\n<Icon>\r\n<href>http://www.vistumbler.net/images/program-images/secure.png</href>\r\n</Icon>\r\n</IconStyle>\r\n</Style>\r\n");
					$file_data .= ('<Style id="Location"><LineStyle><color>7f0000ff</color><width>4</width></LineStyle></Style>');
					echo '<tr><td style="border-style: solid; border-width: 1px">Wrote Header to KML File</td></tr>';
					// open file and write header:
					
					$manuf =& database::manufactures($aparray['mac']);
					mysql_select_db($db_st,$conn) or die("Unable to select Database:".$db);
		#			echo $table."<br>";
					$sql = "SELECT * FROM `$table`";
					$result = mysql_query($sql, $conn) or die(mysql_error());
					$rows = mysql_num_rows($result);
		#			echo $rows."<br>";
					$sql = "SELECT * FROM `$table` WHERE `id`='$row'";
					$result1 = mysql_query($sql, $conn) or die(mysql_error());
		#			echo $ap['mac']."<BR>";
					$newArray = mysql_fetch_array($result1);
					switch($aparray['sectype'])
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
					
					switch($aparray['radio'])
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
					
					$sql_1 = "SELECT * FROM `$table_gps`";
					$result_1 = mysql_query($sql_1, $conn);
					while($gps_table = mysql_fetch_array($result_1))
					{
						$lat_exp = explode(" ", $gps_table['lat']);
						$test = $lat_exp[1]+0;
						
						if($test == "0.0000"){$zero = 1; continue;}
						
						$date_first = $gps_table["date"];
						$time_first = $gps_table["time"];
						$fa = $date_first." ".$time_first;
						$alt = $gps_table['alt'];
						$lat =& database::convert_dm_dd($gps_table['lat']);
						$long =& database::convert_dm_dd($gps_table['long']);
						$zero = 0;
						$NN++;
						break;
					}
					if($zero == 1){echo '<tr><td style="border-style: solid; border-width: 1px">No GPS Data, Skipping Access Point: '.$ssid.'</td></tr>'; $zero == 0; continue;}
					
					$sql_2 = "SELECT * FROM `$table_gps` WHERE `id`='$max'";
					$result_2 = mysql_query($sql_2, $conn);
					$gps_table_last = mysql_fetch_array($result_2);
					$date_last = $gps_table_last["date"];
					$time_last = $gps_table_last["time"];
					
					$la = $date_last." ".$time_last;
					$file_data .= ("<Placemark id=\"".$aparray['mac']."\">\r\n	<name>".$ssid."</name>\r\n	<description><![CDATA[<b>SSID: </b>".$ssid."<br /><b>Mac Address: </b>".$aparray['mac']."<br /><b>Network Type: </b>".$nt."<br /><b>Radio Type: </b>".$radio."<br /><b>Channel: </b>".$aparray['chan']."<br /><b>Authentication: </b>".$aparray['auth']."<br /><b>Encryption: </b>".$aparray['encry']."<br /><b>Basic Transfer Rates: </b>".$btx."<br /><b>Other Transfer Rates: </b>".$otx."<br /><b>First Active: </b>".$fa."<br /><b>Last Updated: </b>".$la."<br /><b>Latitude: </b>".$lat."<br /><b>Longitude: </b>".$long."<br /><b>Manufacturer: </b>".$manuf."<br /><a href=\"".$hosturl."/".$root."/opt/fetch.php?id=".$aparray['id']."\">WiFiDB Link</a>]]></description>\r\n	<styleUrl>".$type."</styleUrl>\r\n<Point id=\"".$aparray['mac']."_GPS\">\r\n<coordinates>".$long.",".$lat.",".$alt."</coordinates>\r\n</Point>\r\n</Placemark>\r\n");
					echo '<tr><td style="border-style: solid; border-width: 1px">Wrote AP: '.$ssid.'</td></tr>';
					
					$sql_3 = "SELECT * FROM `$table` WHERE `id`='$row'";
					$sig_result = mysql_query($sql_3, $conn) or die(mysql_error($conn));
					$array = mysql_fetch_array($sig_result);
					$signals = explode("-",$array['sig']);
	#				echo $array['sig'].'<br>';
					foreach($signals as $signal)
					{
						$sig_exp = explode(",",$signal);
						$gpsid = $sig_exp[0];
#						echo $signal.'<br>';
						$sig = $sig_exp[1];
						$sql_1 = "SELECT * FROM `$table_gps` WHERE `id` = '$gpsid'";
						$result_1 = mysql_query($sql_1, $conn);
						$gps = mysql_fetch_array($result_1);
						$lat_exp = explode(" ", $gps['lat']);
						$test = $lat_exp[1]+0;
						if($test == "0.0000"){$zero = 1; continue;}
						
						$alt = $gps['alt'];
		#				echo "IN: ".$gps['lat'].'<br>';
						$lat =& database::convert_dm_dd($gps['lat']);
		#				echo "out: ".$lat.'<br>';
						$long =& database::convert_dm_dd($gps['long']);
						$file_data .= ("<Placemark id=\"".$gps['id']."\"><styleUrl>".$signal_image."</styleUrl>\r\n<Point id=\"".$aparray['mac']."_GPS\">\r\n<coordinates>".$long.",".$lat.",".$alt."</coordinates>\r\n</Point>\r\n</Placemark>");
						echo '<tr><td style="border-style: solid; border-width: 1px">Plotted Signal GPS Point</td></tr>';
					}
				}else
				{
					echo "Failed to write KML File, Check the permissions on the wifidb folder, and make sure that Apache (or what ever HTTP server you are using) has permissions to write";
				}
				$fileappend = fopen($filename, "a");
				fwrite($fileappend, $file_data);
				fwrite( $fileappend, "	</Document>\r\n</kml>");
				
				fclose( $fileappend );
				echo '<tr class="style4"><td style="border-style: solid; border-width: 1px">Your Google Earth KML file is ready,<BR>you can download it from <a class="links" href="'.$filename.'">Here</a></td></tr></table>';
				mysql_close($conn);
				$end = microtime(true);
				if ($GLOBALS["bench"]  == 1)
				{
					echo "Time is [Unix Epoc]<BR>";
					echo "Start Time: ".$start."<BR>";
					echo "  End Time: ".$end."<BR>";
				}
				break;
			#----------------------#
			#----------------------#
		}
	}

	function exp_vs1($export = "", $user = "", $row = 0)
	{
		include('config.inc.php');
		include('manufactures.inc.php');
		$gps_array = array();
		switch ($export)
		{
			case "exp_all_db_vs1":
				$n	=	1; 
				$nn	=	1; # AP Array key
				echo '<table><tr class="style4"><th style="border-style: solid; border-width: 1px">Start of WiFi DB export to VS1</th></tr>';
				mysql_select_db($db,$conn) or die("Unable to select Database: ".$db);
				$sql_		= "SELECT * FROM `$wtable`";
				$result_	= mysql_query($sql_, $conn) or die(mysql_error());
				while($ap_array = mysql_fetch_array($result_))
				{
					$manuf = database::manufactures($ap_array['mac']);
					switch($ap_array['sectype'])
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
					switch($ap_array['radio'])
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
					mysql_select_db($db_st,$conn) or die("Unable to select Database: ".$db_st);
					
					$table	=	$ap_array['ssid'].'-'.$ap_array['mac'].'-'.$ap_array['sectype'].'-'.$ap_array['radio'].'-'.$ap_array['chan'];
					$sql	=	"SELECT * FROM `$table`";
					$result	=	mysql_query($sql, $conn) or die(mysql_error());
					$rows	=	mysql_num_rows($result);
					
					$sql1 = "SELECT * FROM `$table` WHERE `id` = '$rows'";
					$result1 = mysql_query($sql1, $conn) or die(mysql_error());
					$newArray = mysql_fetch_array($result1);
#					echo $nn."<BR>";
					$otx	= $newArray["otx"];
					$btx	= $newArray["btx"];
					$nt		= $newArray['nt'];
					$label	= $newArray['label'];
					$signal	= $newArray['sig'];
					$aps[$nn]	= array(
										'id'		=>	$ap_array['id'],
										'ssid'		=>	$ap_array['ssid'],
										'mac'		=>	$ap_array['mac'],
										'sectype'	=>	$ap_array['sectype'],
										'r'			=>	$ap_array['radio'],
										'radio'		=>	$radio,
										'chan'		=>	$ap_array['chan'],
										'man'		=>	$manuf,
										'type'		=>	$type,
										'auth'		=>	$auth,
										'encry'		=>	$encry,
										'label'		=>	$label,
										'nt'		=>	$nt,
										'btx'		=>	$btx,
										'otx'		=>	$otx,
										'sig'		=>	$signal
										);
					$nn++;
				}
				$signals = array();
				
				foreach($aps as $key=>$ap)
				{
					$n			=	1;	# GPS Array KEY -has to start at 1 vistumbler will error out if the first GPS point has a key of 0
					$sig		=	$ap['sig'];
					$signals	=	explode("-", $sig);
	#				echo $sig."<BR>";
					$table_gps		=	$ap['ssid'].'-'.$ap['mac'].'-'.$ap['sectype'].'-'.$ap['r'].'-'.$ap['chan'].$gps_ext;
					echo $table_gps."<BR>";
					foreach($signals as $sign)
					{
						mysql_select_db($db_st,$conn) or die("Unable to select Database: ".$db_st);
						$sig_exp = explode(",", $sign);
						$gps_id	= $sig_exp[0];
						
						$sql1 = "SELECT * FROM `$table_gps` WHERE `id` = '$gps_id'";
						$result1 = mysql_query($sql1, $conn) or die(mysql_error());
						$gps_table = mysql_fetch_array($result1);
						$gps_array[$n]	=	array(
												"lat" => $gps_table['lat'],
												"long" => $gps_table['long'],
												"sats" => $gps_table['sats'],
												"date" => $gps_table['date'],
												"time" => $gps_table['time']
												);
						$n++;
						$signals[] = $n.",".$sig_exp[1];
					}
					$sig_new = implode("-", $signals);
					$aps[$key]['sig'] = $sig_new;
					echo $aps[$key]['sig']."<BR>";
				}
				#$gps_array = array_unique($gps_array);
		#		var_dump($gps_array);
				
				$date		=	date('Y-m-d_H-i-s');
				$file_ext	=	$date."_entire_db.vs1";
				$filename	=	$vs1_out.$file_ext;
				// define initial write and appends
				$filewrite	=	fopen($filename, "w");
				$fileappend	=	fopen($filename, "a");
				
				$h1 = "#  Vistumbler VS1 - Detailed Export Version 1.2\r\n# Created By: RanInt WiFi DB Alpha 0.16 Build 1 \r\n# -------------------------------------------------\r\n# GpsID|Latitude|Longitude|NumOfSatalites|Date(UTC y-m-d)|Time(UTC h:m:s)\r\n# -------------------------------------------------\r\n";
				fwrite($fileappend, $h1);
				
				foreach( $gps_array as $key=>$gps )
				{
					$lat	=	$gps['lat'];
					$long	=	$gps['long'];
					$sats	=	$gps['sats'];
					$date	=	$gps['date'];
					$time	=	$gps['time'];
					if ($GLOBALS["debug"] ==1 ){echo "Lat : ".$lat." - Long : ".$long."\n";}
					$gpsd = $key."|".$lat."|".$long."|".$sats."|".$date."|".$time."\r\n";
					if($GLOBALS["debug"] == 1){ echo $gpsd;}
					fwrite($fileappend, $gpsd);
				}
				$ap_head = "# ---------------------------------------------------------------------------------------------------------------------------------------------------------\r\n# SSID|BSSID|MANUFACTURER|Authetication|Encryption|Security Type|Radio Type|Channel|Basic Transfer Rates|Other Transfer Rates|Network Type|Label|GpsID,SIGNAL\r\n# ---------------------------------------------------------------------------------------------------------------------------------------------------------\r\n";
				fwrite($fileappend, $ap_head);
				foreach($aps as $ap)
				{
					$apd = $ap['ssid']."|".$ap['mac']."|".$ap['man']."|".$ap['auth']."|".$ap['encry']."|".$ap['sectype']."|".$ap['radio']."|".$ap['chan']."|".$ap['btx']."|".$ap['otx']."|".$ap['nt']."|".$ap['label']."|".$ap['sig']."\r\n";
					fwrite($fileappend, $apd);
				}
				fclose($fileappend);
				fclose($filewrite);
				mysql_close($conn);
				$end 	=	date("H:i:s");
				$GPSS	=	count($gps_array);
				echo '<tr><td style="border-style: solid; border-width: 1px">Wrote # GPS Points: '.$GPSS.'</td></tr>';
				$APSS	=	count($aps);
				echo '<tr><td style="border-style: solid; border-width: 1px">Wrote # Access Points: '.$APSS.'</td></tr>';
				echo '<tr><td style="border-style: solid; border-width: 1px">Your Vistumbler VS1 file is ready,<BR>you can download it from <a class="links" href="'.$filename.'">Here</a></td><td></td></tr></table>';
				break;
		}
	}
}#end DATABASE CLASS
?>