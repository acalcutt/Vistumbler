#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\..\VistumblerMDB\Icons\icon.ico
#AutoIt3Wrapper_Change2CUI=Y
#AutoIt3Wrapper_Res_requestedExecutionLevel=requireAdministrator
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
;#RequireAdmin
;#include "UDFs\_XMLDomWrapper.au3"
#include "UDFs\FileListToArray3.au3"
#include "UDFs\MD5.au3"
#include "UDFs\AccessCom.au3"
#include <Array.au3>
#include <INet.au3>
 #include <String.au3>

Dim $settings = 'settings.ini'
Dim $SearchWord_None = 'None';IniRead($DefaultLanguagePath, 'SearchWords', 'None', 'None')
Dim $SearchWord_Open = 'Open';IniRead($DefaultLanguagePath, 'SearchWords', 'Open', 'Open')
Dim $SearchWord_Wep = 'WEP';IniRead($DefaultLanguagePath, 'SearchWords', 'WEP', 'WEP')
Dim $dBmMaxSignal = '-30';IniRead($settings, 'Vistumbler', 'dBmMaxSignal', '-30')
Dim $dBmDissociationSignal = '-85';IniRead($settings, 'Vistumbler', 'dBmDissociationSignal', '-85')
Dim $APID, $HISTID, $GPS_ID, $FILE_ID
Dim $RetryAttempts = 1 ;Number of times to retry getting location
Dim $TmpDir = @ScriptDir & '\'
Dim $DB = $TmpDir & 'VS1_Import.mdb'
Dim $filename
Dim $DB_OBJ

Dim $AddApRecordArray[32]

;Get Command Line Options
For $loop = 1 To $CmdLine[0]
	If StringInStr($CmdLine[$loop], '/f') Then
		$filesplit = _StringExplode($CmdLine[$loop], "=" , 1)
		If IsArray($filesplit) Then $filename = $filesplit[1]
	EndIf
	If StringInStr($CmdLine[$loop], '/o') Then
		$outsplit = _StringExplode($CmdLine[$loop], "=" , 1)
		If IsArray($outsplit) Then $DB = $outsplit[1]
	EndIf
Next

;Set Up DB
$ExistingDB = FileExists($DB)
If $ExistingDB = 1 Then ConsoleWrite("! " & $DB & " already exits. Import will use existing file" & @CRLF)
If $ExistingDB = 0 Then ConsoleWrite("+> Creating " & $DB & @CRLF)
If $ExistingDB = 1 Then
	_AccessConnectConn($DB, $DB_OBJ)
	_GetDbValues($DB)
EndIf
If $ExistingDB = 0 Then _SetUpDbTables($DB)
;Import files
If $filename = "" Then $filename = FileSelectFolder ("Select folder that contains vistumbler files", "")

If _IsDirectory($filename) Then
	_SearchVistumblerFiles($filename)
Else
	_LoadVistumblerFile($filename)
EndIf

Func _SearchVistumblerFiles($VistumblerFilesFolder)
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

			ConsoleWrite('File:' & $f & '/' & $VistumblerFiles[0] & ' | File:' & $VistumblerFiles[$f] & @CRLF)
			_LoadVistumblerFile($VistumblerFiles[$f])
		Next
   EndIf
EndFunc

Func _LoadVistumblerFile($loadfile)
	if FileExists($loadfile) Then
		$loadfileMD5 = _MD5ForFile($loadfile)
		ConsoleWrite('MD5:' & $loadfileMD5 & ' | Size:' & Round(FileGetSize ($loadfile)/1024) & 'kB' & @CRLF)
		$query = "SELECT MD5 FROM LoadedFiles WHERE MD5='" & $loadfileMD5 & "'"
		$MD5MatchArray = _RecordSearch($DB, $query, $DB_OBJ)
		$FoundMD5Match = UBound($MD5MatchArray) - 1

		If $FoundMD5Match <> 0 Then
			ConsoleWrite('! File Already Exists '& $loadfile & @CRLF)
		Else
			ConsoleWrite('+> Importing New File ' & $loadfile & @CRLF)
			$FILE_ID += 1
			_ImportVS1($loadfile)
			_AddRecord($DB, "LoadedFiles", $DB_OBJ, $loadfile & '|' & $loadfileMD5)
		EndIf
	EndIf
EndFunc

