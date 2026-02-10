#include-once
#include <Date.au3>
#include "ParseCSV.au3"

; #INDEX# =======================================================================================================================
; Title .........: WigleCSV Library
; AutoIt Version : 3.3+
; Description ...: Functions for working with WiGLE CSV format (v1.4 and v1.6)
; Author(s) .....: acalcutt
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
; _WigleCSV_BuildAuthMode - Converts AUTH/ENCR/NetworkType to WiGLE capability flags format
; _WigleCSV_ParseAuthMode - Parses WiGLE capability flags to AUTH/ENCR/SecType/NetworkType
; _WigleCSV_WriteFile - Exports array of WiFi observations to WigleCSV v1.6 file
; _WigleCSV_ReadFile - Imports WigleCSV file (v1.4 or v1.6) and returns array of observations
; ===============================================================================================================================

; Note: GPS conversion functions (_Format_GPS_DMM_to_DDD / _Format_GPS_DDD_to_DMM) should be
; provided by the calling application. This UDF works with WiGLE's native DDD (Decimal Degrees) format.

; ===============================================================================================================================
; Function Name:    _WigleCSV_BuildAuthMode
; Description:      Converts Vistumbler AUTH/ENCR/NetworkType to WiGLE AuthMode capability flags
; Parameter(s):     $sAuth - Authentication type (e.g., "WPA3-Personal", "WPA2-Enterprise", "Open")
;                   $sEncr - Encryption type (e.g., "CCMP", "GCMP", "TKIP", "WEP", "None")
;                   $sNetType - Network type ("Infrastructure" or "Ad Hoc")
; Return Value(s):  Success - WiGLE capability flags string (e.g., "[WPA3-SAE-CCMP][ESS]")
;                   Failure - Empty string for Open/None networks
; Notes:            Works directly with NativeWifi.au3 output (_Wlan_EnumToString)
;                   Supports WPA3 (SAE/EAP), WPA2, WPA, WEP, and Open networks
;                   GCMP/GCMP-256/CCMP-256 are normalized to GCMP/CCMP for compatibility
; ===============================================================================================================================
Func _WigleCSV_BuildAuthMode($sAuth, $sEncr, $sNetType = "Infrastructure")
	Local $sFlags = ""

	; Normalize encryption variants (GCMP-256 → GCMP, CCMP-256 → CCMP)
	Local $sEncrNorm = $sEncr
	If StringInStr($sEncr, "GCMP") Then
		$sEncrNorm = "GCMP"
	ElseIf StringInStr($sEncr, "CCMP") Then
		$sEncrNorm = "CCMP"
	EndIf

	; Build security flag based on AUTH and ENCR
	; WPA3 Security
	If $sAuth = "WPA3-Enterprise" Or $sAuth = "WPA3-Enterprise-192" Then
		$sFlags = "[WPA3-EAP-" & $sEncrNorm & "]"
	ElseIf $sAuth = "WPA3-Personal" Then
		$sFlags = "[WPA3-SAE-" & $sEncrNorm & "]"
		; WPA2 Security
	ElseIf $sAuth = "WPA2-Enterprise" Then
		$sFlags = "[WPA2-EAP-" & $sEncrNorm & "]"
	ElseIf $sAuth = "WPA2-Personal" Then
		$sFlags = "[WPA2-PSK-" & $sEncrNorm & "]"
		; WPA Security
	ElseIf $sAuth = "WPA-Enterprise" Then
		$sFlags = "[WPA-EAP-" & $sEncrNorm & "]"
	ElseIf $sAuth = "WPA-Personal" Then
		$sFlags = "[WPA-PSK-" & $sEncrNorm & "]"
		; OWE (Opportunistic Wireless Encryption)
	ElseIf $sAuth = "OWE" Then
		$sFlags = "[OWE]"
		; WEP
	ElseIf $sAuth = "Open" And $sEncr = "WEP" Then
		$sFlags = "[WEP]"
		; Shared Key Authentication
	ElseIf $sAuth = "Shared Key" And $sEncr = "WEP" Then
		$sFlags = "[WEP]"
		; Open network - return empty for compatibility
	ElseIf $sAuth = "Open" And $sEncr = "None" Then
		Return ""
	EndIf

	; Add network type flag if security is applied
	If $sFlags <> "" Then
		If $sNetType = "Ad Hoc" Or $sNetType = "IBSS" Then
			$sFlags &= "[IBSS]"
		Else
			$sFlags &= "[ESS]"
		EndIf
	EndIf

	Return $sFlags
