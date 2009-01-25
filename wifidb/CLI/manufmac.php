<?php
$version = "1.0";
$script_start = "1.24.09";
$last_edit = "1.24.09";
$author = "pferland";
echo "Starting creation of Vistumbler compatible Wireless Router Manuf List.\nBy: Pferland\n";
$cwd = "c:/wamp/www/";
$stime = time()*60;
$source="http://standards.ieee.org/regauth/oui/oui.txt";
$manuf_list = array();
$filename = $cwd."manuf_list.txt";
$filewrite = fopen($filename, "w");
$fileappend = fopen($filename, "a");
$return = file($source);
$total_lines = count($return);
echo "Source File opened and Destination file placed, starting convertion.\n\n";
foreach($return as $ret)
{
	$test = substr($ret, 11,5);
	if ($test != "(hex)"){echo "Erroneous data found, dropping\nThis is normal...\n"; continue;}
	$retexp = explode("(hex)",$ret);
	$Man_mac = trim($retexp[0], "\x2D\x20\x09");
	$Manuf = trim($retexp[1], "\n\r\x20\x09");
	if($Manuf == "PRIVATE"){echo "Non Needed Manuf found...\n";continue;}
	$manuf_list[] = array(
						"mac" 	=> $Man_mac,
						"manuf"	=> $Manuf
						);
	echo "Manufacture and MAC Address found...\n";
}
$total_manuf = count($manuf_list);
$write_var = "$"."manufactures=array(\n\r";
fwrite($fileappend, $write_var);
$current = 1;
foreach($manuf_list as $manuf)
{
	if($total_manuf == $current)
	{
		$write = "\"".$manuf['mac']."\"=>\"".$manuf['manuf']."\"\n\r";
	}else{
		$write = "\"".$manuf['mac']."\"=>\"".$manuf['manuf']."\",\n\r";
	}
	echo $write."\n";
	fwrite($fileappend, $write);
	$current++;
}
$footer = ");";
fwrite($fileappend, $footer);

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