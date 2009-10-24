Opt("GUIOnEventMode", 1);Change to OnEvent mode
;--------------------------------------------------------
;AutoIt Version: v3.3.0.0
$Script_Author = 'Andrew Calcutt'
$Script_Name = 'Mysticache'
$Script_Website = 'http://www.techidiots.net'
$version = 'v0.7'
$Script_Start_Date = '2009/10/22'
$last_modified = '2009/10/24'
$title = $Script_Name & ' ' & $version & ' - By ' & $Script_Author & ' - ' & $last_modified
;Includes------------------------------------------------
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <GDIPlus.au3>
#include "UDFs\cfxUDF.au3"
;Variables-----------------------------------------------
Dim $OpenedPort
Dim $UseGPS = 0
Dim $TurnOffGPS = 0
Dim $CompassOpen = 0
Dim $GpsDetailsOpen = 0
Dim $DestSet = 0
Dim $RefreshLoopTime = 500
Dim $SoundDir = @ScriptDir & '\Sounds\'
Dim $ErrorFlag_sound = 'error.wav'
Dim $GpsDetailsGUI
Dim $GPGGA_Update
Dim $GPRMC_Update
Dim $disconnected_time

Dim $StartLat = '0.0000000'
Dim $StartLon = '0.0000000'
Dim $DestLat = '0.0000000'
Dim $DestLon = '0.0000000'
Dim $Latitude = '0.0000000'
Dim $Longitude = '0.0000000'
Dim $Latitude2 = '0.0000000'
Dim $Longitude2 = '0.0000000'
Dim $LatitudeWifidb = '0.0000000'
Dim $LongitudeWifidb = '0.0000000'
Dim $NumberOfSatalites = '00'
Dim $HorDilPitch = '0'
Dim $Alt = '0'
Dim $AltS = 'M'
Dim $Geo = '0'
Dim $GeoS = 'M'
Dim $SpeedInKnots = '0'
Dim $SpeedInMPH = '0'
Dim $SpeedInKmH = '0'
Dim $TrackAngle = '0'

Dim $FixTime, $FixTime2, $FixDate, $Quality
Dim $Temp_FixTime, $Temp_FixTime2, $Temp_FixDate, $Temp_Lat, $Temp_Lon, $Temp_Lat2, $Temp_Lon2, $Temp_Quality, $Temp_NumberOfSatalites, $Temp_HorDilPitch, $Temp_Alt, $Temp_AltS, $Temp_Geo, $Temp_GeoS, $Temp_Status, $Temp_SpeedInKnots, $Temp_SpeedInMPH, $Temp_SpeedInKmH, $Temp_TrackAngle
Dim $CompassGraphic, $CompassGUI, $CompassBack, $CompassHeight, $CircleX, $CircleY, $north, $south, $east, $west
Dim $GpsCurrentDataGUI, $GPGGA_Time, $GPGGA_Lat, $GPGGA_Lon, $GPGGA_Quality, $GPGGA_Satalites, $GPGGA_HorDilPitch, $GPGGA_Alt, $GPGGA_Geo, $GPRMC_Time, $GPRMC_Date, $GPRMC_Lat, $GPRMC_Lon, $GPRMC_Status, $GPRMC_SpeedKnots, $GPRMC_SpeedMPH, $GPRMC_SpeedKmh, $GPRMC_TrackAngle

Dim $settings = @ScriptDir & '\Settings.ini'
Dim $ComPort = IniRead($settings, 'GpsSettings', 'ComPort', '4')
Dim $BAUD = IniRead($settings, 'GpsSettings', 'Baud', '4800')
Dim $PARITY = IniRead($settings, 'GpsSettings', 'Parity', 'N')
Dim $DATABIT = IniRead($settings, 'GpsSettings', 'DataBit', '8')
Dim $STOPBIT = IniRead($settings, 'GpsSettings', 'StopBit', '1')
Dim $GpsTimeout = IniRead($settings, 'GpsSettings', 'GpsTimeout', 30000)

Dim $BackgroundColor = IniRead($settings, 'Colors', 'BackgroundColor', '0x99B4A1')
Dim $ControlBackgroundColor = IniRead($settings, 'Colors', 'ControlBackgroundColor', '0xD7E4C2')
Dim $TextColor = IniRead($settings, 'Colors', 'TextColor', '0x000000')

Dim $RadStartGpsCurPos = IniRead($settings, 'StartGPS', 'Rad_StartGPS_CurrentPos', '4')
Dim $RadStartGpsLatLon = IniRead($settings, 'StartGPS', 'Rad_StartGPS_LatLon', '1')
Dim $DcLat = IniRead($settings, 'StartGPS', 'cLat', '')
Dim $DcLon = IniRead($settings, 'StartGPS', 'cLon', '')

Dim $RadDestGPSLatLon = IniRead($settings, 'DestGPS', 'Rad_DestGPS_LatLon', '1')
Dim $RadDestGPSBrngDist = IniRead($settings, 'DestGPS', 'Rad_DestGPS_BrngDist', '4')
Dim $DdLat = IniRead($settings, 'DestGPS', 'dLat', '')
Dim $DdLon = IniRead($settings, 'DestGPS', 'dLon', '')
Dim $DdBrng = IniRead($settings, 'DestGPS', 'dBrng', '')
Dim $DdDist = IniRead($settings, 'DestGPS', 'dDist', '')

Dim $CompassPosition = IniRead($settings, 'WindowPositions', 'CompassPosition', '')
Dim $GpsDetailsPosition = IniRead($settings, 'WindowPositions', 'GpsDetailsPosition', '')

;-------------------------------------------------------------------------------------------------------------------------------
;                                                       Program GUI
;-------------------------------------------------------------------------------------------------------------------------------

$MysticacheGUI = GUICreate($title, 414, 448, -1, -1, BitOR($WS_OVERLAPPEDWINDOW, $WS_CLIPSIBLINGS))
GUISetBkColor($BackgroundColor)
;Set Window Position
$a = WinGetPos($MysticacheGUI);Get window current position
Dim $State = IniRead($settings, 'WindowPositions', 'State', "Window");Get last window position from the ini file
Dim $Position = IniRead($settings, 'WindowPositions', 'Position', $a[0] & ',' & $a[1] & ',' & $a[2] & ',' & $a[3])
Dim $winpos_old, $winpos
$b = StringSplit($Position, ",")
If $State = "Maximized" Then
	WinSetState($title, "", @SW_MAXIMIZE)
Else
	WinMove($title, "", $b[1], $b[2], $b[3], $b[4]);Resize window to ini value
