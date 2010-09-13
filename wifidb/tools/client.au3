$remote_address = '192.168.1.27'
$remote_port = 9000
dim $client_array
TCPStartup()
Opt("TCPTimeout", 100)
$sock = TCPConnect($remote_address, $remote_port)
If @error Then
	ConsoleWrite("<-- Failed to open socket -->" & @CRLF)
Else
	$remote_socketopen = 1
	ConsoleWrite("<-- Opened socket -->" & @CRLF)
	$sent = TCPSend($sock, "HELLO");// Send Hello message
	If @error Then
		ConsoleWrite("<-- Failed to send hello message to server -->" & @CRLF)
	Else
		$client_array[''] =
		ConsoleWrite("<-- Sent hello message to server -->" & @CRLF)
		$ltimeout = TimerInit()
		While 1
			$recv = TCPRecv($sock, 2048)
			If @error Then ExitLoop
			If $recv <> "" Then
				ConsoleWrite($recv & @CRLF)
				$recv_array = StringSplit($recv, "|")

				Switch $recv_array[1]
					Case "HELLO"
						ConsoleWrite("<-- Ready -->" & @CRLF)
						_WDB_Console($sock, $client_array, "")
					Case "LOCATE"
						ConsoleWrite("<-- LOCATE Response -->" & @CRLF)
						Dim $RLat, $RLon, $RSats, $RDate, $RTime
						If $recv_array[2] = "OK" Then
							$RLat = $recv_array[3]
							$RLon = $recv_array[4]
							$RSats = $recv_array[5]
							$RDate = $recv_array[6]
							$RTime = $recv_array[7]
							$LatitudeWifidb = $RLat
							$LongitudeWifidb = $RLon
							_ArrayDisplay($recv_array)
						EndIf

					Case Else
						ConsoleWrite("<-- Re-Sending Hello -->" & @CRLF)
						TCPSend($sock, "HELLO");// Re-Send Hello message
				EndSwitch
			EndIf
			If TimerDiff($ltimeout) > $remote_timeout Then ExitLoop
		WEnd
	EndIf
EndIf
If $remote_socketopen = 1 Then TCPCloseSocket($sock)






Func _WDB_Console($sock, $client_array, $mesg)
	IF $mesg == ""
		ConsoleWrite("WiFiDB_API:# ")
	ELSE
		ConsoleWrite($mesg & @CRLF & "WiFiDB_API:# ")
	ElseIf
	$get_input = ConsoleRead()
	IF $get_input == ''
		_WDB_Console($sock , $client_array)
	EndIf
	ConsoleWrite($get_input & @CRLF)
	$get_exp = StringSplit("|", $get_input)
	$cmd = StringUpper($get_exp[0])
	Switch $cmd
		Case "LOGIN"
			$get_input = "LOGIN|" & $local_address & "|" & $get_exp[1]
			ConsoleWrite($get_input & @CRLF)
		Case "LOCATE"
			$Send_mesg = $get_input

		Case Else
			_WDB_Console($sock , $client_array, "Command Not Found")
	EndSwitch
	IF $Send_mesg == ""
		_WDB_Console($sock, $client_array);
	Else
		IF TCPSend($sock, $Send_mesg)
			IF $Send_mesg <> "IMPORT|SENT"
				ConsoleWrite("Sent message waiting for server...\r\n")
			EndIF
		Else
			ConsoleWrite("Failed to send message" & @CRLF)
		EndIF
	EndIf
EndFunc