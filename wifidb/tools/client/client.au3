#include <ButtonConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <ProgressConstants.au3>
#include <String.au3>
#include <UDFs\rijndael.au3>
#include <UDFs\MD5.au3>
#include <SQLite.au3>
#include <Misc.au3>
#include <INet.au3>
#Include <Date.au3>

Global $sock, $remote_socketopen, $remote_timeout, $ExpList, $LoggedIn, $User_input, $PWD_input;, $WiFiDB_Pass, $WiFiDB_User
$last_edit = "2010-08-21"
Dim $client_array
Dim $TmpDir = @ScriptDir & '\temp\'
Dim $VS1Dir = @ScriptDir & '\VS1\'
Dim $KMLDir = @ScriptDir & '\KML\'
Dim $GPXDir = @ScriptDir & '\GPX\'
Dim $ExpGUI, $LoginGUI, $seed, $session_key, $ImpTitle, $ImpNotes, $OpenFile, $ImpForm

DirCreate($TmpDir)
DirCreate($KMLDir)
DirCreate($GPXDir)
DirCreate($VS1Dir)

TCPStartup()
$remote_port = '9000'
$local_address = _GetIP()
$remote_socketopen = 0
$remote_timeout = 30000

#Region ### START Koda GUI section ### Form=
AutoItSetOption('GUIOnEventMode', 1)
$Form = GUICreate("WiFiDB Client v1.0 By: Phil Ferland Last Edit: " & $last_edit, 625, 443, 192, 124)
$Connect_Button = GUICtrlCreateButton("Connect", 208, 0, 121, 25, $WS_GROUP)
$Login_Button = GUICtrlCreateButton("Login", 334, 0, 121, 25, $WS_GROUP)
$List_Imports_Button = GUICtrlCreateButton("Get List of Imports", 8, 56, 161, 25, $WS_GROUP)
$Exports_Form_Button = GUICtrlCreateButton("Export a List", 175, 56, 161, 25, $WS_GROUP)
$Imports_Form_Button = GUICtrlCreateButton("Import a List", 342, 56, 161, 25, $WS_GROUP)

$Host_Input = GUICtrlCreateInput("192.168.1.27", 8, 0, 201, 21)

GUICtrlSetOnEvent($Exports_Form_Button, '_CreateExpGui')
GUICtrlSetOnEvent($List_Imports_Button, '_GuiGetLists')
GUICtrlSetOnEvent($Connect_Button, '_Connect')
GUICtrlSetOnEvent($Login_Button, '_CreateLoginGUI')
GUICtrlSetOnEvent($Imports_Form_Button, '_WDBImportGUI')
GUISetOnEvent($GUI_EVENT_CLOSE, '_CloseGui')

$DB = "C:\storage.SDB"
_SQLite_Startup ()
_SQLite_SafeMode(False)
ConsoleWrite("_SQLite_LibVersion=" &_SQLite_LibVersion() & @CRLF)
If FileExists($DB) Then
	$LabDB = _SQLite_Open($DB, $SQLITE_OPEN_READWRITE + $SQLITE_OPEN_CREATE, $SQLITE_ENCODING_UTF16)
Else
	$LabDB = _SQLite_Open($DB, $SQLITE_OPEN_READWRITE + $SQLITE_OPEN_CREATE, $SQLITE_ENCODING_UTF16)
	_SQLite_Exec($LabDB, "DROP TABLE Imports")
	_SQLite_Exec($LabDB, "CREATE TABLE Imports (ID, Username, Title, Aps, Notes, Date)")
EndIf
_SQLite_Exec($LabDB, "pragma synchronous=0");Speed vs Data security. Speed Wins for now.

GUISetState(@SW_SHOW)
While 1
	IF $remote_socketopen == 1 Then
	;	$recv = TCPRecv($sock, 2048)
	;	If @error Then
	;		ConsoleWrite("There was an error fetching from the buffer..." & @CRLF )
	;	EndIf
	;	ConsoleWrite($recv)
	EndIf
	Sleep(1)
WEnd

