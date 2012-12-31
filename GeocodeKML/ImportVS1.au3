;#RequireAdmin
;#include "UDFs\_XMLDomWrapper.au3"
#include "UDFs\FileListToArray3.au3"
#include <Array.au3>
#include <INet.au3>
#include <SQLite.au3>
Dim $APID, $GPS_ID
Dim $RetryAttempts = 1 ;Number of times to retry getting location
Dim $DBhndl
Dim $TmpDir = @ScriptDir & '\temp\'
$ldatetimestamp = StringFormat("%04i", @YEAR) & '-' & StringFormat("%02i", @MON) & '-' & StringFormat("%02i", @MDAY) & ' ' & @HOUR & '-' & @MIN & '-' & @SEC
$DB = $TmpDir & 'VS1_Import_' & $ldatetimestamp & '.SDB'
ConsoleWrite($DB & @CRLF)
_SetUpDbTables($DB)
_SearchVistumblerFiles()


Func _SearchVistumblerFiles()
   $VistumblerFilesFolder = FileSelectFolder ("Select folder that contains vistumbler files", "")
   If @error=1 Then
	  MsgBox(0, "Error", "No folder selected, exiting")
	  Exit
   Else
	  $VistumblerFiles = _FileListToArray3($VistumblerFilesFolder, "*.VS1", 1, 1, 1)
	  _ArrayDisplay($VistumblerFiles)
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
					 #cs
					$query = "SELECT OldGpsID FROM TempGpsIDMatchTabel WHERE OldGpsID=" & $LoadGID
					$TempGidMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
					$FoundTempGidMatch = UBound($TempGidMatchArray) - 1
					If $FoundTempGidMatch = 0 Then
						$query = "SELECT GPSID FROM GPS WHERE Latitude = '" & $LoadLat & "' And Longitude = '" & $LoadLon & "' And NumOfSats = '" & $LoadSat & "' And Date1 = '" & $LoadDate & "' And Time1 = '" & $LoadTime & "'"
						$GpsMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
						$FoundGpsMatch = UBound($GpsMatchArray) - 1
						If $FoundGpsMatch = 0 Then
							$AddGID += 1
							$GPS_ID += 1
							_AddRecord($VistumblerDB, "GPS", $DB_OBJ, $GPS_ID & '|' & $LoadLat & '|' & $LoadLon & '|' & $LoadSat & '|' & $LoadHorDilPitch & '|' & $LoadAlt & '|' & $LoadGeo & '|' & $LoadSpeedKmh & '|' & $LoadSpeedMPH & '|' & $LoadTrackAngle & '|' & $LoadDate & '|' & $LoadTime)
							_AddRecord($VistumblerDB, "TempGpsIDMatchTabel", $DB_OBJ, $LoadGID & '|' & $GPS_ID)
						ElseIf $FoundGpsMatch = 1 Then
							$NewGpsId = $GpsMatchArray[1][1]
							_AddRecord($VistumblerDB, "TempGpsIDMatchTabel", $DB_OBJ, $LoadGID & '|' & $NewGpsId)
						EndIf
					ElseIf $FoundTempGidMatch = 1 Then
						$query = "SELECT GPSID FROM GPS WHERE Latitude = '" & $LoadLat & "' And Longitude = '" & $LoadLon & "' And NumOfSats = '" & $LoadSat & "' And Date1 = '" & $LoadDate & "' And Time1 = '" & $LoadTime & "'"
						$GpsMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
						$FoundGpsMatch = UBound($GpsMatchArray) - 1
						If $FoundGpsMatch = 0 Then
							$AddGID += 1
							$GPS_ID += 1
							_AddRecord($VistumblerDB, "GPS", $DB_OBJ, $GPS_ID & '|' & $LoadLat & '|' & $LoadLon & '|' & $LoadSat & '|' & $LoadHorDilPitch & '|' & $LoadAlt & '|' & $LoadGeo & '|' & $LoadSpeedKmh & '|' & $LoadSpeedMPH & '|' & $LoadTrackAngle & '|' & $LoadDate & '|' & $LoadTime)
							$query = "UPDATE TempGpsIDMatchTabel SET NewGpsID=" & $GPS_ID & " WHERE OldGpsID=" & $LoadGID
							_ExecuteMDB($VistumblerDB, $DB_OBJ, $query)
						ElseIf $FoundGpsMatch = 1 Then
							$NewGpsId = $GpsMatchArray[1][1]
							$query = "UPDATE TempGpsIDMatchTabel SET NewGpsID=" & $NewGpsId & " WHERE OldGpsID=" & $LoadGID
							_ExecuteMDB($VistumblerDB, $DB_OBJ, $query)
						EndIf
				  EndIf
				  #ce
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
							$query = "SELECT NewGpsID FROM TempGpsIDMatchTabel WHERE OldGpsID=" & $ImpGID
							$TempGidMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
							$TempGidMatchArrayMatch = UBound($TempGidMatchArray) - 1
							If $TempGidMatchArrayMatch <> 0 Then
								$NewGID = $TempGidMatchArray[1][1]
								;Add AP Info to DB, Listview, and Treeview
								$NewApAdded = _AddApData(0, $NewGID, $BSSID, $SSID, $Channel, $Authentication, $Encryption, $NetworkType, $RadioType, $BasicTransferRates, $OtherTransferRates, $ImpSig, $ImpRSSI)
								If $NewApAdded <> 0 Then $AddAP += 1
							EndIf
						EndIf
						$closebtn = _GUICtrlButton_GetState($NsCancel)
						If BitAND($closebtn, $BST_PUSHED) = $BST_PUSHED Then ExitLoop
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
							$query = "SELECT NewGpsID FROM TempGpsIDMatchTabel WHERE OldGpsID=" & $ImpGID
							$TempGidMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
							$TempGidMatchArrayMatch = UBound($TempGidMatchArray) - 1
							If $TempGidMatchArrayMatch <> 0 Then
								$NewGID = $TempGidMatchArray[1][1]
								;Add AP Info to DB, Listview, and Treeview
								$NewApAdded = _AddApData(0, $NewGID, $BSSID, $SSID, $Channel, $Authentication, $Encryption, $NetworkType, $RadioType, $BasicTransferRates, $OtherTransferRates, $ImpSig, $ImpRSSI)
								If $NewApAdded <> 0 Then $AddAP += 1
							EndIf
						EndIf
						$closebtn = _GUICtrlButton_GetState($NsCancel)
						If BitAND($closebtn, $BST_PUSHED) = $BST_PUSHED Then ExitLoop
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
					$query = "SELECT GPSID FROM GPS WHERE Latitude = '" & $LoadLatitude & "' And Longitude = '" & $LoadLongitude & "' And Date1 = '" & $LoadFirstActive_Date & "' And Time1 = '" & $LoadFirstActive_Time & "'"
					$GpsMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
					$FoundGpsMatch = UBound($GpsMatchArray) - 1
					If $FoundGpsMatch = 0 Then
						$AddGID += 1
						$GPS_ID += 1
						_AddRecord($VistumblerDB, "GPS", $DB_OBJ, $GPS_ID & '|' & $LoadLatitude & '|' & $LoadLongitude & '|' & $LoadSat & '|0|0|0|0|0|0|' & $LoadFirstActive_Date & '|' & $LoadFirstActive_Time)
						$LoadGID = $GPS_ID
					Else
						$LoadGID = $GpsMatchArray[1][1]
					EndIf
					;Add First AP Info to DB, Listview, and Treeview
					$NewApAdded = _AddApData(0, $LoadGID, $BSSID, $SSID, $Channel, $Authentication, $Encryption, $NetworkType, $RadioType, $BasicTransferRates, $OtherTransferRates, $HighGpsSignal, $RSSI)
					If $NewApAdded <> 0 Then $AddAP += 1
					;Check If Last GPS Information is Already in DB, If it is get the GpsID, If not add it and get its GpsID
					$query = "SELECT GPSID FROM GPS WHERE Latitude = '" & $LoadLatitude & "' And Longitude = '" & $LoadLongitude & "' And Date1 = '" & $LoadLastActive_Date & "' And Time1 = '" & $LoadLastActive_Time & "'"
					$GpsMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
					$FoundGpsMatch = UBound($GpsMatchArray) - 1
					If $FoundGpsMatch = 0 Then
						$AddGID += 1
						$GPS_ID += 1
						_AddRecord($VistumblerDB, "GPS", $DB_OBJ, $GPS_ID & '|' & $LoadLatitude & '|' & $LoadLongitude & '|' & $LoadSat & '|0|0|0|0|0|0|' & $LoadLastActive_Date & '|' & $LoadLastActive_Time)
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

			If TimerDiff($UpdateTimer) > 600 Or ($currentline = $totallines) Then
				$min = (TimerDiff($begintime) / 60000) ;convert from miniseconds to minutes
				$percent = ($currentline / $totallines) * 100
				GUICtrlSetData($progressbar, $percent)
				GUICtrlSetData($percentlabel, $Text_Progress & ': ' & Round($percent, 1))
				GUICtrlSetData($linemin, $Text_LinesMin & ': ' & Round($currentline / $min, 1))
				GUICtrlSetData($newlines, $Text_NewAPs & ': ' & $AddAP & ' - ' & $Text_NewGIDs & ':' & $AddGID)
				GUICtrlSetData($minutes, $Text_Minutes & ': ' & Round($min, 1))
				GUICtrlSetData($linetotal, $Text_LineTotal & ': ' & $currentline & "/" & $totallines)
				GUICtrlSetData($estimatedtime, $Text_EstimatedTimeRemaining & ': ' & Round(($totallines / Round($currentline / $min, 1)) - $min, 1) & "/" & Round($totallines / Round($currentline / $min, 1), 1))
				$UpdateTimer = TimerInit()
			EndIf
			If TimerDiff($MemReleaseTimer) > 10000 Then
				_ReduceMemory()
				$MemReleaseTimer = TimerInit()
			EndIf
			$currentline += 1
			$closebtn = _GUICtrlButton_GetState($NsCancel)
			If BitAND($closebtn, $BST_PUSHED) = $BST_PUSHED Then ExitLoop
		Next
	EndIf
	FileClose($vistumblerfile)
	$query = "DELETE FROM TempGpsIDMatchTable"
	_SQLite_Exec($DBhndl, $query)
	$query = "DROP TempGpsIDMatchTable"
	_SQLite_Exec($DBhndl, $query)
