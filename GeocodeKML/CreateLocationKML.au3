#RequireAdmin
#include "UDFs\_XMLDomWrapper.au3"
#include <Array.au3>
#include <INet.au3>
#include <SQLite.au3>


Dim $TmpDir = @ScriptDir & '\temp\'
Dim $DB = FileOpenDialog("Import from SDB", $TmpDir, "SQLite Database" & ' (*.sdb)', 1)

_SQLite_Startup()
$DBhndl = _SQLite_Open($DB)
_SQLite_Exec($DBhndl, "pragma synchronous=0");Speed vs Data security. Speed Wins for now.

Local $KmlDataArray, $iRows, $iColumns, $iRval
$query = "SELECT Name, Desc, Style, Latitude, Longitude, CountryCode, CountryName, AreaName FROM KMLDATA ORDER BY CountryCode, AreaName"
$iRval = _SQLite_GetTable2d($DBhndl, $query, $KmlDataArray, $iRows, $iColumns)
;_ArrayDisplay($KmlDataArray)
$KmlDataSize = $iRows

Dim $kmlfile
Dim $CurrentFileName

For $ek = 1 to $KmlDataSize
	$kName = $KmlDataArray[$ek][0]
	$kDesc = $KmlDataArray[$ek][1]
	$kStyle = $KmlDataArray[$ek][2]
	$kLat = $KmlDataArray[$ek][3]
	$kLon = $KmlDataArray[$ek][4]
	$kCountryCode = $KmlDataArray[$ek][5]
	$kCountryName = $KmlDataArray[$ek][6]
	$AreaName = $KmlDataArray[$ek][7]
	;ConsoleWrite($kName & '-' & $AreaName & '-' & $kLat & '-' & $kLon & '-' & $kCountryCode & '-' & $kCountryName & '-' & $kDesc & @CRLF)
	$CombinedName = 'vkml'
	If $kCountryCode <> "" Then $CombinedName &= "-" & $kCountryCode
	If $AreaName <> "" Then $CombinedName &= "-" & $AreaName
	$FileName = $TmpDir & $CombinedName & ".kml"
	If $Filename <> $CurrentFileName Then
		If $CurrentFileName <> "" Then
			;Close KML

		$kmlfile &= '	</Folder>' & @CRLF _
			 & '</Document>' & @CRLF _
			 & '</kml>' & @CRLF
			 ConsoleWrite("Write File: " & $CurrentFileName & @CRLF)
			FileWrite($CurrentFileName, $kmlfile)
		EndIf
		;Start New KML File
		$CurrentFileName = $Filename
		ConsoleWrite("New File: " & $FileName & @CRLF)
		FileDelete($FileName)
		;#comments-start

		Local $LatArray, $iRows, $iColumns, $iRval
		$query = "SELECT Latitude FROM KMLDATA WHERE CountryCode='" & $kCountryCode & "' AND AreaName='" & $AreaName & "' ORDER BY Latitude"
		$iRval = _SQLite_GetTable2d($DBhndl, $query, $LatArray, $iRows, $iColumns)
		Local $MinLat, $MaxLat
		For $fhl = 1 to  $iRows ;ORDER BY was not handling +/- properly. go though and find highest and lowest latitude
			$lval = ($LatArray[$fhl][0] - 0)
			If $fhl = 1 Then
				$MinLat = $lval
			Else
				If $lval < $MinLat Then $MinLat = $lval
			EndIf
			If $fhl = 1 Then
				$MaxLat = $lval
			Else
				If $lval > $MaxLat Then $MaxLat = $lval
			EndIf
		Next

		Local $LonArray, $iRows, $iColumns, $iRval
		$query = "SELECT Longitude FROM KMLDATA WHERE CountryCode='" & $kCountryCode & "' AND AreaName='" & $AreaName & "' ORDER BY Longitude"
		$iRval = _SQLite_GetTable2d($DBhndl, $query, $LonArray, $iRows, $iColumns)
		Local $MinLon, $MaxLon
		For $fhl = 1 to  $iRows ;ORDER BY was not handling +/- properly. go though and find highest and lowest longitude
			$lval = ($LonArray[$fhl][0] - 0)
			If $fhl = 1 Then
				$MinLon = $lval
			Else
				If $lval < $MinLon Then $MinLon = $lval
			EndIf
			If $fhl = 1 Then
				$MaxLon = $lval
			Else
				If $lval > $MaxLon Then $MaxLon = $lval
			EndIf
		Next

		ConsoleWrite('"' & $MinLat & '" - "' & $MaxLat & '"      -      "' & $MinLon & '" - "' & $MaxLon & '"' & @CRLF)
		;#comments-end

	  ;<minAltitude>0</minAltitude>
	  ;<maxAltitude>0</maxAltitude>
		$kmlfile = '<?xml version="1.0" encoding="UTF-8"?>' & @CRLF _
			 & '<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">' & @CRLF _
			 & '<Document>' & @CRLF _
			 & '	<description>Geocoding data from GeoNames.org</description>' & @CRLF _
			 & '	<name>' & $CombinedName & '</name>' & @CRLF _
			 & '	<Style id="openStyle">' & @CRLF _
			 & '		<IconStyle>' & @CRLF _
			 & '			<scale>.5</scale>' & @CRLF _
			 & '			<Icon>' & @CRLF _
			 & '				<href>http://vistumbler.sourceforge.net/images/program-images/open.png</href>' & @CRLF _
			 & '			</Icon>' & @CRLF _
			 & '		</IconStyle>' & @CRLF _
			 & '	</Style>' & @CRLF _
			 & '	<Style id="wepStyle">' & @CRLF _
			 & '		<IconStyle>' & @CRLF _
			 & '			<scale>.5</scale>' & @CRLF _
			 & '			<Icon>' & @CRLF _
			 & '				<href>http://vistumbler.sourceforge.net/images/program-images/secure-wep.png</href>' & @CRLF _
			 & '			</Icon>' & @CRLF _
			 & '		</IconStyle>' & @CRLF _
			 & '	</Style>' & @CRLF _
			 & '	<Style id="secureStyle">' & @CRLF _
			 & '		<IconStyle>' & @CRLF _
			 & '			<scale>.5</scale>' & @CRLF _
			 & '			<Icon>' & @CRLF _
			 & '				<href>http://vistumbler.sourceforge.net/images/program-images/secure.png</href>' & @CRLF _
			 & '			</Icon>' & @CRLF _
			 & '		</IconStyle>' & @CRLF _
			 & '	</Style>' & @CRLF _
			 & '	<Folder>' & @CRLF _
			 & '		<Region>' & @CRLF _
			 & '			<LatLonAltBox>' & @CRLF _
			 & '				<north>' & $MaxLat & '</north>' & @CRLF _
			 & '				<south>' & $MinLat & '</south>' & @CRLF _
			 & '		 		<east>' & $MaxLon & '</east>' & @CRLF _
			 & '		 		<west>' & $MinLon & '</west>' & @CRLF _
			 & '			</LatLonAltBox>' & @CRLF _
			 & '			<Lod>' & @CRLF _
			 & '	        	<minLodPixels>128</minLodPixels>' & @CRLF _
			 & '			</Lod>' & @CRLF _
			 & '		</Region>' & @CRLF _
			 & '		<name>Access Points</name>' & @CRLF
	EndIf
	$kmlfile &= '			<Placemark>' & @CRLF _
			 & '				<name>' & $kName & '</name>' & @CRLF _
			 & '				<description><![CDATA[' & $kDesc & ']]></description>' & @CRLF _
			 & '				<styleUrl>' & $kStyle & '</styleUrl>' & @CRLF _
			 & '				<Point>' & @CRLF _
			 & '					<coordinates>' & $kLon & ',' & $kLat & ',0</coordinates>' & @CRLF _
			 & '				</Point>' & @CRLF _
			 & '			</Placemark>' & @CRLF

Next

If $CurrentFileName <> "" Then
	;Close KML
	$kmlfile &= '	</Folder>' & @CRLF _
		& '</Document>' & @CRLF _
		& '</kml>' & @CRLF
		FileWrite($FileName, $kmlfile)
	EndIf