;#RequireAdmin
;#include "UDFs\_XMLDomWrapper.au3"
#include "UDFs\FileListToArray3.au3"
#include "UDFs\MD5.au3"
#include <Array.au3>
#include <INet.au3>
#include <SQLite.au3>
Dim $settings = 'settings.ini'
Dim $SearchWord_None = 'None';IniRead($DefaultLanguagePath, 'SearchWords', 'None', 'None')
Dim $SearchWord_Open = 'Open';IniRead($DefaultLanguagePath, 'SearchWords', 'Open', 'Open')
Dim $SearchWord_Wep = 'WEP';IniRead($DefaultLanguagePath, 'SearchWords', 'WEP', 'WEP')
Dim $dBmMaxSignal = '-30';IniRead($settings, 'Vistumbler', 'dBmMaxSignal', '-30')
Dim $dBmDissociationSignal = '-85';IniRead($settings, 'Vistumbler', 'dBmDissociationSignal', '-85')
Dim $APID, $HISTID, $GPS_ID, $FILE_ID
Dim $RetryAttempts = 1 ;Number of times to retry getting location
Dim $DBhndl
Dim $TmpDir = @ScriptDir & '\temp\'
_SQLite_Startup()

;Set Up DB
;$ldatetimestamp = StringFormat("%04i", @YEAR) & '-' & StringFormat("%02i", @MON) & '-' & StringFormat("%02i", @MDAY) & ' ' & @HOUR & '-' & @MIN & '-' & @SEC
$DB = $TmpDir & 'VS1_Import.SDB'
$ExistingDB = FileExists($DB)
If $ExistingDB = 1 Then ConsoleWrite("! " & $DB & " already exits. Import will use existing file" & @CRLF)
If $ExistingDB = 0 Then ConsoleWrite("+> Creating " & $DB & @CRLF)
$DBhndl = _SQLite_Open($DB)
If $ExistingDB = 1 Then _GetDbValues($DBhndl)
If $ExistingDB = 0 Then _SetUpDbTables($DBhndl)
;Import files
_SearchVistumblerFiles()


Func _SearchVistumblerFiles()
   $VistumblerFilesFolder = FileSelectFolder ("Select folder that contains vistumbler files", "")
   If @error=1 Then
	  MsgBox(0, "Error", "No folder selected, exiting")
	  Exit
   Else
		$VistumblerFiles = _FileListToArray3($VistumblerFilesFolder, "*.VS1", 1, 1, 1)
		For $f=1 to $VistumblerFiles[0]
			;Safe Kill Import if killswitch is set
			$KillSwitch = IniRead($settings, 'Settings', 'KillSwitch', '0')
			If $KillSwitch = 1 Then
				ConsoleWrite("! Kill switch is enabled. Exiting..." & @CRLF)
				Exit
			EndIf
			;Import File
			$filename = $VistumblerFiles[$f]
			$loadfile = $VistumblerFiles[$f]
			$loadfileMD5 = _MD5ForFile($loadfile)
			ConsoleWrite('File:' & $f & '/' & $VistumblerFiles[0] & ' | File:' & $loadfile & ' | MD5:' & $loadfileMD5 & ' | Size:' & Round(FileGetSize ($loadfile)/1024) & 'kB' & @CRLF)
			Local $MD5MatchArray, $iRows, $iColumns, $iRval
			$query = "SELECT MD5 FROM LoadedFiles WHERE MD5='" & $loadfileMD5 & "'"
			$iRval = _SQLite_GetTable2d($DBhndl, $query, $MD5MatchArray, $iRows, $iColumns)
			$FoundMD5Match = $iRows

			If $FoundMD5Match <> 0 Then
				ConsoleWrite('! File Already Exists '& $filename & @CRLF)
			Else
				ConsoleWrite('+> Importing New File ' & $filename & @CRLF)
				$FILE_ID += 1
				_ImportVS1($loadfile)
				$query = "INSERT INTO LoadedFiles(FileID,File,MD5) VALUES ('" & $FILE_ID & "','" & $loadfile & "','" & $loadfileMD5 & "');"
				_SQLite_Exec($DBhndl, $query)
			EndIf

		Next
   EndIf
EndFunc

