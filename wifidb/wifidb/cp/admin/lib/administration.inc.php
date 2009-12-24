<?php
error_reporting(E_ALL|E_STRICT);


function dirlist($di, $title, $col1 , $wid, $desc)
{
	$n=1;
	$desc_file = file($desc);
	
	echo '<h1>'.$title.'</h1>';
	echo '<table border="1" width="'.$wid.'%"><tr><td>'.$col1.'</td><td>Description</td></tr>';
	$dirname = $di;
	$dh = opendir($dirname) or die("couldn't open directory");
	while (!(($file = readdir($dh)) == false))
	{
		if ((is_dir("$dirname/$file")))
		{
			if ($file == "." or $file == ".." or $file == "tmp")
			continue;
			
			echo '<tr><td><a href="'.$file.'/">'.$file.'</a></td>';
			echo '<td>'.$desc_file[$n].'</td>';
			$n++;
		}
		if ((is_file("$dirname/$file")))
		{
			if ($file == "." or $file == ".." or $file == "" or $file == "descriptions.txt" or $file == "sample.PNG" or $file == "tmp" or $file == "source.php" or $file == "source.txt")
			continue;

			echo '<tr><td><a href="'.$file.'">'.$file.'</a></td>';
			echo '<td>'.$file.'</td>';
			$n++;
		} 
	}
	closedir($dh);
	echo '</tr></table>';
}

function dirSize($directory, $details = 0)
{
	if($GLOBALS['screen_output'] == '')
	{
		include_once($GLOBALS['half_path'].'/lib/database.inc.php');
		$directory = $GLOBALS['half_path'].'/'.$directory;
	}else
	{
		include_once($GLOBALS['wifidb_install'].'/lib/database.inc.php');
		$directory = $GLOBALS['wifidb_install'].'/'.$directory;
	}
	$size	=	0;
	$sizes	=	array();
	$num	=	0;
	$dh		=	opendir($directory) or die("couldn't open directory");
	while(!(($file = readdir($dh)) == false))
	{
		if($file == '.svn' or $file == '.' or $file == '..'){continue;}
				
		$typepath = $directory.$file;
	#	echo filetype ($typepath)."<br>";
		if(filetype ($typepath) == 'file')
		{
			$file_size = dos_filesize("$directory/$file");
			if($details)
			{
				$size += $file_size;
				$sizes[] = $file_size;
				$num++;
			}
		}else
		{
			$dh1 = opendir($typepath) or die("couldn't open directory");
			while(!(($file1 = readdir($dh1)) == false))
			{
				if($file1 == '.svn' or $file1 == '.' or $file1 == '..'){continue;}
				
				$typepath1 = $typepath.'/'.$file1;
			#	echo $typepath1."<BR>";
				$file_size = dos_filesize($typepath);
				if($details)
				{
					$size   +=  $file_size;
					$sizes[] = $file_size;
					$num++;
			#		echo $file1.'<BR>';
			#		dump($sizes);
				}
			}
		}
    }
	if($details)
	{
		rsort($sizes);
		$count = count($sizes)-1;
		$max = $sizes[0];
		$min = $sizes[$count];
		$avg = round($size/$num, 2);
	#	echo $avg.' = '.$size.' / '.$num."<BR>";
		return array($size, $num, $max, $min, $avg);
	}else
	{
		return $size;
	}
}



class admin
{

