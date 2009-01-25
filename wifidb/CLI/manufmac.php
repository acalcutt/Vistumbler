<?php
$version = "1.1.1";
$script_start = "1.24.09";
$last_edit = "1.24.09";
$author = "pferland";
		echo "Starting creation of Vistumbler compatible Wireless Router Manuf List.\nBy: Pferland\nhttp:\\www.randomintervals.com\n";
$cwd = "c:/wamp/www/";
$stime = time()*60;
$source="http://standards.ieee.org/regauth/oui/oui.txt";
$manuf_list = array();
$filename = $cwd."manufactures.inc.php";
$filewrite = fopen($filename, "w");
$fileappend = fopen($filename, "a");
		echo "Downloading and Opening the Source File from: ".$source."\n\n";
$return = file($source);
$total_lines = count($return);
		echo "Source File opened and Destination file placed, starting convertion.\n\n";
foreach($return as $ret)
{
	$test = substr($ret, 11,5);
	if ($test != "(hex)"){echo "Erroneous data found, dropping\nThis is normal...\n"; continue;}
	$retexp = explode("(hex)",$ret);
	$Man_mac = trim($retexp[0], "\x20\x09");
	$man_mac = explode("-",$Man_mac);
	$Man_mac = implode("",$man_mac);
	$Manuf = trim($retexp[1], "\n\r\x20\x09");
	if($Manuf == "PRIVATE"){echo "Non Needed Manuf found...\n";continue;}
	$manuf_list[] = array(
						"mac" 	=> $Man_mac,
						"manuf"	=> $Manuf
						);
			echo "Manufacture and MAC Address found...\n";
}
$total_manuf = count($manuf_list);
		echo "Write WiFiDB Compatible File:\n";
$write_var = "<?php\r$"."manufactures=array(\r";
fwrite($fileappend, $write_var);
$current = 1;
foreach($manuf_list as $manuf)
{
	if($total_manuf == $current)
	{
		$write = "\"".$manuf['mac']."\"=>\"".$manuf['manuf']."\"\r";
	}else{
		$write = "\"".$manuf['mac']."\"=>\"".$manuf['manuf']."\",\r";
	}
			echo $write."\n";
	fwrite($fileappend, $write);
	$current++;
}
$footer = ");\r?>";
fwrite($fileappend, $footer);

$filename = $cwd."manufactures.ini";
$filewrite = fopen($filename, "w");
$fileappend = fopen($filename, "a");
		echo "Write Vistumlber Compatible File:\n";
$write_var = ";This file allows you to assign a manufacturer to a mac address(first 6 digits).\r[MANUFACURERS]\r";
fwrite($fileappend, $write_var);

foreach($manuf_list as $manuf)
{
	$write = $manuf['mac']."=".$manuf['manuf']."\r";
	fwrite($fileappend, $write);

}
$etime = time()*60;
$diff_time = $etime - $stime;
$lines_p_min = $total_lines/$diff_time;
	echo "Total Manufactures found: ".$total_manuf."\n----------------\n"
	."Start Time:.......".$stime."\n"
	."End Time:.........".$etime."\n"
	."Total Run Time:...".$diff_time."\n----------------\n"
	."Total Lines:......".$total_lines."\n"
	."Lines per min:....".$lines_p_min."\n"	 
	."----------------\nDone";
?>