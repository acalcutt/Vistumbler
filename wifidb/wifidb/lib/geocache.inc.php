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
			$User_cache = "waypoints_".$User;
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
			$terain = $pri_wpt['terain'];
			$diff = $pri_wpt['diff'];
			$lat = $pri_wpt['lat'];
			$long = $pri_wpt['long'];
			$link = $pri_wpt['link'];
			$c_date = $pri_wpt['c_date'];
			$u_date = date("Y-m-d G:i:s");
			$select = "SELECT * FROM `$db`.`$share_cache` WHERE `pvt_id` = '$id' AND `shared_by` = '$User'";
			$result = mysql_query($select, $conn);
			$array = mysql_fetch_array($result);
			if($array['id'] != $id)
			{
				$sql1 = "INSERT INTO `$db`.`$share_cache` (`id`, `author`, `shared_by`, `name`, `gcid`, `notes`, `cat`, `type`, `terain`, `diff`, `lat`, `long`, `link`, `c_date`, `u_date`, `pvt_id`) VALUES (NULL, '$author', '$shared_by', '$name', '$gcid', '$notes', '$cat', '$type', '$terain', '$diff', '$lat', '$long', '$link', '$c_date', '$u_date', '$id')";
			#	echo $sql1."<BR>";
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
						$return = 1;
					}else
					{
						$return = array("Mysql_error", mysql_error($conn));
					}
				}else
				{
					$return = array("Mysql_error", mysql_error($conn));
				}
			}else
			{
				$return = "dupe";
			}
		}else
		{
			$return = "login";
		}
		return $return;
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
			$User_cache = "waypoints_".$User;
			
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
			$User_cache = "waypoints_".$User;
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
	
	function update_wpt($id = 0, $author = '', $name = '', $gcid = '', $notes = '', $cat = '', $type = '', $terain = '', $diff = '' , $lat = '', $long = '', $link = '')
	{
		include_once($GLOBALS['half_path'].'/lib/security.inc.php');
		$sec = new security();
		
		$db = $GLOBALS['db'];
		$conn = $GLOBALS['conn'];
		$share_cache = $GLOBALS['share_cache'];
		$u_date = date("Y-m-d H:i:s");
	#	echo $cat." - inside func<BR>";
		$User = $sec->login_check();
	#	echo $User." <-----";
		if($User)
		{
			$User_cache = "waypoints_".$User;
			$sql0 = "UPDATE `$db`.`$User_cache` SET `name` = '$name', `author` = '$author', `gcid` = '$gcid', `notes` = '$notes', `cat` = '$cat', `type` = '$type', `terain` = '$terain', `diff` = '$diff', `lat` = '$lat', `long` = '$long', `link` = '$link', `u_date` = '$u_date' WHERE `id` = '$id' LIMIT 1";
		#	echo $sql0."<BR>";
			if(mysql_query($sql0, $conn))
			{
				$select = "SELECT `share`, `share_id` FROM `$db`.`$User_cache` WHERE `id` = '$id'";
			#	echo $select."<BR>";
				$return = mysql_query($select, $conn);
				$shr_wpt = mysql_fetch_array($return);
				$share_id = $shr_wpt['share_id'];
				$share = $shr_wpt['share'];
				if($share == 1)
				{
					$sql1 = "UPDATE `$db`.`$share_cache` SET `author` = '$author', `name` = '$name ', `gcid` = '$gcid ', `notes` = '$notes', `cat` = '$cat', `type` = '$type', `terain` = '$terain', `diff` = '$diff',  `lat` = '$lat', `long` = '$long', `link` = '$link', `u_date` = '$u_date' WHERE `id` = '$share_id' LIMIT 1";
				#	echo $sql1."<BR>";
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
	
	function wptfetch($id=0, $public = 1)
	{
		$apID = $id;
		$start = microtime(true);
		include_once($GLOBALS['half_path'].'/lib/security.inc.php');
		include_once($GLOBALS['half_path'].'/lib/database.inc.php');
		$sec = new security();
		$User = $sec->login_check();
		if($User)
		{
			$conn = $GLOBALS['conn'];
			$db = $GLOBALS['db'];
			$user_cache = 'waypoints_'.$User;
			if(!$public)
			{
				$sql0 = "SELECT * FROM `$db`.`$user_cache`WHERE `id` = '$id'";
			}else
			{
				$sql0 = "SELECT * FROM `$db`.`".$GLOBALS['share_cache']."` WHERE `id` = '$id'";
			}
			$result = mysql_query($sql0, $conn);
			$geo_array = mysql_fetch_array($result);
			$author = $geo_array['author'];
			$name = $geo_array['name'];
			$gcid = $geo_array['gcid'];
			$cat =$geo_array['cat'];
			$type = $geo_array['type'];
			$diff = $geo_array['diff'];
			$terain = $geo_array['terain'];
			$lat = $geo_array['lat'];
			$long = $geo_array['long'];
			$notes = $geo_array['notes'];
			$created = $geo_array['c_date'];
			$updated = $geo_array['u_date'];
			?>
			<meta name="viewport" content="initial-scale=1.0, user-scalable=no" />
			<script type="text/javascript" src="http://maps.google.com/maps/api/js?sensor=false"></script>
			<script type="text/javascript">
			function initialize()
			{
				var latlng = new google.maps.LatLng(<?php echo $lat.', '.$long; ?>);
				var myOptions = {
					zoom: 8,
					center: latlng,
					mapTypeId: google.maps.MapTypeId.HYBRID
				};
				var map = new google.maps.Map(document.getElementById("map_canvas"), myOptions);
				
				var image = '../img/cache.png';
				var latlng = new google.maps.LatLng(<?php echo $lat.', '.$long; ?>);
				var cachemarker = new google.maps.Marker({
					position: latlng,
					map: map,
					icon: image
				});
			}
			</script>
			<body onload="initialize()">
			<?php
			pageheader("User Control Panel --> Mysticache");
			if(!$public)
			{
				user_panel_bar("myst", "listall");
				?><tr>
						<td colspan="6" class="dark">
					<table  BORDER=1 CELLPADDING=2 CELLSPACING=0 style="width: 100%">
						<tr>
							<td align="center">
			<?php
			}
			?>
								<table width="80%" BORDER=1 CELLPADDING=0 CELLSPACING=0>
									<tr class="style4">
										<th colspan="2"><?php echo $name; ?>&nbsp;</th>
									</tr>
									<tr class="sub_head">
										<th>Author</th>
										<td><?php echo $author; ?>&nbsp;</td>
									</tr>
									<tr>
										<th class="style4">GCID</th>
										<td class="light"><?php echo $gcid; ?>&nbsp;</td>
									</tr>
									<tr>
										<th class="style4">Catagory</th>
										<td class="dark"><?php echo $cat; ?>&nbsp;</td>
									</tr>
									<tr>
										<th class="style4">Type</th>
										<td class="light"><?php echo $type; ?>&nbsp;</td>
									</tr>
									<tr>
										<th class="style4">Difficulty</th>
										<td class="dark"><?php echo $diff; ?>&nbsp;</td>
									</tr>
									<tr>
										<th class="style4">Terain</th>
										<td class="light"><?php echo $terain; ?>&nbsp;</td>
									</tr>
									<tr>
										<th class="style4">Latitude</th>
										<td class="dark"><?php echo $lat; ?>&nbsp;</td>
									</tr>
									<tr>
										<th class="style4">Longitude</th>
										<td class="light"><?php echo $long; ?>&nbsp;</td>
									</tr>
									<tr class="sub_head">
										<th>Notes</th><th>Map</th>
									</tr>
									<tr>
										<td class="light">
											<?php echo $notes; ?>&nbsp;
										</td>
										<td class="dark">
												<div id="map_canvas" style="width:100%;height:250px"></div>
										</td>
									</tr>
									<tr  class="sub_head">
										<th>Created</th><th>Last Updated</th>
									</tr>
									<tr  class="light">
										<td>
											<?php echo $created; ?>&nbsp;
										</td>
										<td>
											<?php echo $updated; ?>&nbsp;
										</td>
									</tr>
								</table>
					<?php if(!$public)
					{?>			</td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
		<?php
		}
		}else
		{
			return "login";
		}
	}
}
?>