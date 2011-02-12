<?php
include('../lib/database.inc.php');
include('../lib/config.inc.php');

$func			= '';
$refresh_post	= '';
$tz_post		= '';
$root = $GLOBALS['root'];
$hosturl = $GLOBALS['hosturl'];

if( !isset($_GET['func']) ) { $_GET['func'] = ""; }

$func = strip_tags(addslashes($_GET['func']));

switch($func)
{
	case 'refresh':
		if( (!isset($_POST['refresh'])) or $_POST['refresh']=='' ) { $_POST['refresh'] = "wifidb"; }
		$refresh_post = strip_tags(addslashes($_POST['refresh']));
		setcookie( 'wifidb_refresh' , $refresh_post , (time()+($timeout)), "/".$root."/opt/scheduling.php" );
		#echo $refresh_post."<BR>";
		header('Location: '.$hosturl.$root.'/opt/scheduling.php');
	break;

}
$TZone = (@$_COOKIE['wifidb_client_timezone'] ? @$_COOKIE['wifidb_client_timezone'] : $default_timezone);
$dst = (@$_COOKIE['wifidb_client_dst']!='' ? @$_COOKIE['wifidb_client_dst'] : -1);
$refresh = (@$_COOKIE['wifidb_refresh']!='' ? @$_COOKIE['wifidb_refresh'] : $default_refresh);

pageheader("Scheduling Page");

