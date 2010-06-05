<?php
$ver = array(
				'version'	=>	'1.2',
				'usage'		=>	'To use this, just put the relitive or absolute path of the output SQL file that you want.
IE: wifidb-sql:/opt/wifidb/tools/# php backup_db.php may_2010_backup.sql
The backup script will dump all the tables from the `wifi` and `wifi_st` databases
\tto a SQL file /opt/wifidb/tools/may_2010_backup.sql'
			);
error_reporting(E_ALL|E_STRICT);
global $screen_output, $dim, $COLORS, $daemon_ver;
$screen_output = "CLI";

function clearscreen($out=TRUE){$clearscreen=chr(27)."[H".chr(27)."[2J";if($out){print$clearscreen;}else{return$clearscreen;}}

if(!(@require_once 'daemon/config.inc.php')){die("You need to create and configure your config.inc.php file in the [tools dir]/daemon/config.inc.php");}
if($GLOBALS['wifidb_install'] == ""){die("You need to edit your daemon config file first in: [tools dir]/daemon/config.inc.php");}
require_once $GLOBALS['wifidb_install']."/lib/database.inc.php";
require_once $GLOBALS['wifidb_install']."/lib/config.inc.php";

$sep = $GLOBALS['sep'];
$recover = array();
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
	fwrite($fileappend, str_replace("CREATE TABLE ", "CREATE TABLE `$db`.", $array['Create Table'].";\r\n"));
	
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
	$sql_table_data = "SELECT * FROM `$db`.`$table_name` order by `id` ASC";
	echo $sql_table_data."\r\n";
	$n=0;
	$return_tb_data = mysql_query($sql_table_data, $conn);
	
	$rows = mysql_num_rows($return_tb_data);
	echo "ROWS: ".$rows."\r\n";
	$values = '';
	while($tbl_data = mysql_fetch_array($return_tb_data))
	{
		$n++;
		$values .= '( ';
#		var_dump($tbl_data);	
		foreach($fields_names as $key=>$arr)
		{
#			echo "|- ".$key." - ".$arr." -|- ".$tbl_data[$key]." -| == ";
#			if($table_name == 'wifi0'){echo "|- ".$tbl_data[0]." -|\r\n";}
			if($ar_siz == ($key+1))
			{$values .= "'".addslashes($tbl_data[$key])."'";}
			else{$values .= "'".addslashes($tbl_data[$key])."', ";}
		}
		if($n == $rows)
		{
			fwrite($fileappend, "INSERT INTO `$db`.`$table_name` ( $fields ) VALUES $values );\r\n");
			continue;
		}else
		{
			$values .= " ),\r\n";
		}
	}
}

fwrite($fileappend,"CREATE DATABASE `$db_st`;\r\nUSE `$db_st`;\r\n");

$sql = "SELECT * FROM `$db`.`$wtable` ORDER BY `id` ASC";
#echo $sql."\r\n";
$return__ = mysql_query($sql, $conn);
$rows = mysql_num_rows($return__);
while($newArray = mysql_fetch_array($return__))
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
	$user_pt = @$newArray['user'];
	
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
	
	###################
	clearscreen();
	###################
	
	$table_name = $ssid_table.$sep.$mac_pt.$sep.$sectype_pt.$sep.$radio_pt.$sep.$chan_pt;
	$gps_table = $table_name.$gps_ext;	
	
	$sql_user = "SELECT `user` FROM `$db_st`.`$table_name` LIMIT 1";
	$return_user = mysql_query($sql_user, $conn);
	$user = mysql_fetch_array($return_user);
	if($user_pt == ''){$user_pt = $user['user'];}
	echo "#######\r\nID: $id\r\nCreated By: $user_pt\r\nTable: `$db_st`.`$table_name`\r\n#######";
#########################################################################################################	
	$sql1 = "SHOW CREATE TABLE `$db_st`.`$table_name`";
	#	echo "\r\n".$sql1."\r\n\r\n";
	$return_table = mysql_query($sql1, $conn);
	$array = mysql_fetch_array($return_table);
	if($array['Create Table'] == '')
	{
		$create_sql = "CREATE TABLE `$db_st`.`$table_name` (
		`id` int(255) NOT NULL auto_increment,
		`btx` varchar(10) NOT NULL,
		`otx` varchar(10) NOT NULL,
		`nt` varchar(15) NOT NULL,
		`label` varchar(25) NOT NULL,
		`sig` text NOT NULL,
		`user` varchar(25) NOT NULL,
		PRIMARY KEY  (`id`)
		) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8";
		if(mysql_query($create_sql, $conn))
		{
			$recover[] = $table_name." - CREATE";
			$sql1 = "SHOW CREATE TABLE `$db_st`.`$table_name`";
			$return_table = mysql_query($sql1, $conn);
			$array = mysql_fetch_array($return_table);
		}else{die(mysql_error($conn));}
	}
	fwrite($fileappend, str_replace("CREATE TABLE ", "CREATE TABLE `$db_st`.", $array['Create Table']).";\r\n");
	
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
	$sql_table_data = "SELECT * FROM `$db_st`.`$table_name` ORDER BY `id` ASC";
