<?php
include('../lib/database.inc.php');

include('../lib/config.inc.php');
$func			= '';
$refresh_post	= '';
$tz_post		= '';
if( !isset($_GET['func']) ) { $_GET['func'] = ""; }
$func = strip_tags(addslashes($_GET['func']));

switch($func)
{
	case 'refresh':
		if( (!isset($_POST['refresh'])) or $_POST['refresh']=='' ) { $_POST['refresh'] = "wifidb"; }
		$refresh_post = strip_tags(addslashes($_POST['refresh']));
		setcookie( 'wifidb_refresh' , $refresh_post , (time()+(86400 * 7)), "/".$root."/opt/scheduling.php" ); // 86400 = 1 day
		header('Location: scheduling.php?token='.$_SESSION['token']);
	break;

	case 'set_tzone':
		if( (!isset($_POST['TZone'])) or $_POST['TZone']=='' ) { $_POST['TZone'] = "-5"; }
		$tz_post = strip_tags(addslashes($_POST['TZone']));
		setcookie( 'wifidb_client_timezone' , $tz_post , (time()+(86400 * 365)), "/".$root."/opt/scheduling.php" ); // 86400 = 1 day
		header('Location: scheduling.php?token='.$_SESSION['token']);
	break;
}
$TZone = ($_COOKIE['wifidb_client_timezone']!='' ? $_COOKIE['wifidb_client_timezone'] : $default_timezone);
$refresh = ($_COOKIE['wifidb_refresh']!='' ? $_COOKIE['wifidb_refresh'] : $default_refresh);
#echo $TZone;
pageheader("Scheduling Page");

