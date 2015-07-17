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
#include "UDFs\HTTP.au3"
#include "UDFs\JSON.au3"
#include <Array.au3>
#include <File.au3>
#include <INet.au3>
 #include <String.au3>

$Script_Name = 'WifiDB Uploader'
$version = 'v0.1'

Dim $settings = 'settings.ini'
Dim $SearchWord_None = 'None';IniRead($DefaultLanguagePath, 'SearchWords', 'None', 'None')
Dim $SearchWord_Open = 'Open';IniRead($DefaultLanguagePath, 'SearchWords', 'Open', 'Open')
Dim $SearchWord_Wep = 'WEP';IniRead($DefaultLanguagePath, 'SearchWords', 'WEP', 'WEP')

Dim $WdbUser = 'ACalcutt';IniRead($DefaultLanguagePath, 'SearchWords', 'WEP', 'WEP')
Dim $WdbApiKey = '';IniRead($DefaultLanguagePath, 'SearchWords', 'WEP', 'WEP')
Dim $WdbOtherUser = '';IniRead($DefaultLanguagePath, 'SearchWords', 'WEP', 'WEP')
Dim $DefaultTitle = 'WDB Batch Test';IniRead($DefaultLanguagePath, 'SearchWords', 'WEP', 'WEP')
Dim $DefaultNotes = '';IniRead($DefaultLanguagePath, 'SearchWords', 'WEP', 'WEP')
Dim $DefaultStatus = 'new';IniRead($DefaultLanguagePath, 'SearchWords', 'WEP', 'WEP')
Dim $DefaultStatusText = 'Not Yet Checked';IniRead($DefaultLanguagePath, 'SearchWords', 'WEP', 'WEP')
Dim $WifiDbApiURL = "https://api.wifidb.net/"

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


_UploadUnknownFiles()

;------------------------------------------------------------------------------------------------------------------------------------
;														SCRIPT FUNCTIONS
;------------------------------------------------------------------------------------------------------------------------------------

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

	For $cf = 1 To $FoundFileMatch
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
EndFunc

Func _CheckFile($hash)
	Local $command, $extra_commands
	Local $boundary = "------------" & Chr(Random(Asc("A"), Asc("Z"), 3)) & Chr(Random(Asc("a"), Asc("z"), 3)) & Chr(Random(Asc("A"), Asc("Z"), 3)) & Chr(Random(Asc("a"), Asc("z"), 3)) & Random(1, 9, 1) & Random(1, 9, 1) & Random(1, 9, 1) & Chr(Random(Asc("A"), Asc("Z"), 3)) & Chr(Random(Asc("a"), Asc("z"), 3)) & Chr(Random(Asc("A"), Asc("Z"), 3)) & Chr(Random(Asc("a"), Asc("z"), 3)) & Random(1, 9, 1) & Random(1, 9, 1) & Random(1, 9, 1)

	;Get Host, Path, and Port from WifiDB api url
	$hpparr = _Get_HostPortPath($WifiDbApiURL)
	If Not @error Then
		Local $host, $port, $path
		$host = $hpparr[1]
		$port = $hpparr[2]
		$path = $hpparr[3]
		$page = $path & "import.php?func=check_hash"
		;ConsoleWrite('$host:' & $host & ' ' & '$port:' & $port & @CRLF)
		;ConsoleWrite($path & @CRLF)
		$socket = _HTTPConnect($host, $port)
		If Not @error Then

			$extra_commands = "--" & $boundary & @CRLF
			$extra_commands &= "Content-Disposition: form-data; name=""hash""" & @CRLF & @CRLF
			$extra_commands &= $hash & @CRLF
			$extra_commands &= "--" & $boundary & "--"

			Dim $datasize = StringLen($extra_commands)

			$command = "POST " & $page & " HTTP/1.1" & @CRLF
			$command &= "Host: " & $host & @CRLF
			$command &= "User-Agent: " & $Script_Name & ' ' & $version & @CRLF
			$command &= "Connection: close" & @CRLF
			$command &= "Content-Type: multipart/form-data; boundary=" & $boundary & @CRLF
			$command &= "Content-Length: " & $datasize & @CRLF & @CRLF
			$command &= $extra_commands
			;ConsoleWrite($command & @CRLF)

			Dim $bytessent = TCPSend($socket, $command)

			If $bytessent == 0 Then
				SetExtended(@error)
				SetError(2)
				Return
			EndIf

			$recv = _HTTPRead($socket, 1)
			If @error Then
				ConsoleWrite("_HTTPRead Error:" & @error & @CRLF)
			Else
				;Read WifiDB JSON Response
				Local $httprecv, $import_json_response, $json_array_size
				$httprecv = $recv[4]
				$httprecv = StringTrimRight(StringTrimLeft($httprecv, 1), 1)
				;ConsoleWrite($httprecv & @CRLF)
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
			EndIf
		EndIf
	EndIf
	SetError(1)
