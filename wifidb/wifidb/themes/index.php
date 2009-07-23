<?php
include('../lib/database.inc.php');
include('../lib/config.inc.php');
pageheader("Themes Switchboard");
			if(isset($_SESSION['token']))
			{
				$token = $_SESSION['token'];
			}else
			{
				$token = md5(uniqid(rand(), true));
				$_SESSION['token'] = $token;
			}
			?>
?>
<h2>Themes Switchboard</h2>
<table align="center"><tr style="style4"><th colspan="2">Choose a Theme</th></tr>
<form action="index.php?token=<?php echo $_SESSION['token'];?>" method="post" enctype="multipart/form-data">
<tr><td>
<input type="hidden" name="token" value="<?php echo $token; ?>" />
<SELECT NAME="theme_select">
<?php

$dh = opendir(".") or die("couldn't open directory");
while (($file = readdir($dh)) == true)
{
	if (!is_file($textdir."/".$file)) 
	{
		if($file == '.'){continue;}
		if($file == '..'){continue;}
		if($file == 'index.php'){continue;}
		?>
		<OPTION VALUE="<?php echo $file;?>"><?php	echo $file."<BR>";
		
	}
}
?>
</select>
</td></tr></table>
<?php
$filename = $_SERVER['SCRIPT_FILENAME'];
footer($filename);
?>