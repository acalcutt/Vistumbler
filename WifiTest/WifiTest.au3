#include <Array.au3>
#include <Process.au3>
#include "UDFs\NativeWifi.au3"

$logtext = ""
$log = "log.txt"

; ----- Get Native Wifi info ------
_Wlan_StartSession()
$wlaninterfaces = _Wlan_EnumInterfaces()
$numofint = UBound($wlaninterfaces) - 1
For $antm = 0 To $numofint
	$adapterid = $wlaninterfaces[$antm][0]
	$adapterdesc = $wlaninterfaces[$antm][1]
	_Log("---- OS Info ----")
	_Log(@OSVersion)
	_Log(@OSArch)
	_Log(@OSBuild)
	_Log(@OSType)
	_Log(@OSServicePack)
	_Log("---- Native Wifi Adapter ----")
	_Log($adapterid & "|" & $adapterdesc)
	_Log("---- Native Wifi Networks ----")
	_Wlan_SelectInterface($adapterid)
	$aplist = _Wlan_GetNetworks(False, 0, 0)
	$aplistsize = UBound($aplist) - 1
	For $add = 0 To $aplistsize
		$SSID = $aplist[$add][1]
		$NetworkType = $aplist[$add][2]
		$SecurityEnabled = $aplist[$add][6]
		$Authentication = $aplist[$add][7]
		$Encryption = $aplist[$add][8]
		$RadioType = "802.11" & $aplist[$add][12]
		$Signal = $aplist[$add][5]
		If @OSVersion = "WIN_XP" Then ;WinXP Does not support _Wlan_GetNetworkInfo, so fall back to olf functionality
			$BasicTransferRates = $aplist[$add][11]
			$OtherTransferRates = ""
			$BSSID = $aplist[$add][10]
			_Log($SSID & "|" & $NetworkType & "|" & $SecurityEnabled & "|" & $Authentication & "|" & $Encryption & "|" & $RadioType & "|" & $Signal & "|" & $BasicTransferRates & "|" & $OtherTransferRates & "|" & $BSSID)
		Else
			_Log($SSID & "|" & $NetworkType & "|" & $SecurityEnabled & "|" & $Authentication & "|" & $Encryption & "|" & $RadioType & "|" & $Signal)
		EndIf
	Next
Next

; ----- Get Netsh info ------
_Log("---- Netsh output ----")
$tempfile = @TempDir & "\" & "netshtest.txt"
ConsoleWrite($tempfile & @CRLF)
_RunDos('netsh wlan show networks mode=bssid > "' & $tempfile & '"') ;copy the output of the 'netsh wlan show networks mode=bssid' command to the temp file
;Open netsh temp file and go through it
$netshtempfile = FileOpen($tempfile, 0)
If $netshtempfile <> -1 Then
	$netshfile = FileRead($netshtempfile)
	$netshfile = StringReplace($netshfile, ":" & @CRLF, ":") ;Fix for turkish netsh file
	$TempFileArray = StringSplit($netshfile, @CRLF)

	If IsArray($TempFileArray) Then
		For $stripws = 1 To $TempFileArray[0]
			$TempFileArray[$stripws] = StringStripWS($TempFileArray[$stripws], 3)
		Next
		For $list = 1 To $TempFileArray[0]
			If $TempFileArray[$list] <> "" Then _Log($TempFileArray[$list])
		Next
	EndIf
EndIf

;----- write/dispaly logs -----
FileDelete($log)
FileWrite($log, $logtext)
MsgBox(0, "log", $logtext)


Func _Log($text)
	ConsoleWrite($text & @CRLF)
	$logtext &= $text & @CRLF
EndFunc   ;==>_Log