Func _GoogleEarth_Initialize()
	Local $oGoogleEarth = ObjCreate("GoogleEarth.ApplicationGE")
	If @error <> 1 Then
		While 1
			If $oGoogleEarth.IsOnline() = 1 Or $oGoogleEarth.IsInitialized() = 1 Then ExitLoop
		WEnd
		Return ($oGoogleEarth)
	Else
		SetError(1)
	EndIf
EndFunc   ;==>GoogleEarth_Initialize

Func _GoogleEarth_GetPointonTerrain($oGoogleEarth, $x, $y)
	Local $opointOnTerrain = $oGoogleEarth.GetPointOnTerrainFromScreenCoords($x, $y)
	Local $PointArr[3]
	$PointArr[0] = $opointOnTerrain.latitude
	$PointArr[1] = $opointOnTerrain.longitude
	$PointArr[2] = $opointOnTerrain.Altitude
	Return($PointArr)
EndFunc   ;==>GoogleEarth_GetPointonTerrain

Func _GoogleEarth_ZoomTo($oGoogleEarth, $N, $W, $alt, $range, $tilt, $az, $mode = 1, $speed = 5.0)
	$oGoogleEarth.SetCameraParams($N, $W, $alt, $mode, $range, $tilt, $az, $speed) ; zoom to a custom locus
EndFunc   ;==>GoogleEarth_ZoomTo

Func _GoogleEarth_ScreenShot($oGoogleEarth, $directory, $quality = 100)
	$oGoogleEarth.SaveScreenShot($directory, $quality) ; take a snapshot
EndFunc   ;==>GoogleEarth_ScreenShot

Func _GoogleEarth_OpenKmlFile($oGoogleEarth, $fileName, $suppressMessages = True)
	$oGoogleEarth.OpenKmlFile($fileName, $suppressMessages)
EndFunc   ;==>GoogleEarth_OpenKmlFile

Func _GoogleEarth_LoadKmlData($oGoogleEarth, $kmlData)
	$oGoogleEarth.LoadKmlData($kmlData)
EndFunc   ;==>GoogleEarth_LoadKmlData

Func _GoogleEarth_GetCameraInfo($oGoogleEarth, $considerTerrain = True)
	Local $oCameraInfo = $oGoogleEarth.GetCamera($considerTerrain)
	Local $CamDataArr[7]
	$CamDataArr[0] = $oCameraInfo.FocusPointLatitude
	$CamDataArr[1] = $oCameraInfo.FocusPointLongitude
	$CamDataArr[2] = $oCameraInfo.FocusPointAltitude
	$CamDataArr[3] = $oCameraInfo.FocusPointAltitudeMode
	$CamDataArr[4] = $oCameraInfo.Range
	$CamDataArr[5] = $oCameraInfo.Tilt
	$CamDataArr[6] = $oCameraInfo.Azimuth
	Return $CamDataArr
EndFunc   ;==>GoogleEarth_GetCameraInfo