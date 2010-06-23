<?php
include('lib/database.inc.php');
	pageheader("Show All Shared GeoCaches");
include('lib/config.inc.php');
$theme = $GLOBALS['theme'];
switch(@$func)
{
	default:
		$ord	=	addslashes(@$_GET['ord']);
		$sort	=	addslashes(@$_GET['sort']);
		$from	=	addslashes(@$_GET['from']);
		$from	=	$from+0;
		$from_	=	$from+0;
		$inc	=	addslashes(@$_GET['to']);
		$inc	=	$inc+0;
	#	echo $from."<br>";
		if ($from=="" or !is_int($from)){$from=0;}
		if ($from_=="" or !is_int($from_)){$from_=0;}
		if ($inc=="" or !is_int($inc)){$inc=100;}
		if (@$_COOKIE['WiFiDB_page_limit']){$inc = @$_COOKIE['WiFiDB_page_limit'];}else{$inc=100;}
		if ($ord=="" or !is_string($ord)){$ord="ASC";}
		if ($sort=="" or !is_string($sort)){$sort="id";}
		
		?>
		<b><font size='6'>Shared Geocaches </font></b><br>
		<table BORDER=1 CELLPADDING=2 CELLSPACING=0 style="width: 95%">
			<tr>
				<th class="style3">ID<a href="?func=boeyes&boeye_func=list_all&sort=id&ord=ASC&from=<?php echo $from;?>&to=<?php echo $inc;?>"><img height="15" width="15" border="0"border="0" src="<?php echo $GLOBALS['UPATH'];?>/themes/<?php echo $theme;?>/img/down.png"></a>
				<a href="?func=boeyes&boeye_func=list_all&sort=id&ord=DESC&from=<?php echo $from;?>&to=<?php echo $inc;?>"><img height="15" width="15" border="0"border="0" src="<?php echo $GLOBALS['UPATH'];?>/themes/<?php echo $theme;?>/img/up.png"></a></th>
				<th class="style3">Name<a href="?func=boeyes&boeye_func=list_all&sort=name&ord=ASC&from=<?php echo $from;?>&to=<?php echo $inc;?>"><img height="15" width="15" border="0"border="0" src="<?php echo $GLOBALS['UPATH'];?>/themes/<?php echo $theme;?>/img/down.png"></a>
				<a href="?func=boeyes&boeye_func=list_all&sort=name&ord=DESC&from=<?php echo $from;?>&to=<?php echo $inc;?>"><img height="15" width="15" border="0"border="0" src="<?php echo $GLOBALS['UPATH'];?>/themes/<?php echo $theme;?>/img/up.png"></a></th>
				<th class="style3">Lat<a href="?func=boeyes&boeye_func=list_all&sort=lat&ord=ASC&from=<?php echo $from;?>&to=<?php echo $inc;?>"><img height="15" width="15" border="0"border="0" src="<?php echo $GLOBALS['UPATH'];?>/themes/<?php echo $theme;?>/img/down.png"></a>
				<a href="?func=boeyes&boeye_func=list_all&sort=lat&ord=DESC&from=<?php echo $from;?>&to=<?php echo $inc;?>"><img height="15" width="15" border="0"border="0" src="<?php echo $GLOBALS['UPATH'];?>/themes/<?php echo $theme;?>/img/up.png"></a></th>
				<th class="style3">Long<a href="?func=boeyes&boeye_func=list_all&sort=long&ord=ASC&from=<?php echo $from;?>&to=<?php echo $inc;?>"><img height="15" width="15" border="0"border="0" src="<?php echo $GLOBALS['UPATH'];?>/themes/<?php echo $theme;?>/img/down.png"></a>
				<a href="?func=boeyes&boeye_func=list_all&sort=long&ord=DESC&from=<?php echo $from;?>&to=<?php echo $inc;?>"><img height="15" width="15" border="0"border="0" src="<?php echo $GLOBALS['UPATH'];?>/themes/<?php echo $theme;?>/img/up.png"></a></th>
				<th class="style3">Catagory<a href="?func=boeyes&boeye_func=list_all&sort=cat&ord=ASC&from=<?php echo $from;?>&to=<?php echo $inc;?>"><img height="15" width="15" border="0"border="0" src="<?php echo $GLOBALS['UPATH'];?>/themes/<?php echo $theme;?>/img/down.png"></a>
				<a href="?func=boeyes&boeye_func=list_all&sort=cat&ord=DESC&from=<?php echo $from;?>&to=<?php echo $inc;?>"><img height="15" width="15" border="0"border="0" src="<?php echo $GLOBALS['UPATH'];?>/themes/<?php echo $theme;?>/img/up.png"></a></th>
			</tr>
			<?php
		
		$sql0 = "SELECT * FROM `$db`.`$share_cache`";
		if($result = mysql_query($sql0, $conn))
		{
			$total_rows = mysql_num_rows($result);
			$sql0 = "SELECT * FROM `$db`.`$share_cache` ORDER BY `$sort` $ord LIMIT $from, $inc";
			$result = mysql_query($sql0, $conn);
			if($total_rows != 0)
			{
				while($gcache = mysql_fetch_array($result))
				{
					if($tracker == 0)
					{
						$style_class = "light";
						$tracker = 1;
					}else
					{
						$style_class = "dark";
						$tracker = 0;
					}
					?>
					<tr>
						<td class="<?php echo $style_class;?>">
							<?php echo $gcache['id'];?>
						</td>
						<td class="<?php echo $style_class;?>">
							<a class="links" href="?func=fetch_wpt&id=<?php echo $gcache['id'];?>"><?php echo $gcache['name'];?></a>
						</td>
						<td class="<?php echo $style_class;?>">
							<?php echo $gcache['lat'];?>
						</td>
						<td class="<?php echo $style_class;?>">
							<?php echo $gcache['long'];?>
						</td>
						<td class="<?php echo $style_class;?>">
							<?php echo $gcache['cat'];?>
						</td>
					</tr>
					<?php
				}
			}else
			{
				?>
				<tr class='light'>
					<td colspan='5' align='center'>
						<b>There are no Shared Geocaches. Go import some.</b>
					</td>
				</tr>
				<?php
			}
			?>
			<tr class="sub_head">
				<td colspan="5"><CENTER>
					<?php
					$from_fwd=$from;
					$from = 0;
					$page = 1;
					$pages = $total_rows/$inc;
					$pages_exp = explode(".",$pages);
			#		echo $pages.' --- '.$pages_exp[1].'<BR>';
					$pages_end = "0.".@$pages_exp[1];
					$pages_end = $pages_end+0;
					$pages = $pages-$pages_end;
			#		echo $pages.' --- '.$pages_end.'<BR>';
					$mid_page = ($from_/$inc)+1;
					$pages_together = ' [<a class="links" href="?func=boeyes&boeye_func=list_all&from=0&to='.$inc.'&sort='.$sort.'&ord='.$ord.'">First</a>] - ';
					for($I=0; $I<=$pages; $I++)
					{
						if($I >= ($mid_page - 6) AND $I <= ($mid_page + 4))
						{
			#				echo $mid_page." --- ".$I." --- ".$page."<BR>";
							
							if($mid_page == $page)
							{
								$pages_together .= ' <i><u>'.$page.'</u></i> - ';
							}else
							{
								$pages_together .= ' <a class="links" href="?func=boeyes&boeye_func=list_all&from='.$from.'&to='.$inc.'&sort='.$sort.'&ord='.$ord.'">'.$page.'</a> - ';
							}
						}
						$from=$from+$inc;
						$page++;
					}
					$pages_together .= ' [<a class="links" href="?func=boeyes&boeye_func=list_all&from='.(($pages)*$inc).'&to='.$inc.'&sort='.$sort.'&ord='.$ord.'">Last</a>]  ';
					echo "<br>Page: < ".$pages_together." >";
					?>
				</CENTER></td>
			</tr>
			<?php
		}else
		{
			?>
			<tr class="light">
				<td colspan="5"><CENTER>
				There are no Caches in the share table, go share some if you have `em.
				</CENTER></td>
			</tr>
			<?php
		}
		?>
		</table>
		<?php
	break;
	
	case "fetch_wpt":
		
	break;
}
footer($_SERVER['SCRIPT_FILENAME']);
?>