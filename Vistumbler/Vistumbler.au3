#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Version=Beta
#AutoIt3Wrapper_Icon=icon.ico
#AutoIt3Wrapper_Outfile=Vistumbler.exe
#AutoIt3Wrapper_Run_Tidy=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
;License Information------------------------------------
;Copyright (C) 2008 Andrew Calcutt
;This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; Version 2 of the License.
;This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
;You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
;--------------------------------------------------------
;AutoIt Version: v3.2.13.3 Beta
$Script_Author = 'Andrew Calcutt'
$Script_Start_Date = '07/10/2007'
$Script_Name = 'Vistumbler'
$Script_Website = 'http://www.Vistumbler.net'
$Script_Function = 'A wireless network scanner for vista. This Program uses "netsh wlan show networks mode=bssid" to get wireless information.'
$version = 'v8.11'
$last_modified = '08/31/2008'
$title = $Script_Name & ' ' & $version & ' - By ' & $Script_Author & ' - ' & $last_modified
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
#include <String.au3>
#include "CommMG.au3"
#include "ZIP.au3"
;Associate VS1 with Vistumbler
If StringLower(StringTrimLeft(@ScriptName, StringLen(@ScriptName) - 4)) = '.exe' Then
	RegWrite('HKCR\.vsz\', '', 'REG_SZ', 'Vistumbler')
	RegWrite('HKCR\.vs1\', '', 'REG_SZ', 'Vistumbler')
	RegWrite('HKCR\Vistumbler\shell\open\command\', '', 'REG_SZ', '"' & @ScriptFullPath & '" "%1"')
	RegWrite('HKCR\Vistumbler\DefaultIcon\', '', 'REG_SZ', '"' & @ScriptDir & '\vs1_icon.ico"')
EndIf

Dim $Load = ''
For $loop = 1 To $CmdLine[0]
	If StringLower(StringTrimLeft($CmdLine[$loop], StringLen($CmdLine[$loop]) - 4)) = '.vs1' Then $Load = $CmdLine[$loop]
	If StringLower(StringTrimLeft($CmdLine[$loop], StringLen($CmdLine[$loop]) - 4)) = '.vsz' Then $Load = $CmdLine[$loop]
Next
; Set a COM Error handler--------------------------------
$oMyError = ObjEvent("AutoIt.Error", "MyErrFunc")
;Options-------------------------------------------------
Opt("TrayIconHide", 1);Hide icon in system tray
Opt("GUIOnEventMode", 1);Change to OnEvent mode
;Non Vista Warning---------------------------------------
If @OSVersion <> "WIN_VISTA" Then MsgBox(0, "Warning", "This Program will only run in Vista. It relies on a netsh command that is not avalible in older versions of windows")
;Declair-Variables---------------------------------------
Global $gdi_dll, $user32_dll
Global $hDC

Dim $MoveMode = False
Dim $MoveArea = False
Dim $DataChild_Width
Dim $DataChild_Height

Dim $GPS_ID = 0
Dim $NsOk
Dim $kml_timer
Dim $StartArraySize
Dim $Debug
Dim $debugdisplay
Dim $sErr
Dim $CompassGraphic, $compasspos_old, $compasspos, $north, $south, $east, $west, $CompassBack, $CompassHeight, $CompassBrush
Dim $TmpDir = @ScriptDir & '\temp\'
DirCreate($TmpDir)
Dim $GoogleEarth_ActiveFile = $TmpDir & 'autokml_active.kml'
Dim $GoogleEarth_DeadFile = $TmpDir & 'autokml_dead.kml'
Dim $GoogleEarth_GpsFile = $TmpDir & 'autokml_gps.kml'
Dim $GoogleEarth_TrackFile = $TmpDir & 'autokml_track.kml'
Dim $GoogleEarth_OpenFile = $TmpDir & 'autokml_networklink.kml'
Dim $tempfile = $TmpDir & "netsh_tmp.txt"
Dim $DefaultSaveDir = @ScriptDir & '\Save\'
Dim $SettingsDir = @ScriptDir & '\Settings\'
Dim $LanguageDir = @ScriptDir & '\Languages\'
Dim $SoundDir = @ScriptDir & '\Sounds\'
Dim $ImageDir = @ScriptDir & '\Images\'
Dim $settings = $SettingsDir & 'vistumbler_settings.ini'
Dim $labelsini = $SettingsDir & 'mac_labels.ini'
Dim $manufini = $SettingsDir & 'manufactures.ini'
Dim $Latitude = 'N 0.0000'
Dim $Longitude = 'E 0.0000'
Dim $Latitude2 = 'N 0.0000'
Dim $Longitude2 = 'E 0.0000'
Dim $NumberOfSatalites = '00'
Dim $TurnOffGPS = 0
Dim $UseGPS = 0
Dim $Scan = 0
Dim $Close = 0
Dim $ResetMacLabel = 0
Dim $ResetManLabel = 0
Dim $NewApFound = 0
Dim $ComError = 0
Dim $newdata = 0
Dim $o_old = 0
Dim $RefreshNetworks = 0
Dim $Loading = 0
Dim $disconnected_time = -1
Dim $SortColumn = -1
Dim $GUIList
Dim $TempFileArray, $NetComm, $OpenArray, $headers, $MANUF, $LABEL, $SigHist
Dim $SSID, $NetworkType, $Authentication, $Encryption, $BSSID, $Signal, $RadioType, $Channel, $BasicTransferRates, $OtherTransferRates
Dim $addposition, $newlat, $newlon, $LatTest, $gps, $winpos
Dim $sort_timer
Dim $data_old
Dim $RefreshTimer
Dim $sizes, $sizes_old
Dim $GraphBack, $GraphGrid, $red, $black
Dim $base_add = 0, $data, $data_old, $Graph = 0, $Graph_old, $ResetSizes = 1, $Redraw = 1
Dim $LastSelected = -1
Dim $save_timer
Dim $AutoSaveFile
Dim $ClearAllAps = 0
Dim $UpdateAutoKml = 0
Dim $UpdateAutoSave = 0
Dim $CompassOpen = 0
Dim $CompassGUI = 0
Dim $SayProcess

Dim $TreeviewAPs_left, $TreeviewAPs_width, $TreeviewAPs_top, $TreeviewAPs_height
Dim $ListviewAPs_left, $ListviewAPs_width, $ListviewAPs_top, $ListviewAPs_height
Dim $Graphic_left, $Graphic_width, $Graphic_top, $Graphic_height

Dim $FixTime, $FixTime2, $FixDate, $Quality, $HorDilPitch, $Alt, $AltS, $Geo, $GeoS, $Status, $SpeedInKnots, $SpeedInMPH, $SpeedInKmH, $TrackAngle
Dim $Temp_FixTime, $Temp_FixTime2, $Temp_FixDate, $Temp_Lat, $Temp_Lon, $Temp_Lat2, $Temp_Lon2, $Temp_Quality, $Temp_NumberOfSatalites, $Temp_HorDilPitch, $Temp_Alt, $Temp_AltS, $Temp_Geo, $Temp_GeoS, $Temp_Status, $Temp_SpeedInKnots, $Temp_SpeedInMPH, $Temp_SpeedInKmH, $Temp_TrackAngle
Dim $GpsDetailsGUI, $GPGGA_Update, $GPRMC_Update, $GpsDetailsOpen = 0
Dim $GpsCurrentDataGUI, $GPGGA_Time, $GPGGA_Lat, $GPGGA_Lon, $GPGGA_Quality, $GPGGA_Satalites, $GPGGA_HorDilPitch, $GPGGA_Alt, $GPGGA_Geo, $GPRMC_Time, $GPRMC_Date, $GPRMC_Lat, $GPRMC_Lon, $GPRMC_Status, $GPRMC_SpeedKnots, $GPRMC_SpeedMPH, $GPRMC_SpeedKmh, $GPRMC_TrackAngle
Dim $GUI_AutoSaveKml, $GUI_GoogleEXE, $GUI_AutoKmlActiveTime, $GUI_AutoKmlDeadTime, $GUI_AutoKmlGpsTime, $GUI_AutoKmlTrackTime, $GUI_KmlFlyTo, $AutoKmlActiveHeader, $AutoKmlDeadHeader, $GUI_OpenKmlNetLink, $GUI_AutoKml_Alt, $GUI_AutoKml_AltMode, $GUI_AutoKml_Heading, $GUI_AutoKml_Range, $GUI_AutoKml_Tilt
Dim $GUI_SpeakSignal, $GUI_SpeakSoundsVis, $GUI_SpeakSoundsSapi, $GUI_SpeakPercent, $GUI_SpeakSigTime

Dim $GUI_Import, $vistumblerfileinput, $progressbar, $percentlabel, $linemin, $newlines, $minutes, $linetotal, $estimatedtime, $RadVis, $RadNs

Dim $Apply_GPS = 1, $Apply_Language = 0, $Apply_Manu = 0, $Apply_Lab = 0, $Apply_Column = 1, $Apply_Searchword = 1, $Apply_Misc = 1, $Apply_Auto = 1, $Apply_AutoKML = 1
Dim $SetMisc, $GUI_Comport, $GUI_Baud, $GUI_Format, $Rad_UseNetcomm, $Rad_UseCommMG, $LanguageBox, $SearchWord_SSID_GUI, $SearchWord_BSSID_GUI, $SearchWord_NetType_GUI
Dim $SearchWord_Authentication_GUI, $SearchWord_Signal_GUI, $SearchWord_RadioType_GUI, $SearchWord_Channel_GUI, $SearchWord_BasicRates_GUI, $SearchWord_OtherRates_GUI, $SearchWord_Encryption_GUI, $SearchWord_Open_GUI
Dim $SearchWord_None_GUI, $SearchWord_Wep_GUI, $SearchWord_Infrastructure_GUI, $SearchWord_Adhoc_GUI

Dim $LabAuth, $LabDate, $LabDesc, $GUI_Set_SaveDir, $GUI_Set_SaveDirAuto, $GUI_Set_SaveDirKml, $GUI_BKColor, $GUI_CBKColor, $GUI_TextColor, $GUI_RefreshLoop
Dim $GUI_Manu_List, $GUI_Lab_List, $ImpLanFile
Dim $EditMacGUIForm, $GUI_Manu_NewManu, $GUI_Manu_NewMac, $EditMac_Mac, $EditMac_GUI, $EditLine, $GUI_Lab_NewMac, $GUI_Lab_NewLabel
Dim $AutoSaveBox, $AutoSaveDelBox, $AutoSaveSec, $GUI_SortDirection, $GUI_SortBy, $GUI_SortTime, $GUI_AutoSort, $GUI_SortTime, $GUI_PhilsGraphURL, $GUI_PhilsWdbURL

Dim $CWCB_RadioType, $CWIB_RadioType, $CWCB_Channel, $CWIB_Channel, $CWCB_Latitude, $CWIB_Latitude, $CWCB_Longitude, $CWIB_Longitude, $CWCB_LatitudeDMS, $CWIB_LatitudeDMS, $CWCB_LongitudeDMS, $CWIB_LongitudeDMS, $CWCB_LatitudeDMM, $CWIB_LatitudeDMM, $CWCB_LongitudeDMM, $CWIB_LongitudeDMM, $CWCB_BtX, $CWIB_BtX, $CWCB_OtX, $CWIB_OtX, $CWCB_FirstActive, $CWIB_FirstActive
Dim $CWCB_LastActive, $CWIB_LastActive, $CWCB_Line, $CWIB_Line, $CWCB_Active, $CWIB_Active, $CWCB_SSID, $CWIB_SSID, $CWCB_BSSID, $CWIB_BSSID, $CWCB_Manu, $CWIB_Manu, $CWCB_Signal, $CWIB_Signal
Dim $CWCB_Authentication, $CWIB_Authentication, $CWCB_Encryption, $CWIB_Encryption, $CWCB_NetType, $CWIB_NetType, $CWCB_Label, $CWIB_Label
;Define Arrays
Dim $Direction[23];Direction array for sorting by clicking on the header. Needs to be 1 greatet (or more) than the amount of columns
Dim $Direction2[3]
Dim $manu_mac[1], $manu_manu[1], $label_mac[1], $label_label[1];Define Arrays for "Labels by Mac" and "Manufacturer by Mac"

Dim $TmpArray_BSSID[1]
Dim $TmpArray_SSID[1]
Dim $TmpArray_Auth[1]
Dim $TmpArray_Encr[1]
Dim $TmpArray_Sig[1]
Dim $TmpArray_Chan[1]
Dim $TmpArray_Rad[1]
Dim $TmpArray_BtX[1]
Dim $TmpArray_OtX[1]
Dim $TmpArray_NetType[1]

Dim $DataArray_Line[1]
Dim $DataArray_Active[1]
Dim $DataArray_BSSID[1]
Dim $DataArray_SSID[1]
Dim $DataArray_Auth[1]
Dim $DataArray_Encr[1]
Dim $DataArray_SecType[1]
Dim $DataArray_Sig[1]
Dim $DataArray_HighGpsSig[1]
Dim $DataArray_Chan[1]
Dim $DataArray_Rad[1]
Dim $DataArray_Lon[1]
Dim $DataArray_Lat[1]
Dim $DataArray_BtX[1]
Dim $DataArray_OtX[1]
Dim $DataArray_NetType[1]
Dim $DataArray_FirstTime[1]
Dim $DataArray_LastTime[1]
Dim $DataArray_SigHist[1]
Dim $DataArray_Manu[1]
Dim $DataArray_Label[1]
Dim $DataArray_Row[1]
Dim $DataArray_GID[1]
Dim $DataArray_TreeViewSubChannel[1]
Dim $DataArray_TreeViewSubSSID[1]
Dim $DataArray_TreeViewSubEncr[1]
Dim $DataArray_TreeViewSubAuth[1]
Dim $DataArray_TreeViewSubNetType[1]

Dim $TreeView_Channel_Name[1]
Dim $TreeView_SSID_Name[1]
Dim $TreeView_Encryption_Name[1]
Dim $TreeView_Authentication_Name[1]
Dim $TreeView_NetworkType_Name[1]
Dim $TreeView_Channel_Pos[1]
Dim $TreeView_SSID_Pos[1]
Dim $TreeView_Encryption_Pos[1]
Dim $TreeView_Authentication_Pos[1]
Dim $TreeView_NetworkType_Pos[1]

Dim $GPSArray_ID[1]
Dim $GPSArray_Lat[1]
Dim $GPSArray_Lon[1]
Dim $GPSArray_Sat[1]
Dim $GPSArray_Date[1]
Dim $GPSArray_Time[1]

_SetTmpArraySizes()
_SetDataArraySizes()
_SetTreeArraySizes()

;Load-Settings-From-INI-File----------------------------
Dim $SaveDir = IniRead($settings, 'Vistumbler', 'SaveDir', $DefaultSaveDir)
Dim $SaveDirAuto = IniRead($settings, 'Vistumbler', 'SaveDirAuto', $DefaultSaveDir)
Dim $SaveDirKml = IniRead($settings, 'Vistumbler', 'SaveDirKml', $DefaultSaveDir)
Dim $DefaultLanguage = IniRead($settings, 'Vistumbler', 'Language', 'English')
Dim $netsh = IniRead($settings, 'Vistumbler', 'Netsh_exe', 'netsh.exe')
Dim $SplitPercent = IniRead($settings, 'Vistumbler', 'SplitPercent', '0.2')
Dim $SplitHeightPercent = IniRead($settings, 'Vistumbler', 'SplitHeightPercent', '0.65')
Dim $ComPort = IniRead($settings, 'Vistumbler', 'ComPort', 8)
Dim $BAUD = IniRead($settings, 'Vistumbler', 'Baud', 4800)
Dim $GpsTimeout = IniRead($settings, 'Vistumbler', 'GpsTimeout', 30000)
Dim $RefreshLoopTime = IniRead($settings, 'Vistumbler', 'Sleeptime', 1000)
Dim $SortTime = IniRead($settings, 'Vistumbler', 'AutoSortTime', 60)
Dim $AutoSort = IniRead($settings, 'Vistumbler', 'AutoSort', 0)
Dim $SaveTime = IniRead($settings, 'Vistumbler', 'AutoSaveTime', 60)
Dim $AutoSave = IniRead($settings, 'Vistumbler', 'AutoSave', 0)
Dim $AutoSaveDel = IniRead($settings, 'Vistumbler', 'AutoSaveDel', 1)
Dim $SortBy = IniRead($settings, 'Vistumbler', 'SortCombo', 'Sort by SSID')
Dim $SortDirection = IniRead($settings, 'Vistumbler', 'AscDecDefault', 1)
Dim $SoundOnAP = IniRead($settings, 'Vistumbler', 'PlaySoundOnNewAP', 0)
Dim $new_AP_sound = IniRead($settings, 'Vistumbler', 'NewAP_Sound', 'new_ap.wav')
Dim $error_sound = IniRead($settings, 'Vistumbler', 'Error_Sound', 'error.wav')
Dim $AddDirection = IniRead($settings, 'Vistumbler', 'NewApPosistion', 0)
Dim $TextColor = IniRead($settings, 'Vistumbler', 'TextColor', "0xFFFFFF")
Dim $BackgroundColor = IniRead($settings, 'Vistumbler', 'BackgroundColor', "0x99B4D1")
Dim $ControlBackgroundColor = IniRead($settings, 'Vistumbler', 'ControlBackgroundColor', "0xD7E4F2")
Dim $UseNetcomm = IniRead($settings, 'Vistumbler', 'UseNetcomm', 1)
Dim $RefreshTime = IniRead($settings, 'Vistumbler', 'RefreshTime', 2000)
Dim $MapOpen = IniRead($settings, 'Vistumbler', 'MapOpen', 1)
Dim $MapWEP = IniRead($settings, 'Vistumbler', 'MapWEP', 1)
Dim $MapSec = IniRead($settings, 'Vistumbler', 'MapSec', 1)
Dim $ShowTrack = IniRead($settings, 'Vistumbler', 'ShowTrack', 1)
Dim $Debug = IniRead($settings, 'Vistumbler', 'Debug', 1)
Dim $PhilsGraphURL = IniRead($settings, 'Vistumbler', 'PhilsGraphURL', 'http://www.randomintervals.com/wifi/?')
Dim $PhilsWdbURL = IniRead($settings, 'Vistumbler', 'PhilsWdbURL', 'http://www.randomintervals.com/wifidb/import/?')
Dim $GPSformat = IniRead($settings, 'Vistumbler', 'GPSformat', 1)
Dim $ConnectToButton = IniRead($settings, 'Vistumbler', 'ConnectToButton', "Button4")
Dim $UseLocalKmlImagesOnExport = IniRead($settings, 'Vistumbler', 'UseLocalKmlImagesOnExport', 0)
Dim $AutoKML = IniRead($settings, 'Vistumbler', 'AutoKML', 0)
Dim $GraphDeadTime = IniRead($settings, 'Vistumbler', 'GraphDeadTime', 0)
Dim $SpeakSignal = IniRead($settings, 'Vistumbler', 'SpeakSignal', 0)
Dim $SpeakSigSayPecent = IniRead($settings, 'Vistumbler', 'SpeakSigSayPecent', 1)
Dim $SpeakSigTime = IniRead($settings, 'Vistumbler', 'SpeakSigTime', 2000)
Dim $SpeakType = IniRead($settings, 'Vistumbler', 'SpeakType', 2)
Dim $SaveGpsWithNoAps = IniRead($settings, 'Vistumbler', 'SaveGpsWithNoAps', 0)

Dim $CompassPosition = IniRead($settings, 'WindowPositions', 'CompassPosition', '')
Dim $GpsDetailsPosition = IniRead($settings, 'WindowPositions', 'GpsDetailsPosition', '')

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

Dim $column_Line = IniRead($settings, 'Columns', 'Column_Line', 0)
Dim $column_Active = IniRead($settings, 'Columns', 'Column_Active', 1)
Dim $column_SSID = IniRead($settings, 'Columns', 'Column_SSID', 2)
Dim $column_BSSID = IniRead($settings, 'Columns', 'Column_BSSID', 3)
Dim $column_MANUF = IniRead($settings, 'Columns', 'Column_Manufacturer', 4)
Dim $column_Signal = IniRead($settings, 'Columns', 'Column_Signal', 5)
Dim $column_Authentication = IniRead($settings, 'Columns', 'Column_Authentication', 6)
Dim $column_Encryption = IniRead($settings, 'Columns', 'Column_Encryption', 7)
Dim $column_RadioType = IniRead($settings, 'Columns', 'Column_RadioType', 8)
Dim $column_Channel = IniRead($settings, 'Columns', 'Column_Channel', 9)
Dim $column_Latitude = IniRead($settings, 'Columns', 'Column_Latitude', 10)
Dim $column_Longitude = IniRead($settings, 'Columns', 'Column_Longitude', 11)
Dim $column_LatitudeDMS = IniRead($settings, 'Columns', 'Column_LatitudeDMS', 12)
Dim $column_LongitudeDMS = IniRead($settings, 'Columns', 'Column_LongitudeDMS', 13)
Dim $column_LatitudeDMM = IniRead($settings, 'Columns', 'Column_LatitudeDMM', 14)
Dim $column_LongitudeDMM = IniRead($settings, 'Columns', 'Column_LongitudeDMM', 15)
Dim $column_BasicTransferRates = IniRead($settings, 'Columns', 'Column_BasicTransferRates', 16)
Dim $column_OtherTransferRates = IniRead($settings, 'Columns', 'Column_OtherTransferRates', 17)
Dim $column_FirstActive = IniRead($settings, 'Columns', 'Column_FirstActive', 18)
Dim $column_LastActive = IniRead($settings, 'Columns', 'Column_LastActive', 19)
Dim $column_NetworkType = IniRead($settings, 'Columns', 'Column_NetworkType', 20)
Dim $column_Label = IniRead($settings, 'Columns', 'Column_Label', 21)

Dim $column_Width_Line = IniRead($settings, 'Column_Width', 'Column_Line', 50)
Dim $column_Width_Active = IniRead($settings, 'Column_Width', 'Column_Active', 50)
Dim $column_Width_SSID = IniRead($settings, 'Column_Width', 'Column_SSID', 50)
Dim $column_Width_BSSID = IniRead($settings, 'Column_Width', 'Column_BSSID', 50)
Dim $column_Width_MANUF = IniRead($settings, 'Column_Width', 'Column_Manufacturer', 50)
Dim $column_Width_Signal = IniRead($settings, 'Column_Width', 'Column_Signal', 50)
Dim $column_Width_Authentication = IniRead($settings, 'Column_Width', 'Column_Authentication', 50)
Dim $column_Width_Encryption = IniRead($settings, 'Column_Width', 'Column_Encryption', 50)
Dim $column_Width_RadioType = IniRead($settings, 'Column_Width', 'Column_RadioType', 50)
Dim $column_Width_Channel = IniRead($settings, 'Column_Width', 'Column_Channel', 50)
Dim $column_Width_Latitude = IniRead($settings, 'Column_Width', 'Column_Latitude', 50)
Dim $column_Width_Longitude = IniRead($settings, 'Column_Width', 'Column_Longitude', 50)
Dim $column_Width_LatitudeDMS = IniRead($settings, 'Column_Width', 'Column_LatitudeDMS', 50)
Dim $column_Width_LongitudeDMS = IniRead($settings, 'Column_Width', 'Column_LongitudeDMS', 50)
Dim $column_Width_LatitudeDMM = IniRead($settings, 'Column_Width', 'Column_LatitudeDMM', 50)
Dim $column_Width_LongitudeDMM = IniRead($settings, 'Column_Width', 'Column_LongitudeDMM', 50)
Dim $column_Width_BasicTransferRates = IniRead($settings, 'Column_Width', 'Column_BasicTransferRates', 50)
Dim $column_Width_OtherTransferRates = IniRead($settings, 'Column_Width', 'Column_OtherTransferRates', 50)
Dim $column_Width_FirstActive = IniRead($settings, 'Column_Width', 'Column_FirstActive', 50)
Dim $column_Width_LastActive = IniRead($settings, 'Column_Width', 'Column_LastActive', 50)
Dim $column_Width_NetworkType = IniRead($settings, 'Column_Width', 'Column_NetworkType', 50)
Dim $column_Width_Label = IniRead($settings, 'Column_Width', 'Column_Label', 50)

Dim $Column_Names_Line = IniRead($settings, 'Column_Names', 'Column_Line', '#')
Dim $Column_Names_Active = IniRead($settings, 'Column_Names', 'Column_Active', 'Active')
Dim $Column_Names_SSID = IniRead($settings, 'Column_Names', 'Column_SSID', 'SSID')
Dim $Column_Names_BSSID = IniRead($settings, 'Column_Names', 'Column_BSSID', 'Mac Address')
Dim $Column_Names_MANUF = IniRead($settings, 'Column_Names', 'Column_Manufacturer', 'Manufacturer')
Dim $Column_Names_Signal = IniRead($settings, 'Column_Names', 'Column_Signal', 'Signal')
Dim $Column_Names_Authentication = IniRead($settings, 'Column_Names', 'Column_Authentication', 'Authentication')
Dim $Column_Names_Encryption = IniRead($settings, 'Column_Names', 'Column_Encryption', 'Encryption')
Dim $Column_Names_RadioType = IniRead($settings, 'Column_Names', 'Column_RadioType', 'Radio Type')
Dim $Column_Names_Channel = IniRead($settings, 'Column_Names', 'Column_Channel', 'Channel')
Dim $Column_Names_Latitude = IniRead($settings, 'Column_Names', 'Column_Latitude', 'Latitude')
Dim $Column_Names_Longitude = IniRead($settings, 'Column_Names', 'Column_Longitude', 'Longitude')
Dim $Column_Names_LatitudeDMS = IniRead($settings, 'Column_Names', 'Column_LatitudeDMS', 'Latitude (DDMMSS)')
Dim $Column_Names_LongitudeDMS = IniRead($settings, 'Column_Names', 'Column_LongitudeDMS', 'Longitude (DDMMSS)')
Dim $Column_Names_LatitudeDMM = IniRead($settings, 'Column_Names', 'Column_LatitudeDMM', 'Latitude (DDMMMM)')
Dim $Column_Names_LongitudeDMM = IniRead($settings, 'Column_Names', 'Column_LongitudeDMM', 'Longitude (DDMMMM)')
Dim $Column_Names_BasicTransferRates = IniRead($settings, 'Column_Names', 'Column_BasicTransferRates', 'Basic Transfer Rates')
Dim $Column_Names_OtherTransferRates = IniRead($settings, 'Column_Names', 'Column_OtherTransferRates', 'Other Transfer Rates')
Dim $Column_Names_FirstActive = IniRead($settings, 'Column_Names', 'Column_FirstActive', 'First Active')
Dim $Column_Names_LastActive = IniRead($settings, 'Column_Names', 'Column_LastActive', 'Last Active')
Dim $Column_Names_NetworkType = IniRead($settings, 'Column_Names', 'Column_NetworkType', 'Network Type')
Dim $Column_Names_Label = IniRead($settings, 'Column_Names', 'Column_Label', 'Label')

Dim $SearchWord_SSID = IniRead($settings, 'SearchWords', 'SSID', 'SSID')
Dim $SearchWord_BSSID = IniRead($settings, 'SearchWords', 'BSSID', 'BSSID')
Dim $SearchWord_NetworkType = IniRead($settings, 'SearchWords', 'NetworkType', 'Network type')
Dim $SearchWord_Authentication = IniRead($settings, 'SearchWords', 'Authentication', 'Authentication')
Dim $SearchWord_Encryption = IniRead($settings, 'SearchWords', 'Encryption', 'Encryption')
Dim $SearchWord_Signal = IniRead($settings, 'SearchWords', 'Signal', 'Signal')
Dim $SearchWord_RadioType = IniRead($settings, 'SearchWords', 'RadioType', 'Radio Type')
Dim $SearchWord_Channel = IniRead($settings, 'SearchWords', 'Channel', 'Channel')
Dim $SearchWord_BasicRates = IniRead($settings, 'SearchWords', 'BasicRates', 'Basic Rates')
Dim $SearchWord_OtherRates = IniRead($settings, 'SearchWords', 'OtherRates', 'Other Rates')
Dim $SearchWord_None = IniRead($settings, 'SearchWords', 'None', 'None')
Dim $SearchWord_Open = IniRead($settings, 'SearchWords', 'Open', 'Open')
Dim $SearchWord_Wep = IniRead($settings, 'SearchWords', 'WEP', 'WEP')
Dim $SearchWord_Infrastructure = IniRead($settings, 'SearchWords', 'Infrastructure', 'Infrastructure')
Dim $SearchWord_Adhoc = IniRead($settings, 'SearchWords', 'Adhoc', 'Adhoc')

Dim $Text_Ok = IniRead($settings, 'GuiText', 'Ok', '&Ok')
Dim $Text_Cancel = IniRead($settings, 'GuiText', 'Cancel', 'C&ancel')
Dim $Text_Apply = IniRead($settings, 'GuiText', 'Apply', '&Apply')
Dim $Text_Browse = IniRead($settings, 'GuiText', 'Browse', '&Browse')

Dim $Text_File = IniRead($settings, 'GuiText', 'File', '&File')
Dim $Text_SaveAsTXT = IniRead($settings, 'GuiText', 'SaveAsTXT', 'Save As TXT')
Dim $Text_SaveAsVS1 = IniRead($settings, 'GuiText', 'SaveAsVS1', 'Save As VS1')
Dim $Text_SaveAsVSZ = IniRead($settings, 'GuiText', 'SaveAsVSZ', 'Save As VSZ')
Dim $Text_ImportFromTXT = IniRead($settings, 'GuiText', 'ImportFromTXT', 'Import From TXT / VS1')
Dim $Text_ImportFromVSZ = IniRead($settings, 'GuiText', 'ImportFromVSZ', 'Import From VSZ')
Dim $Text_Exit = IniRead($settings, 'GuiText', 'Exit', 'E&xit')

Dim $Text_Edit = IniRead($settings, 'GuiText', 'Edit', 'E&dit')
Dim $Text_ClearAll = IniRead($settings, 'GuiText', 'ClearAll', 'Clear All')
Dim $Text_Cut = IniRead($settings, 'GuiText', 'Cut', 'Cut')
Dim $Text_Copy = IniRead($settings, 'GuiText', 'Copy', 'Copy')
Dim $Text_Paste = IniRead($settings, 'GuiText', 'Paste', 'Paste')
Dim $Text_Delete = IniRead($settings, 'GuiText', 'Delete', 'Delete')
Dim $Text_Select = IniRead($settings, 'GuiText', 'Select', 'Select')
Dim $Text_SelectAll = IniRead($settings, 'GuiText', 'SelectAll', 'Select All')

Dim $Text_Options = IniRead($settings, 'GuiText', 'Options', '&Options')
Dim $Text_AutoSort = IniRead($settings, 'GuiText', 'AutoSort', 'AutoSort')
Dim $Text_SortTree = IniRead($settings, 'GuiText', 'SortTree', 'Sort Tree  - (slow on big lists)')
Dim $Text_PlaySound = IniRead($settings, 'GuiText', 'PlaySound', 'Play sound on new AP')
Dim $Text_AddAPsToTop = IniRead($settings, 'GuiText', 'AddAPsToTop', 'Add new APs to top')

Dim $Text_Extra = IniRead($settings, 'GuiText', 'Extra', 'Ex&tra')
Dim $Text_ScanAPs = IniRead($settings, 'GuiText', 'ScanAPs', '&Scan APs')
Dim $Text_StopScanAps = IniRead($settings, 'GuiText', 'StopScanAps', '&Stop')
Dim $Text_UseGPS = IniRead($settings, 'GuiText', 'UseGPS', 'Use &GPS')
Dim $Text_StopGPS = IniRead($settings, 'GuiText', 'StopGPS', 'Stop &GPS')

Dim $Text_Settings = IniRead($settings, 'GuiText', 'Settings', 'S&ettings')
Dim $Text_GpsSettings = IniRead($settings, 'GuiText', 'GpsSettings', 'G&PS Settings')
Dim $Text_SetLanguage = IniRead($settings, 'GuiText', 'SetLanguage', 'Set &Language')
Dim $Text_SetSearchWords = IniRead($settings, 'GuiText', 'SetSearchWords', 'Set Search &Words')
Dim $Text_SetMacLabel = IniRead($settings, 'GuiText', 'SetMacLabel', 'Set Labels by Mac')
Dim $Text_SetMacManu = IniRead($settings, 'GuiText', 'SetMacManu', 'Set Manufactures by Mac')

Dim $Text_Export = IniRead($settings, 'GuiText', 'Export', 'Ex&port')
Dim $Text_ExportToKML = IniRead($settings, 'GuiText', 'ExportToKML', 'Export To KML')
Dim $Text_ExportToTXT = IniRead($settings, 'GuiText', 'ExportToTXT', 'Export To TXT')
Dim $Text_ExportToNS1 = IniRead($settings, 'GuiText', 'ExportToNS1', 'Export To NS1')
Dim $Text_ExportToVS1 = IniRead($settings, 'GuiText', 'ExportToVS1', 'Export To VS1')
Dim $Text_PhilsPHPgraph = IniRead($settings, 'GuiText', 'PhilsPHPgraph', 'View graph (Phils PHP)')
Dim $Text_PhilsWDB = IniRead($settings, 'GuiText', 'PhilsWDB', 'Phils WiFiDB (Alpha)')

Dim $Text_RefreshLoopTime = IniRead($settings, 'GuiText', 'RefreshLoopTime', 'Refresh loop time(ms):')
Dim $Text_ActualLoopTime = IniRead($settings, 'GuiText', 'ActualLoopTime', 'Loop time')
Dim $Text_Longitude = IniRead($settings, 'GuiText', 'Longitude', 'Longitude')
Dim $Text_Latitude = IniRead($settings, 'GuiText', 'Latitude', 'Latitude')
Dim $Text_ActiveAPs = IniRead($settings, 'GuiText', 'ActiveAPs', 'Active APs')
Dim $Text_Graph1 = IniRead($settings, 'GuiText', 'Graph1', 'Graph1')
Dim $Text_Graph2 = IniRead($settings, 'GuiText', 'Graph2', 'Graph2')
Dim $Text_NoGraph = IniRead($settings, 'GuiText', 'NoGraph', 'No Graph')
Dim $Text_Active = IniRead($settings, 'GuiText', 'Active', 'Active')
Dim $Text_Dead = IniRead($settings, 'GuiText', 'Dead', 'Dead')

Dim $Text_AddNewLabel = IniRead($settings, 'GuiText', 'AddNewLabel', 'Add New Label')
Dim $Text_RemoveLabel = IniRead($settings, 'GuiText', 'RemoveLabel', 'Remove Selected Label')
Dim $Text_EditLabel = IniRead($settings, 'GuiText', 'EditLabel', 'Edit Selected Label')
Dim $Text_AddNewMan = IniRead($settings, 'GuiText', 'AddNewMan', 'Add New Manufacturer')
Dim $Text_RemoveMan = IniRead($settings, 'GuiText', 'RemoveMan', 'Remove Selected Manufacturer')
Dim $Text_EditMan = IniRead($settings, 'GuiText', 'EditMan', 'Edit Selected Manufacturer')
Dim $Text_NewMac = IniRead($settings, 'GuiText', 'NewMac', 'New Mac Address:')
Dim $Text_NewMan = IniRead($settings, 'GuiText', 'NewMan', 'New Manufacturer:')
Dim $Text_NewLabel = IniRead($settings, 'GuiText', 'NewLabel', 'New Label:')
Dim $Text_Save = IniRead($settings, 'GuiText', 'Save', 'Save?')
Dim $Text_SaveQuestion = IniRead($settings, 'GuiText', 'SaveQuestion', 'Data has changed. Would you like to save?')

Dim $Text_GpsDetails = IniRead($settings, 'GuiText', 'GpsDetails', 'GPS Details')
Dim $Text_GpsCompass = IniRead($settings, 'GuiText', 'GpsCompass', 'GPS Compass')
Dim $Text_Quality = IniRead($settings, 'GuiText', 'Quality', 'Quality')
Dim $Text_Time = IniRead($settings, 'GuiText', 'Time', 'Time')
Dim $Text_NumberOfSatalites = IniRead($settings, 'GuiText', 'NumberOfSatalites', 'Number of Satalites')
Dim $Text_HorizontalDilutionPosition = IniRead($settings, 'GuiText', 'HorizontalDilutionPosition', 'Horizontal Dilution')
Dim $Text_Altitude = IniRead($settings, 'GuiText', 'Altitude', 'Altitude')
Dim $Text_HeightOfGeoid = IniRead($settings, 'GuiText', 'HeightOfGeoid', 'Height of Geoid')
Dim $Text_Status = IniRead($settings, 'GuiText', 'Status', 'Status')
Dim $Text_Date = IniRead($settings, 'GuiText', 'Date', 'Date')
Dim $Text_SpeedInKnots = IniRead($settings, 'GuiText', 'SpeedInKnots', 'Speed(knots)')
Dim $Text_SpeedInMPH = IniRead($settings, 'GuiText', 'SpeedInMPH', 'Speed(MPH)')
Dim $Text_SpeedInKmh = IniRead($settings, 'GuiText', 'SpeedInKmh', 'Speed(km/h)')
Dim $Text_TrackAngle = IniRead($settings, 'GuiText', 'TrackAngle', 'Track Angle')
Dim $Text_Close = IniRead($settings, 'GuiText', 'Close', 'Close')
Dim $Text_ConnectToWindowName = IniRead($settings, 'GuiText', 'ConnectToWindowName', 'Connect to a network')
Dim $Text_RefreshNetworks = IniRead($settings, 'GuiText', 'RefreshingNetworks', 'Refreshing Networks')
Dim $Text_Start = IniRead($settings, 'GuiText', 'Start', 'Start')
Dim $Text_Stop = IniRead($settings, 'GuiText', 'Stop', 'Stop')
Dim $Text_ConnectToWindowTitle = IniRead($settings, 'GuiText', 'ConnectToWindowTitle', '"Connect to" window title:')
Dim $Text_RefreshTime = IniRead($settings, 'GuiText', 'RefreshTime', 'Refresh time (in ms)')
Dim $Text_SetColumnWidths = IniRead($settings, 'GuiText', 'SetColumnWidths', 'Set Column Widths')
Dim $Text_Enable = IniRead($settings, 'GuiText', 'Enable', 'Enable')
Dim $Text_Disable = IniRead($settings, 'GuiText', 'Disable', 'Disable')
Dim $Text_Checked = IniRead($settings, 'GuiText', 'Checked', 'Checked')
Dim $Text_UnChecked = IniRead($settings, 'GuiText', 'UnChecked', 'UnChecked')
Dim $Text_Unknown = IniRead($settings, 'GuiText', 'Unknown', 'Unknown')
Dim $Text_Restart = IniRead($settings, 'GuiText', 'Restart', 'Restart')
Dim $Text_RestartMsg = IniRead($settings, 'GuiText', 'RestartMsg', 'Please restart Vistumbler for language change to take effect')
Dim $Text_Error = IniRead($settings, 'GuiText', 'Error', 'Error')
Dim $Text_NoSignalHistory = IniRead($settings, 'GuiText', 'NoSignalHistory', 'No signal history found, check to make sure your netsh search words are correct')
Dim $Text_NoApSelected = IniRead($settings, 'GuiText', 'NoApSelected', 'You did not select an access point')
Dim $Text_UseNetcomm = IniRead($settings, 'GuiText', 'UseNetcomm', 'Use Netcomm OCX (more stable) - x32')
Dim $Text_UseCommMG = IniRead($settings, 'GuiText', 'UseCommMG', 'Use CommMG (less stable) - x32 - x64')
Dim $Text_SignalHistory = IniRead($settings, 'GuiText', 'SignalHistory', 'Signal History')
Dim $Text_AutoSortEvery = IniRead($settings, 'GuiText', 'AutoSortEvery', 'Auto Sort Every')
Dim $Text_Seconds = IniRead($settings, 'GuiText', 'Seconds', 'Seconds')
Dim $Text_Ascending = IniRead($settings, 'GuiText', 'Ascending', 'Ascending')
Dim $Text_Decending = IniRead($settings, 'GuiText', 'Decending', 'Decending')
Dim $Text_AutoSave = IniRead($settings, 'GuiText', 'AutoSave', 'Auto Save')
Dim $Text_AutoSaveEvery = IniRead($settings, 'GuiText', 'AutoSaveEvery', 'Auto Save Every')
Dim $Text_DelAutoSaveOnExit = IniRead($settings, 'GuiText', 'DelAutoSaveOnExit', 'Delete Auto Save file on exit')
Dim $Text_OpenSaveFolder = IniRead($settings, 'GuiText', 'OpenSaveFolder', 'Open Save Folder')
Dim $Text_SortBy = IniRead($settings, 'GuiText', 'SortBy', 'Sort By')
Dim $Text_SortDirection = IniRead($settings, 'GuiText', 'SortDirection', 'Sort Direction')
Dim $Text_Auto = IniRead($settings, 'GuiText', 'Auto', 'Auto')
Dim $Text_Misc = IniRead($settings, 'GuiText', 'Misc', 'Misc')
Dim $Text_Gps = IniRead($settings, 'GuiText', 'GPS', 'GPS')
Dim $Text_Labels = IniRead($settings, 'GuiText', 'Labels', 'Labels')
Dim $Text_Manufacturers = IniRead($settings, 'GuiText', 'Manufacturers', 'Manufacturers')
Dim $Text_Columns = IniRead($settings, 'GuiText', 'Columns', 'Columns')
Dim $Text_Language = IniRead($settings, 'GuiText', 'Language', 'Language')
Dim $Text_SearchWords = IniRead($settings, 'GuiText', 'SearchWords', 'SearchWords')
Dim $Text_VistumblerSettings = IniRead($settings, 'GuiText', 'VistumblerSettings', 'Vistumbler Settings')
Dim $Text_LanguageAuthor = IniRead($settings, 'GuiText', 'LanguageAuthor', 'Language Author')
Dim $Text_LanguageDate = IniRead($settings, 'GuiText', 'LanguageDate', 'Language Date')
Dim $Text_LanguageDescription = IniRead($settings, 'GuiText', 'LanguageDescription', 'Language Description')
Dim $Text_Description = IniRead($settings, 'GuiText', 'Description', 'Description')
Dim $Text_Progress = IniRead($settings, 'GuiText', 'Progress', 'Progress')
Dim $Text_LinesMin = IniRead($settings, 'GuiText', 'LinesMin', 'Lines/Min')
Dim $Text_NewAPs = IniRead($settings, 'GuiText', 'NewAPs', 'New APs')
Dim $Text_NewGIDs = IniRead($settings, 'GuiText', 'NewGIDs', 'New GIDs')
Dim $Text_Minutes = IniRead($settings, 'GuiText', 'Minutes', 'Minutes')
Dim $Text_LineTotal = IniRead($settings, 'GuiText', 'LineTotal', 'Line/Total')
Dim $Text_EstimatedTimeRemaining = IniRead($settings, 'GuiText', 'EstimatedTimeRemaining', 'Estimated Time Remaining')
Dim $Text_Ready = IniRead($settings, 'GuiText', 'Ready', 'Ready')
Dim $Text_Done = IniRead($settings, 'GuiText', 'Done', 'Done')
Dim $Text_VistumblerSaveDirectory = IniRead($settings, 'GuiText', 'VistumblerSaveDirectory', 'Vistumbler Save Directory')
Dim $Text_VistumblerAutoSaveDirectory = IniRead($settings, 'GuiText', 'VistumblerAutoSaveDirectory', 'Vistumbler Auto Save Directory')
Dim $Text_VistumblerKmlSaveDirectory = IniRead($settings, 'GuiText', 'VistumblerKmlSaveDirectory', 'Vistumbler KML Save Directory')
Dim $Text_BackgroundColor = IniRead($settings, 'GuiText', 'BackgroundColor', 'Background Color')
Dim $Text_ControlColor = IniRead($settings, 'GuiText', 'ControlColor', 'Control Color')
Dim $Text_BgFontColor = IniRead($settings, 'GuiText', 'BgFontColor', 'Font Color')
Dim $Text_ConFontColor = IniRead($settings, 'GuiText', 'ConFontColor', 'Control Font Color')
Dim $Text_NetshMsg = IniRead($settings, 'GuiText', 'NetshMsg', 'This section allows you to change the words Vistumbler uses to search netsh. Change to the proper words for you version of windows. Run "netsh wlan show networks mode = bssid" to find the proper words.')
Dim $Text_PHPgraphing = IniRead($settings, 'GuiText', 'PHPgraphing', 'PHP Graphing')
Dim $Text_ComInterface = IniRead($settings, 'GuiText', 'ComInterface', 'Com Interface')
Dim $Text_ComSettings = IniRead($settings, 'GuiText', 'ComSettings', 'Com Settings')
Dim $Text_Com = IniRead($settings, 'GuiText', 'Com', 'Com')
Dim $Text_Baud = IniRead($settings, 'GuiText', 'Baud', 'Baud')
Dim $Text_GPSFormat = IniRead($settings, 'GuiText', 'GPSFormat', 'GPS Format')
Dim $Text_HideOtherGpsColumns = IniRead($settings, 'GuiText', 'HideOtherGpsColumns', 'Hide Other GPS Columns')
Dim $Text_ImportLanguageFile = IniRead($settings, 'GuiText', 'ImportLanguageFile', 'Import Language File')
Dim $Text_ExportSettings = IniRead($settings, 'GuiText', 'ExportSettings', 'Export Settings')
Dim $Text_ImportSettings = IniRead($settings, 'GuiText', 'ImportSettings', 'Import Settings')
Dim $Text_AutoKml = IniRead($settings, 'GuiText', 'AutoKml', 'Auto KML')
Dim $Text_GoogleEarthEXE = IniRead($settings, 'GuiText', 'GoogleEarthEXE', 'Google Earth EXE')
Dim $Text_AutoSaveKmlEvery = IniRead($settings, 'GuiText', 'AutoSaveKmlEvery', 'Auto Save KML Every')
Dim $Text_SavedAs = IniRead($settings, 'GuiText', 'SavedAs', 'Saved As')
Dim $Text_Overwrite = IniRead($settings, 'GuiText', 'Overwrite', 'Overwrite')
Dim $Text_InstallNetcommOCX = IniRead($settings, 'GuiText', 'InstallNetcommOCX', 'Install Netcomm OCX')
Dim $Text_NoFileSaved = IniRead($settings, 'GuiText', 'NoFileSaved', 'No file has been saved')
Dim $Text_NoApsWithGps = IniRead($settings, 'GuiText', 'NoApsWithGps', 'No Access Points found with GPS coordinates.')
Dim $Text_MacExistsOverwriteIt = IniRead($settings, 'GuiText', 'MacExistsOverwriteIt', 'A entry for this mac address already exists. would you like to overwrite it?')
Dim $Text_SavingLine = IniRead($settings, 'GuiText', 'SavingLine', 'Saving Line')
Dim $Text_DisplayDebug = IniRead($settings, 'GuiText', 'DisplayDebug', 'Debug - Display Functions')
Dim $Text_GraphDeadTime = IniRead($settings, 'GuiText', 'GraphDeadTime', 'Graph Dead Time')
Dim $Text_OpenKmlNetLink = IniRead($settings, 'GuiText', 'OpenKmlNetLink', 'Open KML NetworkLink')
Dim $Text_ActiveRefreshTime = IniRead($settings, 'GuiText', 'ActiveRefreshTime', 'Active Refresh Time')
Dim $Text_DeadRefreshTime = IniRead($settings, 'GuiText', 'DeadRefreshTime', 'Dead Refresh Time')
Dim $Text_GpsRefrshTime = IniRead($settings, 'GuiText', 'GpsRefrshTime', 'Gps Refrsh Time')
Dim $Text_FlyToSettings = IniRead($settings, 'GuiText', 'FlyToSettings', 'Fly To Settings')
Dim $Text_FlyToCurrentGps = IniRead($settings, 'GuiText', 'FlyToCurrentGps', 'Fly to current gps position')
Dim $Text_AltitudeMode = IniRead($settings, 'GuiText', 'AltitudeMode', 'Altitude Mode')
Dim $Text_Range = IniRead($settings, 'GuiText', 'Range', 'Range')
Dim $Text_Heading = IniRead($settings, 'GuiText', 'Heading', 'Heading')
Dim $Text_Tilt = IniRead($settings, 'GuiText', 'Tilt', 'Tilt')
Dim $Text_AutoOpenNetworkLink = IniRead($settings, 'GuiText', 'AutoOpenNetworkLink', 'Automatically Open KML Network Link')
Dim $Text_SpeakSignal = IniRead($settings, 'GuiText', 'SpeakSignal', 'Speak Signal')
Dim $Text_SpeakUseVisSounds = IniRead($settings, 'GuiText', 'SpeakUseVisSounds', 'Use Vistumbler Sound Files')
Dim $Text_SpeakUseSapi = IniRead($settings, 'GuiText', 'SpeakUseSapi', 'Use Microsoft Sound API')
Dim $Text_SpeakSayPercent = IniRead($settings, 'GuiText', 'SpeakSayPercent', 'Say "Percent" after signal')
Dim $Text_GpsTrackTime = IniRead($settings, 'GuiText', 'GpsTrackTime', 'Track Refresh Time')

_SetKmlHeaders()

;Create-Array-Of-Manufactures----------------------------
_ReadIniSectionToArrays($manufini, $manu_mac, $manu_manu, "MANUFACURERS")

;Create-Array-Of-Labels----------------------------
_ReadIniSectionToArrays($labelsini, $label_mac, $label_label, "LABELS")

;Set-Up-Column-Headers-Based-On-INI-File-----------------
$var = IniReadSection($settings, "Columns")
If @error Then
	$headers = '#|Active|SSID|Mac Address|Manufacturer|Signal|Authentication|Encryption|Radio Type|Channel|Latitude|Longitude|Latitude DMS|Longitude DMS|Latitude DMM|Longitude DMM|Basic Transfer Rates|Other Transfer Rates|First Active|Last Updated|Network Type|Label'
Else
	For $a = 0 To ($var[0][0] - 1)
		For $b = 1 To $var[0][0]
			If $a = $var[$b][1] Then $headers &= IniRead($settings, 'Column_Names', $var[$b][0], '') & '|'
		Next
	Next
EndIf

;-------------------------------------------------------------------------------------------------------------------------------
;                                                       GUI
;-------------------------------------------------------------------------------------------------------------------------------
$Vistumbler = GUICreate($title, 980, 692, -1, -1, BitOR($WS_OVERLAPPEDWINDOW, $WS_CLIPSIBLINGS))
GUISetBkColor($BackgroundColor)

$a = WinGetPos($Vistumbler);Get window current position
Dim $VistumblerState = IniRead($settings, 'WindowPositions', 'VistumblerState', "Window");Get last window position from the ini file
Dim $VistumblerPosition = IniRead($settings, 'WindowPositions', 'VistumblerPosition', $a[0] & ',' & $a[1] & ',' & $a[2] & ',' & $a[3])
$b = StringSplit($VistumblerPosition, ",")

If $VistumblerState = "Maximized" Then
	WinSetState($title, "", @SW_MAXIMIZE)
Else
	;Split ini posion string
	WinMove($title, "", $b[1], $b[2], $b[3], $b[4]);Resize window to ini value
EndIf

$file = GUICtrlCreateMenu($Text_File)
$SaveAsTXT = GUICtrlCreateMenuItem($Text_SaveAsTXT, $file)
$SaveAsDetailedTXT = GUICtrlCreateMenuItem($Text_SaveAsVS1, $file)
$ExportFromVSZ = GUICtrlCreateMenuItem($Text_SaveAsVSZ, $file)
$ImportFromTXT = GUICtrlCreateMenuItem($Text_ImportFromTXT, $file)
$ImportFromVSZ = GUICtrlCreateMenuItem($Text_ImportFromVSZ, $file)

$ExitVistumbler = GUICtrlCreateMenuItem($Text_Exit, $file)
$Edit = GUICtrlCreateMenu($Text_Edit)
$ClearAll = GUICtrlCreateMenuItem($Text_ClearAll, $Edit)
$SortTree = GUICtrlCreateMenuItem($Text_SortTree, $Edit)
;$Cut = GUICtrlCreateMenuitem("Cut", $Edit)
;$Copy = GUICtrlCreateMenuitem("Copy", $Edit)
;$Delete = GUICtrlCreateMenuItem("Delete", $Edit)
;$SelectAll = GUICtrlCreateMenuItem("Select All", $Edit)
$Options = GUICtrlCreateMenu($Text_Options)
$ScanWifiGUI = GUICtrlCreateMenuItem($Text_ScanAPs, $Options)
$AutoSaveGUI = GUICtrlCreateMenuItem($Text_AutoSave, $Options)
If $AutoSave = 1 Then GUICtrlSetState($AutoSaveGUI, $GUI_CHECKED)
$AutoSortGUI = GUICtrlCreateMenuItem($Text_AutoSort, $Options)
If $AutoSort = 1 Then GUICtrlSetState($AutoSortGUI, $GUI_CHECKED)
$AutoSaveKML = GUICtrlCreateMenuItem($Text_AutoKml, $Options)
If $AutoKML = 1 Then GUICtrlSetState(-1, $GUI_CHECKED)
$PlaySoundOnNewAP = GUICtrlCreateMenuItem($Text_PlaySound, $Options)
If $SoundOnAP = 1 Then GUICtrlSetState($PlaySoundOnNewAP, $GUI_CHECKED)
$SpeakApSignal = GUICtrlCreateMenuItem($Text_SpeakSignal, $Options)
If $SpeakSignal = 1 Then GUICtrlSetState($SpeakApSignal, $GUI_CHECKED)
$AddNewAPsToTop = GUICtrlCreateMenuItem($Text_AddAPsToTop, $Options)
If $AddDirection = 0 Then GUICtrlSetState(-1, $GUI_CHECKED)
$GraphDeadTimeGUI = GUICtrlCreateMenuItem($Text_GraphDeadTime, $Options)
If $GraphDeadTime = 1 Then GUICtrlSetState(-1, $GUI_CHECKED)
$MenuSaveGpsWithNoAps = GUICtrlCreateMenuItem("Save GPS data when no APs are active", $Options)
If $SaveGpsWithNoAps = 1 Then GUICtrlSetState(-1, $GUI_CHECKED)
$DebugFunc = GUICtrlCreateMenuItem($Text_DisplayDebug, $Options)
If $Debug = 1 Then GUICtrlSetState(-1, $GUI_CHECKED)

Dim $SaveGpsWithNoAps = IniRead($settings, 'Vistumbler', 'SaveGpsWithNoAps', 0)

$SettingsMenu = GUICtrlCreateMenu($Text_Settings)
$SetMisc = GUICtrlCreateMenuItem($Text_VistumblerSettings, $SettingsMenu)
$SetGPS = GUICtrlCreateMenuItem($Text_GpsSettings, $SettingsMenu)
$SetLanguage = GUICtrlCreateMenuItem($Text_SetLanguage, $SettingsMenu)
$SetSearchWords = GUICtrlCreateMenuItem($Text_SetSearchWords, $SettingsMenu)
$SetMacLabel = GUICtrlCreateMenuItem($Text_SetMacLabel, $SettingsMenu)
$SetMacManu = GUICtrlCreateMenuItem($Text_SetMacManu, $SettingsMenu)
$SetColumnWidths = GUICtrlCreateMenuItem($Text_SetColumnWidths, $SettingsMenu)
$SetAuto = GUICtrlCreateMenuItem($Text_AutoSave & ' / ' & $Text_AutoSort, $SettingsMenu)
$SetAutoKML = GUICtrlCreateMenuItem($Text_AutoKml & ' / ' & $Text_SpeakSignal, $SettingsMenu)

$Export = GUICtrlCreateMenu($Text_Export)
$ExportToTXT2 = GUICtrlCreateMenuItem($Text_ExportToTXT, $Export)
$ExportToVS1 = GUICtrlCreateMenuItem($Text_ExportToVS1, $Export)
$ExportToKML = GUICtrlCreateMenuItem($Text_ExportToKML, $Export)
$ExportToNS1 = GUICtrlCreateMenuItem($Text_ExportToNS1, $Export)

$Extra = GUICtrlCreateMenu($Text_Extra)
$RefreshMenuButton = GUICtrlCreateMenuItem($Text_Start & ' ' & $Text_RefreshNetworks, $Extra)
$OpenKmlNetworkLink = GUICtrlCreateMenuItem($Text_OpenKmlNetLink, $Extra)
$GpsDetails = GUICtrlCreateMenuItem($Text_GpsDetails, $Extra)
$GpsCompass = GUICtrlCreateMenuItem($Text_GpsCompass, $Extra)
$OpenSaveFolder = GUICtrlCreateMenuItem($Text_OpenSaveFolder, $Extra)
$ViewInPhilsPHP = GUICtrlCreateMenuItem($Text_PhilsPHPgraph, $Extra)
$ViewPhilsWDB = GUICtrlCreateMenuItem($Text_PhilsWDB, $Extra)

$GraphicGUI = GUICreate("", 895.72, 386.19, 10, 60, BitOR($WS_CHILD, $WS_TABSTOP), $WS_EX_CONTROLPARENT, $Vistumbler)
GUISetBkColor($ControlBackgroundColor)

$DataChild = GUICreate("", 895, 595, 0, 60, BitOR($WS_CHILD, $WS_TABSTOP), $WS_EX_CONTROLPARENT, $Vistumbler)
GUISetBkColor($BackgroundColor)
$ListviewAPs = GUICtrlCreateListView($headers, 260, 5, 725, 585, $LVS_REPORT + $LVS_SINGLESEL, $LVS_EX_HEADERDRAGDROP + $LVS_EX_GRIDLINES + $LVS_EX_FULLROWSELECT)
GUICtrlSetBkColor(-1, $ControlBackgroundColor)
$TreeviewAPs = GUICtrlCreateTreeView(5, 5, 150, 585)
GUICtrlSetBkColor(-1, $ControlBackgroundColor)
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
GUICtrlSetOnEvent($ExitVistumbler, '_CloseToggle')
GUICtrlSetOnEvent($SaveAsTXT, '_ExportData')
GUICtrlSetOnEvent($SaveAsDetailedTXT, '_ExportDetailedData')
GUICtrlSetOnEvent($ImportFromTXT, 'LoadList')
GUICtrlSetOnEvent($ImportFromVSZ, '_ImportVSZ')
GUICtrlSetOnEvent($ExportFromVSZ, '_ExportVSZ')
;Edit Menu
GUICtrlSetOnEvent($ClearAll, '_ClearAll')
;Optons Menu
GUICtrlSetOnEvent($AutoSaveGUI, '_AutoSaveToggle')
GUICtrlSetOnEvent($AutoSortGUI, '_AutoSortToggle')
GUICtrlSetOnEvent($ScanWifiGUI, 'ScanToggle')
GUICtrlSetOnEvent($PlaySoundOnNewAP, '_SoundToggle')
GUICtrlSetOnEvent($SpeakApSignal, '_SpeakSigToggle')
GUICtrlSetOnEvent($AddNewAPsToTop, '_AddApPosToggle')
GUICtrlSetOnEvent($SortTree, '_SortTree')
GUICtrlSetOnEvent($AutoSaveKML, '_AutoKmlToggle')
GUICtrlSetOnEvent($GraphDeadTimeGUI, '_GraphDeadTimeToggle')
GUICtrlSetOnEvent($MenuSaveGpsWithNoAps, '_SaveGpsWithNoAPsToggle')
GUICtrlSetOnEvent($DebugFunc, '_DebugToggle')
;Export Menu
GUICtrlSetOnEvent($ExportToKML, 'SaveToKML')
GUICtrlSetOnEvent($ExportToTXT2, '_ExportData')
GUICtrlSetOnEvent($ExportToNS1, '_ExportNS1')
GUICtrlSetOnEvent($ExportToVS1, '_ExportDetailedData')
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
GUICtrlSetOnEvent($RefreshMenuButton, '_RefreshNetworksGUI')
GUICtrlSetOnEvent($GpsDetails, '_OpenGpsDetailsGUI')
GUICtrlSetOnEvent($GpsCompass, '_CompassGUI')
GUICtrlSetOnEvent($OpenSaveFolder, '_OpenSaveFolder')
GUICtrlSetOnEvent($OpenKmlNetworkLink, '_StartGoogleAutoKmlRefresh')
GUICtrlSetOnEvent($ViewInPhilsPHP, '_ViewInPhilsPHP')
GUICtrlSetOnEvent($ViewPhilsWDB, '_AddToYourWDB')

;Other
GUICtrlSetOnEvent($ListviewAPs, '_SortColumnToggle')


;Set column widths - All variables have ' - 0' after them to make this work. it would not set column widths without the ' - 0'
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

Dim $Authentication_tree = _GUICtrlTreeView_InsertItem($TreeviewAPs, $Column_Names_Authentication)
Dim $channel_tree = _GUICtrlTreeView_InsertItem($TreeviewAPs, $Column_Names_Channel)
Dim $Encryption_tree = _GUICtrlTreeView_InsertItem($TreeviewAPs, $Column_Names_Encryption)
Dim $NetworkType_tree = _GUICtrlTreeView_InsertItem($TreeviewAPs, $Column_Names_NetworkType)
Dim $SSID_tree = _GUICtrlTreeView_InsertItem($TreeviewAPs, $Column_Names_SSID)

If $Load <> '' Then AutoLoadList($Load)

;-------------------------------------------------------------------------------------------------------------------------------
;                                                       PROGRAM RUNNING LOOP
;-------------------------------------------------------------------------------------------------------------------------------

$UpdatedGPS = 0
$UpdatedAPs = 0
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
While 1
	If BitAND($UseGPS = 1, $UpdatedGPS <> 1) Or BitAND($Scan = 1, $UpdatedAPs <> 1) Then
		$ScanResults = 0
		;Set TimeStamps
		$timestamp = @HOUR & ':' & @MIN & ':' & @SEC
		$datestamp = @MON & '-' & @MDAY & '-' & @YEAR
		
		If $UseGPS = 1 And $UpdatedGPS <> 1 Then ; If 'Use GPS' is checked then scan gps and display information
			$GetGpsSuccess = _GetGPS();Scan for GPS if GPS enabled
			If $GetGpsSuccess = 1 Then
				GUICtrlSetData($GuiLat, $Text_Latitude & ': ' & _GpsFormat($Latitude));Set GPS Latitude in GUI
				GUICtrlSetData($GuiLon, $Text_Longitude & ': ' & _GpsFormat($Longitude));Set GPS Longitude in GUI
				$UpdatedGPS = 1
			Else
				If $UseNetcomm = 1 Then GUICtrlSetData($msgdisplay, 'GPS Error. Buffer Empty for more than 10 seconds. GPS was probrably disconnected. GPS has been stopped')
				If $UseNetcomm = 0 Then GUICtrlSetData($msgdisplay, 'GPS Error. GPS has been stopped')
				Sleep(1000)
			EndIf
		EndIf
		
		If $Scan = 1 And $UpdatedAPs <> 1 Then
			;Scan For New Aps
			$ScanResults = _ScanAccessPoints();Scan for Access Points if scanning enabled
			If $ScanResults = -1 Then
				GUICtrlSetData($msgdisplay, 'Error scanning netsh')
				Sleep(1000)
			Else
				$UpdatedAPs = 1 ;Set Update flag so APs do not get scanned again on this loop
			EndIf
			;Refresh Networks If Enabled
			If $RefreshNetworks = 1 Then _RefreshNetworks()
		EndIf
		
		If BitAND($Scan = 1, $ScanResults > 0) Or BitAND($UseGPS = 1, $SaveGpsWithNoAps = 1) Then ;Add GpsID if Scanning and AP was found or if Using GPS and Save GPS With No APs is on
			$GPS_ID = $GPSArray_ID[0] + 1
			_ArrayAdd($GPSArray_ID, $GPS_ID)
			_ArrayAdd($GPSArray_Lat, $Latitude)
			_ArrayAdd($GPSArray_Lon, $Longitude)
			_ArrayAdd($GPSArray_Sat, $NumberOfSatalites)
			_ArrayAdd($GPSArray_Date, $datestamp)
			_ArrayAdd($GPSArray_Time, $timestamp)
			$GPSArray_ID[0] = UBound($GPSArray_ID) - 1
		EndIf
	EndIf
	
	If $SpeakSignal = 1 And $Scan = 1 And $UpdatedSpeechSig = 0 And TimerDiff($Speech_Timer) >= $SpeakSigTime Then
		$SpeakSuccess = _SpeakSelectedSignal()
		If $SpeakSuccess = 1 Then
			$UpdatedSpeechSig = 1
			$Speech_Timer = TimerInit()
		EndIf
	EndIf
	
	If $AutoKML = 1 Then
		If TimerDiff($kml_gps_timer) >= ($AutoKmlGpsTime * 1000) And $AutoKmlGpsTime <> 0 Then _AutoKmlGpsFile($GoogleEarth_GpsFile)
		If TimerDiff($kml_dead_timer) >= ($AutoKmlDeadTime * 1000) And $AutoKmlDeadTime <> 0 Then _AutoSaveKMLDead($GoogleEarth_DeadFile)
		If TimerDiff($kml_active_timer) >= ($AutoKmlActiveTime * 1000) And $AutoKmlActiveTime <> 0 Then _AutoSaveKmlActive($GoogleEarth_ActiveFile)
		If TimerDiff($kml_track_timer) >= ($AutoKmlTrackTime * 1000) And $AutoKmlTrackTime <> 0 Then _AutoSaveKmlTrack($GoogleEarth_TrackFile)
	EndIf
	
	If $AutoSort = 1 And TimerDiff($sort_timer) >= ($SortTime * 1000) Then _Sort($SortBy)
	If $AutoSave = 1 And $UpdateAutoSave = 1 And TimerDiff($save_timer) >= ($SaveTime * 1000) Then
		_AutoSave()
		$UpdateAutoSave = 0
	EndIf
	
	If WinActive($CompassGUI) And $CompassOpen = 1 And $UpdatedCompassPos = 0 Then
		$c = WinGetPos($CompassGUI)
		If $c[0] & ',' & $c[1] & ',' & $c[2] & ',' & $c[3] <> $CompassPosition Then $CompassPosition = $c[0] & ',' & $c[1] & ',' & $c[2] & ',' & $c[3] ;If the $CompassGUI has moved or resized, set $CompassPosition to current window size
		$UpdatedCompassPos = 1
	EndIf
	If WinActive($GpsDetailsGUI) And $GpsDetailsOpen = 1 And $UpdatedGpsDetailsPos = 0 Then
		$g = WinGetPos($GpsDetailsGUI)
		If $g[0] & ',' & $g[1] & ',' & $g[2] & ',' & $g[3] <> $GpsDetailsPosition Then $GpsDetailsPosition = $g[0] & ',' & $g[1] & ',' & $g[2] & ',' & $g[3] ;If the $GpsDetails has moved or resized, set $GpsDetailsPosition to current window size
		$UpdatedGpsDetailsPos = 1
	EndIf

	_TreeviewListviewResize()
	If WinActive($Vistumbler) And _WinMoved() = 1 Then $Redraw = 1
	If WinActive($Vistumbler) And $ResetSizes = 1 Then
		_SetControlSizes()
		$ResetSizes = 0
		$Redraw = 1
	EndIf
	
	If $Close = 1 Then _ExitVistumbler() ;If the close flag has been set, exit visumbler
	If $SortColumn <> -1 Then _HeaderSort($SortColumn)
	If $ClearAllAps = 1 Then _ClearAllAp()
	
	If TimerDiff($ReleaseMemory_Timer) > 30000 Then
		_ReduceMemory()
		$ReleaseMemory_Timer = TimerInit()
	EndIf
	
	If TimerDiff($begin) >= $RefreshLoopTime Then
		$UpdatedGPS = 0
		$UpdatedAPs = 0
		$UpdatedAutoKML = 0
		$UpdatedCompassPos = 0
		$UpdatedGpsDetailsPos = 0
		$UpdatedSpeechSig = 0
		_GraphApSignal()
		_UpdateList();Update Listview with new data
		GUICtrlSetData($msgdisplay, '') ;Clear Message
		$time = TimerDiff($begin)
		GUICtrlSetData($timediff, $Text_ActualLoopTime & ': ' & StringFormat("%04i", $time) & ' ms'); Set 'Actual Loop Time' in GUI
		$begin = TimerInit() ;Start $begin timer, used to measure loop time
	Else
		Sleep(10)
	EndIf
WEnd
Exit

Func MyErrFunc()
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, 'MyErrFunc()') ;#Debug Display
	$ComError = 1
EndFunc   ;==>MyErrFunc

;-------------------------------------------------------------------------------------------------------------------------------
;                                                       WIFI SCAN FUNCTIONS
;-------------------------------------------------------------------------------------------------------------------------------

Func _ScanAccessPoints()
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, ' _ScanAccessPoints()') ;#Debug Display
	$NewAP = 0
	$FoundAPs = 0
	FileDelete($tempfile)
	_RunDOS($netsh & ' wlan show networks mode=bssid > ' & '"' & $tempfile & '"') ;copy the output of the 'netsh wlan show networks mode=bssid' command to the temp file
	$arrayadded = _FileReadToArray($tempfile, $TempFileArray);read the tempfile into the '$TempFileArray' Araay
	If $arrayadded = 1 Then
		For $stripws = 1 To $TempFileArray[0]
			$TempFileArray[$stripws] = StringStripWS($TempFileArray[$stripws], 3)
		Next
		
		For $loop = 1 To $TempFileArray[0]
			$temp = StringSplit(StringStripWS($TempFileArray[$loop], 3), ":")
			;_ArrayDisplay($temp)
			If IsArray($temp) Then
				If StringInStr($TempFileArray[$loop], $SearchWord_SSID) And StringInStr($TempFileArray[$loop], $SearchWord_BSSID) <> 1 Then
					$SSID = StringStripWS($temp[2], 3)
					Dim $NetworkType = '', $Authentication = '', $Encryption = '', $BSSID = ''
				EndIf
				If StringInStr($TempFileArray[$loop], $SearchWord_NetworkType) Then $NetworkType = StringStripWS($temp[2], 3)
				If StringInStr($TempFileArray[$loop], $SearchWord_Authentication) Then $Authentication = StringStripWS($temp[2], 3)
				If StringInStr($TempFileArray[$loop], $SearchWord_Encryption) Then $Encryption = StringStripWS($temp[2], 3)
				If StringInStr($TempFileArray[$loop], $SearchWord_BSSID) Then
					Dim $Signal = '', $RadioType = '', $Channel = '', $BasicTransferRates = '', $OtherTransferRates = '', $MANUF
					$NewAP = 1
					$BSSID = StringStripWS(StringUpper($temp[2] & ':' & $temp[3] & ':' & $temp[4] & ':' & $temp[5] & ':' & $temp[6] & ':' & $temp[7]), 3)
				EndIf
				If StringInStr($TempFileArray[$loop], $SearchWord_Signal) Then $Signal = StringStripWS($temp[2], 3)
				If StringInStr($TempFileArray[$loop], $SearchWord_RadioType) Then $RadioType = StringStripWS($temp[2], 3)
				If StringInStr($TempFileArray[$loop], $SearchWord_Channel) Then $Channel = StringStripWS($temp[2], 3)
				If StringInStr($TempFileArray[$loop], $SearchWord_BasicRates) Then $BasicTransferRates = StringStripWS($temp[2], 3)
				If StringInStr($TempFileArray[$loop], $SearchWord_OtherRates) Then $OtherTransferRates = StringStripWS($temp[2], 3)
				
				$Update = 0
				If $loop = $TempFileArray[0] Then
					$Update = 1
				Else
					If StringInStr($TempFileArray[$loop + 1], $SearchWord_SSID) Or StringInStr($TempFileArray[$loop + 1], $SearchWord_BSSID) Then $Update = 1
				EndIf
				
				If $Update = 1 And $NewAP = 1 And $BSSID <> '' Then
					$NewAP = 0
					If $BSSID <> "" Then
						$FoundAPs += 1
						_ArrayInsert($TmpArray_BSSID, 1, $BSSID)
						_ArrayInsert($TmpArray_SSID, 1, $SSID)
						_ArrayInsert($TmpArray_Auth, 1, $Authentication)
						_ArrayInsert($TmpArray_Encr, 1, $Encryption)
						_ArrayInsert($TmpArray_Sig, 1, $Signal)
						_ArrayInsert($TmpArray_Chan, 1, $Channel)
						_ArrayInsert($TmpArray_Rad, 1, $RadioType)
						_ArrayInsert($TmpArray_BtX, 1, $BasicTransferRates)
						_ArrayInsert($TmpArray_OtX, 1, $OtherTransferRates)
						_ArrayInsert($TmpArray_NetType, 1, $NetworkType)
						_SetTmpArraySizes()
					EndIf
				EndIf

			EndIf
		Next
		Return ($FoundAPs)
	Else
		Return ('-1')
	EndIf
EndFunc   ;==>_ScanAccessPoints

Func _UpdateList()
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_UpdateList()') ;#Debug Display
	$TmpArray_BSSID[0] = UBound($TmpArray_BSSID) - 1
	$Active = $TmpArray_BSSID[0]
	$NewApFound = 0
	
	$StartArraySize = $DataArray_BSSID[0]
	For $listval = 1 To $DataArray_BSSID[0];Scan though current Mac Adresses
		$listposition = $DataArray_BSSID[0] - ($listval - 1);Search the array backwards, since newest APs should be at the end
		$addposition = -1
		For $tmplistval = 1 To $TmpArray_BSSID[0];Scan Through New Mac Adrees
			$newdata = 1
			If $DataArray_BSSID[$listposition] = $TmpArray_BSSID[$tmplistval] Then; If New Mac Address is already found, check if this is the same access point
				If $DataArray_SSID[$listposition] = $TmpArray_SSID[$tmplistval] And _
						$DataArray_Auth[$listposition] = $TmpArray_Auth[$tmplistval] And _
						$DataArray_Encr[$listposition] = $TmpArray_Encr[$tmplistval] And _
						$DataArray_Chan[$listposition] = $TmpArray_Chan[$tmplistval] And _
						$DataArray_NetType[$listposition] = $TmpArray_NetType[$tmplistval] Then ; If Other information is the same, update data
					
					;Update Data in the GUI and Array
					$datetimestamp = $GPSArray_Date[$GPS_ID] & ' ' & $GPSArray_Time[$GPS_ID]
					_UpdateData($listposition, '', $Text_Active, '', '', '', '', $TmpArray_Sig[$tmplistval], '', '', '', $GPSArray_Lat[$GPS_ID], $GPSArray_Lon[$GPS_ID], '', '', '', '', $datetimestamp, '', $ResetManLabel, $ResetMacLabel, $GPSArray_ID[$GPS_ID])

					;Delete TmpArray row since this is not a new access point
					_ArrayDelete($TmpArray_BSSID, $tmplistval)
					_ArrayDelete($TmpArray_SSID, $tmplistval)
					_ArrayDelete($TmpArray_Auth, $tmplistval)
					_ArrayDelete($TmpArray_Encr, $tmplistval)
					_ArrayDelete($TmpArray_Sig, $tmplistval)
					_ArrayDelete($TmpArray_Chan, $tmplistval)
					_ArrayDelete($TmpArray_Rad, $tmplistval)
					_ArrayDelete($TmpArray_BtX, $tmplistval)
					_ArrayDelete($TmpArray_OtX, $tmplistval)
					_ArrayDelete($TmpArray_NetType, $tmplistval)
					
					$addposition = $DataArray_Row[$listposition]
					
					_SetTmpArraySizes()
					ExitLoop
				EndIf
			EndIf
		Next
		If $addposition = -1 Then; If this access point was not found Active (-1), mark it as dead
			_UpdateData($listposition, '', $Text_Dead, '', '', '', '', '0', '', '', '', '', '', '', '', '', '', '', '', $ResetManLabel, $ResetMacLabel, '')
		EndIf
	Next
	$ResetManLabel = 0
	$ResetMacLabel = 0
	; Add remaining New APs into list
	For $AddAP = 1 To $TmpArray_BSSID[0]
		;Add data into Listview, treeview, And Array
		$addposition = _GUICtrlListView_InsertItem($ListviewAPs, $AddDirection, '')
		$datetimestamp = $GPSArray_Date[$GPS_ID] & ' ' & $GPSArray_Time[$GPS_ID]
		_AddData($addposition, $Text_Active, $TmpArray_BSSID[$AddAP], $TmpArray_SSID[$AddAP], $TmpArray_Auth[$AddAP], $TmpArray_Encr[$AddAP], '', $TmpArray_Sig[$AddAP], '', $TmpArray_Chan[$AddAP], $TmpArray_Rad[$AddAP], $GPSArray_Lat[$GPS_ID], $GPSArray_Lon[$GPS_ID], $TmpArray_BtX[$AddAP], $TmpArray_OtX[$AddAP], $TmpArray_NetType[$AddAP], $datetimestamp, $datetimestamp, '', $GPSArray_ID[$GPS_ID])
		$NewApFound = 1
	Next

	If $SoundOnAP = 1 And $NewApFound = 1 Then SoundPlay($SoundDir & $new_AP_sound, 0)

	GUICtrlSetData($ActiveAPs, $Text_ActiveAPs & ': ' & $Active & " / " & $DataArray_BSSID[0])
	;Reset Tmp Arrays to nothing
	Dim $TmpArray_BSSID[1]
	Dim $TmpArray_SSID[1]
	Dim $TmpArray_Auth[1]
	Dim $TmpArray_Encr[1]
	Dim $TmpArray_Sig[1]
	Dim $TmpArray_Chan[1]
	Dim $TmpArray_Rad[1]
	Dim $TmpArray_BtX[1]
	Dim $TmpArray_OtX[1]
	Dim $TmpArray_NetType[1]
EndFunc   ;==>_UpdateList

;-------------------------------------------------------------------------------------------------------------------------------
;                                                       ADD ARRAY/LISTVIEW/TREEVIEW FUNCTIONS
;-------------------------------------------------------------------------------------------------------------------------------

Func _AddData($addpos, $Active, $BSSID, $SSID, $Auth, $Encr, $SecType, $Sig, $HighGpsSig, $Chan, $Rad, $lat, $lon, $BtX, $OtX, $NetType, $FirstTime, $LastTime, $SigHist, $GID)
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_AddData()') ;#Debug Display
	$line = $DataArray_BSSID[0] + 1
	
	$Sig = StringReplace($Sig, "%", '');Remove % sign from signal
	
	If $SigHist = '' Then $SigHist = $Sig
	$StripedBSSID = StringReplace($BSSID, ':', '')
	$MANUF = _FindManufacturer($StripedBSSID)
	$LABEL = _SetLabels($StripedBSSID)

	;Add Into Listview
	_ListViewAdd($addpos, $line, $Active, $BSSID, $SSID, $Auth, $Encr, $Sig, $Chan, $Rad, $BtX, $OtX, $NetType, $FirstTime, $LastTime, $lat, $lon, $MANUF, $LABEL)
	;Add data to the treeview
	$TreePosString = _TreeViewAdd($SSID, $BSSID, $Auth, $Encr, $Chan, $Rad, $BtX, $OtX, $NetType, $MANUF, $LABEL)
	;write treeview positions into array for future use
	$TreePos = StringSplit($TreePosString, '|')
	
	If $AddDirection = 0 Then ; If adding to the top, increase row of every other AP in the list by 1
		For $ResetRow = 1 To $DataArray_Row[0]
			$DataArray_Row[$ResetRow] += 1
		Next
	EndIf
	
	If $lat <> 'N 0.0000' And $lon <> 'E 0.0000' Then
		If $HighGpsSig = '' Then
			$GpsSig = $Sig
		Else
			$GpsSig = $HighGpsSig
		EndIf
	Else
		$GpsSig = '0'
	EndIf
	
	If $SecType = '' Then
		If $Auth = $SearchWord_Open And $Encr = $SearchWord_None Then
			$SecType = 1
		ElseIf $Encr = $SearchWord_Wep Then
			$SecType = 2
		Else
			$SecType = 3
		EndIf
	EndIf

	_ArrayInsert($DataArray_Row, 1, $addpos)
	_ArrayInsert($DataArray_Line, 1, $line)
	
	_ArrayInsert($DataArray_Active, 1, $Active)
	_ArrayInsert($DataArray_BSSID, 1, $BSSID)
	_ArrayInsert($DataArray_SSID, 1, $SSID)
	_ArrayInsert($DataArray_Auth, 1, $Auth)
	_ArrayInsert($DataArray_Encr, 1, $Encr)
	_ArrayInsert($DataArray_SecType, 1, $SecType)
	_ArrayInsert($DataArray_Sig, 1, $Sig)
	_ArrayInsert($DataArray_HighGpsSig, 1, $GpsSig)
	_ArrayInsert($DataArray_Chan, 1, $Chan)
	_ArrayInsert($DataArray_Rad, 1, $Rad)
	_ArrayInsert($DataArray_Lat, 1, $lat)
	_ArrayInsert($DataArray_Lon, 1, $lon)
	_ArrayInsert($DataArray_BtX, 1, $BtX)
	_ArrayInsert($DataArray_OtX, 1, $OtX)
	_ArrayInsert($DataArray_NetType, 1, $NetType)
	_ArrayInsert($DataArray_FirstTime, 1, $FirstTime)
	_ArrayInsert($DataArray_LastTime, 1, $LastTime)
	_ArrayInsert($DataArray_SigHist, 1, $SigHist)
	_ArrayInsert($DataArray_Manu, 1, $MANUF)
	_ArrayInsert($DataArray_Label, 1, $LABEL)
	_ArrayInsert($DataArray_GID, 1, $GID & ',' & $Sig)
	
	_ArrayInsert($DataArray_TreeViewSubChannel, 1, $TreePos[1])
	_ArrayInsert($DataArray_TreeViewSubSSID, 1, $TreePos[2])
	_ArrayInsert($DataArray_TreeViewSubEncr, 1, $TreePos[3])
	_ArrayInsert($DataArray_TreeViewSubAuth, 1, $TreePos[4])
	_ArrayInsert($DataArray_TreeViewSubNetType, 1, $TreePos[5])
	
	$UpdateAutoKml = 1
	$UpdateAutoSave = 1
	
	_SetDataArraySizes()
	Return ($DataArray_Row[0])
EndFunc   ;==>_AddData

Func _UpdateData($arraypos, $line, $Active, $BSSID, $SSID, $Auth, $Encr, $Sig, $HighGpsSig, $Chan, $Rad, $lat, $lon, $BtX, $OtX, $NetType, $FirstTime, $LastTime, $SigHist, $ResetMANUF = 0, $ResetLABEL = 0, $GID = '')
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_UpdateData()') ;#Debug Display
	If $ResetMANUF = 1 Or $ResetLABEL = 1 Then
		$StripedBSSID = StringReplace($DataArray_BSSID[$arraypos], ':', '');Strip ":"'s out of mac address
		If $ResetMANUF = 1 Then $MANUF = _FindManufacturer(StringTrimRight($StripedBSSID, 6));Set Manufacturer
		If $ResetLABEL = 1 Then $LABEL = _SetLabels($StripedBSSID);
	EndIf
	
	If $SigHist <> '' Then
		If $FirstTime = $DataArray_FirstTime[$arraypos] And $LastTime = $DataArray_LastTime[$arraypos] Then ;If New First/Last is the same as Old First/Last, Do Not Update
			$FirstTime = ''
			$LastTime = ''
			$SigHist = ''
		ElseIf StringInStr($SigHist, $DataArray_SigHist[$arraypos]) = 1 Or StringInStr($DataArray_SigHist[$arraypos], $SigHist) = 1 Then ;If New Signal History was found in Old Signal History ||Or|| Old Signal History was found in New Signal History, Do Not Update
			$FirstTime = ''
			$LastTime = ''
			$SigHist = ''
		ElseIf _CompareDate($DataArray_FirstTime[$arraypos], $LastTime) = 1 Then ;If new firsttime and lasttime are before the current one Then Add new signal data before
			$SigHist = $SigHist & "-" & $DataArray_SigHist[$arraypos]
		Else
			$SigHist = $DataArray_SigHist[$arraypos] & "-" & $SigHist
		EndIf
	Else
		$SigHist = ''
	EndIf
	
	If $Sig <> '' Then
		$Sig = StringReplace($Sig, "%", '');Remove % sign from signal
		If $Scan = 1 Or $Loading = 1 Or $DataArray_Sig[$arraypos] <> '0' Then ;If scanning, loading, or this is the first dead signal, add signal to signal history
			If $GraphDeadTime = '0' And $Sig = '0' And $DataArray_Sig[$arraypos] = '0' Then
				$SigHist = ''
			Else
				$SigHist = $DataArray_SigHist[$arraypos] & "-" & $Sig
			EndIf
		EndIf
	EndIf
	
	If $GID <> '' Then $GID = $DataArray_GID[$arraypos] & '-' & $GID & ',' & $Sig
	
	If $lat <> '' And $lon <> '' And $lat <> 'N 0.0000' And $lon <> 'E 0.0000' Then ;If lat and lon are not blank and have a valid position, update, otherwise, do not
		If $Sig <> '' And $HighGpsSig = '' And $Sig > $DataArray_HighGpsSig[$arraypos] Then $HighGpsSig = $Sig
		If $HighGpsSig <> '' Or $DataArray_Lat[$arraypos] = 'N 0.0000' Or $DataArray_Lon[$arraypos] = 'E 0.0000' Then ;If the signal is greater or there are not saved gps results, update
			If $HighGpsSig = '' And $Sig <> '' Then $HighGpsSig = $Sig
		Else ;If the signal is not greater or there are saved gps results, do not update
			$lat = ''
			$lon = ''
		EndIf
	Else;Do nothing (Reset lat,lon variables)
		$lat = ''
		$lon = ''
	EndIf

	;If data being added is the same os the old data, do not update it
	If $line <> '' And $line = $DataArray_Line[$arraypos] Then $line = ''
	If $Active <> '' And $Active = $DataArray_Active[$arraypos] Then $Active = ''
	If $BSSID <> '' And $BSSID = $DataArray_BSSID[$arraypos] Then $BSSID = ''
	If $SSID <> '' And $SSID = $DataArray_SSID[$arraypos] Then $SSID = ''
	If $Auth <> '' And $Auth = $DataArray_Auth[$arraypos] Then $Auth = ''
	If $Encr <> '' And $Encr = $DataArray_Encr[$arraypos] Then $Encr = ''
	If $Sig <> '' And $Sig = $DataArray_Sig[$arraypos] Then $Sig = ''
	If $HighGpsSig <> '' And $HighGpsSig = $DataArray_HighGpsSig[$arraypos] Then $HighGpsSig = ''
	If $Chan <> '' And $Chan = $DataArray_Chan[$arraypos] Then $Chan = ''
	If $Rad <> '' And $Rad = $DataArray_Rad[$arraypos] Then $Rad = ''
	If $lat <> '' And $lat = $DataArray_Lat[$arraypos] Then $lat = ''
	If $lon <> '' And $lon = $DataArray_Lon[$arraypos] Then $lon = ''
	If $BtX <> '' And $BtX = $DataArray_BtX[$arraypos] Then $BtX = ''
	If $OtX <> '' And $OtX = $DataArray_OtX[$arraypos] Then $OtX = ''
	If $NetType <> '' And $NetType = $DataArray_NetType[$arraypos] Then $NetType = ''
	If $FirstTime <> '' And $FirstTime = $DataArray_FirstTime[$arraypos] Then $FirstTime = ''
	If $LastTime <> '' And $LastTime = $DataArray_LastTime[$arraypos] Then $LastTime = ''
	If $SigHist <> '' And $SigHist = $DataArray_SigHist[$arraypos] Then $SigHist = ''
	If $ResetMANUF <> 1 Then $MANUF = ''
	If $ResetLABEL <> 1 Then $LABEL = ''
	If $GID <> '' And $GID = $DataArray_GID[$arraypos] Then $GID = ''
	
	$addpos = $DataArray_Row[$arraypos];Get line of item in listview
	
	_ListViewAdd($addpos, $line, $Active, $BSSID, $SSID, $Auth, $Encr, $Sig, $Chan, $Rad, $BtX, $OtX, $NetType, $FirstTime, $LastTime, $lat, $lon, $MANUF, $LABEL)
	
	If $Active <> '' Or $Sig <> '' Or $HighGpsSig <> '' Or $FirstTime <> '' Or $LastTime <> '' Or $lat <> '' Or $lon <> '' Then
		$UpdateAutoSave = 1
		$UpdateAutoKml = 1
	EndIf
	
	;ConsoleWrite($DataArray_BSSID[$arraypos] & '-' & $addpos & ',' & $line & ',' & $Active & ',' & $BSSID & ',' & $SSID & ',' & $Auth & ',' & $Encr & ',' & $Sig & ',' & $HighGpsSig & ',' & $Chan & ',' & $Rad & ',' & $BtX & ',' & $OtX & ',' & $NetType & ',' & $FirstTime & ',' & $LastTime & ',' & $lat & ',' & $lon & ',' & $MANUF & ',' & $LABEL & @CRLF)
	;ConsoleWrite($DataArray_BSSID[$arraypos] & ',' & $GID & @CRLF)
	
	;Updated data in array
	If $line <> '' Then $DataArray_Line[$arraypos] = $line
	If $Active <> '' Then $DataArray_Active[$arraypos] = $Active
	If $BSSID <> '' Then $DataArray_BSSID[$arraypos] = $BSSID
	If $SSID <> '' Then $DataArray_SSID[$arraypos] = $SSID
	If $Auth <> '' Then $DataArray_Auth[$arraypos] = $Auth
	If $Encr <> '' Then $DataArray_Encr[$arraypos] = $Encr
	If $Sig <> '' Then $DataArray_Sig[$arraypos] = $Sig
	If $HighGpsSig <> '' Then $DataArray_HighGpsSig[$arraypos] = $HighGpsSig
	If $Chan <> '' Then $DataArray_Chan[$arraypos] = $Chan
	If $Rad <> '' Then $DataArray_Rad[$arraypos] = $Rad
	If $lat <> '' Then $DataArray_Lat[$arraypos] = $lat
	If $lon <> '' Then $DataArray_Lon[$arraypos] = $lon
	If $BtX <> '' Then $DataArray_BtX[$arraypos] = $BtX
	If $OtX <> '' Then $DataArray_OtX[$arraypos] = $OtX
	If $NetType <> '' Then $DataArray_NetType[$arraypos] = $NetType
	If $FirstTime <> '' Then $DataArray_FirstTime[$arraypos] = $FirstTime
	If $LastTime <> '' Then $DataArray_LastTime[$arraypos] = $LastTime
	If $SigHist <> '' Then $DataArray_SigHist[$arraypos] = $SigHist
	If $MANUF <> '' Then $DataArray_Manu[$arraypos] = $MANUF
	If $LABEL <> '' Then $DataArray_Label[$arraypos] = $LABEL
	If $GID <> '' Then $DataArray_GID[$arraypos] = $GID
EndFunc   ;==>_UpdateData

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
	
	If $Add_Signal <> '' Then $Add_Signal = $Add_Signal & '%'

	If $Add_Line <> '' Then _GUICtrlListView_SetItemText($ListviewAPs, $line, $Add_Line, $column_Line)
	If $Add_Active <> '' Then _GUICtrlListView_SetItemText($ListviewAPs, $line, $Add_Active, $column_Active)
	If $Add_SSID <> '' Then _GUICtrlListView_SetItemText($ListviewAPs, $line, $Add_SSID, $column_SSID)
	If $Add_BSSID <> '' Then _GUICtrlListView_SetItemText($ListviewAPs, $line, $Add_BSSID, $column_BSSID)
	If $Add_MANU <> '' Then _GUICtrlListView_SetItemText($ListviewAPs, $line, $Add_MANU, $column_MANUF)
	If $Add_Signal <> '' Then _GUICtrlListView_SetItemText($ListviewAPs, $line, $Add_Signal, $column_Signal)
	If $Add_Authentication <> '' Then _GUICtrlListView_SetItemText($ListviewAPs, $line, $Add_Authentication, $column_Authentication)
	If $Add_Encryption <> '' Then _GUICtrlListView_SetItemText($ListviewAPs, $line, $Add_Encryption, $column_Encryption)
	If $Add_RadioType <> '' Then _GUICtrlListView_SetItemText($ListviewAPs, $line, $Add_RadioType, $column_RadioType)
	If $Add_Channel <> '' Then _GUICtrlListView_SetItemText($ListviewAPs, $line, $Add_Channel, $column_Channel)
	If $LatDDD <> '' Then _GUICtrlListView_SetItemText($ListviewAPs, $line, $LatDDD, $column_Latitude)
	If $LonDDD <> '' Then _GUICtrlListView_SetItemText($ListviewAPs, $line, $LonDDD, $column_Longitude)
	If $LatDMS <> '' Then _GUICtrlListView_SetItemText($ListviewAPs, $line, $LatDMS, $column_LatitudeDMS)
	If $LonDMS <> '' Then _GUICtrlListView_SetItemText($ListviewAPs, $line, $LonDMS, $column_LongitudeDMS)
	If $Add_LatitudeDMM <> '' Then _GUICtrlListView_SetItemText($ListviewAPs, $line, $Add_LatitudeDMM, $column_LatitudeDMM)
	If $Add_LongitudeDMM <> '' Then _GUICtrlListView_SetItemText($ListviewAPs, $line, $Add_LongitudeDMM, $column_LongitudeDMM)
	If $Add_BasicTransferRates <> '' Then _GUICtrlListView_SetItemText($ListviewAPs, $line, $Add_BasicTransferRates, $column_BasicTransferRates)
	If $Add_OtherTransferRates <> '' Then _GUICtrlListView_SetItemText($ListviewAPs, $line, $Add_OtherTransferRates, $column_OtherTransferRates)
	If $Add_FirstAcvtive <> '' Then _GUICtrlListView_SetItemText($ListviewAPs, $line, $Add_FirstAcvtive, $column_FirstActive)
	If $Add_LastActive <> '' Then _GUICtrlListView_SetItemText($ListviewAPs, $line, $Add_LastActive, $column_LastActive)
	If $Add_NetworkType <> '' Then _GUICtrlListView_SetItemText($ListviewAPs, $line, $Add_NetworkType, $column_NetworkType)
	If $Add_Label <> '' Then _GUICtrlListView_SetItemText($ListviewAPs, $line, $Add_Label, $column_Label)
EndFunc   ;==>_ListViewAdd

Func _TreeViewAdd($SSID, $BSSID, $Authentication, $Encryption, $Channel, $RadioType, $BasicTransferRates, $OtherTransferRates, $NetworkType, $MANUF, $LABEL)
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_TreeViewAdd()') ;#Debug Display
	$channel_treeviewname = StringFormat("%02i", $Channel)
	$SSID_treeviewname = '(' & $SSID & ')'
	$Encryption_treeviewname = $Encryption
	$Authentication_treeviewname = $Authentication
	$NetworkType_treeviewname = $NetworkType
	
	$channel_treeviewposition = -1
	For $t = 1 To $TreeView_Channel_Name[0]
		If $TreeView_Channel_Name[$t] = $channel_treeviewname Then
			$channel_treeviewposition = $TreeView_Channel_Pos[$t]
			ExitLoop
		EndIf
	Next
	$SSID_treeviewposition = -1
	For $t = 1 To $TreeView_SSID_Name[0]
		If $TreeView_SSID_Name[$t] = $SSID_treeviewname Then
			$SSID_treeviewposition = $TreeView_SSID_Pos[$t]
			ExitLoop
		EndIf
	Next
	$Encryption_treeviewposition = -1
	For $t = 1 To $TreeView_Encryption_Name[0]
		If $TreeView_Encryption_Name[$t] = $Encryption_treeviewname Then
			$Encryption_treeviewposition = $TreeView_Encryption_Pos[$t]
			ExitLoop
		EndIf
	Next
	$Authentication_treeviewposition = -1
	For $t = 1 To $TreeView_Authentication_Name[0]
		If $TreeView_Authentication_Name[$t] = $Authentication_treeviewname Then
			$Authentication_treeviewposition = $TreeView_Authentication_Pos[$t]
			ExitLoop
		EndIf
	Next
	$NetworkType_treeviewposition = -1
	For $t = 1 To $TreeView_NetworkType_Name[0]
		If $TreeView_NetworkType_Name[$t] = $NetworkType_treeviewname Then
			$NetworkType_treeviewposition = $TreeView_NetworkType_Pos[$t]
			ExitLoop
		EndIf
	Next
	;Add Treeview item if it does not exist
	If $channel_treeviewposition = -1 Then
		$channel_treeviewposition = _GUICtrlTreeView_InsertItem($TreeviewAPs, $channel_treeviewname, $channel_tree)
		_ArrayAdd($TreeView_Channel_Name, $channel_treeviewname)
		_ArrayAdd($TreeView_Channel_Pos, $channel_treeviewposition)
	EndIf
	If $SSID_treeviewposition = -1 Then
		$SSID_treeviewposition = _GUICtrlTreeView_InsertItem($TreeviewAPs, $SSID_treeviewname, $SSID_tree)
		_ArrayAdd($TreeView_SSID_Name, $SSID_treeviewname)
		_ArrayAdd($TreeView_SSID_Pos, $SSID_treeviewposition)
	EndIf
	If $Encryption_treeviewposition = -1 Then
		$Encryption_treeviewposition = _GUICtrlTreeView_InsertItem($TreeviewAPs, $Encryption_treeviewname, $Encryption_tree)
		_ArrayAdd($TreeView_Encryption_Name, $Encryption_treeviewname)
		_ArrayAdd($TreeView_Encryption_Pos, $Encryption_treeviewposition)
	EndIf
	If $Authentication_treeviewposition = -1 Then
		$Authentication_treeviewposition = _GUICtrlTreeView_InsertItem($TreeviewAPs, $Authentication_treeviewname, $Authentication_tree)
		_ArrayAdd($TreeView_Authentication_Name, $Authentication_treeviewname)
		_ArrayAdd($TreeView_Authentication_Pos, $Authentication_treeviewposition)
	EndIf
	If $NetworkType_treeviewposition = -1 Then
		$NetworkType_treeviewposition = _GUICtrlTreeView_InsertItem($TreeviewAPs, $NetworkType_treeviewname, $NetworkType_tree)
		_ArrayAdd($TreeView_NetworkType_Name, $NetworkType_treeviewname)
		_ArrayAdd($TreeView_NetworkType_Pos, $NetworkType_treeviewposition)
	EndIf
	_SetTreeArraySizes()
	;Create sub menu item for AP details
	$channel_subtreeviewposition = _GUICtrlTreeView_InsertItem($TreeviewAPs, '(' & $SSID & ')', $channel_treeviewposition)
	$SSID_subtreeviewposition = _GUICtrlTreeView_InsertItem($TreeviewAPs, '(' & $SSID & ')', $SSID_treeviewposition)
	$Encryption_subtreeviewposition = _GUICtrlTreeView_InsertItem($TreeviewAPs, '(' & $SSID & ')', $Encryption_treeviewposition)
	$Authentication_subtreeviewposition = _GUICtrlTreeView_InsertItem($TreeviewAPs, '(' & $SSID & ')', $Authentication_treeviewposition)
	$NetworkType_subtreeviewposition = _GUICtrlTreeView_InsertItem($TreeviewAPs, '(' & $SSID & ')', $NetworkType_treeviewposition)
	
	;Add AP details to sum menu item
	_TreeViewApInfo($channel_subtreeviewposition, $channel_tree, $SSID, $BSSID, $NetworkType, $Encryption, $RadioType, $Authentication, $BasicTransferRates, $OtherTransferRates, $MANUF, $LABEL)
	_TreeViewApInfo($SSID_subtreeviewposition, $SSID_tree, $SSID, $BSSID, $NetworkType, $Encryption, $RadioType, $Authentication, $BasicTransferRates, $OtherTransferRates, $MANUF, $LABEL)
	_TreeViewApInfo($Encryption_subtreeviewposition, $Encryption_tree, $SSID, $BSSID, $NetworkType, $Encryption, $RadioType, $Authentication, $BasicTransferRates, $OtherTransferRates, $MANUF, $LABEL)
	_TreeViewApInfo($Authentication_subtreeviewposition, $Authentication_tree, $SSID, $BSSID, $NetworkType, $Encryption, $RadioType, $Authentication, $BasicTransferRates, $OtherTransferRates, $MANUF, $LABEL)
	_TreeViewApInfo($NetworkType_subtreeviewposition, $NetworkType_tree, $SSID, $BSSID, $NetworkType, $Encryption, $RadioType, $Authentication, $BasicTransferRates, $OtherTransferRates, $MANUF, $LABEL)
	;Return Treeview positions
	Return ($channel_subtreeviewposition & '|' & $SSID_subtreeviewposition & '|' & $Encryption_subtreeviewposition & '|' & $Authentication_subtreeviewposition & '|' & $NetworkType_subtreeviewposition)
EndFunc   ;==>_TreeViewAdd

Func _TreeViewApInfo($position, ByRef $tree, $SSID, $BSSID, $NetworkType, $Encryption, $RadioType, $Authentication, $BasicTransferRates, $OtherTransferRates, $MANUF, $LABEL)
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_TreeViewApInfo()') ;#Debug Display
	_GUICtrlTreeView_InsertItem($TreeviewAPs, $Column_Names_SSID & ' : ' & $SSID, $position)
	_GUICtrlTreeView_InsertItem($TreeviewAPs, $Column_Names_BSSID & ' : ' & $BSSID, $position)
	_GUICtrlTreeView_InsertItem($TreeviewAPs, $Column_Names_NetworkType & ' : ' & $NetworkType, $position)
	_GUICtrlTreeView_InsertItem($TreeviewAPs, $Column_Names_Encryption & ' : ' & $Encryption, $position)
	_GUICtrlTreeView_InsertItem($TreeviewAPs, $Column_Names_RadioType & ' : ' & $RadioType, $position)
	_GUICtrlTreeView_InsertItem($TreeviewAPs, $Column_Names_Authentication & ' : ' & $Authentication, $position)
	_GUICtrlTreeView_InsertItem($TreeviewAPs, $Column_Names_BasicTransferRates & ' : ' & $BasicTransferRates, $position)
	_GUICtrlTreeView_InsertItem($TreeviewAPs, $Column_Names_OtherTransferRates & ' : ' & $OtherTransferRates, $position)
	_GUICtrlTreeView_InsertItem($TreeviewAPs, $Column_Names_MANUF & ' : ' & $MANUF, $position)
	_GUICtrlTreeView_InsertItem($TreeviewAPs, $Column_Names_Label & ' : ' & $LABEL, $position)
EndFunc   ;==>_TreeViewApInfo

Func _SetTreeArraySizes()
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_SetTreeArraySizes()') ;#Debug Display
	$TreeView_Channel_Name[0] = UBound($TreeView_Channel_Name) - 1
	$TreeView_SSID_Name[0] = UBound($TreeView_SSID_Name) - 1
	$TreeView_Encryption_Name[0] = UBound($TreeView_Encryption_Name) - 1
	$TreeView_Authentication_Name[0] = UBound($TreeView_Authentication_Name) - 1
	$TreeView_NetworkType_Name[0] = UBound($TreeView_NetworkType_Name) - 1
	$TreeView_Channel_Pos[0] = UBound($TreeView_Channel_Pos) - 1
	$TreeView_SSID_Pos[0] = UBound($TreeView_SSID_Pos) - 1
	$TreeView_Encryption_Pos[0] = UBound($TreeView_Encryption_Pos) - 1
	$TreeView_Authentication_Pos[0] = UBound($TreeView_Authentication_Pos) - 1
	$TreeView_NetworkType_Pos[0] = UBound($TreeView_NetworkType_Pos) - 1
EndFunc   ;==>_SetTreeArraySizes

Func _SetDataArraySizes()
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_SetDataArraySizes()') ;#Debug Display
	$DataArray_Line[0] = UBound($DataArray_Active) - 1
	$DataArray_Active[0] = UBound($DataArray_Active) - 1
	$DataArray_BSSID[0] = UBound($DataArray_BSSID) - 1
	$DataArray_SSID[0] = UBound($DataArray_SSID) - 1
	$DataArray_Auth[0] = UBound($DataArray_Auth) - 1
	$DataArray_Encr[0] = UBound($DataArray_Encr) - 1
	$DataArray_SecType[0] = UBound($DataArray_SecType) - 1
	$DataArray_Sig[0] = UBound($DataArray_Sig) - 1
	$DataArray_HighGpsSig[0] = UBound($DataArray_HighGpsSig) - 1
	$DataArray_Chan[0] = UBound($DataArray_Chan) - 1
	$DataArray_Rad[0] = UBound($DataArray_Rad) - 1
	$DataArray_Lon[0] = UBound($DataArray_Lon) - 1
	$DataArray_Lat[0] = UBound($DataArray_Lat) - 1
	$DataArray_BtX[0] = UBound($DataArray_BtX) - 1
	$DataArray_OtX[0] = UBound($DataArray_OtX) - 1
	$DataArray_NetType[0] = UBound($DataArray_NetType) - 1
	$DataArray_FirstTime[0] = UBound($DataArray_FirstTime) - 1
	$DataArray_LastTime[0] = UBound($DataArray_LastTime) - 1
	$DataArray_SigHist[0] = UBound($DataArray_SigHist) - 1
	$DataArray_Manu[0] = UBound($DataArray_Manu) - 1
	$DataArray_Label[0] = UBound($DataArray_Label) - 1
	$DataArray_Row[0] = UBound($DataArray_Row) - 1
	$DataArray_GID[0] = UBound($DataArray_Row) - 1
	$DataArray_TreeViewSubChannel[0] = UBound($DataArray_TreeViewSubChannel) - 1
	$DataArray_TreeViewSubSSID[0] = UBound($DataArray_TreeViewSubSSID) - 1
	$DataArray_TreeViewSubEncr[0] = UBound($DataArray_TreeViewSubEncr) - 1
	$DataArray_TreeViewSubAuth[0] = UBound($DataArray_TreeViewSubAuth) - 1
	$DataArray_TreeViewSubNetType[0] = UBound($DataArray_TreeViewSubNetType) - 1
EndFunc   ;==>_SetDataArraySizes

Func _SetTmpArraySizes()
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_SetTmpArraySizes()') ;#Debug Display
	$TmpArray_BSSID[0] = UBound($TmpArray_BSSID) - 1
	$TmpArray_SSID[0] = UBound($TmpArray_SSID) - 1
	$TmpArray_Auth[0] = UBound($TmpArray_Auth) - 1
	$TmpArray_Encr[0] = UBound($TmpArray_Encr) - 1
	$TmpArray_Sig[0] = UBound($TmpArray_Sig) - 1
	$TmpArray_Chan[0] = UBound($TmpArray_Chan) - 1
	$TmpArray_Rad[0] = UBound($TmpArray_Rad) - 1
	$TmpArray_BtX[0] = UBound($TmpArray_BtX) - 1
	$TmpArray_OtX[0] = UBound($TmpArray_OtX) - 1
	$TmpArray_NetType[0] = UBound($TmpArray_NetType) - 1
EndFunc   ;==>_SetTmpArraySizes

Func _ClearAllAp()
	Dim $DataArray_Line[1]
	Dim $DataArray_Active[1]
	Dim $DataArray_BSSID[1]
	Dim $DataArray_SSID[1]
	Dim $DataArray_Auth[1]
	Dim $DataArray_Encr[1]
	Dim $DataArray_Encr[1]
	Dim $DataArray_Sig[1]
	Dim $DataArray_HighGpsSig[1]
	Dim $DataArray_Chan[1]
	Dim $DataArray_Rad[1]
	Dim $DataArray_Lon[1]
	Dim $DataArray_Lat[1]
	Dim $DataArray_BtX[1]
	Dim $DataArray_OtX[1]
	Dim $DataArray_NetType[1]
	Dim $DataArray_FirstTime[1]
	Dim $DataArray_LastTime[1]
	Dim $DataArray_SigHist[1]
	Dim $DataArray_Manu[1]
	Dim $DataArray_Label[1]
	Dim $DataArray_Row[1]
	Dim $DataArray_TreeViewSubChannel[1]
	Dim $DataArray_TreeViewSubSSID[1]
	Dim $DataArray_TreeViewSubEncr[1]
	Dim $DataArray_TreeViewSubAuth[1]
	Dim $DataArray_TreeViewSubNetType[1]

	Dim $TreeView_Channel_Name[1]
	Dim $TreeView_SSID_Name[1]
	Dim $TreeView_Encryption_Name[1]
	Dim $TreeView_Authentication_Name[1]
	Dim $TreeView_NetworkType_Name[1]
	Dim $TreeView_Channel_Pos[1]
	Dim $TreeView_SSID_Pos[1]
	Dim $TreeView_Encryption_Pos[1]
	Dim $TreeView_Authentication_Pos[1]
	Dim $TreeView_NetworkType_Pos[1]
	
	Dim $GPSArray_ID[1]
	Dim $GPSArray_Lat[1]
	Dim $GPSArray_Lon[1]
	Dim $GPSArray_Sat[1]
	Dim $GPSArray_Date[1]
	Dim $GPSArray_Time[1]

	
	GUISwitch($DataChild)
	_GUICtrlListView_Destroy($ListviewAPs)
	$ListviewAPs = GUICtrlCreateListView($headers, 260, 5, 725, 585, $LVS_REPORT + $LVS_SINGLESEL, $LVS_EX_HEADERDRAGDROP + $LVS_EX_GRIDLINES + $LVS_EX_FULLROWSELECT)
	GUICtrlSetBkColor(-1, $ControlBackgroundColor)
	GUISwitch($Vistumbler)
	_SetControlSizes()

	_GUICtrlTreeView_DeleteChildren($TreeviewAPs, $Authentication_tree)
	_GUICtrlTreeView_DeleteChildren($TreeviewAPs, $channel_tree)
	_GUICtrlTreeView_DeleteChildren($TreeviewAPs, $Encryption_tree)
	_GUICtrlTreeView_DeleteChildren($TreeviewAPs, $NetworkType_tree)
	_GUICtrlTreeView_DeleteChildren($TreeviewAPs, $SSID_tree)

	_SetDataArraySizes()
	_SetTreeArraySizes()
	$ClearAllAps = 0
EndFunc   ;==>_ClearAllAp

Func _FixLineNumbers();Update Listview Row Numbers in DataArray
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_FixLineNumbers()') ;#Debug Display
	$ListViewSize = _GUICtrlListView_GetItemCount($ListviewAPs) - 1; Get List Size
	For $lisviewrow = 0 To $ListViewSize
		For $fln = 1 To $DataArray_Line[0]
			If $DataArray_Line[$fln] = _GUICtrlListView_GetItemText($ListviewAPs, $lisviewrow, $column_Line) Then
				$DataArray_Row[$fln] = $lisviewrow
				ExitLoop
			EndIf
		Next
	Next
EndFunc   ;==>_FixLineNumbers

;-------------------------------------------------------------------------------------------------------------------------------
;                                                       MANUFACTURER/LABEL FUNCTIONS
;-------------------------------------------------------------------------------------------------------------------------------

Func _FindManufacturer($findmac);Returns Manufacturer for given Mac Address
	If StringLen($findmac) <> 6 Then $findmac = StringTrimRight($findmac, StringLen($findmac) - 6)
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_FindManufacturer()') ;#Debug Display
	Dim $return = $Text_Unknown
	For $searchmaclist = 1 To $manu_mac[0]
		If StringStripWS(StringUpper($manu_mac[$searchmaclist]), 3) = StringStripWS(StringUpper($findmac), 3) Then ;StringStripWS(StringUpper($findmac), 3) Then
			$return = $manu_manu[$searchmaclist]
			ExitLoop
		EndIf
	Next
	Return ($return)
EndFunc   ;==>_FindManufacturer

Func _SetLabels($findmac);Returns Label for given Mac Address
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_SetLabels()') ;#Debug Display
	Dim $return = $Text_Unknown
	For $searchlabellist = 1 To $label_mac[0]
		If StringStripWS(StringUpper($label_mac[$searchlabellist]), 3) = StringStripWS(StringUpper($findmac), 3) Then
			$return = $label_label[$searchlabellist]
			ExitLoop
		EndIf
	Next
	Return ($return)
EndFunc   ;==>_SetLabels

;-------------------------------------------------------------------------------------------------------------------------------
;                                                       TOGGLE/BUTTON FUNCTIONS
;-------------------------------------------------------------------------------------------------------------------------------

Func _CloseToggle() ;Sets Close to 1 to exit vistumbler
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_CloseToggle()') ;#Debug Display
	$Close = 1
EndFunc   ;==>_CloseToggle

Func _ExitVistumbler()
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_ExitVistumbler()') ;#Debug Display
	If $newdata = 1 Then ;If Access point data has changed since load/last save, ask user if they want to save the data
		$savemsg = MsgBox(3, $Text_Save, $Text_SaveQuestion)
		If $savemsg <> 2 Then
			If $savemsg = 6 Then _ExportData()
			_Exit()
		EndIf
	Else
		_Exit()
	EndIf
	$Close = 0
EndFunc   ;==>_ExitVistumbler

Func _Exit()
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_Exit()') ;#Debug Display
	If WinExists($Text_ConnectToWindowName) Then WinClose($Text_ConnectToWindowName)
	GUISetState(@SW_HIDE, $Vistumbler)
	_WriteINI(); Write current settings to back to INI file
	FileDelete($GoogleEarth_ActiveFile)
	FileDelete($GoogleEarth_DeadFile)
	FileDelete($GoogleEarth_GpsFile)
	FileDelete($GoogleEarth_OpenFile)
	FileDelete($tempfile)
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
		If WinExists($Text_ConnectToWindowName) Then WinClose($Text_ConnectToWindowName)
	Else
		$Scan = 1
		GUICtrlSetState($ScanWifiGUI, $GUI_CHECKED)
		GUICtrlSetData($ScanButton, $Text_StopScanAps)
		$save_timer = TimerInit()
	EndIf
EndFunc   ;==>ScanToggle

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
		$openport = _OpenComPort($ComPort, $BAUD);Open The GPS COM port
		If $openport = 1 Then
			$UseGPS = 1
			;GUICtrlSetState($SetGPS, $GUI_CHECKED)
			GUICtrlSetData($GpsButton, $Text_StopGPS)
			$GPGGA_Update = TimerInit()
			$GPRMC_Update = TimerInit()
		Else
			$UseGPS = 0
			GUICtrlSetData($msgdisplay, 'Error opening GPS port')
		EndIf
	EndIf
EndFunc   ;==>_GpsToggle

Func _TurnOffGPS();Turns off GPS, resets variable
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_TurnOffGPS()') ;#Debug Display
	$UseGPS = 0
	$TurnOffGPS = 0
	$disconnected_time = -1
	$Latitude = 'N 0.0000'
	$Longitude = 'E 0.0000'
	$NumberOfSatalites = '00'
	_CloseComPort($ComPort) ;Close The GPS COM port
	;GUICtrlSetState($SetGPS, $GUI_UNCHECKED)
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
		_ResetSizes()
	ElseIf $Graph = 0 Then
		_DrawingStartUp($GraphicGUI)
		_CreatePens()
		$Graph = 1
		GUICtrlSetData($GraphButton1, $Text_NoGraph)
		GUISwitch($Vistumbler)
		GUISetState(@SW_SHOW, $GraphicGUI)
		_ResetSizes()
	EndIf
	_SetControlSizes()
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
		_ResetSizes()
	ElseIf $Graph = 0 Then
		_DrawingStartUp($GraphicGUI)
		_CreatePens()
		$Graph = 2
		GUICtrlSetData($GraphButton2, $Text_NoGraph)
		GUISwitch($Vistumbler)
		GUISetState(@SW_SHOW, $GraphicGUI)
		_ResetSizes()
	EndIf
	_SetControlSizes()
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
	EndIf ;==>_DebugToggle
EndFunc   ;==>_DebugToggle

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

Func _ToggleSpeechType()
	If $SpeakType = 1 Then
		$SpeakType = 2
	Else
		$SpeakType = 1
	EndIf
EndFunc   ;==>_ToggleSpeechType

Func _ToggleSayPercent()
	If $SpeakSigSayPecent = 1 Then
		$SpeakSigSayPecent = 0
	Else
		$SpeakSigSayPecent = 1
	EndIf
EndFunc   ;==>_ToggleSayPercent

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
	If GUICtrlRead($AddNewAPsToTop) = 65 Then
		GUICtrlSetState($AddNewAPsToTop, $GUI_UNCHECKED)
		$AddDirection = -1
	Else
		GUICtrlSetState($AddNewAPsToTop, $GUI_CHECKED)
		$AddDirection = 0
	EndIf
EndFunc   ;==>_AddApPosToggle

Func _GraphDeadTimeToggle();Sets if new aps are added to the top or bottom of the list
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_AddApPosToggle()') ;#Debug Display
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
	If GUICtrlRead($AutoSaveGUI) = 65 Then
		GUICtrlSetState($AutoSaveGUI, $GUI_UNCHECKED)
		$AutoSave = 0
	Else
		GUICtrlSetState($AutoSaveGUI, $GUI_CHECKED)
		$AutoSave = 1
	EndIf
EndFunc   ;==>_AutoSaveToggle

Func _AutoSortToggle();Turns auto sort on or off
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_AutoSortToggle()') ;#Debug Display
	If GUICtrlRead($AutoSortGUI) = 65 Then
		GUICtrlSetState($AutoSortGUI, $GUI_UNCHECKED)
		$AutoSort = 0
	Else
		GUICtrlSetState($AutoSortGUI, $GUI_CHECKED)
		$AutoSave = 1
		$sort_timer = TimerInit()
	EndIf
EndFunc   ;==>_AutoSortToggle

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

Func _OpenComPort($CommPort = '8', $sBAUD = '4800', $s1 = 'N', $s2 = '8', $s3 = '1');Open specified COM port
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_OpenComPort()') ;#Debug Display
	If $UseNetcomm = 1 Then
		$return = 0
		$ComError = 0
		$CommSettings = $sBAUD & ',' & $s1 & ',' & $s2 & ',' & $s3
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
	Else
		Dim $iBits = 8, $iPar = 0, $iStop = 1, $iFlow = 0
		$OpenedPort = _CommSetPort($CommPort, $sErr, $sBAUD, $iBits, $iPar, $iStop, $iFlow)
		If $OpenedPort = 1 Then
			Return (1)
		Else
			Return (0)
		EndIf
	EndIf
EndFunc   ;==>_OpenComPort

Func _CloseComPort($CommPort = '8');Closes specified COM port
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_CloseComPort()') ;#Debug Display
	;Close the COM Port
	If $UseNetcomm = 1 Then
		With $NetComm
			.CommPort = $CommPort ;Set port number
			.PortOpen = "False"
		EndWith
	Else
		_CommClosePort()
	EndIf
EndFunc   ;==>_CloseComPort

Func _GetGPS(); Recieves data from gps device
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_GetGPS()') ;#Debug Display
	$timeout = TimerInit()
	$return = 1
	
	$maxtime = $RefreshLoopTime * 0.8; Set GPS timeout to 80% of the given timout time
	If $maxtime < 800 Then $maxtime = 800;Set GPS timeout to 800 if it is under that
	
	Dim $Temp_FixTime, $Temp_FixTime2, $Temp_FixDate, $Temp_Lat, $Temp_Lon, $Temp_Lat2, $Temp_Lon2, $Temp_Quality, $Temp_NumberOfSatalites, $Temp_HorDilPitch, $Temp_Alt, $Temp_AltS, $Temp_Geo, $Temp_GeoS, $Temp_Status, $Temp_SpeedInKnots, $Temp_SpeedInMPH, $Temp_SpeedInKmH, $Temp_TrackAngle
	Dim $Temp_Quality = 0, $Temp_Status = "V"
	
	If $UseNetcomm = 1 Then ;Use Netcomm ocx to get data (more stable right now)
		While 1 ;Loop to extract gps data untill location is found or timout time is reached
			If $UseGPS = 0 Then ExitLoop
			If $NetComm.InBufferCount Then
				$Buffer = $NetComm.InBufferCount
				If $Buffer > 100 And $LatTest = 0 And TimerDiff($timeout) < $maxtime Then
					$inputdata = $NetComm.inputdata
					$gps = StringSplit($inputdata, "$")
					For $readloop = 1 To $gps[0]
						If $GpsDetailsOpen = 1 Then GUICtrlSetData($GpsCurrentDataGUI, $gps[$readloop]);Show data line in "GPS Details" GUI if it is open
						If StringInStr($gps[$readloop], "GPGGA") Then
							_GPGGA($gps[$readloop]);Split GPGGA data from data string
						ElseIf StringInStr($gps[$readloop], "GPRMC") Then
							_GPRMC($gps[$readloop]);Split GPRMC data from data string
						EndIf
						If BitOR($Temp_Quality = 1, $Temp_Quality = 2) = 1 And BitOR($Temp_Status = "A", $GpsDetailsOpen <> 1) Then ExitLoop;If $Temp_Quality = 1 (GPS has a fix) And, If the details window is open, $Temp_Status = "A" (Active data, not Void)
						If TimerDiff($timeout) > $maxtime Then ExitLoop;If time is over timeout period, exitloop
					Next
				EndIf
				If TimerDiff($timeout) > $maxtime Then
					GUICtrlSetData($msgdisplay, 'GPS Timeout')
					ExitLoop
				EndIf
				Sleep($maxtime / 10)
				$disconnected_time = TimerInit() ;reset gps turn off timer
			Else
				If $disconnected_time = -1 Then $disconnected_time = TimerInit()
				If TimerDiff($disconnected_time) > 10000 Then ; If nothing has been found in the buffer for 5 seconds, turn off gps
					$disconnected_time = -1
					$return = 0
					_TurnOffGPS()
					SoundPlay($SoundDir & $error_sound, 0)
				EndIf
			EndIf
			If TimerDiff($timeout) > $maxtime Then ExitLoop;If time is over timeout period, exitloop
		WEnd
	Else ;Use CommMG.dll instead of the netcomm ocx (less stable, but works with x64)
		While 1
			$dataline = StringStripWS(_CommGetLine(@CR, 500, $maxtime), 8);Read data line from GPS
			If $GpsDetailsOpen = 1 Then GUICtrlSetData($GpsCurrentDataGUI, $dataline);Show data line in "GPS Details" GUI if it is open
			If StringInStr($dataline, "GPGGA") Then
				_GPGGA($dataline);Split GPGGA data from data string
			ElseIf StringInStr($dataline, "GPRMC") Then
				_GPRMC($dataline);Split GPRMC data from data string
			EndIf
			If BitOR($Temp_Quality = 1, $Temp_Quality = 2) = 1 And BitOR($Temp_Status = "A", $GpsDetailsOpen <> 1) Then ExitLoop;If $Temp_Quality = 1 (GPS has a fix) And, If the details window is open, $Temp_Status = "A" (Active data, not Void)
			If TimerDiff($timeout) > $maxtime Then ExitLoop;If time is over timeout period, exitloop
		WEnd
	EndIf
	
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
	_ClearGpsDetailsGUI();Reset variables if they are over the allowed timeout
	_UpdateGpsDetailsGUI();Write changes to "GPS Details" GUI if it is open
	_DrawCompassLine($TrackAngle)
	
	If $TurnOffGPS = 1 Then _TurnOffGPS()
	
	Return ($return)
EndFunc   ;==>_GetGPS

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
	Return ($h & ":" & $m & ":" & $s & $l & ' (GMT)')
EndFunc   ;==>_FormatGpsTime

Func _FormatGpsDate($date)
	$d = StringTrimRight($date, 4)
	$m = StringTrimLeft(StringTrimRight($date, 2), 2)
	$y = StringTrimLeft($date, 4)
	Return ($m & "/" & $d & "/" & $y)
EndFunc   ;==>_FormatGpsDate

Func _GPGGA($data);Strips data from a gps $GPGGA data string
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_GPGGA()') ;#Debug Display
	GUICtrlSetData($msgdisplay, $data)
	$GPGGA_Split = StringSplit($data, ",");
	If $GPGGA_Split[0] >= 14 Then
		If StringInStr($GPGGA_Split[$GPGGA_Split[0]], "*") Then
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
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_GPRMC()') ;#Debug Display
	GUICtrlSetData($msgdisplay, $data)
	$GPRMC_Split = StringSplit($data, ",")
	If $GPRMC_Split[0] >= 11 Then
		If StringInStr($GPRMC_Split[$GPRMC_Split[0]], "*") Then
			$Temp_Status = $GPRMC_Split[3]
			If $Temp_Status = "A" Then
				$Temp_FixTime2 = _FormatGpsTime($GPRMC_Split[2])
				$Temp_Lat2 = $GPRMC_Split[5] & ' ' & StringFormat('%0.4f', $GPRMC_Split[4]) ;_FormatLatLon($GPRMC_Split[4], $GPRMC_Split[5])
				$Temp_Lon2 = $GPRMC_Split[7] & ' ' & StringFormat('%0.4f', $GPRMC_Split[6]) ;_FormatLatLon($GPRMC_Split[6], $GPRMC_Split[7])
				$Temp_SpeedInKnots = $GPRMC_Split[8]
				$Temp_SpeedInMPH = Round($GPRMC_Split[8] * 1.15, 2) & " MPH"
				$Temp_SpeedInKmH = Round($GPRMC_Split[8] * 1.85200, 2) & " km/h"
				$Temp_TrackAngle = $GPRMC_Split[9]
				$Temp_FixDate = _FormatGpsDate($GPRMC_Split[10])
			EndIf
		EndIf
	EndIf
EndFunc   ;==>_GPRMC

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

Func _GpsFormat($gps);Converts ddmm.mmmm to the users set gps format
	If $GPSformat = 1 Then $return = _Format_GPS_DMM_to_DDD($gps)
	If $GPSformat = 2 Then $return = _Format_GPS_DMM_to_DMS($gps)
	If $GPSformat = 3 Then $return = $gps
	Return ($return)
EndFunc   ;==>_GpsFormat

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
			$c = WinGetPos($CompassGUI)
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

Func _OpenGpsDetailsGUI();Opens GPS Details GUI
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_OpenGpsDetailsGUI()') ;#Debug Display
	If $GpsDetailsOpen = 0 Then
		$GpsDetailsGUI = GUICreate($Text_GpsDetails, 565, 190, -1, -1, BitOR($WS_OVERLAPPEDWINDOW, $WS_CLIPSIBLINGS))
		GUISetBkColor($BackgroundColor)
		$GpsCurrentDataGUI = GUICtrlCreateLabel('', 8, 5, 550, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GPGGA_Quality = GUICtrlCreateLabel($Text_Quality & ":", 32, 22, 235, 15)
		GUICtrlSetColor(-1, $TextColor)
		$GPRMC_Status = GUICtrlCreateLabel($Text_Status & ":", 310, 22, 180, 15)
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
			$g = WinGetPos($GpsDetailsGUI)
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
		GUICtrlSetData($GPGGA_Quality, $Text_Quality & ": " & $Temp_Quality & @CRLF)
		GUICtrlSetData($GPGGA_Satalites, $Text_NumberOfSatalites & ": " & $NumberOfSatalites & @CRLF)
		GUICtrlSetData($GPGGA_HorDilPitch, $Text_HorizontalDilutionPosition & ": " & $HorDilPitch & @CRLF)
		GUICtrlSetData($GPGGA_Alt, $Text_Altitude & ": " & $Alt & $AltS & @CRLF)
		GUICtrlSetData($GPGGA_Geo, $Text_HeightOfGeoid & ": " & $Geo & $GeoS & @CRLF)
		
		GUICtrlSetData($GPRMC_Time, $Text_Time & ": " & $FixTime2 & @CRLF)
		GUICtrlSetData($GPRMC_Date, $Text_Date & ": " & $FixDate & @CRLF)
		GUICtrlSetData($GPRMC_Lat, $Column_Names_Latitude & ": " & _GpsFormat($Latitude2) & @CRLF)
		GUICtrlSetData($GPRMC_Lon, $Column_Names_Longitude & ": " & _GpsFormat($Longitude2) & @CRLF)
		GUICtrlSetData($GPRMC_Status, $Text_Status & ": " & $Temp_Status & @CRLF)
		GUICtrlSetData($GPRMC_SpeedKnots, $Text_SpeedInKnots & ": " & $SpeedInKnots & @CRLF)
		GUICtrlSetData($GPRMC_SpeedMPH, $Text_SpeedInMPH & ": " & $SpeedInMPH & @CRLF)
		GUICtrlSetData($GPRMC_SpeedKmh, $Text_SpeedInKmh & ": " & $SpeedInKmH & @CRLF)
		GUICtrlSetData($GPRMC_TrackAngle, $Text_TrackAngle & ": " & $TrackAngle & @CRLF)
	EndIf
EndFunc   ;==>_UpdateGpsDetailsGUI

Func _ClearGpsDetailsGUI();Clears all GPS Details information
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_ClearGpsDetailsGUI()') ;#Debug Display
	GUICtrlSetData($msgdisplay, "Seconds Since GPS Update: GPGGA:" & Round(TimerDiff($GPGGA_Update) / 1000) & " / " & ($GpsTimeout / 1000) & " - " & "GPRMC:" & Round(TimerDiff($GPRMC_Update) / 1000) & " / " & ($GpsTimeout / 1000))
	If Round(TimerDiff($GPGGA_Update)) > $GpsTimeout Then
		$FixTime = ''
		$Latitude = 'N 0.0000'
		$Longitude = 'E 0.0000'
		$NumberOfSatalites = '00'
		$HorDilPitch = ''
		$Alt = ''
		$AltS = ''
		$Geo = ''
		$GeoS = ''
		$GPGGA_Update = TimerInit()
	EndIf
	If Round(TimerDiff($GPRMC_Update)) > $GpsTimeout Then
		$FixTime2 = ''
		$Latitude2 = 'N 0.0000'
		$Longitude2 = 'E 0.0000'
		$SpeedInKnots = ''
		$SpeedInMPH = ''
		$SpeedInKmH = ''
		$TrackAngle = ''
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
	GUICtrlSetData($msgdisplay, 'Sorting Treeview')
	_GUICtrlTreeView_Sort($TreeviewAPs)
	GUICtrlSetData($msgdisplay, '')
EndFunc   ;==>_SortTree

Func _HeaderSort($column);Sort a column in ap list
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_HeaderSort()') ;#Debug Display
	GUICtrlSetData($msgdisplay, 'Sorting List')
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
	$SortColumn = -1
	GUICtrlSetData($msgdisplay, '')
EndFunc   ;==>_HeaderSort

Func _HeaderSort2($column);Sort a column in a manufacturer/label list
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_HeaderSort2()') ;#Debug Display
	If $Direction2[$column] = 0 Then
		Dim $v_sort = False;set descending
	Else
		Dim $v_sort = True;set ascending
	EndIf
	If $Direction2[$column] = 0 Then
		$Direction2[$column] = 1
	Else
		$Direction2[$column] = 0
	EndIf
	_GUICtrlListView_SimpleSort($GUIList, $v_sort, $column)
EndFunc   ;==>_HeaderSort2

Func _Sort($Sort);Auto Sort based on a user chosen column
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_Sort()') ;#Debug Display
	GUICtrlSetData($msgdisplay, 'Sorting List')
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
	$sort_timer = TimerInit()
EndFunc   ;==>_Sort

;-------------------------------------------------------------------------------------------------------------------------------
;                                                       WINDOW FUNCTIONS
;-------------------------------------------------------------------------------------------------------------------------------

Func _WinMoved();Checks if window has moved. Returns 1 if it has
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_WinMoved()') ;#Debug Display
	$a = WinGetPos($Vistumbler)
	$winpos_old = $winpos
	$winpos = $a[0] & $a[1] & $a[2] & $a[3]
	
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
	$a = WinGetPos($Vistumbler)
	WinMove($DataChild, "", 0, 60, $a[2] - 10, $a[3] - 115)
	$b = WinGetPos($DataChild) ;get child window size
	$sizes = $a[0] & '-' & $a[1] & '-' & $a[2] & '-' & $a[3] & '-' & $b[0] & '-' & $b[1] & '-' & $b[2] & '-' & $b[3]
	If $sizes <> $sizes_old Or $Graph <> $Graph_old Or $Redraw = 1 Then
		$DataChild_Width = $b[2]
		$DataChild_Height = $b[3]
		If $Graph <> 0 Then
			$Graphic_left = ($b[2] * 0.01)
			$Graphic_width = Round(($b[2] * 0.99) - $Graphic_left)
			$Graphic_top = ($b[3] * 0.01)
			$Graphic_height = Round(($b[3] * $SplitHeightPercent) - $Graphic_top)
			
			$ListviewAPs_left = ($b[2] * 0.01)
			$ListviewAPs_width = Round(($b[2] * 0.99) - $ListviewAPs_left)
			$ListviewAPs_top = ($b[3] * $SplitHeightPercent) + 1
			$ListviewAPs_height = Round(($b[3] * 0.99) - $ListviewAPs_top)

			GUICtrlSetState($TreeviewAPs, $GUI_HIDE)
			WinMove($GraphicGUI, "", $Graphic_left, $Graphic_top + 60, $Graphic_width, $Graphic_height)
			GUICtrlSetPos($ListviewAPs, $ListviewAPs_left, $ListviewAPs_top, $ListviewAPs_width, $ListviewAPs_height)
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
			
			GUICtrlSetState($TreeviewAPs, $GUI_SHOW)
			GUICtrlSetPos($ListviewAPs, $ListviewAPs_left, $ListviewAPs_top, $ListviewAPs_width, $ListviewAPs_height)
			GUICtrlSetPos($TreeviewAPs, $TreeviewAPs_left, $TreeviewAPs_top, $TreeviewAPs_width, $TreeviewAPs_height)
			GUICtrlSetState($ListviewAPs, $GUI_FOCUS)
		EndIf
		$sizes_old = $sizes
		$Graph_old = $Graph
	EndIf
EndFunc   ;==>_SetControlSizes

Func _TreeviewListviewResize()
	$cursorInfo = GUIGetCursorInfo($Vistumbler)
	If $Graph = 0 Then
		If $cursorInfo[0] > $TreeviewAPs_left + $TreeviewAPs_width - 5 And $cursorInfo[0] < $TreeviewAPs_left + $TreeviewAPs_width + 5 And $cursorInfo[1] > ($TreeviewAPs_top + 60) And $cursorInfo[1] < ($TreeviewAPs_top + 60) + $TreeviewAPs_height And $MoveMode = False Then
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
		If $cursorInfo[1] > ($Graphic_top + 60) + $Graphic_height - 5 And $cursorInfo[1] < ($Graphic_top + 60) + $Graphic_height + 5 And $MoveMode = False Then
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

;-------------------------------------------------------------------------------------------------------------------------------
;                                                       GRAPH FUNCTIONS
;-------------------------------------------------------------------------------------------------------------------------------

Func _GraphApSignal() ;Graphs GPS History from selected ap
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_GraphApSignal()') ;#Debug Display
	If $Graph <> 0 Then; If the graph tab is selected, run graph script
		$Selected = _GUICtrlListView_GetNextItem($ListviewAPs); find what AP is selected in the list. returns -1 is nothing is selected
		If $Selected <> -1 Then ;If a access point is selected in the listview, map its data
			$line = _GUICtrlListView_GetItemText($ListviewAPs, $Selected, $column_Line)
			$data = ''
			For $finddata = 1 To $DataArray_Line[0]
				If $DataArray_Line[$finddata] = $line Then
					$data = $DataArray_SigHist[$finddata]
					ExitLoop
				EndIf
			Next
			If $data <> $data_old Or $sizes <> $sizes_old Or $Redraw = 1 Then ; if graph data changed, map new data
				$base_right = $Graphic_width - 1
				$base_left = 0
				$base_top = 0
				$base_bottom = $Graphic_height - 1
				$base_x = $base_right - $base_left
				$base_y = $base_bottom - $base_top

				$max_graph_points = 125
				$data_old = $data
				$sizes_old = $sizes
				$splitdata = StringSplit($data, '-');Split signals into an array
				
				If IsArray($splitdata) Then
					If $Selected <> $LastSelected Or $Redraw = 1 Then
						$o_old = 0
						$Redraw = 1
						For $r = 1 To $Graphic_height
							_SelectColor($GraphBack)
							_DrawLine($base_left, $r, $base_right, $r)
						Next
						$LastSelected = $Selected
						
						_SelectColor($GraphGrid)
						_DrawLine($base_left, $base_top, $base_left, $base_bottom)
						_DrawLine($base_right, $base_top, $base_right, $base_bottom)
						_DrawLine($base_left, $base_bottom, $base_right, $base_bottom)
						_DrawLine($base_left, $base_top, $base_right, $base_top)
						For $drawline = 1 To 10
							$subtract_value = ($drawline * 10) * ($base_y / 100)
							_DrawLine($base_right, $subtract_value, $base_left, $subtract_value)
						Next
					EndIf
					
					If $Graph = 1 Then
						If $splitdata[0] > $max_graph_points Then ; If the array is grater that the max number of ports, set array size to the max size, else use the full size of the array
							$start = $splitdata[0] - $max_graph_points
							$arrayend = $splitdata[0]
							$arraylen = $max_graph_points
						Else
							$start = 1
							$arrayend = $splitdata[0]
							$arraylen = $splitdata[0]
						EndIf
						$base_x_add_value = ($base_x / ($arraylen - 2)); Set disance between points
						$base_y_add_value = ($base_y / 100); set distance for 1%, this will be multplied by the signal strenth later
						
						
						;############### Start Mapping Access Point signal Data ###############
						_SelectColor($red)
						$base_add = $base_left
						For $o = $start To ($arrayend - 2)
							$x1 = $base_left + ($base_add - $base_x_add_value)
							$x2 = $base_left + $base_add
							$x3 = $base_left + ($base_add + $base_x_add_value)
							$x4 = $base_left + ($base_add + ($base_x_add_value * 2))
							$y1 = ($base_bottom - ($splitdata[$o - 1] * $base_y_add_value))
							$y2 = $base_bottom - ($splitdata[$o] * $base_y_add_value)
							$y3 = $base_bottom - ($splitdata[$o + 1] * $base_y_add_value)
							$y4 = $base_bottom - ($splitdata[$o + 2] * $base_y_add_value)
							$y_high = $y1
							If $y2 > $y_high Then $y_high = $y2
							If $y3 > $y_high Then $y_high = $y3
							If $y4 > $y_high Then $y_high = $y4
							$y_low = $y1
							If $y2 < $y_low Then $y_low = $y2
							If $y3 < $y_low Then $y_low = $y3
							If $y4 < $y_low Then $y_low = $y4
							
							_SelectColor($GraphBack)
							For $rl = $x1 To $x4
								_DrawLine($rl, $y_high + 2, $rl, $y_low - 2)
							Next
							
							_SelectColor($GraphGrid)
							For $drawline = 1 To 10
								$subtract_value = (($drawline * 10) * $base_y_add_value)
								_DrawLine($x1, $subtract_value, $x4, $subtract_value)
							Next
							
							_DrawLine($base_right, $base_top, $base_right, $base_bottom)
							_DrawLine($base_left, $base_top, $base_left, $base_bottom)
							_DrawLine($base_left, $base_top, $base_right, $base_top)
							
							_SelectColor($red)
							_DrawDot($x1, $y1)
							_DrawLine($x1, $y1, $x2, $y2);Draw line
							_DrawDot($x2, $y2)
							_DrawLine($x2, $y2, $x3, $y3);Draw line
							_DrawDot($x3, $y3)
							_DrawLine($x3, $y3, $x4, $y4);Draw line
							_DrawDot($x4, $y4)
							$base_add += $base_x_add_value
						Next
						;############### End Mapping Access Point signal Data ###############
					ElseIf $Graph = 2 Then
						If $splitdata[0] > $base_x Then
							$start = $splitdata[0] - $base_x
							$arraylen = $splitdata[0]
							;_ArrayDisplay($splitdata, $start)
						Else
							$start = 1
							$arraylen = $splitdata[0]
						EndIf
						$base_y_add_value = ($base_y / 100); set distance for 1%, this will be multplied by the signal strenth later
						
						$base_add = $base_left + 1
						$base_x_add_value = 1
						
						For $o = $start To $arraylen
							If $o < $arraylen And $o <> $start And $Redraw <> 1 Then
								If $splitdata[$o] <> $splitdata[$o - 1] And $start <> 1 Then
									_SelectColor($red)
									_DrawLine(($base_left + $base_add), $base_bottom, ($base_left + $base_add), $base_bottom - ($splitdata[$o] * $base_y_add_value))
									_SelectColor($GraphBack)
									_DrawLine(($base_left + $base_add), $base_bottom - ($splitdata[$o] * $base_y_add_value), ($base_left + $base_add), $base_top)
									_SelectColor($GraphGrid)
									For $drawline = 1 To 10
										$subtract_value = ($drawline * 10) * $base_y_add_value
										_DrawLine(($base_left + $base_add), $subtract_value, ($base_left + $base_add) + 1, $subtract_value)
									Next
								ElseIf $o_old < $o And $start = 1 Then
									_SelectColor($red)
									_DrawLine(($base_left + $base_add), $base_bottom, ($base_left + $base_add), $base_bottom - ($splitdata[$o] * $base_y_add_value))
									_SelectColor($GraphBack)
									_DrawLine(($base_left + $base_add), $base_bottom - ($splitdata[$o] * $base_y_add_value), ($base_left + $base_add), $base_top)
									_SelectColor($GraphGrid)
									For $drawline = 1 To 10
										$subtract_value = ($drawline * 10) * $base_y_add_value
										_DrawLine(($base_left + $base_add), $subtract_value, ($base_left + $base_add) + 1, $subtract_value)
									Next
									$o_old = $o
								EndIf
							ElseIf $o = $start Or $o = $arraylen Or $Redraw = 1 Then
								_SelectColor($red)
								_DrawLine(($base_left + $base_add), $base_bottom, ($base_left + $base_add), $base_bottom - ($splitdata[$o] * $base_y_add_value))
								_SelectColor($GraphBack)
								_DrawLine(($base_left + $base_add), $base_bottom - ($splitdata[$o] * $base_y_add_value), ($base_left + $base_add), $base_top)
								_SelectColor($GraphGrid)
								For $drawline = 1 To 10
									$subtract_value = ($drawline * 10) * $base_y_add_value
									_DrawLine(($base_left + $base_add), $subtract_value, ($base_left + $base_add) + 1, $subtract_value)
								Next
							EndIf
							$base_add += $base_x_add_value
						Next
						_DrawLine($base_right, $base_top, $base_right, $base_bottom)
						_DrawLine($base_left, $base_top, $base_left, $base_bottom)
						_DrawLine($base_left, $base_top, $base_right, $base_top)
					EndIf
				EndIf
				$Redraw = 0
			EndIf
		EndIf
	EndIf
EndFunc   ;==>_GraphApSignal

;-------------------------------------------------------------------------------------------------------------------------------
;Graph API Functions - By neogia - http://www.autoitscript.com/forum/index.php?showtopic=24621&hl=GUICtrlSetGraphic+windows+api
;Used in place of autoit Graphic function to remove flicker when the graph gets redraw (it is slower though :-( )
;-------------------------------------------------------------------------------------------------------------------------------
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

;-------------------------------
;Graph API functions by ACalcutt
;-------------------------------

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
	;$GraphBack = _CreateColor(215, 228, 242)
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
		
		$found = -1
		For $row = 1 To $DataArray_Row[0]
			If $DataArray_Row[$row] = $Selected Then
				$found = $row
				ExitLoop
			EndIf
		Next
		
		If $found <> -1 Then
			$psarray = StringSplit($DataArray_SigHist[$found], '-')
			If @error = 1 Then
				MsgBox(0, $Text_Error, $Text_NoSignalHistory)
			Else
				For $pg = 1 To $psarray[0];reverse signal history
					If $pg = 1 Then
						$pgsigdata = $psarray[$pg]
					Else
						$pgsigdata = $psarray[$pg] & '-' & $pgsigdata
					EndIf
				Next
				$url_root = $PhilsGraphURL
				$url_data = "SSID=" & $DataArray_SSID[$found] & "&Mac=" & $DataArray_BSSID[$found] & "&Manuf=" & $DataArray_Manu[$found] & "&Auth=" & $DataArray_Auth[$found] & "&Encry=" & $DataArray_Encr[$found] & "&radio=" & $DataArray_Rad[$found] & "&Chn=" & $DataArray_Chan[$found] & "&Lat=" & $DataArray_Lat[$found] & "&Long=" & $DataArray_Lon[$found] & "&BTx=" & $DataArray_BtX[$found] & "&OTx=" & $DataArray_OtX[$found] & "&FA=" & $DataArray_FirstTime[$found] & "&LU=" & $DataArray_LastTime[$found] & "&NT=" & $DataArray_NetType[$found] & "&Label=" & $DataArray_Label[$found] & "&Sig=" & $pgsigdata
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

Func _AddToYourWDB();Send data to phils wireless ap database
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_AddToYourWDB()') ;#Debug Display
	$WdbFile = $SaveDir & 'WDB_Export.VS1'
	FileDelete($WdbFile)
	_ExportDetailedTXT($WdbFile)
	$url_root = $PhilsWdbURL;"http://www.randomintervals.com/wifi/beta/db/import/?"
	$url_data = "file=" & $WdbFile
	Run("RunDll32.exe url.dll,FileProtocolHandler " & $url_root & $url_data);open url with rundll 32
EndFunc   ;==>_AddToYourWDB

;-------------------------------------------------------------------------------------------------------------------------------
;                                                       REFRESH NETWORK FUNCTIONS
;-------------------------------------------------------------------------------------------------------------------------------

Func _RefreshNetworksGUI(); GUI to turn GPS refresh on or off and set settings
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_RefreshNetworksGUI()') ;#Debug Display
	Opt("GUIOnEventMode", 0)

	If $RefreshNetworks = 0 Then
		$StartStop = $Text_Start
		$RN_Title = $Text_Start & ' ' & $Text_RefreshNetworks
	Else
		$StartStop = $Text_Stop
		$RN_Title = $Text_Stop & ' ' & $Text_RefreshNetworks
	EndIf
	
	$RefreshGUI = GUICreate($RN_Title, 354, 136, -1, -1)
	GUISetBkColor($BackgroundColor)
	
	$RL1 = GUICtrlCreateLabel($Text_ConnectToWindowTitle, 20, 24, 130, 17)
	$RL2 = GUICtrlCreateLabel($Text_RefreshTime, 20, 56, 130, 17)
	
	$CTWN = GUICtrlCreateInput($Text_ConnectToWindowName, 160, 24, 177, 21)
	
	$RTime = GUICtrlCreateInput($RefreshTime, 160, 56, 177, 21)
	$StartRefresh = GUICtrlCreateButton($StartStop, 80, 96, 81, 25, 0)
	$CancelRefresh = GUICtrlCreateButton($Text_Cancel, 188, 94, 81, 25, 0)
	GUISetState(@SW_SHOW)

	While 1
		$nMsg = GUIGetMsg()
		Switch $nMsg
			Case $GUI_EVENT_CLOSE
				ExitLoop
			Case $CancelRefresh
				ExitLoop
			Case $StartRefresh
				If $RefreshNetworks = 0 Then
					$RefreshNetworks = 1
					GUICtrlSetData($RefreshMenuButton, $Text_Stop & ' ' & $Text_RefreshNetworks)
					$RefreshTimer = TimerInit()
					$RefreshTime = GUICtrlRead($RTime)
					$Text_ConnectToWindowName = GUICtrlRead($CTWN)
					ExitLoop
				Else
					$RefreshNetworks = 0
					GUICtrlSetData($RefreshMenuButton, $Text_Start & ' ' & $Text_RefreshNetworks)
					WinClose($Text_ConnectToWindowName)
					ExitLoop
				EndIf
		EndSwitch
	WEnd
	Opt("GUIOnEventMode", 1)
	GUIDelete($RefreshGUI)
EndFunc   ;==>_RefreshNetworksGUI

Func _RefreshNetworks();Automates clicking the refresh button on the windows 'connect to' window
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_RefreshNetworks()') ;#Debug Display
	;$WinActive =
	If $Scan = 1 And $RefreshNetworks = 1 Then
		If TimerDiff($RefreshTimer) >= $RefreshTime Then
			If WinExists($Text_ConnectToWindowName) = 0 Then Run("RunDll32.exe van.dll,RunVAN")
			ControlClick($Text_ConnectToWindowName, "", $ConnectToButton)
			$RefreshTimer = TimerInit()
		EndIf
		If WinActive($Text_ConnectToWindowName) = 1 Then WinActivate($title)
	EndIf
EndFunc   ;==>_RefreshNetworks

;-------------------------------------------------------------------------------------------------------------------------------
;                                                       VISTUMBLER SAVE FUNCTIONS
;-------------------------------------------------------------------------------------------------------------------------------

Func _OpenSaveFolder();Opens save folder in explorer
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_OpenSaveFolder() ') ;#Debug Display
	Run("RunDll32.exe url.dll,FileProtocolHandler " & $SaveDir)
EndFunc   ;==>_OpenSaveFolder

Func _AutoSave();Autosaves data to a file name based on current time
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_AutoSave()') ;#Debug Display
	DirCreate($SaveDirAuto)
	FileDelete($AutoSaveFile)
	$AutoSaveFile = $SaveDirAuto & 'AutoSave_' & @MON & '-' & @MDAY & '-' & @YEAR & ' ' & @HOUR & '-' & @MIN & '-' & @SEC & '.txt'
	_ExportToTXT($AutoSaveFile)
	$save_timer = TimerInit()
EndFunc   ;==>_AutoSave

Func _ExportData();Saves data to a selected file
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_ExportData()') ;#Debug Display
	DirCreate($SaveDir)
	$timestamp = @MON & '-' & @MDAY & '-' & @YEAR & ' ' & @HOUR & '-' & @MIN & '-' & @SEC
	$file = FileSaveDialog($Text_SaveAsTXT, $SaveDir, 'Text (*.txt)', '', $timestamp & '.txt')
	If @error <> 1 Then
		If StringInStr($file, '.txt') = 0 Then $file = $file & '.txt'
		FileDelete($file)
		_ExportToTXT($file)
		MsgBox(0, $Text_Done, $Text_SavedAs & ': "' & $file & '"')
		GUICtrlSetData($msgdisplay, '')
		$newdata = 0
	EndIf
EndFunc   ;==>_ExportData

Func _ExportDetailedData();Saves data to a selected file
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_ExportData()') ;#Debug Display
	DirCreate($SaveDir)
	$timestamp = @MON & '-' & @MDAY & '-' & @YEAR & ' ' & @HOUR & '-' & @MIN & '-' & @SEC
	$file = FileSaveDialog($Text_SaveAsTXT, $SaveDir, 'Vistumbler (*.VS1)', '', $timestamp & '.VS1')
	If @error <> 1 Then
		If StringInStr($file, '.VS1') = 0 Then $file = $file & '.VS1'
		FileDelete($file)
		_ExportDetailedTXT($file)
		MsgBox(0, $Text_Done, $Text_SavedAs & ': "' & $file & '"')
		GUICtrlSetData($msgdisplay, '')
		$newdata = 0
	EndIf
EndFunc   ;==>_ExportDetailedData

Func _ExportDetailedTXT($savefile);writes vistumbler data to a txt file
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_ExportDetailedTXT()') ;#Debug Display
	FileWriteLine($savefile, "# Vistumbler VS1 - Detailed Export Version 1.0")
	FileWriteLine($savefile, "# Created By: " & $Script_Name & ' ' & $version)
	FileWriteLine($savefile, "# -------------------------------------------------")
	FileWriteLine($savefile, "# GpsID|Latitude|Longitude|NumOfSatalites|Date|Time")
	FileWriteLine($savefile, "# -------------------------------------------------")
	For $exp = 1 To $GPSArray_ID[0]
		GUICtrlSetData($msgdisplay, 'Saving GID' & ' ' & $exp & ' / ' & $GPSArray_ID[0])
		FileWriteLine($savefile, $GPSArray_ID[$exp] & '|' & $GPSArray_Lat[$exp] & '|' & $GPSArray_Lon[$exp] & '|' & $GPSArray_Sat[$exp] & '|' & $GPSArray_Date[$exp] & '|' & $GPSArray_Time[$exp])
	Next
	FileWriteLine($savefile, "# ---------------------------------------------------------------------------------------------------------------------------------------------------------")
	FileWriteLine($savefile, "# SSID|BSSID|MANUFACTURER|Authetication|Encryption|Security Type|Radio Type|Channel|Basic Transfer Rates|Other Transfer Rates|Network Type|Label|GID,SIGNAL")
	FileWriteLine($savefile, "# ---------------------------------------------------------------------------------------------------------------------------------------------------------")
	For $save = 1 To $DataArray_BSSID[0]
		GUICtrlSetData($msgdisplay, $Text_SavingLine & ' ' & $save & ' / ' & $DataArray_BSSID[0])
		FileWriteLine($savefile, $DataArray_SSID[$save] & '|' & $DataArray_BSSID[$save] & '|' & $DataArray_Manu[$save] & '|' & $DataArray_Auth[$save] & '|' & $DataArray_Encr[$save] & '|' & $DataArray_SecType[$save] & '|' & $DataArray_Rad[$save] & '|' & $DataArray_Chan[$save] & '|' & $DataArray_BtX[$save] & '|' & $DataArray_OtX[$save] & '|' & $DataArray_NetType[$save] & '|' & $DataArray_Label[$save] & '|' & $DataArray_GID[$save])
	Next
EndFunc   ;==>_ExportDetailedTXT

Func _ExportToTXT($savefile);writes vistumbler data to a txt file
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_ExportToTXT()') ;#Debug Display
	FileWriteLine($savefile, "# Vistumbler TXT - Export Version 1.0")
	FileWriteLine($savefile, "# Created By: " & $Script_Name & ' ' & $version)
	FileWriteLine($savefile, "# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------")
	FileWriteLine($savefile, "# SSID|BSSID|MANUFACTURER|Highest Signal w/GPS|Authetication|Encryption|Radio Type|Channel|Latitude|Longitude|Basic Transfer Rates|Other Transfer Rates|First Seen|Last Seen|Network Type|Label|Signal History")
	FileWriteLine($savefile, "# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------")
	For $save = 1 To $DataArray_BSSID[0]
		GUICtrlSetData($msgdisplay, $Text_SavingLine & ' ' & $save & ' / ' & $DataArray_BSSID[0])
		FileWriteLine($savefile, $DataArray_SSID[$save] & '|' & $DataArray_BSSID[$save] & '|' & $DataArray_Manu[$save] & '|' & $DataArray_HighGpsSig[$save] & '|' & $DataArray_Auth[$save] & '|' & $DataArray_Encr[$save] & '|' & $DataArray_Rad[$save] & '|' & $DataArray_Chan[$save] & '|' & _GpsFormat($DataArray_Lat[$save]) & '|' & _GpsFormat($DataArray_Lon[$save]) & '|' & $DataArray_BtX[$save] & '|' & $DataArray_OtX[$save] & '|' & $DataArray_FirstTime[$save] & '|' & $DataArray_LastTime[$save] & '|' & $DataArray_NetType[$save] & '|' & $DataArray_Label[$save] & '|' & $DataArray_SigHist[$save])
	Next
EndFunc   ;==>_ExportToTXT

Func _ExportVSZ()
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_ExportVSZ()') ;#Debug Display
	DirCreate($SaveDir)
	$timestamp = @MON & '-' & @MDAY & '-' & @YEAR & ' ' & @HOUR & '-' & @MIN & '-' & @SEC
	$file = FileSaveDialog($Text_SaveAsTXT, $SaveDir, 'Vistumbler (*.VSZ)', '', $timestamp & '.VSZ')
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
Func _ImportVSZ()
	_ImportVszFile()
EndFunc   ;==>_ImportVSZ

Func LoadList()
	_LoadListGUI()
EndFunc   ;==>LoadList

Func AutoLoadList($imfile1 = "")
	If StringLower(StringTrimLeft($imfile1, StringLen($imfile1) - 4)) = '.vs1' Or StringUpper(StringTrimLeft($imfile1, StringLen($imfile1) - 3)) = '.txt' Then
		_LoadListGUI($imfile1)
	ElseIf StringLower(StringTrimLeft($imfile1, StringLen($imfile1) - 4)) = '.vsz' Then
		_ImportVszFile($imfile1)
	EndIf
EndFunc   ;==>AutoLoadList

Func _ImportVszFile($vsz_file = '')
	If $vsz_file = '' Then $vsz_file = FileOpenDialog("Select Vistumbler Zipped File", $SaveDir, "Vistumbler Zipped File (*.VSZ)", 1)
	If @error <> 1 Then
		If StringInStr($vsz_file, '.VSZ') = 0 Then $vsz_file = $vsz_file & '.VSZ'
		$vsz_temp_file = $TmpDir & 'data.zip'
		$vs1_file = $TmpDir & 'data.vs1'
		If FileExists($vsz_temp_file) Then FileDelete($vsz_temp_file)
		If FileExists($vs1_file) Then FileDelete($vs1_file)
		FileCopy($vsz_file, $vsz_temp_file)
		_Zip_Unzip($vsz_temp_file, 'data.vs1', $TmpDir)
		_LoadListGUI($vs1_file)
		FileDelete($vsz_temp_file)
		FileDelete($vs1_file)
	EndIf
EndFunc   ;==>_ImportVszFile

Func _LoadListGUI($imfile1 = "")
	GUISetState(@SW_MINIMIZE, $Vistumbler)
	$GUI_Import = GUICreate($Text_ImportFromTXT, 510, 175, -1, -1)
	GUISetBkColor($BackgroundColor)
	GUICtrlCreateLabel($Text_ImportFromTXT, 10, 10, 200, 20)
	$vistumblerfileinput = GUICtrlCreateInput($imfile1, 10, 30, 420, 20)
	$browse1 = GUICtrlCreateButton($Text_Browse, 440, 30, 60, 20)
	$RadVis = GUICtrlCreateRadio("Vistumbler File", 10, 55, 140, 20)
	GUICtrlSetState($RadVis, $GUI_CHECKED)
	$RadNs = GUICtrlCreateRadio("Netstumbler TXT File", 10, 75, 140, 20)
	$NsOk = GUICtrlCreateButton($Text_ImportFromTXT, 150, 60, 100, 25)
	$NsCancel = GUICtrlCreateButton($Text_Close, 260, 60, 100, 25)
	$progressbar = GUICtrlCreateProgress(10, 95, 490, 10)
	$percentlabel = GUICtrlCreateLabel($Text_Progress & ': ' & $Text_Ready, 10, 115, 200, 20)
	$linetotal = GUICtrlCreateLabel($Text_LineTotal & ':', 10, 135, 200, 20)
	$newlines = GUICtrlCreateLabel($Text_NewAPs & ':', 10, 155, 200, 20)
	$minutes = GUICtrlCreateLabel($Text_Minutes & ':', 230, 115, 240, 20)
	$linemin = GUICtrlCreateLabel($Text_LinesMin & ':', 230, 135, 240, 20)
	$estimatedtime = GUICtrlCreateLabel($Text_EstimatedTimeRemaining & ':', 230, 155, 240, 20)
	GUISetState()
	
	GUICtrlSetOnEvent($browse1, "_ImportFileBrowse")
	GUICtrlSetOnEvent($NsOk, "_ImportOk")
	GUICtrlSetOnEvent($NsCancel, "_ImportClose")
	GUISetOnEvent($GUI_EVENT_CLOSE, '_ImportClose')
	If $imfile1 <> '' Then _ImportOk()
EndFunc   ;==>_LoadListGUI

Func _ImportFileBrowse()
	$file = FileOpenDialog("Select vistumbler File", $SaveDir, "Vistumbler TXT File (*.txt;*.vs1;*.ns1)", 1)
	If Not @error Then GUICtrlSetData($vistumblerfileinput, $file)
EndFunc   ;==>_ImportFileBrowse

Func _ImportClose()
	GUIDelete($GUI_Import)
	GUISetState(@SW_RESTORE, $Vistumbler)
EndFunc   ;==>_ImportClose

Func _ImportOk()
	GUICtrlSetData($percentlabel, $Text_Progress & ': Loading')
	GUICtrlSetState($NsOk, $GUI_DISABLE)
	If GUICtrlRead($RadVis) = 1 Then
		$visfile = GUICtrlRead($vistumblerfileinput)
		$vistumblerfile = FileOpen($visfile, 0)
		If $vistumblerfile <> -1 Then
			$begintime = TimerInit()
			$currentline = 1
			$AddAP = 0
			$AddGID = 0
			$Loading = 1
			Dim $TmpGPSArray_ID[1]
			Dim $TmpGPSArray_NewID[1]
			;Get Total number of lines
			$totallines = 0
			While 1
				FileReadLine($vistumblerfile)
				If @error = -1 Then ExitLoop
				$totallines += 1
			WEnd
			For $Load = 1 To $totallines
				
				$linein = FileReadLine($vistumblerfile, $Load);Open Line in file
				If @error = -1 Then ExitLoop
				If StringTrimRight($linein, StringLen($linein) - 1) <> "#" Then
					$loadlist = StringSplit($linein, '|');Split Infomation of AP on line
					If $loadlist[0] = 6 Then ; If Line is GPS ID Line
						$LoadGID = $loadlist[1]
						$LoadLat = $loadlist[2]
						$LoadLon = $loadlist[3]
						$LoadSat = $loadlist[4]
						$LoadDate = $loadlist[5]
						$LoadTime = $loadlist[6]
						$found_gid = 0
						$GPSArray_ID[0] = UBound($GPSArray_ID) - 1
						For $lg = 1 To $GPSArray_ID[0] ;Go through current GPSArray, If entry entry exists assosiate, else add it and assosiate
							If $GPSArray_Time[$lg] = $LoadTime Then
								If $GPSArray_Lat[$lg] = $LoadLat And $GPSArray_Lon[$lg] = $LoadLon And $GPSArray_Sat[$lg] = $LoadSat And $GPSArray_Date[$lg] = $LoadDate Then
									_ArrayAdd($TmpGPSArray_ID, $LoadGID)
									_ArrayAdd($TmpGPSArray_NewID, $lg)
									$found_gid = 1
									ExitLoop
								EndIf
							EndIf
						Next
						If $found_gid = 0 Then
							$AddGID += 1
							$GPS_ID = $GPSArray_ID[0] + 1
							_ArrayAdd($GPSArray_ID, $GPS_ID)
							_ArrayAdd($GPSArray_Lat, $LoadLat)
							_ArrayAdd($GPSArray_Lon, $LoadLon)
							_ArrayAdd($GPSArray_Sat, $LoadSat)
							_ArrayAdd($GPSArray_Date, $LoadDate)
							_ArrayAdd($GPSArray_Time, $LoadTime)
							$GPSArray_ID[0] = UBound($GPSArray_ID) - 1
							_ArrayAdd($TmpGPSArray_ID, $LoadGID)
							_ArrayAdd($TmpGPSArray_NewID, $GPS_ID)
						EndIf
					ElseIf $loadlist[0] = 13 Then ;If String is VS1 data line
						$found = 0
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
						
						$GidSplit = StringSplit($GigSigHist, '-')
						For $loaddat = 1 To $GidSplit[0]
							$GidSigSplit = StringSplit($GidSplit[$loaddat], ',')
							If $GidSigSplit[0] = 2 Then
								$ImpGID = $GidSigSplit[1]
								$ImpSig = $GidSigSplit[2]
								$NewGID = $TmpGPSArray_NewID[$ImpGID]
								$ImpLat = $GPSArray_Lat[$NewGID]
								$ImpLon = $GPSArray_Lon[$NewGID]
								$ImpDate = $GPSArray_Date[$NewGID]
								$ImpTime = $GPSArray_Time[$NewGID]
								$datetimestamp = $ImpDate & ' ' & $ImpTime

								For $ap = 1 To $DataArray_BSSID[0]
									$arrayline = ($DataArray_BSSID[0] + 1) - $ap
									If $BSSID = $DataArray_BSSID[$arrayline] Then ;If Load Mac address matches a current ap
										If $DataArray_SSID[$arrayline] = $SSID And $DataArray_Chan[$arrayline] = $Channel Then ;Check if other day
											$found = 1
											
											_UpdateData($arrayline, '', $Text_Dead, '', '', '', '', $ImpSig, '', '', '', $ImpLat, $ImpLon, '', '', '', '', $datetimestamp, '', 1, 1, $NewGID)
											ExitLoop
										EndIf
									EndIf
								Next
								
								If $found = 0 Then
									$AddAP += 1
									$new = _GUICtrlListView_InsertItem($ListviewAPs, -1, '')
									_AddData($new, $Text_Dead, $BSSID, $SSID, $Authentication, $Encryption, $LoadSecType, $ImpSig, '', $Channel, $RadioType, $ImpLat, $ImpLon, $BasicTransferRates, $OtherTransferRates, $NetworkType, $datetimestamp, $datetimestamp, '', $NewGID)
								EndIf
							EndIf
						Next
					ElseIf $loadlist[0] = 17 Then ; If string is TXT data line
						$found = 0
						$SSID = StringStripWS($loadlist[1], 3)
						$BSSID = StringStripWS($loadlist[2], 3)
						$HigGpsSignal = StringStripWS($loadlist[4], 3)
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
						$tsplit = StringSplit($LoadFirstActive, ' ')
						$LoadFirstActive_Time = $tsplit[2]
						$LoadFirstActive_Date = $tsplit[1]
						$LoadFirstActive_DTS = $LoadFirstActive_Date & ' ' & $LoadFirstActive_Time
						$tsplit = StringSplit($LoadLastActive, ' ')
						$LoadLastActive_Time = $tsplit[2]
						$LoadLastActive_Date = $tsplit[1]
						$LoadLastActive_DTS = $LoadLastActive_Date & ' ' & $LoadLastActive_Time
						
						For $current_ap = 1 To $DataArray_BSSID[0]
							If $BSSID = $DataArray_BSSID[$current_ap] Then ;If Load Mac address matches a current ap
								If $DataArray_SSID[$current_ap] = $SSID And $DataArray_Chan[$current_ap] = $Channel Then
									$found = 1

									$LoadGID = -1 ;Go through current GPSArray, If entry entry exists mark array position
									For $lg = 1 To $GPSArray_ID[0]
										$gline = ($GPSArray_ID[0] + 1) - $lg
										If $GPSArray_Time[$gline] = $LoadLastActive_Time Then
											If $GPSArray_Lat[$gline] = $LoadLatitude And $GPSArray_Lon[$gline] = $LoadLongitude And $GPSArray_Date[$gline] = $LoadLastActive_Date Then
												$LoadGID = $gline
												ExitLoop
											EndIf
										EndIf
									Next
									If $LoadGID = -1 Then ;Else add Lat Lon and Time to GPSArray
										$AddGID += 1
										$GPS_ID = $GPSArray_ID[0] + 1
										_ArrayAdd($GPSArray_ID, $GPS_ID)
										_ArrayAdd($GPSArray_Lat, $LoadLatitude)
										_ArrayAdd($GPSArray_Lon, $LoadLongitude)
										_ArrayAdd($GPSArray_Sat, '00')
										_ArrayAdd($GPSArray_Date, $LoadLastActive_Date)
										_ArrayAdd($GPSArray_Time, $LoadLastActive_Time)
										$GPSArray_ID[0] = UBound($GPSArray_ID) - 1
										$LoadGID = $GPS_ID
									EndIf
									;Update Data
									_UpdateData($current_ap, '', $Text_Dead, '', '', '', '', '', $HigGpsSignal, '', '', $LoadLatitude, $LoadLongitude, '', '', '', $LoadFirstActive_DTS, $LoadLastActive_DTS, $SignalHistory, 1, 1, $LoadGID)
									ExitLoop
								EndIf
							EndIf
						Next
						;EndIf
						
						If $found = 0 Then
							If IsArray($loadlist) Then
								If $loadlist[0] = 17 Or $loadlist[0] = 18 Then
									If $BSSID <> '' Then ; If Mac Address(BSSID) was found write data into
										$AddAP += 1
										
										$new = _GUICtrlListView_InsertItem($ListviewAPs, -1, '')

										$LoadGID = -1
										For $lg = 1 To $GPSArray_ID[0]
											$gline = ($GPSArray_ID[0] + 1) - $lg
											If $GPSArray_Time[$gline] = $LoadFirstActive_Time Then
												If $GPSArray_Lat[$gline] = $LoadLatitude And $GPSArray_Lon[$gline] = $LoadLongitude And $GPSArray_Date[$gline] = $LoadFirstActive_Date Then
													$LoadGID = $gline
													ExitLoop
												EndIf
											EndIf
										Next
										If $LoadGID = -1 Then ;Else add Lat Lon and Time to GPSArray
											$AddGID += 1
											$GPS_ID = $GPSArray_ID[0] + 1
											_ArrayAdd($GPSArray_ID, $GPS_ID)
											_ArrayAdd($GPSArray_Lat, $LoadLatitude)
											_ArrayAdd($GPSArray_Lon, $LoadLongitude)
											_ArrayAdd($GPSArray_Sat, '00')
											_ArrayAdd($GPSArray_Date, $LoadFirstActive_Date)
											_ArrayAdd($GPSArray_Time, $LoadFirstActive_Time)
											$GPSArray_ID[0] = UBound($GPSArray_ID) - 1
											$LoadGID = $GPS_ID
										EndIf
										_AddData($new, $Text_Dead, $BSSID, $SSID, $Authentication, $Encryption, '', '0', $HigGpsSignal, $Channel, $RadioType, $LoadLatitude, $LoadLongitude, $BasicTransferRates, $OtherTransferRates, $NetworkType, $LoadFirstActive_DTS, $LoadLastActive_DTS, $SignalHistory, $LoadGID)
									EndIf
								EndIf
							EndIf
						EndIf
					Else
						;ExitLoop
					EndIf
				EndIf
				$min = (TimerDiff($begintime) / 60000) ;convert from miniseconds to minutes
				$percent = ($currentline / $totallines) * 100
				
				GUICtrlSetData($progressbar, $percent)
				GUICtrlSetData($percentlabel, $Text_Progress & ': ' & Round($percent, 1))
				GUICtrlSetData($linemin, $Text_LinesMin & ': ' & Round($currentline / $min, 1))
				GUICtrlSetData($newlines, $Text_NewAPs & ': ' & $AddAP & ' - ' & $Text_NewGIDs & ':' & $AddGID)
				GUICtrlSetData($minutes, $Text_Minutes & ': ' & Round($min, 1))
				GUICtrlSetData($linetotal, $Text_LineTotal & ': ' & $currentline & "/" & $totallines)
				GUICtrlSetData($estimatedtime, $Text_EstimatedTimeRemaining & ': ' & Round(($totallines / Round($currentline / $min, 1)) - $min, 1) & "/" & Round($totallines / Round($currentline / $min, 1), 1))
				_ReduceMemory()
				$currentline += 1
			Next
		EndIf
	ElseIf GUICtrlRead($RadNs) = 1 Then
		Dim $BSSID_Array[1], $SSID_Array[1], $FirstSeen_Array[1], $LastSeen_Array[1], $SignalHist_Array[1], $Lat_Array[1], $Lon_Array[1], $Auth_Array[1], $Encr_Array[1], $Type_Array[1]
		$nsfile = GUICtrlRead($vistumblerfileinput)
		$netstumblerfile = FileOpen($nsfile, 0)
		
		If $netstumblerfile <> -1 Then
			;Get Total number of lines
			$totallines = 0
			While 1
				FileReadLine($nsfile)
				If @error = -1 Then ExitLoop
				$totallines += 1
			WEnd
			$begintime = TimerInit()
			$currentline = 1
			$AddAP = 0
			$AddGID = 0
			$Loading = 1
			While 1
				$found = 0
				$linein = FileReadLine($netstumblerfile);Open Line in file
				If @error = -1 Then ExitLoop ;If end of lines reached, exit loop
				If StringInStr($linein, "# $DateGMT:") Then ;If the date tag is found, reformat and set date
					$date = StringTrimLeft($linein, 12)
					$datereformat = StringSplit($date, "-")
					If $datereformat[0] = 3 Then $date = $datereformat[2] & "-" & $datereformat[3] & "-" & $datereformat[1]
				EndIf
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
								$Encryption = $SearchWord_Wep
								$Authentication = $SearchWord_Open
							Else
								$LoadSecType = 1
								$Encryption = $SearchWord_None
								$Authentication = $SearchWord_Open
							EndIf
							;Set other information
							$snrarray1 = StringSplit($array[7], " ")
							$SSID = StringTrimLeft(StringTrimRight($array[3], 2), 2)
							$BSSID = StringUpper(StringTrimLeft(StringTrimRight($array[5], 2), 2))
							$time = StringTrimRight($array[6], 6)
							$Signal = $snrarray1[2]
							If $Signal < 0 Then $Signal = '0'
							$LoadLatitude = _Format_GPS_All_to_DMM(StringReplace($array[1], "N 360.0000000", "N 0.0000000"))
							$LoadLongitude = _Format_GPS_All_to_DMM(StringReplace($array[2], "E 720.0000000", "E 0.0000000"))
							$Channel = $array[13]
							$DateTime = $date & " " & $time & " 0"
							;Search current AP list for loaded AP. If found, update it
							$found = 0

							$AddGID += 1
							$GPS_ID = $GPSArray_ID[0] + 1
							_ArrayAdd($GPSArray_ID, $GPS_ID)
							_ArrayAdd($GPSArray_Lat, $LoadLatitude)
							_ArrayAdd($GPSArray_Lon, $LoadLongitude)
							_ArrayAdd($GPSArray_Sat, '00')
							_ArrayAdd($GPSArray_Date, $date)
							_ArrayAdd($GPSArray_Time, $time)
							$GPSArray_ID[0] = UBound($GPSArray_ID) - 1
							$LoadGID = $GPS_ID
							;EndIf
							
							For $current_ap = 1 To $DataArray_BSSID[0]
								If $BSSID = $DataArray_BSSID[$current_ap] Then
									If $DataArray_SSID[$current_ap] = $SSID And _
											$DataArray_Auth[$current_ap] = $Authentication And _
											$DataArray_Encr[$current_ap] = $Encryption And _
											$DataArray_Chan[$current_ap] = $Channel Then
										$found = 1
										If StringInStr($Signal, "*") <> 1 Then $Signal = ''
										_UpdateData($current_ap, '', $Text_Dead, '', '', '', '', $Signal, '', '', '', $LoadLatitude, $LoadLongitude, '', '', '', '', $DateTime, '', 0, 0, $LoadGID)
										ExitLoop
									EndIf
								EndIf
							Next
							;If AP not found, Add It
							If $found = 0 Then
								$AddAP += 1
								$addposition = _GUICtrlListView_InsertItem($ListviewAPs, $AddDirection, '');Add new line into listview
								_AddData($addposition, $Text_Dead, $BSSID, $SSID, $Authentication, $Encryption, $LoadSecType, $Signal, '', $Channel, $Text_Unknown, $LoadLatitude, $LoadLongitude, $Text_Unknown, $Text_Unknown, $Type, $DateTime, $DateTime, $Signal, $LoadGID);Add data into list/array
							EndIf
						EndIf
					Else
						ExitLoop
					EndIf
				EndIf
				$min = (TimerDiff($begintime) / 60000) ;convert from miniseconds to minutes
				$percent = ($currentline / $totallines) * 100
				GUICtrlSetData($progressbar, $percent)
				GUICtrlSetData($percentlabel, $Text_Progress & ': ' & Round($percent, 1))
				GUICtrlSetData($linemin, $Text_LinesMin & ': ' & Round($currentline / $min, 1))
				GUICtrlSetData($newlines, $Text_NewAPs & ': ' & $AddAP & ' - ' & $Text_NewGIDs & ':' & $AddGID)
				GUICtrlSetData($minutes, $Text_Minutes & ': ' & Round($min, 1))
				GUICtrlSetData($linetotal, $Text_LineTotal & ': ' & $currentline & "/" & $totallines)
				GUICtrlSetData($estimatedtime, $Text_EstimatedTimeRemaining & ': ' & Round(($totallines / Round($currentline / $min, 1)) - $min, 1) & "/" & Round($totallines / Round($currentline / $min, 1), 1))
				_ReduceMemory()
				$currentline += 1
			WEnd
			$Loading = 0
		EndIf
	EndIf
	GUICtrlSetData($progressbar, 100)
	GUICtrlSetData($percentlabel, $Text_Progress & ': ' & $Text_Done)
	GUICtrlSetState($NsOk, $GUI_ENABLE)
EndFunc   ;==>_ImportOk

Func _WriteINI()
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_WriteINI()') ;#Debug Display
	;Get new order of columns to write back to INI
	$currentcolumn = StringSplit(_GUICtrlListView_GetColumnOrder($ListviewAPs), '|')
	;_ArrayDisplay($currentcolumn)
	For $c = 1 To $currentcolumn[0]
		If $column_Line = $currentcolumn[$c] Then $save_column_Line = $c - 1
		If $column_Active = $currentcolumn[$c] Then $save_column_Active = $c - 1
		If $column_SSID = $currentcolumn[$c] Then $save_column_SSID = $c - 1
		If $column_BSSID = $currentcolumn[$c] Then $save_column_BSSID = $c - 1
		If $column_MANUF = $currentcolumn[$c] Then $save_column_MANUF = $c - 1
		If $column_Signal = $currentcolumn[$c] Then $save_column_Signal = $c - 1
		If $column_Authentication = $currentcolumn[$c] Then $save_column_Authentication = $c - 1
		If $column_Encryption = $currentcolumn[$c] Then $save_column_Encryption = $c - 1
		If $column_RadioType = $currentcolumn[$c] Then $save_column_RadioType = $c - 1
		If $column_Channel = $currentcolumn[$c] Then $save_column_Channel = $c - 1
		If $column_Latitude = $currentcolumn[$c] Then $save_column_Latitude = $c - 1
		If $column_Longitude = $currentcolumn[$c] Then $save_column_Longitude = $c - 1
		If $column_LatitudeDMS = $currentcolumn[$c] Then $save_column_LatitudeDMS = $c - 1
		If $column_LongitudeDMS = $currentcolumn[$c] Then $save_column_LongitudeDMS = $c - 1
		If $column_LatitudeDMM = $currentcolumn[$c] Then $save_column_LatitudeDMM = $c - 1
		If $column_LongitudeDMM = $currentcolumn[$c] Then $save_column_LongitudeDMM = $c - 1
		If $column_BasicTransferRates = $currentcolumn[$c] Then $save_column_BasicTransferRates = $c - 1
		If $column_OtherTransferRates = $currentcolumn[$c] Then $save_column_OtherTransferRates = $c - 1
		If $column_FirstActive = $currentcolumn[$c] Then $save_column_FirstActive = $c - 1
		If $column_LastActive = $currentcolumn[$c] Then $save_column_LastActive = $c - 1
		If $column_NetworkType = $currentcolumn[$c] Then $save_column_NetworkType = $c - 1
		If $column_Label = $currentcolumn[$c] Then $save_column_Label = $c - 1
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
	IniWrite($settings, "Vistumbler", "SplitPercent", $SplitPercent)
	IniWrite($settings, "Vistumbler", "SplitHeightPercent", $SplitHeightPercent)
	IniWrite($settings, "Vistumbler", "ComPort", $ComPort)
	IniWrite($settings, "Vistumbler", "Baud", $BAUD)
	IniWrite($settings, "Vistumbler", "Sleeptime", $RefreshLoopTime)
	IniWrite($settings, "Vistumbler", "AutoSortTime", $SortTime)
	IniWrite($settings, "Vistumbler", "AutoSort", $AutoSort)
	IniWrite($settings, "Vistumbler", "AutoSave", $AutoSave)
	IniWrite($settings, "Vistumbler", "AutoSaveDel", $AutoSaveDel)
	IniWrite($settings, "Vistumbler", "AutoSaveTime", $SaveTime)
	IniWrite($settings, "Vistumbler", "SortCombo", $SortBy)
	IniWrite($settings, "Vistumbler", "AscDecDefault", $SortDirection)
	IniWrite($settings, "Vistumbler", "NewAP_Sound", $new_AP_sound)
	IniWrite($settings, "Vistumbler", "Error_Sound", $error_sound)
	IniWrite($settings, "Vistumbler", "NewApPosistion", $AddDirection)
	IniWrite($settings, "Vistumbler", "BackgroundColor", $BackgroundColor)
	IniWrite($settings, "Vistumbler", "ControlBackgroundColor", $ControlBackgroundColor)
	IniWrite($settings, "Vistumbler", "TextColor", $TextColor)
	IniWrite($settings, "Vistumbler", "Language", $DefaultLanguage)
	IniWrite($settings, "Vistumbler", "UseNetcomm", $UseNetcomm)
	IniWrite($settings, "Vistumbler", "RefreshTime", $RefreshTime)
	IniWrite($settings, "Vistumbler", "ConnectToButton", $ConnectToButton)
	IniWrite($settings, "Vistumbler", 'MapOpen', $MapOpen)
	IniWrite($settings, 'Vistumbler', 'MapWEP', $MapWEP)
	IniWrite($settings, 'Vistumbler', 'MapSec', $MapSec)
	IniWrite($settings, 'Vistumbler', 'ShowTrack', $ShowTrack)
	IniWrite($settings, 'Vistumbler', 'Debug', $Debug)
	IniWrite($settings, 'Vistumbler', 'GPSformat', $GPSformat)
	IniWrite($settings, 'Vistumbler', 'PhilsGraphURL', $PhilsGraphURL)
	IniWrite($settings, 'Vistumbler', 'PhilsWdbURL', $PhilsWdbURL)
	IniWrite($settings, 'Vistumbler', 'AutoKML', $AutoKML)
	IniWrite($settings, 'Vistumbler', 'UseLocalKmlImagesOnExport', $UseLocalKmlImagesOnExport)
	IniWrite($settings, 'Vistumbler', 'GraphDeadTime', $GraphDeadTime)
	IniWrite($settings, "Vistumbler", 'PlaySoundOnNewAP', $SoundOnAP)
	IniWrite($settings, "Vistumbler", 'SpeakSignal', $SpeakSignal)
	IniWrite($settings, "Vistumbler", 'SpeakSigSayPecent', $SpeakSigSayPecent)
	IniWrite($settings, "Vistumbler", 'SpeakSigTime', $SpeakSigTime)
	IniWrite($settings, "Vistumbler", 'SpeakType', $SpeakType)
	IniWrite($settings, "Vistumbler", 'SaveGpsWithNoAps', $SaveGpsWithNoAps)
	
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
	
	IniWrite($settings, 'WindowPositions', 'VistumblerState', $VistumblerState)
	IniWrite($settings, 'WindowPositions', 'VistumblerPosition', $VistumblerPosition)
	IniWrite($settings, 'WindowPositions', 'CompassPosition', $CompassPosition)
	IniWrite($settings, 'WindowPositions', 'GpsDetailsPosition', $GpsDetailsPosition)

	IniWrite($settings, "Columns", "Column_Line", $save_column_Line)
	IniWrite($settings, "Columns", "Column_Active", $save_column_Active)
	IniWrite($settings, "Columns", "Column_SSID", $save_column_SSID)
	IniWrite($settings, "Columns", "Column_BSSID", $save_column_BSSID)
	IniWrite($settings, "Columns", "Column_Manufacturer", $save_column_MANUF)
	IniWrite($settings, "Columns", "Column_Signal", $save_column_Signal)
	IniWrite($settings, "Columns", "Column_Authentication", $save_column_Authentication)
	IniWrite($settings, "Columns", "Column_Encryption", $save_column_Encryption)
	IniWrite($settings, "Columns", "Column_RadioType", $save_column_RadioType)
	IniWrite($settings, "Columns", "Column_Channel", $save_column_Channel)
	IniWrite($settings, "Columns", "Column_Latitude", $save_column_Latitude)
	IniWrite($settings, "Columns", "Column_Longitude", $save_column_Longitude)
	IniWrite($settings, "Columns", "Column_LatitudeDMS", $save_column_LatitudeDMS)
	IniWrite($settings, "Columns", "Column_LongitudeDMS", $save_column_LongitudeDMS)
	IniWrite($settings, "Columns", "Column_LatitudeDMM", $save_column_LatitudeDMM)
	IniWrite($settings, "Columns", "Column_LongitudeDMM", $save_column_LongitudeDMM)
	IniWrite($settings, "Columns", "Column_BasicTransferRates", $save_column_BasicTransferRates)
	IniWrite($settings, "Columns", "Column_OtherTransferRates", $save_column_OtherTransferRates)
	IniWrite($settings, "Columns", "Column_FirstActive", $save_column_FirstActive)
	IniWrite($settings, "Columns", "Column_LastActive", $save_column_LastActive)
	IniWrite($settings, "Columns", "Column_NetworkType", $save_column_NetworkType)
	IniWrite($settings, "Columns", "Column_Label", $save_column_Label)
	
	IniWrite($settings, "Column_Width", "Column_Line", _GUICtrlListView_GetColumnWidth($ListviewAPs, $column_Line - 0))
	IniWrite($settings, "Column_Width", "Column_Active", _GUICtrlListView_GetColumnWidth($ListviewAPs, $column_Active - 0))
	IniWrite($settings, "Column_Width", "Column_SSID", _GUICtrlListView_GetColumnWidth($ListviewAPs, $column_SSID - 0))
	IniWrite($settings, "Column_Width", "Column_BSSID", _GUICtrlListView_GetColumnWidth($ListviewAPs, $column_BSSID - 0))
	IniWrite($settings, "Column_Width", "Column_Manufacturer", _GUICtrlListView_GetColumnWidth($ListviewAPs, $column_MANUF - 0))
	IniWrite($settings, "Column_Width", "Column_Signal", _GUICtrlListView_GetColumnWidth($ListviewAPs, $column_Signal - 0))
	IniWrite($settings, "Column_Width", "Column_Authentication", _GUICtrlListView_GetColumnWidth($ListviewAPs, $column_Authentication - 0))
	IniWrite($settings, "Column_Width", "Column_Encryption", _GUICtrlListView_GetColumnWidth($ListviewAPs, $column_Encryption - 0))
	IniWrite($settings, "Column_Width", "Column_RadioType", _GUICtrlListView_GetColumnWidth($ListviewAPs, $column_RadioType - 0))
	IniWrite($settings, "Column_Width", "Column_Channel", _GUICtrlListView_GetColumnWidth($ListviewAPs, $column_Channel - 0))
	IniWrite($settings, "Column_Width", "Column_Latitude", _GUICtrlListView_GetColumnWidth($ListviewAPs, $column_Latitude - 0))
	IniWrite($settings, "Column_Width", "Column_Longitude", _GUICtrlListView_GetColumnWidth($ListviewAPs, $column_Longitude - 0))
	IniWrite($settings, "Column_Width", "Column_LatitudeDMS", _GUICtrlListView_GetColumnWidth($ListviewAPs, $column_LatitudeDMS - 0))
	IniWrite($settings, "Column_Width", "Column_LongitudeDMS", _GUICtrlListView_GetColumnWidth($ListviewAPs, $column_LongitudeDMS - 0))
	IniWrite($settings, "Column_Width", "Column_LatitudeDMM", _GUICtrlListView_GetColumnWidth($ListviewAPs, $column_LatitudeDMM - 0))
	IniWrite($settings, "Column_Width", "Column_LongitudeDMM", _GUICtrlListView_GetColumnWidth($ListviewAPs, $column_LongitudeDMM - 0))
	IniWrite($settings, "Column_Width", "Column_BasicTransferRates", _GUICtrlListView_GetColumnWidth($ListviewAPs, $column_BasicTransferRates - 0))
	IniWrite($settings, "Column_Width", "Column_OtherTransferRates", _GUICtrlListView_GetColumnWidth($ListviewAPs, $column_OtherTransferRates - 0))
	IniWrite($settings, "Column_Width", "Column_FirstActive", _GUICtrlListView_GetColumnWidth($ListviewAPs, $column_FirstActive - 0))
	IniWrite($settings, "Column_Width", "Column_LastActive", _GUICtrlListView_GetColumnWidth($ListviewAPs, $column_LastActive - 0))
	IniWrite($settings, "Column_Width", "Column_NetworkType", _GUICtrlListView_GetColumnWidth($ListviewAPs, $column_NetworkType - 0))
	IniWrite($settings, "Column_Width", "Column_Label", _GUICtrlListView_GetColumnWidth($ListviewAPs, $column_Label - 0))

	IniWrite($settings, "Column_Names", "Column_Line", $Column_Names_Line)
	IniWrite($settings, "Column_Names", "Column_Active", $Column_Names_Active)
	IniWrite($settings, "Column_Names", "Column_SSID", $Column_Names_SSID)
	IniWrite($settings, "Column_Names", "Column_BSSID", $Column_Names_BSSID)
	IniWrite($settings, "Column_Names", "Column_Manufacturer", $Column_Names_MANUF)
	IniWrite($settings, "Column_Names", "Column_Signal", $Column_Names_Signal)
	IniWrite($settings, "Column_Names", "Column_Authentication", $Column_Names_Authentication)
	IniWrite($settings, "Column_Names", "Column_Encryption", $Column_Names_Encryption)
	IniWrite($settings, "Column_Names", "Column_RadioType", $Column_Names_RadioType)
	IniWrite($settings, "Column_Names", "Column_Channel", $Column_Names_Channel)
	IniWrite($settings, "Column_Names", "Column_Latitude", $Column_Names_Latitude)
	IniWrite($settings, "Column_Names", "Column_Longitude", $Column_Names_Longitude)
	IniWrite($settings, "Column_Names", "Column_LatitudeDMS", $Column_Names_LatitudeDMS)
	IniWrite($settings, "Column_Names", "Column_LongitudeDMS", $Column_Names_LongitudeDMS)
	IniWrite($settings, "Column_Names", "Column_LatitudeDMM", $Column_Names_LatitudeDMM)
	IniWrite($settings, "Column_Names", "Column_LongitudeDMM", $Column_Names_LongitudeDMM)
	IniWrite($settings, "Column_Names", "Column_BasicTransferRates", $Column_Names_BasicTransferRates)
	IniWrite($settings, "Column_Names", "Column_OtherTransferRates", $Column_Names_OtherTransferRates)
	IniWrite($settings, "Column_Names", "Column_FirstActive", $Column_Names_FirstActive)
	IniWrite($settings, "Column_Names", "Column_LastActive", $Column_Names_LastActive)
	IniWrite($settings, "Column_Names", "Column_NetworkType", $Column_Names_NetworkType)
	IniWrite($settings, "Column_Names", "Column_Label", $Column_Names_Label)
	
	IniWrite($settings, "SearchWords", "SSID", $SearchWord_SSID)
	IniWrite($settings, "SearchWords", "BSSID", $SearchWord_BSSID)
	IniWrite($settings, "SearchWords", "NetworkType", $SearchWord_NetworkType)
	IniWrite($settings, "SearchWords", "Authentication", $SearchWord_Authentication)
	IniWrite($settings, "SearchWords", "Encryption", $SearchWord_Encryption)
	IniWrite($settings, "SearchWords", "Signal", $SearchWord_Signal)
	IniWrite($settings, "SearchWords", "RadioType", $SearchWord_RadioType)
	IniWrite($settings, "SearchWords", "Channel", $SearchWord_Channel)
	IniWrite($settings, "SearchWords", "BasicRates", $SearchWord_BasicRates)
	IniWrite($settings, "SearchWords", "OtherRates", $SearchWord_OtherRates)
	IniWrite($settings, "SearchWords", "Open", $SearchWord_Open)
	IniWrite($settings, "SearchWords", "None", $SearchWord_None)
	IniWrite($settings, "SearchWords", "WEP", $SearchWord_Wep)
	IniWrite($settings, "SearchWords", "Infrastructure", $SearchWord_Infrastructure)
	IniWrite($settings, "SearchWords", "Adhoc", $SearchWord_Adhoc)
	
	IniWrite($settings, "GuiText", "Ok", $Text_Ok)
	IniWrite($settings, "GuiText", "Cancel", $Text_Cancel)
	IniWrite($settings, "GuiText", "Apply", $Text_Apply)
	IniWrite($settings, "GuiText", "Browse", $Text_Browse)
	IniWrite($settings, "GuiText", "File", $Text_File)
	IniWrite($settings, "GuiText", "SaveAsTXT", $Text_SaveAsTXT)
	IniWrite($settings, "GuiText", "SaveAsVS1", $Text_SaveAsVS1)
	IniWrite($settings, "GuiText", "SaveAsVSZ", $Text_SaveAsVSZ)
	IniWrite($settings, "GuiText", "ImportFromTXT", $Text_ImportFromTXT)
	IniWrite($settings, "GuiText", "ImportFromVSZ", $Text_ImportFromVSZ)
	IniWrite($settings, "GuiText", "Exit", $Text_Exit)
	IniWrite($settings, "GuiText", "Edit", $Text_Edit)
	IniWrite($settings, "GuiText", "ClearAll", $Text_ClearAll)
	IniWrite($settings, "GuiText", "Cut", $Text_Cut)
	IniWrite($settings, "GuiText", "Copy", $Text_Copy)
	IniWrite($settings, "GuiText", "Paste", $Text_Paste)
	IniWrite($settings, "GuiText", "Delete", $Text_Delete)
	IniWrite($settings, "GuiText", "Select", $Text_Select)
	IniWrite($settings, "GuiText", "SelectAll", $Text_SelectAll)
	IniWrite($settings, "GuiText", "Options", $Text_Options)
	IniWrite($settings, "GuiText", "AutoSort", $Text_AutoSort)
	IniWrite($settings, "GuiText", "SortTree", $Text_SortTree)
	IniWrite($settings, "GuiText", "PlaySound", $Text_PlaySound)
	IniWrite($settings, "GuiText", "AddAPsToTop", $Text_AddAPsToTop)
	IniWrite($settings, "GuiText", "Extra", $Text_Extra)
	IniWrite($settings, "GuiText", "ScanAPs", $Text_ScanAPs)
	IniWrite($settings, "GuiText", "StopScanAps", $Text_StopScanAps)
	IniWrite($settings, "GuiText", "UseGPS", $Text_UseGPS)
	IniWrite($settings, "GuiText", "StopGPS", $Text_StopGPS)
	IniWrite($settings, "GuiText", "Settings", $Text_Settings)
	IniWrite($settings, "GuiText", "GpsSettings", $Text_GpsSettings)
	IniWrite($settings, "GuiText", "SetLanguage", $Text_SetLanguage)
	IniWrite($settings, "GuiText", "SetSearchWords", $Text_SetSearchWords)
	IniWrite($settings, "GuiText", "Export", $Text_Export)
	IniWrite($settings, "GuiText", "ExportToKML", $Text_ExportToKML)
	IniWrite($settings, "GuiText", "ExportToTXT", $Text_ExportToTXT)
	IniWrite($settings, "GuiText", "ExportToNS1", $Text_ExportToNS1)
	IniWrite($settings, "GuiText", "ExportToVS1", $Text_ExportToVS1)
	IniWrite($settings, "GuiText", "PhilsPHPgraph", $Text_PhilsPHPgraph)
	IniWrite($settings, "GuiText", "PhilsWDB", $Text_PhilsWDB)
	IniWrite($settings, "GuiText", "RefreshLoopTime", $Text_RefreshLoopTime)
	IniWrite($settings, "GuiText", "ActualLoopTime", $Text_ActualLoopTime)
	IniWrite($settings, "GuiText", "Longitude", $Text_Longitude)
	IniWrite($settings, "GuiText", "Latitude", $Text_Latitude)
	IniWrite($settings, "GuiText", "ActiveAPs", $Text_ActiveAPs)
	IniWrite($settings, "GuiText", "Graph1", $Text_Graph1)
	IniWrite($settings, "GuiText", "Graph2", $Text_Graph2)
	IniWrite($settings, "GuiText", "NoGraph", $Text_NoGraph)
	IniWrite($settings, 'GuiText', 'SetMacLabel', $Text_SetMacLabel)
	IniWrite($settings, 'GuiText', 'SetMacManu', $Text_SetMacManu)
	IniWrite($settings, 'GuiText', 'Active', $Text_Active)
	IniWrite($settings, 'GuiText', 'Dead', $Text_Dead)
	IniWrite($settings, 'GuiText', 'AddNewLabel', $Text_AddNewLabel)
	IniWrite($settings, 'GuiText', 'RemoveLabel', $Text_RemoveLabel)
	IniWrite($settings, 'GuiText', 'EditLabel', $Text_EditLabel)
	IniWrite($settings, 'GuiText', 'AddNewMan', $Text_AddNewMan)
	IniWrite($settings, 'GuiText', 'RemoveMan', $Text_RemoveMan)
	IniWrite($settings, 'GuiText', 'EditMan', $Text_EditMan)
	IniWrite($settings, 'GuiText', 'NewMac', $Text_NewMac)
	IniWrite($settings, 'GuiText', 'NewMan', $Text_NewMan)
	IniWrite($settings, 'GuiText', 'NewLabel', $Text_NewLabel)
	IniWrite($settings, 'GuiText', 'Save', $Text_Save)
	IniWrite($settings, 'GuiText', 'SaveQuestion', $Text_SaveQuestion)
	IniWrite($settings, 'GuiText', 'GpsDetails', $Text_GpsDetails)
	IniWrite($settings, 'GuiText', 'GpsCompass', $Text_GpsCompass)
	IniWrite($settings, 'GuiText', 'Quality', $Text_Quality)
	IniWrite($settings, 'GuiText', 'Time', $Text_Time)
	IniWrite($settings, 'GuiText', 'NumberOfSatalites', $Text_NumberOfSatalites)
	IniWrite($settings, 'GuiText', 'HorizontalDilutionPosition', $Text_HorizontalDilutionPosition)
	IniWrite($settings, 'GuiText', 'Altitude', $Text_Altitude)
	IniWrite($settings, 'GuiText', 'HeightOfGeoid', $Text_HeightOfGeoid)
	IniWrite($settings, 'GuiText', 'Status', $Text_Status)
	IniWrite($settings, 'GuiText', 'Date', $Text_Date)
	IniWrite($settings, 'GuiText', 'SpeedInKnots', $Text_SpeedInKnots)
	IniWrite($settings, 'GuiText', 'SpeedInMPH', $Text_SpeedInMPH)
	IniWrite($settings, 'GuiText', 'SpeedInKmh', $Text_SpeedInKmh)
	IniWrite($settings, 'GuiText', 'TrackAngle', $Text_TrackAngle)
	IniWrite($settings, 'GuiText', 'Close', $Text_Close)
	IniWrite($settings, 'GuiText', 'ConnectToWindowName', $Text_ConnectToWindowName)
	IniWrite($settings, 'GuiText', 'RefreshingNetworks', $Text_RefreshNetworks)
	IniWrite($settings, 'GuiText', 'Start', $Text_Start)
	IniWrite($settings, 'GuiText', 'Stop', $Text_Stop)
	IniWrite($settings, 'GuiText', 'ConnectToWindowTitle', $Text_ConnectToWindowTitle)
	IniWrite($settings, 'GuiText', 'RefreshTime', $Text_RefreshTime)
	IniWrite($settings, 'GuiText', 'SetColumnWidths', $Text_SetColumnWidths)
	IniWrite($settings, 'GuiText', 'Enable', $Text_Enable)
	IniWrite($settings, 'GuiText', 'Disable', $Text_Disable)
	IniWrite($settings, 'GuiText', 'Checked', $Text_Checked)
	IniWrite($settings, 'GuiText', 'UnChecked', $Text_UnChecked)
	IniWrite($settings, 'GuiText', 'Unknown', $Text_Unknown)
	IniWrite($settings, 'GuiText', 'Restart', $Text_Restart)
	IniWrite($settings, 'GuiText', 'RestartMsg', $Text_RestartMsg)
	IniWrite($settings, 'GuiText', 'NoSignalHistory', $Text_NoSignalHistory)
	IniWrite($settings, 'GuiText', 'NoApSelected', $Text_NoApSelected)
	IniWrite($settings, 'GuiText', 'UseNetcomm', $Text_UseNetcomm)
	IniWrite($settings, 'GuiText', 'UseCommMG', $Text_UseCommMG)
	IniWrite($settings, 'GuiText', 'SignalHistory', $Text_SignalHistory)
	IniWrite($settings, 'GuiText', 'AutoSortEvery', $Text_AutoSortEvery)
	IniWrite($settings, 'GuiText', 'Seconds', $Text_Seconds)
	IniWrite($settings, 'GuiText', 'Ascending', $Text_Ascending)
	IniWrite($settings, 'GuiText', 'Decending', $Text_Decending)
	IniWrite($settings, 'GuiText', 'AutoSave', $Text_AutoSave)
	IniWrite($settings, 'GuiText', 'AutoSaveEvery', $Text_AutoSaveEvery)
	IniWrite($settings, 'GuiText', 'DelAutoSaveOnExit', $Text_DelAutoSaveOnExit)
	IniWrite($settings, 'GuiText', 'OpenSaveFolder', $Text_OpenSaveFolder)
	IniWrite($settings, 'GuiText', 'SortBy', $Text_SortBy)
	IniWrite($settings, 'GuiText', 'SortDirection', $Text_SortDirection)
	IniWrite($settings, 'GuiText', 'Auto', $Text_Auto)
	IniWrite($settings, 'GuiText', 'Misc', $Text_Misc)
	IniWrite($settings, 'GuiText', 'GPS', $Text_Gps)
	IniWrite($settings, 'GuiText', 'Labels', $Text_Labels)
	IniWrite($settings, 'GuiText', 'Manufacturers', $Text_Manufacturers)
	IniWrite($settings, 'GuiText', 'Columns', $Text_Columns)
	IniWrite($settings, 'GuiText', 'Language', $Text_Language)
	IniWrite($settings, 'GuiText', 'SearchWords', $Text_SearchWords)
	IniWrite($settings, 'GuiText', 'VistumblerSettings', $Text_VistumblerSettings)
	IniWrite($settings, 'GuiText', 'LanguageAuthor', $Text_LanguageAuthor)
	IniWrite($settings, 'GuiText', 'LanguageDate', $Text_LanguageDate)
	IniWrite($settings, 'GuiText', 'LanguageDescription', $Text_LanguageDescription)
	IniWrite($settings, 'GuiText', 'Description', $Text_Description)
	IniWrite($settings, 'GuiText', 'Progress', $Text_Progress)
	IniWrite($settings, 'GuiText', 'LinesMin', $Text_LinesMin)
	IniWrite($settings, 'GuiText', 'NewAPs', $Text_NewAPs)
	IniWrite($settings, 'GuiText', 'NewGIDs', $Text_NewGIDs)
	IniWrite($settings, 'GuiText', 'Minutes', $Text_Minutes)
	IniWrite($settings, 'GuiText', 'LineTotal', $Text_LineTotal)
	IniWrite($settings, 'GuiText', 'EstimatedTimeRemaining', $Text_EstimatedTimeRemaining)
	IniWrite($settings, 'GuiText', 'Ready', $Text_Ready)
	IniWrite($settings, 'GuiText', 'Done', $Text_Done)
	IniWrite($settings, 'GuiText', 'VistumblerSaveDirectory', $Text_VistumblerSaveDirectory)
	IniWrite($settings, 'GuiText', 'VistumblerAutoSaveDirectory', $Text_VistumblerAutoSaveDirectory)
	IniWrite($settings, 'GuiText', 'VistumblerKmlSaveDirectory', $Text_VistumblerKmlSaveDirectory)
	IniWrite($settings, 'GuiText', 'BackgroundColor', $Text_BackgroundColor)
	IniWrite($settings, 'GuiText', 'ControlColor', $Text_ControlColor)
	IniWrite($settings, 'GuiText', 'BgFontColor', $Text_BgFontColor)
	IniWrite($settings, 'GuiText', 'ConFontColor', $Text_ConFontColor)
	IniWrite($settings, 'GuiText', 'NetshMsg', $Text_NetshMsg)
	IniWrite($settings, 'GuiText', 'PHPgraphing', $Text_PHPgraphing)
	IniWrite($settings, 'GuiText', 'ComInterface', $Text_ComInterface)
	IniWrite($settings, 'GuiText', 'ComSettings', $Text_ComSettings)
	IniWrite($settings, 'GuiText', 'Com', $Text_Com)
	IniWrite($settings, 'GuiText', 'Baud', $Text_Baud)
	IniWrite($settings, 'GuiText', 'GPSFormat', $Text_GPSFormat)
	IniWrite($settings, 'GuiText', 'HideOtherGpsColumns', $Text_HideOtherGpsColumns)
	IniWrite($settings, 'GuiText', 'ImportLanguageFile', $Text_ImportLanguageFile)
	IniWrite($settings, 'GuiText', 'AutoKml', $Text_AutoKml)
	IniWrite($settings, 'GuiText', 'GoogleEarthEXE', $Text_GoogleEarthEXE)
	IniWrite($settings, 'GuiText', 'AutoSaveKmlEvery', $Text_AutoSaveKmlEvery)
	IniWrite($settings, 'GuiText', 'SavedAs', $Text_SavedAs)
	IniWrite($settings, 'GuiText', 'Overwrite', $Text_Overwrite)
	IniWrite($settings, 'GuiText', 'InstallNetcommOCX', $Text_InstallNetcommOCX)
	IniWrite($settings, 'GuiText', 'NoFileSaved', $Text_NoFileSaved)
	IniWrite($settings, 'GuiText', 'NoApsWithGps', $Text_NoApsWithGps)
	IniWrite($settings, 'GuiText', 'MacExistsOverwriteIt', $Text_MacExistsOverwriteIt)
	IniWrite($settings, 'GuiText', 'SavingLine', $Text_SavingLine)
	IniWrite($settings, 'GuiText', 'DisplayDebug', $Text_DisplayDebug)
	IniWrite($settings, 'GuiText', 'GraphDeadTime', $Text_GraphDeadTime)
	IniWrite($settings, 'GuiText', 'OpenKmlNetLink', $Text_OpenKmlNetLink)
	IniWrite($settings, 'GuiText', 'ActiveRefreshTime', $Text_ActiveRefreshTime)
	IniWrite($settings, 'GuiText', 'DeadRefreshTime', $Text_DeadRefreshTime)
	IniWrite($settings, 'GuiText', 'GpsRefrshTime', $Text_GpsRefrshTime)
	IniWrite($settings, 'GuiText', 'FlyToSettings', $Text_FlyToSettings)
	IniWrite($settings, 'GuiText', 'FlyToCurrentGps', $Text_FlyToCurrentGps)
	IniWrite($settings, 'GuiText', 'AltitudeMode', $Text_AltitudeMode)
	IniWrite($settings, 'GuiText', 'Range', $Text_Range)
	IniWrite($settings, 'GuiText', 'Heading', $Text_Heading)
	IniWrite($settings, 'GuiText', 'Tilt', $Text_Tilt)
	IniWrite($settings, 'GuiText', 'AutoOpenNetworkLink', $Text_AutoOpenNetworkLink)
	IniWrite($settings, 'GuiText', 'SpeakSignal', $Text_SpeakSignal)
	IniWrite($settings, 'GuiText', 'SpeakUseVisSounds', $Text_SpeakUseVisSounds)
	IniWrite($settings, 'GuiText', 'SpeakUseSapi', $Text_SpeakUseSapi)
	IniWrite($settings, 'GuiText', 'SpeakSayPercent', $Text_SpeakSayPercent)
	IniWrite($settings, 'GuiText', 'GpsTrackTime', $Text_GpsTrackTime)
EndFunc   ;==>_WriteINI

;-------------------------------------------------------------------------------------------------------------------------------
;                                                       GOOGLE EARTH SAVE FUNCTIONS
;-------------------------------------------------------------------------------------------------------------------------------

Func SaveToKML()
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, 'SaveToKML()') ;#Debug Display
	Opt("GUIOnEventMode", 0)
	$ExportKMLGUI = GUICreate("Export KML", 263, 143)
	GUISetBkColor($BackgroundColor)
	$GUI_ExportKML_MapOpen = GUICtrlCreateCheckbox("Map Open Networks", 15, 15, 240, 15)
	If $MapOpen = 1 Then GUICtrlSetState($GUI_ExportKML_MapOpen, $GUI_CHECKED)
	$GUI_ExportKML_MapWEP = GUICtrlCreateCheckbox("Map WEP Networks", 15, 35, 240, 15)
	If $MapWEP = 1 Then GUICtrlSetState($GUI_ExportKML_MapWEP, $GUI_CHECKED)
	$GUI_ExportKML_MapSec = GUICtrlCreateCheckbox("Map Secure Networks", 15, 55, 240, 15)
	If $MapSec = 1 Then GUICtrlSetState($GUI_ExportKML_MapSec, $GUI_CHECKED)
	$GUI_ExportKML_DrawTrack = GUICtrlCreateCheckbox("Draw Track", 15, 75, 240, 15)
	If $ShowTrack = 1 Then GUICtrlSetState($GUI_ExportKML_DrawTrack, $GUI_CHECKED)
	$GUI_ExportKML_UseLocalImages = GUICtrlCreateCheckbox("Use Local Images", 15, 95, 240, 15)
	If $UseLocalKmlImagesOnExport = 1 Then GUICtrlSetState($GUI_ExportKML_UseLocalImages, $GUI_CHECKED)
	$GUI_ExportKML_OK = GUICtrlCreateButton("Ok", 40, 115, 81, 25, 0)
	$GUI_ExportKML_Cancel = GUICtrlCreateButton("Cancel", 139, 115, 81, 25, 0)
	GUISetState(@SW_SHOW)

	While 1
		$nMsg = GUIGetMsg()
		Switch $nMsg
			Case $GUI_EVENT_CLOSE
				GUIDelete($ExportKMLGUI)
				ExitLoop
			Case $GUI_ExportKML_Cancel
				GUIDelete($ExportKMLGUI)
				ExitLoop
			Case $GUI_ExportKML_OK
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
				If GUICtrlRead($GUI_ExportKML_DrawTrack) = 1 Then
					$ShowTrack = 1
				Else
					$ShowTrack = 0
				EndIf
				If GUICtrlRead($GUI_ExportKML_UseLocalImages) = 1 Then
					$UseLocalKmlImagesOnExport = 1
				Else
					$UseLocalKmlImagesOnExport = 0
				EndIf
				GUIDelete($ExportKMLGUI)
				DirCreate($SaveDirKml)
				$timestamp = @MON & '-' & @MDAY & '-' & @YEAR & ' ' & @HOUR & '-' & @MIN & '-' & @SEC
				$kml = FileSaveDialog("Google Earth Output File", $SaveDirKml, 'Google Earth (*.kml)', '', $timestamp & '.kml')
				If Not @error Then
					$savekml = SaveKML($kml, $UseLocalKmlImagesOnExport, $MapOpen, $MapWEP, $MapSec, $ShowTrack)
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
EndFunc   ;==>SaveToKML

Func SaveKML($kml, $KmlUseLocalImages = 1, $MapOpenAPs = 1, $MapWepAps = 1, $MapSecAps = 1, $GpsTrack = 0)
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, 'SaveKML()') ;#Debug Display
	If StringInStr($kml, '.kml') = 0 Then $kml = $kml & '.kml'
	FileDelete($kml)
	$file = '<?xml version="1.0" encoding="utf-8"?>' & @CRLF _
			 & '<kml xmlns="http://earth.google.com/kml/2.0">' & @CRLF _
			 & '<Document>' & @CRLF _
			 & '<Style id="secureStyle">' & @CRLF _
			 & '<IconStyle>' & @CRLF _
			 & '<scale>.5</scale>' & @CRLF _
			 & '<Icon>' & @CRLF
	If $KmlUseLocalImages = 1 Then
		$file &= '<href>' & $ImageDir & 'secure.png</href>' & @CRLF
	Else
		$file &= '<href>http://www.vistumbler.net/images/program-images/secure.png</href>' & @CRLF
	EndIf
	$file &= '</Icon>' & @CRLF _
			 & '</IconStyle>' & @CRLF _
			 & '</Style>' & @CRLF _
			 & '<Style id="wepStyle">' & @CRLF _
			 & '<IconStyle>' & @CRLF _
			 & '<scale>.5</scale>' & @CRLF _
			 & '<Icon>' & @CRLF
	If $KmlUseLocalImages = 1 Then
		$file &= '<href>' & $ImageDir & 'secure-wep.png</href>' & @CRLF
	Else
		$file &= '<href>http://www.vistumbler.net/images/program-images/secure-wep.png</href>' & @CRLF
	EndIf
	$file &= '</Icon>' & @CRLF _
			 & '</IconStyle>' & @CRLF _
			 & '</Style>' & @CRLF _
			 & '<Style id="openStyle">' & @CRLF _
			 & '<IconStyle>' & @CRLF _
			 & '<scale>.5</scale>' & @CRLF _
			 & '<Icon>' & @CRLF
	If $KmlUseLocalImages = 1 Then
		$file &= '<href>' & $ImageDir & 'open.png</href>' & @CRLF
	Else
		$file &= '<href>http://www.vistumbler.net/images/program-images/open.png</href>' & @CRLF
	EndIf
	$file &= '</Icon>' & @CRLF _
			 & '</IconStyle>' & @CRLF _
			 & '</Style>' & @CRLF _
			 & '<Style id="Location">' & @CRLF _
			 & '<LineStyle>' & @CRLF _
			 & '<color>7f0000ff</color>' & @CRLF _
			 & '<width>4</width>' & @CRLF _
			 & '</LineStyle>' & @CRLF _
			 & '</Style>' & @CRLF _
			 & '<Folder>' & @CRLF _
			 & '<description>' & $Script_Name & ' - By ' & $Script_Author & '</description>' & @CRLF _
			 & '<name>' & $Script_Name & ' ' & $version & '</name>' & @CRLF _
			 & '<Folder>' & @CRLF _
			 & '<name>Access Points</name>' & @CRLF _
			 & '<description>Access points found</description>' & @CRLF
	$FoundApWithGps = 0
	For $i = 1 To $DataArray_BSSID[0]
		GUICtrlSetData($msgdisplay, $Text_SavingLine & ' ' & $i & ' / ' & $DataArray_BSSID[0])
		If StringReplace(StringReplace($DataArray_Lat[$i], 'N ', ''), 'S ', '') <> '0.0000' And StringReplace(StringReplace($DataArray_Lon[$i], 'E ', ''), 'W ', '') <> '0.0000' Then
			If $DataArray_SecType[$i] = '1' Then ;If AP has the Open flag, add it to the Open folder
				If $MapOpenAPs = 1 Then
					$file &= '<Placemark>' & @CRLF _
							 & '<name></name>' & @CRLF _
							 & '<description><![CDATA[<b>' & $Column_Names_SSID & ': </b>' & $DataArray_SSID[$i] & '<br /><b>' & $Column_Names_BSSID & ': </b>' & $DataArray_BSSID[$i] & '<br /><b>' & $Column_Names_NetworkType & ': </b>' & $DataArray_NetType[$i] & '<br /><b>' & $Column_Names_RadioType & ': </b>' & $DataArray_Rad[$i] & '<br /><b>' & $Column_Names_Channel & ': </b>' & $DataArray_Chan[$i] & '<br /><b>' & $Column_Names_Authentication & ': </b>' & $DataArray_Auth[$i] & '<br /><b>' & $Column_Names_Encryption & ': </b>' & $DataArray_Encr[$i] & '<br /><b>' & $Column_Names_BasicTransferRates & ': </b>' & $DataArray_BtX[$i] & '<br /><b>' & $Column_Names_OtherTransferRates & ': </b>' & $DataArray_OtX[$i] & '<br /><b>' & $Column_Names_FirstActive & ': </b>' & $DataArray_FirstTime[$i] & '<br /><b>' & $Column_Names_LastActive & ': </b>' & $DataArray_LastTime[$i] & '<br /><b>' & $Column_Names_Latitude & ': </b>' & _Format_GPS_DMM_to_DDD($DataArray_Lat[$i]) & '<br /><b>' & $Column_Names_Longitude & ': </b>' & _Format_GPS_DMM_to_DDD($DataArray_Lon[$i]) & '<br /><b>' & $Column_Names_MANUF & ': </b>' & $DataArray_Manu[$i] & '<br /><b>' & $Text_SignalHistory & ': </b>' & $DataArray_SigHist[$i] & '<br />]]></description>' _
							 & '<styleUrl>#openStyle</styleUrl>' & @CRLF _
							 & '<Point>' & @CRLF _
							 & '<coordinates>' & StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($DataArray_Lon[$i]), 'W', '-'), 'E', ''), ' ', '') & ',' & StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($DataArray_Lat[$i]), 'S', '-'), 'N', ''), ' ', '') & ',0</coordinates>' & @CRLF _
							 & '</Point>' & @CRLF _
							 & '</Placemark>' & @CRLF
					$FoundApWithGps = 1
				EndIf
			ElseIf $DataArray_SecType[$i] = '2' Then ;If AP has the WEP flag, add it to the WEP folder
				If $MapWepAps = 1 Then
					$file &= '<Placemark>' & @CRLF _
							 & '<name></name>' & @CRLF _
							 & '<description><![CDATA[<b>' & $Column_Names_SSID & ': </b>' & $DataArray_SSID[$i] & '<br /><b>' & $Column_Names_BSSID & ': </b>' & $DataArray_BSSID[$i] & '<br /><b>' & $Column_Names_NetworkType & ': </b>' & $DataArray_NetType[$i] & '<br /><b>' & $Column_Names_RadioType & ': </b>' & $DataArray_Rad[$i] & '<br /><b>' & $Column_Names_Channel & ': </b>' & $DataArray_Chan[$i] & '<br /><b>' & $Column_Names_Authentication & ': </b>' & $DataArray_Auth[$i] & '<br /><b>' & $Column_Names_Encryption & ': </b>' & $DataArray_Encr[$i] & '<br /><b>' & $Column_Names_BasicTransferRates & ': </b>' & $DataArray_BtX[$i] & '<br /><b>' & $Column_Names_OtherTransferRates & ': </b>' & $DataArray_OtX[$i] & '<br /><b>' & $Column_Names_FirstActive & ': </b>' & $DataArray_FirstTime[$i] & '<br /><b>' & $Column_Names_LastActive & ': </b>' & $DataArray_LastTime[$i] & '<br /><b>' & $Column_Names_Latitude & ': </b>' & _Format_GPS_DMM_to_DDD($DataArray_Lat[$i]) & '<br /><b>' & $Column_Names_Longitude & ': </b>' & _Format_GPS_DMM_to_DDD($DataArray_Lon[$i]) & '<br /><b>' & $Column_Names_MANUF & ': </b>' & $DataArray_Manu[$i] & '<br /><b>' & $Text_SignalHistory & ': </b>' & $DataArray_SigHist[$i] & '<br />]]></description>' _
							 & '<styleUrl>#wepStyle</styleUrl>' & @CRLF _
							 & '<Point>' & @CRLF _
							 & '<coordinates>' & StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($DataArray_Lon[$i]), 'W', '-'), 'E', ''), ' ', '') & ',' & StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($DataArray_Lat[$i]), 'S', '-'), 'N', ''), ' ', '') & ',0</coordinates>' & @CRLF _
							 & '</Point>' & @CRLF _
							 & '</Placemark>' & @CRLF
					$FoundApWithGps = 1
				EndIf
			ElseIf $DataArray_SecType[$i] = '3' Then ;If AP has the Secure flag, add it to the Secure folder
				If $MapSecAps = 1 Then
					$file &= '<Placemark>' & @CRLF _
							 & '<name></name>' & @CRLF _
							 & '<description><![CDATA[<b>' & $Column_Names_SSID & ': </b>' & $DataArray_SSID[$i] & '<br /><b>' & $Column_Names_BSSID & ': </b>' & $DataArray_BSSID[$i] & '<br /><b>' & $Column_Names_NetworkType & ': </b>' & $DataArray_NetType[$i] & '<br /><b>' & $Column_Names_RadioType & ': </b>' & $DataArray_Rad[$i] & '<br /><b>' & $Column_Names_Channel & ': </b>' & $DataArray_Chan[$i] & '<br /><b>' & $Column_Names_Authentication & ': </b>' & $DataArray_Auth[$i] & '<br /><b>' & $Column_Names_Encryption & ': </b>' & $DataArray_Encr[$i] & '<br /><b>' & $Column_Names_BasicTransferRates & ': </b>' & $DataArray_BtX[$i] & '<br /><b>' & $Column_Names_OtherTransferRates & ': </b>' & $DataArray_OtX[$i] & '<br /><b>' & $Column_Names_FirstActive & ': </b>' & $DataArray_FirstTime[$i] & '<br /><b>' & $Column_Names_LastActive & ': </b>' & $DataArray_LastTime[$i] & '<br /><b>' & $Column_Names_Latitude & ': </b>' & _Format_GPS_DMM_to_DDD($DataArray_Lat[$i]) & '<br /><b>' & $Column_Names_Longitude & ': </b>' & _Format_GPS_DMM_to_DDD($DataArray_Lon[$i]) & '<br /><b>' & $Column_Names_MANUF & ': </b>' & $DataArray_Manu[$i] & '<br /><b>' & $Text_SignalHistory & ': </b>' & $DataArray_SigHist[$i] & '<br />]]></description>' _
							 & '<styleUrl>#secureStyle</styleUrl>' & @CRLF _
							 & '<Point>' & @CRLF _
							 & '<coordinates>' & StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($DataArray_Lon[$i]), 'W', '-'), 'E', ''), ' ', '') & ',' & StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($DataArray_Lat[$i]), 'S', '-'), 'N', ''), ' ', '') & ',0</coordinates>' & @CRLF _
							 & '</Point>' & @CRLF _
							 & '</Placemark>' & @CRLF
					$FoundApWithGps = 1
				EndIf
			EndIf
		EndIf
		_ReduceMemory()
	Next
	
	$file &= '</Folder>' & @CRLF
	
	If $GpsTrack = 1 Then
		$file &= '<Folder>' & @CRLF _
				 & '<Placemark>' & @CRLF _
				 & '<name>GPS Track</name>' & @CRLF _
				 & '<styleUrl>#Location</styleUrl>' & @CRLF _
				 & '<LineString>' & @CRLF _
				 & '<extrude>1</extrude>' & @CRLF _
				 & '<tessellate>1</tessellate>' & @CRLF _
				 & '<coordinates>' & @CRLF
		
		For $e = 1 To $GPSArray_ID[0]
			GUICtrlSetData($msgdisplay, 'Saving GPS Pos ' & $e & ' / ' & $GPSArray_ID[0])
			If $GPSArray_Lat[$e] <> 'N 0.0000' And $GPSArray_Lon[$e] <> 'E 0.0000' Then
				$file &= StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($GPSArray_Lon[$e]), 'W', '-'), 'E', ''), ' ', '') & ',' & StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($GPSArray_Lat[$e]), 'S', '-'), 'N', ''), ' ', '') & ',0' & @CRLF
				$FoundApWithGps = 1
			EndIf
		Next

		; create footer
		$file &= '</coordinates>' & @CRLF _
				 & '</LineString>' & @CRLF _
				 & '</Placemark>' & @CRLF _
				 & '</Folder>' & @CRLF
	EndIf
	$file &= '</Folder>' & @CRLF _
			 & '</Document>' & @CRLF _
			 & '</kml>' & @CRLF
	
	If $FoundApWithGps = 1 Then
		FileWrite($kml, $file)
		Return (1)
	Else
		Return (0)
	EndIf
	;EndIf
