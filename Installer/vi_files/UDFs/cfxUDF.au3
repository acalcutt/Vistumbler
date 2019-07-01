#include-once
#cs
	UDF cfx.au3
	serial functions using kernel32.dll
	V1.0
	Uwe Lahni 2008
	V2.0
	Andrew Calcutt 05/16/2009 - Started converting to UDF
	V2.1
	Mikko Keski-Heroja 02/23/2011 - UDF is now compatible with Opt("MustDeclareVars",1) and Date.au3. Global variable $dll is renamed to $commDll.
#ce

Global $commDll
Global $hSerialPort
Global $dcb_Struct
Global $commtimeout
Global $commtimeout_Struct
Global $commState
Global $commState_Struct

Global Const $STX=chr(2)
Global Const $ETX=chr(3)
Global Const $EOT=chr(4)
Global Const $ENQ=chr(5)
Global Const $ACK=chr(6)
Const $NAK=chr(15)
Const $DLE=chr(16)

;====================================================================================
; Function Name:   _OpenComm($CommPort, $CommBaud, $CommBits, $CommParity, $CommStop, $CommCtrl, $DEBUG)
; Description:    Opens serial port
; Parameters:     $CommPort
;				  $CommBaud - default:4800
;				  $CommBits - 4-8
;				  $CommParity - 0=none, 1=odd, 2=even, 3=mark, 4=space
;				  $CommStop - 0,1,5,2
;				  $CommCtrl = 0011
;                 $DEBUG - Show debug messages = 1
; Returns:  on success, returns serial port id?
;           on failure returns -1 and sets @error to 1
; Note:
;====================================================================================
Func _OpenComm($CommPort, $CommBaud = '4800', $CommBits = '8', $CommParity = '0', $CommStop = '0', $CommCtrl = '0011', $DEBUG = '0')
	$commDll = DllOpen("kernel32.dll")
	local $dcbs="long DCBlength;long BaudRate; long fBitFields;short wReserved;" & _
				"short XonLim;short XoffLim;byte Bytesize;byte parity;byte StopBits;byte XonChar; byte XoffChar;" & _
				"Byte ErrorChar;Byte EofChar;Byte EvtChar;short wReserved1"

	local $commtimeouts="long ReadIntervalTimeout;long ReadTotalTimeoutMultiplier;" & _
						"long ReadTotalTimeoutConstant;long WriteTotalTimeoutMultiplier;long WriteTotalTimeoutConstant"

	local const $GENERIC_READ_WRITE=0xC0000000
	local const $OPEN_EXISTING=3
	local const $FILE_ATTRIBUTE_NORMAL =0x80
	local const $NOPARITY=0
	local const $ONESTOPBIT=0

	$dcb_Struct=DllStructCreate($dcbs)
	if @error Then errpr()

	$commtimeout_Struct=DllStructCreate($commtimeouts)
	if @error Then errpr()

	$hSerialPort = DllCall($commDll, "hwnd", "CreateFile", "str", "COM" & $CommPort, _
									"int", $GENERIC_READ_WRITE, _
									"int", 0, _
									"ptr", 0, _
									"int", $OPEN_EXISTING, _
									"int", $FILE_ATTRIBUTE_NORMAL, _
									"int", 0)
	if @error Then errpr()
	If number($hserialport[0])<1 Then
		If $DEBUG = 1 Then consolewrite("Open Error" & @CRLF)
		return (-1)
	EndIf
	$commState=dllcall($commDll,"long","GetCommState","hwnd",$hSerialPort[0],"ptr",DllStructGetPtr($dcb_Struct))
	if @error Then errpr()
	DllStructSetData( $dcb_Struct,"DCBLength",DllStructGetSize($dcb_Struct))
	if @error Then errpr()
	DllStructSetData( $dcb_Struct,"BaudRate",$CommBaud)
	if @error Then errpr()
	DllStructSetData( $dcb_Struct,"Bytesize",$CommBits)
	if @error Then errpr()
	DllStructSetData( $dcb_Struct,"fBitfields",number('0x' & $CommCtrl))
	if @error Then errpr()
	DllStructSetData( $dcb_Struct,"Parity",$CommParity)
	if @error Then errpr()
	DllStructSetData( $dcb_Struct,"StopBits",'0x' & $CommStop)
	if @error Then errpr()
	DllStructSetData( $dcb_Struct,"XonLim",2048)
	if @error Then errpr()
	DllStructSetData( $dcb_Struct,"XoffLim",512)
	if @error Then errpr()
	$commState=dllcall($commDll,"short","SetCommState","hwnd",$hSerialPort[0],"ptr",DllStructGetPtr($dcb_Struct))
	if @error Then errpr()
	If $DEBUG = 1 Then consolewrite("CommState: "& $commstate[0] & @CRLF)
	if $commstate[0]=0 Then
		If $DEBUG = 1 Then consolewrite("SetCommState Error" & @CRLF)
		return (-1)
	EndIf
	DllStructSetData( $commtimeout_Struct,"ReadIntervalTimeout",-1)
	$commtimeout=dllcall($commDll,"long","SetCommTimeouts","hwnd",$hSerialPort[0],"ptr",DllStructGetPtr($commtimeout_Struct))
	if @error Then errpr()
	return number($hSerialPort[0])
