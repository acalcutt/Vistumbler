<?php
session_start();

$ssid = $_GET['ssid'];
$mac = $_GET['mac'];
$auth = $_GET['auth'];
$encry = $_GET['encry'];
$radio = $_GET['radio'];
$chan = $_GET['chan'];

$waps_search = new ComposerData($ssid, $mac, $auth, $encry, $radio, $chan);
$waps = $waps_search->waps;

// simple matching for start of first or last name, or both
if($_GET['action'] == "complete")
{
    // prepare xml data
    if(sizeof($waps) != 0) {
        header('Content-type: text/xml');
        echo "<waps>";
        foreach($waps as $result) {
          #  var_dump($result);
            echo "<ap>";
            echo "<id>" . $result['id'] . "</id>";
            echo "<ssid>" . $result['ssid'] . "</ssid>";
            echo "<mac>" . $result['mac'] . "</mac>";
            echo "<auth>" . $result['auth'] . "</auth>";
            echo "<encry>" . $result['encry'] . "</encry>";
            echo "<radio>" . $result['radio'] . "</radio>";
            echo "<chan>" . $result['chan'] . "</chan>";
            echo "</ap>";
        }
        echo "</waps>";
    }
}

// if user chooses from pop-up box
if(isset($_GET['action']) && isset($_GET['id']) && $_GET['action'] == "lookup")
{
    foreach($waps as $ap)
    {
            $HTTP_SESSION_VARS["id"] = $ap->id;
            $HTTP_SESSION_VARS["ssid"] = $ap->ssid;
            $HTTP_SESSION_VARS["mac"] = $ap->mac;
            $HTTP_SESSION_VARS["auth"] = $ap->auth;
            $HTTP_SESSION_VARS["encry"] = $ap->encry;
            $HTTP_SESSION_VARS["radio"] = $ap->radio;
            $HTTP_SESSION_VARS["chan"] = $ap->chan;
            header("Location: /wifidb/opt/fetch.php?id=".$ap->id);
    }
}


class ComposerData {

    public $waps;
    public $ssid;
    public $mac;
    public $auth;
    public $encry;
    public $radio;
    public $chan;
    
    function __construct($ssid, $mac, $auth, $encry, $radio, $chan) {
        $this->ssid = $ssid;
        $this->mac = $mac;
        $this->auth = $auth;
        $this->encry = $encry;
        $this->radio = $radio;
        $this->chan = $chan;

        if($ssid == "" && $mac == "" && $auth == "" && $encry == "" && $radio == "" && $chan == ""){die();}

        include "../lib/config.inc.php";
        $mysqli = new mysqli($host, $db_user, $db_pwd, $db);
        
        if($ssid != ""){$sql_a[] = "`ssid` like '%$ssid%'";}
        if($mac != ""){$sql_a[] = "`mac` like '%$mac%'";}
        if($auth != ""){$sql_a[] = "`auth` like '%$auth%'";}
        if($encry != ""){$sql_a[] = "`encry` like '%$encry%'";}
        if($radio != ""){$sql_a[] = "`radio` like '%$radio%'";}
        if($chan != ""){$sql_a[] = "`chan` like '%$chan%'";}

        $sql_imp = implode(" AND ", $sql_a);
        $sql = "SELECT * FROM `$wtable` WHERE ".$sql_imp." LIMIT 0,15";
        $result = $mysqli->query($sql);
        while($obj = $result->fetch_array(MYSQLI_ASSOC))
        {
            $ret[] = $obj;
        }
        $this->waps = $ret;
    }
}
?>