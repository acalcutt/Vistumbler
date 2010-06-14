<?php
##-----------------------------##
##-----------------------------##
##-----------------------------##
function recur_del_dir($Folder)
{
	$del_dir_file_flag = 1;
	$dh	= opendir($Folder) or die("couldn't open directory");
	while(!(($file = readdir($dh)) == false))
	{
		if($file =='.' or $file =='..'){continue;}
		if($row){$style="light";$row=0;}else{$style="dark";$row=1;}
		if(filetype($Folder.'/'.$file) == 'dir')
		{
			if(recur_del_dir($Folder.'/'.$file))
			{
				$del_dir_file_flag = 1;
			}
			else
			{
				$del_dir_file_flag = 0;
			}
		}else
		{
			if(unlink($Folder.'/'.$file))
			{
				?>
				<tr class="<?php echo $style;?>">
					<td><?php echo "File ($Folder) Deleted!"; ?></td>
				</tr>
				<?php
			}else
			{
				$del_dir_file_flag = 0;
			}
		}
	}
	if($del_dir_file_flag)
	{
		if(rmdir($Folder))
		{
			?>
			<tr class="<?php echo $style;?>">
				<td><?php echo "Folder ($Folder) Deleted!"; ?></td>
			</tr>
			<?php
			return 1;
		}
		else
		{
			?>
			<tr class="bad">
				<th><?php echo "Folder ($Folder) could not be deleted!"; ?></th>
			</tr>
			<?php
			return 0;
		}
	}else
	{
		?>
		<tr class="bad">
			<th><?php echo "Folder ($del_dir) could not be deleted! Files still exist!"; ?></th>
		</tr>
		<?php
		return 0;
	}
}


