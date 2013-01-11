; ===================================================================
; HTTP UDF's
; v0.5
;
; By: Greg "Overload" Laabs
; Last Updated: 07-22-06
; Tested with AutoIt Version 3.1.1.131
; Extra requirements: Nothing!
;
; A set of functions that allow you to download webpages and submit
; POST requests.
;
; Main functions:
; _HTTPConnect - Connects to a webserver
; _HTTPGet - Submits a GET request to a webserver
; _HTTPPost - Submits a POST request to a webserver
; _HTTPRead - Reads the response from a webserver
; ===================================================================


TCPStartup()

Global $_HTTPUserAgent = "AutoItScript/"&@AutoItVersion
Global $_HTTPLastSocket = -1
Global $_HTTPRecvTimeout = 5000

; ===================================================================
; _HTTPSetUserAgent($Program, $Version)
;
; Sets the User-Agent that will be sent with all future _HTTP
; functions. If this is never called, the user agent is set to
; AutoItScript/[YourAutoItVersion]
; Parameters:
;    $Program - IN - The name of the program
;    $Version - IN - The version number of the program
; Returns:
;    None
; ===================================================================
Func _HTTPSetUserAgent($Program, $Version)
	$_HTTPUserAgent = $Program&"/"&$Version
EndFunc

; ===================================================================
; _HTTPConnect($host, [$port])
;
; Opens a connection to $host on the port you supply (or 80 if you don't supply a port. Returns the socket of the connection.
; Parameters:
;    $host - IN - The hostname you want to connect to. This should be in the format "www.google.com" or "localhost"
;    $port - OPTIONAL IN - The port to connect on. 80 is default.
; Returns:
;    The socket of the connection.
; Remarks:
;   Possible @errors:
;   1 - Unable to open socket - @extended is set to Windows API WSAGetLasterror return
; ===================================================================
Func _HTTPConnect($host, $port = 80)
	Dim $ip = TCPNameToIP ( $host )
	Dim $socket = TCPConnect ( $ip, 80 )

	If ($socket == -1) Then
		SetError(1, @error)
		Return -1
	EndIf

	$_HTTPLastSocket = $socket
	SetError(0)
	Return $socket
EndFunc

; Possible @errors:
; 1 - No socket
Func _HTTPClose($socket = -1)
	If $socket == -1 Then
		If $_HTTPLastSocket == -1 Then
			SetError(1)
			Return 0
		EndIf
		$socket = $_HTTPLastSocket
	EndIf
	TCPCloseSocket($socket)

	SetError(0)
	Return 1
EndFunc


; ===================================================================
; _HTTPGet($host, $page, [$socket])
;
; Executes a GET request on an open socket.
; Parameters:
;    $host - IN - The hostname you want to get the page from. This should be in the format "www.google.com" or "localhost"
;    $page - IN - The the file you want to get. This should always start with a slash. Examples: "/somepage.php" or "/somedirectory/somefile.zip"
;    $socket - OPTIONAL IN - The socket opened by _HTTPConnect. If this is not supplied, the last socket opened with _HTTPConnect will be used.
; Returns:
;    The number of bytes sent in the request.
; Remarks:
;   Possible @errors:
;   1 - No socket supplied and no current socket exists
;   2 - Error sending to socket. Check @extended for Windows API WSAGetError return
; ===================================================================
Func _HTTPGet($host, $page, $socket = -1)
	Dim $command

	If $socket == -1 Then
		If $_HTTPLastSocket == -1 Then
			SetError(1)
			Return
		EndIf
		$socket = $_HTTPLastSocket
	EndIf

	$command = "GET "&$page&" HTTP/1.1"&@CRLF
	$command &= "Host: " &$host&@CRLF
	$command &= "User-Agent: "&$_HTTPUserAgent&@CRLF
	$command &= "Connection: close"&@CRLF
	$command &= ""&@CRLF

	Dim $bytessent = TCPSend($socket, $command)

	If $bytessent == 0 Then
		SetExtended(@error)
		SetError(2)
		return 0
	EndIf

	SetError(0)
	Return $bytessent
EndFunc

; ===================================================================
; _HTTPPost($host, $page, [$socket])
;
; Executes a POST request on an open socket.
; Parameters:
;    $host - IN - The hostname you want to get the page from. This should be in the format "www.google.com" or "localhost"
;    $page - IN - The the file you want to get. This should always start with a slash. Examples: "/" or "/somedirectory/submitform.php"
;    $socket - OPTIONAL IN - The socket opened by _HTTPConnect. If this is not supplied, the last socket opened with _HTTPConnect will be used.
;    $data - OPTIONAL IN - The data to send in the post request. This should first be run through _HTTPEncodeString()
; Returns:
;    The number of bytes sent in the request.
; Remarks:
;   Possible @errors:
;   1 - No socket supplied and no current socket exists
;   2 - Error sending to socket. Check @extended for Windows API WSAGetError return
; ===================================================================
Func _HTTPPost($host, $page, $socket = -1, $data = "")
	Dim $command

	If $socket == -1 Then
		If $_HTTPLastSocket == -1 Then
			SetError(1)
			Return
		EndIf
		$socket = $_HTTPLastSocket
	EndIf

	Dim $datasize = StringLen($data)

	$command = "POST "&$page&" HTTP/1.1"&@CRLF
	$command &= "Host: " &$host&@CRLF
	$command &= "User-Agent: "&$_HTTPUserAgent&@CRLF
	$command &= "Connection: close"&@CRLF
	$command &= "Content-Type: application/x-www-form-urlencoded"&@CRLF
	$command &= "Content-Length: "&$datasize&@CRLF
	$command &= ""&@CRLF
	$command &= $data&@CRLF

	Dim $bytessent = TCPSend($socket, $command)

	If $bytessent == 0 Then
		SetExtended(@error)
		SetError(2)
		return 0
	EndIf

	SetError(0)
	Return $bytessent
EndFunc

; ===================================================================
; _HTTPRead([$socket], [$flag])
;
; Retrieves data from an open socket. This should only be called after _HTTPGet or _HTTPPost is called.
; Parameters:
;    $socket - OPTIONAL IN - The socket you want to receive data from. If this is not supplied, the last socket opened with _HTTPConnect will be used.
;    $flag - OPTIONAL IN - Determines how the data will be returned. See Remarks.
; Returns:
;    See "Flags" in remarks, below.
; Remarks:
;   Possible @errors:
;   1 - No socket
;   3 - Timeout reached before any data came through the socket
;   4 - Some data came through, but not all of it. Return value is the number of bytes received.
;   5 - Unable to parse HTTP Response from server. Return value is the HTTP Response line
;   6 - Unexpected header data returned. Return value is the line that caused the error
;   7 - Invalid flag
;   8 - Unable to parse chunk size. Return value is the line that caused the error
;   Flags:
;   0 - Return value is the body of the page (default)
;   1 - Return value is an array:
;       [0] = HTTP Return Code
;       [1] = HTTP Return Reason (human readable return code like "OK" or "Forbidden"
;       [2] = HTTP Version
;       [3] = Two dimensional array with the headers. Each item has:
;             [0] = Header name
;             [1] = Header value
;       [4] = The body of the page
; ===================================================================
Func _HTTPRead($socket = -1, $flag = 0)
	If $socket == -1 Then
		If $_HTTPLastSocket == -1 Then
			SetError(1)
			Return
		EndIf
		$socket = $_HTTPLastSocket
	EndIf

	Dim $timer = TimerInit()
	Dim $performancetimer = TimerInit()
	Dim $downloadtime = 0

	Dim $headers[1][2] ; An Array of the headers found
	Dim $numheaders = 0 ; The number of headers found
	Dim $body = "" ; The body of the message
	Dim $HTTPVersion ; The HTTP version of the server (almost always 1.1)
	Dim $HTTPResponseCode ; The HTTP response code like 200, or 404
	Dim $HTTPResponseReason ; The human-readable response reason, like "OK" or "Not Found"
	Dim $bytesreceived = 0 ; The total number of bytes received
	Dim $data = "" ; The entire raw message gets put in here.
	Dim $chunked = 0 ; Set to 1 if we get the "Transfer-Encoding: chunked" header.
	Dim $chunksize = 0 ; The size of the current chunk we are processing.
	Dim $chunkprocessed = 0 ; The amount of data we have processed on the current chunk.
	Dim $contentlength ; The size of the body, if NOT using chunked transfer mode.
	Dim $part = 0 ; Refers to what part of the data we're currently parsing:
	; 0 - Nothing parsed, so HTTP response should come next
	; 1 - Currently parsing headers
	; 2 - Currently waiting for the next chunk size - this is skipped if the transfer-encoding is not chunked
	; 3 - Currently waiting for or parsing body data
	; 4 - Currently parsing footers
	While 1
		Sleep(10)
		Dim $recv = TCPRecv($socket,16)
		If @error <> 0 Then
			;ConsoleWrite("Server closed connection")
			;@error appears to be -1 after the server closes the connection. A good way to tell that we're finished, because we always send
			;the "Connection: close" header to the server.
			; !!! This is no longer used because we can now tell that we're done by checking the content-length header or properly handling
			; chunked data.
		EndIf

		If $recv <> "" Then
			$bytesreceived = $bytesreceived + StringLen($recv)
			$timer = TimerInit()
			$data &= $recv
;~ 			ConsoleWrite("Bytes downloaded: "&$bytesreceived&@CRLF)
		EndIf

		Dim $split = StringSplit($data,@CRLF,1)
		$data = ""
		Dim $i
		For $i=1 To $split[0]
			If $i=$split[0] Then
				If $part < 2 OR $chunked = 1 Then
					; This is tricky. The last line we've received might be truncated, so we only want to process it under special cases.
					; Non chunked data doesn't always send a CRLF at the end so there's no way to tell if this is truly the last line without parsing it.
					; However, we don't want to parse it if it's only a partial header or something.
					; The solution: We will only process this last line if we're at the body section and the transfer-encoding is NOT chunked.
					$data = $split[$i]
					ExitLoop
				EndIf
			EndIf

			Dim $newpart = $part
			Switch $part
				Case 0 ; Nothing parsed, so HTTP response should come next
					If $split[$i] <> "" Then
						Dim $regex = StringRegExp($split[$i],"^HTTP/([0-9.]+) ([0-9]+) ([a-zA-Z0-9 ]+)$",3)
						If @error <> 0 Then
							SetError(5)
							Return $split[$i]
						Else
							$HTTPVersion = $regex[0]
							$HTTPResponseCode = $regex[1]
							$HTTPResponseReason = $regex[2]
							If $HTTPResponseCode <> 100 Then
								$newpart = 1
							EndIf
						EndIf
					EndIf
				Case 1, 4 ; Currently parsing headers or footers
					;If the line is blank, then we're done with headers and the body is next
					If $split[$i] == "" Then
						If $part = 1 Then
							If $chunked Then
								$newpart = 2
							Else
								$newpart = 3
							EndIf
						ElseIf $part = 4 Then
							; If $part is 4 then we're processing footers, so we're all done now.
							ExitLoop 2
						EndIf
					Else ;The line wasn't blank
						;Check to see if the line begins with whitespace. If it does, it's actually
						;a continuation of the previous header
						Dim $regex = StringRegExp($split[$i], "^[ \t]+([^ \t].*)$", 3)
						If @error <> 1 Then
							If $numheaders == 0 Then
								SetError(6)
								Return $split[$i]
							EndIf
							$headers[$numheaders-1][1] &= $regex[0]
						Else;The line didn't start with a space
							Dim $regex = StringRegExp($split[$i],"^([^ :]+):[ \t]*(.*)$",3)
							If @error <> 1 Then
								;This is a new header, so add it to the array
								$numheaders = $numheaders + 1
								ReDim $headers[$numheaders][2]
								$headers[$numheaders-1][0] = $regex[0]
								$headers[$numheaders-1][1] = $regex[1]

								; There are a couple headers we need to know about. We'll process them here.
								If $regex[0] = "Transfer-Encoding" AND $regex[1] = "chunked" Then
									$chunked = 1
								ElseIf $regex[0] = "Content-Length" Then
									$contentlength = Int($regex[1])
								EndIf
							Else
								SetError(6)
								Return $split[$i]
							EndIf
						EndIf
					EndIf
				Case 2 ; Awaiting chunk size
					$regex = StringRegExp($split[$i],"^([0-9a-f]+);?.*$",3)
					If @error <> 0 Then
						SetError(8)
						Return $split[$i]
					EndIf
					$chunksize = $regex[0]
					$chunksize = Dec($chunksize)
					$chunkprocessed = 0

					If $chunksize == 0 Then
						$newpart = 4
					Else
						$newpart = 3
					EndIf
				Case 3 ; Awaiting body data
					$body &= $split[$i]

					$chunkprocessed = $chunkprocessed + StringLen($split[$i])

					If $chunked Then
						If $chunkprocessed >= $chunksize Then
							$newpart = 2
						Else
							$body &= @CRLF
							$chunkprocessed = $chunkprocessed + 2; We add 2 for the CRLF we stipped off.
						EndIf
					Else
						If $chunkprocessed >= $contentlength Then
							ExitLoop 2
						Else
							If $i < $split[0] Then
								; Only add a CRLF if this is not the last line received.
								$body &= @CRLF
								$chunkprocessed = $chunkprocessed + 2; We add 2 for the CRLF we stipped off.
							EndIf
						EndIf
					EndIf
				Case Else
					; This should never happen
			EndSwitch
			$part = $newpart
		Next

		If $bytesreceived == 0 AND TimerDiff($timer) > $_HTTPRecvTimeout Then
			SetError(3)
			Return 0
		ElseIf $bytesreceived > 0 AND TimerDiff($timer) > $_HTTPRecvTimeout Then
			ConsoleWrite($body)
			SetError(4)
			Return $bytesreceived
		EndIf
	WEnd
	$downloadtime = TimerDiff($performancetimer)
	;ConsoleWrite("Performance: Download time: "&$downloadtime&@CRLF)

	Switch $flag
		Case 0
			SetError(0)
			Return $body
		Case 1
			Dim $return[5]
			$return[0] = $HTTPResponseCode
			$return[1] = $HTTPResponseReason
			$return[2] = $HTTPVersion
			$return[3] = $headers
			$return[4] = $body
			SetError(0)
			Return $return
		Case Else
			SetError(7)
			Return 0
	EndSwitch
EndFunc

; ===================================================================
; _HTTPEncodeString($string)
;
; Encodes a string so it can safely be transmitted via HTTP
; Parameters:
;    $string - IN - The string to encode
; Returns:
;    A valid encoded string that can be used as GET or POST variables.
; ===================================================================
Func _HTTPEncodeString($string)
	Local Const $aURIValidChars[256] = _
			[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, _
			0, 1, 0, 0, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 0, 0, _
			1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1, _
			0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 0, _
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, _
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, _
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, _
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

	Local $sEncoded = ""
	For $i = 1 To StringLen($string)
		Local $c = StringMid($string, $i, 1)
		If $c = " " Then $c = "+"
		If Number($aURIValidChars[Asc($c) ]) Then
			$sEncoded &= $c
		Else
			$sEncoded &= StringFormat("%%%02X", Asc($c))
		EndIf
	Next

	Return $sEncoded
EndFunc   ;==>_WebComposeURL

Func _HTTPPost_contenttype($file = "")
	$fileextension = StringRight($file,4)
; I blieve these are the only 2 types that matter when uploading
	Switch $fileextension
		Case ".txt"
			$contenttype = "text/plain"
		Case Else
			$contenttype = "application/octet-stream"
		EndSwitch
	Return $contenttype
EndFunc