EndFunc   ;==>SaveKML

Func _SetKmlHeaders()
	$AutoKmlActiveHeader = '<?xml version="1.0" encoding="UTF-8"?>' & @CRLF _
			 & '<kml xmlns="http://earth.google.com/kml/2.2">' & @CRLF _
			 & '	<Document>' & @CRLF _
			 & '		<Style id="secureStyleActive">' & @CRLF _
			 & '			<IconStyle>' & @CRLF _
			 & '				<scale>.5</scale>' & @CRLF _
			 & '				<Icon>' & @CRLF _
			 & '					<href>' & $ImageDir & 'secure.png</href>' & @CRLF _
			 & '				</Icon>' & @CRLF _
			 & '			</IconStyle>' & @CRLF _
			 & '		</Style>' & @CRLF _
			 & '		<Style id="wepStyleActive">' & @CRLF _
			 & '			<IconStyle>' & @CRLF _
			 & '				<scale>.5</scale>' & @CRLF _
			 & '				<Icon>' & @CRLF _
			 & '					<href>' & $ImageDir & 'secure-wep.png</href>' & @CRLF _
			 & '				</Icon>' & @CRLF _
			 & '			</IconStyle>' & @CRLF _
			 & '		</Style>' & @CRLF _
			 & '		<Style id="openStyleActive">' & @CRLF _
			 & '			<IconStyle>' & @CRLF _
			 & '				<scale>.5</scale>' & @CRLF _
			 & '				<Icon>' & @CRLF _
			 & '					<href>' & $ImageDir & 'open.png</href>' & @CRLF _
			 & '				</Icon>' & @CRLF _
			 & '			</IconStyle>' & @CRLF _
			 & '		</Style>' & @CRLF

	$AutoKmlDeadHeader = '<?xml version="1.0" encoding="UTF-8"?>' & @CRLF _
			 & '<kml xmlns="http://earth.google.com/kml/2.2">' & @CRLF _
			 & '	<Document>' & @CRLF _
			 & '		<Style id="secureStyleDead">' & @CRLF _
			 & '			<IconStyle>' & @CRLF _
			 & '				<scale>.5</scale>' & @CRLF _
			 & '				<Icon>' & @CRLF _
			 & '					<href>' & $ImageDir & 'secure_dead.png</href>' & @CRLF _
			 & '				</Icon>' & @CRLF _
			 & '			</IconStyle>' & @CRLF _
			 & '		</Style>' & @CRLF _
			 & '		<Style id="wepStyleDead">' & @CRLF _
			 & '			<IconStyle>' & @CRLF _
			 & '				<scale>.5</scale>' & @CRLF _
			 & '				<Icon>' & @CRLF _
			 & '					<href>' & $ImageDir & 'secure-wep_dead.png</href>' & @CRLF _
			 & '				</Icon>' & @CRLF _
			 & '			</IconStyle>' & @CRLF _
			 & '		</Style>' & @CRLF _
			 & '		<Style id="openStyleDead">' & @CRLF _
			 & '			<IconStyle>' & @CRLF _
			 & '				<scale>.5</scale>' & @CRLF _
			 & '				<Icon>' & @CRLF _
			 & '					<href>' & $ImageDir & 'open_dead.png</href>' & @CRLF _
			 & '				</Icon>' & @CRLF _
			 & '			</IconStyle>' & @CRLF _
			 & '		</Style>' & @CRLF
