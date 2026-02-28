#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Icons\icon.ico
#AutoIt3Wrapper_Res_ProductName=Vistumbler
#AutoIt3Wrapper_Res_CompanyName=TechIdiots LLC
#AutoIt3Wrapper_Res_Language=1033
#AutoIt3Wrapper_Res_requestedExecutionLevel=asInvoker
#AutoIt3Wrapper_Run_Tidy=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
;License Information------------------------------------
;Copyright (C) 2026 Andrew Calcutt
;This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; Version 2 of the License.
;This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
;You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
;--------------------------------------------------------
;AutoIt Version: v3.3.18.0
$Script_Author = 'Andrew Calcutt'
$Script_Name = 'Vistumbler Exporter'
$Script_Website = 'http://www.Vistumbler.net'
$Script_Function = 'Reads the vistumbler DB and exports based on input options'
$version = 'v8.0.0'
$last_modified = '2026/02/09'
HttpSetUserAgent($Script_Name & ' ' & $version)
;--------------------------------------------------------
#include <SQLite.au3>
#include "UDFs\ZIP.au3"
#include <INet.au3>
#include <String.au3>
$oMyError = ObjEvent("AutoIt.Error", "_Error")

Dim $Default_settings = @ScriptDir & '\Settings\vistumbler_settings.ini'
Dim $Profile_settings = @AppDataDir & '\Vistumbler\vistumbler_settings.ini'
Dim $PortableMode = IniRead($Default_settings, 'Vistumbler', 'PortableMode', 0)
If $PortableMode = 1 Then
	$settings = $Default_settings
	$TmpDir = @ScriptDir & '\temp\'
Else
	$settings = $Profile_settings
	If FileExists($Default_settings) And FileExists($settings) = 0 Then FileCopy($Default_settings, $settings, 1)
	$TmpDir = @TempDir & '\Vistumbler\'
EndIf

Dim $DBhndl
Dim $Debug = 0
Dim $filetype = 'cd' ;Default file type (d=detailed VS1, cd=detailed CSV, cs=summary CSV, k=KML, w=WifiDB Upload)
Dim $filename = $TmpDir & 'Save.csv'
Dim $VistumblerDB = $TmpDir & 'VistumblerDB.SDB'
Dim $ImageDir = @ScriptDir & '\Images\'

;Set GUI text based on default language
Dim $LanguageDir = @ScriptDir & '\Languages\'
Dim $DefaultLanguageFile = IniRead($settings, 'Vistumbler', 'LanguageFile', 'English.ini')
Dim $DefaultLanguagePath = $LanguageDir & $DefaultLanguageFile
If FileExists($DefaultLanguagePath) = 0 Then
	$DefaultLanguageFile = 'English.ini'
	$DefaultLanguagePath = $LanguageDir & $DefaultLanguageFile
EndIf
Dim $Column_Names_Line = IniRead($DefaultLanguagePath, 'Column_Names', 'Column_Line', '#')
Dim $Column_Names_Active = IniRead($DefaultLanguagePath, 'Column_Names', 'Column_Active', 'Active')
Dim $Column_Names_SSID = IniRead($DefaultLanguagePath, 'Column_Names', 'Column_SSID', 'SSID')
Dim $Column_Names_BSSID = IniRead($DefaultLanguagePath, 'Column_Names', 'Column_BSSID', 'Mac Address')
Dim $Column_Names_MANUF = IniRead($DefaultLanguagePath, 'Column_Names', 'Column_Manufacturer', 'Manufacturer')
Dim $Column_Names_Signal = IniRead($DefaultLanguagePath, 'Column_Names', 'Column_Signal', 'Signal')
Dim $Column_Names_Authentication = IniRead($DefaultLanguagePath, 'Column_Names', 'Column_Authentication', 'Authentication')
Dim $Column_Names_Encryption = IniRead($DefaultLanguagePath, 'Column_Names', 'Column_Encryption', 'Encryption')
Dim $Column_Names_RadioType = IniRead($DefaultLanguagePath, 'Column_Names', 'Column_RadioType', 'Radio Type')
Dim $Column_Names_Channel = IniRead($DefaultLanguagePath, 'Column_Names', 'Column_Channel', 'Channel')
Dim $Column_Names_Latitude = IniRead($DefaultLanguagePath, 'Column_Names', 'Column_Latitude', 'Latitude')
Dim $Column_Names_Longitude = IniRead($DefaultLanguagePath, 'Column_Names', 'Column_Longitude', 'Longitude')
Dim $Column_Names_LatitudeDMS = IniRead($DefaultLanguagePath, 'Column_Names', 'Column_LatitudeDMS', 'Latitude (DDMMSS)')
Dim $Column_Names_LongitudeDMS = IniRead($DefaultLanguagePath, 'Column_Names', 'Column_LongitudeDMS', 'Longitude (DDMMSS)')
Dim $Column_Names_LatitudeDMM = IniRead($DefaultLanguagePath, 'Column_Names', 'Column_LatitudeDMM', 'Latitude (DDMMMM)')
Dim $Column_Names_LongitudeDMM = IniRead($DefaultLanguagePath, 'Column_Names', 'Column_LongitudeDMM', 'Longitude (DDMMMM)')
Dim $Column_Names_BasicTransferRates = IniRead($DefaultLanguagePath, 'Column_Names', 'Column_BasicTransferRates', 'Basic Transfer Rates')
Dim $Column_Names_OtherTransferRates = IniRead($DefaultLanguagePath, 'Column_Names', 'Column_OtherTransferRates', 'Other Transfer Rates')
Dim $Column_Names_FirstActive = IniRead($DefaultLanguagePath, 'Column_Names', 'Column_FirstActive', 'First Active')
Dim $Column_Names_LastActive = IniRead($DefaultLanguagePath, 'Column_Names', 'Column_LastActive', 'Last Active')
Dim $Column_Names_NetworkType = IniRead($DefaultLanguagePath, 'Column_Names', 'Column_NetworkType', 'Network Type')
Dim $Column_Names_Label = IniRead($DefaultLanguagePath, 'Column_Names', 'Column_Label', 'Label')

Dim $MapActiveAPs = 0
Dim $MapDeadAPs = 0
Dim $MapAccessPoints = 0
Dim $MapTrack = 0
Dim $apiurl
Dim $WifiDb_User
Dim $WifiDb_ApiKey
Dim $WifiDb_SessionID

