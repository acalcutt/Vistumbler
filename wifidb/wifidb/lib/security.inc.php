<?php
global $sec_ver;
$sec_ver = array(
					"login_check"		=>	"1.0",
					"login"				=>	"1.0",
					"define_priv_name"	=>	"1.0",
					"create_user"		=>	"1.0",
					"remove_user"		=>	"1.0",
					"redirect_page"		=>	"1.0",
					"ff_exists"			=>	"1.0"
				);

function redirect_page($return = "/wifidb/", $delay = 0, $msg = "no Message", $new_window = 0)
{
	?>
		<script type="text/javascript">
			function reload()
			{
				<?php
				if($new_window == 1)
				{ ?>
					window.open('<?php echo $return;?>'); <?
				}
				elseif($new_window == 2)
				{ ?>
					window.open('<?php echo $return;?>');
					location.href = '/<?php echo $GLOBALS["root"];?>/'; <?php
				}
				elseif($new_window == 0)
				{ ?>
					location.href = '<?php echo $return;?>'; <?php
				}
				?>
			}
			</script>
			<body onload="setTimeout('reload()', <?php echo $delay;?>)"><?php echo $msg;?></body>
	<?php
}

function ff_exists($string, $array)
{
	foreach($array as $key=>$val)
	{
		if($string === $val){return 1;}
	}
	return 0;
}



class security
{
	#######################################
	function login_check($admin = 0)
	{
		if($admin == 1)
		{
			$cookie_name = 'WiFiDB_admin_login_yes';
			$cookie_seed = "@LOGGEDIN";
		}else
		{
			$cookie_name = 'WiFiDB_login_yes';
			$cookie_seed = "@LOGGEDIN!";
		}
		global $username, $privs_a;
		$user_logins_table = $GLOBALS['user_logins_table'];
		$db = $GLOBALS['db'];
		$conn = $GLOBALS['conn'];
		
		if(!@$_COOKIE[$cookie_name])
		{
			#	die('You are trying to access a page that needs a cookie, without having a cookie, you cant do that... 
			#	<a href="'.$_SERVER['PHP_SELF'].'">go get a cookie</a>. make it a double stuff.<br>');
			return array(0, "No Cookie");
			break;
		}
		list($cookie_pass_seed, $username) = explode(':', $_COOKIE[$cookie_name]);
		if($username != '')
		{
		#	echo $username;
			$sql0 = "SELECT * FROM `$db`.`$user_logins_table` WHERE `username` = '$username' LIMIT 1";
			$result = mysql_query($sql0, $conn);
			$newArray = mysql_fetch_array($result);
			$db_pass = $newArray['password'];
			$username_db = $newArray['username'];
			
			if(md5($cookie_seed.$db_pass) === $cookie_pass_seed)
			{
				$privs_a = security::check_privs();
			#	var_dump($privs_a);
				return $username_db;
			}else
			{
				return array(0, "Bad Cookie Password");
			}
		}else
		{
			return "No Cookie";
		}
	}