EndIf
;GPS Settings
$But_UseGPS = GUICtrlCreateButton("Use GPS", 16, 15, 97, 20, $WS_GROUP)
GUICtrlCreateLabel("Com Port:", 136, 20, 50, 17)
$CommPort = GUICtrlCreateCombo("1", 185, 15, 80, 25)
GUICtrlSetData(-1, "2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20", $ComPort)
GUICtrlCreateLabel("Baud:", 275, 20, 32, 17)
$CommBaud = GUICtrlCreateCombo("4800", 320, 15, 80, 25)
GUICtrlSetData(-1, "9600|14400|19200|38400|57600|115200", $BAUD)
GUICtrlCreateLabel("Stop Bit:", 16, 52, 44, 17)
$CommBit = GUICtrlCreateCombo("1", 64, 47, 80, 25)
GUICtrlSetData(-1, "1.5|2", $STOPBIT)
GUICtrlCreateLabel("Parity:", 148, 52, 33, 17)
If $PARITY = 'E' Then
	$l_PARITY = 'Even'
ElseIf $PARITY = 'M' Then
	$l_PARITY = 'Mark'
ElseIf $PARITY = 'O' Then
	$l_PARITY = 'Odd'
ElseIf $PARITY = 'S' Then
	$l_PARITY = 'Space'
Else
	$l_PARITY = 'None'
EndIf
$CommParity = GUICtrlCreateCombo("None", 185, 47, 80, 25)
GUICtrlSetData(-1, 'Even|Mark|Odd|Space', $l_PARITY)
GUICtrlCreateLabel("Data Bit:", 275, 52, 45, 17)
$CommDataBit = GUICtrlCreateCombo("4", 320, 47, 80, 25)
GUICtrlSetData(-1, "5|6|7|8", $DATABIT)
;Start GPS Settings
$Grp_StartGPS = GUICtrlCreateGroup("Start GPS Position", 16, 80, 385, 89)
$Rad_StartGPS_CurrentPos = GUICtrlCreateRadio("Current GPS Position", 31, 105, 120, 17)
If $RadStartGpsCurPos = 1 Then GUICtrlSetState($Rad_StartGPS_CurrentPos, $GUI_CHECKED)
$Rad_StartGPS_LatLon = GUICtrlCreateRadio("", 31, 135, 17, 17)
If $RadStartGpsLatLon = 1 Then GUICtrlSetState($Rad_StartGPS_LatLon, $GUI_CHECKED)
$cLat = GUICtrlCreateInput($DcLat, 95, 135, 100, 21)
GUICtrlCreateLabel("Latitude:", 48, 139, 45, 17)
$cLon = GUICtrlCreateInput($DcLon, 258, 136, 100, 21)
GUICtrlCreateLabel("Longitude:", 205, 138, 54, 17)
;Dest GPS Settings
$Grp_DestGPS = GUICtrlCreateGroup("Destination GPS Position", 16, 184, 385, 125)
$Rad_DestGPS_LatLon = GUICtrlCreateRadio("", 31, 211, 17, 17)
If $RadDestGPSLatLon = 1 Then GUICtrlSetState($Rad_DestGPS_LatLon, $GUI_CHECKED)
GUICtrlCreateLabel("Latitude:", 48, 214, 45, 17)
$dLat = GUICtrlCreateInput($DdLat, 95, 209, 100, 21)
GUICtrlCreateLabel("Longitude:", 205, 214, 54, 17)
$dLon = GUICtrlCreateInput($DdLon, 261, 209, 100, 21)
$Rad_DestGPS_BrngDist = GUICtrlCreateRadio("", 31, 244, 17, 17)
If $RadDestGPSBrngDist = 1 Then GUICtrlSetState($Rad_DestGPS_BrngDist, $GUI_CHECKED)
GUICtrlCreateLabel("Bearing:", 48, 247, 43, 17)
$dBrng = GUICtrlCreateInput($DdBrng, 95, 242, 100, 21)
GUICtrlCreateLabel("Distance:", 205, 247, 49, 17)
$dDist = GUICtrlCreateInput($DdDist, 261, 242, 100, 21)
$But_SetDestination = GUICtrlCreateButton("Set Desination", 104, 272, 201, 25, $WS_GROUP)
;Route Info
$Lab_StartGPS = GUICtrlCreateLabel("", 15, 320, 388, 15)
$Lab_DestGPS = GUICtrlCreateLabel("Dest GPS:     Not Set Yet", 15, 340, 388, 15)
$Lab_BrngDist = GUICtrlCreateLabel("", 15, 360, 388, 15)
$Lab_GpsInfo = GUICtrlCreateLabel("", 15, 380, 388, 15)
$But_OpenCompass = GUICtrlCreateButton("Open Compass", 40, 415, 100, 25, $WS_GROUP)
$But_OpenGpsDetails = GUICtrlCreateButton("Open GPS Details", 150, 415, 100, 25, $WS_GROUP)
$But_Exit = GUICtrlCreateButton("Exit", 260, 415, 110, 25, $WS_GROUP)

GUISetOnEvent($GUI_EVENT_CLOSE, '_Exit')
GUICtrlSetOnEvent($But_UseGPS, '_GpsToggle')
GUICtrlSetOnEvent($But_SetDestination, '_SetDestination')
GUICtrlSetOnEvent($But_OpenCompass, '_CompassGUI')
GUICtrlSetOnEvent($But_OpenGpsDetails, '_OpenGpsDetailsGUI')
GUICtrlSetOnEvent($But_Exit, '_Exit')

GUISetState(@SW_SHOW)

;-------------------------------------------------------------------------------------------------------------------------------
;                                                       Program Running Loop
;-------------------------------------------------------------------------------------------------------------------------------

