<?php
$ver=array(
			"lastedit"	=>"2010-June-13",
			"wifi"		=>"v2.0.5",
			"imagegrid" => "v1.0",
		   );

#==============================================================================================================================================================#
#													Image Grid Function													         #
#==============================================================================================================================================================#

function imagegrid($image, $w, $h, $s, $color)
 {
  $ws = $w/$s;
  $hs = $h/$s;

  for($iw=0; $iw < $ws; ++$iw)
   {
    imageline($image, ($iw-0)*$s, 60 , ($iw-0)*$s, $w , $color);
   }

  for($ih=0; $ih<$hs; ++$ih)
   {
    imageline($image, 0, $ih*$s, $w , $ih*$s, $color);
   }
 }
 

#==============================================================================================================================================================#
#													WiFi Graph Linegraph													         #
#==============================================================================================================================================================#

	function wifigraphline($ssid, $mac, $man, $auth, $encry, $radio, $chan, $lat, $long, $BTx, $OTx, $FA, $LU, $NT, $label, $sig, $date, $linec='rand', $text='rand', $bgc='rand')
	{
		$n=0;
		$nn=1;
		$y=20;
		$yy=21;
		$u=20;
		$uu=21;
		if ($text == 'rand')
		{
			$tr = rand(25,220);
			$tg = rand(25,220);
			$tb = rand(25,220);
		}else
		{
			$text_color = explode(':', $text);
			$tr=$text_color[0];
			$tg=$text_color[1];
			$tb=$text_color[2];
		}
		if ($linec== 'rand')
		{
			$r = rand(25,220);
			$g = rand(25,220);
			$b = rand(25,220);
		}else
		{
			$line_color = explode(':', $linec);
			$r=$line_color[0];
			$g=$line_color[1];
			$b=$line_color[2];
		}
		if($bgc == 'rand')
		{
			$bgcr = rand(25, 220);
			$bgcg = rand(25, 220);
			$bgcb = rand(25, 220);
		}else
		{
			$bgcc	= explode(":",$bgc);
			$bgcr = $bgcc[0];
			$bgcg = $bgcc[1];
			$bgcb = $bgcc[2];
		}
		
		if ($ssid==""or$ssid==" " )
		{
			$ssid="UNNAMED";
		}
			$signal = explode("-", $sig);
			$count = count($signal);
			$c1 = 'SSID: '.$ssid.'   Channel: '.$chan.'   Radio: '.$radio.'   Network: '.$NT.'   OTx: '.$OTx;
			$check = strlen($c1);
			$c2 = 'Mac: '.$mac.'   Auth: '.$auth.' '.$encry.'   BTx: '.$BTx.'   Lat: '.$lat.'   Long: '.$long;
			$check2 = strlen($c2);
			$c3 = 'Manuf: '.$man.'   Label: '.$label.'   First: '.$FA.'   Last: '.$LU;
			$check3 = strlen($c3);
			#FIND OUT IF THE IMG NEEDS TO BE WIDER
		if(900 < ($count*6.2))
		{
			$Height = 480;
			$wid    = ($count*6.2)+40;
		}
		elseif(900 < ($check3*6))
		{
			$Height = 480;
			$wid    = ($check3*6)+40;
		}
		elseif(900 < ($check2*6.2))
		{
			$Height = 480;
			$wid    = ($check2*6.2)+40;
		}
		elseif(900 < ($check*6))
		{
			$Height = 480;
			$wid    = ($check*6)+40;
		}
		else
		{
			$wid    = 900;
			$Height = 480;
		}
		$img    = ImageCreateTrueColor($wid, $Height);
		$bg     = imagecolorallocate($img, $bgcr, $bgcg, $bgcb);
		if($bgc !== "000:000:000")
		{
			$grid   = imagecolorallocate($img,0,0,0);
		}else
		{
			$grid   = imagecolorallocate($img,255,255,255);
		}
		$tcolor = imagecolorallocate($img, $tr, $tg, $tb);
		$col = imagecolorallocate($img, $r, $g, $b);
		imagefill($img,0,0,$bg); #PUT HERE SO THAT THE TEXT DOESNT HAVE BLACK FILLINGS (eww)
		imagestring($img, 4, 21, 3, $c1, $tcolor);
		imagestring($img, 4, 21, 23, $c2, $tcolor);
		imagestring($img, 4, 21, 43, $c3, $tcolor);
		#signal strenth numbers--
		$p=460;
		$I=0;
		while($I<105)
		{
			imagestring($img, 4, 3, $p, $I, $tcolor);
			$I=$I+5;
			$p=$p-20;
		}
		#end signal strenth numbers--
		imagesetstyle($img, array($bg, $grid));
		$counting=$count-1;
		$n=0;
		$nn=1;
		imagesetstyle($img,array($bg,$grid));
		imagegrid($img,$wid,$Height,19.99,$grid);
		while($count>0)
		{
			if($nn==$counting+1){break;}
			imageline($img, $y ,459-($signal[$n]*4), $y=$y+6 ,459-($signal[$nn]*4) ,$col);
			imageline($img, $u ,460-($signal[$n]*4), $u=$u+6 ,460-($signal[$nn]*4) ,$col);
			imageline($img, $yy ,459-($signal[$n]*4), $yy=$yy+6 ,459-($signal[$nn]*4) ,$col);
			imageline($img, $uu ,460-($signal[$n]*4), $uu=$uu+6 ,460-($signal[$nn]*4) ,$col);
			$n++;
			$nn++;
			$count--;
		}
		$name='tmp/'.$date.'v.png';
		echo '<h1>'.$ssid.'</h1><br>';
		echo '<img src="'.$name.'"><br />';
		ImagePNG($img, $name);
		ImageDestroy($img);
	}


