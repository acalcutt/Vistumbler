#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\VistumblerMDB\Icons\icon.ico
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
;License Information------------------------------------
;Copyright (C) 2015 Andrew Calcutt
;This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; Version 2 of the License.
;This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
;You should have received a copy of the GNU General Public License along with this program; If not, see <http://www.gnu.org/licenses/gpl-2.0.html>.
;--------------------------------------------------------
;AutoIt Version: v3.3.14.2
$Script_Author = 'Andrew Calcutt'
$Script_Name = 'WiFiDB Uploader'
$Script_Website = 'http://www.Vistumbler.net'
$Script_Function = 'A program to batch upload files to the wifidb using the api'
$version = 'v0.3'
$last_modified = '2015/12/28'
HttpSetUserAgent($Script_Name & ' ' & $version)
;Includes------------------------------------------------#include "UDFs\FileListToArray3.au3"
#include "UDFs\MD5.au3"
#include "UDFs\Base64.au3"
#include "UDFs\AccessCom.au3"
#include "UDFs\HTTP.au3"
#include "UDFs\JSON.au3"
#include <Array.au3>
#include <File.au3>
#include <INet.au3>
#include <String.au3>
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <GUIListBox.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <GuiListView.au3>
;Options-------------------------------------------------
Opt("TrayIconHide", 1);Hide icon in system tray
Opt("GUIResizeMode", 576)

$oMyError = ObjEvent("AutoIt.Error", "MyErrFunc")

Dim $TmpDir = @ScriptDir & '\'
Dim $settings = $TmpDir & 'settings.ini'
Dim $WdbUser = IniRead($settings, 'Settings', 'WdbUser', 'Unknown')
Dim $WdbApiKey = IniRead($settings, 'Settings', 'WdbApiKey', '')
Dim $WdbOtherUser = IniRead($settings, 'Settings', 'WdbOtherUser', '')
Dim $DefaultTitle = IniRead($settings, 'Settings', 'DefaultTitle', 'WDB Batch Upload')
Dim $DefaultNotes = IniRead($settings, 'Settings', 'DefaultNotes', '')
Dim $WifiDbApiURL = IniRead($settings, 'Settings', 'WifiDbApiURL', 'https://api.wifidb.net/')
Dim $AutoImportFolder = IniRead($settings, 'AutoSettings', 'AutoImportFolder', '')
Dim $AutoImport = IniRead($settings, 'AutoSettings', 'AutoImport', 0)
Dim $AutoUpload = IniRead($settings, 'AutoSettings', 'AutoUpload', 0)
Dim $AutoRefreshWating = IniRead($settings, 'AutoSettings', 'AutoRefreshWating', 1)
Dim $AutoImportDefaults = IniRead($settings, 'AutoSettings', 'AutoImportDefaults', 0)
Dim $AutoUploadDefaults = IniRead($settings, 'AutoSettings', 'AutoUploadDefaults', 0)
Dim $DefaultStatus = 'new'
Dim $DefaultStatusText = 'Not Yet Checked'

Dim $ColStatus = 0
Dim $ColStatusMessage = 1
Dim $ColFile = 2
Dim $ColTitle = 3
Dim $ColNotes = 4
Dim $ColMD5 = 5
Dim $columns = 'WDB Status|WDB Status Message|File|Title|Notes|Hash'

Dim $FILE_ID
Dim $DB = $TmpDir & 'files.mdb'
Dim $filename
Dim $DB_OBJ

;Set Up DB
$ExistingDB = FileExists($DB)
If $ExistingDB = 1 Then ConsoleWrite("! " & $DB & " already exits. Import will use existing file" & @CRLF)
If $ExistingDB = 0 Then ConsoleWrite("+> Creating " & $DB & @CRLF)
If $ExistingDB = 1 Then
	_AccessConnectConn($DB, $DB_OBJ)
	_GetDbValues($DB)
EndIf
If $ExistingDB = 0 Then _SetUpDbTables($DB)

;Create GUI
$GUI_wifidbuploader = GUICreate($Script_Name & " " & $version, 700, 513, -1, -1, BitOR($WS_OVERLAPPEDWINDOW, $WS_CLIPSIBLINGS))
$Menu_File = GUICtrlCreateMenu("File")
$Menu_ImportFolder = GUICtrlCreateMenuItem("Import Folder", $Menu_File)
$Menu_ImportFile = GUICtrlCreateMenuItem("Import File", $Menu_File)
$Menu_ExitSaveDB = GUICtrlCreateMenuItem("Exit and Save DB (for testing only)", $Menu_File)
$Menu_Exit = GUICtrlCreateMenuItem("Exit", $Menu_File)
$Menu_settings = GUICtrlCreateMenu("Settings")
$Menu_AutoSettings = GUICtrlCreateMenuItem("Auto Settings", $Menu_settings)
$Menu_UploadSettings = GUICtrlCreateMenuItem("Upload Settings", $Menu_settings)
$Menu_ImportSettings = GUICtrlCreateMenuItem("Import Settings", $Menu_settings)

