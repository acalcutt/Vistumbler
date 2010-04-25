<?php
error_reporting(E_ALL|E_STRICT);
global $screen_output, $dim, $COLORS, $daemon_ver;
$screen_output = "CLI";

function clearscreen($out = TRUE)
{
    $clearscreen = chr(27)."[H".chr(27)."[2J";
    if($out)
	{
		print $clearscreen;
    }
	else
	{
		return $clearscreen;
	}
}


if(!(@require_once 'daemon/config.inc.php')){die("You need to create and configure your config.inc.php file in the [tools dir]/daemon/config.inc.php");}
if($GLOBALS['wifidb_install'] == ""){die("You need to edit your daemon config file first in: [tools dir]/daemon/config.inc.php");}
require_once $GLOBALS['wifidb_install']."/lib/database.inc.php";
require_once $GLOBALS['wifidb_install']."/lib/config.inc.php";
$sep = $GLOBALS['sep'];
$database = new database();
$daemon	=	new daemon();
$fo = fopen($argv[1], 'w');
$fileappend = fopen($argv[1], 'a');
$start = "\r\n########\r\n#\r\n#\r\nSTART TIME: ".date("H:i:s.u")."\r\n";

$sql0 = "SHOW TABLES FROM `$db`";
$return0 = mysql_query($sql0, $conn);
fwrite($fileappend,"CREATE DATABASE `$db`;\r\nUSE `$db`;\r\n");
$inserts = '';
while($tables = mysql_fetch_array($return0))
{
	$table_name = $tables['Tables_in_wifi'];
	$sql_table = "SHOW CREATE TABLE `$db`.`$table_name`";
	$return_table = mysql_query($sql_table, $conn);
	$array = mysql_fetch_array($return_table);
	fwrite($fileappend,$array['Create Table'].";\r\n");
	
	$fields_names = array();
	$sql_table = "SHOW COLUMNS FROM `$db`.`$table_name`";
	$return_table = mysql_query($sql_table, $conn);
	while($array = mysql_fetch_array($return_table))
	{
		#var_dump($array);
		$fields_names[] = $array[0];
	}
	$fields = '';
	$ar_siz = count($fields_names);
#	var_dump($fields_names);
	foreach($fields_names as $key=>$arr)
	{
#		echo "|- ".$array." - ".$arr." -| ";
		if($ar_siz == ($key+1))
		{$fields .= "`".$arr."`";}
		else{$fields .= "`".$arr."`, ";}
	}
	$sql_table_data = "SELECT * FROM `$db`.`$table_name`";
	echo $sql_table_data."\r\n";
	$return_tb_data = mysql_query($sql_table_data, $conn);
	while($tbl_data = mysql_fetch_array($return_tb_data))
	{
#		var_dump($tbl_data);	
		$values = '';
		foreach($fields_names as $key=>$arr)
		{
#			echo "|- ".$key." - ".$arr." -| ";
			if($ar_siz == ($key+1))
			{$values .= "'".$tbl_data[$key]."'";}
			else{$values .= "'".$tbl_data[$key]."', ";}
		}
		$inserts = "INSERT INTO `$db`.`$table_name` ( $fields ) VALUES ( $values );\r\n";
		fwrite($fileappend,$inserts);
	}
}

fwrite($fileappend,"CREATE DATABASE `$db_st`;\r\nUSE `$db_st`;\r\n");

