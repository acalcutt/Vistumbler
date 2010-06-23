<?php

class geocache
{
	#############################
	#	Share Waypoint			#
	#############################
	
	function share_wpt($id)
	{	
		global $cachename;
		include_once($GLOBALS['half_path'].'/lib/security.inc.php');
		$sec = new security();
		$id+0;
		$db = $GLOBALS['db'];
		$conn = $GLOBALS['conn'];
		$share_cache = $GLOBALS['share_cache'];
		$User = $sec->login_check();
	#	echo $User." <-----";
		if($User)
		{
			$User_cache = $User."_waypoints";
			$select = "SELECT * FROM `$db`.`$User_cache` WHERE `id` = '$id'";
			$return = mysql_query($select, $conn);
			$pri_wpt = mysql_fetch_array($return);
			
			$author = $pri_wpt['author'];
			$shared_by = $User;
			$name = addslashes($pri_wpt['name']);
			$cachename = $name;
			$gcid = $pri_wpt['gcid'];
			$notes = addslashes($pri_wpt['notes']);
			$cat = $pri_wpt['cat'];
			$type = addslashes($pri_wpt['type']);
			$lat = $pri_wpt['lat'];
			$long = $pri_wpt['long'];
			$link = $pri_wpt['link'];
			$c_date = $pri_wpt['c_date'];
			$u_date = date("Y-m-d G:i:s");
			
			$sql1 = "INSERT INTO `$db`.`$share_cache` (`id`, `author`, `shared_by`, `name`, `gcid`, `notes`, `cat`, `type`, `lat`, `long`, `link`, `c_date`, `u_date`, `pvt_id`) VALUES (NULL, '$author', '$shared_by', '$name', '$gcid', '$notes', '$cat', '$type', '$lat', '$long', '$link', '$c_date', '$u_date', '$id')";
			if(mysql_query($sql1, $conn))
			{
				$select = "SELECT `id` FROM `$db`.`$share_cache` WHERE `gcid` LIKE '$gcid' AND `name` LIKE '$name'";
		#		echo $select."<BR>";
				$return = mysql_query($select, $conn);
				$shr_wpt = mysql_fetch_array($return);
				$share_id = $shr_wpt['id'];
		#		echo $share_id."<BR>";
				$update_user_share_flag = "UPDATE `$db`.`$User_cache` SET `share` = '1', `share_id` = '$share_id', `u_date` = '$u_date' WHERE `id` = '$id'";
		#		echo $update_user_share_flag."<BR>";
				if(mysql_query($update_user_share_flag, $conn))
				{
					return 1;
				}else
				{
					return array("Mysql_error", mysql_error($conn));
				}
			}else
			{
				return array("Mysql_error", mysql_error($conn));
			}
		}else
		{
			return "login";
		}
	}

	function remove_share_wpt($id)
	{
		global $cachename;
		include_once($GLOBALS['half_path'].'/lib/security.inc.php');
		$sec = new security();
		
		$id+0;
		$db = $GLOBALS['db'];
		$conn = $GLOBALS['conn'];
		$share_cache = $GLOBALS['share_cache'];
		
		$u_date = date("Y-m-d G:i:s");
		$User = $sec->login_check();
	#	echo $User." <-----";
		if($User)
		{
			$User_cache = $User."_waypoints";
			
			$select = "SELECT * FROM `$db`.`$User_cache` WHERE `id` = '$id'";
			$return = mysql_query($select, $conn);
			$pri_wpt = mysql_fetch_array($return);
			
			$cachename = $pri_wpt['name'];
			$remove = "DELETE FROM `$db`.`$share_cache` WHERE `$share_cache`.`pvt_id` = '$id' LIMIT 1";
			if(mysql_query($remove, $conn))
			{
				$update_user_share_flag = "UPDATE `$db`.`$User_cache` SET `share` = '0',`share_id` = '0', `u_date` = '$u_date' WHERE `$User_cache`.`id` = '$id' LIMIT 1";
				if(mysql_query($update_user_share_flag, $conn))
				{
					return 1;
				}else
				{
					return mysql_error($conn);
				}
			}else
			{
				return mysql_error($conn);
			}
		}else
		{
			return "login";
		}
	}

