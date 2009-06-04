<?php
include('../lib/database.inc.php');
echo '<title>Wireless DataBase *Alpha*'.$ver["wifidb"].' --> </title>';
pageheader("Upgrade Page");
echo '<h3>If you have GPS points that are blank, go <a class="links" href="patch_blank_gps/">here</a><h3>';
echo '<h3>If your GPS dates are in the format [MM-DD-YYYY], Alter them to [YYYY-MM-DD] <a class="links" href="patch_alter_dates/">here</a>';

$timezn = 'Etc/GMT+5';
date_default_timezone_set($timezn);

	$filename = $_SERVER['SCRIPT_FILENAME'];
	$file_ex = explode("/", $filename);
	$count = count($file_ex);
	$file = $file_ex[($count)-1];
	?>
	</p>
	</td>
	</tr>
	<tr>
	<td bgcolor="#315573" height="23"><a href="../img/moon.png"><img border="0" src="../img/moon_tn.png"></a></td>
	<td bgcolor="#315573" width="0" align="center">
	<?php
	if (file_exists($filename)) {?>
		<h6><i><u><?php echo $file;?></u></i> was last modified:  <?php echo date ("Y F d @ H:i:s", filemtime($filename));?></h6>
	<?php
	}
	?>
	</td>
	</tr>
	</table>
	</body>
	</html>