EndFunc   ;==>_WigleCSV_BuildAuthMode

; ===============================================================================================================================
; Function Name:    _WigleCSV_ParseAuthMode
; Description:      Parses WiGLE AuthMode capability flags to Vistumbler AUTH/ENCR/SecType/NetworkType
; Parameter(s):     $sAuthMode - WiGLE capability flags (e.g., "[WPA3-SAE-CCMP][ESS]")
; Return Value(s):  Array [AUTH, ENCR, SecType, NetworkType]
;                   SecType: 1=Open, 2=WEP, 3=WPA family
; Notes:            Detects WPA3 via "[WPA3", "SAE", or "EAP_SUITE_B_192" strings
;                   Compatible with WiGLE Android app capability strings
;                   Handles GCMP, GCMP-256, CCMP, CCMP-256, TKIP encryption variants
; ===============================================================================================================================
Func _WigleCSV_ParseAuthMode($sAuthMode)
	Local $sAuth = "Open"
	Local $sEncr = "None"
	Local $iSecType = 1 ; 1=open, 2=wep, 3=wpa/wpa2/wpa3
	Local $sNetType = "Infrastructure"

	; Normalize to uppercase for case-insensitive matching
	Local $sCap = StringUpper($sAuthMode)

	; Determine encryption cipher
	If StringInStr($sCap, "GCMP-256") Then
		$sEncr = "GCMP-256"
	ElseIf StringInStr($sCap, "GCMP") Then
		$sEncr = "GCMP"
	ElseIf StringInStr($sCap, "CCMP-256") Then
		$sEncr = "CCMP-256"
	ElseIf StringInStr($sCap, "CCMP") Or StringInStr($sCap, "AES") Then
		$sEncr = "CCMP"
	ElseIf StringInStr($sCap, "TKIP") Then
		$sEncr = "TKIP"
	ElseIf StringInStr($sCap, "WEP") Then
		$sEncr = "WEP"
	EndIf

	; Determine authentication and security type
	; Check WPA3 first (most secure, check before WPA2/WPA)
	If StringInStr($sCap, "WPA3") Or StringInStr($sCap, "SAE") Or StringInStr($sCap, "EAP_SUITE_B_192") Then
		$iSecType = 3
		If StringInStr($sCap, "EAP") Or StringInStr($sCap, "EAP_SUITE_B_192") Then
			$sAuth = "WPA3-Enterprise"
		Else
			$sAuth = "WPA3-Personal"
		EndIf
		; WPA2
	ElseIf StringInStr($sCap, "WPA2") Or StringInStr($sCap, "RSN") Then
		$iSecType = 3
		If StringInStr($sCap, "EAP") Then
			$sAuth = "WPA2-Enterprise"
		ElseIf StringInStr($sCap, "PSK") Or StringInStr($sCap, "PERSONAL") Then
			$sAuth = "WPA2-Personal"
		Else
			$sAuth = "WPA2-Personal" ; Default WPA2 to Personal
		EndIf
		; WPA
	ElseIf StringInStr($sCap, "WPA") Then
		$iSecType = 3
		If StringInStr($sCap, "EAP") Then
			$sAuth = "WPA-Enterprise"
		ElseIf StringInStr($sCap, "PSK") Or StringInStr($sCap, "PERSONAL") Then
			$sAuth = "WPA-Personal"
		Else
			$sAuth = "WPA-Personal" ; Default WPA to Personal
		EndIf
		; OWE
	ElseIf StringInStr($sCap, "OWE") Then
		$iSecType = 3
		$sAuth = "OWE"
		; WEP
	ElseIf $sEncr = "WEP" Then
		$iSecType = 2
		$sAuth = "Open"
		; Open
	Else
		$iSecType = 1
		$sAuth = "Open"
		$sEncr = "None"
	EndIf

	; Determine network type
	If StringInStr($sCap, "IBSS") Or StringInStr($sCap, "AD-HOC") Then
		$sNetType = "Ad Hoc"
	Else
		$sNetType = "Infrastructure"
	EndIf

	Local $aResult[4] = [$sAuth, $sEncr, $iSecType, $sNetType]
	Return $aResult
