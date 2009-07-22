<?php

#========================================================================================================================#
#											Footer (writes the footer for all pages)									 #
#========================================================================================================================#

function footer($filename = '', $output = "detailed")
{
	include('config.inc.php');
	$file_ex = explode("/", $filename);
	$count = count($file_ex);
	$file = $file_ex[($count)-1];
	if($output == "detailed")
	{
		?>
		</td>
		</tr>
		<tr>
		<td bgcolor="#315573" height="23"><a href="/<?php echo $root; ?>/img/moon.png"><img border="0" src="/<?php echo $root; ?>/img/moon_tn.png"></a></td>
		<td bgcolor="#315573" width="0" align="center">
		<?php
		if (file_exists($filename)) {?>
			<h6><i><u><?php echo $file;?></u></i> was last modified:  <?php echo date ("Y F d @ H:i:s", filemtime($filename));?></h6>
		<?php
		}
		echo $tracker;
		echo $ads;
		?>
		</td>
		</tr>
		</table>
		</body>
		</html>
		<?php
	}
}
?>