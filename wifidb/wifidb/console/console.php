<?php
global $screen_output;
$screen_output = "CLI";
include('../lib/config.inc.php');
include('../lib/database.inc.php');
include($GLOBALS['wifidb_tools'].'/daemon/config.inc.php');

$scroll = (@$_COOKIE['console_scroll']!='' ? @$_COOKIE['console_scroll'] : $GLOBALS['console_scroll']);
$refresh = (@$_COOKIE['console_refresh']!='' ? @$_COOKIE['console_refresh'] : $GLOBALS['console_refresh']);
$last5 = (@$_COOKIE['console_last5']!='' ? @$_COOKIE['console_last5'] : $GLOBALS['console_last5']);
$lines = (@$_COOKIE['console_lines']!='' ? @$_COOKIE['console_lines'] : $GLOBALS['console_lines']);

$N=1;
$NN=1;
$sig_num=0;
$sig_line=0;
$exp_num=0;
$line_num=0;
$console_log = $GLOBALS['daemon_log_folder'].$dim.'imp_expd.log';

$COLORS = array(
				0	=>"/\033\[0;37m/",
				1	=>"/\033\[0;34m/",
				2	=>"/\033\[0;32m/",
				3	=>"/\033\[0;31m/",
				4	=>"/\033\[1;33m/",
				5	=>"/\033\[1;37m/"
				);
$REPLACE = array(
				0	=>"\</span><span class='console_lightgray'>",
				1	=>"\</span><span class='console_blue'>",
				2	=>"\</span><span class='console_green'>",
				3	=>"\</span><span class='console_red'>",
				4	=>"\</span><span class='console_yellow'>",
				5	=>"\</span><span class='console_lightgray'>"
				);

if($refresh < 1){$refresh = 15;}
if($lines < 2){$lines = 2;}
if($lines > 60){$lines = 60;}

$console = file($console_log);
$count = count($console);
$text = "";
?>

<meta http-equiv="refresh" content="<?php echo $refresh; ?>">
<link rel="stylesheet" href="style.css">
<?php
if($scroll)
{
?>
<script>
function go(){
setTimeout(window.location='#end', 20000);
}
</script>
<body onload='go()' bgcolor="BLACK">
<?php
}else
{
?>
<body bgcolor="BLACK">
<?php
}
?>
<table><tr><td>
<span class="console_lightgray">

<?php
$handle = fopen($console_log, "r");

	while($console_line = fgets($handle))
	{
		if($console_line[0] == ".")
		{
			$console_exp = explode(".",$console_line);
			foreach($console_exp as $exp)
			{
				$text = $text.".";
				if($sig_line>300){$text = $text."\r\n";$sig_line=0;}
				$sig_line++;
				$sig_num++;
			}
		}
		if($sig_num != 0 && $console_line[0] == "."){$text = $text."\nSignal Points: ".$sig_num."<br>\r\n";$sig_num=0;}
		
		if($console_line[0] == ":")
		{
			$console_exp = explode(":",$console_line);
			foreach($console_exp as $exp)
			{
				$text = $text.":";
				$exp_num++;
			}
		}
		if($exp_num != 0 && $console_line[0] != ":"){$text = $text."\nAccess Points: ".$exp_num."<br>\r\n";$exp_num=0;}
		
		$sig_num=0;
		$exp_num=0;
		if($last5)
		{
			$test = $count-$line_num;
			if($test <= $lines)
			{
				if(($N > 2) && ($N < 9))
				{
					$more_text = "<span class='console_green'>".$N."&nbsp;&nbsp;&nbsp;&nbsp;".str_replace("\\", "",  preg_replace($COLORS, $REPLACE, $console_line))."<br>\r\n";
				}elseif($N == 10)
				{
					$more_text = $N."&nbsp;&nbsp;&nbsp;&nbsp;".str_replace("\\", "",  preg_replace($COLORS, $REPLACE, $console_line))."</span><br>\r\n";
				}else
				{
					$more_text = $N."&nbsp;&nbsp;&nbsp;&nbsp;".str_replace("\\", "",  preg_replace($COLORS, $REPLACE, $console_line))."<br>\r\n";
				}
				echo wordwrap($more_text, 300, "<br>\r\n");
				$line_num++;
			}else
			{
				$line_num++;
			}
		}else
		{
			$text = $text.$N."&nbsp;&nbsp;&nbsp;&nbsp;".str_replace("\\", "",  preg_replace($COLORS, $REPLACE, $console_line))."<br>\r\n";
			if($NN == 10)
			{
				echo wordwrap($text, 275, "<br>\r\n");
				$NN=0;
				$text="";
			}else
			{
				$NN++;
			}
		}
		$N++;
	}
	if($last5 == 0)
	{
		echo $text.'<a id="end">';
	}
?>

</span>
</td></tr></table>
</body>
<br>