Func _CreateLoginGUI()
	If $session_key <>  "" Then
		_Connect()
		_Connect()
		$session_key = ""
		GUICtrlSetData ( $Login_Button, "Login")
	Else
		$LoginGUI = GUICreate("WiFiDB Login", 306, 145, 192, 124)
		$User_input = GUICtrlCreateInput("", 80, 16, 225, 21)
		$PWD_Input = GUICtrlCreateInput("", 80, 56, 225, 21)
		$OKButton = GUICtrlCreateButton("OK", 16, 96, 105, 33, $WS_GROUP)
		$CnclButton = GUICtrlCreateButton("Cancel", 152, 96, 113, 33, $WS_GROUP)
		$User_lbl = GUICtrlCreateLabel("Username", 0, 8, 64, 17)
		$PWD_lbl = GUICtrlCreateLabel("Password", 0, 56, 64, 17)
		GUISetState(@SW_SHOW)
		GUICtrlSetOnEvent($OKButton, '_WDBLogin')
		;_WDBLogin()
		GUICtrlSetOnEvent($CnclButton, '_CloseLoginGui')
		GUISetOnEvent($GUI_EVENT_CLOSE, '_CloseLoginGui')
	EndIf
EndFunc

Func _WDBLogin()
;	$WiFiDB_User = GUICtrlRead($User_input)
;	$WiFiDB_Pass = GUICtrlRead($PWD_input)
	$WiFiDB_User = 'pferland'
	$WiFiDB_Pass = 'wires169'

	_CloseLoginGui()
	$Prog_Form = GUICreate("Login Progress", 291, 36, 168, 124)
	$Prog_Bar = GUICtrlCreateLabel("Sending Request...", 16, 16, 168, 17)
	GUISetState(@SW_SHOW)
	ConsoleWrite($WiFiDB_User & @CRLF & $WiFiDB_Pass & @CRLF)
	$messg = "LOGIN|" & $local_address & "|" & $WiFiDB_User
	$send = TCPSend($sock, $messg)
	if @error Then
		ConsoleWrite("Send Error!" & @CRLF)
		GUICtrlSetData ( $Prog_Bar, "Failed to send Message.")
	EndIf
	GUICtrlSetData($Prog_Bar, "Sent, Waiting for Response...")
	ConsoleWrite($messg & @CRLF)
	$ltimeout = TimerInit()
	While 1
		$recv = TCPRecv($sock, 2048)
		If @error Then ExitLoop
		If $recv <> "" Then
			ConsoleWrite("IN: " & $recv & @CRLF)
			$recv_array = StringSplit($recv, "|")
			Switch $recv_array[1]
				Case "EXIT" ;Exit message received, Disconnect
					ConsoleWrite("<-- EXIT -->" & @CRLF)
					$ExitError = $recv_array[2]
					ExitLoop
				Case "PWD" ;Server requested WiFiDB password
					$seed = $recv_array[2]
					ConsoleWrite("SEED: " & $seed & @CRLF)
					$hpwd = StringTrimLeft(_rijndaelCipher($seed, $WiFiDB_Pass, 256, 0), 2)
					$messg = "PWD|" & $hpwd
					ConsoleWrite("OUT: " & $messg & @CRLF)
					ConsoleWrite("-->Sent Password Hash(" & $hpwd & ")" & @CRLF)
					TCPSend($sock, $messg)
					GUICtrlSetData ( $Prog_Bar, "Sending Password....")
				Case "LOGIN"
					If $recv_array[2] = "OK" Then ;Logon successful, Start import
						$session_key = $recv_array[3]
						GUICtrlSetData ( $Prog_Bar, "Logged in!")
						GUICtrlSetData ( $Login_Button, "Logout")
						GUIDelete($Prog_Form)
						ConsoleWrite("-->Logged In(" & $session_key & ")" & @CRLF)
						MsgBox(0,"Logged In!","You have logged into WiFiDB")
						ExitLoop
					Else ;Logon failed due to bad username or password
						$rerr = $recv_array[4]
						ConsoleWrite("--> " & $rerr & " <--" & @CRLF)
						GUICtrlSetData ( $Prog_Bar, "Log In Failed!")
						GUIDelete($Prog_Form)
						MsgBox(0,"Failed Log In!","Failed to log into WiFiDB")
						ExitLoop
					EndIf
				EndSwitch
		Else
			If TimerDiff($ltimeout) > $remote_timeout Then
				ConsoleWrite("Timeout loop" & @CRLF)
				GUIDelete($Prog_Form)
				MsgBox(0,"Failed Log In!","Failed to log into WiFiDB." & @CRLF & "Timed out.")
				ExitLoop
			EndIf
		EndIf
	Wend

