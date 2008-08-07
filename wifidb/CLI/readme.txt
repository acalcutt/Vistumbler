This is a converter for the Vistumbler Summery Text file to the VS1 file.

I wrote this script in windows, but it can run on any OS that you have PHP on.


The converter_vs1.php file searches the "text\" folder for vistumbler Text Summery files to convert
It is self aware of where it is living so there is no need to configure it, unless you want it to 
look in another Directory. 

To do so just comment out:

/*	
	$dirs=$_SERVER['PHP_SELF'];
	$dir_exp = explode("\\", $dirs);
	$dir_c= count($dir_exp);
	foreach($dir_exp as $d)
	{
		if($d == "convert_vs1.php")
		{
			continue;
		}
		$dir .= $d."\\";
	}
	$dir.="text\\";
*/

and uncomment: 

// $dir = "Place the DIR that you want searched Here after commenting out the above portion" ;


===================================================================

To change where the output of the VS1 file goes do the same for functions.php

comment out:

/*
	$dir_exp = explode("\\", $source);
	$dir_c = count($dir_exp);
	$script = $dir_exp[$dir_c-1];
	if ($debug ==1 )
	{
		echo $script."\n";
	}
	foreach($dir_exp as $d)
	{	
		if($d == $script)
		{
			continue;
		}
		$dir .= $d."\\";
	}
	$dir.="vs1\\";
*/

and uncomment:

/*
$dir = " Place the DIR that you want the VS1 files to go,  after commenting out the above portion " ;
*/

===================================================================

The convert_vs1() function:
This is the function that does all the work

$source : the dir and file that you are converting

"file"  : output the conversion to a VS1 file (I am working on having a database output too, via MySQL)




Example CLI output:
--------------------------------------------

=-=-=-=-=-=-=-=-=-=-==-=-=-=-=-=-Vistumbler Summery Text to VS1 converter=-=-=-=-=-=-=-=-=-=-==-=-=-=-=-=-
Directory: c:\users\pferland\Desktop\vistumbler\wifidb\CLI\text\

Files to Convert:
0 10602.txt


################=== Start conversion of c:\users\pferland\Desktop\vistumbler\wifidb\CLI\text\10602.txt ===################
1% - 2% - 3% -
Line: 365 - Wrong data type, dropping row
4% - 5% - 6% - 7% - 8% - 9% - 10% - 11% - 12% - 13% - 14% - 15% - 
16% - 17% - 18% - 19% - 20% - 21% - 22% - 23% - 24% - 25% - 26% - 
27% - 28% - 29% - 30% - 31% - 32% - 33% - 34% - 35% - 36% - 37% - 
38% - 39% - 40% - 41% - 42% - 43% - 44% - 45% - 46% - 47% - 48% - 
49% - 50% - 51% - 52% - 53% - 54% - 55% - 56% - 57% - 58% - 59% - 
60% - 61% - 62% - 63% - 64% - 65% - 66% - 67% - 68% - 69% - 70% - 
71% - 72% - 73% - 74% - 75% - 76% - 77% - 78% - 79% - 80% - 81% -
Line: 8660 - Wrong data type, dropping row
82% - 83% - 84% - 85% - 86% - 87% - 88% - 89% - 90% - 91% - 92% - 
93% - 94% - 95% - 96% - 97% - 98% - 99% - 100% - 

Total Number of Access Points : 10597
Total Number of GPS Points : 8916

-------
DONE!
Start Time : 11:48:16
 Stop Time : 11:51:38
-------