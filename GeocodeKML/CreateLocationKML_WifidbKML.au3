#RequireAdmin
#include "UDFs\_XMLDomWrapper.au3"
#include "UDFs\Zip.au3"
#include <Array.au3>
#include <INet.au3>
#include <SQLite.au3>



Dim $TmpDir = @ScriptDir & '\temp\'
Dim $ExportDir = $TmpDir & 'export\'
Dim $FilesDir = $ExportDir & 'files\'
DirCreate($TmpDir)
DirRemove($ExportDir, 1)
DirCreate($ExportDir)
DirCreate($FilesDir)


Dim $DB = FileOpenDialog("Import from SDB", $TmpDir, "SQLite Database" & ' (*.sdb)', 1)

_SQLite_Startup()
$DBhndl = _SQLite_Open($DB)
_SQLite_Exec($DBhndl, "pragma synchronous=0");Speed vs Data security. Speed Wins for now.

Local $KmlDataArray, $iRows, $iColumns, $iRval
$query = "SELECT SSID, BSSID, NetType, RadType, CHAN, AUTH, ENCR, BTX, OTX, FirstActiveDate, FirstActiveTime, LastActiveDate, LastActiveTime, MANU, URL, Style, Latitude, Longitude, CountryCode, CountryName, AreaName, LocProvider FROM KMLDATA ORDER BY CountryCode, AreaName"
$iRval = _SQLite_GetTable2d($DBhndl, $query, $KmlDataArray, $iRows, $iColumns)
;_ArrayDisplay($KmlDataArray)
$KmlDataSize = $iRows

$KmlLinkFile = '<?xml version="1.0" encoding="UTF-8"?>' & @CRLF _
				& '<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">' & @CRLF _
				& '<Document>' & @CRLF _
				& '	<name>Vistumbler</name>' & @CRLF _
				& '	<Folder>' & @CRLF _
				& '		<name>Geocoded KML</name>' & @CRLF _
				& '		<Style>' & @CRLF _
				& '			<ListStyle>' & @CRLF _
				& '				<listItemType>check</listItemType>' & @CRLF _
				& '				<bgColor>00ffffff</bgColor>' & @CRLF _
				& '				<maxSnippetLines>2</maxSnippetLines>' & @CRLF _
				& '			</ListStyle>' & @CRLF _
				& '		</Style>' & @CRLF


Dim $kmlfile
Dim $CurrentFileName

For $ek = 1 to $KmlDataSize
	$kSSID = $KmlDataArray[$ek][0]
	$kBSSID = $KmlDataArray[$ek][1]
	$kNetType = $KmlDataArray[$ek][2]
	$kRadType = $KmlDataArray[$ek][3]
	$kCHAN = $KmlDataArray[$ek][4]
	$kAUTH = $KmlDataArray[$ek][5]
	$kENCR = $KmlDataArray[$ek][6]
	$kBTX = $KmlDataArray[$ek][7]
	$kOTX = $KmlDataArray[$ek][8]
	$kFirstActiveDate = $KmlDataArray[$ek][9]
	$kFirstActiveTime = $KmlDataArray[$ek][10]
	$kLastActiveDate = $KmlDataArray[$ek][11]
	$kLastActiveTime = $KmlDataArray[$ek][12]
	$kMANU = $KmlDataArray[$ek][13]
	$kURL = $KmlDataArray[$ek][14]
	$kStyle = $KmlDataArray[$ek][15]
	$kLatitude = $KmlDataArray[$ek][16]
	$kLongitude = $KmlDataArray[$ek][17]
	$kCountryCode = $KmlDataArray[$ek][18]
	$kCountryName = $KmlDataArray[$ek][19]
	$kAreaName = $KmlDataArray[$ek][20]
	$kLocProvider = $KmlDataArray[$ek][21]

	$CombinedName = 'vkml'
	If $kCountryCode <> "" Then $CombinedName &= "-" & $kCountryCode
	If $kAreaName <> "" Then $CombinedName &= "-" & $kAreaName
	$FileName = $FilesDir & $CombinedName & ".kml"
	If $Filename <> $CurrentFileName Then
		If $CurrentFileName <> "" Then
			;Close KML

		$kmlfile &= '	</Folder>' & @CRLF _
			 & '</Document>' & @CRLF _
			 & '</kml>' & @CRLF
			 ConsoleWrite("Write File: " & $CurrentFileName & @CRLF)
			FileWrite($CurrentFileName, $kmlfile)
		EndIf
		;Creat KML Link File Code
		$KmlName = ''
		If $kCountryCode <> "" Then $KmlName &= $kCountryCode
		If $kAreaName <> "" Then $KmlName &= "-" & $kAreaName
		If $KmlName = "" Then $KmlName = "None"
		$KmlLinkFile &= '		<NetworkLink>' & @CRLF _
					& '			<name>' & $KmlName & '</name>' & @CRLF _
					& '			<Link>' & @CRLF _
					& '				<href>files/' & $CombinedName & '.kml</href>' & @CRLF _
					& '			</Link>' & @CRLF _
					& '		</NetworkLink>' & @CRLF
		;Start New KML File
		$CurrentFileName = $Filename
		ConsoleWrite("New File: " & $FileName & @CRLF)
		FileDelete($FileName)

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
			 & '				<name></name>' & @CRLF _
			 & '				<description><![CDATA[<b>SSID: </b>' & $kSSID & '<br /><b>Mac Address: </b>' & $kBSSID & '<br /><b>Network Type: </b>' & $kNetType & '<br /><b>Radio Type: </b>' & $kRadType & '<br /><b>Channel: </b>' & $kCHAN & '<br /><b>Authentication: </b>' & $kAUTH & '<br /><b>Encryption: </b>' & $kENCR & '<br /><b>Basic Transfer Rates: </b>' & $kBTX & '<br /><b>Other Transfer Rates: </b>' & $kOTX & '<br /><b>First Active: </b>' & $kFirstActiveDate & ' ' & $kFirstActiveTime & '<br /><b>Last Updated: </b>' & $kLastActiveDate & ' ' & $kLastActiveTime & '<br /><b>Latitude: </b>' & $kLatitude & '<br /><b>Longitude: </b>' & $kLongitude & '<br /><b>Manufacturer: </b>' & $kMANU & '<br /><a href="<a href="' & $kURL & '">WiFiDB Link</a><br /><br /><b>Country Code: </b>' & $kCountryCode & '<br /><b>Country Name: </b>' & $kCountryName & '<br /><b>Area Name: </b>' & $kAreaName & '<br /><b>Location Provider: </b>' & $kLocProvider & '<br />]]></description>' & @CRLF _
			 & '				<styleUrl>' & $kStyle & '</styleUrl>' & @CRLF _
			 & '				<Point>' & @CRLF _
			 & '					<coordinates>' & $kLongitude & ',' & $kLatitude & ',0</coordinates>' & @CRLF _
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

$KmlLinkFile &= '	</Folder>' & @CRLF _
				& '</Document>' & @CRLF _
				& '</kml>' & @CRLF

FileWrite($ExportDir & 'doc.kml', $KmlLinkFile)

$tmpzip  = $TmpDir & '\export.zip'
$kmz = $TmpDir & '\export.kmz'

$ziphnd = _Zip_Create($tmpzip, 1)
ConsoleWrite(_Zip_AddItem($ziphnd, $FilesDir) & '-' & @error & @CRLF)
ConsoleWrite(_Zip_AddItem($ziphnd, $ExportDir & 'doc.kml') & '-' & @error & @CRLF)
;FileMove($tmpzip, $kmz)
