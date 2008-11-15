<?php
/////////////////////////////////////////////////////////////////
//  By: Phillip Ferland (Longbow486)                           //
//  Email: longbow486@msn.com                                  //
//  Started on: 10.14.07                                       //
//  Purpose: To generate a PNG graph of a WAP's signals        //
//           from URL driven data                              //
//  Filename: genlineurl.php                                   //
/////////////////////////////////////////////////////////////////
include('../lib/config.inc.php');

$startdate="14-10-2007";
$lastedit="30-10-2008";
echo '<title>WiFiDB PNG Signal Graph *Beta* - ---RanInt---</title>';
?>

<link rel="stylesheet" href="../css/site4.0.css">
<body topmargin="10" leftmargin="0" rightmargin="0" bottommargin="10" marginwidth="10" marginheight="10">
<div align="center">
<table border="0" width="75%" cellspacing="10" cellpadding="2">
	<tr>
		<td bgcolor="#315573">
		<p align="center"><b><font size="5" face="Arial" color="#FFFFFF">
		Wireless DataBase *Alpha* </font>
		<font color="#FFFFFF" size="2">
            <a class="links" href="/">[Root] </a>/
		</font></b>
		</td>
	</tr>
</table>
</div>
<div align="center">
<table border="0" width="75%" cellspacing="10" cellpadding="2" height="90">
	<tr>
<td width="17%" bgcolor="#304D80" valign="top">

<?php
mysql_select_db($db,$conn);
$sqls = "SELECT * FROM links ORDER BY ID ASC";
$result = mysql_query($sqls, $conn);
while ($newArray = mysql_fetch_array($result))
{
	$testField = $newArray['links'];
    echo "<p>$testField</p>";
}
?>

</td>
		<td width="80%" bgcolor="#A9C6FA" valign="top" align="center">
			<p align="center">

<form action="genline.php" method="post" enctype="multipart/form-data">

<?php
echo '<h1>Graph an Access Points Signal history *Beta*</h1><h4>Bar Graph=>'.$ver['graphs']['wifibar'].'<br>Line Graph=>'.$ver['graphs']['wifiline'].'</h4>';

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

$man_mac = str_split($pointer["mac"], 6);
$table=$pointer["ssid"].'-'.$pointer["mac"].'-'.$pointer["sectype"].'-'.$pointer["radio"].'-'.$pointer["chan"];
$table_gps = $table.$gps_ext;
$name = $table."_".$row;

mysql_select_db($db_st,$conn);
$sql = "SELECT*FROM`$table`WHERE`id`=$row";
$result = mysql_query($sql, $conn) or die(mysql_error());
$ap_table = mysql_fetch_array($result);

if ( $manufactures[$man_mac[0]] == ""){$man = "UNKNOWN Manuf";}else{ $man =  $manufactures[$man_mac[0]];}

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
$file_ex = explode("/", $filename);
$count = count($file_ex);
$file = $file_ex[($count)-1];
if (file_exists($filename)) {
    echo "<h6><i><u>$file</u></i> was last modified: " . date ("F d Y H:i:s.", filemtime($filename)) . "</h6>";
}
?></td>
</tr>
<tr>
<td bgcolor="#315573" height="23"><a href="/pictures/moon.png"><img border="0" src="/pictures/moon_tn.PNG"></a></td>
<td bgcolor="#315573" width="0">
</td>
</tr>
</table>