EndFunc   ;==>_WigleCSV_ParseAuthMode

; ===============================================================================================================================
; Function Name:    _WigleCSV_WriteFile
; Description:      Exports array of WiFi observations to WigleCSV v1.6 format file
; Parameter(s):     $sFilePath - Full path to output CSV file
;                   $aObservations - 2D array of observation data (see structure below)
;                   $aDeviceInfo - [Optional] Array with device metadata (see structure below)
; Return Value(s):  Success - Returns 1
;                   Failure - Returns 0 and sets @error
;                   @error 1 - Invalid observation array
;                   @error 2 - File write error
; Observation Array Structure:
;   Each row: [MAC, SSID, Auth, Encr, NetType, DateTime, Channel, Frequency, RSSI, Lat_DDD, Lon_DDD, Alt, Accuracy]
;   - MAC: MAC address (e.g., "aa:bb:cc:dd:ee:ff")
;   - SSID: Network name
;   - Auth: Authentication (e.g., "WPA3-Personal", "WPA2-Enterprise", "Open")
;   - Encr: Encryption (e.g., "CCMP", "GCMP", "TKIP", "WEP", "None")
;   - NetType: Network type ("Infrastructure" or "Ad Hoc")
;   - DateTime: "YYYY-MM-DD HH:MM:SS" format
;   - Channel: WiFi channel number
;   - Frequency: Center frequency in MHz (e.g., 2412, 5180, 5955)
;   - RSSI: Signal strength in dBm
;   - Lat_DDD: Latitude in decimal degrees (e.g., 40.712800)
;   - Lon_DDD: Longitude in decimal degrees (e.g., -71.587292)
;   - Alt: Altitude in meters
;   - Accuracy: GPS accuracy in meters
; Device Info Array Structure [Optional]:
;   [appRelease, model, release, device, brand]
;   If omitted, defaults will be used
; ===============================================================================================================================
Func _WigleCSV_WriteFile($sFilePath, $aObservations, $aDeviceInfo = 0)
	; Validate input
	If Not IsArray($aObservations) Then Return SetError(1, 0, 0)
	Local $iRows = UBound($aObservations)
	If $iRows = 0 Then Return SetError(1, 0, 0)

	; Set default device info if not provided
	Local $sAppRelease = "WigleCSV UDF"
	Local $sModel = "Generic"
	Local $sRelease = ""
	Local $sDevice = ""
	Local $sBrand = ""

	If IsArray($aDeviceInfo) And UBound($aDeviceInfo) >= 5 Then
		$sAppRelease = $aDeviceInfo[0]
		$sModel = $aDeviceInfo[1]
		$sRelease = $aDeviceInfo[2]
		$sDevice = $aDeviceInfo[3]
		$sBrand = $aDeviceInfo[4]
	EndIf

	; Build pre-header (v1.6 format with planetary coordinates)
	Local $sContent = "WigleWifi-1.6"
	$sContent &= ",appRelease=" & StringReplace($sAppRelease, ",", "")
	$sContent &= ",model=" & StringReplace($sModel, ",", "")
	$sContent &= ",release=" & StringReplace($sRelease, ",", "")
	$sContent &= ",device=" & StringReplace($sDevice, ",", "")
	$sContent &= ",display="
	$sContent &= ",board="
	$sContent &= ",brand=" & StringReplace($sBrand, ",", "")
	$sContent &= ",star=Sol,body=3,subBody=0" ; Earth coordinates
	$sContent &= @LF

	; Add header row (v1.6 format with Frequency, RCOIs, MfgrId)
	$sContent &= "MAC,SSID,AuthMode,FirstSeen,Channel,Frequency,RSSI,CurrentLatitude,CurrentLongitude,AltitudeMeters,AccuracyMeters,RCOIs,MfgrId,Type" & @LF

	; Process each observation
	For $i = 0 To $iRows - 1
		Local $sMac = $aObservations[$i][0]
		Local $sSSID = StringReplace($aObservations[$i][1], ",", "") ; Remove commas from SSID
		Local $sAuth = $aObservations[$i][2]
		Local $sEncr = $aObservations[$i][3]
		Local $sNetType = $aObservations[$i][4]
		Local $sDateTime = $aObservations[$i][5]
		Local $iChannel = $aObservations[$i][6]
		Local $iFreq = $aObservations[$i][7]
		Local $iRSSI = $aObservations[$i][8]
		Local $fLat = $aObservations[$i][9]
		Local $fLon = $aObservations[$i][10]
		Local $fAlt = $aObservations[$i][11]
		Local $fAccuracy = $aObservations[$i][12]

		; Build AuthMode flags
		Local $sAuthMode = _WigleCSV_BuildAuthMode($sAuth, $sEncr, $sNetType)

		; Build CSV line (v1.6 format)
		$sContent &= $sMac & ","
		$sContent &= $sSSID & ","
		$sContent &= $sAuthMode & ","
		$sContent &= $sDateTime & ","
		$sContent &= $iChannel & ","
		$sContent &= $iFreq & ","
		$sContent &= $iRSSI & ","
		$sContent &= $fLat & ","
		$sContent &= $fLon & ","
		$sContent &= $fAlt & ","
		$sContent &= $fAccuracy & ","
		$sContent &= "," ; RCOIs (empty for WiFi)
		$sContent &= "," ; MfgrId (empty for WiFi)
		$sContent &= "WIFI"
		$sContent &= @LF
	Next

	; Write to file (UTF-8 format)
	Local $hFile = FileOpen($sFilePath, 128 + 2) ; $FO_UTF8 + $FO_OVERWRITE
	If $hFile = -1 Then Return SetError(2, 0, 0)
	FileWrite($hFile, $sContent)
	FileClose($hFile)

	Return 1
