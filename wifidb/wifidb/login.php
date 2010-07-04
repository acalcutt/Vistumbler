<?php
global $conn, $user_logins_table, $db;

include_once('lib/database.inc.php');
include_once('lib/security.inc.php');
include_once('lib/config.inc.php');

$seed = $GLOBALS['login_seed'];
$func =	'';
$func = filter_input(INPUT_GET, 'func', FILTER_SANITIZE_SPECIAL_CHARS);
$return = @$_GET['return'];
$sec = new security();

if($return == '' and !@$_POST['return']){$return = $GLOBALS['hosturl'].''.$GLOBALS['root'];}

switch($func)
{
	case "login_proc":
		$return = @$_POST['return'];
		$username = filter_input(INPUT_POST, 'time_user', FILTER_SANITIZE_SPECIAL_CHARS);
		$password = filter_input(INPUT_POST, 'time_pass', FILTER_SANITIZE_SPECIAL_CHARS);
		$login = $sec->login($username, $password, $seed, 0);
		pageheader(" --> User Login");
		switch($login)
		{
			case "locked":
				?><h2>This user is locked out. contact this WiFiDB\'s admin, or go to the <a href="http://forum.techidiots.net/">forums</a> and bitch to Phil.<br></h2><?php
			break;
			
			case "validate":
				?><h2>This user is not validated yet. You should be getting an email soon if not already from the Database with a link
	to validate your email address first so that we can verify that you are in fact a real person. The administrator of the site has enabled this by default.</h2><?php
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
			break;
			
			case"u_fail":
				?><h2>Username does not exsist.</h2><?php
			break;
			
			case "u_u_r_fail":
				echo "failed to update User row";
			break;
			
			case "good":
				redirect_page($return, 2000, 'Login Successful!');
			break;
			
			case "cookie_fail":
				echo "Set Cookie fail, check the bottom of the glass, or your browser.";
			break;
			
			default:
				echo "Unknown Return.";
			break;
		}
		
	break;
	
	#---#
	case "logout_proc":
		$username = filter_input(INPUT_POST, 'time_user', FILTER_SANITIZE_SPECIAL_CHARS);
		$password = filter_input(INPUT_POST, 'time_pass', FILTER_SANITIZE_SPECIAL_CHARS);
	#	$login = $sec->login($username, $password, $seed, $return);
		$admin_cookie = filter_input(INPUT_GET, 'a_c', FILTER_SANITIZE_SPECIAL_CHARS);
		if($admin_cookie==1)
		{
			$cookie_name = 'WiFiDB_admin_login_yes';
			$msg = 'Admin Logout Successful!';
			if($GLOBALS["root"] != '')
			{$path		 = '/'.$GLOBALS["root"].'/cp/admin/';}
			else{$path		 = '/cp/admin/';}
		}else
		{
			$cookie_name = 'WiFiDB_login_yes';
			$msg = 'Logout Successful!';
			if($GLOBALS["root"] != '')
			{$path		 = '/'.$GLOBALS["root"].'/';}
			else{$path		 = '/';}
		}
		if(setcookie($cookie_name, md5("@LOGGEDOUT!").":".$username, time()-3600, $path))
		{
			pageheader("User Logout");
			redirect_page($GLOBALS['UPATH'], 2000, $msg);
		}
		else
		{
			pageheader("User Logout");
			echo "Could not log you out.. :-(";
		}
	break;
	
	#---#
	case "create_user_form":
		pageheader("Security Page");
		?>
		<font color="green"><h2>Create User</h2></font>
		<?php
		$sec->user_create_form();
	break;
	
	#---#
	case "create_user_proc":
		pageheader("Security Page");
		$username = filter_input(INPUT_POST, 'time_user', FILTER_SANITIZE_SPECIAL_CHARS);
		$password = filter_input(INPUT_POST, 'time_pass', FILTER_SANITIZE_SPECIAL_CHARS);
		$password2 = filter_input(INPUT_POST, 'time_pass2', FILTER_SANITIZE_SPECIAL_CHARS);
		$email = filter_input(INPUT_POST, 'time_email', FILTER_SANITIZE_SPECIAL_CHARS);
		if($password !== $password2)
		{
			?>
			<font color="red"><h2>Passwords did not match</h2></font>
			<?php
			$sec->user_create_form($username, $email);
		}else
		{
			$create = $sec->create_user($username, $password, $email, $user_array=array(0,0,0,1), $seed);
			switch($create)
			{
				case 1:
					?>
					<p align="center"><font  color="green"><h2>User Created! Go ahead and login.</h2></font></p>
					<?php
					if($GLOBALS['email_validation'])
					{
						mail_validation($email, $username);
						?>
						<p align="center"><font  color="yellow"><h2>Email Validation has been enabled, check your email for a link and activate your account first.</h2></font></p>
						<?php
					}
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
							<td colspan="2"><p align="center"><input type="submit" value="Login"></p></td>
						</tr>
						<tr>
							<td colspan="2"><p align="center"><a class="links" href="<?php echo $_SERVER['PHP_SELF'];?>?func=create_user_form">Create a user account</a><br><a class="links" href="<?php echo $_SERVER['PHP_SELF'];?>?func=reset_user_pass">Forgot your password?</a></p></td>
						</tr>
					</table>
					</form>
					<?php
				break;
				
				case is_array($create):
					list($er, $msg) = $create;
					switch($er)
					{
						case "create_tb":
							echo $msg.'<BR>This is a serious error, contact Phil on the <a href="http://forum.techidiots.net/">forums</a><br>MySQL Error Message: '.$msg."<br><br><h1>D'oh!</h1>";
						break;
						
						case "dup_u":
							?><h2><font color="red">There is a user already with that username or email address. Pick another one.</font></h2><BR>
							<?php
							$sec->user_create_form($username, $email);
						break;
						
						case "err_email":
							?><h2><font color="red">The email address you provided is not valid. Please enter a real email.</font></h2><BR>
							<?php
							$sec->user_create_form($username, $email);
						break;
						
						case "un_err":
							?><h2><font color="red">The username you provided is blank. How are you supposed to login?</font></h2><BR>
							<?php
							$sec->user_create_form($username, $email);
						break;
						
						case "pw_err":
							?><h2><font color="red">The password you provided is blank. How are you supposed to login?</font></h2><BR>
							<?php
							$sec->user_create_form($username, $email);
						break;
					}
				break;
			}
		}
	break;
	
	case "validate_user":
		pageheader("Security Page");
		$validate_code = htmlentities($_GET['validate_code'], ENT_QUOTES);
		$sql = "SELECT * FROM `$db`.`$validate_table` WHERE `code` = '$validate_code'";
		$result = mysql_query($sql, $conn);
		$v_array = mysql_fetch_array($result);
		$username = $v_array['username'];
		if($username)
		{
			$update = "UPDATE `$db`.`$user_logins_table` SET `validated` = '0' WHERE `username` = '$username'";
	#		echo $update."<br>";
			if(mysql_query($update, $conn))
			{
				$delete = "DELETE FROM `$db`.`$validate_table` WHERE `username` = '$username'";
			#	echo $delete."<BR>";
				if(mysql_query($delete, $conn))
				{
					echo "<font color='Green'><h2>Username: $username\r\n<BR>Has been activated! Go login -></h2></font>";
				}else
				{
					echo "<font color='Yellow'><h2>Username: $username\r\n<BR>Activated, but failed to remove from activation table, <br>
					This isnt a critical issue, but should be looked into by an administrator.
					<br>".mysql_error($conn)."</h2></font>";
				}
			}else
			{
				echo "<font color='red'><h2>Username: $username\r\n<BR>Failed to activate...<br>".mysql_error($conn)."</h2></font>";
			}
		}else
		{
			echo "<font color='red'><h2>Invalid Activation Code, Would you like to <a class='links' href='?func=revalidate'>send another</a> validation code?.</h2></font>";
		}
	break;
	
	case "revalidate_proc":
		pageheader("Security Page");
		$username = filter_input(INPUT_POST, 'time_user', FILTER_SANITIZE_SPECIAL_CHARS);
		$password = filter_input(INPUT_POST, 'time_pass', FILTER_SANITIZE_SPECIAL_CHARS);
		$email = filter_input(INPUT_POST, 'time_email', FILTER_SANITIZE_SPECIAL_CHARS);
		$seed == $GLOBALS['login_seed'];
		$pass_seed = md5($password.$seed);
		
		$sql0 = "SELECT * FROM `$db`.`$user_logins_table` WHERE `username` = '$username' LIMIT 1";
		$result = mysql_query($sql0, $conn);
		$newArray = mysql_fetch_array($result);
		$username_db = $newArray['username'];
		$user_email = $newArray['email'];
		$user_pwd_db = $newArray['password'];
	#	echo $pass_seed." == ".$user_pwd_db."<BR>";
		if($pass_seed == $user_pwd_db)
		{
			if(mail_validation($user_email, $username))
			{
				echo "<font color='green'><h2>Validation Email sent again.</h2>";
			}else
			{
				echo "<font color='red'><h2>Failed to send Validation Email.</h2>";
			}
		}else
		{
			echo "<font color='red'><h2>You entered the wrong password.</h2>";
		}
		echo "</font>";
	break;

	case "revalidate":
		pageheader("Security Page");
		?>
		<p align='center'><font color='red'><h2>Resend User Email Validation Code</h2></font></p>
		<form method="post" action="<?php echo $_SERVER['PHP_SELF'];?>?func=revalidate_proc">
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
				<td><input type=PASSWORD name="time_pass"></td>
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
	break;

	
	#---#
	case "reset_user_pass_proc":
		pageheader("Security Page");
		$username = filter_input(INPUT_POST, 'time_user', FILTER_SANITIZE_SPECIAL_CHARS);
		$email = filter_input(INPUT_POST, 'time_email', FILTER_SANITIZE_SPECIAL_CHARS);
		
		$sql0 = "SELECT * FROM `$db`.`$user_logins_table` WHERE `username` = '$username' LIMIT 1";
		$result = mysql_query($sql0, $conn);
		$newArray = mysql_fetch_array($result);
		$username_db = $newArray['username'];
		$user_email = $newArray['email'];
		if($username_db == '')
		{
			?>
			<p align='center'><font color='red'><h2>User not found, try again.</h2></font></p>
			<p align='center'><font color='red'><h2>Reset User password</h2></font></p>
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
					<td>Password</td>
					<td><input type=PASSWORD name="time_pass"></td>
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
		}else
		{
			if($email == $user_email)
			{
				##########################
				$validatecode = $sec->gen_keys(12);
				##########################
				require_once('lib/MAIL5.php');
				
				$conn				= 	$GLOBALS['conn'];
				$db					= 	$GLOBALS['db'];
				$user_logins_table	=	$GLOBALS['user_logins_table'];
				$seed				=	$GLOBALS['login_seed'];
				$from				=	$GLOBALS['admin_email'];
				$wifidb_smtp		=	$GLOBALS['wifidb_smtp'];
				$sender				=	$from;
				$sender_pass		=	$GLOBALS['wifidb_from_pass'];
				$to					=	array();
				$mail				=	new MAIL5();
				
				if(!$mail->from($from))
				{die("Failed to add From address\r\n");}
				if(!$mail->addto($user_email))
				{die("Failed to add To address\r\n");}
				
				if(!$mail->subject("WiFiDB User Password Reset"))
				{die("Failed to add subject\r\n");}
				
				$contents = "You have requested a reset of your password, here it is...
Your account: $username
Temp Password: $validatecode

Go here to reset it to one you choose:
".$GLOBALS['UPATH']."/login.php?func=reset_password

-WiFiDB Service";

				if(!$mail->text($contents))
				{die("Failed to add message\r\n");}
				
				$smtp_conn = $mail->connect($wifidb_smtp, 465, $sender, $sender_pass, 'tls', 10);
				if ($smtp_conn)
				{
					if($mail->send($smtp_conn))
					{
						$password = md5($validatecode.$seed);
						$update = "UPDATE `$db`.`$user_logins_table` SET `password` = '$password' WHERE `username` = '$username'";
					#	echo $update."<BR>";
						if(mysql_query($update, $conn))
						{
							echo "<font color='green'><h2>Password reset email sent.</h2></font>";
						}else
						{
							echo "Mysql Error: ".mysql_error($conn);
						}
					}
					else
					{
						echo "<font color='red'><h2>Password reset email Failed to send.</h2></font>";
					}
				}
				else
				{
					echo "<font color='red'><h2>Failed to connect to SMTP Host.</h2></font>";
				}
				$mail->disconnect();
			}else
			{
				?>
				<p align='center'><font color='red'><h2>Email address could not be matched, try again.</h2></font></p>
				<p align='center'><font color='red'><h2>Reset User password</h2></font></p>
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
						<td>Password</td>
						<td><input type=PASSWORD name="time_pass"></td>
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
			}
		}
	break;

	#---#
	case "reset_user_pass":
		pageheader("Security Page");
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
				<td colspan="2"><p align="center"><input type="submit" value="Send Email"></p></td>
			</tr>
		</table>
		</form>
		<?php
	break;
	
	case "reset_password_proc":
		pageheader("Security Page");
		require_once("lib/MAIL5.php");
		$username = filter_input(INPUT_POST, 'time_user', FILTER_SANITIZE_SPECIAL_CHARS);
		$password = filter_input(INPUT_POST, 'time_current_pwd', FILTER_SANITIZE_SPECIAL_CHARS);
		$newpassword = filter_input(INPUT_POST, 'time_new_pwd', FILTER_SANITIZE_SPECIAL_CHARS);
		$newpassword2 = filter_input(INPUT_POST, 'time_new_pwd_again', FILTER_SANITIZE_SPECIAL_CHARS);
		
		$from				=	$GLOBALS['admin_email'];
		$wifidb_smtp		=	$GLOBALS['wifidb_smtp'];
		$sender				=	$from;
		$sender_pass		=	$GLOBALS['wifidb_from_pass'];
		$mail				=	new MAIL5();
		$seed = $GLOBALS['login_seed'];
		
		$sql0 = "SELECT * FROM `$db`.`$user_logins_table` WHERE `username` = '$username' LIMIT 1";
		$result = mysql_query($sql0, $conn);
		$newArray = mysql_fetch_array($result);
		$username_db = $newArray['username'];
		$user_email = $newArray['email'];
		$password_db = $newArray['password'];
		if($username_db == '')
		{
			?>
			<p align='center'><font color='red'><h2>Username was blank, try again.</h2></font></p>
			<p align='center'><font color='red'><h2>Reset forgoten password</h2></font></p>
			<form method="post" action="<?php echo $_SERVER['PHP_SELF'];?>?func=reset_password_proc">
			<table align="center">
				<tr>
					<td colspan="2"><p align="center"><img src="themes/wifidb/img/logo.png"></p></td>
				</tr>
				<tr>
					<td>Username</td>
					<td><input type="text" name="time_user"></td>
				</tr>
				<tr>
					<td>Temp Password</td>
					<td><input type=PASSWORD name="time_current_pwd"></td>
				</tr>
				<tr>
					<td>New Password</td>
					<td><input type=PASSWORD name="time_new_pwd"></td>
				</tr>
				<tr>
					<td>Retype New Password</td>
					<td><input type=PASSWORD name="time_new_pwd_again"></td>
				</tr>
				<tr>
					<td colspan="2"><p align="center"><input type="submit" value="Re-set Password"></p></td>
				</tr>
			</table>
			</form>
			<?php
		}else
		{
			if($newpassword === $newpassword2)
			{
				$password = md5($password.$seed);
				if($password === $password_db)
				{
					$setpassword = md5($newpassword.$seed);
					$update = "UPDATE `$db`.`$user_logins_table` SET `password` = '$setpassword' WHERE `username` = '$username_db'";
				#	echo $update."<BR>";
					if(mysql_query($update, $conn))
					{
						if(!$mail->from($from))
						{die("Failed to add From address\r\n");}
						if(!$mail->addto($user_email))
						{die("Failed to add To address\r\n");}
						
						if(!$mail->subject("WiFiDB User Password Reset"))
						{die("Failed to add subject\r\n");}
						
						$contents = "You have just reset your password, if you did not do this, i would email the admin...

Your account: $username

-WiFiDB Service";
						
						if(!$mail->text($contents))
						{die("Failed to add message\r\n");}
						
						$smtp_conn = $mail->connect($wifidb_smtp, 465, $sender, $sender_pass, 'tls', 10);
						if ($smtp_conn)
						{
							if($mail->send($smtp_conn))
							{
								?>
									<p align='center'><font color='green'><h2>Your password has been reset, you can now go login.</h2></font></p>
								<?php
							}else
							{
								?>
									<p align='center'><font color='red'><h2>Your password has been reset, but failed to send email to user.</h2></font></p>
								<?php
							}
						}else
						{
							?>
								<p align='center'><font color='red'><h2>Failed to connect to SMTP Host.</h2></font></p>
							<?php
						}
					}else
					{
						?><h2>Mysql Error:</h2><font color='red'> <?php echo mysql_error($conn); ?></font><?php
					}
				}else
				{
					?>
					<p align='center'><font color='red'><h2>Password did not match DB.</h2></font></p>
					<p align='center'><font color='red'><h2>Reset forgoten password</h2></font></p>
					<form method="post" action="<?php echo $_SERVER['PHP_SELF'];?>?func=reset_password_proc">
					<table align="center">
						<tr>
							<td colspan="2"><p align="center"><img src="themes/wifidb/img/logo.png"></p></td>
						</tr>
						<tr>
							<td>Username</td>
							<td><input type="text" name="time_user"></td>
						</tr>
						<tr>
							<td>Temp Password</td>
							<td><input type=PASSWORD name="time_current_pwd"></td>
						</tr>
						<tr>
							<td>New Password</td>
							<td><input type=PASSWORD name="time_new_pwd"></td>
						</tr>
						<tr>
							<td>Retype New Password</td>
							<td><input type=PASSWORD name="time_new_pwd_again"></td>
						</tr>
						<tr>
							<td colspan="2"><p align="center"><input type="submit" value="Re-set Password"></p></td>
						</tr>
					</table>
					</form>
					<?php
				}
			}else
			{
				?>
				<p align='center'><font color='red'><h2>New Passwords did not match.</h2></font></p>
				<p align='center'><font color='red'><h2>Reset forgoten password</h2></font></p>
				<form method="post" action="<?php echo $_SERVER['PHP_SELF'];?>?func=reset_password_proc">
				<table align="center">
					<tr>
						<td colspan="2"><p align="center"><img src="themes/wifidb/img/logo.png"></p></td>
					</tr>
					<tr>
						<td>Username</td>
						<td><input type="text" name="time_user"></td>
					</tr>
					<tr>
						<td>Temp Password</td>
						<td><input type=PASSWORD name="time_current_pwd"></td>
					</tr>
					<tr>
						<td>New Password</td>
						<td><input type=PASSWORD name="time_new_pwd"></td>
					</tr>
					<tr>
						<td>Retype New Password</td>
						<td><input type=PASSWORD name="time_new_pwd_again"></td>
					</tr>
					<tr>
						<td colspan="2"><p align="center"><input type="submit" value="Re-set Password"></p></td>
					</tr>
				</table>
				</form>
				<?php
			}
		}
	break;
	
	case "reset_password":
		pageheader("Security Page");
		?>
		<p align='center'><font color='red'><h2>Reset forgoten password</h2></font></p>
		<form method="post" action="<?php echo $_SERVER['PHP_SELF'];?>?func=reset_password_proc">
		<table align="center">
			<tr>
				<td colspan="2"><p align="center"><img src="themes/wifidb/img/logo.png"></p></td>
			</tr>
			<tr>
				<td>Username</td>
				<td><input type="text" name="time_user"></td>
			</tr>
			<tr>
				<td>Temp Password</td>
				<td><input type=PASSWORD name="time_current_pwd"></td>
			</tr>
			<tr>
				<td>New Password</td>
				<td><input type=PASSWORD name="time_new_pwd"></td>
			</tr>
			<tr>
				<td>Retype New Password</td>
				<td><input type=PASSWORD name="time_new_pwd_again"></td>
			</tr>
			<tr>
				<td colspan="2"><p align="center"><input type="submit" value="Re-set Password"></p></td>
			</tr>
		</table>
		</form>
		<?php
	break;
	
	
	#---#
	default :
		pageheader("Security Page");
		$return = str_replace("%	5C", "%5C", $return);
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
	break;
}
footer($_SERVER['SCRIPT_FILENAME']);
?>