	function overview($mode = '')
	{
		
		include_once('../../lib/config.inc.php');
		include_once('../../lib/database.inc.php');
		
		$conn			= 	$GLOBALS['conn'];
		$db				= 	$GLOBALS['db'];
		$db_st			= 	$GLOBALS['db_st'];
		$wtable			=	$GLOBALS['wtable'];
		$users_t		=	$GLOBALS['users_t'];
		$gps_ext		=	$GLOBALS['gps_ext'];
		$files			=	$GLOBALS['files'];
		$user_logins_table = $GLOBALS['user_logins_table'];
		$root			= 	$GLOBALS['root'];
		$half_path		=	$GLOBALS['half_path'];
		
		switch($mode)
		{
			case "aps":
			
			break;
			
			case "geo":
			
			break;
			
			case "users":
			
			break;
			
			case "daemon":
			
			break;
			
			default:

				
				####################################
				?>
				<table WIDTH=85% BORDER=1 CELLPADDING=2 CELLSPACING=0>
					<tr>
						<th colspan="4" class="style1"><strong><em>Statistics</em></strong></th>
					</tr>
					<tr>
						<td class="style2" colspan="2" style="width: 50%" ></td>
						<td class="style2" colspan="2" ></td>
					</tr>
					<tr>
						<th class="style3" style="width: 150px">Number of APs</th>
						<td class="dark" style="width: 491px"><strong><?php echo $total_aps; ?></strong></td>
						<th class="style3" style="width: 200px">Most Common SSID</th>
						<td class="dark"><strong><?php echo $common_ssid; ?></strong></td>
					</tr>
					<tr>
						<th class="style3" style="width: 150px; height: 26px;"><strong>Open</strong></th>
						<td class="dark" style="width: 491px; height: 26px"><strong><?php echo $open_aps; ?></strong></td>
						<th class="style3" style="width: 200px; height: 26px"><strong>AP with most GPS</strong></th>
						<td class="dark" style="height: 26px"><b><?php echo $ap_gps; ?></b></td>
					</tr>
					<tr>
						<th class="style3" style="width: 150px" ><strong>WEP</strong></th>
						<td class="dark" style="width: 491px" ><strong><?php echo $wep_aps; ?></strong></td>
						<th class="style3" style="width: 200px" ><strong>User with most APs</strong></th>
						<td class="dark"><b><?php echo $user_most_aps; ?></b></td>
					</tr>
					<tr>
						<th class="style3" style="width: 150px">Secure</th>
						<td class="dark" style="width: 491px"><b><?php echo $secure_aps; ?></b></td>
						<th class="style3" style="width: 200px">User with most Geocaches</th>
						<td class="dark"><b><?php echo $user_geocache; ?></b></td>
					</tr>
					<tr>
						<td class="style3" style="width: 150px"></td>
						<td class="dark" style="width: 491px"></td>
						<th class="style3" style="width: 200px"><strong>Number of Uploaded Files<br><font size="2">(Total / average / largest / smallest)</font></strong></td>
						<td class="dark"><b><?php echo $files_uploaded; ?><br><font size="2">(<?php echo $files_sizes_total." / ".$file_avg." / ".$file_max." / ".$file_min;?>)</font></b></td>
					</tr>
					<tr>
						<td class="style3" style="width: 150px"></td>
						<td class="dark" style="width: 491px"></td>
						<th class="style3" style="width: 200px"><strong>Graphs Generated<br><font size="2">(Total / average / largest / smallest)</font></strong></th>
						<td class="dark"><b><?php echo $graph_num; ?><br><font size="2">(<?php echo $graph_size." / ".$graph_avg." / ".$graph_max." / ".$graph_min;?>)</font></b></td>
					</tr>
					<tr>
						<td class="style3" style="width: 150px"></td>
						<td class="dark" style="width: 491px"></td>
						<th class="style3" style="width: 200px"><strong>KML Files Exported<br><font size="2">(Total / average / largest / smallest)</font></strong></th>
						<td class="dark"><b><?php echo $kmz_num; ?><br><font size="2">(<?php echo $kmz_size." / ".$kmz_avg." / ".$kmz_max." / ".$kmz_min;?>)</font></b></td>
					</tr>
				</table>
				<?php
			break;
		}
	}
	
	
	
	function uandp($mode = '')
	{
		$root		= 	$GLOBALS['root'];
		$half_path	=	$GLOBALS['half_path'];
		switch($mode)
		{
			case "man_users":
			
			break;
			
			case "man_groups":
			
			break;
			
			case "man_titles":
			
			break;
			
			default:
				echo "Users and Permissions, Overview";
			break;
		}
	}
	
	
	
	function maint($mode = '')
	{
		$root		= 	$GLOBALS['root'];
		$half_path	=	$GLOBALS['half_path'];
		switch($mode)
		{
			case "clean_tmp":
				echo format_size(dirSize($half_path.'tmp/'), $round = 2);
			break;
			
			case "clean_upload":
				echo format_size(dirSize($half_path.'import/up/'), $round = 2);
			break;
			
			case "clean_signal":
				echo format_size(dirSize($half_path.'out/graph/'), $round = 2);
			break;
			
			case "check_dates":
				
			break;
			
			case "check_cords":
				
			break;
			
			default:
				echo "Maintenance, Overview";
			break;
		}
	}
	
	
	
	function sys($mode = '')
	{
		$root		= 	$GLOBALS['root'];
		$half_path	=	$GLOBALS['half_path'];
		switch($mode)
		{
			case "daemon":
			
			break;
			
			case "daemon_config":
			
			break;
			
			case "db_config":
			
			break;
			
			case "updates":
			
			break;
			
			default:
				
				
				
				
				
			break;
		}
	}

}
?>