##-----------------------------##
##-----------------------------##
##-----------------------------##
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
##-----------------------------##
##-----------------------------##
##-----------------------------##
function dirSize($directory)
{
	if($GLOBALS['screen_output'] == 'CLI')
	{
		include_once($GLOBALS['wifidb_install'].'/lib/database.inc.php');
		$dir_exp = explode("/", $directory);
		$halfpath_exp = explode("/", $GLOBALS['wifidb_install']);
		
	#	echo $GLOBALS['wifidb_install']."\r\n";foreach($halfpath_exp as $key=>$val){echo "$key => $val\r\n";}echo "\r\n";foreach( $dir_exp as $key=>$dir){echo $key." => $dir\r\n";}
		
		$first_dir = 0;
		$first_half = 0;
		if($dir_exp[0]==''){ $first_dir = 1;}
		if($halfpath_exp[0]==''){ $first_half = 1;}
		if($dir_exp[$first_dir] === $halfpath_exp[$first_half]){$directory = $directory;}
		else{$directory = $GLOBALS['wifidb_install'].$directory;}
		
	#	echo $directory."<br>\r\n";
	}else
	{
		include_once($GLOBALS['half_path'].'/lib/database.inc.php');
		$dir_exp = explode("/", $directory);
		$halfpath_exp = explode("/", $GLOBALS['half_path']);
		
		$first_dir = 0;
		$first_half = 0;
		if($dir_exp[0]==''){ $first_dir = 1;}
		if($halfpath_exp[0]==''){ $first_half = 1;}
		if($dir_exp[$first_dir] === $halfpath_exp[$first_half]){$directory = $directory;}
		else{$directory = $GLOBALS['wifidb_install'].$directory;}
		
	#	echo $directory."<br>\r\n";
	}
	$size	=	0;
	$sizes	=	array();
	$num	=	0;
	$dh		=	opendir($directory) or die("couldn't open directory - $directory\r\n ");
	while(!(($file = readdir($dh)) == false))
	{
		if($file == '.svn' or $file == '.' or $file == '..'){continue;}
		
		$typepath = $directory.$file;
	#	dump(stat($typepath));
		$filetype = filetype($typepath);
		#echo "$filetype <------ if this says dir WTF ?!\r\n";
		if($filetype == 'file')
		{
			$file_size = dos_filesize("$directory/$file");
			$size += $file_size;
			$sizes[] = $file_size;
	#		echo '$sizes[$num ->'.$num.' - '.$file_size.'] '.$size.'<br>';
			$num++;
		}else
		{
			#echo $typepath." <------ if this is a file something is wrong.....\r\n";
			list($sizea) = dirSize($typepath.'/');
			$size   +=  $sizea;
			$sizes[] = $sizea;
			$num++;
		#	$dh1 = opendir($typepath) or die("couldn't open directory");
		#	while(!(($file1 = readdir($dh1)) == false))
		#	{
		#		if($file1 == '.svn' or $file1 == '.' or $file1 == '..'){continue;}
		#		$typepath1 = $typepath.'/'.$file1;
		#		echo $typepath1."<BR>";
		#		$file_size = dos_filesize($typepath1);
		#		echo $file1.'<BR>';
		#		dump($sizes);
		#	}
		}
    }
	if($num > 0)
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
##-----------------------------##
##-----------------------------##
##-----------------------------##
function user_alph_row($func, $mode, $first, $data)
{
	$conn			= 	$GLOBALS['conn'];
	$db				= 	$GLOBALS['db'];
	$user_logins_table = $GLOBALS['user_logins_table'];
	foreach(range('a', 'z') as $letter)
	{
	#	echo $letter."--";
		$sql_a = "SELECT `id` FROM `$db`.`$user_logins_table` WHERE `disabled` != '1' AND `username` LIKE '".$letter."%'";
		$return_a = mysql_query($sql_a, $conn);
		$rows_a = mysql_num_rows($return_a);
		$results[$letter] = $rows_a;
	#	if($letter == 'a'){echo $rows_a;}
	}

	$sql_all = "SELECT `id` FROM `$db`.`$user_logins_table` WHERE `disabled` != '1'";
	$ret_all = mysql_query($sql_all, $conn);
	$rows_all =  mysql_num_rows($ret_all);

	$sql_num = "SELECT `id` FROM `$db`.`$user_logins_table` WHERE `disabled` != '1' AND `username` REGEXP '[0-9][[:>:]]'";
	$ret_num = mysql_query($sql_num, $conn);
	$rows_num =  mysql_num_rows($ret_num);

	$tracker = 0;
	$user_number = 0;
	if($first == '')
	{
		$sql0 = "SELECT `id`,`username`,`website`,`admins`,`devs`,`mods`,`users`,`last_login`,`join_date` FROM `$db`.`$user_logins_table` WHERE `disabled` != '1' AND `username` NOT LIKE 'Admin'";
	}elseif($first == '#')
	{
		$sql0 = "SELECT `id`,`username`,`website`,`admins`,`devs`,`mods`,`users`,`last_login`,`join_date` FROM `$db`.`$user_logins_table` WHERE `disabled` != '1' AND `username` REGEXP '[0-9][[:>:]]' AND `username` NOT LIKE 'Admin'";
	}else
	{
		$sql0 = "SELECT `id`,`username`,`website`,`admins`,`devs`,`mods`,`users`,`last_login`,`join_date` FROM `$db`.`$user_logins_table` WHERE `disabled` != '1' AND `username` LIKE '".$first."%' AND `username` NOT LIKE 'Admin'";
	}

	#	echo $sql0."<BR>";
	$result = mysql_query($sql0, $conn);
	$rows = mysql_num_rows($result);
	?>
	<tr>
		<td align="center" colspan="6" class="style3">
			<?php if($rows_all > 0 ) { ?><a class="links<?php if($first==""){echo "_s";}?>" href="?func=<?php echo $func; ?>&mode=<?php echo $mode; ?>&first=&">All</a><?php }else{ ?><i>All</i><?php } ?>&nbsp;
			<?php if($results["a"] > 0 ) { ?><a class="links<?php if($first=="a"){echo "_s";}?>" href="?func=<?php echo $func; ?>&mode=<?php echo $mode; ?>&first=a">A</a><?php }else{ ?><i>A</i><?php } ?>&nbsp; 
			<?php if($results["b"] > 0 ) { ?><a class="links<?php if($first=="b"){echo "_s";}?>" href="?func=<?php echo $func; ?>&mode=<?php echo $mode; ?>&first=b">B</a><?php }else{ ?><i>B</i><?php } ?>&nbsp; 
			<?php if($results["c"] > 0 ) { ?><a class="links<?php if($first=="c"){echo "_s";}?>" href="?func=<?php echo $func; ?>&mode=<?php echo $mode; ?>&first=c">C</a><?php }else{ ?><i>C</i><?php } ?>&nbsp; 
			<?php if($results["d"] > 0 ) { ?><a class="links<?php if($first=="d"){echo "_s";}?>" href="?func=<?php echo $func; ?>&mode=<?php echo $mode; ?>&first=d">D</a><?php }else{ ?><i>D</i><?php } ?>&nbsp; 
			<?php if($results["e"] > 0 ) { ?><a class="links<?php if($first=="e"){echo "_s";}?>" href="?func=<?php echo $func; ?>&mode=<?php echo $mode; ?>&first=e">E</a><?php }else{ ?><i>E</i><?php } ?>&nbsp; 
			<?php if($results["f"] > 0 ) { ?><a class="links<?php if($first=="f"){echo "_s";}?>" href="?func=<?php echo $func; ?>&mode=<?php echo $mode; ?>&first=f">F</a><?php }else{ ?><i>F</i><?php } ?>&nbsp; 
			<?php if($results["g"] > 0 ) { ?><a class="links<?php if($first=="g"){echo "_s";}?>" href="?func=<?php echo $func; ?>&mode=<?php echo $mode; ?>&first=g">G</a><?php }else{ ?><i>G</i><?php } ?>&nbsp; 	
			<?php if($results["h"] > 0 ) { ?><a class="links<?php if($first=="h"){echo "_s";}?>" href="?func=<?php echo $func; ?>&mode=<?php echo $mode; ?>&first=h">H</a><?php }else{ ?><i>H</i><?php } ?>&nbsp;
			<?php if($results["i"] > 0 ) { ?><a class="links<?php if($first=="i"){echo "_s";}?>" href="?func=<?php echo $func; ?>&mode=<?php echo $mode; ?>&first=i">I</a><?php }else{ ?><i>I</i><?php } ?>&nbsp; 
			<?php if($results["j"] > 0 ) { ?><a class="links<?php if($first=="j"){echo "_s";}?>" href="?func=<?php echo $func; ?>&mode=<?php echo $mode; ?>&first=j">J</a><?php }else{ ?><i>J</i><?php } ?>&nbsp; 
			<?php if($results["k"] > 0 ) { ?><a class="links<?php if($first=="k"){echo "_s";}?>" href="?func=<?php echo $func; ?>&mode=<?php echo $mode; ?>&first=k">K</a><?php }else{ ?><i>K</i><?php } ?>&nbsp; 
			<?php if($results["l"] > 0 ) { ?><a class="links<?php if($first=="l"){echo "_s";}?>" href="?func=<?php echo $func; ?>&mode=<?php echo $mode; ?>&first=l">L</a><?php }else{ ?><i>L</i><?php } ?>&nbsp; 
			<?php if($results["m"] > 0 ) { ?><a class="links<?php if($first=="m"){echo "_s";}?>" href="?func=<?php echo $func; ?>&mode=<?php echo $mode; ?>&first=m">M</a><?php }else{ ?><i>M</i><?php } ?>&nbsp; 
			<?php if($results["n"] > 0 ) { ?><a class="links<?php if($first=="n"){echo "_s";}?>" href="?func=<?php echo $func; ?>&mode=<?php echo $mode; ?>&first=n">N</a><?php }else{ ?><i>N</i><?php } ?>&nbsp; 
			<?php if($results["o"] > 0 ) { ?><a class="links<?php if($first=="o"){echo "_s";}?>" href="?func=<?php echo $func; ?>&mode=<?php echo $mode; ?>&first=o">O</a><?php }else{ ?><i>O</i><?php } ?>&nbsp; 
			<?php if($results["p"] > 0 ) { ?><a class="links<?php if($first=="p"){echo "_s";}?>" href="?func=<?php echo $func; ?>&mode=<?php echo $mode; ?>&first=p">P</a><?php }else{ ?><i>P</i><?php } ?>&nbsp; 
			<?php if($results["q"] > 0 ) { ?><a class="links<?php if($first=="q"){echo "_s";}?>" href="?func=<?php echo $func; ?>&mode=<?php echo $mode; ?>&first=q">Q</a><?php }else{ ?><i>Q</i><?php } ?>&nbsp; 
			<?php if($results["r"] > 0 ) { ?><a class="links<?php if($first=="r"){echo "_s";}?>" href="?func=<?php echo $func; ?>&mode=<?php echo $mode; ?>&first=r">R</a><?php }else{ ?><i>R</i><?php } ?>&nbsp; 
			<?php if($results["s"] > 0 ) { ?><a class="links<?php if($first=="s"){echo "_s";}?>" href="?func=<?php echo $func; ?>&mode=<?php echo $mode; ?>&first=s">S</a><?php }else{ ?><i>S</i><?php } ?>&nbsp; 
			<?php if($results["t"] > 0 ) { ?><a class="links<?php if($first=="t"){echo "_s";}?>" href="?func=<?php echo $func; ?>&mode=<?php echo $mode; ?>&first=t">T</a><?php }else{ ?><i>T</i><?php } ?>&nbsp; 
			<?php if($results["u"] > 0 ) { ?><a class="links<?php if($first=="u"){echo "_s";}?>" href="?func=<?php echo $func; ?>&mode=<?php echo $mode; ?>&first=u">U</a><?php }else{ ?><i>U</i><?php } ?>&nbsp;						
			<?php if($results["v"] > 0 ) { ?><a class="links<?php if($first=="v"){echo "_s";}?>" href="?func=<?php echo $func; ?>&mode=<?php echo $mode; ?>&first=v">V</a><?php }else{ ?><i>V</i><?php } ?>&nbsp; 
			<?php if($results["w"] > 0 ) { ?><a class="links<?php if($first=="w"){echo "_s";}?>" href="?func=<?php echo $func; ?>&mode=<?php echo $mode; ?>&first=w">W</a><?php }else{ ?><i>W</i><?php } ?>&nbsp; 
			<?php if($results["x"] > 0 ) { ?><a class="links<?php if($first=="x"){echo "_s";}?>" href="?func=<?php echo $func; ?>&mode=<?php echo $mode; ?>&first=x">X</a><?php }else{ ?><i>X</i><?php } ?>&nbsp; 
			<?php if($results["y"] > 0 ) { ?><a class="links<?php if($first=="y"){echo "_s";}?>" href="?func=<?php echo $func; ?>&mode=<?php echo $mode; ?>&first=y">Y</a><?php }else{ ?><i>Y</i><?php } ?>&nbsp; 
			<?php if($results["z"] > 0 ) { ?><a class="links<?php if($first=="z"){echo "_s";}?>" href="?func=<?php echo $func; ?>&mode=<?php echo $mode; ?>&first=z">Z</a><?php }else{ ?><i>Z</i><?php } ?>&nbsp; 
			<?php if($rows_num > 0 ) { ?><a class="links<?php if($first=="num"){echo "_s";}?>" href="?func=<?php echo $func; ?>&mode=<?php echo $mode; ?>&first=num">#</a><?php }else{ ?><i>#</i><?php } ?>
		</td>
	</tr>
	<?php
}


##-----------------------------##
##-----------------------------##
##-----------------------------##
function set_flow($func, $mode)
{
	$func = addslashes(strtolower($func));
	$mode = addslashes(strtolower($mode));
	?>
	<tr>
		<td colspan="1" class="<?php if($func == 'overview' or $func == ''){echo 'cp_select_coloum';}else{echo "light";}?>">
			<font size="2">
				<a class="links<?php if(($mode == 'aps' or $mode == 'apstats' or $mode == 'aphdata') and $func == 'overview'){echo '_s';} ?>" href="?func=overview&mode=aps">Access Points</a> -
				<a class="links<?php if(($mode == 'geo' or $mode == 'mcstats' or $mode == 'mchdata') and $func == 'overview'){echo '_s';} ?>" href="?func=overview&mode=geo">Geocaches</a><br>
				<a class="links<?php if(($mode == 'users') and $func == 'overview'){echo '_s';} ?>" href="?func=overview&mode=users">Users</a> -
				<a class="links<?php if(($mode == 'daemon' or $mode == 'daemon_hist') and $func == 'overview'){echo '_s';} ?>" href="?func=overview&mode=daemon">Daemon Stats</a><br>
				<a class="links<?php if(($mode == 'graphs') and $func == 'overview'){echo '_s';} ?>" href="?func=overview&mode=graphs">Graphs</a>
		</td>
		<td colspan="1" class="<?php if($func == 'uandp'){echo 'cp_select_coloum';}else{echo "light";}?>">
			<font size="2">
				<a class="links<?php if(($mode == 'man_users' or $mode == 'man_user_edit') and $func == 'uandp'){echo '_s';} ?>" href="?func=uandp&mode=man_users">Users</a> - 
				<a class="links<?php if(($mode == 'man_groups' or $mode == 'man_grp_edit') and $func == 'uandp'){echo '_s';} ?>" href="?func=uandp&mode=man_groups">Groups</a> - 
				<a class="links<?php if(($mode == 'man_titles' or $mode == 'man_titles_edit') and $func == 'uandp'){echo '_s';} ?>" href="?func=uandp&mode=man_titles">Titles</a>
			</font>
		</td>
		<td colspan="1" class="<?php if($func == 'maint'){echo 'cp_select_coloum';}else{echo "light";}?>">
			<font size="2">
				<a class="links<?php if(($mode == 'clean_tmp' or $mode == 'clean_tmp_proc') and $func == 'maint'){echo '_s';} ?>" href="?func=maint&mode=clean_tmp">Temp Folder</a> - 
				<a class="links<?php if(($mode == 'clean_upload' or $mode == 'clean_upload_proc') and $func == 'maint'){echo '_s';} ?>" href="?func=maint&mode=clean_upload">Upload Folder</a><br>
				<a class="links<?php if(($mode == 'clean_signal' or $mode == 'clean_signal_proc') and $func == 'maint'){echo '_s';} ?>" href="?func=maint&mode=clean_signal">Graphs Folder</a>
			</font>
		</td>
		<td colspan="1" class="<?php if($func == 'system'){echo 'cp_select_coloum';}else{echo "light";}?>">
			<font size="2">
				<a class="links<?php if(($mode == 'daemon' or $mode == 'daemon_proc') and $func == 'system'){echo '_s';} ?>" href="?func=system&mode=daemon">Daemon Ctl</a> - 
				<a class="links<?php if(($mode == 'daemon_config' or $mode == 'daemon_cfgproc') and $func == 'system'){echo '_s';} ?>" href="?func=system&mode=daemon_config">Daemon Cfg</a><br>
				<a class="links<?php if(($mode == 'db_config' or $mode == 'db_config_proc') and $func == 'system'){echo '_s';} ?>" href="?func=system&mode=db_config">DB Cfg</a> -
				<a class="links<?php if(($mode == 'updates' or $mode == 'updates_proc') and $func == 'system'){echo '_s';} ?>" href="?func=system&mode=updates">Updates</a>
			</font>
		</td>
	</tr>
	<?php
}

##-----------------------------##
##-----------------------------##
##-----------------------------##
##-----------------------------##
##-----------------------------##
##-----------------------------##
class admin
{
	##-----------------------------##
	##-----------------------------##
	##-----------------------------##
	function overview($mode = '')
	{
		
		include_once('../../lib/config.inc.php');
		include_once('../../lib/database.inc.php');
		
		$hosturl		= 	$GLOBALS['hosturl'];
		$conn			= 	$GLOBALS['conn'];
		$db				= 	$GLOBALS['db'];
		$db_st			= 	$GLOBALS['db_st'];
		$DB_stats		= 	$GLOBALS['DB_stats_table'];
		$daemon_perf_table =	$GLOBALS['daemon_perf_table'];
		$wtable			=	$GLOBALS['wtable'];
		$users_t		=	$GLOBALS['users_t'];
		$share_cache	=	$GLOBALS['share_cache'];
		$gps_ext		=	$GLOBALS['gps_ext'];
		$files			=	$GLOBALS['files'];
		$user_logins_table = $GLOBALS['user_logins_table'];
		$root			= 	$GLOBALS['root'];
		$half_path		=	$GLOBALS['half_path'];
		$theme			=	$GLOBALS['theme'];
		$seed			=	$GLOBALS['login_seed'];
		$date_format	=	"Y-m-d H:i:s";
		
		switch($mode)
		{
			case "dbhdata":
				?>
				<table WIDTH=85% BORDER=1 CELLPADDING=2 CELLSPACING=0>
					<tr>
						<th colspan="25" class="style1"><strong><em>Database Historical Statistics</em></strong></th>
					</tr>
					<tr>
						<th colspan="10" class="style1"><strong><em><a href="?func=overview&mode=graphs&data=dbstats" class="links">Graph</a></em></strong></th>
					</tr>
					<tr class="style3">
						<th>ID</th><th>Timestamp</th><th>Most<br>Common<br>SSID</th><th>AP with<br>most GPS</th><th>User with<br>most APs</th><th>Total APs</th>
						<th>Num Unique APs</th><th>WEP APs</th><th>Secure APs</th><th>Open APs</th><th>File Upload<br>Folder Size</th><th>Smallest<br>File</th>
						<th>Avg File</th><th>Max File</th><th>Num of Files</th><th>KMZ Folder<br>Size</th><th>Smallest<br>KMZ</th><th>Avg KMZ</th><th>Max KMZ</th>
						<th>Num of KMZ</th><th>Graph Folder<br>Size</th><th>Smallest<br>Graph</th><th>Avg Graph</th><th>Max Graph</th><th>Num of Graps</th>
					<tr>
				<?php
				$i=0;
				$sql0 = "SELECT * FROM `$db`.`$DB_stats` ORDER BY `id` DESC";
			#	echo $sql0;
				$row = 0;
				$result = mysql_query($sql0, $conn) or die(mysql_error($conn));
				while($dbstats_a = mysql_fetch_array($result))
				{
					if($row == 1)
					{ $row = 0; $style = "dark";}
					else{ $row = 1; $style = "light";}
					
					?>
					<tr class="<?php echo $style; ?>">
						<td><?php echo $dbstats_a['id']; ?></td>
						<td><?php echo $dbstats_a['timestamp']; ?></td>
						<td><?php echo $dbstats_a['top_ssids'][0]; ?></td>
						<td><?php echo $dbstats_a['ap_gps_totals'][0]; ?></td>
						<td><?php echo $dbstats_a['user'][0]; ?></td>
						<td><?php echo $dbstats_a['total_aps']; ?></td>
						<td><?php echo $dbstats_a['nuap']; ?></td>
						<td><?php echo $dbstats_a['wep_aps']; ?></td>
						<td><?php echo $dbstats_a['secure_aps']; ?></td>
						<td><?php echo $dbstats_a['open_aps']; ?></td>
						<td><?php echo $dbstats_a['file_up_totals']; ?></td>
						<td><?php echo $dbstats_a['file_min']; ?></td>
						<td><?php echo $dbstats_a['file_avg']; ?></td>
						<td><?php echo $dbstats_a['file_max']; ?></td>
						<td><?php echo $dbstats_a['file_num']; ?></td>
						<td><?php echo $dbstats_a['kmz_total']; ?></td>
						<td><?php echo $dbstats_a['kmz_min']; ?></td>
						<td><?php echo $dbstats_a['kmz_avg']; ?></td>
						<td><?php echo $dbstats_a['kmz_max']; ?></td>
						<td><?php echo $dbstats_a['kmz_num']; ?></td>
						<td><?php echo $dbstats_a['graph_total']; ?></td>
						<td><?php echo $dbstats_a['graph_min']; ?></td>
						<td><?php echo $dbstats_a['graph_avg']; ?></td>
						<td><?php echo $dbstats_a['graph_max']; ?></td>
						<td><?php echo $dbstats_a['graph_num']; ?></td>
					</tr>
					<?php
					$i++;
				}
				if($i==0)
				{
					?>
					<tr class="light">
						<td align="center" colspan="25">NULL, There is no data in the table. or there is an error (<?php mysql_error($conn); ?>)</td>
					</tr>
					<?php
				}
				?></table><?php
			break;
			###
			###
			case "aphdata":
				?>
				<table WIDTH=85% BORDER=1 CELLPADDING=2 CELLSPACING=0>
					<tr>
						<th colspan="10" class="style1"><strong><em>Database Historical Statistics</em></strong></th>
					</tr>
					<tr>
						<th colspan="10" class="style1"><strong><em><a href="?func=overview&mode=graphs&data=apstats" class="links">Graph</a></em></strong></th>
					</tr>
					<tr class="style3">
						<th>ID</th><th>Timestamp</th><th>Most<br>Common<br>SSID</th><th>AP with<br>most GPS</th><th>User with<br>most APs</th><th>Total APs</th>
						<th>Num Unique APs</th><th>WEP APs</th><th>Secure APs</th><th>Open APs</th>
					<tr>
				<?php
				$i=0;
				$sql0 = "SELECT * FROM `$db`.`$DB_stats` ORDER BY `id` DESC";
			#	echo $sql0;
				$row = 0;
				$result = mysql_query($sql0, $conn) or die(mysql_error($conn));
				while($dbstats_a = mysql_fetch_array($result))
				{
					if($row == 1)
					{ $row = 0; $style = "dark";}
					else{ $row = 1; $style = "light";}
					
					?>
					<tr class="<?php echo $style; ?>">
						<td><?php echo $dbstats_a['id']; ?></td>
						<td><?php echo $dbstats_a['timestamp']; ?></td>
						<td><?php echo $dbstats_a['top_ssids'][0]; ?></td>
						<td><?php echo $dbstats_a['ap_gps_totals'][0]; ?></td>
						<td><?php echo $dbstats_a['user'][0]; ?></td>
						<td><?php echo $dbstats_a['total_aps']; ?></td>
						<td><?php echo $dbstats_a['nuap']; ?></td>
						<td><?php echo $dbstats_a['wep_aps']; ?></td>
						<td><?php echo $dbstats_a['secure_aps']; ?></td>
						<td><?php echo $dbstats_a['open_aps']; ?></td>
					</tr>
					<?php
					$i++;
				}
				if($i==0)
				{
					?>
					<tr class="light">
						<td align="center" colspan="25">NULL, There is no data in the table. or there is an error (<?php mysql_error($conn); ?>)</td>
					</tr>
					<?php
				}
				?></table><?php
			break;
			###
			case "aps":
				$sql0 = "SELECT * FROM `$db`.`$DB_stats` ORDER BY `id` DESC LIMIT 1";
				if($result = mysql_query($sql0, $conn))
				{
					$dbstats_a = mysql_fetch_array($result);
					$common_ssid = $dbstats_a['top_ssids'][0];
					$ap_gps = $dbstats_a['ap_gps_totals'][0];
					$user_most_aps = $dbstats_a['user'][0];
					$user_geocache = $dbstats_a['geos'][0];
					
					$total_aps = $dbstats_a['total_aps'];
					$wep_aps = $dbstats_a['wep_aps'];
					$secure_aps = $dbstats_a['secure_aps'];
					$open_aps = $dbstats_a['open_aps'];
					
					$files_sizes_total = $dbstats_a['file_up_totals'];
					$file_min = $dbstats_a['file_min'];
					$file_avg = $dbstats_a['file_avg'];
					$file_max = $dbstats_a['file_max'];
					$file_num = $dbstats_a['file_num'];
					
					$kmz_size = $dbstats_a['kmz_total'];
					$kmz_min = $dbstats_a['kmz_min'];
					$kmz_avg = $dbstats_a['kmz_avg'];
					$kmz_max = $dbstats_a['kmz_max'];
					$kmz_num = $dbstats_a['kmz_num'];
					
					$graph_size = $dbstats_a['graph_total'];
					$graph_min = $dbstats_a['graph_min'];
					$graph_avg = $dbstats_a['graph_avg'];
					$graph_max = $dbstats_a['graph_max'];
					$graph_num = $dbstats_a['graph_num'];
					
					$timestamp = $dbstats_a['timestamp'];
					$nuap = $dbstats_a['nuap'];
					
					$sql0 = "SELECT * FROM `$db`.`$files`";
					$result = mysql_query($sql0, $conn);
					$files_uploaded = mysql_num_rows($result);
				}else
				{
					$common_ssid = "None";
					$ap_gps = "None";
					$user_most_aps = "None";
					$user_geocache = "None";
					
					$total_aps = 0;
					$wep_aps = 0;
					$secure_aps = 0;
					$open_aps = 0;
					
					$files_sizes_total = 0;
					$file_min = 0;
					$file_avg = 0;
					$file_max = 0;
					$file_num = 0;
					
					$kmz_size = 0;
					$kmz_min = 0;
					$kmz_avg = 0;
					$kmz_max = 0;
					$kmz_num = 0;
					
					$graph_size = 0;
					$graph_min = 0;
					$graph_avg = 0;
					$graph_max = 0;
					$graph_num = 0;
					
					$timestamp = date($date_format);
					$nuap = 0;
					$files_uploaded = 0;
					
				}
				?>
				<table WIDTH=85% BORDER=1 CELLPADDING=2 CELLSPACING=0>
					<tr>
						<th colspan="4" class="style1"><strong><em>Detailed Access Point Statistics</em></strong></th>
					</tr>
					<tr>
						<th colspan="4" class="style1"><strong><em>Last Update: <?php echo $timestamp;?></em></strong></th>
					</tr>
					<tr>
						<th colspan="4" class="style1"><font size="2"><a href="?func=overview&mode=APHdata" class="links">Historical Data</a></font></th>
					</tr>
					<tr>
						<th class="style3" style="width: 150px; height: 26px">Number of APs (Unique)</th>
						<td class="dark"><strong><?php echo $total_aps; ?> (<?php echo $nuap;?>)</strong></td>
						<th class="style3" style="width: 150px">Most Common SSID</th>
						<td class="dark"><strong><?php echo $common_ssid; ?></strong></td>
					</tr>
					<tr>
						<th class="style3" style="width: 150px; height: 26px"><strong>Open</strong></th>
						<td class="dark"><strong><?php echo $open_aps; ?></strong></td>
						<th class="style3" style="width: 150px"><strong>AP with most GPS</strong></th>
						<td class="dark"><b><?php echo $ap_gps; ?></b></td>
					</tr>
					<tr>
						<th class="style3" style="width: 150px; height: 26px"><strong>WEP</strong></th>
						<td class="dark"><strong><?php echo $wep_aps; ?></strong></td>
						<th class="style3" style="width: 150px"><strong>User with most APs</strong></th>
						<td class="dark"><b><?php echo $user_most_aps; ?></b></td>
					</tr>
					<tr>
						<th class="style3" style="width: 150px; height: 26px">Secure</th>
						<td class="dark"><b><?php echo $secure_aps; ?></b></td>
						<th class="style3"></th>
						<td class="dark"></td>
					</tr>
				</table>
				<?php
			break;
			
			case "geo":
				$sql0 = "SELECT * FROM `$db`.`$DB_stats` ORDER BY `id` DESC LIMIT 1";
				if($result = mysql_query($sql0, $conn))
				{
					$dbstats_a = mysql_fetch_array($result);
					$user_geocache1 = explode("-", $dbstats_a['geos']);
					$user_geocache2 = explode("|", $user_geocache1[0]);
					$user_geocache = $user_geocache2[1]."( ".$user_geocache2[0]." )";
					$num_priv_geo = $dbstats_a['num_priv_geo'];
					$num_pub_geo = $dbstats_a['num_pub_geo'];
					$gpx_size = $dbstats_a['gpx_size'];
					$gpx_max = $dbstats_a['gpx_max'];
					$gpx_avg = $dbstats_a['gpx_avg'];
					$gpx_min = $dbstats_a['gpx_min'];
					$gpx_num = $dbstats_a['gpx_num'];
					$timestamp = $dbstats_a['timestamp'];
				}else
				{
					$timestamp = date('Y-m-d H:i:s');
					$user_geocache = "None...";
					$num_priv_geo = 0;
					$num_pub_geo = 0;
					$gpx_size = "0kb";
					$gpx_max = "0kb";
					$gpx_avg = "0kb";
					$gpx_min = "0kb";
					$gpx_num = 0;
				}
				?>
				<table WIDTH=85% BORDER=1 CELLPADDING=2 CELLSPACING=0>
					<tr>
						<th colspan="4" class="style1"><strong><em>Detailed Geocache Statistics</em></strong></th>
					</tr>
					<tr>
						<th colspan="4" class="style1"><strong><em>Last Update: <?php echo $timestamp;?></em></strong></th>
					</tr>
					<tr>
						<th colspan="4" class="style1"><font size="2"><a href="?func=overview&mode=MCHdata" class="links">Historical Data</a></font></th>
					</tr>
					<tr>
						<th class="style3" style="width: 150px; height: 26px">Number of Private Geocaches</th>
						<td class="dark"><strong><?php echo $num_priv_geo; ?></strong></td>
						<th class="style3" style="width: 150px">Number of Public Geocaches</th>
						<td class="dark"><strong><?php echo $num_pub_geo; ?></strong></td>
					</tr>
					<tr>
						<th class="style3" style="width: 150px; height: 26px">User with most Geocaches</th>
						<td class="dark"><strong><?php echo $user_geocache; ?></strong></td>
						<th class="style3" style="width: 150px"><strong>GPX files Generated<br><font size="2">(Total size / average / largest / smallest)</font></strong></th>
						<td class="dark"><b><?php echo $gpx_num; ?><br><font size="2">(<?php echo $gpx_size." / ".$gpx_avg." / ".$gpx_max." / ".$gpx_min;?>)</font></b></td>
					</tr>
				</table>
				<?php
			break;
			###
			case "mchdata":
				?>
				<table WIDTH=85% BORDER=1 CELLPADDING=2 CELLSPACING=0>
					<tr>
						<th colspan="10" class="style1"><strong><em>Geocache Historical Statistics</em></strong></th>
					</tr>
					<tr>
						<th colspan="10" class="style1"><strong><em><a href="?func=overview&mode=graphs&data=mcstats" class="links">Graph</a></em></strong></th>
					</tr>
					<tr class="style3">
						<th>ID</th><th>Timestamp</th><th>Num<br>GPX<br>Files</th><th>GPX<BR>FOLDER<BR>SIZE</th><th>Max</th><th>Avg</th>
						<th>Min</th><th>Number<BR>of<BR>Private<BR>Geocaches</th><th>Number<BR>of<BR>Public<BR>Geocaches</th><th>User<BR>With<BR>Most<BR>Geocaches</th>
					<tr>
				<?php
				$i=0;
				$sql0 = "SELECT * FROM `$db`.`$DB_stats` ORDER BY `id` DESC";
			#	echo $sql0;
				$row = 0;
				$result = mysql_query($sql0, $conn) or die(mysql_error($conn));
				while($dbstats_a = mysql_fetch_array($result))
				{
					if($row == 1)
					{ $row = 0; $style = "dark";}
					else{ $row = 1; $style = "light";}
					
					?>
					<tr class="<?php echo $style; ?>">
						<td><?php echo $dbstats_a['id']; ?></td>
						<td><?php echo $dbstats_a['timestamp']; ?></td>
						<td><?php echo $dbstats_a['gpx_num']; ?></td>
						<td><?php echo $dbstats_a['gpx_size']; ?></td>
						<td><?php echo $dbstats_a['gpx_max']; ?></td>
						<td><?php echo $dbstats_a['gpx_avg']; ?></td>
						<td><?php echo $dbstats_a['gpx_min']; ?></td>
						<td><?php echo $dbstats_a['num_priv_geo']; ?></td>
						<td><?php echo $dbstats_a['num_pub_geo']; ?></td>
						<td><?php $user_geocache1 = explode("-", $dbstats_a['geos']);
					$user_geocache2 = explode("|", $user_geocache1[0]);
					echo $user_geocache2[1]."( ".$user_geocache2[0]." )"; ?></td>
					</tr>
					<?php
					$i++;
				}
				if($i==0)
				{
					?>
					<tr class="light">
						<td align="center" colspan="25">NULL, There is no data in the table. or there is an error (<?php mysql_error($conn); ?>)</td>
					</tr>
					<?php
				}
				?></table><?php
			break;
			###
			
			case "users":
				$detailed_user_view = addslashes(@$_GET['detailed_users']);
				if($detailed_user_view)
				{
				}else
				{
					
				}
				$sql0 = "SELECT * FROM `$db`.`$user_logins_table` WHERE `username` NOT LIKE 'admin%' ORDER BY `username` ASC";
				if($result = mysql_query($sql0, $conn))
				{
					if($detailed_user_view)
					{
					?>
						<b><font size='6'>WiFiDB Users (<a class="links" href="?func=overview&mode=users&detailed_users=0" title="Show the Short version" >detailed</a>)</font></b><br>
					<?php
					}else
					{
					?>
						<b><font size='6'>WiFiDB Users (<a class="links" href="?func=overview&mode=users&detailed_users=1" title="Show Detailed Version">short</a>)</font></b><br>
						<table border="1" style="width: 95%">
					<?php
					}
					$row_color = 0;
					while($users_a = mysql_fetch_array($result))
					{
						if($users_a['uid'] == ''){continue;}
						if($row_color){$row_color =0; $style = "light";}else{$row_color = 1; $style = "dark";}
						$username = $users_a['username'];
						$user_geos = "waypoints_".$users_a['username'];
						
						$sql1 = "SELECT * FROM `$db`.`$users_t` WHERE `username` = '$username'";
						$result1 = mysql_query($sql1, $conn);
						$Num_aps=0;
						while($points_a = mysql_fetch_array($result1))
						{
							$points = explode("-", $points_a['points']);
							$Num_aps = $Num_aps+count($points);
						}
						
						$sql1 = "SELECT `id` FROM `$db`.`$user_geos`";
						$result1 = mysql_query($sql1, $conn);
						$Num_geo = @mysql_num_rows($result1);
						if($Num_geo==''){$Num_geo = 0;}
						$rank = '';
						if($users_a["admins"]){	$rank .= "<img src=\"$hosturl/$root/themes/$theme/img/admins.gif\" title=\"Obey the admins, for they are gods.\" /> \r\n"; }
						if($users_a["devs"]){$rank .= "<img src=\"$hosturl/$root/themes/$theme/img/devs.gif\" title=\"Piss off a dev and be sure to never see the light of a console again.\" /> \r\n";}
						if($users_a["mods"]){$rank .= "<img src=\"$hosturl/$root/themes/$theme/img/mods.gif\" title=\"Mods are the KGB of Packet land.\" /> \r\n";}
						if($users_a["users"]){$rank .= "<img src=\"$hosturl/$root/themes/$theme/img/users.gif\" title=\"Fellow users can be your freind or they can be your enemey, either way keep them close, and keep track of those fuckers, their sneeky\" /> \r\n";}
						
						if($detailed_user_view)
						{
							?>
							<table border="1" width="95%">
							<tr class="style4">
								<th>ID</th>
								<th>User Name</th>
								<th>Number of APs</th>
								<th>E-Mail</th>
								<th>Website</th>
								<th>Vistumbler Version</th>
								<th>Title</th></tr>
							<tr class="<?php echo $style; ?>">
								<td><?php echo $users_a['id']; ?></td>
								<td>
								<?php
								if($Num_aps > 0)
								{
									?>
									<a class="links" href="<?php echo $GLOBALS['hosturl'].$GLOBALS['root']; ?>/opt/userstats.php?func=alluserlists&user=<?php echo $users_a['username'];?>"><?php echo $users_a['username']; ?></a>
									<?php 
								}else
								{
									echo $users_a['username'];
								}
								?>
								</td>
								<td><?php echo $Num_aps; ?></td>
								<td><?php if($users_a['h_email'] and $GLOBALS['priv_name'] != "Administrator"){echo "Email Hidden, except to admins";}else{ ?><a class='email' href='mailto:<?php echo $users_a['email']; ?>' ><?php echo $users_a['email']; ?></a><?php } ?></td>
								<td><?php echo $users_a['website']; ?></td>
								<td><?php echo $users_a['Vis_ver']; ?></td>
								<td>
									<?php echo $rank; ?>
								</td>
							</tr>
							<tr class="style4">
								<th colspan="2">&nbsp;</th>
								<th>Rank</th>
								<th>Number of Geocaches</th>
								<th>Last Login</th>
								<th>Join Date</th>
								<th>UID</th>
							</tr>
							<tr class="<?php echo $style; ?>">
								<td colspan="2">&nbsp;</td>
								<td><?php echo $users_a['rank']; ?></td>
								<td><?php echo $Num_geo; ?></td>
								<td><?php echo $users_a['last_login']; ?></td>
								<td><?php echo $users_a['join_date']; ?></td>
								<td><?php echo $users_a['uid']; ?></td>
							</tr>
						</table>
						<br>
						<?php
						}else
						{
							?>
								<tr class="style4">
									<th>ID</th><th>User Name</th><th>Number of APs</th><th>Last Login</th><th>Join Date</th><th>Vistumbler Version</th><th>Title / Rank</th></tr>
								<tr class="<?php echo $style; ?>">
									<td><?php echo $users_a['id']; ?></td>
									<td>
									<?php
									if($Num_aps > 0)
									{
										?>
										<a class="links" href="<?php echo $GLOBALS['hosturl'].$GLOBALS['root']; ?>/opt/userstats.php?func=alluserlists&user=<?php echo $users_a['username'];?>"><?php echo $users_a['username']; ?></a>
										<?php 
									}else
									{
										echo $users_a['username'];
									}
									?>
									</td>
									<td><?php echo $Num_aps; ?></td>
									<td><?php echo $users_a['last_login']; ?></td>
									<td><?php echo $users_a['join_date']; ?></td>
									<td><?php echo $users_a['Vis_ver']; ?></td>
									<td width="30%"><?php echo $rank; ?></td>
								</tr>
							<?php
						}
					}
				}else
				{
					?>
					<tr class="bad"><td align='center' colspan='<?php if($detailed_user_view){ echo '11';}else{echo '7';} ?>'>There are no Users yet, why dont you go make some freinds.</td></tr>
					<?php
				}
				?></table><?php
			break;
			
			case "daemon":
			####################################
				?><table class="style4" border="1" width="75%"><?php
				$sql0 = "SELECT * FROM `$db`.`$daemon_perf_table` ORDER BY `id` DESC LIMIT 1";
				if($result = mysql_query($sql0, $conn))
				{
					$daemon_a = mysql_fetch_array($result);
					
					$timestamp = $daemon_a['timestamp'];
					$pid = $daemon_a['pid'];
					$runtime = $daemon_a['uptime'];
					$CMD = $daemon_a['CMD'];
					$mem = $daemon_a['mem'];
					$msg = $daemon_a['mesg'];
				}else
				{
					$timestamp = date($date_format);
					$pid = 0;
					$runtime = "0:00";
					$cmd = "NULL";
					$mem = "0%";
					$msg = "No Daemons have been initialized yet...";
				}
				$os = PHP_OS;
				if ( $os[0] == 'L')
				{
					?><tr class="style4"><th colspan="5">Linux Based WiFiDB Daemon</th></tr>
					<?php
				}elseif( $os[0] == 'W')
				{
					?><tr class="style4"><th colspan="5">Windows Based WiFiDB Daemon</th></tr>
					<?php
				}elseif($os[0] != 'W' or $os[0] != 'L')
				{
					?><tr class="style4"><th colspan="5">Unknown OS Based WiFiDB Daemon</th></tr>
					<?php
				}
				?><tr class="style4"><th colspan="5"><a href="?func=overview&mode=daemon_hist" class="links">Historical Data</a></th></tr>
				<tr class="style4"><th>TIMESTAMP</th><th>PID</th><th>RUNTIME</th><th>Memory</th><th>CMD</th></tr><?php
				
				if($pid == 0)
				{
					?><tr align="center" bgcolor="red">
						<td><?php echo $timestamp;?></td>
						<td colspan="4"><?php echo $msg;?></td>
					</tr>
					<?php
				}else
				{	
					?><tr align="center" bgcolor="green">
						<td><?php echo $timestamp;?></td>
						<td><?php echo $pid;?></td>
						<td><?php echo $runtime;?></td>
						<td><?php echo $mem."%";?></td>
						<td><?php echo $CMD;?></td>
					</tr>
					<?php
				}
				
				?></table><?php
			break;
			
			case "daemon_hist":
				?><table class="style4" border="1" width="75%"><?php
				$sql0 = "SELECT * FROM `$db`.`$daemon_perf_table` ORDER BY `id` DESC";
				$result = mysql_query($sql0, $conn);
				
				?><tr class="style4"><th colspan="5">Daemon Performance History</th><tr class="style4"><th>TIMESTAMP</th><th>PID</th><th>RUNTIME</th><th>Memory</th><th>CMD</th></tr><?php
				$row = 0;
				while($daemon_a = mysql_fetch_array($result))
				{
					if($row){$row = 0;$style="dark";}else{$row=1;$style="light";}
					$timestamp = $daemon_a['timestamp'];
					$pid = $daemon_a['pid'];
					$runtime = $daemon_a['uptime'];
					$CMD = $daemon_a['CMD'];
					$mem = $daemon_a['mem'];
					$msg = $daemon_a['mesg'];
					if($pid == 0)
					{
						?><tr align="center" bgcolor="red">
							<td colspan="2"><?php echo $timestamp;?></td> 
							<td colspan="3"><?php echo $msg;?></td>
						</tr>
						<?php
					}else
					{	
						?><tr align="center" class="<?php echo $style; ?>">
							<td><?php echo $timestamp?></td>
							<td><?php echo $pid;?></td>
							<td><?php echo $runtime;?></td>
							<td><?php echo $mem."%";?></td>
							<td><?php echo $CMD;?></td>
						</tr>
						<?php
					}
				}
				?></table><?php
			break;
			
			case "graphs":
				$data = addslashes(strtolower(@$_GET['data']));
				$range = addslashes(strtolower(@$_GET['range']));
				if($data != '')
				{
					switch($data)
					{
						case "dbstats":
							graph_stats('dbstats', $range);
						break;
						
						case "apstats":
							graph_stats('apstats', $range);
						break;
						
						case "mcstats":
							graph_stats('mcstats', $range);
						break;
					}
				}else
				{
					?>
					<table class="style4" border="1" width="75%">
						<tr class="style4">
							<th colspan="2" align="center">Statistic Graphs</th>
						</tr>
						<tr class="light">
							<td><a href="?func=graph&mode=userstats" class="links">User Stats</a></td>
							<td><a href="?func=graph&mode=mcstats" class="links">Geocaches</a></td>
						</tr>
						<tr class="light">
							<td colspan="2"><a href="?func=graph&mode=apstats" class="links">Access Points</a></td>
						</tr>
					</table>
					<?php
				}
			break;
			
			default:
			####################################
				
				$sql0 = "SELECT * FROM `$db`.`$DB_stats` ORDER BY `id` DESC LIMIT 1";
				if($result = mysql_query($sql0, $conn))
				{
					$dbstats_a = mysql_fetch_array($result);
					$common_ssid = $dbstats_a['top_ssids'][0];
					$ap_gps = $dbstats_a['ap_gps_totals'][0];
					$user_most_aps = $dbstats_a['user'][0];
					$user_geocache = $dbstats_a['geos'][0];
					
					$total_aps = $dbstats_a['total_aps'];
					$wep_aps = $dbstats_a['wep_aps'];
					$secure_aps = $dbstats_a['secure_aps'];
					$open_aps = $dbstats_a['open_aps'];
					
					$files_sizes_total = $dbstats_a['file_up_totals'];
					$file_min = $dbstats_a['file_min'];
					$file_avg = $dbstats_a['file_avg'];
					$file_max = $dbstats_a['file_max'];
					$file_num = $dbstats_a['file_num'];
					
					$kmz_size = $dbstats_a['kmz_total'];
					$kmz_min = $dbstats_a['kmz_min'];
					$kmz_avg = $dbstats_a['kmz_avg'];
					$kmz_max = $dbstats_a['kmz_max'];
					$kmz_num = $dbstats_a['kmz_num'];
					
					$graph_size = $dbstats_a['graph_total'];
					$graph_min = $dbstats_a['graph_min'];
					$graph_avg = $dbstats_a['graph_avg'];
					$graph_max = $dbstats_a['graph_max'];
					$graph_num = $dbstats_a['graph_num'];
					
					$timestamp = $dbstats_a['timestamp'];
					$nuap = $dbstats_a['nuap'];
					
					$sql0 = "SELECT * FROM `$db`.`$files`";
					$result = mysql_query($sql0, $conn);
					$files_uploaded = mysql_num_rows($result);
				}else
				{
					$common_ssid = "None";
					$ap_gps = "None";
					$user_most_aps = "None";
					$user_geocache = "None";
					
					$total_aps = 0;
					$wep_aps = 0;
					$secure_aps = 0;
					$open_aps = 0;
					
					$files_sizes_total = 0;
					$file_min = 0;
					$file_avg = 0;
					$file_max = 0;
					$file_num = 0;
					
					$kmz_size = 0;
					$kmz_min = 0;
					$kmz_avg = 0;
					$kmz_max = 0;
					$kmz_num = 0;
					
					$graph_size = 0;
					$graph_min = 0;
					$graph_avg = 0;
					$graph_max = 0;
					$graph_num = 0;
					
					$timestamp = date($date_format);
					$nuap = 0;
					$files_uploaded = 0;
					
				}
				?>
				<table WIDTH=85% BORDER=1 CELLPADDING=2 CELLSPACING=0>
					<tr>
						<th colspan="4" class="style1"><strong><em>Statistics</em></strong></th>
					</tr>
					<tr>
						<th colspan="4" class="style1"><strong><em>Last Update: <?php echo $timestamp;?></em></strong></th>
					</tr>
					<tr class="style1">
						<th colspan="5"><a href="?func=overview&mode=dbhdata" class="links">Historical Data</a></th>
					</tr>
					<tr>
						<th class="style3" style="width: 150px; height: 26px">Number of APs (Unique)</th>
						<td class="dark"><strong><?php echo $total_aps; ?> (<?php echo $nuap;?>)</strong></td>
						<th class="style3" style="width: 150px">Most Common SSID</th>
						<td class="dark"><strong><?php echo $common_ssid; ?></strong></td>
					</tr>
					<tr>
						<th class="style3" style="width: 150px; height: 26px;"><strong>Open</strong></th>
						<td class="dark"><strong><?php echo $open_aps; ?></strong></td>
						<th class="style3" style="width: 150px"><strong>AP with most GPS</strong></th>
						<td class="dark"><b><?php echo $ap_gps; ?></b></td>
					</tr>
					<tr>
						<th class="style3" style="width: 150px; height: 26px"><strong>WEP</strong></th>
						<td class="dark"><strong><?php echo $wep_aps; ?></strong></td>
						<th class="style3" style="width: 150px"><strong>User with most APs</strong></th>
						<td class="dark"><b><?php echo $user_most_aps; ?></b></td>
					</tr>
					<tr>
						<th class="style3" style="width: 150px; height: 26px">Secure</th>
						<td class="dark"><b><?php echo $secure_aps; ?></b></td>
						<th class="style3" style="width: 150px">User with most Geocaches</th>
						<td class="dark"><b><?php echo $user_geocache; ?></b></td>
					</tr>
					<tr>
						<th class="style3" style="width: 150px; height: 26px"><strong>Number of Uploaded Files<br><font size="2">(Total / average / largest / smallest)</font></strong></td>
						<td class="dark"><b><?php echo $files_uploaded; ?><br><font size="2">(<?php echo $files_sizes_total." / ".$file_avg." / ".$file_max." / ".$file_min;?>)</font></b></td>
						<th class="style3" style="width: 150px"><strong>Graphs Generated<br><font size="2">(Total / average / largest / smallest)</font></strong></th>
						<td class="dark"><b><?php echo $graph_num; ?><br><font size="2">(<?php echo $graph_size." / ".$graph_avg." / ".$graph_max." / ".$graph_min;?>)</font></b></td>
					</tr>
					<tr>
						<td class="style3" style="width: 150px; height: 26px"></td>
						<td class="dark"></td>
						<th class="style3" style="width: 150px"><strong>KML Files Exported<br><font size="2">(Total / average / largest / smallest)</font></strong></th>
						<td class="dark"><b><?php echo $kmz_num; ?><br><font size="2">(<?php echo $kmz_size." / ".$kmz_avg." / ".$kmz_max." / ".$kmz_min;?>)</font></b></td>
					</tr>
				</table>
				<?php
			break;
		}
	}
	
	
	##-----------------------------##
	##-----------------------------##
	##-----------------------------##
	function uandp($mode = '')
	{
		include_once('../../lib/config.inc.php');
		include_once('../../lib/database.inc.php');
		
		$hosturl		= 	$GLOBALS['hosturl'];
		$conn			= 	$GLOBALS['conn'];
		$db				= 	$GLOBALS['db'];
		$db_st			= 	$GLOBALS['db_st'];
		$DB_stats		= 	$GLOBALS['DB_stats_table'];
		$daemon_perf_table =	$GLOBALS['daemon_perf_table'];
		$wtable			=	$GLOBALS['wtable'];
		$users_t		=	$GLOBALS['users_t'];
		$share_cache	=	$GLOBALS['share_cache'];
		$gps_ext		=	$GLOBALS['gps_ext'];
		$files			=	$GLOBALS['files'];
		$user_logins_table = $GLOBALS['user_logins_table'];
		$root			= 	$GLOBALS['root'];
		$half_path		=	$GLOBALS['half_path'];
		$theme			=	$GLOBALS['theme'];
		$date_format	=	"Y-m-d H:i:s";
		
		switch($mode)
		{
			case "man_users_edit":
				$username		=	$_POST['username'];
				$user_id		=	$_POST['user_id'];
				$email			=	$_POST['email'];
				$h_email		=	$_POST['h_email'];
				$disabled		=	$_POST['disabled'];
				$locked			=	$_POST['locked'];
				#dump($HTTP_POST_VARS['login_fails_submit']);
				if(@$HTTP_POST_VARS['login_fails_submit']){$login_fails = 0;}else{$login_fails = $_POST['login_fails'];}
				$member 		=	$_POST['member'];
				$website 		=	$_POST['website'];
				$Vis_ver 		=	$_POST['Vis_ver'];
				$sec_token 		=	$_POST['sec_token'];
				$sql1 = "UPDATE `$db`.`$user_logins_table` SET `email` = '$email' , `h_email` = '$h_email', `disabled`='$disabled',`locked`='$locked',`login_fails`='$login_fails',`website`='$website',`Vis_ver`='$Vis_ver' WHERE `id` = '$user_id' LIMIT 1";
			#	echo $sql1;
				if(mysql_query($sql1, $conn))
				{					
					redirect_page('?func=uandp&mode=man_users&data='.$username, 2000, 'Update User Successful!');
				}
			
			break;
			
			
			#################
			case "man_users":
				$data = addslashes(strtolower(@$_GET['data']));
				$first = addslashes(@$_GET['first']);
				?>
				<table WIDTH=85% BORDER=1 CELLPADDING=2 CELLSPACING=0>
					<tr>
						<th colspan="25" class="style4"><strong><em>Database Historical Statistics</em></strong></th>
					</tr>
					
				<?php
				user_alph_row(addslashes(strtolower($_GET['func'])), $mode, $first, $data);
				?>
					<tr>
						<td width="25%" valign="top">
							<table width="100%" height="100%">
								<?php
								$sql0 = "SELECT * FROM `$db`.`$user_logins_table` WHERE `username` LIKE '".$first."%' ORDER BY `username` ASC";
								$result = mysql_query($sql0, $conn);
								$row = 0;
								while($users = mysql_fetch_array($result))
								{
									if($row){$row = 0; $style="light";}else{$row = 1;$style = "dark";}
									?>
									<tr class="<?php echo $style; ?>">
										<td>
											<a class="links<?php if($data == strtolower($users['username'])){echo "_sa";} ?>" href="?func=uandp&mode=man_users&first=<?php echo $first;?>&data=<?php echo $users['username']; ?>"><?php echo $users['username']; ?></a>
										</td>
									</tr>
									<?php
								}
								?>
							</table>
						</td>
						<td>
							<?php
							if($data != '')
							{
								$sql0 = "SELECT * FROM `$db`.`$user_logins_table` WHERE `username` LIKE '$data'";
								$result = mysql_query($sql0, $conn);
								$users = mysql_fetch_array($result);
								?>
								<form method="post" action="" name="edit_user_values_form">
								<table width="100%"  class="style4">
									<tr class="dark">
										<td width="30%">
											Username
										</td>
										<td colspan="2">
											<?php echo $users['username']; ?>
											<input type="hidden" name="username" value="<?php echo $users['username']; ?>">
											<input type="hidden" name="user_id" value="<?php echo $users['id']; ?>">
											<input type="hidden" name="sec_token" value="<?php echo $token; ?>" >
										</td>
									</tr>
									<tr class="dark">
										<td>
											Email Address
										</td>
										<td>
											<input type="text" size="48" maxlength="255" name="email" value="<?php echo $users['email']; ?>">
										</td>
										<td>
												<input type="hidden" name="h_email" value="<?php if(($users['h_email']+0)===1){echo 0;}else{echo 1;} ?>" >
												<input type="button" name="hide_email_submit" value="<?php if(($users['h_email']+0)===0){echo "Hide My Email!";}else{echo "Show My Email!";}?>" onClick="document.edit_user_values_form.action='?func=uandp&mode=man_users_edit'; document.edit_user_values_form.submit();" />
										</td>
									</tr>
									<tr class="dark">
										<td>
											Login Fails
										</td>
										<td>
											<input type="text" name="login_fails" size="3" value="<?php echo $users['login_fails']; ?>">
										</td>
										<td>
											<input type="button" name="login_fails_submit" value="Reset" onClick="document.edit_user_values_form.action='?func=uandp&mode=man_users_edit'; document.edit_user_values_form.submit();" />
										</td>
									</tr>
									<tr class="dark">
										<td>
											Website
										</td>
										<td colspan="2">
											<input type="text" name="website" value="<?php echo $users['website']; ?>">
										</td>
									</tr>
									<tr class="dark">
										<td>
											Vistumbler Version
										</td>
										<td colspan="2">
											<input type="text" name="Vis_ver" value="<?php echo $users['Vis_ver']; ?>">
										</td>
									</tr>
									<tr class="style4">
										<td colspan="3" align="center">
											<input type="hidden" name="disabled" value="<?php echo $users['disabled']; ?>" >
											<input type="hidden" name="locked" value="<?php echo $users['locked']; ?>" >
											<input type="button" name="update_user_submit" value="Update User" onClick="document.edit_user_values_form.action='?func=uandp&mode=man_users_edit'; document.edit_user_values_form.submit();" />
											</form>
										</td>
									</tr>
									<tr class="dark">
										<td></td>
										<td colspan="2">
											<table width="100%">
												<tr align="center">
													<td align="center">
														Disabled?...
														<form method="post" action="" name="disable_enable_user_toggle"  enctype="multipart/form-data">
															<input type="hidden" name="sec_token" value="<?php echo $token; ?>" >
															<input type="hidden" name="disabled" value="<?php if(($users['disabled']+0)===1){echo 0;}else{echo 1;} ?>" >
															<input type="hidden" name="locked" value="<?php echo $users['locked']; ?>" >
															<input type="hidden" name="h_email" value="<?php echo $users['h_email']; ?>" >
															<input type="hidden" name="website" value="<?php echo $users['website']; ?>">
															<input type="hidden" name="username" value="<?php echo $users['username']; ?>">
															<input type="hidden" name="user_id" value="<?php echo $users['id']; ?>">
															<input type="hidden" name="login_fails" size="3" value="<?php echo $users['login_fails']; ?>">
															<input type="hidden" name="Vis_ver" value="<?php echo $users['Vis_ver']; ?>">
															<input type="hidden" name="email" value="<?php echo $users['email']; ?>">
															<input type="button" value="<?php if(($users['disabled']+0)=== 0){echo "Disable User!";}else{echo "Enable User!";}?>" onClick="document.disable_enable_user_toggle.action='?func=uandp&mode=man_users_edit'; document.disable_enable_user_toggle.submit();" />
														</form>
													</td>
													<td align="center">
														Locked?...
														<form method="post" action="?func=uandp&mode=man_users_edit" name="lock_unlock_user_toggle"  enctype="multipart/form-data">
															<input type="hidden" name="sec_token" value="<?php echo $token; ?>" >
															<input type="hidden" name="locked" value="<?php if(($users['locked']+0)==1){echo 0;}else{echo 1;} ?>" >
															<input type="hidden" name="website" value="<?php echo $users['website']; ?>">
															<input type="hidden" name="username" value="<?php echo $users['username']; ?>">
															<input type="hidden" name="user_id" value="<?php echo $users['id']; ?>">
															<input type="hidden" name="login_fails" size="3" value="<?php echo $users['login_fails']; ?>">
															<input type="hidden" name="Vis_ver" value="<?php echo $users['Vis_ver']; ?>">
															<input type="hidden" name="email" size="48" maxlength="255" value="<?php echo $users['email']; ?>">
															<input type="hidden" name="disabled" value="<?php echo $users['disabled']; ?>" >
															<input type="hidden" name="h_email" value="<?php echo $users['h_email']; ?>" >
															<input type="button" value="<?php if(($users['locked']+0)=== 1){echo "Account is currently locked out from to many bad logins!";}else{echo "Account is not locked!";}?>" onClick="document.lock_unlock_user_toggle.action='?func=uandp&mode=man_users_edit'; document.lock_unlock_user_toggle.submit();" />
														</form>
													</td>
												</tr>
											</table>
										</td>
									</tr>
								</table>
							<?php
							}else
							{
								?>
								<table width="75%">
								<tr><td>Choose a user .... over there &#60;---- to the left...</td></tr>
								</table>
								<?php
							}
							?>
						</td>
					</tr>
				</table>
				<?php
			break;
			##################
			case "man_grp_edit":
			#	dump(get_defined_vars());
			#	dump($_POST['admingrp']);
			#	dump($_POST['nonadmingrp']);
				
				$data = addslashes(strtolower($_GET['data']));
				#dump($data);
				$todo = addslashes(strtolower($_GET['todo']));
				$in = $_POST['in_grp'];
				$not_in = $_POST['not_in_grp'];
				if(@$in){$users = $in;}else{$users = $not_in;}
				if($todo === 'r'){$td=0;}elseif($todo==='a'){$td=1;}
				foreach($users as $user_id)
				{
					switch($data)
					{
						case "admins":	
							$sql1 = "UPDATE `$db`.`$user_logins_table` SET `admins` = '$td' WHERE `id` = '$user_id' LIMIT 1";
						break;
						
						case "devs":	
							$sql1 = "UPDATE `$db`.`$user_logins_table` SET `devs` = '$td' WHERE `id` = '$user_id' LIMIT 1";
						break;
						
						case "mods":	
							$sql1 = "UPDATE `$db`.`$user_logins_table` SET `mods` = '$td' WHERE `id` = '$user_id' LIMIT 1";
						break;
						
						case "users":	
							$sql1 = "UPDATE `$db`.`$user_logins_table` SET `users` = '$td' WHERE `id` = '$user_id' LIMIT 1";
						break;
					}
				#	echo $sql1."<br>";
					$result = mysql_query($sql1, $conn);
					if(@$result)
					{					
						echo "Updated user ($user_id) to ";if(@$in){echo "remove ";}else{echo "have ";} echo "`$data group` permissions<br>\r\n";
					}else
					{
						echo "There was a serious error: ".mysql_error($conn)."<br>";
						die();
					}
				}
				redirect_page('?func=uandp&mode=man_groups&data='.$data, 2000, 'Update User Successful!');
			break;
			##################
			case "man_groups":
				$data = addslashes(strtolower(@$_GET['data']));
				?>
				<table WIDTH=85% BORDER=1 CELLPADDING=2 CELLSPACING=0>
					<tr>
						<th colspan="2" class="style1"><strong><em>Manage Groups</em></strong></th>
					</tr>
					<tr>
						<td width="25%" valign="top">
							<table width="100%" height="100%">
								<tr class="light">
										<td>
											<a class="links<?php if($data == 'admins'){echo "_sa";} ?>" href="?func=uandp&mode=man_groups&data=admins">Administrators</a>
										</td>
								</tr>
								<tr class="dark">
									<td>
										<a class="links<?php if($data == 'devs'){echo "_sa";} ?>" href="?func=uandp&mode=man_groups&data=devs">Developers</a>
									</td>
								</tr>
								<tr class="light">
									<td>
										<a class="links<?php if($data == 'mods'){echo "_sa";} ?>" href="?func=uandp&mode=man_groups&data=mods">Moderators</a>
									</td>
								</tr>
								<tr class="dark">
									<td>
										<a class="links<?php if($data == 'users'){echo "_sa";} ?>" href="?func=uandp&mode=man_groups&data=users">Users</a>
									</td>
								</tr>
							</table>
						</td>
						<td>
							<?php
							if($data != '')
							{
								switch($data)
								{
									case "admins":
										?>
										<table width="100%" border="1">
											<tr class="style4">
												<th>Users currently in Admins:</th>
												<th>Users Not In Admins:</th>
											</tr>
											<tr>	
												<td class="light" align="center" width="50%">
												<form method="post" action="" name="remove_from_admin_group"  enctype="multipart/form-data">
												<?php
												$sql0 = "SELECT `username`,`id` FROM `$db`.`$user_logins_table` WHERE `admins` = '1'";
												$result = mysql_query($sql0, $conn);
											#	$rows = mysql_num_rows($result);
												?> <select name="in_grp[]" multiple size="10" style="width: 100%;"> <?php
												while($users = mysql_fetch_array($result))
												{
													echo "<option value='".$users['id']."'>".$users['username']."</option>\r\n";
												#	echo "<option>".$users['username']."\r\n";
												}
												?>
													</select><br>
													<input type="button" name="remove_group_submit" value="Remove Selected User(s)" onClick="document.remove_from_admin_group.action='?func=uandp&mode=man_grp_edit&data=admins&todo=r'; document.remove_from_admin_group.submit();" />
													</form>
												</td>
												<!--#####################-->
												<td class="light" align="center">
												<form method="post" action="" name="add_to_admin_group" enctype="multipart/form-data">
												<?php
												$sql0 = "SELECT `username`,`id` FROM `$db`.`$user_logins_table` WHERE `admins` = '0'";
												$result = mysql_query($sql0, $conn);
											#	$rows = mysql_num_rows($result);
												?> <select name="not_in_grp[]" multiple size="10" style="width: 100%;"> <?php
												while($users = mysql_fetch_array($result))
												{
													echo "<option value='".$users['id']."'>".$users['username']."</option>\r\n";
												#	echo "<option>".$users['username']."\r\n";
												}
												?>
													</select><br>
													<input type="button" name="add_group_submit" value="Add Selected User(s)" onClick="document.add_to_admin_group.action='?func=uandp&mode=man_grp_edit&data=admins&todo=a'; document.add_to_admin_group.submit();" />
												</form>
												</td>
											</tr>
										</table>
										</form>
										<?php
									break;
									###
									case "devs":
										?>
										<table width="100%" border="1">
											<tr class="style4">
												<th>Users currently in Devs:</th>
												<th>Users Not In Devs:</th>
											</tr>
											<tr>	
												<td class="light" align="center" width="50%">
												<form method="post" action="" name="remove_from_dev_group"  enctype="multipart/form-data">
												<?php
												$sql0 = "SELECT `username`,`id` FROM `$db`.`$user_logins_table` WHERE `devs` = '1'";
												$result = mysql_query($sql0, $conn);
											#	$rows = mysql_num_rows($result);
												?> <select name="in_grp[]" multiple size="10" style="width: 100%;"> <?php
												while($users = mysql_fetch_array($result))
												{
													echo "<option value='".$users['id']."'>".$users['username']."</option>\r\n";
												#	echo "<option>".$users['username']."\r\n";
												}
												?>
													</select><br>
													<input type="button" name="remove_group_submit" value="Remove Selected User(s)" onClick="document.remove_from_dev_group.action='?func=uandp&mode=man_grp_edit&data=devs&todo=r'; document.remove_from_dev_group.submit();" />
													</form>
												</td>
												<!--#####################-->
												<td class="light" align="center">
												<form method="post" action="" name="add_to_dev_group" enctype="multipart/form-data">
												<?php
												$sql0 = "SELECT `username`,`id` FROM `$db`.`$user_logins_table` WHERE `devs` = '0'";
												$result = mysql_query($sql0, $conn);
											#	$rows = mysql_num_rows($result);
												?> <select name="not_in_grp[]" multiple size="10" style="width: 100%;"> <?php
												while($users = mysql_fetch_array($result))
												{
													echo "<option value='".$users['id']."'>".$users['username']."</option>\r\n";
												#	echo "<option>".$users['username']."\r\n";
												}
												?>
													</select><br>
													<input type="button" name="add_group_submit" value="Add Selected User(s)" onClick="document.add_to_dev_group.action='?func=uandp&mode=man_grp_edit&data=devs&todo=a'; document.add_to_dev_group.submit();" />
												</form>
												</td>
											</tr>
										</table>
										</form>
										<?php
									break;
									###
									case "mods":
										?>
										<table width="100%" border="1">
											<tr class="style4">
												<th>Users currently in Mods:</th>
												<th>Users Not In Mods:</th>
											</tr>
											<tr>	
												<td class="light" align="center" width="50%">
												<form method="post" action="" name="remove_from_mod_group"  enctype="multipart/form-data">
												<?php
												$sql0 = "SELECT `username`,`id` FROM `$db`.`$user_logins_table` WHERE `mods` = '1'";
												$result = mysql_query($sql0, $conn);
											#	$rows = mysql_num_rows($result);
												?> <select name="in_grp[]" multiple size="10" style="width: 100%;"> <?php
												while($users = mysql_fetch_array($result))
												{
													echo "<option value='".$users['id']."'>".$users['username']."</option>\r\n";
												#	echo "<option>".$users['username']."\r\n";
												}
												?>
													</select><br>
													<input type="button" name="remove_group_submit" value="Remove Selected User(s)" onClick="document.remove_from_mod_group.action='?func=uandp&mode=man_grp_edit&data=mods&todo=r'; document.remove_from_mod_group.submit();" />
													</form>
												</td>
												<!--#####################-->
												<td class="light" align="center">
												<form method="post" action="" name="add_to_mod_group" enctype="multipart/form-data">
												<?php
												$sql0 = "SELECT `username`,`id` FROM `$db`.`$user_logins_table` WHERE `mods` = '0'";
												$result = mysql_query($sql0, $conn);
											#	$rows = mysql_num_rows($result);
												?> <select name="not_in_grp[]" multiple size="10" style="width: 100%;"> <?php
												while($users = mysql_fetch_array($result))
												{
													echo "<option value='".$users['id']."'>".$users['username']."</option>\r\n";
												#	echo "<option>".$users['username']."\r\n";
												}
												?>
													</select><br>
													<input type="button" name="add_group_submit" value="Add Selected User(s)" onClick="document.add_to_mod_group.action='?func=uandp&mode=man_grp_edit&data=mods&todo=a'; document.add_to_mod_group.submit();" />
												</form>
												</td>
											</tr>
										</table>
										</form>
										<?php
									break;
									###
									case "users":
										?>
										<table width="100%" border="1">
											<tr class="style4">
												<th>Users currently in Users:</th>
												<th>Users Not In Users:</th>
											</tr>
											<tr>	
												<td class="light" align="center" width="50%">
												<form method="post" action="" name="remove_from_user_group"  enctype="multipart/form-data">
												<?php
												$sql0 = "SELECT `username`,`id` FROM `$db`.`$user_logins_table` WHERE `users` = '1'";
												$result = mysql_query($sql0, $conn);
											#	$rows = mysql_num_rows($result);
												?> <select name="in_grp[]" multiple size="10" style="width: 100%;"> <?php
												while($users = mysql_fetch_array($result))
												{
													echo "<option value='".$users['id']."'>".$users['username']."</option>\r\n";
												#	echo "<option>".$users['username']."\r\n";
												}
												?>
													</select><br>
													<input type="button" name="remove_group_submit" value="Remove Selected User(s)" onClick="document.remove_from_user_group.action='?func=uandp&mode=man_grp_edit&data=users&todo=r'; document.remove_from_user_group.submit();" />
													</form>
												</td>
												<!--#####################-->
												<td class="light" align="center">
												<form method="post" action="" name="add_to_user_group" enctype="multipart/form-data">
												<?php
												$sql0 = "SELECT `username`,`id` FROM `$db`.`$user_logins_table` WHERE `users` = '0'";
												$result = mysql_query($sql0, $conn);
											#	$rows = mysql_num_rows($result);
												?> <select name="not_in_grp[]" multiple size="10" style="width: 100%;"> <?php
												while($users = mysql_fetch_array($result))
												{
													echo "<option value='".$users['id']."'>".$users['username']."</option>\r\n";
												#	echo "<option>".$users['username']."\r\n";
												}
												?>
													</select><br>
													<input type="button" name="add_group_submit" value="Add Selected User(s)" onClick="document.add_to_user_group.action='?func=uandp&mode=man_grp_edit&data=users&todo=a'; document.add_to_user_group.submit();" />
												</form>
												</td>
											</tr>
										</table>
										</form>
										<?php
									break;
								}
							}else
							{
								echo "Choose a group over there <---- to the left...";
							}
							?>
						</td>
					</tr>
				</table>
				<?php
			break;
			
			case "man_titles_edit":
			#	dump(get_defined_vars());
			#	dump($_POST['admingrp']);
			#	dump($_POST['nonadmingrp']);
				
				$data = addslashes(strtolower($_GET['data']));
				$rank = addslashes($_POST['rank']);
				$username = addslashes(strtolower($_POST['username']));
				$user_id = addslashes(strtolower($_POST['user_id']));
				$sql0 = "SELECT `id` FROM `$db`.`$user_logins_table` WHERE `username` LIKE '".$username."%'";
			#	echo $sql0."<br>";
				$result = mysql_query($sql0, $conn);
				$array = mysql_fetch_array($result);
			#	dump($array);
				if($array['id'] == $user_id)
				{
					$sql1 = "UPDATE `$db`.`$user_logins_table` SET `rank` = '$rank' WHERE `id` = '$user_id' LIMIT 1";
				
			#		echo $sql1."<br>";
				
					$result = mysql_query($sql1, $conn);
					if(@$result)
					{					
						echo "Updated user ($user_id) with new Custom Rank\r\n<br>";
					}else
					{
						echo "There was a serious error: ".mysql_error($conn)."<br>";
						die();
					}
					redirect_page('?func=uandp&mode=man_titles&data='.$data, 2000, 'Update User Successful!');
				}else
				{
					Echo "User ID's did not match, there was an error, contact the support forums for more help";
				}
			break;
			
			case "man_titles":
				$data = addslashes(strtolower(@$_GET['data']));
				$first = addslashes(strtolower(@$_GET['first']));
				?>
				<table WIDTH=85% BORDER=1 CELLPADDING=2 CELLSPACING=0>
					<tr>
						<th colspan="2" class="style1"><strong><em>Manage Users Custom Titles</em></strong></th>
					</tr>
					<?php
						user_alph_row(addslashes(strtolower($_GET['func'])), $mode, $first, $data);
					?>
					<tr>
						<td width="25%" valign="top">
							<table width="100%" height="100%">
								<?php
								$sql0 = "SELECT * FROM `$db`.`$user_logins_table` WHERE `username` LIKE '".$first."%' ORDER BY `username` ASC";
								$result = mysql_query($sql0, $conn);
								$row = 0;
								while($users = mysql_fetch_array($result))
								{
									if($row){$row = 0; $style="light";}else{$row = 1;$style = "dark";}
									?>
									<tr class="<?php echo $style; ?>">
										<td>
											<a class="links<?php if($data == strtolower($users['username'])){echo "_sa";} ?>" href="?func=uandp&mode=man_titles&first=<?php echo $first; ?>&data=<?php echo $users['username']; ?>"><?php echo $users['username']; ?></a>
										</td>
									</tr>
									<?php
								}
								?>
							</table>
						</td>
						<td>
							<?php
							if($data != '')
							{
								$sql0 = "SELECT `rank`,`username`,`id` FROM `$db`.`$user_logins_table` WHERE `username` LIKE '$data'";
								$result = mysql_query($sql0, $conn);
								$users = mysql_fetch_array($result);
								?>
								<form method="post" action="?func=uandp&mode=man_titles_edit&data=<?php echo $data;?>">
								<table width="100%">
									<tr>
										<th class="style4"><?php echo $users['username']; ?> Custom Title</th>
									</tr>
									<tr>
										<td class="dark" align="center" width="75%">
											<input type="text" name="rank" size="48" value="<?php echo $users['rank']; ?>">
											<input type="hidden" name="username" value="<?php echo $users['username']; ?>">
											<input type="hidden" name="user_id" value="<?php echo $users['id']; ?>">
										</td>
									</tr>
									<tr>
										<td align="center" colspan="2" class="light"><input type="submit" value="Update Title"></td>
									</tr>
								</table>
								</form>
								<?php
							}else
							{
								?>
								<table width="75%">
								<tr><td>Choose a user .... over there &#60;---- to the left...</td></tr>
								</table>
								<?php
							}
							?>
						</td>
					</tr>
				</table>
					<?php
			break;
			
			default:
				echo "Users and Permissions, Overview";
			break;
		}
	}
	
	
	##-----------------------------##
	##-----------------------------##
	##-----------------------------##
	function maint($mode = '')
	{
		$hosturl		= 	$GLOBALS['hosturl'];
		$conn			= 	$GLOBALS['conn'];
		$db				= 	$GLOBALS['db'];
		$db_st			= 	$GLOBALS['db_st'];
		$DB_stats		= 	$GLOBALS['DB_stats_table'];
		$daemon_perf_table =	$GLOBALS['daemon_perf_table'];
		$wtable			=	$GLOBALS['wtable'];
		$users_t		=	$GLOBALS['users_t'];
		$share_cache	=	$GLOBALS['share_cache'];
		$gps_ext		=	$GLOBALS['gps_ext'];
		$files			=	$GLOBALS['files'];
		$user_logins_table = $GLOBALS['user_logins_table'];
		$root			= 	$GLOBALS['root'];
		$half_path		=	$GLOBALS['half_path'];
		$theme			=	$GLOBALS['theme'];
		$date_format	=	"Y-m-d H:i:s";


		switch($mode)
		{
			case "clean_tmp_proc":
				?>
				<table border="1" width="80%">
					<tr class="style4">
						<th>Temporary Folder Clean Up Status...</th>
					</tr>
				<?php
				$farc = 'out/archive/tmp_folder_archive_'.rand().'.zip';
				$filearc = $half_path.$farc;
				$home = $half_path.'tmp/';
			#	echo $filearc.'<br><br>$_POST["arc_file"]';
				$row = 0;
				$zip = new ZipArchive;
				if (!$zip->open($filearc, ZipArchive::CREATE))
				{die("Could not create Archive file ($filearc)");}
			#	dump($_POST['arc_file']);
				if(count($_POST['arc_file']) > 0)
				{
					?>
					<tr class="style4">
						<th>Archive Temp Folder Files</th>
					</tr>
					<?php
					$arc_file_flag = 1;
					foreach($_POST['arc_file'] as $arc_file)
					{
					#	echo $half_path.'tmp/'.$arc_file.'<br>';
						if($zip->addFile($half_path.'tmp/'.$arc_file, $arc_file))
						{
							if($row){$style="light";$row=0;}else{$style="dark";$row=1;}
							?>
							<tr class="<?php echo $style;?>">
								<td><?php echo "Added file: ".$arc_file;?></td>
							</tr>
							<?php
						}else
						{
							?>
							<tr class="bad">
								<td><?php echo "Failed to Add file: ".$arc_file;?></td>
							</tr>
							<?php
							$arc_file_flag = 0;
						}
					}
					?>
					<tr class="good">
						<th>All Zipped up!</th>
					</tr>
					<?php
					
				}else
				{
					$arc_file_flag = 1;
					?>
					<tr class="style4">
						<th>No Temp Folder Files Selected To Archive</th>
					</tr>
					<?php
				}
				
			#	echo '<br><br>$_POST["del_file"]';
			#	dump($_POST['del_file']);
				if(count($_POST['del_file']) > 0 and $arc_file_flag === 1)
				{
					?>
					<tr class="style4">
						<th>Delete Temp Folder Files</th>
					</tr>
					<?php
					$del_no=0;
					$del_yes=0;
					foreach($_POST['del_file'] as $del_file)
					{
						if(unlink($home.$del_file))
						{
							if($row){$style="light";$row=0;}else{$style="dark";$row=1;}
							?>
							<tr class="<?php echo $style;?>">
								<td><?php echo "File ($del_file) deleted";?></td>
							</tr>
							<?php
							$del_yes++;
						}
						else
						{
							?>
							<tr class="bad">
								<td><?php echo "File ($del_file) Could not be deleted";?></td>
							</tr>
							<?php
							$del_no++;
						}
					}
					if($del_yes > 0){$style = "good";}else{$style="bad";}
					?>
					<tr class="<?php echo $style;?>">
						<th><?php echo "Done, $del_yes files Deleted and $del_no files had an error deleting"; ?></th>
					</tr>
					<?php
				}elseif($arc_file_flag == 0)
				{
					?>
					<tr class="bad">
						<th>A file could not be archived, will not delete any files, check things out and try again.</th>
					</tr>
					<?php
				}else
				{
					?>
					<tr class="style4">
						<th>No files selected for Deletion.</th>
					</tr>
					<?php
				}
				#################################
				#################################
				#################################
			#	echo '<br><br>$_POST["arc_dir"]';
			#	dump($_POST['arc_dir']);
				if(count($_POST['arc_dir']) > 0 )
				{
					?>
					<tr class="style4">
						<th>Archive Folder in Temp Folder</th>
					</tr>
					<?php
					$arc_dir_flag = 1;
					foreach($_POST['arc_dir'] as $arc_file)
					{
					#	echo $half_path.'tmp/'.$arc_file.'<br>';
						?>
						<tr class="style4">
							<th><?php echo "Archiving Folder: ".$arc_file; ?></th>
						</tr>
						<?php
						$Folder = $half_path.'tmp/'.$arc_file;
					#	$zip->addEmptyDir($arc_file);
						$dh	= opendir($Folder) or die("couldn't open directory");
						while(!(($file = readdir($dh)) == false))
						{
							if($row){$style="light";$row=0;}else{$style="dark";$row=1;}
						#	echo filetype($Folder.'/'.$file)."<br>";
							if(filetype($Folder.'/'.$file) == 'dir'){continue;}
							if($zip->addFile($half_path.'tmp/'.$arc_file.'/'.$file, $arc_file.'/'.$file))
							{
								?>
								<tr class="<?php echo $style;?>">
									<td><?php echo "Added File ($arc_file/$file) to archive"; ?></td>
								</tr>
								<?php
							}
							else
							{
								?>
								<tr class="bad">
									<td><?php echo "Failed to add file ($arc_file/$file) to archive"; ?></td>
								</tr>
								<?php
								$arc_dir_flag = 0;
							}
						}
						?>
						<tr class="good">
							<th><?php echo "Finished Archiving Folder: ".$arc_file; ?></th>
						</tr>
						<?php
					}
					?>
					<tr class="good">
						<th><?php echo "Finished Archiving Folders"; ?></th>
					</tr>
					<?php
				}else
				{
					?>
					<tr class="style4">
						<th>No Folders Selected to Archive</th>
					</tr>
					<?php
					$arc_dir_flag = 1;
				}
				
			#	echo '<br><br>$_POST["del_dir"]';
			#	dump($_POST['del_dir']);
				if(count($_POST['del_dir']) > 0 and $arc_dir_flag === 1)
				{
					?>
					<tr class="style4">
						<th>Deleting Folders in Temp</th>
					</tr>
					<?php
					$del_dir_flag = 1;
					foreach($_POST['del_dir'] as $del_dir)
					{
						recur_del_dir($home.$del_dir);
					}
					?>
					<tr class="good">
						<th><?php echo "Finished Deleting Folders"; ?></th>
					</tr>
					<?php
				}else
				{
					?>
					<tr class="style4">
						<th>No Folders Selected For Deletion</th>
					</tr>
					<?php
				}
				$zip->close();
				?>
					<tr class="style4">
						<th><a href="/<?php echo $root.'/'.$farc;?>" class="links">Temp Folder Archive</a> is ready.<br>( <?php echo $farc;?> )</th>
					</tr>
				</table><?php
			break;
			
###############################################################################################			
			########################
			case "clean_tmp":
				$directory = $half_path."/tmp/";
			#	echo dirSize("tmp/");
				$size = 0;
				?>
				<script type="text/javascript">
				<!--
				function SetAllCheckBoxes(FormName, FieldName, CheckValue)
				{
					if(!document.forms[FormName])
						return;
					var objCheckBoxes = document.forms[FormName].elements[FieldName];
					if(!objCheckBoxes)
						return;
					var countCheckBoxes = objCheckBoxes.length;
					if(!countCheckBoxes)
						objCheckBoxes.checked = CheckValue;
					else
						// set the check value for all check boxes
						for(var i = 0; i < countCheckBoxes; i++)
							objCheckBoxes[i].checked = CheckValue;
				}
				// -->
				</script>

				<form name="temp_folder" action="?func=maint&mode=clean_tmp_proc" method="POST">
				<table border="1" width="80%">
					<tr class="style4">
						<th colspan="4">Temporary Folder</th>
					</tr>
					<tr class="style4">
						<th>
							Delete<br>
							
						</th>
						<th>
							Archive<br>
							
						</th><th width="80%">Filename</th><th>Filesize</th>
					</tr>
				<?php
				$row=0;
				$n=0;
				$dh	= opendir($directory) or die("couldn't open directory");
				while(!(($file = readdir($dh)) == false))
				{
					
					if($file == '.svn' or $file == '.' or $file == '..'){continue;}
					if($row){$style="light";$row=0;}else{$style="dark";$row=1;}
					$typepath = $directory.$file;
				#	echo filetype ($typepath)."<br>";
					if(filetype ($typepath) == 'file')
					{
						$size += dos_filesize($typepath);
				#		echo $typepath."(".format_size(dos_filesize($typepath), 2).")<br>\r\n";
						?>
						<tr class="<?php echo $style;?>">
							<td><input type="checkbox" name="del_file[]" value="<?php echo $file;?>"></td>
							<td><input type="checkbox" name="arc_file[]" value="<?php echo $file;?>"></td>
							<td><?php echo $file; ?></td>
							<td><?php echo format_size(dos_filesize($typepath), 2);?></td>
						</tr>
						<?php
					}else
					{
						$size += dos_filesize($typepath);
						list($size_dir) = dirsize($typepath);
					#	echo $typepath."(".format_size($size_dir, 2).")<br>\r\n";
						?>
						<tr class="<?php echo $style;?>">
							<td><input type="checkbox" name="del_dir[]" value="<?php echo $file;?>"></td>
							<td><input type="checkbox" name="arc_dir[]" value="<?php echo $file;?>"></td>
							<td><strong><?php echo $file; ?></strong></td>
							<td><?php echo format_size($size_dir, 2);?></td>
						</tr>
						<?php
					}
					$n++;
				}
				if($n==0)
				{
				?>
						<tr class="style4">
							<td colspan="4">There are no files in the 'tmp' folder.</td>
						</tr>
						<?php
				}else
				{
				?>
				<tr class="style4">
					<td>
						<input type="button" onclick="SetAllCheckBoxes('temp_folder', 'del_file[]', true);SetAllCheckBoxes('temp_folder', 'del_dir[]', true);" value="Check">
						<input type="button" onclick="SetAllCheckBoxes('temp_folder', 'del_file[]', false);SetAllCheckBoxes('temp_folder', 'del_dir[]', false);" value="Uncheck">
					</td>
					<td>
						<input type="button" onclick="SetAllCheckBoxes('temp_folder', 'arc_file[]', true);SetAllCheckBoxes('temp_folder', 'arc_dir[]', true);" value="Check">
						<input type="button" onclick="SetAllCheckBoxes('temp_folder', 'arc_file[]', false);SetAllCheckBoxes('temp_folder', 'arc_dir[]', false);" value="Uncheck">
					</td>
					<td> &nbsp;</td>
					<td> &nbsp;</td>
				</tr>
				<tr class="style4">
					<td colspan="4" align="center">
						<input type='submit' value='submit'>
					</td>
				</tr>
				<?php
				}
				?>
				<tr class="style4">
					<td colspan="4" align="center">
						Total Temp Folder Size: <?php echo format_size($size,2);?>
					</td>
				</tr>
				</table>
				</form>
				<?php
			break;
########################################################################################	#		
			case "clean_upload_proc":
				?>
				<table border="1" width="80%">
					<tr class="style4">
						<th>Upload Folder Clean Up Status...</th>
					</tr>
				<?php
				$farc = 'out/archive/upload_folder_archive_'.rand().'.zip';
				$filearc = $half_path.$farc;
				$part = 'import/up/';
				$home = $half_path.$part;
			#	echo $filearc.'<br><br>$_POST["arc_file"]';
				$row = 0;
				$zip = new ZipArchive;
				if (!$zip->open($filearc, ZipArchive::CREATE))
				{die("Could not create Archive file ($filearc)");}
			#	dump($_POST['arc_file']);
				if(count($_POST['arc_file']) > 0)
				{
					?>
					<tr class="style4">
						<th>Archive Upload Folder Files</th>
					</tr>
					<?php
					$arc_file_flag = 1;
					foreach($_POST['arc_file'] as $arc_file)
					{
					#	echo $half_path.'tmp/'.$arc_file.'<br>';
						if($zip->addFile($half_path.$part.$arc_file, $arc_file))
						{
							if($row){$style="light";$row=0;}else{$style="dark";$row=1;}
							?>
							<tr class="<?php echo $style;?>">
								<td><?php echo "Added file: ".$arc_file;?></td>
							</tr>
							<?php
						}else
						{
							?>
							<tr class="bad">
								<td><?php echo "Failed to Add file: ".$arc_file;?></td>
							</tr>
							<?php
							$arc_file_flag = 0;
						}
					}
					?>
					<tr class="good">
						<th>All Zipped up!</th>
					</tr>
					<?php
					
				}else
				{
					$arc_file_flag = 1;
					?>
					<tr class="style4">
						<th>No Upload Folder Files Selected To Archive</th>
					</tr>
					<?php
				}
				
			#	echo '<br><br>$_POST["del_file"]';
			#	dump($_POST['del_file']);
				if(count($_POST['del_file']) > 0 and $arc_file_flag === 1)
				{
					?>
					<tr class="style4">
						<th>Delete Temp Folder Files</th>
					</tr>
					<?php
					$del_no=0;
					$del_yes=0;
					foreach($_POST['del_file'] as $del_file)
					{
						if(unlink($home.$del_file))
						{
							if($row){$style="light";$row=0;}else{$style="dark";$row=1;}
							?>
							<tr class="<?php echo $style;?>">
								<td><?php echo "File ($del_file) deleted";?></td>
							</tr>
							<?php
							$del_yes++;
						}
						else
						{
							?>
							<tr class="bad">
								<td><?php echo "File ($del_file) Could not be deleted";?></td>
							</tr>
							<?php
							$del_no++;
						}
					}
					if($del_yes > 0){$style = "good";}else{$style="bad";}
					?>
					<tr class="<?php echo $style;?>">
						<th><?php echo "Done, $del_yes files Deleted and $del_no files had an error deleting"; ?></th>
					</tr>
					<?php
				}elseif($arc_file_flag == 0)
				{
					?>
					<tr class="bad">
						<th>A file could not be archived, will not delete any files, check things out and try again.</th>
					</tr>
					<?php
				}else
				{
					?>
					<tr class="style4">
						<th>No files selected for Deletion.</th>
					</tr>
					<?php
				}
				#################################
				#################################
				#################################
			#	echo '<br><br>$_POST["arc_dir"]';
			#	dump($_POST['arc_dir']);
				if(count($_POST['arc_dir']) > 0 )
				{
					?>
					<tr class="style4">
						<th>Archive Folder in Upload Folder</th>
					</tr>
					<?php
					$arc_dir_flag = 1;
					foreach($_POST['arc_dir'] as $arc_file)
					{
					#	echo $half_path.'tmp/'.$arc_file.'<br>';
						?>
						<tr class="style4">
							<th><?php echo "Archiving Folder: ".$arc_file; ?></th>
						</tr>
						<?php
						$Folder = $half_path.$part.$arc_file;
					#	$zip->addEmptyDir($arc_file);
						$dh	= opendir($Folder) or die("couldn't open directory");
						while(!(($file = readdir($dh)) == false))
						{
							if($row){$style="light";$row=0;}else{$style="dark";$row=1;}
						#	echo filetype($Folder.'/'.$file)."<br>";
							if(filetype($Folder.'/'.$file) == 'dir'){continue;}
							if($zip->addFile($half_path.$part.$arc_file.'/'.$file, $arc_file.'/'.$file))
							{
								?>
								<tr class="<?php echo $style;?>">
									<td><?php echo "Added File ($arc_file/$file) to archive"; ?></td>
								</tr>
								<?php
							}
							else
							{
								?>
								<tr class="bad">
									<td><?php echo "Failed to add file ($arc_file/$file) to archive"; ?></td>
								</tr>
								<?php
								$arc_dir_flag = 0;
							}
						}
						?>
						<tr class="good">
							<th><?php echo "Finished Archiving Folder: ".$arc_file; ?></th>
						</tr>
						<?php
					}
					?>
					<tr class="good">
						<th><?php echo "Finished Archiving Folders"; ?></th>
					</tr>
					<?php
				}else
				{
					?>
					<tr class="style4">
						<th>No Folders Selected to Archive</th>
					</tr>
					<?php
					$arc_dir_flag = 1;
				}
				
			#	echo '<br><br>$_POST["del_dir"]';
			#	dump($_POST['del_dir']);
				if(count($_POST['del_dir']) > 0 and $arc_dir_flag === 1)
				{
					?>
					<tr class="style4">
						<th>Deleting Folders in Upload</th>
					</tr>
					<?php
					$del_dir_flag = 1;
					foreach($_POST['del_dir'] as $del_dir)
					{
						recur_del_dir($home.$del_dir);
					}
					?>
					<tr class="good">
						<th><?php echo "Finished Deleting Folders"; ?></th>
					</tr>
					<?php
				}else
				{
					?>
					<tr class="style4">
						<th>No Folders Selected For Deletion</th>
					</tr>
					<?php
				}
				$zip->close();
				?>
					<tr class="style4">
						<th><a href="/<?php echo $root.'/'.$farc;?>" class="links">Upload Folder Archive</a> is ready.<br>( <?php echo $farc;?> )</th>
					</tr>
				</table><?php
			break;
			
#######################################################################################			
			case "clean_upload":
			#	echo format_size(dirSize('import/up/'), $round = 2);
				$directory = $half_path."/import/up/";
			#	echo dirSize("tmp/");
				$size = 0;
				?>
				<script type="text/javascript">
				<!--
				function SetAllCheckBoxes(FormName, FieldName, CheckValue)
				{
					if(!document.forms[FormName])
						return;
					var objCheckBoxes = document.forms[FormName].elements[FieldName];
					if(!objCheckBoxes)
						return;
					var countCheckBoxes = objCheckBoxes.length;
					if(!countCheckBoxes)
						objCheckBoxes.checked = CheckValue;
					else
						// set the check value for all check boxes
						for(var i = 0; i < countCheckBoxes; i++)
							objCheckBoxes[i].checked = CheckValue;
				}
				// -->
				</script>

				<form name="upload_folder" action="?func=maint&mode=clean_upload_proc" method="POST">
				<table border="1" width="80%">
					<tr class="style4">
						<th colspan="4">Upload Folder</th>
					</tr>
					<tr class="style4">
						<th>
							Delete<br>
							
						</th>
						<th>
							Archive<br>
							
						</th><th width="80%">Filename</th><th>Filesize</th>
					</tr>
				<?php
				$row=0;
				$n=0;
				$dh	= opendir($directory) or die("couldn't open directory");
				while(!(($file = readdir($dh)) == false))
				{
					
					if($file == '.svn' or $file == '.' or $file == '..' or $file == 'index.php' or $file == '.htaccess'){continue;}
					if($row){$style="light";$row=0;}else{$style="dark";$row=1;}
					$typepath = $directory.$file;
				#	echo filetype ($typepath)."<br>";
					if(filetype ($typepath) == 'file')
					{
						$size += dos_filesize($typepath);
				#		echo $typepath."(".format_size(dos_filesize($typepath), 2).")<br>\r\n";
						?>
						<tr class="<?php echo $style;?>">
							<td><input type="checkbox" name="del_file[]" value="<?php echo $file;?>"></td>
							<td><input type="checkbox" name="arc_file[]" value="<?php echo $file;?>"></td>
							<td><?php echo $file; ?></td>
							<td><?php echo format_size(dos_filesize($typepath), 2);?></td>
						</tr>
						<?php
					}else
					{
						$size += dos_filesize($typepath);
						list($size_dir) = dirsize($typepath);
					#	echo $typepath."(".format_size($size_dir, 2).")<br>\r\n";
						?>
						<tr class="<?php echo $style;?>">
							<td><input type="checkbox" name="del_dir[]" value="<?php echo $file;?>"></td>
							<td><input type="checkbox" name="arc_dir[]" value="<?php echo $file;?>"></td>
							<td><strong><?php echo $file; ?></strong></td>
							<td><?php echo format_size($size_dir, 2);?></td>
						</tr>
						<?php
					}
					$n++;
				}
				if($n==0)
				{
				?>
						<tr class="style4">
							<td colspan="4">There are no files in the 'Upload' folder.</td>
						</tr>
						<?php
				}else
				{
				?>
				<tr class="style4">
					<td>
						<input type="button" onclick="SetAllCheckBoxes('upload_folder', 'del_file[]', true);SetAllCheckBoxes('upload_folder', 'del_dir[]', true);" value="Check">
						<input type="button" onclick="SetAllCheckBoxes('upload_folder', 'del_file[]', false);SetAllCheckBoxes('upload_folder', 'del_dir[]', false);" value="Uncheck">
					</td>
					<td>
						<input type="button" onclick="SetAllCheckBoxes('upload_folder', 'arc_file[]', true);SetAllCheckBoxes('upload_folder', 'arc_dir[]', true);" value="Check">
						<input type="button" onclick="SetAllCheckBoxes('upload_folder', 'arc_file[]', false);SetAllCheckBoxes('upload_folder', 'arc_dir[]', false);" value="Uncheck">
					</td>
					<td> &nbsp;</td>
					<td> &nbsp;</td>
				</tr>
				<tr class="style4">
					<td colspan="4" align="center">
						<input type='submit' value='submit'>
					</td>
				</tr>
				<?php
				}
				?>
				<tr class="style4">
					<td colspan="4" align="center">
						Total Upload Folder Size: <?php echo format_size($size,2);?>
					</td>
				</tr>
				</table>
				</form>
				<?php
			break;
			
######################################################################
			case "clean_signal_proc":
				?>
				<table border="1" width="80%">
					<tr class="style4">
						<th>Graph Folder Clean Up Status...</th>
					</tr>
				<?php
				$farc = 'out/archive/graphs_folder_archive_'.rand().'.zip';
				$filearc = $half_path.$farc;
				$part = 'out/graph/';
				$home = $half_path.$part;
			#	echo $filearc.'<br><br>$_POST["arc_file"]';
				$row = 0;
				$zip = new ZipArchive;
				if (!$zip->open($filearc, ZipArchive::CREATE))
				{die("Could not create Archive file ($filearc)");}
			#	dump($_POST['arc_file']);
				if(count($_POST['arc_file']) > 0)
				{
					?>
					<tr class="style4">
						<th>Archive Graph Folder Files</th>
					</tr>
					<?php
					$arc_file_flag = 1;
					foreach($_POST['arc_file'] as $arc_file)
					{
					#	echo $half_path.'tmp/'.$arc_file.'<br>';
						if($zip->addFile($half_path.$part.$arc_file, $arc_file))
						{
							if($row){$style="light";$row=0;}else{$style="dark";$row=1;}
							?>
							<tr class="<?php echo $style;?>">
								<td><?php echo "Added file: ".$arc_file;?></td>
							</tr>
							<?php
						}else
						{
							?>
							<tr class="bad">
								<td><?php echo "Failed to Add file: ".$arc_file;?></td>
							</tr>
							<?php
							$arc_file_flag = 0;
						}
					}
					?>
					<tr class="good">
						<th>All Zipped up!</th>
					</tr>
					<?php
					
				}else
				{
					$arc_file_flag = 1;
					?>
					<tr class="style4">
						<th>No Graph Folder Files Selected To Archive</th>
					</tr>
					<?php
				}
				
			#	echo '<br><br>$_POST["del_file"]';
			#	dump($_POST['del_file']);
				if(count($_POST['del_file']) > 0 and $arc_file_flag === 1)
				{
					?>
					<tr class="style4">
						<th>Delete Graph Folder Files</th>
					</tr>
					<?php
					$del_no=0;
					$del_yes=0;
					foreach($_POST['del_file'] as $del_file)
					{
						if(unlink($home.$del_file))
						{
							if($row){$style="light";$row=0;}else{$style="dark";$row=1;}
							?>
							<tr class="<?php echo $style;?>">
								<td><?php echo "File ($del_file) deleted";?></td>
							</tr>
							<?php
							$del_yes++;
						}
						else
						{
							?>
							<tr class="bad">
								<td><?php echo "File ($del_file) Could not be deleted";?></td>
							</tr>
							<?php
							$del_no++;
						}
					}
					if($del_yes > 0){$style = "good";}else{$style="bad";}
					?>
					<tr class="<?php echo $style;?>">
						<th><?php echo "Done, $del_yes files Deleted and $del_no files had an error deleting"; ?></th>
					</tr>
					<?php
				}elseif($arc_file_flag == 0)
				{
					?>
					<tr class="bad">
						<th>A file could not be archived, will not delete any files, check things out and try again.</th>
					</tr>
					<?php
				}else
				{
					?>
					<tr class="style4">
						<th>No files selected for Deletion.</th>
					</tr>
					<?php
				}
				#################################
				#################################
				#################################
			#	echo '<br><br>$_POST["arc_dir"]';
			#	dump($_POST['arc_dir']);
				if(count($_POST['arc_dir']) > 0 )
				{
					?>
					<tr class="style4">
						<th>Archive Folder in Graph Folder</th>
					</tr>
					<?php
					$arc_dir_flag = 1;
					foreach($_POST['arc_dir'] as $arc_file)
					{
					#	echo $half_path.'tmp/'.$arc_file.'<br>';
						?>
						<tr class="style4">
							<th><?php echo "Archiving Folder: ".$arc_file; ?></th>
						</tr>
						<?php
						$Folder = $half_path.$part.$arc_file;
					#	$zip->addEmptyDir($arc_file);
						$dh	= opendir($Folder) or die("couldn't open directory");
						while(!(($file = readdir($dh)) == false))
						{
							if($row){$style="light";$row=0;}else{$style="dark";$row=1;}
						#	echo filetype($Folder.'/'.$file)."<br>";
							if(filetype($Folder.'/'.$file) == 'dir'){continue;}
							if($zip->addFile($half_path.$part.$arc_file.'/'.$file, $arc_file.'/'.$file))
							{
								?>
								<tr class="<?php echo $style;?>">
									<td><?php echo "Added File ($arc_file/$file) to archive"; ?></td>
								</tr>
								<?php
							}
							else
							{
								?>
								<tr class="bad">
									<td><?php echo "Failed to add file ($arc_file/$file) to archive"; ?></td>
								</tr>
								<?php
								$arc_dir_flag = 0;
							}
						}
						?>
						<tr class="good">
							<th><?php echo "Finished Archiving Folder: ".$arc_file; ?></th>
						</tr>
						<?php
					}
					?>
					<tr class="good">
						<th><?php echo "Finished Archiving Folders"; ?></th>
					</tr>
					<?php
				}else
				{
					?>
					<tr class="style4">
						<th>No Folders Selected to Archive</th>
					</tr>
					<?php
					$arc_dir_flag = 1;
				}
				
			#	echo '<br><br>$_POST["del_dir"]';
			#	dump($_POST['del_dir']);
				if(count($_POST['del_dir']) > 0 and $arc_dir_flag === 1)
				{
					?>
					<tr class="style4">
						<th>Deleting Folders in Graph</th>
					</tr>
					<?php
					$del_dir_flag = 1;
					foreach($_POST['del_dir'] as $del_dir)
					{
						recur_del_dir($home.$del_dir);
					}
					?>
					<tr class="good">
						<th><?php echo "Finished Deleting Folders"; ?></th>
					</tr>
					<?php
				}else
				{
					?>
					<tr class="style4">
						<th>No Folders Selected For Deletion</th>
					</tr>
					<?php
				}
				$zip->close();
				?>
					<tr class="style4">
						<th><a href="/<?php echo $root.'/'.$farc;?>" class="links">Graph Folder Archive</a> is ready.<br>( <?php echo $farc;?> )</th>
					</tr>
				</table><?php
			break;
			
###################################################################################################
			case "clean_signal":
			#	echo format_size(dirSize('out/graph/'), $round = 2);
				$directory = $half_path.'/out/graph/';
			#	echo dirSize("tmp/");
				$size = 0;
				?>
				<script type="text/javascript">
				<!--
				function SetAllCheckBoxes(FormName, FieldName, CheckValue)
				{
					if(!document.forms[FormName])
						return;
					var objCheckBoxes = document.forms[FormName].elements[FieldName];
					if(!objCheckBoxes)
						return;
					var countCheckBoxes = objCheckBoxes.length;
					if(!countCheckBoxes)
						objCheckBoxes.checked = CheckValue;
					else
						// set the check value for all check boxes
						for(var i = 0; i < countCheckBoxes; i++)
							objCheckBoxes[i].checked = CheckValue;
				}
				// -->
				</script>

				<form name="graph_folder" action="?func=maint&mode=clean_signal_proc" method="POST">
				<table border="1" width="80%">
					<tr class="style4">
						<th colspan="4">Graphs Folder</th>
					</tr>
					<tr class="style4">
						<th>Delete</th><th>Archive</th><th width="80%">Filename</th><th>Filesize</th>
					</tr>
				<?php
				$row=0;
				$n=0;
				$dh	= opendir($directory) or die("couldn't open directory");
				while(!(($file = readdir($dh)) == false))
				{
					
					if($file == '.svn' or $file == '.' or $file == '..' or $file == 'index.php' or $file == '.htaccess'){continue;}
					if($row){$style="light";$row=0;}else{$style="dark";$row=1;}
					$typepath = $directory.$file;
				#	echo filetype ($typepath)."<br>";
					if(filetype ($typepath) == 'file')
					{
						$size += dos_filesize($typepath);
				#		echo $typepath."(".format_size(dos_filesize($typepath), 2).")<br>\r\n";
						?>
						<tr class="<?php echo $style;?>">
							<td><input type="checkbox" name="del_file[]" value="<?php echo $file;?>"></td>
							<td><input type="checkbox" name="arc_file[]" value="<?php echo $file;?>"></td>
							<td><?php echo $file; ?></td>
							<td><?php echo format_size(dos_filesize($typepath), 2);?></td>
						</tr>
						<?php
					}else
					{
						$size += dos_filesize($typepath);
						list($size_dir) = dirsize($typepath);
					#	echo $typepath."(".format_size($size_dir, 2).")<br>\r\n";
						?>
						<tr class="<?php echo $style;?>">
							<td><input type="checkbox" name="del_dir[]" value="<?php echo $file;?>"></td>
							<td><input type="checkbox" name="arc_dir[]" value="<?php echo $file;?>"></td>
							<td><strong><?php echo $file; ?></strong></td>
							<td><?php echo format_size($size_dir, 2);?></td>
						</tr>
						<?php
					}
					$n++;
				}
				if($n==0)
				{
				?>
						<tr class="style4">
							<td colspan="4">There are no files in the 'Graphs' folder.</td>
						</tr>
						<?php
				}else
				{
				?>
				<tr class="style4">
					<td>
						<input type="button" onclick="SetAllCheckBoxes('graph_folder', 'del_file[]', true);SetAllCheckBoxes('graph_folder', 'del_dir[]', true);" value="Check">
						<input type="button" onclick="SetAllCheckBoxes('graph_folder', 'del_file[]', false);SetAllCheckBoxes('graph_folder', 'del_dir[]', false);" value="Uncheck">
					</td>
					<td>
						<input type="button" onclick="SetAllCheckBoxes('graph_folder', 'arc_file[]', true);SetAllCheckBoxes('graph_folder', 'arc_dir[]', true);" value="Check">
						<input type="button" onclick="SetAllCheckBoxes('graph_folder', 'arc_file[]', false);SetAllCheckBoxes('graph_folder', 'arc_dir[]', false);" value="Uncheck">
					</td>
					<td> &nbsp;</td>
					<td> &nbsp;</td>
				</tr>
				<tr class="style4">
					<td colspan="4" align="center">
						<input type='submit' value='submit'>
					</td>
				</tr>
				<?php
				}
				?>
				<tr class="style4">
					<td colspan="4" align="center">
						Total Graphs Folder Size: <?php echo format_size($size,2);?>
					</td>
				</tr>
				</table>
				</form>
				<?php
			break;
			
			default:
				echo "Maintenance, Overview";
			break;
		}
	}
	
	
	##-----------------------------##
	##-----------------------------##
	##-----------------------------##
	function sys($mode = '')
	{
		$root		= 	$GLOBALS['root'];
		$half_path	=	$GLOBALS['half_path'];
		$daemon = new daemon();
		switch($mode)
		{
			case "daemon":
				?>
				<table border='1' width="75%">
					<tr class="style4">
						<th colspan="4">WiFiDB Daemon's Control Panel</th>
					</tr>
					<tr>
						<td>
							<table border='1' width="100%">
							<tr class="style4">
								<th colspan="4">Import / Export Daemon</th>
							</tr>
							<?php
							$imp_exp_stat = $daemon->getdaemonstats();
							?>
							<tr class="style4">
								<th>
									<form name="imp_exp_start" action="?func=system&mode=daemon_proc" method="POST">
									<input type='hidden' name="daemon" value='imp_exp_daemon::start'>
									<input <?php if($imp_exp_stat){ echo 'disabled';} ?> type='submit' value='Start'>
									</form>
								</th>
								<th>
									<form name="imp_exp_stop" action="?func=system&mode=daemon_proc" method="POST">
									<input type='hidden' name="daemon" value='imp_exp_daemon::stop'>
									<input <?php if(!$imp_exp_stat){ echo 'disabled';} ?> type='submit' value='Stop'>
									</form>
								</th>
								<th>
									<form name="imp_exp_restart" action="?func=system&mode=daemon_proc" method="POST">
									<input type='hidden' name="daemon" value='imp_exp_daemon::restart'>
									<input <?php if(!$imp_exp_stat){ echo 'disabled';} ?> type='submit' value='Restart'>
									</form>
								</th><th></th>
							</tr>
							</table>
							
							<br>
							
							<table border='1' width="100%">
							<tr class="style4">
								<th colspan="4">Import / Export Performance Monitor Daemon</th>
							</tr>
							<?php
							$perf_stats = $daemon->getperfdaemonstats();
							?>
							<tr class="style4">
								<th>
									<form name="perfmon_start" action="?func=system&mode=daemon_proc" method="POST">
									<input type='hidden' name="daemon" value='perfmon_daemon::start'>
									<input <?php if($perf_stats){ echo 'disabled';} ?> type='submit' value='Start'>
									</form>
								</th>
								<th>
									<form name="perfmon_stop" action="?func=system&mode=daemon_proc" method="POST">
									<input type='hidden' name="daemon" value='perfmon_daemon::stop'>
									<input <?php if(!$perf_stats){ echo 'disabled';} ?> type='submit' value='Stop'>
									</form>
								</th>
								<th>
									<form name="perfmon_restart" action="?func=system&mode=daemon_proc" method="POST">
									<input type='hidden' name="daemon" value='perfmon_daemon::restart'>
									<input <?php if(!$perf_stats){ echo 'disabled';} ?> type='submit' value='Restart'>
									</form>
								</th><th></th>
							</tr>
							</table>
							
							<br>
							
							<table border='1' width="100%">
							<tr class="style4">
								<th colspan="4">Database Statistics Daemon</th>
							</tr>
							<?php
							$daemon_stats = $daemon->getdbdaemonstats();
							?>
							<tr class="style4">
								<th>
									<form name="dbstats_start" action="?func=system&mode=daemon_proc" method="POST">
									<input type='hidden' name="daemon" value='dbstats_daemon::start'>
									<input <?php if($daemon_stats){ echo 'disabled';} ?> type='submit' value='Start'>
									</form>
								</th>
								<th>
									<form name="dbstats_stop" action="?func=system&mode=daemon_proc" method="POST">
									<input type='hidden' name="daemon" value='dbstats_daemon::stop'>
									<input <?php if(!$daemon_stats){ echo 'disabled';} ?> type='Submit' value='Stop'>
									</form>
								</th>
								<th>
									<form name="dbstats_restart" action="?func=system&mode=daemon_proc" method="POST">
									<input type='hidden' name="daemon" value='dbstats_daemon::restart'>
									<input <?php if(!$daemon_stats){ echo 'disabled';} ?> type='submit' value='Restart'>
									</form>
								</th><th></th>
							</tr>
							</table>
						</td>
					</tr>
				</table>
				<?php
			break;
			
			case "daemon_proc":
				dump(get_defined_vars());
				dump($_POST);
				$post_exp = explode("::", $_POST['daemon']);
				$daemon_switch = $post_exp[0];
				$switch = $post_exp[1];
				switch($daemon_switch)
				{
					case "imp_exp_daemon":
						switch($switch)
						{
							case "start":
								if(!$daemon->getdaemonstats())
								{
									echo "Trying to start the Import / Export Daemon....<br>";
									if($daemon->start("imp_exp"))
									{
										sleep(2);
										$pidfile = @file($GLOBALS['pid_file_loc'].'imp_expd.pid');
										if($pidfile)
										{
											$PID =  $pidfile[0];
											echo "STARTED! :-]<br>WiFiDB 'Import/Export Daemon'<br>Version: 2.0.0<br>\t(/tools/daemon/imp_expd.php)<br>PID: [ $PID ]<br>";
										}else
										{
											echo "Failed to start the Import / Export Daemon :-[";
										}
									}else
									{
										echo "Failed to start the Import / Export Daemon :-[";
									}
								}else
								{
									echo "Import / Export Daemon already running, no need to start again...";
								}
							break;
							
							case "stop":
								echo "Stopping the Import / Export Daemon<br>";
							break;
							
							case "restart":
								echo "Restarting the Import / Export Daemon<br>";
							break;
						}
					break;
					
					case "perfmon_daemon":
						switch($switch)
						{
							case "start":
								echo "Starting the Import / Export Performance Monitor Daemon<br>";
								if(!$daemon->getperfdaemonstats())
								{
									$ret = $daemon->start("daemon_perf");
									if($ret == 1)
									{
										sleep(2);
										$pidfile = file($GLOBALS['pid_file_loc'].'daemonperfd.pid');
										$PID =  $pidfile[0];
										echo "STARTED! :-]<br>WiFiDB 'Import/Export Performance Monitor Daemon'<br>Version: 2.0.0<br>\t(/tools/daemon/daemonperfd.php)<br>PID: [ $PID ]<br>";
									}else
									{
										echo "Failed to start the Import / Export Performance Monitor Daemon :-[";
									}
								}else
								{
									echo "Performance Monitor daemon is already running, no need to start it again.";
								}
							break;
							
							case "stop":
								echo "Stopping the Import / Export Performance Monitor Daemon<br>";
							break;
							
							case "restart":
								echo "Restarting the Import / Export Performance Monitor Daemon<br>";
							break;
						}
					break;
					
					case "dbstats_daemon":
						switch($switch)
						{
							case "start":
								echo "Starting the Database Statistics Daemon<br>";
								if(!$daemon->getdbdaemonstats())
								{
									$ret = $daemon->start("daemon_stats", "");
									if($ret == 1)
									{
										sleep(2);
										$pidfile = file($GLOBALS['pid_file_loc'].'dbstatsd.pid');
										$PID =  $pidfile[0];
										echo "STARTED! :-]<br>WiFiDB 'Database Statistics Daemon'<br>Version: 2.0.0<br>\t(/tools/daemon/dbstatsd.php)<br>PID: [ $PID ]<br>";
									}else
									{
										echo "Failed to start the Database Statistics Daemon :-[";
									}
								}else
								{
									echo "Database Statistics Daemon is already running, no need to start it again.";
								}
							break;
							
							case "stop":
								echo "Stopping the Database Statistics Daemon<br>";
							break;
							
							case "restart":
								echo "Restarting the Database Statistics Daemon<br>";
							break;
						}
					break;
				}
				admin_footer();
			break;
			
			case "daemon_cfgproc":
				$file_ext = 'config.inc.php';
				$filename = $GLOBALS['wifidb_tools'].'/daemon/'.$file_ext;
				
				if (!copy($filename, $GLOBALS['wifidb_tools'].'/daemon/edits/'.date("Y-m-d-H:i:s").'_'.$file_ext))
				{
					die("Failed to copy $filename...");
				}
				if(!$filewrite = fopen($filename, "w")){die("could not write config file, check permissions?");}
				$fileappend = fopen($filename, "a");

				$default_user					= addslashes(strip_tags($_POST['default_user']));
				$default_title					= addslashes(strip_tags($_POST['default_title']));
				$default_notes					= addslashes(strip_tags($_POST['default_notes']));
				$wifidb_install					= addslashes(strip_tags($_POST['wifidb_install']));
				$console_line_limit				= addslashes(strip_tags($_POST['console_line_limit']));
				$console_trim_log				= addslashes(strip_tags(@$_POST['console_trim_log']));
				if($console_trim_log == 'on'){$console_trim_log = 1;}else{$console_trim_log = 0;}
				$pid_file_loc					= addslashes(strip_tags($_POST['pid_file_loc']));
				$daemon_log_folder				= addslashes(strip_tags($_POST['daemon_log_folder']));
				$php_install					= strip_tags($_POST['php_install']);
				$time_interval_to_check			= addslashes(strip_tags($_POST['time_interval_to_check']));
				$PERF_time_interval_to_check 	= addslashes(strip_tags($_POST['PERF_time_interval_to_check']));
				$DBSTATS_time_interval_to_check = addslashes(strip_tags($_POST['DBSTATS_time_interval_to_check']));
				$log_level						= addslashes(strip_tags($_POST['log_level']));
				$log_interval					= addslashes(strip_tags($_POST['log_interval']));
				$verbose						= addslashes(strip_tags($_POST['verbose']));
				if($verbose == 'on'){$verbose = 1;}else{$verbose = 0;}
				
				$colors_setting					= addslashes(strip_tags($_POST['colors_setting']));
				if($colors_setting == 'on'){$colors_setting = 1;}else{$colors_setting = 0;}
				
				$BAD_CT_COLOR					= addslashes(strip_tags($_POST['BAD_CT_COLOR']));
				$GOOD_CT_COLOR					= addslashes(strip_tags($_POST['GOOD_CT_COLOR']));
				$OTHER_CT_COLOR					= addslashes(strip_tags($_POST['OTHER_CT_COLOR']));
				$BAD_DBS_COLOR					= addslashes(strip_tags($_POST['BAD_DBS_COLOR']));
				$GOOD_DBS_COLOR					= addslashes(strip_tags($_POST['GOOD_DBS_COLOR']));
				$OTHER_DBS_COLOR				= addslashes(strip_tags($_POST['OTHER_DBS_COLOR']));
				$BAD_DPM_COLOR					= addslashes(strip_tags($_POST['BAD_DPM_COLOR']));
				$GOOD_DPM_COLOR					= addslashes(strip_tags($_POST['GOOD_DPM_COLOR']));
				$OTHER_DPM_COLOR				= addslashes(strip_tags($_POST['OTHER_DPM_COLOR']));
				$BAD_IED_COLOR					= addslashes(strip_tags($_POST['BAD_IED_COLOR']));
				$GOOD_IED_COLOR					= addslashes(strip_tags($_POST['GOOD_IED_COLOR']));
				$OTHER_IED_COLOR				= addslashes(strip_tags($_POST['OTHER_IED_COLOR']));
				$debug 							= addslashes(strip_tags(@$_POST['debug']));
				if($debug  == 'on'){$debug  = 1;}else{$debug  = 0;}
				$daemon_config = "<?php //#last edited -> ".date("Y-M-d H:i:s")."\r\nglobal $"."daemon_ver, $"."start_date, $"."last_edit;
global $"."wifidb_install, $"."log_level, $"."log_interval, $"."verbose, $"."dst, $"."time_interval_to_check, $"."daemon_log, $"."debug;
global $"."colors_setting, $"."default_user, $"."default_title, $"."default_notes, $"."dim, $"."console_line_limit;
global $"."PERF_time_interval_to_check, $"."DBSTATS_time_interval_to_check;
global $"."BAD_CT_COLOR, $"."GOOD_CT_COLOR, $"."OTHER_CT_COLOR, $"."BAD_DBS_COLOR, $"."GOOD_DBS_COLOR, $"."OTHER_DBS_COLOR, $"."BAD_DPM_COLOR, $"."GOOD_DPM_COLOR, $"."OTHER_DPM_COLOR, $"."BAD_IED_COLOR, $"."GOOD_IED_COLOR, $"."OTHER_IED_COLOR;
if(PHP_OS == 'WINNT')
{
\t$"."dim = '\\\\';
}
else
{
\t$"."dim = '/';
}

#############################################
#############################################
####   DO NOT TOUCH ABOVE THIS BLOCK,    ####
#### UNLESS YOU KNOW WHAT YOU ARE DOING. :)##
#############################################
#############################################


//Defaults for unclaimed imports
$"."default_user	= '$default_user';
$"."default_title	= '$default_title';
$"."default_notes	= '$default_notes';

//path to the folder that wifidb is installed in default is /var/www/wifidb/ , because I use Debian. fuck windows 
$"."wifidb_install		=	'$wifidb_install';
$"."console_line_limit	=	$console_line_limit;
$"."console_trim_log	=	$console_trim_log;
$"."pid_file_loc		=	'$pid_file_loc';
$"."daemon_log_folder	=	'$daemon_log_folder';

//IF you are running windows you need to define the install path to the PHP binary
$"."php_install	=	'$php_install';

//In seconds 1800 = 30 min interval
	//# Sleep for the Import/Export Daemon
$"."time_interval_to_check	=	$time_interval_to_check;
	//# Sleep for the I/E Daemon Performance Monitor (check every 5 minuets [300 seconds] by default.
$"."PERF_time_interval_to_check = $PERF_time_interval_to_check;
	//# Database Statistics Daemon sleep, really should be at once a day (86400 seconds) if you have a very large database.
$"."DBSTATS_time_interval_to_check = $DBSTATS_time_interval_to_check;

//The level that you want the log file to write, off (0), Errors only (1), Detailed Errors [when available] (2). That is all for now.
$"."log_level	=	$log_level;

//0, one file 'log/wifidbd_log.log'. 1, one file a day 'log/wifidbd_log_[yyyy-mm-dd].log'.
$"."log_interval	=	$log_interval;

//0; no out put, STUF, 1; let me see the world.
$"."verbose	=	$verbose;

//if you want the CLI output to be color coded 1 = ON, 0 = OFF
//if you ware running windows, this is disabled for you, so even if you turn it on, its not going to work :-p
$"."colors_setting	=	$colors_setting;

//Default colors for the CLI
//Allowed colors:
	//LIGHTGRAY, BLUE, GREEN, RED, YELLOW
	//wifidbd.php
$"."BAD_CT_COLOR	=	'$BAD_CT_COLOR';
$"."GOOD_CT_COLOR	=	'$GOOD_CT_COLOR';
$"."OTHER_CT_COLOR	=	'$OTHER_CT_COLOR';
	//dbstatsd.php
$"."BAD_DBS_COLOR	=	'$BAD_DBS_COLOR';
$"."GOOD_DBS_COLOR	=	'$GOOD_DBS_COLOR';
$"."OTHER_DBS_COLOR	=	'$OTHER_DBS_COLOR';
	//daemonperfd.php
$"."BAD_DPM_COLOR	=	'$BAD_DPM_COLOR';
$"."GOOD_DPM_COLOR	=	'$GOOD_DPM_COLOR';
$"."OTHER_DPM_COLOR	=	'$OTHER_DPM_COLOR';
	//imp_expd.php
$"."BAD_IED_COLOR	=	'$BAD_IED_COLOR';
$"."GOOD_IED_COLOR	=	'$GOOD_IED_COLOR';
$"."OTHER_IED_COLOR	=	'$OTHER_IED_COLOR';

//Debug functions turned on, may also include dropping tables and re-createing them 
//so only turn on if you really know what you are doing
$"."debug = $debug;\r\n?>";

#	echo "<table><tr><td>".str_replace("\n", "<br>", $daemon_config)."</td></tr></table>";
	
				if(fwrite($fileappend, $daemon_config))
				{
					redirect_page('?func=system&mode=daemon_config', 5000, "<b>Daemon Config file has been writen.<br>You will now need to restart the Daemons for the setting changes to take effect.</b>");
				}else
				{
					echo "Failed to write the Daemon config file, check permissions?";
				}
			break;
			
			case "daemon_config":
				$file_ext = 'config.inc.php';
				$filename = $GLOBALS['wifidb_tools'].'/daemon/'.$file_ext;
				include($filename);
				?>
				<form name="WiFiDB_daemon_cfg_form" action="?func=system&mode=daemon_cfgproc" method="post" enctype="multipart/form-data">
				<h2>Edit the WifiDB Daemon Config File.</h2>
				<table width="75%" border="1" cellspacing="0" cellpadding="0">
				<tr><th colspan="2" class="style4">Basic WiFiDB Settings<p align="right"><a class="links" href="<?php echo $GLOBALS['hosturl'].$GLOBALS['root'].'/cp/admin/help/index.php?topic=Daemon_config'; ?>" target="_new">Help?</p></th></tr>
				  <tr class="dark">
					<td >Default User</td>
					<td style="width: 60%"><input style="width: 100%" name="default_user" value="<?php echo $default_user; ?>"></td></tr>
				  <tr class="dark">
					<td >Default Title</td>
					<td><input style="width: 100%" name="default_title" value="<?php echo $default_title; ?>"></td></tr>
				  <tr class="dark">
					<td >Default Notes</td>
					<td><input style="width: 100%" name="default_notes" value="<?php echo $default_notes; ?>"></td></tr>
				  <tr class="dark">
					<td >WifiDB Install Folder</td>
					<td><input style="width: 100%" name="wifidb_install" value="<?php echo $wifidb_install; ?>"></td></tr>
				  <tr class="dark">
					<td >Console Line Limit</td>
					<td ><input style="width: 25%" name="console_line_limit" value="<?php echo $console_line_limit; ?>"></td></tr>
				  <tr class="dark">
					<td >Console Trim Log</td>
					<td ><input type="checkbox" name="console_trim_log" <?php if($console_trim_log){echo ' CHECKED';} ?> ></td></tr>
				  <tr class="dark">
					<td >PID File Location</td>
					<td style="width: 60%"><input style="width: 100%" name="pid_file_loc" value="<?php echo $pid_file_loc; ?>"></td></tr>
				  <tr class="dark">
					<td >PHP Install Folder</td>
					<td><input style="width: 100%" name="php_install" value="<?php echo $php_install; ?>"></td></tr>
				  <tr>
					<th colspan="2" class="style4">Daemon Time Intervals to Check (Seconds)</th>
				  </tr>
				  <tr class="dark">
					<td >Import / Export</td>
					<td ><input name="time_interval_to_check" value="<?php echo $time_interval_to_check; ?>"></td></tr>
				  <tr class="dark">
					<td >Performance Monitor</td>
					<td ><input name="PERF_time_interval_to_check" value="<?php echo $PERF_time_interval_to_check; ?>"></td>
				</TR>
				  <tr class="dark">
					<td >Database Statistics Daemon</td>
					<td ><input name="DBSTATS_time_interval_to_check" value="<?php echo $DBSTATS_time_interval_to_check; ?>"></td>
				</TR>
				  <tr>
					<th colspan="2" class="style4">Logging Settings</th>
				</TR>
				  <tr class="dark">
					<td >Log Level</td>
					<td ><input name="log_level" value="<?php echo $log_level; ?>"></td>
				</TR>
				  <tr class="dark">
					<td >Log Interval</td>
					<td ><input name="log_interval" value="<?php echo $log_interval; ?>"></td>
				</TR>
				<tr class="dark">
					<td >Daemon Log Folder</td>
					<td><input style="width: 100%" name="daemon_log_folder" value="<?php echo $daemon_log_folder; ?>"></td>
				</tr>
				<tr>
					<th class="style4" colspan="2">Output Settings</th>
				</TR>
				  <tr class="dark">
					<td >Verbose</td>
					<td ><input type="checkbox" name="verbose" <?php if($verbose){echo 'CHECKED';} ?> ></td>
				</TR>
				  <tr class="dark">
					<td >Colors (on/off)</td>
					<td ><input type="checkbox" name="colors_setting" <?php if($colors_setting){echo 'CHECKED';} ?> ></td>
				</TR>
				<tr class="dark">
					<TD>Debug</TD>
					<td><input type="checkbox" name="debug" <?php if($debug){echo 'CHECKED';}?> ></td>
				</tr>

				  <tr>
					<th colspan="2" class="style4">Daemon Control Colors</th>
				</TR>
				  <tr class="dark">
					<td >Bad</td>
					<td ><input name="BAD_CT_COLOR" value="<?php echo $BAD_CT_COLOR; ?>"></td>
				</TR>
				  <tr class="dark">
					<td >Good</td>
					<td ><input name="GOOD_CT_COLOR" value="<?php echo $GOOD_CT_COLOR; ?>"></td>
				</TR>
				<TR class="dark">
					<TD >Other</TD>
					<td><input name="OTHER_CT_COLOR" value="<?php echo $OTHER_CT_COLOR; ?>"></td>
				</TR>
				<tr>
				<Th colspan="2" class="style4">Database Statistics Daemon Colors</Th>
				</tr>
				<tr class="dark">
				<TD >Bad</TD>
								<td><input name="BAD_DBS_COLOR" value="<?php echo $BAD_DBS_COLOR; ?>"></td>
				</tr>
				<tr class="dark">
				<TD >Good</TD>
								<td><input name="GOOD_DBS_COLOR" value="<?php echo $GOOD_DBS_COLOR; ?>"></td>
				</tr>
				<tr class="dark">
				<TD >Other</TD>
								<td><input name="OTHER_DBS_COLOR" value="<?php echo $OTHER_DBS_COLOR; ?>"></td>
				</tr>
				<tr>
				<Th colspan="2" class="style4">Daemon Perfomance Monitor Colors</Th>
				</tr>
				<tr class="dark">
				<TD >Bad</TD>
								<td><input name="BAD_DPM_COLOR" value="<?php echo $BAD_DPM_COLOR; ?>"></td>
				</tr>
				<tr class="dark">
				<TD >Good</TD>
								<td><input name="GOOD_DPM_COLOR" value="<?php echo $GOOD_DPM_COLOR; ?>"></td>
				</tr>
				<tr class="dark">
				<TD >Other</TD>
								<td><input name="OTHER_DPM_COLOR" value="<?php echo $OTHER_DPM_COLOR; ?>"></td>
				</tr>
				<tr>
				<Th colspan="2" class="style4">Import / Export Daemon Colors</Th>
				</tr>
				<tr class="dark">
				<TD >Bad</TD>
								<td><input name="BAD_IED_COLOR" value="<?php echo $BAD_IED_COLOR; ?>"></td>
				</tr>
				<tr class="dark">
				<TD >Good</TD>
								<td><input name="GOOD_IED_COLOR" value="<?php echo $GOOD_IED_COLOR; ?>"></td>
				</tr>
				<tr class="dark">
				<TD >Other</TD>
								<td><input name="OTHER_IED_COLOR" value="<?php echo $OTHER_IED_COLOR; ?>"></td>
				</tr>
				<TR class="style4"><TD colspan="2" class="daemon_kml">
				<INPUT TYPE=SUBMIT NAME="submit" VALUE="Submit" STYLE="width: 0.71in; height: 0.36in">
				</TD>
				</TR>
				</TABLE>
				</form>
				<?php
			break;
			
			case "db_config_proc":
				$wifidb_tools		=	addslashes(strip_tags($_POST['wifidb_tools']));
				$wifidb_install		=	addslashes(strip_tags($_POST['wifidb_install']));
				$root				=	addslashes(strip_tags($_POST['root']));
				$hosturl			=	addslashes(strip_tags($_POST['hosturl']));
				$admin_email		=	addslashes(strip_tags($_POST['admin_email']));
				$config_fails		=	addslashes(strip_tags($_POST['config_fails']));
				$daemon				=	addslashes(strip_tags($_POST['daemon']));
				$WiFiDB_LNZ_User 	=	addslashes(strip_tags($_POST['WiFiDB_LNZ_User']));
				$apache_grp			=	addslashes(strip_tags($_POST['apache_grp']));
				$default_theme		=	addslashes(strip_tags($_POST['default_theme']));
				$default_refresh 	=	addslashes(strip_tags($_POST['default_refresh']));
				$timeout			=	addslashes(strip_tags($_POST['timeout']));
				$console_refresh	=	addslashes(strip_tags($_POST['console_refresh']));
				$console_scroll		=	addslashes(strip_tags($_POST['console_scroll']));
				$console_last5		=	addslashes(strip_tags($_POST['console_last5']));
				$console_lines		=	addslashes(strip_tags($_POST['console_lines']));
				$console_log		=	addslashes(strip_tags($_POST['console_log']));
				$bypass_check		=	addslashes(strip_tags($_POST['bypass_check']));
				$rebuild			=	addslashes(strip_tags($_POST['rebuild']));
				$bench				=	addslashes(strip_tags($_POST['bench']));
				$debug				=	addslashes(strip_tags($_POST['debug']));
				$settings_tb		=	addslashes(strip_tags($_POST['settings_tb']));
				$users_t			=	addslashes(strip_tags($_POST['users_t']));
				$links				=	addslashes(strip_tags($_POST['links']));
				$wtable				=	addslashes(strip_tags($_POST['wtable']));
				$user_logins_table	=	addslashes(strip_tags($_POST['user_logins_table']));
				$validate_table		=	addslashes(strip_tags($_POST['validate_table']));
				$share_cache		=	addslashes(strip_tags($_POST['share_cache']));
				$files				=	addslashes(strip_tags($_POST['files']));
				$files_tmp			=	addslashes(strip_tags($_POST['files_tmp']));
				$annunc				=	addslashes(strip_tags($_POST['annunc']));
				$annunc_comm		=	addslashes(strip_tags($_POST['annunc_comm']));
				$gps_ext			=	addslashes(strip_tags($_POST['gps_ext']));
				$sep				=	addslashes(strip_tags($_POST['sep']));
				$db					=	addslashes(strip_tags($_POST['db']));
				$db_st				=	addslashes(strip_tags($_POST['db_st']));
				$host				=	addslashes(strip_tags($_POST['host']));
				$db_user			=	addslashes(strip_tags($_POST['db_user']));
				$db_pwd				=	addslashes(strip_tags($_POST['db_pwd']));
				$collate			=	addslashes(strip_tags($_POST['collate']));
				$engine				=	addslashes(strip_tags($_POST['engine']));
				$char_set			=	addslashes(strip_tags($_POST['char_set']));
				$open_loc			=	addslashes(strip_tags($_POST['open_loc']));
				$WEP_loc			=	addslashes(strip_tags($_POST['WEP_loc']));
				$WPA_loc			=	addslashes(strip_tags($_POST['WPA_loc']));
				$KML_SOURCE_URL		=	addslashes(strip_tags($_POST['KML_SOURCE_URL']));
				$kml_out			=	addslashes(strip_tags($_POST['kml_out']));
				$vs1_out			=	addslashes(strip_tags($_POST['vs1_out']));
				$daemon_out			=	addslashes(strip_tags($_POST['daemon_out']));
				$gpx_out			=	addslashes(strip_tags($_POST['gpx_out']));
				$ads				= 	addslashes($_POST['ads']);
				$header				= 	addslashes($_POST['header']);
				$tracker			= 	addslashes($_POST['tracker']);
				echo $_POST['header'];
				$DB_Config = "$"."lastedit	=	'".date('Y-M-d H:i:s')."';
#COOKIE GLOBALS
global $"."console_refresh, $"."console_scroll, $"."console_last5, $"."default_theme, $"."default_refresh, $"."default_dst, $"."default_timezone, $"."timeout, $"."config_fails, $"."login_seed;
#SQL GLOBALS
global $"."wifidb_install, $"."conn, $"."db, $"."db_st, $"."DB_stats_table, $"."daemon_perf_table, $"."users_t, $"."user_logins_table, $"."validate_table, $"."files, $"."files_tmp, $"."annunc, $"."annunc_comm, $"."collate, $"."engine, $"."char_set;
#MISC GLOBALS
global $"."header, $"."ads, $"."tracker, $"."hosturl, $"."dim, $"."admin_email, $"."WiFiDB_LNZ_User, $"."apache_grp, $"."div, $"."wifidb_tools, $"."daemon, $"."root, $"."console_lines, $"."console_log, $"."bypass_check, $"."wifidb_email_updates, $"."wifidb_from, $"."wifidb_from_pass;

$"."lastedit	=	'$date';

#----------General Settings------------#
$"."bypass_check	=	0;
$"."wifidb_tools	=	'$toolsdir';
$"."wifidb_install	=	'$wifidb_install';
$"."timezn			=	'$Local_tz';
$"."root			=	'$root';
$"."hosturl		=	'$hosturl';
$"."dim			=	DIRECTORY_SEPARATOR;
$"."admin_email	=	'$email';
$"."config_fails	=	3;
$"."login_seed		=	'$seed';
$"."wifidb_email_updates = '$wifidb_email_updates';
$"."wifidb_from	=	'$wifidb_from';
$"."wifidb_from_pass	=	'$wifidb_from_pass';
$"."wifidb_smtp		=	'';

#---------------- Daemon Info ----------------#
$"."daemon				=	$daemon;
$"."log_level			=	$log_level;
$"."log_interval		=	$log_interval;
$"."WiFiDB_LNZ_User 	=	'$WiFiDB_LNZ_User';
$"."apache_grp			=	'$apache_grp';

#-------------Themes Settings--------------#
$"."default_theme		= '$default_theme';
$"."default_refresh 	= $default_refresh;
$"."default_timezone	= $default_timezone;
$"."default_dst		= $default_dst;
$"."timeout			= $timeout; #(86400 [seconds in a day] * 365 [days in a year]) 

#-------------Console Viewer Settings--------------#
$"."console_refresh	= $console_refresh;
$"."console_scroll		= $console_scroll;
$"."console_last5		= $console_last5;
$"."console_lines		= $console_lines;
$"."console_log		= '$console_log';

#---------------- Debug Info ----------------#
$"."rebuild	=	$rebuild;
$"."bench		=	$bench;
$"."debug		=	$debug;

#---------------- Tables ----------------#
$"."settings_tb	=	'$settings_tb';
$"."users_t		=	'$users_t';
$"."links			=	'$links';
$"."wtable			=	'$wtable';
$"."user_logins_table	=	'$user_logins_table';
$"."validate_table		=	'$validate_table';
$"."share_cache	=	'$share_cache';
$"."files			=	'$files';
$"."files_tmp		=	'$files_tmp';
$"."annunc			=	'$annunc';
$"."annunc_comm	=	'$annunc_comm';
$"."gps_ext		=	'$gps_ext';
$"."sep			=	'$sep';

#---------------- DataBases ----------------#
$"."db		=	'$db';
$"."db_st	=	'$db_st';

#---------------- SQL Info ----------------#
$"."host		=	'$host';
$"."db_user	=	'$db_user';
$"."db_pwd		=	'$db_pwd';
$"."conn		=	 mysql_pconnect($"."host, $"."db_user, $"."db_pwd) or die('Unable to connect to SQL server: $"."host');
$"."collate	=	'$collate';
$"."engine		=	'$engine';
$"."char_set	=	'$char_set';

#---------------- Export Info ----------------#
$"."open_loc		=	'$open_loc';
$"."WEP_loc		=	'$WEP_loc';
$"."WPA_loc		=	'$WPA_loc';
$"."KML_SOURCE_URL	=	'$KML_SOURCE_URL';
$"."kml_out		=	'$kml_out';
$"."vs1_out		=	'$vs1_out';
$"."daemon_out		=	'$daemon_out';
$"."gpx_out		=	'$gpx_out';

#---------------- Header and Footer Additional Info -----------------#
	 // Put the code for your ads in here www.google.com/adsense
$"."ads		= '$ads';

$"."header	= '$header';

	// put the code for the url tracker that you use here (ie - www.google.com/analytics )
$"."tracker	= '$tracker';";

				echo "<table><tr><td>".str_replace("\r\n", "<br>", $DB_Config)."</td></tr></table>";
			break;
			
			case "db_config":
				$file_ext = 'config.inc.php';
				$filename = $half_path.'/lib/'.$file_ext;
				include($filename);
				?>
				<form name="WiFiDB_daemon_cfg_form" action="?func=system&mode=db_config_proc" method="post" enctype="multipart/form-data">
				<h2>Edit the WifiDB Config File.</h2>
				<table width="75%" border="1" cellspacing="0" cellpadding="0">
				<tr><th colspan="2" class="style4">Basic WiFiDB Settings
					<p align="right"><a class="links" href="<?php echo $GLOBALS['hosturl'].$GLOBALS['root'].'/cp/admin/help/index.php?topic=Daemon_config'; ?>" target="_new">Help?</p></th></tr>
				  <tr class="dark">
					<td >WiFiDB Tools Folder</td>
					<td>
					<input style="width: 96%" name="wifidb_tools" value="<?php echo $wifidb_tools; ?>"></td></tr>
				  <tr class="dark">
					<td >WiFiDB HTML Folder</td>
					<td>
					<input style="width: 96%" name="wifidb_install" value="<?php echo $wifidb_install; ?>"></td></tr>
				  <tr class="dark">
					<td >Root Folder</td>
					<td>
					<input style="width: 33%" name="root" value="<?php echo $root; ?>"></td></tr>
				  <tr class="dark">
					<td >Host URL</td>
					<td>
					<input style="width: 96%" name="hosturl" value="<?php echo $hosturl; ?>"></td></tr>
				  <tr class="dark">
					<td >Admin Email</td>
					<td>
					<input style="width: 84%" name="admin_email" value="<?php echo $admin_email; ?>"></td></tr>
				  <tr class="dark">
					<td >Max Login Fails before Lock</td>
					<td ><input style="width: 25%" name="config_fails" value="<?php echo $config_fails; ?>"></td></tr>
				  <tr>
					<th colspan="2" class="style4">Daemon Settings</th>
				</tr>
				  <tr class="dark">
					<td >Daemon (on/off)</td>
					<td ><input type="checkbox" name="daemon" <?php if($daemon){echo 'CHECKED';} ?> ></td></tr>
				  <tr class="dark">
					<td >HTTP Server user</td>
					<td>
					<input style="width: 40%" name="WiFiDB_LNZ_User" value="<?php echo $WiFiDB_LNZ_User; ?>"></td></tr>
				  <tr class="dark">
					<td >HTTP Server Group</td>
					<td >
					<input name="apache_grp" value="<?php echo $apache_grp; ?>" style="width: 175px"></td></tr>
				  <tr>
					<th colspan="2" class="style4">Themes Settings</th>
				</tr>
				  <tr class="dark">
					<td >Default Theme</td>
					<td >
						<select name="default_theme">
						<OPTION selected VALUE=""> Select a Theme.
						<?php
						$dh = opendir("../../themes/") or die("couldn't open directory");
						while (!(($file = readdir($dh)) == false))
						{
							if ((is_dir("../../themes/$file"))) 
							{
								if($file=="."){continue;}
								if($file==".."){continue;}
								if($file==".svn"){continue;}
								echo '<OPTION VALUE="'.$file.'"> '.$file;
							}
						}
						?>
						</select>
					</td>
				</TR>
				  <tr class="dark">
					<td >Default Refresh</td>
					<td ><input name="default_refresh" value="<?php echo $default_refresh; ?>"></td>
				</TR>
				  <tr class="dark">
					<td >Timeout</td>
					<td ><input name="timeout" value="<?php echo $timeout; ?>"></td>
				</TR>
				<tr>
					<th colspan="2" class="style4">Console Viewer Settings</th>
				</tr>
				  <tr class="dark">
					<td >Console Refresh</td>
					<td >
					<input name="console_refresh" value="<?php echo $console_refresh; ?>" style="width: 53px"></td>
				</TR>
				<tr class="dark">
					<td >Console Scroll</td>
					<td >
					<input name="console_scroll" type="checkbox"  <?php if($console_scroll){echo "CHECKED";} ?> style="width: 53px"></td>
				</TR>
				  <tr class="dark">
					<td >Console Last 5</td>
					<td >
					<input name="console_last5" type="checkbox"  <?php if($console_last5){echo "CHECKED";} ?> style="width: 53px"></td>
				</TR>
				  <tr class="dark">
					<td >Console Lines</td>
					<td >
					<input name="console_lines" value="<?php echo $console_lines; ?>"></td>
				</TR>
				  <tr class="dark">
					<td >Console Log</td>
					<td ><input name="console_log" <?php echo $console_log; ?> ></td>
				</TR>
				  <tr>
					<th colspan="2" class="style4">Debug and Other Settings</th>
				</TR>
				  <tr class="dark">
					<td >Bypass Install folder check</td>
					<td >
					<input type="checkbox" name="bypass_check" <?php if($bypass_check){echo 'CHECKED';} ?> ></td>
				</TR>
				  <tr class="dark">
					<td >Rebuild flag</td>
					<td >
					<input type="checkbox" name="rebuild" <?php if($rebuild){echo 'CHECKED';} ?> ></td>
				</TR>
				<TR class="dark">
					<TD >Debug Flag</TD>
					<td>
					<input type="checkbox" name="debug" <?php if($debug){echo 'CHECKED';} ?> ></td>
				</TR>
				<TR class="dark">
					<TD >Benchmark Flag</TD>
					<td>
					<input type="checkbox" name="bench" <?php if($bench){echo 'CHECKED';} ?> ></td>
				</TR>
				<tr>
					<th colspan="2" class="style4">SQL Server settings</Th>
				</tr>
				<tr class="dark">
					<TD>SQL Host address</TD>
					<td><input name="host" value="<?php echo $host; ?>" ></td>
				</tr>
				<tr class="dark">
					<TD>WiFiDB SQL User</TD>
					<td>
						<input style="width: 48%" name="db_user" value="<?php echo $db_user; ?>"></td>
				</tr>
				<tr class="dark">
					<TD>WiFiDB SQL Password</TD>
					<td>
						<input style="width: 49%" name="db_pwd" value="<?php echo $db_pwd; ?>"></td>
				</tr>
				<tr class="dark">
					<TD>SQL Collate</TD>
					<td>
						<input style="width: 46%" name="collate" value="<?php echo $collate; ?>"></td>
				</tr>
				<tr class="dark">
					<TD>SQL Engine</TD>
					<td>
						<input style="width: 47%" name="engine" value="<?php echo $engine; ?>"></td>
				</tr>
				<tr class="dark">
					<TD>Char Set</TD>
					<td>
						<input style="width: 44%" name="char_set" value="<?php echo $char_set; ?>"></td>
				</tr>
				<tr>
					<Th colspan="2" class="style4">Database Settings</Th>
				</tr>
				<tr class="dark">
					<TD >Settings DB Name</TD>
					<td>
						<input name="db" value="<?php echo $db; ?>" style="width: 100px"></td>
				</tr>
				<tr class="dark">
					<TD >Storage DB Name</TD>
					<td>
						<input name="db_st" value="<?php echo $db_st; ?>" style="width: 100px"></td>
				</tr>
				<tr class="dark">
					<TD >Settings Table</TD>
					<td>
						<input name="settings_tb" value="<?php echo $settings_tb; ?>" style="width: 206px"></td>
				</tr>
				<tr class="dark">
				<TD >Users Import Table</TD>
					<td>
						<input name="users_t" value="<?php echo $users_t; ?>" style="width: 206px"></td>
				</tr>
				<tr class="dark">
				<TD >Links Table</TD>
					<td>
						<input name="links" value="<?php echo $links; ?>" style="width: 216px"></td>
				</tr>
				<tr class="dark">
				<TD >Wifi Pointers Table</TD>
					<td>
						<input name="wtable" value="<?php echo $wtable; ?>" style="width: 212px"></td>
				</tr>
				<tr class="dark">
				<TD >Users Login Table</TD>
					<td>
						<input name="user_logins_table" value="<?php echo $user_logins_table; ?>" style="width: 205px"></td>
				</tr>
				<tr class="dark">
				<TD >Users Validation Table</TD>
					<td>
						<input name="validate_table" value="<?php echo $validate_table; ?>" style="width: 215px"></td>
				</tr>
				<tr class="dark">
				<TD >Geocache Shares Table</TD>
					<td>
						<input name="share_cache" value="<?php echo $share_cache; ?>" style="width: 212px"></td>
				</tr>
				<tr class="dark">
				<TD >Imported Files Table</TD>
					<td>
						<input name="files" value="<?php echo $files; ?>" style="width: 212px"></td>
				</tr>
				<tr class="dark">
				<TD >Waiting Files Table</TD>
					<td>
						<input name="files_tmp" value="<?php echo $files_tmp; ?>" style="width: 219px"></td>
				</tr>
				<tr class="dark">
				<TD >Announcement Table</TD>
					<td>
						<input name="annunc" value="<?php echo $annunc; ?>" style="width: 232px"></td>
				</tr>
				<tr class="dark">
				<TD >Announcement Comments Table</TD>
					<td>
						<input name="annunc_comm" value="<?php echo $annunc_comm; ?>" style="width: 231px"></td>
				</tr>
				<tr class="dark">
				<TD >GPS Table extension</TD>
					<td>
						<input name="gps_ext" value="<?php echo $gps_ext; ?>" style="width: 88px"></td>
				</tr>
				<tr class="dark">
				<TD >Table Separator</TD>
					<td>
						<input name="sep" value="<?php echo $sep; ?>" style="width: 51px"></td>
				</tr>
				<tr class="dark">
					<Th colspan="2" class="style4" >KML Settings</Th>
				</tr>
				<tr class="dark">
					<TD>Open Image</TD>
					<td>
						<input style="width: 100%" name="open_loc" value="<?php echo $open_loc; ?>"></td>
				</tr>
				<tr class="dark">
					<TD>WEP Image</TD><td><input style="width: 100%" name="WEP_loc" value="<?php echo $WEP_loc; ?>"></td>
				</tr>
				<tr class="dark">
					<TD>Secure Image</TD>
					<td>
						<input style="width: 100%" name="WPA_loc" value="<?php echo $WPA_loc; ?>"></td>
				</tr>
				<tr class="dark">
					<TD>KML Source URL</TD>
					<td>
						<input style="width: 100%" name="KML_SOURCE_URL" value="<?php echo $KML_SOURCE_URL; ?>"></td>
				</tr>
				<tr class="dark">
					<Th colspan='2' class="style4">Output Folders</Th>
				</tr>
				<tr class="dark">
					<TD>KMZ Out Folder</TD>
					<td>
						<input style="width: 100%" name="kml_out" value="<?php echo $kml_out; ?>"></td>
				</tr>
				<tr class="dark">
					<TD>VS1 Out Folder</TD>
					<td>
						<input style="width: 100%" name="vs1_out" value="<?php echo $vs1_out; ?>"></td>
				</tr>
				<tr class="dark">
					<TD>Daemon Out Folder</TD>
					<td>
						<input style="width: 100%" name="daemon_out" value="<?php echo $daemon_out; ?>"></td>
				</tr>
				<tr class="dark">
					<TD>GPX Out Folder</TD>
					<td>
						<input style="width: 100%" name="gpx_out" value="<?php echo $gpx_out; ?>"></td>
				</tr>
				<TR>
					<TD colspan="2" class="daemon_kml">
						<input type='hidden' name="ads" value='<?php echo $ads; ?>'>
						<input type='hidden' name="header" value='<?php echo addslashes($header); ?>'>
						<input type='hidden' name="tracker" value='<?php echo $tracker; ?>'>
						<input type='hidden' name="login_seed" value='<?php echo $login_seed; ?>'>
						<input type='hidden' name="db_user" value='<?php echo $db_user; ?>'>
						<input type='hidden' name="db_pwd" value='<?php echo $db_pwd; ?>'>
						<INPUT TYPE=SUBMIT NAME="submit" VALUE="Submit" STYLE="width: 0.71in; height: 0.36in">
					</TD>
				</TR>
				</TABLE>
				</form>
				<?php
			break;
			
			case "updates":
			
			break;
			
			default:
				
				
				
				
				
			break;
		}
	}
}
?>