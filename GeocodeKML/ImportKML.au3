#RequireAdmin
#include "UDFs\_XMLDomWrapper.au3"
#include <Array.au3>
#include <INet.au3>
#include <SQLite.au3>
Dim $RetryAttempts = 5 ;Number of times to retry getting location
Dim $DBhndl
Dim $TmpDir = @ScriptDir & '\temp\'
$ldatetimestamp = StringFormat("%04i", @YEAR) & '-' & StringFormat("%02i", @MON) & '-' & StringFormat("%02i", @MDAY) & ' ' & @HOUR & '-' & @MIN & '-' & @SEC
$DB = $TmpDir & $ldatetimestamp & '.SDB'
ConsoleWrite($DB & @CRLF)
_SetUpDbTables($DB)
_SearchKML()

Func _SearchKML()
	$KMLfile = FileOpenDialog("Import from KML", '', "Google Earth file" & ' (*.kml)', 1)
	$result = _XMLFileOpen($KMLfile)
	;ConsoleWrite(@error & @CRLF)
	If @error then ConsoleWrite(@extended & @CRLF)
	ConsoleWrite($result)
	$path = "/*[1]"
	_SearchForPlaceMark($path)
EndFunc   ;==>_ImportGPX

Func _SearchForPlaceMark($spath)
	ConsoleWrite($spath & @CRLF)
	$PathNodesArray = _XMLGetChildNodes($spath)
	If IsArray($PathNodesArray) Then
		For $spa = 1 To $PathNodesArray[0]
			ConsoleWrite($PathNodesArray[$spa] & @CRLF)
			If StringLower($PathNodesArray[$spa]) = "document" Or StringLower($PathNodesArray[$spa]) = "folder" Then
				$DocPath = $spath & "/*[" & $spa & "]"
				_SearchForPlaceMark($DocPath)
			ElseIf StringLower($PathNodesArray[$spa]) = "placemark" Then
				$PlacemarkPath = $spath & "/*[" & $spa & "]"
				$PlacemarkNodes = _XMLGetChildNodes($PlacemarkPath)
				Local $PName, $PDesc, $PStyle, $PLat, $Plon, $PCountryCode, $PCountryName, $PAreaName
				For $pma = 1 to $PlacemarkNodes[0]
					;ConsoleWrite($spa & '-' & $pma & ' : ')
					If StringLower($PlacemarkNodes[$pma]) = "name" Then
						$NamePath = $PlacemarkPath & "/*[" & $pma & "]"
						$NameArray = _XMLGetValue($NamePath)
						$PName = StringReplace(StringReplace($NameArray[1], "'", "''"), "Location", "")
					ElseIf StringLower($PlacemarkNodes[$pma]) = "description" Then
						$DeskPath = $PlacemarkPath & "/*[" & $pma & "]"
						$DeskArray = _XMLGetValue($DeskPath)
						$PDesc = StringReplace($DeskArray[1], "'", "''")
					ElseIf StringLower($PlacemarkNodes[$pma]) = "styleUrl" Then
						$StylePath = $PlacemarkPath & "/*[" & $pma & "]"
						$StyleArray = _XMLGetValue($StylePath)
						$PStyle = StringReplace(StringReplace(StringReplace($StyleArray[1], "openStyleDead", "openStyle"), "wepStyleDead", "wepStyle"), "secureStyleDead", "secureStyle")
					ElseIf StringLower($PlacemarkNodes[$pma]) = "point" Then
						$PointPath = $PlacemarkPath & "/*[" & $pma & "]"
						$PointNodes = _XMLGetChildNodes($PointPath)
						For $pta = 1 to $PointNodes[0]
							If StringLower($PointNodes[$pta]) = "coordinates" Then
								$CordPath = $PointPath & "/*[" & $pta & "]"
								$CordArray = _XMLGetValue($CordPath)
								$LatLonArr = StringSplit($CordArray[1], ",")
								$Plon = $LatLonArr[1]
								$PLat = $LatLonArr[2]
								For $gl = 1 to $RetryAttempts
									$LocationArr = _GeonamesGetGpsLocation($PLat, $Plon)
									$PCountryCode = $LocationArr[1]
									$PCountryName = $LocationArr[2]
									$PAreaName = $LocationArr[3]
									If $PCountryCode <> "" Or $PCountryName <> "" Or $PAreaName <> "" Then ExitLoop
									$LocationArr = _GoogleGetGpsLocation($PLat, $Plon)
									$PCountryCode = $LocationArr[1]
									$PCountryName = StringReplace($LocationArr[2], "USA", "United States")
									$PAreaName = $LocationArr[3]
									If $PCountryCode <> "" Or $PCountryName <> "" Or $PAreaName <> "" Then ExitLoop
									;Sleep(5000)
								Next
								ConsoleWrite($PCountryCode &  ' - ' & $PCountryName &  ' - ' & $PAreaName & @CRLF)
								;Sleep($RequestSleepTime);sleep because google returns results better
							EndIf
						Next
					EndIf
				Next
				If $PName <> "" Or $PCountryCode <> "" Or $PCountryName <> "" Or $PAreaName <> "" Or $PDesc <> "" Then
					ConsoleWrite('"' & $PName  & '" - "' & $PCountryCode & '" - "' & $PCountryName & '" - "' & $PAreaName & '" - "' & $PStyle & '" - "' & $PLat & '" - "' & $Plon & '" - "' & $PDesc & '"' & @CRLF)
					$query = "INSERT INTO KMLDATA(Name,Desc,Style,Latitude,Longitude,CountryCode,CountryName,AreaName) VALUES ('" & $PName & "','" & $PDesc & "','" & $PStyle & "','" & $PLat & "','" & $Plon & "','" & $PCountryCode & "','" & $PCountryName & "','" & $PAreaName & "');"
					_SQLite_Exec($DBhndl, $query)
				EndIf
			EndIf
		Next
	EndIf