EndFunc   ;==>_WigleCSV_WriteFile

; ===============================================================================================================================
; Function Name:    _WigleCSV_ReadFile
; Description:      Imports WigleCSV file (v1.4 or v1.6) and returns array of observations
; Parameter(s):     $sFilePath - Full path to WigleCSV file
; Return Value(s):  Success - 2D array of observations (see structure below)
;                   Failure - Returns 0 and sets @error
;                   @error 1 - File read error
;                   @error 2 - Invalid CSV format
; Returned Array Structure:
;   Row 0: [Version, ColumnCount] - Metadata about the file format
;   Row 1+: Each observation [MAC, SSID, Auth, Encr, SecType, NetType, DateTime, Channel, Frequency, RSSI, Lat_DDD, Lon_DDD, Alt, Accuracy, RadType]
;   - MAC: MAC address
;   - SSID: Network name
;   - Auth: Authentication type (e.g., "WPA3-Personal", "WPA2-Enterprise")
;   - Encr: Encryption type (e.g., "CCMP", "GCMP", "TKIP")
;   - SecType: Security type (1=Open, 2=WEP, 3=WPA family)
;   - NetType: Network type ("Infrastructure" or "Ad Hoc")
;   - DateTime: "YYYY-MM-DD HH:MM:SS"
;   - Channel: WiFi channel number
;   - Frequency: Center frequency in MHz (0 if v1.4)
;   - RSSI: Signal strength in dBm
;   - Lat_DDD: Latitude in decimal degrees
;   - Lon_DDD: Longitude in decimal degrees
;   - Alt: Altitude in meters
;   - Accuracy: GPS accuracy in meters
;   - RadType: Radio type based on frequency/channel
; Notes:            Automatically detects v1.4 (11 cols) vs v1.6 (14 cols)
;                   Requires _ParseCSV() function from ParseCSV.au3
; ===============================================================================================================================
Func _WigleCSV_ReadFile($sFilePath)
	; Check if file exists
	If Not FileExists($sFilePath) Then Return SetError(1, 0, 0)

	; Parse CSV file (requires _ParseCSV function from calling application)
	Local $aCSV = _ParseCSV($sFilePath, ',|', '"')
	If @error Or Not IsArray($aCSV) Then Return SetError(2, 0, 0)

	Local $iRows = UBound($aCSV)
	Local $iCols = UBound($aCSV, 2)

	If $iRows < 2 Then Return SetError(2, 0, 0) ; Need at least header + 1 data row

	; Detect version (v1.4 has 11 cols, v1.6 has 14 cols)
	Local $sVersion = "1.4"
	If $iCols = 14 Then $sVersion = "1.6"

	; Prepare result array (metadata + observations)
	Local $aResult[$iRows][15] ; Row 0 = metadata, Row 1+ = observations

	; Set metadata in row 0
	$aResult[0][0] = $sVersion
	$aResult[0][1] = $iCols

	; Process each observation (skip row 0 = pre-header, row 1 = header)
	Local $iResultRow = 1
	For $i = 2 To $iRows - 1
		Local $sMac = StringUpper($aCSV[$i][0])
		Local $sSSID = $aCSV[$i][1]

		; Remove quotes from SSID if present
		If StringLeft($sSSID, 1) = '"' And StringRight($sSSID, 1) = '"' Then
			$sSSID = StringTrimLeft(StringTrimRight($sSSID, 1), 1)
		EndIf

		Local $sAuthMode = $aCSV[$i][2]
		Local $sDateTime = $aCSV[$i][3]
		Local $iChannel, $iFreq, $iRSSI, $fLat, $fLon, $fAlt, $fAccuracy

		; Parse based on version
		If $iCols = 14 Then ; v1.6 format
			$iChannel = $aCSV[$i][4]
			$iFreq = $aCSV[$i][5]
			$iRSSI = $aCSV[$i][6]
			$fLat = $aCSV[$i][7]
			$fLon = $aCSV[$i][8]
			$fAlt = $aCSV[$i][9]
			$fAccuracy = $aCSV[$i][10]
			; RCOIs and MfgrId available but not used: $aCSV[$i][11], $aCSV[$i][12]
		Else ; v1.4 format (11 cols)
			$iChannel = $aCSV[$i][4]
			$iFreq = 0 ; Not available in v1.4
			$iRSSI = $aCSV[$i][5]
			$fLat = $aCSV[$i][6]
			$fLon = $aCSV[$i][7]
			$fAlt = $aCSV[$i][8]
			$fAccuracy = $aCSV[$i][9]
		EndIf

		; Skip invalid entries
		If StringLeft($sDateTime, 4) = "1969" Then ContinueLoop

		; Parse AuthMode to get Auth, Encr, SecType, NetType
		Local $aAuthParse = _WigleCSV_ParseAuthMode($sAuthMode)
		Local $sAuth = $aAuthParse[0]
		Local $sEncr = $aAuthParse[1]
		Local $iSecType = $aAuthParse[2]
		Local $sNetType = $aAuthParse[3]

		; Determine radio type based on frequency (if available) or channel
		Local $sRadType = "802.11"
		If $iFreq > 0 Then
			; Use frequency for more accurate band detection
			If $iFreq >= 2412 And $iFreq <= 2484 Then
				$sRadType = "802.11g" ; 2.4 GHz band
			ElseIf $iFreq >= 5160 And $iFreq <= 5980 Then
				$sRadType = "802.11n" ; 5 GHz band (could also be ac/ax)
			ElseIf $iFreq >= 5955 And $iFreq <= 7115 Then
				$sRadType = "802.11ax" ; 6 GHz band (WiFi 6E)
			EndIf
		Else
			; Fallback to channel-based detection for v1.4 format
			If $iChannel >= 1 And $iChannel <= 14 Then
				$sRadType = "802.11g" ; 2.4 GHz band
			ElseIf $iChannel > 14 Then
				$sRadType = "802.11n" ; 5 GHz band
			EndIf
		EndIf

		; Fill result array
		$aResult[$iResultRow][0] = $sMac
		$aResult[$iResultRow][1] = $sSSID
		$aResult[$iResultRow][2] = $sAuth
		$aResult[$iResultRow][3] = $sEncr
		$aResult[$iResultRow][4] = $iSecType
		$aResult[$iResultRow][5] = $sNetType
		$aResult[$iResultRow][6] = $sDateTime
		$aResult[$iResultRow][7] = $iChannel
		$aResult[$iResultRow][8] = $iFreq
		$aResult[$iResultRow][9] = $iRSSI
		$aResult[$iResultRow][10] = $fLat
		$aResult[$iResultRow][11] = $fLon
		$aResult[$iResultRow][12] = $fAlt
		$aResult[$iResultRow][13] = $fAccuracy
		$aResult[$iResultRow][14] = $sRadType

		$iResultRow += 1
	Next

	; Resize array to actual size
	ReDim $aResult[$iResultRow][15]

	Return $aResult
EndFunc   ;==>_WigleCSV_ReadFile
