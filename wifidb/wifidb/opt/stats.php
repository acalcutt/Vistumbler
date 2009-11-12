<?php
	function max_string_len($My_Array)
	{
		$len = 0;
		$keep_key = 0;
		foreach($My_Array as $key=>$val)
		{
#			dump($val);
			$length = strlen($val);
			if($length > $len)
			{
				$len = $length;
				$keep_key = $key;
#				dump($keep_key);
#				dump($len);
			}
		}
		return $len;
	}

	function dump(&$var, $info = FALSE)
	{
	    $scope = false;
	    $prefix = 'unique';
	    $suffix = 'value';
	 
	    if($scope) $vals = $scope;
	    else $vals = $GLOBALS;

	    $old = $var;
	    $var = $new = $prefix.rand().$suffix; $vname = FALSE;
	    foreach($vals as $key => $val) if($val === $new) $vname = $key;
	    $var = $old;

	    echo "<pre style='margin: 0px 0px 10px 0px; display: block; background: white; color: black; font-family: Verdana; border: 1px solid #cccccc; padding: 5px; font-size: 10px; line-height: 13px;'>";
	    if($info != FALSE) echo "<b style='color: red;'>$info:</b><br>";
	    do_dump($var, '$'.$vname);
	    echo "</pre>";
	}

	function do_dump(&$var, $var_name = NULL, $indent = NULL, $reference = NULL)
	{
	    $do_dump_indent = "<span style='color:#eeeeee;'>|</span> &nbsp;&nbsp; ";
	    $reference = $reference.$var_name;
	    $keyvar = 'the_do_dump_recursion_protection_scheme'; $keyname = 'referenced_object_name';

	    if (is_array($var) && isset($var[$keyvar]))
	    {
	        $real_var = &$var[$keyvar];
	        $real_name = &$var[$keyname];
	        $type = ucfirst(gettype($real_var));
	        echo "$indent$var_name <span style='color:#a2a2a2'>$type</span> = <span style='color:#e87800;'>&amp;$real_name</span><br>";
	    }
	    else
	    {
	        $var = array($keyvar => $var, $keyname => $reference);
	        $avar = &$var[$keyvar];
	   
	        $type = ucfirst(gettype($avar));
	        if($type == "String") $type_color = "<span style='color:green'>";
	        elseif($type == "Integer") $type_color = "<span style='color:red'>";
	        elseif($type == "Double"){ $type_color = "<span style='color:#0099c5'>"; $type = "Float"; }
	        elseif($type == "Boolean") $type_color = "<span style='color:#92008d'>";
	        elseif($type == "NULL") $type_color = "<span style='color:black'>";
	   
	        if(is_array($avar))
	        {
	            $count = count($avar);
	            echo "$indent" . ($var_name ? "$var_name => ":"") . "<span style='color:#a2a2a2'>$type ($count)</span><br>$indent(<br>";
	            $keys = array_keys($avar);
	            foreach($keys as $name)
	            {
	                $value = &$avar[$name];
	                do_dump($value, "['$name']", $indent.$do_dump_indent, $reference);
	            }
	            echo "$indent)<br>";
	        }
	        elseif(is_object($avar))
	        {
	            echo "$indent$var_name <span style='color:#a2a2a2'>$type</span><br>$indent(<br>";
	            foreach($avar as $name=>$value) do_dump($value, "$name", $indent.$do_dump_indent, $reference);
	            echo "$indent)<br>";
	        }
	        elseif(is_int($avar)) echo "$indent$var_name = <span style='color:#a2a2a2'>$type(".strlen($avar).")</span> $type_color$avar</span><br>";
	        elseif(is_string($avar)) echo "$indent$var_name = <span style='color:#a2a2a2'>$type(".strlen($avar).")</span> $type_color\"$avar\"</span><br>";
	        elseif(is_float($avar)) echo "$indent$var_name = <span style='color:#a2a2a2'>$type(".strlen($avar).")</span> $type_color$avar</span><br>";
	        elseif(is_bool($avar)) echo "$indent$var_name = <span style='color:#a2a2a2'>$type(".strlen($avar).")</span> $type_color".($avar == 1 ? "TRUE":"FALSE")."</span><br>";
	        elseif(is_null($avar)) echo "$indent$var_name = <span style='color:#a2a2a2'>$type(".strlen($avar).")</span> {$type_color}NULL</span><br>";
	        else echo "$indent$var_name = <span style='color:#a2a2a2'>$type(".strlen($avar).")</span> $avar<br>";

	        $var = $var[$keyvar];
	    }
	}

	function grid($image, $w, $h, $s, $color)
	{
		$ws = $w/$s;
		$hs = $h/$s;
		for($iw=3; $iw < $ws; ++$iw)
		{
			imageline($image, ($iw-0)*$s, 40 , ($iw-0)*$s, $w , $color);
		}
		for($ih=2; $ih<$hs; ++$ih)
		{
			imageline($image, 60, $ih*$s, $w , $ih*$s, $color);
		}
	}

 	function stat_graph($title="Untitled", $aps=array(), $gps=array(), $files=array(), $type="")
	{
		$n=0;
		$nn=1;
		$y=60;
		$yy=61;
		$u=60;
		$uu=61;
		
#		$bgc="255:255:255";
		$bgc="000:000:000";
		
		$textc="255:255:255";
#		$textc="000:000:000";
		
		$line1="255:000:000";
		$line2="000:255:000";
		
		$text_color = explode(':', $textc);
		$tr=$text_color[0];
		$tg=$text_color[1];
		$tb=$text_color[2];

		$line1_color = explode(':', $line1);
		$r1=$line1_color[0];
		$g1=$line1_color[1];
		$b1=$line1_color[2];

		$line2_color = explode(':', $line2);
		$r2=$line2_color[0];
		$g2=$line2_color[1];
		$b2=$line2_color[2];
		
		#FIND OUT IF THE IMG NEEDS TO BE WIDER
		
		$count = count($aps);
		$gps_count = count($gps);
		
		$Span = 20;
		
		$gps_div = 65;
		$max_aps = max($aps);
		if($type == "users")
		{
			$max_gps = 0;
			$aps_div = 10;
		}elseif($type == "files")
		{
			$aps_div = 25;
			$max_gps = max($gps);
		}

		$aps_scale = $max_aps/$aps_div;
		$gps_scale = $max_gps/$gps_div;
		
		$gps__ = $gps_div/20;
		$aps__ = $aps_div/20;
		
		$aps_value = $aps_scale/$aps__;
		$gps_value = $gps_scale/$gps__;
	
		$gps_height = $max_gps/$gps_div;
		$aps_height = $max_aps/$aps_div;
		
#	echo $aps_height."<BR>".$gps_height."<BR>";
		
		$max_height = max($gps_height, $aps_height);
		
		$longest_file = max_string_len($files);
		$start_number = $longest_file*9;
		
		$max_height = $max_height+20;
#		echo $max_height."<BR>";
		
		switch($type)
		{
			case "files":
				if(900 < ($count*$Span))
				{$wid = ($count*$Span)+90;}
				else{$wid = 900;}
				
				if(1024 < $max_height)
				{$Height = $max_height;}
				else{$Height = 1024;}
			break;
			
			case "users":
				if(800 < ($count*$Span))
				{$wid = ($count*$Span)+90;}
				else{$wid = 800;}
				
				if(700 < $max_height)
				{$Height = $max_height;}
				else{$Height = 700;}
			break;
		}
		
		$_20_from_bottom	= $Height - 20;
		
		$start_of_lines_459	= $Height-$start_number;
		$start_of_lines_460	= ($Height-$start_number) - 1;
		
#	echo "<BR>".$start_of_lines_459."<BR>".$start_of_lines_460;
		
		$img    = ImageCreateTrueColor($wid, $Height);
		$bg     = imagecolorallocate($img, 0, 0, 0);
		$tcolor = imagecolorallocate($img, 0, 0, 255);
		$col1	= imagecolorallocate($img, 255, 0, 0);
		$col2	= imagecolorallocate($img, 0, 255, 0);
		
		imagefill($img,0,0,$bg); #PUT HERE SO THAT THE TEXT DOESNT HAVE BLACK FILLINGS (eww)
		$grid_bottom_y = $max_height-$start_number;
		$grid_bottom_x = $wid-15;
		#signal strenth numbers--
		$max_value = max($aps_value, $gps_value);
		$p=$grid_bottom_y-20;
		$I=$max_value;
		$II=0;
		while($II<125)
		{
			$I_exp = explode(".",$I);
			$I = $I_exp[0];
			imagestring($img, 4, 5, $p, $I, $col1);
			$I=$I+$max_value;
			$p=$p-20;
			$II=$II+5;
		}
		#end signal strenth numbers--
		
		$grid   = imagecolorallocate($img,255,255,255);
		imagesetstyle($img, array($bg, $grid));
		
		imagesetstyle($img,array($bg,$grid));
		grid($img, $grid_bottom_x, $start_of_lines_460-20, 20, $grid);

		imagerectangle($img, 60, 40, $grid_bottom_x, $start_of_lines_460-20, $grid);
		imagerectangle($img, 61, 41, $grid_bottom_x+1, $start_of_lines_460-21, $grid);
		if($type == "files")
		{
			//legend box
			imagefilledrectangle($img, 65,65,315,115, $bg);
			imagerectangle($img, 65,65,315,115, $grid);

			//GPS color box
			imagefilledrectangle($img, 70,70,90,90, $col2);
			imagerectangle($img, 70,70,90,90, $grid);
			imagestring($img, 4, 95, 70, "<- Number of GPS points", $grid);
			
			//AP color box
			imagefilledrectangle($img, 70,90,90,110, $col1);
			imagerectangle($img, 70,90,90,110, $grid);
			imagestring($img, 4, 95, 90, "<- Number of Access Points", $grid);
		}elseif($type == "users")
		{
			//legend box
			imagefilledrectangle($img, 65,65,315,95, $bg);
			imagerectangle($img, 65,65,315,95, $grid);

			//AP color box
			imagefilledrectangle($img, 70,70,90,90, $col2);
			imagerectangle($img, 70,70,90,90, $grid);
			imagestring($img, 4, 95, 70, "<- Number of Access Points", $grid);
		}
		foreach($aps as $key=>$ap)
		{
#			if($nn == $count){continue;}
	#		echo $ap."<BR>".$key."<BR>";
			
			if($type == "users")
			{
				if($aps[$key+1]==0 && $aps[$key+2]==0)
				{
					$aps[$key+1]=$aps[$key];
					$y__ = $y;
					$u__ = $u;
					$yy__ = $yy;
					$uu__ = $uu;
				}else
				{
					$y__ = $y+$Span;
					$u__ = $u+$Span;
					$yy__ = $yy+$Span;
					$uu__ = $uu+$Span;
				}
				imageline($img, $y ,$start_of_lines_459-($ap/$aps_div), $y__ ,$start_of_lines_459-($aps[$key+1]/$aps_div) ,$col2);
				imageline($img, $u ,$start_of_lines_460-($ap/$aps_div), $u__ ,$start_of_lines_460-($aps[$key+1]/$aps_div) ,$col2);
				imageline($img, $yy ,$start_of_lines_459-($ap/$aps_div), $yy__ ,$start_of_lines_459-($aps[$key+1]/$aps_div) ,$col2);
				imageline($img, $uu ,$start_of_lines_460-($ap/$aps_div), $uu__ ,$start_of_lines_460-($aps[$key+1]/$aps_div) ,$col2);
			}elseif($type == "files")
			{
				if((@$aps[$key+1]==0 && @$aps[$key+2]==0) && (@$gps[$key+1]==0 && @$gps[$key+2]==0) )
				{
					$aps[$key+1]=$aps[$key];
					
					$y__ = $y;
					$u__ = $u;
					$yy__ = $yy;
					$uu__ = $uu;
				}else
				{
					$y__ = $y+$Span;
					$u__ = $u+$Span;
					$yy__ = $yy+$Span;
					$uu__ = $uu+$Span;
				}
				imageline($img, $y ,$start_of_lines_459-($ap/$aps_div)-20, $y__ ,$start_of_lines_459-($aps[$key+1]/$aps_div)-20 ,$col1);
				imageline($img, $u ,$start_of_lines_460-($ap/$aps_div)-20, $u__ ,$start_of_lines_460-($aps[$key+1]/$aps_div)-20 ,$col1);
				imageline($img, $yy ,$start_of_lines_459-($ap/$aps_div)-20, $yy__ ,$start_of_lines_459-($aps[$key+1]/$aps_div)-20 ,$col1);
				imageline($img, $uu ,$start_of_lines_460-($ap/$aps_div)-20, $uu__ ,$start_of_lines_460-($aps[$key+1]/$aps_div)-20 ,$col1);
			
				imageline($img, $y ,$start_of_lines_459-($gps[$key]/$gps_div)-20, $y__ ,$start_of_lines_459-($gps[$key+1]/$gps_div)-20 ,$col2);
				imageline($img, $u ,$start_of_lines_460-($gps[$key]/$gps_div)-20, $u__ ,$start_of_lines_460-($gps[$key+1]/$gps_div)-20 ,$col2);
				imageline($img, $yy ,$start_of_lines_459-($gps[$key]/$gps_div)-20, $yy__ ,$start_of_lines_459-($gps[$key+1]/$gps_div)-20 ,$col2);
				imageline($img, $uu ,$start_of_lines_460-($gps[$key]/$gps_div)-20, $uu__ ,$start_of_lines_460-($gps[$key+1]/$gps_div)-20 ,$col2);
			}
			imagestringup($img, 4, $y, $_20_from_bottom, $files[$n], $grid);
			
			$y=$y+$Span;
			$yy=$yy+$Span;
			$u=$u+$Span;
			$uu=$uu+$Span;
			$n++;
			$nn++;
			$count--;
		}
		
		$name='../out/stats/stats_'.$title.'.png';
		ImagePNG($img, $name);
		ImageDestroy($img);
		echo '<img src="'.$name.'"><br />';
	}