	#######################################
	function define_priv_name($member)
	{
		$groups = explode("," , $member);
		foreach($groups as $group)
		{
			if($group == 'admins')
			{
				return "Administrator";
			}elseif($group == 'devs')
			{
				return "Developer";
			}elseif($group == 'mods')
			{
				return "Moderator";
			}elseif($group == 'users')
			{
				return "User";
			}
		}
		
	}
	
	
	#######################################
	function check_privs($admin = 0)
	{
		if($admin == 1)
		{
			$cookie_name = 'WiFiDB_admin_login_yes';
			$cookie_seed = "@LOGGEDIN";
		}else
		{
			$cookie_name = 'WiFiDB_login_yes';
			$cookie_seed = "@LOGGEDIN!";
		}
		global $privs_a;
		$user_logins_table = $GLOBALS['user_logins_table'];
		$db = $GLOBALS['db'];
		$conn = $GLOBALS['conn'];
		
		if(!@$_COOKIE['WiFiDB_login_yes'])
		{
			#	die('You are trying to access a page that needs a cookie, without having a cookie, you cant do that... 
			#	<a href="'.$_SERVER['PHP_SELF'].'">go get a cookie</a>. make it a double stuff.<br>');
			return 0;
			break;
		}
		list($cookie_pass_seed, $username) = explode(':', $_COOKIE['WiFiDB_login_yes']);
	#	echo $username;
		$sql0 = "SELECT * FROM `$db`.`$user_logins_table` WHERE `username` = '$username' LIMIT 1";
		$result = mysql_query($sql0, $conn);
		$newArray = mysql_fetch_array($result);
		$member = $newArray['member'];
		$groups = explode(",", $member);
		$privs = 0;
	#	echo $privs;
		foreach($groups as $group)
		{
	#		echo $group."<BR>";
			if($group == 'admins')
			{
				$privs += 1000;
			}elseif($group == 'devs')
			{
				$privs += 100;
			}elseif($group == 'mods')
			{
				$privs += 10;
			}elseif($group == 'users')
			{
				$privs += 1;
			}
		}
		if($privs >= 1000){$priv_name = "Administrator";}
		elseif($privs >= 100){$priv_name = "Developer";}
		elseif($privs >= 10){$priv_name = "Moderator";}
		else{$priv_name = "User";}

	#	echo $privs;
		return array($privs, $priv_name);
	#
	}

	#######################################

	function login($username = '', $password = '', $seed = 'MNKEY!', $admin = 0)
	{
		if($admin == 1)
		{
			$cookie_name = 'WiFiDB_admin_login_yes';
			$cookie_seed = "@LOGGEDIN";
		}else
		{
			$cookie_name = 'WiFiDB_login_yes';
			$cookie_seed = "@LOGGEDIN!";
		}
		$user_logins_table = $GLOBALS['user_logins_table'];
		$db = $GLOBALS['db'];
		$conn = $GLOBALS['conn'];
		
		$date = date("Y-m-d G:i:s");
		
		$pass_seed = md5($password.$seed);
		
		$sql0 = "SELECT * FROM `$db`.`$user_logins_table` WHERE `username` = '$username' LIMIT 1";
	#	echo $sql0;
		$result = mysql_query($sql0, $conn);
		$newArray = mysql_fetch_array($result);
		if($newArray['login_fails'] == $GLOBALS['config_fails'] or $newArray['locked'] == 1)
		{
			return 'locked';
		}
		$id = $newArray['id'];
		$db_pass = $newArray['password'];
		$fails = $newArray['login_fails'];
		$username_db = $newArray['username'];

	#	echo $username."<BR>".$username_db."<BR>".$pass_seed."<BR>".$db_pass."<BR>";
		
		if($db_pass === $pass_seed)
		{
	#		echo "GOOD CHECK!<BR>";
			if(setcookie($cookie_name, md5($cookie_seed.$pass_seed).":".$username, (time()+(86400*7))))
			{
				$sql1 = "UPDATE `$db`.`$user_logins_table` SET `last_login` = '$date' WHERE `$user_logins_table`.`id` = '$id' LIMIT 1";
				if(mysql_query($sql1, $conn))
				{
					return "good";
				}else
				{
					return "u_u_r_fail";
				}
			}else
			{
				return "cookie_fail";
			}
		}else
		{
			if($username_db != '')
			{
				$fails++;
				$to_go = $GLOBALS['config_fails'] - $fails;
		#		echo $fails.' - '.$GLOBALS['config_fails'];
				if($fails >= $GLOBALS['config_fails'])
				{
					$sql1 = "UPDATE `$db`.`$user_logins_table` SET `locked` = '1' WHERE `$user_logins_table`.`id` = '$id' LIMIT 1";
					mysql_query($sql1, $conn);
					return "locked";
				}else
				{
					$sql1 = "UPDATE `$db`.`$user_logins_table` SET `login_fails` = '$fails' WHERE `$user_logins_table`.`id` = '$id' LIMIT 1";
					mysql_query($sql1, $conn);
					return "p_fail";
				}
			}else
			{
				return "u_fail";
			}
			?>
			<p align="center"><font color="red"><h2>Bad Username or Password!</h2></font></p>
			<p align="center"><font color="red"><h3>You have <?php echo $to_go;?> more attmpt(s) till you are locked out.</h3></font></p>
			<form method="post" action="<?php echo $_SERVER['PHP_SELF'];?>?func=login_proc">
			<table align="center">
				<tr>
					<td colspan="2"><p align="center"><img src="themes/wifidb/img/logo.png"></p></td>
				</tr>
				<tr>
					<td>Username</td>
					<td><input type="text" name="time_user"></td>
				</tr>
				<tr>
					<td>Password</td>
					<td><input type="password" name="time_pass"></td>
				</tr>
				<tr>
					<td colspan="2"><p align="center"><input type="submit" value="Login"></p></td>
				</tr>
				<tr>
					<td colspan="2"><p align="center"><a href="<?php echo $_SERVER['PHP_SELF'];?>?func=create_user_form">Create a user account</a><br><a href="<?php echo $_SERVER['PHP_SELF'];?>?func=reset_user_pass">Forgot your password?</a></p></td>
				</tr>
			</table>
			</form>
			<?php
		}
	}



