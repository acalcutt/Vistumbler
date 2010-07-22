<?php
if(!(require_once 'config.inc.php')){die("You need to create and configure your config.inc.php file in the [tools dir]/daemon/config.inc.php");}
if($GLOBALS['wifidb_install'] == ""){die("You need to edit your daemon config file first in: [tools dir]/daemon/config.inc.php");}
require_once $GLOBALS['wifidb_install']."/lib/config.inc.php";

$conn	= 	$GLOBALS['conn'];
$server_settings['db']	= 	$GLOBALS['db'];
$server_settings['db_st']	= 	$GLOBALS['db_st'];
$server_settings['wtable']	=	$GLOBALS['wtable'];
$server_settings['users_t']	=	$GLOBALS['users_t'];
$server_settings['gps_ext']	=	$GLOBALS['gps_ext'];
$server_settings['files']	=	$GLOBALS['files'];
$server_settings['files_tmp']	=	$GLOBALS['files_tmp'];
$server_settings['login_t']	=	$GLOBALS['user_logins_table'];
$server_settings['seed']	= 	$GLOBALS['login_seed'];
// Set the ip and port we will listen on
$ips = getIPs();
$address = $ips[0];
$port = 9000;
$max_clients = 2;
echo "Starting the WiFiDB API Daemon on [".$ips[0].":".$port."]\r\nMax Clients configured for: ".$max_clients."\r\n";
// Array that will hold client information
$client = Array();

// Create a TCP Stream socket
$sock = socket_create(AF_INET, SOCK_STREAM, 0);
// Bind the socket to an address/port
socket_bind($sock, $address, $port) or die('Could not bind to address');
// Start listening for connections
socket_listen($sock);

