<?php
include('daemon/config.inc.php');
require('rbrconfig.php');
require $GLOBALS['wifidb_install']."/lib/config.inc.php";
require $GLOBALS['wifidb_install']."/lib/database.inc.php";
echo "$start $end\n";
for($I = $start; $I <= $end; $I++)
{	
	echo $I."\n";
	$sql1		= "SELECT `user_row`, `file` FROM `$db`.`files` WHERE id='$I'";
	$result1	= mysql_query($sql1, $conn);
	$newArray	= mysql_fetch_array($result1);
	$id			= $newArray['user_row'];
	$filename	= $newArray['file'];
	
	$sql2		= "SELECT `points` FROM `$db`.`users` WHERE id='$id'";
	$result2	= mysql_query($sql2, $conn);
	$points		= mysql_fetch_array($result2);
	$points_exp	= explode('-', $points['points']);
	foreach($points_exp as $pts)
	{
		$pts_exp	= explode(',',$pts);
		$id_row		= explode(':',$pts_exp[1]);
		$row		= $id_row[1];
		$ptr_id		= $id_row[0];
		
		$sqlpt		= "SELECT * FROM `$db`.`$wtable` WHERE `id`='$ptr_id'";
		$resultpt	= mysql_query($sqlpt, $conn);
		$pointer	= mysql_fetch_array($resultpt);
		
		$ssid_ptb_	= $pointer['ssid'];
		$ssids_ptb	= str_split($pointer['ssid'],25);
		$ssid_ptb	= smart_quotes($ssids_ptb[0]);
		$table		= $ssid_ptb.'-'.$pointer["mac"].'-'.$pointer["sectype"].'-'.$pointer["radio"].'-'.$pointer["chan"];
		$table_gps	= $table.$gps_ext;
		
		if($pts_exp[0] == '0')
		{
			$remove_sig	= mysql_query("DROP TABLE `$db_st`.`$table`", $conn);
			if($remove_sig){echo "Removed Signal Table: $table\n";}else{echo "Could not remove signal table: $table\n";}
			
			$remove_gps	= mysql_query("DROP TABLE `$db_st`.`$table_gps`", $conn);
			if($remove_gps){echo "Removed GPS Table: $table_gps\n";}else{echo "Could not remove gps table: $table_gps\n";}
			
			$remove_ptr	= mysql_query("DELETE FROM `$db`.`$wtable` WHERE `id` = '$ptr_id'", $conn);
			if($remove_ptr){echo "Removed Pointer: $ptr_id\n";}else{echo "Could not remove pointer: $ptr_id\n";}
			
		}else
		{
			$sqlsig		= "SELECT * FROM `$db_st`.`$table` WHERE `id`='$row'";
			$resultsig	= mysql_query($sqlpt, $conn);
			$sig_table	= mysql_fetch_array($resultsig);
			$sig_gps = explode("-",$sig_table['sig']);
			foreach($sig_gps as $signals)
			{
				$sig = $sig_gps[1];
				$gps = $sig_gps[0];
				$sqlgps		= "SELECT * FROM `$db_st`.`$table_gps` WHERE `id`='$gps'";
				$resultgps	= mysql_query($sqlpt, $conn);
				$gps_table	= mysql_fetch_array($resultgps);
				if($gps_table['lat'] == '')
				{
					$remove_ptr	= mysql_query("DELETE FROM `$db`.`$table` WHERE `id` = '$row'", $conn);
					if($remove_ptr){echo "Removed Signal History Row: $row\n";}else{echo "Could not remove signal history row: $row\n";}
					break;
				}
			}
		}
	}
	
	$remove_user	= mysql_query("DELETE FROM `$db`.`users` WHERE `id` = '$id'", $conn);
	if($remove_user){echo "Removed User Import List: $id\n";}else{echo "Could not remove user import list: $id\n";}

	$remove_file	= mysql_query("DELETE FROM `$db`.`files` WHERE `id` = '$I'", $conn);
	if($remove_file){echo "Removed file from table: $filename\n";}else{echo "Could not remove file from table: $filename\n";}
}
?>