error_reporting(E_ALL|E_STRICT);

#include('../lib/database.inc.php');
include('../lib/config.inc.php');
#include('../lib/graph.inc.php');

#	pageheader("Statistics for WiFiDB");
#	$database = new database();
#	$graph = new graph();

$aps = array();
$gps = array();
$filenames = array();

$sql0 = "SELECT * FROM `$db`.`files` ORDER BY `id` ASC";
$result0 = mysql_query($sql0, $conn) or die(mysql_error($conn));
$total_rows = mysql_num_rows($result0);
if($total_rows != 0)
{
	while ($files = mysql_fetch_array($result0))
	{
		$filenames[]	=	$files['file'];
		$aps[]			=	$files['aps'];
		$gps[]			=	$files['gps'];
	}
#	dump($filenames);
#	dump($data);
	
	stat_graph($title="Untitled", $aps, $gps, $filenames, $type="files");
}else
{
	echo "<h2>There is nothing to stat, import something so I can graph it.</h2>";
}

$N = -1;
$last_user = '';
$users = array();
$ap_s = array();

$sql0 = "SELECT * FROM `$db`.`users` ORDER BY `username` ASC";
$result0 = mysql_query($sql0, $conn) or die(mysql_error($conn));
$total_rows = mysql_num_rows($result0);
if($total_rows != 0)
{
	while ($users_return = mysql_fetch_array($result0))
	{
		if($users_return['username'] != $last_user)
		{
			$N++;
			$num_pts = 0;
			$users[$N] = $users_return['username'];
		}
		echo $users[$N]."<BR>";
		$points_exp = explode("-",$users_return['points']);
		$points_temp = "";
		$points_temp = array();
		foreach($points_exp as $point)
		{
			$point_exp = explode(":", $point);
			if($point_exp[0] == 0)
			{
				$pnt_exp = explode("," , $point_exp[0]);
				$points_temp[] = $pnt_exp[1];
			}
		}
		$implode_pts = count($points_temp);
		$num_pts = $num_pts+$implode_pts;
	#	ECHO $implode_pts."<BR>";
		$last_user = $users_return['username'];
		if($N != -1 ){$ap_s[$N] = $num_pts;}
	}
	dump($users);
	
	$blank = array();
#	$ap_s = array( 0=>2000,1=>1200,2=>2500,3=>3200,4=>1200,5=>500,6=>1000);
	dump($ap_s);
	stat_graph($title="Untitled_1", $ap_s, $blank, $users, $type="users");
}else
{
	echo "<h2>There is nothing to stat, import something so I can graph it.</h2>";
}



#footer($_SERVER['SCRIPT_FILENAME']);
?>