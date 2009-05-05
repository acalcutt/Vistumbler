<?php
session_start();
include('../lib/config.inc.php');
$refresh_file = "refresh.txt";
if (isset($_POST['token']))
{
	if (isset($_SESSION['token']) && $_POST['token'] == $_SESSION['token'])
	{
		$refresh = $_POST['refresh'];
		$refresh = filter_var($refresh , FILTER_VALIDATE_INT, array('min_range'=>5, 'max_range'=>30720));
		if(!$refresh)
		{
			echo '<font color="white">You must choose between 5 seconds and 512 Minutes, I have set it to 15 for you, you dumbass.</font>';
			$refresh = "15";
		}
		fopen($refresh_file, "w");
		$fileappend = fopen($refresh_file, "a");
		fwrite($fileappend, $refresh);
	}else
	{
		$refresh = "15";
	}
}else
{
	$refresh_fopen = file($refresh_file);
	$refresh = $refresh_fopen[0];
}
include('../lib/database.inc.php');

echo '<meta http-equiv="refresh" content="'.$refresh.'">';

pageheader("Search results Page");
mysql_select_db($db,$conn);
$sql = "SELECT * FROM `settings` WHERE `table` LIKE 'files'";
$result = mysql_query($sql, $conn) or die(mysql_error());
$file_array = mysql_fetch_array($result);

$token = md5(uniqid(rand(), true));
$_SESSION['token'] = $token;

?></td>
		<td width="80%" bgcolor="#A9C6FA" valign="top" align="center">
			<p align="center">
			<h2>Import Results</h2>
			<h2>Next Import scheduled on: <br>
			<?php
				echo $file_array['size'];
			?> GMT / 
			<?php
				$nextrun = date("Y-m-d H:i:s", (strtotime($file_array['size'])-14400));
				echo $nextrun				
			?> EST</h2>
			<h4>If none are already importing...</h4>
			<form action="scheduling.php" method="post" enctype="multipart/form-data">
			<input type="hidden" name="token" value="<?php echo $token; ?>" />
			Select a Refresh Rate : <br> 
			<SELECT NAME="refresh">  
			<OPTION VALUE="5"> 5 Seconds
			<OPTION VALUE="10"> 10 Seconds
			<OPTION VALUE="15"> 15 Seconds
			<OPTION VALUE="30"> 30 Seconds
			<OPTION VALUE="60"> 60 Seconds
			<OPTION VALUE="120"> 2 Minutes
			<OPTION VALUE="240"> 4 Minutes
			<OPTION VALUE="480"> 8 Minutes
			<OPTION VALUE="960"> 16 Minutes
			<OPTION VALUE="1920"> 32 Minutes
			<OPTION VALUE="3840"> 64 Minutes
			<OPTION VALUE="5760"> 96 Minutes
			<OPTION VALUE="7680"> 128 Minutes
			<OPTION VALUE="30720"> 512 Minutes
			</SELECT><br>
			<INPUT TYPE=SUBMIT NAME="submit" VALUE="Submit"><br>
			(Currently set to: <?php echo $refresh;?>)
			</form>
			<table width="90%"><tr class="style4"><th border="1" colspan="7" align="center">Files waiting for import</th></tr>
<?php
$sql = "SELECT * FROM `files_tmp` ORDER BY `id` ASC";
$result = mysql_query($sql, $conn) or die(mysql_error());
$total_rows = mysql_num_rows($result);
if($total_rows === 0)
{
	?><tr><td border="1" colspan="7" align="center">There where no files waiting to be imported, Go and import a file</td></tr></table><?php
}else
{
	?>
	<tr align="center"><td border="1"><br>
	<?php
	while ($newArray = mysql_fetch_array($result))
	{
		if($newArray['importing'] == '1' )
		{
			$color = 'style="background-color: lime"';
		}else
		{
			$color = 'style="background-color: yellow"';
		}
 		?>
		<table <?php echo $color;?> border="1"  width="100%">
		<tr class="style4"><th>ID</th><th>Filename</th><th>Date</th><th>user</th><th>title</th><th>size</th></tr>
		<tr <?php echo $color;?>>
		<td align="center">
		<?php
		echo $newArray['id'];
		?>
		</td><td align="center">
		<?php
		echo $newArray['file'];
		?>
		</td><td align="center">
		<?php
		echo $newArray['date'];
		?>
		</td><td align="center">
		<?php
		echo $newArray['user'];
		?>
		</td><td align="center">
		<?php
		echo $newArray['title'];
		?>
		</td><td align="center">
		<?php
		echo $newArray['size'];
		?>
		</td></tr>
		<tr class="style4">
		<th <?php echo $color;?>>
		</th>
		<th>Hash Sum</th><th>Importing?</th><th colspan="2">Current SSID</th><th>AP / Total AP's</th></tr>
		<tr <?php echo $color;?>>
		<td></td>
		<td align="center">
		<?php
		echo $newArray['hash'];
		?>
		</td><td align="center">
		<?php
		if($newArray['importing'] == '1'){$importing = "Yes";}else{$importing = "No";}
		echo $importing;
		?>
		</td><td align="center" colspan="2">
		<?php
		if($newArray['ap'] == NULL){$ssid = "None being imported";}else{$ssid = $newArray['ap'];}
		echo $ssid;
		?>
		</td><td align="center">
		<?php
		if($newArray['tot'] == NULL){$tot = "None being imported";}else{$tot = $newArray['tot'];}
		echo $tot;
		?>
		</td></tr>
		</table>
		<br>
		<?php
	}
	?></td></tr></table><?php
}
?>
			<table border="1" width="90%"><tr class="style4">
			<th colspan="9" align="center">Files already imported</th></tr>
<?php
$sql = "SELECT * FROM `files` ORDER BY `id` DESC";
$result = mysql_query($sql, $conn) or die(mysql_error());
$total_rows = mysql_num_rows($result);
if($total_rows === 0)
{
	?><tr><td colspan="9" align="center">There where no files that where imported, Go and import a file</td></tr></table><?php
}else
{
	while ($newArray = mysql_fetch_array($result))
	{
		?><tr class="style4"><th>ID</th><th>Filename</th><th>Date</th><th>user</th><th>title</th></tr><tr><td align="center">
		<?php
		echo $newArray['id'];
		?>
		</td><td align="center">
		<?php
		echo '<a class="links" href="../opt/userstats.php?func=useraplist&row='.$newArray["user_row"].'">'.$newArray['file'].'</a>';
		?>
		</td><td align="center">
		<?php
		echo $newArray['date'];
		?>
		</td><td align="center">
		<?php
		echo '<a class="links" href ="../opt/userstats.php?func=allap&user='.$newArray["user"].'">'.$newArray["user"].'</a>';
		?>
		</td><td align="center">
		<?php
		echo $newArray['title'];
		?></td></tr>
		<tr>
		<th></th><th class="style4">Total AP's</th><th class="style4">Total GPS</th><th class="style4">Size</th><th class="style4">Hash Sum</th></tr>
		<tr><td></td><td align="center">
		<?php
		echo $newArray['aps'];
		?>
		</td><td align="center">
		<?php
		echo $newArray['gps'];
		?>
		</td><td align="center">
		<?php
		echo $newArray['size'];
		?>
		</td><td align="center">
		<?php
		echo $newArray['hash'];
		?>
		</td></tr><tr></tr>
		<?php
	}
	?>
	</tr></table><?php
}
$filename = $_SERVER['SCRIPT_FILENAME'];
footer($filename);
?>