EndFunc   ;==>_SetKmlHeaders

Func _StartGoogleAutoKmlRefresh()
	$kml = $GoogleEarth_OpenFile
	FileDelete($kml)
	If $AutoKML = 1 Then
		If FileExists($GoogleEarth_EXE) Then
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
						 & '				<refreshInterval>' & $AutoKmlGpsTime & '</refreshInterval>' & @CRLF _
						 & '			</Url>' & @CRLF _
						 & '		</NetworkLink>' & @CRLF
			EndIf
			If $AutoKmlActiveTime <> 0 Then
				$file &= '		<NetworkLink>' & @CRLF _
						 & '			<name>' & $Script_Name & ' Active APs</name>' & @CRLF _
						 & '			<Url>' & @CRLF _ ;AP List
						 & '				<href>' & $GoogleEarth_ActiveFile & '</href>' & @CRLF _
						 & '				<refreshMode>onInterval</refreshMode>' & @CRLF _
						 & '				<refreshInterval>' & $AutoKmlActiveTime & '</refreshInterval>' & @CRLF _
						 & '			</Url>' & @CRLF _
						 & '		</NetworkLink>' & @CRLF
			EndIf
			If $AutoKmlDeadTime <> 0 Then
				$file &= '		<NetworkLink>' & @CRLF _
						 & '			<name>' & $Script_Name & ' Dead APs</name>' & @CRLF _
						 & '			<Url>' & @CRLF _ ;AP List
						 & '				<href>' & $GoogleEarth_DeadFile & '</href>' & @CRLF _
						 & '				<refreshMode>onInterval</refreshMode>' & @CRLF _
						 & '				<refreshInterval>' & $AutoKmlDeadTime & '</refreshInterval>' & @CRLF _
						 & '			</Url>' & @CRLF _
						 & '		</NetworkLink>' & @CRLF
			EndIf
			If $AutoKmlTrackTime <> 0 Then
				$file &= '		<NetworkLink>' & @CRLF _
						 & '			<name>GPS Track</name>' & @CRLF _
						 & '			<Url>' & @CRLF _ ;AP List
						 & '				<href>' & $GoogleEarth_TrackFile & '</href>' & @CRLF _
						 & '				<refreshMode>onInterval</refreshMode>' & @CRLF _
						 & '				<refreshInterval>' & $AutoKmlTrackTime & '</refreshInterval>' & @CRLF _
						 & '			</Url>' & @CRLF _
						 & '		</NetworkLink>' & @CRLF
			EndIf
			$file &= '	</Document>' & @CRLF _
					 & '</kml>' & @CRLF
			FileWrite($kml, $file)
			If Not @error Then
				_AutoSaveKmlActive($GoogleEarth_ActiveFile)
				_AutoSaveKMLDead($GoogleEarth_DeadFile)
				Run('"' & $GoogleEarth_EXE & '" "' & $kml & '"')
			EndIf
		Else
			MsgBox(0, $Text_Error, "Google earth file does not exist or is set wrong in the AutoKML settings")
		EndIf
	Else
		MsgBox(0, $Text_Error, "AutoKML is not yet started. please start it first")
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
	If $Latitude <> 'N 0.0000' And $Longitude <> 'E 0.0000' Then
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
	If $Latitude <> 'N 0.0000' And $Longitude <> 'E 0.0000' Then
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