While 1
	If $UseGPS =  1 Then _GetGPS()
	If GUICtrlRead($Rad_StartGPS_CurrentPos) = 1 Then
		$StartLat = StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($Latitude), 'S', '-'), 'N', ''), ' ', '')
		$StartLon = StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($Longitude), 'W', '-'), 'E', ''), ' ', '')
		ConsoleWrite($Latitude & '-' & $Longitude & @CRLF)
		;$StartBrng = $TrackAngle
	ElseIf GUICtrlRead($Rad_StartGPS_LatLon) = 1 Then
		$StartLat = GUICtrlRead($cLat)
		$StartLon = GUICtrlRead($cLon)
		;$StartBrng = $cBear
	EndIf
	$DestBrng = _BearingBetweenPoints($StartLat, $StartLon, $DestLat, $DestLon)
	$DestDist = _DistanceBetweenPoints($StartLat, $StartLon, $DestLat, $DestLon)
	GUICtrlSetData($Lab_StartGPS, 'Start GPS:     Latitude: ' & StringFormat('%0.7f', $StartLat) & '     Longitude: ' & StringFormat('%0.7f', $StartLon))
	If $DestSet = 1 Then GUICtrlSetData($Lab_BrngDist, 'Bearing: ' & StringFormat('%0.1f', $DestBrng) & ' degrees     Distance: ' & StringFormat('%0.1f', $DestDist) & ' meters')

	If $UseGPS = 1 And GUICtrlRead($Rad_StartGPS_CurrentPos) = 1 Then
		_DrawCompassLine($DestBrng, $TrackAngle)
	Else
		_DrawCompassLine($DestBrng)
	EndIf

	;Check Mysticache Window Position
	_WinMoved()

	;Check Compass Window Position
	If WinActive($CompassGUI) And $CompassOpen = 1  Then
		$c = WinGetPos($CompassGUI)
		If $c[0] & ',' & $c[1] & ',' & $c[2] & ',' & $c[3] <> $CompassPosition Then $CompassPosition = $c[0] & ',' & $c[1] & ',' & $c[2] & ',' & $c[3] ;If the $CompassGUI has moved or resized, set $CompassPosition to current window size
	EndIf

	;Check GPS Details Windows Position
	If WinActive($GpsDetailsGUI) And $GpsDetailsOpen = 1 Then
		$g = WinGetPos($GpsDetailsGUI)
		If $g[0] & ',' & $g[1] & ',' & $g[2] & ',' & $g[3] <> $GpsDetailsPosition Then $GpsDetailsPosition = $g[0] & ',' & $g[1] & ',' & $g[2] & ',' & $g[3] ;If the $GpsDetails has moved or resized, set $GpsDetailsPosition to current window size
	EndIf

	If $TurnOffGPS = 1 Then _TurnOffGPS()
	Sleep($RefreshLoopTime)

WEnd

;-------------------------------------------------------------------------------------------------------------------------------
;                                                       PROGRAM FUNCTIONS
;-------------------------------------------------------------------------------------------------------------------------------

Func _Exit()
	_SaveSettings()
	Exit
EndFunc   ;==>_Exit

Func _SetDestination()
	If GUICtrlRead($Rad_DestGPS_LatLon) = 1 Then
		$DestLat = GUICtrlRead($dLat)
		$DestLon = GUICtrlRead($dLon)
	ElseIf GUICtrlRead($Rad_DestGPS_BrngDist) = 1 Then
		$DestLat = _DestLat($StartLat, GUICtrlRead($dBrng), GUICtrlRead($dDist))
		$DestLon = _DestLon($StartLat, $StartLon, $DestLat, GUICtrlRead($dBrng), GUICtrlRead($dDist))
	Else
		$DestLat = '0.0000000'
		$DestLon = '0.0000000'
	EndIf
	GUICtrlSetData($Lab_DestGPS, 'Dest GPS:     Latitude: ' & StringFormat('%0.7f', $DestLat) & '     Longitude: ' & StringFormat('%0.7f',$DestLon))
	$DestSet = 1
EndFunc   ;==>_SetDestination

Func _WinMoved();Checks if window has moved. Returns 1 if it has
	$a = WinGetPos($MysticacheGUI)
	$winpos_old = $winpos
	$winpos = $a[0] & $a[1] & $a[2] & $a[3] & WinGetState($title, "")

	If $winpos_old <> $winpos Then
		;Set window state and position
		$winstate = WinGetState($title, "")
		If BitAND($winstate, 32) Then;Set
			$State = "Maximized"
		Else
			$State = "Window"
			$Position = $a[0] & ',' & $a[1] & ',' & $a[2] & ',' & $a[3]
		EndIf
		Return 1 ;Set Flag that window moved
	Else
		Return 0 ;Set Flag that window did not move
	EndIf
EndFunc   ;==>_WinMoved

Func _SaveSettings()
	IniWrite($settings, 'WindowPositions', 'State', $State)
	IniWrite($settings, 'WindowPositions', 'Position', $Position)
	IniWrite($settings, 'WindowPositions', 'CompassPosition', $CompassPosition)
	IniWrite($settings, 'WindowPositions', 'GpsDetailsPosition', $GpsDetailsPosition)

	IniWrite($settings, 'Colors', 'BackgroundColor', $BackgroundColor)
	IniWrite($settings, 'Colors', 'ControlBackgroundColor', $ControlBackgroundColor)
	IniWrite($settings, 'Colors', 'TextColor', $TextColor)

	IniWrite($settings, 'GpsSettings', 'ComPort', GUICtrlRead($CommPort))
	IniWrite($settings, 'GpsSettings', 'Baud', GUICtrlRead($CommBaud))
	IniWrite($settings, 'GpsSettings', 'Parity', GUICtrlRead($CommParity))
	IniWrite($settings, 'GpsSettings', 'DataBit', GUICtrlRead($CommDataBit))
	IniWrite($settings, 'GpsSettings', 'StopBit', GUICtrlRead($CommBit))
	IniWrite($settings, 'GpsSettings', 'GpsTimeout', $GpsTimeout)

	IniWrite($settings, 'StartGPS', 'Rad_StartGPS_CurrentPos', GUICtrlRead($Rad_StartGPS_CurrentPos))
	IniWrite($settings, 'StartGPS', 'Rad_StartGPS_LatLon', GUICtrlRead($Rad_StartGPS_LatLon))
	IniWrite($settings, 'StartGPS', 'cLat', GUICtrlRead($cLat))
	IniWrite($settings, 'StartGPS', 'cLon', GUICtrlRead($cLon))

	IniWrite($settings, 'DestGPS', 'Rad_DestGPS_LatLon', GUICtrlRead($Rad_DestGPS_LatLon))
	IniWrite($settings, 'DestGPS', 'Rad_DestGPS_BrngDist', GUICtrlRead($Rad_DestGPS_BrngDist))
	IniWrite($settings, 'DestGPS', 'dLat', GUICtrlRead($dLat))
	IniWrite($settings, 'DestGPS', 'dLon', GUICtrlRead($dLon))
	IniWrite($settings, 'DestGPS', 'dBrng', GUICtrlRead($dBrng))
	IniWrite($settings, 'DestGPS', 'dDist', GUICtrlRead($dDist))
EndFunc

;-------------------------------------------------------------------------------------------------------------------------------
;                                                       GPS FUNCTIONS
;-------------------------------------------------------------------------------------------------------------------------------

Func _GpsToggle();Turns GPS on or off
	If $UseGPS = 1 Then
		$TurnOffGPS = 1
	Else
		$openport = _OpenComPort(GUICtrlRead($CommPort), GUICtrlRead($CommBaud), GUICtrlRead($CommParity), GUICtrlRead($CommDataBit), GUICtrlRead($CommBit));Open The GPS COM port
		If $openport = 1 Then
			$UseGPS = 1
			GUICtrlSetData($But_UseGPS, "Stop GPS")
			$GPGGA_Update = TimerInit()
			$GPRMC_Update = TimerInit()
		Else
			$UseGPS = 0
		EndIf
	EndIf
