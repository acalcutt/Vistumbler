#cs
	UDF cfx.au3
	serial functions using kernel32.dll
	V1.0
	Uwe Lahni 2008
	V2.0
	Andrew Calcutt 05/16/2009 - Started converting to UDF
	Andrew Calcutt 04/03/2010 - Moved contants outside of the functions
#ce
#include-once
Global $dll
Global $hSerialPort
Global $dcb_Struct
Global $commtimeout
Global $commtimeout_Struct
Global $commState
Global $commState_Struct
Const $GENERIC_READ_WRITE = 0xC0000000
Const $S_OPEN_EXISTING = 3
Const $S_FILE_ATTRIBUTE_NORMAL = 0x80
Const $NOPARITY = 0
Const $ONESTOPBIT = 0

;====================================================================================
; Function Name:   _OpenComm($CommPort, $CommBaud, $CommBits, $CommParity, $CommStop, $CommCtrl, $DEBUG)
; Description:    Opens serial port
; Parameters:     $CommPort
;				  $CommBaud
;				  $CommBits - 4-8
;				  $CommParity - 0=none, 1=odd, 2=even, 3=mark, 4=space
;				  $CommStop - 0=1 1=1.5 2=2
;				  $CommCtrl = 0011
;				  $DEBUG - Show debug messages = 1
; Returns:  on success, returns serial port id?
;           on failure returns -1 and sets @error to 1
; Note:
;====================================================================================
Func _OpenComm($CommPort, $CommBaud = '4800', $CommBits = '8', $CommParity = '0', $CommStop = '0', $CommCtrl = '0011', $DEBUG = '0')
	$dll = DllOpen("kernel32.dll")
	$dcbs = "long DCBlength;long BaudRate; long fBitFields;short wReserved;"
	$dcbs &= "short XonLim;short XoffLim;byte Bytesize;byte parity;byte StopBits;byte XonChar; byte XoffChar;"
	$dcbs &= "Byte ErrorChar;Byte EofChar;Byte EvtChar;short wReserved1"

	$commtimeouts = "long ReadIntervalTimeout;long ReadTotalTimeoutMultiplier;"
	$commtimeouts &= "long ReadTotalTimeoutConstant;long WriteTotalTimeoutMultiplier;long WriteTotalTimeoutConstant"

	$dcb_Struct = DllStructCreate($dcbs)
	If @error Then errpr()

	$commtimeout_Struct = DllStructCreate($commtimeouts)
	If @error Then errpr()

	$hSerialPort = DllCall($dll, "hwnd", "CreateFile", "str", "COM" & $CommPort, _
			"int", $GENERIC_READ_WRITE, _
			"int", 0, _
			"ptr", 0, _
			"int", $S_OPEN_EXISTING, _
			"int", $S_FILE_ATTRIBUTE_NORMAL, _
			"int", 0)
	If @error Then errpr()
	If Number($hSerialPort[0]) < 1 Then
		If $DEBUG = 1 Then ConsoleWrite("Open Error" & @CRLF)
		Return (-1)
	EndIf
	$commState = DllCall($dll, "long", "GetCommState", "hwnd", $hSerialPort[0], "ptr", DllStructGetPtr($dcb_Struct))
	If @error Then errpr()
	DllStructSetData($dcb_Struct, "DCBLength", DllStructGetSize($dcb_Struct))
	If @error Then errpr()
	DllStructSetData($dcb_Struct, "BaudRate", $CommBaud)
	If @error Then errpr()
	DllStructSetData($dcb_Struct, "Bytesize", $CommBits)
	If @error Then errpr()
	DllStructSetData($dcb_Struct, "fBitfields", Number('0x' & $CommCtrl))
	If @error Then errpr()
	DllStructSetData($dcb_Struct, "Parity", $CommParity)
	If @error Then errpr()
	DllStructSetData($dcb_Struct, "StopBits", '0x' & $CommStop)
	If @error Then errpr()
	DllStructSetData($dcb_Struct, "XonLim", 2048)
	If @error Then errpr()
	DllStructSetData($dcb_Struct, "XoffLim", 512)
	If @error Then errpr()
	$commState = DllCall($dll, "short", "SetCommState", "hwnd", $hSerialPort[0], "ptr", DllStructGetPtr($dcb_Struct))
	If @error Then errpr()
	If $DEBUG = 1 Then ConsoleWrite("CommState: " & $commState[0] & @CRLF)
	If $commState[0] = 0 Then
		If $DEBUG = 1 Then ConsoleWrite("SetCommState Error" & @CRLF)
		Return (-1)
	EndIf
	DllStructSetData($commtimeout_Struct, "ReadIntervalTimeout", -1)
	$commtimeout = DllCall($dll, "long", "SetCommTimeouts", "hwnd", $hSerialPort[0], "ptr", DllStructGetPtr($commtimeout_Struct))
	If @error Then errpr()
	Return Number($hSerialPort[0])
EndFunc   ;==>_OpenComm