$btn_upload = GUICtrlCreateButton("Upload 'unknown' files", 8, 5, 145, 33)
$btn_refresh = GUICtrlCreateButton("Refresh unfinished files", 164, 5, 145, 33)
$msgdisplay = GUICtrlCreateLabel("", 8, 40, 484, 20)
$ulist = _GUICtrlListView_Create($GUI_wifidbuploader, $columns, 5, 65, 690, 422, $LVS_REPORT)
_GUICtrlListView_SetExtendedListViewStyle($ulist, BitOR($LVS_EX_HEADERDRAGDROP, $LVS_EX_GRIDLINES, $LVS_EX_FULLROWSELECT, $LVS_EX_DOUBLEBUFFER))
_GUICtrlListView_SetColumnWidth($ulist, $ColStatus, 75)
_GUICtrlListView_SetColumnWidth($ulist, $ColStatusMessage, 150)
_GUICtrlListView_SetColumnWidth($ulist, $ColFile, 200)
_GUICtrlListView_SetColumnWidth($ulist, $ColTitle, 100)
_GUICtrlListView_SetColumnWidth($ulist, $ColNotes, 100)
_GUICtrlListView_SetColumnWidth($ulist, $ColMD5, 250)

GUISetState(@SW_SHOW)
If $AutoImport = 1 And $AutoImportFolder <> "" Then _LoadFolderSelect($AutoImportFolder)
If $AutoUpload = 1 Then _UploadUnknownFiles()
_UpdateListview()

$RefreshTimer = TimerInit()
While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			_Exit()
		Case $Menu_Exit
			_Exit()
		Case $Menu_ExitSaveDB
			_Exit_SaveDB()
		Case $Menu_ImportFolder
			_LoadFolderSelect()
		Case $Menu_ImportFile
			_LoadFileSelect()
		Case $Menu_AutoSettings
			_GuiAutoSettings()
		Case $Menu_UploadSettings
			_GuiUploadSettings()
		Case $Menu_ImportSettings
			_GuiImportSettings()
		Case $btn_upload
			If $AutoUploadDefaults = 1 Then
				_UploadUnknownFiles()
				_UpdateListview()
			Else
				If _GuiUploadSettings() = 1 Then
					_UploadUnknownFiles()
					_UpdateListview()
				Else
					GUICtrlSetData($msgdisplay, "Error. 'Upload Settings' were not set.")
				EndIf
			EndIf
		Case $btn_refresh
			_CheckUnfinishedFiles()
	EndSwitch
	If $AutoRefreshWating = 1 And TimerDiff($RefreshTimer) > 300000 Then _CheckUnfinishedFiles()
WEnd


;----------------------------------------------------------------------------
;                              Functions
;----------------------------------------------------------------------------

Func _Exit()
	_SaveSettings()
	_AccessCloseConn($DB_OBJ)
	FileDelete($DB)
	Exit
EndFunc   ;==>_Exit

Func _Exit_SaveDB()
	_SaveSettings()
	_AccessCloseConn($DB_OBJ)
	Exit
EndFunc   ;==>_Exit

Func _SaveSettings()
	IniWrite($settings, 'Settings', 'WdbUser', $WdbUser)
	IniWrite($settings, 'Settings', 'WdbApiKey', $WdbApiKey)
	IniWrite($settings, 'Settings', 'WdbOtherUser', $WdbOtherUser)
	IniWrite($settings, 'Settings', 'DefaultTitle', $DefaultTitle)
	IniWrite($settings, 'Settings', 'DefaultNotes', $DefaultNotes)
	IniWrite($settings, 'Settings', 'WifiDbApiURL', $WifiDbApiURL)

	IniWrite($settings, 'AutoSettings', 'AutoImportFolder', $AutoImportFolder)
	IniWrite($settings, 'AutoSettings', 'AutoImport', $AutoImport)
	IniWrite($settings, 'AutoSettings', 'AutoUpload', $AutoUpload)
	IniWrite($settings, 'AutoSettings', 'AutoRefreshWating', $AutoRefreshWating)
	IniWrite($settings, 'AutoSettings', 'AutoImportDefaults', $AutoImportDefaults)
	IniWrite($settings, 'AutoSettings', 'AutoUploadDefaults', $AutoUploadDefaults)
EndFunc   ;==>_SaveSettings