EndFunc

;====================================================================================
; Function Name:   _CloseComm($CommSerialPort)
; Description:    Closes serial port
; Parameters:     $CommSerialPort - value returned by _OpenComm
; Returns:  on success, returns 1
;           on failure returns -1 and sets @error to 1
; Note:
;====================================================================================
Func _CloseComm($CommSerialPort, $DEBUG = 0)
	local $closeerr=DllCall($commDll, "int", "CloseHandle", "hwnd", $CommSerialPort)
	if @error Then
		errpr()
		Exit
	EndIf
	If $DEBUG = 1 Then ConsoleWrite("Close " & $closeerr[0] & @crlf)
	return($closeerr[0])
EndFunc

Func _tx($CommSerialPort, $t, $DEBUG = 0)
	if $DEBUG=1 then FileWriteLine("debug.txt","Send " &c2s($t))
	local $lptr0=dllstructcreate("long_ptr")
	local $tbuf=$t
	local $txr=dllcall($commDll,"int","WriteFile","hwnd",$CommSerialPort, _
						"str",$tbuf, _
						"int",stringlen($tbuf), _
						"long_ptr", DllStructGetPtr($lptr0), _
						"ptr", 0)
	if @error Then errpr()
EndFunc

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
	if $DEBUG=1 then ConsoleWrite("Wait " & $MinBufferSize & " " & $MaxWaitTime & @CRLF)
	Local $rxbuf
	local $jetza=TimerInit()
	local $lptr0=dllstructcreate("long_ptr")

	local $rxr, $rxl, $to
	Do
		$rxr=dllcall($commDll,"int","ReadFile","hwnd",$CommSerialPort, _
							"str"," ", _
							"int",1, _
							"long_ptr", DllStructGetPtr($lptr0), _
							"ptr", 0)
		if @error Then errpr()
		$rxl=DllStructGetData($lptr0,1)
		if $DEBUG=1 then ConsoleWrite("R0:" & $rxr[0] & " |R1:" & $rxr[1] & " |R2:" & $rxr[2] & " |rxl:" & $rxl & " |R4:" & $rxr[4] & @CRLF)
		if $rxl>=1 then
			$rxbuf&=$rxr[2]
		EndIf
		$to=TimerDiff($jetza)
    Until stringlen($rxbuf) >= $MinBufferSize OR $to > $MaxWaitTime
	Return($rxbuf)
EndFunc

Func _rx($rxbuf, $n=0, $DEBUG = 0)
	local $r
	if StringLen($rxbuf)<$n then
		$rxbuf=""
		Return("")
	EndIf
	If $n=0	Then
		$r=$rxbuf
		$rxbuf=""
		Return($r)
	EndIf
	If $n<0 then
		$rxbuf=""
		Return("")
	EndIf
	$r=Stringleft($rxbuf,$n)
	local $rl=Stringlen($rxbuf)
	$rxbuf=StringRight($rxbuf,$rl-$n)
	if $DEBUG=1 then FileWriteLine("debug.txt","Read " & c2s($r))
	return($r)
EndFunc

Func c2s($t)
	local $tc
	local $ts=""
	For $ii= 1 To StringLen($t)
		$tc=StringMid($t,$ii,1)
		if Asc($tc)<32 Then
			$ts&="<" & asc($tc) & ">"
		Else
			$ts&=$tc
		EndIf
	Next
	return $ts
EndFunc


func errpr()
	consolewrite ("Error " & @error & @CRLF)
EndFunc
