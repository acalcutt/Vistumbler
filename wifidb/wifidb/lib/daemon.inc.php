<?php
class daemon
{
    function live_migrate($arg1, $arg2)
    {
        if($arg1 == "UNKNOWN")
        {
            $sql = "SELECT * FROM `$db`.`$live_aps` where `id` = '$arg2'";
        }else
        {
            $sql = "SELECT * FROM `$db`.`$live_aps` where `username` = '$arg1'";
        }
    }
####################
    function live_export($arg1, $arg2)
    {
        if($arg1 == "UNKNOWN")
        {
            $sql = "SELECT * FROM `$db`.`$live_aps` where `id` = '$arg2'";
        }else
        {
            $sql = "SELECT * FROM `$db`.`$live_aps` where `username` = '$arg1' ORDER BY `LA` DESC";
        }
        $result1 =  $conn->query($sql) or die($conn->error);
        echo "Rows: ".$result1->num_rows."\r\n";
        $nn =-1;
        $n =1;	# GPS Array KEY -has to start at 1 vistumbler will error out if the first GPS point has a key of 0
        while($list_array = $result1->fetch_array(1))
        {
                if($list_array["points"] == ''){continue;}
                $points = explode("-", $list_array['points']);
                $title = $list_array['title'];
        #	echo "Starting AP Export.\r\n";
                foreach($points as $point)
                {
        #		echo $point."\r\n";
                        $nn++;
                        $point_exp = explode(",", $point);
                        $pnt = explode(":", $point_exp[1]);
                        $rows = $pnt[1];
                        $APID = $pnt[0];
                        $sql	= "SELECT * FROM `$db`.`$wtable` WHERE `id` = '$APID' LIMIT 1";
                        $result2   =   $conn->query($sql, $conn) or die($conn->error);
                        $ap_array = $result2->fetch_array(1);
                        #var_dump($ap_array);
                        $manuf = @database::manufactures($ap_array['mac']);
                        switch($ap_array['sectype'])
                                {
                                        case 1:
                                                $type = "#openStyleDead";
                                                $auth = "Open";
                                                $encry = "None";
                                                break;
                                        case 2:
                                                $type = "#wepStyleDead";
                                                $auth = "Open";
                                                $encry = "WEP";
                                                break;
                                        case 3:
                                                $type = "#secureStyleDead";
                                                $auth = "WPA-Personal";
                                                $encry = "TKIP-PSK";
                                                break;
                                }
                        switch($ap_array['radio'])
                                {
                                        case "a":
                                                $radio="802.11a";
                                                break;
                                        case "b":
                                                $radio="802.11b";
                                                break;
                                        case "g":
                                                $radio="802.11g";
                                                break;
                                        case "n":
                                                $radio="802.11n";
                                                break;
                                        default:
                                                $radio="Unknown Radio";
                                                break;
                                }
        #		echo $ap_array['id']." -- ".$ap_array['ssid']."\r\n";
                        $ssid_edit = html_entity_decode($ap_array['ssid']);
                        list($ssid_t, $ssid_f, $ssid)  = make_ssid($ssid_edit);
                #	$ssid_t = $ssid_array[0];
                #	$ssid_f = $ssid_array[1];
                #	$ssid = $ssid_array[2];
                        $table	=	$ssid_t.'-'.$ap_array['mac'].'-'.$ap_array['sectype'].'-'.$ap_array['radio'].'-'.$ap_array['chan'];
                        $sql1 = "SELECT * FROM `$db_st`.`$table` WHERE `id` = '$rows'";
                        $result1 = mysql_query($sql1, $conn) or die(mysql_error($conn));
                        $newArray = mysql_fetch_array($result1);
#					echo $nn."<BR>";
                        $otx	= $newArray["otx"];
                        $btx	= $newArray["btx"];
                        $nt		= $newArray['nt'];
                        $label	= $newArray['label'];
                        $signal	= $newArray['sig'];
                        $aps[$nn]	= array(
                                                                'id'		=>	$ap_array['id'],
                                                                'ssid'		=>	$ssid_t,
                                                                'mac'		=>	$ap_array['mac'],
                                                                'sectype'	=>	$ap_array['sectype'],
                                                                'r'			=>	$radio,
                                                                'radio'		=>	$ap_array['radio'],
                                                                'chan'		=>	$ap_array['chan'],
                                                                'man'		=>	$manuf,
                                                                'type'		=>	$type,
                                                                'auth'		=>	$auth,
                                                                'encry'		=>	$encry,
                                                                'label'		=>	$label,
                                                                'nt'		=>	$nt,
                                                                'btx'		=>	$btx,
                                                                'otx'		=>	$otx,
                                                                'sig'		=>	$signal
                                                                );

                        $sig		=	$aps[$nn]['sig'];
                        $signals	=	explode("-", $sig);
#				echo $sig."<BR>";
                        $table_gps		=	$aps[$nn]['ssid'].'-'.$aps[$nn]['mac'].'-'.$aps[$nn]['sectype'].'-'.$aps[$nn]['radio'].'-'.$aps[$nn]['chan'].$gps_ext;
        #		echo $table_gps."\r\n";
                        foreach($signals as $key=>$val)
                        {
                                $sig_exp = explode(",", $val);
                                $gps_id	= $sig_exp[0];

                                $sql1 = "SELECT * FROM `$db_st`.`$table_gps` WHERE `id` = '$gps_id'";
                                $result1 = mysql_query($sql1, $conn) or die(mysql_error($conn));
                                $gps_table = mysql_fetch_array($result1);
                                $gps_array[$n]	=	array(
                                                                                "lat" => $gps_table['lat'],
                                                                                "long" => $gps_table['long'],
                                                                                "sats" => $gps_table['sats'],
                                                                                "hdp" => $gps_table['hdp'],
                                                                                "alt" => $gps_table['alt'],
                                                                                "geo" => $gps_table['geo'],
                                                                                "kmh" => $gps_table['kmh'],
                                                                                "mph" => $gps_table['mph'],
                                                                                "track" => $gps_table['track'],
                                                                                "date" => $gps_table['date'],
                                                                                "time" => $gps_table['time']
                                                                                );
                                $n++;
                                $signals[] = $n.",".$sig_exp[1];
                        }
                        echo $nn."-".$n."==";
                        $sig_new = implode("-", $signals);
                        $aps[$nn]['sig'] = $sig_new;
                        unset($signals);
                }
        }
    }
####################
    function daemon_kml($named = 0, $verbose = 1)
    {
        require $GLOBALS['wifidb_tools']."/daemon/config.inc.php";
        require $GLOBALS['wdb_install']."/lib/config.inc.php";
        verbosed($GLOBALS['COLORS']['GREEN']."Starting Automated KMZ creation.".$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, "CLI");
        
        $this->db_st            =   $GLOBALS['db_st'];
        $this->db               =   $GLOBALS['db'];
        $this->conn             =   $GLOBALS['conn'];
        $this->gps_ext          =   $GLOBALS['gps_ext'];
        $this->root             =   $GLOBALS['root'];
        $this->hosturl          =   $GLOBALS['hosturl'];
        $this->open_loc         =   $GLOBALS['open_loc'];
        $this->WEP_loc          =   $GLOBALS['WEP_loc'];
        $this->WPA_loc          =   $GLOBALS['WPA_loc'];
        $this->KML_SOURCE_URL   =   $GLOBALS['KML_SOURCE_URL'];

        $start  =   microtime(true);

        $this->daily_folder = $GLOBALS['wdb_install']."out/daemon/".date('Y-m-d')."/";
        $this->daemon_folder = $GLOBALS['wdb_install']."out/daemon/";
        if(!(is_dir($this->daily_folder)))
        {
            echo "Make Folder $this->daily_folder\n";
            mkdir($this->daily_folder, 0755);
        }

        $this->temp_index_kml = $this->daily_folder.'doc.kml';
        $this->temp_daily_kml = $this->daily_folder.'daily_db.kml';
        $this->temp_dailyL_kml = $this->daily_folder.'daily_db_label.kml';
        $this->temp_kml = $this->daily_folder.'full_db.kml';
        $this->temp_kml_label = $this->daily_folder.'full_db_label.kml';
        $this->filename = $this->daemon_folder.'fulldb.kmz';
        $this->filename_copy = $this->daily_folder.'fulldb.kmz';

        # do a full Db export for the day if needed
        $this->temp_kml_size = dos_filesize($this->temp_kml);
        if(!file_exists($this->temp_kml) or $this->temp_kml_size == '0' )
        {
            $this->daemon_full_db_exp($this->temp_kml, $this->temp_kml_label, $verbose);
        }
        else
        {
            verbosed($GLOBALS['COLORS']['RED']."File already exists, no need to export full DB.".$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, "CLI");
        }
        ## Since the Full DB exists, lets do a daily.
        $this->daemon_daily_db_exp($this->temp_daily_kml, $this->temp_dailyL_kml, $verbose);
        
        ####
        ##  OK thats done, lets make the index file for the KMZ, so Earth can find the full and daily kmls
        ####
        verbosed($GLOBALS['COLORS']['LIGHTGRAY']."Writing Index KML for KMZ file.".$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, "CLI");
        $this->filewrite = fopen($this->temp_index_kml, "w");
        $this->fileappend_index = fopen($this->temp_index_kml, "a");

        fwrite($this->fileappend_index, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<kml xmlns=\"http://www.opengis.net/kml/2.2\" xmlns:gx=\"http://www.google.com/kml/ext/2.2\" xmlns:kml=\"http://www.opengis.net/kml/2.2\" xmlns:atom=\"http://www.w3.org/2005/Atom\">
<Document>
    <name>WiFiDB Daily KMZ</name>
    <open>1</open>
    <Folder>
            <name>WiFiDB Daily DB Export</name>
            <open>1</open>
            <Style>
                    <ListStyle>
                            <listItemType>radioFolder</listItemType>
                            <bgColor>00ffffff</bgColor>
                            <maxSnippetLines>2</maxSnippetLines>
                    </ListStyle>
            </Style>
            <NetworkLink>
                    <name>daily_db.kml</name>
                    <Link>
                            <href>files/daily_db.kml</href>
                    </Link>
            </NetworkLink>
            <NetworkLink>
                    <name>daily_db_label.kml</name>
                    <visibility>0</visibility>
                    <Link>
                            <href>files/daily_db_label.kml</href>
                    </Link>
            </NetworkLink>
    </Folder>
    <Folder>
            <name>WiFiDB Full DB Export</name>
            <open>1</open>
            <Style>
                    <ListStyle>
                            <listItemType>radioFolder</listItemType>
                            <bgColor>00ffffff</bgColor>
                            <maxSnippetLines>2</maxSnippetLines>
                    </ListStyle>
            </Style>
            <NetworkLink>
                    <name>full_db.kml</name>
                    <Link>
                            <href>files/full_db.kml</href>
                    </Link>
            </NetworkLink>
            <NetworkLink>
                    <name>full_db _label.kml</name>
                    <visibility>0</visibility>
                    <Link>
                            <href>files/full_db_label.kml</href>
                    </Link>
            </NetworkLink>
    </Folder>
</Document>
</kml>
");
        fclose($this->fileappend_index);

        # Zip them all up into a KMZ file
        verbosed($GLOBALS['COLORS']['LIGHTGRAY']."KMZ file, with everything in it: ".$this->filename."\n".$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, "CLI");

        $this->moved = "/tmp/temp.zip";
        $zip = new ZipArchive;
        if ($zip->open($this->moved, ZIPARCHIVE::OVERWRITE) === TRUE)
        {
    #	$zip->addEmptyDir('files');
            $zip->addFile($this->temp_index_kml, 'doc.kml');
            $zip->addFile($this->temp_kml, 'files/full_db.kml');
            $zip->addFile($this->temp_kml_label, 'files/full_db_label.kml');

            $zip->addFile($this->temp_daily_kml, 'files/daily_db.kml');
            $zip->addFile($this->temp_dailyL_kml, 'files/daily_db_label.kml');

            $zip->close();

            verbosed($GLOBALS['COLORS']['GREEN']."The KMZ file is ready.".$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, "CLI");
#		echo "Zipped up\n";
            verbosed($GLOBALS['COLORS']['GREEN']."Starting Cleanup of Temp Files.".$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, "CLI");
            # cleanup
            unlink($this->temp_index_kml);
            unlink($this->temp_kml);
            unlink($this->temp_kml_label);
            unlink($this->temp_daily_kml);
            unlink($this->temp_dailyL_kml);
        } else {
            verbosed($GLOBALS['COLORS']['RED']."The KMZ file is NOT ready.".$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, "CLI");
#		echo "Blown up\n";
        }

        recurse_chown_chgrp($this->daemon_folder, $GLOBALS['WiFiDB_LNZ_User'], $GLOBALS['apache_grp']);
        recurse_chmod($this->daemon_folder, 0755);

        copy($this->moved, $this->filename);
        copy($this->filename, $this->filename_copy);

        ######## The Network Link KML file
        $this->daemon_KMZ_folder = $GLOBALS['UPATH']."/out/daemon/";

        $this->Network_link_KML = $this->daemon_KMZ_folder."update.kml";

        $this->daemon_daily_KML = $GLOBALS['wdb_install']."/out/daemon/update.kml";

        $this->filewrite = fopen($this->daemon_daily_KML, "w");
        $this->fileappend_update = fopen($this->daemon_daily_KML, "a");


        fwrite($this->fileappend_update, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<kml xmlns=\"http://earth.google.com/kml/2.2\">
    <Document>
            <name>WiFiDB *ALPHA* Auto KMZ Generation</name>
            <Folder>
            <name> Newest Access Point</name>
            <open>1</open>
            <Style>
                    <ListStyle>
                            <listItemType>radioFolder</listItemType>
                            <bgColor>00ffffff</bgColor>
                            <maxSnippetLines>2</maxSnippetLines>
                    </ListStyle>
            </Style>
            <NetworkLink>
                    <name>Newest AP</name>
                    <flyToView>1</flyToView>
                    <Url>
                            <href>".$this->daemon_KMZ_folder."newestAP.kml</href>
                            <refreshMode>onInterval</refreshMode>
                            <refreshInterval>1</refreshInterval>
                    </Url>
            </NetworkLink>
            <NetworkLink>
                    <name>Newest AP Label</name>
                    <flyToView>1</flyToView>
                    <Url>
                            <href>".$this->daemon_KMZ_folder."newestAP_label.kml</href>
                            <visibility>0</visibility>
                            <refreshMode>onInterval</refreshMode>
                            <refreshInterval>1</refreshInterval>
                    </Url>
            </NetworkLink>
            </Folder>
            <name>Daemon Generated KMZ</name>
            <open>1</open>
            <NetworkLink>
                    <name>Daily KMZ</name>
                    <Url>
                            <href>".$this->daemon_KMZ_folder."fulldb.kmz</href>
                            <refreshMode>onInterval</refreshMode>
                            <refreshInterval>3600</refreshInterval>
                    </Url>
            </NetworkLink>
    </Document>
</kml>");
        fclose($this->fileappend_update);
        verbosed($GLOBALS['COLORS']['GREEN']."Daily DB export complete.".$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, "CLI");
        verbosed($GLOBALS['COLORS']['LIGHTGRAY']."KML file is ready ->\n\t\t ".$this->Network_link_KML."\n".$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, "CLI");
        $end = microtime(true);
        echo "Time is [Unix Epoc]\n";
        echo "Start Time: ".$start."\n";
        echo "  End Time: ".$end."\n";
#		die();
    }
####################
    function daemon_full_db_exp($temp_kml="", $temp_kml_label="", $verbose = 0)
    {
        require_once "config.inc.php";
        require_once $GLOBALS['wdb_install']."/lib/config.inc.php";
        $mem_file = "Memory_map.txt";
        file_put_contents($mem_file, "");

        $this->db_st = $GLOBALS['db_st'];
        $this->db = $GLOBALS['db'];
        $this->conn = new mysqli($GLOBALS['host'], $GLOBALS['db_user'], $GLOBALS['db_pwd']);
        $this->settings = $GLOBALS['settings_tb'];
        $this->users_imports = $GLOBALS['users_t'];
        $this->verbose = $GLOBALS['verbose'];
        $this->open_loc 	=	$GLOBALS['open_loc'];
        $this->WEP_loc          =	$GLOBALS['WEP_loc'];
        $this->WPA_loc          =	$GLOBALS['WPA_loc'];
        $this->KML_SOURCE_URL	=	$GLOBALS['KML_SOURCE_URL'];
        $this->database         =       new database();
        
// define initial write and appends
        $this->filewrite = fopen($temp_kml, "w");
        $this->fileappend = fopen($temp_kml, "a");
        $this->filewrite_label = fopen($temp_kml_label, "w");
        $this->fileappend_label = fopen($temp_kml_label, "a");
        
        $this->sql = "SELECT * FROM `$this->db`.`$this->settings` where `id`='2'";
        $this->result = $this->conn->query($this->sql);
        $this->total_ = $this->result->fetch_array(1);
        $this->total = $this->total_['size'];

        # Write non label Header data
        $this->data  =  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<kml xmlns=\"http://earth.google.com/kml/2.2\">
    <Document>
        <Style id=\"openStyleDead\">
            <IconStyle>
                <scale>0.5</scale>
                <Icon>
                    <href>http://vistumbler.sourceforge.net/images/program-images/open.png</href>
                </Icon>
            </IconStyle>
        </Style>
        <Style id=\"wepStyleDead\">
            <IconStyle>
                <scale>0.5</scale>
                <Icon>
                    <href>http://vistumbler.sourceforge.net/images/program-images/secure-wep.png</href>
                </Icon>
            </IconStyle>
        </Style>
        <Style id=\"secureStyleDead\">
            <IconStyle>
                <scale>0.5</scale>
                <Icon>
                    <href>http://vistumbler.sourceforge.net/images/program-images/secure.png</href>
                </Icon>
            </IconStyle>
        </Style>
        <name>WiFiDB Access Points</name>";
        fwrite($this->fileappend, $this->data);
        
        #Write labeled header data
        $this->Ldata = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<kml xmlns=\"http://earth.google.com/kml/2.2\">
    <Document>
        <Style id=\"openStyleDead\">
            <IconStyle>
                <scale>0.5</scale>
                <Icon>
                    <href>http://vistumbler.sourceforge.net/images/program-images/open.png</href>
                </Icon>
            </IconStyle>
        </Style>
        <Style id=\"wepStyleDead\">
            <IconStyle>
                <scale>0.5</scale>
                <Icon>
                    <href>http://vistumbler.sourceforge.net/images/program-images/secure-wep.png</href>
                </Icon>
            </IconStyle>
        </Style>
        <Style id=\"secureStyleDead\">
            <IconStyle>
                <scale>0.5</scale>
                <Icon>
                    <href>http://vistumbler.sourceforge.net/images/program-images/secure.png</href>
                </Icon>
            </IconStyle>
        </Style>
        <name>WiFiDB AP Labels</name>
        <description>Total: $total</description>";
        fwrite($this->fileappend_label, $this->Ldata);

        $skip = array();
        $date = date("Y-m-d");
        $this->sql = "SELECT * FROM `$this->db`.`$this->users_imports` where `date` like '$date%'";
        $this->result = $this->conn->query($this->sql);
        while($this->today_array = $this->result->fetch_array(1))
        {
            $points_exp = explode("-",$this->today_array['points']);
            foreach($points_exp as $point_a)
            {
                $p_e = explode(":", $point_a);
                $p_e_2 = explode(",", $p_e[0]);
                if(!in_array($p_e_2[1], $skip))
                {
                    $skip[] = $p_e_2[1];
                }
            }
        }
        #var_dump($skip);
        #die();
        error_reporting("E_WARNING");
        gc_enable();
        $this->gen_kml_place("1", $skip, $this->fileappend, $this->fileappend_label, $mem_file);
        $this->gen_kml_place("2", $skip, $this->fileappend, $this->fileappend_label, $mem_file);
        $this->gen_kml_place("3", $skip, $this->fileappend, $this->fileappend_label, $mem_file);

        $this->data = "</Document>\r\n</kml>";
        fwrite($this->fileappend, $this->data);
        fclose($this->fileappend);

        $Ldata = "</Folder>\r\n	</Document>\r\n</kml>";
        fwrite($this->fileappend_label, $this->Ldata);
        fclose($this->fileappend_label);

        verbosed($GLOBALS['COLORS']['YELLOW']."Preparing Buffer for Full DB KML", $this->verbose, "CLI");
        if($this->verbose){echo"\n";}
    }
####################
    function gen_kml_place($search, $skip, $fileappend, $fileappend_label, $mem_file)
    {
        require_once              "config.inc.php";
        require_once              $GLOBALS['wdb_install']."/lib/config.inc.php";
        $this->conn           =   new mysqli($GLOBALS['host'], $GLOBALS['db_user'], $GLOBALS['db_pwd']);
        $this->db_st          =   $GLOBALS['db_st'];
        $this->db             =   $GLOBALS['db'];
        $this->wtable         =   $GLOBALS['wtable'];
        $this->gps_ext        =   $GLOBALS['gps_ext'];
        $this->root           =   $GLOBALS['root'];
        $this->sep            =   $GLOBALS['sep'];
        $this->hosturl        =   $GLOBALS['hosturl'];
        $this->open_loc       =   $GLOBALS['open_loc'];
        $this->WEP_loc        =   $GLOBALS['WEP_loc'];
        $this->WPA_loc        =   $GLOBALS['WPA_loc'];
        $this->KML_SOURCE_URL =   $GLOBALS['KML_SOURCE_URL'];
        $this->fileappend     =   $fileappend;
        $this->fileappend_label     =   $fileappend_label;
        $this->database       =   new database();
        $this->NN             =   0;
        $this->data           =   '';
        $this->Ldata          =   '';
        $this->c_row          =   1;
        switch($search)
        {
            case "1":
                $this->data    =   "<Folder>\r\n<name>Open Access Points</name>\r\n";
                break;
            case "2":
                $this->data    =   "<Folder>\r\n<name>WEP Access Points</name>\r\n";
                break;
            case "3":
                $this->data    =   "<Folder>\r\n<name>Secure Access Points</name>\r\n";
                break;
        }
        echo $search." - ".$this->data."\r\n";
        fwrite($this->fileappend, $this->data);
        fwrite($this->fileappend_label, $this->data);

        $this->sql = "SELECT * FROM `$this->db`.`$this->wtable` where `sectype`='$search'";
        $this->result = $this->conn->query($this->sql);

        $this->rows = $this->result->num_rows;

        fwrite($fileappend, "<description>APs: ".$this->rows."</description>\r\n");
        fwrite($fileappend_label, "<description>APs: ".$this->rows."</description>\r\n");

        while($this->ap_array = $this->result->fetch_array(1))
        {
            gc_collect_cycles();
            $real_mem = ((memory_get_usage(1)/1024)/1024);
            $non_real_mem = ((memory_get_usage(0)/1024)/1024);
            echo "\r\n".$real_mem."M\r\n";
            echo $non_real_mem."M\r\n";
            file_put_contents($mem_file, date("Y-m-d:G.i.s")."|$real_mem|$non_real_mem\r\n", FILE_APPEND);

            echo $this->sql."\r\n";
            echo $this->rows."\r\n";
            echo $this->c_row."\r\n";
            $this->c_row++;
            
            if(in_array($this->ap_array['id'], $skip)){continue;}
            
            $this->man        =   $this->database->manufactures($this->ap_array['mac']);
            $this->id         =   $this->ap_array['id'];
            list($this->ssid) =   make_ssid($this->ap_array['ssid']);
            $this->ssid_kml   =   preg_replace('/[\x00-\x1F]/', '', htmlentities($this->ssid, ENT_QUOTES));
            $this->mac        =   $this->ap_array['mac'];
            $this->sectype    =   $this->ap_array['sectype'];
            $this->radio      =   $this->ap_array['radio'];
            $this->chan       =   $this->ap_array['chan'];
            $this->auth       =   $this->ap_array['auth'];
            $this->encry      =   $this->ap_array['encry'];

#            $this->table      =   $this->ssid.$this->sep.$this->mac.$this->sep.$this->sectype.$this->sep.$this->radio.$this->sep.$this->chan;
#            $this->table_gps  =   $this->table.$this->gps_ext;

            #echo $id."\r\n".$table."\r\n";

#            $this->sql1       =     "SELECT * FROM `$this->db_st`.`$this->table` order by `id` desc limit 1";
#            $this->result1    =     $this->conn->query($this->sql1);
#            $this->newArray   =     $this->result1->fetch_array(1);

#            echo $this->sectype."\r\n";

            switch($this->sectype)
            {
                case 1:
                    $this->type     =   "#openStyleDead";
                    break;
                case 2:
                    $this->type     =   "#wepStyleDead";
                    break;
                case 3:
                    $this->type     =   "#secureStyleDead";
                    break;
            }
            switch($this->radio)
            {
                case "a":
                    $this->radio    =   "802.11a";
                    break;
                case "b":
                    $this->radio    =   "802.11b";
                    break;
                case "g":
                    $this->radio    =   "802.11g";
                    break;
                case "n":
                    $this->radio    =   "802.11n";
                    break;
                default:
                    $this->radio    =   "Unknown Radio";
                    break;
            }

#            $this->otx      =   $this->newArray["otx"];
#            $this->btx      =   $this->newArray["btx"];
#            $this->nt       =   $this->newArray['nt'];
#            $this->label    =   $this->newArray['label'];
#            $this->sql1     =   "SELECT * FROM `$this->db_st`.`$this->table_gps` WHERE `lat` != 'N 0.0000' ORDER BY `date` desc limit 1";
#            $this->result1->free();

#            if(!$this->result1 = $this->conn->query($this->sql1))
#            {echo $this->sql_1."\r\n";continue;}
            
#            $this->gps_table_first  =   $this->result1->fetch_array(1);
            $this->lat_exp      =   explode(" ", $this->ap_array['lat']);
            echo $this->ap_array['lat']."\r\n";
            if(isset($this->lat_exp[1]))
            {
                $this->test     =   $this->lat_exp[1]+0;
            }else
            {
                $this->test     =   $this->lat_exp[0]+0;
            }
            
            if($this->test == "0"){continue;}
            
            #$this->date_first   =   $this->gps_table_first["date"];
            #$this->time_first   =   $this->gps_table_first["time"];
            #$this->fa           =   $this->date_first." ".$this->time_first;
            #$this->alt          =   $this->gps_table_first['alt'];
            echo "------------------------\r\n".$this->ap_array['lat']." - ".$this->ap_array['long']." ($this->id)\r\n";
            $this->lat          =&  $this->database->convert_dm_dd($this->ap_array['lat']);
            $this->long         =&  $this->database->convert_dm_dd($this->ap_array['long']);
            
            #echo "DD->DM Test:\r\n";
            #$database->convert_dd_dm($lat);
            #$database->convert_dd_dm($long);
            echo "------------------------\r\n";
            if($this->lat == -1)
            {
                echo $this->table."\r\n";
                echo $this->id;
                $this->date = date("Y-m-d:G.i.s");
                file_put_contents("kml_export_errors.txt", "($this->date)".$this->table."----".$this->id."\r\n", FILE_APPEND);
                continue;
                #die("HEY YOU TOLD ME TO DIE!");
            }
            $this->NN++;
            //=====================================================================================================//
            #$this->result1->free();
            #$this->sql1             =   "SELECT * FROM `$this->db_st`.`$this->table_gps` order by `id` desc limit 1";
            #$this->result1          =   $this->conn->query($this->sql1);
            #$this->gps_table_last   =   $this->result1->fetch_array(1);
            #$this->date_last        =   $this->gps_table_last["date"];
            #$this->time_last        =   $this->gps_table_last["time"];
            #$this->la               =   $this->date_last." ".$this->time_last;
            
            fwrite($fileappend, "<Placemark id=\"".$this->mac."\">\r\n<description><![CDATA[<b>SSID: </b>".$this->ssid_kml."<br /><b>Mac Address: </b>".$this->mac."<br /><b>Network Type: </b>".$this->nt."<br /><b>Radio Type: </b>".$this->radio."<br /><b>Channel: </b>".$this->chan."<br /><b>Authentication: </b>".$this->auth."<br /><b>Encryption: </b>".$this->encry."<br /><b>Basic Transfer Rates: </b>".$this->btx."<br /><b>Other Transfer Rates: </b>".$this->otx."<br /><b>First Active: </b>".$this->fa."<br /><b>Last Updated: </b>".$this->la."<br /><b>Latitude: </b>".$this->lat."<br /><b>Longitude: </b>".$this->long."<br /><b>Manufacturer: </b>".$this->man."<br /><a href=\"".$this->hosturl."/".$this->root."/opt/fetch.php?id=".$this->id."\">WiFiDB Link</a>]]></description>\r\n	<styleUrl>".$this->type."</styleUrl>\r\n<Point id=\"".$this->mac."_GPS\">\r\n<coordinates>".$this->long.",".$this->lat.",".$this->alt."</coordinates>\r\n</Point>\r\n</Placemark>\r\n");
            fwrite($fileappend_label, "<Placemark id=\"".$this->mac."_Label\">\r\n<name>".$this->ssid_kml."</name>\r\n<description><![CDATA[<b>SSID: </b>".$this->ssid_kml."<br /><b>Mac Address: </b>".$this->mac."<br /><b>Network Type: </b>".$this->nt."<br /><b>Radio Type: </b>".$this->radio."<br /><b>Channel: </b>".$this->ap_array['chan']."<br /><b>Authentication: </b>".$this->auth."<br /><b>Encryption: </b>".$this->encry."<br /><b>Basic Transfer Rates: </b>".$this->btx."<br /><b>Other Transfer Rates: </b>".$this->otx."<br /><b>First Active: </b>".$this->fa."<br /><b>Last Updated: </b>".$this->la."<br /><b>Latitude: </b>".$this->lat."<br /><b>Longitude: </b>".$this->long."<br /><b>Manufacturer: </b>".$this->man."<br /><a href=\"".$this->hosturl."/".$this->root."/opt/fetch.php?id=".$this->id."\">WiFiDB Link</a>]]></description>\r\n<styleUrl>".$this->type."</styleUrl>\r\n<Point id=\"".$this->mac."_label\">\r\n<coordinates>".$this->long.",".$this->lat.",".$this->alt."</coordinates>\r\n</Point>\r\n</Placemark>\r\n");
            
            unset($this->data);
            unset($this->ap_array);
            unset($this->ldata);
            unset($this->lat);
            unset($this->long);
            unset($this->gps_table_first);
            unset($this->result1);
            unset($this->newArray);
            unset($this->lat_exp);
            if($GLOBALS['verbose'])
            {
                echo ".";
            }
        }
        fwrite($fileappend, "</Folder>\r\n");
        fwrite($fileappend_label, "</Folder>\r\n");
        
        return 1;
    }
####################
    function daemon_daily_db_exp($temp_daily_kml=NULL, $temp_dailyL_kml=NULL, $verbose = 0)
    {
            require_once "config.inc.php";
            require_once $GLOBALS['wdb_install']."/lib/config.inc.php";

            $date = date('Y-m-d');
            $db_st = $GLOBALS['db_st'];
            $db = $GLOBALS['db'];
            $conn = $GLOBALS['conn'];
            $wtable = $GLOBALS['wtable'];
            $users_t = $GLOBALS['users_t'];
            $gps_ext = $GLOBALS['gps_ext'];
            $root = $GLOBALS['root'];
            $hosturl = $GLOBALS['hosturl'];
            $open_loc 	=	$GLOBALS['open_loc'];
            $WEP_loc 	=	$GLOBALS['WEP_loc'];
            $WPA_loc 	=	$GLOBALS['WPA_loc'];
            $KML_SOURCE_URL	=	$GLOBALS['KML_SOURCE_URL'];

            $database	=	new database();

#		echo "Daily KML File: ".$temp_daily_kml."\n";
            $filewrite = fopen($temp_daily_kml, "w");
            $fileappend_daily = fopen($temp_daily_kml, "a");
            $filewrite_L = fopen($temp_dailyL_kml, "w");
            $fileappend_daily_label = fopen($temp_dailyL_kml, "a");

            $x=0;
            $n=0;
            $NN=0;
            $APs = array();
            # prepare the AP array so there are no duplicates
            verbosed($GLOBALS['COLORS']['YELLOW']."Preparing Buffer for Daily KML.", $verbose, "CLI");
#		echo $date."\n";
            $sql = "SELECT `user_row` FROM `$db`.`files` WHERE `date` LIKE '$date%'";
#		echo $sql."\n";
            $result = mysql_query($sql, $conn) or die(mysql_error($conn));
            while($user_rows = mysql_fetch_array($result))
            {
                    $id = $user_rows['user_row'];
                    $sql11 = "SELECT `points` FROM `$db`.`$users_t` WHERE `id` = '$id'";
    #		echo $sql11."\n";
                    $points_result = mysql_query($sql11, $conn) or die(mysql_error($conn));
                    $points = mysql_fetch_array($points_result);
                    #  1,40763:6-1,40763:6
                    $points_exp = explode("-", $points['points']);

                    #  1,40763:6
                    foreach($points_exp as $point)
                    {
                            if($point == ""){continue;}
                            #  1   40763:6
                    #	echo $point." - ";
                            $point_exp = explode(",",$point);
                            $points_exp = explode(":", $point_exp[1]);
                            $APs[] = $points_exp[0];
    #			echo $points_exp[0]."\n";
                    }
            }
            $APs = array_unique($APs);
            $Odata = '';
            $Wdata = '';
            $Sdata = '';
            $OLdata = '';
            $WLdata = '';
            $SLdata = '';
            verbosed("Starting to gather data for Daily KML.", $verbose, "CLI");
            foreach($APs as $ap)
            {
#	echo "\n\n".$ap."\n";
                    $sql0 = "SELECT * FROM `$db`.`$wtable` WHERE `id` = '$ap'";
                    $result0 = mysql_query($sql0, $conn) or die(mysql_error($conn));
                    while($ap_array = mysql_fetch_array($result0))
                    {
                            $man 		= $database->manufactures($ap_array['mac']);
                            $id			= $ap_array['id'];
                            $ssid_ptb_ = $ap_array['ssid'];
                            $ssids_ptb = str_split($ssid_ptb_,25);
                            $ssid = smart_quotes($ssids_ptb[0]);
                            $ssid_kml = preg_replace('/[\x00-\x1F]/', '', htmlentities($ssid, ENT_QUOTES));
                            $mac		= $ap_array['mac'];
                            $sectype	= $ap_array['sectype'];
                            $radio		= $ap_array['radio'];
                            $chan		= $ap_array['chan'];
                            $table = $ssid.'-'.$mac.'-'.$sectype.'-'.$radio.'-'.$chan;
                            $table_gps = $table.$gps_ext;
                            $sql1 = "SELECT * FROM `$db_st`.`$table`";
                            $result1 = mysql_query($sql1, $conn);
                            if(!$result1){continue;}
                            $rows = mysql_num_rows($result1);
                            $sql = "SELECT * FROM `$db_st`.`$table` WHERE `id`='$rows'";
                            $result1 = mysql_query($sql, $conn);
                            $newArray = mysql_fetch_array($result1);
                            switch($sectype)
                            {
                                    case 1:
                                            $type = "#openStyleDead";
                                            $auth = "Open";
                                            $encry = "None";
                                            break;
                                    case 2:
                                            $type = "#wepStyleDead";
                                            $auth = "Open";
                                            $encry = "WEP";
                                            break;
                                    case 3:
                                            $type = "#secureStyleDead";
                                            $auth = "WPA-Personal";
                                            $encry = "TKIP-PSK";
                                            break;
                            }
#	echo $type."\n";
                            switch($radio)
                            {
                                    case "a":
                                            $radio="802.11a";
                                            break;
                                    case "b":
                                            $radio="802.11b";
                                            break;
                                    case "g":
                                            $radio="802.11g";
                                            break;
                                    case "n":
                                            $radio="802.11n";
                                            break;
                                    default:
                                            $radio="Unknown Radio";
                                            break;
                            }

                            $otx = $newArray["otx"];
                            $btx = $newArray["btx"];
                            $nt = $newArray['nt'];
                            $label = $newArray['label'];

                            $sql6 = "SELECT * FROM `$db_st`.`$table_gps`";
                            $result6 = mysql_query($sql6, $conn);
                            $max = mysql_num_rows($result6);

                            $sql_1 = "SELECT * FROM `$db_st`.`$table_gps`";
                            $result_1 = mysql_query($sql_1, $conn);
                            $zero = 0;
#	echo $type."\n";
                            $rows_GPS = mysql_num_rows($result_1);
                            if($rows_GPS != 0)
                            {
                                    while($gps_table_first = mysql_fetch_array($result_1))
                                    {
                                            $lat_exp = explode(" ", $gps_table_first['lat']);
                                            if(@$lat_exp[1])
                                            {
                                                    $test = $lat_exp[1]+0;
                                            }else
                                            {
                                                    $test = $gps_table_first['lat']+0;
                                            }
                                            if($test != TRUE)
                                            {
                                                    $zero = 1;
                                                    continue;
                                            }
    #					echo $test."\n";
                                            $date_first = $gps_table_first["date"];
                                            $time_first = $gps_table_first["time"];
                                            $fa   = $date_first." ".$time_first;
                                            $alt  = $gps_table_first['alt'];

                                            $lat  =& $database->convert_dm_dd($gps_table_first['lat']);
                                            $long =& $database->convert_dm_dd($gps_table_first['long']);
                                            $zero = 0;
                                            break;
                                    }
            #			echo "GPS Value of Zero Flag: ".$zero."\n";
                            }else
                            {
                                    continue;
                            }
                            if($zero == 1)
                            {
                                    continue;
                            }
                            $NN++;
                            //=====================================================================================================//
                            $sql_2 = "SELECT * FROM `$db_st`.`$table_gps` WHERE `id`='$max'";
                            $result_2 = mysql_query($sql_2, $conn);
                            $gps_table_last = mysql_fetch_array($result_2);
                            $date_last = $gps_table_last["date"];
                            $time_last = $gps_table_last["time"];
                            $la = $date_last." ".$time_last;

                            switch($type)
                            {
                                    case "#openStyleDead":
                                            $Odata .= "<Placemark id=\"".$mac."\">\r\n<description><![CDATA[<b>SSID: </b>".$ssid_kml."<br /><b>Mac Address: </b>".$mac."<br /><b>Network Type: </b>".$nt."<br /><b>Radio Type: </b>".$radio."<br /><b>Channel: </b>".$ap_array['chan']."<br /><b>Authentication: </b>".$auth."<br /><b>Encryption: </b>".$encry."<br /><b>Basic Transfer Rates: </b>".$btx."<br /><b>Other Transfer Rates: </b>".$otx."<br /><b>First Active: </b>".$fa."<br /><b>Last Updated: </b>".$la."<br /><b>Latitude: </b>".$lat."<br /><b>Longitude: </b>".$long."<br /><b>Manufacturer: </b>".$man."<br /><a href=\"".$hosturl."/".$root."/opt/fetch.php?id=".$id."\">WiFiDB Link</a>]]></description>\r\n	<styleUrl>".$type."</styleUrl>\r\n<Point id=\"".$mac."_GPS\">\r\n<coordinates>".$long.",".$lat.",".$alt."</coordinates>\r\n</Point>\r\n</Placemark>\r\n";
                                            $OLdata .= "<Placemark id=\"".$mac."_Label\">\r\n	<name>".$ssid_kml."</name>\r\n	<description><![CDATA[<b>SSID: </b>".$ssid_kml."<br /><b>Mac Address: </b>".$mac."<br /><b>Network Type: </b>".$nt."<br /><b>Radio Type: </b>".$radio."<br /><b>Channel: </b>".$ap_array['chan']."<br /><b>Authentication: </b>".$auth."<br /><b>Encryption: </b>".$encry."<br /><b>Basic Transfer Rates: </b>".$btx."<br /><b>Other Transfer Rates: </b>".$otx."<br /><b>First Active: </b>".$fa."<br /><b>Last Updated: </b>".$la."<br /><b>Latitude: </b>".$lat."<br /><b>Longitude: </b>".$long."<br /><b>Manufacturer: </b>".$man."<br /><a href=\"".$hosturl."/".$root."/opt/fetch.php?id=".$id."\">WiFiDB Link</a>]]></description>\r\n<styleUrl>".$type."</styleUrl>\r\n<Point id=\"".$mac."_label\">\r\n<coordinates>".$long.",".$lat.",".$alt."</coordinates>\r\n</Point>\r\n</Placemark>\r\n";
                                    break;

                                    case "#wepStyleDead":
                                            $Wdata .= "<Placemark id=\"".$mac."\">\r\n<description><![CDATA[<b>SSID: </b>".$ssid_kml."<br /><b>Mac Address: </b>".$mac."<br /><b>Network Type: </b>".$nt."<br /><b>Radio Type: </b>".$radio."<br /><b>Channel: </b>".$ap_array['chan']."<br /><b>Authentication: </b>".$auth."<br /><b>Encryption: </b>".$encry."<br /><b>Basic Transfer Rates: </b>".$btx."<br /><b>Other Transfer Rates: </b>".$otx."<br /><b>First Active: </b>".$fa."<br /><b>Last Updated: </b>".$la."<br /><b>Latitude: </b>".$lat."<br /><b>Longitude: </b>".$long."<br /><b>Manufacturer: </b>".$man."<br /><a href=\"".$hosturl."/".$root."/opt/fetch.php?id=".$id."\">WiFiDB Link</a>]]></description>\r\n<styleUrl>".$type."</styleUrl>\r\n<Point id=\"".$mac."_GPS\">\r\n<coordinates>".$long.",".$lat.",".$alt."</coordinates>\r\n</Point>\r\n</Placemark>\r\n";
                                            $WLdata .= "<Placemark id=\"".$mac."_Label\">\r\n	<name>".$ssid_kml."</name>\r\n	<description><![CDATA[<b>SSID: </b>".$ssid_kml."<br /><b>Mac Address: </b>".$mac."<br /><b>Network Type: </b>".$nt."<br /><b>Radio Type: </b>".$radio."<br /><b>Channel: </b>".$ap_array['chan']."<br /><b>Authentication: </b>".$auth."<br /><b>Encryption: </b>".$encry."<br /><b>Basic Transfer Rates: </b>".$btx."<br /><b>Other Transfer Rates: </b>".$otx."<br /><b>First Active: </b>".$fa."<br /><b>Last Updated: </b>".$la."<br /><b>Latitude: </b>".$lat."<br /><b>Longitude: </b>".$long."<br /><b>Manufacturer: </b>".$man."<br /><a href=\"".$hosturl."/".$root."/opt/fetch.php?id=".$id."\">WiFiDB Link</a>]]></description>\r\n<styleUrl>".$type."</styleUrl>\r\n<Point id=\"".$mac."_label\">\r\n<coordinates>".$long.",".$lat.",".$alt."</coordinates>\r\n</Point>\r\n</Placemark>\r\n";
                                    break;

                                    case "#secureStyleDead":
                                            $Sdata .= "<Placemark id=\"".$mac."\">\r\n<description><![CDATA[<b>SSID: </b>".$ssid_kml."<br /><b>Mac Address: </b>".$mac."<br /><b>Network Type: </b>".$nt."<br /><b>Radio Type: </b>".$radio."<br /><b>Channel: </b>".$ap_array['chan']."<br /><b>Authentication: </b>".$auth."<br /><b>Encryption: </b>".$encry."<br /><b>Basic Transfer Rates: </b>".$btx."<br /><b>Other Transfer Rates: </b>".$otx."<br /><b>First Active: </b>".$fa."<br /><b>Last Updated: </b>".$la."<br /><b>Latitude: </b>".$lat."<br /><b>Longitude: </b>".$long."<br /><b>Manufacturer: </b>".$man."<br /><a href=\"".$hosturl."/".$root."/opt/fetch.php?id=".$id."\">WiFiDB Link</a>]]></description>\r\n	<styleUrl>".$type."</styleUrl>\r\n<Point id=\"".$mac."_GPS\">\r\n<coordinates>".$long.",".$lat.",".$alt."</coordinates>\r\n</Point>\r\n</Placemark>\r\n";
                                            $SLdata .= "<Placemark id=\"".$mac."_Label\">\r\n<name>".$ssid_kml."</name>\r\n	<description><![CDATA[<b>SSID: </b>".$ssid_kml."<br /><b>Mac Address: </b>".$mac."<br /><b>Network Type: </b>".$nt."<br /><b>Radio Type: </b>".$radio."<br /><b>Channel: </b>".$ap_array['chan']."<br /><b>Authentication: </b>".$auth."<br /><b>Encryption: </b>".$encry."<br /><b>Basic Transfer Rates: </b>".$btx."<br /><b>Other Transfer Rates: </b>".$otx."<br /><b>First Active: </b>".$fa."<br /><b>Last Updated: </b>".$la."<br /><b>Latitude: </b>".$lat."<br /><b>Longitude: </b>".$long."<br /><b>Manufacturer: </b>".$man."<br /><a href=\"".$hosturl."/".$root."/opt/fetch.php?id=".$id."\">WiFiDB Link</a>]]></description>\r\n<styleUrl>".$type."</styleUrl>\r\n<Point id=\"".$mac."_label\">\r\n<coordinates>".$long.",".$lat.",".$alt."</coordinates>\r\n</Point>\r\n</Placemark>\r\n";
                                    break;
                            }
                            unset($lat);
                            unset($long);
                            unset($gps_table_first["lat"]);
                            unset($gps_table_first["long"]);
                    }
                    if($verbose){echo".";}
            }
            if($verbose){echo"\n";}
            verbosed("Finished Preparing buffer for Daily KML.".$GLOBALS['COLORS']['LIGHTGRAY'], $verbose, "CLI");

            $Ddata  =  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n<kml xmlns=\"$KML_SOURCE_URL\"><!--exp_all_db_kml-->\r\n<Document>\r\n<name>RanInt WifiDB KML</name>\r\n";
            $Ddata .= "<Style id=\"openStyleDead\">\r\n<IconStyle>\r\n<scale>0.5</scale>\r\n<Icon>\r\n<href>".$open_loc."</href>\r\n</Icon>\r\n</IconStyle>\r\n	</Style>\r\n";
            $Ddata .= "<Style id=\"wepStyleDead\">\r\n<IconStyle>\r\n<scale>0.5</scale>\r\n<Icon>\r\n<href>".$WEP_loc."</href>\r\n</Icon>\r\n</IconStyle>\r\n</Style>\r\n";
            $Ddata .= "<Style id=\"secureStyleDead\">\r\n<IconStyle>\r\n<scale>0.5</scale>\r\n<Icon>\r\n<href>".$WPA_loc."</href>\r\n</Icon>\r\n</IconStyle>\r\n</Style>\r\n";
            $Ddata .= '<Style id="Location"><LineStyle><color>7f0000ff</color><width>4</width></LineStyle></Style>';
            $Ddata .= "<Folder>\r\n<name>WiFiDB Access Points</name>\r\n<description>APs: ".$NN."</description>\r\n";
            $Ddata .= "<Folder>\r\n<name>Open Access Points</name>\r\n".$Odata."</Folder>\r\n";
            $Ddata .= "<Folder>\r\n<name>WEP Access Points</name>\r\n".$Wdata."</Folder>\r\n";
            $Ddata .= "<Folder>\r\n<name>Secure Access Points</name>\r\n".$Sdata."</Folder>\r\n";
            $Ddata = $Ddata."</Folder>\r\n	</Document>\r\n</kml>";
            #	write temp KML file to TMP folder
            fwrite($fileappend_daily, $Ddata);
            fclose($fileappend_daily);

            $DLdata  =  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n<kml xmlns=\"$KML_SOURCE_URL\"><!--exp_all_db_kml-->\r\n<Document>\r\n<name>RanInt WifiDB KML</name>\r\n";
            $DLdata .= "<Style id=\"openStyleDead\">\r\n<IconStyle>\r\n<scale>0.5</scale>\r\n<Icon>\r\n<href>".$open_loc."</href>\r\n</Icon>\r\n</IconStyle>\r\n	</Style>\r\n";
            $DLdata .= "<Style id=\"wepStyleDead\">\r\n<IconStyle>\r\n<scale>0.5</scale>\r\n<Icon>\r\n<href>".$WEP_loc."</href>\r\n</Icon>\r\n</IconStyle>\r\n</Style>\r\n";
            $DLdata .= "<Style id=\"secureStyleDead\">\r\n<IconStyle>\r\n<scale>0.5</scale>\r\n<Icon>\r\n<href>".$WPA_loc."</href>\r\n</Icon>\r\n</IconStyle>\r\n</Style>\r\n";
            $DLdata .= '<Style id="Location"><LineStyle><color>7f0000ff</color><width>4</width></LineStyle></Style>';
            $DLdata .= "<Folder>\r\n<name>WiFiDB Access Points</name>\r\n<description>APs: ".$NN."</description>\r\n";
            $DLdata .= "<Folder>\r\n<name>Open Access Points</name>\r\n".$OLdata."</Folder>\r\n";
            $DLdata .= "<Folder>\r\n<name>WEP Access Points</name>\r\n".$WLdata."</Folder>\r\n";
            $DLdata .= "<Folder>\r\n<name>Secure Access Points</name>\r\n".$SLdata."</Folder>\r\n";
            $DLdata = $DLdata."</Folder>\r\n	</Document>\r\n</kml>";
            #	write temp KML file to TMP folder
            fwrite($fileappend_daily_label, $DLdata);
            fclose($fileappend_daily_label);
    }
####################
    function getdaemonstats( $daemon_pid = NULL, $verbose = 1 )
    {
        if($daemon_pid == NULL )return -1;
        #
        $return =0;
        $WFDBD_PID = $GLOBALS['pid_file_loc'].$daemon_pid; // dbstatsd.pid | imp_expd.pid | daemonperfd.pid
        $os = PHP_OS;
        if ( $os[0] == 'L')
        {
            $output = array();
            if(file_exists($WFDBD_PID))
            {
                $pid_open = file($WFDBD_PID);
        #	echo $pid_open[0]."<br>";
                exec('ps vp '.$pid_open[0] , $output, $sta);
                if(isset($output[1]))
                {
                    if($verbose){
                    $start = trim($output[1], " ");
                    preg_match_all("/(\d+?)(\.)(\d+?)/", $start, $match);
                    $mem = $match[0][0];

                    preg_match_all("/(php.*)/", $start, $matc);
                    $CMD = $matc[0][0];

                    preg_match_all("/(\d+)(\:)(\d+)/", $start, $mat);
                    $time = $mat[0][0];

                    $patterns[1] = '/  /';
                    $patterns[2] = '/ /';
                    $ps_stats = preg_replace($patterns , "|" , $start);
                    $ps_Sta_exp = explode("|", $ps_stats);
                    $return = 1;
                    ?>
                    <tr class="style4">
                            <th>PID</th>
                            <th>TIME</th>
                            <th>Memory</th>
                            <th>CMD</th>
                    </tr>
                    <tr align="center" bgcolor="green">
                            <td><?php echo str_replace(' ?',"",$ps_Sta_exp[0]);?></td>
                            <td><?php echo $time;?></td>
                            <td><?php echo $mem."%";?></td>
                            <td><?php echo $CMD;?></td>
                    </tr>
                    <?php
                    }
                    return 1;
                }else
                {
                    if($verbose){ ?><tr align="center" bgcolor="red"><td colspan="4">Linux Based Import / Export Daemon is not running!</td><?php }
                    return 0;
                }
            }else
            {
                if($verbose){ ?><tr align="center" bgcolor="red"><td colspan="4">Linux Based Import / Export Daemon is not running!</td><?php }
                return 0;
            }
        }elseif( $os[0] == 'W')
        {
            $output = array();
            if(file_exists($WFDBD_PID))
            {
                $pid_open = file($WFDBD_PID);
                exec('tasklist /V /FI "PID eq '.$pid_open[0].'" /FO CSV' , $output, $sta);
                if(isset($output[2]))
                {
                    if($verbose){
                    ?><tr class="style4"><th colspan="4">Windows Based Import / Export Daemon</th></tr><tr><th>Proc</th><th>PID</th><th>Memory</th><th>CPU Time</th></tr><?php
                    $ps_stats = explode("," , $output[2]);
                    ?><tr align="center" bgcolor="green"><td><?php echo str_replace('"',"",$ps_stats[0]);?></td><td><?php echo str_replace('"',"",$ps_stats[1]);?></td><td><?php echo str_replace('"',"",$ps_stats[4]).','.str_replace('"',"",$ps_stats[5]);?></td><td><?php echo str_replace('"',"",$ps_stats[8]);?></td></tr><?php
                    }
                    return 1;
                }else
                {
                    if($verbose){
                    ?><tr class="style4"><th colspan="4">Windows Based Import / Export Daemon</th></tr>
                    <tr align="center" bgcolor="red"><td colspan="4">Windows Based Import / Export Daemon is not running!</td><?php
                    }
                    return 0;
                }
            }else
            {
                if($verbose){
                ?><tr class="style4"><th colspan="4">Windows Based Import / Export Daemon</th></tr>
                <tr align="center" bgcolor="red"><td colspan="4">Windows Based Import / Export Daemon is not running!</td><?php
                }
                return 0;
            }
        }else
        {
            if($verbose){
            ?><tr class="style4"><th colspan="4">Unkown OS Based Import / Export Daemon</th></tr>
            <tr align="center" bgcolor="red"><td colspan="4">Unkown OS Based Import / Export Daemon is not running!</td><?php
            }
            return 0;
        }
    }
#END DAEMON CLASS
}
?>