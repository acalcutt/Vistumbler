#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=icon.ico
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
;License Information------------------------------------
;Copyright (C) 2008 Andrew Calcutt
;This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; Version 2 of the License.
;This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
;You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
;--------------------------------------------------------
;AutoIt Version: v3.2.13.3 Beta
$Script_Author = 'Andrew Calcutt'
$Script_Name = 'Vistumbler AutoKML'
$Script_Website = 'http://www.Vistumbler.net'
$Script_Function = 'Reads the vistumbler DB and exports a KML based on input options'
$version = 'v1.0'
$last_modified = '08/01/2008'
;--------------------------------------------------------
#include "AccessCom.au3"
$oMyError = ObjEvent("AutoIt.Error", "_Error")

Dim $MapActiveAPs = 0
Dim $MapDeadAPs = 0
Dim $MapAccessPoints = 0
Dim $MapTrack = 0
Dim $kml_file = @ScriptDir & '\Temp\test.kml'
Dim $ImageDir = @ScriptDir & '\Images\'
Dim $VistumblerDB = @ScriptDir & '\Temp\VistumblerDB.mdb'
Dim $settings = @ScriptDir & '\Settings\vistumbler_settings.ini'
Dim $DB_OBJ

Dim $Column_Names_Line = IniRead($settings, 'Column_Names', 'Column_Line', '#')
Dim $Column_Names_Active = IniRead($settings, 'Column_Names', 'Column_Active', 'Active')
Dim $Column_Names_SSID = IniRead($settings, 'Column_Names', 'Column_SSID', 'SSID')
Dim $Column_Names_BSSID = IniRead($settings, 'Column_Names', 'Column_BSSID', 'Mac Address')
Dim $Column_Names_MANUF = IniRead($settings, 'Column_Names', 'Column_Manufacturer', 'Manufacturer')
Dim $Column_Names_Signal = IniRead($settings, 'Column_Names', 'Column_Signal', 'Signal')
Dim $Column_Names_Authentication = IniRead($settings, 'Column_Names', 'Column_Authentication', 'Authentication')
Dim $Column_Names_Encryption = IniRead($settings, 'Column_Names', 'Column_Encryption', 'Encryption')
Dim $Column_Names_RadioType = IniRead($settings, 'Column_Names', 'Column_RadioType', 'Radio Type')
Dim $Column_Names_Channel = IniRead($settings, 'Column_Names', 'Column_Channel', 'Channel')
Dim $Column_Names_Latitude = IniRead($settings, 'Column_Names', 'Column_Latitude', 'Latitude')
Dim $Column_Names_Longitude = IniRead($settings, 'Column_Names', 'Column_Longitude', 'Longitude')
Dim $Column_Names_LatitudeDMS = IniRead($settings, 'Column_Names', 'Column_LatitudeDMS', 'Latitude (DDMMSS)')
Dim $Column_Names_LongitudeDMS = IniRead($settings, 'Column_Names', 'Column_LongitudeDMS', 'Longitude (DDMMSS)')
Dim $Column_Names_LatitudeDMM = IniRead($settings, 'Column_Names', 'Column_LatitudeDMM', 'Latitude (DDMMMM)')
Dim $Column_Names_LongitudeDMM = IniRead($settings, 'Column_Names', 'Column_LongitudeDMM', 'Longitude (DDMMMM)')
Dim $Column_Names_BasicTransferRates = IniRead($settings, 'Column_Names', 'Column_BasicTransferRates', 'Basic Transfer Rates')
Dim $Column_Names_OtherTransferRates = IniRead($settings, 'Column_Names', 'Column_OtherTransferRates', 'Other Transfer Rates')
Dim $Column_Names_FirstActive = IniRead($settings, 'Column_Names', 'Column_FirstActive', 'First Active')
Dim $Column_Names_LastActive = IniRead($settings, 'Column_Names', 'Column_LastActive', 'Last Active')
Dim $Column_Names_NetworkType = IniRead($settings, 'Column_Names', 'Column_NetworkType', 'Network Type')
Dim $Column_Names_Label = IniRead($settings, 'Column_Names', 'Column_Label', 'Label')

For $loop = 1 To $CmdLine[0]
	If StringInStr($CmdLine[$loop], '/k') Then
		$filesplit = StringSplit($CmdLine[$loop], "=")
		If $filesplit[0] = 2 Then $kml_file = $filesplit[2]
	EndIf
	If StringInStr($CmdLine[$loop], '/a') Then
		$MapActiveAPs = 1
		$MapAccessPoints = 1
	EndIf
	If StringInStr($CmdLine[$loop], '/d') Then
		$MapDeadAPs = 1
		$MapAccessPoints = 1
	EndIf
	If StringInStr($CmdLine[$loop], '/t') Then
		$MapTrack = 1
	EndIf
	If StringInStr($CmdLine[$loop], '/?') Then
		MsgBox(0, '', '/k="path to save kml file"' & @CRLF & @CRLF & '/a	Map Active Access Points' & @CRLF & '/d	Map Dead Access Points' & @CRLF & '/t	Map GPS Track')
		Exit
	EndIf
