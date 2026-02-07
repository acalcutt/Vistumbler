#CS
Windows Location Platform Functions - Version 1.0.0 - 2026-02-06
by acalcutt
http://www.vistumbler.net/

This UDF provides access to location data via Windows Location Sensor (Windows 10/11)
or falls back to using WMI/PowerShell methods for location retrieval.

Artistic License 2.0

Note: This uses Windows Sensors API available in Windows 7+ and enhanced in Windows 10+

#CE

;--------------Enumerations-------------

; Location Report Types
Global Enum $REPORT_TYPE_LATITUDE_LONGITUDE = 0, $REPORT_TYPE_CIVIC_ADDRESS = 1

; Location Report Status
Global Enum $REPORT_NOT_SUPPORTED = 0, $REPORT_ERROR = 1, $REPORT_ACCESS_DENIED = 2, $REPORT_INITIALIZING = 3, $REPORT_RUNNING = 4

; Location Desired Accuracy
Global Enum $LOCATION_DESIRED_ACCURACY_DEFAULT = 0, $LOCATION_DESIRED_ACCURACY_HIGH = 1

;--------------Constants-------------
Global Const $LOCATION_E_REPORT_NOT_FOUND = 0x80070490
Global Const $LOCATION_E_ACCESS_DENIED = 0x80070005

;--------------Global Variables-------------
Global $g_oLocation = 0
Global $g_bLocationInitialized = False
Global $g_iLocationStatus = $REPORT_NOT_SUPPORTED
Global $g_sLocationError = ""

; ===============================================================================================================================
; Function Name:    _WinLocation_Startup()
; Description:      Initializes the Windows Location API using PowerShell/WMI fallback
; Parameter(s):     $iDesiredAccuracy - 0 for default, 1 for high accuracy (Optional, default = 1)
; Return Value(s):  Success: 1
;                   Failure: 0 and sets @error
;                   @error = 1: Location services not available
;                   @error = 2: Location API disabled or access denied
;                   @error = 3: Other initialization error
; ===============================================================================================================================
Func _WinLocation_Startup($iDesiredAccuracy = $LOCATION_DESIRED_ACCURACY_HIGH)
	If $g_bLocationInitialized Then Return 1
	
	; Check if we're on Windows 10/11 by checking for location sensor support via PowerShell
	; This is more reliable than COM for Windows Location access
	Local $sTestScript = 'Add-Type -AssemblyName System.Device; $loc = New-Object System.Device.Location.GeoCoordinateWatcher; $loc.TryStart($false, [TimeSpan]::FromSeconds(1)); $loc.Permission'
	Local $iPID = Run(@ComSpec & ' /c powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "' & $sTestScript & '"', "", @SW_HIDE, $STDOUT_CHILD)
	
	If $iPID Then
		Local $sOutput = ""
		Local $iTimer = TimerInit()
		While ProcessExists($iPID) And TimerDiff($iTimer) < 3000
			$sOutput &= StdoutRead($iPID)
			Sleep(50)
		WEnd
		$sOutput &= StdoutRead($iPID)
		
		If StringInStr($sOutput, "Granted") Then
			$g_bLocationInitialized = True
			$g_iLocationStatus = $REPORT_RUNNING
			Return 1
		ElseIf StringInStr($sOutput, "Denied") Then
			$g_sLocationError = "Location access denied. Please enable location services in Windows settings."
			$g_iLocationStatus = $REPORT_ACCESS_DENIED
			Return SetError(2, 0, 0)
		EndIf
	EndIf
	
	; If PowerShell method fails, mark as initialized anyway and let GetPosition handle errors
	$g_bLocationInitialized = True
	$g_iLocationStatus = $REPORT_INITIALIZING
	Return 1
EndFunc   ;==>_WinLocation_Startup

; ===============================================================================================================================
; Function Name:    _WinLocation_Shutdown()
; Description:      Shuts down the Windows Location API and releases resources
; Return Value(s):  Always returns 1
; ===============================================================================================================================
Func _WinLocation_Shutdown()
	$g_bLocationInitialized = False
	$g_iLocationStatus = $REPORT_NOT_SUPPORTED
	$g_sLocationError = ""
	Return 1
EndFunc   ;==>_WinLocation_Shutdown

