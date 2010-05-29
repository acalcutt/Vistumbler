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
		Local $LatArray, $iRows, $iColumns, $iRval
		$query = "SELECT Latitude FROM KMLDATA WHERE CountryCode='" & $kCountryCode & "' AND AreaName='" & $AreaName & "'ORDER BY Latitude DESC Limit 1"
		$iRval = _SQLite_GetTable2d($DBhndl, $query, $LatArray, $iRows, $iColumns)
		$MinLat = $LatArray[1][1]
		Local $LatArray, $iRows, $iColumns, $iRval
		$query = "SELECT Latitude FROM KMLDATA WHERE CountryCode='" & $kCountryCode & "' AND AreaName='" & $AreaName & "'ORDER BY Latitude ASC Limit 1"
		$iRval = _SQLite_GetTable2d($DBhndl, $query, $LatArray, $iRows, $iColumns)
		$MaxLat = $LatArray[1][1]
		ConsoleWrite($MinLat & ' - ' & $MaxLat & @CRLF)

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