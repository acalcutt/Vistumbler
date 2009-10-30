Opt("GUIOnEventMode", 1);Change to OnEvent mode
;--------------------------------------------------------
;AutoIt Version: v3.3.0.0
$Script_Author = 'Andrew Calcutt'
$Script_Name = 'Mysticache'
$Script_Website = 'http://www.techidiots.net'
$version = 'v2.0 Alpha 1'
$Script_Start_Date = '2009/10/22'
$last_modified = '2009/10/30'
$title = $Script_Name & ' ' & $version & ' - By ' & $Script_Author & ' - ' & $last_modified
;Includes------------------------------------------------
#include <Date.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <GDIPlus.au3>
#include <GuiListView.au3>
#include <File.au3>
#include "UDFs\AccessCom.au3"
#include "UDFs\cfxUDF.au3"
#include "UDFs\CommMG.au3"
#include "UDFs\FileInUse.au3"
;Get Date/Time-------------------------------------------
$dt = StringSplit(_DateTimeUtcConvert(StringFormat("%04i", @YEAR) & '-' & StringFormat("%02i", @MON) & '-' & StringFormat("%02i", @MDAY), @HOUR & ':' & @MIN & ':' & @SEC & '.' & StringFormat("%03i", @MSEC), 1), ' ')
$datestamp = $dt[1]
$timestamp = $dt[2]
$ldatetimestamp = StringFormat("%04i", @YEAR) & '-' & StringFormat("%02i", @MON) & '-' & StringFormat("%02i", @MDAY) & ' ' & @HOUR & '-' & @MIN & '-' & @SEC
;If file is secified, set load file
Dim $Load = ''
For $loop = 1 To $CmdLine[0]
	If StringLower(StringTrimLeft($CmdLine[$loop], StringLen($CmdLine[$loop]) - 4)) = '.vs1' Then $Load = $CmdLine[$loop]
	If StringLower(StringTrimLeft($CmdLine[$loop], StringLen($CmdLine[$loop]) - 4)) = '.vsz' Then $Load = $CmdLine[$loop]
Next
;Variables-----------------------------------------------
Dim $OpenedPort
Dim $WPID = 0
Dim $UseGPS = 0
Dim $TurnOffGPS = 0
Dim $CompassOpen = 0
Dim $GpsDetailsOpen = 0
Dim $DestSet = 0
Dim $Debug = 0
Dim $RefreshLoopTime = 500
Dim $ErrorFlag_sound = 'error.wav'
Dim $GpsDetailsGUI
Dim $GPGGA_Update
Dim $GPRMC_Update
Dim $disconnected_time
Dim $sErr
Dim $NetComm
Dim $DB_OBJ

Dim $StartLat = 'N 0.0000'
Dim $StartLon = 'E 0.0000'
Dim $DestLat = 'N 0.0000'
Dim $DestLon = 'E 0.0000'
Dim $Latitude = 'N 0.0000'
Dim $Longitude = 'E 0.0000'
Dim $Latitude2 = 'N 0.0000'
Dim $Longitude2 = 'E 0.0000'
Dim $NumberOfSatalites = '00'
Dim $HorDilPitch = '0'
Dim $Alt = '0'
Dim $AltS = 'M'
Dim $Geo = '0'
Dim $GeoS = 'M'
Dim $SpeedInKnots = '0'
Dim $SpeedInMPH = '0'
Dim $SpeedInKmH = '0'
Dim $TrackAngle = '0'

Dim $AddWaypoingGuiOpen = 0
Dim $AddWaypoingGui, $Rad_DestGPS_LatLon, $Rad_DestGPS_BrngDist, $GUI_AddName, $GUI_AddNotes, $dLat, $dLon, $dBrng, $dDist, $dWPID, $dListRow
Dim $EditWaypoingGui, $EditWaypoingGuiOpen

Dim $winpos_old, $winpos, $sizes, $sizes_old
Dim $FixTime, $FixTime2, $FixDate, $Quality
Dim $Temp_FixTime, $Temp_FixTime2, $Temp_FixDate, $Temp_Lat, $Temp_Lon, $Temp_Lat2, $Temp_Lon2, $Temp_Quality, $Temp_NumberOfSatalites, $Temp_HorDilPitch, $Temp_Alt, $Temp_AltS, $Temp_Geo, $Temp_GeoS, $Temp_Status, $Temp_SpeedInKnots, $Temp_SpeedInMPH, $Temp_SpeedInKmH, $Temp_TrackAngle
Dim $CompassGraphic, $CompassGUI, $CompassBack, $CompassHeight, $CircleX, $CircleY, $north, $south, $east, $west
Dim $GpsCurrentDataGUI, $GPGGA_Time, $GPGGA_Lat, $GPGGA_Lon, $GPGGA_Quality, $GPGGA_Satalites, $GPGGA_HorDilPitch, $GPGGA_Alt, $GPGGA_Geo, $GPRMC_Time, $GPRMC_Date, $GPRMC_Lat, $GPRMC_Lon, $GPRMC_Status, $GPRMC_SpeedKnots, $GPRMC_SpeedMPH, $GPRMC_SpeedKmh, $GPRMC_TrackAngle