Func _ImportVS1($VS1file)
	_CreateTable($DB, 'TempGpsIDMatchTabel', $DB_OBJ)
	_CreatMultipleFields($DB, 'TempGpsIDMatchTabel', $DB_OBJ, 'OldGpsID INTEGER|NewGpsID INTEGER')
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
		For $Load = 1 To $totallines
			$linein = FileReadLine($vistumblerfile, $Load);Open Line in file
			If @error = -1 Then ExitLoop
			If StringTrimRight($linein, StringLen($linein) - 1) <> "#" Then
				$loadlist = StringSplit($linein, '|');Split Infomation of AP on line
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

					$query = "SELECT TOP 1 OldGpsID FROM TempGpsIDMatchTabel WHERE OldGpsID=" & $LoadGID
					$TempGidMatchArray = _RecordSearch($DB, $query, $DB_OBJ)
					$FoundTempGidMatch = UBound($TempGidMatchArray) - 1
					If $FoundTempGidMatch = 0 Then
						$query = "SELECT TOP 1 GPSID FROM GPS WHERE Latitude = '" & $LoadLat & "' And Longitude = '" & $LoadLon & "' And NumOfSats = '" & $LoadSat & "' And Date1 = '" & $LoadDate & "' And Time1 = '" & $LoadTime & "'"
						$GpsMatchArray = _RecordSearch($DB, $query, $DB_OBJ)
						$FoundGpsMatch = UBound($GpsMatchArray) - 1
						If $FoundGpsMatch = 0 Then
							$AddGID += 1
							$GPS_ID += 1
							_AddRecord($DB, "GPS", $DB_OBJ, $GPS_ID & '|' & $LoadLat & '|' & $LoadLon & '|' & $LoadSat & '|' & $LoadHorDilPitch & '|' & $LoadAlt & '|' & $LoadGeo & '|' & $LoadSpeedKmh & '|' & $LoadSpeedMPH & '|' & $LoadTrackAngle & '|' & $LoadDate & '|' & $LoadTime)
							_AddRecord($DB, "TempGpsIDMatchTabel", $DB_OBJ, $LoadGID & '|' & $GPS_ID)
						ElseIf $FoundGpsMatch = 1 Then
							$NewGpsId = $GpsMatchArray[1][1]
							_AddRecord($DB, "TempGpsIDMatchTabel", $DB_OBJ, $LoadGID & '|' & $NewGpsId)
						EndIf
					ElseIf $FoundTempGidMatch = 1 Then
						$query = "SELECT TOP 1 GPSID FROM GPS WHERE Latitude = '" & $LoadLat & "' And Longitude = '" & $LoadLon & "' And NumOfSats = '" & $LoadSat & "' And Date1 = '" & $LoadDate & "' And Time1 = '" & $LoadTime & "'"
						$GpsMatchArray = _RecordSearch($DB, $query, $DB_OBJ)
						$FoundGpsMatch = UBound($GpsMatchArray) - 1
						If $FoundGpsMatch = 0 Then
							$AddGID += 1
							$GPS_ID += 1
							_AddRecord($DB, "GPS", $DB_OBJ, $GPS_ID & '|' & $LoadLat & '|' & $LoadLon & '|' & $LoadSat & '|' & $LoadHorDilPitch & '|' & $LoadAlt & '|' & $LoadGeo & '|' & $LoadSpeedKmh & '|' & $LoadSpeedMPH & '|' & $LoadTrackAngle & '|' & $LoadDate & '|' & $LoadTime)
							$query = "UPDATE TempGpsIDMatchTabel SET NewGpsID=" & $GPS_ID & " WHERE OldGpsID=" & $LoadGID
							_ExecuteMDB($DB, $DB_OBJ, $query)
						ElseIf $FoundGpsMatch = 1 Then
							$NewGpsId = $GpsMatchArray[1][1]
							$query = "UPDATE TempGpsIDMatchTabel SET NewGpsID=" & $NewGpsId & " WHERE OldGpsID=" & $LoadGID
							_ExecuteMDB($DB, $DB_OBJ, $query)
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
							$query = "SELECT TOP 1 NewGpsID FROM TempGpsIDMatchTabel WHERE OldGpsID=" & $ImpGID
							$TempGidMatchArray = _RecordSearch($DB, $query, $DB_OBJ)
							$TempGidMatchArrayMatch = UBound($TempGidMatchArray) - 1
							If $TempGidMatchArrayMatch <> 0 Then
								$NewGID = $TempGidMatchArray[1][1]
								;Add AP Info to DB, Listview, and Treeview
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
							$query = "SELECT TOP 1 NewGpsID FROM TempGpsIDMatchTabel WHERE OldGpsID=" & $ImpGID
							$TempGidMatchArray = _RecordSearch($DB, $query, $DB_OBJ)
							$TempGidMatchArrayMatch = UBound($TempGidMatchArray) - 1
							If $TempGidMatchArrayMatch <> 0 Then
								$NewGID = $TempGidMatchArray[1][1]
								;Add AP Info to DB, Listview, and Treeview
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
					$query = "SELECT  TOP 1 GPSID FROM GPS WHERE Latitude = '" & $LoadLatitude & "' And Longitude = '" & $LoadLongitude & "' And Date1 = '" & $LoadFirstActive_Date & "' And Time1 = '" & $LoadFirstActive_Time & "'"
					$GpsMatchArray = _RecordSearch($DB, $query, $DB_OBJ)
					$FoundGpsMatch = UBound($GpsMatchArray) - 1
					If $FoundGpsMatch = 0 Then
						$AddGID += 1
						$GPS_ID += 1
						_AddRecord($DB, "GPS", $DB_OBJ, $GPS_ID & '|' & $LoadLatitude & '|' & $LoadLongitude & '|' & $LoadSat & '|0|0|0|0|0|0|' & $LoadFirstActive_Date & '|' & $LoadFirstActive_Time)
						$LoadGID = $GPS_ID
					Else
						$LoadGID = $GpsMatchArray[1][1]
					EndIf
					;Add First AP Info to DB, Listview, and Treeview
					$NewApAdded = _AddApData(0, $LoadGID, $BSSID, $SSID, $Channel, $Authentication, $Encryption, $NetworkType, $RadioType, $BasicTransferRates, $OtherTransferRates, $HighGpsSignal, $RSSI)
					If $NewApAdded <> 0 Then $AddAP += 1
					;Check If Last GPS Information is Already in DB, If it is get the GpsID, If not add it and get its GpsID
					$query = "SELECT  TOP 1 GPSID FROM GPS WHERE Latitude = '" & $LoadLatitude & "' And Longitude = '" & $LoadLongitude & "' And Date1 = '" & $LoadLastActive_Date & "' And Time1 = '" & $LoadLastActive_Time & "'"
					$GpsMatchArray = _RecordSearch($DB, $query, $DB_OBJ)
					$FoundGpsMatch = UBound($GpsMatchArray) - 1
					If $FoundGpsMatch = 0 Then
						$AddGID += 1
						$GPS_ID += 1
						_AddRecord($DB, "GPS", $DB_OBJ, $GPS_ID & '|' & $LoadLatitude & '|' & $LoadLongitude & '|' & $LoadSat & '|0|0|0|0|0|0|' & $LoadLastActive_Date & '|' & $LoadLastActive_Time)
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

		Next
	EndIf
	FileClose($vistumblerfile)
	$query = "DELETE * FROM TempGpsIDMatchTabel"
	_ExecuteMDB($DB, $DB_OBJ, $query)
	_DropTable($DB, 'TempGpsIDMatchTabel', $DB_OBJ)
