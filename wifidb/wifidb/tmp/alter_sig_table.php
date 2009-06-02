<?php
include('../lib/config.inc.php');
include('../lib/database.inc.php');
mysql_select_db($db,$conn);
$sql0 = "SELECT * FROM `$wtable` ORDER BY `id` DESC";
$result = mysql_query($sql0, $conn);
$total_rows = mysql_num_rows($result);
if($total_rows != 0)
{
	?><table><?php
	while ($newArray = mysql_fetch_array($result))
	{
		$id = $newArray['id'];
		$ssid_array = make_ssid($newArray['ssid']);
		$ssid = $ssid_array[2];
		$mac = $newArray['mac'];;
		$chan = $newArray['chan'];
		$radio = $newArray['radio'];
		$sectype = $newArray['sectype'];
		
		$table = $ssid."-".$mac."-".$sectype."-".$radio."-".$chan;
		$sql1 = "ALTER TABLE `$wifi_st`.`$table` ADD `user_row` INT ( 255 ) NOT NULL";
		$insert = mysql_query($sql1, $conn);
		if($insert)
		{echo "<tr><td>Success..........</td><td>Altered `$wifi_st`.`$table` to add user_row field;</td></tr>";}
		else{
		echo "<tr><td>Failure..........</td><td>Altered `$wifi_st`.`$table` to add user_row field;<br>".mysql_error($conn)."</td></tr>";
		}
	}
	?></table><?php
}
?>