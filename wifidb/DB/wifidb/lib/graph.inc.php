<?php
$lastedit = "01-11-2008";
$ver=array(
			"graphs"=>array(
							"wifiline"			=> "2.0.2", 
							"wifibar" 			=> "2.0.2", 
							"imagegrid"			=> "1.0",
							"genboth"			=> "1.0"
							),
			);

class graphs
{
	function genboth()
	{
		include('../lib/config.php');
	echo "Got Includes<br>";	
		mysql_select_db($db,$conn);
	echo "Connected to Wifi<br>";
		$this->sql = "SELECT `id` FROM $wtable";
		$this->results = mysql_query($this->sql, $conn) or die(mysql_error());
	echo "Queried Pointer Table<br>";
		$n=0;
		while ($newArray = mysql_fetch_array($this->results))
		{
			$id_p[$n]=$newArray['id'];
			$n++;
		}
	echo "Built array of AP ID's<br>";
		#Start line graph
		foreach($id_p as $val)
		{
			mysql_select_db($db,$conn);
		echo "Start for ID: ".$val."<br>";
			$this->sql = "SELECT * FROM `$wtable` WHERE `id`='$val'";
			$this->results = mysql_query($this->sql, $conn) or die(mysql_error());
		echo "Queried Pointer table for Info<br>";
			
			$newArray = mysql_fetch_array($this->results);
			
			$this->ssid = $newArray['ssid'];
			$this->mac = $newArray['mac'];
			$this->man = $newArray['manuf'];
			$this->sectype = $newArray['sectype'];
			$this->radio = $newArray['radio'];
			$this->chan = $newArray['chan'];
			
			if ($this->sectype == "1"){$this->auth = "Open";$this->encry="None";}
			elseif($this->sectype == "2"){$this->auth = "Open";$this->encry="WEP";}
			elseif($this->sectype == "3"){$this->auth = "WPA-Personal";$this->encry="TKIP";}
		echo "Created Auth and Encry info from Sectype<br>";
			$source = $this->ssid."-".$this->mac."-".$this->sectype."-".$this->radio."-".$this->chan;
			
			mysql_select_db($db_st,$conn);
		echo "Connected to Wifi_ST<br>";
			$this->result = mysql_query("SELECT * FROM `$source`", $conn) or die(mysql_error());
			$n=1;
			while ($this->field = mysql_fetch_array($this->result)) 
			{
				$id[$n]=$this->field['id'];
				$btx[$n]=$this->field['btx'];
				$otx[$n]=$this->field['otx'];
				$nt[$n]=$this->field['nt'];
				$label[$n]=$this->field['label'];
				$sig[$n]=$this->field['sig'];
				$user[$n]=$this->field['user'];
			echo "Got data from ST table<br>";
				$tmp=explode("-",$sig[$n]);
				$this->sigtmp=$sig[$n];
				
				$sig[$n]="";
				foreach($tmp as $val)
				{
					$tm=explode(",",$val);
					$sig[$n].=$tm[1]."-";
				}
			echo "Cleaned up Signal data for use in 2D graph<br>	[".$sig[$n]."]";
			$n++;
			}
			$n=0;
			foreach($id as $val)
			{
			echo "Start graph gen for Row ID: ".$val."<br>";
			$source_row = $this->ssid."-".$this->mac."-".$this->sectype."-".$this->radio."-".$this->chan."-row-".$val;
			echo $source_row."<br>";
			$file_b="../graph/waps/".$source_row.".png";
			$file_v="../graph/waps/".$source_row."v.png";
			if (file_exists($file_v) and file_exists($file_b))
			{
				echo "File exists, not generating Line graph for this AP's Row<br>";
				continue;
			}
			else{
				if (!file_exists($file_v)){
				graphs::wifigraphline($this->ssid, $this->mac, $this->man, $this->auth, $this->encry, $this->radio, $this->chan, $lat[$n], $long[$n], $btx[$n], $otx[$n], $fa[$n], $lu[$n], $nt[$n], $label[$n], $sig[$n], $source_row );
				echo "Generated Line Graph<br>";
				}
				if(!file_exists($file_b)){
				graphs::wifigraphbar($this->ssid, $this->mac, $this->man, $this->auth, $this->encry, $this->radio, $this->chan, $lat[$n], $long[$n], $btx[$n], $otx[$n], $fa[$n], $lu[$n], $nt[$n], $label[$n], $sig[$n], $source_row );
				echo "Generated Bar Graph<br>";
				}
			}
				unset($this->results);
				unset($this->sql);
				unset($sig);
			$n++;
			}
		}
	#end gen graph
	}

#==============================================================================================================================================================#
#													Image Grid Function												         #
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
#													WiFi Graph Linegraph												         #
#==============================================================================================================================================================#