EndFunc

Func _Connect()
	ConsoleWrite("Remote Socket Open? " & $remote_socketopen & @CRLF)
	If $remote_socketopen <> 1 Then
		$Host = GUICtrlRead($Host_Input)
		ConsoleWrite("Connecting to :" & $Host & ":" & $remote_port & @CRLF)
		$sock = TCPConnect($Host, $remote_port)
		$sent = TCPSend($sock, "HELLO");// Send Hello message
		If @error Then
			ConsoleWrite("<-- Failed to send hello message to server -->" & @CRLF)
		Else
			$ltimeout = TimerInit()
			While 1
				$recv = TCPRecv($sock, 2048)
				If @error Then
					ConsoleWrite("There was an error fetching from the buffer..." & @CRLF )
					ExitLoop
				EndIf
				If $recv <> "" Then
					ConsoleWrite($recv & @CRLF)
					$recv_array = StringSplit($recv, "|")
				;//	_ArrayDisplay($recv_array)
					IF $recv_array[1] <> "HELLO" Then
						ConsoleWrite("Server did not return correct message...." & @CRLF)
						ExitLoop
					Else
						ConsoleWrite("You are connected!" & @CRLF)
						$remote_socketopen = 1
						GUICtrlSetData ( $Connect_Button, "Disconnect")
						ExitLoop
					EndIf
				EndIf
				If TimerDiff($ltimeout) > $remote_timeout Then ExitLoop
			WEnd
		EndIf
	Else
		ConsoleWrite("Disconnecting..." & @CRLF)
		TCPCloseSocket($sock)
		GUICtrlSetData ( $Connect_Button, "Connect")
		$remote_socketopen = 0
	EndIf
EndFunc

Func _CreateExpGui()
	IF $remote_socketopen <> 1 Then
		ConsoleWrite("You are not connected..." & @CRLF)
		MsgBox(0,"Not Connected", "You are not connected to the WiFiDB API server...")
	Else
		dim $hQuery, $aRow
		$ExpGui = GUICreate("Export", 625, 443, 192, 124)
		$ExpList = GUICtrlCreateListView("ID|Username|Title|AP Count|Notes|Date", 0, 0, 617, 396)
		$ToKMLButton = GUICtrlCreateButton("To KML", 8, 400, 137, 33, $WS_GROUP)
		$ToVs1Button = GUICtrlCreateButton("To VS1", 152, 400, 137, 33, $WS_GROUP)

		GUISetOnEvent($GUI_EVENT_CLOSE, '_CloseExpGui')
		GUICtrlSetOnEvent($ToVs1Button, '_WDBExpVS1')
		GUICtrlSetOnEvent($ToKMLButton, '_WDBExpKML')

		_SQlite_Query (-1, "SELECT * FROM Imports;", $hQuery) ; the query
		While _SQLite_FetchData ($hQuery, $aRow) = $SQLITE_OK
		;	_ArrayDisplay($aRow)
			$insert = $aRow[0] & "|" & $aRow[1] & "|" & $aRow[2] & "|" & $aRow[3] & "|" & $aRow[4] & "|" & $aRow[5]
			GUICtrlCreateListViewItem($insert, $ExpList)

		;	ConsoleWrite($insert & @CRLF)
		WEnd
		GUISetState(@SW_SHOW)

	EndIf
EndFunc

Func _WDBExpKML()
	IF $remote_socketopen <> 1 Then
		ConsoleWrite("You are not connected..." & @CRLF)
		MsgBox(0,"Not Connected", "You are not connected to the WiFiDB API server...")
	Else
		If $session_key <> "" Then
			$type = "KML"
			$data = StringSplit(GUICtrlRead(GUICtrlRead($ExpList)),"|")
			$ID = $data[1]
			ConsoleWrite("EXPORT ID: " & $ID & @CRLF)
			$msg  =  "EXPORT|"& $session_key & "|" & $type & "|" & $ID
			TCPSend($sock, $msg)
			ConsoleWrite("Sent:" & $msg & @CRLF )
			_WDBRecvFile("EXPORT", "KML")
		EndIf
	EndIf
EndFunc

