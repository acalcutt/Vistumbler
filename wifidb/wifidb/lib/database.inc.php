<?php
global $ver;
$ver = array(
			"wifidb"			=>	"0.16 Build 3",
			"Last_Core_Edit" 	=> 	"2009-Jul-08",
			"database"			=>	array(  
										"import_vs1"		=>	"1.7.1", 
										"apfetch"			=>	"2.6.1",
										"gps_check_array"	=>	"1.2",
										"all_users"			=>	"1.2",
										"users_lists"		=>	"1.2",
										"user_ap_list"		=>	"1.2",
										"all_users_ap"		=>	"1.3",
										"exp_kml"			=>	"3.4.0",
										"exp_vs1"			=>	"1.1.0",
										"exp_gpx"			=>	"1.0.0",
										"convert_dm_dd"		=>	"1.3.0",
										"convert_dd_dm"		=>	"1.3.1",
										"manufactures"		=>	"1.0",
										"gen_gps"			=>	"1.0"
										),
			"Misc"				=>	array(
										"pageheader"		=>  "1.2",
										"footer"			=>	"1.2",
										"breadcrumbs"		=>	"1.0",
										"smart_quotes"		=> 	"1.0",
										"smart"				=> 	"1.0",
										"Manufactures-list"	=> 	"2.0",
										"Languages-List"	=>	"1.0",
										"make_ssid"			=>	"1.0",
										"verbosed"			=>	"1.2",
										"logd"				=>	"1.2",
										"IFWC"				=>	"2.0"
										),
			);

#---------------- Install Folder Warning Code -----------------#
function check_install_folder()
{
	include('config.inc.php');
	if(PHP_OS == 'Linux'){ $div = '/';}
	if(PHP_OS == 'WINNT'){ $div = '\\';}
	$path = getcwd();
	$path_exp = explode($div, $path);
	$path_count = count($path_exp);
	foreach($path_exp as $key=>$val)
	{
		if($val == $root){ $path_key = $key;}
	}
	$full_path = '';
	$I = 0;
	if(isset($path_key))
	{
		while($I!=($path_key+1))
		{
			$full_path = $full_path.$path_exp[$I].$div;
			$I++;
		}
		$full_path = $full_path.'install';
		if(is_dir($full_path)){echo '<h2><font color="red">The install Folder is still there, remove it!</font></h2>';}
	}
}

#========================================================================================================================#
#											verbose (Echos out a message to the screen or page)							 #
#========================================================================================================================#

function logd($message = '', $log_interval = 0, $details = 0,  $log_level = 0)
{
	require('config.inc.php');
	if($log_level != 0)
	{
		if($message == ''){echo "Logd was told to write a blank string.\nThis has NOT been logged.\nThis will NOT be allowed!\n"; continue;}
		$date = date("y-m-d");
		$time = time()+$DST;
		$datetime = date("Y-m-d H:i:s",$time);
		$message = $datetime."   ->    ".$message."\r\n";
		include('config.inc.php');
		if($log_interval==1)
		{
			$cidir = getcwd();
			$filename = '/CLI/log/wifidbd_log.log';
			if(!is_file($filename))
			{
				fopen($filename, "w");
			}
			$fileappend = fopen($filename, "a");
			if($log_level == 2 && $details == 0){$log_level = 1;}
			if($log_level == 2)
			{
				$message = $message."\n==Details==\n".$detail."\n===========\n";
			}
			$write_message = fwrite($fileappend, $message);
			if(!$write_message){die("Could not write message to the file, thats not good...");}
		}elseif($log_interval==1)
		{
			$cidir = getcwd();
			$filename = '/CLI/log/wifidbd_'.$date.'_log.log';
			if(!is_file($filename))
			{
				fopen($filename, "w");
			}
			$fileappend = fopen($filename, "a");
			if($log_level == 2 && $details == 0){$log_level = 1;}
			if($log_level == 1)
			{
				$message = $message."\n==Details==\n".$detail."\n===========\n";
			}
			$write_message = fwrite($fileappend, $message);
			if(!$write_message){die("Could not write message to the file, thats not good...");}
		}
	}
}

#========================================================================================================================#
#											log write (writes a message to the log file)								 #
#========================================================================================================================#

function verbosed($message = "", $level = 0, $out="CLI", $header = 0)
{
	require('config.inc.php');
	$time = time()+$DST;
	$datetime = date("Y-m-d H:i:s",$time);
	if($out == "CLI")
	{
		if($message != '')
		{
			if($header == 0)
			{
				$message = $datetime."   ->    ".$message;
			}	
			if($level==1)
			{
				echo $message."\n";
			}
		}else
		{
			echo "Verbose was told to write a blank string";
		}
	}elseif($out == "HTML")
	{
		if($message != '')
		{
			echo $message."<br>";
		}else
		{
			echo "Verbose was told to write a blank string";
		}
	}
}


#========================================================================================================================#
#											regenerateSession (regens Token for a session)								 #
#========================================================================================================================#

function regenerateSession($reload = false)
{
	// This token is used by forms to prevent cross site forgery attempts
	if(!isset($_SESSION['token']) || $reload)
		$_SESSION['token'] = md5(microtime(true));

	if(!isset($_SESSION['IPaddress']) || $reload)
		$_SESSION['IPaddress'] = $_SERVER['REMOTE_ADDR'];

	if(!isset($_SESSION['userAgent']) || $reload)
		$_SESSION['userAgent'] = $_SERVER['HTTP_USER_AGENT'];

	//$_SESSION['user_id'] = $this->user->getId();

	// Set current session to expire in 1 minute
	$_SESSION['OBSOLETE'] = true;
	$_SESSION['EXPIRES'] = time() + 60;

	// Create new session without destroying the old one
	session_regenerate_id(false);

	// Grab current session ID and close both sessions to allow other scripts to use them
	$newSession = session_id();
	session_write_close();

	// Set session ID to the new one, and start it back up again
	session_id($newSession);
	session_start();

	// Don't want this one to expire
	unset($_SESSION['OBSOLETE']);
	unset($_SESSION['EXPIRES']);
	return $_SESSION['token'];
}

#========================================================================================================================#
#									check session (checks to see if a session is live or not)					 		 #
#========================================================================================================================#

function checkSession()
{
	try{
		if($_SESSION['OBSOLETE'] && ($_SESSION['EXPIRES'] < time()))
			throw new Exception('Attempt to use expired session.');
		if(!is_numeric($_SESSION['user_id']))
			throw new Exception('No session started.');
		if($_SESSION['IPaddress'] != $_SERVER['REMOTE_ADDR'])
			throw new Exception('IP Address mixmatch (possible session hijacking attempt).');
		if($_SESSION['userAgent'] != $_SERVER['HTTP_USER_AGENT'])
			throw new Exception('Useragent mixmatch (possible session hijacking attempt).');
		if(!$this->loadUser($_SESSION['user_id']))
			throw new Exception('Attempted to log in user that does not exist with ID: ' . $_SESSION['user_id']);
		if(!$_SESSION['OBSOLETE'] && mt_rand(1, 100) == 1)
		{
			$this->regenerateSession();
		}
		return true;
	}catch(Exception $e){
		return false;
	}
}

#========================================================================================================================#
#									breadcrumb (creates a breadcrumb to follow on each page)							 #
#========================================================================================================================#

function breadcrumb($PATH_INFO)
{
	global $page_title, $root_url;

	// Remove these comments if you like, but only distribute 
	// commented versions.
	
	// Replace all instances of _ with a space
	$PATH_INFO = str_replace("_", " ", $PATH_INFO);
	// split up the path at each slash
	$pathArray = explode("/",$PATH_INFO);
	
	// Initialize variable and add link to home page
	if(!isset($root_url)) { $root_url=""; }
	$breadCrumbHTML = '<a class="links" href="'.$root_url.'/" title="Root">[ Root ]</a> / ';
	
	// initialize newTrail
	$newTrail = $root_url."/";
	
	// starting for loop at 1 to remove root
	for($a=1;$a<count($pathArray)-1;$a++) {
		// capitalize the first letter of each word in the section name
		$crumbDisplayName = ucwords($pathArray[$a]);
		// rebuild the navigation path
		$newTrail .= $pathArray[$a].'/';
		// build the HTML for the breadcrumb trail
		$breadCrumbHTML .= '<a class="links" href="'.$newTrail.'">[ '.$crumbDisplayName.' ]</a> / ';
	}
	// Add the current page
	if(!isset($page_title)) { $page_title = "Current Page"; }
	$breadCrumbHTML .= '<strong>'.$page_title.'</strong>';
	
	// print the generated HTML
	print($breadCrumbHTML);
	
	// return success (not necessary, but maybe the 
	// user wants to test its success?
	return true;
}

#========================================================================================================================#
#											Header (writes the Headers for all pages)									 #
#========================================================================================================================#

function pageheader($title)
{
	session_start();
	if(!isset($_SESSION['token']) or !isset($_GET['token']))
	{
		$token = md5(uniqid(rand(), true));
		$_SESSION['token'] = $token;
	}else
	{
		$token = $_SESSION['token'];
	}

#	$token = regenerateSession();
#	checkSession();
	include('config.inc.php');
	echo '<title>Wireless DataBase *Alpha*'.$GLOBALS['ver']["wifidb"].' --> '.$title.'</title>';
	$sql = "SELECT `id` FROM `$db`.`files`";
	$result1 = mysql_query($sql, $conn);
	check_install_folder();	
	if(!$result1){echo "<font color=\"red\"><h2>You need to <a class=\"upgrade\" href=\"install/upgrade/\">upgrade</a> before you will be able to properly use WiFiDB Build 3.</h3></font>";}
	?>
	<link rel="stylesheet" href="<?php if($root != ''){echo '/'.$root;}?>/css/site4.0.css">
	<body topmargin="10" leftmargin="0" rightmargin="0" bottommargin="10" marginwidth="10" marginheight="10">
	<div align="center">
	<table border="0" width="85%" cellspacing="5" cellpadding="2">
		<tr style="background-color: #315573;">
			<td colspan="2">
			<p align="center"><b>
			<font style="size: 5;font-family: Arial;color: #FFFFFF;">
			Wireless DataBase *Alpha* <?php echo $GLOBALS['ver']['wifidb'].'<br />'; ?>
			<font size="2">
				<?php breadcrumb($_SERVER["REQUEST_URI"]); ?>
			</font></font></b>
			</td>
		</tr>
		<tr>
			<td style="background-color: #304D80;width: 15%;vertical-align: top;">
			<p><a class="links" href="<?php if($root != ''){echo '/'.$root;}?>/?token=<?php echo $token;?>">Main Page</a></p>
			<p><a class="links" href="<?php if($root != ''){echo '/'.$root;}?>/all.php?sort=SSID&ord=ASC&from=0&to=100&token=<?php echo $token;?>">View All APs</a></p>
			<p><a class="links" href="<?php if($root != ''){echo '/'.$root;}?>/import/?token=<?php echo $token;?>">Import</a></p>
			<p><a class="links" href="<?php if($root != ''){echo '/'.$root;}?>/opt/scheduling.php?token=<?php echo $token;?>">Files Waiting for Import</a></p>
			<p><a class="links" href="<?php if($root != ''){echo '/'.$root;}?>/opt/export.php?func=index&token=<?php echo $token;?>">Export</a></p>
			<p><a class="links" href="<?php if($root != ''){echo '/'.$root;}?>/opt/search.php?token=<?php echo $token;?>">Search</a></p>
			<p><a class="links" href="<?php if($root != ''){echo '/'.$root;}?>/opt/userstats.php?func=allusers&token=<?php echo $token;?>">View All Users</a></p>
			<p><a class="links" href="<?php if($root != ''){echo '/'.$root;}?>/ver.php?token=<?php echo $token;?>">WiFiDB Version</a></p>
			<p><a class="links" href="<?php if($root != ''){echo '/'.$root;}?>/down.php?token=<?php echo $token;?>">Download WiFiDB</a></p>
		</td>
		<td style="background-color: #A9C6FA;width: 80%;vertical-align: top;" align="center"><br>
		<?php
}

#========================================================================================================================#
#											Footer (writes the footer for all pages)									 #
#========================================================================================================================#

function footer($filename = '')
{
	include('config.inc.php');
	$file_ex = explode("/", $filename);
	$count = count($file_ex);
	$file = $file_ex[($count)-1];
	?>
	</td>
	</tr>
	<tr>
	<td bgcolor="#315573" height="23"><a href="/<?php echo $root; ?>/img/moon.png"><img border="0" src="/<?php echo $root; ?>/img/moon_tn.png"></a></td>
	<td bgcolor="#315573" width="0" align="center">
	<?php
	if (file_exists($filename)) {?>
		<h6><i><u><?php echo $file;?></u></i> was last modified:  <?php echo date ("Y F d @ H:i:s", filemtime($filename));?></h6>
	<?php
	}
	echo $tracker;
	echo $ads;
	?>
	</td>
	</tr>
	</table>
	</body>
	</html>
	<?php
}

#========================================================================================================================#
#													Smart Quotes (char filtering)										 #
#========================================================================================================================#

function smart_quotes($text="") // Used for SSID Sanatization
{
	$pattern = '/"((.)*?)"/i';
	$strip = array(
					0=>".",
					1=>"*",
					2=>"?",
					3=>"<",
					4=>">",
					5=>'"',
					6=>"'",
					7=>"$",
					8=>"?>",
					9=>";",
					10=>"#",
					11=>"&",
					12=>"=",
					13=>"~",
					14=>"^",
					15=>"`",
					16=>"+",
					17=>"%",
					18=>"!",
					19=>"@",
					20=>"-",
					21=>"/",
					22=>"ÿ",
					23=>""
				);
	$text = preg_replace($pattern,"&#147;\\1&#148;",stripslashes($text));
	$text = str_replace($strip,"_",$text);
	return $text;
}

#========================================================================================================================#
#													Smart (filtering for GPS)											 #
#========================================================================================================================#

function smart($text="") // Used for GPS
{
	$pattern = '/"((.)*?)"/i';
	$strip = array(
					0=>" ",
					1=>":",
					2=>"-",
					3=>".",
					4=>"N",
					5=>"E",
					6=>"W",
					7=>"S"
				  );
	$text = preg_replace($pattern,"&#147;\\1&#148;",stripslashes($text));
	$text = str_replace($strip,"",$text);
	return $text;
}

#========================================================================================================================#
#							dos_filesize (gives file size for either windows or linux machines)				 			 #
#========================================================================================================================#

function dos_filesize($fn) 
{
	if(PHP_OS == "WINNT")
	{
		if (is_file($fn))
			return exec('FOR %A IN ("'.$fn.'") DO @ECHO %~zA');
		else
			return '0';
	}else
	{
		return filesize($fn);
	}
}

#========================================================================================================================#
#							format_size (formats bytes based size to B, kB, MB, GB... and so on)					 	 #
#========================================================================================================================#

function format_size($size, $round = 2)
{
	//Size must be bytes!
	$sizes = array('B', 'kB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB');
	for ($i=0; $size > 1024 && $i < count($sizes) - 1; $i++) $size /= 1024;
	return round($size,$round).$sizes[$i];
}

#========================================================================================================================#
#							make ssid (makes a DB safe, File safe and Unsan versions of an SSID)			 			 #
#========================================================================================================================#

function make_ssid($ssid_frm_src_or_pnt_tbl = '')
{
	$ssids = filter_var($ssid_frm_src_or_pnt_tbl, FILTER_SANITIZE_SPECIAL_CHARS);
	$ssid_safe_full_length = smart_quotes($ssids);
	$ssid_sized = str_split($ssid_safe_full_length,25); //split SSID in two on is 25 char long.
	$ssid_table_safe = $ssid_sized[0]; //Use the 25 char long word for the APs table name, this is due to a limitation in MySQL table name lengths, 
	if($ssid_table_safe == ''){$ssid_table_safe = "UNNAMED";}
	if($ssids == ''){$ssids = "UNNAMED";}
	$A = array(0=> $ssid_table_safe, 1=>$ssid_safe_full_length , 2=> $ssids,);
	return $A;
}


	
	#========================================================================================================================#
	#																														 #
	#									WiFiDB Database Class that holds DB based functions									 #
	#																														 #
	#========================================================================================================================#



class database
{
	#========================================================================================================================#
	#										gen_gps (generate GPS cords from a VS1 file to Array)				 			 #
	#========================================================================================================================#

	function gen_gps($retexp = array(), $gpscount = 0)
	{
		$ret_len = count($retexp);
		switch ($ret_len)
		{
			case 6:
				$retexp[1]	=	filter_var($retexp[1], FILTER_SANITIZE_SPECIAL_CHARS, FILTER_FLAG_STRIP_LOW);
				$retexp[2]	=	filter_var($retexp[2], FILTER_SANITIZE_SPECIAL_CHARS, FILTER_FLAG_STRIP_LOW);
				$retexp[3]	=	filter_var($retexp[3], FILTER_SANITIZE_SPECIAL_CHARS, FILTER_FLAG_STRIP_LOW);
				$retexp[4]	=	filter_var($retexp[4], FILTER_SANITIZE_SPECIAL_CHARS, FILTER_FLAG_STRIP_LOW);
				$retexp[5]	=	filter_var($retexp[5], FILTER_SANITIZE_SPECIAL_CHARS, FILTER_FLAG_STRIP_LOW);
				$date_exp = explode("-",$retexp[4]);
				if(strlen($date_exp[0]) <= 2)
				{
					$gpsdate = $date_exp[2]."-".$date_exp[0]."-".$date_exp[1];
				}else
				{
					$gpsdate = $retexp[4];
				}
				# GpsID|Latitude|Longitude|NumOfSatalites|Date(UTC y-m-d)|Time(UTC h:m:s)
				$gdata = array(
											"lat"=>$retexp[1],
											"long"=>$retexp[2],
											"sats"=>$retexp[3],
											"hdp"=>'0.0',
											"alt"=>'0.0',
											"geo"=>'-0.0',
											"kmh"=>'0.0',
											"mph"=>'0.0',
											"track"=>'0.0',
											"date"=>$gpsdate,
											"time"=>$retexp[5]
											);
				$gpscount++;
				break;
			case 12:
				$retexp[1]	=	filter_var($retexp[1], FILTER_SANITIZE_SPECIAL_CHARS, FILTER_FLAG_STRIP_LOW);
				$retexp[2]	=	filter_var($retexp[2], FILTER_SANITIZE_SPECIAL_CHARS, FILTER_FLAG_STRIP_LOW);
				$retexp[3]	=	filter_var($retexp[3], FILTER_SANITIZE_SPECIAL_CHARS, FILTER_FLAG_STRIP_LOW);
				$retexp[4]	=	filter_var($retexp[4], FILTER_SANITIZE_SPECIAL_CHARS, FILTER_FLAG_STRIP_LOW);
				$retexp[5]	=	filter_var($retexp[5], FILTER_SANITIZE_SPECIAL_CHARS, FILTER_FLAG_STRIP_LOW);
				$retexp[6]	=	filter_var($retexp[1], FILTER_SANITIZE_SPECIAL_CHARS, FILTER_FLAG_STRIP_LOW);
				$retexp[7]	=	filter_var($retexp[2], FILTER_SANITIZE_SPECIAL_CHARS, FILTER_FLAG_STRIP_LOW);
				$retexp[8]	=	filter_var($retexp[3], FILTER_SANITIZE_SPECIAL_CHARS, FILTER_FLAG_STRIP_LOW);
				$retexp[9]	=	filter_var($retexp[4], FILTER_SANITIZE_SPECIAL_CHARS, FILTER_FLAG_STRIP_LOW);
				$date_exp = explode("-",$retexp[10]);
				if(strlen($date_exp[0]) <= 2)
				{
					$gpsdate = $date_exp[2]."-".$date_exp[0]."-".$date_exp[1];
				}else
				{
					$gpsdate = $retexp[10];
				}
				# GpsID|Latitude|Longitude|NumOfSatalites|HorDilPitch|Alt|Geo|Speed(km/h)|Speed(MPH)|TrackAngle|Date(UTC y-m-d)|Time(UTC h:m:s)
				$gdata = array(
											"lat"=>$retexp[1],
											"long"=>$retexp[2],
											"sats"=>$retexp[3],
											"hdp"=>$retexp[4],
											"alt"=>$retexp[5],
											"geo"=>$retexp[6],
											"kmh"=>$retexp[7],
											"mph"=>$retexp[8],
											"track"=>$retexp[9],
											"date"=>$gpsdate,
											"time"=>$retexp[11]
											);
				$gpscount++;
				break;
			default :
				$gdata = array(
											"lat"=>"N 0.0000",
											"long"=>"E 0.0000",
											"sats"=>"00",
											"hdp"=>"0",
											"alt"=>"0",
											"geo"=>"0",
											"kmh"=>"0",
											"mph"=>"0",
											"track"=>"0",
											"date"=>"1970-06-17",
											"time"=>"12:00:00"
											);
				$gpscount++;
		}
		$list = array(0=>$gdata, 1=> $gpscount);
		return $list;
	}

	#========================================================================================================================#
	#						check file (check to see if a file has already been imported into the DB)			 			 #
	#========================================================================================================================#

	function check_file($file = '')
	{
		include($GLOBALS['wifidb_install'].$GLOBALS['dim'].'lib'.$GLOBALS['dim'].'config.inc.php');
#		$file = $GLOBALS['wifidb_install'].$GLOBALS['dim'].'import'.$GLOBALS['dim'].'up'.$GLOBALS['dim'].$file;
		$hash = hash_file('md5', $file);
		$file_exp = explode($GLOBALS['dim'], $file);
		$file_exp_seg = count($file_exp);
		$file1 = $file_exp[$file_exp_seg-1];
		$file2 = trim(strstr($file1, '_'), "_");
		mysql_select_db($db,$GLOBALS['conn']);
		$sql = "SELECT * FROM `files` WHERE `file` LIKE '%$file2'";
		$fileq = mysql_query($sql, $GLOBALS['conn']);
		$fileqq = mysql_fetch_array($fileq);
		if( strcmp($hash ,$fileqq['hash']) == 0 )
		{
			return 0;
		}else
		{
			return 1;
		}
	}