$sql = "SELECT * FROM `$db`.`$wtable`";
$return = mysql_query($sql, $conn);
$rows = mysql_num_rows($return);
$inserts = '';
while($newArray = mysql_fetch_array($return))
{
	$id = $newArray['id'];
	$ssid_pt = $newArray['ssid'];
	list($ssid_table) = make_ssid($ssid_pt);
	
	$mac_pt = $newArray['mac'];
	$sectype_pt = $newArray['sectype'];
	$radio_pt = $newArray['radio'];
	$chan_pt = $newArray['chan'];
	$auth_pt = $newArray['auth'];
	$encry_pt = $newArray['encry'];
	
	if($auth_pt == "Offen" or $auth_pt = "Abierta")
	{
		if($encry_pt == "Keine" or $encry_pt == "	Ninguna")
		{
			$sectype_pt = "1";
		}
		elseif($encry_pt == "WEP")
		{
			$sectype_pt = "2";
		}
	}
	clearscreen();
	$table_name = $ssid_table.$sep.$mac_pt.$sep.$sectype_pt.$sep.$radio_pt.$sep.$chan_pt;
	echo "\r\n#######\r\nID: $id\r\nSSID: $ssid_pt\r\nTable: `$db_st`.`$table_name`\r\n#######";
#########################################################################################################	
	$sql1 = "SHOW CREATE TABLE `$db_st`.`$table_name`";
	#	echo "\r\n".$sql1."\r\n\r\n";
	$return_table = mysql_query($sql1, $conn);
	$array = mysql_fetch_array($return_table);
	$CreateTable = str_replace("CREATE TABLE ", "CREATE TABLE `$db_st`.", $array['Create Table']);
	fwrite($fileappend,$CreateTable.";\r\n");
	
	$fields_names = array();
	$sql_table = "SHOW COLUMNS FROM `$db_st`.`$table_name`";
	$return_table = mysql_query($sql_table, $conn);
	while($array = mysql_fetch_array($return_table))
	{
		#var_dump($array);
		$fields_names[] = $array[0];
	}
	$fields = '';
	$ar_siz = count($fields_names);
#	var_dump($fields_names);
	foreach($fields_names as $key=>$arr)
	{
#		echo "|- ".$array." - ".$arr." -| ";
		if($ar_siz == ($key+1))
		{$fields .= "`".$arr."`";}
		else{$fields .= "`".$arr."`, ";}
	}
	$sql_table_data = "SELECT * FROM `$db_st`.`$table_name`";
#	echo $sql_table_data."\r\n";
	$return_tb_data = mysql_query($sql_table_data, $conn);
	while($tbl_data = mysql_fetch_array($return_tb_data))
	{
#		var_dump($tbl_data);	
		$values = '';
		foreach($fields_names as $key=>$arr)
		{
#			echo "|- ".$key." - ".$arr." -| ";
			if($ar_siz == ($key+1))
			{$values .= "'".$tbl_data[$key]."'";}
			else{$values .= "'".$tbl_data[$key]."', ";}
		}
		$inserts = "INSERT INTO `$db_st`.`$table_name` ( $fields ) VALUES ( $values );\r\n";
		fwrite($fileappend,$inserts);
	}
	
#########################################################################################################	
	$gps_table = $table_name.$gps_ext;
	
	$sql1 = "SHOW CREATE TABLE `$db_st`.`$gps_table`";
	#	echo "\r\n".$sql1."\r\n\r\n";
	$return_table = mysql_query($sql1, $conn);
	$array = mysql_fetch_array($return_table);
	fwrite($fileappend,$array['Create Table'].";\r\n");	
	$fields_names = array();
	$sql_table = "SHOW COLUMNS FROM `$db_st`.`$gps_table`";
	$return_table = mysql_query($sql_table, $conn);
	while($array = mysql_fetch_array($return_table))
	{
		#var_dump($array);
		$fields_names[] = $array[0];
	}
	$fields = '';
	$ar_siz = count($fields_names);
#	var_dump($fields_names);
	foreach($fields_names as $key=>$arr)
	{
#		echo "|- ".$array." - ".$arr." -| ";
		if($ar_siz == ($key+1))
		{$fields .= "`".$arr."`";}
		else{$fields .= "`".$arr."`, ";}
	}
	$sql_table_data = "SELECT * FROM `$db_st`.`$gps_table`";
#	echo $sql_table_data."\r\n";
	$return_tb_data = mysql_query($sql_table_data, $conn);
	$alt_id = '';
	while($tbl_data = mysql_fetch_array($return_tb_data))
	{
#		var_dump($tbl_data);	
		$values = '';
		foreach($fields_names as $key=>$arr)
		{
#			echo "|- ".$key." - ".$arr." -| ";
			if($ar_siz == ($key+1))
			{$values .= "'".$tbl_data[$key]."'";}
			else{$values .= "'".$tbl_data[$key]."', ";}
		}
		if($alt_id == $tbl_data['id']){continue;}
		$inserts = "INSERT INTO `$db_st`.`$gps_table` ( $fields ) VALUES ( $values );\r\n";
		fwrite($fileappend,$inserts);
		$inserts = '';
		$alt_id = $tbl_data['id'];
	}
}
fwrite($fileappend,$inserts);

echo $start."\r\n########\r\n#\r\n#\r\nEND TIME: ".date("H:i:s.u");
?>