<?php
include('../lib/database.inc.php');
include('../lib/config.inc.php');
pageheader("Search Results Page");
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

		echo '<table border="1" width="100%" cellspacing="0">'
			.'<tr><td align="center" colspan="6"><a class="links" href="results.php?ord='.$ord.'&sort='.$sort.'&from='.$from.'&to='.$inc.'&ssid='.$ssid.'&mac='.$mac.'&radio='.$radio.'&chan='.$chan.'&auth='.$auth.'&encry='.$encry.'&token='.$_SESSION['token'].'">Save this search</a></td></tr>'
			.'<tr class="style4"><th>SSID</th>'
			.'<th>MAC</th>'
			.'<th>Chan</th>'
			.'<th>Radio Type</th>'
			.'<th>Authentication</th>'
			.'<th>Encryption</th></tr>';
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
		$sql0 = "SELECT * FROM $wtable WHERE " . implode(' AND ', $sql_a) ." ORDER BY $sort $ord";
		$result = mysql_query($sql0, $conn) or die(mysql_error());
		$total_rows = mysql_num_rows($result);
		if($total_rows === 0)
		{
			echo '<tr><td colspan="6" align="center">There where no results, please try again</td></tr></table>'; 
			$filename = $_SERVER['SCRIPT_FILENAME'];
			footer($filename);
			die();
		}

		while ($newArray = mysql_fetch_array($result))
		{
			$id = $newArray['id'];
			$ssid = $newArray['ssid'];
			$mac = $newArray['mac'];
			$chan = $newArray['chan'];
			$radio = $newArray['radio'];
			$auth = $newArray['auth'];
			$encry = $newArray['encry'];
			echo '<tr><td><a class="links" href="fetch.php?id='.$id.'&token='.$_SESSION['token'].'">'.$ssid.'</a></td>';
			echo '<td>'.$mac.'</td>';
			echo '<td>'.$chan.'</td>';
			if($radio=="a")
			{$radio="802.11a";}
			elseif($radio=="b")
			{$radio="802.11b";}
			elseif($radio=="g")
			{$radio="802.11g";}
			elseif($radio=="n")
			{$radio="802.11n";}
			else
			{$radio="Unknown Radio";}
			echo '<td>'.$radio.'</td>';
			echo '<td>'.$auth.'</td>';
			echo '<td>'.$encry.'</td></tr>';	
		}
		echo "</table>";
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