// Loop continuously
while (true) {
    // Setup clients listen socket for reading
#	echo ".";
	$read[0] = $sock;
	for ($i = 0; $i < $max_clients; $i++)
	{
		if ($client[$i]['sock']  != null)
		$read[$i + 1] = $client[$i]['sock'] ;
	}
	// Set up a blocking call to socket_select()
	$ready = @socket_select($read, $w, $e, 0);
	/* if a new connection is being made add it to the client array */
	if (in_array($sock, $read)) {
		for ($i = 0; $i < $max_clients; $i++)
		{
			if ($client[$i]['sock'] == null) {
				$client[$i]['sock'] = socket_accept($sock);
				echo "Accepted socket.\r\n";
				break;
			}
			elseif ($i == $max_clients - 1)
			{
				#print ("too many clients");
			}
		}
		if ($ready > 0)
		#	echo $ready."\r\n";
			continue;
	} // end if in_array
	// If a client is trying to write - handle it now
	for ($i = 0; $i < $max_clients; $i++) // for each client
	{
		if (in_array($client[$i]['sock'] , $read))
		{
			$input = trim(socket_read($client[$i]['sock'] , 1024));
			if ($input == null) {
				// Zero length string meaning disconnected
				unset($client[$i]);
			}
			if ($input == 'EXIT') {
				// requested disconnect
				socket_close($client[$i]['sock']);
				echo "Closed connection to: ".$client[$i]['sock']."\r\n";
				unset($client[$i]);
			}
			$input = explode("|", $input);
			switch ($input[0])
			{
				case "IP":
					// strip white spaces and write back to user
					echo $input[1]."\r\nGet me your IP...";
					socket_write($client[$i]['sock'], "GET_U_IP|", strlen("GET_U_IP|"));
				break;

				case "IPADDR":
					$client[$i]['ip_addr'] = $input[1];
					echo $client[$i]['ip_addr']."\r\n";
					$messg = "OK|Logged IP...";
					socket_write($client[$i]['sock'], $messg, strlen($messg));
				break;
				
				case "LOCATE":
					$locate = locate($n[1]);
					switch($locate[0])
					{
						case 1:
							$messg = "LOCATE|".$locate[1];
							socket_write($client[$i]['sock'], $messg, strlen($messg));
							echo "Locate AP GPS command successful (".$client[$i]['ip_addr'].").\r\n";
						break;
						case 0:
							$messg = "LOCATE|Empty";
							socket_write($client[$i]['sock'], $messg, strlen($messg));
							echo "Locate AP GPS command failed, no data in database (".$client[$i]['ip_addr'].").\r\n";
						break;
						case -1:
							$messg = "LOCATE|Error";
							socket_write($client[$i]['sock'], $messg, strlen($messg));
							echo "Locate AP GPS command failed (".$client[$i]['ip_addr'].").\r\n".$messg;
						break;
					}
				break;
				
				case "LOGIN":
					$client[$i]['wdb_user'] = $input[1];
					echo "User attemting login from (".$client[$i]['ip_addr']."): ".$client[$i]['wdb_user']."\r\n";
					#ask for password
					$messg = "PWD|".$server_settings['seed'];
					socket_write($client[$i]['sock'], $messg, strlen($messg));
					echo "Asked ".$input[1]." for their password.\r\n";
				break;
				case "PWD":
					echo $client[$i]['wdb_user']." sent password.\r\n";
					$sql = "select * from `".$server_settings['db']."`.`".$server_settings['login_t']."` WHERE `username` LIKE '".$client[$i]['wdb_user']."'";
					$result = mysql_query($sql, $conn);
					$array = mysql_fetch_array($result);
					if($array['login_fails'] == $GLOBALS['config_fails'] or $array['locked'] == 1)
					{
						echo $client[$i]['wdb_user'].' is locked\r\n';
						$messg = "EXIT|Your account has been locked for too many bad login attpemts...";
						socket_write($client[$i]['sock'], $messg, strlen($messg));
						socket_close($client[$i]['sock']);
						unset($client[$i]);
						break;
					}
					if($array['validated'] == 1)
					{
						echo $client[$i]['wdb_user'].' has not validated yet.\r\n';
						$messg = "EXIT|User is not validated yet...";
						socket_write($client[$i]['sock'], $messg, strlen($messg));
						socket_close($client[$i]['sock']);
						unset($client[$i]);
						break;
					}
					
					$id = $array['id'];
					$db_pass = $array['password'];
					$fails = $array['login_fails'];
					$username_db = $array['username'];
					
				#	$pass_seed = md5($input[1].$server_settings['seed']);
					
					if($db_pass === $input[1])
					{
						$sql = "SELECT `last_active` FROM `".$server_settings['db']."`.`".$server_settings['login_t']."` WHERE `id` = '$id' LIMIT 1";
						$array = mysql_fetch_array(mysql_query($sql, $conn));
						$last_active = $array['last_active'];
						$sql = "UPDATE `".$server_settings['db']."`.`".$server_settings['login_t']."` SET `login_fails` = '0', `last_active` = '$last_active', `last_login` = '$date' WHERE `id` = '$id' LIMIT 1";
						if(mysql_query($sql, $conn))
						{
							echo $client[$i]['wdb_user']." logged in successfully.\r\n";
							$keys = md5($db_pass."PIECAVE".rand(1000,90000));
							$messg = "LOK|".$keys;
							$client[$i]['keys'] = $keys;
							socket_write($client[$i]['sock'], $messg, strlen($messg));
						}else
						{
							echo "Failed to update ".$client[$i]['wdb_user']." user row.\r\n";
						}
					}else
					{
						if($username_db != '')
						{
							$fails++;
							$to_go = $GLOBALS['config_fails'] - $fails;
					#		echo $fails.' - '.$GLOBALS['config_fails'];
							if($fails >= $GLOBALS['config_fails'])
							{
								$sql = "UPDATE `".$server_settings['db']."`.`".$server_settings['login_t']."` SET `locked` = '1' WHERE `id` = '$id' LIMIT 1";
								mysql_query($sql, $conn);
								echo $client[$i]['wdb_user']." has been locked.\r\n";
								$messg = "EXIT|Your account has been locked for too many bad login attpemts...";
								socket_write($client[$i]['sock'], $messg, strlen($messg));
								socket_close($client[$i]['sock']);
								unset($client[$i]);
							}else
							{
								$sql = "UPDATE `".$server_settings['db']."`.`".$server_settings['login_t']."` SET `login_fails` = '$fails' WHERE `id` = '$id' LIMIT 1";
								mysql_query($sql, $conn);
								echo $client[$i]['wdb_user']." failed to login, To Go: $to_go\r\n";
								$messg = "FAIL|$to_go";
								socket_write($client[$i]['sock'], $messg, strlen($messg));
							}
						}else
						{
							echo "Username was empty.. :-/\r\n";
							$messg = "BADU|The Username or password was bad, try again...";
							socket_write($client[$i]['sock'], $messg, strlen($messg));
						}
					}
				break;
			}
		}
	}
} // end while
// Close the master sockets
socket_close($sock);