Next

If $kml_file <> '' Then
	_AccessConnectConn($VistumblerDB, $DB_OBJ)
	_AutoSaveKml($kml_file, $MapTrack, $MapAccessPoints, $MapActiveAPs, $MapDeadAPs)
	_AccessCloseConn($DB_OBJ)
EndIf
Exit

Func _AutoSaveKml($kml, $MapGpsTrack = 1, $MapAPs = 1, $MapActive = 1, $MapDead = 1)
	If StringInStr($kml, '.kml') = 0 Then $kml = $kml & '.kml'
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
				$query = "SELECT SSID, BSSID, NETTYPE, RADTYPE, CHAN, AUTH, ENCR, BTX, OTX, MANU, LABEL, HighGpsHistID, Active, SecType FROM AP WHERE HighGpsHistId <> '0'"
			ElseIf $MapActive = 1 Then
				$query = "SELECT SSID, BSSID, NETTYPE, RADTYPE, CHAN, AUTH, ENCR, BTX, OTX, MANU, LABEL, HighGpsHistID, Active, SecType FROM AP WHERE HighGpsHistId <> '0' And Active = '1'"
			ElseIf $MapDead = 1 Then
				$query = "SELECT SSID, BSSID, NETTYPE, RADTYPE, CHAN, AUTH, ENCR, BTX, OTX, MANU, LABEL, HighGpsHistID, Active, SecType FROM AP WHERE HighGpsHistId <> '0' And Active = '0'"
			EndIf
			ConsoleWrite('-->' & $query & @CRLF)
			$ApMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
			$FoundApMatch = UBound($ApMatchArray) - 1
			ConsoleWrite('-->' & $FoundApMatch & @CRLF)
			If $FoundApMatch <> 0 Then
				$FoundApWithGps = 1
				$file_open = ''
				$file_wep = ''
				$file_sec = ''
				For $exp = 1 To $FoundApMatch
					$ExpSSID = $ApMatchArray[$exp][1]
					$ExpBSSID = $ApMatchArray[$exp][2]
					$ExpNET = $ApMatchArray[$exp][3]
					$ExpRAD = $ApMatchArray[$exp][4]
					$ExpCHAN = $ApMatchArray[$exp][5]
					$ExpAUTH = $ApMatchArray[$exp][6]
					$ExpENCR = $ApMatchArray[$exp][7]
					$ExpBTX = $ApMatchArray[$exp][8]
					$ExpOTX = $ApMatchArray[$exp][9]
					$ExpMANU = $ApMatchArray[$exp][10]
					$ExpLAB = $ApMatchArray[$exp][11]
					$ExpHighGpsHistID = $ApMatchArray[$exp][12] - 0
					;$ExpFirstID = $ApMatchArray[$exp][13] - 0
					;$ExpLastID = $ApMatchArray[$exp][14] - 0
					$ExpActive = $ApMatchArray[$exp][13]
					$ExpSecType = $ApMatchArray[$exp][14]
					;Get Gps ID of HighGpsHistId
					$query = "SELECT GpsID FROM Hist Where HistID = '" & $ExpHighGpsHistID & "'"
					$HistMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
					$FoundHistMatch = UBound($HistMatchArray) - 1
					If $FoundHistMatch <> 0 Then
						$ExpGID = $HistMatchArray[1][1]
						;Get Latitude and Longitude
						$query = "SELECT Latitude, Longitude FROM GPS WHERE GpsId = '" & $ExpGID & "'"
						$GpsMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
						$FoundGpsMatch = UBound($GpsMatchArray) - 1
						If $FoundGpsMatch <> 0 Then
							$ExpLat = _Format_GPS_DMM_to_DDD($GpsMatchArray[1][1])
							$ExpLon = _Format_GPS_DMM_to_DDD($GpsMatchArray[1][2])
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
		$query = "SELECT Latitude, Longitude FROM GPS WHERE Latitude <> 'N 0.0000' And Longitude <> 'E 0.0000' ORDER BY Date1, Time1"
		$GpsMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
		$FoundGpsMatch = UBound($GpsMatchArray) - 1
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
				$ExpLat = _Format_GPS_DMM_to_DDD($GpsMatchArray[$exp][1])
				$ExpLon = _Format_GPS_DMM_to_DDD($GpsMatchArray[$exp][2])
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

Func _Error()
	Exit
EndFunc   ;==>_Error