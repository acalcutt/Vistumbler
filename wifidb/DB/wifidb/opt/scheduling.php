<?php
include('../lib/database.inc.php');
include('../lib/config.inc.php');
pageheader("Search results Page");
?></td>
		<td width="80%" bgcolor="#A9C6FA" valign="top" align="center">
			<p align="center">
			<h2>Import Results</h2>
			<table border="1" width="90%"><tr class="style4"><th colspan="7" align="center">Files waiting for import</th><tr class="style4"><th>ID</th><th>Filename</th><th>Date</th><th>user</th><th>title</th><th>size</th><th>hash</th></tr>
<?php
mysql_select_db($db,$conn);
$sql = "SELECT * FROM `files_tmp`";
$result = mysql_query($sql, $conn) or die(mysql_error());
$total_rows = mysql_num_rows($result);
if($total_rows === 0)
{
	?><tr><td colspan="7" align="center">There where no files waiting to be imported, Go and import a file</td></tr></table><?php
}else
{
	while ($newArray = mysql_fetch_array($result))
	{
		?>
		<tr><td align="center">
		<?php
		echo $newArray['id']
		?>
		</td></tr><tr><td align="center">
		<?php
		echo $newArray['file']
		?>
		</td></tr><tr><td align="center">
		<?php
		echo $newArray['date']
		?>
		</td></tr><tr><td align="center">
		<?php
		echo $newArray['user']
		?>
		</td></tr><tr><td align="center">
		<?php
		echo $newArray['title']
		?>
		</td></tr><tr><td align="center">
		<?php
		echo $newArray['size']
		?>
		</td></tr><tr><td align="center">
		<?php
		echo $newArray['hash']
		?>
		</td></tr>
		<?php
	}
	?></table><?php
}
?>
			<table border="1" width="90%"><tr class="style4">
			<th colspan="9" align="center">Files already imported</th></tr>
			<tr class="style4"><th>ID</th><th>Filename</th><th>Date</th><th>user</th><th>title</th><th>Total APs</th><th>Total GPS</th><th>size</th><th>hash</th></tr>
<?php
$sql = "SELECT * FROM `files`";
$result = mysql_query($sql, $conn) or die(mysql_error());
$total_rows = mysql_num_rows($result);
if($total_rows === 0)
{
	?><tr><td colspan="9" align="center">There where no files that where imported, Go and import a file</td></tr></table><?php
}else
{
}
$filename = $_SERVER['SCRIPT_FILENAME'];
footer($filename);
?>