function locate($list = "")
{
	$conn = $GLOBALS['conn'];
	$db = $GLOBALS['db'];
	$db_st = $GLOBALS['db_st'];
	$wtable = $GLOBALS['wtable'];
	$gps_ext = $GLOBALS['gps_ext'];
	if($list == ""){$return = array(0=>-1, 1=>"Blank list");}
	$listing = explode("-", $list);
	if(count($listing) == 0){$return = array(0=>-1, 1=>"Blank list");}
	$pre_sig = '';
	foreach($listing as $key=>$macandsig)
	{
		$mac_sig_array = explode(",",$macandsig);
		$sig = $mac_sig_array[1];
		$mac = str_replace(":" , "" , $mac_sig_array[0]);
		$result = mysql_query("SELECT * FROM `$db`.`$wtable` WHERE `mac` LIKE '$mac' LIMIT 1", $conn);
		if(!$result)
		{
			 $return = array(0=>-1, 1=>mysql_error($conn));
			 return $return;
		}
		$array = mysql_fetch_array($result);
		if($array['mac'] == '')
		{
			$nf_array[] = $mac;
			$notfound = 1;
			continue;
		}
		$ssidss = smart_quotes($array['ssid']);
		$ssidsss = str_split($ssidss,25); //split SSID in two at is 25th char.
		$ssid_S = $ssidsss[0]; //Use the 25 char long word for the APs table name, this is due to a limitation in MySQL table name lengths, 
							  //the rest of the info will suffice for unique table names
		
		$table = $ssid_S.$sep.$array['mac'].$sep.$array['sectype'].$sep.$array['radio'].$sep.$array['chan'];
		$table_gps = $ssid_S.$sep.$array['mac'].$sep.$array['sectype'].$sep.$array['radio'].$sep.$array['chan'].$gps_ext;
		
		$pre_sat	= '';
		$pre_lat	= '';
		$pre_long	= '';
		$pre_date	= '';
		
		$result_rows = mysql_query("select * from `$db_st`.`$table_gps`",$conn);
		$total_rows = mysql_num_rows($result_rows);
		
		if($total_rows < 2)
		{
			$sql1 ="select * from `$db_st`.`$table_gps`";
			$testing = "1";
		}else
		{
			$sql1 = "select * from `$db_st`.`$table_gps` ORDER BY `date` DESC";
			$testing = "2";
		}
		$result1 = mysql_query($sql1,$conn);
		if(!$result1){mysql_error($conn); continue;}
		while($array1 = mysql_fetch_array($result1))
		{
			if($array1['sats'] == 0 or $array1['sats'] <= $pre_sats){continue;}
			
			$lat_exp = explode(" ",$array1['lat']);
			$lat = $lat_exp[1];
			if($lat == "0.0000"){continue;}
			
			$long_exp = explode(" ",$array1['long']);
			$long = $long_exp[1];
			if($long == "0.0000"){continue;}
			
			if($array1['sats'] >= $pre_sat)
			{
				$use[$N] = array(
								'lat'	=> $array1['lat'],
								'long'	=> $array1['long'],
								'date'	=> $array1['date'],
								'time'	=> $array1['time'],
								'sats'	=> $array1['sats']
							);
				$sig_sort[$N] = $sig;
				$sig_id[$N]	= $N;
				$N++;
				break;
			}
			$pre_sats	= $array1['sats'];
			$pre_lat	= $array1['lat'];
			$pre_long	= $array1['long'];
			$pre_date	= $array1['date'];
			$pre_time	= $array1['time'];
		}
	}
	@array_multisort($sig_sort, $sig_id);
	$count_sig = count($sig_sort);
	$array_id = $count_sig-1;
	
	if($array_id != -1)
	{
		$return = array(0=>1, 1=> $use[$array_id]['lat'].",".$use[$array_id]['long'].",".$use[$array_id]['sats'].",".$use[$array_id]['date'].",".$use[$array_id]['time']);
	}
	if($notfound == 1)
	{
		$return = array(0=>0,1=>"\r\n+Import some aps");
	}
	return $return;
}

###################################
function getIPs($withV6 = true) {
    preg_match_all('/inet'.($withV6 ? '6?' : '').' addr: ?([^ ]+)/', `ifconfig`, $ips);
    return $ips[1];
}

?> 