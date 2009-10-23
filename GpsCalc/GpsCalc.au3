#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#Region ### START Koda GUI section ### Form=c:\users\acalcutt\desktop\gpscalc.kxf
$Form1_1 = GUICreate("GpsCalc - By Andrew Calcutt (10/22/2009)", 539, 196, 192, 124)
$cLat = GUICtrlCreateInput("", 120, 16, 137, 21)
$cLon = GUICtrlCreateInput("", 390, 18, 137, 21)
$Label1 = GUICtrlCreateLabel("Current Latitude:", 8, 20, 82, 17)
$Label2 = GUICtrlCreateLabel("Current Longitude:", 270, 20, 91, 17)
$dLat = GUICtrlCreateInput("", 120, 63, 137, 21)
$dLon = GUICtrlCreateInput("", 390, 65, 137, 21)
$Label3 = GUICtrlCreateLabel("Destination Latitude:", 10, 67, 101, 17)
$Label4 = GUICtrlCreateLabel("Destination Longitude:", 270, 67, 110, 17)
$Calc_Bear_Dist = GUICtrlCreateButton("Calculate Destination Bearing / Distance", 144, 88, 241, 25, $WS_GROUP)
$dBear = GUICtrlCreateInput("", 120, 124, 137, 21)
$dDist = GUICtrlCreateInput("", 390, 126, 137, 21)
$Label5 = GUICtrlCreateLabel("Destination Bearing", 10, 128, 96, 17)
$Label6 = GUICtrlCreateLabel("Destination Distance:", 270, 128, 105, 17)
$Calc_Lat_log = GUICtrlCreateButton("Calculate Destination Latitude / Longitude", 145, 158, 241, 25, $WS_GROUP)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

While 1
$nMsg = GUIGetMsg()
Switch $nMsg
	Case $GUI_EVENT_CLOSE
		Exit
	Case $Calc_Bear_Dist
		$Distance = _DistanceBetweenPoints(GUICtrlRead($cLat), GUICtrlRead($cLon), GUICtrlRead($dLat), GUICtrlRead($dLon))
		$Bearing = _BearingBetweenPoints(GUICtrlRead($cLat), GUICtrlRead($cLon), GUICtrlRead($dLat), GUICtrlRead($dLon))
		GUICtrlSetData($dDist, $Distance)
		GUICtrlSetData($dBear, $Bearing)
	Case $Calc_Lat_log
		$Latitude = _DestLat(GUICtrlRead($cLat), GUICtrlRead($dBear), GUICtrlRead($dDist))
		$Longitude = _DestLon(GUICtrlRead($cLat), GUICtrlRead($cLon), $Latitude, GUICtrlRead($dBear), GUICtrlRead($dDist))
		GUICtrlSetData($dLat, $Latitude)
		GUICtrlSetData($dLon, $Longitude)
EndSwitch
WEnd

Func _DistanceBetweenPoints($Lat1, $Lon1, $Lat2, $Lon2)
	Local $EarthRadius = 6378137 ;meters
	$Lat1 = _deg2rad($Lat1)
	$Lon1 = _deg2rad($Lon1)
	$Lat2 = _deg2rad($Lat2)
	$Lon2 = _deg2rad($Lon2)
	Return (ACos(Sin($Lat1)*Sin($Lat2)+Cos($Lat1)*Cos($Lat2)*Cos($Lon2-$Lon1))*$EarthRadius);Return distance in meters
EndFunc   ;==>_DistanceBetweenPoints

Func _BearingBetweenPoints($Lat1, $Lon1, $Lat2, $Lon2)
	$Lat1 = _deg2rad($Lat1)
	$Lon1 = _deg2rad($Lon1)
	$Lat2 = _deg2rad($Lat2)
	$Lon2 = _deg2rad($Lon2)
	Return (_rad2deg(_ATAN2(COS($Lat1)*SIN($Lat2)-SIN($Lat1)*COS($Lat2)*COS($Lon2-$Lon1), SIN($Lon2-$Lon1)*COS($Lat2))));Return bearing in degrees
EndFunc   ;==>_DistanceBetweenPoints

Func _DestLat($Lat1, $Brng1, $Dist1)
	Local $EarthRadius = 6378137 ;meters
	$Lat1 = _deg2rad($Lat1)
	$Brng1 = _deg2rad($Brng1)
	Return(StringFormat('%0.7f', _rad2deg(ASIN(SIN($Lat1)*COS($Dist1/$EarthRadius) + COS($Lat1)*SIN($Dist1/$EarthRadius)*COS($Brng1)))));Return destination decimal latitude
EndFunc

Func _DestLon($Lat1, $Lon1, $Lat2, $Brng1, $Dist1)
	Local $EarthRadius = 6378137 ;meters
	$Lat1 = _deg2rad($Lat1)
	$Lon1 = _deg2rad($Lon1)
	$Lat2 = _deg2rad($Lat2)
	$Brng1 = _deg2rad($Brng1)
	Return(StringFormat('%0.7f', _rad2deg($Lon1+_ATAN2(COS($Dist1/$EarthRadius)-SIN($Lat1)*SIN($Lat2), SIN($Brng1)*SIN($Dist1/$EarthRadius)*COS($Lat1)))));Return destination decimal longitude
EndFunc

;---------------------------------------------------------------------------------------
;Math Functions
;---------------------------------------------------------------------------------------
Func _deg2rad($Degree) ;convert degrees to radians
	Local $PI = 3.14159265358979
	$Degree = StringReplace(StringReplace(StringReplace(StringReplace(StringReplace($Degree, 'W', '-'), 'E', ''), 'S', '-'), 'N', ''), ' ', '')
	Return ($Degree * ($PI / 180))
EndFunc   ;==>_deg2rad

Func _rad2deg($radian) ;convert radians to degrees
	Local $PI = 3.14159265358979
	Return ($radian * (180 / $PI))
EndFunc   ;==>_rad2deg

Func _ATan2($x, $y) ;ATan2 function, since autoit only has ATan
	Local Const $PI = 3.14159265358979
	If $y < 0 Then
		Return -_ATan2($x, -$y)
	ElseIf $x < 0 Then
		Return $Pi - ATan(-$y / $x)
	ElseIf $x > 0 Then
		Return ATan($y / $x)
	ElseIf $y <> 0 Then
		Return $Pi / 2
	Else
		MsgBox( 16, "Error - Division by zero", "Domain Error in Function: ATan2()" & @LF & "$x and $y cannot both equal zero" )
		SetError( 1 )
	EndIf
EndFunc


