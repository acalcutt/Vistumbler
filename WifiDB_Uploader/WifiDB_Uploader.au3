#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\VistumblerMDB\Icons\icon.ico
#AutoIt3Wrapper_Res_requestedExecutionLevel=highestAvailable
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
Opt("GUIResizeMode", 576)
;#RequireAdmin
;#include "UDFs\_XMLDomWrapper.au3"
#include "UDFs\FileListToArray3.au3"
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

$Script_Name = 'WifiDB Uploader'
$version = 'v0.1'

$oMyError = ObjEvent("AutoIt.Error","MyErrFunc")

Dim $settings = 'settings.ini'
Dim $WdbUser = IniRead($settings, 'Settings', 'WdbUser', 'Unknown')
Dim $WdbApiKey = IniRead($settings, 'Settings', 'WdbApiKey', '')
Dim $WdbOtherUser = IniRead($settings, 'Settings', 'WdbOtherUser', '')
Dim $DefaultTitle = IniRead($settings, 'Settings', 'DefaultTitle', 'WDB Batch Upload')
Dim $DefaultNotes = IniRead($settings, 'Settings', 'DefaultNotes', '')
Dim $WifiDbApiURL =  IniRead($settings, 'Settings', 'WifiDbApiURL', 'https://api.wifidb.net/')
Dim $DefaultStatus = 'new'
Dim $DefaultStatusText = 'Not Yet Checked'

Dim $ColFile = 0
Dim $ColMD5 = 1
Dim $ColTitle = 2
Dim $ColNotes = 3
Dim $ColStatus = 4
Dim $ColStatusMessage = 5

Dim $FILE_ID
Dim $RetryAttempts = 1 ;Number of times to retry getting location
Dim $TmpDir = @ScriptDir & '\'
Dim $DB = $TmpDir & 'files.mdb'
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
If $filename = "" Then $filename = FileSelectFolder ("Select folder that contains vistumbler files", @ScriptDir)

If _IsDirectory($filename) Then
	_SearchVistumblerFiles($filename)
Else
	_LoadVistumblerFile($filename)
EndIf

_CheckNewFiles()


$UploadForm = GUICreate("WifiDB Uploader v0.1", 615, 437, -1, -1, BitOR($WS_OVERLAPPEDWINDOW, $WS_CLIPSIBLINGS))

$ulist = _GUICtrlListView_Create($UploadForm, 'File|Hash|Title|Notes|WDB Status|WDB Status Message', 8, 8, 601, 318, BitOR($LVS_REPORT, $LVS_SINGLESEL))
_UpdateListview()

$Group1 = GUICtrlCreateGroup("User Information", 16, 336, 593, 89)
GUICtrlCreateLabel("WifiDB Username", 32, 363, 125, 17)
$WdbUser_GUI = GUICtrlCreateInput($WdbUser, 32, 384, 125, 21)
GUICtrlCreateLabel("Other users", 173, 364, 125, 17)
$WdbOtherUser_GUI = GUICtrlCreateInput($WdbOtherUser, 173, 385, 125, 21)
GUICtrlCreateLabel("WifiDB Api Key", 319, 365, 125, 17)
$WdbApiKey_GUI = GUICtrlCreateInput($WdbApiKey, 319, 386, 125, 21)
$Upload = GUICtrlCreateButton("Upload 'unknown'", 472, 368, 121, 41)

GUISetState(@SW_SHOW)
GUIRegisterMsg($WM_SIZE, "WM_SIZE")

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			$WdbUser = GUICtrlRead($WdbUser_GUI)
			$WdbOtherUser = GUICtrlRead($WdbOtherUser_GUI)
			$WdbApiKey = GUICtrlRead($WdbApiKey_GUI)
			ExitLoop
		Case $Upload
			$WdbUser = GUICtrlRead($WdbUser_GUI)
			$WdbOtherUser = GUICtrlRead($WdbOtherUser_GUI)
			$WdbApiKey = GUICtrlRead($WdbApiKey_GUI)
			_UploadUnknownFiles()
			_UpdateListview()
	EndSwitch
WEnd

_SaveSettings()
_AccessCloseConn($DB_OBJ)
FileDelete($DB)



;------------------------------------------------------------------------------------------------------------------------------------
;														SCRIPT FUNCTIONS
;------------------------------------------------------------------------------------------------------------------------------------