EndFunc   ;==>_GpsToggle

Func _TurnOffGPS();Turns off GPS, resets variable\
	$UseGPS = 0
	$TurnOffGPS = 0
	$disconnected_time = -1
	$Latitude = 'N 0.0000'
	$Longitude = 'E 0.0000'
	$Latitude2 = 'N 0.0000'
	$Longitude2 = 'E 0.0000'
	$NumberOfSatalites = '00'
	$HorDilPitch = '0'
	$Alt = '0'
	$AltS = 'M'
	$Geo = '0'
	$GeoS = 'M'
	$SpeedInKnots = '0'
	$SpeedInMPH = '0'
	$SpeedInKmH = '0'
	$TrackAngle = '0'
	_CloseComPort(GUICtrlRead($CommPort)) ;Close The GPS COM port
	GUICtrlSetData($But_UseGPS, "Use GPS")
	GUICtrlSetData($Lab_GpsInfo, "")
EndFunc   ;==>_TurnOffGPS

Func _OpenComPort($CommPort = '8', $sBAUD = '4800', $sPARITY = 'N', $sDataBit = '8', $sStopBit = '1', $sFlow = '0');Open specified COM port
	If $sPARITY = 'O' Then ;Odd
		$iPar = '1'
	ElseIf $sPARITY = 'E' Then ;Even
		$iPar = '2'
	ElseIf $sPARITY = 'M' Then ;Mark
		$iPar = '3'
	ElseIf $sPARITY = 'S' Then ;Space
		$iPar = '4'
	Else
		$iPar = '0';None
	EndIf
	If $sStopBit = '1' Then
		$iStop = '0'
	ElseIf $sStopBit = '1.5' Then
		$iStop = '1'
	ElseIf $sStopBit = '2' Then
		$iStop = '2'
	EndIf
	$OpenedPort = _OpenComm($CommPort, $sBAUD, $sDataBit, $iPar, $iStop)
	If $OpenedPort = '-1' Then
		Return (0)
	Else
		Return (1)
	EndIf
EndFunc   ;==>_OpenComPort

Func _CloseComPort($CommPort = '8');Closes specified COM port
	_CloseComm($OpenedPort)
EndFunc   ;==>_CloseComPort

Func _CheckGpsChecksum($checkdata);Checks if GPS Data Checksum is correct. Returns 1 if it is correct, else Returns 0
	$end = 0
	$calc_checksum = 0
	$checkdata_checksum = ''
	$gps_data_split = StringSplit($checkdata, '');Seperate all characters of data and put them into an array
	For $gds = 1 To $gps_data_split[0]
		If $gps_data_split[$gds] <> '$' And $gps_data_split[$gds] <> '*' And $end = 0 Then
			If $calc_checksum = 0 Then ;If $calc_checksum is equal 0, set $calc_checksum to the ascii value of this character
				$calc_checksum = Asc($gps_data_split[$gds])
			Else;If $calc_checksum is not equal 0 then XOR the new character ascii value with the $calc_checksum value
				$calc_checksum = BitXOR($calc_checksum, Asc($gps_data_split[$gds]))
			EndIf
		ElseIf $gps_data_split[$gds] = '*' Then ;If the checksum has been reached, set the $end flag
			$end = 1
		ElseIf $end = 1 And StringIsAlNum($gps_data_split[$gds]) Then ;if the end flag is equal 1 and the character is alpha-numeric then add the character to the end of $checkdata_checksum
			$checkdata_checksum &= $gps_data_split[$gds]
		EndIf
	Next
	$calc_checksum = Hex($calc_checksum, 2)
	If $calc_checksum = $checkdata_checksum Then ;If the calculated checksum matches the given checksum then Return 1, Else Return 0
		Return (1)
	Else
		Return (0)
	EndIf
EndFunc   ;==>_CheckGpsChecksum

Func _GPGGA($data);Strips data from a gps $GPGGA data string
	GUICtrlSetData($Lab_GpsInfo, $data)
	If _CheckGpsChecksum($data) = 1 Then
		$GPGGA_Split = StringSplit($data, ",");
		If $GPGGA_Split[0] >= 14 Then
			$Temp_Quality = $GPGGA_Split[7]
			If BitOR($Temp_Quality = 1, $Temp_Quality = 2) = 1 Then
				$Temp_FixTime = _FormatGpsTime($GPGGA_Split[2])
				$Temp_Lat = $GPGGA_Split[4] & " " & StringFormat('%0.4f', $GPGGA_Split[3]);_FormatLatLon($GPGGA_Split[3], $GPGGA_Split[4])
				$Temp_Lon = $GPGGA_Split[6] & " " & StringFormat('%0.4f', $GPGGA_Split[5]);_FormatLatLon($GPGGA_Split[5], $GPGGA_Split[6])
				$Temp_NumberOfSatalites = $GPGGA_Split[8]
				$Temp_HorDilPitch = $GPGGA_Split[9]
				$Temp_Alt = $GPGGA_Split[10] * 3.2808399
				$Temp_AltS = $GPGGA_Split[11]
				$Temp_Geo = $GPGGA_Split[12]
				$Temp_GeoS = $GPGGA_Split[13]
			EndIf
		EndIf
	EndIf
EndFunc   ;==>_GPGGA

Func _GPRMC($data);Strips data from a gps $GPRMC data string
	GUICtrlSetData($Lab_GpsInfo, $data)
	If _CheckGpsChecksum($data) = 1 Then
		$GPRMC_Split = StringSplit($data, ",")
		If $GPRMC_Split[0] >= 11 Then
			$Temp_Status = $GPRMC_Split[3]
			If $Temp_Status = "A" Then
				$Temp_FixTime2 = _FormatGpsTime($GPRMC_Split[2])
				$Temp_Lat2 = $GPRMC_Split[5] & ' ' & StringFormat('%0.4f', $GPRMC_Split[4]) ;_FormatLatLon($GPRMC_Split[4], $GPRMC_Split[5])
				$Temp_Lon2 = $GPRMC_Split[7] & ' ' & StringFormat('%0.4f', $GPRMC_Split[6]) ;_FormatLatLon($GPRMC_Split[6], $GPRMC_Split[7])
				$Temp_SpeedInKnots = $GPRMC_Split[8]
				$Temp_SpeedInMPH = Round($GPRMC_Split[8] * 1.15, 2)
				$Temp_SpeedInKmH = Round($GPRMC_Split[8] * 1.85200, 2)
				$Temp_TrackAngle = $GPRMC_Split[9]
				$Temp_FixDate = _FormatGpsDate($GPRMC_Split[10])
			EndIf
		EndIf
	EndIf