EndFunc   ;==>_ImportVS1

Func _AddApData($New, $NewGpsId, $BSSID, $SSID, $CHAN, $AUTH, $ENCR, $NETTYPE, $RADTYPE, $BTX, $OtX, $SIG, $RSSI)
	;ConsoleWrite("$New:" & $New & " $NewGpsId:" & $NewGpsId & " $BSSID:" & $BSSID & " $SSID:" & $SSID & " $CHAN:" & $CHAN & " $AUTH:" & $AUTH & " $ENCR:" & $ENCR & " $NETTYPE:" & $NETTYPE & " $RADTYPE" & $RADTYPE & " $BTX:" & $BTX & "$OtX:" & $OtX & " $SIG:" & $SIG & " $RSSI:" & $RSSI & @CRLF)
	If $New = 1 And $SIG <> 0 Then
		$AP_Status = "Active"
		$AP_StatusNum = 1
		$AP_DisplaySig = $SIG
		$AP_DisplayRSSI = $RSSI
	Else
		$AP_Status = "Dead"
		$AP_StatusNum = 0
		$AP_DisplaySig = 0
		$AP_DisplayRSSI = -100
	EndIf
	;Get Current GPS/Date/Time Information
	$query = "SELECT TOP 1 Latitude, Longitude, NumOfSats, Date1, Time1 FROM GPS WHERE GpsID = " & $NewGpsId
	$GpsMatchArray = _RecordSearch($DB, $query, $DB_OBJ)
	$New_Lat = $GpsMatchArray[1][1]
	$New_Lon = $GpsMatchArray[1][2]
	$New_NumSat = $GpsMatchArray[1][3]
	$New_Date = $GpsMatchArray[1][4]
	$New_Time = $GpsMatchArray[1][5]
	$New_DateTime = $New_Date & ' ' & $New_Time
	$NewApFound = 0
	If $GpsMatchArray <> 0 Then ;If GPS ID Is Found
		;Query AP table for New AP
		$query = "SELECT TOP 1 ApID, ListRow, HighGpsHistId, LastGpsID, FirstHistID, LastHistID, Active, SecType, HighSignal, HighRSSI FROM AP WHERE BSSID = '" & $BSSID & "' And SSID ='" & StringReplace($SSID, "'", "''") & "' And CHAN = " & $CHAN & " And AUTH = '" & $AUTH & "' And ENCR = '" & $ENCR & "' And RADTYPE = '" & $RADTYPE & "'"
		$ApMatchArray = _RecordSearch($DB, $query, $DB_OBJ)
		$FoundApMatch = UBound($ApMatchArray) - 1
		;ConsoleWrite($query & @CRLF)
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
			_AddRecord($DB, "HIST", $DB_OBJ, $HISTID & '|' & $APID & '|' & $NewGpsId & '|' & $SIG & '|' & $RSSI & '|' & $New_Date & '|' & $New_Time)
			;Add AP Data into the AP table
			ReDim $AddApRecordArray[32]
			$AddApRecordArray[0] = 21
			$AddApRecordArray[1] = $APID
			$AddApRecordArray[2] = $ListRow
			$AddApRecordArray[3] = $AP_StatusNum
			$AddApRecordArray[4] = $BSSID
			$AddApRecordArray[5] = $SSID
			$AddApRecordArray[6] = $CHAN
			$AddApRecordArray[7] = $AUTH
			$AddApRecordArray[8] = $ENCR
			$AddApRecordArray[9] = $SecType
			$AddApRecordArray[10] = $NETTYPE
			$AddApRecordArray[11] = $RADTYPE
			$AddApRecordArray[12] = $BTX
			$AddApRecordArray[13] = $OtX
			$AddApRecordArray[14] = $DBHighGpsHistId
			$AddApRecordArray[15] = $NewGpsId
			$AddApRecordArray[16] = $HISTID
			$AddApRecordArray[17] = $HISTID
			$AddApRecordArray[18] = $MANUF
			$AddApRecordArray[19] = $LABEL
			$AddApRecordArray[20] = $AP_DisplaySig
			$AddApRecordArray[21] = $SIG
			$AddApRecordArray[22] = $AP_DisplayRSSI
			$AddApRecordArray[23] = $RSSI
			$AddApRecordArray[24] = "";Geonames CountryCode
			$AddApRecordArray[25] = "";Geonames CountryName
			$AddApRecordArray[26] = "";Geonames AdminCode
			$AddApRecordArray[27] = "";Geonames AdminName
			$AddApRecordArray[28] = "";Geonames Admin2Name
			$AddApRecordArray[29] = "";Geonames Areaname
			$AddApRecordArray[30] = -1;Geonames Accuracy(miles)
			$AddApRecordArray[31] = -1;Geonames Accuracy(km)
			_AddRecord($DB, "AP", $DB_OBJ, $AddApRecordArray)
		ElseIf $FoundApMatch = 1 Then ;If the AP is already in the AP table, update it
			$Found_APID = $ApMatchArray[1][1]
			$Found_ListRow = $ApMatchArray[1][2]
			$Found_HighGpsHistId = $ApMatchArray[1][3]
			$Found_LastGpsID = $ApMatchArray[1][4]
			$Found_FirstHistID = $ApMatchArray[1][5]
			$Found_LastHistID = $ApMatchArray[1][6]
			$Found_Active = $ApMatchArray[1][7]
			$Found_SecType = $ApMatchArray[1][8]
			$Found_HighSignal = Round($ApMatchArray[1][9])
			$Found_HighRSSI = Round($ApMatchArray[1][10])
			$HISTID += 1
			;Set Last Time and First Time
			If $New = 1 Then ;If this is a new access point, use new information
				$ExpLastHistID = $HISTID
				$ExpFirstHistID = -1
				$ExpGpsID = $NewGpsId
				$ExpLastDateTime = $New_DateTime
				$ExpFirstDateTime = -1
			Else ;If this is not a new check if this information is newer or older
				$query = "SELECT TOP 1 Date1, Time1 FROM Hist WHERE HistID=" & $Found_LastHistID
				$HistMatchArray = _RecordSearch($DB, $query, $DB_OBJ)
				If _CompareDate($HistMatchArray[1][1] & ' ' & $HistMatchArray[1][2], $New_Date & ' ' & $New_Time) = 1 Then
					$ExpLastHistID = $Found_LastHistID
					$ExpGpsID = $Found_LastGpsID
					$ExpLastDateTime = $HistMatchArray[1][1] & ' ' & $HistMatchArray[1][2]
				Else
					$ExpLastHistID = $HISTID
					$ExpGpsID = $NewGpsId
					$ExpLastDateTime = $New_DateTime
				EndIf
				$query = "SELECT TOP 1 Date1, Time1 FROM Hist WHERE HistID=" & $Found_FirstHistID
				$HistMatchArray = _RecordSearch($DB, $query, $DB_OBJ)
				If _CompareDate($HistMatchArray[1][1] & ' ' & $HistMatchArray[1][2], $New_Date & ' ' & $New_Time) = 2 Then
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
					$query = "SELECT GpsID, RSSI FROM HIST WHERE HistID=" & $Found_HighGpsHistId
					$HistMatchArray = _RecordSearch($DB, $query, $DB_OBJ)
					$Found_GpsID = $HistMatchArray[1][1]
					$Found_RSSI = $HistMatchArray[1][2]
					;Get Old Latititude, Logitude and Number of Satalites from Old GPS ID
					$query = "SELECT Latitude, Longitude, NumOfSats FROM GPS WHERE GpsID=" & $Found_GpsID
					$GpsMatchArray = _RecordSearch($DB, $query, $DB_OBJ)
					$Found_Lat = $GpsMatchArray[1][1]
					$Found_Lon = $GpsMatchArray[1][2]
					$Found_NumSat = $GpsMatchArray[1][3]
					If $RSSI > $Found_RSSI Then ;If the new RSSI is greater or eqaul to the old RSSI
						$DBHighGpsHistId = $HISTID
						$DBLat = $New_Lat
						$DBLon = $New_Lon
					ElseIf $RSSI = $Found_RSSI Then ;If the RSSIs are equal, use the position with the higher number of sats
						If $New_NumSat > $Found_NumSat Then
							$DBHighGpsHistId = $HISTID
							$DBLat = $New_Lat
							$DBLon = $New_Lon
						Else
							$DBHighGpsHistId = $Found_HighGpsHistId
							$DBLat = -1
							$DBLon = -1
						EndIf
					Else ;If the old RSSI is greater than the new, use the old position
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
				$query = "UPDATE AP SET HighGpsHistId=" & $DBHighGpsHistId & " WHERE ApID=" & $Found_APID
				_ExecuteMDB($DB, $DB_OBJ, $query)
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
			_ExecuteMDB($DB, $DB_OBJ, $query)
			;ConsoleWrite($query & @CRLF)
			;Update AP in DB. Set FirstHistID
			If $ExpFirstHistID <> -1 Then
				$query = "UPDATE AP SET FirstHistId=" & $ExpFirstHistID & " WHERE ApId=" & $Found_APID
				_ExecuteMDB($DB, $DB_OBJ, $query)
			EndIf
			;Add new history ID
			_AddRecord($DB, "HIST", $DB_OBJ, $HISTID & '|' & $Found_APID & '|' & $NewGpsId & '|' & $SIG & '|' & $RSSI & '|' & $New_Date & '|' & $New_Time)

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