Dim $settings = @ScriptDir & '\Settings.ini'
Dim $DateFormat = StringReplace(StringReplace(IniRead($settings, 'DateFormat', 'DateFormat', RegRead('HKCU\Control Panel\International\', 'sShortDate')), 'MM', 'M'), 'dd', 'd')
Dim $ComPort = IniRead($settings, 'GpsSettings', 'ComPort', '4')
Dim $BAUD = IniRead($settings, 'GpsSettings', 'Baud', '4800')
Dim $PARITY = IniRead($settings, 'GpsSettings', 'Parity', 'N')
Dim $DATABIT = IniRead($settings, 'GpsSettings', 'DataBit', '8')
Dim $STOPBIT = IniRead($settings, 'GpsSettings', 'StopBit', '1')
Dim $GpsType = IniRead($settings, 'GpsSettings', 'GpsType', '2')
Dim $GpsFormat = IniRead($settings, 'GpsSettings', 'GpsFormat', '3')
Dim $GpsTimeout = IniRead($settings, 'GpsSettings', 'GpsTimeout', 30000)

If $GpsType = 0 Then
	$DefGpsInt = "CommMG"
ElseIf $GpsType = 1 Then
	$DefGpsInt = "Netcomm OCX"
ElseIf $GpsType = 2 Then
	$DefGpsInt = "Kernel32"
EndIf

Dim $BackgroundColor = IniRead($settings, 'Colors', 'BackgroundColor', '0x99B4A1')
Dim $ControlBackgroundColor = IniRead($settings, 'Colors', 'ControlBackgroundColor', '0xD7E4C2')
Dim $TextColor = IniRead($settings, 'Colors', 'TextColor', '0x000000')


Dim $RadStartGpsCurPos = IniRead($settings, 'StartGPS', 'Rad_StartGPS_CurrentPos', '4')
Dim $RadStartGpsLatLon = IniRead($settings, 'StartGPS', 'Rad_StartGPS_LatLon', '1')
Dim $DcLat = IniRead($settings, 'StartGPS', 'cLat', '')
Dim $DcLon = IniRead($settings, 'StartGPS', 'cLon', '')

Dim $RadDestGPSLatLon = IniRead($settings, 'DestGPS', 'Rad_DestGPS_LatLon', '1')
Dim $RadDestGPSBrngDist = IniRead($settings, 'DestGPS', 'Rad_DestGPS_BrngDist', '4')
Dim $DdLat = IniRead($settings, 'DestGPS', 'dLat', '')
Dim $DdLon = IniRead($settings, 'DestGPS', 'dLon', '')
Dim $DdBrng = IniRead($settings, 'DestGPS', 'dBrng', '')
Dim $DdDist = IniRead($settings, 'DestGPS', 'dDist', '')

Dim $CompassPosition = IniRead($settings, 'WindowPositions', 'CompassPosition', '')
Dim $GpsDetailsPosition = IniRead($settings, 'WindowPositions', 'GpsDetailsPosition', '')
Dim $SoundDir = @ScriptDir & '\Sounds\'
Dim $ImageDir = @ScriptDir & '\Images\'
Dim $TmpDir = @ScriptDir & '\temp\'
Dim $LanguageDir = @ScriptDir & '\Languages\'
DirCreate($SoundDir)
DirCreate($ImageDir)
DirCreate($TmpDir)
DirCreate($LanguageDir)

Dim $AddDirection = IniRead($settings, 'Vistumbler', 'NewApPosistion', 0)
Dim $DefaultLanguage = IniRead($settings, 'Vistumbler', 'Language', 'English')
Dim $DefaultLanguageFile = IniRead($settings, 'Vistumbler', 'LanguageFile', $DefaultLanguage & '.ini')
Dim $DefaultLanguagePath = $LanguageDir & $DefaultLanguageFile
If FileExists($DefaultLanguagePath) = 0 Then
	$DefaultLanguage = 'English'
	$DefaultLanguageFile = 'English.ini'
	$DefaultLanguagePath = $LanguageDir & $DefaultLanguageFile
EndIf

Dim $Text_File = IniRead($DefaultLanguagePath, 'GuiText', 'File', '&File')
Dim $Text_SaveAsTXT = IniRead($DefaultLanguagePath, 'GuiText', 'SaveAsTXT', 'Save As TXT')
Dim $Text_SaveAsVS1 = IniRead($DefaultLanguagePath, 'GuiText', 'SaveAsVS1', 'Save As VS1')
Dim $Text_SaveAsVSZ = IniRead($DefaultLanguagePath, 'GuiText', 'SaveAsVSZ', 'Save As VSZ')
Dim $Text_ImportFromTXT = IniRead($DefaultLanguagePath, 'GuiText', 'ImportFromTXT', 'Import From TXT / VS1')
Dim $Text_ImportFromVSZ = IniRead($DefaultLanguagePath, 'GuiText', 'ImportFromVSZ', 'Import From VSZ')
Dim $Text_Exit = IniRead($DefaultLanguagePath, 'GuiText', 'Exit', 'E&xit')
Dim $Text_ExitSaveDb = IniRead($DefaultLanguagePath, 'GuiText', 'ExitSaveDb', 'Exit (Save DB)')

Dim $Text_Edit = IniRead($DefaultLanguagePath, 'GuiText', 'Edit', 'E&dit')
Dim $Text_ClearAll = IniRead($DefaultLanguagePath, 'GuiText', 'ClearAll', 'Clear All')
Dim $Text_Cut = IniRead($DefaultLanguagePath, 'GuiText', 'Cut', 'Cut')
Dim $Text_Copy = IniRead($DefaultLanguagePath, 'GuiText', 'Copy', 'Copy')
Dim $Text_Paste = IniRead($DefaultLanguagePath, 'GuiText', 'Paste', 'Paste')
Dim $Text_Delete = IniRead($DefaultLanguagePath, 'GuiText', 'Delete', 'Delete')
Dim $Text_Select = IniRead($DefaultLanguagePath, 'GuiText', 'Select', 'Select')
Dim $Text_SelectAll = IniRead($DefaultLanguagePath, 'GuiText', 'SelectAll', 'Select All')

Dim $Text_RecoverMsg = IniRead($DefaultLanguagePath, 'GuiText', 'RecoverMsg', 'Old DB Found. Would you like to recover it?')
Dim $Text_DeleteSelected = IniRead($DefaultLanguagePath, 'GuiText', 'DeleteSelected', 'Delete Selected')
Dim $Text_RecoverSelected = IniRead($DefaultLanguagePath, 'GuiText', 'RecoverSelected', 'Recover Selected')
Dim $Text_Exit = IniRead($DefaultLanguagePath, 'GuiText', 'Exit', 'E&xit')
Dim $Text_NewSession = IniRead($DefaultLanguagePath, 'GuiText', 'NewSession', 'New Session')
Dim $Text_Size = IniRead($DefaultLanguagePath, 'GuiText', 'Size', 'Size')
Dim $Text_Error = IniRead($DefaultLanguagePath, 'GuiText', 'Error', 'Error')
Dim $Text_NoMdbSelected = IniRead($DefaultLanguagePath, 'GuiText', 'NoMdbSelected', 'No MDB Selected')
Dim $Text_ImportFolder = IniRead($DefaultLanguagePath, 'GuiText', 'ImportFolder', 'Import Folder')

Dim $Text_Options = IniRead($DefaultLanguagePath, 'GuiText', 'Options', '&Options')

Dim $Text_Settings = IniRead($DefaultLanguagePath, 'GuiText', 'Settings', 'S&ettings')

Dim $Text_Export = IniRead($DefaultLanguagePath, 'GuiText', 'Export', 'Ex&port')
Dim $Text_ExportToKML = IniRead($DefaultLanguagePath, 'GuiText', 'ExportToKML', 'Export To KML')
Dim $Text_ExportToGPX = IniRead($DefaultLanguagePath, 'GuiText', 'ExportToGPX', 'Export To GPX')
Dim $Text_ExportToTXT = IniRead($DefaultLanguagePath, 'GuiText', 'ExportToTXT', 'Export To TXT')
Dim $Text_ExportToNS1 = IniRead($DefaultLanguagePath, 'GuiText', 'ExportToNS1', 'Export To NS1')
Dim $Text_ExportToVS1 = IniRead($DefaultLanguagePath, 'GuiText', 'ExportToVS1', 'Export To VS1')
Dim $Text_ExportToCSV = IniRead($DefaultLanguagePath, 'GuiText', 'ExportToCSV', 'Export To CSV')

Dim $Text_UseGPS = IniRead($DefaultLanguagePath, 'GuiText', 'UseGPS', 'Use &GPS')
Dim $Text_StopGPS = IniRead($DefaultLanguagePath, 'GuiText', 'StopGPS', 'Stop &GPS')

Dim $Text_ActualLoopTime = IniRead($DefaultLanguagePath, 'GuiText', 'ActualLoopTime', 'Loop time')
Dim $Text_Longitude = IniRead($DefaultLanguagePath, 'GuiText', 'Longitude', 'Longitude')
Dim $Text_Latitude = IniRead($DefaultLanguagePath, 'GuiText', 'Latitude', 'Latitude')



$MDBfiles = _FileListToArray($TmpDir, '*.MDB', 1);Find all files in the folder that end in .MDB
If IsArray($MDBfiles) Then
	Opt("GUIOnEventMode", 0)
	$FoundMdbFile = 0
	$RecoverMdbGui = GUICreate($Text_RecoverMsg, 461, 210, -1, -1, BitOR($WS_OVERLAPPEDWINDOW, $WS_CLIPSIBLINGS))
	GUISetBkColor($BackgroundColor)
	$Recover_Del = GUICtrlCreateButton($Text_DeleteSelected, 10, 150, 215, 25)
	$Recover_Rec = GUICtrlCreateButton($Text_RecoverSelected, 235, 150, 215, 25)
	$Recover_Exit = GUICtrlCreateButton($Text_Exit, 10, 180, 215, 25)
	$Recover_New = GUICtrlCreateButton($Text_NewSession, 235, 180, 215, 25)
	$Recover_List = GUICtrlCreateListView(StringReplace($Text_File, '&', '') & "|" & $Text_Size, 10, 8, 440, 136, $LVS_REPORT + $LVS_SINGLESEL, $LVS_EX_HEADERDRAGDROP + $LVS_EX_GRIDLINES + $LVS_EX_FULLROWSELECT)
	_GUICtrlListView_SetColumnWidth($Recover_List, 0, 335)
	_GUICtrlListView_SetColumnWidth($Recover_List, 1, 100)
	GUICtrlSetBkColor(-1, $ControlBackgroundColor)
	For $FoundMDB = 1 To $MDBfiles[0]
		$mdbfile = $MDBfiles[$FoundMDB]
		If _FileInUse($TmpDir & $mdbfile) = 0 Then
			$FoundMdbFile = 1
			$mdbsize = (FileGetSize($TmpDir & $mdbfile) / 1024) & 'kb'
			$ListRow = _GUICtrlListView_InsertItem($Recover_List, "", 0)
			_GUICtrlListView_SetItemText($Recover_List, $ListRow, $mdbfile, 0)
			_GUICtrlListView_SetItemText($Recover_List, $ListRow, $mdbsize, 1)
		EndIf
	Next
	If $FoundMdbFile = 0 Then
		$MysticacheDB = $TmpDir & $ldatetimestamp & '.mdb'
		$MysticacheDBName = $ldatetimestamp & '.mdb'
	Else
		GUISetState(@SW_SHOW)
		While 1
			$nMsg = GUIGetMsg()
			Switch $nMsg
				Case $GUI_EVENT_CLOSE
					$MysticacheDB = $TmpDir & $ldatetimestamp & '.mdb'
					$MysticacheDBName = $ldatetimestamp & '.mdb'
					ExitLoop
				Case $Recover_New
					$MysticacheDB = $TmpDir & $ldatetimestamp & '.mdb'
					$MysticacheDBName = $ldatetimestamp & '.mdb'
					ExitLoop
				Case $Recover_Exit
					Exit
				Case $Recover_Rec
					$Selected = _GUICtrlListView_GetNextItem($Recover_List); find what AP is selected in the list. returns -1 is nothing is selected
					If $Selected = '-1' Then
						MsgBox(0, $Text_Error, $Text_NoMdbSelected)
					Else
						$mdbfilename = _GUICtrlListView_GetItemText($Recover_List, $Selected)
						$MysticacheDB = $TmpDir & $mdbfilename
						$MysticacheDBName = $mdbfilename
						ExitLoop
					EndIf
				Case $Recover_Del
					$Selected = _GUICtrlListView_GetNextItem($Recover_List); find what AP is selected in the list. returns -1 is nothing is selected
					If $Selected = '-1' Then
						MsgBox(0, $Text_Error, $Text_NoMdbSelected)
					Else
						$fn = _GUICtrlListView_GetItemText($Recover_List, $Selected)
						$fn_fullpath = $TmpDir & $fn
						FileDelete($fn_fullpath)
						_GUICtrlListView_DeleteItem(GUICtrlGetHandle($Recover_List), $Selected)
					EndIf
			EndSwitch
		WEnd
	EndIf
	GUIDelete($RecoverMdbGui)
	Opt("GUIOnEventMode", 1)
Else
	$MysticacheDB = $TmpDir & $ldatetimestamp & '.mdb'
	$MysticacheDBName = $ldatetimestamp & '.mdb'
EndIf

If FileExists($MysticacheDB) Then
	$Recover = 1
	$WPID = 0
	_AccessConnectConn($MysticacheDB, $DB_OBJ)
	$query = "SELECT GpsID FROM GPS"
	$GpsMatchArray = _RecordSearch($MysticacheDB, $query, $DB_OBJ)
	$GPS_ID = UBound($GpsMatchArray) - 1
Else
	ConsoleWrite($MysticacheDB & @CRLF)
	_SetUpDbTables($MysticacheDB)
EndIf

Dim $column_Line = 0
Dim $column_Name = 1
Dim $column_Notes = 2
Dim $column_Latitude = 3
Dim $column_Longitude = 4
Dim $column_Bearing = 5
Dim $column_Distance = 6

$var = IniReadSection($settings, "Columns")
If @error Then
	$headers = '#|Name|Notes|Latitude|Longitude|Bearing|Distance'
Else
	For $a = 0 To ($var[0][0] - 1)
		For $b = 1 To $var[0][0]
			If $a = $var[$b][1] Then $headers &= IniRead($DefaultLanguagePath, 'Column_Names', $var[$b][0], IniRead($settings, 'Column_Names', $var[$b][0], '')) & '|'
		Next
	Next
EndIf

;-------------------------------------------------------------------------------------------------------------------------------
;                                                       GUI
;-------------------------------------------------------------------------------------------------------------------------------

Dim $title = $Script_Name & ' ' & $version & ' - By ' & $Script_Author & ' - ' & _DateLocalFormat($last_modified) & ' - (' & $MysticacheDBName & ')'
$MysticacheGUI = GUICreate($title, 980, 692, -1, -1, BitOR($WS_OVERLAPPEDWINDOW, $WS_CLIPSIBLINGS))
GUISetBkColor($BackgroundColor)

$a = WinGetPos($MysticacheGUI);Get window current position
Dim $State = IniRead($settings, 'WindowPositions', 'MysticacheState', "Window");Get last window position from the ini file
Dim $Position = IniRead($settings, 'WindowPositions', 'MysticachePosition', $a[0] & ',' & $a[1] & ',' & $a[2] & ',' & $a[3])
$b = StringSplit($Position, ",") ;Split ini posion string

If $State = "Maximized" Then
	WinSetState($title, "", @SW_MAXIMIZE)
Else
	WinMove($title, "", $b[1], $b[2], $b[3], $b[4]);Resize window to ini value
EndIf
;File Menu
$file = GUICtrlCreateMenu($Text_File)
;$NewSession = GUICtrlCreateMenuItem($Text_NewSession, $file)
;$SaveAsTXT = GUICtrlCreateMenuItem($Text_SaveAsTXT, $file)
;$SaveAsDetailedTXT = GUICtrlCreateMenuItem($Text_SaveAsVS1, $file)
;$ExportFromVSZ = GUICtrlCreateMenuItem($Text_SaveAsVSZ, $file)
;$ImportFromTXT = GUICtrlCreateMenuItem($Text_ImportFromTXT, $file)
;$ImportFromVSZ = GUICtrlCreateMenuItem($Text_ImportFromVSZ, $file)
;$ImportFolder = GUICtrlCreateMenuItem($Text_ImportFolder, $file)
$ExitSaveDB = GUICtrlCreateMenuItem($Text_ExitSaveDb, $file)
$ExitMysticache = GUICtrlCreateMenuItem($Text_Exit, $file)
;Edit Menu
$Edit = GUICtrlCreateMenu($Text_Edit)
;$Cut = GUICtrlCreateMenuitem("Cut", $Edit)
;$Copy = GUICtrlCreateMenuItem($Text_Copy, $Edit)
;$Delete = GUICtrlCreateMenuItem("Delete", $Edit)
;$SelectAll = GUICtrlCreateMenuItem("Select All", $Edit)
;$ClearAll = GUICtrlCreateMenuItem($Text_ClearAll, $Edit)
$Options = GUICtrlCreateMenu($Text_Options)


$SettingsMenu = GUICtrlCreateMenu($Text_Settings)
$SetGPS = GUICtrlCreateMenuItem("GPS Settings", $SettingsMenu)


$Export = GUICtrlCreateMenu($Text_Export)
;$ExportTXTMenu = GUICtrlCreateMenu($Text_ExportToTXT, $Export)
;$ExportToTXT = GUICtrlCreateMenuItem("All Waypoints", $ExportTXTMenu)
;$ExportVS1Menu = GUICtrlCreateMenu($Text_ExportToVS1, $Export)
;$ExportToVS1 = GUICtrlCreateMenuItem("All Waypoints", $ExportVS1Menu)
;$ExportCsvMenu = GUICtrlCreateMenu($Text_ExportToCSV, $Export)
;$ExportToCsv = GUICtrlCreateMenuItem("All Waypoints", $ExportCsvMenu)
;$ExportKmlMenu = GUICtrlCreateMenu($Text_ExportToKML, $Export)
;$ExportToKML = GUICtrlCreateMenuItem("All Waypoints", $ExportKmlMenu)
;$CreateApSignalMap = GUICtrlCreateMenuItem("Selected Waypoint", $ExportKmlMenu)
;$ExportGpxMenu = GUICtrlCreateMenu($Text_ExportToGPX, $Export)
;$ExportToGPX = GUICtrlCreateMenuItem("All Waypoints", $ExportGpxMenu)

$Extra = GUICtrlCreateMenu("Extra")
$GpsDetails = GUICtrlCreateMenuItem("Gps Details", $Extra)
$GpsCompass = GUICtrlCreateMenuItem("Compass", $Extra)

$DataChild = GUICreate("", 895, 595, 0, 60, BitOR($WS_CHILD, $WS_TABSTOP), $WS_EX_CONTROLPARENT, $MysticacheGUI)
GUISetBkColor($BackgroundColor)
$ListviewAPs = GUICtrlCreateListView($headers, 260, 5, 725, 585, $LVS_REPORT + $LVS_SINGLESEL, $LVS_EX_HEADERDRAGDROP + $LVS_EX_GRIDLINES + $LVS_EX_FULLROWSELECT)
GUICtrlSetBkColor(-1, $ControlBackgroundColor)
GUISetState()

$ControlChild = GUICreate("", 970, 65, 0, 0, $WS_CHILD, $WS_EX_CONTROLPARENT, $MysticacheGUI) ; Create Child window for controls
GUISetBkColor($BackgroundColor)
$But_UseGPS = GUICtrlCreateButton($Text_UseGPS, 15, 8, 100, 20, 0)
$AddWpButton = GUICtrlCreateButton("Add Waypoint", 15, 35, 100, 20, 0)
$EditWpButton = GUICtrlCreateButton("Edit Waypoint", 120, 35, 100, 20, 0)
$DelWpButton = GUICtrlCreateButton("Delete Waypoint", 230, 35, 100, 20, 0)
$SetDestButton = GUICtrlCreateButton("Use as Destination", 340, 35, 100, 20, 0)

$Grp_StartGPS = GUICtrlCreateGroup("Start GPS Position", 450, 0, 405, 60)
$Rad_StartGPS_CurrentPos = GUICtrlCreateRadio("", 465, 15, 17, 17)
$Lab_Rad_CurrentPos = GUICtrlCreateLabel("Current GPS Position", 485, 17, 350, 17)
If $RadStartGpsCurPos = 1 Then GUICtrlSetState($Rad_StartGPS_CurrentPos, $GUI_CHECKED)
$Rad_StartGPS_LatLon = GUICtrlCreateRadio("", 465, 35, 17, 17)
If $RadStartGpsLatLon = 1 Then GUICtrlSetState($Rad_StartGPS_LatLon, $GUI_CHECKED)
GUICtrlCreateLabel("Latitude:", 485, 37, 45, 17)
$cLat = GUICtrlCreateInput($DcLat, 535, 35, 75, 21)
GUICtrlCreateLabel("Longitude:", 615, 37, 50, 17)
$cLon = GUICtrlCreateInput($DcLon, 670, 35, 75, 21)
$But_GetCurrentGps = GUICtrlCreateButton("Get Current GPS", 755, 35, 90, 21, $WS_GROUP)

;$timediff = GUICtrlCreateLabel($Text_ActualLoopTime & ': 0 ms', 155, 25, 300, 15)
;GUICtrlSetColor(-1, $TextColor)
$Lab_StartGPS = GUICtrlCreateLabel("", 120, 5, 330, 15)
GUICtrlSetColor(-1, $TextColor)
$Lab_DestGPS = GUICtrlCreateLabel("Dest GPS:     Not Set Yet", 120, 20, 330, 15)
GUICtrlSetColor(-1, $TextColor)
;$debugdisplay = GUICtrlCreateLabel('', 765, 10, 200, 15)
;GUICtrlSetColor(-1, $TextColor)
;$msgdisplay = GUICtrlCreateLabel('', 155, 40, 610, 15)
;GUICtrlSetColor(-1, $TextColor)

GUISetState(@SW_SHOW)

GUISwitch($MysticacheGUI)
_SetControlSizes()
GUISetState(@SW_SHOW)

;Button-Events-------------------------------------------
GUISetOnEvent($GUI_EVENT_CLOSE, '_Exit')
;GUISetOnEvent($GUI_EVENT_RESIZED, '_ResetSizes')
;GUISetOnEvent($GUI_EVENT_MINIMIZE, '_ResetSizes')
;GUISetOnEvent($GUI_EVENT_RESTORE, '_ResetSizes')
;GUISetOnEvent($GUI_EVENT_MAXIMIZE, '_ResetSizes')
;Buttons
GUICtrlSetOnEvent($But_UseGPS, '_GpsToggle')
GUICtrlSetOnEvent($AddWpButton, '_AddWaypointGUI')
GUICtrlSetOnEvent($EditWpButton, '_EditWaypointGUI')
GUICtrlSetOnEvent($SetDestButton, '_SetDestination')
;File Menu
;GUICtrlSetOnEvent($NewSession, '_NewSession')
;GUICtrlSetOnEvent($SaveAsTXT, '_ExportData')
;GUICtrlSetOnEvent($SaveAsDetailedTXT, '_ExportDetailedData')
;GUICtrlSetOnEvent($ImportFromTXT, 'LoadList')
;GUICtrlSetOnEvent($ImportFromVSZ, '_ImportVSZ')
;GUICtrlSetOnEvent($ExportFromVSZ, '_ExportVSZ')
;GUICtrlSetOnEvent($ImportFolder, '_LoadFolder')
GUICtrlSetOnEvent($ExitSaveDB, '_ExitSaveDB')
GUICtrlSetOnEvent($ExitMysticache, '_Exit')
;Edit Menu
;GUICtrlSetOnEvent($ClearAll, '_ClearAll')
;GUICtrlSetOnEvent($Copy, '_CopyAP')
;Optons Menu

;Export Menu
;GUICtrlSetOnEvent($ExportToTXT, '_ExportData')
;GUICtrlSetOnEvent($ExportToVS1, '_ExportDetailedData')
;GUICtrlSetOnEvent($ExportToCsv, '_ExportCsvData')
;GUICtrlSetOnEvent($ExportToKML, 'SaveToKML')
;GUICtrlSetOnEvent($CreateApSignalMap, '_KmlSignalMapSelectedAP')
;GUICtrlSetOnEvent($ExportToGPX, '_SaveToGPX')
;Settings Menu
GUICtrlSetOnEvent($SetGPS, '_GPSOptions')
;Extra
GUICtrlSetOnEvent($GpsCompass, '_CompassGUI')
GUICtrlSetOnEvent($GpsDetails, '_OpenGpsDetailsGUI') 
;Other
GUICtrlSetOnEvent($ListviewAPs, '_SortColumnToggle')

;Set Listview Widths
_SetListviewWidths()

;If $Recover = 1 Then _RecoverMDB()

;If $Load <> '' Then AutoLoadList($Load)


While 1
	If $UseGPS = 1 Then _GetGPS()
	If GUICtrlRead($Rad_StartGPS_CurrentPos) = 1 Then
		$StartLat = $Latitude
		$StartLon = $Longitude
		;$StartBrng = $TrackAngle
	ElseIf GUICtrlRead($Rad_StartGPS_LatLon) = 1 Then
		$StartLat = _Format_GPS_All_to_DMM(GUICtrlRead($cLat), "N", "S")
		$StartLon = _Format_GPS_All_to_DMM(GUICtrlRead($cLon), "E", "W")
		;$StartBrng = $cBear
	EndIf
	GUICtrlSetData($Lab_Rad_CurrentPos, "Current GPS Position: Lat: " & _GpsFormat($Latitude) & " Lon: " & _GpsFormat($Longitude))
	GUICtrlSetData($Lab_StartGPS, 'Start GPS:     Latitude: ' & $StartLat & '     Longitude: ' & $StartLon)
	;If $DestSet = 1 Then GUICtrlSetData($Lab_BrngDist, 'Bearing: ' & StringFormat('%0.1f', $DestBrng) & ' degrees     Distance: ' & StringFormat('%0.1f', $DestDist) & ' meters')

	;Compass Window and Drawing
	$DestBrng = _BearingBetweenPoints($StartLat, $StartLon, $DestLat, $DestLon)
	$DestDist = _DistanceBetweenPoints($StartLat, $StartLon, $DestLat, $DestLon)
	ConsoleWrite($StartLat & '-' & $StartLon & '-' & $DestLat & '-' & $DestLon & @CRLF)
	ConsoleWrite($DestBrng & @CRLF)
	_SetCompassSizes()
	If $UseGPS = 1 And GUICtrlRead($Rad_StartGPS_CurrentPos) = 1 Then
		_DrawCompassLine($DestBrng, "0xFFFF3333")
		_DrawCompassLine($TrackAngle, "0xFF000000")
	Else
		If $DestSet = 1 Then _DrawCompassLine($DestBrng, "0xFFFF3333")
	EndIf

	$RoundedDestDist = Round($DestDist)
	If $RoundedDestDist <= 25 Then
		_DrawCompassCircle(90, "0xFF228b22")
	ElseIf $RoundedDestDist <= 50 Then
		_DrawCompassCircle(75, "0xFFadff2f")
	ElseIf $RoundedDestDist <= 100 Then
		_DrawCompassCircle(60, "0xFFffff00")
	ElseIf $RoundedDestDist <= 200 Then
		_DrawCompassCircle(45, "0xFFdaa520")
	ElseIf $RoundedDestDist <= 400 Then
		_DrawCompassCircle(30, "0xFFff4500")
	ElseIf $RoundedDestDist <= 600 Then
		_DrawCompassCircle(15, "0xFFff0000")
	EndIf
	;Check Mysticache Window Position
	_WinMoved()
	_SetControlSizes()
	_UpdateDestBrng()


	If WinActive($CompassGUI) And $CompassOpen = 1 Then
		$c = WinGetPos($CompassGUI)
		If $c[0] & ',' & $c[1] & ',' & $c[2] & ',' & $c[3] <> $CompassPosition Then $CompassPosition = $c[0] & ',' & $c[1] & ',' & $c[2] & ',' & $c[3] ;If the $CompassGUI has moved or resized, set $CompassPosition to current window size
	EndIf

	;Check GPS Details Windows Position
	If WinActive($GpsDetailsGUI) And $GpsDetailsOpen = 1 Then
		$g = WinGetPos($GpsDetailsGUI)
		If $g[0] & ',' & $g[1] & ',' & $g[2] & ',' & $g[3] <> $GpsDetailsPosition Then $GpsDetailsPosition = $g[0] & ',' & $g[1] & ',' & $g[2] & ',' & $g[3] ;If the $GpsDetails has moved or resized, set $GpsDetailsPosition to current window size
	EndIf

	If $TurnOffGPS = 1 Then _TurnOffGPS()
	Sleep($RefreshLoopTime)

WEnd

Func _AddWaypointGUI()
	If $AddWaypoingGuiOpen = 0 Then
		$AddWaypoingGuiOpen = 1
		$AddWaypoingGui = GUICreate("Add Waypoint", 360, 199, -1, -1)
		GUISetBkColor($BackgroundColor)
		GUICtrlCreateLabel("Name:", 15, 16, 35, 17)
		$GUI_AddName = GUICtrlCreateInput("", 56, 16, 281, 21)
		GUICtrlCreateLabel("Notes:", 15, 46, 35, 17)
		$GUI_AddNotes = GUICtrlCreateInput("", 56, 48, 281, 21)

		$Rad_DestGPS_LatLon = GUICtrlCreateRadio("", 16, 88, 17, 17)
		If $RadDestGPSLatLon = 1 Then GUICtrlSetState($Rad_DestGPS_LatLon, $GUI_CHECKED)
		GUICtrlCreateLabel("Latitude:", 40, 91, 45, 17)
		$dLat = GUICtrlCreateInput("", 85, 88, 81, 21)
		GUICtrlCreateLabel("Longitude:", 184, 91, 54, 17)
		$dLon = GUICtrlCreateInput("", 240, 88, 81, 21)
		$Rad_DestGPS_BrngDist = GUICtrlCreateRadio("", 16, 119, 17, 17)
		If $RadDestGPSBrngDist = 1 Then GUICtrlSetState($Rad_DestGPS_BrngDist, $GUI_CHECKED)
		GUICtrlCreateLabel("Bearing:", 40, 122, 43, 17)
		$dBrng = GUICtrlCreateInput("", 85, 119, 81, 21)
		GUICtrlCreateLabel("Distance:", 186, 122, 49, 17)
		$dDist = GUICtrlCreateInput("", 240, 119, 81, 21)
		$But_AddWapoint = GUICtrlCreateButton("Add Waypoint", 88, 158, 81, 25, $WS_GROUP)
		$But_Cancel = GUICtrlCreateButton("Cancel", 189, 158, 81, 25, $WS_GROUP)
		GUISetState(@SW_SHOW)
		GUICtrlSetOnEvent($But_AddWapoint, '_AddWaypoint')
		GUICtrlSetOnEvent($But_Cancel, '_CloseAddWaypointGUI')
	EndIf
EndFunc

Func _CloseAddWaypointGUI()
	GUIDelete($AddWaypoingGui)
	$AddWaypoingGuiOpen = 0
EndFunc

Func _AddWaypoint()
	$WPName = GUICtrlRead($GUI_AddName)
	$WPNotes = GUICtrlRead($GUI_AddNotes)
	$WPBrng = GUICtrlRead($dBrng)
	$WPDist = GUICtrlRead($dDist)
	$WPLat = GUICtrlRead($dLat)
	$WPLon = GUICtrlRead($dLon)
	ConsoleWrite("GUICtrlRead($Rad_DestGPS_LatLon) = " & GUICtrlRead($Rad_DestGPS_LatLon) & ' - GUICtrlRead($Rad_DestGPS_BrngDist) = ' & GUICtrlRead($Rad_DestGPS_BrngDist) & @CRLF)
	If GUICtrlRead($Rad_DestGPS_LatLon) = 1 Then
		$DestLat = _Format_GPS_All_to_DMM($WPLat, "N", "S")
		$DestLon = _Format_GPS_All_to_DMM($WPLon, "E", "W")
	ElseIf GUICtrlRead($Rad_DestGPS_BrngDist) = 1 Then
		$DestLat = _DestLat($StartLat, $WPBrng, $WPDist)
		$DestLon = _DestLon($StartLat, $StartLon, $DestLat, $WPBrng, $WPDist)
	Else
		$DestLat = 'N 0.0000'
		$DestLon = 'E 0.0000'
	EndIf
	ConsoleWrite("$DestLat: " & $DestLat & ' - $DestLon: ' & $DestLon & ' - $StartLat: ' & $StartLat & ' - $StartLon: ' & $StartLon & ' - $WPBrng: ' & $WPBrng & ' - $WPDist: ' & $WPDist & @CRLF)
	$DestBrng = StringFormat('%0.1f', _BearingBetweenPoints($StartLat, $StartLon, $DestLat, $DestLon))
	$DestDist = StringFormat('%0.1f', _DistanceBetweenPoints($StartLat, $StartLon, $DestLat, $DestLon))
	ConsoleWrite("$DestBrng: " & $DestBrng & ' - $DestDist: ' & $DestDist & @CRLF)
	$query = "SELECT TOP 1 WPID FROM WP WHERE Name = '" & $WPName & "' And Notes ='" & $WPNotes & "' And Latitude = '" & $DestLat & "' And Longitude = '" & $DestLon & "'"
	$WpMatchArray = _RecordSearch($MysticacheDB, $query, $DB_OBJ)
	$FoundWpMatch = UBound($WpMatchArray) - 1
	If $FoundWpMatch = 0 Then ;If WP is not found then add it
		$WPID += 1
		;Add APs to top of list
		If $AddDirection = 0 Then
			$query = "UPDATE WP SET ListRow = ListRow + 1 WHERE ListRow <> '-1'"
			_ExecuteMDB($MysticacheDB, $DB_OBJ, $query)
			$DBAddPos = 0
		Else ;Add to bottom
			$DBAddPos = -1
		EndIf
		;Add Into ListView
		$ListRow = _GUICtrlListView_InsertItem($ListviewAPs, $WPID, $DBAddPos)
		_ListViewAdd($ListRow, $WPID, $WPName, $WPNotes, $DestLat, $DestLon, $DestBrng, $DestDist)
		_AddRecord($MysticacheDB, "WP", $DB_OBJ, $WPID & '|' & $ListRow & '|' & $WPName & '|' & $WPNotes & '|' & $DestLat & '|' & $DestLon & '|' & $DestBrng & '|' & $DestDist)

		;_CreatMultipleFields($dbfile, "WP", $DB_OBJ, 'WPID TEXT(255)|ListRow TEXT(255)|Name TEXT(255)|Notes TEXT(255)|Latitude TEXT(255)|Longitude TEXT(3)|Bearing TEXT(20)|Distance TEXT(20)')

	Else
		Msgbox(0, "Error", "This waypoint already exists")
	EndIf
	_CloseAddWaypointGUI()
EndFunc

Func _EditWaypointGUI()
	If $EditWaypoingGuiOpen = 0 Then
		$Selected = _GUICtrlListView_GetNextItem($ListviewAPs); find what AP is selected in the list. returns -1 is nothing is selected
		If $Selected <> -1 Then ;If a access point is selected in the listview, play its signal strenth
			$query = "SELECT WPID, ListRow, Name, Notes, Latitude, Longitude, Bearing, Distance FROM WP WHERE ListRow='" & $Selected & "'"
			$WpMatchArray = _RecordSearch($MysticacheDB, $query, $DB_OBJ)
			$DB_WPID = $WpMatchArray[1][1]
			$DB_ListRow = $WpMatchArray[1][2]
			$DB_Name = $WpMatchArray[1][3]
			$DB_Notes = $WpMatchArray[1][4]
			$DB_Latitude = $WpMatchArray[1][5]
			$DB_Longitude = $WpMatchArray[1][6]
			$DB_Bearing = $WpMatchArray[1][7]
			$DB_Distance = $WpMatchArray[1][8]
			$dWPID = $DB_WPID
			$dListRow = $DB_ListRow
			$EditWaypoingGuiOpen = 1
			$EditWaypoingGui = GUICreate("Edit Waypoint", 360, 199, -1, -1)
			GUISetBkColor($BackgroundColor)
			GUICtrlCreateLabel("Name:", 15, 16, 35, 17)
			$GUI_AddName = GUICtrlCreateInput($DB_Name, 56, 16, 281, 21)
			GUICtrlCreateLabel("Notes:", 15, 46, 35, 17)
			$GUI_AddNotes = GUICtrlCreateInput($DB_Notes, 56, 48, 281, 21)

			$Rad_DestGPS_LatLon = GUICtrlCreateRadio("", 16, 88, 17, 17)
			If $RadDestGPSLatLon = 1 Then GUICtrlSetState($Rad_DestGPS_LatLon, $GUI_CHECKED)
			GUICtrlCreateLabel("Latitude:", 40, 91, 45, 17)
			$dLat = GUICtrlCreateInput($DB_Latitude, 85, 88, 81, 21)
			GUICtrlCreateLabel("Longitude:", 184, 91, 54, 17)
			$dLon = GUICtrlCreateInput($DB_Longitude, 240, 88, 81, 21)
			$Rad_DestGPS_BrngDist = GUICtrlCreateRadio("", 16, 119, 17, 17)
			If $RadDestGPSBrngDist = 1 Then GUICtrlSetState($Rad_DestGPS_BrngDist, $GUI_CHECKED)
			GUICtrlCreateLabel("Bearing:", 40, 122, 43, 17)
			$dBrng = GUICtrlCreateInput($DB_Bearing, 85, 119, 81, 21)
			GUICtrlCreateLabel("Distance:", 186, 122, 49, 17)
			$dDist = GUICtrlCreateInput($DB_Distance, 240, 119, 81, 21)
			$But_AddWapoint = GUICtrlCreateButton("Edit Waypoint", 88, 158, 81, 25, $WS_GROUP)
			$But_Cancel = GUICtrlCreateButton("Cancel", 189, 158, 81, 25, $WS_GROUP)
			GUISetState(@SW_SHOW)
			GUICtrlSetOnEvent($But_AddWapoint, '_EditWaypoint')
			GUICtrlSetOnEvent($But_Cancel, '_CloseEditWaypointGUI')
		EndIf
	EndIf
EndFunc

Func _CloseEditWaypointGUI()
	GUIDelete($EditWaypoingGui)
	$EditWaypoingGuiOpen = 0
EndFunc

Func _EditWaypoint()
	$WPWPID = $dWPID
	$WPListrow = $dListRow
	$WPName = GUICtrlRead($GUI_AddName)
	$WPNotes = GUICtrlRead($GUI_AddNotes)
	$WPBrng = GUICtrlRead($dBrng)
	$WPDist = GUICtrlRead($dDist)
	$WPLat = GUICtrlRead($dLat)
	$WPLon = GUICtrlRead($dLon)
	
	If GUICtrlRead($Rad_DestGPS_LatLon) = 1 Then
		$DestLat = _Format_GPS_All_to_DMM($WPLat, "N", "S")
		$DestLon = _Format_GPS_All_to_DMM($WPLon, "E", "W")
	ElseIf GUICtrlRead($Rad_DestGPS_BrngDist) = 1 Then
		$DestLat = _DestLat($StartLat, $WPBrng, $WPDist)
		$DestLon = _DestLon($StartLat, $StartLon, $DestLat, $WPBrng, $WPDist)
	Else
		$DestLat = 'N 0.0000'
		$DestLon = 'E 0.0000'
	EndIf
	$DestBrng = StringFormat('%0.1f', _BearingBetweenPoints($StartLat, $StartLon, $DestLat, $DestLon))
	$DestDist = StringFormat('%0.1f', _DistanceBetweenPoints($StartLat, $StartLon, $DestLat, $DestLon))
	
	_ListViewAdd($WPListrow, $WPWPID, $WPName, $WPNotes, $DestLat, $DestLon, $DestBrng, $DestDist)
	_AddRecord($MysticacheDB, "WP", $DB_OBJ, $WPWPID & '|' & $WPListrow & '|' & $WPName & '|' & $WPNotes & '|' & $DestLat & '|' & $DestLon & '|' & $DestBrng & '|' & $DestDist)
	
	_CloseEditWaypointGUI()
EndFunc


Func _SetDestination()
	$Selected = _GUICtrlListView_GetNextItem($ListviewAPs); find what AP is selected in the list. returns -1 is nothing is selected
	If $Selected <> -1 Then ;If a access point is selected in the listview, play its signal strenth
		$query = "SELECT Latitude, Longitude FROM WP WHERE ListRow='" & $Selected & "'"
		$WpMatchArray = _RecordSearch($MysticacheDB, $query, $DB_OBJ)
		$DestLat = $WpMatchArray[1][1]
		$DestLon = $WpMatchArray[1][2]
		$DestSet = 1
		GUICtrlSetData($Lab_DestGPS, 'Dest GPS:     Latitude: ' & $DestLat & '     Longitude: ' & $DestLon)
	EndIf
EndFunc   ;==>_SetDestination


Func _UpdateDestBrng()
	$query = "SELECT WPID, ListRow, Latitude, Longitude, Bearing, Distance FROM WP"
	$WpMatchArray = _RecordSearch($MysticacheDB, $query, $DB_OBJ)
	$FoundWpMatch = UBound($WpMatchArray) - 1
	ConsoleWrite("$FoundWpMatch: " & $FoundWpMatch & @CRLF)
	If $FoundWpMatch <> 0 Then ;If WP was found
		For $udb = 1 to $FoundWpMatch
			$DB_WPID = $WpMatchArray[$udb][1]
			$DB_ListRow = $WpMatchArray[$udb][2]
			$DB_Latitude = $WpMatchArray[$udb][3]
			$DB_Longitude = $WpMatchArray[$udb][4]
			$DB_Bearing = $WpMatchArray[$udb][5]
			$DB_Distance = $WpMatchArray[$udb][6]
			ConsoleWrite("$DB_ListRow: " & $DB_ListRow & @CRLF)

			$New_Brng = StringFormat('%0.1f', _BearingBetweenPoints($StartLat, $StartLon, $DB_Latitude, $DB_Longitude))
			$New_Dist = StringFormat('%0.1f', _DistanceBetweenPoints($StartLat, $StartLon, $DB_Latitude, $DB_Longitude))

			If $DB_Bearing <> $New_Brng Then
				$UpdBrng = $New_Brng
				$query = "UPDATE WP SET Bearing='" & $New_Brng & "' WHERE WPID='" & $DB_WPID & "'"
				ConsoleWrite($query & @CRLF)
				_ExecuteMDB($MysticacheDB, $DB_OBJ, $query)
			Else
				$UpdBrng = ''
			EndIf

			If $DB_Distance <> $New_Dist Then
				$UpdDist = $New_Dist
				$query = "UPDATE WP SET Distance='" & $New_Dist & "' WHERE WPID='" & $DB_WPID & "'"
				ConsoleWrite($query & @CRLF)
				_ExecuteMDB($MysticacheDB, $DB_OBJ, $query)
			Else
				$UpdDist = ''
			EndIf
			
			_ListViewAdd($DB_ListRow, '', '', '', '', '', $UpdBrng, $UpdDist)
		Next
	EndIf
EndFunc


Func _ListViewAdd($line, $Add_Line = '', $Add_Name = '', $Add_Notes = '', $Add_Latitude = '', $Add_Longitude = '', $Add_Bearing = '', $Add_Distance = '')
	If $Add_Line <> '' Then _GUICtrlListView_SetItemText($ListviewAPs, $line, $Add_Line, $column_Line)
	If $Add_Name <> '' Then _GUICtrlListView_SetItemText($ListviewAPs, $line, $Add_Name, $column_Name)
	If $Add_Notes <> '' Then _GUICtrlListView_SetItemText($ListviewAPs, $line, $Add_Notes, $column_Notes)
	If $Add_Latitude <> '' Then _GUICtrlListView_SetItemText($ListviewAPs, $line, $Add_Latitude, $column_Latitude)
	If $Add_Longitude <> '' Then _GUICtrlListView_SetItemText($ListviewAPs, $line, $Add_Longitude, $column_Longitude)
	If $Add_Bearing <> '' Then _GUICtrlListView_SetItemText($ListviewAPs, $line, $Add_Bearing, $column_Bearing)
	If $Add_Distance <> '' Then _GUICtrlListView_SetItemText($ListviewAPs, $line, $Add_Distance, $column_Distance)
EndFunc   ;==>_ListViewAdd

Func _SetUpDbTables($dbfile)
	;If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_SetUpDbTables()') ;#Debug Display
	_CreateDB($dbfile)
	_AccessConnectConn($dbfile, $DB_OBJ)
	_CreateTable($dbfile, 'GPS', $DB_OBJ)
	_CreateTable($dbfile, 'WP', $DB_OBJ)
	_CreatMultipleFields($dbfile, 'GPS', $DB_OBJ, 'GPSID TEXT(255)|Latitude TEXT(20)|Longitude TEXT(20)|NumOfSats TEXT(2)|HorDilPitch TEXT(255)|Alt TEXT(255)|Geo TEXT(255)|SpeedInMPH TEXT(255)|SpeedInKmH TEXT(255)|TrackAngle TEXT(255)|Date1 TEXT(50)|Time1 TEXT(50)')
	_CreatMultipleFields($dbfile, 'WP', $DB_OBJ, 'WPID TEXT(255)|ListRow TEXT(255)|Name TEXT(255)|Notes TEXT(255)|Latitude TEXT(255)|Longitude TEXT(255)|Bearing TEXT(255)|Distance TEXT(255)')
EndFunc   ;==>_SetUpDbTables

Func _DateTimeUtcConvert($Date, $time, $ConvertToUTC)
	Local $mon, $d, $y, $h, $m, $s, $ms
	$DateSplit = StringSplit($Date, '-')
	$TimeSplit = StringSplit($time, ':')
	If $DateSplit[0] = 3 And $TimeSplit[0] = 3 Then
		If StringInStr($TimeSplit[3], '.') Then
			$SecMsSplit = StringSplit($TimeSplit[3], '.')
			$s = $SecMsSplit[1]
			$ms = $SecMsSplit[2]
		Else
			$s = $TimeSplit[3]
			$ms = '000'
		EndIf
		$tSystem = _Date_Time_EncodeSystemTime($DateSplit[2], $DateSplit[3], $DateSplit[1], $TimeSplit[1], $TimeSplit[2], $s)
		If $ConvertToUTC = 1 Then
			$rTime = _Date_Time_TzSpecificLocalTimeToSystemTime(DllStructGetPtr($tSystem))
		Else
			$rTime = _Date_Time_SystemTimeToTzSpecificLocalTime(DllStructGetPtr($tSystem))
		EndIf
		$dts1 = StringSplit(_Date_Time_SystemTimeToDateTimeStr($rTime), ' ')
		$dts2 = StringSplit($dts1[1], '/')
		$dts3 = StringSplit($dts1[2], ':')
		$mon = $dts2[1]
		$d = $dts2[2]
		$y = $dts2[3]
		$h = $dts3[1]
		$m = $dts3[2]
		$s = $dts3[3]
		Return ($y & '-' & $mon & '-' & $d & ' ' & $h & ':' & $m & ':' & $s & '.' & $ms)
	Else
		Return ('0000-00-00 00:00:00.000')
	EndIf
EndFunc   ;==>_DateTimeUtcConvert

Func _DateTimeLocalFormat($DateTimeString)
	$dta = StringSplit($DateTimeString, ' ')
	$ds = _DateLocalFormat($dta[1])
	Return ($ds & ' ' & $dta[2])
EndFunc   ;==>_DateTimeLocalFormat

Func _DateLocalFormat($DateString)
	If StringInStr($DateString, '/') Then
		$da = StringSplit($DateString, '/')
		$y = $da[1]
		$m = $da[2]
		$d = $da[3]
		Return (StringReplace(StringReplace(StringReplace($DateFormat, 'M', $m), 'd', $d), 'yyyy', $y))
	ElseIf StringInStr($DateString, '-') Then
		$da = StringSplit($DateString, '-')
		$y = $da[1]
		$m = $da[2]
		$d = $da[3]
		Return (StringReplace(StringReplace(StringReplace(StringReplace($DateFormat, 'M', $m), 'd', $d), 'yyyy', $y), '/', '-'))
	EndIf
EndFunc   ;==>_DateLocalFormat

Func _GpsFormat($gps);Converts ddmm.mmmm to the users set gps format
	If $GpsFormat = 1 Then $return = _Format_GPS_DMM_to_DDD($gps)
	If $GpsFormat = 2 Then $return = _Format_GPS_DMM_to_DMS($gps)
	If $GpsFormat = 3 Then $return = $gps
	Return ($return)
EndFunc   ;==>_GpsFormat

Func _Exit()
	_ExitMysticache()
EndFunc

Func _ExitSaveDB()
	_ExitMysticache(1)
EndFunc   ;==>_Exit

Func _ExitMysticache($SaveDB=0)
	GUISetState(@SW_HIDE, $MysticacheGUI)
	_AccessCloseConn($DB_OBJ)
	_SaveSettings()
	If $SaveDB <> 1 Then FileDelete($MysticacheDB)
	If $UseGPS = 1 Then ;If GPS is active, stop it so the COM port does not stay open
		_TurnOffGPS()
		Exit
	Else
		Exit
	EndIf
EndFunc   ;==>_Exit

Func _GetCurrentGps()
	;GUICtrlSetData($cLat, StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($Latitude), 'S', '-'), 'N', ''), ' ', ''))
	;GUICtrlSetData($cLon, StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($Longitude), 'W', '-'), 'E', ''), ' ', ''))
