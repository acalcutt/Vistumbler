#RequireAdmin
#region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_icon=Icons\icon.ico
#AutoIt3Wrapper_outfile=Vistumbler.exe
#AutoIt3Wrapper_Run_Tidy=y
#endregion ;**** Directives created by AutoIt3Wrapper_GUI ****
;License Information------------------------------------
;Copyright (C) 2010 Andrew Calcutt
;This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; Version 2 of the License.
;This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
;You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
;--------------------------------------------------------
;AutoIt Version: v3.3.6.1
$Script_Author = 'Andrew Calcutt'
$Script_Name = 'Vistumbler'
$Script_Website = 'http://www.Vistumbler.net'
$Script_Function = 'A wireless network scanner for vista. This Program uses "netsh wlan show networks mode=bssid" to get wireless information.'
$version = 'SQLite Alpha 8'
If @AutoItX64 Then $version &= ' (x64)'
$Script_Start_Date = '2007/07/10'
$last_modified = '2010/06/24'
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
#include <Misc.au3>
#include <String.au3>
#include <INet.au3>
#include "UDFs\CommMG.au3"
#include "UDFs\cfxUDF.au3"
#include "UDFs\MD5.au3"
#include "UDFs\NativeWifi.au3"
#include "UDFs\ParseCSV.au3"
#include "UDFs\ZIP.au3"
#include "UDFs\FileInUse.au3"
#include "UDFs\WinGetPosEx.au3"
#include "UDFs\UnixTime.au3"
#include <SQLite.au3>
;VistumblerEXE-------------------------------------------
$VistumblerEXE = StringReplace(@ScriptName, ".au3", ".exe")
;Set/Create Folders--------------------------------------
Dim $SettingsDir = @ScriptDir & '\Settings\'
Dim $DefaultSaveDir = @ScriptDir & '\Save\'
Dim $LanguageDir = @ScriptDir & '\Languages\'
Dim $SoundDir = @ScriptDir & '\Sounds\'
Dim $ImageDir = @ScriptDir & '\Images\'
Dim $TmpDir = @ScriptDir & '\temp\'
Dim $ToolsDir = @ScriptDir & '\Tools\'
Dim $IconDir = @ScriptDir & '\Icons\'
DirCreate($SettingsDir)
DirCreate($DefaultSaveDir)
DirCreate($SettingsDir)
DirCreate($LanguageDir)
DirCreate($SoundDir)
DirCreate($ImageDir)
DirCreate($TmpDir)
DirCreate($ToolsDir)
;Cleanup Old Temp Files----------------------------------
_CleanupFiles($TmpDir, '*.tmp')
_CleanupFiles($TmpDir, '*.ldb')
_CleanupFiles($TmpDir, '*.ini')
_CleanupFiles($TmpDir, '*.kml')
;Set Settings file
Dim $settings = $SettingsDir & 'vistumbler_settings.ini'
;Associate VS1 with Vistumbler
If StringLower(StringTrimLeft(@ScriptName, StringLen(@ScriptName) - 4)) = '.exe' Then
	RegWrite('HKCR\.vsz\', '', 'REG_SZ', 'Vistumbler')
	RegWrite('HKCR\.vs1\', '', 'REG_SZ', 'Vistumbler')
	RegWrite('HKCR\Vistumbler\shell\open\command\', '', 'REG_SZ', '"' & @ScriptFullPath & '" "%1"')
	RegWrite('HKCR\Vistumbler\DefaultIcon\', '', 'REG_SZ', '"' & @ScriptDir & '\Icons\vsfile_icon.ico"')
EndIf

Dim $Load = ''
For $loop = 1 To $CmdLine[0]
	If StringLower(StringTrimLeft($CmdLine[$loop], StringLen($CmdLine[$loop]) - 4)) = '.vs1' Then $Load = $CmdLine[$loop]
	If StringLower(StringTrimLeft($CmdLine[$loop], StringLen($CmdLine[$loop]) - 4)) = '.vsz' Then $Load = $CmdLine[$loop]
Next
; Set a COM Error handler--------------------------------
$oMyError = ObjEvent("AutoIt.Error", "MyErrFunc")
;Set Wifi Scan Type
Dim $UseNativeWifi = IniRead($settings, 'Vistumbler', 'UseNativeWifi', 0)
If @OSVersion = "WIN_XP" Then $UseNativeWifi = 1
; -------------------------------------------------------
GUIRegisterMsg($WM_NOTIFY, "WM_NOTIFY")
;Options-------------------------------------------------
Opt("TrayIconHide", 1);Hide icon in system tray
Opt("GUIOnEventMode", 1);Change to OnEvent mode
;Get Date/Time-------------------------------------------
$dt = StringSplit(_DateTimeUtcConvert(StringFormat("%04i", @YEAR) & '-' & StringFormat("%02i", @MON) & '-' & StringFormat("%02i", @MDAY), @HOUR & ':' & @MIN & ':' & @SEC & '.' & StringFormat("%03i", @MSEC), 1), ' ')
$datestamp = $dt[1]
$timestamp = $dt[2]
$ldatetimestamp = StringFormat("%04i", @YEAR) & '-' & StringFormat("%02i", @MON) & '-' & StringFormat("%02i", @MDAY) & ' ' & @HOUR & '-' & @MIN & '-' & @SEC
;Declair-Variables---------------------------------------
Global $gdi_dll, $user32_dll
Global $hDC

Dim $NsOk
Dim $kml_timer
Dim $StartArraySize
Dim $Debug
Dim $debugdisplay
Dim $sErr
Dim $CompassGraphic, $compasspos_old, $compasspos, $north, $south, $east, $west, $CompassBack, $CompassHeight, $CompassBrush

Dim $VistumblerDB
Dim $VistumblerDbName
Dim $ManuDB = $SettingsDir & 'Manufacturers.sdb'
Dim $LabDB = $SettingsDir & 'Labels.sdb'
Dim $InstDB = $SettingsDir & 'Instruments.sdb'
Dim $FiltDB = $SettingsDir & 'Filters.sdb'
Dim $DBhndl
Dim $ManuDBhndl
Dim $InstDBhndl
Dim $FiltDBhndl
Dim $DateFormat = StringReplace(StringReplace(IniRead($settings, 'DateFormat', 'DateFormat', RegRead('HKCU\Control Panel\International\', 'sShortDate')), 'MM', 'M'), 'dd', 'd')
Dim $APID = 0
Dim $HISTID = 0
Dim $GPS_ID = 0
Dim $Recover = 0

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
Dim $o_old = 0
;Dim $Loading = 0
Dim $disconnected_time = -1
Dim $SortColumn = -1
Dim $GUIList
Dim $TempFileArray, $TempFileArrayShowInt, $NetComm, $OpenArray, $headers, $MANUF, $LABEL, $SigHist
Dim $SSID, $NetworkType, $Authentication, $Encryption, $BSSID, $Signal, $RadioType, $Channel, $BasicTransferRates, $OtherTransferRates
Dim $addposition, $newlat, $newlon, $LatTest, $gps, $winpos
Dim $sort_timer
Dim $data_old
Dim $RefreshTimer
Dim $sizes, $sizes_old
Dim $GraphBack, $GraphGrid, $red, $black
Dim $base_add = 0, $data, $data_old, $info_old, $Graph = 0, $Graph_old, $ResetSizes = 1, $Redraw = 1, $ReGraph = 1
Dim $LastSelected = -1
Dim $save_timer
Dim $AutoSaveFile
Dim $SaveDbOnExit = 0
Dim $ClearAllAps = 0
Dim $UpdateAutoKml = 0
Dim $UpdateAutoSave = 0
Dim $CompassOpen = 0
Dim $CompassGUI = 0
Dim $SettingsOpen = 0
Dim $SayProcess
Dim $MidiProcess
Dim $AutoSaveProcess
Dim $AutoKmlActiveProcess
Dim $AutoKmlDeadProcess
Dim $AutoKmlTrackProcess
Dim $AutoKmlProcess
Dim $RefreshWindowOpened
Dim $NsCancel
Dim $DefaultApapterID
Dim $OpenedPort
Dim $LastGpsString

Dim $AddQuery
Dim $RemoveQuery

Dim $ListviewAPs
Dim $TreeviewAPs

Dim $NetworkAdapters[1]
Dim $wlanhandle = _Wlan_OpenHandle()

Dim $TreeviewAPs_left, $TreeviewAPs_width, $TreeviewAPs_top, $TreeviewAPs_height
Dim $ListviewAPs_left, $ListviewAPs_width, $ListviewAPs_top, $ListviewAPs_height
Dim $Graphic_left, $Graphic_width, $Graphic_top, $Graphic_height

Dim $FixTime, $FixTime2, $FixDate, $Quality
Dim $Temp_FixTime, $Temp_FixTime2, $Temp_FixDate, $Temp_Lat, $Temp_Lon, $Temp_Lat2, $Temp_Lon2, $Temp_Quality, $Temp_NumberOfSatalites, $Temp_HorDilPitch, $Temp_Alt, $Temp_AltS, $Temp_Geo, $Temp_GeoS, $Temp_Status, $Temp_SpeedInKnots, $Temp_SpeedInMPH, $Temp_SpeedInKmH, $Temp_TrackAngle
Dim $GpsDetailsGUI, $GPGGA_Update, $GPRMC_Update, $GpsDetailsOpen = 0, $WifidbGPS_Update
Dim $GpsCurrentDataGUI, $GPGGA_Time, $GPGGA_Lat, $GPGGA_Lon, $GPGGA_Quality, $GPGGA_Satalites, $GPGGA_HorDilPitch, $GPGGA_Alt, $GPGGA_Geo, $GPRMC_Time, $GPRMC_Date, $GPRMC_Lat, $GPRMC_Lon, $GPRMC_Status, $GPRMC_SpeedKnots, $GPRMC_SpeedMPH, $GPRMC_SpeedKmh, $GPRMC_TrackAngle
Dim $GUI_AutoSaveKml, $GUI_GoogleEXE, $GUI_AutoKmlActiveTime, $GUI_AutoKmlDeadTime, $GUI_AutoKmlGpsTime, $GUI_AutoKmlTrackTime, $GUI_KmlFlyTo, $AutoKmlActiveHeader, $AutoKmlDeadHeader, $GUI_OpenKmlNetLink, $GUI_AutoKml_Alt, $GUI_AutoKml_AltMode, $GUI_AutoKml_Heading, $GUI_AutoKml_Range, $GUI_AutoKml_Tilt
Dim $GUI_SpeakSignal, $GUI_PlayMidiSounds, $GUI_SpeakSoundsVis, $GUI_SpeakSoundsSapi, $GUI_SpeakPercent, $GUI_SpeakSigTime, $GUI_SpeakSoundsMidi, $GUI_Midi_Instument, $GUI_Midi_PlayTime

Dim $GUI_Import, $vistumblerfileinput, $progressbar, $percentlabel, $linemin, $newlines, $minutes, $linetotal, $estimatedtime, $RadVis, $RadCsv, $RadNs, $RadWD
Dim $ExportKMLGUI, $GUI_TrackColor

Dim $UpdateTimer, $MemReleaseTimer, $begintime, $closebtn

Dim $Apply_GPS = 1, $Apply_Language = 0, $Apply_Manu = 0, $Apply_Lab = 0, $Apply_Column = 1, $Apply_Searchword = 1, $Apply_Misc = 1, $Apply_Auto = 1, $Apply_AutoKML = 1, $Apply_Filter = 1
Dim $SetMisc, $GUI_Comport, $GUI_Baud, $GUI_Parity, $GUI_StopBit, $GUI_DataBit, $GUI_Format, $Rad_UseNetcomm, $Rad_UseCommMG, $Rad_UseKernel32, $LanguageBox, $SearchWord_SSID_GUI, $SearchWord_BSSID_GUI, $SearchWord_NetType_GUI
Dim $SearchWord_Authentication_GUI, $SearchWord_Signal_GUI, $SearchWord_RadioType_GUI, $SearchWord_Channel_GUI, $SearchWord_BasicRates_GUI, $SearchWord_OtherRates_GUI, $SearchWord_Encryption_GUI, $SearchWord_Open_GUI
Dim $SearchWord_None_GUI, $SearchWord_Wep_GUI, $SearchWord_Infrastructure_GUI, $SearchWord_Adhoc_GUI

Dim $LabAuth, $LabDate, $LabWinCode, $LabDesc, $GUI_Set_SaveDir, $GUI_Set_SaveDirAuto, $GUI_Set_SaveDirKml, $GUI_BKColor, $GUI_CBKColor, $GUI_TextColor, $GUI_TimeBeforeMarkingDead, $GUI_RefreshLoop, $GUI_AutoCheckForUpdates, $GUI_CheckForBetaUpdates
Dim $GUI_Manu_List, $GUI_Lab_List, $ImpLanFile
Dim $EditMacGUIForm, $GUI_Manu_NewManu, $GUI_Manu_NewMac, $EditMac_Mac, $EditMac_GUI, $EditLine, $GUI_Lab_NewMac, $GUI_Lab_NewLabel
Dim $AutoSaveBox, $AutoSaveDelBox, $AutoSaveSec, $GUI_SortDirection, $GUI_RefreshNetworks, $GUI_RefreshTime, $GUI_WifidbLocate, $GUI_WiFiDbLocateRefreshTime, $GUI_SortBy, $GUI_SortTime, $GUI_AutoSort, $GUI_SortTime, $GUI_PhilsGraphURL, $GUI_PhilsWdbURL
Dim $Gui_CsvFile, $Gui_CsvRadSummary, $Gui_CsvRadDetailed, $Gui_CsvFilter
Dim $GUI_ModifyFilters, $FilterLV, $AddEditFilt_GUI, $Filter_ID_GUI, $Filter_Name_GUI, $Filter_Desc_GUI

Dim $CWCB_RadioType, $CWIB_RadioType, $CWCB_Channel, $CWIB_Channel, $CWCB_Latitude, $CWIB_Latitude, $CWCB_Longitude, $CWIB_Longitude, $CWCB_LatitudeDMS, $CWIB_LatitudeDMS, $CWCB_LongitudeDMS, $CWIB_LongitudeDMS, $CWCB_LatitudeDMM, $CWIB_LatitudeDMM, $CWCB_LongitudeDMM, $CWIB_LongitudeDMM, $CWCB_BtX, $CWIB_BtX, $CWCB_OtX, $CWIB_OtX, $CWCB_FirstActive, $CWIB_FirstActive
Dim $CWCB_LastActive, $CWIB_LastActive, $CWCB_Line, $CWIB_Line, $CWCB_Active, $CWIB_Active, $CWCB_SSID, $CWIB_SSID, $CWCB_BSSID, $CWIB_BSSID, $CWCB_Manu, $CWIB_Manu, $CWCB_Signal, $CWIB_Signal
Dim $CWCB_Authentication, $CWIB_Authentication, $CWCB_Encryption, $CWIB_Encryption, $CWCB_NetType, $CWIB_NetType, $CWCB_Label, $CWIB_Label

Dim $GUI_COPY, $CopyAPID, $Copy_Line, $Copy_BSSID, $Copy_SSID, $Copy_CHAN, $Copy_AUTH, $Copy_ENCR, $Copy_NETTYPE, $Copy_RADTYPE, $Copy_SIG, $Copy_LAB, $Copy_MANU, $Copy_LAT, $Copy_LON, $Copy_LATDMS, $Copy_LONDMS, $Copy_LATDMM, $Copy_LONDMM, $Copy_BTX, $Copy_OTX, $Copy_FirstActive, $Copy_LastActive

Dim $Filter_SSID_GUI, $Filter_BSSID_GUI, $Filter_CHAN_GUI, $Filter_AUTH_GUI, $Filter_ENCR_GUI, $Filter_RADTYPE_GUI, $Filter_NETTYPE_GUI, $Filter_SIG_GUI, $Filter_BTX_GUI, $Filter_OTX_GUI, $Filter_Line_GUI, $Filter_Active_GUI
$CurrentVersionFile = @ScriptDir & '\versions.ini'
$NewVersionFile = @ScriptDir & '\temp\versions.ini'
$VIEWSVN_ROOT = 'http://svn.vistumbler.net/viewvc/vistumbler/VistumblerSQLite/'

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
Dim $Direction[23];Direction array for sorting by clicking on the header. Needs to be 1 greatet (or more) than the amount of columns
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
Dim $WiFiDbLocateRefreshTime = IniRead($settings, 'Vistumbler', 'WiFiDbLocateRefreshTime', 5000)
Dim $Debug = IniRead($settings, 'Vistumbler', 'Debug', 0)
Dim $GraphDeadTime = IniRead($settings, 'Vistumbler', 'GraphDeadTime', 0)
Dim $SaveGpsWithNoAps = IniRead($settings, 'Vistumbler', 'SaveGpsWithNoAps', 1)
Dim $ShowEstimatedDB = IniRead($settings, 'Vistumbler', 'ShowEstimatedDB', 0)
Dim $TimeBeforeMarkedDead = IniRead($settings, 'Vistumbler', 'TimeBeforeMarkedDead', 2)
Dim $AutoSelect = IniRead($settings, 'Vistumbler', 'AutoSelect', 0)
Dim $UseWiFiDbGpsLocate = IniRead($settings, 'Vistumbler', 'UseWiFiDbGpsLocate', 0)
Dim $DefFiltID = IniRead($settings, 'Vistumbler', 'DefFiltID', '-1')

Dim $CompassPosition = IniRead($settings, 'WindowPositions', 'CompassPosition', '')
Dim $GpsDetailsPosition = IniRead($settings, 'WindowPositions', 'GpsDetailsPosition', '')

Dim $ComPort = IniRead($settings, 'GpsSettings', 'ComPort', '4')
Dim $BAUD = IniRead($settings, 'GpsSettings', 'Baud', '4800')
Dim $PARITY = IniRead($settings, 'GpsSettings', 'Parity', 'N')
Dim $DATABIT = IniRead($settings, 'GpsSettings', 'DataBit', '8')
Dim $STOPBIT = IniRead($settings, 'GpsSettings', 'StopBit', '1')
Dim $GpsType = IniRead($settings, 'GpsSettings', 'GpsType', '2')
Dim $GPSformat = IniRead($settings, 'GpsSettings', 'GPSformat', 3)
Dim $GpsTimeout = IniRead($settings, 'GpsSettings', 'GpsTimeout', 30000)

Dim $SortTime = IniRead($settings, 'AutoSort', 'AutoSortTime', 60)
Dim $AutoSort = IniRead($settings, 'AutoSort', 'AutoSort', 0)
Dim $SortBy = IniRead($settings, 'AutoSort', 'SortCombo', 'Sort by SSID')
Dim $SortDirection = IniRead($settings, 'AutoSort', 'AscDecDefault', 1)

Dim $SaveTime = IniRead($settings, 'AutoSave', 'AutoSaveTime', 300)
Dim $AutoSave = IniRead($settings, 'AutoSave', 'AutoSave', 1)
Dim $AutoSaveDel = IniRead($settings, 'AutoSave', 'AutoSaveDel', 1)

Dim $SoundOnAP = IniRead($settings, 'Sound', 'PlaySoundOnNewAP', 1)
Dim $new_AP_sound = IniRead($settings, 'Sound', 'NewAP_Sound', 'new_ap.wav')
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
Dim $GoogleEarth_EXE = IniRead($settings, 'AutoKML', 'GoogleEarth_EXE', 'C:\Program Files\Google\Google Earth\googleearth.exe')

Dim $PhilsGraphURL = IniRead($settings, 'PhilsWifiTools', 'Graph_URL', 'http://www.randomintervals.com/wifi/')
Dim $PhilsWdbURL = IniRead($settings, 'PhilsWifiTools', 'WiFiDB_URL', 'http://www.vistumbler.net/wifidb/')

Dim $column_Line = IniRead($settings, 'Columns', 'Column_Line', 0)
Dim $column_Active = IniRead($settings, 'Columns', 'Column_Active', 1)
Dim $column_BSSID = IniRead($settings, 'Columns', 'Column_BSSID', 2)
Dim $column_SSID = IniRead($settings, 'Columns', 'Column_SSID', 3)
Dim $column_Signal = IniRead($settings, 'Columns', 'Column_Signal', 4)
Dim $column_Channel = IniRead($settings, 'Columns', 'Column_Channel', 5)
Dim $column_Authentication = IniRead($settings, 'Columns', 'Column_Authentication', 6)
Dim $column_Encryption = IniRead($settings, 'Columns', 'Column_Encryption', 7)
Dim $column_NetworkType = IniRead($settings, 'Columns', 'Column_NetworkType', 8)
Dim $column_Latitude = IniRead($settings, 'Columns', 'Column_Latitude', 9)
Dim $column_Longitude = IniRead($settings, 'Columns', 'Column_Longitude', 10)
Dim $column_MANUF = IniRead($settings, 'Columns', 'Column_Manufacturer', 11)
Dim $column_Label = IniRead($settings, 'Columns', 'Column_Label', 12)
Dim $column_RadioType = IniRead($settings, 'Columns', 'Column_RadioType', 13)
Dim $column_LatitudeDMS = IniRead($settings, 'Columns', 'Column_LatitudeDMS', 14)
Dim $column_LongitudeDMS = IniRead($settings, 'Columns', 'Column_LongitudeDMS', 15)
Dim $column_LatitudeDMM = IniRead($settings, 'Columns', 'Column_LatitudeDMM', 16)
Dim $column_LongitudeDMM = IniRead($settings, 'Columns', 'Column_LongitudeDMM', 17)
Dim $column_BasicTransferRates = IniRead($settings, 'Columns', 'Column_BasicTransferRates', 18)
Dim $column_OtherTransferRates = IniRead($settings, 'Columns', 'Column_OtherTransferRates', 19)
Dim $column_FirstActive = IniRead($settings, 'Columns', 'Column_FirstActive', 20)
Dim $column_LastActive = IniRead($settings, 'Columns', 'Column_LastActive', 21)

Dim $column_Width_Line = IniRead($settings, 'Column_Width', 'Column_Line', 35)
Dim $column_Width_Active = IniRead($settings, 'Column_Width', 'Column_Active', 60)
Dim $column_Width_SSID = IniRead($settings, 'Column_Width', 'Column_SSID', 150)
Dim $column_Width_BSSID = IniRead($settings, 'Column_Width', 'Column_BSSID', 110)
Dim $column_Width_MANUF = IniRead($settings, 'Column_Width', 'Column_Manufacturer', 110)
Dim $column_Width_Signal = IniRead($settings, 'Column_Width', 'Column_Signal', 60)
Dim $column_Width_Authentication = IniRead($settings, 'Column_Width', 'Column_Authentication', 105)
Dim $column_Width_Encryption = IniRead($settings, 'Column_Width', 'Column_Encryption', 105)
Dim $column_Width_RadioType = IniRead($settings, 'Column_Width', 'Column_RadioType', 85)
Dim $column_Width_Channel = IniRead($settings, 'Column_Width', 'Column_Channel', 70)
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
Dim $Column_Names_Authentication = IniRead($DefaultLanguagePath, 'Column_Names', 'Column_Authentication', 'Authentication')
Dim $Column_Names_Encryption = IniRead($DefaultLanguagePath, 'Column_Names', 'Column_Encryption', 'Encryption')
Dim $Column_Names_RadioType = IniRead($DefaultLanguagePath, 'Column_Names', 'Column_RadioType', 'Radio Type')
Dim $Column_Names_Channel = IniRead($DefaultLanguagePath, 'Column_Names', 'Column_Channel', 'Channel')
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
Dim $Text_AddAPsToTop = IniRead($DefaultLanguagePath, 'GuiText', 'AddAPsToTop', 'Add new APs to top')

Dim $Text_Extra = IniRead($DefaultLanguagePath, 'GuiText', 'Extra', 'Ex&tra')
Dim $Text_ScanAPs = IniRead($DefaultLanguagePath, 'GuiText', 'ScanAPs', '&Scan APs')
Dim $Text_StopScanAps = IniRead($DefaultLanguagePath, 'GuiText', 'StopScanAps', '&Stop')
Dim $Text_UseGPS = IniRead($DefaultLanguagePath, 'GuiText', 'UseGPS', 'Use &GPS')
Dim $Text_StopGPS = IniRead($DefaultLanguagePath, 'GuiText', 'StopGPS', 'Stop &GPS')

Dim $Text_Settings = IniRead($DefaultLanguagePath, 'GuiText', 'Settings', 'S&ettings')
Dim $Text_GpsSettings = IniRead($DefaultLanguagePath, 'GuiText', 'GpsSettings', 'G&PS Settings')
Dim $Text_SetLanguage = IniRead($DefaultLanguagePath, 'GuiText', 'SetLanguage', 'Set &Language')
Dim $Text_SetSearchWords = IniRead($DefaultLanguagePath, 'GuiText', 'SetSearchWords', 'Set Search &Words')
Dim $Text_SetMacLabel = IniRead($DefaultLanguagePath, 'GuiText', 'SetMacLabel', 'Set Labels by Mac')
Dim $Text_SetMacManu = IniRead($DefaultLanguagePath, 'GuiText', 'SetMacManu', 'Set Manufactures by Mac')

Dim $Text_PhilsPHPgraph = IniRead($DefaultLanguagePath, 'GuiText', 'PhilsPHPgraph', 'View graph (Phils PHP)')
Dim $Text_PhilsWDB = IniRead($DefaultLanguagePath, 'GuiText', 'PhilsWDB', 'Phils WiFiDB (Alpha)')
Dim $Text_UploadDataToWifiDB = IniRead($DefaultLanguagePath, 'GuiText', 'UploadDataToWiFiDB', 'Upload Data to WiFiDB')

Dim $Text_RefreshLoopTime = IniRead($DefaultLanguagePath, 'GuiText', 'RefreshLoopTime', 'Refresh loop time(ms):')
Dim $Text_ActualLoopTime = IniRead($DefaultLanguagePath, 'GuiText', 'ActualLoopTime', 'Loop time')
Dim $Text_Longitude = IniRead($DefaultLanguagePath, 'GuiText', 'Longitude', 'Longitude')
Dim $Text_Latitude = IniRead($DefaultLanguagePath, 'GuiText', 'Latitude', 'Latitude')
Dim $Text_ActiveAPs = IniRead($DefaultLanguagePath, 'GuiText', 'ActiveAPs', 'Active APs')
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
Dim $Text_Save = IniRead($DefaultLanguagePath, 'GuiText', 'Save', 'Save?')
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
Dim $Text_AutoSave = IniRead($DefaultLanguagePath, 'GuiText', 'AutoSave', 'Auto Save')
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
Dim $Text_NoApsWithGps = IniRead($DefaultLanguagePath, 'GuiText', 'NoApsWithGps', 'No Access Points found with GPS coordinates.')
Dim $Text_MacExistsOverwriteIt = IniRead($DefaultLanguagePath, 'GuiText', 'MacExistsOverwriteIt', 'A entry for this mac address already exists. would you like to overwrite it?')
Dim $Text_SavingLine = IniRead($DefaultLanguagePath, 'GuiText', 'SavingLine', 'Saving Line')
Dim $Text_DisplayDebug = IniRead($DefaultLanguagePath, 'GuiText', 'DisplayDebug', 'Debug - Display Functions')
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
Dim $Text_VistumblerFile = IniRead($DefaultLanguagePath, 'GuiText', 'VistumblerFile', 'Vistumbler File')
Dim $Text_DetailedCsvFile = IniRead($DefaultLanguagePath, 'GuiText', 'DetailedFile', 'Detailed CSV File')
Dim $Text_NetstumblerTxtFile = IniRead($DefaultLanguagePath, 'GuiText', 'NetstumblerTxtFile', 'Netstumbler TXT File')
Dim $Text_ErrorOpeningGpsPort = IniRead($DefaultLanguagePath, 'GuiText', 'ErrorOpeningGpsPort', 'Error opening GPS port')
Dim $Text_SecondsSinceGpsUpdate = IniRead($DefaultLanguagePath, 'GuiText', 'SecondsSinceGpsUpdate', 'Seconds Since GPS Update')
Dim $Text_SavingGID = IniRead($DefaultLanguagePath, 'GuiText', 'SavingGID', 'Saving GID')
Dim $Text_SavingHistID = IniRead($DefaultLanguagePath, 'GuiText', 'SavingHistID', 'Saving HistID')
Dim $Text_NoUpdates = IniRead($DefaultLanguagePath, 'GuiText', 'NoUpdates', 'No Updates Avalible')
Dim $Text_NoActiveApFound = IniRead($DefaultLanguagePath, 'GuiText', 'NoActiveApFound', 'No Active AP found')
Dim $Text_VistumblerDonate = IniRead($DefaultLanguagePath, 'GuiText', 'VistumblerDonate', 'Donate')
Dim $Text_VistumblerStore = IniRead($DefaultLanguagePath, 'GuiText', 'VistumblerStore', 'Store')
Dim $Text_SupportVistumbler = IniRead($DefaultLanguagePath, 'GuiText', 'SupportVistumbler', '*Support Vistumbler*')
Dim $Text_UseNativeWifi = IniRead($DefaultLanguagePath, 'GuiText', 'UseNativeWifi', 'Use Native Wifi (No BSSID, CHAN, OTX, BTX, or RADTYPE)')
Dim $Text_FilterMsg = IniRead($DefaultLanguagePath, 'GuiText', 'FilterMsg', 'Use asterik(*)" as wildcard. Seperate multiple filters with a comma(,). Use a dash(-) for ranges.')
Dim $Text_SetFilters = IniRead($DefaultLanguagePath, 'GuiText', 'SetFilters', 'Set Filters')
Dim $Text_Filtered = IniRead($DefaultLanguagePath, 'GuiText', 'Filtered', 'Filtered')
Dim $Text_Filters = IniRead($DefaultLanguagePath, 'GuiText', 'Filters', 'Filters')
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
Dim $Text_AutoSelectConnectedAP = IniRead($DefaultLanguagePath, 'GuiText', 'AutoSelectConnectedAP', 'Auto Select Connected AP')
Dim $Text_Experimental = IniRead($DefaultLanguagePath, 'GuiText', 'Experimental', 'Experimental')
Dim $Text_Color = IniRead($DefaultLanguagePath, 'GuiText', 'Color', 'Color')
Dim $Text_PhilsWifiTools = IniRead($DefaultLanguagePath, "GuiText", "PhilsWifiTools", "Phil's WiFi Tools")
Dim $Text_AddRemFilters = IniRead($DefaultLanguagePath, "GuiText", "AddRemFilters", "Add/Remove Filters")
Dim $Text_NoFilterSelected = IniRead($DefaultLanguagePath, "GuiText", "NoFilterSelected", "No filter selected.")
Dim $Text_AddFilter = IniRead($DefaultLanguagePath, "GuiText", "AddFilter", "Add Filter")
Dim $Text_EditFilter = IniRead($DefaultLanguagePath, "GuiText", "EditFilter ", "Edit Filter ")
Dim $Text_DeleteFilter = IniRead($DefaultLanguagePath, "GuiText", "DeleteFilter", "Delete Filter")
Dim $Text_TimeBeforeMarkedDead = IniRead($DefaultLanguagePath, "GuiText", "TimeBeforeMarkedDead", "Time to wait before marking AP dead (s)")

If $AutoCheckForUpdates = 1 Then
	If _CheckForUpdates() = 1 Then
		$updatemsg = MsgBox(4, $Text_Update, $Text_UpdateMsg)
		If $updatemsg = 6 Then _StartUpdate()
	EndIf
EndIf

$MDBfiles = _FileListToArray($TmpDir, '*.SDB', 1);Find all files in the folder that end in .SDB (SQLite DB)
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
		$VistumblerDB = $TmpDir & $ldatetimestamp & '.SDB'
		$VistumblerDbName = $ldatetimestamp & '.SDB'
	Else
		GUISetState(@SW_SHOW)
		While 1
			$nMsg = GUIGetMsg()
			Switch $nMsg
				Case $GUI_EVENT_CLOSE
					$VistumblerDB = $TmpDir & $ldatetimestamp & '.SDB'
					$VistumblerDbName = $ldatetimestamp & '.SDB'
					ExitLoop
				Case $Recover_New
					$VistumblerDB = $TmpDir & $ldatetimestamp & '.SDB'
					$VistumblerDbName = $ldatetimestamp & '.SDB'
					ExitLoop
				Case $Recover_Exit
					Exit
				Case $Recover_Rec
					$Selected = _GUICtrlListView_GetNextItem($Recover_List); find what AP is selected in the list. returns -1 is nothing is selected
					If $Selected = '-1' Then
						MsgBox(0, $Text_Error, $Text_NoMdbSelected)
					Else
						$mdbfilename = _GUICtrlListView_GetItemText($Recover_List, $Selected)
						$VistumblerDB = $TmpDir & $mdbfilename
						$VistumblerDbName = $mdbfilename
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
	$VistumblerDB = $TmpDir & $ldatetimestamp & '.SDB'
	$VistumblerDbName = $ldatetimestamp & '.SDB'
EndIf

_SQLite_Startup()
Local $aRow

ConsoleWrite($VistumblerDB & @CRLF)
If FileExists($VistumblerDB) Then
	$Recover = 1
	$APID = 0
	$DBhndl = _SQLite_Open($VistumblerDB, $SQLITE_OPEN_READWRITE + $SQLITE_OPEN_CREATE, $SQLITE_ENCODING_UTF16)
	_SQLite_Exec($DBhndl, "pragma synchronous=0");Speed vs Data security. Speed Wins for now.
	Local $HistMatchArray, $iRows, $iColumns, $iRval
	$query = "SELECT HistID FROM Hist"
	$iRval = _SQLite_GetTable2d($DBhndl, $query, $HistMatchArray, $iRows, $iColumns)
	$HISTID = $iRows
	Local $GpsMatchArray, $iRows, $iColumns, $iRval
	$query = "SELECT GpsID FROM GPS"
	$iRval = _SQLite_GetTable2d($DBhndl, $query, $GpsMatchArray, $iRows, $iColumns)
	$GPS_ID = $iRows
	$query = "DELETE FROM TreeviewPos"
	_SQLite_Exec($DBhndl, $query)
Else
	_SetUpDbTables($VistumblerDB)
EndIf

;Connect to manufacturer database
If FileExists($ManuDB) Then
	$ManuDBhndl = _SQLite_Open($ManuDB, $SQLITE_OPEN_READWRITE + $SQLITE_OPEN_CREATE, $SQLITE_ENCODING_UTF16)
Else
	$ManuDBhndl = _SQLite_Open($ManuDB, $SQLITE_OPEN_READWRITE + $SQLITE_OPEN_CREATE, $SQLITE_ENCODING_UTF16)
	_SQLite_Exec($ManuDBhndl, "CREATE TABLE Manufacturers (BSSID,Manufacturer)")
	_SQLite_Exec($ManuDBhndl, "pragma synchronous=0");Speed vs Data security. Speed Wins for now.
EndIf
;Connect to label database
If FileExists($LabDB) Then
	$LabDBhndl = _SQLite_Open($LabDB, $SQLITE_OPEN_READWRITE + $SQLITE_OPEN_CREATE, $SQLITE_ENCODING_UTF16)
Else
	$LabDBhndl = _SQLite_Open($LabDB, $SQLITE_OPEN_READWRITE + $SQLITE_OPEN_CREATE, $SQLITE_ENCODING_UTF16)
	_SQLite_Exec($LabDBhndl, "CREATE TABLE Labels (BSSID,Label)")
EndIf
;Connect to Instrument database
If FileExists($InstDB) Then
	$InstDBhndl = _SQLite_Open($InstDB, $SQLITE_OPEN_READWRITE + $SQLITE_OPEN_CREATE, $SQLITE_ENCODING_UTF16)
Else
	$InstDBhndl = _SQLite_Open($InstDB, $SQLITE_OPEN_READWRITE + $SQLITE_OPEN_CREATE, $SQLITE_ENCODING_UTF16)
	_SQLite_Exec($InstDBhndl, "CREATE TABLE Instruments (INSTNUM,INSTTEXT)")
EndIf
;Connect to Filter database
If FileExists($FiltDB) Then
	$FiltDBhndl = _SQLite_Open($FiltDB, $SQLITE_OPEN_READWRITE + $SQLITE_OPEN_CREATE, $SQLITE_ENCODING_UTF16)
	Local $FiltMatchArray, $iRows, $iColumns, $iRval
	$query = "SELECT FiltID FROM Filters"
	$iRval = _SQLite_GetTable2d($FiltDBhndl, $query, $FiltMatchArray, $iRows, $iColumns)
	$FiltID = $iRows
Else
	$FiltDBhndl = _SQLite_Open($FiltDB, $SQLITE_OPEN_READWRITE + $SQLITE_OPEN_CREATE, $SQLITE_ENCODING_UTF16)
	_SQLite_Exec($FiltDBhndl, "CREATE TABLE Filters (FiltID,FiltName,FiltDesc,SSID,BSSID,CHAN,AUTH,ENCR,RADTYPE,NETTYPE,Signal,BTX,OTX,ApID,Active)")
	$FiltID = 0
EndIf

$var = IniReadSection($settings, "Columns")
If @error Then
	$headers = '#|Active|Mac Address|SSID|Signal|Channel|Authentication|Encryption|Network Type|Latitude|Longitude|Manufacturer|Label|Radio Type|Lat (dd mm ss)|Lon (dd mm ss)|Lat (ddmm.mmmm)|Lon (ddmm.mmmm)|Basic Transfer Rates|Other Transfer Rates|First Active|Last Updated|'
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
Dim $title = $Script_Name & ' ' & $version & ' - By ' & $Script_Author & ' - ' & _DateLocalFormat($last_modified) & ' - (' & $VistumblerDbName & ')'
$Vistumbler = GUICreate($title, 980, 692, -1, -1, BitOR($WS_OVERLAPPEDWINDOW, $WS_CLIPSIBLINGS))
GUISetBkColor($BackgroundColor)

$a = _WinGetPosEx($Vistumbler);Get window current position
Dim $VistumblerState = IniRead($settings, 'WindowPositions', 'VistumblerState', "Window");Get last window position from the ini file
Dim $VistumblerPosition = IniRead($settings, 'WindowPositions', 'VistumblerPosition', $a[0] & ',' & $a[1] & ',' & $a[2] & ',' & $a[3])
$b = StringSplit($VistumblerPosition, ",")

If $VistumblerState = "Maximized" Then
	WinSetState($title, "", @SW_MAXIMIZE)
Else
	;Split ini posion string
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
$ExportVSZMenu = GUICtrlCreateMenu('Export To VSZ', $Export)
$ExportToVSZ = GUICtrlCreateMenuItem($Text_AllAPs, $ExportVSZMenu)
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
$ScanWifiGUI = GUICtrlCreateMenuItem($Text_ScanAPs, $Options)
$RefreshMenuButton = GUICtrlCreateMenuItem($Text_RefreshNetworks, $Options)
If $RefreshNetworks = 1 Then GUICtrlSetState($RefreshMenuButton, $GUI_CHECKED)
$AutoSaveGUI = GUICtrlCreateMenuItem($Text_AutoSave, $Options)
If $AutoSave = 1 Then GUICtrlSetState($AutoSaveGUI, $GUI_CHECKED)

$AutoSaveKML = GUICtrlCreateMenuItem($Text_AutoKml, $Options)
If $AutoKML = 1 Then GUICtrlSetState(-1, $GUI_CHECKED)
$UseWiFiDbGpsLocateButton = GUICtrlCreateMenuItem($Text_AutoWiFiDbGpsLocate & ' (' & $Text_Experimental & ')', $Options)
If $UseWiFiDbGpsLocate = 1 Then GUICtrlSetState(-1, $GUI_CHECKED)
$PlaySoundOnNewAP = GUICtrlCreateMenuItem($Text_PlaySound, $Options)
If $SoundOnAP = 1 Then GUICtrlSetState($PlaySoundOnNewAP, $GUI_CHECKED)
$SpeakApSignal = GUICtrlCreateMenuItem($Text_SpeakSignal, $Options)
If $SpeakSignal = 1 Then GUICtrlSetState($SpeakApSignal, $GUI_CHECKED)
$GUI_MidiActiveAps = GUICtrlCreateMenuItem($Text_PlayMidiSounds, $Options)
If $Midi_PlayForActiveAps = 1 Then GUICtrlSetState(-1, $GUI_CHECKED)
$MenuSaveGpsWithNoAps = GUICtrlCreateMenuItem($Text_SaveAllGpsData, $Options)
If $SaveGpsWithNoAps = 1 Then GUICtrlSetState(-1, $GUI_CHECKED)
$GuiUseNativeWifi = GUICtrlCreateMenuItem($Text_UseNativeWifi, $Options)
If $UseNativeWifi = 1 Then GUICtrlSetState(-1, $GUI_CHECKED)
If @OSVersion = "WIN_XP" Then GUICtrlSetState(-1, $GUI_DISABLE)
$DebugFunc = GUICtrlCreateMenuItem($Text_DisplayDebug, $Options)
If $Debug = 1 Then GUICtrlSetState(-1, $GUI_CHECKED)

$ViewMenu = GUICtrlCreateMenu($Text_View)
$FilterMenu = GUICtrlCreateMenu($Text_Filters, $ViewMenu)
Dim $FilterMenuID_Array[1]
Dim $FilterID_Array[1]
Dim $FoundFilter = 0
$AddRemoveFilters = GUICtrlCreateMenuItem($Text_AddRemFilters, $FilterMenu)
Local $FiltMatchArray, $iRows, $iColumns, $iRval
$query = "SELECT FiltID, FiltName FROM Filters"
$iRval = _SQLite_GetTable2d($FiltDBhndl, $query, $FiltMatchArray, $iRows, $iColumns)
$FoundFiltMatch = $iRows
If $FoundFiltMatch <> 0 Then
	For $ffm = 1 To $FoundFiltMatch
		$Filter_ID = $FiltMatchArray[$ffm][0]
		$Filter_Name = $FiltMatchArray[$ffm][1]
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

$AutoSortGUI = GUICtrlCreateMenuItem($Text_AutoSort, $ViewMenu)
If $AutoSort = 1 Then GUICtrlSetState($AutoSortGUI, $GUI_CHECKED)
$AutoSelectMenuButton = GUICtrlCreateMenuItem($Text_AutoSelectConnectedAP, $ViewMenu)
If $AutoSelect = 1 Then GUICtrlSetState(-1, $GUI_CHECKED)
$AddNewAPsToTop = GUICtrlCreateMenuItem($Text_AddAPsToTop, $ViewMenu)
If $AddDirection = 0 Then GUICtrlSetState(-1, $GUI_CHECKED)
$ShowEstDb = GUICtrlCreateMenuItem($Text_ShowSignalDB, $ViewMenu)
If $ShowEstimatedDB = 1 Then GUICtrlSetState(-1, $GUI_CHECKED)
$GraphDeadTimeGUI = GUICtrlCreateMenuItem($Text_GraphDeadTime, $ViewMenu)
If $GraphDeadTime = 1 Then GUICtrlSetState(-1, $GUI_CHECKED)


$SettingsMenu = GUICtrlCreateMenu($Text_Settings)
$SetMisc = GUICtrlCreateMenuItem($Text_VistumblerSettings, $SettingsMenu)
$SetGPS = GUICtrlCreateMenuItem($Text_GpsSettings, $SettingsMenu)
$SetLanguage = GUICtrlCreateMenuItem($Text_SetLanguage, $SettingsMenu)
$SetSearchWords = GUICtrlCreateMenuItem($Text_SetSearchWords, $SettingsMenu)
$SetMacLabel = GUICtrlCreateMenuItem($Text_SetMacLabel, $SettingsMenu)
$SetMacManu = GUICtrlCreateMenuItem($Text_SetMacManu, $SettingsMenu)
$SetColumnWidths = GUICtrlCreateMenuItem($Text_SetColumnWidths, $SettingsMenu)
$SetAuto = GUICtrlCreateMenuItem($Text_AutoSave & ' / ' & $Text_AutoSort & ' / ' & $Text_RefreshNetworks & ' / ' & $Text_AutoWiFiDbGpsLocate, $SettingsMenu)
$SetAutoKML = GUICtrlCreateMenuItem($Text_AutoKml & ' / ' & $Text_SpeakSignal & ' / ' & $Text_MIDI, $SettingsMenu)

$Interfaces = GUICtrlCreateMenu($Text_Interface)
$RefreshInterfaces = GUICtrlCreateMenuItem("Refresh Interfaces", $Interfaces)
GUICtrlSetOnEvent($RefreshInterfaces, '_RefreshInterfaces')
_AddInterfaces()

$Extra = GUICtrlCreateMenu($Text_Extra)
#comments-start
	$ExternalToolsMenu = GUICtrlCreateMenu("External Tools", $Extra)
	Dim $ToolMenuID[1]
	Dim $ToolFilename[1]
	$menuid = GUICtrlCreateMenuItem("Open External Tools Folder", $ExternalToolsMenu)
	GUICtrlSetOnEvent($menuid, '_OpenExternalToolsFolder')
	$ToolFiles = _FileListToArray($ToolsDir, '*.*', 1);Find all files in the folder
	For $FoundTools = 1 To $ToolFiles[0]
	$file = $ToolFiles[$FoundTools]
	$menuid = GUICtrlCreateMenuItem(StringTrimRight($file, 4), $ExternalToolsMenu)
	_ArrayAdd($ToolMenuID, $menuid)
	_ArrayAdd($ToolFilename, $ToolsDir & $file)
	$ToolMenuID[0] = UBound($ToolMenuID) - 1
	$ToolFilename[0] = UBound($ToolFilename) - 1
	GUICtrlSetOnEvent($menuid, '_OpenExternalTool')
	Next
#comments-end
$OpenKmlNetworkLink = GUICtrlCreateMenuItem($Text_OpenKmlNetLink, $Extra)
$GpsDetails = GUICtrlCreateMenuItem($Text_GpsDetails, $Extra)
$GpsCompass = GUICtrlCreateMenuItem($Text_GpsCompass, $Extra)
$OpenSaveFolder = GUICtrlCreateMenuItem($Text_OpenSaveFolder, $Extra)
$ViewInPhilsPHP = GUICtrlCreateMenuItem($Text_PhilsPHPgraph, $Extra)
$ViewPhilsWDB = GUICtrlCreateMenuItem($Text_UploadDataToWifiDB & ' (' & $Text_Experimental & ')', $Extra)
$LocateInWDB = GUICtrlCreateMenuItem($Text_LocateInWiFiDB & ' (' & $Text_Experimental & ')', $Extra)
$UpdateManufacturers = GUICtrlCreateMenuItem("Update Manufacturers", $Extra)


$Help = GUICtrlCreateMenu($Text_Help)
$VistumblerHome = GUICtrlCreateMenuItem($Text_VistumblerHome, $Help)
$VistumblerForum = GUICtrlCreateMenuItem($Text_VistumblerForum, $Help)
$VistumblerWiki = GUICtrlCreateMenuItem($Text_VistumblerWiki, $Help)
$UpdateVistumbler = GUICtrlCreateMenuItem($Text_CheckForUpdates, $Help)




$SupportVistumbler = GUICtrlCreateMenu($Text_SupportVistumbler)
$VistumblerDonate = GUICtrlCreateMenuItem($Text_VistumblerDonate, $SupportVistumbler)
$VistumblerStore = GUICtrlCreateMenuItem($Text_VistumblerStore, $SupportVistumbler)

$GraphicGUI = GUICreate("", 900, 400, 10, 60, BitOR($WS_CHILD, $WS_TABSTOP), $WS_EX_CONTROLPARENT, $Vistumbler)
GUISetBkColor($ControlBackgroundColor)
$100 = GUICtrlCreateLabel('100%', 0, 5, 35, 38)
$90 = GUICtrlCreateLabel('  90%', 0, 44, 35, 38)
$80 = GUICtrlCreateLabel('  80%', 0, 83, 35, 38)
$70 = GUICtrlCreateLabel('  70%', 0, 122, 35, 38)
$60 = GUICtrlCreateLabel('  60%', 0, 161, 35, 38)
$50 = GUICtrlCreateLabel('  50%', 0, 199, 35, 38)
$40 = GUICtrlCreateLabel('  40%', 0, 238, 35, 38)
$30 = GUICtrlCreateLabel('  30%', 0, 277, 35, 38)
$20 = GUICtrlCreateLabel('  20%', 0, 316, 35, 38)
$10 = GUICtrlCreateLabel('  10%', 0, 355, 35, 38)
GUICtrlSetColor($100, $TextColor)
GUICtrlSetColor($90, $TextColor)
GUICtrlSetColor($80, $TextColor)
GUICtrlSetColor($70, $TextColor)
GUICtrlSetColor($60, $TextColor)
GUICtrlSetColor($50, $TextColor)
GUICtrlSetColor($40, $TextColor)
GUICtrlSetColor($30, $TextColor)
GUICtrlSetColor($20, $TextColor)
GUICtrlSetColor($10, $TextColor)

$DataChild = GUICreate("", 895, 595, 0, 60, BitOR($WS_CHILD, $WS_TABSTOP), $WS_EX_CONTROLPARENT, $Vistumbler)
GUISetBkColor($BackgroundColor)

$ListviewAPs = GUICtrlCreateListView($headers, 260, 5, 725, 585, $LVS_REPORT + $LVS_SINGLESEL, $LVS_EX_HEADERDRAGDROP + $LVS_EX_GRIDLINES + $LVS_EX_FULLROWSELECT)
GUICtrlSetBkColor(-1, $ControlBackgroundColor)
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

$TreeviewAPs = GUICtrlCreateTreeView(5, 5, 150, 585)
_GUICtrlTreeView_SetBkColor($TreeviewAPs, $ControlBackgroundColor)
GUISetState()



$ControlChild = GUICreate("", 970, 65, 0, 0, $WS_CHILD, $WS_EX_CONTROLPARENT, $Vistumbler) ; Create Child window for controls
GUISetBkColor($BackgroundColor)
$ScanButton = GUICtrlCreateButton($Text_ScanAPs, 10, 8, 70, 20, 0)
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

GUISetState(@SW_SHOW)

GUISwitch($Vistumbler)
_SetControlSizes()
GUISetState(@SW_SHOW)

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
GUICtrlSetOnEvent($ExitSaveDB, '_ExitSaveDB')
GUICtrlSetOnEvent($ExitVistumbler, '_CloseToggle')
;Edit Menu
GUICtrlSetOnEvent($ClearAll, '_ClearAll')
GUICtrlSetOnEvent($Copy, '_CopyAP')
GUICtrlSetOnEvent($SelectConnected, '_MenuSelectConnectedAp')
GUICtrlSetOnEvent($SortTree, '_SortTree')
;Optons Menu
GUICtrlSetOnEvent($ScanWifiGUI, 'ScanToggle')
GUICtrlSetOnEvent($RefreshMenuButton, '_AutoRefreshToggle')
GUICtrlSetOnEvent($AutoSaveGUI, '_AutoSaveToggle')
GUICtrlSetOnEvent($AutoSortGUI, '_AutoSortToggle')
GUICtrlSetOnEvent($UseWiFiDbGpsLocateButton, '_WifiDbLocateToggle')
GUICtrlSetOnEvent($ShowEstDb, '_ShowDbToggle')
GUICtrlSetOnEvent($PlaySoundOnNewAP, '_SoundToggle')
GUICtrlSetOnEvent($SpeakApSignal, '_SpeakSigToggle')
GUICtrlSetOnEvent($AddNewAPsToTop, '_AddApPosToggle')
GUICtrlSetOnEvent($AutoSaveKML, '_AutoKmlToggle')
GUICtrlSetOnEvent($AutoSelectMenuButton, '_AutoConnectToggle')
GUICtrlSetOnEvent($GraphDeadTimeGUI, '_GraphDeadTimeToggle')
GUICtrlSetOnEvent($MenuSaveGpsWithNoAps, '_SaveGpsWithNoAPsToggle')
GUICtrlSetOnEvent($GUI_MidiActiveAps, '_ActiveApMidiToggle')
GUICtrlSetOnEvent($DebugFunc, '_DebugToggle')
GUICtrlSetOnEvent($GuiUseNativeWifi, '_NativeWifiToggle')
;Export Menu
GUICtrlSetOnEvent($ExportToVS1, '_ExportDetailedData')
GUICtrlSetOnEvent($ExportToFilVS1, '_ExportFilteredDetailedData')
GUICtrlSetOnEvent($ExportToVSZ, '_ExportVSZ')
GUICtrlSetOnEvent($ExportToCsv, '_ExportCsvData')
GUICtrlSetOnEvent($ExportToFilCsv, '_ExportCsvFilteredData')
GUICtrlSetOnEvent($ExportToKML, 'SaveToKML')
GUICtrlSetOnEvent($ExportToFilKML, '_ExportFilteredKML')
GUICtrlSetOnEvent($CreateApSignalMap, '_KmlSignalMapSelectedAP')
GUICtrlSetOnEvent($ExportToGPX, '_SaveToGPX')
GUICtrlSetOnEvent($ExportToNS1, '_ExportNS1')
;View Menu
GUICtrlSetOnEvent($AddRemoveFilters, '_ModifyFilters')
;Settings Menu
GUICtrlSetOnEvent($SetAuto, '_SettingsGUI_Auto')
GUICtrlSetOnEvent($SetAutoKML, '_SettingsGUI_AutoKML')
GUICtrlSetOnEvent($SetMisc, '_SettingsGUI_Misc')
GUICtrlSetOnEvent($SetGPS, '_SettingsGUI_GPS')
GUICtrlSetOnEvent($SetLanguage, '_SettingsGUI_Lan')
GUICtrlSetOnEvent($SetMacManu, '_SettingsGUI_Manu')
GUICtrlSetOnEvent($SetMacLabel, '_SettingsGUI_Lab')
GUICtrlSetOnEvent($SetColumnWidths, '_SettingsGUI_Col')
GUICtrlSetOnEvent($SetSearchWords, '_SettingsGUI_SW')
;Extra Menu
GUICtrlSetOnEvent($GpsDetails, '_OpenGpsDetailsGUI')
GUICtrlSetOnEvent($GpsCompass, '_CompassGUI')
GUICtrlSetOnEvent($OpenSaveFolder, '_OpenSaveFolder')
GUICtrlSetOnEvent($OpenKmlNetworkLink, '_StartGoogleAutoKmlRefresh')
GUICtrlSetOnEvent($ViewInPhilsPHP, '_ViewInPhilsPHP')
GUICtrlSetOnEvent($ViewPhilsWDB, '_AddToYourWDB')
GUICtrlSetOnEvent($LocateInWDB, '_LocatePositionInWiFiDB')
GUICtrlSetOnEvent($UpdateManufacturers, '_ManufacturerUpdate')


;Help Menu
GUICtrlSetOnEvent($VistumblerHome, '_OpenVistumblerHome')
GUICtrlSetOnEvent($VistumblerForum, '_OpenVistumblerForum')
GUICtrlSetOnEvent($VistumblerWiki, '_OpenVistumblerWiki')
GUICtrlSetOnEvent($UpdateVistumbler, '_MenuUpdate')
;Support Vistumbler
GUICtrlSetOnEvent($VistumblerDonate, '_OpenVistumblerDonate')
GUICtrlSetOnEvent($VistumblerStore, '_OpenVistumblerStore')
;Other
GUICtrlSetOnEvent($ListviewAPs, '_SortColumnToggle')

;Set Listview Widths
_SetListviewWidths()

Dim $Authentication_tree = _GUICtrlTreeView_InsertItem($TreeviewAPs, $Column_Names_Authentication)
Dim $channel_tree = _GUICtrlTreeView_InsertItem($TreeviewAPs, $Column_Names_Channel)
Dim $Encryption_tree = _GUICtrlTreeView_InsertItem($TreeviewAPs, $Column_Names_Encryption)
Dim $NetworkType_tree = _GUICtrlTreeView_InsertItem($TreeviewAPs, $Column_Names_NetworkType)
Dim $SSID_tree = _GUICtrlTreeView_InsertItem($TreeviewAPs, $Column_Names_SSID)

If $Recover = 1 Then _RecoverSDB()

If $Load <> '' Then _LoadListGUI($Load)

;-------------------------------------------------------------------------------------------------------------------------------
;                                                       PROGRAM RUNNING LOOP
;-------------------------------------------------------------------------------------------------------------------------------
$UpdatedWiFiDbGPS = 0
$UpdatedGPS = 0
$UpdatedAPs = 0
$UpdatedGraph = 0
$UpdatedAutoKML = 0
$UpdatedCompassPos = 0
$UpdatedGpsDetailsPos = 0
$UpdatedSpeechSig = 0
$begin = TimerInit() ;Start $begin timer, used to measure loop time
$kml_active_timer = TimerInit()
$kml_dead_timer = TimerInit()
$kml_gps_timer = TimerInit()
$kml_track_timer = TimerInit()
$ReleaseMemory_Timer = TimerInit()
$Speech_Timer = TimerInit()
$WiFiDbLocate_Timer = TimerInit()
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
				GUICtrlSetData($GuiLat, $Text_Latitude & ': ' & _GpsFormat($Latitude));Set GPS Latitude in GUI
				GUICtrlSetData($GuiLon, $Text_Longitude & ': ' & _GpsFormat($Longitude));Set GPS Longitude in GUI
			EndIf
			$WiFiDbLocate_Timer = TimerInit()
			$UpdatedWiFiDbGPS = 1
		EndIf
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
				$query = "INSERT INTO GPS(GPSID,Latitude,Longitude,NumOfSats,HorDilPitch,Alt,Geo,SpeedInMPH,SpeedInKmH,TrackAngle,Date1,Time1) VALUES ('" & $GPS_ID & "','" & $Latitude & "','" & $Longitude & "','" & $NumberOfSatalites & "','" & $HorDilPitch & "','" & $Alt & "','" & $Geo & "','" & $SpeedInMPH & "','" & $SpeedInKmH & "','" & $TrackAngle & "','" & $datestamp & "','" & $timestamp & "');"
				_SQLite_Exec($DBhndl, $query)
			EndIf
			;Mark Dead Access Points
			_MarkDeadAPs()
			;Remove APs that do not match the filter
			_FilterRemoveNonMatchingInList()
			;Add APs back into the listview that match but are not there
			_FilterReAddMatchingNotInList()
			;Play Midi Sounds for all active APs (if enabled)
			_PlayMidiForActiveAPs()
		EndIf
		If $ScanResults > 0 Then $UpdateAutoSave = 1
		;Refresh Networks If Enabled
		If $RefreshNetworks = 1 Then _RefreshNetworks()
		;Select connected AP
		If $AutoSelect = 1 And WinActive($Vistumbler) Then _SelectConnectedAp()
	ElseIf $Scan = 0 And $UpdatedAPs <> 1 Then
		$UpdatedAPs = 1
		;Add GPS ID If AP Scanning is off, UseGPS is on, and Save GPS when no AP are active is on
		If $UseGPS = 1 And $SaveGpsWithNoAps = 1 Then
			$GPS_ID += 1

			$query = "INSERT INTO GPS(GPSID,Latitude,Longitude,NumOfSats,HorDilPitch,Alt,Geo,SpeedInMPH,SpeedInKmH,TrackAngle,Date1,Time1) VALUES ('" & $GPS_ID & "','" & $Latitude & "','" & $Longitude & "','" & $NumberOfSatalites & "','" & $HorDilPitch & "','" & $Alt & "','" & $Geo & "','" & $SpeedInMPH & "','" & $SpeedInKmH & "','" & $TrackAngle & "','" & $datestamp & "','" & $timestamp & "');"
			_SQLite_Exec($DBhndl, $query)
		EndIf
		;Mark Dead Access Points
		_MarkDeadAPs()
		;Remove APs that do not match the filter
		_FilterRemoveNonMatchingInList()
		;Add APs back into the listview that match but are not there
		_FilterReAddMatchingNotInList()
	EndIf
	;Resize Controls / Control Resize Monitoring
	_TreeviewListviewResize()

	;Check If Vistumbler Window has moved to tell the graph to redraw
	If _WinMoved() = 1 Then
		_SetControlSizes()
		$Redraw = 1
	EndIf

	;Graph Selected AP
	If $UpdatedGraph <> 1 Then
		$UpdatedGraph = 1
		_GraphApSignal()
	EndIf

	;Speak Signal of selected AP (if enabled)
	If $SpeakSignal = 1 And $Scan = 1 And $UpdatedSpeechSig = 0 And TimerDiff($Speech_Timer) >= $SpeakSigTime Then
		$SpeakSuccess = _SpeakSelectedSignal()
		If $SpeakSuccess = 1 Then
			$UpdatedSpeechSig = 1
			$Speech_Timer = TimerInit()
		EndIf
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

	;Sort Listview (if enabled)
	If $AutoSort = 1 And TimerDiff($sort_timer) >= ($SortTime * 1000) Then _Sort($SortBy)
	If $AutoSave = 1 And $UpdateAutoSave = 1 And TimerDiff($save_timer) >= ($SaveTime * 1000) Then
		_AutoSave()
		$UpdateAutoSave = 0
	EndIf

	;Check Compass Window Position
	If WinActive($CompassGUI) And $CompassOpen = 1 And $UpdatedCompassPos = 0 Then
		$c = _WinGetPosEx($CompassGUI)
		If $c[0] & ',' & $c[1] & ',' & $c[2] & ',' & $c[3] <> $CompassPosition Then $CompassPosition = $c[0] & ',' & $c[1] & ',' & $c[2] & ',' & $c[3] ;If the $CompassGUI has moved or resized, set $CompassPosition to current window size
		$UpdatedCompassPos = 1
	EndIf

	;Check GPS Details Windows Position
	If WinActive($GpsDetailsGUI) And $GpsDetailsOpen = 1 And $UpdatedGpsDetailsPos = 0 Then
		$g = _WinGetPosEx($GpsDetailsGUI)
		If $g[0] & ',' & $g[1] & ',' & $g[2] & ',' & $g[3] <> $GpsDetailsPosition Then $GpsDetailsPosition = $g[0] & ',' & $g[1] & ',' & $g[2] & ',' & $g[3] ;If the $GpsDetails has moved or resized, set $GpsDetailsPosition to current window size
		$UpdatedGpsDetailsPos = 1
	EndIf

	;Flag Actions
	If $Close = 1 Then _ExitVistumbler() ;If the close flag has been set, exit visumbler
	If $SortColumn <> -1 Then _HeaderSort($SortColumn);Sort clicked listview column
	If $ClearAllAps = 1 Then _ClearAllAp();Clear all access points

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
		$UpdatedCompassPos = 0
		$UpdatedGpsDetailsPos = 0
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
	If $UseNativeWifi = 1 Then
		$FoundAPs = 0
		$NewFoundAPs = 0
		$aplist = _Wlan_GetAvailableNetworkList(2, $DefaultApapterID, $wlanhandle)
		;_ArrayDisplay($aplist)
		$aplistsize = UBound($aplist) - 1
		For $add = 0 To $aplistsize
			$RadioType = ''
			$BasicTransferRates = ''
			$OtherTransferRates = ''
			$BSSID = ''
			$Channel = ''
			$SSID = $aplist[$add][0]
			$NetworkType = $aplist[$add][1]
			$Signal = $aplist[$add][3]
			$Authentication = $aplist[$add][4]
			$Encryption = $aplist[$add][5]
			$FoundAPs += 1
			;Add new GPS ID
			If $FoundAPs = 1 Then
				$GPS_ID += 1
				$query = "INSERT INTO GPS(GPSID,Latitude,Longitude,NumOfSats,HorDilPitch,Alt,Geo,SpeedInMPH,SpeedInKmH,TrackAngle,Date1,Time1) VALUES ('" & $GPS_ID & "','" & $Latitude & "','" & $Longitude & "','" & $NumberOfSatalites & "','" & $HorDilPitch & "','" & $Alt & "','" & $Geo & "','" & $SpeedInMPH & "','" & $SpeedInKmH & "','" & $TrackAngle & "','" & $datestamp & "','" & $timestamp & "');"
				_SQLite_Exec($DBhndl, $query)
			EndIf
			;Add new access point
			$NewFound = _AddApData(1, $GPS_ID, $BSSID, $SSID, $Channel, $Authentication, $Encryption, $NetworkType, $RadioType, $BasicTransferRates, $OtherTransferRates, $Signal)
			If $NewFound = 1 Then $NewFoundAPs += 1
		Next
		;Play New AP sound if sounds are enabled
		If $NewFoundAPs <> 0 And $SoundOnAP = 1 Then SoundPlay($SoundDir & $new_AP_sound, 0)
		;Return number of active APs
		Return ($FoundAPs)
	Else
		$NewAP = 0
		$FoundAPs = 0
		$NewFoundAPs = 0
		;Dump data from netsh
		FileDelete($tempfile);delete old temp file
		_RunDOS($netsh & ' wlan show networks mode=bssid interface="' & $DefaultApapter & '" > ' & '"' & $tempfile & '"') ;copy the output of the 'netsh wlan show networks mode=bssid' command to the temp file
		$arrayadded = _FileReadToArray($tempfile, $TempFileArray);read the tempfile into the '$TempFileArray' Array
		;Go through data and pull AP information
		If $arrayadded = 1 Then
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
							$NewSSID = 1
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
							$query = "INSERT INTO GPS(GPSID,Latitude,Longitude,NumOfSats,HorDilPitch,Alt,Geo,SpeedInMPH,SpeedInKmH,TrackAngle,Date1,Time1) VALUES ('" & $GPS_ID & "','" & $Latitude & "','" & $Longitude & "','" & $NumberOfSatalites & "','" & $HorDilPitch & "','" & $Alt & "','" & $Geo & "','" & $SpeedInMPH & "','" & $SpeedInKmH & "','" & $TrackAngle & "','" & $datestamp & "','" & $timestamp & "');"
							_SQLite_Exec($DBhndl, $query)
						EndIf
						;Add new access point
						$NewFound = _AddApData(1, $GPS_ID, $BSSID, $SSID, $Channel, $Authentication, $Encryption, $NetworkType, $RadioType, $BasicTransferRates, $OtherTransferRates, $Signal)
						If $NewFound = 1 Then $NewFoundAPs += 1
					EndIf
				EndIf
			Next
			;Play New AP sound if sounds are enabled
			If $NewFoundAPs <> 0 And $SoundOnAP = 1 Then SoundPlay($SoundDir & $new_AP_sound, 0)
			;Return number of active APs
			Return ($FoundAPs)
		Else
			Return ('-1')
		EndIf
	EndIf
EndFunc   ;==>_ScanAccessPoints

;-------------------------------------------------------------------------------------------------------------------------------
;                                                       ADD DB/LISTVIEW/TREEVIEW FUNCTIONS
;-------------------------------------------------------------------------------------------------------------------------------

Func _AddApData($New, $NewGpsId, $BSSID, $SSID, $CHAN, $AUTH, $ENCR, $NETTYPE, $RADTYPE, $BTX, $OtX, $SIG)
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_AddApData()') ;#Debug Display
	$t = TimerInit()
	$AddedAp = 0
	If $New = 1 And $SIG <> 0 Then
		$AP_Status = $Text_Active
		$AP_StatusNum = 1
		$AP_DisplaySig = $SIG
	Else
		$AP_Status = $Text_Dead
		$AP_StatusNum = 0
		$AP_DisplaySig = '0'
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
		$query = "SELECT ApID, ListRow, HighGpsHistId, LastGpsID, FirstHistID, LastHistID, Active, SecType FROM AP WHERE BSSID = '" & $BSSID & "' And SSID ='" & StringReplace($SSID, "'", "''") & "' And CHAN = '" & StringFormat("%03i", $CHAN) & "' And AUTH = '" & $AUTH & "' And ENCR = '" & $ENCR & "' And RADTYPE = '" & $RADTYPE & "' limit 1"
		$iRval = _SQLite_GetTable2d($DBhndl, $query, $ApMatchArray, $iRows, $iColumns)
		;$ApMatchArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
		$FoundApMatch = $iRows
		If $iRows = 0 Then ;If AP is not found then add it
			$APID += 1
			$HISTID += 1
			$NewApFound = 1
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
			$query = "INSERT INTO Hist(HistID,ApID,GpsID,Signal,Date1,Time1) VALUES ('" & $HISTID & "','" & $APID & "','" & $NewGpsId & "','" & $SIG & "','" & $New_Date & "','" & $New_Time & "');"
			_SQLite_Exec($DBhndl, $query)
			;Add AP Data into the AP table
			$query = "INSERT INTO AP(ApID,ListRow,Active,BSSID,SSID,CHAN,AUTH,ENCR,SECTYPE,NETTYPE,RADTYPE,BTX,OTX,HighGpsHistId,LastGpsID,FirstHistID,LastHistID,MANU,LABEL,Signal) VALUES ('" & $APID & "','" & $ListRow & "','" & $AP_StatusNum & "','" & $BSSID & "','" & StringReplace($SSID, "'", "''") & "','" & StringFormat("%03i", $CHAN) & "','" & $AUTH & "','" & $ENCR & "','" & $SecType & "','" & $NETTYPE & "','" & $RADTYPE & "','" & $BTX & "','" & $OtX & "','" & $DBHighGpsHistId & "','" & $NewGpsId & "','" & $HISTID & "','" & $HISTID & "','" & StringReplace($MANUF, "'", "''") & "','" & StringReplace($LABEL, "'", "''") & "','" & StringFormat("%03i", $SIG) & "');"
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
			$HISTID += 1
			;Set Last Time and First Time
			If $New = 1 Then ;If this is a new access point, use new information
				$ExpLastHistID = $HISTID
				$ExpFirstHistID = ''
				$ExpGpsID = $NewGpsId
				$ExpLastDateTime = $New_DateTime
				$ExpFirstDateTime = ''
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
					$ExpFirstDateTime = ''
					$ExpFirstHistID = ''
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
							$DBLat = ''
							$DBLon = ''
						EndIf
					Else ;If the Old Number of satalites is greater than the new, use the old position
						$DBHighGpsHistId = $Found_HighGpsHistId
						$DBLat = ''
						$DBLon = ''
					EndIf
				EndIf
			Else ;If new lat and lon are not valid, use the old position and do not update lat and lon
				$DBHighGpsHistId = $Found_HighGpsHistId
				$DBLat = ''
				$DBLon = ''
			EndIf
			;If HighGpsHistID is different from the origional, update it
			If $DBHighGpsHistId <> $Found_HighGpsHistId Then
				$query = "UPDATE AP SET HighGpsHistId = '" & $DBHighGpsHistId & "' WHERE ApID = '" & $Found_APID & "'"
				_SQLite_Exec($DBhndl, $query)
			EndIf
			;Update AP in DB. Set Active, LastGpsID, and LastHistID
			$query = "UPDATE AP SET Active = '" & $AP_StatusNum & "', LastGpsID = '" & $ExpGpsID & "', LastHistId = '" & $ExpLastHistID & "',Signal = '" & StringFormat("%03i", $SIG) & "' WHERE ApId = '" & $Found_APID & "'"
			_SQLite_Exec($DBhndl, $query)
			;Update AP in DB. Set FirstHistID
			If $ExpFirstHistID <> '' Then
				$query = "UPDATE AP SET FirstHistId = '" & $ExpFirstHistID & "' WHERE ApId = '" & $Found_APID & "'"
				_SQLite_Exec($DBhndl, $query)
			EndIf
			;Add new history ID
			$query = "INSERT INTO Hist(HistID,ApID,GpsID,Signal,Date1,Time1) VALUES ('" & $HISTID & "','" & $Found_APID & "','" & $NewGpsId & "','" & $SIG & "','" & $New_Date & "','" & $New_Time & "');"
			_SQLite_Exec($DBhndl, $query)
			;Update List information
			If $New = 0 And $Found_Active = 0 Then
				$Exp_AP_Status = ''
				$Exp_AP_DisplaySig = ''
			Else
				$Exp_AP_Status = $AP_Status
				$Exp_AP_DisplaySig = $AP_DisplaySig
			EndIf
			If $Found_ListRow <> -1 Then
				;Update AP Listview data
				_ListViewAdd($Found_ListRow, '', $Exp_AP_Status, '', '', '', '', $Exp_AP_DisplaySig, '', '', '', '', '', $ExpFirstDateTime, $ExpLastDateTime, $DBLat, $DBLon, '', '')
				;Update Signal Icon
				_UpdateIcon($Found_ListRow, $Exp_AP_DisplaySig, $Found_SecType)
			EndIf
		EndIf
	EndIf
	Return ($NewApFound)
EndFunc   ;==>_AddApData

Func _UpdateIcon($ApListRow, $ApSig, $ApSecType)
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
	Local $ApMatchArray, $iRows, $iColumns, $iRval
	$query = "SELECT ApID, ListRow, LastGpsID, SecType FROM AP WHERE Active = '1'"
	$iRval = _SQLite_GetTable2d($DBhndl, $query, $ApMatchArray, $iRows, $iColumns)
	$FoundApMatch = $iRows
	;Set APs Dead in Listview
	For $resetdead = 1 To $FoundApMatch
		$Found_APID = $ApMatchArray[$resetdead][0]
		$Found_ListRow = $ApMatchArray[$resetdead][1]
		$Found_LastGpsID = $ApMatchArray[$resetdead][2]
		$Found_SecType = $ApMatchArray[$resetdead][3]
		;Get Last Time
		Local $GpsMatchArray, $iRows, $iColumns, $iRval
		$query = "SELECT Date1, Time1 FROM GPS WHERE GpsID = '" & $Found_LastGpsID & "' LIMIT 1"
		$iRval = _SQLite_GetTable2d($DBhndl, $query, $GpsMatchArray, $iRows, $iColumns)
		$Found_Date = $GpsMatchArray[1][0]
		$Found_Time = _TimeToSeconds($GpsMatchArray[1][1])
		$Current_Time = _TimeToSeconds($timestamp)
		$Found_dts = StringReplace($Found_Date & $Found_Time, '-', '')
		$Current_dts = StringReplace($datestamp & $Current_Time, '-', '')
		;Set APs that have been inactive for specified time dead
		If ($Current_dts - $Found_dts) > $TimeBeforeMarkedDead Then
			_GUICtrlListView_SetItemText($ListviewAPs, $Found_ListRow, $Text_Dead, $column_Active)
			_GUICtrlListView_SetItemText($ListviewAPs, $Found_ListRow, '0%', $column_Signal)
			If $Found_SecType = 1 Then
				_GUICtrlListView_SetItemImage($ListviewAPs, $Found_ListRow, 0)
			Else
				_GUICtrlListView_SetItemImage($ListviewAPs, $Found_ListRow, 6)
			EndIf



			$query = "UPDATE AP SET Active = '0', Signal = '000' WHERE ApID = '" & $Found_APID & "'"
			_SQLite_Exec($DBhndl, $query)
		EndIf
	Next
	;Update active/total ap label
	$query = "Select COUNT(ApID) FROM AP WHERE Active = '1'"
	_SQLite_QuerySingleRow($DBhndl, $query, $aRow)
	$ActiveCount = $aRow[0]
	;$ActiveCountArray = _RecordSearch($VistumblerDB, $query, $DB_OBJ)
	;$ActiveCount = $ActiveCountArray[1][1]
	GUICtrlSetData($ActiveAPs, $Text_ActiveAPs & ': ' & $ActiveCount & " / " & $APID)
EndFunc   ;==>_MarkDeadAPs

Func _TimeToSeconds($iTime)
	$dts = StringSplit($iTime, ":") ;Split time so it can be converted to seconds
	$rTime = ($dts[1] * 3600) + ($dts[2] * 60) + $dts[3] ;In seconds
	Return ($rTime)
EndFunc   ;==>_TimeToSeconds


Func _ListViewAdd($line, $Add_Line = '', $Add_Active = '', $Add_BSSID = '', $Add_SSID = '', $Add_Authentication = '', $Add_Encryption = '', $Add_Signal = '', $Add_Channel = '', $Add_RadioType = '', $Add_BasicTransferRates = '', $Add_OtherTransferRates = '', $Add_NetworkType = '', $Add_FirstAcvtive = '', $Add_LastActive = '', $Add_LatitudeDMM = '', $Add_LongitudeDMM = '', $Add_MANU = '', $Add_Label = '')
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_ListViewAdd()') ;#Debug Display

	If $Add_LatitudeDMM <> '' And $Add_LongitudeDMM <> '' Then
		$LatDMS = _Format_GPS_DMM_to_DMS($Add_LatitudeDMM)
		$LonDMS = _Format_GPS_DMM_to_DMS($Add_LongitudeDMM)
		$LatDDD = _Format_GPS_DMM_to_DDD($Add_LatitudeDMM)
		$LonDDD = _Format_GPS_DMM_to_DDD($Add_LongitudeDMM)
	Else ;Do nothing (Reset lat,lon variables)
		$LatDMS = ''
		$LonDMS = ''
		$LatDDD = ''
		$LonDDD = ''
	EndIf

	If $Add_Signal <> '' Then
		If $Add_Signal = 0 Or $ShowEstimatedDB = 0 Then
			$AddDb = ''
		Else
			$AddDb = '(' & _EstimateDbFromSignalPercent($Add_Signal) & 'dB)'
		EndIf
	EndIf

	If $Add_Line <> '' Then _GUICtrlListView_SetItemText($ListviewAPs, $line, $Add_Line, $column_Line)
	If $Add_Active <> '' Then _GUICtrlListView_SetItemText($ListviewAPs, $line, $Add_Active, $column_Active)
	If $Add_SSID <> '' Then _GUICtrlListView_SetItemText($ListviewAPs, $line, $Add_SSID, $column_SSID)
	If $Add_BSSID <> '' Then _GUICtrlListView_SetItemText($ListviewAPs, $line, $Add_BSSID, $column_BSSID)
	If $Add_MANU <> '' Then _GUICtrlListView_SetItemText($ListviewAPs, $line, $Add_MANU, $column_MANUF)
	If $Add_Signal <> '' Then _GUICtrlListView_SetItemText($ListviewAPs, $line, $Add_Signal & '% ' & $AddDb, $column_Signal)
	If $Add_Authentication <> '' Then _GUICtrlListView_SetItemText($ListviewAPs, $line, $Add_Authentication, $column_Authentication)
	If $Add_Encryption <> '' Then _GUICtrlListView_SetItemText($ListviewAPs, $line, $Add_Encryption, $column_Encryption)
	If $Add_RadioType <> '' Then _GUICtrlListView_SetItemText($ListviewAPs, $line, $Add_RadioType, $column_RadioType)
	If $Add_Channel <> '' Then _GUICtrlListView_SetItemText($ListviewAPs, $line, Round($Add_Channel), $column_Channel)
	If $LatDDD <> '' Then _GUICtrlListView_SetItemText($ListviewAPs, $line, $LatDDD, $column_Latitude)
	If $LonDDD <> '' Then _GUICtrlListView_SetItemText($ListviewAPs, $line, $LonDDD, $column_Longitude)
	If $LatDMS <> '' Then _GUICtrlListView_SetItemText($ListviewAPs, $line, $LatDMS, $column_LatitudeDMS)
	If $LonDMS <> '' Then _GUICtrlListView_SetItemText($ListviewAPs, $line, $LonDMS, $column_LongitudeDMS)
	If $Add_LatitudeDMM <> '' Then _GUICtrlListView_SetItemText($ListviewAPs, $line, $Add_LatitudeDMM, $column_LatitudeDMM)
	If $Add_LongitudeDMM <> '' Then _GUICtrlListView_SetItemText($ListviewAPs, $line, $Add_LongitudeDMM, $column_LongitudeDMM)
	If $Add_BasicTransferRates <> '' Then _GUICtrlListView_SetItemText($ListviewAPs, $line, $Add_BasicTransferRates, $column_BasicTransferRates)
	If $Add_OtherTransferRates <> '' Then _GUICtrlListView_SetItemText($ListviewAPs, $line, $Add_OtherTransferRates, $column_OtherTransferRates)
	If $Add_NetworkType <> '' Then _GUICtrlListView_SetItemText($ListviewAPs, $line, $Add_NetworkType, $column_NetworkType)
	If $Add_Label <> '' Then _GUICtrlListView_SetItemText($ListviewAPs, $line, $Add_Label, $column_Label)
	If $Add_FirstAcvtive <> '' Then
		$LTD = StringSplit($Add_FirstAcvtive, ' ')
		_GUICtrlListView_SetItemText($ListviewAPs, $line, _DateTimeLocalFormat(_DateTimeUtcConvert($LTD[1], $LTD[2], 0)), $column_FirstActive)
	EndIf
	If $Add_LastActive <> '' Then
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
	$channel_treeviewname = StringFormat("%02i", $ImpCHAN)
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

	Local $TreeMatchArray, $iRows, $iColumns, $iRval
	$query = "SELECT SubTreePos FROM TreeviewPos WHERE RootTree = '" & $RootTree & "' And SubTreeName = '" & StringReplace($SubTreeName, "'", "''") & "' LIMIT 1"
	$iRval = _SQLite_GetTable2d($DBhndl, $query, $TreeMatchArray, $iRows, $iColumns)
	If $iRows = 0 Then
		$treeviewposition = _GUICtrlTreeView_InsertItem($Treeview, $SubTreeName, $tree)
	Else
		$treeviewposition = $TreeMatchArray[1][0]
	EndIf

	$subtreeviewposition = _GUICtrlTreeView_InsertItem($Treeview, '(' & $ImpSSID & ')', $treeviewposition)
	$st_ssid = _GUICtrlTreeView_InsertItem($Treeview, $Column_Names_SSID & ' : ' & $ImpSSID, $subtreeviewposition)
	$st_bssid = _GUICtrlTreeView_InsertItem($Treeview, $Column_Names_BSSID & ' : ' & $ImpBSSID, $subtreeviewposition)
	$st_chan = _GUICtrlTreeView_InsertItem($Treeview, $Column_Names_Channel & ' : ' & $ImpCHAN, $subtreeviewposition)
	$st_net = _GUICtrlTreeView_InsertItem($Treeview, $Column_Names_NetworkType & ' : ' & $ImpNET, $subtreeviewposition)
	$st_encr = _GUICtrlTreeView_InsertItem($Treeview, $Column_Names_Encryption & ' : ' & $ImpENCR, $subtreeviewposition)
	$st_rad = _GUICtrlTreeView_InsertItem($Treeview, $Column_Names_RadioType & ' : ' & $ImpRAD, $subtreeviewposition)
	$st_auth = _GUICtrlTreeView_InsertItem($Treeview, $Column_Names_Authentication & ' : ' & $ImpAUTH, $subtreeviewposition)
	$st_btx = _GUICtrlTreeView_InsertItem($Treeview, $Column_Names_BasicTransferRates & ' : ' & $ImpBTX, $subtreeviewposition)
	$st_otx = _GUICtrlTreeView_InsertItem($Treeview, $Column_Names_OtherTransferRates & ' : ' & $ImpOTX, $subtreeviewposition)
	$st_manu = _GUICtrlTreeView_InsertItem($Treeview, $Column_Names_MANUF & ' : ' & $ImpMANU, $subtreeviewposition)
	$st_lab = _GUICtrlTreeView_InsertItem($Treeview, $Column_Names_Label & ' : ' & $ImpLAB, $subtreeviewposition)
	;Write treeview position information to DB

	$query = "INSERT INTO TreeviewPos(ApID,RootTree,SubTreeName,SubTreePos,InfoSubPos,SsidPos,BssidPos,ChanPos,NetPos,EncrPos,RadPos,AuthPos,BtxPos,OtxPos,ManuPos,LabPos) VALUES ('" & $ImpApID & "','" & $RootTree & "','" & StringReplace($SubTreeName, "'", "''") & "','" & $treeviewposition & "','" & $subtreeviewposition & "','" & $st_ssid & "','" & $st_bssid & "','" & $st_chan & "','" & $st_net & "','" & $st_encr & "','" & $st_rad & "','" & $st_auth & "','" & $st_btx & "','" & $st_otx & "','" & $st_manu & "','" & $st_lab & "');"
	_SQLite_Exec($DBhndl, $query)

EndFunc   ;==>_AddTreeviewItem

Func _TreeViewRemove($ImpApID)
	_RemoveTreeviewItem($TreeviewAPs, 'CHAN', $ImpApID)
	_RemoveTreeviewItem($TreeviewAPs, 'SSID', $ImpApID)
	_RemoveTreeviewItem($TreeviewAPs, 'ENCR', $ImpApID)
	_RemoveTreeviewItem($TreeviewAPs, 'AUTH', $ImpApID)
	_RemoveTreeviewItem($TreeviewAPs, 'NETTYPE', $ImpApID)
EndFunc   ;==>_TreeViewRemove

Func _RemoveTreeviewItem($Treeview, $RootTree, $ImpApID)
	Local $TreeMatchArray, $iRows, $iColumns, $iRval
	$query = "SELECT SubTreePos, InfoSubPos FROM TreeviewPos WHERE ApID = '" & $ImpApID & "' And RootTree = '" & $RootTree & "' LIMIT 1"
	$iRval = _SQLite_GetTable2d($DBhndl, $query, $TreeMatchArray, $iRows, $iColumns)
	$FoundTreeMatch = $iRows
	If $FoundTreeMatch = 1 Then
		$STP = $TreeMatchArray[1][0]
		$ISP = $TreeMatchArray[1][1]
		Local $TreeMatchArray2, $iRows, $iColumns, $iRval
		$query = "SELECT SubTreePos FROM TreeviewPos WHERE ApID <> '" & $ImpApID & "' And SubTreePos = '" & $STP & "' And RootTree = '" & $RootTree & "' LIMIT 1"
		$iRval = _SQLite_GetTable2d($DBhndl, $query, $TreeMatchArray2, $iRows, $iColumns)
		If $iRows = 0 Then _GUICtrlTreeView_Delete(GUICtrlGetHandle($Treeview), $STP)
	EndIf
	$query = "DELETE FROM TreeviewPos WHERE ApID = '" & $ImpApID & "' And RootTree = '" & $RootTree & "'"
	_SQLite_Exec($DBhndl, $query)
EndFunc   ;==>_RemoveTreeviewItem

Func _FilterRemoveNonMatchingInList()
	If StringInStr($RemoveQuery, 'WHERE') Then
		$query = $RemoveQuery & " And (Listrow <> '-1')"
		Local $ApMatchArray, $iRows, $iColumns, $iRval
		$iRval = _SQLite_GetTable2d($DBhndl, $query, $ApMatchArray, $iRows, $iColumns)
		$FoundApMatch = $iRows
		If $FoundApMatch <> 0 Then
			For $frnm = 1 To $FoundApMatch
				$fApID = $ApMatchArray[$frnm][0]
				;Get ListRow of AP
				Local $ListRowArray, $iRows, $iColumns, $iRval
				$query = "Select ListRow FROM AP WHERE ApID='" & $fApID & "'"
				$iRval = _SQLite_GetTable2d($DBhndl, $query, $ListRowArray, $iRows, $iColumns)
				$fListRow = $ListRowArray[1][0]
				_TreeViewRemove($fApID)
				;Delete AP Row
				_GUICtrlListView_DeleteItem(GUICtrlGetHandle($ListviewAPs), $fListRow)
				;Set AP ListRow to -1
				$query = "UPDATE AP SET ListRow='-1' WHERE ApID='" & $fApID & "'"
				_SQLite_Exec($DBhndl, $query)
				;Subtract 1 from all listsrows higher that the one being deleted
				Local $ListRowArray, $iRows, $iColumns, $iRval
				$query = "Select ApID, ListRow FROM AP WHERE ListRow<>'-1'"
				$iRval = _SQLite_GetTable2d($DBhndl, $query, $ListRowArray, $iRows, $iColumns)
				$ListRowMatch = $iRows
				If $ListRowMatch <> 0 Then
					For $lrnu = 1 To $ListRowMatch
						$lApID = $ListRowArray[$lrnu][0]
						$lListRow = $ListRowArray[$lrnu][1]
						If StringFormat("%09i", $lListRow) > StringFormat("%09i", $fListRow) Then
							$nListRow = $lListRow - 1
							$query = "UPDATE AP SET ListRow='" & $nListRow & "' WHERE ApID='" & $lApID & "'"
							_SQLite_Exec($DBhndl, $query)
						EndIf
					Next
					_FixListIcons()
				EndIf
			Next
		EndIf
	EndIf
EndFunc   ;==>_FilterRemoveNonMatchingInList

Func _FilterReAddMatchingNotInList()
	If StringInStr($AddQuery, "WHERE") Then
		$fquery = $AddQuery & " AND ListRow = '-1'"
	Else
		$fquery = $AddQuery & " WHERE ListRow = '-1'"
	EndIf


	Local $LoadApMatchArray, $iRows, $iColumns, $iRval
	$iRval = _SQLite_GetTable2d($DBhndl, $fquery, $LoadApMatchArray, $iRows, $iColumns)

	$FoundLoadApMatch = $iRows
	For $imp = 1 To $FoundLoadApMatch
		$ImpApID = $LoadApMatchArray[$imp][0]
		$ImpSSID = $LoadApMatchArray[$imp][1]
		$ImpBSSID = $LoadApMatchArray[$imp][2]
		$ImpNET = $LoadApMatchArray[$imp][3]
		$ImpRAD = $LoadApMatchArray[$imp][4]
		$ImpCHAN = $LoadApMatchArray[$imp][5]
		$ImpAUTH = $LoadApMatchArray[$imp][6]
		$ImpENCR = $LoadApMatchArray[$imp][7]
		$ImpSecType = $LoadApMatchArray[$imp][8]
		$ImpBTX = $LoadApMatchArray[$imp][9]
		$ImpOTX = $LoadApMatchArray[$imp][10]
		$ImpMANU = $LoadApMatchArray[$imp][11]
		$ImpLAB = $LoadApMatchArray[$imp][12]
		$ImpHighGpsHistID = $LoadApMatchArray[$imp][13]
		$ImpFirstHistID = $LoadApMatchArray[$imp][14]
		$ImpLastHistID = $LoadApMatchArray[$imp][15]
		$ImpLastGpsID = $LoadApMatchArray[$imp][16]
		$ImpActive = $LoadApMatchArray[$imp][17]
		;Get GPS Position
		If $ImpHighGpsHistID = 0 Then
			$ImpLat = 'N 0000.0000'
			$ImpLon = 'E 0000.0000'
		Else
			Local $HistMatchArray, $iRows, $iColumns, $iRval
			$query = "SELECT GpsID FROM Hist WHERE HistID = '" & $ImpHighGpsHistID & "'"
			$iRval = _SQLite_GetTable2d($DBhndl, $query, $HistMatchArray, $iRows, $iColumns)
			$ImpGID = $HistMatchArray[1][0]

			Local $GpsMatchArray, $iRows, $iColumns, $iRval
			$query = "SELECT Latitude, Longitude FROM GPS WHERE GpsID = '" & $ImpGID & "'"
			$iRval = _SQLite_GetTable2d($DBhndl, $query, $GpsMatchArray, $iRows, $iColumns)
			$ImpLat = $GpsMatchArray[1][0]
			$ImpLon = $GpsMatchArray[1][1]
		EndIf
		;Get First Time
		Local $HistMatchArray, $iRows, $iColumns, $iRval
		$query = "SELECT Date1, Time1 FROM Hist WHERE HistID = '" & $ImpFirstHistID & "'"
		$iRval = _SQLite_GetTable2d($DBhndl, $query, $HistMatchArray, $iRows, $iColumns)
		$ImpDate = $HistMatchArray[1][0]
		$ImpTime = $HistMatchArray[1][1]
		$ImpFirstDateTime = $ImpDate & ' ' & $ImpTime
		;Get Last Time
		Local $HistMatchArray, $iRows, $iColumns, $iRval
		$query = "SELECT Date1, Time1, Signal FROM Hist WHERE HistID = '" & $ImpLastHistID & "'"
		$iRval = _SQLite_GetTable2d($DBhndl, $query, $HistMatchArray, $iRows, $iColumns)
		$ImpDate = $HistMatchArray[1][0]
		$ImpTime = $HistMatchArray[1][1]
		$ImpSig = $HistMatchArray[1][2]
		$ImpLastDateTime = $ImpDate & ' ' & $ImpTime
		;If AP is not active, mark as dead and set signal to 0
		If $ImpActive <> 0 And $ImpSig <> 0 Then
			$LActive = $Text_Active
		Else
			$LActive = $Text_Dead
			$ImpSig = '0'
		EndIf

		;Add APs to top of list
		If $AddDirection = 0 Then
			$query = "UPDATE AP SET ListRow = ListRow + 1 WHERE ListRow <> '-1'"
			_SQLite_Exec($DBhndl, $query)
			$DBAddPos = 0
		Else ;Add to bottom
			$DBAddPos = -1
		EndIf
		;Add Into ListView, Set icon color
		If $ImpSig >= 1 And $ImpSig <= 20 Then
			If $ImpSecType = 1 Then
				$ListRow = _GUICtrlListView_InsertItem($ListviewAPs, $ImpApID, $DBAddPos, 1)
			Else
				$ListRow = _GUICtrlListView_InsertItem($ListviewAPs, $ImpApID, $DBAddPos, 7)
			EndIf
		ElseIf $ImpSig >= 21 And $ImpSig <= 40 Then
			If $ImpSecType = 1 Then
				$ListRow = _GUICtrlListView_InsertItem($ListviewAPs, $ImpApID, $DBAddPos, 2)
			Else
				$ListRow = _GUICtrlListView_InsertItem($ListviewAPs, $ImpApID, $DBAddPos, 8)
			EndIf
		ElseIf $ImpSig >= 41 And $ImpSig <= 60 Then
			If $ImpSecType = 1 Then
				$ListRow = _GUICtrlListView_InsertItem($ListviewAPs, $ImpApID, $DBAddPos, 3)
			Else
				$ListRow = _GUICtrlListView_InsertItem($ListviewAPs, $ImpApID, $DBAddPos, 9)
			EndIf
		ElseIf $ImpSig >= 61 And $ImpSig <= 80 Then
			If $ImpSecType = 1 Then
				$ListRow = _GUICtrlListView_InsertItem($ListviewAPs, $ImpApID, $DBAddPos, 4)
			Else
				$ListRow = _GUICtrlListView_InsertItem($ListviewAPs, $ImpApID, $DBAddPos, 10)
			EndIf
		ElseIf $ImpSig >= 81 And $ImpSig <= 100 Then
			If $ImpSecType = 1 Then
				$ListRow = _GUICtrlListView_InsertItem($ListviewAPs, $ImpApID, $DBAddPos, 5)
			Else
				$ListRow = _GUICtrlListView_InsertItem($ListviewAPs, $ImpApID, $DBAddPos, 11)
			EndIf
		Else
			If $ImpSecType = 1 Then
				$ListRow = _GUICtrlListView_InsertItem($ListviewAPs, $ImpApID, $DBAddPos, 0)
			Else
				$ListRow = _GUICtrlListView_InsertItem($ListviewAPs, $ImpApID, $DBAddPos, 6)
			EndIf
		EndIf
		_ListViewAdd($ListRow, $ImpApID, $LActive, $ImpBSSID, $ImpSSID, $ImpAUTH, $ImpENCR, $ImpSig, $ImpCHAN, $ImpRAD, $ImpBTX, $ImpOTX, $ImpNET, $ImpFirstDateTime, $ImpLastDateTime, $ImpLat, $ImpLon, $ImpMANU, $ImpLAB)
		$query = "UPDATE AP SET ListRow='" & $ListRow & "' WHERE ApID='" & $ImpApID & "'"
		_SQLite_Exec($DBhndl, $query)
		;Add Into TreeView
		_TreeViewAdd($ImpApID, $ImpSSID, $ImpBSSID, $ImpCHAN, $ImpNET, $ImpENCR, $ImpRAD, $ImpAUTH, $ImpBTX, $ImpOTX, $ImpMANU, $ImpLAB)
	Next
EndFunc   ;==>_FilterReAddMatchingNotInList

Func _ClearAllAp()
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_ClearAllAp()') ;#Debug Display
	;Reset Variables
	$APID = 0
	$GPS_ID = 0
	$HISTID = 0
	;Clear DB
	$query = "DELETE FROM GPS"
	_SQLite_Exec($DBhndl, $query)
	$query = "DELETE FROM AP"
	_SQLite_Exec($DBhndl, $query)
	$query = "DELETE FROM Hist"
	_SQLite_Exec($DBhndl, $query)
	$query = "DELETE FROM TreeviewPos"
	_SQLite_Exec($DBhndl, $query)
	$query = "DELETE FROM LoadedFiles"
	_SQLite_Exec($DBhndl, $query)
	;Clear Listview
	GUISwitch($DataChild)
	_GetListviewWidths()
	GUICtrlDelete($ListviewAPs)
	$ListviewAPs = GUICtrlCreateListView($headers, $ListviewAPs_left, $ListviewAPs_top, $ListviewAPs_width, $ListviewAPs_height, $LVS_REPORT + $LVS_SINGLESEL, $LVS_EX_HEADERDRAGDROP + $LVS_EX_GRIDLINES + $LVS_EX_FULLROWSELECT)
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
	GUICtrlSetBkColor(-1, $ControlBackgroundColor)
	_SetListviewWidths()
	GUICtrlSetOnEvent($ListviewAPs, '_SortColumnToggle')
	GUISwitch($Vistumbler)
	_SetControlSizes()
	;Clear Treeview
	_GUICtrlTreeView_DeleteChildren($TreeviewAPs, $Authentication_tree)
	_GUICtrlTreeView_DeleteChildren($TreeviewAPs, $channel_tree)
	_GUICtrlTreeView_DeleteChildren($TreeviewAPs, $Encryption_tree)
	_GUICtrlTreeView_DeleteChildren($TreeviewAPs, $NetworkType_tree)
	_GUICtrlTreeView_DeleteChildren($TreeviewAPs, $SSID_tree)
	$ClearAllAps = 0
	$Redraw = 1
EndFunc   ;==>_ClearAllAp

Func _FixLineNumbers();Update Listview Row Numbers in DataArray
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_FixLineNumbers()') ;#Debug Display
	$ListViewSize = _GUICtrlListView_GetItemCount($ListviewAPs) - 1; Get List Size
	For $lisviewrow = 0 To $ListViewSize
		$APNUM = _GUICtrlListView_GetItemText($ListviewAPs, $lisviewrow, $column_Line)
		$query = "UPDATE AP SET ListRow = '" & $lisviewrow & "' WHERE ApId = '" & $APNUM & "'"
		_SQLite_Exec($DBhndl, $query)
	Next
EndFunc   ;==>_FixLineNumbers

Func _FixListIcons()
	Local $ApMatchArray, $iRows, $iColumns, $iRval
	$query = "SELECT ListRow, SecType, Signal FROM AP WHERE ListRow <> '-1'"
	$iRval = _SQLite_GetTable2d($DBhndl, $query, $ApMatchArray, $iRows, $iColumns)
	$FoundApMatch = $iRows
	;Update in Listview
	For $resetdead = 1 To $FoundApMatch
		$Found_ListRow = $ApMatchArray[$resetdead][0]
		$Found_SecType = $ApMatchArray[$resetdead][1]
		$Found_Signal = $ApMatchArray[$resetdead][2]
		_UpdateIcon($Found_ListRow, $Found_Signal, $Found_SecType)
	Next
EndFunc   ;==>_FixListIcons

Func _RecoverSDB()
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_RecoverSDB()') ;#Debug Display
	GUICtrlSetData($msgdisplay, $Text_RecoveringMDB)
	;Reset all listview positions in DB
	$query = "UPDATE AP SET ListRow = '-1', Active = '0', Signal = '000'"
	_SQLite_Exec($DBhndl, $query)
	;Get total APIDs
	Local $ApMatchArray, $iRows, $iColumns, $iRval
	$query = "SELECT ApID FROM AP"
	$iRval = _SQLite_GetTable2d($DBhndl, $query, $ApMatchArray, $iRows, $iColumns)
	$APID = $iRows
	;Delete all old treeview information
	$query = "DELETE FROM TreeviewPos"
	_SQLite_Exec($DBhndl, $query)
	;Add APs into Listview and Treeview
	_FilterReAddMatchingNotInList()
	;Sort
	If $AddDirection = 0 Then
		$v_sort = True;set ascending
	Else
		$v_sort = False;set descending
	EndIf
	_GUICtrlListView_SimpleSort($ListviewAPs, $v_sort, $column_Line)
	;Update Labels and Manufacturers
	_UpdateListMacLabels()
	GUICtrlSetData($msgdisplay, '')
EndFunc   ;==>_RecoverSDB

Func _SetUpDbTables($dbfile)
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_SetUpDbTables()') ;#Debug Display
	$DBhndl = _SQLite_Open($dbfile, $SQLITE_OPEN_READWRITE + $SQLITE_OPEN_CREATE, $SQLITE_ENCODING_UTF16)
	_SQLite_Exec($DBhndl, "pragma synchronous=0");Speed vs Data security. Speed Wins for now.
	_SQLite_Exec($DBhndl, "CREATE TABLE GPS (GPSID,Latitude,Longitude,NumOfSats,HorDilPitch,Alt,Geo,SpeedInMPH,SpeedInKmH,TrackAngle,Date1,Time1)")
	_SQLite_Exec($DBhndl, "CREATE TABLE AP (ApID,ListRow,Active,BSSID,SSID,CHAN,AUTH,ENCR,SECTYPE,NETTYPE,RADTYPE,BTX,OTX,HighGpsHistId,LastGpsID,FirstHistID,LastHistID,MANU,LABEL,Signal)")
	_SQLite_Exec($DBhndl, "CREATE TABLE Hist (HistID,ApID,GpsID,Signal,Date1,Time1)")
	_SQLite_Exec($DBhndl, "CREATE TABLE TreeviewPos (ApID,RootTree,SubTreeName,SubTreePos,InfoSubPos,SsidPos,BssidPos,ChanPos,NetPos,EncrPos,RadPos,AuthPos,BtxPos,OtxPos,ManuPos,LabPos)")
	_SQLite_Exec($DBhndl, "CREATE TABLE LoadedFiles (File,MD5)")
	#comments-start
		_CreateDB($dbfile)
		_AccessConnectConn($dbfile, $DB_OBJ)
		_CreateTable($dbfile, 'GPS', $DB_OBJ)
		_CreateTable($dbfile, 'AP', $DB_OBJ)
		_CreateTable($dbfile, 'Hist', $DB_OBJ)
		_CreateTable($dbfile, 'TreeviewPos', $DB_OBJ)
		_CreateTable($dbfile, 'LoadedFiles', $DB_OBJ)
		_CreateTable($VistumblerDB, "Graph", $DB_OBJ)
		_CreateTable($VistumblerDB, "Graph_Temp", $DB_OBJ)
		_CreatMultipleFields($dbfile, 'GPS', $DB_OBJ, 'GPSID TEXT(255)|Latitude TEXT(20)|Longitude TEXT(20)|NumOfSats TEXT(2)|HorDilPitch TEXT(255)|Alt TEXT(255)|Geo TEXT(255)|SpeedInMPH TEXT(255)|SpeedInKmH TEXT(255)|TrackAngle TEXT(255)|Date1 TEXT(50)|Time1 TEXT(50)')
		_CreatMultipleFields($dbfile, 'AP', $DB_OBJ, 'ApID TEXT(255)|ListRow TEXT(255)|Active TEXT(1)|BSSID TEXT(20)|SSID TEXT(255)|CHAN TEXT(3)|AUTH TEXT(20)|ENCR TEXT(20)|SECTYPE TEXT(1)|NETTYPE TEXT(20)|RADTYPE TEXT(20)|BTX TEXT(100)|OTX TEXT(100)|HighGpsHistId TEXT(100)|LastGpsID TEXT(100)|FirstHistID TEXT(100)|LastHistID TEXT(100)|MANU TEXT(100)|LABEL TEXT(100)|Signal TEXT(3)')
		_CreatMultipleFields($dbfile, 'Hist', $DB_OBJ, 'HistID TEXT(255)|ApID TEXT(255)|GpsID TEXT(255)|Signal TEXT(3)|Date1 TEXT(50)|Time1 TEXT(50)')
		_CreatMultipleFields($dbfile, 'TreeviewPos', $DB_OBJ, 'ApID TEXT(255)|RootTree TEXT(255)|SubTreeName TEXT(255)|SubTreePos TEXT(255)|InfoSubPos TEXT(255)|SsidPos TEXT(255)|BssidPos TEXT(255)|ChanPos TEXT(255)|NetPos TEXT(255)|EncrPos TEXT(255)|RadPos TEXT(255)|AuthPos TEXT(255)|BtxPos TEXT(255)|OtxPos TEXT(255)|ManuPos TEXT(255)|LabPos TEXT(255)')
		_CreatMultipleFields($dbfile, 'LoadedFiles', $DB_OBJ, 'File TEXT(255)|MD5 TEXT(255)')
	#comments-end
EndFunc   ;==>_SetUpDbTables

;-------------------------------------------------------------------------------------------------------------------------------
;                                                       MANUFACTURER/LABEL FUNCTIONS
;-------------------------------------------------------------------------------------------------------------------------------

Func _FindManufacturer($findmac);Returns Manufacturer for given Mac Address
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_FindManufacturer()') ;#Debug Display
	$findmac = StringReplace($findmac, ':', '')
	If StringLen($findmac) <> 6 Then $findmac = StringTrimRight($findmac, StringLen($findmac) - 6)
	Local $ManuMatchArray, $iRows, $iColumns, $iRval
	$query = "SELECT Manufacturer FROM Manufacturers WHERE BSSID = '" & $findmac & "'"
	$iRval = _SQLite_GetTable2d($ManuDBhndl, $query, $ManuMatchArray, $iRows, $iColumns)
	$FoundManuMatch = $iRows
	If $FoundManuMatch = 0 Then
		Return ($Text_Unknown)
	Else
		$Manu = $ManuMatchArray[1][0]
		Return ($Manu)
	EndIf
EndFunc   ;==>_FindManufacturer

Func _SetLabels($findmac);Returns Label for given Mac Address
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_SetLabels()') ;#Debug Display
	$findmac = StringReplace($findmac, ':', '')
	Local $LabMatchArray, $iRows, $iColumns, $iRval
	$query = "SELECT Label FROM Labels WHERE BSSID = '" & $findmac & "'"
	$iRval = _SQLite_GetTable2d($LabDBhndl, $query, $LabMatchArray, $iRows, $iColumns)
	$FoundLabMatch = $iRows
	If $FoundLabMatch = 0 Then
		Return ($Text_Unknown)
	Else
		$LABEL = $LabMatchArray[1][0]
		Return ($LABEL)
	EndIf
EndFunc   ;==>_SetLabels

Func _UpdateListMacLabels()
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_UpdateListMacLabels()') ;#Debug Display
	Local $ApMatchArray, $iRows, $iColumns, $iRval
	$query = "SELECT BSSID, MANU, LABEL, ListRow, ApID FROM AP"
	$iRval = _SQLite_GetTable2d($DBhndl, $query, $ApMatchArray, $iRows, $iColumns)
	$FoundApMatch = $iRows
	For $up = 1 To $FoundApMatch
		$Found_BSSID = $ApMatchArray[$up][0]
		$Found_MANU = $ApMatchArray[$up][1]
		$Found_LAB = $ApMatchArray[$up][2]
		$Found_ListRow = $ApMatchArray[$up][3]
		$Found_APID = $ApMatchArray[$up][4]
		$New_MANU = _FindManufacturer($Found_BSSID)
		$New_LAB = _SetLabels($Found_BSSID)
		;Set Manufacturer
		If $Found_MANU <> $New_MANU Then
			_GUICtrlListView_SetItemText($ListviewAPs, $Found_ListRow, $New_MANU, $column_MANUF)
			$query = "UPDATE AP SET MANU = '" & $New_MANU & "' WHERE ApID = '" & $Found_APID & "'"
			_SQLite_Exec($DBhndl, $query)
		EndIf
		;Set Label
		If $Found_LAB <> $New_LAB Then
			_GUICtrlListView_SetItemText($ListviewAPs, $Found_ListRow, $New_LAB, $column_Label)
			$query = "UPDATE AP SET LABEL = '" & $New_LAB & "' WHERE ApID = '" & $Found_APID & "'"
			_SQLite_Exec($DBhndl, $query)
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
	GUISetState(@SW_HIDE, $Vistumbler)
	_SQLite_Close($DBhndl)
	_SQLite_Close($ManuDBhndl)
	_SQLite_Close($LabDBhndl)
	_SQLite_Close($InstDBhndl)
	_WriteINI(); Write current settings to back to INI file
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
	If $SaveDbOnExit <> 1 Then FileDelete($VistumblerDB)
	If $AutoSaveDel = 1 Then FileDelete($AutoSaveFile)
	If $UseGPS = 1 Then ;If GPS is active, stop it so the COM port does not stay open
		_TurnOffGPS()
		Exit
	Else
		Exit
	EndIf
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
		$save_timer = TimerInit()
		;Refresh Wireless networks
		_Wlan_Scan($DefaultApapterID, $wlanhandle)
	EndIf
EndFunc   ;==>ScanToggle

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
	If $Graph = 1 Then
		_DeletePens()
		_DrawingShutDown($GraphicGUI)
		$Graph = 0
		GUICtrlSetData($GraphButton1, $Text_Graph1)
		GUISwitch($Vistumbler)
		GUISetState(@SW_HIDE, $GraphicGUI)
	ElseIf $Graph = 2 Then
		$Graph = 1
		GUISwitch($ControlChild)
		GUICtrlSetData($GraphButton1, $Text_NoGraph)
		GUICtrlSetData($GraphButton2, $Text_Graph2)
		GUISwitch($Vistumbler)
	ElseIf $Graph = 0 Then
		_DrawingStartUp($GraphicGUI)
		_CreatePens()
		$Graph = 1
		GUICtrlSetData($GraphButton1, $Text_NoGraph)
		GUISwitch($Vistumbler)
		GUISetState(@SW_SHOW, $GraphicGUI)
	EndIf
	_SetControlSizes()
	$Redraw = 1
EndFunc   ;==>_GraphToggle

Func _GraphToggle2(); Graph2 Button
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_GraphToggle2()') ;#Debug Display
	If $Graph = 2 Then
		_DeletePens()
		_DrawingShutDown($GraphicGUI)
		$Graph = 0
		GUICtrlSetData($GraphButton2, $Text_Graph2)
		GUISwitch($Vistumbler)
		GUISetState(@SW_HIDE, $GraphicGUI)
	ElseIf $Graph = 1 Then
		$Graph = 2
		GUISwitch($ControlChild)
		GUICtrlSetData($GraphButton2, $Text_NoGraph)
		GUICtrlSetData($GraphButton1, $Text_Graph1)
		GUISwitch($Vistumbler)
	ElseIf $Graph = 0 Then
		_DrawingStartUp($GraphicGUI)
		_CreatePens()
		$Graph = 2
		GUICtrlSetData($GraphButton2, $Text_NoGraph)
		GUISwitch($Vistumbler)
		GUISetState(@SW_SHOW, $GraphicGUI)
	EndIf
	_SetControlSizes()
	$Redraw = 1
EndFunc   ;==>_GraphToggle2

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

Func _SortColumnToggle(); Sets the ap list column header that was clicked
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_SortColumnToggle()') ;#Debug Display
	$SortColumn = GUICtrlGetState($ListviewAPs)
EndFunc   ;==>_SortColumnToggle

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

Func _AutoSaveToggle();Turns auto save on or off
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_AutoSaveToggle()') ;#Debug Display
	If $AutoSave = 1 Then
		GUICtrlSetState($AutoSaveGUI, $GUI_UNCHECKED)
		$AutoSave = 0
	Else
		GUICtrlSetState($AutoSaveGUI, $GUI_CHECKED)
		$AutoSave = 1
	EndIf
EndFunc   ;==>_AutoSaveToggle

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
		GUICtrlSetState($UseWiFiDbGpsLocateButton, $GUI_CHECKED)
		$UseWiFiDbGpsLocate = 1
	EndIf
EndFunc   ;==>_WifiDbLocateToggle

Func _ShowDbToggle();Turns Estimated DB value on or off
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_ShowDbToggle()') ;#Debug Display
	If $ShowEstimatedDB = 1 Then
		GUICtrlSetState($ShowEstDb, $GUI_UNCHECKED)
		$ShowEstimatedDB = 0
	Else
		GUICtrlSetState($ShowEstDb, $GUI_CHECKED)
		$ShowEstimatedDB = 1
	EndIf
EndFunc   ;==>_ShowDbToggle

Func _ResetSizes()
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_ResetSizes()') ;#Debug Display
	$ResetSizes = 1
EndFunc   ;==>_ResetSizes

Func _ClearAll();Clear all APs
	$ClearAllAps = 1
EndFunc   ;==>_ClearAll

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
	_DrawCompassLine($TrackAngle)

	If $TurnOffGPS = 1 Then _TurnOffGPS()

	Return ($return)
EndFunc   ;==>_GetGPS

Func _FormatGpsTime($time)
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_FormatGpsTime()') ;#Debug Display
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
		ConsoleWrite($data & @CRLF)
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
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_GPRMC()') ;#Debug Display
	GUICtrlSetData($msgdisplay, $data)
	If _CheckGpsChecksum($data) = 1 Then
		ConsoleWrite($data & @CRLF)
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
	$return = '0000.0000'
	$splitlatlon1 = StringSplit($gps, " ");Split N,S,E,W from data
	If $splitlatlon1[0] = 2 Then
		$splitlatlon2 = StringSplit(StringFormat("%0.4f", $splitlatlon1[2]), ".");Split dd from data
		$ls = StringFormat("%04i", $splitlatlon2[1])
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

Func _Format_GPS_All_to_DMM($gps);converts dd.ddddddd, 'dd° mm' ss", or ddmm.mmmm to ddmm.mmmm
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
	If $GPSformat = 1 Then $return = _Format_GPS_DMM_to_DDD($gps)
	If $GPSformat = 2 Then $return = _Format_GPS_DMM_to_DMS($gps)
	If $GPSformat = 3 Then $return = $gps
	Return ($return)
EndFunc   ;==>_GpsFormat

;-------------------------------------------------------------------------------------------------------------------------------
;                                                       GPS COMPASS GUI FUNCTIONS
;-------------------------------------------------------------------------------------------------------------------------------

Func _CompassGUI()
	If $CompassOpen = 0 Then
		$CompassGUI = GUICreate($Text_GpsCompass, 130, 130, -1, -1, BitOR($WS_OVERLAPPEDWINDOW, $WS_CLIPSIBLINGS))
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
			$c = _WinGetPosEx($CompassGUI)
			$CompassPosition = $c[0] & ',' & $c[1] & ',' & $c[2] & ',' & $c[3]
		EndIf
		_SetCompassSizes()

		$CompassOpen = 1
	EndIf ;==>_CompassGUI
EndFunc   ;==>_CompassGUI

Func _CloseCompassGui();closes the compass window
	_GDIPlus_GraphicsDispose($CompassGraphic)
	_GDIPlus_Shutdown()
	GUIDelete($CompassGUI)
	$CompassOpen = 0
EndFunc   ;==>_CloseCompassGui

Func _SetCompassSizes();Takes the size of a hidden label in the compass window and determines the Width/Height of the compass
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
	$hBrush = _GDIPlus_BrushCreateSolid($CompassColor) ;red
	_GDIPlus_GraphicsFillEllipse($CompassGraphic, 15, 15, $CompassHeight, $CompassHeight, $hBrush)
EndFunc   ;==>_SetCompassSizes

Func _DrawCompassLine($Degree);Draws compass in GPS Details GUI
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_DrawCompassLine()') ;#Debug Display
	If $CompassOpen = 1 Then
		_SetCompassSizes()
		$Radius = ($CompassHeight / 2) - 1
		$CenterX = ($CompassHeight / 2) + 15
		$CenterY = ($CompassHeight / 2) + 15

		;Calculate (X, Y) based on Degrees, Radius, And Center of circle (X, Y)
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
		_GDIPlus_GraphicsDrawLine($CompassGraphic, $CenterX, $CenterY, $CircleX, $CircleY)
		;Draw Compass
		;GUICtrlSetGraphic($CompassGraphic, $GUI_GR_ELLIPSE, 1, 1, $CompassHeight - 2, $CompassHeight - 2);Draw compass cicle
		GUICtrlSetGraphic($CompassGraphic, $GUI_GR_MOVE, $CenterX, $CenterY);Move to center of the circle
		GUICtrlSetGraphic($CompassGraphic, $GUI_GR_LINE, $CircleX, $CircleY);Draw line from center to calculated point
		GUICtrlSetGraphic($CompassGraphic, $GUI_GR_REFRESH);Show changes
		;GUISwitch($Vistumbler)
	EndIf
EndFunc   ;==>_DrawCompassLine

;-------------------------------------------------------------------------------------------------------------------------------
;                                                       GPS DETAILS GUI FUNCTIONS
;-------------------------------------------------------------------------------------------------------------------------------

Func _OpenGpsDetailsGUI();Opens GPS Details GUI
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_OpenGpsDetailsGUI()') ;#Debug Display
	If $GpsDetailsOpen = 0 Then
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
		If $gpsplit[0] = 4 Then ;If $CompassPosition is a proper position, move and resize window
			WinMove($GpsDetailsGUI, '', $gpsplit[1], $gpsplit[2], $gpsplit[3], $gpsplit[4])
		Else ;Set $CompassPosition to the current window position
			$g = _WinGetPosEx($GpsDetailsGUI)
			$GpsDetailsPosition = $g[0] & ',' & $g[1] & ',' & $g[2] & ',' & $g[3]
		EndIf

		$GpsDetailsOpen = 1
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
	GUICtrlSetData($msgdisplay, $Text_SecondsSinceGpsUpdate & ": GPGGA:" & Round(TimerDiff($GPGGA_Update) / 1000) & " / " & ($GpsTimeout / 1000) & " - " & "GPRMC:" & Round(TimerDiff($GPRMC_Update) / 1000) & " / " & ($GpsTimeout / 1000))
	If Round(TimerDiff($GPGGA_Update)) > $GpsTimeout Then
		$FixTime = ''
		$Latitude = 'N 0000.0000'
		$Longitude = 'E 0000.0000'
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

Func _HeaderSort($column);Sort a column in ap list
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_HeaderSort()') ;#Debug Display
	GUICtrlSetData($msgdisplay, $Text_SortingList)
	If $Direction[$column] = 0 Then
		Dim $v_sort = False;set descending
	Else
		Dim $v_sort = True;set ascending
	EndIf
	If $Direction[$column] = 0 Then
		$Direction[$column] = 1
	Else
		$Direction[$column] = 0
	EndIf
	_GUICtrlListView_SimpleSort($ListviewAPs, $v_sort, $column)
	_FixLineNumbers()
	_FixListIcons()
	$SortColumn = -1
	GUICtrlSetData($msgdisplay, '')
EndFunc   ;==>_HeaderSort

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

Func _Sort($Sort);Auto Sort based on a user chosen column
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_Sort()') ;#Debug Display
	GUICtrlSetData($msgdisplay, $Text_SortingList)
	If $SortDirection = 1 Then
		Dim $v_sort = False;set ascending
	Else
		Dim $v_sort = True;set descending
	EndIf

	If $Sort = $Column_Names_SSID Then
		_GUICtrlListView_SimpleSort($ListviewAPs, $v_sort, $column_SSID)
	ElseIf $Sort = $Column_Names_NetworkType Then
		_GUICtrlListView_SimpleSort($ListviewAPs, $v_sort, $column_NetworkType)
	ElseIf $Sort = $Column_Names_Authentication Then
		_GUICtrlListView_SimpleSort($ListviewAPs, $v_sort, $column_Authentication)
	ElseIf $Sort = $Column_Names_Encryption Then
		_GUICtrlListView_SimpleSort($ListviewAPs, $v_sort, $column_Encryption)
	ElseIf $Sort = $Column_Names_BSSID Then
		_GUICtrlListView_SimpleSort($ListviewAPs, $v_sort, $column_BSSID)
	ElseIf $Sort = $Column_Names_Signal Then
		_GUICtrlListView_SimpleSort($ListviewAPs, $v_sort, $column_Signal)
	ElseIf $Sort = $Column_Names_RadioType Then
		_GUICtrlListView_SimpleSort($ListviewAPs, $v_sort, $column_RadioType)
	ElseIf $Sort = $Column_Names_Channel Then
		_GUICtrlListView_SimpleSort($ListviewAPs, $v_sort, $column_Channel)
	ElseIf $Sort = $Column_Names_BasicTransferRates Then
		_GUICtrlListView_SimpleSort($ListviewAPs, $v_sort, $column_BasicTransferRates)
	ElseIf $Sort = $Column_Names_OtherTransferRates Then
		_GUICtrlListView_SimpleSort($ListviewAPs, $v_sort, $column_OtherTransferRates)
	ElseIf $Sort = $Column_Names_Latitude Then
		_GUICtrlListView_SimpleSort($ListviewAPs, $v_sort, $column_Longitude)
	ElseIf $Sort = $Column_Names_Longitude Then
		_GUICtrlListView_SimpleSort($ListviewAPs, $v_sort, $column_Latitude)
	ElseIf $Sort = $Column_Names_LatitudeDMS Then
		_GUICtrlListView_SimpleSort($ListviewAPs, $v_sort, $column_LongitudeDMS)
	ElseIf $Sort = $Column_Names_LongitudeDMS Then
		_GUICtrlListView_SimpleSort($ListviewAPs, $v_sort, $column_LatitudeDMS)
	ElseIf $Sort = $Column_Names_LatitudeDMM Then
		_GUICtrlListView_SimpleSort($ListviewAPs, $v_sort, $column_LongitudeDMM)
	ElseIf $Sort = $Column_Names_LongitudeDMM Then
		_GUICtrlListView_SimpleSort($ListviewAPs, $v_sort, $column_LatitudeDMM)
	ElseIf $Sort = $Column_Names_FirstActive Then
		_GUICtrlListView_SimpleSort($ListviewAPs, $v_sort, $column_FirstActive)
	ElseIf $Sort = $Column_Names_LastActive Then
		_GUICtrlListView_SimpleSort($ListviewAPs, $v_sort, $column_LastActive)
	ElseIf $Sort = $Column_Names_Active Then
		_GUICtrlListView_SimpleSort($ListviewAPs, $v_sort, $column_Active)
	ElseIf $Sort = $Column_Names_MANUF Then
		_GUICtrlListView_SimpleSort($ListviewAPs, $v_sort, $column_MANUF)
	EndIf
	_FixLineNumbers()
	_FixListIcons()
	$sort_timer = TimerInit()
EndFunc   ;==>_Sort

;-------------------------------------------------------------------------------------------------------------------------------
;                                                       WINDOW FUNCTIONS
;-------------------------------------------------------------------------------------------------------------------------------

Func _WinMoved();Checks if window has moved. Returns 1 if it has
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_WinMoved()') ;#Debug Display
	$a = _WinGetPosEx($Vistumbler)
	$winpos_old = $winpos
	$winpos = $a[0] & $a[1] & $a[2] & $a[3] & WinGetState($title, "")

	If $winpos_old <> $winpos Then
		;Set window state and position
		$winstate = WinGetState($title, "")
		If BitAND($winstate, 32) Then;Set
			$VistumblerState = "Maximized"
		Else
			$VistumblerState = "Window"
			$VistumblerPosition = $a[0] & ',' & $a[1] & ',' & $a[2] & ',' & $a[3]
		EndIf
		Return 1 ;Set Flag that window moved
	Else
		Return 0 ;Set Flag that window did not move
	EndIf
EndFunc   ;==>_WinMoved

Func _SetControlSizes();Sets control positions in GUI based on the windows current size
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_SetControlSizes()') ;#Debug Display
	$a = _WinGetPosEx($Vistumbler)
	WinMove($DataChild, "", 0, 60, $a[2] - 10, $a[3] - 115)
	$b = _WinGetPosEx($DataChild) ;get child window size
	$sizes = $a[0] & '-' & $a[1] & '-' & $a[2] & '-' & $a[3] & '-' & $b[0] & '-' & $b[1] & '-' & $b[2] & '-' & $b[3]
	If $sizes <> $sizes_old Or $Graph <> $Graph_old Then
		$DataChild_Width = $b[2]
		$DataChild_Height = $b[3]
		If $Graph <> 0 Then
			$Graphic_left = ($b[2] * 0.01)
			$Graphic_width = Round(($b[2] * 0.99) - $Graphic_left)
			$Graphic_top = ($b[3] * 0.01) + 10
			$Graphic_height = Round(($b[3] * $SplitHeightPercent) - $Graphic_top)

			$ListviewAPs_left = ($b[2] * 0.01)
			$ListviewAPs_width = Round(($b[2] * 0.99) - $ListviewAPs_left)
			$ListviewAPs_top = ($b[3] * $SplitHeightPercent) + 1
			$ListviewAPs_height = Round(($b[3] * 0.99) - $ListviewAPs_top)

			GUICtrlSetPos($ListviewAPs, $ListviewAPs_left, $ListviewAPs_top, $ListviewAPs_width, $ListviewAPs_height)
			GUICtrlSetState($TreeviewAPs, $GUI_HIDE)
			WinMove($GraphicGUI, "", $Graphic_left, $Graphic_top + 60, $Graphic_width, $Graphic_height)
			GUICtrlSetState($ListviewAPs, $GUI_FOCUS)
		Else
			$TreeviewAPs_left = ($b[2] * 0.01)
			$TreeviewAPs_width = ($b[2] * $SplitPercent) - $TreeviewAPs_left
			$TreeviewAPs_top = ($b[3] * 0.01)
			$TreeviewAPs_height = ($b[3] * 0.99) - $TreeviewAPs_top

			$ListviewAPs_left = ($b[2] * $SplitPercent) + 1
			$ListviewAPs_width = ($b[2] * 0.99) - $ListviewAPs_left
			$ListviewAPs_top = ($b[3] * 0.01)
			$ListviewAPs_height = ($b[3] * 0.99) - $ListviewAPs_top

			GUICtrlSetPos($ListviewAPs, $ListviewAPs_left, $ListviewAPs_top, $ListviewAPs_width, $ListviewAPs_height)
			GUICtrlSetPos($TreeviewAPs, $TreeviewAPs_left, $TreeviewAPs_top, $TreeviewAPs_width, $TreeviewAPs_height)
			GUICtrlSetState($TreeviewAPs, $GUI_SHOW)
			GUICtrlSetState($ListviewAPs, $GUI_FOCUS)
		EndIf
		$sizes_old = $sizes
		$Graph_old = $Graph
	EndIf
EndFunc   ;==>_SetControlSizes

Func _TreeviewListviewResize()
	$cursorInfo = GUIGetCursorInfo($Vistumbler)
	If $Graph = 0 Then
		If WinActive($Vistumbler) And $cursorInfo[0] > $TreeviewAPs_left + $TreeviewAPs_width - 5 And $cursorInfo[0] < $TreeviewAPs_left + $TreeviewAPs_width + 5 And $cursorInfo[1] > ($TreeviewAPs_top + 60) And $cursorInfo[1] < ($TreeviewAPs_top + 60) + $TreeviewAPs_height And $MoveMode = False Then
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
			GUICtrlSetPos($TreeviewAPs, $TreeviewAPs_left, $TreeviewAPs_top, $TreeviewAPs_width, $TreeviewAPs_height); resize treeview
			;_WinAPI_MoveWindow($TreeviewAPs, $TreeviewAPs_left, $TreeviewAPs_top, $TreeviewAPs_width, $TreeviewAPs_height)
			$ListviewAPs_left = $TreeviewAPs_left + $TreeviewAPs_width + 1
			$ListviewAPs_width = ($DataChild_Width * 0.99) - $ListviewAPs_left
			GUICtrlSetPos($ListviewAPs, $ListviewAPs_left, $ListviewAPs_top, $ListviewAPs_width, $ListviewAPs_height); resize listview
			$SplitPercent = StringFormat('%0.2f', $TreeviewAPs_width / $DataChild_Width)
		EndIf
		If $MoveMode = True And $cursorInfo[2] = 0 Then
			$MoveMode = False
			GUISetCursor(2, 1);  2 = ARROW
		EndIf
	Else
		If WinActive($Vistumbler) And $cursorInfo[1] > ($Graphic_top + 60) + $Graphic_height - 5 And $cursorInfo[1] < ($Graphic_top + 60) + $Graphic_height + 5 And $MoveMode = False Then
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
			$GraphArea_TopHeight = 60
			$Graphic_height = $cursorInfo[1] - ($Graphic_top + $GraphArea_TopHeight)
			WinMove($GraphicGUI, "", $Graphic_left, $Graphic_top + $GraphArea_TopHeight, $Graphic_width, $Graphic_height)
			$ListviewAPs_top = $Graphic_top + $Graphic_height + 1
			$ListviewAPs_height = $DataChild_Height - $ListviewAPs_top
			GUICtrlSetPos($ListviewAPs, $ListviewAPs_left, $ListviewAPs_top, $ListviewAPs_width, $ListviewAPs_height); resize listview
			$SplitHeightPercent = StringFormat('%0.2f', $Graphic_height / $DataChild_Height)
			$Redraw = 1
		EndIf
		If $MoveMode = True And $cursorInfo[2] = 0 Then
			$MoveMode = False
			GUISetCursor(2, 1);  2 = ARROW
		EndIf
	EndIf
EndFunc   ;==>_TreeviewListviewResize

Func WM_NOTIFY($hWnd, $MsgID, $wParam, $lParam)
	Local $tagNMHDR, $event, $hwndFrom, $code
	$tagNMHDR = DllStructCreate("int;int;int", $lParam)
	If @error Then Return 0
	$code = DllStructGetData($tagNMHDR, 3)
	If $wParam = $ListviewAPs And $code = -3 Then
		$Selected = _GUICtrlListView_GetNextItem($ListviewAPs); find what AP is selected in the list. returns -1 is nothing is selected
		If $Selected <> -1 Then ;If a access point is selected in the listview, map its data
			_GUICtrlListView_SetItemSelected($ListviewAPs, $Selected, False)
		EndIf
	EndIf
	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_NOTIFY

;-------------------------------------------------------------------------------------------------------------------------------
;                                                       GRAPH FUNCTIONS
;-------------------------------------------------------------------------------------------------------------------------------

Func _RedrawGraphGrid()
	;Set Grid Variables
	$base_right = $Graphic_width - 1
	$base_left = 30
	$base_top = 10
	$base_bottom = $Graphic_height - 1
	$base_x = $base_right - $base_left
	$base_y = $base_bottom - $base_top
	;Draw Background
	For $r = 1 To $Graphic_height
		_SelectColor($GraphBack)
		_DrawLine($base_left, $r, $base_right, $r)
	Next
	;Draw outside lines
	_SelectColor($GraphGrid)
	_DrawLine($base_left, $base_top, $base_left, $base_bottom)
	_DrawLine($base_right, $base_top, $base_right, $base_bottom)
	_DrawLine($base_left, $base_bottom, $base_right, $base_bottom)
	_DrawLine($base_left, $base_top, $base_right, $base_top)
	;Draw Horizontal grid lines
	For $drawline = 1 To 10
		$subtract_value = (($drawline * 10) * ($base_y / 100)) + $base_top
		_DrawLine($base_right, $subtract_value, $base_left, $subtract_value)
	Next
	$ReGraph = 1
	;Deleted old graph points
	ReDim $OldGraphData[1]
EndFunc   ;==>_RedrawGraphGrid

Func _GraphApSignal() ;Graphs GPS History from selected ap
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_GraphApSignal()') ;#Debug Display
	$gt = TimerInit()
	If $Graph <> 0 And $MoveMode = False Then; If the graph tab is selected, run graph script
		;Set Grid Variables
		$base_right = $Graphic_width - 1
		$base_left = 30
		$base_top = 10
		$base_bottom = $Graphic_height - 1
		$base_x = $base_right - $base_left
		$base_y = $base_bottom - $base_top
		$Selected = _GUICtrlListView_GetNextItem($ListviewAPs); find what AP is selected in the list. returns -1 is nothing is selected
		If $Redraw = 1 Then
			_RedrawGraphGrid()
			$Redraw = 0
		EndIf
		If $Selected <> -1 Then ;If a access point is selected in the listview, map its data
			Local $ListRowMatchArray, $iRows, $iColumns, $iRval
			$query = "SELECT ApID FROM AP WHERE ListRow = '" & $Selected & "' LIMIT 1"
			$iRval = _SQLite_GetTable2d($DBhndl, $query, $ListRowMatchArray, $iRows, $iColumns)
			$GraphApID = $ListRowMatchArray[1][0]
			If $Graph = 1 Then
				$max_graph_points = '125'
			Else
				$max_graph_points = $base_x
			EndIf
			Local $HistMatchArray, $iRows, $iColumns, $iRval
			$query = "SELECT Signal, ApID, Date1, Time1 FROM Hist WHERE ApID = '" & $GraphApID & "' And Signal <> '0' ORDER BY Date1, Time1 Desc LIMIT " & $max_graph_points
			$iRval = _SQLite_GetTable2d($DBhndl, $query, $HistMatchArray, $iRows, $iColumns)
			$HistSize = $iRows
			If $HistSize <> 0 Then
				;$data = $HistMatchArray[$HistSize][3] & '-' & $HistMatchArray[$HistSize][4] & '-' & $HistSize
				$info = $HistMatchArray[$HistSize][2] & '-' & $GraphDeadTime & '-' & $TimeBeforeMarkedDead & '-' & $Graph
				If $info_old <> $info Then
					$info_old = $info
					_RedrawGraphGrid()
					$ReGraph = 1
				EndIf
				;If $data <> $data_old Or $sizes <> $sizes_old Or $ReGraph = 1 Then ; if graph data changed, map new data
				$data_old = $data
				$sizes_old = $sizes

				$Last_dts = ''
				Local $GraphTempID = 0
				Local $GraphData
				Local $MaxNumberOfZeros = 0
				For $gs = 1 To $HistSize ; Create Data Array
					$ExpSig = $HistMatchArray[$gs][0]
					$ExpApID = $HistMatchArray[$gs][1]
					$ExpDate = $HistMatchArray[$gs][2]
					$ExpTime = $HistMatchArray[$gs][3]
					$dts = StringSplit($ExpTime, ":") ;Split time so it can be converted to seconds
					$ExpTime = ($dts[1] * 3600) + ($dts[2] * 60) + StringTrimRight($dts[3], 4) ;In seconds
					$Found_dts = StringReplace($ExpDate & $ExpTime, '-', '')
					If $Last_dts = '' Then
						If $Scan = 1 Then
							$dts = StringSplit($timestamp, ":") ;Split time so it can be converted to seconds
							$LastTime = ($dts[1] * 3600) + ($dts[2] * 60) + StringTrimRight($dts[3], 4) ;In seconds
							$Last_dts = StringReplace($datestamp & $LastTime, '-', '')
							$GraphLastTime = $Last_dts
						Else
							$Last_dts = $GraphLastTime
							If $Last_dts = '' Then $Last_dts = $Found_dts
						EndIf
					EndIf
					If ($Last_dts - $Found_dts) > $TimeBeforeMarkedDead Then
						If $GraphDeadTime = 1 Then
							$numofzeros = ($Last_dts - $Found_dts) - $TimeBeforeMarkedDead
							For $wz = 1 To $numofzeros
								$GraphData = '0|' & $GraphData
								If $wz = $MaxNumberOfZeros And $MaxNumberOfZeros <> 0 Then ExitLoop
								$GraphTempID += 1
								If $GraphTempID = $max_graph_points Then ExitLoop
							Next
						Else
							$GraphData = '0|' & $GraphData
							$GraphTempID += 1
						EndIf
						If $GraphTempID = $max_graph_points Then ExitLoop
						$GraphData = $ExpSig & '|' & $GraphData
						$Last_dts = $Found_dts
					Else
						$GraphData = $ExpSig & '|' & $GraphData
						$Last_dts = $Found_dts
					EndIf
					$GraphTempID += 1
					If $GraphTempID = $max_graph_points Then ExitLoop
				Next
				$GraphDataArray = StringSplit($GraphData, '|')
				$GraphDataMatch = $GraphDataArray[0]
				If $GraphDataMatch <> 0 Then
					If $GraphDataMatch > $max_graph_points Then ; If the array is grater that the max number of ports, set array size to the max size, else use the full size of the array
						$start = $GraphDataMatch - $max_graph_points
						$arrayend = $GraphDataMatch
						$arraylen = $max_graph_points
					Else
						$start = 1
						$arrayend = $GraphDataMatch
						$arraylen = $GraphDataMatch
					EndIf
					If $Graph = 1 Then
						$base_x_add_value = ($base_x / ($arraylen - 2)); Set disance between points
						$base_y_add_value = ($base_y / 100); set distance for 1%, this will be multplied by the signal strenth later
						;############### Start Mapping Access Point signal Data ###############
						_SelectColor($red)
						$base_add = 0
						For $o = $start To ($arrayend - 1)
							$x1 = ($base_left + 1) + ($base_add * $base_x_add_value)
							$x2 = ($base_left + 1) + (($base_add + 1) * $base_x_add_value)
							$y1 = ($base_bottom + 1) - ($GraphDataArray[$o] * $base_y_add_value)
							$y2 = ($base_bottom + 1) - ($GraphDataArray[$o + 1] * $base_y_add_value)

							_SelectColor($GraphBack)
							For $rl = $x1 To $x2
								_DrawLine($rl, $base_top, $rl, $base_bottom)
							Next

							_SelectColor($GraphGrid)
							For $drawline = 1 To 10
								$subtract_value = (($drawline * 10) * $base_y_add_value) + $base_top
								_DrawLine($x1, $subtract_value, $x2, $subtract_value)
							Next

							_DrawLine($base_right, $base_top, $base_right, $base_bottom)
							_DrawLine($base_left, $base_top, $base_left, $base_bottom)
							_DrawLine($base_left, $base_top, $base_right, $base_top)

							_SelectColor($red)
							_DrawDot($x1, $y1)
							_DrawLine($x1, $y1, $x2, $y2);Draw line
							_DrawDot($x2, $y2)
							If $o <> $start Then
								$x3 = ($base_left + 1) + (($base_add - 1) * $base_x_add_value)
								$y3 = ($base_bottom + 1) - ($GraphDataArray[$o - 1] * $base_y_add_value)
								_DrawLine($x3, $y3, $x1, $y1);Draw line
							EndIf
							$base_add += 1
						Next
						;############### End Mapping Access Point signal Data ###############
					ElseIf $Graph = 2 Then
						$base_y_add_value = ($base_y / 100); set distance for 1%, this will be multplied by the signal strenth later
						$base_add = 1
						$base_x_add_value = 1
						$GraphData = ""
						$OldGraphData[0] = UBound($OldGraphData) - 1

						For $o = 1 To $GraphDataMatch
							If $o <= $OldGraphData[0] Then
								If $GraphDataArray[$o] <> $OldGraphData[$o] Then
									_SelectColor($red)
									_DrawLine(($base_left + $base_add), $base_bottom, ($base_left + $base_add), $base_bottom - ($GraphDataArray[$o] * $base_y_add_value))
									_SelectColor($GraphBack)
									_DrawLine(($base_left + $base_add), $base_bottom - ($GraphDataArray[$o] * $base_y_add_value), ($base_left + $base_add), $base_top)
									_SelectColor($GraphGrid)
									For $drawline = 1 To 10
										$subtract_value = (($drawline * 10) * $base_y_add_value) + $base_top
										_DrawLine(($base_left + $base_add), $subtract_value, ($base_left + $base_add) + 1, $subtract_value)
									Next
								EndIf
							ElseIf $GraphDataArray[$o] <> 0 Then
								_SelectColor($red)
								_DrawLine(($base_left + $base_add), $base_bottom, ($base_left + $base_add), $base_bottom - ($GraphDataArray[$o] * $base_y_add_value))
								_SelectColor($GraphBack)
								_DrawLine(($base_left + $base_add), $base_bottom - ($GraphDataArray[$o] * $base_y_add_value), ($base_left + $base_add), $base_top)
								_SelectColor($GraphGrid)
								For $drawline = 1 To 10
									$subtract_value = (($drawline * 10) * $base_y_add_value) + $base_top
									_DrawLine(($base_left + $base_add), $subtract_value, ($base_left + $base_add) + 1, $subtract_value)
								Next
							EndIf
							If $GraphData <> "" Then $GraphData &= "|"
							$GraphData &= $GraphDataArray[$o]
							$base_add += $base_x_add_value
						Next
						$OldGraphData = StringSplit($GraphData, '|')
						_DrawLine($base_right, $base_top, $base_right, $base_bottom)
						_DrawLine($base_left, $base_top, $base_left, $base_bottom)
						_DrawLine($base_left, $base_top, $base_right, $base_top)
					EndIf
					$ReGraph = 0
				EndIf
				;EndIf
			EndIf
		EndIf
	EndIf
EndFunc   ;==>_GraphApSignal

;Graph API Functions - By neogia - http://www.autoitscript.com/forum/index.php?showtopic=24621&hl=GUICtrlSetGraphic+windows+api
;Used in place of autoit Graphic function to remove flicker when the graph gets redraw (it is slower though :-( )
Func _DrawDot($x, $y)
	;If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_DrawDot()') ;#Debug Display
	_DrawLine($x - 1, $y - 1, $x + 1, $y - 1)
	_DrawLine($x - 1, $y, $x + 1, $y)
	_DrawLine($x - 1, $y + 1, $x + 1, $y + 1)
EndFunc   ;==>_DrawDot

Func _DrawingStartUp($GUI)
	;If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_DrawingStartUp()') ;#Debug Display
	Global $gdi_dll = DllOpen("gdi32.dll")
	Global $user32_dll = DllOpen("user32.dll")
	Global $hDC = DllCall("user32.dll", "int", "GetDC", "hwnd", $GUI)
	$hDC = $hDC[0]
EndFunc   ;==>_DrawingStartUp

Func _DrawingShutDown($GUI)
	;If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_DrawingShutDown()') ;#Debug Display
	DllCall($user32_dll, "int", "ReleaseDC", "int", $hDC, "hwnd", $GUI)
	DllClose($gdi_dll)
	DllClose($user32_dll)
EndFunc   ;==>_DrawingShutDown

Func _CreateColor($r, $g, $b)
	;If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_CreateColor()') ;#Debug Display
	$hPen = DllCall($gdi_dll, "hwnd", "CreatePen", "int", "0", "int", "0", "hwnd", "0x00" & Hex($b, 2) & Hex($g, 2) & Hex($r, 2))
	Return $hPen[0]
EndFunc   ;==>_CreateColor

Func _SelectColor($hPen)
	;If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_SelectColor()') ;#Debug Display
	DllCall($gdi_dll, "hwnd", "SelectObject", "hwnd", $hDC, "hwnd", $hPen)
EndFunc   ;==>_SelectColor

Func _DrawLine($x0, $y0, $x1, $y1)
	;If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_DrawLine()') ;#Debug Display
	DllCall($gdi_dll, "int", "MoveToEx", "hwnd", $hDC, "int", $x0, "int", $y0, "ptr", 0)
	DllCall($gdi_dll, "int", "LineTo", "hwnd", $hDC, "int", $x1, "int", $y1)
EndFunc   ;==>_DrawLine

;Graph API functions by ACalcutt
Func _DeleteObject($hPen)
	;If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_DeleteObject()') ;#Debug Display
	DllCall($gdi_dll, "int", "DeleteObject", "int", $hPen)
EndFunc   ;==>_DeleteObject

Func _CreatePens()
	;If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_CreatePens()') ;#Debug Display
	$GraphBackColor = StringTrimLeft($ControlBackgroundColor, 2)
	$r = Dec(StringTrimRight($GraphBackColor, 4))
	$g = Dec(StringTrimLeft(StringTrimRight($GraphBackColor, 2), 2))
	$b = Dec(StringTrimLeft($GraphBackColor, 4))
	$GraphBack = _CreateColor($r, $g, $b)
	$black = _CreateColor(0, 0, 0)
	$red = _CreateColor(255, 0, 0)
	$GraphGridColor = StringTrimLeft($BackgroundColor, 2)
	$r = Dec(StringTrimRight($GraphGridColor, 4))
	$g = Dec(StringTrimLeft(StringTrimRight($GraphGridColor, 2), 2))
	$b = Dec(StringTrimLeft($GraphGridColor, 4))
	$GraphGrid = _CreateColor($r, $g, $b)
	;$GraphGrid = _CreateColor(0, 0, 255)
EndFunc   ;==>_CreatePens

Func _DeletePens()
	;If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_DeletePens()') ;#Debug Display
	_DeleteObject($GraphBack)
	_DeleteObject($black)
	_DeleteObject($red)
	_DeleteObject($GraphGrid)
EndFunc   ;==>_DeletePens

;-------------------------------------------------------------------------------------------------------------------------------
;                                                       PHILS FUNCTIONS
;-------------------------------------------------------------------------------------------------------------------------------

Func _ViewInPhilsPHP();Sends data to phils php graphing script
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_ViewInPhilsPHP()') ;#Debug Display
	$Selected = _GUICtrlListView_GetNextItem($ListviewAPs); find what AP is selected in the list. returns -1 is nothing is selected
	If $Selected <> -1 Then ;If a access point is selected in the listview, map its data
		Local $ListRowMatchArray, $iRows, $iColumns, $iRval
		$query = "SELECT ApID, SSID, BSSID, AUTH, ENCR, RADTYPE, NETTYPE, CHAN, BTX, OTX, MANU, LABEL, HighGpsHistID FROM AP WHERE ListRow = '" & $Selected & "'"
		$iRval = _SQLite_GetTable2d($DBhndl, $query, $ListRowMatchArray, $iRows, $iColumns)
		$FoundListRowMatch = $iRows
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
				Local $HistMatchArray, $iRows, $iColumns, $iRval
				$query = "SELECT GpsID FROM Hist WHERE HistID = '" & $Found_HighGpsHistId & "' LIMIT 1"
				$iRval = _SQLite_GetTable2d($DBhndl, $query, $HistMatchArray, $iRows, $iColumns)
				$Found_HighGpsID = $HistMatchArray[1][0]
				Local $GpsMatchArray, $iRows, $iColumns, $iRval
				$query = "SELECT Latitude, Longitude FROM GPS WHERE GpsID = '" & $Found_HighGpsID & "' LIMIT 1"
				$iRval = _SQLite_GetTable2d($DBhndl, $query, $GpsMatchArray, $iRows, $iColumns)
				$Found_Lat = $GpsMatchArray[1][0]
				$Found_Lon = $GpsMatchArray[1][1]
			EndIf
			Local $SignalMatchArray, $iRows, $iColumns, $iRval
			$query = "SELECT Signal, Date1, Time1 FROM Hist WHERE ApID = '" & $Found_APID & "' ORDER BY Date1 DESC, Time1 DESC"
			$iRval = _SQLite_GetTable2d($DBhndl, $query, $SignalMatchArray, $iRows, $iColumns)
			$FoundSignalMatch = $iRows
			If $FoundSignalMatch <> 0 Then
				For $pg = 1 To $FoundSignalMatch
					If $pg = 1 Then
						$pgsigdata = $SignalMatchArray[$pg][1]
						$Found_LastSeen = $SignalMatchArray[$pg][2] & ' ' & $SignalMatchArray[$pg][3]
					Else
						$pgsigdata &= '-' & $SignalMatchArray[$pg][1]
					EndIf
					If $pg = $FoundSignalMatch Then $Found_FirstSeen = $SignalMatchArray[$pg][2] & ' ' & $SignalMatchArray[$pg][3]
				Next
				$url_root = $PhilsGraphURL
				$url_data = "?SSID=" & $Found_SSID & "&Mac=" & $Found_BSSID & "&Manuf=" & $Found_MANU & "&Auth=" & $Found_AUTH & "&Encry=" & $Found_ENCR & "&radio=" & $Found_RADTYPE & "&Chn=" & $Found_CHAN & "&Lat=" & $Found_Lat & "&Long=" & $Found_Lon & "&BTx=" & $Found_BTX & "&OTx=" & $Found_OTX & "&FA=" & $Found_FirstSeen & "&LU=" & $Found_LastSeen & "&NT=" & $Found_NETTYPE & "&Label=" & $Found_LAB & "&Sig=" & $pgsigdata
				$url_full = $url_root & $url_data
				$url_trimmed = StringTrimRight($url_full, (StringLen($url_full) - 2048)) ;trim sting to internet explorer max url lenth
				$url_trimmed2 = StringTrimRight($url_trimmed, (StringLen($url_trimmed) - StringInStr($url_trimmed, "-", 1, -1)) + 1);find - that marks the last full data and get rid of the rest
				Run("RunDll32.exe url.dll,FileProtocolHandler " & $url_trimmed2);open url with rundll 32
			EndIf
		EndIf
	Else
		MsgBox(0, $Text_Error, $Text_NoApSelected)
	EndIf
EndFunc   ;==>_ViewInPhilsPHP

Func _AddToYourWDB()
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_AddToYourWDB()') ;#Debug Display
	$WdbFile = $SaveDir & 'WDB_Export.VS1'
	FileDelete($WdbFile)
	_ExportDetailedTXT($WdbFile)
	$url_root = $PhilsWdbURL & 'import/?'
	$url_data = "file=" & $WdbFile
	Run("RunDll32.exe url.dll,FileProtocolHandler " & $url_root & $url_data);open url with rundll 32
EndFunc   ;==>_AddToYourWDB

Func _LocatePositionInWiFiDB();Send data to phils wireless ap database
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_LocatePositionInWiFiDB()') ;#Debug Display
	Local $ActiveMacs
	Local $BssidMatchArray, $iRows, $iColumns, $iRval
	$query = "SELECT BSSID, Signal FROM AP WHERE Active = '1'"
	$iRval = _SQLite_GetTable2d($DBhndl, $query, $BssidMatchArray, $iRows, $iColumns)
	$FoundBssidMatch = $iRows
	If $FoundBssidMatch <> 0 Then
		For $exb = 1 To $FoundBssidMatch
			If $exb <> 1 Then $ActiveMacs &= '-'
			$ActiveMacs &= $BssidMatchArray[$exb][1] & '|' & ($BssidMatchArray[$exb][2] + 0)
		Next
		$url_root = $PhilsWdbURL & 'opt/locate.php?'
		$url_data = "ActiveBSSIDs=" & $ActiveMacs
		Run("RunDll32.exe url.dll,FileProtocolHandler " & $url_root & $url_data);open url with rundll 32
	Else
		MsgBox(0, $Text_Error, $Text_NoActiveApFound)
	EndIf
EndFunc   ;==>_LocatePositionInWiFiDB

Func _LocateGpsInWifidb()
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_LocatePositionInWiFiDB()') ;#Debug Display
	Local $ActiveMacs
	Local $return = 0
	Local $BssidMatchArray, $iRows, $iColumns, $iRval
	$query = "SELECT BSSID, Signal FROM AP WHERE Active = '1'"
	$iRval = _SQLite_GetTable2d($DBhndl, $query, $BssidMatchArray, $iRows, $iColumns)
	$FoundBssidMatch = $iRows
	If $FoundBssidMatch <> 0 Then
		For $exb = 1 To $FoundBssidMatch
			If $exb <> 1 Then $ActiveMacs &= '-'
			$ActiveMacs &= $BssidMatchArray[$exb][1] & '|' & ($BssidMatchArray[$exb][2] + 0)
		Next
		$url_root = $PhilsWdbURL & 'opt/locate.php?'
		$url_data = $url_root & "ActiveBSSIDs=" & $ActiveMacs
		$webpagesource = _INetGetSource($url_data)
		If StringInStr($webpagesource, '|') Then
			$wifigpsdata = StringSplit($webpagesource, "|")
			If $wifigpsdata[1] <> '' And $wifigpsdata[1] <> '' Then
				$LatitudeWifidb = $wifigpsdata[1]
				$LongitudeWifidb = $wifigpsdata[2]
				$WifidbGPS_Update = TimerInit()
				$return = 1
			EndIf
		EndIf
	EndIf
	_ClearWifiGpsDetails()
	Return ($return)
EndFunc   ;==>_LocateGpsInWifidb

Func _ClearWifiGpsDetails();Clears all GPS Details information
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_ClearWifiGpsDetails()') ;#Debug Display
	GUICtrlSetData($msgdisplay, $Text_SecondsSinceGpsUpdate & ": WifiDb:" & Round(TimerDiff($WifidbGPS_Update) / 1000) & " / " & ($GpsTimeout / 1000))
	If Round(TimerDiff($WifidbGPS_Update)) > $GpsTimeout Then
		$Latitude = 'N 0000.0000'
		$Longitude = 'E 0000.0000'
		$LatitudeWifidb = 'N 0000.0000'
		$LongitudeWifidb = 'E 0000.0000'
		GUICtrlSetData($GuiLat, $Text_Latitude & ': ' & _GpsFormat($Latitude));Set GPS Latitude in GUI
		GUICtrlSetData($GuiLon, $Text_Longitude & ': ' & _GpsFormat($Longitude));Set GPS Longitude in GUI
		$WifidbGPS_Update = TimerInit()
	EndIf
EndFunc   ;==>_ClearWifiGpsDetails

;-------------------------------------------------------------------------------------------------------------------------------
;                                                       REFRESH NETWORK FUNCTION
;-------------------------------------------------------------------------------------------------------------------------------

Func _RefreshNetworks() ;Refresh Wireless networks
	If $Scan = 1 And $RefreshNetworks = 1 Then
		If TimerDiff($RefreshTimer) >= $RefreshTime Then
			_Wlan_Scan($DefaultApapterID, $wlanhandle)
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
	Run("RunDll32.exe url.dll,FileProtocolHandler " & 'http://sourceforge.net/apps/mediawiki/vistumbler/')
EndFunc   ;==>_OpenVistumblerWiki

;-------------------------------------------------------------------------------------------------------------------------------
;                                                       SUPPORT VISTUMBLER FUNCTIONS
;-------------------------------------------------------------------------------------------------------------------------------

Func _OpenVistumblerDonate();Opens Vistumbler Donate
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_OpenVistumblerDonate() ') ;#Debug Display
	Run("RunDll32.exe url.dll,FileProtocolHandler " & 'https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=ACalcutt%40Vistumbler%2enet&item_name=Vistumbler%20Donation&no_shipping=0&no_note=1&tax=0&currency_code=USD&lc=US&bn=PP%2dDonationsBF&charset=UTF%2d8')
EndFunc   ;==>_OpenVistumblerDonate

Func _OpenVistumblerStore();Opens Vistumbler Store
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_OpenVistumblerStore() ') ;#Debug Display
	Run("RunDll32.exe url.dll,FileProtocolHandler " & 'http://www.zazzle.com/acalcutt/products')
EndFunc   ;==>_OpenVistumblerStore

;-------------------------------------------------------------------------------------------------------------------------------
;                                                       COPY GUI FUNCTIONS
;-------------------------------------------------------------------------------------------------------------------------------

Func _CopyAP()
	$CopySelected = _GUICtrlListView_GetNextItem($ListviewAPs); find what AP is selected in the list. returns -1 is nothing is selected
	Local $ApMatchArray, $iRows, $iColumns, $iRval
	;$query = "SELECT ApID FROM AP WHERE ListRow='" & $CopySelected & "';"
	$query = "SELECT ApID FROM AP WHERE ListRow=" & $CopySelected & ";"
	$iRval = _SQLite_GetTable2d($DBhndl, $query, $ApMatchArray, $iRows, $iColumns)
	$FoundApMatch = $iRows
	If $CopySelected <> -1 And $FoundApMatch <> 0 Then ;If a access point is selected in the listview, map its data
		$CopyAPID = $ApMatchArray[1][0]
		$GUI_COPY = GUICreate($Text_Copy, 491, 249)
		GUISetBkColor($BackgroundColor)
		GUICtrlCreateGroup($Text_SelectWhatToCopy, 8, 8, 473, 201)
		$Copy_Line = GUICtrlCreateCheckbox($Column_Names_Line, 27, 29, 200, 15)
		$Copy_BSSID = GUICtrlCreateCheckbox($Column_Names_BSSID, 27, 44, 200, 15)
		$Copy_SSID = GUICtrlCreateCheckbox($Column_Names_SSID, 27, 59, 200, 15)
		$Copy_CHAN = GUICtrlCreateCheckbox($Column_Names_Channel, 27, 75, 200, 15)
		$Copy_AUTH = GUICtrlCreateCheckbox($Column_Names_Authentication, 27, 90, 200, 15)
		$Copy_ENCR = GUICtrlCreateCheckbox($Column_Names_Encryption, 27, 105, 200, 15)
		$Copy_NETTYPE = GUICtrlCreateCheckbox($Column_Names_NetworkType, 27, 120, 200, 15)
		$Copy_RADTYPE = GUICtrlCreateCheckbox($Column_Names_RadioType, 27, 135, 200, 15)
		$Copy_SIG = GUICtrlCreateCheckbox($Column_Names_Signal, 27, 151, 200, 15)
		$Copy_LAB = GUICtrlCreateCheckbox($Column_Names_Label, 27, 166, 200, 15)
		$Copy_MANU = GUICtrlCreateCheckbox($Column_Names_MANUF, 27, 181, 200, 15)
		$Copy_LAT = GUICtrlCreateCheckbox($Column_Names_Latitude, 267, 29, 200, 15)
		$Copy_LON = GUICtrlCreateCheckbox($Column_Names_Longitude, 267, 44, 200, 15)
		$Copy_LATDMS = GUICtrlCreateCheckbox($Column_Names_LatitudeDMS, 267, 59, 200, 15)
		$Copy_LONDMS = GUICtrlCreateCheckbox($Column_Names_LongitudeDMS, 267, 75, 200, 15)
		$Copy_LATDMM = GUICtrlCreateCheckbox($Column_Names_LatitudeDMM, 267, 90, 200, 15)
		$Copy_LONDMM = GUICtrlCreateCheckbox($Column_Names_LongitudeDMM, 267, 105, 200, 15)
		$Copy_BTX = GUICtrlCreateCheckbox($Column_Names_BasicTransferRates, 267, 120, 200, 15)
		$Copy_OTX = GUICtrlCreateCheckbox($Column_Names_OtherTransferRates, 267, 135, 200, 15)
		$Copy_FirstActive = GUICtrlCreateCheckbox($Column_Names_FirstActive, 267, 151, 200, 15)
		$Copy_LastActive = GUICtrlCreateCheckbox($Column_Names_LastActive, 267, 166, 200, 15)

		$CopyOK = GUICtrlCreateButton($Text_Ok, 142, 216, 100, 25, 0)
		$CopyCancel = GUICtrlCreateButton($Text_Cancel, 256, 216, 100, 25, 0)
		GUISetState(@SW_SHOW)

		GUISetOnEvent($GUI_EVENT_CLOSE, '_CloseCopyGUI')
		GUICtrlSetOnEvent($CopyCancel, '_CloseCopyGUI')
		GUICtrlSetOnEvent($CopyOK, '_CopyOK')
	Else
		MsgBox(0, $Text_Error, $Text_NoApSelected)
	EndIf
EndFunc   ;==>_CopyAP

Func _CloseCopyGUI()
	GUIDelete($GUI_COPY)
EndFunc   ;==>_CloseCopyGUI

Func _CopyOK()
	Local $ApMatchArray, $iRows, $iColumns, $iRval
	$query = "SELECT ApID, BSSID, SSID, CHAN, AUTH, ENCR, NETTYPE, RADTYPE, LABEL, MANU, HighGpsHistID, BTX, OTX, FirstHistID, LastHistID FROM AP WHERE ApID = '" & $CopyAPID & "'"
	$iRval = _SQLite_GetTable2d($DBhndl, $query, $ApMatchArray, $iRows, $iColumns)
	$FoundApMatch = $iRows
	If $FoundApMatch <> 0 Then
		$CopyText = ''
		If GUICtrlRead($Copy_Line) = 1 Then
			$CopyText = $ApMatchArray[1][0]
		EndIf
		If GUICtrlRead($Copy_BSSID) = 1 Then
			If $CopyText = '' Then
				$CopyText = $ApMatchArray[1][1]
			Else
				$CopyText &= '|' & $ApMatchArray[1][1]
			EndIf
		EndIf
		If GUICtrlRead($Copy_SSID) = 1 Then
			If $CopyText = '' Then
				$CopyText = $ApMatchArray[1][2]
			Else
				$CopyText &= '|' & $ApMatchArray[1][2]
			EndIf
		EndIf
		If GUICtrlRead($Copy_CHAN) = 1 Then
			If $CopyText = '' Then
				$CopyText = $ApMatchArray[1][3]
			Else
				$CopyText &= '|' & $ApMatchArray[1][3]
			EndIf
		EndIf
		If GUICtrlRead($Copy_AUTH) = 1 Then
			If $CopyText = '' Then
				$CopyText = $ApMatchArray[1][4]
			Else
				$CopyText &= '|' & $ApMatchArray[1][4]
			EndIf
		EndIf
		If GUICtrlRead($Copy_ENCR) = 1 Then
			If $CopyText = '' Then
				$CopyText = $ApMatchArray[1][5]
			Else
				$CopyText &= '|' & $ApMatchArray[1][5]
			EndIf
		EndIf
		If GUICtrlRead($Copy_NETTYPE) = 1 Then
			If $CopyText = '' Then
				$CopyText = $ApMatchArray[1][6]
			Else
				$CopyText &= '|' & $ApMatchArray[1][6]
			EndIf
		EndIf
		If GUICtrlRead($Copy_RADTYPE) = 1 Then
			If $CopyText = '' Then
				$CopyText = $ApMatchArray[1][7]
			Else
				$CopyText &= '|' & $ApMatchArray[1][7]
			EndIf
		EndIf
		If GUICtrlRead($Copy_SIG) = 1 Then
			$LastHistID = Round($ApMatchArray[1][14])
			Local $HistMatchArray, $iRows, $iColumns, $iRval
			$query = "SELECT Signal FROM Hist Where HistID = '" & $LastHistID & "'"
			$iRval = _SQLite_GetTable2d($DBhndl, $query, $HistMatchArray, $iRows, $iColumns)
			$ExpSig = $HistMatchArray[1][0]
			If $CopyText = '' Then
				$CopyText = $ExpSig
			Else
				$CopyText &= '|' & $ExpSig
			EndIf
		EndIf
		If GUICtrlRead($Copy_LAB) = 1 Then
			If $CopyText = '' Then
				$CopyText = $ApMatchArray[1][8]
			Else
				$CopyText &= '|' & $ApMatchArray[1][8]
			EndIf
		EndIf
		If GUICtrlRead($Copy_MANU) = 1 Then
			If $CopyText = '' Then
				$CopyText = $ApMatchArray[1][9]
			Else
				$CopyText &= '|' & $ApMatchArray[1][9]
			EndIf
		EndIf
		If GUICtrlRead($Copy_LAT) = 1 Or GUICtrlRead($Copy_LON) = 1 Or GUICtrlRead($Copy_LATDMS) = 1 Or GUICtrlRead($Copy_LONDMS) = 1 Or GUICtrlRead($Copy_LATDMM) = 1 Or GUICtrlRead($Copy_LONDMM) = 1 Then
			$HighGpsHistID = Round($ApMatchArray[1][10])
			If $HighGpsHistID = 0 Then
				$CopyLat = 'N 0000.0000'
				$CopyLon = 'E 0000.0000'
			Else
				Local $HistMatchArray, $iRows, $iColumns, $iRval
				$query = "SELECT GpsId FROM Hist Where HistID = '" & $HighGpsHistID & "'"
				$iRval = _SQLite_GetTable2d($DBhndl, $query, $HistMatchArray, $iRows, $iColumns)
				$ExpGID = $HistMatchArray[1][0]
				Local $GpsMatchArray, $iRows, $iColumns, $iRval
				$query = "SELECT Latitude, Longitude FROM GPS WHERE GpsId = '" & $ExpGID & "'"
				$iRval = _SQLite_GetTable2d($DBhndl, $query, $GpsMatchArray, $iRows, $iColumns)
				$CopyLat = $GpsMatchArray[1][0]
				$CopyLon = $GpsMatchArray[1][1]
			EndIf
			If GUICtrlRead($Copy_LAT) = 1 Then
				If $CopyText = '' Then
					$CopyText = _Format_GPS_DMM_to_DDD($CopyLat)
				Else
					$CopyText &= '|' & _Format_GPS_DMM_to_DDD($CopyLat)
				EndIf
			EndIf
			If GUICtrlRead($Copy_LON) = 1 Then
				If $CopyText = '' Then
					$CopyText = _Format_GPS_DMM_to_DDD($CopyLon)
				Else
					$CopyText &= '|' & _Format_GPS_DMM_to_DDD($CopyLon)
				EndIf
			EndIf
			If GUICtrlRead($Copy_LATDMS) = 1 Then
				If $CopyText = '' Then
					$CopyText = _Format_GPS_DMM_to_DMS($CopyLat)
				Else
					$CopyText &= '|' & _Format_GPS_DMM_to_DMS($CopyLat)
				EndIf
			EndIf
			If GUICtrlRead($Copy_LONDMS) = 1 Then
				If $CopyText = '' Then
					$CopyText = _Format_GPS_DMM_to_DMS($CopyLon)
				Else
					$CopyText &= '|' & _Format_GPS_DMM_to_DMS($CopyLon)
				EndIf
			EndIf
			If GUICtrlRead($Copy_LATDMM) = 1 Then
				If $CopyText = '' Then
					$CopyText = $CopyLat
				Else
					$CopyText &= '|' & $CopyLat
				EndIf
			EndIf
			If GUICtrlRead($Copy_LONDMM) = 1 Then
				If $CopyText = '' Then
					$CopyText = $CopyLon
				Else
					$CopyText &= '|' & $CopyLon
				EndIf
			EndIf
		EndIf
		If GUICtrlRead($Copy_BTX) = 1 Then
			If $CopyText = '' Then
				$CopyText = $ApMatchArray[1][11]
			Else
				$CopyText &= '|' & $ApMatchArray[1][11]
			EndIf
		EndIf
		If GUICtrlRead($Copy_OTX) = 1 Then
			If $CopyText = '' Then
				$CopyText = $ApMatchArray[1][12]
			Else
				$CopyText &= '|' & $ApMatchArray[1][12]
			EndIf
		EndIf
		If GUICtrlRead($Copy_FirstActive) = 1 Then
			$FirstHistID = $ApMatchArray[1][13]
			Local $HistMatchArray, $iRows, $iColumns, $iRval
			$query = "SELECT GpsID FROM Hist Where HistID = '" & $FirstHistID & "'"
			$iRval = _SQLite_GetTable2d($DBhndl, $query, $HistMatchArray, $iRows, $iColumns)
			$ExpGID = $HistMatchArray[1][0]
			Local $GpsMatchArray, $iRows, $iColumns, $iRval
			$query = "SELECT Date1, Time1 FROM Gps Where GpsID = '" & $ExpGID & "'"
			$iRval = _SQLite_GetTable2d($DBhndl, $query, $GpsMatchArray, $iRows, $iColumns)
			$ExpDate = $GpsMatchArray[1][0]
			$ExpTime = $GpsMatchArray[1][1]
			If $CopyText = '' Then
				$CopyText = $ExpDate & ' ' & $ExpTime
			Else
				$CopyText &= '|' & $ExpDate & ' ' & $ExpTime
			EndIf
		EndIf
		If GUICtrlRead($Copy_LastActive) = 1 Then
			$LastHistID = $ApMatchArray[1][14]
			Local $HistMatchArray, $iRows, $iColumns, $iRval
			$query = "SELECT GpsID FROM Hist Where HistID = '" & $LastHistID & "'"
			$iRval = _SQLite_GetTable2d($DBhndl, $query, $HistMatchArray, $iRows, $iColumns)
			$ExpGID = $HistMatchArray[1][0]
			Local $GpsMatchArray, $iRows, $iColumns, $iRval
			$query = "SELECT Date1, Time1 FROM Gps Where GpsID = '" & $ExpGID & "'"
			$iRval = _SQLite_GetTable2d($DBhndl, $query, $GpsMatchArray, $iRows, $iColumns)
			$ExpDate = $GpsMatchArray[1][0]
			$ExpTime = $GpsMatchArray[1][1]
			If $CopyText = '' Then
				$CopyText = $ExpDate & ' ' & $ExpTime
			Else
				$CopyText &= '|' & $ExpDate & ' ' & $ExpTime
			EndIf
		EndIf
		ClipPut($CopyText)
	EndIf
	_CloseCopyGUI()
EndFunc   ;==>_CopyOK

;-------------------------------------------------------------------------------------------------------------------------------
;                                                       VISTUMBLER SAVE FUNCTIONS
;-------------------------------------------------------------------------------------------------------------------------------

Func _OpenSaveFolder();Opens save folder in explorer
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_OpenSaveFolder() ') ;#Debug Display
	Run('RunDll32.exe url.dll,FileProtocolHandler "' & $SaveDir & '"')
EndFunc   ;==>_OpenSaveFolder

Func _OpenExternalToolsFolder()
	Run('RunDll32.exe url.dll,FileProtocolHandler "' & $ToolsDir & '"')
EndFunc   ;==>_OpenExternalToolsFolder

Func _AutoSave();Autosaves data to a file name based on current time
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_AutoSave()') ;#Debug Display
	DirCreate($SaveDirAuto)
	FileDelete($AutoSaveFile)
	$AutoSaveFile = $SaveDirAuto & 'AutoSave_' & $datestamp & ' ' & StringReplace(StringReplace($timestamp, ':', '-'), '.', '-') & '.VS1'
	If ProcessExists($AutoSaveProcess) = 0 Then
		$AutoSaveProcess = Run(@ComSpec & " /C " & FileGetShortName(@ScriptDir & '\Export.exe') & ' /db="' & $VistumblerDB & '" /t=d /f="' & $AutoSaveFile & '"', '', @SW_HIDE)
		$save_timer = TimerInit()
	EndIf
EndFunc   ;==>_AutoSave

Func _ExportDetailedData();Saves data to a selected file
	_ExportDetailedDataGui(0)
EndFunc   ;==>_ExportDetailedData

Func _ExportFilteredDetailedData();Saves filtered data to a selected file
	_ExportDetailedDataGui(1)
EndFunc   ;==>_ExportFilteredDetailedData

Func _ExportDetailedDataGui($Filter = 0);Save VS1 GUI
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_ExportData()') ;#Debug Display
	DirCreate($SaveDir)
	$file = FileSaveDialog($Text_SaveAsTXT, $SaveDir, $Text_VistumblerFile & ' (*.VS1)', '', $ldatetimestamp & '.VS1')
	If @error <> 1 Then
		If StringInStr($file, '.VS1') = 0 Then $file = $file & '.VS1'
		FileDelete($file)
		_ExportDetailedTXT($file, $Filter)
		MsgBox(0, $Text_Done, $Text_SavedAs & ': "' & $file & '"')
		GUICtrlSetData($msgdisplay, '')
		$newdata = 0
	EndIf
EndFunc   ;==>_ExportDetailedDataGui

Func _ExportDetailedTXT($savefile, $Filter = 0);writes vistumbler detailed data to a txt file
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_ExportDetailedTXT()') ;#Debug Display
	FileWriteLine($savefile, "# Vistumbler VS1 - Detailed Export Version 3.0")
	FileWriteLine($savefile, "# Created By: " & $Script_Name & ' ' & $version)

	;Export GIDs
	FileWriteLine($savefile, "# -------------------------------------------------")
	FileWriteLine($savefile, "# GpsID|Latitude|Longitude|NumOfSatalites|HorizontalDilutionOfPrecision|Altitude(m)|HeightOfGeoidAboveWGS84Ellipsoid(m)|Speed(km/h)|Speed(MPH)|TrackAngle(Deg)|Date(UTC y-m-d)|Time(UTC h:m:s.ms)")
	FileWriteLine($savefile, "# -------------------------------------------------")

	Local $GpsMatchArray, $iRows, $iColumns, $iRval
	$query = "SELECT GpsID, Latitude, Longitude, NumOfSats, HorDilPitch, Alt, Geo, SpeedInMPH, SpeedInKmH, TrackAngle, Date1, Time1 FROM GPS ORDER BY Date1, Time1"
	$iRval = _SQLite_GetTable2d($DBhndl, $query, $GpsMatchArray, $iRows, $iColumns)
	$FoundGpsMatch = $iRows
	For $exp = 1 To $FoundGpsMatch
		GUICtrlSetData($msgdisplay, $Text_SavingGID & ' ' & $exp & ' / ' & $FoundGpsMatch)
		$ExpGID = $GpsMatchArray[$exp][0]
		$ExpLat = $GpsMatchArray[$exp][1]
		$ExpLon = $GpsMatchArray[$exp][2]
		$ExpSat = $GpsMatchArray[$exp][3]
		$ExpHorDilPitch = $GpsMatchArray[$exp][4]
		$ExpAlt = $GpsMatchArray[$exp][5]
		$ExpGeo = $GpsMatchArray[$exp][6]
		$ExpSpeedMPH = $GpsMatchArray[$exp][7]
		$ExpSpeedKmh = $GpsMatchArray[$exp][8]
		$ExpTrack = $GpsMatchArray[$exp][9]
		$ExpDate = $GpsMatchArray[$exp][10]
		$ExpTime = $GpsMatchArray[$exp][11]
		FileWriteLine($savefile, $ExpGID & '|' & $ExpLat & '|' & $ExpLon & '|' & $ExpSat & '|' & $ExpHorDilPitch & '|' & $ExpAlt & '|' & $ExpGeo & '|' & $ExpSpeedKmh & '|' & $ExpSpeedMPH & '|' & $ExpTrack & '|' & $ExpDate & '|' & $ExpTime)
	Next

	;Export AP Information
	FileWriteLine($savefile, "# ---------------------------------------------------------------------------------------------------------------------------------------------------------")
	FileWriteLine($savefile, "# SSID|BSSID|MANUFACTURER|Authetication|Encryption|Security Type|Radio Type|Channel|Basic Transfer Rates|Other Transfer Rates|Network Type|Label|GID,SIGNAL")
	FileWriteLine($savefile, "# ---------------------------------------------------------------------------------------------------------------------------------------------------------")
	If $Filter = 1 Then
		$query = $AddQuery
	Else
		$query = "SELECT ApID, SSID, BSSID, NETTYPE, RADTYPE, CHAN, AUTH, ENCR, SecType, BTX, OTX, MANU, LABEL, HighGpsHistID, FirstHistID, LastHistID, LastGpsID, Active FROM AP"
	EndIf
	Local $ApMatchArray, $iRows, $iColumns, $iRval
	$iRval = _SQLite_GetTable2d($DBhndl, $query, $ApMatchArray, $iRows, $iColumns)
	$FoundApMatch = $iRows
	For $exp = 1 To $FoundApMatch
		GUICtrlSetData($msgdisplay, $Text_SavingLine & ' ' & $exp & ' / ' & $FoundApMatch)
		$ExpApID = $ApMatchArray[$exp][0]
		$ExpSSID = $ApMatchArray[$exp][1]
		$ExpBSSID = $ApMatchArray[$exp][2]
		$ExpNET = $ApMatchArray[$exp][3]
		$ExpRAD = $ApMatchArray[$exp][4]
		$ExpCHAN = $ApMatchArray[$exp][5]
		$ExpAUTH = $ApMatchArray[$exp][6]
		$ExpENCR = $ApMatchArray[$exp][7]
		$ExpSECTYPE = $ApMatchArray[$exp][8]
		$ExpBTX = $ApMatchArray[$exp][9]
		$ExpOTX = $ApMatchArray[$exp][10]
		$ExpMANU = $ApMatchArray[$exp][11]
		$ExpLAB = $ApMatchArray[$exp][12]
		$ExpHighGpsID = $ApMatchArray[$exp][13]
		$ExpFirstID = $ApMatchArray[$exp][14]
		$ExpLastID = $ApMatchArray[$exp][15]
		$ExpGidSid = ''

		;Create GID,SIG String
		Local $HistMatchArray, $iRows, $iColumns, $iRval
		$query = "SELECT GpsID, Signal FROM Hist WHERE ApID = '" & $ExpApID & "'"
		$iRval = _SQLite_GetTable2d($DBhndl, $query, $HistMatchArray, $iRows, $iColumns)
		$FoundHistMatch = $iRows
		For $epgs = 1 To $FoundHistMatch
			$ExpGID = $HistMatchArray[$epgs][0]
			$ExpSig = $HistMatchArray[$epgs][1]
			If $epgs = 1 Then
				$ExpGidSid = $ExpGID & ',' & $ExpSig
			Else
				$ExpGidSid &= '-' & $ExpGID & ',' & $ExpSig
			EndIf
		Next

		FileWriteLine($savefile, $ExpSSID & '|' & $ExpBSSID & '|' & $ExpMANU & '|' & $ExpAUTH & '|' & $ExpENCR & '|' & $ExpSECTYPE & '|' & $ExpRAD & '|' & $ExpCHAN & '|' & $ExpBTX & '|' & $ExpOTX & '|' & $ExpNET & '|' & $ExpLAB & '|' & $ExpGidSid)
	Next
EndFunc   ;==>_ExportDetailedTXT

Func _ExportData();Saves data to a selected file
	_ExportDataGui(0)
EndFunc   ;==>_ExportData

Func _ExportFilteredData();Saves data to a selected file
	_ExportDataGui(1)
EndFunc   ;==>_ExportFilteredData

Func _ExportDataGui($Filter = 0);Saves data to a selected file
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_ExportData()') ;#Debug Display
	DirCreate($SaveDir)
	$file = FileSaveDialog($Text_SaveAsTXT, $SaveDir, 'Text (*.txt)', '', $ldatetimestamp & '.txt')
	If @error <> 1 Then
		If StringInStr($file, '.txt') = 0 Then $file = $file & '.txt'
		FileDelete($file)
		_ExportToTXT($file, $Filter)
		MsgBox(0, $Text_Done, $Text_SavedAs & ': "' & $file & '"')
		GUICtrlSetData($msgdisplay, '')
		$newdata = 0
	EndIf
EndFunc   ;==>_ExportDataGui

Func _ExportToTXT($savefile, $Filter = 0);writes vistumbler data to a txt file
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_ExportToTXT()') ;#Debug Display
	FileWriteLine($savefile, "# Vistumbler TXT - Export Version 2")
	FileWriteLine($savefile, "# Created By: " & $Script_Name & ' ' & $version)
	FileWriteLine($savefile, "# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------")
	FileWriteLine($savefile, "# SSID|BSSID|MANUFACTURER|Highest Signal w/GPS|Authetication|Encryption|Radio Type|Channel|Latitude|Longitude|Basic Transfer Rates|Other Transfer Rates|First Seen(UTC)|Last Seen(UTC)|Network Type|Label|Signal History")
	FileWriteLine($savefile, "# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------")
	If $Filter = 1 Then
		$query = $AddQuery
	Else
		$query = "SELECT ApID, SSID, BSSID, NETTYPE, RADTYPE, CHAN, AUTH, ENCR, SecType, BTX, OTX, MANU, LABEL, HighGpsHistID, FirstHistID, LastHistID, LastGpsID, Active FROM AP"
	EndIf
	Local $ApMatchArray, $iRows, $iColumns, $iRval
	$iRval = _SQLite_GetTable2d($DBhndl, $query, $ApMatchArray, $iRows, $iColumns)
	$FoundApMatch = $iRows
	For $exp = 1 To $FoundApMatch
		GUICtrlSetData($msgdisplay, $Text_SavingLine & ' ' & $exp & ' / ' & $FoundApMatch)
		$ExpApID = $ApMatchArray[$exp][0]
		$ExpSSID = $ApMatchArray[$exp][1]
		$ExpBSSID = $ApMatchArray[$exp][2]
		$ExpNET = $ApMatchArray[$exp][3]
		$ExpRAD = $ApMatchArray[$exp][4]
		$ExpCHAN = $ApMatchArray[$exp][5]
		$ExpAUTH = $ApMatchArray[$exp][6]
		$ExpENCR = $ApMatchArray[$exp][7]
		$ExpBTX = $ApMatchArray[$exp][9]
		$ExpOTX = $ApMatchArray[$exp][10]
		$ExpMANU = $ApMatchArray[$exp][11]
		$ExpLAB = $ApMatchArray[$exp][12]
		$ExpHighGpsID = $ApMatchArray[$exp][13]
		$ExpFirstID = $ApMatchArray[$exp][14]
		$ExpLastID = $ApMatchArray[$exp][15]

		;Get High GPS Signal
		If $ExpHighGpsID = 0 Then
			$ExpHighGpsSig = 0
			$ExpHighGpsLat = 'N 0000.0000'
			$ExpHighGpsLon = 'E 0000.0000'
		Else
			Local $HistMatchArray, $iRows, $iColumns, $iRval
			$query = "SELECT Signal, GpsID FROM Hist WHERE HistID = '" & $ExpHighGpsID & "'"
			$iRval = _SQLite_GetTable2d($DBhndl, $query, $HistMatchArray, $iRows, $iColumns)
			$ExpHighGpsSig = $HistMatchArray[1][0]
			$ExpHighGpsID = $HistMatchArray[1][1]
			Local $GpsMatchArray, $iRows, $iColumns, $iRval
			$query = "SELECT Latitude, Longitude FROM GPS WHERE GpsID = '" & $ExpHighGpsID & "'"
			$iRval = _SQLite_GetTable2d($DBhndl, $query, $GpsMatchArray, $iRows, $iColumns)
			$ExpHighGpsLat = $GpsMatchArray[1][0]
			$ExpHighGpsLon = $GpsMatchArray[1][1]
		EndIf

		;Get First Found Time From FirstHistID
		Local $HistMatchArray, $iRows, $iColumns, $iRval
		$query = "SELECT GpsID FROM Hist WHERE HistID = '" & $ExpFirstID & "'"
		$iRval = _SQLite_GetTable2d($DBhndl, $query, $HistMatchArray, $iRows, $iColumns)
		$ExpFirstGpsId = $HistMatchArray[1][0]
		Local $GpsMatchArray, $iRows, $iColumns, $iRval
		$query = "SELECT Date1, Time1 FROM GPS WHERE GpsID = '" & $ExpFirstGpsId & "'"
		$iRval = _SQLite_GetTable2d($DBhndl, $query, $GpsMatchArray, $iRows, $iColumns)
		$FirstDateTime = $GpsMatchArray[1][0] & ' ' & $GpsMatchArray[1][1]

		;Get Last Found Time From LastHistID
		Local $HistMatchArray, $iRows, $iColumns, $iRval
		$query = "SELECT GpsID FROM Hist WHERE HistID = '" & $ExpLastID & "'"
		$iRval = _SQLite_GetTable2d($DBhndl, $query, $HistMatchArray, $iRows, $iColumns)
		$ExpLastGpsId = $HistMatchArray[1][0]
		Local $GpsMatchArray, $iRows, $iColumns, $iRval
		$query = "SELECT Date1, Time1 FROM GPS WHERE GpsID = '" & $ExpLastGpsId & "'"
		$iRval = _SQLite_GetTable2d($DBhndl, $query, $GpsMatchArray, $iRows, $iColumns)
		$LastDateTime = $GpsMatchArray[1][0] & ' ' & $GpsMatchArray[1][1]

		;Get Signal History
		Local $HistMatchArray, $iRows, $iColumns, $iRval
		$query = "SELECT Signal FROM Hist WHERE ApID = '" & $ExpApID & "'"
		$iRval = _SQLite_GetTable2d($DBhndl, $query, $HistMatchArray, $iRows, $iColumns)
		$FoundHistMatch = $iRows
		For $esh = 1 To $FoundHistMatch
			If $esh = 1 Then
				$ExpSigHist = $HistMatchArray[$esh][0]
			Else
				$ExpSigHist &= '-' & $HistMatchArray[$esh][0]
			EndIf
		Next

		FileWriteLine($savefile, $ExpSSID & '|' & $ExpBSSID & '|' & $ExpMANU & '|' & $ExpHighGpsSig & '|' & $ExpAUTH & '|' & $ExpENCR & '|' & $ExpRAD & '|' & $ExpCHAN & '|' & $ExpHighGpsLat & '|' & $ExpHighGpsLon & '|' & $ExpBTX & '|' & $ExpOTX & '|' & $FirstDateTime & '|' & $LastDateTime & '|' & $ExpNET & '|' & $ExpLAB & '|' & $ExpSigHist)
	Next
EndFunc   ;==>_ExportToTXT

Func _ExportCsvData();Saves data to a selected file
	_ExportCsvDataGui(0)
EndFunc   ;==>_ExportCsvData

Func _ExportCsvFilteredData();Saves data to a selected file
	_ExportCsvDataGui(1)
EndFunc   ;==>_ExportCsvFilteredData

Func _ExportCsvDataGui($Gui_CsvFilter = 0);Saves data to a selected file
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_ExportCsvDataGui()') ;#Debug Display
	$Gui_Csv = GUICreate($Text_ExportToCSV, 543, 132)
	GUISetBkColor($BackgroundColor)
	$Gui_CsvFile = GUICtrlCreateInput($SaveDir & $ldatetimestamp & '.csv', 20, 20, 409, 21)
	$GUI_CsvSaveAs = GUICtrlCreateButton("Save As", 440, 20, 81, 22, $WS_GROUP)
	$Gui_CsvRadSummary = GUICtrlCreateRadio("Summary", 20, 50, 289, 20)
	GUICtrlSetState($Gui_CsvRadSummary, $GUI_CHECKED)
	$Gui_CsvRadDetailed = GUICtrlCreateRadio("Detailed", 20, 70, 289, 20)
	$Gui_CsvOk = GUICtrlCreateButton($Text_Ok, 128, 95, 97, 25, $WS_GROUP)
	$Gui_CsvCancel = GUICtrlCreateButton($Text_Cancel, 290, 95, 97, 25, $WS_GROUP)
	GUISetState(@SW_SHOW)
	GUICtrlSetOnEvent($GUI_CsvSaveAs, "_ExportCsvDataGui_SaveAs")
	GUICtrlSetOnEvent($Gui_CsvOk, "_ExportCsvDataGui_Ok")
	GUICtrlSetOnEvent($Gui_CsvCancel, "_ExportCsvDataGui_Close")
	GUISetOnEvent($GUI_EVENT_CLOSE, '_ExportCsvDataGui_Close')
EndFunc   ;==>_ExportCsvDataGui

Func _ExportCsvDataGui_Ok()
	$file = GUICtrlRead($Gui_CsvFile)
	$rad_summary = GUICtrlRead($Gui_CsvRadSummary)
	$rad_detailed = GUICtrlRead($Gui_CsvRadDetailed)
	_ExportCsvDataGui_Close()
	If StringInStr($file, '.csv') = 0 Then $file = $file & '.csv'
	FileDelete($file)
	If $rad_summary = 1 Then
		_ExportToCSV($file, $Gui_CsvFilter, 0)
	Else
		_ExportToCSV($file, $Gui_CsvFilter, 1)
	EndIf
	MsgBox(0, $Text_Done, $Text_SavedAs & ': "' & $file & '"')
	GUICtrlSetData($msgdisplay, '')
	$newdata = 0
EndFunc   ;==>_ExportCsvDataGui_Ok

Func _ExportCsvDataGui_SaveAs()
	$file = FileSaveDialog($Text_SaveAsTXT, $SaveDir, 'CSV (*.csv)', '', GUICtrlRead($Gui_CsvFile))
	If @error <> 1 Then GUICtrlSetData($Gui_CsvFile, $file)
EndFunc   ;==>_ExportCsvDataGui_SaveAs

Func _ExportCsvDataGui_Close()
	GUIDelete($EditMacGUIForm)
EndFunc   ;==>_ExportCsvDataGui_Close

Func _ExportToCSV($savefile, $Filter = 0, $Detailed = 0);writes vistumbler data to a csv file
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_ExportToCSV()') ;#Debug Display
	If $Filter = 1 Then
		$query = $AddQuery
	Else
		$query = "SELECT ApID, SSID, BSSID, NETTYPE, RADTYPE, CHAN, AUTH, ENCR, SecType, BTX, OTX, MANU, LABEL, HighGpsHistID, FirstHistID, LastHistID, LastGpsID, Active FROM AP"
	EndIf
	If $Detailed = 0 Then
		FileWriteLine($savefile, "SSID,BSSID,MANUFACTURER,HIGHEST SIGNAL W/GPS,AUTHENTICATION,ENCRYPTION,RADIO TYPE,CHANNEL,LATITUDE,LONGITUDE,BTX,OTX,FIRST SEEN(UTC),LAST SEEN(UTC),NETWORK TYPE,LABEL")
	ElseIf $Detailed = 1 Then
		FileWriteLine($savefile, "SSID,BSSID,MANUFACTURER,SIGNAL,AUTHENTICATION,ENCRYPTION,RADIO TYPE,CHANNEL,BTX,OTX,NETWORK TYPE,LABEL,LATITUDE,LONGITUDE,SATELLITES,HDOP,ALTITUDE,HEIGHT OF GEOID,SPEED(km/h),SPEED(MPH),TRACK ANGLE,DATE(UTC),TIME(UTC)")
	EndIf
	Local $ApMatchArray, $iRows, $iColumns, $iRval
	$iRval = _SQLite_GetTable2d($DBhndl, $query, $ApMatchArray, $iRows, $iColumns)
	$FoundApMatch = $iRows
	For $exp = 1 To $FoundApMatch
		GUICtrlSetData($msgdisplay, $Text_SavingLine & ' ' & $exp & ' / ' & $FoundApMatch)
		$ExpApID = $ApMatchArray[$exp][0]
		$ExpSSID = $ApMatchArray[$exp][1]
		$ExpBSSID = $ApMatchArray[$exp][2]
		$ExpNET = $ApMatchArray[$exp][3]
		$ExpRAD = $ApMatchArray[$exp][4]
		$ExpCHAN = $ApMatchArray[$exp][5]
		$ExpAUTH = $ApMatchArray[$exp][6]
		$ExpENCR = $ApMatchArray[$exp][7]
		$ExpBTX = $ApMatchArray[$exp][9]
		$ExpOTX = $ApMatchArray[$exp][10]
		$ExpMANU = $ApMatchArray[$exp][11]
		$ExpLAB = $ApMatchArray[$exp][12]
		$ExpHighGpsID = $ApMatchArray[$exp][13]
		$ExpFirstID = $ApMatchArray[$exp][14]
		$ExpLastID = $ApMatchArray[$exp][15]

		If $Detailed = 0 Then
			;Get High GPS Signal
			If $ExpHighGpsID = 0 Then
				$ExpHighGpsSig = 0
				$ExpHighGpsLat = 'N 0000.0000'
				$ExpHighGpsLon = 'E 0000.0000'
			Else
				Local $HistMatchArray, $iRows, $iColumns, $iRval
				$query = "SELECT Signal, GpsID FROM Hist WHERE HistID = '" & $ExpHighGpsID & "'"
				$iRval = _SQLite_GetTable2d($DBhndl, $query, $HistMatchArray, $iRows, $iColumns)
				$ExpHighGpsSig = $HistMatchArray[1][0]
				$ExpHighGpsID = $HistMatchArray[1][1]
				Local $GpsMatchArray, $iRows, $iColumns, $iRval
				$query = "SELECT Latitude, Longitude FROM GPS WHERE GpsID = '" & $ExpHighGpsID & "'"
				$iRval = _SQLite_GetTable2d($DBhndl, $query, $GpsMatchArray, $iRows, $iColumns)
				$ExpHighGpsLat = $GpsMatchArray[1][0]
				$ExpHighGpsLon = $GpsMatchArray[1][1]
			EndIf
			;Get First Found Time From FirstHistID
			Local $HistMatchArray, $iRows, $iColumns, $iRval
			$query = "SELECT GpsID FROM Hist WHERE HistID = '" & $ExpFirstID & "'"
			$iRval = _SQLite_GetTable2d($DBhndl, $query, $HistMatchArray, $iRows, $iColumns)
			$ExpFirstGpsId = $HistMatchArray[1][0]
			Local $GpsMatchArray, $iRows, $iColumns, $iRval
			$query = "SELECT Date1, Time1 FROM GPS WHERE GpsID = '" & $ExpFirstGpsId & "'"
			$iRval = _SQLite_GetTable2d($DBhndl, $query, $GpsMatchArray, $iRows, $iColumns)
			$FirstDateTime = $GpsMatchArray[1][0] & ' ' & $GpsMatchArray[1][1]
			;Get Last Found Time From LastHistID
			Local $HistMatchArray, $iRows, $iColumns, $iRval
			$query = "SELECT GpsID FROM Hist WHERE HistID = '" & $ExpLastID & "'"
			$iRval = _SQLite_GetTable2d($DBhndl, $query, $HistMatchArray, $iRows, $iColumns)
			$ExpLastGpsId = $HistMatchArray[1][0]
			Local $GpsMatchArray, $iRows, $iColumns, $iRval
			$query = "SELECT Date1, Time1 FROM GPS WHERE GpsID = '" & $ExpLastGpsId & "'"
			$iRval = _SQLite_GetTable2d($DBhndl, $query, $GpsMatchArray, $iRows, $iColumns)
			$LastDateTime = $GpsMatchArray[1][0] & ' ' & $GpsMatchArray[1][1]
			;Write summary csv line
			FileWriteLine($savefile, StringReplace($ExpSSID, ',', '') & ',' & $ExpBSSID & ',' & StringReplace($ExpMANU, ',', '') & ',' & $ExpHighGpsSig & ',' & $ExpAUTH & ',' & $ExpENCR & ',' & $ExpRAD & ',' & $ExpCHAN & ',' & StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($ExpHighGpsLat), 'S', '-'), 'N', ''), ' ', '') & ',' & StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($ExpHighGpsLon), 'W', '-'), 'E', ''), ' ', '') & ',' & $ExpBTX & ',' & $ExpOTX & ',' & $FirstDateTime & ',' & $LastDateTime & ',' & $ExpNET & ',' & StringReplace($ExpLAB, ',', ''))
		ElseIf $Detailed = 1 Then
			;Get All Signals and GpsIDs for current ApID
			Local $HistMatchArray, $iRows, $iColumns, $iRval
			$query = "SELECT GpsID, Signal FROM Hist WHERE ApID='" & $ExpApID & "' And Signal<>'0' ORDER BY Date1, Time1"
			$iRval = _SQLite_GetTable2d($DBhndl, $query, $HistMatchArray, $iRows, $iColumns)
			$FoundHistMatch = $iRows
			For $exph = 1 To $FoundHistMatch
				$ExpGID = $HistMatchArray[$exph][0]
				$ExpSig = $HistMatchArray[$exph][1]
				;Get GPS Data Based on GpsID
				Local $GpsMatchArray, $iRows, $iColumns, $iRval
				$query = "SELECT Latitude, Longitude, NumOfSats, HorDilPitch, Alt, Geo, SpeedInMPH, SpeedInKmH, TrackAngle, Date1, Time1 FROM GPS WHERE GpsID='" & $ExpGID & "'"
				$iRval = _SQLite_GetTable2d($DBhndl, $query, $GpsMatchArray, $iRows, $iColumns)
				$ExpLat = StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($GpsMatchArray[1][0]), 'S', '-'), 'N', ''), ' ', '')
				$ExpLon = StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($GpsMatchArray[1][1]), 'W', '-'), 'E', ''), ' ', '')
				$ExpSat = $GpsMatchArray[1][2]
				$ExpHorDilPitch = $GpsMatchArray[1][3]
				$ExpAlt = $GpsMatchArray[1][4]
				$ExpGeo = $GpsMatchArray[1][5]
				$ExpSpeedMPH = $GpsMatchArray[1][6]
				$ExpSpeedKmh = $GpsMatchArray[1][7]
				$ExpTrack = $GpsMatchArray[1][8]
				$ExpDate = $GpsMatchArray[1][9]
				$ExpTime = $GpsMatchArray[1][10]
				;Write detailed csv line
				FileWriteLine($savefile, '"' & $ExpSSID & '",' & $ExpBSSID & ',"' & $ExpMANU & '",' & $ExpSig & ',' & $ExpAUTH & ',' & $ExpENCR & ',' & $ExpRAD & ',' & $ExpCHAN & ',' & $ExpBTX & ',' & $ExpOTX & ',' & $ExpNET & ',"' & $ExpLAB & '",' & $ExpLat & ',' & $ExpLon & ',' & $ExpSat & ',' & $ExpHorDilPitch & ',' & $ExpAlt & ',' & $ExpGeo & ',' & $ExpSpeedKmh & ',' & $ExpSpeedMPH & ',' & $ExpTrack & ',' & $ExpDate & ',' & $ExpTime)
			Next
		EndIf
	Next
EndFunc   ;==>_ExportToCSV

Func _SaveGarminGPX($gpx, $MapOpenAPs = 1, $MapWepAps = 1, $MapSecAps = 1, $GpsTrack = 0, $Sanitize = 1)
	$FoundApWithGps = 0
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_SaveGarminGPX()') ;#Debug Display
	If StringInStr($gpx, '.gpx') = 0 Then $gpx = $gpx & '.gpx'
	FileDelete($gpx)
	$file = '<?xml version="1.0" encoding="UTF-8" standalone="no" ?>' & @CRLF _
			 & '<gpx xmlns="http://www.topografix.com/GPX/1/1" creator="Vistumbler ' & $version & '" version="1.1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd">' & @CRLF
	If $MapOpenAPs = 1 Then
		Local $ApMatchArray, $iRows, $iColumns, $iRval
		$query = "SELECT SSID, BSSID, HighGpsHistId FROM AP WHERE SECTYPE = '1' And HighGpsHistId <> '0'"
		$iRval = _SQLite_GetTable2d($DBhndl, $query, $ApMatchArray, $iRows, $iColumns)
		$FoundApMatch = $iRows
		If $FoundApMatch <> 0 Then
			$FoundApWithGps = 1
			For $exp = 1 To $FoundApMatch
				GUICtrlSetData($msgdisplay, 'Saving Open AP ' & $exp & '/' & $FoundApMatch)
				$ExpSSID = $ApMatchArray[$exp][0]
				If $Sanitize = 1 Then $ExpSSID = StringReplace(StringReplace(StringReplace($ExpSSID, '&', ''), '>', ''), '<', '')
				$ExpBSSID = $ApMatchArray[$exp][1]
				$ExpHighGpsHistID = $ApMatchArray[$exp][2]
				;Get Gps ID of HighGpsHistId
				Local $HistMatchArray, $iRows, $iColumns, $iRval
				$query = "SELECT GpsID FROM Hist Where HistID = '" & $ExpHighGpsHistID & "'"
				$iRval = _SQLite_GetTable2d($DBhndl, $query, $HistMatchArray, $iRows, $iColumns)
				$ExpGID = $HistMatchArray[1][0]
				;Get Latitude and Longitude
				Local $GpsMatchArray, $iRows, $iColumns, $iRval
				$query = "SELECT Latitude, Longitude, Alt, Date1, Time1 FROM GPS WHERE GpsId = '" & $ExpGID & "'"
				$iRval = _SQLite_GetTable2d($DBhndl, $query, $GpsMatchArray, $iRows, $iColumns)
				$ExpLat = StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($GpsMatchArray[1][0]), 'S', '-'), 'N', ''), ' ', '')
				$ExpLon = StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($GpsMatchArray[1][1]), 'W', '-'), 'E', ''), ' ', '')
				$ExpAlt = _MetersToFeet($GpsMatchArray[1][2])
				$ExpDate = $GpsMatchArray[1][3]
				$ExpTime = $GpsMatchArray[1][4]

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
		Local $ApMatchArray, $iRows, $iColumns, $iRval
		$query = "SELECT SSID, BSSID, HighGpsHistId FROM AP WHERE SECTYPE = '2' And HighGpsHistId <> '0'"
		$iRval = _SQLite_GetTable2d($DBhndl, $query, $ApMatchArray, $iRows, $iColumns)
		$FoundApMatch = $iRows
		If $FoundApMatch <> 0 Then
			$FoundApWithGps = 1
			For $exp = 1 To $FoundApMatch
				GUICtrlSetData($msgdisplay, 'Saving WEP AP ' & $exp & '/' & $FoundApMatch)
				$ExpSSID = $ApMatchArray[$exp][0]
				If $Sanitize = 1 Then $ExpSSID = StringReplace(StringReplace(StringReplace($ExpSSID, '&', ''), '>', ''), '<', '')
				$ExpBSSID = $ApMatchArray[$exp][1]
				$ExpHighGpsHistID = $ApMatchArray[$exp][2]

				;Get Gps ID of HighGpsHistId
				Local $HistMatchArray, $iRows, $iColumns, $iRval
				$query = "SELECT GpsID FROM Hist Where HistID = '" & $ExpHighGpsHistID & "'"
				$iRval = _SQLite_GetTable2d($DBhndl, $query, $HistMatchArray, $iRows, $iColumns)
				$ExpGID = $HistMatchArray[1][0]
				;Get Latitude and Longitude
				Local $GpsMatchArray, $iRows, $iColumns, $iRval
				$query = "SELECT Latitude, Longitude, Alt, Date1, Time1 FROM GPS WHERE GpsId = '" & $ExpGID & "'"
				$iRval = _SQLite_GetTable2d($DBhndl, $query, $GpsMatchArray, $iRows, $iColumns)
				$ExpLat = StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($GpsMatchArray[1][0]), 'S', '-'), 'N', ''), ' ', '')
				$ExpLon = StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($GpsMatchArray[1][1]), 'W', '-'), 'E', ''), ' ', '')
				$ExpAlt = _MetersToFeet($GpsMatchArray[1][2])
				$ExpDate = $GpsMatchArray[1][3]
				$ExpTime = $GpsMatchArray[1][4]

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
		Local $ApMatchArray, $iRows, $iColumns, $iRval
		$query = "SELECT SSID, BSSID, HighGpsHistId FROM AP WHERE SECTYPE = '3' And HighGpsHistId <> '0'"
		$iRval = _SQLite_GetTable2d($DBhndl, $query, $ApMatchArray, $iRows, $iColumns)
		$FoundApMatch = $iRows
		If $FoundApMatch <> 0 Then
			$FoundApWithGps = 1
			For $exp = 1 To $FoundApMatch
				GUICtrlSetData($msgdisplay, 'Saving Secure AP ' & $exp & '/' & $FoundApMatch)
				$ExpSSID = $ApMatchArray[$exp][0]
				If $Sanitize = 1 Then $ExpSSID = StringReplace(StringReplace(StringReplace($ExpSSID, '&', ''), '>', ''), '<', '')
				$ExpBSSID = $ApMatchArray[$exp][1]
				$ExpHighGpsHistID = $ApMatchArray[$exp][2]
				;Get Gps ID of HighGpsHistId
				Local $HistMatchArray, $iRows, $iColumns, $iRval
				$query = "SELECT GpsID FROM Hist Where HistID = '" & $ExpHighGpsHistID & "'"
				$iRval = _SQLite_GetTable2d($DBhndl, $query, $HistMatchArray, $iRows, $iColumns)
				$ExpGID = $HistMatchArray[1][0]
				;Get Latitude and Longitude
				Local $GpsMatchArray, $iRows, $iColumns, $iRval
				$query = "SELECT Latitude, Longitude, Alt, Date1, Time1 FROM GPS WHERE GpsId = '" & $ExpGID & "'"
				$iRval = _SQLite_GetTable2d($DBhndl, $query, $GpsMatchArray, $iRows, $iColumns)
				$ExpLat = StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($GpsMatchArray[1][0]), 'S', '-'), 'N', ''), ' ', '')
				$ExpLon = StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($GpsMatchArray[1][1]), 'W', '-'), 'E', ''), ' ', '')
				$ExpAlt = _MetersToFeet($GpsMatchArray[1][2])
				$ExpDate = $GpsMatchArray[1][3]
				$ExpTime = $GpsMatchArray[1][4]

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
		Local $GpsMatchArray, $iRows, $iColumns, $iRval
		$query = "SELECT Latitude, Longitude, Alt, Date1, Time1, SpeedInKmH FROM GPS WHERE Latitude <> 'N 0000.0000' And Longitude <> 'E 0000.0000' ORDER BY Date1, Time1"
		$iRval = _SQLite_GetTable2d($DBhndl, $query, $GpsMatchArray, $iRows, $iColumns)
		$FoundGpsMatch = $iRows
		If $FoundGpsMatch <> 0 Then
			$file &= '<trk>' & @CRLF _
					 & '<name>GPS Track</name>' & @CRLF _
					 & '<trkseg>' & @CRLF
			For $exp = 1 To $FoundGpsMatch
				GUICtrlSetData($msgdisplay, 'Saving Gps Position ' & $exp & '/' & $FoundGpsMatch)
				$ExpLat = StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($GpsMatchArray[$exp][0]), 'S', '-'), 'N', ''), ' ', '')
				$ExpLon = StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($GpsMatchArray[$exp][1]), 'W', '-'), 'E', ''), ' ', '')
				$ExpAlt = _MetersToFeet($GpsMatchArray[$exp][2])
				$ExpDate = $GpsMatchArray[$exp][3]
				$ExpTime = $GpsMatchArray[$exp][4]
				$ExpSpeedKmh = $GpsMatchArray[$exp][5]
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
		FileWrite($gpx, $file)
		Return (1)
	Else
		Return (0)
	EndIf
	;EndIf
EndFunc   ;==>_SaveGarminGPX

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
				$gpx = FileSaveDialog("Garmin Output File", $SaveDir, 'GPS eXchange Format (*.gpx)', '', $ldatetimestamp & '.gpx')
				If Not @error Then
					$saveGPX = _SaveGarminGPX($gpx, $MapOpen, $MapWEP, $MapSec, $ShowTrack)
					If $saveGPX = 1 Then
						MsgBox(0, $Text_Done, $Text_SavedAs & ': "' & $gpx & '"')
					Else
						MsgBox(0, $Text_Done, $Text_NoApsWithGps & ' ' & $Text_NoFileSaved)
					EndIf
				EndIf
				ExitLoop
		EndSwitch
	WEnd
	Opt("GUIOnEventMode", 1)
EndFunc   ;==>_SaveToGPX

Func _ExportVSZ()
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_ExportVSZ()') ;#Debug Display
	DirCreate($SaveDir)
	$file = FileSaveDialog($Text_SaveAsTXT, $SaveDir, $Text_VistumblerFile & ' (*.VSZ)', '', $ldatetimestamp & '.VSZ')
	If @error <> 1 Then
		If StringInStr($file, '.VSZ') = 0 Then $file = $file & '.VSZ'
		$vsz_temp_file = $TmpDir & 'data.zip'
		$vsz_file = $file
		$vs1_file = $TmpDir & 'data.vs1'
		If FileExists($vsz_temp_file) Then FileDelete($vsz_temp_file)
		If FileExists($vsz_file) Then FileDelete($vsz_file)
		If FileExists($vs1_file) Then FileDelete($vs1_file)
		_ExportDetailedTXT($vs1_file)
		_Zip_Create($vsz_temp_file)
		_Zip_AddFile($vsz_temp_file, $vs1_file)
		FileMove($vsz_temp_file, $vsz_file)
		FileDelete($vs1_file)
	EndIf
EndFunc   ;==>_ExportVSZ
;-------------------------------------------------------------------------------------------------------------------------------
;                                                       VISTUMBLER OPEN FUNCTIONS
;-------------------------------------------------------------------------------------------------------------------------------

Func LoadList()
	_LoadListGUI()
EndFunc   ;==>LoadList


Func _ExtractVSZ($vsz_file)
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
	GUISetState(@SW_MINIMIZE, $Vistumbler)

	$GUI_Import = GUICreate(StringReplace($Text_Import, "&", ""), 501, 245, -1, -1)
	GUISetBkColor($BackgroundColor)
	$vistumblerfileinput = GUICtrlCreateInput($imfile1, 8, 10, 377, 21)
	$browse1 = GUICtrlCreateButton($Text_Browse, 392, 8, 97, 25, $WS_GROUP)
	$RadVis = GUICtrlCreateRadio("Vistumbler file (VS1, VSZ)", 10, 40, 240, 20)
	GUICtrlSetState($RadVis, $GUI_CHECKED)
	$RadCsv = GUICtrlCreateRadio("Detailed Comma Delimited file (CSV)", 10, 60, 240, 20)
	$RadNs = GUICtrlCreateRadio("Netstumbler wi-scan (TXT, NS1)", 255, 40, 240, 20)
	$RadWD = GUICtrlCreateRadio("Wardrive-android file (DB3)", 255, 60, 240, 20)
	$NsOk = GUICtrlCreateButton($Text_Ok, 95, 95, 150, 25, $WS_GROUP)
	$NsCancel = GUICtrlCreateButton($Text_Close, 255, 95, 150, 25, $WS_GROUP)
	$progressbar = GUICtrlCreateProgress(10, 135, 480, 20)
	$percentlabel = GUICtrlCreateLabel($Text_Progress & ': ' & $Text_Ready, 10, 165, 230, 20)
	$linetotal = GUICtrlCreateLabel($Text_LineTotal & ':', 10, 190, 230, 20)
	$newlines = GUICtrlCreateLabel($Text_NewAPs & ':', 10, 215, 230, 20)

	$minutes = GUICtrlCreateLabel($Text_Minutes & ':', 260, 165, 230, 20)
	$linemin = GUICtrlCreateLabel($Text_LinesMin & ':', 260, 190, 230, 20)
	$estimatedtime = GUICtrlCreateLabel($Text_EstimatedTimeRemaining & ':', 260, 215, 230, 20)
	GUISetState(@SW_SHOW)

	GUICtrlSetOnEvent($browse1, "_ImportFileBrowse")
	GUICtrlSetOnEvent($NsOk, "_ImportOk")
	GUICtrlSetOnEvent($NsCancel, "_ImportClose")
	GUISetOnEvent($GUI_EVENT_CLOSE, '_ImportClose')
	If $imfile1 <> '' Then _ImportOk()
EndFunc   ;==>_LoadListGUI



Func _ImportFileBrowse()
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
	GUIDelete($GUI_Import)
	GUISetState(@SW_RESTORE, $Vistumbler)
EndFunc   ;==>_ImportClose

Func _ImportOk()
	GUICtrlSetData($percentlabel, $Text_Progress & ': ' & $Text_Loading)
	$UpdateTimer = TimerInit()
	$MemReleaseTimer = TimerInit()
	$loadfile = GUICtrlRead($vistumblerfileinput)
	$loadfileMD5 = _MD5ForFile($loadfile)

	Local $MD5MatchArray, $iRows, $iColumns, $iRval
	$query = "SELECT MD5 FROM LoadedFiles WHERE MD5='" & $loadfileMD5 & "'"
	$iRval = _SQLite_GetTable2d($DBhndl, $query, $MD5MatchArray, $iRows, $iColumns)
	$FoundMD5Match = $iRows

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
		GUICtrlSetData($percentlabel, $Text_Progress & ': ' & $Text_AddingApsIntoList)
		_FilterReAddMatchingNotInList()
		GUICtrlSetData($percentlabel, $Text_Progress & ': ' & $Text_SortingList)
		If $AddDirection = 0 Then
			$v_sort = True;set ascending
		Else
			$v_sort = False;set descending
		EndIf
		_GUICtrlListView_SimpleSort($ListviewAPs, $v_sort, $column_Line)
		_FixLineNumbers()
		$min = (TimerDiff($begintime) / 60000) ;convert from miniseconds to minutes
		GUICtrlSetData($minutes, $Text_Minutes & ': ' & Round($min, 1))
		GUICtrlSetData($progressbar, 100)
		GUICtrlSetState($NsOk, $GUI_ENABLE)
		If Not BitAND($closebtn, $BST_PUSHED) = $BST_PUSHED Then
			$query = "INSERT INTO LoadedFiles(File,MD5) VALUES ('" & $loadfile & "','" & $loadfileMD5 & "');"
			_SQLite_Exec($DBhndl, $query)
		EndIf
		GUICtrlSetData($percentlabel, $Text_Progress & ': ' & $Text_Done)
	EndIf
EndFunc   ;==>_ImportOk

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
				_SQLite_Exec($DBhndl, "BEGIN;")
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
				ElseIf $loadlist[0] = 13 Then ;If String is VS1 data line
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
							Local $TempGidMatchArray, $iRows, $iColumns, $iRval
							$query = "SELECT NewGpsID FROM TempGpsIDMatchTable WHERE OldGpsID = '" & $ImpGID & "'"
							$iRval = _SQLite_GetTable2d($DBhndl, $query, $TempGidMatchArray, $iRows, $iColumns)
							$TempGidMatchArrayMatch = $iRows
							If $TempGidMatchArrayMatch <> 0 Then
								$NewGID = $TempGidMatchArray[1][0]
								;Add AP Info to DB, Listview, and Treeview
								$NewApAdded = _AddApData(0, $NewGID, $BSSID, $SSID, $Channel, $Authentication, $Encryption, $NetworkType, $RadioType, $BasicTransferRates, $OtherTransferRates, $ImpSig)
								If $NewApAdded = 1 Then $AddAP += 1
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
					$FoundGpsMatch = $iRows
					If $FoundGpsMatch = 0 Then
						$AddGID += 1
						$GPS_ID += 1
						$query = "INSERT INTO GPS(GPSID,Latitude,Longitude,NumOfSats,HorDilPitch,Alt,Geo,SpeedInMPH,SpeedInKmH,TrackAngle,Date1,Time1) VALUES ('" & $GPS_ID & "','" & $LoadLatitude & "','" & $LoadLongitude & "','" & $LoadSat & "','0','0','0','0','0','0','" & $LoadFirstActive_Date & "','" & $LoadFirstActive_Time & "');"
						_SQLite_Exec($DBhndl, $query)
						$LoadGID = $GPS_ID
					Else
						$LoadGID = $GpsMatchArray[1][1]
					EndIf
					;Add First AP Info to DB, Listview, and Treeview
					$NewApAdded = _AddApData(0, $LoadGID, $BSSID, $SSID, $Channel, $Authentication, $Encryption, $NetworkType, $RadioType, $BasicTransferRates, $OtherTransferRates, $HighGpsSignal)
					If $NewApAdded = 1 Then $AddAP += 1
					;Check If Last GPS Information is Already in DB, If it is get the GpsID, If not add it and get its GpsID
					Local $GpsMatchArray, $iRows, $iColumns, $iRval
					$query = "SELECT GPSID FROM GPS WHERE Latitude = '" & $LoadLatitude & "' And Longitude = '" & $LoadLongitude & "' And Date1 = '" & $LoadLastActive_Date & "' And Time1 = '" & $LoadLastActive_Time & "'"
					$iRval = _SQLite_GetTable2d($DBhndl, $query, $GpsMatchArray, $iRows, $iColumns)
					$FoundGpsMatch = $iRows
					If $FoundGpsMatch = 0 Then
						$AddGID += 1
						$GPS_ID += 1
						$query = "INSERT INTO GPS(GPSID,Latitude,Longitude,NumOfSats,HorDilPitch,Alt,Geo,SpeedInMPH,SpeedInKmH,TrackAngle,Date1,Time1) VALUES ('" & $GPS_ID & "','" & $LoadLatitude & "','" & $LoadLongitude & "','" & $LoadSat & "','0','0','0','0','0','0','" & $LoadLastActive_Date & "','" & $LoadLastActive_Time & "');"
						_SQLite_Exec($DBhndl, $query)
						$LoadGID = $GPS_ID
					Else
						$LoadGID = $GpsMatchArray[1][1]
					EndIf
					;Add Last AP Info to DB, Listview, and Treeview
					$NewApAdded = _AddApData(0, $LoadGID, $BSSID, $SSID, $Channel, $Authentication, $Encryption, $NetworkType, $RadioType, $BasicTransferRates, $OtherTransferRates, $HighGpsSignal)
					If $NewApAdded = 1 Then $AddAP += 1
				Else
					;ExitLoop
				EndIf
				_SQLite_Exec($DBhndl, "COMMIT;")
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

Func _ImportCSV($CSVfile)
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
		If $iCol = 23 Then ;Import Vistumbler Detailed CSV
			For $lc = 1 To $iSize
				$s = $CSVArray[$lc][0]
				$r = $CSVArray[$lc][1]

				$ImpSSID = $CSVArray[$lc][0]
				If StringLeft($ImpSSID, 1) = '"' And StringRight($ImpSSID, 1) = '"' Then $ImpSSID = StringTrimLeft(StringTrimRight($ImpSSID, 1), 1)
				$ImpBSSID = $CSVArray[$lc][1]
				$ImpMANU = $CSVArray[$lc][2]
				If StringLeft($ImpMANU, 1) = '"' And StringRight($ImpMANU, 1) = '"' Then $ImpMANU = StringTrimLeft(StringTrimRight($ImpMANU, 1), 1)
				$ImpSig = $CSVArray[$lc][3]
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

				Local $GpsMatchArray, $iRows, $iColumns, $iRval
				$query = "SELECT GPSID FROM GPS WHERE Latitude = '" & $ImpLat & "' And Longitude = '" & $ImpLon & "' And NumOfSats = '" & $ImpSat & "' And Date1 = '" & $ImpDate & "' And Time1 = '" & $ImpTime & "'"
				$iRval = _SQLite_GetTable2d($DBhndl, $query, $GpsMatchArray, $iRows, $iColumns)
				$FoundGpsMatch = $iRows
				If $FoundGpsMatch = 0 Then
					$AddGID += 1
					$GPS_ID += 1
					;Add GPS ID
					$query = "INSERT INTO GPS(GPSID,Latitude,Longitude,NumOfSats,HorDilPitch,Alt,Geo,SpeedInMPH,SpeedInKmH,TrackAngle,Date1,Time1) VALUES ('" & $GPS_ID & "','" & $ImpLat & "','" & $ImpLon & "','" & $ImpSat & "','" & $ImpHDOP & "','" & $ImpAlt & "','" & $ImpGeo & "','" & $ImpSpeedMPH & "','" & $ImpSpeedKMH & "','" & $ImpTrackAngle & "','" & $ImpDate & "','" & $ImpTime & "');"
					_SQLite_Exec($DBhndl, $query)
					$ImpGID = $GPS_ID
				ElseIf $FoundGpsMatch = 1 Then
					$ImpGID = $GpsMatchArray[1][0]
				EndIf
				$NewApAdded = _AddApData(0, $ImpGID, $ImpBSSID, $ImpSSID, $ImpCHAN, $ImpAUTH, $ImpENCR, $ImpNET, $ImpRAD, $ImpBTX, $ImpOTX, $ImpSig)
				If $NewApAdded = 1 Then $AddAP += 1

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
		ElseIf $iCol = 16 Then ;Import Vistumbler Summary CSV
			For $lc = 1 To $iSize
				$ImpSSID = $CSVArray[$lc][0]
				If StringLeft($ImpSSID, 1) = '"' And StringRight($ImpSSID, 1) = '"' Then $ImpSSID = StringTrimLeft(StringTrimRight($ImpSSID, 1), 1)
				$ImpBSSID = $CSVArray[$lc][1]
				$ImpMANU = $CSVArray[$lc][2]
				If StringLeft($ImpMANU, 1) = '"' And StringRight($ImpMANU, 1) = '"' Then $ImpMANU = StringTrimLeft(StringTrimRight($ImpMANU, 1), 1)
				$ImpHighSig = $CSVArray[$lc][3]
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

				$tsplit = StringSplit($ImpFirstDateTime, ' ')
				$LoadFirstActive_Date = $tsplit[1]
				$LoadFirstActive_Time = $tsplit[2]

				$tsplit = StringSplit($ImpLastDateTime, ' ')
				$LoadLastActive_Date = $tsplit[1]
				$LoadLastActive_Time = $tsplit[2]

				;Check If First GPS Information is Already in DB, If it is get the GpsID, If not add it and get its GpsID
				Local $GpsMatchArray, $iRows, $iColumns, $iRval
				$query = "SELECT GPSID FROM GPS WHERE Latitude = '" & $ImpLat & "' And Longitude = '" & $ImpLon & "' And Date1 = '" & $LoadFirstActive_Date & "' And Time1 = '" & $LoadFirstActive_Time & "'"
				$iRval = _SQLite_GetTable2d($DBhndl, $query, $GpsMatchArray, $iRows, $iColumns)
				$FoundGpsMatch = $iRows
				If $FoundGpsMatch = 0 Then
					$AddGID += 1
					$GPS_ID += 1
					$query = "INSERT INTO GPS(GPSID,Latitude,Longitude,NumOfSats,HorDilPitch,Alt,Geo,SpeedInMPH,SpeedInKmH,TrackAngle,Date1,Time1) VALUES ('" & $GPS_ID & "','" & $ImpLat & "','" & $ImpLon & "','" & $ImpSat & "','0','0','0','0','0','0','" & $LoadFirstActive_Date & "','" & $LoadFirstActive_Time & "');"
					_SQLite_Exec($DBhndl, $query)
					$LoadGID = $GPS_ID
				Else
					$LoadGID = $GpsMatchArray[1][0]
				EndIf
				;Add First AP Info to DB, Listview, and Treeview
				$NewApAdded = _AddApData(0, $LoadGID, $ImpBSSID, $ImpSSID, $ImpCHAN, $ImpAUTH, $ImpENCR, $ImpNET, $ImpRAD, $ImpBTX, $ImpOTX, $ImpHighSig)
				If $NewApAdded = 1 Then $AddAP += 1
				;Check If Last GPS Information is Already in DB, If it is get the GpsID, If not add it and get its GpsID
				Local $GpsMatchArray, $iRows, $iColumns, $iRval
				$query = "SELECT GPSID FROM GPS WHERE Latitude = '" & $ImpLat & "' And Longitude = '" & $ImpLon & "' And Date1 = '" & $LoadLastActive_Date & "' And Time1 = '" & $LoadLastActive_Time & "'"
				$iRval = _SQLite_GetTable2d($DBhndl, $query, $GpsMatchArray, $iRows, $iColumns)
				$FoundGpsMatch = $iRows
				If $FoundGpsMatch = 0 Then
					$AddGID += 1
					$GPS_ID += 1
					$query = "INSERT INTO GPS(GPSID,Latitude,Longitude,NumOfSats,HorDilPitch,Alt,Geo,SpeedInMPH,SpeedInKmH,TrackAngle,Date1,Time1) VALUES ('" & $GPS_ID & "','" & $ImpLat & "','" & $ImpLon & "','" & $ImpSat & "','0','0','0','0','0','0','" & $LoadLastActive_Date & "','" & $LoadLastActive_Time & "');"
					_SQLite_Exec($DBhndl, $query)
					$LoadGID = $GPS_ID
				Else
					$LoadGID = $GpsMatchArray[1][1]
				EndIf
				;Add Last AP Info to DB, Listview, and Treeview
				$NewApAdded = _AddApData(0, $LoadGID, $ImpBSSID, $ImpSSID, $ImpCHAN, $ImpAUTH, $ImpENCR, $ImpNET, $ImpRAD, $ImpBTX, $ImpOTX, $ImpHighSig)
				If $NewApAdded = 1 Then $AddAP += 1

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
	Dim $BSSID_Array[1], $SSID_Array[1], $FirstSeen_Array[1], $LastSeen_Array[1], $SignalHist_Array[1], $Lat_Array[1], $Lon_Array[1], $Auth_Array[1], $Encr_Array[1], $Type_Array[1]
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
		;$Loading = 1

		For $Load = 1 To $totallines
			$linein = FileReadLine($netstumblerfile, $Load);Open Line in file
			If @error = -1 Then ExitLoop
			If StringInStr($linein, "# $DateGMT:") Then $Date = StringTrimLeft($linein, 12);If the date tag is found, set date
			If StringLeft($linein, 1) <> "#" Then ;If the line is not commented out, get AP information
				$array = StringSplit($linein, "	");Seperate AP information
				If $array[0] = 13 Then
					If $linein <> "" And IsArray($array) Then
						;Decode Flags
						$HexIn = Number("0x" & $array[9])
						Global $ESS = False, $nsimploopBSS = False, $CFPoll = False, $CFPollReq = False, $WEP = False, $ShortPreAm = False, $PBCC = False, $ChAgile = False
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
						$Signal = $snrarray1[2]
						If $Signal < 0 Then $Signal = '0'
						$LoadLatitude = _Format_GPS_All_to_DMM(StringReplace($array[1], "N 360.0000000", "N 0.0000000"))
						$LoadLongitude = _Format_GPS_All_to_DMM(StringReplace($array[2], "E 720.0000000", "E 0.0000000"))
						$Channel = $array[13]
						$DateTime = $Date & " " & $time

						Local $GpsMatchArray, $iRows, $iColumns, $iRval
						$query = "SELECT GPSID FROM GPS WHERE Latitude = '" & $LoadLatitude & "' And Longitude = '" & $LoadLongitude & "' And Date1 = '" & $Date & "' And Time1 = '" & $time & "'"
						$iRval = _SQLite_GetTable2d($DBhndl, $query, $GpsMatchArray, $iRows, $iColumns)
						$FoundGpsMatch = $iRows
						If $FoundGpsMatch = 0 Then
							$AddGID += 1
							$GPS_ID += 1
							$query = "INSERT INTO GPS(GPSID,Latitude,Longitude,NumOfSats,HorDilPitch,Alt,Geo,SpeedInMPH,SpeedInKmH,TrackAngle,Date1,Time1) VALUES ('" & $GPS_ID & "','" & $LoadLatitude & "','" & $LoadLongitude & "','00','0','0','0','0','0','0','" & $Date & "','" & $time & "');"
							_SQLite_Exec($DBhndl, $query)
							$LoadGID = $GPS_ID
						ElseIf $FoundGpsMatch = 1 Then
							$LoadGID = $GpsMatchArray[1][0]
						EndIf
						;Add Last AP Info to DB, Listview
						$NewApAdded = _AddApData(0, $LoadGID, $BSSID, $SSID, $Channel, $Authentication, $Encryption, $Type, $Text_Unknown, $Text_Unknown, $Text_Unknown, $Signal)
						If $NewApAdded = 1 Then $AddAP += 1
					EndIf
				Else
					ExitLoop
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

Func _WriteINI()
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_WriteINI()') ;#Debug Display
	;Get new order of columns to write back to INI
	$currentcolumn = StringSplit(_GUICtrlListView_GetColumnOrder($ListviewAPs), '|')
	;_ArrayDisplay($currentcolumn)
	For $c = 1 To $currentcolumn[0]
		If $column_Line = $currentcolumn[$c] Then $save_column_Line = $c - 1
		If $column_Active = $currentcolumn[$c] Then $save_column_Active = $c - 1
		If $column_BSSID = $currentcolumn[$c] Then $save_column_BSSID = $c - 1
		If $column_SSID = $currentcolumn[$c] Then $save_column_SSID = $c - 1
		If $column_Signal = $currentcolumn[$c] Then $save_column_Signal = $c - 1
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
	IniWrite($settings, "Vistumbler", "WiFiDbLocateRefreshTime", $WiFiDbLocateRefreshTime)
	IniWrite($settings, 'Vistumbler', 'Debug', $Debug)
	IniWrite($settings, 'Vistumbler', 'GraphDeadTime', $GraphDeadTime)
	IniWrite($settings, "Vistumbler", 'SaveGpsWithNoAps', $SaveGpsWithNoAps)
	IniWrite($settings, "Vistumbler", 'ShowEstimatedDB', $ShowEstimatedDB)
	IniWrite($settings, "Vistumbler", 'TimeBeforeMarkedDead', $TimeBeforeMarkedDead)
	IniWrite($settings, "Vistumbler", 'AutoSelect', $AutoSelect)
	IniWrite($settings, "Vistumbler", 'UseWiFiDbGpsLocate', $UseWiFiDbGpsLocate)
	IniWrite($settings, "Vistumbler", 'DefFiltID', $DefFiltID)

	IniWrite($settings, 'WindowPositions', 'VistumblerState', $VistumblerState)
	IniWrite($settings, 'WindowPositions', 'VistumblerPosition', $VistumblerPosition)
	IniWrite($settings, 'WindowPositions', 'CompassPosition', $CompassPosition)
	IniWrite($settings, 'WindowPositions', 'GpsDetailsPosition', $GpsDetailsPosition)

	IniWrite($settings, "DateFormat", "DateFormat", $DateFormat)

	IniWrite($settings, 'GpsSettings', 'ComPort', $ComPort)
	IniWrite($settings, 'GpsSettings', 'Baud', $BAUD)
	IniWrite($settings, 'GpsSettings', 'Parity', $PARITY)
	IniWrite($settings, 'GpsSettings', 'DataBit', $DATABIT)
	IniWrite($settings, 'GpsSettings', 'StopBit', $STOPBIT)
	IniWrite($settings, 'GpsSettings', 'GpsType', $GpsType)
	IniWrite($settings, 'GpsSettings', 'GPSformat', $GPSformat)
	IniWrite($settings, 'GpsSettings', 'GpsTimeout', $GpsTimeout)

	IniWrite($settings, "AutoSort", "AutoSortTime", $SortTime)
	IniWrite($settings, "AutoSort", "AutoSort", $AutoSort)
	IniWrite($settings, "AutoSort", "SortCombo", $SortBy)
	IniWrite($settings, "AutoSort", "AscDecDefault", $SortDirection)

	IniWrite($settings, "AutoSave", "AutoSave", $AutoSave)
	IniWrite($settings, "AutoSave", "AutoSaveDel", $AutoSaveDel)
	IniWrite($settings, "AutoSave", "AutoSaveTime", $SaveTime)

	IniWrite($settings, "Sound", 'PlaySoundOnNewAP', $SoundOnAP)
	IniWrite($settings, "Sound", "NewAP_Sound", $new_AP_sound)
	IniWrite($settings, "Sound", "Error_Sound", $ErrorFlag_sound)

	IniWrite($settings, "MIDI", 'SpeakSignal', $SpeakSignal)
	IniWrite($settings, "MIDI", 'SpeakSigSayPecent', $SpeakSigSayPecent)
	IniWrite($settings, "MIDI", 'SpeakSigTime', $SpeakSigTime)
	IniWrite($settings, "MIDI", 'SpeakType', $SpeakType)
	IniWrite($settings, "MIDI", 'Midi_Instument', $Midi_Instument)
	IniWrite($settings, "MIDI", 'Midi_PlayTime', $Midi_PlayTime)
	IniWrite($settings, "MIDI", 'Midi_PlayForActiveAps', $Midi_PlayForActiveAps)

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
	IniWrite($settings, 'AutoKML', 'GoogleEarth_EXE', $GoogleEarth_EXE)

	IniWrite($settings, 'KmlSettings', 'MapPos', $MapPos)
	IniWrite($settings, 'KmlSettings', 'MapSig', $MapSig)
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

	IniWrite($settings, 'PhilsWifiTools', 'Graph_URL', $PhilsGraphURL)
	IniWrite($settings, 'PhilsWifiTools', 'WiFiDB_URL', $PhilsWdbURL)

	IniWrite($settings, "Columns", "Column_Line", $save_column_Line)
	IniWrite($settings, "Columns", "Column_Active", $save_column_Active)
	IniWrite($settings, "Columns", "Column_BSSID", $save_column_BSSID)
	IniWrite($settings, "Columns", "Column_SSID", $save_column_SSID)
	IniWrite($settings, "Columns", "Column_Signal", $save_column_Signal)
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
	IniWrite($settings, "Columns", "Column_OtherTransferRates", $save_column_OtherTransferRates)
	IniWrite($settings, "Columns", "Column_FirstActive", $save_column_FirstActive)
	IniWrite($settings, "Columns", "Column_LastActive", $save_column_LastActive)

	IniWrite($settings, "Column_Width", "Column_Line", _GUICtrlListView_GetColumnWidth($ListviewAPs, $column_Line - 0))
	IniWrite($settings, "Column_Width", "Column_Active", _GUICtrlListView_GetColumnWidth($ListviewAPs, $column_Active - 0))
	IniWrite($settings, "Column_Width", "Column_BSSID", _GUICtrlListView_GetColumnWidth($ListviewAPs, $column_BSSID - 0))
	IniWrite($settings, "Column_Width", "Column_SSID", _GUICtrlListView_GetColumnWidth($ListviewAPs, $column_SSID - 0))
	IniWrite($settings, "Column_Width", "Column_Signal", _GUICtrlListView_GetColumnWidth($ListviewAPs, $column_Signal - 0))
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

	;//Write Changes to Language File
	IniWrite($DefaultLanguagePath, "Column_Names", "Column_Line", $Column_Names_Line)
	IniWrite($DefaultLanguagePath, "Column_Names", "Column_Active", $Column_Names_Active)
	IniWrite($DefaultLanguagePath, "Column_Names", "Column_SSID", $Column_Names_SSID)
	IniWrite($DefaultLanguagePath, "Column_Names", "Column_BSSID", $Column_Names_BSSID)
	IniWrite($DefaultLanguagePath, "Column_Names", "Column_Manufacturer", $Column_Names_MANUF)
	IniWrite($DefaultLanguagePath, "Column_Names", "Column_Signal", $Column_Names_Signal)
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
	IniWrite($DefaultLanguagePath, "GuiText", "AddAPsToTop", $Text_AddAPsToTop)
	IniWrite($DefaultLanguagePath, "GuiText", "Extra", $Text_Extra)
	IniWrite($DefaultLanguagePath, "GuiText", "ScanAPs", $Text_ScanAPs)
	IniWrite($DefaultLanguagePath, "GuiText", "StopScanAps", $Text_StopScanAps)
	IniWrite($DefaultLanguagePath, "GuiText", "UseGPS", $Text_UseGPS)
	IniWrite($DefaultLanguagePath, "GuiText", "StopGPS", $Text_StopGPS)
	IniWrite($DefaultLanguagePath, "GuiText", "Settings", $Text_Settings)
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
	IniWrite($DefaultLanguagePath, "GuiText", "PhilsPHPgraph", $Text_PhilsPHPgraph)
	IniWrite($DefaultLanguagePath, "GuiText", "PhilsWDB", $Text_PhilsWDB)
	IniWrite($DefaultLanguagePath, "GuiText", "UploadDataToWiFiDB", $Text_UploadDataToWifiDB)
	IniWrite($DefaultLanguagePath, "GuiText", "RefreshLoopTime", $Text_RefreshLoopTime)
	IniWrite($DefaultLanguagePath, "GuiText", "ActualLoopTime", $Text_ActualLoopTime)
	IniWrite($DefaultLanguagePath, "GuiText", "Longitude", $Text_Longitude)
	IniWrite($DefaultLanguagePath, "GuiText", "Latitude", $Text_Latitude)
	IniWrite($DefaultLanguagePath, "GuiText", "ActiveAPs", $Text_ActiveAPs)
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
	IniWrite($DefaultLanguagePath, 'GuiText', 'AutoSave', $Text_AutoSave)
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
	IniWrite($DefaultLanguagePath, 'GuiText', 'MacExistsOverwriteIt', $Text_MacExistsOverwriteIt)
	IniWrite($DefaultLanguagePath, 'GuiText', 'SavingLine', $Text_SavingLine)
	IniWrite($DefaultLanguagePath, 'GuiText', 'DisplayDebug', $Text_DisplayDebug)
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
	IniWrite($DefaultLanguagePath, 'GuiText', 'VistumblerFile', $Text_VistumblerFile)
	IniWrite($DefaultLanguagePath, 'GuiText', 'DetailedFile', $Text_DetailedCsvFile)
	IniWrite($DefaultLanguagePath, 'GuiText', 'NetstumblerTxtFile', $Text_NetstumblerTxtFile)
	IniWrite($DefaultLanguagePath, 'GuiText', 'ErrorOpeningGpsPort', $Text_ErrorOpeningGpsPort)
	IniWrite($DefaultLanguagePath, 'GuiText', 'SecondsSinceGpsUpdate', $Text_SecondsSinceGpsUpdate)
	IniWrite($DefaultLanguagePath, 'GuiText', 'SavingGID', $Text_SavingGID)
	IniWrite($DefaultLanguagePath, 'GuiText', 'SavingHistID', $Text_SavingHistID)
	IniWrite($DefaultLanguagePath, 'GuiText', 'NoUpdates', $Text_NoUpdates)
	IniWrite($DefaultLanguagePath, 'GuiText', 'NoActiveApFound', $Text_NoActiveApFound)
	IniWrite($DefaultLanguagePath, 'GuiText', 'VistumblerDonate', $Text_VistumblerDonate)
	IniWrite($DefaultLanguagePath, 'GuiText', 'VistumblerStore', $Text_VistumblerStore)
	IniWrite($DefaultLanguagePath, 'GuiText', 'SupportVistumbler', $Text_SupportVistumbler)
	IniWrite($DefaultLanguagePath, 'GuiText', 'UseNativeWifi', $Text_UseNativeWifi)
	IniWrite($DefaultLanguagePath, 'GuiText', 'FilterMsg', $Text_FilterMsg)
	IniWrite($DefaultLanguagePath, 'GuiText', 'SetFilters', $Text_SetFilters)
	IniWrite($DefaultLanguagePath, 'GuiText', 'Filtered', $Text_Filtered)
	IniWrite($DefaultLanguagePath, 'GuiText', 'Filters', $Text_Filters)
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
	IniWrite($DefaultLanguagePath, 'GuiText', 'AutoSelectConnectedAP', $Text_AutoSelectConnectedAP)
	IniWrite($DefaultLanguagePath, 'GuiText', 'Experimental', $Text_Experimental)
	IniWrite($DefaultLanguagePath, 'GuiText', 'Color', $Text_Color)
	IniWrite($DefaultLanguagePath, 'GuiText', 'PhilsWifiTools', $Text_PhilsWifiTools)
	IniWrite($DefaultLanguagePath, 'GuiText', 'AddRemFilters', $Text_AddRemFilters)
	IniWrite($DefaultLanguagePath, 'GuiText', 'NoFilterSelected', $Text_NoFilterSelected)
	IniWrite($DefaultLanguagePath, 'GuiText', 'AddFilter', $Text_AddFilter)
	IniWrite($DefaultLanguagePath, 'GuiText', 'EditFilter', $Text_EditFilter)
	IniWrite($DefaultLanguagePath, 'GuiText', 'DeleteFilter', $Text_DeleteFilter)
	IniWrite($DefaultLanguagePath, 'GuiText', 'TimeBeforeMarkedDead', $Text_TimeBeforeMarkedDead)
EndFunc   ;==>_WriteINI

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
	$ExportKMLGUI = GUICreate($Text_ExportToKML, 250, 285)
	GUISetBkColor($BackgroundColor)
	$GUI_ExportKML_PosMap = GUICtrlCreateCheckbox("Show GPS Position Map", 15, 15, 240, 15)
	If $MapPos = 1 Then GUICtrlSetState($GUI_ExportKML_PosMap, $GUI_CHECKED)
	$GUI_ExportKML_SigMap = GUICtrlCreateCheckbox("Show GPS Signal Map", 15, 35, 240, 15)
	If $MapSig = 1 Then GUICtrlSetState($GUI_ExportKML_SigMap, $GUI_CHECKED)
	$GUI_ExportKML_SigCir = GUICtrlCreateCheckbox("Use circle to show signal strength", 30, 55, 200, 15)
	GUICtrlCreateLabel($Text_Color & ":", 30, 75, 45, 15)
	$GUI_CirSigMapColor = GUICtrlCreateInput($CirSigMapColor, 75, 75, 75, 15)
	$GUI_CirSigMapColorBrowse = GUICtrlCreateButton($Text_Browse, 160, 72, 75, 20)
	If $MapSigType = 1 Then
		GUICtrlSetState($GUI_ExportKML_SigCir, $GUI_CHECKED)
	Else
		GUICtrlSetState($GUI_CirSigMapColor, $GUI_DISABLE)
		GUICtrlSetState($GUI_CirSigMapColorBrowse, $GUI_DISABLE)
	EndIf
	$GUI_ExportKML_RangeMap = GUICtrlCreateCheckbox("Show GPS Range Map", 15, 95, 240, 15)
	GUICtrlCreateLabel($Text_Color & ":", 30, 115, 45, 15)
	$GUI_CirRangeMapColor = GUICtrlCreateInput($CirRangeMapColor, 75, 115, 75, 15)
	$GUI_CirRangeMapColorBrowse = GUICtrlCreateButton($Text_Browse, 160, 112, 75, 20)
	If $MapRange = 1 Then
		GUICtrlSetState($GUI_ExportKML_RangeMap, $GUI_CHECKED)
	Else
		GUICtrlSetState($GUI_CirRangeMapColor, $GUI_DISABLE)
		GUICtrlSetState($GUI_CirRangeMapColorBrowse, $GUI_DISABLE)
	EndIf
	$GUI_ExportKML_DrawTrack = GUICtrlCreateCheckbox("Show GPS Track", 15, 135, 240, 15)
	GUICtrlCreateLabel($Text_Color & ":", 30, 155, 45, 15)
	$GUI_TrackColor = GUICtrlCreateInput($TrackColor, 75, 155, 75, 15)
	$GUI_TrackColorBrowse = GUICtrlCreateButton($Text_Browse, 160, 152, 75, 20)
	If $ShowTrack = 1 Then
		GUICtrlSetState($GUI_ExportKML_DrawTrack, $GUI_CHECKED)
	Else
		GUICtrlSetState($GUI_TrackColor, $GUI_DISABLE)
		GUICtrlSetState($GUI_TrackColorBrowse, $GUI_DISABLE)
	EndIf
	$GUI_ExportKML_MapOpen = GUICtrlCreateCheckbox($Text_MapOpenNetworks, 15, 175, 240, 15)
	If $MapOpen = 1 Then GUICtrlSetState($GUI_ExportKML_MapOpen, $GUI_CHECKED)
	$GUI_ExportKML_MapWEP = GUICtrlCreateCheckbox($Text_MapWepNetworks, 15, 195, 240, 15)
	If $MapWEP = 1 Then GUICtrlSetState($GUI_ExportKML_MapWEP, $GUI_CHECKED)
	$GUI_ExportKML_MapSec = GUICtrlCreateCheckbox($Text_MapSecureNetworks, 15, 215, 240, 15)
	If $MapSec = 1 Then GUICtrlSetState($GUI_ExportKML_MapSec, $GUI_CHECKED)

	$GUI_ExportKML_UseLocalImages = GUICtrlCreateCheckbox($Text_UseLocalImages, 15, 235, 240, 15)
	If $UseLocalKmlImagesOnExport = 1 Then GUICtrlSetState($GUI_ExportKML_UseLocalImages, $GUI_CHECKED)
	$GUI_ExportKML_OK = GUICtrlCreateButton($Text_Ok, 40, 255, 81, 25, 0)
	$GUI_ExportKML_Cancel = GUICtrlCreateButton($Text_Cancel, 139, 255, 81, 25, 0)
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
				If GUICtrlRead($GUI_ExportKML_PosMap) = 1 Then
					$MapPos = 1
				Else
					$MapPos = 0
				EndIf
				If GUICtrlRead($GUI_ExportKML_SigMap) = 1 Then
					$MapSig = 1
				Else
					$MapSig = 0
				EndIf
				If GUICtrlRead($GUI_ExportKML_RangeMap) = 1 Then
					$MapRange = 1
				Else
					$MapRange = 0
				EndIf
				If GUICtrlRead($GUI_ExportKML_DrawTrack) = 1 Then
					$ShowTrack = 1
				Else
					$ShowTrack = 0
				EndIf
				If GUICtrlRead($GUI_ExportKML_SigCir) = 1 Then
					$MapSigType = 1
				Else
					$MapSigType = 0
				EndIf
				If GUICtrlRead($GUI_ExportKML_MapOpen) = 1 Then
					$MapOpen = 1
				Else
					$MapOpen = 0
				EndIf
				If GUICtrlRead($GUI_ExportKML_MapWEP) = 1 Then
					$MapWEP = 1
				Else
					$MapWEP = 0
				EndIf
				If GUICtrlRead($GUI_ExportKML_MapSec) = 1 Then
					$MapSec = 1
				Else
					$MapSec = 0
				EndIf
				If GUICtrlRead($GUI_ExportKML_UseLocalImages) = 1 Then
					$UseLocalKmlImagesOnExport = 1
				Else
					$UseLocalKmlImagesOnExport = 0
				EndIf
				$TrackColor = GUICtrlRead($GUI_TrackColor)
				$CirSigMapColor = GUICtrlRead($GUI_CirSigMapColor)
				$CirRangeMapColor = GUICtrlRead($GUI_CirRangeMapColor)
				GUIDelete($ExportKMLGUI)
				DirCreate($SaveDirKml)
				$kml = FileSaveDialog("Google Earth Output File", $SaveDirKml, 'Google Earth (*.kml)', '', $ldatetimestamp & '.kml')
				If Not @error Then
					$savekml = SaveKML($kml, $UseLocalKmlImagesOnExport, $MapPos, $ShowTrack, $MapSig, $MapRange, $SelectedApID, $Filter, $MapSigType, $MapOpen, $MapWEP, $MapSec)
					If $savekml = 1 Then
						MsgBox(0, $Text_Done, $Text_SavedAs & ': "' & $kml & '"')
					Else
						MsgBox(0, $Text_Done, $Text_NoApsWithGps & ' ' & $Text_NoFileSaved)
					EndIf
				EndIf
				ExitLoop
		EndSwitch
	WEnd
	Opt("GUIOnEventMode", 1)
EndFunc   ;==>SaveToKmlGUI

Func SaveKML($kml, $KmlUseLocalImages = 1, $GpsPosMap = 0, $GpsTrack = 0, $GpsSigMap = 0, $GpsRangeMap = 0, $SelectedApID = 0, $Filter = 0, $SigMapType = 0, $MapOpenAPs = 1, $MapWepAps = 1, $MapSecAps = 1)
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, 'SaveKML()') ;#Debug Display
	Local $file_header
	Local $file_data
	Local $file_posdata
	Local $file_sigdata
	Local $file_rangedata
	Local $file_footer
	Local $FoundApWithGps
	Local $NewTimeString
	If StringInStr($kml, '.kml') = 0 Then $kml = $kml & '.kml'
	FileDelete($kml)

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
					$query = $AddQuery & " And SECTYPE='1' And HighGpsHistId<>'0' ORDER BY SSID"
				Else
					$query = $AddQuery & " WHERE SECTYPE='1' And HighGpsHistId<>'0' ORDER BY SSID"
				EndIf
			ElseIf $SelectedApID <> 0 Then
				$query = "SELECT ApID FROM AP WHERE ApID='" & $SelectedApID & "' And SECTYPE='1' And HighGpsHistId<>'0' ORDER BY SSID"
			Else
				$query = "SELECT ApID FROM AP WHERE SECTYPE='1' And HighGpsHistId<>'0' ORDER BY SSID"
			EndIf
			Local $ApMatchArray, $iRows, $iColumns, $iRval
			$iRval = _SQLite_GetTable2d($DBhndl, $query, $ApMatchArray, $iRows, $iColumns)
			$FoundApMatch = $iRows
			If $FoundApMatch <> 0 Then
				$FoundApWithGps = 1
				If $GpsPosMap = 1 Then $file_posdata &= '		<Folder>' & @CRLF & '			<name>Open Access Points</name>' & @CRLF
				If $GpsSigMap = 1 Then $file_sigdata &= '		<Folder>' & @CRLF & '			<name>Open Access Points</name>' & @CRLF
				If $GpsRangeMap = 1 Then $file_rangedata &= '		<Folder>' & @CRLF & '			<name>Open Access Points</name>' & @CRLF
				For $exp = 1 To $FoundApMatch
					GUICtrlSetData($msgdisplay, 'Saving Open AP ' & $exp & '/' & $FoundApMatch)
					$ExpApID = $ApMatchArray[$exp][0]
					If $GpsPosMap = 1 Then $file_posdata &= _KmlPosMapAPID($ExpApID)
					If $GpsSigMap = 1 And $SigMapType = 0 Then $file_sigdata &= _KmlSignalMapAPID($ExpApID)
					If $GpsSigMap = 1 And $SigMapType = 1 Then $file_sigdata &= _KmlCircleSignalMapAPID($ExpApID)
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
					$query = $AddQuery & " And SECTYPE='2' And HighGpsHistId<>'0' ORDER BY SSID"
				Else
					$query = $AddQuery & " WHERE SECTYPE='2' And HighGpsHistId<>'0' ORDER BY SSID"
				EndIf
			ElseIf $SelectedApID <> 0 Then
				$query = "SELECT ApID FROM AP WHERE ApID='" & $SelectedApID & "' And SECTYPE='2' And HighGpsHistId<>'0' ORDER BY SSID"
			Else
				$query = "SELECT ApID FROM AP WHERE SECTYPE='2' And HighGpsHistId<>'0' ORDER BY SSID"
			EndIf
			Local $ApMatchArray, $iRows, $iColumns, $iRval
			$iRval = _SQLite_GetTable2d($DBhndl, $query, $ApMatchArray, $iRows, $iColumns)
			$FoundApMatch = $iRows
			If $FoundApMatch <> 0 Then
				$FoundApWithGps = 1
				If $GpsPosMap = 1 Then $file_posdata &= '		<Folder>' & @CRLF & '			<name>WEP Access Points</name>' & @CRLF
				If $GpsSigMap = 1 Then $file_sigdata &= '		<Folder>' & @CRLF & '			<name>WEP Access Points</name>' & @CRLF
				If $GpsRangeMap = 1 Then $file_rangedata &= '		<Folder>' & @CRLF & '			<name>WEP Access Points</name>' & @CRLF
				For $exp = 1 To $FoundApMatch
					GUICtrlSetData($msgdisplay, 'Saving WEP AP ' & $exp & '/' & $FoundApMatch)
					$ExpApID = $ApMatchArray[$exp][1]
					If $GpsPosMap = 1 Then $file_posdata &= _KmlPosMapAPID($ExpApID)
					If $GpsSigMap = 1 And $SigMapType = 0 Then $file_sigdata &= _KmlSignalMapAPID($ExpApID)
					If $GpsSigMap = 1 And $SigMapType = 1 Then $file_sigdata &= _KmlCircleSignalMapAPID($ExpApID)
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
					$query = $AddQuery & " And SECTYPE='3' And HighGpsHistId<>'0' ORDER BY SSID"
				Else
					$query = $AddQuery & " WHERE SECTYPE='3' And HighGpsHistId<>'0' ORDER BY SSID"
				EndIf
			ElseIf $SelectedApID <> 0 Then
				$query = "SELECT ApID FROM AP WHERE ApID='" & $SelectedApID & "' And SECTYPE='3' And HighGpsHistId<>'0' ORDER BY SSID"
			Else
				$query = "SELECT ApID FROM AP WHERE SECTYPE='3' And HighGpsHistId<>'0' ORDER BY SSID"
			EndIf
			Local $ApMatchArray, $iRows, $iColumns, $iRval
			$iRval = _SQLite_GetTable2d($DBhndl, $query, $ApMatchArray, $iRows, $iColumns)
			$FoundApMatch = $iRows
			If $FoundApMatch <> 0 Then
				$FoundApWithGps = 1
				If $GpsPosMap = 1 Then $file_posdata &= '		<Folder>' & @CRLF & '			<name>Secure Access Points</name>' & @CRLF
				If $GpsSigMap = 1 Then $file_sigdata &= '		<Folder>' & @CRLF & '			<name>Secure Access Points</name>' & @CRLF
				If $GpsRangeMap = 1 Then $file_rangedata &= '		<Folder>' & @CRLF & '			<name>Secure Access Points</name>' & @CRLF
				For $exp = 1 To $FoundApMatch
					GUICtrlSetData($msgdisplay, 'Saving Secure AP ' & $exp & '/' & $FoundApMatch)
					$ExpApID = $ApMatchArray[$exp][1]
					If $GpsPosMap = 1 Then $file_posdata &= _KmlPosMapAPID($ExpApID)
					If $GpsSigMap = 1 And $SigMapType = 0 Then $file_sigdata &= _KmlSignalMapAPID($ExpApID)
					If $GpsSigMap = 1 And $SigMapType = 1 Then $file_sigdata &= _KmlCircleSignalMapAPID($ExpApID)
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
		Local $GpsMatchArray, $iRows, $iColumns, $iRval
		$query = "SELECT Latitude, Longitude, Date1, Time1 FROM GPS WHERE Latitude <> 'N 0000.0000' And Longitude <> 'E 0000.0000' ORDER BY Date1, Time1"
		$iRval = _SQLite_GetTable2d($DBhndl, $query, $GpsMatchArray, $iRows, $iColumns)
		$FoundGpsMatch = $iRows
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
		FileWrite($kml, $file_header & $file_data & $file_footer)
		Return (1)
	Else
		Return (0)
	EndIf
	;EndIf
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
		Local $ListRowMatchArray, $iRows, $iColumns, $iRval
		$query = "SELECT ApID, SSID FROM AP WHERE ListRow = '" & $Selected & "'"
		$iRval = _SQLite_GetTable2d($DBhndl, $query, $ListRowMatchArray, $iRows, $iColumns)
		$ExpApID = $ListRowMatchArray[1][0]
		SaveToKmlGUI(0, $ExpApID)
	EndIf
EndFunc   ;==>_KmlSignalMapSelectedAP

Func _KmlPosMapAPID($APID)
	Local $file_data
	Local $ApMatchArray, $iRows, $iColumns, $iRval
	$query = "SELECT SSID, BSSID, NETTYPE, RADTYPE, CHAN, AUTH, ENCR, BTX, OTX, MANU, LABEL, HighGpsHistID, FirstHistID, LastHistID, SecType FROM AP WHERE ApID='" & $APID & "'"
	$iRval = _SQLite_GetTable2d($DBhndl, $query, $ApMatchArray, $iRows, $iColumns)
	$ExpSSID = StringReplace(StringReplace(StringReplace($ApMatchArray[1][0], '&', ''), '>', ''), '<', '')
	$ExpBSSID = $ApMatchArray[1][1]
	$ExpNET = $ApMatchArray[1][2]
	$ExpRAD = $ApMatchArray[1][3]
	$ExpCHAN = $ApMatchArray[1][4]
	$ExpAUTH = $ApMatchArray[1][5]
	$ExpENCR = $ApMatchArray[1][6]
	$ExpBTX = $ApMatchArray[1][7]
	$ExpOTX = $ApMatchArray[1][8]
	$ExpMANU = $ApMatchArray[1][9]
	$ExpLAB = $ApMatchArray[1][10]
	$ExpHighGpsHistID = $ApMatchArray[1][11]
	$ExpFirstID = $ApMatchArray[1][12]
	$ExpLastID = $ApMatchArray[1][13]
	$ExpSECTYPE = $ApMatchArray[1][14]

	;Get Gps ID of HighGpsHistId
	Local $HistMatchArray, $iRows, $iColumns, $iRval
	$query = "SELECT GpsID FROM Hist Where HistID = '" & $ExpHighGpsHistID & "'"
	$iRval = _SQLite_GetTable2d($DBhndl, $query, $HistMatchArray, $iRows, $iColumns)
	$ExpGID = $HistMatchArray[1][0]
	;Get Latitude and Longitude
	Local $GpsMatchArray, $iRows, $iColumns, $iRval
	$query = "SELECT Latitude, Longitude FROM GPS WHERE GpsId = '" & $ExpGID & "'"
	$iRval = _SQLite_GetTable2d($DBhndl, $query, $GpsMatchArray, $iRows, $iColumns)
	$ExpLat = _Format_GPS_DMM_to_DDD($GpsMatchArray[1][0])
	$ExpLon = _Format_GPS_DMM_to_DDD($GpsMatchArray[1][1])
	If $ExpLat <> 'N 0.0000000' And $ExpLon <> 'E 0.0000000' Then
		;Get First Seen
		Local $HistMatchArray, $iRows, $iColumns, $iRval
		$query = "SELECT GpsId FROM Hist Where HistID = '" & $ExpFirstID & "'"
		$iRval = _SQLite_GetTable2d($DBhndl, $query, $HistMatchArray, $iRows, $iColumns)
		$ExpGID = $HistMatchArray[1][0]
		Local $GpsMatchArray, $iRows, $iColumns, $iRval
		$query = "SELECT Date1, Time1 FROM GPS WHERE GpsId = '" & $ExpGID & "'"
		$iRval = _SQLite_GetTable2d($DBhndl, $query, $GpsMatchArray, $iRows, $iColumns)
		$ExpFirstDateTime = $GpsMatchArray[1][0] & ' ' & $GpsMatchArray[1][1]
		;Get Last Seen
		Local $HistMatchArray, $iRows, $iColumns, $iRval
		$query = "SELECT GpsId FROM Hist Where HistID = '" & $ExpLastID & "'"
		$iRval = _SQLite_GetTable2d($DBhndl, $query, $HistMatchArray, $iRows, $iColumns)
		$ExpGID = $HistMatchArray[1][0]
		Local $GpsMatchArray, $iRows, $iColumns, $iRval
		$query = "SELECT Date1, Time1 FROM GPS WHERE GpsId = '" & $ExpGID & "'"
		$iRval = _SQLite_GetTable2d($DBhndl, $query, $GpsMatchArray, $iRows, $iColumns)
		$ExpLastDateTime = $GpsMatchArray[1][0] & ' ' & $GpsMatchArray[1][1]

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

Func _KmlSignalMapAPID($APID)
	Local $file
	Local $SigData = 0
	Local $SigStrengthLevel = 0
	Local $ExpString
	Local $NewTimeString
	Local $ApIDMatch, $iRows, $iColumns, $iRval
	$query = "SELECT SSID, BSSID FROM AP WHERE ApID='" & $APID & "'"
	$iRval = _SQLite_GetTable2d($DBhndl, $query, $ApIDMatch, $iRows, $iColumns)
	$ExpSSID = StringReplace(StringReplace(StringReplace($ApIDMatch[1][0], '&', ''), '>', ''), '<', '')
	$ExpBSSID = $ApIDMatch[1][1]
	Local $GpsIDArray, $iRows, $iColumns, $iRval
	$query = "SELECT GpsID, Signal, Date1, Time1 FROM Hist Where ApID='" & $APID & "' And Signal<>'0' ORDER BY Date1, Time1 ASC"
	$iRval = _SQLite_GetTable2d($DBhndl, $query, $GpsIDArray, $iRows, $iColumns)
	$GpsIDMatch = $iRows
	If $GpsIDMatch <> 0 Then
		For $e = 1 To $GpsIDMatch
			$ExpGID = $GpsIDArray[$e][0]
			$ExpSig = $GpsIDArray[$e][1]
			$ExpDate = StringReplace($GpsIDArray[$e][2], '-', '')
			$ExpTime = $GpsIDArray[$e][3]
			$dts = StringSplit($ExpTime, ":") ;Split time so it can be converted to seconds
			$ExpTime = ($dts[1] * 3600) + ($dts[2] * 60) + $dts[3] ;In seconds
			$LastTimeString = $NewTimeString
			$NewTimeString = $ExpDate & StringFormat("%05i", $ExpTime)
			If $LastTimeString = '' Then $LastTimeString = $NewTimeString
			;Get Latidude and logitude
			Local $GpsArray, $iRows, $iColumns, $iRval
			$query = "SELECT Longitude, Latitude, Alt FROM GPS Where GpsID='" & $ExpGID & "'"
			$iRval = _SQLite_GetTable2d($DBhndl, $query, $GpsArray, $iRows, $iColumns)
			$ExpLon = StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($GpsArray[1][0]), 'W', '-'), 'E', ''), ' ', '')
			$ExpLat = StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($GpsArray[1][1]), 'S', '-'), 'N', ''), ' ', '')
			$ExpAlt = $GpsArray[1][2]
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

				$ExpString = '					' & $ExpLon & ',' & $ExpLat & ',' & $ExpSig & @CRLF
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

Func _KmlCircleSignalMapAPID($APID)
	Local $file
	Local $ApIDMatch, $iRows, $iColumns, $iRval
	$query = "SELECT SSID, BSSID, HighGpsHistID FROM AP WHERE ApID='" & $APID & "'"
	$iRval = _SQLite_GetTable2d($DBhndl, $query, $ApIDMatch, $iRows, $iColumns)
	$ExpSSID = StringReplace(StringReplace(StringReplace($ApIDMatch[1][0], '&', ''), '>', ''), '<', '')
	$ExpBSSID = $ApIDMatch[1][1]
	$ExpHighGpsHistID = $ApIDMatch[1][2]
	If $ExpHighGpsHistID <> '0' Then
		Local $HistIDArray, $iRows, $iColumns, $iRval
		$query = "SELECT Signal, GpsID FROM Hist WHERE HistID='" & $ExpHighGpsHistID & "'"
		$iRval = _SQLite_GetTable2d($DBhndl, $query, $HistIDArray, $iRows, $iColumns)
		$ExpSig = $HistIDArray[1][0]
		$ExpHighGpsID = $HistIDArray[1][1]
		Local $GpsIDArray, $iRows, $iColumns, $iRval
		$query = "SELECT Longitude, Latitude FROM GPS Where GpsID='" & $ExpHighGpsID & "'"
		$iRval = _SQLite_GetTable2d($DBhndl, $query, $GpsIDArray, $iRows, $iColumns)
		$ExpLon = $GpsIDArray[1][0]
		$ExpLat = $GpsIDArray[1][1]
		$file &= '	<Folder>' & @CRLF _
				 & '		<name>' & $ExpSSID & ' - ' & $ExpBSSID & '</name>' & @CRLF
		$file &= _KmlDrawCircle($ExpLat, $ExpLon, $ExpSig, 'SigCircleColor')
		$file &= '	</Folder>' & @CRLF
	EndIf
	Return ($file)
EndFunc   ;==>_KmlCircleSignalMapAPID

Func _KmlCircleDistanceMapAPID($APID)
	Local $file
	Local $ExpDist = 10
	Local $ApIDMatch, $iRows, $iColumns, $iRval
	$query = "SELECT SSID, BSSID, HighGpsHistID FROM AP WHERE ApID='" & $APID & "'"
	$iRval = _SQLite_GetTable2d($DBhndl, $query, $ApIDMatch, $iRows, $iColumns)
	$ExpSSID = StringReplace(StringReplace(StringReplace($ApIDMatch[1][0], '&', ''), '>', ''), '<', '')
	$ExpBSSID = $ApIDMatch[1][1]
	$ExpHighGpsHistID = $ApIDMatch[1][2]
	If $ExpHighGpsHistID <> '0' Then
		Local $HistIDArray, $iRows, $iColumns, $iRval
		$query = "SELECT Signal, GpsID FROM Hist WHERE HistID='" & $ExpHighGpsHistID & "'"
		$iRval = _SQLite_GetTable2d($DBhndl, $query, $HistIDArray, $iRows, $iColumns)
		$ExpSig = $HistIDArray[1][0]
		$ExpHighGpsID = $HistIDArray[1][1]
		Local $GpsIDArray, $iRows, $iColumns, $iRval
		$query = "SELECT Longitude, Latitude FROM GPS Where GpsID='" & $ExpHighGpsID & "'"
		$iRval = _SQLite_GetTable2d($DBhndl, $query, $GpsIDArray, $iRows, $iColumns)
		$ExpLon = $GpsIDArray[1][0]
		$ExpLat = $GpsIDArray[1][1]
		;Find Outside Gps Point
		Local $HistIDArray, $iRows, $iColumns, $iRval
		$query = "SELECT GpsID FROM Hist WHERE ApID='" & $APID & "'"
		$iRval = _SQLite_GetTable2d($DBhndl, $query, $HistIDArray, $iRows, $iColumns)
		$HistIDMatch = $iRows
		If $HistIDMatch <> 0 Then
			For $gid = 1 To $HistIDMatch
				$ExpGpsID = $HistIDArray[$gid][0]
				Local $GpsIDArray, $iRows, $iColumns, $iRval
				$query = "SELECT Longitude, Latitude FROM GPS Where GpsID='" & $ExpGpsID & "'"
				$iRval = _SQLite_GetTable2d($DBhndl, $query, $GpsIDArray, $iRows, $iColumns)
				$ExpLon2 = $GpsIDArray[1][0]
				$ExpLat2 = $GpsIDArray[1][1]
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
		If FileExists($GoogleEarth_EXE) Then
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
				Run('"' & $GoogleEarth_EXE & '" "' & $kml & '"')
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
	$FileName = FileSaveDialog($Text_SaveAsTXT, $SaveDir, $Text_NetstumblerTxtFile & ' (*.NS1)', '', $ldatetimestamp & '.NS1')
	If @error <> 1 Then
		FileDelete($FileName)
		$APID1 = ''
		$Date1 = ''

		$file = "# $Creator: " & $Script_Name & " " & $version & @CRLF & _
				"# $Format: wi-scan summary with extensions" & @CRLF & _
				"# Latitude	Longitude	( SSID )	Type	( BSSID )	Time (GMT)	[ SNR Sig Noise ]	# ( Name )	Flags	Channelbits	BcnIntvl	DataRate	LastChannel" & @CRLF

		Local $HistMatchArray, $iRows, $iColumns, $iRval
		$query = "SELECT ApID, GpsID, Signal, Date1, Time1 FROM Hist ORDER BY Date1, Time1"
		$iRval = _SQLite_GetTable2d($DBhndl, $query, $HistMatchArray, $iRows, $iColumns)
		$FoundHistMatch = $iRows
		For $exns1 = 1 To $FoundHistMatch
			GUICtrlSetData($msgdisplay, $Text_SavingHistID & ' ' & $exns1 & ' / ' & $FoundHistMatch)
			$Found_APID = $HistMatchArray[$exns1][0]
			If $Found_APID <> $APID1 Then
				$Found_GpsID = $HistMatchArray[$exns1][1]
				$Found_Sig = $HistMatchArray[$exns1][2]
				$Found_Date = $HistMatchArray[$exns1][3]
				$Found_Time = StringTrimRight($HistMatchArray[$exns1][4], 4)
				Local $ApMatchArray, $iRows, $iColumns, $iRval
				$query = "SELECT Latitude, Longitude FROM GPS WHERE GpsID = '" & $Found_GpsID & "'"
				$iRval = _SQLite_GetTable2d($DBhndl, $query, $ApMatchArray, $iRows, $iColumns)
				$Found_Lat = _Format_GPS_DMM_to_DDD($ApMatchArray[1][0])
				$Found_Lon = _Format_GPS_DMM_to_DDD($ApMatchArray[1][1])
				Local $ApMatchArray, $iRows, $iColumns, $iRval
				$query = "SELECT SSID, BSSID, SecType, NETTYPE, CHAN, BTX, OTX, LABEL, MANU FROM AP WHERE ApID = '" & $Found_APID & "'"
				$iRval = _SQLite_GetTable2d($DBhndl, $query, $ApMatchArray, $iRows, $iColumns)
				$Found_SSID = $ApMatchArray[1][0]
				$Found_BSSID = $ApMatchArray[1][1]
				$Found_SecType = $ApMatchArray[1][2]
				$Found_NETTYPE = $ApMatchArray[1][3]
				$Found_CHAN = $ApMatchArray[1][4]
				$Found_BTX = $ApMatchArray[1][5]
				$Found_OTX = $ApMatchArray[1][6]
				$Found_LAB = $ApMatchArray[1][7]
				$Found_MANU = $ApMatchArray[1][8]

				If $Found_Date <> $Date1 Then
					$Date1 = $Found_Date
					$file &= "# $DateGMT: " & $Date1 & @CRLF
				EndIf

				$otxarray = StringSplit($Found_OTX, " ")
				If IsArray($otxarray) Then
					$Radio = $otxarray[$otxarray[0]] * 10
				Else
					$btxarray = StringSplit($Found_BTX, " ")
					If IsArray($btxarray) Then
						$Radio = $btxarray[$btxarray[0]] * 10
					Else
						$Radio = 0
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
			$file &= $Found_Lat & "	" & $Found_Lon & "	( " & $Found_SSID & " )	" & $BSS & "	( " & $Found_BSSID & " )	" & $Found_Time & " (GMT)	[ " & $Found_Sig & " " & $Found_Sig + 50 & " 50 ]	# ( " & $Found_LAB & ' - ' & $Found_MANU & " )	" & $Flags & "	" & $CHAN & "	1000	" & $Radio & "	" & $Found_CHAN & @CRLF
		Next
		FileWrite($FileName, $file)
	Else
		MsgBox(0, $Text_Error, $Text_NoFileSaved)
	EndIf
EndFunc   ;==>_ExportNS1

;-------------------------------------------------------------------------------------------------------------------------------
;                                                       SETTINGS WINDOW FUNCTIONS
;-------------------------------------------------------------------------------------------------------------------------------

Func _SettingsGUI_Misc();Opens GUI to Misc tab
	$Apply_Misc = 1
	_SettingsGUI(0)
EndFunc   ;==>_SettingsGUI_Misc

Func _SettingsGUI_GPS();Opens GUI to GPS tab
	$Apply_GPS = 1
	_SettingsGUI(1)
EndFunc   ;==>_SettingsGUI_GPS

Func _SettingsGUI_Lan();Opens GUI to Language tab
	$Apply_Language = 1
	_SettingsGUI(2)
EndFunc   ;==>_SettingsGUI_Lan

Func _SettingsGUI_Manu();Opens GUI to Manufacturer tab
	$Apply_Manu = 1
	_SettingsGUI(3)
EndFunc   ;==>_SettingsGUI_Manu

Func _SettingsGUI_Lab();Opens GUI to Label tab
	$Apply_Lab = 1
	_SettingsGUI(4)
EndFunc   ;==>_SettingsGUI_Lab

Func _SettingsGUI_Col();Opens GUI to Column tab
	$Apply_Column = 1
	_SettingsGUI(5)
EndFunc   ;==>_SettingsGUI_Col

Func _SettingsGUI_SW();Opens GUI to Searchword tab
	$Apply_Searchword = 1
	_SettingsGUI(6)
EndFunc   ;==>_SettingsGUI_SW

Func _SettingsGUI_Auto();Opens GUI to Auto tab
	$Apply_Auto = 1
	_SettingsGUI(7)
EndFunc   ;==>_SettingsGUI_Auto

Func _SettingsGUI_AutoKML();Opens GUI to Auto tab
	$Apply_AutoKML = 1
	_SettingsGUI(8)
EndFunc   ;==>_SettingsGUI_AutoKML

Func _SettingsGUI($StartTab);Opens Settings GUI to specified tab
	If $SettingsOpen = 1 Then
		WinActivate($Text_VistumblerSettings)
	Else
		$SettingsOpen = 1
		$SetMisc = GUICreate($Text_VistumblerSettings, 690, 500, -1, -1, BitOR($WS_OVERLAPPEDWINDOW, $WS_CLIPSIBLINGS))
		GUISetBkColor($BackgroundColor)
		$Settings_Tab = GUICtrlCreateTab(0, 0, 690, 470)
		;Misc Tab
		$Tab_Misc = GUICtrlCreateTabItem($Text_Misc)
		_GUICtrlTab_SetBkColor($SetMisc, $Settings_Tab, $BackgroundColor)
		$GroupMisc = GUICtrlCreateGroup($Text_Misc, 8, 32, 665, 425)
		GUICtrlSetColor(-1, $TextColor)
		$GroupMiscOpt = GUICtrlCreateGroup($Text_Options, 16, 56, 649, 265)
		GUICtrlSetColor(-1, $TextColor)
		GUICtrlCreateLabel($Text_VistumblerSaveDirectory, 31, 76, 620, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GUI_Set_SaveDir = GUICtrlCreateInput($SaveDir, 31, 91, 515, 21)
		$browse1 = GUICtrlCreateButton($Text_Browse, 556, 91, 97, 20, 0)
		GUICtrlCreateLabel($Text_VistumblerAutoSaveDirectory, 31, 116, 620, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GUI_Set_SaveDirAuto = GUICtrlCreateInput($SaveDirAuto, 31, 131, 515, 21)
		$Browse2 = GUICtrlCreateButton($Text_Browse, 556, 131, 97, 20, 0)
		GUICtrlCreateLabel($Text_VistumblerKmlSaveDirectory, 31, 156, 620, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GUI_Set_SaveDirKml = GUICtrlCreateInput($SaveDirKml, 31, 171, 515, 21)
		$Browse3 = GUICtrlCreateButton($Text_Browse, 556, 171, 97, 20, 0)
		GUICtrlCreateLabel($Text_BackgroundColor, 31, 196, 300, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GUI_BKColor = GUICtrlCreateInput(StringReplace($BackgroundColor, '0x', ''), 31, 211, 195, 21)
		$cbrowse1 = GUICtrlCreateButton($Text_Browse, 235, 211, 97, 20, 0)
		GUICtrlCreateLabel($Text_ControlColor, 353, 196, 300, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GUI_CBKColor = GUICtrlCreateInput(StringReplace($ControlBackgroundColor, '0x', ''), 353, 211, 195, 21)
		$cbrowse2 = GUICtrlCreateButton($Text_Browse, 556, 211, 97, 20, 0)
		GUICtrlCreateLabel($Text_BgFontColor, 31, 236, 300, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GUI_TextColor = GUICtrlCreateInput(StringReplace($TextColor, '0x', ''), 31, 251, 195, 21)
		$cbrowse3 = GUICtrlCreateButton($Text_Browse, 235, 251, 97, 20, 0)
		GUICtrlCreateLabel($Text_RefreshLoopTime, 353, 236, 300, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GUI_RefreshLoop = GUICtrlCreateInput($RefreshLoopTime, 353, 251, 195, 21)
		GUICtrlCreateLabel($Text_TimeBeforeMarkedDead, 31, 277, 300, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GUI_TimeBeforeMarkingDead = GUICtrlCreateInput($TimeBeforeMarkedDead, 31, 292, 195, 21)
		$GUI_AutoCheckForUpdates = GUICtrlCreateCheckbox($Text_AutoCheckUpdates, 353, 277, 300, 15)
		GUICtrlSetColor(-1, $TextColor)
		If $AutoCheckForUpdates = 1 Then GUICtrlSetState($GUI_AutoCheckForUpdates, $GUI_CHECKED)
		$GUI_CheckForBetaUpdates = GUICtrlCreateCheckbox($Text_CheckBetaUpdates, 353, 297, 300, 15)
		GUICtrlSetColor(-1, $TextColor)
		If $CheckForBetaUpdates = 1 Then GUICtrlSetState($GUI_CheckForBetaUpdates, $GUI_CHECKED)
		$GroupMiscPHP = GUICtrlCreateGroup($Text_PhilsWifiTools, 16, 328, 649, 121)
		GUICtrlSetColor(-1, $TextColor)
		GUICtrlCreateLabel($Text_PHPgraphing, 31, 349, 620, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GUI_PhilsGraphURL = GUICtrlCreateInput($PhilsGraphURL, 31, 369, 620, 21)
		GUICtrlCreateLabel($Text_PhilsWDB, 32, 396, 620, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GUI_PhilsWdbURL = GUICtrlCreateInput($PhilsWdbURL, 32, 416, 620, 21)
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
		$ComLabel = GUICtrlCreateLabel($Text_Com, 44, 180, 275, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GUI_Comport = GUICtrlCreateCombo("1", 44, 195, 275, 25)
		GUICtrlSetData(-1, "2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20", $ComPort)
		$BaudLabel = GUICtrlCreateLabel($Text_Baud, 44, 235, 275, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GUI_Baud = GUICtrlCreateCombo("4800", 44, 250, 275, 25)
		GUICtrlSetData(-1, "9600|14400|19200|38400|57600|115200", $BAUD)
		$StopBitLabel = GUICtrlCreateLabel($Text_StopBit, 44, 290, 275, 15)
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
		$ParityLabel = GUICtrlCreateLabel($Text_Parity, 364, 180, 275, 15)
		$GUI_Parity = GUICtrlCreateCombo($Text_None, 364, 195, 275, 25)
		GUICtrlSetData(-1, $Text_Even & '|' & $Text_Mark & '|' & $Text_Odd & '|' & $Text_Space, $l_PARITY)
		$DataBitLabel = GUICtrlCreateLabel($Text_DataBit, 364, 235, 275, 15)
		$GUI_DataBit = GUICtrlCreateCombo("4", 364, 250, 275, 25)
		GUICtrlSetData(-1, "5|6|7|8", $DATABIT)
		$GroupGpsFormat = GUICtrlCreateGroup($Text_GPSFormat, 24, 360, 633, 50)
		GUICtrlSetColor(-1, $TextColor)
		If $GPSformat = 1 Then $DefForm = "dd.dddd"
		If $GPSformat = 2 Then $DefForm = "dd mm ss"
		If $GPSformat = 3 Then $DefForm = "ddmm.mmmm"
		$GUI_Format = GUICtrlCreateCombo("dd.dddd", 44, 380, 275, 25)
		GUICtrlSetData(-1, "ddmm.mmmm|dd mm ss", $DefForm)
		GUICtrlSetColor($GUI_Format, $TextColor)
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
		Local $ManuMatchArray, $iRows, $iColumns, $iRval
		$query = "SELECT BSSID, Manufacturer FROM Manufacturers"
		$iRval = _SQLite_GetTable2d($ManuDBhndl, $query, $ManuMatchArray, $iRows, $iColumns)
		$FoundManuMatch = $iRows
		GUICtrlSetData($msgdisplay, $Text_VistumblerSettings & ' - Loading ' & $FoundManuMatch & ' Manufacturer(s)')
		For $m = 1 To $FoundManuMatch
			$manumac = $ManuMatchArray[$m][0]
			$manumanu = $ManuMatchArray[$m][1]
			GUICtrlCreateListViewItem('"' & $manumac & '"|' & $manumanu, $GUI_Manu_List)
		Next
		GUICtrlSetData($msgdisplay, '')
		;Labels Tab
		$Tab_Lab = GUICtrlCreateTabItem($Text_Labels)
		_GUICtrlTab_SetBkColor($SetMisc, $Settings_Tab, $BackgroundColor)
		$Label7 = GUICtrlCreateLabel($Text_NewMac, 34, 39, 195, 15)
		GUICtrlSetColor(-1, $TextColor)
		$Label8 = GUICtrlCreateLabel($Text_NewLabel, 244, 39, 410, 15)
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
		Local $LabMatchArray, $iRows, $iColumns, $iRval
		$query = "SELECT BSSID, Label FROM Labels"
		$iRval = _SQLite_GetTable2d($LabDBhndl, $query, $LabMatchArray, $iRows, $iColumns)
		$FoundLabMatch = $iRows
		GUICtrlSetData($msgdisplay, $Text_VistumblerSettings & ' - Loading ' & $FoundLabMatch & ' Label(s)')
		For $l = 1 To $FoundLabMatch
			$labmac = $LabMatchArray[$l][0]
			$lablab = $LabMatchArray[$l][1]
			GUICtrlCreateListViewItem('"' & $labmac & '"|' & $lablab, $GUI_Lab_List)
		Next
		GUICtrlSetData($msgdisplay, '')
		;Columns Tabs
		$Tab_Col = GUICtrlCreateTabItem($Text_Columns)
		;Get Current GUI widths from listview
		_GetListviewWidths()
		;Start Column tab gui
		_GUICtrlTab_SetBkColor($SetMisc, $Settings_Tab, $BackgroundColor)
		$GroupColumns = GUICtrlCreateGroup($Text_Columns, 16, 40, 657, 417)
		GUICtrlSetColor(-1, $TextColor)


		$CWCB_Line = GUICtrlCreateCheckbox($Column_Names_Line, 34, 105, 185, 17)
		GUICtrlSetColor(-1, $TextColor)
		$CWIB_Line = GUICtrlCreateInput($column_Width_Line, 224, 105, 113, 21)
		GUICtrlSetColor(-1, $TextColor)
		$CWCB_Active = GUICtrlCreateCheckbox($Column_Names_Active, 34, 135, 185, 17)
		GUICtrlSetColor(-1, $TextColor)
		$CWIB_Active = GUICtrlCreateInput($column_Width_Active, 224, 135, 113, 21)
		GUICtrlSetColor(-1, $TextColor)
		$CWCB_SSID = GUICtrlCreateCheckbox($Column_Names_SSID, 34, 165, 185, 17)
		GUICtrlSetColor(-1, $TextColor)
		$CWIB_SSID = GUICtrlCreateInput($column_Width_SSID, 224, 165, 113, 21)
		GUICtrlSetColor(-1, $TextColor)
		$CWCB_BSSID = GUICtrlCreateCheckbox($Column_Names_BSSID, 34, 195, 185, 17)
		GUICtrlSetColor(-1, $TextColor)
		$CWIB_BSSID = GUICtrlCreateInput($column_Width_BSSID, 224, 195, 113, 21)
		GUICtrlSetColor(-1, $TextColor)
		$CWCB_Signal = GUICtrlCreateCheckbox($Column_Names_Signal, 34, 225, 185, 17)
		GUICtrlSetColor(-1, $TextColor)
		$CWIB_Signal = GUICtrlCreateInput($column_Width_Signal, 224, 225, 113, 21)
		GUICtrlSetColor(-1, $TextColor)
		$CWCB_Authentication = GUICtrlCreateCheckbox($Column_Names_Authentication, 34, 255, 185, 17)
		GUICtrlSetColor(-1, $TextColor)
		$CWIB_Authentication = GUICtrlCreateInput($column_Width_Authentication, 224, 255, 113, 21)
		GUICtrlSetColor(-1, $TextColor)
		$CWCB_Encryption = GUICtrlCreateCheckbox($Column_Names_Encryption, 34, 285, 185, 17)
		GUICtrlSetColor(-1, $TextColor)
		$CWIB_Encryption = GUICtrlCreateInput($column_Width_Encryption, 224, 285, 113, 21)
		GUICtrlSetColor(-1, $TextColor)
		$CWCB_Channel = GUICtrlCreateCheckbox($Column_Names_Channel, 34, 315, 185, 17)
		GUICtrlSetColor(-1, $TextColor)
		$CWIB_Channel = GUICtrlCreateInput($column_Width_Channel, 224, 315, 113, 21)
		GUICtrlSetColor(-1, $TextColor)
		$CWCB_RadioType = GUICtrlCreateCheckbox($Column_Names_RadioType, 34, 345, 185, 17)
		GUICtrlSetColor(-1, $TextColor)
		$CWIB_RadioType = GUICtrlCreateInput($column_Width_RadioType, 224, 345, 113, 21)
		GUICtrlSetColor(-1, $TextColor)
		$CWCB_NetType = GUICtrlCreateCheckbox($Column_Names_NetworkType, 34, 373, 185, 17)
		GUICtrlSetColor(-1, $TextColor)
		$CWIB_NetType = GUICtrlCreateInput($column_Width_NetworkType, 224, 373, 113, 21)
		GUICtrlSetColor(-1, $TextColor)
		$CWCB_Manu = GUICtrlCreateCheckbox($Column_Names_MANUF, 34, 403, 185, 17)
		GUICtrlSetColor(-1, $TextColor)
		$CWIB_Manu = GUICtrlCreateInput($column_Width_MANUF, 224, 403, 112, 21)
		GUICtrlSetColor(-1, $TextColor)

		$CWCB_Label = GUICtrlCreateCheckbox($Column_Names_Label, 364, 105, 185, 17)
		GUICtrlSetColor(-1, $TextColor)
		$CWIB_Label = GUICtrlCreateInput($column_Width_Label, 549, 105, 113, 21)
		GUICtrlSetColor(-1, $TextColor)
		$CWCB_Latitude = GUICtrlCreateCheckbox($Column_Names_Latitude, 364, 135, 185, 17)
		GUICtrlSetColor(-1, $TextColor)
		$CWIB_Latitude = GUICtrlCreateInput($column_Width_Latitude, 549, 137, 113, 21)
		GUICtrlSetColor(-1, $TextColor)
		$CWCB_Longitude = GUICtrlCreateCheckbox($Column_Names_Longitude, 364, 165, 185, 17)
		GUICtrlSetColor(-1, $TextColor)
		$CWIB_Longitude = GUICtrlCreateInput($column_Width_Longitude, 549, 165, 113, 21)
		GUICtrlSetColor(-1, $TextColor)
		$CWCB_LatitudeDMS = GUICtrlCreateCheckbox($Column_Names_LatitudeDMS, 364, 195, 185, 17)
		GUICtrlSetColor(-1, $TextColor)
		$CWIB_LatitudeDMS = GUICtrlCreateInput($column_Width_LatitudeDMS, 549, 197, 113, 21)
		GUICtrlSetColor(-1, $TextColor)
		$CWCB_LongitudeDMS = GUICtrlCreateCheckbox($Column_Names_LongitudeDMS, 364, 225, 185, 17)
		GUICtrlSetColor(-1, $TextColor)
		$CWIB_LongitudeDMS = GUICtrlCreateInput($column_Width_LatitudeDMS, 549, 225, 113, 21)
		GUICtrlSetColor(-1, $TextColor)
		$CWCB_LatitudeDMM = GUICtrlCreateCheckbox($Column_Names_LatitudeDMM, 364, 255, 185, 17)
		GUICtrlSetColor(-1, $TextColor)
		$CWIB_LatitudeDMM = GUICtrlCreateInput($column_Width_LatitudeDMM, 549, 255, 113, 21)
		GUICtrlSetColor(-1, $TextColor)
		$CWCB_LongitudeDMM = GUICtrlCreateCheckbox($Column_Names_LongitudeDMM, 364, 287, 185, 17)
		GUICtrlSetColor(-1, $TextColor)
		$CWIB_LongitudeDMM = GUICtrlCreateInput($column_Width_LongitudeDMM, 549, 285, 113, 21)
		GUICtrlSetColor(-1, $TextColor)
		$CWCB_BtX = GUICtrlCreateCheckbox($Column_Names_BasicTransferRates, 364, 315, 185, 17)
		GUICtrlSetColor(-1, $TextColor)
		$CWIB_BtX = GUICtrlCreateInput($column_Width_BasicTransferRates, 549, 315, 113, 21)
		GUICtrlSetColor(-1, $TextColor)
		$CWCB_OtX = GUICtrlCreateCheckbox($Column_Names_OtherTransferRates, 364, 345, 185, 17)
		GUICtrlSetColor(-1, $TextColor)
		$CWIB_OtX = GUICtrlCreateInput($column_Width_OtherTransferRates, 549, 345, 113, 21)
		GUICtrlSetColor(-1, $TextColor)
		$CWCB_FirstActive = GUICtrlCreateCheckbox($Column_Names_FirstActive, 364, 373, 185, 17)
		GUICtrlSetColor(-1, $TextColor)
		$CWIB_FirstActive = GUICtrlCreateInput($column_Width_FirstActive, 549, 373, 113, 21)
		GUICtrlSetColor(-1, $TextColor)
		$CWCB_LastActive = GUICtrlCreateCheckbox($Column_Names_LastActive, 364, 403, 185, 17)
		GUICtrlSetColor(-1, $TextColor)
		$CWIB_LastActive = GUICtrlCreateInput($column_Width_LastActive, 549, 403, 113, 21)
		GUICtrlSetColor(-1, $TextColor)
		_SetCwState()
		GUICtrlCreateLabel($Text_Enable & " / " & $Text_Disable, 32, 70, 175, 17)
		GUICtrlSetColor(-1, $TextColor)
		GUICtrlCreateLabel($Text_SetColumnWidths, 224, 70, 118, 17)
		GUICtrlSetColor(-1, $TextColor)
		GUICtrlCreateLabel($Text_Enable & " / " & $Text_Disable, 356, 70, 175, 17)
		GUICtrlSetColor(-1, $TextColor)
		GUICtrlCreateLabel($Text_SetColumnWidths, 548, 70, 118, 17)
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
		;Auto Tab
		$Tab_Auto = GUICtrlCreateTabItem($Text_Auto)
		_GUICtrlTab_SetBkColor($SetMisc, $Settings_Tab, $BackgroundColor)
		GUICtrlCreateGroup($Text_AutoSave, 16, 40, 650, 121);Auto Save Group
		GUICtrlSetColor(-1, $TextColor)
		$AutoSaveBox = GUICtrlCreateCheckbox($Text_AutoSave, 30, 65, 625, 15)
		GUICtrlSetColor(-1, $TextColor)
		If $AutoSave = 1 Then GUICtrlSetState($AutoSaveBox, $GUI_CHECKED)
		$AutoSaveDelBox = GUICtrlCreateCheckbox($Text_DelAutoSaveOnExit, 30, 85, 625, 15)
		GUICtrlSetColor(-1, $TextColor)
		If $AutoSaveDel = 1 Then GUICtrlSetState($AutoSaveDelBox, $GUI_CHECKED)
		GUICtrlCreateLabel($Text_AutoSaveEvery & '(s)', 31, 105, 625, 15)
		GUICtrlSetColor(-1, $TextColor)
		$AutoSaveSec = GUICtrlCreateInput($SaveTime, 31, 120, 115, 21)
		GUICtrlSetColor(-1, $TextColor)
		GUICtrlCreateGroup($Text_AutoSort, 15, 165, 650, 169);Auto Sort Group
		GUICtrlSetColor(-1, $TextColor)
		$GUI_AutoSort = GUICtrlCreateCheckbox($Text_AutoSort, 30, 190, 625, 15)
		GUICtrlSetColor(-1, $TextColor)
		If $AutoSort = 1 Then GUICtrlSetState($GUI_AutoSort, $GUI_CHECKED)
		GUICtrlCreateLabel($Text_SortBy, 30, 210, 625, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GUI_SortBy = GUICtrlCreateCombo($Column_Names_SSID, 30, 225, 615, 21)
		GUICtrlSetData(-1, $Column_Names_NetworkType & "|" & $Column_Names_Authentication & "|" & $Column_Names_Encryption & "|" & $Column_Names_BSSID & "|" & $Column_Names_Signal & "|" & $Column_Names_RadioType & "|" & $Column_Names_Channel & "|" & $Column_Names_BasicTransferRates & "|" & $Column_Names_OtherTransferRates & "|" & $Column_Names_Latitude & "|" & $Column_Names_Longitude & "|" & $Column_Names_LatitudeDMM & "|" & $Column_Names_LongitudeDMM & "|" & $Column_Names_LatitudeDMS & "|" & $Column_Names_LongitudeDMS & "|" & $Column_Names_FirstActive & "|" & $Column_Names_LastActive & "|" & $Column_Names_Active & "|" & $Column_Names_MANUF, $SortBy)
		If $SortDirection = 1 Then
			$SortDirectionDefault = $Text_Ascending
		Else
			$SortDirectionDefault = $Text_Decending
		EndIf
		GUICtrlCreateLabel($Text_SortDirection, 30, 250, 625, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GUI_SortDirection = GUICtrlCreateCombo($Text_Ascending, 30, 265, 615, 21)
		GUICtrlSetData(-1, $Text_Decending, $SortDirectionDefault)
		GUICtrlCreateLabel($Text_AutoSortEvery & '(s)', 30, 290, 625, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GUI_SortTime = GUICtrlCreateInput($SortTime, 30, 305, 115, 20)
		;Auto Refresh Group
		GUICtrlCreateGroup($Text_RefreshNetworks, 16, 340, 320, 125)
		$GUI_RefreshNetworks = GUICtrlCreateCheckbox($Text_RefreshNetworks, 30, 360, 300, 15)
		GUICtrlSetColor(-1, $TextColor)
		If $RefreshNetworks = 1 Then GUICtrlSetState($GUI_RefreshNetworks, $GUI_CHECKED)
		GUICtrlCreateLabel($Text_RefreshTime & '(s)', 30, 380, 615, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GUI_RefreshTime = GUICtrlCreateInput(($RefreshTime / 1000), 30, 395, 115, 20)
		GUICtrlSetColor(-1, $TextColor)
		;Auto Refresh Group
		GUICtrlCreateGroup($Text_AutoWiFiDbGpsLocate, 346, 340, 320, 125)
		$GUI_WifidbLocate = GUICtrlCreateCheckbox($Text_AutoWiFiDbGpsLocate, 360, 360, 300, 15)
		GUICtrlSetColor(-1, $TextColor)
		If $UseWiFiDbGpsLocate = 1 Then GUICtrlSetState($GUI_WifidbLocate, $GUI_CHECKED)
		GUICtrlCreateLabel($Text_RefreshTime & '(s)', 360, 380, 615, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GUI_WiFiDbLocateRefreshTime = GUICtrlCreateInput(($WiFiDbLocateRefreshTime / 1000), 360, 395, 115, 20)
		GUICtrlSetColor(-1, $TextColor)

		;AutoKML Tab
		$Tab_AutoKML = GUICtrlCreateTabItem($Text_AutoKml & ' / ' & $Text_SpeakSignal & ' / ' & $Text_MIDI)
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
		$GUI_GoogleEXE = GUICtrlCreateInput($GoogleEarth_EXE, 30, 115, 537, 20)
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
		;Speak Signal Options
		GUICtrlCreateGroup($Text_SpeakSignal, 16, 290, 350, 145)
		$GUI_SpeakSignal = GUICtrlCreateCheckbox($Text_SpeakSignal, 30, 310, 200, 15)
		GUICtrlSetColor(-1, $TextColor)
		If $SpeakSignal = 1 Then GUICtrlSetState($GUI_SpeakSignal, $GUI_CHECKED)
		$GUI_SpeakSoundsVis = GUICtrlCreateRadio($Text_SpeakUseVisSounds, 30, 330, 200, 15)
		$GUI_SpeakSoundsSapi = GUICtrlCreateRadio($Text_SpeakUseSapi, 30, 350, 200, 15)
		$GUI_SpeakSoundsMidi = GUICtrlCreateRadio($Text_MIDI, 30, 370, 200, 15)
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
		GUICtrlCreateLabel($Text_SpeakRefreshTime & '(ms)', 30, 390, 150, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GUI_SpeakSigTime = GUICtrlCreateInput($SpeakSigTime, 30, 405, 150, 20)
		GUICtrlSetColor(-1, $TextColor)
		$GUI_SpeakPercent = GUICtrlCreateCheckbox($Text_SpeakSayPercent, 200, 405, 150, 15)
		GUICtrlSetColor(-1, $TextColor)
		If $SpeakSigSayPecent = 1 Then GUICtrlSetState($GUI_SpeakPercent, $GUI_CHECKED)

		GUICtrlCreateGroup($Text_MIDI, 370, 290, 295, 145)
		$GUI_PlayMidiSounds = GUICtrlCreateCheckbox($Text_PlayMidiSounds, 385, 310, 200, 15)
		If $Midi_PlayForActiveAps = 1 Then GUICtrlSetState($GUI_PlayMidiSounds, $GUI_CHECKED)
		GUICtrlCreateLabel($Text_MidiInstrumentNumber, 385, 330, 150, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GUI_Midi_Instument = GUICtrlCreateCombo('', 385, 345, 265, 20)
		Local $InstMatchArray, $iRows, $iColumns, $iRval
		$query = "SELECT INSTNUM, INSTTEXT FROM Instruments"
		$iRval = _SQLite_GetTable2d($InstDBhndl, $query, $InstMatchArray, $iRows, $iColumns)
		$FoundInstMatch = $iRows
		GUICtrlSetData($msgdisplay, $Text_VistumblerSettings & ' - Loading ' & $FoundInstMatch & ' Instrument(s)')
		For $m = 1 To $FoundInstMatch
			$INSTNUM = $InstMatchArray[$m][0]
			$INSTTEXT = $InstMatchArray[$m][1]
			If $INSTNUM = $Midi_Instument Then
				GUICtrlSetData($GUI_Midi_Instument, $INSTNUM & ' - ' & $INSTTEXT, $INSTNUM & ' - ' & $INSTTEXT)
			Else
				GUICtrlSetData($GUI_Midi_Instument, $INSTNUM & ' - ' & $INSTTEXT)
			EndIf
		Next
		GUICtrlSetColor(-1, $TextColor)
		GUICtrlCreateLabel($Text_MidiPlayTime & '(ms)', 385, 370, 150, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GUI_Midi_PlayTime = GUICtrlCreateInput($Midi_PlayTime, 385, 385, 265, 20)
		GUICtrlSetColor(-1, $TextColor)

		GUICtrlCreateTabItem("")

		;END OF TABS
		$GUI_Set_Apply = GUICtrlCreateButton($Text_Apply, 610, 470, 73, 25, 0)
		$GUI_Set_Can = GUICtrlCreateButton($Text_Cancel, 535, 470, 75, 25, 0)
		$GUI_Set_Ok = GUICtrlCreateButton($Text_Ok, 460, 470, 75, 25, 0)
		;$GUI_Set_Export = GUICtrlCreateButton($Text_ExportSettings, 2, 470, 135, 25, 0)
		;$GUI_Set_Import = GUICtrlCreateButton($Text_ImportSettings, 137, 470, 135, 25, 0)

		If $StartTab = 0 Then GUICtrlSetState($Tab_Misc, $GUI_SHOW)
		If $StartTab = 1 Then GUICtrlSetState($Tab_Gps, $GUI_SHOW)
		If $StartTab = 2 Then GUICtrlSetState($Tab_Lan, $GUI_SHOW)
		If $StartTab = 3 Then GUICtrlSetState($Tab_Manu, $GUI_SHOW)
		If $StartTab = 4 Then GUICtrlSetState($Tab_Lab, $GUI_SHOW)
		If $StartTab = 5 Then GUICtrlSetState($Tab_Col, $GUI_SHOW)
		If $StartTab = 6 Then GUICtrlSetState($Tab_SW, $GUI_SHOW)
		If $StartTab = 7 Then GUICtrlSetState($Tab_Auto, $GUI_SHOW)
		If $StartTab = 8 Then GUICtrlSetState($Tab_AutoKML, $GUI_SHOW)


		GUICtrlSetOnEvent($Add_MANU, '_AddManu')
		GUICtrlSetOnEvent($Edit_MANU, '_EditManu')
		GUICtrlSetOnEvent($Remove_MANU, '_RemoveManu')
		GUICtrlSetOnEvent($Add_Lab, '_AddLabel')
		GUICtrlSetOnEvent($Edit_Lab, '_EditLabel')
		GUICtrlSetOnEvent($Remove_Lab, '_RemoveLabel')

		GUICtrlSetOnEvent($browse1, '_BrowseSave')
		GUICtrlSetOnEvent($Browse2, '_BrowseAutoSave')
		GUICtrlSetOnEvent($Browse3, '_BrowseKmlSave')

		GUICtrlSetOnEvent($cbrowse1, '_ColorBrowse1')
		GUICtrlSetOnEvent($cbrowse2, '_ColorBrowse2')
		GUICtrlSetOnEvent($cbrowse3, '_ColorBrowse3')

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
		GUICtrlSetOnEvent($CWCB_Authentication, '_SetWidthValue_Authentication')
		GUICtrlSetOnEvent($CWCB_Encryption, '_SetWidthValue_Encryption')
		GUICtrlSetOnEvent($CWCB_Channel, '_SetWidthValue_Channel')
		GUICtrlSetOnEvent($CWCB_RadioType, '_SetWidthValue_RadioType')
		GUICtrlSetOnEvent($CWCB_NetType, '_SetWidthValue_NetType')
		GUICtrlSetOnEvent($CWCB_Manu, '_SetWidthValue_Manu')
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
		$FileName = StringTrimLeft($imfile, $lastslash)
		FileDelete($LanguageDir & $FileName)
		FileCopy($imfile, $LanguageDir & $FileName)
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
	If $Apply_GPS = 1 Then
		If GUICtrlRead($GUI_Comport) <> $ComPort And $UseGPS = 1 Then _GpsToggle() ;If the port has changed and gps is turned on then turn off the gps (it will be re-enabled with the new port)
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
		If GUICtrlRead($Rad_UseCommMG) = 1 Then $GpsType = 0 ;Set CommMG as default comm interface
		If GUICtrlRead($Rad_UseNetcomm) = 1 Then $GpsType = 1 ;Set Netcomm as default comm interface
		If GUICtrlRead($Rad_UseKernel32) = 1 Then $GpsType = 2 ;Set Kernel32 as default comm interface
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
		$Text_AddAPsToTop = IniRead($DefaultLanguagePath, 'GuiText', 'AddAPsToTop', 'Add new APs to top')
		$Text_Extra = IniRead($DefaultLanguagePath, 'GuiText', 'Extra', 'Ex&tra')
		$Text_ScanAPs = IniRead($DefaultLanguagePath, 'GuiText', 'ScanAPs', '&Scan APs')
		$Text_StopScanAps = IniRead($DefaultLanguagePath, 'GuiText', 'StopScanAps', '&Stop')
		$Text_UseGPS = IniRead($DefaultLanguagePath, 'GuiText', 'UseGPS', 'Use &GPS')
		$Text_StopGPS = IniRead($DefaultLanguagePath, 'GuiText', 'StopGPS', 'Stop &GPS')
		$Text_Settings = IniRead($DefaultLanguagePath, 'GuiText', 'Settings', 'S&ettings')
		$Text_GpsSettings = IniRead($DefaultLanguagePath, 'GuiText', 'GpsSettings', 'G&PS Settings')
		$Text_SetLanguage = IniRead($DefaultLanguagePath, 'GuiText', 'SetLanguage', 'Set &Language')
		$Text_SetSearchWords = IniRead($DefaultLanguagePath, 'GuiText', 'SetSearchWords', 'Set Search &Words')
		$Text_SetMacLabel = IniRead($DefaultLanguagePath, 'GuiText', 'SetMacLabel', 'Set Labels by Mac')
		$Text_SetMacManu = IniRead($DefaultLanguagePath, 'GuiText', 'SetMacManu', 'Set Manufactures by Mac')
		$Text_Export = IniRead($DefaultLanguagePath, 'GuiText', 'Export', 'Ex&port')
		$Text_ExportToKML = IniRead($DefaultLanguagePath, 'GuiText', 'ExportToKML', 'Export To KML')
		$Text_ExportToGPX = IniRead($DefaultLanguagePath, 'GuiText', 'ExportToGPX', 'Export To GPX')
		$Text_ExportToTXT = IniRead($DefaultLanguagePath, 'GuiText', 'ExportToTXT', 'Export To TXT')
		$Text_ExportToNS1 = IniRead($DefaultLanguagePath, 'GuiText', 'ExportToNS1', 'Export To NS1')
		$Text_ExportToVS1 = IniRead($DefaultLanguagePath, 'GuiText', 'ExportToVS1', 'Export To VS1')
		$Text_ExportToCSV = IniRead($DefaultLanguagePath, 'GuiText', 'ExportToCSV', 'Export To CSV')
		$Text_PhilsPHPgraph = IniRead($DefaultLanguagePath, 'GuiText', 'PhilsPHPgraph', 'View graph (Phils PHP version)')
		$Text_PhilsWDB = IniRead($DefaultLanguagePath, 'GuiText', 'PhilsWDB', 'Phils WiFiDB (Alpha)')
		$Text_UploadDataToWifiDB = IniRead($DefaultLanguagePath, 'GuiText', 'UploadDataToWiFiDB', 'Upload Data to WiFiDB')
		$Text_RefreshLoopTime = IniRead($DefaultLanguagePath, 'GuiText', 'RefreshLoopTime', 'Refresh loop time(ms):')
		$Text_ActualLoopTime = IniRead($DefaultLanguagePath, 'GuiText', 'ActualLoopTime', 'Actual loop time:')
		$Text_Longitude = IniRead($DefaultLanguagePath, 'GuiText', 'Longitude', 'Longitude:')
		$Text_Latitude = IniRead($DefaultLanguagePath, 'GuiText', 'Latitude', 'Latitude:')
		$Text_ActiveAPs = IniRead($DefaultLanguagePath, 'GuiText', 'ActiveAPs', 'Active APs:')
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
		$Text_NoApsWithGps = IniRead($DefaultLanguagePath, 'GuiText', 'NoApsWithGps', 'No Access Points found with GPS coordinates.')
		$Text_MacExistsOverwriteIt = IniRead($DefaultLanguagePath, 'GuiText', 'MacExistsOverwriteIt', 'A entry for this mac address already exists. would you like to overwrite it?')
		$Text_SavingLine = IniRead($DefaultLanguagePath, 'GuiText', 'SavingLine', 'Saving Line')
		$Text_DisplayDebug = IniRead($DefaultLanguagePath, 'GuiText', 'DisplayDebug', 'Debug - Display Functions')
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
		$Text_VistumblerFile = IniRead($DefaultLanguagePath, 'GuiText', 'VistumblerFile', 'Vistumbler File')
		$Text_DetailedCsvFile = IniRead($DefaultLanguagePath, 'GuiText', 'DetailedFile', 'Detailed CSV File')
		$Text_NetstumblerTxtFile = IniRead($DefaultLanguagePath, 'GuiText', 'NetstumblerTxtFile', 'Netstumbler TXT File')
		$Text_ErrorOpeningGpsPort = IniRead($DefaultLanguagePath, 'GuiText', 'ErrorOpeningGpsPort', 'Error opening GPS port')
		$Text_SecondsSinceGpsUpdate = IniRead($DefaultLanguagePath, 'GuiText', 'SecondsSinceGpsUpdate', 'Seconds Since GPS Update')
		$Text_SavingGID = IniRead($DefaultLanguagePath, 'GuiText', 'SavingGID', 'Saving GID')
		$Text_SavingHistID = IniRead($DefaultLanguagePath, 'GuiText', 'SavingHistID', 'Saving HistID')
		$Text_NoUpdates = IniRead($DefaultLanguagePath, 'GuiText', 'NoUpdates', 'No Updates Avalible')
		$Text_NoActiveApFound = IniRead($DefaultLanguagePath, 'GuiText', 'NoActiveApFound', 'No Active AP found')
		$Text_VistumblerDonate = IniRead($DefaultLanguagePath, 'GuiText', 'VistumblerDonate', 'Donate')
		$Text_VistumblerStore = IniRead($DefaultLanguagePath, 'GuiText', 'VistumblerStore', 'Store')
		$Text_SupportVistumbler = IniRead($DefaultLanguagePath, 'GuiText', 'SupportVistumbler', '*Support Vistumbler*')
		$Text_UseNativeWifi = IniRead($DefaultLanguagePath, 'GuiText', 'UseNativeWifi', 'Use Native Wifi (No BSSID, CHAN, OTX, BTX, or RADTYPE)')
		$Text_FilterMsg = IniRead($DefaultLanguagePath, 'GuiText', 'FilterMsg', 'Use asterik(*)" as a wildcard. Seperate multiple filters with a comma(,). Use a dash(-) for ranges.')
		$Text_SetFilters = IniRead($DefaultLanguagePath, 'GuiText', 'SetFilters', 'Set Filters')
		$Text_Filtered = IniRead($DefaultLanguagePath, 'GuiText', 'Filters', 'Filters')
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
		$Text_AutoSelectConnectedAP = IniRead($DefaultLanguagePath, 'GuiText', 'AutoSelectConnectedAP', 'Auto Select Connected AP')
		$Text_Experimental = IniRead($DefaultLanguagePath, 'GuiText', 'Experimental', 'Experimental')
		$Text_Color = IniRead($DefaultLanguagePath, 'GuiText', 'Color', 'Color')
		$Text_PhilsWifiTools = IniRead($DefaultLanguagePath, "GuiText", "PhilsWifiTools", "Phil's WiFi Tools")
		$Text_AddRemFilters = IniRead($DefaultLanguagePath, "GuiText", "AddRemFilters", "Add/Remove Filters")
		$Text_NoFilterSelected = IniRead($DefaultLanguagePath, "GuiText", "NoFilterSelected", "No filter selected.")
		$Text_AddFilter = IniRead($DefaultLanguagePath, "GuiText", "AddFilter", "Add Filter")
		$Text_EditFilter = IniRead($DefaultLanguagePath, "GuiText", "EditFilter ", "Edit Filter ")
		$Text_DeleteFilter = IniRead($DefaultLanguagePath, "GuiText", "DeleteFilter", "Delete Filter")
		$Text_TimeBeforeMarkedDead = IniRead($DefaultLanguagePath, "GuiText", "TimeBeforeMarkedDead", "Time to wait before marking AP dead (s)")
		$RestartVistumbler = 1
	EndIf
	If $Apply_Manu = 1 Then
		;Remove all current Mac address/manus in the array
		$query = "DELETE FROM Manufacturers"
		_SQLite_Exec($ManuDBhndl, $query)
		;Rewrite Mac address/labels from listview into the array
		$itemcount = _GUICtrlListView_GetItemCount($GUI_Manu_List) - 1; Get List Size
		_SQLite_Exec($ManuDBhndl, "BEGIN;")
		For $findloop = 0 To $itemcount
			$o_manu_mac = StringUpper(StringReplace(_GUICtrlListView_GetItemText($GUI_Manu_List, $findloop, 0), '"', ''))
			$o_manu = _GUICtrlListView_GetItemText($GUI_Manu_List, $findloop, 1)
			$query = "INSERT INTO Manufacturers(BSSID,Manufacturer) VALUES ('" & $o_manu_mac & "','" & StringReplace($o_manu, "'", "''") & "');"
			_SQLite_Exec($ManuDBhndl, $query)
		Next
		_SQLite_Exec($ManuDBhndl, "COMMIT;")
		;Reset Labels In List
		_UpdateListMacLabels()
	EndIf
	If $Apply_Lab = 1 Then
		;Remove all current Mac address/labels in the array
		$query = "DELETE FROM Labels"
		_SQLite_Exec($DBhndl, $query)
		;Rewrite Mac address/labels from listview into the array
		$itemcount = _GUICtrlListView_GetItemCount($GUI_Lab_List) - 1; Get List Size
		For $findloop = 0 To $itemcount
			$o_lab_mac = StringUpper(StringReplace(_GUICtrlListView_GetItemText($GUI_Lab_List, $findloop, 0), '"', ''))
			$o_lab = _GUICtrlListView_GetItemText($GUI_Lab_List, $findloop, 1)
			$query = "INSERT INTO Labels(BSSID,Label) VALUES ('" & $o_lab_mac & "','" & $o_lab & "');"
			_SQLite_Exec($ManuDBhndl, $query)
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
	If $Apply_Misc = 1 Then
		$Tmp_SaveDir = GUICtrlRead($GUI_Set_SaveDir)
		$Tmp_SaveDirAuto = GUICtrlRead($GUI_Set_SaveDirAuto)
		$Tmp_SaveDirKml = GUICtrlRead($GUI_Set_SaveDirKml)
		If StringTrimLeft($Tmp_SaveDir, StringLen($Tmp_SaveDir) - 1) <> "\" Then $Tmp_SaveDir = $Tmp_SaveDir & "\" ;If directory does not have trailing \ then add it
		If StringTrimLeft($Tmp_SaveDirAuto, StringLen($Tmp_SaveDirAuto) - 1) <> "\" Then $Tmp_SaveDirAuto = $Tmp_SaveDirAuto & "\" ;If directory does not have trailing \ then add it
		If StringTrimLeft($Tmp_SaveDirKml, StringLen($Tmp_SaveDirKml) - 1) <> "\" Then $Tmp_SaveDirKml = $Tmp_SaveDirKml & "\" ;If directory does not have trailing \ then add it
		$SaveDir = $Tmp_SaveDir
		$SaveDirAuto = $Tmp_SaveDirAuto
		$SaveDirKml = $Tmp_SaveDirKml
		$BackgroundColor = '0x' & StringUpper(GUICtrlRead($GUI_BKColor))
		$ControlBackgroundColor = '0x' & StringUpper(GUICtrlRead($GUI_CBKColor))
		$TextColor = '0x' & StringUpper(GUICtrlRead($GUI_TextColor))
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
		$RefreshLoopTime = GUICtrlRead($GUI_RefreshLoop)
		$PhilsGraphURL = GUICtrlRead($GUI_PhilsGraphURL)
		$PhilsWdbURL = GUICtrlRead($GUI_PhilsWdbURL)
	EndIf
	If $Apply_Auto = 1 Then
		;AutoSave
		If GUICtrlRead($AutoSaveBox) = 1 Then
			$AutoSave = 1
			$save_timer = TimerInit()
			GUICtrlSetState($AutoSaveGUI, $GUI_CHECKED)
		Else
			$AutoSave = 0
			GUICtrlSetState($AutoSaveGUI, $GUI_UNCHECKED)
		EndIf
		If GUICtrlRead($AutoSaveDelBox) = 1 Then
			$AutoSaveDel = 1
		Else
			$AutoSaveDel = 0
		EndIf
		$SaveTime = GUICtrlRead($AutoSaveSec)
		;AutoSort
		If GUICtrlRead($GUI_SortDirection) = $Text_Ascending Then
			$SortDirection = 1
		Else
			$SortDirection = 0
		EndIf

		$SortBy = GUICtrlRead($GUI_SortBy)
		$SortTime = GUICtrlRead($GUI_SortTime)
		If GUICtrlRead($GUI_AutoSort) = 4 And $AutoSort = 1 Then _AutoSortToggle()
		If GUICtrlRead($GUI_AutoSort) = 1 And $AutoSort = 0 Then _AutoSortToggle()
		;Auto Refresh
		If GUICtrlRead($GUI_RefreshNetworks) = 4 And $RefreshNetworks = 1 Then _AutoRefreshToggle()
		If GUICtrlRead($GUI_RefreshNetworks) = 1 And $RefreshNetworks = 0 Then _AutoRefreshToggle()
		$RefreshTime = (GUICtrlRead($GUI_RefreshTime) * 1000)
		;Auto WiFiDB
		If GUICtrlRead($GUI_WifidbLocate) = 4 And $UseWiFiDbGpsLocate = 1 Then _WifiDbLocateToggle()
		If GUICtrlRead($GUI_WifidbLocate) = 1 And $UseWiFiDbGpsLocate = 0 Then _WifiDbLocateToggle()
		$WiFiDbLocateRefreshTime = (GUICtrlRead($GUI_WiFiDbLocateRefreshTime) * 1000)
	EndIf
	If $Apply_AutoKML = 1 Then
		If GUICtrlRead($AutoSaveKML) = 4 And $AutoKML = 1 Then _AutoKmlToggle()
		If GUICtrlRead($AutoSaveKML) = 1 And $AutoKML = 0 Then _AutoKmlToggle()
		If GUICtrlRead($GUI_OpenKmlNetLink) = 1 Then
			$OpenKmlNetLink = 1
			If $AutoKML = 1 Then _StartGoogleAutoKmlRefresh()
		Else
			$OpenKmlNetLink = 0
		EndIf

		$GoogleEarth_EXE = GUICtrlRead($GUI_GoogleEXE)
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


	Dim $Apply_GPS = 1, $Apply_Language = 0, $Apply_Manu = 0, $Apply_Lab = 0, $Apply_Column = 1, $Apply_Searchword = 1, $Apply_Misc = 1, $Apply_Auto = 1, $Apply_AutoKML = 1
	If $RestartVistumbler = 1 Then MsgBox(0, $Text_Restart, $Text_RestartMsg)
EndFunc   ;==>_ApplySettingsGUI

Func _AddFilerString($q_query, $q_field, $FilterValues)
	$FilterValues = StringReplace(StringReplace($FilterValues, '"', ''), "'", "")
	Local $ret
	Local $ret2
	If $FilterValues = '*' Then
		Return ($q_query)
	Else
		If $q_query <> '' Then $q_query &= ' AND '
		$FilterValues = StringReplace($FilterValues, "|", ",")
		If StringInStr($FilterValues, ",") Then
			$q_splitstring = StringSplit($FilterValues, ",")
			For $q = 1 To $q_splitstring[0]
				If StringInStr($q_splitstring[$q], '<>') Then
					If $ret <> '' Then $ret &= ','
					If $q_field = "CHAN" Or $q_field = "Signal" Then
						$ret &= "'" & StringFormat("%03i", StringReplace($q_splitstring[$q], '<>', '')) & "'"
					Else
						$ret &= "'" & StringReplace($q_splitstring[$q], '<>', '') & "'"
					EndIf
				Else
					If $ret2 <> '' Then $ret2 &= ','
					If $q_field = "CHAN" Or $q_field = "Signal" Then
						$ret2 &= "'" & StringFormat("%03i", $q_splitstring[$q]) & "'"
					Else
						$ret2 &= "'" & $q_splitstring[$q] & "'"
					EndIf
				EndIf
			Next
			If $ret <> '' Or $ret2 <> '' Then $q_query &= "("
			If $ret <> '' Then $q_query &= $q_field & " NOT IN (" & $ret & ")"
			If $ret <> '' And $ret2 <> '' Then $q_query &= " And "
			If $ret2 <> '' Then $q_query &= $q_field & " IN (" & $ret2 & ")"
			If $ret <> '' Or $ret2 <> '' Then $q_query &= ")"
			Return ($q_query)
		ElseIf StringInStr($FilterValues, "-") Then
			$q_splitstring = StringSplit($FilterValues, "-")
			If StringInStr($FilterValues, '<>') Then
				If $q_field = "CHAN" Or $q_field = "Signal" Then
					$q_query &= "(" & $q_field & " NOT BETWEEN '" & StringFormat("%03i", StringReplace($q_splitstring[1], '<>', '')) & "' AND '" & StringFormat("%03i", StringReplace($q_splitstring[2], '<>', '')) & "')"
				Else
					$q_query &= "(" & $q_field & " NOT BETWEEN '" & StringReplace($q_splitstring[1], '<>', '') & "' AND '" & StringReplace($q_splitstring[2], '<>', '') & "')"
				EndIf
			Else
				If $q_field = "CHAN" Or $q_field = "Signal" Then
					$q_query &= "(" & $q_field & " BETWEEN '" & StringFormat("%03i", $q_splitstring[1]) & "' AND '" & StringFormat("%03i", $q_splitstring[2]) & "')"
				Else
					$q_query &= "(" & $q_field & " BETWEEN '" & $q_splitstring[1] & "' AND '" & $q_splitstring[2] & "')"
				EndIf
			EndIf
			Return ($q_query)
		Else
			If StringInStr($FilterValues, '<>') Then
				If $q_field = "CHAN" Or $q_field = "Signal" Then
					$q_query &= "(" & $q_field & " <> '" & StringFormat("%03i", StringReplace($FilterValues, '<>', '')) & "')"
				Else
					$q_query &= "(" & $q_field & " <> '" & StringReplace($FilterValues, '<>', '') & "')"
				EndIf
			Else
				If $q_field = "CHAN" Or $q_field = "Signal" Then
					$q_query &= "(" & $q_field & " = '" & StringFormat("%03i", $FilterValues) & "')"
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
		$FilterValues = StringReplace($FilterValues, "|", ",")
		If StringInStr($FilterValues, ",") Then
			$q_splitstring = StringSplit($FilterValues, ",")
			For $q = 1 To $q_splitstring[0]
				If StringInStr($q_splitstring[$q], '<>') Then
					If $ret <> '' Then $ret &= ','
					If $q_field = "CHAN" Or $q_field = "Signal" Then
						$ret &= "'" & StringFormat("%03i", StringReplace($q_splitstring[$q], '<>', '')) & "'"
					Else
						$ret &= "'" & StringReplace($q_splitstring[$q], '<>', '') & "'"
					EndIf
				Else
					If $ret2 <> '' Then $ret2 &= ','
					If $q_field = "CHAN" Or $q_field = "Signal" Then
						$ret2 &= "'" & StringFormat("%03i", $q_splitstring[$q]) & "'"
					Else
						$ret2 &= "'" & $q_splitstring[$q] & "'"
					EndIf
				EndIf
			Next
			If $ret <> '' Or $ret2 <> '' Then $q_query &= "("
			If $ret <> '' Then $q_query &= $q_field & " IN (" & $ret & ")"
			If $ret <> '' And $ret2 <> '' Then $q_query &= " Or "
			If $ret2 <> '' Then $q_query &= $q_field & " NOT IN (" & $ret2 & ")"
			If $ret <> '' Or $ret2 <> '' Then $q_query &= ")"
			Return ($q_query)
		ElseIf StringInStr($FilterValues, "-") Then
			$q_splitstring = StringSplit($FilterValues, "-")
			If StringInStr($FilterValues, '<>') Then
				If $q_field = "CHAN" Or $q_field = "Signal" Then
					$q_query &= "(" & $q_field & " BETWEEN '" & StringFormat("%03i", StringReplace($q_splitstring[1], '<>', '')) & "' AND '" & StringFormat("%03i", StringReplace($q_splitstring[2], '<>', '')) & "')"
				Else
					$q_query &= "(" & $q_field & " BETWEEN '" & StringReplace($q_splitstring[1], '<>', '') & "' AND '" & StringReplace($q_splitstring[2], '<>', '') & "')"
				EndIf
			Else
				If $q_field = "CHAN" Or $q_field = "Signal" Then
					$q_query &= "(" & $q_field & " NOT BETWEEN '" & StringFormat("%03i", $q_splitstring[1]) & "' AND '" & StringFormat("%03i", $q_splitstring[2]) & "')"
				Else
					$q_query &= "(" & $q_field & " NOT BETWEEN '" & $q_splitstring[1] & "' AND '" & $q_splitstring[2] & "')"
				EndIf
			EndIf
			Return ($q_query)
		Else
			If StringInStr($FilterValues, '<>') Then
				If $q_field = "CHAN" Or $q_field = "Signal" Then
					$q_query &= "(" & $q_field & " = '" & StringFormat("%03i", StringReplace($FilterValues, '<>', '')) & "')"
				Else
					$q_query &= "(" & $q_field & " = '" & StringReplace($FilterValues, '<>', '') & "')"
				EndIf
			Else
				If $q_field = "CHAN" Or $q_field = "Signal" Then
					$q_query &= "(" & $q_field & " <> '" & StringFormat("%03i", $FilterValues) & "')"
				Else
					$q_query &= "(" & $q_field & " <> '" & $FilterValues & "')"
				EndIf
			EndIf
			Return ($q_query)
		EndIf
	EndIf
EndFunc   ;==>_RemoveFilterString

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
	_SetWidthValue($CWCB_Line, $CWIB_Line, $column_Width_Line, $settings, 'Column_Width', 'Column_Line', 35)
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
	_SetWidthValue($CWCB_Signal, $CWIB_Signal, $column_Width_Signal, $settings, 'Column_Width', 'Column_Signal', 70)
EndFunc   ;==>_SetWidthValue_Signal
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

Func _RemoveManu();Removed manufactuer from list
	$Apply_Manu = 1
	$EditLine = _GUICtrlListView_GetNextItem($GUI_Manu_List)
	If $EditLine <> $LV_ERR Then _GUICtrlListView_DeleteItem($GUI_Manu_List, $EditLine)
EndFunc   ;==>_RemoveManu

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

Func _RemoveLabel();Close edit label window
	$Apply_Lab = 1
	$EditLine = _GUICtrlListView_GetNextItem($GUI_Lab_List)
	If $EditLine <> $LV_ERR Then _GUICtrlListView_DeleteItem($GUI_Lab_List, $EditLine)
EndFunc   ;==>_RemoveLabel

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
	_SetCWCBIB($CWIB_RadioType, $CWCB_RadioType)
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
	_SetCWCBIB($CWIB_Line, $CWCB_Line)
	_SetCWCBIB($CWIB_Active, $CWCB_Active)
	_SetCWCBIB($CWIB_SSID, $CWCB_SSID)
	_SetCWCBIB($CWIB_BSSID, $CWCB_BSSID)
	_SetCWCBIB($CWIB_Manu, $CWCB_Manu)
	_SetCWCBIB($CWIB_Signal, $CWCB_Signal)
	_SetCWCBIB($CWIB_Authentication, $CWCB_Authentication)
	_SetCWCBIB($CWIB_Encryption, $CWCB_Encryption)
	_SetCWCBIB($CWIB_NetType, $CWCB_NetType)
	_SetCWCBIB($CWIB_Label, $CWCB_Label)
EndFunc   ;==>_SetCwState

Func _GuessNetshSearchwords()
	Local $GSearchWord_SSID = '', $GSearchWord_NetworkType = '', $GSearchWord_Authentication = '', $GSearchWord_Encryption = '', $GSearchWord_BSSID = '', $GSearchWord_Signal = '', $GSearchWord_RadioType = '', $GSearchWord_Channel = '', $GSearchWord_BasicRates = '', $GSearchWord_OtherRates = ''
	$count = 0
	FileDelete($tempfile)
	If $DefaultApapter = $Text_Default Then
		_RunDOS('netsh wlan show networks mode=bssid > ' & '"' & $tempfile & '"') ;copy the output of the 'netsh wlan show networks mode=bssid' command to the temp file
	Else
		_RunDOS($netsh & ' wlan show networks interface="' & $DefaultApapter & '" mode=bssid > ' & '"' & $tempfile & '"') ;copy the output of the 'netsh wlan show networks mode=bssid' command to the temp file
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
			Local $ApMatchArray, $iRows, $iColumns, $iRval
			$query = "SELECT LastHistID, Active FROM AP WHERE ListRow = '" & $Selected & "'"
			$iRval = _SQLite_GetTable2d($DBhndl, $query, $ApMatchArray, $iRows, $iColumns)
			$FoundApMatch = $iRows
			If $FoundApMatch <> 0 Then
				$PlayHistID = $ApMatchArray[1][0]
				$ApIsActive = $ApMatchArray[1][1]
				Local $HistMatchArray, $iRows, $iColumns, $iRval
				$query = "SELECT Signal FROM Hist WHERE HistID = '" & $PlayHistID & "'"
				$iRval = _SQLite_GetTable2d($DBhndl, $query, $HistMatchArray, $iRows, $iColumns)
				$FoundHistMatch = $iRows
				If $FoundHistMatch <> 0 Then
					If $ApIsActive = 1 Then
						$say = $HistMatchArray[1][0]
					Else
						$say = '0'
					EndIf
					If ProcessExists($SayProcess) = 0 Then;If Say.exe is still running, skip opening it again
						If $SpeakType = 1 Then
							$run = FileGetShortName(@ScriptDir & '\say.exe') & ' /s="' & $say & '" /t=1'
							If $SpeakSigSayPecent = 1 Then $run &= ' /p'
							$SayProcess = Run(@ComSpec & " /C " & $run, '', @SW_HIDE)
							If @error Then $ErrorFlag = 1
						ElseIf $SpeakType = 2 Then
							$run = FileGetShortName(@ScriptDir & '\say.exe') & ' /s="' & $say & '" /t=2'
							If $SpeakSigSayPecent = 1 Then $run &= ' /p'
							$SayProcess = Run(@ComSpec & " /C " & $run, '', @SW_HIDE)
							If @error Then $ErrorFlag = 1
						ElseIf $SpeakType = 3 Then
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
		Local $TempHistArray, $iRows, $iColumns, $iRval
		$query = "SELECT Signal FROM Hist WHERE GpsID = '" & $GPS_ID & "'"
		$iRval = _SQLite_GetTable2d($DBhndl, $query, $TempHistArray, $iRows, $iColumns)
		$FoundTempHist = $iRows
		If $FoundTempHist <> 0 Then
			$PlaySignals = ''
			For $mp = 1 To $FoundTempHist
				If $mp <> 1 Then $PlaySignals &= '-'
				$PlaySignals &= $TempHistArray[$mp][0]
			Next
			If $PlaySignals <> '' Then
				$run = FileGetShortName(@ScriptDir & '\say.exe') & ' /ms=' & $PlaySignals & ' /t=4 /i=' & $Midi_Instument & ' /w=' & $Midi_PlayTime
				$MidiProcess = Run(@ComSpec & " /C " & $run, '', @SW_HIDE)
			EndIf
		EndIf
	EndIf
EndFunc   ;==>_PlayMidiForActiveAPs

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
	Run(@ScriptDir & '\update.exe /s="' & $NewVersionFile & '"')
	Exit
EndFunc   ;==>_StartUpdate

Func _CheckForUpdates()
	$UpdatesAvalible = 0
	DirCreate(@ScriptDir & '\temp\')
	FileDelete($NewVersionFile)
	If $CheckForBetaUpdates = 1 Then
		$get = InetGet($VIEWSVN_ROOT & 'versions-beta.ini', $NewVersionFile)
		If $get = 0 Then FileDelete($NewVersionFile)
	Else
		$get = InetGet($VIEWSVN_ROOT & 'versions.ini', $NewVersionFile)
		If $get = 0 Then FileDelete($NewVersionFile)
	EndIf
	If FileExists($NewVersionFile) Then
		$fv = IniReadSection($NewVersionFile, "FileVersions")
		If Not @error Then
			For $i = 1 To $fv[0][0]
				$FileName = $fv[$i][0]
				$fversion = $fv[$i][1]
				If IniRead($CurrentVersionFile, "FileVersions", $FileName, '0') <> $fversion Or FileExists(@ScriptDir & '\' & $FileName) = 0 Then
					If $FileName = 'update.exe' Then
						$getfileerror = 0
						$dfile = InetGet($VIEWSVN_ROOT & $FileName & '?revision=' & $fversion, @ScriptDir & '\' & $FileName, 1, 1)
						While InetGetInfo();While Download Active
							Sleep(5)
						WEnd
						If InetGetInfo($dfile, 3) = False Then $getfileerror = 1
						If $getfileerror = 0 And FileGetSize($FileName) <> 0 Then IniWrite($CurrentVersionFile, "FileVersions", $FileName, $fversion)
					EndIf
					$UpdatesAvalible = 1
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
	Local $FiltMatchArray, $iRows, $iColumns, $iRval
	$query = "SELECT FiltID, FiltName, FiltDesc FROM Filters"
	$iRval = _SQLite_GetTable2d($FiltDBhndl, $query, $FiltMatchArray, $iRows, $iColumns)
	$FoundFiltMatch = $iRows
	If $FoundFiltMatch <> 0 Then
		For $ffm = 1 To $FoundFiltMatch
			$Filter_ID = $FiltMatchArray[$ffm][0]
			$Filter_Name = $FiltMatchArray[$ffm][1]
			$Filter_Desc = $FiltMatchArray[$ffm][2]
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
		_SQLite_Exec($DBhndl, $query)
		$FiltID -= 1
		$query = "UPDATE Filters SET FiltID = FiltID - 1 WHERE FiltID > '" & $FilterID & "'"
		_SQLite_Exec($DBhndl, $query)
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
	Local $Filter_Name, $Filter_Desc, $Filter_SSID = "*", $Filter_BSSID = "*", $Filter_CHAN = "*", $Filter_AUTH = "*", $Filter_ENCR = "*", $Filter_RADTYPE = "*", $Filter_NETTYPE = "*", $Filter_SIG = "*", $Filter_BTX = "*", $Filter_OTX = "*", $Filter_Line = "*", $Filter_Active = "*"
	If $Filter_ID <> '-1' Then
		Local $FiltMatchArray, $iRows, $iColumns, $iRval
		$query = "SELECT FiltName, FiltDesc, SSID, BSSID, CHAN, AUTH, ENCR, RADTYPE, NETTYPE, Signal, BTX, OTX, ApID, Active FROM Filters WHERE FiltID='" & $Filter_ID & "'"
		$iRval = _SQLite_GetTable2d($DBhndl, $query, $FiltMatchArray, $iRows, $iColumns)
		$Filter_Name = $FiltMatchArray[1][0]
		$Filter_Desc = $FiltMatchArray[1][1]
		$Filter_SSID = $FiltMatchArray[1][2]
		$Filter_BSSID = $FiltMatchArray[1][3]
		$Filter_CHAN = $FiltMatchArray[1][4]
		$Filter_AUTH = $FiltMatchArray[1][5]
		$Filter_ENCR = $FiltMatchArray[1][6]
		$Filter_RADTYPE = $FiltMatchArray[1][7]
		$Filter_NETTYPE = $FiltMatchArray[1][8]
		$Filter_SIG = $FiltMatchArray[1][9]
		$Filter_BTX = $FiltMatchArray[1][10]
		$Filter_OTX = $FiltMatchArray[1][11]
		$Filter_Line = $FiltMatchArray[1][12]
		$Filter_Active = $FiltMatchArray[1][13]
	EndIf
	$Filter_ID_GUI = $Filter_ID

	$AddEditFilt_GUI = GUICreate("Add/Edit Filter", 690, 500, -1, -1, BitOR($WS_OVERLAPPEDWINDOW, $WS_CLIPSIBLINGS))


	GUICtrlCreateLabel("Filter Name", 28, 15, 300, 15)
	GUICtrlSetColor(-1, $TextColor)
	$Filter_Name_GUI = GUICtrlCreateInput($Filter_Name, 28, 30, 300, 20)
	GUICtrlCreateLabel("Filter Description", 353, 15, 300, 15)
	GUICtrlSetColor(-1, $TextColor)
	$Filter_Desc_GUI = GUICtrlCreateInput($Filter_Desc, 353, 30, 300, 20)



	GUISetBkColor($BackgroundColor)
	GUICtrlCreateGroup('Filters', 8, 75, 665, 400)
	GUICtrlCreateLabel($Text_FilterMsg, 32, 90, 618, 40)
	GUICtrlSetColor(-1, $TextColor)
	GUICtrlSetColor(-1, $TextColor)
	GUICtrlCreateLabel($SearchWord_SSID, 28, 125, 300, 15)
	GUICtrlSetColor(-1, $TextColor)
	$Filter_SSID_GUI = GUICtrlCreateInput($Filter_SSID, 28, 140, 300, 20)
	GUICtrlCreateLabel($SearchWord_BSSID, 28, 165, 300, 15)
	GUICtrlSetColor(-1, $TextColor)
	$Filter_BSSID_GUI = GUICtrlCreateInput($Filter_BSSID, 28, 180, 300, 20)
	GUICtrlCreateLabel($SearchWord_Channel, 28, 205, 300, 15)
	GUICtrlSetColor(-1, $TextColor)
	$Filter_CHAN_GUI = GUICtrlCreateInput($Filter_CHAN, 28, 220, 300, 20)
	GUICtrlCreateLabel($SearchWord_Authentication, 28, 245, 300, 15)
	GUICtrlSetColor(-1, $TextColor)
	$Filter_AUTH_GUI = GUICtrlCreateInput($Filter_AUTH, 28, 260, 300, 20)
	GUICtrlCreateLabel($SearchWord_Encryption, 28, 285, 300, 15)
	GUICtrlSetColor(-1, $TextColor)
	$Filter_ENCR_GUI = GUICtrlCreateInput($Filter_ENCR, 28, 300, 300, 20)
	GUICtrlCreateLabel($SearchWord_RadioType, 28, 325, 300, 15)
	GUICtrlSetColor(-1, $TextColor)
	$Filter_RADTYPE_GUI = GUICtrlCreateInput($Filter_RADTYPE, 28, 340, 300, 20)
	GUICtrlCreateLabel($SearchWord_NetworkType, 28, 365, 300, 15)
	GUICtrlSetColor(-1, $TextColor)
	$Filter_NETTYPE_GUI = GUICtrlCreateInput($Filter_NETTYPE, 28, 380, 300, 20)
	GUICtrlCreateLabel($SearchWord_Signal, 28, 405, 300, 15)
	GUICtrlSetColor(-1, $TextColor)
	$Filter_SIG_GUI = GUICtrlCreateInput($Filter_SIG, 28, 420, 300, 20)
	GUICtrlCreateLabel($SearchWord_BasicRates, 353, 125, 300, 15)
	GUICtrlSetColor(-1, $TextColor)
	$Filter_BTX_GUI = GUICtrlCreateInput($Filter_BTX, 353, 140, 300, 20)
	GUICtrlCreateLabel($SearchWord_OtherRates, 353, 165, 300, 15)
	GUICtrlSetColor(-1, $TextColor)
	$Filter_OTX_GUI = GUICtrlCreateInput($Filter_OTX, 353, 180, 300, 20)
	GUICtrlCreateLabel('Line', 353, 205, 300, 15)
	GUICtrlSetColor(-1, $TextColor)
	$Filter_Line_GUI = GUICtrlCreateInput($Filter_Line, 353, 220, 300, 20)
	GUICtrlCreateLabel($Text_Active, 353, 245, 300, 15)
	GUICtrlSetColor(-1, $TextColor)
	$Filter_Active_GUI = GUICtrlCreateInput($Filter_Active, 353, 260, 300, 20)
	GUICtrlSetColor(-1, $TextColor)
	$GUI_AddEditFilt_Can = GUICtrlCreateButton($Text_Cancel, 535, 470, 75, 25, 0)
	$GUI_AddEditFilt_Ok = GUICtrlCreateButton($Text_Ok, 460, 470, 75, 25, 0)

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
	$Filter_Desc = GUICtrlRead($Filter_Desc_GUI)
	$Filter_SSID = GUICtrlRead($Filter_SSID_GUI)
	$Filter_BSSID = GUICtrlRead($Filter_BSSID_GUI)
	$Filter_CHAN = GUICtrlRead($Filter_CHAN_GUI)
	$Filter_AUTH = GUICtrlRead($Filter_AUTH_GUI)
	$Filter_ENCR = GUICtrlRead($Filter_ENCR_GUI)
	$Filter_RADTYPE = GUICtrlRead($Filter_RADTYPE_GUI)
	$Filter_NETTYPE = GUICtrlRead($Filter_NETTYPE_GUI)
	$Filter_SIG = GUICtrlRead($Filter_SIG_GUI)
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
	If $Filter_BTX = '' Then $Filter_BTX = '*'
	If $Filter_OTX = '' Then $Filter_OTX = '*'
	If $Filter_Line = '' Then $Filter_Line = '*'
	If $Filter_Active = '' Then $Filter_Active = '*'

	If $Filter_ID_GUI = '-1' Then
		$FiltID += 1
		$query = "INSERT INTO Filters (FiltID,FiltName,FiltDesc,SSID,BSSID,CHAN,AUTH,ENCR,RADTYPE,NETTYPE,Signal,BTX,OTX,ApID,Active) VALUES ('" & $FiltID & "','" & $Filter_Name & "','" & $Filter_Desc & "','" & $Filter_SSID & "','" & $Filter_BSSID & "','" & $Filter_CHAN & "','" & $Filter_AUTH & "','" & $Filter_ENCR & "','" & $Filter_RADTYPE & "','" & $Filter_NETTYPE & "','" & $Filter_SIG & "','" & $Filter_BTX & "','" & $Filter_OTX & "','" & $Filter_Line & "','" & $Filter_Active & "');"
		_SQLite_Exec($FiltDBhndl, $query)
		$menuid = GUICtrlCreateMenuItem($Filter_Name, $FilterMenu)
		GUICtrlSetOnEvent($menuid, '_FilterChanged')
		_ArrayAdd($FilterMenuID_Array, $menuid)
		_ArrayAdd($FilterID_Array, $FiltID)
		$FilterMenuID_Array[0] = UBound($FilterMenuID_Array) - 1
		$FilterID_Array[0] = UBound($FilterID_Array) - 1
	Else
		$Filter_ID = $Filter_ID_GUI
		$query = "UPDATE Filters SET FiltName='" & $Filter_Name & "', FiltDesc='" & $Filter_Desc & "', SSID='" & $Filter_SSID & "', BSSID='" & $Filter_BSSID & "', CHAN='" & $Filter_CHAN & "', AUTH='" & $Filter_AUTH & "', ENCR='" & $Filter_ENCR & "', RADTYPE='" & $Filter_RADTYPE & "', NETTYPE='" & $Filter_NETTYPE & "', Signal='" & $Filter_SIG & "', BTX='" & $Filter_BTX & "', OTX='" & $Filter_OTX & "', ApID='" & $Filter_Line & "', Active='" & $Filter_Active & "' WHERE FiltID='" & $Filter_ID & "'"
		_SQLite_Exec($DBhndl, $query)
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
EndFunc   ;==>_FilterChanged

Func _CreateFilterQuerys()
	$AddQuery = "SELECT ApID, SSID, BSSID, NETTYPE, RADTYPE, CHAN, AUTH, ENCR, SecType, BTX, OTX, MANU, LABEL, HighGpsHistID, FirstHistID, LastHistID, LastGpsID, Active FROM AP"
	$RemoveQuery = "SELECT ApID, SSID, BSSID, NETTYPE, RADTYPE, CHAN, AUTH, ENCR, SecType, BTX, OTX, MANU, LABEL, HighGpsHistID, FirstHistID, LastHistID, LastGpsID, Active FROM AP"
	If $DefFiltID <> '-1' Then
		Local $FiltMatchArray, $iRows, $iColumns, $iRval
		$query = "SELECT SSID, BSSID, CHAN, AUTH, ENCR, RADTYPE, NETTYPE, Signal, BTX, OTX, ApID, Active FROM Filters WHERE FiltID='" & $DefFiltID & "'"
		$iRval = _SQLite_GetTable2d($FiltDBhndl, $query, $FiltMatchArray, $iRows, $iColumns)
		$Filter_SSID = $FiltMatchArray[1][0]
		$Filter_BSSID = $FiltMatchArray[1][1]
		$Filter_CHAN = $FiltMatchArray[1][2]
		$Filter_AUTH = $FiltMatchArray[1][3]
		$Filter_ENCR = $FiltMatchArray[1][4]
		$Filter_RADTYPE = $FiltMatchArray[1][5]
		$Filter_NETTYPE = $FiltMatchArray[1][6]
		$Filter_SIG = $FiltMatchArray[1][7]
		$Filter_BTX = $FiltMatchArray[1][8]
		$Filter_OTX = $FiltMatchArray[1][9]
		$Filter_Line = $FiltMatchArray[1][10]
		$Filter_Active = $FiltMatchArray[1][11]

		$aquery = ''
		$aquery = _AddFilerString($aquery, 'SSID', $Filter_SSID)
		$aquery = _AddFilerString($aquery, 'BSSID', $Filter_BSSID)
		$aquery = _AddFilerString($aquery, 'CHAN', $Filter_CHAN)
		$aquery = _AddFilerString($aquery, 'AUTH', $Filter_AUTH)
		$aquery = _AddFilerString($aquery, 'ENCR', $Filter_ENCR)
		$aquery = _AddFilerString($aquery, 'RADTYPE', $Filter_RADTYPE)
		$aquery = _AddFilerString($aquery, 'NETTYPE', $Filter_NETTYPE)
		$aquery = _AddFilerString($aquery, 'Signal', $Filter_SIG)
		$aquery = _AddFilerString($aquery, 'BTX', $Filter_BTX)
		$aquery = _AddFilerString($aquery, 'OTX', $Filter_OTX)
		$aquery = _AddFilerString($aquery, 'ApID', $Filter_Line)
		$aquery = _AddFilerString($aquery, 'Active', $Filter_Active)
		If $aquery <> '' Then $AddQuery &= ' WHERE (' & $aquery & ')'

		$rquery = ''
		$rquery = _RemoveFilterString($rquery, 'SSID', $Filter_SSID)
		$rquery = _RemoveFilterString($rquery, 'BSSID', $Filter_BSSID)
		$rquery = _RemoveFilterString($rquery, 'CHAN', $Filter_CHAN)
		$rquery = _RemoveFilterString($rquery, 'AUTH', $Filter_AUTH)
		$rquery = _RemoveFilterString($rquery, 'ENCR', $Filter_ENCR)
		$rquery = _RemoveFilterString($rquery, 'RADTYPE', $Filter_RADTYPE)
		$rquery = _RemoveFilterString($rquery, 'NETTYPE', $Filter_NETTYPE)
		$rquery = _RemoveFilterString($rquery, 'Signal', $Filter_SIG)
		$rquery = _RemoveFilterString($rquery, 'BTX', $Filter_BTX)
		$rquery = _RemoveFilterString($rquery, 'OTX', $Filter_OTX)
		$rquery = _RemoveFilterString($rquery, 'ApID', $Filter_Line)
		$rquery = _RemoveFilterString($rquery, 'Active', $Filter_Active)
		If $rquery <> '' Then $RemoveQuery &= ' WHERE (' & $rquery & ')'
	EndIf
EndFunc   ;==>_CreateFilterQuerys

;-------------------------------------------------------------------------------------------------------------------------------
;                                                       WIRELESS INTERFACE FUNCTIONS
;-------------------------------------------------------------------------------------------------------------------------------

Func _AddInterfaces()
	Dim $NetworkAdapters[1]
	Local $found_adapter = 0
	Local $menuid = 0
	If $UseNativeWifi = 1 Then
		$wlaninterfaces = _Wlan_EnumInterfaces($wlanhandle)
		$numofint = UBound($wlaninterfaces) - 1
		For $antm = 0 To $numofint
			$adapterid = $wlaninterfaces[$antm][0]
			$adaptername = $wlaninterfaces[$antm][1]
			$menuid = GUICtrlCreateMenuItem($adaptername, $Interfaces)
			_ArrayAdd($NetworkAdapters, $menuid)
			GUICtrlSetOnEvent($menuid, '_InterfaceChanged')
			If $DefaultApapter = $adaptername Then
				$found_adapter = 1
				$DefaultApapterID = $adapterid
				GUICtrlSetState($menuid, $GUI_CHECKED)
			EndIf
		Next
		If $menuid <> 0 And $found_adapter = 0 Then
			$DefaultApapter = $adaptername
			$DefaultApapterID = $adapterid
			GUICtrlSetState($menuid, $GUI_CHECKED)
		EndIf
		If $menuid = 0 Then GUICtrlCreateMenuItem($Text_NoAdaptersFound, $Interfaces)
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
		If $menuid = 0 Then GUICtrlCreateMenuItem($Text_NoAdaptersFound, $Interfaces)
		$NetworkAdapters[0] = UBound($NetworkAdapters) - 1
		;Find adapterid
		$wlaninterfaces = _Wlan_EnumInterfaces($wlanhandle)
		$numofint = UBound($wlaninterfaces) - 1
		For $antm = 0 To $numofint
			If $DefaultApapterDesc = $wlaninterfaces[$antm][1] Then $DefaultApapterID = $wlaninterfaces[$antm][0]
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
		$wlaninterfaces = _Wlan_EnumInterfaces($wlanhandle)
		$numofint = UBound($wlaninterfaces) - 1
		For $antm = 0 To $numofint
			$adapterid = $wlaninterfaces[$antm][0]
			$adaptername = $wlaninterfaces[$antm][1]
			If $DefaultApapter = $adaptername Then $DefaultApapterID = $adapterid
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
		$wlanhandle = _Wlan_OpenHandle()
		$wlaninterfaces = _Wlan_EnumInterfaces($wlanhandle)
		$numofint = UBound($wlaninterfaces) - 1
		For $antm = 0 To $numofint
			If $DefaultApapterDesc = $wlaninterfaces[$antm][1] Then $DefaultApapterID = $wlaninterfaces[$antm][0]
		Next
	EndIf
EndFunc   ;==>_InterfaceChanged

Func _RefreshInterfaces()
	;Delete all old menu items
	For $ri = 1 To $NetworkAdapters[0]
		$menuid = $NetworkAdapters[$ri]
		GUICtrlDelete($menuid)
	Next
	;Add updated interfaces
	_AddInterfaces()
EndFunc   ;==>_RefreshInterfaces

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

Func _EstimateDbFromSignalPercent($InSig)
	$EstimatedDB = Round(-70 + (20 * Log10($InSig / (105 - $InSig))))
	Return ($EstimatedDB)
EndFunc   ;==>_EstimateDbFromSignalPercent

;-------------------------------------------------------------------------------------------------------------------------------
;                                                       OTHER FUNCTIONS
;-------------------------------------------------------------------------------------------------------------------------------

Func MyErrFunc()
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, 'MyErrFunc()') ;#Debug Display
	$ComError = 1
EndFunc   ;==>MyErrFunc

Func _ReduceMemory() ;http://www.autoitscript.com/forum/index.php?showtopic=14070&view=findpost&p=96101
	DllCall("psapi.dll", 'int', 'EmptyWorkingSet', 'long', -1)
EndFunc   ;==>_ReduceMemory

Func _MenuSelectConnectedAp()
	Local $SelConAP = _SelectConnectedAp()
	If $SelConAP = -1 Then
		;MsgBox(0, $Text_Error, $Text_NoActiveApFound & @CRLF & @CRLF & $Column_Names_BSSID & ':' & $IntBSSID & @CRLF & $Column_Names_SSID & ':' & $IntSSID & @CRLF & $Column_Names_Channel & ':' & $IntChan & @CRLF & $Column_Names_Authentication & ':' & $IntAuth)
	ElseIf $SelConAP = 0 Then
		MsgBox(0, $Text_Error, $Text_NoActiveApFound)
	EndIf
EndFunc   ;==>_MenuSelectConnectedAp

Func _SelectConnectedAp()
	$return = 0
	FileDelete($tempfile_showint)
	_RunDOS($netsh & ' wlan show interfaces interface="' & $DefaultApapter & '" > ' & '"' & $tempfile_showint & '"') ;copy the output of the 'netsh wlan show interfaces' command to the temp file
	$showintarraysize = _FileReadToArray($tempfile_showint, $TempFileArrayShowInt);read the tempfile into the '$TempFileArrayShowInt' Araay
	If $showintarraysize = 1 Then
		For $strip_ws = 1 To $TempFileArrayShowInt[0]
			$TempFileArrayShowInt[$strip_ws] = StringStripWS($TempFileArrayShowInt[$strip_ws], 3)
		Next

		Dim $IntState, $IntSSID, $IntBSSID, $IntChan, $IntAuth, $InEncr
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
		If $UseNativeWifi = 1 Then
			If $IntAuth = $SearchWord_Open And $InEncr = $SearchWord_None Then
				$SecType = 1
			ElseIf $InEncr = $SearchWord_Wep Then
				$SecType = 2
			Else
				$SecType = 3
			EndIf
			$query = "SELECT ListRow FROM AP WHERE SSID ='" & StringReplace($IntSSID, "'", "''") & "' And SECTYPE = '" & $SecType & "'"
		Else
			$query = "SELECT ListRow FROM AP WHERE BSSID = '" & $IntBSSID & "' And SSID ='" & StringReplace($IntSSID, "'", "''") & "' And CHAN = '" & StringFormat("%03i", $IntChan) & "' And AUTH = '" & $IntAuth & "'"
		EndIf
		Local $ApMatchArray, $iRows, $iColumns, $iRval
		$iRval = _SQLite_GetTable2d($DBhndl, $query, $ApMatchArray, $iRows, $iColumns)
		$FoundApMatch = $iRows
		If $FoundApMatch > 0 Then
			$return = 1
			$Found_ListRow = $ApMatchArray[1][0]
			_GUICtrlListView_SetItemState($ListviewAPs, $Found_ListRow, $LVIS_FOCUSED, $LVIS_FOCUSED)
			_GUICtrlListView_SetItemState($ListviewAPs, $Found_ListRow, $LVIS_SELECTED, $LVIS_SELECTED)
			GUICtrlSetState($ListviewAPs, $GUI_FOCUS)
		Else
			$return = 0
		EndIf
	EndIf
	Return ($return)
EndFunc   ;==>_SelectConnectedAp

Func _DataMatchInDelimitedString($mdata, $mDelimitedString, $mDelimiter = '|', $mAllSymbol = '*')
	If $mDelimitedString = $mAllSymbol Then
		Return (1)
	Else
		$M_Found = 0
		$M_SplitString = StringSplit($mDelimitedString, $mDelimiter)
		For $m = 1 To $M_SplitString[0]
			If $M_SplitString[$m] = $mdata Then
				$M_Found = 1
				ExitLoop
			EndIf
		Next
		If $M_Found = 1 Then
			Return (1)
		Else
			Return (0)
		EndIf
	EndIf
EndFunc   ;==>_DataMatchInDelimitedString

Func _DeleteListviewRow($dapid)
	;_GUICtrlListView_DeleteItem($ListviewAPs, $drow)
	;$query = "UPDATE AP SET ListRow = '-1' WHERE ApID = '" & $fApID & "'"
	;_ExecuteMDB($VistumblerDB, $DB_OBJ, $query)
	;$query = " AP SET ListRow = ListRow - 1 WHERE ListRow > '" & $fListRow & "'"
	;_ExecuteMDB($VistumblerDB, $DB_OBJ, $query)
EndFunc   ;==>_DeleteListviewRow

Func _NewSession()
	Run(@ScriptDir & "\" & $VistumblerEXE)
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

#comments-start
	Func _OpenExternalTool()
	$menuid = @GUI_CtrlId
	$file = ""
	For $tma = 1 To $ToolMenuID[0]
	If $ToolMenuID[$tma] = $menuid Then $file = $ToolFilename[$tma]
	Next
	If $file <> "" Then Run("RunDll32.exe url.dll,FileProtocolHandler " & $file);open file with rundll 32	$query = "pragma synchronous=0"
	_SQLite_Exec($DBhndl, $query)
	EndFunc   ;==>_OpenExternalTool
#comments-end

Func _ImportWardriveDb3($DB3file)
	$WardriveImpDB = _SQLite_Open($DB3file, $SQLITE_OPEN_READWRITE + $SQLITE_OPEN_CREATE, $SQLITE_ENCODING_UTF16)
	Local $NetworkMatchArray, $iRows, $iColumns, $iRval
	$query = "SELECT bssid, ssid, capabilities, level, frequency, lat, lon, alt, timestamp FROM networks"
	$iRval = _SQLite_GetTable2d($WardriveImpDB, $query, $NetworkMatchArray, $iRows, $iColumns)
	$WardriveAPs = $iRows
	_ArrayDisplay($NetworkMatchArray)

	$UpdateTimer = TimerInit()
	$begintime = TimerInit()
	$AddAP = 0
	$AddGID = 0
	For $NewAP = 1 To $WardriveAPs
		$Found_BSSID = StringUpper($NetworkMatchArray[$NewAP][0])
		$Found_SSID = $NetworkMatchArray[$NewAP][1]
		$Found_Capabilies = $NetworkMatchArray[$NewAP][2]
		$Found_Level = $NetworkMatchArray[$NewAP][3]
		$Found_Frequency = $NetworkMatchArray[$NewAP][4]
		$Found_Lat = _Format_GPS_DDD_to_DMM($NetworkMatchArray[$NewAP][5], "N", "S")
		$Found_Lon = _Format_GPS_DDD_to_DMM($NetworkMatchArray[$NewAP][6], "E", "W")
		$Found_Alt = $NetworkMatchArray[$NewAP][7]
		$Found_TimeStamp = StringTrimRight($NetworkMatchArray[$NewAP][8], 3)

		;Get Authentication and Encrytion from capabilities
		If StringInStr($Found_Capabilies, "WPA2-PSK-CCMP") Or StringInStr($Found_Capabilies, "WPA2-PSK-TKIP+CCMP") Then
			$Found_AUTH = "WPA2-Personal"
			$Found_ENCR = "CCMP"
			$Found_SecType = "3"
		ElseIf StringInStr($Found_Capabilies, "WPA-PSK-CCMP") Or StringInStr($Found_Capabilies, "WPA-PSK-TKIP+CCMP") Then
			$Found_AUTH = "WPA-Personal"
			$Found_ENCR = "CCMP"
			$Found_SecType = "3"
		ElseIf StringInStr($Found_Capabilies, "WPA2-EAP-CCMP") Or StringInStr($Found_Capabilies, "WPA2-EAP-TKIP+CCMP") Then
			$Found_AUTH = "WPA2-Enterprise"
			$Found_ENCR = "CCMP"
			$Found_SecType = "3"
		ElseIf StringInStr($Found_Capabilies, "WPA-EAP-CCMP") Or StringInStr($Found_Capabilies, "WPA-EAP-TKIP+CCMP") Then
			$Found_AUTH = "WPA-Enterprise"
			$Found_ENCR = "CCMP"
			$Found_SecType = "3"
		ElseIf StringInStr($Found_Capabilies, "WPA2-PSK-TKIP") Then
			$Found_AUTH = "WPA2-Personal"
			$Found_ENCR = "TKIP"
			$Found_SecType = "3"
		ElseIf StringInStr($Found_Capabilies, "WPA-PSK-TKIP") Then
			$Found_AUTH = "WPA-Personal"
			$Found_ENCR = "TKIP"
			$Found_SecType = "3"
		ElseIf StringInStr($Found_Capabilies, "WPA2-EAP-TKIP") Then
			$Found_AUTH = "WPA2-Enterprise"
			$Found_ENCR = "TKIP"
			$Found_SecType = "3"
		ElseIf StringInStr($Found_Capabilies, "WPA-EAP-TKIP") Then
			$Found_AUTH = "WPA-Enterprise"
			$Found_ENCR = "TKIP"
			$Found_SecType = "3"
		ElseIf StringInStr($Found_Capabilies, "WEP") Then
			$Found_AUTH = "Open"
			$Found_ENCR = "WEP"
			$Found_SecType = "2"
		Else
			$Found_AUTH = "Open"
			$Found_ENCR = "None"
			$Found_SecType = "1"
		EndIf

		;Get Network Type from capabilities
		If StringInStr($Found_Capabilies, "[IBSS]") Then
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
		Local $GpsMatchArray, $iRows, $iColumns, $iRval
		$query = "SELECT GPSID FROM GPS WHERE Latitude = '" & $Found_Lat & "' And Longitude = '" & $Found_Lon & "' And Date1 = '" & $Found_Date & "' And Time1 = '" & $Found_Time & "'"
		$iRval = _SQLite_GetTable2d($DBhndl, $query, $GpsMatchArray, $iRows, $iColumns)
		$FoundGpsMatch = $iRows
		If $FoundGpsMatch = 0 Then
			$AddGID += 1
			$GPS_ID += 1
			;Add GPS ID
			$query = "INSERT INTO GPS(GPSID,Latitude,Longitude,NumOfSats,HorDilPitch,Alt,Geo,SpeedInMPH,SpeedInKmH,TrackAngle,Date1,Time1) VALUES ('" & $GPS_ID & "','" & $Found_Lat & "','" & $Found_Lon & "','0','0','" & $Found_Alt & "','0','0','0','0','" & $Found_Date & "','" & $Found_Time & "');"
			_SQLite_Exec($DBhndl, $query)
			$NewGpsId = $GPS_ID
		ElseIf $FoundGpsMatch = 1 Then
			$NewGpsId = $GpsMatchArray[1][0]
		EndIf

		;Add AP data into Vistumbler DB
		$NewApAdded = _AddApData(0, $NewGpsId, $Found_BSSID, $Found_SSID, $Found_CHAN, $Found_AUTH, $Found_ENCR, $Found_NETTYPE, "802.11g", "Unknown", "Unknown", "0")
		If $NewApAdded = 1 Then $AddAP += 1

		If TimerDiff($UpdateTimer) > 600 Or ($NewAP = $WardriveAPs) Then
			$min = (TimerDiff($begintime) / 60000) ;convert from miniseconds to minutes
			$percent = ($NewAP / $WardriveAPs) * 100
			GUICtrlSetData($progressbar, $percent)
			GUICtrlSetData($percentlabel, $Text_Progress & ': ' & Round($percent, 1))
			GUICtrlSetData($linemin, $Text_LinesMin & ': ' & Round($Load / $min, 1))
			GUICtrlSetData($newlines, $Text_NewAPs & ': ' & $AddAP & ' - ' & $Text_NewGIDs & ':' & $AddGID)
			GUICtrlSetData($minutes, $Text_Minutes & ': ' & Round($min, 1))
			GUICtrlSetData($linetotal, $Text_LineTotal & ': ' & $NewAP & "/" & $WardriveAPs)
			GUICtrlSetData($estimatedtime, $Text_EstimatedTimeRemaining & ': ' & Round(($WardriveAPs / Round($NewAP / $min, 1)) - $min, 1) & "/" & Round($WardriveAPs / Round($NewAP / $min, 1), 1))
			$UpdateTimer = TimerInit()
		EndIf
	Next
	_SQLite_Close($WardriveImpDB)
EndFunc   ;==>_ImportWardriveDb3