; ===============================================================================================================================
; Function Name:    _WinLocation_GetPosition()
; Description:      Gets the current latitude/longitude position from Windows Location using PowerShell/.NET
; Return Value(s):  Success: Array with location data
;                   [0] = Latitude (decimal degrees)
;                   [1] = Longitude (decimal degrees)
;                   [2] = Error radius (meters) - horizontal accuracy
;                   [3] = Altitude (meters above sea level, may be 0 if not available)
;                   [4] = Altitude error (meters, may be 0 if not available)
;                   [5] = Timestamp (string format)
;                   Failure: 0 and sets @error
;                   @error = 1: Location API not initialized
;                   @error = 2: Location report not available
;                   @error = 3: Access denied
;                   @error = 4: Timeout
;                   @error = 5: General error
; ===============================================================================================================================
Func _WinLocation_GetPosition()
	If Not $g_bLocationInitialized Then
		Return SetError(1, 0, 0)
	EndIf
	
	Local $aPosition[6]
	
	; Use PowerShell to access System.Device.Location.GeoCoordinateWatcher
	Local $sPSScript = 'Add-Type -AssemblyName System.Device; ' & _
		'$loc = New-Object System.Device.Location.GeoCoordinateWatcher; ' & _
		'$loc.Start(); ' & _
		'$timeout = [DateTime]::Now.AddSeconds(10); ' & _
		'while ($loc.Status -ne ''Ready'' -and [DateTime]::Now -lt $timeout) { Start-Sleep -Milliseconds 100 }; ' & _
		'if ($loc.Status -eq ''Ready'' -and $loc.Position.Location.IsUnknown -eq $false) { ' & _
		'$pos = $loc.Position.Location; ' & _
		'Write-Output "$($pos.Latitude)|$($pos.Longitude)|$($pos.HorizontalAccuracy)|$($pos.Altitude)|$($pos.VerticalAccuracy)|$($loc.Position.Timestamp)" ' & _
		'} else { Write-Output "ERROR" }; ' & _
		'$loc.Stop(); $loc.Dispose()'
	
	Local $iPID = Run(@ComSpec & ' /c powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "' & $sPSScript & '"', "", @SW_HIDE, $STDOUT_CHILD + $STDERR_CHILD)
	
	If Not $iPID Then
		$g_iLocationStatus = $REPORT_ERROR
		$g_sLocationError = "Failed to execute PowerShell location query"
		Return SetError(5, 0, 0)
	EndIf
	
	Local $sOutput = ""
	Local $iTimer = TimerInit()
	While ProcessExists($iPID) And TimerDiff($iTimer) < 12000
		$sOutput &= StdoutRead($iPID)
		Sleep(100)
	WEnd
	$sOutput &= StdoutRead($iPID)
	$sOutput = StringStripWS($sOutput, 3)
	
	; Kill process if still running
	If ProcessExists($iPID) Then ProcessClose($iPID)
	
	; Parse output
	If $sOutput = "ERROR" Or $sOutput = "" Then
		$g_iLocationStatus = $REPORT_ERROR
		$g_sLocationError = "Location not available. Check if location services are enabled and an app has location permission."
		Return SetError(2, 0, 0)
	EndIf
	
	; Split the output
	Local $aParts = StringSplit($sOutput, "|", 2)
	If UBound($aParts) < 6 Then
		$g_iLocationStatus = $REPORT_ERROR
		$g_sLocationError = "Invalid location data received: " & $sOutput
		Return SetError(5, 0, 0)
	EndIf
	
	; Fill the array
	$aPosition[0] = Number($aParts[0]) ; Latitude
	$aPosition[1] = Number($aParts[1]) ; Longitude
	$aPosition[2] = Number($aParts[2]) ; Horizontal Accuracy
	$aPosition[3] = Number($aParts[3]) ; Altitude
	$aPosition[4] = Number($aParts[4]) ; Vertical Accuracy
	$aPosition[5] = $aParts[5] ; Timestamp
	
	; Check if we got valid data
	If $aPosition[0] = 0 And $aPosition[1] = 0 Then
		$g_iLocationStatus = $REPORT_ERROR
		$g_sLocationError = "Invalid location data (0, 0)"
		Return SetError(2, 0, 0)
	EndIf
	
	$g_iLocationStatus = $REPORT_RUNNING
	$g_sLocationError = ""
	
	Return $aPosition