#==============================================================================================================================================================#
#													WiFi Graph Bargraph													         #
#==============================================================================================================================================================#


	function wifigraphbar($ssid, $mac, $man, $auth, $encry, $radio, $chan, $lat, $long, $BTx, $OTx, $FA, $LU, $NT, $label, $sig, $date, $linec='rand', $text='rand', $bgc='rand')
	{
		$p=460;
		$I=0;

		if ($text == 'rand')
		{
			$tr = rand(50,200);
			$tg = rand(50,200);
			$tb = rand(50,200);
		}else
		{
			$text_color = explode(':', $text);
			$tr=$text_color[0];
			$tg=$text_color[1];
			$tb=$text_color[2];
		}
		if ($linec == 'rand')
		{
			$r = rand(50,200);
			$g = rand(50,200);
			$b = rand(50,200);
		}else
		{
			$line_color = explode(':', $linec);
			$r=$line_color[0];
			$g=$line_color[1];
			$b=$line_color[2];
		}
		if($bgc == 'rand')
		{
			$bgcr = rand(25, 220);
			$bgcg = rand(25, 220);
			$bgcb = rand(25, 220);
		}else
		{
			$bgcc	= explode(":",$bgc);
			$bgcr = $bgcc[0];
			$bgcg = $bgcc[1];
			$bgcb = $bgcc[2];
		}
		if ($ssid==""or$ssid==" ")
		{
			$ssid="UNNAMED";
		}
		$signal = explode("-", $sig);
		$count = (count($signal)-1);
		$c1 = 'SSID: '.$ssid.'   Channel: '.$chan.'   Radio: '.$radio.'   Network: '.$NT.'   OTx: '.$OTx;
		$check = strlen($c1);
		$c2 = 'Mac: '.$mac.'   Auth: '.$auth.' '.$encry.'   BTx: '.$BTx.'   Lat: '.$lat.'   Long: '.$long;
		$check2 = strlen($c2);
		$c3 = 'Manuf: '.$man.'   Label: '.$label.'   First: '.$FA.'   Last: '.$LU;
		$check3 = strlen($c3);
		#FIND OUT IF THE IMG NEEDS TO BE WIDER
		if(900 < ($count*3))
		{
			$Height = 480;
			$wid    = ($count*3)+38;
		}
		elseif(900 < ($check3*8))
		{
			$Height = 480;
			$wid    = ($check3*8)+40;
		}
		elseif(900 < ($check2*8))
		{
			$Height = 480;
			$wid    = ($check2*8)+40;
		}
		elseif(900 < ($check*8))
		{
			$Height = 480;
			$wid    = ($check*8)+40;
		}
		else
		{
			$wid    = 900;
			$Height = 480;
		}
		$img    = ImageCreateTrueColor($wid, $Height);
		$bg     = imagecolorallocate($img, $bgcr, $bgcg, $bgcb);
		if($bgc == "000:000:000")
		{
			$grid   = imagecolorallocate($img,255,255,255);
		}else
		{
			$grid   = imagecolorallocate($img,0,0,0);
		}
		$tcolor = imagecolorallocate($img, $tr, $tg, $tb);
		$col = imagecolorallocate($img, $r, $g, $b);
		imagefill($img,0,0,$bg); #PUT HERE SO THAT THE TEXT DOESNT HAVE BLACK FILLINGS (eww)
		imagestring($img, 4, 21, 3, $c1, $tcolor);
		imagestring($img, 4, 21, 23, $c2, $tcolor);
		imagestring($img, 4, 21, 43, $c3, $tcolor);
		#signal strenth numbers--
		while($I<105)
		{
			imagestring($img, 4, 3, $p, $I, $tcolor);
			$I=$I+5;
			$p=$p-20;
		}
		#end signal strenth numbers--
		imagesetstyle($img, array($bg, $grid));
		$X=20;
		$n=0;
		imagesetstyle($img,array($bg,$grid));
		imagegrid($img,$wid,$Height,19.99,$grid);
		while($count>=0)
		{
			if($n==$count+1){break;}
			if ($signal[$n]==0)
			{
				$signal[$n]=1;
				imageline($img, $X ,459, $X, 459-($signal[$n]), $col);
				$X++;
				imageline($img, $X ,459, $X, 459-($signal[$n]), $col);
				$X=$X+2;
			}
			else
			{
				imageline($img, $X ,459, $X, 459-($signal[$n]*4), $col);
				$X++;
				imageline($img, $X ,459, $X, 459-($signal[$n]*4), $col);
				$X=$X+2;
			}
			$n++;
			$count--;
		}
		$name='tmp/'.$date.'.png';
		echo '<h1>'.$ssid.'</h1><br>';
		echo '<img src="'.$name.'"><br />';
		ImagePNG($img, $name);
		ImageDestroy($img);
	}
?>