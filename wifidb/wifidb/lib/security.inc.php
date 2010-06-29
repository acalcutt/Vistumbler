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


function ff_exists($string, $array)
{
	foreach($array as $key=>$val)
	{
		if($string === $val){return 1;}
	}
	return 0;
}


function checkEmail($email)
{
	// First, we check that there's one @ symbol, and that the lengths are right 
	if (!ereg("^[^@]{1,64}@[^@]{1,255}$", $email)) 
	{
		// Email invalid because wrong number of characters in one section, or wrong number of @ symbols. 
		return false; 
	}
	// Split it into sections to make life easier 
	$email_array = explode("@", $email); 
	$local_array = explode(".", $email_array[0]); 
	for ($i = 0; $i < sizeof($local_array); $i++) 
	{
		if (!ereg("^(([A-Za-z0-9!#$%&'*+/=?^_`{|}~-][A-Za-z0-9!#$%&'*+/=?^_`{|}~\.-]{0,63})|(\"[^(\\|\")]{0,62}\"))$", $local_array[$i])) 
		{
			return false; 
		} 
	}
	if (!ereg("^\[?[0-9\.]+\]?$", $email_array[1])) 
	{
		// Check if domain is IP. If not, it should be valid domain name 
		$domain_array = explode(".", $email_array[1]);
		if (sizeof($domain_array) < 2) 
		{
			return false; // Not enough parts to domain 
		} 
		for ($i = 0; $i < sizeof($domain_array); $i++) 
		{ 
			if (!ereg("^(([A-Za-z0-9][A-Za-z0-9-]{0,61}[A-Za-z0-9])|([A-Za-z0-9]+))$", $domain_array[$i]))
			{ 
				return false; 
			} 
		} 
	} 
	return true; 
}


class security
{
	#######################################
	function gen_keys($len = 12)
	{
		// http://snippets.dzone.com/posts/show/3123
		$base			=	'ABCDEFGHKLMNOPQRSTWXYZabcdefghjkmnpqrstwxyz123456789';
		$max			=	strlen($base)-1;
		$activatecode	=	'';
		mt_srand((double)microtime()*1000000);
		while (strlen($activatecode) < $len+1)
		{$activatecode.=$base{mt_rand(0,$max)};}
		return $activatecode;
	}