Func _AutoSaveKmlActive($kml, $MapOpenAPs = 1, $MapWepAps = 1, $MapSecAps = 1)
	If StringInStr($kml, '.kml') = 0 Then $kml = $kml & '.kml'
	$FoundOpenApWithGps = 0
	$FoundWepApWithGps = 0
	$FoundSecApWithGps = 0
	$fileWEP = ''
	$fileOpen = ''
	$fileSecure = ''
	For $i = 1 To $DataArray_BSSID[0]
		If $DataArray_Active[$i] = $Text_Active Then
			If StringReplace(StringReplace($DataArray_Lat[$i], 'N ', ''), 'S ', '') <> '0.0000' And StringReplace(StringReplace($DataArray_Lon[$i], 'E ', ''), 'W ', '') <> '0.0000' Then
				If $DataArray_SecType[$i] = '1' Then ;If AP has the Open flag, add it to the Open folder
					If $MapOpenAPs = 1 Then
						$fileOpen &= '				<Placemark>' & @CRLF _
								 & '					<name></name>' & @CRLF _
								 & '					<description><![CDATA[<b>' & $Column_Names_SSID & ': </b>' & $DataArray_SSID[$i] & '<br /><b>' & $Column_Names_BSSID & ': </b>' & $DataArray_BSSID[$i] & '<br /><b>' & $Column_Names_NetworkType & ': </b>' & $DataArray_NetType[$i] & '<br /><b>' & $Column_Names_RadioType & ': </b>' & $DataArray_Rad[$i] & '<br /><b>' & $Column_Names_Channel & ': </b>' & $DataArray_Chan[$i] & '<br /><b>' & $Column_Names_Authentication & ': </b>' & $DataArray_Auth[$i] & '<br /><b>' & $Column_Names_Encryption & ': </b>' & $DataArray_Encr[$i] & '<br /><b>' & $Column_Names_BasicTransferRates & ': </b>' & $DataArray_BtX[$i] & '<br /><b>' & $Column_Names_OtherTransferRates & ': </b>' & $DataArray_OtX[$i] & '<br /><b>' & $Column_Names_FirstActive & ': </b>' & $DataArray_FirstTime[$i] & '<br /><b>' & $Column_Names_LastActive & ': </b>' & $DataArray_LastTime[$i] & '<br /><b>' & $Column_Names_Latitude & ': </b>' & _Format_GPS_DMM_to_DDD($DataArray_Lat[$i]) & '<br /><b>' & $Column_Names_Longitude & ': </b>' & _Format_GPS_DMM_to_DDD($DataArray_Lon[$i]) & '<br /><b>' & $Column_Names_MANUF & ': </b>' & $DataArray_Manu[$i] & '<br />]]></description>' & @CRLF _
								 & '					<styleUrl>#openStyleActive</styleUrl>' & @CRLF _
								 & '					<Point>' & @CRLF _
								 & '						<coordinates>' & StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($DataArray_Lon[$i]), 'W', '-'), 'E', ''), ' ', '') & ',' & StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($DataArray_Lat[$i]), 'S', '-'), 'N', ''), ' ', '') & ',0</coordinates>' & @CRLF _
								 & '					</Point>' & @CRLF _
								 & '				</Placemark>' & @CRLF
						$FoundOpenApWithGps += 1
					EndIf
				ElseIf $DataArray_SecType[$i] = '2' Then ;If AP has the WEP flag, add it to the WEP folder
					If $MapWepAps = 1 Then
						$fileWEP &= '				<Placemark>' & @CRLF _
								 & '					<name></name>' & @CRLF _
								 & '					<description><![CDATA[<b>' & $Column_Names_SSID & ': </b>' & $DataArray_SSID[$i] & '<br /><b>' & $Column_Names_BSSID & ': </b>' & $DataArray_BSSID[$i] & '<br /><b>' & $Column_Names_NetworkType & ': </b>' & $DataArray_NetType[$i] & '<br /><b>' & $Column_Names_RadioType & ': </b>' & $DataArray_Rad[$i] & '<br /><b>' & $Column_Names_Channel & ': </b>' & $DataArray_Chan[$i] & '<br /><b>' & $Column_Names_Authentication & ': </b>' & $DataArray_Auth[$i] & '<br /><b>' & $Column_Names_Encryption & ': </b>' & $DataArray_Encr[$i] & '<br /><b>' & $Column_Names_BasicTransferRates & ': </b>' & $DataArray_BtX[$i] & '<br /><b>' & $Column_Names_OtherTransferRates & ': </b>' & $DataArray_OtX[$i] & '<br /><b>' & $Column_Names_FirstActive & ': </b>' & $DataArray_FirstTime[$i] & '<br /><b>' & $Column_Names_LastActive & ': </b>' & $DataArray_LastTime[$i] & '<br /><b>' & $Column_Names_Latitude & ': </b>' & _Format_GPS_DMM_to_DDD($DataArray_Lat[$i]) & '<br /><b>' & $Column_Names_Longitude & ': </b>' & _Format_GPS_DMM_to_DDD($DataArray_Lon[$i]) & '<br /><b>' & $Column_Names_MANUF & ': </b>' & $DataArray_Manu[$i] & '<br />]]></description>' & @CRLF _
								 & '					<styleUrl>#wepStyleActive</styleUrl>' & @CRLF _
								 & '					<Point>' & @CRLF _
								 & '						<coordinates>' & StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($DataArray_Lon[$i]), 'W', '-'), 'E', ''), ' ', '') & ',' & StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($DataArray_Lat[$i]), 'S', '-'), 'N', ''), ' ', '') & ',0</coordinates>' & @CRLF _
								 & '					</Point>' & @CRLF _
								 & '				</Placemark>' & @CRLF
						$FoundWepApWithGps += 1
					EndIf
				ElseIf $DataArray_SecType[$i] = '3' Then ;If AP has the Secure flag, add it to the Secure folder
					If $MapSecAps = 1 Then
						$fileSecure &= '				<Placemark>' & @CRLF _
								 & '					<name></name>' & @CRLF _
								 & '					<description><![CDATA[<b>' & $Column_Names_SSID & ': </b>' & $DataArray_SSID[$i] & '<br /><b>' & $Column_Names_BSSID & ': </b>' & $DataArray_BSSID[$i] & '<br /><b>' & $Column_Names_NetworkType & ': </b>' & $DataArray_NetType[$i] & '<br /><b>' & $Column_Names_RadioType & ': </b>' & $DataArray_Rad[$i] & '<br /><b>' & $Column_Names_Channel & ': </b>' & $DataArray_Chan[$i] & '<br /><b>' & $Column_Names_Authentication & ': </b>' & $DataArray_Auth[$i] & '<br /><b>' & $Column_Names_Encryption & ': </b>' & $DataArray_Encr[$i] & '<br /><b>' & $Column_Names_BasicTransferRates & ': </b>' & $DataArray_BtX[$i] & '<br /><b>' & $Column_Names_OtherTransferRates & ': </b>' & $DataArray_OtX[$i] & '<br /><b>' & $Column_Names_FirstActive & ': </b>' & $DataArray_FirstTime[$i] & '<br /><b>' & $Column_Names_LastActive & ': </b>' & $DataArray_LastTime[$i] & '<br /><b>' & $Column_Names_Latitude & ': </b>' & _Format_GPS_DMM_to_DDD($DataArray_Lat[$i]) & '<br /><b>' & $Column_Names_Longitude & ': </b>' & _Format_GPS_DMM_to_DDD($DataArray_Lon[$i]) & '<br /><b>' & $Column_Names_MANUF & ': </b>' & $DataArray_Manu[$i] & '<br />]]></description>' & @CRLF _
								 & '					<styleUrl>#secureStyleActive</styleUrl>' & @CRLF _
								 & '					<Point>' & @CRLF _
								 & '						<coordinates>' & StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($DataArray_Lon[$i]), 'W', '-'), 'E', ''), ' ', '') & ',' & StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($DataArray_Lat[$i]), 'S', '-'), 'N', ''), ' ', '') & ',0</coordinates>' & @CRLF _
								 & '					</Point>' & @CRLF _
								 & '				</Placemark>' & @CRLF
						$FoundSecApWithGps += 1
					EndIf
				EndIf
			EndIf
		EndIf
	Next
	;Format KML File

	$file = $AutoKmlActiveHeader & @CRLF _
			 & '		<Folder>' & @CRLF _
			 & '			<name>Active Access Points</name>' & @CRLF _
			 & '			<description>APs:' & ($FoundOpenApWithGps + $FoundWepApWithGps + $FoundSecApWithGps) & '</description>' & @CRLF
	
	If $FoundOpenApWithGps <> 0 Then
		$file &= '			<Folder>' & @CRLF _
				 & '				<name>Open Access Points</name>' & @CRLF _
				 & '				<description>APs:' & $FoundOpenApWithGps & '</description>' & @CRLF _
				 & $fileOpen & @CRLF _
				 & '			</Folder>' & @CRLF
	EndIf
	If $FoundWepApWithGps <> 0 Then
		$file &= '			<Folder>' & @CRLF _
				 & '				<name>WEP Access Points</name>' & @CRLF _
				 & '				<description>APs:' & $FoundWepApWithGps & '</description>' & @CRLF _
				 & $fileWEP & @CRLF _
				 & '			</Folder>' & @CRLF
	EndIf
	If $FoundSecApWithGps <> 0 Then
		$file &= '			<Folder>' & @CRLF _
				 & '				<name>Secure Access Points</name>' & @CRLF _
				 & '				<description>APs:' & $FoundSecApWithGps & '</description>' & @CRLF _
				 & $fileSecure & @CRLF _
				 & '			</Folder>' & @CRLF
	EndIf

	$file &= '			</Folder>' & @CRLF _
			 & '	</Document>' & @CRLF _
			 & '</kml>'

	FileDelete($kml)
	$filewrite = FileWrite($kml, $file)

	If $filewrite = 1 Then
		$kml_active_timer = TimerInit()
		Return (1)
	Else
		Return (0)
	EndIf
