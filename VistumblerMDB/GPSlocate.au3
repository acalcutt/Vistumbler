#include <INet.au3>
#include <Array.au3>
$gllat = "40.714224"
$gllon = "-73.961452"
$googlelookupurl = "http://maps.google.com/maps/geo?q=" & $gllat & "," & $gllon
$webpagesource = _INetGetSource($googlelookupurl)
;ConsoleWrite($webpagesource)
$arr = StringSplit($webpagesource, @LF)
;_ArrayDisplay($arr)

For $d=1 to $arr[0]
	$gdline = StringStripWS($arr[$d], 8)
	ConsoleWrite($gdline & @CRLF)
Next