EndFunc   ;==>_ImportVS1

Func _AddApData($New, $NewGpsId, $BSSID, $SSID, $CHAN, $AUTH, $ENCR, $NETTYPE, $RADTYPE, $BTX, $OtX, $SIG, $RSSI)
	;ConsoleWrite("$New:" & $New & " $NewGpsId:" & $NewGpsId & " $BSSID:" & $BSSID & " $SSID:" & $SSID & " $CHAN:" & $CHAN & " $AUTH:" & $AUTH & " $ENCR:" & $ENCR & " $NETTYPE:" & $NETTYPE & " $RADTYPE" & $RADTYPE & " $BTX:" & $BTX & "$OtX:" & $OtX & " $SIG:" & $SIG & " $RSSI:" & $RSSI & @CRLF)
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_AddApData()') ;#Debug Display
	If $New = 1 And $SIG <> 0 Then
		$AP_Status = $Text_Active
		$AP_StatusNum = 1
		$AP_DisplaySig = $SIG
		$AP_DisplayRSSI = $RSSI
	Else
		$AP_Status = $Text_Dead
		$AP_StatusNum = 0
		$AP_DisplaySig = 0
		$AP_DisplayRSSI = -100
	EndIf
	;Get Current GPS/Date/Time Information
	$query = "SELECT TOP 1 Latitude, Longitude, NumOfSats, Date1, Time1 FROM GPS WHERE GpsID = " & $NewGpsId
	$GpsMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
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
		$ApMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
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
			$MANUF = _FindManufacturer($BSSID);Set Manufacturer
			$LABEL = _SetLabels($BSSID)
			;Set HISTID
			If $New_Lat <> 'N 0000.0000' And $New_Lon <> 'E 0000.0000' Then
				$DBHighGpsHistId = $HISTID
			Else
				$DBHighGpsHistId = '0'
			EndIf
			;Add History Information
			_AddRecord($VistumblerDB, "HIST", $DB_OBJ, $HISTID & '|' & $APID & '|' & $NewGpsId & '|' & $SIG & '|' & $RSSI & '|' & $New_Date & '|' & $New_Time)
			;Add AP Data into the AP table
			ReDim $AddApRecordArray[24]
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
			_AddRecord($VistumblerDB, "AP", $DB_OBJ, $AddApRecordArray)

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
				$HistMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
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
				$HistMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
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
					$query = "SELECT GpsID, Signal FROM HIST WHERE HistID=" & $Found_HighGpsHistId
					$HistMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
					$Found_GpsID = $HistMatchArray[1][1]
					$Found_Sig = $HistMatchArray[1][2] - 0 ;For some reason a " - 0' was needed here or the signals would not compair properly
					;Get Old Latititude, Logitude and Number of Satalites from Old GPS ID
					$query = "SELECT Latitude, Longitude, NumOfSats FROM GPS WHERE GpsID=" & $Found_GpsID
					$GpsMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
					$Found_Lat = $GpsMatchArray[1][1]
					$Found_Lon = $GpsMatchArray[1][2]
					$Found_NumSat = $GpsMatchArray[1][3]
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
				$query = "UPDATE AP SET HighGpsHistId=" & $DBHighGpsHistId & " WHERE ApID=" & $Found_APID
				_ExecuteMDB($VistumblerDB, $DB_OBJ, $query)
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
			_ExecuteMDB($VistumblerDB, $DB_OBJ, $query)
			;ConsoleWrite($query & @CRLF)
			;Update AP in DB. Set FirstHistID
			If $ExpFirstHistID <> -1 Then
				$query = "UPDATE AP SET FirstHistId=" & $ExpFirstHistID & " WHERE ApId=" & $Found_APID
				_ExecuteMDB($VistumblerDB, $DB_OBJ, $query)
			EndIf
			;Add new history ID
			_AddRecord($VistumblerDB, "HIST", $DB_OBJ, $HISTID & '|' & $Found_APID & '|' & $NewGpsId & '|' & $SIG & '|' & $RSSI & '|' & $New_Date & '|' & $New_Time)
			EndIf
		EndIf
	EndIf
	Return ($NewApFound)