For $loop = 1 To $CmdLine[0]
	If StringInStr($CmdLine[$loop], '/f') Then
		$filesplit = _StringExplode($CmdLine[$loop], "=", 1)
		If IsArray($filesplit) Then $filename = $filesplit[1]
	EndIf
	If StringInStr($CmdLine[$loop], '/t') Then
		$filesplit = _StringExplode($CmdLine[$loop], "=", 1)
		If IsArray($filesplit) Then $filetype = $filesplit[1]
	EndIf
	If StringInStr($CmdLine[$loop], '/a') Then
		$MapActiveAPs = 1
		$MapAccessPoints = 1
	EndIf
	If StringInStr($CmdLine[$loop], '/p') Then
		$MapTrack = 1
	EndIf
	If StringInStr($CmdLine[$loop], '/db') Then
		$filesplit = _StringExplode($CmdLine[$loop], "=", 1)
		If IsArray($filesplit) Then $VistumblerDB = $filesplit[1]
	EndIf
	If StringInStr($CmdLine[$loop], '/d') And StringInStr($CmdLine[$loop], '/db') = 0 Then
		$MapDeadAPs = 1
		$MapAccessPoints = 1
	EndIf
	If StringInStr($CmdLine[$loop], '/u') Then
		$urlsplit = _StringExplode($CmdLine[$loop], "=", 1)
		If IsArray($urlsplit) Then $apiurl = $urlsplit[1]
	EndIf
	If StringInStr($CmdLine[$loop], '/wa') Then
		$wasplit = _StringExplode($CmdLine[$loop], "=", 1)
		If IsArray($wasplit) Then $WifiDb_User = $wasplit[1]
	EndIf
	If StringInStr($CmdLine[$loop], '/wk') Then
		$wksplit = _StringExplode($CmdLine[$loop], "=", 1)
		If IsArray($wksplit) Then $WifiDb_ApiKey = $wksplit[1]
	EndIf
	If StringInStr($CmdLine[$loop], '/wsid') Then
		$wsidsplit = _StringExplode($CmdLine[$loop], "=", 1)
		If IsArray($wsidsplit) Then $WifiDb_SessionID = $wsidsplit[1]
	EndIf
	If StringInStr($CmdLine[$loop], '/?') Then
		MsgBox(0, '', 'to be filled in later. the old help was outdated an no longer relevant')
		Exit
	EndIf
Next

If FileExists($VistumblerDB) Then
	_SQLite_Startup()
	$DBhndl = _SQLite_Open($VistumblerDB, $SQLITE_OPEN_READONLY)
	If $filetype = 'd' Then
		_ExportVS1($filename)
	ElseIf $filetype = 'z' Then
		_ExportVSZ($filename)
	ElseIf $filetype = 'cd' Then
		_ExportToCSV($filename, 1)
	ElseIf $filetype = 'cs' Then
		_ExportToCSV($filename, 0)
	ElseIf $filetype = 'k' Then
		_AutoSaveKml($filename, $MapTrack, $MapAccessPoints, $MapActiveAPs, $MapDeadAPs)
	ElseIf $filetype = 'w' Then
		_UploadActiveApsToWifidb()
	EndIf
	_SQLite_Close($DBhndl)
EndIf
Exit

;-------------------------------------------------------------------------------------------------------------------------------
;                                                       FUNCTIONS
;-------------------------------------------------------------------------------------------------------------------------------

Func _ExportVS1($savefile) ;writes vistumbler detailed data to a txt file
	$file = "# Vistumbler VS1 - Detailed Export Version 4.0" & @CRLF & _
			"# Created By: " & $Script_Name & ' ' & $version & @CRLF & _
			"# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------" & @CRLF & _
			"# GpsID|Latitude|Longitude|NumOfSatalites|HorizontalDilutionOfPrecision|Altitude(m)|HeightOfGeoidAboveWGS84Ellipsoid(m)|Speed(km/h)|Speed(MPH)|TrackAngle(Deg)|Date(UTC y-m-d)|Time(UTC h:m:s.ms)" & @CRLF & _
			"# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------" & @CRLF
	;Export GPS IDs
	Local $GpsMatchArray, $iRows, $iColumns, $iRval
	$query = "SELECT GpsID, Latitude, Longitude, NumOfSats, HorDilPitch, Alt, Geo, SpeedInMPH, SpeedInKmH, TrackAngle, Date1, Time1 FROM GPS ORDER BY Date1, Time1"
	$iRval = _SQLite_GetTable2d($DBhndl, $query, $GpsMatchArray, $iRows, $iColumns)
	$FoundGpsMatch = $iRows
	For $exp = 1 To $iRows
		$ExpGID = $GpsMatchArray[$exp][0]
		$ExpLat = $GpsMatchArray[$exp][1]
		$ExpLon = $GpsMatchArray[$exp][2]
		$ExpSat = $GpsMatchArray[$exp][3]
		$ExpHorDilPitch = $GpsMatchArray[$exp][4]
		$ExpAlt = $GpsMatchArray[$exp][5]
		$ExpGeo = $GpsMatchArray[$exp][6]
		$ExpSpeedMPH = $GpsMatchArray[$exp][7]
		$ExpSpeedKmh = $GpsMatchArray[$exp][8]
		$ExpTrack = $GpsMatchArray[$exp][9]
		$ExpDate = $GpsMatchArray[$exp][10]
		$ExpTime = $GpsMatchArray[$exp][11]
		$file &= $ExpGID & '|' & $ExpLat & '|' & $ExpLon & '|' & $ExpSat & '|' & $ExpHorDilPitch & '|' & $ExpAlt & '|' & $ExpGeo & '|' & $ExpSpeedKmh & '|' & $ExpSpeedMPH & '|' & $ExpTrack & '|' & $ExpDate & '|' & $ExpTime & @CRLF
	Next

	;Export AP Information
	$file &= "# ---------------------------------------------------------------------------------------------------------------------------------------------------------" & @CRLF & _
			"# SSID|BSSID|MANUFACTURER|Authentication|Encryption|Security Type|Radio Type|Channel|Basic Transfer Rates|Other Transfer Rates|High Signal|High RSSI|Network Type|Label|GID,SIGNAL,RSSI" & @CRLF & _
			"# ---------------------------------------------------------------------------------------------------------------------------------------------------------" & @CRLF

	Local $ApMatchArray, $iRows, $iColumns, $iRval
	$query = "SELECT ApID, SSID, BSSID, NETTYPE, RADTYPE, CHAN, AUTH, ENCR, SecType, BTX, OTX, HighSignal, HighRSSI, MANU, LABEL, HighGpsHistID, FirstHistID, LastHistID FROM AP"
	$iRval = _SQLite_GetTable2d($DBhndl, $query, $ApMatchArray, $iRows, $iColumns)
	$FoundApMatch = $iRows
	If $FoundApMatch > 0 Then
		For $exp = 1 To $iRows
			$ExpApID = $ApMatchArray[$exp][0]
			$ExpSSID = $ApMatchArray[$exp][1]
			$ExpBSSID = $ApMatchArray[$exp][2]
			$ExpNET = $ApMatchArray[$exp][3]
			$ExpRAD = $ApMatchArray[$exp][4]
			$ExpCHAN = $ApMatchArray[$exp][5]
			$ExpAUTH = $ApMatchArray[$exp][6]
			$ExpENCR = $ApMatchArray[$exp][7]
			$ExpSECTYPE = $ApMatchArray[$exp][8]
			$ExpBTX = $ApMatchArray[$exp][9]
			$ExpOTX = $ApMatchArray[$exp][10]
			$ExpHighSig = $ApMatchArray[$exp][11]
			$ExpHighRSSI = $ApMatchArray[$exp][12]
			$ExpMANU = $ApMatchArray[$exp][13]
			$ExpLAB = $ApMatchArray[$exp][14]
			$ExpHighGpsID = $ApMatchArray[$exp][15]
			$ExpFirstID = $ApMatchArray[$exp][16]
			$ExpLastID = $ApMatchArray[$exp][17]

			;Create GID,SIG String
			$ExpGidSid = ''
			Local $HistMatchArray, $iRows, $iColumns, $iRval
			$query = "SELECT GpsID, Signal, RSSI FROM Hist WHERE ApID=" & $ExpApID
			$iRval = _SQLite_GetTable2d($DBhndl, $query, $HistMatchArray, $iRows, $iColumns)
			$FoundHistMatch = $iRows
			For $epgs = 1 To $iRows
				$ExpGID = $HistMatchArray[$epgs][0]
				$ExpSig = $HistMatchArray[$epgs][1]
				$ExpRSSI = $HistMatchArray[$epgs][2]
				If $epgs = 1 Then
					$ExpGidSid = $ExpGID & ',' & $ExpSig & ',' & $ExpRSSI
				Else
					$ExpGidSid &= '\' & $ExpGID & ',' & $ExpSig & ',' & $ExpRSSI
				EndIf
			Next

			$file &= $ExpSSID & '|' & $ExpBSSID & '|' & $ExpMANU & '|' & $ExpAUTH & '|' & $ExpENCR & '|' & $ExpSECTYPE & '|' & $ExpRAD & '|' & $ExpCHAN & '|' & $ExpBTX & '|' & $ExpOTX & '|' & $ExpHighSig & '|' & $ExpHighRSSI & '|' & $ExpNET & '|' & $ExpLAB & '|' & $ExpGidSid & @CRLF
		Next
		$savefile_handle = FileOpen($savefile, 128 + 2) ;Open in UTF-8 write mode
		FileWrite($savefile_handle, $file)
		FileClose($savefile_handle)
		Return (1)
	Else
		Return (0)
	EndIf
