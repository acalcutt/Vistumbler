#RequireAdmin
#include "UDFs\_XMLDomWrapper.au3"
#include <Array.au3>
#include <INet.au3>
#include <SQLite.au3>
Dim $RetryAttempts = 5 ;Number of times to retry getting location
Dim $DBhndl
Dim $TmpDir = @ScriptDir & '\temp\'
$ldatetimestamp = StringFormat("%04i", @YEAR) & '-' & StringFormat("%02i", @MON) & '-' & StringFormat("%02i", @MDAY) & ' ' & @HOUR & '-' & @MIN & '-' & @SEC
$DB = $TmpDir & 'FullDB.SDB'
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
				Local $PName, $PDesc, $PStyle, $PLat, $Plon
				For $pma = 1 to $PlacemarkNodes[0]
					;ConsoleWrite($spa & '-' & $pma & ' : ')
					If StringLower($PlacemarkNodes[$pma]) = "name" Then
						$NamePath = $PlacemarkPath & "/*[" & $pma & "]"
						$NameArray = _XMLGetValue($NamePath)
						$PName = StringReplace(StringReplace($NameArray[1], "'", "''"), "Location", "")
					ElseIf StringLower($PlacemarkNodes[$pma]) = "description" Then
						$DeskPath = $PlacemarkPath & "/*[" & $pma & "]"
						$DeskArray = _XMLGetValue($DeskPath)
						$PDesc = StringReplace(StringReplace(StringReplace(StringReplace(StringReplace($DeskArray[1], "<b>", ""), "</b>", ""), "<a href=""", ""), "</a>", ""), "'", "''")
						$DescSplit = StringSplit($PDesc, "<br />", 1)
						;_ArrayDisplay($DescSplit)
						Dim $SSID, $BSSID, $NetType, $RadType, $CHAN, $AUTH, $ENCR, $BTX, $OTX, $FirstActive, $LastActive, $MANU, $URL
						For $dl = 1 to $DescSplit[0]
							$DescDataSplit = StringSplit($DescSplit[$dl], ": ", 1)
							;_ArrayDisplay($DescDataSplit)
							If $DescDataSplit[1] = "SSID" Then
								$SSID = $DescDataSplit[2]
							ElseIf $DescDataSplit[1] = "Mac Address" Then
								$BSSID  = StringReplace($DescDataSplit[2], ":", "")
								;ConsoleWrite($BSSID & @CRLF)
							ElseIf $DescDataSplit[1] = "Network Type" Then
								$NetType = $DescDataSplit[2]
							ElseIf $DescDataSplit[1] = "Radio Type" Then
								$RadType = $DescDataSplit[2]
							ElseIf $DescDataSplit[1] = "Channel" Then
								$CHAN = $DescDataSplit[2]
							ElseIf $DescDataSplit[1] = "Authentication" Then
								$AUTH = $DescDataSplit[2]
							ElseIf $DescDataSplit[1] = "Encryption" Then
								$ENCR = $DescDataSplit[2]
							ElseIf $DescDataSplit[1] = "Basic Transfer Rates" Then
								$BTX = $DescDataSplit[2]
							ElseIf $DescDataSplit[1] = "Other Transfer Rates" Then
								$OTX = $DescDataSplit[2]
							ElseIf $DescDataSplit[1] = "First Active" Then
								$FirstActive = $DescDataSplit[2]
								$FirstActiveSplit = StringSplit($FirstActive, ' ')
								$FirstActiveDate = $FirstActiveSplit[1]
								$FirstActiveTime = $FirstActiveSplit[2]
							ElseIf $DescDataSplit[1] = "Last Updated" Then
								$LastActive = $DescDataSplit[2]
								$LastActiveSplit = StringSplit($LastActive, ' ')
								$LastActiveDate = $LastActiveSplit[1]
								$LastActiveTime = $LastActiveSplit[2]
							ElseIf $DescDataSplit[1] = "Manufacturer" Then
								$MANU = $DescDataSplit[2]
							ElseIf StringInStr($DescDataSplit[1], "http://", 0) Then
								$UrlSplit = StringSplit($DescDataSplit[1], '"')
								$FixedURL = StringReplace($UrlSplit[1], "//wifidb", "/wifidb") ;Fix phils kml error (waves fist)
								$URL = $FixedURL
								;ConsoleWrite($URL & @CRLF)
							EndIf
						Next
						ConsoleWrite($SSID & ' - ' & $BSSID & ' - ' & $NetType & ' - ' & $RadType & ' - ' & $CHAN & ' - ' & $AUTH & ' - ' & $ENCR & ' - ' & $BTX & ' - ' & $OTX & ' - ' & $FirstActiveDate & ' - ' & $FirstActiveTime & ' - ' & $LastActiveDate & ' - ' & $LastActiveTime & ' - ' & $MANU & ' - ' & $URL & @CRLF)
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
								;Sleep($RequestSleepTime);sleep because google returns results better
							EndIf
						Next
					EndIf
				Next
				If $PName <> "" Or BitAnd($Plon <> "", $Plat <> "") Or $PDesc <> "" Then
					Local $KmlMatchArray, $iRows, $iColumns, $iRval
					$query = "SELECT FirstActiveDate, FirstActiveTime, LastActiveDate, LastActiveTime FROM KMLDATA WHERE BSSID = '" & $BSSID & "' And SSID ='" & $SSID & "' And CHAN = '" & $CHAN & "' And AUTH = '" & $AUTH & "' And ENCR = '" & $ENCR & "' And RadType = '" & $RadType & "' limit 1"
					$iRval = _SQLite_GetTable2d($DBhndl, $query, $KmlMatchArray, $iRows, $iColumns)
					If $iRows = 0 Then ;If AP is not found then add it
						;Get Location Information
						Local $PCountryCode, $PCountryName, $PAreaName
						For $gl = 1 to $RetryAttempts
							$LocationArr = _GeonamesGetGpsLocation($PLat, $Plon)
							$PCountryCode = $LocationArr[1]
							$PCountryName = $LocationArr[2]
							$PAreaName = $LocationArr[3]
							$LocProvider = "GeoNames"
							If $PCountryCode <> "" Or $PCountryName <> "" Or $PAreaName <> "" Then ExitLoop
							$LocationArr = _GoogleGetGpsLocation($PLat, $Plon)
							$PCountryCode = $LocationArr[1]
							$PCountryName = StringReplace($LocationArr[2], "USA", "United States")
							$PAreaName = $LocationArr[3]
							$LocProvider = "Google"
							If $PCountryCode <> "" Or $PCountryName <> "" Or $PAreaName <> "" Then ExitLoop
							$LocProvider = ""
							Sleep(1000)
						Next
						ConsoleWrite($PCountryCode &  ' - ' & $PCountryName &  ' - ' & $PAreaName &  ' - ' & $LocProvider & @CRLF)
						;Add AP Data to DB
						$query = "INSERT INTO KMLDATA(Name,SSID,BSSID,NetType,RadType,CHAN,AUTH,ENCR,BTX,OTX,FirstActiveDate,FirstActiveTime,LastActiveDate,LastActiveTime,MANU,URL,Style,Latitude,Longitude,CountryCode,CountryName,AreaName,LocProvider) VALUES ('" & $PName & "','" & $SSID & "','" & $BSSID & "','" & $NetType & "','" & $RadType & "','" & $CHAN & "','" & $AUTH & "','" & $ENCR & "','" & $BTX & "','" & $OTX & "','" & $FirstActiveDate & "','" & $FirstActiveTime & "','" & $LastActiveDate & "','" & $LastActiveTime & "','" & $MANU & "','" & $URL & "','" & $PStyle & "','" & $PLat & "','" & $Plon & "','" & $PCountryCode & "','" & $PCountryName & "','" & $PAreaName & "','" & $LocProvider & "');"
						_SQLite_Exec($DBhndl, $query)
					ElseIf $iRows = 1 then
						$OrigFirstActiveDate = $KmlMatchArray[1][0]
						$OrigFirstActiveTime = $KmlMatchArray[1][1]
						$OrigLastActiveDate = $KmlMatchArray[1][2]
						$OrigLastActiveTime = $KmlMatchArray[1][3]
						ConsoleWrite($OrigFirstActiveDate & @CRLF)

						;See if new first time is older than old first time
						If _CompareDate($FirstActiveDate & ' ' & $FirstActiveTime, $OrigFirstActiveDate & ' ' & $OrigFirstActiveTime) = 2 Then ;Orig First active is newer....change to new first active
							$query = "UPDATE KMLDATA SET FirstActiveDate='" & $FirstActiveDate & "', FirstActiveTime='" & $FirstActiveTime & "' WHERE BSSID = '" & $BSSID & "' And SSID ='" & $SSID & "' And CHAN = '" & $CHAN & "' And AUTH = '" & $AUTH & "' And ENCR = '" & $ENCR & "' And RadType = '" & $RadType & "'"
							_SQLite_Exec($DBhndl, $query)
						EndIf

						;See if new last time is newer than old last time
						If _CompareDate($LastActiveDate & ' ' & $LastActiveTime, $OrigLastActiveDate & ' ' & $OrigLastActiveTime) = 1 Then ;Orig Last active is older....change to new last active
							$query = "UPDATE KMLDATA SET FirstActiveDate='" & $FirstActiveDate & "', FirstActiveTime='" & $FirstActiveTime & "' WHERE BSSID = '" & $BSSID & "' And SSID ='" & $SSID & "' And CHAN = '" & $CHAN & "' And AUTH = '" & $AUTH & "' And ENCR = '" & $ENCR & "' And RadType = '" & $RadType & "'"
							_SQLite_Exec($DBhndl, $query)
						EndIf
					EndIf
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
	;ConsoleWrite("Google" & @CRLF)
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
	;ConsoleWrite("Geonames" & @CRLF)
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