EndFunc   ;==>_GPRMC

Func _GetGPS(); Recieves data from gps device
	$timeout = TimerInit()
	$return = 1
	$FoundData = 0

	$maxtime = $RefreshLoopTime * 0.8; Set GPS timeout to 80% of the given timout time
	If $maxtime < 800 Then $maxtime = 800;Set GPS timeout to 800 if it is under that

	Dim $Temp_FixTime, $Temp_FixTime2, $Temp_FixDate, $Temp_Lat, $Temp_Lon, $Temp_Lat2, $Temp_Lon2, $Temp_Quality, $Temp_NumberOfSatalites, $Temp_HorDilPitch, $Temp_Alt, $Temp_AltS, $Temp_Geo, $Temp_GeoS, $Temp_Status, $Temp_SpeedInKnots, $Temp_SpeedInMPH, $Temp_SpeedInKmH, $Temp_TrackAngle
	Dim $Temp_Quality = 0, $Temp_Status = "V"

	While 1 ;Loop to extract gps data untill location is found or timout time is reached
		If $UseGPS = 0 Then ExitLoop
		$gstring = StringStripWS(_rxwait($OpenedPort, '1000', $maxtime), 8);Read data line from GPS
		$dataline = $gstring; & $LastGpsString
		$LastGpsString = $gstring
		If StringInStr($dataline, '$') And StringInStr($dataline, '*') Then
			$FoundData = 1
			$dlsplit = StringSplit($dataline, '$')
			For $gda = 1 To $dlsplit[0]
				;If $GpsDetailsOpen = 1 Then GUICtrlSetData($GpsCurrentDataGUI, $dlsplit[$gda]);Show data line in "GPS Details" GUI if it is open
				If StringInStr($dlsplit[$gda], '*') Then ;Check if string containts start character ($) and checsum character (*). If it does not have them, ignore the data

					If StringInStr($dlsplit[$gda], "GPGGA") Then
						_GPGGA($dlsplit[$gda]);Split GPGGA data from data string
						$disconnected_time = -1
					ElseIf StringInStr($dlsplit[$gda], "GPRMC") Then
						_GPRMC($dlsplit[$gda]);Split GPRMC data from data string
						$disconnected_time = -1
					EndIf
				EndIf

			Next
		EndIf
		;If BitOR($Temp_Quality = 1, $Temp_Quality = 2) = 1 And BitOR($Temp_Status = "A", $GpsDetailsOpen <> 1) Then ExitLoop;If $Temp_Quality = 1 (GPS has a fix) And, If the details window is open, $Temp_Status = "A" (Active data, not Void)
		If BitOR($Temp_Quality = 1, $Temp_Quality = 2) = 1 And $Temp_Status = "A" Then ExitLoop;If $Temp_Quality = 1 (GPS has a fix) And, If the details window is open, $Temp_Status = "A" (Active data, not Void)
		If TimerDiff($timeout) > $maxtime Then ExitLoop;If time is over timeout period, exitloop
	WEnd
	ConsoleWrite($Temp_Lat & '-' & $Temp_Lon & @CRLF)
	ConsoleWrite($FoundData & '-' & $Temp_Quality & @CRLF)
	If $FoundData = 1 Then
		$disconnected_time = -1
		If BitOR($Temp_Quality = 1, $Temp_Quality = 2) = 1 Then ;If the GPGGA data has a fix(1) then write data to perminant variables
			If $FixTime <> $Temp_FixTime Then $GPGGA_Update = TimerInit()
			$FixTime = $Temp_FixTime
			$Latitude = $Temp_Lat
			$Longitude = $Temp_Lon
			$NumberOfSatalites = $Temp_NumberOfSatalites
			$HorDilPitch = $Temp_HorDilPitch
			$Alt = $Temp_Alt
			$AltS = $Temp_AltS
			$Geo = $Temp_Geo
			$GeoS = $Temp_GeoS
		EndIf
		If $Temp_Status = "A" Then ;If the GPRMC data is Active(A) then write data to perminant variables
			If $FixTime2 <> $Temp_FixTime2 Then $GPRMC_Update = TimerInit()
			$FixTime2 = $Temp_FixTime2
			$Latitude2 = $Temp_Lat2
			$Longitude2 = $Temp_Lon2
			$SpeedInKnots = $Temp_SpeedInKnots
			$SpeedInMPH = $Temp_SpeedInMPH
			$SpeedInKmH = $Temp_SpeedInKmH
			$TrackAngle = $Temp_TrackAngle
			$FixDate = $Temp_FixDate
		EndIf
	Else
		If $disconnected_time = -1 Then $disconnected_time = TimerInit()
		If TimerDiff($disconnected_time) > 10000 Then ; If nothing has been found in the buffer for 10 seconds, turn off gps
			$disconnected_time = -1
			$return = 0
			_TurnOffGPS()
			SoundPlay($SoundDir & $ErrorFlag_sound, 0)
		EndIf
	EndIf

	_ClearGpsDetailsGUI();Reset variables if they are over the allowed timeout
	_UpdateGpsDetailsGUI();Write changes to "GPS Details" GUI if it is open
	;_DrawCompassLine($TrackAngle)
	Return ($return)
EndFunc   ;==>_GetGPS

Func _Format_GPS_DMM_to_DDD($gps);converts gps position from ddmm.mmmm to dd.ddddddd
	$return = '0.0000000'
	$splitlatlon1 = StringSplit($gps, " ");Split N,S,E,W from data
	If $splitlatlon1[0] = 2 Then
		$splitlatlon2 = StringSplit($splitlatlon1[2], ".");Split dd from data
		$latlonleft = StringTrimRight($splitlatlon2[1], 2)
		$latlonright = (StringTrimLeft($splitlatlon2[1], StringLen($splitlatlon2[1]) - 2) & '.' & $splitlatlon2[2]) / 60
		$return = $splitlatlon1[1] & ' ' & StringFormat('%0.7f', $latlonleft + $latlonright);set return
	EndIf
	Return ($return)
EndFunc   ;==>_Format_GPS_DMM_to_DDD

Func _FormatGpsTime($time)
	$time = StringTrimRight($time, 4)
	$h = StringTrimRight($time, 4)
	$m = StringTrimLeft(StringTrimRight($time, 2), 2)
	$s = StringTrimLeft($time, 4)
	If $h > 12 Then
		$h = $h - 12
		$l = "PM"
	Else
		$l = "AM"
	EndIf
	Return ($h & ":" & $m & ":" & $s & $l & ' (UTC)')