EndFunc   ;==>_ExportVS1

Func _ExportToCSV($savefile, $Detailed = 0) ;writes vistumbler data to a csv file
	If $Detailed = 0 Then
		$file = "SSID,BSSID,MANUFACTURER,HIGHEST SIGNAL W/GPS,AUTHENTICATION,ENCRYPTION,RADIO TYPE,CHANNEL,LATITUDE,LONGITUDE,BTX,OTX,FIRST SEEN(UTC),LAST SEEN(UTC),NETWORK TYPE,LABEL" & @CRLF
	ElseIf $Detailed = 1 Then
		$file = "SSID,BSSID,MANUFACTURER,SIGNAL,AUTHENTICATION,ENCRYPTION,RADIO TYPE,CHANNEL,BTX,OTX,NETWORK TYPE,LABEL,LATITUDE,LONGITUDE,SATELLITES,HDOP,ALTITUDE,HEIGHT OF GEOID,SPEED(km/h),SPEED(MPH),TRACK ANGLE,DATE(UTC),TIME(UTC)" & @CRLF
	EndIf
	Local $ApMatchArray, $iRows, $iColumns, $iRval
	$query = "SELECT ApID, SSID, BSSID, NETTYPE, RADTYPE, CHAN, AUTH, ENCR, SecType, BTX, OTX, MANU, LABEL, HighGpsHistID, FirstHistID, LastHistID, LastGpsID, Active FROM AP"
	$iRval = _SQLite_GetTable2d($DBhndl, $query, $ApMatchArray, $iRows, $iColumns)
	$FoundApMatch = $iRows
	If $FoundApMatch > 0 Then
		For $exp = 1 To $iRows
			$ExpApID = $ApMatchArray[$exp][0]
			$ExpSSID = $ApMatchArray[$exp][1]
			$ExpBSSID = $ApMatchArray[$exp][2]
			$ExpNET = $ApMatchArray[$exp][3]
			$ExpRAD = $ApMatchArray[$exp][4]
			$ExpCHAN = $ApMatchArray[$exp][5]
			$ExpAUTH = $ApMatchArray[$exp][6]
			$ExpENCR = $ApMatchArray[$exp][7]
			$ExpBTX = $ApMatchArray[$exp][9]
			$ExpOTX = $ApMatchArray[$exp][10]
			$ExpMANU = $ApMatchArray[$exp][11]
			$ExpLAB = $ApMatchArray[$exp][12]
			$ExpHighGpsID = $ApMatchArray[$exp][13]
			$ExpFirstID = $ApMatchArray[$exp][14]
			$ExpLastID = $ApMatchArray[$exp][15]

			If $Detailed = 0 Then
				;Get High GPS Signal
				If $ExpHighGpsID = 0 Then
					$ExpHighGpsSig = 0
					$ExpHighGpsLat = 'N 0000.0000'
					$ExpHighGpsLon = 'E 0000.0000'
				Else
					Local $HistMatchArray, $iRows, $iColumns, $iRval
					$query = "SELECT Signal, GpsID FROM Hist WHERE HistID=" & $ExpHighGpsID
					$iRval = _SQLite_GetTable2d($DBhndl, $query, $HistMatchArray, $iRows, $iColumns)
					$ExpHighGpsSig = $HistMatchArray[1][0]
					$ExpHighGpsID = $HistMatchArray[1][1]
					Local $GpsMatchArray, $iRows, $iColumns, $iRval
					$query = "SELECT Latitude, Longitude FROM GPS WHERE GpsID=" & $ExpHighGpsID
					$iRval = _SQLite_GetTable2d($DBhndl, $query, $GpsMatchArray, $iRows, $iColumns)
					$ExpHighGpsLat = $GpsMatchArray[1][0]
					$ExpHighGpsLon = $GpsMatchArray[1][1]
				EndIf
				;Get First Found Time From FirstHistID
				Local $HistMatchArray, $iRows, $iColumns, $iRval
				$query = "SELECT GpsID FROM Hist WHERE HistID=" & $ExpFirstID
				$iRval = _SQLite_GetTable2d($DBhndl, $query, $HistMatchArray, $iRows, $iColumns)
				$ExpFirstGpsId = $HistMatchArray[1][0]
				Local $GpsMatchArray, $iRows, $iColumns, $iRval
				$query = "SELECT Date1, Time1 FROM GPS WHERE GpsID=" & $ExpFirstGpsId
				$iRval = _SQLite_GetTable2d($DBhndl, $query, $GpsMatchArray, $iRows, $iColumns)
				$FirstDateTime = $GpsMatchArray[1][0] & ' ' & $GpsMatchArray[1][1]
				;Get Last Found Time From LastHistID
				Local $HistMatchArray, $iRows, $iColumns, $iRval
				$query = "SELECT GpsID FROM Hist WHERE HistID=" & $ExpLastID
				$iRval = _SQLite_GetTable2d($DBhndl, $query, $HistMatchArray, $iRows, $iColumns)
				$ExpLastGpsID = $HistMatchArray[1][0]
				Local $GpsMatchArray, $iRows, $iColumns, $iRval
				$query = "SELECT Date1, Time1 FROM GPS WHERE GpsID=" & $ExpLastGpsID
				$iRval = _SQLite_GetTable2d($DBhndl, $query, $GpsMatchArray, $iRows, $iColumns)
				$LastDateTime = $GpsMatchArray[1][0] & ' ' & $GpsMatchArray[1][1]
				;Write summary csv line
				$file &= StringReplace($ExpSSID, ',', '') & ',' & $ExpBSSID & ',' & StringReplace($ExpMANU, ',', '') & ',' & $ExpHighGpsSig & ',' & $ExpAUTH & ',' & $ExpENCR & ',' & $ExpRAD & ',' & $ExpCHAN & ',' & StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($ExpHighGpsLat), 'S', '-'), 'N', ''), ' ', '') & ',' & StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($ExpHighGpsLon), 'W', '-'), 'E', ''), ' ', '') & ',' & $ExpBTX & ',' & $ExpOTX & ',' & $FirstDateTime & ',' & $LastDateTime & ',' & $ExpNET & ',' & StringReplace($ExpLAB, ',', '') & @CRLF
			ElseIf $Detailed = 1 Then
				;Get All Signals and GpsIDs for current ApID
				Local $HistMatchArray, $iRows, $iColumns, $iRval
				$query = "SELECT GpsID, Signal FROM Hist WHERE ApID=" & $ExpApID & " And Signal<>0 ORDER BY Date1, Time1"
				$iRval = _SQLite_GetTable2d($DBhndl, $query, $HistMatchArray, $iRows, $iColumns)
				$FoundHistMatch = $iRows
				For $exph = 1 To $iRows
					$ExpGID = $HistMatchArray[$exph][0]
					$ExpSig = $HistMatchArray[$exph][1]
					;Get GPS Data Based on GpsID
					Local $GpsMatchArray, $iRows, $iColumns, $iRval
					$query = "SELECT Latitude, Longitude, NumOfSats, HorDilPitch, Alt, Geo, SpeedInMPH, SpeedInKmH, TrackAngle, Date1, Time1 FROM GPS WHERE GpsID=" & $ExpGID
					$iRval = _SQLite_GetTable2d($DBhndl, $query, $GpsMatchArray, $iRows, $iColumns)
					$ExpLat = StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($GpsMatchArray[1][0]), 'S', '-'), 'N', ''), ' ', '')
					$ExpLon = StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($GpsMatchArray[1][1]), 'W', '-'), 'E', ''), ' ', '')
					$ExpSat = $GpsMatchArray[1][2]
					$ExpHorDilPitch = $GpsMatchArray[1][3]
					$ExpAlt = $GpsMatchArray[1][4]
					$ExpGeo = $GpsMatchArray[1][5]
					$ExpSpeedMPH = $GpsMatchArray[1][6]
					$ExpSpeedKmh = $GpsMatchArray[1][7]
					$ExpTrack = $GpsMatchArray[1][8]
					$ExpDate = $GpsMatchArray[1][9]
					$ExpTime = $GpsMatchArray[1][10]
					;Write detailed csv line
					$file &= '"' & $ExpSSID & '",' & $ExpBSSID & ',"' & $ExpMANU & '",' & $ExpSig & ',' & $ExpAUTH & ',' & $ExpENCR & ',' & $ExpRAD & ',' & $ExpCHAN & ',' & $ExpBTX & ',' & $ExpOTX & ',' & $ExpNET & ',"' & $ExpLAB & '",' & $ExpLat & ',' & $ExpLon & ',' & $ExpSat & ',' & $ExpHorDilPitch & ',' & $ExpAlt & ',' & $ExpGeo & ',' & $ExpSpeedKmh & ',' & $ExpSpeedMPH & ',' & $ExpTrack & ',' & $ExpDate & ',' & $ExpTime & @CRLF
				Next
			EndIf
		Next
		$savefile_handle = FileOpen($savefile, 128 + 2) ;Open in UTF-8 write mode
		FileWrite($savefile_handle, $file)
		FileClose($savefile_handle)
		Return (1)
	Else
		Return (0)
	EndIf