Func _ImportVS1($VS1file)
	_SQLite_Exec($DBhndl, "CREATE TABLE TempGpsIDMatchTable (OldGpsID,NewGpsID)")
	$vistumblerfile = FileOpen($VS1file, 0)
	If $vistumblerfile <> -1 Then
		$begintime = TimerInit()
		$currentline = 1
		$AddAP = 0
		$AddGID = 0
		;Get Total number of lines
		$totallines = 0
		While 1
			FileReadLine($vistumblerfile)
			If @error = -1 Then ExitLoop
			$totallines += 1
		WEnd
		;Start Importing File
		$DispTimer = TimerInit()
		For $Load = 1 To $totallines
			$linein = FileReadLine($vistumblerfile, $Load);Open Line in file
			If @error = -1 Then ExitLoop
			If StringTrimRight($linein, StringLen($linein) - 1) <> "#" Then
				$loadlist = StringSplit($linein, '|');Split Infomation of AP on line
				;ConsoleWrite($loadlist[0] & @CRLF)
				If $loadlist[0] = 6 Or $loadlist[0] = 12 Then ; If Line is GPS ID Line
					If $loadlist[0] = 6 Then
						$LoadGID = $loadlist[1]
						$LoadLat = _Format_GPS_DMM($loadlist[2])
						$LoadLon = _Format_GPS_DMM($loadlist[3])
						$LoadSat = $loadlist[4]
						$LoadHorDilPitch = 0
						$LoadAlt = 0
						$LoadGeo = 0
						$LoadSpeedKmh = 0
						$LoadSpeedMPH = 0
						$LoadTrackAngle = 0
						$LoadDate = $loadlist[5]
						$ld = StringSplit($LoadDate, '-')
						If StringLen($ld[1]) <> 4 Then $LoadDate = StringFormat("%04i", $ld[3]) & '-' & StringFormat("%02i", $ld[1]) & '-' & StringFormat("%02i", $ld[2])
						$LoadTime = $loadlist[6]
						If StringInStr($LoadTime, '.') = 0 Then $LoadTime &= '.000'
					ElseIf $loadlist[0] = 12 Then
						$LoadGID = $loadlist[1]
						$LoadLat = _Format_GPS_DMM($loadlist[2])
						$LoadLon = _Format_GPS_DMM($loadlist[3])
						$LoadSat = $loadlist[4]
						$LoadHorDilPitch = $loadlist[5]
						$LoadAlt = $loadlist[6]
						$LoadGeo = $loadlist[7]
						$LoadSpeedKmh = $loadlist[8]
						$LoadSpeedMPH = $loadlist[9]
						$LoadTrackAngle = $loadlist[10]
						$LoadDate = $loadlist[11]
						$ld = StringSplit($LoadDate, '-')
						If StringLen($ld[1]) <> 4 Then $LoadDate = StringFormat("%04i", $ld[3]) & '-' & StringFormat("%02i", $ld[1]) & '-' & StringFormat("%02i", $ld[2])
						$LoadTime = $loadlist[12]
						If StringInStr($LoadTime, '.') = 0 Then $LoadTime &= '.000'
					 EndIf
					   Local $TempGidMatchArray, $iRows, $iColumns, $iRval
					   $query = "SELECT OldGpsID FROM TempGpsIDMatchTable WHERE OldGpsID = '" & $LoadGID & "'"
					   $iRval = _SQLite_GetTable2d($DBhndl, $query, $TempGidMatchArray, $iRows, $iColumns)
					   $FoundTempGidMatch = $iRows
					   If $FoundTempGidMatch = 0 Then
						   Local $GpsMatchArray, $iRows, $iColumns, $iRval
						   $query = "SELECT GPSID FROM GPS WHERE Latitude = '" & $LoadLat & "' And Longitude = '" & $LoadLon & "' And NumOfSats = '" & $LoadSat & "' And Date1 = '" & $LoadDate & "' And Time1 = '" & $LoadTime & "'"
						   $iRval = _SQLite_GetTable2d($DBhndl, $query, $GpsMatchArray, $iRows, $iColumns)
						   $FoundGpsMatch = $iRows
						   If $FoundGpsMatch = 0 Then
							   $AddGID += 1
							   $GPS_ID += 1
							   ;Add GPS ID
							   $query = "INSERT INTO GPS(GPSID,Latitude,Longitude,NumOfSats,HorDilPitch,Alt,Geo,SpeedInMPH,SpeedInKmH,TrackAngle,Date1,Time1) VALUES ('" & $GPS_ID & "','" & $LoadLat & "','" & $LoadLon & "','" & $LoadSat & "','" & $LoadHorDilPitch & "','" & $LoadAlt & "','" & $LoadGeo & "','" & $LoadSpeedMPH & "','" & $LoadSpeedKmh & "','" & $LoadTrackAngle & "','" & $LoadDate & "','" & $LoadTime & "');"
							   _SQLite_Exec($DBhndl, $query)
							   ;Add to GPS match table
							   $query = "INSERT INTO TempGpsIDMatchTable(OldGpsID,NewGpsID) VALUES ('" & $LoadGID & "','" & $GPS_ID & "');"
							   _SQLite_Exec($DBhndl, $query)
						   ElseIf $FoundGpsMatch = 1 Then
							   $NewGpsId = $GpsMatchArray[1][0]
							   ;Add to GPS match table
							   $query = "INSERT INTO TempGpsIDMatchTable(OldGpsID,NewGpsID) VALUES ('" & $LoadGID & "','" & $NewGpsId & "');"
							   _SQLite_Exec($DBhndl, $query)
						   EndIf
					   ElseIf $FoundTempGidMatch = 1 Then
						   Local $GpsMatchArray, $iRows, $iColumns, $iRval
						   $query = "SELECT GPSID FROM GPS WHERE Latitude = '" & $LoadLat & "' And Longitude = '" & $LoadLon & "' And NumOfSats = '" & $LoadSat & "' And Date1 = '" & $LoadDate & "' And Time1 = '" & $LoadTime & "'"
						   $iRval = _SQLite_GetTable2d($DBhndl, $query, $GpsMatchArray, $iRows, $iColumns)
						   $FoundGpsMatch = $iRows
						   If $FoundGpsMatch = 0 Then
							   $AddGID += 1
							   $GPS_ID += 1
							   ;Add GPS ID
							   $query = "INSERT INTO GPS(GPSID,Latitude,Longitude,NumOfSats,HorDilPitch,Alt,Geo,SpeedInMPH,SpeedInKmH,TrackAngle,Date1,Time1) VALUES ('" & $GPS_ID & "','" & $LoadLat & "','" & $LoadLon & "','" & $LoadSat & "','" & $LoadHorDilPitch & "','" & $LoadAlt & "','" & $LoadGeo & "','" & $LoadSpeedMPH & "','" & $LoadSpeedKmh & "','" & $LoadTrackAngle & "','" & $LoadDate & "','" & $LoadTime & "');"
							   _SQLite_Exec($DBhndl, $query)
						   ElseIf $FoundGpsMatch = 1 Then
							   $NewGpsId = $GpsMatchArray[1][0]
							   $query = "UPDATE TempGpsIDMatchTable SET NewGpsID='" & $NewGpsId & "' WHERE OldGpsID='" & $LoadGID & "'"
							   _SQLite_Exec($DBhndl, $query)
						   EndIf
					   EndIf
				ElseIf $loadlist[0] = 13 Then ;If String is VS1 v3 data line
					$Found = 0
					$SSID = StringStripWS($loadlist[1], 3)
					$BSSID = StringStripWS($loadlist[2], 3)
					$Authentication = StringStripWS($loadlist[4], 3)
					$Encryption = StringStripWS($loadlist[5], 3)
					$LoadSecType = StringStripWS($loadlist[6], 3)
					$RadioType = StringStripWS($loadlist[7], 3)
					$Channel = StringStripWS($loadlist[8], 3)
					$BasicTransferRates = StringStripWS($loadlist[9], 3)
					$OtherTransferRates = StringStripWS($loadlist[10], 3)
					$NetworkType = StringStripWS($loadlist[11], 3)
					$GigSigHist = StringStripWS($loadlist[13], 3)
					;Go through GID/Signal history and add information to DB
					$GidSplit = StringSplit($GigSigHist, '-')
					For $loaddat = 1 To $GidSplit[0]
						$GidSigSplit = StringSplit($GidSplit[$loaddat], ',')
						If $GidSigSplit[0] = 2 Then
							$ImpGID = $GidSigSplit[1]
							$ImpSig = StringReplace(StringStripWS($GidSigSplit[2], 3), '%', '')
							If $ImpSig = '' Then $ImpSig = '0' ;Old VS1 file no signal fix
							$ImpRSSI = _SignalPercentToDb($ImpSig)

							Local $TempGpsIDMatchArray, $iRows, $iColumns, $iRval
							$query = "SELECT NewGpsID FROM TempGpsIDMatchTable WHERE OldGpsID='" & $ImpGID & "'"
							$iRval = _SQLite_GetTable2d($DBhndl, $query, $TempGpsIDMatchArray, $iRows, $iColumns)
							If $iRows = 1 Then
								$NewGID = $TempGpsIDMatchArray[1][0]
								$NewApAdded = _AddApData(0, $NewGID, $BSSID, $SSID, $Channel, $Authentication, $Encryption, $NetworkType, $RadioType, $BasicTransferRates, $OtherTransferRates, $ImpSig, $ImpRSSI)
								If $NewApAdded <> 0 Then $AddAP += 1
							EndIf
						EndIf
					Next
				ElseIf $loadlist[0] = 15 Then ;If String is VS1 v4 data line
					;_ArrayDisplay($loadlist)
					$Found = 0
					$SSID = StringStripWS($loadlist[1], 3)
					$BSSID = StringStripWS($loadlist[2], 3)
					;$ImpManu = StringStripWS($loadlist[3], 3)
					$Authentication = StringStripWS($loadlist[4], 3)
					$Encryption = StringStripWS($loadlist[5], 3)
					$LoadSecType = StringStripWS($loadlist[6], 3)
					$RadioType = StringStripWS($loadlist[7], 3)
					$Channel = StringStripWS($loadlist[8], 3)
					$BasicTransferRates = StringStripWS($loadlist[9], 3)
					$OtherTransferRates = StringStripWS($loadlist[10], 3)
					$HighSignal = StringStripWS($loadlist[11], 3)
					$HighRSS1 = StringStripWS($loadlist[12], 3)
					$NetworkType = StringStripWS($loadlist[13], 3)
					;$ImpLabel = StringStripWS($loadlist[14], 3)
					$GigSigHist = StringStripWS($loadlist[15], 3)

					;Go through GID/Signal history and add information to DB
					$GidSplit = StringSplit($GigSigHist, '\')
					For $loaddat = 1 To $GidSplit[0]
						$GidSigSplit = StringSplit($GidSplit[$loaddat], ',')
						If $GidSigSplit[0] = 3 Then
							$ImpGID = $GidSigSplit[1]
							$ImpSig = StringReplace(StringStripWS($GidSigSplit[2], 3), '%', '')
							$ImpRSSI = $GidSigSplit[3]
							Local $TempGpsIDMatchArray, $iRows, $iColumns, $iRval
							$query = "SELECT NewGpsID FROM TempGpsIDMatchTable WHERE OldGpsID=" & $ImpGID
							$iRval = _SQLite_GetTable2d($DBhndl, $query, $TempGpsIDMatchArray, $iRows, $iColumns)
							If $iRows = 1 Then
								$NewGID = $GpsMatchArray[1][0]
								$NewApAdded = _AddApData(0, $NewGID, $BSSID, $SSID, $Channel, $Authentication, $Encryption, $NetworkType, $RadioType, $BasicTransferRates, $OtherTransferRates, $ImpSig, $ImpRSSI)
								If $NewApAdded <> 0 Then $AddAP += 1
							EndIf
						EndIf
					Next
				ElseIf $loadlist[0] = 17 Then ; If string is TXT data line
					$Found = 0
					$SSID = StringStripWS($loadlist[1], 3)
					$BSSID = StringStripWS($loadlist[2], 3)
					$HighGpsSignal = StringReplace(StringStripWS($loadlist[4], 3), '%', '')
					$RSSI = _SignalPercentToDb($HighGpsSignal)
					$Authentication = StringStripWS($loadlist[5], 3)
					$Encryption = StringStripWS($loadlist[6], 3)
					$RadioType = StringStripWS($loadlist[7], 3)
					$Channel = StringStripWS($loadlist[8], 3)
					$LoadLatitude = _Format_GPS_All_to_DMM(StringStripWS($loadlist[9], 3))
					$LoadLongitude = _Format_GPS_All_to_DMM(StringStripWS($loadlist[10], 3))
					$BasicTransferRates = StringStripWS($loadlist[11], 3)
					$OtherTransferRates = StringStripWS($loadlist[12], 3)
					$LoadFirstActive = StringStripWS($loadlist[13], 3)
					$LoadLastActive = StringStripWS($loadlist[14], 3)
					$NetworkType = StringStripWS($loadlist[15], 3)
					$SignalHistory = StringStripWS($loadlist[17], 3)
					$LoadSat = '00'
					$tsplit = StringSplit($LoadFirstActive, ' ')
					$LoadFirstActive_Time = $tsplit[2]
					If StringInStr($LoadFirstActive_Time, '.') = 0 Then $LoadFirstActive_Time &= '.000'
					$LoadFirstActive_Date = $tsplit[1]
					$ld = StringSplit($LoadFirstActive_Date, '-')
					If StringLen($ld[1]) <> 4 Then $LoadFirstActive_Date = StringFormat("%04i", $ld[3]) & '-' & StringFormat("%02i", $ld[1]) & '-' & StringFormat("%02i", $ld[2])
					$tsplit = StringSplit($LoadLastActive, ' ')
					$LoadLastActive_Time = $tsplit[2]
					If StringInStr($LoadLastActive_Time, '.') = 0 Then $LoadLastActive_Time &= '.000'
					$LoadLastActive_Date = $tsplit[1]
					$ld = StringSplit($LoadLastActive_Date, '-')
					If StringLen($ld[1]) <> 4 Then $LoadLastActive_Date = StringFormat("%04i", $ld[3]) & '-' & StringFormat("%02i", $ld[1]) & '-' & StringFormat("%02i", $ld[2])

					;Check If First GPS Information is Already in DB, If it is get the GpsID, If not add it and get its GpsID

					Local $GpsMatchArray, $iRows, $iColumns, $iRval
					$query = "SELECT GPSID FROM GPS WHERE Latitude = '" & $LoadLatitude & "' And Longitude = '" & $LoadLongitude & "' And Date1 = '" & $LoadFirstActive_Date & "' And Time1 = '" & $LoadFirstActive_Time & "'"
					$iRval = _SQLite_GetTable2d($DBhndl, $query, $GpsMatchArray, $iRows, $iColumns)
					If $iRows = 0 Then
						$AddGID += 1
						$GPS_ID += 1
						$query = "INSERT INTO GPS(GPSID,Latitude,Longitude,NumOfSats,HorDilPitch,Alt,Geo,SpeedInMPH,SpeedInKmH,TrackAngle,Date1,Time1) VALUES ('" & $GPS_ID & "','" & $LoadLatitude & "','" & $LoadLongitude & "','" & $LoadSat & "',0,0,0,0,0,0,'" & $LoadFirstActive_Date & "','" & $LoadFirstActive_Time & "');"
						_SQLite_Exec($DBhndl, $query)
						$LoadGID = $GPS_ID
					Else
						$LoadGID = $GpsMatchArray[1][0]
					EndIf

					;Add First AP Info to DB, Listview, and Treeview
					$NewApAdded = _AddApData(0, $LoadGID, $BSSID, $SSID, $Channel, $Authentication, $Encryption, $NetworkType, $RadioType, $BasicTransferRates, $OtherTransferRates, $HighGpsSignal, $RSSI)
					If $NewApAdded <> 0 Then $AddAP += 1
					;Check If Last GPS Information is Already in DB, If it is get the GpsID, If not add it and get its GpsID
					Local $GpsMatchArray, $iRows, $iColumns, $iRval
					$query = "SELECT GPSID FROM GPS WHERE Latitude = '" & $LoadLatitude & "' And Longitude = '" & $LoadLongitude & "' And Date1 = '" & $LoadFirstActive_Date & "' And Time1 = '" & $LoadLastActive_Time & "'"
					$iRval = _SQLite_GetTable2d($DBhndl, $query, $GpsMatchArray, $iRows, $iColumns)
					If $iRows = 0 Then
						$AddGID += 1
						$GPS_ID += 1
						$query = "INSERT INTO GPS(GPSID,Latitude,Longitude,NumOfSats,HorDilPitch,Alt,Geo,SpeedInMPH,SpeedInKmH,TrackAngle,Date1,Time1) VALUES ('" & $GPS_ID & "','" & $LoadLatitude & "','" & $LoadLongitude & "','" & $LoadSat & "',0,0,0,0,0,0,'" & $LoadLastActive_Date & "','" & $LoadLastActive_Time & "');"
						_SQLite_Exec($DBhndl, $query)
						$LoadGID = $GPS_ID
					Else
						$LoadGID = $GpsMatchArray[1][1]
					EndIf
					;Add Last AP Info to DB, Listview, and Treeview
					$NewApAdded = _AddApData(0, $LoadGID, $BSSID, $SSID, $Channel, $Authentication, $Encryption, $NetworkType, $RadioType, $BasicTransferRates, $OtherTransferRates, $HighGpsSignal, $RSSI)
					If $NewApAdded <> 0 Then $AddAP += 1
				Else
					;ExitLoop
				EndIf
			EndIf
			;Display line info to console
			If TimerDiff($DispTimer) > 15000 Then
				$datetimestamp = StringFormat("%04i", @YEAR) & '-' & StringFormat("%02i", @MON) & '-' & StringFormat("%02i", @MDAY) & ' ' & @HOUR & ':' & @MIN & ':' & @SEC
				ConsoleWrite('--> ' & $datetimestamp & ' - Line: ' & $Load & '/' &  $totallines & @CRLF)
				$DispTimer = TimerInit()
			EndIf
		Next
	EndIf
	FileClose($vistumblerfile)
	$query = "DELETE FROM TempGpsIDMatchTable"
	_SQLite_Exec($DBhndl, $query)
	$query = "DROP TABLE TempGpsIDMatchTable"
	_SQLite_Exec($DBhndl, $query)
EndFunc   ;==>_ImportVS1

Func _AddApData($New, $NewGpsId, $BSSID, $SSID, $CHAN, $AUTH, $ENCR, $NETTYPE, $RADTYPE, $BTX, $OtX, $SIG, $RSSI)
	;ConsoleWrite("$New:" & $New & " $NewGpsId:" & $NewGpsId & " $BSSID:" & $BSSID & " $SSID:" & $SSID & " $CHAN:" & $CHAN & " $AUTH:" & $AUTH & " $ENCR:" & $ENCR & " $NETTYPE:" & $NETTYPE & " $RADTYPE" & $RADTYPE & " $BTX:" & $BTX & "$OtX:" & $OtX & " $SIG:" & $SIG & " $RSSI:" & $RSSI & @CRLF)
	If $New = 1 And $SIG <> 0 Then
		$AP_Status = "Active";$Text_Active
		$AP_StatusNum = 1
		$AP_DisplaySig = $SIG
		$AP_DisplayRSSI = $RSSI
	Else
		$AP_Status = "Dead";$Text_Dead
		$AP_StatusNum = 0
		$AP_DisplaySig = 0
		$AP_DisplayRSSI = -100
	EndIf
	;Get Current GPS/Date/Time Information
	Local $GpsMatchArray, $iRows, $iColumns, $iRval
	$query = "SELECT Latitude, Longitude, NumOfSats, Date1, Time1 FROM GPS WHERE GpsID = '" & $NewGpsId & "' limit 1"
	$iRval = _SQLite_GetTable2d($DBhndl, $query, $GpsMatchArray, $iRows, $iColumns)
	;$GpsMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
	$New_Lat = $GpsMatchArray[1][0]
	$New_Lon = $GpsMatchArray[1][1]
	$New_NumSat = $GpsMatchArray[1][2]
	$New_Date = $GpsMatchArray[1][3]
	$New_Time = $GpsMatchArray[1][4]
	$New_DateTime = $New_Date & ' ' & $New_Time
	$NewApFound = 0
	If $GpsMatchArray <> 0 Then ;If GPS ID Is Found
		;Query AP table for New AP
		Local $ApMatchArray, $iRows, $iColumns, $iRval
		$query = "SELECT ApID, ListRow, HighGpsHistId, LastGpsID, FirstHistID, LastHistID, Active, SecType, HighSignal, HighRSSI FROM AP WHERE BSSID = '" & $BSSID & "' And SSID ='" & StringReplace($SSID, "'", "''") & "' And CHAN = '" & $CHAN & "' And AUTH = '" & $AUTH & "' And ENCR = '" & $ENCR & "' And RADTYPE = '" & $RADTYPE & "' limit 1"
		$iRval = _SQLite_GetTable2d($DBhndl, $query, $ApMatchArray, $iRows, $iColumns)
		;$ApMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
		$FoundApMatch = $iRows
		If $FoundApMatch = 0 Then ;If AP is not found then add it
			$APID += 1
			$HISTID += 1
			$NewApFound = $APID
			$ListRow = -1
			;Set Security Type
			If BitOR($AUTH = $SearchWord_Open, $AUTH = 'Open') And BitOR($ENCR = $SearchWord_None, $ENCR = 'Unencrypted') Then
				$SecType = 1
			ElseIf BitOR($ENCR = $SearchWord_Wep, $ENCR = 'WEP') Then
				$SecType = 2
			Else
				$SecType = 3
			EndIf
			;Get Label and Manufacturer information
			$MANUF = "";_FindManufacturer($BSSID);Set Manufacturer
			$LABEL = "";_SetLabels($BSSID)
			;Set HISTID
			If $New_Lat <> 'N 0000.0000' And $New_Lon <> 'E 0000.0000' Then
				$DBHighGpsHistId = $HISTID
			Else
				$DBHighGpsHistId = '0'
			EndIf
			;Add History Information
			$query = "INSERT INTO Hist(HistID,ApID,GpsID,FileID,Signal,RSSI,Date1,Time1) VALUES ('" & $HISTID & "','" & $APID & "','" & $NewGpsId & "','" & $FILE_ID & "','" & $SIG & "','" & $RSSI & "','" & $New_Date & "','" & $New_Time & "');"
			_SQLite_Exec($DBhndl, $query)
			;Add AP Data into the AP table
			$query = "INSERT INTO AP(ApID,ListRow,Active,BSSID,SSID,CHAN,AUTH,ENCR,SECTYPE,NETTYPE,RADTYPE,BTX,OTX,HighGpsHistId,LastGpsID,FirstHistID,LastHistID,MANU,LABEL,Signal,HighSignal,RSSI,HighRSSI,CountryCode,CountryName,AdminCode,AdminName,Admin2Name) VALUES ('" & $APID & "','" & $ListRow & "','" & $AP_StatusNum & "','" & $BSSID & "','" & StringReplace($SSID, "'", "''") & "','" & $CHAN & "','" & $AUTH & "','" & $ENCR & "','" & $SecType & "','" & $NETTYPE & "','" & $RADTYPE & "','" & $BTX & "','" & $OtX & "','" & $DBHighGpsHistId & "','" & $NewGpsId & "','" & $HISTID & "','" & $HISTID & "','" & StringReplace($MANUF, "'", "''") & "','" & StringReplace($LABEL, "'", "''") & "','" & $AP_DisplaySig & "','" & $SIG & "','" & $AP_DisplayRSSI & "','" & $RSSI & "','','','','','');"
			_SQLite_Exec($DBhndl, $query)
		ElseIf $FoundApMatch = 1 Then ;If the AP is already in the AP table, update it
			$Found_APID = $ApMatchArray[1][0]
			$Found_ListRow = $ApMatchArray[1][1]
			$Found_HighGpsHistId = $ApMatchArray[1][2]
			$Found_LastGpsID = $ApMatchArray[1][3]
			$Found_FirstHistID = $ApMatchArray[1][4]
			$Found_LastHistID = $ApMatchArray[1][5]
			$Found_Active = $ApMatchArray[1][6]
			$Found_SecType = $ApMatchArray[1][7]
			$Found_HighSignal = Round($ApMatchArray[1][8])
			$Found_HighRSSI = Round($ApMatchArray[1][9])
			$HISTID += 1
			;Set Last Time and First Time
			If $New = 1 Then ;If this is a new access point, use new information
				$ExpLastHistID = $HISTID
				$ExpFirstHistID = -1
				$ExpGpsID = $NewGpsId
				$ExpLastDateTime = $New_DateTime
				$ExpFirstDateTime = -1
			Else ;If this is not a new check if this information is newer or older
				Local $HistMatchArray, $iRows, $iColumns, $iRval
				$query = "SELECT Date1, Time1 FROM Hist WHERE HistID = '" & $Found_LastHistID & "' LIMIT 1"
				$iRval = _SQLite_GetTable2d($DBhndl, $query, $HistMatchArray, $iRows, $iColumns)
				If _CompareDate($HistMatchArray[1][0] & ' ' & $HistMatchArray[1][1], $New_Date & ' ' & $New_Time) = 1 Then
					$ExpLastHistID = $Found_LastHistID
					$ExpGpsID = $Found_LastGpsID
					$ExpLastDateTime = $HistMatchArray[1][0] & ' ' & $HistMatchArray[1][1]
				Else
					$ExpLastHistID = $HISTID
					$ExpGpsID = $NewGpsId
					$ExpLastDateTime = $New_DateTime
				EndIf
				Local $HistMatchArray, $iRows, $iColumns, $iRval
				$query = "SELECT Date1, Time1 FROM Hist WHERE HistID = '" & $Found_FirstHistID & "' LIMIT 1"
				$iRval = _SQLite_GetTable2d($DBhndl, $query, $HistMatchArray, $iRows, $iColumns)
				If _CompareDate($HistMatchArray[1][0] & ' ' & $HistMatchArray[1][1], $New_Date & ' ' & $New_Time) = 2 Then
					$ExpFirstDateTime = -1
					$ExpFirstHistID = -1
				Else
					$ExpFirstDateTime = $New_Date & ' ' & $New_Time
					$ExpFirstHistID = $HISTID
				EndIf
			EndIf
			;Set Highest GPS History ID
			If $New_Lat <> 'N 0000.0000' And $New_Lon <> 'E 0000.0000' Then ;If new latitude and longitude are valid
				If $Found_HighGpsHistId = 0 Then ;If old HighGpsHistId is blank then use the new Hist ID
					$DBLat = $New_Lat
					$DBLon = $New_Lon
					$DBHighGpsHistId = $HISTID
				Else;If old HighGpsHistId has a postion, check if the new posion has a higher number of satalites/higher signal
					;Get Old GpsID and Signal
					Local $HistMatchArray, $iRows, $iColumns, $iRval
					$query = "SELECT GpsID, Signal FROM HIST WHERE HistID = '" & $Found_HighGpsHistId & "' LIMIT 1"
					$iRval = _SQLite_GetTable2d($DBhndl, $query, $HistMatchArray, $iRows, $iColumns)
					$Found_GpsID = $HistMatchArray[1][0]
					$Found_Sig = $HistMatchArray[1][1] - 0 ;For some reason a " - 0' was needed here or the signals would not compair properly
					;Get Old Latititude, Logitude and Number of Satalites from Old GPS ID
					Local $GpsMatchArray, $iRows, $iColumns, $iRval
					$query = "SELECT Latitude, Longitude, NumOfSats FROM GPS WHERE GpsID = '" & $Found_GpsID & "'"
					$iRval = _SQLite_GetTable2d($DBhndl, $query, $GpsMatchArray, $iRows, $iColumns)
					$Found_Lat = $GpsMatchArray[1][0]
					$Found_Lon = $GpsMatchArray[1][1]
					$Found_NumSat = $GpsMatchArray[1][2]
					If $SIG > $Found_Sig Then ;If the new signal is greater or eqaul to the old signal
						$DBHighGpsHistId = $HISTID
						$DBLat = $New_Lat
						$DBLon = $New_Lon
					ElseIf $SIG = $Found_Sig Then ;If the number of satalites are equal, use the position with the higher signal
						If $New_NumSat > $Found_NumSat Then
							$DBHighGpsHistId = $HISTID
							$DBLat = $New_Lat
							$DBLon = $New_Lon
						Else
							$DBHighGpsHistId = $Found_HighGpsHistId
							$DBLat = -1
							$DBLon = -1
						EndIf
					Else ;If the Old Number of satalites is greater than the new, use the old position
						$DBHighGpsHistId = $Found_HighGpsHistId
						$DBLat = -1
						$DBLon = -1
					EndIf
				EndIf
			Else ;If new lat and lon are not valid, use the old position and do not update lat and lon
				$DBHighGpsHistId = $Found_HighGpsHistId
				$DBLat = -1
				$DBLon = -1
			EndIf
			;If HighGpsHistID is different from the origional, update it
			If $DBHighGpsHistId <> $Found_HighGpsHistId Then
				$query = "UPDATE AP SET HighGpsHistId = '" & $DBHighGpsHistId & "' WHERE ApID = '" & $Found_APID & "'"
				_SQLite_Exec($DBhndl, $query)
			EndIf
			;If High Signal has changed, update it
			If $SIG > $Found_HighSignal Then
				$ExpHighSig = $SIG
			Else
				$ExpHighSig = $Found_HighSignal
			EndIf
			;If High Signal has changed, update it
			If $RSSI > $Found_HighRSSI Then
				$ExpHighRSSI = $RSSI
			Else
				$ExpHighRSSI = $Found_HighRSSI
			EndIf
			;Update AP in DB. Set Active, LastGpsID, and LastHistID
			$query = "UPDATE AP SET Active=" & $AP_StatusNum & ", LastGpsID=" & $ExpGpsID & ", LastHistId=" & $ExpLastHistID & ",Signal=" & $AP_DisplaySig & ",HighSignal=" & $ExpHighSig & ",RSSI=" & $AP_DisplayRSSI & ",HighRSSI=" & $ExpHighRSSI & " WHERE ApId=" & $Found_APID
			_SQLite_Exec($DBhndl, $query)
			;Update AP in DB. Set FirstHistID
			If $ExpFirstHistID <> -1 Then
				$query = "UPDATE AP SET FirstHistId = '" & $ExpFirstHistID & "' WHERE ApId = '" & $Found_APID & "'"
				_SQLite_Exec($DBhndl, $query)
			EndIf
			;Add new history ID
			$query = "INSERT INTO Hist(HistID,ApID,GpsID,FileID,Signal,RSSI,Date1,Time1) VALUES ('" & $HISTID & "','" & $Found_APID & "','" & $NewGpsId & "','" & $FILE_ID & "','" & $SIG & "','" & $RSSI & "','" & $New_Date & "','" & $New_Time & "');"
			_SQLite_Exec($DBhndl, $query)
		EndIf
	EndIf
	Return ($NewApFound)
EndFunc   ;==>_AddApData

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

Func _Format_GPS_All_to_DMM($gps);converts dd.ddddddd, 'dd� mm' ss", or ddmm.mmmm to ddmm.mmmm
	;All GPS Formats to ddmm.mmmm
	$return = '0.0000'
	$splitlatlon1 = StringSplit($gps, " ");Split N,S,E,W from data
	If $splitlatlon1[0] = 2 Then
		$splitlatlon2 = StringSplit($splitlatlon1[2], ".")
		If StringLen($splitlatlon2[2]) = 4 Then ;ddmm.mmmm to ddmm.mmmm
			$return = $splitlatlon1[1] & ' ' & StringFormat('%0.4f', $splitlatlon1[2])
		ElseIf StringLen($splitlatlon2[2]) = 7 Then ; dd.dddd to ddmm.mmmm
			$DD = $splitlatlon2[1] * 100
			$MM = ('.' & $splitlatlon2[2]) * 60 ;multiply remaining decimal by 60 to get mm.mmmm
			$return = $splitlatlon1[1] & ' ' & StringFormat('%0.4f', $DD + $MM);Format data properly (ex. N ddmm.mmmm)
		EndIf
	ElseIf $splitlatlon1[0] = 4 Then; ddmmss to ddmm.mmmm
		$DD = StringTrimRight($splitlatlon1[2], 1) * 100
		$MM = StringTrimRight($splitlatlon1[3], 1) + (StringTrimRight($splitlatlon1[4], 1) / 60)
		$return = $splitlatlon1[1] & ' ' & StringFormat('%0.4f', $DD + $MM)
	EndIf
	Return ($return)
EndFunc   ;==>_Format_GPS_All_to_DMM

Func _SignalPercentToDb($InSig);Estimated value
	$dBm = ((($dBmMaxSignal - $dBmDissociationSignal) * $InSig) - (20 * $dBmMaxSignal) + (100 * $dBmDissociationSignal)) / 80
	Return (Round($dBm))
EndFunc   ;==>_SignalPercentToDb

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

Func _WifiDBGeonames($lat, $lon)
	Local $aResult[6]
	Local $CountryName, $CountryName, $AdminName, $AdminCode, $AdminName2
	$url = 'http://192.168.1.27/wifidb/api/geonames.php?lat=' & $lat & '&long=' & $lon
	ConsoleWrite($url & @CRLF)
	$webpagesource = _INetGetSource($url, 'True')
	If StringInStr($webpagesource, "|") Then
		$GeoInfoSplit = StringSplit($webpagesource, "|")
		$aResult[1] = $GeoInfoSplit[1];$GL_CountryCode
		$aResult[2] = $GeoInfoSplit[2];$GL_CountryName
		$aResult[3] = $GeoInfoSplit[3];$GL_AdminCode
		$aResult[4] = $GeoInfoSplit[4];$GL_AdminName
		$aResult[5] = $GeoInfoSplit[5];$GL_Admin2Name
	EndIf
	Return($aResult)
EndFunc

Func _SetUpDbTables($dbfile)
	_SQLite_Exec($dbfile, "pragma synchronous=0");Speed vs Data security. Speed Wins for now.
	_SQLite_Exec($dbfile, "CREATE TABLE AP (ApID,ListRow,Active,BSSID,SSID,CHAN,AUTH,ENCR,SECTYPE,NETTYPE,RADTYPE,BTX,OTX,HighGpsHistId,LastGpsID,FirstHistID,LastHistID,MANU,LABEL,Signal,HighSignal,RSSI,HighRSSI,CountryCode,CountryName,AdminCode,AdminName,Admin2Name)")
	_SQLite_Exec($dbfile, "CREATE TABLE GPS (GPSID,Latitude,Longitude,NumOfSats,HorDilPitch,Alt,Geo,SpeedInMPH,SpeedInKmH,TrackAngle,Date1,Time1)")
	_SQLite_Exec($dbfile, "CREATE TABLE Hist (HistID,ApID,GpsID,FileID,Signal,RSSI,Date1,Time1)")
	_SQLite_Exec($dbfile, "CREATE TABLE LoadedFiles (FileID,File,MD5)")
EndFunc   ;==>_SetUpDbTables

Func _GetDbValues($dbfile)
	;Get Counts
	Local $aRow
	$query = "Select COUNT(ApID) FROM AP"
	_SQLite_QuerySingleRow($dbfile, $query, $aRow)
	$APID = $aRow[0]
	ConsoleWrite('$APID:' & $APID & @CRLF)
	Local $aRow
	$query = "Select COUNT(GPSID) FROM GPS"
	_SQLite_QuerySingleRow($dbfile, $query, $aRow)
	$GPS_ID = $aRow[0]
	ConsoleWrite('$GPS_ID:' & $GPS_ID & @CRLF)
	Local $aRow
	$query = "Select COUNT(HistID) FROM Hist"
	_SQLite_QuerySingleRow($dbfile, $query, $aRow)
	$HISTID = $aRow[0]
	ConsoleWrite('$HISTID:' & $HISTID & @CRLF)
	Local $aRow
	$query = "Select COUNT(FileID) FROM LoadedFiles"
	_SQLite_QuerySingleRow($dbfile, $query, $aRow)
	$FILE_ID = $aRow[0]
	ConsoleWrite('$FILE_ID:' & $FILE_ID & @CRLF)
EndFunc

Func _Format_GPS_DMM($gps)
	$return = '0000.0000'
	$splitlatlon1 = StringSplit($gps, " ");Split N,S,E,W from data
	If $splitlatlon1[0] = 2 Then
		$splitlatlon2 = StringSplit(StringFormat("%0.4f", $splitlatlon1[2]), ".");Split dd from data
		$return = $splitlatlon1[1] & ' ' & StringFormat("%04i", $splitlatlon2[1]) & '.' & $splitlatlon2[2];set return
	EndIf
	Return ($return)
EndFunc   ;==>_Format_GPS_DMM

 #cs
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
				Local $PName, $PDesc, $PStyle, $PLat, $Plon, $PCountryCode, $PCountryName, $PAreaCode, $PAreaName, $PArea2Name
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
									$LocationArr = _WifiDBGeonames($PLat, $Plon)
									$PCountryCode = $LocationArr[1]
									$PCountryName = $LocationArr[2]
									$PAreaCode = $LocationArr[3]
									$PAreaName = $LocationArr[4]
									$PArea2Name = $LocationArr[5]
									If $PCountryCode <> "" Or $PCountryName <> "" Or $PAreaCode <> "" Or $PAreaName <> "" Or $PArea2Name <> "" Then ExitLoop
								Next
								ConsoleWrite($PCountryCode &  ' - ' & $PCountryName &  ' - ' & $PAreaName & @CRLF)
								;Sleep($RequestSleepTime);sleep because google returns results better
							EndIf
						Next
					EndIf
				Next
				If $PName <> "" Or $PCountryCode <> "" Or $PCountryName <> "" Or $PAreaName <> "" Or $PDesc <> "" Then
					ConsoleWrite('"' & $PName  & '" - "' & $PCountryCode & '" - "' & $PCountryName & '" - "' & $PAreaCode & '" - "' & $PAreaName & '" - "' & $PArea2Name & '" - "' & $PStyle & '" - "' & $PLat & '" - "' & $Plon & '" - "' & $PDesc & '"' & @CRLF)
					$query = "INSERT INTO KMLDATA(Name,Desc,Style,Latitude,Longitude,CountryCode,CountryName,AreaCode,AreaName,Area2Name) VALUES ('" & $PName & "','" & $PDesc & "','" & $PStyle & "','" & $PLat & "','" & $Plon & "','" & $PCountryCode & "','" & $PCountryName & "','" & $PAreaCode & "','" & $PAreaName & "','" & $PArea2Name & "');"
					_SQLite_Exec($DBhndl, $query)
				EndIf
			EndIf
		Next
	EndIf
EndFunc

#ce