Func _SetUpDbTables($dbfile)
	_CreateDB($dbfile)
	_AccessConnectConn($dbfile, $DB_OBJ)
	_CreateTable($dbfile, 'GPS', $DB_OBJ)
	_CreateTable($dbfile, 'AP', $DB_OBJ)
	_CreateTable($dbfile, 'Hist', $DB_OBJ)
	_CreateTable($dbfile, 'TreeviewPos', $DB_OBJ)
	_CreateTable($dbfile, 'LoadedFiles', $DB_OBJ)
	_CreateTable($dbfile, 'CAM', $DB_OBJ)
	_CreatMultipleFields($dbfile, 'GPS', $DB_OBJ, 'GPSID INTEGER|Latitude TEXT(20)|Longitude TEXT(20)|NumOfSats TEXT(2)|HorDilPitch TEXT(255)|Alt TEXT(255)|Geo TEXT(255)|SpeedInMPH TEXT(255)|SpeedInKmH TEXT(255)|TrackAngle TEXT(255)|Date1 TEXT(50)|Time1 TEXT(50)')
	_CreatMultipleFields($dbfile, 'AP', $DB_OBJ, 'ApID INTEGER|ListRow INTEGER|Active INTEGER|BSSID TEXT(20)|SSID TEXT(255)|CHAN INTEGER|AUTH TEXT(20)|ENCR TEXT(20)|SECTYPE INTEGER|NETTYPE TEXT(20)|RADTYPE TEXT(20)|BTX TEXT(100)|OTX TEXT(100)|HighGpsHistId INTEGER|LastGpsID INTEGER|FirstHistID INTEGER|LastHistID INTEGER|MANU TEXT(100)|LABEL TEXT(100)|Signal INTEGER|HighSignal INTEGER|RSSI INTEGER|HighRSSI INTEGER|CountryCode TEXT(100)|CountryName TEXT(100)|AdminCode TEXT(100)|AdminName TEXT(100)|Admin2Name TEXT(100)|AreaName TEXT(100)|GNAmiles FLOAT|GNAkm FLOAT')
	_CreatMultipleFields($dbfile, 'Hist', $DB_OBJ, 'HistID INTEGER|ApID INTEGER|GpsID INTEGER|Signal INTEGER|RSSI INTEGER|Date1 TEXT(50)|Time1 TEXT(50)')
	_CreatMultipleFields($dbfile, 'TreeviewPos', $DB_OBJ, 'ApID INTEGER|RootTree TEXT(255)|SubTreeName TEXT(255)|SubTreePos INTEGER|InfoSubPos INTEGER|SsidPos INTEGER|BssidPos INTEGER|ChanPos INTEGER|NetPos INTEGER|EncrPos INTEGER|RadPos  INTEGER|AuthPos INTEGER|BtxPos INTEGER|OtxPos INTEGER|ManuPos INTEGER|LabPos INTEGER')
	_CreatMultipleFields($dbfile, 'LoadedFiles', $DB_OBJ, 'File TEXT(255)|MD5 TEXT(255)')
	_CreatMultipleFields($dbfile, 'CAM', $DB_OBJ, 'CamID INTEGER|CamGroup TEXT(255)|GpsID INTEGER|CamName TEXT(255)|CamFile TEXT(255)|ImgMD5 TEXT(255)|Date1 TEXT(255)|Time1 TEXT(255)')
