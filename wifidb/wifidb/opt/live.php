<?php
$ft_start = microtime(1);
error_reporting(E_ALL|E_STRICT);
$startdate="14-Apr-2011";
$lastedit="19-Apr-2011";
$ver = "1.0.0";

global $screen_output;
$screen_output = "CLI";

include('../lib/config.inc.php');
#include('../lib/database.inc.php');
$live_aps = "live_aps";
$live_gps = "live_gps";

// AP Detail Variables
list($ssid_, $ssids) = make_ssid(@$_GET['SSID']);
$macs   =   (@$_GET['Mac'] ? filter_input(INPUT_GET, 'Mac', FILTER_SANITIZE_ENCODED, array(16,32) ) : "00:00:00:00:00:00");
$mac    =   str_replace(":","",$macs);
$radio  =   (@$_GET['Rad'] ? filter_input(INPUT_GET, 'Rad', FILTER_SANITIZE_ENCODED, array(16,32) ) : "802.11u");
$sectype=   (@$_GET['SecType'] ? filter_input(INPUT_GET, 'SecType', FILTER_SANITIZE_NUMBER_INT) : 0);
$chan   =   (@$_GET['Chn'] ? filter_input(INPUT_GET, 'Chn', FILTER_SANITIZE_NUMBER_INT) : 0);
//Other AP Info
$auth   =   (@$_GET['Auth'] ? filter_input(INPUT_GET, 'Auth', FILTER_SANITIZE_ENCODED, array(16,32) ) : "Open");
$encry  =   (@$_GET['Encry'] ? filter_input(INPUT_GET, 'Encry', FILTER_SANITIZE_ENCODED, array(16,32) ) : "None");
$BTx    =   (@$_GET['BTx'] ? filter_input(INPUT_GET, 'BTx', FILTER_SANITIZE_ENCODED, array(16,32) ) : "0.0");
$OTx    =   (@$_GET['OTx'] ? filter_input(INPUT_GET, 'OTx', FILTER_SANITIZE_ENCODED, array(16,32) ) : "0.0");
$NT     =   (@$_GET['NT'] ? filter_input(INPUT_GET, 'NT', FILTER_SANITIZE_ENCODED, array(16,32) ) : "Unknown");
$label  =   (@$_GET['Label'] ? filter_input(INPUT_GET, 'Label', FILTER_SANITIZE_ENCODED, array(16,32)) : "No Label");
$sig    =   (@$_GET['Sig'] ? filter_input(INPUT_GET, 'Sig', FILTER_SANITIZE_STRING, array(4,8)) : "0");

// GPS Variables
$lat    =   (@$_GET['Lat'] ? filter_input(INPUT_GET, 'Lat', FILTER_SANITIZE_ENCODED, array(16,32) ) : "N 0000.0000");
$long   =   (@$_GET['Long'] ? filter_input(INPUT_GET, 'Long', FILTER_SANITIZE_ENCODED, array(16,32) ) : "E 0000.0000");
$sats   =   (@$_GET['Sats'] ? filter_input(INPUT_GET, 'Sats', FILTER_SANITIZE_NUMBER_INT) : "0" );
$hdp    =   (@$_GET['HDP'] ? filter_input(INPUT_GET, 'HDP', FILTER_SANITIZE_NUMBER_FLOAT) : "0" );
$alt    =   (@$_GET['ALT'] ? filter_input(INPUT_GET, 'ALT', FILTER_SANITIZE_NUMBER_FLOAT) : "0" );
$geo    =   (@$_GET['GEO'] ? filter_input(INPUT_GET, 'GEO', FILTER_SANITIZE_NUMBER_FLOAT) : "0" );
$kmh    =   (@$_GET['KMH'] ? filter_input(INPUT_GET, 'KMH', FILTER_SANITIZE_NUMBER_FLOAT) : "0" );
$mph    =   (@$_GET['MPH'] ? filter_input(INPUT_GET, 'MPH', FILTER_SANITIZE_NUMBER_FLOAT) : "0" );
$track  =   (@$_GET['Track'] ? filter_input(INPUT_GET, 'Track', FILTER_SANITIZE_NUMBER_FLOAT) : "0" );
$date   =   (@$_GET['Date'] ? filter_input(INPUT_GET, 'Date', FILTER_SANITIZE_STRING, array(16,32)) : date("Y-m-d") );
$time   =   (@$_GET['Time'] ? filter_input(INPUT_GET, 'Time', FILTER_SANITIZE_STRING, array(16,32)) : date("H:i:s") );

//Username and API Key
$username   =   ( @$_GET['username'] ? filter_input(INPUT_GET, 'username', FILTER_SANITIZE_STRING, array(16,32)) : "UNKOWN" );
$apikey     =   ( @$_GET['apikey'] ? filter_input(INPUT_GET, 'apikey', FILTER_SANITIZE_STRING, array(16,32)) : "NONE" );

#dump($username);

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

$table = $ssid_.$sep.$macs.$sep.$sectype.$sep.$radios.$sep.$chan.$gps_ext;

$conn = new mysqli($host, $db_user, $db_pwd);
$sql = "SELECT id,ssid,mac,chan,sectype,auth,encry,radio FROM
        `$db`.`$wtable`
        WHERE `mac` = '$mac'
        AND `ssid` = '$ssids'
        AND `chan` = '$chan'
        AND `sectype` = '$sectype'
        AND `radio` = '$radios' LIMIT 1";