EndFunc   ;==>_GetCurrentGps

Func _WinMoved();Checks if window has moved. Returns 1 if it has
	$a = WinGetPos($MysticacheGUI)
	$winpos_old = $winpos
	$winpos = $a[0] & $a[1] & $a[2] & $a[3] & WinGetState($title, "")

	If $winpos_old <> $winpos Then
		;Set window state and position
		$winstate = WinGetState($title, "")
		If BitAND($winstate, 32) Then;Set
			$State = "Maximized"
		Else
			$State = "Window"
			$Position = $a[0] & ',' & $a[1] & ',' & $a[2] & ',' & $a[3]
		EndIf
		Return 1 ;Set Flag that window moved
	Else
		Return 0 ;Set Flag that window did not move
	EndIf
EndFunc   ;==>_WinMoved

Func _SaveSettings()

	IniWrite($settings, 'WindowPositions', 'State', $State)
	IniWrite($settings, 'WindowPositions', 'Position', $Position)
	IniWrite($settings, 'WindowPositions', 'CompassPosition', $CompassPosition)
	IniWrite($settings, 'WindowPositions', 'GpsDetailsPosition', $GpsDetailsPosition)

	IniWrite($settings, 'Colors', 'BackgroundColor', $BackgroundColor)
	IniWrite($settings, 'Colors', 'ControlBackgroundColor', $ControlBackgroundColor)
	IniWrite($settings, 'Colors', 'TextColor', $TextColor)

	IniWrite($settings, 'GpsSettings', 'ComPort', $ComPort)
	IniWrite($settings, 'GpsSettings', 'Baud', $BAUD)
	IniWrite($settings, 'GpsSettings', 'Parity', $PARITY)
	IniWrite($settings, 'GpsSettings', 'DataBit', $DATABIT)
	IniWrite($settings, 'GpsSettings', 'StopBit', $STOPBIT)
	IniWrite($settings, 'GpsSettings', 'GpsTimeout', $GpsTimeout)
	IniWrite($settings, 'GpsSettings', 'GpsType', $GpsType)
	IniWrite($settings, 'GpsSettings', 'GpsFormat', $GpsFormat)

	IniWrite($settings, 'StartGPS', 'Rad_StartGPS_CurrentPos', GUICtrlRead($Rad_StartGPS_CurrentPos))
	IniWrite($settings, 'StartGPS', 'Rad_StartGPS_LatLon', GUICtrlRead($Rad_StartGPS_LatLon))
	IniWrite($settings, 'StartGPS', 'cLat', GUICtrlRead($cLat))
	IniWrite($settings, 'StartGPS', 'cLon', GUICtrlRead($cLon))

	;IniWrite($settings, 'DestGPS', 'Rad_DestGPS_LatLon', GUICtrlRead($Rad_DestGPS_LatLon))
	;IniWrite($settings, 'DestGPS', 'Rad_DestGPS_BrngDist', GUICtrlRead($Rad_DestGPS_BrngDist))
	;IniWrite($settings, 'DestGPS', 'dLat', GUICtrlRead($dLat))
	;IniWrite($settings, 'DestGPS', 'dLon', GUICtrlRead($dLon))
	;IniWrite($settings, 'DestGPS', 'dBrng', GUICtrlRead($dBrng))
	;IniWrite($settings, 'DestGPS', 'dDist', GUICtrlRead($dDist))