Func _SaveSettings()
	IniWrite($settings, 'Settings', 'WdbUser', $WdbUser)
	IniWrite($settings, 'Settings', 'WdbApiKey', $WdbApiKey)
	IniWrite($settings, 'Settings', 'WdbOtherUser', $WdbOtherUser)
	IniWrite($settings, 'Settings', 'DefaultTitle', $DefaultTitle)
	IniWrite($settings, 'Settings', 'DefaultNotes', $DefaultNotes)
	IniWrite($settings, 'Settings', 'WifiDbApiURL', $WifiDbApiURL)
EndFunc

Func WM_SIZE($hWnd, $Msg, $wParam, $lParam)

    Local $iHeight, $iWidth
    $iWidth = BitAND($lParam, 0xFFFF) ; _WinAPI_LoWord
    $iHeight = BitShift($lParam, 16) ; _WinAPI_HiWord
    _WinAPI_MoveWindow($ulist, 10, 10, $iWidth - 20, $iHeight - 120)
    Return $GUI_RUNDEFMSG
EndFunc

Func _UpdateListview()
	local $szDrive, $szDir, $szFName, $szExt
	_GUICtrlListView_BeginUpdate ($ulist)
	_GUICtrlListView_DeleteAllItems ($ulist)
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
		$filename=$szFName & $szExt

		$line = _GUICtrlListView_AddItem($ulist, $filename, $ColFile)
		_GUICtrlListView_AddSubItem($ulist, $line, $md5, $ColMD5)
		_GUICtrlListView_AddSubItem($ulist, $line, $uploadtitle, $ColTitle)
		_GUICtrlListView_AddSubItem($ulist, $line, $uploadnotes, $ColNotes)
		_GUICtrlListView_AddSubItem($ulist, $line, $wdbstatus, $ColStatus)
		_GUICtrlListView_AddSubItem($ulist, $line, $wdbstatustext, $ColStatusMessage)

	Next
	_GUICtrlListView_EndUpdate ($ulist)
EndFunc

Func _SearchVistumblerFiles($VistumblerFilesFolder)
   If @error=1 Then
	  MsgBox(0, "Error", "No folder selected, exiting")
	  Exit
   Else
		SplashTextOn ( "Status", "Loading Files in '" & $VistumblerFilesFolder & "'" , 400, 100, -1, -1, 2 + 16)
		$VistumblerFiles = _FileListToArray3($VistumblerFilesFolder, "*.VS1", 1, 1, 1)
		For $f=1 to $VistumblerFiles[0]
			ControlSetText("Status", "", "Static1", "Loading File ( " & $f & " of " & $VistumblerFiles[0] & " )")
			;Safe Kill Import if killswitch is set
			$KillSwitch = IniRead($settings, 'Settings', 'KillSwitch', '0')
			If $KillSwitch = 1 Then
				ConsoleWrite("! Kill switch is enabled. Exiting..." & @CRLF)
				Exit
			EndIf

			ConsoleWrite('File:' & $f & '/' & $VistumblerFiles[0] & ' | File:' & $VistumblerFiles[$f] & @CRLF)
			_LoadVistumblerFile($VistumblerFiles[$f])
		Next
		SplashOff()
   EndIf
EndFunc

Func _LoadVistumblerFile($loadfile)
	if FileExists($loadfile) Then
		$loadfileMD5 = _MD5ForFile($loadfile)
		ConsoleWrite('MD5:' & $loadfileMD5 & ' | Size:' & Round(FileGetSize ($loadfile)/1024) & 'kB' & @CRLF)
		$query = "SELECT md5 FROM UploadFiles WHERE md5='" & $loadfileMD5 & "'"
		$MD5MatchArray = _RecordSearch($DB, $query, $DB_OBJ)
		$FoundMD5Match = UBound($MD5MatchArray) - 1

		If $FoundMD5Match <> 0 Then
			ConsoleWrite('! File Already Exists '& $loadfile & @CRLF)
		Else
			ConsoleWrite('+> Importing New File ' & $loadfile & @CRLF)
			$FILE_ID += 1
			_AddRecord($DB, "UploadFiles", $DB_OBJ, $loadfile & '|' & $loadfileMD5 & '|' & $DefaultTitle & '|' & $DefaultNotes & '|' & $DefaultStatus & '|' & $DefaultStatusText)
		EndIf
	EndIf
