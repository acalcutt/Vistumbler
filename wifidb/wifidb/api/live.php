<?php
$ft_start = microtime(1);
error_reporting(E_ALL|E_STRICT);
$startdate="14-Apr-2011";
$lastedit="01-Oct-2011";
$ver = "1.0.0";

global $screen_output;
$screen_output = "CLI";

include('../lib/config.inc.php');
#include('../lib/database.inc.php');
$live_aps = "live_aps";
$live_gps = "live_gps";

// AP Detail Variables
list($ssid_, $ssids) = make_ssid($_GET['SSID']);
$mac   =   filter_input(INPUT_GET, 'Mac', FILTER_SANITIZE_ENCODED, array(16,32) );
if($mac == ""){$mac = "000000000000";}
#$mac    =   implode(":", str_split($macs, 2));
$auth   =   filter_input(INPUT_GET, 'Auth', FILTER_SANITIZE_ENCODED, array(16,32) );
$encry  =   filter_input(INPUT_GET, 'Encry', FILTER_SANITIZE_ENCODED, array(16,32) );
$radio  =   filter_input(INPUT_GET, 'Rad', FILTER_SANITIZE_ENCODED, array(16,32) );
$sectype=   filter_input(INPUT_GET, 'SecType', FILTER_SANITIZE_NUMBER_INT)+0;
$chan   =   filter_input(INPUT_GET, 'Chn', FILTER_SANITIZE_NUMBER_INT)+0;
$lat    =   filter_input(INPUT_GET, 'Lat', FILTER_SANITIZE_ENCODED, array(16,32) );
$long   =   filter_input(INPUT_GET, 'Long', FILTER_SANITIZE_ENCODED, array(16,32) );
$BTx    =   filter_input(INPUT_GET, 'BTx', FILTER_SANITIZE_ENCODED, array(16,32) );
$OTx    =   filter_input(INPUT_GET, 'OTx', FILTER_SANITIZE_ENCODED, array(16,32) );
$FA     =   filter_input(INPUT_GET, 'FA', FILTER_SANITIZE_ENCODED, array(16,32) );
$LU     =   filter_input(INPUT_GET, 'FA', FILTER_SANITIZE_ENCODED, array(16,32) );
$NT     =   filter_input(INPUT_GET, 'NT', FILTER_SANITIZE_ENCODED, array(16,32) );
$label  =   filter_input(INPUT_GET, 'Label', FILTER_SANITIZE_ENCODED, array(16,32));
$sig    =   filter_input(INPUT_GET, 'Sig', FILTER_SANITIZE_STRING, array(4,8));

// GPS Variables
$sats           =   filter_input(INPUT_GET, 'Sats', FILTER_SANITIZE_NUMBER_INT);
$hdp            =   filter_input(INPUT_GET, 'HDP', FILTER_SANITIZE_NUMBER_FLOAT);
$alt            =   filter_input(INPUT_GET, 'ALT', FILTER_SANITIZE_NUMBER_FLOAT);
$geo            =   filter_input(INPUT_GET, 'GEO', FILTER_SANITIZE_NUMBER_FLOAT);
$kmh            =   filter_input(INPUT_GET, 'KMH', FILTER_SANITIZE_NUMBER_FLOAT);
$mph            =   filter_input(INPUT_GET, 'MPH', FILTER_SANITIZE_NUMBER_FLOAT);
$track          =   filter_input(INPUT_GET, 'Track', FILTER_SANITIZE_NUMBER_FLOAT);
$date           =   filter_input(INPUT_GET, 'Date', FILTER_SANITIZE_STRING, array(16,32));
$time           =   filter_input(INPUT_GET, 'Time', FILTER_SANITIZE_STRING, array(16,32));

//Username and API Key
$username   =   ( @$_GET['username'] ? filter_input(INPUT_GET, 'username', FILTER_SANITIZE_STRING, array(16,32)) : "UNKNOWN" );
#dump($username);
$apikey     =   ( @$_GET['apikey'] ? filter_input(INPUT_GET, 'apikey', FILTER_SANITIZE_STRING, array(16,32)) : "NONE" );