Func _WDBExpVS1()
	IF $remote_socketopen <> 1 Then
		ConsoleWrite("You are not connected..." & @CRLF)
		MsgBox(0,"Not Connected", "You are not connected to the WiFiDB API server...")
	Else
		If $session_key <> "" Then
			$type = "VS1"
			$data = StringSplit(GUICtrlRead(GUICtrlRead($ExpList)),"|")
			$ID = $data[1]
			ConsoleWrite("EXPORT ID: " & $ID & @CRLF)
			$msg  =  "EXPORT|"& $session_key & "|" & $type & "|" & $ID
			TCPSend($sock, $msg)
			ConsoleWrite("Sent:" & $msg & @CRLF )
			_WDBRecvFile("EXPORT", "VS1")
		EndIf
	EndIf
EndFunc


;	_WDBRecvFile args:
;	$mode = LIST/EXPORT
;	$type = LIST[IMPORTS]
;			EXPORT[KML/VS1/GPX]
;		(Type is only used with Export)
Func _WDBRecvFile($mode = "", $type = "" )
	$Prog_Form = GUICreate("Recive File Progress", 350, 75, 168, 124)
	$Prog_Bar = GUICtrlCreateLabel("Sent Request...", 16, 16, 168, 50)
	GUISetState(@SW_SHOW)
	$Filedata = ""
	Dim $retu[1]
	$ltimeout = TimerInit()
	$read_sent = 0
	$LINE = 1
	While 1
		$recv = TCPRecv($sock, 4096)
		If $recv <> "" Then
			$recv_array = StringSplit($recv, "|")
			ConsoleWrite($mode & " [==] " & $recv_array[1] & @CRLF)
			$LINE = $LINE+1
			If $recv_array[1] <> $mode Then
				If $recv_array[0] < 2 Then
					$Filedata  = $Filedata & $recv
					ConsoleWrite(@CRLF & "DATA: " & @CRLF & $recv & @CRLF)
					ContinueLoop
				EndIf
			EndIf
			Switch $recv_array[2]
				Case "WORKING"
					GUICtrlSetData($Prog_Bar, "Waiting for File...")
					ConsoleWrite("Waiting to " & $mode & $type & "..." & @CRLF)
				Case "SENT"
					GUICtrlSetData($Prog_Bar, "File Recieved...")
					ConsoleWrite("Finished " & $type & " " & $mode & @CRLF)
					$md5 = $recv_array[3]
					ConsoleWrite(@CRLF & "MD5: " & $md5 & @CRLF)
					ExitLoop
				Case "READY"
					GUICtrlSetData($Prog_Bar, "Recieving " & $LINE & "...")
					ConsoleWrite(". ")
					$read_sent = 1
					$ii = 2
					If $mode == "EXPORT" Then
						$EXPfilename = $recv_array[3]
						$recv_array[3] = ""
					EndIf
					while $ii <= $recv_array[0]
					;	If $recv_array[$ii] == "LIST" Then
					;		If $ii > 2 Then
					;		;	ContinueLoop
					;		EndIf
						If $recv_array[$ii] == "SENT" Then
							GUICtrlSetData($Prog_Bar, "File Recieved...")
							$md5 = $recv_array[$ii+1]
							ConsoleWrite(@CRLF & "MD5: " & $md5 & @CRLF)
							ExitLoop(2)
						Else
							If $recv_array[$ii] <> $mode Then
								$Filedata  = $Filedata & $recv_array[$ii]
							EndIf
						EndIf
						$ii = $ii+1
					WEnd
				Case "DATA"
					GUICtrlSetData($Prog_Bar, "Recieving " & $LINE & "...")
					ConsoleWrite(". ")
					$read_sent = 1
					$ii = 2
					while $ii <= $recv_array[0]
						If $recv_array[$ii] == "SENT" Then
							$md5 = $recv_array[$ii+1]
							ConsoleWrite(@CRLF & "MD5: " & $md5 & @CRLF)
							ExitLoop(2)
						Else
							If $recv_array[$ii] <> $mode Then
								$Filedata  = $Filedata & $recv_array[$ii]
							EndIf
						EndIf
						$ii = $ii+1
					WEnd
				Case Else
					GUICtrlSetData($Prog_Bar, "Recieving " & $LINE & "...")
					ConsoleWrite(". ")
					$read_sent = 1
					$ii = 1
					while $ii <= $recv_array[0]
						If $recv_array[$ii] == "SENT" Then
							$md5 = $recv_array[$ii+1]
							ConsoleWrite(@CRLF & "2 CASE ELSE: ARRAY MD5: " & $md5 & @CRLF)
							ExitLoop(2)
						Else
							If $recv_array[$ii] <> $mode Then
								$Filedata  = $Filedata & $recv_array[$ii]
							EndIf
						EndIf
						$ii = $ii+1
					WEnd
			EndSwitch
		EndIf
	WEnd
	switch $type
		Case "VS1"
			$filename = $VS1Dir & $EXPfilename
			$Filedata = StringReplace(StringReplace(StringReplace(StringReplace($Filedata, "~", "|"), "READY", ""), $mode, ""), "DATA", "")
		Case "KML"
			$Filedata = StringReplace(StringReplace($Filedata, "~", "|"), "READY", "")
			$filename = $KMLDir & $EXPfilename
		Case "GPX"
			$Filedata = StringReplace(StringReplace($Filedata, "~", "|"), "READY", "")
			$filename = $GPXDir & $EXPfilename
		Case "IMPORTS"
			$Filedata = StringReplace(StringReplace($Filedata, "~", "|"), "READY", "")
			$filename = $TmpDir & "LstImpTmp_" & StringReplace(StringReplace(StringReplace(_NowCalc(), "/", "-")," ", "_"),":", "-") & ".txt"
		Case Else
	EndSwitch
	GUICtrlSetData($Prog_Bar, "Writing File (" & $filename & ")...")
	$cal_MD5 = _MD5($Filedata)
	$file = FileOpen($filename, 2)
	FileWrite($file, $Filedata)
	IF @error Then
		GUICtrlSetData($Prog_Bar, "File: " & $filename & " was NOT written")
		ConsoleWrite("File: " & $filename & " was NOT written" & @CRLF)
		$retu = 0
	Else
		_ArrayAdd($retu, $filename)
		_ArrayAdd($retu, $md5)
		_ArrayAdd($retu, $cal_MD5)
	;	_ArrayDisplay($retu)
		GUICtrlSetData($Prog_Bar, "File: " & $filename & " was written")
		ConsoleWrite("File: " & $filename & " was written" & @CRLF)
	EndIf
	FileClose($file)
	GUIDelete($Prog_Form)
	return $retu
