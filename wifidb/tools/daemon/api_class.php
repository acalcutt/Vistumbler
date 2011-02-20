<?php

/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

/**
 * Description of api_class
 *
 * @author pferland
 */
$api = new api_server($argv);
class api_server {
    //put your code here
    function __construct($argv)
    {
        $this->ver = '2.0';
        $this->author = 'Phil Ferland';
        $this->last = '2011-02-19';
        if(!$config_xml = @file_get_contents('config.inc.xml'))
        {
            die("Failed to read the config file.\r\n".$this->help());
        }
        $xml = xml2ary($config_xml);
        die(var_dump($xml));
        $this->settings['wifidb_install'] = $xml['config']['_c']['wifidb_install']['_v'];
        $this->settings['pid_file'] = $xml['config']['_c']['pid_file_loc']['_v']."api_d.pid";
        $this->settings['log_file'] = $xml['config']['_c']['daemon_log_folder']['_v']."api_d.log";
        
        if(!$config_w_xml = @file_get_contents($this->settings['wifidb_install'].'lib/config.inc.xml'))
        {
            die("Failed to read the config file.\r\n".$this->help());
        }
        $xml = xml2ary($config_w_xml);
        die(var_dump($xml));
        
        if(!@require_once($wifidb_install.'/lib/database.inc.php'))
        {
            die("Failed to include the database library\r\n".$this->help());
        }
        
        $this->settings['db']           =   $xml1['config']['_c']['db']['_v'];
        $this->settings['db_st']	=   $xml1['config']['_c']['db_st']['_v'];
        $this->settings['wtable']	=   $xml1['config']['_c']['wtable']['_v'];
        $this->settings['users_t']	=   $xml1['config']['_c']['users_t']['_v'];
        $this->settings['gps_ext']	=   $xml1['config']['_c']['gps_ext']['_v'];
        $this->settings['files']	=   $xml1['config']['_c']['files']['_v'];
        $this->settings['files_tmp']    =   $xml1['config']['_c']['files_tmp']['_v'];
        $this->settings['login_t']      =   $xml1['config']['_c']['user_logins_table']['_v'];
        $this->settings['seed']         =   $xml1['config']['_c']['login_seed']['_v'];
    }
    
    function help()
    {
        echo "\r\n\tWIFIDB API SERVER\r\n\tVersion: $this->ver\r\n\tLast Edit: $this->last\r\n\tAuthor: $this->author
\t\tCommands:
\t\t-c,--config\tLocation of the config file.\r\n-h,--help\tThis Help message.\r\n";
    }
}

class api_client {
    //put your code here
    function __construct() {
        
    }
}




function xml2ary(&$string="")
{
    if($string == "") return -1;
    $parser = xml_parser_create();
    xml_parser_set_option($parser, XML_OPTION_CASE_FOLDING, 0);
    xml_parse_into_struct($parser, $string, $vals, $index);
    xml_parser_free($parser);

    $mnary=array();
    $ary=&$mnary;
    foreach ($vals as $r) {
        $t=$r['tag'];
        if ($r['type']=='open') {
            if (isset($ary[$t])) {
                if (isset($ary[$t][0])) $ary[$t][]=array(); else $ary[$t]=array($ary[$t], array());
                $cv=&$ary[$t][count($ary[$t])-1];
            } else $cv=&$ary[$t];
            if (isset($r['attributes'])) {foreach ($r['attributes'] as $k=>$v) $cv['_a'][$k]=$v;}
            $cv['_c']=array();
            $cv['_c']['_p']=&$ary;
            $ary=&$cv['_c'];

        } elseif ($r['type']=='complete') {
            if (isset($ary[$t])) { // same as open
                if (isset($ary[$t][0])) $ary[$t][]=array(); else $ary[$t]=array($ary[$t], array());
                $cv=&$ary[$t][count($ary[$t])-1];
            } else $cv=&$ary[$t];
            if (isset($r['attributes'])) {foreach ($r['attributes'] as $k=>$v) $cv['_a'][$k]=$v;}
            $cv['_v']=(isset($r['value']) ? $r['value'] : '');

        } elseif ($r['type']=='close') {
            $ary=&$ary['_p'];
        }
    }    

    _del_p($mnary);
    return $mnary;
}

// _Internal: Remove recursion in result array
function _del_p(&$ary) {
    foreach ($ary as $k=>$v) {
        if ($k==='_p') unset($ary[$k]);
        elseif (is_array($ary[$k])) _del_p($ary[$k]);
    }
}
?>