$returns = array();
switch(strtolower($radio))
{
    case "802.11a":
        $radios = "a";
        break;
    case "802.11b":
        $radios = "b";
        break;
    case "802.11g":
        $radios = "g";
        break;
    case "802.11n":
        $radios = "n";
        break;
    case "802.11u":
        $radios = "U";
        break;
}

#$table = $ssid_.$sep.$macs.$sep.$sectype.$sep.$radios.$sep.$chan.$gps_ext;

$conn = new mysqli($host, $db_user, $db_pwd);
$sql = "SELECT * FROM `$db`.`$live_aps` where mac = '$mac' AND ssid='$ssids' AND sectype='$sectype' AND radio='$radios' AND chan='$chan' AND username='$username';";
#echo $sql."<br />";

$result = $conn->query($sql);
$ap = $result->fetch_array(1);

if($ap['id'])
{
    #echo "is old AP<br />Lets add to the GPS history...";
    #dump($ap);

    $lat_sub = $lat[0];
    if($lat_sub != "-" && is_numeric($lat_sub))
    {
       $lat = "N ".$lat;
    }else #if(is_int(substr($gps['lat'], 0,1))+0)
    {
       $lat = str_replace("-", "S ", $lat);
    }
    ######
    ######
    ######
    #var_dump(substr($gps['long'], 0,1));
    $long_sub = $long[0];
    if($long_sub != "-" && is_numeric($long_sub))
    {
       $long = "E ".$long;
    }else #if(is_int(substr($gps['long'], 0,1)+0))
    {
       $long = str_replace("-", "W ", $long);
    }

    $sql = "INSERT INTO `$db`.`$live_gps` (`id`, `lat`, `long`, `sats`, `hdp`, `alt`, `geo`, `kmh`, `mph`, `track`, `date`, `time`)
    VALUES ('', '$lat', '$long', '$sats', '$hdp', '$alt', '$geo', '$kmh', '$mph', '$track', '$date', '$time');";
    #echo str_replace("
    #","<br />", $sql."<br /><br />");

    if($conn->query($sql))
    {
        $ins_sig = $ap['sig'].'|'.$sig.'-'.$conn->insert_id;
        $id = $ap['id'];
        $sql = "UPDATE `$db`.`$live_aps` SET sig='$ins_sig', lu = '$date $time' WHERE id='$id'";
        #echo $sql."</br>";
        if($conn->query($sql))
        {
            $returns[] = "Success!";
            #echo "Inserted</br>";
        }else
        {
            $returns[] = "Failure!";
            $returns[] = $conn->error;
        }
    }
}else
{
    #echo "add new AP<br />";

    $lat_sub = $lat[0];
    if($lat_sub != "-" && is_numeric($lat_sub))
    {
       $lat = "N ".$lat;
    }else #if(is_int(substr($gps['lat'], 0,1))+0)
    {
       $lat = str_replace("-", "S ", $lat);
    }
    ######
    ######
    ######
    #var_dump(substr($gps['long'], 0,1));
    $long_sub = $long[0];
    if($long_sub != "-" && is_numeric($long_sub))
    {
       $long = "E ".$long;
    }else #if(is_int(substr($gps['long'], 0,1)+0))
    {
       $long = str_replace("-", "W ", $long);
    }

    $sql = "INSERT INTO `$db`.`$live_gps` (`id`, `lat`, `long`, `sats`, `hdp`, `alt`, `geo`, `kmh`, `mph`, `track`, `date`, `time`)
    VALUES ('', '$lat', '$long', '$sats', '$hdp', '$alt', '$geo', '$kmh', '$mph', '$track', '$date', '$time');";
    #echo str_replace("
    #","<br />", $sql."<br /><br />");

    if($conn->query($sql))
    {
        $sql = "INSERT INTO  `$db`.`$live_aps` ( `id` , `ssid` , `mac` ,  `chan`, `radio`,`auth`,`encry`, `sectype`, `sig`, `username`, `BTx`, `OTx`, `NT`, `Label`, `fa`, `lu`)
        VALUES ('', '$ssids', '$mac','$chan', '$radios', '$auth', '$encry', '$sectype', '$sig-$conn->insert_id',  '$username', '$BTx', '$OTx', '$NT', '$label', '$date $time', '$date $time')";
        #echo str_replace("
        #","<br />", $sql."<br /><br />");
        if($conn->query($sql))
        {
            $returns[] = "Success!";
        }else
        {
            $returns[] = "Failure!";
            $returns[] = $conn->error;
        }
    }else
    {
        $returns[] = "Failure!";
        $returns[] = $conn->error;
        #echo $conn->error;
    }
}
foreach($returns as $ret)
{
    echo "#-".$ret."\r\n";
}
$ft_stop = microtime(1);
echo "#-time:".($ft_stop-$ft_start);



