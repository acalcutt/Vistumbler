<?php
include('../lib/database.inc.php');
pageheader("Search Results Page");
include('../lib/config.inc.php');
?>
			<h2>Search Results</h2>
<?php
if (isset($_GET['token']))
{
	if (isset($_SESSION['token']) && $_GET['token'] == $_SESSION['token'])
	{
		$sql_a=array();

		if (isset($_POST['ssid']))	{$ssid = $_POST['ssid'];  }else{$ssid = $_GET['ssid'];}
		if (isset($_POST['mac']))	{$mac = $_POST['mac'];}else{$mac = $_GET['mac'];}
		if (isset($_POST['radio']))	{$radio = $_POST['radio']; }else{$radio = $_GET['radio'];}
		if (isset($_POST['chan']))	{$chan = $_POST['chan']; }else{$chan = $_GET['chan'];}
		if (isset($_POST['auth']))	{$auth = $_POST['auth']; }else{$auth = $_GET['auth'];}
		if (isset($_POST['encry']))	{$encry = $_POST['encry'];  }else{$encry = $_GET['encry'];}

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
		
		$sql_a[0]	=	" `ssid` like '".$ssid."%' ";
		$sql_a[1]	=	" `mac` like '".$mac."%' ";
		$sql_a[2]	=	" `radio` like '".$radio."%' ";
		$sql_a[3]	=	" `chan` like '".$chan."%' ";
		$sql_a[4]	=	" `auth` like '".$auth."%' ";
		$sql_a[5]	=	" `encry` like '".$encry."%' ";

		if(!$sql_a)
		{
			echo '<tr><td colspan="6" align="center">There where no results, please try again</td></tr></table>'; 
			$filename = $_SERVER['SCRIPT_FILENAME'];
			footer($filename);
			die();
		}
		mysql_select_db($db,$conn);
		
		$sql0 = "SELECT * FROM $wtable WHERE " . implode(' AND ', $sql_a) ." ORDER BY $sort $ord LIMIT $from, $inc";
		$result = mysql_query($sql0, $conn) or die(mysql_error($conn));
		
		$sql00 = "SELECT * FROM $wtable WHERE " . implode(' AND ', $sql_a) ." ORDER BY $sort $ord";
		$result1 = mysql_query($sql00, $conn) or die(mysql_error($conn));
		
		$total_rows = mysql_num_rows($result1);
		echo '<p align="center">Total APs found: '.$total_rows.'</p>';
		echo '<table border="1" width="100%" cellspacing="0">'
			.'<tr><td align="center" colspan="7"><a class="links" href="results.php?ord='.$ord.'&sort='.$sort.'&from='.$from.'&to='.$inc.'&ssid='.$ssid.'&mac='.$mac.'&radio='.$radio.'&chan='.$chan.'&auth='.$auth.'&encry='.$encry.'&token='.$_SESSION['token'].'">Save this search</a></td></tr>'
			.'<tr class="style4"><td>ID</td><td>SSID<a href="?ssid='.$ssid.'&mac='.$mac.'&radio='.$radio.'&chan='.$chan.'&auth='.$auth.'&encry='.$encry.'&sort=SSID&ord=ASC&from='.$from.'&to='.$inc.'&token='.$_SESSION["token"].'"><img height="15" width="15" border="0"border="0" src="../img/down.png"></a><a href="?ssid='.$ssid.'&mac='.$mac.'&radio='.$radio.'&chan='.$chan.'&auth='.$auth.'&encry='.$encry.'&sort=SSID&ord=DESC&from='.$from.'&to='.$inc.'&token='.$_SESSION["token"].'"><img height="15" width="15" border="0"src="../img/up.png"></a></td>'
			.'<td>MAC<a href="?ssid='.$ssid.'&mac='.$mac.'&radio='.$radio.'&chan='.$chan.'&auth='.$auth.'&encry='.$encry.'&sort=mac&ord=ASC&from='.$from.'&to='.$inc.'&token='.$_SESSION["token"].'"><img height="15" width="15" border="0"src="../img/down.png"></a><a href="?ssid='.$ssid.'&mac='.$mac.'&radio='.$radio.'&chan='.$chan.'&auth='.$auth.'&encry='.$encry.'&sort=mac&ord=DESC&from='.$from.'&to='.$inc.'&token='.$_SESSION["token"].'"><img height="15" width="15" border="0"src="../img/up.png"></a></td>'
			.'<td>Chan<a href="?ssid='.$ssid.'&mac='.$mac.'&radio='.$radio.'&chan='.$chan.'&auth='.$auth.'&encry='.$encry.'&sort=chan&ord=ASC&from='.$from.'&to='.$inc.'&token='.$_SESSION["token"].'"><img height="15" width="15" border="0"src="../img/down.png"></a><a href="?ssid='.$ssid.'&mac='.$mac.'&radio='.$radio.'&chan='.$chan.'&auth='.$auth.'&encry='.$encry.'&sort=chan&ord=DESC&from='.$from.'&to='.$inc.'&token='.$_SESSION["token"].'"><img height="15" width="15" border="0"src="../img/up.png"></a></td>'
			.'<td>Radio Type<a href="?ssid='.$ssid.'&mac='.$mac.'&radio='.$radio.'&chan='.$chan.'&auth='.$auth.'&encry='.$encry.'&sort=radio&ord=ASC&from='.$from.'&to='.$inc.'"&token='.$_SESSION["token"].'><img height="15" width="15" border="0" src="../img/down.png"></a><a href="?ssid='.$ssid.'&mac='.$mac.'&radio='.$radio.'&chan='.$chan.'&auth='.$auth.'&encry='.$encry.'&sort=radio&ord=DESC&from='.$from.'&to='.$inc.'&token='.$_SESSION["token"].'"><img height="15" width="15" border="0"src="../img/up.png"></a></td>'
			.'<td>Authentication<a href="?ssid='.$ssid.'&mac='.$mac.'&radio='.$radio.'&chan='.$chan.'&auth='.$auth.'&encry='.$encry.'&sort=auth&ord=ASC&from='.$from.'&to='.$inc.'&token='.$_SESSION["token"].'"><img height="15" width="15" border="0" src="../img/down.png"></a><a href="?ssid='.$ssid.'&mac='.$mac.'&radio='.$radio.'&chan='.$chan.'&auth='.$auth.'&encry='.$encry.'&sort=auth&ord=DESC&from='.$from.'&to='.$inc.'&token='.$_SESSION["token"].'"><img height="15" width="15" border="0"src="../img/up.png"></a></td>'
			.'<td>Encryption<a href="?ssid='.$ssid.'&mac='.$mac.'&radio='.$radio.'&chan='.$chan.'&auth='.$auth.'&encry='.$encry.'&sort=encry&ord=ASC&from='.$from.'&to='.$inc.'&token='.$_SESSION["token"].'"><img height="15" width="15" border="0" src="../img/down.png"></a><a href="?ssid='.$ssid.'&mac='.$mac.'&radio='.$radio.'&chan='.$chan.'&auth='.$auth.'&encry='.$encry.'&sort=encry&ord=DESC&from='.$from.'&to='.$inc.'&token='.$_SESSION["token"].'"><img height="15" width="15" border="0"src="../img/up.png"></a></td></tr>';

		if($total_rows === 0)
		{
			echo '<tr><td colspan="6" align="center">There where no results, please try again</td></tr></table>'; 
			$filename = $_SERVER['SCRIPT_FILENAME'];
			footer($filename);
			die();
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
		$result = mysql_query($sql00, $conn) or die(mysql_error($conn));
		$size = mysql_num_rows($result);
		$from_fwd=$from;
		$from = 0;
		$page = 1;
		$pages = $size/$inc;
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
		if ($from_<=$size)
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
$filename = $_SERVER['SCRIPT_FILENAME'];
footer($filename);
?>