//echo $sql."<br />";
$result = $conn->query($sql) or printf($conn->error);
$array = $result->fetch_array(1);
if(@$array['id'])
{
    $AP_id = $array['id'];
    echo "It's an old AP :/<br />";

    $sql = "SELECT sig FROM
        `$db`.`$live_aps`
        WHERE `mac` = '$mac'
        AND `ssid` = '$ssids'
        AND `chan` = '$chan'
        AND `sectype` = '$sectype'
        AND `radio` = '$radios' LIMIT 1";

    $result->free();
    $result = $conn->query($sql) or printf($conn->error);
    $array = $result->fetch_array(1);
    $all_sigs = $array['sig'];

    $sig_exp = explode("|", $all_sigs);
    
    $sig_c = count($sig_exp)-1;
    if(!$sig_c)
    {
        $sig_exp_id = explode("-", $array['sig']);
        $id = $sig_exp_id[1];
        $signal = $sig_exp_id[0];
    }else
    {
        $sig_exp_id = explode("-", $sig_exp[$sig_c]);
        $id = $sig_exp_id[1];
        $signal = $sig_exp_id[0];
    }

    $sql = "SELECT * FROM `$db`.`$live_gps` WHERE `id` = '$id'";
    $result->free();
    $result = $conn->query($sql) or printf($conn->error);
    $array = $result->fetch_array(1);

    list($lat, $long) = format_gps($lat, $long);

    if( (!strcmp($array['lat'], $lat)) && (!strcmp($array['long'], $long)) )
    {
        echo "Lat/Long are the same, move a litte you lazy bastard.<br />";
    }else
    {
        echo "Lat/Long are different, what aboot the Sats and Date/Time, Eh?<br />";
        $url_time   = strtotime($date." ".$time);
        $db_time    = strtotime($array['date']." ".$array['time']);
        if(($url_time - $db_time) > 2)
        {
            echo "Oooo its time is newer o_0, lets go insert it<br />";
            $sql = "INSERT INTO `$db`.`$live_gps` (`id`, `lat`, `long`, `sats`, `hdp`, `alt`, `geo`, `kmh`, `mph`, `track`, `date`, `time`)
            VALUES ('', '$lat', '$long', '$sats', '$hdp', '$alt', '$geo', '$kmh', '$mph', '$track', '$date', '$time');";
           // echo str_replace("
           // ","<br />", $sql."<br /><br />");
            $conn->query($sql) or printf($conn->error);

            $sig = $all_sigs."|".$signal."-".$conn->insert_id;

            $sql = "UPDATE `$db`.`live_aps` SET `sig` = '$sig', `LA` = '$date $time' WHERE `id` = '$AP_id'";
            //echo $sql."<br /><br />";
            $conn->query($sql) or printf($conn->error);

        }else
        {
            echo "What are you thinking? You cant have more then a second resolution. >:(<br />";
        }
    }
}else
{
    echo "Add new AP. :]<br />";

    list($lat, $long) = format_gps($lat, $long);
    
    $sql = "INSERT INTO `$db`.`$live_gps` (`id`, `lat`, `long`, `sats`, `hdp`, `alt`, `geo`, `kmh`, `mph`, `track`, `date`, `time`)
    VALUES ('', '$lat', '$long', '$sats', '$hdp', '$alt', '$geo', '$kmh', '$mph', '$track', '$date', '$time');";
    //echo str_replace("
    //","<br />", $sql."<br /><br />");
    $conn->query($sql) or printf($conn->error);
    $sig = $sig."-".$conn->insert_id;
    $sql = "INSERT INTO  `$db`.`$live_aps` ( `id` , `ssid` , `mac` ,  `chan`, `radio`,`auth`,`encry`, `sectype`, `sig`, `username`)
    VALUES ('', '$ssids', '$mac','$chan', '$radios', '$auth', '$encry', '$sectype', '$sig',  '$username' ) ";
    //echo str_replace("
    //","<br />", $sql."<br /><br />");
    $conn->query($sql) or printf($conn->error);

    $sql = "INSERT INTO  `$db`.`$wtable` ( `id`, `ssid`, `mac`, `chan`, `radio`, `auth`, `encry`, `sectype`, `BTx`, `OTx`, `NT`, `Label`, `LA`, `lat`, `long`, `active`)
                                  VALUES ('', '$ssids', '$mac','$chan', '$radios', '$auth', '$encry', '$sectype', '$BTx', '$OTx', '$NT', '$label', '$date $time', '$lat',  '$long', '1' ) ";
    //echo str_replace("
    //","<br />", $sql."<br /><br />");
    $conn->query($sql) or printf($conn->error);

}

$ft_stop = microtime(1);
echo "Total Memory Usage: ".memory_get_usage(1)."<br />";
echo "1 Time: ".($ft_stop-$ft_start);

























function format_gps($lat, $long)
{
    $lat = str_replace("%20", " ", $lat);
    $long = str_replace("%20", " ", $long);
    
    $lat_sub = $lat[0];
    if($lat_sub != "-" && is_numeric($lat_sub))
    {
       $lat = "N ".$lat;
    }else #if(is_int(substr($gps['lat'], 0,1))+0)
    {
       $lat = str_replace("-", "S ", $lat);
    }

    $long_sub = $long[0];
    if($long_sub != "-" && is_numeric($long_sub))
    {
       $long = "E ".$long;
    }else #if(is_int(substr($gps['long'], 0,1)+0))
    {
       $long = str_replace("-", "W ", $long);
    }

    $out = array($lat, $long);
    return $out;
}



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