Func _SetUpDbTables($dbfile)
	_CreateDB($dbfile)
	_AccessConnectConn($dbfile, $DB_OBJ)
	_CreateTable($dbfile, 'UploadFiles', $DB_OBJ)
	_CreatMultipleFields($dbfile, 'UploadFiles', $DB_OBJ, 'filename TEXT(255)|md5 TEXT(255)|uploadtitle TEXT(255)|uploadnotes TEXT(255)|wdbstatus TEXT(255)|wdbstatustext TEXT(255)')
EndFunc   ;==>_SetUpDbTables

Func _GetDbValues($dbfile)
	;Get Counts
	$query = "Select COUNT(filename) FROM UploadFiles"
	$FileMatchArray = _RecordSearch($dbfile, $query, $DB_OBJ)
	$FILE_ID = $FileMatchArray[1][1]
	ConsoleWrite('$FILE_ID:' & $FILE_ID & @CRLF)
EndFunc   ;==>_GetDbValues

Func _UpdateListview()
	GUICtrlSetData($msgdisplay, "Updating List")
	Local $szDrive, $szDir, $szFName, $szExt
	_GUICtrlListView_BeginUpdate($ulist)
	_GUICtrlListView_DeleteAllItems($ulist)
	$query = "SELECT filename, md5, uploadtitle, uploadnotes, wdbstatus, wdbstatustext FROM UploadFiles ORDER BY wdbstatus DESC"; WHERE wdbstatus='unknown'"
	ConsoleWrite("$query:" & $query & @CRLF)
	$FileMatchArray = _RecordSearch($DB, $query, $DB_OBJ)
	$FoundFileMatch = UBound($FileMatchArray) - 1

	For $cf = 1 To $FoundFileMatch
		$filefullname = $FileMatchArray[$cf][1]
		$md5 = $FileMatchArray[$cf][2]
		$uploadtitle = $FileMatchArray[$cf][3]
		$uploadnotes = $FileMatchArray[$cf][4]
		$wdbstatus = $FileMatchArray[$cf][5]
		$wdbstatustext = $FileMatchArray[$cf][6]


		_PathSplit($filefullname, $szDrive, $szDir, $szFName, $szExt)
		$filename = $szFName & $szExt

		$line = _GUICtrlListView_AddItem($ulist, $wdbstatus, $ColStatus)
		_GUICtrlListView_AddSubItem($ulist, $line, $md5, $ColMD5)
		_GUICtrlListView_AddSubItem($ulist, $line, $uploadtitle, $ColTitle)
		_GUICtrlListView_AddSubItem($ulist, $line, $uploadnotes, $ColNotes)
		_GUICtrlListView_AddSubItem($ulist, $line, $filename, $ColFile)
		_GUICtrlListView_AddSubItem($ulist, $line, $wdbstatustext, $ColStatusMessage)

	Next
	_GUICtrlListView_EndUpdate($ulist)
	GUICtrlSetData($msgdisplay, "")
EndFunc   ;==>_UpdateListview

Func _LoadFolderSelect($loadfolder="")
	GUISetState(@SW_HIDE, $GUI_wifidbuploader)
	If $loadfolder="" Then
		$loadfolder = FileSelectFolder("Select folder that contains vistumbler vs1 files", @ScriptDir)
		If @error Then
			GUICtrlSetData($msgdisplay, "Error. No folder selected")
			Return(0)
		EndIf
	EndIf
	If $loadfolder = "" Then
		GUICtrlSetData($msgdisplay, "Error. Folder is blank")
	Else
		If $AutoImportDefaults = 1 Then
			_LoadFolder($loadfolder)
			_CheckNewFiles()
			_UpdateListview()
		Else
			If _GuiImportSettings() = 1 Then
				_LoadFolder($loadfolder)
				_CheckNewFiles()
				_UpdateListview()
			Else
				GUICtrlSetData($msgdisplay, "Error. 'Import Settings' were not set.")
			EndIf
		EndIf
	EndIf
	GUISetState(@SW_SHOW, $GUI_wifidbuploader)
EndFunc   ;==>_LoadFolderSelect

Func _LoadFolder($loadfolder)
	GUICtrlSetData($msgdisplay, "Loading Files in '" & $loadfolder & "'")
	$VistumblerFiles = _FileListToArray($loadfolder, "*.VS1", 1, 1)
	For $f = 1 To $VistumblerFiles[0]
		GUICtrlSetData($msgdisplay, "Loading File ( " & $f & " of " & $VistumblerFiles[0] & " )")
		;Safe Kill Import if killswitch is set
		$KillSwitch = IniRead($settings, 'Settings', 'KillSwitch', '0')
		If $KillSwitch = 1 Then
			GUICtrlSetData($msgdisplay, "! Kill switch is enabled. Exiting...")
			ConsoleWrite("! Kill switch is enabled. Exiting...")
			ExitLoop
		EndIf
		ConsoleWrite('File:' & $f & '/' & $VistumblerFiles[0] & ' | File:' & $VistumblerFiles[$f])
		_LoadFile($VistumblerFiles[$f])
	Next