EndFunc   ;==>_FormatGpsTime

Func _FormatGpsDate($Date)
	$d = StringTrimRight($Date, 4)
	$m = StringTrimLeft(StringTrimRight($Date, 2), 2)
	$y = StringTrimLeft($Date, 4)
	Return ($y & '-' & $m & '-' & $d)
EndFunc   ;==>_FormatGpsDate

Func _DistanceBetweenPoints($Lat1, $Lon1, $Lat2, $Lon2)
	Local $EarthRadius = 6378137 ;meters
	$Lat1 = _deg2rad($Lat1)
	$Lon1 = _deg2rad($Lon1)
	$Lat2 = _deg2rad($Lat2)
	$Lon2 = _deg2rad($Lon2)
	Return (ACos(Sin($Lat1) * Sin($Lat2) + Cos($Lat1) * Cos($Lat2) * Cos($Lon2 - $Lon1)) * $EarthRadius);Return distance in meters
EndFunc   ;==>_DistanceBetweenPoints

Func _BearingBetweenPoints($Lat1, $Lon1, $Lat2, $Lon2)
	$Lat1 = _deg2rad($Lat1)
	$Lon1 = _deg2rad($Lon1)
	$Lat2 = _deg2rad($Lat2)
	$Lon2 = _deg2rad($Lon2)
	$bDegrees = _rad2deg(_ATan2(Cos($Lat1) * Sin($Lat2) - Sin($Lat1) * Cos($Lat2) * Cos($Lon2 - $Lon1), Sin($Lon2 - $Lon1) * Cos($Lat2)))
	If $bDegrees < 0 Then $bDegrees += 360
	Return ($bDegrees);Return bearing in degrees
EndFunc   ;==>_BearingBetweenPoints

Func _DestLat($Lat1, $Brng1, $Dist1)
	Local $EarthRadius = 6378137 ;meters
	$Lat1 = _deg2rad($Lat1)
	$Brng1 = _deg2rad($Brng1)
	Return (StringFormat('%0.7f', _rad2deg(ASin(Sin($Lat1) * Cos($Dist1 / $EarthRadius) + Cos($Lat1) * Sin($Dist1 / $EarthRadius) * Cos($Brng1)))));Return destination decimal latitude
EndFunc   ;==>_DestLat

Func _DestLon($Lat1, $Lon1, $Lat2, $Brng1, $Dist1)
	Local $EarthRadius = 6378137 ;meters
	$Lat1 = _deg2rad($Lat1)
	$Lon1 = _deg2rad($Lon1)
	$Lat2 = _deg2rad($Lat2)
	$Brng1 = _deg2rad($Brng1)
	Return (StringFormat('%0.7f', _rad2deg($Lon1 + _ATan2(Cos($Dist1 / $EarthRadius) - Sin($Lat1) * Sin($Lat2), Sin($Brng1) * Sin($Dist1 / $EarthRadius) * Cos($Lat1)))));Return destination decimal longitude
EndFunc   ;==>_DestLon

;-------------------------------------------------------------------------------------------------------------------------------
;                                                       GPS DETAILS GUI FUNCTIONS
;-------------------------------------------------------------------------------------------------------------------------------

