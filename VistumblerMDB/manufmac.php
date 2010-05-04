<?php
$ver = "1.2.1";
ini_set("memory_limit","3072M"); //lots of GPS cords need lots of memory
$script_start = "2009-Jan-24";
$last_edit = "2009-July-22";
$author = "pferland";
$stime = time();
echo "-----------------------------------------------------------------------\n";
echo "| Starting creation of Vistumbler compatible Wireless Router Manuf List.\n| By: $author\n| http:\\www.randomintervals.com\n| Version: $ver\n";
$debug = 0;
$cwd = getcwd();

$source="http://standards.ieee.org/regauth/oui/oui.txt";
$manuf_list = array();
$phpfile = "manufactures.inc.php";
$phpfilewrite = fopen($phpfile, "w");
$phpfileappend = fopen($phpfile, "a");

$vs1file = "manufactures.ini";
$vs1filewrite = fopen($vs1file, "w");
$vs1fileappend = fopen($vs1file, "a");

	echo "Downloading and Opening the Source File from: \n----->".$source."\n|\n|";
$return = file($source);

$total_lines = count($return);
	echo "Source File opened and Destination file placed, starting convertion.\n|\n|";
foreach($return as $ret)
{
	$test = substr($ret, 11,5);
	if ($test != "(hex)"){if($debug === 1){echo "Erroneous data found, dropping\n| This is normal...\n| ";} continue;}
	$retexp = explode("(hex)",$ret);
	$Man_mac = trim($retexp[0], "\x20\x09");
	$man_mac = explode("-",$Man_mac);
	$Man_mac = implode("",$man_mac);
	$Manuf = trim($retexp[1], "\n\r\x20\x09");
	if($Manuf == "PRIVATE"){echo "Non Needed Manuf found...\n| ";continue;}
	$manuf_list[] = array(
						"mac" 	=> $Man_mac,
						"manuf"	=> addslashes($Manuf)
						);
			
}
echo "Manufactures and MAC Address' found...\n| ";
$total_manuf = count($manuf_list);
		echo "Write Manufactures File for both Vistumbler and WiFiDB:\n";

fwrite($vs1fileappend, ";This file allows you to assign a manufacturer to a mac address(first 6 digits).\r\n[MANUFACURERS]\r\n");
fwrite($phpfileappend, "<?php\r\n$"."manufactures=array(\r\n");

$current = 1;
foreach($manuf_list as $manuf)
{
	if($total_manuf == $current)
	{
		$write = "\"".$manuf['mac']."\"=>\"".$manuf['manuf']."\"\r\n";
	}else{
		$write = "\"".$manuf['mac']."\"=>\"".$manuf['manuf']."\",\r\n";
	}
	if($debug === 1){	echo $write."\n| ";}
	fwrite($phpfileappend, $write);
	$current++;
	

	fwrite($vs1fileappend, $manuf['mac']."=".$manuf['manuf']."\r\n");
	if($debug == 1){echo $write."\n";}
}
fwrite($phpfileappend, ");\r?>");
#------------------------------------------------------------------------------------------------------#

$etime = time();
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