EndFunc   ;==>_ExportToCSV

Func _ExportVSZ($savefile)
	$vsz_temp_file = $TmpDir & 'data.zip'
	$vsz_file = $savefile
	$vs1_file = $TmpDir & 'data.vs1'
	If FileExists($vsz_temp_file) Then FileDelete($vsz_temp_file)
	If FileExists($vsz_file) Then FileDelete($vsz_file)
	If FileExists($vs1_file) Then FileDelete($vs1_file)
	_ExportVS1($vs1_file)
	_Zip_Create($vsz_temp_file)
	_Zip_AddItem($vsz_temp_file, $vs1_file)
	FileMove($vsz_temp_file, $vsz_file)
	FileDelete($vs1_file)
EndFunc   ;==>_ExportVSZ

Func _AutoSaveKml($kml, $MapGpsTrack = 1, $MapAPs = 1, $MapActive = 1, $MapDead = 1)
	$file = '<?xml version="1.0" encoding="utf-8"?>' & @CRLF _
			 & '<kml xmlns="http://earth.google.com/kml/2.0">' & @CRLF _
			 & '<Document>' & @CRLF _
			 & '<description>' & 'Vistumbler AutoKML' & ' - By ' & 'Andrew Calcutt' & '</description>' & @CRLF _
			 & '<name>' & 'Vistumbler AutoKML' & ' ' & 'V1.0' & '</name>' & @CRLF
	If $MapAPs = 1 Then
			If $MapActive = 1 Then
				$file &= '<Style id="secureStyle">' & @CRLF _
						 & '<IconStyle>' & @CRLF _
						 & '<scale>.5</scale>' & @CRLF _
						 & '<Icon>' & @CRLF _
						 & '<href>' & $ImageDir & 'secure.png</href>' & @CRLF _
						 & '</Icon>' & @CRLF _
						 & '</IconStyle>' & @CRLF _
						 & '</Style>' & @CRLF _
						 & '<Style id="wepStyle">' & @CRLF _
						 & '<IconStyle>' & @CRLF _
						 & '<scale>.5</scale>' & @CRLF _
						 & '<Icon>' & @CRLF _
						 & '<href>' & $ImageDir & 'secure-wep.png</href>' & @CRLF _
						 & '</Icon>' & @CRLF _
						 & '</IconStyle>' & @CRLF _
						 & '</Style>' & @CRLF _
						 & '<Style id="openStyle">' & @CRLF _
						 & '<IconStyle>' & @CRLF _
						 & '<scale>.5</scale>' & @CRLF _
						 & '<Icon>' & @CRLF _
						 & '<href>' & $ImageDir & 'open.png</href>' & @CRLF _
						 & '</Icon>' & @CRLF _
						 & '</IconStyle>' & @CRLF _
						 & '</Style>' & @CRLF

			EndIf
			If $MapDead = 1 Then
				$file &= '<Style id="secureDeadStyle">' & @CRLF _
						 & '<IconStyle>' & @CRLF _
						 & '<scale>.5</scale>' & @CRLF _
						 & '<Icon>' & @CRLF _
						 & '<href>' & $ImageDir & 'secure_dead.png</href>' & @CRLF _
						 & '</Icon>' & @CRLF _
						 & '</IconStyle>' & @CRLF _
						 & '</Style>' & @CRLF _
						 & '<Style id="wepDeadStyle">' & @CRLF _
						 & '<IconStyle>' & @CRLF _
						 & '<scale>.5</scale>' & @CRLF _
						 & '<Icon>' & @CRLF _
						 & '<href>' & $ImageDir & 'secure-wep_dead.png</href>' & @CRLF _
						 & '</Icon>' & @CRLF _
						 & '</IconStyle>' & @CRLF _
						 & '</Style>' & @CRLF _
						 & '<Style id="openDeadStyle">' & @CRLF _
						 & '<IconStyle>' & @CRLF _
						 & '<scale>.5</scale>' & @CRLF _
						 & '<Icon>' & @CRLF _
						 & '<href>' & $ImageDir & 'open_dead.png</href>' & @CRLF _
						 & '</Icon>' & @CRLF _
						 & '</IconStyle>' & @CRLF _
						 & '</Style>' & @CRLF
			EndIf
	EndIf
	If $MapGpsTrack = 1 Then
		$file &= '<Style id="Location">' & @CRLF _
				 & '<LineStyle>' & @CRLF _
				 & '<color>7f0000ff</color>' & @CRLF _
				 & '<width>4</width>' & @CRLF _
				 & '</LineStyle>' & @CRLF _
				 & '</Style>' & @CRLF
	EndIf
	If $MapAPs = 1 Then
		ConsoleWrite('-->' & $MapActive & '-' & $MapDead & @CRLF)
		If $MapActive = 1 Or $MapDead = 1 Then
			If $MapActive = 1 And $MapDead = 1 Then
				$query = "SELECT SSID, BSSID, NETTYPE, RADTYPE, CHAN, AUTH, ENCR, BTX, OTX, MANU, LABEL, HighGpsHistID, Active, SecType FROM AP WHERE HighGpsHistId <> 0"
				ElseIf $MapActive = 1 Then
				$query = "SELECT SSID, BSSID, NETTYPE, RADTYPE, CHAN, AUTH, ENCR, BTX, OTX, MANU, LABEL, HighGpsHistID, Active, SecType FROM AP WHERE HighGpsHistId <> 0 And Active = 1"
				ElseIf $MapDead = 1 Then
				$query = "SELECT SSID, BSSID, NETTYPE, RADTYPE, CHAN, AUTH, ENCR, BTX, OTX, MANU, LABEL, HighGpsHistID, Active, SecType FROM AP WHERE HighGpsHistId <> 0 And Active = 0"
				EndIf
			ConsoleWrite('-->' & $query & @CRLF)
			Local $ApMatchArray, $iRows, $iColumns, $iRval
			$iRval = _SQLite_GetTable2d($DBhndl, $query, $ApMatchArray, $iRows, $iColumns)
			$FoundApMatch = $iRows
			If $FoundApMatch <> 0 Then
				$FoundApWithGps = 1
				$file_open = ''
				$file_wep = ''
				$file_sec = ''
				For $exp = 1 To $FoundApMatch
					$ExpSSID = $ApMatchArray[$exp][0]
					$ExpBSSID = $ApMatchArray[$exp][1]
					$ExpNET = $ApMatchArray[$exp][2]
					$ExpRAD = $ApMatchArray[$exp][3]
					$ExpCHAN = $ApMatchArray[$exp][4]
					$ExpAUTH = $ApMatchArray[$exp][5]
					$ExpENCR = $ApMatchArray[$exp][6]
					$ExpBTX = $ApMatchArray[$exp][7]
					$ExpOTX = $ApMatchArray[$exp][8]
					$ExpMANU = $ApMatchArray[$exp][9]
					$ExpLAB = $ApMatchArray[$exp][10]
					$ExpHighGpsHistID = $ApMatchArray[$exp][11] - 0
					;$ExpFirstID = $ApMatchArray[$exp][13] - 0
					;$ExpLastID = $ApMatchArray[$exp][14] - 0
					$ExpActive = $ApMatchArray[$exp][12]
					$ExpSecType = $ApMatchArray[$exp][13]
					;Get Gps ID of HighGpsHistId
					Local $HistMatchArray, $iRows, $iColumns, $iRval
					$query = "SELECT GpsID FROM Hist Where HistID = " & $ExpHighGpsHistID
					$iRval = _SQLite_GetTable2d($DBhndl, $query, $HistMatchArray, $iRows, $iColumns)
					$FoundHistMatch = $iRows
					If $FoundHistMatch <> 0 Then
						$ExpGID = $HistMatchArray[1][0]
						;Get Latitude and Longitude
						Local $GpsMatchArray, $iRows, $iColumns, $iRval
						$query = "SELECT Latitude, Longitude FROM GPS WHERE GpsId = " & $ExpGID
						$iRval = _SQLite_GetTable2d($DBhndl, $query, $GpsMatchArray, $iRows, $iColumns)
						$FoundGpsMatch = $iRows
						If $FoundGpsMatch <> 0 Then
							$ExpLat = _Format_GPS_DMM_to_DDD($GpsMatchArray[1][0])
							$ExpLon = _Format_GPS_DMM_to_DDD($GpsMatchArray[1][1])
								If $ExpSecType = 1 Then
									$file_open &= '<Placemark>' & @CRLF _
											 & '<name></name>' & @CRLF _
											 & '<description><![CDATA[<b>' & $Column_Names_SSID & ': </b>' & $ExpSSID & '<br /><b>' & $Column_Names_BSSID & ': </b>' & $ExpBSSID & '<br /><b>' & $Column_Names_NetworkType & ': </b>' & $ExpNET & '<br /><b>' & $Column_Names_RadioType & ': </b>' & $ExpRAD & '<br /><b>' & $Column_Names_Channel & ': </b>' & $ExpCHAN & '<br /><b>' & $Column_Names_Authentication & ': </b>' & $ExpAUTH & '<br /><b>' & $Column_Names_Encryption & ': </b>' & $ExpENCR & '<br /><b>' & $Column_Names_BasicTransferRates & ': </b>' & $ExpBTX & '<br /><b>' & $Column_Names_OtherTransferRates & ': </b>' & $ExpOTX & '<br /><b>' & $Column_Names_Latitude & ': </b>' & $ExpLat & '<br /><b>' & $Column_Names_Longitude & ': </b>' & $ExpLon & '<br /><b>' & $Column_Names_MANUF & ': </b>' & $ExpMANU & '<br />]]></description>' & @CRLF
											 ;& '<description><![CDATA[<b>' & $Column_Names_SSID & ': </b>' & $ExpSSID & '<br /><b>' & $Column_Names_BSSID & ': </b>' & $ExpBSSID & '<br /><b>' & $Column_Names_NetworkType & ': </b>' & $ExpNET & '<br /><b>' & $Column_Names_RadioType & ': </b>' & $ExpRAD & '<br /><b>' & $Column_Names_Channel & ': </b>' & $ExpCHAN & '<br /><b>' & $Column_Names_Authentication & ': </b>' & $ExpAUTH & '<br /><b>' & $Column_Names_Encryption & ': </b>' & $ExpENCR & '<br /><b>' & $Column_Names_BasicTransferRates & ': </b>' & $ExpBTX & '<br /><b>' & $Column_Names_OtherTransferRates & ': </b>' & $ExpOTX & '<br /><b>' & $Column_Names_FirstActive & ': </b>' & $ExpFirstDateTime & '<br /><b>' & $Column_Names_LastActive & ': </b>' & $ExpLastDateTime & '<br /><b>' & $Column_Names_Latitude & ': </b>' & $ExpLat & '<br /><b>' & $Column_Names_Longitude & ': </b>' & $ExpLon & '<br /><b>' & $Column_Names_MANUF & ': </b>' & $ExpMANU & '<br />]]></description>' & @CRLF
									If $ExpActive = 1 Then
										$file_open &= '<styleUrl>#openStyle</styleUrl>' & @CRLF
									ElseIf $ExpActive = 0 Then
										$file_open &= '<styleUrl>#openDeadStyle</styleUrl>' & @CRLF
									EndIf
									$file_open &= '<Point>' & @CRLF _
											 & '<coordinates>' & StringReplace(StringReplace(StringReplace($ExpLon, 'W', '-'), 'E', ''), ' ', '') & ',' & StringReplace(StringReplace(StringReplace($ExpLat, 'S', '-'), 'N', ''), ' ', '') & ',0</coordinates>' & @CRLF _
											 & '</Point>' & @CRLF _
											 & '</Placemark>' & @CRLF
								ElseIf $ExpSecType = 2 Then
									$file_wep &= '<Placemark>' & @CRLF _
											 & '<name></name>' & @CRLF _
											& '<description><![CDATA[<b>' & $Column_Names_SSID & ': </b>' & $ExpSSID & '<br /><b>' & $Column_Names_BSSID & ': </b>' & $ExpBSSID & '<br /><b>' & $Column_Names_NetworkType & ': </b>' & $ExpNET & '<br /><b>' & $Column_Names_RadioType & ': </b>' & $ExpRAD & '<br /><b>' & $Column_Names_Channel & ': </b>' & $ExpCHAN & '<br /><b>' & $Column_Names_Authentication & ': </b>' & $ExpAUTH & '<br /><b>' & $Column_Names_Encryption & ': </b>' & $ExpENCR & '<br /><b>' & $Column_Names_BasicTransferRates & ': </b>' & $ExpBTX & '<br /><b>' & $Column_Names_OtherTransferRates & ': </b>' & $ExpOTX & '<br /><b>' & $Column_Names_Latitude & ': </b>' & $ExpLat & '<br /><b>' & $Column_Names_Longitude & ': </b>' & $ExpLon & '<br /><b>' & $Column_Names_MANUF & ': </b>' & $ExpMANU & '<br />]]></description>' & @CRLF
											;& '<description><![CDATA[<b>' & $Column_Names_SSID & ': </b>' & $ExpSSID & '<br /><b>' & $Column_Names_BSSID & ': </b>' & $ExpBSSID & '<br /><b>' & $Column_Names_NetworkType & ': </b>' & $ExpNET & '<br /><b>' & $Column_Names_RadioType & ': </b>' & $ExpRAD & '<br /><b>' & $Column_Names_Channel & ': </b>' & $ExpCHAN & '<br /><b>' & $Column_Names_Authentication & ': </b>' & $ExpAUTH & '<br /><b>' & $Column_Names_Encryption & ': </b>' & $ExpENCR & '<br /><b>' & $Column_Names_BasicTransferRates & ': </b>' & $ExpBTX & '<br /><b>' & $Column_Names_OtherTransferRates & ': </b>' & $ExpOTX & '<br /><b>' & $Column_Names_FirstActive & ': </b>' & $ExpFirstDateTime & '<br /><b>' & $Column_Names_LastActive & ': </b>' & $ExpLastDateTime & '<br /><b>' & $Column_Names_Latitude & ': </b>' & $ExpLat & '<br /><b>' & $Column_Names_Longitude & ': </b>' & $ExpLon & '<br /><b>' & $Column_Names_MANUF & ': </b>' & $ExpMANU & '<br />]]></description>' & @CRLF
									If $ExpActive = 1 Then
										$file_wep &= '<styleUrl>#wepStyle</styleUrl>' & @CRLF
									ElseIf $ExpActive = 0 Then
										$file_wep &= '<styleUrl>#wepDeadStyle</styleUrl>' & @CRLF
									EndIf
									$file_wep &= '<Point>' & @CRLF _
											 & '<coordinates>' & StringReplace(StringReplace(StringReplace($ExpLon, 'W', '-'), 'E', ''), ' ', '') & ',' & StringReplace(StringReplace(StringReplace($ExpLat, 'S', '-'), 'N', ''), ' ', '') & ',0</coordinates>' & @CRLF _
											 & '</Point>' & @CRLF _
											 & '</Placemark>' & @CRLF
								ElseIf $ExpSecType = 3 Then
									$file_sec &= '<Placemark>' & @CRLF _
											 & '<name></name>' & @CRLF _
											 & '<description><![CDATA[<b>' & $Column_Names_SSID & ': </b>' & $ExpSSID & '<br /><b>' & $Column_Names_BSSID & ': </b>' & $ExpBSSID & '<br /><b>' & $Column_Names_NetworkType & ': </b>' & $ExpNET & '<br /><b>' & $Column_Names_RadioType & ': </b>' & $ExpRAD & '<br /><b>' & $Column_Names_Channel & ': </b>' & $ExpCHAN & '<br /><b>' & $Column_Names_Authentication & ': </b>' & $ExpAUTH & '<br /><b>' & $Column_Names_Encryption & ': </b>' & $ExpENCR & '<br /><b>' & $Column_Names_BasicTransferRates & ': </b>' & $ExpBTX & '<br /><b>' & $Column_Names_OtherTransferRates & ': </b>' & $ExpOTX & '<br /><b>' & $Column_Names_Latitude & ': </b>' & $ExpLat & '<br /><b>' & $Column_Names_Longitude & ': </b>' & $ExpLon & '<br /><b>' & $Column_Names_MANUF & ': </b>' & $ExpMANU & '<br />]]></description>' & @CRLF
											; & '<description><![CDATA[<b>' & $Column_Names_SSID & ': </b>' & $ExpSSID & '<br /><b>' & $Column_Names_BSSID & ': </b>' & $ExpBSSID & '<br /><b>' & $Column_Names_NetworkType & ': </b>' & $ExpNET & '<br /><b>' & $Column_Names_RadioType & ': </b>' & $ExpRAD & '<br /><b>' & $Column_Names_Channel & ': </b>' & $ExpCHAN & '<br /><b>' & $Column_Names_Authentication & ': </b>' & $ExpAUTH & '<br /><b>' & $Column_Names_Encryption & ': </b>' & $ExpENCR & '<br /><b>' & $Column_Names_BasicTransferRates & ': </b>' & $ExpBTX & '<br /><b>' & $Column_Names_OtherTransferRates & ': </b>' & $ExpOTX & '<br /><b>' & $Column_Names_FirstActive & ': </b>' & $ExpFirstDateTime & '<br /><b>' & $Column_Names_LastActive & ': </b>' & $ExpLastDateTime & '<br /><b>' & $Column_Names_Latitude & ': </b>' & $ExpLat & '<br /><b>' & $Column_Names_Longitude & ': </b>' & $ExpLon & '<br /><b>' & $Column_Names_MANUF & ': </b>' & $ExpMANU & '<br />]]></description>' & @CRLF
									If $ExpActive = 1 Then
										$file_sec &= '<styleUrl>#secureStyle</styleUrl>' & @CRLF
									ElseIf $ExpActive = 0 Then
										$file_sec &= '<styleUrl>#secureDeadStyle</styleUrl>' & @CRLF
									EndIf
									$file_sec &= '<Point>' & @CRLF _
											 & '<coordinates>' & StringReplace(StringReplace(StringReplace($ExpLon, 'W', '-'), 'E', ''), ' ', '') & ',' & StringReplace(StringReplace(StringReplace($ExpLat, 'S', '-'), 'N', ''), ' ', '') & ',0</coordinates>' & @CRLF _
											 & '</Point>' & @CRLF _
											 & '</Placemark>' & @CRLF
								EndIf
						EndIf
					EndIf
					sleep(5)
				Next
				If $file_open <> '' Then
					$file &= '<Folder>' & @CRLF _
							 & '<name>Open Access Points</name>' & @CRLF _
							 & $file_open & '</Folder>' & @CRLF
				EndIf
				If $file_wep <> '' Then
					$file &= '<Folder>' & @CRLF _
							 & '<name>Wep Access Points</name>' & @CRLF _
							 & $file_wep & '</Folder>' & @CRLF
				EndIf
				If $file_sec <> '' Then
					$file &= '<Folder>' & @CRLF _
							 & '<name>Secure Access Points</name>' & @CRLF _
							 & $file_sec & '</Folder>' & @CRLF
				EndIf
			EndIf
		EndIf
	EndIf
	If $MapGpsTrack = 1 Then
		Local $GpsMatchArray, $iRows, $iColumns, $iRval
		$query = "SELECT Latitude, Longitude FROM GPS WHERE Latitude <> 'N 0.0000' And Longitude <> 'E 0.0000' ORDER BY Date1, Time1"
		$iRval = _SQLite_GetTable2d($DBhndl, $query, $GpsMatchArray, $iRows, $iColumns)
		$FoundGpsMatch = $iRows
		If $FoundGpsMatch <> 0 Then
			$file &= '<Folder>' & @CRLF _
					 & '<name>Vistumbler Gps Track</name>' & @CRLF _
					 & '<Placemark>' & @CRLF _
					 & '<name>Location</name>' & @CRLF _
					 & '<styleUrl>#Location</styleUrl>' & @CRLF _
					 & '<LineString>' & @CRLF _
					 & '<extrude>1</extrude>' & @CRLF _
					 & '<tessellate>1</tessellate>' & @CRLF _
					 & '<coordinates>' & @CRLF
			For $exp = 1 To $FoundGpsMatch
				$ExpLat = _Format_GPS_DMM_to_DDD($GpsMatchArray[$exp][0])
				$ExpLon = _Format_GPS_DMM_to_DDD($GpsMatchArray[$exp][1])
				If $ExpLat <> 'N 0.0000000' And $ExpLon <> 'E 0.0000000' Then
					$FoundApWithGps = 1
					$file &= StringReplace(StringReplace(StringReplace($ExpLon, 'W', '-'), 'E', ''), ' ', '') & ',' & StringReplace(StringReplace(StringReplace($ExpLat, 'S', '-'), 'N', ''), ' ', '') & ',0' & @CRLF
				EndIf
			Next
			$file &= '</coordinates>' & @CRLF _
					 & '</LineString>' & @CRLF _
					 & '</Placemark>' & @CRLF _
					 & '</Folder>' & @CRLF
		EndIf
	EndIf
	$file &= '</Document>' & @CRLF _
			 & '</kml>'

	FileDelete($kml)
	$filewrite = FileWrite($kml, $file)