	function wifigraphline($ssid, $mac, $man, $auth, $encry, $radio, $chan, $lat, $long, $BTx, $OTx, $FA, $LU, $NT, $label, $sig, $date, $linec="rand", $text="rand")
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
	}else{
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
	}else{
	$line_color = explode(':', $linec);
	$r=$line_color[0];
	$g=$line_color[1];
	$b=$line_color[2];
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
	$bg     = imagecolorallocate($img, 255, 255, 255);
	$grid   = imagecolorallocate($img,0,0,0);
	$color  = imagecolorallocate($img, 255, 0, 0);
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
	$n=$count-1;
	$nn=$count-2;
	while($count>-1)
	{
	    imageline($img, $y ,459-($signal[$n]*4), $y=$y+6 ,459-($signal[$nn]*4) ,$col);
	    imageline($img, $u ,460-($signal[$n]*4), $u=$u+6 ,460-($signal[$nn]*4) ,$col);
	    imageline($img, $yy ,459-($signal[$n]*4), $yy=$yy+6 ,459-($signal[$nn]*4) ,$col);
	    imageline($img, $uu ,460-($signal[$n]*4), $uu=$uu+6 ,460-($signal[$nn]*4) ,$col);
	$n--;
	$nn--;
	$count--;
	}
	imagesetstyle($img,array($bg,$grid));
	graphs::imagegrid($img,$wid,$Height,19.99,$grid);
	$name='../out/graph/'.$date.'v.png';
	echo '<h1>'.$ssid.'</h1><br>';
	echo '<img src="'.$name.'"><br />';
	ImagePNG($img, $name);
	ImageDestroy($img);
	}
	#==============================================================================================================================================================#
	#													WiFi Graph Bargraph													         #
	#==============================================================================================================================================================#
	function wifigraphbar($ssid, $mac, $man, $auth, $encry, $radio, $chan, $lat, $long, $BTx, $OTx, $FA, $LU, $NT, $label, $sig, $date, $linec="rand", $text="rand")
	{
	$p=460;
	$I=0;

	if ($text == 'rand')
	{
	$tr = rand(50,200);
	$tg = rand(50,200);
	$tb = rand(50,200);
	}else{
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
	}else{
	$line_color = explode(':', $linec);
	$r=$line_color[0];
	$g=$line_color[1];
	$b=$line_color[2];
	}
	if ($ssid==""or$ssid==" ")
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
	$bg     = imagecolorallocate($img, 255, 255, 255);
	$grid   = imagecolorallocate($img,0,0,0);
	$color  = imagecolorallocate($img, 255, 0, 0);
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
	while($count>=0)
	{
	  if ($signal[$count]==0)
	  {
	  $signal[$count]=1;
	  imageline($img, $X ,459, $X, 459-($signal[$count]), $col);
	  $X++;
	  imageline($img, $X ,459, $X, 459-($signal[$count]), $col);
	  $X=$X+2;
	  }else{
	  imageline($img, $X ,459, $X, 459-($signal[$count]*4), $col);
	  $X++;
	  imageline($img, $X ,459, $X, 459-($signal[$count]*4), $col);
	  $X=$X+2;
	  }
	$count--;
	}
	imagesetstyle($img,array($bg,$grid));
	graphs::imagegrid($img,$wid,$Height,19.99,$grid);
	$name='../out/graph/'.$date.'.png';
	echo '<h1>'.$ssid.'</h1><br>';
	echo '<img src="'.$name.'"><br />';
	ImagePNG($img, $name);
	ImageDestroy($img);
	}
#end Graphs CLASS
}

?>