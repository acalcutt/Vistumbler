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
	#	dump($_POST['return']);
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
						<td>Username <font size="1">(CaSeSenSiTivE)</font></td>
						<td><input type="text" name="time_user"></td>
					</tr>
					<tr>
						<td>Password <font size="1">(CaSeSenSiTivE)</font></td>
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
			$path = '/cp/';
		}else
		{
			$cookie_name = 'WiFiDB_login_yes';
			$msg = 'Logout Successful!';
			$path = '/';
		}
		if(setcookie($cookie_name, md5("@LOGGEDOUT!").":".$username, time()-3600, $path))
		{
			redirect_page($return, 2000, $msg);
		}
		else
		{
			echo "Could not log you out.. :-(";
		}
	break;
	
	#---#
	case "create_user_form":
		pageheader("Security Page");
		?>
		<form method="post" action="<?php echo $_SERVER['PHP_SELF'];?>?func=create_user_proc">
		<table align="center">
			<tr>
				<td colspan="2"><p align="center"><img src="themes/wifidb/img/logo.png"></p></td>
			</tr>
			<tr>
				<td>Username <font size="1">(CaSeSenSiTivE)</font></td>
				<td><input type="text" name="time_user"></td>
			</tr>
			<tr>
				<td>Password <font size="1">(CaSeSenSiTivE)</font></td>
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
			<form method="post" action="<?php echo $_SERVER['PHP_SELF'];?>?func=create_user_proc">
			<table align="center">
				<tr>
					<td colspan="2"><p align="center"><img src="themes/wifidb/img/logo.png"></p></td>
				</tr>
				<tr>
					<td>Username <font size="1">(CaSeSenSiTivE)</font></td>
					<td><input type="text" name="time_user" value="<?php echo $username;?>"></td>
				</tr>
				<tr>
					<td>Password <font size="1">(CaSeSenSiTivE)</font></td>
					<td><input type="password" name="time_pass"></td>
				</tr>
				<tr>
					<td>Password (again)<font size="1">(CaSeSenSiTivE)</font></td>
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
		}else
		{
			$create = $sec->create_user($username, $password, $email, $user_array=array(0,0,0,1), $seed);
			switch($create)
			{
				case 1:
					mail_validation($email, $username);
					?>
					<p align="center"><font  color="green"><h2>User Created! Go ahead and login.</h2></font></p>
					<form method="post" action="<?php echo $_SERVER['PHP_SELF'];?>?func=login_proc">
					<table align="center">
						<tr>
							<td colspan="2"><p align="center"><img src="themes/wifidb/img/logo.png"></p></td>
						</tr>
						<tr>
							<td>Username <font size="1">(CaSeSenSiTivE)</font></td>
							<td><input type="text" name="time_user"></td>
						</tr>
						<tr>
							<td>Password <font size="1">(CaSeSenSiTivE)</font></td>
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
						case "create_wpt":
							echo 'There was an error in Creating the Geocache table.<BR>This is a serious error, contact Phil on the <a href="http://forum.techidiots.net/">forums</a><br>MySQL Error Message: '.$msg."<br><br><h1>D'oh!</h1>";
						break;
						
						case "dup_u":
							?><h2><font color="red">There is a user already with that username or email address. Pick another one.</font></h2><BR>
							<?php  #echo $msg;?>
							<form method="post" action="<?php echo $_SERVER['PHP_SELF'];?>?func=create_user_proc">
							<table align="center">
								<tr>
									<td colspan="2"><p align="center"><img src="themes/wifidb/img/logo.png"></p></td>
								</tr>
								<tr>
									<td>Username <font size="1">(CaSeSenSiTivE)</font></td>
									<td><input type="text" name="time_user" value="<?php echo $username;?>"></td>
								</tr>
								<tr>
									<td>Password <font size="1">(CaSeSenSiTivE)</font></td>
									<td><input type="password" name="time_pass"></td>
								</tr>
								<tr>
									<td>Password (again)<font size="1">(CaSeSenSiTivE)</font></td>
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
		if($v_array['username'])
		{
			$update = "UPDATE `$db`.`$user_logins_table` SET `validated` = '0' WHERE `username` = '$username'";
			if(mysql_query($update, $conn))
			{
				$username = $v_array['username'];
				$delete = "DELETE FROM `$db`.`$validate_table` WHERE `username` = '$username'";
				echo $delete."<BR>";
				if(mysql_query($delete, $conn))
				{
					echo "<font color='Grey'><h2>Username: ".$v_array['username']."\r\n<BR>Has been activated! Go login -></h2></font>";
				}else
				{
					echo "<font color='Yellow'><h2>Username: ".$v_array['username']."\r\n<BR>Activated, but failed to remove from activation table, <br>
					This isnt a critical issue, but should be looked into by an administrator.
					<br>".mysql_error($conn)."</h2></font>";
				}
			}else
			{
				echo "<font color='red'><h2>Username: ".$v_array['username']."\r\n<BR>Failed to activate...<br>".mysql_error($conn)."</h2></font>";
			}
		}else
		{
			echo "<font color='red'><h2>Invalid Activation Code, Please try again.</h2></font>";
		}
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
			echo "<p align='center'><font color='red'><h2>User not found, try again, remember user-names are (CaSeSenSiTivE) sensitive.</h2></font></p>";
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
		}else
		{
			if($email === $user_email)
			{
				##########################
				$activatecode = $sec->gen_keys(12);
				##########################
				
				
			#	echo $activatecode;
				$subject = "WiFiDB User account Info";
				$contents = "<BR>Your WiFiDB Account password has been requested to have been reset, so here it is: ".$activatecode."\r\nIf you did not request this, contact one of us on the <a href='http://forum.techidiots.net/forum/'>forums.</a>";
			#	echo $contents."<BR>";
				$from_header = "From: WiFiDB_accounts@".$host_domain;
				if($contents != "")
				{
					$users_email = $GLOBALS['admin_email'];
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
				echo "<p align='center'><font color='red'><h2>Email address could not be matched, try again, remember emails are (CaSeSenSiTivE) sensitive.</h2></font></p>";
				?>
				<p align='center'><font color='red'><h2>Reset forgotten password</h2></font></p>
				<form method="post" action="<?php echo $_SERVER['PHP_SELF'];?>?func=reset_user_pass_proc">
				<table align="center">
					<tr>
						<td colspan="2"><p align="center"><img src="themes/wifidb/img/logo.png"></p></td>
					</tr>
					<tr>
						<td>Username <font size="1">(CaSeSenSiTivE)</font></td>
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
				<td>Username <font size="1">(CaSeSenSiTivE)</font></td>
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
				<td>Username <font size="1">(CaSeSenSiTivE)</font></td>
				<td><input type="text" name="time_user"></td>
			</tr>
			<tr>
				<td>Password <font size="1">(CaSeSenSiTivE)</font></td>
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