;====================================================================================
; Function Name:   _CloseComm($CommSerialPort)
; Description:    Closes serial port
; Parameters:     $CommSerialPort - value returned by _OpenComm
;				  $DEBUG - Show debug messages = 1
; Returns:  on success, returns 1
;           on failure returns 0
; Note:
;====================================================================================
Func _CloseComm($CommSerialPort, $DEBUG = 0)
	$closeerr = DllCall($dll, "int", "CloseHandle", "hwnd", $CommSerialPort)
	If @error Then errpr()
	If $DEBUG = 1 Then ConsoleWrite("Close " & $closeerr[0] & @CRLF)
	Return ($closeerr[0])
EndFunc   ;==>_CloseComm

;====================================================================================
; Function Name:   _tx($CommSerialPort, $tbuf, $DEBUG = 0)
; Description:
; Parameters:     $CommSerialPort - value returned by _OpenComm
;				  $t - minimum buffer data size
;				  $DEBUG - Show debug messages = 1
; Returns:  on success, returns 1
;           on failure returns -1 and sets @error to 1
; Note:
;====================================================================================
Func _tx($CommSerialPort, $tbuf, $DEBUG = 0)
	If $DEBUG = 1 Then FileWriteLine("debug.txt", "Send " & c2s($tbuf))
	$lptr0 = DllStructCreate("long_ptr")
	$txr = DllCall($dll, "int", "WriteFile", "hwnd", $CommSerialPort, _
			"str", $tbuf, _
			"int", StringLen($tbuf), _
			"long_ptr", DllStructGetPtr($lptr0), _
			"ptr", 0)
	If @error Then errpr()
EndFunc   ;==>_tx

;====================================================================================
; Function Name:   _rxwait($CommSerialPort, $MinBufferSize, $MaxWaitTime, $DEBUG = 0)
; Description:    Recieves data
; Parameters:     $CommSerialPort - value returned by _OpenComm
;				  $MinBufferSize - Buffer size to wait for
;				  $MaxWaitTime - Maximum time to wait before failing
;				  $DEBUG - Show debug messages
; Returns:  on success, returns 1
;           on failure returns -1 and sets @error to 1
; Note:
;====================================================================================
Func _rxwait($CommSerialPort, $MinBufferSize, $MaxWaitTime, $DEBUG = 0)
	If $DEBUG = 1 Then ConsoleWrite("Wait " & $MinBufferSize & " " & $MaxWaitTime & @CRLF)
	Local $rxbuf
	$jetza = TimerInit()
	$lptr0 = DllStructCreate("long_ptr")

	Do
		$rxr = DllCall($dll, "int", "ReadFile", "hwnd", $CommSerialPort, _
				"str", " ", _
				"int", 1, _
				"long_ptr", DllStructGetPtr($lptr0), _
				"ptr", 0)
		If @error Then errpr()
		$rxl = DllStructGetData($lptr0, 1)
		If $DEBUG = 1 Then ConsoleWrite("R0:" & $rxr[0] & " |R1:" & $rxr[1] & " |R2:" & $rxr[2] & " |rxl:" & $rxl & " |R4:" & $rxr[4] & @CRLF)
		If $rxl >= 1 Then
			$rxbuf &= $rxr[2]
		EndIf
		$to = TimerDiff($jetza)
	Until StringLen($rxbuf) >= $MinBufferSize Or $to > $MaxWaitTime
	Return ($rxbuf)
EndFunc   ;==>_rxwait

;====================================================================================
; Function Name:   _rx($rxbuf, $MinBufferSize, $DEBUG = 0)
; Description:
; Parameters:     $rxbuf - buffer data
;				  $MinBufferSize - minimum buffer data size
;				  $DEBUG - Show debug messages = 1
; Returns:
;
; Note:
;====================================================================================
Func _rx($rxbuf, $MinBufferSize = 0, $DEBUG = 0)
	If StringLen($rxbuf) < $MinBufferSize Then
		$rxbuf = ""
		Return ("")
	EndIf
	If $MinBufferSize = 0 Then
		$r = $rxbuf
		$rxbuf = ""
		Return ($r)
	EndIf
	If $MinBufferSize < 0 Then
		$rxbuf = ""
		Return ("")
	EndIf
	$r = StringLeft($rxbuf, $MinBufferSize)
	$rl = StringLen($rxbuf)
	$rxbuf = StringRight($rxbuf, $rl - $MinBufferSize)
	If $DEBUG = 1 Then FileWriteLine("debug.txt", "Read " & c2s($r))
	Return ($r)
EndFunc   ;==>_rx

Func c2s($t)
	$ts = ""
	For $ii = 1 To StringLen($t)
		$tc = StringMid($t, $ii, 1)
		If Asc($tc) < 32 Then
			$ts &= "<" & Asc($tc) & ">"
		Else
			$ts &= $tc
		EndIf
	Next
	Return $ts
EndFunc   ;==>c2s


Func errpr()
	ConsoleWrite("Error " & @error & @CRLF)
EndFunc   ;==>errpr