function make_ssid($ssid_in = '')
{
    $ssid_in = preg_replace('/[\x00-\x1F\x7F]/', '', $ssid_in);

    if($ssid_in == ""){$ssid_in="UNNAMED";}
    #var_dump($exp)."</br>";
    #if($ssid_len < 1){$ssid_in="UNNAMED";}

    ###########
    ## Make File Safe SSID
    $file_safe_ssid = smart_quotes($ssid_in);
    ###########

    ###########
    ## Make Row and HTML safe SSID
    $ssid_in_dupe = $ssid_in;
    $ssid_in = htmlentities($ssid_in, ENT_QUOTES);
    $ssid_safe_full_length = mysql_real_escape_string($ssid_in_dupe);
    ###########

    ###########
    ## Make Table safe SSID
    $ssid_sized = str_split($ssid_in_dupe, 25); //split SSID in two on is 25 char.
    $replace = array(' ', '`', '.', "'", '"', "/", "\\");
    #echo $ssid_sized[0];
    $ssid_table_safe = str_replace($replace,'_',$ssid_sized[0]); //Use the 25 char word for the APs table name, this is due to a limitation in MySQL table name lengths,
    ###########

    ###########
    ## Return
    #echo $ssid_table_safe;
    $A = array(0=>$ssid_table_safe, 1=>$ssid_safe_full_length , 2=> $ssid_in, 3=>$file_safe_ssid, 4=>$ssid_in_dupe);
    return $A;
    ###########
}
function smart_quotes($text="") // Used for SSID Sanatization
{
	$pattern = '/"((.)*?)"/i';
	$strip = array(
			0=>";",
			1=>"`",
			2=>"&", #
			3=>"!", #
			4=>"/", #
			5=>"\\", #
			6=>"'",
			7=>'"',
			8=>" "
			);
	$text = preg_replace($pattern,"&#147;\\1&#148;",$text);
	$text = str_replace($strip,"_",$text);
	return $text;
}
function dump($value="" , $level=0)
{
  if ($level==-1)
  {
    $trans[' ']='&there4;';
    $trans["\t"]='&rArr;';
    $trans["\n"]='&para;;';
    $trans["\r"]='&lArr;';
    $trans["\0"]='&oplus;';
    return strtr(htmlspecialchars($value),$trans);
  }
  if ($level==0) echo '<pre>';
  $type= gettype($value);
  echo $type;
  if ($type=='string')
  {
    echo '('.strlen($value).')';
    $value= dump($value,-1);
  }
  elseif ($type=='boolean') $value= ($value?'true':'false');
  elseif ($type=='object')
  {
    $props= get_class_vars(get_class($value));
    echo '('.count($props).') <u>'.get_class($value).'</u>';
    foreach($props as $key=>$val)
    {
      echo "\n".str_repeat("\t",$level+1).$key.' => ';
      dump($value->$key,$level+1);
    }
    $value= '';
  }
  elseif ($type=='array')
  {
    echo '('.count($value).')';
    foreach($value as $key=>$val)
    {
      echo "\n".str_repeat("\t",$level+1).dump($key,-1).' => ';
      dump($val,$level+1);
    }
    $value= '';
  }
  echo " <b>$value</b>";
  if ($level==0) echo '</pre>';
}
?>