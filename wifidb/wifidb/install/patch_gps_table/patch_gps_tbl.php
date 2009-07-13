<?php
include('../../lib/config.inc.php');
mysql_select_db($db_st, $conn);
$result = mysql_query("show tables LIKE '%_GPS'", $conn);
while($array = mysql_fetch_row($result))
{
	$table = $array[0];
	echo $table."<BR>";
	$sql = "ALTER TABLE `$db_st`.`$table` MODIFY `hdp` varchar(255) NOT NULL ,MODIFY `alt` varchar(255) NOT NULL ,MODIFY `geo` varchar(255) NOT NULL ,MODIFY `kmh` varchar(255) NOT NULL ,MODIFY `mph` varchar(255) NOT NULL ,MODIFY`track` varchar(255) ,MODIFY `fa` varchar(255) NOT NULL ,MODIFY`lu` varchar(255) NOT NULL";
	$insert = mysql_query($sql, $conn);
	if($insert)
	{
		echo "Success..........Altered `$db_st`.`$table` to fix null gps data in the `hdp` , `alt` , `geo` , kmh` , and `track`<BR>";
	}
	else
	{
		echo "Failure..........Alter `$db_st`.`$table`;<br><br>".mysql_error($conn);
	}
}

?>