EndFunc   ;==>_LoadFolder

Func _LoadFileSelect()
	GUISetState(@SW_HIDE, $GUI_wifidbuploader)
	$loadfile = FileOpenDialog("Select vs1 file", @ScriptDir, "Vistumbler VS1 (*.vs1)")
	If @error Then
		GUICtrlSetData($msgdisplay, "Error. No file selected")
	Else
		If $AutoImportDefaults = 1 Then
			_LoadFile($loadfile)
			_CheckNewFiles()
			_UpdateListview()
		Else
			If _GuiImportSettings() = 1 Then
				_LoadFile($loadfile)
				_CheckNewFiles()
				_UpdateListview()
			Else
				GUICtrlSetData($msgdisplay, "Error. 'Import Settings' were not set.")
			EndIf
		EndIf
	EndIf
	GUISetState(@SW_SHOW, $GUI_wifidbuploader)
EndFunc   ;==>_LoadFileSelect

Func _LoadFile($loadfile)
	If FileExists($loadfile) Then
		$loadfileMD5 = _MD5ForFile($loadfile)
		ConsoleWrite('MD5:' & $loadfileMD5 & ' | Size:' & Round(FileGetSize($loadfile) / 1024) & 'kB' & @CRLF)
		$query = "SELECT md5 FROM UploadFiles WHERE md5='" & $loadfileMD5 & "'"
		$MD5MatchArray = _RecordSearch($DB, $query, $DB_OBJ)
		$FoundMD5Match = UBound($MD5MatchArray) - 1

		If $FoundMD5Match <> 0 Then
			ConsoleWrite('! File Already Exists ' & $loadfile & @CRLF)
		Else
			ConsoleWrite('+> Importing New File ' & $loadfile & @CRLF)
			$FILE_ID += 1
			_AddRecord($DB, "UploadFiles", $DB_OBJ, $loadfile & '|' & $loadfileMD5 & '|' & $DefaultTitle & '|' & $DefaultNotes & '|' & $DefaultStatus & '|' & $DefaultStatusText)
		EndIf
	EndIf
EndFunc   ;==>_LoadFile

Func _CheckNewFiles()
	$query = "SELECT filename, md5 FROM UploadFiles WHERE wdbstatus='new'"
	ConsoleWrite("$query:" & $query & @CRLF)
	$FileMatchArray = _RecordSearch($DB, $query, $DB_OBJ)
	$FoundFileMatch = UBound($FileMatchArray) - 1

	GUICtrlSetData($msgdisplay, "Checking file status in WifiDB")
	For $cf = 1 To $FoundFileMatch
		GUICtrlSetData($msgdisplay, "Checking file status in WifiDB ( " & $cf & " of " & $FoundFileMatch & " )")
		$filename = $FileMatchArray[$cf][1]
		$md5 = $FileMatchArray[$cf][2]

		$FileStatus = _CheckFile($md5)
		If Not @error Then
			ConsoleWrite('$fstatus:' & $FileStatus[0] & @CRLF)
			ConsoleWrite('$fstatustext:' & $FileStatus[1] & @CRLF)

			$query = "UPDATE UploadFiles SET wdbstatus='" & $FileStatus[0] & "', wdbstatustext='" & $FileStatus[1] & "' WHERE md5='" & $md5 & "'"
			ConsoleWrite($query & @CRLF)
			_ExecuteMDB($DB, $DB_OBJ, $query)
		EndIf
	Next
	GUICtrlSetData($msgdisplay, "")
EndFunc   ;==>_CheckNewFiles

Func _CheckUnfinishedFiles()
	$query = "SELECT filename, md5 FROM UploadFiles WHERE (wdbstatus<>'imported' And wdbstatus<>'bad')"
	ConsoleWrite("$query:" & $query & @CRLF)
	$FileMatchArray = _RecordSearch($DB, $query, $DB_OBJ)
	$FoundFileMatch = UBound($FileMatchArray) - 1

	GUICtrlSetData($msgdisplay, "Checking file status in WifiDB")
	For $cf = 1 To $FoundFileMatch
		GUICtrlSetData($msgdisplay, "Checking file status in WifiDB ( " & $cf & " of " & $FoundFileMatch & " )")
		$filename = $FileMatchArray[$cf][1]
		$md5 = $FileMatchArray[$cf][2]

		$FileStatus = _CheckFile($md5)
		If Not @error Then
			ConsoleWrite('$fstatus:' & $FileStatus[0] & @CRLF)
			ConsoleWrite('$fstatustext:' & $FileStatus[1] & @CRLF)

			$query = "UPDATE UploadFiles SET wdbstatus='" & $FileStatus[0] & "', wdbstatustext='" & $FileStatus[1] & "' WHERE md5='" & $md5 & "'"
			ConsoleWrite($query & @CRLF)
			_ExecuteMDB($DB, $DB_OBJ, $query)
		EndIf
	Next
	_UpdateListview()
	GUICtrlSetData($msgdisplay, "")
	$RefreshTimer = TimerInit()