EndFunc   ;==>_SetUpDbTables

Func _GetDbValues($dbfile)
	;Get Counts
	$query = "Select COUNT(ApID) FROM AP"
	$ApMatchArray = _RecordSearch($dbfile, $query, $DB_OBJ)
	$APID = $ApMatchArray[1][1]
	ConsoleWrite('$APID:' & $APID & @CRLF)
	$query = "Select COUNT(GpsID) FROM GPS"
	$GpsMatchArray = _RecordSearch($dbfile, $query, $DB_OBJ)
	$GPS_ID = $GpsMatchArray[1][1]
	ConsoleWrite('$GPS_ID:' & $GPS_ID & @CRLF)
	$query = "Select COUNT(HistID) FROM Hist"
	$HistMatchArray = _RecordSearch($dbfile, $query, $DB_OBJ)
	$HISTID = $HistMatchArray[1][1]
	ConsoleWrite('$HISTID:' & $HISTID & @CRLF)
	$query = "Select COUNT(File) FROM LoadedFiles"
	$FileMatchArray = _RecordSearch($dbfile, $query, $DB_OBJ)
	$FILE_ID = $FileMatchArray[1][1]
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

Func _IsDirectory ($sDir)
   If StringInStr (FileGetAttrib ($sDir), "D") Then Return 1
      Return 0
EndFunc ; ==> _IsDirectory