	#######################################
	function login_check($admin = 0)
	{
		global $global_loggedin;
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
		if(@$GLOBALS['user_logins_table'])
		{
			$user_logins_table = $GLOBALS['user_logins_table'];
		}else
		{
			return array(0, "upgrade");
		}
		$db = $GLOBALS['db'];
		$conn = $GLOBALS['conn'];
	#	echo "<br>".$cookie_name.":  ".$_COOKIE[$cookie_name]."<br>";
		if($admin and !@isset($_COOKIE[$cookie_name]))
		{
		#	die('You are trying to access a page that needs a cookie, without having a cookie, you cant do that... 
		#	<a href="'.$GLOBALS["hosturl"].$GLOBALS["root"].'/cp/?func=admin_cp">go get a cookie</a>. make it a double stuff.<br>');
			return "No Cookie";
		#	break;
		}
		if(@isset($_COOKIE[$cookie_name]))
		{
			list($cookie_pass_seed, $username) = explode(':', $_COOKIE[$cookie_name]);
			if($username != '')
			{
			#	echo $username;
				$sql0 = "SELECT * FROM `$db`.`$user_logins_table` WHERE `username` = '$username' LIMIT 1";
				$result = mysql_query($sql0, $conn);
				$newArray = mysql_fetch_array($result);
				$db_pass = $newArray['password'];
				$username_db = $newArray['username'];
				
				if(md5($db_pass.$cookie_seed) === $cookie_pass_seed)
				{
					$privs_a = security::check_privs();
				#	var_dump($privs_a);
					$global_loggedin = 0;
					return $username_db;
				}else
				{
					return array(0, "Bad Cookie Password");
				}
			}else
			{
				return "No Cookie";
			}
		}else
		{
			$global_loggedin = 0;
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
		global $privs, $priv_name;
		include_once('config.inc.php');
		$conn = $GLOBALS['conn'];
		if($admin == 1)
		{
			$cookie_seed = "@LOGGEDIN";
			list($cookie_pass_seed, $username) = explode(':', $_COOKIE['WiFiDB_admin_login_yes']);
		}else
		{
			$cookie_seed = "@LOGGEDIN!";
			list($cookie_pass_seed, $username) = explode(':', $_COOKIE['WiFiDB_login_yes']);
		}
		$user_logins_table = $GLOBALS['user_logins_table'];
	#	echo $username;
		$sql0 = "SELECT * FROM `wifi`.`$user_logins_table` WHERE `username` = '$username' LIMIT 1";
	#	echo $sql0;
		$result = mysql_query($sql0, $conn);
		$newArray = mysql_fetch_array($result);
		$table_pass = md5($newArray['password'].$cookie_seed);
		if($table_pass == $cookie_pass_seed)
		{
			$groups = array(3=>$newArray['admins'],2=>$newArray['devs'],1=>$newArray['mods'],0=>$newArray['users']);
			$privs = implode("",$groups);
			$privs+0;
	#		echo $privs;
			if($privs >= 1000){$priv_name = "Administrator";}
			elseif($privs >= 100){$priv_name = "Developer";}
			elseif($privs >= 10){$priv_name = "Moderator";}
			else{$priv_name = "User";}
			
			return array($privs, $priv_name);
		}
		else
		{
			die("Wrong pass or no Cookie, go get one.");
		}
	}

	#######################################

	function login($username = '', $password = '', $seed = '', $admin = 0, $no_save_login = 0)
	{
		if($seed ==''){$seed == $GLOBALS['login_seed'];}
		if($seed == ''){$seed = "PIECAVE!";}
		
		if($admin == 1)
		{
			$cookie_name = 'WiFiDB_admin_login_yes';
			$cookie_seed = "@LOGGEDIN";
			if($GLOBALS["root"] != '')
			{$path		 = '/'.$GLOBALS["root"].'/cp/admin/';}
			else{$path		 = '/cp/admin/';}
			$cookie_timeout = time()-3600;
		}else
		{
			$cookie_name = 'WiFiDB_login_yes';
			$cookie_seed = "@LOGGEDIN!";
			if($GLOBALS["root"] != '')
			{$path		 = '/'.$GLOBALS["root"].'/';}
			else{$path		 = '/';}
			
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
		if($newArray['validated'] == 1)
		{
			return 'validate';
		}
		$id = $newArray['id'];
		$db_pass = $newArray['password'];
		$fails = $newArray['login_fails'];
		$username_db = $newArray['username'];

		if($db_pass === $pass_seed)
		{
			if($no_save_login == 1)
			{
				$cookie_timeout = time()-3600;
			}else
			{
				$cookie_timeout = time()+$GLOBALS['timeout'];
			}
			
			if(setcookie($cookie_name, md5($pass_seed.$cookie_seed).":".$username, $cookie_timeout, $path))
			{
				$sql0 = "SELECT `last_active` FROM `$db`.`$user_logins_table` WHERE `id` = '$id' LIMIT 1";
				$array = mysql_fetch_array(mysql_query($sql0, $conn));
				$last_active = $array['last_active'];
				$sql1 = "UPDATE `$db`.`$user_logins_table` SET `login_fails` = '0', `last_active` = '$last_active', `last_login` = '$date' WHERE `$user_logins_table`.`id` = '$id' LIMIT 1";
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
					return array("p_fail", $to_go);
				}
			}else
			{
				return "u_fail";
			}
		}
	}

	function check_user_reserved($username = '')
	{
		if($username == ''){return -1;}
		include('config.inc.php');
		$reserved = explode(":", $GLOBALS['reserved_users']);
		foreach($reserved as $resv)
		{
			if($username == $resv)
			{return 1;}
		}
		return 0;
	}
	
	
	function user_create_form($username = '', $email = '')
	{
		?>
		<form method="post" action="<?php echo $_SERVER['PHP_SELF'];?>?func=create_user_proc">
			<table align="center">
				<tr>
					<td colspan="2"><p align="center"><img src="themes/wifidb/img/logo.png"></p></td>
				</tr>
				<tr>
					<td>Username</td>
					<td><input type="text" name="time_user" value="<?php echo $username;?>"></td>
				</tr>
				<tr>
					<td>Password</td>
					<td><input type="password" name="time_pass"></td>
				</tr>
				<tr>
					<td>Password (again)</td>
					<td><input type="password" name="time_pass2"></td>
				</tr>
				<tr>
					<td>Email</td>
					<td><input type="text" name="time_email" value="<?php echo $email;?>"></td>
				</tr>
				<tr>
					<td colspan="2"><p align="center"><input type="submit" value="Create Me!"></p></td>
				</tr>
			</table>
		</form>
		<?php
	}
	
	
	#######################################
	function create_user($username="", $password="", $email="local@localhost.local", $user_array=array(0,0,0,1), $seed="", $validate_user_flag = 1)
	{
		if($username == ""){$return = array("un_err", "Username is blank"); return $return;}
		if($password == ""){$return = array("pw_err", "Password is blank"); return $return;}
		if(security::check_user_reserved($username) == 1){$return = array("dup_u", "Reserved user"); return $return;}
		if(!checkEmail($email)){$return = array("err_email", "Invalid Email address.");return $return;}
		
		include('config.inc.php');
		
		$conn = $GLOBALS['conn'];
		$db = $GLOBALS['db'];
		$user_logins_table = $GLOBALS['user_logins_table'];
		$UPATH	=	$GLOBALS['UPATH'];
		$subject = "New WiFiDB User ";
		$type = "new_users";
		$date = date("Y-m-d G:i:s");
		
		$admin = $user_array[0];
		$dev = $user_array[1];
		$mod = $user_array[2];
		$user = $user_array[3];
		
		if($seed == ''){$seed = $GLOBALS['seed'];}
		if($seed == ''){$seed = "PIECAVE!";}
		
		if($username == '' or $password == ''){die("Username and/or password cannot be blank.");}
		
		$uid_b = md5($date.$username.$seed);
		$uid_exp = str_split($uid_b, 6);
		$uid = implode("-", $uid_exp);
		#echo $uid."<BR>";
		$user_cache = 'waypoints_'.$username;
		$user_stats = 'stats_'.$username;
		$pass_seed = md5($password.$seed);
		$insert_user = "INSERT INTO `$db`.`$user_logins_table` (`id` ,`username` ,`password`, `admins` , `devs`, `mods`, `users` ,`last_login` ,`email`, `uid`, `join_date`, `validated` )VALUES ( NULL , '$username', '$pass_seed', '$admin','$dev','$mod','$user', '$date', '$email', '$uid', '$date', '$validate_user_flag')";
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
							  `cat` varchar(255) NOT NULL,
							  `type` varchar(255) NOT NULL,
							  `diff` double(3,2) NOT NULL,
							  `terain` double(3,2) NOT NULL,
							  `lat` varchar(255) NOT NULL,
							  `long` varchar(255) NOT NULL,
							  `link` varchar(255) NOT NULL,
							  `share` tinyint(1) NOT NULL,
							  `share_id` int(255) NOT NULL,
							  `c_date` datetime NOT NULL,
							  `u_date` datetime NOT NULL,
							  UNIQUE KEY `id` (`id`),
							  UNIQUE `gcid` (`gcid`)
							) ENGINE=INNODB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=0";
			if(mysql_query($create_user_cache, $conn))
			{
				$create_user_cache = "CREATE TABLE `$db`.`$user_stats` 
							(
							  `id` int(255) NOT NULL auto_increment,
							  `newest` varchar(255) NOT NULL,
							  `largest` varchar(255) NOT NULL,
							  UNIQUE KEY `id` (`id`)
							) ENGINE=INNODB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=0";
				if(mysql_query($create_user_cache, $conn))
				{
					$msg = "New user has been created!\r\nUsername: $username\r\nDate: $date\r\nLink to Users' info: ".$UPATH."/opt/userstats.php?func=alluserlists&user=$username";
					mail_users($msg, $subject, $type, 0);
					return 1;
				}else
				{
					$msg = "Failed to create new user statistics table. ($date)\r\n Username: $username\r\nMySQL Error:\r\n$err";
					mail_users($msg, $subject, $type, 1);
					$return = array("create_tb", $msg);
					return $return;
				}
			}else
			{
				$msg = "Failed to create new user Geocache table. ($date)\r\n Username: $username\r\nMySQL Error:\r\n$err";
				mail_users($msg, $subject, $type, 1);
				$return = array("create_tb", $msg);
				return $return;
			}
		}
		else
		{
			$err = mysql_error($conn);
			$msg = "Failed to create new user. Duplicate username or email already exists in database. ($date)\r\n Username: $username\r\n Email: $email\r\n MySQL Error:\r\n$err";
			mail_users($msg, $subject, $type, 1);
			$return = array("dup_u", $err);
			return $return;
		}
	}
}
?>