EndFunc   ;==>_SaveSettings

;-------------------------------------------------------------------------------------------------------------------------------
;                                                       GPS FUNCTIONS
;-------------------------------------------------------------------------------------------------------------------------------

Func _GpsToggle();Turns GPS on or off
	If $UseGPS = 1 Then
		$TurnOffGPS = 1
	Else
		$openport = _OpenComPort($ComPort, $BAUD, $PARITY, $DATABIT, $STOPBIT);Open The GPS COM port
		If $openport = 1 Then
			$UseGPS = 1
			GUICtrlSetData($But_UseGPS, "Stop GPS")
			$GPGGA_Update = TimerInit()
			$GPRMC_Update = TimerInit()
			;GUICtrlSetData($Lab_GpsInfo, "Succesfully Opened GPS")
		Else
			$UseGPS = 0
			;GUICtrlSetData($Lab_GpsInfo, "Error Opening GPS")
			SoundPlay($SoundDir & $ErrorFlag_sound, 0)
		EndIf
	EndIf
EndFunc   ;==>_GpsToggle

Func _TurnOffGPS();Turns off GPS, resets variable\
	$UseGPS = 0
	$TurnOffGPS = 0
	$disconnected_time = -1
	$Latitude = 'N 0.0000'
	$Longitude = 'E 0.0000'
	$Latitude2 = 'N 0.0000'
	$Longitude2 = 'E 0.0000'
	$NumberOfSatalites = '00'
	$HorDilPitch = '0'
	$Alt = '0'
	$AltS = 'M'
	$Geo = '0'
	$GeoS = 'M'
	$SpeedInKnots = '0'
	$SpeedInMPH = '0'
	$SpeedInKmH = '0'
	$TrackAngle = '0'

	_CloseComPort($ComPort) ;Close The GPS COM port
	GUICtrlSetData($But_UseGPS, "Use GPS")
	;GUICtrlSetData($Lab_GpsInfo, "")
