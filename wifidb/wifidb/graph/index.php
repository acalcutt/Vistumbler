<?php
/////////////////////////////////////////////////////////////////
//  By: Phillip Ferland (Longbow486)                           //
//  Email: longbow486@msn.com                                  //
//  Started on: 10.14.07                                       //
//  Purpose: To generate a PNG graph of a WAP's signal         //
//           from URL driven data                              //
//  Filename: index.php                                        //
/////////////////////////////////////////////////////////////////
$startdate="14-10-2007";
$lastedit="03-Jun-2009";

include('../lib/database.inc.php');
pageheader("Graph AP Signal History Page");
include('../lib/config.inc.php');
include('../lib/graph.inc.php');
?>
<form action="genline.php?token=<?php echo $_SESSION['token'];?>" method="post" enctype="multipart/form-data">
<?php
echo '<h1>Graph an Access Points Signal history *Beta*</h1><h4>Bar Graph=>'.$ver_graph['graphs']['wifibar'].'<br>Line Graph=>'.$ver_graph['graphs']['wifiline'].'</h4>';

$id = $_GET['id'];
$row = $_GET['row'];

mysql_select_db($db,$conn);
$sql = "SELECT*FROM`$wtable`WHERE`id`=$id";
$result = mysql_query($sql, $conn) or die(mysql_error());
$pointer = mysql_fetch_array($result);

$radio=$pointer['radio'];

if	  ($radio == "a"){$radio = "802.11a";}
elseif($radio == "b"){$radio = "802.11b";}
elseif($radio == "g"){$radio = "802.11g";}
elseif($radio == "n"){$radio = "802.11n";}
else				 {$radio = "802.11u";}


$table=$pointer["ssid"].'-'.$pointer["mac"].'-'.$pointer["sectype"].'-'.$pointer["radio"].'-'.$pointer["chan"];
$table_gps = $table.$gps_ext;
$name = $table."_".$row;

mysql_select_db($db_st,$conn);
$sql = "SELECT*FROM`$table`WHERE`id`=$row";
$result = mysql_query($sql, $conn) or die(mysql_error());
$ap_table = mysql_fetch_array($result);
$database = new database();
$man = $database->manufactures($pointer["mac"]);
#if ( $manufactures[$man_mac[0]] == ""){$man = "UNKNOWN Manuf";}else{ $man =  $manufactures[$man_mac[0]];}

$sig_exp = explode("-", $ap_table["sig"]);
$sig_size = count($sig_exp)-1;

$first_ID = explode(",",$sig_exp[0]);
$first = $first_ID[0];

$last_ID = explode(",",$sig_exp[$sig_size]);
$last = $last_ID[0];

$sql = "SELECT * FROM `$table_gps` WHERE `id`='$first'";
$result = mysql_query($sql, $conn) or die(mysql_error());
$gps_table_first = mysql_fetch_array($result);

$date_first = $gps_table_first["date"];
$time_first = $gps_table_first["time"];
$fa = $date_first." ".$time_first;

$sql = "SELECT * FROM `$table_gps` WHERE `id`='$last'";
$result = mysql_query($sql, $conn) or die(mysql_error());
$gps_table_last = mysql_fetch_array($result);
$date_last = $gps_table_last["date"];
$time_last = $gps_table_last["time"];
$lu = $date_last." ".$time_last;

$sig = explode("-",$ap_table['sig']);
$N=0;
foreach($sig as $sigs)
{
	$explode=explode(",",$sigs);
	$signal[$N]=$explode[1];
	$N++;
}
$sig = implode("-",$signal);

	echo '<table style="width: 500px" cellspacing="3" cellpadding="0" class="style3"><tr><td class="style2">'
		.'<input name="ssid" type="hidden" value="'.$pointer["ssid"].'"/>'."\r\n"
		.'<input name="mac" type="hidden" value="'.$pointer["mac"].'"/>'."\r\n"
		.'<input name="man" type="hidden" value="'.$man.'"/>'."\r\n"
		.'<input name="auth" type="hidden" value="'.$pointer["auth"].'"/>'."\r\n"
		.'<input name="encry" type="hidden" value="'.$pointer["encry"].'"/>'."\r\n"
		.'<input name="radio" type="hidden" value="'.$radio.'"/>'."\r\n"
		.'<input name="chan" type="hidden" value="'.$pointer["chan"].'"/>'."\r\n"
		.'<input name="lat" type="hidden" value="'.$gps_table_first["lat"].'"/>'."\r\n"
		.'<input name="long" type="hidden" value="'.$gps_table_first["long"].'"/>'."\r\n"
		.'<input name="btx" type="hidden" value="'.$ap_table["btx"].'"/>'."\r\n"
		.'<input name="otx" type="hidden" value="'.$ap_table["otx"].'"/>'."\r\n"
		.'<input name="fa" type="hidden" value="'.$fa.'"/>'."\r\n"
		.'<input name="lu" type="hidden" value="'.$lu.'"/>'."\r\n"
		.'<input name="nt" type="hidden" value="'.$ap_table["nt"].'"/>'."\r\n"
		.'<input name="label" type="hidden" value="'.$ap_table["label"].'"/>'."\r\n"
		.'<input name="sig" type="hidden" value="'.$sig.'"/>'."\r\n"
		.'<input name="name" type="hidden" value="'.$name.'"/>'."\r\n";
	?>
					Choose Graph Type: 
					<select name="line" style="height: 22px; width: 139px">
	<option value="">Bar (Vertical)</option>
	<option value="line">Line (Horizontal)</option>
	</select>
					</td>
				</tr>
				<tr>
					<td class="style2">
					Choose Text Color: 
					<select name="text" style="height: 22px; width: 147px">
	<option value="255:000:000">Red</option>
	<option value="000:255:000">Green</option>
	<option value="000:000:255">Blue</option>
	<option value="000:000:000">Black</option>
	<option value="255:255:000">Yellow</option>
	<option value="255:128:000">Orange</option>
	<option value="128:064:000">Brown</option>
	<option value="000:255:255">Sky Blue</option>
	<option value="064:000:128">Purple</option>
	<option value="128:128:128">Grey</option>
	<option value="226:012:243">Pink</option>
	<option value="rand">Random</option>
	</select>
					
					</td>
				</tr>
				<tr>
					<td class="style2">
					Choose Background Color:
					<select name="bgc" style="height: 22px; width: 147px">
	<option value="000:000:000">Black</option>
	<option value="255:255:255">White</option>
	</select>
					
					</td>
				</tr>
	
				<tr>
					<td class="style2">
					Choose Line Color:<select name="linec" style="width: 153px">
	<option value="255:000:000">Red</option>
	<option value="000:255:000">Green</option>
	<option value="000:000:255">Blue</option>
	<option value="000:000:000">Black</option>
	<option value="255:255:000">Yellow</option>
	<option value="255:128:000">Orange</option>
	<option value="128:064:000">Brown</option>
	<option value="000:255:255">Sky Blue</option>
	<option value="064:000:128">Purple</option>
	<option value="128:128:128">Grey</option>
	<option value="226:012:243">Pink</option>
	<option value="rand">Random</option>
	</select>
					
					</td>
				</tr>
				<tr>
					<td class="style2">
					<input name="Submit1" type="submit" value="Generate Graph" />
					</form>
					</td>
				</tr>
			</table>
<br>
<?php

$filename = $_SERVER['SCRIPT_FILENAME'];
footer($filename);
?>