<?php
include('../lib/database.inc.php');
pageheader("Import Page");
include('../lib/config.inc.php');
if ($_SERVER['HTTP_HOST'] == "rihq.randomintervals.com" or $_SERVER['HTTP_HOST'] == "www.randomintervals.com" or $_SERVER['HTTP_HOST'] == "192.168.1.26" or $_SERVER['HTTP_HOST'] == "randomintervals.com")
{echo '<h2>This is one of my Development servers </h2>
<h4>(which is unstable because I am always working in it)</h4>
<h2>Go on over to the <i>Vistumbler <a target="_blank" href="http://www.vistumbler.net/wifidb/">\'Production Server\'</i></a> for a more stable environment</h2>';}
$conn = $GLOBALS['conn'];
$users_t	= $GLOBALS['users_t'];
$user_logins_table = $GLOBALS['user_logins_table'];
$files_tmp	= $GLOBALS['files_tmp'];
if(isset($_GET['func']))
{
	if($_GET['func'] == 'import')
	{$func =  'import';}
	else{$func = '';}
}else
{
	$func = '';
}
//Switchboard for import file or index form to upload file
switch($func)
{
	case 'import': //Import file that has been uploaded
		if (isset($_GET['token']))
		{
			if (isset($_SESSION['token']) && $_GET['token'] == $_SESSION['token'])
			{
				if($_POST["user"] !== ''){$user = addslashes($_POST["user"]);}else{$user="Unknown";}
				if($_POST["notes"] !== ''){$notes = addslashes($_POST["notes"]);}else{$notes="No Notes";}
				if($_POST['title'] !== ''){$title = addslashes($_POST['title']);}else{$title="Untitled";}
				
				$tmp	=	$_FILES['file']['tmp_name'];
				$filename	=	$_FILES['file']['name'];
				$file_ext = explode('.', $filename);
				$ext = strtolower($file_ext[1]);
				if($ext != 'vs1'){echo '<h2>You can only upload VS1 files<br><A class="links" HREF="javascript:history.go(-1)">Go back</a> and do it right!</h2>'; footer($_SERVER['SCRIPT_FILENAME']); die();}
				$rand	=	rand(); //generate a random number to be added to the new filename so there is not a chance of being a duplicate name.
				
				$user = filter_var($user, FILTER_SANITIZE_SPECIAL_CHARS);
				$notes = filter_var($notes, FILTER_SANITIZE_SPECIAL_CHARS);
				$title = filter_var($title, FILTER_SANITIZE_SPECIAL_CHARS);
				
				$sql = "SELECT `username` FROM `$db`.`$user_logins_table` WHERE `username` LIKE '$user'";
				$result = mysql_query( $sql , $conn);
				$array = mysql_fetch_array($result);
				if($array['username'] == $user and !$global_loggedin)
				{
					echo "<h2>You need to be logged in to import to a user that has a login.<br> Go <a class='links' href='".$GLOBALS['hosturl']."login.php?return=/import/'>login</a> and then import again.</h2>";
					die(footer($_SERVER['SCRIPT_FILENAME']));
				}
				$uploadfolder = getcwd().'/up/';
				$uploadfile = $uploadfolder.$rand.'_'.$filename;
				$return  = file($tmp);
				$count = count($return);
				if($count <= 8) 
				{
					echo '<br><br><h2>You cannot upload an empty VS1 file, at least scan for a few seconds to import some data. <A HREF="javascript:history.go(-1)"> [Go Back]</A></h2>';
					$filename = $_SERVER['SCRIPT_FILENAME'];
					footer($filename);
					die();
				}
				if (!copy($tmp, $uploadfile))
				{
					echo 'Failure to Move file to Upload Dir ('.$uploadfolder.'), check the folder permisions if you are using Linux.<BR>';
					$filename = $_SERVER['SCRIPT_FILENAME'];
					footer($filename);
					die();
				}
				chmod($uploadfile, 0600);
				$hash = hash_file('md5', $uploadfile);

				$size1 = format_size(dos_filesize($uploadfile));
								
				$return  = file($tmp);
				
				$VS1Test = str_split($return[0], 12);
				$file_e = explode('.',$filename);
				$file_max = count($file_e);
				
				//What file are we tring to import, a VS1 or a GPX file?
				if($file_e[$file_max-1] == 'gpx' )
				{
					echo "<h2>Importing GPX File</h2><h1>Imported By: ".$user."<BR></h1>";
					echo "<h2>With Title: ".$title."</h2>";
					$database = new database();
					$database->import_gpx($uploadfile, $user, $notes, $title );
				}
				elseif($VS1Test[0] == "# Vistumbler" )
				{
					echo "<h2>Importing VS1 File</h2><h1>Imported By: ".$user."<BR></h1>";
					echo "<h2>With Title: ".$title."</h2>";
					
					$database = new database();
					if($GLOBALS['daemon']==1)
					{	
						//lets try a schedualed import table that has a cron job
						//that runs and imports all of them at once into the DB 
						//in order that they where uploaded
						$imp_file = $rand.'_'.$filename;
						$date = date("y-m-d H:i:s");
						$sql = "INSERT INTO `$db`.`$files_tmp` ( `id`, `file`, `date`, `user`, `notes`, `title`, `size`, `hash`  ) VALUES ( '', '$imp_file', '$date', '$user', '$notes', '$title', '$size1', '$hash')";
						$result = mysql_query( $sql , $conn);
						if($result)
						{
							echo "<h2>File has been inserted for Importing at a later time at a schedualed time.</h2>";
						}else
						{
							echo "<h2>There was an error inserting file for schedualed import.</h2>".mysql_error($conn);
						}
					}else
					{
						$database->import_vs1($uploadfile, $user, $notes, $title, $verbose = 1, $out = "CLI" );
					}
				}else
				{
					echo '<H1>Hey! You have to upload a valid VS1 or GPX File <A HREF="javascript:history.go(-1)"> [Go Back]</A> and do it again the right way.</h1>';
					footer($_SERVER['SCRIPT_FILENAME']);
					die();
				}
				?>
				<p><a class="links" href="/wifidb/opt/scheduling.php?token=<?php echo $_SESSION['token'];?>">Go and check out your new Import</a>. Go on, you know you want to...</p>
				<?php
				mysql_select_db($db,$conn);

				$sqls = "SELECT * FROM `$users_t`";
				$result = mysql_query($sqls, $conn) or die(mysql_error());
				$row = mysql_num_rows($result);
				#$database->exp_kml($export="exp_newest_kml");
				
				// ASK FOR ANOTHER IMPORT
				?>
				<CENTER><form action="?func=import&token=<?php echo $_SESSION['token'];?>" method="post" enctype="multipart/form-data">
					<TABLE BORDER=1 CELLPADDING=2 CELLSPACING=0>
						<TR height="40">
							<TD class="style4">
								<P>Title of Import: 
								</P>
							</TD>
							<TD>
								<P><A NAME="title"></A><INPUT TYPE=TEXT NAME="title" SIZE=28 STYLE="width: 2.42in; height: 0.25in"></P>
							</TD>
						</TR>
						<TR height="40">
							<TD class="style4">
								<P>File location: 
								</P>
							</TD>
							<TD>
								<P><A NAME="file"></A><INPUT TYPE=FILE NAME="file" SIZE=56 STYLE="width: 5.41in; height: 0.25in"></P>
							</TD>
						</TR>
						<TR height="40">
							<TD class="style4">
								<P>Username: 
								</P>
							</TD>
							<TD>
								<P><A NAME="user"></A>
								<?php
								if($GLOBALS['login_check'])
								{
									?><INPUT TYPE=Text DISABLED NAME="user_display" value="<?php echo $GLOBALS['username'];?>"><?php
									?><INPUT TYPE=hidden NAME="user" value="<?php echo $GLOBALS['username'];?>"><?php
								}else
								{
									?>
									<INPUT TYPE=TEXT NAME="user" SIZE=28 STYLE="width: 2.42in; height: 0.25in">
									<?php
								}
								?>
								</P>
							</TD>
						</TR>
						<TR>
							<TD class="style4">
								<P>Notes: 
								</P>
							</TD>
							<TD>
								<P><TEXTAREA NAME="notes" ROWS=4 COLS=50 STYLE="width: 4.42in; height: 1.01in"></TEXTAREA><BR>
								</P>
							</TD>
						</TR>
							<TD>.</TD><TD>
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
				<?php
			}else
			{
				echo "Failure to compare tokens, session not set. Try again.<BR>";
			}
		}else
		{
			echo "Failure to compare tokens, token not set. Try again.<BR>";
		}
		break;
	#----------------------
	default: //index page that has form to upload file
		?><h2>Import Access Points</h2><?php
		if (isset($_GET['file']))
		{
			$get_exp = explode('\\\\',$_GET['file']);
			$file_imp = implode('\\', $get_exp);
			echo "<h2>Due to security restrictions in current browsers, file fields cannot have dynamic content, <br> The file that you are trying to import via Vistumbler Is here: <br><b><u>".$file_imp."</u></b><br>Copy and Paste the underlined text into the file location field to import it.<br></h2>";
		}
		echo "<br>Only VS1 Files are Supported at this time.<br>The username is optional, but it helps keep track of who has imported what Access Points<br><br>";
		?>
		<CENTER><form action="?func=import&token=<?php echo $_SESSION['token'];?>" method="post" enctype="multipart/form-data">
			<TABLE BORDER=1 CELLPADDING=2 CELLSPACING=0>
				<TR height="40">
					<TD class="style4">
						<P>Title of Import: 
						</P>
					</TD>
					<TD class="light">
						<P><A NAME="title"></A><INPUT TYPE=TEXT NAME="title" SIZE=28 STYLE="width: 2.42in; height: 0.25in"></P>
					</TD>
				</TR>
				<TR height="40">
					<TD class="style4">
						<P>File location: 
						</P>
					</TD>
					<TD class="light">
						<P><A NAME="file"></A><INPUT TYPE=FILE NAME="file" SIZE=56 STYLE="width: 5.41in; height: 0.25in"></P>
					</TD>
				</TR>
				<TR height="40">
					<TD class="style4">
						<P>Username: 
						</P>
					</TD>
					<TD class="light">
						<P><A NAME="user"></A>
						<?php
						if($GLOBALS['login_check'])
						{
							?><INPUT TYPE=Text DISABLED NAME="user_display" value="<?php echo $GLOBALS['username'];?>"><?php
							?><INPUT TYPE=hidden NAME="user" value="<?php echo $GLOBALS['username'];?>"><?php
						}else
						{
							?>
							<INPUT TYPE=TEXT NAME="user" SIZE=28 STYLE="width: 2.42in; height: 0.25in">
							<?php
						}
						?>
						</P>
					</TD>
				</TR>
				<TR>
					<TD class="style4">
						<P>Notes: 
						</P>
					</TD>
					<TD class="light">
						<P><TEXTAREA NAME="notes" ROWS=4 COLS=50 STYLE="width: 4.42in; height: 1.01in"></TEXTAREA><BR>
						</P>
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
		<?php
		break;
}
footer($_SERVER['SCRIPT_FILENAME']);
?>