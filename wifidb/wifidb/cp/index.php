<?php
include('../lib/config.inc.php');
include('../lib/security.inc.php');
include('../lib/database.inc.php');

include_once($GLOBALS['half_path'].'/lib/security.inc.php');

$theme = $GLOBALS['theme'];
$func = '';
$func = filter_input(INPUT_GET, 'func', FILTER_SANITIZE_SPECIAL_CHARS);

$conn = $GLOBALS['conn'];
$db = $GLOBALS['db'];
$user_logins_table = $GLOBALS['user_logins_table'];

$user_cookie = explode(":", $_COOKIE['WiFiDB_login_yes']);
$username = $user_cookie[1];

$sec = new security();

$login_check = $sec->login_check();

if(is_array($login_check) or $login_check == "No Cookie"){$login_check = 0;}else{$login_check = 1;}

if($login_check)
{
	if($username != "admin")
	{
		switch($func)
		{
			##-------------##
			case 'profile':
				pageheader("User Control Panel --> Profile");
				$sql0 = "SELECT * FROM `$db`.`$user_logins_table` WHERE `username` = '$username' LIMIT 1";
				$result = mysql_query($sql0, $conn);
				$newArray = mysql_fetch_array($result);
				user_panel_bar("prof", 0);
				?><tr>
						<td colspan="6" class="dark">
						<form method="post" action="?func=update_user_profile">
						<table  BORDER=1 CELLPADDING=2 CELLSPACING=0 style="width: 100%">
							<tr>
								<th width="30%" class="style3">Email</th>
								<td class="light"><input type="text" name="email" size="75%" value="<?php echo $newArray['email'];?>"> Hide? <input name="h_email" type="checkbox" <?php if($newArray['h_email']){echo 'checked';}?>></td>
							</tr>
							<tr>
								<th width="30%" class="style3">Website</th>
								<td class="light"><input type="text" name="website" size="75%" value="<?php echo $newArray['website'];?>"></td>
							</tr>
							<tr>
								<th width="30%" class="style3">Vistumbler Version</th>
								<td class="light"><input type="text" name="Vis_ver" size="75%" value="<?php echo $newArray['Vis_ver'];?>"></td>
							</tr>
							<tr class="light">
								<td colspan="2">
									<p align="center">
										<input type="hidden" name="username" value="<?php echo $newArray['username'];?>">
										<input type="hidden" name="user_id" value="<?php echo $newArray['id'];?>">
										<input type="submit" value="Update Me!">
									</p>
								</td>
							</tr>
						</table>
						</form>
						</td>
					</tr>
				</table>
				<?php
				footer($_SERVER['SCRIPT_FILENAME']);
			break;
			
			case "update_user_profile":
				pageheader("User Control Panel --> Profile");
				user_panel_bar("prof", 0);
				?><tr>
						<td colspan="6" class="dark" align='center'>
				<?php
				$username = addslashes(strtolower($_POST['username']));
				$user_id = addslashes(strtolower($_POST['user_id']));
				
				$email = htmlentities(addslashes($_POST['email']),ENT_QUOTES);
				$h_email = addslashes($_POST['h_email']);
				if($h_email == "on"){$h_email = 1;}else{$h_email = 0;}
				
				$website = htmlentities(addslashes($_POST['website']),ENT_QUOTES);
				$Vis_ver = htmlentities(addslashes($_POST['Vis_ver']),ENT_QUOTES);
				
				$sql0 = "SELECT `id` FROM `$db`.`$user_logins_table` WHERE `username` LIKE '".$username."%'";
				$result = mysql_query($sql0, $conn);
				$array = mysql_fetch_array($result);
				if($array['id']+0 === $user_id+0)
				{
					$sql1 = "UPDATE `$db`.`$user_logins_table` SET `email` = '$email', `h_email` = '$h_email', `website` = '$website', `Vis_ver` = '$Vis_ver' WHERE `id` = '$user_id' LIMIT 1";
					$result = mysql_query($sql1, $conn);
					if(@$result)
					{					
						echo "Updated user ($user_id) Profile\r\n<br>";
					}else
					{
						echo "There was a serious error: ".mysql_error($conn)."<br>";
						die(footer($_SERVER['SCRIPT_FILENAME']));
					}
					redirect_page('?func=profile', 2000, 'Update User Successful!');
				}else
				{
					Echo "User ID's did not match, there was an error, contact the support forums for more help";
				}
				?>
						</td>
					</tr>
				</table>
				<?php
				footer($_SERVER['SCRIPT_FILENAME']);
			break;
			
			
			##-------------##
			case 'update_user_pref':
				pageheader("User Control Panel --> Update Preferences");
				user_panel_bar("pref", 0);
				$username = addslashes(strtolower($_POST['username']));
				$user_id = addslashes(strtolower($_POST['user_id']));
				
				$mail_updates = ((@$_POST['mail_updates']) == 'on' ? 1 : 0);
				$imports = ((@$_POST['imports']) == 'on' ? 1 : 0);
				$kmz = ((@$_POST['kmz']) == 'on' ? 1 : 0);
				$new_users = ((@$_POST['new_users']) == 'on' ? 1 : 0);
				$statistics = ((@$_POST['statistics']) == 'on' ? 1 : 0);
				$announcements = ((@$_POST['announcements']) == 'on' ? 1 : 0);
				$announce_comment = ((@$_POST['announce_comment']) == 'on' ? 1 : 0);
				$geonamed = ((@$_POST['geonamed']) == 'on' ? 1 : 0);
				$pub_geocache = ((@$_POST['pub_geocache']) == 'on' ? 1 : 0);
				$schedule = ((@$_POST['schedule']) == 'on' ? 1 : 0);
				
				$sql0 = "SELECT `id` FROM `$db`.`$user_logins_table` WHERE `username` LIKE '".$username."%'";
				$result = mysql_query($sql0, $conn);
				$array = mysql_fetch_array($result);
				if($array['id']+0 === $user_id+0)
				{
					$sql1 = "UPDATE `$db`.`$user_logins_table` SET 
																`mail_updates` = '$mail_updates',
																`schedule`	=	'$schedule',
																`imports` = '$imports', 
																`kmz` = '$kmz', 
																`new_users` = '$new_users', 
																`statistics` = '$statistics', 
																`announcements` = '$announcements', 
																`announce_comment` = '$announce_comment', 
																`geonamed` = '$geonamed', 
																`pub_geocache` = '$pub_geocache'
																WHERE `id` = '$user_id' LIMIT 1";
					echo $sql1."<br>";
					$result = mysql_query($sql1, $conn);
					if(@$result)
					{					
						echo "Updated $username ($user_id) Preferences\r\n<br>";
					}else
					{
						echo "There was a serious error: ".mysql_error($conn)."<br>";
						die();
					}
					redirect_page('?func=pref', 2000, 'Update User Preferences Successful!');
				}else
				{
					Echo "User ID's did not match, there was an error, contact the <a href='http://forum.techidiots.net/forum/viewforum.php?f=47'>support forums</a> for more help.";
				}
				footer($_SERVER['SCRIPT_FILENAME']);
			break;
			
			
			
			
			##-------------##
			case 'pref':
				?>
				<script type="text/javascript">
	function endisable( ) {
	document.forms['WiFiDB_Install'].elements['toolsdir'].disabled =! document.forms['WiFiDB_Install'].elements['daemon'].checked;
	document.forms['WiFiDB_Install'].elements['httpduser'].disabled =! document.forms['WiFiDB_Install'].elements['daemon'].checked;
	document.forms['WiFiDB_Install'].elements['httpdgrp'].disabled =! document.forms['WiFiDB_Install'].elements['daemon'].checked;
	}
	</script>
				<?php
				pageheader("User Control Panel --> Preferences");
				$sql0 = "SELECT * FROM `$db`.`$user_logins_table` WHERE `username` = '$username' LIMIT 1";
				$result = mysql_query($sql0, $conn);
				$newArray = mysql_fetch_array($result);
				user_panel_bar("pref", 0);
				?><tr>
						<td colspan="6" class="dark">
						<form method="post" action="?func=update_user_pref">
						<table BORDER=1 CELLPADDING=2 CELLSPACING=0 style="width: 100%">
							<tr>
								<th width="30%" class="style3">Email me about updates</th>
								<td align="center" class="dark"><input name="mail_updates" type="checkbox" <?php if($newArray['mail_updates']){echo 'checked';}?>></td>
							</tr>
							<tr>
								<td colspan='2'>
									<table BORDER=1 CELLPADDING=2 CELLSPACING=0 style="width: 100%">
										<tr>
											<th width="30%" class="style3">Announcements</th>
											<td align="center" class="light"><input name="announcements" type="checkbox" <?php if($newArray['announcements']){echo 'checked';}?>></td></td>
										</tr>
										<tr>
											<th width="30%" class="style3">Announcement Comments</th>
											<td align="center" class="dark"><input name="announce_comment" type="checkbox" <?php if($newArray['announce_comment']){echo 'checked';}?>></td></td>
										</tr>
										<tr>
											<th width="30%" class="style3">New Public Geocaches</th>
											<td align="center" class="light"><input name="pub_geocache" type="checkbox" <?php if($newArray['pub_geocache']){echo 'checked';}?>></td></td>
										</tr>
										<tr>	
											<th width="30%" class="style3">New Users</th>
											<td align="center" class="dark"><input name="new_users" type="checkbox" <?php if($newArray['new_users']){echo 'checked';}?>></td></td>
										</tr>
										<tr>
											<th width="30%" class="style3">Scheduled Import</th>
											<td align="center" class="light"><input name="schedule" type="checkbox" <?php if($newArray['schedule']){echo 'checked';}?>></td></td>
										</tr>
										<tr>
											<th width="30%" class="style3">Import Finished</th>
											<td align="center" class="dark"><input name="imports" type="checkbox" <?php if($newArray['imports']){echo 'checked';}?>></td></td>
										</tr>
										<tr>
											<th width="30%" class="style3">New Full DB KML</th>
											<td align="center" class="light"><input name="kmz" type="checkbox" <?php if($newArray['kmz']){echo 'checked';}?>></td></td>
										</tr>
										<tr>
											<th width="30%" class="style3">GeoNames Daemon</th>
											<td align="center" class="dark"><input name="geonamed" type="checkbox" <?php if($newArray['geonamed']){echo 'checked';}?>></td></td>
										</tr>
										<tr>
											<th width="30%" class="style3">Database Statistics Daemon</th>
											<td align="center" class="light"><input name="statisticsd" type="checkbox" <?php if($newArray['statistics']){echo 'checked';}?>></td></td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td colspan="2">
									<p align="center">
										<input type="hidden" name="username" value="<?php echo $newArray['username'];?>">
										<input type="hidden" name="user_id" value="<?php echo $newArray['id'];?>">
										<input type="submit" value="Update Me!">
									</p>
								</td>
							</tr>
						</table>
						</form>
						</td>
					</tr>
				</table>
				<?php
				footer($_SERVER['SCRIPT_FILENAME']);
			break;
			
			
			##-------------##
			case 'boeyes':
				
				$boeye_func = '';
				$boeye_func = filter_input(INPUT_GET, 'boeye_func', FILTER_SANITIZE_SPECIAL_CHARS);
				
				include('../lib/geocache.inc.php');
				$myscache = new geocache();
				
				if($boeye_func != "fetch_wpt")
				{
					pageheader("User Control Panel --> Mysticache");
				}
				switch($boeye_func)
				{
					case "fetch_wpt":
						$id = $_GET['id']+0;
						$myscache->wptfetch($id, 0);
					break;
					
					case "list_all":
						$ord	=	addslashes(@$_GET['ord']);
						$sort	=	addslashes(@$_GET['sort']);
						$from	=	addslashes(@$_GET['from']);
						$from	=	$from+0;
						$from_	=	$from+0;
						$inc	=	addslashes(@$_GET['to']);
						$inc	=	$inc+0;
					#	echo $from."<br>";
						if ($from=="" or !is_int($from)){$from=0;}
						if ($from_=="" or !is_int($from_)){$from_=0;}
						if ($inc=="" or !is_int($inc)){$inc=100;}
						if (@$_COOKIE['WiFiDB_page_limit']){$inc = $_COOKIE['WiFiDB_page_limit'];}else{$inc=100;}
						if ($ord=="" or !is_string($ord)){$ord="ASC";}
						if ($sort=="" or !is_string($sort)){$sort="id";}
						user_panel_bar("myst", "listall");
						?><tr>
								<td colspan="6" class="dark">
								<table  BORDER=1 CELLPADDING=2 CELLSPACING=0 style="width: 100%">
									<tr>
										<th class="style3">ID<a href="?func=boeyes&boeye_func=list_all&sort=id&ord=ASC&from=<?php echo $from;?>&to=<?php echo $inc;?>&token=<?php echo $_SESSION["token"];?>"><img height="15" width="15" border="0"border="0" src="<?php echo $GLOBALS['hosturl']."/".$GLOBALS['root']."/";?>themes/<?php echo $theme;?>/img/down.png"></a><a href="?func=boeyes&boeye_func=list_all&sort=id&ord=DESC&from=<?php echo $from;?>&to=<?php echo $inc;?>&token=<?php echo $_SESSION["token"];?>"><img height="15" width="15" border="0"border="0" src="<?php echo $GLOBALS['hosturl']."/".$GLOBALS['root']."/";?>themes/<?php echo $theme;?>/img/up.png"></a></th>
										<th class="style3">Name<a href="?func=boeyes&boeye_func=list_all&sort=name&ord=ASC&from=<?php echo $from;?>&to=<?php echo $inc;?>&token=<?php echo $_SESSION["token"];?>"><img height="15" width="15" border="0"border="0" src="<?php echo $GLOBALS['hosturl']."/".$GLOBALS['root']."/";?>themes/<?php echo $theme;?>/img/down.png"></a><a href="?func=boeyes&boeye_func=list_all&sort=name&ord=DESC&from=<?php echo $from;?>&to=<?php echo $inc;?>&token=<?php echo $_SESSION["token"];?>"><img height="15" width="15" border="0"border="0" src="<?php echo $GLOBALS['hosturl']."/".$GLOBALS['root']."/";?>themes/<?php echo $theme;?>/img/up.png"></a></th>
										<th class="style3">Edit?</th>
										<th class="style3">Delete?</th>
										<th class="style3">Lat<a href="?func=boeyes&boeye_func=list_all&sort=lat&ord=ASC&from=<?php echo $from;?>&to=<?php echo $inc;?>&token=<?php echo $_SESSION["token"];?>"><img height="15" width="15" border="0"border="0" src="<?php echo $GLOBALS['hosturl']."/".$GLOBALS['root']."/";?>themes/<?php echo $theme;?>/img/down.png"></a><a href="?func=boeyes&boeye_func=list_all&sort=lat&ord=DESC&from=<?php echo $from;?>&to=<?php echo $inc;?>&token=<?php echo $_SESSION["token"];?>"><img height="15" width="15" border="0"border="0" src="<?php echo $GLOBALS['hosturl']."/".$GLOBALS['root']."/";?>themes/<?php echo $theme;?>/img/up.png"></a></th>
										<th class="style3">Long<a href="?func=boeyes&boeye_func=list_all&sort=long&ord=ASC&from=<?php echo $from;?>&to=<?php echo $inc;?>&token=<?php echo $_SESSION["token"];?>"><img height="15" width="15" border="0"border="0" src="<?php echo $GLOBALS['hosturl']."/".$GLOBALS['root']."/";?>themes/<?php echo $theme;?>/img/down.png"></a><a href="?func=boeyes&boeye_func=list_all&sort=long&ord=DESC&from=<?php echo $from;?>&to=<?php echo $inc;?>&token=<?php echo $_SESSION["token"];?>"><img height="15" width="15" border="0"border="0" src="<?php echo $GLOBALS['hosturl']."/".$GLOBALS['root']."/";?>themes/<?php echo $theme;?>/img/up.png"></a></th>
										<th class="style3">Catagory<a href="?func=boeyes&boeye_func=list_all&sort=cat&ord=ASC&from=<?php echo $from;?>&to=<?php echo $inc;?>&token=<?php echo $_SESSION["token"];?>"><img height="15" width="15" border="0"border="0" src="<?php echo $GLOBALS['hosturl']."/".$GLOBALS['root']."/";?>themes/<?php echo $theme;?>/img/down.png"></a><a href="?func=boeyes&boeye_func=list_all&sort=cat&ord=DESC&from=<?php echo $from;?>&to=<?php echo $inc;?>&token=<?php echo $_SESSION["token"];?>"><img height="15" width="15" border="0"border="0" src="<?php echo $GLOBALS['hosturl']."/".$GLOBALS['root']."/";?>themes/<?php echo $theme;?>/img/up.png"></a></th>
										<th class="style3">Share?</th>
									</tr>
									<?php
									$user_cache = 'waypoints_'.$username;
									$sql0 = "SELECT * FROM `$db`.`$user_cache` ORDER BY `$sort` $ord LIMIT $from, $inc";
									$result = mysql_query($sql0, $conn);
									$total_rows = mysql_num_rows($result);
									if($total_rows > 0)
									{
										while($gcache = mysql_fetch_array($result))
										{
											if($tracker == 0)
											{
												$style_class = "light";
												$tracker = 1;
											}else
											{
												$style_class = "dark";
												$tracker = 0;
											}
												?><tr>
													<td class="<?php echo $style_class;?>">
														<?php echo $gcache['id'];?>
													</td>
													<td class="<?php echo $style_class;?>">
														<a class="links" href="?func=boeyes&boeye_func=fetch_wpt&id=<?php echo $gcache['id'];?>"><?php echo $gcache['name'];?></a>
													</td>
													<td class="<?php echo $style_class;?>">
														<a class="links" href="?func=boeyes&boeye_func=update_wpt&id=<?php echo $gcache['id'];?>">Edit</a>
													</td>
													<td class="<?php echo $style_class;?>">
														<a class="links" href="?func=boeyes&boeye_func=remove_wpt&id=<?php echo $gcache['id'];?>">Delete</a>
													</td>
													<td class="<?php echo $style_class;?>">
														<?php echo $gcache['lat'];?>
													</td>
													<td class="<?php echo $style_class;?>">
														<?php echo $gcache['long'];?>
													</td>
													<td class="<?php echo $style_class;?>">
														<?php echo $gcache['cat'];?>
													</td>
													<td class="<?php echo $style_class;?>">
														<form method="post" action="?func=boeyes&boeye_func=<?php if($gcache['share'] == 1){echo "remove_share_wpt_proc";}else{echo "share_wpt_proc";}?>" name="insertForm"  enctype="multipart/form-data">
														<input name="share_wpt_id" type="hidden" <?php if($gcache['share']==1){echo "checked";}?> value="<?php echo $gcache['id']; ?>" >
														<input type="submit" value="<?php if($gcache['share'] == 1){echo "Hide Me!";}else{echo "Share Me!";}?>">
														</form>
													</td>
												</tr>
										<?php
										}
									}else
									{?>
										<tr>
											<td class="light" colspan="8">
											<CENTER>
											You have no caches, get <a class="links" href="?func=boeyes&boeye_func=import_switch">crackin'</a>
											</CENTER>
											</td>
										</tr>
									<?php
									}
									?>
									<tr><td colspan="8"><CENTER>
								<?php
								$sql0 = "SELECT * FROM `$db`.`$user_cache`";
								$result = mysql_query($sql0, $conn);
								$total_rows = mysql_num_rows($result);
								$from_fwd=$from;
								$from = 0;
								$page = 1;
								$pages = $total_rows/$inc;
								
								if($total_rows > 0)
								{
									$pages_exp = explode(".",$pages);
							#		echo $pages.' --- '.$pages_exp[1].'<BR>';
									$pages_end = "0.".$pages_exp[1];
								}else
								{
									$pages_end = 0;
								}
								$pages_end = $pages_end+0;
								$pages = $pages-$pages_end;
						#		echo $pages.' --- '.$pages_end.'<BR>';
								$mid_page = ($from_/$inc)+1;
								$pages_together = ' [<a class="links" href="?func=boeyes&boeye_func=list_all&from=0&to='.$inc.'&sort='.$sort.'&ord='.$ord.'">First</a>] - ';
								for($I=0; $I<=$pages; $I++)
								{
									if($I >= ($mid_page - 6) AND $I <= ($mid_page + 4))
									{
						#				echo $mid_page." --- ".$I." --- ".$page."<BR>";
										
										if($mid_page == $page)
										{
											$pages_together .= ' <i><u>'.$page.'</u></i> - ';
										}else
										{
											$pages_together .= ' <a class="links" href="?func=boeyes&boeye_func=list_all&from='.$from.'&to='.$inc.'&sort='.$sort.'&ord='.$ord.'&token='.$_SESSION["token"].'">'.$page.'</a> - ';
										}
									}
									$from=$from+$inc;
									$page++;
								}
								$pages_together .= ' [<a class="links" href="?func=boeyes&boeye_func=list_all&from='.(($pages)*$inc).'&to='.$inc.'&sort='.$sort.'&ord='.$ord.'">Last</a>]  ';
								echo "<br>Page: < ".$pages_together." >";
								?>
								</CENTER>
								</td></tr></table>
								</td>
							</tr>
						</table>
						<?php
					break;
					
					case "remove_share_wpt_proc":
						user_panel_bar("myst", 1);
						?><tr>
								<td colspan="6" class="dark">
									<CENTER>
										<?php
										$id = 0;
										$id = filter_input(INPUT_POST, 'share_wpt_id', FILTER_SANITIZE_SPECIAL_CHARS);
										$share_rtn = $myscache->remove_share_wpt($id);
								#		dump($share_rtn);
										$name = $GLOBALS['cachename'];
										switch($share_rtn)
										{
											case is_array($share_rtn):
												list($username, $error) = $share_rtn;
												echo $error;
												break;

											case "login":
												echo "You are not logged in, please do so.";
												break;

											case 1:
												redirect_page("?func=boeyes&boeye_func=list_all",2000,"Un-share of Geocache: $name ( $id )<br>Was successful.");
												break;
										}
										?>
									</CENTER>
								</td></tr></table>
								</td>
							</tr>
						</table>
						<?php
					break;
					
					case "remove_wpt":
						user_panel_bar("myst", 1);
						?><tr>
								<td colspan="6" class="dark">
									<CENTER>
										<?php
										$id = 0;
										$id = filter_input(INPUT_POST, 'wpt_id', FILTER_SANITIZE_SPECIAL_CHARS);
										$share_rtn = $myscache->remove_wpt($id);
									#	dump($share_rtn);
										$name = $GLOBALS['cachename'];
										switch($share_rtn)
										{
											case is_array($share_rtn):
												list($val, $error) = $share_rtn;
												echo $error;
												break;

											case "login":
												echo "You are not logged in, please do so.";
												break;

											case 1:
												redirect_page("?func=boeyes&boeye_func=list_all",2000,"Geocache: $name ( $id )<br> Deletion Was successful.");
												break;
										}
										?>
									</CENTER>
								</td></tr></table>
								</td>
							</tr>
						</table>
						<?php
					break;
					
					case "share_wpt_proc":
						user_panel_bar("myst", 1);
						?><tr>
								<td colspan="6" class="dark">
									<CENTER>
										<?php
										$id = 0;
										$id = filter_input(INPUT_POST, 'share_wpt_id', FILTER_SANITIZE_SPECIAL_CHARS);
										$share_rtn = $myscache->share_wpt($id);
								#		dump($share_rtn);
										$name = $GLOBALS['cachename'];
										switch($share_rtn)
										{
											case is_array($share_rtn):
												list($username, $error) = $share_rtn;
												echo $error;
											break;
											case "dupe":
												redirect_page("?func=boeyes&boeye_func=list_all", 2000, "This Cache is already shared... what are you tryin' to do man?");
											break;
											case "login":
												redirect_page("../login.php", 2000, "You are not logged in, please do so.");
											break;
											case 1:
												redirect_page("?func=boeyes&boeye_func=list_all", 2000, "Share of Waypoint: $name ( $id )<br>Was sucssesfull.");
											break;
										}
										?>
									</CENTER>
								</td>
							</tr>
						</table>
						<?php
					break;
					
					case "update_wpt":
						$id = 0;
						$id = filter_input(INPUT_GET, 'id', FILTER_SANITIZE_SPECIAL_CHARS);
						$User_cache = 'waypoints_'.$username;
						$select = "SELECT * FROM `$db`.`$User_cache` WHERE `id` = '$id'";
						$return = mysql_query($select, $conn);
						$pri_wpt = mysql_fetch_array($return);
						user_panel_bar("myst", 1);
						?><tr>
								<td colspan="6" class="dark">
									<CENTER>
										<h2>Edit Geocache data</h2>
										<form method="post" action="?func=boeyes&boeye_func=update_wpt_proc" name="insertForm"  enctype="multipart/form-data">
										<table align="center" class="tree" border="1">
											<tr >
												<td  align="center" style="width: 20%" class="style4">Name</td>
												<td class="dark">
													<input type="text" name="name" value="<?php echo $pri_wpt['name'];?>" size="40"/>
												</td>
											</tr>
											<tr class="odd">
												<td  align="center" style="width: 20%" class="style4">Author</td>
												<td class="light">
													<input type="text" name="author" value="<?php echo $pri_wpt['author'];?>" size="40"/>
												</td>
											</tr>
											<tr class="odd">
												<td  align="center" style="width: 20%" class="style4">GCID</td>
												<td class="dark">
													<input type="text" name="gcid" value="<?php echo $pri_wpt['gcid'];?>" size="40"/>
												</td>
											</tr>
											<tr >
												<td  align="center" class="style4">Notes</td>
												<td class="light">
													<textarea name="notes" tabindex="10" style="width: 481px; height: 216px" ><?php echo $pri_wpt['notes'];?></textarea>            
												</td>
											</tr>
											<tr class="odd">
												<td  align="center" class="style4">Catagory</td>
												<td class="dark">
													<input type="text" name="cat" value="<?php echo $pri_wpt['cat'];?>"style="width: 335px" />
												</td>
											</tr>
											<tr >
												<td align="center" class="style4">Type</td>
												<td class="light">
													<input type="text" name="type" value="<?php echo $pri_wpt['type'];?>"style="width: 335px" />
												</td>
												</tr>
											<tr >
												<td align="center" class="style4">Difficulty</td>
												<td class="dark">
													<input type="text" name="diff" value="<?php echo $pri_wpt['diff'];?>"style="width: 335px" />
												</td>
												</tr>
											<tr >
												<td align="center" class="style4">Terain</td>
												<td class="light">
													<input type="text" name="terain" value="<?php echo $pri_wpt['terain'];?>"style="width: 335px" />
												</td>
												</tr>
											<tr class="odd">
												<td  align="center" class="style4">Lat</td>
												<td class="dark">
													<input type="text" name="lat" value="<?php echo $pri_wpt['lat'];?>" style="width: 100px"/>
												</td>
											</tr>
											<tr >
												<td  align="center" class="style4">Long</td>
												<td class="light">
													<input type="text" name="long" value="<?php echo $pri_wpt['long'];?>" style="width: 100px"/>
												</td>
											</tr>
											<tr class="odd">
												<td  align="center" class="style4">Link</td>
												<td class="dark">
													<input type="text" name="link" value="<?php echo $pri_wpt['link'];?>" style="width: 476px" />
												</td>
											</tr>
											<tr>
												<td colspan='2'>
													<input type="hidden" name="id" value="<?php echo $pri_wpt['id'];?>"/>
													<CENTER><input type="submit" value="Update Me!"></CENTER>
												</td>
											</tr>
										</table>
										</form>
									</CENTER>
								</td></tr></table>
								</td>
							</tr>
						</table>
						<?php
					break;
					
					
					case "update_wpt_proc":
						$id = filter_input(INPUT_POST, 'id', FILTER_SANITIZE_SPECIAL_CHARS);
						$name = filter_input(INPUT_POST, 'name', FILTER_SANITIZE_SPECIAL_CHARS);
						$author = filter_input(INPUT_POST, 'author', FILTER_SANITIZE_SPECIAL_CHARS);
						$gcid = filter_input(INPUT_POST, 'gcid', FILTER_SANITIZE_SPECIAL_CHARS);
						$notes = filter_input(INPUT_POST, 'notes', FILTER_SANITIZE_SPECIAL_CHARS);
						$cat = filter_input(INPUT_POST, 'cat', FILTER_SANITIZE_SPECIAL_CHARS);
						$type = filter_input(INPUT_POST, 'type', FILTER_SANITIZE_SPECIAL_CHARS);
						$terain = filter_input(INPUT_POST, 'terain', FILTER_SANITIZE_SPECIAL_CHARS);
						$diff = filter_input(INPUT_POST, 'diff', FILTER_SANITIZE_SPECIAL_CHARS);
						$lat = filter_input(INPUT_POST, 'lat', FILTER_SANITIZE_SPECIAL_CHARS);
						$long = filter_input(INPUT_POST, 'long', FILTER_SANITIZE_SPECIAL_CHARS);
						$link = filter_input(INPUT_POST, 'link', FILTER_SANITIZE_SPECIAL_CHARS);
						user_panel_bar("myst", 1);
						?><tr>
								<td colspan="6" class="dark">
									<CENTER>
									<?php
									echo $cat." - inside func<BR>";
									$update = $myscache->update_wpt($id, $author, $name, $gcid, $notes, $cat, $type, $terain, $diff, $lat, $long, $link);
								#	dump($update);
									switch($update)
									{
										case is_array($update):
											list($username, $error) = $update;
											echo $error;
											break;

										case "login":
											redirect_page("../login.php", 2000, "You are not logged in, please do so.");
											break;

										case 1:
											redirect_page("?func=boeyes&boeye_func=list_all", 2000, "Update of Waypoint: ".$update."<br>Was successful.", 0);
											break;
									}
									?>
									</CENTER>
								</td>
							</tr>
						</table>
						<?php
					break;
					
					
					case "import_switch":
						user_panel_bar("myst", "import");
						?><tr>
								<td colspan="6" class="dark">
									<CENTER>
										<h3>All supported files are Mysticache Exports</h3>
										<table>
											<tr>
												<td><a class="links" href="?func=boeyes&boeye_func=import_gpx">Import GPX</a> - <a class="links_sample" target="_new" href="http://vistumbler.svn.sourceforge.net/viewvc/vistumbler/Mysticache/sample.gpx?view=markup">Sample</a></td>
											</tr>
											<tr>
												<td><a class="links" href="?func=boeyes&boeye_func=import_loc">Import LOC</a> - <a class="links_sample" target="_new" href="http://vistumbler.svn.sourceforge.net/viewvc/vistumbler/Mysticache/test.loc?view=markup">Sample</a></td>
											</tr>
										</table>
									</CENTER>
								</td>
							</tr>
						</table>
						<?php
					break;
					
					
					case "import_gpx":
						user_panel_bar("myst", "gpx");
						?><tr>
								<td colspan="6" class="dark">
									<CENTER>
									<?php
									if (isset($_GET['file']))
									{
										$file_de = urldecode($_GET['file']);
										$get_exp = explode('\\\\',$file_de);
										$file_imp = implode("%5C", $get_exp);
										$file_imp = str_replace("%5C%5C", "&#92;", $file_imp);
										echo "<h3>Due to security restrictions in current browsers, file fields cannot have dynamic content,
										<br>The file that you are trying to import via Vistumbler Is here:
										<br><font color='red'><b><u>".$file_imp."</u></b></font>
										<br>Copy and Paste the underlined text into the file location field to import it.<br></h3>";
									}
									?>
									
									<h2>Import Mysticache GPX file</h2>
										<form action="?func=boeyes&boeye_func=import_gpx_proc" method="post" enctype="multipart/form-data">
										<TABLE BORDER=1 CELLPADDING=2 CELLSPACING=0>
											<TR height="40">
												<TD class="style4">
													<P>File location: 
													</P>
												</TD>
												<TD class="light">
													<P><A NAME="file"></A><INPUT TYPE=FILE NAME="file" SIZE=56 STYLE="width: 5.41in; height: 0.25in"></P>
												</TD>
											</TR>
											<TR class="light">
												<TD>&nbsp;</TD><TD>
													<P>
												<?php	
													if($rebuild === 0)
													{
													echo '<INPUT TYPE=SUBMIT NAME="submit" VALUE="Submit" STYLE="width: 0.71in; height: 0.36in"></P>';
													}else{echo "The database is in  rebuild mode, please wait...";}
												?>
												</TD>
											</TR>
										</TABLE>
										</form>
									</CENTER>
								</td>
							</tr>
						</table>
						<?php
						
					break;
					
					case "import_gpx_proc":
						user_panel_bar("myst", "gpx");
						?><tr>
								<td colspan="6" class="dark">
									<CENTER><?php
						include('../lib/wdb_xml.inc.php');
						$wdbxml = new WDB_XML();
						
						
						$userfolder = getcwd().'/up/'.$username;
						$uploadfolder = $userfolder."/gpx";
						if(!(is_dir($userfolder)))
						{
						#	echo "Make Folder $daily_folder\n";
							if(!mkdir($userfolder))
							{echo "Failed to make user upload folder";}
							else
							{
								if(!mkdir($uploadfolder)){echo "Failed to make GPX folder";}
							}
						}
						
						$tmp		=	$_FILES['file']['tmp_name'];
						$filename	=	$_FILES['file']['name'];
						$rand		=	rand();
						$xml_file 	= 	$uploadfolder.$rand.'_'.$filename;
						
						if (copy($tmp, $xml_file))
						{
							$import_rtn = $wdbxml->import_xml($xml_file);
							switch($import_rtn)
							{
								case is_array($import_rtn):
									list($username, $wpts) = $import_rtn;
									redirect_page("?func=boeyes&boeye_func=list_all", 2000, "", 0);
									echo "<h2>Success!<br>User: ".$username."<BR> Filename: ".$filename." <br> Number of Wpts: ".$wpts."</h2>";
									break;
									
								case "login":
									redirect_page("../login.php", 2000, "You are not logged in, please do so.");
									break;

								case 0:
									redirect_page("../login.php", 2000, "There was a faital error in importing.");
									break;
							}
						}else
						{
							echo "Could not copy, you either did not provide a file, or there is a problem on the server.";
						}
						?>
									</CENTER>
								</td>
							</tr>
						</table>
						<?php
					break;
					
					
					case "import_loc":
						user_panel_bar("myst", "loc");
						?><tr>
								<td colspan="6" class="dark">
									<CENTER>
									<?php
									if(@$_GET['file'] != '')
									{
										$file = filter_var(addslashes($_GET['file']),FILTER_SANITIZE_ENCODED);
										echo "<h3>You are trying to upload a file from Mysticache, Copy the below:<br>".$file;
									}
									?>
									<h2>Import Mysticache LOC file</h2>
										<form action="?func=boeyes&boeye_func=import_loc_proc" method="post" enctype="multipart/form-data">
										<TABLE BORDER=1 CELLPADDING=2 CELLSPACING=0>
											<TR height="40" class="style4">
												<TD class="style4">
													<P>File location: 
													</P>
												</TD>
												<TD class="light">
													<P><A NAME="file"></A><INPUT TYPE=FILE NAME="file" SIZE=56 STYLE="width: 5.41in; height: 0.25in"></P>
												</TD>
											</TR>
											<TR class="light">
												<TD>&nbsp;</TD><TD>
													<P>
												<?php	
													if($rebuild === 0)
													{
													echo '<INPUT TYPE=SUBMIT NAME="submit" VALUE="Submit" STYLE="width: 0.71in; height: 0.36in"></P>';
													}else{echo "The database is in  rebuild mode, please wait...</p>";}
												?>
												</TD>
											</TR>
										</TABLE>
										</form>
									</CENTER>
								</td>
							</tr>
						</table>
						<?php
						
					break;
					
					case "import_loc_proc":
						user_panel_bar("myst", "loc");
						?><tr>
								<td colspan="6" class="dark">
									<CENTER>
						<?php
						include('../lib/wdb_xml.inc.php');
						$wdbxml = new WDB_XML();
						
						if($_POST["user"] !== ''){$user = addslashes($_POST["user"]);}else{$user="Unknown";}
						if($_POST["notes"] !== ''){$notes = addslashes($_POST["notes"]);}else{$notes="No Notes";}
						if($_POST['title'] !== ''){$title = addslashes($_POST['title']);}else{$title="Untitled";}
						
						$userfolder = getcwd().'/up/'.$username;
						$uploadfolder = $userfolder."/loc";
						if(!(is_dir($userfolder)))
						{
						#	echo "Make Folder $daily_folder\n";
							if(!mkdir($userfolder))
							{echo "Failed to make user upload folder";}
							else
							{
								if(!mkdir($uploadfolder)){echo "Failed to make LOC folder";}
							}
						}
						
						$tmp		=	$_FILES['file']['tmp_name'];
						$filename	=	$_FILES['file']['name'];
						$rand		=	rand();
						$xml_file 	= 	$uploadfolder.$rand.'_'.$filename;
						
						if (copy($tmp, $xml_file))
						{
							$import_rtn = $wdbxml->import_xml($xml_file);
							
							switch($import_rtn)
							{
								case is_array($import_rtn):
									list($username, $wpts) = $import_rtn;
									echo "<h2>Success!<br>User: ".$username."<BR> Filename: ".$filename." <br> Number of Wpts: ".$wpts."</h2>";
									redirect_page("?func=boeyes&boeye_func=list_all", 2000, "", 0);
									break;

								case "login":
									redirect_page("../login.php", 2000, "You are not logged in, please do so.");
									break;

								case 0:
									redirect_page("../login.php", 2000, "There was a faital error in importing.");
									break;
							}
						}else
						{
							echo "Could not copy";
						}
						?>
									</CENTER>
								</td>
							</tr>
						</table>
						<?php
					break;
					
					#####################
					default:
						$User_cache = 'waypoints_'.$username;
						$select = "SELECT * FROM `$db`.`$User_cache`";
						$return = mysql_query($select, $conn);
						$num_wpts = @mysql_num_rows($return);
				#		echo $select;
						$select = "SELECT * FROM `$db`.`$User_cache` WHERE `share` = '1'";
						$return = mysql_query($select, $conn);
						$num_shared_wpts = @mysql_num_rows($return);
				#		echo $select;
						user_panel_bar("myst", 1);
						?>
								<td colspan="6" class="dark">
								<CENTER><table BORDER=1 CELLPADDING=2 CELLSPACING=0 width ="50%">
									<tr>
										<th colspan="2" class="style4">
										Cache Statistics
										</th>
									</tr>
									<tr>
										<td width="60%" class="style4">
											Number of Caches:
										</td>
										<td class="light">
											<?php echo $num_wpts;?>
										</td>
									</tr>
									<tr>
										<td width="60%" class="style4">
											Number of Shared Caches:
										</td>
										<td class="light">
											<?php echo $num_shared_wpts;?>
										</td>
									</tr>
								</table>
								</CENTER>
								</td>
							</tr>
						</table>
						<?php
					break;
				}
				footer($_SERVER['SCRIPT_FILENAME']);
			break;
			
			
			##-------------##
			case 'fandf':
				pageheader("User Control Panel --> Friends and Foes");
				$sql0 = "SELECT * FROM `$db`.`$user_logins_table` WHERE `username` = '$username' LIMIT 1";
				$result = mysql_query($sql0, $conn);
				$newArray = mysql_fetch_array($result);
				$friends = explode(":", $newArray['friends']);
				$foes = explode(":", $newArray['foes']);
				$type = htmlentities(@$_GET['type'], ENT_QUOTES);
				switch($type)
				{
					case "friends":
						$mode = htmlentities(@$_GET['mode'], ENT_QUOTES);
						switch($mode)
						{
							case "del":
								user_panel_bar("fandf", 0);
								?>
									<tr>
										<td colspan="5">
										<?php
								$sql0 = "SELECT `friends` FROM `$db`.`$user_logins_table` WHERE `username` = '$username'";
								$result = mysql_query($sql0, $conn);
								$friends_array = mysql_fetch_array($result);
								$frnd_array = explode(":", $friends_array['friends']);
								
								$del_array = $_POST['del'];
								foreach($del_array as $key=>$del)
								{$del = htmlentities($del, ENT_QUOTES);$del_array[$key] = $del;}
								
								foreach($del_array as $del)
								{
									foreach($frnd_array as $key=>$frnd)
									{
										if($frnd == $del)
										{
											unset($frnd_array[$key]);
										}
									}
								}
								$deled = implode(":", $frnd_array);
								
								$update_frnd = "UPDATE `$db`.`$user_logins_table` SET `friends` = '$deled' WHERE `username`='$username'";
								if(mysql_query($update_frnd, $conn))
								{
									redirect_page("?func=fandf&type=friends", 2000, "<CENTER><table><tr class='sub_head'><td>Friends list updated!</td></tr></table></CENTER>", 0);
								}else
								{
									echo "<CENTER><table><tr class='sub_head'><td>Failed to update the users Friends List...<br>Mysql Error: ".mysql_error($conn)."</td></tr></table></CENTER>";
								}
								?></td>
								</tr>
							</table><?php
							break;
							
							case "add":
								user_panel_bar("fandf", 0);
								?>
									<tr>
										<td colspan="5">
										<?php
								$sql0 = "SELECT `friends` FROM `$db`.`$user_logins_table` WHERE `username` = '$username'";
							#	echo $sql0;
								$result = mysql_query($sql0, $conn);
								$friends_array = mysql_fetch_array($result);
								
								$add_array = $_POST['add'];
								foreach($add_array as $key=>$add)
								{$add = htmlentities($add, ENT_QUOTES);$add_array[$key] = $add;}
								if($friends_array['friends'] != '')
								{$added = $friends_array['friends'].":".implode(":", $add_array);}
								else{$added = implode(":", $add_array);}
								
							#	echo $added;
								
								$update_frnd = "UPDATE `$db`.`$user_logins_table` SET `friends` = '$added' WHERE `username`='$username'";
								if(mysql_query($update_frnd, $conn))
								{
									redirect_page("?func=fandf&type=friends", 2000, "<CENTER><table><tr class='sub_head'><td>Freinds list updated!</td></tr></table></CENTER>", 0);
								}else
								{
									echo "<CENTER><table><tr class='sub_head'><td>Failed to update the users Friends List...<br>Mysql Error: ".mysql_error($conn)."</td></tr></table></CENTER>";
								}
								?></td>
								</tr>
							</table><?php
							break;
							
							default:
								$sql0 = "SELECT `friends`, `foes` FROM `$db`.`$user_logins_table` WHERE `username` = '$username'";
								$result = mysql_query($sql0, $conn);
								$friends_array = mysql_fetch_array($result);
								$frnd_array = explode(":", $friends_array['friends']);
								$foe_array = explode(":", $friends_array['foes']);
								$inside = array();
								$outside = array();
								$sql0 = "SELECT `username` FROM `$db`.`$user_logins_table` WHERE `username` NOT LIKE 'admin%'";
								$result = mysql_query($sql0, $conn);
								while($users = mysql_fetch_array($result))
								{
									if($users['username'] == $username){continue;}
									foreach($foe_array as $foe){if($foe == $users['username']){continue 2;}}
									
									foreach($frnd_array as $frnd)
									{
										if($frnd == $users['username'])
										{
											$inside[] = $users['username'];
											continue 2;
										}
									}
									$outside[] = $users['username'];
								}
								user_panel_bar("fandf", 0);
								?>
									<tr>
										<td colspan="5">
										<table width="100%" border="1">
											<tr class="style4">
												<th>Users currently in Friends:</th>
												<th>Users Not In Friends:</th>
											</tr>
											<tr>	
												<td class="light" align="center" width="50%">
												<form method="post" action="" name="remove_from_friends_group"  enctype="multipart/form-data">
													<select name="del[]" multiple size="10" style="width: 100%;">
													<?php
													foreach($inside as $in)
													{
														echo "<option value='".$in."'>".$in."</option>\r\n";
													}
													?>
													</select>
													<br>
													<input type="button" name="remove_friend_submit" value="Remove Selected User(s)" onClick="document.remove_from_friends_group.action='?func=fandf&type=friends&mode=del'; document.remove_from_friends_group.submit();" />
													</form>
												</td>
												<!--#####################-->
												<td class="light" align="center">
												<form method="post" action="" name="add_to_friends_group" enctype="multipart/form-data">
													<select name="add[]" multiple size="10" style="width: 100%;">
													<?php
													foreach($outside as $out)
													{
														echo "<option value='".$out."'>".$out."</option>\r\n";
													}
													?>
													</select>
													<br>
													<input type="button" name="add_friend_submit" value="Add Selected User(s)" onClick="document.add_to_friends_group.action='?func=fandf&type=friends&mode=add'; document.add_to_friends_group.submit();" />
												</form>
												</td>
											</tr>
										</table>
									</td>
								</tr>
							</table
							<?php
							break;
						}
					break;
					
					case "foes":
						$mode = htmlentities(@$_GET['mode'], ENT_QUOTES);
						switch($mode)
						{
							case "del":
								user_panel_bar("fandf", 0);
								?>
									<tr>
										<td colspan="5">
										<?php
								$sql0 = "SELECT `foes` FROM `$db`.`$user_logins_table` WHERE `username` = '$username'";
								$result = mysql_query($sql0, $conn);
								$foes_array = mysql_fetch_array($result);
								$foe_array = explode(":", $foes_array['foes']);
								
								$del_array = $_POST['del'];
								foreach($del_array as $key=>$del)
								{$del = htmlentities($del, ENT_QUOTES);$del_array[$key] = $del;}
								
								foreach($del_array as $del)
								{
									foreach($foe_array as $key=>$foe)
									{
										if($foe == $del)
										{
											unset($foe_array[$key]);
										}
									}
								}
								$deled = implode(":", $foe_array);
								
								$update_foe = "UPDATE `$db`.`$user_logins_table` SET `foes` = '$deled' WHERE `username`='$username'";
								if(mysql_query($update_foe, $conn))
								{
									redirect_page("?func=fandf&type=foes", 2000, "<CENTER><table><tr class='sub_head'><td> Foes list updated!</td></tr></table></CENTER>", 0);
								}else
								{
									echo "<CENTER><table><tr class='sub_head'><td>Failed to update the users Foes List...<br>Mysql Error: ".mysql_error($conn)."</td></tr></table></CENTER>";
								}
								?></td>
								</tr>
							</table><?php
							break;
							
							case "add":
								user_panel_bar("fandf", 0);
								?>
									<tr>
										<td colspan="5">
										<?php
								$sql0 = "SELECT `foes` FROM `$db`.`$user_logins_table` WHERE `username` = '$username'";
							#	echo $sql0;
								$result = mysql_query($sql0, $conn);
								$foes_array = mysql_fetch_array($result);
								
								$add_array = $_POST['add'];
								foreach($add_array as $key=>$add)
								{$add = htmlentities($add, ENT_QUOTES);$add_array[$key] = $add;}
								if($foes_array['foes'] != '')
								{$added = $foes_array['foes'].":".implode(":", $add_array);}
								else{$added = implode(":", $add_array);}
								
							#	echo $added;
								
								$update_foe = "UPDATE `$db`.`$user_logins_table` SET `foes` = '$added' WHERE `username`='$username'";
								if(mysql_query($update_foe, $conn))
								{
									redirect_page("?func=fandf&type=foes", 2000, "<CENTER><table><tr class='sub_head'><td>Foes list updated!</td></tr></table></CENTER>", 0);
								}else
								{
									echo "<CENTER><table><tr class='sub_head'><td>Failed to update the users Foes List...<br>Mysql Error: ".mysql_error($conn)."</td></tr></table></CENTER>";
								}
								?></td>
								</tr>
							</table><?php
							break;
							
							default:
								$sql0 = "SELECT `friends`, `foes` FROM `$db`.`$user_logins_table` WHERE `username` = '$username'";
								$result = mysql_query($sql0, $conn);
								$foes_array = mysql_fetch_array($result);
								
								$frnd_array = explode(":", $foes_array['friends']);
								$foe_array = explode(":", $foes_array['foes']);
								
								$inside = array();
								$outside = array();
								
								$sql0 = "SELECT `username` FROM `$db`.`$user_logins_table` WHERE `username` NOT LIKE 'admin%'";
								$result = mysql_query($sql0, $conn);
								while($users = mysql_fetch_array($result))
								{
									if($users['username'] == $username){continue;}
									foreach($frnd_array as $frnd){if($frnd == $users['username']){continue 2;}}
									
									foreach($foe_array as $foe)
									{
										if($foe == $users['username'])
										{
											$inside[] = $users['username'];
											continue 2;
										}
									}
									$outside[] = $users['username'];
								}
								user_panel_bar("fandf", 0);
								?>
									<tr>
										<td colspan="5">
										<table width="100%" border="1">
											<tr class="style4">
												<th>Users currently in Foes:</th>
												<th>Users Not In Foes:</th>
											</tr>
											<tr>	
												<td class="light" align="center" width="50%">
												<form method="post" action="" name="remove_from_foes_group"  enctype="multipart/form-data">
													<select name="del[]" multiple size="10" style="width: 100%;">
													<?php
													foreach($inside as $in)
													{
														echo "<option value='".$in."'>".$in."</option>\r\n";
													}
													?>
													</select>
													<br>
													<input type="button" name="remove_friend_submit" value="Remove Selected User(s)" onClick="document.remove_from_foes_group.action='?func=fandf&type=foes&mode=del'; document.remove_from_foes_group.submit();" />
													</form>
												</td>
												<!--#####################-->
												<td class="light" align="center">
												<form method="post" action="" name="add_to_foes_group" enctype="multipart/form-data">
													<select name="add[]" multiple size="10" style="width: 100%;">
													<?php
													foreach($outside as $out)
													{
														echo "<option value='".$out."'>".$out."</option>\r\n";
													}
													?>
													</select>
													<br>
													<input type="button" name="add_friend_submit" value="Add Selected User(s)" onClick="document.add_to_foes_group.action='?func=fandf&type=foes&mode=add'; document.add_to_foes_group.submit();" />
												</form>
												</td>
											</tr>
										</table>
									</td>
								</tr>
							</table>
							<?php
							break;
						}
					break;
					
					default:
						user_panel_bar("fandf", 0);
						?>
							<tr>
								<td colspan="6" class="dark">
								<CENTER>
								<?php
								?>
								<table BORDER=1 CELLPADDING=2 CELLSPACING=0 style="width: 50%">
									<tr>
										<th class="style3" colspan="2">Select some freinds, and block some Foes</th>
									</tr>
									<tr>
										<th width="30%" class="style3">Friends</th>
										<td>
											<CENTER><a class="links" href="?func=fandf&type=friends">Manage Friends</a></CENTER>
										</td>
									</tr>
									<tr>
										<th width="30%" class="style3">Foes</th>
										<td>
											<CENTER><a class="links" href="?func=fandf&type=foes">Manage Foes</a></CENTER>
										</td>
									</tr>
								</table>
								</CENTER>
								</form>
								</td>
							</tr>
						</table>
						<?php
					break;
				}
				footer($_SERVER['SCRIPT_FILENAME']);
			break;
			
			##-------------##
			case "mailbox":
				$page = addslashes(strtolower($_get['page']));
				echo $page;
				pageheader("User Control Panel --> MailBox");
				if($page == '')
				{
					?><b><font size="6"><?php echo $username; ?>'s Mailbox</font></b>
					<script type="text/javascript">

					/***********************************************
					* Dynamic Ajax Content- © Dynamic Drive DHTML code library (www.dynamicdrive.com)
					* This notice MUST stay intact for legal use
					* Visit Dynamic Drive at http://www.dynamicdrive.com/ for full source code
					***********************************************/

					var loadedobjects=""
					var rootdomain="http://"+window.location.hostname

					function ajaxpage(url, containerid){
					var page_request = false
					if (window.XMLHttpRequest) // if Mozilla, Safari etc
					page_request = new XMLHttpRequest()
					else if (window.ActiveXObject){ // if IE
					try {
					page_request = new ActiveXObject("Msxml2.XMLHTTP")
					} 
					catch (e){
					try{
					page_request = new ActiveXObject("Microsoft.XMLHTTP")
					}
					catch (e){}
					}
					}
					else
					return false
					page_request.onreadystatechange=function(){
					loadpage(page_request, containerid)
					}
					page_request.open('GET', url, true)
					page_request.send(null)
					}

					function loadpage(page_request, containerid){
					if (page_request.readyState == 4 && (page_request.status==200 || window.location.href.indexOf("http")==-1))
					document.getElementById(containerid).innerHTML=page_request.responseText
					}

					</script>
					<table width="100%"><tr><td><img alt="" src="<?php echo $GLOBALS['hosturl'].$GLOBALS['root']; ?>/themes/wifidb/img/1x1_transparent.gif" width="100%" height="1" /></td></tr>
					<tr><td id="leftcolumn">
					[<a class="links" href="javascript:ajaxpage('?func=mailbox&page=inbox', 'rightcolumn');">Inbox</a>]
					[<a class="links" href="javascript:ajaxpage('?func=mailbox&page=compose', 'rightcolumn');">Write</a>]
					[<a class="links" href="javascript:ajaxpage('?func=mailbox&page=sentmsgs', 'rightcolumn');">Sent</a>]
					</td></tr>
					<tr>
					<td id="rightcolumn" align="center">
					<iframe src="?func=mailbox&page=inbox" width="100%" height="500">
						<p>Your browser does not support iframes.</p>
					</iframe>
					</td>
					</tr></table>
					<?php
				}else
				{
					switch($page)
					{
						###############
						case "inbox":
							?> <table> <tr><th>Inbox</th></tr></table> <?php
						break;
						###############
						case "compose":
							?> <table> <tr><th>Compose message</th></tr></table> <?php
						break;
						###############
						case "sent":
							?> <table> <tr><th>Sent Messages</th></tr></table> <?php
						break;
					}
				}
				$filename = $_SERVER['SCRIPT_FILENAME'];
				footer($filename);
			break;
			
			
			case "admin_cp":
				pageheader("Administrator Control Panel --> Re-login");
				?>
				<h2>You need to re-login to go to the admin page.</h2>
				<form method="post" action="<?php echo $_SERVER['PHP_SELF'];?>?func=admin_cp_proc">
				<table align="center">
					<tr>
						<td colspan="2"><p align="center"><img src="<?php echo $GLOBALS['hosturl'].$GLOBALS['root']; ?>/themes/wifidb/img/logo.png"></p></td>
					</tr>
					<tr>
						<td><b>Username</b></td>
						<td><input type="text" name="admin_user"></td>
					</tr>
					<tr>
						<td><b>Password</b></td>
						<td><input type="password" name="admin_pass"></td>
					</tr>
					<tr>
						<td colspan="2"><p align="center"><input type="hidden" name="return" value="<?php echo $return;?>"><input type="submit" value="Re-Login"></p></td>
					</tr>
				</table>
				</form>
				<?php
				footer($_SERVER['SCRIPT_FILENAME']);
			break;
			
			case "admin_cp_proc":
				include_once('../lib/security.inc.php');
				
				$username = filter_input(INPUT_POST, 'admin_user', FILTER_SANITIZE_SPECIAL_CHARS);
				$password = filter_input(INPUT_POST, 'admin_pass', FILTER_SANITIZE_SPECIAL_CHARS);
				
				$sec = new security();
				$login = $sec->login($username, $password, $GLOBALS['login_seed'], 1);
				
				pageheader("Administrator Control Panel --> Re-login");
			#	dump($_POST['return']);
				switch($login)
				{
					case "locked":
						?><h2>This user is locked out. Contact this WiFiDB\'s admin, or go to the <a href="http://forum.techidiots.net/">forums</a> and bitch to Phil.<br></h2><?php
					break;
					
					case is_array($login):
						$to_go = $login[1];
						?><p align="center"><font color="red"><h2>Bad Username or Password!</h2></font></p>
						<p align="center"><font color="red"><h3>You have <?php echo $to_go;?> more attmpt(s) till you are locked out.</h3></font></p>
						<?php
						$return = str_replace("%5C", "%5C", $return);
						?>
						<form method="post" action="<?php echo $_SERVER['PHP_SELF'];?>?func=login_proc">
						<table align="center">
							<tr>
								<td colspan="2"><p align="center"><img src="<?php echo $GLOBALS['UPATH']; ?>/themes/wifidb/img/logo.png"></p></td>
							</tr>
							<tr>
								<td><b>Username</b></td>
								<td><input type="text" name="time_user"></td>
							</tr>
							<tr>
								<td><b>Password</b></td>
								<td><input type="password" name="time_pass"></td>
							</tr>
							<tr>
								<td colspan="2"><p align="center"><input type="hidden" name="return" value="<?php echo $return;?>"><input type="submit" value="Login"></p></td>
							</tr>
							<tr>
								<td colspan="2"><p align="center"><a class="links" href="<?php echo $_SERVER['PHP_SELF'];?>?func=create_user_form">Create a user account</a><br><a class="links" href="<?php echo $_SERVER['PHP_SELF'];?>?func=reset_user_pass">Forgot your password?</a></p></td>
							</tr>
						</table>
						</form>
						<?php
					break;
					
					case"u_fail":
						?><h2>Username does not exsist.</h2><?php
					break;
					
					case "u_u_r_fail":
						echo "failed to update User row";
					break;
					
					case "good":
						redirect_page($GLOBALS['UPATH'].'/cp/admin/', 2000, 'Login Successful!', 2);
					break;
					
					case "cookie_fail":
						echo "Set Cookie fail, check the bottom of the glass, or your browser.";
					break;
					
					default:
						?><h2>Unknown Return.<br>Contact this WiFiDB\'s admin, or go to the <a href="http://forum.techidiots.net/">forums</a> and bitch to Phil.<br></h2><?php
					break;
				}
				footer($_SERVER['SCRIPT_FILENAME']);
			break;
			
			##-------------##
			default:
				$privs_a = $GLOBALS['privs_a'];
				list($privs, $priv_name) = $privs_a;
				$conn = $GLOBALS['conn'];
				$username = $GLOBALS['username'];
				################
				$sql0 = "SELECT * FROM `$db`.`$user_logins_table` WHERE `username` = '$username' LIMIT 1";
				$result = mysql_query($sql0, $conn);
				$newArray = mysql_fetch_array($result);
				$last_login = $newArray['last_login'];
				$join_date = $newArray['join_date'];
				
				################
				$sql = "SELECT * FROM `$db`.`$users_t` WHERE `username` LIKE '$username' ORDER BY `id` DESC LIMIT 1";
				$user_query = mysql_query($sql, $conn) or die(mysql_error($conn));
				$user_last = mysql_fetch_array($user_query);
				
				$last_import_id = $user_last['id'];
				$user_aps = $user_last['aps'];
				$user_gps = $user_last['gps'];
				
				$last_import_title = $user_last['title'];
				$last_import_date = $user_last['date'];
				
				###########
				$sql2 = "SELECT * FROM `$db`.`stats_$username` ORDER BY `id` DESC LIMIT 1";
				echo $sql2."<br>";
				$max_gps_query = mysql_query($sql2, $conn) or die(mysql_error($conn));
				$max_gps_array = mysql_fetch_array($user_query);
				$max_ssid_id = $max_gps_array['largest'];
				dump($max_gps_array);
				if($max_gps_array['largest'] == '')
				{
					echo $max_gps_array['largest']."---".$max_gps_array['newest']."<BR>";
					$max_ssid_ = explode(" - ", $max_gps_array['largest']);
					$newest_ = explode(" - ", $max_gps_array['newest']);
					$max_ssid = '<a href="'.$GLOBALS['UPATH'].'opt/fetch.php?id='.$max_ssid_[1].'">'.$max_ssid_[0].'</a> ('.$max_ssid_[2].')';
					$newest = '<a href="'.$GLOBALS['UPATH'].'opt/fetch.php?id='.$newest_[1].'">'.$newest[0].'</a> '.$newest_[2];
				}else
				{
					$max_ssid = "No Max AP yet.";
					$newest = "No Newset AP yet.";
				}
				
				
				###########
				$sql4 = "SELECT * FROM `$db`.`$users_t` WHERE `username` LIKE '$username' ORDER BY `aps` DESC LIMIT 1";
			#	echo $sql4."<BR>";
				$user_query = mysql_query($sql4, $conn) or die(mysql_error($conn));
				$user_largest = mysql_fetch_array($user_query);
				$large_import_title = $user_last['title'];
				
				
				if(@$last_import_title == ''){$last_import_title = "No imports";}
				if(@$large_import_title == ''){$large_import_title = "No imports";}		
				pageheader("User Control Panel --> Overview");
				user_panel_bar("overview", 0);
				?>
					<tr>
						<td colspan="6" class="dark">
						<table  BORDER=1 CELLPADDING=2 CELLSPACING=0 style="width: 100%">
							<tr>
								<th width="30%" class="style3">Privledge Level</th>
								<td align="center" class="light"><?php echo $priv_name; if($newArray['rank'] != ''){echo " ( ".$newArray['rank']." )";}?></td>
							</tr>
							<tr>
								<th width="30%" class="style3">Largest Import</th>
								<td align="center" class="light"><?php echo $large_import_title;?></td>
							</tr>
							<tr>
								<th width="30%" class="style3">Last Import</th>
								<td align="center" class="light"><?php echo $last_import_title;?></td>
							</tr>
							<tr>
								<th width="30%" class="style3">AP with most GPS</th>
								<td align="center" class="light"><?php echo $max_ssid;?></td>
							</tr>
							<tr>
								<th width="30%" class="style3">Newest AP</th>
								<td align="center" class="light"><?php echo $newest;?></td>
							</tr>
							<tr>
								<th width="30%" class="style3">Last Login</th>
								<td align="center" class="light"><?php echo $last_login;?></td>
							</tr>
							<tr>
								<th width="30%" class="style3">Join Date</th>
								<td align="center" class="light"><?php echo $join_date;?></td>
							</tr>
						</table>
						</td>
					</tr>
				</table>
				<?php
				footer($_SERVER['SCRIPT_FILENAME']);
			break;
		}
	}else
	{
		$func = filter_input(INPUT_GET, 'func', FILTER_SANITIZE_SPECIAL_CHARS);
		switch($func)
		{
			case "admin_cp":
				pageheader("Administrator Control Panel --> Re-login");
				?>
				<h2>You need to re-login to go to the admin page.</h2>
				<form method="post" action="<?php echo $_SERVER['PHP_SELF'];?>?func=admin_cp_proc">
				<table align="center">
					<tr>
						<td colspan="2"><p align="center"><img src="<?php echo $GLOBALS['hosturl'].$GLOBALS['root']; ?>/themes/wifidb/img/logo.png"></p></td>
					</tr>
					<tr>
						<td><b>Username</b></td>
						<td><input type="text" name="admin_user"></td>
					</tr>
					<tr>
						<td><b>Password</b></td>
						<td><input type="password" name="admin_pass"></td>
					</tr>
					<tr>
						<td colspan="2"><p align="center"><input type="hidden" name="return" value="<?php echo $return;?>"><input type="submit" value="Re-Login"></p></td>
					</tr>
				</table>
				</form>
				<?php
				footer($_SERVER['SCRIPT_FILENAME']);
			break;
			
			case "admin_cp_proc":
				include_once('../lib/security.inc.php');
				
				$username = filter_input(INPUT_POST, 'admin_user', FILTER_SANITIZE_SPECIAL_CHARS);
				$password = filter_input(INPUT_POST, 'admin_pass', FILTER_SANITIZE_SPECIAL_CHARS);
				
				$sec = new security();
				$login = $sec->login($username, $password, $GLOBALS['login_seed'], 1);
				
				pageheader("Administrator Control Panel --> Re-login");
			#	dump($_POST['return']);
				switch($login)
				{
					case "locked":
						?><h2>This user is locked out. Contact this WiFiDB\'s admin, or go to the <a href="http://forum.techidiots.net/">forums</a> and bitch to Phil.<br></h2><?php
					break;
					
					case is_array($login):
						$to_go = $login[1];
						?><p align="center"><font color="red"><h2>Bad Username or Password!</h2></font></p>
						<p align="center"><font color="red"><h3>You have <?php echo $to_go;?> more attmpt(s) till you are locked out.</h3></font></p>
						<?php
						$return = str_replace("%5C", "%5C", $return);
						?>
						<form method="post" action="<?php echo $_SERVER['PHP_SELF'];?>?func=login_proc">
						<table align="center">
							<tr>
								<td colspan="2"><p align="center"><img src="<?php echo $GLOBALS['UPATH']; ?>/themes/wifidb/img/logo.png"></p></td>
							</tr>
							<tr>
								<td><b>Username</b></td>
								<td><input type="text" name="time_user"></td>
							</tr>
							<tr>
								<td><b>Password</b></td>
								<td><input type="password" name="time_pass"></td>
							</tr>
							<tr>
								<td colspan="2"><p align="center"><input type="hidden" name="return" value="<?php echo $return;?>"><input type="submit" value="Login"></p></td>
							</tr>
							<tr>
								<td colspan="2"><p align="center"><a class="links" href="<?php echo $_SERVER['PHP_SELF'];?>?func=create_user_form">Create a user account</a><br><a class="links" href="<?php echo $_SERVER['PHP_SELF'];?>?func=reset_user_pass">Forgot your password?</a></p></td>
							</tr>
						</table>
						</form>
						<?php
					break;
					
					case"u_fail":
						?><h2>Username does not exsist.</h2><?php
					break;
					
					case "u_u_r_fail":
						echo "failed to update User row";
					break;
					
					case "good":
						redirect_page($GLOBALS['UPATH'].'/cp/admin/', 2000, 'Login Successful!', 2);
					break;
					
					case "cookie_fail":
						echo "Set Cookie fail, check the bottom of the glass, or your browser.";
					break;
					
					default:
						?><h2>Unknown Return.<br>Contact this WiFiDB\'s admin, or go to the <a href="http://forum.techidiots.net/">forums</a> and bitch to Phil.<br></h2><?php
					break;
				}
				footer($_SERVER['SCRIPT_FILENAME']);
			break;
			
			default:
				pageheader("User Control Panel");
				?>
				<h1>The Built-in Administrator user doesn't have a User Control Panel, only the Admin Panel.</h1>
				<?php
				footer($_SERVER['SCRIPT_FILENAME']);
			break;
		}
	}
}else
{
	redirect_page('/'.$root.'/', 2000, 'Not Logged in!');
}
?>