<?php
global $client_seed;


function getIPs($withV6 = true) {
    preg_match_all('/inet'.($withV6 ? '6?' : '').' addr: ?([^ ]+)/', `ifconfig`, $ips);
    return $ips[1];
}




#$address = 'localhost';
$remote_address = '192.168.1.27';
$remote_port = 9000;

// Create a TCP Stream socket
$sock = socket_create(AF_INET, SOCK_STREAM, 0);

// Bind the socket to an address/port
socket_connect($sock, $remote_address, $remote_port) or die('Could not bind to address');

$read[0] = $sock;
 
$sent = socket_write($sock, "IP|Hello Server!", strlen("IP|Hello Server!"));

if($sent === false)
{
	echo "Failed to send message to server...\r\n";
}else
{
	while(true)
	{
		$input = socket_read($sock , 1024);
	    $n = trim($input);
	    $n = explode("|", $n);
	#	echo $n[0]."\r\n";
		switch($n[0])
		{
			case 'GET_U_IP':
				$ips = getIPs();
				$messg = "IP|".$ips[0];
				socket_write($sock, $messg, strlen($messg));
				echo "Sent IP, waiting for response from server...\r\n";
			break;
			
			case "not":
				echo "There was an error, exiting...";
				socket_close($sock);
				die();
			break;
			
			case "pwd":
				#ask for password
				fwrite(STDOUT, "Password :# ");
				system('stty -echo');
				$get_pwd = trim(fgets(STDIN));
				system('stty -echo');
				$client_seed = $n[1];
				$pass_seed = md5($get_pwd.$client_seed);
				$messg = "PWD|".$pass_seed;
				socket_write($sock, $messg, strlen($messg));
				echo "\r\nSent password, waiting for server...\r\n";
			break;
			case "FAIL":
				fwrite(STDOUT, "Failed to login, $n[1] more tries...\r\nPassword :# ");
				$get_pwd = trim(fgets(STDIN));
				$pass_seed = md5($get_pwd.$client_seed);
				$messg = "PWD|".$pass_seed;
				socket_write($sock, $messg, strlen($messg));
				echo "Sent password, waiting for server...\r\n";
			break;
			case "LOCK":
				fwrite(STDOUT, "Your user has been locked from too many bad login attempts.\r\nExiting...");
				socket_close($sock);
				die();
			break;
			case "exit":
				if(@$n[1] != "")
				{
					fwrite(STDOUT, $n[1]."\r\n");
				}
				socket_close($sock);
			break;
			default:
				
				if(@$n[0] != "Lok")
				{
					fwrite(STDOUT, $n[1]."\r\nWiFiDB_API:# ");
				}elseif($n[0] == "Lok")
				{
					fwrite(STDOUT, "Login Successful.\r\nWiFiDB_API:# "); 
				}else
				{
					fwrite(STDOUT, "WiFiDB_API:# ");
				}
				$get_input = trim(fgets(STDIN));
			#	echo $get_input."\r\n";
				if($get_input == "exit")
				{
					socket_write($sock, $get_input, strlen($get_input));
					socket_close($sock);
					die("closed.\r\n");
				}
				if(socket_write($sock, $get_input, strlen($get_input)))
				{
					echo "Sent message waiting for response from server...\r\n";
				}else
				{
					echo "Failed to send message: ".socket_strerror(socket_last_error())."\r\n";
				}
			break;
		}
		#echo "Sent message waiting for response from server...\r\n";
	}	
}
?>