EndFunc

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
EndFunc

Func _IsDirectory ($sDir)
   If StringInStr (FileGetAttrib ($sDir), "D") Then Return 1
      Return 0
EndFunc ; ==> _IsDirectory

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

Func _CheckNewFiles()
	$query = "SELECT filename, md5 FROM UploadFiles WHERE wdbstatus='new'"
	ConsoleWrite("$query:" & $query & @CRLF)
	$FileMatchArray = _RecordSearch($DB, $query, $DB_OBJ)
	$FoundFileMatch = UBound($FileMatchArray) - 1

	SplashTextOn ( "Status", "Checking file status in WifiDB", 400, 100, -1, -1, 2 + 16)
	For $cf = 1 To $FoundFileMatch
		ControlSetText("Status", "", "Static1", "Checking file status in WifiDB ( " & $cf & " of " & $FoundFileMatch & " )")
		$filename = $FileMatchArray[$cf][1]
		$md5 = $FileMatchArray[$cf][2]

		$filestatus = _CheckFile($md5)
		If Not @error Then
			ConsoleWrite('$fstatus:' & $filestatus[0] & @CRLF)
			ConsoleWrite('$fstatustext:' & $filestatus[1] & @CRLF)

			$query = "UPDATE UploadFiles SET wdbstatus='" & $filestatus[0] & "', wdbstatustext='" & $filestatus[1] & "' WHERE md5='" & $md5 & "'"
			ConsoleWrite($query & @CRLF)
			_ExecuteMDB($DB, $DB_OBJ, $query)

		EndIf
	Next
	SplashOff()
EndFunc

Func _CheckFile($hash)
	Local $command, $extra_commands
	Local $boundary = "------------" & Chr(Random(Asc("A"), Asc("Z"), 3)) & Chr(Random(Asc("a"), Asc("z"), 3)) & Chr(Random(Asc("A"), Asc("Z"), 3)) & Chr(Random(Asc("a"), Asc("z"), 3)) & Random(1, 9, 1) & Random(1, 9, 1) & Random(1, 9, 1) & Chr(Random(Asc("A"), Asc("Z"), 3)) & Chr(Random(Asc("a"), Asc("z"), 3)) & Chr(Random(Asc("A"), Asc("Z"), 3)) & Chr(Random(Asc("a"), Asc("z"), 3)) & Random(1, 9, 1) & Random(1, 9, 1) & Random(1, 9, 1)

    $sUrl = $WifiDbApiURL & "import.php?func=check_hash"
    $oHttpRequest = ObjCreate("WinHttp.WinHttpRequest.5.1")
    $oHttpRequest.Option(4) = 13056
    $oHttpRequest.Open ("POST", $sUrl, False)
    $oHttpRequest.setRequestHeader  ("Content-Type","multipart/form-data; boundary=" & $boundary)
	$PostData = "--" & $boundary & @CRLF
	$PostData &= "Content-Disposition: form-data; name=""hash""" & @CRLF & @CRLF
	$PostData &= $hash & @CRLF
	$PostData &= "--" & $boundary & "--"
	$oHttpRequest.Send (StringToBinary($PostData))
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
		Return($FileStatus)
	EndIf

	SetError(1)
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
	$filetype = "text/plain; charset=""UTF-8"""
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
	$fileopen = FileOpen($file,128)
	$file = FileRead($fileopen)
	FileClose($fileopen)

    $sUrl = $WifiDbApiURL & "import.php"
	ConsoleWrite($sUrl & @CRLF)
    $oHttpRequest = ObjCreate("WinHttp.WinHttpRequest.5.1")
    $oHttpRequest.Option(4) = 13056
    $oHttpRequest.Open ("POST", $sUrl, False)
    $oHttpRequest.setRequestHeader  ("Content-Type","multipart/form-data; boundary=" & $boundary)

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
	$PostData &= "--" & $boundary & @CRLF
	$PostData &= "Content-Disposition: form-data; name=""file""; filename=""" & $filename & """" & @CRLF
	$PostData &= "Content-Type: " & $contenttype & @CRLF & @CRLF
	$PostData &= $file & @crlf
	$PostData &= "--" & $boundary & "--"

	;ConsoleWrite($PostData & @CRLF)
	ConsoleWrite(StringReplace($PostData, $file, "## DATA FILE ##" & @CRLF) & @CRLF)

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