#	echo $sql_table_data."\r\n";
	$return_tb_data = mysql_query($sql_table_data, $conn);
	$rows = mysql_num_rows($return_tb_data);
	$n=0;
	$values = '';
	while($tbl_data = mysql_fetch_array($return_tb_data))
	{
		$n++;
#		var_dump($tbl_data);	
		$values .= '( ';
		foreach($fields_names as $key=>$arr)
		{
#			echo "|- ".$key." - ".$arr." -| ";
			if($ar_siz == ($key+1))
			{$values .= "'".addslashes($tbl_data[$key])."'";}
			else{$values .= "'".addslashes($tbl_data[$key])."', ";}
		}
		if($n == $rows){$values .= " )\r\n";}else{$values .= " ),\r\n";}
	}
	if($values == '')
	{
		$insert_sig_sql = "INSERT INTO `$db_st`.`$table_name` ( `id`, `btx`, `otx`, `nt`, `label`, `sig`, `user` ) VALUES ( '', '0', '0', 'Ad-Hoc', 'No Label', '1,1', 'WiFiDB' )";
		if(mysql_query($insert_sig_sql, $conn))
		{
			$recover[] = $table_name." - INSERT";
			fwrite($fileappend, "INSERT INTO `$db_st`.`$table_name` ( `id`, `btx`, `otx`, `nt`, `label`, `sig`, `user` ) VALUES ( '', '0', '0', 'Ad-Hoc', 'No Label', '1,1', 'WiFiDB' );\r\n");
		}else{die(mysql_error($conn));}
	}else
	{
		fwrite($fileappend,"INSERT INTO `$db_st`.`$table_name` ( $fields ) VALUES $values;\r\n");
	}
	
#########################################################################################################
	
	$sql1 = "SHOW CREATE TABLE `$db_st`.`$gps_table`";
	$return_table = mysql_query($sql1, $conn);
	$array = mysql_fetch_array($return_table);
	if($array['Create Table'] == '')
	{
		$create_g_sql = "CREATE TABLE `$db_st`.`$gps_table` (
		`id` int(255) NOT NULL auto_increment,
		`lat` varchar(25) NOT NULL,
		`long` varchar(25) NOT NULL,
		`sats` int(2) NOT NULL,
		`hdp` float NOT NULL,
		`alt` float NOT NULL,
		`geo` float NOT NULL,
		`kmh` float NOT NULL,
		`mph` float NOT NULL,
		`track` float NOT NULL,
		`date` varchar(10) NOT NULL,
		`time` varchar(8) NOT NULL,
		PRIMARY KEY  (`id`)
		) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8";
		if(mysql_query($create_g_sql, $conn))
		{
			$recover[] = $gps_table." - CREATE";
			$sql1 = "SHOW CREATE TABLE `$db_st`.`$gps_table`";
			$return_table = mysql_query($sql1, $conn);
			$array = mysql_fetch_array($return_table);
		}else{die(mysql_error($conn));}
	}
	
	$CreateTable = str_replace("CREATE TABLE ", "CREATE TABLE `$db_st`.", $array['Create Table']);
	fwrite($fileappend,$CreateTable.";\r\n");	
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
	$sql_table_data = "SELECT * FROM `$db_st`.`$gps_table` ORDER BY `id` ASC";
#	echo $sql_table_data."\r\n";
	$return_tb_data = mysql_query($sql_table_data, $conn);
	$alt_id = '';
	$inserts = '';
	$values = '';
	$n=0;
	$rows = mysql_num_rows($return_tb_data);
	while($tbl_data = mysql_fetch_array($return_tb_data))
	{
		$n++;
#		var_dump($tbl_data);	
		$values .= '( ';
		foreach($fields_names as $key=>$arr)
		{
#			echo "|- ".$key." - ".$arr." -| ";
			if($ar_siz == ($key+1))
			{$values .= "'".addslashes($tbl_data[$key])."'";}
			else{$values .= "'".addslashes($tbl_data[$key])."', ";}
		}
		if($alt_id == $tbl_data['id']){continue;}
		$alt_id = $tbl_data['id'];
		if($n == $rows){$values .= " )\r\n";}else{$values.=" ),\r\n";}
	}
	if($values == '')
	{
		$insert_gps_sql = "INSERT INTO `$db_st`.`$gps_table` ( `id`, `lat`, `long`, `sats`, `hdp`, `alt`, `geo`, `kmh`, `mph`, `track`, `date`, `time` ) VALUES ( '', 'N 0.0000', 'E 0.0000', '00', '0', '0', '0', '0', '0', '0', '1986-04-01', '12:01:01' )";
		if(mysql_query($insert_gps_sql, $conn))
		{
			$recover[] = $gps_table." - INSERT";
			fwrite($fileappend, "INSERT INTO `$db_st`.`$gps_table` ( `id`, `lat`, `long`, `sats`, `hdp`, `alt`, `geo`, `kmh`, `mph`, `track`, `date`, `time` ) VALUES ( '', 'N 0.0000', 'E 0.0000', '00', '0', '0', '0', '0', '0', '0', '1979-06-31', '00:00:00' );\r\n");
		}else{die(mysql_error($conn));}
	}else
	{
		fwrite($fileappend, "INSERT INTO `$db_st`.`$gps_table` ( $fields ) VALUES $values;\r\n");
	}

}
echo $start."\r\n########\r\n#\r\n#\r\nEND TIME: ".date("H:i:s.u")."\r\n";
var_dump($recover);
?>