	function remove_wpt($id)
	{
		include_once($GLOBALS['half_path'].'/lib/security.inc.php');
		$sec = new security();
		
		$id+0;
		$db = $GLOBALS['db'];
		$conn = $GLOBALS['conn'];
		
		$User = $sec->login_check();
	#	echo $User." <-----";
		if($User)
		{
			$User_cache = $User."_waypoints";
			$remove = "DELETE FROM `$db`.`$User_cache` WHERE `$User_cache`.`id` = '$id' LIMIT 1";
			if(mysql_query($remove, $conn))
			{
				return 1;
			}else
			{
				return array(0, mysql_error($conn));
			}
		}else
		{
			return "login";
		}
	}
	
	function update_wpt($id = 0, $name = '', $gcid = '', $notes = '', $cat = '', $type = '', $terain = '', $diff = '' , $lat = '', $long = '', $link = '')
	{
		include_once($GLOBALS['half_path'].'/lib/security.inc.php');
		$sec = new security();
		
		$db = $GLOBALS['db'];
		$conn = $GLOBALS['conn'];
		$share_cache = $GLOBALS['share_cache'];
		$u_date = date("Y-m-d G:i:s");
		
		$User = $sec->login_check();
	#	echo $User." <-----";
		if($User)
		{
			$User_cache = "waypoints_".$User;
			$sql0 = "UPDATE `$db`.`$User_cache` SET `name` = '$name', `gcid` = '$gcid', `notes` = '$notes', `cat` = '$cat', `type` = '$type', `terain` = '$terain', `diff` = '$diff', `lat` = '$lat', `long` = '$long', `link` = '$link', `u_date` = '$u_date' WHERE `$User_cache`.`id` = '$id' LIMIT 1";
			if(mysql_query($sql0, $conn))
			{
				$select = "SELECT `share`, `share_id` FROM `$db`.`$User_cache` WHERE `id` = '$id'";
				
				$return = mysql_query($select, $conn);
				$shr_wpt = mysql_fetch_array($return);
				$share_id = $shr_wpt['share_id'];
				$share = $shr_wpt['share'];
				if($share == 1)
				{
					$sql1 = "UPDATE `$db`.`$share_cache` SET `author` = '$username', `name` = '$name ', `gcid` = '$gcid ', `notes` = '$notes', `cat` = '$cat', `type` = '$type', `lat` = '$lat', `long` = '$long', `link` = '$link', `u_date` = '$u_date' WHERE `$share_cache`.`id` = '$share_id' LIMIT 1";
					if(mysql_query($sql1, $conn))
					{
						return 1;
					}else
					{
						return mysql_error($conn);
					}
				}
				return 1;
			}else
			{
				return mysql_error($conn);
			}
		}else
		{
			return "login";
		}
	}
	

	
	
	
	#####################################
	#		Waypoint Fetch				#
	#####################################
	