EndFunc   ;==>_AutoSaveKmlActive

Func _AutoSaveKMLDead($kml, $KmlUseLocalImages = 1, $MapOpenAPs = 1, $MapWepAps = 1, $MapSecAps = 1)
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, 'SaveKML()') ;#Debug Display
	If StringInStr($kml, '.kml') = 0 Then $kml = $kml & '.kml'
	$FoundOpenApWithGps = 0
	$FoundWepApWithGps = 0
	$FoundSecApWithGps = 0
	$fileWEP = ''
	$fileOpen = ''
	$fileSecure = ''
	For $i = 1 To $DataArray_BSSID[0]
		GUICtrlSetData($msgdisplay, $Text_SavingLine & ' ' & $i & ' / ' & $DataArray_BSSID[0])
		If $DataArray_Active[$i] = $Text_Dead Then
			If StringReplace(StringReplace($DataArray_Lat[$i], 'N ', ''), 'S ', '') <> '0.0000' And StringReplace(StringReplace($DataArray_Lon[$i], 'E ', ''), 'W ', '') <> '0.0000' Then
				If $DataArray_SecType[$i] = '1' Then ;If AP has the Open flag, add it to the Open folder
					If $MapOpenAPs = 1 Then
						$fileOpen &= '				<Placemark>' & @CRLF _
								 & '					<name></name>' & @CRLF _
								 & '					<description><![CDATA[<b>' & $Column_Names_SSID & ': </b>' & $DataArray_SSID[$i] & '<br /><b>' & $Column_Names_BSSID & ': </b>' & $DataArray_BSSID[$i] & '<br /><b>' & $Column_Names_NetworkType & ': </b>' & $DataArray_NetType[$i] & '<br /><b>' & $Column_Names_RadioType & ': </b>' & $DataArray_Rad[$i] & '<br /><b>' & $Column_Names_Channel & ': </b>' & $DataArray_Chan[$i] & '<br /><b>' & $Column_Names_Authentication & ': </b>' & $DataArray_Auth[$i] & '<br /><b>' & $Column_Names_Encryption & ': </b>' & $DataArray_Encr[$i] & '<br /><b>' & $Column_Names_BasicTransferRates & ': </b>' & $DataArray_BtX[$i] & '<br /><b>' & $Column_Names_OtherTransferRates & ': </b>' & $DataArray_OtX[$i] & '<br /><b>' & $Column_Names_FirstActive & ': </b>' & $DataArray_FirstTime[$i] & '<br /><b>' & $Column_Names_LastActive & ': </b>' & $DataArray_LastTime[$i] & '<br /><b>' & $Column_Names_Latitude & ': </b>' & _Format_GPS_DMM_to_DDD($DataArray_Lat[$i]) & '<br /><b>' & $Column_Names_Longitude & ': </b>' & _Format_GPS_DMM_to_DDD($DataArray_Lon[$i]) & '<br /><b>' & $Column_Names_MANUF & ': </b>' & $DataArray_Manu[$i] & '<br />]]></description>' & @CRLF _
								 & '					<styleUrl>#openStyleDead</styleUrl>' & @CRLF _
								 & '					<Point>' & @CRLF _
								 & '						<coordinates>' & StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($DataArray_Lon[$i]), 'W', '-'), 'E', ''), ' ', '') & ',' & StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($DataArray_Lat[$i]), 'S', '-'), 'N', ''), ' ', '') & ',0</coordinates>' & @CRLF _
								 & '					</Point>' & @CRLF _
								 & '				</Placemark>' & @CRLF
						$FoundOpenApWithGps += 1
					EndIf
				ElseIf $DataArray_SecType[$i] = '2' Then ;If AP has the WEP flag, add it to the WEP folder
					If $MapWepAps = 1 Then
						$fileWEP &= '				<Placemark>' & @CRLF _
								 & '					<name></name>' & @CRLF _
								 & '					<description><![CDATA[<b>' & $Column_Names_SSID & ': </b>' & $DataArray_SSID[$i] & '<br /><b>' & $Column_Names_BSSID & ': </b>' & $DataArray_BSSID[$i] & '<br /><b>' & $Column_Names_NetworkType & ': </b>' & $DataArray_NetType[$i] & '<br /><b>' & $Column_Names_RadioType & ': </b>' & $DataArray_Rad[$i] & '<br /><b>' & $Column_Names_Channel & ': </b>' & $DataArray_Chan[$i] & '<br /><b>' & $Column_Names_Authentication & ': </b>' & $DataArray_Auth[$i] & '<br /><b>' & $Column_Names_Encryption & ': </b>' & $DataArray_Encr[$i] & '<br /><b>' & $Column_Names_BasicTransferRates & ': </b>' & $DataArray_BtX[$i] & '<br /><b>' & $Column_Names_OtherTransferRates & ': </b>' & $DataArray_OtX[$i] & '<br /><b>' & $Column_Names_FirstActive & ': </b>' & $DataArray_FirstTime[$i] & '<br /><b>' & $Column_Names_LastActive & ': </b>' & $DataArray_LastTime[$i] & '<br /><b>' & $Column_Names_Latitude & ': </b>' & _Format_GPS_DMM_to_DDD($DataArray_Lat[$i]) & '<br /><b>' & $Column_Names_Longitude & ': </b>' & _Format_GPS_DMM_to_DDD($DataArray_Lon[$i]) & '<br /><b>' & $Column_Names_MANUF & ': </b>' & $DataArray_Manu[$i] & '<br />]]></description>' & @CRLF _
								 & '					<styleUrl>#wepStyleDead</styleUrl>' & @CRLF _
								 & '					<Point>' & @CRLF _
								 & '						<coordinates>' & StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($DataArray_Lon[$i]), 'W', '-'), 'E', ''), ' ', '') & ',' & StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($DataArray_Lat[$i]), 'S', '-'), 'N', ''), ' ', '') & ',0</coordinates>' & @CRLF _
								 & '					</Point>' & @CRLF _
								 & '				</Placemark>' & @CRLF
						$FoundWepApWithGps += 1
					EndIf
				ElseIf $DataArray_SecType[$i] = '3' Then ;If AP has the Secure flag, add it to the Open folder
					If $MapSecAps = 1 Then
						$fileSecure &= '				<Placemark>' & @CRLF _
								 & '					<name></name>' & @CRLF _
								 & '					<description><![CDATA[<b>' & $Column_Names_SSID & ': </b>' & $DataArray_SSID[$i] & '<br /><b>' & $Column_Names_BSSID & ': </b>' & $DataArray_BSSID[$i] & '<br /><b>' & $Column_Names_NetworkType & ': </b>' & $DataArray_NetType[$i] & '<br /><b>' & $Column_Names_RadioType & ': </b>' & $DataArray_Rad[$i] & '<br /><b>' & $Column_Names_Channel & ': </b>' & $DataArray_Chan[$i] & '<br /><b>' & $Column_Names_Authentication & ': </b>' & $DataArray_Auth[$i] & '<br /><b>' & $Column_Names_Encryption & ': </b>' & $DataArray_Encr[$i] & '<br /><b>' & $Column_Names_BasicTransferRates & ': </b>' & $DataArray_BtX[$i] & '<br /><b>' & $Column_Names_OtherTransferRates & ': </b>' & $DataArray_OtX[$i] & '<br /><b>' & $Column_Names_FirstActive & ': </b>' & $DataArray_FirstTime[$i] & '<br /><b>' & $Column_Names_LastActive & ': </b>' & $DataArray_LastTime[$i] & '<br /><b>' & $Column_Names_Latitude & ': </b>' & _Format_GPS_DMM_to_DDD($DataArray_Lat[$i]) & '<br /><b>' & $Column_Names_Longitude & ': </b>' & _Format_GPS_DMM_to_DDD($DataArray_Lon[$i]) & '<br /><b>' & $Column_Names_MANUF & ': </b>' & $DataArray_Manu[$i] & '<br />]]></description>' & @CRLF _
								 & '					<styleUrl>#secureStyleDead</styleUrl>' & @CRLF _
								 & '					<Point>' & @CRLF _
								 & '						<coordinates>' & StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($DataArray_Lon[$i]), 'W', '-'), 'E', ''), ' ', '') & ',' & StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($DataArray_Lat[$i]), 'S', '-'), 'N', ''), ' ', '') & ',0</coordinates>' & @CRLF _
								 & '					</Point>' & @CRLF _
								 & '				</Placemark>' & @CRLF
						$FoundSecApWithGps += 1
					EndIf
				EndIf
			EndIf
		EndIf
		_ReduceMemory()
	Next
	
	;Format KML File

	$file = $AutoKmlDeadHeader & @CRLF _
			 & '		<Folder>' & @CRLF _
			 & '			<name>Dead Access Points</name>' & @CRLF _
			 & '			<description>APs:' & ($FoundOpenApWithGps + $FoundWepApWithGps + $FoundSecApWithGps) & '</description>' & @CRLF
	
	If $FoundOpenApWithGps <> 0 Then
		$file &= '			<Folder>' & @CRLF _
				 & '				<name>Open Access Points</name>' & @CRLF _
				 & '				<description>APs:' & $FoundOpenApWithGps & '</description>' & @CRLF _
				 & $fileOpen & @CRLF _
				 & '			</Folder>' & @CRLF
	EndIf
	If $FoundWepApWithGps <> 0 Then
		$file &= '			<Folder>' & @CRLF _
				 & '				<name>WEP Access Points</name>' & @CRLF _
				 & '				<description>APs:' & $FoundWepApWithGps & '</description>' & @CRLF _
				 & $fileWEP & @CRLF _
				 & '			</Folder>' & @CRLF
	EndIf
	If $FoundSecApWithGps <> 0 Then
		$file &= '			<Folder>' & @CRLF _
				 & '				<name>Secure Access Points</name>' & @CRLF _
				 & '				<description>APs:' & $FoundSecApWithGps & '</description>' & @CRLF _
				 & $fileSecure & @CRLF _
				 & '			</Folder>' & @CRLF
	EndIf

	$file &= '			</Folder>' & @CRLF _
			 & '	</Document>' & @CRLF _
			 & '</kml>'

	FileDelete($kml)
	$filewrite = FileWrite($kml, $file)

	If $filewrite = 1 Then
		$kml_dead_timer = TimerInit()
		Return (1)
	Else
		Return (0)
	EndIf
	;EndIf