EndFunc

Func _CheckFile($hash)
	Local $command, $extra_commands
	Local $boundary = "------------" & Chr(Random(Asc("A"), Asc("Z"), 3)) & Chr(Random(Asc("a"), Asc("z"), 3)) & Chr(Random(Asc("A"), Asc("Z"), 3)) & Chr(Random(Asc("a"), Asc("z"), 3)) & Random(1, 9, 1) & Random(1, 9, 1) & Random(1, 9, 1) & Chr(Random(Asc("A"), Asc("Z"), 3)) & Chr(Random(Asc("a"), Asc("z"), 3)) & Chr(Random(Asc("A"), Asc("Z"), 3)) & Chr(Random(Asc("a"), Asc("z"), 3)) & Random(1, 9, 1) & Random(1, 9, 1) & Random(1, 9, 1)

	$sUrl = $WifiDbApiURL & "import.php?func=check_hash"
	$oHttpRequest = ObjCreate("WinHttp.WinHttpRequest.5.1")
	$oHttpRequest.Option(4) = 13056
	$oHttpRequest.Open("POST", $sUrl, False)
	$oHttpRequest.setRequestHeader("Content-Type", "multipart/form-data; boundary=" & $boundary)
	$PostData = "--" & $boundary & @CRLF
	$PostData &= "Content-Disposition: form-data; name=""hash""" & @CRLF & @CRLF
	$PostData &= $hash & @CRLF
	$PostData &= "--" & $boundary & "--"
	$oHttpRequest.Send(StringToBinary($PostData))
	$Response = $oHttpRequest.ResponseText
	$httprecv = StringTrimRight(StringTrimLeft($Response, 1), 1)
	ConsoleWrite($httprecv & @CRLF)
	$import_json_response = _JSONDecode($httprecv)
	$import_json_response_iRows = UBound($import_json_response, 1)
	$import_json_response_iCols = UBound($import_json_response, 2)
	;ConsoleWrite('$import_json_response_iRows:' & $import_json_response_iRows & @CRLF)
	;ConsoleWrite('$import_json_response_iCols:' & $import_json_response_iCols & @CRLF)
	If $import_json_response_iRows = 2 And $import_json_response_iCols = 2 Then
		Local $FileStatus[2]
		$FileStatus[0] = $import_json_response[1][0]
		$FileStatus[1] = $import_json_response[1][1]
		SetError(0)
		Return ($FileStatus)
	EndIf

	SetError(1)
EndFunc   ;==>_CheckFile