EndFunc   ;==>_TurnOffGPS

Func _OpenComPort($CommPort = '8', $sBAUD = '4800', $sPARITY = 'N', $sDataBit = '8', $sStopBit = '1', $sFlow = '0');Open specified COM port
	;ConsoleWrite($GpsType & @CRLF)
	If $GpsType = 0 Then
		If $sPARITY = 'O' Then ;Odd
			$iPar = '1'
		ElseIf $sPARITY = 'E' Then ;Even
			$iPar = '2'
		ElseIf $sPARITY = 'M' Then ;Mark
			$iPar = '3'
		ElseIf $sPARITY = 'S' Then ;Space
			$iPar = '4'
		Else
			$iPar = '0';None
		EndIf
		$OpenedPort = _CommSetPort($CommPort, $sErr, $sBAUD, $sDataBit, $iPar, $sStopBit, $sFlow)
		If $OpenedPort = 1 Then
			Return (1)
		Else
			Return (0)
		EndIf
	ElseIf $GpsType = 1 Then
		$return = 0
		$ComError = 0
		$CommSettings = $sBAUD & ',' & $sPARITY & ',' & $sDataBit & ',' & $sStopBit
		;	Create NETComm.ocx object
		$NetComm = ObjCreate("NETCommOCX.NETComm")
		If IsObj($NetComm) = 0 Then ;If $NetComm is not an object then netcomm ocx is probrably not installed
			MsgBox(0, "Error", "Install Netcomm OCX (http://home.comcast.net/~hardandsoftware/NETCommOCX.htm)")
		Else
			$NetComm.CommPort = $CommPort ;Set port number
			$NetComm.Settings = $CommSettings ;Set port settings
			$NetComm.InputLen = 0 ;reads entire buffer
			If $ComError <> 1 Then
				$NetComm.InputMode = 0 ;reads in text mode
				$NetComm.HandShaking = 3 ;uses both RTS and Xon/Xoff handshaking
				$NetComm.PortOpen = "True"
				$return = 1
			EndIf
		EndIf
		Return ($return)
	ElseIf $GpsType = 2 Then
		If $sPARITY = 'O' Then ;Odd
			$iPar = '1'
		ElseIf $sPARITY = 'E' Then ;Even
			$iPar = '2'
		ElseIf $sPARITY = 'M' Then ;Mark
			$iPar = '3'
		ElseIf $sPARITY = 'S' Then ;Space
			$iPar = '4'
		Else
			$iPar = '0';None
		EndIf
		If $sStopBit = '1' Then
			$iStop = '0'
		ElseIf $sStopBit = '1.5' Then
			$iStop = '1'
		ElseIf $sStopBit = '2' Then
			$iStop = '2'
		EndIf
		$OpenedPort = _OpenComm($CommPort, $sBAUD, $sDataBit, $iPar, $iStop)
		If $OpenedPort = '-1' Then
			Return (0)
		Else
			Return (1)
		EndIf
	EndIf
EndFunc   ;==>_OpenComPort

Func _CloseComPort($CommPort = '8');Closes specified COM port
	;Close the COM Port
	If $GpsType = 0 Then
		_CommClosePort()
	ElseIf $GpsType = 1 Then
		With $NetComm
			.CommPort = $CommPort ;Set port number
			.PortOpen = "False"
		EndWith
	ElseIf $GpsType = 2 Then
		_CloseComm($OpenedPort)
	EndIf
EndFunc   ;==>_CloseComPort

Func _GetGPS(); Recieves data from gps device
	$timeout = TimerInit()
	$return = 1
	$FoundData = 0

	$maxtime = $RefreshLoopTime * 0.8; Set GPS timeout to 80% of the given timout time
	If $maxtime < 800 Then $maxtime = 800;Set GPS timeout to 800 if it is under that

	Dim $Temp_FixTime, $Temp_FixTime2, $Temp_FixDate, $Temp_Lat, $Temp_Lon, $Temp_Lat2, $Temp_Lon2, $Temp_Quality, $Temp_NumberOfSatalites, $Temp_HorDilPitch, $Temp_Alt, $Temp_AltS, $Temp_Geo, $Temp_GeoS, $Temp_Status, $Temp_SpeedInKnots, $Temp_SpeedInMPH, $Temp_SpeedInKmH, $Temp_TrackAngle
	Dim $Temp_Quality = 0, $Temp_Status = "V"

	While 1 ;Loop to extract gps data untill location is found or timout time is reached
		If $UseGPS = 0 Then ExitLoop
		If $GpsType = 0 Then ;Use CommMG
			$dataline = StringStripWS(_CommGetLine(@CR, 500, $maxtime), 8);Read data line from GPS
			If $GpsDetailsOpen = 1 Then GUICtrlSetData($GpsCurrentDataGUI, $dataline);Show data line in "GPS Details" GUI if it is open
			If StringInStr($dataline, '$') And StringInStr($dataline, '*') Then ;Check if string containts start character ($) and checsum character (*). If it does not have them, ignore the data
				$FoundData = 1
				If StringInStr($dataline, "$GPGGA") Then
					_GPGGA($dataline);Split GPGGA data from data string
					$disconnected_time = -1
				ElseIf StringInStr($dataline, "$GPRMC") Then
					_GPRMC($dataline);Split GPRMC data from data string
					$disconnected_time = -1
				EndIf
			EndIf
		ElseIf $GpsType = 1 Then ;Use Netcomm ocx to get data (more stable right now)
			If $NetComm.InBufferCount Then
				$Buffer = $NetComm.InBufferCount
				If $Buffer > 85 And TimerDiff($timeout) < $maxtime Then
					$inputdata = $NetComm.inputdata
					If StringInStr($inputdata, '$') And StringInStr($inputdata, '*') Then ;Check if string containts start character ($) and checsum character (*). If it does not have them, ignore the data
						$FoundData = 1
						$gps = StringSplit($inputdata, @CR);Split data string by CR and put data into the $gps array
						For $readloop = 1 To $gps[0];go through array
							$gpsline = StringStripWS($gps[$readloop], 3)
							If $GpsDetailsOpen = 1 Then GUICtrlSetData($GpsCurrentDataGUI, $gpsline);Show data line in "GPS Details" GUI if it is open
							If StringInStr($gpsline, '$') And StringInStr($gpsline, '*') Then ;Check if string containts start character ($) and checsum character (*). If it does not have them, ignore the data
								If StringInStr($gpsline, "$GPGGA") Then
									_GPGGA($gpsline);Split GPGGA data from data string
								ElseIf StringInStr($gpsline, "$GPRMC") Then
									_GPRMC($gpsline);Split GPRMC data from data string
								EndIf
							EndIf
							If BitOR($Temp_Quality = 1, $Temp_Quality = 2) = 1 And BitOR($Temp_Status = "A", $GpsDetailsOpen <> 1) Then ExitLoop;If $Temp_Quality = 1 (GPS has a fix) And, If the details window is open, $Temp_Status = "A" (Active data, not Void)
							If TimerDiff($timeout) > $maxtime Then ExitLoop;If time is over timeout period, exitloop
						Next
					EndIf
				EndIf
			EndIf
		ElseIf $GpsType = 2 Then ;Use Kernel32
			$gstring = StringStripWS(_rxwait($OpenedPort, '1000', $maxtime), 8);Read data line from GPS
			$dataline = $gstring; & $LastGpsString
			$LastGpsString = $gstring
			If StringInStr($dataline, '$') And StringInStr($dataline, '*') Then
				$FoundData = 1
				$dlsplit = StringSplit($dataline, '$')
				For $gda = 1 To $dlsplit[0]
					If $GpsDetailsOpen = 1 Then GUICtrlSetData($GpsCurrentDataGUI, $dlsplit[$gda]);Show data line in "GPS Details" GUI if it is open
					If StringInStr($dlsplit[$gda], '*') Then ;Check if string containts start character ($) and checsum character (*). If it does not have them, ignore the data

						If StringInStr($dlsplit[$gda], "GPGGA") Then
							_GPGGA($dlsplit[$gda]);Split GPGGA data from data string
							$disconnected_time = -1
						ElseIf StringInStr($dlsplit[$gda], "GPRMC") Then
							_GPRMC($dlsplit[$gda]);Split GPRMC data from data string
							$disconnected_time = -1
						EndIf
					EndIf

				Next
			EndIf
		EndIf
		If BitOR($Temp_Quality = 1, $Temp_Quality = 2) = 1 And BitOR($Temp_Status = "A", $GpsDetailsOpen <> 1) Then ExitLoop;If $Temp_Quality = 1 (GPS has a fix) And, If the details window is open, $Temp_Status = "A" (Active data, not Void)
		If TimerDiff($timeout) > $maxtime Then ExitLoop;If time is over timeout period, exitloop
	WEnd
	If $FoundData = 1 Then
		$disconnected_time = -1
		If BitOR($Temp_Quality = 1, $Temp_Quality = 2) = 1 Then ;If the GPGGA data has a fix(1) then write data to perminant variables
			If $FixTime <> $Temp_FixTime Then $GPGGA_Update = TimerInit()
			$FixTime = $Temp_FixTime
			$Latitude = $Temp_Lat
			$Longitude = $Temp_Lon
			$NumberOfSatalites = $Temp_NumberOfSatalites
			$HorDilPitch = $Temp_HorDilPitch
			$Alt = $Temp_Alt
			$AltS = $Temp_AltS
			$Geo = $Temp_Geo
			$GeoS = $Temp_GeoS
		EndIf
		If $Temp_Status = "A" Then ;If the GPRMC data is Active(A) then write data to perminant variables
			If $FixTime2 <> $Temp_FixTime2 Then $GPRMC_Update = TimerInit()
			$FixTime2 = $Temp_FixTime2
			$Latitude2 = $Temp_Lat2
			$Longitude2 = $Temp_Lon2
			$SpeedInKnots = $Temp_SpeedInKnots
			$SpeedInMPH = $Temp_SpeedInMPH
			$SpeedInKmH = $Temp_SpeedInKmH
			$TrackAngle = $Temp_TrackAngle
			$FixDate = $Temp_FixDate
		EndIf
	Else
		If $disconnected_time = -1 Then $disconnected_time = TimerInit()
		If TimerDiff($disconnected_time) > 10000 Then ; If nothing has been found in the buffer for 10 seconds, turn off gps
			$disconnected_time = -1
			$return = 0
			_TurnOffGPS()
			SoundPlay($SoundDir & $ErrorFlag_sound, 0)
		EndIf
	EndIf

	_ClearGpsDetailsGUI();Reset variables if they are over the allowed timeout
	_UpdateGpsDetailsGUI();Write changes to "GPS Details" GUI if it is open

	If $TurnOffGPS = 1 Then _TurnOffGPS()

	Return ($return)