	#========================================================================================================================#
	#							insert file (put a file that was just imported into the Files table)				 			 #
	#========================================================================================================================#

	function insert_file($file = '', $totalaps = 0, $totalgps = 0, $user = "Unknown", $notes = "No Notes", $title = "Untitled", $user_row = 0)
	{
		include('config.inc.php');
		$size = (filesize($file)/1024);
		$hash = hash_file('md5', $file);
		$date = date("y-m-d H:i:s");
		mysql_select_db($db,$conn);
		
		$file_exp = explode("/", $file);
		$file_exp_seg = count($file_exp);
		$file1 = $file_exp[$file_exp_seg-1];
		
		$sql = "INSERT INTO `wifi`.`files` ( `id` , `file` , `size` , `date` , `aps` , `gps` , `hash` , `user` , `notes` , `title`, `user_row`	)
									VALUES ( NULL , '$file1', '$size', '$date' , '$totalaps', '$totalgps', '$hash' , '$user' , '$notes' , '$title', '$user_row' )";
		if(mysql_query($sql, $conn))
		{
			return 1;
		}else
		{
			$A = array( 0=>'0', 'error' => mysql_error($conn));
			return $A;
		}
	}

	#========================================================================================================================#
	#						Grab the Manuf for a given MAC, return Unknown Manuf if not found								 #
	#========================================================================================================================#
	function &manufactures($mac="")
	{
		include('manufactures.inc.php');
		$man_mac = str_split($mac,6);
		if(isset($manufactures[$man_mac[0]]))
		{
			$manuf = $manufactures[$man_mac[0]];
		}
		else
		{
			$manuf = "Unknown Manufacture";
		}
		return $manuf;
	}

	#========================================================================================================================#
	#											import GPX (Import Garmin Based GPX files)						 			 #
	#========================================================================================================================#

	function import_gpx($source="" , $user="Unknown" , $notes="No Notes" , $title="UNTITLED" )
	{
		$start = microtime(true);
		$times=date('Y-m-d H:i:s');
		
		if ($source == NULL){?><h2>You did not submit a file, please <A HREF="javascript:history.go(-1)"> [Go Back]</A> and do so.</h2> <?php die();}
		
		include('../lib/config.inc.php');
		
		$apdata  = array();
		$gpdata  = array();
		$signals = array();
		$sats_id = array();
		
		$fileex  = explode(".", $source);
		$return  = file($source);
		$count = count($return);
		$rettest = substr($return[1], 1, -1);
		
		if ($rettest = 'gpx xmlns="http://www.topografix.com/GPX/1/1" creator="Vistumbler 9.3 Beta 2" version="1.1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd"')
		{	
			echo $rettest."<br>";
		}else
		{
			echo '<h1>You need to upload a valid GPX file, go look up the santax for it, or the file that you saved is corrupted</h1>';
		}
	}
	
	#========================================================================================================================#
	#													VS1 File import													     #
	#========================================================================================================================#
	