EndFunc


Func _GoogleGetGpsLocation($gllat, $gllon)
	Local $aResult[4]
	Local $AdministrativeAreaName, $CountryName, $CountryNameCode
	$googlelookupurl = "http://maps.google.com/maps/geo?q=" & $gllat & "," & $gllon
	$webpagesource = _INetGetSource($googlelookupurl)
	;ConsoleWrite($webpagesource)
	ConsoleWrite("Google" & @CRLF)
	$arr = StringSplit($webpagesource, @LF)
	For $d=1 to $arr[0]
		$gdline = StringStripWS($arr[$d], 8)
		;ConsoleWrite($gdline & @CRLF)
		If StringInStr($gdline, '"AdministrativeAreaName"') Then
			$ts = StringSplit($gdline, ":")
			$AdministrativeAreaName = $ts[2]
		ElseIf StringInStr($gdline, '"CountryName"') Then
			$ts = StringSplit($gdline, ":")
			$CountryName = $ts[2]
		ElseIf StringInStr($gdline, '"CountryNameCode"') Then
			$ts = StringSplit($gdline, ":")
			$CountryNameCode = $ts[2]
		EndIf
		If $AdministrativeAreaName <> "" And $CountryName <> "" And $CountryNameCode <> "" Then ExitLoop
	Next
	$aResult[1] = StringReplace(StringReplace($CountryNameCode, ',', ''), '"', '')
	$aResult[2] = StringReplace(StringReplace($CountryName, ',', ''), '"', '')
	$aResult[3] = StringReplace(StringReplace($AdministrativeAreaName, ',', ''), '"', '')
	;ConsoleWrite('aan:' & $AdministrativeAreaName & @CRLF & 'cn' & $CountryName & @CRLF & 'cnc' & $CountryNameCode & @CRLF)
	Sleep(750);Sleep 15 seconds to prevent hitting 15,000 request/day limit
	Return $aResult
EndFunc

Func _GeonamesGetGpsLocation($gllat, $gllon)
	Local $aResult[4]
	Local $AdministrativeAreaName, $CountryName, $CountryNameCode
	$geonameslookupurl = "http://ws.geonames.org/countrySubdivision?lat=" & $gllat & "&lng=" & $gllon
	$webpagesource = _INetGetSource($geonameslookupurl)
	;ConsoleWrite($webpagesource)
	ConsoleWrite("Geonames" & @CRLF)
	$arr = StringSplit($webpagesource, @LF)
	For $d=1 to $arr[0]
		$gdline = $arr[$d]
		If StringInStr($gdline, 'code type="ISO3166-2"') Then
			$ts = StringSplit($gdline, ">")
			$AdministrativeAreaName = StringReplace($ts[2], "</code", "")
		ElseIf StringInStr($gdline, 'countryName') Then
			$ts = StringSplit($gdline, ">")
			$CountryName = StringReplace($ts[2], "</countryName", "")
		ElseIf StringInStr($gdline, 'countryCode') Then
			$ts = StringSplit($gdline, ">")
			$CountryNameCode = StringReplace($ts[2], "</countryCode", "")
		EndIf
		If $AdministrativeAreaName <> "" And $CountryName <> "" And $CountryNameCode <> "" Then ExitLoop
	Next
	$aResult[1] = StringReplace(StringReplace($CountryNameCode, ',', ''), '"', '')
	$aResult[2] = StringReplace(StringReplace($CountryName, ',', ''), '"', '')
	$aResult[3] = StringReplace(StringReplace($AdministrativeAreaName, ',', ''), '"', '')
	;ConsoleWrite('aan:' & $AdministrativeAreaName & @CRLF & 'cn' & $CountryName & @CRLF & 'cnc' & $CountryNameCode & @CRLF)
	Sleep(750);Sleep 500ms to prevent hitting 5000 request/hr limit
	Return $aResult
EndFunc


Func _SetUpDbTables($dbfile)
	_SQLite_Startup()
	$DBhndl = _SQLite_Open($dbfile)
	_SQLite_Exec($DBhndl, "pragma synchronous=0");Speed vs Data security. Speed Wins for now.
	ConsoleWrite(@error & @CRLF)
	_SQLite_Exec($DBhndl, "CREATE TABLE KMLDATA (Name,Desc,Style,Latitude,Longitude,CountryCode,CountryName,AreaName)")
EndFunc   ;==>_SetUpDbTables