EndFunc   ;==>_GetGPS

Func _GPGGA($data);Strips data from a gps $GPGGA data string
	;GUICtrlSetData($Lab_GpsInfo, $data)
	If _CheckGpsChecksum($data) = 1 Then
		$GPGGA_Split = StringSplit($data, ",");
		If $GPGGA_Split[0] >= 14 Then
			$Temp_Quality = $GPGGA_Split[7]
			If BitOR($Temp_Quality = 1, $Temp_Quality = 2) = 1 Then
				$Temp_FixTime = _FormatGpsTime($GPGGA_Split[2])
				$Temp_Lat = $GPGGA_Split[4] & " " & StringFormat('%0.4f', $GPGGA_Split[3]);_FormatLatLon($GPGGA_Split[3], $GPGGA_Split[4])
				$Temp_Lon = $GPGGA_Split[6] & " " & StringFormat('%0.4f', $GPGGA_Split[5]);_FormatLatLon($GPGGA_Split[5], $GPGGA_Split[6])
				$Temp_NumberOfSatalites = $GPGGA_Split[8]
				$Temp_HorDilPitch = $GPGGA_Split[9]
				$Temp_Alt = $GPGGA_Split[10] * 3.2808399
				$Temp_AltS = $GPGGA_Split[11]
				$Temp_Geo = $GPGGA_Split[12]
				$Temp_GeoS = $GPGGA_Split[13]
			EndIf
		EndIf
	EndIf
EndFunc   ;==>_GPGGA

Func _GPRMC($data);Strips data from a gps $GPRMC data string
	;GUICtrlSetData($Lab_GpsInfo, $data)
	If _CheckGpsChecksum($data) = 1 Then
		$GPRMC_Split = StringSplit($data, ",")
		If $GPRMC_Split[0] >= 11 Then
			$Temp_Status = $GPRMC_Split[3]
			If $Temp_Status = "A" Then
				$Temp_FixTime2 = _FormatGpsTime($GPRMC_Split[2])
				$Temp_Lat2 = $GPRMC_Split[5] & ' ' & StringFormat('%0.4f', $GPRMC_Split[4]) ;_FormatLatLon($GPRMC_Split[4], $GPRMC_Split[5])
				$Temp_Lon2 = $GPRMC_Split[7] & ' ' & StringFormat('%0.4f', $GPRMC_Split[6]) ;_FormatLatLon($GPRMC_Split[6], $GPRMC_Split[7])
				$Temp_SpeedInKnots = $GPRMC_Split[8]
				$Temp_SpeedInMPH = Round($GPRMC_Split[8] * 1.15, 2)
				$Temp_SpeedInKmH = Round($GPRMC_Split[8] * 1.85200, 2)
				$Temp_TrackAngle = $GPRMC_Split[9]
				$Temp_FixDate = _FormatGpsDate($GPRMC_Split[10])
			EndIf
		EndIf
	EndIf
EndFunc   ;==>_GPRMC

Func _CheckGpsChecksum($checkdata);Checks if GPS Data Checksum is correct. Returns 1 if it is correct, else Returns 0
	$end = 0
	$calc_checksum = 0
	$checkdata_checksum = ''
	$gps_data_split = StringSplit($checkdata, '');Seperate all characters of data and put them into an array
	For $gds = 1 To $gps_data_split[0]
		If $gps_data_split[$gds] <> '$' And $gps_data_split[$gds] <> '*' And $end = 0 Then
			If $calc_checksum = 0 Then ;If $calc_checksum is equal 0, set $calc_checksum to the ascii value of this character
				$calc_checksum = Asc($gps_data_split[$gds])
			Else;If $calc_checksum is not equal 0 then XOR the new character ascii value with the $calc_checksum value
				$calc_checksum = BitXOR($calc_checksum, Asc($gps_data_split[$gds]))
			EndIf
		ElseIf $gps_data_split[$gds] = '*' Then ;If the checksum has been reached, set the $end flag
			$end = 1
		ElseIf $end = 1 And StringIsAlNum($gps_data_split[$gds]) Then ;if the end flag is equal 1 and the character is alpha-numeric then add the character to the end of $checkdata_checksum
			$checkdata_checksum &= $gps_data_split[$gds]
		EndIf
	Next
	$calc_checksum = Hex($calc_checksum, 2)
	If $calc_checksum = $checkdata_checksum Then ;If the calculated checksum matches the given checksum then Return 1, Else Return 0
		Return (1)
	Else
		Return (0)
	EndIf
EndFunc   ;==>_CheckGpsChecksum

Func _Format_GPS_DMM_to_DMS($gps);converts gps ddmm.mmmm to 'dd° mm' ss"
	;If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_Format_GPS_DMM_to_DMS()') ;#Debug Display
	$return = '0° 0' & Chr(39) & ' 0"'
	$splitlatlon1 = StringSplit($gps, " ");Split N,S,E,W from data
	If $splitlatlon1[0] = 2 Then
		$splitlatlon2 = StringSplit($splitlatlon1[2], ".")
		If $splitlatlon2[0] = 2 Then
			$DD = StringTrimRight($splitlatlon2[1], 2)
			$MM = StringTrimLeft($splitlatlon2[1], StringLen($splitlatlon2[1]) - 2)
			$SS = StringFormat('%0.4f', (('.' & $splitlatlon2[2]) * 60)); multiply remaining minutes by 60 to get ss
			$return = $splitlatlon1[1] & ' ' & $DD & '° ' & $MM & Chr(39) & ' ' & $SS & '"' ;Format data properly (ex. dd° mm' ss"N)
		Else
			$return = $splitlatlon1[1] & ' 0° 0' & Chr(39) & ' 0"'
		EndIf
	EndIf
	Return ($return)
EndFunc   ;==>_Format_GPS_DMM_to_DMS

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

Func _Format_GPS_All_to_DMM($gps, $PosChr, $NegChr);converts dd.ddddddd, 'dd° mm' ss", or ddmm.mmmm to ddmm.mmmm
	If StringInStr($gps, '-') Or StringInStr($gps, $NegChr) Then
		$gDir = $NegChr
	Else
		$gDir = $PosChr
	EndIf
	$gps = StringReplace(StringReplace(StringReplace(StringReplace(StringReplace($gps, " ", ""), "-", ""), "+", ""), $PosChr, ""), $NegChr, "")
	$splitlatlon2 = StringSplit($gps, ".")
	;ConsoleWrite('$splitlatlon2[0]: ' & $splitlatlon2[0] & '-' & $splitlatlon2[1] & '-' & $splitlatlon2[2] & @CRLF)
	If $splitlatlon2[0] = 1 Then
		$DDSplit = StringSplit($gps, "°")
		If $DDSplit[0] = 2 Then
			$DD = $DDSplit[1] * 100
			$MMSplit = StringSplit($DDSplit[2], "'")
			If $MMSplit[0] = 2 Then
				$MM = $MMSplit[1] + (StringReplace($MMSplit[2], '"', '') / 60)
				$return = $gDir & ' ' & StringFormat('%0.4f', $DD + $MM)
			EndIf
		EndIf
	ElseIf $splitlatlon2[0] = 2 Then
		If StringLen($splitlatlon2[2]) = 4 Then ;ddmm.mmmm to ddmm.mmmm
			$return = $gDir & ' ' & StringFormat('%0.4f', $gps)
		Else; dd.dddd to ddmm.mmmm
			$DD = $splitlatlon2[1] * 100
			$MM = ('.' & $splitlatlon2[2]) * 60 ;multiply remaining decimal by 60 to get mm.mmmm
			$return = $gDir & ' ' & StringFormat('%0.4f', $DD + $MM);Format data properly (ex. N ddmm.mmmm)
		EndIf
	EndIf
	Return ($return)
EndFunc   ;==>_Format_GPS_All_to_DMM

Func _FormatGpsTime($time)
	$time = StringTrimRight($time, 4)
	$h = StringTrimRight($time, 4)
	$m = StringTrimLeft(StringTrimRight($time, 2), 2)
	$s = StringTrimLeft($time, 4)
	If $h > 12 Then
		$h = $h - 12
		$l = "PM"
	Else
		$l = "AM"
	EndIf
	Return ($h & ":" & $m & ":" & $s & $l & ' (UTC)')
EndFunc   ;==>_FormatGpsTime

Func _FormatGpsDate($Date)
	$d = StringTrimRight($Date, 4)
	$m = StringTrimLeft(StringTrimRight($Date, 2), 2)
	$y = StringTrimLeft($Date, 4)
	Return ($y & '-' & $m & '-' & $d)
EndFunc   ;==>_FormatGpsDate

Func _DistanceBetweenPoints($Lat1, $Lon1, $Lat2, $Lon2)
	Local $EarthRadius = 6378137 ;meters
	$Lat1 = _deg2rad(StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($Lat1), " ", ""), "N", ""), "S", "-"))
	$Lon1 = _deg2rad(StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($Lon1), " ", ""), "E", ""), "W", "-"))
	$Lat2 = _deg2rad(StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($Lat2), " ", ""), "N", ""), "S", "-"))
	$Lon2 = _deg2rad(StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($Lon2), " ", ""), "E", ""), "W", "-"))
	Return (ACos(Sin($Lat1) * Sin($Lat2) + Cos($Lat1) * Cos($Lat2) * Cos($Lon2 - $Lon1)) * $EarthRadius);Return distance in meters
EndFunc   ;==>_DistanceBetweenPoints

Func _BearingBetweenPoints($Lat1, $Lon1, $Lat2, $Lon2)
	$Lat1 = _deg2rad(StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($Lat1), " ", ""), "N", ""), "S", "-"))
	$Lon1 = _deg2rad(StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($Lon1), " ", ""), "E", ""), "W", "-"))
	$Lat2 = _deg2rad(StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($Lat2), " ", ""), "N", ""), "S", "-"))
	$Lon2 = _deg2rad(StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($Lon2), " ", ""), "E", ""), "W", "-"))
	$bDegrees = _rad2deg(_ATan2(Cos($Lat1) * Sin($Lat2) - Sin($Lat1) * Cos($Lat2) * Cos($Lon2 - $Lon1), Sin($Lon2 - $Lon1) * Cos($Lat2)));Return Bearing in degrees
	If $bDegrees < 0 Then $bDegrees += 360
	Return ($bDegrees);Return bearing in degrees