	#######################################
	function create_user($username="", $password="", $email="local@localhost.local", $seed="MONK!")
	{
		if($username == '' or $password == ''){die("Username and/or password cannot be blank.");}
		$user_logins_table = $GLOBALS['user_logins_table'];
		$db = $GLOBALS['db'];
		$conn = $GLOBALS['conn'];
		$date = date("Y-m-d G:i:s");
		$uid_b = md5($date.$username.$seed);
		$uid_exp = str_split($uid_b, 6);
		$uid = implode("-", $uid_exp);
		#echo $uid."<BR>";
		$user_cache = $username.'_waypoints';
		$pass_seed = md5($password.$seed);
		$insert_user = "INSERT INTO `$db`.`$user_logins_table` (`id` ,`username` ,`password`, `member` ,`last_login` ,`email`, `uid`, `join_date` )VALUES ( NULL , '$username', '$pass_seed', ',,,users', '$date', '$email', '$uid', '$date')";
		if(mysql_query($insert_user, $conn))
		{
			$create_user_cache = "CREATE TABLE `$db`.`$user_cache` 
							(
							  `id` int(255) NOT NULL auto_increment,
							  `author` varchar(255) NOT NULL,
							  `name` varchar(255) NOT NULL,
							  `shared_by` varchar(255) NOT NULL,
							  `gcid` varchar(255) NOT NULL,
							  `notes` text NOT NULL,
							  `cat` set('home','family','medical','police','fire','fastfood','finefood','gas','geocache','think of more...') NOT NULL,
							  `type` varchar(255) NOT NULL,
							  `diff` double(2,2) NOT NULL,
							  `terain` double(2,2) NOT NULL,
							  `lat` varchar(255) NOT NULL,
							  `long` varchar(255) NOT NULL,
							  `link` varchar(255) NOT NULL,
							  `share` tinyint(1) NOT NULL,
							  `share_id` int(255) NOT NULL,
							  `c_date` datetime NOT NULL,
							  `u_date` datetime NOT NULL,
							  UNIQUE KEY `id` (`id`),
							  UNIQUE `gcid` (`gcid`)
							) ENGINE=INNODB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=0";
			if(mysql_query($create_user_cache, $conn))
			{
				return 1;
			}else
			{
				return array("create_wpt", mysql_error($conn));
			}
		}
		else
		{
			return array("dup_u", mysql_error($conn));
		}
	}
}
?>