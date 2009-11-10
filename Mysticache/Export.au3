#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_icon=Icons\icon.ico
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
;License Information------------------------------------
;Copyright (C) 2008 Andrew Calcutt
;This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; Version 2 of the License.
;This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
;You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
;--------------------------------------------------------
;AutoIt Version: v3.2.13.11 Beta
$Script_Author = 'Andrew Calcutt'
$Script_Name = 'Myticache Save'
$Script_Website = 'http://www.Mysticache.net'
$Script_Function = 'Reads the Mysticache DB and exports a KML based on input options'
$version = 'v1'
$last_modified = '2009/11/2009'
;--------------------------------------------------------
#include "UDFs\AccessCom.au3"
$oMyError = ObjEvent("AutoIt.Error", "_Error")

Dim $DB_OBJ
Dim $filetype = 'k';Default file type (d=detailed, s=summary, k=kml)
Dim $filename = @ScriptDir & '\Temp\Save.txt'
Dim $settings = @ScriptDir & '\Settings\Mysticache_settings.ini'
Dim $MysticacheDB = @ScriptDir & '\Temp\MysticacheDB.mdb'
Dim $ImageDir = @ScriptDir & '\Images\'
Dim $TmpDir = @ScriptDir & '\temp\'

Dim $MapWaypoints = 0
Dim $MapTrack = 0

For $loop = 1 To $CmdLine[0]
	If StringInStr($CmdLine[$loop], '/f') Then
		$filesplit = StringSplit($CmdLine[$loop], "=")
		If $filesplit[0] = 2 Then $filename = $filesplit[2]
	EndIf
	If StringInStr($CmdLine[$loop], '/ft') Then
		$filesplit = StringSplit($CmdLine[$loop], "=")
		If $filesplit[0] = 2 Then $filetype = $filesplit[2]
	EndIf
	If StringInStr($CmdLine[$loop], '/wp') Then
		$MapWaypoints = 1
	EndIf
	If StringInStr($CmdLine[$loop], '/t') Then
		$MapTrack = 1
	EndIf
	If StringInStr($CmdLine[$loop], '/?') Then
		;MsgBox(0, '', '/k="path to save kml file"' & @CRLF & @CRLF & '/a	Map Active Access Points' & @CRLF & '/d	Map Dead Access Points' & @CRLF & '/t	Map GPS Track')
		Exit
	EndIf
Next

If $filename <> '' Then
	_AccessConnectConn($MysticacheDB, $DB_OBJ)
	If $filetype = 'kml' Then
		_AutoSaveKml($filename, $MapTrack, $MapWaypoints)
	EndIf
	_AccessCloseConn($DB_OBJ)
EndIf
Exit

Func _AutoSaveKml($kml, $MapGpsTrack = 1, $MapGpsWpts = 1)
	$file = '<?xml version="1.0" encoding="utf-8"?>' & @CRLF _
			 & '<kml xmlns="http://earth.google.com/kml/2.0">' & @CRLF _
			 & '<Document>' & @CRLF _
			 & '<description>' & 'Myticache AutoKML' & ' - By ' & 'Andrew Calcutt' & '</description>' & @CRLF _
			 & '<name>' & 'Mysticache AutoKML' & ' ' & 'V1.0' & '</name>' & @CRLF
	If $MapGpsWpts = 1 Then
				$file &= '<Style id="Waypoint">' & @CRLF _
						 & '<IconStyle>' & @CRLF _
						 & '<scale>.5</scale>' & @CRLF _
						 & '<Icon>' & @CRLF _
						 & '<href>' & $ImageDir & 'waypoint.png</href>' & @CRLF _
						 & '</Icon>' & @CRLF _
						 & '</IconStyle>' & @CRLF _
						 & '</Style>' & @CRLF
	EndIf
	If $MapGpsTrack = 1 Then
		$file &= '<Style id="Location">' & @CRLF _
				 & '<LineStyle>' & @CRLF _
				 & '<color>7f0000ff</color>' & @CRLF _
				 & '<width>4</width>' & @CRLF _
				 & '</LineStyle>' & @CRLF _
				 & '</Style>' & @CRLF
	EndIf
	If $MapGpsWpts = 1 Then
		$query = "SELECT WPID, Name, GPID, Notes, Latitude, Longitude, Bearing, Destination, Link FROM WP"
			$WpMatchArray = _RecordSearch($MysticacheDB, $query, $DB_OBJ)
			$FoundWpMatch = UBound($WpMatchArray) - 1
			If $FoundWpMatch <> 0 Then
				$file &= '<Folder>' & @CRLF _
					& '<name>Waypoints</name>' & @CRLF
				For $exp = 1 To $FoundWpMatch
					$ExpWPID = $WpMatchArray[$exp][1]
					$ExpName = $WpMatchArray[$exp][2]
					$ExpGPID = $WpMatchArray[$exp][3]
					$ExpNotes = $WpMatchArray[$exp][4]
					$ExpLat = StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($WpMatchArray[$exp][5]), 'W', '-'), 'E', ''), ' ', '')
					$ExpLon = StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($WpMatchArray[$exp][6]), 'S', '-'), 'N', ''), ' ', '')
					$ExpBrng = $WpMatchArray[$exp][7]
					$ExpDest = $WpMatchArray[$exp][8]
					$ExpLink = $WpMatchArray[$exp][9]

					$file &= '<Placemark>' & @CRLF _
							& '<name>' & $ExpName & '</name>' & @CRLF _
							& '<description><![CDATA[<b>' & 'Name' & ': </b>' & $ExpName & '<br /><b>' & 'GC #' & ': </b>' & $ExpGPID & '<br /><b>' & "Notes" & ': </b>' & $ExpNotes & '<br /><b>' & 'Latitude' & ': </b>' & $ExpLat & '<br /><b>' & 'Longitude' & ': </b>' & $ExpLon & '<br /><b>' & "Link" & ': </b>' & $ExpLink & '<br />]]></description>' & @CRLF _
							& '<Point>' & @CRLF _
							& '<coordinates>' & $ExpLon & ',' & $ExpLat & ',0</coordinates>' & @CRLF _
							& '</Point>' & @CRLF _
							& '</Placemark>' & @CRLF
				Next


				$file &= '</Folder>' & @CRLF
			EndIf

	EndIf
	If $MapGpsTrack = 1 Then
		$query = "SELECT Latitude, Longitude FROM GPS WHERE Latitude <> 'N 0.0000' And Longitude <> 'E 0.0000' ORDER BY Date1, Time1"
		$GpsMatchArray = _RecordSearch($MysticacheDB, $query, $DB_OBJ)
		$FoundGpsMatch = UBound($GpsMatchArray) - 1
		If $FoundGpsMatch <> 0 Then
			$file &= '<Folder>' & @CRLF _
					 & '<name>Mysticache Gps Track</name>' & @CRLF _
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
