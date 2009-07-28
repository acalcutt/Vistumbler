<?php
include('../lib/config.inc.php');
$func = '';
$refresh_post = '';

if( !isset($_GET['func']) ) { $_GET['func'] = ""; }
$func = strip_tags(addslashes($_GET['func']));

if($func == 'change')
{
	if( (!isset($_POST['refresh'])) or $_POST['refresh']=='' ) { $_POST['refresh'] = "wifidb"; }
	$refresh_post = strip_tags(addslashes($_POST['refresh']));
	setcookie( 'wifidb_refresh' , $refresh_post , (time()+(86400 * 7)), "/".$root."/opt/scheduling.php" ); // 86400 = 1 day
	header('Location: scheduling.php?token='.$_SESSION['token']);
}
$refresh = ($_COOKIE['wifidb_refresh']!='' ? $_COOKIE['wifidb_refresh'] : $default_refresh);

include('../lib/database.inc.php');
pageheader("Scheduling Page");


####################
function getdaemonstats()
{
	$os = PHP_OS;
	if ( $os[0] == 'L')
	{
		#echo $os."<br>";
		$output = array();
		$WFDBD_PID = "/var/run/wifidbd.pid";
		if(file_exists($WFDBD_PID))
		{
			$pid_open = file($WFDBD_PID);
			exec('ps vp '.$pid_open[0] , $output, $sta);
			if(isset($output[1]))
			{
				?><tr class="style4"><th colspan="4">Linux Based WiFiDB Daemon</th></tr><tr class="style4"><th>PID</th><th>TIME</th><th>Memory</th><th>CMD</th></tr><?php
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
#			echo $ps_stats;
				$ps_Sta_exp = explode("|", $ps_stats);
				?><tr align="center" bgcolor="green"><td><?php echo str_replace(' ?',"",$ps_Sta_exp[0]);?></td><td><?php echo $time;?></td><td><?php echo $mem."%";?></td><td><?php echo $CMD;?></td></tr><?php
			}else
			{
				?><tr class="style4"><th colspan="4">Linux Based WiFiDB Daemon</th></tr>
				<tr align="center" bgcolor="red"><td colspan="4">Linux Based WiFiDB Daemon is not running!</td><?php
			}
		}
	}elseif( $os[0] == 'W')
	{
		$output = array();
		$WFDBD_PID = "C:\CLI\daemon\wifidbd.pid";
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
		
		default:
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
				<tr><td>Next Import scheduled on:</td><td><?php echo $file_array['size'];?> GMT</td><td><?php $nextrun = date("Y-m-d H:i:s", (strtotime($file_array['size'])-18000)); echo $nextrun; ?> EST</td></tr>
				<tr><td colspan="1">Select Refresh Rate:</td><td colspan="2">
					<form action="scheduling.php?func=change&token=<?php echo $_SESSION['token'];?>" method="post" enctype="multipart/form-data">
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
	}
}
echo "<BR>";
footer($_SERVER['SCRIPT_FILENAME']);
?>