	function import_vs1($source="" , $user="Unknown" , $notes="No Notes" , $title="UNTITLED", $verbose = 0 , $out = "CLI")
	{
		#MESSAGES FOR CLI AND HTML INTERFACES#
		$wrong_file_type_msg			= "There is something wrong with the file you uploaded, check and make sure it is a valid VS1 file and try again.";
		$Inserted_user_data_good_msg	= "Succesfully Inserted User data into Users table.";
		$failed_import_user_data_msg	= "Failed to Insert User data into Users table.";
		$text_file_support_ms			= "Text files are no longer supported, please save your list as a VS1 file or use the Extra->Wifidb menu option in Vistumbler.";
		$error_updating_pts_msg			= "Error Updating Pointers table with new AP.";
		$error_updating_stgs_msg		= "Error Updating Settings table with new size.";
		$updating_stgs_good_msg			= "Updated Settings table with new size.";
		$error_retrev_file_name_CLI_msg = "There was an error sending the file name to the function.";
		$error_retrev_file_name_HTML_msg = "You did not submit a file, please <A HREF=\"javascript:history.go(-1)\"> [- Go Back -]</A> and do so.";
		$emtpy_file_err_msg				= "You cannot upload an empty VS1 file, at least scan for a few seconds to import some data.";
		$error_reserv_user_row			= "Could not reserve user import row!";
		$no_aps_in_file_msg				= "This File does not have any APs to import, just a bunch of GPS cords.";
		$updated_tmp_table_msg			= "Updated files_tmp table with this runs data.";
		$too_many_unique_aps_error_msg	= "There are too many Pointers for this one Access Point, defaulting to the first one in the list.";
		$being_updated_msg				= "is being updated.";
		$error_running_gps_check_msg	= "There was an error running gps check.";
		$failed_gps_add					= "FAILED to added GPS History to Table";
		$being_imported_msg				= "is being imported";
		$failed_insert_sig_msg			= "FAILED to insert the Signal data.";
		$failed_insert_gps_msg			= "FAILED to insert the GPS data.";
		$failed_create_gps_msg			= "FAILED to create the GPS History Table.";
		$failed_create_sig_msg			= "FAILED to create Signal History Table";
		$Finished_inserting_sig_msg		= "Finished Inserting Signal History into its table";
		$Error_inserting_sig_msg		= "Error inserting signal history into its table";
		$text_files_support_msg			= "Text Files are not longer supported, either re-export it from Vistumbler or use the converter.exe";
		$insert_new_gps_msg				= "Error inserting new GPS point";
		$removed_old_gps_msg			= "Error removing old GPS point";
		
		
		if($out == "HTML"){$verbose = 1;}
		if ($source == NULL)
		{
			logd($error_retrev_file_name_CLI_msg."\r\n", $log_interval, 0,  $log_level);
			if($out=="CLI")
			{
				verbosed($GLOBALS['COLORS']['RED'].$error_retrev_file_name_CLI_msg."\r\n".$GLOBALS['COLORS']['WHITE'], $verbose, "CLI");
				break;
			}elseif($out=="HTML")
			{
				verbosed("<h2>".$error_retrev_file_name_HTML_msg."</h2>", $verbose);
				if($out == "HTML"){footer($_SERVER['SCRIPT_FILENAME']);}die();
			}
		}
		$return  = file($source);
		$count = count($return);
		
		$file_row =  0;
		require $GLOBALS['wifidb_install']."/lib/config.inc.php";
		require 'config.inc.php';
		
		$file_exp = explode("/", $source);
		$file_exp_seg = count($file_exp);
		$file1 = $file_exp[$file_exp_seg-1];
		
		$FILENUM = 1;
		$start = microtime(true);
		$times=date('Y-m-d H:i:s');
		
		$user_n	 = 0;
		$N		 = 0;
		$n		 = 0;
		$gpscount= 0;
		$co		 = 0;
		$cco	 = 0;
		$updated = 0;
		$imported = 0;
		$apdata  = array();
		$gpdata  = array();
		$signals = array();
		$sats_id = array();
		
		$return  = file($source);
		$count = count($return);
		
		$file_row =  0;
		if($count <= 8) 
		{
			logd($empty_file_err_msg."\r\n", $log_interval, 0,  $log_level);
			if($out=="CLI")
			{
				verbosed($GLOBALS['COLORS']['RED'].$empty_file_err_msg."\n".$GLOBALS['COLORS']['WHITE'], $verbose, "CLI");
				break;
			}elseif($out=="HTML")
			{
				verbosed("<h2>".$empty_file_err_msg."</h2>", $verbose);
				if($out == "HTML"){footer($_SERVER['SCRIPT_FILENAME']);}die();
			}
		}
		mysql_select_db($db,$conn);
		
		
#		$result = mysql_query("SELECT `row` FROM `$db`.`files_tmp` WHERE `file` LIKE '$file1' LIMIT 1", $conn);
#		$newArray = mysql_fetch_array($result);
		$sqlu = "INSERT INTO `$db`.`users` ( `id` , `username` , `points` ,  `notes`, `date`, `title` , `aps`, `gps`) VALUES ( '', '$user', '','$notes', '', '$title', '', '')";
		$user_row_new_result = mysql_query("SELECT `id` FROM `$db`.`users` ORDER BY `id` DESC LIMIT 1", $conn);
		if(!$user_row_new_result)
		{
			logd($error_reserv_user_row."!\r\n".mysql_error($conn), $log_interval, 0,  $log_level);
			if($out=="CLI")
			{
				verbosed($GLOBALS['COLORS']['RED'].$error_reserv_user_row."\n".$GLOBALS['COLORS']['WHITE'].mysql_error($conn), $verbose, "CLI");
				if($out == "HTML"){footer($_SERVER['SCRIPT_FILENAME']);}die();
			}elseif($out=="HTML")
			{
				verbosed("<p>".$error_reserv_user_row."</p>".mysql_error($conn), $verbose);
				if($out == "HTML"){footer($_SERVER['SCRIPT_FILENAME']);}die();
			}
		}
		$user_row_result = mysql_query("SELECT `id` FROM `$db`.`users` ORDER BY `id` DESC LIMIT 1", $conn);
		$user_row_array = mysql_fetch_array($user_row_result);
		$user_row_id = $user_row_array['id'];  //STILL NEED TO IMPLEMENT THIS, ONLY JUST STARTED
		
		foreach($return as $ret)
		{
#			if($file_row != $newArray['row'] AND $newArray['row'] != 0 AND $newArray['row'] >= $file_row )
#			{
#				continue;
#			}else
#			{
#				$file_row++;
#			}
			if ($ret[0] == "#"){continue;}
			
			$retexp = explode("|",$ret);
			$ret_len = count($retexp);
			
			if ($ret_len == 12 or $ret_len == 6)
			{
				list($gdata[$retexp[0]], $gpscount) = database::gen_gps($retexp, $gpscount);
			}elseif($ret_len == 13)
			{
					if(!isset($SETFLAGTEST))
					{
						$count1 = $count - $gpscount;
						$count1 = $count1 - 8;
						if($count1 == 0) 
						{
							logd($no_aps_in_file_msg."\r\n", $log_interval, 0,  $log_level);
							if($out=="CLI")
							{
								verbosed($GLOBALS['COLORS']['RED'].$no_aps_in_file_msg."\n".$GLOBALS['COLORS']['WHITE'], $verbose, "CLI");
								if($out == "HTML"){footer($_SERVER['SCRIPT_FILENAME']);}die();
							}elseif($out=="HTML")
							{
								verbosed("<p>".$no_aps_in_file_msg."</p>", $verbose);
								if($out == "HTML"){footer($_SERVER['SCRIPT_FILENAME']);}die();
							}
						}
					}
					$SETFLAGTEST = TRUE;
					$wifi = explode("|",$ret, 13);
					if($wifi[0] == "" && $wifi[1] == "" && $wifi[5] == "" && $wifi[6] == "" && $wifi[7] == ""){continue;}
					mysql_select_db($db,$conn);
					$dbsize = mysql_query("SELECT `id` FROM `$db`.`$wtable` ORDER BY `id` DESC LIMIT 1", $GLOBALS['conn']);
					$size1 = mysql_fetch_array($dbsize);
					$size = $size1['id']+0;
					$size++;
					
					//You cant have any blank data, thats just rude...
					if($wifi[0] == ''){$wifi[0]="UNNAMED";}
					if($wifi[1] == ''){$wifi[1] = "00:00:00:00:00:00";}
					if($wifi[5] == ''){$wifi[5] = "0";}
					if($wifi[6] == ''){$wifi[6] = "u";}
					if($wifi[7] == ''){$wifi[7] = "0";}
					
					// sanitize wifi data to be used in table name
					$ssids = filter_var($wifi[0], FILTER_SANITIZE_SPECIAL_CHARS);
					$ssidss = smart_quotes($ssids);
					$ssidsss = str_split($ssidss,25); //split SSID in two at is 25th char.
					$ssid_S = $ssidsss[0]; //Use the 25 char long word for the APs table name, this is due to a limitation in MySQL table name lengths, 
										  //the rest of the info will suffice for unique table names
					if($out=="CLI")
					{
						$this_of_this = $FILENUM." / ".$count1;
						$sqlup = "UPDATE `files_tmp` SET `importing` = '1', `tot` = '$this_of_this', `ap` = '$ssids', `row` = '$file_row' WHERE `file` = '$file1';";
						if (mysql_query($sqlup, $conn) or die(mysql_error($conn)))
						{
							logd($updated_tmp_table_msg."\r\n", $log_interval, 0,  $log_level);
							verbosed($GLOBALS['COLORS']['GREEN'].$updated_tmp_table_msg."\n".$GLOBALS['COLORS']['WHITE'], $verbose, "CLI");
						}
					}
					$mac1 = explode(':', $wifi[1]);
					$macs = $mac1[0].$mac1[1].$mac1[2].$mac1[3].$mac1[4].$mac1[5]; //the APs table doesnt need :'s in its name, nor does the Pointers table, well it could I just dont want to
					
					$auth		=	filter_var($wifi[3], FILTER_SANITIZE_SPECIAL_CHARS);
					$encry		=	filter_var($wifi[4], FILTER_SANITIZE_SPECIAL_CHARS);
					$sectype	=	filter_var($wifi[5], FILTER_SANITIZE_SPECIAL_CHARS);
					$chan		=	filter_var($wifi[7], FILTER_SANITIZE_SPECIAL_CHARS);
					$chan		=	$chan+0;
					$btx		=	filter_var($wifi[8], FILTER_SANITIZE_SPECIAL_CHARS);
					$otx		=	filter_var($wifi[9], FILTER_SANITIZE_SPECIAL_CHARS);
					$nt			=	filter_var($wifi[10], FILTER_SANITIZE_SPECIAL_CHARS);
					$label		=	filter_var($wifi[11], FILTER_SANITIZE_SPECIAL_CHARS);
					$san_sig	=	filter_var($wifi[12], FILTER_SANITIZE_SPECIAL_CHARS);
					
					$san_sig	=	str_replace("&#13;&#10;","",$san_sig);
					$NUM_SIG = explode("-",$san_sig);
					foreach($NUM_SIG as $key=>$val)
					{
						$num_san_sig = explode(",",$val);
						$NUM_SIG[$key] = ($num_san_sig[0]+0).",".($num_san_sig[1]+0);
					}
					$san_sig = implode("-",$NUM_SIG);
					
					if($wifi[6] == "802.11a")
						{$radios = "a";}
					elseif($wifi[6] == "802.11b")
						{$radios = "b";}
					elseif($wifi[6] == "802.11g")
						{$radios = "g";}
					elseif($wifi[6] == "802.11n")
						{$radios = "n";}
					else
						{$radios = "U";}
					
					$conn1 = mysql_connect($host, $db_user, $db_pwd);
					mysql_select_db($db,$conn1);
					$result = mysql_query("SELECT * FROM `$db`.`$wtable` WHERE `mac` LIKE '$macs' AND `ssid` LIKE '$ssidss' AND `chan` LIKE '$chan' AND `sectype` LIKE '$sectype' AND `radio` LIKE '$radios' LIMIT 1", $conn1) or die(mysql_error($conn1));
					$rows = mysql_num_rows($result);
					$newArray = mysql_fetch_array($result);
					$APid = $newArray['id'];
					$ssid_pt = $newArray['ssid'];
					$ssid_pt_s = smart_quotes($ssid_pt);
					$ssid_pt_ss = str_split($ssid_pt_s,25); //split SSID in two at is 25th char.
					$ssid_pt_S = $ssid_pt_ss[0];
					
					$mac_pt = $newArray['mac'];
					$sectype_pt = $newArray['sectype'];
					$radio_pt = $newArray['radio'];
					$chan_pt = $newArray['chan'];
					$auth_pt = $newArray['auth'];
					$encry_pt = $newArray['encry'];
					
					mysql_close($conn1);
					$table_ptb = $ssid_pt_S.'-'.$mac_pt.'-'.$sectype_pt.'-'.$radio_pt.'-'.$chan_pt;
					//create table name to select from, insert into, or create
					$table = $ssid_S.'-'.$macs.'-'.$sectype.'-'.$radios.'-'.$chan;
					$gps_table = $table.$gps_ext;
					
					if(!isset($table_ptb)){$table_ptb="";}
					
					if($table == $table_ptb)
					{
	#################################################################################################################################################################
	#################################################################################################################################################################
	#										UPDATE AP									#
	#################################################################################################################################################################
	#################################################################################################################################################################
						logd($this_of_this."   ( ".$APid." )   ||   ".$table." - ".$being_updated_msg."\r\n".mysql_error($conn), $log_interval, 0,  $log_level);
						if($out=="CLI")
						{
							verbosed($GLOBALS['COLORS']['GREEN'].$this_of_this."   ( ".$APid." )   ||   ".$table." - ".$being_updated_msg.".\n".$GLOBALS['COLORS']['WHITE'], $verbose, "CLI");
						}elseif($out=="HTML")
						{
							verbosed('<table border="1" width="90%" class="update"><tr class="style4"><th>ID</th><th>New/Update</th><th>SSID</th><th>Mac Address</th><th>Authentication</th><th>Encryption</th><th>Radion Type</th><th>Channel</th></tr>
									<tr><td>'.$APid.'</td><td><b>U</b></td><td>'.$ssids.'</td><td>'.$macs.'</td><td>'.$auth.'</td><td>'.$encry.'</td><td>'.$radios.'</td><td>'.$chan.'</td></tr><tr><td colspan="8">', $verbose, "HTML");
						}
						mysql_select_db($db_st,$conn);
						//setup ID number for new GPS cords
						$DB_result = mysql_query("SELECT * FROM `$db_st`.`$gps_table`", $conn);
						$gpstableid = mysql_num_rows($DB_result);
						if ( $gpstableid == 0)
						{
							$gps_id = 1;
						}
						else
						{
							//if the table is already populated set it to the last ID's number
							$gps_id = $gpstableid+0;
							$gps_id++;
						}
						//pull out all GPS rows to be tested against for duplicates
						
						echo "GPS points already in table: ".$gpstableid." - GPS_ID: ".$gps_id."\n";
						
						$N=0;
						$prev='';
						$sql_multi = array();
						$signal_exp = explode("-",$san_sig);
						$NNN = 0;
						$sig_counting = count($signal_exp)-1;
						$DBresult = mysql_query("SELECT * FROM `$db_st`.`$gps_table`", $conn);
						while ($neArray = mysql_fetch_array($DBresult))
						{
							$db_gps[$neArray["id"]]["id"]=$neArray["id"];
							$db_gps[$neArray["id"]]["lat"]=$neArray["lat"];
							$db_gps[$neArray["id"]]["long"]=$neArray["long"];
							$db_gps[$neArray["id"]]["sats"]=$neArray["sats"];
							$db_gps[$neArray["id"]]["date"]=$neArray["date"];
							$db_gps[$neArray["id"]]["time"]=$neArray["time"];
						}
						foreach($signal_exp as $key=>$exp)
						{
							$NNN++;
#							echo "Pre loop: ".$gps_id."\n".$dbid."\n";
							//Create GPS Array for each Singal, because the GPS table is growing for each signal you need to re-grab it to test the data
							
							
							$esp = explode(",",$exp);
							$vs1_id = $esp[0];
							$signal = $esp[1];
							
							$lat = $gdata[$vs1_id]["lat"];
							$long = $gdata[$vs1_id]["long"];
							$sats = $gdata[$vs1_id]["sats"];
							$date = $gdata[$vs1_id]["date"];
							$time = $gdata[$vs1_id]["time"];
							$hdp = $gdata[$vs1_id]["hdp"];
							$alt = $gdata[$vs1_id]["alt"];
							$geo = $gdata[$vs1_id]["geo"];
							$kmh = $gdata[$vs1_id]["kmh"];
							$mph = $gdata[$vs1_id]["mph"];
							$track = $gdata[$vs1_id]["track"];
							
							$lat1 = smart($lat);
							$long1 = smart($long);
							$time1 = smart($time);
							$date1 = smart($date);
							
							$comp = $lat1."".$long1."".$date1."".$time1;
							if(!isset($db_gps)){$db_gps = array();}
							list($return_gps, $dbid) = database::check_gps_array($db_gps,$comp, $gps_table);
							if ($prev == $vs1_id)
							{
								$gps_id_ = $gps_id-1;
								$signals[$N] = $gps_id_.",".$signal;
			#					echo "Same as Pre: ".$signals[$N]."\n";
							#	$gps_id++;
								$N++;
								if($verbose == 1 && $out == "CLI"){echo ".";}
								continue;
							}
							$DBresult = mysql_query("SELECT * FROM `$gps_table` WHERE `id` = '$dbid'", $conn);
							$GPSDBArray = mysql_fetch_array($DBresult);
							if($return_gps === 1 && $dbid != 0)
							{
								if($sats > $GPSDBArray['sats'] && $GPSDBArray['id'] != 0)
								{
									$sql_D = "DELETE FROM `$db_st`.`$gps_table` WHERE `$gps_table`.`id` = '$dbid' AND `$gps_table`.`lat` LIKE '$lat' AND `$gps_table`.`long` = '$long' LIMIT 1";
									$DBresult1 = mysql_query($sql_D, $conn);
									if(!$DBresult1)
									{
										logd($removed_old_gps_msg.".\r\n", $log_interval, 0,  $log_level);
										if($out=="CLI")
										{
											verbosed($GLOBALS['COLORS']['GREEN'].$removed_old_gps_msg.".\n".$GLOBALS['COLORS']['WHITE'], $verbose, "CLI");
										}elseif($out=="HTML")
										{
											verbosed("<p>".$removed_old_gps_msg."</p>", $verbose, "HTML");
										}
										die();
									}
									
									$sql_U = "INSERT INTO `$gps_table` ( `id` , `lat` , `long` , `sats`, `hdp`, `alt`, `geo`, `kmh`, `mph`, `track` , `date` , `time` ) VALUES ( '$dbid', '$lat', '$long', '$sats', '$hdp', '$alt', '$geo', '$kmh', '$mph', '$track', '$date', '$time')";
									$DBresult2 = mysql_query($sql_U, $conn);
									if(!$DBresult2)
									{
										logd($insert_new_gps_msg.".\r\n", $log_interval, 0,  $log_level);
										if($out=="CLI")
										{
											verbosed($GLOBALS['COLORS']['GREEN'].$insert_new_gps_msg.".\n".$GLOBALS['COLORS']['WHITE'], $verbose, "CLI");
										}elseif($out=="HTML")
										{
											verbosed("<p>".$insert_new_gps_msg."</p>", $verbose, "HTML");
										}
										die();
									}
									$signals[$N] = $dbid.",".$signal;
			#						echo "Update DB: ".$signals[$N]."\n";
									if($verbose == 1 && $out == "CLI"){echo ".";}
									$N++;
									$prev = $vs1_id;
									continue;
								#	echo "Update DB: ".$dbid."\n";
								}else
								{
									$signals[$N] = $dbid.",".$signal;
			#						echo "In DB: ".$signals[$N]."\n";
									if($verbose == 1 && $out == "CLI"){echo ".";}
									$N++;
									$prev = $vs1_id;
									continue;
								#	echo "Already in DB: ".$dbid."\n";
								}
							}elseif($return_gps === 0 or $dbid == 0)
							{
								$sql_U = "INSERT INTO `$db_st`.`$gps_table` ( `id` , `lat` , `long` , `sats`, `hdp`, `alt`, `geo`, `kmh`, `mph`, `track` , `date` , `time` ) "
																		."VALUES ( '$gps_id', '$lat', '$long', '$sats', '$hdp', '$alt', '$geo', '$kmh', '$mph', '$track', '$date', '$time')";
								
								$DBresult0 = mysql_query($sql_U, $conn);
								if(!$DBresult0)
								{
									logd($insert_new_gps_msg.".\r\n", $log_interval, 0,  $log_level);
									if($out=="CLI")
									{
										verbosed($GLOBALS['COLORS']['GREEN'].$insert_new_gps_msg.".\n".$GLOBALS['COLORS']['WHITE'], $verbose, "CLI");
									}elseif($out=="HTML")
									{
										verbosed("<p>".$insert_new_gps_msg."</p>", $verbose, "HTML");
									}
									die();
								}
								$signals[$N] = $gps_id.",".$signal;
		#						echo "New GPS: ".$signals[$N]."\n";
								#echo "New GPS: ".$gps_id."\n";
							}else
							{
								logd($error_running_gps_check_msg.".\r\n".mysql_error($conn), $log_interval, 0,  $log_level);
								if($out=="CLI")
								{
									verbosed($GLOBALS['COLORS']['RED'].$error_running_gps_check_msg.".\n".$GLOBALS['COLORS']['WHITE'].mysql_error($conn), $verbose, "CLI");
								}elseif($out=="HTML")
								{
									verbosed("<p>".$error_running_gps_check_msg."</p>".mysql_error($conn), $verbose, "HTML");
								}
								if($out == "HTML"){footer($_SERVER['SCRIPT_FILENAME']);}die();
							}
							if($verbose == 1 && $out == "CLI"){echo ".";}
							$gps_id++;
							$N++;
							$prev = $vs1_id;
						}
						if($verbose == 1 && $out == "CLI"){echo "\n";}
						
						
						
				#		$mysqli = new mysqli($host, $db_user, $db_pwd, $db_st);
				#		if (mysqli_connect_errno())
				#		{
				#			printf("Connect failed: %s\n", mysqli_connect_error());
				#			exit();
				#		}
				#		$query = implode(";", $sql_multi);
				#		if($query != '')
				#		{
				#			try {
				#				$res = $mysqli->query($query);
				#			}catch (mysqli_sql_exception $e)
				#			{
				#				$Error_inserting_sig_msg."\r\nError Code: ".$e->getCode()."\r\nError Message: ".$e->getMessage()."\r\nStrack Trace: ".nl2br($e->getTraceAsString());
				#				logd($Error_inserting_sig_msg, $log_interval, 0,  $log_level);
				#				if($out=="CLI")
				#				{
				#					verbosed($GLOBALS['COLORS']['RED'].$Error_inserting_sig_msg."\n".$GLOBALS['COLORS']['WHITE'], $verbose, "CLI");
				#				}elseif($out=="HTML")
				#				{
				#					verbosed("<p>".$Error_inserting_sig_msg, $verbose, "HTML");
				#				}
				#				if($out == "HTML"){footer($_SERVER['SCRIPT_FILENAME']);}die();
				#			}
				#		}else
				#		{
				#			logd($Finished_inserting_sig_msg, $log_interval, 0,  $log_level);
				#			if($out=="CLI")
				#			{
				#				verbosed($GLOBALS['COLORS']['GREEN'].$Finished_inserting_sig_msg."\n".$GLOBALS['COLORS']['WHITE'], $verbose, "CLI");
				#			}elseif($out=="HTML")
				#			{
				#				verbosed("<p>".$Finished_inserting_sig_msg, $verbose, "HTML");
				#			}
				#		}
						if($out=="HTML")
						{
							$DB_COUNT = count($db_gps);
							logd("Total GPS in DB: ".$DB_COUNT." || GPS Imports: ".$NNN." .\r\n".mysql_error($conn), $log_interval, 0,  $log_level);
							verbosed("Total GPS in DB: ".$DB_COUNT."<br>GPS Imports: ".$NNN."<br>".mysql_error($conn), $verbose, "HTML");
							?>
								</td></tr>
								<td colspan="8">
							<?php
						}
						
						$exp = explode(",",$signals[$N-1]);
						if($exp[0] == 0){unset($signals[$N-1]);}
						$sig = implode("-",$signals);
						$sqlit = "INSERT INTO `$db_st`.`$table` ( `id` , `btx` , `otx` , `nt` , `label` , `sig`, `user` ) VALUES ( '', '$btx', '$otx', '$nt', '$label', '$sig', '$user')";
						if (!mysql_query($sqlit, $conn))
						{
							logd($failed_sig_add.".\r\n".mysql_error($conn), $log_interval, 0,  $log_level);
							if($out=="CLI")
							{
								verbosed($GLOBALS['COLORS']['RED'].$failed_sig_add.".\n".$GLOBALS['COLORS']['WHITE'].mysql_error($conn), $verbose, "CLI");
							}elseif($out=="HTML")
							{
								verbosed("<p>".$failed_sig_add."</p>".mysql_error($conn), $verbose, "HTML");
							}
							if($out == "HTML"){footer($_SERVER['SCRIPT_FILENAME']);}die();
						}
	#					if($table == "linksys-00226B536D81-3-g-6"){die();}
						$sqlit_ = "SELECT * FROM `$db_st`.`$table`";
						$sqlit_res = mysql_query($sqlit_, $conn) or die(mysql_error());
						$sqlit_num_rows = mysql_num_rows($sqlit_res);
						$sqlit_num_rows++;
						$user_aps[$user_n]="1,".$APid.":".$sqlit_num_rows; //User import tracking //UPDATE AP
						
						logd($user_aps[$user_n], $log_interval, 0,  $log_level);
						if($out=="CLI")
						{
							verbosed($GLOBALS['COLORS']['GREEN'].$user_aps[$user_n]."\n".$GLOBALS['COLORS']['WHITE'], $verbose."\n".$GLOBALS['COLORS']['WHITE'].mysql_error($conn), $verbose, "CLI");
						}elseif($out=="HTML")
						{
							verbosed($user_aps[$user_n]."<br>", $verbose, "HTML");
						}
						$user_n++;
						$updated++;
						if($out == "HTML")
						{
							?>
							</td></tr></table><br>
							<?php
						}
					}else
					{
	#################################################################################################################################################################
	#################################################################################################################################################################
	#										NEW AP										#
	#################################################################################################################################################################
	#################################################################################################################################################################
						$skip_pt_insert=0;
						logd($this_of_this."   ( ".$size." )   ||   ".$table." - ".$being_imported_msg."\r\n", $log_interval, 0,  $log_level);
						if($out=="CLI")
						{
							verbosed($GLOBALS['COLORS']['GREEN'].$this_of_this."   ( ".$size." )   ||   ".$table." - ".$being_imported_msg.".\n".$GLOBALS['COLORS']['WHITE'], $verbose, "CLI");
						}elseif($out=="HTML")
						{
							verbosed('<table border="1" width="90%" class="new"><tr class="style4"><th>ID</th><th>New/Update</th><th>SSID</th><th>Mac Address</th><th>Authentication</th><th>Encryption</th><th>Radion Type</th><th>Channel</th></tr>
									<tr><td>'.$size.'</td><td><b>U</b></td><td>'.$ssids.'</td><td>'.$macs.'</td><td>'.$auth.'</td><td>'.$encry.'</td><td>'.$radios.'</td><td>'.$chan.'</td></tr><tr><td colspan="8">', $verbose, "HTML");
						}
						mysql_select_db($db_st,$conn)or die(mysql_error($conn));
						$sqlct = "CREATE TABLE `$db_st`.`$table` (
									`id` INT( 255 ) NOT NULL AUTO_INCREMENT ,
									`btx` VARCHAR( 10 ) NOT NULL ,
									`otx` VARCHAR( 10 ) NOT NULL ,
									`nt` VARCHAR( 15 ) NOT NULL ,
									`label` VARCHAR( 25 ) NOT NULL ,
									`sig` TEXT NOT NULL ,
									`user` VARCHAR(25) NOT NULL ,
									PRIMARY KEY (`id`) 
									) ENGINE = 'InnoDB' DEFAULT CHARSET='utf8'";
				#		echo "(1)Create Table [".$db_st."].{".$table."}\n		 => Added new Table for ".$ssids."\n";
						if(!mysql_query($sqlct, $conn))
						{
							logd($failed_create_sig_msg."\r\n\t-> ".$sqlct." - ".mysql_error($conn), $log_interval, 0,  $log_level);
							if($out=="CLI")
							{
								verbosed($GLOBALS['COLORS']['RED'].$failed_create_sig_msg."\n\t->".$GLOBALS['COLORS']['WHITE'].mysql_error($conn), $verbose, "CLI");
							}elseif($out=="HTML")
							{
								verbosed("<p>".$failed_create_sig_msg."\t-> ".$sqlct." - ".mysql_error($conn)."</p>", $verbose, "HTML");
							}
							$skip_pt_insert = 1;
						}
						$sqlcgt = "CREATE TABLE `$db_st`.`$gps_table` (`id` INT( 255 ) NOT NULL AUTO_INCREMENT ,`lat` VARCHAR( 25 ) NOT NULL ,`long` VARCHAR( 25 ) NOT NULL ,`sats` INT( 2 ) NOT NULL ,`hdp` FLOAT NOT NULL ,`alt` FLOAT NOT NULL ,`geo` FLOAT NOT NULL ,`kmh` FLOAT NOT NULL ,`mph` FLOAT NOT NULL ,`track` FLOAT NOT NULL ,`date` VARCHAR( 10 ) NOT NULL ,`time` VARCHAR( 8 ) NOT NULL ,INDEX ( `id` ), UNIQUE( `id` )) ENGINE = 'InnoDB' DEFAULT CHARSET='utf8'";
						if(!mysql_query($sqlcgt, $conn))
						{
							logd($failed_create_gps_msg."\r\n\t-> ".$sqlcgt." - ".mysql_error($conn), $log_interval, 0,  $log_level);
							if($out=="CLI")
							{
								verbosed($GLOBALS['COLORS']['RED'].$failed_create_gps_msg."\n\t-> ".$GLOBALS['COLORS']['WHITE'].mysql_error($conn), $verbose, "CLI");
								if($skip_pt_insert == 0){die();}
							}elseif($out=="HTML")
							{
								verbosed("<p>".$failed_create_gps_msg."</p>\t-> ".mysql_error($conn), $verbose, "HTML");
								if($skip_pt_insert == 0){footer($_SERVER['SCRIPT_FILENAME']);die();}
							}
						}
						$signal_exp = explode("-",$san_sig);
					#	echo $wifi[12]."\n";
						$DB_result = mysql_query("SELECT * FROM `$db_st`.`$gps_table`", $conn);
						$gpstableid = mysql_num_rows($DB_result);
						
						if ( $gpstableid == 0)
						{
							$gps_id = 1;
						}
						else
						{
							//if the table is already populated set it to the last ID's number
							$gps_id = $gpstableid;
							$gps_id++;
						}
						echo "GPS points already in table: ".$gpstableid." - GPS_ID: ".$gps_id."\n";
						
						$N=0;
						$prev='';
						$sql_multi = array();
						$signal_exp = explode("-",$san_sig);
						$NNN = 0;
						$sig_counting = count($signal_exp)-1;
						$DBresult = mysql_query("SELECT * FROM `$db_st`.`$gps_table`", $conn);
						while ($neArray = mysql_fetch_array($DBresult))
						{
							$db_gps[$neArray["id"]]["id"]=$neArray["id"];
							$db_gps[$neArray["id"]]["lat"]=$neArray["lat"];
							$db_gps[$neArray["id"]]["long"]=$neArray["long"];
							$db_gps[$neArray["id"]]["sats"]=$neArray["sats"];
							$db_gps[$neArray["id"]]["date"]=$neArray["date"];
							$db_gps[$neArray["id"]]["time"]=$neArray["time"];
						}
						foreach($signal_exp as $key=>$exp)
						{
							$NNN++;
#							echo "Pre loop: ".$gps_id."\n".$dbid."\n";
							//Create GPS Array for each Singal, because the GPS table is growing for each signal you need to re-grab it to test the data
							
							
							$esp = explode(",",$exp);
							$vs1_id = $esp[0];
							$signal = $esp[1];
							
							$lat = $gdata[$vs1_id]["lat"];
							$long = $gdata[$vs1_id]["long"];
							$sats = $gdata[$vs1_id]["sats"];
							$date = $gdata[$vs1_id]["date"];
							$time = $gdata[$vs1_id]["time"];
							$hdp = $gdata[$vs1_id]["hdp"];
							$alt = $gdata[$vs1_id]["alt"];
							$geo = $gdata[$vs1_id]["geo"];
							$kmh = $gdata[$vs1_id]["kmh"];
							$mph = $gdata[$vs1_id]["mph"];
							$track = $gdata[$vs1_id]["track"];
							
							$lat1 = smart($lat);
							$long1 = smart($long);
							$time1 = smart($time);
							$date1 = smart($date);
							
							$comp = $lat1."".$long1."".$date1."".$time1;
							if(!isset($db_gps)){$db_gps = array();}
							list($return_gps, $dbid) = database::check_gps_array($db_gps,$comp, $gps_table);
							if ($prev == $vs1_id)
							{
								$gps_id_ = $gps_id-1;
								$signals[$N] = $gps_id_.",".$signal;
			#					echo "Same as Pre: ".$signals[$N]."\n";
						#		$gps_id++;
								$N++;
								if($verbose == 1 && $out == "CLI"){echo ".";}
								continue;
							}
							if($skip_pt_insert == 0)
							{
								$sql_ = "INSERT INTO `$db_st`.`$gps_table` ( `id` , `lat` , `long` , `sats`, `hdp`, `alt`, `geo`, `kmh`, `mph`, `track` , `date` , `time` ) "
																			."VALUES ( '$gps_id', '$lat', '$long', '$sats', '$hdp', '$alt', '$geo', '$kmh', '$mph', '$track', '$date', '$time')";
								$DBresult = mysql_query($sql_, $conn);
								if($DBresult)
								{
									$signals[$N] = $gps_id.",".$signal;
			#						echo "New GPS for new: ".$signals[$N]."\n";
								}
								else
								{
									logd($insert_new_gps_msg.".\r\n".mysql_error($conn), $log_interval, 0,  $log_level);
									if($out=="CLI")
									{
										verbosed($GLOBALS['COLORS']['RED'].$insert_new_gps_msg.".\n".$GLOBALS['COLORS']['WHITE'].mysql_error($conn), $verbose, "CLI");
									}elseif($out=="HTML")
									{
										verbosed("<p>".$insert_new_gps_msg."</p>".mysql_error($conn), $verbose, "HTML");
									}
									if($out == "HTML"){footer($_SERVER['SCRIPT_FILENAME']);}die();
								}
							}else
							{
								$DBresult = mysql_query("SELECT * FROM `$gps_table` WHERE `id` = '$dbid'", $conn);
								$GPSDBArray = mysql_fetch_array($DBresult);
								if($return_gps === 1 && $dbid != 0)
								{
									if($sats > $GPSDBArray['sats'])
									{
										$sql_multi[$NNN] = "DELETE FROM `$db_st`.`$gps_table` WHERE `$gps_table`.`id` = '$dbid' AND `$gps_table`.`lat` LIKE '$lat' AND `$gps_table`.`long` = '$long' LIMIT 1";
										$NNN++;
										$sql_multi[$NNN] = "INSERT INTO `$gps_table` ( `id` , `lat` , `long` , `sats`, `hdp`, `alt`, `geo`, `kmh`, `mph`, `track` , `date` , `time` ) VALUES ( '$dbid', '$lat', '$long', '$sats', '$hdp', '$alt', '$geo', '$kmh', '$mph', '$track', '$date', '$time')";
										$signals[$N] = $dbid.",".$signal;
			#							echo "Update GPS: ".$signals[$N]."\n";
										if($verbose == 1 && $out == "CLI"){echo ".";}
										$N++;
										$prev = $vs1_id;
										continue;
									#	echo "Update DB: ".$dbid."\n";
									}else
									{
										$signals[$N] = $dbid.",".$signal;
			#							echo "Already in DB: ".$signals[$N]."\n";
										if($verbose == 1 && $out == "CLI"){echo ".";}
										$N++;
										$prev = $vs1_id;
										continue;
									#	echo "Already in DB: ".$dbid."\n";
									}
								}elseif($return_gps === 0 or $dbid == 0	)
								{
									$sql_multi[$NNN] = "INSERT INTO `$db_st`.`$gps_table` ( `id` , `lat` , `long` , `sats`, `hdp`, `alt`, `geo`, `kmh`, `mph`, `track` , `date` , `time` ) "
																			."VALUES ( '$gps_id', '$lat', '$long', '$sats', '$hdp', '$alt', '$geo', '$kmh', '$mph', '$track', '$date', '$time')";
									$signals[$N] = $gps_id.",".$signal;
			#						echo "New GPS for 'update': ".$signals[$N]."\n";
									#echo "New GPS: ".$gps_id."\n";
								}else
								{
									logd($error_running_gps_check_msg.".\r\n".mysql_error($conn), $log_interval, 0,  $log_level);
									if($out=="CLI")
									{
										verbosed($GLOBALS['COLORS']['RED'].$error_running_gps_check_msg.".\n".$GLOBALS['COLORS']['WHITE'].mysql_error($conn), $verbose, "CLI");
									}elseif($out=="HTML")
									{
										verbosed("<p>".$error_running_gps_check_msg."</p>".mysql_error($conn), $verbose, "HTML");
									}
									if($out == "HTML"){footer($_SERVER['SCRIPT_FILENAME']);}die();
								}
							}
							if($verbose == 1 && $out == "CLI"){echo ".";}
							$gps_id++;
							$N++;
							$prev = $vs1_id;
						}

						if($verbose == 1 && $out == "CLI"){echo "\n";}
						$mysqli = new mysqli($host, $db_user, $db_pwd, $db_st);
						if (mysqli_connect_errno())
						{
							printf("Connect failed: %s\n", mysqli_connect_error());
							exit();
						}
						$query = implode(";", $sql_multi);
						if($query != '')
						{
							try {
								$res = $mysqli->query($query);
							#	echo $res."\n".$query."\n";
							}catch (mysqli_sql_exception $e)
							{
								$Error_inserting_sig_msg."\r\nError Code: ".$e->getCode()."\r\nError Message: ".$e->getMessage()."\r\nStrack Trace: ".nl2br($e->getTraceAsString());
								logd($Error_inserting_sig_msg, $log_interval, 0,  $log_level);
								if($out=="CLI")
								{
									verbosed($GLOBALS['COLORS']['RED'].$Error_inserting_sig_msg."\n".$GLOBALS['COLORS']['WHITE'], $verbose, "CLI");
								}elseif($out=="HTML")
								{
									verbosed("<p>".$Error_inserting_sig_msg, $verbose, "HTML");
								}
								if($out == "HTML"){footer($_SERVER['SCRIPT_FILENAME']);}die();
							}
						}else
						{
							logd($Error_inserting_sig_msg, $log_interval, 0,  $log_level);
							if($out=="CLI")
							{
								verbosed($GLOBALS['COLORS']['GREEN'].$Finished_inserting_sig_msg."\n".$GLOBALS['COLORS']['WHITE'], $verbose, "CLI");
							}elseif($out=="HTML")
							{
								verbosed("<p>".$Finished_inserting_sig_msg, $verbose, "HTML");
							}
						}
						
						if($out == "HTML")
						{
							?>
							<tr><td colspan="8">
							<?php
						}elseif($out == "CLI")
						{
							if($verbose == 1){echo "\n";}
						}
						
						$exp = explode(",",$signals[$N-1]);
						if($exp[0] == 0){unset($signals[$N-1]);}
						$sig = implode("-" , $signals);
						$sig = str_replace("&#13;&#10;" , "" , $sig); 
						
						$sqlit1 = "INSERT INTO `$db_st`.`$table` ( `id` , `btx` , `otx` , `nt` , `label` , `sig`, `user` ) VALUES ( '', '$btx', '$otx', '$nt', '$label', '$sig', '$user')";
		#				echo $sqlit1."\n";
						$insertsqlresult = mysql_query($sqlit1, $conn);
		#				echo "(3)Insert into [".$db_st."].{".$table."}\n		 => Add Signal History to Table\n";
						if(!$insertsqlresult)
						{
							logd($failed_insert_sig_msg."\r\n\t-> ".mysql_error($conn), $log_interval, 0,  $log_level);
							if($out=="CLI")
							{
								verbosed($GLOBALS['COLORS']['RED'].$failed_insert_sig_msg."\n\t-> ".$GLOBALS['COLORS']['WHITE'].mysql_error($conn), $verbose, "CLI");
							}elseif($out=="HTML")
							{
								verbosed("<p>".$failed_insert_sig_msg."</p>\t-> ".mysql_error($conn), $verbose, "HTML");
							}
							if($out == "HTML"){footer($_SERVER['SCRIPT_FILENAME']);}die();
						}else
						{
							logd($Finished_inserting_sig_msg."\r\n", $log_interval, 0,  $log_level);
							if($out=="CLI")
							{
								verbosed($GLOBALS['COLORS']['GREEN'].$Finished_inserting_sig_msg."\n".$GLOBALS['COLORS']['WHITE'], $verbose, "CLI");
							}elseif($out=="HTML")
							{
								verbosed("<p>".$Finished_inserting_sig_msg."</p>", $verbose, "HTML");
							}
						
						}
	#					if($table == "linksys-00226B536D81-3-g-6"){die();}
						# pointers
						mysql_select_db($db,$conn);
						if($skip_pt_insert == 0)
						{
							$sqlp = "INSERT INTO `$db`.`$wtable` ( `id` , `ssid` , `mac` ,  `chan`, `radio`,`auth`,`encry`, `sectype` ) VALUES ( '', '$ssids', '$macs','$chan', '$radios', '$auth', '$encry', '$sectype')";
							if (mysql_query($sqlp, $conn))
							{
								$user_aps[$user_n]="0,".$size.":1";
								$sqlup = "UPDATE `$db`.`$settings_tb` SET `size` = '$size' WHERE `table` = '$wtable' LIMIT 1;";
								if (mysql_query($sqlup, $conn))
								{
									logd($updating_stgs_good_msg."\r\n", $log_interval, 0,  $log_level);
									if($out=="CLI")
									{
										verbosed($GLOBALS['COLORS']['GREEN'].$updating_stgs_good_msg."\n".$GLOBALS['COLORS']['WHITE'], $verbose, "CLI");
									}elseif($out=="HTML")
									{
										verbosed("<p>".$updating_stgs_good_msg."</p>".$GLOBALS['COLORS']['WHITE'], $verbose, "HTML");
									}
								}else
								{
									logd($error_updating_stgs_msg."\r\n\t-> ".mysql_error($conn), $log_interval, 0,  $log_level);
									if($out=="CLI")
									{
										verbosed($GLOBALS['COLORS']['RED'].$error_updating_stgs_msg."\n".$GLOBALS['COLORS']['WHITE'].mysql_error($conn), $verbose, "CLI");
									}elseif($out=="HTML")
									{
										verbosed("<p>".$error_updating_stgs_msg."</p>".mysql_error($conn), $verbose, "HTML");
									}
									if($out == "HTML"){footer($_SERVER['SCRIPT_FILENAME']);}die();
								}
								logd($user_aps[$user_n], $log_interval, 0,  $log_level);
								if($out=="CLI")
								{
									verbosed($GLOBALS['COLORS']['GREEN'].$user_aps[$user_n]."\n".$GLOBALS['COLORS']['WHITE'], $verbose, "CLI");
								}elseif($out=="HTML")
								{
									verbosed($user_aps[$user_n]."<br>", $verbose, "HTML");
								}
								$user_n++;
							}else
							{
								logd($error_updating_pts_msg."\r\n\t-> ".mysql_error($conn), $log_interval, 0,  $log_level);
								if($out=="CLI")
								{
									verbosed($GLOBALS['COLORS']['RED'].$error_updating_pts_msg."\n\t-> ".$GLOBALS['COLORS']['WHITE'].mysql_error($conn), $verbose, "CLI");
								}elseif($out=="HTML")
								{
									verbosed("<p>".$error_updating_pts_msg."</p>".mysql_error($conn), $verbose, "HTML");
								}
								if($out == "HTML"){footer($_SERVER['SCRIPT_FILENAME']);}die();
							}
							$imported++;
						}else
						{
							$result_dup = mysql_query("SELECT `id` FROM `$db`.`$wtable` WHERE `mac` LIKE '$macs'  AND `ssid` LIKE '$ssids' AND `chan` LIKE '$chan' AND `sectype` LIKE '$sectype'", $conn) or die(mysql_error($conn));
							$newArray_dup = mysql_fetch_array($result_dup);
							$duplicate_id = $newArray_dup['id'];
							
							$result_sig = mysql_query("SELECT `id` FROM `$db_st`.`$table`", $conn) or die(mysql_error($conn));
							$row_sig = mysql_num_rows($result_sig);
							
							$user_aps[$user_n]="1,".$duplicate_id.":".$row_sig;
							logd($user_aps[$user_n], $log_interval, 0,  $log_level);
							if($out=="CLI")
							{
								verbosed($GLOBALS['COLORS']['GREEN'].$user_aps[$user_n]."\n".$GLOBALS['COLORS']['WHITE'], $verbose, "CLI");
							}elseif($out=="HTML")
							{
								verbosed($user_aps[$user_n]."<br>", $verbose, "HTML");
							}
							$user_n++;	
							
							echo $GLOBALS['COLORS']['RED']."Skipped Creation of duplicate Pointer Row in wifi0\n".$GLOBALS['COLORS']['WHITE'];
						}
						$skip_pt_insert = 0;
					}
					if($out == "HTML")
					{
						?>
						</td></tr></table><br>
						<?php
					}
					$FILENUM++;
					unset($ssid_ptb);
					unset($mac_ptb);
					unset($sectype_ptb);
					unset($radio_ptb);
					unset($chan_ptb);
					unset($table_ptb);
					
					if(!is_null($signals))
					{
						foreach ($signals as $i => $value)
						{
							unset($signals[$i]);
						}
						$signals = array_values($signals);
					}
			}elseif($ret_len == 17)
			{
				logd($text_files_support_msg, $log_interval, 0,  $log_level);
				if($out=="CLI")
				{
					verbosed($GLOBALS['COLORS']['YELLOW'].$text_files_support_msg."\n".$GLOBALS['COLORS']['WHITE'], $verbose, "CLI");
				}elseif($out=="HTML")
				{
					verbosed("<h1>".$text_files_support_msg."</h1>", $verbose, "HTML");
				}
				if($out == "HTML"){footer($_SERVER['SCRIPT_FILENAME']);die();}
				return "text";
			}elseif($ret_len == 0)
			{
				logd($wrong_file_type_msg, $log_interval, 0,  $log_level);
				if($out=="CLI")
				{
					verbosed($GLOBALS['COLORS']['RED'].$wrong_file_type_msg."\n".$GLOBALS['COLORS']['WHITE'], $verbose, "CLI");
				}elseif($out=="HTML")
				{
					verbosed("<h1>".$wrong_file_type_msg.".</h1>", $verbose, "HTML");
				}
				if($out == "HTML"){footer($_SERVER['SCRIPT_FILENAME']);die();}
			}else
			{
				logd($wrong_file_type_msg, $log_interval, 0,  $log_level);
				if($out=="CLI")
				{
					verbosed($GLOBALS['COLORS']['RED'].$wrong_file_type_msg."\n".$GLOBALS['COLORS']['WHITE'], $verbose, "CLI");
				}elseif($out=="HTML")
				{
					verbosed("<h1>".$wrong_file_type_msg.".</h1>", $verbose, "HTML");
				}
				if($out == "HTML"){footer($_SERVER['SCRIPT_FILENAME']);die();}
			}
		}
		mysql_select_db($db,$conn);
		
		if(is_array($user_aps))
		{
			$user_ap_s = implode("-",$user_aps);
		}else
		{
			$user_ap_s = "";
		}
		$notes = addslashes($notes);
		
		if($title === ''){$title = "Untitled";}
		if($user === ''){$user="Unknown";}
		if($notes === ''){$notes="No Notes";}
		$hash = hash_file('md5', $source);
		$total_ap = count($user_aps);
		$gdatacount = count($gdata);
#		if($user_ap_s != "")
#		{
			$sqlu = "INSERT INTO `$db`.`users` ( `id` , `username` , `points` ,  `notes`, `date`, `title` , `aps`, `gps`, `hash`) VALUES ( '', '$user', '$user_ap_s','$notes', '$times', '$title', '$total_ap', '$gdatacount', '$hash')";
			if(!mysql_query($sqlu, $conn))
			{
				if($out=="CLI")
				{
					verbosed($failed_import_user_data_msg.mysql_error($conn), $verbose, "CLI");
				}elseif($out=="HTML")
				{
					verbosed($GLOBALS['COLORS']['RED'].$failed_import_user_data_msg."\n".$GLOBALS['COLORS']['WHITE'].mysql_error($conn), $verbose, "HTML");
				}
				logd($failed_import_user_data_msg.mysql_error($conn), $log_interval, 0,  $log_level);
				if($out == "HTML"){footer($_SERVER['SCRIPT_FILENAME']);}
				die();
			}else
			{
				if($out=="CLI")
				{
					verbosed($GLOBALS['COLORS']['GREEN'].$Inserted_user_data_good_msg."\n".$GLOBALS['COLORS']['WHITE'], $verbose, "CLI");
				}elseif($out=="HTML")
				{
					verbosed("<p>".$Inserted_user_data_good_msg."</p>", $verbose, "HTML");
				}
				logd($Inserted_user_data_good_msg, $log_interval, 0,  $log_level);
			}
			
#		}
		if($out=="CLI")
		{
			echo "\nFile DONE!\n|\n|\n";
		}elseif($out=="HTML")
		{
			echo "<p>File DONE!</p>";
		}
		$end = microtime(true);
		$times = array(
						"aps"	=> $total_ap,
						"gps" => $gdatacount
						);
		return $times;
	}
	
	
	#========================================================================================================================#
	#													Convert GeoCord DM to DD									   	     #
	#========================================================================================================================#
	
	function &convert_dm_dd($geocord_in = "")
	{
		$start = microtime(true);
	//	GPS Convertion :
		$neg=FALSE;
		$geocord_exp = explode(".", $geocord_in);//replace any Letter Headings with Numeric Headings
		$geocord_front = explode(" ", $geocord_exp[0]);
		if($geocord_exp[0][0] === "S" or $geocord_exp[0][0] === "W"){$neg = TRUE;}
		$patterns[0] = '/N /';
		$patterns[1] = '/E /';
		$patterns[2] = '/S /';
		$patterns[3] = '/W /';
		$replacements = "";
		$geocord_in = preg_replace($patterns, $replacements, $geocord_in);
		$geocord_exp = explode(".", $geocord_in);
		if($geocord_exp[0][0] === "-"){$geocord_exp[0] = 0 - $geocord_exp[0];$neg = TRUE;}
		// 428.7753 ---- 428 - 7753
		$geocord_dec = "0.".$geocord_exp[1];
		// 428.7753 ---- 428 - 0.7753
		$len = strlen($geocord_exp[0]);
#		echo $len.'<BR>';
		$geocord_min = substr($geocord_exp[0],-2,3);
#		echo $geocord_min.'<BR>';
		// 428.7753 ---- 4 - 28 - 0.7753
		$geocord_min = $geocord_min+$geocord_dec;
		// 428.7753 ---- 4 - 28.7753
		$geocord_div = $geocord_min/60;
		// 428.7753 ---- 4 - (28.7753)/60 = 0.4795883
		if($len ==3)
		{
			$geocord_deg = substr($geocord_exp[0], 0,1);
#			echo $geocord_deg.'<br>';
		}elseif($len == 4)
		{
			$geocord_deg = substr($geocord_exp[0], 0,2);
#			echo $geocord_deg.'<br>';
		}elseif($len == 5)
		{
			$geocord_deg = substr($geocord_exp[0], 0,3);
#			echo $geocord_deg.'<br>';
		}
		$geocord_out = $geocord_deg + $geocord_div;
		// 428.7753 ---- 4.4795883
		if($neg === TRUE){$geocord_out = "-".$geocord_out;}
		$end = microtime(true);
		if ($GLOBALS["bench"]  == 1)
		{
			echo "Time is [Unix Epoc]<BR>";
			echo "Start Time: ".$start."<BR>";
			echo "  End Time: ".$end."<BR>";
		}
		$geocord_out = substr($geocord_out, 0,10);
		return $geocord_out;
	}
	#========================================================================================================================#
	#													Convert GeoCord DD to DM									   	     #
	#========================================================================================================================#
	
	function &convert_dd_dm($geocord_in="")
	{
		$start = microtime(true);
		//	GPS Convertion :
#		echo $geocord_in.'<BR>';
		$neg=FALSE;
		$geocord_exp = explode(".", $geocord_in);
		$geocord_front = explode(" ", $geocord_exp[0]);
		
		if($geocord_exp[0][0] == "S" or $geocord_exp[0][0] == "W"){$neg = TRUE;}
		$pattern[0] = '/N /';
		$pattern[1] = '/E /';
		$pattern[2] = '/S /';
		$pattern[3] = '/W /';
		$replacements = "";
		$geocord_exp[0] = preg_replace($pattern, $replacements, $geocord_exp[0]);
		
		if($geocord_exp[0][0] === "-"){$geocord_exp[0] = 0 - $geocord_exp[0];$neg = TRUE;}
		// 4.146255 ---- 4 - 146255
#		echo $geocord_exp[1].'<br>';
		$geocord_dec = "0.".$geocord_exp[1];
		// 4.146255 ---- 4 - 0.146255
#		echo $geocord_dec.'<br>';
		$geocord_mult = $geocord_dec*60;
		// 4.146255 ---- 4 - (0.146255)*60 = 8.7753
#		echo $geocord_mult.'<br>';
		$mult = explode(".",$geocord_mult);
#		echo $len.'<br>';
		if( strlen($mult[0]) < 2 )
		{
			$geocord_mult = "0".$geocord_mult;
		}
		// 4.146255 ---- 4 - 08.7753
		$geocord_out = $geocord_exp[0].$geocord_mult;
		// 4.146255 ---- 408.7753
		$geocord_o = explode(".", $geocord_out);
		if( strlen($geocord_o[1]) > 4 ){ $geocord_o[1] = substr($geocord_o[1], 0 , 4); $geocord_out = implode('.', $geocord_o); }
		
		if($neg === TRUE){$geocord_out = "-".$geocord_out;}
		$end = microtime(true);
		if ($GLOBALS["bench"]  == 1)
		{
			echo "Time is [Unix Epoc]<BR>";
			echo "Start Time: ".$start."<BR>";
			echo "  End Time: ".$end."<BR>";
		}
		return $geocord_out;
	}
	
	#========================================================================================================================#
	#													GPS check, make sure there are no duplicates						 #
	#========================================================================================================================#

	function &check_gps_array($gpsarray, $test, $table)
	{
		$start = microtime(true);
		include('config.inc.php');
		$conn1 = $GLOBALS['conn'];
		$db_st = $GLOBALS['db_st'];
		
		$count = count($gpsarray);
		if($count !=0)
		{
			foreach($gpsarray as $gps)
			{
				$id = $gps['id'];
				$lat = smart($gps['lat']);
				$long = smart($gps['long']);
				$time = smart($gps['time']);
				$date = smart($gps['date']);
				$gps_t 	= $lat."".$long."".$date."".$time;
				$gps_t = $gps_t+0;
				$test	 = $test+0;
				
				if ($gps_t===$test)
				{
					if ($GLOBALS["debug"]  == 1 ) {
						echo  "  SAME<br>";
						echo  "  Array data: ".$gps_t."<br>";
						echo  "  Testing data: ".$test."<br>.-.-.-.-.=.-.-.-.-.<br>";
						echo  "-----=-----=-----<br>|<br>|<br>"; 
					}
					
					$lat_a = $gps['lat'];
					$long_a = $gps['long'];
					$time_a = $gps['time'];
					$date_a = $gps['date'];
					
					$sql11 = "SELECT * FROM `$db_st`.`$table` WHERE `lat` like '$lat_a' AND `long` like '$long_a' AND `date` like '$date_a' AND `time` like '$time_a' LIMIT 1";
					$gpresult = mysql_query($sql11, $conn1);
					$gpsdbarray = mysql_fetch_array($gpresult);
					
					$id_ = $gpsdbarray['id'];
#					echo $sql11."\n".$id_."\n";
					
					$return = array(0=>1,1=>$id_);
					return $return;
					break;
				}else
				{
					if ($GLOBALS["debug"]  == 1){
						echo  "  NOT SAME<br>";
						echo  "  Array data: ".$gps_t."<br>";
						echo  "  Testing data: ".$test."<br>----<br>";
						echo  "-----=-----<br>";
					}
					$return = array(0=>0,1=>0);
				}
			}
		}else
		{
			$return = array(0=>0,1=>0);
		}
		$end = microtime(true);
		if ($GLOBALS["bench"]  == 1)
		{
			#echo "Time is [Unix Epoc]<BR>";
			#echo "Start Time: ".$start."<BR>";
			#echo "  End Time: ".$end."<BR>";
		}
		return $return;
	}
	
	
	#========================================================================================================================#
	#													AP History Fetch													 #
	#========================================================================================================================#

	function apfetch($id=0)
	{
		$apID = $id;
		$start = microtime(true);
		include('../lib/config.inc.php');
		$sqls = "SELECT * FROM `$db`.`$wtable` WHERE id='$id'";
		$result = mysql_query($sqls, $conn) or die(mysql_error());
		$newArray = mysql_fetch_array($result);
		$ID = $newArray['id'];
		$tablerowid = 0;
		$macaddress = $newArray['mac'];
		$manuf = database::manufactures($macaddress);
		$mac = str_split($macaddress,2);
		$mac_full = $mac[0].":".$mac[1].":".$mac[2].":".$mac[3].":".$mac[4].":".$mac[5];
		$radio = $newArray['radio'];
		if($radio == "a")
			{$radio = "802.11a";}
		elseif($radio == "b")
			{$radio = "802.11b";}
		elseif($radio == "g")
			{$radio = "802.11g";}
		elseif($radio == "n")
			{$radio = "802.11n";}
		else
			{$radio = "802.11u";}
		$ssid_ptb_ = $newArray["ssid"];
		$ssids_ptb = str_split($newArray['ssid'],25);
		$ssid_ptb = smart_quotes($ssids_ptb[0]);
		$table		=	$ssid_ptb.'-'.$newArray["mac"].'-'.$newArray["sectype"].'-'.$newArray["radio"].'-'.$newArray['chan'];
		$table_gps	=	$table.$gps_ext;
		?>
				<SCRIPT LANGUAGE="JavaScript">
				// Row Hide function.
				// by tcadieux
				function expandcontract(tbodyid,ClickIcon)
				{
					if (document.getElementById(ClickIcon).innerHTML == "+")
					{
						document.getElementById(tbodyid).style.display = "";
						document.getElementById(ClickIcon).innerHTML = "-";
					}else{
						document.getElementById(tbodyid).style.display = "none";
						document.getElementById(ClickIcon).innerHTML = "+";
					}
				}
				</SCRIPT>
				<h1><?php echo $newArray['ssid'];?></h1>
				<TABLE WIDTH=569 BORDER=1 CELLPADDING=4 CELLSPACING=0>
				<TABLE WIDTH=569 BORDER=1 CELLPADDING=4 CELLSPACING=0>
				<COL WIDTH=112><COL WIDTH=439>
				<TR VALIGN=TOP><TD class="style4" WIDTH=112><P>MAC Address</P></TD><TD WIDTH=439><P><?php echo $mac_full;?></P></TD></TR>
				<TR VALIGN=TOP><TD class="style4" WIDTH=112><P>Manufacture</P></TD><TD WIDTH=439><P><?php echo $manuf;?></P></TD></TR>
				<TR VALIGN=TOP><TD class="style4" WIDTH=112 HEIGHT=26><P>Authentication</P></TD><TD WIDTH=439><P><?php echo $newArray['auth'];?></P></TD></TR>
				<TR VALIGN=TOP><TD class="style4" WIDTH=112><P>Encryption Type</P></TD><TD WIDTH=439><P><?php echo $newArray['encry'];?></P></TD></TR>
				<TR VALIGN=TOP><TD class="style4" WIDTH=112><P>Radio Type</P></TD><TD WIDTH=439><P><?php echo $radio;?></P></TD></TR>
				<TR VALIGN=TOP><TD class="style4" WIDTH=112><P>Channel #</P></TD><TD WIDTH=439><P><?php echo $newArray['chan'];?></P></TD></TR>
		<?php
		?>
		<tr><td colspan="2" align="center" ><a class="links" href="../opt/export.php?func=exp_single_ap&row=<?php echo $ID;?>&token=<?php echo $_SESSION['token'];?>">Export this AP to KML</a></td></tr>
		</table>
		<br>
		<TABLE WIDTH=85% BORDER=1 CELLPADDING=4 CELLSPACING=0 id="gps">
		<tr class="style4"><th colspan="10">Signal History</th></tr>
		<tr class="style4"><th>Row</th><th>Btx</th><th>Otx</th><th>First Active</th><th>Last Update</th><th>Network Type</th><th>Label</th><th>User</th><th>Signal</th><th>Plot</th></tr>
		<?php
		$start1 = microtime(true);
		$result = mysql_query("SELECT * FROM `$db_st`.`$table` ORDER BY `id`", $conn) or die(mysql_error());
		while ($field = mysql_fetch_array($result))
		{
			$row = $field["id"];
			$row_id = $row.','.$ID;
			$sig_exp = explode("-", $field["sig"]);
			$sig_size = count($sig_exp)-1;

			$first_ID = explode(",",$sig_exp[0]);
			$first = $first_ID[0];
			if($first == 0)
			{
				$first_ID = explode(",",$sig_exp[1]);
				$first = $first_ID[0];
			}
			
			$last_ID = explode(",",$sig_exp[$sig_size]);
			$last = $last_ID[0];
			if($last == 0)
			{
				$last_ID = explode(",",$sig_exp[$sig_size-1]);
				$last = $last_ID[0];
			}
			
			$sql1 = "SELECT * FROM `$db_st`.`$table_gps` WHERE `id`='$first'";
			$re = mysql_query($sql1, $conn) or die(mysql_error());
			$gps_table_first = mysql_fetch_array($re);

			$date_first = $gps_table_first["date"];
			$time_first = $gps_table_first["time"];
			$fa = $date_first." ".$time_first;
			
			$sql2 = "SELECT * FROM `$db_st`.`$table_gps` WHERE `id`='$last'";
			$res = mysql_query($sql2, $conn) or die(mysql_error());
			$gps_table_last = mysql_fetch_array($res);
			$date_last = $gps_table_last["date"];
			$time_last = $gps_table_last["time"];
			$lu = $date_last." ".$time_last;
			?>
				<tr><td align="center"><?php echo $row; ?></td><td>
				<?php echo $field["btx"]; ?></td><td>
				<?php echo $field["otx"]; ?></td><td>
				<?php echo $fa; ?></td><td>
				<?php echo $lu; ?></td><td>
				<?php echo $field["nt"]; ?></td><td>
				<?php echo $field["label"]; ?></td><td>
				<a class="links" href="../opt/userstats.php?func=allap&user=<?php echo $field["user"]; ?>&token=<?php echo $_SESSION['token'];?>"><?php echo $field["user"]; ?></a></td><td>
				<a class="links" href="../graph/?row=<?php echo $row; ?>&id=<?php echo $ID; ?>&token=<?php echo $_SESSION['token'];?>">Graph Signal</a></td><td><a class="links" href="export.php?func=exp_all_signal&row=<?php echo $row_id;?>&token=<?php echo $_SESSION['token'];?>">KML</a>
			<!--	OR <a class="links" href="export.php?func=exp_all_signal_gpx&row=<?php #echo $row_id;?>&token=<?php #echo $_SESSION['token'];?>">GPX</a> -->
				</td></tr>
				<tr><td colspan="10" align="center">
				
				<table WIDTH=569 BORDER=1 CELLPADDING=4 CELLSPACING=0>
				<tr><td class="style4" onclick="expandcontract('Row<?php echo $tablerowid;?>','ClickIcon<?php echo $tablerowid;?>')" id="ClickIcon<?php echo $tablerowid;?>" style="cursor: pointer; cursor: hand;">+</td>
				<th colspan="6" class="style4">GPS History</th></tr>
				<tbody id="Row<?php echo $tablerowid;?>" style="display:none">
				<tr class="style4"><th>Row</th><th>Lat</th><th>Long</th><th>Sats</th><th>Date</th><th>Time</th></tr>
				<?php
				$tablerowid++;
				$signals = explode('-',$field['sig']);
				foreach($signals as $signal)
				{
					$sig_exp = explode(',',$signal);
					$id = $sig_exp[0]+0;
					if($id == 0){continue;}
					$start2 = microtime(true);
					$result1 = mysql_query("SELECT * FROM `$db_st`.`$table_gps` WHERE `id` = '$id'", $conn) or die(mysql_error());
				#	$rows = mysql_num_rows($result1);
					while ($field = mysql_fetch_array($result1)) 
					{
				#		if($rows > 1){$rows--; continue;}
						?>
						<tr><td align="center">
						<?php echo $field["id"]; ?></td><td>
						<?php echo $field["lat"]; ?></td><td>
						<?php echo $field["long"]; ?></td><td align="center">
						<?php echo $field["sats"]; ?></td><td>
						<?php echo $field["date"]; ?></td><td>
						<?php echo $field["time"]; ?></td></tr>
						<?php
					}
					$end2 = microtime(true);
				}
				?>
				</table>
				</td></tr>
				<?php
		}
		$end1 = microtime(true);
		?>
		</table>
		<br>
		<TABLE WIDTH=569 BORDER=1 CELLPADDING=4 CELLSPACING=0>
		<?php
		#END GPSFETCH FUNC
		?>
		<tr class="style4"><th colspan="6">Associated Lists</th></tr>
		<tr class="style4"><th>New/Update</th><th>ID</th><th>User</th><th>Title</th><th>Total APs</th><th>Date</th></tr>
		<?php
		$start3 = microtime(true);
		mysql_select_db($db, $conn);
		$result = mysql_query("SELECT * FROM `$db`.`users`", $conn);
		while ($field = mysql_fetch_array($result)) 
		{
			if($field['points'] != '')
			{
				$APS = explode("-" , $field['points']);
				foreach ($APS as $AP)
				{
			#		echo $AP."<BR>";
					$access = explode(",", $AP);
					$New_or_Update = $access[0];
					
					$access1 = explode(":",$access[1]);
					$user_list_id = $access1[0];
					
					if ( $apID  ==  $user_list_id )
					{
						$list[]=$field['id'].",".$New_or_Update;
					}
				}
			}
		}
		if(isset($list))
		{
			foreach($list as $aplist)
			{
				$exp = explode(",",$aplist);
				$apid = $exp[0];
				$new_update = $exp[1];
				$result = mysql_query("SELECT * FROM `$db`.`users` WHERE `id`='$apid'", $conn);
				while ($field = mysql_fetch_array($result)) 
				{
					if($field["title"]==''){$field["title"]="Untitled";}
					$points = explode('-' , $field['points']);
					$total = count($points);
					?>
					<td ><?php if($new_update == 1)
					{echo "Update";}
					else{echo "New";} 
					?></td><td align="center"><a class="links" href="userstats.php?func=useraplist&row=<?php echo $field["id"];?>&token=<?php echo $_SESSION['token'];?>"><?php echo $field["id"];?></a></td><td><a class="links" href="userstats.php?func=alluserlists&user=<?php echo $field["username"];?>&token=<?php echo $_SESSION['token'];?>"><?php echo $field["username"];?></a></td><td><a class="links" href="userstats.php?func=useraplist&row=<?php echo $field["id"];?>&token=<?php echo $_SESSION['token'];?>"><?php echo $field["title"];?></a></td><td align="center"><?php echo $total;?></td><td><?php echo $field['date'];?></td></tr>
					<?php
				}
			}
		}else
		{
			?>
			<td colspan="5" align="center">There are no Other Lists with this AP in it.</td></tr>
			<?php
			
		}
		$end3 = microtime(true);
		mysql_close($conn);
		?>
		</table><br>
		<?php
		$end = microtime(true);
		if ($GLOBALS["bench"]  == 1)
		{
			echo "Time is [Unix Epoc]<BR>";
			echo "Total Start Time: ".$start."<BR>";
			echo "Total  End Time: ".$end."<BR>";
			echo "Start Time 1: ".$start1."<BR>";
			echo "  End Time 1: ".$end1."<BR>";
			echo "Start Time 2: ".$start2."<BR>";
			echo "  End Time 2: ".$end2."<BR>";
			echo "Start Time 3: ".$start3."<BR>";
			echo "  End Time 3: ".$end3."<BR>";
		}
		#END IMPORT LISTS FETCH FUNC
	}
	
	
	#========================================================================================================================#
	#													Grab the stats for All Users										 #
	#========================================================================================================================#
	function all_users()
	{
		$start = microtime(true);
		include('config.inc.php');
		$users = array();
		$userarray = array();
		?>
			<h1>Stats For: All Users</h1>
			<table border="1"><tr class="style4">
			<th>ID</th><th>UserName</th><th>Title</th><th>Number of APs</th><th>Imported On</th></tr><tr>
		<?php
		
		mysql_select_db($db,$conn);
		$sql = "SELECT * FROM `users` ORDER BY username ASC";
		$result = mysql_query($sql, $conn) or die(mysql_error());
		$num = mysql_num_rows($result);
		if($num == 0)
		{
			echo '<tr><td colspan="5" align="center">There no Users, Import something.</td></tr></table>'; 
			$filename = $_SERVER['SCRIPT_FILENAME'];
			footer($filename);
			die();
		}
		while ($user_array = mysql_fetch_array($result))
		{
			$users[]=$user_array["username"];
		}
		$users = array_unique($users);
		$pre_user = "";
		$n=0;
		foreach($users as $user)
		{
			$sql = "SELECT * FROM `users` WHERE `username`='$user'";
			$result = mysql_query($sql, $conn) or die(mysql_error());
			while ($user_array = mysql_fetch_array($result))
			{
				$id	=	$user_array['id'];
				$username = $user_array['username'];
				if($pre_user === $username or $pre_user === ""){$n++;}else{$n=0;}
				if ($user_array['title'] === "" or $user_array['title'] === " "){ $user_array['title']="UNTITLED";}
				if ($user_array['date'] === ""){ $user_array['date']="No date, hmm..";}
				if ($user_array['notes'] === " " or $user_array['notes'] === ""){ $user_array['notes']="No Notes, hmm..";}
				$points = explode("-",$user_array['points']);
				$pc = count($points);
				if($user_array['points'] === ""){continue;}
				if($pre_user !== $username)
				{
					echo '<tr><td>'.$user_array['id'].'</td><td><a class="links" href="userstats.php?func=alluserlists&user='.$username.'&token='.$_SESSION['token'].'">'.$username.'</a></td><td><a class="links" href="userstats.php?func=useraplist&row='.$user_array["id"].'&token='.$_SESSION['token'].'">'.$user_array['title'].'</a></td><td>'.$pc.'</td><td>'.$user_array['date'].'</td></tr>';
				}
				else
				{
					?>
					<tr><td></td><td></td><td><a class="links" href="userstats.php?func=useraplist&row=<?php echo $user_array["id"];?>&token=<?php echo $_SESSION['token'];?>"><?php echo $user_array['title'];?></a></td><td><?php echo $pc;?></td><td><?php echo $user_array['date'];?></td></tr>
					<?php
				}
				$pre_user = $username;
			}
			?>
			<tr></tr>
			<?php
		}
		
		?>
		</tr></td></table><br>
		<?php
		$end = microtime(true);
				if ($GLOBALS["bench"]  == 1)
				{
					echo "Time is [Unix Epoc]<BR>";
					echo "Start Time: ".$start."<BR>";
					echo "  End Time: ".$end."<BR>";
				}
	}
	
	
	#========================================================================================================================#
	#													Grab All the AP's for a given user									 #
	#========================================================================================================================#
	
	function all_users_ap($user="")
	{
		$start = microtime(true);
		?>
		<h3>View All Users <a class="links" href="userstats.php?func=allusers&token=<?php echo $_SESSION['token'];?>">Here</a></h3>
		<h1>Access Points For: <a class="links" href ="../opt/userstats.php?func=alluserlists&user=<?php echo $user;?>&token=<?php echo $_SESSION['token'];?>"><?php echo $user;?></a></h1>
		<h3><a class="links" href="../opt/export.php?func=exp_user_all_kml&user=<?php echo $user;?>&token=<?php echo $_SESSION['token'];?>">Export To KML File</a></h3>
		<table border="1"><tr class="style4"><th>AP ID</th><th>Row</th><th>SSID</th><th>Mac Address</th><th>Authentication</th><th>Encryption</th><th>Radio</th><th>Channel</th></tr>
		<?php
		include('config.inc.php');
		mysql_select_db($db,$conn);
		$sql = "SELECT * FROM `users` WHERE `username`='$user'";
		$re = mysql_query($sql, $conn) or die(mysql_error());
		while($user_array = mysql_fetch_array($re))
		{
			if($user_array["points"] != '')
			{
				$explode = explode("-",$user_array["points"]);
				foreach($explode as $explo)
				{
					$exp = explode(",",$explo);
					$flag = $exp[0];
					$ap_exp = explode(":",$exp[1]);
					$aps[] = array(
									"flag"=>$flag,
									"apid"=>$ap_exp[0],
									"row"=>$ap_exp[1]
									);
				}
			}
		}
		foreach($aps as $ap)
		{
			if($ap['flag'] == "1"){continue;}
			$apid = $ap['apid'];
			$row = $ap['row'];
			
			$sql = "SELECT * FROM `$wtable` WHERE `ID`='$apid'";
			$res = mysql_query($sql, $conn) or die(mysql_error());
			while ($ap_array = mysql_fetch_array($res))
			{
				$ssid = $ap_array['ssid'];
			    $mac = $ap_array['mac'];
			    $chan = $ap_array['chan'];
				$radio = $ap_array['radio'];
				$auth = $ap_array['auth'];
				$encry = $ap_array['encry'];
			    if($radio=="a")
				{$radio="802.11a";}
				elseif($radio=="b")
				{$radio="802.11b";}
				elseif($radio=="g")
				{$radio="802.11g";}
				elseif($radio=="n")
				{$radio="802.11n";}
				else
				{$radio="Unknown Radio";}
				?>
				<tr><td align="center">
				<?php
				echo $apid;
				?>
				</td><td align="center">
				<?php
				echo $row;
				?>
				</td><td align="center"><a class="links" href="fetch.php?id=<?php echo $apid;?>&token=<?php echo $_SESSION['token'];?>"><?php echo $ssid;?></a></td>
				<td>
				<?php echo $mac;?></td><td align="center">
				<?php echo $auth;?></td><td align="center">
				<?php echo $encry;?></td><td align="center">
				<?php echo $radio;?></td><td align="center">
				<?php echo $chan;?></td></tr>
				<?php
			}
		}
		echo "</table><br>";
		$end = microtime(true);
				if ($GLOBALS["bench"]  == 1)
				{
					echo "Time is [Unix Epoc]<BR>";
					echo "Start Time: ".$start."<BR>";
					echo "  End Time: ".$end."<BR>";
				}
	}
	
	#========================================================================================================================#
	#													Grab all user Import lists											 #
	#========================================================================================================================#

	function users_lists($user="")
	{
		$start = microtime(true);
		include('config.inc.php');
		echo '<h1>Import Lists For: <a class="links" href ="../opt/userstats.php?func=allap&user='.$user.'&token='.$_SESSION['token'].'">'.$user.'</a></h1>';		
		echo '<h3>View All Users <a class="links" href="userstats.php?func=allusers&token='.$_SESSION['token'].'">Here</a></h3>';
		echo '<h3>View all Access Points for user: <a class="links" href="../opt/userstats.php?func=allap&user='.$user.'&token='.$_SESSION['token'].'">'.$user.'</a>';
		echo '<h2><a class="links" href=../opt/export.php?func=exp_user_all_kml&user='.$user.'&token='.$_SESSION['token'].'">Export To KML File</a></h2>';
		echo '<table border="1"><tr class="style4"><th>ID</th><th>Title</th><th># of APs</th><th>Imported on</th></tr><tr>';
		mysql_select_db($db,$conn);
		$sql = "SELECT * FROM `users` WHERE `username` = '$user'";
		$result = mysql_query($sql, $conn) or die(mysql_error());
		while($user_array = mysql_fetch_array($result))
		{
			if($user_array['title']==''){$title = "Untitled";}else{$title = $user_array['title'];}
			$points = explode('-',$user_array['points']);
			$total = count($points);
			echo '<tr><td align="center">'.$user_array["id"].'</td><td align="center"><a class="links" href="../opt/userstats.php?func=useraplist&row='.$user_array["id"].'&token='.$_SESSION['token'].'">'.$title.'</a></td><td align="center">'.$total.'</td><td align="center">'.$user_array["date"].'</td></tr>';
			
		}
		echo "</table><br>";
		$end = microtime(true);
				if ($GLOBALS["bench"]  == 1)
				{
					echo "Time is [Unix Epoc]<BR>";
					echo "Start Time: ".$start."<BR>";
					echo "  End Time: ".$end."<BR>";
				}
	}
	
	#========================================================================================================================#
	#													Grab the AP's for a given user's Import								 #
	#========================================================================================================================#

	function user_ap_list($row=0)
	{
		$start = microtime(true);
		include('config.inc.php');
		$pagerow =0;
		mysql_select_db($db,$conn);
		$sql = "SELECT * FROM `users` WHERE `id`='$row'";
		$result = mysql_query($sql, $conn) or die(mysql_error());
		$user_array = mysql_fetch_array($result);
		$aps=explode("-",$user_array["points"]);
		echo '<h1>Access Points For: <a class="links" href ="../opt/userstats.php?func=alluserlists&user='.$user_array["username"].'&token='.$_SESSION['token'].'">'.$user_array["username"].'</a></h1><h2>With Title: '.$user_array["title"].'</h2><h2>Imported On: '.$user_array["date"].'</h2>';
		?>
		<h3>View All Users <a class="links" href="userstats.php?func=allusers&token=<?php echo $_SESSION['token'];?>">Here</a></h3>
		<?php
		echo '<a class="links" href=../opt/export.php?func=exp_user_list&row='.$user_array["id"].'&token='.$_SESSION['token'].'">Export To KML File</a>';
		echo '<table border="1"><tr class="style4"><th>New/Update</th><th>AP ID</th><th>Row</th><th>SSID</th><th>Mac Address</th><th>Authentication</th><th>Encryption</th><th>Radio</th><th>Channel</th></tr><tr>';
		foreach($aps as $ap)
		{
			#$pagerow++;
			$ap_exp = explode("," , $ap);
			if($ap_exp[0]==0){$flag = "N";}else{$flag = "U";}
			
			$ap_and_row = explode(":",$ap_exp[1]);
			$apid = $ap_and_row[0];
			$row = $ap_and_row[1];
			
			$sql = "SELECT * FROM `$wtable` WHERE `ID`='$apid'";
			$result = mysql_query($sql, $conn) or die(mysql_error());
			while ($ap_array = mysql_fetch_array($result))
			{
				$ssid = $ap_array['ssid'];
			    $mac = $ap_array['mac'];
			    $chan = $ap_array['chan'];
				$radio = $ap_array['radio'];
				$auth = $ap_array['auth'];
				$encry = $ap_array['encry'];
			    echo '<tr><td align="center">'.$flag.'</td><td align="center">'.$apid.'</td><td align="center">'.$row.'</td><td align="center"><a class="links" href="fetch.php?id='.$apid.'&token='.$_SESSION['token'].'">'.$ssid.'</a></td>';
			    echo '<td align="center">'.$mac.'</td>';
			    echo '<td align="center">'.$auth.'</td>';
				if($radio=="a")
				{$radio="802.11a";}
				elseif($radio=="b")
				{$radio="802.11b";}
				elseif($radio=="g")
				{$radio="802.11g";}
				elseif($radio=="n")
				{$radio="802.11n";}
				else
				{$radio="Unknown Radio";}
				echo '<td align="center">'.$encry.'</td>';
				echo '<td align="center">'.$radio.'</td>';
				echo '<td align="center">'.$chan.'</td></tr>';
			}
		}
		echo "</table><br>";
		$end = microtime(true);
				if ($GLOBALS["bench"]  == 1)
				{
					echo "Time is [Unix Epoc]<BR>";
					echo "Start Time: ".$start."<BR>";
					echo "  End Time: ".$end."<BR>";
				}
	}
	
	
	#========================================================================================================================#
	#													Export to Google KML File											 #
	#========================================================================================================================#

	function exp_kml($export = "", $user = "", $row = 0)
	{
		include('config.inc.php');
		include('manufactures.inc.php');
		switch ($export)
		{
			#--------------------#
			#-					-#
			#--------------------#
			case "exp_all_db_kml":
				$start = microtime(true);
				echo '<table style="border-style: solid; border-width: 1px"><tr class="style4"><th colspan="2" style="border-style: solid; border-width: 1px">Start of WiFi DB export to KML</th></tr>';
				mysql_select_db($db,$conn) or die("Unable to select Database:".$db);
				$sql = "SELECT * FROM `$wtable`";
				$result = mysql_query($sql, $conn) or die(mysql_error($conn));
				$total = mysql_num_rows($result);
				$date=date('Y-m-d_H-i-s');
				$file_ext = $date."_full_databse.kml";
				$filename = ($kml_out.$file_ext);
				// define initial write and appends
				$filewrite = fopen($filename, "w");
				$fileappend = fopen($filename, "a");
				
				$fdata  =  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n	<kml xmlns=\"$KML_SOURCE_URL\"><!--exp_all_db_kml-->\r\n		<Document>\r\n			<name>RanInt WifiDB KML</name>\r\n";
				$fdata .= "			<Style id=\"openStyleDead\">\r\n		<IconStyle>\r\n				<scale>0.5</scale>\r\n				<Icon>\r\n			<href>".$open_loc."</href>\r\n			</Icon>\r\n			</IconStyle>\r\n			</Style>\r\n";
				$fdata .= "<Style id=\"wepStyleDead\">\r\n<IconStyle>\r\n<scale>0.5</scale>\r\n<Icon>\r\n<href>".$WEP_loc."</href>\r\n</Icon>\r\n</IconStyle>\r\n</Style>\r\n";
				$fdata .= "<Style id=\"secureStyleDead\">\r\n<IconStyle>\r\n<scale>0.5</scale>\r\n<Icon>\r\n<href>".$WPA_loc."</href>\r\n</Icon>\r\n</IconStyle>\r\n</Style>\r\n";
				$fdata .= '<Style id="Location"><LineStyle><color>7f0000ff</color><width>4</width></LineStyle></Style>';
				echo '<tr><td style="border-style: solid; border-width: 1px" colspan="2">Wrote Header to KML File</td><td></td></tr>';
				$x=0;
				$n=0;
				$NN=0;
				$fdata .= "<Folder>\r\n<name>Access Points</name>\r\n<description>APs: ".$total."</description>\r\n";
				$fdata .= "<Folder>\r\n<name>WiFiDB Access Points</name>\r\n";
				echo '<tr><td colspan="2" style="border-style: solid; border-width: 1px">Wrote KML Folder Header</td></tr>';
				while($ap_array = mysql_fetch_array($result))
				{
					$man 		= database::manufactures($ap_array['mac']);
					$id			= $ap_array['id'];
					$ssid_ptb_ = $ap_array['ssid'];
					$ssids_ptb = str_split($ssid_ptb_,25);
					$ssid = smart_quotes($ssids_ptb[0]);
					$mac		= $ap_array['mac'];
					$sectype	= $ap_array['sectype'];
					$radio		= $ap_array['radio'];
					$chan		= $ap_array['chan'];
					$table = $ssid.'-'.$mac.'-'.$sectype.'-'.$radio.'-'.$chan;
					$table_gps = $table.$gps_ext;
					mysql_select_db($db_st,$conn) or die("Unable to select Database:".$db);
					$sql1 = "SELECT * FROM `$table`";
					$result1 = mysql_query($sql1, $conn);
					if(!$result1){continue;}
					$rows = mysql_num_rows($result1);
					$sql = "SELECT * FROM `$table` WHERE `id`='1'";
					$newArray = mysql_fetch_array($result1);
					switch($sectype)
					{
						case 1:
							$type = "#openStyleDead";
							$auth = "Open";
							$encry = "None";
							break;
						case 2:
							$type = "#wepStyleDead";
							$auth = "Open";
							$encry = "WEP";
							break;
						case 3:
							$type = "#secureStyleDead";
							$auth = "WPA-Personal";
							$encry = "TKIP-PSK";
							break;
					}
					switch($radio)
					{
						case "a":
							$radio="802.11a";
							break;
						case "b":
							$radio="802.11b";
							break;
						case "g":
							$radio="802.11g";
							break;
						case "n":
							$radio="802.11n";
							break;
						default:
							$radio="Unknown Radio";
							break;
					}
					
					$otx = $newArray["otx"];
					$btx = $newArray["btx"];
					$nt = $newArray['nt'];
					$label = $newArray['label'];
					
					$sql6 = "SELECT * FROM `$table_gps`";
					$result6 = mysql_query($sql6, $conn);
					$max = mysql_num_rows($result6);
					
					$sql_1 = "SELECT * FROM `$table_gps`";
					$result_1 = mysql_query($sql_1, $conn);
					$zero = 0;
					while($gps_table_first = mysql_fetch_array($result_1))
					{
						$lat_exp = explode(" ", $gps_table_first['lat']);
						
						$test = $lat_exp[1]+0;
						
						if($test == "0"){$zero = 1; continue;}
						
						$date_first = $gps_table_first["date"];
						$time_first = $gps_table_first["time"];
						$fa   = $date_first." ".$time_first;
						$alt  = $gps_table_first['alt'];
						$lat  =& database::convert_dm_dd($gps_table_first['lat']);
						$long =& database::convert_dm_dd($gps_table_first['long']);
						$zero = 0;
						$NN++;
						break;
					}
					if($zero == 1){$zero == 0; continue;}
					//=====================================================================================================//
					
					$sql_2 = "SELECT * FROM `$table_gps` WHERE `id`='$max'";
					$result_2 = mysql_query($sql_2, $conn);
					$gps_table_last = mysql_fetch_array($result_2);
					$date_last = $gps_table_last["date"];
					$time_last = $gps_table_last["time"];
					$la = $date_last." ".$time_last;
					$ssid_name = '';
					if ($named == 1){$ssid_name = $ssid;}
					$fdata .= "<Placemark id=\"".$mac."\">\r\n	<name>".$ssid_name."</name>\r\n	<description><![CDATA[<b>SSID: </b>".$ssid."<br /><b>Mac Address: </b>".$mac."<br /><b>Network Type: </b>".$nt."<br /><b>Radio Type: </b>".$radio."<br /><b>Channel: </b>".$ap['chan']."<br /><b>Authentication: </b>".$auth."<br /><b>Encryption: </b>".$encry."<br /><b>Basic Transfer Rates: </b>".$btx."<br /><b>Other Transfer Rates: </b>".$otx."<br /><b>First Active: </b>".$fa."<br /><b>Last Updated: </b>".$la."<br /><b>Latitude: </b>".$lat."<br /><b>Longitude: </b>".$long."<br /><b>Manufacturer: </b>".$manuf."<br /><a href=\"".$hosturl."/".$root."/opt/fetch.php?id=".$id."\">WiFiDB Link</a>]]></description>\r\n	<styleUrl>".$type."</styleUrl>\r\n<Point id=\"".$mac."_GPS\">\r\n<coordinates>".$long.",".$lat.",".$alt."</coordinates>\r\n</Point>\r\n</Placemark>\r\n";
					echo '<tr><td style="border-style: solid; border-width: 1px">'.$NN.'<td style="border-style: solid; border-width: 1px">Wrote AP: '.$ssid.'</td></tr>';
					unset($lat);
					unset($long);
					unset($gps_table_first["lat"]);
					unset($gps_table_first["long"]);
				}
				if($zero == 0)
				{
					fwrite( $fileappend, $fdata."	</Folder>\r\n	</Folder>\r\n	</Document>\r\n</kml>");
					fclose( $fileappend );
					echo '<tr class="style4"><td colspan="2" style="border-style: solid; border-width: 1px">Your Google Earth KML file is ready,<BR>you can download it from <a class="links" href="'.$filename.'">Here</a></td></tr></table>';
				}else
				{
					echo '<tr><td colspan="2" style="border-style: solid; border-width: 1px">No GPS Data, Skipping Access Point: '.$ssid.'</td></tr>';
					echo '<tr class="style4"><td colspan="2" style="border-style: solid; border-width: 1px">Your Google Earth KML file is NOT ready.</td></tr></table>';
				}
				mysql_close($conn);
				$end = microtime(true);
				if ($GLOBALS["bench"]  == 1)
				{
					echo "Time is [Unix Epoc]<BR>";
					echo "Start Time: ".$start."<BR>";
					echo "  End Time: ".$end."<BR>";
				}
				break;
			#--------------------#
			#-					-#
			#--------------------#
			case "exp_user_list":
				$start = microtime(true);
				echo '<table style="border-style: solid; border-width: 1px"><tr class="style4"><th style="border-style: solid; border-width: 1px" colspan="2">Start of export Users List to KML</th></tr>';
				if($row == 0)
				{
					$sql_row = "SELECT * FROM `users` ORDER BY `id` DESC LIMIT 1";
					$result_row = mysql_query($sql_row, $conn) or die(mysql_error());
					$row_array = mysql_fetch_array($result_row);
					$row = $row_array['id'];
				}
				mysql_select_db($db,$conn) or die("Unable to select Database:".$db);
				$sql = "SELECT * FROM `users` WHERE `id`='$row'";
				$result = mysql_query($sql, $conn) or die(mysql_error());
				$user_array = mysql_fetch_array($result);
				
				$aps = explode("-" , $user_array["points"]);
				
				$date=date('Y-m-d_H-i-s');
				
				if ($user_array["title"]==""){$title = "UNTITLED";}else{$title=$user_array["title"];}
				if ($user_array["username"]==""){$user = "Uknnown";}else{$user=$user_array["username"];}
				echo '<tr class="style4"><td colspan="2" align="center" style="border-style: solid; border-width: 1px">Username: '.$user.'</td></tr>'
					.'<tr class="style4"><td colspan="2" align="center" style="border-style: solid; border-width: 1px">Title: '.$title.'</td></tr>';
				$file_ext = $title.'-'.$date.'.kml';
				$filename = ($kml_out.$file_ext);
				// define initial write and appends
				$filewrite = fopen($filename, "w");
				$fileappend = fopen($filename, "a");
				// open file and write header:
				fwrite($fileappend, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n	<kml xmlns=\"$KML_SOURCE_URL\">\r\n<!--exp_user_list-->		<Document>\r\n			<name>User: ".$user." - Title: ".$title."</name>\r\n");
				fwrite($fileappend, "			<Style id=\"openStyleDead\">\r\n		<IconStyle>\r\n				<scale>0.5</scale>\r\n				<Icon>\r\n			<href>".$open_loc."</href>\r\n			</Icon>\r\n			</IconStyle>\r\n			</Style>\r\n");
				fwrite($fileappend, "<Style id=\"wepStyleDead\">\r\n<IconStyle>\r\n<scale>0.5</scale>\r\n<Icon>\r\n<href>".$WEP_loc."</href>\r\n</Icon>\r\n</IconStyle>\r\n</Style>\r\n");
				fwrite($fileappend, "<Style id=\"secureStyleDead\">\r\n<IconStyle>\r\n<scale>0.5</scale>\r\n<Icon>\r\n<href>".$WPA_loc."</href>\r\n</Icon>\r\n</IconStyle>\r\n</Style>\r\n");
				fwrite($fileappend, '<Style id="Location"><LineStyle><color>7f0000ff</color><width>4</width></LineStyle></Style>');
				echo '<tr><td colspan="2" style="border-style: solid; border-width: 1px">Wrote Header to KML File</td><td></td></tr>';
				$x=0;
				$n=0;
				$total = count($aps);
				fwrite( $fileappend, "<Folder>\r\n<name>Access Points</name>\r\n<description>APs: ".$total."</description>\r\n");
				fwrite( $fileappend, "<Folder>\r\n<name>".$title." Access Points</name>\r\n");
				echo '<tr><td colspan="2" style="border-style: solid; border-width: 1px">Wrote KML Folder Header</td></tr>';
				$NN=0;
				foreach($aps as $ap)
				{
					$ap_exp = explode("," , $ap);
					$apid_exp = explode(":",$ap_exp[1]);
					if($ap_exp[0] == 1){continue;}
					$apid = $apid_exp[0];
					$update_row = $apid_exp[1];
					$udflag = $ap_exp[0];
					
					mysql_select_db($db,$conn) or die("Unable to select Database:".$db);
					$sql0 = "SELECT * FROM `$wtable` WHERE `id`='$apid'";
					$result0 = mysql_query($sql0, $conn) or die(mysql_error());
					$newArray = mysql_fetch_array($result0);
					
					$id = $newArray['id'];
					$ssids_ptb = str_split(smart_quotes($newArray['ssid']),25);
					$ssid = $ssids_ptb[0];
					$mac = $newArray['mac'];
					$man =& database::manufactures($mac);
					$chan = $newArray['chan'];
					$r = $newArray["radio"];
					$auth = $newArray['auth'];
					$encry = $newArray['encry'];
					$sectype = $newArray['sectype'];
					switch($sectype)
					{
						case 1:
							$type = "#openStyleDead";
							$auth = "Open";
							$encry = "None";
							break;
						case 2:
							$type = "#wepStyleDead";
							$auth = "Open";
							$encry = "WEP";
							break;
						case 3:
							$type = "#secureStyleDead";
							$auth = "WPA-Personal";
							$encry = "TIKP";
							break;
					}
					
					switch($r)
					{
						case "a":
							$radio="802.11a";
							break;
						case "b":
							$radio="802.11b";
							break;
						case "g":
							$radio="802.11g";
							break;
						case "n":
							$radio="802.11n";
							break;
						default:
							$radio="Unknown Radio";
							break;
					}
					
					$table=$ssid.'-'.$mac.'-'.$sectype.'-'.$r.'-'.$chan;
					mysql_select_db($db_st) or die("Unable to select Database: ".$db_st);
					
					$sql = "SELECT * FROM `$table` WHERE `id`='$update_row'";
					$result = mysql_query($sql, $conn);
					$AP_table = mysql_fetch_array($result);
					$otx = $AP_table["otx"];
					$btx = $AP_table["btx"];
					$nt = $AP_table['nt'];
					$label = $AP_table['label'];
					$table_gps = $table.$gps_ext;
					
					$sql6 = "SELECT * FROM `$table_gps`";
					$result6 = mysql_query($sql6, $conn);
					$max = mysql_num_rows($result6);
					
					$sql = "SELECT * FROM `$table_gps`";
					$result = mysql_query($sql, $conn);
					while($gps_table_first = mysql_fetch_array($result))
					{
						$lat_exp = explode(" ", $gps_table_first['lat']);
						
						$test = $lat_exp[1]+0;
						
						if($test == "0.0000"){$zero = 1; continue;}
						
						$date_first = $gps_table_first["date"];
						$time_first = $gps_table_first["time"];
						$fa = $date_first." ".$time_first;
						$alt = $gps_table_first['alt'];
						$lat =& database::convert_dm_dd($gps_table_first['lat']);
						$long =& database::convert_dm_dd($gps_table_first['long']);
						$zero = 0;
						$NN++;
						break;
					}
					if($zero == 1){echo '<tr><td colspan="2" style="border-style: solid; border-width: 1px">No GPS Data, Skipping Access Point: '.$ssid.'</td></tr>'; $zero == 0; continue;}
					
					$sql_1 = "SELECT * FROM `$table_gps` WHERE `id`='$max'";
					$result_1 = mysql_query($sql_1, $conn);
					$gps_table_last = mysql_fetch_array($result_1);
					$date_last = $gps_table_last["date"];
					$time_last = $gps_table_last["time"];
					$la = $date_last." ".$time_last;
					$ssid_name = '';
					if ($named == 1){$ssid_name = $ssid;}
					fwrite( $fileappend, "<Placemark id=\"".$mac."\">\r\n	<name>".$ssid_name."</name>\r\n	<description><![CDATA[<b>SSID: </b>".$ssid."<br /><b>Mac Address: </b>".$mac."<br /><b>Network Type: </b>".$nt."<br /><b>Radio Type: </b>".$radio."<br /><b>Channel: </b>".$chan."<br /><b>Authentication: </b>".$auth."<br /><b>Encryption: </b>".$encry."<br /><b>Basic Transfer Rates: </b>".$btx."<br /><b>Other Transfer Rates: </b>".$otx."<br /><b>First Active: </b>".$fa."<br /><b>Last Updated: </b>".$la."<br /><b>Latitude: </b>".$lat."<br /><b>Longitude: </b>".$long."<br /><b>Manufacturer: </b>".$man."<br /><a href=\"<a href=\"".$hosturl."/".$root."/opt/fetch.php?id=".$id."\">WiFiDB Link</a>]]></description>\r\n	<styleUrl>".$type."</styleUrl>\r\n	");
					fwrite( $fileappend, "<Point id=\"".$mac."_GPS\">\r\n<coordinates>".$long.",".$lat.",".$alt."</coordinates>\r\n</Point>\r\n</Placemark>\r\n");
					echo '<tr><td style="border-style: solid; border-width: 1px">'.$NN.'</td><td style="border-style: solid; border-width: 1px">Wrote AP: '.$ssid.'</td></tr>';
					unset($gps_table_first["lat"]);
					unset($gps_table_first["long"]);
					
				}
				fwrite( $fileappend, "	</Folder>\r\n");
				fwrite( $fileappend, "	</Folder>\r\n	</Document>\r\n</kml>");
				fclose( $fileappend );
				echo '<tr class="style4"><td colspan="2" style="border-style: solid; border-width: 1px">Your Google Earth KML file is ready,<BR>you can download it from <a class="links" href="'.$filename.'">Here</a></td></tr></table>';
				mysql_close($conn);
				$end = microtime(true);
				if ($GLOBALS["bench"]  == 1)
				{
					echo "Time is [Unix Epoc]<BR>";
					echo "Start Time: ".$start."<BR>";
					echo "  End Time: ".$end."<BR>";
				}
				break;
			#--------------------#
			#-					-#
			#--------------------#
			case "exp_single_ap":
				$start = microtime(true);
				$NN=0;
				$date=date('Y-m-d_H-i-s');
				$sql = "SELECT * FROM `$wtable` WHERE `ID`='$row'";
				$result = mysql_query($sql, $conn) or die(mysql_error());
				$aparray = mysql_fetch_array($result);
				
				$file_ext = $aparray['ssid']."-".$aparray['mac']."-".$aparray['sectype']."-".$date.".kml";
				echo '<table style="border-style: solid; border-width: 1px"><tr class="style4"><th style="border-style: solid; border-width: 1px">Start export of Single AP: '.$aparray["ssid"].'</th></tr>';
				$filename = ($kml_out.$file_ext);
				// define initial write and appends
				$filewrite = fopen($filename, "w");
				if($filewrite != FALSE)
				{
					$file_data  = ("");
					$file_data .= ("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n<kml xmlns=\"$KML_SOURCE_URL\">\r\n<!--exp_single_ap--><Document>\r\n<name>RanInt WifiDB KML</name>\r\n");
					$file_data .= ("<Style id=\"openStyleDead\">\r\n<IconStyle>\r\n<scale>0.5</scale>\r\n<Icon>\r\n<href>http://www.vistumbler.net/images/program-images/open.png</href>\r\n</Icon>\r\n</IconStyle>\r\n</Style>\r\n");
					$file_data .= ("<Style id=\"wepStyleDead\">\r\n<IconStyle>\r\n<scale>0.5</scale>\r\n<Icon>\r\n<href>http://www.vistumbler.net/images/program-images/secure-wep.png</href>\r\n</Icon>\r\n</IconStyle>\r\n</Style>\r\n");
					$file_data .= ("<Style id=\"secureStyleDead\">\r\n<IconStyle>\r\n<scale>0.5</scale>\r\n<Icon>\r\n<href>http://www.vistumbler.net/images/program-images/secure.png</href>\r\n</Icon>\r\n</IconStyle>\r\n</Style>\r\n");
					$file_data .= ('<Style id="Location"><LineStyle><color>7f0000ff</color><width>4</width></LineStyle></Style>');
					echo '<tr><td style="border-style: solid; border-width: 1px">Wrote Header to KML File</td><td></td></tr>';
					// open file and write header:
					
					$manuf =& database::manufactures($aparray['mac']);
					$ssids_ptb = str_split(smart_quotes($aparray['ssid']),25);
					$ssid = $ssids_ptb[0];
					$table=$ssid.'-'.$aparray['mac'].'-'.$aparray['sectype'].'-'.$aparray['radio'].'-'.$aparray['chan'];
					$table_gps = $table.$gps_ext;
					mysql_select_db($db_st,$conn) or die("Unable to select Database:".$db);
		#			echo $table."<br>";
					$sql = "SELECT * FROM `$table`";
					$result = mysql_query($sql, $conn) or die(mysql_error());
					$rows = mysql_num_rows($result);
		#			echo $rows."<br>";
					$sql = "SELECT * FROM `$table` WHERE `id`='1'";
					$result1 = mysql_query($sql, $conn) or die(mysql_error());
		#			echo $ap['mac']."<BR>";
					while ($newArray = mysql_fetch_array($result1))
					{
						switch($aparray['sectype'])
						{
							case 1:
								$type = "#openStyleDead";
								break;
							case 2:
								$type = "#wepStyleDead";
								break;
							case 3:
								$type = "#secureStyleDead";
								break;
						}
						
						switch($aparray['radio'])
						{
							case "a":
								$radio="802.11a";
								break;
							case "b":
								$radio="802.11b";
								break;
							case "g":
								$radio="802.11g";
								break;
							case "n":
								$radio="802.11n";
								break;
							default:
								$radio="Unknown Radio";
								break;
						}
						
						$otx = $newArray["otx"];
						$btx = $newArray["btx"];
						$nt = $newArray['nt'];
						$label = $newArray['label'];
						
						$sql6 = "SELECT * FROM `$table_gps`";
						$result6 = mysql_query($sql6, $conn);
						$max = mysql_num_rows($result6);
						
						$sql_1 = "SELECT * FROM `$table_gps`";
						$result_1 = mysql_query($sql_1, $conn);
						while($gps_table_first = mysql_fetch_array($result_1))
						{
							$lat_exp = explode(" ", $gps_table_first['lat']);
							
							$test = $lat_exp[1]+0;
							
							if($test == "0.0000"){$zero = 1; continue;}
							
							$date_first = $gps_table_first["date"];
							$time_first = $gps_table_first["time"];
							$fa = $date_first." ".$time_first;
							$alt = $gps_table_first['alt'];
							$lat =& database::convert_dm_dd($gps_table_first['lat']);
							$long =& database::convert_dm_dd($gps_table_first['long']);
							$zero = 0;
							$NN++;
							break;
						}
						if($zero == 1){echo '<tr><td style="border-style: solid; border-width: 1px">No GPS Data, Skipping Access Point: '.$ssid.'</td></tr>'; $zero == 0; continue;}
						
						$sql_2 = "SELECT * FROM `$table_gps` WHERE `id`='$max'";
						$result_2 = mysql_query($sql_2, $conn);
						$gps_table_last = mysql_fetch_array($result_2);
						$date_last = $gps_table_last["date"];
						$time_last = $gps_table_last["time"];
						$la = $date_last." ".$time_last;
						$ssid_name = '';
						if ($named == 1){$ssid_name = $ssid;}
						$file_data .= ("<Placemark id=\"".$aparray['mac']."\">\r\n	<name>".$ssid_name."</name>\r\n	<description><![CDATA[<b>SSID: </b>".$ssid."<br /><b>Mac Address: </b>".$aparray['mac']."<br /><b>Network Type: </b>".$nt."<br /><b>Radio Type: </b>".$radio."<br /><b>Channel: </b>".$aparray['chan']."<br /><b>Authentication: </b>".$aparray['auth']."<br /><b>Encryption: </b>".$aparray['encry']."<br /><b>Basic Transfer Rates: </b>".$btx."<br /><b>Other Transfer Rates: </b>".$otx."<br /><b>First Active: </b>".$fa."<br /><b>Last Updated: </b>".$la."<br /><b>Latitude: </b>".$lat."<br /><b>Longitude: </b>".$long."<br /><b>Manufacturer: </b>".$manuf."<br /><a href=\"".$hosturl."/".$root."/opt/fetch.php?id=".$aparray['id']."\">WiFiDB Link</a>]]></description>\r\n	<styleUrl>".$type."</styleUrl>\r\n<Point id=\"".$aparray['mac']."_GPS\">\r\n<coordinates>".$long.",".$lat.",".$alt."</coordinates>\r\n</Point>\r\n</Placemark>\r\n");
						echo '<tr><td style="border-style: solid; border-width: 1px">Wrote AP: '.$ssid.'</td></tr>';
					}
				}else
				{
					echo "Failed to write KML File, Check the permissions on the wifidb folder, and make sure that Apache (or what ever HTTP server you are using) has permissions to write";
				}
				$fileappend = fopen($filename, "a");
				fwrite($fileappend, $file_data);
				fwrite( $fileappend, "	</Document>\r\n</kml>");
				
				fclose( $fileappend );
				echo '<tr class="style4"><td style="border-style: solid; border-width: 1px">Your Google Earth KML file is ready,<BR>you can download it from <a class="links" href="'.$filename.'">Here</a></td></tr></table>';
				mysql_close($conn);
				$end = microtime(true);
				if ($GLOBALS["bench"]  == 1)
				{
					echo "Time is [Unix Epoc]<BR>";
					echo "Start Time: ".$start."<BR>";
					echo "  End Time: ".$end."<BR>";
				}
				break;
			#--------------------#
			#-					-#
			#--------------------#
			case "exp_user_all_kml":
				include('config.inc.php');
				$start = microtime(true);
				mysql_select_db($db,$conn) or die("Unable to select Database:".$db);
				echo '<table style="border-style: solid; border-width: 1px"><tr class="style4"><th style="border-style: solid; border-width: 1px" colspan="2">Start export of all APs for User: '.$user.', to KML</th></tr>';
				$ap_id = array();
				$sql = "SELECT `points` FROM `users` WHERE `username`='$user'";
				$result = mysql_query($sql, $conn);
				while($points = mysql_fetch_array($result))
				{
					$points_exp = explode("-",$points['points']);
					foreach($points_exp as $point)
					{
						$points2 = explode(",", $point);
						if($points2[0] == 1){continue;}
						$point_ = explode(":", $points2[1]);
						$ap_id[] = array(
											'id'	=> $point_[0],
											'row'	=> $point_[1]
										  );
					}
				}
				#var_dump($ap_id);
				$date=date('Y-m-d_H-i-s');
				
				$file_ext = $date."_".$user."_all_AP.kml";
				$filename = ($kml_out.$file_ext);
				// define initial write and appends
				$filewrite = fopen($filename, "w");
				$fileappend = fopen($filename, "a");
				// open file and write header:
				$total = count($ap_id);
				fwrite($fileappend, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n	<kml xmlns=\"".$KML_SOURCE_URL."\">\r\n<!--exp_user_all_kml--><Document>\r\n<name>RanInt WifiDB KML</name>\r\n");
				fwrite($fileappend, "<Style id=\"openStyleDead\">\r\n<IconStyle>\r\n<scale>0.5</scale>\r\n<Icon>\r\n<href>".$open_loc."</href>\r\n</Icon>\r\n</IconStyle>\r\n</Style>\r\n");
				fwrite($fileappend, "<Style id=\"wepStyleDead\">\r\n<IconStyle>\r\n<scale>0.5</scale>\r\n<Icon>\r\n<href>".$WEP_loc."</href>\r\n</Icon>\r\n</IconStyle>\r\n</Style>\r\n");
				fwrite($fileappend, "<Style id=\"secureStyleDead\">\r\n<IconStyle>\r\n<scale>0.5</scale>\r\n<Icon>\r\n<href>".$WPA_loc."</href>\r\n</Icon>\r\n</IconStyle>\r\n</Style>\r\n");
				fwrite($fileappend, '<Style id="Location"><LineStyle><color>7f0000ff</color><width>4</width></LineStyle></Style>');
				fwrite( $fileappend, "<Folder>\r\n<name>WiFiDB Access Points</name>\r\n<description>Total Number of APs: ".$total."</description>\r\n");
				fwrite( $fileappend, "<Folder>\r\n<name>Access Points for User: ".$user."</name>\r\n");
				echo '<tr><td colspan="2" style="border-style: solid; border-width: 1px">Wrote Header to KML File</td></tr>';
				$NN = 0;
				foreach($ap_id as $ap)
				{
					mysql_select_db($db,$conn) or die("Unable to select Database:".$db);
					$id = $ap['id'];
					$rows = $ap['row'];
					
					$sql = "SELECT * FROM `$wtable` WHERE `id`='$id'";
					$result = mysql_query($sql, $conn);
					$aps = mysql_fetch_array($result);
					
					$ssids_ptb = str_split(smart_quotes($aps['ssid']),25);
					$ssid = $ssids_ptb[0];
					$mac = $aps['mac'];
					$sectype = $aps['sectype'];
					$r = $aps['radio'];
					$chan = $aps['chan'];
					$manuf =& database::manufactures($mac);
					
					$table = $ssid.'-'.$mac.'-'.$sectype.'-'.$r.'-'.$chan;
					$table_gps = $table.$gps_ext;
					
					switch($r)
						{
							case "a":
								$radio="802.11a";
								break;
							case "b":
								$radio="802.11b";
								break;
							case "g":
								$radio="802.11g";
								break;
							case "n":
								$radio="802.11n";
								break;
							case "u":
								$radio="802.11u";
								break;
							default:
							$radio="Unknown Radio";
								break;
						}
					switch($sectype)
						{
							case 1:
								$type = "#openStyleDead";
								$auth = "Open";
								$encry = "None";
								break;
							case 2:
								$type = "#wepStyleDead";
								$auth = "Open";
								$encry = "WEP";
								break;
							case 3:
								$type = "#secureStyleDead";
								$auth = "WPA-Personal";
								$encry = "TKIP-PSK";
								break;
						}
					mysql_select_db($db_st,$conn) or die("Unable to select Database:".$db_st);
					$sql = "SELECT * FROM `$table` WHERE `id`='$rows'";
					$result1 = mysql_query($sql, $conn) or die(mysql_error());
					
					while ($newArray = mysql_fetch_array($result1))
					{
						$otx = $newArray["otx"];
						$btx = $newArray["btx"];
						$nt = $newArray['nt'];
						$label = $newArray['label'];
						
						$signal_exp = explode("-", $newArray['sig']);
						$sig_count = count($signal_exp);
						
						$exp_first = explode("," , $signal_exp[0]);
						$first_sig_gps_id = $exp_first[1];
						
						$exp_last = explode("," , $signal_exp[$sig_count-1]);
						$last_sig_gps_id = $exp_last[1];
						
						$sql6 = "SELECT * FROM `$table_gps`";
						$result6 = mysql_query($sql6, $conn);
						$max = mysql_num_rows($result6);
						
						$sql_1 = "SELECT * FROM `$table_gps`";
						$result_1 = mysql_query($sql_1, $conn);
						$zero = 0;
						while($gps_table_first = mysql_fetch_array($result_1))
						{
							$lat_exp = explode(" ", $gps_table_first['lat']);
							$date_first = $gps_table_first["date"];
							$time_first = $gps_table_first["time"];
							$fa = $date_first." ".$time_first;
							$test = $lat_exp[1]+0;
							
							if($test == "0.0000"){$zero = 1; continue;}
							
							
							$alt = $gps_table_first['alt'];
							$lat =& database::convert_dm_dd($gps_table_first['lat']);
							$long =& database::convert_dm_dd($gps_table_first['long']);
							$zero = 0;
							$NN++;
							break;
						}
						if($zero == 1){echo '<tr><td colspan="2" style="border-style: solid; border-width: 1px">No GPS Data, Skipping Access Point: '.$aps['ssid'].'</td></tr>'; $zero == 0; continue;}
						
						$sql_2 = "SELECT * FROM `$table_gps` WHERE `id`='$last_sig_gps_id'";
						$result_2 = mysql_query($sql_2, $conn);
						$gps_table_last = mysql_fetch_array($result_2);
						$date_last = $gps_table_last["date"];
						$time_last = $gps_table_last["time"];
						$la = $date_last." ".$time_last;
						$ssid_name = '';
						if ($named == 1){$ssid_name = $aps['ssid'];}
						fwrite( $fileappend, "<Placemark id=\"".$mac."\">\r\n	<name>".$ssid_name."</name>\r\n	<description><![CDATA[<b>SSID: </b>".$aps['ssid']."<br /><b>Mac Address: </b>".$mac."<br /><b>Network Type: </b>".$nt."<br /><b>Radio Type: </b>".$radio."<br /><b>Channel: </b>".$chan."<br /><b>Authentication: </b>".$auth."<br /><b>Encryption: </b>".$encry."<br /><b>Basic Transfer Rates: </b>".$btx."<br /><b>Other Transfer Rates: </b>".$otx."<br /><b>First Active: </b>".$fa."<br /><b>Last Updated: </b>".$la."<br /><b>Latitude: </b>".$lat."<br /><b>Longitude: </b>".$long."<br /><b>Manufacturer: </b>".$manuf."<br /><a href=\"".$hosturl."/".$root."/opt/fetch.php?id=".$id."\">WiFiDB Link</a>]]></description>\r\n	<styleUrl>".$type."</styleUrl>\r\n<Point id=\"".$mac."_GPS\">\r\n<coordinates>".$long.",".$lat.",".$alt."</coordinates>\r\n</Point>\r\n</Placemark>\r\n");
						echo '<tr><td style="border-style: solid; border-width: 1px">'.$NN.'</td><td style="border-style: solid; border-width: 1px">Wrote AP: '.$aps['ssid'].'</td></tr>';
						
						unset($gps_table_first["lat"]);
						unset($gps_table_first["long"]);
					}
				}
				fwrite( $fileappend, "	</Folder>\r\n");
				fwrite( $fileappend, "	</Folder>\r\n	</Document>\r\n</kml>");
				fclose( $fileappend );
				echo '<tr class="style4"><td colspan="2" style="border-style: solid; border-width: 1px">Your Google Earth KML file is ready,<BR>you can download it from <a class="links" href="'.$filename.'">Here</a></td></tr></table>';
				mysql_close($conn);
				$end = microtime(true);
				if ($GLOBALS["bench"]  == 1)
				{
					echo "Time is [Unix Epoc]<BR>";
					echo "Start Time: ".$start."<BR>";
					echo "  End Time: ".$end."<BR>";
				}
				break;
			#--------------------#
			#-					-#
			#--------------------#
			case "exp_newest_kml":
				$date=date('Y-m-d_H-i-s');
				$start = microtime(true);
				$sql = "SELECT * FROM `$wtable`";
				$result = mysql_query($sql, $conn) or die(mysql_error());
				$rows = mysql_num_rows($result);
				
				$sql = "SELECT * FROM `$wtable` WHERE `id`='$rows'";
				$result = mysql_query($sql, $conn) or die(mysql_error());
				$ap_array = mysql_fetch_array($result);
				$manuf =& database::manufactures($ap_array['mac']);
				$file_ext = "Newest_AP_".$date.".kml";
				echo '<table style="border-style: solid; border-width: 1px"><tr class="style4"><th style="border-style: solid; border-width: 1px">Start export of Newest AP: '.$ap_array["ssid"].'</th></tr>';
				$filename = ($kml_out.$file_ext);
				// define initial write and appends
				$filewrite = fopen($filename, "w");
				if($filewrite != FALSE)
				{
					$file_data  = ("");
					$file_data .= ("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n<kml xmlns=\"$KML_SOURCE_URL\">\r\n<!--exp_newest_kml--><Document>\r\n<name>RanInt WifiDB KML</name>\r\n");
					$file_data .= ("<Style id=\"openStyleDead\">\r\n<IconStyle>\r\n<scale>0.5</scale>\r\n<Icon>\r\n<href>http://www.vistumbler.net/images/program-images/open.png</href>\r\n</Icon>\r\n</IconStyle>\r\n</Style>\r\n");
					$file_data .= ("<Style id=\"wepStyleDead\">\r\n<IconStyle>\r\n<scale>0.5</scale>\r\n<Icon>\r\n<href>http://www.vistumbler.net/images/program-images/secure-wep.png</href>\r\n</Icon>\r\n</IconStyle>\r\n</Style>\r\n");
					$file_data .= ("<Style id=\"secureStyleDead\">\r\n<IconStyle>\r\n<scale>0.5</scale>\r\n<Icon>\r\n<href>http://www.vistumbler.net/images/program-images/secure.png</href>\r\n</Icon>\r\n</IconStyle>\r\n</Style>\r\n");
					$file_data .= ('<Style id="Location"><LineStyle><color>7f0000ff</color><width>4</width></LineStyle></Style>');
					echo '<tr><td style="border-style: solid; border-width: 1px">Wrote Header to KML File</td></tr>';
					// open file and write header:
					$ssids_ptb = str_split(smart_quotes($ap_array['ssid']),25);
					$ssid = $ssids_ptb[0];
					$table=$ssid.'-'.$ap_array['mac'].'-'.$ap_array['sectype'].'-'.$ap_array['radio'].'-'.$ap_array['chan'];
					$table_gps = $table.$gps_ext;
					mysql_select_db($db_st,$conn) or die("Unable to select Database:".$db);
		#			echo $table."<br>";
					$sql = "SELECT * FROM `$table`";
					$result = mysql_query($sql, $conn) or die(mysql_error());
					$rows = mysql_num_rows($result);
		#			echo $rows."<br>";
					$sql = "SELECT * FROM `$table` WHERE `id`='1'";
					$result1 = mysql_query($sql, $conn) or die(mysql_error());
					$newArray = mysql_fetch_array($result1);
		#			echo $ap['mac']."<BR>";
					switch($ap_array['sectype'])
						{
							case 1:
								$type = "#openStyleDead";
								$auth = "Open";
								$encry = "None";
								break;
							case 2:
								$type = "#wepStyleDead";
								$auth = "Open";
								$encry = "WEP";
								break;
							case 3:
								$type = "#secureStyleDead";
								$auth = "WPA-Personal";
								$encry = "TKIP-PSK";
								break;
						}
						
					switch($ap_array['radio'])
						{
							case "a":
								$radio="802.11a";
								break;
							case "b":
								$radio="802.11b";
								break;
							case "g":
								$radio="802.11g";
								break;
							case "n":
								$radio="802.11n";
								break;
							default:
								$radio="Unknown Radio";
								break;
						}
					$otx = $newArray["otx"];
					$btx = $newArray["btx"];
					$nt = $newArray['nt'];
					$label = $newArray['label'];
					
					$sql6 = "SELECT * FROM `$table_gps`";
					$result6 = mysql_query($sql6, $conn);
					$max = mysql_num_rows($result6);
					
					$sql_1 = "SELECT * FROM `$table_gps`";
					$result_1 = mysql_query($sql_1, $conn);
					while($gps_table_first = mysql_fetch_array($result_1))
					{
						$lat_exp = explode(" ", $gps_table_first['lat']);
						
						$test = $lat_exp[1]+0;
						
						if($test == "0.0000"){$zero = 1; continue;}
						
						$date_first = $gps_table_first["date"];
						$time_first = $gps_table_first["time"];
						$fa = $date_first." ".$time_first;
						$alt = $gps_table_first['alt'];
						$lat =& database::convert_dm_dd($gps_table_first['lat']);
						$long =& database::convert_dm_dd($gps_table_first['long']);
						$zero = 0;
						break;
					}
					if($zero == 1){echo '<tr><td style="border-style: solid; border-width: 1px">No GPS Data, Skipping Access Point: '.$ap_array['ssid'].'</td></tr>'; $zero == 0; continue;}
					{
						?>
						<tr>
							<td style="border-style: solid; border-width: 1px">No GPS Data, Skipping Access Point:
							<?php
							echo $ap_array["ssid"];
							?>
							</td>
						</tr>
						<tr>
							<td style="border-style: solid; border-width: 1px">Your Google Earth KML file is not ready, 
																				There where no GPS cords to plot.</td>
							<td></td>
						</tr>
						</table>
						<?php
						$end = microtime(true);
						if ($GLOBALS["bench"]  == 1)
						{
							echo "Time is [HH:MM:SS.UU]<BR>";
							echo "Start Time: ".$start."<BR>";
							echo "  End Time: ".$end."<BR>";
						}
						continue;
					}
					
					$sql_2 = "SELECT * FROM `$table_gps` WHERE `id`='$max'";
					$result_2 = mysql_query($sql_2, $conn);
					$gps_table_last = mysql_fetch_array($result_2);
					$date_last = $gps_table_last["date"];
					$time_last = $gps_table_last["time"];
					$la = $date_last." ".$time_last;
					$ssid_name = '';
					if ($named == 1){$ssid_name = $ssid;}
					$file_data .= ("<Placemark id=\"".$ap_array['mac']."\">\r\n	<name>".$ssid_name."</name>\r\n	<description><![CDATA[<b>SSID: </b>".$ap_array['ssid']."<br /><b>Mac Address: </b>".$ap_array['mac']."<br /><b>Network Type: </b>".$nt."<br /><b>Radio Type: </b>".$radio."<br /><b>Channel: </b>".$ap_array['chan']."<br /><b>Authentication: </b>".$auth."<br /><b>Encryption: </b>".$encry."<br /><b>Basic Transfer Rates: </b>".$btx."<br /><b>Other Transfer Rates: </b>".$otx."<br /><b>First Active: </b>".$fa."<br /><b>Last Updated: </b>".$la."<br /><b>Latitude: </b>".$lat."<br /><b>Longitude: </b>".$long."<br /><b>Manufacturer: </b>".$manuf."<br /><a href=\"".$hosturl."/".$root."/opt/fetch.php?id=".$ap_array['id']."\">WiFiDB Link</a>]]></description>\r\n	<styleUrl>".$type."</styleUrl>\r\n<Point id=\"".$ap_array['mac']."_GPS\">\r\n<coordinates>".$long.",".$lat.",".$alt."</coordinates>\r\n</Point>\r\n</Placemark>\r\n");
					echo '<tr><td style="border-style: solid; border-width: 1px">Wrote AP: '.$ap_array['ssid'].'</td></tr>';
				}else
				{
					echo "Failed to write KML File, Check the permissions on the wifidb folder, and make sure that Apache (or what ever HTTP server you are using) has permissions to write";
				}
				$fileappend = fopen($filename, "a");
				fwrite($fileappend, $filedata);
				fclose( $fileappend );
				echo '<tr class="style4"><td style="border-style: solid; border-width: 1px" colspan="2">Your Google Earth KML file is ready,<BR>you can download it from <a class="links" href="'.$filename.'">Here</a></td></tr></table>';
				mysql_close($conn);
				$end = microtime(true);
				if ($GLOBALS["bench"]  == 1)
				{
					echo "Time is [Unix Epoc]<BR>";
					echo "Start Time: ".$start."<BR>";
					echo "  End Time: ".$end."<BR>";
				}
				break;
			#--------------------#
			#-					-#
			#--------------------#
			case "exp_all_signal":
				$start = microtime(true);
				$NN=0;
				$signal_image ='';
				$row_id_exp = explode(",",$row);
				$id = $row_id_exp[1];
				$row = $row_id_exp[0];
				$date=date('Y-m-d_H-i-s');
				$sql = "SELECT * FROM `$db`.`$wtable` WHERE `ID`='$id'";
				$result = mysql_query($sql, $conn) or die(mysql_error());
				$aparray = mysql_fetch_array($result);
				$ssid_array = make_ssid($aparray['ssid']);
				$ssid_t = $ssid_array[0];
				$ssid_f = $ssid_array[1];
				$ssid = $ssid_array[2];
				$file_ext = $ssid_f."-".$aparray['mac']."-".$aparray['sectype']."-".$date.".kml";
				echo '<table style="border-style: solid; border-width: 1px"><tr class="style4"><th style="border-style: solid; border-width: 1px">Start export of Single AP: '.$ssid.'\'s Signal History</th></tr>';
				$filename = ($kml_out.$file_ext);
				// define initial write and appends
				$filewrite = fopen($filename, "w");
				if($filewrite != FALSE)
				{
					$table=$ssid_t.'-'.$aparray['mac'].'-'.$aparray['sectype'].'-'.$aparray['radio'].'-'.$aparray['chan'];
					$table_gps = $table.$gps_ext;
					
					$file_data  = ("");
					$file_data .= ("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n<kml xmlns=\"".$KML_SOURCE_URL."\">\r\n<!--exp_all_signal--><Document>\r\n<name>".$table."</name>\r\n");
					$file_data .= ("<Style id=\"openStyleDead\">\r\n<IconStyle>\r\n<scale>0.5</scale>\r\n<Icon>\r\n<href>http://www.vistumbler.net/images/program-images/open.png</href>\r\n</Icon>\r\n</IconStyle>\r\n</Style>\r\n");
					$file_data .= ("<Style id=\"wepStyleDead\">\r\n<IconStyle>\r\n<scale>0.5</scale>\r\n<Icon>\r\n<href>http://www.vistumbler.net/images/program-images/secure-wep.png</href>\r\n</Icon>\r\n</IconStyle>\r\n</Style>\r\n");
					$file_data .= ("<Style id=\"secureStyleDead\">\r\n<IconStyle>\r\n<scale>0.5</scale>\r\n<Icon>\r\n<href>http://www.vistumbler.net/images/program-images/secure.png</href>\r\n</Icon>\r\n</IconStyle>\r\n</Style>\r\n");
					$file_data .= ('<Style id="Location"><LineStyle><color>7f0000ff</color><width>4</width></LineStyle></Style>');
					echo '<tr><td style="border-style: solid; border-width: 1px">Wrote Header to KML File</td></tr>';
					// open file and write header:
					
					$manuf =& database::manufactures($aparray['mac']);
					mysql_select_db($db_st,$conn) or die("Unable to select Database:".$db);
		#			echo $table."<br>";
					$sql = "SELECT * FROM `$table`";
					$result = mysql_query($sql, $conn) or die(mysql_error());
					$rows = mysql_num_rows($result);
		#			echo $rows."<br>";
					$sql = "SELECT * FROM `$table` WHERE `id`='$row'";
					$result1 = mysql_query($sql, $conn) or die(mysql_error());
		#			echo $ap['mac']."<BR>";
					$newArray = mysql_fetch_array($result1);
					switch($aparray['sectype'])
					{
						case 1:
							$type = "#openStyleDead";
							break;
						case 2:
							$type = "#wepStyleDead";
							break;
						case 3:
							$type = "#secureStyleDead";
							break;
					}
					
					switch($aparray['radio'])
					{
						case "a":
							$radio="802.11a";
							break;
						case "b":
							$radio="802.11b";
							break;
						case "g":
							$radio="802.11g";
							break;
						case "n":
							$radio="802.11n";
							break;
						default:
							$radio="Unknown Radio";
							break;
					}
					
					$otx = $newArray["otx"];
					$btx = $newArray["btx"];
					$nt = $newArray['nt'];
					$label = $newArray['label'];
					
					$sql6 = "SELECT * FROM `$table_gps`";
					$result6 = mysql_query($sql6, $conn);
					$max = mysql_num_rows($result6);
					
					$sql_1 = "SELECT * FROM `$table_gps`";
					$result_1 = mysql_query($sql_1, $conn);
					while($gps_table = mysql_fetch_array($result_1))
					{
						$lat_exp = explode(" ", $gps_table['lat']);
						$test = $lat_exp[1]+0;
						
						if($test == "0.0000"){$zero = 1; continue;}
						
						$date_first = $gps_table["date"];
						$time_first = $gps_table["time"];
						$fa = $date_first." ".$time_first;
						$alt = $gps_table['alt'];
						$lat =& database::convert_dm_dd($gps_table['lat']);
						$long =& database::convert_dm_dd($gps_table['long']);
						$zero = 0;
						$NN++;
						break;
					}
					if($zero == 1){echo '<tr><td style="border-style: solid; border-width: 1px">No GPS Data, Skipping Access Point: '.$ssid.'</td></tr>'; $zero == 0; continue;}
					
					$sql_2 = "SELECT * FROM `$table_gps` WHERE `id`='$max'";
					$result_2 = mysql_query($sql_2, $conn);
					$gps_table_last = mysql_fetch_array($result_2);
					$date_last = $gps_table_last["date"];
					$time_last = $gps_table_last["time"];
					
					$la = $date_last." ".$time_last;
					$file_data .= ("<Placemark id=\"".$aparray['mac']."\">\r\n	<name>".$ssid."</name>\r\n	<description><![CDATA[<b>SSID: </b>".$ssid."<br /><b>Mac Address: </b>".$aparray['mac']."<br /><b>Network Type: </b>".$nt."<br /><b>Radio Type: </b>".$radio."<br /><b>Channel: </b>".$aparray['chan']."<br /><b>Authentication: </b>".$aparray['auth']."<br /><b>Encryption: </b>".$aparray['encry']."<br /><b>Basic Transfer Rates: </b>".$btx."<br /><b>Other Transfer Rates: </b>".$otx."<br /><b>First Active: </b>".$fa."<br /><b>Last Updated: </b>".$la."<br /><b>Latitude: </b>".$lat."<br /><b>Longitude: </b>".$long."<br /><b>Manufacturer: </b>".$manuf."<br /><a href=\"".$hosturl."/".$root."/opt/fetch.php?id=".$aparray['id']."\">WiFiDB Link</a>]]></description>\r\n	<styleUrl>".$type."</styleUrl>\r\n<Point id=\"".$aparray['mac']."_GPS\">\r\n<coordinates>".$long.",".$lat.",".$alt."</coordinates>\r\n</Point>\r\n</Placemark>\r\n");
					echo '<tr><td style="border-style: solid; border-width: 1px">Wrote AP: '.$ssid.'</td></tr>';
					
					$sql_3 = "SELECT * FROM `$table` WHERE `id`='$row'";
					$sig_result = mysql_query($sql_3, $conn) or die(mysql_error($conn));
					$array = mysql_fetch_array($sig_result);
					$signals = explode("-",$array['sig']);
	#				echo $array['sig'].'<br>';
					foreach($signals as $signal)
					{
						$sig_exp = explode(",",$signal);
						$gpsid = $sig_exp[0];
#						echo $signal.'<br>';
						$sig = $sig_exp[1];
						$sql_1 = "SELECT * FROM `$table_gps` WHERE `id` = '$gpsid'";
						$result_1 = mysql_query($sql_1, $conn);
						$gps = mysql_fetch_array($result_1);
						$lat_exp = explode(" ", $gps['lat']);
						$test = $lat_exp[1]+0;
						if($test == "0.0000"){$zero = 1; continue;}
						
						$alt = $gps['alt'];
		#				echo "IN: ".$gps['lat'].'<br>';
						$lat =& database::convert_dm_dd($gps['lat']);
		#				echo "out: ".$lat.'<br>';
						$long =& database::convert_dm_dd($gps['long']);
						$file_data .= ("<Placemark id=\"".$gps['id']."\"><styleUrl>".$signal_image."</styleUrl>\r\n<description><![CDATA[<b>Signal Strength: </b>".$sig."%<br />]]></description>\r\n<Point id=\"".$aparray['mac']."_GPS\">\r\n<coordinates>".$long.",".$lat.",".$alt."</coordinates>\r\n</Point>\r\n</Placemark>");
						echo '<tr><td style="border-style: solid; border-width: 1px">Plotted Signal GPS Point</td></tr>';
					}
				}else
				{
					echo "Failed to write KML File, Check the permissions on the wifidb folder, and make sure that Apache (or what ever HTTP server you are using) has permissions to write";
				}
				$fileappend = fopen($filename, "a");
				fwrite($fileappend, $file_data);
				fwrite( $fileappend, "	</Document>\r\n</kml>");
				
				fclose( $fileappend );
				echo '<tr class="style4"><td style="border-style: solid; border-width: 1px">Your Google Earth KML file is ready,<BR>you can download it from <a class="links" href="'.$filename.'">Here</a></td></tr></table>';
				mysql_close($conn);
				$end = microtime(true);
				if ($GLOBALS["bench"]  == 1)
				{
					echo "Time is [Unix Epoc]<BR>";
					echo "Start Time: ".$start."<BR>";
					echo "  End Time: ".$end."<BR>";
				}
				break;
			#--------------------#
			#-					-#
			#--------------------#
		}
	}
	
	#========================================================================================================================#
	#													Export to Garmin GPX File											 #
	#========================================================================================================================#

	function exp_gpx($export = "", $user = "", $row = 0)
	{
		include('config.inc.php');
		include('manufactures.inc.php');
		$gps_array = array();
		switch ($export)
		{
			case "exp_all_signal":
				$start = microtime(true);
				$NN=0;
				$signal_image ='';
				$row_id_exp = explode(",",$row);
				$id = $row_id_exp[1];
				$row = $row_id_exp[0];
				$date=date('Y-m-d_H-i-s');
				$sql = "SELECT * FROM `$wtable` WHERE `ID`='$id'";
				$result = mysql_query($sql, $conn) or die(mysql_error());
				$aparray = mysql_fetch_array($result);
				$ssid_array = make_ssid($aparray['ssid']);
				$ssid_t = $ssid_array[0];
				$ssid_f = $ssid_array[1];
				$ssid = $ssid_array[2];
				$file_ext = $ssid_f."-".$aparray['mac']."-".$aparray['sectype']."-".$date.".gpx";
				echo '<table style="border-style: solid; border-width: 1px"><tr class="style4"><th style="border-style: solid; border-width: 1px">Start export of Single AP: '.$ssid.'\'s Signal History</th></tr>';
				$filename = ($gpx_out.$file_ext);
				// define initial write and appends
				$filewrite = fopen($filename, "w");
				if($filewrite != FALSE)
				{
					$table=$ssid_t.'-'.$aparray['mac'].'-'.$aparray['sectype'].'-'.$aparray['radio'].'-'.$aparray['chan'];
					$table_gps = $table.$gps_ext;
					
					$file_data  = "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\" ?>\r\n<gpx xmlns=\"http://www.topografix.com/GPX/1/1\" creator=\"WiFiDB 0.16 Build 2\" version=\"1.1\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:schemaLocation=\"http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd\">";
					// write file header buffer var
					
					mysql_select_db($db_st,$conn) or die("Unable to select Database:".$db);
		#			echo $table."<br>";
					$sql = "SELECT * FROM `$table`";
					$result = mysql_query($sql, $conn) or die(mysql_error());
					$rows = mysql_num_rows($result);
		#			echo $rows."<br>";
					$sql = "SELECT * FROM `$table` WHERE `id`='$row'";
					$result1 = mysql_query($sql, $conn) or die(mysql_error());
					$mac_e = str_split($aparray['mac'],2);
					$macadd = $mac_e[0].":".$mac_e[1].":".$mac_e[2].":".$mac_e[3].":".$mac_e[4].":".$mac_e[5];
					
					$newArray = mysql_fetch_array($result1);
					$type = $aparray['sectype'];
					if($type == 1){$color = "Navaid, Green";}
					if($type == 2){$color = "Navaid, Amber";}
					if($type == 3){$color = "Navaid, Red";}
					
					$sql6 = "SELECT * FROM `$table_gps`";
					$result6 = mysql_query($sql6, $conn);
					$max = mysql_num_rows($result6);
					
					$sql_1 = "SELECT * FROM `$table_gps`";
					$result_1 = mysql_query($sql_1, $conn);
					while($gps_table = mysql_fetch_array($result_1))
					{
						$lat_exp = explode(" ", $gps_table['lat']);
						$test = $lat_exp[1]+0;
						
						if($test == "0.0000"){$zero = 1; continue;}
						
						$date = $gps_table["date"];
						$time = $gps_table["time"];
						$alt = $gps_table['alt'];
						$alt = $alt * 3.28;
						$lat =& database::convert_dm_dd($gps_table['lat']);
						$long =& database::convert_dm_dd($gps_table['long']);
						$zero = 0;
						$NN++;
						break;
					}
					if($zero == 1){echo '<tr><td style="border-style: solid; border-width: 1px">No GPS Data, Skipping Access Point: '.$ssid.'</td></tr>'; $zero == 0; continue;}
					
					$file_data .= "<wpt lat=\"".$lat."\" lon=\"".$long."\">\r\n"
									."<ele>".$alt."</ele>\r\n"
									."<time>".$date."T".$time."Z</time>\r\n"
									."<name>".$ssid."</name>\r\n"
									."<cmt>".$macadd."</cmt>\r\n"
									."<desc>".$macadd."</desc>\r\n"
									."<sym>".$color."</sym>\r\n<extensions>\r\n"
									."<gpxx:WaypointExtension xmlns:gpxx=\"http://www.garmin.com/xmlschemas/GpxExtensions/v3\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:schemaLocation=\"http://www.garmin.com/xmlschemas/GpxExtensions/v3 http://www.garmin.com/xmlschemas/GpxExtensions/v3/GpxExtensionsv3.xsd\">\r\n"
									."<gpxx:DisplayMode>SymbolAndName</gpxx:DisplayMode>\r\n<gpxx:Categories>\r\n"
									."<gpxx:Category>Category ".$type."</gpxx:Category>\r\n</gpxx:Categories>\r\n</gpxx:WaypointExtension>\r\n</extensions>\r\n</wpt>\r\n\r\n";
					echo '<tr><td style="border-style: solid; border-width: 1px">Wrote AP: '.$ssid.'</td></tr>';
					
					$sql_3 = "SELECT * FROM `$table` WHERE `id`='$row'";
					$sig_result = mysql_query($sql_3, $conn) or die(mysql_error($conn));
					$array = mysql_fetch_array($sig_result);
					$signals = explode("-",$array['sig']);
					$file_data .= "<trk>\r\n<name>GPS Track</name>\r\n<trkseg>\r\n";
					foreach($signals as $signal)
					{
						$sig_exp = explode(",",$signal);
						$gpsid = $sig_exp[0];
						
						$sig = $sig_exp[1];
						$sql_1 = "SELECT * FROM `$table_gps` WHERE `id` = '$gpsid'";
						$result_1 = mysql_query($sql_1, $conn);
						$gps = mysql_fetch_array($result_1);
						$lat_exp = explode(" ", $gps['lat']);
						$test = $lat_exp[1]+0;
						if($test == "0.0000"){$zero = 1; continue;}
						
						$alt = $gps['alt'];
						$alt = $alt * 3.28;
						
						$lat =& database::convert_dm_dd($gps['lat']);
						
						$long =& database::convert_dm_dd($gps['long']);
						$file_data .= "<trkpt lat=\"".$lat."\" lon=\"".$long."\">\r\n"
									."<ele>".$alt."</ele>\r\n"
									."<time>".$date."T".$time."Z</time>\r\n"
									."</trkpt>\r\n";
						echo '<tr><td style="border-style: solid; border-width: 1px">Plotted Signal GPS Point</td></tr>';
					}
					$file_data .= "</trkseg>\r\n</trk></gpx>";
				}else
				{
					echo "Failed to write KML File, Check the permissions on the wifidb folder, and make sure that Apache (or what ever HTTP server you are using) has permissions to write";
				}
				$fileappend = fopen($filename, "a");
				fwrite($fileappend, $file_data);
				fclose( $fileappend );
				echo '<tr class="style4"><td style="border-style: solid; border-width: 1px">Your Google Earth KML file is ready,<BR>you can download it from <a class="links" href="'.$filename.'">Here</a></td></tr></table>';
				
				mysql_close($conn);
				$end = microtime(true);
				if ($GLOBALS["bench"]  == 1)
				{
					echo "Time is [Unix Epoc]<BR>";
					echo "Start Time: ".$start."<BR>";
					echo "  End Time: ".$end."<BR>";
				}
				break;
		}
	}
	
	#========================================================================================================================#
	#													Export to Vistumbler VS1 File										 #
	#========================================================================================================================#

	function exp_vs1($export = "", $user = "", $row = 0)
	{
		include('config.inc.php');
		include('manufactures.inc.php');
		$gps_array = array();
		switch ($export)
		{
			case "exp_all_db_vs1":
				$n	=	1; 
				$nn	=	1; # AP Array key
				echo '<table><tr class="style4"><th style="border-style: solid; border-width: 1px">Start of WiFi DB export to VS1</th></tr>';
				mysql_select_db($db,$conn) or die("Unable to select Database: ".$db);
				$sql_		= "SELECT * FROM `$wtable`";
				$result_	= mysql_query($sql_, $conn) or die(mysql_error());
				while($ap_array = mysql_fetch_array($result_))
				{
					$manuf = database::manufactures($ap_array['mac']);
					switch($ap_array['sectype'])
						{
							case 1:
								$type = "#openStyleDead";
								$auth = "Open";
								$encry = "None";
								break;
							case 2:
								$type = "#wepStyleDead";
								$auth = "Open";
								$encry = "WEP";
								break;
							case 3:
								$type = "#secureStyleDead";
								$auth = "WPA-Personal";
								$encry = "TKIP-PSK";
								break;
						}
					switch($ap_array['radio'])
						{
							case "a":
								$radio="802.11a";
								break;
							case "b":
								$radio="802.11b";
								break;
							case "g":
								$radio="802.11g";
								break;
							case "n":
								$radio="802.11n";
								break;
							default:
								$radio="Unknown Radio";
								break;
						}
					mysql_select_db($db_st,$conn) or die("Unable to select Database: ".$db_st);
					$ssid_array = make_ssid($aparray['ssid']);
					$ssid_t = $ssid_array[0];
					$ssid_f = $ssid_array[1];
					$ssid = $ssid_array[2];
					$table	=	$ssid_t.'-'.$ap_array['mac'].'-'.$ap_array['sectype'].'-'.$ap_array['radio'].'-'.$ap_array['chan'];
					$sql	=	"SELECT * FROM `$table`";
					$result	=	mysql_query($sql, $conn) or die(mysql_error());
					$rows	=	mysql_num_rows($result);
					
					$sql1 = "SELECT * FROM `$table` WHERE `id` = '$rows'";
					$result1 = mysql_query($sql1, $conn) or die(mysql_error());
					$newArray = mysql_fetch_array($result1);
#					echo $nn."<BR>";
					$otx	= $newArray["otx"];
					$btx	= $newArray["btx"];
					$nt		= $newArray['nt'];
					$label	= $newArray['label'];
					$signal	= $newArray['sig'];
					$aps[$nn]	= array(
										'id'		=>	$ap_array['id'],
										'ssid'		=>	$ap_array['ssid'],
										'mac'		=>	$ap_array['mac'],
										'sectype'	=>	$ap_array['sectype'],
										'r'			=>	$ap_array['radio'],
										'radio'		=>	$radio,
										'chan'		=>	$ap_array['chan'],
										'man'		=>	$manuf,
										'type'		=>	$type,
										'auth'		=>	$auth,
										'encry'		=>	$encry,
										'label'		=>	$label,
										'nt'		=>	$nt,
										'btx'		=>	$btx,
										'otx'		=>	$otx,
										'sig'		=>	$signal
										);
					$nn++;
				}
				$signals = array();
				
				foreach($aps as $key=>$ap)
				{
					$n			=	1;	# GPS Array KEY -has to start at 1 vistumbler will error out if the first GPS point has a key of 0
					$sig		=	$ap['sig'];
					$signals	=	explode("-", $sig);
	#				echo $sig."<BR>";
					$table_gps		=	$table.$gps_ext;
					echo $table_gps."<BR>";
					foreach($signals as $sign)
					{
						mysql_select_db($db_st,$conn) or die("Unable to select Database: ".$db_st);
						$sig_exp = explode(",", $sign);
						$gps_id	= $sig_exp[0];
						
						$sql1 = "SELECT * FROM `$table_gps` WHERE `id` = '$gps_id'";
						$result1 = mysql_query($sql1, $conn) or die(mysql_error());
						$gps_table = mysql_fetch_array($result1);
						$gps_array[$n]	=	array(
												"lat" => $gps_table['lat'],
												"long" => $gps_table['long'],
												"sats" => $gps_table['sats'],
												"date" => $gps_table['date'],
												"time" => $gps_table['time']
												);
						$n++;
						$signals[] = $n.",".$sig_exp[1];
					}
					$sig_new = implode("-", $signals);
					$aps[$key]['sig'] = $sig_new;
					echo $aps[$key]['sig']."<BR>";
				}
				#$gps_array = array_unique($gps_array);
		#		var_dump($gps_array);
				
				$date		=	date('Y-m-d_H-i-s');
				$file_ext	=	$date."_entire_db.vs1";
				$filename	=	$vs1_out.$file_ext;
				// define initial write and appends
				$filewrite	=	fopen($filename, "w");
				$fileappend	=	fopen($filename, "a");
				
				$h1 = "#  Vistumbler VS1 - Detailed Export Version 1.2\r\n# Created By: RanInt WiFi DB Alpha 0.16 Build 1 \r\n# -------------------------------------------------\r\n# GpsID|Latitude|Longitude|NumOfSatalites|Date(UTC y-m-d)|Time(UTC h:m:s)\r\n# -------------------------------------------------\r\n";
				fwrite($fileappend, $h1);
				
				foreach( $gps_array as $key=>$gps )
				{
					$lat	=	$gps['lat'];
					$long	=	$gps['long'];
					$sats	=	$gps['sats'];
					$date	=	$gps['date'];
					$time	=	$gps['time'];
					if ($GLOBALS["debug"] ==1 ){echo "Lat : ".$lat." - Long : ".$long."\n";}
					$gpsd = $key."|".$lat."|".$long."|".$sats."|".$date."|".$time."\r\n";
					if($GLOBALS["debug"] == 1){ echo $gpsd;}
					fwrite($fileappend, $gpsd);
				}
				$ap_head = "# ---------------------------------------------------------------------------------------------------------------------------------------------------------\r\n# SSID|BSSID|MANUFACTURER|Authetication|Encryption|Security Type|Radio Type|Channel|Basic Transfer Rates|Other Transfer Rates|Network Type|Label|GpsID,SIGNAL\r\n# ---------------------------------------------------------------------------------------------------------------------------------------------------------\r\n";
				fwrite($fileappend, $ap_head);
				foreach($aps as $ap)
				{
					$apd = $ap['ssid']."|".$ap['mac']."|".$ap['man']."|".$ap['auth']."|".$ap['encry']."|".$ap['sectype']."|".$ap['radio']."|".$ap['chan']."|".$ap['btx']."|".$ap['otx']."|".$ap['nt']."|".$ap['label']."|".$ap['sig']."\r\n";
					fwrite($fileappend, $apd);
				}
				fclose($fileappend);
				fclose($filewrite);
				mysql_close($conn);
				$end 	=	date("H:i:s");
				$GPSS	=	count($gps_array);
				echo '<tr><td style="border-style: solid; border-width: 1px">Wrote # GPS Points: '.$GPSS.'</td></tr>';
				$APSS	=	count($aps);
				echo '<tr><td style="border-style: solid; border-width: 1px">Wrote # Access Points: '.$APSS.'</td></tr>';
				echo '<tr><td style="border-style: solid; border-width: 1px">Your Vistumbler VS1 file is ready,<BR>you can download it from <a class="links" href="'.$filename.'">Here</a></td><td></td></tr></table>';
				break;
		}
	}
}#end DATABASE CLASS
?>