Func _GuiAutoSettings()
	GUISetState(@SW_HIDE, $GUI_wifidbuploader)
	$GUI_AutoSettings = GUICreate("Auto Settings", 404, 224)
	$chk_autoimport = GUICtrlCreateCheckbox("Automatically Import Folder on Load", 10, 16, 375, 20)
	If $AutoImport = 1 Then GUICtrlSetState($chk_autoimport, $GUI_CHECKED)
	$inp_autoimpfolder = GUICtrlCreateInput($AutoImportFolder, 40, 40, 273, 21)
	$btn_browse = GUICtrlCreateButton("Browse", 320, 38, 73, 25)
	$chk_autoupload = GUICtrlCreateCheckbox("Automatically Upload 'unknown' files to WiFiDB on Load", 10, 70, 375, 20)
	If $AutoUpload = 1 Then GUICtrlSetState($chk_autoupload, $GUI_CHECKED)
	$chk_autorefreshwaiting = GUICtrlCreateCheckbox("Automatically refresh unfinished files every 5 minutes", 10, 95, 375, 20)
	If $AutoRefreshWating = 1 Then GUICtrlSetState($chk_autorefreshwaiting, $GUI_CHECKED)
	$chk_autoimpdefault = GUICtrlCreateCheckbox("Automatically use 'Import Settings' when importing", 10, 120, 375, 20)
	If $AutoImportDefaults = 1 Then GUICtrlSetState($chk_autoimpdefault, $GUI_CHECKED)
	$chk_autoupdefault = GUICtrlCreateCheckbox("Automatically use 'Upload Settings' when uploading", 11, 146, 375, 20)
	If $AutoUploadDefaults = 1 Then GUICtrlSetState($chk_autoupdefault, $GUI_CHECKED)
	$btn_autook = GUICtrlCreateButton("OK", 104, 181, 89, 25)
	$btn_autocan = GUICtrlCreateButton("Cancel", 204, 181, 89, 25)
	GUISetState(@SW_SHOW)

	While 1
		$nMsg = GUIGetMsg()
		Switch $nMsg
			Case $GUI_EVENT_CLOSE
				GUIDelete($GUI_AutoSettings)
				GUISetState(@SW_SHOW, $GUI_wifidbuploader)
				Return(0)
			Case $btn_autocan
				GUIDelete($GUI_AutoSettings)
				GUISetState(@SW_SHOW, $GUI_wifidbuploader)
				Return(0)
			Case $btn_browse
				$loadfolder = FileSelectFolder("Select folder that contains vistumbler vs1 files", @ScriptDir)
				If Not @error Then GUICtrlSetData($inp_autoimpfolder, $loadfolder)
			Case $btn_autook
				$AutoImportFolder = GUICtrlRead($inp_autoimpfolder)

				If GUICtrlRead($chk_autoimport) = 1 Then
					$AutoImport = 1
				Else
					$AutoImport = 0
				EndIf

				If GUICtrlRead($chk_autoupload) = 1 Then
					$AutoUpload = 1
				Else
					$AutoUpload = 0
				EndIf

				If GUICtrlRead($chk_autorefreshwaiting) = 1 Then
					$AutoRefreshWating = 1
				Else
					$AutoRefreshWating = 0
				EndIf

				If GUICtrlRead($chk_autoimpdefault) = 1 Then
					$AutoImportDefaults = 1
				Else
					$AutoImportDefaults = 0
				EndIf

				If GUICtrlRead($chk_autoupdefault) = 1 Then
					$AutoUploadDefaults = 1
				Else
					$AutoUploadDefaults = 0
				EndIf

				_SaveSettings()
				GUIDelete($GUI_AutoSettings)
				GUISetState(@SW_SHOW, $GUI_wifidbuploader)
				Return(1)
		EndSwitch
	WEnd
EndFunc

Func _GuiUploadSettings()
	GUISetState(@SW_HIDE, $GUI_wifidbuploader)
	$GUI_UploadSettings = GUICreate("Upload Settings", 420, 300)
	GUICtrlCreateLabel("WifiDB Username", 10, 17, 400, 20)
	$inp_wdbusername = GUICtrlCreateInput($WdbUser, 10, 37, 400, 21)
	GUICtrlCreateLabel("WifiDB Api Key", 10, 67, 400, 20)
	$inp_wdbapikey = GUICtrlCreateInput($WdbApiKey, 10, 87, 400, 21)
	GUICtrlCreateLabel("WifiDB Other Contributing Users", 10, 117, 400, 20)
	$inp_wdbotherusers = GUICtrlCreateInput($WdbOtherUser, 10, 137, 400, 21)
	GUICtrlCreateLabel("WifiDB Api URL", 10, 167, 400, 20)
	$inp_wdbapiurl = GUICtrlCreateInput($WifiDbApiURL, 10, 187, 400, 20)
	$chk_autoupdefault = GUICtrlCreateCheckbox("Automatically use 'Upload Settings' when uploading", 11, 227, 375, 20)
	If $AutoUploadDefaults = 1 Then GUICtrlSetState($chk_autoupdefault, $GUI_CHECKED)
	$btn_upok = GUICtrlCreateButton("OK", 104, 257, 97, 25)
	$btn_upcan = GUICtrlCreateButton("Cancel", 217, 257, 97, 25)
	GUISetState(@SW_SHOW)

	While 1
		$nMsg = GUIGetMsg()
		Switch $nMsg
			Case $GUI_EVENT_CLOSE
				GUIDelete($GUI_UploadSettings)
				GUISetState(@SW_SHOW, $GUI_wifidbuploader)
				Return(0)
			Case $btn_upcan
				GUIDelete($GUI_UploadSettings)
				GUISetState(@SW_SHOW, $GUI_wifidbuploader)
				Return(0)
			Case $btn_upok
				$WdbUser = GUICtrlRead($inp_wdbusername)
				$WdbApiKey = GUICtrlRead($inp_wdbapikey)
				$WdbOtherUser = GUICtrlRead($inp_wdbotherusers)
				$WifiDbApiURL = GUICtrlRead($inp_wdbapiurl)
				If GUICtrlRead($chk_autoupdefault) = 1 Then
					$AutoUploadDefaults = 1
				Else
					$AutoUploadDefaults = 0
				EndIf
				_SaveSettings()
				GUIDelete($GUI_UploadSettings)
				GUISetState(@SW_SHOW, $GUI_wifidbuploader)
				Return(1)
		EndSwitch
	WEnd
EndFunc