EndFunc   ;==>_AddApData




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
	_SQLite_Startup()
	$DBhndl = _SQLite_Open($dbfile)
	_SQLite_Exec($DBhndl, "pragma synchronous=0");Speed vs Data security. Speed Wins for now.
	ConsoleWrite(@error & @CRLF)
	_SQLite_Exec($DBhndl, "CREATE TABLE GPS (GPSID,Latitude,Longitude,NumOfSats,HorDilPitch,Alt,Geo,SpeedInMPH,SpeedInKmH,TrackAngle,Date1,Time1)")
	_SQLite_Exec($DBhndl, "CREATE TABLE AP (ApID,ListRow,Active,BSSID,SSID,CHAN,AUTH,ENCR,SECTYPE,NETTYPE,RADTYPE,BTX,OTX,HighGpsHistId,LastGpsID,FirstHistID,LastHistID,MANU,LABEL,Signal,HighSignal,RSSI,HighRSSI,CountryCode,CountryName,AdminCode,AdminName,Admin2Name)")
	_SQLite_Exec($DBhndl, "CREATE TABLE Hist (HistID,ApID,GpsID,Signal,RSSI,Date1,Time1)")
	_SQLite_Exec($DBhndl, "CREATE TABLE LoadedFiles (File,MD5)")

	;Get Counts
	$query = "Select COUNT(ApID) FROM AP"
	_SQLite_QuerySingleRow($DBhndl, $query, $aRow)
	$APID = $aRow[0]
	$query = "Select COUNT(GPSID) FROM GPS"
	_SQLite_QuerySingleRow($DBhndl, $query, $aRow)
	$GPS_ID = $aRow[0]
EndFunc   ;==>_SetUpDbTables

Func _Format_GPS_DMM($gps)
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_Format_GPS_DMM()') ;#Debug Display
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