EndFunc   ;==>_BearingBetweenPoints

Func _DestLat($Lat1, $Brng1, $Dist1)
	Local $EarthRadius = 6378137 ;meters
	$Lat1 = _deg2rad(StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($Lat1), " ", ""), "N", ""), "S", "-"))
	$Brng1 = _deg2rad($Brng1)
	Return (_Format_GPS_All_to_DMM(_rad2deg(ASin(Sin($Lat1) * Cos($Dist1 / $EarthRadius) + Cos($Lat1) * Sin($Dist1 / $EarthRadius) * Cos($Brng1))), "N", "S"));Return destination dmm latitude
EndFunc   ;==>_DestLat

Func _DestLon($Lat1, $Lon1, $Lat2, $Brng1, $Dist1)
	Local $EarthRadius = 6378137 ;meters
	$Lat1 = _deg2rad(StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($Lat1), " ", ""), "N", ""), "S", "-"))
	$Lon1 = _deg2rad(StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($Lon1), " ", ""), "E", ""), "W", "-"))
	$Lat2 = _deg2rad(StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($Lat2), " ", ""), "N", ""), "S", "-"))
	$Brng1 = _deg2rad($Brng1)
	Return (_Format_GPS_All_to_DMM(_rad2deg($Lon1 + _ATan2(Cos($Dist1 / $EarthRadius) - Sin($Lat1) * Sin($Lat2), Sin($Brng1) * Sin($Dist1 / $EarthRadius) * Cos($Lat1))), "E", "W"));Return destination dmm longitude
EndFunc   ;==>_DestLon

Func _GPSOptions()
	;GPS Settings
	$CloseGpsGUI = 0
	Opt("GUIOnEventMode", 0) ; Turn Off OnEvent mode
	$GpsOptions = GUICreate("GPS Settings", 420, 115, -1, -1)
	GUISetBkColor($BackgroundColor)
	GUICtrlCreateLabel("Com Port:", 15, 20, 50, 17)
	$CommPort = GUICtrlCreateCombo("1", 65, 15, 80, 25)
	GUICtrlSetData(-1, "2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20", $ComPort)
	GUICtrlCreateLabel("Baud:", 150, 20, 50, 17)
	$CommBaud = GUICtrlCreateCombo("4800", 185, 15, 80, 25)
	GUICtrlSetData(-1, "9600|14400|19200|38400|57600|115200", $BAUD)
	GUICtrlCreateLabel("Interface:", 270, 20, 50, 17)
	If $GpsType = 0 Then
		$DefGpsInt = "CommMG"
	ElseIf $GpsType = 1 Then
		$DefGpsInt = "Netcomm OCX"
	Else
		$DefGpsInt = "Kernel32"
	EndIf
	$Interface = GUICtrlCreateCombo("Kernel32", 325, 15, 80, 25)
	GUICtrlSetData(-1, "CommMG|Netcomm OCX", $DefGpsInt)
	GUICtrlCreateLabel("Stop Bit:", 16, 52, 50, 17)
	$CommBit = GUICtrlCreateCombo("1", 65, 47, 80, 25)
	GUICtrlSetData(-1, "1.5|2", $STOPBIT)
	GUICtrlCreateLabel("Parity:", 150, 52, 50, 17)
	If $PARITY = 'E' Then
		$l_PARITY = 'Even'
	ElseIf $PARITY = 'M' Then
		$l_PARITY = 'Mark'
	ElseIf $PARITY = 'O' Then
		$l_PARITY = 'Odd'
	ElseIf $PARITY = 'S' Then
		$l_PARITY = 'Space'
	Else
		$l_PARITY = 'None'
	EndIf
	$CommParity = GUICtrlCreateCombo("None", 185, 47, 80, 25)
	GUICtrlSetData(-1, 'Even|Mark|Odd|Space', $l_PARITY)
	GUICtrlCreateLabel("Data Bit:", 270, 52, 50, 17)
	$CommDataBit = GUICtrlCreateCombo("4", 325, 47, 80, 25)
	GUICtrlSetData(-1, "5|6|7|8", $DATABIT)
	$GPS_OK = GUICtrlCreateButton("Ok", 100, 80, 81, 25, 0)
	$GPS_Cancel = GUICtrlCreateButton("Cancel", 240, 80, 81, 25, 0)
	GUISetState(@SW_SHOW)
	While 1
		$nMsg = GUIGetMsg()
		Switch $nMsg
			Case $GUI_EVENT_CLOSE
				ExitLoop
			Case $GPS_Cancel
				ExitLoop
			Case $GPS_OK
				$ComPort = GUICtrlRead($CommPort)
				$BAUD = GUICtrlRead($CommBaud)
				$PARITY = GUICtrlRead($CommParity)
				$DATABIT = GUICtrlRead($CommDataBit)
				$STOPBIT = GUICtrlRead($CommBit)
				If GUICtrlRead($Interface) = "CommMG" Then
					$GpsType = 0
				ElseIf GUICtrlRead($Interface) = "Netcomm OCX" Then
					$GpsType = 1
				Else
					$GpsType = 2
				EndIf
				ExitLoop
		EndSwitch
	WEnd
	Opt("GUIOnEventMode", 1) ; Change to OnEvent mode
	GUIDelete($GpsOptions)
EndFunc   ;==>_GPSOptions

;-------------------------------------------------------------------------------------------------------------------------------
;                                                       GPS DETAILS GUI FUNCTIONS
;-------------------------------------------------------------------------------------------------------------------------------