EndFunc   ;==>_WinLocation_GetPosition

; ===============================================================================================================================
; Function Name:    _WinLocation_GetStatus()
; Description:      Gets the current status of the Windows Location API
; Return Value(s):  Returns one of the REPORT_* status constants
;                   $REPORT_NOT_SUPPORTED = 0
;                   $REPORT_ERROR = 1
;                   $REPORT_ACCESS_DENIED = 2
;                   $REPORT_INITIALIZING = 3
;                   $REPORT_RUNNING = 4
; ===============================================================================================================================
Func _WinLocation_GetStatus()
	Return $g_iLocationStatus
EndFunc   ;==>_WinLocation_GetStatus

; ===============================================================================================================================
; Function Name:    _WinLocation_GetStatusString()
; Description:      Gets a string description of the current status
; Return Value(s):  String describing current status
; ===============================================================================================================================
Func _WinLocation_GetStatusString()
	Switch $g_iLocationStatus
		Case $REPORT_NOT_SUPPORTED
			Return "Not Supported"
		Case $REPORT_ERROR
			Return "Error: " & $g_sLocationError
		Case $REPORT_ACCESS_DENIED
			Return "Access Denied"
		Case $REPORT_INITIALIZING
			Return "Initializing"
		Case $REPORT_RUNNING
			Return "Running"
		Case Else
			Return "Unknown"
	EndSwitch
EndFunc   ;==>_WinLocation_GetStatusString

; ===============================================================================================================================
; Function Name:    _WinLocation_ConvertToNMEAFormat()
; Description:      Converts decimal degrees to NMEA format (DDMM.MMMM)
; Parameter(s):     $dDecimalDegrees - Latitude or Longitude in decimal degrees
;                   $bIsLatitude - True for latitude, False for longitude
; Return Value(s):  String in NMEA format (e.g., "N 4725.1234" or "W 12215.5678")
; ===============================================================================================================================
Func _WinLocation_ConvertToNMEAFormat($dDecimalDegrees, $bIsLatitude = True)
	Local $sDirection, $iDegrees, $dMinutes, $sResult
	
	; Determine direction
	If $bIsLatitude Then
		$sDirection = ($dDecimalDegrees >= 0) ? "N" : "S"
	Else
		$sDirection = ($dDecimalDegrees >= 0) ? "E" : "W"
	EndIf
	
	; Work with absolute value
	$dDecimalDegrees = Abs($dDecimalDegrees)
	
	; Extract degrees
	$iDegrees = Int($dDecimalDegrees)
	
	; Convert decimal part to minutes
	$dMinutes = ($dDecimalDegrees - $iDegrees) * 60
	
	; Format as NMEA: DDMM.MMMM or DDDMM.MMMM
	If $bIsLatitude Then
		$sResult = $sDirection & " " & StringFormat("%02d%07.4f", $iDegrees, $dMinutes)
	Else
		$sResult = $sDirection & " " & StringFormat("%03d%07.4f", $iDegrees, $dMinutes)
	EndIf
	
	Return $sResult
EndFunc   ;==>_WinLocation_ConvertToNMEAFormat

; ===============================================================================================================================
; Function Name:    _WinLocation_IsAvailable()
; Description:      Checks if Windows Location API is available on this system
; Return Value(s):  1 if available, 0 if not
; ===============================================================================================================================
Func _WinLocation_IsAvailable()
	; Just check if PowerShell is available - we'll handle errors later
	If FileExists(@SystemDir & "\WindowsPowerShell\v1.0\powershell.exe") Then
		Return 1
	EndIf
	; Also check alternate location
	If FileExists(@WindowsDir & "\System32\WindowsPowerShell\v1.0\powershell.exe") Then
		Return 1
	EndIf
	Return 0
EndFunc   ;==>_WinLocation_IsAvailable

; ===============================================================================================================================
; Function Name:    _WinLocation_OpenLocationSettings()
; Description:      Opens Windows Location Settings so user can enable/configure location services
; Return Value(s):  Always returns 1
; ===============================================================================================================================
Func _WinLocation_OpenLocationSettings()
	; Windows 10 and later
	Run("ms-settings:privacy-location")
	Return 1
EndFunc   ;==>_WinLocation_OpenLocationSettings