EndFunc   ;==>_AutoSaveKMLDead

Func _AutoSaveKmlTrack($kml)
	If StringLower(StringTrimLeft($kml, StringLen($kml) - 4)) <> '.kml' Then $kml &= '.kml'
	$file = '<?xml version="1.0" encoding="UTF-8"?>' & @CRLF _
			 & '<kml xmlns="http://earth.google.com/kml/2.1">' & @CRLF _
			 & '<Document>' & @CRLF _
			 & '<name>' & $kml & '</name>' & @CRLF _
			 & '<open>1</open>' & @CRLF _
			 & '<Style id="Location">' & @CRLF _
			 & '<LineStyle>' & @CRLF _
			 & '<color>7f0000ff</color>' & @CRLF _
			 & '<width>4</width>' & @CRLF _
			 & '</LineStyle>' & @CRLF _
			 & '</Style>' & @CRLF _
			 & '<Placemark>' & @CRLF _
			 & '<name>Location</name>' & @CRLF _
			 & '<styleUrl>#Location</styleUrl>' & @CRLF _
			 & '<LineString>' & @CRLF _
			 & '<extrude>1</extrude>' & @CRLF _
			 & '<tessellate>1</tessellate>' & @CRLF _
			 & '<coordinates>' & @CRLF _
			
	For $e = 1 To $GPSArray_ID[0]
		GUICtrlSetData($msgdisplay, 'Saving GPS Pos ' & $e & ' / ' & $GPSArray_ID[0])
		If $GPSArray_Lat[$e] <> 'N 0.0000' And $GPSArray_Lon[$e] <> 'E 0.0000' Then
			$file &= StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($GPSArray_Lon[$e]), 'W', '-'), 'E', ''), ' ', '') & ',' & StringReplace(StringReplace(StringReplace(_Format_GPS_DMM_to_DDD($GPSArray_Lat[$e]), 'S', '-'), 'N', ''), ' ', '') & ',0' & @CRLF
		EndIf
	Next

	; create footer
	$file &= '</coordinates>' & @CRLF _
			 & '</LineString>' & @CRLF _
			 & '</Placemark>' & @CRLF _
			 & '</Document>' & @CRLF _
			 & '</kml>'
	
	FileDelete($kml)
	$filewrite = FileWrite($kml, $file)
	
	If $filewrite = 1 Then
		$kml_track_timer = TimerInit()
		Return (1)
	Else
		Return (0)
	EndIf