$func = '';
if(!isset($_GET['func'])){$_GET['func']="";}
$func = strip_tags(addslashes($_GET['func']));
if($GLOBALS['wifidb_tools'] == 'NO PATH' or $GLOBALS['wifidb_tools'] == NULL){$func = "no_daemon";}
if(is_string($func))
{
	$daemon = new daemon();
	switch($func)
	{
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
					?><tr class="sub_head"><th>ID</th><th>Filename</th><th>Date</th><th>user</th><th>title</th></tr>
					<tr class="<?php echo $class;?>"><td align="center">
					<?php
					echo $newArray['id'];
					?>
					</td><td align="center">
					<a class="links" href="../opt/userstats.php?func=useraplist&row=<?php echo $newArray["user_row"];?>"><?php echo html_entity_decode($newArray['file']);?></a>
					</td><td align="center">
					<?php
					echo $newArray['date'];
					?>
					</td><td align="center">
					<a class="links" href ="../opt/userstats.php?func=alluserlists&user=<?php echo $newArray["user"];?>"><?php echo $newArray["user"];?></a>
					</td><td align="center">
					<?php
					echo $newArray['title'];
					?></td></tr>
					<tr><th></th><th class="sub_head">Total AP's</th><th class="sub_head">Total GPS</th><th class="sub_head">Size</th><th class="sub_head">Hash Sum</th></tr>
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
			if(@$DATES[0] == ''){$today = $date;}else{$today = $DATES[0];}
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
					<tr class="light">
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
					<tr class="light">
						<td class="daemon_kml">Newest AP KML Last Edit: </td>
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
					<tr class="light">
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
					<tr class="light">
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
					<tr>
						<td colspan="3" class="dark">
						<table align="center" border="1" cellspacing="0" cellpadding="0" width="50%">
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
								<tr>
									<td colspan='3'>There have been no KMZ files created.</td>
								</tr>
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
						</td></tr>
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
			include $GLOBALS['wifidb_tools']."/daemon/config.inc.php";
			echo '<meta http-equiv="refresh" content="'.$refresh.'"><table border="1" width="90%"><tr class="style4"><th colspan="4">Scheduled Imports</th></tr>';
			mysql_select_db($db,$conn);
			$sql = "SELECT * FROM `$db`.`settings` WHERE `table` LIKE 'files'";
			$result = mysql_query($sql, $conn) or die(mysql_error());
			$file_array = mysql_fetch_array($result);		
			?>
				<tr><td class="style3">Next Import scheduled on:</td><td class="light"><?php echo $file_array['size'];?> UTC</td><td class="light">
			<?php
				if($dst == 1){$dst = 0;}
			#	echo "Before: ".$file_array['size']."<BR>";
				$str_time = strtotime($file_array['size']);
			#	echo "Convert: ".$str_time."<BR>";
				$alter_by = ((($TZone+$dst)*60)*60);
			#	echo "CALC: ".$alter_by."<BR>";
				$altered = $str_time+$alter_by;
			#	echo "ADD: ".$altered."<BR>";
				$next_run = date("Y-m-d H:i:s", $altered);
				echo $next_run.'  [ '.getTZ('-5').' ]';
			?>
				</td></tr>
				<tr><td  class="style3" colspan="1">Select Refresh Rate:</td><td class="light" colspan="2">
					<?php #echo $refresh."<BR>"; ?>
					<form action="scheduling.php?func=refresh" method="post" enctype="multipart/form-data">
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
			$daemon->getdaemonstats();
			?>
			</table>
			<br>
			<?php
			if($func == 'waiting')
			{
			    $sql = "SELECT * FROM `$db`.`files_tmp` ORDER BY `date` asc";
			}else
			{
			    $sql = "SELECT * FROM `$db`.`files_tmp` ORDER BY `date` asc limit 20";
			}
			$result_1 = mysql_query($sql, $conn) or die(mysql_error($conn));
			$total_rows = mysql_num_rows($result_1);
			if($total_rows > 10)
			{
				echo '<a class="links" href="scheduling.php?func=waiting">View other files waiting for import.</a><br>';
			}
			
			$sql1 = "SELECT * FROM `$db`.`files`";
			$result2 = mysql_query($sql1, $conn) or die(mysql_error($conn));
			$done_rows = mysql_num_rows($result2);
			if($done_rows > 0)
			{
				echo '<a class="links" href="scheduling.php?func=done">View other files that have finished importing.</a><br>';
			}
			?>
			<br>
			<table border="1" width="90%"><tr class="style4"><th border="1" colspan="7" align="center">Files waiting for import</th></tr><?php
			
			if($total_rows === 0)
			{
				?><tr class="light"><td border="1" colspan="7" align="center">There are no files waiting to be imported, Go and import a file</td></tr></table><?php
			}else
			{
				?><tr align="center"><td border="1"><br><?php
				while ($newArray = mysql_fetch_array($result_1))
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
					$id = $newArray['id'];
					$sql1 = "select * from `$db`.`$wtable` where `id` = '$id'";
					$result1 = mysql_query($sql1, $conn);
					$newArray1 = mysql_fetch_array($result1);
					list($ssid_ptb) = make_ssid($newArray1["ssid"]);
					$table = $ssid_ptb.'-'.$newArray1["mac"].'-'.$newArray1["sectype"].'-'.$newArray1["radio"].'-'.$newArray1['chan'].$gps_ext;
					$sql_gps = "select * from `$db_st`.`$table` where `lat` NOT LIKE 'N 0.0000' limit 1";
					#echo $sql_gps;
					$resultgps = mysql_query($sql_gps, $conn);
					$lastgps = @mysql_fetch_array($resultgps);
					#var_dump($lastgps);
					$lat_check = explode(" ", $lastgps['lat']);
					$lat_c = $lat_check[1]+0;
					if($lat_c != "0"){$gps_yes = 1;}else{$gps_yes = 0;}
					?>
					</td><td align="center">
					<?php
					echo html_entity_decode($newArray['file']);
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
						</td>
						<td align="center">
					<?php
					echo $newArray['user'];
					?>
						</td>
					<?php
					if($newArray['ap'] == NULL)
					{
					    $ssid = "<td colspan='2' align='center'>Not being imported</td>";

					}else
					{
					    if($gps_yes)
					    {
						$ssid = '<td align="center">'.$newArray['ap'].'<img width="20px" src="../img/globe_on.png"></td>';
					    }
					    else
					    {
						$ssid = '<td align="center"><table align="center"><tr><td valign="center" align="right">'.$newArray['ap'].'</td><td valign="center" align="left"><img width="20px" src="../img/globe_off.png"></td></tr></table></td>';
					    }
					}
					echo $ssid;
					
					if($newArray['tot'] == NULL){$tot = "";}else{$tot = '<td align="center">'.$newArray['tot'].'</td>';}
					echo $tot;
					?>
					    </tr>
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