EndFunc

Func _UploadUnknownFiles()
	$query = "SELECT filename, md5, uploadtitle, uploadnotes FROM UploadFiles WHERE wdbstatus='unknown'"
	ConsoleWrite("$query:" & $query & @CRLF)
	$FileMatchArray = _RecordSearch($DB, $query, $DB_OBJ)
	$FoundFileMatch = UBound($FileMatchArray) - 1

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

			$query = "UPDATE UploadFiles SET wdbstatus='" & $filestatus[0] & "', wdbstatustext='" & $filestatus[1] & "' WHERE md5='" & $md5 & "'"
			ConsoleWrite($query & @CRLF)
			_ExecuteMDB($DB, $DB_OBJ, $query)

		EndIf
	Next
EndFunc

Func _UploadToWifiDB($file, $WifiDb_ApiKey, $WifiDb_User, $WifiDb_OtherUsers, $upload_title, $upload_notes)
	Local $command, $extra_commands
	Local $boundary = "------------" & Chr(Random(Asc("A"), Asc("Z"), 3)) & Chr(Random(Asc("a"), Asc("z"), 3)) & Chr(Random(Asc("A"), Asc("Z"), 3)) & Chr(Random(Asc("a"), Asc("z"), 3)) & Random(1, 9, 1) & Random(1, 9, 1) & Random(1, 9, 1) & Chr(Random(Asc("A"), Asc("Z"), 3)) & Chr(Random(Asc("a"), Asc("z"), 3)) & Chr(Random(Asc("A"), Asc("Z"), 3)) & Chr(Random(Asc("a"), Asc("z"), 3)) & Random(1, 9, 1) & Random(1, 9, 1) & Random(1, 9, 1)
	local $szDrive, $szDir, $szFName, $szExt
	_PathSplit($file, $szDrive, $szDir, $szFName, $szExt)
	$filetype = "text/plain; charset=""UTF-8"""
	$fileuname = $szFName & $szExt
	$fileread = FileRead($file)

	;Get Host, Path, and Port from WifiDB api url
	$hpparr = _Get_HostPortPath($WifiDbApiURL)
	If Not @error Then
		Local $host, $port, $path
		$host = $hpparr[1]
		$port = $hpparr[2]
		$path = $hpparr[3]
		$page = $path & "import.php"
		;ConsoleWrite('$host:' & $host & ' ' & '$port:' & $port & @CRLF)
		;ConsoleWrite($path & @CRLF)
		$socket = _HTTPConnect($host, $port)
		If Not @error Then
			_HTTPPost_WifiDB_File($host, $page, $socket, $fileread, $fileuname, $filetype, $WifiDb_ApiKey, $WifiDb_User, $WifiDb_OtherUsers, $upload_title, $upload_notes)
			$recv = _HTTPRead($socket, 1)
			If @error Then
				ConsoleWrite("_HTTPRead Error:" & @error & @CRLF)
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
			EndIf
		Else
			ConsoleWrite("_HTTPConnect Error: Unable to open socket - WSAGetLasterror:" & @extended & @CRLF)
		EndIf
	EndIf
	SetError(1)
EndFunc

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