Func _OpenGpsDetailsGUI();Opens GPS Details GUI
	If $GpsDetailsOpen = 0 Then
		$GpsDetailsGUI = GUICreate("Gps Details", 565, 190, -1, -1, BitOR($WS_OVERLAPPEDWINDOW, $WS_CLIPSIBLINGS))
		GUISetBkColor($BackgroundColor)
		$GpsCurrentDataGUI = GUICtrlCreateLabel('', 8, 5, 550, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GPGGA_Quality = GUICtrlCreateLabel("Quality" & ":", 310, 22, 180, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GPRMC_Status = GUICtrlCreateLabel("Status" & ":", 32, 22, 235, 15)
		GUICtrlSetColor(-1, $TextColor)
		GUICtrlCreateGroup("GPRMC", 8, 40, 273, 145)
		GUICtrlSetColor(-1, $TextColor)
		$GPRMC_Time = GUICtrlCreateLabel("Time" & ":", 25, 55, 235, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GPRMC_Date = GUICtrlCreateLabel("Date" & ":", 25, 70, 235, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GPRMC_Lat = GUICtrlCreateLabel("Latitude" & ":", 25, 85, 235, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GPRMC_Lon = GUICtrlCreateLabel("Longitude" & ":", 25, 100, 235, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GPRMC_SpeedKnots = GUICtrlCreateLabel("Speed(knots)" & ":", 25, 115, 235, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GPRMC_SpeedMPH = GUICtrlCreateLabel("Speed(MPH)" & ":", 25, 130, 243, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GPRMC_SpeedKmh = GUICtrlCreateLabel("Speed(kmh)" & ":", 25, 145, 243, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GPRMC_TrackAngle = GUICtrlCreateLabel("Track Angle" & ":", 25, 160, 243, 20)
		GUICtrlSetColor(-1, $TextColor)
		GUICtrlCreateGroup("GPGGA", 287, 40, 273, 125)
		GUICtrlSetColor(-1, $TextColor)
		$GPGGA_Time = GUICtrlCreateLabel("Time" & ":", 304, 55, 235, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GPGGA_Satalites = GUICtrlCreateLabel("Number of sats" & ":", 304, 70, 235, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GPGGA_Lat = GUICtrlCreateLabel("Latitude" & ":", 304, 85, 235, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GPGGA_Lon = GUICtrlCreateLabel("Longitude" & ":", 304, 100, 235, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GPGGA_HorDilPitch = GUICtrlCreateLabel("H.D.P." & ":", 304, 115, 235, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GPGGA_Alt = GUICtrlCreateLabel("Altitude" & ":", 304, 130, 243, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GPGGA_Geo = GUICtrlCreateLabel("Height of Geoid" & ":", 304, 145, 243, 15)
		GUICtrlSetColor(-1, $TextColor)
		$CloseGpsDetailsGUI = GUICtrlCreateButton("Close", 375, 165, 97, 25, 0)
		GUICtrlSetOnEvent($CloseGpsDetailsGUI, '_CloseGpsDetailsGUI')
		GUISetOnEvent($GUI_EVENT_CLOSE, '_CloseGpsDetailsGUI')

		GUISetState(@SW_SHOW)

		$gpsplit = StringSplit($GpsDetailsPosition, ',')
		If $gpsplit[0] = 4 Then ;If $CompassPosition is a proper position, move and resize window
			WinMove($GpsDetailsGUI, '', $gpsplit[1], $gpsplit[2], $gpsplit[3], $gpsplit[4])
		Else ;Set $CompassPosition to the current window position
			$g = WinGetPos($GpsDetailsGUI)
			$GpsDetailsPosition = $g[0] & ',' & $g[1] & ',' & $g[2] & ',' & $g[3]
		EndIf

		$GpsDetailsOpen = 1
	EndIf
EndFunc   ;==>_OpenGpsDetailsGUI

Func _UpdateGpsDetailsGUI();Updates information on GPS Details GUI
	If $GpsDetailsOpen = 1 Then
		GUICtrlSetData($GPGGA_Time, "Time" & ": " & $FixTime)
		GUICtrlSetData($GPGGA_Lat, "Latitude" & ": " & StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($Latitude), 'S', '-'), 'N', ''), ' ', ''))
		GUICtrlSetData($GPGGA_Lon, "Longitude" & ": " & StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($Longitude), 'W', '-'), 'E', ''), ' ', ''))
		GUICtrlSetData($GPGGA_Quality, "Quality" & ": " & $Temp_Quality)
		GUICtrlSetData($GPGGA_Satalites, "Number of sats" & ": " & $NumberOfSatalites)
		GUICtrlSetData($GPGGA_HorDilPitch, "H.D.P." & ": " & $HorDilPitch)
		GUICtrlSetData($GPGGA_Alt, "Altitude" & ": " & $Alt & $AltS)
		GUICtrlSetData($GPGGA_Geo, "Height of Geoid" & ": " & $Geo & $GeoS)

		GUICtrlSetData($GPRMC_Time, "Time" & ": " & $FixTime2)
		GUICtrlSetData($GPRMC_Date, "Date" & ": " & $FixDate)
		GUICtrlSetData($GPRMC_Lat, "Latitude" & ": " & StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($Latitude2), 'S', '-'), 'N', ''), ' ', ''))
		GUICtrlSetData($GPRMC_Lon, "Longitude" & ": " & StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($Longitude2), 'W', '-'), 'E', ''), ' ', ''))
		GUICtrlSetData($GPRMC_Status, "Status" & ": " & $Temp_Status)
		GUICtrlSetData($GPRMC_SpeedKnots, "Speed(knots)" & ": " & $SpeedInKnots & " Kn")
		GUICtrlSetData($GPRMC_SpeedMPH, "Speed(MPH)" & ": " & $SpeedInMPH & " MPH")
		GUICtrlSetData($GPRMC_SpeedKmh, "Speed(kmh)" & ": " & $SpeedInKmH & " Km/H")
		GUICtrlSetData($GPRMC_TrackAngle, "Track Angle" & ": " & $TrackAngle)
	EndIf
EndFunc   ;==>_UpdateGpsDetailsGUI

Func _ClearGpsDetailsGUI();Clears all GPS Details information
	If Round(TimerDiff($GPGGA_Update)) > $GpsTimeout Then
		$FixTime = ''
		$Latitude = '0.0000000'
		$Longitude = '0.0000000'
		$NumberOfSatalites = '00'
		$HorDilPitch = '0'
		$Alt = '0'
		$AltS = 'M'
		$Geo = '0'
		$GeoS = 'M'
		$GPGGA_Update = TimerInit()
	EndIf
	If Round(TimerDiff($GPRMC_Update)) > $GpsTimeout Then
		$FixTime2 = ''
		$Latitude2 = '0.0000000'
		$Longitude2 = '0.0000000'
		$SpeedInKnots = '0'
		$SpeedInMPH = '0'
		$SpeedInKmH = '0'
		$TrackAngle = '0'
		$FixDate = ''
		$GPRMC_Update = TimerInit()
	EndIf
EndFunc   ;==>_ClearGpsDetailsGUI

Func _CloseGpsDetailsGUI(); Closes GPS Details GUI
	GUIDelete($GpsDetailsGUI)
	$GpsDetailsOpen = 0
EndFunc   ;==>_CloseGpsDetailsGUI

;-------------------------------------------------------------------------------------------------------------------------------
;                                                       GPS COMPASS GUI FUNCTIONS
;-------------------------------------------------------------------------------------------------------------------------------

Func _CompassGUI()
	If $CompassOpen = 0 Then
		$CompassGUI = GUICreate("Compass", 130, 130, -1, -1, BitOR($WS_OVERLAPPEDWINDOW, $WS_CLIPSIBLINGS))
		GUISetBkColor($BackgroundColor)
		$CompassBack = GUICtrlCreateLabel('', 0, 0, 130, 130)
		GUICtrlSetState($CompassBack, $GUI_HIDE)
		$north = GUICtrlCreateLabel("N", 50, 0, 15, 15)
		GUICtrlSetColor(-1, $TextColor)
		$south = GUICtrlCreateLabel("S", 50, 90, 15, 15)
		GUICtrlSetColor(-1, $TextColor)
		$east = GUICtrlCreateLabel("E", 93, 45, 15, 12)
		GUICtrlSetColor(-1, $TextColor)
		$west = GUICtrlCreateLabel("W", 3, 45, 15, 12)
		GUICtrlSetColor(-1, $TextColor)

		_GDIPlus_Startup()
		$CompassGraphic = _GDIPlus_GraphicsCreateFromHWND($CompassGUI)
		$CompassColor = '0xFF' & StringTrimLeft($ControlBackgroundColor, 2)
		$hBrush = _GDIPlus_BrushCreateSolid($CompassColor) ;red
		_GDIPlus_GraphicsFillEllipse($CompassGraphic, 15, 15, 100, 100, $hBrush)

		GUISetOnEvent($GUI_EVENT_CLOSE, '_CloseCompassGui')
		GUISetOnEvent($GUI_EVENT_RESIZED, '_SetCompassSizes')
		GUISetOnEvent($GUI_EVENT_RESTORE, '_SetCompassSizes')

		GUISetState(@SW_SHOW)

		$cpsplit = StringSplit($CompassPosition, ',')
		If $cpsplit[0] = 4 Then ;If $CompassPosition is a proper position, move and resize window
			WinMove($CompassGUI, '', $cpsplit[1], $cpsplit[2], $cpsplit[3], $cpsplit[4])
		Else ;Set $CompassPosition to the current window position
			$c = WinGetPos($CompassGUI)
			$CompassPosition = $c[0] & ',' & $c[1] & ',' & $c[2] & ',' & $c[3]
		EndIf
		_SetCompassSizes()

		$CompassOpen = 1
	Else
		WinActivate($CompassGUI)
	EndIf
EndFunc   ;==>_CompassGUI

Func _CloseCompassGui();closes the compass window
	_GDIPlus_GraphicsDispose($CompassGraphic)
	_GDIPlus_Shutdown()
	GUIDelete($CompassGUI)
	$CompassOpen = 0
EndFunc   ;==>_CloseCompassGui

Func _SetCompassSizes();Takes the size of a hidden label in the compass window and determines the Width/Height of the compass
	$a = ControlGetPos("", "", $CompassBack)
	If Not @error Then
		$compasspos = $a[0] & $a[1] & $a[2] & $a[3]
		If $a[2] > $a[3] Then
			Dim $CompassHeight = $a[3] - 30
		Else
			Dim $CompassHeight = $a[2] - 30
		EndIf
	EndIf
	$CompassMidWidth = 10 + ($CompassHeight / 2)
	$CompassMidHeight = 10 + ($CompassHeight / 2)
	GUICtrlSetPos($north, $CompassMidWidth, 0, 15, 15)
	GUICtrlSetPos($south, $CompassMidWidth, $CompassHeight + 15, 15, 15)
	GUICtrlSetPos($east, $CompassHeight + 15, $CompassMidHeight, 15, 15)
	GUICtrlSetPos($west, 0, $CompassMidHeight, 15, 15)

	_GDIPlus_GraphicsDispose($CompassGraphic)
	_GDIPlus_Shutdown()
	_GDIPlus_Startup()

	$CompassGraphic = _GDIPlus_GraphicsCreateFromHWND($CompassGUI)
	$CompassColor = '0xFF' & StringTrimLeft($ControlBackgroundColor, 2)
	$hBrush = _GDIPlus_BrushCreateSolid($CompassColor) ;red
	_GDIPlus_GraphicsFillEllipse($CompassGraphic, 15, 15, $CompassHeight, $CompassHeight, $hBrush)
EndFunc   ;==>_SetCompassSizes

Func _DrawCompassLine($Degree,$Degree2='-1');, $Degree2);Draws compass in GPS Details GUI
	If $CompassOpen = 1 Then
		_SetCompassSizes()
		$Radius = ($CompassHeight / 2) - 1
		$CenterX = ($CompassHeight / 2) + 15
		$CenterY = ($CompassHeight / 2) + 15

		;Calculate (X, Y) based on Degrees, Radius, And Center of circle (X, Y) for $Degree
		If $Degree = 0 Or $Degree = 360 Then
			$CircleX = $CenterX
			$CircleY = $CenterY - $Radius
		ElseIf $Degree > 0 And $Degree < 90 Then
			$Radians = $Degree * 0.0174532925
			$CircleX = $CenterX + (Sin($Radians) * $Radius)
			$CircleY = $CenterY - (Cos($Radians) * $Radius)
		ElseIf $Degree = 90 Then
			$CircleX = $CenterX + $Radius
			$CircleY = $CenterY
		ElseIf $Degree > 90 And $Degree < 180 Then
			$TmpDegree = $Degree - 90
			$Radians = $TmpDegree * 0.0174532925
			$CircleX = $CenterX + (Cos($Radians) * $Radius)
			$CircleY = $CenterY + (Sin($Radians) * $Radius)
		ElseIf $Degree = 180 Then
			$CircleX = $CenterX
			$CircleY = $CenterY + $Radius
		ElseIf $Degree > 180 And $Degree < 270 Then
			$TmpDegree = $Degree - 180
			$Radians = $TmpDegree * 0.0174532925
			$CircleX = $CenterX - (Sin($Radians) * $Radius)
			$CircleY = $CenterY + (Cos($Radians) * $Radius)
		ElseIf $Degree = 270 Then
			$CircleX = $CenterX - $Radius
			$CircleY = $CenterY
		ElseIf $Degree > 270 And $Degree < 360 Then
			$TmpDegree = $Degree - 270
			$Radians = $TmpDegree * 0.0174532925
			$CircleX = $CenterX - (Cos($Radians) * $Radius)
			$CircleY = $CenterY - (Sin($Radians) * $Radius)
		EndIf
		;Draw $Degree Line
		$pen = _GDIPlus_PenCreate("0xFFFF3333")
		_GDIPlus_GraphicsDrawLine($CompassGraphic, $CenterX, $CenterY, $CircleX, $CircleY, $pen)
		_GDIPlus_PenDispose($pen)

		If $Degree2 <> '-1' Then
			;Calculate (X, Y) based on Degrees, Radius, And Center of circle (X, Y) for $Degree2
			If $Degree2 = 0 Or $Degree2 = 360 Then
				$CircleX = $CenterX
				$CircleY = $CenterY - $Radius
			ElseIf $Degree2 > 0 And $Degree2 < 90 Then
				$Radians = $Degree2 * 0.0174532925
				$CircleX = $CenterX + (Sin($Radians) * $Radius)
				$CircleY = $CenterY - (Cos($Radians) * $Radius)
			ElseIf $Degree2 = 90 Then
				$CircleX = $CenterX + $Radius
				$CircleY = $CenterY
			ElseIf $Degree2 > 90 And $Degree2 < 180 Then
				$TmpDegree = $Degree2 - 90
				$Radians = $TmpDegree * 0.0174532925
				$CircleX = $CenterX + (Cos($Radians) * $Radius)
				$CircleY = $CenterY + (Sin($Radians) * $Radius)
			ElseIf $Degree2 = 180 Then
				$CircleX = $CenterX
				$CircleY = $CenterY + $Radius
			ElseIf $Degree2 > 180 And $Degree2 < 270 Then
				$TmpDegree = $Degree2 - 180
				$Radians = $TmpDegree * 0.0174532925
				$CircleX = $CenterX - (Sin($Radians) * $Radius)
				$CircleY = $CenterY + (Cos($Radians) * $Radius)
			ElseIf $Degree2 = 270 Then
				$CircleX = $CenterX - $Radius
				$CircleY = $CenterY
			ElseIf $Degree2 > 270 And $Degree2 < 360 Then
				$TmpDegree = $Degree2 - 270
				$Radians = $TmpDegree * 0.0174532925
				$CircleX = $CenterX - (Cos($Radians) * $Radius)
				$CircleY = $CenterY - (Sin($Radians) * $Radius)
			EndIf
			;Draw $Degree Line
			$pen = _GDIPlus_PenCreate("0xFF000000")
			_GDIPlus_GraphicsDrawLine($CompassGraphic, $CenterX, $CenterY, $CircleX, $CircleY, $pen)
			_GDIPlus_PenDispose($pen)
		EndIf

	EndIf
EndFunc   ;==>_DrawCompassLine

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
		Return $PI - ATan(-$y / $x)
	ElseIf $x > 0 Then
		Return ATan($y / $x)
	ElseIf $y <> 0 Then
		Return $PI / 2
	Else
		SetError(1)
	EndIf
EndFunc   ;==>_ATan2