Func _GuiImportSettings()
	GUISetState(@SW_HIDE, $GUI_wifidbuploader)
	$Gui_ImportSettings = GUICreate("Import Settings", 420, 185)
	GUICtrlCreateLabel("Import Title", 10, 17, 400, 20)
	$imp_imptitle = GUICtrlCreateInput($DefaultTitle, 10, 37, 400, 21)
	GUICtrlCreateLabel("Import Notes", 10, 67, 400, 20)
	$imp_impnotes = GUICtrlCreateInput($DefaultNotes, 10, 87, 400, 21)
	$chk_autoimpdefault = GUICtrlCreateCheckbox("Automatically use 'Import Settings' when importing", 10, 117, 375, 20)
	If $AutoImportDefaults = 1 Then GUICtrlSetState($chk_autoimpdefault, $GUI_CHECKED)
	$btn_impok = GUICtrlCreateButton("OK", 104, 145, 97, 25)
	$btn_impcan = GUICtrlCreateButton("Cancel", 217, 145, 97, 25)
	GUISetState(@SW_SHOW)

	While 1
		$nMsg = GUIGetMsg()
		Switch $nMsg
			Case $GUI_EVENT_CLOSE
				GUIDelete($Gui_ImportSettings)
				GUISetState(@SW_SHOW, $GUI_wifidbuploader)
				Return(0)
			Case $btn_impcan
				GUIDelete($Gui_ImportSettings)
				GUISetState(@SW_SHOW, $GUI_wifidbuploader)
				Return(0)
			Case $btn_impok
				$DefaultTitle = GUICtrlRead($imp_imptitle)
				$DefaultNotes = GUICtrlRead($imp_impnotes)
				If GUICtrlRead($chk_autoimpdefault) = 1 Then
					$AutoImportDefaults = 1
				Else
					$AutoImportDefaults = 0
				EndIf
				_SaveSettings()
				GUIDelete($Gui_ImportSettings)
				GUISetState(@SW_SHOW, $GUI_wifidbuploader)
				Return(1)
		EndSwitch
	WEnd

EndFunc

Func _UploadUnknownFiles()
	$query = "SELECT filename, md5, uploadtitle, uploadnotes FROM UploadFiles WHERE wdbstatus='unknown'"
	ConsoleWrite("$query:" & $query & @CRLF)
	$FileMatchArray = _RecordSearch($DB, $query, $DB_OBJ)
	$FoundFileMatch = UBound($FileMatchArray) - 1

	If $FoundFileMatch = 0 Then MsgBox(0, "Error", "There are no files that are unknown to the wifidb. There is nothing to upload at this time.")

	For $cf = 1 To $FoundFileMatch
		$filename = $FileMatchArray[$cf][1]
		$md5 = $FileMatchArray[$cf][2]
		$uploadtitle = $FileMatchArray[$cf][3]
		$uploadnotes = $FileMatchArray[$cf][4]

		_UploadToWifiDB($filename, $WdbApiKey, $WdbUser, $WdbOtherUser, $uploadtitle, $uploadnotes)
		$filestatus = _CheckFile($md5)
		If Not @error Then
			ConsoleWrite('$fstatus:' & $filestatus[0] & @CRLF)
			ConsoleWrite('$fstatustext:' & $filestatus[1] & @CRLF)

			If $filestatus[0] <> 'unknown' Then
				$query = "UPDATE UploadFiles SET wdbstatus='" & $filestatus[0] & "', wdbstatustext='" & $filestatus[1] & "' WHERE md5='" & $md5 & "'"
				ConsoleWrite($query & @CRLF)
				_ExecuteMDB($DB, $DB_OBJ, $query)
			Else
				$query = "UPDATE UploadFiles SET wdbstatus='error', wdbstatustext='File still not found after upload. It may be an invalid file.' WHERE md5='" & $md5 & "'"
				ConsoleWrite($query & @CRLF)
				_ExecuteMDB($DB, $DB_OBJ, $query)
			EndIf
		EndIf
	Next
EndFunc

Func _UploadToWifiDB($file, $WifiDb_ApiKey, $WifiDb_User, $WifiDb_OtherUsers, $upload_title, $upload_notes)
	local $szDrive, $szDir, $szFName, $szExt
	_PathSplit($file, $szDrive, $szDir, $szFName, $szExt)
	$filetype = "application/octet-stream"
	$fileuname = $szFName & $szExt
	;$fileread = FileRead($file)
	ConsoleWrite($fileuname & @CRLF)


	$httprecv = _HTTPPost_WifiDB_File($file, $fileuname, $filetype, $WifiDb_ApiKey, $WifiDb_User, $WifiDb_OtherUsers, $upload_title, $upload_notes)
	ConsoleWrite($httprecv & @CRLF)

	Local $import_json_response, $json_array_size, $json_msg
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
			ConsoleWrite("Title: " & $imtitle & @CRLF & "User: " & $imuser & @CRLF & "Message: " & $immessage & @CRLF & "Import Number: " & $imimportnum & @CRLF & "File Hash: " & $imfilehash & @CRLF)
			Local $FileStatus[5]
			$FileStatus[0] = $imtitle
			$FileStatus[1] = $imuser
			$FileStatus[2] = $immessage
			$FileStatus[3] = $imimportnum
			$FileStatus[4] = $imfilehash
			SetError(0)
			Return($FileStatus)
		EndIf
	EndIf

	SetError(1)
