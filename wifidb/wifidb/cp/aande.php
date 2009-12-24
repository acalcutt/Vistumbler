<?php
include('../lib/config.inc.php');
include('../lib/database.inc.php');
include('../lib/security.inc.php');
$sec = new security();

pageheader($title, $output="");
$date	= date('Y-m-d');

$db					= $GLOBALS['db'];
$conn				= $GLOBALS['conn'];
$wtable				= $GLOBALS['wtable'];
$user_logins_table 	= $GLOBALS['user_logins_table'];
$shared_waypoints	= $GLOBALS['share_cache'];
$users_t			= $GLOBALS['users_t'];

$root		= $GLOBALS['root'];
$hosturl	= $GLOBALS['hosturl'];

$type = addslashes($_GET['type']);
$func = addslashes($_GET['func']);

$priv_name = $GLOBALS['priv_name'];

switch($func)
{
	case "update":
		$first = addslashes($_GET['first']);
		foreach(range('a', 'z') as $letter)
		{
		#	echo $letter."--";
			$sql_a = "SELECT `id` FROM `$db`.`$user_logins_table` WHERE `disabled` != '1' AND `username` LIKE '".$letter."%'";
			$return_a = mysql_query($sql_a, $conn);
			$rows_a = mysql_num_rows($return_a);
			$results[$letter] = $rows_a;
		}

		$sql_all = "SELECT `id` FROM `$db`.`$user_logins_table` WHERE `disabled` != '1'";
		$ret_all = mysql_query($sql_all, $conn);
		$rows_all =  mysql_num_rows($ret_all);

		$sql_num = "SELECT `id` FROM `$db`.`$user_logins_table` WHERE `disabled` != '1' AND `username` REGEXP '[0-9][[:>:]]'";
		$ret_num = mysql_query($sql_num, $conn);
		$rows_num =  mysql_num_rows($ret_num);

		$tracker = 0;
		$user_number = 0;
		$priv_name = $GLOBALS['priv_name'];
		if($first == '')
		{
			$sql0 = "SELECT `id`,`username`,`website`,`member`,`last_login`,`join_date` FROM `$db`.`$user_logins_table` WHERE `disabled` != '1'";
		}elseif($first == '#')
		{
			$sql0 = "SELECT `id`,`username`,`website`,`member`,`last_login`,`join_date` FROM `$db`.`$user_logins_table` WHERE `disabled` != '1' AND `username` REGEXP '[0-9][[:>:]]'";
		}elseif($user_search != 0)
		{
			$sql0 = "SELECT `id`,`username`,`website`,`member`,`last_login`,`join_date` FROM `$db`.`$user_logins_table` WHERE `disabled` != '1' AND `username` LIKE '$user_search'";
		}elseif($email_search != 0)
		{
			$sql0 = "SELECT `id`,`username`,`website`,`member`,`last_login`,`join_date` FROM `$db`.`$user_logins_table` WHERE `disabled` != '1' AND `email` LIKE '$user_search' AND `h_email` != '1'";
		}else
		{
			$sql0 = "SELECT `id`,`username`,`website`,`member`,`last_login`,`join_date` FROM `$db`.`$user_logins_table` WHERE `disabled` != '1' AND `username` LIKE '".$first."%'";
		}

		#	echo $sql0."<BR>";
		$result = mysql_query($sql0, $conn);
		$rows = mysql_num_rows($result);
		?>
		<link rel="stylesheet" href="<?php if($root != ''){echo $hosturl.$root;}?>/themes/wifidb/styles.css">
		<table width="75%">
		<tr>
		<td style="background-color: #A9C6FA;width: 80%;vertical-align: top;" align="center">
				<h2>Find a member</h2>
				<h3>To add as a<?php if($type == "foes"){ echo " <font color='red'>Foe";}else{echo " <font color='green'>Friend";} ?></font></h3>
				<form method="post" action="./?func=user_search">
					<table>
					<tr>
						<td><label for="username">Username:</label></td>
						<td><input type="text" name="username" id="username" value="<?php echo $user_search; ?>" /></td>
					</tr>
					<tr>
						<td><label for="email">E-mail:</label></td>
						<td><input type="text" name="email" id="email" value="<?php echo $email_search; ?>"/></td>
					</tr>
					<tr>
						<td colspan="2" align="center"><input type="submit" value="Find Users"></td>
					</tr>
					</table>
				</form>
				<form method="post" action="./?func=update_<?php if($type == "foes"){ echo "foes"; }else{ echo "friends"; }?>">
					<CENTER><h2>Members</h2></CENTER>
					<table width="100%" align="center">
						<tr>
							<td align="center" colspan="6">
								<strong style="font-size: 0.95em;">
								<?php if($rows_all > 0 ) { ?><a class="links" href="?func=update&type=<?php if($type == "foes"){ echo "foes";}else{echo "friends";} ?>first=">All</a><?php }else{ ?>All<?php } ?>&nbsp;
								<?php if($results["a"] > 0 ) { ?><a class="links" href="?func=update&type=<?php if($type == "foes"){ echo "foes";}else{echo "friends";} ?>first=a">A</a><?php }else{ ?>A<?php } ?>&nbsp; 
								<?php if($results["b"] > 0 ) { ?><a class="links" href="?func=update&type=<?php if($type == "foes"){ echo "foes";}else{echo "friends";} ?>first=b">B</a><?php }else{ ?>B<?php } ?>&nbsp; 
								<?php if($results["c"] > 0 ) { ?><a class="links" href="?func=update&type=<?php if($type == "foes"){ echo "foes";}else{echo "friends";} ?>first=c">C</a><?php }else{ ?>C<?php } ?>&nbsp; 
								<?php if($results["d"] > 0 ) { ?><a class="links" href="?func=update&type=<?php if($type == "foes"){ echo "foes";}else{echo "friends";} ?>first=d">D</a><?php }else{ ?>D<?php } ?>&nbsp; 
								<?php if($results["e"] > 0 ) { ?><a class="links" href="?func=update&type=<?php if($type == "foes"){ echo "foes";}else{echo "friends";} ?>first=e">E</a><?php }else{ ?>E<?php } ?>&nbsp; 
								<?php if($results["f"] > 0 ) { ?><a class="links" href="?func=update&type=<?php if($type == "foes"){ echo "foes";}else{echo "friends";} ?>first=f">F</a><?php }else{ ?>F<?php } ?>&nbsp; 
								<?php if($results["g"] > 0 ) { ?><a class="links" href="?func=update&type=<?php if($type == "foes"){ echo "foes";}else{echo "friends";} ?>first=g">G</a><?php }else{ ?>G<?php } ?>&nbsp; 	
								<?php if($results["h"] > 0 ) { ?><a class="links" href="?func=update&type=<?php if($type == "foes"){ echo "foes";}else{echo "friends";} ?>first=h">H</a><?php }else{ ?>H<?php } ?>&nbsp;
								<?php if($results["i"] > 0 ) { ?><a class="links" href="?func=update&type=<?php if($type == "foes"){ echo "foes";}else{echo "friends";} ?>first=i">I</a><?php }else{ ?>I<?php } ?>&nbsp; 
								<?php if($results["j"] > 0 ) { ?><a class="links" href="?func=update&type=<?php if($type == "foes"){ echo "foes";}else{echo "friends";} ?>first=j">J</a><?php }else{ ?>J<?php } ?>&nbsp; 
								<?php if($results["k"] > 0 ) { ?><a class="links" href="?func=update&type=<?php if($type == "foes"){ echo "foes";}else{echo "friends";} ?>first=k">K</a><?php }else{ ?>K<?php } ?>&nbsp; 
								<?php if($results["l"] > 0 ) { ?><a class="links" href="?func=update&type=<?php if($type == "foes"){ echo "foes";}else{echo "friends";} ?>first=l">L</a><?php }else{ ?>L<?php } ?>&nbsp; 
								<?php if($results["m"] > 0 ) { ?><a class="links" href="?func=update&type=<?php if($type == "foes"){ echo "foes";}else{echo "friends";} ?>first=m">M</a><?php }else{ ?>M<?php } ?>&nbsp; 
								<?php if($results["n"] > 0 ) { ?><a class="links" href="?func=update&type=<?php if($type == "foes"){ echo "foes";}else{echo "friends";} ?>first=n">N</a><?php }else{ ?>N<?php } ?>&nbsp; 
								<?php if($results["o"] > 0 ) { ?><a class="links" href="?func=update&type=<?php if($type == "foes"){ echo "foes";}else{echo "friends";} ?>first=o">O</a><?php }else{ ?>O<?php } ?>&nbsp; 
								<?php if($results["p"] > 0 ) { ?><a class="links" href="?func=update&type=<?php if($type == "foes"){ echo "foes";}else{echo "friends";} ?>first=p">P</a><?php }else{ ?>P<?php } ?>&nbsp; 
								<?php if($results["q"] > 0 ) { ?><a class="links" href="?func=update&type=<?php if($type == "foes"){ echo "foes";}else{echo "friends";} ?>first=q">Q</a><?php }else{ ?>Q<?php } ?>&nbsp; 
								<?php if($results["r"] > 0 ) { ?><a class="links" href="?func=update&type=<?php if($type == "foes"){ echo "foes";}else{echo "friends";} ?>first=r">R</a><?php }else{ ?>R<?php } ?>&nbsp; 
								<?php if($results["s"] > 0 ) { ?><a class="links" href="?func=update&type=<?php if($type == "foes"){ echo "foes";}else{echo "friends";} ?>first=s">S</a><?php }else{ ?>S<?php } ?>&nbsp; 
								<?php if($results["t"] > 0 ) { ?><a class="links" href="?func=update&type=<?php if($type == "foes"){ echo "foes";}else{echo "friends";} ?>first=t">T</a><?php }else{ ?>T<?php } ?>&nbsp; 
								<?php if($results["u"] > 0 ) { ?><a class="links" href="?func=update&type=<?php if($type == "foes"){ echo "foes";}else{echo "friends";} ?>first=u">U</a><?php }else{ ?>U<?php } ?>&nbsp;						
								<?php if($results["v"] > 0 ) { ?><a class="links" href="?func=update&type=<?php if($type == "foes"){ echo "foes";}else{echo "friends";} ?>first=v">V</a><?php }else{ ?>V<?php } ?>&nbsp; 
								<?php if($results["w"] > 0 ) { ?><a class="links" href="?func=update&type=<?php if($type == "foes"){ echo "foes";}else{echo "friends";} ?>first=w">W</a><?php }else{ ?>W<?php } ?>&nbsp; 
								<?php if($results["x"] > 0 ) { ?><a class="links" href="?func=update&type=<?php if($type == "foes"){ echo "foes";}else{echo "friends";} ?>first=x">X</a><?php }else{ ?>X<?php } ?>&nbsp; 
								<?php if($results["y"] > 0 ) { ?><a class="links" href="?func=update&type=<?php if($type == "foes"){ echo "foes";}else{echo "friends";} ?>first=y">Y</a><?php }else{ ?>Y<?php } ?>&nbsp; 
								<?php if($results["z"] > 0 ) { ?><a class="links" href="?func=update&type=<?php if($type == "foes"){ echo "foes";}else{echo "friends";} ?>first=z">Z</a><?php }else{ ?>Z<?php } ?>&nbsp; 
								<?php if($rows_num > 0 ) { ?><a class="links" href="?func=update&type=<?php if($type == "foes"){ echo "foes";}else{echo "friends";} ?>first=num">#</a><?php }else{ ?>#<?php } ?>
								</strong>
							</td>
						</tr>
						<tr>
							<th class="style4"><a class="links" href="">Username</a></th>
							<th class="style4"><a class="links" href="">Level</a></th>
							<th class="style4"><a class="links" href="">APs / GCs</a></th>
							<th class="style4"><a class="links" href="">Website</a></th>
							<th class="style4" width="20%"><a class="links" href="">Joined</a></th>
							<th class="style4" width="20%"><a class="links" href="">Last Lopin</a></th>
						</tr>
						
						<?php
						################
						if($rows > 0)
						{
							while($newArray = mysql_fetch_array($result))
							{
								$user_number++;
								
								$user_name = $newArray['username'];
								$website = $newArray['website'];
								$last_login = $newArray['last_login'];
								$join_date = $newArray['join_date'];
								$userprivname = $sec->define_priv_name($newArray['member']);
						#		echo $userprivname;
								$sql1 = "SELECT `id` FROM `$db`.`$shared_waypoints` WHERE `shared_by` = '$user_name'";
						#		echo $sql1."<BR>";
								$result1 = mysql_query($sql1, $conn) or die(mysql_error($conn));
								$shared_gcs = mysql_num_rows($result1);
								
								$sql1 = "SELECT `points` FROM `$db`.`$users_t` WHERE `username` = '$user_name'";
						#		echo $sql1."<BR>";
								$result1 = mysql_query($sql1, $conn);
								$total_aps = 0;
								while($aps_array = mysql_fetch_array($result1))
								{
									$pnts_exp = explode("-", $aps_array['points']);
									$aps = count($pnts_exp);
									$total_aps += $aps;
								}
								if($tracker == 0)
								{
									$style_class = "light";
									$tracker = 1;
								}else
								{
									$style_class = "dark";
									$tracker = 0;
								}
								if($website!='')
								{
									$website_exp = explode(".", $website);
									$web_count = count($website_exp)-1;
									$website_name = $website_exp[$web_count-1].'.'.$website_exp[$web_count];
								}else
								{
									$website_name = '';
								}
								?>
								<tr class="<?php echo $style_class;?>">
									<td><input type="checkbox" name="user<?php echo $user_number;?>" value="<?php echo $user_name;?>" />&nbsp;&nbsp;<a href="/<?php echo $root;?>/opt/userstats.php?user=<?php echo $user_name;?>" class="links"><?php echo $user_name;?></a></td>
									<td align="center"><?php echo $userprivname;?></td>
									<td align="center"><?php echo $total_aps." / ".$shared_gcs;?></td>
									<td align="center"><a class="links" href="<?php echo $website;?>" target="_blank"><?php echo $website_name;?></a></td>
									<td align="center"><?php echo substr_replace(date("r", strtotime($join_date)),'', -6);?></td>
									<td align="center"><?php echo substr_replace(date("r", strtotime($last_login)),'', -6);?></td>
								</tr>
								<?php
							}
						}else
						{
							?>
							<tr class="light"><td align="center" colspan="6"><b>There are no users for that Character</b></td></tr>
							<?php
						}
						?>
						<tr>
							<td align="center" colspan="6">
							<input name="max_num_returns" type="hidden" value="<?php echo $user_number; ?>" >
							<input type="submit" value="Add Users">
							</td>
						</tr>
						<tr>
							<td align="center">
							<CENTER>
							<!--pages-->
							
							</CENTER>
							</td>
						</tr>
					</table>
				</form>
			</tr>
		</table>
	<?php
	break;
	
	case "update_friends":
		$max_num_users = $_POST['max_num_returns'];
		
	break;
}