EndFunc

Func _WDBSendFile($File = "")
	$Prog_Form = GUICreate("Recive File Progress", 350, 75, 168, 124)
	$Prog_Bar = GUICtrlCreateLabel("Sent Request...", 16, 16, 168, 50)
	GUISetState(@SW_SHOW)
	GUICtrlSetData($Prog_Bar, "Starting...")
	ConsoleWrite("-->Sending File(" & $File & ")" & @CRLF)
	$iFileOp = FileOpen($File, 16)
	$sBuff = FileRead($iFileOp)
	FileClose($iFileOp)
	GUICtrlSetData($Prog_Bar, "Starting Sent of File...")
	While BinaryLen($sBuff)
		ConsoleWrite(BinaryLen($sBuff) & @CRLF)
		$iSendReturn = TCPSend($sock, $sBuff)
		If @error Then ExitLoop
		$sBuff = BinaryMid($sBuff, $iSendReturn + 1, BinaryLen($sBuff) - $iSendReturn)
		GUICtrlSetData($Prog_Bar, BinaryLen($sBuff) & "B of File to go.")
	WEnd
	TCPSend($sock, "IMPORT|SENT")
	ConsoleWrite("-->File Sent" & @CRLF)
	GUIDelete($Prog_Form)
EndFunc

Func _WDBImportGUI()
	IF $remote_socketopen <> 1 Then
		ConsoleWrite("You are not connected..." & @CRLF)
		MsgBox(0,"Not Connected", "You are not connected to the WiFiDB API server...")
	Else
		If $session_key == "" Then
			ConsoleWrite("You are not logged in..." & @CRLF)
			MsgBox(0,"Not Logged in", "You need to login before you can import to the WiFiDB API server...")
		Else
			$OpenFile = FileOpenDialog("File to Import into WiFiDB", @ScriptDir, "Vistumbler Details (*.vs1)|Text File (*.txt)",1)
			ConsoleWrite("Open File: " & $OpenFile & @CRLF)
			$ImpForm = GUICreate("Enter Your Import Details", 544, 342, 194, 124)
			$Label_Title = GUICtrlCreateLabel("Title of Import", 8, 8, 84, 20)
			GUICtrlSetFont(-1, 10, 400, 0, "MS Sans Serif")
			$Label_Notes = GUICtrlCreateLabel("Notes", 8, 48, 88, 20)
			GUICtrlSetFont(-1, 10, 400, 0, "MS Sans Serif")
			$ImpTitle = GUICtrlCreateInput("", 96, 8, 441, 21)
			$ImpNotes = GUICtrlCreateEdit("", 96, 40, 441, 257)
			$OK_Button = GUICtrlCreateButton("OK", 104, 304, 121, 33, $WS_GROUP)
			$Clo_Button = GUICtrlCreateButton("Close", 232, 304, 121, 33, $WS_GROUP)
			GUISetState(@SW_SHOW)

			GUICtrlSetOnEvent($OK_Button, '_WDBSendImp')
			GUICtrlSetOnEvent($Clo_Button, '_CloseImpGUI')
		EndIf
	EndIf