	function wptfetch($id=0)
	{
		$apID = $id;
		$start = microtime(true);
		include('../lib/config.inc.php');
		$sqls = "SELECT * FROM `$db`.`$wtable` WHERE id='$id'";
		$result = mysql_query($sqls, $conn) or die(mysql_error($conn));
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
		$ssid_ptb_ = $newArray["ssid"];
		$ssids_ptb = str_split($newArray['ssid'],25);
		$ssid_ptb = smart_quotes($ssids_ptb[0]);
		$table		=	$ssid_ptb.'-'.$newArray["mac"].'-'.$newArray["sectype"].'-'.$newArray["radio"].'-'.$newArray['chan'];
		$table_gps	=	$table.$gps_ext;
		?>
				<SCRIPT LANGUAGE="JavaScript">
				// Row Hide function.
				// by tcadieux
				function expandcontract(tbodyid,ClickIcon)
				{
					if (document.getElementById(ClickIcon).innerHTML == "+")
					{
						document.getElementById(tbodyid).style.display = "";
						document.getElementById(ClickIcon).innerHTML = "-";
					}else{
						document.getElementById(tbodyid).style.display = "none";
						document.getElementById(ClickIcon).innerHTML = "+";
					}
				}
				</SCRIPT>
		<h1><?php echo $newArray['ssid'];?></h1>
		<TABLE align=center WIDTH=569 BORDER=1 CELLPADDING=4 CELLSPACING=0>
		<TABLE align=center WIDTH=569 BORDER=1 CELLPADDING=4 CELLSPACING=0>
		<COL WIDTH=112><COL WIDTH=439>
		<TR VALIGN=TOP><TD class="style4" WIDTH=112><P>MAC Address</P></TD><TD WIDTH=439><P><?php echo $mac_full;?></P></TD></TR>
		<TR VALIGN=TOP><TD class="style4" WIDTH=112><P>Manufacture</P></TD><TD WIDTH=439><P><?php echo $manuf;?></P></TD></TR>
		<TR VALIGN=TOP><TD class="style4" WIDTH=112 HEIGHT=26><P>Authentication</P></TD><TD WIDTH=439><P><?php echo $newArray['auth'];?></P></TD></TR>
		<TR VALIGN=TOP><TD class="style4" WIDTH=112><P>Encryption Type</P></TD><TD WIDTH=439><P><?php echo $newArray['encry'];?></P></TD></TR>
		<TR VALIGN=TOP><TD class="style4" WIDTH=112><P>Radio Type</P></TD><TD WIDTH=439><P><?php echo $radio;?></P></TD></TR>
		<TR VALIGN=TOP><TD class="style4" WIDTH=112><P>Channel #</P></TD><TD WIDTH=439><P><?php echo $newArray['chan'];?></P></TD></TR>
		<?php
		?>
		<tr><td colspan="2" align="center" ><a class="links" href="../opt/export.php?func=exp_single_ap&row=<?php echo $ID;?>&token=<?php echo $_SESSION['token'];?>">Export this AP to KML</a></td></tr>
		</table>
		<br>
		<TABLE align=center  WIDTH=85% BORDER=1 CELLPADDING=4 CELLSPACING=0 id="gps">
		<tr class="style4"><th colspan="10">Signal History</th></tr>
		<tr class="style4"><th>Row</th><th>Btx</th><th>Otx</th><th>First Active</th><th>Last Update</th><th>Network Type</th><th>Label</th><th>User</th><th>Signal</th><th>Plot</th></tr>
		<?php
		$start1 = microtime(true);
		$result = mysql_query("SELECT * FROM `$db_st`.`$table` ORDER BY `id`", $conn) or die(mysql_error($conn));
		while ($field = mysql_fetch_array($result))
		{
			$row = $field["id"];
			$row_id = $row.','.$ID;
			$sig_exp = explode("-", $field["sig"]);
			$sig_size = count($sig_exp)-1;

			$first_ID = explode(",",$sig_exp[0]);
			$first = $first_ID[0];
			if($first == 0)
			{
				$first_ID = explode(",",$sig_exp[1]);
				$first = $first_ID[0];
			}
			
			$last_ID = explode(",",$sig_exp[$sig_size]);
			$last = $last_ID[0];
			if($last == 0)
			{
				$last_ID = explode(",",$sig_exp[$sig_size-1]);
				$last = $last_ID[0];
			}
			
			$sql1 = "SELECT * FROM `$db_st`.`$table_gps` WHERE `id`='$first'";
			$re = mysql_query($sql1, $conn) or die(mysql_error($conn));
			$gps_table_first = mysql_fetch_array($re);

			$date_first = $gps_table_first["date"];
			$time_first = $gps_table_first["time"];
			$fa = $date_first." ".$time_first;
			
			$sql2 = "SELECT * FROM `$db_st`.`$table_gps` WHERE `id`='$last'";
			$res = mysql_query($sql2, $conn) or die(mysql_error($conn));
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
				<a class="links" href="../opt/userstats.php?func=allap&user=<?php echo $field["user"]; ?>&token=<?php echo $_SESSION['token'];?>"><?php echo $field["user"]; ?></a></td><td>
				<a class="links" href="../graph/?row=<?php echo $row; ?>&id=<?php echo $ID; ?>&token=<?php echo $_SESSION['token'];?>">Graph Signal</a></td><td><a class="links" href="export.php?func=exp_all_signal&row=<?php echo $row_id;?>&token=<?php echo $_SESSION['token'];?>">KML</a>
			<!--	OR <a class="links" href="export.php?func=exp_all_signal_gpx&row=<?php #echo $row_id;?>&token=<?php #echo $_SESSION['token'];?>">GPX</a> -->
				</td></tr>
				<tr><td colspan="10" align="center">
				
				<table  align=center WIDTH=569 BORDER=1 CELLPADDING=4 CELLSPACING=0>
				<tr><td class="style4" onclick="expandcontract('Row<?php echo $tablerowid;?>','ClickIcon<?php echo $tablerowid;?>')" id="ClickIcon<?php echo $tablerowid;?>" style="cursor: pointer; cursor: hand;">+</td>
				<th colspan="6" class="style4">GPS History</th></tr>
				<tbody id="Row<?php echo $tablerowid;?>" style="display:none">
				<tr class="style4"><th>Row</th><th>Lat</th><th>Long</th><th>Sats</th><th>Date</th><th>Time</th></tr>
				<?php
				$tablerowid++;
				$signals = explode('-',$field['sig']);
				foreach($signals as $signal)
				{
					$sig_exp = explode(',',$signal);
					$id = $sig_exp[0]+0;
					if($id == 0){continue;}
					$start2 = microtime(true);
					$result1 = mysql_query("SELECT * FROM `$db_st`.`$table_gps` WHERE `id` = '$id'", $conn) or die(mysql_error($conn));
				#	$rows = mysql_num_rows($result1);
					while ($field = mysql_fetch_array($result1)) 
					{
				#		if($rows > 1){$rows--; continue;}
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
		<br>
		<TABLE align=center WIDTH=569 BORDER=1 CELLPADDING=4 CELLSPACING=0>
		<?php
		#END GPSFETCH FUNC
		?>
		<tr class="style4"><th colspan="6">Associated Lists</th></tr>
		<tr class="style4"><th>New/Update</th><th>ID</th><th>User</th><th>Title</th><th>Total APs</th><th>Date</th></tr>
		<?php
		$start3 = microtime(true);
		$result = mysql_query("SELECT * FROM `$db`.`$users_t`", $conn);
		while ($field = mysql_fetch_array($result)) 
		{
			if($field['points'] != '')
			{
				$APS = explode("-" , $field['points']);
				foreach ($APS as $AP)
				{
			#		echo $AP."<BR>";
					$access = explode(",", $AP);
					$New_or_Update = $access[0];
					
					$access1 = explode(":",$access[1]);
					$user_list_id = $access1[0];
					
					if ( $apID  ==  $user_list_id )
					{
						$list[]=$field['id'].",".$New_or_Update;
					}
				}
			}
		}
		if(isset($list))
		{
			foreach($list as $aplist)
			{
				$exp = explode(",",$aplist);
				$apid = $exp[0];
				$new_update = $exp[1];
				$result = mysql_query("SELECT * FROM `$db`.`$users_t` WHERE `id`='$apid'", $conn);
				while ($field = mysql_fetch_array($result)) 
				{
					if($field["title"]==''){$field["title"]="Untitled";}
					$points = explode('-' , $field['points']);
					$total = count($points);
					?>
					<td ><?php if($new_update == 1)
					{echo "Update";}
					else{echo "New";} 
					?></td><td align="center"><a class="links" href="userstats.php?func=useraplist&row=<?php echo $field["id"];?>&token=<?php echo $_SESSION['token'];?>"><?php echo $field["id"];?></a></td><td><a class="links" href="userstats.php?func=alluserlists&user=<?php echo $field["username"];?>&token=<?php echo $_SESSION['token'];?>"><?php echo $field["username"];?></a></td><td><a class="links" href="userstats.php?func=useraplist&row=<?php echo $field["id"];?>&token=<?php echo $_SESSION['token'];?>"><?php echo $field["title"];?></a></td><td align="center"><?php echo $total;?></td><td><?php echo $field['date'];?></td></tr>
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
}
?>