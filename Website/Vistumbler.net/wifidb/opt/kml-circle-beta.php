<title>Welcome to the Random Intervals Wireless DB</title>
<link rel="stylesheet" href="/wifidb/css/site4.0.css">
<body topmargin="10" leftmargin="0" rightmargin="0" bottommargin="10" marginwidth="10" marginheight="10">
<div align="center">
<table border="0" width="75%" cellspacing="10" cellpadding="2">
	<tr>
		<td bgcolor="#315573">
		<p align="center"><b><font size="5" face="Arial" color="#FFFFFF">
		Randomintervals.com </font>
		<font color="#FFFFFF" size="2">
            <a class="links" href="/">[Root] </a>/ <a class="links" href="/wifidb/">[WifiDB] </a>/
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
$lastmodified="4.26.08";
include('../lib/config.inc.php');
$conn = mysql_connect($host, $db_user, $db_pwd);
mysql_select_db($db,$conn);
$sqls = "SELECT * FROM links ORDER BY ID ASC";
$result = mysql_query($sqls, $conn) or die(mysql_error());
while ($newArray = mysql_fetch_array($result))
{
	$testField = $newArray['links'];
    echo "<p>$testField</p>";
}
?>

</td>
		<td width="80%" bgcolor="#A9C6FA" valign="top" align="center">
			<p align="center">
<?php
$id=$_GET['id'];

mysql_select_db($db,$conn);
$sqls = "SELECT * FROM wifi WHERE id=$id";
$result = mysql_query($sqls, $conn) or die(mysql_error());
while ($newArray = mysql_fetch_array($result))
{
$ssid=$newArray['ssid'];
$mac=$newArray['mac'];
$sectype = $newArray['sectype'];
$radio = $newArray['radio'];
$chan=$newArray['chan'];
$table_gps = $ssid.$sep.$mac.$sep.$sectype.$sep.$radio.$sep.$chan.$gps_ext;

mysql_select_db($db,$conn);
$sqls = "SELECT * FROM `$table_gps`";
$result = mysql_num_row($sqls, $conn) or die(mysql_error());


list($centerlat_form , $centerlong_form) &= convert_dm_dd($newArray['lat'],$gpsarray['long']);
 
}
$longs=explode(" ",$centerlong_form,2);
$lats=explode(" ",$centerlat_form,2);
if ($longs[0]=="W")
{$longs[0]="-";}else{$longs[0]="";}
if ($lats[0]=="S")
{$lats[0]="-";}else{$lats[0]="";}
$latss=implode("",$lats);
$longss=implode("",$longs);


$radius_form=20;
// make sure we have the information we need
if ((!$latss || !$longss) ||
    (!$latss && !$radius_form) )
{
  echo "WHAT ARE YOU DOIN MAN!<BR>You cant just run this script all by itself, you need data man DATA!!!!!!!!!!!!!!!!!!!!<br>Now go back and do it right damnit<br><br>       -RanInt Dev/Admin/God";
  exit(1);
}

// convert coordinates to radians
$lat1 = deg2rad($latss);
$long1 = deg2rad($longss);
$lat2 = deg2rad($latss);
$long2 = deg2rad($longss);

// get the difference between lat/long coords
$dlat = $lat2-$lat1;
$dlong = $long2-$long1;

// if the radius of the circle wasn't given, we need to calculate it
if (!$radius_form) {
  // compute distance of great circle
  $a = pow((sin($dlat/2)), 2) + cos($lat1) * cos($lat2) *
       pow((sin($dlong/2)), 2);
  $c = 2 * atan2(sqrt($a), sqrt(1-$a));
  // get distance between points (in meters)
  $d = 6378137 * $c;
} else {
  $d = $radius_form;
}

$d_rad = $d/6378137;
$file_ext = $MAC.'_'.$ssid.'_'.$chan.'.kml';
$filename = ('files/kml/'.$file_ext);

// define initial write and appends
$filewrite = fopen($filename, "w");
$fileappend = fopen($filename, "a");

// open file and write header:
fwrite($filewrite, "<Folder>\n<name></name>\n<visibility>1</visibility>\n<Placemark>\n<name></name>\n<visibility>1</visibility>\n<Style>\n<geomColor>ff0000ff</geomColor>\n<geomScale>1</geomScale></Style>\n<LineString>\n<coordinates>\n");
// loop through the array and write path linestrings
for($i=0; $i<=360; $i++) {
  $radial = deg2rad($i);
  $lat_rad = asin(sin($lat1)*cos($d_rad) + cos($lat1)*sin($d_rad)*cos($radial));
  $dlon_rad = atan2(sin($radial)*sin($d_rad)*cos($lat1),
                    cos($d_rad)-sin($lat1)*sin($lat_rad));
  $lon_rad = fmod(($long1+$dlon_rad + M_PI), 2*M_PI) - M_PI;
  fwrite( $fileappend, rad2deg($lon_rad).",".rad2deg($lat_rad).",0 ");
  }

// write everything else and clean up

fwrite( $fileappend, "</coordinates>\n</LineString>\n</Placemark>\n</Folder>");
fwrite( $fileappend, " ");
fclose( $fileappend );
if(file_exists($filename)) {
  echo ('<p>Your WAP ('.$MAC.'_'.$ssid.'_'.$chan.'.kml)Google Earth File is <a href="$filename">right here</a><br>Thanks to <a href="http://bbs.keyhole.com/ubb/showthreaded.php?Number=23634" target="_blank">ink_polaroid</a> for the circle generator.</p>');
} else {
  echo( "If you can see this, something is wrong..." );
}
?>
</p>
</td>
</tr>
<tr>
<td bgcolor="#315573" height="23"><a href="/pictures/moon.png"><img border="0" src="/pictures/moon_tn.PNG"></a></td>
<td bgcolor="#315573" width="0">&nbsp;</td>
</tr>
</table>
</div>
</html>