EndFunc

Func _HTTPPost_WifiDB_File($file, $filename, $contenttype, $apikey, $user, $otherusers, $title, $notes)
	Local $PostData
	Local $boundary = "------------" & Chr(Random(Asc("A"), Asc("Z"), 3)) & Chr(Random(Asc("a"), Asc("z"), 3)) & Chr(Random(Asc("A"), Asc("Z"), 3)) & Chr(Random(Asc("a"), Asc("z"), 3)) & Random(1, 9, 1) & Random(1, 9, 1) & Random(1, 9, 1) & Chr(Random(Asc("A"), Asc("Z"), 3)) & Chr(Random(Asc("a"), Asc("z"), 3)) & Chr(Random(Asc("A"), Asc("Z"), 3)) & Chr(Random(Asc("a"), Asc("z"), 3)) & Random(1, 9, 1) & Random(1, 9, 1) & Random(1, 9, 1)
	$fileopen = FileOpen($file,16)
	$file = BinaryToString(FileRead($fileopen))
	FileClose($fileopen)

    $sUrl = $WifiDbApiURL & "import.php"
	ConsoleWrite($sUrl & @CRLF)
    $oHttpRequest = ObjCreate("WinHttp.WinHttpRequest.5.1")
    ;$oHttpRequest.Option(4) = 13056
    $oHttpRequest.Open ("POST", $sUrl, False)
	$oHttpRequest.setRequestHeader  ("User-Agent",$Script_Name & ' ' & $version)
    $oHttpRequest.setRequestHeader  ("Content-Type","multipart/form-data; boundary=" & $boundary)

	$PostData &= "--" & $boundary & @CRLF
	$PostData &= "Content-Disposition: form-data; name=""file""; filename=""" & $filename & """" & @CRLF
	$PostData &= "Content-Type: " & $contenttype & @CRLF & @CRLF
	$PostData &= $file & @CRLF

	If $apikey <> "" Then
		$PostData &= "--" & $boundary & @CRLF
		$PostData &= "Content-Disposition: form-data; name=""apikey""" & @CRLF & @CRLF
		$PostData &= $apikey & @CRLF
	EndIf
	If $user <> "" Then
		$PostData &= "--" & $boundary & @CRLF
		$PostData &= "Content-Disposition: form-data; name=""username""" & @CRLF & @CRLF
		$PostData &= $user & @CRLF
	EndIf
	If $otherusers <> "" Then
		$PostData &= "--" & $boundary & @CRLF
		$PostData &= "Content-Disposition: form-data; name=""otherusers""" & @CRLF & @CRLF
		$PostData &= $otherusers & @CRLF
	EndIf
	If $title <> "" Then
		$PostData &= "--" & $boundary & @CRLF
		$PostData &= "Content-Disposition: form-data; name=""title""" & @CRLF & @CRLF
		$PostData &= $title & @CRLF
	EndIf
	If $notes <> "" Then
		$PostData &= "--" & $boundary & @CRLF
		$PostData &= "Content-Disposition: form-data; name=""notes""" & @CRLF & @CRLF
		$PostData &= $notes & @CRLF
	EndIf
	$PostData &= "--" & $boundary & "--" & @CRLF

	;ConsoleWrite($PostData & @CRLF)
	ConsoleWrite(StringReplace($PostData, $file, "## DATA FILE ##" & @CRLF) & @CRLF)
	;ConsoleWrite($PostData & @CRLF)

	$oHttpRequest.Send (StringToBinary($PostData))

	ConsoleWrite("STATUS:" & $oHttpRequest.Status & @CRLF)


	$Response = $oHttpRequest.ResponseText

	$oHttpRequest = ""
	Return($Response)
EndFunc   ;==>_HTTPPost_WifiDB_File

Func MyErrFunc()
	$HexNumber=hex($oMyError.number,8)
	Msgbox(0,"","We intercepted a COM Error !" & @CRLF & _
	"Number is: " & $HexNumber & @CRLF & _
	"Windescription is: " & $oMyError.windescription )
	$_eventerror = 1
Endfunc