Func _OpenGpsDetailsGUI();Opens GPS Details GUI
	If $GpsDetailsOpen = 0 Then
		$GpsDetailsGUI = GUICreate("Gps Details", 565, 190, -1, -1, BitOR($WS_OVERLAPPEDWINDOW, $WS_CLIPSIBLINGS))
		GUISetBkColor($BackgroundColor)
		$GpsCurrentDataGUI = GUICtrlCreateLabel('', 8, 5, 550, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GPGGA_Quality = GUICtrlCreateLabel("Quality" & ":", 310, 22, 180, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GPRMC_Status = GUICtrlCreateLabel("Status" & ":", 32, 22, 235, 15)
		GUICtrlSetColor(-1, $TextColor)
		GUICtrlCreateGroup("GPRMC", 8, 40, 273, 145)
		GUICtrlSetColor(-1, $TextColor)
		$GPRMC_Time = GUICtrlCreateLabel("Time" & ":", 25, 55, 235, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GPRMC_Date = GUICtrlCreateLabel("Date" & ":", 25, 70, 235, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GPRMC_Lat = GUICtrlCreateLabel("Latitude" & ":", 25, 85, 235, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GPRMC_Lon = GUICtrlCreateLabel("Longitude" & ":", 25, 100, 235, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GPRMC_SpeedKnots = GUICtrlCreateLabel("Speed(knots)" & ":", 25, 115, 235, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GPRMC_SpeedMPH = GUICtrlCreateLabel("Speed(MPH)" & ":", 25, 130, 243, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GPRMC_SpeedKmh = GUICtrlCreateLabel("Speed(kmh)" & ":", 25, 145, 243, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GPRMC_TrackAngle = GUICtrlCreateLabel("Track Angle" & ":", 25, 160, 243, 20)
		GUICtrlSetColor(-1, $TextColor)
		GUICtrlCreateGroup("GPGGA", 287, 40, 273, 125)
		GUICtrlSetColor(-1, $TextColor)
		$GPGGA_Time = GUICtrlCreateLabel("Time" & ":", 304, 55, 235, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GPGGA_Satalites = GUICtrlCreateLabel("Number of sats" & ":", 304, 70, 235, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GPGGA_Lat = GUICtrlCreateLabel("Latitude" & ":", 304, 85, 235, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GPGGA_Lon = GUICtrlCreateLabel("Longitude" & ":", 304, 100, 235, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GPGGA_HorDilPitch = GUICtrlCreateLabel("H.D.P." & ":", 304, 115, 235, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GPGGA_Alt = GUICtrlCreateLabel("Altitude" & ":", 304, 130, 243, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GPGGA_Geo = GUICtrlCreateLabel("Height of Geoid" & ":", 304, 145, 243, 15)
		GUICtrlSetColor(-1, $TextColor)
		$CloseGpsDetailsGUI = GUICtrlCreateButton("Close", 375, 165, 97, 25, 0)
		GUICtrlSetOnEvent($CloseGpsDetailsGUI, '_CloseGpsDetailsGUI')
		GUISetOnEvent($GUI_EVENT_CLOSE, '_CloseGpsDetailsGUI')

		GUISetState(@SW_SHOW)

		$gpsplit = StringSplit($GpsDetailsPosition, ',')
		If $gpsplit[0] = 4 Then ;If $CompassPosition is a proper position, move and resize window
			WinMove($GpsDetailsGUI, '', $gpsplit[1], $gpsplit[2], $gpsplit[3], $gpsplit[4])
		Else ;Set $CompassPosition to the current window position
			$g = WinGetPos($GpsDetailsGUI)
			$GpsDetailsPosition = $g[0] & ',' & $g[1] & ',' & $g[2] & ',' & $g[3]
		EndIf

		$GpsDetailsOpen = 1
	EndIf
EndFunc   ;==>_OpenGpsDetailsGUI

Func _UpdateGpsDetailsGUI();Updates information on GPS Details GUI
	If $GpsDetailsOpen = 1 Then
		GUICtrlSetData($GPGGA_Time, "Time" & ": " & $FixTime)
		GUICtrlSetData($GPGGA_Lat, "Latitude" & ": " & StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($Latitude), 'S', '-'), 'N', ''), ' ', ''))
		GUICtrlSetData($GPGGA_Lon, "Longitude" & ": " & StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($Longitude), 'W', '-'), 'E', ''), ' ', ''))
		GUICtrlSetData($GPGGA_Quality, "Quality" & ": " & $Temp_Quality)
		GUICtrlSetData($GPGGA_Satalites, "Number of sats" & ": " & $NumberOfSatalites)
		GUICtrlSetData($GPGGA_HorDilPitch, "H.D.P." & ": " & $HorDilPitch)
		GUICtrlSetData($GPGGA_Alt, "Altitude" & ": " & $Alt & $AltS)
		GUICtrlSetData($GPGGA_Geo, "Height of Geoid" & ": " & $Geo & $GeoS)

		GUICtrlSetData($GPRMC_Time, "Time" & ": " & $FixTime2)
		GUICtrlSetData($GPRMC_Date, "Date" & ": " & $FixDate)
		GUICtrlSetData($GPRMC_Lat, "Latitude" & ": " & StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($Latitude2), 'S', '-'), 'N', ''), ' ', ''))
		GUICtrlSetData($GPRMC_Lon, "Longitude" & ": " & StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($Longitude2), 'W', '-'), 'E', ''), ' ', ''))
		GUICtrlSetData($GPRMC_Status, "Status" & ": " & $Temp_Status)
		GUICtrlSetData($GPRMC_SpeedKnots, "Speed(knots)" & ": " & $SpeedInKnots & " Kn")
		GUICtrlSetData($GPRMC_SpeedMPH, "Speed(MPH)" & ": " & $SpeedInMPH & " MPH")
		GUICtrlSetData($GPRMC_SpeedKmh, "Speed(kmh)" & ": " & $SpeedInKmH & " Km/H")
		GUICtrlSetData($GPRMC_TrackAngle, "Track Angle" & ": " & $TrackAngle)
	EndIf
EndFunc   ;==>_UpdateGpsDetailsGUI

Func _ClearGpsDetailsGUI();Clears all GPS Details information
	If Round(TimerDiff($GPGGA_Update)) > $GpsTimeout Then
		$FixTime = ''
		$Latitude = '0.0000000'
		$Longitude = '0.0000000'
		$NumberOfSatalites = '00'
		$HorDilPitch = '0'
		$Alt = '0'
		$AltS = 'M'
		$Geo = '0'
		$GeoS = 'M'
		$GPGGA_Update = TimerInit()
	EndIf
	If Round(TimerDiff($GPRMC_Update)) > $GpsTimeout Then
		$FixTime2 = ''
		$Latitude2 = '0.0000000'
		$Longitude2 = '0.0000000'
		$SpeedInKnots = '0'
		$SpeedInMPH = '0'
		$SpeedInKmH = '0'
		$TrackAngle = '0'
		$FixDate = ''
		$GPRMC_Update = TimerInit()
	EndIf
EndFunc   ;==>_ClearGpsDetailsGUI

Func _CloseGpsDetailsGUI(); Closes GPS Details GUI
	GUIDelete($GpsDetailsGUI)
	$GpsDetailsOpen = 0
EndFunc   ;==>_CloseGpsDetailsGUI

;-------------------------------------------------------------------------------------------------------------------------------
;                                                       GPS COMPASS GUI FUNCTIONS
;-------------------------------------------------------------------------------------------------------------------------------

Func _CompassGUI()
	If $CompassOpen = 0 Then
		$CompassGUI = GUICreate("Compass", 130, 130, -1, -1, BitOR($WS_OVERLAPPEDWINDOW, $WS_CLIPSIBLINGS))
		GUISetBkColor($BackgroundColor)
		$CompassBack = GUICtrlCreateLabel('', 0, 0, 130, 130)
		GUICtrlSetState($CompassBack, $GUI_HIDE)
		$north = GUICtrlCreateLabel("N", 50, 0, 15, 15)
		GUICtrlSetColor(-1, $TextColor)
		$south = GUICtrlCreateLabel("S", 50, 90, 15, 15)
		GUICtrlSetColor(-1, $TextColor)
		$east = GUICtrlCreateLabel("E", 93, 45, 15, 12)
		GUICtrlSetColor(-1, $TextColor)
		$west = GUICtrlCreateLabel("W", 3, 45, 15, 12)
		GUICtrlSetColor(-1, $TextColor)

		_GDIPlus_Startup()
		$CompassGraphic = _GDIPlus_GraphicsCreateFromHWND($CompassGUI)
		$CompassColor = '0xFF' & StringTrimLeft($ControlBackgroundColor, 2)
		$hBrush = _GDIPlus_BrushCreateSolid($CompassColor) ;red
		_GDIPlus_GraphicsFillEllipse($CompassGraphic, 15, 15, 100, 100, $hBrush)

		GUISetOnEvent($GUI_EVENT_CLOSE, '_CloseCompassGui')
		GUISetOnEvent($GUI_EVENT_RESIZED, '_SetCompassSizes')
		GUISetOnEvent($GUI_EVENT_RESTORE, '_SetCompassSizes')

		GUISetState(@SW_SHOW)

		$cpsplit = StringSplit($CompassPosition, ',')
		If $cpsplit[0] = 4 Then ;If $CompassPosition is a proper position, move and resize window
			WinMove($CompassGUI, '', $cpsplit[1], $cpsplit[2], $cpsplit[3], $cpsplit[4])
		Else ;Set $CompassPosition to the current window position
			$c = WinGetPos($CompassGUI)
			$CompassPosition = $c[0] & ',' & $c[1] & ',' & $c[2] & ',' & $c[3]
		EndIf
		_SetCompassSizes()

		$CompassOpen = 1
	Else
		WinActivate($CompassGUI)
	EndIf
EndFunc   ;==>_CompassGUI

Func _CloseCompassGui();closes the compass window
	_GDIPlus_GraphicsDispose($CompassGraphic)
	_GDIPlus_Shutdown()
	GUIDelete($CompassGUI)
	$CompassOpen = 0
EndFunc   ;==>_CloseCompassGui

Func _SetCompassSizes();Takes the size of a hidden label in the compass window and determines the Width/Height of the compass
	If $CompassOpen = 1 Then
		;Check Compass Window Position
		If WinActive($CompassGUI) Then
			$c = WinGetPos($CompassGUI)
			If $c[0] & ',' & $c[1] & ',' & $c[2] & ',' & $c[3] <> $CompassPosition Then $CompassPosition = $c[0] & ',' & $c[1] & ',' & $c[2] & ',' & $c[3] ;If the $CompassGUI has moved or resized, set $CompassPosition to current window size
		EndIf
		;Get sizes
		$a = ControlGetPos("", "", $CompassBack)
		If Not @error Then
			$compasspos = $a[0] & $a[1] & $a[2] & $a[3]
			If $a[2] > $a[3] Then
				Dim $CompassHeight = $a[3] - 30
			Else
				Dim $CompassHeight = $a[2] - 30
			EndIf
		EndIf
		$CompassMidWidth = 10 + ($CompassHeight / 2)
		$CompassMidHeight = 10 + ($CompassHeight / 2)
		GUICtrlSetPos($north, $CompassMidWidth, 0, 15, 15)
		GUICtrlSetPos($south, $CompassMidWidth, $CompassHeight + 15, 15, 15)
		GUICtrlSetPos($east, $CompassHeight + 15, $CompassMidHeight, 15, 15)
		GUICtrlSetPos($west, 0, $CompassMidHeight, 15, 15)

		_GDIPlus_GraphicsDispose($CompassGraphic)
		_GDIPlus_Shutdown()
		_GDIPlus_Startup()

		$CompassGraphic = _GDIPlus_GraphicsCreateFromHWND($CompassGUI)
		$CompassColor = '0xFF' & StringTrimLeft($ControlBackgroundColor, 2)
		$hBrush = _GDIPlus_BrushCreateSolid($CompassColor)
		_GDIPlus_GraphicsFillEllipse($CompassGraphic, 15, 15, $CompassHeight, $CompassHeight, $hBrush)
	EndIf
EndFunc   ;==>_SetCompassSizes

Func _DrawCompassLine($Degree, $LineColorARGB = "0xFF000000");, $Degree2);Draws compass in GPS Details GUI
	If $CompassOpen = 1 Then
		$Radius = ($CompassHeight / 2) - 1
		$CenterX = ($CompassHeight / 2) + 15
		$CenterY = ($CompassHeight / 2) + 15
		If $Degree >= 0 And $Degree <= 360 Then ;Only Draw line if valid degree value was given
			;Calculate (X, Y) based on Degrees, Radius, And Center of circle (X, Y) for $Degree
			If $Degree = 0 Or $Degree = 360 Then
				$CircleX = $CenterX
				$CircleY = $CenterY - $Radius
			ElseIf $Degree > 0 And $Degree < 90 Then
				$Radians = $Degree * 0.0174532925
				$CircleX = $CenterX + (Sin($Radians) * $Radius)
				$CircleY = $CenterY - (Cos($Radians) * $Radius)
			ElseIf $Degree = 90 Then
				$CircleX = $CenterX + $Radius
				$CircleY = $CenterY
			ElseIf $Degree > 90 And $Degree < 180 Then
				$TmpDegree = $Degree - 90
				$Radians = $TmpDegree * 0.0174532925
				$CircleX = $CenterX + (Cos($Radians) * $Radius)
				$CircleY = $CenterY + (Sin($Radians) * $Radius)
			ElseIf $Degree = 180 Then
				$CircleX = $CenterX
				$CircleY = $CenterY + $Radius
			ElseIf $Degree > 180 And $Degree < 270 Then
				$TmpDegree = $Degree - 180
				$Radians = $TmpDegree * 0.0174532925
				$CircleX = $CenterX - (Sin($Radians) * $Radius)
				$CircleY = $CenterY + (Cos($Radians) * $Radius)
			ElseIf $Degree = 270 Then
				$CircleX = $CenterX - $Radius
				$CircleY = $CenterY
			ElseIf $Degree > 270 And $Degree < 360 Then
				$TmpDegree = $Degree - 270
				$Radians = $TmpDegree * 0.0174532925
				$CircleX = $CenterX - (Cos($Radians) * $Radius)
				$CircleY = $CenterY - (Sin($Radians) * $Radius)
			EndIf
			;Draw $Degree Line
			$pen = _GDIPlus_PenCreate($LineColorARGB, 2)
			_GDIPlus_GraphicsDrawLine($CompassGraphic, $CenterX, $CenterY, $CircleX, $CircleY, $pen)
			_GDIPlus_PenDispose($pen)
		EndIf

	EndIf
EndFunc   ;==>_DrawCompassLine

Func _DrawCompassCircle($Percent, $LineColorARGB = "0xFF000000");, $Degree2);Draws compass in GPS Details GUI
	$Radius = ($CompassHeight / 2) - 1
	$pen = _GDIPlus_PenCreate($LineColorARGB, 2)
	;ConsoleWrite(15 + ($Radius * ($Percent * .01)) & '-' & $Radius & '-' & $Percent & @CRLF)
	_GDIPlus_GraphicsDrawEllipse($CompassGraphic, 15 + ($Radius * ($Percent * .01)), 15 + ($Radius * ($Percent * .01)), $CompassHeight - (2 * ($Radius * ($Percent * .01))), $CompassHeight - (2 * ($Radius * ($Percent * .01))), $pen)
	_GDIPlus_PenDispose($pen)
EndFunc   ;==>_DrawCompassCircle
;---------------------------------------------------------------------------------------
;Math Functions
;---------------------------------------------------------------------------------------
Func _deg2rad($Degree) ;convert degrees to radians
	Local $PI = 3.14159265358979
	$Degree = StringReplace(StringReplace(StringReplace(StringReplace(StringReplace($Degree, 'W', '-'), 'E', ''), 'S', '-'), 'N', ''), ' ', '')
	Return ($Degree * ($PI / 180))
EndFunc   ;==>_deg2rad

Func _rad2deg($radian) ;convert radians to degrees
	Local $PI = 3.14159265358979
	Return ($radian * (180 / $PI))
EndFunc   ;==>_rad2deg

Func _ATan2($x, $y) ;ATan2 function, since autoit only has ATan
	Local Const $PI = 3.14159265358979
	If $y < 0 Then
		Return -_ATan2($x, -$y)
	ElseIf $x < 0 Then
		Return $PI - ATan(-$y / $x)
	ElseIf $x > 0 Then
		Return ATan($y / $x)
	ElseIf $y <> 0 Then
		Return $PI / 2
	Else
		SetError(1)
	EndIf
EndFunc   ;==>_ATan2

Func _SetControlSizes();Sets control positions in GUI based on the windows current size
	$a = WinGetPos($MysticacheGUI)
	WinMove($DataChild, "", 0, 60, $a[2] - 10, $a[3] - 115)
	$b = WinGetPos($DataChild) ;get child window size
	$sizes = $a[0] & '-' & $a[1] & '-' & $a[2] & '-' & $a[3] & '-' & $b[0] & '-' & $b[1] & '-' & $b[2] & '-' & $b[3]
	If $sizes <> $sizes_old Then
		$ListviewAPs_left = ($b[2] * 0.01)
		$ListviewAPs_width = ($b[2] * 0.99) - $ListviewAPs_left
		$ListviewAPs_top = ($b[3] * 0.01)
		$ListviewAPs_height = ($b[3] * 0.99) - $ListviewAPs_top

		;ConsoleWrite($ListviewAPs_left & '-' & $ListviewAPs_width & '-' & $ListviewAPs_top & '-' & $ListviewAPs_height & @CRLF)

		GUICtrlSetPos($ListviewAPs, $ListviewAPs_left, $ListviewAPs_top, $ListviewAPs_width, $ListviewAPs_height)
		GUICtrlSetState($ListviewAPs, $GUI_FOCUS)
	EndIf
	$sizes_old = $sizes
EndFunc   ;==>_SetControlSizes

Func _SortColumnToggle(); Sets the ap list column header that was clicked
	;If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_SortColumnToggle()') ;#Debug Display
	$SortColumn = GUICtrlGetState($ListviewAPs)
EndFunc   ;==>_SortColumnToggle

Func _SetListviewWidths()
	;If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_SetListviewWidths()') ;#Debug Display
	;Set column widths - All variables have ' - 0' after them to make this work. it would not set column widths without the ' - 0'

	#comments-start
		_GUICtrlListView_SetColumnWidth($ListviewAPs, $column_Active - 0, $column_Width_Active - 0)
		_GUICtrlListView_SetColumnWidth($ListviewAPs, $column_SSID - 0, $column_Width_SSID - 0)
		_GUICtrlListView_SetColumnWidth($ListviewAPs, $column_BSSID - 0, $column_Width_BSSID - 0)
		_GUICtrlListView_SetColumnWidth($ListviewAPs, $column_MANUF - 0, $column_Width_MANUF - 0)
		_GUICtrlListView_SetColumnWidth($ListviewAPs, $column_Signal - 0, $column_Width_Signal - 0)
		_GUICtrlListView_SetColumnWidth($ListviewAPs, $column_Authentication - 0, $column_Width_Authentication - 0)
		_GUICtrlListView_SetColumnWidth($ListviewAPs, $column_Encryption - 0, $column_Width_Encryption - 0)
		_GUICtrlListView_SetColumnWidth($ListviewAPs, $column_RadioType - 0, $column_Width_RadioType - 0)
		_GUICtrlListView_SetColumnWidth($ListviewAPs, $column_Channel - 0, $column_Width_Channel - 0)
		_GUICtrlListView_SetColumnWidth($ListviewAPs, $column_Latitude - 0, $column_Width_Latitude - 0)
		_GUICtrlListView_SetColumnWidth($ListviewAPs, $column_Longitude - 0, $column_Width_Longitude - 0)
		_GUICtrlListView_SetColumnWidth($ListviewAPs, $column_LatitudeDMS - 0, $column_Width_LatitudeDMS - 0)
		_GUICtrlListView_SetColumnWidth($ListviewAPs, $column_LongitudeDMS - 0, $column_Width_LongitudeDMS - 0)
		_GUICtrlListView_SetColumnWidth($ListviewAPs, $column_LatitudeDMM - 0, $column_Width_LatitudeDMM - 0)
		_GUICtrlListView_SetColumnWidth($ListviewAPs, $column_LongitudeDMM - 0, $column_Width_LongitudeDMM - 0)
		_GUICtrlListView_SetColumnWidth($ListviewAPs, $column_BasicTransferRates - 0, $column_Width_BasicTransferRates - 0)
		_GUICtrlListView_SetColumnWidth($ListviewAPs, $column_OtherTransferRates - 0, $column_Width_OtherTransferRates - 0)
		_GUICtrlListView_SetColumnWidth($ListviewAPs, $column_FirstActive - 0, $column_Width_FirstActive - 0)
		_GUICtrlListView_SetColumnWidth($ListviewAPs, $column_LastActive - 0, $column_Width_LastActive - 0)
		_GUICtrlListView_SetColumnWidth($ListviewAPs, $column_NetworkType - 0, $column_Width_NetworkType - 0)
		_GUICtrlListView_SetColumnWidth($ListviewAPs, $column_Label - 0, $column_Width_Label - 0)
	#comments-end
EndFunc   ;==>_SetListviewWidths
