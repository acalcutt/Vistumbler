<?php
global $conn, $user_logins_table, $db;

include_once('lib/database.inc.php');
include_once('lib/security.inc.php');
include_once('lib/config.inc.php');
$sec = new security();
$func				=	'';

$func = filter_input(INPUT_GET, 'func', FILTER_SANITIZE_SPECIAL_CHARS);

switch($func)
{
	case "login_proc":
		$return = filter_input(INPUT_POST, 'return');
		$username = filter_input(INPUT_POST, 'time_user', FILTER_SANITIZE_SPECIAL_CHARS);
		$password = filter_input(INPUT_POST, 'time_pass', FILTER_SANITIZE_SPECIAL_CHARS);
		$login = $sec->login($username, $password, $seed, $return);
		pageheader("Login Page");
		
		if($login == "locked")
		{
			echo '<h2>This user is locked out. contact this WiFiDB\'s admin, or go to the <a href="http://forum.techidiots.net/">forums</a> and bitch to Phil.<br></h2>';
		}
		footer($_SERVER['SCRIPT_FILENAME']);
	break;
	
	#---#
	case "logout_proc":
		
		if(!@$_COOKIE['WiFiDB_login_yes'])
		{
			?>
				<script type="text/javascript">
					function reload()
					{
						location.href = '<?php echo $hosturl.$root.'/';?>';
					}
				</script>
				<body onload="reload()">Cookie already expired...</body>
			<?php
		}else
		{
			if(setcookie("WiFiDB_login_yes", md5("@LOGGEDIN!".$pass_seed).":".$username, time()-3600))
			{
				?>
				<script type="text/javascript">
					function reload()
					{
						location.href = '<?php echo $hosturl.$root.'/';?>';
					}
				</script>
				<body onload="reload()">Logged Out...</body>
				<?php
			}
			else
			{
				echo "Could not log you out.. :-(";
			}
		}
		
	break;
	
	#---#
	case "create_user_form":
		pageheader("Login Page");
		?>
		<form method="post" action="<?php echo $_SERVER['PHP_SELF'];?>?func=create_user_proc">
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
				<td>Password (again)</td>
				<td><input type="password" name="time_pass2"></td>
			</tr>
			<tr>
				<td>Email</td>
				<td><input type="text" name="time_email"></td>
			</tr>
			<tr>
				<td colspan="2"><p align="center"><input type="submit" value="Create Me!"></p></td>
			</tr>
		</table>
		
		</form>
		<?php
		footer($_SERVER['SCRIPT_FILENAME']);
	break;
	
	#---#
	case "create_user_proc":
		pageheader("Login Page");
		$username = filter_input(INPUT_POST, 'time_user', FILTER_SANITIZE_SPECIAL_CHARS);
		$password = filter_input(INPUT_POST, 'time_pass', FILTER_SANITIZE_SPECIAL_CHARS);
		$password2 = filter_input(INPUT_POST, 'time_pass2', FILTER_SANITIZE_SPECIAL_CHARS);
		$email = filter_input(INPUT_POST, 'time_email', FILTER_SANITIZE_SPECIAL_CHARS);
		if($password !== $password2)
		{
			
			?>
			<form method="post" action="<?php echo $_SERVER['PHP_SELF'];?>?func=create_user_proc">
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
					<td>Password (again)</td>
					<td><input type="password" name="time_pass2"></td>
				</tr>
				<tr>
					<td>Email</td>
					<td><input type="text" name="time_email"></td>
				</tr>
				<tr>
					<td colspan="2"><p align="center"><input type="submit" value="Create Me!"></p></td>
				</tr>
			</table>
			
			</form>
			<?php
			footer($_SERVER['SCRIPT_FILENAME']);
			die();
		}
		if($sec->create_user($username, $password, $email, $seed))
		{
			?>
			<p align="center"><font  color="green"><h2>User Created! Go ahead and login.</h2></font></p>
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
					<td colspan="2"><p align="center"><a class="links" href="<?php echo $_SERVER['PHP_SELF'];?>?func=create_user_form">Create a user account</a><br><a class="links" href="<?php echo $_SERVER['PHP_SELF'];?>?func=reset_user_pass">Forgot your password?</a></p></td>
				</tr>
			</table>
			</form>
			<?php
		
		}else
		{
			echo "<br><h1>D'oh!</h1>";
		}
		footer($_SERVER['SCRIPT_FILENAME']);
	break;
	
	#---#
	case "dash":
		if($sec->login_check())
		{
			?>
			<script type="text/javascript">
				function reload()
				{
					location.href = '<?php echo $hosturl.$root.'/';?>';
				}
			</script>
			<body onload="reload()"></body>
			<?php
		}else
		{
			echo '<BR>NOOO!!!!!<br>
			Login failed for some reason, go to the
			<a href="http://forum.techidiots.net/">forums</a> and bitch to Phil.<br>
			Or <a href="'.$hosturl.$root.'/login.php">go back</a> and try again.';
		}
		
	break;
	
	#---#
	case "reset_user_pass_proc":
		
		pageheader("Login Page");
		$username = filter_input(INPUT_POST, 'time_user', FILTER_SANITIZE_SPECIAL_CHARS);
		$email = filter_input(INPUT_POST, 'time_email', FILTER_SANITIZE_SPECIAL_CHARS);
		
		$sql0 = "SELECT * FROM `$db`.`$user_logins_table` WHERE `username` = '$username' LIMIT 1";
		$result = mysql_query($sql0, $conn);
		$newArray = mysql_fetch_array($result);
		$username_db = $newArray['username'];
		$user_email = $newArray['email'];
		if($username_db == '')
		{
			echo "<p align='center'><font color='red'><h2>User not found, try again, remember user-names are case sensitive.</h2></font></p>";
			?>
			<p align='center'><font color='red'><h2>Reset forgotten password</h2></font></p>
			<form method="post" action="<?php echo $_SERVER['PHP_SELF'];?>?func=reset_user_pass_proc">
			<table align="center">
				<tr>
					<td colspan="2"><p align="center"><img src="themes/wifidb/img/logo.png"></p></td>
				</tr>
				<tr>
					<td>Username</td>
					<td><input type="text" name="time_user"></td>
				</tr>
				<tr>
					<td>Email Address</td>
					<td><input type="text" name="time_email"></td>
				</tr>
				<tr>
					<td colspan="2"><p align="center"><input type="submit" value="Reset"></p></td>
				</tr>
			</table>
			</form>
			<?php
			footer($_SERVER['SCRIPT_FILENAME']);
		}else
		{
			if($email === $user_email)
			{
				##########################
				// http://snippets.dzone.com/posts/show/3123
				$len			=	12;
				$base			=	'ABCDEFGHKLMNOPQRSTWXYZabcdefghjkmnpqrstwxyz123456789!@#$%^&*()_+-=';
				$max			=	strlen($base)-1;
				$activatecode	=	'';
				
				mt_srand((double)microtime()*1000000);
				
				while (strlen($activatecode) < $len+1)
				{
					$activatecode.=$base{mt_rand(0,$max)};
				}
				##########################
				
				
			#	echo $activatecode;
				$subject = "WiFiDB User account Info";
				$contents = "<BR>Your WiFiDB Account password has been requested to have been reset, so here it is: ".$activatecode."\r\nIf you did not request this, contact one of us on the <a href='http://forum.techidiots.net/forum/'>forums.</a>";
			#	echo $contents."<BR>";
				$from_header = "From: WiFiDB_accounts@".$host_domain;
				if($contents != "")
				{
					$users_email = "longbow486@msn.com";
					if(mail($users_email, $subject, $contents, $from_header))
				#	if(sendmail($username_db, $users_email, "WiFiDB No-Reply", "wifidb@randomintervals.com", $subject, $contents, $from_header))
					{
						echo "<p align='center'><font color='green'><h2>Email Sent.</h2></font></p>";
					}else
					{
						echo "<p align='center'><font color='red'><h2>Email Not Sent.</h2></font></p>";
					}
				}else
				{
				   echo "<p align='center'><font color='red'><h2>There was nothing in the bodym of the email....</h2></font></p>";
				}
			}else
			{
				echo "<p align='center'><font color='red'><h2>Email address could not be matched, try again, remember emails are case sensitive.</h2></font></p>";
				?>
				<p align='center'><font color='red'><h2>Reset forgotten password</h2></font></p>
				<form method="post" action="<?php echo $_SERVER['PHP_SELF'];?>?func=reset_user_pass_proc">
				<table align="center">
					<tr>
						<td colspan="2"><p align="center"><img src="themes/wifidb/img/logo.png"></p></td>
					</tr>
					<tr>
						<td>Username</td>
						<td><input type="text" name="time_user"></td>
					</tr>
					<tr>
						<td>Email Address</td>
						<td><input type="text" name="time_email"></td>
					</tr>
					<tr>
						<td colspan="2"><p align="center"><input type="submit" value="Reset"></p></td>
					</tr>
				</table>
				</form>
				<?php
				footer($_SERVER['SCRIPT_FILENAME']);
			}
		}
	break;

	#---#
	case "reset_user_pass":
		pageheader("Login Page");
		?>
		<p align='center'><font color='red'><h2>Reset forgoten password</h2></font></p>
		<form method="post" action="<?php echo $_SERVER['PHP_SELF'];?>?func=reset_user_pass_proc">
		<table align="center">
			<tr>
				<td colspan="2"><p align="center"><img src="themes/wifidb/img/logo.png"></p></td>
			</tr>
			<tr>
				<td>Username</td>
				<td><input type="text" name="time_user"></td>
			</tr>
			<tr>
				<td>Email Address</td>
				<td><input type="text" name="time_email"></td>
			</tr>
			<tr>
				<td colspan="2"><p align="center"><input type="submit" value="Login"></p></td>
			</tr>
		</table>
		</form>
		<?php
		footer($_SERVER['SCRIPT_FILENAME']);
	break;
	
	#---#
	default :
		pageheader("Login Page");
		$return = filter_input(INPUT_GET, 'return');
		?>
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
				<td colspan="2"><p align="center"><input type="hidden" name="return" value="<?php echo $return;?>"><input type="submit" value="Login"></p></td>
			</tr>
			<tr>
				<td colspan="2"><p align="center"><a class="links" href="<?php echo $_SERVER['PHP_SELF'];?>?func=create_user_form">Create a user account</a><br><a class="links" href="<?php echo $_SERVER['PHP_SELF'];?>?func=reset_user_pass">Forgot your password?</a></p></td>
			</tr>
		</table>
		</form>
		<?php
		footer($_SERVER['SCRIPT_FILENAME']);
	break;
}
footer($_SERVER['SCRIPT_FILENAME']);
?>