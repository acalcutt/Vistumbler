<?php
include('../lib/database.inc.php');
pageheader("Search Results Page");
include('../lib/config.inc.php');
$theme = $GLOBALS['theme'];
?>
			<h2>Search Results</h2>
<?php
if (isset($_GET['token']))
{
	if (isset($_SESSION['token']) && $_GET['token'] == $_SESSION['token'])
	{
		$sql_a=array();

		if ($_POST['ssid'] == "%" or $_POST['mac'] == "%" or $_POST['radio'] == "%" or $_POST['chan'] == "%" or $_POST['auth'] == "%" or $_POST['encry'] == "%" )
		{
			echo '<table><tr><td colspan="6" align="center">Come on man, you cant search or all of something, thats what <a class="links" href="../all.php?token='.$_SESSION["token"].'">this page</a> is for!</td></tr></table>'; 
			die(footer($_SERVER['SCRIPT_FILENAME']));
		}
		
		if(isset($_GET['func']))
		{$func = $_GET['func'];}
		else{$func = "";}
		
		if(isset($_POST['ssid']))
		{$ssid = $_POST['ssid'];}
		else{$ssid = $_GET['ssid'];}
		
		if(isset($_POST['mac']))
		{$mac = $_POST['mac'];}
		else{$mac = $_GET['mac'];}
		
		if(isset($_POST['radio']))
		{$radio = $_POST['radio'];}
		else{$radio = $_GET['radio'];}
		
		if(isset($_POST['chan']))
		{$chan = $_POST['chan'];}
		else{$chan = $_GET['chan'];}
		
		if(isset($_POST['auth']))
		{$auth = $_POST['auth'];}
		else{$auth = $_GET['auth'];}
		
		if(isset($_POST['encry']))
		{$encry = $_POST['encry'];}
		else{$encry = $_GET['encry'];}
		
		$ord   =	addslashes(strip_tags($_GET['ord']));
		$sort  =	addslashes(strip_tags($_GET['sort']));
		$from  =	addslashes(strip_tags($_GET['from']));
		$from_ =	addslashes(strip_tags($_GET['from']));
		$inc   =	addslashes(strip_tags($_GET['to']));

		$ssid = addslashes(strip_tags($ssid));
		$mac = addslashes(strip_tags($mac));
		$radio = addslashes(strip_tags($radio));
		$chan = addslashes(strip_tags($chan));
		$auth = addslashes(strip_tags($auth));
		$encry = addslashes(strip_tags($encry));

		$mac_explode = explode(':', $mac);
		$mac_co = count($mac_explode);
		if($mac_co > 1){$mac = implode('', $mac_explode);}

		if ($from==""){$from=0;}
		if ($inc==""){$inc=100;}
		if ($ord==""){$ord="ASC";}
		if ($sort==""){$sort="id";}
		$x=0;
		$n=0;
		$to=$from+$inc;
		
		$save_url = '<a title="(right click - save bookmark)" class="links" href="results.php?ord='.$ord.'&sort='.$sort.'&from='.$from.'&to='.$inc.'&';
		$export_url = '<a class="links" href="results.php?func=export&';
		$II = 0;
		
		if($ssid!='')
		{
			$save_url .= 'ssid='.$ssid.'&';
			$export_url .= 'ssid='.$ssid.'&';
			$sql_a[$II]	=	" `ssid` like '".$ssid."%' ";
			
		}
		
		if($mac!='')
		{
			$save_url .= 'mac='.$mac.'&';
			$export_url .=  'mac='.$mac.'&';
			$sql_a[$II]	=	" `mac` like '".$mac."%' ";
			$II++;
		}
		
		if($radio!='')
		{
			$save_url .= 'radio='.$radio.'&';
			$export_url .=  'radio='.$radio.'&';
			$sql_a[$II]	=	" `radio` like '".$radio."%' ";
			$II++;
		}
		
		if($chan!='')
		{
			$save_url .= 'chan='.$chan.'&';
			$export_url .=  'chan='.$chan.'&';
			$sql_a[$II]	=	" `chan` like '".$chan."%' ";
			$II++;
		}
		
		if($auth!='')
		{
			$save_url .= 'auth='.$auth.'&';
			$export_url .=  'auth='.$auth.'&';
			$sql_a[$II]	=	" `auth` like '".$auth."%' ";
			$II++;
		}
		
		if($encry!='')
		{
			$save_url .= 'encry='.$encry.'&';
			$export_url .=  'encry='.$encry.'&';
			$sql_a[$II]	=	" `encry` like '".$encry."%' ";
			$II++;
		}
		$save_url .= 'token='.$_SESSION['token'].'">Save for later</a>';		
		$export_url .=  'token='.$_SESSION['token'].'">Export to KML</a>';

		if(!$sql_a)
		{
			echo '<h2>There where no results, please try again<br><A class="links" HREF="javascript:history.go(-1)">Go back</a> and do it right!</h2>'; 
			die(footer($_SERVER['SCRIPT_FILENAME']));
		}
		if($func == "export")
		{
			database::exp_search($sql_a);
			die(footer($_SERVER['SCRIPT_FILENAME']));
		}
		
		$sql0 = "SELECT * FROM `$db`.`$wtable` WHERE " . implode(' AND ', $sql_a) ." ORDER BY $sort $ord LIMIT $from, $inc";
		$result = mysql_query($sql0, $conn) or die(mysql_error($conn));
		
		$sql00 = "SELECT * FROM `$db`.`$wtable` WHERE " . implode(' AND ', $sql_a) ." ORDER BY $sort $ord";
		$result1 = mysql_query($sql00, $conn) or die(mysql_error($conn));
		
		$total_rows = mysql_num_rows($result1);
		echo '<p align="center">Total APs found: '.$total_rows.'</p><table border="1" width="100%" cellspacing="0"><tr><td align="center" colspan="7">';
		
		echo $save_url.'<br>'.$export_url.'</td></tr>';
		
		echo '<tr class="style4"><td>ID</td><td>SSID<a href="?ssid='.$ssid.'&mac='.$mac.'&radio='.$radio.'&chan='.$chan.'&auth='.$auth.'&encry='.$encry.'&sort=SSID&ord=ASC&from='.$from.'&to='.$inc.'&token='.$_SESSION["token"].'"><img height="15" width="15" border="0"border="0" src="../themes/'.$theme.'/img/down.png"></a><a href="?ssid='.$ssid.'&mac='.$mac.'&radio='.$radio.'&chan='.$chan.'&auth='.$auth.'&encry='.$encry.'&sort=SSID&ord=DESC&from='.$from.'&to='.$inc.'&token='.$_SESSION["token"].'"><img height="15" width="15" border="0"src="../themes/'.$theme.'/img/up.png"></a></td>'
			.'<td>MAC<a href="?ssid='.$ssid.'&mac='.$mac.'&radio='.$radio.'&chan='.$chan.'&auth='.$auth.'&encry='.$encry.'&sort=mac&ord=ASC&from='.$from.'&to='.$inc.'&token='.$_SESSION["token"].'"><img height="15" width="15" border="0"src="../themes/'.$theme.'/img/down.png"></a><a href="?ssid='.$ssid.'&mac='.$mac.'&radio='.$radio.'&chan='.$chan.'&auth='.$auth.'&encry='.$encry.'&sort=mac&ord=DESC&from='.$from.'&to='.$inc.'&token='.$_SESSION["token"].'"><img height="15" width="15" border="0"src="../themes/'.$theme.'/img/up.png"></a></td>'
			.'<td>Chan<a href="?ssid='.$ssid.'&mac='.$mac.'&radio='.$radio.'&chan='.$chan.'&auth='.$auth.'&encry='.$encry.'&sort=chan&ord=ASC&from='.$from.'&to='.$inc.'&token='.$_SESSION["token"].'"><img height="15" width="15" border="0"src="../themes/'.$theme.'/img/down.png"></a><a href="?ssid='.$ssid.'&mac='.$mac.'&radio='.$radio.'&chan='.$chan.'&auth='.$auth.'&encry='.$encry.'&sort=chan&ord=DESC&from='.$from.'&to='.$inc.'&token='.$_SESSION["token"].'"><img height="15" width="15" border="0"src="../themes/'.$theme.'/img/up.png"></a></td>'
			.'<td>Radio Type<a href="?ssid='.$ssid.'&mac='.$mac.'&radio='.$radio.'&chan='.$chan.'&auth='.$auth.'&encry='.$encry.'&sort=radio&ord=ASC&from='.$from.'&to='.$inc.'"&token='.$_SESSION["token"].'><img height="15" width="15" border="0" src="../themes/'.$theme.'/img/down.png"></a><a href="?ssid='.$ssid.'&mac='.$mac.'&radio='.$radio.'&chan='.$chan.'&auth='.$auth.'&encry='.$encry.'&sort=radio&ord=DESC&from='.$from.'&to='.$inc.'&token='.$_SESSION["token"].'"><img height="15" width="15" border="0"src="../themes/'.$theme.'/img/up.png"></a></td>'
			.'<td>Authentication<a href="?ssid='.$ssid.'&mac='.$mac.'&radio='.$radio.'&chan='.$chan.'&auth='.$auth.'&encry='.$encry.'&sort=auth&ord=ASC&from='.$from.'&to='.$inc.'&token='.$_SESSION["token"].'"><img height="15" width="15" border="0" src="../themes/'.$theme.'/img/down.png"></a><a href="?ssid='.$ssid.'&mac='.$mac.'&radio='.$radio.'&chan='.$chan.'&auth='.$auth.'&encry='.$encry.'&sort=auth&ord=DESC&from='.$from.'&to='.$inc.'&token='.$_SESSION["token"].'"><img height="15" width="15" border="0"src="../themes/'.$theme.'/img/up.png"></a></td>'
			.'<td>Encryption<a href="?ssid='.$ssid.'&mac='.$mac.'&radio='.$radio.'&chan='.$chan.'&auth='.$auth.'&encry='.$encry.'&sort=encry&ord=ASC&from='.$from.'&to='.$inc.'&token='.$_SESSION["token"].'"><img height="15" width="15" border="0" src="../themes/'.$theme.'/img/down.png"></a><a href="?ssid='.$ssid.'&mac='.$mac.'&radio='.$radio.'&chan='.$chan.'&auth='.$auth.'&encry='.$encry.'&sort=encry&ord=DESC&from='.$from.'&to='.$inc.'&token='.$_SESSION["token"].'"><img height="15" width="15" border="0"src="../themes/'.$theme.'/img/up.png"></a></td></tr>';

		if($total_rows === 0)
		{
			echo '<tr><td colspan="6" align="center">There where no results, please try again</td></tr></table>'; 
			die(footer($_SERVER['SCRIPT_FILENAME']));
		}
		
		while ($newArray = mysql_fetch_array($result))
		{
			$id_s = $newArray['id'];
			$ssid_s = $newArray['ssid'];
			$mac_s = $newArray['mac'];
			$chan_s = $newArray['chan'];
			$radio_s = $newArray['radio'];
			$auth_s = $newArray['auth'];
			$encry_s = $newArray['encry'];
			if($auth_s == "" or $encry_s == '')
			{
				$auth_s = "Uknown";
				$encry_s = "Unknown";
			}
			echo '<tr><td>'.$id_s.'</td><td><a class="links" href="fetch.php?id='.$id_s.'&token='.$_SESSION['token'].'">'.$ssid_s.'</a></td>';
			echo '<td>'.$mac_s.'</td>';
			echo '<td>'.$chan_s.'</td>';
			if($radio_s=="a")
			{$radio_s="802.11a";}
			elseif($radio_s=="b")
			{$radio_s="802.11b";}
			elseif($radio_s=="g")
			{$radio_s="802.11g";}
			elseif($radio_s=="n")
			{$radio_s="802.11n";}
			else
			{$radio_s="Unknown Radio";}
			echo '<td>'.$radio_s.'</td>';
			echo '<td>'.$auth_s.'</td>';
			echo '<td>'.$encry_s.'</td></tr>';	
		}
		echo "</table>";
		echo "<br>Page: ";
	#	$sql1 = "SELECT * FROM $wtable";
	#	$result = mysql_query($sql00, $conn) or die(mysql_error($conn));
	#	$size = mysql_num_rows($result);
		$from_fwd=$from;
		$from = 0;
		$page = 1;
		$pages = $total_rows/$inc;
		if ($from=0)
		{
			$from_back=$to_back-$inc;
			echo '<a class="links" href="?ssid='.$ssid.'&mac='.$mac.'&radio='.$radio.'&chan='.$chan.'&auth='.$auth.'&encry='.$encry.'&from='.$from_back.'&to='.$$inc.'&sort='.$sort.'&ord='.$ord.'&token='.$_SESSION["token"].'"><- </a> ';
		}
		else
		{
			echo"< -";
		}
		for($I=0; $I<=$pages; $I++)
		{
				echo ' <a class="links" href="?ssid='.$ssid.'&mac='.$mac.'&radio='.$radio.'&chan='.$chan.'&auth='.$auth.'&encry='.$encry.'&from='.$from.'&to='.$inc.'&sort='.$sort.'&ord='.$ord.'&token='.$_SESSION["token"].'">'.$page.'</a> - ';
				$from=$from+$inc;
				$page++;
		}
		if ($from_<=$pages)
		{
			echo">";
		}
		else
		{
			echo '<a class="links" href="?ssid='.$ssid.'&mac='.$mac.'&radio='.$radio.'&chan='.$chan.'&auth='.$auth.'&encry='.$encry.'&from='.$from_fwd.'&to='.$$inc.'&sort='.$sort.'&ord='.$ord.'&token='.$_SESSION["token"].'">></a>';
		}
	}else
	{
		echo "<h2>Could not Compare Tokens, try again.</h2>";
	}
}else
{
	echo "<h2>You dont have a token, try again</h2>";
}
footer($_SERVER['SCRIPT_FILENAME']);
?>