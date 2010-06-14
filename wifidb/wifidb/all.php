<?php
include('lib/database.inc.php');
	pageheader("Show all APs");
include('lib/config.inc.php');
$theme = $GLOBALS['theme'];
$ord	=	addslashes($_GET['ord']);
$sort	=	addslashes($_GET['sort']);
$from	=	addslashes($_GET['from']);
$from	=	$from+0;
$from_	=	$from+0;
$inc	=	addslashes($_GET['to']);
$inc	=	$inc+0;
if ($from=="" or !is_int($from)){$from=0;}
if ($from_=="" or !is_int($from_)){$from_=0;}
if ($inc=="" or !is_int($inc)){$inc=100;}
if ($ord=="" or !is_string($ord)){$ord="ASC";}
if ($sort=="" or !is_string($sort)){$sort="id";}
?>
<table border="1" width="100%" cellspacing="0">
<tr class="style4"><td>SSID<a href="?sort=SSID&ord=ASC&from=<?php echo $from; ?>&to=<?php echo $inc; ?>"><img height="15" width="15" border="0"border="0" src="themes/<?php echo $theme; ?>/img/down.png"></a><a href="?sort=SSID&ord=DESC&from=<?php echo $from; ?>&to=<?php echo $inc; ?>"><img height="15" width="15" border="0"src="themes/<?php echo $theme; ?>/img/up.png"></a></td>
<td>MAC<a href="?sort=mac&ord=ASC&from=<?php echo $from; ?>&to=<?php echo $inc; ?>"><img height="15" width="15" border="0"src="themes/<?php echo $theme; ?>/img/down.png"></a><a href="?sort=mac&ord=DESC&from=<?php echo $from; ?>&to=<?php echo $inc; ?>"><img height="15" width="15" border="0"src="themes/<?php echo $theme; ?>/img/up.png"></a></td>
<td>Chan<a href="?sort=chan&ord=ASC&from=<?php echo $from; ?>&to=<?php echo $inc; ?>"><img height="15" width="15" border="0"src="themes/<?php echo $theme; ?>/img/down.png"></a><a href="?sort=chan&ord=DESC&from=<?php echo $from; ?>&to=<?php echo $inc; ?>"><img height="15" width="15" border="0"src="themes/<?php echo $theme; ?>/img/up.png"></a></td>
<td>Radio Type<a href="?sort=radio&ord=ASC&from=<?php echo $from; ?>&to=<?php echo $inc; ?>"><img height="15" width="15" border="0" src="themes/<?php echo $theme; ?>/img/down.png"></a><a href="?sort=radio&ord=DESC&from=<?php echo $from; ?>&to=<?php echo $inc; ?>"><img height="15" width="15" border="0"src="themes/<?php echo $theme; ?>/img/up.png"></a></td>
<td>Authentication<a href="?sort=auth&ord=ASC&from=<?php echo $from; ?>&to=<?php echo $inc; ?>"><img height="15" width="15" border="0" src="themes/<?php echo $theme; ?>/img/down.png"></a><a href="?sort=auth&ord=DESC&from=<?php echo $from; ?>&to=<?php echo $inc; ?>"><img height="15" width="15" border="0"src="themes/<?php echo $theme; ?>/img/up.png"></a></td>
<td>Encryption<a href="?sort=encry&ord=ASC&from=<?php echo $from; ?>&to=<?php echo $inc; ?>"><img height="15" width="15" border="0" src="themes/<?php echo $theme; ?>/img/down.png"></a><a href="?sort=encry&ord=DESC&from=<?php echo $from; ?>&to=<?php echo $inc; ?>"><img height="15" width="15" border="0"src="themes/<?php echo $theme; ?>/img/up.png"></a></td></tr>
<?php
$sql0 = "SELECT * FROM `$db`.`$wtable` ORDER BY `$sort` $ord LIMIT $from, $inc";
$result = mysql_query($sql0, $conn) or die(mysql_error($conn));

$sql00 = "SELECT * FROM `$db`.`$wtable` ORDER BY `$sort` $ord";
$result1 = mysql_query($sql00, $conn) or die(mysql_error($conn));
$total_rows = mysql_num_rows($result1);
if($total_rows != 0)
{
	$row_color = 0;
	while ($newArray = mysql_fetch_array($result))
	{
		if($row_color == 1)
		{$row_color = 0; $color = "light";}
		else{$row_color = 1; $color = "dark";}
		
		$id = $newArray['id'];
		$ssid = $newArray['ssid'];
		$mac = $newArray['mac'];
		$mac_exp = str_split($mac,2);
		$mac = implode(":",$mac_exp);
		$chan = $newArray['chan'];
		$radio = $newArray['radio'];
		$auth = $newArray['auth'];
		$encry = $newArray['encry'];
		echo '<tr class="'.$color.'"><td><a class="links" href="opt/fetch.php?id='.$id.'">'.$ssid.'</a></td>';
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
}else
{
	?>
	<tr>
		<td align="center" colspan="6">
			<b>There are no Access Points imported as of yet, go grab some with Vistumbler and import them.<br />
			Come on... you know you want too.</b>
		</td>
	</tr>
	</table>
	<?php
	$filename = $_SERVER['SCRIPT_FILENAME'];
	footer($filename);
	die();
}
?>
<tr class="sub_head"><td colspan="6" align="center">
<?php
$from_fwd=$from;
$from = 0;
$page = 1;
$pages = $total_rows/$inc;
$pages_exp = explode(".",$pages);
$pages_end = "0.".$pages_exp[1];
$pages_end = $pages_end+0;
$pages = $pages-$pages_end;
$mid_page = ($from_/$inc)+1;
$pages_together = 'Page: &lt;&#45;&#45;  &#91<a class="links" href="?from=0&to='.$inc.'&sort='.$sort.'&ord='.$ord.'">First</a>&#93 &#45; ';
for($I=0; $I<=$pages; $I++)
{
	if($I >= ($mid_page - 6) AND $I <= ($mid_page + 4))
	{
		if($mid_page == $page)
		{
			$pages_together .= ' <i><u>'.$page.'</u></i> - ';
		}else
		{
			$pages_together .= ' <a class="links" href="?from='.$from.'&to='.$inc.'&sort='.$sort.'&ord='.$ord.'">'.$page.'</a> &#45; ';
		}
	}
	$from=$from+$inc;
	$page++;
}
$pages_together .= ' &#91<a class="links" href="?from='.(($pages)*$inc).'&to='.$inc.'&sort='.$sort.'&ord='.$ord.'">Last</a>&#93 &#45;&#45;&gt;';
?>
		<?php echo $pages_together; ?>
		</td>
	</tr>
</table>
<?php
footer($_SERVER['SCRIPT_FILENAME']);
?>