EndFunc

Func _WDBSendImp()
	$Title = GUICtrlRead($ImpTitle)
	$Notes = GUICtrlRead($ImpNotes)
	$file_exp = StringSplit($OpenFile, "\")
	$file_imp_name = $file_exp[$file_exp[0]]
	ConsoleWrite($file_imp_name & @CRLF)
	_CloseImpGUI()

	$messg = "IMPORT|" & $session_key & '|VS1|' & $file_imp_name & '|' & $Title & '|'&$Notes&'|' & StringLower(_MD5ForFile($OpenFile))
	$send = TCPSend($sock, $messg)
	If @error Then
		ConsoleWrite("Error Sending message" & @CRLF)
	Else
		_WDBSendFile($OpenFile)
	EndIf
EndFunc

Func _CloseExpGui();closes the compass window
	GUIDelete($ExpGUI)
EndFunc   ;==>_CloseCompassGui
Func _CloseImpGui();closes the compass window
	GUIDelete($ImpForm)
EndFunc   ;==>_CloseCompassGui
Func _CloseLoginGui();closes the compass window
	GUIDelete($LoginGUI)
EndFunc   ;==>_CloseCompassGui
Func _CloseGui()
	Exit
EndFunc

Func _GuiGetLists()
	IF $remote_socketopen <> 1 Then
		ConsoleWrite("You are not connected..." & @CRLF)
		MsgBox(0,"Not Connected", "You are not connected to the WiFiDB API server...")
	Else
		$type = "IMPORTS"
		$range = ""
		$msg  =  "LIST|" & $type & "|" & $range
		TCPSend($sock, $msg)
		ConsoleWrite("Sent:" & $msg & @CRLF )
		$list_filename = _WDBRecvFile("LIST", "IMPORTS")
	;	_ArrayDisplay($list_filename)
		if $list_filename == 0 then
			MsgBox(0,"File Error", "There was an error writing the List File.")
		Else
			$ret_md5 = StringUpper($list_filename[2])
			$cal_md5 = StringReplace($list_filename[3], "0x", "")
			ConsoleWrite(@CRLF & "File: " & $list_filename[1] & @CRLF & "Written MD5: " & $cal_md5 & @CRLF & "Sent MD5: " & $ret_md5 & @CRLF)
			if $cal_md5 <> $ret_md5 Then
				MsgBox(0,"MD5 File", "There was an error matching the MD5's.")
			Else
				Dim $aRecords
				If Not _FileReadToArray($list_filename[1],$aRecords) Then
				   MsgBox(0,"Error", " Error reading file:" & @error)
				Else
					For $x = 1 to $aRecords[0]
						$exp = StringSplit($aRecords[$x], "|")
						$id = $exp[1]
						$username = $exp[2]
						$title = $exp[3]
						$aps = $exp[4]
						$notes = $exp[5]
						$date = $exp[6]
						_SQLite_Exec($LabDB, "Insert into Imports ( ID, Username, Title, Aps, Notes, Date) Values ( '"& $id & "', '" & $username & "', '" & $title & "', '" & $aps & "', '" & $notes & "', '" & $date & "');")
						If @error Then
							ConsoleWrite("SQLite Error: " & @error & @CRLF)
						EndIf
					Next
				EndIf
				MsgBox(0,"Imports List File", "The Imports List File is complete.")
			EndIf
		EndIf
	EndIf
EndFunc