Func _CompareDate($d1, $d2);If $d1 is greater than $d2, return 1 ELSE return 2

	$d1 = StringReplace(StringReplace(StringReplace(StringReplace(StringReplace($d1, '-', ''), '/', ''), ':', ''), ':', ''), ' ', '')
	$d2 = StringReplace(StringReplace(StringReplace(StringReplace(StringReplace($d2, '-', ''), '/', ''), ':', ''), ':', ''), ' ', '')
	If $d1 = $d2 Then
		Return (0)
	ElseIf $d1 > $d2 Then
		Return (1)
	ElseIf $d1 < $d2 Then
		Return (2)
	Else
		Return (-1)
	EndIf

EndFunc   ;==>_CompareDate

Func _SetUpDbTables($dbfile)
	_SQLite_Startup()
	$DBhndl = _SQLite_Open($dbfile)
	_SQLite_Exec($DBhndl, "pragma synchronous=0");Speed vs Data security. Speed Wins for now.
	ConsoleWrite(@error & @CRLF)
	_SQLite_Exec($DBhndl, "CREATE TABLE KMLDATA (Name,SSID,BSSID,NetType,RadType,CHAN,AUTH,ENCR,BTX,OTX,FirstActiveDate,FirstActiveTime,LastActiveDate,LastActiveTime,MANU,URL,Style,Latitude,Longitude,CountryCode,CountryName,AreaName,LocProvider)")
EndFunc   ;==>_SetUpDbTables