EndFunc   ;==>_AutoSaveKml

Func _UploadActiveApsToWifidb()
	If $Debug = 1 Then FileWrite("templog.txt", 'UploadActiveApsToWifidb----------------------------------------------------------------------------------------------' & @CRLF)
	Local $ApMatchArray, $iRows, $iColumns, $iRval
	$query = "SELECT ApID, BSSID, SSID, CHAN, AUTH, ENCR, SECTYPE, NETTYPE, RADTYPE, BTX, OTX, LastHistID, LABEL FROM AP WHERE Active=1"
	$iRval = _SQLite_GetTable2d($DBhndl, $query, $ApMatchArray, $iRows, $iColumns)
	$FoundApMatch = $iRows
	If $Debug = 1 Then FileWrite("templog.txt", $FoundApMatch & @CRLF)
	For $exp = 1 To $iRows
		$ExpApID = $ApMatchArray[$exp][0]
		$ExpBSSID = StringReplace($ApMatchArray[$exp][1], ":", "")
		$ExpSSID = $ApMatchArray[$exp][2]
		$ExpCHAN = $ApMatchArray[$exp][3]
		$ExpAUTH = $ApMatchArray[$exp][4]
		$ExpENCR = $ApMatchArray[$exp][5]
		$ExpSECTYPE = $ApMatchArray[$exp][6]
		$ExpNET = $ApMatchArray[$exp][7]
		$ExpRAD = $ApMatchArray[$exp][8]
		$ExpBTX = $ApMatchArray[$exp][9]
		$ExpOTX = $ApMatchArray[$exp][10]
		$ExpLastID = $ApMatchArray[$exp][11]
		$ExpLAB = $ApMatchArray[$exp][12]

		Local $HistMatchArray, $iRows, $iColumns, $iRval
		$query = "SELECT Signal, RSSI, GpsID FROM Hist WHERE HistID=" & $ExpLastID
		$iRval = _SQLite_GetTable2d($DBhndl, $query, $HistMatchArray, $iRows, $iColumns)
		$FoundHistMatch = $iRows
		If $FoundHistMatch = 1 Then
			$ExpLastGpsSig = $HistMatchArray[1][0]
			$ExpLastGpsRSSI = $HistMatchArray[1][1]
			$ExpLastGpsID = $HistMatchArray[1][2]
			If $ExpLastGpsSig <> 0 Then
				Local $GpsMatchArray, $iRows, $iColumns, $iRval
				$query = "SELECT Latitude, Longitude, NumOfSats, HorDilPitch, Alt, Geo, SpeedInMPH, SpeedInKmH, TrackAngle, Date1, Time1 FROM GPS WHERE GpsID=" & $ExpLastGpsID
				$iRval = _SQLite_GetTable2d($DBhndl, $query, $GpsMatchArray, $iRows, $iColumns)
				$FoundGpsMatch = $iRows
				If $FoundGpsMatch = 1 Then
					$ExpLastGpsLat = StringReplace(StringReplace(StringReplace($GpsMatchArray[1][0], "N", ""), "S", "-"), " ", "")
					$ExpLastGpsLon = StringReplace(StringReplace(StringReplace($GpsMatchArray[1][1], "E", ""), "W", "-"), " ", "")
					$ExpLastGpsSat = $GpsMatchArray[1][2]
					$ExpLastGpsHDP = $GpsMatchArray[1][3]
					$ExpLastGpsAlt = $GpsMatchArray[1][4]
					$ExpLastGpsGeo = $GpsMatchArray[1][5]
					$ExpLastGpsMPH = $GpsMatchArray[1][6]
					$ExpLastGpsKMH = $GpsMatchArray[1][7]
					$ExpLastGpsTAngle = $GpsMatchArray[1][8]
					$ExpLastGpsDate = $GpsMatchArray[1][9]
					$ExpLastGpsTime = $GpsMatchArray[1][10]

					$url_root = $apiurl & 'live.php?'
					$url_data = "SessionID=" & $WifiDb_SessionID & "&SSID=" & $ExpSSID & "&Mac=" & $ExpBSSID & "&Auth=" & $ExpAUTH & "&SecType=" & $ExpSECTYPE & "&Encry=" & $ExpENCR & "&Rad=" & $ExpRAD & "&Chn=" & $ExpCHAN & "&Lat=" & $ExpLastGpsLat & "&Long=" & $ExpLastGpsLon & "&BTx=" & $ExpBTX & "&OTx=" & $ExpOTX & "&Date=" & $ExpLastGpsDate & "&Time=" & $ExpLastGpsTime & "&NT=" & $ExpNET & "&Label=" & $ExpLAB & "&Sig=" & $ExpLastGpsSig & "&RSSI=" & $ExpLastGpsRSSI & "&Sats=" & $ExpLastGpsSat & "&HDP=" & $ExpLastGpsHDP & "&ALT=" & $ExpLastGpsAlt & "&GEO=" & $ExpLastGpsGeo & "&KMH=" & $ExpLastGpsKMH & "&MPH=" & $ExpLastGpsMPH & "&Track=" & $ExpLastGpsTAngle
					If $WifiDb_User <> '' And $WifiDb_ApiKey <> '' Then $url_data &= "&username=" & $WifiDb_User & "&apikey=" & $WifiDb_ApiKey
					If $Debug = 1 Then FileWrite("templog.txt", StringLen($url_root & $url_data) & ' - ' & $url_root & $url_data & @CRLF)
					$webpagesource = _INetGetSource($url_root & $url_data)
					If $Debug = 1 Then FileWrite("templog.txt", $webpagesource & @CRLF & '---------------------------------------------------------------------------------------------' & @CRLF)
				EndIf
			EndIf
		EndIf
	Next