####################
function getdaemonstats()
{
	$WFDBD_PID = $GLOBALS['wifidb_tools'].'/daemon/wifidbd.pid';
	$os = PHP_OS;
	if ( $os[0] == 'L')
	{
		?><tr class="style4"><th colspan="4">Linux Based WiFiDB Daemon</th></tr><?php
		$output = array();
		if(file_exists($WFDBD_PID))
		{
			$pid_open = file($WFDBD_PID);
			echo $pid_open;
			exec('ps vp '.$pid_open[0] , $output, $sta);
			if(isset($output[1]))
			{
				$start = trim($output[1], " ");
				preg_match_all("/(\d+?)(\.)(\d+?)/", $start, $match);
				$mem = $match[0][0];
				
				preg_match_all("/(php.*)/", $start, $matc);
				$CMD = $matc[0][0];
				
				preg_match_all("/(\d+)(\:)(\d+)/", $start, $mat);
				$time = $mat[0][0];
				
				$patterns[1] = '/  /';
				$patterns[2] = '/ /';
				$ps_stats = preg_replace($patterns , "|" , $start);
				$ps_Sta_exp = explode("|", $ps_stats);
				?>
				<tr class="style4">
					<th>PID</th>
					<th>TIME</th>
					<th>Memory</th>
					<th>CMD</th>
				</tr>
				<tr align="center" bgcolor="green">
					<td><?php echo str_replace(' ?',"",$ps_Sta_exp[0]);?></td>
					<td><?php echo $time;?></td>
					<td><?php echo $mem."%";?></td>
					<td><?php echo $CMD;?></td>
				</tr>
				<?php
			}else
			{
				?><tr align="center" bgcolor="red"><td colspan="4">Linux Based WiFiDB Daemon is not running!</td><?php
			}
		}else
		{
			?><tr align="center" bgcolor="red"><td colspan="4">Linux Based WiFiDB Daemon is not running!</td><?php
		}
	}elseif( $os[0] == 'W')
	{
		$output = array();
		if(file_exists($WFDBD_PID))
		{
			$pid_open = file($WFDBD_PID);
			exec('tasklist /V /FI "PID eq '.$pid_open[0].'" /FO CSV' , $output, $sta);
			if(isset($output[2]))
			{
				?><tr class="style4"><th colspan="4">Windows Based WiFiDB Daemon</th></tr><tr><th>Proc</th><th>PID</th><th>Memory</th><th>CPU Time</th></tr><?php
				$ps_stats = explode("," , $output[2]);
				?><tr align="center" bgcolor="green"><td><?php echo str_replace('"',"",$ps_stats[0]);?></td><td><?php echo str_replace('"',"",$ps_stats[1]);?></td><td><?php echo str_replace('"',"",$ps_stats[4]).','.str_replace('"',"",$ps_stats[5]);?></td><td><?php echo str_replace('"',"",$ps_stats[8]);?></td></tr><?php
			}else
			{
				?><tr class="style4"><th colspan="4">Windows Based WiFiDB Daemon</th></tr>
				<tr align="center" bgcolor="red"><td colspan="4">Windows Based WiFiDB Daemon is not running!</td><?php
			}
		}else
		{
			?><tr class="style4"><th colspan="4">Windows Based WiFiDB Daemon</th></tr>
			<tr align="center" bgcolor="red"><td colspan="4">Windows Based WiFiDB Daemon is not running!</td><?php
		}
	}else
	{
		?><tr class="style4"><th colspan="4">Unkown OS Based WiFiDB Daemon</th></tr>
		<tr align="center" bgcolor="red"><td colspan="4">Unkown OS Based WiFiDB Daemon is not running!</td><?php
	}
	
}
#####################
$func = '';
if(!isset($_GET['func'])){$_GET['func']="";}
$func = strip_tags(addslashes($_GET['func']));
if($GLOBALS['wifidb_tools'] == 'NO PATH' or $GLOBALS['wifidb_tools'] == NULL){$func = "no_daemon";}
if(is_string($func))
{
	switch($func)
	{
		case 'waiting':
			?><table border="1" width="90%"><tr class="style4"><th border="1" colspan="7" align="center">Files waiting for import</th></tr><?php
			$sql1 = "SELECT * FROM `$db`.`files_tmp`";
			$result1 = mysql_query($sql1, $conn) or die(mysql_error($conn));
			$total_rows = mysql_num_rows($result1);
			
			$sql = "SELECT * FROM `$db`.`files_tmp` ORDER BY `id` ASC LIMIT 10, $total_rows";
			$result = mysql_query($sql, $conn) or die(mysql_error($conn));
			if($total_rows === 0)
			{
				?><tr><td border="1" colspan="7" align="center">There are no files waiting to be imported, Go and import a file</td></tr></table><?php
			}else
			{
				?><tr align="center"><td border="1"><br><?php
				while ($newArray = mysql_fetch_array($result))
				{
					if($newArray['importing'] == '1' )
					{
						$color = 'style="background-color: lime"';
					}else
					{
						$color = 'style="background-color: yellow"';
					}
					?>
					<table <?php echo $color;?> border="1"  width="100%">
					<tr class="style4"><th>ID</th><th>Filename</th><th>Date</th><th>title</th><th>size</th></tr>
					<tr <?php echo $color;?>>
					<td align="center">
					<?php
					echo $newArray['id'];
					?>
					</td><td align="center">
					<?php
					echo $newArray['file'];
					?>
					</td><td align="center">
					<?php
					echo $newArray['date'];
					?>
					</td><td align="center">
					<?php
					echo $newArray['title'];
					?>
					</td><td align="center">
					<?php
					echo $newArray['size'];
					?>
					</td></tr>
					<tr class="style4">
					<th <?php echo $color;?>>
					</th>
					<th>Hash Sum</th><th>User</th><th >Current SSID</th><th>AP / Total AP's</th></tr>
					<tr <?php echo $color;?>>
					<td></td>
					<td align="center">
					<?php
					echo $newArray['hash'];
					?>
					</td><td align="center">
					<?php
					echo $newArray['user'];
					?>
					</td><td align="center">
					<?php
					if($newArray['ap'] == NULL){$ssid = "None being imported";}else{$ssid = $newArray['ap'];}
					echo $ssid;
					?>
					</td><td align="center">
					<?php
					if($newArray['tot'] == NULL){$tot = "None being imported";}else{$tot = $newArray['tot'];}
					echo $tot;
					?>
					</td></tr>
					</table>
					<br>
					<?php
				}
					?>
					</td></tr>
					</table>
					<?PHP
			}
		break;
		
		case 'done':
			?>
			<br><table border="1" width="90%"><tr class="style4">
			<th colspan="9" align="center">Files already imported</th></tr>
			<?php
			$sql = "SELECT * FROM `$db`.`files` ORDER BY `id` DESC";
			$result = mysql_query($sql, $conn) or die(mysql_error());
			$total_rows = mysql_num_rows($result);
			if($total_rows === 0)
			{
				?><tr><td colspan="9" align="center">There where no files that where imported, Go and import a file</td></tr></table><?php
			}else
			{
				while ($newArray = mysql_fetch_array($result))
				{
					?><tr class="style4"><th>ID</th><th>Filename</th><th>Date</th><th>user</th><th>title</th></tr><tr><td align="center">
					<?php
					echo $newArray['id'];
					?>
					</td><td align="center">
					<a class="links" href="../opt/userstats.php?func=useraplist&row=<?php echo $newArray["user_row"];?>&token=<?php echo $_SESSION['token']?>"><?php echo $newArray['file'];?></a>
					</td><td align="center">
					<?php
					echo $newArray['date'];
					?>
					</td><td align="center">
					<a class="links" href ="../opt/userstats.php?func=alluserlists&user=<?php echo $newArray["user"];?>&token=<?php echo $_SESSION['token']?>"><?php echo $newArray["user"];?></a>
					</td><td align="center">
					<?php
					echo $newArray['title'];
					?></td></tr>
					<tr>
					<th></th><th class="style4">Total AP's</th><th class="style4">Total GPS</th><th class="style4">Size</th><th class="style4">Hash Sum</th></tr>
					<tr><td></td><td align="center">
					<?php
					echo $newArray['aps'];
					?>
					</td><td align="center">
					<?php
					echo $newArray['gps'];
					?>
					</td><td align="center">
					<?php
					echo $newArray['size'];
					?>
					</td><td align="center">
					<?php
					echo $newArray['hash'];
					?>
					</td></tr><tr></tr>
					<?php
				}
				?>
				</table><?php
			}
		break;
		
		case 'daemon_kml':
			?>
			<table width="50%" border="1" cellspacing="0" cellpadding="0" align="center">
			<tr>
				<td>
				<table border="1" cellspacing="0" cellpadding="0" style="width: 100%">
					<tr>
						<td class="style4">Daemon Generated KML</td>
					</tr>
				</table>
				<table border="1" cellspacing="0" cellpadding="0" style="width: 100%">
					<tr><td class="daemon_kml" colspan="2">
					<?php
					if(file_exists("../out/daemon/update.kml"))
					{
					?>
					<a class="links" href="../out/daemon/update.kml">Current WiFiDB Network Link</a>
					<?php
					}else
					{
					?>
						The Daemon Needs to be on and you need to import something with GPS for the first update.kml file to be created.
					<?php
					}
					?>
					</td>
					</tr>
					<tr>
						<td colspan="2" class="style4">History</td>
					</tr>
				</table>
				<table style="width: 50%" align="center">
					<tr>
						<td class="daemon_kml">
						<?php
						$download = '';
						$file_count = 0;
						$dh = opendir("../out/daemon") or die("couldn't open directory");
						while ($file = readdir($dh))
						{
							if($file == "."){continue;}
							if($file == ".."){continue;}
							if($file == ".svn"){continue;}
							if($file == "fulldb.kmz"){continue;}
							if($file == "update.kml"){continue;}
							if($file == "newestAP.kml"){continue;}
							if($file == "newestAP_label.kml"){continue;}
							$kmz_file = '../out/daemon/'.$file.'/fulldb.kmz';
							if(file_exists($kmz_file))
							{
								$download = $download.'<table border="1" cellspacing="0" cellpadding="0"  width="100%">
									<tr>
										<td style="width: 50%">'.$file.'</td>
										<td><a class="links" href="../out/daemon/'.$file.'/fulldb.kmz">Download</a></td>
									</tr>
								</table>
								<br>';
								$file_count++;
							}
						}
						if($file_count == 0)
						{
							?>
							<table style="width: 100%">
								<tr>
									<td>There have been no KMZ files created.</td>
								</tr>
							</table>
							<?php
						}else
						{
							echo $download;
						}
						?>
						</td>
						</tr>
					</table>
					</td>
				</tr>
			</table>
			<?php
		break;
		
		case "create_kml":
		
		$daemon_KMZ_folder = $GLOBALS['hosturl'].$GLOBALS['root']."/out/daemon/";
		
		$Network_link_KML = $daemon_KMZ_folder."update.kml";
		
		$daemon_daily_KML = $GLOBALS['wifidb_install']."/out/daemon/update.kml";
		
		$filewrite = fopen($daemon_daily_KML, "w");
		$fileappend_update = fopen($daemon_daily_KML, "a");
		
		fwrite($fileappend_update, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<kml xmlns=\"http://earth.google.com/kml/2.2\">
	<Document>
		<name>WiFiDB *ALPHA* Auto KMZ Generation</name>
		<Folder>
		<name> Newest Access Point</name>
		<open>1</open>
		<Style>
			<ListStyle>
				<listItemType>radioFolder</listItemType>
				<bgColor>00ffffff</bgColor>
				<maxSnippetLines>2</maxSnippetLines>
			</ListStyle>
		</Style>
		<NetworkLink>
			<name>Newest AP</name>
			<flyToView>1</flyToView>
			<Url>
				<href>".$daemon_KMZ_folder."newestAP.kml</href>
				<refreshMode>onInterval</refreshMode>
				<refreshInterval>1</refreshInterval>
			</Url>
		</NetworkLink>
		<NetworkLink>
			<name>Newest AP Label</name>
			<flyToView>1</flyToView>
			<Url>
				<href>".$daemon_KMZ_folder."newestAP_label.kml</href>
				<visibility>0</visibility>
				<refreshMode>onInterval</refreshMode>
				<refreshInterval>1</refreshInterval>
			</Url>
		</NetworkLink>
		</Folder>
		<name>Daemon Generated KMZ</name>
		<open>1</open>
		<NetworkLink>
			<name>Daily KMZ</name>
			<Url>
				<href>".$daemon_KMZ_folder."fulldb.kmz</href>
				<refreshMode>onInterval</refreshMode>
				<refreshInterval>3600</refreshInterval>
			</Url>
		</NetworkLink>
	</Document>
</kml>");
		
		break;
		
		case "no_daemon":
			?>
			<h2>You do not have the Daemon Option enabled, you will not be able to use this page until you enable it.</h2>
			<?php
		break;
		
		
		default:
		
$timezone_names = array(
							0	=>		"International Date Line",
							1	=>		"International Date Line",
							2	=>		"Pacific Ocean",
							3	=>		"Kamchatskiy, E Russia",
							4	=>		"Hawaii",
							5	=>		"Eastern Russia - Sydney, Australia",
							6	=>		"Alaska Time",
							7	=>		"Mid Australia",
							8	=>		"Japan",
							9	=>		"Pacific Standard Time",
							10	=>		"China",
							11	=>		"Mountain Standard Time",
							12	=>		"W Mongolia",
							13	=>		"Burma",
							14	=>		"Central Standard Time",
							15	=>		"Almaty (Alma ATA), Russia",
							
							16	=>		"Atlantic Time",
							17	=>		"Afghanistan",
							18	=>		"NW Caspian Sea",
							19	=>		"Newfoundland Time",
							20	=>		"Greenland Time",
							21	=>		"Iran",
							22	=>		"Moscow, Mid-East, E Africa",
							
							23	=>		"Eastern Standard Time",
							24	=>		"India",
							25	=>		"Ural Mountains, Russia",
							
							26	=>		"Atlantic Ocean",
							27	=>		"E Europe, E Central Africa",
							28	=>		"SE Greenland",
							29	=>		"Mid Europe - Africa",
							30	=>		"Greenwich, England"
						);

$timezone_numbers = array(
							0	=>	"/-12/"	,# International Date Line
							1	=>	"/12/"	,# International Date Line
							2	=>	"/-11/"	,# Pacific Ocean
							3	=>	"/11/"	,# Kamchatskiy, E Russia
							4	=>	"/-10/"	,# Hawaii
							5	=>	"/10/"	,# Eastern Russia - Sydney, Australia
							6	=>	"/-9/"	,# Alaska Time
							7	=>	"/9.5/",#	 Mid Australia
							8	=>	"/9/"	,# Japan
							9	=>	"/-8/"	,# Pacific Standard Time
							10	=>	"/8/"	 ,#China
							11	=>	"/-7/",#	 Mountain Standard Time
							12	=>	"/7/"	, #W Mongolia
							13	=>	"/6.5/",#	 Burma
							14	=>	"/-6/",#	 Central Standard Time
							15	=>	"/6/"	,# Almaty (Alma ATA), Russia

							16	=>	"/-4/",#	 Atlantic Time
							17	=>	"/4.5/",#	 Afghanistan
							18	=>	"/4/",#	 NW Caspian Sea
							19	=>	"/-3.5/"	,# Newfoundland Time
							20	=>	"/-3/"	,# Greenland Time
							21	=>	"/3.5/",#	 Iran
							22	=>	"/3/"	,# Moscow, Mid-East, E Africa
							
							23	=>	"/-5/",#	 Eastern Standard Time
							24	=>	"/5.5/",#	 India
							25	=>	"/5/"	,# Ural Mountains, Russia
							
							26	=>	"/-2/",#	 Atlantic Ocean
							27	=>	"/2/"	, #E Europe, E Central Africa
							28	=>	"/-1/",#	 SE Greenland
							29	=>	"/1/",#	 Mid Europe - Africa
							30	=>	"/0/"	 #Greenwich, England
						);
 
			include $GLOBALS['wifidb_tools']."/daemon/config.inc.php";
			echo '<meta http-equiv="refresh" content="'.$refresh.'"><table border="1" width="90%"><tr class="style4"><th colspan="4">Scheduled Imports</th></tr>';
			mysql_select_db($db,$conn);
			$sql = "SELECT * FROM `$db`.`settings` WHERE `table` LIKE 'files'";
			$result = mysql_query($sql, $conn) or die(mysql_error());
			$file_array = mysql_fetch_array($result);
			
			if(isset($_SESSION['token']))
			{
				$token = $_SESSION['token'];
			}else
			{
				$token = md5(uniqid(rand(), true));
				$_SESSION['token'] = $token;
			}			
			?>
				<tr><td>Next Import scheduled on:</td><td><?php echo $file_array['size'];?> UTC</td><td>
				<?php
				$str_time = strtotime($file_array['size']);
				$alter_by = (($TZone*60)*60);
				$altered = $str_time+$alter_by;
				$next_run = date("Y-m-d H:i:s", $altered);
				$Zone = " [".$TZone."] ";
				$time_zone_string = preg_replace($timezone_numbers, $timezone_names, $Zone);
				
				echo $next_run.$time_zone_string;
				?></td></tr>
				<tr><td colspan="1">Select Refresh Rate:</td><td colspan="2">
					<form action="scheduling.php?func=refresh&token=<?php echo $_SESSION['token'];?>" method="post" enctype="multipart/form-data">
					<input type="hidden" name="token" value="<?php echo $token; ?>" />
					<SELECT NAME="refresh">  
					<OPTION <?php if($refresh == 5){ echo "selected ";}?> VALUE="5"> 5 Seconds
					<OPTION <?php if($refresh == 10){ echo "selected ";}?> VALUE="10"> 10 Seconds
					<OPTION <?php if($refresh == 15){ echo "selected ";}?> VALUE="15"> 15 Seconds
					<OPTION <?php if($refresh == 30){ echo "selected ";}?> VALUE="30"> 30 Seconds
					<OPTION <?php if($refresh == 60){ echo "selected ";}?> VALUE="60"> 60 Seconds
					<OPTION <?php if($refresh == 120){ echo "selected ";}?> VALUE="120"> 2 Minutes
					<OPTION <?php if($refresh == 240){ echo "selected ";}?> VALUE="240"> 4 Minutes
					<OPTION <?php if($refresh == 480){ echo "selected ";}?> VALUE="480"> 8 Minutes
					<OPTION <?php if($refresh == 960){ echo "selected ";}?> VALUE="960"> 16 Minutes
					<OPTION <?php if($refresh == 1920){ echo "selected ";}?> VALUE="1920"> 32 Minutes
					<OPTION <?php if($refresh == 3840){ echo "selected ";}?> VALUE="3840"> 64 Minutes
					<OPTION <?php if($refresh == 5760){ echo "selected ";}?> VALUE="5760"> 96 Minutes
					<OPTION <?php if($refresh == 7680){ echo "selected ";}?> VALUE="7680"> 128 Minutes
					<OPTION <?php if($refresh == 30720){ echo "selected ";}?> VALUE="30720"> 512 Minutes
					</SELECT>
					<INPUT TYPE=SUBMIT NAME="submit" VALUE="Submit">
					</form>
				</td></tr>
				<tr><td colspan="1">Set Your Timezone:</td><td colspan="2">
					<form action="scheduling.php?func=set_tzone&token=<?php echo $_SESSION['token'];?>" method="post" enctype="multipart/form-data">
					<input type="hidden" name="token" value="<?php echo $token; ?>" />
					<SELECT NAME="TZone">  
					<OPTION <?php if($TZone == -12){ echo "selected ";}?> VALUE="-12"> -12 hrs
					<OPTION <?php if($TZone == -11){ echo "selected ";}?> VALUE="-11"> -11 hrs
					<OPTION <?php if($TZone == -10){ echo "selected ";}?> VALUE="-10"> -10 hrs
					<OPTION <?php if($TZone == -9){ echo "selected ";}?> VALUE="-9"> -9 hrs
					<OPTION <?php if($TZone == -8){ echo "selected ";}?> VALUE="-8"> -8 hrs
					<OPTION <?php if($TZone == -7){ echo "selected ";}?> VALUE="-7"> -7 hrs
					<OPTION <?php if($TZone == -6){ echo "selected ";}?> VALUE="-6"> -6 hrs
					<OPTION <?php if($TZone == -5){ echo "selected ";}?> VALUE="-5"> -5 hrs
					<OPTION <?php if($TZone == -4){ echo "selected ";}?> VALUE="-4"> -4 hrs
					<OPTION <?php if($TZone == -3.5){ echo "selected ";}?> VALUE="-3.5"> -3.5 hrs
					<OPTION <?php if($TZone == -3){ echo "selected ";}?> VALUE="-3"> -3 hrs
					<OPTION <?php if($TZone == -2){ echo "selected ";}?> VALUE="-2"> -2 hrs
					<OPTION <?php if($TZone == -1){ echo "selected ";}?> VALUE="-1"> -1 hrs
					<OPTION <?php if($TZone == 0){ echo "selected ";}?> VALUE="0"> 0 hrs
					<OPTION <?php if($TZone == 1){ echo "selected ";}?> VALUE="1"> 1 hrs
					<OPTION <?php if($TZone == 2){ echo "selected ";}?> VALUE="2"> 2 hrs
					<OPTION <?php if($TZone == 3){ echo "selected ";}?> VALUE="3"> 3 hrs
					<OPTION <?php if($TZone == 3.5){ echo "selected ";}?> VALUE="3.5"> 3.5 hrs
					<OPTION <?php if($TZone == 4){ echo "selected ";}?> VALUE="4"> 4 hrs
					<OPTION <?php if($TZone == 4.5){ echo "selected ";}?> VALUE="4.5"> 4.5 hrs
					<OPTION <?php if($TZone == 5){ echo "selected ";}?> VALUE="5"> 5 hrs
					<OPTION <?php if($TZone == 6){ echo "selected ";}?> VALUE="6"> 6 hrs
					<OPTION <?php if($TZone == 6.5){ echo "selected ";}?> VALUE="6.5"> 6.5 hrs
					<OPTION <?php if($TZone == 7){ echo "selected ";}?> VALUE="7"> 7 hrs
					<OPTION <?php if($TZone == 8){ echo "selected ";}?> VALUE="8"> 8 hrs
					<OPTION <?php if($TZone == 9){ echo "selected ";}?> VALUE="9"> 9 hrs
					<OPTION <?php if($TZone == -9.5){ echo "selected ";}?> VALUE="9.5"> 9.5 hrs
					<OPTION <?php if($TZone == 10){ echo "selected ";}?> VALUE="10"> 10 hrs
					<OPTION <?php if($TZone == 11){ echo "selected ";}?> VALUE="11"> 11 hrs
					<OPTION <?php if($TZone == 12){ echo "selected ";}?> VALUE="12"> 12 hrs
					</SELECT>
					<INPUT TYPE=SUBMIT NAME="submit" VALUE="Submit">
					</form>
				</td></tr>
				
			</table><br />
			<table border="1" width="90%">
			<tr class="style4"><th colspan="4">Daemon Status:</TH></tr>
			<?php
			getdaemonstats();
			?>
			</table>
			<br>
			<?php
			$sql1 = "SELECT * FROM `$db`.`files_tmp`";
			$result1 = mysql_query($sql1, $conn) or die(mysql_error($conn));
			$total_rows = mysql_num_rows($result1);
			if($total_rows > 10)
			{
				echo '<a class="links" href="scheduling.php?func=waiting&token='.$_SESSION['token'].'">View other files waiting for import.</a><br>';
			}
			
			$sql1 = "SELECT * FROM `$db`.`files`";
			$result1 = mysql_query($sql1, $conn) or die(mysql_error($conn));
			$done_rows = mysql_num_rows($result1);
			if($done_rows > 0)
			{
				echo '<a class="links" href="scheduling.php?func=done&token='.$_SESSION['token'].'">View other files that have finished importing.</a><br>';
			}
			?>
			<br>
			<table border="1" width="90%"><tr class="style4"><th border="1" colspan="7" align="center">Files waiting for import</th></tr><?php
			$sql = "SELECT * FROM `$db`.`files_tmp` ORDER BY `id` ASC LIMIT 0, 10";
			$result = mysql_query($sql, $conn) or die(mysql_error($conn));
			if($total_rows === 0)
			{
				?><tr><td border="1" colspan="7" align="center">There are no files waiting to be imported, Go and import a file</td></tr></table><?php
			}else
			{
				?><tr align="center"><td border="1"><br><?php
				while ($newArray = mysql_fetch_array($result))
				{
					if($newArray['importing'] == '1' )
					{
						$color = 'style="background-color: lime"';
					}else
					{
						$color = 'style="background-color: yellow"';
					}
						?>
					<table <?php echo $color;?> border="1"  width="100%">
					<tr class="style4"><th>ID</th><th>Filename</th><th>Date</th><th>title</th><th>size</th></tr>
					<tr <?php echo $color;?>>
					<td align="center">
					<?php
					echo $newArray['id'];
					?>
					</td><td align="center">
					<?php
					echo $newArray['file'];
					?>
					</td><td align="center">
					<?php
					echo $newArray['date'];
					?>
					</td><td align="center">
					<?php
					echo $newArray['title'];
					?>
					</td><td align="center">
					<?php
					echo $newArray['size'];
					?>
					</td></tr>
					<tr class="style4">
					<th <?php echo $color;?>>
					</th>
					<th>Hash Sum</th><th>User</th><th >Current SSID</th><th>AP / Total AP's</th></tr>
					<tr <?php echo $color;?>>
					<td></td>
					<td align="center">
					<?php
					echo $newArray['hash'];
					?>
					</td><td align="center">
					<?php
					echo $newArray['user'];
					?>
					</td><td align="center">
					<?php
					if($newArray['ap'] == NULL){$ssid = "None being imported";}else{$ssid = $newArray['ap'];}
					echo $ssid;
					?>
					</td><td align="center">
					<?php
					if($newArray['tot'] == NULL){$tot = "None being imported";}else{$tot = $newArray['tot'];}
					echo $tot;
					?>
					</td></tr>
					</table>
					<br>
					<?php
				}
				?></td></tr></table><br><?php
			}
		break;
	}
}
echo "<BR>";
footer($_SERVER['SCRIPT_FILENAME']);
?>