EndFunc   ;==>_AutoSaveKmlTrack

;-------------------------------------------------------------------------------------------------------------------------------
;                                                       NETSTUMBLER SAVE/OPEN FUNCTIONS
;-------------------------------------------------------------------------------------------------------------------------------

Func _ExportNS1();Saves netstumbler data to a netstumbler summary .ns1
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_ExportNS1()') ;#Debug Display
	DirCreate($SaveDir)
	$timestamp = @MON & '-' & @MDAY & '-' & @YEAR & ' ' & @HOUR & '-' & @MIN & '-' & @SEC
	$filename = FileSaveDialog($Text_SaveAsTXT, $SaveDir, 'Netstumbler (*.NS1)', '', $timestamp & '.NS1')
	If @error <> 1 Then
		FileDelete($filename)

		$date = ''
		$date1 = ''
		$date2 = ''
		$time = ''
		$time1 = ''
		$time2 = ''
		$OrigDate = ''
		$file = "# $Creator: " & $Script_Name & " " & $version & @CRLF & _
				"# $Format: wi-scan summary with extensions" & @CRLF & _
				"# Latitude	Longitude	( SSID )	Type	( BSSID )	Time (GMT)	[ SNR Sig Noise ]	# ( Name )	Flags	Channelbits	BcnIntvl	DataRate	LastChannel" & @CRLF
		For $exns1 = 1 To $DataArray_BSSID[0]
			GUICtrlSetData($msgdisplay, $exns1 & " / " & $DataArray_BSSID[0])
			$firstarray = StringSplit($DataArray_FirstTime[$exns1], " ")
			$date1array = StringSplit($firstarray[1], "-")
			$lastarray = StringSplit($DataArray_LastTime[$exns1], " ")
			$date2array = StringSplit($firstarray[1], "-")
			If $firstarray[1] <> $date1 Then $date1 = $date1array[3] & "-" & $date1array[1] & "-" & $date1array[2]
			If $firstarray[2] <> $time1 Then $time1 = $firstarray[2]
			;EndIf
			If $OrigDate <> $date1 Then
				$file &= "# $DateGMT: " & $date1 & @CRLF
				$OrigDate = $date1
			Else
				If $lastarray[1] <> $date2 Then $date2 = $date2array[3] & "-" & $date2array[1] & "-" & $date2array[2]
				If $lastarray[2] <> $time2 Then $time2 = $lastarray[2]
				If $OrigDate <> $date2 Then $file &= "# $DateGMT: " & $date2 & @CRLF
				$OrigDate = $date2
			EndIf
			
			$gidarray = StringSplit($DataArray_GID[$exns1], "-")
			If IsArray($gidarray) Then
				For $g = 1 To $gidarray[0]
					$GidSplit = StringSplit($gidarray[$g], ",")
					If $GidSplit[0] = 2 Then
						$Exp_Lat = _Format_GPS_DMM_to_DDD($GPSArray_Lat[$GidSplit[1]])
						$Exp_Lon = _Format_GPS_DMM_to_DDD($GPSArray_Lon[$GidSplit[1]])
						$Exp_Date = $GPSArray_Date[$GidSplit[1]]
						$Exp_Time = _TimeLocalToGmt($GPSArray_Time[$GidSplit[1]])
						$Exp_Sig = $GidSplit[2]
						$datetimestamp = $Exp_Date & ' ' & $Exp_Time
						
						$Radio = 0
						$otxarray = StringSplit($DataArray_OtX[$exns1], " ")
						If IsArray($otxarray) Then
							$Radio = $otxarray[$otxarray[0]] * 10
						Else
							$btxarray = StringSplit($DataArray_BtX[$exns1], " ")
							If IsArray($btxarray) Then $Radio = $btxarray[$btxarray[0]] * 10
						EndIf
						
						;Channel Info - http://www.netstumbler.org/f4/channelbits-8849/
						$Chan = '00000000'
						If $DataArray_Chan[$exns1] = 1 Then $Chan = '00000002'
						If $DataArray_Chan[$exns1] = 2 Then $Chan = '00000004'
						If $DataArray_Chan[$exns1] = 3 Then $Chan = '00000008'
						If $DataArray_Chan[$exns1] = 4 Then $Chan = '00000010'
						If $DataArray_Chan[$exns1] = 5 Then $Chan = '00000020'
						If $DataArray_Chan[$exns1] = 6 Then $Chan = '00000040'
						If $DataArray_Chan[$exns1] = 7 Then $Chan = '00000080'
						If $DataArray_Chan[$exns1] = 8 Then $Chan = '00000100'
						If $DataArray_Chan[$exns1] = 9 Then $Chan = '00000200'
						If $DataArray_Chan[$exns1] = 10 Then $Chan = '00000400'
						If $DataArray_Chan[$exns1] = 11 Then $Chan = '00000800'
						If $DataArray_Chan[$exns1] = 12 Then $Chan = '00001000'
						If $DataArray_Chan[$exns1] = 13 Then $Chan = '00002000'
						If $DataArray_Chan[$exns1] = 14 Then $Chan = '00004000'
						If $DataArray_Chan[$exns1] = 36 Then $Chan = '00008000'
						If $DataArray_Chan[$exns1] = 40 Then $Chan = '00010000'
						If $DataArray_Chan[$exns1] = 44 Then $Chan = '00020000'
						If $DataArray_Chan[$exns1] = 48 Then $Chan = '00040000'
						If $DataArray_Chan[$exns1] = 52 Then $Chan = '00080000'
						If $DataArray_Chan[$exns1] = 56 Then $Chan = '00100000'
						If $DataArray_Chan[$exns1] = 60 Then $Chan = '00200000'
						If $DataArray_Chan[$exns1] = 64 Then $Chan = '00400000'
						If $DataArray_Chan[$exns1] = 149 Then $Chan = '00800000'
						If $DataArray_Chan[$exns1] = 153 Then $Chan = '01000000'
						If $DataArray_Chan[$exns1] = 157 Then $Chan = '02000000'
						If $DataArray_Chan[$exns1] = 161 Then $Chan = '04000000'
						If $DataArray_Chan[$exns1] = 38 Then $Chan = '08000000'
						If $DataArray_Chan[$exns1] = 46 Then $Chan = '10000000'
						If $DataArray_Chan[$exns1] = 54 Then $Chan = '20000000'
						If $DataArray_Chan[$exns1] = 62 Then $Chan = '40000000'
						If $DataArray_Chan[$exns1] = 34 Then $Chan = '80000000'
						
						$Flags = 0
						If $DataArray_NetType[$exns1] = $SearchWord_Adhoc Then
							;$Flags += 0x2 ;Set IBSS (Ad hoc) flag
							$Flags += 2 ;Set IBSS (Ad hoc) flag
							$BSS = 'ad-hoc'
						Else
							;$Flags += 0x1 ;Set ESS (Infrastructure) flag
							$Flags += 1 ;Set ESS (Infrastructure) flag
							$BSS = 'BSS'
						EndIf
						
						If $DataArray_Encr[$exns1] <> $SearchWord_None Then
							;$Flags += 0x10 ;Set Privacy (WEP) flag
							$Flags += 10 ;Set Privacy (WEP) flag
						EndIf
						
						$Flags = StringFormat("%04i", $Flags)
						
						$file &= $Exp_Lat & "	" & $Exp_Lon & "	( " & $DataArray_SSID[$exns1] & " )	" & $BSS & "	( " & $DataArray_BSSID[$exns1] & " )	" & $Exp_Time & " (GMT)	[ " & $Exp_Sig & " " & $Exp_Sig + 50 & " 50 ]	# ( " & $DataArray_Label[$exns1] & ' - ' & $DataArray_Manu[$exns1] & " )	" & $Flags & "	" & $Chan & "	1000	" & $Radio & "	" & $DataArray_Chan[$exns1] & @CRLF
					EndIf
				Next
			EndIf
		Next
		FileWrite($filename, $file)
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
	$SetMisc = GUICreate($Text_VistumblerSettings, 690, 500, -1, -1, BitOR($WS_OVERLAPPEDWINDOW, $WS_CLIPSIBLINGS))
	GUISetBkColor($BackgroundColor)
	$Settings_Tab = GUICtrlCreateTab(0, 0, 690, 470)
	;Misc Tab
	$Tab_Misc = GUICtrlCreateTabItem($Text_Misc)
	_GUICtrlTab_SetBkColor($SetMisc, $Settings_Tab, $BackgroundColor)
	$GroupMisc = GUICtrlCreateGroup($Text_Misc, 8, 32, 665, 425)
	GUICtrlSetColor(-1, $TextColor)
	$GroupMiscOpt = GUICtrlCreateGroup($Text_Options, 16, 56, 649, 257)
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
	$GUI_BKColor = GUICtrlCreateInput(StringReplace($BackgroundColor, '0x', ''), 31, 211, 300, 21)
	GUICtrlCreateLabel($Text_ControlColor, 353, 196, 300, 15)
	GUICtrlSetColor(-1, $TextColor)
	$GUI_CBKColor = GUICtrlCreateInput(StringReplace($ControlBackgroundColor, '0x', ''), 353, 211, 300, 21)
	GUICtrlCreateLabel($Text_BgFontColor, 31, 236, 300, 15)
	GUICtrlSetColor(-1, $TextColor)
	$GUI_TextColor = GUICtrlCreateInput(StringReplace($TextColor, '0x', ''), 31, 251, 300, 21)
	GUICtrlCreateLabel($Text_RefreshLoopTime, 353, 236, 300, 15)
	GUICtrlSetColor(-1, $TextColor)
	$GUI_RefreshLoop = GUICtrlCreateInput($RefreshLoopTime, 353, 251, 300, 21)
	$GroupMiscPHP = GUICtrlCreateGroup($Text_PHPgraphing, 16, 328, 649, 121)
	GUICtrlSetColor(-1, $TextColor)
	GUICtrlCreateLabel($Text_PhilsPHPgraph, 31, 349, 620, 15)
	GUICtrlSetColor(-1, $TextColor)
	$GUI_PhilsGraphURL = GUICtrlCreateInput($PhilsGraphURL, 31, 369, 620, 21)
	GUICtrlCreateLabel($Text_PhilsWDB, 32, 396, 620, 15)
	GUICtrlSetColor(-1, $TextColor)
	$GUI_PhilsWdbURL = GUICtrlCreateInput($PhilsWdbURL, 32, 416, 620, 21)
	;GPS Tab
	$Tab_Gps = GUICtrlCreateTabItem($Text_Gps)
	_GUICtrlTab_SetBkColor($SetMisc, $Settings_Tab, $BackgroundColor)
	$GroupComInt = GUICtrlCreateGroup($Text_ComInterface, 24, 48, 633, 97)
	GUICtrlSetColor(-1, $TextColor)
	$Rad_UseNetcomm = GUICtrlCreateRadio($Text_UseNetcomm, 40, 72, 361, 17)
	GUICtrlSetColor(-1, $TextColor)
	$Rad_UseCommMG = GUICtrlCreateRadio($Text_UseCommMG, 40, 104, 361, 17)
	GUICtrlSetColor(-1, $TextColor)
	If $UseNetcomm = 1 Then
		GUICtrlSetState($Rad_UseNetcomm, $GUI_CHECKED)
	Else
		GUICtrlSetState($Rad_UseCommMG, $GUI_CHECKED)
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
	;$FlowLabel = GUICtrlCreateLabel("Flow Control", 364, 180, 275, 15)
	;$Combo3 = GUICtrlCreateCombo("Combo1", 364, 195, 275, 25)
	;$ParityLabel = GUICtrlCreateLabel("Parity", 364, 235, 275, 15)
	;$ParityCombo = GUICtrlCreateCombo("ParityCombo", 364, 250, 275, 25)
	;$Label3 = GUICtrlCreateLabel("Stop Bits", 44, 290, 275, 15)
	;$Combo2 = GUICtrlCreateCombo("Combo1", 41, 305, 275, 25)
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
	$languagefile = $LanguageDir & $DefaultLanguage & ".ini" ;set default ini file Language Author information will be added into the GUI
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
	$LabAuth = GUICtrlCreateLabel(IniRead($languagefile, 'Info', 'Author', ''), 40, 112, 580, 17)
	GUICtrlSetColor(-1, $TextColor)
	GUICtrlCreateGroup($Text_LanguageDate, 32, 150, 601, 41)
	GUICtrlSetColor(-1, $TextColor)
	$LabDate = GUICtrlCreateLabel(IniRead($languagefile, 'Info', 'Date', ''), 40, 166, 580, 17)
	GUICtrlSetColor(-1, $TextColor)
	GUICtrlCreateGroup($Text_LanguageDescription, 34, 200, 601, 121)
	GUICtrlSetColor(-1, $TextColor)
	$LabDesc = GUICtrlCreateLabel(IniRead($languagefile, 'Info', 'Description', ''), 42, 216, 580, 97)
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
	_GUICtrlListView_SetColumnWidth($GUI_Manu_List, 0, 160)
	_GUICtrlListView_SetColumnWidth($GUI_Manu_List, 1, 450)
	For $m = 1 To $manu_mac[0];Add MACS/MANUFACTURES into the list
		GUICtrlCreateListViewItem('"' & $manu_mac[$m] & '"|' & $manu_manu[$m], $GUI_Manu_List)
	Next
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
	_GUICtrlListView_SetColumnWidth($GUI_Lab_List, 0, 160)
	_GUICtrlListView_SetColumnWidth($GUI_Lab_List, 1, 450)
	For $m = 1 To $label_mac[0];Add MACS/MANUFACTURES into the list
		GUICtrlCreateListViewItem('"' & $label_mac[$m] & '"|' & $label_label[$m], $GUI_Lab_List)
	Next
	;Columns Tabs
	$Tab_Col = GUICtrlCreateTabItem($Text_Columns)
	;Get Current GUI widths from listview
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
	GUICtrlCreateLabel($Text_AutoSaveEvery, 31, 105, 84, 15)
	GUICtrlSetColor(-1, $TextColor)
	$AutoSaveSec = GUICtrlCreateInput($SaveTime, 31, 120, 115, 21)
	GUICtrlCreateLabel($Text_Seconds, 151, 125, 505, 17)
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
	GUICtrlCreateLabel($Text_AutoSortEvery, 30, 290, 625, 15)
	GUICtrlSetColor(-1, $TextColor)
	$GUI_SortTime = GUICtrlCreateInput($SortTime, 30, 305, 115, 21)
	GUICtrlCreateLabel($Text_Seconds, 150, 315, 505, 17)
	GUICtrlSetColor(-1, $TextColor)
	
	
	;AutoKML Tab
	$Tab_AutoKML = GUICtrlCreateTabItem($Text_AutoKml & ' / ' & $Text_SpeakSignal)
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
	;GUICtrlCreateLabel($Text_Seconds, 150, 160, 50, 15)
	;GUICtrlSetColor(-1, $TextColor)
	GUICtrlCreateLabel($Text_DeadRefreshTime & '(s)', 155, 140, 115, 15)
	GUICtrlSetColor(-1, $TextColor)
	$GUI_AutoKmlDeadTime = GUICtrlCreateInput($AutoKmlDeadTime, 155, 155, 115, 20)
	;GUICtrlCreateLabel($Text_Seconds, 315, 160, 50, 15)
	;GUICtrlSetColor(-1, $TextColor)
	GUICtrlCreateLabel($Text_GpsRefrshTime & '(s)', 280, 140, 115, 15)
	GUICtrlSetColor(-1, $TextColor)
	$GUI_AutoKmlGpsTime = GUICtrlCreateInput($AutoKmlGpsTime, 280, 155, 115, 20)
	;GUICtrlCreateLabel($Text_Seconds, 480, 160, 50, 15)
	;GUICtrlSetColor(-1, $TextColor)
	GUICtrlCreateLabel($Text_GpsTrackTime & '(s)', 405, 140, 115, 15)
	GUICtrlSetColor(-1, $TextColor)
	$GUI_AutoKmlTrackTime = GUICtrlCreateInput($AutoKmlTrackTime, 405, 155, 115, 20)
	;GUICtrlCreateLabel($Text_Seconds, 480, 160, 50, 15)
	;GUICtrlSetColor(-1, $TextColor)
	
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
	GUICtrlCreateGroup($Text_SpeakSignal, 16, 290, 650, 145)
	$GUI_SpeakSignal = GUICtrlCreateCheckbox($Text_SpeakSignal, 30, 310, 625, 15)
	GUICtrlSetColor(-1, $TextColor)
	If $SpeakSignal = 1 Then GUICtrlSetState($GUI_SpeakSignal, $GUI_CHECKED)
	$GUI_SpeakSoundsVis = GUICtrlCreateRadio($Text_SpeakUseVisSounds, 30, 330, 625, 15)
	$GUI_SpeakSoundsSapi = GUICtrlCreateRadio($Text_SpeakUseSapi, 30, 350, 625, 15)
	GUICtrlSetColor($GUI_SpeakSoundsVis, $TextColor)
	GUICtrlSetColor($GUI_SpeakSoundsSapi, $TextColor)
	If $SpeakType = 1 Then
		GUICtrlSetState($GUI_SpeakSoundsVis, $GUI_CHECKED)
	Else
		GUICtrlSetState($GUI_SpeakSoundsSapi, $GUI_CHECKED)
	EndIf
	$GUI_SpeakPercent = GUICtrlCreateCheckbox($Text_SpeakSayPercent, 30, 370, 625, 15)
	GUICtrlSetColor(-1, $TextColor)
	If $SpeakSigSayPecent = 1 Then GUICtrlSetState($GUI_SpeakPercent, $GUI_CHECKED)
	GUICtrlCreateLabel('Speak Refresh Time' & '(ms)', 30, 390, 150, 15)
	GUICtrlSetColor(-1, $TextColor)
	$GUI_SpeakSigTime = GUICtrlCreateInput($SpeakSigTime, 30, 405, 150, 20)
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

	GUISetState(@SW_SHOW)
