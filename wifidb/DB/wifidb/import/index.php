<?php
include('../lib/database.inc.php');
include('../lib/config.inc.php');
pageheader("Import Page");
?></td>
		<td width="80%" bgcolor="#A9C6FA" valign="top" align="center">
			<p align="center">
			<h2>Import Access Points</h2>
<?php

session_start();
$domain = $_SERVER['HTTP_HOST'];
if ($domain === "rihq.randomintervals.com" or $domain === "lanncafe.dynu.com" or $domain === "192.168.3.23")
{echo '<h2>This is my Development server </h2><H4>(which is unstable because I am always working in it)</H4><H2>Go on over to my <i><a href="http://www.randomintervals.com/wifidb/">\'Production Server\'</i></a> for a more stable enviroment</h2>';}
if(isset($_GET['func']))
{
	$func =  $_GET['func'];
}else
{
	$func = '';
}

switch($func)
{
	case 'import':
		if (isset($_POST['token']))
		{
			if (isset($_SESSION['token']) && $_POST['token'] == $_SESSION['token'])
			{
				if($_POST["user"] !== ''){$user = addslashes($_POST["user"]);}else{$user="Unknown";}
				if($_POST["notes"] !== ''){$notes = addslashes($_POST["notes"]);}else{$notes="No Notes";}
				if($_POST['title'] !== ''){$title = addslashes($_POST['title']);}else{$title="Untitled";}

				$tmp	=	$_FILES['file']['tmp_name'];
				$filename	=	$_FILES['file']['name'];

				$rand	=	rand();

				$user = smart_quotes($user);

				$uploaddir = getcwd()."/up/";
				$uploadfile = $uploaddir.$rand.'_'.$filename;

				$return  = file($tmp);
				$VS1Test = str_split($return[0], 12);
				$file_e = explode('.',$filename);
				$file_max = count($file_e);

				if($file_e[$file_max-1] == 'gpx' )
				{
					if (!move_uploaded_file($tmp, $uploadfile))
					{
						echo "Failure to Move file to Upload Dir (/import/up/), check the folder permisions if you are using Linux.<BR>";
						die();
					}

					echo "<h2>Importing GPX File</h2><h1>Imported By: ".$user."<BR></h1>";
					echo "<h2>With Title: ".$title."</h2>";
				#	echo $uploadfile;
					$database = new database();
					$database->import_gpx($uploadfile, $user, $notes, $title );
				}
				elseif($VS1Test[0] == "# Vistumbler" )
				{
					if (!move_uploaded_file($tmp, $uploadfile))
					{
						echo "Failure to Move file to Upload Dir (/import/up/), check the folder permisions if you are using Linux.<BR>";
						footer($_SERVER['SCRIPT_FILENAME']);
						die();
					}

					echo "<h2>Importing VS1 File</h2><h1>Imported By: ".$user."<BR></h1>";
					echo "<h2>With Title: ".$title."</h2>";

					$database = new database();
					$database->import_vs1($uploadfile, $user, $notes, $title );
				}else
				{
					echo '<H1>Hey! You have to upload a valid VS1 or GPX File <A HREF="javascript:history.go(-1)"> [Go Back]</A> and do it again the right way.</h1>';
					footer($_SERVER['SCRIPT_FILENAME']);
					die();
				}

				mysql_select_db($db,$conn);

				$sqls = "SELECT * FROM `users`";
				$result = mysql_query($sqls, $conn) or die(mysql_error());
				$row = mysql_num_rows($result);
				#$database->exp_kml($export="exp_newest_kml");
			}else
			{
				echo "Failure to compare tokens, try again.<BR>";
			}
		}else
		{
			echo "Failure to compare tokens, try again.<BR>";
		}
		break;
	#----------------------
	default:
		if (isset($_GET['file']))
		{
		echo "Due to security restrictions in current browsers, file fields cannot have dynamic content, <br> The file that you are trying to import via Vistumbler Is here: <b>".$_GET['file']."</b><br>Copy and Paste the bolded text into the file location field to import it.<br>";
		}

		echo "<br>Only VS1 Files are Supported at this time.<br>The username is optional, but it helps keep track of who has imported what Access Points<br><br>";
		$token = md5(uniqid(rand(), true));
		$_SESSION['token'] = $token;
		?>
		<CENTER><form action="?func=import" method="post" enctype="multipart/form-data">
			<input type="hidden" name="token" value="<?php echo $token; ?>" />
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
						<P><A NAME="user"></A><INPUT TYPE=TEXT NAME="user" SIZE=28 STYLE="width: 2.42in; height: 0.25in"></P>
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
		break;
}
$filename = $_SERVER['SCRIPT_FILENAME'];
footer($filename);
?>