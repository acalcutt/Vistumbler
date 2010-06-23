<?php
include('../lib/config.inc.php');
include('../lib/database.inc.php');
include('../lib/security.inc.php');
$sec = new security();

$date	= date('Y-m-d');

$db					= $GLOBALS['db'];
$conn				= $GLOBALS['conn'];
$wtable				= $GLOBALS['wtable'];
$user_logins_table 	= $GLOBALS['user_logins_table'];
$shared_waypoints	= $GLOBALS['share_cache'];
$users_t			= $GLOBALS['users_t'];

$user_cookie = explode(":", $_COOKIE['WiFiDB_login_yes']);
$username = $user_cookie[1];
$func = addslashes($_GET['func']);
switch($func)
{
	case "update":
		$type = addslashes(@$_GET['type']);
		$first = addslashes(@$_GET['first']);
		#echo @$user_search."| - |".@$email_search."| - |".$first."| - |";
		$usersearch = addslashes(@$_GET['usersearch']);
		$emailsearch = 0;
		if($usersearch == '1')
		{
			$user_search = addslashes($_POST['username']);	
			$emailsearch = 0;
			$usersearch = 1;
			$first = ' + ';
			
			if($_POST['email'] != '')
			{
				$emailsearch = 1;
				$usersearch = 0;
				$first = ' + ';
				$email_search = addslashes($_POST['email']);
			}
		}else
		{
			$emailsearch = 0;
			$usersearch = 0;
		}
		if($first == 'num')
		{$first = "#";}
		foreach(range('a', 'z') as $letter)
		{
		#	echo $letter."--";
			$sql_a = "SELECT `id` FROM `$db`.`$user_logins_table` WHERE `disabled` != '1' AND `username` LIKE '".$letter."%' AND `username` NOT LIKE 'admin%'";
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
		if($first == '')
		{
			$sql0 = "SELECT * FROM `$db`.`$user_logins_table` WHERE `disabled` != '1' AND `username` NOT LIKE 'admin%'";
		}elseif($first == '#')
		{
			$sql0 = "SELECT * FROM `$db`.`$user_logins_table` WHERE `disabled` != '1' AND `username` REGEXP '[0-9][[:>:]]' AND `username` NOT LIKE 'admin%'";
		}elseif($usersearch != 0)
		{
			$sql0 = "SELECT * FROM `$db`.`$user_logins_table` WHERE `disabled` != '1' AND `username` LIKE '$user_search' AND `username` NOT LIKE 'admin%'";
		}elseif($emailsearch != 0)
		{
			$sql0 = "SELECT * FROM `$db`.`$user_logins_table` WHERE `disabled` != '1' AND `email` LIKE '$email_search' AND `h_email` != '1' AND `username` NOT LIKE 'admin%'";
		}else
		{
			$sql0 = "SELECT * FROM `$db`.`$user_logins_table` WHERE `disabled` != '1' AND `username` LIKE '".$first."%' AND `username` NOT LIKE 'admin%'";
		}
	#	echo $sql0."<BR>";
		$result = mysql_query($sql0, $conn);
		$rows = mysql_num_rows($result);
		
		$uf_sql = "SELECT * FROM `$db`.`$user_login_table` WHERE `username` = '$username'";
		$uf_result = mysql_query($uf_sql, $conn);
		$uf_array = mysql_fetch_array($uf_result);
		if($type == 'friends')
		{
			$friends = $uf_array['friends'];
			$friends_array = explode(":", $friends);
		}else
		{
			$foes = $uf_array['foes'];
			$foes_array = explode(":", $foes);
		}
		?>
		<link rel="stylesheet" href="<?php echo $GLOBALS['UPATH']; ?>/themes/wifidb/styles.css">
		<table width="75%">
		<tr>
		<td style="background-color: #A9C6FA;width: 80%;vertical-align: top;" align="center">
			<h2>Find a member</h2>
			<h3>To add as a<?php if($type == "foes"){ echo " <font color='red'>Foe";}else{echo " <font color='green'>Friend";} ?></font></h3>
			<form method="post" action="?func=update&type=friends&usersearch=1">
				<table>
				<tr>
					<td><label for="username">Username:</label></td>
					<td><input type="text" name="username" id="username" value="<?php if(@$user_search == 0){}else{echo $user_search;} ?>" /></td>
				</tr>
				<tr>
					<td><label for="email">E-mail:</label></td>
					<td><input type="text" name="email" id="email" value="<?php echo @$email_search; ?>"/></td>
				</tr>
				<tr>
					<td colspan="2" align="center"><input type="submit" value="Find Users"></td>
				</tr>
				</table>
			</form>
			<form method="post" action="?func=update_<?php if($type == "foes"){ echo "foes"; }else{ echo "friends"; }?>">
				<CENTER><h2>Members</h2></CENTER>
				<table width="100%" align="center">
					<tr>
						<td align="center" colspan="6">
							<strong style="font-size: 0.95em;">
							<?php if($rows_all > 0 ) { ?><a class="links" href="?func=update&type=<?php if($type == "foes"){ echo "foes";}else{echo "friends";} ?>&first=">All</a><?php }else{ ?>All<?php } ?>&nbsp;
							<?php if($results["a"] > 0 ) { ?><a class="links" href="?func=update&type=<?php if($type == "foes"){ echo "foes";}else{echo "friends";} ?>&first=a">A</a><?php }else{ ?>A<?php } ?>&nbsp; 
							<?php if($results["b"] > 0 ) { ?><a class="links" href="?func=update&type=<?php if($type == "foes"){ echo "foes";}else{echo "friends";} ?>&first=b">B</a><?php }else{ ?>B<?php } ?>&nbsp; 
							<?php if($results["c"] > 0 ) { ?><a class="links" href="?func=update&type=<?php if($type == "foes"){ echo "foes";}else{echo "friends";} ?>&first=c">C</a><?php }else{ ?>C<?php } ?>&nbsp; 
							<?php if($results["d"] > 0 ) { ?><a class="links" href="?func=update&type=<?php if($type == "foes"){ echo "foes";}else{echo "friends";} ?>&first=d">D</a><?php }else{ ?>D<?php } ?>&nbsp; 
							<?php if($results["e"] > 0 ) { ?><a class="links" href="?func=update&type=<?php if($type == "foes"){ echo "foes";}else{echo "friends";} ?>&first=e">E</a><?php }else{ ?>E<?php } ?>&nbsp; 
							<?php if($results["f"] > 0 ) { ?><a class="links" href="?func=update&type=<?php if($type == "foes"){ echo "foes";}else{echo "friends";} ?>&first=f">F</a><?php }else{ ?>F<?php } ?>&nbsp; 
							<?php if($results["g"] > 0 ) { ?><a class="links" href="?func=update&type=<?php if($type == "foes"){ echo "foes";}else{echo "friends";} ?>&first=g">G</a><?php }else{ ?>G<?php } ?>&nbsp; 	
							<?php if($results["h"] > 0 ) { ?><a class="links" href="?func=update&type=<?php if($type == "foes"){ echo "foes";}else{echo "friends";} ?>&first=h">H</a><?php }else{ ?>H<?php } ?>&nbsp;
							<?php if($results["i"] > 0 ) { ?><a class="links" href="?func=update&type=<?php if($type == "foes"){ echo "foes";}else{echo "friends";} ?>&first=i">I</a><?php }else{ ?>I<?php } ?>&nbsp; 
							<?php if($results["j"] > 0 ) { ?><a class="links" href="?func=update&type=<?php if($type == "foes"){ echo "foes";}else{echo "friends";} ?>&first=j">J</a><?php }else{ ?>J<?php } ?>&nbsp; 
							<?php if($results["k"] > 0 ) { ?><a class="links" href="?func=update&type=<?php if($type == "foes"){ echo "foes";}else{echo "friends";} ?>&first=k">K</a><?php }else{ ?>K<?php } ?>&nbsp; 
							<?php if($results["l"] > 0 ) { ?><a class="links" href="?func=update&type=<?php if($type == "foes"){ echo "foes";}else{echo "friends";} ?>&first=l">L</a><?php }else{ ?>L<?php } ?>&nbsp; 
							<?php if($results["m"] > 0 ) { ?><a class="links" href="?func=update&type=<?php if($type == "foes"){ echo "foes";}else{echo "friends";} ?>&first=m">M</a><?php }else{ ?>M<?php } ?>&nbsp; 
							<?php if($results["n"] > 0 ) { ?><a class="links" href="?func=update&type=<?php if($type == "foes"){ echo "foes";}else{echo "friends";} ?>&first=n">N</a><?php }else{ ?>N<?php } ?>&nbsp; 
							<?php if($results["o"] > 0 ) { ?><a class="links" href="?func=update&type=<?php if($type == "foes"){ echo "foes";}else{echo "friends";} ?>&first=o">O</a><?php }else{ ?>O<?php } ?>&nbsp; 
							<?php if($results["p"] > 0 ) { ?><a class="links" href="?func=update&type=<?php if($type == "foes"){ echo "foes";}else{echo "friends";} ?>&first=p">P</a><?php }else{ ?>P<?php } ?>&nbsp; 
							<?php if($results["q"] > 0 ) { ?><a class="links" href="?func=update&type=<?php if($type == "foes"){ echo "foes";}else{echo "friends";} ?>&first=q">Q</a><?php }else{ ?>Q<?php } ?>&nbsp; 
							<?php if($results["r"] > 0 ) { ?><a class="links" href="?func=update&type=<?php if($type == "foes"){ echo "foes";}else{echo "friends";} ?>&first=r">R</a><?php }else{ ?>R<?php } ?>&nbsp; 
							<?php if($results["s"] > 0 ) { ?><a class="links" href="?func=update&type=<?php if($type == "foes"){ echo "foes";}else{echo "friends";} ?>&first=s">S</a><?php }else{ ?>S<?php } ?>&nbsp; 
							<?php if($results["t"] > 0 ) { ?><a class="links" href="?func=update&type=<?php if($type == "foes"){ echo "foes";}else{echo "friends";} ?>&first=t">T</a><?php }else{ ?>T<?php } ?>&nbsp; 
							<?php if($results["u"] > 0 ) { ?><a class="links" href="?func=update&type=<?php if($type == "foes"){ echo "foes";}else{echo "friends";} ?>&first=u">U</a><?php }else{ ?>U<?php } ?>&nbsp;						
							<?php if($results["v"] > 0 ) { ?><a class="links" href="?func=update&type=<?php if($type == "foes"){ echo "foes";}else{echo "friends";} ?>&first=v">V</a><?php }else{ ?>V<?php } ?>&nbsp; 
							<?php if($results["w"] > 0 ) { ?><a class="links" href="?func=update&type=<?php if($type == "foes"){ echo "foes";}else{echo "friends";} ?>&first=w">W</a><?php }else{ ?>W<?php } ?>&nbsp; 
							<?php if($results["x"] > 0 ) { ?><a class="links" href="?func=update&type=<?php if($type == "foes"){ echo "foes";}else{echo "friends";} ?>&first=x">X</a><?php }else{ ?>X<?php } ?>&nbsp; 
							<?php if($results["y"] > 0 ) { ?><a class="links" href="?func=update&type=<?php if($type == "foes"){ echo "foes";}else{echo "friends";} ?>&first=y">Y</a><?php }else{ ?>Y<?php } ?>&nbsp; 
							<?php if($results["z"] > 0 ) { ?><a class="links" href="?func=update&type=<?php if($type == "foes"){ echo "foes";}else{echo "friends";} ?>&first=z">Z</a><?php }else{ ?>Z<?php } ?>&nbsp; 
							<?php if($rows_num > 0 ) { ?><a class="links" href="?func=update&type=<?php if($type == "foes"){ echo "foes";}else{echo "friends";} ?>&first=num">#</a><?php }else{ ?>#<?php } ?>
							</strong>
						</td>
					</tr>
					<tr>
						<td>
					<?php
					################
						if($rows > 0)
						{
							while($newArray = mysql_fetch_array($result))
							{
								$user_number++;
								
								$user_name = $newArray['username'];
								if($username == $user_name){continue;}
								foreach($friends_array as $friends)
								{
									if($user_name == $friends)
									{Continue;}
								}
								$sql0 = "SELECT `friends` FROM `$db`.`$user_logins_table` WHERE `username` = '$username'";
								$result = mysql_query($sql0, $conn);
								while($friends_array = mysql_fetch_array($result))
								{
									$friends_array['friends'];
								}
								?>
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
											</select><br>
											<input type="button" name="remove_friend_submit" value="Remove Selected User(s)" onClick="document.remove_from_friends_group.action='?func=add_freinds'; document.remove_from_friends_group.submit();" />
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
											</select><br>
											<input type="button" name="add_friend_submit" value="Add Selected User(s)" onClick="document.add_to_friends_group.action='?func=del_friends'; document.add_to_friends_group.submit();" />
										</form>
										</td>
									</tr>
								</table>
								<?php
							}
						}else
						{
							
						}
						?>
							</td>
						</tr>
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
	
	case "add_friends":
		?>
		<link rel="stylesheet" href="<?php echo $GLOBALS['UPATH']; ?>/themes/wifidb/styles.css">
		<table width="75%">
		<tr>
		<td style="background-color: #A9C6FA;width: 80%;vertical-align: top;" align="center">
			
			<?php
			$_POST['users'];
			
			
			$sql = "SELECT * FROM `$db`.`$user_logins_table` WHERE `username` = '$username'";
			$result = mysql_query($sql, $conn);
			$array = mysql_fetch_array($result);
			
			$db_f = explode(":", $array['friends']);
			foreach($db_f as $db_freind)
			{
				#foreach($
			}
			$friends = ":".$users;
			
			$update = "UPDATE `$db`.`$user_logins_table` SET `friends` = '$friends' WHERE `username` = '$username'";
			echo $update."<BR>";
			if(mysql_query($update, $conn))
			{
				?>
				<h2>Added as Friends</h2>
				<?php
				foreach($_POST['users'] as $friend)
				{echo $friends."<BR>";}
			}else
			{
				?><h2>Failed, Mysql Error:</h2> <font color="red"><?php echo mysql_error($conn); ?> </font> <?php
			}
			?>
		</td>
		</tr>
		</table>
		<?php
	break;
}
?>