EndFunc   ;==>_SettingsGUI

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
	GUICtrlSetData($LabDate, IniRead($languagefile, 'Info', 'Date', ''))
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
		If GUICtrlRead($GUI_Format) = "dd.dddd" Then $GPSformat = 1
		If GUICtrlRead($GUI_Format) = "dd mm ss" Then $GPSformat = 2
		If GUICtrlRead($GUI_Format) = "ddmm.mmmm" Then $GPSformat = 3
		GUICtrlSetData($GuiLat, $Text_Latitude & ': ' & _GpsFormat($Latitude));Set GPS Latitude in GUI
		GUICtrlSetData($GuiLon, $Text_Longitude & ': ' & _GpsFormat($Longitude));Set GPS Longitude in GUI
		If GUICtrlRead($Rad_UseNetcomm) = 1 Then $UseNetcomm = 1 ;Set Netcomm as default comm interface
		If GUICtrlRead($Rad_UseCommMG) = 1 Then $UseNetcomm = 0 ;Set CommMG as default comm interface
	EndIf
	If $Apply_Language = 1 Then
		$DefaultLanguage = GUICtrlRead($LanguageBox)
		$newlanguagefile = $LanguageDir & $DefaultLanguage & ".ini"
		$Column_Names_Active = IniRead($newlanguagefile, 'Column_Names', 'Column_Active', 'Active')
		$Column_Names_SSID = IniRead($newlanguagefile, 'Column_Names', 'Column_SSID', 'SSID')
		$Column_Names_BSSID = IniRead($newlanguagefile, 'Column_Names', 'Column_BSSID', 'Mac Address')
		$Column_Names_MANUF = IniRead($newlanguagefile, 'Column_Names', 'Column_Manufacturer', 'Manufacturer')
		$Column_Names_Signal = IniRead($newlanguagefile, 'Column_Names', 'Column_Signal', 'Signal')
		$Column_Names_Authentication = IniRead($newlanguagefile, 'Column_Names', 'Column_Authentication', 'Authentication')
		$Column_Names_Encryption = IniRead($newlanguagefile, 'Column_Names', 'Column_Encryption', 'Encryption')
		$Column_Names_RadioType = IniRead($newlanguagefile, 'Column_Names', 'Column_RadioType', 'Radio Type')
		$Column_Names_Channel = IniRead($newlanguagefile, 'Column_Names', 'Column_Channel', 'Channel')
		$Column_Names_Latitude = IniRead($newlanguagefile, 'Column_Names', 'Column_Latitude', 'Latitude')
		$Column_Names_Longitude = IniRead($newlanguagefile, 'Column_Names', 'Column_Longitude', 'Longitude')
		$Column_Names_BasicTransferRates = IniRead($newlanguagefile, 'Column_Names', 'Column_BasicTransferRates', 'Basic Transfer Rates')
		$Column_Names_OtherTransferRates = IniRead($newlanguagefile, 'Column_Names', 'Column_OtherTransferRates', 'Other Transfer Rates')
		$Column_Names_FirstActive = IniRead($newlanguagefile, 'Column_Names', 'Column_FirstActive', 'First Active')
		$Column_Names_LastActive = IniRead($newlanguagefile, 'Column_Names', 'Column_LastActive', 'Last Active')
		$Column_Names_NetworkType = IniRead($newlanguagefile, 'Column_Names', 'Column_NetworkType', 'Network Type')
		$Column_Names_Label = IniRead($newlanguagefile, 'Column_Names', 'Column_Label', 'Label')

		$Text_Ok = IniRead($newlanguagefile, 'GuiText', 'Ok', '&Ok')
		$Text_Cancel = IniRead($newlanguagefile, 'GuiText', 'Cancel', 'C&ancel')
		$Text_Apply = IniRead($newlanguagefile, 'GuiText', 'Apply', '&Apply')
		$Text_Browse = IniRead($newlanguagefile, 'GuiText', 'Browse', '&Browse')
		$Text_File = IniRead($newlanguagefile, 'GuiText', 'File', '&File')
		$Text_SaveAsTXT = IniRead($newlanguagefile, 'GuiText', 'SaveAsTXT', 'Save As TXT')
		$Text_SaveAsVS1 = IniRead($newlanguagefile, 'GuiText', 'SaveAsVS1', 'Save As VS1')
		$Text_SaveAsVSZ = IniRead($newlanguagefile, 'GuiText', 'SaveAsVSZ', 'Save As VSZ')
		$Text_ImportFromTXT = IniRead($newlanguagefile, 'GuiText', 'ImportFromTXT', 'Import From TXT / VS1')
		$Text_ImportFromVSZ = IniRead($newlanguagefile, 'GuiText', 'ImportFromVSZ', 'Import From VSZ')
		$Text_Exit = IniRead($newlanguagefile, 'GuiText', 'Exit', 'E&xit')
		$Text_Edit = IniRead($newlanguagefile, 'GuiText', 'Edit', 'E&dit')
		$Text_ClearAll = IniRead($newlanguagefile, 'GuiText', 'ClearAll', 'Clear All')
		$Text_Cut = IniRead($newlanguagefile, 'GuiText', 'Cut', 'Cut')
		$Text_Copy = IniRead($newlanguagefile, 'GuiText', 'Copy', 'Copy')
		$Text_Paste = IniRead($newlanguagefile, 'GuiText', 'Paste', 'Paste')
		$Text_Delete = IniRead($newlanguagefile, 'GuiText', 'Delete', 'Delete')
		$Text_Select = IniRead($newlanguagefile, 'GuiText', 'Select', 'Select')
		$Text_SelectAll = IniRead($newlanguagefile, 'GuiText', 'SelectAll', 'Select All')
		$Text_Options = IniRead($newlanguagefile, 'GuiText', 'Options', '&Options')
		$Text_AutoSort = IniRead($newlanguagefile, 'GuiText', 'AutoSort', 'AutoSort')
		$Text_SortTree = IniRead($newlanguagefile, 'GuiText', 'SortTree', 'Sort Tree(slow)')
		$Text_PlaySound = IniRead($newlanguagefile, 'GuiText', 'PlaySound', 'Play sound on new AP')
		$Text_AddAPsToTop = IniRead($newlanguagefile, 'GuiText', 'AddAPsToTop', 'Add new APs to top')
		$Text_Extra = IniRead($newlanguagefile, 'GuiText', 'Extra', 'Ex&tra')
		$Text_ScanAPs = IniRead($newlanguagefile, 'GuiText', 'ScanAPs', '&Scan APs')
		$Text_StopScanAps = IniRead($newlanguagefile, 'GuiText', 'StopScanAps', '&Stop')
		$Text_UseGPS = IniRead($newlanguagefile, 'GuiText', 'UseGPS', 'Use &GPS')
		$Text_StopGPS = IniRead($newlanguagefile, 'GuiText', 'StopGPS', 'Stop &GPS')
		$Text_Settings = IniRead($newlanguagefile, 'GuiText', 'Settings', 'S&ettings')
		$Text_GpsSettings = IniRead($newlanguagefile, 'GuiText', 'GpsSettings', 'G&PS Settings')
		$Text_SetLanguage = IniRead($newlanguagefile, 'GuiText', 'SetLanguage', 'Set &Language')
		$Text_SetSearchWords = IniRead($newlanguagefile, 'GuiText', 'SetSearchWords', 'Set Search &Words')
		$Text_SetMacLabel = IniRead($newlanguagefile, 'GuiText', 'SetMacLabel', 'Set Labels by Mac')
		$Text_SetMacManu = IniRead($newlanguagefile, 'GuiText', 'SetMacManu', 'Set Manufactures by Mac')
		$Text_Export = IniRead($newlanguagefile, 'GuiText', 'Export', 'Ex&port')
		$Text_ExportToKML = IniRead($newlanguagefile, 'GuiText', 'ExportToKML', 'Export To KML')
		$Text_ExportToTXT = IniRead($newlanguagefile, 'GuiText', 'ExportToTXT', 'Export To TXT')
		$Text_ExportToNS1 = IniRead($newlanguagefile, 'GuiText', 'ExportToNS1', 'Export To NS1')
		$Text_ExportToVS1 = IniRead($newlanguagefile, 'GuiText', 'ExportToVS1', 'Export To VS1')
		$Text_PhilsPHPgraph = IniRead($newlanguagefile, 'GuiText', 'PhilsPHPgraph', 'View graph (Phils PHP version)')
		$Text_PhilsWDB = IniRead($newlanguagefile, 'GuiText', 'PhilsWDB', 'Phils WiFiDB (Alpha)')
		$Text_RefreshLoopTime = IniRead($newlanguagefile, 'GuiText', 'RefreshLoopTime', 'Refresh loop time(ms):')
		$Text_ActualLoopTime = IniRead($newlanguagefile, 'GuiText', 'ActualLoopTime', 'Actual loop time:')
		$Text_Longitude = IniRead($newlanguagefile, 'GuiText', 'Longitude', 'Longitude:')
		$Text_Latitude = IniRead($newlanguagefile, 'GuiText', 'Latitude', 'Latitude:')
		$Text_ActiveAPs = IniRead($newlanguagefile, 'GuiText', 'ActiveAPs', 'Active APs:')
		$Text_Graph1 = IniRead($newlanguagefile, 'GuiText', 'Graph1', 'Graph1')
		$Text_Graph2 = IniRead($newlanguagefile, 'GuiText', 'Graph2', 'Graph2')
		$Text_NoGraph = IniRead($newlanguagefile, 'GuiText', 'NoGraph', 'No Graph')
		$Text_Active = IniRead($newlanguagefile, 'GuiText', 'Active', 'Active')
		$Text_Dead = IniRead($newlanguagefile, 'GuiText', 'Dead', 'Dead')
		$Text_AddNewLabel = IniRead($newlanguagefile, 'GuiText', 'AddNewLabel', 'Add New Label')
		$Text_RemoveLabel = IniRead($newlanguagefile, 'GuiText', 'RemoveLabel', 'Remove Selected Label')
		$Text_EditLabel = IniRead($newlanguagefile, 'GuiText', 'EditLabel', 'Edit Selected Label')
		$Text_AddNewMan = IniRead($newlanguagefile, 'GuiText', 'AddNewMan', 'Add New Manufacturer')
		$Text_RemoveMan = IniRead($newlanguagefile, 'GuiText', 'RemoveMan', 'Remove Selected Manufacturer')
		$Text_EditMan = IniRead($newlanguagefile, 'GuiText', 'EditMan', 'Edit Selected Manufacturer')
		$Text_NewMac = IniRead($newlanguagefile, 'GuiText', 'NewMac', 'New Mac Address:')
		$Text_NewMan = IniRead($newlanguagefile, 'GuiText', 'NewMan', 'New Manufacturer:')
		$Text_NewLabel = IniRead($newlanguagefile, 'GuiText', 'NewLabel', 'New label:')
		$Text_Save = IniRead($newlanguagefile, 'GuiText', 'Save', 'Save?')
		$Text_SaveQuestion = IniRead($newlanguagefile, 'GuiText', 'SaveQuestion', 'Data has changed. Would you like to save?')
		$Text_GpsDetails = IniRead($newlanguagefile, 'GuiText', 'GpsDetails', 'GPS Details')
		$Text_GpsCompass = IniRead($newlanguagefile, 'GuiText', 'GpsCompass', 'Gps Compass')
		$Text_Quality = IniRead($newlanguagefile, 'GuiText', 'Quality', 'Quality')
		$Text_Time = IniRead($newlanguagefile, 'GuiText', 'Time', 'Time')
		$Text_NumberOfSatalites = IniRead($newlanguagefile, 'GuiText', 'NumberOfSatalites', 'Number of Satalites')
		$Text_HorizontalDilutionPosition = IniRead($newlanguagefile, 'GuiText', 'HorizontalDilutionPosition', 'Horizontal Dilution')
		$Text_Altitude = IniRead($newlanguagefile, 'GuiText', 'Altitude', 'Altitude')
		$Text_HeightOfGeoid = IniRead($newlanguagefile, 'GuiText', 'HeightOfGeoid', 'Height of Geoid')
		$Text_Status = IniRead($newlanguagefile, 'GuiText', 'Status', 'Status')
		$Text_Date = IniRead($newlanguagefile, 'GuiText', 'Date', 'Date')
		$Text_SpeedInKnots = IniRead($newlanguagefile, 'GuiText', 'SpeedInKnots', 'Speed(knots)')
		$Text_SpeedInMPH = IniRead($newlanguagefile, 'GuiText', 'SpeedInMPH', 'Speed(MPH)')
		$Text_SpeedInKmh = IniRead($newlanguagefile, 'GuiText', 'SpeedInKmh', 'Speed(km/h)')
		$Text_TrackAngle = IniRead($newlanguagefile, 'GuiText', 'TrackAngle', 'Track Angle')
		$Text_Close = IniRead($newlanguagefile, 'GuiText', 'Close', 'Track Close')
		$Text_ConnectToWindowName = IniRead($newlanguagefile, 'GuiText', 'ConnectToWindowName', 'Connect to a network')
		$Text_RefreshNetworks = IniRead($newlanguagefile, 'GuiText', 'StartRefreshingNetworks', 'Refreshing Networks')
		$Text_Start = IniRead($newlanguagefile, 'GuiText', 'Start', 'Start')
		$Text_Stop = IniRead($newlanguagefile, 'GuiText', 'Stop', 'Stop')
		$Text_ConnectToWindowTitle = IniRead($newlanguagefile, 'GuiText', 'ConnectToWindowTitle', '"Connect to" window title:')
		$Text_RefreshTime = IniRead($newlanguagefile, 'GuiText', 'RefreshTime', 'Refresh time (in ms)')
		$Text_SetColumnWidths = IniRead($newlanguagefile, 'GuiText', 'SetColumnWidths', 'Set Column Widths')
		$Text_Enable = IniRead($newlanguagefile, 'GuiText', 'Enable', 'Enable')
		$Text_Disable = IniRead($newlanguagefile, 'GuiText', 'Disable', 'Disable')
		$Text_Checked = IniRead($newlanguagefile, 'GuiText', 'Checked', 'Checked')
		$Text_UnChecked = IniRead($newlanguagefile, 'GuiText', 'UnChecked', 'UnChecked')
		$Text_Unknown = IniRead($newlanguagefile, 'GuiText', 'Unknown', 'Unknown')
		$Text_Restart = IniRead($newlanguagefile, 'GuiText', 'Restart', 'Restart')
		$Text_RestartMsg = IniRead($newlanguagefile, 'GuiText', 'RestartMsg', 'Please restart Vistumbler for language change to take effect')
		$Text_Error = IniRead($newlanguagefile, 'GuiText', 'Error', 'Error')
		$Text_NoSignalHistory = IniRead($newlanguagefile, 'GuiText', 'NoSignalHistory', 'No signal history found, check to make sure your netsh search words are correct')
		$Text_NoApSelected = IniRead($newlanguagefile, 'GuiText', 'NoApSelected', 'You did not select an access point')
		$Text_UseNetcomm = IniRead($newlanguagefile, 'GuiText', 'UseNetcomm', 'Use Netcomm OCX (more stable) - x32')
		$Text_UseCommMG = IniRead($newlanguagefile, 'GuiText', 'UseCommMG', 'Use CommMG (less stable) - x32 - x64')
		$Text_SignalHistory = IniRead($newlanguagefile, 'GuiText', 'SignalHistory', 'Signal History')
		$Text_AutoSortEvery = IniRead($newlanguagefile, 'GuiText', 'AutoSortEvery', 'Auto Sort Every')
		$Text_Seconds = IniRead($newlanguagefile, 'GuiText', 'Seconds', 'Seconds')
		$Text_Ascending = IniRead($newlanguagefile, 'GuiText', 'Ascending', 'Ascending')
		$Text_Decending = IniRead($newlanguagefile, 'GuiText', 'Decending', 'Decending')
		$Text_AutoSave = IniRead($newlanguagefile, 'GuiText', 'AutoSave', 'AutoSave')
		$Text_AutoSaveEvery = IniRead($newlanguagefile, 'GuiText', 'AutoSaveEvery', 'AutoSave Every')
		$Text_DelAutoSaveOnExit = IniRead($newlanguagefile, 'GuiText', 'DelAutoSaveOnExit', 'Delete Autosave file on exit')
		$Text_OpenSaveFolder = IniRead($newlanguagefile, 'GuiText', 'OpenSaveFolder', 'Open Save Folder')
		$Text_SortBy = IniRead($newlanguagefile, 'GuiText', 'SortBy', 'Sort By')
		$Text_SortDirection = IniRead($newlanguagefile, 'GuiText', 'SortDirection', 'Sort Direction')
		$Text_Auto = IniRead($newlanguagefile, 'GuiText', 'Auto', 'Auto')
		$Text_Misc = IniRead($newlanguagefile, 'GuiText', 'Misc', 'Misc')
		$Text_Gps = IniRead($newlanguagefile, 'GuiText', 'GPS', 'GPS')
		$Text_Labels = IniRead($newlanguagefile, 'GuiText', 'Labels', 'Labels')
		$Text_Manufacturers = IniRead($newlanguagefile, 'GuiText', 'Manufacturers', 'Manufacturers')
		$Text_Columns = IniRead($newlanguagefile, 'GuiText', 'Columns', 'Columns')
		$Text_Language = IniRead($newlanguagefile, 'GuiText', 'Language', 'Language')
		$Text_SearchWords = IniRead($newlanguagefile, 'GuiText', 'SearchWords', 'SearchWords')
		$Text_VistumblerSettings = IniRead($newlanguagefile, 'GuiText', 'VistumblerSettings', 'Vistumbler Settings')
		$Text_LanguageAuthor = IniRead($newlanguagefile, 'GuiText', 'LanguageAuthor', 'Language Author')
		$Text_LanguageDate = IniRead($newlanguagefile, 'GuiText', 'LanguageDate', 'Language Date')
		$Text_LanguageDescription = IniRead($newlanguagefile, 'GuiText', 'LanguageDescription', 'Language Description')
		$Text_Description = IniRead($newlanguagefile, 'GuiText', 'Description', 'Description')
		$Text_Progress = IniRead($newlanguagefile, 'GuiText', 'Progress', 'Progress')
		$Text_LinesMin = IniRead($newlanguagefile, 'GuiText', 'LinesMin', 'Lines/Min')
		$Text_NewAPs = IniRead($newlanguagefile, 'GuiText', 'NewAPs', 'New APs')
		$Text_NewGIDs = IniRead($newlanguagefile, 'GuiText', 'NewGIDs', 'New GIDs')
		$Text_Minutes = IniRead($newlanguagefile, 'GuiText', 'Minutes', 'Minutes')
		$Text_LineTotal = IniRead($newlanguagefile, 'GuiText', 'LineTotal', 'Line/Total')
		$Text_EstimatedTimeRemaining = IniRead($newlanguagefile, 'GuiText', 'EstimatedTimeRemaining', 'Estimated Time Remaining')
		$Text_Ready = IniRead($newlanguagefile, 'GuiText', 'Ready', 'Ready')
		$Text_Done = IniRead($newlanguagefile, 'GuiText', 'Done', 'Done')
		$Text_VistumblerSaveDirectory = IniRead($newlanguagefile, 'GuiText', 'VistumblerSaveDirectory', 'Vistumbler Save Directory')
		$Text_VistumblerAutoSaveDirectory = IniRead($newlanguagefile, 'GuiText', 'VistumblerAutoSaveDirectory', 'Vistumbler Auto Save Directory')
		$Text_VistumblerKmlSaveDirectory = IniRead($newlanguagefile, 'GuiText', 'VistumblerKmlSaveDirectory', 'Vistumbler KML Save Directory')
		$Text_BackgroundColor = IniRead($newlanguagefile, 'GuiText', 'BackgroundColor', 'Background Color')
		$Text_ControlColor = IniRead($newlanguagefile, 'GuiText', 'ControlColor', 'Control Color')
		$Text_BgFontColor = IniRead($newlanguagefile, 'GuiText', 'BgFontColor', 'Font Color')
		$Text_ConFontColor = IniRead($newlanguagefile, 'GuiText', 'ConFontColor', 'Control Font Color')
		$Text_NetshMsg = IniRead($newlanguagefile, 'GuiText', 'NetshMsg', 'This section allows you to change the words Vistumbler uses to search netsh. Change to the proper words for you version of windows. Run "netsh wlan show networks mode = bssid" to find the proper words.')
		$Text_PHPgraphing = IniRead($newlanguagefile, 'GuiText', 'PHPgraphing', 'PHP Graphing')
		$Text_ComInterface = IniRead($newlanguagefile, 'GuiText', 'ComInterface', 'Com Interface')
		$Text_ComSettings = IniRead($newlanguagefile, 'GuiText', 'ComSettings', 'Com Settings')
		$Text_Com = IniRead($newlanguagefile, 'GuiText', 'Com', 'Com')
		$Text_Baud = IniRead($newlanguagefile, 'GuiText', 'Baud', 'Baud')
		$Text_GPSFormat = IniRead($newlanguagefile, 'GuiText', 'GPSFormat', 'GPS Format')
		$Text_HideOtherGpsColumns = IniRead($newlanguagefile, 'GuiText', 'HideOtherGpsColumns', 'Hide Other GPS Columns')
		$Text_ImportLanguageFile = IniRead($newlanguagefile, 'GuiText', 'ImportLanguageFile', 'Import Language File')
		$Text_AutoKml = IniRead($newlanguagefile, 'GuiText', 'AutoKml', 'Auto KML')
		$Text_GoogleEarthEXE = IniRead($newlanguagefile, 'GuiText', 'GoogleEarthEXE', 'Google Earth EXE')
		$Text_AutoSaveKmlEvery = IniRead($newlanguagefile, 'GuiText', 'AutoSaveKmlEvery', 'Auto Save KML Every')
		$Text_SavedAs = IniRead($newlanguagefile, 'GuiText', 'SavedAs', 'Saved As')
		$Text_Overwrite = IniRead($newlanguagefile, 'GuiText', 'Overwrite', 'Overwrite')
		$Text_InstallNetcommOCX = IniRead($newlanguagefile, 'GuiText', 'InstallNetcommOCX', 'Install Netcomm OCX')
		$Text_NoFileSaved = IniRead($newlanguagefile, 'GuiText', 'NoFileSaved', 'No file has been saved')
		$Text_NoApsWithGps = IniRead($newlanguagefile, 'GuiText', 'NoApsWithGps', 'No Access Points found with GPS coordinates.')
		$Text_MacExistsOverwriteIt = IniRead($newlanguagefile, 'GuiText', 'MacExistsOverwriteIt', 'A entry for this mac address already exists. would you like to overwrite it?')
		$Text_SavingLine = IniRead($newlanguagefile, 'GuiText', 'SavingLine', 'Saving Line')
		$Text_DisplayDebug = IniRead($newlanguagefile, 'GuiText', 'DisplayDebug', 'Debug - Display Functions')
		$Text_OpenKmlNetLink = IniRead($newlanguagefile, 'GuiText', 'OpenKmlNetLink', 'Open KML NetworkLink')
		$Text_ActiveRefreshTime = IniRead($newlanguagefile, 'GuiText', 'ActiveRefreshTime', 'Active Refresh Time')
		$Text_DeadRefreshTime = IniRead($newlanguagefile, 'GuiText', 'DeadRefreshTime', 'Dead Refresh Time')
		$Text_GpsRefrshTime = IniRead($newlanguagefile, 'GuiText', 'GpsRefrshTime', 'Gps Refrsh Time')
		$Text_FlyToSettings = IniRead($newlanguagefile, 'GuiText', 'FlyToSettings', 'Fly To Settings')
		$Text_FlyToCurrentGps = IniRead($newlanguagefile, 'GuiText', 'FlyToCurrentGps', 'Fly to current gps position')
		$Text_AltitudeMode = IniRead($newlanguagefile, 'GuiText', 'AltitudeMode', 'Altitude Mode')
		$Text_Range = IniRead($newlanguagefile, 'GuiText', 'Range', 'Range')
		$Text_Heading = IniRead($newlanguagefile, 'GuiText', 'Heading', 'Heading')
		$Text_Tilt = IniRead($newlanguagefile, 'GuiText', 'Tilt', 'Tilt')
		$Text_AutoOpenNetworkLink = IniRead($newlanguagefile, 'GuiText', 'AutoOpenNetworkLink', 'Automatically Open KML Network Link')
		$Text_SpeakSignal = IniRead($newlanguagefile, 'GuiText', 'SpeakSignal', 'Speak Signal')
		$Text_SpeakUseVisSounds = IniRead($newlanguagefile, 'GuiText', 'SpeakUseVisSounds', 'Use Vistumbler Sound Files')
		$Text_SpeakUseSapi = IniRead($newlanguagefile, 'GuiText', 'SpeakUseSapi', 'Use Microsoft Sound API')
		$Text_SpeakSayPercent = IniRead($newlanguagefile, 'GuiText', 'SpeakSayPercent', 'Say "Percent" after signal')
		$Text_GpsTrackTime = IniRead($newlanguagefile, 'GuiText', 'GpsTrackTime', 'Track Refresh Time')
		$RestartVistumbler = 1
	EndIf
	If $Apply_Manu = 1 Then
		;Remove all current Mac address/labels in the array
		Dim $manu_mac[1]
		Dim $manu_manu[1]
		;Rewrite Mac address/labels from listview into the array
		$itemcount = _GUICtrlListView_GetItemCount($GUI_Manu_List) - 1; Get List Size
		For $findloop = 0 To $itemcount
			_ArrayAdd($manu_mac, StringReplace(_GUICtrlListView_GetItemText($GUI_Manu_List, $itemcount - $findloop, 0), '"', ''))
			_ArrayAdd($manu_manu, _GUICtrlListView_GetItemText($GUI_Manu_List, $itemcount - $findloop, 1))
		Next
		$manu_mac[0] = UBound($manu_mac) - 1
		$manu_manu[0] = UBound($manu_manu) - 1
		;rewrite manufacturer ini
		IniDelete($manufini, "MANUFACURERS")
		For $m = 1 To $manu_mac[0]
			IniWrite($manufini, "MANUFACURERS", $manu_mac[$m], $manu_manu[$m])
		Next
		;Set flag so Labels get reset
		$ResetManLabel = 1
	EndIf
	If $Apply_Lab = 1 Then
		;Remove all current Mac address/labels in the array
		Dim $label_mac[1]
		Dim $label_label[1]
		;Rewrite Mac address/labels from listview into the array
		$itemcount = _GUICtrlListView_GetItemCount($GUI_Lab_List) - 1; Get List Size
		For $findloop = 0 To $itemcount
			_ArrayAdd($label_mac, StringReplace(_GUICtrlListView_GetItemText($GUI_Lab_List, $itemcount - $findloop, 0), '"', ''))
			_ArrayAdd($label_label, _GUICtrlListView_GetItemText($GUI_Lab_List, $itemcount - $findloop, 1))
		Next
		$label_mac[0] = UBound($label_mac) - 1
		$label_label[0] = UBound($label_label) - 1
		;rewrite manufacturer ini
		IniDelete($labelsini, "LABELS")
		For $m = 1 To $label_mac[0]
			IniWrite($labelsini, "LABELS", $label_mac[$m], $label_label[$m])
		Next
		;Set flag so Labels get reset
		$ResetMacLabel = 1
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
		Else
			$SpeakType = 2 ;Set SAPI default speak signal interface
		EndIf
		If GUICtrlRead($GUI_SpeakPercent) = 1 Then
			$SpeakSigSayPecent = 1;Say Percent
		Else
			$SpeakSigSayPecent = 0;Don't say percent
		EndIf
		$SpeakSigTime = GUICtrlRead($GUI_SpeakSigTime)
	EndIf

	Dim $Apply_GPS = 1, $Apply_Language = 0, $Apply_Manu = 0, $Apply_Lab = 0, $Apply_Column = 1, $Apply_Searchword = 1, $Apply_Misc = 1, $Apply_Auto = 1, $Apply_AutoKML = 1
	If $RestartVistumbler = 1 Then MsgBox(0, $Text_Restart, $Text_RestartMsg)
	;Dim $Apply_GPS = 0, $Apply_Language = 0, $Apply_Manu = 0, $Apply_Lab = 0, $Apply_Column = 0, $Apply_Searchword = 0, $Apply_Misc = 0
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
		$EditMacGUIForm = GUICreate("Edit Manufacturer", 625, 86, -1, -1)
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

;-------------------------------------------------------------------------------------------------------------------------------
;                                                       OTHER FUNCTIONS
;-------------------------------------------------------------------------------------------------------------------------------

Func _CompareDate($d1, $d2);If $d1 is greater than $d2, return 1 ELSE return 2
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_CompareDate()') ;#Debug Display
	$d1split = StringSplit($d1, ' ')
	$d2split = StringSplit($d2, ' ')
	
	If $d1split[0] >= 2 And $d2split[0] >= 2 Then
		$date1 = StringSplit($d1split[1], '-')
		$time1 = StringSplit($d1split[2], ':')
		;$ms1 = $d1split[3]
		$date1month = $date1[1]
		$date1day = $date1[2]
		$date1year = $date1[3]
		$time1hour = $time1[1]
		$time1minute = $time1[2]
		$time1second = $time1[3]
		$date2 = StringSplit($d2split[1], '-')
		$time2 = StringSplit($d2split[2], ':')
		;$ms2 = $d2split[3]
		$date2month = $date2[1]
		$date2day = $date2[2]
		$date2year = $date2[3]
		$time2hour = $time2[1]
		$time2minute = $time2[2]
		$time2second = $time2[3]
		
		If $date1year > $date2year Then
			$greater = $d1
			$less = $d2
		ElseIf $date1year < $date2year Then
			$greater = $d2
			$less = $d1
		Else
			If $date1month > $date2month Then
				$greater = $d1
				$less = $d2
			ElseIf $date1month < $date2month Then
				$greater = $d2
				$less = $d1
			Else
				If $date1day > $date2day Then
					$greater = $d1
					$less = $d2
				ElseIf $date1day < $date2day Then
					$greater = $d2
					$less = $d1
				Else
					If $time1hour > $time2hour Then
						$greater = $d1
						$less = $d2
					ElseIf $time1hour < $time2hour Then
						$greater = $d2
						$less = $d1
					Else
						If $time1minute > $time2minute Then
							$greater = $d1
							$less = $d2
						ElseIf $time1minute < $time2minute Then
							$greater = $d2
							$less = $d1
						Else
							If $time1second > $time2second Then
								$greater = $d1
								$less = $d2
							Else
								$greater = $d2
								$less = $d1
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
		If $d1 = $greater Then
			Return 1
		Else
			Return 2
		EndIf
	EndIf

EndFunc   ;==>_CompareDate

Func _ReadIniSectionToArrays($ini, ByRef $ar1, ByRef $ar2, $section)
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_ReadIniSectionToArrays()') ;#Debug Display
	$var = IniReadSection($ini, $section)
	If Not @error Then
		For $i = 1 To $var[0][0]
			_ArrayAdd($ar1, StringUpper($var[$i][0]))
			_ArrayAdd($ar2, $var[$i][1])
		Next
		$ar1[0] = UBound($ar2) - 1
		$ar2[0] = UBound($ar2) - 1
	EndIf
EndFunc   ;==>_ReadIniSectionToArrays

Func _GUICtrlTab_SetBkColor($hWnd, $hSysTab32, $sBkColor) ;Function used to set the background color in a tab --> http://www.autoitscript.com/forum/index.php?showtopic=40659&view=findpost&p=497705
	If $Debug = 1 Then GUICtrlSetData($debugdisplay, '_GUICtrlTab_SetBkColor()') ;#Debug Display
	Local $aTabPos = ControlGetPos($hWnd, "", $hSysTab32)
	Local $aTab_Rect = _GUICtrlTab_GetItemRect($hSysTab32, -1)
	GUICtrlCreateLabel("", $aTabPos[0] + 2, $aTabPos[1] + $aTab_Rect[3] + 4, $aTabPos[2] - 4, $aTabPos[3] - $aTab_Rect[3] - 7)
	GUICtrlSetBkColor(-1, $sBkColor)
	GUICtrlSetState(-1, $GUI_DISABLE)
EndFunc   ;==>_GUICtrlTab_SetBkColor

Func _TimeLocalToGmt($time)
	$timesplit = StringSplit($time, ':')
	If $timesplit[0] = 3 Then
		$hour = $timesplit[1]
		$min = $timesplit[2]
		$sec = $timesplit[3]

		$tzinfo = _Date_Time_GetTimeZoneInformation()
		$Offset = $tzinfo[1] / 60
		$hour = $hour + $Offset
		
		If $hour > 24 Then $hour = $hour - 12
		Return ($hour & ":" & $min & ":" & $sec)
	Else
		Return ("00:00:00")
	EndIf
EndFunc   ;==>_TimeLocalToGmt

Func _TimeGmtToLocal($time)
	$timesplit = StringSplit($time, ':')
	If $timesplit[0] = 3 Then
		$hour = $timesplit[1]
		$min = $timesplit[2]
		$sec = $timesplit[3]

		$tzinfo = _Date_Time_GetTimeZoneInformation()
		$Offset = $tzinfo[1] / 60
		$hour = $hour - $Offset
		
		If $hour < 0 Then $hour = $hour + 24
		Return ($hour & ":" & $min & ":" & $sec)
	Else
		Return ("00:00:00")
	EndIf
EndFunc   ;==>_TimeGmtToLocal

Func _ReduceMemory() ;http://www.autoitscript.com/forum/index.php?showtopic=14070&view=findpost&p=96101
	DllCall("psapi.dll", 'int', 'EmptyWorkingSet', 'long', -1)
EndFunc   ;==>_ReduceMemory

Func _SpeakSelectedSignal();Finds the slected access point and speaks its signal strenth
	$Error = 0
	If $SpeakSignal = 1 Then; If the signal speaking is turned on
		$Selected = _GUICtrlListView_GetNextItem($ListviewAPs); find what AP is selected in the list. returns -1 is nothing is selected
		If $Selected <> -1 Then ;If a access point is selected in the listview, play its signal strenth
			$line = _GUICtrlListView_GetItemText($ListviewAPs, $Selected, $column_Line)
			For $finddata = 1 To $DataArray_Line[0]
				If $DataArray_Line[$finddata] = $line Then
					$say = $DataArray_Sig[$finddata]
					If $SpeakSigSayPecent = 1 Then $say &= '%'
					If ProcessExists($SayProcess) = 0 Then;If Say.exe is still running, skip opening it again
						If $SpeakType = 1 Then
							$SayProcess = Run(@ComSpec & " /C " & FileGetShortName(@ScriptDir & '\say.exe') & ' /s="' & $say & '" /t=1', '', @SW_HIDE)
							If @error Then $Error = 1
							;ConsoleWrite($Error & @CRLF)
						Else
							$SayProcess = Run(@ComSpec & " /C " & FileGetShortName(@ScriptDir & '\say.exe') & ' /s="' & $say & '" /t=2', '', @SW_HIDE)
							If @error Then $Error = 1
							;ConsoleWrite($Error & @CRLF)
						EndIf
					Else
						$Error = 1
					EndIf
					ExitLoop
				EndIf
			Next
		EndIf
	EndIf
	If $Error = 0 Then
		Return (1)
	Else
		Return (0)
	EndIf
EndFunc   ;==>_SpeakSelectedSignal