EndFunc   ;==>_UploadActiveApsToWifidb

Func _Format_GPS_DMM_to_DDD($gps);converts gps position from ddmm.mmmm to dd.ddddddd
	$return = '0.0000000'
	$splitlatlon1 = StringSplit($gps, " ") ;Split N,S,E,W from data
	If $splitlatlon1[0] = 2 Then
		$splitlatlon2 = StringSplit($splitlatlon1[2], ".");Split dd from data
		$latlonleft = StringTrimRight($splitlatlon2[1], 2)
		$latlonright = (StringTrimLeft($splitlatlon2[1], StringLen($splitlatlon2[1]) - 2) & '.' & $splitlatlon2[2]) / 60
		$return = $splitlatlon1[1] & ' ' & StringFormat('%0.7f', $latlonleft + $latlonright);set return
	EndIf
	Return ($return)
EndFunc   ;==>_Format_GPS_DMM_to_DDD

Func _Error()
	If $Debug = 1 Then
		MsgBox(0, "Error", "We intercepted a COM Error !" & @CRLF & @CRLF & _
				"err.description is: " & @TAB & $oMyError.description & @CRLF & _
				"err.windescription:" & @TAB & $oMyError.windescription & @CRLF & _
				"err.number is: " & @TAB & Hex($oMyError.number, 8) & @CRLF & _
				"err.lastdllerror is: " & @TAB & $oMyError.lastdllerror & @CRLF & _
				"err.scriptline is: " & @TAB & $oMyError.scriptline & @CRLF & _
				"err.source is: " & @TAB & $oMyError.source & @CRLF & _
				"err.helpfile is: " & @TAB & $oMyError.helpfile & @CRLF & _
				"err.helpcontext is: " & @TAB & $oMyError.helpcontext _
				)
	EndIf
	Exit
EndFunc   ;==>_Error