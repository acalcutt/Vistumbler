<table><tr><th>Filename</th><th>File Size</th><th>File Info</th></tr>
<?php
$file = file('tree.txt');
foreach($file as $line)
{
	# EXPECTING something similar to: |-- [       4371]  index.php	//The Main Index page for WiFiDB
	if($line == '/wifidb/'){echo "<h2>".$line."</h2>";continue;}
	if($line == '\r\n' or $line == ''){echo "<tr><td colspan=\"3\"></td></tr>";continue;}
	
	preg_match('[\[[ + 0-9]+]', $line, $size);
	#				$line													|=| 	$size
	#	|-- [       4371]  index.php	//The Main Index page for WiFiDB    |=|	[       4371]
	
	$fileline = preg_replace('[\[[ + 0-9]+]', '');
	#				$line									|=| 	$size
	#	|--  index.php	//The Main Index page for WiFiDB    |=|	[       4371]
	$explode = explode("	//", $line);
	$file = $explode[0];
	$info = $explode[1];
	#		$file		|=| 	$size		|=|	$info
	#	|--  index.php	|=|	[       4371]	|=|	The Main Index page for WiFiDB
	?><tr><td><?php echo $file;?></td><td><?php echo $size;?></td><td><?php echo $info;?></td></tr>
	<?php
	
	
	
}

?>
</table>