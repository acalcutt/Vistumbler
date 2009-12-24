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
		setcookie( 'wifidb_refresh' , $refresh_post , (time()+($timeout)), "/".$root."/opt/scheduling.php" );
		header('Location: scheduling.php?token='.$_SESSION['token']);
	break;

}
$TZone = ($_COOKIE['wifidb_client_timezone'] ? $_COOKIE['wifidb_client_timezone'] : $default_timezone);
$dst = ($_COOKIE['wifidb_client_dst']!='' ? $_COOKIE['wifidb_client_dst'] : -1);
$refresh = ($_COOKIE['wifidb_refresh']!='' ? $_COOKIE['wifidb_refresh'] : $default_refresh);

pageheader("Scheduling Page");

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
				?><tr class="dark"><td border="1" colspan="7" align="center">There are no files waiting to be imported, Go and import a file</td></tr></table><?php
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
			footer($_SERVER['SCRIPT_FILENAME']);
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
				$class_f = 0;
				while ($newArray = mysql_fetch_array($result))
				{
					if($class_f){$class = "light"; $class_f =0;}else{$class = "dark"; $class_f =1;}
					?><tr class="sub_header"><th>ID</th><th>Filename</th><th>Date</th><th>user</th><th>title</th></tr>
					<tr class="<?php echo $class;?>"><td align="center">
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
					<tr><th></th><th class="sub_header">Total AP's</th><th class="sub_header">Total GPS</th><th class="sub_header">Size</th><th class="sub_header">Hash Sum</th></tr>
					<tr><td></td><td class="<?php echo $class;?>" align="center">
					<?php
					echo $newArray['aps'];
					?>
					</td><td class="<?php echo $class;?>" align="center">
					<?php
					echo $newArray['gps'];
					?>
					</td><td class="<?php echo $class;?>" align="center">
					<?php
					echo format_size(($newArray['size']*1024), 2);
					?>
					</td><td class="<?php echo $class;?>" align="center">
					<?php
					echo $newArray['hash'];
					?>
					</td></tr><tr></tr><tr></tr><tr></tr><tr></tr>
					<?php
				}
				?>
				</table><?php
			}
			footer($_SERVER['SCRIPT_FILENAME']);
		break;
		
		case 'daemon_kml':
			$date = date("Y-m-d");
			$DATES = array();
			$DGK_folder = array();
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
					$DATES[] = $file;
					$DGK_folder[] = array(
											"file" => $file,
											"kmz_file" => $kmz_file,
											"kmz_date" => date ("H:i:s", filemtime($kmz_file)),
											"kmz_size" => format_size(dos_filesize("../out/daemon/".$file."/fulldb.kmz"), 2)
										);
						
					$file_count++;
				}
			}
			rsort($DGK_folder);
			rsort($DATES);
			if($DATES[0] == ''){$today = $date;}else{$today = $DATES[0];}
			?>
			<table width="700px" border="1" cellspacing="0" cellpadding="0" align="center">
			<tr>
				<td>
				<table border="1" cellspacing="0" cellpadding="0" style="width: 100%">
					<tr>
						<td class="style4">Daemon Generated KML<br><font size="2">All times are local system time.</font></td>
					</tr>
				</table>
				<table border="1" cellspacing="0" cellpadding="0" style="width: 100%">
					<tr>
						<td class="daemon_kml" colspan="3">
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
						<td class='daemon_kml'>Newest AP KML Last Edit: </td>
							<?php
							$newest = '../out/daemon/newestAP.kml';
							if(file_exists($newest))
							{
								echo "<td>".date ("Y-m-d H:i:s", filemtime($newest))."</td><td>".format_size(dos_filesize($newest), 2);
							}else
							{
								echo "<td>None generated yet</td><td> 0.00 kb";
							}
							?>
						</td>
					</tr>
					<tr>
						<td class='daemon_kml'>Full KML Last Edit: </td>
							<?php
							$full = '../out/daemon/'.$today.'/full_db.kml';
							if(file_exists($full))
							{
								echo "<td >".date ("Y-m-d H:i:s", filemtime($full))."</td><td>".format_size(dos_filesize($full), 2);
							}else
							{
								echo "<td>None generated for ".$today." yet, <br>be patient young grasshopper.</td><td> 0.00 kb";
							}
							?>
							</td>
					</tr>
					<tr>
						<td class='daemon_kml'>Daily KML Last Edit: </td>
							<?php
							$daily = '../out/daemon/'.$today.'/daily_db.kml';
							if(file_exists($daily))
							{
								echo "<td>".date ("Y-m-d H:i:s", filemtime($daily))."</td><td>".format_size(dos_filesize($daily), 2);
							}else
							{
								echo "<td>None generated for ".$today." yet, <br>be patient young grasshopper.</td><td> 0.00 kb";
							}
							?>
							</td>
						</td>
					</tr>
					<tr>
						<td colspan="3" class="style4">History</td>
					</tr>
				</table>
				<table style="width: 65%" align="center">
					<tr>
						<td class="daemon_kml">
						<table border="1" cellspacing="0" cellpadding="0" width="100%"><tr><td>
						<table border="1" cellspacing="0" cellpadding="0" width="100%">
							<tr class="style4">
								<td width="33%">Date Created</td>
								<td width="33%">Last Edit Time</td>
								<td width="33%">Size</td>
							</tr>
						<?php
						#var_dump($DGK_folder);
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
							$row_color = 0;
							foreach($DGK_folder as $Day)
							{
								if($row_color == 1)
								{$row_color = 0; $color = "light";}
								else{$row_color = 1; $color = "dark";}
								
								echo '<tr class="'.$color.'">
					<td width="33%"><a class="links" href="'.$Day['kmz_file'].'">'.$Day['file'].'</a></td>
					<td width="33%">'.$Day['kmz_date'].'</td>
					<td width="33%">'.$Day['kmz_size'].'</td>
				</tr>';
							}
						}
						?>
						</table>
						</td></tr></table>
						</td>
						</tr>
					</table></td>
						</tr>
					</table>
			<?php
			footer($_SERVER['SCRIPT_FILENAME']);
		break;

		case "no_daemon":
			?>
			<h2>You do not have the Daemon Option enabled, you will not be able to use this page until you enable it.</h2>
			<?php
			footer($_SERVER['SCRIPT_FILENAME']);
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
							7	=>	"/9.5/" ,# Mid Australia
							8	=>	"/9/"	,# Japan
							9	=>	"/-8/"	,# Pacific Standard Time
							10	=>	"/8/"	,# China
							11	=>	"/-7/"  ,# Mountain Standard Time
							12	=>	"/7/"	,# W Mongolia
							13	=>	"/6.5/" ,# Burma
							14	=>	"/-6/"  ,# Central Standard Time
							15	=>	"/6/"	,# Almaty (Alma ATA), Russia
							16	=>	"/-4/"  ,# Atlantic Time
							17	=>	"/4.5/" ,# Afghanistan
							18	=>	"/4/"   ,# NW Caspian Sea
							19	=>	"/-3.5/",# Newfoundland Time
							20	=>	"/-3/"	,# Greenland Time
							21	=>	"/3.5/" ,# Iran
							22	=>	"/3/"	,# Moscow, Mid-East, E Africa
							23	=>	"/-5/"  ,# Eastern Standard Time
							24	=>	"/5.5/" ,# India
							25	=>	"/5/"	,# Ural Mountains, Russia
							26	=>	"/-2/"  ,# Atlantic Ocean
							27	=>	"/2/"	,# E Europe, E Central Africa
							28	=>	"/-1/"  ,# SE Greenland
							29	=>	"/1/"   ,# Mid Europe - Africa
							30	=>	"/0/"	 # Greenwich, England
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
			#	if($dst == 1){$dst = -1;}
				$str_time = strtotime($file_array['size']);
				$alter_by = ((($TZone+$dst)*60)*60);
				$altered = $str_time+$alter_by;
				$next_run = date("Y-m-d H:i:s", $altered);
				$Zone = " [".$TZone."] ";
				$Zone = preg_replace($timezone_numbers, $timezone_names, $Zone);
				
				echo $next_run.$Zone;
			?>
				</td></tr>
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
			</table><br />
			<table border="1" width="90%">
			<tr class="style4"><th colspan="4">Daemon Status:</TH></tr>
			<?php
			daemon::getdaemonstats();
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
					<tr class="style4"><th>ID</th><th>Filename</th><th>Title</th><th>Date</th><th>size</th></tr>
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
					echo $newArray['title'];
					?>
					</td><td align="center">
					<?php
					echo $newArray['date'];
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
			footer($_SERVER['SCRIPT_FILENAME']);
		break;
	}
}
?>