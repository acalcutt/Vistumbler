#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Icons\icon.ico
#AutoIt3Wrapper_Outfile=Vistumbler.exe
#AutoIt3Wrapper_Res_Fileversion=10.3.2.0
#AutoIt3Wrapper_Res_requestedExecutionLevel=requireAdministrator
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
;License Information------------------------------------
;Copyright (C) 2015 Andrew Calcutt
;This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; Version 2 of the License.
;This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
;You should have received a copy of the GNU General Public License along with this program; If not, see <http://www.gnu.org/licenses/gpl-2.0.html>.
;--------------------------------------------------------
;AutoIt Version: v3.3.12.0
$Script_Author = 'Andrew Calcutt'
$Script_Name = 'Vistumbler'
$Script_Website = 'http://www.Vistumbler.net'
$Script_Function = 'A wireless network scanner for Windows 8, Windows 7, and Vista.'
$version = 'v10.6'
$Script_Start_Date = '2007/07/10'
$last_modified = '2015/06/12'
HttpSetUserAgent($Script_Name & ' ' & $version)
;Includes------------------------------------------------
#include <File.au3>
#include <GuiConstants.au3>
#include <GuiListView.au3>
#include <WindowsConstants.au3>
#include <GuiTreeView.au3>
#include <GuiTab.au3>
#include <Process.au3>
#include <GDIPlus.au3>
#include <Date.au3>
#include <GuiButton.au3>
#include <GuiMenu.au3>
#include <Misc.au3>
#include <String.au3>
#include <INet.au3>
#include <SQLite.au3>
#include <GuiMenu.au3>
#include "UDFs\AccessCom.au3"
#include "UDFs\CommMG.au3"
#include "UDFs\cfxUDF.au3"
#include "UDFs\HTTP.au3"
#include "UDFs\JSON.au3"
#include "UDFs\MD5.au3"
#include "UDFs\NativeWifi.au3"
#include "UDFs\ParseCSV.au3"
#include "UDFs\ZIP.au3"
#include "UDFs\FileInUse.au3"
#include "UDFs\UnixTime.au3"
;Set setting folder--------------------------------------
Dim $SettingsDir = @ScriptDir & '\Settings\'
DirCreate($SettingsDir)
;Set Settings file
Dim $settings = $SettingsDir & 'vistumbler_settings.ini'
IniWrite($settings, "Vistumbler", "Name", $Script_Name)
IniWrite($settings, "Vistumbler", "Version", $version)
;Set if Vistumbler Should run in portable mode (keep all directories in the vistumbler folder)
Dim $PortableMode = IniRead($settings, 'Vistumbler', 'PortableMode', 0)
;Set directories
If $PortableMode = 0 Then ;Use Local User %temp% directory for temp and users my document folder for save
	Dim $DefaultSaveDir = @MyDocumentsDir & '\Vistumbler\'
	Dim $TmpDir = @TempDir & '\Vistumbler\'
Else;Use folders inside the Vistumbler directory
	Dim $DefaultSaveDir = @ScriptDir & '\Save\'
	Dim $TmpDir = @ScriptDir & '\temp\'
EndIf
Dim $LanguageDir = @ScriptDir & '\Languages\'
Dim $SoundDir = @ScriptDir & '\Sounds\'
Dim $ImageDir = @ScriptDir & '\Images\'
Dim $IconDir = @ScriptDir & '\Icons\'
;Create directories
DirCreate($SettingsDir)
DirCreate($DefaultSaveDir)
DirCreate($TmpDir)
DirCreate($LanguageDir)
DirCreate($SoundDir)
DirCreate($ImageDir)
DirCreate($IconDir)
;Cleanup Old Temp Files----------------------------------
_CleanupFiles($TmpDir, '*.tmp')
_CleanupFiles($TmpDir, '*.ldb')
_CleanupFiles($TmpDir, '*.ini')
_CleanupFiles($TmpDir, '*.kml')
;Associate VS1 with Vistumbler
If $PortableMode = 0 Then
	If StringLower(StringTrimLeft(@ScriptName, StringLen(@ScriptName) - 4)) = '.exe' Then
		RegWrite('HKCR\.vsz\', '', 'REG_SZ', 'Vistumbler')
		RegWrite('HKCR\.vs1\', '', 'REG_SZ', 'Vistumbler')
		RegWrite('HKCR\Vistumbler\shell\open\command\', '', 'REG_SZ', '"' & @ScriptFullPath & '" "%1"')
		RegWrite('HKCR\Vistumbler\DefaultIcon\', '', 'REG_SZ', '"' & @ScriptDir & '\Icons\vsfile_icon.ico"')
	EndIf
EndIf
;Set Hotkeys
$hkArray = IniReadSection($settings, "Hotkeys")
If Not @error Then
	For $hk = 1 To $hkArray[0][0]
		ConsoleWrite("Hotkey:" & $hkArray[$hk][0] & " Function:" & $hkArray[$hk][1] & @CRLF)
		HotKeySet($hkArray[$hk][0], $hkArray[$hk][1])
	Next
EndIf

;Set vistumbler to load VS1/VSZ if one is specified by command line
Dim $Load = ''
For $loop = 1 To $CmdLine[0]
	If StringLower(StringTrimLeft($CmdLine[$loop], StringLen($CmdLine[$loop]) - 4)) = '.vs1' Then $Load = $CmdLine[$loop]
	If StringLower(StringTrimLeft($CmdLine[$loop], StringLen($CmdLine[$loop]) - 4)) = '.vsz' Then $Load = $CmdLine[$loop]
Next
; Set a COM Error handler--------------------------------
$oMyError = ObjEvent("AutoIt.Error", "MyErrFunc")
;Set Wifi Scan Type
Dim $UseNativeWifi = IniRead($settings, 'Vistumbler', 'UseNativeWifi', 1)
If @OSVersion = "WIN_XP" Then $UseNativeWifi = 1
; -------------------------------------------------------
GUIRegisterMsg($WM_NOTIFY, "WM_NOTIFY")
;Options-------------------------------------------------
Opt("TrayIconHide", 1);Hide icon in system tray
Opt("GUIOnEventMode", 1);Change to OnEvent mode
Opt("GUIResizeMode", 802)
;Get Date/Time-------------------------------------------
$dt = StringSplit(_DateTimeUtcConvert(StringFormat("%04i", @YEAR) & '-' & StringFormat("%02i", @MON) & '-' & StringFormat("%02i", @MDAY), @HOUR & ':' & @MIN & ':' & @SEC & '.' & StringFormat("%03i", @MSEC), 1), ' ')
$datestamp = $dt[1]
$timestamp = $dt[2]
$ldatetimestamp = StringFormat("%04i", @YEAR) & '-' & StringFormat("%02i", @MON) & '-' & StringFormat("%02i", @MDAY) & ' ' & @HOUR & '-' & @MIN & '-' & @SEC
Dim $DateFormat = StringReplace(StringReplace(IniRead($settings, 'DateFormat', 'DateFormat', RegRead('HKCU\Control Panel\International\', 'sShortDate')), 'MM', 'M'), 'dd', 'd')
;Declair-Variables---------------------------------------
Global $gdi_dll, $user32_dll
Global $hDC
Global Enum $idCopy = 1000, $idNewManu, $idNewLabel, $idGNInfo, $idGraph, $idFindAP

Dim $NsOk
Dim $StartArraySize
Dim $Debug
Dim $debugdisplay
Dim $sErr

Dim $VistumblerDB
Dim $VistumblerDbName
Dim $ManuDB = $SettingsDir & 'Manufacturers.mdb'
Dim $LabDB = $SettingsDir & 'Labels.mdb'
Dim $CamDB = $SettingsDir & 'Cameras.mdb'
Dim $InstDB = $SettingsDir & 'Instruments.mdb'
Dim $FiltDB = $SettingsDir & 'Filters.mdb'

Dim $DB_OBJ
Dim $ManuDB_OBJ
Dim $LabDB_OBJ
Dim $CamDB_OBJ
Dim $InstDB_OBJ
Dim $FiltDB_OBJ
Dim $AddApRecordArray[24]
Dim $AddLabelRecordArray[3]
Dim $AddManuRecordArray[3]
Dim $AddTreeRecordArray[17]
Dim $APID = 0
Dim $HISTID = 0
Dim $GPS_ID = 0
Dim $CamID = 0
Dim $CamGroupID = 0
Dim $Recover = 0
Dim $VistumblerGuiOpen = 0

Dim $MoveMode = False
Dim $MoveArea = False
Dim $DataChild_Width
Dim $DataChild_Height

Dim $datestamp
Dim $timestamp
Dim $GraphLastTime

Dim $GoogleEarth_ActiveFile = _TempFile($TmpDir, "autokml_active_", ".kml")
Dim $GoogleEarth_DeadFile = _TempFile($TmpDir, "autokml_dead_", ".kml")
Dim $GoogleEarth_GpsFile = _TempFile($TmpDir, "autokml_gps_", ".kml")
Dim $GoogleEarth_TrackFile = _TempFile($TmpDir, "autokml_track_", ".kml")
Dim $GoogleEarth_OpenFile = _TempFile($TmpDir, "autokml_networklink_", ".kml")
Dim $tempfile = _TempFile($TmpDir, "netsh-tmp_", ".tmp")
Dim $tempfile_showint = _TempFile($TmpDir, "netsh-si-tmp_", ".tmp")
Dim $wifidbgpstmp = _TempFile($TmpDir, "wifidb-gps-tmp_", ".tmp")
Dim $Latitude = 'N 0000.0000'
Dim $Longitude = 'E 0000.0000'
Dim $Latitude2 = 'N 0000.0000'
Dim $Longitude2 = 'E 0000.0000'
Dim $LatitudeWifidb = 'N 0000.0000'
Dim $LongitudeWifidb = 'E 0000.0000'
Dim $Last_Latitude = 'N 0000.0000'
Dim $Last_Longitude = 'E 0000.0000'
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
Dim $TurnOffGPS = 0
Dim $UseGPS = 0
Dim $Scan = 0
Dim $Close = 0
Dim $NewApFound = 0
Dim $ComError = 0
Dim $newdata = 0
Dim $disconnected_time = -1
Dim $SortColumn = -1
Dim $GUIList
Dim $TempFileArray, $TempFileArrayShowInt, $NetComm, $OpenArray, $headers, $MANUF, $LABEL, $SigHist
Dim $SSID, $NetworkType, $Authentication, $Encryption, $BSSID, $Signal, $RadioType, $Channel, $BasicTransferRates, $OtherTransferRates
Dim $LatTest, $gps, $winpos
Dim $sort_timer
Dim $data_old
Dim $RefreshTimer
Dim $sizes, $sizes_old
Dim $GraphBack, $GraphGrid, $red, $black
Dim $base_add = 0, $data, $data_old, $info_old, $Graph = 0, $Graph_old, $MinimalGuiMode_old, $ResetSizes = 1, $ReGraph = 1
Dim $LastSelected = -1
Dim $AutoRecoveryVS1File
Dim $SaveDbOnExit = 0
Dim $ClearAllAps = 0
Dim $UpdateAutoSave = 0
Dim $CompassOpen = 0
Dim $SettingsOpen = 0
Dim $AddMacOpen = 0
Dim $AddLabelOpen = 0
Dim $AutoUpApsToWifiDB = 0
Dim $ClearListAndTree = 0
Dim $TempBatchListviewInsert = 0
Dim $TempBatchListviewDelete = 0
Dim $SayProcess
Dim $MidiProcess
Dim $AutoRecoveryVS1Process
Dim $AutoKmlActiveProcess
Dim $AutoKmlDeadProcess
Dim $AutoKmlTrackProcess
Dim $NsCancel
Dim $DefaultApapterID
Dim $OpenedPort
Dim $LastGpsString
Dim $WifiDbSessionID

Dim $AddQuery
Dim $RemoveQuery
Dim $CountQuery

Dim $ListviewAPs
Dim $TreeviewAPs

Dim $NetworkAdapters[1]
_Wlan_StartSession()
Dim $noadaptersid

Dim $TreeviewAPs_left, $TreeviewAPs_width, $TreeviewAPs_top, $TreeviewAPs_height
Dim $ListviewAPs_left, $ListviewAPs_width, $ListviewAPs_top, $ListviewAPs_height
Dim $Graphic_left, $Graphic_width, $Graphic_top, $Graphic_height

Dim $Graph_topborder = 20, $Graph_bottomborder = 20, $Graph_leftborder = 40, $Graph_rightborder = 20
Dim $Compass_topborder = 20, $Compass_bottomborder = 20, $Compass_leftborder = 20, $Compass_rightborder = 20
Dim $2400topborder = 20, $2400bottomborder = 40, $2400leftborder = 40, $2400rightborder = 20
Dim $5000topborder = 20, $5000bottomborder = 40, $5000leftborder = 40, $5000rightborder = 20

Dim $Graph_backbuffer, $Graph_height, $Graph_width
Dim $CompassGUI, $Compass_graphics, $Compass_bitmap, $Compass_backbuffer, $Compass_height, $Compass_width, $Degree, $CompassGUI_width, $CompassGUI_height
Dim $2400chanGUI, $2400GraphicGUI, $2400chanGUIOpen, $2400height, $2400width, $2400topborder, $2400bottomborder, $2400leftborder, $2400rightborder, $2400graphheight, $2400graphwidth, $2400freqwidth, $2400percheight, $2400backbuffer, $2400bitmap, $2400graphics
Dim $5000chanGUI, $5000GraphicGUI, $5000chanGUIOpen, $5000height, $5000width, $5000topborder, $5000bottomborder, $5000leftborder, $5000rightborder, $5000graphheight, $5000graphwidth, $5000freqwidth, $5000percheight, $5000backbuffer, $5000bitmap, $5000graphics

Dim $FixTime, $FixTime2, $FixDate
Dim $Temp_FixTime, $Temp_FixTime2, $Temp_FixDate, $Temp_Lat, $Temp_Lon, $Temp_Lat2, $Temp_Lon2, $Temp_Quality, $Temp_NumberOfSatalites, $Temp_HorDilPitch, $Temp_Alt, $Temp_AltS, $Temp_Geo, $Temp_GeoS, $Temp_Status, $Temp_SpeedInKnots, $Temp_SpeedInMPH, $Temp_SpeedInKmH, $Temp_TrackAngle
Dim $GpsDetailsGUI, $GPGGA_Update, $GPRMC_Update, $GpsDetailsOpen = 0, $WifidbGPS_Update, $UploadFileToWifiDBOpen = 0
Dim $GpsCurrentDataGUI, $GPGGA_Time, $GPGGA_Lat, $GPGGA_Lon, $GPGGA_Quality, $GPGGA_Satalites, $GPGGA_HorDilPitch, $GPGGA_Alt, $GPGGA_Geo, $GPRMC_Time, $GPRMC_Date, $GPRMC_Lat, $GPRMC_Lon, $GPRMC_Status, $GPRMC_SpeedKnots, $GPRMC_SpeedMPH, $GPRMC_SpeedKmh, $GPRMC_TrackAngle
Dim $GUI_AutoSaveKml, $GUI_GoogleEXE, $GUI_AutoKmlActiveTime, $GUI_AutoKmlDeadTime, $GUI_AutoKmlGpsTime, $GUI_AutoKmlTrackTime, $GUI_KmlFlyTo, $AutoKmlActiveHeader, $GUI_OpenKmlNetLink, $GUI_AutoKml_Alt, $GUI_AutoKml_AltMode, $GUI_AutoKml_Heading, $GUI_AutoKml_Range, $GUI_AutoKml_Tilt
Dim $GUI_NewApSound, $GUI_ASperloop, $GUI_ASperap, $GUI_ASperapwsound, $GUI_SpeakSignal, $GUI_PlayMidiSounds, $GUI_SpeakSoundsVis, $GUI_SpeakSoundsSapi, $GUI_SpeakPercent, $GUI_SpeakSigTime, $GUI_SpeakSoundsMidi, $GUI_Midi_Instument, $GUI_Midi_PlayTime

Dim $GUI_Import, $vistumblerfileinput, $progressbar, $percentlabel, $linemin, $newlines, $minutes, $linetotal, $estimatedtime, $RadVis, $RadCsv, $RadNs, $RadWD
Dim $ExportKMLGUI, $GUI_TrackColor
Dim $GUI_ImportImageFiles

Dim $WifiDbUploadGUI, $WifiDb_User_GUI, $WifiDb_OtherUsers_GUI, $WifiDb_ApiKey_GUI, $upload_title_GUI, $upload_notes_GUI, $VS1_Radio_GUI, $VSZ_Radio_GUI, $CSV_Radio_GUI, $Export_Filtered_GUI
Dim $UpdateTimer, $MemReleaseTimer, $begintime, $closebtn

Dim $Apply_Misc = 1, $Apply_Save = 1, $Apply_GPS = 1, $Apply_Language = 0, $Apply_Manu = 0, $Apply_Lab = 0, $Apply_Column = 1, $Apply_Searchword = 1, $Apply_Auto = 1, $Apply_Sound = 1, $Apply_WifiDB = 1, $Apply_Cam = 0
Dim $SetMisc, $GUI_Comport, $GUI_Baud, $GUI_Parity, $GUI_StopBit, $GUI_DataBit, $GUI_Format, $GUI_GpsDisconnect, $GUI_GpsReset, $Rad_UseNetcomm, $Rad_UseCommMG, $Rad_UseKernel32, $LanguageBox, $SearchWord_SSID_GUI, $SearchWord_BSSID_GUI, $SearchWord_NetType_GUI
Dim $SearchWord_Authentication_GUI, $SearchWord_Signal_GUI, $SearchWord_RadioType_GUI, $SearchWord_Channel_GUI, $SearchWord_BasicRates_GUI, $SearchWord_OtherRates_GUI, $SearchWord_Encryption_GUI, $SearchWord_Open_GUI
Dim $SearchWord_None_GUI, $SearchWord_Wep_GUI, $SearchWord_Infrastructure_GUI, $SearchWord_Adhoc_GUI

Dim $LabAuth, $LabDate, $LabWinCode, $LabDesc, $GUI_Set_SaveDir, $GUI_Set_SaveDirAuto, $GUI_Set_SaveDirKml, $GUI_BKColor, $GUI_CBKColor, $GUI_TextColor, $GUI_dBmMaxSignal, $GUI_dBmDisassociationSignal, $GUI_TimeBeforeMarkingDead, $GUI_RefreshLoop, $GUI_AutoCheckForUpdates, $GUI_CheckForBetaUpdates, $GUI_CamTriggerScript
Dim $Gui_Csv, $GUI_Manu_List, $GUI_Lab_List, $GUI_Cam_List, $ImpLanFile
Dim $EditMacGUIForm, $GUI_Manu_NewManu, $GUI_Manu_NewMac, $EditMac_Mac, $EditMac_GUI, $EditLine, $GUI_Lab_NewMac, $GUI_Lab_NewLabel, $EditCamGUIForm, $GUI_Cam_NewID, $GUI_Cam_NewLOC, $GUI_Edit_CamID, $GUI_Edit_CamLOC, $Gui_CamTrigger, $GUI_CamTriggerTime, $GUI_ImgGroupName, $GUI_ImgGroupName, $GUI_ImpImgSkewTime, $GUI_ImpImgDir
Dim $AutoSaveAndClearBox, $AutoSaveAndClearRadioAP, $AutoSaveAndClearRadioTime, $AutoSaveAndClearAPsGUI, $AutoSaveAndClearTimeGUI, $AutoRecoveryBox, $AutoRecoveryDelBox, $AutoSaveAndClearPlaySoundGUI, $AutoRecoveryTimeGUI, $GUI_SortDirection, $GUI_RefreshNetworks, $GUI_RefreshTime, $GUI_WifidbLocate, $GUI_WiFiDbLocateRefreshTime, $GUI_SortBy, $GUI_SortTime, $GUI_AutoSort, $GUI_SortTime, $GUI_WifiDB_User, $GUI_WifiDB_ApiKey, $GUI_WifiDbGraphURL, $GUI_WifiDbWdbURL, $GUI_WifiDbApiURL, $GUI_WifidbUploadAps, $GUI_AutoUpApsToWifiDBTime
Dim $Gui_CsvFile, $Gui_CsvRadSummary, $Gui_CsvRadDetailed, $Gui_CsvFiltered
Dim $GUI_ModifyFilters, $FilterLV, $AddEditFilt_GUI, $Filter_ID_GUI, $Filter_Name_GUI, $Filter_Desc_GUI
Dim $MacAdd_GUI, $MacAdd_GUI_BSSID, $MacAdd_GUI_MANU, $LabelAdd_GUI, $LabelAdd_GUI_BSSID, $LabelAdd_GUI_LABEL

Dim $CWCB_RadioType, $CWIB_RadioType, $CWCB_Channel, $CWIB_Channel, $CWCB_Latitude, $CWIB_Latitude, $CWCB_Longitude, $CWIB_Longitude, $CWCB_LatitudeDMS, $CWIB_LatitudeDMS, $CWCB_LongitudeDMS, $CWIB_LongitudeDMS, $CWCB_LatitudeDMM, $CWIB_LatitudeDMM, $CWCB_LongitudeDMM, $CWIB_LongitudeDMM, $CWCB_BtX, $CWIB_BtX, $CWCB_OtX, $CWIB_OtX, $CWCB_FirstActive, $CWIB_FirstActive
Dim $CWCB_LastActive, $CWIB_LastActive, $CWCB_Line, $CWIB_Line, $CWCB_Active, $CWIB_Active, $CWCB_SSID, $CWIB_SSID, $CWCB_BSSID, $CWIB_BSSID, $CWCB_Manu, $CWIB_Manu, $CWCB_Signal, $CWIB_Signal, $CWCB_HighSignal, $CWIB_HighSignal, $CWCB_RSSI, $CWIB_RSSI, $CWCB_HighRSSI, $CWIB_HighRSSI
Dim $CWCB_Authentication, $CWIB_Authentication, $CWCB_Encryption, $CWIB_Encryption, $CWCB_NetType, $CWIB_NetType, $CWCB_Label, $CWIB_Label

Dim $CopyGUI_BSSID, $CopyGUI_Line, $CopyGUI_SSID, $CopyGUI_CHAN, $CopyGUI_AUTH, $CopyGUI_ENCR, $CopyGUI_NETTYPE, $CopyGUI_RADTYPE, $CopyGUI_SIG, $CopyGUI_HIGHSIG, $CopyGUI_RSSI, $CopyGUI_HIGHRSSI, $CopyGUI_MANU, $CopyGUI_LAB, $CopyGUI_LAT, $CopyGUI_LON, $CopyGUI_LATDMS, $CopyGUI_LONDMS, $CopyGUI_LATDMM, $CopyGUI_LONDMM, $CopyGUI_BTX, $CopyGUI_OTX, $CopyGUI_FirstActive, $CopyGUI_LastActive
Dim $GUI_COPY, $CopyFlag = 0, $CopyAPID, $Copy_Line, $Copy_BSSID, $Copy_SSID, $Copy_CHAN, $Copy_AUTH, $Copy_ENCR, $Copy_NETTYPE, $Copy_RADTYPE, $Copy_SIG, $Copy_HIGHSIG, $Copy_RSSI, $Copy_HIGHRSSI, $Copy_LAB, $Copy_MANU, $Copy_LAT, $Copy_LON, $Copy_LATDMS, $Copy_LONDMS, $Copy_LATDMM, $Copy_LONDMM, $Copy_BTX, $Copy_OTX, $Copy_FirstActive, $Copy_LastActive

Dim $Filter_SSID_GUI, $Filter_BSSID_GUI, $Filter_CHAN_GUI, $Filter_AUTH_GUI, $Filter_ENCR_GUI, $Filter_RADTYPE_GUI, $Filter_NETTYPE_GUI, $Filter_SIG_GUI, $Filter_HighSig_GUI, $Filter_RSSI_GUI, $Filter_HighRSSI_GUI, $Filter_BTX_GUI, $Filter_OTX_GUI, $Filter_Line_GUI, $Filter_Active_GUI
Dim $GIT_ROOT = 'https://raw.github.com/acalcutt/Vistumbler/'
Dim $CurrentVersionFile = @ScriptDir & '\versions.ini'
Dim $NewVersionFile = $TmpDir & 'versions.ini'

Dim $KmlSignalMapStyles = '	<Style id="SigCat1">' & @CRLF _
		 & '		<IconStyle>' & @CRLF _
		 & '			<scale>1.2</scale>' & @CRLF _
		 & '		</IconStyle>' & @CRLF _
		 & '		<LineStyle>' & @CRLF _
		 & '			<color>ff0000ff</color>' & @CRLF _
		 & '			<width>2</width>' & @CRLF _
		 & '		</LineStyle>' & @CRLF _
		 & '		<PolyStyle>' & @CRLF _
		 & '			<color>bf0000ff</color>' & @CRLF _
		 & '			<outline>0</outline>' & @CRLF _
		 & '			<opacity>75</opacity>' & @CRLF _
		 & '		</PolyStyle>' & @CRLF _
		 & '	</Style>' & @CRLF _
		 & '	<Style id="SigCat2">' & @CRLF _
		 & '		<IconStyle>' & @CRLF _
		 & '			<scale>1.2</scale>' & @CRLF _
		 & '		</IconStyle>' & @CRLF _
		 & '		<LineStyle>' & @CRLF _
		 & '			<color>ff0055ff</color>' & @CRLF _
		 & '			<width>2</width>' & @CRLF _
		 & '		</LineStyle>' & @CRLF _
		 & '		<PolyStyle>' & @CRLF _
		 & '			<color>bf0055ff</color>' & @CRLF _
		 & '			<outline>0</outline>' & @CRLF _
		 & '			<opacity>75</opacity>' & @CRLF _
		 & '		</PolyStyle>' & @CRLF _
		 & '	</Style>' & @CRLF _
		 & '	<Style id="SigCat3">' & @CRLF _
		 & '		<IconStyle>' & @CRLF _
		 & '			<scale>1.2</scale>' & @CRLF _
		 & '		</IconStyle>' & @CRLF _
		 & '		<LineStyle>' & @CRLF _
		 & '			<color>ff00ffff</color>' & @CRLF _
		 & '			<width>2</width>' & @CRLF _
		 & '		</LineStyle>' & @CRLF _
		 & '		<PolyStyle>' & @CRLF _
		 & '			<color>bf00ffff</color>' & @CRLF _
		 & '			<outline>0</outline>' & @CRLF _
		 & '			<opacity>75</opacity>' & @CRLF _
		 & '		</PolyStyle>' & @CRLF _
		 & '	</Style>' & @CRLF _
		 & '	<Style id="SigCat4">' & @CRLF _
		 & '		<IconStyle>' & @CRLF _
		 & '			<scale>1.2</scale>' & @CRLF _
		 & '		</IconStyle>' & @CRLF _
		 & '		<LineStyle>' & @CRLF _
		 & '			<color>ff01ffc8</color>' & @CRLF _
		 & '			<width>2</width>' & @CRLF _
		 & '		</LineStyle>' & @CRLF _
		 & '		<PolyStyle>' & @CRLF _
		 & '			<color>bf01ffc8</color>' & @CRLF _
		 & '			<outline>0</outline>' & @CRLF _
		 & '			<opacity>75</opacity>' & @CRLF _
		 & '		</PolyStyle>' & @CRLF _
		 & '	</Style>' & @CRLF _
		 & '	<Style id="SigCat5">' & @CRLF _
		 & '		<IconStyle>' & @CRLF _
		 & '			<scale>1.2</scale>' & @CRLF _
		 & '		</IconStyle>' & @CRLF _
		 & '		<LineStyle>' & @CRLF _
		 & '			<color>ff70ff48</color>' & @CRLF _
		 & '			<width>2</width>' & @CRLF _
		 & '		</LineStyle>' & @CRLF _
		 & '		<PolyStyle>' & @CRLF _
		 & '			<color>bf70ff48</color>' & @CRLF _
		 & '			<outline>0</outline>' & @CRLF _
		 & '			<opacity>75</opacity>' & @CRLF _
		 & '		</PolyStyle>' & @CRLF _
		 & '	</Style>' & @CRLF _
		 & '	<Style id="SigCat6">' & @CRLF _
		 & '		<IconStyle>' & @CRLF _
		 & '			<scale>1.2</scale>' & @CRLF _
		 & '		</IconStyle>' & @CRLF _
		 & '		<LineStyle>' & @CRLF _
		 & '			<color>ff3d8c27</color>' & @CRLF _
		 & '			<width>2</width>' & @CRLF _
		 & '		</LineStyle>' & @CRLF _
		 & '		<PolyStyle>' & @CRLF _
		 & '			<color>bf3d8c27</color>' & @CRLF _
		 & '			<outline>0</outline>' & @CRLF _
		 & '			<opacity>75</opacity>' & @CRLF _
		 & '		</PolyStyle>' & @CRLF _
		 & '	</Style>' & @CRLF

;Define Arrays
Dim $Direction[26];Direction array for sorting by clicking on the header. Needs to be 1 greatet (or more) than the amount of columns
Dim $Direction2[3]
Dim $Direction3[3]
Dim $OldGraphData[1]
;Load-Settings-From-INI-File----------------------------
Dim $SaveDir = IniRead($settings, 'Vistumbler', 'SaveDir', $DefaultSaveDir)
Dim $SaveDirAuto = IniRead($settings, 'Vistumbler', 'SaveDirAuto', $DefaultSaveDir)
Dim $SaveDirKml = IniRead($settings, 'Vistumbler', 'SaveDirKml', $DefaultSaveDir)
Dim $netsh = IniRead($settings, 'Vistumbler', 'Netsh_exe', 'netsh.exe')
Dim $AutoCheckForUpdates = IniRead($settings, 'Vistumbler', 'AutoCheckForUpdates', 1)
Dim $CheckForBetaUpdates = IniRead($settings, 'Vistumbler', 'CheckForBetaUpdates', 1)
Dim $DefaultApapter = IniRead($settings, 'Vistumbler', 'DefaultApapter', 'Wireless Network Connection')
Dim $TextColor = IniRead($settings, 'Vistumbler', 'TextColor', "0x000000")
Dim $BackgroundColor = IniRead($settings, 'Vistumbler', 'BackgroundColor', "0x99B4A1")
Dim $ControlBackgroundColor = IniRead($settings, 'Vistumbler', 'ControlBackgroundColor', "0xD7E4C2")
Dim $SplitPercent = IniRead($settings, 'Vistumbler', 'SplitPercent', '0.2')
Dim $SplitHeightPercent = IniRead($settings, 'Vistumbler', 'SplitHeightPercent', '0.65')
Dim $RefreshLoopTime = IniRead($settings, 'Vistumbler', 'Sleeptime', 1000)
Dim $AddDirection = IniRead($settings, 'Vistumbler', 'NewApPosistion', 0)
Dim $RefreshNetworks = IniRead($settings, 'Vistumbler', 'AutoRefreshNetworks', 1)
Dim $RefreshTime = IniRead($settings, 'Vistumbler', 'AutoRefreshTime', 1000)
Dim $Debug = IniRead($settings, 'Vistumbler', 'Debug', 0)
Dim $DebugCom = IniRead($settings, 'Vistumbler', 'DebugCom', 0)
Dim $UseRssiInGraphs = IniRead($settings, 'Vistumbler', 'UseRssiInGraphs', 1)
Dim $GraphDeadTime = IniRead($settings, 'Vistumbler', 'GraphDeadTime', 0)
Dim $SaveGpsWithNoAps = IniRead($settings, 'Vistumbler', 'SaveGpsWithNoAps', 1)
Dim $TimeBeforeMarkedDead = IniRead($settings, 'Vistumbler', 'TimeBeforeMarkedDead', 2)
Dim $AutoSelect = IniRead($settings, 'Vistumbler', 'AutoSelect', 0)
Dim $AutoSelectHS = IniRead($settings, 'Vistumbler', 'AutoSelectHS', 0)
Dim $DefFiltID = IniRead($settings, 'Vistumbler', 'DefFiltID', '-1')
Dim $AutoScan = IniRead($settings, 'Vistumbler', 'AutoScan', '0')
Dim $dBmMaxSignal = IniRead($settings, 'Vistumbler', 'dBmMaxSignal', '-30')
Dim $dBmDissociationSignal = IniRead($settings, 'Vistumbler', 'dBmDissociationSignal', '-85')
Dim $MinimalGuiMode = IniRead($settings, 'Vistumbler', 'MinimalGuiMode', 0)
Dim $MinimalGuiExitHeight = IniRead($settings, 'Vistumbler', 'MinimalGuiExitHeight', 695)
Dim $AutoScrollToBottom = IniRead($settings, 'Vistumbler', 'AutoScrollToBottom', 0)
Dim $BatchListviewInsert = IniRead($settings, 'Vistumbler', 'BatchListviewInsert', 0)

Dim $VistumblerState = IniRead($settings, 'WindowPositions', 'VistumblerState', 'Window')
Dim $VistumblerPosition = IniRead($settings, 'WindowPositions', 'VistumblerPosition', '')
Dim $CompassPosition = IniRead($settings, 'WindowPositions', 'CompassPosition', '')
Dim $GpsDetailsPosition = IniRead($settings, 'WindowPositions', 'GpsDetailsPosition', '')
Dim $2400ChanGraphPos = IniRead($settings, 'WindowPositions', '2400ChanGraphPos', '')
Dim $5000ChanGraphPos = IniRead($settings, 'WindowPositions', '5000ChanGraphPos', '')

Dim $ComPort = IniRead($settings, 'GpsSettings', 'ComPort', '4')
Dim $BAUD = IniRead($settings, 'GpsSettings', 'Baud', '4800')
Dim $PARITY = IniRead($settings, 'GpsSettings', 'Parity', 'N')
Dim $DATABIT = IniRead($settings, 'GpsSettings', 'DataBit', '8')
Dim $STOPBIT = IniRead($settings, 'GpsSettings', 'StopBit', '1')
Dim $GpsType = IniRead($settings, 'GpsSettings', 'GpsType', '2')
Dim $GPSformat = IniRead($settings, 'GpsSettings', 'GPSformat', 3)
Dim $GpsTimeout = IniRead($settings, 'GpsSettings', 'GpsTimeout', 30000)
Dim $GpsDisconnect = IniRead($settings, 'GpsSettings', 'GpsDisconnect', 1)
Dim $GpsReset = IniRead($settings, 'GpsSettings', 'GpsReset', 1)

Dim $SortTime = IniRead($settings, 'AutoSort', 'AutoSortTime', 60)
Dim $AutoSort = IniRead($settings, 'AutoSort', 'AutoSort', 0)
Dim $SortBy = IniRead($settings, 'AutoSort', 'SortCombo', 'SSID')
Dim $SortDirection = IniRead($settings, 'AutoSort', 'AscDecDefault', 0)

Dim $AutoRecoveryVS1 = IniRead($settings, 'AutoRecovery', 'AutoRecovery', 1)
Dim $AutoRecoveryVS1Del = IniRead($settings, 'AutoRecovery', 'AutoRecoveryDel', 1)
Dim $AutoRecoveryTime = IniRead($settings, 'AutoRecovery', 'AutoRecoveryTime', 5)

Dim $AutoSaveAndClear = IniRead($settings, 'AutoSaveAndClear', 'AutoSaveAndClear', 0)
Dim $AutoSaveAndClearPlaySound = IniRead($settings, 'AutoSaveAndClear', 'AutoSaveAndClearPlaySound', 1)
Dim $AutoSaveAndClearOnTime = IniRead($settings, 'AutoSaveAndClear', 'AutoSaveAndClearOnTime', 0)
Dim $AutoSaveAndClearTime = IniRead($settings, 'AutoSaveAndClear', 'AutoSaveAndClearTime', 60)
Dim $AutoSaveAndClearOnAPs = IniRead($settings, 'AutoSaveAndClear', 'AutoSaveAndClearOnAPs', 1)
Dim $AutoSaveAndClearAPs = IniRead($settings, 'AutoSaveAndClear', 'AutoSaveAndClearAPs', 1000)

Dim $SoundOnGps = IniRead($settings, 'Sound', 'PlaySoundOnNewGps', 0)
Dim $SoundOnAP = IniRead($settings, 'Sound', 'PlaySoundOnNewAP', 1)
Dim $SoundPerAP = IniRead($settings, 'Sound', 'SoundPerAP', 0)
Dim $NewSoundSigBased = IniRead($settings, 'Sound', 'NewSoundSigBased', 0)
Dim $new_AP_sound = IniRead($settings, 'Sound', 'NewAP_Sound', 'new_ap.wav')
Dim $new_GPS_sound = IniRead($settings, 'Sound', 'NewGPS_Sound', 'new_gps.wav')
Dim $AutoSave_sound = IniRead($settings, 'Sound', 'AutoSave_Sound', 'autosave.wav')
Dim $ErrorFlag_sound = IniRead($settings, 'Sound', 'Error_Sound', 'error.wav')

Dim $SpeakSignal = IniRead($settings, 'MIDI', 'SpeakSignal', 0)
Dim $SpeakSigSayPecent = IniRead($settings, 'MIDI', 'SpeakSigSayPecent', 1)
Dim $SpeakSigTime = IniRead($settings, 'MIDI', 'SpeakSigTime', 2000)
Dim $SpeakType = IniRead($settings, 'MIDI', 'SpeakType', 2)
Dim $Midi_Instument = IniRead($settings, 'MIDI', 'Midi_Instument', 56)
Dim $Midi_PlayTime = IniRead($settings, 'MIDI', 'Midi_PlayTime', 500)
Dim $Midi_PlayForActiveAps = IniRead($settings, 'MIDI', 'Midi_PlayForActiveAps', 0)

Dim $MapPos = IniRead($settings, 'KmlSettings', 'MapPos', 1)
Dim $MapSig = IniRead($settings, 'KmlSettings', 'MapSig', 1)
Dim $MapSigUseRSSI = IniRead($settings, 'KmlSettings', 'MapSigUseRSSI', 1)
Dim $MapSigType = IniRead($settings, 'KmlSettings', 'MapSigType', 0)
Dim $MapRange = IniRead($settings, 'KmlSettings', 'MapRange', 1)
Dim $ShowTrack = IniRead($settings, 'KmlSettings', 'ShowTrack', 1)
Dim $MapOpen = IniRead($settings, 'KmlSettings', 'MapOpen', 1)
Dim $MapWEP = IniRead($settings, 'KmlSettings', 'MapWEP', 1)
Dim $MapSec = IniRead($settings, 'KmlSettings', 'MapSec', 1)
Dim $UseLocalKmlImagesOnExport = IniRead($settings, 'KmlSettings', 'UseLocalKmlImagesOnExport', 0)
Dim $SigMapTimeBeforeMarkedDead = IniRead($settings, 'KmlSettings', 'SigMapTimeBeforeMarkedDead', 2)
Dim $TrackColor = IniRead($settings, 'KmlSettings', 'TrackColor', '7F0000FF')
Dim $CirSigMapColor = IniRead($settings, 'KmlSettings', 'CirSigMapColor', 'FF0055FF')
Dim $CirRangeMapColor = IniRead($settings, 'KmlSettings', 'CirRangeMapColor', 'FF00AA00')

Dim $CamTrigger = IniRead($settings, 'Cam', 'CamTrigger', 0)
Dim $CamTriggerScript = IniRead($settings, 'Cam', 'CamTriggerScript', "")
Dim $CamTriggerTime = IniRead($settings, 'Cam', 'CamTriggerTime', 10000)
Dim $DownloadImages = IniRead($settings, 'Cam', 'DownloadImages', 0)
Dim $DownloadImagesTime = IniRead($settings, 'Cam', 'DownloadImagesTime', 10000)

Dim $AutoKML = IniRead($settings, 'AutoKML', 'AutoKML', 0)
Dim $AutoKML_Alt = IniRead($settings, 'AutoKML', 'AutoKML_Alt', '4000')
Dim $AutoKML_AltMode = IniRead($settings, 'AutoKML', 'AutoKML_AltMode', 'clampToGround')
Dim $AutoKML_Heading = IniRead($settings, 'AutoKML', 'AutoKML_Heading', '0')
Dim $AutoKML_Range = IniRead($settings, 'AutoKML', 'AutoKML_Range', '4000')
Dim $AutoKML_Tilt = IniRead($settings, 'AutoKML', 'AutoKML_Tilt', '0')
Dim $AutoKmlActiveTime = IniRead($settings, 'AutoKML', 'AutoKmlActiveTime', 1)
Dim $AutoKmlDeadTime = IniRead($settings, 'AutoKML', 'AutoKmlDeadTime', 30)
Dim $AutoKmlGpsTime = IniRead($settings, 'AutoKML', 'AutoKmlGpsTime', 1)
Dim $AutoKmlTrackTime = IniRead($settings, 'AutoKML', 'AutoKmlTrackTime', 10)
Dim $KmlFlyTo = IniRead($settings, 'AutoKML', 'KmlFlyTo', 1)
Dim $OpenKmlNetLink = IniRead($settings, 'AutoKML', 'OpenKmlNetLink', 1)
$defaultgooglepath = RegRead('HKEY_CURRENT_USER\Software\Google\Google Earth Plus\autoupdate', 'AppPath') & '/googleearth.exe'
If $defaultgooglepath = '/googleearth.exe' And @OSArch = 'X86' Then $defaultgooglepath = 'C:/Program Files/Google/Google Earth/client/googleearth.exe' ;use as default for x86 if google earth path is not found in registry
If $defaultgooglepath = '/googleearth.exe' And @OSArch = 'X64' Then $defaultgooglepath = 'C:/Program Files (x86)/Google/Google Earth/client/googleearth.exe' ;use as default for x64 if google earth path is not found in registry
Dim $GoogleEarthExe = IniRead($settings, 'AutoKML', 'GoogleEarthExe', $defaultgooglepath)

Dim $WifiDb_User = IniRead($settings, 'WifiDbWifiTools', 'WifiDb_User', '')
Dim $WifiDb_ApiKey = IniRead($settings, 'WifiDbWifiTools', 'WifiDb_ApiKey', '')
Dim $WifiDb_OtherUsers = IniRead($settings, 'WifiDbWifiTools', 'WifiDb_OtherUsers', '')
Dim $WifiDb_UploadType = IniRead($settings, 'WifiDbWifiTools', 'WifiDb_UploadType', 'VSZ')
Dim $WifiDb_UploadFiltered = IniRead($settings, 'WifiDbWifiTools', 'WifiDb_UploadFiltered', 0)
Dim $WifiDbGraphURL = IniRead($settings, 'WifiDbWifiTools', 'WifiDb_GRAPH_URL', 'https://api.wifidb.net/wifi/')
Dim $WifiDbWdbURL = IniRead($settings, 'WifiDbWifiTools', 'WiFiDB_URL', 'https://live.wifidb.net/wifidb/')
Dim $WifiDbApiURL = IniRead($settings, 'WifiDbWifiTools', 'WifiDB_API_URL', 'https://api.wifidb.net/')
Dim $UseWiFiDbGpsLocate = IniRead($settings, 'WifiDbWifiTools', 'UseWiFiDbGpsLocate', 0)
Dim $EnableAutoUpApsToWifiDB = IniRead($settings, 'WifiDbWifiTools', 'AutoUpApsToWifiDB', 0)
Dim $AutoUpApsToWifiDBTime = IniRead($settings, 'WifiDbWifiTools', 'AutoUpApsToWifiDBTime', 60)
Dim $WiFiDbLocateRefreshTime = IniRead($settings, 'WifiDbWifiTools', 'WiFiDbLocateRefreshTime', 5000)

Dim $column_Line = IniRead($settings, 'Columns', 'Column_Line', 0)
Dim $column_Active = IniRead($settings, 'Columns', 'Column_Active', 1)
Dim $column_BSSID = IniRead($settings, 'Columns', 'Column_BSSID', 2)
Dim $column_SSID = IniRead($settings, 'Columns', 'Column_SSID', 3)
Dim $column_Signal = IniRead($settings, 'Columns', 'Column_Signal', 4)
Dim $column_HighSignal = IniRead($settings, 'Columns', 'Column_HighSignal', 5)
Dim $column_RSSI = IniRead($settings, 'Columns', 'Column_RSSI', 6)
Dim $column_HighRSSI = IniRead($settings, 'Columns', 'Column_HighRSSI', 7)
Dim $column_Channel = IniRead($settings, 'Columns', 'Column_Channel', 8)
Dim $column_Authentication = IniRead($settings, 'Columns', 'Column_Authentication', 9)
Dim $column_Encryption = IniRead($settings, 'Columns', 'Column_Encryption', 10)
Dim $column_NetworkType = IniRead($settings, 'Columns', 'Column_NetworkType', 11)
Dim $column_Latitude = IniRead($settings, 'Columns', 'Column_Latitude', 12)
Dim $column_Longitude = IniRead($settings, 'Columns', 'Column_Longitude', 13)
Dim $column_MANUF = IniRead($settings, 'Columns', 'Column_Manufacturer', 14)
Dim $column_Label = IniRead($settings, 'Columns', 'Column_Label', 15)
Dim $column_RadioType = IniRead($settings, 'Columns', 'Column_RadioType', 16)
Dim $column_LatitudeDMS = IniRead($settings, 'Columns', 'Column_LatitudeDMS', 17)
Dim $column_LongitudeDMS = IniRead($settings, 'Columns', 'Column_LongitudeDMS', 18)
Dim $column_LatitudeDMM = IniRead($settings, 'Columns', 'Column_LatitudeDMM', 19)
Dim $column_LongitudeDMM = IniRead($settings, 'Columns', 'Column_LongitudeDMM', 20)
Dim $column_BasicTransferRates = IniRead($settings, 'Columns', 'Column_BasicTransferRates', 21)
Dim $column_OtherTransferRates = IniRead($settings, 'Columns', 'Column_OtherTransferRates', 22)
Dim $column_FirstActive = IniRead($settings, 'Columns', 'Column_FirstActive', 23)
Dim $column_LastActive = IniRead($settings, 'Columns', 'Column_LastActive', 24)

Dim $column_Width_Line = IniRead($settings, 'Column_Width', 'Column_Line', 60)
Dim $column_Width_Active = IniRead($settings, 'Column_Width', 'Column_Active', 60)
Dim $column_Width_SSID = IniRead($settings, 'Column_Width', 'Column_SSID', 150)
Dim $column_Width_BSSID = IniRead($settings, 'Column_Width', 'Column_BSSID', 110)
Dim $column_Width_MANUF = IniRead($settings, 'Column_Width', 'Column_Manufacturer', 110)
Dim $column_Width_Signal = IniRead($settings, 'Column_Width', 'Column_Signal', 75)
Dim $column_Width_HighSignal = IniRead($settings, 'Column_Width', 'Column_HighSignal', 75)
Dim $column_Width_RSSI = IniRead($settings, 'Column_Width', 'Column_RSSI', 75)
Dim $column_Width_HighRSSI = IniRead($settings, 'Column_Width', 'Column_HighRSSI', 75)
Dim $column_Width_Channel = IniRead($settings, 'Column_Width', 'Column_Channel', 70)
Dim $column_Width_Authentication = IniRead($settings, 'Column_Width', 'Column_Authentication', 105)
Dim $column_Width_Encryption = IniRead($settings, 'Column_Width', 'Column_Encryption', 105)
Dim $column_Width_RadioType = IniRead($settings, 'Column_Width', 'Column_RadioType', 85)
Dim $column_Width_Latitude = IniRead($settings, 'Column_Width', 'Column_Latitude', 85)
Dim $column_Width_Longitude = IniRead($settings, 'Column_Width', 'Column_Longitude', 85)
Dim $column_Width_LatitudeDMS = IniRead($settings, 'Column_Width', 'Column_LatitudeDMS', 115)
Dim $column_Width_LongitudeDMS = IniRead($settings, 'Column_Width', 'Column_LongitudeDMS', 115)
Dim $column_Width_LatitudeDMM = IniRead($settings, 'Column_Width', 'Column_LatitudeDMM', 140)
Dim $column_Width_LongitudeDMM = IniRead($settings, 'Column_Width', 'Column_LongitudeDMM', 140)
Dim $column_Width_BasicTransferRates = IniRead($settings, 'Column_Width', 'Column_BasicTransferRates', 130)
Dim $column_Width_OtherTransferRates = IniRead($settings, 'Column_Width', 'Column_OtherTransferRates', 130)
Dim $column_Width_FirstActive = IniRead($settings, 'Column_Width', 'Column_FirstActive', 130)
Dim $column_Width_LastActive = IniRead($settings, 'Column_Width', 'Column_LastActive', 130)
Dim $column_Width_NetworkType = IniRead($settings, 'Column_Width', 'Column_NetworkType', 100)
Dim $column_Width_Label = IniRead($settings, 'Column_Width', 'Column_Label', 110)

;Load GUI Text from language file
Dim $DefaultLanguage = IniRead($settings, 'Vistumbler', 'Language', 'English')
Dim $DefaultLanguageFile = IniRead($settings, 'Vistumbler', 'LanguageFile', $DefaultLanguage & '.ini')
Dim $DefaultLanguagePath = $LanguageDir & $DefaultLanguageFile
If FileExists($DefaultLanguagePath) = 0 Then
	$DefaultLanguage = 'English'
	$DefaultLanguageFile = 'English.ini'
	$DefaultLanguagePath = $LanguageDir & $DefaultLanguageFile
EndIf
IniDelete($settings, 'GuiText');Delete old GuiText section of the setting file if it exists

Dim $Column_Names_Line = IniRead($DefaultLanguagePath, 'Column_Names', 'Column_Line', '#')
Dim $Column_Names_Active = IniRead($DefaultLanguagePath, 'Column_Names', 'Column_Active', 'Active')
Dim $Column_Names_SSID = IniRead($DefaultLanguagePath, 'Column_Names', 'Column_SSID', 'SSID')
Dim $Column_Names_BSSID = IniRead($DefaultLanguagePath, 'Column_Names', 'Column_BSSID', 'Mac Address')
Dim $Column_Names_MANUF = IniRead($DefaultLanguagePath, 'Column_Names', 'Column_Manufacturer', 'Manufacturer')
Dim $Column_Names_Signal = IniRead($DefaultLanguagePath, 'Column_Names', 'Column_Signal', 'Signal')
Dim $Column_Names_HighSignal = IniRead($DefaultLanguagePath, 'Column_Names', 'Column_HighSignal', 'High Signal')
Dim $Column_Names_RSSI = IniRead($DefaultLanguagePath, 'Column_Names', 'Column_RSSI', 'RSSI')
Dim $Column_Names_HighRSSI = IniRead($DefaultLanguagePath, 'Column_Names', 'Column_HighRSSI', 'High RSSI')
Dim $Column_Names_Channel = IniRead($DefaultLanguagePath, 'Column_Names', 'Column_Channel', 'Channel')
Dim $Column_Names_Authentication = IniRead($DefaultLanguagePath, 'Column_Names', 'Column_Authentication', 'Authentication')
Dim $Column_Names_Encryption = IniRead($DefaultLanguagePath, 'Column_Names', 'Column_Encryption', 'Encryption')
Dim $Column_Names_RadioType = IniRead($DefaultLanguagePath, 'Column_Names', 'Column_RadioType', 'Radio Type')
Dim $Column_Names_Latitude = IniRead($DefaultLanguagePath, 'Column_Names', 'Column_Latitude', 'Latitude')
Dim $Column_Names_Longitude = IniRead($DefaultLanguagePath, 'Column_Names', 'Column_Longitude', 'Longitude')
Dim $Column_Names_LatitudeDMS = IniRead($DefaultLanguagePath, 'Column_Names', 'Column_LatitudeDMS', 'Latitude (DDMMSS)')
Dim $Column_Names_LongitudeDMS = IniRead($DefaultLanguagePath, 'Column_Names', 'Column_LongitudeDMS', 'Longitude (DDMMSS)')
Dim $Column_Names_LatitudeDMM = IniRead($DefaultLanguagePath, 'Column_Names', 'Column_LatitudeDMM', 'Latitude (DDMMMM)')
Dim $Column_Names_LongitudeDMM = IniRead($DefaultLanguagePath, 'Column_Names', 'Column_LongitudeDMM', 'Longitude (DDMMMM)')
Dim $Column_Names_BasicTransferRates = IniRead($DefaultLanguagePath, 'Column_Names', 'Column_BasicTransferRates', 'Basic Transfer Rates')
Dim $Column_Names_OtherTransferRates = IniRead($DefaultLanguagePath, 'Column_Names', 'Column_OtherTransferRates', 'Other Transfer Rates')
Dim $Column_Names_FirstActive = IniRead($DefaultLanguagePath, 'Column_Names', 'Column_FirstActive', 'First Active')
Dim $Column_Names_LastActive = IniRead($DefaultLanguagePath, 'Column_Names', 'Column_LastActive', 'Last Active')
Dim $Column_Names_NetworkType = IniRead($DefaultLanguagePath, 'Column_Names', 'Column_NetworkType', 'Network Type')
Dim $Column_Names_Label = IniRead($DefaultLanguagePath, 'Column_Names', 'Column_Label', 'Label')

Dim $SearchWord_SSID = IniRead($DefaultLanguagePath, 'SearchWords', 'SSID', 'SSID')
Dim $SearchWord_BSSID = IniRead($DefaultLanguagePath, 'SearchWords', 'BSSID', 'BSSID')
Dim $SearchWord_NetworkType = IniRead($DefaultLanguagePath, 'SearchWords', 'NetworkType', 'Network type')
Dim $SearchWord_Authentication = IniRead($DefaultLanguagePath, 'SearchWords', 'Authentication', 'Authentication')
Dim $SearchWord_Encryption = IniRead($DefaultLanguagePath, 'SearchWords', 'Encryption', 'Encryption')
Dim $SearchWord_Signal = IniRead($DefaultLanguagePath, 'SearchWords', 'Signal', 'Signal')
Dim $SearchWord_RSSI = IniRead($DefaultLanguagePath, 'SearchWords', 'RSSI', 'RSSI')
Dim $SearchWord_RadioType = IniRead($DefaultLanguagePath, 'SearchWords', 'RadioType', 'Radio Type')
Dim $SearchWord_Channel = IniRead($DefaultLanguagePath, 'SearchWords', 'Channel', 'Channel')
Dim $SearchWord_BasicRates = IniRead($DefaultLanguagePath, 'SearchWords', 'BasicRates', 'Basic Rates')
Dim $SearchWord_OtherRates = IniRead($DefaultLanguagePath, 'SearchWords', 'OtherRates', 'Other Rates')
Dim $SearchWord_None = IniRead($DefaultLanguagePath, 'SearchWords', 'None', 'None')
Dim $SearchWord_Open = IniRead($DefaultLanguagePath, 'SearchWords', 'Open', 'Open')
Dim $SearchWord_Wep = IniRead($DefaultLanguagePath, 'SearchWords', 'WEP', 'WEP')
Dim $SearchWord_Infrastructure = IniRead($DefaultLanguagePath, 'SearchWords', 'Infrastructure', 'Infrastructure')
Dim $SearchWord_Adhoc = IniRead($DefaultLanguagePath, 'SearchWords', 'Adhoc', 'Adhoc')
Dim $SearchWord_Cipher = IniRead($DefaultLanguagePath, 'SearchWords', 'Cipher', 'Cipher')

Dim $Text_Ok = IniRead($DefaultLanguagePath, 'GuiText', 'Ok', '&Ok')
Dim $Text_Cancel = IniRead($DefaultLanguagePath, 'GuiText', 'Cancel', 'C&ancel')
Dim $Text_Apply = IniRead($DefaultLanguagePath, 'GuiText', 'Apply', '&Apply')
Dim $Text_Browse = IniRead($DefaultLanguagePath, 'GuiText', 'Browse', '&Browse')

Dim $Text_File = IniRead($DefaultLanguagePath, 'GuiText', 'File', '&File')
Dim $Text_Import = IniRead($DefaultLanguagePath, 'GuiText', 'Import', '&Import')
Dim $Text_SaveAsTXT = IniRead($DefaultLanguagePath, 'GuiText', 'SaveAsTXT', 'Save As TXT')
Dim $Text_SaveAsVS1 = IniRead($DefaultLanguagePath, 'GuiText', 'SaveAsVS1', 'Save As VS1')
Dim $Text_SaveAsVSZ = IniRead($DefaultLanguagePath, 'GuiText', 'SaveAsVSZ', 'Save As VSZ')
Dim $Text_Export = IniRead($DefaultLanguagePath, 'GuiText', 'Export', 'Ex&port')
Dim $Text_ExportToKML = IniRead($DefaultLanguagePath, 'GuiText', 'ExportToKML', 'Export To KML')
Dim $Text_ExportToGPX = IniRead($DefaultLanguagePath, 'GuiText', 'ExportToGPX', 'Export To GPX')
Dim $Text_ExportToTXT = IniRead($DefaultLanguagePath, 'GuiText', 'ExportToTXT', 'Export To TXT')
Dim $Text_ExportToNS1 = IniRead($DefaultLanguagePath, 'GuiText', 'ExportToNS1', 'Export To NS1')
Dim $Text_ExportToVS1 = IniRead($DefaultLanguagePath, 'GuiText', 'ExportToVS1', 'Export To VS1')
Dim $Text_ExportToCSV = IniRead($DefaultLanguagePath, 'GuiText', 'ExportToCSV', 'Export To CSV')
Dim $Text_ExportToVSZ = IniRead($DefaultLanguagePath, "GuiText", "ExportToVSZ", "Export To VSZ")
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

Dim $Text_View = IniRead($DefaultLanguagePath, 'GuiText', 'View', '&View')

Dim $Text_Options = IniRead($DefaultLanguagePath, 'GuiText', 'Options', '&Options')
Dim $Text_AutoSort = IniRead($DefaultLanguagePath, 'GuiText', 'AutoSort', 'AutoSort')
Dim $Text_SortTree = IniRead($DefaultLanguagePath, 'GuiText', 'SortTree', 'Sort Tree  - (slow on big lists)')
Dim $Text_PlaySound = IniRead($DefaultLanguagePath, 'GuiText', 'PlaySound', 'Play sound on new AP')
Dim $Text_PlayGpsSound = IniRead($DefaultLanguagePath, 'GuiText', 'PlayGpsSound', 'Play sound on new GPS')
Dim $Text_AddAPsToTop = IniRead($DefaultLanguagePath, 'GuiText', 'AddAPsToTop', 'Add new APs to top')

Dim $Text_Extra = IniRead($DefaultLanguagePath, 'GuiText', 'Extra', 'Ex&tra')
Dim $Text_ScanAPs = IniRead($DefaultLanguagePath, 'GuiText', 'ScanAPs', '&Scan APs')
Dim $Text_StopScanAps = IniRead($DefaultLanguagePath, 'GuiText', 'StopScanAps', '&Stop')
Dim $Text_UseGPS = IniRead($DefaultLanguagePath, 'GuiText', 'UseGPS', 'Use &GPS')
Dim $Text_StopGPS = IniRead($DefaultLanguagePath, 'GuiText', 'StopGPS', 'Stop &GPS')

Dim $Text_Settings = IniRead($DefaultLanguagePath, 'GuiText', 'Settings', 'Settings')
Dim $Text_MiscSettings = IniRead($DefaultLanguagePath, 'GuiText', 'MiscSettings', 'Misc Settings')
Dim $Text_SaveSettings = IniRead($DefaultLanguagePath, 'GuiText', 'SaveSettings', 'Save Settings')
Dim $Text_GpsSettings = IniRead($DefaultLanguagePath, 'GuiText', 'GpsSettings', 'GPS Settings')
Dim $Text_SetLanguage = IniRead($DefaultLanguagePath, 'GuiText', 'SetLanguage', 'Set Language')
Dim $Text_SetSearchWords = IniRead($DefaultLanguagePath, 'GuiText', 'SetSearchWords', 'Set Search Words')
Dim $Text_SetMacLabel = IniRead($DefaultLanguagePath, 'GuiText', 'SetMacLabel', 'Set Labels by Mac')
Dim $Text_SetMacManu = IniRead($DefaultLanguagePath, 'GuiText', 'SetMacManu', 'Set Manufactures by Mac')

Dim $Text_WifiDbPHPgraph = IniRead($DefaultLanguagePath, 'GuiText', 'WifiDbPHPgraph', 'Graph Selected AP Signal to Image')
Dim $Text_WifiDbWDB = IniRead($DefaultLanguagePath, 'GuiText', 'WifiDbWDB', 'WiFiDB URL')
Dim $Text_WifiDbWdbLocate = IniRead($DefaultLanguagePath, 'GuiText', 'WifiDbWdbLocate', 'WifiDB Locate URL')
Dim $Text_UploadDataToWifiDB = IniRead($DefaultLanguagePath, 'GuiText', 'UploadDataToWiFiDB', 'Upload Data to WiFiDB')

Dim $Text_RefreshLoopTime = IniRead($DefaultLanguagePath, 'GuiText', 'RefreshLoopTime', 'Refresh loop time(ms):')
Dim $Text_ActualLoopTime = IniRead($DefaultLanguagePath, 'GuiText', 'ActualLoopTime', 'Loop time')
Dim $Text_Longitude = IniRead($DefaultLanguagePath, 'GuiText', 'Longitude', 'Longitude')
Dim $Text_Latitude = IniRead($DefaultLanguagePath, 'GuiText', 'Latitude', 'Latitude')
Dim $Text_ActiveAPs = IniRead($DefaultLanguagePath, 'GuiText', 'ActiveAPs', 'Active APs')
Dim $Text_Graph = IniRead($DefaultLanguagePath, 'GuiText', 'Graph', 'Graph')
Dim $Text_Graph1 = IniRead($DefaultLanguagePath, 'GuiText', 'Graph1', 'Graph1')
Dim $Text_Graph2 = IniRead($DefaultLanguagePath, 'GuiText', 'Graph2', 'Graph2')
Dim $Text_NoGraph = IniRead($DefaultLanguagePath, 'GuiText', 'NoGraph', 'No Graph')
Dim $Text_Active = IniRead($DefaultLanguagePath, 'GuiText', 'Active', 'Active')
Dim $Text_Dead = IniRead($DefaultLanguagePath, 'GuiText', 'Dead', 'Dead')

Dim $Text_AddNewLabel = IniRead($DefaultLanguagePath, 'GuiText', 'AddNewLabel', 'Add New Label')
Dim $Text_RemoveLabel = IniRead($DefaultLanguagePath, 'GuiText', 'RemoveLabel', 'Remove Selected Label')
Dim $Text_EditLabel = IniRead($DefaultLanguagePath, 'GuiText', 'EditLabel', 'Edit Selected Label')
Dim $Text_AddNewMan = IniRead($DefaultLanguagePath, 'GuiText', 'AddNewMan', 'Add New Manufacturer')
Dim $Text_RemoveMan = IniRead($DefaultLanguagePath, 'GuiText', 'RemoveMan', 'Remove Selected Manufacturer')
Dim $Text_EditMan = IniRead($DefaultLanguagePath, 'GuiText', 'EditMan', 'Edit Selected Manufacturer')
Dim $Text_NewMac = IniRead($DefaultLanguagePath, 'GuiText', 'NewMac', 'New Mac Address:')
Dim $Text_NewMan = IniRead($DefaultLanguagePath, 'GuiText', 'NewMan', 'New Manufacturer:')
Dim $Text_NewLabel = IniRead($DefaultLanguagePath, 'GuiText', 'NewLabel', 'New Label:')
Dim $Text_Save = IniRead($DefaultLanguagePath, 'GuiText', 'Save', 'Save')
Dim $Text_SaveQuestion = IniRead($DefaultLanguagePath, 'GuiText', 'SaveQuestion', 'Data has changed. Would you like to save?')

Dim $Text_GpsDetails = IniRead($DefaultLanguagePath, 'GuiText', 'GpsDetails', 'GPS Details')
Dim $Text_GpsCompass = IniRead($DefaultLanguagePath, 'GuiText', 'GpsCompass', 'GPS Compass')
Dim $Text_Quality = IniRead($DefaultLanguagePath, 'GuiText', 'Quality', 'Quality')
Dim $Text_Time = IniRead($DefaultLanguagePath, 'GuiText', 'Time', 'Time')
Dim $Text_NumberOfSatalites = IniRead($DefaultLanguagePath, 'GuiText', 'NumberOfSatalites', 'Number of Satalites')
Dim $Text_HorizontalDilutionPosition = IniRead($DefaultLanguagePath, 'GuiText', 'HorizontalDilutionPosition', 'Horizontal Dilution')
Dim $Text_Altitude = IniRead($DefaultLanguagePath, 'GuiText', 'Altitude', 'Altitude')
Dim $Text_HeightOfGeoid = IniRead($DefaultLanguagePath, 'GuiText', 'HeightOfGeoid', 'Height of Geoid')
Dim $Text_Status = IniRead($DefaultLanguagePath, 'GuiText', 'Status', 'Status')
Dim $Text_Date = IniRead($DefaultLanguagePath, 'GuiText', 'Date', 'Date')
Dim $Text_SpeedInKnots = IniRead($DefaultLanguagePath, 'GuiText', 'SpeedInKnots', 'Speed(knots)')
Dim $Text_SpeedInMPH = IniRead($DefaultLanguagePath, 'GuiText', 'SpeedInMPH', 'Speed(MPH)')
Dim $Text_SpeedInKmh = IniRead($DefaultLanguagePath, 'GuiText', 'SpeedInKmh', 'Speed(km/h)')
Dim $Text_TrackAngle = IniRead($DefaultLanguagePath, 'GuiText', 'TrackAngle', 'Track Angle')
Dim $Text_Close = IniRead($DefaultLanguagePath, 'GuiText', 'Close', 'Close')
Dim $Text_Start = IniRead($DefaultLanguagePath, 'GuiText', 'Start', 'Start')
Dim $Text_Stop = IniRead($DefaultLanguagePath, 'GuiText', 'Stop', 'Stop')
Dim $Text_RefreshNetworks = IniRead($DefaultLanguagePath, 'GuiText', 'RefreshingNetworks', 'Auto Refresh Networks')
Dim $Text_RefreshTime = IniRead($DefaultLanguagePath, 'GuiText', 'RefreshTime', 'Refresh time')
Dim $Text_SetColumnWidths = IniRead($DefaultLanguagePath, 'GuiText', 'SetColumnWidths', 'Set Column Widths')
Dim $Text_Enable = IniRead($DefaultLanguagePath, 'GuiText', 'Enable', 'Enable')
Dim $Text_Disable = IniRead($DefaultLanguagePath, 'GuiText', 'Disable', 'Disable')
Dim $Text_Checked = IniRead($DefaultLanguagePath, 'GuiText', 'Checked', 'Checked')
Dim $Text_UnChecked = IniRead($DefaultLanguagePath, 'GuiText', 'UnChecked', 'UnChecked')
Dim $Text_Unknown = IniRead($DefaultLanguagePath, 'GuiText', 'Unknown', 'Unknown')
Dim $Text_Restart = IniRead($DefaultLanguagePath, 'GuiText', 'Restart', 'Restart')
Dim $Text_RestartMsg = IniRead($DefaultLanguagePath, 'GuiText', 'RestartMsg', 'Please restart Vistumbler for language change to take effect')
Dim $Text_Error = IniRead($DefaultLanguagePath, 'GuiText', 'Error', 'Error')
Dim $Text_NoSignalHistory = IniRead($DefaultLanguagePath, 'GuiText', 'NoSignalHistory', 'No signal history found, check to make sure your netsh search words are correct')
Dim $Text_NoApSelected = IniRead($DefaultLanguagePath, 'GuiText', 'NoApSelected', 'You did not select an access point')
Dim $Text_UseNetcomm = IniRead($DefaultLanguagePath, 'GuiText', 'UseNetcomm', 'Use Netcomm OCX (more stable) - x32')
Dim $Text_UseCommMG = IniRead($DefaultLanguagePath, 'GuiText', 'UseCommMG', 'Use CommMG (less stable) - x32 - x64')
Dim $Text_SignalHistory = IniRead($DefaultLanguagePath, 'GuiText', 'SignalHistory', 'Signal History')
Dim $Text_AutoSortEvery = IniRead($DefaultLanguagePath, 'GuiText', 'AutoSortEvery', 'Auto Sort Every')
Dim $Text_Seconds = IniRead($DefaultLanguagePath, 'GuiText', 'Seconds', 'Seconds')
Dim $Text_Ascending = IniRead($DefaultLanguagePath, 'GuiText', 'Ascending', 'Ascending')
Dim $Text_Decending = IniRead($DefaultLanguagePath, 'GuiText', 'Decending', 'Decending')
Dim $Text_AutoRecoveryVS1 = IniRead($DefaultLanguagePath, 'GuiText', 'AutoRecoveryVS1', 'Auto Recovery VS1')
Dim $Text_AutoSaveAndClear = IniRead($DefaultLanguagePath, 'GuiText', 'AutoSaveAndClear', 'Auto Save And Clear')
Dim $Text_AutoSaveEvery = IniRead($DefaultLanguagePath, 'GuiText', 'AutoSaveEvery', 'Auto Save Every')
Dim $Text_DelAutoSaveOnExit = IniRead($DefaultLanguagePath, 'GuiText', 'DelAutoSaveOnExit', 'Delete Auto Save file on exit')
Dim $Text_OpenSaveFolder = IniRead($DefaultLanguagePath, 'GuiText', 'OpenSaveFolder', 'Open Save Folder')
Dim $Text_SortBy = IniRead($DefaultLanguagePath, 'GuiText', 'SortBy', 'Sort By')
Dim $Text_SortDirection = IniRead($DefaultLanguagePath, 'GuiText', 'SortDirection', 'Sort Direction')
Dim $Text_Auto = IniRead($DefaultLanguagePath, 'GuiText', 'Auto', 'Auto')
Dim $Text_Misc = IniRead($DefaultLanguagePath, 'GuiText', 'Misc', 'Misc')
Dim $Text_Gps = IniRead($DefaultLanguagePath, 'GuiText', 'GPS', 'GPS')
Dim $Text_Labels = IniRead($DefaultLanguagePath, 'GuiText', 'Labels', 'Labels')
Dim $Text_Manufacturers = IniRead($DefaultLanguagePath, 'GuiText', 'Manufacturers', 'Manufacturers')
Dim $Text_Columns = IniRead($DefaultLanguagePath, 'GuiText', 'Columns', 'Columns')
Dim $Text_Language = IniRead($DefaultLanguagePath, 'GuiText', 'Language', 'Language')
Dim $Text_SearchWords = IniRead($DefaultLanguagePath, 'GuiText', 'SearchWords', 'SearchWords')
Dim $Text_VistumblerSettings = IniRead($DefaultLanguagePath, 'GuiText', 'VistumblerSettings', 'Vistumbler Settings')
Dim $Text_LanguageAuthor = IniRead($DefaultLanguagePath, 'GuiText', 'LanguageAuthor', 'Language Author')
Dim $Text_LanguageDate = IniRead($DefaultLanguagePath, 'GuiText', 'LanguageDate', 'Language Date')
Dim $Text_LanguageDescription = IniRead($DefaultLanguagePath, 'GuiText', 'LanguageDescription', 'Language Description')
Dim $Text_Description = IniRead($DefaultLanguagePath, 'GuiText', 'Description', 'Description')
Dim $Text_Progress = IniRead($DefaultLanguagePath, 'GuiText', 'Progress', 'Progress')
Dim $Text_LinesMin = IniRead($DefaultLanguagePath, 'GuiText', 'LinesMin', 'Lines/Min')
Dim $Text_NewAPs = IniRead($DefaultLanguagePath, 'GuiText', 'NewAPs', 'New APs')
Dim $Text_NewGIDs = IniRead($DefaultLanguagePath, 'GuiText', 'NewGIDs', 'New GIDs')
Dim $Text_Minutes = IniRead($DefaultLanguagePath, 'GuiText', 'Minutes', 'Minutes')
Dim $Text_LineTotal = IniRead($DefaultLanguagePath, 'GuiText', 'LineTotal', 'Line/Total')
Dim $Text_EstimatedTimeRemaining = IniRead($DefaultLanguagePath, 'GuiText', 'EstimatedTimeRemaining', 'Estimated Time Remaining')
Dim $Text_Ready = IniRead($DefaultLanguagePath, 'GuiText', 'Ready', 'Ready')
Dim $Text_Done = IniRead($DefaultLanguagePath, 'GuiText', 'Done', 'Done')
Dim $Text_VistumblerSaveDirectory = IniRead($DefaultLanguagePath, 'GuiText', 'VistumblerSaveDirectory', 'Vistumbler Save Directory')
Dim $Text_VistumblerAutoSaveDirectory = IniRead($DefaultLanguagePath, 'GuiText', 'VistumblerAutoSaveDirectory', 'Vistumbler Auto Save Directory')
Dim $Text_VistumblerKmlSaveDirectory = IniRead($DefaultLanguagePath, 'GuiText', 'VistumblerKmlSaveDirectory', 'Vistumbler KML Save Directory')
Dim $Text_BackgroundColor = IniRead($DefaultLanguagePath, 'GuiText', 'BackgroundColor', 'Background Color')
Dim $Text_ControlColor = IniRead($DefaultLanguagePath, 'GuiText', 'ControlColor', 'Control Color')
Dim $Text_BgFontColor = IniRead($DefaultLanguagePath, 'GuiText', 'BgFontColor', 'Font Color')
Dim $Text_ConFontColor = IniRead($DefaultLanguagePath, 'GuiText', 'ConFontColor', 'Control Font Color')
Dim $Text_NetshMsg = IniRead($DefaultLanguagePath, 'GuiText', 'NetshMsg', 'This section allows you to change the words Vistumbler uses to search netsh. Change to the proper words for you version of windows. Run "netsh wlan show networks mode = bssid" to find the proper words.')
Dim $Text_PHPgraphing = IniRead($DefaultLanguagePath, 'GuiText', 'PHPgraphing', 'PHP Graphing')
Dim $Text_ComInterface = IniRead($DefaultLanguagePath, 'GuiText', 'ComInterface', 'Com Interface')
Dim $Text_ComSettings = IniRead($DefaultLanguagePath, 'GuiText', 'ComSettings', 'Com Settings')
Dim $Text_Com = IniRead($DefaultLanguagePath, 'GuiText', 'Com', 'Com')
Dim $Text_Baud = IniRead($DefaultLanguagePath, 'GuiText', 'Baud', 'Baud')
Dim $Text_GPSFormat = IniRead($DefaultLanguagePath, 'GuiText', 'GPSFormat', 'GPS Format')
Dim $Text_HideOtherGpsColumns = IniRead($DefaultLanguagePath, 'GuiText', 'HideOtherGpsColumns', 'Hide Other GPS Columns')
Dim $Text_ImportLanguageFile = IniRead($DefaultLanguagePath, 'GuiText', 'ImportLanguageFile', 'Import Language File')
Dim $Text_ExportSettings = IniRead($DefaultLanguagePath, 'GuiText', 'ExportSettings', 'Export Settings')
Dim $Text_ImportSettings = IniRead($DefaultLanguagePath, 'GuiText', 'ImportSettings', 'Import Settings')
Dim $Text_AutoKml = IniRead($DefaultLanguagePath, 'GuiText', 'AutoKml', 'Auto KML')
Dim $Text_GoogleEarthEXE = IniRead($DefaultLanguagePath, 'GuiText', 'GoogleEarthEXE', 'Google Earth EXE')
Dim $Text_AutoSaveKmlEvery = IniRead($DefaultLanguagePath, 'GuiText', 'AutoSaveKmlEvery', 'Auto Save KML Every')
Dim $Text_SavedAs = IniRead($DefaultLanguagePath, 'GuiText', 'SavedAs', 'Saved As')
Dim $Text_Overwrite = IniRead($DefaultLanguagePath, 'GuiText', 'Overwrite', 'Overwrite')
Dim $Text_InstallNetcommOCX = IniRead($DefaultLanguagePath, 'GuiText', 'InstallNetcommOCX', 'Install Netcomm OCX')
Dim $Text_NoFileSaved = IniRead($DefaultLanguagePath, 'GuiText', 'NoFileSaved', 'No file has been saved')
Dim $Text_NoApsWithGps = IniRead($DefaultLanguagePath, 'GuiText', 'NoApsWithGps', 'No access points found with gps coordinates.')
Dim $Text_NoAps = IniRead($DefaultLanguagePath, 'GuiText', 'NoAps', 'No access points.')
Dim $Text_MacExistsOverwriteIt = IniRead($DefaultLanguagePath, 'GuiText', 'MacExistsOverwriteIt', 'A entry for this mac address already exists. would you like to overwrite it?')
Dim $Text_SavingLine = IniRead($DefaultLanguagePath, 'GuiText', 'SavingLine', 'Saving Line')
Dim $Text_Debug = IniRead($DefaultLanguagePath, 'GuiText', 'Debug', 'Debug')
Dim $Text_DisplayDebug = IniRead($DefaultLanguagePath, 'GuiText', 'DisplayDebug', 'Display Functions')
Dim $Text_DisplayComErrors = IniRead($DefaultLanguagePath, 'GuiText', 'DisplayDebugCom', 'Display COM Errors')
Dim $Text_GraphDeadTime = IniRead($DefaultLanguagePath, 'GuiText', 'GraphDeadTime', 'Graph Dead Time')
Dim $Text_OpenKmlNetLink = IniRead($DefaultLanguagePath, 'GuiText', 'OpenKmlNetLink', 'Open KML NetworkLink')
Dim $Text_ActiveRefreshTime = IniRead($DefaultLanguagePath, 'GuiText', 'ActiveRefreshTime', 'Active Refresh Time')
Dim $Text_DeadRefreshTime = IniRead($DefaultLanguagePath, 'GuiText', 'DeadRefreshTime', 'Dead Refresh Time')
Dim $Text_GpsRefrshTime = IniRead($DefaultLanguagePath, 'GuiText', 'GpsRefrshTime', 'Gps Refrsh Time')
Dim $Text_FlyToSettings = IniRead($DefaultLanguagePath, 'GuiText', 'FlyToSettings', 'Fly To Settings')
Dim $Text_FlyToCurrentGps = IniRead($DefaultLanguagePath, 'GuiText', 'FlyToCurrentGps', 'Fly to current gps position')
Dim $Text_AltitudeMode = IniRead($DefaultLanguagePath, 'GuiText', 'AltitudeMode', 'Altitude Mode')
Dim $Text_Range = IniRead($DefaultLanguagePath, 'GuiText', 'Range', 'Range')
Dim $Text_Heading = IniRead($DefaultLanguagePath, 'GuiText', 'Heading', 'Heading')
Dim $Text_Tilt = IniRead($DefaultLanguagePath, 'GuiText', 'Tilt', 'Tilt')
Dim $Text_AutoOpenNetworkLink = IniRead($DefaultLanguagePath, 'GuiText', 'AutoOpenNetworkLink', 'Automatically Open KML Network Link')
Dim $Text_SpeakSignal = IniRead($DefaultLanguagePath, 'GuiText', 'SpeakSignal', 'Speak Signal')
Dim $Text_SpeakUseVisSounds = IniRead($DefaultLanguagePath, 'GuiText', 'SpeakUseVisSounds', 'Use Vistumbler Sound Files')
Dim $Text_SpeakUseSapi = IniRead($DefaultLanguagePath, 'GuiText', 'SpeakUseSapi', 'Use Microsoft Sound API')
Dim $Text_SpeakSayPercent = IniRead($DefaultLanguagePath, 'GuiText', 'SpeakSayPercent', 'Say "Percent" after signal')
Dim $Text_GpsTrackTime = IniRead($DefaultLanguagePath, 'GuiText', 'GpsTrackTime', 'Track Refresh Time')
Dim $Text_SaveAllGpsData = IniRead($DefaultLanguagePath, 'GuiText', 'SaveAllGpsData', 'Save GPS data when no APs are active')
Dim $Text_None = IniRead($DefaultLanguagePath, 'GuiText', 'None', 'None')
Dim $Text_Even = IniRead($DefaultLanguagePath, 'GuiText', 'Even', 'Even')
Dim $Text_Odd = IniRead($DefaultLanguagePath, 'GuiText', 'Odd', 'Odd')
Dim $Text_Mark = IniRead($DefaultLanguagePath, 'GuiText', 'Mark', 'Mark')
Dim $Text_Space = IniRead($DefaultLanguagePath, 'GuiText', 'Space', 'Space')
Dim $Text_StopBit = IniRead($DefaultLanguagePath, 'GuiText', 'StopBit', 'Stop Bit')
Dim $Text_Parity = IniRead($DefaultLanguagePath, 'GuiText', 'Parity', 'Parity')
Dim $Text_DataBit = IniRead($DefaultLanguagePath, 'GuiText', 'DataBit', 'Data Bit')
Dim $Text_Update = IniRead($DefaultLanguagePath, 'GuiText', 'Update', 'Update')
Dim $Text_UpdateMsg = IniRead($DefaultLanguagePath, 'GuiText', 'UpdateMsg', 'Update Found. Would you like to update vistumbler?')
Dim $Text_Recover = IniRead($DefaultLanguagePath, 'GuiText', 'Recover', 'Recover')
Dim $Text_RecoverMsg = IniRead($DefaultLanguagePath, 'GuiText', 'RecoverMsg', 'Old DB Found. Would you like to recover it?')
Dim $Text_SelectConnectedAP = IniRead($DefaultLanguagePath, 'GuiText', 'SelectConnectedAP', 'Select Connected AP')
Dim $Text_VistumblerHome = IniRead($DefaultLanguagePath, 'GuiText', 'VistumblerHome', 'Vistumbler Home')
Dim $Text_VistumblerForum = IniRead($DefaultLanguagePath, 'GuiText', 'VistumblerForum', 'Vistumbler Forum')
Dim $Text_VistumblerWiki = IniRead($DefaultLanguagePath, 'GuiText', 'VistumblerWiki', 'Vistumbler Wiki')
Dim $Text_CheckForUpdates = IniRead($DefaultLanguagePath, 'GuiText', 'CheckForUpdates', 'Check For Updates')
Dim $Text_SelectWhatToCopy = IniRead($DefaultLanguagePath, 'GuiText', 'SelectWhatToCopy', 'Select what you want to copy')
Dim $Text_Default = IniRead($DefaultLanguagePath, 'GuiText', 'Default', 'Default')
Dim $Text_PlayMidiSounds = IniRead($DefaultLanguagePath, 'GuiText', 'PlayMidiSounds', 'Play MIDI sounds for all active APs')
Dim $Text_Interface = IniRead($DefaultLanguagePath, 'GuiText', 'Interface', 'Interface')
Dim $Text_LanguageCode = IniRead($DefaultLanguagePath, 'GuiText', 'LanguageCode', 'Language Code')
Dim $Text_AutoCheckUpdates = IniRead($DefaultLanguagePath, 'GuiText', 'AutoCheckUpdates', 'Automatically Check For Updates')
Dim $Text_CheckBetaUpdates = IniRead($DefaultLanguagePath, 'GuiText', 'CheckBetaUpdates', 'Check For Beta Updates')
Dim $Text_GuessSearchwords = IniRead($DefaultLanguagePath, 'GuiText', 'GuessSearchwords', 'Guess Netsh Searchwords')
Dim $Text_Help = IniRead($DefaultLanguagePath, 'GuiText', 'Help', 'Help')
Dim $Text_ErrorScanningNetsh = IniRead($DefaultLanguagePath, 'GuiText', 'ErrorScanningNetsh', 'Error scanning netsh')
Dim $Text_GpsErrorBufferEmpty = IniRead($DefaultLanguagePath, 'GuiText', 'GpsErrorBufferEmpty', 'GPS Error. Buffer Empty for more than 10 seconds. GPS was probrably disconnected. GPS has been stopped')
Dim $Text_GpsErrorStopped = IniRead($DefaultLanguagePath, 'GuiText', 'GpsErrorStopped', 'GPS Error. GPS has been stopped')
Dim $Text_ShowSignalDB = IniRead($DefaultLanguagePath, 'GuiText', 'ShowSignalDB', 'Show Signal dB (Estimated)')
Dim $Text_SortingList = IniRead($DefaultLanguagePath, 'GuiText', 'SortingList', 'Sorting List')
Dim $Text_Loading = IniRead($DefaultLanguagePath, 'GuiText', 'Loading', 'Loading')
Dim $Text_MapOpenNetworks = IniRead($DefaultLanguagePath, 'GuiText', 'MapOpenNetworks', 'Map Open Networks')
Dim $Text_MapWepNetworks = IniRead($DefaultLanguagePath, 'GuiText', 'MapWepNetworks', 'Map WEP Networks')
Dim $Text_MapSecureNetworks = IniRead($DefaultLanguagePath, 'GuiText', 'MapSecureNetworks', 'Map Secure Networks')
Dim $Text_DrawTrack = IniRead($DefaultLanguagePath, 'GuiText', 'DrawTrack', 'Draw Track')
Dim $Text_UseLocalImages = IniRead($DefaultLanguagePath, 'GuiText', 'UseLocalImages', 'Use Local Images')
Dim $Text_MIDI = IniRead($DefaultLanguagePath, 'GuiText', 'MIDI', 'MIDI')
Dim $Text_MidiInstrumentNumber = IniRead($DefaultLanguagePath, 'GuiText', 'MidiInstrumentNumber', 'MIDI Instrument #')
Dim $Text_MidiPlayTime = IniRead($DefaultLanguagePath, 'GuiText', 'MidiPlayTime', 'MIDI Play Time')
Dim $Text_SpeakRefreshTime = IniRead($DefaultLanguagePath, 'GuiText', 'SpeakRefreshTime', 'Speak Refresh Time')
Dim $Text_Information = IniRead($DefaultLanguagePath, 'GuiText', 'Information', 'Information')
Dim $Text_AddedGuessedSearchwords = IniRead($DefaultLanguagePath, 'GuiText', 'AddedGuessedSearchwords', 'Added guessed netsh searchwords. Searchwords for Open, None, WEP, Infrustructure, and Adhoc will still need to be done manually')
Dim $Text_SortingTreeview = IniRead($DefaultLanguagePath, 'GuiText', 'SortingTreeview', 'Sorting Treeview')
Dim $Text_Recovering = IniRead($DefaultLanguagePath, 'GuiText', 'Recovering', 'Recovering')
Dim $Text_ErrorOpeningGpsPort = IniRead($DefaultLanguagePath, 'GuiText', 'ErrorOpeningGpsPort', 'Error opening GPS port')
Dim $Text_SecondsSinceGpsUpdate = IniRead($DefaultLanguagePath, 'GuiText', 'SecondsSinceGpsUpdate', 'Seconds Since GPS Update')
Dim $Text_SavingGID = IniRead($DefaultLanguagePath, 'GuiText', 'SavingGID', 'Saving GID')
Dim $Text_SavingHistID = IniRead($DefaultLanguagePath, 'GuiText', 'SavingHistID', 'Saving HistID')
Dim $Text_NoUpdates = IniRead($DefaultLanguagePath, 'GuiText', 'NoUpdates', 'No Updates Avalible')
Dim $Text_NoActiveApFound = IniRead($DefaultLanguagePath, 'GuiText', 'NoActiveApFound', 'No Active AP found')
Dim $Text_VistumblerDonate = IniRead($DefaultLanguagePath, 'GuiText', 'VistumblerDonate', 'Donate')
Dim $Text_VistumblerStore = IniRead($DefaultLanguagePath, 'GuiText', 'VistumblerStore', 'Store')
Dim $Text_SupportVistumbler = IniRead($DefaultLanguagePath, 'GuiText', 'SupportVistumbler', '*Support Vistumbler*')
Dim $Text_UseNativeWifiMsg = IniRead($DefaultLanguagePath, 'GuiText', 'UseNativeWifiMsg', 'Use Native Wifi')
Dim $Text_UseNativeWifiXpExtMsg = IniRead($DefaultLanguagePath, 'GuiText', 'UseNativeWifiXpExtMsg', '(No BSSID, CHAN, OTX, BTX)')

Dim $Text_FilterMsg = IniRead($DefaultLanguagePath, 'GuiText', 'FilterMsg', 'Use asterik(*) for all. Seperate multiple filters with a comma(,). Use a dash(-) for ranges. Mac address field supports like with percent(%) as a wildcard. SSID field uses backslash(\) to escape control characters.')
Dim $Text_SetFilters = IniRead($DefaultLanguagePath, 'GuiText', 'SetFilters', 'Set Filters')
Dim $Text_Filtered = IniRead($DefaultLanguagePath, 'GuiText', 'Filtered', 'Filtered')
Dim $Text_Filters = IniRead($DefaultLanguagePath, 'GuiText', 'Filters', 'Filters')
Dim $Text_FilterName = IniRead($DefaultLanguagePath, 'GuiText', 'FilterName', 'Filter Name')
Dim $Text_FilterDesc = IniRead($DefaultLanguagePath, 'GuiText', 'FilterDesc', 'Filter Description')
Dim $Text_FilterAddEdit = IniRead($DefaultLanguagePath, 'GuiText', 'FilterAddEdit', 'Add/Edit Filter')
Dim $Text_NoAdaptersFound = IniRead($DefaultLanguagePath, 'GuiText', 'NoAdaptersFound', 'No Adapters Found')
Dim $Text_RecoveringMDB = IniRead($DefaultLanguagePath, 'GuiText', 'RecoveringMDB', 'Recovering MDB')
Dim $Text_FixingGpsTableDates = IniRead($DefaultLanguagePath, 'GuiText', 'FixingGpsTableDates', 'Fixing GPS table date(s)')
Dim $Text_FixingGpsTableTimes = IniRead($DefaultLanguagePath, 'GuiText', 'FixingGpsTableTimes', 'Fixing GPS table times(s)')
Dim $Text_FixingHistTableDates = IniRead($DefaultLanguagePath, 'GuiText', 'FixingHistTableDates', 'Fixing HIST table date(s)')
Dim $Text_VistumblerNeedsToRestart = IniRead($DefaultLanguagePath, 'GuiText', 'VistumblerNeedsToRestart', 'Vistumbler needs to be restarted. Vistumbler will now close')
Dim $Text_AddingApsIntoList = IniRead($DefaultLanguagePath, 'GuiText', 'AddingApsIntoList', 'Adding new APs into list')
Dim $Text_GoogleEarthDoesNotExist = IniRead($DefaultLanguagePath, 'GuiText', 'GoogleEarthDoesNotExist', 'Google earth file does not exist or is set wrong in the AutoKML settings')
Dim $Text_AutoKmlIsNotStarted = IniRead($DefaultLanguagePath, 'GuiText', 'AutoKmlIsNotStarted', 'AutoKML is not yet started. Would you like to turn it on now?')
Dim $Text_UseKernel32 = IniRead($DefaultLanguagePath, 'GuiText', 'UseKernel32', 'Use Kernel32 - x32 - x64')
Dim $Text_UnableToGuessSearchwords = IniRead($DefaultLanguagePath, 'GuiText', 'UnableToGuessSearchwords', 'Vistumbler was unable to guess searchwords')
Dim $Text_SelectedAP = IniRead($DefaultLanguagePath, 'GuiText', 'SelectedAP', 'Selected AP')
Dim $Text_AllAPs = IniRead($DefaultLanguagePath, 'GuiText', 'AllAPs', 'All APs')
Dim $Text_FilteredAPs = IniRead($DefaultLanguagePath, 'GuiText', 'FilteredAPs', 'Filtered APs')
Dim $Text_ImportFolder = IniRead($DefaultLanguagePath, 'GuiText', 'ImportFolder', 'Import Folder')
Dim $Text_DeleteSelected = IniRead($DefaultLanguagePath, 'GuiText', 'DeleteSelected', 'Delete Selected')
Dim $Text_RecoverSelected = IniRead($DefaultLanguagePath, 'GuiText', 'RecoverSelected', 'Recover Selected')
Dim $Text_NewSession = IniRead($DefaultLanguagePath, 'GuiText', 'NewSession', 'New Session')
Dim $Text_Size = IniRead($DefaultLanguagePath, 'GuiText', 'Size', 'Size')
Dim $Text_NoMdbSelected = IniRead($DefaultLanguagePath, 'GuiText', 'NoMdbSelected', 'No MDB Selected')
Dim $Text_LocateInWiFiDB = IniRead($DefaultLanguagePath, 'GuiText', 'LocateInWiFiDB', 'Locate Position in WiFiDB')
Dim $Text_AutoWiFiDbGpsLocate = IniRead($DefaultLanguagePath, 'GuiText', 'AutoWiFiDbGpsLocate', 'Auto WiFiDB Gps Locate')
Dim $Text_AutoWiFiDbUploadAps = IniRead($DefaultLanguagePath, 'GuiText', 'AutoWiFiDbUploadAps', 'Auto WiFiDB Upload Active AP')
Dim $Text_AutoSelectConnectedAP = IniRead($DefaultLanguagePath, 'GuiText', 'AutoSelectConnectedAP', 'Auto Select Connected AP')
Dim $Text_AutoSelectHighSignal = IniRead($DefaultLanguagePath, "GuiText", 'AutoSelectHighSigAP', 'Auto Select Highest Signal AP')
Dim $Text_Experimental = IniRead($DefaultLanguagePath, 'GuiText', 'Experimental', 'Experimental')
Dim $Text_Color = IniRead($DefaultLanguagePath, 'GuiText', 'Color', 'Color')
Dim $Text_AddRemFilters = IniRead($DefaultLanguagePath, "GuiText", "AddRemFilters", "Add/Remove Filters")
Dim $Text_NoFilterSelected = IniRead($DefaultLanguagePath, "GuiText", "NoFilterSelected", "No filter selected.")
Dim $Text_AddFilter = IniRead($DefaultLanguagePath, "GuiText", "AddFilter", "Add Filter")
Dim $Text_EditFilter = IniRead($DefaultLanguagePath, "GuiText", "EditFilter ", "Edit Filter ")
Dim $Text_DeleteFilter = IniRead($DefaultLanguagePath, "GuiText", "DeleteFilter", "Delete Filter")
Dim $Text_TimeBeforeMarkedDead = IniRead($DefaultLanguagePath, "GuiText", "TimeBeforeMarkedDead", "Time to wait before marking AP dead (s)")
Dim $Text_FilterNameRequired = IniRead($DefaultLanguagePath, "GuiText", "FilterNameRequired", "Filter Name is required")
Dim $Text_UpdateManufacturers = IniRead($DefaultLanguagePath, "GuiText", "UpdateManufacturers", "Update Manufacturers")
Dim $Text_FixHistSignals = IniRead($DefaultLanguagePath, "GuiText", "FixHistSignals", "Fixing Missing Hist Table Signal(s)")
Dim $Text_VistumblerFile = IniRead($DefaultLanguagePath, 'GuiText', 'VistumblerFile', 'Vistumbler file')
Dim $Text_DetailedCsvFile = IniRead($DefaultLanguagePath, 'GuiText', 'DetailedFile', 'Detailed Comma Delimited file')
Dim $Text_SummaryCsvFile = IniRead($DefaultLanguagePath, 'GuiText', 'SummaryFile', 'Summary Comma Delimited file')
Dim $Text_NetstumblerTxtFile = IniRead($DefaultLanguagePath, 'GuiText', 'NetstumblerTxtFile', 'Netstumbler wi-scan file')
Dim $Text_WardriveDb3File = IniRead($DefaultLanguagePath, "GuiText", "WardriveDb3File", "Wardrive-android file")
Dim $Text_AutoScanApsOnLaunch = IniRead($DefaultLanguagePath, "GuiText", "AutoScanApsOnLaunch", "Auto Scan APs on launch")
Dim $Text_RefreshInterfaces = IniRead($DefaultLanguagePath, "GuiText", "RefreshInterfaces", "Refresh Interfaces")
Dim $Text_Sound = IniRead($DefaultLanguagePath, 'GuiText', 'Sound', 'Sound')
Dim $Text_OncePerLoop = IniRead($DefaultLanguagePath, 'GuiText', 'OncePerLoop', 'Once per loop')
Dim $Text_OncePerAP = IniRead($DefaultLanguagePath, 'GuiText', 'OncePerAP', 'Once per ap')
Dim $Text_OncePerAPwSound = IniRead($DefaultLanguagePath, 'GuiText', 'OncePerAPwSound', 'Once per ap with volume based on signal')
Dim $Text_WifiDB = IniRead($DefaultLanguagePath, 'GuiText', 'WifiDB', 'WifiDB')
Dim $Text_Warning = IniRead($DefaultLanguagePath, 'GuiText', 'Warning', 'Warning')
Dim $Text_WifiDBLocateWarning = IniRead($DefaultLanguagePath, 'GuiText', 'WifiDBLocateWarning', 'This feature sends active access point information to the WifiDB API URL specified in the Vistumbler WifiDB Settings. If you do not want to send data to the wifidb, do not enable this feature. Do you want to continue to enable this feature?')
Dim $Text_WifiDBAutoUploadWarning = IniRead($DefaultLanguagePath, 'GuiText', 'WifiDBAutoUploadWarning', 'This feature sends active access point information to the WifiDB API URL specified in the Vistumbler WifiDB Settings. If you do not want to send data to the wifidb, do not enable this feature. Do you want to continue to enable this feature?')
Dim $Text_WifiDBOpenLiveAPWebpage = IniRead($DefaultLanguagePath, 'GuiText', 'WifiDBOpenLiveAPWebpage', 'Open WifiDB Live AP Webpage')
Dim $Text_WifiDBOpenMainWebpage = IniRead($DefaultLanguagePath, 'GuiText', 'WifiDBOpenMainWebpage', 'Open WifiDB Main Webpage')
Dim $Text_FilePath = IniRead($DefaultLanguagePath, 'GuiText', 'FilePath', 'File Path')
Dim $Text_CameraName = IniRead($DefaultLanguagePath, 'GuiText', 'CameraName', 'Camera Name')
Dim $Text_CameraURL = IniRead($DefaultLanguagePath, 'GuiText', 'CameraURL', 'Camera URL')
Dim $Text_Cameras = IniRead($DefaultLanguagePath, 'GuiText', 'Cameras', 'Camera(s)')
Dim $Text_AddCamera = IniRead($DefaultLanguagePath, 'GuiText', 'AddCamera', 'Add Camera')
Dim $Text_RemoveCamera = IniRead($DefaultLanguagePath, 'GuiText', 'RemoveCamera', 'Remove Camera')
Dim $Text_EditCamera = IniRead($DefaultLanguagePath, 'GuiText', 'EditCamera', 'Edit Camera')
Dim $Text_DownloadImages = IniRead($DefaultLanguagePath, 'GuiText', 'DownloadImages', 'Download Images')
Dim $Text_EnableCamTriggerScript = IniRead($DefaultLanguagePath, 'GuiText', 'EnableCamTriggerScript', 'Enable camera trigger script')
Dim $Text_CameraTriggerScript = IniRead($DefaultLanguagePath, 'GuiText', 'CameraTriggerScript', 'Camera Trigger Script')
Dim $Text_CameraTriggerScriptTypes = IniRead($DefaultLanguagePath, 'GuiText', 'CameraTriggerScriptTypes', 'Camera Trigger Script (exe,bat)')
Dim $Text_SetCameras = IniRead($DefaultLanguagePath, 'GuiText', 'SetCameras', 'Set Cameras')
Dim $Text_UpdateUpdaterMsg = IniRead($DefaultLanguagePath, 'GuiText', 'UpdateUpdaterMsg', 'There is an update to the vistumbler updater. Would you like to download and update it now?')
Dim $Text_UseRssiInGraphs = IniRead($DefaultLanguagePath, 'GuiText', 'UseRssiInGraphs', 'Use RSSI in graphs')
Dim $Text_2400ChannelGraph = IniRead($DefaultLanguagePath, 'GuiText', '2400ChannelGraph', '2.4Ghz Channel Graph')
Dim $Text_5000ChannelGraph = IniRead($DefaultLanguagePath, 'GuiText', '5000ChannelGraph', '5Ghz Channel Graph')
Dim $Text_UpdateGeolocations = IniRead($DefaultLanguagePath, 'GuiText', 'UpdateGeolocations', 'Update Geolocations')
Dim $Text_ShowGpsPositionMap = IniRead($DefaultLanguagePath, 'GuiText', 'ShowGpsPositionMap', 'Show GPS Position Map')
Dim $Text_ShowGpsSignalMap = IniRead($DefaultLanguagePath, 'GuiText', 'ShowGpsSignalMap', 'Show GPS Signal Map')
Dim $Text_UseRssiSignalValue = IniRead($DefaultLanguagePath, 'GuiText', 'UseRssiSignalValue', 'Use RSSI signal values')
Dim $Text_UseCircleToShowSigStength = IniRead($DefaultLanguagePath, 'GuiText', 'UseCircleToShowSigStength', 'Use circle to show signal strength')
Dim $Text_ShowGpsRangeMap = IniRead($DefaultLanguagePath, 'GuiText', 'ShowGpsRangeMap', 'Show GPS Range Map')
Dim $Text_ShowGpsTack = IniRead($DefaultLanguagePath, 'GuiText', 'ShowGpsTack', 'Show GPS Track')
Dim $Text_Line = IniRead($DefaultLanguagePath, 'GuiText', 'Line', 'Line')
Dim $Text_Total = IniRead($DefaultLanguagePath, 'GuiText', 'Total', 'Total')
Dim $Text_WifiDB_Upload_Discliamer = IniRead($DefaultLanguagePath, 'GuiText', 'WifiDB_Upload_Discliamer', 'This feature uploads access points to the WifiDB. a file will be generated and uploaded to the WifiDB API URL specified in the Vistumbler WifiDB Settings.')
Dim $Text_UserInformation = IniRead($DefaultLanguagePath, 'GuiText', 'UserInformation', 'User Information')
Dim $Text_WifiDB_Username = IniRead($DefaultLanguagePath, 'GuiText', 'WifiDB_Username', 'WifiDB Username')
Dim $Text_WifiDB_Api_Key = IniRead($DefaultLanguagePath, 'GuiText', 'WifiDB_Api_Key', 'WifiDB Api Key')
Dim $Text_OtherUsers = IniRead($DefaultLanguagePath, 'GuiText', 'OtherUsers', 'Other users')
Dim $Text_FileType = IniRead($DefaultLanguagePath, 'GuiText', 'FileType', 'File Type')
Dim $Text_VistumblerVSZ = IniRead($DefaultLanguagePath, 'GuiText', 'VistumblerVSZ', 'Vistumbler VSZ')
Dim $Text_VistumblerVS1 = IniRead($DefaultLanguagePath, 'GuiText', 'VistumblerVS1', 'Vistumbler VS1')
Dim $Text_VistumblerCSV = IniRead($DefaultLanguagePath, 'GuiText', 'VistumblerCSV', 'Vistumbler Detailed CSV')
Dim $Text_UploadInformation = IniRead($DefaultLanguagePath, 'GuiText', 'UploadInformation', 'Upload Information')
Dim $Text_Title = IniRead($DefaultLanguagePath, 'GuiText', 'Title', 'Title')
Dim $Text_Notes = IniRead($DefaultLanguagePath, 'GuiText', 'Notes', 'Notes')
Dim $Text_UploadApsToWifidb = IniRead($DefaultLanguagePath, 'GuiText', 'UploadApsToWifidb', 'Upload APs to WifiDB')
Dim $Text_UploadingApsToWifidb = IniRead($DefaultLanguagePath, 'GuiText', 'UploadingApsToWifidb', 'Uploading APs to WifiDB')
Dim $Text_GeoNamesInfo = IniRead($DefaultLanguagePath, 'GuiText', 'GeoNamesInfo', 'Geonames Info')
Dim $Text_FindApInWifidb = IniRead($DefaultLanguagePath, 'GuiText', 'FindApInWifidb', 'Find AP in WifiDB')
Dim $Text_GpsDisconnect = IniRead($DefaultLanguagePath, 'GuiText', 'GpsDisconnect', 'Disconnect GPS when no data is recieved in over 10 seconds')
Dim $Text_GpsReset = IniRead($DefaultLanguagePath, 'GuiText', 'GpsReset', 'Reset GPS position when no GPGGA data is recived in over 30 seconds')
Dim $Text_APs = IniRead($DefaultLanguagePath, 'GuiText', 'APs', 'APs')
Dim $Text_MaxSignal = IniRead($DefaultLanguagePath, 'GuiText', 'MaxSignal', 'Max Signal')
Dim $Text_DisassociationSignal = IniRead($DefaultLanguagePath, 'GuiText', 'DisassociationSignal', 'Disassociation Signal')
Dim $Text_SaveDirectories = IniRead($DefaultLanguagePath, 'GuiText', 'SaveDirectories', 'Save Directories')
Dim $Text_AutoSaveAndClearAfterNumberofAPs = IniRead($DefaultLanguagePath, 'GuiText', 'AutoSaveAndClearAfterNumberofAPs', 'Auto Save And Clear After Number of APs')
Dim $Text_AutoSaveandClearAfterTime = IniRead($DefaultLanguagePath, 'GuiText', 'AutoSaveandClearAfterTime', 'Auto Save and Clear After Time')
Dim $Text_PlaySoundWhenSaving = IniRead($DefaultLanguagePath, 'GuiText', 'PlaySoundWhenSaving', 'Play Sound When Saving')
Dim $Text_MinimalGuiMode = IniRead($DefaultLanguagePath, 'GuiText', 'MinimalGuiMode', 'Minimal GUI Mode')
Dim $Text_AutoScrollToBottom = IniRead($DefaultLanguagePath, 'GuiText', 'AutoScrollToBottom', 'Auto Scroll to Bottom of List')
Dim $Text_ListviewBatchInsertMode = IniRead($DefaultLanguagePath, 'GuiText', 'ListviewBatchInsertMode', 'Listview Batch Insert Mode')

If $AutoCheckForUpdates = 1 Then
	If _CheckForUpdates() = 1 Then
		$updatemsg = MsgBox(4, $Text_Update, $Text_UpdateMsg)
		If $updatemsg = 6 Then _StartUpdate()
	EndIf
EndIf

Dim $MDBfiles[1][4]
$MDBfiles[0][0] = 0
;Add MDB Files from temp dir
$tempMDB = _FileListToArray($TmpDir, '*.MDB', 1);Find all files in the folder that end in .MDB
If IsArray($tempMDB) Then
	For $af = 1 To $tempMDB[0]
		$mdbfile = $tempMDB[$af]
		If _FileInUse($TmpDir & $mdbfile) = 0 Then
			ReDim $MDBfiles[UBound($MDBfiles) + 1][4]
			$ArraySize = UBound($MDBfiles) - 1
			$MDBfiles[0][0] = $ArraySize;Array Size
			$MDBfiles[$ArraySize][0] = $ArraySize;ID
			$MDBfiles[$ArraySize][1] = $mdbfile;File Name
			$MDBfiles[$ArraySize][2] = $TmpDir & $mdbfile;File Path
			$MDBfiles[$ArraySize][3] = (FileGetSize($TmpDir & $mdbfile) / 1024) & 'kb'
		EndIf
	Next
EndIf
;Add MDB Files from save dir
$saveMDB = _FileListToArray($SaveDir, '*.MDB', 1);Find all files in the folder that end in .MDB
If IsArray($saveMDB) Then
	For $af = 1 To $saveMDB[0]
		$mdbfile = $saveMDB[$af]
		If _FileInUse($SaveDir & $mdbfile) = 0 Then
			ReDim $MDBfiles[UBound($MDBfiles) + 1][4]
			$ArraySize = UBound($MDBfiles) - 1
			$MDBfiles[0][0] = $ArraySize;Array Size
			$MDBfiles[$ArraySize][0] = $ArraySize;ID
			$MDBfiles[$ArraySize][1] = $mdbfile;File Name
			$MDBfiles[$ArraySize][2] = $SaveDir & $mdbfile;File Path
			$MDBfiles[$ArraySize][3] = (FileGetSize($SaveDir & $mdbfile) / 1024) & 'kb'
		EndIf
	Next
EndIf
;Show MDB Recover GUI if MDB files exist
If $MDBfiles[0][0] > 0 Then
	Opt("GUIOnEventMode", 0)
	$FoundMdbFile = 0
	$RecoverMdbGui = GUICreate($Text_RecoverMsg, 461, 210, -1, -1, BitOR($WS_OVERLAPPEDWINDOW, $WS_CLIPSIBLINGS))
	GUISetBkColor($BackgroundColor)
	$Recover_Del = GUICtrlCreateButton($Text_DeleteSelected, 10, 150, 215, 25)
	$Recover_Rec = GUICtrlCreateButton($Text_RecoverSelected, 235, 150, 215, 25)
	$Recover_Exit = GUICtrlCreateButton($Text_Exit, 10, 180, 215, 25)
	$Recover_New = GUICtrlCreateButton($Text_NewSession, 235, 180, 215, 25)
	$Recover_List = GUICtrlCreateListView(StringReplace($Text_File, '&', '') & "|" & $Text_Size & "|" & $Text_FilePath, 10, 8, 440, 136, $LVS_REPORT + $LVS_SINGLESEL, $LVS_EX_HEADERDRAGDROP + $LVS_EX_GRIDLINES + $LVS_EX_FULLROWSELECT)
	_GUICtrlListView_SetColumnWidth($Recover_List, 0, 335)
	_GUICtrlListView_SetColumnWidth($Recover_List, 1, 100)
	_GUICtrlListView_SetColumnWidth($Recover_List, 2, 600)
	GUICtrlSetBkColor(-1, $ControlBackgroundColor)
	For $FoundMDB = 1 To $MDBfiles[0][0]
		$mdbfile = $MDBfiles[$FoundMDB][1]
		$mdbpath = $MDBfiles[$FoundMDB][2]
		$mdbsize = $MDBfiles[$FoundMDB][3]
		$ListRow = _GUICtrlListView_InsertItem($Recover_List, "", 0)
		_GUICtrlListView_SetItemText($Recover_List, $ListRow, $mdbfile, 0)
		_GUICtrlListView_SetItemText($Recover_List, $ListRow, $mdbsize, 1)
		_GUICtrlListView_SetItemText($Recover_List, $ListRow, $mdbpath, 2)
	Next
	GUISetState(@SW_SHOW)
	While 1
		$nMsg = GUIGetMsg()
		Switch $nMsg
			Case $GUI_EVENT_CLOSE
				$VistumblerDB = $TmpDir & $ldatetimestamp & '.mdb'
				$VistumblerDbName = $ldatetimestamp & '.mdb'
				$VistumblerCamFolder = $TmpDir & $ldatetimestamp & '\'
				ExitLoop
			Case $Recover_New
				$VistumblerDB = $TmpDir & $ldatetimestamp & '.mdb'
				$VistumblerDbName = $ldatetimestamp & '.mdb'
				$VistumblerCamFolder = $TmpDir & $ldatetimestamp & '\'
				ExitLoop
			Case $Recover_Exit
				Exit
			Case $Recover_Rec
				$Selected = _GUICtrlListView_GetNextItem($Recover_List); find what AP is selected in the list. returns -1 is nothing is selected
				If $Selected = '-1' Then
					MsgBox(0, $Text_Error, $Text_NoMdbSelected)
				Else
					$VistumblerDbName = _GUICtrlListView_GetItemText($Recover_List, $Selected, 0)
					$VistumblerDB = _GUICtrlListView_GetItemText($Recover_List, $Selected, 2)
					$VistumblerCamFolder = StringTrimRight($VistumblerDB, 4) & '\'
					;If this MDB/ZIP is not in the temp folder, move it there and rename it
					$mdbfolder = StringTrimRight($VistumblerDB, (StringLen($VistumblerDB) - StringInStr($VistumblerDB, "\", 1, -1)))
					If $mdbfolder <> $TmpDir Then
						$OldVistumblerDB = $VistumblerDB
						$VistumblerDB = _TempFile($TmpDir, StringTrimRight($VistumblerDbName, 4) & "__", ".mdb", 4)
						$VistumblerDbName = StringTrimLeft($VistumblerDB, StringInStr($VistumblerDB, "\", 1, -1))
						FileCopy($OldVistumblerDB, $VistumblerDB, 9)
						$OldVistumblerCamFolder = StringTrimRight($OldVistumblerDB, 4) & '\'
						$VistumblerCamFolder = StringTrimRight($VistumblerDB, 4) & '\'
						DirCopy($OldVistumblerCamFolder, $VistumblerCamFolder, 1)
					EndIf
					ExitLoop
				EndIf
			Case $Recover_Del
				$Selected = _GUICtrlListView_GetNextItem($Recover_List); find what AP is selected in the list. returns -1 is nothing is selected
				If $Selected = '-1' Then
					MsgBox(0, $Text_Error, $Text_NoMdbSelected)
				Else
					$db_fullpath = _GUICtrlListView_GetItemText($Recover_List, $Selected, 2)
					FileDelete($db_fullpath)
					$folder_fullpath = StringTrimRight($db_fullpath, 4) & '\'
					DirRemove($folder_fullpath, 1)
					_GUICtrlListView_DeleteItem(GUICtrlGetHandle($Recover_List), $Selected)
				EndIf
		EndSwitch
	WEnd
	GUIDelete($RecoverMdbGui)
	Opt("GUIOnEventMode", 1)
Else
	$VistumblerDB = $TmpDir & $ldatetimestamp & '.mdb'
	$VistumblerDbName = $ldatetimestamp & '.mdb'
	$VistumblerCamFolder = $TmpDir & $ldatetimestamp & '\'
EndIf

;ConsoleWrite($VistumblerDB & @CRLF)
;ConsoleWrite($VistumblerCamFolder & @CRLF)


If FileExists($VistumblerDB) Then
	_AccessConnectConn($VistumblerDB, $DB_OBJ)
	$Recover = 1
Else
	_SetUpDbTables($VistumblerDB)
EndIf

If Not FileExists($VistumblerCamFolder) Then
	DirCreate($VistumblerCamFolder)
EndIf

;Connect to manufacturer database
If FileExists($ManuDB) Then
	_AccessConnectConn($ManuDB, $ManuDB_OBJ)
Else
	_CreateDB($ManuDB)
	_AccessConnectConn($ManuDB, $ManuDB_OBJ)
	_CreateTable($ManuDB, 'Manufacturers', $ManuDB_OBJ)
	_CreatMultipleFields($ManuDB, 'Manufacturers', $ManuDB_OBJ, 'BSSID TEXT(6)|Manufacturer TEXT(255)')
EndIf
;Connect to label database
If FileExists($LabDB) Then
	_AccessConnectConn($LabDB, $LabDB_OBJ)
Else
	_CreateDB($LabDB)
	_AccessConnectConn($LabDB, $LabDB_OBJ)
	_CreateTable($LabDB, 'Labels', $LabDB_OBJ)
	_CreatMultipleFields($LabDB, 'Labels', $LabDB_OBJ, 'BSSID TEXT(12)|Label TEXT(255)')
EndIf
;Connect to camera database
If FileExists($CamDB) Then
	_AccessConnectConn($CamDB, $CamDB_OBJ)
Else
	_CreateDB($CamDB)
	_AccessConnectConn($CamDB, $CamDB_OBJ)
	_CreateTable($CamDB, 'Cameras', $CamDB_OBJ)
	_CreatMultipleFields($CamDB, 'Cameras', $CamDB_OBJ, 'CamName TEXT(255)|CamUrl TEXT(255)')

	$query = "SELECT CamName, CamUrl FROM Cameras"
EndIf
;Connect to Instrument database
If FileExists($InstDB) Then
	_AccessConnectConn($InstDB, $InstDB_OBJ)
Else
	_CreateDB($InstDB)
	_AccessConnectConn($InstDB, $InstDB_OBJ)
	_CreateTable($InstDB, 'Instruments', $InstDB_OBJ)
	_CreatMultipleFields($InstDB, 'Instruments', $InstDB_OBJ, 'INSTNUM TEXT(3)|INSTTEXT TEXT(255)')
EndIf
;Connect to Filter database
If FileExists($FiltDB) Then
	_AccessConnectConn($FiltDB, $FiltDB_OBJ)
	$query = "SELECT FiltID FROM Filters"
	$FiltMatchArray = _RecordSearch($FiltDB, $query, $FiltDB_OBJ)
	$FiltID = UBound($FiltMatchArray) - 1
Else
	_CreateDB($FiltDB)
	_AccessConnectConn($FiltDB, $FiltDB_OBJ)
	_CreateTable($FiltDB, 'Filters', $FiltDB_OBJ)
	_CreatMultipleFields($FiltDB, 'Filters', $FiltDB_OBJ, 'FiltID TEXT(255)|FiltName TEXT(255)|FiltDesc TEXT(255)|SSID TEXT(255)|BSSID TEXT(255)|CHAN TEXT(255)|AUTH TEXT(255)|ENCR TEXT(255)|RADTYPE TEXT(255)|NETTYPE TEXT(255)|Signal TEXT(255)|HighSig TEXT(255)|RSSI TEXT(255)|HighRSSI TEXT(255)|BTX TEXT(255)|OTX TEXT(255)|ApID |Active TEXT(255)')
	$FiltID = 0
EndIf

$var = IniReadSection($settings, "Columns")
If @error Then
	$headers = '#|Active|Mac Address|SSID|Signal|High Signal|RSSI|High RSSI|Channel|Authentication|Encryption|Network Type|Latitude|Longitude|Manufacturer|Label|Radio Type|Lat (dd mm ss)|Lon (dd mm ss)|Lat (ddmm.mmmm)|Lon (ddmm.mmmm)|Basic Transfer Rates|Other Transfer Rates|First Active|Last Updated'
Else
	For $a = 0 To ($var[0][0] - 1)
		For $b = 1 To $var[0][0]
			If $a = $var[$b][1] Then $headers &= IniRead($DefaultLanguagePath, 'Column_Names', $var[$b][0], IniRead($settings, 'Column_Names', $var[$b][0], ''))
			If $a = $var[$b][1] And $b <> $var[0][0] Then $headers &= '|'
		Next
	Next
EndIf

_GDIPlus_Startup()
$Pen_GraphGrid = _GDIPlus_PenCreate(StringReplace($BackgroundColor, "0x", "0xFF"))
$Pen_Red = _GDIPlus_PenCreate("0xFFFF0000")
$Brush_ControlBackgroundColor = _GDIPlus_BrushCreateSolid(StringReplace($ControlBackgroundColor, "0x", "0xFF"))
$Brush_Blue = _GDIPlus_BrushCreateSolid(0xFF00007F)
$FontFamily_Arial = _GDIPlus_FontFamilyCreate("Arial")
;-------------------------------------------------------------------------------------------------------------------------------
;                                                       GUI
;-------------------------------------------------------------------------------------------------------------------------------
Dim $title = $Script_Name & ' ' & $version & ' - By ' & $Script_Author & ' - ' & _DateLocalFormat($last_modified) & ' - (' & $VistumblerDbName & ')'
$Vistumbler = GUICreate($title, 980, 692, -1, -1, BitOR($WS_OVERLAPPEDWINDOW, $WS_CLIPSIBLINGS))
GUISetBkColor($BackgroundColor)

;Set windows position and size
If $VistumblerPosition = "" Then
	$a = WinGetPos($Vistumbler)
	$VistumblerPosition = $a[0] & ',' & $a[1] & ',' & $a[2] & ',' & $a[3]
EndIf
$b = StringSplit($VistumblerPosition, ",")
If $VistumblerState = "Maximized" Then
	WinSetState($title, "", @SW_MAXIMIZE)
Else
	WinMove($title, "", $b[1], $b[2], $b[3], $b[4]);Resize window to ini value
EndIf

;File Menu
$file = GUICtrlCreateMenu($Text_File)
$NewSession = GUICtrlCreateMenuItem($Text_NewSession, $file)
$Save = GUICtrlCreateMenu($Text_Import, $file)
$ImportFromTXT = GUICtrlCreateMenuItem($Text_Import, $Save)
$ImportFolder = GUICtrlCreateMenuItem($Text_ImportFolder, $Save)
$Export = GUICtrlCreateMenu($Text_Export, $file)
$ExportVS1Menu = GUICtrlCreateMenu($Text_ExportToVS1, $Export)
$ExportToVS1 = GUICtrlCreateMenuItem($Text_AllAPs, $ExportVS1Menu)
$ExportToFilVS1 = GUICtrlCreateMenuItem($Text_FilteredAPs, $ExportVS1Menu)
$ExportVSZMenu = GUICtrlCreateMenu($Text_ExportToVSZ, $Export)
$ExportToVSZ = GUICtrlCreateMenuItem($Text_AllAPs, $ExportVSZMenu)
$ExportToFilVSZ = GUICtrlCreateMenuItem($Text_FilteredAPs, $ExportVSZMenu)
$ExportCsvMenu = GUICtrlCreateMenu($Text_ExportToCSV, $Export)
$ExportToCsv = GUICtrlCreateMenuItem($Text_AllAPs, $ExportCsvMenu)
$ExportToFilCsv = GUICtrlCreateMenuItem($Text_FilteredAPs, $ExportCsvMenu)
$ExportKmlMenu = GUICtrlCreateMenu($Text_ExportToKML, $Export)
$ExportToKML = GUICtrlCreateMenuItem($Text_AllAPs, $ExportKmlMenu)
$ExportToFilKML = GUICtrlCreateMenuItem($Text_FilteredAPs, $ExportKmlMenu)
$CreateApSignalMap = GUICtrlCreateMenuItem($Text_SelectedAP, $ExportKmlMenu)
$ExportGpxMenu = GUICtrlCreateMenu($Text_ExportToGPX, $Export)
$ExportToGPX = GUICtrlCreateMenuItem($Text_AllAPs, $ExportGpxMenu)
$ExportNS1Menu = GUICtrlCreateMenu($Text_ExportToNS1, $Export)
$ExportToNS1 = GUICtrlCreateMenuItem($Text_AllAPs, $ExportNS1Menu)
;$ExportCamFile = GUICtrlCreateMenuItem("Export cam file", $Export)
$ExitSaveDB = GUICtrlCreateMenuItem($Text_ExitSaveDb, $file)
$ExitVistumbler = GUICtrlCreateMenuItem($Text_Exit, $file)
;Edit Menu
$Edit = GUICtrlCreateMenu($Text_Edit)
;$Cut = GUICtrlCreateMenuitem("Cut", $Edit)
$Copy = GUICtrlCreateMenuItem($Text_Copy, $Edit)
;$Delete = GUICtrlCreateMenuItem("Delete", $Edit)
;$SelectAll = GUICtrlCreateMenuItem("Select All", $Edit)
$ClearAll = GUICtrlCreateMenuItem($Text_ClearAll, $Edit)
$SortTree = GUICtrlCreateMenuItem($Text_SortTree, $Edit)
$SelectConnected = GUICtrlCreateMenuItem($Text_SelectConnectedAP, $Edit)

$Options = GUICtrlCreateMenu($Text_Options)
If @OSVersion = "WIN_XP" Then;Added extened 'Use Native Wifi' message (Since XP does not support BSSID, CHAN, Basic Transfer Rate)
	$Text_UseNativeWifi = $Text_UseNativeWifiMsg & " " & $Text_UseNativeWifiXpExtMsg
Else
	$Text_UseNativeWifi = $Text_UseNativeWifiMsg
EndIf
$GuiUseNativeWifi = GUICtrlCreateMenuItem($Text_UseNativeWifi, $Options)
If $UseNativeWifi = 1 Then GUICtrlSetState(-1, $GUI_CHECKED)
If @OSVersion = "WIN_XP" Then GUICtrlSetState(-1, $GUI_DISABLE)
$ScanWifiGUI = GUICtrlCreateMenuItem($Text_ScanAPs, $Options)
$RefreshMenuButton = GUICtrlCreateMenuItem($Text_RefreshNetworks, $Options)
If $RefreshNetworks = 1 Then GUICtrlSetState($RefreshMenuButton, $GUI_CHECKED)
$AutoRecoveryVS1GUI = GUICtrlCreateMenuItem($Text_AutoRecoveryVS1, $Options)
If $AutoRecoveryVS1 = 1 Then GUICtrlSetState($AutoRecoveryVS1GUI, $GUI_CHECKED)
$AutoSaveAndClearGUI = GUICtrlCreateMenuItem($Text_AutoSaveAndClear, $Options)
If $AutoSaveAndClear = 1 Then GUICtrlSetState($AutoSaveAndClearGUI, $GUI_CHECKED)
$AutoSaveKML = GUICtrlCreateMenuItem($Text_AutoKml, $Options)
If $AutoKML = 1 Then GUICtrlSetState(-1, $GUI_CHECKED)
$AutoScanMenu = GUICtrlCreateMenuItem($Text_AutoScanApsOnLaunch, $Options)
If $AutoScan = 1 Then GUICtrlSetState(-1, $GUI_CHECKED)
$PlaySoundOnNewAP = GUICtrlCreateMenuItem($Text_PlaySound, $Options)
If $SoundOnAP = 1 Then GUICtrlSetState($PlaySoundOnNewAP, $GUI_CHECKED)
$PlaySoundOnNewGPS = GUICtrlCreateMenuItem($Text_PlayGpsSound, $Options)
If $SoundOnGps = 1 Then GUICtrlSetState($PlaySoundOnNewGPS, $GUI_CHECKED)
$SpeakApSignal = GUICtrlCreateMenuItem($Text_SpeakSignal, $Options)
If $SpeakSignal = 1 Then GUICtrlSetState($SpeakApSignal, $GUI_CHECKED)
$GUI_MidiActiveAps = GUICtrlCreateMenuItem($Text_PlayMidiSounds, $Options)
If $Midi_PlayForActiveAps = 1 Then GUICtrlSetState(-1, $GUI_CHECKED)
$MenuSaveGpsWithNoAps = GUICtrlCreateMenuItem($Text_SaveAllGpsData, $Options)
If $SaveGpsWithNoAps = 1 Then GUICtrlSetState(-1, $GUI_CHECKED)
$GUI_DownloadImages = GUICtrlCreateMenuItem($Text_DownloadImages & " (" & $Text_Experimental & ")", $Options)
If $DownloadImages = 1 Then GUICtrlSetState(-1, $GUI_CHECKED)
$GUI_CamTriggerMenu = GUICtrlCreateMenuItem($Text_EnableCamTriggerScript & " (" & $Text_Experimental & ")", $Options)
If $CamTrigger = 1 Then GUICtrlSetState(-1, $GUI_CHECKED)
$GuiMinimalGuiMode = GUICtrlCreateMenuItem($Text_MinimalGuiMode & " (" & $Text_Experimental & ")", $Options)
If $MinimalGuiMode = 1 Then GUICtrlSetState(-1, $GUI_CHECKED)
$DebugMenu = GUICtrlCreateMenu($Text_Debug, $Options)
$DebugFunc = GUICtrlCreateMenuItem($Text_DisplayDebug, $DebugMenu)
If $Debug = 1 Then GUICtrlSetState(-1, $GUI_CHECKED)
$DebugComGUI = GUICtrlCreateMenuItem($Text_DisplayComErrors, $DebugMenu)
If $DebugCom = 1 Then GUICtrlSetState(-1, $GUI_CHECKED)

$ViewMenu = GUICtrlCreateMenu($Text_View)
$FilterMenu = GUICtrlCreateMenu($Text_Filters, $ViewMenu)
Dim $FilterMenuID_Array[1]
Dim $FilterID_Array[1]
Dim $FoundFilter = 0
$AddRemoveFilters = GUICtrlCreateMenuItem($Text_AddRemFilters, $FilterMenu)
$query = "SELECT FiltID, FiltName FROM Filters"
$FiltMatchArray = _RecordSearch($FiltDB, $query, $FiltDB_OBJ)
$FoundFiltMatch = UBound($FiltMatchArray) - 1
If $FoundFiltMatch <> 0 Then
	For $ffm = 1 To $FoundFiltMatch
		$Filter_ID = $FiltMatchArray[$ffm][1]
		$Filter_Name = $FiltMatchArray[$ffm][2]
		$menuid = GUICtrlCreateMenuItem($Filter_Name, $FilterMenu)
		GUICtrlSetOnEvent($menuid, '_FilterChanged')
		_ArrayAdd($FilterMenuID_Array, $menuid)
		_ArrayAdd($FilterID_Array, $Filter_ID)
		$FilterMenuID_Array[0] = UBound($FilterMenuID_Array) - 1
		$FilterID_Array[0] = UBound($FilterID_Array) - 1
		If $DefFiltID <> '-1' And $Filter_ID = $DefFiltID Then
			$FoundFilter = 1
			GUICtrlSetState($menuid, $GUI_CHECKED)
		EndIf
	Next
EndIf
If $FoundFilter = 0 Then $DefFiltID = '-1'
_CreateFilterQuerys()

;View Menu
$GraphViewOptions = GUICtrlCreateMenu($Text_Graph, $ViewMenu)
$UseRssiInGraphsGUI = GUICtrlCreateMenuItem($Text_UseRssiInGraphs, $GraphViewOptions)
If $UseRssiInGraphs = 1 Then GUICtrlSetState(-1, $GUI_CHECKED)
$GraphDeadTimeGUI = GUICtrlCreateMenuItem($Text_GraphDeadTime, $GraphViewOptions)
If $GraphDeadTime = 1 Then GUICtrlSetState(-1, $GUI_CHECKED)
$AutoSortGUI = GUICtrlCreateMenuItem($Text_AutoSort, $ViewMenu)
If $AutoSort = 1 Then GUICtrlSetState($AutoSortGUI, $GUI_CHECKED)
$AutoSelectMenuButton = GUICtrlCreateMenuItem($Text_AutoSelectConnectedAP, $ViewMenu)
If $AutoSelect = 1 Then GUICtrlSetState(-1, $GUI_CHECKED)
$AutoSelectHighSignal = GUICtrlCreateMenuItem($Text_AutoSelectHighSignal, $ViewMenu)
If $AutoSelectHS = 1 Then GUICtrlSetState(-1, $GUI_CHECKED)
$AddNewAPsToTop = GUICtrlCreateMenuItem($Text_AddAPsToTop, $ViewMenu)
If $AddDirection = 0 Then GUICtrlSetState(-1, $GUI_CHECKED)
$GuiAutoScrollToBottom = GUICtrlCreateMenuItem($Text_AutoScrollToBottom, $ViewMenu)
If $AutoScrollToBottom = 1 Then GUICtrlSetState(-1, $GUI_CHECKED)
$GuiBatchListviewInsert = GUICtrlCreateMenuItem($Text_ListviewBatchInsertMode & " (" & $Text_Experimental & ")", $ViewMenu)
If $BatchListviewInsert = 1 Then GUICtrlSetState(-1, $GUI_CHECKED)

;Settings Menu
$SettingsMenu = GUICtrlCreateMenu($Text_Settings)
$SetMisc = GUICtrlCreateMenuItem($Text_MiscSettings, $SettingsMenu)
$SetSave = GUICtrlCreateMenuItem($Text_SaveSettings, $SettingsMenu)
$SetGPS = GUICtrlCreateMenuItem($Text_GpsSettings, $SettingsMenu)
$SetLanguage = GUICtrlCreateMenuItem($Text_SetLanguage, $SettingsMenu)
$SetSearchWords = GUICtrlCreateMenuItem($Text_SetSearchWords, $SettingsMenu)
$SetMacLabel = GUICtrlCreateMenuItem($Text_SetMacLabel, $SettingsMenu)
$SetMacManu = GUICtrlCreateMenuItem($Text_SetMacManu, $SettingsMenu)
$SetColumnWidths = GUICtrlCreateMenuItem($Text_SetColumnWidths, $SettingsMenu)
$SetAuto = GUICtrlCreateMenuItem($Text_AutoKml & ' / ' & $Text_AutoSort, $SettingsMenu)
$SetSound = GUICtrlCreateMenuItem($Text_Sound, $SettingsMenu)
$SetWifiDB = GUICtrlCreateMenuItem($Text_WifiDB, $SettingsMenu)
$SetCamera = GUICtrlCreateMenuItem($Text_SetCameras, $SettingsMenu)

$Interfaces = GUICtrlCreateMenu($Text_Interface)
$RefreshInterfaces = GUICtrlCreateMenuItem($Text_RefreshInterfaces, $Interfaces)
GUICtrlSetOnEvent($RefreshInterfaces, '_RefreshInterfaces')
_AddInterfaces()

$ExtraMenu = GUICtrlCreateMenu($Text_Extra)
$GUI_2400ChannelGraph = GUICtrlCreateMenuItem($Text_2400ChannelGraph & " (" & $Text_Experimental & ")", $ExtraMenu)
$GUI_5000ChannelGraph = GUICtrlCreateMenuItem($Text_5000ChannelGraph & " (" & $Text_Experimental & ")", $ExtraMenu)
$GpsDetails = GUICtrlCreateMenuItem($Text_GpsDetails, $ExtraMenu)
$GpsCompass = GUICtrlCreateMenuItem($Text_GpsCompass, $ExtraMenu)
$OpenKmlNetworkLink = GUICtrlCreateMenuItem($Text_OpenKmlNetLink, $ExtraMenu)
$OpenSaveFolder = GUICtrlCreateMenuItem($Text_OpenSaveFolder, $ExtraMenu)
$UpdateManufacturers = GUICtrlCreateMenuItem($Text_UpdateManufacturers, $ExtraMenu)
;$GUI_ImportImageFolder = GUICtrlCreateMenuItem("Import Image Folder (" & $Text_Experimental & ")", $ExtraMenu)
;$GUI_CleanupNonMatchingImages = GUICtrlCreateMenuItem("Cleanup non-matching images (" & $Text_Experimental & ")", $ExtraMenu)


$WifidbMenu = GUICtrlCreateMenu($Text_WifiDB)
$UseWiFiDbGpsLocateButton = GUICtrlCreateMenuItem($Text_AutoWiFiDbGpsLocate & ' (' & $Text_Experimental & ')', $WifidbMenu)
If @OSVersion = "WIN_XP" Then GUICtrlSetState($UseWiFiDbGpsLocateButton, $GUI_DISABLE)
If @OSVersion = "WIN_XP" Then $UseWiFiDbGpsLocate = 0
If $UseWiFiDbGpsLocate = 1 Then GUICtrlSetState($UseWiFiDbGpsLocateButton, $GUI_CHECKED)
$UseWiFiDbAutoUploadButton = GUICtrlCreateMenuItem($Text_AutoWiFiDbUploadAps & ' (' & $Text_Experimental & ')', $WifidbMenu)
If $EnableAutoUpApsToWifiDB = 1 Then _WifiDbAutoUploadToggle(0)
$ViewWifiDbWDB = GUICtrlCreateMenuItem($Text_UploadDataToWifiDB & ' (' & $Text_Experimental & ')', $WifidbMenu)
$LocateInWDB = GUICtrlCreateMenuItem($Text_LocateInWiFiDB & ' (' & $Text_Experimental & ')', $WifidbMenu)
$ViewLiveInWDB = GUICtrlCreateMenuItem($Text_WifiDBOpenLiveAPWebpage & ' (' & $Text_Experimental & ')', $WifidbMenu)
$UpdateGeolocations = GUICtrlCreateMenuItem($Text_UpdateGeolocations & ' (' & $Text_Experimental & ')', $WifidbMenu)
$ViewWDBWebpage = GUICtrlCreateMenuItem($Text_WifiDBOpenMainWebpage, $WifidbMenu)
$ViewInWifiDbGraph = GUICtrlCreateMenuItem($Text_WifiDbPHPgraph, $WifidbMenu)

$Help = GUICtrlCreateMenu($Text_Help)
$VistumblerHome = GUICtrlCreateMenuItem($Text_VistumblerHome, $Help)
$VistumblerForum = GUICtrlCreateMenuItem($Text_VistumblerForum, $Help)
$VistumblerWiki = GUICtrlCreateMenuItem($Text_VistumblerWiki, $Help)
$UpdateVistumbler = GUICtrlCreateMenuItem($Text_CheckForUpdates, $Help)

$SupportVistumbler = GUICtrlCreateMenu($Text_SupportVistumbler)
$VistumblerDonate = GUICtrlCreateMenuItem($Text_VistumblerDonate, $SupportVistumbler)
$VistumblerStore = GUICtrlCreateMenuItem($Text_VistumblerStore, $SupportVistumbler)

$GraphicGUI = GUICreate("", 900, 400, 10, 60, $WS_CHILD, -1, $Vistumbler)
GUISetBkColor($ControlBackgroundColor)
$Graphic = _GDIPlus_GraphicsCreateFromHWND($GraphicGUI)
$Graph_bitmap = _GDIPlus_BitmapCreateFromGraphics(900, 400, $Graphic)
$Graph_backbuffer = _GDIPlus_ImageGetGraphicsContext($Graph_bitmap)
GUISwitch($Vistumbler)

$ListviewAPs = _GUICtrlListView_Create($Vistumbler, $headers, 260, 65, 725, 585, BitOR($LVS_REPORT, $LVS_SINGLESEL))
_GUICtrlListView_SetExtendedListViewStyle($ListviewAPs, BitOR($LVS_EX_HEADERDRAGDROP, $LVS_EX_GRIDLINES, $LVS_EX_FULLROWSELECT, $LVS_EX_DOUBLEBUFFER))
_GUICtrlListView_SetBkColor($ListviewAPs, RGB2BGR($ControlBackgroundColor))
_GUICtrlListView_SetTextBkColor($ListviewAPs, RGB2BGR($ControlBackgroundColor))
WinSetState($ListviewAPs, "", @SW_HIDE)

$hImage = _GUIImageList_Create()
_GUIImageList_AddIcon($hImage, $IconDir & "Signal\open-grey.ico")
_GUIImageList_AddIcon($hImage, $IconDir & "Signal\open-red.ico")
_GUIImageList_AddIcon($hImage, $IconDir & "Signal\open-orange.ico")
_GUIImageList_AddIcon($hImage, $IconDir & "Signal\open-yellow.ico")
_GUIImageList_AddIcon($hImage, $IconDir & "Signal\open-light-green.ico")
_GUIImageList_AddIcon($hImage, $IconDir & "Signal\open-green.ico")
_GUIImageList_AddIcon($hImage, $IconDir & "Signal\sec-grey.ico")
_GUIImageList_AddIcon($hImage, $IconDir & "Signal\sec-red.ico")
_GUIImageList_AddIcon($hImage, $IconDir & "Signal\sec-orange.ico")
_GUIImageList_AddIcon($hImage, $IconDir & "Signal\sec-yellow.ico")
_GUIImageList_AddIcon($hImage, $IconDir & "Signal\sec-light-green.ico")
_GUIImageList_AddIcon($hImage, $IconDir & "Signal\sec-green.ico")
_GUICtrlListView_SetImageList($ListviewAPs, $hImage, 1)

$TreeviewAPs = _GUICtrlTreeView_Create($Vistumbler, 5, 65, 150, 585)
_GUICtrlTreeView_SetBkColor($TreeviewAPs, $ControlBackgroundColor)
WinSetState($TreeviewAPs, "", @SW_HIDE)

$ScanButton = GUICtrlCreateButton($Text_ScanAPs, 10, 8, 70, 20, 0)
If $AutoScan = 1 Then ScanToggle()
$GpsButton = GUICtrlCreateButton($Text_UseGPS, 80, 8, 70, 20, 0)
$GraphButton1 = GUICtrlCreateButton($Text_Graph1, 10, 35, 70, 20, 0)
$GraphButton2 = GUICtrlCreateButton($Text_Graph2, 80, 35, 70, 20, 0)

$ActiveAPs = GUICtrlCreateLabel($Text_ActiveAPs & ': ' & '0 / 0', 155, 10, 300, 15)
GUICtrlSetColor(-1, $TextColor)
$timediff = GUICtrlCreateLabel($Text_ActualLoopTime & ': 0 ms', 155, 25, 300, 15)
GUICtrlSetColor(-1, $TextColor)
$GuiLat = GUICtrlCreateLabel($Text_Latitude & ': ' & _GpsFormat($Latitude), 460, 10, 300, 15)
GUICtrlSetColor(-1, $TextColor)
$GuiLon = GUICtrlCreateLabel($Text_Longitude & ': ' & _GpsFormat($Longitude), 460, 25, 300, 15)
GUICtrlSetColor(-1, $TextColor)
$debugdisplay = GUICtrlCreateLabel('', 765, 10, 200, 15)
GUICtrlSetColor(-1, $TextColor)
$msgdisplay = GUICtrlCreateLabel('', 155, 40, 610, 15)
GUICtrlSetColor(-1, $TextColor)

GUISwitch($Vistumbler)
GUISetState(@SW_SHOW)
_SetControlSizes()

$VistumblerGuiOpen = 1

;Button-Events-------------------------------------------
GUISetOnEvent($GUI_EVENT_CLOSE, '_CloseToggle')
GUISetOnEvent($GUI_EVENT_RESIZED, '_ResetSizes')
GUISetOnEvent($GUI_EVENT_MINIMIZE, '_ResetSizes')
GUISetOnEvent($GUI_EVENT_RESTORE, '_ResetSizes')
GUISetOnEvent($GUI_EVENT_MAXIMIZE, '_ResetSizes')
;Buttons
GUICtrlSetOnEvent($ScanButton, 'ScanToggle')
GUICtrlSetOnEvent($GpsButton, '_GpsToggle')
GUICtrlSetOnEvent($GraphButton1, '_GraphToggle')
GUICtrlSetOnEvent($GraphButton2, '_GraphToggle2')
;File Menu
GUICtrlSetOnEvent($NewSession, '_NewSession')
GUICtrlSetOnEvent($ImportFromTXT, 'LoadList')
GUICtrlSetOnEvent($ImportFolder, '_LoadFolder')
GUICtrlSetOnEvent($ExportToVS1, '_ExportDetailedData')
GUICtrlSetOnEvent($ExportToFilVS1, '_ExportFilteredDetailedData')
GUICtrlSetOnEvent($ExportToVSZ, '_ExportVszData')
GUICtrlSetOnEvent($ExportToFilVSZ, '_ExportVszFilteredData')
GUICtrlSetOnEvent($ExportToCsv, '_ExportCsvData')
GUICtrlSetOnEvent($ExportToFilCsv, '_ExportCsvFilteredData')
GUICtrlSetOnEvent($ExportToKML, 'SaveToKML')
GUICtrlSetOnEvent($ExportToFilKML, '_ExportFilteredKML')
GUICtrlSetOnEvent($CreateApSignalMap, '_KmlSignalMapSelectedAP')
GUICtrlSetOnEvent($ExportToGPX, '_SaveToGPX')
GUICtrlSetOnEvent($ExportToNS1, '_ExportNS1')
;GUICtrlSetOnEvent($ExportCamFile, '_ExportCamFile')
GUICtrlSetOnEvent($ExitSaveDB, '_ExitSaveDB')
GUICtrlSetOnEvent($ExitVistumbler, '_CloseToggle')
;Edit Menu
GUICtrlSetOnEvent($ClearAll, '_ClearAll')
GUICtrlSetOnEvent($Copy, '_CopySelectedAP')
GUICtrlSetOnEvent($SelectConnected, '_MenuSelectConnectedAp')
GUICtrlSetOnEvent($SortTree, '_SortTree')
;Optons Menu
GUICtrlSetOnEvent($ScanWifiGUI, 'ScanToggle')
GUICtrlSetOnEvent($RefreshMenuButton, '_AutoRefreshToggle')
GUICtrlSetOnEvent($AutoRecoveryVS1GUI, '_AutoRecoveryVS1Toggle')
GUICtrlSetOnEvent($AutoSaveAndClearGUI, '_AutoSaveAndClearToggle')
GUICtrlSetOnEvent($AutoSaveKML, '_AutoKmlToggle')
GUICtrlSetOnEvent($AutoScanMenu, '_AutoScanToggle')
GUICtrlSetOnEvent($PlaySoundOnNewAP, '_SoundToggle')
GUICtrlSetOnEvent($PlaySoundOnNewGPS, '_GpsSoundToggle')
GUICtrlSetOnEvent($SpeakApSignal, '_SpeakSigToggle')
GUICtrlSetOnEvent($GUI_MidiActiveAps, '_ActiveApMidiToggle')
GUICtrlSetOnEvent($MenuSaveGpsWithNoAps, '_SaveGpsWithNoAPsToggle')
GUICtrlSetOnEvent($GuiUseNativeWifi, '_NativeWifiToggle')
GUICtrlSetOnEvent($DebugFunc, '_DebugToggle')
GUICtrlSetOnEvent($DebugComGUI, '_DebugComToggle')
GUICtrlSetOnEvent($GUI_DownloadImages, '_DownloadImagesToggle')
GUICtrlSetOnEvent($GUI_CamTriggerMenu, '_CamTriggerToggle')
GUICtrlSetOnEvent($GuiMinimalGuiMode, '_MinimalGuiModeToggle')
;View Menu
GUICtrlSetOnEvent($AddRemoveFilters, '_ModifyFilters')
GUICtrlSetOnEvent($AutoSortGUI, '_AutoSortToggle')
GUICtrlSetOnEvent($AutoSelectMenuButton, '_AutoConnectToggle')
GUICtrlSetOnEvent($AutoSelectHighSignal, '_AutoSelHighSigToggle')
GUICtrlSetOnEvent($AddNewAPsToTop, '_AddApPosToggle')
GUICtrlSetOnEvent($UseRssiInGraphsGUI, '_UseRssiInGraphsToggle')
GUICtrlSetOnEvent($GraphDeadTimeGUI, '_GraphDeadTimeToggle')
GUICtrlSetOnEvent($GuiAutoScrollToBottom, '_AutoScrollToBottomToggle')
GUICtrlSetOnEvent($GuiBatchListviewInsert, '_BatchListviewInsertToggle')
;Settings Menu
GUICtrlSetOnEvent($SetMisc, '_SettingsGUI_Misc')
GUICtrlSetOnEvent($SetSave, '_SettingsGUI_Save')
GUICtrlSetOnEvent($SetGPS, '_SettingsGUI_GPS')
GUICtrlSetOnEvent($SetLanguage, '_SettingsGUI_Lan')
GUICtrlSetOnEvent($SetMacManu, '_SettingsGUI_Manu')
GUICtrlSetOnEvent($SetMacLabel, '_SettingsGUI_Lab')
GUICtrlSetOnEvent($SetColumnWidths, '_SettingsGUI_Col')
GUICtrlSetOnEvent($SetSearchWords, '_SettingsGUI_SW')
GUICtrlSetOnEvent($SetAuto, '_SettingsGUI_Auto')
GUICtrlSetOnEvent($SetSound, '_SettingsGUI_Sound')
GUICtrlSetOnEvent($SetWifiDB, '_SettingsGUI_WifiDB')
GUICtrlSetOnEvent($SetCamera, '_SettingsGUI_Cam')
;Extra Menu
GUICtrlSetOnEvent($GpsCompass, '_CompassGUI')
GUICtrlSetOnEvent($GpsDetails, '_OpenGpsDetailsGUI')
GUICtrlSetOnEvent($GUI_2400ChannelGraph, '_Channels2400_GUI')
GUICtrlSetOnEvent($GUI_5000ChannelGraph, '_Channels5000_GUI')
GUICtrlSetOnEvent($OpenSaveFolder, '_OpenSaveFolder')
GUICtrlSetOnEvent($OpenKmlNetworkLink, '_StartGoogleAutoKmlRefresh')
GUICtrlSetOnEvent($UpdateManufacturers, '_ManufacturerUpdate')
;GUICtrlSetOnEvent($GUI_ImportImageFolder, '_GUI_ImportImageFiles')
;GUICtrlSetOnEvent($GUI_CleanupNonMatchingImages, '_RemoveNonMatchingImages')
;WifiDB Menu
GUICtrlSetOnEvent($UseWiFiDbGpsLocateButton, '_WifiDbLocateToggle')
GUICtrlSetOnEvent($UseWiFiDbAutoUploadButton, '_WifiDbAutoUploadToggleWarn')
GUICtrlSetOnEvent($ViewWifiDbWDB, '_AddToYourWDB')
GUICtrlSetOnEvent($LocateInWDB, '_LocatePositionInWiFiDB')
GUICtrlSetOnEvent($ViewLiveInWDB, '_ViewLiveInWDB')
GUICtrlSetOnEvent($UpdateGeolocations, '_GeoLocateAllAps')
GUICtrlSetOnEvent($ViewWDBWebpage, '_ViewWDBWebpage')
GUICtrlSetOnEvent($ViewInWifiDbGraph, '_ViewInWifiDbGraph')
;Help Menu
GUICtrlSetOnEvent($VistumblerHome, '_OpenVistumblerHome')
GUICtrlSetOnEvent($VistumblerForum, '_OpenVistumblerForum')
GUICtrlSetOnEvent($VistumblerWiki, '_OpenVistumblerWiki')
GUICtrlSetOnEvent($UpdateVistumbler, '_MenuUpdate')
;Support Vistumbler
GUICtrlSetOnEvent($VistumblerDonate, '_OpenVistumblerDonate')
GUICtrlSetOnEvent($VistumblerStore, '_OpenVistumblerStore')

;Set Listview Widths
_SetListviewWidths()

Dim $Authentication_tree = _GUICtrlTreeView_InsertItem($TreeviewAPs, $Column_Names_Authentication)
Dim $channel_tree = _GUICtrlTreeView_InsertItem($TreeviewAPs, $Column_Names_Channel)
Dim $Encryption_tree = _GUICtrlTreeView_InsertItem($TreeviewAPs, $Column_Names_Encryption)
Dim $NetworkType_tree = _GUICtrlTreeView_InsertItem($TreeviewAPs, $Column_Names_NetworkType)
Dim $SSID_tree = _GUICtrlTreeView_InsertItem($TreeviewAPs, $Column_Names_SSID)

If $Recover = 1 Then _RecoverMDB()

If $Load <> '' Then _LoadListGUI($Load)

;-------------------------------------------------------------------------------------------------------------------------------
;                                                       PROGRAM RUNNING LOOP
;-------------------------------------------------------------------------------------------------------------------------------
$UpdatedWiFiDbGPS = 0
$UpdatedGPS = 0
$UpdatedAPs = 0
$UpdatedGraph = 0
$UpdatedAutoKML = 0
$UpdatedSpeechSig = 0
$begin = TimerInit() ;Start $begin timer, used to measure loop time
$kml_active_timer = TimerInit()
$kml_dead_timer = TimerInit()
$kml_gps_timer = TimerInit()
$kml_track_timer = TimerInit()
$ReleaseMemory_Timer = TimerInit()
$Speech_Timer = TimerInit()
$WiFiDbLocate_Timer = TimerInit()
$wifidb_au_timer = TimerInit()
$cam_timer = TimerInit()
$camtrig_timer = TimerInit()
$save_timer = TimerInit()
$autosave_timer = TimerInit()
While 1
	;Set TimeStamps (UTC Values)
	$dt = StringSplit(_DateTimeUtcConvert(StringFormat("%04i", @YEAR) & '-' & StringFormat("%02i", @MON) & '-' & StringFormat("%02i", @MDAY), @HOUR & ':' & @MIN & ':' & @SEC & '.' & StringFormat("%03i", @MSEC), 1), ' ') ;UTC Time
	$datestamp = $dt[1]
	$timestamp = $dt[2]
	$ldatetimestamp = StringFormat("%04i", @YEAR) & '-' & StringFormat("%02i", @MON) & '-' & StringFormat("%02i", @MDAY) & ' ' & @HOUR & '-' & @MIN & '-' & @SEC ;Local Time

	;Get GPS position from WiFiDB
	If $UseWiFiDbGpsLocate = 1 And $UpdatedWiFiDbGPS <> 1 And $Scan = 1 And TimerDiff($WiFiDbLocate_Timer) >= $WiFiDbLocateRefreshTime Then
		$GetWifidbGpsSuccess = _LocateGpsInWifidb()
		If $GetWifidbGpsSuccess = 1 Then
			If $LatitudeWifidb <> 'N 0000.0000' And $LongitudeWifidb <> 'E 0000.0000' Then
				$Latitude = $LatitudeWifidb
				$Longitude = $LongitudeWifidb
			EndIf
			GUICtrlSetData($GuiLat, $Text_Latitude & ': ' & _GpsFormat($Latitude));Set GPS Latitude in GUI
			GUICtrlSetData($GuiLon, $Text_Longitude & ': ' & _GpsFormat($Longitude));Set GPS Longitude in GUI
		EndIf
		$WiFiDbLocate_Timer = TimerInit()
		$UpdatedWiFiDbGPS = 1
		;ConsoleWrite($GetWifidbGpsSuccess & @CRLF)
	EndIf

	;Get GPS Information (if enabled)
	If $UseGPS = 1 And $UpdatedGPS <> 1 Then ; If 'Use GPS' is checked then scan gps and display information
		$GetGpsSuccess = _GetGPS();Scan for GPS if GPS enabled
		If $GetGpsSuccess = 1 Then
			GUICtrlSetData($GuiLat, $Text_Latitude & ': ' & _GpsFormat($Latitude));Set GPS Latitude in GUI
			GUICtrlSetData($GuiLon, $Text_Longitude & ': ' & _GpsFormat($Longitude));Set GPS Longitude in GUI
			$UpdatedGPS = 1
		Else
			If $GpsType = 1 Then GUICtrlSetData($msgdisplay, $Text_GpsErrorBufferEmpty)
			If $GpsType = 0 Then GUICtrlSetData($msgdisplay, $Text_GpsErrorStopped)
			Sleep(1000)
		EndIf
	EndIf

	;Play New GPS sound (if enabled)
	If $SoundOnGps = 1 Then
		If $Last_Latitude <> $Latitude Or $Last_Longitude <> $Longitude Then
			;_SoundPlay($new_GPS_sound_open_id, 0)
			_PlayWavSound($SoundDir & $new_GPS_sound)
			$Last_Latitude = $Latitude
			$Last_Longitude = $Longitude
		EndIf
	EndIf

	;Get AP Information (if enabled)
	If $Scan = 1 And $UpdatedAPs <> 1 Then
		;Scan For New Aps
		$ScanResults = _ScanAccessPoints();Scan for Access Points if scanning enabled
		If $ScanResults = -1 Then
			GUICtrlSetData($msgdisplay, $Text_ErrorScanningNetsh)
			Sleep(1000)
		Else
			;Set Update flag so APs do not get scanned again on this loop
			$UpdatedAPs = 1
			;Set flag that new data has been added
			If $ScanResults <> 0 Then $newdata = 1
			;Add GPS ID If no access points are found and Save GPS when no APs are active is on
			If $ScanResults = 0 And $SaveGpsWithNoAps = 1 Then
				$GPS_ID += 1
				_AddRecord($VistumblerDB, "GPS", $DB_OBJ, $GPS_ID & '|' & $Latitude & '|' & $Longitude & '|' & $NumberOfSatalites & '|' & $HorDilPitch & '|' & $Alt & '|' & $Geo & '|' & $SpeedInMPH & '|' & $SpeedInKmH & '|' & $TrackAngle & '|' & $datestamp & '|' & $timestamp)
			EndIf
			;Mark Dead Access Points
			_MarkDeadAPs()
			If $MinimalGuiMode = 0 Then
				;Remove APs that do not match the filter
				_FilterRemoveNonMatchingInList()
				;Add APs back into the listview that match but are not there
				_UpdateListview($BatchListviewInsert)
			EndIf
			;Play Midi Sounds for all active APs (if enabled)
			_PlayMidiForActiveAPs()
		EndIf
		If $ScanResults > 0 Then $UpdateAutoSave = 1
		;Refresh Networks If Enabled
		If $RefreshNetworks = 1 Then _RefreshNetworks()
		;Select connected AP
		If $AutoSelect = 1 And WinActive($Vistumbler) Then _SelectConnectedAp()
		;Select the active AP with the highest signal
		If $AutoSelectHS = 1 And WinActive($Vistumbler) Then _SelectHighSignalAp()
	ElseIf $Scan = 0 And $UpdatedAPs <> 1 Then
		$UpdatedAPs = 1
		;Add GPS ID If AP Scanning is off, UseGPS is on, and Save GPS when no AP are active is on
		If $UseGPS = 1 And $SaveGpsWithNoAps = 1 Then
			$GPS_ID += 1
			_AddRecord($VistumblerDB, "GPS", $DB_OBJ, $GPS_ID & '|' & $Latitude & '|' & $Longitude & '|' & $NumberOfSatalites & '|' & $HorDilPitch & '|' & $Alt & '|' & $Geo & '|' & $SpeedInMPH & '|' & $SpeedInKmH & '|' & $TrackAngle & '|' & $datestamp & '|' & $timestamp)
		EndIf
		;Mark Dead Access Points
		_MarkDeadAPs()
		If $MinimalGuiMode = 0 Then
			;Remove APs that do not match the filter
			_FilterRemoveNonMatchingInList()
			;Add APs back into the listview that match but are not there
			_UpdateListview($BatchListviewInsert)
		EndIf
	EndIf
	;Resize Controls / Control Resize Monitoring
	_TreeviewListviewResize()


	;Graph Selected AP
	If $UpdatedGraph = 0 Then
		_GraphDraw()
		$UpdatedGraph = 1
	EndIf

	;Speak Signal of selected AP (if enabled)
	If $SpeakSignal = 1 And $Scan = 1 And $UpdatedSpeechSig = 0 And TimerDiff($Speech_Timer) >= $SpeakSigTime Then
		$SpeakSuccess = _SpeakSelectedSignal()
		If $SpeakSuccess = 1 Then
			$UpdatedSpeechSig = 1
			$Speech_Timer = TimerInit()
		EndIf
	EndIf

	;Get Webcam Images
	If $DownloadImages = 1 And TimerDiff($cam_timer) >= $DownloadImagesTime Then
		_ImageDownloader()
		$cam_timer = TimerInit()
	EndIf

	;Trigger Camera Script
	If $CamTrigger = 1 And TimerDiff($camtrig_timer) >= $CamTriggerTime Then
		_CamTrigger()
		$camtrig_timer = TimerInit()
	EndIf

	;Export KML files for AutoKML Google Earth Tracking (if enabled)
	If $AutoKML = 1 Then
		If TimerDiff($kml_gps_timer) >= ($AutoKmlGpsTime * 1000) And $AutoKmlGpsTime <> 0 Then
			_AutoKmlGpsFile($GoogleEarth_GpsFile)
			$kml_gps_timer = TimerInit()
		EndIf
		If TimerDiff($kml_dead_timer) >= ($AutoKmlDeadTime * 1000) And $AutoKmlDeadTime <> 0 And ProcessExists($AutoKmlDeadProcess) = 0 Then
			$AutoKmlDeadProcess = Run(@ComSpec & " /C " & FileGetShortName(@ScriptDir & '\Export.exe') & ' /db="' & $VistumblerDB & '" /t=k /f="' & $GoogleEarth_DeadFile & '" /d', '', @SW_HIDE)
			$kml_dead_timer = TimerInit()
		EndIf
		If TimerDiff($kml_active_timer) >= ($AutoKmlActiveTime * 1000) And $AutoKmlActiveTime <> 0 And ProcessExists($AutoKmlActiveProcess) = 0 Then
			$AutoKmlActiveProcess = Run(@ComSpec & " /C " & FileGetShortName(@ScriptDir & '\Export.exe') & ' /db="' & $VistumblerDB & '" /t=k /f="' & $GoogleEarth_ActiveFile & '" /a', '', @SW_HIDE)
			$kml_active_timer = TimerInit()
		EndIf
		If TimerDiff($kml_track_timer) >= ($AutoKmlTrackTime * 1000) And $AutoKmlTrackTime <> 0 And ProcessExists($AutoKmlTrackProcess) = 0 Then
			$AutoKmlTrackProcess = Run(@ComSpec & " /C " & FileGetShortName(@ScriptDir & '\Export.exe') & ' /db="' & $VistumblerDB & '" /t=k /f="' & $GoogleEarth_TrackFile & '" /p', '', @SW_HIDE)
			$kml_track_timer = TimerInit()
		EndIf
	EndIf

	;Upload Active APs to WiFiDB (if enabled)
	If $AutoUpApsToWifiDB = 1 Then
		If TimerDiff($wifidb_au_timer) >= ($AutoUpApsToWifiDBTime * 1000) Then
			$run = 'Export.exe' & ' /db="' & $VistumblerDB & '" /t=w /u="' & $WifiDbApiURL & '" /wa="' & $WifiDb_User & '" /wk="' & $WifiDb_ApiKey & '" /wsid="' & $WifiDbSessionID & '"'
			ConsoleWrite($run & @CRLF)
			$WifiDbUploadProcess = Run($run, @ScriptDir, @SW_HIDE)
			$wifidb_au_timer = TimerInit()
		EndIf
	EndIf

	If $AutoRecoveryVS1 = 1 And $UpdateAutoSave = 1 And TimerDiff($save_timer) >= ($AutoRecoveryTime * 60000) Then
		_AutoRecoveryVS1()
		$UpdateAutoSave = 0
	EndIf

	If $AutoSaveAndClear = 1 Then
		If $AutoSaveAndClearOnAPs = 1 And $APID >= $AutoSaveAndClearAPs Then
			_AutoSaveAndClear()
		ElseIf $AutoSaveAndClearOnTime = 1 And TimerDiff($autosave_timer) >= ($AutoSaveAndClearTime * 60000) Then
			_AutoSaveAndClear()
		EndIf
	EndIf

	;Check GPS Details Windows Position
	If WinExists($GpsDetailsGUI) And $GpsDetailsOpen = 1 Then
		$p = WinGetPos($GpsDetailsGUI)
		If $p[0] & ',' & $p[1] & ',' & $p[2] & ',' & $p[3] <> $GpsDetailsPosition Then $GpsDetailsPosition = $p[0] & ',' & $p[1] & ',' & $p[2] & ',' & $p[3] ;If the $GpsDetails has moved or resized, set $GpsDetailsPosition to current window size
	EndIf

	;Check Compass Window Position
	If WinExists($CompassGUI) And $CompassOpen = 1 Then
		$CompassPosition_old = $CompassPosition
		$p = WinGetPos($CompassGUI)
		If $p[0] & ',' & $p[1] & ',' & $p[2] & ',' & $p[3] <> $CompassPosition Then $CompassPosition = $p[0] & ',' & $p[1] & ',' & $p[2] & ',' & $p[3] ;If the $CompassGUI has moved or resized, set $pompassPosition to current window size
		If $CompassPosition <> $CompassPosition_old Then _SetCompassSizes()
		_DrawCompass()
	EndIf

	;Check 2.4Ghz Channel Graph Window Position
	If WinExists($2400chanGUI) And $2400chanGUIOpen = 1 Then
		$2400ChanGraphPos_old = $2400ChanGraphPos
		$p = WinGetPos($2400chanGUI)
		If $p[0] & ',' & $p[1] & ',' & $p[2] & ',' & $p[3] <> $2400ChanGraphPos Then $2400ChanGraphPos = $p[0] & ',' & $p[1] & ',' & $p[2] & ',' & $p[3] ;If the $2400chanGUI has moved or resized, set $GpsDetailsPosition to current window size
		If $2400ChanGraphPos <> $2400ChanGraphPos_old Then _Set2400ChanGraphSizes()
		_Draw2400ChanGraph()
	EndIf

	;Check 5Ghz Channel Graph  Position
	If WinExists($5000chanGUI) And $5000chanGUIOpen = 1 Then
		$5000ChanGraphPos_old = $5000ChanGraphPos
		$p = WinGetPos($5000chanGUI)
		If $p[0] & ',' & $p[1] & ',' & $p[2] & ',' & $p[3] <> $5000ChanGraphPos Then $5000ChanGraphPos = $p[0] & ',' & $p[1] & ',' & $p[2] & ',' & $p[3] ;If the $5000chanGUI has moved or resized, set $pompassPosition to current window size
		If $5000ChanGraphPos <> $5000ChanGraphPos_old Then _Set5000ChanGraphSizes()
		_Draw5000ChanGraph()
	EndIf

	;Check Vistumbler Window Position
	If WinExists($Vistumbler) Then
		;Set Position
		$p = WinGetPos($Vistumbler)
		If $p[0] & ',' & $p[1] & ',' & $p[2] & ',' & $p[3] <> $VistumblerPosition Then $VistumblerPosition = $p[0] & ',' & $p[1] & ',' & $p[2] & ',' & $p[3] ;If the $VistumblerPosition has moved or resized, set $pompassPosition to current window size
		;Set Window State
		$ws = WinGetState($title, "")
		If BitAND($ws, 32) Then;Set
			$VistumblerState = "Maximized"
		Else
			$VistumblerState = "Window"
		EndIf
		$winpos_old = $winpos
		$winpos = $VistumblerPosition & '-' & $VistumblerState
		If $winpos <> $winpos_old Or $MinimalGuiMode <> $MinimalGuiMode_old Then _SetControlSizes()
	EndIf

	;Flag Actions
	If $CopyFlag = 1 Then _CopySetClipboard()
	If $Close = 1 Then _ExitVistumbler() ;If the close flag has been set, exit visumbler
	If $SortColumn <> -1 Then _HeaderSort($SortColumn);Sort clicked listview column
	If $ClearAllAps = 1 Then _ClearAllAp();Clear all access points
	If $ClearListAndTree = 1 Then _ClearListAndTree() ;Clear list and tree for Minimal GUI Mode
	If $AutoScrollToBottom = 1 Then _GUICtrlListView_Scroll($ListviewAPs, 0, _GUICtrlListView_GetItemCount($ListviewAPs) * 16)

	;Release Memory (Working Set)
	If TimerDiff($ReleaseMemory_Timer) > 30000 Then
		_ReduceMemory()
		$ReleaseMemory_Timer = TimerInit()
	EndIf

	If TimerDiff($begin) >= $RefreshLoopTime Then
		$UpdatedWiFiDbGPS = 0
		$UpdatedGPS = 0
		$UpdatedAPs = 0
		$UpdatedGraph = 0
		$UpdatedAutoKML = 0
		$UpdatedSpeechSig = 0
		GUICtrlSetData($msgdisplay, '') ;Clear Message
		$time = TimerDiff($begin)
		GUICtrlSetData($timediff, $Text_ActualLoopTime & ': ' & StringFormat("%04i", $time) & ' ms'); Set 'Actual Loop Time' in GUI
		$begin = TimerInit() ;Start $begin timer, used to measure loop time
	Else
		Sleep(10)
	EndIf
WEnd
Exit

;-------------------------------------------------------------------------------------------------------------------------------
;                                                       WIFI SCAN FUNCTIONS
;-------------------------------------------------------------------------------------------------------------------------------

Func _ScanAccessPoints()
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, ' _ScanAccessPoints()') ;#Debug Display
	Local $FoundAPs = 0
	Local $FilterMatches = 0
	If $UseNativeWifi = 1 Then
		$aplist = _Wlan_GetNetworks(False, 0, 0)
		;_ArrayDisplay($aplist)
		$aplistsize = UBound($aplist) - 1
		For $add = 0 To $aplistsize
			$SSID = $aplist[$add][1]
			$NetworkType = $aplist[$add][2]
			$SecurityEnabled = $aplist[$add][6]
			$Authentication = $aplist[$add][7]
			$Encryption = $aplist[$add][8]
			$RadioType = "802.11" & $aplist[$add][12]
			$Signal = $aplist[$add][5]
			If $Signal <> 0 Then
				$FoundAPs += 1
				;Add new GPS ID
				If $FoundAPs = 1 Then
					$GPS_ID += 1
					_AddRecord($VistumblerDB, "GPS", $DB_OBJ, $GPS_ID & '|' & $Latitude & '|' & $Longitude & '|' & $NumberOfSatalites & '|' & $HorDilPitch & '|' & $Alt & '|' & $Geo & '|' & $SpeedInMPH & '|' & $SpeedInKmH & '|' & $TrackAngle & '|' & $datestamp & '|' & $timestamp)
				EndIf
				;Add new access point(s)
				If @OSVersion = "WIN_XP" Then ;WinXP Does not support _Wlan_GetNetworkInfo, so fall back to olf functionality
					$BasicTransferRates = $aplist[$add][11]
					$OtherTransferRates = ""
					$BSSID = $aplist[$add][10]
					$RSSI = _SignalPercentToDb($Signal)
					$Channel = 0
					$NewFound = _AddApData(1, $GPS_ID, $BSSID, $SSID, $Channel, $Authentication, $Encryption, $NetworkType, $RadioType, $BasicTransferRates, $OtherTransferRates, $Signal, $RSSI)
					If $NewFound <> 0 Then
						;Check if this AP matches the filter
						If StringInStr($AddQuery, "WHERE") Then
							$fquery = $AddQuery & " AND ApID = " & $NewFound
						Else
							$fquery = $AddQuery & " WHERE ApID = " & $NewFound
						EndIf
						$LoadApMatchArray = _RecordSearch($VistumblerDB, $fquery, $DB_OBJ)
						$FoundLoadApMatch = UBound($LoadApMatchArray) - 1
						;If AP Matches filter, increment $FilterMatches
						If $FoundLoadApMatch = 1 Then $FilterMatches += 1
						;Play per-ap new ap sound
						If $SoundPerAP = 1 And $FoundLoadApMatch = 1 Then
							If $NewSoundSigBased = 1 Then
								$run = FileGetShortName(@ScriptDir & '\say.exe') & ' /s="' & $Signal & '" /t=5'
								$SayProcess = Run(@ComSpec & " /C " & $run, '', @SW_HIDE)
							Else
								$run = FileGetShortName(@ScriptDir & '\say.exe') & ' /s="100" /t=5'
								$SayProcess = Run(@ComSpec & " /C " & $run, '', @SW_HIDE)
							EndIf
						EndIf
					EndIf
				Else ;Uses _Wlan_GetNetworkInfo and get extended information
					If $SecurityEnabled = "Security Enabled" Then
						$Secured = True
					Else
						$Secured = False
					EndIf
					If $NetworkType = "Infrastructure" Then
						$BssType = $DOT11_BSS_TYPE_INFRASTRUCTURE
					Else
						$BssType = $DOT11_BSS_TYPE_INDEPENDENT
					EndIf

					$apinfo = _Wlan_GetNetworkInfo($SSID, $BssType, $Secured)
					;_ArrayDisplay($apinfo)
					$apinfosize = UBound($apinfo) - 1
					For $addinfo = 0 To $apinfosize
						$InfoSSID = $apinfo[$addinfo][1]
						$BSSID = StringReplace($apinfo[$addinfo][2], " ", ":")
						$Flags = $apinfo[$addinfo][3]
						$NetworkType = $apinfo[$addinfo][4]
						If $apinfo[$addinfo][5] = "Unknown/Any Phy Type" Then
							$RadioType = "Unknown"
						Else
							$RadioType = "802.11" & $apinfo[$addinfo][5]
						EndIf
						$Signal = $apinfo[$addinfo][6]
						$RSSI = $apinfo[$addinfo][7]
						$Channel = $apinfo[$addinfo][8]

						$TypeMatch = BitOR(BitAND($BssType = $DOT11_BSS_TYPE_INFRASTRUCTURE, StringInStr($Flags, "(ESS)") <> 0), BitAND($BssType = $DOT11_BSS_TYPE_INDEPENDENT, StringInStr($Flags, "(IBSS)") <> 0))
						$SecMatch = BitOR(BitAND($Secured = True, StringInStr($Flags, "(Priv)") <> 0), BitAND($Secured = False, StringInStr($Flags, "(Priv)") = 0))
						;ConsoleWrite($SSID & ' - ' & $InfoSSID & ' - ' & $Signal & ' - ' & $BSSID & ' - ' & $Flags & ' - ' & $Secured & ' - ' & $SecMatch & ' - ' & $TypeMatch & @CRLF)
						If $Signal <> 0 And $RSSI < 0 And $SSID = $InfoSSID And $SecMatch = 1 And $TypeMatch = 1 Then ;"$SSID = $InfoSSID And $SecMatch = 1 And $TypeMatch = 1" check is a temporary workaround for blank SSIDse
							;ConsoleWrite($SSID & ' - ' & $Signal & ' - ' & $RSSI & ' - ' & _SignalPercentToDb($Signal) & @CRLF)
							;Split Other Transfer Rates from Basic Transfer Rates
							Local $highchan = 0, $otrswitch = 0, $BasicTransferRates = "", $OtherTransferRates = ""
							$tr_split = StringSplit($apinfo[$addinfo][11], ",")
							For $trs = 1 To $tr_split[0]
								$transferrate = $tr_split[$trs] - 0
								If ($transferrate > $highchan) And ($otrswitch = 0) Then
									$highchan = $transferrate
									If $BasicTransferRates <> "" Then $BasicTransferRates &= ","
									$BasicTransferRates &= $transferrate
								Else
									$otrswitch = 1
									If $OtherTransferRates <> "" Then $OtherTransferRates &= ","
									$OtherTransferRates &= $transferrate
								EndIf
							Next
							;End Split Other Transfer Rates from Basic Transfer Rates
							$NewFound = _AddApData(1, $GPS_ID, $BSSID, $SSID, $Channel, $Authentication, $Encryption, $NetworkType, $RadioType, $BasicTransferRates, $OtherTransferRates, $Signal, $RSSI)
							If $NewFound <> 0 Then
								;Check if this AP matches the filter
								If StringInStr($AddQuery, "WHERE") Then
									$fquery = $AddQuery & " AND ApID = " & $NewFound
								Else
									$fquery = $AddQuery & " WHERE ApID = " & $NewFound
								EndIf
								$LoadApMatchArray = _RecordSearch($VistumblerDB, $fquery, $DB_OBJ)
								$FoundLoadApMatch = UBound($LoadApMatchArray) - 1
								;If AP Matches filter, increment $FilterMatches
								If $FoundLoadApMatch = 1 Then $FilterMatches += 1
								;Play per-ap new ap sound
								If $SoundPerAP = 1 And $FoundLoadApMatch = 1 Then
									If $NewSoundSigBased = 1 Then
										$run = FileGetShortName(@ScriptDir & '\say.exe') & ' /s="' & $Signal & '" /t=5'
										$SayProcess = Run(@ComSpec & " /C " & $run, '', @SW_HIDE)
									Else
										$run = FileGetShortName(@ScriptDir & '\say.exe') & ' /s="100" /t=5'
										$SayProcess = Run(@ComSpec & " /C " & $run, '', @SW_HIDE)
									EndIf
								EndIf
							EndIf
						EndIf
					Next
				EndIf
			EndIf
		Next
		;Play New AP sound if sounds are enabled if per-ap sound is disabled
		If $SoundPerAP = 0 And $FilterMatches <> 0 And $SoundOnAP = 1 Then _PlayWavSound($SoundDir & $new_AP_sound);_SoundPlay($new_AP_sound_open_id, 0)
		;Return number of active APs
		Return ($FoundAPs)
	Else
		Local $NewAP = 0
		;Delete old temp file
		FileDelete($tempfile)
		;Dump data from netsh
		_RunDos($netsh & ' wlan show networks mode=bssid interface="' & $DefaultApapter & '" > ' & '"' & $tempfile & '"') ;copy the output of the 'netsh wlan show networks mode=bssid' command to the temp file
		;Open netsh temp file and go through it
		$netshtempfile = FileOpen($tempfile, 0)
		If $netshtempfile <> -1 Then
			$netshfile = FileRead($netshtempfile)
			$netshfile = StringReplace($netshfile, ":" & @CRLF, ":") ;Fix for turkish netsh file
			$TempFileArray = StringSplit($netshfile, @CRLF)
			If IsArray($TempFileArray) Then
				;Strip out whitespace before and after text on each line
				For $stripws = 1 To $TempFileArray[0]
					$TempFileArray[$stripws] = StringStripWS($TempFileArray[$stripws], 3)
				Next
				;Go through each line to get data
				For $loop = 1 To $TempFileArray[0]
					$temp = StringSplit(StringStripWS($TempFileArray[$loop], 3), ":")
					If IsArray($temp) Then
						If $temp[0] = 2 Then
							If StringInStr($TempFileArray[$loop], $SearchWord_SSID) And StringInStr($TempFileArray[$loop], $SearchWord_BSSID) <> 1 Then
								$SSID = StringStripWS($temp[2], 3)
								Dim $NetworkType = '', $Authentication = '', $Encryption = '', $BSSID = ''
							EndIf
							If StringInStr($TempFileArray[$loop], $SearchWord_NetworkType) Then $NetworkType = StringStripWS($temp[2], 3)
							If StringInStr($TempFileArray[$loop], $SearchWord_Authentication) Then $Authentication = StringStripWS($temp[2], 3)
							If StringInStr($TempFileArray[$loop], $SearchWord_Encryption) Then $Encryption = StringStripWS($temp[2], 3)
							If StringInStr($TempFileArray[$loop], $SearchWord_Signal) Then $Signal = StringStripWS(StringReplace($temp[2], '%', ''), 3)
							If StringInStr($TempFileArray[$loop], $SearchWord_RadioType) Then $RadioType = StringStripWS($temp[2], 3)
							If StringInStr($TempFileArray[$loop], $SearchWord_Channel) Then $Channel = StringStripWS($temp[2], 3)
							If StringInStr($TempFileArray[$loop], $SearchWord_BasicRates) Then $BasicTransferRates = StringStripWS($temp[2], 3)
							If StringInStr($TempFileArray[$loop], $SearchWord_OtherRates) Then $OtherTransferRates = StringStripWS($temp[2], 3)
						ElseIf $temp[0] = 7 Then
							If StringInStr($TempFileArray[$loop], $SearchWord_BSSID) Then
								Dim $Signal = '0', $RadioType = '', $Channel = '', $BasicTransferRates = '', $OtherTransferRates = '', $MANUF
								$NewAP = 1
								$BSSID = StringStripWS(StringUpper($temp[2] & ':' & $temp[3] & ':' & $temp[4] & ':' & $temp[5] & ':' & $temp[6] & ':' & $temp[7]), 3)
							EndIf
						EndIf
					EndIf
					;Set Update Flag (if needed)
					$Update = 0
					If $loop = $TempFileArray[0] Then
						$Update = 1
					Else
						If StringInStr($TempFileArray[$loop + 1], $SearchWord_SSID) Or StringInStr($TempFileArray[$loop + 1], $SearchWord_BSSID) Then $Update = 1
					EndIf
					;Add data into database and gui
					If $Update = 1 And $NewAP = 1 And $BSSID <> '' Then
						$NewAP = 0
						If $BSSID <> "" Then
							$FoundAPs += 1
							;Add new GPS ID
							If $FoundAPs = 1 Then
								$GPS_ID += 1
								_AddRecord($VistumblerDB, "GPS", $DB_OBJ, $GPS_ID & '|' & $Latitude & '|' & $Longitude & '|' & $NumberOfSatalites & '|' & $HorDilPitch & '|' & $Alt & '|' & $Geo & '|' & $SpeedInMPH & '|' & $SpeedInKmH & '|' & $TrackAngle & '|' & $datestamp & '|' & $timestamp)
							EndIf
							;Add new access point
							$RSSI = _SignalPercentToDb($Signal)
							$NewFound = _AddApData(1, $GPS_ID, $BSSID, $SSID, $Channel, $Authentication, $Encryption, $NetworkType, $RadioType, $BasicTransferRates, $OtherTransferRates, $Signal, $RSSI)
							If $NewFound <> 0 Then
								;Check if this AP matches the filter
								If StringInStr($AddQuery, "WHERE") Then
									$fquery = $AddQuery & " AND ApID = " & $NewFound
								Else
									$fquery = $AddQuery & " WHERE ApID = " & $NewFound
								EndIf
								$LoadApMatchArray = _RecordSearch($VistumblerDB, $fquery, $DB_OBJ)
								$FoundLoadApMatch = UBound($LoadApMatchArray) - 1
								;If AP Matches filter, increment $FilterMatches
								If $FoundLoadApMatch = 1 Then $FilterMatches += 1
								;Play per-ap new AP sound
								If $SoundPerAP = 1 And $FoundLoadApMatch = 1 Then
									If $NewSoundSigBased = 1 Then
										$run = FileGetShortName(@ScriptDir & '\say.exe') & ' /s="' & $Signal & '" /t=5'
										$SayProcess = Run(@ComSpec & " /C " & $run, '', @SW_HIDE)
									Else
										$run = FileGetShortName(@ScriptDir & '\say.exe') & ' /s="100" /t=5'
										$SayProcess = Run(@ComSpec & " /C " & $run, '', @SW_HIDE)
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
				Next
				;Play New AP sound if sounds are enabled if per-ap sound is disabled
				If $SoundPerAP = 0 And $FilterMatches <> 0 And $SoundOnAP = 1 Then _PlayWavSound($SoundDir & $new_AP_sound);_SoundPlay($new_AP_sound_open_id, 0)
			EndIf
			FileClose($netshtempfile)
			;Return number of active APs
			Return ($FoundAPs)
		Else
			Return ("-1")
		EndIf
	EndIf
EndFunc   ;==>_ScanAccessPoints

;-------------------------------------------------------------------------------------------------------------------------------
;                                                       ADD DB/LISTVIEW/TREEVIEW FUNCTIONS
;-------------------------------------------------------------------------------------------------------------------------------

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
					$query = "SELECT GpsID, RSSI FROM HIST WHERE HistID=" & $Found_HighGpsHistId
					$HistMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
					$Found_GpsID = $HistMatchArray[1][1]
					$Found_RSSI = $HistMatchArray[1][2]
					;Get Old Latititude, Logitude and Number of Satalites from Old GPS ID
					$query = "SELECT Latitude, Longitude, NumOfSats FROM GPS WHERE GpsID=" & $Found_GpsID
					$GpsMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
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
			;Update List information
			If $New = 0 And $Found_Active = 0 Then
				$Exp_AP_Status = -1
				$Exp_AP_DisplaySig = -1
				$Exp_AP_DisplayRSSI = -1
			Else
				$Exp_AP_Status = $AP_Status
				$Exp_AP_DisplaySig = $AP_DisplaySig
				$Exp_AP_DisplayRSSI = $AP_DisplayRSSI
			EndIf
			If $Found_ListRow <> -1 Then
				;Update AP Listview data
				_GUICtrlListView_BeginUpdate($ListviewAPs)
				_ListViewAdd($Found_ListRow, -1, $Exp_AP_Status, -1, -1, -1, -1, $Exp_AP_DisplaySig, $ExpHighSig, $Exp_AP_DisplayRSSI, $ExpHighRSSI, -1, -1, -1, -1, -1, $ExpFirstDateTime, $ExpLastDateTime, $DBLat, $DBLon, -1, -1)
				;Update Signal Icon
				_UpdateIcon($Found_ListRow, $Exp_AP_DisplaySig, $Found_SecType)
				_GUICtrlListView_EndUpdate($ListviewAPs)
			EndIf
		EndIf
	EndIf
	Return ($NewApFound)
EndFunc   ;==>_AddApData

Func _AddIconListRow($SigLev, $IconSecType, $LineTxt, $AddPos)
	;Add Into ListView, Set icon color
	Local $addListRow
	If $SigLev >= 1 And $SigLev <= 20 Then
		If $IconSecType = 1 Then
			$addListRow = _GUICtrlListView_InsertItem($ListviewAPs, $LineTxt, $AddPos, 1)
		Else
			$addListRow = _GUICtrlListView_InsertItem($ListviewAPs, $LineTxt, $AddPos, 7)
		EndIf
	ElseIf $SigLev >= 21 And $SigLev <= 40 Then
		If $IconSecType = 1 Then
			$addListRow = _GUICtrlListView_InsertItem($ListviewAPs, $LineTxt, $AddPos, 2)
		Else
			$addListRow = _GUICtrlListView_InsertItem($ListviewAPs, $LineTxt, $AddPos, 8)
		EndIf
	ElseIf $SigLev >= 41 And $SigLev <= 60 Then
		If $IconSecType = 1 Then
			$addListRow = _GUICtrlListView_InsertItem($ListviewAPs, $LineTxt, $AddPos, 3)
		Else
			$addListRow = _GUICtrlListView_InsertItem($ListviewAPs, $LineTxt, $AddPos, 9)
		EndIf
	ElseIf $SigLev >= 61 And $SigLev <= 80 Then
		If $IconSecType = 1 Then
			$addListRow = _GUICtrlListView_InsertItem($ListviewAPs, $LineTxt, $AddPos, 4)
		Else
			$addListRow = _GUICtrlListView_InsertItem($ListviewAPs, $LineTxt, $AddPos, 10)
		EndIf
	ElseIf $SigLev >= 81 And $SigLev <= 100 Then
		If $IconSecType = 1 Then
			$addListRow = _GUICtrlListView_InsertItem($ListviewAPs, $LineTxt, $AddPos, 5)
		Else
			$addListRow = _GUICtrlListView_InsertItem($ListviewAPs, $LineTxt, $AddPos, 11)
		EndIf
	Else
		If $IconSecType = 1 Then
			$addListRow = _GUICtrlListView_InsertItem($ListviewAPs, $LineTxt, $AddPos, 0)
		Else
			$addListRow = _GUICtrlListView_InsertItem($ListviewAPs, $LineTxt, $AddPos, 6)
		EndIf
	EndIf
	Return ($addListRow)
EndFunc   ;==>_AddIconListRow

Func _UpdateIcon($ApListRow, $ApSig, $ApSecType)
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_UpdateIcon()') ;#Debug Display
	If $ApSig >= 1 And $ApSig <= 20 Then
		If $ApSecType = 1 Then
			_GUICtrlListView_SetItemImage($ListviewAPs, $ApListRow, 1)
		Else
			_GUICtrlListView_SetItemImage($ListviewAPs, $ApListRow, 7)
		EndIf
	ElseIf $ApSig >= 21 And $ApSig <= 40 Then
		If $ApSecType = 1 Then
			_GUICtrlListView_SetItemImage($ListviewAPs, $ApListRow, 2)
		Else
			_GUICtrlListView_SetItemImage($ListviewAPs, $ApListRow, 8)
		EndIf
	ElseIf $ApSig >= 41 And $ApSig <= 60 Then
		If $ApSecType = 1 Then
			_GUICtrlListView_SetItemImage($ListviewAPs, $ApListRow, 3)
		Else
			_GUICtrlListView_SetItemImage($ListviewAPs, $ApListRow, 9)
		EndIf
	ElseIf $ApSig >= 61 And $ApSig <= 80 Then
		If $ApSecType = 1 Then
			_GUICtrlListView_SetItemImage($ListviewAPs, $ApListRow, 4)
		Else
			_GUICtrlListView_SetItemImage($ListviewAPs, $ApListRow, 10)
		EndIf
	ElseIf $ApSig >= 81 And $ApSig <= 100 Then
		If $ApSecType = 1 Then
			_GUICtrlListView_SetItemImage($ListviewAPs, $ApListRow, 5)
		Else
			_GUICtrlListView_SetItemImage($ListviewAPs, $ApListRow, 11)
		EndIf
	Else
		If $ApSecType = 1 Then
			_GUICtrlListView_SetItemImage($ListviewAPs, $ApListRow, 0)
		Else
			_GUICtrlListView_SetItemImage($ListviewAPs, $ApListRow, 6)
		EndIf
	EndIf
EndFunc   ;==>_UpdateIcon

Func _MarkDeadAPs()
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_MarkDeadAPs()') ;#Debug Display
	;Set APs Dead in Listview
	$query = "SELECT ApID, ListRow, LastGpsID, SecType FROM AP WHERE Active=1"
	$ApMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
	$FoundApMatch = UBound($ApMatchArray) - 1
	For $resetdead = 1 To $FoundApMatch
		$Found_APID = $ApMatchArray[$resetdead][1]
		$Found_ListRow = $ApMatchArray[$resetdead][2]
		$Found_LastGpsID = $ApMatchArray[$resetdead][3]
		$Found_SecType = $ApMatchArray[$resetdead][4]
		;Get Last Time
		$query = "SELECT Date1, Time1 FROM GPS WHERE GpsID=" & $Found_LastGpsID
		$GpsMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
		$Found_Date = $GpsMatchArray[1][1]
		$Found_Time = _TimeToSeconds($GpsMatchArray[1][2])
		$Current_Time = _TimeToSeconds($timestamp)
		$Found_dts = StringReplace($Found_Date & $Found_Time, '-', '')
		$Current_dts = StringReplace($datestamp & $Current_Time, '-', '')
		;Set APs that have been inactive for specified time dead
		If (($Current_dts - $Found_dts) > $TimeBeforeMarkedDead) Or $Scan = 0 Then
			If $MinimalGuiMode = 0 Then
				_ListViewAdd($Found_ListRow, -1, $Text_Dead, -1, -1, -1, -1, '0', -1, '-100', -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1)
				_UpdateIcon($Found_ListRow, 0, $Found_SecType)
			EndIf
			$query = "UPDATE AP SET Active=0, Signal=0, RSSI=-100 WHERE ApID=" & $Found_APID
			_ExecuteMDB($VistumblerDB, $DB_OBJ, $query)
		EndIf
	Next

	;Fix APs that are marked dead but still have a signal
	$query = "SELECT ApID, ListRow, SecType FROM AP WHERE Active=0 And Signal<>0"
	$ApMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
	$FoundApMatch = UBound($ApMatchArray) - 1
	For $resetdead = 1 To $FoundApMatch
		$Found_APID = $ApMatchArray[$resetdead][1]
		$Found_ListRow = $ApMatchArray[$resetdead][2]
		$Found_SecType = $ApMatchArray[$resetdead][3]
		$query = "UPDATE AP SET Signal=0 WHERE ApID='" & $Found_APID & "'"
		_ExecuteMDB($VistumblerDB, $DB_OBJ, $query)
		If $MinimalGuiMode = 0 Then _UpdateIcon($Found_ListRow, 0, $Found_SecType)
	Next

	;Update active/total ap label
	$query = "Select COUNT(ApID) FROM AP WHERE Active=1"
	$ActiveCountArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
	$ActiveCount = $ActiveCountArray[1][1]
	If $DefFiltID = '-1' Then
		GUICtrlSetData($ActiveAPs, $Text_ActiveAPs & ': ' & $ActiveCount & " / " & $APID)
	Else
		;$query = "Select COUNT(ApID) FROM AP WHERE ListRow<>-1"
		$FilteredCountArray = _RecordSearch($VistumblerDB, $CountQuery, $DB_OBJ)
		$FilteredCount = $FilteredCountArray[1][1]

		Local $query
		If StringInStr($CountQuery, "WHERE") Then
			$query = $CountQuery & " AND Active=1"
		Else
			$query = $CountQuery & " WHERE Active=1"
		EndIf
		;$query = "Select COUNT(ApID) FROM AP WHERE Active=1 And ListRow<>-1"
		$ActiveFilteredCountArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
		$ActiveFilteredCount = $ActiveFilteredCountArray[1][1]
		GUICtrlSetData($ActiveAPs, $Text_ActiveAPs & ': ' & $ActiveFilteredCount & " / " & $FilteredCount & " " & $Text_Filtered & "    " & $ActiveCount & " / " & $APID & " " & $Text_Total)
		;GUICtrlSetData($ActiveAPs, $Text_ActiveAPs & ': ' & $ActiveCount & " / " & $APID & "  ( " & $ActiveFilteredCount & " / " & $FilteredCount & " filtered )")
	EndIf
EndFunc   ;==>_MarkDeadAPs

Func _ListViewAdd($line, $Add_Line = -1, $Add_Active = -1, $Add_BSSID = -1, $Add_SSID = -1, $Add_Authentication = -1, $Add_Encryption = -1, $Add_Signal = -1, $Add_HighSignal = -1, $Add_RSSI = -1, $Add_HighRSSI = -1, $Add_Channel = -1, $Add_RadioType = -1, $Add_BasicTransferRates = -1, $Add_OtherTransferRates = -1, $Add_NetworkType = -1, $Add_FirstAcvtive = -1, $Add_LastActive = -1, $Add_LatitudeDMM = -1, $Add_LongitudeDMM = -1, $Add_MANU = -1, $Add_Label = -1)
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_ListViewAdd()') ;#Debug Display

	If $Add_Active <> -1 Then $Add_Active = StringReplace(StringReplace($Add_Active, "1", $Text_Active), "0", $Text_Dead)

	If $Add_LatitudeDMM <> -1 And $Add_LongitudeDMM <> -1 Then
		$LatDMS = _Format_GPS_DMM_to_DMS($Add_LatitudeDMM)
		$LonDMS = _Format_GPS_DMM_to_DMS($Add_LongitudeDMM)
		$LatDDD = _Format_GPS_DMM_to_DDD($Add_LatitudeDMM)
		$LonDDD = _Format_GPS_DMM_to_DDD($Add_LongitudeDMM)
	Else ;Do nothing (Reset lat,lon variables)
		$LatDMS = -1
		$LonDMS = -1
		$LatDDD = -1
		$LonDDD = -1
	EndIf

	If $Add_Line <> -1 Then _GUICtrlListView_SetItemText($ListviewAPs, $line, Round($Add_Line), $column_Line)
	If $Add_Active <> -1 Then _GUICtrlListView_SetItemText($ListviewAPs, $line, $Add_Active, $column_Active)
	If $Add_SSID <> -1 Then _GUICtrlListView_SetItemText($ListviewAPs, $line, $Add_SSID, $column_SSID)
	If $Add_BSSID <> -1 Then _GUICtrlListView_SetItemText($ListviewAPs, $line, $Add_BSSID, $column_BSSID)
	If $Add_MANU <> -1 Then _GUICtrlListView_SetItemText($ListviewAPs, $line, $Add_MANU, $column_MANUF)
	If $Add_Signal <> -1 Then _GUICtrlListView_SetItemText($ListviewAPs, $line, Round($Add_Signal) & '% ', $column_Signal)
	If $Add_HighSignal <> -1 Then _GUICtrlListView_SetItemText($ListviewAPs, $line, Round($Add_HighSignal) & '% ', $column_HighSignal)
	If $Add_RSSI <> -1 Then _GUICtrlListView_SetItemText($ListviewAPs, $line, $Add_RSSI & ' dBm', $column_RSSI)
	If $Add_HighSignal <> -1 Then _GUICtrlListView_SetItemText($ListviewAPs, $line, $Add_HighRSSI & ' dBm', $column_HighRSSI)
	If $Add_Authentication <> -1 Then _GUICtrlListView_SetItemText($ListviewAPs, $line, $Add_Authentication, $column_Authentication)
	If $Add_Encryption <> -1 Then _GUICtrlListView_SetItemText($ListviewAPs, $line, $Add_Encryption, $column_Encryption)
	If $Add_RadioType <> -1 Then _GUICtrlListView_SetItemText($ListviewAPs, $line, $Add_RadioType, $column_RadioType)
	If $Add_Channel <> -1 Then _GUICtrlListView_SetItemText($ListviewAPs, $line, Round($Add_Channel), $column_Channel)
	If $LatDDD <> -1 Then _GUICtrlListView_SetItemText($ListviewAPs, $line, $LatDDD, $column_Latitude)
	If $LonDDD <> -1 Then _GUICtrlListView_SetItemText($ListviewAPs, $line, $LonDDD, $column_Longitude)
	If $LatDMS <> -1 Then _GUICtrlListView_SetItemText($ListviewAPs, $line, $LatDMS, $column_LatitudeDMS)
	If $LonDMS <> -1 Then _GUICtrlListView_SetItemText($ListviewAPs, $line, $LonDMS, $column_LongitudeDMS)
	If $Add_LatitudeDMM <> -1 Then _GUICtrlListView_SetItemText($ListviewAPs, $line, $Add_LatitudeDMM, $column_LatitudeDMM)
	If $Add_LongitudeDMM <> -1 Then _GUICtrlListView_SetItemText($ListviewAPs, $line, $Add_LongitudeDMM, $column_LongitudeDMM)
	If $Add_BasicTransferRates <> -1 Then _GUICtrlListView_SetItemText($ListviewAPs, $line, $Add_BasicTransferRates, $column_BasicTransferRates)
	If $Add_OtherTransferRates <> -1 Then _GUICtrlListView_SetItemText($ListviewAPs, $line, $Add_OtherTransferRates, $column_OtherTransferRates)
	If $Add_NetworkType <> -1 Then _GUICtrlListView_SetItemText($ListviewAPs, $line, $Add_NetworkType, $column_NetworkType)
	If $Add_Label <> -1 Then _GUICtrlListView_SetItemText($ListviewAPs, $line, $Add_Label, $column_Label)
	If $Add_FirstAcvtive <> -1 Then
		$LTD = StringSplit($Add_FirstAcvtive, ' ')
		_GUICtrlListView_SetItemText($ListviewAPs, $line, _DateTimeLocalFormat(_DateTimeUtcConvert($LTD[1], $LTD[2], 0)), $column_FirstActive)
	EndIf
	If $Add_LastActive <> -1 Then
		$LTD = StringSplit($Add_LastActive, ' ')
		_GUICtrlListView_SetItemText($ListviewAPs, $line, _DateTimeLocalFormat(_DateTimeUtcConvert($LTD[1], $LTD[2], 0)), $column_LastActive)
	EndIf
EndFunc   ;==>_ListViewAdd

Func _SetListviewWidths()
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_SetListviewWidths()') ;#Debug Display
	;Set column widths - All variables have ' - 0' after them to make this work. it would not set column widths without the ' - 0'
	_GUICtrlListView_SetColumnWidth($ListviewAPs, $column_Line - 0, $column_Width_Line - 0)
	_GUICtrlListView_SetColumnWidth($ListviewAPs, $column_Active - 0, $column_Width_Active - 0)
	_GUICtrlListView_SetColumnWidth($ListviewAPs, $column_SSID - 0, $column_Width_SSID - 0)
	_GUICtrlListView_SetColumnWidth($ListviewAPs, $column_BSSID - 0, $column_Width_BSSID - 0)
	_GUICtrlListView_SetColumnWidth($ListviewAPs, $column_MANUF - 0, $column_Width_MANUF - 0)
	_GUICtrlListView_SetColumnWidth($ListviewAPs, $column_Signal - 0, $column_Width_Signal - 0)
	_GUICtrlListView_SetColumnWidth($ListviewAPs, $column_HighSignal - 0, $column_Width_HighSignal - 0)
	_GUICtrlListView_SetColumnWidth($ListviewAPs, $column_RSSI - 0, $column_Width_RSSI - 0)
	_GUICtrlListView_SetColumnWidth($ListviewAPs, $column_HighRSSI - 0, $column_Width_HighRSSI - 0)
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
EndFunc   ;==>_SetListviewWidths

Func _GetListviewWidths()
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_GetListviewWidths()') ;#Debug Display
	$column_Width_Line = _GUICtrlListView_GetColumnWidth($ListviewAPs, $column_Line - 0)
	$column_Width_Active = _GUICtrlListView_GetColumnWidth($ListviewAPs, $column_Active - 0)
	$column_Width_SSID = _GUICtrlListView_GetColumnWidth($ListviewAPs, $column_SSID - 0)
	$column_Width_BSSID = _GUICtrlListView_GetColumnWidth($ListviewAPs, $column_BSSID - 0)
	$column_Width_MANUF = _GUICtrlListView_GetColumnWidth($ListviewAPs, $column_MANUF - 0)
	$column_Width_Signal = _GUICtrlListView_GetColumnWidth($ListviewAPs, $column_Signal - 0)
	$column_Width_HighSignal = _GUICtrlListView_GetColumnWidth($ListviewAPs, $column_HighSignal - 0)
	$column_Width_RSSI = _GUICtrlListView_GetColumnWidth($ListviewAPs, $column_RSSI - 0)
	$column_Width_HighRSSI = _GUICtrlListView_GetColumnWidth($ListviewAPs, $column_HighRSSI - 0)
	$column_Width_Authentication = _GUICtrlListView_GetColumnWidth($ListviewAPs, $column_Authentication - 0)
	$column_Width_Encryption = _GUICtrlListView_GetColumnWidth($ListviewAPs, $column_Encryption - 0)
	$column_Width_RadioType = _GUICtrlListView_GetColumnWidth($ListviewAPs, $column_RadioType - 0)
	$column_Width_Channel = _GUICtrlListView_GetColumnWidth($ListviewAPs, $column_Channel - 0)
	$column_Width_Latitude = _GUICtrlListView_GetColumnWidth($ListviewAPs, $column_Latitude - 0)
	$column_Width_Longitude = _GUICtrlListView_GetColumnWidth($ListviewAPs, $column_Longitude - 0)
	$column_Width_LatitudeDMS = _GUICtrlListView_GetColumnWidth($ListviewAPs, $column_LatitudeDMS - 0)
	$column_Width_LongitudeDMS = _GUICtrlListView_GetColumnWidth($ListviewAPs, $column_LongitudeDMS - 0)
	$column_Width_LatitudeDMM = _GUICtrlListView_GetColumnWidth($ListviewAPs, $column_LatitudeDMM - 0)
	$column_Width_LongitudeDMM = _GUICtrlListView_GetColumnWidth($ListviewAPs, $column_LongitudeDMM - 0)
	$column_Width_BasicTransferRates = _GUICtrlListView_GetColumnWidth($ListviewAPs, $column_BasicTransferRates - 0)
	$column_Width_OtherTransferRates = _GUICtrlListView_GetColumnWidth($ListviewAPs, $column_OtherTransferRates - 0)
	$column_Width_FirstActive = _GUICtrlListView_GetColumnWidth($ListviewAPs, $column_FirstActive - 0)
	$column_Width_LastActive = _GUICtrlListView_GetColumnWidth($ListviewAPs, $column_LastActive - 0)
	$column_Width_NetworkType = _GUICtrlListView_GetColumnWidth($ListviewAPs, $column_NetworkType - 0)
	$column_Width_Label = _GUICtrlListView_GetColumnWidth($ListviewAPs, $column_Label - 0)
EndFunc   ;==>_GetListviewWidths

Func _TreeViewAdd($ImpApID, $ImpSSID, $ImpBSSID, $ImpCHAN, $ImpNET, $ImpENCR, $ImpRAD, $ImpAUTH, $ImpBTX, $ImpOTX, $ImpMANU, $ImpLAB)
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_TreeViewAdd()') ;#Debug Display
	;Format Treeview Names
	$channel_treeviewname = StringFormat("%03i", $ImpCHAN)
	$SSID_treeviewname = '(' & $ImpSSID & ')'
	$Encryption_treeviewname = $ImpENCR
	$Authentication_treeviewname = $ImpAUTH
	$NetworkType_treeviewname = $ImpNET
	;Create sub menu item for AP details
	_AddTreeviewItem('CHAN', $TreeviewAPs, $channel_tree, $channel_treeviewname, $ImpApID, $ImpSSID, $ImpBSSID, $ImpCHAN, $ImpNET, $ImpENCR, $ImpRAD, $ImpAUTH, $ImpBTX, $ImpOTX, $ImpMANU, $ImpLAB)
	_AddTreeviewItem('SSID', $TreeviewAPs, $SSID_tree, $SSID_treeviewname, $ImpApID, $ImpSSID, $ImpBSSID, $ImpCHAN, $ImpNET, $ImpENCR, $ImpRAD, $ImpAUTH, $ImpBTX, $ImpOTX, $ImpMANU, $ImpLAB)
	_AddTreeviewItem('ENCR', $TreeviewAPs, $Encryption_tree, $Encryption_treeviewname, $ImpApID, $ImpSSID, $ImpBSSID, $ImpCHAN, $ImpNET, $ImpENCR, $ImpRAD, $ImpAUTH, $ImpBTX, $ImpOTX, $ImpMANU, $ImpLAB)
	_AddTreeviewItem('AUTH', $TreeviewAPs, $Authentication_tree, $Authentication_treeviewname, $ImpApID, $ImpSSID, $ImpBSSID, $ImpCHAN, $ImpNET, $ImpENCR, $ImpRAD, $ImpAUTH, $ImpBTX, $ImpOTX, $ImpMANU, $ImpLAB)
	_AddTreeviewItem('NETTYPE', $TreeviewAPs, $NetworkType_tree, $NetworkType_treeviewname, $ImpApID, $ImpSSID, $ImpBSSID, $ImpCHAN, $ImpNET, $ImpENCR, $ImpRAD, $ImpAUTH, $ImpBTX, $ImpOTX, $ImpMANU, $ImpLAB)
EndFunc   ;==>_TreeViewAdd

Func _AddTreeviewItem($RootTree, $Treeview, $tree, $SubTreeName, $ImpApID, $ImpSSID, $ImpBSSID, $ImpCHAN, $ImpNET, $ImpENCR, $ImpRAD, $ImpAUTH, $ImpBTX, $ImpOTX, $ImpMANU, $ImpLAB)
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_AddTreeviewItem()') ;#Debug Display
	$query = "SELECT TOP 1 SubTreePos FROM TreeviewPos WHERE RootTree='" & $RootTree & "' And SubTreeName='" & StringReplace($SubTreeName, "'", "''") & "'"
	$TreeMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
	$FoundTreeMatch = UBound($TreeMatchArray) - 1
	If $FoundTreeMatch = 0 Then
		$treeviewposition = _GUICtrlTreeView_InsertItem($Treeview, $SubTreeName, $tree)
	Else
		$treeviewposition = $TreeMatchArray[1][1]
	EndIf
	$subtreeviewposition = _GUICtrlTreeView_InsertItem($Treeview, '(' & $ImpSSID & ')', $treeviewposition)
	$st_ssid = _GUICtrlTreeView_InsertItem($Treeview, $Column_Names_SSID & ' : ' & $ImpSSID, $subtreeviewposition)
	$st_bssid = _GUICtrlTreeView_InsertItem($Treeview, $Column_Names_BSSID & ' : ' & $ImpBSSID, $subtreeviewposition)
	$st_chan = _GUICtrlTreeView_InsertItem($Treeview, $Column_Names_Channel & ' : ' & StringFormat("%03i", $ImpCHAN), $subtreeviewposition)
	$st_net = _GUICtrlTreeView_InsertItem($Treeview, $Column_Names_NetworkType & ' : ' & $ImpNET, $subtreeviewposition)
	$st_encr = _GUICtrlTreeView_InsertItem($Treeview, $Column_Names_Encryption & ' : ' & $ImpENCR, $subtreeviewposition)
	$st_rad = _GUICtrlTreeView_InsertItem($Treeview, $Column_Names_RadioType & ' : ' & $ImpRAD, $subtreeviewposition)
	$st_auth = _GUICtrlTreeView_InsertItem($Treeview, $Column_Names_Authentication & ' : ' & $ImpAUTH, $subtreeviewposition)
	$st_btx = _GUICtrlTreeView_InsertItem($Treeview, $Column_Names_BasicTransferRates & ' : ' & $ImpBTX, $subtreeviewposition)
	$st_otx = _GUICtrlTreeView_InsertItem($Treeview, $Column_Names_OtherTransferRates & ' : ' & $ImpOTX, $subtreeviewposition)
	$st_manu = _GUICtrlTreeView_InsertItem($Treeview, $Column_Names_MANUF & ' : ' & $ImpMANU, $subtreeviewposition)
	$st_lab = _GUICtrlTreeView_InsertItem($Treeview, $Column_Names_Label & ' : ' & $ImpLAB, $subtreeviewposition)
	;Write treeview position information to DB
	ReDim $AddTreeRecordArray[17]
	$AddTreeRecordArray[0] = 16
	$AddTreeRecordArray[1] = $ImpApID
	$AddTreeRecordArray[2] = $RootTree
	$AddTreeRecordArray[3] = $SubTreeName
	$AddTreeRecordArray[4] = $treeviewposition
	$AddTreeRecordArray[5] = $subtreeviewposition
	$AddTreeRecordArray[6] = $st_ssid
	$AddTreeRecordArray[7] = $st_bssid
	$AddTreeRecordArray[8] = $st_chan
	$AddTreeRecordArray[9] = $st_net
	$AddTreeRecordArray[10] = $st_encr
	$AddTreeRecordArray[11] = $st_rad
	$AddTreeRecordArray[12] = $st_auth
	$AddTreeRecordArray[13] = $st_btx
	$AddTreeRecordArray[14] = $st_otx
	$AddTreeRecordArray[15] = $st_manu
	$AddTreeRecordArray[16] = $st_lab
	_AddRecord($VistumblerDB, "TreeviewPos", $DB_OBJ, $AddTreeRecordArray)
EndFunc   ;==>_AddTreeviewItem

Func _TreeViewRemove($ImpApID)
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_TreeViewRemove()') ;#Debug Display
	_RemoveTreeviewItem($TreeviewAPs, 'CHAN', $ImpApID)
	_RemoveTreeviewItem($TreeviewAPs, 'SSID', $ImpApID)
	_RemoveTreeviewItem($TreeviewAPs, 'ENCR', $ImpApID)
	_RemoveTreeviewItem($TreeviewAPs, 'AUTH', $ImpApID)
	_RemoveTreeviewItem($TreeviewAPs, 'NETTYPE', $ImpApID)
EndFunc   ;==>_TreeViewRemove

Func _RemoveTreeviewItem($Treeview, $RootTree, $ImpApID)
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_RemoveTreeviewItem()') ;#Debug Display
	$query = "SELECT SubTreePos, InfoSubPos FROM TreeviewPos WHERE ApID=" & $ImpApID & " And RootTree='" & $RootTree & "'"
	$TreeMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
	$FoundTreeMatch = UBound($TreeMatchArray) - 1
	If $FoundTreeMatch = 1 Then
		$STP = $TreeMatchArray[1][1]
		$ISP = $TreeMatchArray[1][2]
		$query = "SELECT TOP 1 SubTreePos FROM TreeviewPos WHERE ApID<>" & $ImpApID & " And SubTreePos=" & $STP & " And RootTree='" & $RootTree & "'"
		$TreeMatchArray2 = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
		$FoundTreeMatch2 = UBound($TreeMatchArray2) - 1
		If $FoundTreeMatch2 = 0 Then _GUICtrlTreeView_Delete($Treeview, $STP)
	EndIf
	$query = "DELETE FROM TreeviewPos WHERE ApID=" & $ImpApID & " And RootTree='" & $RootTree & "'"
	_ExecuteMDB($VistumblerDB, $DB_OBJ, $query)
EndFunc   ;==>_RemoveTreeviewItem

Func _FilterRemoveNonMatchingInList($Batch = 0)
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_FilterRemoveNonMatchingInList()') ;#Debug Display
	If $Batch = 1 Or $TempBatchListviewDelete = 1 Then
		_GUICtrlListView_BeginUpdate($ListviewAPs)
		_GUICtrlTreeView_BeginUpdate($TreeviewAPs)
	EndIf
	If StringInStr($RemoveQuery, 'WHERE') Then
		$query = $RemoveQuery & " And (Listrow<>-1)"
		$ApMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
		If $ApMatchArray[0][0] <> 0 Then
			For $frnm = 1 To $ApMatchArray[0][0]
				$fApID = $ApMatchArray[$frnm][1]
				;Get ListRow of AP
				$query = "Select ListRow FROM AP WHERE ApID=" & $fApID
				;ConsoleWrite($query & @CRLF)
				$ListRowArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
				$fListRow = $ListRowArray[1][1]
				_TreeViewRemove($fApID)
				;Delete AP Row
				_GUICtrlListView_DeleteItem($ListviewAPs, $fListRow)
				;Set AP ListRow to -1
				$query = "UPDATE AP SET ListRow=-1 WHERE ApID=" & $fApID
				_ExecuteMDB($VistumblerDB, $DB_OBJ, $query)
				;Subtract 1 from all listsrows higher that the one being deleted
				$query = "Select ApID, ListRow FROM AP WHERE ListRow<>-1"
				$ListRowArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
				$ListRowMatch = UBound($ListRowArray) - 1
				If $ListRowMatch <> 0 Then
					For $lrnu = 1 To $ListRowMatch
						$lApID = $ListRowArray[$lrnu][1]
						$lListRow = $ListRowArray[$lrnu][2]
						If StringFormat("%09i", $lListRow) > StringFormat("%09i", $fListRow) Then
							$nListRow = $lListRow - 1
							$query = "UPDATE AP SET ListRow=" & $nListRow & " WHERE ApID=" & $lApID
							_ExecuteMDB($VistumblerDB, $DB_OBJ, $query)
						EndIf
					Next
					_FixListIcons()
				EndIf
			Next
		EndIf
	EndIf
	If $Batch = 1  Or $TempBatchListviewDelete = 1 Then
		_GUICtrlListView_EndUpdate($ListviewAPs)
		_GUICtrlTreeView_EndUpdate($TreeviewAPs)
		$TempBatchListviewDelete = 0
	EndIf
EndFunc   ;==>_FilterRemoveNonMatchingInList

Func _UpdateListview($Batch = 0)
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_UpdateListview()') ;#Debug Display
	If $Batch = 1 Or $TempBatchListviewInsert = 1 Then
		_GUICtrlListView_BeginUpdate($ListviewAPs)
		_GUICtrlTreeView_BeginUpdate($TreeviewAPs)
	EndIf
	;Find APs that meet criteria but are not in the listview
	If StringInStr($AddQuery, "WHERE") Then
		$fquery = $AddQuery & " AND ListRow=-1"
	Else
		$fquery = $AddQuery & " WHERE ListRow=-1"
	EndIf
	$LoadApMatchArray = _RecordSearch($VistumblerDB, $fquery, $DB_OBJ)
	$FoundLoadApMatch = UBound($LoadApMatchArray) - 1

	If $AutoSort = 0 Then
		For $imp = 1 To $FoundLoadApMatch
			$ImpApID = $LoadApMatchArray[$imp][1]
			$ImpSSID = $LoadApMatchArray[$imp][2]
			$ImpBSSID = $LoadApMatchArray[$imp][3]
			$ImpNET = $LoadApMatchArray[$imp][4]
			$ImpRAD = $LoadApMatchArray[$imp][5]
			$ImpCHAN = $LoadApMatchArray[$imp][6]
			$ImpAUTH = $LoadApMatchArray[$imp][7]
			$ImpENCR = $LoadApMatchArray[$imp][8]
			$ImpSecType = $LoadApMatchArray[$imp][9]
			$ImpBTX = $LoadApMatchArray[$imp][10]
			$ImpOTX = $LoadApMatchArray[$imp][11]
			$ImpMANU = $LoadApMatchArray[$imp][12]
			$ImpLAB = $LoadApMatchArray[$imp][13]
			$ImpHighGpsHistID = $LoadApMatchArray[$imp][14]
			$ImpFirstHistID = $LoadApMatchArray[$imp][15]
			$ImpLastHistID = $LoadApMatchArray[$imp][16]
			$ImpLastGpsID = $LoadApMatchArray[$imp][17]
			$ImpActive = $LoadApMatchArray[$imp][18]
			$ImpHighSignal = $LoadApMatchArray[$imp][19]
			$ImpHighRSSI = $LoadApMatchArray[$imp][20]
			;Get GPS Position
			If $ImpHighGpsHistID = 0 Then
				$ImpLat = 'N 0000.0000'
				$ImpLon = 'E 0000.0000'
			Else
				$query = "SELECT GpsID FROM Hist WHERE HistID=" & $ImpHighGpsHistID
				$HistMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
				$ImpGID = $HistMatchArray[1][1]
				$query = "SELECT Latitude, Longitude FROM GPS WHERE GpsID=" & $ImpGID
				$GpsMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
				$FoundGpsMatch = UBound($GpsMatchArray) - 1
				$ImpLat = $GpsMatchArray[1][1]
				$ImpLon = $GpsMatchArray[1][2]
			EndIf
			;Get First Time
			$query = "SELECT Date1, Time1 FROM Hist WHERE HistID=" & $ImpFirstHistID
			$HistMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
			$ImpDate = $HistMatchArray[1][1]
			$ImpTime = $HistMatchArray[1][2]
			$ImpFirstDateTime = $ImpDate & ' ' & $ImpTime
			;Get Last Time
			$query = "SELECT Date1, Time1, Signal, RSSI FROM Hist WHERE HistID=" & $ImpLastHistID
			$HistMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
			$ImpDate = $HistMatchArray[1][1]
			$ImpTime = $HistMatchArray[1][2]
			$ImpSig = $HistMatchArray[1][3]
			$ImpRSSI = $HistMatchArray[1][4]
			$ImpLastDateTime = $ImpDate & ' ' & $ImpTime
			;If AP is not active, mark as dead and set signal to 0
			If $ImpActive <> 0 And $ImpSig <> 0 Then
				$LActive = $Text_Active
			Else
				$LActive = $Text_Dead
				$ImpSig = '0'
				$ImpRSSI = '-100'
			EndIf

			;Add APs to top of list
			If $AddDirection = 0 Then
				$query = "UPDATE AP SET ListRow=ListRow+1 WHERE ListRow<>-1"
				_ExecuteMDB($VistumblerDB, $DB_OBJ, $query)
				$DBAddPos = 0
			Else ;Add to bottom
				$DBAddPos = -1
			EndIf

			;Add New Listrow with Icon
			If $Batch = 0 And $TempBatchListviewInsert = 0 Then _GUICtrlListView_BeginUpdate($ListviewAPs)
			$ListRow = _AddIconListRow($ImpSig, $ImpSecType, $ImpApID, $DBAddPos)
			_ListViewAdd($ListRow, $ImpApID, $LActive, $ImpBSSID, $ImpSSID, $ImpAUTH, $ImpENCR, $ImpSig, $ImpHighSignal, $ImpRSSI, $ImpHighRSSI, $ImpCHAN, $ImpRAD, $ImpBTX, $ImpOTX, $ImpNET, $ImpFirstDateTime, $ImpLastDateTime, $ImpLat, $ImpLon, $ImpMANU, $ImpLAB)
			If $Batch = 0 And $TempBatchListviewInsert = 0 Then _GUICtrlListView_EndUpdate($ListviewAPs)
			$query = "UPDATE AP SET ListRow=" & $ListRow & " WHERE ApID=" & $ImpApID
			_ExecuteMDB($VistumblerDB, $DB_OBJ, $query)
			;Add Into TreeView
			If $Batch = 0 And $TempBatchListviewInsert = 0 Then _GUICtrlTreeView_BeginUpdate($TreeviewAPs)
			_TreeViewAdd($ImpApID, $ImpSSID, $ImpBSSID, $ImpCHAN, $ImpNET, $ImpENCR, $ImpRAD, $ImpAUTH, $ImpBTX, $ImpOTX, $ImpMANU, $ImpLAB)
			If $Batch = 0 And $TempBatchListviewInsert = 0 Then _GUICtrlTreeView_EndUpdate($TreeviewAPs)
		Next
	Else
		Local $ListRowPos = -1, $DbColName, $SortDir
		;Mark APs that are not in the list but meet the criteria
		For $imp = 1 To $FoundLoadApMatch
			;Set the ListRow to -2 so it gets added later
			$ImpApID = $LoadApMatchArray[$imp][1]
			$query = "UPDATE AP SET ListRow=-2 WHERE ApID=" & $ImpApID
			_ExecuteMDB($VistumblerDB, $DB_OBJ, $query)
		Next
		;Get Sort Direction from settings
		If $SortDirection = 1 Then
			$SortDir = "DESC"
		Else
			$SortDir = "ASC"
		EndIf
		$DbCol = _GetDbColNameByListColName($SortBy) ;Set DB Column to sort by
		;ConsoleWrite("$DbCol:" & $DbCol & " $SortDir:" & $SortDir & @CRLF)
		If $DbCol = "Latitude" Or $DbCol = "Longitude" Then ; Sort by Latitude Or Longitude
			;Add results that have no GPS postion first if DESC
			If $SortDir = "DESC" Then
				$query = "SELECT ListRow, ApID, SSID, BSSID, NETTYPE, RADTYPE, CHAN, AUTH, ENCR, SecType, BTX, OTX, MANU, LABEL, HighGpsHistID, FirstHistID, LastHistID, LastGpsID, Active, Signal, HighSignal, RSSI, HighRSSI FROM AP WHERE HighGpsHistID=0 And ListRow<>-1 ORDER BY ApID " & $SortDir
				$ListRowPos = __UpdateListviewDbQueryToList($query, $ListRowPos)
			EndIf
			;Add sorted results with GPS
			If $DbCol = "Latitude" Then $query = "SELECT AP.ListRow, AP.ApID, AP.SSID, AP.BSSID, AP.NETTYPE, AP.RADTYPE, AP.CHAN, AP.AUTH, AP.ENCR, AP.SecType, AP.BTX, AP.OTX, AP.MANU, AP.LABEL, AP.HighGpsHistID, AP.FirstHistID, AP.LastHistID, AP.LastGpsID, AP.Active, AP.Signal, AP.HighSignal, AP.RSSI, AP.HighRSSI FROM (AP INNER JOIN Hist ON AP.HighGpsHistId = Hist.HistID) INNER JOIN GPS ON Hist.GpsID = GPS.GPSID WHERE ListRow<>-1 ORDER BY GPS.Latitude " & $SortDir & ", GPS.Longitude " & $SortDir & ", AP.ApID " & $SortDir
			If $DbCol = "Longitude" Then $query = "SELECT AP.ListRow, AP.ApID, AP.SSID, AP.BSSID, AP.NETTYPE, AP.RADTYPE, AP.CHAN, AP.AUTH, AP.ENCR, AP.SecType, AP.BTX, AP.OTX, AP.MANU, AP.LABEL, AP.HighGpsHistID, AP.FirstHistID, AP.LastHistID, AP.LastGpsID, AP.Active, AP.Signal, AP.HighSignal, AP.RSSI, AP.HighRSSI FROM (AP INNER JOIN Hist ON AP.HighGpsHistId = Hist.HistID) INNER JOIN GPS ON Hist.GpsID = GPS.GPSID WHERE ListRow<>-1 ORDER BY GPS.Longitude " & $SortDir & ", GPS.Latitude " & $SortDir & ", AP.ApID " & $SortDir
			$ListRowPos = __UpdateListviewDbQueryToList($query, $ListRowPos)
			;Add results that have no GPS postion last if ASC
			If $SortDir = "ASC" Then
				$query = "SELECT ListRow, ApID, SSID, BSSID, NETTYPE, RADTYPE, CHAN, AUTH, ENCR, SecType, BTX, OTX, MANU, LABEL, HighGpsHistID, FirstHistID, LastHistID, LastGpsID, Active, Signal, HighSignal, RSSI, HighRSSI FROM AP WHERE HighGpsHistID=0 And ListRow<>-1 ORDER BY ApID " & $SortDir
				$ListRowPos = __UpdateListviewDbQueryToList($query, $ListRowPos)
			EndIf
		ElseIf $DbCol = "FirstActive" Then ; Sort by First Active Time
			$query = "SELECT AP.ListRow, AP.ApID, AP.SSID, AP.BSSID, AP.NETTYPE, AP.RADTYPE, AP.CHAN, AP.AUTH, AP.ENCR, AP.SecType, AP.BTX, AP.OTX, AP.MANU, AP.LABEL, AP.HighGpsHistID, AP.FirstHistID, AP.LastHistID, AP.LastGpsID, AP.Active, AP.Signal, AP.HighSignal, AP.RSSI, AP.HighRSSI, Hist.Date1, Hist.Time1 FROM AP INNER JOIN Hist ON AP.FirstHistID = Hist.HistID WHERE ListRow<>-1 ORDER BY Hist.Date1 " & $SortDir & ", Hist.Time1 " & $SortDir & ", AP.ApID " & $SortDir
			$ListRowPos = __UpdateListviewDbQueryToList($query, $ListRowPos)
		ElseIf $DbCol = "LastActive" Then ; Sort by Last Active Time
			$query = "SELECT AP.ListRow, AP.ApID, AP.SSID, AP.BSSID, AP.NETTYPE, AP.RADTYPE, AP.CHAN, AP.AUTH, AP.ENCR, AP.SecType, AP.BTX, AP.OTX, AP.MANU, AP.LABEL, AP.HighGpsHistID, AP.FirstHistID, AP.LastHistID, AP.LastGpsID, AP.Active, AP.Signal, AP.HighSignal, AP.RSSI, AP.HighRSSI, Hist.Date1, Hist.Time1 FROM AP INNER JOIN Hist ON AP.LastHistID = Hist.HistID WHERE ListRow<>-1 ORDER BY Hist.Date1 " & $SortDir & ", Hist.Time1 " & $SortDir & ", AP.ApID " & $SortDir
			$ListRowPos = __UpdateListviewDbQueryToList($query, $ListRowPos)
		ElseIf $DbCol = "Signal" Or $DbCol = "HighSignal" Or $DbCol = "RSSI" Or $DbCol = "HighRSSI" Or $DbCol = "CHAN" Then ; Sort by Last Active Time
			$query = "SELECT ListRow, ApID, SSID, BSSID, NETTYPE, RADTYPE, CHAN, AUTH, ENCR, SecType, BTX, OTX, MANU, LABEL, HighGpsHistID, FirstHistID, LastHistID, LastGpsID, Active, Signal, HighSignal, RSSI, HighRSSI FROM AP WHERE ListRow<>-1 ORDER BY " & $DbCol & " " & $SortDir & ", ApID " & $SortDir
			$ListRowPos = __UpdateListviewDbQueryToList($query, $ListRowPos)
		Else ; Sort by any other column
			$query = "SELECT ListRow, ApID, SSID, BSSID, NETTYPE, RADTYPE, CHAN, AUTH, ENCR, SecType, BTX, OTX, MANU, LABEL, HighGpsHistID, FirstHistID, LastHistID, LastGpsID, Active, Signal, HighSignal, RSSI, HighRSSI FROM AP WHERE ListRow<>-1 ORDER BY " & $DbCol & " " & $SortDir & ", ApID " & $SortDir
			$ListRowPos = __UpdateListviewDbQueryToList($query, $ListRowPos)
		EndIf
	EndIf
	If $Batch = 1  Or $TempBatchListviewInsert = 1 Then
		_GUICtrlListView_EndUpdate($ListviewAPs)
		_GUICtrlTreeView_EndUpdate($TreeviewAPs)
		$TempBatchListviewInsert = 0
	EndIf
EndFunc   ;==>_UpdateListview

Func __UpdateListviewDbQueryToList($query, $listpos)
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '__UpdateListviewDbQueryToList()') ;#Debug Display
	If $MinimalGuiMode = 0 Then
		$ListCurrentRowCount = _GUICtrlListView_GetItemCount($ListviewAPs)
		$ApMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
		$FoundApMatch = UBound($ApMatchArray) - 1
		For $wlv = 1 To $FoundApMatch
			$listpos += 1
			$Found_ListRow = $ApMatchArray[$wlv][1]
			If $Found_ListRow <> $listpos Then ;If row has changed, update list information
				$Found_APID = $ApMatchArray[$wlv][2]
				$Found_SSID = $ApMatchArray[$wlv][3]
				$Found_BSSID = $ApMatchArray[$wlv][4]
				$Found_NETTYPE = $ApMatchArray[$wlv][5]
				$Found_RADTYPE = $ApMatchArray[$wlv][6]
				$Found_CHAN = $ApMatchArray[$wlv][7]
				$Found_AUTH = $ApMatchArray[$wlv][8]
				$Found_ENCR = $ApMatchArray[$wlv][9]
				$Found_SecType = $ApMatchArray[$wlv][10]
				$Found_BTX = $ApMatchArray[$wlv][11]
				$Found_OTX = $ApMatchArray[$wlv][12]
				$Found_MANU = $ApMatchArray[$wlv][13]
				$Found_LABEL = $ApMatchArray[$wlv][14]
				$Found_HighGpsHistId = $ApMatchArray[$wlv][15]
				$Found_FirstHistID = $ApMatchArray[$wlv][16]
				$Found_LastHistID = $ApMatchArray[$wlv][17]
				$Found_LastGpsID = $ApMatchArray[$wlv][18]
				$Found_Active = $ApMatchArray[$wlv][19]
				$Found_Signal = $ApMatchArray[$wlv][20]
				$Found_HighSignal = $ApMatchArray[$wlv][21]
				$Found_RSSI = $ApMatchArray[$wlv][22]
				$Found_HighRSSI = $ApMatchArray[$wlv][23]

				;Get First Time
				$query = "SELECT Date1, Time1 FROM Hist WHERE HistID=" & $Found_FirstHistID
				$HistMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
				$Found_FirstDate = $HistMatchArray[1][1]
				$Found_FirstTime = $HistMatchArray[1][2]
				$Found_FirstDateTime = $Found_FirstDate & ' ' & $Found_FirstTime

				;Get Last Time
				$query = "SELECT Date1, Time1 FROM Hist WHERE HistID=" & $Found_LastHistID
				$HistMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
				$Found_LastDate = $HistMatchArray[1][1]
				$Found_LastTime = $HistMatchArray[1][2]
				$Found_LastDateTime = $Found_LastDate & ' ' & $Found_LastTime

				;Get GPS Position
				If $Found_HighGpsHistId = 0 Then
					$Found_Lat = "N 0000.0000"
					$Found_Lon = "E 0000.0000"
				Else
					$query = "SELECT GpsID FROM Hist WHERE HistID=" & $Found_HighGpsHistId
					$HistMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
					$Found_GpsID = $HistMatchArray[1][1]
					$query = "SELECT Latitude, Longitude FROM GPS WHERE GPSID=" & $Found_GpsID
					$GpsMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
					$Found_Lat = $GpsMatchArray[1][1]
					$Found_Lon = $GpsMatchArray[1][2]
				EndIf

				If $wlv > $ListCurrentRowCount Then
					;Add new row with icon to the bottom of the list
					_GUICtrlListView_BeginUpdate($ListviewAPs)
					$ListRow = _AddIconListRow($Found_Signal, $Found_SecType, $Found_APID, -1)
					;Write changes to listview
					_ListViewAdd($ListRow, $Found_APID, $Found_Active, $Found_BSSID, $Found_SSID, $Found_AUTH, $Found_ENCR, $Found_Signal, $Found_HighSignal, $Found_RSSI, $Found_HighRSSI, $Found_CHAN, $Found_RADTYPE, $Found_BTX, $Found_OTX, $Found_NETTYPE, $Found_FirstDateTime, $Found_LastDateTime, $Found_Lat, $Found_Lon, $Found_MANU, $Found_LABEL)
					_GUICtrlListView_EndUpdate($ListviewAPs)
					;Update ListRow
					$query = "UPDATE AP SET ListRow=" & $ListRow & " WHERE ApID=" & $Found_APID
					_ExecuteMDB($VistumblerDB, $DB_OBJ, $query)
					;Add Into TreeView
					_GUICtrlTreeView_BeginUpdate($TreeviewAPs)
					_TreeViewAdd($Found_APID, $Found_SSID, $Found_BSSID, $Found_CHAN, $Found_NETTYPE, $Found_ENCR, $Found_RADTYPE, $Found_AUTH, $Found_BTX, $Found_OTX, $Found_MANU, $Found_LABEL)
					_GUICtrlTreeView_EndUpdate($TreeviewAPs)
				Else
					;Write changes to listview
					_GUICtrlListView_BeginUpdate($ListviewAPs)
					_GUICtrlListView_BeginUpdate($ListviewAPs)
					_ListViewAdd($listpos, $Found_APID, $Found_Active, $Found_BSSID, $Found_SSID, $Found_AUTH, $Found_ENCR, $Found_Signal, $Found_HighSignal, $Found_RSSI, $Found_HighRSSI, $Found_CHAN, $Found_RADTYPE, $Found_BTX, $Found_OTX, $Found_NETTYPE, $Found_FirstDateTime, $Found_LastDateTime, $Found_Lat, $Found_Lon, $Found_MANU, $Found_LABEL)
					;Update ListRow Icon
					_UpdateIcon($listpos, $Found_Signal, $Found_SecType)
					_GUICtrlListView_EndUpdate($ListviewAPs)
					;Update ListRow
					$query = "UPDATE AP SET ListRow=" & $listpos & " WHERE ApID=" & $Found_APID
					_ExecuteMDB($VistumblerDB, $DB_OBJ, $query)
				EndIf
			EndIf
		Next
		;Remove extra rows
		If $ListCurrentRowCount > $FoundApMatch Then
			_GUICtrlListView_BeginUpdate($ListviewAPs)
			For $remrow = $FoundApMatch To $ListCurrentRowCount
				_GUICtrlListView_DeleteItem($ListviewAPs, $remrow)
			Next
			_GUICtrlListView_EndUpdate($ListviewAPs)
		EndIf
	EndIf
EndFunc   ;==>__UpdateListviewDbQueryToList

Func _ClearAllAp()
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_ClearAllAp()') ;#Debug Display
	;Reset Variables
	$APID = 0
	$CamID = 0
	$GPS_ID = 0
	$HISTID = 0
	;Clear DB
	$query = "DELETE * FROM AP"
	_ExecuteMDB($VistumblerDB, $DB_OBJ, $query)
	$query = "DELETE * FROM Cam"
	_ExecuteMDB($VistumblerDB, $DB_OBJ, $query)
	$query = "DELETE * FROM GPS"
	_ExecuteMDB($VistumblerDB, $DB_OBJ, $query)
	$query = "DELETE * FROM Hist"
	_ExecuteMDB($VistumblerDB, $DB_OBJ, $query)
	$query = "DELETE * FROM TreeviewPos"
	_ExecuteMDB($VistumblerDB, $DB_OBJ, $query)
	$query = "DELETE * FROM LoadedFiles"
	_ExecuteMDB($VistumblerDB, $DB_OBJ, $query)
	;Update Column Widths
	_GetListviewWidths()
	;Update Column Order
	Local $sheaders
	$currentcolumn = StringSplit(_GUICtrlListView_GetColumnOrder($ListviewAPs), '|')
	For $c = 1 To $currentcolumn[0]
		$cinfo = _GUICtrlListView_GetColumn($ListviewAPs, $currentcolumn[$c] - 0)
		$sheaders &= $cinfo[5] & '|'
		If $column_Line = $currentcolumn[$c] Then $save_column_Line = $c - 1
		If $column_Active = $currentcolumn[$c] Then $save_column_Active = $c - 1
		If $column_BSSID = $currentcolumn[$c] Then $save_column_BSSID = $c - 1
		If $column_SSID = $currentcolumn[$c] Then $save_column_SSID = $c - 1
		If $column_Signal = $currentcolumn[$c] Then $save_column_Signal = $c - 1
		If $column_HighSignal = $currentcolumn[$c] Then $save_column_HighSignal = $c - 1
		If $column_RSSI = $currentcolumn[$c] Then $save_column_RSSI = $c - 1
		If $column_HighRSSI = $currentcolumn[$c] Then $save_column_HighRSSI = $c - 1
		If $column_Channel = $currentcolumn[$c] Then $save_column_Channel = $c - 1
		If $column_Authentication = $currentcolumn[$c] Then $save_column_Authentication = $c - 1
		If $column_Encryption = $currentcolumn[$c] Then $save_column_Encryption = $c - 1
		If $column_NetworkType = $currentcolumn[$c] Then $save_column_NetworkType = $c - 1
		If $column_Latitude = $currentcolumn[$c] Then $save_column_Latitude = $c - 1
		If $column_Longitude = $currentcolumn[$c] Then $save_column_Longitude = $c - 1
		If $column_MANUF = $currentcolumn[$c] Then $save_column_MANUF = $c - 1
		If $column_Label = $currentcolumn[$c] Then $save_column_Label = $c - 1
		If $column_RadioType = $currentcolumn[$c] Then $save_column_RadioType = $c - 1
		If $column_LatitudeDMS = $currentcolumn[$c] Then $save_column_LatitudeDMS = $c - 1
		If $column_LongitudeDMS = $currentcolumn[$c] Then $save_column_LongitudeDMS = $c - 1
		If $column_LatitudeDMM = $currentcolumn[$c] Then $save_column_LatitudeDMM = $c - 1
		If $column_LongitudeDMM = $currentcolumn[$c] Then $save_column_LongitudeDMM = $c - 1
		If $column_BasicTransferRates = $currentcolumn[$c] Then $save_column_BasicTransferRates = $c - 1
		If $column_OtherTransferRates = $currentcolumn[$c] Then $save_column_OtherTransferRates = $c - 1
		If $column_FirstActive = $currentcolumn[$c] Then $save_column_FirstActive = $c - 1
		If $column_LastActive = $currentcolumn[$c] Then $save_column_LastActive = $c - 1
	Next
	$headers = $sheaders
	$column_Line = $save_column_Line
	$column_Active = $save_column_Active
	$column_BSSID = $save_column_BSSID
	$column_SSID = $save_column_SSID
	$column_Signal = $save_column_Signal
	$column_HighSignal = $save_column_HighSignal
	$column_RSSI = $save_column_RSSI
	$column_HighRSSI = $save_column_HighRSSI
	$column_Channel = $save_column_Channel
	$column_Authentication = $save_column_Authentication
	$column_Encryption = $save_column_Encryption
	$column_NetworkType = $save_column_NetworkType
	$column_Latitude = $save_column_Latitude
	$column_Longitude = $save_column_Longitude
	$column_MANUF = $save_column_MANUF
	$column_Label = $save_column_Label
	$column_RadioType = $save_column_RadioType
	$column_LatitudeDMS = $save_column_LatitudeDMS
	$column_LongitudeDMS = $save_column_LongitudeDMS
	$column_LatitudeDMM = $save_column_LatitudeDMM
	$column_LongitudeDMM = $save_column_LongitudeDMM
	$column_BasicTransferRates = $save_column_BasicTransferRates
	$column_OtherTransferRates = $save_column_OtherTransferRates
	$column_FirstActive = $save_column_FirstActive
	$column_LastActive = $save_column_LastActive
	;Recreate Listview
	GUISwitch($Vistumbler)
	_GUICtrlListView_DeleteAllItems($ListviewAPs)
	;GUICtrlDelete($ListviewAPs)
	;$ListviewAPs = GUICtrlCreateListView($headers, $ListviewAPs_left, $ListviewAPs_top, $ListviewAPs_width, $ListviewAPs_height, $LVS_REPORT + $LVS_SINGLESEL, $LVS_EX_HEADERDRAGDROP + $LVS_EX_GRIDLINES + $LVS_EX_FULLROWSELECT)
	;$ListviewAPs = _GUICtrlListView_Create($Vistumbler, $headers, 260, 65, 725, 585, BitOR($LVS_REPORT, $LVS_SINGLESEL))
	;_GUICtrlListView_SetExtendedListViewStyle($ListviewAPs, BitOR($LVS_EX_HEADERDRAGDROP, $LVS_EX_GRIDLINES, $LVS_EX_FULLROWSELECT, $LVS_EX_DOUBLEBUFFER))
	;$hImage = _GUIImageList_Create()
	;_GUIImageList_AddIcon($hImage, $IconDir & "Signal\open-grey.ico")
	;_GUIImageList_AddIcon($hImage, $IconDir & "Signal\open-red.ico")
	;_GUIImageList_AddIcon($hImage, $IconDir & "Signal\open-orange.ico")
	;_GUIImageList_AddIcon($hImage, $IconDir & "Signal\open-yellow.ico")
	;_GUIImageList_AddIcon($hImage, $IconDir & "Signal\open-light-green.ico")
	;_GUIImageList_AddIcon($hImage, $IconDir & "Signal\open-green.ico")
	;_GUIImageList_AddIcon($hImage, $IconDir & "Signal\sec-grey.ico")
	;_GUIImageList_AddIcon($hImage, $IconDir & "Signal\sec-red.ico")
	;_GUIImageList_AddIcon($hImage, $IconDir & "Signal\sec-orange.ico")
	;_GUIImageList_AddIcon($hImage, $IconDir & "Signal\sec-yellow.ico")
	;_GUIImageList_AddIcon($hImage, $IconDir & "Signal\sec-light-green.ico")
	;_GUIImageList_AddIcon($hImage, $IconDir & "Signal\sec-green.ico")
	;_GUICtrlListView_SetImageList($ListviewAPs, $hImage, 1)
	;GUICtrlSetBkColor(-1, $ControlBackgroundColor)
	_SetListviewWidths()
	_SetControlSizes()
	;Clear Treeview
	_GUICtrlTreeView_DeleteChildren($TreeviewAPs, $Authentication_tree)
	_GUICtrlTreeView_DeleteChildren($TreeviewAPs, $channel_tree)
	_GUICtrlTreeView_DeleteChildren($TreeviewAPs, $Encryption_tree)
	_GUICtrlTreeView_DeleteChildren($TreeviewAPs, $NetworkType_tree)
	_GUICtrlTreeView_DeleteChildren($TreeviewAPs, $SSID_tree)
	$ClearAllAps = 0
EndFunc   ;==>_ClearAllAp

Func _ClearListAndTree()
	;Clear Listview
	_GUICtrlListView_DeleteAllItems($ListviewAPs)
	;Clear Treeview
	_GUICtrlTreeView_DeleteChildren($TreeviewAPs, $Authentication_tree)
	_GUICtrlTreeView_DeleteChildren($TreeviewAPs, $channel_tree)
	_GUICtrlTreeView_DeleteChildren($TreeviewAPs, $Encryption_tree)
	_GUICtrlTreeView_DeleteChildren($TreeviewAPs, $NetworkType_tree)
	_GUICtrlTreeView_DeleteChildren($TreeviewAPs, $SSID_tree)
	;Reset Listview positions
	$query = "UPDATE AP SET ListRow=-1"
	_ExecuteMDB($VistumblerDB, $DB_OBJ, $query)
	;Reset Treeview positions
	$query = "DELETE * FROM TreeviewPos"
	_ExecuteMDB($VistumblerDB, $DB_OBJ, $query)
	;Reset flag
	$ClearListAndTree = 0
EndFunc   ;==>_ClearListAndTree

Func _FixLineNumbers();Update Listview Row Numbers in DataArray
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_FixLineNumbers()') ;#Debug Display
	$ListViewSize = _GUICtrlListView_GetItemCount($ListviewAPs) - 1; Get List Size
	For $lisviewrow = 0 To $ListViewSize
		$APNUM = _GUICtrlListView_GetItemText($ListviewAPs, $lisviewrow, $column_Line)
		$query = "UPDATE AP SET ListRow=" & $lisviewrow & " WHERE ApId=" & $APNUM
		_ExecuteMDB($VistumblerDB, $DB_OBJ, $query)
	Next
EndFunc   ;==>_FixLineNumbers

Func _FixListIcons()
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_FixListIcons()') ;#Debug Display
	$query = "SELECT ListRow, SecType, Signal FROM AP WHERE ListRow<>-1"
	$ApMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
	$FoundApMatch = UBound($ApMatchArray) - 1
	;Update in Listview
	For $resetdead = 1 To $FoundApMatch
		$Found_ListRow = $ApMatchArray[$resetdead][1]
		$Found_SecType = $ApMatchArray[$resetdead][2]
		$Found_Signal = $ApMatchArray[$resetdead][3]
		_UpdateIcon($Found_ListRow, $Found_Signal, $Found_SecType)
	Next
EndFunc   ;==>_FixListIcons

Func _RecoverMDB()
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_RecoverMDB()') ;#Debug Display
	GUICtrlSetData($msgdisplay, $Text_RecoveringMDB)
	;Get total APIDs
	$query = "Select COUNT(ApID) FROM AP"
	$ApMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
	$APID = $ApMatchArray[1][1]
	GUICtrlSetData($ActiveAPs, $Text_ActiveAPs & ': ' & "0 / " & $APID)
	;ConsoleWrite("APID:" & $APID & @CRLF)
	;Get  total HistIDs
	$query = "Select COUNT(HistID) FROM Hist"
	$HistMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
	$HISTID = $HistMatchArray[1][1]
	;ConsoleWrite("HISTID:" & $HISTID & @CRLF)
	;Get total GPSIDs
	$query = "Select COUNT(GpsID) FROM GPS"
	$GpsMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
	$GPS_ID = $GpsMatchArray[1][1]
	;ConsoleWrite("GPS_ID:" & $GPS_ID & @CRLF)
	;Get total CamIDs
	$query = "Select COUNT(CamID) FROM Cam"
	$CamIDCountArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
	$CamID = $CamIDCountArray[1][1]
	;ConsoleWrite("CamID:" & $CamID & @CRLF)
	;Remove treeview postion table
	$query = "DELETE * FROM TreeviewPos"
	_ExecuteMDB($VistumblerDB, $DB_OBJ, $query)
	;Reset Listview positions and set all access points to inactive
	$query = "UPDATE AP SET ListRow=-1, Active=0, Signal=0"
	_ExecuteMDB($VistumblerDB, $DB_OBJ, $query)
	If $MinimalGuiMode = 0 Then
		;Add APs into Listview and Treeview
		_UpdateListview(1)
		;Update Labels and Manufacturers
		_UpdateListMacLabels()
	EndIf
	GUICtrlSetData($msgdisplay, '')
EndFunc   ;==>_RecoverMDB

Func _SetUpDbTables($dbfile)
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_SetUpDbTables()') ;#Debug Display
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

;-------------------------------------------------------------------------------------------------------------------------------
;                                                       MANUFACTURER/LABEL FUNCTIONS
;-------------------------------------------------------------------------------------------------------------------------------

Func _FindManufacturer($findmac);Returns Manufacturer for given Mac Address
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_FindManufacturer()') ;#Debug Display
	$findmac = StringReplace($findmac, ':', '')
	If StringLen($findmac) <> 6 Then $findmac = StringTrimRight($findmac, StringLen($findmac) - 6)
	$query = "SELECT Manufacturer FROM Manufacturers WHERE BSSID = '" & $findmac & "'"
	$ManuMatchArray = _RecordSearch($ManuDB, $query, $ManuDB_OBJ)
	$FoundManuMatch = UBound($ManuMatchArray) - 1
	If $FoundManuMatch = 0 Then
		Return ($Text_Unknown)
	Else
		$Manu = $ManuMatchArray[1][1]
		Return ($Manu)
	EndIf
EndFunc   ;==>_FindManufacturer

Func _SetLabels($findmac);Returns Label for given Mac Address
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_SetLabels()') ;#Debug Display
	$findmac = StringReplace($findmac, ':', '')
	$query = "SELECT Label FROM Labels WHERE BSSID = '" & $findmac & "'"
	$LabMatchArray = _RecordSearch($LabDB, $query, $LabDB_OBJ)
	$FoundLabMatch = UBound($LabMatchArray) - 1
	If $FoundLabMatch = 0 Then
		Return ($Text_Unknown)
	Else
		$LABEL = $LabMatchArray[1][1]
		Return ($LABEL)
	EndIf
EndFunc   ;==>_SetLabels

Func _UpdateListMacLabels()
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_UpdateListMacLabels()') ;#Debug Display
	GUICtrlSetData($msgdisplay, "Updating manufacturers")
	$query = "SELECT BSSID, MANU, LABEL, ListRow, ApID FROM AP"
	$ApMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
	$FoundApMatch = UBound($ApMatchArray) - 1
	For $up = 1 To $FoundApMatch
		$Found_BSSID = $ApMatchArray[$up][1]
		$Found_MANU = $ApMatchArray[$up][2]
		$Found_LAB = $ApMatchArray[$up][3]
		$Found_ListRow = $ApMatchArray[$up][4]
		$Found_APID = $ApMatchArray[$up][5]
		$New_MANU = _FindManufacturer($Found_BSSID)
		$New_LAB = _SetLabels($Found_BSSID)
		;Set Manufacturer
		If $Found_MANU <> $New_MANU Then
			_GUICtrlListView_SetItemText($ListviewAPs, $Found_ListRow, $New_MANU, $column_MANUF)
			$query = "UPDATE AP SET MANU='" & $New_MANU & "' WHERE ApID=" & $Found_APID
			_ExecuteMDB($VistumblerDB, $DB_OBJ, $query)
		EndIf
		;Set Label
		If $Found_LAB <> $New_LAB Then
			_GUICtrlListView_SetItemText($ListviewAPs, $Found_ListRow, $New_LAB, $column_Label)
			$query = "UPDATE AP SET LABEL='" & $New_LAB & "' WHERE ApID=" & $Found_APID
			_ExecuteMDB($VistumblerDB, $DB_OBJ, $query)
		EndIf
	Next
EndFunc   ;==>_UpdateListMacLabels

;-------------------------------------------------------------------------------------------------------------------------------
;                                                       TOGGLE/BUTTON FUNCTIONS
;-------------------------------------------------------------------------------------------------------------------------------

Func _CloseToggle() ;Sets Close to 1 to exit vistumbler
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_CloseToggle()') ;#Debug Display
	$Close = 1
EndFunc   ;==>_CloseToggle

Func _ExitSaveDB()
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_ExitSaveDB()') ;#Debug Display
	$SaveDbOnExit = 1
	_CloseToggle()
EndFunc   ;==>_ExitSaveDB

Func _ExitVistumbler()
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_ExitVistumbler()') ;#Debug Display
	If $newdata = 1 Then ;If Access point data has changed since /last save, ask user if they want to save the data
		$savemsg = MsgBox(3, $Text_Save, $Text_SaveQuestion)
		If $savemsg <> 2 Then
			If $savemsg = 6 Then _ExportDetailedData()
			_Exit()
		EndIf
	Else
		_Exit()
	EndIf
	$Close = 0
EndFunc   ;==>_ExitVistumbler

Func _Exit()
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_Exit()') ;#Debug Display
	_GDIPlus_Shutdown()
	GUISetState(@SW_HIDE, $Vistumbler)
	_AccessCloseConn($DB_OBJ)
	_AccessCloseConn($ManuDB_OBJ)
	_AccessCloseConn($LabDB_OBJ)
	_AccessCloseConn($InstDB_OBJ)
	; Write current settings to back to INI file
	_WriteINI()
	$PID = -1
	$CloseTimer = TimerInit()
	While $PID <> 0
		$PID = ProcessExists("Export.exe")
		ProcessClose($PID)
		If TimerDiff($CloseTimer) >= 10000 Then ExitLoop
	WEnd
	FileDelete($GoogleEarth_ActiveFile)
	FileDelete($GoogleEarth_DeadFile)
	FileDelete($GoogleEarth_GpsFile)
	FileDelete($GoogleEarth_OpenFile)
	FileDelete($GoogleEarth_TrackFile)
	FileDelete($tempfile)
	FileDelete($tempfile_showint)
	If $SaveDbOnExit = 1 Then
		FileMove($VistumblerDB, $SaveDir, 9);Move to save directory for later use
		DirMove($VistumblerCamFolder, $SaveDir & StringTrimRight($VistumblerDbName, 4) & "\", 1)
	Else
		FileDelete($VistumblerDB)
		FileDelete($VistumblerCamFolder & "*")
		DirRemove($VistumblerCamFolder, 1)
	EndIf
	If $AutoRecoveryVS1Del = 1 Then FileDelete($AutoRecoveryVS1File)
	If $UseGPS = 1 Then ;If GPS is active, stop it so the COM port does not stay open
		_TurnOffGPS()
	EndIf

	;Exit Vistumbler
	Exit
EndFunc   ;==>_Exit

Func ScanToggle();Turns AP scanning on or off
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, 'ScanToggle()') ;#Debug Display
	If $Scan = 1 Then
		$Scan = 0
		GUICtrlSetState($ScanWifiGUI, $GUI_UNCHECKED)
		GUICtrlSetData($ScanButton, $Text_ScanAPs)
	Else
		$Scan = 1
		GUICtrlSetState($ScanWifiGUI, $GUI_CHECKED)
		GUICtrlSetData($ScanButton, $Text_StopScanAps)
		;Refresh Wireless networks
		_Wlan_Scan()
	EndIf
EndFunc   ;==>ScanToggle

Func _AutoScanToggle();Turns auto scan on or off
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_AutoScanToggle()') ;#Debug Display
	If $AutoScan = 1 Then
		GUICtrlSetState($AutoScanMenu, $GUI_UNCHECKED)
		$AutoScan = 0
	Else
		GUICtrlSetState($AutoScanMenu, $GUI_CHECKED)
		$AutoScan = 1
	EndIf
EndFunc   ;==>_AutoScanToggle

Func _AutoRefreshToggle()
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_AutoRefreshToggle()') ;#Debug Display
	If $RefreshNetworks = 1 Then
		GUICtrlSetState($RefreshMenuButton, $GUI_UNCHECKED)
		$RefreshNetworks = 0
	Else
		GUICtrlSetState($RefreshMenuButton, $GUI_CHECKED)
		$RefreshNetworks = 1
		$RefreshTimer = TimerInit()
	EndIf
EndFunc   ;==>_AutoRefreshToggle

Func _AutoConnectToggle()
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_AutoConnectToggle()') ;#Debug Display
	If $AutoSelect = 1 Then
		GUICtrlSetState($AutoSelectMenuButton, $GUI_UNCHECKED)
		$AutoSelect = 0
	Else
		GUICtrlSetState($AutoSelectMenuButton, $GUI_CHECKED)
		$AutoSelect = 1
	EndIf
EndFunc   ;==>_AutoConnectToggle

Func _AutoSelHighSigToggle()
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_AutoSelHighSigToggle()') ;#Debug Display
	If $AutoSelectHS = 1 Then
		GUICtrlSetState($AutoSelectHighSignal, $GUI_UNCHECKED)
		$AutoSelectHS = 0
	Else
		GUICtrlSetState($AutoSelectHighSignal, $GUI_CHECKED)
		$AutoSelectHS = 1
	EndIf
EndFunc   ;==>_AutoSelHighSigToggle

Func _ActiveApMidiToggle()
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_ActiveApMidiToggle()') ;#Debug Display
	If $Midi_PlayForActiveAps = 1 Then
		GUICtrlSetState($GUI_MidiActiveAps, $GUI_UNCHECKED)
		$Midi_PlayForActiveAps = 0
	Else
		GUICtrlSetState($GUI_MidiActiveAps, $GUI_CHECKED)
		$Midi_PlayForActiveAps = 1
	EndIf
EndFunc   ;==>_ActiveApMidiToggle

Func _AutoKmlToggle()
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_AutoKmlToggle()') ;#Debug Display
	If $AutoKML = 1 Then
		GUICtrlSetState($AutoSaveKML, $GUI_UNCHECKED)
		$AutoKML = 0
	Else
		GUICtrlSetState($AutoSaveKML, $GUI_CHECKED)
		$AutoKML = 1
		$kml_active_timer = TimerInit()
		$kml_dead_timer = TimerInit()
		$kml_gps_timer = TimerInit()
		$kml_track_timer = TimerInit()
	EndIf
EndFunc   ;==>_AutoKmlToggle

Func _GpsToggle();Turns GPS on or off
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_GpsToggle()') ;#Debug Display
	If $UseGPS = 1 Then
		$TurnOffGPS = 1
	Else
		$openport = _OpenComPort($ComPort, $BAUD, $PARITY, $DATABIT, $STOPBIT);Open The GPS COM port

		If $openport = 1 Then
			$UseGPS = 1
			GUICtrlSetData($GpsButton, $Text_StopGPS)
			$GPGGA_Update = TimerInit()
			$GPRMC_Update = TimerInit()
		Else
			$UseGPS = 0
			GUICtrlSetData($msgdisplay, $Text_ErrorOpeningGpsPort)
		EndIf
	EndIf
EndFunc   ;==>_GpsToggle

Func _TurnOffGPS();Turns off GPS, resets variable
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_TurnOffGPS()') ;#Debug Display
	$UseGPS = 0
	$TurnOffGPS = 0
	$disconnected_time = -1
	$Latitude = 'N 0000.0000'
	$Longitude = 'E 0000.0000'
	$Latitude2 = 'N 0000.0000'
	$Longitude2 = 'E 0000.0000'
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
	GUICtrlSetData($GpsButton, $Text_UseGPS)
	GUICtrlSetData($msgdisplay, '')
EndFunc   ;==>_TurnOffGPS

Func _GraphToggle(); Graph1 Button
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_GraphToggle()') ;#Debug Display
	GUISetState(@SW_LOCK, $Vistumbler);lock gui - will be unlocked by _SetControlSizes
	If $Graph = 1 Then
		$Graph = 0
		GUICtrlSetData($GraphButton1, $Text_Graph1)
	ElseIf $Graph = 2 Then
		$Graph = 1
		GUISwitch($Vistumbler)
		GUICtrlSetData($GraphButton1, $Text_NoGraph)
		GUICtrlSetData($GraphButton2, $Text_Graph2)
	ElseIf $Graph = 0 Then
		$Graph = 1
		GUICtrlSetData($GraphButton1, $Text_NoGraph)
	EndIf
	_SetControlSizes()
EndFunc   ;==>_GraphToggle

Func _GraphToggle2(); Graph2 Button
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_GraphToggle2()') ;#Debug Display
	If $Graph = 2 Then
		$Graph = 0
		GUICtrlSetData($GraphButton2, $Text_Graph2)
	ElseIf $Graph = 1 Then
		$Graph = 2
		GUICtrlSetData($GraphButton2, $Text_NoGraph)
		GUICtrlSetData($GraphButton1, $Text_Graph1)
	ElseIf $Graph = 0 Then
		$Graph = 2
		GUICtrlSetData($GraphButton2, $Text_NoGraph)
	EndIf
	_SetControlSizes()
EndFunc   ;==>_GraphToggle2

Func _MinimalGuiModeToggle()
	If $MinimalGuiMode = 1 Then
		$MinimalGuiMode = 0
		GUICtrlSetState($GuiMinimalGuiMode, $GUI_UNCHECKED)
		GUICtrlSetData($msgdisplay, "Restoring GUI")
		_UpdateListview(1)
		$a = WinGetPos($Vistumbler)
		WinMove($title, "", $a[0], $a[1], $a[2], $MinimalGuiExitHeight);Resize window to Minimal GUI Height
		GUICtrlSetData($msgdisplay, "")
	Else
		$MinimalGuiMode = 1
		$ClearListAndTree = 1
		GUICtrlSetState($GuiMinimalGuiMode, $GUI_CHECKED)
		If $VistumblerState = "Maximized" Then
			WinSetState($title, "", @SW_RESTORE)
			$VistumblerState = "Window"
		EndIf
		$a = WinGetPos($Vistumbler)
		$MinimalGuiExitHeight = $a[3]
		$b = _WinAPI_GetClientRect($Vistumbler)
		$titlebar_height = $a[3] - (DllStructGetData($b, "Bottom") - DllStructGetData($b, "Top"))
		WinMove($title, "", $a[0], $a[1], $a[2], $titlebar_height + 65);Resize window to Minimal GUI Height
	EndIf
EndFunc   ;==>_MinimalGuiModeToggle

Func _AutoScrollToBottomToggle()
	If $AutoScrollToBottom = 1 Then
		$AutoScrollToBottom = 0
		GUICtrlSetState($GuiAutoScrollToBottom, $GUI_UNCHECKED)
	Else
		$AutoScrollToBottom = 1
		GUICtrlSetState($GuiAutoScrollToBottom, $GUI_CHECKED)
	EndIf
EndFunc   ;==>_AutoScrollToBottomToggle

Func _BatchListviewInsertToggle()
	If $BatchListviewInsert = 1 Then
		$BatchListviewInsert = 0
		GUICtrlSetState($GuiBatchListviewInsert, $GUI_UNCHECKED)
	Else
		$BatchListviewInsert = 1
		GUICtrlSetState($GuiBatchListviewInsert, $GUI_CHECKED)
	EndIf
EndFunc   ;==>_BatchListviewInsertToggle

Func _DebugToggle() ;Sets if current function should be displayed in the gui
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_DebugToggle()') ;#Debug Display
	If $Debug = 1 Then
		GUICtrlSetState($DebugFunc, $GUI_UNCHECKED)
		GUICtrlSetData($debugdisplay, '')
		$Debug = 0
	Else
		GUICtrlSetState($DebugFunc, $GUI_CHECKED)
		$Debug = 1
	EndIf
EndFunc   ;==>_DebugToggle

Func _DebugComToggle() ;Sets if current function should be displayed in the gui
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_DebugComToggle()') ;#Debug Display
	If $DebugCom = 1 Then
		GUICtrlSetState($DebugComGUI, $GUI_UNCHECKED)
		$DebugCom = 0
	Else
		GUICtrlSetState($DebugComGUI, $GUI_CHECKED)
		$DebugCom = 1
	EndIf
EndFunc   ;==>_DebugComToggle

Func _NativeWifiToggle()
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_NativeWifiToggle()') ;#Debug Display
	If $UseNativeWifi = 1 Then
		GUICtrlSetState($GuiUseNativeWifi, $GUI_UNCHECKED)
		$UseNativeWifi = 0
	Else
		GUICtrlSetState($GuiUseNativeWifi, $GUI_CHECKED)
		$UseNativeWifi = 1
	EndIf
	MsgBox(0, $Text_Information, $Text_VistumblerNeedsToRestart)
	_ExitVistumbler()
EndFunc   ;==>_NativeWifiToggle

Func _SoundToggle();turns new ap sound on or off
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_SoundToggle()') ;#Debug Display
	If $SoundOnAP = 1 Then
		GUICtrlSetState($PlaySoundOnNewAP, $GUI_UNCHECKED)
		$SoundOnAP = 0
	Else
		GUICtrlSetState($PlaySoundOnNewAP, $GUI_CHECKED)
		$SoundOnAP = 1
	EndIf
EndFunc   ;==>_SoundToggle

Func _GpsSoundToggle();turns new gps sound on or off
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_GpsSoundToggle()') ;#Debug Display
	If $SoundOnGps = 1 Then
		GUICtrlSetState($PlaySoundOnNewGPS, $GUI_UNCHECKED)
		$SoundOnGps = 0
	Else
		GUICtrlSetState($PlaySoundOnNewGPS, $GUI_CHECKED)
		$SoundOnGps = 1
	EndIf
EndFunc   ;==>_GpsSoundToggle

Func _SaveGpsWithNoAPsToggle();turns saving gps data without APs on or off
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_SaveGpsWithNoAPsToggle()') ;#Debug Display
	If $SaveGpsWithNoAps = 1 Then
		GUICtrlSetState($MenuSaveGpsWithNoAps, $GUI_UNCHECKED)
		$SaveGpsWithNoAps = 0
	Else
		GUICtrlSetState($MenuSaveGpsWithNoAps, $GUI_CHECKED)
		$SaveGpsWithNoAps = 1
	EndIf
EndFunc   ;==>_SaveGpsWithNoAPsToggle

Func _SpeakSigToggle();turns speak ap signal on or off
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_SpeakSigToggle()') ;#Debug Display
	If $SpeakSignal = 1 Then
		GUICtrlSetState($SpeakApSignal, $GUI_UNCHECKED)
		$SpeakSignal = 0
	Else
		GUICtrlSetState($SpeakApSignal, $GUI_CHECKED)
		$SpeakSignal = 1
	EndIf
EndFunc   ;==>_SpeakSigToggle

Func _AddApPosToggle();Sets if new aps are added to the top or bottom of the list
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_AddApPosToggle()') ;#Debug Display
	If $AddDirection = 0 Then
		GUICtrlSetState($AddNewAPsToTop, $GUI_UNCHECKED)
		$AddDirection = -1
	Else
		GUICtrlSetState($AddNewAPsToTop, $GUI_CHECKED)
		$AddDirection = 0
	EndIf
EndFunc   ;==>_AddApPosToggle

Func _GraphDeadTimeToggle();Sets if new aps are added to the top or bottom of the list
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_GraphDeadTimeToggle') ;#Debug Display
	If $GraphDeadTime = 1 Then
		GUICtrlSetState($GraphDeadTimeGUI, $GUI_UNCHECKED)
		$GraphDeadTime = 0
	Else
		GUICtrlSetState($GraphDeadTimeGUI, $GUI_CHECKED)
		$GraphDeadTime = 1
	EndIf
EndFunc   ;==>_GraphDeadTimeToggle

Func _UseRssiInGraphsToggle();Sets if new aps are added to the top or bottom of the list
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_UseRssiInGraphsToggle') ;#Debug Display
	If $UseRssiInGraphs = 1 Then
		GUICtrlSetState($UseRssiInGraphsGUI, $GUI_UNCHECKED)
		$UseRssiInGraphs = 0
	Else
		GUICtrlSetState($UseRssiInGraphsGUI, $GUI_CHECKED)
		$UseRssiInGraphs = 1
	EndIf
EndFunc   ;==>_UseRssiInGraphsToggle

Func _AutoRecoveryVS1Toggle();Turns auto recovery vs1 on or off
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_AutoRecoveryVS1Toggle()') ;#Debug Display
	If $AutoRecoveryVS1 = 1 Then
		GUICtrlSetState($AutoRecoveryVS1GUI, $GUI_UNCHECKED)
		$AutoRecoveryVS1 = 0
	Else
		GUICtrlSetState($AutoRecoveryVS1GUI, $GUI_CHECKED)
		$AutoRecoveryVS1 = 1
	EndIf
EndFunc   ;==>_AutoRecoveryVS1Toggle

Func _AutoSaveAndClearToggle();Turns auto save and clear on or off
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_AutoSaveAndClearToggle()') ;#Debug Display
	If $AutoSaveAndClear = 1 Then
		GUICtrlSetState($AutoSaveAndClearGUI, $GUI_UNCHECKED)
		$AutoSaveAndClear = 0
	Else
		GUICtrlSetState($AutoSaveAndClearGUI, $GUI_CHECKED)
		$AutoSaveAndClear = 1
	EndIf
EndFunc   ;==>_AutoSaveAndClearToggle


Func _AutoSortToggle();Turns auto sort on or off
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_AutoSortToggle()') ;#Debug Display
	If $AutoSort = 1 Then
		GUICtrlSetState($AutoSortGUI, $GUI_UNCHECKED)
		$AutoSort = 0
	Else
		GUICtrlSetState($AutoSortGUI, $GUI_CHECKED)
		$AutoSort = 1
		$sort_timer = TimerInit()
	EndIf
EndFunc   ;==>_AutoSortToggle

Func _WifiDbLocateToggle();Turns wifi gps locate on or off
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_WifiDbLocateToggle()') ;#Debug Display
	If $UseWiFiDbGpsLocate = 1 Then
		GUICtrlSetState($UseWiFiDbGpsLocateButton, $GUI_UNCHECKED)
		$UseWiFiDbGpsLocate = 0
		$Latitude = 'N 0000.0000'
		$Longitude = 'E 0000.0000'
		$LatitudeWifidb = 'N 0000.0000'
		$LongitudeWifidb = 'E 0000.0000'
	Else
		$UploadWarn = MsgBox(4, $Text_Warning, $Text_WifiDBLocateWarning)
		If $UploadWarn = 6 Then
			GUICtrlSetState($UseWiFiDbGpsLocateButton, $GUI_CHECKED)
			$UseWiFiDbGpsLocate = 1
			$WifidbGPS_Update = TimerInit()
		EndIf
	EndIf
EndFunc   ;==>_WifiDbLocateToggle

Func _WifiDbAutoUploadToggleWarn()
	_WifiDbAutoUploadToggle(1)
EndFunc   ;==>_WifiDbAutoUploadToggleWarn

Func _WifiDbAutoUploadToggle($Warn = 1)
	If $AutoUpApsToWifiDB = 1 Then
		GUICtrlSetState($UseWiFiDbAutoUploadButton, $GUI_UNCHECKED)
		$AutoUpApsToWifiDB = 0
	Else
		If $Warn = 0 Then $UploadWarn = 6
		If $Warn <> 0 Then $UploadWarn = MsgBox(4, $Text_Warning, $Text_WifiDBAutoUploadWarning)
		If $UploadWarn = 6 Then
			GUICtrlSetState($UseWiFiDbAutoUploadButton, $GUI_CHECKED)
			;Set WifiDB Session ID
			$WifiDbSessionID = StringTrimLeft(_MD5(Random(1000, 9999, 1) & Random(1000, 9999, 1) & Random(1000, 9999, 1) & Random(1000, 9999, 1) & Random(1000, 9999, 1) & Random(1000, 9999, 1) & Random(1000, 9999, 1) & Random(1000, 9999, 1) & Random(1000, 9999, 1) & Random(1000, 9999, 1) & $ldatetimestamp & '-' & @MSEC), 2)
			ConsoleWrite("WifiDb Session ID:" & $WifiDbSessionID & @CRLF)
			$AutoUpApsToWifiDB = 1
			$wifidb_au_timer = TimerInit()
		EndIf
	EndIf
EndFunc   ;==>_WifiDbAutoUploadToggle

Func _DownloadImagesToggle();Turns Estimated DB value on or off
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_DownloadImagesToggle()') ;#Debug Display
	If $DownloadImages = 1 Then
		GUICtrlSetState($GUI_DownloadImages, $GUI_UNCHECKED)
		$DownloadImages = 0
	Else
		GUICtrlSetState($GUI_DownloadImages, $GUI_CHECKED)
		$DownloadImages = 1
	EndIf
EndFunc   ;==>_DownloadImagesToggle

Func _CamTriggerToggle();Turns cam trigger on or off
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_CamTriggerToggle()') ;#Debug Display
	If $CamTrigger = 1 Then
		GUICtrlSetState($GUI_CamTriggerMenu, $GUI_UNCHECKED)
		$CamTrigger = 0
	Else
		GUICtrlSetState($GUI_CamTriggerMenu, $GUI_CHECKED)
		$CamTrigger = 1
	EndIf
EndFunc   ;==>_CamTriggerToggle

Func _ResetSizes()
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_ResetSizes()') ;#Debug Display
	$ResetSizes = 1
EndFunc   ;==>_ResetSizes

Func _ClearAll();Clear all APs
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_ClearAll()') ;#Debug Display
	$ClearAllAps = 1
EndFunc   ;==>_ClearAll

Func _MenuSelectConnectedAp()
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_MenuSelectConnectedAp()') ;#Debug Display
	Local $SelConAP = _SelectConnectedAp()
	If $SelConAP = -1 Then
		;MsgBox(0, $Text_Error, $Text_NoActiveApFound & @CRLF & @CRLF & $Column_Names_BSSID & ':' & $IntBSSID & @CRLF & $Column_Names_SSID & ':' & $IntSSID & @CRLF & $Column_Names_Channel & ':' & $IntChan & @CRLF & $Column_Names_Authentication & ':' & $IntAuth)
	ElseIf $SelConAP = 0 Then
		MsgBox(0, $Text_Error, $Text_NoActiveApFound)
	EndIf
EndFunc   ;==>_MenuSelectConnectedAp

Func _SelectConnectedAp()
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_SelectConnectedAp()') ;#Debug Display
	$return = 0
	FileDelete($tempfile_showint)
	_RunDos($netsh & ' wlan show interfaces interface="' & $DefaultApapter & '" > ' & '"' & $tempfile_showint & '"') ;copy the output of the 'netsh wlan show interfaces' command to the temp file
	$showintarraysize = _FileReadToArray($tempfile_showint, $TempFileArrayShowInt);read the tempfile into the '$TempFileArrayShowInt' Araay
	If $showintarraysize = 1 Then
		For $strip_ws = 1 To $TempFileArrayShowInt[0]
			$TempFileArrayShowInt[$strip_ws] = StringStripWS($TempFileArrayShowInt[$strip_ws], 3)
		Next

		Dim $IntSSID, $IntBSSID, $IntChan, $IntAuth, $InEncr
		For $loop = 1 To $TempFileArrayShowInt[0]
			$temp = StringSplit(StringStripWS($TempFileArrayShowInt[$loop], 3), ":")
			If IsArray($temp) Then
				If $temp[0] = 2 Then
					If StringInStr($TempFileArrayShowInt[$loop], $SearchWord_SSID) And StringInStr($TempFileArrayShowInt[$loop], $SearchWord_BSSID) <> 1 Then $IntSSID = StringStripWS($temp[2], 3)
					If StringInStr($TempFileArrayShowInt[$loop], $SearchWord_Channel) Then $IntChan = StringStripWS($temp[2], 3)
					If StringInStr($TempFileArrayShowInt[$loop], $SearchWord_Authentication) Then $IntAuth = StringStripWS($temp[2], 3)
					If StringInStr($TempFileArrayShowInt[$loop], $SearchWord_Cipher) Then $InEncr = StringStripWS($temp[2], 3)
					$NewAP = 1
				ElseIf $temp[0] = 7 Then
					If StringInStr($TempFileArrayShowInt[$loop], $SearchWord_BSSID) Then
						Dim $Signal = '', $RadioType = '', $Channel = '', $BasicTransferRates = '', $OtherTransferRates = '', $MANUF
						$NewAP = 1
						$IntBSSID = StringStripWS(StringUpper($temp[2] & ':' & $temp[3] & ':' & $temp[4] & ':' & $temp[5] & ':' & $temp[6] & ':' & $temp[7]), 3)
					EndIf
				EndIf
			EndIf
		Next
		If $UseNativeWifi = 1 And @OSVersion = "WIN_XP" Then
			If $IntAuth = $SearchWord_Open And $InEncr = $SearchWord_None Then
				$SecType = 1
			ElseIf $InEncr = $SearchWord_Wep Then
				$SecType = 2
			Else
				$SecType = 3
			EndIf
			$query = "SELECT ListRow FROM AP WHERE SSID='" & StringReplace($IntSSID, "'", "''") & "' And SECTYPE=" & $SecType
		Else
			$query = "SELECT ListRow FROM AP WHERE BSSID='" & $IntBSSID & "' And SSID='" & StringReplace($IntSSID, "'", "''") & "' And CHAN=" & $IntChan & " And AUTH='" & $IntAuth & "'"
		EndIf
		$ApMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
		$FoundApMatch = UBound($ApMatchArray) - 1
		If $FoundApMatch > 0 Then
			$return = 1
			$Found_ListRow = $ApMatchArray[1][1]
			_GUICtrlListView_SetItemState($ListviewAPs, $Found_ListRow, $LVIS_FOCUSED, $LVIS_FOCUSED)
			_GUICtrlListView_SetItemState($ListviewAPs, $Found_ListRow, $LVIS_SELECTED, $LVIS_SELECTED)
			GUICtrlSetState($ListviewAPs, $GUI_FOCUS)
		Else
			$return = 0
		EndIf
	EndIf
	Return ($return)
EndFunc   ;==>_SelectConnectedAp

Func _SelectHighSignalAp()
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_SelectHighSignalAp()') ;#Debug Display
	$query = "SELECT TOP 1 ListRow FROM AP WHERE ListRow<>-1 ORDER BY RSSI DESC"
	$ApMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
	$FoundApMatch = UBound($ApMatchArray) - 1
	If $FoundApMatch <> 0 Then
		$Found_ListRow = $ApMatchArray[1][1]
		_GUICtrlListView_SetItemState($ListviewAPs, $Found_ListRow, $LVIS_FOCUSED, $LVIS_FOCUSED)
		_GUICtrlListView_SetItemState($ListviewAPs, $Found_ListRow, $LVIS_SELECTED, $LVIS_SELECTED)
		GUICtrlSetState($ListviewAPs, $GUI_FOCUS)
		Return (1)
	Else
		Return (0)
	EndIf
EndFunc   ;==>_SelectHighSignalAp
;-------------------------------------------------------------------------------------------------------------------------------
;                                                       GPS FUNCTIONS
;-------------------------------------------------------------------------------------------------------------------------------

Func _OpenComPort($CommPort = '8', $sBAUD = '4800', $sPARITY = 'N', $sDataBit = '8', $sStopBit = '1', $sFlow = '0');Open specified COM port
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_OpenComPort()') ;#Debug Display
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
			MsgBox(0, $Text_Error, $Text_InstallNetcommOCX)
		Else
			$NetComm.CommPort = $CommPort ;Set port number
			$NetComm.settings = $CommSettings ;Set port settings
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
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_CloseComPort()') ;#Debug Display
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
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_GetGPS()') ;#Debug Display
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
				If $Buffer > 85 And $LatTest = 0 And TimerDiff($timeout) < $maxtime Then
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
			$gstring = StringStripWS(_rxwait($OpenedPort, '500', $maxtime), 8);Read data line from GPS
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
			$GPGGA_Update = TimerInit()
			$FixTime = $Temp_FixTime
			$Latitude = _Format_GPS_DMM($Temp_Lat)
			$Longitude = _Format_GPS_DMM($Temp_Lon)
			$NumberOfSatalites = $Temp_NumberOfSatalites
			$HorDilPitch = $Temp_HorDilPitch
			$Alt = $Temp_Alt
			$AltS = $Temp_AltS
			$Geo = $Temp_Geo
			$GeoS = $Temp_GeoS
		EndIf
		If $Temp_Status = "A" Then ;If the GPRMC data is Active(A) then write data to perminant variables
			$GPRMC_Update = TimerInit()
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
		If (TimerDiff($disconnected_time) > 10000) And ($GpsDisconnect = 1) Then ; If nothing has been found in the buffer for 10 seconds, turn off gps
			$disconnected_time = -1
			$return = 0
			_TurnOffGPS()
			;_SoundPlay($ErrorFlag_sound_open_id, 0)
			_PlayWavSound($SoundDir & $ErrorFlag_sound)
		EndIf
	EndIf

	_ClearGpsDetailsGUI();Reset variables if they are over the allowed timeout
	_UpdateGpsDetailsGUI();Write changes to "GPS Details" GUI if it is open
	$Degree = $TrackAngle

	If $TurnOffGPS = 1 Then _TurnOffGPS()

	Return ($return)
EndFunc   ;==>_GetGPS

Func _FormatGpsTime($time)
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_FormatGpsTime()') ;#Debug Display
	$h = StringLeft($time, 2)
	$m = StringMid($time, 3, 2)
	$s = StringMid($time, 5, 2)
	If $h > 12 Then
		$h = $h - 12
		$l = "PM"
	Else
		$l = "AM"
	EndIf
	Return ($h & ":" & $m & ":" & $s & $l & ' (UTC)')
EndFunc   ;==>_FormatGpsTime

Func _FormatGpsDate($Date)
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_FormatGpsDate()') ;#Debug Display
	$d = StringTrimRight($Date, 4)
	$m = StringTrimLeft(StringTrimRight($Date, 2), 2)
	$y = StringTrimLeft($Date, 4)
	Return (StringReplace(StringReplace(StringReplace($DateFormat, 'M', $m), 'd', $d), 'yyyy', $y))
EndFunc   ;==>_FormatGpsDate

Func _CheckGpsChecksum($checkdata);Checks if GPS Data Checksum is correct. Returns 1 if it is correct, else Returns 0
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_CheckGpsChecksum') ;#Debug Display
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

Func _GPGGA($data);Strips data from a gps $GPGGA data string
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_GPGGA()') ;#Debug Display
	GUICtrlSetData($msgdisplay, $data)
	If _CheckGpsChecksum($data) = 1 Then
		$GPGGA_Split = StringSplit($data, ",");
		If $GPGGA_Split[0] >= 14 Then
			$Temp_Quality = $GPGGA_Split[7]
			If BitOR($Temp_Quality = 1, $Temp_Quality = 2) = 1 Then
				;Start BlueNMEA fixes...WTF
				If StringInStr($GPGGA_Split[3], "-") Then ;Fix latitude
					$GPGGA_Split[3] = StringReplace($GPGGA_Split[3], "-", "")
					$GPGGA_Split[4] = "S"
				EndIf
				If StringInStr($GPGGA_Split[5], "-") Then ;Fix longitude
					$GPGGA_Split[5] = StringReplace($GPGGA_Split[5], "-", "")
					$GPGGA_Split[6] = "W"
				EndIf
				;End BlueNMEA fixes
				$Temp_FixTime = _FormatGpsTime($GPGGA_Split[2])
				$Temp_Lat = $GPGGA_Split[4] & " " & StringFormat('%0.4f', $GPGGA_Split[3])
				$Temp_Lon = $GPGGA_Split[6] & " " & StringFormat('%0.4f', $GPGGA_Split[5])
				$Temp_NumberOfSatalites = $GPGGA_Split[8]
				$Temp_HorDilPitch = StringFormat('%0.2f', $GPGGA_Split[9])
				$Temp_Alt = StringFormat('%0.2f', $GPGGA_Split[10] * 3.2808399)
				$Temp_AltS = $GPGGA_Split[11]
				$Temp_Geo = StringFormat('%0.2f', $GPGGA_Split[12])
				$Temp_GeoS = $GPGGA_Split[13]
			EndIf
		EndIf
	EndIf
EndFunc   ;==>_GPGGA

Func _GPRMC($data);Strips data from a gps $GPRMC data string
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_GPRMC()') ;#Debug Display
	GUICtrlSetData($msgdisplay, $data)
	If _CheckGpsChecksum($data) = 1 Then
		$GPRMC_Split = StringSplit($data, ",")
		If $GPRMC_Split[0] >= 11 Then
			$Temp_Status = $GPRMC_Split[3]
			If $Temp_Status = "A" Then
				;Start BlueNMEA fixes...WTF
				If StringInStr($GPRMC_Split[4], "-") Then ;Fix latitude
					$GPRMC_Split[4] = StringReplace($GPRMC_Split[4], "-", "")
					$GPRMC_Split[5] = "S"
				EndIf
				If StringInStr($GPRMC_Split[6], "-") Then ;Fix longitude
					$GPRMC_Split[6] = StringReplace($GPRMC_Split[6], "-", "")
					$GPRMC_Split[7] = "W"
				EndIf
				;End BlueNMEA fixes
				$Temp_FixTime2 = _FormatGpsTime($GPRMC_Split[2])
				$Temp_Lat2 = $GPRMC_Split[5] & ' ' & StringFormat('%0.4f', $GPRMC_Split[4])
				$Temp_Lon2 = $GPRMC_Split[7] & ' ' & StringFormat('%0.4f', $GPRMC_Split[6])
				$Temp_SpeedInKnots = $GPRMC_Split[8]
				$Temp_SpeedInMPH = Round($GPRMC_Split[8] * 1.15, 2)
				$Temp_SpeedInKmH = Round($GPRMC_Split[8] * 1.85200, 2)
				$Temp_TrackAngle = $GPRMC_Split[9]
				$Temp_FixDate = _FormatGpsDate($GPRMC_Split[10])
			EndIf
		EndIf
	EndIf
EndFunc   ;==>_GPRMC

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

Func _Format_GPS_DMM_to_DDD($gps);converts gps position from ddmm.mmmm to dd.ddddddd
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_Format_GPS_DMM_to_DDD()') ;#Debug Display
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

Func _Format_GPS_DMM_to_DMS($gps);converts gps ddmm.mmmm to 'dd° mm' ss"
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_Format_GPS_DMM_to_DMS()') ;#Debug Display
	$return = '0° 0' & Chr(39) & ' 0"'
	$splitlatlon1 = StringSplit($gps, " ");Split N,S,E,W from data
	If $splitlatlon1[0] = 2 Then
		$splitlatlon2 = StringSplit($splitlatlon1[2], ".")
		If $splitlatlon2[0] = 2 Then
			$DD = StringTrimRight($splitlatlon2[1], 2)
			$MM = StringTrimLeft($splitlatlon2[1], StringLen($splitlatlon2[1]) - 2)
			$SS = StringFormat('%0.4f', (('.' & $splitlatlon2[2]) * 60)); multiply remaining minutes by 60 to get ss
			If $DD = "" Then $DD = "0"
			$return = $splitlatlon1[1] & ' ' & $DD & '° ' & $MM & Chr(39) & ' ' & $SS & '"' ;Format data properly (ex. dd° mm' ss"N)
		Else
			$return = $splitlatlon1[1] & ' 0° 0' & Chr(39) & ' 0"'
		EndIf
	EndIf
	Return ($return)
EndFunc   ;==>_Format_GPS_DMM_to_DMS

Func _Format_GPS_All_to_DMM($gps);converts dd.ddddddd, 'ddï¿½ mm' ss", or ddmm.mmmm to ddmm.mmmm
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_Format_GPS_All_to_DMM()') ;#Debug Display
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

Func _Format_GPS_DDD_to_DMM($gps, $PosChr, $NegChr);converts dd.ddddddd, to ddmm.mmmm
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_Format_GP_DDD_to_DMM()') ;#Debug Display
	;dd.ddddddd to ddmm.mmmm
	$return = '0000.0000'
	If StringInStr($gps, '-') Or StringInStr($gps, $NegChr) Then
		$gDir = $NegChr
	Else
		$gDir = $PosChr
	EndIf
	$gps = StringReplace(StringReplace(StringReplace(StringReplace(StringReplace($gps, " ", ""), "-", ""), "+", ""), $PosChr, ""), $NegChr, "")
	$splitlatlon1 = StringSplit($gps, ".")
	If $splitlatlon1[0] = 2 Then
		$DD = $splitlatlon1[1] * 100
		$MM = ('.' & $splitlatlon1[2]) * 60 ;multiply remaining decimal by 60 to get mm.mmmm
		$return = $gDir & ' ' & StringFormat('%0.4f', $DD + $MM);Format data properly (ex. N ddmm.mmmm)
	EndIf
	Return ($return)
EndFunc   ;==>_Format_GPS_DDD_to_DMM

Func _GpsFormat($gps);Converts ddmm.mmmm to the users set gps format
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_GpsFormat()') ;#Debug Display
	If $GPSformat = 1 Then $return = _Format_GPS_DMM_to_DDD($gps)
	If $GPSformat = 2 Then $return = _Format_GPS_DMM_to_DMS($gps)
	If $GPSformat = 3 Then $return = $gps
	Return ($return)
EndFunc   ;==>_GpsFormat

;-------------------------------------------------------------------------------------------------------------------------------
;                                                       GPS COMPASS GUI FUNCTIONS
;-------------------------------------------------------------------------------------------------------------------------------

Func _CompassGUI()
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_CompassGUI()') ;#Debug Display
	If $CompassOpen = 0 Then
		$CompassGUI = GUICreate($Text_GpsCompass, 130, 130, -1, -1, BitOR($WS_OVERLAPPEDWINDOW, $WS_CLIPSIBLINGS))
		GUISetBkColor($BackgroundColor)
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
		_DrawCompass()

		$CompassOpen = 1
	Else
		WinActivate($CompassGUI)
	EndIf
EndFunc   ;==>_CompassGUI

Func _CloseCompassGui();closes the compass window
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_CloseCompassGui()') ;#Debug Display
	GUIDelete($CompassGUI)
	$CompassOpen = 0
EndFunc   ;==>_CloseCompassGui

Func _SetCompassSizes();Takes the size of a hidden label in the compass window and determines the Width/Height of the compass
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_SetCompassSizes()') ;#Debug Display
	;---- Keep Window Square ----
	$cs = WinGetPos($CompassGUI)
	$cs_x = $cs[0]
	$cs_y = $cs[1]
	$cs_width = $cs[2]
	$cs_height = $cs[3]
	If $cs_height < $cs_width Then $cs_width = $cs_height
	If $cs_height > $cs_width Then $cs_height = $cs_width
	WinMove($CompassGUI, "", $cs_x, $cs_y, $cs_width, $cs_height)
	;---- End Keep Window Square ----
	;---- Redraw Circle ----
	$p = _WinAPI_GetClientRect($CompassGUI)
	$CompassGUI_height = DllStructGetData($p, "Bottom")
	$CompassGUI_width = DllStructGetData($p, "Right")
	$Compass_height = $CompassGUI_height - ($Compass_topborder + $Compass_bottomborder)
	$Compass_width = $CompassGUI_width - ($Compass_leftborder + $Compass_rightborder)
	If $Compass_height < $Compass_width Then $Compass_width = $Compass_height
	If $Compass_height > $Compass_width Then $Compass_height = $Compass_width

	$Compass_graphics = _GDIPlus_GraphicsCreateFromHWND($CompassGUI)
	$Compass_bitmap = _GDIPlus_BitmapCreateFromGraphics($CompassGUI_width, $CompassGUI_height, $Compass_graphics)
	$Compass_backbuffer = _GDIPlus_ImageGetGraphicsContext($Compass_bitmap)
	;---- End Redraw Circle ----
EndFunc   ;==>_SetCompassSizes

Func _DrawCompass()
	;Set Background Color
	_GDIPlus_GraphicsClear($Compass_backbuffer, StringReplace($BackgroundColor, "0x", "0xFF"))
	;Draw Circle
	$Radius = ($Compass_width / 2)
	$CenterX = ($CompassGUI_width / 2)
	$CenterY = ($CompassGUI_height / 2)
	$CLeft = $CenterX - ($Compass_width / 2)
	$CTop = $CenterY - ($Compass_height / 2)
	_GDIPlus_GraphicsFillEllipse($Compass_backbuffer, $CLeft, $CTop, $Compass_width, $Compass_height, $Brush_ControlBackgroundColor)
	;Draw direction lables
	_GDIPlus_GraphicsDrawString($Compass_backbuffer, "N", $CenterX - 6, $CTop - 15)
	_GDIPlus_GraphicsDrawString($Compass_backbuffer, "S", $CenterX - 6, ($CTop + $Compass_height))
	_GDIPlus_GraphicsDrawString($Compass_backbuffer, "W", $CLeft - 17, $CenterY - 8)
	_GDIPlus_GraphicsDrawString($Compass_backbuffer, "E", ($CLeft + $Compass_width), $CenterY - 8)
	;Draw Compass Line-Calculate (X, Y) based on Degrees, Radius, And Center of circle (X, Y)
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
	If $UseGPS = 1 Then _GDIPlus_GraphicsDrawLine($Compass_backbuffer, $CenterX, $CenterY, $CircleX, $CircleY)
	;Draw new image to the screen
	_GDIPlus_GraphicsDrawImageRect($Compass_graphics, $Compass_bitmap, 0, 0, $CompassGUI_width, $CompassGUI_height)
EndFunc   ;==>_DrawCompass

;-------------------------------------------------------------------------------------------------------------------------------
;                                                       GPS DETAILS GUI FUNCTIONS
;-------------------------------------------------------------------------------------------------------------------------------

Func _OpenGpsDetailsGUI();Opens GPS Details GUI
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_OpenGpsDetailsGUI()') ;#Debug Display
	If $GpsDetailsOpen = 0 Then
		Opt("GUIResizeMode", 1)
		$GpsDetailsGUI = GUICreate($Text_GpsDetails, 565, 190, -1, -1, BitOR($WS_OVERLAPPEDWINDOW, $WS_CLIPSIBLINGS))
		GUISetBkColor($BackgroundColor)
		$GpsCurrentDataGUI = GUICtrlCreateLabel('', 8, 5, 550, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GPGGA_Quality = GUICtrlCreateLabel($Text_Quality & ":", 310, 22, 180, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GPRMC_Status = GUICtrlCreateLabel($Text_Status & ":", 32, 22, 235, 15)
		GUICtrlSetColor(-1, $TextColor)
		GUICtrlCreateGroup("GPRMC", 8, 40, 273, 145)
		GUICtrlSetColor(-1, $TextColor)
		$GPRMC_Time = GUICtrlCreateLabel($Text_Time & ":", 25, 55, 235, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GPRMC_Date = GUICtrlCreateLabel($Text_Date & ":", 25, 70, 235, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GPRMC_Lat = GUICtrlCreateLabel($Column_Names_Latitude & ":", 25, 85, 235, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GPRMC_Lon = GUICtrlCreateLabel($Column_Names_Longitude & ":", 25, 100, 235, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GPRMC_SpeedKnots = GUICtrlCreateLabel($Text_SpeedInKnots & ":", 25, 115, 235, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GPRMC_SpeedMPH = GUICtrlCreateLabel($Text_SpeedInMPH & ":", 25, 130, 243, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GPRMC_SpeedKmh = GUICtrlCreateLabel($Text_SpeedInKmh & ":", 25, 145, 243, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GPRMC_TrackAngle = GUICtrlCreateLabel($Text_TrackAngle & ":", 25, 160, 243, 20)
		GUICtrlSetColor(-1, $TextColor)
		GUICtrlCreateGroup("GPGGA", 287, 40, 273, 125)
		GUICtrlSetColor(-1, $TextColor)
		$GPGGA_Time = GUICtrlCreateLabel($Text_Time & ":", 304, 55, 235, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GPGGA_Satalites = GUICtrlCreateLabel($Text_NumberOfSatalites & ":", 304, 70, 235, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GPGGA_Lat = GUICtrlCreateLabel($Column_Names_Latitude & ":", 304, 85, 235, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GPGGA_Lon = GUICtrlCreateLabel($Column_Names_Longitude & ":", 304, 100, 235, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GPGGA_HorDilPitch = GUICtrlCreateLabel($Text_HorizontalDilutionPosition & ":", 304, 115, 235, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GPGGA_Alt = GUICtrlCreateLabel($Text_Altitude & ":", 304, 130, 243, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GPGGA_Geo = GUICtrlCreateLabel($Text_HeightOfGeoid & ":", 304, 145, 243, 15)
		GUICtrlSetColor(-1, $TextColor)
		$CloseGpsDetailsGUI = GUICtrlCreateButton($Text_Close, 375, 165, 97, 25, 0)
		GUICtrlSetOnEvent($CloseGpsDetailsGUI, '_CloseGpsDetailsGUI')
		GUISetOnEvent($GUI_EVENT_CLOSE, '_CloseGpsDetailsGUI')

		GUISetState(@SW_SHOW)

		$gpsplit = StringSplit($GpsDetailsPosition, ',')
		If $gpsplit[0] = 4 Then ;If $GpsDetailsPosition is a proper position, move and resize window
			WinMove($GpsDetailsGUI, '', $gpsplit[1], $gpsplit[2], $gpsplit[3], $gpsplit[4])
		Else ;Set $GpsDetailsPosition to the current window position
			$g = WinGetPos($GpsDetailsGUI)
			$GpsDetailsPosition = $g[0] & ',' & $g[1] & ',' & $g[2] & ',' & $g[3]
		EndIf

		Opt("GUIResizeMode", 802)
		$GpsDetailsOpen = 1
	Else
		WinActivate($GpsDetailsGUI)
	EndIf
EndFunc   ;==>_OpenGpsDetailsGUI

Func _UpdateGpsDetailsGUI();Updates information on GPS Details GUI
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_UpdateGpsDetailsGUI()') ;#Debug Display
	If $GpsDetailsOpen = 1 Then
		GUICtrlSetData($GPGGA_Time, $Text_Time & ": " & $FixTime)
		GUICtrlSetData($GPGGA_Lat, $Column_Names_Latitude & ": " & _GpsFormat($Latitude))
		GUICtrlSetData($GPGGA_Lon, $Column_Names_Longitude & ": " & _GpsFormat($Longitude))
		GUICtrlSetData($GPGGA_Quality, $Text_Quality & ": " & $Temp_Quality)
		GUICtrlSetData($GPGGA_Satalites, $Text_NumberOfSatalites & ": " & $NumberOfSatalites)
		GUICtrlSetData($GPGGA_HorDilPitch, $Text_HorizontalDilutionPosition & ": " & $HorDilPitch)
		GUICtrlSetData($GPGGA_Alt, $Text_Altitude & ": " & $Alt & $AltS)
		GUICtrlSetData($GPGGA_Geo, $Text_HeightOfGeoid & ": " & $Geo & $GeoS)

		GUICtrlSetData($GPRMC_Time, $Text_Time & ": " & $FixTime2)
		GUICtrlSetData($GPRMC_Date, $Text_Date & ": " & $FixDate)
		GUICtrlSetData($GPRMC_Lat, $Column_Names_Latitude & ": " & _GpsFormat($Latitude2))
		GUICtrlSetData($GPRMC_Lon, $Column_Names_Longitude & ": " & _GpsFormat($Longitude2))
		GUICtrlSetData($GPRMC_Status, $Text_Status & ": " & $Temp_Status)
		GUICtrlSetData($GPRMC_SpeedKnots, $Text_SpeedInKnots & ": " & $SpeedInKnots & " Kn")
		GUICtrlSetData($GPRMC_SpeedMPH, $Text_SpeedInMPH & ": " & $SpeedInMPH & " Km/H")
		GUICtrlSetData($GPRMC_SpeedKmh, $Text_SpeedInKmh & ": " & $SpeedInKmH & " MPH")
		GUICtrlSetData($GPRMC_TrackAngle, $Text_TrackAngle & ": " & $TrackAngle)
	EndIf
EndFunc   ;==>_UpdateGpsDetailsGUI

Func _ClearGpsDetailsGUI();Clears all GPS Details information
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_ClearGpsDetailsGUI()') ;#Debug Display
	If $UseGPS = 1 Then
		If $GpsReset = 1 Then
			GUICtrlSetData($msgdisplay, $Text_SecondsSinceGpsUpdate & ": GPGGA:" & Round(TimerDiff($GPGGA_Update) / 1000) & " / " & ($GpsTimeout / 1000) & " - " & "GPRMC:" & Round(TimerDiff($GPRMC_Update) / 1000) & " / " & ($GpsTimeout / 1000))
			If Round(TimerDiff($GPGGA_Update)) > $GpsTimeout Then
				If $UseWiFiDbGpsLocate = 0 Then
					$Latitude = 'N 0000.0000'
					$Longitude = 'E 0000.0000'
				EndIf
				$FixTime = ''
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
				$Latitude2 = 'N 0000.0000'
				$Longitude2 = 'E 0000.0000'
				$SpeedInKnots = '0'
				$SpeedInMPH = '0'
				$SpeedInKmH = '0'
				$TrackAngle = '0'
				$FixDate = ''
				$GPRMC_Update = TimerInit()
			EndIf
		EndIf
		If $UseWiFiDbGpsLocate = 1 Then
			If Round(TimerDiff($WifidbGPS_Update)) > $GpsTimeout Then
				GUICtrlSetData($msgdisplay, $Text_SecondsSinceGpsUpdate & ": WifiDB:" & Round(TimerDiff($WifidbGPS_Update) / 1000) & " / " & ($GpsTimeout / 1000))
				$Latitude = 'N 0000.0000'
				$Longitude = 'E 0000.0000'
				$LatitudeWifidb = 'N 0000.0000'
				$LongitudeWifidb = 'E 0000.0000'
				GUICtrlSetData($GuiLat, $Text_Latitude & ': ' & _GpsFormat($Latitude));Set GPS Latitude in GUI
				GUICtrlSetData($GuiLon, $Text_Longitude & ': ' & _GpsFormat($Longitude));Set GPS Longitude in GUI
				$WifidbGPS_Update = TimerInit()
			EndIf
		EndIf
	EndIf
EndFunc   ;==>_ClearGpsDetailsGUI

Func _CloseGpsDetailsGUI(); Closes GPS Details GUI
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_CloseGpsDetailsGUI()') ;#Debug Display
	GUIDelete($GpsDetailsGUI)
	$GpsDetailsOpen = 0
EndFunc   ;==>_CloseGpsDetailsGUI

;-------------------------------------------------------------------------------------------------------------------------------
;                                                       SORT FUNCTIONS
;-------------------------------------------------------------------------------------------------------------------------------
Func _SortTree();Sort the data in the treeview
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_SortTree()') ;#Debug Display
	GUICtrlSetData($msgdisplay, $Text_SortingTreeview)
	_GUICtrlTreeView_Sort($TreeviewAPs)
	GUICtrlSetData($msgdisplay, '')
EndFunc   ;==>_SortTree

Func _SortListColumn($ListColName, $SortOrder)
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_SortListColumn()') ;#Debug Display
	Local $DbColName = _GetDbColNameByListColName($ListColName) ;Set DB Column to sort by
	_ListSort($DbColName, $SortOrder);Sort List
	$sort_timer = TimerInit();Reset Sort Timer
EndFunc   ;==>_SortListColumn

Func _HeaderSort($column);Sort a column in ap list
	;ConsoleWrite($column & @CRLF)
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_HeaderSort()') ;#Debug Display
	;Get Column Name
	Local $colInfo = _GUICtrlListView_GetColumn($ListviewAPs, $column)
	Local $colName = $colInfo[5]
	;Set DB Column to sort by
	Local $DbColName = _GetDbColNameByListColName($colName)
	;Sort List
	GUICtrlSetData($msgdisplay, $Text_SortingList)
	_ListSort($DbColName, $Direction[$column])
	GUICtrlSetData($msgdisplay, '')
	;Reverse sort direction (for next sort)
	If $Direction[$column] = 1 Then
		$Direction[$column] = 0
	Else
		$Direction[$column] = 1
	EndIf
	;Sort complete. Reset sort variable.
	$SortColumn = -1
EndFunc   ;==>_HeaderSort

Func _ListSort($DbCol, $SortOrder)
	If $DbCol <> "" Then
		;ConsoleWrite($DbCol & @CRLF)
		Local $ListRowPos = -1
		If $SortOrder = 1 Then
			$SortDir = "DESC"
		Else
			$SortDir = "ASC"
		EndIf
		ConsoleWrite("$DbCol:" & $DbCol & " $SortOrder:" & $SortOrder & " $SortDir:" & $SortDir & @CRLF)
		If $DbCol = "Latitude" Or $DbCol = "Longitude" Then ; Sort by Latitude Or Longitude
			;Add results that have no GPS postion first if DESC
			If $SortDir = "DESC" Then
				$query = "SELECT ListRow, ApID, SSID, BSSID, NETTYPE, RADTYPE, CHAN, AUTH, ENCR, SecType, BTX, OTX, MANU, LABEL, HighGpsHistID, FirstHistID, LastHistID, LastGpsID, Active, Signal, HighSignal, RSSI, HighRSSI FROM AP WHERE HighGpsHistID=0 And ListRow<>-1 ORDER BY ApID " & $SortDir
				$ListRowPos = _SortDbQueryToList($query, $ListRowPos)
			EndIf
			;Add sorted results with GPS
			If $DbCol = "Latitude" Then $query = "SELECT AP.ListRow, AP.ApID, AP.SSID, AP.BSSID, AP.NETTYPE, AP.RADTYPE, AP.CHAN, AP.AUTH, AP.ENCR, AP.SecType, AP.BTX, AP.OTX, AP.MANU, AP.LABEL, AP.HighGpsHistID, AP.FirstHistID, AP.LastHistID, AP.LastGpsID, AP.Active, AP.Signal, AP.HighSignal, AP.RSSI, AP.HighRSSI FROM (AP INNER JOIN Hist ON AP.HighGpsHistId = Hist.HistID) INNER JOIN GPS ON Hist.GpsID = GPS.GPSID WHERE ListRow<>-1 ORDER BY GPS.Latitude " & $SortDir & ", GPS.Longitude " & $SortDir & ", AP.ApID " & $SortDir
			If $DbCol = "Longitude" Then $query = "SELECT AP.ListRow, AP.ApID, AP.SSID, AP.BSSID, AP.NETTYPE, AP.RADTYPE, AP.CHAN, AP.AUTH, AP.ENCR, AP.SecType, AP.BTX, AP.OTX, AP.MANU, AP.LABEL, AP.HighGpsHistID, AP.FirstHistID, AP.LastHistID, AP.LastGpsID, AP.Active, AP.Signal, AP.HighSignal, AP.RSSI, AP.HighRSSI FROM (AP INNER JOIN Hist ON AP.HighGpsHistId = Hist.HistID) INNER JOIN GPS ON Hist.GpsID = GPS.GPSID WHERE ListRow<>-1 ORDER BY GPS.Longitude " & $SortDir & ", GPS.Latitude " & $SortDir & ", AP.ApID " & $SortDir
			$ListRowPos = _SortDbQueryToList($query, $ListRowPos)
			;Add results that have no GPS postion last if ASC
			If $SortDir = "ASC" Then
				$query = "SELECT ListRow, ApID, SSID, BSSID, NETTYPE, RADTYPE, CHAN, AUTH, ENCR, SecType, BTX, OTX, MANU, LABEL, HighGpsHistID, FirstHistID, LastHistID, LastGpsID, Active, Signal, HighSignal, RSSI, HighRSSI FROM AP WHERE HighGpsHistID=0 And ListRow<>-1 ORDER BY ApID " & $SortDir
				$ListRowPos = _SortDbQueryToList($query, $ListRowPos)
			EndIf
		ElseIf $DbCol = "FirstActive" Then ; Sort by First Active Time
			$query = "SELECT AP.ListRow, AP.ApID, AP.SSID, AP.BSSID, AP.NETTYPE, AP.RADTYPE, AP.CHAN, AP.AUTH, AP.ENCR, AP.SecType, AP.BTX, AP.OTX, AP.MANU, AP.LABEL, AP.HighGpsHistID, AP.FirstHistID, AP.LastHistID, AP.LastGpsID, AP.Active, AP.Signal, AP.HighSignal, AP.RSSI, AP.HighRSSI, Hist.Date1, Hist.Time1 FROM AP INNER JOIN Hist ON AP.FirstHistID = Hist.HistID WHERE ListRow<>-1 ORDER BY Hist.Date1 " & $SortDir & ", Hist.Time1 " & $SortDir & ", AP.ApID " & $SortDir
			$ListRowPos = _SortDbQueryToList($query, $ListRowPos)
		ElseIf $DbCol = "LastActive" Then ; Sort by Last Active Time
			$query = "SELECT AP.ListRow, AP.ApID, AP.SSID, AP.BSSID, AP.NETTYPE, AP.RADTYPE, AP.CHAN, AP.AUTH, AP.ENCR, AP.SecType, AP.BTX, AP.OTX, AP.MANU, AP.LABEL, AP.HighGpsHistID, AP.FirstHistID, AP.LastHistID, AP.LastGpsID, AP.Active, AP.Signal, AP.HighSignal, AP.RSSI, AP.HighRSSI, Hist.Date1, Hist.Time1 FROM AP INNER JOIN Hist ON AP.LastHistID = Hist.HistID WHERE ListRow<>-1 ORDER BY Hist.Date1 " & $SortDir & ", Hist.Time1 " & $SortDir & ", AP.ApID " & $SortDir
			$ListRowPos = _SortDbQueryToList($query, $ListRowPos)
		ElseIf $DbCol = "Signal" Or $DbCol = "HighSignal" Or $DbCol = "RSSI" Or $DbCol = "HighRSSI" Or $DbCol = "CHAN" Then ; Sort by Last Active Time
			$query = "SELECT ListRow, ApID, SSID, BSSID, NETTYPE, RADTYPE, CHAN, AUTH, ENCR, SecType, BTX, OTX, MANU, LABEL, HighGpsHistID, FirstHistID, LastHistID, LastGpsID, Active, Signal, HighSignal, RSSI, HighRSSI FROM AP WHERE ListRow<>-1 ORDER BY " & $DbCol & " " & $SortDir & ", ApID " & $SortDir
			$ListRowPos = _SortDbQueryToList($query, $ListRowPos)
		Else ; Sort by any other column
			$query = "SELECT ListRow, ApID, SSID, BSSID, NETTYPE, RADTYPE, CHAN, AUTH, ENCR, SecType, BTX, OTX, MANU, LABEL, HighGpsHistID, FirstHistID, LastHistID, LastGpsID, Active, Signal, HighSignal, RSSI, HighRSSI FROM AP WHERE ListRow<>-1 ORDER BY " & $DbCol & " " & $SortDir & ", ApID " & $SortDir
			$ListRowPos = _SortDbQueryToList($query, $ListRowPos)
		EndIf
	EndIf
EndFunc   ;==>_ListSort

Func _SortDbQueryToList($query, $listpos)
	;ConsoleWrite($query & @CRLF)
	_GUICtrlListView_BeginUpdate($ListviewAPs)
	GUISetState(@SW_LOCK, $Vistumbler)
	$ApMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
	$FoundApMatch = UBound($ApMatchArray) - 1
	For $wlv = 1 To $FoundApMatch
		$listpos += 1
		$Found_ListRow = $ApMatchArray[$wlv][1]
		If $Found_ListRow <> $listpos Then ;If row has changed, update list information
			$Found_APID = $ApMatchArray[$wlv][2]
			$Found_SSID = $ApMatchArray[$wlv][3]
			$Found_BSSID = $ApMatchArray[$wlv][4]
			$Found_NETTYPE = $ApMatchArray[$wlv][5]
			$Found_RADTYPE = $ApMatchArray[$wlv][6]
			$Found_CHAN = $ApMatchArray[$wlv][7]
			$Found_AUTH = $ApMatchArray[$wlv][8]
			$Found_ENCR = $ApMatchArray[$wlv][9]
			$Found_SecType = $ApMatchArray[$wlv][10]
			$Found_BTX = $ApMatchArray[$wlv][11]
			$Found_OTX = $ApMatchArray[$wlv][12]
			$Found_MANU = $ApMatchArray[$wlv][13]
			$Found_LABEL = $ApMatchArray[$wlv][14]
			$Found_HighGpsHistId = $ApMatchArray[$wlv][15]
			$Found_FirstHistID = $ApMatchArray[$wlv][16]
			$Found_LastHistID = $ApMatchArray[$wlv][17]
			$Found_LastGpsID = $ApMatchArray[$wlv][18]
			$Found_Active = $ApMatchArray[$wlv][19]
			$Found_Signal = $ApMatchArray[$wlv][20]
			$Found_HighSignal = $ApMatchArray[$wlv][21]
			$Found_RSSI = $ApMatchArray[$wlv][22]
			$Found_HighRSSI = $ApMatchArray[$wlv][23]

			;Get First Time
			$query = "SELECT Date1, Time1 FROM Hist WHERE HistID=" & $Found_FirstHistID
			$HistMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
			$Found_FirstDate = $HistMatchArray[1][1]
			$Found_FirstTime = $HistMatchArray[1][2]
			$Found_FirstDateTime = $Found_FirstDate & ' ' & $Found_FirstTime

			;Get Last Time
			$query = "SELECT Date1, Time1 FROM Hist WHERE HistID=" & $Found_LastHistID
			$HistMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
			$Found_LastDate = $HistMatchArray[1][1]
			$Found_LastTime = $HistMatchArray[1][2]
			$Found_LastDateTime = $Found_LastDate & ' ' & $Found_LastTime

			;Get GPS Position
			If $Found_HighGpsHistId = 0 Then
				$Found_Lat = "N 0000.0000"
				$Found_Lon = "E 0000.0000"
			Else
				$query = "SELECT GpsID FROM Hist WHERE HistID=" & $Found_HighGpsHistId
				$HistMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
				$Found_GpsID = $HistMatchArray[1][1]
				$query = "SELECT Latitude, Longitude FROM GPS WHERE GPSID=" & $Found_GpsID
				$GpsMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
				$Found_Lat = $GpsMatchArray[1][1]
				$Found_Lon = $GpsMatchArray[1][2]
			EndIf

			;Write changes to listview
			_ListViewAdd($listpos, $Found_APID, $Found_Active, $Found_BSSID, $Found_SSID, $Found_AUTH, $Found_ENCR, $Found_Signal, $Found_HighSignal, $Found_RSSI, $Found_HighRSSI, $Found_CHAN, $Found_RADTYPE, $Found_BTX, $Found_OTX, $Found_NETTYPE, $Found_FirstDateTime, $Found_LastDateTime, $Found_Lat, $Found_Lon, $Found_MANU, $Found_LABEL)

			;Update ListRow Icon
			_UpdateIcon($listpos, $Found_Signal, $Found_SecType)

			;Update ListRow
			$query = "UPDATE AP SET ListRow=" & $listpos & " WHERE ApID=" & $Found_APID
			_ExecuteMDB($VistumblerDB, $DB_OBJ, $query)
		EndIf
	Next
	GUISetState(@SW_UNLOCK, $Vistumbler)
	_GUICtrlListView_EndUpdate($ListviewAPs)
	Return ($listpos)
EndFunc   ;==>_SortDbQueryToList

Func _GetDbColNameByListColName($colName)
	Local $DbSortCol = ""
	;ConsoleWrite($colName & @CRLF)
	If $colName = $Column_Names_Line Then
		$DbSortCol = "ApID"
	ElseIf $colName = $Column_Names_Active Then
		$DbSortCol = "Active"
	ElseIf $colName = $Column_Names_BSSID Then
		$DbSortCol = "BSSID"
	ElseIf $colName = $Column_Names_SSID Then
		$DbSortCol = "SSID"
	ElseIf $colName = $Column_Names_Signal Then
		$DbSortCol = "Signal"
	ElseIf $colName = $Column_Names_HighSignal Then
		$DbSortCol = "HighSignal"
	ElseIf $colName = $Column_Names_RSSI Then
		$DbSortCol = "RSSI"
	ElseIf $colName = $Column_Names_HighRSSI Then
		$DbSortCol = "HighRSSI"
	ElseIf $colName = $Column_Names_Channel Then
		$DbSortCol = "CHAN"
	ElseIf $colName = $Column_Names_Authentication Then
		$DbSortCol = "AUTH"
	ElseIf $colName = $Column_Names_Encryption Then
		$DbSortCol = "ENCR"
	ElseIf $colName = $Column_Names_NetworkType Then
		$DbSortCol = "NETTYPE"
	ElseIf $colName = $Column_Names_Latitude Then
		$DbSortCol = "Latitude"
	ElseIf $colName = $Column_Names_Longitude Then
		$DbSortCol = "Longitude"
	ElseIf $colName = $Column_Names_LatitudeDMM Then
		$DbSortCol = "Latitude"
	ElseIf $colName = $Column_Names_LongitudeDMM Then
		$DbSortCol = "Longitude"
	ElseIf $colName = $Column_Names_LatitudeDMS Then
		$DbSortCol = "Latitude"
	ElseIf $colName = $Column_Names_LongitudeDMS Then
		$DbSortCol = "Longitude"
	ElseIf $colName = $Column_Names_MANUF Then
		$DbSortCol = "MANU"
	ElseIf $colName = $Column_Names_Label Then
		$DbSortCol = "Label"
	ElseIf $colName = $Column_Names_RadioType Then
		$DbSortCol = "RADTYPE"
	ElseIf $colName = $Column_Names_BasicTransferRates Then
		$DbSortCol = "BTX"
	ElseIf $colName = $Column_Names_OtherTransferRates Then
		$DbSortCol = "OTX"
	ElseIf $colName = $Column_Names_FirstActive Then
		$DbSortCol = "FirstActive"
	ElseIf $colName = $Column_Names_LastActive Then
		$DbSortCol = "LastActive"
	EndIf
	Return ($DbSortCol)
EndFunc   ;==>_GetDbColNameByListColName

Func _ManufacturerSort();Sorts manufacturer column in manufacturer list
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_ManufacturerSort()') ;#Debug Display
	$column = GUICtrlGetState($GUI_Manu_List)
	If $Direction2[$column] = 0 Then
		Dim $v_sort = False;set descending
		$Direction2[$column] = 1
	Else
		Dim $v_sort = True;set ascending
		$Direction2[$column] = 0
	EndIf
	_GUICtrlListView_SimpleSort($GUI_Manu_List, $v_sort, $column)
	$Apply_Manu = 1
EndFunc   ;==>_ManufacturerSort

Func _LabelSort();Sorts manufacturer column in manufacturer list
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_LabelSort()') ;#Debug Display
	$column = GUICtrlGetState($GUI_Lab_List)
	If $Direction3[$column] = 0 Then
		Dim $v_sort = False;set descending
		$Direction3[$column] = 1
	Else
		Dim $v_sort = True;set ascending
		$Direction3[$column] = 0
	EndIf
	_GUICtrlListView_SimpleSort($GUI_Lab_List, $v_sort, $column)
	$Apply_Lab = 1
EndFunc   ;==>_LabelSort

;-------------------------------------------------------------------------------------------------------------------------------
;                                                       WINDOW FUNCTIONS
;-------------------------------------------------------------------------------------------------------------------------------


Func _SetControlSizes();Sets control positions in GUI based on the windows current size
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_SetControlSizes()') ;#Debug Display
	$a = _WinAPI_GetClientRect($Vistumbler)
	$b = _WinAPI_GetClientRect($GraphicGUI)
	$sizes = DllStructGetData($a, "Right") & '-' & DllStructGetData($a, "Bottom") & '-' & DllStructGetData($b, "Right") & '-' & DllStructGetData($b, "Bottom")
	If $sizes <> $sizes_old Or $Graph <> $Graph_old Or $MinimalGuiMode <> $MinimalGuiMode_old Then
		$DataChild_Left = 2
		$DataChild_Width = DllStructGetData($a, "Right")
		$DataChild_Top = 65
		$DataChild_Height = DllStructGetData($a, "Bottom") - $DataChild_Top
		If $MinimalGuiMode = 1 Then
			GUISetState(@SW_LOCK, $Vistumbler)
			WinSetState($TreeviewAPs, "", @SW_HIDE)
			WinSetState($ListviewAPs, "", @SW_HIDE)
			GUISetState(@SW_HIDE, $GraphicGUI)
			GUICtrlSetState($GraphButton1, $GUI_HIDE)
			GUICtrlSetState($GraphButton2, $GUI_HIDE)
			GUISetState(@SW_UNLOCK, $Vistumbler)
		ElseIf $Graph <> 0 Then
			$Graphic_left = $DataChild_Left
			$Graphic_width = $DataChild_Width - $Graphic_left
			$Graphic_top = $DataChild_Top
			$Graphic_height = $DataChild_Height * $SplitHeightPercent

			$Graph_height = $Graphic_height - ($Graph_topborder + $Graph_bottomborder)
			$Graph_width = $Graphic_width - ($Graph_leftborder + $Graph_rightborder)

			$ListviewAPs_left = $DataChild_Left
			$ListviewAPs_width = $DataChild_Width - $ListviewAPs_left
			$ListviewAPs_top = $DataChild_Top + ($Graphic_height + 1)
			$ListviewAPs_height = $DataChild_Height - ($Graphic_height + 1)

			GUISetState(@SW_LOCK, $Vistumbler)
			WinMove($ListviewAPs, "", $ListviewAPs_left, $ListviewAPs_top, $ListviewAPs_width, $ListviewAPs_height)
			WinMove($GraphicGUI, "", $Graphic_left, $Graphic_top, $Graphic_width, $Graphic_height)
			WinSetState($TreeviewAPs, "", @SW_HIDE)
			WinSetState($ListviewAPs, "", @SW_SHOW)
			GUISetState(@SW_SHOW, $GraphicGUI)
			GUICtrlSetState($GraphButton1, $GUI_SHOW)
			GUICtrlSetState($GraphButton2, $GUI_SHOW)
			GUISetState(@SW_UNLOCK, $Vistumbler)

			$Graphic = _GDIPlus_GraphicsCreateFromHWND($GraphicGUI)
			$Graph_bitmap = _GDIPlus_BitmapCreateFromGraphics($Graphic_width, $Graphic_height, $Graphic)
			$Graph_backbuffer = _GDIPlus_ImageGetGraphicsContext($Graph_bitmap)
		Else
			$TreeviewAPs_left = $DataChild_Left
			$TreeviewAPs_width = ($DataChild_Width * $SplitPercent) - $TreeviewAPs_left
			$TreeviewAPs_top = $DataChild_Top
			$TreeviewAPs_height = $DataChild_Height

			$ListviewAPs_left = ($DataChild_Width * $SplitPercent) + 1
			$ListviewAPs_width = $DataChild_Width - $ListviewAPs_left
			$ListviewAPs_top = $DataChild_Top
			$ListviewAPs_height = $DataChild_Height

			GUISetState(@SW_LOCK, $Vistumbler)
			WinMove($ListviewAPs, "", $ListviewAPs_left, $ListviewAPs_top, $ListviewAPs_width, $ListviewAPs_height)
			WinMove($TreeviewAPs, "", $TreeviewAPs_left, $TreeviewAPs_top, $TreeviewAPs_width, $TreeviewAPs_height)
			WinSetState($TreeviewAPs, "", @SW_SHOW)
			WinSetState($ListviewAPs, "", @SW_SHOW)
			GUISetState(@SW_HIDE, $GraphicGUI)
			GUICtrlSetState($GraphButton1, $GUI_SHOW)
			GUICtrlSetState($GraphButton2, $GUI_SHOW)
			GUISetState(@SW_UNLOCK, $Vistumbler)
		EndIf
		$sizes_old = $sizes
		$Graph_old = $Graph
		$MinimalGuiMode_old = $MinimalGuiMode
	EndIf
EndFunc   ;==>_SetControlSizes

Func _TreeviewListviewResize()
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_TreeviewListviewResize()') ;#Debug Display
	$cursorInfo = GUIGetCursorInfo($Vistumbler)
	If $Graph = 0 Then
		If WinActive($Vistumbler) And $cursorInfo[0] > ($TreeviewAPs_left + $TreeviewAPs_width - 5) And $cursorInfo[0] < ($TreeviewAPs_left + $TreeviewAPs_width + 5) And $cursorInfo[1] > $TreeviewAPs_top And $cursorInfo[1] < ($TreeviewAPs_top + $TreeviewAPs_height) And $MoveMode = False Then
			$MoveArea = True
			GUISetCursor(13, 1);  13 = SIZEWE
		ElseIf $MoveArea = True Then
			$MoveArea = False
			GUISetCursor(2, 1);  2 = ARROW
		EndIf
		If $MoveArea = True And $cursorInfo[2] = 1 Then
			$MoveMode = True
		EndIf
		If $MoveMode = True Then
			GUISetCursor(13, 1);  13 = SIZEWE
			$TreeviewAPs_width = $cursorInfo[0] - $TreeviewAPs_left
			WinMove($TreeviewAPs, "", $TreeviewAPs_left, $TreeviewAPs_top, $TreeviewAPs_width, $TreeviewAPs_height); resize treeview
			$ListviewAPs_left = $TreeviewAPs_left + $TreeviewAPs_width + 1
			$ListviewAPs_width = $DataChild_Width - $ListviewAPs_left
			WinMove($ListviewAPs, "", $ListviewAPs_left, $ListviewAPs_top, $ListviewAPs_width, $ListviewAPs_height); resize listview
			$SplitPercent = StringFormat('%0.2f', $TreeviewAPs_width / $DataChild_Width)
			_WinAPI_RedrawWindow($ListviewAPs)
		EndIf
		If $MoveMode = True And $cursorInfo[2] = 0 Then
			$MoveMode = False
			GUISetCursor(2, 1);  2 = ARROW
		EndIf
	Else
		If WinActive($Vistumbler) And $cursorInfo[1] > $ListviewAPs_top - 5 And $cursorInfo[1] < $ListviewAPs_top + 5 And $MoveMode = False Then
			$MoveArea = True
			GUISetCursor(11, 1);  11 = SIZENS
		ElseIf $MoveArea = True Then
			$MoveArea = False
			GUISetCursor(2, 1);  2 = ARROW
		EndIf
		If $MoveArea = True And $cursorInfo[2] = 1 Then
			$MoveMode = True
		EndIf
		If $MoveMode = True Then
			GUISetCursor(11, 1);  11 = SIZENS
			$Graphic_height = $cursorInfo[1] - $Graphic_top
			WinMove($GraphicGUI, "", $Graphic_left, $Graphic_top, $Graphic_width, $Graphic_height)
			$ListviewAPs_top = $Graphic_top + $Graphic_height + 1
			$ListviewAPs_height = $DataChild_Height - $Graphic_height
			WinMove($ListviewAPs, "", $ListviewAPs_left, $ListviewAPs_top, $ListviewAPs_width, $ListviewAPs_height); resize listview
			$SplitHeightPercent = StringFormat('%0.2f', $Graphic_height / $DataChild_Height)
			_WinAPI_RedrawWindow($ListviewAPs)
		EndIf
		If $MoveMode = True And $cursorInfo[2] = 0 Then
			$MoveMode = False
			GUISetCursor(2, 1);  2 = ARROW
		EndIf
	EndIf
EndFunc   ;==>_TreeviewListviewResize

Func WM_NOTIFY($hWnd, $iMsg, $iwParam, $ilParam)
	Local $hWndFrom, $iIDFrom, $iCode, $tNMHDR, $hWndListView, $tInfo
	$hWndListView = $ListviewAPs
	If Not IsHWnd($ListviewAPs) Then $hWndListView = GUICtrlGetHandle($ListviewAPs)

	$tNMHDR = DllStructCreate($tagNMHDR, $ilParam)
	$hWndFrom = HWnd(DllStructGetData($tNMHDR, "hWndFrom"))
	;$iIDFrom = DllStructGetData($tNMHDR, "IDFrom")
	$iCode = DllStructGetData($tNMHDR, "Code")
	Switch $hWndFrom
		Case $hWndListView
			Switch $iCode
				Case $NM_CLICK
					;ConsoleWrite('Listview Left Click' & @CRLF)
				Case $NM_RCLICK
					;ConsoleWrite('Listview Right Click' & @CRLF)
					ListViewAPs_RClick()
				Case $NM_DBLCLK
					;ConsoleWrite("Listview Double Click" & @CRLF)
					$Selected = _GUICtrlListView_GetNextItem($ListviewAPs); find what AP is selected in the list. returns -1 is nothing is selected
					If $Selected <> -1 Then _GUICtrlListView_SetItemSelected($ListviewAPs, $Selected, False) ; Deselect selected AP
				Case $LVN_COLUMNCLICK
					;ConsoleWrite("Listview Column Click" & @CRLF)
					$tInfo = DllStructCreate($tagNMLISTVIEW, $ilParam)
					$SortColumn = DllStructGetData($tInfo, "SubItem")
			EndSwitch
	EndSwitch
	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_NOTIFY

Func ListViewAPs_RClick()
	Local $aHit
	$hWndListView = $ListviewAPs
	If Not IsHWnd($ListviewAPs) Then $hWndListView = GUICtrlGetHandle($ListviewAPs)
	$aHit = _GUICtrlListView_SubItemHitTest($hWndListView)
	If ($aHit[0] <> -1) Then
		; Create a standard popup menu
		$hMenu = _GUICtrlMenu_CreatePopup()
		_GUICtrlMenu_AddMenuItem($hMenu, $Text_Copy, $idCopy)
		_GUICtrlMenu_AddMenuItem($hMenu, $Text_AddNewMan, $idNewManu)
		_GUICtrlMenu_AddMenuItem($hMenu, $Text_AddNewLabel, $idNewLabel)
		_GUICtrlMenu_AddMenuItem($hMenu, $Text_GeoNamesInfo, $idGNInfo)
		_GUICtrlMenu_AddMenuItem($hMenu, $Text_WifiDbPHPgraph, $idGraph)
		_GUICtrlMenu_AddMenuItem($hMenu, $Text_FindApInWifidb, $idFindAP)


		; ========================================================================
		; capture the context menu selections
		; ========================================================================
		Switch _GUICtrlMenu_TrackPopupMenu($hMenu, $hWndListView, -1, -1, 1, 1, 2)
			Case $idCopy
				ConsoleWrite("Copy: " & StringFormat("Item, SubItem [%d, %d]", $aHit[0], $aHit[1]) & @CRLF)
				_CopySelectedAP()
			Case $idNewManu
				ConsoleWrite("AddManu: " & StringFormat("Item, SubItem [%d, %d]", $aHit[0], $aHit[1]) & @CRLF)
				_RClick_AddManu()
			Case $idNewLabel
				ConsoleWrite("AddLabel: " & StringFormat("Item, SubItem [%d, %d]", $aHit[0], $aHit[1]) & @CRLF)
				_RClick_AddLabel()
			Case $idGNInfo
				ConsoleWrite("Info: " & StringFormat("Item, SubItem [%d, %d]", $aHit[0], $aHit[1]) & @CRLF)
				_GeonamesInfo($aHit[0])
			Case $idGraph
				ConsoleWrite("Graph: " & StringFormat("Item, SubItem [%d, %d]", $aHit[0], $aHit[1]) & @CRLF)
				_ViewInWifiDbGraph_Open($aHit[0])
			Case $idFindAP
				ConsoleWrite("Find AP: " & StringFormat("Item, SubItem [%d, %d]", $aHit[0], $aHit[1]) & @CRLF)
				_LocateAPInWifidb($aHit[0], 1)
		EndSwitch
		_GUICtrlMenu_DestroyMenu($hMenu)
	EndIf
EndFunc   ;==>ListViewAPs_RClick

Func _RClick_AddManu();Adds new manucaturer to settings gui manufacturer list
	If $AddMacOpen = 1 Then _MacAdd_Close()
	$Selected = _GUICtrlListView_GetNextItem($ListviewAPs); find what AP is selected in the list. returns -1 is nothing is selected
	If $Selected <> -1 Then ;If a access point is selected in the listview, map its data
		;Get Mac Address
		$query = "SELECT BSSID FROM AP WHERE ListRow=" & $Selected
		$ListRowMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
		$Found_BSSID = StringUpper(StringReplace(StringReplace(StringReplace(StringReplace($ListRowMatchArray[1][1], ':', ''), '-', ''), '"', ''), ' ', ''))
		$Found_BSSID = StringTrimRight($Found_BSSID, StringLen($Found_BSSID) - 6)

		;Get existing mac address information if it exists
		Local $Found_MMANU
		$query = "SELECT Manufacturer FROM Manufacturers WHERE BSSID='" & $Found_BSSID & "'"
		$ManuMatchArray = _RecordSearch($ManuDB, $query, $ManuDB_OBJ)
		$FoundManuMatch = UBound($ManuMatchArray) - 1
		If $FoundManuMatch = 1 Then
			$Found_MMANU = $ManuMatchArray[1][1]
		EndIf

		;Present GUI to change mac address
		$MacAdd_GUI = GUICreate($Text_AddNewMan, 623, 96)
		GUISetBkColor($BackgroundColor)
		GUICtrlCreateLabel($Column_Names_BSSID, 15, 10, 150, 15)
		$MacAdd_GUI_BSSID = GUICtrlCreateInput($Found_BSSID, 16, 30, 153, 21)
		GUICtrlCreateLabel($Column_Names_MANUF, 185, 10, 420, 15)
		$MacAdd_GUI_MANU = GUICtrlCreateInput($Found_MMANU, 185, 30, 420, 21)
		$MacAdd_OK = GUICtrlCreateButton($Text_Ok, 160, 60, 129, 25)
		GUICtrlSetState(-1, 512)
		$MacAdd_Cancel = GUICtrlCreateButton($Text_Cancel, 298, 60, 129, 25)
		GUISetState(@SW_SHOW)
		$AddMacOpen = 1
		GUICtrlSetOnEvent($MacAdd_OK, "_MacAdd_Ok")
		GUICtrlSetOnEvent($MacAdd_Cancel, "_MacAdd_Close")

	Else
		MsgBox(0, $Text_Error, "No AP selected")
	EndIf
EndFunc   ;==>_RClick_AddManu

Func _MacAdd_Ok()
	$MacAdd_BSSID = GUICtrlRead($MacAdd_GUI_BSSID)
	$MacAdd_MANU = GUICtrlRead($MacAdd_GUI_MANU)
	;Check if mac already exists
	$query = "SELECT Manufacturer FROM Manufacturers WHERE BSSID='" & $MacAdd_BSSID & "'"
	$ManuMatchArray = _RecordSearch($ManuDB, $query, $ManuDB_OBJ)
	$FoundManuMatch = UBound($ManuMatchArray) - 1
	If $FoundManuMatch = 1 Then ; Mac Exists, ask to update it
		$overwrite_entry = MsgBox(4, $Text_Overwrite & '?', $Text_MacExistsOverwriteIt)
		If $overwrite_entry = 6 Then
			$query = "UPDATE Manufacturers SET Manufacturer='" & StringReplace($MacAdd_MANU, "'", "''") & "' WHERE BSSID='" & $MacAdd_BSSID & "'"
			_ExecuteMDB($ManuDB, $ManuDB_OBJ, $query)
		EndIf
	Else ; Mac doesn't exist, Add it
		ReDim $AddManuRecordArray[3]
		$AddManuRecordArray[0] = 2
		$AddManuRecordArray[1] = $MacAdd_BSSID
		$AddManuRecordArray[2] = $MacAdd_MANU
		_AddRecord($ManuDB, "Manufacturers", $ManuDB_OBJ, $AddManuRecordArray)
	EndIf
	_MacAdd_Close()
EndFunc   ;==>_MacAdd_Ok

Func _MacAdd_Close();Close edit manufacturer window
	GUIDelete($MacAdd_GUI)
	$AddMacOpen = 0
	_UpdateListMacLabels()
EndFunc   ;==>_MacAdd_Close

Func _RClick_AddLabel();Adds new manucaturer to settings gui manufacturer list
	If $AddLabelOpen = 1 Then _LabelAdd_Close()
	$Selected = _GUICtrlListView_GetNextItem($ListviewAPs); find what AP is selected in the list. returns -1 is nothing is selected
	If $Selected <> -1 Then ;If a access point is selected in the listview, map its data
		;Get Mac Address
		$query = "SELECT BSSID FROM AP WHERE ListRow=" & $Selected
		$ListRowMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
		$Found_BSSID = StringUpper(StringReplace(StringReplace(StringReplace(StringReplace($ListRowMatchArray[1][1], ':', ''), '-', ''), '"', ''), ' ', ''))
		;Get existing mac address information if it exists
		Local $Found_MLABEL
		$query = "SELECT Label FROM Labels WHERE BSSID='" & $Found_BSSID & "'"
		$ManuMatchArray = _RecordSearch($LabDB, $query, $LabDB_OBJ)
		$FoundManuMatch = UBound($ManuMatchArray) - 1
		If $FoundManuMatch = 1 Then
			$Found_MLABEL = $ManuMatchArray[1][1]
		EndIf
		;Present GUI to change mac address
		$LabelAdd_GUI = GUICreate($Text_AddNewLabel, 623, 96)
		GUISetBkColor($BackgroundColor)
		GUICtrlCreateLabel($Column_Names_BSSID, 15, 10, 150, 15)
		$LabelAdd_GUI_BSSID = GUICtrlCreateInput($Found_BSSID, 16, 30, 153, 21)
		GUICtrlCreateLabel($Column_Names_Label, 185, 10, 420, 15)
		$LabelAdd_GUI_LABEL = GUICtrlCreateInput($Found_MLABEL, 185, 30, 420, 21)
		$LabelAdd_OK = GUICtrlCreateButton($Text_Ok, 160, 60, 129, 25)
		GUICtrlSetState(-1, 512)
		$LabelAdd_Cancel = GUICtrlCreateButton($Text_Cancel, 298, 60, 129, 25)
		GUISetState(@SW_SHOW)
		$AddLabelOpen = 1
		GUICtrlSetOnEvent($LabelAdd_OK, "_LabelAdd_Ok")
		GUICtrlSetOnEvent($LabelAdd_Cancel, "_LabelAdd_Close")
	Else
		MsgBox(0, $Text_Error, "No AP selected")
	EndIf
EndFunc   ;==>_RClick_AddLabel

Func _LabelAdd_Ok()
	$LabelAdd_BSSID = GUICtrlRead($LabelAdd_GUI_BSSID)
	$LabelAdd_LABEL = GUICtrlRead($LabelAdd_GUI_LABEL)
	;Check if mac already exists
	$query = "SELECT Label FROM Labels WHERE BSSID='" & $LabelAdd_BSSID & "'"
	$ManuMatchArray = _RecordSearch($LabDB, $query, $LabDB_OBJ)
	$FoundManuMatch = UBound($ManuMatchArray) - 1
	If $FoundManuMatch = 1 Then ; Mac Exists, ask to update it
		$overwrite_entry = MsgBox(4, $Text_Overwrite & '?', $Text_MacExistsOverwriteIt)
		If $overwrite_entry = 6 Then
			$query = "UPDATE Labels SET Label='" & StringReplace($LabelAdd_LABEL, "'", "''") & "' WHERE BSSID='" & $LabelAdd_BSSID & "'"
			;ConsoleWrite('old: ' & $query & @CRLF)
			_ExecuteMDB($LabDB, $LabDB_OBJ, $query)
		EndIf
	Else ; Mac doesn't exist, Add it
		ReDim $AddLabelRecordArray[3]
		$AddLabelRecordArray[0] = 2
		$AddLabelRecordArray[1] = $LabelAdd_BSSID
		$AddLabelRecordArray[2] = $LabelAdd_LABEL
		_AddRecord($LabDB, "Labels", $LabDB_OBJ, $AddLabelRecordArray)
	EndIf
	_LabelAdd_Close()
EndFunc   ;==>_LabelAdd_Ok

Func _LabelAdd_Close();Close edit manufacturer window
	GUIDelete($LabelAdd_GUI)
	$AddLabelOpen = 0
	_UpdateListMacLabels()
EndFunc   ;==>_LabelAdd_Close
;-------------------------------------------------------------------------------------------------------------------------------
;                                                       GRAPH FUNCTIONS
;-------------------------------------------------------------------------------------------------------------------------------

;---------- Signal Graph Functions ----------
Func _GraphDraw()
	_GDIPlus_GraphicsClear($Graph_backbuffer)
	;Set Background Color
	_GDIPlus_GraphicsClear($Graph_backbuffer, StringReplace($ControlBackgroundColor, "0x", "0xFF"))
	;Draw % or dBm labels and lines
	If $UseRssiInGraphs = 1 Then;Draw dBm labels
		For $sn = 0 To 10
			$RSSI = ($sn * -10)
			$vposition = $Graph_topborder + (($Graph_height / 10) * $sn)
			_GDIPlus_GraphicsDrawString($Graph_backbuffer, $RSSI, 0, $vposition - 5)
			_GDIPlus_GraphicsDrawLine($Graph_backbuffer, $Graph_leftborder, $vposition, $Graph_leftborder + $Graph_width, $vposition, $Pen_GraphGrid)
		Next
	Else;Draw % labels
		For $sn = 0 To 10
			$percent = ($sn * 10) & "%"
			$vposition = $Graph_topborder + ($Graph_height - (($Graph_height / 10) * $sn))
			_GDIPlus_GraphicsDrawString($Graph_backbuffer, $percent, 0, $vposition - 5)
			_GDIPlus_GraphicsDrawLine($Graph_backbuffer, $Graph_leftborder, $vposition, $Graph_leftborder + $Graph_width, $vposition, $Pen_GraphGrid)
		Next
	EndIf

	;Graph Selected AP
	$Selected = _GUICtrlListView_GetNextItem($ListviewAPs); find what AP is selected in the list. returns -1 is nothing is selected
	If $Selected <> -1 Then ;If a access point is selected in the listview, map its data
		$query = "SELECT ApID FROM AP WHERE ListRow=" & $Selected
		$ListRowMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
		$GraphApID = $ListRowMatchArray[1][1]
		If $Graph = 1 Then
			$max_graph_points = '125'
			$query = "SELECT TOP " & $max_graph_points & " Signal, RSSI, ApID, Date1, Time1 FROM Hist WHERE ApID=" & $GraphApID & " And Signal<>0 ORDER BY Date1, Time1 Desc"
			$HistMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
			$HistSize = UBound($HistMatchArray) - 1
			If $HistSize <> 0 Then
				If $HistSize < $max_graph_points Then $max_graph_points = $HistSize ;Fix to prevent graph from drawing outside its region when the are 0% marks
				Local $graph_point_center_y, $graph_point_center_x, $Found_dts, $gloop
				Local $GraphWidthSpacing = $Graph_width / ($HistSize - 1)
				Local $GraphHeightSpacing = $Graph_height / 100
				For $gs = 1 To $HistSize
					$gloop += 1
					If $gloop > $max_graph_points Then ExitLoop
					$ExpSig = $HistMatchArray[$gs][1] - 0
					$ExpRSSI = $HistMatchArray[$gs][2]
					$ExpApID = $HistMatchArray[$gs][3]
					$ExpDate = $HistMatchArray[$gs][4]

					$Last_dts = $Found_dts
					$ts = StringSplit($HistMatchArray[$gs][5], ":")
					$ExpTime = ($ts[1] * 3600) + ($ts[2] * 60) + StringTrimRight($ts[3], 4) ;In seconds
					$Found_dts = StringReplace($ExpDate & $ExpTime, '-', '')


					$old_graph_point_center_x = $graph_point_center_x
					$old_graph_point_center_y = $graph_point_center_y
					$graph_point_center_x = ($Graph_leftborder + $Graph_width) - ($GraphWidthSpacing * ($gloop - 1))
					If $UseRssiInGraphs = 1 Then
						$graph_point_center_y = $Graph_topborder + ($Graph_height - ($GraphHeightSpacing * (100 + $ExpRSSI)))
						;ConsoleWrite($graph_point_center_y & @CRLF)
					Else
						$graph_point_center_y = $Graph_topborder + ($Graph_height - ($GraphHeightSpacing * $ExpSig))
					EndIf

					;Draw Point
					_GDIPlus_GraphicsDrawLine($Graph_backbuffer, $graph_point_center_x - 1, $graph_point_center_y - 1, $graph_point_center_x + 1, $graph_point_center_y - 1, $Pen_Red)
					_GDIPlus_GraphicsDrawLine($Graph_backbuffer, $graph_point_center_x - 1, $graph_point_center_y, $graph_point_center_x + 1, $graph_point_center_y, $Pen_Red)
					_GDIPlus_GraphicsDrawLine($Graph_backbuffer, $graph_point_center_x - 1, $graph_point_center_y + 1, $graph_point_center_x + 1, $graph_point_center_y + 1, $Pen_Red)

					;Draw Connecting line
					If $gs <> 1 Then
						;Draw Connecting line
						_GDIPlus_GraphicsDrawLine($Graph_backbuffer, $old_graph_point_center_x, $old_graph_point_center_y, $graph_point_center_x, $graph_point_center_y, $Pen_Red)
						;Draw any gaps that may exist (AP at 0%)
						If ($Last_dts - $Found_dts) > $TimeBeforeMarkedDead Then
							If $GraphDeadTime = 1 Then
								$numofzeros = ($Last_dts - $Found_dts) - $TimeBeforeMarkedDead
								For $wz = 1 To $numofzeros
									$gloop += 1
									If $gloop > $max_graph_points Then ExitLoop

									$old_graph_point_center_x = $graph_point_center_x
									$old_graph_point_center_y = $graph_point_center_y
									$graph_point_center_x = ($Graph_leftborder + $Graph_width) - ($GraphWidthSpacing * ($gloop - 1))
									$graph_point_center_y = $Graph_topborder + $Graph_height

									;Draw Point
									_GDIPlus_GraphicsDrawLine($Graph_backbuffer, $graph_point_center_x - 1, $graph_point_center_y - 1, $graph_point_center_x + 1, $graph_point_center_y - 1, $Pen_Red)
									_GDIPlus_GraphicsDrawLine($Graph_backbuffer, $graph_point_center_x - 1, $graph_point_center_y, $graph_point_center_x + 1, $graph_point_center_y, $Pen_Red)
									_GDIPlus_GraphicsDrawLine($Graph_backbuffer, $graph_point_center_x - 1, $graph_point_center_y + 1, $graph_point_center_x + 1, $graph_point_center_y + 1, $Pen_Red)

									;Draw Line
									_GDIPlus_GraphicsDrawLine($Graph_backbuffer, $old_graph_point_center_x, $old_graph_point_center_y, $graph_point_center_x, $graph_point_center_y, $Pen_Red)
								Next
							Else
								$gloop += 1
								If $gloop > $max_graph_points Then ExitLoop

								$old_graph_point_center_x = $graph_point_center_x
								$old_graph_point_center_y = $graph_point_center_y
								$graph_point_center_x = ($Graph_leftborder + $Graph_width) - ($GraphWidthSpacing * ($gloop - 1))
								$graph_point_center_y = $Graph_topborder + $Graph_height

								;Draw Point
								_GDIPlus_GraphicsDrawLine($Graph_backbuffer, $graph_point_center_x - 1, $graph_point_center_y - 1, $graph_point_center_x + 1, $graph_point_center_y - 1, $Pen_Red)
								_GDIPlus_GraphicsDrawLine($Graph_backbuffer, $graph_point_center_x - 1, $graph_point_center_y, $graph_point_center_x + 1, $graph_point_center_y, $Pen_Red)
								_GDIPlus_GraphicsDrawLine($Graph_backbuffer, $graph_point_center_x - 1, $graph_point_center_y + 1, $graph_point_center_x + 1, $graph_point_center_y + 1, $Pen_Red)

								;Draw Line
								_GDIPlus_GraphicsDrawLine($Graph_backbuffer, $old_graph_point_center_x, $old_graph_point_center_y, $graph_point_center_x, $graph_point_center_y, $Pen_Red)
							EndIf
						EndIf
					EndIf
				Next
			EndIf
		ElseIf $Graph = 2 Then
			$max_graph_points = $Graph_width
			$query = "SELECT TOP " & $max_graph_points & " Signal, RSSI, ApID, Date1, Time1 FROM Hist WHERE ApID=" & $GraphApID & " And Signal<>0 ORDER BY Date1, Time1 Desc"
			$HistMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
			$HistSize = UBound($HistMatchArray) - 1
			If $HistSize <> 0 Then
				Local $Found_dts, $gloop
				Local $GraphWidthSpacing = $Graph_width / $max_graph_points
				Local $GraphHeightSpacing = $Graph_height / 100
				For $gs = 1 To $HistSize
					$gloop += 1
					If $gloop > $max_graph_points Then ExitLoop
					$ExpSig = $HistMatchArray[$gs][1] - 0
					$ExpRSSI = $HistMatchArray[$gs][2]
					$ExpApID = $HistMatchArray[$gs][3]
					$ExpDate = $HistMatchArray[$gs][4]

					$Last_dts = $Found_dts
					$ts = StringSplit($HistMatchArray[$gs][5], ":")
					$ExpTime = ($ts[1] * 3600) + ($ts[2] * 60) + StringTrimRight($ts[3], 4) ;In seconds
					$Found_dts = StringReplace($ExpDate & $ExpTime, '-', '')

					;Draw line for signal strength
					If $UseRssiInGraphs = 1 Then
						$graph_line_top_y = $Graph_topborder + ($Graph_height - ($GraphHeightSpacing * (100 + $ExpRSSI)))
					Else
						$graph_line_top_y = $Graph_topborder + ($Graph_height - ($GraphHeightSpacing * $ExpSig))
					EndIf
					$graph_line_top_x = ($Graph_leftborder + $Graph_width) - ($gloop * $GraphWidthSpacing)
					$graph_line_bottom_x = ($Graph_leftborder + $Graph_width) - ($gloop * $GraphWidthSpacing)
					$graph_line_bottom_y = $Graph_topborder + $Graph_height
					_GDIPlus_GraphicsDrawLine($Graph_backbuffer, $graph_line_top_x, $graph_line_top_y, $graph_line_bottom_x, $graph_line_bottom_y, $Pen_Red)

					;increment $gloop for any gaps that may exist (AP at 0%)
					If $gs <> 1 Then
						If ($Last_dts - $Found_dts) > $TimeBeforeMarkedDead Then
							If $GraphDeadTime = 1 Then
								$numofzeros = ($Last_dts - $Found_dts) - $TimeBeforeMarkedDead
								For $wz = 1 To $numofzeros
									$gloop += 1
									If $gloop > $max_graph_points Then ExitLoop
								Next
							Else
								$gloop += 1
								If $gloop > $max_graph_points Then ExitLoop
							EndIf
						EndIf
					EndIf

				Next
			EndIf
		EndIf
	EndIf

	;Draw temporary image to GUI
	_GDIPlus_GraphicsDrawImageRect($Graphic, $Graph_bitmap, 0, 0, $Graphic_width, $Graphic_height)

EndFunc   ;==>_GraphDraw

;---------- 2.4Ghz Channel Graph Function ----------
Func _Channels2400_GUI()
	If $2400chanGUIOpen = 0 Then
		$2400chanGUIOpen = 1

		$2400chanGUI = GUICreate($Text_2400ChannelGraph, 800, 400, -1, -1, BitOR($WS_OVERLAPPEDWINDOW, $WS_CLIPSIBLINGS))
		GUISetBkColor($ControlBackgroundColor, $2400chanGUI)

		$cpsplit = StringSplit($2400ChanGraphPos, ',')
		If $cpsplit[0] = 4 Then ;If $2400ChanGraphPos is a proper position, move and resize window
			WinMove($2400chanGUI, '', $cpsplit[1], $cpsplit[2], $cpsplit[3], $cpsplit[4])
		Else ;Set $2400ChanGraphPos to the current window position
			$c = WinGetPos($2400chanGUI)
			$2400ChanGraphPos = $c[0] & ',' & $c[1] & ',' & $c[2] & ',' & $c[3]
		EndIf

		GUISetState(@SW_SHOW, $2400chanGUI)
		GUISetOnEvent($GUI_EVENT_CLOSE, '_Close2400GUI')
		GUISetOnEvent($GUI_EVENT_RESIZED, '_Set2400ChanGraphSizes')
		GUISetOnEvent($GUI_EVENT_RESTORE, '_Set2400ChanGraphSizes')

		_Set2400ChanGraphSizes()
		_Draw2400ChanGraph()
	Else
		WinActivate($2400chanGUI)
	EndIf
EndFunc   ;==>_Channels2400_GUI

Func _Close2400GUI()
	GUIDelete($2400chanGUI)
	$2400chanGUIOpen = 0
EndFunc   ;==>_Close2400GUI

Func _Set2400ChanGraphSizes()
	;Get Window Size
	$p = _WinAPI_GetClientRect($2400chanGUI)
	$2400width = DllStructGetData($p, "Right")
	$2400height = DllStructGetData($p, "Bottom")
	;Set Sizes

	$2400graphheight = $2400height - ($2400topborder + $2400bottomborder)
	$2400graphwidth = $2400width - ($2400leftborder + $2400rightborder)
	$2400freqwidth = $2400graphwidth / 100
	$2400percheight = $2400graphheight / 100

	$2400graphics = _GDIPlus_GraphicsCreateFromHWND($2400chanGUI)
	$2400bitmap = _GDIPlus_BitmapCreateFromGraphics($2400width, $2400height, $2400graphics)
	$2400backbuffer = _GDIPlus_ImageGetGraphicsContext($2400bitmap)
EndFunc   ;==>_Set2400ChanGraphSizes

Func _Draw2400ChanGraph()
	;Set Background Color
	_GDIPlus_GraphicsClear($2400backbuffer, StringReplace($ControlBackgroundColor, "0x", "0xFF"))
	;Draw 10% labels and lines
	If $UseRssiInGraphs = 1 Then
		For $sn = 0 To 10
			$RSSI = ($sn * -10)
			$vposition = $2400topborder + (($2400graphheight / 10) * $sn)
			_GDIPlus_GraphicsDrawString($2400backbuffer, $RSSI, 0, $vposition - 5)
			_GDIPlus_GraphicsDrawLine($2400backbuffer, $2400leftborder, $vposition, $2400width - $2400rightborder, $vposition, $Pen_GraphGrid)
		Next
	Else
		For $sn = 0 To 10
			$percent = ($sn * 10) & "%"
			$vposition = ($2400height - $2400bottomborder) - (($2400graphheight / 10) * $sn)
			_GDIPlus_GraphicsDrawString($2400backbuffer, $percent, 0, $vposition - 5)
			_GDIPlus_GraphicsDrawLine($2400backbuffer, $2400leftborder, $vposition, $2400width - $2400rightborder, $vposition, $Pen_GraphGrid)
		Next
	EndIf

	;Draw Channel labels and lines
	_Draw2400ChanLine(2412, 1)
	_Draw2400ChanLine(2417, 2)
	_Draw2400ChanLine(2422, 3)
	_Draw2400ChanLine(2427, 4)
	_Draw2400ChanLine(2432, 5)
	_Draw2400ChanLine(2437, 6)
	_Draw2400ChanLine(2442, 7)
	_Draw2400ChanLine(2447, 8)
	_Draw2400ChanLine(2452, 9)
	_Draw2400ChanLine(2457, 10)
	_Draw2400ChanLine(2462, 11)
	_Draw2400ChanLine(2467, 12)
	_Draw2400ChanLine(2472, 13)
	_Draw2400ChanLine(2484, 14)

	;Draw graph lines
	$query = "SELECT SSID, CHAN, Signal, RSSI FROM AP WHERE Active=1 And ListRow<>-1"
	$ApMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
	$FoundApMatch = UBound($ApMatchArray) - 1
	For $dc = 1 To $FoundApMatch
		$Found_SSID = $ApMatchArray[$dc][1]
		$Found_CHAN = $ApMatchArray[$dc][2]
		$Found_Signal = $ApMatchArray[$dc][3] - 0
		$Found_RSSI = $ApMatchArray[$dc][4]
		If $Found_CHAN = 1 Then
			$Found_Freq = 2412
		ElseIf $Found_CHAN = 2 Then
			$Found_Freq = 2417
		ElseIf $Found_CHAN = 3 Then
			$Found_Freq = 2422
		ElseIf $Found_CHAN = 4 Then
			$Found_Freq = 2427
		ElseIf $Found_CHAN = 5 Then
			$Found_Freq = 2432
		ElseIf $Found_CHAN = 6 Then
			$Found_Freq = 2437
		ElseIf $Found_CHAN = 7 Then
			$Found_Freq = 2442
		ElseIf $Found_CHAN = 8 Then
			$Found_Freq = 2447
		ElseIf $Found_CHAN = 9 Then
			$Found_Freq = 2452
		ElseIf $Found_CHAN = 10 Then
			$Found_Freq = 2457
		ElseIf $Found_CHAN = 11 Then
			$Found_Freq = 2462
		ElseIf $Found_CHAN = 12 Then
			$Found_Freq = 2467
		ElseIf $Found_CHAN = 13 Then
			$Found_Freq = 2472
		ElseIf $Found_CHAN = 14 Then
			$Found_Freq = 2484
		Else
			$Found_Freq = 0
		EndIf

		If $Found_Freq <> 0 Then
			$x_center = $2400leftborder + (($Found_Freq - 2400) * $2400freqwidth)
			$x_left = $x_center - (11 * $2400freqwidth)
			$x_right = $x_center + (11 * $2400freqwidth)
			$y_bottom = $2400topborder + $2400graphheight
			If $UseRssiInGraphs = 1 Then
				$y_sigheight = (100 + $Found_RSSI) * $2400percheight
			Else
				$y_sigheight = $Found_Signal * $2400percheight
			EndIf
			$y_top = $2400topborder + ($2400graphheight - $y_sigheight)

			;Draw left side or curve
			Local $aPoints[4][2]
			$aPoints[0][0] = 3
			$aPoints[1][0] = $x_left + 5
			$aPoints[1][1] = $y_top
			$aPoints[2][0] = $x_left + 5
			$aPoints[2][1] = $y_top + ($y_sigheight / 2)
			$aPoints[3][0] = $x_left
			$aPoints[3][1] = $y_bottom
			_GDIPlus_GraphicsDrawCurve($2400backbuffer, $aPoints, $Pen_Red)
			;Draw right side or curve
			Local $aPoints[4][2]
			$aPoints[0][0] = 3
			$aPoints[1][0] = $x_right - 5
			$aPoints[1][1] = $y_top
			$aPoints[2][0] = $x_right - 5
			$aPoints[2][1] = $y_top + ($y_sigheight / 2)
			$aPoints[3][0] = $x_right
			$aPoints[3][1] = $y_bottom
			_GDIPlus_GraphicsDrawCurve($2400backbuffer, $aPoints, $Pen_Red)
			;Draw top of curve
			_GDIPlus_GraphicsDrawLine($2400backbuffer, $x_left + 5, $y_top, $x_right - 5, $y_top, $Pen_Red)
			;Draw SSID text
			$hFont = _GDIPlus_FontCreate($FontFamily_Arial, 9, 1)
			$tLayout = _GDIPlus_RectFCreate($x_left, $y_top - 15, $x_right - $x_left, 15)
			$hFormat = _GDIPlus_StringFormatCreate()
			_GDIPlus_StringFormatSetAlign($hFormat, 1)
			_GDIPlus_GraphicsDrawStringEx($2400backbuffer, $Found_SSID, $hFont, $tLayout, $hFormat, $Brush_Blue)
		EndIf
	Next
	_GDIPlus_GraphicsDrawImageRect($2400graphics, $2400bitmap, 0, 0, $2400width, $2400height)
EndFunc   ;==>_Draw2400ChanGraph

Func _Draw2400ChanLine($frequency, $Channel)
	$hposition = $2400leftborder + ($2400freqwidth * ($frequency - 2400))
	_GDIPlus_GraphicsDrawString($2400backbuffer, $Channel, $hposition - 5, ($2400graphheight + $2400topborder) + 5)
	_GDIPlus_GraphicsDrawLine($2400backbuffer, $hposition, $2400topborder, $hposition, $2400graphheight + $2400topborder, $Pen_GraphGrid)
EndFunc   ;==>_Draw2400ChanLine

;---------- 5Ghz Channel Graph Function ----------
Func _Channels5000_GUI()
	If $5000chanGUIOpen = 0 Then
		$5000chanGUIOpen = 1

		$5000chanGUI = GUICreate($Text_5000ChannelGraph, 800, 400, -1, -1, BitOR($WS_OVERLAPPEDWINDOW, $WS_CLIPSIBLINGS))
		GUISetBkColor($ControlBackgroundColor, $5000chanGUI)

		$cpsplit = StringSplit($5000ChanGraphPos, ',')
		If $cpsplit[0] = 4 Then ;If $5000ChanGraphPos is a proper position, move and resize window
			WinMove($5000chanGUI, '', $cpsplit[1], $cpsplit[2], $cpsplit[3], $cpsplit[4])
		Else ;Set $5000ChanGraphPos to the current window position
			$c = WinGetPos($5000chanGUI)
			$5000ChanGraphPos = $c[0] & ',' & $c[1] & ',' & $c[2] & ',' & $c[3]
		EndIf

		GUISetOnEvent($GUI_EVENT_CLOSE, '_Close5000GUI')
		GUISetOnEvent($GUI_EVENT_RESIZED, '_Set5000ChanGraphSizes')
		GUISetOnEvent($GUI_EVENT_RESTORE, '_Set5000ChanGraphSizes')

		GUISetState(@SW_SHOW, $5000chanGUI)

		_Set5000ChanGraphSizes()
		_Draw5000ChanGraph()
	Else
		WinActivate($5000chanGUI)
	EndIf
EndFunc   ;==>_Channels5000_GUI

Func _Close5000GUI()
	GUIDelete($5000chanGUI)
	$5000chanGUIOpen = 0
EndFunc   ;==>_Close5000GUI

Func _Set5000ChanGraphSizes()
	;Get Window Size
	$p = _WinAPI_GetClientRect($5000chanGUI)
	$5000width = DllStructGetData($p, "Right")
	$5000height = DllStructGetData($p, "Bottom")
	;Set Sizes
	$5000graphheight = $5000height - ($5000topborder + $5000bottomborder)
	$5000graphwidth = $5000width - ($5000leftborder + $5000rightborder)
	$5000freqwidth = $5000graphwidth / 700 ; Freq Range 5150 - 5850 (700points)
	$5000percheight = $5000graphheight / 100

	$5000graphics = _GDIPlus_GraphicsCreateFromHWND($5000chanGUI)
	$5000bitmap = _GDIPlus_BitmapCreateFromGraphics($5000width, $5000height, $5000graphics)
	$5000backbuffer = _GDIPlus_ImageGetGraphicsContext($5000bitmap)
EndFunc   ;==>_Set5000ChanGraphSizes

Func _Draw5000ChanGraph()
	_GDIPlus_GraphicsClear($5000backbuffer)
	;Set Background Color
	_GDIPlus_GraphicsClear($5000backbuffer, StringReplace($ControlBackgroundColor, "0x", "0xFF"))
	;Draw 10% labels and lines
	If $UseRssiInGraphs = 1 Then
		For $sn = 0 To 10
			$RSSI = ($sn * -10)
			$vposition = $5000topborder + (($5000graphheight / 10) * $sn)
			_GDIPlus_GraphicsDrawString($5000backbuffer, $RSSI, 0, $vposition - 5)
			_GDIPlus_GraphicsDrawLine($5000backbuffer, $5000leftborder, $vposition, $5000width - $5000rightborder, $vposition, $Pen_GraphGrid)
		Next
	Else
		For $sn = 0 To 10
			$percent = ($sn * 10) & "%"
			$vposition = ($5000height - $5000bottomborder) - (($5000graphheight / 10) * $sn)
			_GDIPlus_GraphicsDrawString($5000backbuffer, $percent, 0, $vposition - 5)
			_GDIPlus_GraphicsDrawLine($5000backbuffer, $5000leftborder, $vposition, $5000width - $5000rightborder, $vposition, $Pen_GraphGrid)
		Next
	EndIf
	;Draw Channel labels and lines
	_Draw5000ChanLine(5180, 36)
	_Draw5000ChanLine(5200, 40)
	_Draw5000ChanLine(5220, 44)
	_Draw5000ChanLine(5240, 48)
	_Draw5000ChanLine(5260, 52)
	_Draw5000ChanLine(5280, 56)
	_Draw5000ChanLine(5300, 60)
	_Draw5000ChanLine(5320, 64)
	_Draw5000ChanLine(5500, 100)
	_Draw5000ChanLine(5520, 104)
	_Draw5000ChanLine(5540, 108)
	_Draw5000ChanLine(5560, 112)
	_Draw5000ChanLine(5580, 116)
	_Draw5000ChanLine(5600, 120)
	_Draw5000ChanLine(5620, 124)
	_Draw5000ChanLine(5640, 128)
	_Draw5000ChanLine(5660, 132)
	_Draw5000ChanLine(5680, 136)
	_Draw5000ChanLine(5700, 140)
	_Draw5000ChanLine(5745, 149)
	_Draw5000ChanLine(5765, 153)
	_Draw5000ChanLine(5785, 157)
	_Draw5000ChanLine(5805, 161)
	_Draw5000ChanLine(5825, 165)

	$query = "SELECT SSID, CHAN, Signal, RSSI FROM AP WHERE Active=1 And ListRow<>-1"
	$ApMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
	$FoundApMatch = UBound($ApMatchArray) - 1
	For $dc = 1 To $FoundApMatch
		$Found_SSID = $ApMatchArray[$dc][1]
		$Found_CHAN = $ApMatchArray[$dc][2]
		$Found_Signal = $ApMatchArray[$dc][3] - 0
		$Found_RSSI = $ApMatchArray[$dc][4]
		If $Found_CHAN = 36 Then
			$Found_Freq = 5180
		ElseIf $Found_CHAN = 40 Then
			$Found_Freq = 5200
		ElseIf $Found_CHAN = 44 Then
			$Found_Freq = 5220
		ElseIf $Found_CHAN = 48 Then
			$Found_Freq = 5240
		ElseIf $Found_CHAN = 52 Then
			$Found_Freq = 5260
		ElseIf $Found_CHAN = 56 Then
			$Found_Freq = 5280
		ElseIf $Found_CHAN = 60 Then
			$Found_Freq = 5300
		ElseIf $Found_CHAN = 64 Then
			$Found_Freq = 5320
		ElseIf $Found_CHAN = 100 Then
			$Found_Freq = 5500
		ElseIf $Found_CHAN = 104 Then
			$Found_Freq = 5520
		ElseIf $Found_CHAN = 108 Then
			$Found_Freq = 5540
		ElseIf $Found_CHAN = 112 Then
			$Found_Freq = 5560
		ElseIf $Found_CHAN = 116 Then
			$Found_Freq = 5580
		ElseIf $Found_CHAN = 120 Then
			$Found_Freq = 5600
		ElseIf $Found_CHAN = 124 Then
			$Found_Freq = 5620
		ElseIf $Found_CHAN = 128 Then
			$Found_Freq = 5640
		ElseIf $Found_CHAN = 132 Then
			$Found_Freq = 5660
		ElseIf $Found_CHAN = 136 Then
			$Found_Freq = 5680
		ElseIf $Found_CHAN = 140 Then
			$Found_Freq = 5700
		ElseIf $Found_CHAN = 149 Then
			$Found_Freq = 5745
		ElseIf $Found_CHAN = 153 Then
			$Found_Freq = 5765
		ElseIf $Found_CHAN = 157 Then
			$Found_Freq = 5785
		ElseIf $Found_CHAN = 161 Then
			$Found_Freq = 5805
		ElseIf $Found_CHAN = 165 Then
			$Found_Freq = 5825
		Else
			$Found_Freq = 0
		EndIf

		If $Found_Freq <> 0 Then
			$x_center = $5000leftborder + (($Found_Freq - 5150) * $5000freqwidth)
			$x_left = $x_center - (10 * $5000freqwidth)
			$x_right = $x_center + (10 * $5000freqwidth)
			$y_bottom = $5000topborder + $5000graphheight
			If $UseRssiInGraphs = 1 Then
				$y_sigheight = (100 + $Found_RSSI) * $5000percheight
			Else
				$y_sigheight = $Found_Signal * $5000percheight
			EndIf
			$y_top = $5000topborder + ($5000graphheight - $y_sigheight)

			;Draw left side or curve
			Local $aPoints[4][2]
			$aPoints[0][0] = 3
			$aPoints[1][0] = $x_left + 5
			$aPoints[1][1] = $y_top
			$aPoints[2][0] = $x_left + 5
			$aPoints[2][1] = $y_top + ($y_sigheight / 2)
			$aPoints[3][0] = $x_left
			$aPoints[3][1] = $y_bottom
			_GDIPlus_GraphicsDrawCurve($5000backbuffer, $aPoints, $Pen_Red)
			;Draw right side or curve
			Local $aPoints[4][2]
			$aPoints[0][0] = 3
			$aPoints[1][0] = $x_right - 5
			$aPoints[1][1] = $y_top
			$aPoints[2][0] = $x_right - 5
			$aPoints[2][1] = $y_top + ($y_sigheight / 2)
			$aPoints[3][0] = $x_right
			$aPoints[3][1] = $y_bottom
			_GDIPlus_GraphicsDrawCurve($5000backbuffer, $aPoints, $Pen_Red)
			;Draw top of curve
			_GDIPlus_GraphicsDrawLine($5000backbuffer, $x_left + 5, $y_top, $x_right - 5, $y_top, $Pen_Red)
			;Draw SSID text
			$hFont = _GDIPlus_FontCreate($FontFamily_Arial, 9, 1)
			$tLayout = _GDIPlus_RectFCreate($x_left, $y_top - 15, $x_right - $x_left, 15)
			$hFormat = _GDIPlus_StringFormatCreate()
			_GDIPlus_StringFormatSetAlign($hFormat, 1)
			_GDIPlus_GraphicsDrawStringEx($5000backbuffer, $Found_SSID, $hFont, $tLayout, $hFormat, $Brush_Blue)
		EndIf
	Next
	_GDIPlus_GraphicsDrawImageRect($5000graphics, $5000bitmap, 0, 0, $5000width, $5000height)
EndFunc   ;==>_Draw5000ChanGraph

Func _Draw5000ChanLine($frequency, $Channel)
	$hposition = $5000leftborder + ($5000freqwidth * ($frequency - 5150))
	_GDIPlus_GraphicsDrawString($5000backbuffer, $Channel, $hposition - 5, ($5000graphheight + $5000topborder) + 5)
	_GDIPlus_GraphicsDrawLine($5000backbuffer, $hposition, $5000topborder, $hposition, $5000graphheight + $5000topborder, $Pen_GraphGrid)
EndFunc   ;==>_Draw5000ChanLine

;-------------------------------------------------------------------------------------------------------------------------------
;                                                       WifiDB FUNCTIONS
;-------------------------------------------------------------------------------------------------------------------------------
Func _ViewInWifiDbGraph()
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_ViewInWifiDbGraph()') ;#Debug Display
	$Selected = _GUICtrlListView_GetNextItem($ListviewAPs); find what AP is selected in the list. returns -1 is nothing is selected
	_ViewInWifiDbGraph_Open($Selected)
EndFunc   ;==>_ViewInWifiDbGraph

Func _ViewInWifiDbGraph_Open($Selected);Sends data to WifiDb php graphing script
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_ViewInWifiDbGraph_Open()') ;#Debug Display
	If $Selected <> -1 Then ;If a access point is selected in the listview, map its data
		$query = "SELECT ApID, SSID, BSSID, AUTH, ENCR, RADTYPE, NETTYPE, CHAN, BTX, OTX, MANU, LABEL, HighGpsHistID FROM AP WHERE ListRow=" & $Selected
		$ListRowMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
		$FoundListRowMatch = UBound($ListRowMatchArray) - 1
		If $FoundListRowMatch <> 0 Then
			$Found_APID = $ListRowMatchArray[1][1]
			$Found_SSID = $ListRowMatchArray[1][2]
			$Found_BSSID = $ListRowMatchArray[1][3]
			$Found_AUTH = $ListRowMatchArray[1][4]
			$Found_ENCR = $ListRowMatchArray[1][5]
			$Found_RADTYPE = $ListRowMatchArray[1][6]
			$Found_NETTYPE = $ListRowMatchArray[1][7]
			$Found_CHAN = $ListRowMatchArray[1][8]
			$Found_BTX = $ListRowMatchArray[1][9]
			$Found_OTX = $ListRowMatchArray[1][10]
			$Found_MANU = $ListRowMatchArray[1][11]
			$Found_LAB = $ListRowMatchArray[1][12]
			$Found_HighGpsHistId = $ListRowMatchArray[1][13] - 0

			If $Found_HighGpsHistId = 0 Then
				$Found_Lat = 'N 0000.0000'
				$Found_Lon = 'E 0000.0000'
			Else
				$query = "SELECT GpsID FROM Hist WHERE HistID=" & $Found_HighGpsHistId
				$HistMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
				$FoundHistMatch = UBound($HistMatchArray) - 1
				$Found_HighGpsID = $HistMatchArray[1][1]
				$query = "SELECT Latitude, Longitude FROM GPS WHERE GpsID=" & $Found_HighGpsID
				$GpsMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
				$Found_Lat = $GpsMatchArray[1][1]
				$Found_Lon = $GpsMatchArray[1][2]
			EndIf

			;---------------------

			$max_graph_points = 1000
			$query = "SELECT TOP " & $max_graph_points & " Signal, Date1, Time1 FROM Hist WHERE ApID=" & $Found_APID & " And Signal<>0 ORDER BY Date1, Time1 Desc"
			$SignalMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
			$FoundSignalMatch = UBound($SignalMatchArray) - 1
			If $FoundSignalMatch <> 0 Then
				Local $Found_dts, $gloop, $pgsigdata, $Found_FirstSeen, $Found_LastSeen
				For $gs = 1 To $FoundSignalMatch
					$gloop += 1
					If $gloop > $max_graph_points Then ExitLoop
					$ExpSig = $SignalMatchArray[$gs][1] - 0
					$ExpDate = $SignalMatchArray[$gs][2]
					$ExpTime = $SignalMatchArray[$gs][3]

					$Last_dts = $Found_dts
					$ts = StringSplit($ExpTime, ":")
					$ExpTimeSecs = ($ts[1] * 3600) + ($ts[2] * 60) + StringTrimRight($ts[3], 4) ;In seconds
					$Found_dts = StringReplace($ExpDate & $ExpTimeSecs, '-', '')

					If $gs = 1 Then
						$pgsigdata = $ExpSig
						$Found_FirstSeen = $ExpDate & ' ' & $ExpTime
						$Found_LastSeen = $ExpDate & ' ' & $ExpTime
					Else
						If ($Last_dts - $Found_dts) > $TimeBeforeMarkedDead Then
							$numofzeros = ($Last_dts - $Found_dts) - $TimeBeforeMarkedDead
							For $wz = 1 To $numofzeros
								$gloop += 1
								$pgsigdata &= '-0'
								If $gloop > $max_graph_points Then ExitLoop
							Next
						EndIf
						$pgsigdata &= '-' & $ExpSig
						$Found_LastSeen = $ExpDate & ' ' & $ExpTime
					EndIf
				Next
				If $pgsigdata = "" Then
					MsgBox(0, $Text_Error, "No data to graph")
				Else
					$url_root = $WifiDbGraphURL
					$url_data = "?SSID=" & $Found_SSID & "&Mac=" & $Found_BSSID & "&Manuf=" & $Found_MANU & "&Auth=" & $Found_AUTH & "&Encry=" & $Found_ENCR & "&radio=" & $Found_RADTYPE & "&Chn=" & $Found_CHAN & "&Lat=" & $Found_Lat & "&Long=" & $Found_Lon & "&BTx=" & $Found_BTX & "&OTx=" & $Found_OTX & "&FA=" & $Found_FirstSeen & "&LU=" & $Found_LastSeen & "&NT=" & $Found_NETTYPE & "&Label=" & $Found_LAB & "&Sig=" & $pgsigdata
					$url_full = $url_root & $url_data
					$url_trimmed = StringTrimRight($url_full, (StringLen($url_full) - 2048)) ;trim sting to internet explorer max url lenth
					$url_trimmed2 = StringTrimRight($url_trimmed, (StringLen($url_trimmed) - StringInStr($url_trimmed, "-", 1, -1)) + 1);find - that marks the last full data and get rid of the rest
					Run("RunDll32.exe url.dll,FileProtocolHandler " & $url_trimmed2);open url with rundll 32
				EndIf
			EndIf
		EndIf
	Else
		MsgBox(0, $Text_Error, $Text_NoApSelected)
	EndIf
EndFunc   ;==>_ViewInWifiDbGraph_Open

Func _AddToYourWDB()
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_AddToYourWDB()') ;#Debug Display
	If $UploadFileToWifiDBOpen = 0 Then
		$UploadFileToWifiDBOpen = 1
		$WifiDbUploadGUI = GUICreate($Text_UploadApsToWifidb, 580, 525)
		GUISetBkColor($BackgroundColor)
		GUICtrlCreateLabel($Text_WifiDB_Upload_Discliamer, 24, 8, 532, 89)

		GUICtrlCreateGroup($Text_UserInformation, 24, 104, 281, 161)
		GUICtrlCreateLabel($Text_WifiDB_Username, 39, 124, 236, 20)
		$WifiDb_User_GUI = GUICtrlCreateInput($WifiDb_User, 39, 144, 241, 20)
		GUICtrlCreateLabel($Text_OtherUsers, 39, 169, 236, 20)
		$WifiDb_OtherUsers_GUI = GUICtrlCreateInput($WifiDb_OtherUsers, 39, 189, 241, 20)
		GUICtrlSetState($WifiDb_OtherUsers_GUI, $GUI_DISABLE)
		GUICtrlCreateLabel($Text_WifiDB_Api_Key, 39, 213, 236, 20)
		$WifiDb_ApiKey_GUI = GUICtrlCreateInput($WifiDb_ApiKey, 39, 233, 241, 21)
		GUICtrlSetState($WifiDb_ApiKey_GUI, $GUI_DISABLE)

		GUICtrlCreateGroup($Text_FileType, 312, 104, 249, 161)
		$VSZ_Radio_GUI = GUICtrlCreateRadio($Text_VistumblerVSZ, 327, 150, 220, 20)
		;If $WifiDb_UploadType = "VSZ" Then GUICtrlSetState($VSZ_Radio_GUI, $GUI_CHECKED)
		GUICtrlSetState($VSZ_Radio_GUI, $GUI_DISABLE)
		$VS1_Radio_GUI = GUICtrlCreateRadio($Text_VistumblerVS1, 327, 170, 220, 20)
		If $WifiDb_UploadType = "VS1" Then GUICtrlSetState($VS1_Radio_GUI, $GUI_CHECKED)
		If $WifiDb_UploadType = "VSZ" Then GUICtrlSetState($VS1_Radio_GUI, $GUI_CHECKED);temporarily make vsz export vs1 since vsz support is not ready
		$CSV_Radio_GUI = GUICtrlCreateRadio($Text_VistumblerCSV, 327, 190, 220, 20)
		If $WifiDb_UploadType = "CSV" Then GUICtrlSetState($CSV_Radio_GUI, $GUI_CHECKED)
		$Export_Filtered_GUI = GUICtrlCreateCheckbox($Text_Filtered, 327, 210, 220, 20)
		If $WifiDb_UploadFiltered = 1 Then GUICtrlSetState($Export_Filtered_GUI, $GUI_CHECKED)

		GUICtrlCreateGroup($Text_UploadInformation, 24, 272, 537, 201)
		GUICtrlCreateLabel($Text_Title, 39, 297, 500, 20)
		$upload_title_GUI = GUICtrlCreateInput($ldatetimestamp, 39, 317, 500, 21)
		GUICtrlCreateLabel($Text_Notes, 39, 342, 500, 20)
		$upload_notes_GUI = GUICtrlCreateEdit("", 39, 362, 497, 100)

		$WifiDbUploadGUI_Upload = GUICtrlCreateButton($Text_UploadApsToWifidb, 35, 488, 241, 25)
		$WifiDbUploadGUI_Cancel = GUICtrlCreateButton($Text_Cancel, 305, 487, 241, 25)
		GUISetState(@SW_SHOW)

		GUICtrlSetOnEvent($WifiDbUploadGUI_Upload, '_UploadFileToWifiDB')
		GUICtrlSetOnEvent($WifiDbUploadGUI_Cancel, '_CloseWifiDbUploadGUI')
		GUISetOnEvent($GUI_EVENT_CLOSE, '_CloseWifiDbUploadGUI')
	Else
		WinActivate($WifiDbUploadGUI)
	EndIf
EndFunc   ;==>_AddToYourWDB

Func _CloseWifiDbUploadGUI()
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_CloseWifiDbUploadGUI() ') ;#Debug Display
	GUIDelete($WifiDbUploadGUI)
	$UploadFileToWifiDBOpen = 0
EndFunc   ;==>_CloseWifiDbUploadGUI

Func _UploadFileToWifiDB()
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_UploadFileToWifiDB() ') ;#Debug Display
	GUICtrlSetData($msgdisplay, $Text_UploadingApsToWifidb)
	;Get Upload Information from upload GUI
	$WifiDb_User = GUICtrlRead($WifiDb_User_GUI)
	If $WifiDb_User = "" Then $WifiDb_User = "Unknown"
	$WifiDb_OtherUsers = GUICtrlRead($WifiDb_OtherUsers_GUI)
	$WifiDb_ApiKey = GUICtrlRead($WifiDb_ApiKey_GUI)
	$upload_title = GUICtrlRead($upload_title_GUI)
	$upload_notes = GUICtrlRead($upload_notes_GUI)

	If GUICtrlRead($VS1_Radio_GUI) = 1 Then
		$WdbFile = $SaveDir & 'WDB_Export.VS1'
		$WifiDb_UploadType = "VS1"
	ElseIf GUICtrlRead($CSV_Radio_GUI) = 1 Then
		$WdbFile = $SaveDir & 'WDB_Export.CSV'
		$WifiDb_UploadType = "CSV"
	Else
		$WdbFile = $SaveDir & 'WDB_Export.VSZ'
		$WifiDb_UploadType = "VSZ"
	EndIf

	If GUICtrlRead($Export_Filtered_GUI) = 1 Then
		$WifiDb_UploadFiltered = 1
	Else
		$WifiDb_UploadFiltered = 0
	EndIf

	ConsoleWrite("$WifiDb_UploadType:" & $WifiDb_UploadType & "$WifiDb_UploadFiltered:" & $WifiDb_UploadFiltered & " $WifiDb_User:" & $WifiDb_User & " $WifiDb_OtherUsers:" & $WifiDb_OtherUsers & " $WifiDb_ApiKey:" & $WifiDb_ApiKey & " $upload_title:" & $upload_title & " $upload_notes:" & $upload_notes & @CRLF)
	_CloseWifiDbUploadGUI()

	;Get Host, Path, and Port from WifiDB api url
	$hpparr = _Get_HostPortPath($WifiDbApiURL)
	If Not @error Then
		Local $host, $port, $path
		$host = $hpparr[1]
		$port = $hpparr[2]
		$path = $hpparr[3]
		$page = $path & "import.php"
		ConsoleWrite('$host:' & $host & ' ' & '$port:' & $port & @CRLF)
		ConsoleWrite($path & @CRLF)

		;Export WDB File
		Local $fileexported, $filetype, $fileuname, $fileread
		If $WifiDb_UploadType = "VS1" Then
			$fileexported = _ExportVS1($WdbFile, $WifiDb_UploadFiltered)
			$filetype = "text/plain; charset=""UTF-8"""
			$fileuname = $ldatetimestamp & "_VS.VS1"
			If $fileexported = 1 Then $fileread = FileRead($WdbFile)
		ElseIf $WifiDb_UploadType = "CSV" Then
			$fileexported = _ExportToCSV($WdbFile, $WifiDb_UploadFiltered, 1)
			$filetype = "text/plain; charset=""UTF-8"""
			$fileuname = $ldatetimestamp & "_VS.CSV"
			If $fileexported = 1 Then $fileread = FileRead($WdbFile)
		Else
			$fileexported = _ExportVSZ($WdbFile, $WifiDb_UploadFiltered)
			$filetype = "application/octet-stream"
			$fileuname = $ldatetimestamp & "_VS.VSZ"
			If $fileexported = 1 Then $fileread = FileRead($WdbFile) & @CRLF
		EndIf

		If $fileexported = 1 Then ;Upload File to WifiDB
			$socket = _HTTPConnect($host, $port)
			If Not @error Then
				_HTTPPost_WifiDB_File($host, $page, $socket, $fileread, $fileuname, $filetype, $WifiDb_ApiKey, $WifiDb_User, $WifiDb_OtherUsers, $upload_title, $upload_notes)
				$recv = _HTTPRead($socket, 1)
				If @error Then
					ConsoleWrite("_HTTPRead Error:" & @error & @CRLF)
					MsgBox(0, $Text_Error, "_HTTPRead Error:" & @error)
				Else
					Local $httprecv, $import_json_response, $json_array_size, $json_msg
					$httprecv = $recv[4]
					ConsoleWrite($httprecv & @CRLF)
					$import_json_response = _JSONDecode($httprecv)
					$import_json_response_iRows = UBound($import_json_response, 1)
					$import_json_response_iCols = UBound($import_json_response, 2)
					;Pull out information from decoded json array
					If $import_json_response_iCols = 2 Then
						Local $imtitle, $imuser, $immessage, $imimportnum, $imfilehash, $imerror
						For $ji = 0 To ($import_json_response_iRows - 1)
							If $import_json_response[$ji][0] = 'title' Then $imtitle = $import_json_response[$ji][1]
							If $import_json_response[$ji][0] = 'user' Then $imuser = $import_json_response[$ji][1]
							If $import_json_response[$ji][0] = 'message' Then $immessage = $import_json_response[$ji][1]
							If $import_json_response[$ji][0] = 'importnum' Then $imimportnum = $import_json_response[$ji][1]
							If $import_json_response[$ji][0] = 'filehash' Then $imfilehash = $import_json_response[$ji][1]
							If $import_json_response[$ji][0] = 'error' Then $imerror = $import_json_response[$ji][1]
						Next
						If $imtitle <> "" Or $imuser <> "" Or $immessage <> "" Or $imimportnum <> "" Or $imfilehash <> "" Then
							MsgBox(0, $Text_Information, "Title: " & $imtitle & @CRLF & "User: " & $imuser & @CRLF & "Message: " & $immessage & @CRLF & "Import Number: " & $imimportnum & @CRLF & "File Hash: " & $imfilehash & @CRLF)
							ConsoleWrite("Title: " & $imtitle & @CRLF & "User: " & $imuser & @CRLF & "Message: " & $immessage & @CRLF & "Import Number: " & $imimportnum & @CRLF & "File Hash: " & $imfilehash & @CRLF)
						Else
							MsgBox(0, $Text_Error, $httprecv)
						EndIf
					Else
						MsgBox(0, $Text_Error, "Unexpected array size from _JSONDecode()" & @CRLF & @CRLF & "-- HTTP Response --" & @CRLF & $httprecv)
					EndIf
				EndIf
			Else
				MsgBox(0, $Text_Error, "_HTTPConnect Error: Unable to open socket - WSAGetLasterror:" & @extended)
				ConsoleWrite("_HTTPConnect Error: Unable to open socket - WSAGetLasterror:" & @extended & @CRLF)
			EndIf
		Else ;File Export failed
			ConsoleWrite("No export created for some reason... are there APs to be exported?" & @CRLF)
			MsgBox(0, $Text_Error, "No export created for some reason... are there APs to be exported?")
		EndIf
	Else
		ConsoleWrite("error getting host, path, and port from url """ & $WifiDbApiURL & """" & @CRLF)
		MsgBox(0, $Text_Error, "error getting host, path, and port from url """ & $WifiDbApiURL & """")
	EndIf
	GUICtrlSetData($msgdisplay, '');Clear $msgdisplay
EndFunc   ;==>_UploadFileToWifiDB

Func _Get_HostPortPath($inURL)
	Local $host, $port, $path
	$hstring = StringTrimRight($inURL, StringLen($inURL) - (StringInStr($inURL, "/", 0, 3) - 1))
	$path = StringTrimLeft($inURL, StringInStr($inURL, "/", 0, 3) - 1)
	If StringInStr($hstring, ":", 0, 2) Then
		$hpa = StringSplit($hstring, ":")
		If $hpa[0] = 3 Then
			$host = StringReplace($hpa[2], "//", "")
			$port = $hpa[3]
		EndIf
	Else
		$host = StringReplace(StringReplace($hstring, "https://", ""), "http://", "")
		If StringInStr($hstring, "https://") Then
			$port = 443
		Else
			$port = 80
		EndIf
	EndIf
	If $host <> "" And $port <> "" And $path <> "" Then
		Local $hpResults[4]
		$hpResults[0] = 3
		$hpResults[1] = $host
		$hpResults[2] = $port
		$hpResults[3] = $path
		Return $hpResults
	Else
		SetError(1);something messed up splitting the given URL....who knows what.
	EndIf
EndFunc   ;==>_Get_HostPortPath

Func _HTTPPost_WifiDB_File($host, $page, $socket, $file, $filename, $contenttype, $apikey, $user, $otherusers, $title, $notes)
	Local $command, $extra_commands
	Local $boundary = "------------" & Chr(Random(Asc("A"), Asc("Z"), 3)) & Chr(Random(Asc("a"), Asc("z"), 3)) & Chr(Random(Asc("A"), Asc("Z"), 3)) & Chr(Random(Asc("a"), Asc("z"), 3)) & Random(1, 9, 1) & Random(1, 9, 1) & Random(1, 9, 1) & Chr(Random(Asc("A"), Asc("Z"), 3)) & Chr(Random(Asc("a"), Asc("z"), 3)) & Chr(Random(Asc("A"), Asc("Z"), 3)) & Chr(Random(Asc("a"), Asc("z"), 3)) & Random(1, 9, 1) & Random(1, 9, 1) & Random(1, 9, 1)

	If $apikey <> "" Then
		$extra_commands = "--" & $boundary & @CRLF
		$extra_commands &= "Content-Disposition: form-data; name=""apikey""" & @CRLF & @CRLF
		$extra_commands &= $apikey & @CRLF
	EndIf
	If $user <> "" Then
		$extra_commands &= "--" & $boundary & @CRLF
		$extra_commands &= "Content-Disposition: form-data; name=""username""" & @CRLF & @CRLF
		$extra_commands &= $user & @CRLF
	EndIf
	If $otherusers <> "" Then
		$extra_commands &= "--" & $boundary & @CRLF
		$extra_commands &= "Content-Disposition: form-data; name=""otherusers""" & @CRLF & @CRLF
		$extra_commands &= $otherusers & @CRLF
	EndIf
	If $title <> "" Then
		$extra_commands &= "--" & $boundary & @CRLF
		$extra_commands &= "Content-Disposition: form-data; name=""title""" & @CRLF & @CRLF
		$extra_commands &= $title & @CRLF
	EndIf
	If $notes <> "" Then
		$extra_commands &= "--" & $boundary & @CRLF
		$extra_commands &= "Content-Disposition: form-data; name=""notes""" & @CRLF & @CRLF
		$extra_commands &= $notes & @CRLF
	EndIf
	$extra_commands &= "--" & $boundary & @CRLF
	$extra_commands &= "Content-Disposition: form-data; name=""file""; filename=""" & $filename & """" & @CRLF
	$extra_commands &= "Content-Type: " & $contenttype & @CRLF & @CRLF

	$extra_commands &= $file
	$extra_commands &= "--" & $boundary & "--"

	Dim $datasize = StringLen($extra_commands)

	$command = "POST " & $page & " HTTP/1.1" & @CRLF
	$command &= "Host: " & $host & @CRLF
	$command &= "User-Agent: " & $Script_Name & ' ' & $version & @CRLF
	$command &= "Connection: close" & @CRLF
	$command &= "Content-Type: multipart/form-data; boundary=" & $boundary & @CRLF
	$command &= "Content-Length: " & $datasize & @CRLF & @CRLF
	$command &= $extra_commands

	If $contenttype = "application/octet-stream" Then
		ConsoleWrite(StringReplace($command, $file, "## BINARY DATA FILE ##" & @CRLF) & @CRLF)
	Else
		ConsoleWrite($command & @CRLF)
	EndIf

	Dim $bytessent = TCPSend($socket, $command)

	If $bytessent == 0 Then
		SetExtended(@error)
		SetError(2)
		Return 0
	EndIf

	SetError(0)
	Return $bytessent
EndFunc   ;==>_HTTPPost_WifiDB_File

Func _LocatePositionInWiFiDB();Finds GPS based on active acess points displays information in message box
	_LocateGpsInWifidb(1)
EndFunc   ;==>_LocatePositionInWiFiDB

Func _LocateGpsInWifidb($ShowPrompts = 0);Finds GPS based on active acess points based on WifiDB for use in vistumbler
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_LocatePositionInWiFiDB()') ;#Debug Display
	Local $ActiveMacs = ""
	Local $return = 0
	$query = "SELECT BSSID, Signal FROM AP WHERE Active=1 And ListRow<>-1 And BSSID<>''"
	$BssidMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
	$FoundBssidMatch = UBound($BssidMatchArray) - 1
	If $FoundBssidMatch <> 0 Then
		For $exb = 1 To $FoundBssidMatch
			If $exb <> 1 Then $ActiveMacs &= '-'
			$ActiveMacs &= $BssidMatchArray[$exb][1] & '|' & ($BssidMatchArray[$exb][2] + 0)
		Next
		If $ActiveMacs <> "" Then
			;Get Host, Path, and Port from WifiDB api url
			$hpparr = _Get_HostPortPath($WifiDbApiURL)
			If Not @error Then
				Local $host, $port, $path
				$host = $hpparr[1]
				$port = $hpparr[2]
				$path = $hpparr[3]
				$page = $path & "locate.php"
				ConsoleWrite('$host:' & $host & ' ' & '$port:' & $port & @CRLF)
				ConsoleWrite($path & @CRLF)
				;Get information from WifiDB
				$socket = _HTTPConnect($host, $port)
				If Not @error Then
					_HTTPPost_WifiDB_LocateGPS($host, $page, $socket, $ActiveMacs)
					$recv = _HTTPRead($socket, 1)
					If @error Then
						ConsoleWrite("_HTTPRead Error:" & @error & @CRLF)
						If $ShowPrompts = 1 Then MsgBox(0, $Text_Error, "_HTTPRead Error:" & @error)
					Else
						;Read WifiDB JSON Response
						Local $httprecv, $import_json_response, $json_array_size
						$httprecv = $recv[4]
						ConsoleWrite($httprecv & @CRLF)
						$import_json_response = _JSONDecode($httprecv)
						$import_json_response_iRows = UBound($import_json_response, 1)
						$import_json_response_iCols = UBound($import_json_response, 2)
						If $import_json_response_iCols = 2 Then
							;Pull out information from decoded json array
							Local $lglat, $lglon, $lgdate, $lgtime, $lgsats, $lgerror
							For $ji = 0 To ($import_json_response_iRows - 1)
								If $import_json_response[$ji][0] = 'lat' Then $lglat = $import_json_response[$ji][1]
								If $import_json_response[$ji][0] = 'long' Then $lglon = $import_json_response[$ji][1]
								If $import_json_response[$ji][0] = 'date' Then $lgdate = $import_json_response[$ji][1]
								If $import_json_response[$ji][0] = 'time' Then $lgtime = $import_json_response[$ji][1]
								If $import_json_response[$ji][0] = 'sats' Then $lgsats = $import_json_response[$ji][1]
								If $import_json_response[$ji][0] = 'error' Then $lgerror = $import_json_response[$ji][1]
							Next
							;Update Vistumbler GPS info with what was pulled from wifidb
							If $lglat <> '' And $lglon <> '' Then
								;Format Lat/Lon
								If StringInStr($lglat, "-") Then
									$lglat = "S " & StringReplace(StringReplace($lglat, "-", ""), "0.0000", "0000.0000")
								Else
									$lglat = "N " & StringReplace(StringReplace($lglat, "+", ""), "0.0000", "0000.0000")
								EndIf
								If StringInStr($lglon, "-") Then
									$lglon = "W " & StringReplace(StringReplace($lglon, "-", ""), "0.0000", "0000.0000")
								Else
									$lglon = "E " & StringReplace(StringReplace($lglon, "+", ""), "0.0000", "0000.0000")
								EndIf
								;Set WifiDB Lat/Lon
								$LatitudeWifidb = $lglat
								$LongitudeWifidb = $lglon
								;Show Prompt
								If $ShowPrompts = 1 Then MsgBox(0, $Text_Information, $Text_Latitude & ': ' & $lglat & @CRLF & $Text_Longitude & ': ' & $lglon & @CRLF & $Text_Date & ': ' & $lgdate & @CRLF & $Text_Time & ': ' & $lgtime & @CRLF)
								ConsoleWrite('$lglat:' & $lglat & ' $lglon:' & $lglon & ' $lgdate:' & $lgdate & ' $lgtime:' & $lgtime & ' $lgsats:' & $lgsats & @CRLF)
								;Reset update timer
								$WifidbGPS_Update = TimerInit()
								$return = 1
							ElseIf $lgerror <> '' Then
								If $ShowPrompts = 1 Then MsgBox(0, $Text_Error, $Text_Error & ': ' & $lgerror)
								ConsoleWrite($Text_Error & ': ' & $lgerror & @CRLF)
							Else
								If $ShowPrompts = 1 Then MsgBox(0, $Text_Error, $Text_Error & ': ' & $httprecv)
								ConsoleWrite($Text_Error & ': ' & $httprecv & @CRLF)
							EndIf
						Else
							If $ShowPrompts = 1 Then MsgBox(0, $Text_Error, "Unexpected array size from _JSONDecode()" & @CRLF & @CRLF & "-- HTTP Response --" & @CRLF & $httprecv)
						EndIf
					EndIf
				Else
					If $ShowPrompts = 1 Then MsgBox(0, $Text_Error, "_HTTPConnect Error: Unable to open socket - WSAGetLasterror:" & @extended)
					ConsoleWrite("_HTTPConnect Error: Unable to open socket - WSAGetLasterror:" & @extended & @CRLF)
				EndIf
			Else
				If $ShowPrompts = 1 Then MsgBox(0, $Text_Error, "error getting host, path, and port from url """ & $WifiDbApiURL & """")
				ConsoleWrite("error getting host, path, and port from url """ & $WifiDbApiURL & """" & @CRLF)
			EndIf
		EndIf
	Else
		If $ShowPrompts = 1 Then MsgBox(0, $Text_Error, $Text_NoActiveApFound)
	EndIf

	;Update GPS Information in GUI
	_ClearGpsDetailsGUI();Reset variables if they are over the allowed timeout
	_UpdateGpsDetailsGUI();Write changes to "GPS Details" GUI if it is open

	Return ($return)
EndFunc   ;==>_LocateGpsInWifidb

Func _HTTPPost_WifiDB_LocateGPS($host, $page, $socket, $ActiveBSSIDs)
	Local $command, $extra_commands
	Local $boundary = "------------" & Chr(Random(Asc("A"), Asc("Z"), 3)) & Chr(Random(Asc("a"), Asc("z"), 3)) & Chr(Random(Asc("A"), Asc("Z"), 3)) & Chr(Random(Asc("a"), Asc("z"), 3)) & Random(1, 9, 1) & Random(1, 9, 1) & Random(1, 9, 1) & Chr(Random(Asc("A"), Asc("Z"), 3)) & Chr(Random(Asc("a"), Asc("z"), 3)) & Chr(Random(Asc("A"), Asc("Z"), 3)) & Chr(Random(Asc("a"), Asc("z"), 3)) & Random(1, 9, 1) & Random(1, 9, 1) & Random(1, 9, 1)

	$extra_commands = "--" & $boundary & @CRLF
	$extra_commands &= "Content-Disposition: form-data; name=""ActiveBSSIDs""" & @CRLF & @CRLF
	$extra_commands &= $ActiveBSSIDs & @CRLF
	$extra_commands &= "--" & $boundary & "--"

	Dim $datasize = StringLen($extra_commands)

	$command = "POST " & $page & " HTTP/1.1" & @CRLF
	$command &= "Host: " & $host & @CRLF
	$command &= "User-Agent: " & $Script_Name & ' ' & $version & @CRLF
	$command &= "Connection: close" & @CRLF
	$command &= "Content-Type: multipart/form-data; boundary=" & $boundary & @CRLF
	$command &= "Content-Length: " & $datasize & @CRLF & @CRLF
	$command &= $extra_commands
	ConsoleWrite($command & @CRLF)

	Dim $bytessent = TCPSend($socket, $command)

	If $bytessent == 0 Then
		SetExtended(@error)
		SetError(2)
		Return 0
	EndIf

	SetError(0)
	Return $bytessent
EndFunc   ;==>_HTTPPost_WifiDB_LocateGPS

Func _GeoLocate($lat, $lon, $ShowPrompts = 0)
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_GeoLocate()') ;#Debug Display
	Local $return = 0
	$lat = StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($lat), "N", ""), "S", "-"), " ", "")
	$lon = StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($lon), "E", ""), "W", "-"), " ", "")
	$hpparr = _Get_HostPortPath($WifiDbApiURL)
	If Not @error Then
		Local $host, $port, $path
		$host = $hpparr[1]
		$port = $hpparr[2]
		$path = $hpparr[3]
		$page = $path & "geonames.php"
		ConsoleWrite('$host:' & $host & ' ' & '$port:' & $port & @CRLF)
		ConsoleWrite($path & @CRLF)
		;Get information from WifiDB
		$socket = _HTTPConnect($host, $port)
		If Not @error Then
			_HTTPPost_WifiDB_GeoLocate($host, $page, $socket, $lat, $lon)
			$recv = _HTTPRead($socket, 1)
			If @error Then
				ConsoleWrite("_HTTPRead Error:" & @error & @CRLF)
				If $ShowPrompts = 1 Then MsgBox(0, $Text_Error, "_HTTPRead Error:" & @error)
			Else
				;Read WifiDB JSON Response
				Local $httprecv, $import_json_response, $json_array_size
				$httprecv = $recv[4]
				ConsoleWrite($httprecv & @CRLF)
				$import_json_response = _JSONDecode($httprecv)
				$import_json_response_iRows = UBound($import_json_response, 1)
				$import_json_response_iCols = UBound($import_json_response, 2)
				If $import_json_response_iCols = 2 Then
					;Pull out information from decoded json array
					Local $gncc, $gncn, $gna1c, $gna1n, $gna2n, $gnan, $gnerr, $gnm, $gnkm
					For $ji = 0 To ($import_json_response_iRows - 1)
						If $import_json_response[$ji][0] = 'Country Code' Then $gncc = $import_json_response[$ji][1]
						If $import_json_response[$ji][0] = 'Country Name' Then $gncn = $import_json_response[$ji][1]
						If $import_json_response[$ji][0] = 'Admin1 Code' Then $gna1c = $import_json_response[$ji][1]
						If $import_json_response[$ji][0] = 'Admin1 Name' Then $gna1n = $import_json_response[$ji][1]
						If $import_json_response[$ji][0] = 'Admin2 Name' Then $gna2n = $import_json_response[$ji][1]
						If $import_json_response[$ji][0] = 'Area Name' Then $gnan = $import_json_response[$ji][1]
						If $import_json_response[$ji][0] = 'miles' Then $gnm = $import_json_response[$ji][1]
						If $import_json_response[$ji][0] = 'km' Then $gnkm = $import_json_response[$ji][1]
						If $import_json_response[$ji][0] = 'error' Then $gnerr = $import_json_response[$ji][1]
					Next
					If $gncc <> "" Or $gncn <> "" Or $gna1c <> "" Or $gna1n <> "" Or $gna2n <> "" Or $gnan <> "" Or $gnm <> "" Or $gnkm <> "" Or $gnerr <> "" Then
						Local $aReturn[9]
						$aReturn[1] = $gncc
						$aReturn[2] = $gncn
						$aReturn[3] = $gna1c
						$aReturn[4] = $gna1n
						$aReturn[5] = $gna2n
						$aReturn[6] = $gnan
						$aReturn[7] = $gnm
						$aReturn[8] = $gnkm
						Return $aReturn
					Else
						Local $aReturn[2]
						$aReturn[1] = $gnerr
						SetError(1)
						Return
					EndIf
				Else
					If $ShowPrompts = 1 Then MsgBox(0, $Text_Error, "Unexpected array size from _JSONDecode()" & @CRLF & @CRLF & "-- HTTP Response --" & @CRLF & $httprecv)
				EndIf
			EndIf
		Else
			If $ShowPrompts = 1 Then MsgBox(0, $Text_Error, "_HTTPConnect Error: Unable to open socket - WSAGetLasterror:" & @extended)
			ConsoleWrite("_HTTPConnect Error: Unable to open socket - WSAGetLasterror:" & @extended & @CRLF)
		EndIf
	EndIf
EndFunc   ;==>_GeoLocate

Func _HTTPPost_WifiDB_GeoLocate($host, $page, $socket, $lat, $lon)
	Local $command, $extra_commands
	Local $boundary = "------------" & Chr(Random(Asc("A"), Asc("Z"), 3)) & Chr(Random(Asc("a"), Asc("z"), 3)) & Chr(Random(Asc("A"), Asc("Z"), 3)) & Chr(Random(Asc("a"), Asc("z"), 3)) & Random(1, 9, 1) & Random(1, 9, 1) & Random(1, 9, 1) & Chr(Random(Asc("A"), Asc("Z"), 3)) & Chr(Random(Asc("a"), Asc("z"), 3)) & Chr(Random(Asc("A"), Asc("Z"), 3)) & Chr(Random(Asc("a"), Asc("z"), 3)) & Random(1, 9, 1) & Random(1, 9, 1) & Random(1, 9, 1)

	$extra_commands = "--" & $boundary & @CRLF
	$extra_commands &= "Content-Disposition: form-data; name=""lat""" & @CRLF & @CRLF
	$extra_commands &= $lat & @CRLF
	$extra_commands &= "--" & $boundary & @CRLF
	$extra_commands &= "Content-Disposition: form-data; name=""long""" & @CRLF & @CRLF
	$extra_commands &= $lon & @CRLF
	$extra_commands &= "--" & $boundary & "--"

	Dim $datasize = StringLen($extra_commands)

	$command = "POST " & $page & " HTTP/1.1" & @CRLF
	$command &= "Host: " & $host & @CRLF
	$command &= "User-Agent: " & $Script_Name & ' ' & $version & @CRLF
	$command &= "Connection: close" & @CRLF
	$command &= "Content-Type: multipart/form-data; boundary=" & $boundary & @CRLF
	$command &= "Content-Length: " & $datasize & @CRLF & @CRLF
	$command &= $extra_commands
	ConsoleWrite($command & @CRLF)

	Dim $bytessent = TCPSend($socket, $command)

	If $bytessent == 0 Then
		SetExtended(@error)
		SetError(2)
		Return 0
	EndIf

	SetError(0)
	Return $bytessent
EndFunc   ;==>_HTTPPost_WifiDB_GeoLocate

Func _GeonamesInfo($SelectedRow)
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_CopyAP_GUI() ') ;#Debug Display
	$query = "SELECT CountryCode, CountryName, AdminCode, AdminName, Admin2Name, AreaName, GNAmiles, GNAkm FROM AP WHERE ListRow=" & $SelectedRow
	$ApMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
	$FoundApMatch = UBound($ApMatchArray) - 1
	If $SelectedRow <> -1 And $FoundApMatch <> 0 Then ;If a access point is selected in the listview, map its data
		Local $GN_CountryCode = "Not Available", $GN_CountryName = "Not Available", $GN_AdminCode = "Not Available", $GN_AdminName = "Not Available", $GN_Admin2Name = "Not Available", $GN_AreaName = "Not Available", $GN_GNAmiles = "Not Available", $GN_GNAkm = "Not Available"
		If $ApMatchArray[1][1] <> "" Then $GN_CountryCode = $ApMatchArray[1][1]
		If $ApMatchArray[1][2] <> "" Then $GN_CountryName = $ApMatchArray[1][2]
		If $ApMatchArray[1][3] <> "" Then $GN_AdminCode = $ApMatchArray[1][3]
		If $ApMatchArray[1][4] <> "" Then $GN_AdminName = $ApMatchArray[1][4]
		If $ApMatchArray[1][5] <> "" Then $GN_Admin2Name = $ApMatchArray[1][5]
		If $ApMatchArray[1][6] <> "" Then $GN_AreaName = $ApMatchArray[1][6]
		If $ApMatchArray[1][7] <> -1 Then $GN_GNAmiles = $ApMatchArray[1][7]
		If $ApMatchArray[1][8] <> -1 Then $GN_GNAkm = $ApMatchArray[1][8]
		MsgBox(0, $Text_Information, "Country Code: " & $GN_CountryCode & @CRLF & "Country Name: " & $GN_CountryName & @CRLF & "Admin Code: " & $GN_AdminCode & @CRLF & "Admin Name: " & $GN_AdminName & @CRLF & "Admin2 Name: " & $GN_Admin2Name & @CRLF & "Area Name: " & $GN_AreaName & @CRLF & 'Accuracy(miles): ' & $GN_GNAmiles & @CRLF & 'Accuracy(km): ' & $GN_GNAkm)
	Else
		If $SelectedRow = -1 Then
			MsgBox(0, $Text_Error, $Text_NoApSelected)
		ElseIf $FoundApMatch = 0 Then
			MsgBox(0, $Text_Error, "No AP match found")
		EndIf
	EndIf
EndFunc   ;==>_GeonamesInfo

Func _ViewLiveInWDB();View wifidb live aps in browser
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_ViewLiveInWDB()') ;#Debug Display
	$url = $WifiDbWdbURL & 'opt/live.php'
	Run("RunDll32.exe url.dll,FileProtocolHandler " & $url);open url with rundll 32
EndFunc   ;==>_ViewLiveInWDB

Func _LocateAPInWifidb($Selected, $ShowPrompts = 0);Finds AP in WifiDB
	ConsoleWrite("$Selected:" & $Selected & @CRLF)
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_LocateAPInWifidb()') ;#Debug Display
	If $Selected <> -1 Then
		$query = "SELECT TOP 1 SSID, BSSID, RADTYPE, CHAN, AUTH, ENCR FROM AP WHERE ListRow=" & $Selected
		ConsoleWrite("$query:" & $query & @CRLF)
		$ApMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
		$FoundApMatch = UBound($ApMatchArray) - 1
		If $FoundApMatch <> 0 Then
			Local $ExpSSID, $ExpBSSID, $ExpRAD, $ExpCHAN, $ExpAUTH, $ExpENCR
			$ExpSSID = $ApMatchArray[1][1]
			$ExpBSSID = $ApMatchArray[1][2]
			$ExpRAD = $ApMatchArray[1][3]
			$ExpCHAN = $ApMatchArray[1][4]
			$ExpAUTH = $ApMatchArray[1][5]
			$ExpENCR = $ApMatchArray[1][6]

			;Get Host, Path, and Port from WifiDB api url
			$hpparr = _Get_HostPortPath($WifiDbApiURL)
			If Not @error Then
				Local $host, $port, $path
				$host = $hpparr[1]
				$port = $hpparr[2]
				$path = $hpparr[3]
				$page = $path & "search.php"
				ConsoleWrite('$host:' & $host & ' ' & '$port:' & $port & @CRLF)
				ConsoleWrite($page & @CRLF)
				;Get information from WifiDB
				$socket = _HTTPConnect($host, $port)
				If Not @error Then
					_HTTPPost_WifiDB_LocateAP($host, $page, $socket, $ExpSSID, $ExpBSSID, $ExpRAD, $ExpCHAN, $ExpAUTH, $ExpENCR)
					$recv = _HTTPRead($socket, 1)
					If @error Then
						ConsoleWrite("_HTTPRead Error:" & @error & @CRLF)
						If $ShowPrompts = 1 Then MsgBox(0, $Text_Error, "_HTTPRead Error:" & @error)
					Else
						;Read WifiDB JSON Response
						Local $httprecv, $import_json_response, $iRows, $iCols
						$httprecv = $recv[4]
						ConsoleWrite($httprecv & @CRLF)
						$import_json_response = _JSONDecode($httprecv)
						$import_json_response_iRows = UBound($import_json_response, 1)
						$import_json_response_iCols = UBound($import_json_response, 2)
						ConsoleWrite('$import_json_response_iCols:' & $import_json_response_iCols & @CRLF)
						If $import_json_response_iRows <> 0 And $import_json_response_iCols = 0 Then
							;Pull out information from decoded json array
							Local $lglat, $lglon, $lgdate, $lgtime, $lgsats, $lgerror
							For $ji = 0 To ($import_json_response_iRows - 1)
								$aparr = $import_json_response[$ji]
								$aparr_iRows = UBound($aparr, 1)
								$aparr_iCols = UBound($aparr, 2)
								ConsoleWrite('$aparr_iCols:' & $aparr_iCols & @CRLF)
								If $aparr_iCols = 2 Then
									Local $aid, $assid, $amac, $asectype, $achan, $aauth, $aencry, $aradio, $abtx, $aotx, $alabel, $afa, $ala, $ant, $amanuf, $ageonames_id, $aadmin1_id, $aadmin2_id, $ausername, $aap_hash
									For $ai = 0 To ($aparr_iRows - 1)
										If $aparr[$ai][0] = 'id' Then $aid = $aparr[$ai][1]
										If $aparr[$ai][0] = 'ssid' Then $assid = $aparr[$ai][1]
										If $aparr[$ai][0] = 'mac' Then $amac = $aparr[$ai][1]
										If $aparr[$ai][0] = 'sectype' Then $asectype = $aparr[$ai][1]
										If $aparr[$ai][0] = 'chan' Then $achan = $aparr[$ai][1]
										If $aparr[$ai][0] = 'auth' Then $aauth = $aparr[$ai][1]
										If $aparr[$ai][0] = 'encry' Then $aencry = $aparr[$ai][1]
										If $aparr[$ai][0] = 'radio' Then $aradio = $aparr[$ai][1]
										If $aparr[$ai][0] = 'BTx' Then $abtx = $aparr[$ai][1]
										If $aparr[$ai][0] = 'OTx' Then $aotx = $aparr[$ai][1]
										If $aparr[$ai][0] = 'label' Then $alabel = $aparr[$ai][1]
										If $aparr[$ai][0] = 'FA' Then $afa = $aparr[$ai][1]
										If $aparr[$ai][0] = 'LA' Then $ala = $aparr[$ai][1]
										If $aparr[$ai][0] = 'NT' Then $ant = $aparr[$ai][1]
										If $aparr[$ai][0] = 'manuf' Then $amanuf = $aparr[$ai][1]
										If $aparr[$ai][0] = 'geonames_id' Then $ageonames_id = $aparr[$ai][1]
										If $aparr[$ai][0] = 'admin1_id' Then $aadmin1_id = $aparr[$ai][1]
										If $aparr[$ai][0] = 'admin2_id' Then $aadmin2_id = $aparr[$ai][1]
										If $aparr[$ai][0] = 'username' Then $ausername = $aparr[$ai][1]
										If $aparr[$ai][0] = 'ap_hash' Then $aap_hash = $aparr[$ai][1]
									Next
									If $ShowPrompts = 1 Then MsgBox(0, $Text_Information, 'ID: ' & $aid & @CRLF & 'SSID: ' & $assid & @CRLF & 'BSSID: ' & $amac & @CRLF & 'SecType: ' & $asectype & @CRLF & 'Channel: ' & $achan & @CRLF & 'Authentication: ' & $aauth & @CRLF & 'Encrytion: ' & $aencry & @CRLF & 'Radio Type' & $aradio & @CRLF & 'BTX: ' & $abtx & @CRLF & 'OTX: ' & $aotx & @CRLF & 'Label: ' & $alabel & @CRLF & 'First Seen: ' & $afa & @CRLF & 'Last Seen: ' & $ala & @CRLF & 'Network Type: ' & $ant & @CRLF & 'Manufacturer: ' & $amanuf & @CRLF & 'Geonames ID: ' & $ageonames_id & @CRLF & 'Admin ID:' & $aadmin1_id & @CRLF & 'Admin2 ID: ' & $aadmin2_id & @CRLF & 'Username: ' & $ausername & @CRLF & 'Hash: ' & $aap_hash)
									ConsoleWrite($aid & ' - ' & $assid & ' - ' & $amac & ' - ' & $asectype & ' - ' & $achan & ' - ' & $aauth & ' - ' & $aencry & ' - ' & $aradio & ' - ' & $abtx & ' - ' & $aotx & ' - ' & $alabel & ' - ' & $afa & ' - ' & $ala & ' - ' & $ant & ' - ' & $amanuf & ' - ' & $ageonames_id & ' - ' & $aadmin1_id & ' - ' & $aadmin2_id & ' - ' & $ausername & ' - ' & $aap_hash & @CRLF)
								EndIf
							Next
						Else
							If $ShowPrompts = 1 Then MsgBox(0, $Text_Error, "Unexpected array size from _JSONDecode()" & @CRLF & @CRLF & "-- HTTP Response --" & @CRLF & $httprecv)
						EndIf
					EndIf
				Else
					If $ShowPrompts = 1 Then MsgBox(0, $Text_Error, "_HTTPConnect Error: Unable to open socket - WSAGetLasterror:" & @extended)
					ConsoleWrite("_HTTPConnect Error: Unable to open socket - WSAGetLasterror:" & @extended & @CRLF)
				EndIf
			Else
				If $ShowPrompts = 1 Then MsgBox(0, $Text_Error, "error getting host, path, and port from url """ & $WifiDbApiURL & """")
				ConsoleWrite("error getting host, path, and port from url """ & $WifiDbApiURL & """" & @CRLF)
			EndIf
		EndIf
	Else
		If $ShowPrompts = 1 Then MsgBox(0, $Text_Error, $Text_NoApSelected)
	EndIf
EndFunc   ;==>_LocateAPInWifidb

Func _HTTPPost_WifiDB_LocateAP($host, $page, $socket, $SSID, $mac, $radio, $CHAN, $AUTH, $encry)
	Local $command, $extra_commands
	Local $boundary = "------------" & Chr(Random(Asc("A"), Asc("Z"), 3)) & Chr(Random(Asc("a"), Asc("z"), 3)) & Chr(Random(Asc("A"), Asc("Z"), 3)) & Chr(Random(Asc("a"), Asc("z"), 3)) & Random(1, 9, 1) & Random(1, 9, 1) & Random(1, 9, 1) & Chr(Random(Asc("A"), Asc("Z"), 3)) & Chr(Random(Asc("a"), Asc("z"), 3)) & Chr(Random(Asc("A"), Asc("Z"), 3)) & Chr(Random(Asc("a"), Asc("z"), 3)) & Random(1, 9, 1) & Random(1, 9, 1) & Random(1, 9, 1)

	$extra_commands = "--" & $boundary & @CRLF
	$extra_commands &= "Content-Disposition: form-data; name=""ssid""" & @CRLF & @CRLF
	$extra_commands &= $SSID & @CRLF
	$extra_commands &= "--" & $boundary & @CRLF
	$extra_commands &= "Content-Disposition: form-data; name=""mac""" & @CRLF & @CRLF
	$extra_commands &= $mac & @CRLF
	$extra_commands &= "--" & $boundary & @CRLF
	$extra_commands &= "Content-Disposition: form-data; name=""radio""" & @CRLF & @CRLF
	$extra_commands &= $radio & @CRLF
	$extra_commands &= "--" & $boundary & @CRLF
	$extra_commands &= "Content-Disposition: form-data; name=""chan""" & @CRLF & @CRLF
	$extra_commands &= $CHAN & @CRLF
	$extra_commands &= "--" & $boundary & @CRLF
	$extra_commands &= "Content-Disposition: form-data; name=""auth""" & @CRLF & @CRLF
	$extra_commands &= $AUTH & @CRLF
	$extra_commands &= "--" & $boundary & @CRLF
	$extra_commands &= "Content-Disposition: form-data; name=""encry""" & @CRLF & @CRLF
	$extra_commands &= $encry & @CRLF
	$extra_commands &= "--" & $boundary & "--"

	Dim $datasize = StringLen($extra_commands)

	$command = "POST " & $page & " HTTP/1.1" & @CRLF
	$command &= "Host: " & $host & @CRLF
	$command &= "User-Agent: " & $Script_Name & ' ' & $version & @CRLF
	$command &= "Connection: close" & @CRLF
	$command &= "Content-Type: multipart/form-data; boundary=" & $boundary & @CRLF
	$command &= "Content-Length: " & $datasize & @CRLF & @CRLF
	$command &= $extra_commands
	ConsoleWrite($command & @CRLF)

	Dim $bytessent = TCPSend($socket, $command)

	If $bytessent == 0 Then
		SetExtended(@error)
		SetError(2)
		Return 0
	EndIf

	SetError(0)
	Return $bytessent
EndFunc   ;==>_HTTPPost_WifiDB_LocateAP

Func _ViewWDBWebpage();View wifidb live aps in browser
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_ViewWDBWebpage()') ;#Debug Display
	$url = $WifiDbWdbURL
	Run("RunDll32.exe url.dll,FileProtocolHandler " & $url);open url with rundll 32
EndFunc   ;==>_ViewWDBWebpage

Func _GeoLocateAllAps()
	$OnlyUpdateBlank = InputBox("Geolocate Update Type", "1=Update only blank" & @CRLF & "0=update all aps", 1)
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_GeoLocateAllAps()') ;#Debug Display
	If $OnlyUpdateBlank = 0 Then
		$query = "SELECT ApID, HighGpsHistId FROM AP WHERE HighGpsHistId<>0"
	Else
		$query = "SELECT ApID, HighGpsHistId FROM AP WHERE HighGpsHistId<>0 And CountryCode='' And CountryName='' And AdminCode='' And AdminName='' And Admin2Name='' And AreaName=''"
	EndIf
	$ApMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
	$ApMatch = UBound($ApMatchArray) - 1
	For $ugn = 1 To $ApMatch
		GUICtrlSetData($msgdisplay, 'Updating Geoname information for AP ' & $ugn & "/" & $ApMatch)
		;ConsoleWrite($ugn & "/" & $ApMatch & @CRLF)
		$Ap_ApID = $ApMatchArray[$ugn][1]
		$Ap_HighGpsHist = $ApMatchArray[$ugn][2]
		;ConsoleWrite("APID:" & $Ap_ApID & @CRLF)
		;ConsoleWrite("HighGpsHist:" & $Ap_HighGpsHist & @CRLF)
		$query = "SELECT GpsID FROM Hist WHERE HistID=" & $Ap_HighGpsHist
		$HistMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
		$HistMatch = UBound($ApMatchArray) - 1
		If $HistMatch <> 0 Then
			$Ap_GpsID = $HistMatchArray[1][1]
			;ConsoleWrite("GpsID:" & $Ap_GpsID & @CRLF)
			$query = "SELECT Latitude, Longitude FROM GPS WHERE GPSID=" & $Ap_GpsID
			$GpsMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
			$GpsMatch = UBound($ApMatchArray) - 1
			If $GpsMatch <> 0 Then
				$Ap_Lat = $GpsMatchArray[1][1]
				$Ap_Lon = $GpsMatchArray[1][2]
				$GeoInfo = _GeoLocate($Ap_Lat, $Ap_Lon)
				If Not @error Then
					$GL_CountryCode = $GeoInfo[1]
					$GL_CountryName = $GeoInfo[2]
					$GL_AdminCode = $GeoInfo[3]
					$GL_AdminName = $GeoInfo[4]
					$GL_Admin2Name = $GeoInfo[5]
					$GL_AreaName = $GeoInfo[6]
					$GL_Miles = $GeoInfo[7]
					$GL_km = $GeoInfo[8]
					ConsoleWrite($GL_CountryCode & @CRLF & $GL_CountryName & @CRLF & $GL_AdminCode & @CRLF & $GL_AdminName & @CRLF & $GL_Admin2Name & @CRLF & $GL_AreaName & @CRLF & $GL_Miles & @CRLF & $GL_km & @CRLF)
					$query = "UPDATE AP SET CountryCode='" & $GL_CountryCode & "', CountryName='" & $GL_CountryName & "' , AdminCode='" & $GL_AdminCode & "' , AdminName='" & $GL_AdminName & "' , Admin2Name='" & $GL_Admin2Name & "' , AreaName='" & $GL_AreaName & "' , GNAmiles='" & $GL_Miles & "'  , GNAkm='" & $GL_km & "' WHERE ApID=" & $Ap_ApID
					ConsoleWrite($query & @CRLF)
					_ExecuteMDB($VistumblerDB, $DB_OBJ, $query)
				EndIf
				;ConsoleWrite("---------------------------------------------------" & @CRLF)
			EndIf
		EndIf
	Next
	MsgBox(0, $Text_Information, 'Finished updating geolocations')
	GUICtrlSetData($msgdisplay, '')
EndFunc   ;==>_GeoLocateAllAps

;-------------------------------------------------------------------------------------------------------------------------------
;                                                       REFRESH NETWORK FUNCTION
;-------------------------------------------------------------------------------------------------------------------------------

Func _RefreshNetworks() ;Refresh Wireless networks
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_RefreshNetworks() ') ;#Debug Display
	If $Scan = 1 And $RefreshNetworks = 1 Then
		If TimerDiff($RefreshTimer) >= $RefreshTime Then
			_Wlan_Scan()
			$RefreshTimer = TimerInit()
		EndIf
	EndIf
EndFunc   ;==>_RefreshNetworks

;-------------------------------------------------------------------------------------------------------------------------------
;                                                       HELP FUNCTIONS
;-------------------------------------------------------------------------------------------------------------------------------

Func _OpenVistumblerHome();Opens Vistumbler Website
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_OpenVistumblerHome() ') ;#Debug Display
	Run("RunDll32.exe url.dll,FileProtocolHandler " & 'http://www.vistumbler.net')
EndFunc   ;==>_OpenVistumblerHome

Func _OpenVistumblerForum();Opens Vistumbler Forum
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_OpenVistumblerForum() ') ;#Debug Display
	Run("RunDll32.exe url.dll,FileProtocolHandler " & 'http://forum.vistumbler.net')
EndFunc   ;==>_OpenVistumblerForum

Func _OpenVistumblerWiki();Opens Vistumbler Wiki
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_OpenVistumblerWiki() ') ;#Debug Display
	Run("RunDll32.exe url.dll,FileProtocolHandler " & 'https://github.com/RIEI/Vistumbler/wiki')
EndFunc   ;==>_OpenVistumblerWiki

;-------------------------------------------------------------------------------------------------------------------------------
;                                                       SUPPORT VISTUMBLER FUNCTIONS
;-------------------------------------------------------------------------------------------------------------------------------

Func _OpenVistumblerDonate();Opens Vistumbler Donate
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_OpenVistumblerDonate() ') ;#Debug Display
	Run("RunDll32.exe url.dll,FileProtocolHandler " & 'http://donate.vistumbler.net')
EndFunc   ;==>_OpenVistumblerDonate

Func _OpenVistumblerStore();Opens Vistumbler Store
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_OpenVistumblerStore() ') ;#Debug Display
	Run("RunDll32.exe url.dll,FileProtocolHandler " & 'http://store.vistumbler.net')
EndFunc   ;==>_OpenVistumblerStore
;-------------------------------------------------------------------------------------------------------------------------------
;                                                       COPY GUI FUNCTIONS
;-------------------------------------------------------------------------------------------------------------------------------

Func _CopySelectedAP()
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_CopySelectedAP() ') ;#Debug Display
	$CopySelected = _GUICtrlListView_GetNextItem($ListviewAPs); find what AP is selected in the list. returns -1 is nothing is selected
	_CopyAP_GUI($CopySelected)
EndFunc   ;==>_CopySelectedAP

Func _CopyAP_GUI($SelectedRow)
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_CopyAP_GUI() ') ;#Debug Display
	$query = "SELECT ApID FROM AP WHERE ListRow=" & $SelectedRow
	$ApMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
	$FoundApMatch = UBound($ApMatchArray) - 1
	If $SelectedRow <> -1 And $FoundApMatch <> 0 Then ;If a access point is selected in the listview, map its data
		$CopyAPID = $ApMatchArray[1][1]
		$GUI_COPY = GUICreate($Text_Copy, 491, 249)
		GUISetBkColor($BackgroundColor)
		GUICtrlCreateGroup($Text_SelectWhatToCopy, 8, 8, 473, 201)
		$CopyGUI_Line = GUICtrlCreateCheckbox($Column_Names_Line, 27, 25, 200, 15)
		If $Copy_Line = 1 Then GUICtrlSetState(-1, $GUI_CHECKED)
		$CopyGUI_BSSID = GUICtrlCreateCheckbox($Column_Names_BSSID, 27, 40, 200, 15)
		If $Copy_BSSID = 1 Then GUICtrlSetState(-1, $GUI_CHECKED)
		$CopyGUI_SSID = GUICtrlCreateCheckbox($Column_Names_SSID, 27, 55, 200, 15)
		If $Copy_SSID = 1 Then GUICtrlSetState(-1, $GUI_CHECKED)
		$CopyGUI_CHAN = GUICtrlCreateCheckbox($Column_Names_Channel, 27, 70, 200, 15)
		If $Copy_CHAN = 1 Then GUICtrlSetState(-1, $GUI_CHECKED)
		$CopyGUI_AUTH = GUICtrlCreateCheckbox($Column_Names_Authentication, 27, 85, 200, 15)
		If $Copy_AUTH = 1 Then GUICtrlSetState(-1, $GUI_CHECKED)
		$CopyGUI_ENCR = GUICtrlCreateCheckbox($Column_Names_Encryption, 27, 100, 200, 15)
		If $Copy_ENCR = 1 Then GUICtrlSetState(-1, $GUI_CHECKED)
		$CopyGUI_NETTYPE = GUICtrlCreateCheckbox($Column_Names_NetworkType, 27, 115, 200, 15)
		If $Copy_NETTYPE = 1 Then GUICtrlSetState(-1, $GUI_CHECKED)
		$CopyGUI_RADTYPE = GUICtrlCreateCheckbox($Column_Names_RadioType, 27, 130, 200, 15)
		If $Copy_RADTYPE = 1 Then GUICtrlSetState(-1, $GUI_CHECKED)
		$CopyGUI_SIG = GUICtrlCreateCheckbox($Column_Names_Signal, 27, 145, 200, 15)
		If $Copy_SIG = 1 Then GUICtrlSetState(-1, $GUI_CHECKED)
		$CopyGUI_HIGHSIG = GUICtrlCreateCheckbox($Column_Names_HighSignal, 27, 160, 200, 15)
		If $Copy_HIGHSIG = 1 Then GUICtrlSetState(-1, $GUI_CHECKED)
		$CopyGUI_RSSI = GUICtrlCreateCheckbox($Column_Names_RSSI, 27, 175, 200, 15)
		If $Copy_RSSI = 1 Then GUICtrlSetState(-1, $GUI_CHECKED)
		$CopyGUI_HIGHRSSI = GUICtrlCreateCheckbox($Column_Names_HighRSSI, 27, 190, 200, 15)
		If $Copy_HIGHRSSI = 1 Then GUICtrlSetState(-1, $GUI_CHECKED)
		$CopyGUI_MANU = GUICtrlCreateCheckbox($Column_Names_MANUF, 267, 25, 200, 15)
		If $Copy_MANU = 1 Then GUICtrlSetState(-1, $GUI_CHECKED)
		$CopyGUI_LAB = GUICtrlCreateCheckbox($Column_Names_Label, 267, 40, 200, 15)
		If $Copy_LAB = 1 Then GUICtrlSetState(-1, $GUI_CHECKED)
		$CopyGUI_LAT = GUICtrlCreateCheckbox($Column_Names_Latitude, 267, 55, 200, 15)
		If $Copy_LAT = 1 Then GUICtrlSetState(-1, $GUI_CHECKED)
		$CopyGUI_LON = GUICtrlCreateCheckbox($Column_Names_Longitude, 267, 70, 200, 15)
		If $Copy_LON = 1 Then GUICtrlSetState(-1, $GUI_CHECKED)
		$CopyGUI_LATDMS = GUICtrlCreateCheckbox($Column_Names_LatitudeDMS, 267, 85, 200, 15)
		If $Copy_LATDMS = 1 Then GUICtrlSetState(-1, $GUI_CHECKED)
		$CopyGUI_LONDMS = GUICtrlCreateCheckbox($Column_Names_LongitudeDMS, 267, 100, 200, 15)
		If $Copy_LONDMS = 1 Then GUICtrlSetState(-1, $GUI_CHECKED)
		$CopyGUI_LATDMM = GUICtrlCreateCheckbox($Column_Names_LatitudeDMM, 267, 115, 200, 15)
		If $Copy_LATDMM = 1 Then GUICtrlSetState(-1, $GUI_CHECKED)
		$CopyGUI_LONDMM = GUICtrlCreateCheckbox($Column_Names_LongitudeDMM, 267, 130, 200, 15)
		If $Copy_LONDMM = 1 Then GUICtrlSetState(-1, $GUI_CHECKED)
		$CopyGUI_BTX = GUICtrlCreateCheckbox($Column_Names_BasicTransferRates, 267, 145, 200, 15)
		If $Copy_BTX = 1 Then GUICtrlSetState(-1, $GUI_CHECKED)
		$CopyGUI_OTX = GUICtrlCreateCheckbox($Column_Names_OtherTransferRates, 267, 160, 200, 15)
		If $Copy_OTX = 1 Then GUICtrlSetState(-1, $GUI_CHECKED)
		$CopyGUI_FirstActive = GUICtrlCreateCheckbox($Column_Names_FirstActive, 267, 175, 200, 15)
		If $Copy_FirstActive = 1 Then GUICtrlSetState(-1, $GUI_CHECKED)
		$CopyGUI_LastActive = GUICtrlCreateCheckbox($Column_Names_LastActive, 267, 190, 200, 15)
		If $Copy_LastActive = 1 Then GUICtrlSetState(-1, $GUI_CHECKED)

		$CopyOK = GUICtrlCreateButton($Text_Ok, 142, 216, 100, 25, 0)
		$CopyCancel = GUICtrlCreateButton($Text_Cancel, 256, 216, 100, 25, 0)
		GUISetState(@SW_SHOW)

		GUISetOnEvent($GUI_EVENT_CLOSE, '_CloseCopyGUI')
		GUICtrlSetOnEvent($CopyCancel, '_CloseCopyGUI')
		GUICtrlSetOnEvent($CopyOK, '_CopyOK')
	Else
		MsgBox(0, $Text_Error, $Text_NoApSelected)
	EndIf
EndFunc   ;==>_CopyAP_GUI

Func _CloseCopyGUI()
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_CloseCopyGUI() ') ;#Debug Display
	GUIDelete($GUI_COPY)
EndFunc   ;==>_CloseCopyGUI

Func _CopyOK()
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_CopyOK() ') ;#Debug Display
	$CopyFlag = 1
	Dim $Copy_Line = 0, $Copy_BSSID = 0, $Copy_SSID = 0, $Copy_CHAN = 0, $Copy_AUTH = 0, $Copy_ENCR = 0, $Copy_NETTYPE = 0, $Copy_RADTYPE = 0, $Copy_SIG = 0, $Copy_HIGHSIG = 0, $Copy_RSSI = 0, $Copy_HIGHRSSI = 0, $Copy_MANU = 0, $Copy_LAB = 0, $Copy_LAT = 0, $Copy_LON = 0, $Copy_LATDMS = 0, $Copy_LONDMS = 0, $Copy_LATDMM = 0, $Copy_LONDMM = 0, $Copy_BTX = 0, $Copy_OTX = 0, $Copy_FirstActive = 0, $Copy_LastActive = 0
	If GUICtrlRead($CopyGUI_Line) = 1 Then $Copy_Line = 1
	If GUICtrlRead($CopyGUI_BSSID) = 1 Then $Copy_BSSID = 1
	If GUICtrlRead($CopyGUI_SSID) = 1 Then $Copy_SSID = 1
	If GUICtrlRead($CopyGUI_CHAN) = 1 Then $Copy_CHAN = 1
	If GUICtrlRead($CopyGUI_AUTH) = 1 Then $Copy_AUTH = 1
	If GUICtrlRead($CopyGUI_ENCR) = 1 Then $Copy_ENCR = 1
	If GUICtrlRead($CopyGUI_NETTYPE) = 1 Then $Copy_NETTYPE = 1
	If GUICtrlRead($CopyGUI_RADTYPE) = 1 Then $Copy_RADTYPE = 1
	If GUICtrlRead($CopyGUI_SIG) = 1 Then $Copy_SIG = 1
	If GUICtrlRead($CopyGUI_HIGHSIG) = 1 Then $Copy_HIGHSIG = 1
	If GUICtrlRead($CopyGUI_RSSI) = 1 Then $Copy_RSSI = 1
	If GUICtrlRead($CopyGUI_HIGHRSSI) = 1 Then $Copy_HIGHRSSI = 1
	If GUICtrlRead($CopyGUI_MANU) = 1 Then $Copy_MANU = 1
	If GUICtrlRead($CopyGUI_LAB) = 1 Then $Copy_LAB = 1
	If GUICtrlRead($CopyGUI_LAT) = 1 Then $Copy_LAT = 1
	If GUICtrlRead($CopyGUI_LON) = 1 Then $Copy_LON = 1
	If GUICtrlRead($CopyGUI_LATDMS) = 1 Then $Copy_LATDMS = 1
	If GUICtrlRead($CopyGUI_LONDMS) = 1 Then $Copy_LONDMS = 1
	If GUICtrlRead($CopyGUI_LATDMM) = 1 Then $Copy_LATDMM = 1
	If GUICtrlRead($CopyGUI_LONDMM) = 1 Then $Copy_LONDMM = 1
	If GUICtrlRead($CopyGUI_BTX) = 1 Then $Copy_BTX = 1
	If GUICtrlRead($CopyGUI_OTX) = 1 Then $Copy_OTX = 1
	If GUICtrlRead($CopyGUI_FirstActive) = 1 Then $Copy_FirstActive = 1
	If GUICtrlRead($CopyGUI_LastActive) = 1 Then $Copy_LastActive = 1
	_CloseCopyGUI()
EndFunc   ;==>_CopyOK

Func _CopySetClipboard()
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_CopySetClipboard() ') ;#Debug Display
	$query = "SELECT ApID, BSSID, SSID, CHAN, AUTH, ENCR, NETTYPE, RADTYPE, HighSignal, HighRSSI, MANU, LABEL, HighGpsHistID, BTX, OTX, FirstHistID, LastHistID FROM AP WHERE ApID=" & $CopyAPID
	$ApMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
	$FoundApMatch = UBound($ApMatchArray) - 1
	If $FoundApMatch <> 0 Then
		$CopyText = ''
		If $Copy_Line = 1 Then
			$CopyText = Round($ApMatchArray[1][1])
		EndIf
		If $Copy_BSSID = 1 Then
			If $CopyText = '' Then
				$CopyText = $ApMatchArray[1][2]
			Else
				$CopyText &= '|' & $ApMatchArray[1][2]
			EndIf
		EndIf
		If $Copy_SSID = 1 Then
			If $CopyText = '' Then
				$CopyText = $ApMatchArray[1][3]
			Else
				$CopyText &= '|' & $ApMatchArray[1][3]
			EndIf
		EndIf
		If $Copy_CHAN = 1 Then
			If $CopyText = '' Then
				$CopyText = Round($ApMatchArray[1][4])
			Else
				$CopyText &= '|' & Round($ApMatchArray[1][4])
			EndIf
		EndIf
		If $Copy_AUTH = 1 Then
			If $CopyText = '' Then
				$CopyText = $ApMatchArray[1][5]
			Else
				$CopyText &= '|' & $ApMatchArray[1][5]
			EndIf
		EndIf
		If $Copy_ENCR = 1 Then
			If $CopyText = '' Then
				$CopyText = $ApMatchArray[1][6]
			Else
				$CopyText &= '|' & $ApMatchArray[1][6]
			EndIf
		EndIf
		If $Copy_NETTYPE = 1 Then
			If $CopyText = '' Then
				$CopyText = $ApMatchArray[1][7]
			Else
				$CopyText &= '|' & $ApMatchArray[1][7]
			EndIf
		EndIf
		If $Copy_RADTYPE = 1 Then
			If $CopyText = '' Then
				$CopyText = $ApMatchArray[1][8]
			Else
				$CopyText &= '|' & $ApMatchArray[1][8]
			EndIf
		EndIf
		If $Copy_SIG = 1 Then
			$LastHistID = $ApMatchArray[1][17] - 0
			$query = "SELECT Signal FROM Hist Where HistID=" & $LastHistID
			$HistMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
			$ExpSig = $HistMatchArray[1][1]
			If $CopyText = '' Then
				$CopyText = $ExpSig
			Else
				$CopyText &= '|' & $ExpSig
			EndIf
		EndIf
		If $Copy_HIGHSIG = 1 Then
			If $CopyText = '' Then
				$CopyText = $ApMatchArray[1][9]
			Else
				$CopyText &= '|' & $ApMatchArray[1][9]
			EndIf
		EndIf
		If $Copy_RSSI = 1 Then
			$LastHistID = $ApMatchArray[1][17] - 0
			$query = "SELECT RSSI FROM Hist Where HistID=" & $LastHistID
			$HistMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
			$ExpRSSI = $HistMatchArray[1][1]
			If $CopyText = '' Then
				$CopyText = $ExpRSSI
			Else
				$CopyText &= '|' & $ExpRSSI
			EndIf
		EndIf
		If $Copy_HIGHRSSI = 1 Then
			If $CopyText = '' Then
				$CopyText = $ApMatchArray[1][10]
			Else
				$CopyText &= '|' & $ApMatchArray[1][10]
			EndIf
		EndIf
		If $Copy_MANU = 1 Then
			If $CopyText = '' Then
				$CopyText = $ApMatchArray[1][11]
			Else
				$CopyText &= '|' & $ApMatchArray[1][11]
			EndIf
		EndIf
		If $Copy_LAB = 1 Then
			If $CopyText = '' Then
				$CopyText = $ApMatchArray[1][12]
			Else
				$CopyText &= '|' & $ApMatchArray[1][12]
			EndIf
		EndIf
		If $Copy_LAT = 1 Or $Copy_LON = 1 Or $Copy_LATDMS = 1 Or $Copy_LONDMS = 1 Or $Copy_LATDMM = 1 Or $Copy_LONDMM = 1 Then
			$HighGpsHistID = $ApMatchArray[1][13] - 0
			If $HighGpsHistID = 0 Then
				$CopyLat = 'N 0000.0000'
				$CopyLon = 'E 0000.0000'
			Else
				$query = "SELECT GpsId FROM Hist Where HistID=" & $HighGpsHistID
				$HistMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
				$ExpGID = $HistMatchArray[1][1]
				$query = "SELECT Latitude, Longitude FROM GPS WHERE GpsId=" & $ExpGID
				$GpsMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
				$CopyLat = $GpsMatchArray[1][1]
				$CopyLon = $GpsMatchArray[1][2]
			EndIf
			If $Copy_LAT = 1 Then
				If $CopyText = '' Then
					$CopyText = _Format_GPS_DMM_to_DDD($CopyLat)
				Else
					$CopyText &= '|' & _Format_GPS_DMM_to_DDD($CopyLat)
				EndIf
			EndIf
			If $Copy_LON = 1 Then
				If $CopyText = '' Then
					$CopyText = _Format_GPS_DMM_to_DDD($CopyLon)
				Else
					$CopyText &= '|' & _Format_GPS_DMM_to_DDD($CopyLon)
				EndIf
			EndIf
			If $Copy_LATDMS = 1 Then
				If $CopyText = '' Then
					$CopyText = _Format_GPS_DMM_to_DMS($CopyLat)
				Else
					$CopyText &= '|' & _Format_GPS_DMM_to_DMS($CopyLat)
				EndIf
			EndIf
			If $Copy_LONDMS = 1 Then
				If $CopyText = '' Then
					$CopyText = _Format_GPS_DMM_to_DMS($CopyLon)
				Else
					$CopyText &= '|' & _Format_GPS_DMM_to_DMS($CopyLon)
				EndIf
			EndIf
			If $Copy_LATDMM = 1 Then
				If $CopyText = '' Then
					$CopyText = $CopyLat
				Else
					$CopyText &= '|' & $CopyLat
				EndIf
			EndIf
			If $Copy_LONDMM = 1 Then
				If $CopyText = '' Then
					$CopyText = $CopyLon
				Else
					$CopyText &= '|' & $CopyLon
				EndIf
			EndIf
		EndIf
		If $Copy_BTX = 1 Then
			If $CopyText = '' Then
				$CopyText = $ApMatchArray[1][14]
			Else
				$CopyText &= '|' & $ApMatchArray[1][14]
			EndIf
		EndIf
		If $Copy_OTX = 1 Then
			If $CopyText = '' Then
				$CopyText = $ApMatchArray[1][13]
			Else
				$CopyText &= '|' & $ApMatchArray[1][15]
			EndIf
		EndIf
		If $Copy_FirstActive = 1 Then
			$FirstHistID = $ApMatchArray[1][16]
			$query = "SELECT GpsID FROM Hist Where HistID=" & $FirstHistID
			$HistMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
			$ExpGID = $HistMatchArray[1][1]
			$query = "SELECT Date1, Time1 FROM Gps Where GpsID=" & $ExpGID
			$GpsMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
			$ExpDate = $GpsMatchArray[1][1]
			$ExpTime = $GpsMatchArray[1][2]
			If $CopyText = '' Then
				$CopyText = $ExpDate & ' ' & $ExpTime
			Else
				$CopyText &= '|' & $ExpDate & ' ' & $ExpTime
			EndIf
		EndIf
		If $Copy_LastActive = 1 Then
			$LastHistID = $ApMatchArray[1][17]
			$query = "SELECT GpsID FROM Hist Where HistID=" & $LastHistID
			$HistMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
			$ExpGID = $HistMatchArray[1][1]
			$query = "SELECT Date1, Time1 FROM Gps Where GpsID=" & $ExpGID
			$GpsMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
			$ExpDate = $GpsMatchArray[1][1]
			$ExpTime = $GpsMatchArray[1][2]
			If $CopyText = '' Then
				$CopyText = $ExpDate & ' ' & $ExpTime
			Else
				$CopyText &= '|' & $ExpDate & ' ' & $ExpTime
			EndIf
		EndIf
		;ConsoleWrite($CopyText & @CRLF)
		ClipPut($CopyText)
	EndIf
	$CopyFlag = 0
EndFunc   ;==>_CopySetClipboard

;-------------------------------------------------------------------------------------------------------------------------------
;                                                       VISTUMBLER SAVE FUNCTIONS
;-------------------------------------------------------------------------------------------------------------------------------

Func _OpenSaveFolder();Opens save folder in explorer
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_OpenSaveFolder() ') ;#Debug Display
	Run('RunDll32.exe url.dll,FileProtocolHandler "' & $SaveDir & '"')
EndFunc   ;==>_OpenSaveFolder

Func _AutoRecoveryVS1();Autosaves data to a file name based on current time
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_AutoRecoveryVS1()') ;#Debug Display
	DirCreate($SaveDirAuto)
	FileDelete($AutoRecoveryVS1File)
	$AutoRecoveryVS1File = $SaveDirAuto & $ldatetimestamp & '_AutoRecovery' & '.VS1'
	If ProcessExists($AutoRecoveryVS1Process) = 0 Then
		$AutoRecoveryVS1Process = Run(@ComSpec & " /C " & FileGetShortName(@ScriptDir & '\Export.exe') & ' /db="' & $VistumblerDB & '" /t=d /f="' & $AutoRecoveryVS1File & '"', '', @SW_HIDE)
		$save_timer = TimerInit()
	EndIf
EndFunc   ;==>_AutoRecoveryVS1

Func _AutoSaveAndClear();Autosaves data to a file name based on current time
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_AutoSaveAndClear()') ;#Debug Display
	$AutoSaveAndClearFile = $SaveDirAuto & $ldatetimestamp & '_AutoSave' & '.VS1'
	If $AutoSaveAndClearPlaySound = 1 Then _PlayWavSound($SoundDir & $AutoSave_sound)
	GUICtrlSetData($msgdisplay, "Running Auto Save and Clear")
	$expvs1 = _ExportVS1($AutoSaveAndClearFile, 0)
	If $expvs1 = 1 Then
		GUICtrlSetData($msgdisplay, "File Exported Successfully. Clearing List")
		_ClearAll()
	Else
		GUICtrlSetData($msgdisplay, "Error Saving File. List will not be cleared.")
	EndIf
	$autosave_timer = TimerInit()
EndFunc   ;==>_AutoSaveAndClear

Func _ExportDetailedData();Saves data to a selected file
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_ExportDetailedData() ') ;#Debug Display
	_ExportDetailedDataGui(0)
EndFunc   ;==>_ExportDetailedData

Func _ExportFilteredDetailedData();Saves filtered data to a selected file
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_ExportFilteredDetailedData() ') ;#Debug Display
	_ExportDetailedDataGui(1)
EndFunc   ;==>_ExportFilteredDetailedData

Func _ExportDetailedDataGui($Filter = 0);Save VS1 GUI
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_ExportDetailedDataGui()') ;#Debug Display
	DirCreate($SaveDir)
	$filename = FileSaveDialog($Text_SaveAsTXT, $SaveDir, $Text_VistumblerFile & ' (*.VS1)', '', $ldatetimestamp & '.VS1')
	If @error <> 1 Then
		If StringInStr($filename, '.VS1') = 0 Then $filename = $filename & '.VS1'
		$saved = _ExportVS1($filename, $Filter)
		If $saved = 1 Then
			MsgBox(0, $Text_Done, $Text_SavedAs & ': "' & $filename & '"')
		Else
			MsgBox(0, $Text_Error, $Text_NoAps & ' ' & $Text_NoFileSaved)
		EndIf
		GUICtrlSetData($msgdisplay, '')
		$newdata = 0
	EndIf
EndFunc   ;==>_ExportDetailedDataGui

Func _ExportVS1($savefile, $Filter = 0);writes vistumbler detailed data to a txt file
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_ExportDetailedTXT()') ;#Debug Display
	$file = "# Vistumbler VS1 - Detailed Export Version 4.0" & @CRLF & _
			"# Created By: " & $Script_Name & ' ' & $version & @CRLF & _
			"# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------" & @CRLF & _
			"# GpsID|Latitude|Longitude|NumOfSatalites|HorizontalDilutionOfPrecision|Altitude(m)|HeightOfGeoidAboveWGS84Ellipsoid(m)|Speed(km/h)|Speed(MPH)|TrackAngle(Deg)|Date(UTC y-m-d)|Time(UTC h:m:s.ms)" & @CRLF & _
			"# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------" & @CRLF
	;Export GPS IDs
	$query = "SELECT GpsID, Latitude, Longitude, NumOfSats, HorDilPitch, Alt, Geo, SpeedInMPH, SpeedInKmH, TrackAngle, Date1, Time1 FROM GPS ORDER BY Date1, Time1"
	$GpsMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
	$FoundGpsMatch = UBound($GpsMatchArray) - 1
	For $exp = 1 To $FoundGpsMatch
		GUICtrlSetData($msgdisplay, $Text_SavingGID & ' ' & $exp & ' / ' & $FoundGpsMatch)
		$ExpGID = $GpsMatchArray[$exp][1]
		$ExpLat = $GpsMatchArray[$exp][2]
		$ExpLon = $GpsMatchArray[$exp][3]
		$ExpSat = $GpsMatchArray[$exp][4]
		$ExpHorDilPitch = $GpsMatchArray[$exp][5]
		$ExpAlt = $GpsMatchArray[$exp][6]
		$ExpGeo = $GpsMatchArray[$exp][7]
		$ExpSpeedMPH = $GpsMatchArray[$exp][8]
		$ExpSpeedKmh = $GpsMatchArray[$exp][9]
		$ExpTrack = $GpsMatchArray[$exp][10]
		$ExpDate = $GpsMatchArray[$exp][11]
		$ExpTime = $GpsMatchArray[$exp][12]
		$file &= $ExpGID & '|' & $ExpLat & '|' & $ExpLon & '|' & $ExpSat & '|' & $ExpHorDilPitch & '|' & $ExpAlt & '|' & $ExpGeo & '|' & $ExpSpeedKmh & '|' & $ExpSpeedMPH & '|' & $ExpTrack & '|' & $ExpDate & '|' & $ExpTime & @CRLF
	Next

	;Export AP Information
	$file &= "# ---------------------------------------------------------------------------------------------------------------------------------------------------------" & @CRLF & _
			"# SSID|BSSID|MANUFACTURER|Authentication|Encryption|Security Type|Radio Type|Channel|Basic Transfer Rates|Other Transfer Rates|High Signal|High RSSI|Network Type|Label|GID,SIGNAL,RSSI" & @CRLF & _
			"# ---------------------------------------------------------------------------------------------------------------------------------------------------------" & @CRLF
	If $Filter = 1 Then
		$query = $AddQuery
	Else
		$query = "SELECT ApID, SSID, BSSID, NETTYPE, RADTYPE, CHAN, AUTH, ENCR, SecType, BTX, OTX, HighSignal, HighRSSI, MANU, LABEL, HighGpsHistID, FirstHistID, LastHistID FROM AP"
	EndIf
	$ApMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
	$FoundApMatch = UBound($ApMatchArray) - 1
	If $FoundApMatch > 0 Then
		For $exp = 1 To $FoundApMatch
			GUICtrlSetData($msgdisplay, $Text_SavingLine & ' ' & $exp & ' / ' & $FoundApMatch)
			$ExpApID = $ApMatchArray[$exp][1]
			$ExpSSID = $ApMatchArray[$exp][2]
			$ExpBSSID = $ApMatchArray[$exp][3]
			$ExpNET = $ApMatchArray[$exp][4]
			$ExpRAD = $ApMatchArray[$exp][5]
			$ExpCHAN = $ApMatchArray[$exp][6]
			$ExpAUTH = $ApMatchArray[$exp][7]
			$ExpENCR = $ApMatchArray[$exp][8]
			$ExpSECTYPE = $ApMatchArray[$exp][9]
			$ExpBTX = $ApMatchArray[$exp][10]
			$ExpOTX = $ApMatchArray[$exp][11]
			$ExpHighSig = $ApMatchArray[$exp][12]
			$ExpHighRSSI = $ApMatchArray[$exp][13]
			$ExpMANU = $ApMatchArray[$exp][14]
			$ExpLAB = $ApMatchArray[$exp][15]
			$ExpHighGpsID = $ApMatchArray[$exp][16]
			$ExpFirstID = $ApMatchArray[$exp][17]
			$ExpLastID = $ApMatchArray[$exp][18]

			;Create GID,SIG String
			$ExpGidSid = ''
			$query = "SELECT GpsID, Signal, RSSI FROM Hist WHERE ApID=" & $ExpApID
			$HistMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
			$FoundHistMatch = UBound($HistMatchArray) - 1
			For $epgs = 1 To $FoundHistMatch
				$ExpGID = $HistMatchArray[$epgs][1]
				$ExpSig = $HistMatchArray[$epgs][2]
				$ExpRSSI = $HistMatchArray[$epgs][3]
				If $epgs = 1 Then
					$ExpGidSid = $ExpGID & ',' & $ExpSig & ',' & $ExpRSSI
				Else
					$ExpGidSid &= '\' & $ExpGID & ',' & $ExpSig & ',' & $ExpRSSI
				EndIf
			Next

			$file &= $ExpSSID & '|' & $ExpBSSID & '|' & $ExpMANU & '|' & $ExpAUTH & '|' & $ExpENCR & '|' & $ExpSECTYPE & '|' & $ExpRAD & '|' & $ExpCHAN & '|' & $ExpBTX & '|' & $ExpOTX & '|' & $ExpHighSig & '|' & $ExpHighRSSI & '|' & $ExpNET & '|' & $ExpLAB & '|' & $ExpGidSid & @CRLF
		Next
		$savefile = FileOpen($savefile, 128 + 2);Open in UTF-8 write mode
		FileWrite($savefile, $file)
		FileClose($savefile)
		Return (1)
	Else
		Return (0)
	EndIf
EndFunc   ;==>_ExportVS1

Func _ExportVszData()
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_ExportVszData()') ;#Debug Display
	$file = FileSaveDialog($Text_SaveAsVSZ, $SaveDir, $Text_VistumblerFile & ' (*.VSZ)', '', $ldatetimestamp & '.VSZ')
	If @error <> 1 Then _ExportVSZ($file, 0)
EndFunc   ;==>_ExportVszData

Func _ExportVszFilteredData()
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_ExportVszFilteredData()') ;#Debug Display
	$file = FileSaveDialog($Text_SaveAsVSZ & ' ' & $Text_Filtered, $SaveDir, $Text_VistumblerFile & ' (*.VSZ)', '', $ldatetimestamp & '.VSZ')
	If @error <> 1 Then _ExportVSZ($file, 1)
EndFunc   ;==>_ExportVszFilteredData

Func _ExportVSZ($savefile, $Filter = 0)
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_ExportVSZ()') ;#Debug Display
	If StringInStr($savefile, '.VSZ') = 0 Then $savefile = $savefile & '.VSZ'
	$vsz_temp_file = $TmpDir & 'data.zip'
	$vsz_file = $savefile
	$vs1_file = $TmpDir & 'data.vs1'
	If FileExists($vsz_temp_file) Then FileDelete($vsz_temp_file)
	If FileExists($vsz_file) Then FileDelete($vsz_file)
	If FileExists($vs1_file) Then FileDelete($vs1_file)
	$vs1tmpcreated = _ExportVS1($vs1_file, $Filter)
	If $vs1tmpcreated = 1 Then
		_Zip_Create($vsz_temp_file)
		_Zip_AddItem($vsz_temp_file, $vs1_file)
		FileMove($vsz_temp_file, $vsz_file)
		FileDelete($vs1_file)
		If FileExists($savefile) Then Return (1)
	EndIf
	Return (0)
EndFunc   ;==>_ExportVSZ

Func _ExportCsvData();Saves data to a selected file
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_ExportCsvData()') ;#Debug Display
	_ExportCsvDataGui(0)
EndFunc   ;==>_ExportCsvData

Func _ExportCsvFilteredData();Saves data to a selected file
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_ExportCsvFilteredData()') ;#Debug Display
	_ExportCsvDataGui(1)
EndFunc   ;==>_ExportCsvFilteredData

Func _ExportCsvDataGui($Gui_CsvFilter = 0);Saves data to a selected file
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_ExportCsvDataGui()') ;#Debug Display
	$Gui_Csv = GUICreate($Text_ExportToCSV, 543, 132)
	GUISetBkColor($BackgroundColor)
	$Gui_CsvFile = GUICtrlCreateInput($SaveDir & $ldatetimestamp & '.csv', 20, 20, 409, 21)
	$GUI_CsvSaveAs = GUICtrlCreateButton($Text_Browse, 440, 20, 81, 22, $WS_GROUP)
	$Gui_CsvRadDetailed = GUICtrlCreateRadio($Text_DetailedCsvFile, 20, 50, 250, 20)
	GUICtrlSetState($Gui_CsvRadDetailed, $GUI_CHECKED)
	$Gui_CsvRadSummary = GUICtrlCreateRadio($Text_SummaryCsvFile, 20, 70, 250, 20)
	$Gui_CsvFiltered = GUICtrlCreateCheckbox($Text_Filtered, 300, 50, 250, 20)
	If $Gui_CsvFilter = 1 Then GUICtrlSetState($Gui_CsvFiltered, $GUI_CHECKED)
	$Gui_CsvOk = GUICtrlCreateButton($Text_Ok, 128, 95, 97, 25, $WS_GROUP)
	$Gui_CsvCancel = GUICtrlCreateButton($Text_Cancel, 290, 95, 97, 25, $WS_GROUP)
	GUISetState(@SW_SHOW)
	GUICtrlSetOnEvent($GUI_CsvSaveAs, "_ExportCsvDataGui_SaveAs")
	GUICtrlSetOnEvent($Gui_CsvOk, "_ExportCsvDataGui_Ok")
	GUICtrlSetOnEvent($Gui_CsvCancel, "_ExportCsvDataGui_Close")
	GUISetOnEvent($GUI_EVENT_CLOSE, '_ExportCsvDataGui_Close')
EndFunc   ;==>_ExportCsvDataGui

Func _ExportCsvDataGui_Ok()
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_ExportCsvDataGui_Ok()') ;#Debug Display
	$filename = GUICtrlRead($Gui_CsvFile)
	If GUICtrlRead($Gui_CsvRadSummary) = 1 Then
		$CsvDetailed = 0
	Else
		$CsvDetailed = 1
	EndIf
	If GUICtrlRead($Gui_CsvFiltered) = 1 Then
		$CsvFiltered = 1
	Else
		$CsvFiltered = 0
	EndIf
	_ExportCsvDataGui_Close()

	If StringInStr($filename, '.csv') = 0 Then $filename = $filename & '.csv'
	$saved = _ExportToCSV($filename, $CsvFiltered, $CsvDetailed)
	If $saved = 1 Then
		MsgBox(0, $Text_Done, $Text_SavedAs & ': "' & $filename & '"')
	Else
		MsgBox(0, $Text_Error, $Text_NoAps & ' ' & $Text_NoFileSaved)
	EndIf
	GUICtrlSetData($msgdisplay, '')
	$newdata = 0
EndFunc   ;==>_ExportCsvDataGui_Ok

Func _ExportCsvDataGui_SaveAs()
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_ExportCsvDataGui_SaveAs()') ;#Debug Display
	$filename = FileSaveDialog($Text_SaveAsTXT, $SaveDir, 'CSV (*.csv)', '', GUICtrlRead($Gui_CsvFile))
	If @error <> 1 Then GUICtrlSetData($Gui_CsvFile, $filename)
EndFunc   ;==>_ExportCsvDataGui_SaveAs

Func _ExportCsvDataGui_Close()
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_ExportCsvDataGui_Close()') ;#Debug Display
	GUIDelete($Gui_Csv)
EndFunc   ;==>_ExportCsvDataGui_Close

Func _ExportToCSV($savefile, $Filter = 0, $Detailed = 0);writes vistumbler data to a csv file
	ConsoleWrite("$Filter:" & $Filter & ' - $Detailed:' & $Detailed & @CRLF)
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_ExportToCSV()') ;#Debug Display
	If $Filter = 1 Then
		$query = $AddQuery
	Else
		$query = "SELECT ApID, SSID, BSSID, NETTYPE, RADTYPE, CHAN, AUTH, ENCR, SecType, BTX, OTX, HighSignal, HighRSSI, MANU, LABEL, HighGpsHistID, FirstHistID, LastHistID, LastGpsID, Active FROM AP"
	EndIf
	If $Detailed = 0 Then
		$file = "SSID,BSSID,MANUFACTURER,HIGHEST SIGNAL W/GPS,AUTHENTICATION,ENCRYPTION,RADIO TYPE,CHANNEL,LATITUDE,LONGITUDE,BTX,OTX,FIRST SEEN(UTC),LAST SEEN(UTC),NETWORK TYPE,LABEL, HIGHEST SIGNAL, HIGHEST RSSI" & @CRLF
	ElseIf $Detailed = 1 Then
		$file = "SSID,BSSID,MANUFACTURER,SIGNAL,High Signal,RSSI,High RSSI,AUTHENTICATION,ENCRYPTION,RADIO TYPE,CHANNEL,BTX,OTX,NETWORK TYPE,LABEL,LATITUDE,LONGITUDE,SATELLITES,HDOP,ALTITUDE,HEIGHT OF GEOID,SPEED(km/h),SPEED(MPH),TRACK ANGLE,DATE(UTC),TIME(UTC)" & @CRLF
	EndIf
	$ApMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
	$FoundApMatch = UBound($ApMatchArray) - 1
	If $FoundApMatch > 0 Then
		For $exp = 1 To $FoundApMatch
			GUICtrlSetData($msgdisplay, $Text_SavingLine & ' ' & $exp & ' / ' & $FoundApMatch)
			$ExpApID = $ApMatchArray[$exp][1]
			$ExpSSID = $ApMatchArray[$exp][2]
			$ExpBSSID = $ApMatchArray[$exp][3]
			$ExpNET = $ApMatchArray[$exp][4]
			$ExpRAD = $ApMatchArray[$exp][5]
			$ExpCHAN = $ApMatchArray[$exp][6]
			$ExpAUTH = $ApMatchArray[$exp][7]
			$ExpENCR = $ApMatchArray[$exp][8]
			$ExpSECTYPE = $ApMatchArray[$exp][9]
			$ExpBTX = $ApMatchArray[$exp][10]
			$ExpOTX = $ApMatchArray[$exp][11]
			$ExpHighSig = $ApMatchArray[$exp][12]
			$ExpHighRSSI = $ApMatchArray[$exp][13]
			$ExpMANU = $ApMatchArray[$exp][14]
			$ExpLAB = $ApMatchArray[$exp][15]
			$ExpHighGpsID = $ApMatchArray[$exp][16]
			$ExpFirstID = $ApMatchArray[$exp][17]
			$ExpLastID = $ApMatchArray[$exp][18]

			If $Detailed = 0 Then
				;Get High GPS Signal
				If $ExpHighGpsID = 0 Then
					$ExpHighGpsSig = 0
					$ExpHighGpsLat = 'N 0000.0000'
					$ExpHighGpsLon = 'E 0000.0000'
				Else
					$query = "SELECT Signal, GpsID FROM Hist WHERE HistID=" & $ExpHighGpsID
					$HistMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
					$ExpHighGpsSig = $HistMatchArray[1][1]
					$ExpHighGpsID = $HistMatchArray[1][2]
					$query = "SELECT Latitude, Longitude FROM GPS WHERE GpsID=" & $ExpHighGpsID
					$GpsMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
					$ExpHighGpsLat = $GpsMatchArray[1][1]
					$ExpHighGpsLon = $GpsMatchArray[1][2]
				EndIf
				;Get First Found Time From FirstHistID
				$query = "SELECT GpsID FROM Hist WHERE HistID=" & $ExpFirstID
				$HistMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
				$ExpFirstGpsId = $HistMatchArray[1][1]
				$query = "SELECT Date1, Time1 FROM GPS WHERE GpsID=" & $ExpFirstGpsId
				$GpsMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
				$FirstDateTime = $GpsMatchArray[1][1] & ' ' & $GpsMatchArray[1][2]
				;Get Last Found Time From LastHistID
				$query = "SELECT GpsID FROM Hist WHERE HistID=" & $ExpLastID
				$HistMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
				$ExpLastGpsID = $HistMatchArray[1][1]
				$query = "SELECT Date1, Time1 FROM GPS WHERE GpsID=" & $ExpLastGpsID
				$GpsMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
				$LastDateTime = $GpsMatchArray[1][1] & ' ' & $GpsMatchArray[1][2]
				;Write summary csv line
				$file &= StringReplace($ExpSSID, ',', '') & ',' & $ExpBSSID & ',' & StringReplace($ExpMANU, ',', '') & ',' & $ExpHighGpsSig & ',' & $ExpAUTH & ',' & $ExpENCR & ',' & $ExpRAD & ',' & $ExpCHAN & ',' & StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($ExpHighGpsLat), 'S', '-'), 'N', ''), ' ', '') & ',' & StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($ExpHighGpsLon), 'W', '-'), 'E', ''), ' ', '') & ',' & $ExpBTX & ',' & $ExpOTX & ',' & $FirstDateTime & ',' & $LastDateTime & ',' & $ExpNET & ',' & StringReplace($ExpLAB, ',', '') & ',' & $ExpHighSig & ',' & $ExpHighRSSI & @CRLF
			ElseIf $Detailed = 1 Then
				;Get All Signals and GpsIDs for current ApID
				$query = "SELECT GpsID, Signal, RSSI FROM Hist WHERE ApID=" & $ExpApID & " And Signal<>0 ORDER BY Date1, Time1"
				$HistMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
				$FoundHistMatch = UBound($HistMatchArray) - 1
				For $exph = 1 To $FoundHistMatch
					$ExpGID = $HistMatchArray[$exph][1]
					$ExpSig = $HistMatchArray[$exph][2]
					$ExpRSSI = $HistMatchArray[$exph][3]
					;Get GPS Data Based on GpsID
					$query = "SELECT Latitude, Longitude, NumOfSats, HorDilPitch, Alt, Geo, SpeedInMPH, SpeedInKmH, TrackAngle, Date1, Time1 FROM GPS WHERE GpsID=" & $ExpGID
					$GpsMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
					$ExpLat = StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($GpsMatchArray[1][1]), 'S', '-'), 'N', ''), ' ', '')
					$ExpLon = StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($GpsMatchArray[1][2]), 'W', '-'), 'E', ''), ' ', '')
					$ExpSat = $GpsMatchArray[1][3]
					$ExpHorDilPitch = $GpsMatchArray[1][4]
					$ExpAlt = $GpsMatchArray[1][5]
					$ExpGeo = $GpsMatchArray[1][6]
					$ExpSpeedMPH = $GpsMatchArray[1][7]
					$ExpSpeedKmh = $GpsMatchArray[1][8]
					$ExpTrack = $GpsMatchArray[1][9]
					$ExpDate = $GpsMatchArray[1][10]
					$ExpTime = $GpsMatchArray[1][11]
					;Write detailed csv line
					$file &= '"' & $ExpSSID & '",' & $ExpBSSID & ',"' & $ExpMANU & '",' & $ExpSig & ',' & $ExpHighSig & ',' & $ExpRSSI & ',' & $ExpHighRSSI & ',' & $ExpAUTH & ',' & $ExpENCR & ',' & $ExpRAD & ',' & $ExpCHAN & ',"' & $ExpBTX & '","' & $ExpOTX & '",' & $ExpNET & ',"' & $ExpLAB & '",' & $ExpLat & ',' & $ExpLon & ',' & $ExpSat & ',' & $ExpHorDilPitch & ',' & $ExpAlt & ',' & $ExpGeo & ',' & $ExpSpeedKmh & ',' & $ExpSpeedMPH & ',' & $ExpTrack & ',' & $ExpDate & ',' & $ExpTime & @CRLF
				Next
			EndIf
		Next
		$savefile = FileOpen($savefile, 128 + 2);Open in UTF-8 write mode
		FileWrite($savefile, $file)
		FileClose($savefile)
		Return (1)
	Else
		Return (0)
	EndIf
EndFunc   ;==>_ExportToCSV

Func _SaveToGPX()
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_SaveToGPX()') ;#Debug Display
	Opt("GUIOnEventMode", 0)
	$ExportGPXGUI = GUICreate($Text_ExportToGPX, 263, 143)
	GUISetBkColor($BackgroundColor)
	$GUI_ExportGPX_MapOpen = GUICtrlCreateCheckbox($Text_MapOpenNetworks, 15, 15, 240, 15)
	If $MapOpen = 1 Then GUICtrlSetState($GUI_ExportGPX_MapOpen, $GUI_CHECKED)
	$GUI_ExportGPX_MapWEP = GUICtrlCreateCheckbox($Text_MapWepNetworks, 15, 35, 240, 15)
	If $MapWEP = 1 Then GUICtrlSetState($GUI_ExportGPX_MapWEP, $GUI_CHECKED)
	$GUI_ExportGPX_MapSec = GUICtrlCreateCheckbox($Text_MapSecureNetworks, 15, 55, 240, 15)
	If $MapSec = 1 Then GUICtrlSetState($GUI_ExportGPX_MapSec, $GUI_CHECKED)
	$GUI_ExportGPX_DrawTrack = GUICtrlCreateCheckbox($Text_DrawTrack, 15, 75, 240, 15)
	If $ShowTrack = 1 Then GUICtrlSetState($GUI_ExportGPX_DrawTrack, $GUI_CHECKED)
	$GUI_ExportGPX_OK = GUICtrlCreateButton($Text_Ok, 40, 115, 81, 25, 0)
	$GUI_ExportGPX_Cancel = GUICtrlCreateButton($Text_Cancel, 139, 115, 81, 25, 0)
	GUISetState(@SW_SHOW)

	While 1
		$nMsg = GUIGetMsg()
		Switch $nMsg
			Case $GUI_EVENT_CLOSE
				GUIDelete($ExportGPXGUI)
				ExitLoop
			Case $GUI_ExportGPX_Cancel
				GUIDelete($ExportGPXGUI)
				ExitLoop
			Case $GUI_ExportGPX_OK
				If GUICtrlRead($GUI_ExportGPX_MapOpen) = 1 Then
					$MapOpen = 1
				Else
					$MapOpen = 0
				EndIf
				If GUICtrlRead($GUI_ExportGPX_MapWEP) = 1 Then
					$MapWEP = 1
				Else
					$MapWEP = 0
				EndIf
				If GUICtrlRead($GUI_ExportGPX_MapSec) = 1 Then
					$MapSec = 1
				Else
					$MapSec = 0
				EndIf
				If GUICtrlRead($GUI_ExportGPX_DrawTrack) = 1 Then
					$ShowTrack = 1
				Else
					$ShowTrack = 0
				EndIf
				GUIDelete($ExportGPXGUI)
				DirCreate($SaveDir)
				$filename = FileSaveDialog("Garmin Output File", $SaveDir, 'GPS eXchange Format (*.gpx)', '', $ldatetimestamp & '.gpx')
				If Not @error Then
					If StringInStr($filename, '.gpx') = 0 Then $filename = $filename & '.gpx'
					$saved = _SaveGarminGPX($filename, $MapOpen, $MapWEP, $MapSec, $ShowTrack)
					If $saved = 1 Then
						MsgBox(0, $Text_Done, $Text_SavedAs & ': "' & $filename & '"')
					Else
						MsgBox(0, $Text_Done, $Text_NoApsWithGps & ' ' & $Text_NoFileSaved)
					EndIf
				EndIf
				ExitLoop
		EndSwitch
	WEnd
	Opt("GUIOnEventMode", 1)
EndFunc   ;==>_SaveToGPX

Func _SaveGarminGPX($savefile, $MapOpenAPs = 1, $MapWepAps = 1, $MapSecAps = 1, $GpsTrack = 0, $Sanitize = 1)
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_SaveGarminGPX()') ;#Debug Display
	$FoundApWithGps = 0

	$file = '<?xml version="1.0" encoding="UTF-8" standalone="no" ?>' & @CRLF _
			 & '<gpx xmlns="http://www.topografix.com/GPX/1/1" creator="Vistumbler ' & $version & '" version="1.1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd">' & @CRLF
	If $MapOpenAPs = 1 Then
		$query = "SELECT SSID, BSSID, HighGpsHistId FROM AP WHERE SECTYPE=1 And HighGpsHistId<>0"
		$ApMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
		$FoundApMatch = UBound($ApMatchArray) - 1
		If $FoundApMatch <> 0 Then
			$FoundApWithGps = 1
			For $exp = 1 To $FoundApMatch
				GUICtrlSetData($msgdisplay, 'Saving Open AP ' & $exp & '/' & $FoundApMatch)
				$ExpSSID = $ApMatchArray[$exp][1]
				If $Sanitize = 1 Then $ExpSSID = StringReplace(StringReplace(StringReplace($ExpSSID, '&', ''), '>', ''), '<', '')
				$ExpBSSID = $ApMatchArray[$exp][2]
				$ExpHighGpsHistID = $ApMatchArray[$exp][3]
				;Get Gps ID of HighGpsHistId
				$query = "SELECT GpsID FROM Hist Where HistID=" & $ExpHighGpsHistID
				$HistMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
				$ExpGID = $HistMatchArray[1][1]
				;Get Latitude and Longitude
				$query = "SELECT Latitude, Longitude, Alt, Date1, Time1 FROM GPS WHERE GpsId=" & $ExpGID
				$GpsMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
				$ExpLat = StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($GpsMatchArray[1][1]), 'S', '-'), 'N', ''), ' ', '')
				$ExpLon = StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($GpsMatchArray[1][2]), 'W', '-'), 'E', ''), ' ', '')
				$ExpAlt = _MetersToFeet($GpsMatchArray[1][3])
				$ExpDate = $GpsMatchArray[1][4]
				$ExpTime = $GpsMatchArray[1][5]

				If $ExpLat <> 'N 0.0000000' And $ExpLon <> 'E 0.0000000' Then
					$file &= '<wpt lat="' & $ExpLat & '" lon="' & $ExpLon & '">' & @CRLF _
							 & '<ele>' & $ExpAlt & '</ele>' & @CRLF _
							 & '<time>' & $ExpDate & 'T' & $ExpTime & 'Z</time>' & @CRLF _
							 & '<name>' & $ExpSSID & '</name>' & @CRLF _
							 & '<cmt>' & $ExpBSSID & '</cmt>' & @CRLF _
							 & '<desc>' & $ExpBSSID & '</desc>' & @CRLF _
							 & '<sym>Navaid, Green</sym>' & @CRLF _
							 & '<extensions>' & @CRLF _
							 & '<gpxx:WaypointExtension xmlns:gpxx="http://www.garmin.com/xmlschemas/GpxExtensions/v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.garmin.com/xmlschemas/GpxExtensions/v3 http://www.garmin.com/xmlschemas/GpxExtensions/v3/GpxExtensionsv3.xsd">' & @CRLF _
							 & '<gpxx:DisplayMode>SymbolAndName</gpxx:DisplayMode>' & @CRLF _
							 & '<gpxx:Categories>' & @CRLF _
							 & '<gpxx:Category>Category 1</gpxx:Category>' & @CRLF _
							 & '</gpxx:Categories>' & @CRLF _
							 & '</gpxx:WaypointExtension>' & @CRLF _
							 & '</extensions>' & @CRLF _
							 & '</wpt>' & @CRLF & @CRLF
				EndIf
			Next
		EndIf
	EndIf
	If $MapWepAps = 1 Then
		$query = "SELECT SSID, BSSID, HighGpsHistId FROM AP WHERE SECTYPE=2 And HighGpsHistId<>0"
		$ApMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
		$FoundApMatch = UBound($ApMatchArray) - 1
		If $FoundApMatch <> 0 Then
			$FoundApWithGps = 1
			For $exp = 1 To $FoundApMatch
				GUICtrlSetData($msgdisplay, 'Saving WEP AP ' & $exp & '/' & $FoundApMatch)
				$ExpSSID = $ApMatchArray[$exp][1]
				If $Sanitize = 1 Then $ExpSSID = StringReplace(StringReplace(StringReplace($ExpSSID, '&', ''), '>', ''), '<', '')
				$ExpBSSID = $ApMatchArray[$exp][2]
				$ExpHighGpsHistID = $ApMatchArray[$exp][3]

				;Get Gps ID of HighGpsHistId
				$query = "SELECT GpsID FROM Hist Where HistID=" & $ExpHighGpsHistID
				$HistMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
				$ExpGID = $HistMatchArray[1][1]
				;Get Latitude and Longitude
				$query = "SELECT Latitude, Longitude, Alt, Date1, Time1 FROM GPS WHERE GpsId=" & $ExpGID
				$GpsMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
				$ExpLat = StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($GpsMatchArray[1][1]), 'S', '-'), 'N', ''), ' ', '')
				$ExpLon = StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($GpsMatchArray[1][2]), 'W', '-'), 'E', ''), ' ', '')
				$ExpAlt = _MetersToFeet($GpsMatchArray[1][3])
				$ExpDate = $GpsMatchArray[1][4]
				$ExpTime = $GpsMatchArray[1][5]

				If $ExpLat <> 'N 0.0000000' And $ExpLon <> 'E 0.0000000' Then
					$file &= '<wpt lat="' & $ExpLat & '" lon="' & $ExpLon & '">' & @CRLF _
							 & '<ele>' & $ExpAlt & '</ele>' & @CRLF _
							 & '<time>' & $ExpDate & 'T' & $ExpTime & 'Z</time>' & @CRLF _
							 & '<name>' & $ExpSSID & '</name>' & @CRLF _
							 & '<cmt>' & $ExpBSSID & '</cmt>' & @CRLF _
							 & '<desc>' & $ExpBSSID & '</desc>' & @CRLF _
							 & '<sym>Navaid, Amber</sym>' & @CRLF _
							 & '<extensions>' & @CRLF _
							 & '<gpxx:WaypointExtension xmlns:gpxx="http://www.garmin.com/xmlschemas/GpxExtensions/v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.garmin.com/xmlschemas/GpxExtensions/v3 http://www.garmin.com/xmlschemas/GpxExtensions/v3/GpxExtensionsv3.xsd">' & @CRLF _
							 & '<gpxx:DisplayMode>SymbolAndName</gpxx:DisplayMode>' & @CRLF _
							 & '<gpxx:Categories>' & @CRLF _
							 & '<gpxx:Category>Category 2</gpxx:Category>' & @CRLF _
							 & '</gpxx:Categories>' & @CRLF _
							 & '</gpxx:WaypointExtension>' & @CRLF _
							 & '</extensions>' & @CRLF _
							 & '</wpt>' & @CRLF & @CRLF
				EndIf
			Next
		EndIf
	EndIf
	If $MapSecAps = 1 Then
		$query = "SELECT SSID, BSSID, HighGpsHistId FROM AP WHERE SECTYPE=3 And HighGpsHistId<>0"
		$ApMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
		$FoundApMatch = UBound($ApMatchArray) - 1
		If $FoundApMatch <> 0 Then
			$FoundApWithGps = 1
			For $exp = 1 To $FoundApMatch
				GUICtrlSetData($msgdisplay, 'Saving Secure AP ' & $exp & '/' & $FoundApMatch)
				$ExpSSID = $ApMatchArray[$exp][1]
				If $Sanitize = 1 Then $ExpSSID = StringReplace(StringReplace(StringReplace($ExpSSID, '&', ''), '>', ''), '<', '')
				$ExpBSSID = $ApMatchArray[$exp][2]
				$ExpHighGpsHistID = $ApMatchArray[$exp][3]

				;Get Gps ID of HighGpsHistId
				$query = "SELECT GpsID FROM Hist Where HistID=" & $ExpHighGpsHistID
				$HistMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
				$ExpGID = $HistMatchArray[1][1]
				;Get Latitude and Longitude
				$query = "SELECT Latitude, Longitude, Alt, Date1, Time1 FROM GPS WHERE GpsId=" & $ExpGID
				$GpsMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
				$ExpLat = StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($GpsMatchArray[1][1]), 'S', '-'), 'N', ''), ' ', '')
				$ExpLon = StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($GpsMatchArray[1][2]), 'W', '-'), 'E', ''), ' ', '')
				$ExpAlt = _MetersToFeet($GpsMatchArray[1][3])
				$ExpDate = $GpsMatchArray[1][4]
				$ExpTime = $GpsMatchArray[1][5]

				If $ExpLat <> 'N 0.0000000' And $ExpLon <> 'E 0.0000000' Then
					$file &= '<wpt lat="' & $ExpLat & '" lon="' & $ExpLon & '">' & @CRLF _
							 & '<ele>' & $ExpAlt & '</ele>' & @CRLF _
							 & '<time>' & $ExpDate & 'T' & $ExpTime & 'Z</time>' & @CRLF _
							 & '<name>' & $ExpSSID & '</name>' & @CRLF _
							 & '<cmt>' & $ExpBSSID & '</cmt>' & @CRLF _
							 & '<desc>' & $ExpBSSID & '</desc>' & @CRLF _
							 & '<sym>Navaid, Red</sym>' & @CRLF _
							 & '<extensions>' & @CRLF _
							 & '<gpxx:WaypointExtension xmlns:gpxx="http://www.garmin.com/xmlschemas/GpxExtensions/v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.garmin.com/xmlschemas/GpxExtensions/v3 http://www.garmin.com/xmlschemas/GpxExtensions/v3/GpxExtensionsv3.xsd">' & @CRLF _
							 & '<gpxx:DisplayMode>SymbolAndName</gpxx:DisplayMode>' & @CRLF _
							 & '<gpxx:Categories>' & @CRLF _
							 & '<gpxx:Category>Category 3</gpxx:Category>' & @CRLF _
							 & '</gpxx:Categories>' & @CRLF _
							 & '</gpxx:WaypointExtension>' & @CRLF _
							 & '</extensions>' & @CRLF _
							 & '</wpt>' & @CRLF & @CRLF
				EndIf
			Next
		EndIf
	EndIf

	If $GpsTrack = 1 Then
		$query = "SELECT Latitude, Longitude, Alt, Date1, Time1, SpeedInKmH FROM GPS WHERE Latitude <> 'N 0000.0000' And Longitude <> 'E 0000.0000' ORDER BY Date1, Time1"
		$GpsMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
		$FoundGpsMatch = UBound($GpsMatchArray) - 1
		If $FoundGpsMatch <> 0 Then
			$file &= '<trk>' & @CRLF _
					 & '<name>GPS Track</name>' & @CRLF _
					 & '<trkseg>' & @CRLF
			For $exp = 1 To $FoundGpsMatch
				GUICtrlSetData($msgdisplay, 'Saving Gps Position ' & $exp & '/' & $FoundGpsMatch)
				$ExpLat = StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($GpsMatchArray[$exp][1]), 'S', '-'), 'N', ''), ' ', '')
				$ExpLon = StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($GpsMatchArray[$exp][2]), 'W', '-'), 'E', ''), ' ', '')
				$ExpAlt = _MetersToFeet($GpsMatchArray[$exp][3])
				$ExpDate = $GpsMatchArray[$exp][4]
				$ExpTime = $GpsMatchArray[$exp][5]
				$ExpSpeedKmh = $GpsMatchArray[$exp][6]
				If $ExpLat <> 'N 0.0000000' And $ExpLon <> 'E 0.0000000' Then
					$FoundApWithGps = 1
					$file &= '<trkpt lat="' & $ExpLat & '" lon="' & $ExpLon & '">' & @CRLF _
							 & '<ele>' & $ExpAlt & '</ele>' & @CRLF _
							 & '<time>' & $ExpDate & 'T' & $ExpTime & 'Z</time>' & @CRLF _
							 & '</trkpt>' & @CRLF
				EndIf
			Next
			$file &= '</trkseg>' & @CRLF _
					 & '</trk>' & @CRLF
		EndIf
	EndIf
	$file &= '</gpx>' & @CRLF

	If $FoundApWithGps = 1 Then
		$savefile = FileOpen($savefile, 128 + 2);Open in UTF-8 write mode
		FileWrite($savefile, $file)
		FileClose($savefile)
		Return (1)
	Else
		Return (0)
	EndIf
	;EndIf
EndFunc   ;==>_SaveGarminGPX

Func _WriteINI()
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_WriteINI()') ;#Debug Display
	;write ini settings
	If $SaveDir <> $DefaultSaveDir Then
		IniWrite($settings, "Vistumbler", "SaveDir", $SaveDir);Write new save dir ro ini
	Else
		IniDelete($settings, "Vistumbler", "SaveDir");delete entry from the ini file
	EndIf
	If $SaveDirAuto <> $DefaultSaveDir Then
		IniWrite($settings, "Vistumbler", "SaveDirAuto", $SaveDirAuto);Write new auto save dir ro ini
	Else
		IniDelete($settings, "Vistumbler", "SaveDirAuto");delete entry from the ini file
	EndIf
	If $SaveDirKml <> $DefaultSaveDir Then
		IniWrite($settings, "Vistumbler", "SaveDirKml", $SaveDirKml);Write new save kml dir ro ini
	Else
		IniDelete($settings, "Vistumbler", "SaveDirKml");delete entry from the ini file
	EndIf
	IniWrite($settings, "Vistumbler", "Netsh_exe", $netsh)
	IniWrite($settings, "Vistumbler", 'PortableMode', $PortableMode)
	IniWrite($settings, "Vistumbler", "UseNativeWifi", $UseNativeWifi)
	IniWrite($settings, "Vistumbler", "AutoCheckForUpdates", $AutoCheckForUpdates)
	IniWrite($settings, "Vistumbler", "CheckForBetaUpdates", $CheckForBetaUpdates)
	IniWrite($settings, "Vistumbler", "DefaultApapter", $DefaultApapter)
	IniWrite($settings, "Vistumbler", "TextColor", $TextColor)
	IniWrite($settings, "Vistumbler", "BackgroundColor", $BackgroundColor)
	IniWrite($settings, "Vistumbler", "ControlBackgroundColor", $ControlBackgroundColor)
	IniWrite($settings, "Vistumbler", "SplitPercent", $SplitPercent)
	IniWrite($settings, "Vistumbler", "SplitHeightPercent", $SplitHeightPercent)
	IniWrite($settings, "Vistumbler", "Sleeptime", $RefreshLoopTime)
	IniWrite($settings, "Vistumbler", "NewApPosistion", $AddDirection)
	IniWrite($settings, "Vistumbler", "Language", $DefaultLanguage)
	IniWrite($settings, "Vistumbler", "LanguageFile", $DefaultLanguageFile)
	IniWrite($settings, "Vistumbler", "AutoRefreshNetworks", $RefreshNetworks)
	IniWrite($settings, "Vistumbler", "AutoRefreshTime", $RefreshTime)
	IniWrite($settings, 'Vistumbler', 'Debug', $Debug)
	IniWrite($settings, 'Vistumbler', 'DebugCom', $DebugCom)
	IniWrite($settings, 'Vistumbler', 'GraphDeadTime', $GraphDeadTime)
	IniWrite($settings, 'Vistumbler', 'UseRssiInGraphs', $UseRssiInGraphs)
	IniWrite($settings, "Vistumbler", 'SaveGpsWithNoAps', $SaveGpsWithNoAps)
	IniWrite($settings, "Vistumbler", 'TimeBeforeMarkedDead', $TimeBeforeMarkedDead)
	IniWrite($settings, "Vistumbler", 'AutoSelect', $AutoSelect)
	IniWrite($settings, "Vistumbler", 'AutoSelectHS', $AutoSelectHS)
	IniWrite($settings, "Vistumbler", 'DefFiltID', $DefFiltID)
	IniWrite($settings, "Vistumbler", 'AutoScan', $AutoScan)
	IniWrite($settings, "Vistumbler", 'dBmMaxSignal', $dBmMaxSignal)
	IniWrite($settings, "Vistumbler", 'dBmDissociationSignal', $dBmDissociationSignal)
	IniWrite($settings, "Vistumbler", 'MinimalGuiMode', $MinimalGuiMode)
	IniWrite($settings, "Vistumbler", 'MinimalGuiExitHeight', $MinimalGuiExitHeight)
	IniWrite($settings, "Vistumbler", 'BatchListviewInsert', $BatchListviewInsert)
	IniWrite($settings, "Vistumbler", 'AutoScrollToBottom', $AutoScrollToBottom)

	IniWrite($settings, 'WindowPositions', 'VistumblerState', $VistumblerState)
	IniWrite($settings, 'WindowPositions', 'VistumblerPosition', $VistumblerPosition)
	IniWrite($settings, 'WindowPositions', 'CompassPosition', $CompassPosition)
	IniWrite($settings, 'WindowPositions', 'GpsDetailsPosition', $GpsDetailsPosition)
	IniWrite($settings, 'WindowPositions', '2400ChanGraphPos', $2400ChanGraphPos)
	IniWrite($settings, 'WindowPositions', '5000ChanGraphPos', $5000ChanGraphPos)

	IniWrite($settings, "DateFormat", "DateFormat", $DateFormat)

	IniWrite($settings, 'GpsSettings', 'ComPort', $ComPort)
	IniWrite($settings, 'GpsSettings', 'Baud', $BAUD)
	IniWrite($settings, 'GpsSettings', 'Parity', $PARITY)
	IniWrite($settings, 'GpsSettings', 'DataBit', $DATABIT)
	IniWrite($settings, 'GpsSettings', 'StopBit', $STOPBIT)
	IniWrite($settings, 'GpsSettings', 'GpsType', $GpsType)
	IniWrite($settings, 'GpsSettings', 'GPSformat', $GPSformat)
	IniWrite($settings, 'GpsSettings', 'GpsTimeout', $GpsTimeout)
	IniWrite($settings, 'GpsSettings', 'GpsDisconnect', $GpsDisconnect)
	IniWrite($settings, 'GpsSettings', 'GpsReset', $GpsReset)

	IniWrite($settings, "AutoSort", "AutoSortTime", $SortTime)
	IniWrite($settings, "AutoSort", "AutoSort", $AutoSort)
	IniWrite($settings, "AutoSort", "SortCombo", $SortBy)
	IniWrite($settings, "AutoSort", "AscDecDefault", $SortDirection)

	IniWrite($settings, "AutoRecovery", "AutoRecovery", $AutoRecoveryVS1)
	IniWrite($settings, "AutoRecovery", "AutoRecoveryDel", $AutoRecoveryVS1Del)
	IniWrite($settings, "AutoRecovery", "AutoSaveTime", $AutoRecoveryTime)

	IniWrite($settings, "AutoSaveAndClear", "AutoSaveAndClear", $AutoSaveAndClear)
	IniWrite($settings, "AutoSaveAndClear", "AutoSaveAndClearPlaySound", $AutoSaveAndClearPlaySound)
	IniWrite($settings, "AutoSaveAndClear", "AutoSaveAndClearOnTime", $AutoSaveAndClearOnTime)
	IniWrite($settings, "AutoSaveAndClear", "AutoSaveAndClearTime", $AutoSaveAndClearTime)
	IniWrite($settings, "AutoSaveAndClear", "AutoSaveAndClearOnAPs", $AutoSaveAndClearOnAPs)
	IniWrite($settings, "AutoSaveAndClear", "AutoSaveAndClearAPs", $AutoSaveAndClearAPs)

	IniWrite($settings, "Sound", 'PlaySoundOnNewGps', $SoundOnGps)
	IniWrite($settings, "Sound", 'PlaySoundOnNewAP', $SoundOnAP)
	IniWrite($settings, "Sound", 'SoundPerAP', $SoundPerAP)
	IniWrite($settings, "Sound", 'NewSoundSigBased', $NewSoundSigBased)
	IniWrite($settings, "Sound", "NewAP_Sound", $new_AP_sound)
	IniWrite($settings, "Sound", "NewGPS_Sound", $new_GPS_sound)
	IniWrite($settings, "Sound", "AutoSave_Sound", $AutoSave_sound)
	IniWrite($settings, "Sound", "Error_Sound", $ErrorFlag_sound)

	IniWrite($settings, "MIDI", 'SpeakSignal', $SpeakSignal)
	IniWrite($settings, "MIDI", 'SpeakSigSayPecent', $SpeakSigSayPecent)
	IniWrite($settings, "MIDI", 'SpeakSigTime', $SpeakSigTime)
	IniWrite($settings, "MIDI", 'SpeakType', $SpeakType)
	IniWrite($settings, "MIDI", 'Midi_Instument', $Midi_Instument)
	IniWrite($settings, "MIDI", 'Midi_PlayTime', $Midi_PlayTime)
	IniWrite($settings, "MIDI", 'Midi_PlayForActiveAps', $Midi_PlayForActiveAps)

	IniWrite($settings, 'Cam', 'CamTriggerScript', $CamTriggerScript)
	IniWrite($settings, 'Cam', 'CamTriggerTime', $CamTriggerTime)
	IniWrite($settings, 'Cam', 'DownloadImages', $DownloadImages)
	IniWrite($settings, 'Cam', 'DownloadImagesTime', $DownloadImagesTime)

	IniWrite($settings, 'AutoKML', 'AutoKML', $AutoKML)
	IniWrite($settings, 'AutoKML', 'AutoKML_Alt', $AutoKML_Alt)
	IniWrite($settings, 'AutoKML', 'AutoKML_AltMode', $AutoKML_AltMode)
	IniWrite($settings, 'AutoKML', 'AutoKML_Heading', $AutoKML_Heading)
	IniWrite($settings, 'AutoKML', 'AutoKML_Range', $AutoKML_Range)
	IniWrite($settings, 'AutoKML', 'AutoKML_Tilt', $AutoKML_Tilt)
	IniWrite($settings, 'AutoKML', 'AutoKmlActiveTime', $AutoKmlActiveTime)
	IniWrite($settings, 'AutoKML', 'AutoKmlDeadTime', $AutoKmlDeadTime)
	IniWrite($settings, 'AutoKML', 'AutoKmlGpsTime', $AutoKmlGpsTime)
	IniWrite($settings, 'AutoKML', 'AutoKmlTrackTime', $AutoKmlTrackTime)
	IniWrite($settings, 'AutoKML', 'KmlFlyTo', $KmlFlyTo)
	IniWrite($settings, 'AutoKML', 'OpenKmlNetLink', $OpenKmlNetLink)
	If $GoogleEarthExe <> $defaultgooglepath Then IniWrite($settings, 'AutoKML', 'GoogleEarthExe', $GoogleEarthExe)

	IniWrite($settings, 'KmlSettings', 'MapPos', $MapPos)
	IniWrite($settings, 'KmlSettings', 'MapSig', $MapSig)
	IniWrite($settings, 'KmlSettings', 'MapSigUseRSSI', $MapSigUseRSSI)
	IniWrite($settings, 'KmlSettings', 'MapSigType', $MapSigType)
	IniWrite($settings, 'KmlSettings', 'MapRange', $MapRange)
	IniWrite($settings, 'KmlSettings', 'ShowTrack', $ShowTrack)
	IniWrite($settings, "KmlSettings", 'MapOpen', $MapOpen)
	IniWrite($settings, 'KmlSettings', 'MapWEP', $MapWEP)
	IniWrite($settings, 'KmlSettings', 'MapSec', $MapSec)
	IniWrite($settings, 'KmlSettings', 'UseLocalKmlImagesOnExport', $UseLocalKmlImagesOnExport)
	IniWrite($settings, 'KmlSettings', 'SigMapTimeBeforeMarkedDead', $SigMapTimeBeforeMarkedDead)
	IniWrite($settings, 'KmlSettings', 'TrackColor', $TrackColor)
	IniWrite($settings, 'KmlSettings', 'CirSigMapColor', $CirSigMapColor)
	IniWrite($settings, 'KmlSettings', 'CirRangeMapColor', $CirRangeMapColor)

	IniWrite($settings, 'WifiDbWifiTools', 'WifiDb_User', $WifiDb_User)
	IniWrite($settings, 'WifiDbWifiTools', 'WifiDb_ApiKey', $WifiDb_ApiKey)
	IniWrite($settings, 'WifiDbWifiTools', 'WifiDb_OtherUsers', $WifiDb_OtherUsers)
	IniWrite($settings, 'WifiDbWifiTools', 'WifiDb_UploadType', $WifiDb_UploadType)
	IniWrite($settings, 'WifiDbWifiTools', 'WifiDb_UploadFiltered', $WifiDb_UploadFiltered)
	IniWrite($settings, 'WifiDbWifiTools', 'WifiDb_GRAPH_URL', $WifiDbGraphURL)
	IniWrite($settings, 'WifiDbWifiTools', 'WiFiDB_URL', $WifiDbWdbURL)
	IniWrite($settings, 'WifiDbWifiTools', 'WifiDB_API_URL', $WifiDbApiURL)
	IniWrite($settings, "WifiDbWifiTools", 'UseWiFiDbGpsLocate', $UseWiFiDbGpsLocate)
	IniWrite($settings, 'WifiDbWifiTools', 'AutoUpApsToWifiDB', $AutoUpApsToWifiDB)
	IniWrite($settings, 'WifiDbWifiTools', 'AutoUpApsToWifiDBTime', $AutoUpApsToWifiDBTime)
	IniWrite($settings, "WifiDbWifiTools", "WiFiDbLocateRefreshTime", $WiFiDbLocateRefreshTime)

	If $VistumblerGuiOpen = 1 Then
		;Get Current column positions
		$currentcolumn = StringSplit(_GUICtrlListView_GetColumnOrder($ListviewAPs), '|')
		For $c = 1 To $currentcolumn[0]
			If $column_Line = $currentcolumn[$c] Then $save_column_Line = $c - 1
			If $column_Active = $currentcolumn[$c] Then $save_column_Active = $c - 1
			If $column_BSSID = $currentcolumn[$c] Then $save_column_BSSID = $c - 1
			If $column_SSID = $currentcolumn[$c] Then $save_column_SSID = $c - 1
			If $column_Signal = $currentcolumn[$c] Then $save_column_Signal = $c - 1
			If $column_HighSignal = $currentcolumn[$c] Then $save_column_HighSignal = $c - 1
			If $column_RSSI = $currentcolumn[$c] Then $save_column_RSSI = $c - 1
			If $column_HighRSSI = $currentcolumn[$c] Then $save_column_HighRSSI = $c - 1
			If $column_Channel = $currentcolumn[$c] Then $save_column_Channel = $c - 1
			If $column_Authentication = $currentcolumn[$c] Then $save_column_Authentication = $c - 1
			If $column_Encryption = $currentcolumn[$c] Then $save_column_Encryption = $c - 1
			If $column_NetworkType = $currentcolumn[$c] Then $save_column_NetworkType = $c - 1
			If $column_Latitude = $currentcolumn[$c] Then $save_column_Latitude = $c - 1
			If $column_Longitude = $currentcolumn[$c] Then $save_column_Longitude = $c - 1
			If $column_MANUF = $currentcolumn[$c] Then $save_column_MANUF = $c - 1
			If $column_Label = $currentcolumn[$c] Then $save_column_Label = $c - 1
			If $column_RadioType = $currentcolumn[$c] Then $save_column_RadioType = $c - 1
			If $column_LatitudeDMS = $currentcolumn[$c] Then $save_column_LatitudeDMS = $c - 1
			If $column_LongitudeDMS = $currentcolumn[$c] Then $save_column_LongitudeDMS = $c - 1
			If $column_LatitudeDMM = $currentcolumn[$c] Then $save_column_LatitudeDMM = $c - 1
			If $column_LongitudeDMM = $currentcolumn[$c] Then $save_column_LongitudeDMM = $c - 1
			If $column_BasicTransferRates = $currentcolumn[$c] Then $save_column_BasicTransferRates = $c - 1
			If $column_OtherTransferRates = $currentcolumn[$c] Then $save_column_OtherTransferRates = $c - 1
			If $column_FirstActive = $currentcolumn[$c] Then $save_column_FirstActive = $c - 1
			If $column_LastActive = $currentcolumn[$c] Then $save_column_LastActive = $c - 1
		Next

		IniWrite($settings, "Columns", "Column_Line", $save_column_Line)
		IniWrite($settings, "Columns", "Column_Active", $save_column_Active)
		IniWrite($settings, "Columns", "Column_BSSID", $save_column_BSSID)
		IniWrite($settings, "Columns", "Column_SSID", $save_column_SSID)
		IniWrite($settings, "Columns", "Column_Signal", $save_column_Signal)
		IniWrite($settings, "Columns", "Column_HighSignal", $save_column_HighSignal)
		IniWrite($settings, "Columns", "Column_RSSI", $save_column_RSSI)
		IniWrite($settings, "Columns", "Column_HighRSSI", $save_column_HighRSSI)
		IniWrite($settings, "Columns", "Column_Channel", $save_column_Channel)
		IniWrite($settings, "Columns", "Column_Authentication", $save_column_Authentication)
		IniWrite($settings, "Columns", "Column_Encryption", $save_column_Encryption)
		IniWrite($settings, "Columns", "Column_NetworkType", $save_column_NetworkType)
		IniWrite($settings, "Columns", "Column_Latitude", $save_column_Latitude)
		IniWrite($settings, "Columns", "Column_Longitude", $save_column_Longitude)
		IniWrite($settings, "Columns", "Column_Manufacturer", $save_column_MANUF)
		IniWrite($settings, "Columns", "Column_Label", $save_column_Label)
		IniWrite($settings, "Columns", "Column_RadioType", $save_column_RadioType)
		IniWrite($settings, "Columns", "Column_LatitudeDMS", $save_column_LatitudeDMS)
		IniWrite($settings, "Columns", "Column_LongitudeDMS", $save_column_LongitudeDMS)
		IniWrite($settings, "Columns", "Column_LatitudeDMM", $save_column_LatitudeDMM)
		IniWrite($settings, "Columns", "Column_LongitudeDMM", $save_column_LongitudeDMM)
		IniWrite($settings, "Columns", "Column_BasicTransferRates", $save_column_BasicTransferRates)
		IniWrite($settings, "Columns", "Column_OtherTransferRates", $column_OtherTransferRates)
		IniWrite($settings, "Columns", "Column_FirstActive", $save_column_FirstActive)
		IniWrite($settings, "Columns", "Column_LastActive", $save_column_LastActive)

		IniWrite($settings, "Column_Width", "Column_Line", _GUICtrlListView_GetColumnWidth($ListviewAPs, $column_Line - 0))
		IniWrite($settings, "Column_Width", "Column_Active", _GUICtrlListView_GetColumnWidth($ListviewAPs, $column_Active - 0))
		IniWrite($settings, "Column_Width", "Column_BSSID", _GUICtrlListView_GetColumnWidth($ListviewAPs, $column_BSSID - 0))
		IniWrite($settings, "Column_Width", "Column_SSID", _GUICtrlListView_GetColumnWidth($ListviewAPs, $column_SSID - 0))
		IniWrite($settings, "Column_Width", "Column_Signal", _GUICtrlListView_GetColumnWidth($ListviewAPs, $column_Signal - 0))
		IniWrite($settings, "Column_Width", "Column_HighSignal", _GUICtrlListView_GetColumnWidth($ListviewAPs, $column_HighSignal - 0))
		IniWrite($settings, "Column_Width", "Column_RSSI", _GUICtrlListView_GetColumnWidth($ListviewAPs, $column_RSSI - 0))
		IniWrite($settings, "Column_Width", "Column_HighRSSI", _GUICtrlListView_GetColumnWidth($ListviewAPs, $column_HighRSSI - 0))
		IniWrite($settings, "Column_Width", "Column_Channel", _GUICtrlListView_GetColumnWidth($ListviewAPs, $column_Channel - 0))
		IniWrite($settings, "Column_Width", "Column_Authentication", _GUICtrlListView_GetColumnWidth($ListviewAPs, $column_Authentication - 0))
		IniWrite($settings, "Column_Width", "Column_Encryption", _GUICtrlListView_GetColumnWidth($ListviewAPs, $column_Encryption - 0))
		IniWrite($settings, "Column_Width", "Column_NetworkType", _GUICtrlListView_GetColumnWidth($ListviewAPs, $column_NetworkType - 0))
		IniWrite($settings, "Column_Width", "Column_Latitude", _GUICtrlListView_GetColumnWidth($ListviewAPs, $column_Latitude - 0))
		IniWrite($settings, "Column_Width", "Column_Longitude", _GUICtrlListView_GetColumnWidth($ListviewAPs, $column_Longitude - 0))
		IniWrite($settings, "Column_Width", "Column_Manufacturer", _GUICtrlListView_GetColumnWidth($ListviewAPs, $column_MANUF - 0))
		IniWrite($settings, "Column_Width", "Column_Label", _GUICtrlListView_GetColumnWidth($ListviewAPs, $column_Label - 0))
		IniWrite($settings, "Column_Width", "Column_RadioType", _GUICtrlListView_GetColumnWidth($ListviewAPs, $column_RadioType - 0))
		IniWrite($settings, "Column_Width", "Column_LatitudeDMS", _GUICtrlListView_GetColumnWidth($ListviewAPs, $column_LatitudeDMS - 0))
		IniWrite($settings, "Column_Width", "Column_LongitudeDMS", _GUICtrlListView_GetColumnWidth($ListviewAPs, $column_LongitudeDMS - 0))
		IniWrite($settings, "Column_Width", "Column_LatitudeDMM", _GUICtrlListView_GetColumnWidth($ListviewAPs, $column_LatitudeDMM - 0))
		IniWrite($settings, "Column_Width", "Column_LongitudeDMM", _GUICtrlListView_GetColumnWidth($ListviewAPs, $column_LongitudeDMM - 0))
		IniWrite($settings, "Column_Width", "Column_BasicTransferRates", _GUICtrlListView_GetColumnWidth($ListviewAPs, $column_BasicTransferRates - 0))
		IniWrite($settings, "Column_Width", "Column_OtherTransferRates", _GUICtrlListView_GetColumnWidth($ListviewAPs, $column_OtherTransferRates - 0))
		IniWrite($settings, "Column_Width", "Column_FirstActive", _GUICtrlListView_GetColumnWidth($ListviewAPs, $column_FirstActive - 0))
		IniWrite($settings, "Column_Width", "Column_LastActive", _GUICtrlListView_GetColumnWidth($ListviewAPs, $column_LastActive - 0))
	EndIf

	;//Write Changes to Language File
	IniWrite($DefaultLanguagePath, "Column_Names", "Column_Line", $Column_Names_Line)
	IniWrite($DefaultLanguagePath, "Column_Names", "Column_Active", $Column_Names_Active)
	IniWrite($DefaultLanguagePath, "Column_Names", "Column_SSID", $Column_Names_SSID)
	IniWrite($DefaultLanguagePath, "Column_Names", "Column_BSSID", $Column_Names_BSSID)
	IniWrite($DefaultLanguagePath, "Column_Names", "Column_Manufacturer", $Column_Names_MANUF)
	IniWrite($DefaultLanguagePath, "Column_Names", "Column_Signal", $Column_Names_Signal)
	IniWrite($DefaultLanguagePath, "Column_Names", "Column_HighSignal", $Column_Names_HighSignal)
	IniWrite($DefaultLanguagePath, "Column_Names", "Column_RSSI", $Column_Names_RSSI)
	IniWrite($DefaultLanguagePath, "Column_Names", "Column_HighRSSI", $Column_Names_HighRSSI)
	IniWrite($DefaultLanguagePath, "Column_Names", "Column_Authentication", $Column_Names_Authentication)
	IniWrite($DefaultLanguagePath, "Column_Names", "Column_Encryption", $Column_Names_Encryption)
	IniWrite($DefaultLanguagePath, "Column_Names", "Column_RadioType", $Column_Names_RadioType)
	IniWrite($DefaultLanguagePath, "Column_Names", "Column_Channel", $Column_Names_Channel)
	IniWrite($DefaultLanguagePath, "Column_Names", "Column_Latitude", $Column_Names_Latitude)
	IniWrite($DefaultLanguagePath, "Column_Names", "Column_Longitude", $Column_Names_Longitude)
	IniWrite($DefaultLanguagePath, "Column_Names", "Column_LatitudeDMS", $Column_Names_LatitudeDMS)
	IniWrite($DefaultLanguagePath, "Column_Names", "Column_LongitudeDMS", $Column_Names_LongitudeDMS)
	IniWrite($DefaultLanguagePath, "Column_Names", "Column_LatitudeDMM", $Column_Names_LatitudeDMM)
	IniWrite($DefaultLanguagePath, "Column_Names", "Column_LongitudeDMM", $Column_Names_LongitudeDMM)
	IniWrite($DefaultLanguagePath, "Column_Names", "Column_BasicTransferRates", $Column_Names_BasicTransferRates)
	IniWrite($DefaultLanguagePath, "Column_Names", "Column_OtherTransferRates", $Column_Names_OtherTransferRates)
	IniWrite($DefaultLanguagePath, "Column_Names", "Column_FirstActive", $Column_Names_FirstActive)
	IniWrite($DefaultLanguagePath, "Column_Names", "Column_LastActive", $Column_Names_LastActive)
	IniWrite($DefaultLanguagePath, "Column_Names", "Column_NetworkType", $Column_Names_NetworkType)
	IniWrite($DefaultLanguagePath, "Column_Names", "Column_Label", $Column_Names_Label)

	IniWrite($DefaultLanguagePath, "SearchWords", "SSID", $SearchWord_SSID)
	IniWrite($DefaultLanguagePath, "SearchWords", "BSSID", $SearchWord_BSSID)
	IniWrite($DefaultLanguagePath, "SearchWords", "NetworkType", $SearchWord_NetworkType)
	IniWrite($DefaultLanguagePath, "SearchWords", "Authentication", $SearchWord_Authentication)
	IniWrite($DefaultLanguagePath, "SearchWords", "Encryption", $SearchWord_Encryption)
	IniWrite($DefaultLanguagePath, "SearchWords", "Signal", $SearchWord_Signal)
	IniWrite($DefaultLanguagePath, "SearchWords", "RSSI", $SearchWord_RSSI)
	IniWrite($DefaultLanguagePath, "SearchWords", "RadioType", $SearchWord_RadioType)
	IniWrite($DefaultLanguagePath, "SearchWords", "Channel", $SearchWord_Channel)
	IniWrite($DefaultLanguagePath, "SearchWords", "BasicRates", $SearchWord_BasicRates)
	IniWrite($DefaultLanguagePath, "SearchWords", "OtherRates", $SearchWord_OtherRates)
	IniWrite($DefaultLanguagePath, "SearchWords", "Open", $SearchWord_Open)
	IniWrite($DefaultLanguagePath, "SearchWords", "None", $SearchWord_None)
	IniWrite($DefaultLanguagePath, "SearchWords", "WEP", $SearchWord_Wep)
	IniWrite($DefaultLanguagePath, "SearchWords", "Infrastructure", $SearchWord_Infrastructure)
	IniWrite($DefaultLanguagePath, "SearchWords", "Adhoc", $SearchWord_Adhoc)
	IniWrite($DefaultLanguagePath, "SearchWords", "Cipher", $SearchWord_Cipher)

	IniWrite($DefaultLanguagePath, "GuiText", "Ok", $Text_Ok)
	IniWrite($DefaultLanguagePath, "GuiText", "Cancel", $Text_Cancel)
	IniWrite($DefaultLanguagePath, "GuiText", "Apply", $Text_Apply)
	IniWrite($DefaultLanguagePath, "GuiText", "Browse", $Text_Browse)
	IniWrite($DefaultLanguagePath, "GuiText", "File", $Text_File)
	IniWrite($DefaultLanguagePath, "GuiText", "Import", $Text_Import)
	IniWrite($DefaultLanguagePath, "GuiText", "SaveAsTXT", $Text_SaveAsTXT)
	IniWrite($DefaultLanguagePath, "GuiText", "SaveAsVS1", $Text_SaveAsVS1)
	IniWrite($DefaultLanguagePath, "GuiText", "SaveAsVSZ", $Text_SaveAsVSZ)
	IniWrite($DefaultLanguagePath, "GuiText", "ImportFromTXT", $Text_ImportFromTXT)
	IniWrite($DefaultLanguagePath, "GuiText", "ImportFromVSZ", $Text_ImportFromVSZ)
	IniWrite($DefaultLanguagePath, "GuiText", "Exit", $Text_Exit)
	IniWrite($DefaultLanguagePath, "GuiText", "ExitSaveDb", $Text_ExitSaveDb)
	IniWrite($DefaultLanguagePath, "GuiText", "Edit", $Text_Edit)
	IniWrite($DefaultLanguagePath, "GuiText", "ClearAll", $Text_ClearAll)
	IniWrite($DefaultLanguagePath, "GuiText", "Cut", $Text_Cut)
	IniWrite($DefaultLanguagePath, "GuiText", "Copy", $Text_Copy)
	IniWrite($DefaultLanguagePath, "GuiText", "Paste", $Text_Paste)
	IniWrite($DefaultLanguagePath, "GuiText", "Delete", $Text_Delete)
	IniWrite($DefaultLanguagePath, "GuiText", "Select", $Text_Select)
	IniWrite($DefaultLanguagePath, "GuiText", "SelectAll", $Text_SelectAll)
	IniWrite($DefaultLanguagePath, "GuiText", "View", $Text_View)
	IniWrite($DefaultLanguagePath, "GuiText", "Options", $Text_Options)
	IniWrite($DefaultLanguagePath, "GuiText", "AutoSort", $Text_AutoSort)
	IniWrite($DefaultLanguagePath, "GuiText", "SortTree", $Text_SortTree)
	IniWrite($DefaultLanguagePath, "GuiText", "PlaySound", $Text_PlaySound)
	IniWrite($DefaultLanguagePath, "GuiText", "PlayGpsSound", $Text_PlayGpsSound)
	IniWrite($DefaultLanguagePath, "GuiText", "AddAPsToTop", $Text_AddAPsToTop)
	IniWrite($DefaultLanguagePath, "GuiText", "Extra", $Text_Extra)
	IniWrite($DefaultLanguagePath, "GuiText", "ScanAPs", $Text_ScanAPs)
	IniWrite($DefaultLanguagePath, "GuiText", "StopScanAps", $Text_StopScanAps)
	IniWrite($DefaultLanguagePath, "GuiText", "UseGPS", $Text_UseGPS)
	IniWrite($DefaultLanguagePath, "GuiText", "StopGPS", $Text_StopGPS)
	IniWrite($DefaultLanguagePath, "GuiText", "Settings", $Text_Settings)
	IniWrite($DefaultLanguagePath, "GuiText", "MiscSettings", $Text_MiscSettings)
	IniWrite($DefaultLanguagePath, "GuiText", "SaveSettings", $Text_SaveSettings)
	IniWrite($DefaultLanguagePath, "GuiText", "GpsSettings", $Text_GpsSettings)
	IniWrite($DefaultLanguagePath, "GuiText", "SetLanguage", $Text_SetLanguage)
	IniWrite($DefaultLanguagePath, "GuiText", "SetSearchWords", $Text_SetSearchWords)
	IniWrite($DefaultLanguagePath, "GuiText", "Export", $Text_Export)
	IniWrite($DefaultLanguagePath, "GuiText", "ExportToKML", $Text_ExportToKML)
	IniWrite($DefaultLanguagePath, "GuiText", "ExportToGPX", $Text_ExportToGPX)
	IniWrite($DefaultLanguagePath, "GuiText", "ExportToTXT", $Text_ExportToTXT)
	IniWrite($DefaultLanguagePath, "GuiText", "ExportToNS1", $Text_ExportToNS1)
	IniWrite($DefaultLanguagePath, "GuiText", "ExportToVS1", $Text_ExportToVS1)
	IniWrite($DefaultLanguagePath, "GuiText", "ExportToCSV", $Text_ExportToCSV)
	IniWrite($DefaultLanguagePath, "GuiText", "ExportToVSZ", $Text_ExportToVSZ)
	IniWrite($DefaultLanguagePath, "GuiText", "WifiDbPHPgraph", $Text_WifiDbPHPgraph)
	IniWrite($DefaultLanguagePath, "GuiText", "WifiDbWDB", $Text_WifiDbWDB)
	IniWrite($DefaultLanguagePath, "GuiText", "WifiDbWdbLocate", $Text_WifiDbWdbLocate)
	IniWrite($DefaultLanguagePath, "GuiText", "UploadDataToWiFiDB", $Text_UploadDataToWifiDB)
	IniWrite($DefaultLanguagePath, "GuiText", "RefreshLoopTime", $Text_RefreshLoopTime)
	IniWrite($DefaultLanguagePath, "GuiText", "ActualLoopTime", $Text_ActualLoopTime)
	IniWrite($DefaultLanguagePath, "GuiText", "Longitude", $Text_Longitude)
	IniWrite($DefaultLanguagePath, "GuiText", "Latitude", $Text_Latitude)
	IniWrite($DefaultLanguagePath, "GuiText", "ActiveAPs", $Text_ActiveAPs)
	IniWrite($DefaultLanguagePath, "GuiText", "Graph", $Text_Graph)
	IniWrite($DefaultLanguagePath, "GuiText", "Graph1", $Text_Graph1)
	IniWrite($DefaultLanguagePath, "GuiText", "Graph2", $Text_Graph2)
	IniWrite($DefaultLanguagePath, "GuiText", "NoGraph", $Text_NoGraph)
	IniWrite($DefaultLanguagePath, 'GuiText', 'SetMacLabel', $Text_SetMacLabel)
	IniWrite($DefaultLanguagePath, 'GuiText', 'SetMacManu', $Text_SetMacManu)
	IniWrite($DefaultLanguagePath, 'GuiText', 'Active', $Text_Active)
	IniWrite($DefaultLanguagePath, 'GuiText', 'Dead', $Text_Dead)
	IniWrite($DefaultLanguagePath, 'GuiText', 'AddNewLabel', $Text_AddNewLabel)
	IniWrite($DefaultLanguagePath, 'GuiText', 'RemoveLabel', $Text_RemoveLabel)
	IniWrite($DefaultLanguagePath, 'GuiText', 'EditLabel', $Text_EditLabel)
	IniWrite($DefaultLanguagePath, 'GuiText', 'AddNewMan', $Text_AddNewMan)
	IniWrite($DefaultLanguagePath, 'GuiText', 'RemoveMan', $Text_RemoveMan)
	IniWrite($DefaultLanguagePath, 'GuiText', 'EditMan', $Text_EditMan)
	IniWrite($DefaultLanguagePath, 'GuiText', 'NewMac', $Text_NewMac)
	IniWrite($DefaultLanguagePath, 'GuiText', 'NewMan', $Text_NewMan)
	IniWrite($DefaultLanguagePath, 'GuiText', 'NewLabel', $Text_NewLabel)
	IniWrite($DefaultLanguagePath, 'GuiText', 'Save', $Text_Save)
	IniWrite($DefaultLanguagePath, 'GuiText', 'SaveQuestion', $Text_SaveQuestion)
	IniWrite($DefaultLanguagePath, 'GuiText', 'GpsDetails', $Text_GpsDetails)
	IniWrite($DefaultLanguagePath, 'GuiText', 'GpsCompass', $Text_GpsCompass)
	IniWrite($DefaultLanguagePath, 'GuiText', 'Quality', $Text_Quality)
	IniWrite($DefaultLanguagePath, 'GuiText', 'Time', $Text_Time)
	IniWrite($DefaultLanguagePath, 'GuiText', 'NumberOfSatalites', $Text_NumberOfSatalites)
	IniWrite($DefaultLanguagePath, 'GuiText', 'HorizontalDilutionPosition', $Text_HorizontalDilutionPosition)
	IniWrite($DefaultLanguagePath, 'GuiText', 'Altitude', $Text_Altitude)
	IniWrite($DefaultLanguagePath, 'GuiText', 'HeightOfGeoid', $Text_HeightOfGeoid)
	IniWrite($DefaultLanguagePath, 'GuiText', 'Status', $Text_Status)
	IniWrite($DefaultLanguagePath, 'GuiText', 'Date', $Text_Date)
	IniWrite($DefaultLanguagePath, 'GuiText', 'SpeedInKnots', $Text_SpeedInKnots)
	IniWrite($DefaultLanguagePath, 'GuiText', 'SpeedInMPH', $Text_SpeedInMPH)
	IniWrite($DefaultLanguagePath, 'GuiText', 'SpeedInKmh', $Text_SpeedInKmh)
	IniWrite($DefaultLanguagePath, 'GuiText', 'TrackAngle', $Text_TrackAngle)
	IniWrite($DefaultLanguagePath, 'GuiText', 'Close', $Text_Close)
	IniWrite($DefaultLanguagePath, 'GuiText', 'Start', $Text_Start)
	IniWrite($DefaultLanguagePath, 'GuiText', 'Stop', $Text_Stop)
	IniWrite($DefaultLanguagePath, 'GuiText', 'RefreshingNetworks', $Text_RefreshNetworks)
	IniWrite($DefaultLanguagePath, 'GuiText', 'RefreshTime', $Text_RefreshTime)
	IniWrite($DefaultLanguagePath, 'GuiText', 'SetColumnWidths', $Text_SetColumnWidths)
	IniWrite($DefaultLanguagePath, 'GuiText', 'Enable', $Text_Enable)
	IniWrite($DefaultLanguagePath, 'GuiText', 'Disable', $Text_Disable)
	IniWrite($DefaultLanguagePath, 'GuiText', 'Checked', $Text_Checked)
	IniWrite($DefaultLanguagePath, 'GuiText', 'UnChecked', $Text_UnChecked)
	IniWrite($DefaultLanguagePath, 'GuiText', 'Unknown', $Text_Unknown)
	IniWrite($DefaultLanguagePath, 'GuiText', 'Restart', $Text_Restart)
	IniWrite($DefaultLanguagePath, 'GuiText', 'RestartMsg', $Text_RestartMsg)
	IniWrite($DefaultLanguagePath, 'GuiText', 'Error', $Text_Error)
	IniWrite($DefaultLanguagePath, 'GuiText', 'NoSignalHistory', $Text_NoSignalHistory)
	IniWrite($DefaultLanguagePath, 'GuiText', 'NoApSelected', $Text_NoApSelected)
	IniWrite($DefaultLanguagePath, 'GuiText', 'UseNetcomm', $Text_UseNetcomm)
	IniWrite($DefaultLanguagePath, 'GuiText', 'UseCommMG', $Text_UseCommMG)
	IniWrite($DefaultLanguagePath, 'GuiText', 'SignalHistory', $Text_SignalHistory)
	IniWrite($DefaultLanguagePath, 'GuiText', 'AutoSortEvery', $Text_AutoSortEvery)
	IniWrite($DefaultLanguagePath, 'GuiText', 'Seconds', $Text_Seconds)
	IniWrite($DefaultLanguagePath, 'GuiText', 'Ascending', $Text_Ascending)
	IniWrite($DefaultLanguagePath, 'GuiText', 'Decending', $Text_Decending)
	IniWrite($DefaultLanguagePath, 'GuiText', 'AutoRecoveryVS1', $Text_AutoRecoveryVS1)
	IniWrite($DefaultLanguagePath, 'GuiText', 'AutoSaveEvery', $Text_AutoSaveEvery)
	IniWrite($DefaultLanguagePath, 'GuiText', 'DelAutoSaveOnExit', $Text_DelAutoSaveOnExit)
	IniWrite($DefaultLanguagePath, 'GuiText', 'OpenSaveFolder', $Text_OpenSaveFolder)
	IniWrite($DefaultLanguagePath, 'GuiText', 'SortBy', $Text_SortBy)
	IniWrite($DefaultLanguagePath, 'GuiText', 'SortDirection', $Text_SortDirection)
	IniWrite($DefaultLanguagePath, 'GuiText', 'Auto', $Text_Auto)
	IniWrite($DefaultLanguagePath, 'GuiText', 'Misc', $Text_Misc)
	IniWrite($DefaultLanguagePath, 'GuiText', 'GPS', $Text_Gps)
	IniWrite($DefaultLanguagePath, 'GuiText', 'Labels', $Text_Labels)
	IniWrite($DefaultLanguagePath, 'GuiText', 'Manufacturers', $Text_Manufacturers)
	IniWrite($DefaultLanguagePath, 'GuiText', 'Columns', $Text_Columns)
	IniWrite($DefaultLanguagePath, 'GuiText', 'Language', $Text_Language)
	IniWrite($DefaultLanguagePath, 'GuiText', 'SearchWords', $Text_SearchWords)
	IniWrite($DefaultLanguagePath, 'GuiText', 'VistumblerSettings', $Text_VistumblerSettings)
	IniWrite($DefaultLanguagePath, 'GuiText', 'LanguageAuthor', $Text_LanguageAuthor)
	IniWrite($DefaultLanguagePath, 'GuiText', 'LanguageDate', $Text_LanguageDate)
	IniWrite($DefaultLanguagePath, 'GuiText', 'LanguageDescription', $Text_LanguageDescription)
	IniWrite($DefaultLanguagePath, 'GuiText', 'Description', $Text_Description)
	IniWrite($DefaultLanguagePath, 'GuiText', 'Progress', $Text_Progress)
	IniWrite($DefaultLanguagePath, 'GuiText', 'LinesMin', $Text_LinesMin)
	IniWrite($DefaultLanguagePath, 'GuiText', 'NewAPs', $Text_NewAPs)
	IniWrite($DefaultLanguagePath, 'GuiText', 'NewGIDs', $Text_NewGIDs)
	IniWrite($DefaultLanguagePath, 'GuiText', 'Minutes', $Text_Minutes)
	IniWrite($DefaultLanguagePath, 'GuiText', 'LineTotal', $Text_LineTotal)
	IniWrite($DefaultLanguagePath, 'GuiText', 'EstimatedTimeRemaining', $Text_EstimatedTimeRemaining)
	IniWrite($DefaultLanguagePath, 'GuiText', 'Ready', $Text_Ready)
	IniWrite($DefaultLanguagePath, 'GuiText', 'Done', $Text_Done)
	IniWrite($DefaultLanguagePath, 'GuiText', 'VistumblerSaveDirectory', $Text_VistumblerSaveDirectory)
	IniWrite($DefaultLanguagePath, 'GuiText', 'VistumblerAutoSaveDirectory', $Text_VistumblerAutoSaveDirectory)
	IniWrite($DefaultLanguagePath, 'GuiText', 'VistumblerKmlSaveDirectory', $Text_VistumblerKmlSaveDirectory)
	IniWrite($DefaultLanguagePath, 'GuiText', 'BackgroundColor', $Text_BackgroundColor)
	IniWrite($DefaultLanguagePath, 'GuiText', 'ControlColor', $Text_ControlColor)
	IniWrite($DefaultLanguagePath, 'GuiText', 'BgFontColor', $Text_BgFontColor)
	IniWrite($DefaultLanguagePath, 'GuiText', 'ConFontColor', $Text_ConFontColor)
	IniWrite($DefaultLanguagePath, 'GuiText', 'NetshMsg', $Text_NetshMsg)
	IniWrite($DefaultLanguagePath, 'GuiText', 'PHPgraphing', $Text_PHPgraphing)
	IniWrite($DefaultLanguagePath, 'GuiText', 'ComInterface', $Text_ComInterface)
	IniWrite($DefaultLanguagePath, 'GuiText', 'ComSettings', $Text_ComSettings)
	IniWrite($DefaultLanguagePath, 'GuiText', 'Com', $Text_Com)
	IniWrite($DefaultLanguagePath, 'GuiText', 'Baud', $Text_Baud)
	IniWrite($DefaultLanguagePath, 'GuiText', 'GPSFormat', $Text_GPSFormat)
	IniWrite($DefaultLanguagePath, 'GuiText', 'HideOtherGpsColumns', $Text_HideOtherGpsColumns)
	IniWrite($DefaultLanguagePath, 'GuiText', 'ImportLanguageFile', $Text_ImportLanguageFile)
	IniWrite($DefaultLanguagePath, 'GuiText', 'AutoKml', $Text_AutoKml)
	IniWrite($DefaultLanguagePath, 'GuiText', 'GoogleEarthEXE', $Text_GoogleEarthEXE)
	IniWrite($DefaultLanguagePath, 'GuiText', 'AutoSaveKmlEvery', $Text_AutoSaveKmlEvery)
	IniWrite($DefaultLanguagePath, 'GuiText', 'SavedAs', $Text_SavedAs)
	IniWrite($DefaultLanguagePath, 'GuiText', 'Overwrite', $Text_Overwrite)
	IniWrite($DefaultLanguagePath, 'GuiText', 'InstallNetcommOCX', $Text_InstallNetcommOCX)
	IniWrite($DefaultLanguagePath, 'GuiText', 'NoFileSaved', $Text_NoFileSaved)
	IniWrite($DefaultLanguagePath, 'GuiText', 'NoApsWithGps', $Text_NoApsWithGps)
	IniWrite($DefaultLanguagePath, 'GuiText', 'NoAps', $Text_NoAps)
	IniWrite($DefaultLanguagePath, 'GuiText', 'MacExistsOverwriteIt', $Text_MacExistsOverwriteIt)
	IniWrite($DefaultLanguagePath, 'GuiText', 'SavingLine', $Text_SavingLine)
	IniWrite($DefaultLanguagePath, 'GuiText', 'Debug', $Text_Debug)
	IniWrite($DefaultLanguagePath, 'GuiText', 'DisplayDebug', $Text_DisplayDebug)
	IniWrite($DefaultLanguagePath, 'GuiText', 'DisplayDebugCom', $Text_DisplayComErrors)
	IniWrite($DefaultLanguagePath, 'GuiText', 'GraphDeadTime', $Text_GraphDeadTime)
	IniWrite($DefaultLanguagePath, 'GuiText', 'OpenKmlNetLink', $Text_OpenKmlNetLink)
	IniWrite($DefaultLanguagePath, 'GuiText', 'ActiveRefreshTime', $Text_ActiveRefreshTime)
	IniWrite($DefaultLanguagePath, 'GuiText', 'DeadRefreshTime', $Text_DeadRefreshTime)
	IniWrite($DefaultLanguagePath, 'GuiText', 'GpsRefrshTime', $Text_GpsRefrshTime)
	IniWrite($DefaultLanguagePath, 'GuiText', 'FlyToSettings', $Text_FlyToSettings)
	IniWrite($DefaultLanguagePath, 'GuiText', 'FlyToCurrentGps', $Text_FlyToCurrentGps)
	IniWrite($DefaultLanguagePath, 'GuiText', 'AltitudeMode', $Text_AltitudeMode)
	IniWrite($DefaultLanguagePath, 'GuiText', 'Range', $Text_Range)
	IniWrite($DefaultLanguagePath, 'GuiText', 'Heading', $Text_Heading)
	IniWrite($DefaultLanguagePath, 'GuiText', 'Tilt', $Text_Tilt)
	IniWrite($DefaultLanguagePath, 'GuiText', 'AutoOpenNetworkLink', $Text_AutoOpenNetworkLink)
	IniWrite($DefaultLanguagePath, 'GuiText', 'SpeakSignal', $Text_SpeakSignal)
	IniWrite($DefaultLanguagePath, 'GuiText', 'SpeakUseVisSounds', $Text_SpeakUseVisSounds)
	IniWrite($DefaultLanguagePath, 'GuiText', 'SpeakUseSapi', $Text_SpeakUseSapi)
	IniWrite($DefaultLanguagePath, 'GuiText', 'SpeakSayPercent', $Text_SpeakSayPercent)
	IniWrite($DefaultLanguagePath, 'GuiText', 'GpsTrackTime', $Text_GpsTrackTime)
	IniWrite($DefaultLanguagePath, 'GuiText', 'SaveAllGpsData', $Text_SaveAllGpsData)
	IniWrite($DefaultLanguagePath, 'GuiText', 'None', $Text_None)
	IniWrite($DefaultLanguagePath, 'GuiText', 'Even', $Text_Even)
	IniWrite($DefaultLanguagePath, 'GuiText', 'Odd', $Text_Odd)
	IniWrite($DefaultLanguagePath, 'GuiText', 'Mark', $Text_Mark)
	IniWrite($DefaultLanguagePath, 'GuiText', 'Space', $Text_Space)
	IniWrite($DefaultLanguagePath, 'GuiText', 'StopBit', $Text_StopBit)
	IniWrite($DefaultLanguagePath, 'GuiText', 'Parity', $Text_Parity)
	IniWrite($DefaultLanguagePath, 'GuiText', 'DataBit', $Text_DataBit)
	IniWrite($DefaultLanguagePath, 'GuiText', 'Update', $Text_Update)
	IniWrite($DefaultLanguagePath, 'GuiText', 'UpdateMsg', $Text_UpdateMsg)
	IniWrite($DefaultLanguagePath, 'GuiText', 'Recover', $Text_Recover)
	IniWrite($DefaultLanguagePath, 'GuiText', 'RecoverMsg', $Text_RecoverMsg)
	IniWrite($DefaultLanguagePath, 'GuiText', 'SelectConnectedAP', $Text_SelectConnectedAP)
	IniWrite($DefaultLanguagePath, 'GuiText', 'VistumblerHome', $Text_VistumblerHome)
	IniWrite($DefaultLanguagePath, 'GuiText', 'VistumblerForum', $Text_VistumblerForum)
	IniWrite($DefaultLanguagePath, 'GuiText', 'VistumblerWiki', $Text_VistumblerWiki)
	IniWrite($DefaultLanguagePath, 'GuiText', 'CheckForUpdates', $Text_CheckForUpdates)
	IniWrite($DefaultLanguagePath, 'GuiText', 'SelectWhatToCopy', $Text_SelectWhatToCopy)
	IniWrite($DefaultLanguagePath, 'GuiText', 'Default', $Text_Default)
	IniWrite($DefaultLanguagePath, 'GuiText', 'PlayMidiSounds', $Text_PlayMidiSounds)
	IniWrite($DefaultLanguagePath, 'GuiText', 'Interface', $Text_Interface)
	IniWrite($DefaultLanguagePath, 'GuiText', 'LanguageCode', $Text_LanguageCode)
	IniWrite($DefaultLanguagePath, 'GuiText', 'AutoCheckUpdates', $Text_AutoCheckUpdates)
	IniWrite($DefaultLanguagePath, 'GuiText', 'CheckBetaUpdates', $Text_CheckBetaUpdates)
	IniWrite($DefaultLanguagePath, 'GuiText', 'GuessSearchwords', $Text_GuessSearchwords)
	IniWrite($DefaultLanguagePath, 'GuiText', 'Help', $Text_Help)
	IniWrite($DefaultLanguagePath, 'GuiText', 'ErrorScanningNetsh', $Text_ErrorScanningNetsh)
	IniWrite($DefaultLanguagePath, 'GuiText', 'GpsErrorBufferEmpty', $Text_GpsErrorBufferEmpty)
	IniWrite($DefaultLanguagePath, 'GuiText', 'GpsErrorStopped', $Text_GpsErrorStopped)
	IniWrite($DefaultLanguagePath, 'GuiText', 'ShowSignalDB', $Text_ShowSignalDB)
	IniWrite($DefaultLanguagePath, 'GuiText', 'SortingList', $Text_SortingList)
	IniWrite($DefaultLanguagePath, 'GuiText', 'Loading', $Text_Loading)
	IniWrite($DefaultLanguagePath, 'GuiText', 'MapOpenNetworks', $Text_MapOpenNetworks)
	IniWrite($DefaultLanguagePath, 'GuiText', 'MapWepNetworks', $Text_MapWepNetworks)
	IniWrite($DefaultLanguagePath, 'GuiText', 'MapSecureNetworks', $Text_MapSecureNetworks)
	IniWrite($DefaultLanguagePath, 'GuiText', 'DrawTrack', $Text_DrawTrack)
	IniWrite($DefaultLanguagePath, 'GuiText', 'UseLocalImages', $Text_UseLocalImages)
	IniWrite($DefaultLanguagePath, 'GuiText', 'MIDI', $Text_MIDI)
	IniWrite($DefaultLanguagePath, 'GuiText', 'MidiInstrumentNumber', $Text_MidiInstrumentNumber)
	IniWrite($DefaultLanguagePath, 'GuiText', 'MidiPlayTime', $Text_MidiPlayTime)
	IniWrite($DefaultLanguagePath, 'GuiText', 'SpeakRefreshTime', $Text_SpeakRefreshTime)
	IniWrite($DefaultLanguagePath, 'GuiText', 'Information', $Text_Information)
	IniWrite($DefaultLanguagePath, 'GuiText', 'AddedGuessedSearchwords', $Text_AddedGuessedSearchwords)
	IniWrite($DefaultLanguagePath, 'GuiText', 'SortingTreeview', $Text_SortingTreeview)
	IniWrite($DefaultLanguagePath, 'GuiText', 'Recovering', $Text_Recovering)
	IniWrite($DefaultLanguagePath, 'GuiText', 'ErrorOpeningGpsPort', $Text_ErrorOpeningGpsPort)
	IniWrite($DefaultLanguagePath, 'GuiText', 'SecondsSinceGpsUpdate', $Text_SecondsSinceGpsUpdate)
	IniWrite($DefaultLanguagePath, 'GuiText', 'SavingGID', $Text_SavingGID)
	IniWrite($DefaultLanguagePath, 'GuiText', 'SavingHistID', $Text_SavingHistID)
	IniWrite($DefaultLanguagePath, 'GuiText', 'NoUpdates', $Text_NoUpdates)
	IniWrite($DefaultLanguagePath, 'GuiText', 'NoActiveApFound', $Text_NoActiveApFound)
	IniWrite($DefaultLanguagePath, 'GuiText', 'VistumblerDonate', $Text_VistumblerDonate)
	IniWrite($DefaultLanguagePath, 'GuiText', 'VistumblerStore', $Text_VistumblerStore)
	IniWrite($DefaultLanguagePath, 'GuiText', 'SupportVistumbler', $Text_SupportVistumbler)
	IniWrite($DefaultLanguagePath, 'GuiText', 'UseNativeWifiMsg', $Text_UseNativeWifiMsg)
	IniWrite($DefaultLanguagePath, 'GuiText', 'UseNativeWifiXpExtMsg', $Text_UseNativeWifiXpExtMsg)
	IniWrite($DefaultLanguagePath, 'GuiText', 'FilterMsg', $Text_FilterMsg)
	IniWrite($DefaultLanguagePath, 'GuiText', 'SetFilters', $Text_SetFilters)
	IniWrite($DefaultLanguagePath, 'GuiText', 'Filtered', $Text_Filtered)
	IniWrite($DefaultLanguagePath, 'GuiText', 'Filters', $Text_Filters)
	IniWrite($DefaultLanguagePath, 'GuiText', 'FilterName', $Text_FilterName)
	IniWrite($DefaultLanguagePath, 'GuiText', 'FilterDesc', $Text_FilterDesc)
	IniWrite($DefaultLanguagePath, 'GuiText', 'FilterAddEdit', $Text_FilterAddEdit)
	IniWrite($DefaultLanguagePath, 'GuiText', 'NoAdaptersFound', $Text_NoAdaptersFound)
	IniWrite($DefaultLanguagePath, 'GuiText', 'RecoveringMDB', $Text_RecoveringMDB)
	IniWrite($DefaultLanguagePath, 'GuiText', 'FixingGpsTableDates', $Text_FixingGpsTableDates)
	IniWrite($DefaultLanguagePath, 'GuiText', 'FixingGpsTableTimes', $Text_FixingGpsTableTimes)
	IniWrite($DefaultLanguagePath, 'GuiText', 'FixingHistTableDates', $Text_FixingHistTableDates)
	IniWrite($DefaultLanguagePath, 'GuiText', 'VistumblerNeedsToRestart', $Text_VistumblerNeedsToRestart)
	IniWrite($DefaultLanguagePath, 'GuiText', 'AddingApsIntoList', $Text_AddingApsIntoList)
	IniWrite($DefaultLanguagePath, 'GuiText', 'GoogleEarthDoesNotExist', $Text_GoogleEarthDoesNotExist)
	IniWrite($DefaultLanguagePath, 'GuiText', 'AutoKmlIsNotStarted', $Text_AutoKmlIsNotStarted)
	IniWrite($DefaultLanguagePath, 'GuiText', 'UseKernel32', $Text_UseKernel32)
	IniWrite($DefaultLanguagePath, 'GuiText', 'UnableToGuessSearchwords', $Text_UnableToGuessSearchwords)
	IniWrite($DefaultLanguagePath, 'GuiText', 'SelectedAP', $Text_SelectedAP)
	IniWrite($DefaultLanguagePath, 'GuiText', 'AllAPs', $Text_AllAPs)
	IniWrite($DefaultLanguagePath, 'GuiText', 'FilteredAPs', $Text_FilteredAPs)
	IniWrite($DefaultLanguagePath, 'GuiText', 'ImportFolder', $Text_ImportFolder)
	IniWrite($DefaultLanguagePath, 'GuiText', 'DeleteSelected', $Text_DeleteSelected)
	IniWrite($DefaultLanguagePath, 'GuiText', 'RecoverSelected', $Text_RecoverSelected)
	IniWrite($DefaultLanguagePath, 'GuiText', 'NewSession', $Text_NewSession)
	IniWrite($DefaultLanguagePath, 'GuiText', 'Size', $Text_Size)
	IniWrite($DefaultLanguagePath, 'GuiText', 'NoMdbSelected', $Text_NoMdbSelected)
	IniWrite($DefaultLanguagePath, 'GuiText', 'LocateInWiFiDB', $Text_LocateInWiFiDB)
	IniWrite($DefaultLanguagePath, 'GuiText', 'AutoWiFiDbGpsLocate', $Text_AutoWiFiDbGpsLocate)
	IniWrite($DefaultLanguagePath, 'GuiText', 'AutoWiFiDbUploadAps', $Text_AutoWiFiDbUploadAps)
	IniWrite($DefaultLanguagePath, 'GuiText', 'AutoSelectConnectedAP', $Text_AutoSelectConnectedAP)
	IniWrite($DefaultLanguagePath, 'GuiText', 'AutoSelectHighSigAP', $Text_AutoSelectHighSignal)
	IniWrite($DefaultLanguagePath, 'GuiText', 'Experimental', $Text_Experimental)
	IniWrite($DefaultLanguagePath, 'GuiText', 'Color', $Text_Color)
	IniWrite($DefaultLanguagePath, 'GuiText', 'AddRemFilters', $Text_AddRemFilters)
	IniWrite($DefaultLanguagePath, 'GuiText', 'NoFilterSelected', $Text_NoFilterSelected)
	IniWrite($DefaultLanguagePath, 'GuiText', 'AddFilter', $Text_AddFilter)
	IniWrite($DefaultLanguagePath, 'GuiText', 'EditFilter', $Text_EditFilter)
	IniWrite($DefaultLanguagePath, 'GuiText', 'DeleteFilter', $Text_DeleteFilter)
	IniWrite($DefaultLanguagePath, 'GuiText', 'TimeBeforeMarkedDead', $Text_TimeBeforeMarkedDead)
	IniWrite($DefaultLanguagePath, 'GuiText', 'FilterNameRequired', $Text_FilterNameRequired)
	IniWrite($DefaultLanguagePath, 'GuiText', 'UpdateManufacturers', $Text_UpdateManufacturers)
	IniWrite($DefaultLanguagePath, 'GuiText', 'FixHistSignals', $Text_FixHistSignals)
	IniWrite($DefaultLanguagePath, 'GuiText', 'VistumblerFile', $Text_VistumblerFile)
	IniWrite($DefaultLanguagePath, 'GuiText', 'DetailedFile', $Text_DetailedCsvFile)
	IniWrite($DefaultLanguagePath, 'GuiText', 'SummaryFile', $Text_SummaryCsvFile)
	IniWrite($DefaultLanguagePath, 'GuiText', 'NetstumblerTxtFile', $Text_NetstumblerTxtFile)
	IniWrite($DefaultLanguagePath, 'GuiText', 'WardriveDb3File', $Text_WardriveDb3File)
	IniWrite($DefaultLanguagePath, 'GuiText', 'AutoScanApsOnLaunch', $Text_AutoScanApsOnLaunch)
	IniWrite($DefaultLanguagePath, 'GuiText', 'RefreshInterfaces', $Text_RefreshInterfaces)
	IniWrite($DefaultLanguagePath, 'GuiText', 'Sound', $Text_Sound)
	IniWrite($DefaultLanguagePath, 'GuiText', 'OncePerLoop', $Text_OncePerLoop)
	IniWrite($DefaultLanguagePath, 'GuiText', 'OncePerAP', $Text_OncePerAP)
	IniWrite($DefaultLanguagePath, 'GuiText', 'OncePerAPwSound', $Text_OncePerAPwSound)
	IniWrite($DefaultLanguagePath, 'GuiText', 'WifiDB', $Text_WifiDB)
	IniWrite($DefaultLanguagePath, 'GuiText', 'Warning', $Text_Warning)
	IniWrite($DefaultLanguagePath, 'GuiText', 'WifiDBLocateWarning', $Text_WifiDBLocateWarning)
	IniWrite($DefaultLanguagePath, 'GuiText', 'WifiDBAutoUploadWarning', $Text_WifiDBAutoUploadWarning)
	IniWrite($DefaultLanguagePath, 'GuiText', 'WifiDBOpenLiveAPWebpage', $Text_WifiDBOpenLiveAPWebpage)
	IniWrite($DefaultLanguagePath, 'GuiText', 'WifiDBOpenMainWebpage', $Text_WifiDBOpenMainWebpage)
	IniWrite($DefaultLanguagePath, 'GuiText', 'FilePath', $Text_FilePath)
	IniWrite($DefaultLanguagePath, 'GuiText', 'CameraName', $Text_CameraName)
	IniWrite($DefaultLanguagePath, 'GuiText', 'CameraURL', $Text_CameraURL)
	IniWrite($DefaultLanguagePath, 'GuiText', 'Cameras', $Text_Cameras)
	IniWrite($DefaultLanguagePath, 'GuiText', 'AddCamera', $Text_AddCamera)
	IniWrite($DefaultLanguagePath, 'GuiText', 'RemoveCamera', $Text_RemoveCamera)
	IniWrite($DefaultLanguagePath, 'GuiText', 'EditCamera', $Text_EditCamera)
	IniWrite($DefaultLanguagePath, 'GuiText', 'DownloadImages', $Text_DownloadImages)
	IniWrite($DefaultLanguagePath, 'GuiText', 'EnableCamTriggerScript', $Text_EnableCamTriggerScript)
	IniWrite($DefaultLanguagePath, 'GuiText', 'CameraTriggerScript', $Text_CameraTriggerScript)
	IniWrite($DefaultLanguagePath, 'GuiText', 'CameraTriggerScriptTypes', $Text_CameraTriggerScriptTypes)
	IniWrite($DefaultLanguagePath, 'GuiText', 'SetCameras', $Text_SetCameras)
	IniWrite($DefaultLanguagePath, 'GuiText', 'UpdateUpdaterMsg', $Text_UpdateUpdaterMsg)
	IniWrite($DefaultLanguagePath, 'GuiText', 'UseRssiInGraphs', $Text_UseRssiInGraphs)
	IniWrite($DefaultLanguagePath, 'GuiText', '2400ChannelGraph', $Text_2400ChannelGraph)
	IniWrite($DefaultLanguagePath, 'GuiText', '5000ChannelGraph', $Text_5000ChannelGraph)
	IniWrite($DefaultLanguagePath, 'GuiText', 'UpdateGeolocations', $Text_UpdateGeolocations)
	IniWrite($DefaultLanguagePath, 'GuiText', 'ShowGpsPositionMap', $Text_ShowGpsPositionMap)
	IniWrite($DefaultLanguagePath, 'GuiText', 'ShowGpsSignalMap', $Text_ShowGpsSignalMap)
	IniWrite($DefaultLanguagePath, 'GuiText', 'UseRssiSignalValue', $Text_UseRssiSignalValue)
	IniWrite($DefaultLanguagePath, 'GuiText', 'UseCircleToShowSigStength', $Text_UseCircleToShowSigStength)
	IniWrite($DefaultLanguagePath, 'GuiText', 'ShowGpsRangeMap', $Text_ShowGpsRangeMap)
	IniWrite($DefaultLanguagePath, 'GuiText', 'ShowGpsTack', $Text_ShowGpsTack)
	IniWrite($DefaultLanguagePath, 'GuiText', 'Line', $Text_Line)
	IniWrite($DefaultLanguagePath, 'GuiText', 'Total', $Text_Total)
	IniWrite($DefaultLanguagePath, 'GuiText', 'WifiDB_Upload_Discliamer', $Text_WifiDB_Upload_Discliamer)
	IniWrite($DefaultLanguagePath, 'GuiText', 'UserInformation', $Text_UserInformation)
	IniWrite($DefaultLanguagePath, 'GuiText', 'WifiDB_Username', $Text_WifiDB_Username)
	IniWrite($DefaultLanguagePath, 'GuiText', 'WifiDB_Api_Key', $Text_WifiDB_Api_Key)
	IniWrite($DefaultLanguagePath, 'GuiText', 'OtherUsers', $Text_OtherUsers)
	IniWrite($DefaultLanguagePath, 'GuiText', 'FileType', $Text_FileType)
	IniWrite($DefaultLanguagePath, 'GuiText', 'VistumblerVSZ', $Text_VistumblerVSZ)
	IniWrite($DefaultLanguagePath, 'GuiText', 'VistumblerVS1', $Text_VistumblerVS1)
	IniWrite($DefaultLanguagePath, 'GuiText', 'VistumblerCSV', $Text_VistumblerCSV)
	IniWrite($DefaultLanguagePath, 'GuiText', 'UploadInformation', $Text_UploadInformation)
	IniWrite($DefaultLanguagePath, 'GuiText', 'Title', $Text_Title)
	IniWrite($DefaultLanguagePath, 'GuiText', 'Notes', $Text_Notes)
	IniWrite($DefaultLanguagePath, 'GuiText', 'UploadApsToWifidb', $Text_UploadApsToWifidb)
	IniWrite($DefaultLanguagePath, 'GuiText', 'UploadingApsToWifidb', $Text_UploadingApsToWifidb)
	IniWrite($DefaultLanguagePath, 'GuiText', 'GeoNamesInfo', $Text_GeoNamesInfo)
	IniWrite($DefaultLanguagePath, 'GuiText', 'FindApInWifidb', $Text_FindApInWifidb)
	IniWrite($DefaultLanguagePath, 'GuiText', 'GpsDisconnect', $Text_GpsDisconnect)
	IniWrite($DefaultLanguagePath, 'GuiText', 'GpsReset', $Text_GpsReset)
	IniWrite($DefaultLanguagePath, 'GuiText', 'APs', $Text_APs)
	IniWrite($DefaultLanguagePath, 'GuiText', 'MaxSignal', $Text_MaxSignal)
	IniWrite($DefaultLanguagePath, 'GuiText', 'DisassociationSignal', $Text_DisassociationSignal)
	IniWrite($DefaultLanguagePath, 'GuiText', 'SaveDirectories', $Text_SaveDirectories)
	IniWrite($DefaultLanguagePath, 'GuiText', 'AutoSaveAndClearAfterNumberofAPs', $Text_AutoSaveAndClearAfterNumberofAPs)
	IniWrite($DefaultLanguagePath, 'GuiText', 'AutoSaveandClearAfterTime', $Text_AutoSaveandClearAfterTime)
	IniWrite($DefaultLanguagePath, 'GuiText', 'PlaySoundWhenSaving', $Text_PlaySoundWhenSaving)
	IniWrite($DefaultLanguagePath, 'GuiText', 'MinimalGuiMode', $Text_MinimalGuiMode)
	IniWrite($DefaultLanguagePath, 'GuiText', 'AutoScrollToBottom', $Text_AutoScrollToBottom)
	IniWrite($DefaultLanguagePath, 'GuiText', 'ListviewBatchInsertMode', $Text_ListviewBatchInsertMode)
EndFunc   ;==>_WriteINI

;-------------------------------------------------------------------------------------------------------------------------------
;                                                       VISTUMBLER OPEN FUNCTIONS
;-------------------------------------------------------------------------------------------------------------------------------

Func LoadList()
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, 'LoadList()') ;#Debug Display
	_LoadListGUI()
EndFunc   ;==>LoadList

Func _ExtractVSZ($vsz_file)
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_ExtractVSZ()') ;#Debug Display
	$vsz_temp_file = $TmpDir & 'data.zip'
	$vs1_file = $TmpDir & 'data.vs1'
	If FileExists($vsz_temp_file) Then FileDelete($vsz_temp_file)
	If FileExists($vs1_file) Then FileDelete($vs1_file)
	FileCopy($vsz_file, $vsz_temp_file)
	_Zip_Unzip($vsz_temp_file, 'data.vs1', $TmpDir)
	FileDelete($vsz_temp_file)
	Return ($vs1_file)
EndFunc   ;==>_ExtractVSZ

Func _LoadFolder()
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_LoadFolder()') ;#Debug Display
	$FoundFiles = 0
	$LoadFolder = FileSelectFolder($Text_ImportFolder & "(VS1/VSZ)", "")
	If Not @error Then
		$vs1files = _FileListToArray($LoadFolder, '*.vs1', 1);Find all files in the folder that end in .vs1
		If IsArray($vs1files) Then
			For $b = 1 To $vs1files[0]
				GUICtrlSetData($msgdisplay, $Text_Loading & " - " & $b & "/" & $vs1files[0] & " (" & $LoadFolder & "\" & $vs1files[$b] & ")")
				_LoadListGUI($LoadFolder & "\" & $vs1files[$b])
				_ImportClose()
			Next
			$FoundFiles = 1
		EndIf
		$vszfiles = _FileListToArray($LoadFolder, '*.vsz', 1);Find all files in the folder that end in .vsz
		If IsArray($vszfiles) Then
			For $b = 1 To $vszfiles[0]
				GUICtrlSetData($msgdisplay, $Text_Loading & " - " & $b & "/" & $vszfiles[0] & " (" & $LoadFolder & "\" & $vszfiles[$b] & ")")
				_LoadListGUI($LoadFolder & "\" & $vszfiles[$b])
				_ImportClose()
			Next
			$FoundFiles = 1
		EndIf
	EndIf
	If $FoundFiles = 0 Then
		MsgBox(0, $Text_Error, "No VS1 or VSZ files found")
	Else
		MsgBox(0, $Text_Information, $Text_Done)
	EndIf
EndFunc   ;==>_LoadFolder

Func _LoadListGUI($imfile1 = "")
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_LoadListGUI()') ;#Debug Display
	GUISetState(@SW_MINIMIZE, $Vistumbler)

	$GUI_Import = GUICreate(StringReplace($Text_Import, "&", ""), 501, 245, -1, -1)
	GUISetBkColor($BackgroundColor)
	$vistumblerfileinput = GUICtrlCreateInput($imfile1, 8, 10, 377, 21)
	$browse1 = GUICtrlCreateButton($Text_Browse, 392, 8, 97, 25, $WS_GROUP)
	$RadVis = GUICtrlCreateRadio($Text_VistumblerFile & ' (VS1, VSZ)', 10, 40, 240, 20)
	GUICtrlSetState($RadVis, $GUI_CHECKED)
	$RadCsv = GUICtrlCreateRadio($Text_DetailedCsvFile & ' (CSV)', 10, 60, 240, 20)
	$RadNs = GUICtrlCreateRadio($Text_NetstumblerTxtFile & ' (TXT, NS1)', 255, 40, 240, 20)
	$RadWD = GUICtrlCreateRadio($Text_WardriveDb3File & ' (DB3)', 255, 60, 240, 20)
	$NsOk = GUICtrlCreateButton($Text_Ok, 95, 95, 150, 25, $WS_GROUP)
	$NsCancel = GUICtrlCreateButton($Text_Close, 255, 95, 150, 25, $WS_GROUP)
	$progressbar = GUICtrlCreateProgress(10, 135, 480, 20)
	$percentlabel = GUICtrlCreateLabel($Text_Progress & ': ' & $Text_Ready, 10, 165, 230, 20)
	$linetotal = GUICtrlCreateLabel($Text_LineTotal & ':', 10, 190, 250, 20)
	$newlines = GUICtrlCreateLabel($Text_NewAPs & ':', 10, 215, 230, 20)

	$minutes = GUICtrlCreateLabel($Text_Minutes & ':', 230, 165, 270, 20)
	$linemin = GUICtrlCreateLabel($Text_LinesMin & ':', 230, 190, 270, 35)
	$estimatedtime = GUICtrlCreateLabel($Text_EstimatedTimeRemaining & ':', 230, 215, 270, 35)
	GUISetState(@SW_SHOW)

	GUICtrlSetOnEvent($browse1, "_ImportFileBrowse")
	GUICtrlSetOnEvent($NsOk, "_ImportOk")
	GUICtrlSetOnEvent($NsCancel, "_ImportClose")
	GUISetOnEvent($GUI_EVENT_CLOSE, '_ImportClose')
	If $imfile1 <> '' Then _ImportOk()
EndFunc   ;==>_LoadListGUI

Func _ImportFileBrowse()
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_ImportFileBrowse()') ;#Debug Display
	If GUICtrlRead($RadVis) = 1 Then
		$file = FileOpenDialog($Text_VistumblerFile, $SaveDir, $Text_VistumblerFile & ' (*.vs1;*.vsz;*.txt)', 1)
		If Not @error Then GUICtrlSetData($vistumblerfileinput, $file)
	ElseIf GUICtrlRead($RadCsv) = 1 Then
		$file = FileOpenDialog($Text_VistumblerFile, $SaveDir, $Text_DetailedCsvFile & ' (*.csv)', 1)
		If Not @error Then GUICtrlSetData($vistumblerfileinput, $file)
	ElseIf GUICtrlRead($RadNs) = 1 Then
		$file = FileOpenDialog($Text_VistumblerFile, $SaveDir, $Text_NetstumblerTxtFile & ' (*.txt;*.ns1)', 1)
		If Not @error Then GUICtrlSetData($vistumblerfileinput, $file)
	ElseIf GUICtrlRead($RadWD) = 1 Then
		$file = FileOpenDialog($Text_VistumblerFile, $SaveDir, "Wardrive-android file" & ' (*.db3)', 1)
		If Not @error Then GUICtrlSetData($vistumblerfileinput, $file)
	EndIf
EndFunc   ;==>_ImportFileBrowse

Func _ImportClose()
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_ImportClose()') ;#Debug Display
	GUIDelete($GUI_Import)
	GUISetState(@SW_RESTORE, $Vistumbler)
EndFunc   ;==>_ImportClose

Func _ImportOk()
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_ImportOk()') ;#Debug Display
	GUICtrlSetData($percentlabel, $Text_Progress & ': ' & $Text_Loading)
	$UpdateTimer = TimerInit()
	$MemReleaseTimer = TimerInit()
	$loadfile = GUICtrlRead($vistumblerfileinput)
	$loadfileMD5 = _MD5ForFile($loadfile)

	$query = "SELECT MD5 FROM LoadedFiles WHERE MD5='" & $loadfileMD5 & "'"
	$MD5MatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
	$FoundMD5Match = UBound($MD5MatchArray) - 1

	If $FoundMD5Match <> 0 Then
		GUICtrlSetData($percentlabel, $Text_Progress & ': ' & 'This file has already been imported')
	Else
		GUICtrlSetState($NsOk, $GUI_DISABLE)
		If GUICtrlRead($RadVis) = 1 Then
			If StringUpper(StringRight($loadfile, 4)) = '.VSZ' Then
				$TempVS1 = _ExtractVSZ($loadfile)
				_ImportVS1($TempVS1)
				FileDelete($TempVS1)
			Else
				_ImportVS1($loadfile)
			EndIf
		ElseIf GUICtrlRead($RadCsv) = 1 Then
			_ImportCSV($loadfile)
		ElseIf GUICtrlRead($RadNs) = 1 Then
			_ImportNS1($loadfile)
		ElseIf GUICtrlRead($RadWD) = 1 Then
			_ImportWardriveDb3($loadfile)
		EndIf
		$min = (TimerDiff($begintime) / 60000) ;convert from miniseconds to minutes
		GUICtrlSetData($minutes, $Text_Minutes & ': ' & Round($min, 1))
		If $MinimalGuiMode = 0 Then
			GUICtrlSetData($percentlabel, $Text_Progress & ': ' & $Text_AddingApsIntoList)
			_UpdateListview(1)
			;Update Labels and Manufacturers
			_UpdateListMacLabels()
		EndIf
		$min = (TimerDiff($begintime) / 60000) ;convert from miniseconds to minutes
		GUICtrlSetData($minutes, $Text_Minutes & ': ' & Round($min, 1))
		GUICtrlSetData($progressbar, 100)
		GUICtrlSetState($NsOk, $GUI_ENABLE)
		If Not BitAND($closebtn, $BST_PUSHED) = $BST_PUSHED Then _AddRecord($ManuDB, "LoadedFiles", $DB_OBJ, $loadfile & '|' & $loadfileMD5)
		GUICtrlSetData($percentlabel, $Text_Progress & ': ' & $Text_Done)
	EndIf
EndFunc   ;==>_ImportOk

Func _ImportVS1($VS1file)
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_ImportVS1()') ;#Debug Display
	_CreateTable($VistumblerDB, 'TempGpsIDMatchTabel', $DB_OBJ)
	_CreatMultipleFields($VistumblerDB, 'TempGpsIDMatchTabel', $DB_OBJ, 'OldGpsID INTEGER|NewGpsID INTEGER')
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
				ConsoleWrite($loadlist[0] & @CRLF)
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
					$TempGidMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
					$FoundTempGidMatch = UBound($TempGidMatchArray) - 1
					If $FoundTempGidMatch = 0 Then
						$query = "SELECT TOP 1 GPSID FROM GPS WHERE Latitude = '" & $LoadLat & "' And Longitude = '" & $LoadLon & "' And NumOfSats = '" & $LoadSat & "' And Date1 = '" & $LoadDate & "' And Time1 = '" & $LoadTime & "'"
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
						$query = "SELECT TOP 1 GPSID FROM GPS WHERE Latitude = '" & $LoadLat & "' And Longitude = '" & $LoadLon & "' And NumOfSats = '" & $LoadSat & "' And Date1 = '" & $LoadDate & "' And Time1 = '" & $LoadTime & "'"
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
							$query = "SELECT TOP 1 NewGpsID FROM TempGpsIDMatchTabel WHERE OldGpsID=" & $ImpGID
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
					$query = "SELECT  TOP 1 GPSID FROM GPS WHERE Latitude = '" & $LoadLatitude & "' And Longitude = '" & $LoadLongitude & "' And Date1 = '" & $LoadFirstActive_Date & "' And Time1 = '" & $LoadFirstActive_Time & "'"
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
					$query = "SELECT  TOP 1 GPSID FROM GPS WHERE Latitude = '" & $LoadLatitude & "' And Longitude = '" & $LoadLongitude & "' And Date1 = '" & $LoadLastActive_Date & "' And Time1 = '" & $LoadLastActive_Time & "'"
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
				GUICtrlSetData($estimatedtime, $Text_EstimatedTimeRemaining & ': ' & _DecToMinSec(Round(($totallines / Round($currentline / $min, 1)) - $min, 1)) & "/" & _DecToMinSec(Round($totallines / Round($currentline / $min, 1), 1)))
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
	$query = "DELETE * FROM TempGpsIDMatchTabel"
	_ExecuteMDB($VistumblerDB, $DB_OBJ, $query)
	_DropTable($VistumblerDB, 'TempGpsIDMatchTabel', $DB_OBJ)
EndFunc   ;==>_ImportVS1

Func _ImportCSV($CSVfile)
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_ImportCSV()') ;#Debug Display
	$vistumblerfile = FileOpen($CSVfile, 0)
	If $vistumblerfile <> -1 Then
		$begintime = TimerInit()
		$currentline = 1
		$AddAP = 0
		$AddGID = 0
		;Start Importing File
		$CSVArray = _ParseCSV($CSVfile, ',|', '"')
		$iSize = UBound($CSVArray) - 1
		$iCol = UBound($CSVArray, 2)
		If $iCol = 23 Then ;Import Vistumbler Detailed CSV v1
			For $lc = 1 To $iSize
				$s = $CSVArray[$lc][0]
				$r = $CSVArray[$lc][1]

				$ImpSSID = $CSVArray[$lc][0]
				If StringLeft($ImpSSID, 1) = '"' And StringRight($ImpSSID, 1) = '"' Then $ImpSSID = StringTrimLeft(StringTrimRight($ImpSSID, 1), 1)
				$ImpBSSID = $CSVArray[$lc][1]
				$ImpMANU = $CSVArray[$lc][2]
				If StringLeft($ImpMANU, 1) = '"' And StringRight($ImpMANU, 1) = '"' Then $ImpMANU = StringTrimLeft(StringTrimRight($ImpMANU, 1), 1)
				$ImpSig = $CSVArray[$lc][3]
				$ImpRSSI = _SignalPercentToDb($ImpSig)
				$ImpAUTH = $CSVArray[$lc][4]
				$ImpENCR = $CSVArray[$lc][5]
				$ImpRAD = $CSVArray[$lc][6]
				$ImpCHAN = $CSVArray[$lc][7]
				$ImpBTX = $CSVArray[$lc][8]
				$ImpOTX = $CSVArray[$lc][9]
				$ImpNET = $CSVArray[$lc][10]
				$ImpLAB = $CSVArray[$lc][11]
				If StringLeft($ImpLAB, 1) = '"' And StringRight($ImpLAB, 1) = '"' Then $ImpLAB = StringTrimLeft(StringTrimRight($ImpLAB, 1), 1)
				$ImpLat = _Format_GPS_DDD_to_DMM($CSVArray[$lc][12], "N", "S")
				$ImpLon = _Format_GPS_DDD_to_DMM($CSVArray[$lc][13], "E", "W")
				$ImpSat = $CSVArray[$lc][14]
				$ImpHDOP = $CSVArray[$lc][15]
				$ImpAlt = $CSVArray[$lc][16]
				$ImpGeo = $CSVArray[$lc][17]
				$ImpSpeedKMH = $CSVArray[$lc][18]
				$ImpSpeedMPH = $CSVArray[$lc][19]
				$ImpTrackAngle = $CSVArray[$lc][20]
				$ImpDate = $CSVArray[$lc][21]
				$ImpTime = $CSVArray[$lc][22]


				$query = "SELECT GPSID FROM GPS WHERE Latitude = '" & $ImpLat & "' And Longitude = '" & $ImpLon & "' And NumOfSats = '" & $ImpSat & "' And Date1 = '" & $ImpDate & "' And Time1 = '" & $ImpTime & "'"
				$GpsMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
				$FoundGpsMatch = UBound($GpsMatchArray) - 1
				If $FoundGpsMatch = 0 Then
					$AddGID += 1
					$GPS_ID += 1
					_AddRecord($VistumblerDB, "GPS", $DB_OBJ, $GPS_ID & '|' & $ImpLat & '|' & $ImpLon & '|' & $ImpSat & '|' & $ImpHDOP & '|' & $ImpAlt & '|' & $ImpGeo & '|' & $ImpSpeedKMH & '|' & $ImpSpeedMPH & '|' & $ImpTrackAngle & '|' & $ImpDate & '|' & $ImpTime)
					$ImpGID = $GPS_ID
				ElseIf $FoundGpsMatch = 1 Then
					$ImpGID = $GpsMatchArray[1][1]
				EndIf

				$NewApAdded = _AddApData(0, $ImpGID, $ImpBSSID, $ImpSSID, $ImpCHAN, $ImpAUTH, $ImpENCR, $ImpNET, $ImpRAD, $ImpBTX, $ImpOTX, $ImpSig, $ImpRSSI)
				If $NewApAdded <> 0 Then $AddAP += 1

				If TimerDiff($UpdateTimer) > 600 Or ($currentline = $iSize) Then
					$min = (TimerDiff($begintime) / 60000) ;convert from miniseconds to minutes
					$percent = ($currentline / $iSize) * 100
					GUICtrlSetData($progressbar, $percent)
					GUICtrlSetData($percentlabel, $Text_Progress & ': ' & Round($percent, 1))
					GUICtrlSetData($linemin, $Text_LinesMin & ': ' & Round($currentline / $min, 1))
					GUICtrlSetData($newlines, $Text_NewAPs & ': ' & $AddAP & ' - ' & $Text_NewGIDs & ':' & $AddGID)
					GUICtrlSetData($minutes, $Text_Minutes & ': ' & Round($min, 1))
					GUICtrlSetData($linetotal, $Text_LineTotal & ': ' & $currentline & "/" & $iSize)
					GUICtrlSetData($estimatedtime, $Text_EstimatedTimeRemaining & ': ' & Round(($iSize / Round($currentline / $min, 1)) - $min, 1) & "/" & Round($iSize / Round($currentline / $min, 1), 1))
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
		ElseIf $iCol = 26 Then ;Import Vistumbler Detailed CSV v2
			For $lc = 1 To $iSize
				$s = $CSVArray[$lc][0]
				$r = $CSVArray[$lc][1]

				$ImpSSID = $CSVArray[$lc][0]
				If StringLeft($ImpSSID, 1) = '"' And StringRight($ImpSSID, 1) = '"' Then $ImpSSID = StringTrimLeft(StringTrimRight($ImpSSID, 1), 1)
				$ImpBSSID = $CSVArray[$lc][1]
				$ImpMANU = $CSVArray[$lc][2]
				If StringLeft($ImpMANU, 1) = '"' And StringRight($ImpMANU, 1) = '"' Then $ImpMANU = StringTrimLeft(StringTrimRight($ImpMANU, 1), 1)
				$ImpSig = $CSVArray[$lc][3]
				;$ImpHighSig = $CSVArray[$lc][4]
				$ImpRSSI = $CSVArray[$lc][5]
				;$ImpHighRSSI = $CSVArray[$lc][6]
				$ImpAUTH = $CSVArray[$lc][7]
				$ImpENCR = $CSVArray[$lc][8]
				$ImpRAD = $CSVArray[$lc][9]
				$ImpCHAN = $CSVArray[$lc][10]
				$ImpBTX = $CSVArray[$lc][11]
				If StringLeft($ImpBTX, 1) = '"' And StringRight($ImpBTX, 1) = '"' Then $ImpBTX = StringTrimLeft(StringTrimRight($ImpBTX, 1), 1)
				$ImpOTX = $CSVArray[$lc][12]
				If StringLeft($ImpOTX, 1) = '"' And StringRight($ImpOTX, 1) = '"' Then $ImpOTX = StringTrimLeft(StringTrimRight($ImpOTX, 1), 1)
				$ImpNET = $CSVArray[$lc][13]
				$ImpLAB = $CSVArray[$lc][14]
				If StringLeft($ImpLAB, 1) = '"' And StringRight($ImpLAB, 1) = '"' Then $ImpLAB = StringTrimLeft(StringTrimRight($ImpLAB, 1), 1)
				$ImpLat = _Format_GPS_DDD_to_DMM($CSVArray[$lc][15], "N", "S")
				$ImpLon = _Format_GPS_DDD_to_DMM($CSVArray[$lc][16], "E", "W")
				$ImpSat = $CSVArray[$lc][17]
				$ImpHDOP = $CSVArray[$lc][18]
				$ImpAlt = $CSVArray[$lc][19]
				$ImpGeo = $CSVArray[$lc][20]
				$ImpSpeedKMH = $CSVArray[$lc][21]
				$ImpSpeedMPH = $CSVArray[$lc][22]
				$ImpTrackAngle = $CSVArray[$lc][23]
				$ImpDate = $CSVArray[$lc][24]
				$ImpTime = $CSVArray[$lc][25]

				$query = "SELECT GPSID FROM GPS WHERE Latitude = '" & $ImpLat & "' And Longitude = '" & $ImpLon & "' And NumOfSats = '" & $ImpSat & "' And Date1 = '" & $ImpDate & "' And Time1 = '" & $ImpTime & "'"
				$GpsMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
				$FoundGpsMatch = UBound($GpsMatchArray) - 1
				If $FoundGpsMatch = 0 Then
					$AddGID += 1
					$GPS_ID += 1
					_AddRecord($VistumblerDB, "GPS", $DB_OBJ, $GPS_ID & '|' & $ImpLat & '|' & $ImpLon & '|' & $ImpSat & '|' & $ImpHDOP & '|' & $ImpAlt & '|' & $ImpGeo & '|' & $ImpSpeedKMH & '|' & $ImpSpeedMPH & '|' & $ImpTrackAngle & '|' & $ImpDate & '|' & $ImpTime)
					$ImpGID = $GPS_ID
				ElseIf $FoundGpsMatch = 1 Then
					$ImpGID = $GpsMatchArray[1][1]
				EndIf

				$NewApAdded = _AddApData(0, $ImpGID, $ImpBSSID, $ImpSSID, $ImpCHAN, $ImpAUTH, $ImpENCR, $ImpNET, $ImpRAD, $ImpBTX, $ImpOTX, $ImpSig, $ImpRSSI)
				If $NewApAdded <> 0 Then $AddAP += 1

				If TimerDiff($UpdateTimer) > 600 Or ($currentline = $iSize) Then
					$min = (TimerDiff($begintime) / 60000) ;convert from miniseconds to minutes
					$percent = ($currentline / $iSize) * 100
					GUICtrlSetData($progressbar, $percent)
					GUICtrlSetData($percentlabel, $Text_Progress & ': ' & Round($percent, 1))
					GUICtrlSetData($linemin, $Text_LinesMin & ': ' & Round($currentline / $min, 1))
					GUICtrlSetData($newlines, $Text_NewAPs & ': ' & $AddAP & ' - ' & $Text_NewGIDs & ':' & $AddGID)
					GUICtrlSetData($minutes, $Text_Minutes & ': ' & Round($min, 1))
					GUICtrlSetData($linetotal, $Text_LineTotal & ': ' & $currentline & "/" & $iSize)
					GUICtrlSetData($estimatedtime, $Text_EstimatedTimeRemaining & ': ' & Round(($iSize / Round($currentline / $min, 1)) - $min, 1) & "/" & Round($iSize / Round($currentline / $min, 1), 1))
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
		ElseIf $iCol = 16 Or $iCol = 18 Then ;Import Vistumbler Summary CSV
			For $lc = 1 To $iSize
				$ImpSSID = $CSVArray[$lc][0]
				If StringLeft($ImpSSID, 1) = '"' And StringRight($ImpSSID, 1) = '"' Then $ImpSSID = StringTrimLeft(StringTrimRight($ImpSSID, 1), 1)
				$ImpBSSID = $CSVArray[$lc][1]
				$ImpMANU = $CSVArray[$lc][2]
				If StringLeft($ImpMANU, 1) = '"' And StringRight($ImpMANU, 1) = '"' Then $ImpMANU = StringTrimLeft(StringTrimRight($ImpMANU, 1), 1)
				$ImpHighSig = $CSVArray[$lc][3]
				$ImpRSSI = _SignalPercentToDb($ImpHighSig)
				$ImpAUTH = $CSVArray[$lc][4]
				$ImpENCR = $CSVArray[$lc][5]
				$ImpRAD = $CSVArray[$lc][6]
				$ImpCHAN = $CSVArray[$lc][7]
				$ImpLat = _Format_GPS_DDD_to_DMM($CSVArray[$lc][8], "N", "S")
				$ImpLon = _Format_GPS_DDD_to_DMM($CSVArray[$lc][9], "E", "W")
				$ImpBTX = $CSVArray[$lc][10]
				$ImpOTX = $CSVArray[$lc][11]
				$ImpFirstDateTime = $CSVArray[$lc][12]
				$ImpLastDateTime = $CSVArray[$lc][13]
				$ImpNET = $CSVArray[$lc][14]
				$ImpLAB = $CSVArray[$lc][15]
				If StringLeft($ImpLAB, 1) = '"' And StringRight($ImpLAB, 1) = '"' Then $ImpLAB = StringTrimLeft(StringTrimRight($ImpLAB, 1), 1)
				$ImpSat = "00"
				If $iCol = 18 Then ;If this is a newer summery csv, use the new RSSI and Signal values
					$ImpHighSig = $CSVArray[$lc][16]
					$ImpRSSI = $CSVArray[$lc][17]
				EndIf

				$tsplit = StringSplit($ImpFirstDateTime, ' ')
				$LoadFirstActive_Date = $tsplit[1]
				$LoadFirstActive_Time = $tsplit[2]

				$tsplit = StringSplit($ImpLastDateTime, ' ')
				$LoadLastActive_Date = $tsplit[1]
				$LoadLastActive_Time = $tsplit[2]

				;Check If First GPS Information is Already in DB, If it is get the GpsID, If not add it and get its GpsID
				$query = "SELECT GPSID FROM GPS WHERE Latitude = '" & $ImpLat & "' And Longitude = '" & $ImpLon & "' And Date1 = '" & $LoadFirstActive_Date & "' And Time1 = '" & $LoadFirstActive_Time & "'"
				$GpsMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
				$FoundGpsMatch = UBound($GpsMatchArray) - 1
				If $FoundGpsMatch = 0 Then
					$AddGID += 1
					$GPS_ID += 1
					_AddRecord($VistumblerDB, "GPS", $DB_OBJ, $GPS_ID & '|' & $ImpLat & '|' & $ImpLon & '|' & $ImpSat & '|0|0|0|0|0|0|' & $LoadFirstActive_Date & '|' & $LoadFirstActive_Time)
					$LoadGID = $GPS_ID
				Else
					$LoadGID = $GpsMatchArray[1][1]
				EndIf
				;Add First AP Info to DB, Listview, and Treeview
				$NewApAdded = _AddApData(0, $LoadGID, $ImpBSSID, $ImpSSID, $ImpCHAN, $ImpAUTH, $ImpENCR, $ImpNET, $ImpRAD, $ImpBTX, $ImpOTX, $ImpHighSig, $ImpRSSI)
				If $NewApAdded <> 0 Then $AddAP += 1
				;Check If Last GPS Information is Already in DB, If it is get the GpsID, If not add it and get its GpsID
				$query = "SELECT GPSID FROM GPS WHERE Latitude = '" & $ImpLat & "' And Longitude = '" & $ImpLon & "' And Date1 = '" & $LoadLastActive_Date & "' And Time1 = '" & $LoadLastActive_Time & "'"
				$GpsMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
				$FoundGpsMatch = UBound($GpsMatchArray) - 1
				If $FoundGpsMatch = 0 Then
					$AddGID += 1
					$GPS_ID += 1
					_AddRecord($VistumblerDB, "GPS", $DB_OBJ, $GPS_ID & '|' & $ImpLat & '|' & $ImpLon & '|' & $ImpSat & '|0|0|0|0|0|0|' & $LoadLastActive_Date & '|' & $LoadLastActive_Time)
					$LoadGID = $GPS_ID
				Else
					$LoadGID = $GpsMatchArray[1][1]
				EndIf
				;Add Last AP Info to DB, Listview, and Treeview
				$NewApAdded = _AddApData(0, $LoadGID, $ImpBSSID, $ImpSSID, $ImpCHAN, $ImpAUTH, $ImpENCR, $ImpNET, $ImpRAD, $ImpBTX, $ImpOTX, $ImpHighSig, $ImpRSSI)
				If $NewApAdded <> 0 Then $AddAP += 1

				If TimerDiff($UpdateTimer) > 600 Or ($currentline = $iSize) Then
					$min = (TimerDiff($begintime) / 60000) ;convert from miniseconds to minutes
					$percent = ($currentline / $iSize) * 100
					GUICtrlSetData($progressbar, $percent)
					GUICtrlSetData($percentlabel, $Text_Progress & ': ' & Round($percent, 1))
					GUICtrlSetData($linemin, $Text_LinesMin & ': ' & Round($currentline / $min, 1))
					GUICtrlSetData($newlines, $Text_NewAPs & ': ' & $AddAP & ' - ' & $Text_NewGIDs & ':' & $AddGID)
					GUICtrlSetData($minutes, $Text_Minutes & ': ' & Round($min, 1))
					GUICtrlSetData($linetotal, $Text_LineTotal & ': ' & $currentline & "/" & $iSize)
					GUICtrlSetData($estimatedtime, $Text_EstimatedTimeRemaining & ': ' & Round(($iSize / Round($currentline / $min, 1)) - $min, 1) & "/" & Round($iSize / Round($currentline / $min, 1), 1))
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
	EndIf
EndFunc   ;==>_ImportCSV

Func _ImportNS1($NS1file)
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_ImportNS1()') ;#Debug Display
	$netstumblerfile = FileOpen($NS1file, 0)

	If $netstumblerfile <> -1 Then
		;Get Total number of lines
		$totallines = 0
		While 1
			FileReadLine($netstumblerfile)
			If @error = -1 Then ExitLoop
			$totallines += 1
		WEnd
		$begintime = TimerInit()
		$currentline = 1
		$AddAP = 0
		$AddGID = 0
		For $Load = 1 To $totallines
			$linein = FileReadLine($netstumblerfile, $Load);Open Line in file
			If @error = -1 Then ExitLoop
			;ConsoleWrite($linein & @CRLF)
			If StringInStr($linein, "# $DateGMT:") Then $Date = StringTrimLeft($linein, 12);If the date tag is found, set date
			If StringLeft($linein, 1) <> "#" Then ;If the line is not commented out, get AP information
				$array = StringSplit($linein, "	");Seperate AP information
				If $array[0] = 13 Then
					If $linein <> "" And IsArray($array) Then
						;Decode Flags
						$HexIn = Number("0x" & $array[9])
						Global $ESS = False, $nsimploopBSS = False, $WEP = False, $ShortPreAm = False
						If BitAND($HexIn, 0x1) Then $ESS = True
						If BitAND($HexIn, 0x2) Then $nsimploopBSS = True
						If BitAND($HexIn, 0x10) Then $WEP = True
						;Set AP Type based on flags
						$Type = ''
						If $HexIn Then
							If $ESS = True Then $Type &= $SearchWord_Infrastructure
							If $nsimploopBSS = True Then $Type &= $SearchWord_Adhoc
						EndIf
						If $WEP = True Then
							$LoadSecType = 2
							If $UseNativeWifi = 1 Then
								$Encryption = 'WEP'
								$Authentication = 'Open'
							Else
								$Encryption = $SearchWord_Wep
								$Authentication = $SearchWord_Open
							EndIf
						Else
							$LoadSecType = 1
							If $UseNativeWifi = 1 Then
								$Encryption = 'Unencrypted'
								$Authentication = 'Open'
							Else
								$Encryption = $SearchWord_None
								$Authentication = $SearchWord_Open
							EndIf
						EndIf
						;Set other information
						$snrarray1 = StringSplit($array[7], " ")
						$SSID = StringTrimLeft(StringTrimRight($array[3], 2), 2)
						$BSSID = StringUpper(StringTrimLeft(StringTrimRight($array[5], 2), 2))
						$time = StringTrimRight($array[6], 6)
						If StringInStr($time, '.') = 0 Then $time &= '.000'
						$ImpNsSig = $snrarray1[2]
						If $ImpNsSig <> "-32618" Then
							$RSSI = $ImpNsSig - 95 ;Subtact 95 from the wi-scan export's "Sig" number to get the actual rssi (http://www.netstumbler.org/netstumbler/determining-rssi-t11729.html)
							$Signal = _DbToSignalPercent($RSSI)
							$LoadLatitude = _Format_GPS_All_to_DMM(StringReplace($array[1], "N 360.0000000", "N 0.0000000"))
							$LoadLongitude = _Format_GPS_All_to_DMM(StringReplace($array[2], "E 720.0000000", "E 0.0000000"))
							$Channel = $array[13]

							$query = "SELECT GPSID FROM GPS WHERE Latitude = '" & $LoadLatitude & "' And Longitude = '" & $LoadLongitude & "' And Date1 = '" & $Date & "' And Time1 = '" & $time & "'"
							$GpsMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
							$FoundGpsMatch = UBound($GpsMatchArray) - 1
							If $FoundGpsMatch = 0 Then
								$AddGID += 1
								$GPS_ID += 1
								_AddRecord($VistumblerDB, "GPS", $DB_OBJ, $GPS_ID & '|' & $LoadLatitude & '|' & $LoadLongitude & '|00|0|0|0|0|0|0|' & $Date & '|' & $time)
								$LoadGID = $GPS_ID
							ElseIf $FoundGpsMatch = 1 Then
								$LoadGID = $GpsMatchArray[1][1]
							EndIf
							;Add Last AP Info to DB, Listview
							$NewApAdded = _AddApData(0, $LoadGID, $BSSID, $SSID, $Channel, $Authentication, $Encryption, $Type, $Text_Unknown, $Text_Unknown, $Text_Unknown, $Signal, $RSSI)
							If $NewApAdded <> 0 Then $AddAP += 1
						EndIf
					EndIf
				Else
					;ExitLoop
				EndIf
			EndIf

			If TimerDiff($UpdateTimer) > 600 Or ($currentline = $totallines) Then
				$min = (TimerDiff($begintime) / 60000) ;convert from miniseconds to minutes
				$percent = ($currentline / $totallines) * 100
				GUICtrlSetData($progressbar, $percent)
				GUICtrlSetData($percentlabel, $Text_Progress & ': ' & Round($percent, 1))
				GUICtrlSetData($linemin, $Text_LinesMin & ': ' & Round($Load / $min, 1))
				GUICtrlSetData($newlines, $Text_NewAPs & ': ' & $AddAP & ' - ' & $Text_NewGIDs & ':' & $AddGID)
				GUICtrlSetData($minutes, $Text_Minutes & ': ' & Round($min, 1))
				GUICtrlSetData($linetotal, $Text_LineTotal & ': ' & $Load & "/" & $totallines)
				GUICtrlSetData($estimatedtime, $Text_EstimatedTimeRemaining & ': ' & Round(($totallines / Round($Load / $min, 1)) - $min, 1) & "/" & Round($totallines / Round($Load / $min, 1), 1))
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
	FileClose($netstumblerfile)
EndFunc   ;==>_ImportNS1

Func _ImportWardriveDb3($DB3file)
	_SQLite_Startup()
	$WardriveImpDB = _SQLite_Open($DB3file, $SQLITE_OPEN_READWRITE + $SQLITE_OPEN_CREATE, $SQLITE_ENCODING_UTF16)
	_SQLite_Exec($WardriveImpDB, "pragma integrity_check");Speed vs Data security. Speed Wins for now.
	Local $NetworkMatchArray, $iRows, $iColumns, $iRval
	$query = "SELECT bssid, ssid, capabilities, level, frequency, lat, lon, alt, timestamp FROM networks"
	$iRval = _SQLite_GetTable2d($WardriveImpDB, $query, $NetworkMatchArray, $iRows, $iColumns)
	$WardriveAPs = $iRows

	$UpdateTimer = TimerInit()
	$begintime = TimerInit()
	$AddAP = 0
	$AddGID = 0
	For $NewAP = 1 To $WardriveAPs
		$Found_BSSID = StringUpper($NetworkMatchArray[$NewAP][0])
		$Found_SSID = $NetworkMatchArray[$NewAP][1]
		$Found_Capabilities = $NetworkMatchArray[$NewAP][2]
		$Found_RSSI = $NetworkMatchArray[$NewAP][3]
		$Found_Signal = _DbToSignalPercent($Found_RSSI)
		$Found_Frequency = $NetworkMatchArray[$NewAP][4]
		$Found_Lat = _Format_GPS_DDD_to_DMM($NetworkMatchArray[$NewAP][5], "N", "S")
		$Found_Lon = _Format_GPS_DDD_to_DMM($NetworkMatchArray[$NewAP][6], "E", "W")
		$Found_Alt = $NetworkMatchArray[$NewAP][7]
		$Found_TimeStamp = StringTrimRight($NetworkMatchArray[$NewAP][8], 3)

		;Get Authentication and Encrytion from capabilities
		If StringInStr($Found_Capabilities, "WPA2-PSK-CCMP") Or StringInStr($Found_Capabilities, "WPA2-PSK-TKIP+CCMP") Then
			$Found_AUTH = "WPA2-Personal"
			$Found_ENCR = "CCMP"
			$Found_SecType = "3"
		ElseIf StringInStr($Found_Capabilities, "WPA-PSK-CCMP") Or StringInStr($Found_Capabilities, "WPA-PSK-TKIP+CCMP") Then
			$Found_AUTH = "WPA-Personal"
			$Found_ENCR = "CCMP"
			$Found_SecType = "3"
		ElseIf StringInStr($Found_Capabilities, "WPA2-EAP-CCMP") Or StringInStr($Found_Capabilities, "WPA2-EAP-TKIP+CCMP") Then
			$Found_AUTH = "WPA2-Enterprise"
			$Found_ENCR = "CCMP"
			$Found_SecType = "3"
		ElseIf StringInStr($Found_Capabilities, "WPA-EAP-CCMP") Or StringInStr($Found_Capabilities, "WPA-EAP-TKIP+CCMP") Then
			$Found_AUTH = "WPA-Enterprise"
			$Found_ENCR = "CCMP"
			$Found_SecType = "3"
		ElseIf StringInStr($Found_Capabilities, "WPA2-PSK-TKIP") Then
			$Found_AUTH = "WPA2-Personal"
			$Found_ENCR = "TKIP"
			$Found_SecType = "3"
		ElseIf StringInStr($Found_Capabilities, "WPA-PSK-TKIP") Then
			$Found_AUTH = "WPA-Personal"
			$Found_ENCR = "TKIP"
			$Found_SecType = "3"
		ElseIf StringInStr($Found_Capabilities, "WPA2-EAP-TKIP") Then
			$Found_AUTH = "WPA2-Enterprise"
			$Found_ENCR = "TKIP"
			$Found_SecType = "3"
		ElseIf StringInStr($Found_Capabilities, "WPA-EAP-TKIP") Then
			$Found_AUTH = "WPA-Enterprise"
			$Found_ENCR = "TKIP"
			$Found_SecType = "3"
		ElseIf StringInStr($Found_Capabilities, "WEP") Then
			$Found_AUTH = "Open"
			$Found_ENCR = "WEP"
			$Found_SecType = "2"
		Else
			$Found_AUTH = "Open"
			$Found_ENCR = "None"
			$Found_SecType = "1"
		EndIf

		;Get Network Type from capabilities
		If StringInStr($Found_Capabilities, "[IBSS]") Then
			$Found_NETTYPE = "Adhoc"
		Else
			$Found_NETTYPE = "Infrastructure"
		EndIf

		;Get Channel From Frequency
		If $Found_Frequency = "2412" Then
			$Found_CHAN = "001"
		ElseIf $Found_Frequency = "2417" Then
			$Found_CHAN = "002"
		ElseIf $Found_Frequency = "2422" Then
			$Found_CHAN = "003"
		ElseIf $Found_Frequency = "2427" Then
			$Found_CHAN = "004"
		ElseIf $Found_Frequency = "2432" Then
			$Found_CHAN = "005"
		ElseIf $Found_Frequency = "2437" Then
			$Found_CHAN = "006"
		ElseIf $Found_Frequency = "2442" Then
			$Found_CHAN = "007"
		ElseIf $Found_Frequency = "2447" Then
			$Found_CHAN = "008"
		ElseIf $Found_Frequency = "2452" Then
			$Found_CHAN = "009"
		ElseIf $Found_Frequency = "2457" Then
			$Found_CHAN = "010"
		ElseIf $Found_Frequency = "2462" Then
			$Found_CHAN = "011"
		ElseIf $Found_Frequency = "2467" Then
			$Found_CHAN = "012"
		ElseIf $Found_Frequency = "2472" Then
			$Found_CHAN = "013"
		Else
			$Found_CHAN = "Unknown"
		EndIf

		$Found_Date = _StringFormatTime("%Y", $Found_TimeStamp) & "-" & _StringFormatTime("%m", $Found_TimeStamp) & "-" & _StringFormatTime("%d", $Found_TimeStamp)
		$Found_Time = _StringFormatTime("%X", $Found_TimeStamp) & ".000"

		;Add GPS data in Vistumbler DB
		$query = "SELECT GPSID FROM GPS WHERE Latitude = '" & $Found_Lat & "' And Longitude = '" & $Found_Lon & "' And Date1 = '" & $Found_Date & "' And Time1 = '" & $Found_Time & "'"
		$GpsMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
		$FoundGpsMatch = UBound($GpsMatchArray) - 1
		If $FoundGpsMatch = 0 Then
			$AddGID += 1
			$GPS_ID += 1
			;Add GPS ID
			_AddRecord($VistumblerDB, "GPS", $DB_OBJ, $GPS_ID & '|' & $Found_Lat & '|' & $Found_Lon & '|0|0|' & $Found_Alt & '|0|0|0|0|' & $Found_Date & '|' & $Found_Time)
			$NewGpsId = $GPS_ID
		ElseIf $FoundGpsMatch = 1 Then
			$NewGpsId = $GpsMatchArray[1][1]
		EndIf

		;Add AP data into Vistumbler DB
		$NewApAdded = _AddApData(0, $NewGpsId, $Found_BSSID, $Found_SSID, $Found_CHAN, $Found_AUTH, $Found_ENCR, $Found_NETTYPE, "802.11g", "Unknown", "Unknown", $Found_Signal, $Found_RSSI)
		If $NewApAdded <> 0 Then $AddAP += 1

		If TimerDiff($UpdateTimer) > 600 Or ($NewAP = $WardriveAPs) Then
			$min = (TimerDiff($begintime) / 60000) ;convert from miniseconds to minutes
			$percent = ($NewAP / $WardriveAPs) * 100
			GUICtrlSetData($progressbar, $percent)
			GUICtrlSetData($percentlabel, $Text_Progress & ': ' & Round($percent, 1))
			GUICtrlSetData($linemin, $Text_LinesMin & ': ' & Round($Load / $min, 1))
			GUICtrlSetData($newlines, $Text_NewAPs & ': ' & $AddAP & ' - ' & $Text_NewGIDs & ':' & $AddGID)
			GUICtrlSetData($minutes, $Text_Minutes & ': ' & Round($min, 1))
			GUICtrlSetData($linetotal, $Text_LineTotal & ': ' & $NewAP & " / " & $WardriveAPs)
			GUICtrlSetData($estimatedtime, $Text_EstimatedTimeRemaining & ': ' & Round(($WardriveAPs / Round($NewAP / $min, 1)) - $min, 1) & "/" & Round($WardriveAPs / Round($NewAP / $min, 1), 1))
			$UpdateTimer = TimerInit()
		EndIf
	Next
	_SQLite_Close($WardriveImpDB)
	_SQLite_Shutdown()
EndFunc   ;==>_ImportWardriveDb3

;-------------------------------------------------------------------------------------------------------------------------------
;                                                       GOOGLE EARTH SAVE FUNCTIONS
;-------------------------------------------------------------------------------------------------------------------------------

Func SaveToKML()
	SaveToKmlGUI(0)
EndFunc   ;==>SaveToKML

Func _ExportFilteredKML()
	SaveToKmlGUI(1)
EndFunc   ;==>_ExportFilteredKML

Func SaveToKmlGUI($Filter = 0, $SelectedApID = 0)
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, 'SaveToKML()') ;#Debug Display
	Opt("GUIOnEventMode", 0)
	$ExportKMLGUI = GUICreate($Text_ExportToKML, 250, 305)
	GUISetBkColor($BackgroundColor)
	$GUI_ExportKML_PosMap = GUICtrlCreateCheckbox($Text_ShowGpsPositionMap, 15, 15, 240, 15)
	If $MapPos = 1 Then GUICtrlSetState($GUI_ExportKML_PosMap, $GUI_CHECKED)
	$GUI_ExportKML_SigMap = GUICtrlCreateCheckbox($Text_ShowGpsSignalMap, 15, 35, 240, 15)
	If $MapSig = 1 Then GUICtrlSetState($GUI_ExportKML_SigMap, $GUI_CHECKED)
	$GUI_ExportKML_SigUseRSSI = GUICtrlCreateCheckbox($Text_UseRssiSignalValue, 30, 55, 200, 15)
	If $MapSigUseRSSI = 1 Then GUICtrlSetState($GUI_ExportKML_SigUseRSSI, $GUI_CHECKED)
	$GUI_ExportKML_SigCir = GUICtrlCreateCheckbox($Text_UseCircleToShowSigStength, 30, 75, 200, 15)
	GUICtrlCreateLabel($Text_Color & ":", 30, 95, 45, 15)
	$GUI_CirSigMapColor = GUICtrlCreateInput($CirSigMapColor, 75, 95, 75, 15)
	$GUI_CirSigMapColorBrowse = GUICtrlCreateButton($Text_Browse, 160, 92, 75, 20)
	If $MapSigType = 1 Then
		GUICtrlSetState($GUI_ExportKML_SigCir, $GUI_CHECKED)
	Else
		GUICtrlSetState($GUI_CirSigMapColor, $GUI_DISABLE)
		GUICtrlSetState($GUI_CirSigMapColorBrowse, $GUI_DISABLE)
	EndIf
	$GUI_ExportKML_RangeMap = GUICtrlCreateCheckbox($Text_ShowGpsRangeMap, 15, 115, 240, 15)
	GUICtrlCreateLabel($Text_Color & ":", 30, 135, 45, 15)
	$GUI_CirRangeMapColor = GUICtrlCreateInput($CirRangeMapColor, 75, 135, 75, 15)
	$GUI_CirRangeMapColorBrowse = GUICtrlCreateButton($Text_Browse, 160, 132, 75, 20)
	If $MapRange = 1 Then
		GUICtrlSetState($GUI_ExportKML_RangeMap, $GUI_CHECKED)
	Else
		GUICtrlSetState($GUI_CirRangeMapColor, $GUI_DISABLE)
		GUICtrlSetState($GUI_CirRangeMapColorBrowse, $GUI_DISABLE)
	EndIf
	$GUI_ExportKML_DrawTrack = GUICtrlCreateCheckbox($Text_ShowGpsTack, 15, 155, 240, 15)
	GUICtrlCreateLabel($Text_Color & ":", 30, 175, 45, 15)
	$GUI_TrackColor = GUICtrlCreateInput($TrackColor, 75, 175, 75, 15)
	$GUI_TrackColorBrowse = GUICtrlCreateButton($Text_Browse, 160, 172, 75, 20)
	If $ShowTrack = 1 Then
		GUICtrlSetState($GUI_ExportKML_DrawTrack, $GUI_CHECKED)
	Else
		GUICtrlSetState($GUI_TrackColor, $GUI_DISABLE)
		GUICtrlSetState($GUI_TrackColorBrowse, $GUI_DISABLE)
	EndIf
	$GUI_ExportKML_MapOpen = GUICtrlCreateCheckbox($Text_MapOpenNetworks, 15, 195, 240, 15)
	If $MapOpen = 1 Then GUICtrlSetState($GUI_ExportKML_MapOpen, $GUI_CHECKED)
	$GUI_ExportKML_MapWEP = GUICtrlCreateCheckbox($Text_MapWepNetworks, 15, 215, 240, 15)
	If $MapWEP = 1 Then GUICtrlSetState($GUI_ExportKML_MapWEP, $GUI_CHECKED)
	$GUI_ExportKML_MapSec = GUICtrlCreateCheckbox($Text_MapSecureNetworks, 15, 235, 240, 15)
	If $MapSec = 1 Then GUICtrlSetState($GUI_ExportKML_MapSec, $GUI_CHECKED)

	$GUI_ExportKML_UseLocalImages = GUICtrlCreateCheckbox($Text_UseLocalImages, 15, 255, 240, 15)
	If $UseLocalKmlImagesOnExport = 1 Then GUICtrlSetState($GUI_ExportKML_UseLocalImages, $GUI_CHECKED)
	$GUI_ExportKML_OK = GUICtrlCreateButton($Text_Ok, 40, 275, 81, 25, 0)
	$GUI_ExportKML_Cancel = GUICtrlCreateButton($Text_Cancel, 139, 275, 81, 25, 0)
	GUISetState(@SW_SHOW)

	While 1
		$nMsg = GUIGetMsg()
		Switch $nMsg
			Case $GUI_ExportKML_SigCir
				If GUICtrlRead($GUI_ExportKML_SigCir) = 1 Then
					GUICtrlSetState($GUI_CirSigMapColor, $GUI_ENABLE)
					GUICtrlSetState($GUI_CirSigMapColorBrowse, $GUI_ENABLE)
				Else
					GUICtrlSetState($GUI_CirSigMapColor, $GUI_DISABLE)
					GUICtrlSetState($GUI_CirSigMapColorBrowse, $GUI_DISABLE)
				EndIf
			Case $GUI_ExportKML_RangeMap
				If GUICtrlRead($GUI_ExportKML_RangeMap) = 1 Then
					GUICtrlSetState($GUI_CirRangeMapColor, $GUI_ENABLE)
					GUICtrlSetState($GUI_CirRangeMapColorBrowse, $GUI_ENABLE)
				Else
					GUICtrlSetState($GUI_CirRangeMapColor, $GUI_DISABLE)
					GUICtrlSetState($GUI_CirRangeMapColorBrowse, $GUI_DISABLE)
				EndIf
			Case $GUI_ExportKML_DrawTrack
				If GUICtrlRead($GUI_ExportKML_DrawTrack) = 1 Then
					GUICtrlSetState($GUI_TrackColor, $GUI_ENABLE)
					GUICtrlSetState($GUI_TrackColorBrowse, $GUI_ENABLE)
				Else
					GUICtrlSetState($GUI_TrackColor, $GUI_DISABLE)
					GUICtrlSetState($GUI_TrackColorBrowse, $GUI_DISABLE)
				EndIf
			Case $GUI_CirSigMapColorBrowse
				$transparency = StringTrimRight(GUICtrlRead($GUI_CirSigMapColor), 6)
				$color = _ChooseColor(1, '0x' & StringTrimLeft(GUICtrlRead($GUI_CirSigMapColor), 2), 1, $ExportKMLGUI)
				If $color <> -1 Then GUICtrlSetData($GUI_CirSigMapColor, $transparency & StringReplace($color, "0x", ""))
			Case $GUI_CirRangeMapColorBrowse
				$transparency = StringTrimRight(GUICtrlRead($GUI_CirRangeMapColor), 6)
				$color = _ChooseColor(1, '0x' & StringTrimLeft(GUICtrlRead($GUI_CirRangeMapColor), 2), 1, $ExportKMLGUI)
				If $color <> -1 Then GUICtrlSetData($GUI_CirRangeMapColor, $transparency & StringReplace($color, "0x", ""))
			Case $GUI_TrackColorBrowse
				$transparency = StringTrimRight(GUICtrlRead($GUI_TrackColor), 6)
				$color = _ChooseColor(1, '0x' & StringTrimLeft(GUICtrlRead($GUI_TrackColor), 2), 1, $ExportKMLGUI)
				If $color <> -1 Then GUICtrlSetData($GUI_TrackColor, $transparency & StringReplace($color, "0x", ""))
			Case $GUI_EVENT_CLOSE
				GUIDelete($ExportKMLGUI)
				ExitLoop
			Case $GUI_ExportKML_Cancel
				GUIDelete($ExportKMLGUI)
				ExitLoop
			Case $GUI_ExportKML_OK
				Dim $MapPos = 0, $MapSig = 0, $MapRange = 0, $ShowTrack = 0, $MapSigUseRSSI = 0, $MapSigType = 0, $MapOpen = 0, $MapWEP = 0, $MapSec = 0, $UseLocalKmlImagesOnExport = 0
				If GUICtrlRead($GUI_ExportKML_PosMap) = 1 Then $MapPos = 1
				If GUICtrlRead($GUI_ExportKML_SigMap) = 1 Then $MapSig = 1
				If GUICtrlRead($GUI_ExportKML_RangeMap) = 1 Then $MapRange = 1
				If GUICtrlRead($GUI_ExportKML_DrawTrack) = 1 Then $ShowTrack = 1
				If GUICtrlRead($GUI_ExportKML_SigUseRSSI) = 1 Then $MapSigUseRSSI = 1
				If GUICtrlRead($GUI_ExportKML_SigCir) = 1 Then $MapSigType = 1
				If GUICtrlRead($GUI_ExportKML_MapOpen) = 1 Then $MapOpen = 1
				If GUICtrlRead($GUI_ExportKML_MapWEP) = 1 Then $MapWEP = 1
				If GUICtrlRead($GUI_ExportKML_MapSec) = 1 Then $MapSec = 1
				If GUICtrlRead($GUI_ExportKML_UseLocalImages) = 1 Then $UseLocalKmlImagesOnExport = 1
				$TrackColor = GUICtrlRead($GUI_TrackColor)
				$CirSigMapColor = GUICtrlRead($GUI_CirSigMapColor)
				$CirRangeMapColor = GUICtrlRead($GUI_CirRangeMapColor)
				GUIDelete($ExportKMLGUI)
				DirCreate($SaveDirKml)
				$filename = FileSaveDialog("Google Earth Output File", $SaveDirKml, 'Google Earth (*.kml)', '', $ldatetimestamp & '.kml')
				If Not @error Then
					If StringInStr($filename, '.kml') = 0 Then $filename = $filename & '.kml'
					$saved = SaveKML($filename, $UseLocalKmlImagesOnExport, $MapPos, $ShowTrack, $MapSig, $MapRange, $SelectedApID, $Filter, $MapSigType, $MapOpen, $MapWEP, $MapSec, $MapSigUseRSSI)
					If $saved = 1 Then
						MsgBox(0, $Text_Done, $Text_SavedAs & ': "' & $filename & '"')
					Else
						MsgBox(0, $Text_Done, $Text_NoApsWithGps & ' ' & $Text_NoFileSaved)
					EndIf
				EndIf
				ExitLoop
		EndSwitch
	WEnd
	Opt("GUIOnEventMode", 1)
EndFunc   ;==>SaveToKmlGUI

Func SaveKML($savefile, $KmlUseLocalImages = 1, $GpsPosMap = 0, $GpsTrack = 0, $GpsSigMap = 0, $GpsRangeMap = 0, $SelectedApID = 0, $Filter = 0, $SigMapType = 0, $MapOpenAPs = 1, $MapWepAps = 1, $MapSecAps = 1, $UseRSSI = 1)
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, 'SaveKML()') ;#Debug Display
	Local $file_header
	Local $file_data
	Local $file_posdata
	Local $file_sigdata
	Local $file_rangedata
	Local $file_footer
	Local $FoundApWithGps
	Local $NewTimeString

	$file_header = '<?xml version="1.0" encoding="UTF-8"?>' & @CRLF _
			 & '<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">' & @CRLF _
			 & '<Document>' & @CRLF _
			 & '	<description>' & $Script_Name & ' - By ' & $Script_Author & '</description>' & @CRLF _
			 & '	<name>' & $Script_Name & ' ' & $version & '</name>' & @CRLF

	If $GpsPosMap = 1 Then ; Add GPS Position Icon Styles
		$file_header &= '	<Style id="secureStyle">' & @CRLF _
				 & '		<IconStyle>' & @CRLF _
				 & '			<scale>.5</scale>' & @CRLF _
				 & '			<Icon>' & @CRLF
		If $KmlUseLocalImages = 1 Then
			$file_header &= '				<href>' & $ImageDir & 'secure.png</href>' & @CRLF
		Else
			$file_header &= '				<href>http://vistumbler.sourceforge.net/images/program-images/secure.png</href>' & @CRLF
		EndIf
		$file_header &= '			</Icon>' & @CRLF _
				 & '		</IconStyle>' & @CRLF _
				 & '	</Style>' & @CRLF _
				 & '	<Style id="wepStyle">' & @CRLF _
				 & '		<IconStyle>' & @CRLF _
				 & '			<scale>.5</scale>' & @CRLF _
				 & '			<Icon>' & @CRLF
		If $KmlUseLocalImages = 1 Then
			$file_header &= '				<href>' & $ImageDir & 'secure-wep.png</href>' & @CRLF
		Else
			$file_header &= '				<href>http://vistumbler.sourceforge.net/images/program-images/secure-wep.png</href>' & @CRLF
		EndIf
		$file_header &= '			</Icon>' & @CRLF _
				 & '		</IconStyle>' & @CRLF _
				 & '	</Style>' & @CRLF _
				 & '	<Style id="openStyle">' & @CRLF _
				 & '		<IconStyle>' & @CRLF _
				 & '			<scale>.5</scale>' & @CRLF _
				 & '			<Icon>' & @CRLF
		If $KmlUseLocalImages = 1 Then
			$file_header &= '				<href>' & $ImageDir & 'open.png</href>' & @CRLF
		Else
			$file_header &= '				<href>http://vistumbler.sourceforge.net/images/program-images/open.png</href>' & @CRLF
		EndIf
		$file_header &= '			</Icon>' & @CRLF _
				 & '		</IconStyle>' & @CRLF _
				 & '	</Style>' & @CRLF
	EndIf
	If $GpsSigMap = 1 Then ; Add GPS Signal Map Line Styles
		$file_header &= $KmlSignalMapStyles
	EndIf
	If $GpsTrack = 1 Then ; Add GPS Track Line Style
		$file_header &= '	<Style id="Location">' & @CRLF _
				 & '		<LineStyle>' & @CRLF _
				 & '			<color>' & $TrackColor & '</color>' & @CRLF _
				 & '			<width>4</width>' & @CRLF _
				 & '		</LineStyle>' & @CRLF _
				 & '	</Style>' & @CRLF
	EndIf
	If $SigMapType = 1 Then
		$file_header &= '	<Style id="SigCircleColor">' & @CRLF _
				 & '		<LineStyle>' & @CRLF _
				 & '			<color>' & $CirSigMapColor & '</color>' & @CRLF _
				 & '		</LineStyle>' & @CRLF _
				 & '		<PolyStyle>' & @CRLF _
				 & '			<color>ff00ff00</color>' & @CRLF _
				 & '			<outline>0</outline>' & @CRLF _
				 & '		</PolyStyle>' & @CRLF _
				 & '	</Style>' & @CRLF
	EndIf
	If $GpsRangeMap = 1 Then
		$file_header &= '	<Style id="RangeCircleColor">' & @CRLF _
				 & '		<LineStyle>' & @CRLF _
				 & '			<color>' & $CirRangeMapColor & '</color>' & @CRLF _
				 & '		</LineStyle>' & @CRLF _
				 & '		<PolyStyle>' & @CRLF _
				 & '			<color>ff00ff00</color>' & @CRLF _
				 & '			<outline>0</outline>' & @CRLF _
				 & '		</PolyStyle>' & @CRLF _
				 & '	</Style>' & @CRLF
	EndIf

	If $GpsPosMap = 1 Or $GpsSigMap = 1 Or $GpsRangeMap = 1 Then
		If $GpsPosMap = 1 Then $file_posdata &= '	<Folder>' & @CRLF & '		<name>GPS Position Map</name>' & @CRLF
		If $GpsSigMap = 1 Then $file_sigdata &= '	<Folder>' & @CRLF & '		<name>GPS Signal Map</name>' & @CRLF
		If $GpsRangeMap = 1 Then $file_rangedata &= '	<Folder>' & @CRLF & '		<name>GPS Range Map</name>' & @CRLF
		If $MapOpenAPs = 1 Then
			If $Filter = 1 Then
				If StringInStr($AddQuery, "WHERE") Then
					$query = $AddQuery & " And SECTYPE=1 And HighGpsHistId<>0 ORDER BY SSID"
				Else
					$query = $AddQuery & " WHERE SECTYPE=1 And HighGpsHistId<>0 ORDER BY SSID"
				EndIf
			ElseIf $SelectedApID <> 0 Then
				$query = "SELECT ApID FROM AP WHERE ApID=" & $SelectedApID & " And SECTYPE=1 And HighGpsHistId<>0 ORDER BY SSID"
			Else
				$query = "SELECT ApID FROM AP WHERE SECTYPE=1 And HighGpsHistId<>0 ORDER BY SSID"
			EndIf
			$ApMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
			$FoundApMatch = UBound($ApMatchArray) - 1
			If $FoundApMatch <> 0 Then
				$FoundApWithGps = 1
				If $GpsPosMap = 1 Then $file_posdata &= '		<Folder>' & @CRLF & '			<name>Open Access Points</name>' & @CRLF
				If $GpsSigMap = 1 Then $file_sigdata &= '		<Folder>' & @CRLF & '			<name>Open Access Points</name>' & @CRLF
				If $GpsRangeMap = 1 Then $file_rangedata &= '		<Folder>' & @CRLF & '			<name>Open Access Points</name>' & @CRLF
				For $exp = 1 To $FoundApMatch
					GUICtrlSetData($msgdisplay, 'Saving Open AP ' & $exp & '/' & $FoundApMatch)
					$ExpApID = $ApMatchArray[$exp][1]
					If $GpsPosMap = 1 Then $file_posdata &= _KmlPosMapAPID($ExpApID)
					If $GpsSigMap = 1 And $SigMapType = 0 Then $file_sigdata &= _KmlSignalMapAPID($ExpApID, $UseRSSI)
					If $GpsSigMap = 1 And $SigMapType = 1 Then $file_sigdata &= _KmlCircleSignalMapAPID($ExpApID, $UseRSSI)
					If $GpsRangeMap = 1 Then $file_rangedata &= _KmlCircleDistanceMapAPID($ExpApID)
				Next
				If $GpsPosMap = 1 Then $file_posdata &= '		</Folder>' & @CRLF
				If $GpsSigMap = 1 Then $file_sigdata &= '		</Folder>' & @CRLF
				If $GpsRangeMap = 1 Then $file_rangedata &= '		</Folder>' & @CRLF
			EndIf
		EndIf
		If $MapWepAps = 1 Then
			If $Filter = 1 Then
				If StringInStr($AddQuery, "WHERE") Then
					$query = $AddQuery & " And SECTYPE=2 And HighGpsHistId<>0 ORDER BY SSID"
				Else
					$query = $AddQuery & " WHERE SECTYPE=2 And HighGpsHistId<>0 ORDER BY SSID"
				EndIf
			ElseIf $SelectedApID <> 0 Then
				$query = "SELECT ApID FROM AP WHERE ApID=" & $SelectedApID & " And SECTYPE=2 And HighGpsHistId<>0 ORDER BY SSID"
			Else
				$query = "SELECT ApID FROM AP WHERE SECTYPE=2 And HighGpsHistId<>0 ORDER BY SSID"
			EndIf
			$ApMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
			$FoundApMatch = UBound($ApMatchArray) - 1
			If $FoundApMatch <> 0 Then
				$FoundApWithGps = 1
				If $GpsPosMap = 1 Then $file_posdata &= '		<Folder>' & @CRLF & '			<name>WEP Access Points</name>' & @CRLF
				If $GpsSigMap = 1 Then $file_sigdata &= '		<Folder>' & @CRLF & '			<name>WEP Access Points</name>' & @CRLF
				If $GpsRangeMap = 1 Then $file_rangedata &= '		<Folder>' & @CRLF & '			<name>WEP Access Points</name>' & @CRLF
				For $exp = 1 To $FoundApMatch
					GUICtrlSetData($msgdisplay, 'Saving WEP AP ' & $exp & '/' & $FoundApMatch)
					$ExpApID = $ApMatchArray[$exp][1]
					If $GpsPosMap = 1 Then $file_posdata &= _KmlPosMapAPID($ExpApID)
					If $GpsSigMap = 1 And $SigMapType = 0 Then $file_sigdata &= _KmlSignalMapAPID($ExpApID, $UseRSSI)
					If $GpsSigMap = 1 And $SigMapType = 1 Then $file_sigdata &= _KmlCircleSignalMapAPID($ExpApID, $UseRSSI)
					If $GpsRangeMap = 1 Then $file_rangedata &= _KmlCircleDistanceMapAPID($ExpApID)
				Next
				If $GpsPosMap = 1 Then $file_posdata &= '		</Folder>' & @CRLF
				If $GpsSigMap = 1 Then $file_sigdata &= '		</Folder>' & @CRLF
				If $GpsRangeMap = 1 Then $file_rangedata &= '		</Folder>' & @CRLF
			EndIf
		EndIf
		If $MapSecAps = 1 Then
			If $Filter = 1 Then
				If StringInStr($AddQuery, "WHERE") Then
					$query = $AddQuery & " And SECTYPE=3 And HighGpsHistId<>0 ORDER BY SSID"
				Else
					$query = $AddQuery & " WHERE SECTYPE=3 And HighGpsHistId<>0 ORDER BY SSID"
				EndIf
			ElseIf $SelectedApID <> 0 Then
				$query = "SELECT ApID FROM AP WHERE ApID=" & $SelectedApID & " And SECTYPE=3 And HighGpsHistId<>0 ORDER BY SSID"
			Else
				$query = "SELECT ApID FROM AP WHERE SECTYPE=3 And HighGpsHistId<>0 ORDER BY SSID"
			EndIf
			$ApMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
			$FoundApMatch = UBound($ApMatchArray) - 1
			If $FoundApMatch <> 0 Then
				$FoundApWithGps = 1
				If $GpsPosMap = 1 Then $file_posdata &= '		<Folder>' & @CRLF & '			<name>Secure Access Points</name>' & @CRLF
				If $GpsSigMap = 1 Then $file_sigdata &= '		<Folder>' & @CRLF & '			<name>Secure Access Points</name>' & @CRLF
				If $GpsRangeMap = 1 Then $file_rangedata &= '		<Folder>' & @CRLF & '			<name>Secure Access Points</name>' & @CRLF
				For $exp = 1 To $FoundApMatch
					GUICtrlSetData($msgdisplay, 'Saving Secure AP ' & $exp & '/' & $FoundApMatch)
					$ExpApID = $ApMatchArray[$exp][1]
					If $GpsPosMap = 1 Then $file_posdata &= _KmlPosMapAPID($ExpApID)
					If $GpsSigMap = 1 And $SigMapType = 0 Then $file_sigdata &= _KmlSignalMapAPID($ExpApID, $UseRSSI)
					If $GpsSigMap = 1 And $SigMapType = 1 Then $file_sigdata &= _KmlCircleSignalMapAPID($ExpApID, $UseRSSI)
					If $GpsRangeMap = 1 Then $file_rangedata &= _KmlCircleDistanceMapAPID($ExpApID)
				Next
				If $GpsPosMap = 1 Then $file_posdata &= '		</Folder>' & @CRLF
				If $GpsSigMap = 1 Then $file_sigdata &= '		</Folder>' & @CRLF
				If $GpsRangeMap = 1 Then $file_rangedata &= '		</Folder>' & @CRLF
			EndIf
		EndIf
		If $GpsPosMap = 1 Then $file_posdata &= '	</Folder>' & @CRLF
		If $GpsSigMap = 1 Then $file_sigdata &= '	</Folder>' & @CRLF
		If $GpsRangeMap = 1 Then $file_rangedata &= '	</Folder>' & @CRLF
		If $GpsPosMap = 1 Then $file_data &= $file_posdata
		If $GpsSigMap = 1 Then $file_data &= $file_sigdata
		If $GpsRangeMap = 1 Then $file_data &= $file_rangedata
	EndIf

	If $GpsTrack = 1 Then
		$query = "SELECT Latitude, Longitude, Date1, Time1 FROM GPS WHERE Latitude <> 'N 0000.0000' And Longitude <> 'E 0000.0000' ORDER BY Date1, Time1"
		$GpsMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
		$FoundGpsMatch = UBound($GpsMatchArray) - 1
		If $FoundGpsMatch <> 0 Then

			$file_data &= '	<Folder>' & @CRLF _
					 & '		<name>GPS Track</name>' & @CRLF _
					 & '		<Placemark>' & @CRLF _
					 & '			<name>GPS Track</name>' & @CRLF _
					 & '			<styleUrl>#Location</styleUrl>' & @CRLF _
					 & '			<LineString>' & @CRLF _
					 & '				<extrude>1</extrude>' & @CRLF _
					 & '				<tessellate>1</tessellate>' & @CRLF _
					 & '				<coordinates>' & @CRLF
			For $exp = 1 To $FoundGpsMatch
				GUICtrlSetData($msgdisplay, 'Saving Gps Position ' & $exp & '/' & $FoundGpsMatch)
				$ExpLat = _Format_GPS_DMM_to_DDD($GpsMatchArray[$exp][1])
				$ExpLon = _Format_GPS_DMM_to_DDD($GpsMatchArray[$exp][2])
				$ExpDate = StringReplace($GpsMatchArray[$exp][3], '-', '')
				$ExpTime = $GpsMatchArray[$exp][4]
				$dts = StringSplit($ExpTime, ":") ;Split time so it can be converted to seconds
				$ExpTime = ($dts[1] * 3600) + ($dts[2] * 60) + $dts[3] ;In seconds
				$LastTimeString = $NewTimeString
				$NewTimeString = $ExpDate & StringFormat("%05i", $ExpTime)
				If $LastTimeString = '' Then $LastTimeString = $NewTimeString
				If ($NewTimeString - $LastTimeString) > 180 And $FoundApWithGps = 1 Then
					$file_data &= '				</coordinates>' & @CRLF _
							 & '			</LineString>' & @CRLF _
							 & '		</Placemark>' & @CRLF _
							 & '		<Placemark>' & @CRLF _
							 & '			<name>GPS Track</name>' & @CRLF _
							 & '			<styleUrl>#Location</styleUrl>' & @CRLF _
							 & '			<LineString>' & @CRLF _
							 & '				<extrude>1</extrude>' & @CRLF _
							 & '				<tessellate>1</tessellate>' & @CRLF _
							 & '				<coordinates>' & @CRLF
				EndIf
				If $ExpLat <> 'N 0.0000000' And $ExpLon <> 'E 0.0000000' Then
					$FoundApWithGps = 1
					$file_data &= '					' & StringReplace(StringReplace(StringReplace($ExpLon, 'W', '-'), 'E', ''), ' ', '') & ',' & StringReplace(StringReplace(StringReplace($ExpLat, 'S', '-'), 'N', ''), ' ', '') & ',0' & @CRLF
				EndIf
			Next
			$file_data &= '				</coordinates>' & @CRLF _
					 & '			</LineString>' & @CRLF _
					 & '		</Placemark>' & @CRLF _
					 & '	</Folder>' & @CRLF
		EndIf
	EndIf
	$file_footer &= '</Document>' & @CRLF _
			 & '</kml>' & @CRLF

	If $FoundApWithGps = 1 Then
		$savefile = FileOpen($savefile, 128 + 2);Open in UTF-8 write mode
		FileWrite($savefile, $file_header & $file_data & $file_footer)
		FileClose($savefile)
		Return (1)
	Else
		Return (0)
	EndIf
EndFunc   ;==>SaveKML

Func _KmlSignalMapSelectedAP()
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_KmlHeatmapSelected()') ;#Debug Display
	Local $file_header
	Local $file_data
	Local $file_footer
	$Selected = _GUICtrlListView_GetNextItem($ListviewAPs); find what AP is selected in the list. returns -1 is nothing is selected
	If $Selected = -1 Then
		MsgBox(0, $Text_Error, $Text_NoApSelected)
	Else
		$query = "SELECT ApID, SSID FROM AP WHERE ListRow=" & $Selected
		$ListRowMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
		$ExpApID = $ListRowMatchArray[1][1]
		SaveToKmlGUI(0, $ExpApID)
	EndIf
EndFunc   ;==>_KmlSignalMapSelectedAP

Func _KmlPosMapAPID($APID)
	Local $file_data
	$query = "SELECT SSID, BSSID, NETTYPE, RADTYPE, CHAN, AUTH, ENCR, BTX, OTX, MANU, LABEL, HighGpsHistID, FirstHistID, LastHistID, SecType FROM AP WHERE ApID=" & $APID
	$ApMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
	$ExpSSID = StringReplace(StringReplace(StringReplace($ApMatchArray[1][1], '&', ''), '>', ''), '<', '')
	$ExpBSSID = $ApMatchArray[1][2]
	$ExpNET = $ApMatchArray[1][3]
	$ExpRAD = $ApMatchArray[1][4]
	$ExpCHAN = $ApMatchArray[1][5]
	$ExpAUTH = $ApMatchArray[1][6]
	$ExpENCR = $ApMatchArray[1][7]
	$ExpBTX = $ApMatchArray[1][8]
	$ExpOTX = $ApMatchArray[1][9]
	$ExpMANU = $ApMatchArray[1][10]
	$ExpLAB = $ApMatchArray[1][11]
	$ExpHighGpsHistID = $ApMatchArray[1][12]
	$ExpFirstID = $ApMatchArray[1][13]
	$ExpLastID = $ApMatchArray[1][14]
	$ExpSECTYPE = $ApMatchArray[1][15]

	;Get Gps ID of HighGpsHistId
	$query = "SELECT GpsID FROM Hist Where HistID=" & $ExpHighGpsHistID
	$HistMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
	$ExpGID = $HistMatchArray[1][1]
	;Get Latitude and Longitude
	$query = "SELECT Latitude, Longitude FROM GPS WHERE GpsId=" & $ExpGID
	$GpsMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
	$ExpLat = _Format_GPS_DMM_to_DDD($GpsMatchArray[1][1])
	$ExpLon = _Format_GPS_DMM_to_DDD($GpsMatchArray[1][2])
	If $ExpLat <> 'N 0.0000000' And $ExpLon <> 'E 0.0000000' Then
		;Get First Seen
		$query = "SELECT GpsId FROM Hist Where HistID=" & $ExpFirstID
		$HistMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
		$ExpGID = $HistMatchArray[1][1]
		$query = "SELECT Date1, Time1 FROM GPS WHERE GpsId=" & $ExpGID
		$GpsMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
		$ExpFirstDateTime = $GpsMatchArray[1][1] & ' ' & $GpsMatchArray[1][2]
		;Get Last Seen
		$query = "SELECT GpsId FROM Hist Where HistID=" & $ExpLastID
		$HistMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
		$ExpGID = $HistMatchArray[1][1]
		$query = "SELECT Date1, Time1 FROM GPS WHERE GpsId=" & $ExpGID
		$GpsMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
		$ExpLastDateTime = $GpsMatchArray[1][1] & ' ' & $GpsMatchArray[1][2]

		$file_data &= '			<Placemark>' & @CRLF _
				 & '				<name></name>' & @CRLF _
				 & '				<description><![CDATA[<b>' & $Column_Names_SSID & ': </b>' & $ExpSSID & '<br /><b>' & $Column_Names_BSSID & ': </b>' & $ExpBSSID & '<br /><b>' & $Column_Names_NetworkType & ': </b>' & $ExpNET & '<br /><b>' & $Column_Names_RadioType & ': </b>' & $ExpRAD & '<br /><b>' & $Column_Names_Channel & ': </b>' & $ExpCHAN & '<br /><b>' & $Column_Names_Authentication & ': </b>' & $ExpAUTH & '<br /><b>' & $Column_Names_Encryption & ': </b>' & $ExpENCR & '<br /><b>' & $Column_Names_BasicTransferRates & ': </b>' & $ExpBTX & '<br /><b>' & $Column_Names_OtherTransferRates & ': </b>' & $ExpOTX & '<br /><b>' & $Column_Names_FirstActive & ': </b>' & $ExpFirstDateTime & '<br /><b>' & $Column_Names_LastActive & ': </b>' & $ExpLastDateTime & '<br /><b>' & $Column_Names_Latitude & ': </b>' & $ExpLat & '<br /><b>' & $Column_Names_Longitude & ': </b>' & $ExpLon & '<br /><b>' & $Column_Names_MANUF & ': </b>' & $ExpMANU & '<br />]]></description>'
		If $ExpSECTYPE = 1 Then
			$file_data &= '				<styleUrl>#openStyle</styleUrl>' & @CRLF
		ElseIf $ExpSECTYPE = 2 Then
			$file_data &= '				<styleUrl>#wepStyle</styleUrl>' & @CRLF
		ElseIf $ExpSECTYPE = 3 Then
			$file_data &= '				<styleUrl>#secureStyle</styleUrl>' & @CRLF
		EndIf
		$file_data &= '				<Point>' & @CRLF _
				 & '					<coordinates>' & StringReplace(StringReplace(StringReplace($ExpLon, 'W', '-'), 'E', ''), ' ', '') & ',' & StringReplace(StringReplace(StringReplace($ExpLat, 'S', '-'), 'N', ''), ' ', '') & ',0</coordinates>' & @CRLF _
				 & '				</Point>' & @CRLF _
				 & '			</Placemark>' & @CRLF
	EndIf
	Return ($file_data)
EndFunc   ;==>_KmlPosMapAPID

Func _KmlSignalMapAPID($APID, $UseRSSI = 1)
	Local $file
	Local $SigData = 0
	Local $SigStrengthLevel = 0
	Local $ExpString
	Local $NewTimeString
	$query = "SELECT SSID, BSSID FROM AP WHERE ApID=" & $APID
	$ApIDMatch = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
	$ExpSSID = StringReplace(StringReplace(StringReplace($ApIDMatch[1][1], '&', ''), '>', ''), '<', '')
	$ExpBSSID = $ApIDMatch[1][2]
	$query = "SELECT GpsID, Signal, RSSI, Date1, Time1 FROM Hist Where ApID=" & $APID & " And Signal<>0 ORDER BY Date1, Time1 ASC"
	$GpsIDArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
	$GpsIDMatch = UBound($GpsIDArray) - 1
	If $GpsIDMatch <> 0 Then
		For $e = 1 To $GpsIDMatch
			$ExpGID = $GpsIDArray[$e][1]
			$ExpSig = $GpsIDArray[$e][2]
			$ExpRSSI = $GpsIDArray[$e][3]
			$ExpDate = StringReplace($GpsIDArray[$e][4], '-', '')
			$ExpTime = $GpsIDArray[$e][5]
			$dts = StringSplit($ExpTime, ":") ;Split time so it can be converted to seconds
			$ExpTime = ($dts[1] * 3600) + ($dts[2] * 60) + $dts[3] ;In seconds
			$LastTimeString = $NewTimeString
			$NewTimeString = $ExpDate & StringFormat("%05i", $ExpTime)
			If $LastTimeString = '' Then $LastTimeString = $NewTimeString
			;Get Latidude and logitude
			$query = "SELECT Longitude, Latitude, Alt FROM GPS Where GpsID=" & $ExpGID
			$GpsArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
			$ExpLon = StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($GpsArray[1][1]), 'W', '-'), 'E', ''), ' ', '')
			$ExpLat = StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($GpsArray[1][2]), 'S', '-'), 'N', ''), ' ', '')
			$ExpAlt = $GpsArray[1][3]
			If $ExpLon <> '0.0000000' And $ExpLat <> '0.0000000' Then
				If $SigData = 0 Then
					$file &= '	<Folder>' & @CRLF _
							 & '		<name>' & $ExpSSID & ' - ' & $ExpBSSID & '</name>' & @CRLF
				EndIf
				If $LastTimeString = '' Then $LastTimeString = $NewTimeString
				$LastSigStrengthLevel = $SigStrengthLevel
				$LastSigData = $SigData
				$SigData = 1
				If $ExpSig >= 1 And $ExpSig <= 16 Then
					$SigStrengthLevel = 1
					$SigCat = '#SigCat1'
				ElseIf $ExpSig >= 17 And $ExpSig <= 32 Then
					$SigStrengthLevel = 2
					$SigCat = '#SigCat2'
				ElseIf $ExpSig >= 33 And $ExpSig <= 48 Then
					$SigStrengthLevel = 3
					$SigCat = '#SigCat3'
				ElseIf $ExpSig >= 49 And $ExpSig <= 64 Then
					$SigStrengthLevel = 4
					$SigCat = '#SigCat4'
				ElseIf $ExpSig >= 65 And $ExpSig <= 80 Then
					$SigStrengthLevel = 5
					$SigCat = '#SigCat5'
				ElseIf $ExpSig >= 80 And $ExpSig <= 100 Then
					$SigStrengthLevel = 6
					$SigCat = '#SigCat6'
				EndIf
				If $LastSigStrengthLevel <> $SigStrengthLevel Or ($NewTimeString - $LastTimeString) > $SigMapTimeBeforeMarkedDead Or $LastSigData = 0 Then
					If $LastSigData = 1 Then
						$file &= '				</coordinates>' & @CRLF _
								 & '			</LineString>' & @CRLF _
								 & '		</Placemark>' & @CRLF
					EndIf
					$file &= '		<Placemark>' & @CRLF _
							 & '			<styleUrl>' & $SigCat & '</styleUrl>' & @CRLF _
							 & '			<LineString>' & @CRLF _
							 & '				<extrude>1</extrude>' & @CRLF _
							 & '				<tessellate>0</tessellate>' & @CRLF _
							 & '				<altitudeMode>relativeToGround</altitudeMode>' & @CRLF _
							 & '				<coordinates>' & @CRLF
					If $ExpString <> '' And ($NewTimeString - $LastTimeString) <= $SigMapTimeBeforeMarkedDead Then $file &= $ExpString
				EndIf

				If $UseRSSI = 1 Then
					$ExpRSSIAlt = 100 + $ExpRSSI
					$ExpString = '					' & $ExpLon & ',' & $ExpLat & ',' & $ExpRSSIAlt & @CRLF
					;ConsoleWrite($ExpRSSI & ' - ' & $ExpRSSIAlt & @CRLF)
				Else
					$ExpString = '					' & $ExpLon & ',' & $ExpLat & ',' & $ExpSig & @CRLF
				EndIf

				$file &= $ExpString
			EndIf
			If $e = $GpsIDMatch And $SigData = 1 Then
				$file &= '				</coordinates>' & @CRLF _
						 & '			</LineString>' & @CRLF _
						 & '		</Placemark>' & @CRLF _
						 & '	</Folder>' & @CRLF
			EndIf
		Next
	EndIf
	Return ($file)
EndFunc   ;==>_KmlSignalMapAPID

Func _KmlCircleSignalMapAPID($APID, $UseRSSI = 1)
	Local $file
	$query = "SELECT SSID, BSSID, HighGpsHistID FROM AP WHERE ApID=" & $APID
	$ApIDMatch = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
	$ExpSSID = StringReplace(StringReplace(StringReplace($ApIDMatch[1][1], '&', ''), '>', ''), '<', '')
	$ExpBSSID = $ApIDMatch[1][2]
	$ExpHighGpsHistID = $ApIDMatch[1][3]
	If $ExpHighGpsHistID <> '0' Then
		$query = "SELECT Signal, RSSI, GpsID FROM Hist WHERE HistID=" & $ExpHighGpsHistID
		$HistIDArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
		$ExpSig = $HistIDArray[1][1]
		$ExpRSSI = $HistIDArray[1][2]
		$ExpHighGpsID = $HistIDArray[1][3]
		$query = "SELECT Longitude, Latitude FROM GPS Where GpsID=" & $ExpHighGpsID
		$GpsIDArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
		$ExpLon = $GpsIDArray[1][1]
		$ExpLat = $GpsIDArray[1][2]
		$file &= '	<Folder>' & @CRLF _
				 & '		<name>' & $ExpSSID & ' - ' & $ExpBSSID & '</name>' & @CRLF
		If $UseRSSI = 1 Then
			$ExpRSSIAlt = 100 + $ExpRSSI
			$file &= _KmlDrawCircle($ExpLat, $ExpLon, $ExpRSSIAlt, 'SigCircleColor')
		Else
			$file &= _KmlDrawCircle($ExpLat, $ExpLon, $ExpSig, 'SigCircleColor')
		EndIf
		$file &= '	</Folder>' & @CRLF
	EndIf
	Return ($file)
EndFunc   ;==>_KmlCircleSignalMapAPID

Func _KmlCircleDistanceMapAPID($APID)
	Local $file
	Local $ExpDist = 10
	$query = "SELECT SSID, BSSID, HighGpsHistID FROM AP WHERE ApID=" & $APID
	$ApIDMatch = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
	$ExpSSID = StringReplace(StringReplace(StringReplace($ApIDMatch[1][1], '&', ''), '>', ''), '<', '')
	$ExpBSSID = $ApIDMatch[1][2]
	$ExpHighGpsHistID = $ApIDMatch[1][3]
	If $ExpHighGpsHistID <> '0' Then
		$query = "SELECT Signal, GpsID FROM Hist WHERE HistID=" & $ExpHighGpsHistID
		$HistIDArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
		$ExpSig = $HistIDArray[1][1]
		$ExpHighGpsID = $HistIDArray[1][2]
		$query = "SELECT Longitude, Latitude FROM GPS Where GpsID=" & $ExpHighGpsID
		$GpsIDArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
		$ExpLon = $GpsIDArray[1][1]
		$ExpLat = $GpsIDArray[1][2]
		;Find Outside Gps Point
		$query = "SELECT GpsID FROM Hist WHERE ApID=" & $APID
		$HistIDArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
		$HistIDMatch = UBound($HistIDArray) - 1
		If $HistIDMatch <> 0 Then
			For $gid = 1 To $HistIDMatch
				$ExpGpsID = $HistIDArray[$gid][1]
				$query = "SELECT Longitude, Latitude FROM GPS Where GpsID=" & $ExpGpsID
				$GpsIDArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
				$ExpLon2 = $GpsIDArray[1][1]
				$ExpLat2 = $GpsIDArray[1][2]
				If $ExpLat2 <> 'N 0.0000' And $ExpLon2 <> 'E 0.0000' Then
					If $ExpLat2 <> 'N 0000.0000' And $ExpLon2 <> 'E 0000.0000' Then
						$Dist = _KmlDistanceBetweenPoints($ExpLat, $ExpLon, $ExpLat2, $ExpLon2)
						If $Dist > $ExpDist Then $ExpDist = $Dist
					EndIf
				EndIf
			Next
		EndIf
		$file &= '	<Folder>' & @CRLF _
				 & '		<name>' & $ExpSSID & ' - ' & $ExpBSSID & '</name>' & @CRLF
		$file &= _KmlDrawCircle($ExpLat, $ExpLon, $ExpDist, 'RangeCircleColor')
		$file &= '	</Folder>' & @CRLF
	EndIf
	Return ($file)
EndFunc   ;==>_KmlCircleDistanceMapAPID

Func _KmlDistanceBetweenPoints($Lat1, $Lon1, $Lat2, $Lon2)
	$Lat1 = _deg2rad(StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($Lat1), 'S', '-'), 'N', ''), ' ', ''))
	$Lon1 = _deg2rad(StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($Lon1), 'W', '-'), 'E', ''), ' ', ''))
	$Lat2 = _deg2rad(StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($Lat2), 'S', '-'), 'N', ''), ' ', ''))
	$Lon2 = _deg2rad(StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($Lon2), 'W', '-'), 'E', ''), ' ', ''))
	$d = ACos(Sin($Lat1) * Sin($Lat2) + Cos($Lat1) * Cos($Lat2) * Cos($Lon2 - $Lon1)) * 6378137
	Return ($d)
EndFunc   ;==>_KmlDistanceBetweenPoints

Func _KmlDrawCircle($CenterLat, $CenterLon, $Radius, $CirStyle)
	Local $PI = 3.14159265358979
	Local $viewdistance = 10000
	; convert coordinates to radians
	$Lat1 = _deg2rad(StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($CenterLat), 'S', '-'), 'N', ''), ' ', ''))
	$long1 = _deg2rad(StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($CenterLon), 'W', '-'), 'E', ''), ' ', ''))
	$d = $Radius
	$d_rad = $d / 6378137
	;create header
	$file = '<Placemark>' & @CRLF _
			 & '<name>Location</name>' & @CRLF _
			 & '<styleUrl>#' & $CirStyle & '</styleUrl>' & @CRLF _
			 & '<LineString>' & @CRLF _
			 & '<extrude>1</extrude>' & @CRLF _
			 & '<tessellate>1</tessellate>' & @CRLF _
			 & '<coordinates>' & @CRLF
	; loop through the array and write path linestrings
	For $i = 0 To 360
		$radial = _deg2rad($i)
		$lat_rad = ASin(Sin($Lat1) * Cos($d_rad) + Cos($Lat1) * Sin($d_rad) * Cos($radial))
		$dlon_rad = ATan(Sin($radial) * Sin($d_rad) * Cos($Lat1)) / (Cos($d_rad) - Sin($Lat1) * Sin($lat_rad))
		$lon_rad = Mod(($long1 + $dlon_rad + $PI), 2 * $PI) - $PI ; origionally fmod(($long1 + $dlon_rad + $PI), 2 * $PI) - $PI
		$file &= _rad2deg($lon_rad) & ',' & _rad2deg($lat_rad) & ',' & $viewdistance & @CRLF
	Next
	; create footer
	$file &= '</coordinates>' & @CRLF _
			 & '</LineString>' & @CRLF _
			 & '</Placemark>' & @CRLF
	Return ($file)
EndFunc   ;==>_KmlDrawCircle

Func _StartGoogleAutoKmlRefresh()
	$kml = $GoogleEarth_OpenFile
	FileDelete($kml)
	If $AutoKML = 1 Then
		If FileExists($GoogleEarthExe) Then
			$RefAutoKmlGpsTime = Round($AutoKmlGpsTime / 2)
			$RefAutoKmlActiveTime = Round($AutoKmlActiveTime / 2)
			$RefAutoKmlDeadTime = Round($AutoKmlDeadTime / 2)
			$RefAutoKmlTrackTime = Round($AutoKmlTrackTime / 2)
			If $RefAutoKmlGpsTime < 1 Then $RefAutoKmlGpsTime = 1
			If $RefAutoKmlActiveTime < 1 Then $RefAutoKmlActiveTime = 1
			If $RefAutoKmlDeadTime < 1 Then $RefAutoKmlDeadTime = 1
			If $RefAutoKmlTrackTime < 1 Then $RefAutoKmlTrackTime = 1
			$file = '<?xml version="1.0" encoding="UTF-8"?>' & @CRLF _
					 & '<kml xmlns="http://earth.google.com/kml/2.2">' & @CRLF _
					 & '	<Document>' & @CRLF _
					 & '		<name>' & $Script_Name & ' ' & $version & '</name>' & @CRLF
			If $AutoKmlGpsTime <> 0 Then
				$file &= '		<NetworkLink>' & @CRLF _
						 & '			<name>' & $Script_Name & ' GPS Position</name>' & @CRLF
				If $KmlFlyTo = 1 Then $file &= '			<flyToView>1</flyToView>' & @CRLF
				$file &= '			<Url>' & @CRLF _ ;GPS Position
						 & '				<href>' & $GoogleEarth_GpsFile & '</href>' & @CRLF _
						 & '				<refreshMode>onInterval</refreshMode>' & @CRLF _
						 & '				<refreshInterval>' & $RefAutoKmlGpsTime & '</refreshInterval>' & @CRLF _
						 & '			</Url>' & @CRLF _
						 & '		</NetworkLink>' & @CRLF
			EndIf
			If $AutoKmlActiveTime <> 0 Then
				$file &= '		<NetworkLink>' & @CRLF _
						 & '			<name>' & $Script_Name & ' Active APs</name>' & @CRLF _
						 & '			<Url>' & @CRLF _ ;AP List
						 & '				<href>' & $GoogleEarth_ActiveFile & '</href>' & @CRLF _
						 & '				<refreshMode>onInterval</refreshMode>' & @CRLF _
						 & '				<refreshInterval>' & $RefAutoKmlActiveTime & '</refreshInterval>' & @CRLF _
						 & '			</Url>' & @CRLF _
						 & '		</NetworkLink>' & @CRLF
			EndIf
			If $AutoKmlDeadTime <> 0 Then
				$file &= '		<NetworkLink>' & @CRLF _
						 & '			<name>' & $Script_Name & ' Dead APs</name>' & @CRLF _
						 & '			<Url>' & @CRLF _ ;AP List
						 & '				<href>' & $GoogleEarth_DeadFile & '</href>' & @CRLF _
						 & '				<refreshMode>onInterval</refreshMode>' & @CRLF _
						 & '				<refreshInterval>' & $RefAutoKmlDeadTime & '</refreshInterval>' & @CRLF _
						 & '			</Url>' & @CRLF _
						 & '		</NetworkLink>' & @CRLF
			EndIf
			If $AutoKmlTrackTime <> 0 Then
				$file &= '		<NetworkLink>' & @CRLF _
						 & '			<name>GPS Track</name>' & @CRLF _
						 & '			<Url>' & @CRLF _ ;AP List
						 & '				<href>' & $GoogleEarth_TrackFile & '</href>' & @CRLF _
						 & '				<refreshMode>onInterval</refreshMode>' & @CRLF _
						 & '				<refreshInterval>' & $RefAutoKmlTrackTime & '</refreshInterval>' & @CRLF _
						 & '			</Url>' & @CRLF _
						 & '		</NetworkLink>' & @CRLF
			EndIf
			$file &= '	</Document>' & @CRLF _
					 & '</kml>' & @CRLF
			FileWrite($kml, $file)
			If Not @error Then
				If $AutoKmlGpsTime <> 0 Then _AutoKmlGpsFile($GoogleEarth_GpsFile)
				If $AutoKmlDeadTime <> 0 Then Run(@ComSpec & " /C " & FileGetShortName(@ScriptDir & '\Export.exe') & ' /db="' & $VistumblerDB & '" /t=k /f="' & $GoogleEarth_DeadFile & '" /d', '', @SW_HIDE)
				If $AutoKmlActiveTime <> 0 Then Run(@ComSpec & " /C " & FileGetShortName(@ScriptDir & '\Export.exe') & ' /db="' & $VistumblerDB & '"/t=k /f="' & $GoogleEarth_ActiveFile & '" /a', '', @SW_HIDE)
				If $AutoKmlTrackTime <> 0 Then Run(@ComSpec & " /C " & FileGetShortName(@ScriptDir & '\Export.exe') & ' /db="' & $VistumblerDB & '" /t=k /f="' & $GoogleEarth_TrackFile & '" /p', '', @SW_HIDE)
				Run('"' & $GoogleEarthExe & '" "' & $kml & '"')
			EndIf
		Else
			MsgBox(0, $Text_Error, $Text_GoogleEarthDoesNotExist)
		EndIf
	Else
		$updatemsg = MsgBox(4, $Text_Error, $Text_AutoKmlIsNotStarted)
		If $updatemsg = 6 Then
			_AutoKmlToggle()
			_StartGoogleAutoKmlRefresh()
		EndIf
	EndIf
EndFunc   ;==>_StartGoogleAutoKmlRefresh

Func _AutoKmlGpsFile($kml)
	;Write GPS KML
	If StringInStr($kml, '.kml') = 0 Then $kml = $kml & '.kml'
	$file = '<?xml version="1.0" encoding="UTF-8"?>' & @CRLF _
			 & '<kml xmlns="http://earth.google.com/kml/2.2">' & @CRLF _
			 & '	<Document>' & @CRLF _
			 & '		<Style id="gpsStyle">' & @CRLF _
			 & '			<IconStyle>' & @CRLF _
			 & '				<scale>1</scale>' & @CRLF _
			 & '				<Icon>' & @CRLF _
			 & '<href>' & $ImageDir & 'gpspos.png</href>' & @CRLF _
			 & '				</Icon>' & @CRLF _
			 & '			</IconStyle>' & @CRLF _
			 & '		</Style>' & @CRLF
	If $Latitude <> 'N 0000.0000' And $Longitude <> 'E 0000.0000' Then
		$file &= '			<LookAt>  ' & @CRLF _
				 & '				<longitude>' & StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($Longitude), 'W', '-'), 'E', ''), ' ', '') & '</longitude>' & @CRLF _
				 & '				<latitude>' & StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($Latitude), 'S', '-'), 'N', ''), ' ', '') & '</latitude>' & @CRLF _
				 & '				<altitude>' & $AutoKML_Alt & '</altitude>' & @CRLF _
				 & '				<heading>' & $AutoKML_Heading & '</heading>' & @CRLF _
				 & '				<tilt>' & $AutoKML_Tilt & '</tilt>' & @CRLF _
				 & '				<range>' & $AutoKML_Range & '</range>' & @CRLF _
				 & '			</LookAt>' & @CRLF
	EndIf
	$file &= '		<Folder>' & @CRLF _
			 & '			<name>GPS Position</name>' & @CRLF
	If $Latitude <> 'N 0000.0000' And $Longitude <> 'E 0000.0000' Then
		$file &= '			<Placemark>' & @CRLF _
				 & '				<name>Current Position</name>' & @CRLF _
				 & '				<description><![CDATA[<b>' & $Column_Names_Latitude & ': </b>' & _GpsFormat($Latitude) & '<br /><b>' & $Column_Names_Longitude & ': </b>' & _GpsFormat($Longitude) & '<br />]]></description>' & @CRLF _
				 & '				<styleUrl>#gpsStyle</styleUrl>' & @CRLF _
				 & '				<Point>' & @CRLF _
				 & '					<altitudeMode>' & $AutoKML_AltMode & '</altitudeMode>' & @CRLF _
				 & '					<coordinates>' & StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($Longitude), 'W', '-'), 'E', ''), ' ', '') & ',' & StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($Latitude), 'S', '-'), 'N', ''), ' ', '') & ',0</coordinates>' & @CRLF _
				 & '				</Point>' & @CRLF _
				 & '			</Placemark>' & @CRLF
	EndIf
	$file &= '		</Folder>' & @CRLF _
			 & '	</Document>' & @CRLF _
			 & '</kml>'
	FileDelete($kml)
	FileWrite($kml, $file)
EndFunc   ;==>_AutoKmlGpsFile

;-------------------------------------------------------------------------------------------------------------------------------
;                                                       NETSTUMBLER SAVE/OPEN FUNCTIONS
;-------------------------------------------------------------------------------------------------------------------------------

Func _ExportNS1();Saves netstumbler data to a netstumbler summary .ns1
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_ExportNS1()') ;#Debug Display
	DirCreate($SaveDir)
	$filename = FileSaveDialog($Text_SaveAsTXT, $SaveDir, $Text_NetstumblerTxtFile & ' (*.NS1)', '', $ldatetimestamp & '.NS1')
	If @error <> 1 Then
		If StringInStr($filename, '.NS1') = 0 Then $filename = $filename & '.NS1'
		$APID1 = ''
		$Date1 = ''

		$file = "# $Creator: " & $Script_Name & " " & $version & @CRLF & _
				"# $Format: wi-scan summary with extensions" & @CRLF & _
				"# Latitude	Longitude	( SSID )	Type	( BSSID )	Time (GMT)	[ SNR Sig Noise ]	# ( Name )	Flags	Channelbits	BcnIntvl	DataRate	LastChannel" & @CRLF

		$query = "SELECT ApID, GpsID, Signal, Date1, Time1 FROM Hist ORDER BY Date1, Time1"
		$HistMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
		$FoundHistMatch = UBound($HistMatchArray) - 1
		If $FoundHistMatch > 0 Then
			For $exns1 = 1 To $FoundHistMatch
				GUICtrlSetData($msgdisplay, $Text_SavingHistID & ' ' & $exns1 & ' / ' & $FoundHistMatch)
				$Found_APID = $HistMatchArray[$exns1][1]
				If $Found_APID <> $APID1 Then
					$Found_GpsID = $HistMatchArray[$exns1][2]
					$Found_Sig = $HistMatchArray[$exns1][3]
					$Found_Date = $HistMatchArray[$exns1][4]
					$Found_Time = StringTrimRight($HistMatchArray[$exns1][5], 4)
					$query = "SELECT Latitude, Longitude FROM GPS WHERE GpsID=" & $Found_GpsID
					$ApMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
					$Found_Lat = _Format_GPS_DMM_to_DDD($ApMatchArray[1][1])
					$Found_Lon = _Format_GPS_DMM_to_DDD($ApMatchArray[1][2])
					$query = "SELECT SSID, BSSID, SecType, NETTYPE, CHAN, BTX, OTX, LABEL, MANU FROM AP WHERE ApID=" & $Found_APID
					$ApMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
					$Found_SSID = $ApMatchArray[1][1]
					$Found_BSSID = $ApMatchArray[1][2]
					$Found_SecType = $ApMatchArray[1][3]
					$Found_NETTYPE = $ApMatchArray[1][4]
					$Found_CHAN = $ApMatchArray[1][5]
					$Found_BTX = $ApMatchArray[1][6]
					$Found_OTX = $ApMatchArray[1][7]
					$Found_LAB = $ApMatchArray[1][8]
					$Found_MANU = $ApMatchArray[1][9]

					If $Found_Date <> $Date1 Then
						$Date1 = $Found_Date
						$file &= "# $DateGMT: " & $Date1 & @CRLF
					EndIf

					$otxarray = StringSplit($Found_OTX, " ")
					If IsArray($otxarray) Then
						$radio = $otxarray[$otxarray[0]] * 10
					Else
						$btxarray = StringSplit($Found_BTX, " ")
						If IsArray($btxarray) Then
							$radio = $btxarray[$btxarray[0]] * 10
						Else
							$radio = 0
						EndIf
					EndIf

					;Channel Info - http://www.netstumbler.org/f4/channelbits-8849/
					$CHAN = '00000000'
					If $Found_CHAN = 1 Then $CHAN = '00000002'
					If $Found_CHAN = 2 Then $CHAN = '00000004'
					If $Found_CHAN = 3 Then $CHAN = '00000008'
					If $Found_CHAN = 4 Then $CHAN = '00000010'
					If $Found_CHAN = 5 Then $CHAN = '00000020'
					If $Found_CHAN = 6 Then $CHAN = '00000040'
					If $Found_CHAN = 7 Then $CHAN = '00000080'
					If $Found_CHAN = 8 Then $CHAN = '00000100'
					If $Found_CHAN = 9 Then $CHAN = '00000200'
					If $Found_CHAN = 10 Then $CHAN = '00000400'
					If $Found_CHAN = 11 Then $CHAN = '00000800'
					If $Found_CHAN = 12 Then $CHAN = '00001000'
					If $Found_CHAN = 13 Then $CHAN = '00002000'
					If $Found_CHAN = 14 Then $CHAN = '00004000'
					If $Found_CHAN = 36 Then $CHAN = '00008000'
					If $Found_CHAN = 40 Then $CHAN = '00010000'
					If $Found_CHAN = 44 Then $CHAN = '00020000'
					If $Found_CHAN = 48 Then $CHAN = '00040000'
					If $Found_CHAN = 52 Then $CHAN = '00080000'
					If $Found_CHAN = 56 Then $CHAN = '00100000'
					If $Found_CHAN = 60 Then $CHAN = '00200000'
					If $Found_CHAN = 64 Then $CHAN = '00400000'
					If $Found_CHAN = 149 Then $CHAN = '00800000'
					If $Found_CHAN = 153 Then $CHAN = '01000000'
					If $Found_CHAN = 157 Then $CHAN = '02000000'
					If $Found_CHAN = 161 Then $CHAN = '04000000'
					If $Found_CHAN = 38 Then $CHAN = '08000000'
					If $Found_CHAN = 46 Then $CHAN = '10000000'
					If $Found_CHAN = 54 Then $CHAN = '20000000'
					If $Found_CHAN = 62 Then $CHAN = '40000000'
					If $Found_CHAN = 34 Then $CHAN = '80000000'

					$Flags = 0
					If $Found_NETTYPE = $SearchWord_Adhoc Then
						$Flags += 2 ;Set IBSS (Ad hoc) flag
						$BSS = 'ad-hoc'
					Else
						$Flags += 1 ;Set ESS (Infrastructure) flag
						$BSS = 'BSS'
					EndIf

					If $Found_SecType <> '1' Then
						$Flags += 10 ;Set Privacy (WEP) flag
					EndIf

					$Flags = StringFormat("%04i", $Flags)
				EndIf
				$file &= $Found_Lat & "	" & $Found_Lon & "	( " & $Found_SSID & " )	" & $BSS & "	( " & $Found_BSSID & " )	" & $Found_Time & " (GMT)	[ " & $Found_Sig & " " & $Found_Sig + 50 & " 50 ]	# ( " & $Found_LAB & ' - ' & $Found_MANU & " )	" & $Flags & "	" & $CHAN & "	1000	" & $radio & "	" & $Found_CHAN & @CRLF
			Next
			$savefile = FileOpen($filename, 128 + 2);Open in UTF-8 write mode
			FileWrite($savefile, $file)
			FileClose($savefile)
			MsgBox(0, $Text_Done, $Text_SavedAs & ': "' & $filename & '"')
		Else
			MsgBox(0, $Text_Done, $Text_NoAps & ' ' & $Text_NoFileSaved)
		EndIf
	Else
		MsgBox(0, $Text_Error, $Text_NoFileSaved)
		Return (0)
	EndIf
EndFunc   ;==>_ExportNS1

;-------------------------------------------------------------------------------------------------------------------------------
;                                                       SETTINGS WINDOW FUNCTIONS
;-------------------------------------------------------------------------------------------------------------------------------

Func _SettingsGUI_Misc();Opens GUI to Misc tab
	$Apply_Misc = 1
	_SettingsGUI(0)
EndFunc   ;==>_SettingsGUI_Misc

Func _SettingsGUI_Save();Opens GUI to Misc tab
	$Apply_Save = 1
	_SettingsGUI(1)
EndFunc   ;==>_SettingsGUI_Save

Func _SettingsGUI_GPS();Opens GUI to GPS tab
	$Apply_GPS = 1
	_SettingsGUI(2)
EndFunc   ;==>_SettingsGUI_GPS

Func _SettingsGUI_Lan();Opens GUI to Language tab
	$Apply_Language = 1
	_SettingsGUI(3)
EndFunc   ;==>_SettingsGUI_Lan

Func _SettingsGUI_Manu();Opens GUI to Manufacturer tab
	$Apply_Manu = 1
	_SettingsGUI(4)
EndFunc   ;==>_SettingsGUI_Manu

Func _SettingsGUI_Lab();Opens GUI to Label tab
	$Apply_Lab = 1
	_SettingsGUI(5)
EndFunc   ;==>_SettingsGUI_Lab

Func _SettingsGUI_Col();Opens GUI to Column tab
	$Apply_Column = 1
	_SettingsGUI(6)
EndFunc   ;==>_SettingsGUI_Col

Func _SettingsGUI_SW();Opens GUI to Searchword tab
	$Apply_Searchword = 1
	_SettingsGUI(7)
EndFunc   ;==>_SettingsGUI_SW

Func _SettingsGUI_Auto();Opens GUI to Auto tab
	$Apply_Auto = 1
	_SettingsGUI(8)
EndFunc   ;==>_SettingsGUI_Auto

Func _SettingsGUI_Sound();Opens GUI to Auto tab
	$Apply_Sound = 1
	_SettingsGUI(9)
EndFunc   ;==>_SettingsGUI_Sound

Func _SettingsGUI_WifiDB();Opens GUI to Auto tab
	$Apply_WifiDB = 1
	_SettingsGUI(10)
EndFunc   ;==>_SettingsGUI_WifiDB

Func _SettingsGUI_Cam();Opens GUI to Auto tab
	$Apply_Cam = 1
	_SettingsGUI(11)
EndFunc   ;==>_SettingsGUI_Cam

Func _SettingsGUI($StartTab);Opens Settings GUI to specified tab
	If $SettingsOpen = 1 Then
		WinActivate($Text_VistumblerSettings)
	Else
		$SettingsOpen = 1
		$SetMisc = GUICreate($Text_VistumblerSettings, 680, 500, -1, -1, BitOR($WS_OVERLAPPEDWINDOW, $WS_CLIPSIBLINGS))
		GUISetBkColor($BackgroundColor)
		$Settings_Tab = GUICtrlCreateTab(0, 0, 680, 470)

		;Misc Tab
		$Tab_Misc = GUICtrlCreateTabItem($Text_Misc)
		_GUICtrlTab_SetBkColor($SetMisc, $Settings_Tab, $BackgroundColor)
		$GroupMiscSettings = GUICtrlCreateGroup($Text_MiscSettings, 15, 50, 650, 200)
		GUICtrlSetColor(-1, $TextColor)
		GUICtrlCreateLabel($Text_BackgroundColor, 31, 70, 300, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GUI_BKColor = GUICtrlCreateInput(StringReplace($BackgroundColor, '0x', ''), 31, 85, 195, 21)
		$cbrowse1 = GUICtrlCreateButton($Text_Browse, 235, 85, 97, 20, 0)
		GUICtrlCreateLabel($Text_ControlColor, 353, 70, 300, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GUI_CBKColor = GUICtrlCreateInput(StringReplace($ControlBackgroundColor, '0x', ''), 353, 85, 195, 21)
		$cbrowse2 = GUICtrlCreateButton($Text_Browse, 556, 85, 97, 20, 0)
		GUICtrlCreateLabel($Text_BgFontColor, 31, 110, 300, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GUI_TextColor = GUICtrlCreateInput(StringReplace($TextColor, '0x', ''), 31, 125, 195, 21)
		$cbrowse3 = GUICtrlCreateButton($Text_Browse, 235, 125, 97, 20, 0)
		GUICtrlCreateLabel($Text_RefreshLoopTime, 353, 110, 300, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GUI_RefreshLoop = GUICtrlCreateInput($RefreshLoopTime, 353, 125, 195, 21)
		GUICtrlCreateLabel($Text_MaxSignal & " (dBm)", 31, 150, 300, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GUI_dBmMaxSignal = GUICtrlCreateInput($dBmMaxSignal, 31, 165, 195, 21)
		GUICtrlCreateLabel($Text_DisassociationSignal & " (dBm)", 31, 190, 300, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GUI_dBmDisassociationSignal = GUICtrlCreateInput($dBmDissociationSignal, 31, 205, 195, 21)
		GUICtrlCreateLabel($Text_TimeBeforeMarkedDead, 353, 150, 300, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GUI_TimeBeforeMarkingDead = GUICtrlCreateInput($TimeBeforeMarkedDead, 353, 165, 195, 21)

		$GUI_AutoCheckForUpdates = GUICtrlCreateCheckbox($Text_AutoCheckUpdates, 353, 195, 300, 15)
		GUICtrlSetColor(-1, $TextColor)
		If $AutoCheckForUpdates = 1 Then GUICtrlSetState($GUI_AutoCheckForUpdates, $GUI_CHECKED)
		$GUI_CheckForBetaUpdates = GUICtrlCreateCheckbox($Text_CheckBetaUpdates, 353, 210, 300, 15)
		GUICtrlSetColor(-1, $TextColor)
		If $CheckForBetaUpdates = 1 Then GUICtrlSetState($GUI_CheckForBetaUpdates, $GUI_CHECKED)
		;Auto Refresh Group
		GUICtrlCreateGroup($Text_RefreshNetworks, 16, 250, 325, 110)
		$GUI_RefreshNetworks = GUICtrlCreateCheckbox($Text_RefreshNetworks, 30, 275, 300, 15)
		GUICtrlSetColor(-1, $TextColor)
		If $RefreshNetworks = 1 Then GUICtrlSetState($GUI_RefreshNetworks, $GUI_CHECKED)
		GUICtrlCreateLabel($Text_RefreshTime & '(s)', 30, 295, 615, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GUI_RefreshTime = GUICtrlCreateInput(($RefreshTime / 1000), 30, 310, 115, 20)
		GUICtrlSetColor(-1, $TextColor)

		;Save Tab
		$Tab_Save = GUICtrlCreateTabItem($Text_Save)
		_GUICtrlTab_SetBkColor($SetMisc, $Settings_Tab, $BackgroundColor)
		GUICtrlSetColor(-1, $TextColor)
		$GroupSaveDirs = GUICtrlCreateGroup($Text_SaveDirectories, 15, 50, 650, 180)
		GUICtrlSetColor(-1, $TextColor)
		GUICtrlCreateLabel($Text_VistumblerSaveDirectory, 30, 70, 580, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GUI_Set_SaveDir = GUICtrlCreateInput($SaveDir, 30, 85, 515, 21)
		$browse1 = GUICtrlCreateButton($Text_Browse, 555, 85, 97, 20, 0)
		GUICtrlCreateLabel($Text_VistumblerAutoSaveDirectory, 30, 110, 580, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GUI_Set_SaveDirAuto = GUICtrlCreateInput($SaveDirAuto, 30, 125, 515, 21)
		$Browse2 = GUICtrlCreateButton($Text_Browse, 555, 125, 97, 20, 0)
		GUICtrlCreateLabel($Text_VistumblerKmlSaveDirectory, 30, 150, 580, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GUI_Set_SaveDirKml = GUICtrlCreateInput($SaveDirKml, 30, 165, 515, 21)
		$Browse3 = GUICtrlCreateButton($Text_Browse, 555, 165, 97, 20, 0)

		;Auto Save and Clear
		GUICtrlCreateGroup($Text_AutoSaveAndClear, 15, 240, 320, 170)
		GUICtrlSetColor(-1, $TextColor)
		$AutoSaveAndClearBox = GUICtrlCreateCheckbox($Text_AutoSaveAndClear, 25, 265, 300, 15)
		GUICtrlSetColor(-1, $TextColor)
		If $AutoSaveAndClear = 1 Then GUICtrlSetState($AutoSaveAndClearBox, $GUI_CHECKED)
		$AutoSaveAndClearRadioAP = GUICtrlCreateRadio($Text_AutoSaveAndClearAfterNumberofAPs, 40, 285, 280, 15)
		If $AutoSaveAndClearOnAPs = 1 Then GUICtrlSetState($AutoSaveAndClearRadioAP, $GUI_CHECKED)
		GUICtrlSetColor(-1, $TextColor)
		$AutoSaveAndClearAPsGUI = GUICtrlCreateInput($AutoSaveAndClearAPs, 55, 305, 50, 20)
		GUICtrlSetColor(-1, $TextColor)
		GUICtrlCreateLabel($Text_APs, 107, 308, 100, 15)
		GUICtrlSetColor(-1, $TextColor)
		$AutoSaveAndClearRadioTime = GUICtrlCreateRadio($Text_AutoSaveandClearAfterTime, 40, 330, 280, 15)
		If $AutoSaveAndClearOnTime = 1 Then GUICtrlSetState($AutoSaveAndClearRadioTime, $GUI_CHECKED)
		GUICtrlSetColor(-1, $TextColor)
		$AutoSaveAndClearTimeGUI = GUICtrlCreateInput($AutoSaveAndClearTime, 55, 350, 50, 20)
		GUICtrlSetColor(-1, $TextColor)
		GUICtrlCreateLabel($Text_Minutes, 107, 353, 100, 15)
		GUICtrlSetColor(-1, $TextColor)
		$AutoSaveAndClearPlaySoundGUI = GUICtrlCreateCheckbox($Text_PlaySoundWhenSaving, 40, 380, 280, 15)
		If $AutoSaveAndClearPlaySound = 1 Then GUICtrlSetState($AutoSaveAndClearPlaySoundGUI, $GUI_CHECKED)

		;Auto Recovery
		GUICtrlCreateGroup($Text_AutoRecoveryVS1, 345, 240, 320, 170)
		GUICtrlSetColor(-1, $TextColor)
		$AutoRecoveryBox = GUICtrlCreateCheckbox($Text_AutoRecoveryVS1, 360, 265, 300, 15)
		If $AutoRecoveryVS1 = 1 Then GUICtrlSetState($AutoRecoveryBox, $GUI_CHECKED)
		GUICtrlSetColor(-1, $TextColor)
		$AutoRecoveryDelBox = GUICtrlCreateCheckbox($Text_DelAutoSaveOnExit, 360, 290, 300, 15)
		GUICtrlSetColor(-1, $TextColor)
		If $AutoRecoveryVS1Del = 1 Then GUICtrlSetState($AutoRecoveryDelBox, $GUI_CHECKED)
		GUICtrlCreateLabel($Text_AutoSaveEvery, 360, 315, 300, 15)
		GUICtrlSetColor(-1, $TextColor)
		$AutoRecoveryTimeGUI = GUICtrlCreateInput($AutoRecoveryTime, 360, 335, 50, 21)
		GUICtrlSetColor(-1, $TextColor)
		GUICtrlCreateLabel($Text_Minutes, 412, 338, 100, 15)
		GUICtrlSetColor(-1, $TextColor)

		;GPS Tab
		$Tab_Gps = GUICtrlCreateTabItem($Text_Gps)
		_GUICtrlTab_SetBkColor($SetMisc, $Settings_Tab, $BackgroundColor)
		$GroupComInt = GUICtrlCreateGroup($Text_ComInterface, 24, 48, 633, 105)
		GUICtrlSetColor(-1, $TextColor)
		$Rad_UseNetcomm = GUICtrlCreateRadio($Text_UseNetcomm, 40, 70, 361, 20)
		GUICtrlSetColor(-1, $TextColor)
		$Rad_UseCommMG = GUICtrlCreateRadio($Text_UseCommMG, 40, 95, 361, 20)
		GUICtrlSetColor(-1, $TextColor)
		$Rad_UseKernel32 = GUICtrlCreateRadio($Text_UseKernel32, 40, 120, 361, 20)
		GUICtrlSetColor(-1, $TextColor)
		If $GpsType = 0 Then
			GUICtrlSetState($Rad_UseCommMG, $GUI_CHECKED)
		ElseIf $GpsType = 1 Then
			GUICtrlSetState($Rad_UseNetcomm, $GUI_CHECKED)
		ElseIf $GpsType = 2 Then
			GUICtrlSetState($Rad_UseKernel32, $GUI_CHECKED)
		EndIf
		$GroupComSet = GUICtrlCreateGroup($Text_ComSettings, 24, 160, 633, 185)
		GUICtrlSetColor(-1, $TextColor)
		GUICtrlCreateLabel($Text_Com, 44, 180, 275, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GUI_Comport = GUICtrlCreateCombo("1", 44, 195, 275, 25)
		GUICtrlSetData(-1, "2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20", $ComPort)
		GUICtrlCreateLabel($Text_Baud, 44, 235, 275, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GUI_Baud = GUICtrlCreateCombo("4800", 44, 250, 275, 25)
		GUICtrlSetData(-1, "9600|14400|19200|38400|57600|115200", $BAUD)
		GUICtrlCreateLabel($Text_StopBit, 44, 290, 275, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GUI_StopBit = GUICtrlCreateCombo("1", 44, 305, 275, 25)
		GUICtrlSetData(-1, "1.5|2", $STOPBIT)

		If $PARITY = 'E' Then
			$l_PARITY = $Text_Even
		ElseIf $PARITY = 'M' Then
			$l_PARITY = $Text_Mark
		ElseIf $PARITY = 'O' Then
			$l_PARITY = $Text_Odd
		ElseIf $PARITY = 'S' Then
			$l_PARITY = $Text_Space
		Else
			$l_PARITY = $Text_None
		EndIf
		GUICtrlCreateLabel($Text_Parity, 364, 180, 275, 15)
		$GUI_Parity = GUICtrlCreateCombo($Text_None, 364, 195, 275, 25)
		GUICtrlSetData(-1, $Text_Even & '|' & $Text_Mark & '|' & $Text_Odd & '|' & $Text_Space, $l_PARITY)
		GUICtrlCreateLabel($Text_DataBit, 364, 235, 275, 15)
		$GUI_DataBit = GUICtrlCreateCombo("4", 364, 250, 275, 25)
		GUICtrlSetData(-1, "5|6|7|8", $DATABIT)
		$GroupGpsOptions = GUICtrlCreateGroup($Text_GpsSettings, 24, 360, 633, 100)
		GUICtrlSetColor(-1, $TextColor)
		GUICtrlCreateLabel($Text_GPSFormat, 44, 380, 100, 15)
		If $GPSformat = 1 Then $DefForm = "dd.dddd"
		If $GPSformat = 2 Then $DefForm = "dd mm ss"
		If $GPSformat = 3 Then $DefForm = "ddmm.mmmm"
		$GUI_Format = GUICtrlCreateCombo("dd.dddd", 44, 395, 275, 25)
		GUICtrlSetData(-1, "ddmm.mmmm|dd mm ss", $DefForm)
		GUICtrlSetColor($GUI_Format, $TextColor)
		$GUI_GpsDisconnect = GUICtrlCreateCheckbox($Text_GpsDisconnect, 44, 420, 400, 15)
		If $GpsDisconnect = 1 Then GUICtrlSetState($GUI_GpsDisconnect, $GUI_CHECKED)
		GUICtrlSetColor(-1, $TextColor)
		$GUI_GpsReset = GUICtrlCreateCheckbox($Text_GpsReset, 44, 440, 400, 15)
		If $GpsReset = 1 Then GUICtrlSetState($GUI_GpsReset, $GUI_CHECKED)
		GUICtrlSetColor(-1, $TextColor)
		;Language Tab
		$Tab_Lan = GUICtrlCreateTabItem($Text_Language)
		_GUICtrlTab_SetBkColor($SetMisc, $Settings_Tab, $BackgroundColor)
		$GroupLan = GUICtrlCreateGroup($Text_SetLanguage, 16, 40, 641, 297)
		GUICtrlSetColor(-1, $TextColor)
		Dim $Languages1 = '', $Languages2 = ''
		$languagefiles = _FileListToArray($LanguageDir, '*.ini', 1);Find all files in the folder that end in .ini . These are automatically assumed to a language file
		For $b = 1 To $languagefiles[0];Set Languages into proper format for the combo box
			If $b = 1 Then
				$Languages1 = StringTrimRight($languagefiles[$b], 4)
			ElseIf $b > 1 Then
				$Languages2 &= StringTrimRight($languagefiles[$b], 4)
				If $b < $languagefiles[0] Then $Languages2 &= '|'
			EndIf
		Next

		$LanguageBox = GUICtrlCreateCombo($Languages1, 32, 64, 601, 25)
		GUICtrlSetData($LanguageBox, $Languages2, $DefaultLanguage)
		GUICtrlCreateGroup($Text_LanguageAuthor, 32, 96, 601, 41)
		GUICtrlSetColor(-1, $TextColor)
		$LabAuth = GUICtrlCreateLabel(IniRead($DefaultLanguagePath, 'Info', 'Author', ''), 40, 112, 580, 17)
		GUICtrlSetColor(-1, $TextColor)
		GUICtrlCreateGroup($Text_LanguageDate, 32, 150, 300, 41)
		GUICtrlSetColor(-1, $TextColor)
		$LabDate = GUICtrlCreateLabel(_DateLocalFormat(IniRead($DefaultLanguagePath, 'Info', 'Date', '')), 40, 166, 280, 17)
		GUICtrlSetColor(-1, $TextColor)
		GUICtrlCreateGroup($Text_LanguageCode, 340, 150, 293, 41)
		GUICtrlSetColor(-1, $TextColor)
		$LabWinCode = GUICtrlCreateLabel(IniRead($DefaultLanguagePath, 'Info', 'WindowsLanguageCode', ''), 350, 166, 280, 17)
		GUICtrlSetColor(-1, $TextColor)
		GUICtrlCreateGroup($Text_LanguageDescription, 34, 200, 601, 121)
		GUICtrlSetColor(-1, $TextColor)
		$LabDesc = GUICtrlCreateLabel(IniRead($DefaultLanguagePath, 'Info', 'Description', ''), 42, 216, 580, 97)
		GUICtrlSetColor(-1, $TextColor)

		$GroupLanImp = GUICtrlCreateGroup($Text_ImportLanguageFile, 16, 352, 641, 97)
		GUICtrlSetColor(-1, $TextColor)
		$ImpLanFile = GUICtrlCreateInput("", 32, 376, 505, 21)
		GUICtrlSetColor(-1, $TextColor)
		$ImpLanBrowse = GUICtrlCreateButton($Text_Browse, 552, 376, 81, 20, 0)
		$ImpLanButton = GUICtrlCreateButton($Text_ImportLanguageFile, 264, 408, 161, 25, 0)
		;Manufactures tab
		$Tab_Manu = GUICtrlCreateTabItem($Text_Manufacturers)
		_GUICtrlTab_SetBkColor($SetMisc, $Settings_Tab, $BackgroundColor)
		GUICtrlCreateLabel($Text_NewMac, 34, 39, 195, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GUI_Manu_NewMac = GUICtrlCreateInput("", 34, 56, 195, 21)
		GUICtrlCreateLabel($Text_NewMan, 244, 39, 410, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GUI_Manu_NewManu = GUICtrlCreateInput("", 244, 56, 410, 21)
		GUICtrlSetColor(-1, $TextColor)
		$Add_MANU = GUICtrlCreateButton($Text_AddNewMan, 24, 90, 201, 25, 0)
		$Remove_MANU = GUICtrlCreateButton($Text_RemoveMan, 239, 90, 201, 25, 0)
		$Edit_MANU = GUICtrlCreateButton($Text_EditMan, 456, 90, 201, 25, 0)
		$GUI_Manu_List = GUICtrlCreateListView($Column_Names_BSSID & "|" & $Column_Names_MANUF, 24, 125, 634, 326, $LVS_REPORT, $LVS_EX_HEADERDRAGDROP + $LVS_EX_GRIDLINES + $LVS_EX_FULLROWSELECT)
		GUICtrlSetBkColor(-1, $ControlBackgroundColor)
		_GUICtrlListView_SetColumnWidth($GUI_Manu_List, 0, 160)
		_GUICtrlListView_SetColumnWidth($GUI_Manu_List, 1, 450)
		;Add Manufacturers to list
		$query = "SELECT BSSID, Manufacturer FROM Manufacturers"
		$ManuMatchArray = _RecordSearch($ManuDB, $query, $ManuDB_OBJ)
		$FoundManuMatch = UBound($ManuMatchArray) - 1
		GUICtrlSetData($msgdisplay, $Text_VistumblerSettings & ' - Loading ' & $FoundManuMatch & ' Manufacturer(s)')
		For $m = 1 To $FoundManuMatch
			$manumac = $ManuMatchArray[$m][1]
			$manumanu = $ManuMatchArray[$m][2]
			GUICtrlCreateListViewItem('"' & $manumac & '"|' & $manumanu, $GUI_Manu_List)
		Next
		GUICtrlSetData($msgdisplay, '')
		;Labels Tab
		$Tab_Lab = GUICtrlCreateTabItem($Text_Labels)
		_GUICtrlTab_SetBkColor($SetMisc, $Settings_Tab, $BackgroundColor)
		GUICtrlCreateLabel($Text_NewMac, 34, 39, 195, 15)
		GUICtrlSetColor(-1, $TextColor)
		GUICtrlCreateLabel($Text_NewLabel, 244, 39, 410, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GUI_Lab_NewMac = GUICtrlCreateInput("", 34, 56, 195, 21)
		GUICtrlSetColor(-1, $TextColor)
		$GUI_Lab_NewLabel = GUICtrlCreateInput("", 244, 56, 410, 21)
		GUICtrlSetColor(-1, $TextColor)
		$Add_Lab = GUICtrlCreateButton($Text_AddNewLabel, 24, 90, 201, 25, 0)
		$Remove_Lab = GUICtrlCreateButton($Text_RemoveLabel, 239, 90, 201, 25, 0)
		$Edit_Lab = GUICtrlCreateButton($Text_EditLabel, 454, 90, 201, 25, 0)
		$GUI_Lab_List = GUICtrlCreateListView($Column_Names_BSSID & "|" & $Column_Names_Label, 24, 125, 634, 326, $LVS_REPORT, $LVS_EX_HEADERDRAGDROP + $LVS_EX_GRIDLINES + $LVS_EX_FULLROWSELECT)
		GUICtrlSetBkColor(-1, $ControlBackgroundColor)
		_GUICtrlListView_SetColumnWidth($GUI_Lab_List, 0, 160)
		_GUICtrlListView_SetColumnWidth($GUI_Lab_List, 1, 450)
		;Add Labels to list
		$query = "SELECT BSSID, Label FROM Labels"
		$LabMatchArray = _RecordSearch($LabDB, $query, $LabDB_OBJ)
		$FoundLabMatch = UBound($LabMatchArray) - 1
		GUICtrlSetData($msgdisplay, $Text_VistumblerSettings & ' - Loading ' & $FoundLabMatch & ' Label(s)')
		For $l = 1 To $FoundLabMatch
			$labmac = $LabMatchArray[$l][1]
			$lablab = $LabMatchArray[$l][2]
			GUICtrlCreateListViewItem('"' & $labmac & '"|' & $lablab, $GUI_Lab_List)
		Next
		GUICtrlSetData($msgdisplay, '')
		;Columns Tabs
		$Tab_Col = GUICtrlCreateTabItem($Text_Columns)
		;Get Current GUI widths from listview
		_GetListviewWidths()
		;Start Column tab gui
		_GUICtrlTab_SetBkColor($SetMisc, $Settings_Tab, $BackgroundColor)
		$GroupColumns = GUICtrlCreateGroup($Text_Columns, 16, 25, 657, 435)
		GUICtrlSetColor(-1, $TextColor)
		$CWCB_Line = GUICtrlCreateCheckbox($Column_Names_Line, 34, 65, 185, 17)
		GUICtrlSetColor(-1, $TextColor)
		$CWIB_Line = GUICtrlCreateInput($column_Width_Line, 224, 65, 113, 21)
		GUICtrlSetColor(-1, $TextColor)
		$CWCB_Active = GUICtrlCreateCheckbox($Column_Names_Active, 34, 95, 185, 17)
		GUICtrlSetColor(-1, $TextColor)
		$CWIB_Active = GUICtrlCreateInput($column_Width_Active, 224, 95, 113, 21)
		GUICtrlSetColor(-1, $TextColor)
		$CWCB_SSID = GUICtrlCreateCheckbox($Column_Names_SSID, 34, 125, 185, 17)
		GUICtrlSetColor(-1, $TextColor)
		$CWIB_SSID = GUICtrlCreateInput($column_Width_SSID, 224, 125, 113, 21)
		GUICtrlSetColor(-1, $TextColor)
		$CWCB_BSSID = GUICtrlCreateCheckbox($Column_Names_BSSID, 34, 155, 185, 17)
		GUICtrlSetColor(-1, $TextColor)
		$CWIB_BSSID = GUICtrlCreateInput($column_Width_BSSID, 224, 155, 113, 21)
		GUICtrlSetColor(-1, $TextColor)

		$CWCB_Signal = GUICtrlCreateCheckbox($Column_Names_Signal, 34, 185, 185, 17)
		GUICtrlSetColor(-1, $TextColor)
		$CWIB_Signal = GUICtrlCreateInput($column_Width_Signal, 224, 185, 113, 21)
		GUICtrlSetColor(-1, $TextColor)
		$CWCB_HighSignal = GUICtrlCreateCheckbox($Column_Names_HighSignal, 34, 215, 185, 17)
		GUICtrlSetColor(-1, $TextColor)
		$CWIB_HighSignal = GUICtrlCreateInput($column_Width_HighSignal, 224, 215, 113, 21)
		GUICtrlSetColor(-1, $TextColor)

		$CWCB_RSSI = GUICtrlCreateCheckbox($Column_Names_RSSI, 34, 245, 185, 17)
		GUICtrlSetColor(-1, $TextColor)
		$CWIB_RSSI = GUICtrlCreateInput($column_Width_RSSI, 224, 245, 113, 21)
		GUICtrlSetColor(-1, $TextColor)
		$CWCB_HighRSSI = GUICtrlCreateCheckbox($Column_Names_HighRSSI, 34, 275, 185, 17)
		GUICtrlSetColor(-1, $TextColor)
		$CWIB_HighRSSI = GUICtrlCreateInput($column_Width_HighRSSI, 224, 275, 113, 21)
		GUICtrlSetColor(-1, $TextColor)

		$CWCB_Authentication = GUICtrlCreateCheckbox($Column_Names_Authentication, 34, 305, 185, 17)
		GUICtrlSetColor(-1, $TextColor)
		$CWIB_Authentication = GUICtrlCreateInput($column_Width_Authentication, 224, 305, 113, 21)
		GUICtrlSetColor(-1, $TextColor)
		$CWCB_Encryption = GUICtrlCreateCheckbox($Column_Names_Encryption, 34, 335, 185, 17)
		GUICtrlSetColor(-1, $TextColor)
		$CWIB_Encryption = GUICtrlCreateInput($column_Width_Encryption, 224, 335, 113, 21)
		GUICtrlSetColor(-1, $TextColor)
		$CWCB_RadioType = GUICtrlCreateCheckbox($Column_Names_RadioType, 34, 365, 185, 17)
		GUICtrlSetColor(-1, $TextColor)
		$CWIB_RadioType = GUICtrlCreateInput($column_Width_RadioType, 224, 365, 113, 21)
		GUICtrlSetColor(-1, $TextColor)
		$CWCB_NetType = GUICtrlCreateCheckbox($Column_Names_NetworkType, 34, 395, 185, 17)
		GUICtrlSetColor(-1, $TextColor)
		$CWIB_NetType = GUICtrlCreateInput($column_Width_NetworkType, 224, 395, 113, 21)
		GUICtrlSetColor(-1, $TextColor)
		$CWCB_Channel = GUICtrlCreateCheckbox($Column_Names_Channel, 34, 425, 185, 17)
		GUICtrlSetColor(-1, $TextColor)
		$CWIB_Channel = GUICtrlCreateInput($column_Width_Channel, 224, 425, 113, 21)
		GUICtrlSetColor(-1, $TextColor)

		$CWCB_Manu = GUICtrlCreateCheckbox($Column_Names_MANUF, 364, 65, 185, 17)
		GUICtrlSetColor(-1, $TextColor)
		$CWIB_Manu = GUICtrlCreateInput($column_Width_MANUF, 549, 65, 112, 21)
		GUICtrlSetColor(-1, $TextColor)
		$CWCB_Label = GUICtrlCreateCheckbox($Column_Names_Label, 364, 95, 185, 17)
		GUICtrlSetColor(-1, $TextColor)
		$CWIB_Label = GUICtrlCreateInput($column_Width_Label, 549, 95, 113, 21)
		GUICtrlSetColor(-1, $TextColor)
		$CWCB_Latitude = GUICtrlCreateCheckbox($Column_Names_Latitude, 364, 125, 185, 17)
		GUICtrlSetColor(-1, $TextColor)
		$CWIB_Latitude = GUICtrlCreateInput($column_Width_Latitude, 549, 125, 113, 21)
		GUICtrlSetColor(-1, $TextColor)
		$CWCB_Longitude = GUICtrlCreateCheckbox($Column_Names_Longitude, 364, 155, 185, 17)
		GUICtrlSetColor(-1, $TextColor)
		$CWIB_Longitude = GUICtrlCreateInput($column_Width_Longitude, 549, 155, 113, 21)
		GUICtrlSetColor(-1, $TextColor)
		$CWCB_LatitudeDMS = GUICtrlCreateCheckbox($Column_Names_LatitudeDMS, 364, 185, 185, 17)
		GUICtrlSetColor(-1, $TextColor)
		$CWIB_LatitudeDMS = GUICtrlCreateInput($column_Width_LatitudeDMS, 549, 185, 113, 21)
		GUICtrlSetColor(-1, $TextColor)
		$CWCB_LongitudeDMS = GUICtrlCreateCheckbox($Column_Names_LongitudeDMS, 364, 215, 185, 17)
		GUICtrlSetColor(-1, $TextColor)
		$CWIB_LongitudeDMS = GUICtrlCreateInput($column_Width_LatitudeDMS, 549, 215, 113, 21)
		GUICtrlSetColor(-1, $TextColor)
		$CWCB_LatitudeDMM = GUICtrlCreateCheckbox($Column_Names_LatitudeDMM, 364, 245, 185, 17)
		GUICtrlSetColor(-1, $TextColor)
		$CWIB_LatitudeDMM = GUICtrlCreateInput($column_Width_LatitudeDMM, 549, 245, 113, 21)
		GUICtrlSetColor(-1, $TextColor)
		$CWCB_LongitudeDMM = GUICtrlCreateCheckbox($Column_Names_LongitudeDMM, 364, 275, 185, 17)
		GUICtrlSetColor(-1, $TextColor)
		$CWIB_LongitudeDMM = GUICtrlCreateInput($column_Width_LongitudeDMM, 549, 275, 113, 21)
		GUICtrlSetColor(-1, $TextColor)
		$CWCB_BtX = GUICtrlCreateCheckbox($Column_Names_BasicTransferRates, 364, 305, 185, 17)
		GUICtrlSetColor(-1, $TextColor)
		$CWIB_BtX = GUICtrlCreateInput($column_Width_BasicTransferRates, 549, 305, 113, 21)
		GUICtrlSetColor(-1, $TextColor)
		$CWCB_OtX = GUICtrlCreateCheckbox($Column_Names_OtherTransferRates, 364, 335, 185, 17)
		GUICtrlSetColor(-1, $TextColor)
		$CWIB_OtX = GUICtrlCreateInput($column_Width_OtherTransferRates, 549, 335, 113, 21)
		GUICtrlSetColor(-1, $TextColor)
		$CWCB_FirstActive = GUICtrlCreateCheckbox($Column_Names_FirstActive, 364, 365, 185, 17)
		GUICtrlSetColor(-1, $TextColor)
		$CWIB_FirstActive = GUICtrlCreateInput($column_Width_FirstActive, 549, 365, 113, 21)
		GUICtrlSetColor(-1, $TextColor)
		$CWCB_LastActive = GUICtrlCreateCheckbox($Column_Names_LastActive, 364, 395, 185, 17)
		GUICtrlSetColor(-1, $TextColor)
		$CWIB_LastActive = GUICtrlCreateInput($column_Width_LastActive, 549, 395, 113, 21)
		GUICtrlSetColor(-1, $TextColor)
		_SetCwState()
		GUICtrlCreateLabel($Text_Enable & " / " & $Text_Disable, 32, 45, 175, 15)
		GUICtrlSetColor(-1, $TextColor)
		GUICtrlCreateLabel($Text_SetColumnWidths, 224, 45, 118, 15)
		GUICtrlSetColor(-1, $TextColor)
		GUICtrlCreateLabel($Text_Enable & " / " & $Text_Disable, 356, 45, 175, 15)
		GUICtrlSetColor(-1, $TextColor)
		GUICtrlCreateLabel($Text_SetColumnWidths, 548, 45, 118, 15)
		GUICtrlSetColor(-1, $TextColor)
		;Searchwords Tab
		$Tab_SW = GUICtrlCreateTabItem($Text_SearchWords)
		_GUICtrlTab_SetBkColor($SetMisc, $Settings_Tab, $BackgroundColor)
		GUICtrlCreateGroup($Text_SetSearchWords, 8, 32, 665, 425)
		GUICtrlSetColor(-1, $TextColor)
		GUICtrlCreateLabel($SearchWord_SSID, 28, 125, 300, 15)
		GUICtrlSetColor(-1, $TextColor)
		$SearchWord_SSID_GUI = GUICtrlCreateInput($SearchWord_SSID, 28, 140, 300, 20)
		GUICtrlCreateLabel($SearchWord_BSSID, 28, 165, 300, 15)
		GUICtrlSetColor(-1, $TextColor)
		$SearchWord_BSSID_GUI = GUICtrlCreateInput($SearchWord_BSSID, 28, 180, 300, 20)
		GUICtrlCreateLabel($SearchWord_Channel, 28, 205, 300, 15)
		GUICtrlSetColor(-1, $TextColor)
		$SearchWord_Channel_GUI = GUICtrlCreateInput($SearchWord_Channel, 28, 220, 300, 20)
		GUICtrlCreateLabel($SearchWord_Authentication, 28, 245, 300, 15)
		GUICtrlSetColor(-1, $TextColor)
		$SearchWord_Authentication_GUI = GUICtrlCreateInput($SearchWord_Authentication, 28, 260, 300, 20)
		GUICtrlCreateLabel($SearchWord_Encryption, 28, 285, 300, 15)
		GUICtrlSetColor(-1, $TextColor)
		$SearchWord_Encryption_GUI = GUICtrlCreateInput($SearchWord_Encryption, 28, 300, 300, 20)
		GUICtrlCreateLabel($SearchWord_RadioType, 28, 325, 300, 15)
		GUICtrlSetColor(-1, $TextColor)
		$SearchWord_RadioType_GUI = GUICtrlCreateInput($SearchWord_RadioType, 28, 340, 300, 20)
		GUICtrlCreateLabel($SearchWord_NetworkType, 28, 365, 300, 15)
		GUICtrlSetColor(-1, $TextColor)
		$SearchWord_NetType_GUI = GUICtrlCreateInput($SearchWord_NetworkType, 28, 380, 300, 20)
		GUICtrlCreateLabel($SearchWord_Signal, 28, 405, 300, 15)
		GUICtrlSetColor(-1, $TextColor)
		$SearchWord_Signal_GUI = GUICtrlCreateInput($SearchWord_Signal, 28, 420, 300, 20)
		GUICtrlCreateLabel($SearchWord_BasicRates, 353, 125, 300, 15)
		GUICtrlSetColor(-1, $TextColor)
		$SearchWord_BasicRates_GUI = GUICtrlCreateInput($SearchWord_BasicRates, 353, 140, 300, 20)
		GUICtrlCreateLabel($SearchWord_OtherRates, 353, 165, 300, 15)
		GUICtrlSetColor(-1, $TextColor)
		$SearchWord_OtherRates_GUI = GUICtrlCreateInput($SearchWord_OtherRates, 353, 180, 300, 20)
		GUICtrlCreateLabel($SearchWord_Open, 353, 205, 300, 15)
		GUICtrlSetColor(-1, $TextColor)
		$SearchWord_Open_GUI = GUICtrlCreateInput($SearchWord_Open, 353, 220, 300, 20)
		GUICtrlCreateLabel($SearchWord_None, 353, 245, 300, 15)
		GUICtrlSetColor(-1, $TextColor)
		$SearchWord_None_GUI = GUICtrlCreateInput($SearchWord_None, 353, 260, 300, 20)
		GUICtrlCreateLabel($SearchWord_Wep, 353, 285, 300, 15)
		GUICtrlSetColor(-1, $TextColor)
		$SearchWord_Wep_GUI = GUICtrlCreateInput($SearchWord_Wep, 353, 300, 300, 20)
		GUICtrlCreateLabel($SearchWord_Infrastructure, 353, 325, 300, 15)
		GUICtrlSetColor(-1, $TextColor)
		$SearchWord_Infrastructure_GUI = GUICtrlCreateInput($SearchWord_Infrastructure, 353, 340, 300, 20)
		GUICtrlCreateLabel($SearchWord_Adhoc, 353, 365, 300, 15)
		GUICtrlSetColor(-1, $TextColor)
		$SearchWord_Adhoc_GUI = GUICtrlCreateInput($SearchWord_Adhoc, 353, 380, 300, 20)
		$GuiGuessSearchwords = GUICtrlCreateButton($Text_GuessSearchwords, 353, 420, 300, 20)
		$swdesc = GUICtrlCreateGroup($Text_Description, 24, 56, 633, 65)
		GUICtrlSetColor(-1, $TextColor)
		GUICtrlCreateLabel($Text_NetshMsg, 32, 72, 618, 41)
		GUICtrlSetColor(-1, $TextColor)
		;----------------------------
		;Auto Tab
		;----------------------------
		$Tab_Auto = GUICtrlCreateTabItem($Text_Auto)
		_GUICtrlTab_SetBkColor($SetMisc, $Settings_Tab, $BackgroundColor)
		GUICtrlCreateGroup($Text_AutoKml, 16, 40, 650, 240);Auto Save Group
		GUICtrlSetColor(-1, $TextColor)
		$GUI_AutoSaveKml = GUICtrlCreateCheckbox($Text_AutoKml, 30, 60, 625, 15)
		GUICtrlSetColor(-1, $TextColor)
		If $AutoKML = 1 Then GUICtrlSetState($GUI_AutoSaveKml, $GUI_CHECKED)
		$GUI_OpenKmlNetLink = GUICtrlCreateCheckbox($Text_AutoOpenNetworkLink, 30, 80, 625, 15)
		GUICtrlSetColor(-1, $TextColor)
		If $OpenKmlNetLink = 1 Then GUICtrlSetState($GUI_OpenKmlNetLink, $GUI_CHECKED)
		GUICtrlCreateLabel($Text_GoogleEarthEXE, 30, 100, 62, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GUI_GoogleEXE = GUICtrlCreateInput($GoogleEarthExe, 30, 115, 515, 20)
		$browsege = GUICtrlCreateButton($Text_Browse, 555, 115, 97, 20, 0)
		GUICtrlCreateLabel($Text_ActiveRefreshTime & '(s)', 30, 140, 115, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GUI_AutoKmlActiveTime = GUICtrlCreateInput($AutoKmlActiveTime, 30, 155, 115, 20)
		GUICtrlCreateLabel($Text_DeadRefreshTime & '(s)', 155, 140, 115, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GUI_AutoKmlDeadTime = GUICtrlCreateInput($AutoKmlDeadTime, 155, 155, 115, 20)
		GUICtrlCreateLabel($Text_GpsRefrshTime & '(s)', 280, 140, 115, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GUI_AutoKmlGpsTime = GUICtrlCreateInput($AutoKmlGpsTime, 280, 155, 115, 20)
		GUICtrlCreateLabel($Text_GpsTrackTime & '(s)', 405, 140, 115, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GUI_AutoKmlTrackTime = GUICtrlCreateInput($AutoKmlTrackTime, 405, 155, 115, 20)
		;Fly To Settings
		GUICtrlCreateGroup($Text_FlyToSettings, 30, 180, 620, 90)
		$GUI_KmlFlyTo = GUICtrlCreateCheckbox($Text_FlyToCurrentGps, 45, 200, 570, 15)
		GUICtrlSetColor(-1, $TextColor)
		If $KmlFlyTo = 1 Then GUICtrlSetState($GUI_KmlFlyTo, $GUI_CHECKED)
		GUICtrlCreateLabel($Text_Altitude & '(m)', 45, 220, 110, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GUI_AutoKml_Alt = GUICtrlCreateInput($AutoKML_Alt, 45, 235, 110, 20)
		GUICtrlCreateLabel($Text_AltitudeMode, 165, 220, 110, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GUI_AutoKml_AltMode = GUICtrlCreateCombo('clampToGround', 165, 235, 110, 20)
		GUICtrlSetData(-1, "relativeToGround|absolute", $AutoKML_AltMode)
		GUICtrlCreateLabel($Text_Range & '(m)', 285, 220, 110, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GUI_AutoKml_Range = GUICtrlCreateInput($AutoKML_Range, 285, 235, 110, 20)
		GUICtrlCreateLabel($Text_Heading & '(0-360)', 405, 220, 110, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GUI_AutoKml_Heading = GUICtrlCreateInput($AutoKML_Heading, 405, 235, 110, 20)
		GUICtrlCreateLabel($Text_Tilt & '(0-90)', 525, 220, 110, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GUI_AutoKml_Tilt = GUICtrlCreateInput($AutoKML_Tilt, 525, 235, 110, 20)
		;Auto Sort Group
		GUICtrlCreateGroup($Text_AutoSort, 15, 285, 650, 169)
		GUICtrlSetColor(-1, $TextColor)
		$GUI_AutoSort = GUICtrlCreateCheckbox($Text_AutoSort, 30, 310, 625, 15)
		GUICtrlSetColor(-1, $TextColor)
		If $AutoSort = 1 Then GUICtrlSetState($GUI_AutoSort, $GUI_CHECKED)
		GUICtrlCreateLabel($Text_SortBy, 30, 330, 625, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GUI_SortBy = GUICtrlCreateCombo($Column_Names_SSID, 30, 345, 615, 21)
		GUICtrlSetData(-1, $Column_Names_NetworkType & "|" & $Column_Names_Authentication & "|" & $Column_Names_Encryption & "|" & $Column_Names_BSSID & "|" & $Column_Names_Signal & "|" & $Column_Names_HighSignal & "|" & $Column_Names_RSSI & "|" & $Column_Names_HighRSSI & "|" & $Column_Names_RadioType & "|" & $Column_Names_Channel & "|" & $Column_Names_BasicTransferRates & "|" & $Column_Names_OtherTransferRates & "|" & $Column_Names_Latitude & "|" & $Column_Names_Longitude & "|" & $Column_Names_LatitudeDMM & "|" & $Column_Names_LongitudeDMM & "|" & $Column_Names_LatitudeDMS & "|" & $Column_Names_LongitudeDMS & "|" & $Column_Names_FirstActive & "|" & $Column_Names_LastActive & "|" & $Column_Names_Active & "|" & $Column_Names_MANUF, $SortBy)
		If $SortDirection = 1 Then
			$SortDirectionDefault = $Text_Decending
		Else
			$SortDirectionDefault = $Text_Ascending
		EndIf
		GUICtrlCreateLabel($Text_SortDirection, 30, 370, 625, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GUI_SortDirection = GUICtrlCreateCombo($Text_Ascending, 30, 385, 615, 21)
		GUICtrlSetData(-1, $Text_Decending, $SortDirectionDefault)
		GUICtrlCreateLabel($Text_AutoSortEvery & '(s)', 30, 410, 625, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GUI_SortTime = GUICtrlCreateInput($SortTime, 30, 425, 115, 20)
		;----------------------------
		;Sound Tab
		;----------------------------
		$Tab_Sound = GUICtrlCreateTabItem($Text_Sound)
		_GUICtrlTab_SetBkColor($SetMisc, $Settings_Tab, $BackgroundColor)
		GUICtrlCreateGroup($Text_PlaySound, 16, 40, 650, 105)
		$GUI_NewApSound = GUICtrlCreateCheckbox($Text_PlaySound, 30, 60, 300, 15)
		GUICtrlSetColor(-1, $TextColor)
		If $SoundOnAP = 1 Then GUICtrlSetState($GUI_NewApSound, $GUI_CHECKED)
		$GUI_ASperloop = GUICtrlCreateRadio($Text_OncePerLoop, 30, 80, 300, 15)
		If $SoundPerAP = 0 Then GUICtrlSetState($GUI_ASperloop, $GUI_CHECKED)
		$GUI_ASperap = GUICtrlCreateRadio($Text_OncePerAP, 30, 100, 300, 15)
		If $SoundPerAP = 1 And $NewSoundSigBased = 0 Then GUICtrlSetState($GUI_ASperap, $GUI_CHECKED)
		$GUI_ASperapwsound = GUICtrlCreateRadio($Text_OncePerAPwSound, 30, 120, 300, 15)
		If $SoundPerAP = 1 And $NewSoundSigBased = 1 Then GUICtrlSetState($GUI_ASperapwsound, $GUI_CHECKED)
		;Speak Signal Options
		GUICtrlCreateGroup($Text_SpeakSignal, 16, 155, 650, 145)
		$GUI_SpeakSignal = GUICtrlCreateCheckbox($Text_SpeakSignal, 30, 175, 200, 15)
		GUICtrlSetColor(-1, $TextColor)
		If $SpeakSignal = 1 Then GUICtrlSetState($GUI_SpeakSignal, $GUI_CHECKED)
		$GUI_SpeakSoundsVis = GUICtrlCreateRadio($Text_SpeakUseVisSounds, 30, 195, 200, 15)
		$GUI_SpeakSoundsSapi = GUICtrlCreateRadio($Text_SpeakUseSapi, 30, 215, 200, 15)
		$GUI_SpeakSoundsMidi = GUICtrlCreateRadio($Text_MIDI, 30, 235, 200, 15)
		GUICtrlSetColor($GUI_SpeakSoundsVis, $TextColor)
		GUICtrlSetColor($GUI_SpeakSoundsSapi, $TextColor)
		GUICtrlSetColor($GUI_SpeakSoundsMidi, $TextColor)
		If $SpeakType = 1 Then
			GUICtrlSetState($GUI_SpeakSoundsVis, $GUI_CHECKED)
		ElseIf $SpeakType = 2 Then
			GUICtrlSetState($GUI_SpeakSoundsSapi, $GUI_CHECKED)
		ElseIf $SpeakType = 3 Then
			GUICtrlSetState($GUI_SpeakSoundsMidi, $GUI_CHECKED)
		EndIf
		GUICtrlCreateLabel($Text_SpeakRefreshTime & '(ms)', 30, 255, 150, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GUI_SpeakSigTime = GUICtrlCreateInput($SpeakSigTime, 30, 270, 150, 20)
		GUICtrlSetColor(-1, $TextColor)
		$GUI_SpeakPercent = GUICtrlCreateCheckbox($Text_SpeakSayPercent, 200, 270, 150, 15)
		GUICtrlSetColor(-1, $TextColor)
		If $SpeakSigSayPecent = 1 Then GUICtrlSetState($GUI_SpeakPercent, $GUI_CHECKED)

		GUICtrlCreateGroup($Text_MIDI, 16, 310, 650, 135)
		$GUI_PlayMidiSounds = GUICtrlCreateCheckbox($Text_PlayMidiSounds, 30, 330, 200, 15)
		If $Midi_PlayForActiveAps = 1 Then GUICtrlSetState($GUI_PlayMidiSounds, $GUI_CHECKED)
		GUICtrlCreateLabel($Text_MidiInstrumentNumber, 30, 350, 150, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GUI_Midi_Instument = GUICtrlCreateCombo('', 30, 365, 310, 20)
		$query = "SELECT INSTNUM, INSTTEXT FROM Instruments"
		$InstMatchArray = _RecordSearch($InstDB, $query, $InstDB_OBJ)
		$FoundInstMatch = UBound($InstMatchArray) - 1
		GUICtrlSetData($msgdisplay, $Text_VistumblerSettings & ' - Loading ' & $FoundInstMatch & ' Instrument(s)')
		For $m = 1 To $FoundInstMatch
			$INSTNUM = $InstMatchArray[$m][1]
			$INSTTEXT = $InstMatchArray[$m][2]
			If $INSTNUM = $Midi_Instument Then
				GUICtrlSetData($GUI_Midi_Instument, $INSTNUM & ' - ' & $INSTTEXT, $INSTNUM & ' - ' & $INSTTEXT)
			Else
				GUICtrlSetData($GUI_Midi_Instument, $INSTNUM & ' - ' & $INSTTEXT)
			EndIf
		Next
		GUICtrlSetColor(-1, $TextColor)
		GUICtrlCreateLabel($Text_MidiPlayTime & '(ms)', 30, 390, 150, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GUI_Midi_PlayTime = GUICtrlCreateInput($Midi_PlayTime, 30, 405, 310, 20)
		GUICtrlSetColor(-1, $TextColor)
		;----------------------------
		;WifiDB Tab
		;----------------------------
		$Tab_WifiDB = GUICtrlCreateTabItem($Text_WifiDB)
		_GUICtrlTab_SetBkColor($SetMisc, $Settings_Tab, $BackgroundColor)
		GUICtrlCreateGroup($Text_WifiDB, 15, 40, 650, 250)
		GUICtrlCreateLabel("WifiDB Username", 28, 77, 88, 15)
		$GUI_WifiDB_User = GUICtrlCreateInput($WifiDb_User, 123, 75, 185, 20)
		GUICtrlCreateLabel("WifiDB API Key", 328, 77, 78, 15)
		$GUI_WifiDB_ApiKey = GUICtrlCreateInput($WifiDb_ApiKey, 411, 75, 185, 20)
		;GUICtrlSetState($GUI_WifiDB_ApiKey, $GUI_DISABLE);disable because wifidb api key is not yet implemented
		GUICtrlCreateLabel($Text_PHPgraphing, 31, 110, 620, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GUI_WifiDbGraphURL = GUICtrlCreateInput($WifiDbGraphURL, 31, 125, 620, 20)
		GUICtrlCreateLabel($Text_WifiDbWDB, 32, 150, 620, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GUI_WifiDbWdbURL = GUICtrlCreateInput($WifiDbWdbURL, 32, 165, 620, 20)
		GUICtrlCreateLabel("WifiDB API URL", 32, 190, 620, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GUI_WifiDbApiURL = GUICtrlCreateInput($WifiDbApiURL, 32, 205, 620, 20)

		GUICtrlCreateGroup($Text_AutoWiFiDbGpsLocate, 15, 300, 320, 85)
		$GUI_WifidbLocate = GUICtrlCreateCheckbox($Text_AutoWiFiDbGpsLocate, 30, 320, 300, 15)
		GUICtrlSetColor(-1, $TextColor)
		If $UseWiFiDbGpsLocate = 1 Then GUICtrlSetState($GUI_WifidbLocate, $GUI_CHECKED)
		GUICtrlCreateLabel($Text_RefreshTime & '(s)', 30, 340, 615, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GUI_WiFiDbLocateRefreshTime = GUICtrlCreateInput(($WiFiDbLocateRefreshTime / 1000), 30, 355, 115, 20)
		GUICtrlSetColor(-1, $TextColor)

		GUICtrlCreateGroup($Text_AutoWiFiDbUploadAps, 346, 300, 320, 85)
		$GUI_WifidbUploadAps = GUICtrlCreateCheckbox($Text_AutoWiFiDbUploadAps, 360, 320, 300, 15)
		GUICtrlSetColor(-1, $TextColor)
		If $AutoUpApsToWifiDB = 1 Then GUICtrlSetState($GUI_WifidbUploadAps, $GUI_CHECKED)
		;GUICtrlSetState($GUI_WifidbUploadAps, $GUI_DISABLE); Upload to WifiDB is not ready yet. The checkbox will be disabled untill it is available
		GUICtrlCreateLabel($Text_RefreshTime & '(s)', 360, 340, 615, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GUI_AutoUpApsToWifiDBTime = GUICtrlCreateInput($AutoUpApsToWifiDBTime, 360, 355, 115, 20)
		GUICtrlSetColor(-1, $TextColor)

		;Camera tab
		$Tab_Cam = GUICtrlCreateTabItem($Text_Cameras)
		_GUICtrlTab_SetBkColor($SetMisc, $Settings_Tab, $BackgroundColor)
		GUICtrlCreateLabel($Text_CameraName, 34, 39, 195, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GUI_Cam_NewID = GUICtrlCreateInput("", 34, 56, 195, 21)
		GUICtrlCreateLabel($Text_CameraURL, 244, 39, 410, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GUI_Cam_NewLOC = GUICtrlCreateInput("", 244, 56, 410, 21)
		GUICtrlSetColor(-1, $TextColor)
		$Add_Cam = GUICtrlCreateButton($Text_AddCamera, 24, 90, 201, 25, 0)
		$Remove_Cam = GUICtrlCreateButton($Text_RemoveCamera, 239, 90, 201, 25, 0)
		$Edit_Cam = GUICtrlCreateButton($Text_EditCamera, 456, 90, 201, 25, 0)
		$GUI_Cam_List = GUICtrlCreateListView($Text_CameraName & "|" & $Text_CameraURL, 24, 125, 634, 150, $LVS_REPORT, $LVS_EX_HEADERDRAGDROP + $LVS_EX_GRIDLINES + $LVS_EX_FULLROWSELECT)
		GUICtrlSetBkColor(-1, $ControlBackgroundColor)
		_GUICtrlListView_SetColumnWidth($GUI_Cam_List, 0, 160)
		_GUICtrlListView_SetColumnWidth($GUI_Cam_List, 1, 450)
		;Add cameras to list
		$query = "SELECT CamName, CamUrl FROM Cameras"
		$CamMatchArray = _RecordSearch($CamDB, $query, $CamDB_OBJ)
		$FoundCamMatch = UBound($CamMatchArray) - 1
		GUICtrlSetData($msgdisplay, $Text_VistumblerSettings & ' - Loading ' & $FoundCamMatch & ' ' & $Text_Cameras)
		For $c = 1 To $FoundCamMatch
			$camname = $CamMatchArray[$c][1]
			$camurl = $CamMatchArray[$c][2]
			GUICtrlCreateListViewItem('"' & $camname & '"|' & $camurl, $GUI_Cam_List)
		Next
		GUICtrlSetData($msgdisplay, '')
		GUICtrlCreateGroup($Text_CameraTriggerScript, 15, 300, 650, 150)
		$Gui_CamTrigger = GUICtrlCreateCheckbox($Text_EnableCamTriggerScript, 31, 320, 185, 17)
		If $CamTrigger = 1 Then GUICtrlSetState(-1, $GUI_CHECKED)
		GUICtrlSetColor(-1, $TextColor)
		GUICtrlSetColor(-1, $TextColor)
		GUICtrlCreateLabel($Text_CameraTriggerScriptTypes, 31, 345, 620, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GUI_CamTriggerScript = GUICtrlCreateInput($CamTriggerScript, 31, 360, 515, 21)
		GUICtrlCreateLabel($Text_RefreshTime, 31, 385, 620, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GUI_CamTriggerTime = GUICtrlCreateInput($CamTriggerTime, 31, 400, 515, 21)
		$csbrowse1 = GUICtrlCreateButton($Text_Browse, 556, 360, 97, 20, 0)
		GUICtrlCreateTabItem("");END OF TABS

		$GUI_Set_Ok = GUICtrlCreateButton($Text_Ok, 455, 472, 75, 25, 0)
		$GUI_Set_Can = GUICtrlCreateButton($Text_Cancel, 530, 472, 75, 25, 0)
		$GUI_Set_Apply = GUICtrlCreateButton($Text_Apply, 605, 472, 73, 25, 0)

		If $StartTab = 0 Then GUICtrlSetState($Tab_Misc, $GUI_SHOW)
		If $StartTab = 1 Then GUICtrlSetState($Tab_Save, $GUI_SHOW)
		If $StartTab = 2 Then GUICtrlSetState($Tab_Gps, $GUI_SHOW)
		If $StartTab = 3 Then GUICtrlSetState($Tab_Lan, $GUI_SHOW)
		If $StartTab = 4 Then GUICtrlSetState($Tab_Manu, $GUI_SHOW)
		If $StartTab = 5 Then GUICtrlSetState($Tab_Lab, $GUI_SHOW)
		If $StartTab = 6 Then GUICtrlSetState($Tab_Col, $GUI_SHOW)
		If $StartTab = 7 Then GUICtrlSetState($Tab_SW, $GUI_SHOW)
		If $StartTab = 8 Then GUICtrlSetState($Tab_Auto, $GUI_SHOW)
		If $StartTab = 9 Then GUICtrlSetState($Tab_Sound, $GUI_SHOW)
		If $StartTab = 10 Then GUICtrlSetState($Tab_WifiDB, $GUI_SHOW)
		If $StartTab = 11 Then GUICtrlSetState($Tab_Cam, $GUI_SHOW)

		GUICtrlSetOnEvent($Add_MANU, '_AddManu')
		GUICtrlSetOnEvent($Edit_MANU, '_EditManu')
		GUICtrlSetOnEvent($Remove_MANU, '_RemoveManu')
		GUICtrlSetOnEvent($Add_Lab, '_AddLabel')
		GUICtrlSetOnEvent($Edit_Lab, '_EditLabel')
		GUICtrlSetOnEvent($Remove_Lab, '_RemoveLabel')
		GUICtrlSetOnEvent($Add_Cam, '_AddCam')
		GUICtrlSetOnEvent($Edit_Cam, '_EditCam')
		GUICtrlSetOnEvent($Remove_Cam, '_RemoveCam')

		GUICtrlSetOnEvent($browse1, '_BrowseSave')
		GUICtrlSetOnEvent($Browse2, '_BrowseAutoSave')
		GUICtrlSetOnEvent($Browse3, '_BrowseKmlSave')

		GUICtrlSetOnEvent($browsege, '_BrowseGoogleEarth')

		GUICtrlSetOnEvent($cbrowse1, '_ColorBrowse1')
		GUICtrlSetOnEvent($cbrowse2, '_ColorBrowse2')
		GUICtrlSetOnEvent($cbrowse3, '_ColorBrowse3')

		GUICtrlSetOnEvent($csbrowse1, '_CamScriptBrowse')

		GUISetOnEvent($GUI_EVENT_CLOSE, '_CloseSettingsGUI')
		GUICtrlSetOnEvent($GUI_Set_Can, '_CloseSettingsGUI')
		GUICtrlSetOnEvent($GUI_Set_Apply, '_ApplySettingsGUI')
		GUICtrlSetOnEvent($ImpLanBrowse, '_ImportLanguageBrowse')
		GUICtrlSetOnEvent($ImpLanButton, '_ImportLanguage')
		GUICtrlSetOnEvent($GUI_Set_Ok, '_OkSettingsGUI')
		GUICtrlSetOnEvent($CWCB_Line, '_SetWidthValue_Line')
		GUICtrlSetOnEvent($CWCB_Active, '_SetWidthValue_Active')
		GUICtrlSetOnEvent($CWCB_SSID, '_SetWidthValue_SSID')
		GUICtrlSetOnEvent($CWCB_BSSID, '_SetWidthValue_BSSID')
		GUICtrlSetOnEvent($CWCB_Signal, '_SetWidthValue_Signal')
		GUICtrlSetOnEvent($CWCB_HighSignal, '_SetWidthValue_HighSignal')
		GUICtrlSetOnEvent($CWCB_RSSI, '_SetWidthValue_RSSI')
		GUICtrlSetOnEvent($CWCB_HighRSSI, '_SetWidthValue_HighRSSI')
		GUICtrlSetOnEvent($CWCB_Authentication, '_SetWidthValue_Authentication')
		GUICtrlSetOnEvent($CWCB_Encryption, '_SetWidthValue_Encryption')
		GUICtrlSetOnEvent($CWCB_RadioType, '_SetWidthValue_RadioType')
		GUICtrlSetOnEvent($CWCB_NetType, '_SetWidthValue_NetType')
		GUICtrlSetOnEvent($CWCB_Manu, '_SetWidthValue_Manu')
		GUICtrlSetOnEvent($CWCB_Channel, '_SetWidthValue_Channel')
		GUICtrlSetOnEvent($CWCB_Label, '_SetWidthValue_Label')
		GUICtrlSetOnEvent($CWCB_Latitude, '_SetWidthValue_Latitude')
		GUICtrlSetOnEvent($CWCB_Longitude, '_SetWidthValue_Longitude')
		GUICtrlSetOnEvent($CWCB_LatitudeDMS, '_SetWidthValue_LatitudeDMS')
		GUICtrlSetOnEvent($CWCB_LongitudeDMS, '_SetWidthValue_LongitudeDMS')
		GUICtrlSetOnEvent($CWCB_LatitudeDMM, '_SetWidthValue_LatitudeDMM')
		GUICtrlSetOnEvent($CWCB_LongitudeDMM, '_SetWidthValue_LongitudeDMM')
		GUICtrlSetOnEvent($CWCB_BtX, '_SetWidthValue_Btx')
		GUICtrlSetOnEvent($CWCB_OtX, '_SetWidthValue_Otx')
		GUICtrlSetOnEvent($CWCB_FirstActive, '_SetWidthValue_FirstActive')
		GUICtrlSetOnEvent($CWCB_LastActive, '_SetWidthValue_LastActive')
		GUICtrlSetOnEvent($LanguageBox, '_LanguageChanged')
		GUICtrlSetOnEvent($GuiGuessSearchwords, '_GuessNetshSearchwords')
		GUICtrlSetOnEvent($GUI_Manu_List, '_ManufacturerSort')
		GUICtrlSetOnEvent($GUI_Lab_List, '_LabelSort')

		GUISetState(@SW_SHOW)
	EndIf
EndFunc   ;==>_SettingsGUI

Func _CamScriptBrowse()
	$camscriptfile = FileOpenDialog("Select camera script file", @ScriptDir, "Cam Script File (*.exe;*.bat)", 1 + 4)
	If Not @error Then
		GUICtrlSetData($GUI_CamTriggerScript, $camscriptfile)
	EndIf
EndFunc   ;==>_CamScriptBrowse

Func _ColorBrowse1()
	$color = _ChooseColor(2, $BackgroundColor, 2, $SetMisc)
	If $color <> -1 Then GUICtrlSetData($GUI_BKColor, StringReplace($color, "0x", ""))
EndFunc   ;==>_ColorBrowse1

Func _ColorBrowse2()
	$color = _ChooseColor(2, $ControlBackgroundColor, 2, $SetMisc)
	If $color <> -1 Then GUICtrlSetData($GUI_CBKColor, StringReplace($color, "0x", ""))
EndFunc   ;==>_ColorBrowse2

Func _ColorBrowse3()
	$color = _ChooseColor(2, $TextColor, 2, $SetMisc)
	If $color <> -1 Then GUICtrlSetData($GUI_TextColor, StringReplace($color, "0x", ""))
EndFunc   ;==>_ColorBrowse3

Func _BrowseGoogleEarth()
	$file = FileOpenDialog($Text_GoogleEarthEXE, "C:\Program Files (x86)\Google\Google Earth\client\", "Google Earth (googleearth.exe)", $FD_FILEMUSTEXIST)
	If Not @error Then
		GUICtrlSetData($GUI_GoogleEXE, $file)
	EndIf
EndFunc   ;==>_BrowseSave

Func _BrowseSave()
	$folder = FileSelectFolder($Text_VistumblerSaveDirectory, '', 1, GUICtrlRead($GUI_Set_SaveDir))
	If Not @error Then
		If StringTrimLeft($folder, StringLen($folder) - 1) <> "\" Then $folder = $folder & "\" ;If directory does not have training \ then add it
		GUICtrlSetData($GUI_Set_SaveDir, $folder)
	EndIf
EndFunc   ;==>_BrowseSave

Func _BrowseAutoSave()
	$folder = FileSelectFolder($Text_VistumblerAutoSaveDirectory, '', 1, GUICtrlRead($GUI_Set_SaveDirAuto))
	If Not @error Then
		If StringTrimLeft($folder, StringLen($folder) - 1) <> "\" Then $folder = $folder & "\" ;If directory does not have training \ then add it
		GUICtrlSetData($GUI_Set_SaveDirAuto, $folder)
	EndIf
EndFunc   ;==>_BrowseAutoSave

Func _BrowseKmlSave()
	$folder = FileSelectFolder($Text_VistumblerKmlSaveDirectory, '', 1, GUICtrlRead($GUI_Set_SaveDirKml))
	If Not @error Then
		If StringTrimLeft($folder, StringLen($folder) - 1) <> "\" Then $folder = $folder & "\" ;If directory does not have training \ then add it
		GUICtrlSetData($GUI_Set_SaveDirKml, $folder)
	EndIf
EndFunc   ;==>_BrowseKmlSave

Func _ImportLanguageBrowse();opens a browse window to import a language file
	$languagefile = FileOpenDialog("Select Language File", $SaveDir, "Vistumbler Language File (*.ini)", 1)
	If Not @error Then
		GUICtrlSetData($ImpLanFile, $languagefile)
	EndIf
EndFunc   ;==>_ImportLanguageBrowse

Func _ImportLanguage();Copies language file to the languages directory
	$imfile = GUICtrlRead($ImpLanFile)
	If $imfile <> '' Then
		$lastslash = StringInStr($imfile, "\", 0, -1)
		$filename = StringTrimLeft($imfile, $lastslash)
		FileDelete($LanguageDir & $filename)
		FileCopy($imfile, $LanguageDir & $filename)
	EndIf
EndFunc   ;==>_ImportLanguage

Func _LanguageChanged();Sets language information in gui if language changed
	$Apply_Language = 1
	$Apply_Searchword = 1
	$Language = GUICtrlRead($LanguageBox)
	$languagefile = $LanguageDir & $Language & ".ini"
	GUICtrlSetData($LabAuth, IniRead($languagefile, 'Info', 'Author', ''))
	GUICtrlSetData($LabDate, _DateLocalFormat(IniRead($languagefile, 'Info', 'Date', '')))
	GUICtrlSetData($LabWinCode, IniRead($languagefile, 'Info', 'WindowsLanguageCode', ''))
	GUICtrlSetData($LabDesc, IniRead($languagefile, 'Info', 'Description', ''))
	GUICtrlSetData($SearchWord_SSID_GUI, IniRead($languagefile, 'SearchWords', 'SSID', 'SSID'))
	GUICtrlSetData($SearchWord_BSSID_GUI, IniRead($languagefile, 'SearchWords', 'BSSID', 'BSSID'))
	GUICtrlSetData($SearchWord_Channel_GUI, IniRead($languagefile, 'SearchWords', 'Channel', 'Channel'))
	GUICtrlSetData($SearchWord_Authentication_GUI, IniRead($languagefile, 'SearchWords', 'Authentication', 'Authentication'))
	GUICtrlSetData($SearchWord_Encryption_GUI, IniRead($languagefile, 'SearchWords', 'Encryption', 'Encryption'))
	GUICtrlSetData($SearchWord_RadioType_GUI, IniRead($languagefile, 'SearchWords', 'RadioType', 'Radio Type'))
	GUICtrlSetData($SearchWord_NetType_GUI, IniRead($languagefile, 'SearchWords', 'NetworkType', 'Network type'))
	GUICtrlSetData($SearchWord_Signal_GUI, IniRead($languagefile, 'SearchWords', 'Signal', 'Signal'))
	;GUICtrlSetData($SearchWord_RSSI_GUI, IniRead($languagefile, 'SearchWords', 'RSSI', 'RSSI'))
	GUICtrlSetData($SearchWord_BasicRates_GUI, IniRead($languagefile, 'SearchWords', 'BasicRates', 'Basic Rates'))
	GUICtrlSetData($SearchWord_OtherRates_GUI, IniRead($languagefile, 'SearchWords', 'OtherRates', 'Other Rates'))
	GUICtrlSetData($SearchWord_Open_GUI, IniRead($languagefile, 'SearchWords', 'Open', 'Open'))
	GUICtrlSetData($SearchWord_None_GUI, IniRead($languagefile, 'SearchWords', 'None', 'None'))
	GUICtrlSetData($SearchWord_Wep_GUI, IniRead($languagefile, 'SearchWords', 'Wep', 'WEP'))
	GUICtrlSetData($SearchWord_Infrastructure_GUI, IniRead($languagefile, 'SearchWords', 'Infrastructure', 'Infrastructure'))
	GUICtrlSetData($SearchWord_Adhoc_GUI, IniRead($languagefile, 'SearchWords', 'Adhoc', 'Adhoc'))
EndFunc   ;==>_LanguageChanged

Func _CloseSettingsGUI();closes settings gui
	GUIDelete($SetMisc)
	$SettingsOpen = 0
EndFunc   ;==>_CloseSettingsGUI

Func _OkSettingsGUI();Applys settings and closes settings gui
	_ApplySettingsGUI()
	_CloseSettingsGUI()
	_WriteINI()
EndFunc   ;==>_OkSettingsGUI

Func _ApplySettingsGUI();Applys settings
	$RestartVistumbler = 0
	If $Apply_Misc = 1 Then
		$BackgroundColor = '0x' & StringUpper(GUICtrlRead($GUI_BKColor))
		$ControlBackgroundColor = '0x' & StringUpper(GUICtrlRead($GUI_CBKColor))
		$TextColor = '0x' & StringUpper(GUICtrlRead($GUI_TextColor))
		$dBmMaxSignal = GUICtrlRead($GUI_dBmMaxSignal)
		$dBmDissociationSignal = GUICtrlRead($GUI_dBmDisassociationSignal)
		$RefreshLoopTime = GUICtrlRead($GUI_RefreshLoop)
		$TimeBeforeMarkedDead = GUICtrlRead($GUI_TimeBeforeMarkingDead)
		If $TimeBeforeMarkedDead > 86400 Then $TimeBeforeMarkedDead = 86400
		If GUICtrlRead($GUI_AutoCheckForUpdates) = 1 Then
			$AutoCheckForUpdates = 1
		Else
			$AutoCheckForUpdates = 0
		EndIf
		If GUICtrlRead($GUI_CheckForBetaUpdates) = 1 Then
			$CheckForBetaUpdates = 1
		Else
			$CheckForBetaUpdates = 0
		EndIf
		;Auto Refresh
		If GUICtrlRead($GUI_RefreshNetworks) = 4 And $RefreshNetworks = 1 Then _AutoRefreshToggle()
		If GUICtrlRead($GUI_RefreshNetworks) = 1 And $RefreshNetworks = 0 Then _AutoRefreshToggle()
		$RefreshTime = (GUICtrlRead($GUI_RefreshTime) * 1000)
	EndIf
	If $Apply_Save = 1 Then
		$Tmp_SaveDir = GUICtrlRead($GUI_Set_SaveDir)
		$Tmp_SaveDirAuto = GUICtrlRead($GUI_Set_SaveDirAuto)
		$Tmp_SaveDirKml = GUICtrlRead($GUI_Set_SaveDirKml)
		If StringTrimLeft($Tmp_SaveDir, StringLen($Tmp_SaveDir) - 1) <> "\" Then $Tmp_SaveDir = $Tmp_SaveDir & "\" ;If directory does not have trailing \ then add it
		If StringTrimLeft($Tmp_SaveDirAuto, StringLen($Tmp_SaveDirAuto) - 1) <> "\" Then $Tmp_SaveDirAuto = $Tmp_SaveDirAuto & "\" ;If directory does not have trailing \ then add it
		If StringTrimLeft($Tmp_SaveDirKml, StringLen($Tmp_SaveDirKml) - 1) <> "\" Then $Tmp_SaveDirKml = $Tmp_SaveDirKml & "\" ;If directory does not have trailing \ then add it
		$SaveDir = $Tmp_SaveDir
		$SaveDirAuto = $Tmp_SaveDirAuto
		$SaveDirKml = $Tmp_SaveDirKml

		;Auto Save and Clear
		If GUICtrlRead($AutoSaveAndClearBox) = 4 And $AutoSaveAndClear = 1 Then _AutoSaveAndClearToggle()
		If GUICtrlRead($AutoSaveAndClearBox) = 1 And $AutoSaveAndClear = 0 Then _AutoSaveAndClearToggle()

		If GUICtrlRead($AutoSaveAndClearRadioAP) = 1 Then
			$AutoSaveAndClearOnAPs = 1
			$AutoSaveAndClearOnTime = 0
		Else
			$AutoSaveAndClearOnAPs = 0
			$AutoSaveAndClearOnTime = 1
		EndIf
		$AutoSaveAndClearAPs = GUICtrlRead($AutoSaveAndClearAPsGUI)
		$AutoSaveAndClearTime = GUICtrlRead($AutoSaveAndClearTimeGUI)

		;Auto Recovery VS1
		If GUICtrlRead($AutoRecoveryBox) = 4 And $AutoRecoveryVS1 = 1 Then _AutoRecoveryVS1Toggle()
		If GUICtrlRead($AutoRecoveryBox) = 1 And $AutoRecoveryVS1 = 0 Then _AutoRecoveryVS1Toggle()
		If GUICtrlRead($AutoRecoveryDelBox) = 1 Then
			$AutoRecoveryVS1Del = 1
		Else
			$AutoRecoveryVS1Del = 0
		EndIf
		$AutoRecoveryTime = GUICtrlRead($AutoRecoveryTimeGUI)
		If GUICtrlRead($AutoSaveAndClearPlaySoundGUI) = 1 Then
			$AutoSaveAndClearPlaySound = 1
		Else
			$AutoSaveAndClearPlaySound = 0
		EndIf
	EndIf
	If $Apply_GPS = 1 Then
		If GUICtrlRead($GUI_Comport) <> $ComPort And $UseGPS = 1 Then _GpsToggle() ;If the port has changed and gps is turned on then turn off the gps (it will be re-enabled with the new port)
		If GUICtrlRead($Rad_UseCommMG) = 1 Then $GpsType = 0 ;Set CommMG as default comm interface
		If GUICtrlRead($Rad_UseNetcomm) = 1 Then $GpsType = 1 ;Set Netcomm as default comm interface
		If GUICtrlRead($Rad_UseKernel32) = 1 Then $GpsType = 2 ;Set Kernel32 as default comm interface
		$ComPort = GUICtrlRead($GUI_Comport)
		$BAUD = GUICtrlRead($GUI_Baud)
		$STOPBIT = GUICtrlRead($GUI_StopBit)
		$DATABIT = GUICtrlRead($GUI_DataBit)
		If GUICtrlRead($GUI_Parity) = $Text_Even Then
			$PARITY = 'E'
		ElseIf GUICtrlRead($GUI_Parity) = $Text_Mark Then
			$PARITY = 'M'
		ElseIf GUICtrlRead($GUI_Parity) = $Text_Odd Then
			$PARITY = 'O'
		ElseIf GUICtrlRead($GUI_Parity) = $Text_Space Then
			$PARITY = 'S'
		Else ;GUICtrlRead($GUI_Parity) = 'None' Then
			$PARITY = 'N'
		EndIf
		If GUICtrlRead($GUI_Format) = "dd.dddd" Then $GPSformat = 1
		If GUICtrlRead($GUI_Format) = "dd mm ss" Then $GPSformat = 2
		If GUICtrlRead($GUI_Format) = "ddmm.mmmm" Then $GPSformat = 3
		GUICtrlSetData($GuiLat, $Text_Latitude & ': ' & _GpsFormat($Latitude));Set GPS Latitude in GUI
		GUICtrlSetData($GuiLon, $Text_Longitude & ': ' & _GpsFormat($Longitude));Set GPS Longitude in GUI
		If GUICtrlRead($GUI_GpsDisconnect) = 1 Then
			$GpsDisconnect = 1
		Else
			$GpsDisconnect = 0
		EndIf
		If GUICtrlRead($GUI_GpsReset) = 1 Then
			$GpsReset = 1
		Else
			$GpsReset = 0
		EndIf
	EndIf
	If $Apply_Language = 1 Then
		$DefaultLanguage = GUICtrlRead($LanguageBox)
		$DefaultLanguageFile = $DefaultLanguage & '.ini'
		$DefaultLanguagePath = $LanguageDir & $DefaultLanguageFile
		$Column_Names_Line = IniRead($DefaultLanguagePath, 'Column_Names', 'Column_Line', '#')
		$Column_Names_Active = IniRead($DefaultLanguagePath, 'Column_Names', 'Column_Active', 'Active')
		$Column_Names_SSID = IniRead($DefaultLanguagePath, 'Column_Names', 'Column_SSID', 'SSID')
		$Column_Names_BSSID = IniRead($DefaultLanguagePath, 'Column_Names', 'Column_BSSID', 'Mac Address')
		$Column_Names_MANUF = IniRead($DefaultLanguagePath, 'Column_Names', 'Column_Manufacturer', 'Manufacturer')
		$Column_Names_Signal = IniRead($DefaultLanguagePath, 'Column_Names', 'Column_Signal', 'Signal')
		$Column_Names_HighSignal = IniRead($DefaultLanguagePath, 'Column_Names', 'Column_HighSignal', 'High Signal')
		$Column_Names_RSSI = IniRead($DefaultLanguagePath, 'Column_Names', 'Column_RSSI', 'RSSI')
		$Column_Names_HighRSSI = IniRead($DefaultLanguagePath, 'Column_Names', 'Column_HighRSSI', 'High RSSI')
		$Column_Names_Authentication = IniRead($DefaultLanguagePath, 'Column_Names', 'Column_Authentication', 'Authentication')
		$Column_Names_Encryption = IniRead($DefaultLanguagePath, 'Column_Names', 'Column_Encryption', 'Encryption')
		$Column_Names_RadioType = IniRead($DefaultLanguagePath, 'Column_Names', 'Column_RadioType', 'Radio Type')
		$Column_Names_Channel = IniRead($DefaultLanguagePath, 'Column_Names', 'Column_Channel', 'Channel')
		$Column_Names_Latitude = IniRead($DefaultLanguagePath, 'Column_Names', 'Column_Latitude', 'Latitude')
		$Column_Names_Longitude = IniRead($DefaultLanguagePath, 'Column_Names', 'Column_Longitude', 'Longitude')
		$Column_Names_BasicTransferRates = IniRead($DefaultLanguagePath, 'Column_Names', 'Column_BasicTransferRates', 'Basic Transfer Rates')
		$Column_Names_OtherTransferRates = IniRead($DefaultLanguagePath, 'Column_Names', 'Column_OtherTransferRates', 'Other Transfer Rates')
		$Column_Names_FirstActive = IniRead($DefaultLanguagePath, 'Column_Names', 'Column_FirstActive', 'First Active')
		$Column_Names_LastActive = IniRead($DefaultLanguagePath, 'Column_Names', 'Column_LastActive', 'Last Active')
		$Column_Names_NetworkType = IniRead($DefaultLanguagePath, 'Column_Names', 'Column_NetworkType', 'Network Type')
		$Column_Names_Label = IniRead($DefaultLanguagePath, 'Column_Names', 'Column_Label', 'Label')

		$Text_Ok = IniRead($DefaultLanguagePath, 'GuiText', 'Ok', '&Ok')
		$Text_Cancel = IniRead($DefaultLanguagePath, 'GuiText', 'Cancel', 'C&ancel')
		$Text_Apply = IniRead($DefaultLanguagePath, 'GuiText', 'Apply', '&Apply')
		$Text_Browse = IniRead($DefaultLanguagePath, 'GuiText', 'Browse', '&Browse')
		$Text_File = IniRead($DefaultLanguagePath, 'GuiText', 'File', '&File')
		$Text_Import = IniRead($DefaultLanguagePath, 'GuiText', 'Import', '&Import')
		$Text_SaveAsTXT = IniRead($DefaultLanguagePath, 'GuiText', 'SaveAsTXT', 'Save As TXT')
		$Text_SaveAsVS1 = IniRead($DefaultLanguagePath, 'GuiText', 'SaveAsVS1', 'Save As VS1')
		$Text_SaveAsVSZ = IniRead($DefaultLanguagePath, 'GuiText', 'SaveAsVSZ', 'Save As VSZ')
		$Text_ImportFromTXT = IniRead($DefaultLanguagePath, 'GuiText', 'ImportFromTXT', 'Import From TXT / VS1')
		$Text_ImportFromVSZ = IniRead($DefaultLanguagePath, 'GuiText', 'ImportFromVSZ', 'Import From VSZ')
		$Text_Exit = IniRead($DefaultLanguagePath, 'GuiText', 'Exit', 'E&xit')
		$Text_ExitSaveDb = IniRead($DefaultLanguagePath, 'GuiText', 'ExitSaveDb', 'Exit (Save DB)')
		$Text_Edit = IniRead($DefaultLanguagePath, 'GuiText', 'Edit', 'E&dit')
		$Text_ClearAll = IniRead($DefaultLanguagePath, 'GuiText', 'ClearAll', 'Clear All')
		$Text_Cut = IniRead($DefaultLanguagePath, 'GuiText', 'Cut', 'Cut')
		$Text_Copy = IniRead($DefaultLanguagePath, 'GuiText', 'Copy', 'Copy')
		$Text_Paste = IniRead($DefaultLanguagePath, 'GuiText', 'Paste', 'Paste')
		$Text_Delete = IniRead($DefaultLanguagePath, 'GuiText', 'Delete', 'Delete')
		$Text_Select = IniRead($DefaultLanguagePath, 'GuiText', 'Select', 'Select')
		$Text_SelectAll = IniRead($DefaultLanguagePath, 'GuiText', 'SelectAll', 'Select All')
		$Text_View = IniRead($DefaultLanguagePath, 'GuiText', 'View', '&View')
		$Text_Options = IniRead($DefaultLanguagePath, 'GuiText', 'Options', '&Options')
		$Text_AutoSort = IniRead($DefaultLanguagePath, 'GuiText', 'AutoSort', 'AutoSort')
		$Text_SortTree = IniRead($DefaultLanguagePath, 'GuiText', 'SortTree', 'Sort Tree(slow)')
		$Text_PlaySound = IniRead($DefaultLanguagePath, 'GuiText', 'PlaySound', 'Play sound on new AP')
		$Text_PlayGpsSound = IniRead($DefaultLanguagePath, 'GuiText', 'PlayGpsSound', 'Play sound on new GPS')
		$Text_AddAPsToTop = IniRead($DefaultLanguagePath, 'GuiText', 'AddAPsToTop', 'Add new APs to top')
		$Text_Extra = IniRead($DefaultLanguagePath, 'GuiText', 'Extra', 'Ex&tra')
		$Text_ScanAPs = IniRead($DefaultLanguagePath, 'GuiText', 'ScanAPs', '&Scan APs')
		$Text_StopScanAps = IniRead($DefaultLanguagePath, 'GuiText', 'StopScanAps', '&Stop')
		$Text_UseGPS = IniRead($DefaultLanguagePath, 'GuiText', 'UseGPS', 'Use &GPS')
		$Text_StopGPS = IniRead($DefaultLanguagePath, 'GuiText', 'StopGPS', 'Stop &GPS')
		$Text_Settings = IniRead($DefaultLanguagePath, 'GuiText', 'Settings', 'Settings')
		$Text_MiscSettings = IniRead($DefaultLanguagePath, 'GuiText', 'MiscSettings', 'Misc Settings')
		$Text_SaveSettings = IniRead($DefaultLanguagePath, 'GuiText', 'SaveSettings', 'Save Settings')
		$Text_GpsSettings = IniRead($DefaultLanguagePath, 'GuiText', 'GpsSettings', 'GPS Settings')
		$Text_SetLanguage = IniRead($DefaultLanguagePath, 'GuiText', 'SetLanguage', 'Set Language')
		$Text_SetSearchWords = IniRead($DefaultLanguagePath, 'GuiText', 'SetSearchWords', 'Set Search Words')
		$Text_SetMacLabel = IniRead($DefaultLanguagePath, 'GuiText', 'SetMacLabel', 'Set Labels by Mac')
		$Text_SetMacManu = IniRead($DefaultLanguagePath, 'GuiText', 'SetMacManu', 'Set Manufactures by Mac')
		$Text_Export = IniRead($DefaultLanguagePath, 'GuiText', 'Export', 'Ex&port')
		$Text_ExportToKML = IniRead($DefaultLanguagePath, 'GuiText', 'ExportToKML', 'Export To KML')
		$Text_ExportToGPX = IniRead($DefaultLanguagePath, 'GuiText', 'ExportToGPX', 'Export To GPX')
		$Text_ExportToTXT = IniRead($DefaultLanguagePath, 'GuiText', 'ExportToTXT', 'Export To TXT')
		$Text_ExportToNS1 = IniRead($DefaultLanguagePath, 'GuiText', 'ExportToNS1', 'Export To NS1')
		$Text_ExportToVS1 = IniRead($DefaultLanguagePath, 'GuiText', 'ExportToVS1', 'Export To VS1')
		$Text_ExportToCSV = IniRead($DefaultLanguagePath, 'GuiText', 'ExportToCSV', 'Export To CSV')
		$Text_ExportToVSZ = IniRead($DefaultLanguagePath, "GuiText", "ExportToVSZ", "Export To VSZ")
		$Text_WifiDbPHPgraph = IniRead($DefaultLanguagePath, 'GuiText', 'WifiDbPHPgraph', 'Graph Selected AP Signal to Image')
		$Text_WifiDbWDB = IniRead($DefaultLanguagePath, 'GuiText', 'WifiDbWDB', 'WiFiDB URL')
		$Text_WifiDbWdbLocate = IniRead($DefaultLanguagePath, 'GuiText', 'WifiDbWdbLocate', 'WifiDB Locate URL')
		$Text_UploadDataToWifiDB = IniRead($DefaultLanguagePath, 'GuiText', 'UploadDataToWiFiDB', 'Upload Data to WiFiDB')
		$Text_RefreshLoopTime = IniRead($DefaultLanguagePath, 'GuiText', 'RefreshLoopTime', 'Refresh loop time(ms):')
		$Text_ActualLoopTime = IniRead($DefaultLanguagePath, 'GuiText', 'ActualLoopTime', 'Actual loop time:')
		$Text_Longitude = IniRead($DefaultLanguagePath, 'GuiText', 'Longitude', 'Longitude:')
		$Text_Latitude = IniRead($DefaultLanguagePath, 'GuiText', 'Latitude', 'Latitude:')
		$Text_ActiveAPs = IniRead($DefaultLanguagePath, 'GuiText', 'ActiveAPs', 'Active APs:')
		$Text_Graph = IniRead($DefaultLanguagePath, 'GuiText', 'Graph', 'Graph')
		$Text_Graph1 = IniRead($DefaultLanguagePath, 'GuiText', 'Graph1', 'Graph1')
		$Text_Graph2 = IniRead($DefaultLanguagePath, 'GuiText', 'Graph2', 'Graph2')
		$Text_NoGraph = IniRead($DefaultLanguagePath, 'GuiText', 'NoGraph', 'No Graph')
		$Text_Active = IniRead($DefaultLanguagePath, 'GuiText', 'Active', 'Active')
		$Text_Dead = IniRead($DefaultLanguagePath, 'GuiText', 'Dead', 'Dead')
		$Text_AddNewLabel = IniRead($DefaultLanguagePath, 'GuiText', 'AddNewLabel', 'Add New Label')
		$Text_RemoveLabel = IniRead($DefaultLanguagePath, 'GuiText', 'RemoveLabel', 'Remove Selected Label')
		$Text_EditLabel = IniRead($DefaultLanguagePath, 'GuiText', 'EditLabel', 'Edit Selected Label')
		$Text_AddNewMan = IniRead($DefaultLanguagePath, 'GuiText', 'AddNewMan', 'Add New Manufacturer')
		$Text_RemoveMan = IniRead($DefaultLanguagePath, 'GuiText', 'RemoveMan', 'Remove Selected Manufacturer')
		$Text_EditMan = IniRead($DefaultLanguagePath, 'GuiText', 'EditMan', 'Edit Selected Manufacturer')
		$Text_NewMac = IniRead($DefaultLanguagePath, 'GuiText', 'NewMac', 'New Mac Address:')
		$Text_NewMan = IniRead($DefaultLanguagePath, 'GuiText', 'NewMan', 'New Manufacturer:')
		$Text_NewLabel = IniRead($DefaultLanguagePath, 'GuiText', 'NewLabel', 'New label:')
		$Text_Save = IniRead($DefaultLanguagePath, 'GuiText', 'Save', 'Save?')
		$Text_SaveQuestion = IniRead($DefaultLanguagePath, 'GuiText', 'SaveQuestion', 'Data has changed. Would you like to save?')
		$Text_GpsDetails = IniRead($DefaultLanguagePath, 'GuiText', 'GpsDetails', 'GPS Details')
		$Text_GpsCompass = IniRead($DefaultLanguagePath, 'GuiText', 'GpsCompass', 'Gps Compass')
		$Text_Quality = IniRead($DefaultLanguagePath, 'GuiText', 'Quality', 'Quality')
		$Text_Time = IniRead($DefaultLanguagePath, 'GuiText', 'Time', 'Time')
		$Text_NumberOfSatalites = IniRead($DefaultLanguagePath, 'GuiText', 'NumberOfSatalites', 'Number of Satalites')
		$Text_HorizontalDilutionPosition = IniRead($DefaultLanguagePath, 'GuiText', 'HorizontalDilutionPosition', 'Horizontal Dilution')
		$Text_Altitude = IniRead($DefaultLanguagePath, 'GuiText', 'Altitude', 'Altitude')
		$Text_HeightOfGeoid = IniRead($DefaultLanguagePath, 'GuiText', 'HeightOfGeoid', 'Height of Geoid')
		$Text_Status = IniRead($DefaultLanguagePath, 'GuiText', 'Status', 'Status')
		$Text_Date = IniRead($DefaultLanguagePath, 'GuiText', 'Date', 'Date')
		$Text_SpeedInKnots = IniRead($DefaultLanguagePath, 'GuiText', 'SpeedInKnots', 'Speed(knots)')
		$Text_SpeedInMPH = IniRead($DefaultLanguagePath, 'GuiText', 'SpeedInMPH', 'Speed(MPH)')
		$Text_SpeedInKmh = IniRead($DefaultLanguagePath, 'GuiText', 'SpeedInKmh', 'Speed(km/h)')
		$Text_TrackAngle = IniRead($DefaultLanguagePath, 'GuiText', 'TrackAngle', 'Track Angle')
		$Text_Close = IniRead($DefaultLanguagePath, 'GuiText', 'Close', 'Track Close')
		$Text_RefreshNetworks = IniRead($DefaultLanguagePath, 'GuiText', 'RefreshingNetworks', 'Auto Refresh Networks')
		$Text_Start = IniRead($DefaultLanguagePath, 'GuiText', 'Start', 'Start')
		$Text_Stop = IniRead($DefaultLanguagePath, 'GuiText', 'Stop', 'Stop')
		$Text_RefreshTime = IniRead($DefaultLanguagePath, 'GuiText', 'RefreshTime', 'Refresh time')
		$Text_SetColumnWidths = IniRead($DefaultLanguagePath, 'GuiText', 'SetColumnWidths', 'Set Column Widths')
		$Text_Enable = IniRead($DefaultLanguagePath, 'GuiText', 'Enable', 'Enable')
		$Text_Disable = IniRead($DefaultLanguagePath, 'GuiText', 'Disable', 'Disable')
		$Text_Checked = IniRead($DefaultLanguagePath, 'GuiText', 'Checked', 'Checked')
		$Text_UnChecked = IniRead($DefaultLanguagePath, 'GuiText', 'UnChecked', 'UnChecked')
		$Text_Unknown = IniRead($DefaultLanguagePath, 'GuiText', 'Unknown', 'Unknown')
		$Text_Restart = IniRead($DefaultLanguagePath, 'GuiText', 'Restart', 'Restart')
		$Text_RestartMsg = IniRead($DefaultLanguagePath, 'GuiText', 'RestartMsg', 'Please restart Vistumbler for language change to take effect')
		$Text_Error = IniRead($DefaultLanguagePath, 'GuiText', 'Error', 'Error')
		$Text_NoSignalHistory = IniRead($DefaultLanguagePath, 'GuiText', 'NoSignalHistory', 'No signal history found, check to make sure your netsh search words are correct')
		$Text_NoApSelected = IniRead($DefaultLanguagePath, 'GuiText', 'NoApSelected', 'You did not select an access point')
		$Text_UseNetcomm = IniRead($DefaultLanguagePath, 'GuiText', 'UseNetcomm', 'Use Netcomm OCX (more stable) - x32')
		$Text_UseCommMG = IniRead($DefaultLanguagePath, 'GuiText', 'UseCommMG', 'Use CommMG (less stable) - x32 - x64')
		$Text_SignalHistory = IniRead($DefaultLanguagePath, 'GuiText', 'SignalHistory', 'Signal History')
		$Text_AutoSortEvery = IniRead($DefaultLanguagePath, 'GuiText', 'AutoSortEvery', 'Auto Sort Every')
		$Text_Seconds = IniRead($DefaultLanguagePath, 'GuiText', 'Seconds', 'Seconds')
		$Text_Ascending = IniRead($DefaultLanguagePath, 'GuiText', 'Ascending', 'Ascending')
		$Text_Decending = IniRead($DefaultLanguagePath, 'GuiText', 'Decending', 'Decending')
		$Text_AutoSave = IniRead($DefaultLanguagePath, 'GuiText', 'AutoSave', 'AutoSave')
		$Text_AutoSaveEvery = IniRead($DefaultLanguagePath, 'GuiText', 'AutoSaveEvery', 'AutoSave Every')
		$Text_DelAutoSaveOnExit = IniRead($DefaultLanguagePath, 'GuiText', 'DelAutoSaveOnExit', 'Delete Autosave file on exit')
		$Text_OpenSaveFolder = IniRead($DefaultLanguagePath, 'GuiText', 'OpenSaveFolder', 'Open Save Folder')
		$Text_SortBy = IniRead($DefaultLanguagePath, 'GuiText', 'SortBy', 'Sort By')
		$Text_SortDirection = IniRead($DefaultLanguagePath, 'GuiText', 'SortDirection', 'Sort Direction')
		$Text_Auto = IniRead($DefaultLanguagePath, 'GuiText', 'Auto', 'Auto')
		$Text_Misc = IniRead($DefaultLanguagePath, 'GuiText', 'Misc', 'Misc')
		$Text_Gps = IniRead($DefaultLanguagePath, 'GuiText', 'GPS', 'GPS')
		$Text_Labels = IniRead($DefaultLanguagePath, 'GuiText', 'Labels', 'Labels')
		$Text_Manufacturers = IniRead($DefaultLanguagePath, 'GuiText', 'Manufacturers', 'Manufacturers')
		$Text_Columns = IniRead($DefaultLanguagePath, 'GuiText', 'Columns', 'Columns')
		$Text_Language = IniRead($DefaultLanguagePath, 'GuiText', 'Language', 'Language')
		$Text_SearchWords = IniRead($DefaultLanguagePath, 'GuiText', 'SearchWords', 'SearchWords')
		$Text_VistumblerSettings = IniRead($DefaultLanguagePath, 'GuiText', 'VistumblerSettings', 'Vistumbler Settings')
		$Text_LanguageAuthor = IniRead($DefaultLanguagePath, 'GuiText', 'LanguageAuthor', 'Language Author')
		$Text_LanguageDate = IniRead($DefaultLanguagePath, 'GuiText', 'LanguageDate', 'Language Date')
		$Text_LanguageDescription = IniRead($DefaultLanguagePath, 'GuiText', 'LanguageDescription', 'Language Description')
		$Text_Description = IniRead($DefaultLanguagePath, 'GuiText', 'Description', 'Description')
		$Text_Progress = IniRead($DefaultLanguagePath, 'GuiText', 'Progress', 'Progress')
		$Text_LinesMin = IniRead($DefaultLanguagePath, 'GuiText', 'LinesMin', 'Lines/Min')
		$Text_NewAPs = IniRead($DefaultLanguagePath, 'GuiText', 'NewAPs', 'New APs')
		$Text_NewGIDs = IniRead($DefaultLanguagePath, 'GuiText', 'NewGIDs', 'New GIDs')
		$Text_Minutes = IniRead($DefaultLanguagePath, 'GuiText', 'Minutes', 'Minutes')
		$Text_LineTotal = IniRead($DefaultLanguagePath, 'GuiText', 'LineTotal', 'Line/Total')
		$Text_EstimatedTimeRemaining = IniRead($DefaultLanguagePath, 'GuiText', 'EstimatedTimeRemaining', 'Estimated Time Remaining')
		$Text_Ready = IniRead($DefaultLanguagePath, 'GuiText', 'Ready', 'Ready')
		$Text_Done = IniRead($DefaultLanguagePath, 'GuiText', 'Done', 'Done')
		$Text_VistumblerSaveDirectory = IniRead($DefaultLanguagePath, 'GuiText', 'VistumblerSaveDirectory', 'Vistumbler Save Directory')
		$Text_VistumblerAutoSaveDirectory = IniRead($DefaultLanguagePath, 'GuiText', 'VistumblerAutoSaveDirectory', 'Vistumbler Auto Save Directory')
		$Text_VistumblerKmlSaveDirectory = IniRead($DefaultLanguagePath, 'GuiText', 'VistumblerKmlSaveDirectory', 'Vistumbler KML Save Directory')
		$Text_BackgroundColor = IniRead($DefaultLanguagePath, 'GuiText', 'BackgroundColor', 'Background Color')
		$Text_ControlColor = IniRead($DefaultLanguagePath, 'GuiText', 'ControlColor', 'Control Color')
		$Text_BgFontColor = IniRead($DefaultLanguagePath, 'GuiText', 'BgFontColor', 'Font Color')
		$Text_ConFontColor = IniRead($DefaultLanguagePath, 'GuiText', 'ConFontColor', 'Control Font Color')
		$Text_NetshMsg = IniRead($DefaultLanguagePath, 'GuiText', 'NetshMsg', 'This section allows you to change the words Vistumbler uses to search netsh. Change to the proper words for you version of windows. Run "netsh wlan show networks mode = bssid" to find the proper words.')
		$Text_PHPgraphing = IniRead($DefaultLanguagePath, 'GuiText', 'PHPgraphing', 'PHP Graphing')
		$Text_ComInterface = IniRead($DefaultLanguagePath, 'GuiText', 'ComInterface', 'Com Interface')
		$Text_ComSettings = IniRead($DefaultLanguagePath, 'GuiText', 'ComSettings', 'Com Settings')
		$Text_Com = IniRead($DefaultLanguagePath, 'GuiText', 'Com', 'Com')
		$Text_Baud = IniRead($DefaultLanguagePath, 'GuiText', 'Baud', 'Baud')
		$Text_GPSFormat = IniRead($DefaultLanguagePath, 'GuiText', 'GPSFormat', 'GPS Format')
		$Text_HideOtherGpsColumns = IniRead($DefaultLanguagePath, 'GuiText', 'HideOtherGpsColumns', 'Hide Other GPS Columns')
		$Text_ImportLanguageFile = IniRead($DefaultLanguagePath, 'GuiText', 'ImportLanguageFile', 'Import Language File')
		$Text_AutoKml = IniRead($DefaultLanguagePath, 'GuiText', 'AutoKml', 'Auto KML')
		$Text_GoogleEarthEXE = IniRead($DefaultLanguagePath, 'GuiText', 'GoogleEarthEXE', 'Google Earth EXE')
		$Text_AutoSaveKmlEvery = IniRead($DefaultLanguagePath, 'GuiText', 'AutoSaveKmlEvery', 'Auto Save KML Every')
		$Text_SavedAs = IniRead($DefaultLanguagePath, 'GuiText', 'SavedAs', 'Saved As')
		$Text_Overwrite = IniRead($DefaultLanguagePath, 'GuiText', 'Overwrite', 'Overwrite')
		$Text_InstallNetcommOCX = IniRead($DefaultLanguagePath, 'GuiText', 'InstallNetcommOCX', 'Install Netcomm OCX')
		$Text_NoFileSaved = IniRead($DefaultLanguagePath, 'GuiText', 'NoFileSaved', 'No file has been saved')
		$Text_NoApsWithGps = IniRead($DefaultLanguagePath, 'GuiText', 'NoApsWithGps', 'No access points found with gps coordinates.')
		$Text_NoAps = IniRead($DefaultLanguagePath, 'GuiText', 'NoAps', 'No access points.')
		$Text_MacExistsOverwriteIt = IniRead($DefaultLanguagePath, 'GuiText', 'MacExistsOverwriteIt', 'A entry for this mac address already exists. would you like to overwrite it?')
		$Text_SavingLine = IniRead($DefaultLanguagePath, 'GuiText', 'SavingLine', 'Saving Line')
		$Text_Debug = IniRead($DefaultLanguagePath, 'GuiText', 'Debug', 'Debug')
		$Text_DisplayDebug = IniRead($DefaultLanguagePath, 'GuiText', 'DisplayDebug', 'Display Functions')
		$Text_DisplayComErrors = IniRead($DefaultLanguagePath, 'GuiText', 'DisplayDebugCom', 'Display COM Errors')
		$Text_GraphDeadTime = IniRead($DefaultLanguagePath, 'GuiText', 'GraphDeadTime', 'Graph Dead Time')
		$Text_OpenKmlNetLink = IniRead($DefaultLanguagePath, 'GuiText', 'OpenKmlNetLink', 'Open KML NetworkLink')
		$Text_ActiveRefreshTime = IniRead($DefaultLanguagePath, 'GuiText', 'ActiveRefreshTime', 'Active Refresh Time')
		$Text_DeadRefreshTime = IniRead($DefaultLanguagePath, 'GuiText', 'DeadRefreshTime', 'Dead Refresh Time')
		$Text_GpsRefrshTime = IniRead($DefaultLanguagePath, 'GuiText', 'GpsRefrshTime', 'Gps Refrsh Time')
		$Text_FlyToSettings = IniRead($DefaultLanguagePath, 'GuiText', 'FlyToSettings', 'Fly To Settings')
		$Text_FlyToCurrentGps = IniRead($DefaultLanguagePath, 'GuiText', 'FlyToCurrentGps', 'Fly to current gps position')
		$Text_AltitudeMode = IniRead($DefaultLanguagePath, 'GuiText', 'AltitudeMode', 'Altitude Mode')
		$Text_Range = IniRead($DefaultLanguagePath, 'GuiText', 'Range', 'Range')
		$Text_Heading = IniRead($DefaultLanguagePath, 'GuiText', 'Heading', 'Heading')
		$Text_Tilt = IniRead($DefaultLanguagePath, 'GuiText', 'Tilt', 'Tilt')
		$Text_AutoOpenNetworkLink = IniRead($DefaultLanguagePath, 'GuiText', 'AutoOpenNetworkLink', 'Automatically Open KML Network Link')
		$Text_SpeakSignal = IniRead($DefaultLanguagePath, 'GuiText', 'SpeakSignal', 'Speak Signal')
		$Text_SpeakUseVisSounds = IniRead($DefaultLanguagePath, 'GuiText', 'SpeakUseVisSounds', 'Use Vistumbler Sound Files')
		$Text_SpeakUseSapi = IniRead($DefaultLanguagePath, 'GuiText', 'SpeakUseSapi', 'Use Microsoft Sound API')
		$Text_SpeakSayPercent = IniRead($DefaultLanguagePath, 'GuiText', 'SpeakSayPercent', 'Say "Percent" after signal')
		$Text_GpsTrackTime = IniRead($DefaultLanguagePath, 'GuiText', 'GpsTrackTime', 'Track Refresh Time')
		$Text_SaveAllGpsData = IniRead($DefaultLanguagePath, 'GuiText', 'SaveAllGpsData', 'Save GPS data when no APs are active')
		$Text_None = IniRead($DefaultLanguagePath, 'GuiText', 'None', 'None')
		$Text_Even = IniRead($DefaultLanguagePath, 'GuiText', 'Even', 'Even')
		$Text_Odd = IniRead($DefaultLanguagePath, 'GuiText', 'Odd', 'Odd')
		$Text_Mark = IniRead($DefaultLanguagePath, 'GuiText', 'Mark', 'Mark')
		$Text_Space = IniRead($DefaultLanguagePath, 'GuiText', 'Space', 'Space')
		$Text_StopBit = IniRead($DefaultLanguagePath, 'GuiText', 'StopBit', 'Stop Bit')
		$Text_Parity = IniRead($DefaultLanguagePath, 'GuiText', 'Parity', 'Parity')
		$Text_DataBit = IniRead($DefaultLanguagePath, 'GuiText', 'DataBit', 'Data Bit')
		$Text_Update = IniRead($DefaultLanguagePath, 'GuiText', 'Update', 'Update')
		$Text_UpdateMsg = IniRead($DefaultLanguagePath, 'GuiText', 'UpdateMsg', 'Update Found. Would you like to update vistumbler?')
		$Text_Recover = IniRead($DefaultLanguagePath, 'GuiText', 'Recover', 'Recover')
		$Text_RecoverMsg = IniRead($DefaultLanguagePath, 'GuiText', 'RecoverMsg', 'Old DB Found. Would you like to recover it?')
		$Text_SelectConnectedAP = IniRead($DefaultLanguagePath, 'GuiText', 'SelectConnectedAP', 'Select Connected AP')
		$Text_VistumblerHome = IniRead($DefaultLanguagePath, 'GuiText', 'VistumblerHome', 'Vistumbler Home')
		$Text_VistumblerForum = IniRead($DefaultLanguagePath, 'GuiText', 'VistumblerForum', 'Vistumbler Forum')
		$Text_VistumblerWiki = IniRead($DefaultLanguagePath, 'GuiText', 'VistumblerWiki', 'Vistumbler Wiki')
		$Text_CheckForUpdates = IniRead($DefaultLanguagePath, 'GuiText', 'CheckForUpdates', 'Check For Updates')
		$Text_SelectWhatToCopy = IniRead($DefaultLanguagePath, 'GuiText', 'SelectWhatToCopy', 'Select what you want to copy')
		$Text_Default = IniRead($DefaultLanguagePath, 'GuiText', 'Default', 'Default')
		$Text_PlayMidiSounds = IniRead($DefaultLanguagePath, 'GuiText', 'PlayMidiSounds', 'Play MIDI sounds for all active APs')
		$Text_Interface = IniRead($DefaultLanguagePath, 'GuiText', 'Interface', 'Interface')
		$Text_LanguageCode = IniRead($DefaultLanguagePath, 'GuiText', 'LanguageCode', 'Language Code')
		$Text_AutoCheckUpdates = IniRead($DefaultLanguagePath, 'GuiText', 'AutoCheckUpdates', 'Automatically Check For Updates')
		$Text_CheckBetaUpdates = IniRead($DefaultLanguagePath, 'GuiText', 'CheckBetaUpdates', 'Check For Beta Updates')
		$Text_GuessSearchwords = IniRead($DefaultLanguagePath, 'GuiText', 'GuessSearchwords', 'Guess Netsh Searchwords')
		$Text_Help = IniRead($DefaultLanguagePath, 'GuiText', 'Help', 'Help')
		$Text_ErrorScanningNetsh = IniRead($DefaultLanguagePath, 'GuiText', 'ErrorScanningNetsh', 'Error scanning netsh')
		$Text_GpsErrorBufferEmpty = IniRead($DefaultLanguagePath, 'GuiText', 'GpsErrorBufferEmpty', 'GPS Error. Buffer Empty for more than 10 seconds. GPS was probrably disconnected. GPS has been stopped')
		$Text_GpsErrorStopped = IniRead($DefaultLanguagePath, 'GuiText', 'GpsErrorStopped', 'GPS Error. GPS has been stopped')
		$Text_ShowSignalDB = IniRead($DefaultLanguagePath, 'GuiText', 'ShowSignalDB', 'Show Signal dB (Estimated)')
		$Text_SortingList = IniRead($DefaultLanguagePath, 'GuiText', 'SortingList', 'Sorting List')
		$Text_Loading = IniRead($DefaultLanguagePath, 'GuiText', 'Loading', 'Loading')
		$Text_MapOpenNetworks = IniRead($DefaultLanguagePath, 'GuiText', 'MapOpenNetworks', 'Map Open Networks')
		$Text_MapWepNetworks = IniRead($DefaultLanguagePath, 'GuiText', 'MapWepNetworks', 'Map WEP Networks')
		$Text_MapSecureNetworks = IniRead($DefaultLanguagePath, 'GuiText', 'MapSecureNetworks', 'Map Secure Networks')
		$Text_DrawTrack = IniRead($DefaultLanguagePath, 'GuiText', 'DrawTrack', 'Draw Track')
		$Text_UseLocalImages = IniRead($DefaultLanguagePath, 'GuiText', 'UseLocalImages', 'Use Local Images')
		$Text_MIDI = IniRead($DefaultLanguagePath, 'GuiText', 'MIDI', 'MIDI')
		$Text_MidiInstrumentNumber = IniRead($DefaultLanguagePath, 'GuiText', 'MidiInstrumentNumber', 'MIDI Instrument #')
		$Text_MidiPlayTime = IniRead($DefaultLanguagePath, 'GuiText', 'MidiPlayTime', 'MIDI Play Time')
		$Text_SpeakRefreshTime = IniRead($DefaultLanguagePath, 'GuiText', 'SpeakRefreshTime', 'Speak Refresh Time')
		$Text_Information = IniRead($DefaultLanguagePath, 'GuiText', 'Information', 'Information')
		$Text_AddedGuessedSearchwords = IniRead($DefaultLanguagePath, 'GuiText', 'AddedGuessedSearchwords', 'Added guessed netsh searchwords. Searchwords for Open, None, WEP, Infrustructure, and Adhoc will still need to be done manually')
		$Text_SortingTreeview = IniRead($DefaultLanguagePath, 'GuiText', 'SortingTreeview', 'Sorting Treeview')
		$Text_Recovering = IniRead($DefaultLanguagePath, 'GuiText', 'Recovering', 'Recovering')
		$Text_ErrorOpeningGpsPort = IniRead($DefaultLanguagePath, 'GuiText', 'ErrorOpeningGpsPort', 'Error opening GPS port')
		$Text_SecondsSinceGpsUpdate = IniRead($DefaultLanguagePath, 'GuiText', 'SecondsSinceGpsUpdate', 'Seconds Since GPS Update')
		$Text_SavingGID = IniRead($DefaultLanguagePath, 'GuiText', 'SavingGID', 'Saving GID')
		$Text_SavingHistID = IniRead($DefaultLanguagePath, 'GuiText', 'SavingHistID', 'Saving HistID')
		$Text_NoUpdates = IniRead($DefaultLanguagePath, 'GuiText', 'NoUpdates', 'No Updates Avalible')
		$Text_NoActiveApFound = IniRead($DefaultLanguagePath, 'GuiText', 'NoActiveApFound', 'No Active AP found')
		$Text_VistumblerDonate = IniRead($DefaultLanguagePath, 'GuiText', 'VistumblerDonate', 'Donate')
		$Text_VistumblerStore = IniRead($DefaultLanguagePath, 'GuiText', 'VistumblerStore', 'Store')
		$Text_SupportVistumbler = IniRead($DefaultLanguagePath, 'GuiText', 'SupportVistumbler', '*Support Vistumbler*')
		$Text_UseNativeWifiMsg = IniRead($DefaultLanguagePath, 'GuiText', 'UseNativeWifiMsg', 'Use Native Wifi')
		$Text_UseNativeWifiXpExtMsg = IniRead($DefaultLanguagePath, 'GuiText', 'UseNativeWifiXpExtMsg', '(No BSSID, CHAN, OTX, BTX)')
		$Text_FilterMsg = IniRead($DefaultLanguagePath, 'GuiText', 'FilterMsg', 'Use asterik(*)" as a wildcard. Seperate multiple filters with a comma(,). Use a dash(-) for ranges.')
		$Text_SetFilters = IniRead($DefaultLanguagePath, 'GuiText', 'SetFilters', 'Set Filters')
		$Text_Filtered = IniRead($DefaultLanguagePath, 'GuiText', 'Filtered', 'Filtered')
		$Text_Filters = IniRead($DefaultLanguagePath, 'GuiText', 'Filters', 'Filters')
		$Text_FilterName = IniRead($DefaultLanguagePath, 'GuiText', 'FilterName', 'Filter Name')
		$Text_FilterDesc = IniRead($DefaultLanguagePath, 'GuiText', 'FilterDesc', 'Filter Description')
		$Text_FilterAddEdit = IniRead($DefaultLanguagePath, 'GuiText', 'FilterAddEdit', 'Add/Edit Filter')
		$Text_NoAdaptersFound = IniRead($DefaultLanguagePath, 'GuiText', 'NoAdaptersFound', 'No Adapters Found')
		$Text_RecoveringMDB = IniRead($DefaultLanguagePath, 'GuiText', 'RecoveringMDB', 'Recovering MDB')
		$Text_FixingGpsTableDates = IniRead($DefaultLanguagePath, 'GuiText', 'FixingGpsTableDates', 'Fixing GPS table date(s)')
		$Text_FixingGpsTableTimes = IniRead($DefaultLanguagePath, 'GuiText', 'FixingGpsTableTimes', 'Fixing GPS table time(s)')
		$Text_FixingHistTableDates = IniRead($DefaultLanguagePath, 'GuiText', 'FixingHistTableDates', 'Fixing HIST table date(s)')
		$Text_VistumblerNeedsToRestart = IniRead($DefaultLanguagePath, 'GuiText', 'VistumblerNeedsToRestart', 'Vistumbler needs to be restarted. Vistumbler will now close')
		$Text_AddingApsIntoList = IniRead($DefaultLanguagePath, 'GuiText', 'AddingApsIntoList', 'Adding new APs into list')
		$Text_GoogleEarthDoesNotExist = IniRead($DefaultLanguagePath, 'GuiText', 'GoogleEarthDoesNotExist', 'Google earth file does not exist or is set wrong in the AutoKML settings')
		$Text_AutoKmlIsNotStarted = IniRead($DefaultLanguagePath, 'GuiText', 'AutoKmlIsNotStarted', 'AutoKML is not yet started. Would you like to turn it on now?')
		$Text_UseKernel32 = IniRead($DefaultLanguagePath, 'GuiText', 'UseKernel32', 'Use Kernel32 - x32 - x64')
		$Text_UnableToGuessSearchwords = IniRead($DefaultLanguagePath, 'GuiText', 'UnableToGuessSearchwords', 'Vistumbler was unable to guess searchwords')
		$Text_SelectedAP = IniRead($DefaultLanguagePath, 'GuiText', 'SelectedAP', 'Selected AP')
		$Text_AllAPs = IniRead($DefaultLanguagePath, 'GuiText', 'AllAPs', 'All APs')
		$Text_FilteredAPs = IniRead($DefaultLanguagePath, 'GuiText', 'FilteredAPs', 'Filtered APs')
		$Text_ImportFolder = IniRead($DefaultLanguagePath, 'GuiText', 'ImportFolder', 'Import Folder')
		$Text_DeleteSelected = IniRead($DefaultLanguagePath, 'GuiText', 'DeleteSelected', 'Delete Selected')
		$Text_RecoverSelected = IniRead($DefaultLanguagePath, 'GuiText', 'RecoverSelected', 'Recover Selected')
		$Text_NewSession = IniRead($DefaultLanguagePath, 'GuiText', 'NewSession', 'New Session')
		$Text_Size = IniRead($DefaultLanguagePath, 'GuiText', 'Size', 'Size')
		$Text_NoMdbSelected = IniRead($DefaultLanguagePath, 'GuiText', 'NoMdbSelected', 'No MDB Selected')
		$Text_LocateInWiFiDB = IniRead($DefaultLanguagePath, 'GuiText', 'LocateInWiFiDB', 'Locate Position in WiFiDB')
		$Text_AutoWiFiDbGpsLocate = IniRead($DefaultLanguagePath, 'GuiText', 'AutoWiFiDbGpsLocate', 'Auto WiFiDB Gps Locate')
		$Text_AutoWiFiDbUploadAps = IniRead($DefaultLanguagePath, 'GuiText', 'AutoWiFiDbUploadAps', 'Auto WiFiDB Upload Active AP')
		$Text_AutoSelectConnectedAP = IniRead($DefaultLanguagePath, 'GuiText', 'AutoSelectConnectedAP', 'Auto Select Connected AP')
		$Text_AutoSelectHighSignal = IniRead($DefaultLanguagePath, "GuiText", 'AutoSelectHighSigAP', 'Auto Select Highest Signal AP')
		$Text_Experimental = IniRead($DefaultLanguagePath, 'GuiText', 'Experimental', 'Experimental')
		$Text_Color = IniRead($DefaultLanguagePath, 'GuiText', 'Color', 'Color')
		$Text_AddRemFilters = IniRead($DefaultLanguagePath, "GuiText", "AddRemFilters", "Add/Remove Filters")
		$Text_NoFilterSelected = IniRead($DefaultLanguagePath, "GuiText", "NoFilterSelected", "No filter selected.")
		$Text_AddFilter = IniRead($DefaultLanguagePath, "GuiText", "AddFilter", "Add Filter")
		$Text_EditFilter = IniRead($DefaultLanguagePath, "GuiText", "EditFilter ", "Edit Filter ")
		$Text_DeleteFilter = IniRead($DefaultLanguagePath, "GuiText", "DeleteFilter", "Delete Filter")
		$Text_TimeBeforeMarkedDead = IniRead($DefaultLanguagePath, "GuiText", "TimeBeforeMarkedDead", "Time to wait before marking AP dead (s)")
		$Text_FilterNameRequired = IniRead($DefaultLanguagePath, "GuiText", "FilterNameRequired", "Filter Name is required")
		$Text_UpdateManufacturers = IniRead($DefaultLanguagePath, "GuiText", "UpdateManufacturers", "Update Manufacturers")
		$Text_FixHistSignals = IniRead($DefaultLanguagePath, "GuiText", "FixHistSignals", "Fixing Missing Hist Table Signal(s)")
		$Text_VistumblerFile = IniRead($DefaultLanguagePath, 'GuiText', 'VistumblerFile', 'Vistumbler file')
		$Text_DetailedCsvFile = IniRead($DefaultLanguagePath, 'GuiText', 'DetailedFile', 'Detailed Comma Delimited file')
		$Text_SummaryCsvFile = IniRead($DefaultLanguagePath, 'GuiText', 'SummaryFile', 'Summary Comma Delimited file')
		$Text_NetstumblerTxtFile = IniRead($DefaultLanguagePath, 'GuiText', 'NetstumblerTxtFile', 'Netstumbler wi-scan file')
		$Text_WardriveDb3File = IniRead($DefaultLanguagePath, 'GuiText', 'WardriveDb3File', 'Wardrive-android file')
		$Text_AutoScanApsOnLaunch = IniRead($DefaultLanguagePath, "GuiText", "AutoScanApsOnLaunch", "Auto Scan APs on launch")
		$Text_RefreshInterfaces = IniRead($DefaultLanguagePath, "GuiText", "RefreshInterfaces", "Refresh Interfaces")
		$Text_Sound = IniRead($DefaultLanguagePath, 'GuiText', 'Sound', 'Sound')
		$Text_OncePerLoop = IniRead($DefaultLanguagePath, 'GuiText', 'OncePerLoop', 'Once per loop')
		$Text_OncePerAP = IniRead($DefaultLanguagePath, 'GuiText', 'OncePerAP', 'Once per ap')
		$Text_OncePerAPwSound = IniRead($DefaultLanguagePath, 'GuiText', 'OncePerAPwSound', 'Once per ap with volume based on signal')
		$Text_WifiDB = IniRead($DefaultLanguagePath, 'GuiText', 'WifiDB', 'WifiDB')
		$Text_Warning = IniRead($DefaultLanguagePath, 'GuiText', 'Warning', 'Warning')
		$Text_WifiDBLocateWarning = IniRead($DefaultLanguagePath, 'GuiText', 'WifiDBLocateWarning', 'This feature sends active access point information to the WifiDB API URL specified in the Vistumbler WifiDB Settings. If you do not want to send data to the wifidb, do not enable this feature. Do you want to continue to enable this feature?')
		$Text_WifiDBAutoUploadWarning = IniRead($DefaultLanguagePath, 'GuiText', 'WifiDBAutoUploadWarning', 'This feature sends active access point information to the WifiDB URL specified in the Vistumbler WifiDB Settings. If you do not want to send data to the wifidb, do not enable this feature. Do you want to continue to enable this feature?')
		$Text_WifiDBOpenLiveAPWebpage = IniRead($DefaultLanguagePath, 'GuiText', 'WifiDBOpenLiveAPWebpage', 'Open WifiDB Live AP Webpage')
		$Text_WifiDBOpenMainWebpage = IniRead($DefaultLanguagePath, 'GuiText', 'WifiDBOpenMainWebpage', 'Open WifiDB Main Webpage')
		$Text_FilePath = IniRead($DefaultLanguagePath, 'GuiText', 'FilePath', 'File Path')
		$Text_CameraName = IniRead($DefaultLanguagePath, 'GuiText', 'CameraName', 'Camera Name')
		$Text_CameraURL = IniRead($DefaultLanguagePath, 'GuiText', 'CameraURL', 'Camera URL')
		$Text_Cameras = IniRead($DefaultLanguagePath, 'GuiText', 'Cameras', 'Cameras')
		$Text_AddCamera = IniRead($DefaultLanguagePath, 'GuiText', 'AddCamera', 'Add Camera')
		$Text_RemoveCamera = IniRead($DefaultLanguagePath, 'GuiText', 'RemoveCamera', 'Remove Camera')
		$Text_EditCamera = IniRead($DefaultLanguagePath, 'GuiText', 'EditCamera', 'Edit Camera')
		$Text_DownloadImages = IniRead($DefaultLanguagePath, 'GuiText', 'DownloadImages', 'Download Images')
		$Text_EnableCamTriggerScript = IniRead($DefaultLanguagePath, 'GuiText', 'EnableCamTriggerScript', 'Enable camera trigger script')
		$Text_CameraTriggerScript = IniRead($DefaultLanguagePath, 'GuiText', 'CameraTriggerScript', 'Camera Trigger Script')
		$Text_CameraTriggerScriptTypes = IniRead($DefaultLanguagePath, 'GuiText', 'CameraTriggerScriptTypes', 'Camera Trigger Script (exe,bat)')
		$Text_SetCameras = IniRead($DefaultLanguagePath, 'GuiText', 'SetCameras', 'Set Cameras')
		$Text_UpdateUpdaterMsg = IniRead($DefaultLanguagePath, 'GuiText', 'UpdateUpdaterMsg', 'There is an update to the vistumbler updater. Would you like to download and update it now?')
		$Text_UseRssiInGraphs = IniRead($DefaultLanguagePath, 'GuiText', 'UseRssiInGraphs', 'Use RSSI in graphs')
		$Text_2400ChannelGraph = IniRead($DefaultLanguagePath, 'GuiText', '2400ChannelGraph', '2.4Ghz Channel Graph')
		$Text_5000ChannelGraph = IniRead($DefaultLanguagePath, 'GuiText', '5000ChannelGraph', '5Ghz Channel Graph')
		$Text_UpdateGeolocations = IniRead($DefaultLanguagePath, 'GuiText', 'UpdateGeolocations', 'Update Geolocations')
		$Text_ShowGpsPositionMap = IniRead($DefaultLanguagePath, 'GuiText', 'ShowGpsPositionMap', 'Show GPS Position Map')
		$Text_ShowGpsSignalMap = IniRead($DefaultLanguagePath, 'GuiText', 'ShowGpsSignalMap', 'Show GPS Signal Map')
		$Text_UseRssiSignalValue = IniRead($DefaultLanguagePath, 'GuiText', 'UseRssiSignalValue', 'Use RSSI signal values')
		$Text_UseCircleToShowSigStength = IniRead($DefaultLanguagePath, 'GuiText', 'UseCircleToShowSigStength', 'Use circle to show signal strength')
		$Text_ShowGpsRangeMap = IniRead($DefaultLanguagePath, 'GuiText', 'ShowGpsRangeMap', 'Show GPS Range Map')
		$Text_ShowGpsTack = IniRead($DefaultLanguagePath, 'GuiText', 'ShowGpsTack', 'Show GPS Track')
		$Text_Line = IniRead($DefaultLanguagePath, 'GuiText', 'Line', 'Line')
		$Text_Total = IniRead($DefaultLanguagePath, 'GuiText', 'Total', 'Total')
		$Text_WifiDB_Upload_Discliamer = IniRead($DefaultLanguagePath, 'GuiText', 'WifiDB_Upload_Discliamer', 'This feature uploads access points to the WifiDB. a file will be generated and uploaded to the WifiDB API URL specified in the Vistumbler WifiDB Settings.')
		$Text_UserInformation = IniRead($DefaultLanguagePath, 'GuiText', 'UserInformation', 'User Information')
		$Text_WifiDB_Username = IniRead($DefaultLanguagePath, 'GuiText', 'WifiDB_Username', 'WifiDB Username')
		$Text_WifiDB_Api_Key = IniRead($DefaultLanguagePath, 'GuiText', 'WifiDB_Api_Key', 'WifiDB Api Key')
		$Text_OtherUsers = IniRead($DefaultLanguagePath, 'GuiText', 'OtherUsers', 'Other users')
		$Text_FileType = IniRead($DefaultLanguagePath, 'GuiText', 'FileType', 'File Type')
		$Text_VistumblerVSZ = IniRead($DefaultLanguagePath, 'GuiText', 'VistumblerVSZ', 'Vistumbler VSZ')
		$Text_VistumblerVS1 = IniRead($DefaultLanguagePath, 'GuiText', 'VistumblerVS1', 'Vistumbler VS1')
		$Text_VistumblerCSV = IniRead($DefaultLanguagePath, 'GuiText', 'VistumblerCSV', 'Vistumbler Detailed CSV')
		$Text_UploadInformation = IniRead($DefaultLanguagePath, 'GuiText', 'UploadInformation', 'Upload Information')
		$Text_Title = IniRead($DefaultLanguagePath, 'GuiText', 'Title', 'Title')
		$Text_Notes = IniRead($DefaultLanguagePath, 'GuiText', 'Notes', 'Notes')
		$Text_UploadApsToWifidb = IniRead($DefaultLanguagePath, 'GuiText', 'UploadApsToWifidb', 'Upload APs to WifiDB')
		$Text_UploadingApsToWifidb = IniRead($DefaultLanguagePath, 'GuiText', 'UploadingApsToWifidb', 'Uploading APs to WifiDB')
		$Text_GeoNamesInfo = IniRead($DefaultLanguagePath, 'GuiText', 'GeoNamesInfo', 'Geonames Info')
		$Text_FindApInWifidb = IniRead($DefaultLanguagePath, 'GuiText', 'FindApInWifidb', 'Find AP in WifiDB')
		$Text_GpsDisconnect = IniRead($DefaultLanguagePath, 'GuiText', 'GpsDisconnect', 'Disconnect GPS when no data is recieved in over 10 seconds')
		$Text_GpsReset = IniRead($DefaultLanguagePath, 'GuiText', 'GpsReset', 'Reset GPS position when no GPGGA data is recived in over 30 seconds')
		$Text_APs = IniRead($DefaultLanguagePath, 'GuiText', 'APs', 'APs')
		$Text_MaxSignal = IniRead($DefaultLanguagePath, 'GuiText', 'MaxSignal', 'Max Signal')
		$Text_DisassociationSignal = IniRead($DefaultLanguagePath, 'GuiText', 'DisassociationSignal', 'Disassociation Signal')
		$Text_SaveDirectories = IniRead($DefaultLanguagePath, 'GuiText', 'SaveDirectories', 'Save Directories')
		$Text_AutoSaveAndClearAfterNumberofAPs = IniRead($DefaultLanguagePath, 'GuiText', 'AutoSaveAndClearAfterNumberofAPs', 'Auto Save And Clear After Number of APs')
		$Text_AutoSaveandClearAfterTime = IniRead($DefaultLanguagePath, 'GuiText', 'AutoSaveandClearAfterTime', 'Auto Save and Clear After Time')
		$Text_PlaySoundWhenSaving = IniRead($DefaultLanguagePath, 'GuiText', 'PlaySoundWhenSaving', 'Play Sound When Saving')
		$Text_MinimalGuiMode = IniRead($DefaultLanguagePath, 'GuiText', 'MinimalGuiMode', 'Minimal GUI Mode')
		$Text_AutoScrollToBottom = IniRead($DefaultLanguagePath, 'GuiText', 'AutoScrollToBottom', 'Auto Scroll to Bottom of List')
		$Text_ListviewBatchInsertMode = IniRead($DefaultLanguagePath, 'GuiText', 'ListviewBatchInsertMode', 'Listview Batch Insert Mode')

		$RestartVistumbler = 1
	EndIf
	If $Apply_Manu = 1 Then
		;Remove all current Mac address/manus in the array
		$query = "DELETE * FROM Manufacturers"
		_ExecuteMDB($ManuDB, $ManuDB_OBJ, $query)
		;Rewrite Mac address/labels from listview into the array
		$itemcount = _GUICtrlListView_GetItemCount($GUI_Manu_List) - 1; Get List Size
		For $findloop = 0 To $itemcount
			$o_manu_mac = StringUpper(StringReplace(_GUICtrlListView_GetItemText($GUI_Manu_List, $findloop, 0), '"', ''))
			$o_manu = _GUICtrlListView_GetItemText($GUI_Manu_List, $findloop, 1)
			_AddRecord($ManuDB, "Manufacturers", $ManuDB_OBJ, $o_manu_mac & '|' & $o_manu)
		Next
		;Reset Labels In List
		_UpdateListMacLabels()
	EndIf
	If $Apply_Lab = 1 Then
		;Remove all current Mac address/labels in the array
		$query = "DELETE * FROM Labels"
		_ExecuteMDB($LabDB, $LabDB_OBJ, $query)
		;Rewrite Mac address/labels from listview into the array
		$itemcount = _GUICtrlListView_GetItemCount($GUI_Lab_List) - 1; Get List Size
		For $findloop = 0 To $itemcount
			$o_lab_mac = StringUpper(StringReplace(_GUICtrlListView_GetItemText($GUI_Lab_List, $findloop, 0), '"', ''))
			$o_lab = _GUICtrlListView_GetItemText($GUI_Lab_List, $findloop, 1)
			_AddRecord($LabDB, "Labels", $LabDB_OBJ, $o_lab_mac & '|' & $o_lab)
		Next
		;Reset Labels In List
		_UpdateListMacLabels()
	EndIf
	If $Apply_Column = 1 Then
		$column_Width_Line = GUICtrlRead($CWIB_Line)
		$column_Width_Active = GUICtrlRead($CWIB_Active)
		$column_Width_SSID = GUICtrlRead($CWIB_SSID)
		$column_Width_BSSID = GUICtrlRead($CWIB_BSSID)
		$column_Width_MANUF = GUICtrlRead($CWIB_Manu)
		$column_Width_Signal = GUICtrlRead($CWIB_Signal)
		$column_Width_HighSignal = GUICtrlRead($CWIB_HighSignal)
		$column_Width_RSSI = GUICtrlRead($CWIB_RSSI)
		$column_Width_HighRSSI = GUICtrlRead($CWIB_HighRSSI)
		$column_Width_Authentication = GUICtrlRead($CWIB_Authentication)
		$column_Width_Encryption = GUICtrlRead($CWIB_Encryption)
		$column_Width_RadioType = GUICtrlRead($CWIB_RadioType)
		$column_Width_Channel = GUICtrlRead($CWIB_Channel)
		$column_Width_Latitude = GUICtrlRead($CWIB_Latitude)
		$column_Width_Longitude = GUICtrlRead($CWIB_Longitude)
		$column_Width_LatitudeDMS = GUICtrlRead($CWIB_LatitudeDMS)
		$column_Width_LongitudeDMS = GUICtrlRead($CWIB_LongitudeDMS)
		$column_Width_LatitudeDMM = GUICtrlRead($CWIB_LatitudeDMM)
		$column_Width_LongitudeDMM = GUICtrlRead($CWIB_LongitudeDMM)
		$column_Width_BasicTransferRates = GUICtrlRead($CWIB_BtX)
		$column_Width_OtherTransferRates = GUICtrlRead($CWIB_OtX)
		$column_Width_FirstActive = GUICtrlRead($CWIB_FirstActive)
		$column_Width_LastActive = GUICtrlRead($CWIB_LastActive)
		$column_Width_NetworkType = GUICtrlRead($CWIB_NetType)
		$column_Width_Label = GUICtrlRead($CWIB_Label)
		_SetListviewWidths()
	EndIf
	If $Apply_Searchword = 1 Then
		$SearchWord_SSID = GUICtrlRead($SearchWord_SSID_GUI)
		$SearchWord_BSSID = GUICtrlRead($SearchWord_BSSID_GUI)
		$SearchWord_NetworkType = GUICtrlRead($SearchWord_NetType_GUI)
		$SearchWord_Authentication = GUICtrlRead($SearchWord_Authentication_GUI)
		$SearchWord_Signal = GUICtrlRead($SearchWord_Signal_GUI)
		;$SearchWord_RSSI = GUICtrlRead($SearchWord_RSSI_GUI)
		$SearchWord_RadioType = GUICtrlRead($SearchWord_RadioType_GUI)
		$SearchWord_Channel = GUICtrlRead($SearchWord_Channel_GUI)
		$SearchWord_BasicRates = GUICtrlRead($SearchWord_BasicRates_GUI)
		$SearchWord_OtherRates = GUICtrlRead($SearchWord_OtherRates_GUI)
		$SearchWord_Encryption = GUICtrlRead($SearchWord_Encryption_GUI)
		$SearchWord_Open = GUICtrlRead($SearchWord_Open_GUI)
		$SearchWord_None = GUICtrlRead($SearchWord_None_GUI)
		$SearchWord_Wep = GUICtrlRead($SearchWord_Wep_GUI)
		$SearchWord_Infrastructure = GUICtrlRead($SearchWord_Infrastructure_GUI)
		$SearchWord_Adhoc = GUICtrlRead($SearchWord_Adhoc_GUI)
	EndIf
	If $Apply_Auto = 1 Then
		;Auto KML
		If GUICtrlRead($AutoSaveKML) = 4 And $AutoKML = 1 Then _AutoKmlToggle()
		If GUICtrlRead($AutoSaveKML) = 1 And $AutoKML = 0 Then _AutoKmlToggle()

		$GoogleEarthExe = GUICtrlRead($GUI_GoogleEXE)
		$AutoKmlActiveTime = GUICtrlRead($GUI_AutoKmlActiveTime)
		$AutoKmlDeadTime = GUICtrlRead($GUI_AutoKmlDeadTime)
		$AutoKmlGpsTime = GUICtrlRead($GUI_AutoKmlGpsTime)
		$AutoKmlTrackTime = GUICtrlRead($GUI_AutoKmlTrackTime)

		If GUICtrlRead($GUI_KmlFlyTo) = 1 Then
			$KmlFlyTo = 1
		Else
			$KmlFlyTo = 0
		EndIf
		$AutoKML_Alt = GUICtrlRead($GUI_AutoKml_Alt)
		$AutoKML_AltMode = GUICtrlRead($GUI_AutoKml_AltMode)
		$AutoKML_Heading = GUICtrlRead($GUI_AutoKml_Heading)
		$AutoKML_Range = GUICtrlRead($GUI_AutoKml_Range)
		$AutoKML_Tilt = GUICtrlRead($GUI_AutoKml_Tilt)

		If GUICtrlRead($GUI_OpenKmlNetLink) = 1 Then
			$OpenKmlNetLink = 1
			If $AutoKML = 1 Then _StartGoogleAutoKmlRefresh()
		Else
			$OpenKmlNetLink = 0
		EndIf

		;AutoSort
		If GUICtrlRead($GUI_SortDirection) = $Text_Ascending Then
			$SortDirection = 0
		Else
			$SortDirection = 1
		EndIf

		$SortBy = GUICtrlRead($GUI_SortBy)
		$SortTime = GUICtrlRead($GUI_SortTime)
		If GUICtrlRead($GUI_AutoSort) = 4 And $AutoSort = 1 Then _AutoSortToggle()
		If GUICtrlRead($GUI_AutoSort) = 1 And $AutoSort = 0 Then _AutoSortToggle()
	EndIf
	If $Apply_Sound = 1 Then
		;New AP Sound Settings
		If GUICtrlRead($GUI_NewApSound) = 4 And $SoundOnAP = 1 Then _SoundToggle();Turn off new ap sound
		If GUICtrlRead($GUI_NewApSound) = 1 And $SoundOnAP = 0 Then _SoundToggle();Turn on new ap sound
		If GUICtrlRead($GUI_ASperloop) = 1 Then
			$SoundPerAP = 0
		ElseIf GUICtrlRead($GUI_ASperap) = 1 Then
			$SoundPerAP = 1
			$NewSoundSigBased = 0
		ElseIf GUICtrlRead($GUI_ASperapwsound) = 1 Then
			$SoundPerAP = 1
			$NewSoundSigBased = 1
		EndIf
		;Save Speak Settings
		If GUICtrlRead($GUI_SpeakSignal) = 4 And $SpeakSignal = 1 Then _SpeakSigToggle();Turn off speak signal
		If GUICtrlRead($GUI_SpeakSignal) = 1 And $SpeakSignal = 0 Then _SpeakSigToggle();Turn on speak signal
		If GUICtrlRead($GUI_SpeakSoundsVis) = 1 Then
			$SpeakType = 1 ;Set Vistumbler Sounds as default speak signal interface
		ElseIf GUICtrlRead($GUI_SpeakSoundsSapi) = 1 Then
			$SpeakType = 2 ;Set SAPI as default speak signal interface
		ElseIf GUICtrlRead($GUI_SpeakSoundsMidi) = 1 Then
			$SpeakType = 3 ;Set MIDI as default speak signal interface
		EndIf
		If GUICtrlRead($GUI_SpeakPercent) = 1 Then
			$SpeakSigSayPecent = 1;Say Percent
		Else
			$SpeakSigSayPecent = 0;Don't say percent
		EndIf
		$SpeakSigTime = GUICtrlRead($GUI_SpeakSigTime)
		If GUICtrlRead($GUI_PlayMidiSounds) = 4 And $Midi_PlayForActiveAps = 1 Then _ActiveApMidiToggle();Turn off MIDI signal
		If GUICtrlRead($GUI_PlayMidiSounds) = 1 And $Midi_PlayForActiveAps = 0 Then _ActiveApMidiToggle();Turn on MIDI signal
		$MidiInstSplit = StringSplit(GUICtrlRead($GUI_Midi_Instument), ' - ', 1)
		$Midi_Instument = $MidiInstSplit[1]
		$Midi_PlayTime = GUICtrlRead($GUI_Midi_PlayTime)
	EndIf
	If $Apply_WifiDB = 1 Then
		$WifiDb_User = GUICtrlRead($GUI_WifiDB_User)
		$WifiDb_ApiKey = GUICtrlRead($GUI_WifiDB_ApiKey)
		$WifiDbGraphURL = GUICtrlRead($GUI_WifiDbGraphURL)
		$WifiDbWdbURL = GUICtrlRead($GUI_WifiDbWdbURL)
		$WifiDbApiURL = GUICtrlRead($GUI_WifiDbApiURL)
		;Auto WiFiDB Locate
		If GUICtrlRead($GUI_WifidbLocate) = 4 And $UseWiFiDbGpsLocate = 1 Then _WifiDbLocateToggle()
		If GUICtrlRead($GUI_WifidbLocate) = 1 And $UseWiFiDbGpsLocate = 0 Then _WifiDbLocateToggle()
		$WiFiDbLocateRefreshTime = (GUICtrlRead($GUI_WiFiDbLocateRefreshTime) * 1000)
		;Auto WiFiDB Update
		If GUICtrlRead($GUI_WifidbUploadAps) = 4 And $AutoUpApsToWifiDB = 1 Then _WifiDbAutoUploadToggle()
		If GUICtrlRead($GUI_WifidbUploadAps) = 1 And $AutoUpApsToWifiDB = 0 Then _WifiDbAutoUploadToggle()
		$AutoUpApsToWifiDBTime = GUICtrlRead($GUI_AutoUpApsToWifiDBTime)
	EndIf
	If $Apply_Cam = 1 Then
		;Remove all current cameras in the array
		$query = "DELETE * FROM Cameras"
		_ExecuteMDB($CamDB, $CamDB_OBJ, $query)
		;Rewrite cameras from listview into the array
		$itemcount = _GUICtrlListView_GetItemCount($GUI_Cam_List) - 1; Get List Size
		For $findloop = 0 To $itemcount
			$o_camname = StringReplace(_GUICtrlListView_GetItemText($GUI_Cam_List, $findloop, 0), '"', '')
			$o_camurl = _GUICtrlListView_GetItemText($GUI_Cam_List, $findloop, 1)
			_AddRecord($CamDB, "Cameras", $CamDB_OBJ, $o_camname & '|' & $o_camurl)
		Next
		;Set Cam Script
		If GUICtrlRead($Gui_CamTrigger) = 4 And $CamTrigger = 1 Then _CamTriggerToggle()
		If GUICtrlRead($Gui_CamTrigger) = 1 And $CamTrigger = 0 Then _CamTriggerToggle()
		$CamTriggerScript = GUICtrlRead($GUI_CamTriggerScript)
		$CamTriggerTime = GUICtrlRead($GUI_CamTriggerTime)
	EndIf
	Dim $Apply_Misc = 1, $Apply_Save = 1, $Apply_GPS = 1, $Apply_Language = 0, $Apply_Manu = 0, $Apply_Lab = 0, $Apply_Column = 1, $Apply_Searchword = 1, $Apply_Auto = 1, $Apply_Sound = 1, $Apply_WifiDB = 1, $Apply_Cam = 0
	If $RestartVistumbler = 1 Then MsgBox(0, $Text_Restart, $Text_RestartMsg)
EndFunc   ;==>_ApplySettingsGUI

Func _SetWidthValue_RadioType()
	_SetWidthValue($CWCB_RadioType, $CWIB_RadioType, $column_Width_RadioType, $settings, 'Column_Width', 'Column_RadioType', 100)
EndFunc   ;==>_SetWidthValue_RadioType
Func _SetWidthValue_Channel()
	_SetWidthValue($CWCB_Channel, $CWIB_Channel, $column_Width_Channel, $settings, 'Column_Width', 'Column_Channel', 55)
EndFunc   ;==>_SetWidthValue_Channel
Func _SetWidthValue_Latitude()
	_SetWidthValue($CWCB_Latitude, $CWIB_Latitude, $column_Width_Latitude, $settings, 'Column_Width', 'Column_Latitude', 100)
EndFunc   ;==>_SetWidthValue_Latitude
Func _SetWidthValue_Longitude()
	_SetWidthValue($CWCB_Longitude, $CWIB_Longitude, $column_Width_Longitude, $settings, 'Column_Width', 'Column_Longitude', 100)
EndFunc   ;==>_SetWidthValue_Longitude
Func _SetWidthValue_LatitudeDMS()
	_SetWidthValue($CWCB_LatitudeDMS, $CWIB_LatitudeDMS, $column_Width_LatitudeDMS, $settings, 'Column_Width', 'Column_LatitudeDMS', 100)
EndFunc   ;==>_SetWidthValue_LatitudeDMS
Func _SetWidthValue_LongitudeDMS()
	_SetWidthValue($CWCB_LongitudeDMS, $CWIB_LongitudeDMS, $column_Width_LongitudeDMS, $settings, 'Column_Width', 'Column_LongitudeDMS', 100)
EndFunc   ;==>_SetWidthValue_LongitudeDMS
Func _SetWidthValue_LatitudeDMM()
	_SetWidthValue($CWCB_LatitudeDMM, $CWIB_LatitudeDMM, $column_Width_LatitudeDMM, $settings, 'Column_Width', 'Column_LatitudeDMM', 100)
EndFunc   ;==>_SetWidthValue_LatitudeDMM
Func _SetWidthValue_LongitudeDMM()
	_SetWidthValue($CWCB_LongitudeDMM, $CWIB_LongitudeDMM, $column_Width_LongitudeDMM, $settings, 'Column_Width', 'Column_LongitudeDMM', 100)
EndFunc   ;==>_SetWidthValue_LongitudeDMM
Func _SetWidthValue_BtX()
	_SetWidthValue($CWCB_BtX, $CWIB_BtX, $column_Width_BasicTransferRates, $settings, 'Column_Width', 'Column_BasicTransferRates', 140)
EndFunc   ;==>_SetWidthValue_BtX
Func _SetWidthValue_OtX()
	_SetWidthValue($CWCB_OtX, $CWIB_OtX, $column_Width_OtherTransferRates, $settings, 'Column_Width', 'Column_OtherTransferRates', 140)
EndFunc   ;==>_SetWidthValue_OtX
Func _SetWidthValue_FirstActive()
	_SetWidthValue($CWCB_FirstActive, $CWIB_FirstActive, $column_Width_FirstActive, $settings, 'Column_Width', 'Column_FirstActive', 165)
EndFunc   ;==>_SetWidthValue_FirstActive
Func _SetWidthValue_LastActive()
	_SetWidthValue($CWCB_LastActive, $CWIB_LastActive, $column_Width_LastActive, $settings, 'Column_Width', 'Column_LastActive', 150)
EndFunc   ;==>_SetWidthValue_LastActive
Func _SetWidthValue_Line()
	_SetWidthValue($CWCB_Line, $CWIB_Line, $column_Width_Line, $settings, 'Column_Width', 'Column_Line', 60)
EndFunc   ;==>_SetWidthValue_Line
Func _SetWidthValue_Active()
	_SetWidthValue($CWCB_Active, $CWIB_Active, $column_Width_Active, $settings, 'Column_Width', 'Column_Active', 60)
EndFunc   ;==>_SetWidthValue_Active
Func _SetWidthValue_SSID()
	_SetWidthValue($CWCB_SSID, $CWIB_SSID, $column_Width_SSID, $settings, 'Column_Width', 'Column_SSID', 115)
EndFunc   ;==>_SetWidthValue_SSID
Func _SetWidthValue_BSSID()
	_SetWidthValue($CWCB_BSSID, $CWIB_BSSID, $column_Width_BSSID, $settings, 'Column_Width', 'Column_BSSID', 135)
EndFunc   ;==>_SetWidthValue_BSSID
Func _SetWidthValue_Manu()
	_SetWidthValue($CWCB_Manu, $CWIB_Manu, $column_Width_MANUF, $settings, 'Column_Width', 'Column_Manufacturer', 100)
EndFunc   ;==>_SetWidthValue_Manu
Func _SetWidthValue_Signal()
	_SetWidthValue($CWCB_Signal, $CWIB_Signal, $column_Width_Signal, $settings, 'Column_Width', 'Column_Signal', 75)
EndFunc   ;==>_SetWidthValue_Signal
Func _SetWidthValue_HighSignal()
	_SetWidthValue($CWCB_HighSignal, $CWIB_HighSignal, $column_Width_HighSignal, $settings, 'Column_Width', 'Column_HighSignal', 75)
EndFunc   ;==>_SetWidthValue_HighSignal
Func _SetWidthValue_RSSI()
	_SetWidthValue($CWCB_RSSI, $CWIB_RSSI, $column_Width_RSSI, $settings, 'Column_Width', 'Column_RSSI', 75)
EndFunc   ;==>_SetWidthValue_RSSI
Func _SetWidthValue_HighRSSI()
	_SetWidthValue($CWCB_HighRSSI, $CWIB_HighRSSI, $column_Width_HighRSSI, $settings, 'Column_Width', 'Column_HighRSSI', 75)
EndFunc   ;==>_SetWidthValue_HighRSSI
Func _SetWidthValue_Authentication()
	_SetWidthValue($CWCB_Authentication, $CWIB_Authentication, $column_Width_Authentication, $settings, 'Column_Width', 'Column_Authentication', 100)
EndFunc   ;==>_SetWidthValue_Authentication
Func _SetWidthValue_Encryption()
	_SetWidthValue($CWCB_Encryption, $CWIB_Encryption, $column_Width_Encryption, $settings, 'Column_Width', 'Column_Encryption', 100)
EndFunc   ;==>_SetWidthValue_Encryption
Func _SetWidthValue_NetType()
	_SetWidthValue($CWCB_NetType, $CWIB_NetType, $column_Width_NetworkType, $settings, 'Column_Width', 'Column_NetworkType', 100)
EndFunc   ;==>_SetWidthValue_NetType
Func _SetWidthValue_Label()
	_SetWidthValue($CWCB_Label, $CWIB_Label, $column_Width_Label, $settings, 'Column_Width', 'Column_Label', 100)
EndFunc   ;==>_SetWidthValue_Label

Func _AddManu();Adds new manucaturer to settings gui manufacturer list
	$Apply_Manu = 1
	$StrippedMac = StringUpper(StringReplace(StringReplace(StringReplace(StringReplace(GUICtrlRead($GUI_Manu_NewMac), ':', ''), '-', ''), '"', ''), ' ', ''))
	$AddMac = '"' & StringTrimRight($StrippedMac, StringLen($StrippedMac) - 6) & '"'
	$AddLM = GUICtrlRead($GUI_Manu_NewManu)
	$arraysearch = -1
	$itemcount = _GUICtrlListView_GetItemCount($GUI_Manu_List) - 1; Get List Size
	For $findloop = 0 To $itemcount; Find BSSID list; If found, set $arraysearch with position
		If _GUICtrlListView_GetItemText($GUI_Manu_List, $findloop, 0) = $AddMac Then
			$arraysearch = $findloop
			ExitLoop
		EndIf
	Next
	If $arraysearch = -1 Then
		$arraysearch = _GUICtrlListView_InsertItem($GUI_Manu_List, 0, '')
		_GUICtrlListView_SetItemText($GUI_Manu_List, $arraysearch, $AddMac, 0)
		_GUICtrlListView_SetItemText($GUI_Manu_List, $arraysearch, $AddLM, 1)
	Else
		$overwrite_entry = MsgBox(4, $Text_Overwrite & '?', $Text_MacExistsOverwriteIt)
		If $overwrite_entry = 6 Then
			_GUICtrlListView_SetItemText($GUI_Manu_List, $arraysearch, $AddMac, 0)
			_GUICtrlListView_SetItemText($GUI_Manu_List, $arraysearch, $AddLM, 1)
		EndIf
	EndIf
EndFunc   ;==>_AddManu

Func _EditManu();Opens edit manufacturer window
	$EditLine = _GUICtrlListView_GetNextItem($GUI_Manu_List)
	If $EditLine <> $LV_ERR Then
		$EditMac = StringTrimRight(StringTrimLeft(_GUICtrlListView_GetItemText($GUI_Manu_List, $EditLine, 0), 1), 1)
		$EditLab = _GUICtrlListView_GetItemText($GUI_Manu_List, $EditLine, 1)
		$EditMacGUIForm = GUICreate($Text_EditMan, 625, 86, -1, -1)
		GUISetBkColor($BackgroundColor)
		GUICtrlCreateLabel($Column_Names_BSSID, 16, 16, 69, 17)
		$EditMac_Mac = GUICtrlCreateInput($EditMac, 88, 16, 137, 21)
		GUICtrlCreateLabel($Column_Names_MANUF, 230, 16, 70, 17)
		$EditMac_GUI = GUICtrlCreateInput($EditLab, 305, 16, 300, 21)
		$EditMac_OK = GUICtrlCreateButton($Text_Ok, 200, 48, 97, 25, 0)
		$EditMac_Can = GUICtrlCreateButton($Text_Cancel, 312, 48, 97, 25, 0)
		GUISetState(@SW_SHOW)
		GUICtrlSetOnEvent($EditMac_OK, "_EditManu_Ok")
		GUICtrlSetOnEvent($EditMac_Can, "_EditManu_Close")
	EndIf
EndFunc   ;==>_EditManu

Func _RemoveManu();Removed manufactuer from list
	$Apply_Manu = 1
	$EditLine = _GUICtrlListView_GetNextItem($GUI_Manu_List)
	If $EditLine <> $LV_ERR Then _GUICtrlListView_DeleteItem($GUI_Manu_List, $EditLine)
EndFunc   ;==>_RemoveManu

Func _EditManu_Close();Close edit manufacturer window
	GUIDelete($EditMacGUIForm)
EndFunc   ;==>_EditManu_Close

Func _EditManu_Ok();Apply edit manufacture window settings and close it
	$Apply_Manu = 1
	$StrippedMac = StringUpper(StringReplace(StringReplace(StringReplace(StringReplace(GUICtrlRead($EditMac_Mac), ':', ''), '-', ''), '"', ''), ' ', ''))
	_GUICtrlListView_SetItemText($GUI_Manu_List, $EditLine, '"' & StringTrimRight($StrippedMac, StringLen($StrippedMac) - 6) & '"', 0)
	_GUICtrlListView_SetItemText($GUI_Manu_List, $EditLine, GUICtrlRead($EditMac_GUI), 1)
	GUIDelete($EditMacGUIForm)
EndFunc   ;==>_EditManu_Ok

Func _AddLabel();Adds new label to settings gui label list
	$Apply_Lab = 1
	$StrippedMac = StringUpper(StringReplace(StringReplace(StringReplace(StringReplace(GUICtrlRead($GUI_Lab_NewMac), ':', ''), '-', ''), '"', ''), ' ', ''))
	$AddMac = '"' & StringTrimRight($StrippedMac, StringLen($StrippedMac) - 12) & '"'
	$AddLM = GUICtrlRead($GUI_Lab_NewLabel)
	$arraysearch = -1
	$itemcount = _GUICtrlListView_GetItemCount($GUI_Lab_List) - 1; Get List Size
	For $findloop = 0 To $itemcount; Find BSSID list; If found, set $arraysearch with position
		If _GUICtrlListView_GetItemText($GUI_Lab_List, $findloop, 0) = $AddMac Then
			$arraysearch = $findloop
			ExitLoop
		EndIf
	Next
	If $arraysearch = -1 Then
		$arraysearch = _GUICtrlListView_InsertItem($GUI_Lab_List, 0, '')
		_GUICtrlListView_SetItemText($GUI_Lab_List, $arraysearch, $AddMac, 0)
		_GUICtrlListView_SetItemText($GUI_Lab_List, $arraysearch, $AddLM, 1)
	Else
		$overwrite_entry = MsgBox(4, $Text_Overwrite & '?', $Text_MacExistsOverwriteIt)
		If $overwrite_entry = 6 Then
			_GUICtrlListView_SetItemText($GUI_Lab_List, $arraysearch, $AddMac, 0)
			_GUICtrlListView_SetItemText($GUI_Lab_List, $arraysearch, $AddLM, 1)
		EndIf
	EndIf
EndFunc   ;==>_AddLabel

Func _EditLabel();Opens edit label window
	$EditLine = _GUICtrlListView_GetNextItem($GUI_Lab_List)
	If $EditLine <> $LV_ERR Then
		$EditMac = StringTrimRight(StringTrimLeft(_GUICtrlListView_GetItemText($GUI_Lab_List, $EditLine, 0), 1), 1)
		$EditLab = _GUICtrlListView_GetItemText($GUI_Lab_List, $EditLine, 1)
		$EditMacGUIForm = GUICreate($Text_EditLabel, 625, 86, -1, -1)
		GUISetBkColor($BackgroundColor)
		GUICtrlCreateLabel($Column_Names_BSSID, 16, 16, 69, 17)
		$EditMac_Mac = GUICtrlCreateInput($EditMac, 88, 16, 137, 21)
		GUICtrlCreateLabel($Column_Names_Label, 230, 16, 70, 17)
		$EditMac_GUI = GUICtrlCreateInput($EditLab, 305, 16, 300, 21)
		$EditMac_OK = GUICtrlCreateButton($Text_Ok, 200, 48, 97, 25, 0)
		$EditMac_Can = GUICtrlCreateButton($Text_Cancel, 312, 48, 97, 25, 0)
		GUISetState(@SW_SHOW)
		GUICtrlSetOnEvent($EditMac_OK, "_EditLabel_Ok")
		GUICtrlSetOnEvent($EditMac_Can, "_EditLabel_Close")
	EndIf
EndFunc   ;==>_EditLabel

Func _RemoveLabel();Close edit label window
	$Apply_Lab = 1
	$EditLine = _GUICtrlListView_GetNextItem($GUI_Lab_List)
	;ConsoleWrite($EditLine & ' - ' & $LV_ERR & @CRLF)
	If $EditLine <> $LV_ERR Then _GUICtrlListView_DeleteItem($GUI_Lab_List, $EditLine)
EndFunc   ;==>_RemoveLabel


Func _EditLabel_Close();Close edit label window
	GUIDelete($EditMacGUIForm)
EndFunc   ;==>_EditLabel_Close

Func _EditLabel_Ok();Apply edit label window settings and close it
	$Apply_Lab = 1
	$StrippedMac = StringUpper(StringReplace(StringReplace(StringReplace(StringReplace(GUICtrlRead($EditMac_Mac), ':', ''), '-', ''), '"', ''), ' ', ''))
	_GUICtrlListView_SetItemText($GUI_Lab_List, $EditLine, '"' & StringTrimRight($StrippedMac, StringLen($StrippedMac) - 12) & '"', 0)
	_GUICtrlListView_SetItemText($GUI_Lab_List, $EditLine, GUICtrlRead($EditMac_GUI), 1)
	GUIDelete($EditMacGUIForm)
EndFunc   ;==>_EditLabel_Ok

Func _AddCam();Adds new Camcaturer to settings gui Camfacturer list
	$Apply_Cam = 1
	$AddID = '"' & GUICtrlRead($GUI_Cam_NewID) & '"'
	$AddLOC = GUICtrlRead($GUI_Cam_NewLOC)
	$arraysearch = -1
	$itemcount = _GUICtrlListView_GetItemCount($GUI_Cam_List) - 1; Get List Size
	For $findloop = 0 To $itemcount; Find cam in list; If found, set $arraysearch with position
		If _GUICtrlListView_GetItemText($GUI_Cam_List, $findloop, 0) = $AddID Then
			$arraysearch = $findloop
			ExitLoop
		EndIf
	Next
	If $arraysearch = -1 Then
		$arraysearch = _GUICtrlListView_InsertItem($GUI_Cam_List, 0, '')
		_GUICtrlListView_SetItemText($GUI_Cam_List, $arraysearch, $AddID, 0)
		_GUICtrlListView_SetItemText($GUI_Cam_List, $arraysearch, $AddLOC, 1)
	Else
		$overwrite_entry = MsgBox(4, $Text_Overwrite & '?', "Camera Already Exists. Do you want to overwrite it.")
		If $overwrite_entry = 6 Then
			_GUICtrlListView_SetItemText($GUI_Cam_List, $arraysearch, $AddID, 0)
			_GUICtrlListView_SetItemText($GUI_Cam_List, $arraysearch, $AddLOC, 1)
		EndIf
	EndIf
EndFunc   ;==>_AddCam

Func _EditCam();Opens edit Camfacturer window
	$EditLine = _GUICtrlListView_GetNextItem($GUI_Cam_List)
	If $EditLine <> $LV_ERR Then
		$EditCamID = StringTrimRight(StringTrimLeft(_GUICtrlListView_GetItemText($GUI_Cam_List, $EditLine, 0), 1), 1)
		$EditCamLoc = _GUICtrlListView_GetItemText($GUI_Cam_List, $EditLine, 1)
		$EditCamGUIForm = GUICreate($Text_AddCamera, 625, 86, -1, -1)
		GUISetBkColor($BackgroundColor)
		GUICtrlCreateLabel($Text_CameraName, 16, 16, 69, 17)
		$GUI_Edit_CamID = GUICtrlCreateInput($EditCamID, 88, 16, 137, 21)
		GUICtrlCreateLabel($Text_CameraURL, 230, 16, 70, 17)
		$GUI_Edit_CamLOC = GUICtrlCreateInput($EditCamLoc, 305, 16, 300, 21)
		$EditCam_OK = GUICtrlCreateButton($Text_Ok, 200, 48, 97, 25, 0)
		$EditCam_Can = GUICtrlCreateButton($Text_Cancel, 312, 48, 97, 25, 0)
		GUISetState(@SW_SHOW)
		GUICtrlSetOnEvent($EditCam_OK, "_EditCam_Ok")
		GUICtrlSetOnEvent($EditCam_Can, "_EditCam_Close")
	EndIf
EndFunc   ;==>_EditCam

Func _EditCam_Close();Close edit Camfacturer window
	GUIDelete($EditCamGUIForm)
EndFunc   ;==>_EditCam_Close

Func _EditCam_Ok();Apply edit Camfacture window settings and close it
	$Apply_Cam = 1
	$AddID = '"' & GUICtrlRead($GUI_Edit_CamID) & '"'
	$AddLOC = GUICtrlRead($GUI_Edit_CamLOC)
	_GUICtrlListView_SetItemText($GUI_Cam_List, $EditLine, $AddID, 0)
	_GUICtrlListView_SetItemText($GUI_Cam_List, $EditLine, $AddLOC, 1)
	GUIDelete($EditMacGUIForm)
EndFunc   ;==>_EditCam_Ok

Func _RemoveCam();Removed Camfactuer from list
	$Apply_Cam = 1
	$EditLine = _GUICtrlListView_GetNextItem($GUI_Cam_List)
	;ConsoleWrite($EditLine & ' - ' & $LV_ERR & @CRLF)
	If $EditLine <> $LV_ERR Then _GUICtrlListView_DeleteItem(GUICtrlGetHandle($GUI_Cam_List), $EditLine)
EndFunc   ;==>_RemoveCam

Func _SetWidthValue(ByRef $wcheckbox, ByRef $winput, $wcurrentwidth, $wsettings, $wsection, $wvalue, $wdef);Enable or disable a column in settings gui. reset width
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_SetWidthValue()') ;#Debug Display
	If GUICtrlRead($wcheckbox) = $GUI_UNCHECKED Then
		GUICtrlSetData($winput, 0)
		GUICtrlSetState($winput, $GUI_DISABLE)
	Else
		If $wcurrentwidth <> 0 Then
			GUICtrlSetData($winput, $wcurrentwidth)
		Else
			$wcolumnwidth = IniRead($wsettings, $wsection, $wvalue, $wdef)
			If $wcolumnwidth <> 0 Then
				GUICtrlSetData($winput, $wcolumnwidth)
			Else
				GUICtrlSetData($winput, $wdef)
			EndIf
		EndIf
		GUICtrlSetState($winput, $GUI_ENABLE)
	EndIf
EndFunc   ;==>_SetWidthValue

Func _SetCWCBIB(ByRef $CWIB, ByRef $CWCB);Sets column enabled or disabled based on width
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_SetCWCBIB()') ;#Debug Display
	If GUICtrlRead($CWIB) = 0 Then
		GUICtrlSetState($CWIB, $GUI_DISABLE)
		GUICtrlSetState($CWCB, $GUI_UNCHECKED)
	Else
		GUICtrlSetState($CWIB, $GUI_ENABLE)
		GUICtrlSetState($CWCB, $GUI_CHECKED)
	EndIf
EndFunc   ;==>_SetCWCBIB

Func _SetCwState(); Set All columns in settings gui enabled or disabled
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_SetCwState()') ;#Debug Display
	_SetCWCBIB($CWIB_Line, $CWCB_Line)
	_SetCWCBIB($CWIB_Active, $CWCB_Active)
	_SetCWCBIB($CWIB_SSID, $CWCB_SSID)
	_SetCWCBIB($CWIB_BSSID, $CWCB_BSSID)
	_SetCWCBIB($CWIB_Signal, $CWCB_Signal)
	_SetCWCBIB($CWIB_HighSignal, $CWCB_HighSignal)
	_SetCWCBIB($CWIB_RSSI, $CWCB_RSSI)
	_SetCWCBIB($CWIB_HighRSSI, $CWCB_HighRSSI)
	_SetCWCBIB($CWIB_Authentication, $CWCB_Authentication)
	_SetCWCBIB($CWIB_Encryption, $CWCB_Encryption)
	_SetCWCBIB($CWIB_NetType, $CWCB_NetType)
	_SetCWCBIB($CWIB_RadioType, $CWCB_RadioType)


	_SetCWCBIB($CWIB_Manu, $CWCB_Manu)
	_SetCWCBIB($CWIB_Label, $CWCB_Label)

	_SetCWCBIB($CWIB_Channel, $CWCB_Channel)
	_SetCWCBIB($CWIB_Latitude, $CWCB_Latitude)
	_SetCWCBIB($CWIB_Longitude, $CWCB_Longitude)
	_SetCWCBIB($CWIB_LatitudeDMS, $CWCB_LatitudeDMS)
	_SetCWCBIB($CWIB_LongitudeDMS, $CWCB_LongitudeDMS)
	_SetCWCBIB($CWIB_LatitudeDMM, $CWCB_LatitudeDMM)
	_SetCWCBIB($CWIB_LongitudeDMM, $CWCB_LongitudeDMM)
	_SetCWCBIB($CWIB_BtX, $CWCB_BtX)
	_SetCWCBIB($CWIB_OtX, $CWCB_OtX)
	_SetCWCBIB($CWIB_FirstActive, $CWCB_FirstActive)
	_SetCWCBIB($CWIB_LastActive, $CWCB_LastActive)

EndFunc   ;==>_SetCwState

Func _GuessNetshSearchwords()
	Local $GSearchWord_SSID = '', $GSearchWord_NetworkType = '', $GSearchWord_Authentication = '', $GSearchWord_Encryption = '', $GSearchWord_BSSID = '', $GSearchWord_Signal = '', $GSearchWord_RadioType = '', $GSearchWord_Channel = '', $GSearchWord_BasicRates = '', $GSearchWord_OtherRates = ''
	$count = 0
	FileDelete($tempfile)
	If $DefaultApapter = $Text_Default Then
		_RunDos('netsh wlan show networks mode=bssid > ' & '"' & $tempfile & '"') ;copy the output of the 'netsh wlan show networks mode=bssid' command to the temp file
	Else
		_RunDos($netsh & ' wlan show networks interface="' & $DefaultApapter & '" mode=bssid > ' & '"' & $tempfile & '"') ;copy the output of the 'netsh wlan show networks mode=bssid' command to the temp file
	EndIf

	$arrayadded = _FileReadToArray($tempfile, $TempFileArray);read the tempfile into the '$TempFileArray' Araay
	If $arrayadded = 1 Then
		;Strip out whitespace before and after text on each line
		For $stripws = 1 To $TempFileArray[0]
			$TempFileArray[$stripws] = StringStripWS($TempFileArray[$stripws], 3)
		Next

		For $loop = 1 To $TempFileArray[0]
			$temp = StringSplit(StringStripWS($TempFileArray[$loop], 3), ":")
			If IsArray($temp) Then
				If $temp[0] = 2 Or $temp[0] = 7 Then
					$count += 1
					If $count = 1 Then
						$GSearchword_Adapter = StringStripWS($temp[1], 3)
					ElseIf $count = 2 Then
						$GSearchWord_SSID = StringStripWS($temp[1], 3)
						If StringInStr($GSearchWord_SSID, ' ') Then
							$SSID_Split = StringSplit($GSearchWord_SSID, ' ')
							If $SSID_Split[0] = 2 Then $GSearchWord_SSID = $SSID_Split[1]
						EndIf
					ElseIf $count = 3 Then
						$GSearchWord_NetworkType = StringStripWS($temp[1], 3)
					ElseIf $count = 4 Then
						$GSearchWord_Authentication = StringStripWS($temp[1], 3)
					ElseIf $count = 5 Then
						$GSearchWord_Encryption = StringStripWS($temp[1], 3)
					ElseIf $count = 6 Then
						$GSearchWord_BSSID = StringStripWS($temp[1], 3)
						If StringInStr($GSearchWord_BSSID, ' ') Then
							$BSSID_Split = StringSplit($GSearchWord_BSSID, ' ')
							If $BSSID_Split[0] = 2 Then $GSearchWord_BSSID = $BSSID_Split[1]
						EndIf
					ElseIf $count = 7 Then
						$GSearchWord_Signal = StringStripWS($temp[1], 3)
					ElseIf $count = 8 Then
						$GSearchWord_RadioType = StringStripWS($temp[1], 3)
					ElseIf $count = 9 Then
						$GSearchWord_Channel = StringStripWS($temp[1], 3)
					ElseIf $count = 10 Then
						$GSearchWord_BasicRates = StringStripWS($temp[1], 3)
					ElseIf $count = 11 Then
						$GSearchWord_OtherRates = StringStripWS($temp[1], 3)
					EndIf
				EndIf
			EndIf
		Next
		;Update Data In GUI
		If $GSearchWord_SSID <> '' And $GSearchWord_NetworkType <> '' And $GSearchWord_Authentication <> '' And $GSearchWord_Encryption <> '' And $GSearchWord_BSSID <> '' And $GSearchWord_Signal <> '' And $GSearchWord_RadioType <> '' And $GSearchWord_Channel <> '' And $GSearchWord_BasicRates <> '' And $GSearchWord_OtherRates <> '' Then
			GUICtrlSetData($SearchWord_SSID_GUI, $GSearchWord_SSID)
			GUICtrlSetData($SearchWord_NetType_GUI, $GSearchWord_NetworkType)
			GUICtrlSetData($SearchWord_Authentication_GUI, $GSearchWord_Authentication)
			GUICtrlSetData($SearchWord_Encryption_GUI, $GSearchWord_Encryption)
			GUICtrlSetData($SearchWord_BSSID_GUI, $GSearchWord_BSSID)
			GUICtrlSetData($SearchWord_Signal_GUI, $GSearchWord_Signal)
			GUICtrlSetData($SearchWord_RadioType_GUI, $GSearchWord_RadioType)
			GUICtrlSetData($SearchWord_Channel_GUI, $GSearchWord_Channel)
			GUICtrlSetData($SearchWord_BasicRates_GUI, $GSearchWord_BasicRates)
			GUICtrlSetData($SearchWord_OtherRates_GUI, $GSearchWord_OtherRates)
			;Show Done Message
			MsgBox(0, $Text_Information, $Text_AddedGuessedSearchwords)
		Else
			MsgBox(0, $Text_Error, $Text_UnableToGuessSearchwords)
		EndIf
	EndIf
EndFunc   ;==>_GuessNetshSearchwords

Func _GUICtrlTab_SetBkColor($hWnd, $hSysTab32, $sBkColor) ;Function used to set the background color in a tab --> http://www.autoitscript.com/forum/index.php?showtopic=40659&view=findpost&p=497705
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_GUICtrlTab_SetBkColor()') ;#Debug Display
	Local $aTabPos = ControlGetPos($hWnd, "", $hSysTab32)
	Local $aTab_Rect = _GUICtrlTab_GetItemRect($hSysTab32, -1)
	GUICtrlCreateLabel("", $aTabPos[0] + 2, $aTabPos[1] + $aTab_Rect[3] + 4, $aTabPos[2] - 4, $aTabPos[3] - $aTab_Rect[3] - 7)
	GUICtrlSetBkColor(-1, $sBkColor)
	GUICtrlSetState(-1, $GUI_DISABLE)
EndFunc   ;==>_GUICtrlTab_SetBkColor

;-------------------------------------------------------------------------------------------------------------------------------
;                                                       SAY SIGNAL / MIDI FUNCTIONS
;-------------------------------------------------------------------------------------------------------------------------------

Func _SpeakSelectedSignal();Finds the slected access point and speaks its signal strenth
	$ErrorFlag = 0
	If $SpeakSignal = 1 Then; If the signal speaking is turned on
		$Selected = _GUICtrlListView_GetNextItem($ListviewAPs); find what AP is selected in the list. returns -1 is nothing is selected
		If $Selected <> -1 Then ;If a access point is selected in the listview, play its signal strenth
			$query = "SELECT LastHistID, Active, SSID FROM AP WHERE ListRow=" & $Selected
			$ApMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
			$FoundApMatch = UBound($ApMatchArray) - 1
			If $FoundApMatch <> 0 Then
				$PlayHistID = $ApMatchArray[1][1]
				$ApIsActive = $ApMatchArray[1][2]
				$ApSSID = $ApMatchArray[1][3]
				$query = "SELECT Signal FROM Hist WHERE HistID=" & $PlayHistID
				$HistMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
				$FoundHistMatch = UBound($HistMatchArray) - 1
				If $FoundHistMatch <> 0 Then
					If $ApIsActive = 1 Then
						$say = $HistMatchArray[1][1]
					Else
						$say = '0'
					EndIf
					If ProcessExists($SayProcess) = 0 Then;If Say.exe is still running, skip opening it again
						If $SpeakType = 1 Then ;Use Sound Files
							$run = FileGetShortName(@ScriptDir & '\say.exe') & ' /s="' & $say & '" /t=1'
							If $SpeakSigSayPecent = 1 Then $run &= ' /p'
							$SayProcess = Run(@ComSpec & " /C " & $run, '', @SW_HIDE)
							If @error Then $ErrorFlag = 1
						ElseIf $SpeakType = 2 Then ;Use Microsoft Sound API
							$SayNameBefore = 0
							If $SayNameBefore = 1 Then $say = $ApSSID & ' ' & $say
							$run = FileGetShortName(@ScriptDir & '\say.exe') & ' /s="' & $say & '" /t=2'
							If $SpeakSigSayPecent = 1 Then $run &= ' /p'
							$SayProcess = Run(@ComSpec & " /C " & $run, '', @SW_HIDE)
							If @error Then $ErrorFlag = 1
						ElseIf $SpeakType = 3 Then ;Use midi files
							$run = FileGetShortName(@ScriptDir & '\say.exe') & ' /s="' & $say & '" /t=3 /i=' & $Midi_Instument & ' /w=' & $Midi_PlayTime
							$SayProcess = Run(@ComSpec & " /C " & $run, '', @SW_HIDE)
							If @error Then $ErrorFlag = 1
						EndIf
					Else
						$ErrorFlag = 1
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
	If $ErrorFlag = 0 Then
		Return (1)
	Else
		Return (0)
	EndIf
EndFunc   ;==>_SpeakSelectedSignal

Func _PlayMidiForActiveAPs()
	If $Midi_PlayForActiveAps = 1 And ProcessExists($MidiProcess) = 0 Then
		$query = "SELECT Signal FROM Hist WHERE GpsID=" & $GPS_ID
		$TempHistArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
		$FoundTempHist = UBound($TempHistArray) - 1
		If $FoundTempHist <> 0 Then
			$PlaySignals = ''
			For $mp = 1 To $FoundTempHist
				If $mp <> 1 Then $PlaySignals &= '-'
				$PlaySignals &= $TempHistArray[$mp][1]
			Next
			If $PlaySignals <> '' Then
				$run = FileGetShortName(@ScriptDir & '\say.exe') & ' /ms=' & $PlaySignals & ' /t=4 /i=' & $Midi_Instument & ' /w=' & $Midi_PlayTime
				$MidiProcess = Run(@ComSpec & " /C " & $run, '', @SW_HIDE)
			EndIf
		EndIf
	EndIf
EndFunc   ;==>_PlayMidiForActiveAPs

Func _PlayWavSound($Sound)
	$run = FileGetShortName(@ScriptDir & '\UDFs\sounder.exe') & ' ' & FileGetShortName($Sound)
	Run(@ComSpec & " /C " & $run, '', @SW_HIDE)
EndFunc   ;==>_PlayWavSound

;-------------------------------------------------------------------------------------------------------------------------------
;                                                       UPDATE FUNCTIONS
;-------------------------------------------------------------------------------------------------------------------------------

Func _MenuUpdate()
	If _CheckForUpdates() = 1 Then
		$updatemsg = MsgBox(4, $Text_Update & '?', $Text_UpdateMsg)
		If $updatemsg = 6 Then _StartUpdate()
	Else
		MsgBox(0, $Text_Information, $Text_NoUpdates)
	EndIf
EndFunc   ;==>_MenuUpdate

Func _StartUpdate()
	_WriteINI()
	Run(@ScriptDir & '\update.exe')
	Exit
EndFunc   ;==>_StartUpdate

Func _CheckForUpdates()
	$UpdatesAvalible = 0
	FileDelete($NewVersionFile)
	If $CheckForBetaUpdates = 1 Then
		$get = InetGet($GIT_ROOT & 'beta/VistumblerMDB/versions.ini', $NewVersionFile, 1)
		If $get = 0 Then FileDelete($NewVersionFile)
	Else
		$get = InetGet($GIT_ROOT & 'master/VistumblerMDB/versions.ini', $NewVersionFile, 1)
		If $get = 0 Then FileDelete($NewVersionFile)
	EndIf
	If FileExists($NewVersionFile) Then
		$fv = IniReadSection($NewVersionFile, "FileVersions")
		If Not @error Then
			For $i = 1 To $fv[0][0]
				$filename = $fv[$i][0]
				$fversion = $fv[$i][1]
				If IniRead($CurrentVersionFile, "FileVersions", $filename, '0') <> $fversion Or FileExists(@ScriptDir & '\' & $filename) = 0 Then
					If $filename = 'update.exe' Then ;Download updated update.exe
						$dloadupdatemsg = MsgBox(4, $Text_Information, $Text_UpdateUpdaterMsg)
						If $dloadupdatemsg = 6 Then
							$sourcefile = $GIT_ROOT & $fversion & '/VistumblerMDB/' & $filename
							$desttmpfile = $TmpDir & $filename & '.tmp'
							$destfile = @ScriptDir & '\' & $filename
							$get = InetGet($sourcefile, $desttmpfile, 1)
							If $get <> 0 And FileGetSize($desttmpfile) <> 0 Then ;Download Successful
								If FileMove($desttmpfile, $destfile, 9) = 1 Then IniWrite($CurrentVersionFile, "FileVersions", $filename, $fversion)
							EndIf
							FileDelete($desttmpfile)
						EndIf
					Else
						$UpdatesAvalible = 1
					EndIf
				EndIf
			Next
		EndIf
	EndIf
	Return ($UpdatesAvalible)
EndFunc   ;==>_CheckForUpdates

Func _ManufacturerUpdate()
	Run(@ScriptDir & '\UpdateManufactures.exe')
	Exit
EndFunc   ;==>_ManufacturerUpdate

;-------------------------------------------------------------------------------------------------------------------------------
;                                                       FILTER FUNCTIONS
;-------------------------------------------------------------------------------------------------------------------------------

Func _ModifyFilters()
	$GUI_ModifyFilters = GUICreate($Text_AddRemFilters, 620, 330)
	GUISetBkColor($BackgroundColor)
	$FilterLV = GUICtrlCreateListView("ID|Name|Description", 10, 8, 600, 254, $LVS_REPORT + $LVS_SINGLESEL, $LVS_EX_HEADERDRAGDROP + $LVS_EX_GRIDLINES + $LVS_EX_FULLROWSELECT)
	GUICtrlSetBkColor(-1, $ControlBackgroundColor)
	_GUICtrlListView_SetColumnWidth($FilterLV, 0, 30)
	_GUICtrlListView_SetColumnWidth($FilterLV, 1, 160)
	_GUICtrlListView_SetColumnWidth($FilterLV, 2, 400)
	$query = "SELECT FiltID, FiltName, FiltDesc FROM Filters"
	$FiltMatchArray = _RecordSearch($FiltDB, $query, $FiltDB_OBJ)
	$FoundFiltMatch = UBound($FiltMatchArray) - 1
	If $FoundFiltMatch <> 0 Then
		For $ffm = 1 To $FoundFiltMatch
			$Filter_ID = $FiltMatchArray[$ffm][1]
			$Filter_Name = $FiltMatchArray[$ffm][2]
			$Filter_Desc = $FiltMatchArray[$ffm][3]
			GUICtrlCreateListViewItem($Filter_ID & '|' & $Filter_Name & '|' & $Filter_Desc, $FilterLV)
		Next
	EndIf
	$GUI_AddFilter = GUICtrlCreateButton($Text_AddFilter, 10, 265, 200, 25, $WS_GROUP)
	$GUI_EditFilter = GUICtrlCreateButton($Text_EditFilter, 210, 265, 200, 25, $WS_GROUP)
	$GUI_DelFilter = GUICtrlCreateButton($Text_DeleteFilter, 410, 265, 200, 25, $WS_GROUP)
	$GUI_Filter_Close = GUICtrlCreateButton($Text_Close, 250, 296, 113, 25, $WS_GROUP)
	GUISetState(@SW_SHOW)
	GUISetOnEvent($GUI_EVENT_CLOSE, '_ModifyFilters_Close')
	GUICtrlSetOnEvent($GUI_Filter_Close, "_ModifyFilters_Close")
	GUICtrlSetOnEvent($GUI_AddFilter, "_AddFilter")
	GUICtrlSetOnEvent($GUI_EditFilter, "_EditFilter")
	GUICtrlSetOnEvent($GUI_DelFilter, "_DeleteFilter")
EndFunc   ;==>_ModifyFilters

Func _DeleteFilter()
	Local $menuid = '-1'
	Local $ArrayID = '-1'
	Local $Selected = _GUICtrlListView_GetNextItem($FilterLV)
	If $Selected <> -1 Then
		$FilterID = _GUICtrlListView_GetItemText($FilterLV, $Selected, 0)
		;Get MenuID based on Filter ID
		For $fl = 1 To $FilterID_Array[0]
			If $FilterID_Array[$fl] = $FilterID Then
				$menuid = $FilterMenuID_Array[$fl]
				$ArrayID = $fl
				ExitLoop
			EndIf
		Next
		;Delete Filter from DB
		$query = "DELETE FROM Filters WHERE FiltID='" & $FilterID & "'"
		_ExecuteMDB($FiltDB, $FiltDB_OBJ, $query)
		$FiltID -= 1
		$query = "UPDATE Filters SET FiltID = FiltID - 1 WHERE FiltID > '" & $FilterID & "'"
		_ExecuteMDB($FiltDB, $FiltDB_OBJ, $query)
		;Delete Menu Item
		If $menuid <> '-1' Then GUICtrlDelete($menuid)
		If $ArrayID <> '-1' Then
			_ArrayDelete($FilterID_Array, $ArrayID)
			_ArrayDelete($FilterMenuID_Array, $ArrayID)
			$FilterID_Array[0] = UBound($FilterID_Array) - 1
			$FilterMenuID_Array[0] = UBound($FilterMenuID_Array) - 1
		EndIf
		For $fl = 1 To $FilterID_Array[0]
			If $FilterID_Array[$fl] > $FilterID Then $FilterID_Array[$fl] = $FilterID_Array[$fl] - 1
		Next
		;Create new filter string if this is the default filter
		If $DefFiltID = $FilterID Then
			$DefFiltID = '-1'
			_CreateFilterQuerys()
		EndIf
		;Refresh GUI
		_ModifyFilters_Close()
		_ModifyFilters()
	Else
		MsgBox(0, $Text_Error, $Text_NoFilterSelected)
	EndIf
EndFunc   ;==>_DeleteFilter

Func _ModifyFilters_Close()
	GUIDelete($GUI_ModifyFilters)
EndFunc   ;==>_ModifyFilters_Close

Func _AddFilter()
	_AddEditFilter()
	_ModifyFilters_Close()
EndFunc   ;==>_AddFilter

Func _EditFilter()
	$Selected = _GUICtrlListView_GetNextItem($FilterLV)
	If $Selected <> -1 Then
		$FilterID = _GUICtrlListView_GetItemText($FilterLV, $Selected, 0)
		_AddEditFilter($FilterID)
		_ModifyFilters_Close()
	Else
		MsgBox(0, $Text_Error, $Text_NoFilterSelected)
	EndIf
EndFunc   ;==>_EditFilter

Func _AddEditFilter($Filter_ID = '-1')
	Local $Filter_Name, $Filter_Desc, $Filter_SSID = "*", $Filter_BSSID = "*", $Filter_CHAN = "*", $Filter_AUTH = "*", $Filter_ENCR = "*", $Filter_RADTYPE = "*", $Filter_NETTYPE = "*", $Filter_SIG = "*", $Filter_HighSig = "*", $Filter_RSSI = "*", $Filter_HighRSSI = "*", $Filter_BTX = "*", $Filter_OTX = "*", $Filter_Line = "*", $Filter_Active = "*"
	If $Filter_ID <> '-1' Then
		$query = "SELECT FiltName, FiltDesc, SSID, BSSID, CHAN, AUTH, ENCR, RADTYPE, NETTYPE, Signal, HighSig, RSSI, HighRSSI, BTX, OTX, ApID, Active FROM Filters WHERE FiltID='" & $Filter_ID & "'"
		$FiltMatchArray = _RecordSearch($FiltDB, $query, $FiltDB_OBJ)
		$Filter_Name = $FiltMatchArray[1][1]
		$Filter_Desc = $FiltMatchArray[1][2]
		$Filter_SSID = $FiltMatchArray[1][3]
		$Filter_BSSID = $FiltMatchArray[1][4]
		$Filter_CHAN = $FiltMatchArray[1][5]
		$Filter_AUTH = $FiltMatchArray[1][6]
		$Filter_ENCR = $FiltMatchArray[1][7]
		$Filter_RADTYPE = $FiltMatchArray[1][8]
		$Filter_NETTYPE = $FiltMatchArray[1][9]
		$Filter_SIG = $FiltMatchArray[1][10]
		$Filter_HighSig = $FiltMatchArray[1][11]
		$Filter_RSSI = $FiltMatchArray[1][12]
		$Filter_HighRSSI = $FiltMatchArray[1][13]
		$Filter_BTX = $FiltMatchArray[1][14]
		$Filter_OTX = $FiltMatchArray[1][15]
		$Filter_Line = $FiltMatchArray[1][16]
		$Filter_Active = $FiltMatchArray[1][17]
	EndIf
	$Filter_ID_GUI = $Filter_ID

	$AddEditFilt_GUI = GUICreate($Text_FilterAddEdit, 690, 500, -1, -1, BitOR($WS_OVERLAPPEDWINDOW, $WS_CLIPSIBLINGS))

	GUICtrlCreateLabel($Text_FilterName, 28, 15, 300, 15)
	GUICtrlSetColor(-1, $TextColor)
	$Filter_Name_GUI = GUICtrlCreateInput($Filter_Name, 28, 30, 300, 20)
	GUICtrlCreateLabel($Text_FilterDesc, 353, 15, 300, 15)
	GUICtrlSetColor(-1, $TextColor)
	$Filter_Desc_GUI = GUICtrlCreateInput($Filter_Desc, 353, 30, 300, 20)
	GUISetBkColor($BackgroundColor)
	GUICtrlCreateGroup($Text_Filters, 8, 75, 665, 390)
	GUICtrlCreateLabel($Text_FilterMsg, 32, 90, 618, 40)
	GUICtrlSetColor(-1, $TextColor)
	GUICtrlCreateLabel($Column_Names_SSID, 28, 125, 300, 15)
	GUICtrlSetColor(-1, $TextColor)
	$Filter_SSID_GUI = GUICtrlCreateInput($Filter_SSID, 28, 140, 300, 20)
	GUICtrlCreateLabel($Column_Names_BSSID, 28, 165, 300, 15)
	GUICtrlSetColor(-1, $TextColor)
	$Filter_BSSID_GUI = GUICtrlCreateInput($Filter_BSSID, 28, 180, 300, 20)
	GUICtrlCreateLabel($Column_Names_Channel, 28, 205, 300, 15)
	GUICtrlSetColor(-1, $TextColor)
	$Filter_CHAN_GUI = GUICtrlCreateInput($Filter_CHAN, 28, 220, 300, 20)
	GUICtrlCreateLabel($Column_Names_Authentication, 28, 245, 300, 15)
	GUICtrlSetColor(-1, $TextColor)
	$Filter_AUTH_GUI = GUICtrlCreateInput($Filter_AUTH, 28, 260, 300, 20)
	GUICtrlCreateLabel($Column_Names_Encryption, 28, 285, 300, 15)
	GUICtrlSetColor(-1, $TextColor)
	$Filter_ENCR_GUI = GUICtrlCreateInput($Filter_ENCR, 28, 300, 300, 20)
	GUICtrlCreateLabel($Column_Names_RadioType, 28, 325, 300, 15)
	GUICtrlSetColor(-1, $TextColor)
	$Filter_RADTYPE_GUI = GUICtrlCreateInput($Filter_RADTYPE, 28, 340, 300, 20)
	GUICtrlCreateLabel($Column_Names_NetworkType, 28, 365, 300, 15)
	GUICtrlSetColor(-1, $TextColor)
	$Filter_NETTYPE_GUI = GUICtrlCreateInput($Filter_NETTYPE, 28, 380, 300, 20)
	GUICtrlCreateLabel($Column_Names_Active, 28, 405, 300, 15)
	GUICtrlSetColor(-1, $TextColor)
	$Filter_Active_GUI = GUICtrlCreateInput($Filter_Active, 28, 420, 300, 20)
	GUICtrlSetColor(-1, $TextColor)
	GUICtrlCreateLabel($Column_Names_BasicTransferRates, 353, 125, 300, 15)
	GUICtrlSetColor(-1, $TextColor)
	$Filter_BTX_GUI = GUICtrlCreateInput($Filter_BTX, 353, 140, 300, 20)
	GUICtrlCreateLabel($Column_Names_OtherTransferRates, 353, 165, 300, 15)
	GUICtrlSetColor(-1, $TextColor)
	$Filter_OTX_GUI = GUICtrlCreateInput($Filter_OTX, 353, 180, 300, 20)
	GUICtrlSetColor(-1, $TextColor)
	GUICtrlCreateLabel($Column_Names_Line, 353, 205, 300, 15)
	GUICtrlSetColor(-1, $TextColor)
	$Filter_Line_GUI = GUICtrlCreateInput($Filter_Line, 353, 220, 300, 20)
	GUICtrlCreateLabel($Column_Names_Signal, 353, 245, 300, 15)
	GUICtrlSetColor(-1, $TextColor)
	$Filter_SIG_GUI = GUICtrlCreateInput($Filter_SIG, 353, 260, 300, 20)
	GUICtrlSetColor(-1, $TextColor)
	GUICtrlCreateLabel($Column_Names_HighSignal, 353, 285, 300, 15)
	GUICtrlSetColor(-1, $TextColor)
	$Filter_HighSig_GUI = GUICtrlCreateInput($Filter_HighSig, 353, 300, 300, 20)
	GUICtrlSetColor(-1, $TextColor)
	GUICtrlCreateLabel($Column_Names_RSSI, 353, 325, 300, 15)
	GUICtrlSetColor(-1, $TextColor)
	$Filter_RSSI_GUI = GUICtrlCreateInput($Filter_RSSI, 353, 340, 300, 20)
	GUICtrlSetColor(-1, $TextColor)
	GUICtrlCreateLabel($Column_Names_HighRSSI, 353, 365, 300, 15)
	GUICtrlSetColor(-1, $TextColor)
	$Filter_HighRSSI_GUI = GUICtrlCreateInput($Filter_HighRSSI, 353, 380, 300, 20)
	GUICtrlSetColor(-1, $TextColor)
	$GUI_AddEditFilt_Can = GUICtrlCreateButton($Text_Cancel, 600, 470, 75, 25, 0)
	$GUI_AddEditFilt_Ok = GUICtrlCreateButton($Text_Ok, 525, 470, 75, 25, 0)

	GUICtrlSetOnEvent($GUI_AddEditFilt_Can, "_AddEditFilter_Close")
	GUICtrlSetOnEvent($GUI_AddEditFilt_Ok, "_AddEditFilter_Ok")
	GUISetState(@SW_SHOW)
EndFunc   ;==>_AddEditFilter

Func _AddEditFilter_Close()
	GUIDelete($AddEditFilt_GUI)
	_ModifyFilters()
EndFunc   ;==>_AddEditFilter_Close

Func _AddEditFilter_Ok()
	$Filter_Name = GUICtrlRead($Filter_Name_GUI)
	If $Filter_Name = "" Then
		MsgBox(0, $Text_Error, $Text_FilterNameRequired)
	Else
		$Filter_Desc = GUICtrlRead($Filter_Desc_GUI)
		$Filter_SSID = GUICtrlRead($Filter_SSID_GUI)
		$Filter_BSSID = GUICtrlRead($Filter_BSSID_GUI)
		$Filter_CHAN = GUICtrlRead($Filter_CHAN_GUI)
		$Filter_AUTH = GUICtrlRead($Filter_AUTH_GUI)
		$Filter_ENCR = GUICtrlRead($Filter_ENCR_GUI)
		$Filter_RADTYPE = GUICtrlRead($Filter_RADTYPE_GUI)
		$Filter_NETTYPE = GUICtrlRead($Filter_NETTYPE_GUI)
		$Filter_SIG = GUICtrlRead($Filter_SIG_GUI)
		$Filter_HighSig = GUICtrlRead($Filter_HighSig_GUI)
		$Filter_RSSI = GUICtrlRead($Filter_RSSI_GUI)
		$Filter_HighRSSI = GUICtrlRead($Filter_HighRSSI_GUI)
		$Filter_BTX = GUICtrlRead($Filter_BTX_GUI)
		$Filter_OTX = GUICtrlRead($Filter_OTX_GUI)
		$Filter_Line = GUICtrlRead($Filter_Line_GUI)
		$Filter_Active = StringReplace(StringReplace(GUICtrlRead($Filter_Active_GUI), $Text_Active, '1'), $Text_Dead, '0')

		;If $Filter_SSID = '' Then $Filter_SSID = '*'
		If $Filter_BSSID = '' Then $Filter_BSSID = '*'
		If $Filter_CHAN = '' Then $Filter_CHAN = '*'
		If $Filter_AUTH = '' Then $Filter_AUTH = '*'
		If $Filter_ENCR = '' Then $Filter_ENCR = '*'
		If $Filter_RADTYPE = '' Then $Filter_RADTYPE = '*'
		If $Filter_NETTYPE = '' Then $Filter_NETTYPE = '*'
		If $Filter_SIG = '' Then $Filter_SIG = '*'
		If $Filter_HighSig = '' Then $Filter_HighSig = '*'
		If $Filter_RSSI = '' Then $Filter_RSSI = '*'
		If $Filter_HighRSSI = '' Then $Filter_HighRSSI = '*'
		If $Filter_BTX = '' Then $Filter_BTX = '*'
		If $Filter_OTX = '' Then $Filter_OTX = '*'
		If $Filter_Line = '' Then $Filter_Line = '*'
		If $Filter_Active = '' Then $Filter_Active = '*'

		If $Filter_ID_GUI = '-1' Then
			$FiltID += 1
			_AddRecord($FiltDB, "Filters", $FiltDB_OBJ, $FiltID & '|' & $Filter_Name & '|' & $Filter_Desc & '|' & $Filter_SSID & '|' & $Filter_BSSID & '|' & $Filter_CHAN & '|' & $Filter_AUTH & '|' & $Filter_ENCR & '|' & $Filter_RADTYPE & '|' & $Filter_NETTYPE & '|' & $Filter_SIG & '|' & $Filter_HighSig & '|' & $Filter_RSSI & '|' & $Filter_HighRSSI & '|' & $Filter_BTX & '|' & $Filter_OTX & '|' & $Filter_Line & '|' & $Filter_Active)
			$menuid = GUICtrlCreateMenuItem($Filter_Name, $FilterMenu)
			GUICtrlSetOnEvent($menuid, '_FilterChanged')
			_ArrayAdd($FilterMenuID_Array, $menuid)
			_ArrayAdd($FilterID_Array, $FiltID)
			$FilterMenuID_Array[0] = UBound($FilterMenuID_Array) - 1
			$FilterID_Array[0] = UBound($FilterID_Array) - 1
		Else
			$Filter_ID = $Filter_ID_GUI
			$query = "UPDATE Filters SET FiltName='" & $Filter_Name & "', FiltDesc='" & $Filter_Desc & "', SSID='" & $Filter_SSID & "', BSSID='" & $Filter_BSSID & "', CHAN='" & $Filter_CHAN & "', AUTH='" & $Filter_AUTH & "', ENCR='" & $Filter_ENCR & "', RADTYPE='" & $Filter_RADTYPE & "', NETTYPE='" & $Filter_NETTYPE & "', Signal='" & $Filter_SIG & "', HighSig='" & $Filter_HighSig & "', RSSI='" & $Filter_RSSI & "', HighRSSI='" & $Filter_HighRSSI & "', BTX='" & $Filter_BTX & "', OTX='" & $Filter_OTX & "', ApID='" & $Filter_Line & "', Active='" & $Filter_Active & "' WHERE FiltID='" & $Filter_ID & "'"
			_ExecuteMDB($FiltDB, $FiltDB_OBJ, $query)
			For $fi = 1 To $FilterID_Array[0]
				If $FilterID_Array[$fi] = $Filter_ID Then
					$Filter_MenuID = $FilterMenuID_Array[$fi]
					GUICtrlSetData($Filter_MenuID, $Filter_Name)
					ExitLoop
				EndIf
			Next

		EndIf
		GUIDelete($AddEditFilt_GUI)
		_CreateFilterQuerys()
		_ModifyFilters()
	EndIf
EndFunc   ;==>_AddEditFilter_Ok

Func _FilterChanged()
	$menuid = @GUI_CtrlId
	For $fs = 1 To $FilterMenuID_Array[0]
		If $FilterMenuID_Array[$fs] = $menuid Then
			$Filter_ID = $FilterID_Array[$fs]
			If $Filter_ID <> $DefFiltID Then
				;Check to see if another filter is selected, deselect it if it exists
				If $DefFiltID <> '-1' Then
					For $fm = 1 To $FilterID_Array[0]
						If $FilterID_Array[$fm] = $DefFiltID Then
							$Filter_MenuID = $FilterMenuID_Array[$fm]
							GUICtrlSetState($Filter_MenuID, $GUI_UNCHECKED)
							ExitLoop
						EndIf
					Next
				EndIf
				For $fm = 1 To $FilterMenuID_Array[0]
					If $FilterMenuID_Array[$fm] = $menuid Then
						$DefFiltID = $FilterID_Array[$fm]
						GUICtrlSetState($menuid, $GUI_CHECKED)
						ExitLoop
					EndIf
				Next
			Else
				For $fm = 1 To $FilterMenuID_Array[0]
					If $FilterMenuID_Array[$fm] = $menuid Then
						$Filter_ID = $FilterID_Array[$fm]
						$DefFiltID = '-1'
						GUICtrlSetState($menuid, $GUI_UNCHECKED)
					EndIf
				Next
			EndIf
			ExitLoop
		EndIf
	Next
	_CreateFilterQuerys()
	$TempBatchListviewInsert = 1
	$TempBatchListviewDelete = 1
EndFunc   ;==>_FilterChanged

Func _CreateFilterQuerys()
	$AddQuery = "SELECT ApID, SSID, BSSID, NETTYPE, RADTYPE, CHAN, AUTH, ENCR, SecType, BTX, OTX, MANU, LABEL, HighGpsHistID, FirstHistID, LastHistID, LastGpsID, Active, HighSignal, HighRSSI, ListRow FROM AP"
	$RemoveQuery = "SELECT ApID, SSID, BSSID, NETTYPE, RADTYPE, CHAN, AUTH, ENCR, SecType, BTX, OTX, MANU, LABEL, HighGpsHistID, FirstHistID, LastHistID, LastGpsID, Active FROM AP"
	$CountQuery = "Select COUNT(ApID) FROM AP"

	If $DefFiltID <> '-1' Then
		$query = "SELECT SSID, BSSID, CHAN, AUTH, ENCR, RADTYPE, NETTYPE, Signal, HighSig, RSSI, HighRSSI, BTX, OTX, ApID, Active FROM Filters WHERE FiltID='" & $DefFiltID & "'"
		$FiltMatchArray = _RecordSearch($FiltDB, $query, $FiltDB_OBJ)
		$Filter_SSID = $FiltMatchArray[1][1]
		$Filter_BSSID = $FiltMatchArray[1][2]
		$Filter_CHAN = $FiltMatchArray[1][3]
		$Filter_AUTH = $FiltMatchArray[1][4]
		$Filter_ENCR = $FiltMatchArray[1][5]
		$Filter_RADTYPE = $FiltMatchArray[1][6]
		$Filter_NETTYPE = $FiltMatchArray[1][7]
		$Filter_SIG = $FiltMatchArray[1][8]
		$Filter_HighSig = $FiltMatchArray[1][9]
		$Filter_RSSI = $FiltMatchArray[1][10]
		$Filter_HighRSSI = $FiltMatchArray[1][11]
		$Filter_BTX = $FiltMatchArray[1][12]
		$Filter_OTX = $FiltMatchArray[1][13]
		$Filter_Line = $FiltMatchArray[1][14]
		$Filter_Active = $FiltMatchArray[1][15]

		$aquery = ''
		$aquery = _AddFilerString($aquery, 'SSID', $Filter_SSID)
		$aquery = _AddFilerString($aquery, 'BSSID', $Filter_BSSID)
		$aquery = _AddFilerString($aquery, 'CHAN', $Filter_CHAN)
		$aquery = _AddFilerString($aquery, 'AUTH', $Filter_AUTH)
		$aquery = _AddFilerString($aquery, 'ENCR', $Filter_ENCR)
		$aquery = _AddFilerString($aquery, 'RADTYPE', $Filter_RADTYPE)
		$aquery = _AddFilerString($aquery, 'NETTYPE', $Filter_NETTYPE)
		$aquery = _AddFilerString($aquery, 'Signal', $Filter_SIG)
		$aquery = _AddFilerString($aquery, 'HighSignal', $Filter_HighSig)
		$aquery = _AddFilerString($aquery, 'RSSI', $Filter_RSSI)
		$aquery = _AddFilerString($aquery, 'HighRSSI', $Filter_HighRSSI)
		$aquery = _AddFilerString($aquery, 'BTX', $Filter_BTX)
		$aquery = _AddFilerString($aquery, 'OTX', $Filter_OTX)
		$aquery = _AddFilerString($aquery, 'ApID', $Filter_Line)
		$aquery = _AddFilerString($aquery, 'Active', $Filter_Active)
		If $aquery <> '' Then $AddQuery &= ' WHERE (' & $aquery & ')'
		If $aquery <> '' Then $CountQuery &= ' WHERE (' & $aquery & ')'

		ConsoleWrite($AddQuery & @CRLF)
		ConsoleWrite($CountQuery & @CRLF)

		$rquery = ''
		$rquery = _RemoveFilterString($rquery, 'SSID', $Filter_SSID)
		$rquery = _RemoveFilterString($rquery, 'BSSID', $Filter_BSSID)
		$rquery = _RemoveFilterString($rquery, 'CHAN', $Filter_CHAN)
		$rquery = _RemoveFilterString($rquery, 'AUTH', $Filter_AUTH)
		$rquery = _RemoveFilterString($rquery, 'ENCR', $Filter_ENCR)
		$rquery = _RemoveFilterString($rquery, 'RADTYPE', $Filter_RADTYPE)
		$rquery = _RemoveFilterString($rquery, 'NETTYPE', $Filter_NETTYPE)
		$rquery = _RemoveFilterString($rquery, 'Signal', $Filter_SIG)
		$rquery = _RemoveFilterString($rquery, 'HighSignal', $Filter_HighSig)
		$rquery = _RemoveFilterString($rquery, 'RSSI', $Filter_RSSI)
		$rquery = _RemoveFilterString($rquery, 'HighRSSI', $Filter_HighRSSI)
		$rquery = _RemoveFilterString($rquery, 'BTX', $Filter_BTX)
		$rquery = _RemoveFilterString($rquery, 'OTX', $Filter_OTX)
		$rquery = _RemoveFilterString($rquery, 'ApID', $Filter_Line)
		$rquery = _RemoveFilterString($rquery, 'Active', $Filter_Active)
		If $rquery <> '' Then $RemoveQuery &= ' WHERE (' & $rquery & ')'

		ConsoleWrite($RemoveQuery & @CRLF)
	EndIf
EndFunc   ;==>_CreateFilterQuerys

Func _AddFilerString($q_query, $q_field, $FilterValues)
	$FilterValues = StringReplace(StringReplace($FilterValues, '"', ''), "'", "")
	Local $ret
	Local $ret2
	If $FilterValues = '*' Then
		Return ($q_query)
	Else
		If $q_query <> '' Then $q_query &= ' AND '
		;$FilterValues = StringReplace($FilterValues, "|", ",")
		;Get values to seperate filter sysmbols from escaped filter symbols
		StringReplace($FilterValues, "%", "%")
		$filter_pcount = @extended ; Number of percent signs in filter
		StringReplace($FilterValues, "\%", "\%")
		$filter_epcount = @extended ; Number of escaped percent signs in filter
		StringReplace($FilterValues, "-", "-")
		$filter_dcount = @extended ; Number of dashes in filter
		StringReplace($FilterValues, "\-", "\-")
		$filter_edcount = @extended ; Number of escaped dashes in filter
		StringReplace($FilterValues, ",", ",")
		$filter_ccount = @extended ; Number of commas in filter
		StringReplace($FilterValues, "\,", "\,")
		$filter_eccount = @extended ; Number of escaped commas signs in filter
		$filter_enecount = @extended ; Number of escaped not equals in filter
		$FilterValues = StringReplace(StringReplace(StringReplace($FilterValues, "\%", "%"), "\-", "-"), "\,", ",")

		If $q_field = "Signal" Or $q_field = "HighSignal" Or $q_field = "RSSI" Or $q_field = "HighRSSI" Or $q_field = "CHAN" Then ;These are integer fields and need to be treated differently (no quotes or the query fails)
			If (UBound(StringSplit($FilterValues, "-")) - 2) = 3 Then ;If there are 3 dashes, treat this as a range of RSSI values
				$RRS = StringSplit($FilterValues, "-")
				If $RRS[0] = 4 Then
					$Rnum1 = $RRS[1] & '-' & $RRS[2]
					$Rnum2 = $RRS[3] & '-' & $RRS[4]
					ConsoleWrite('Range: ' & $Rnum1 & ' - ' & $Rnum2 & @CRLF)
					If StringInStr($FilterValues, '<>') Then
						$q_query &= "(" & $q_field & " NOT BETWEEN " & StringReplace($Rnum1, '<>', '') & " AND " & StringReplace($Rnum2, '<>', '') & ")"
					Else
						$q_query &= "(" & $q_field & " BETWEEN " & $Rnum1 & " AND " & $Rnum2 & ")"
					EndIf
				EndIf
			ElseIf StringInStr($FilterValues, ",") Then
				$q_splitstring = StringSplit($FilterValues, ",")
				For $q = 1 To $q_splitstring[0]
					If StringInStr($q_splitstring[$q], '<>') Then
						If $ret <> '' Then $ret &= ','
						$ret &= StringReplace($q_splitstring[$q], '<>', '')
					Else
						If $ret2 <> '' Then $ret2 &= ','
						$ret2 &= $q_splitstring[$q]
					EndIf
				Next
				If $ret <> '' Or $ret2 <> '' Then $q_query &= "("
				If $ret <> '' Then $q_query &= $q_field & " NOT IN (" & $ret & ")"
				If $ret <> '' And $ret2 <> '' Then $q_query &= " And "
				If $ret2 <> '' Then $q_query &= $q_field & " IN (" & $ret2 & ")"
				If $ret <> '' Or $ret2 <> '' Then $q_query &= ")"
			ElseIf StringInStr($FilterValues, "-") Then
				$q_splitstring = StringSplit($FilterValues, "-")
				If StringInStr($FilterValues, '<>') Then
					$q_query &= "(" & $q_field & " NOT BETWEEN " & StringReplace($q_splitstring[1], '<>', '') & " AND " & StringReplace($q_splitstring[2], '<>', '') & ")"
				Else
					$q_query &= "(" & $q_field & " BETWEEN " & $q_splitstring[1] & " AND " & $q_splitstring[2] & ")"
				EndIf
			Else
				If StringInStr($FilterValues, '<>') Then
					$q_query &= "(" & $q_field & " <> " & StringReplace($FilterValues, '<>', '') & ")"
				Else
					If StringInStr($FilterValues, '%') And ($filter_pcount > $filter_epcount) Then ;If has "%" and there are more "%"s then "\%"s, treat as a like statement
						$q_query &= "(" & $q_field & " like '" & $FilterValues & "')"
					Else
						$q_query &= "(" & $q_field & " = '" & $FilterValues & "')"
					EndIf
				EndIf
			EndIf
			Return ($q_query)
		ElseIf StringInStr($FilterValues, ",") And ($filter_ccount > $filter_eccount) Then
			$q_splitstring = StringSplit($FilterValues, ",")
			For $q = 1 To $q_splitstring[0]
				If StringInStr($q_splitstring[$q], '<>') Then
					If $ret <> '' Then $ret &= ','
					$ret &= "'" & StringReplace($q_splitstring[$q], '<>', '') & "'"
				Else
					If $ret2 <> '' Then $ret2 &= ','
					$ret2 &= "'" & $q_splitstring[$q] & "'"
				EndIf
			Next
			If $ret <> '' Or $ret2 <> '' Then $q_query &= "("
			If $ret <> '' Then $q_query &= $q_field & " NOT IN (" & $ret & ")"
			If $ret <> '' And $ret2 <> '' Then $q_query &= " And "
			If $ret2 <> '' Then $q_query &= $q_field & " IN (" & $ret2 & ")"
			If $ret <> '' Or $ret2 <> '' Then $q_query &= ")"
			Return ($q_query)
		ElseIf StringInStr($FilterValues, "-") And ($filter_dcount > $filter_edcount) Then
			$filtopnum = (($filter_dcount - 1) / 2) + 1 ;Find center dash, which should be the filter operator
			$splitdashpos = StringInStr($FilterValues, "-", 1, $filtopnum) ;Find center dash location
			$ri1 = StringTrimRight($FilterValues, (StringLen($FilterValues) - $splitdashpos) + 1) ;Get first range value
			$ri2 = StringTrimLeft($FilterValues, $splitdashpos) ;Get second range value
			If StringInStr($FilterValues, '<>') Then
				$q_query &= "(" & $q_field & " NOT BETWEEN '" & StringReplace($ri1, '<>', '') & "' AND '" & StringReplace($ri2, '<>', '') & "')"
			Else
				$q_query &= "(" & $q_field & " BETWEEN '" & $ri1 & "' AND '" & $ri2 & "')"
			EndIf
			Return ($q_query)
		Else
			If StringInStr($FilterValues, '<>') Then
				$q_query &= "(" & $q_field & " <> '" & StringReplace($FilterValues, '<>', '') & "')"
			Else
				If StringInStr($FilterValues, '%') And ($filter_pcount > $filter_epcount) Then ;If has "%" and there are more "%"s then "\%"s, treat as a like statement
					$q_query &= "(" & $q_field & " like '" & $FilterValues & "')"
				Else
					$q_query &= "(" & $q_field & " = '" & $FilterValues & "')"
				EndIf
			EndIf
			Return ($q_query)
		EndIf
	EndIf
EndFunc   ;==>_AddFilerString

Func _RemoveFilterString($q_query, $q_field, $FilterValues)
	$FilterValues = StringReplace(StringReplace($FilterValues, '"', ''), "'", "")
	Local $ret
	Local $ret2
	If $FilterValues = '*' Then
		Return ($q_query)
	Else
		If $q_query <> '' Then $q_query &= ' OR '
		;$FilterValues = StringReplace($FilterValues, "|", ",")
		;Get values to seperate filter sysmbols from escaped filter symbols
		StringReplace($FilterValues, "%", "%")
		$filter_pcount = @extended ; Number of percent signs in filter
		StringReplace($FilterValues, "\%", "\%")
		$filter_epcount = @extended ; Number of escaped percent signs in filter
		StringReplace($FilterValues, "-", "-")
		$filter_dcount = @extended ; Number of dashes in filter
		StringReplace($FilterValues, "\-", "\-")
		$filter_edcount = @extended ; Number of escaped dashes in filter
		StringReplace($FilterValues, ",", ",")
		$filter_ccount = @extended ; Number of commas in filter
		StringReplace($FilterValues, "\,", "\,")
		$filter_eccount = @extended ; Number of escaped commas signs in filter
		$FilterValues = StringReplace(StringReplace(StringReplace($FilterValues, "\%", "%"), "\-", "-"), "\,", ",")
		;Create query
		If $q_field = "Signal" Or $q_field = "HighSignal" Or $q_field = "RSSI" Or $q_field = "HighRSSI" Or $q_field = "CHAN" Then ;These are integer fields and need to be treated differently (no quotes or the query fails)
			If (UBound(StringSplit($FilterValues, "-")) - 2) = 3 Then ;If there are 3 dashes, treat this as a range of RSSI values
				$RRS = StringSplit($FilterValues, "-")
				If $RRS[0] = 4 Then
					$Rnum1 = $RRS[1] & '-' & $RRS[2]
					$Rnum2 = $RRS[3] & '-' & $RRS[4]
					ConsoleWrite('Range: ' & $Rnum1 & ' - ' & $Rnum2 & @CRLF)
					If StringInStr($FilterValues, '<>') Then
						$q_query &= "(" & $q_field & " BETWEEN " & StringReplace($Rnum1, '<>', '') & " AND " & $Rnum2 & ")"
					Else
						$q_query &= "(" & $q_field & " NOT BETWEEN " & $Rnum1 & " AND " & $Rnum2 & ")"
					EndIf
				EndIf
			ElseIf StringInStr($FilterValues, ",") Then
				$q_splitstring = StringSplit($FilterValues, ",")
				For $q = 1 To $q_splitstring[0]
					If StringInStr($q_splitstring[$q], '<>') Then
						If $ret <> '' Then $ret &= ','
						$ret &= StringReplace($q_splitstring[$q], '<>', '')
					Else
						If $ret2 <> '' Then $ret2 &= ','
						$ret2 &= $q_splitstring[$q]
					EndIf
				Next
				If $ret <> '' Or $ret2 <> '' Then $q_query &= "("
				If $ret <> '' Then $q_query &= $q_field & " IN (" & $ret & ")"
				If $ret <> '' And $ret2 <> '' Then $q_query &= " Or "
				If $ret2 <> '' Then $q_query &= $q_field & " NOT IN (" & $ret2 & ")"
				If $ret <> '' Or $ret2 <> '' Then $q_query &= ")"
			ElseIf StringInStr($FilterValues, "-") Then
				$q_splitstring = StringSplit($FilterValues, "-")
				If StringInStr($FilterValues, '<>') Then
					$q_query &= "(" & $q_field & " BETWEEN " & StringReplace($q_splitstring[1], '<>', '') & " AND " & StringReplace($q_splitstring[2], '<>', '') & ")"
				Else
					$q_query &= "(" & $q_field & " NOT BETWEEN " & $q_splitstring[1] & " AND " & $q_splitstring[2] & ")"
				EndIf
			Else
				If StringInStr($FilterValues, '<>') Then
					$q_query &= "(" & $q_field & " = " & StringReplace($FilterValues, '<>', '') & ")"
				Else
					If StringInStr($FilterValues, '%') And ($filter_pcount > $filter_epcount) Then ;If has "%" and there are more "%"s then "\%"s, treat as a like statement
						$q_query &= "(" & $q_field & " not like '" & $FilterValues & "')"
					Else
						$q_query &= "(" & $q_field & " <> '" & $FilterValues & "')"
					EndIf
				EndIf
			EndIf
			Return ($q_query)
		ElseIf StringInStr($FilterValues, ",") And ($filter_ccount > $filter_eccount) Then
			$q_splitstring = StringSplit($FilterValues, ",")
			For $q = 1 To $q_splitstring[0]
				If StringInStr($q_splitstring[$q], '<>') Then
					If $ret <> '' Then $ret &= ','
					$ret &= "'" & StringReplace($q_splitstring[$q], '<>', '') & "'"
				Else
					If $ret2 <> '' Then $ret2 &= ','
					$ret2 &= "'" & $q_splitstring[$q] & "'"
				EndIf
			Next
			If $ret <> '' Or $ret2 <> '' Then $q_query &= "("
			If $ret <> '' Then $q_query &= $q_field & " IN (" & $ret & ")"
			If $ret <> '' And $ret2 <> '' Then $q_query &= " Or "
			If $ret2 <> '' Then $q_query &= $q_field & " NOT IN (" & $ret2 & ")"
			If $ret <> '' Or $ret2 <> '' Then $q_query &= ")"
			Return ($q_query)
		ElseIf StringInStr($FilterValues, "-") And ($filter_dcount > $filter_edcount) Then
			$filtopnum = (($filter_dcount - 1) / 2) + 1 ;Find center dash, which should be the filter operator
			$splitdashpos = StringInStr($FilterValues, "-", 1, $filtopnum) ;Find center dash location
			$ri1 = StringTrimRight($FilterValues, (StringLen($FilterValues) - $splitdashpos) + 1) ;Get first range value
			$ri2 = StringTrimLeft($FilterValues, $splitdashpos) ;Get second range value
			If StringInStr($FilterValues, '<>') Then
				$q_query &= "(" & $q_field & " BETWEEN '" & StringReplace($ri1, '<>', '') & "' AND '" & StringReplace($ri2, '<>', '') & "')"
			Else
				$q_query &= "(" & $q_field & " NOT BETWEEN '" & $ri1 & "' AND '" & $ri2 & "')"
			EndIf
			Return ($q_query)
		Else
			If StringInStr($FilterValues, '<>') Then
				$q_query &= "(" & $q_field & " = '" & StringReplace($FilterValues, '<>', '') & "')"
			Else
				If StringInStr($FilterValues, '%') And ($filter_pcount > $filter_epcount) Then ;If has "%" and there are more "%"s then "\%"s, treat as a like statement
					$q_query &= "(" & $q_field & " not like '" & $FilterValues & "')"
				Else
					$q_query &= "(" & $q_field & " <> '" & $FilterValues & "')"
				EndIf
			EndIf
			Return ($q_query)
		EndIf
	EndIf
EndFunc   ;==>_RemoveFilterString

;-------------------------------------------------------------------------------------------------------------------------------
;                                                       WIRELESS INTERFACE FUNCTIONS
;-------------------------------------------------------------------------------------------------------------------------------

Func _AddInterfaces()
	Dim $NetworkAdapters[1]
	Local $found_adapter = 0
	Local $menuid = 0
	If $UseNativeWifi = 1 Then
		$wlaninterfaces = _Wlan_EnumInterfaces()
		$numofint = UBound($wlaninterfaces) - 1
		For $antm = 0 To $numofint
			$adapterid = $wlaninterfaces[$antm][0]
			$adapterdesc = $wlaninterfaces[$antm][1]
			$adaptername = RegRead('HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Network\{4D36E972-E325-11CE-BFC1-08002BE10318}\' & $adapterid & '\Connection', 'Name')
			$menuid = GUICtrlCreateMenuItem($adaptername & ' (' & $adapterdesc & ')', $Interfaces)
			_ArrayAdd($NetworkAdapters, $menuid)
			GUICtrlSetOnEvent($menuid, '_InterfaceChanged')
			If $DefaultApapter = $adaptername Then
				$found_adapter = 1
				$DefaultApapterID = $adapterid
				_Wlan_SelectInterface($DefaultApapterID)
				GUICtrlSetState($menuid, $GUI_CHECKED)
			EndIf
		Next
		If $menuid <> 0 And $found_adapter = 0 Then
			$DefaultApapter = $adaptername
			$DefaultApapterID = $adapterid
			_Wlan_SelectInterface($DefaultApapterID)
			GUICtrlSetState($menuid, $GUI_CHECKED)
		EndIf
		If $menuid = 0 Then $noadaptersid = GUICtrlCreateMenuItem($Text_NoAdaptersFound, $Interfaces)
		$NetworkAdapters[0] = UBound($NetworkAdapters) - 1
	Else
		;Get network interfaces and add the to the interface menu
		Local $DefaultApapterDesc
		$objWMIService = ObjGet("winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2")
		$colNIC = $objWMIService.ExecQuery("Select * from Win32_NetworkAdapter WHERE AdapterTypeID = 0 And NetConnectionID <> NULL")
		For $object In $colNIC
			$adaptername = $object.NetConnectionID
			$adapterdesc = $object.Description
			$menuid = GUICtrlCreateMenuItem($adaptername & ' (' & $adapterdesc & ')', $Interfaces)
			_ArrayAdd($NetworkAdapters, $menuid)
			GUICtrlSetOnEvent($menuid, '_InterfaceChanged')
			If $DefaultApapter = $adaptername Then
				$DefaultApapterDesc = $adapterdesc
				$found_adapter = 1
				GUICtrlSetState($menuid, $GUI_CHECKED)
			EndIf
		Next
		If $menuid <> 0 And $found_adapter = 0 Then
			$DefaultApapter = $adaptername
			$DefaultApapterDesc = $adapterdesc
			GUICtrlSetState($menuid, $GUI_CHECKED)
		EndIf
		If $menuid = 0 Then $noadaptersid = GUICtrlCreateMenuItem($Text_NoAdaptersFound, $Interfaces)
		$NetworkAdapters[0] = UBound($NetworkAdapters) - 1
		;Find adapterid
		$wlaninterfaces = _Wlan_EnumInterfaces()
		$numofint = UBound($wlaninterfaces) - 1
		For $antm = 0 To $numofint
			If $DefaultApapterDesc = $wlaninterfaces[$antm][1] Then $DefaultApapterID = $wlaninterfaces[$antm][0]
			_Wlan_SelectInterface($DefaultApapterID)
		Next
	EndIf
EndFunc   ;==>_AddInterfaces

Func _InterfaceChanged()
	$menuid = @GUI_CtrlId
	For $uc = 1 To $NetworkAdapters[0]
		If $NetworkAdapters[$uc] = $menuid Then
			GUICtrlSetState($NetworkAdapters[$uc], $GUI_CHECKED)
		Else
			GUICtrlSetState($NetworkAdapters[$uc], $GUI_UNCHECKED)
		EndIf
	Next
	$das = StringSplit(GUICtrlRead(@GUI_CtrlId, 1), ' (', 1)
	$DefaultApapter = $das[1]
	;If Using Native Wifi, Find DefaultAdapterId
	If $UseNativeWifi = 1 Then
		$wlaninterfaces = _Wlan_EnumInterfaces()
		$numofint = UBound($wlaninterfaces) - 1
		For $antm = 0 To $numofint
			$adapterid = $wlaninterfaces[$antm][0]
			$adapterdesc = $wlaninterfaces[$antm][1]
			$adaptername = RegRead('HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Network\{4D36E972-E325-11CE-BFC1-08002BE10318}\' & $adapterid & '\Connection', 'Name')
			If $DefaultApapter = $adaptername Then $DefaultApapterID = $adapterid
			_Wlan_SelectInterface($DefaultApapterID)
		Next
	Else
		Dim $DefaultApapterID = '', $DefaultApapterDesc = ''
		$objWMIService = ObjGet("winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2")
		$colNIC = $objWMIService.ExecQuery("Select * from Win32_NetworkAdapter WHERE AdapterTypeID = 0 And NetConnectionID <> NULL")
		For $object In $colNIC
			$adaptername = $object.NetConnectionID
			$adapterdesc = $object.Description
			If $DefaultApapter = $adaptername Then $DefaultApapterDesc = $adapterdesc
		Next
		;Find adapterid
		;$wlanhandle = _Wlan_OpenHandle()
		$wlaninterfaces = _Wlan_EnumInterfaces()
		$numofint = UBound($wlaninterfaces) - 1
		For $antm = 0 To $numofint
			If $DefaultApapterDesc = $wlaninterfaces[$antm][1] Then $DefaultApapterID = $wlaninterfaces[$antm][0]
			_Wlan_SelectInterface($DefaultApapterID)
		Next
	EndIf
EndFunc   ;==>_InterfaceChanged

Func _RefreshInterfaces()
	;Delete all old menu items
	For $ri = 1 To $NetworkAdapters[0]
		$menuid = $NetworkAdapters[$ri]
		GUICtrlDelete($menuid)
	Next
	GUICtrlDelete($noadaptersid)
	;Add updated interfaces
	_AddInterfaces()
EndFunc   ;==>_RefreshInterfaces

;-------------------------------------------------------------------------------------------------------------------------------
;                                                       CAMERA FUNCTIONS
;-------------------------------------------------------------------------------------------------------------------------------

Func _ImageDownloader()
	$query = "SELECT CamName, CamUrl FROM Cameras"
	$CamMatchArray = _RecordSearch($CamDB, $query, $CamDB_OBJ)
	$FoundCamMatch = UBound($CamMatchArray) - 1
	If $FoundCamMatch > 0 Then
		$dtfilebase = StringFormat("%04i", @YEAR) & '-' & StringFormat("%02i", @MON) & '-' & StringFormat("%02i", @MDAY) & ' ' & @HOUR & '-' & @MIN & '-' & @SEC
		For $c = 1 To $FoundCamMatch
			$camname = $CamMatchArray[$c][1]
			$camurl = $CamMatchArray[$c][2]
			$filename = $dtfilebase & '_' & 'gpsid-' & $GPS_ID & '_' & $camname & '.jpg'
			$tmpfile = $TmpDir & $filename
			$destfile = $VistumblerCamFolder & $filename
			;ConsoleWrite($camname & ' - ' & $camurl & ' - ' & $tmpfile & @CRLF)
			$get = InetGet($camurl, $tmpfile, 0)
			;ConsoleWrite($get & @CRLF)
			If $get <> 0 Then
				;ConsoleWrite($GPS_ID & @CRLF)
				$imgmd5 = _MD5ForFile($destfile)
				$query = "SELECT TOP 1 CamID FROM Cam WHERE ImgMD5='" & $imgmd5 & "'"
				;ConsoleWrite($query & @CRLF)
				$ImgMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
				$FoundImgMatch = UBound($ImgMatchArray) - 1
				If $FoundImgMatch = 0 Then ;If Img is not found, add it
					$CamID += 1
					_AddRecord($VistumblerDB, "Cam", $DB_OBJ, $CamID & '|' & $GPS_ID & '|' & $camname & '|' & $filename & '|' & $datestamp & '|' & $timestamp)
					FileMove($tmpfile, $destfile)
				EndIf
			EndIf
			If FileExists($tmpfile) Then FileDelete($tmpfile)
		Next
	EndIf
EndFunc   ;==>_ImageDownloader

Func _ExportCamFile()
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_ExportToCSV()') ;#Debug Display
	$file = "CamID,CamGroup,CamGpsID,CamName,CamFile,Date,Time,Latitude,Longitude,NumberOfSats,ExpHorDilPitch,Altitude,HeightOfGeoid,SpeedKmh,SpeedMPH,Track" & @CRLF
	$filename = FileSaveDialog('Save Camera File', $SaveDir, 'Vistumbler Camera File (*.VSCZ)', '', $ldatetimestamp & '.VSCZ')
	$query = "SELECT CamID, CamGroup, GpsID, CamName, CamFile, Date1, Time1 FROM CAM"
	$CamMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
	$FoundCamMatch = UBound($CamMatchArray) - 1
	If $FoundCamMatch > 0 Then
		$datafiletmp = $TmpDir & 'Data.csv'
		$exporttmp = $TmpDir & 'Export.zip'
		_Zip_Create($exporttmp, 1)
		For $exp = 1 To $FoundCamMatch
			GUICtrlSetData($msgdisplay, $Text_SavingLine & ' ' & $exp & ' / ' & $FoundCamMatch)
			;Ap Info
			$ExpCamID = $CamMatchArray[$exp][1]
			$ExpCamGroup = $CamMatchArray[$exp][2]
			$ExpGpsID = $CamMatchArray[$exp][3]
			$ExpCamName = $CamMatchArray[$exp][4]
			$ExpCamFile = $CamMatchArray[$exp][5]
			$ExpCamDate = $CamMatchArray[$exp][6]
			$ExpCamTime = $CamMatchArray[$exp][7]
			;GPS Information
			If $ExpGpsID <> 0 Then
				$query = "SELECT Latitude, Longitude, NumOfSats, HorDilPitch, Alt, Geo, SpeedInMPH, SpeedInKmH, TrackAngle, Date1, Time1 FROM GPS WHERE GpsID=" & $ExpGpsID
				;ConsoleWrite($query & @CRLF)
				$GpsMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
				$ExpLat = StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($GpsMatchArray[1][1]), 'S', '-'), 'N', ''), ' ', '')
				$ExpLon = StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($GpsMatchArray[1][2]), 'W', '-'), 'E', ''), ' ', '')
				$ExpSat = $GpsMatchArray[1][3]
				$ExpHorDilPitch = $GpsMatchArray[1][4]
				$ExpAlt = $GpsMatchArray[1][5]
				$ExpGeo = $GpsMatchArray[1][6]
				$ExpSpeedMPH = $GpsMatchArray[1][7]
				$ExpSpeedKmh = $GpsMatchArray[1][8]
				$ExpTrack = $GpsMatchArray[1][9]
			Else
				Dim $ExpLat = "0.0000000", $ExpLon = "0.0000000", $ExpSat = "00", $ExpHorDilPitch = "0", $ExpAlt = "0", $ExpGeo = "0", $ExpSpeedMPH = "0", $ExpSpeedKmh = "0", $ExpTrack = "0"
			EndIf
			;ConsoleWrite($ExpCamID & ',' & $ExpCamGroup & ',' & $ExpGpsID & ',' & $ExpCamName & ',' & $ExpCamFile & ',' & $ExpCamDate & ',' & $ExpCamTime & ',' & $ExpLat & ',' & $ExpLon & ',' & $ExpSat & ',' & $ExpHorDilPitch & ',' & $ExpAlt & ',' & $ExpGeo & ',' & $ExpSpeedKmh & ',' & $ExpSpeedMPH & ',' & $ExpTrack & @CRLF)
			$file &= $ExpCamID & ',' & $ExpCamGroup & ',' & $ExpGpsID & ',' & $ExpCamName & ',' & $ExpCamFile & ',' & $ExpCamDate & ',' & $ExpCamTime & ',' & $ExpLat & ',' & $ExpLon & ',' & $ExpSat & ',' & $ExpHorDilPitch & ',' & $ExpAlt & ',' & $ExpGeo & ',' & $ExpSpeedKmh & ',' & $ExpSpeedMPH & ',' & $ExpTrack & @CRLF
		Next
		;Add cam data to zip
		$filetmp = FileOpen($datafiletmp, 128 + 2);Open in UTF-8 write mode
		FileWrite($filetmp, $file)
		FileClose($filetmp)
		;ConsoleWrite($datafiletmp & @CRLF)
		;ConsoleWrite(_Zip_AddItem($exporttmp, $datafiletmp) & '-' & @error & @CRLF)
		;Add cam images folder to zip
		_Zip_AddItem($exporttmp, $VistumblerCamFolder)
		;Save tmp export
		FileMove($exporttmp, $filename)
		FileDelete($datafiletmp)
		FileDelete($exporttmp)
		Return (1)
	Else
		Return (0)
	EndIf
EndFunc   ;==>_ExportCamFile

Func _CamTrigger()
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_CamTrigger()') ;#Debug Display
	;ConsoleWrite($CamTriggerScript & @CRLF)
	If FileExists($CamTriggerScript) Then
		Run($CamTriggerScript)
	EndIf
EndFunc   ;==>_CamTrigger

Func _GUI_ImportImageFiles()
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_GUI_ImportImageFiles()') ;#Debug Display
	$GUI_ImportImageFiles = GUICreate("Import Images from folder", 401, 224, 192, 114)
	GUICtrlCreateGroup("Import Images from folder", 8, 8, 385, 209)
	GUICtrlCreateLabel("Image Group Name", 23, 38, 344, 15)
	$GUI_ImgGroupName = GUICtrlCreateInput("", 23, 53, 353, 21)
	GUICtrlCreateLabel("Image Directory", 23, 78, 344, 15)
	$GUI_ImpImgDir = GUICtrlCreateInput("", 23, 93, 265, 21)
	$GUI_ImpBrowse = GUICtrlCreateButton("Browse", 296, 93, 81, 20)
	GUICtrlCreateLabel("Skew Image time (in Seconds)", 23, 118, 344, 15)
	$GUI_ImpImgSkewTime = GUICtrlCreateInput("0", 23, 133, 353, 21)

	$Button_ImgImp = GUICtrlCreateButton("Import", 88, 168, 97, 33)
	$Button_ImgCan = GUICtrlCreateButton("Cancel", 194, 168, 97, 33)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	GUICtrlSetOnEvent($Button_ImgImp, '_ImportImageFiles')
	GUICtrlSetOnEvent($Button_ImgCan, '_GUI_ImportImageFiles_Close')
	GUISetState(@SW_SHOW)
EndFunc   ;==>_GUI_ImportImageFiles

Func _ImportImageFiles()
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_ImportImageFiles()') ;#Debug Display
	$ImgGroupName = GUICtrlRead($GUI_ImgGroupName)
	$ImgDir = GUICtrlRead($GUI_ImpImgDir)
	$ImgSkewTime = GUICtrlRead($GUI_ImpImgSkewTime)
	If FileExists($ImgDir) Then
		If StringTrimLeft($ImgDir, StringLen($ImgDir) - 1) <> "\" Then $ImgDir = $ImgDir & "\" ;If directory does not have training \ then add it
		$ImgArray = _FileListToArray($ImgDir)
		If Not @error Then
			$query = "Select COUNT(CamID) FROM Cam WHERE CamName = '" & $ImgGroupName & "'"
			$CamCountArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
			$CamCount = $CamCountArray[1][1]
			;ConsoleWrite($CamCount & @CRLF)
			For $ii = 1 To $ImgArray[0]
				$imgpath = $ImgDir & $ImgArray[$ii]
				$imgmd5 = _MD5ForFile($imgpath)
				;Check if image already exists
				$query = "SELECT TOP 1 CamID FROM Cam WHERE ImgMD5='" & $imgmd5 & "'"
				;ConsoleWrite($query & @CRLF)
				$ImgMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
				$FoundImgMatch = UBound($ImgMatchArray) - 1
				If $FoundImgMatch = 0 Then ;If Img is not found, add it
					$imgtimearr = FileGetTime($imgpath, 0)
					;ConsoleWrite($imgpath & " " & FileGetTime($imgpath, 1, 1) & @CRLF)
					If IsArray($imgtimearr) Then ;Use time to match image up with gps point
						;Convert Time from local time to UTC and into the format vistumbler uses
						;ConsoleWrite($imgtimearr[1] & '-' & $imgtimearr[2] & '-' & $imgtimearr[0] & ' ' & $imgtimearr[3] & ':' & $imgtimearr[4] & ':' & $imgtimearr[5] & @CRLF)
						$tSystem = _Date_Time_EncodeSystemTime($imgtimearr[1], $imgtimearr[2], $imgtimearr[0], $imgtimearr[3], $imgtimearr[4], $imgtimearr[5])
						$rTime = _Date_Time_TzSpecificLocalTimeToSystemTime(DllStructGetPtr($tSystem))
						$dts1 = StringSplit(_Date_Time_SystemTimeToDateTimeStr($rTime), ' ')
						$dts2 = StringSplit($dts1[1], '/')
						$mon = $dts2[1]
						$day = $dts2[2]
						$year = $dts2[3]
						$ImgDateUTC = $year & '-' & $mon & '-' & $day ;Image Date in UTC year-month-day format
						$ImgTimeUTC = $dts1[2];Image time in UTC Hour:minute:second
						;ConsoleWrite($ImgDateUTC & ' ' & $ImgTimeUTC & @CRLF)
						;Find matching GPS point
						$query = "SELECT TOP 1 GPSID FROM GPS WHERE Date1 = '" & $ImgDateUTC & "' And Time1 like '" & $ImgTimeUTC & "%'"
						;ConsoleWrite($query & @CRLF)
						$GpsMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
						$FoundGpsMatch = UBound($GpsMatchArray) - 1
						If $FoundGpsMatch <> 0 Then ;If a gps id match was found, import the image
							$ImgGpsId = $GpsMatchArray[1][1]
							$dtfilebase = $ImgDateUTC & ' ' & StringReplace($ImgTimeUTC, ":", "-")
							$filename = $dtfilebase & '_' & 'gpsid-' & $ImgGpsId & '_' & $ImgGroupName & '.jpg'
							$destfile = $VistumblerCamFolder & $filename
							If FileCopy($imgpath, $destfile, 1) = 1 Then
								$CamID += 1
								$CamCount += 1
								_AddRecord($VistumblerDB, "Cam", $DB_OBJ, $CamID & '|' & $CamCount & '|' & $ImgGpsId & '|' & $ImgGroupName & '|' & $filename & '|' & $imgmd5 & '|' & $ImgDateUTC & '|' & $ImgTimeUTC)
							EndIf
						Else ; just echo it out for now
							;ConsoleWrite("No gps match found for image " & $imgpath & @CRLF)
						EndIf
					EndIf
				EndIf
			Next
		EndIf
	EndIf
EndFunc   ;==>_ImportImageFiles

Func _GUI_ImportImageFiles_Close()
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_GUI_ImportImageFiles_Close()') ;#Debug Display
	GUIDelete($GUI_ImportImageFiles)
EndFunc   ;==>_GUI_ImportImageFiles_Close

Func _RemoveNonMatchingImages()
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_RemoveNonMatchingImages()') ;#Debug Display
	$query = "SELECT CamName FROM Cam"
	;ConsoleWrite($query & @CRLF)
	$CamNameArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
	$CamNameMatch = UBound($CamNameArray) - 1
	If $CamNameMatch = 0 Then ;If Img is not found, add it
	EndIf
EndFunc   ;==>_RemoveNonMatchingImages

;-------------------------------------------------------------------------------------------------------------------------------
;                                                       MATH FUNCTIONS
;-------------------------------------------------------------------------------------------------------------------------------

Func Log10($x)
	Return Log($x) / Log(10) ;10 is the base
EndFunc   ;==>Log10

Func _MetersToFeet($meters)
	$feet = $meters / 3.28
	Return ($feet)
EndFunc   ;==>_MetersToFeet

Func _deg2rad($Degree) ;convert degrees to radians
	Local $PI = 3.14159265358979
	Return ($Degree * ($PI / 180))
EndFunc   ;==>_deg2rad

Func _rad2deg($radian) ;convert radians to degrees
	Local $PI = 3.14159265358979
	Return ($radian * (180 / $PI))
EndFunc   ;==>_rad2deg

Func _SignalPercentToDb($InSig);Estimated value
	$dBm = ((($dBmMaxSignal - $dBmDissociationSignal) * $InSig) - (20 * $dBmMaxSignal) + (100 * $dBmDissociationSignal)) / 80
	Return (Round($dBm))
EndFunc   ;==>_SignalPercentToDb

Func _DbToSignalPercent($InDB);Estimated value
	$SIG = 100 - 80 * ($dBmMaxSignal - $InDB) / ($dBmMaxSignal - $dBmDissociationSignal)
	If $SIG < 0 Then $SIG = 0
	Return (Round($SIG))
EndFunc   ;==>_DbToSignalPercent

;-------------------------------------------------------------------------------------------------------------------------------
;                                                       DATE / TIME FUNCTIONS
;-------------------------------------------------------------------------------------------------------------------------------

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

Func _CompareDate($d1, $d2);If $d1 is greater than $d2, return 1 ELSE return 2
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_CompareDate()') ;#Debug Display

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

Func _TimeToSeconds($iTime)
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_TimeToSeconds()') ;#Debug Display
	$dts = StringSplit($iTime, ":") ;Split time so it can be converted to seconds
	$rTime = ($dts[1] * 3600) + ($dts[2] * 60) + $dts[3] ;In seconds
	Return ($rTime)
EndFunc   ;==>_TimeToSeconds

Func _DecToMinSec($dec) ;Convert a decimal value of time to "(XX)XXm XXsec" format
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_DecToMinSec()') ;#Debug Display
	$hdec = $dec / 60
	$mdec = StringRegExpReplace($hdec, "(\d*\.)", ".") * 60
	$sdec = StringRegExpReplace($mdec, "(\d*\.)", ".") * 60
	$Hour = StringFormat("%d\n", $hdec);StringTrimRight($hdec, (StringLen($hdec) - StringInStr($hdec, ".", 1, -1)) + 1)
	$Mins = StringFormat("%d\n", $mdec);StringTrimRight($mdec, (StringLen($mdec) - StringInStr($mdec, ".", 1, -1)) + 1)
	$Secs = Round($sdec, 1);StringTrimRight($sdec, (StringLen($sdec) - StringInStr($sdec, ".", 1, -1)) + 1)

	ConsoleWrite(' $dec:' & $dec & '$hdec: ' & $hdec & '$mdec: ' & $mdec & '$sdec:' & $sdec & @CRLF)
	ConsoleWrite('$Hour: ' & $Hour & '$Mins:' & $Mins & ' $Secs:' & $Secs & @CRLF)

	$rettime = ""
	If $Hour <> 0 Then $rettime &= $Hour & 'h '
	If $Mins <> 0 Then $rettime &= $Mins & 'm '
	If $Secs <> 0 Then $rettime &= $Secs & 's'

	Return ($rettime)
EndFunc   ;==>_DecToMinSec

Func RGB2BGR($iColor)
	If StringLen($iColor) = 8 Then
		$r = StringMid($iColor, 3, 2)
		$g = StringMid($iColor, 5, 2)
		$b = StringMid($iColor, 7, 2)
		Return ('0x' & $b & $g & $r)
	Else
		SetError(1)
		Return ('0xFFFFFF')
	EndIf
EndFunc   ;==>RGB2BGR
;-------------------------------------------------------------------------------------------------------------------------------
;                                                       OTHER FUNCTIONS
;-------------------------------------------------------------------------------------------------------------------------------

Func MyErrFunc()
	$ComError = 1
	If $DebugCom = 1 Then
		MsgBox(0, $Text_Error, "We intercepted a COM Error !" & @CRLF & @CRLF & _
				"err.description is: " & @TAB & $oMyError.description & @CRLF & _
				"err.windescription:" & @TAB & $oMyError.windescription & @CRLF & _
				"err.number is: " & @TAB & Hex($oMyError.number, 8) & @CRLF & _
				"err.lastdllerror is: " & @TAB & $oMyError.lastdllerror & @CRLF & _
				"err.scriptline is: " & @TAB & $oMyError.scriptline & @CRLF & _
				"err.source is: " & @TAB & $oMyError.source & @CRLF & _
				"err.helpfile is: " & @TAB & $oMyError.helpfile & @CRLF & _
				"err.helpcontext is: " & @TAB & $oMyError.helpcontext _
				)
	EndIf
EndFunc   ;==>MyErrFunc

Func _ReduceMemory() ;http://www.autoitscript.com/forum/index.php?showtopic=14070&view=findpost&p=96101
	DllCall("psapi.dll", 'int', 'EmptyWorkingSet', 'long', -1)
EndFunc   ;==>_ReduceMemory

Func _NewSession()
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_NewSession()') ;#Debug Display
	Run(@ScriptDir & "\Vistumbler.exe")
EndFunc   ;==>_NewSession

Func _CleanupFiles($cDIR, $cTYPE)
	$Tmpfiles = _FileListToArray($cDIR, $cTYPE, 1);Find all files in the folder that end in .tmp
	If IsArray($Tmpfiles) Then
		For $FoundTmp = 1 To $Tmpfiles[0]
			$tmpname = $TmpDir & $Tmpfiles[$FoundTmp]
			If _FileInUse($tmpname) = 0 Then FileDelete($tmpname)
		Next
	EndIf
EndFunc   ;==>_CleanupFiles
