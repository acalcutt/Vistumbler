;License Information------------------------------------
;Copyright (C) 2008 Andrew Calcutt
;This file was created by martin of the AutoIt forum. (http://www.autoitscript.com/forum/index.php?showtopic=45842&hl=commmg)
;This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; Version 2 of the License.
;This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
;You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
;--------------------------------------------------------
#cs
	UDF for commg.dll
	V1.0 Replaces mgcomm.au3
#ce
Const $sUDFVersion = 'CommMG.au3 V2.1 '
#cs
	Version 2.1.1 Added missing declarations which caused problems in scripts using Opt("MustDeclareVars",1) - thanks to Hannes
	Version 2.1 Thanks to jps1x2 for the read/send bte array incentive and testing.
	Version 2.0.2 beta changed readbytearray so returns no of bytes read
	Version 2.0.1 beta
	added _CommSendByteArray and _CommReadByteArray
	Version 2.0 - added _CommSwitch. Can now use up to 4 ports.
	added option for flow control = NONE to _CommSetPort
	
	AutoIt Version: 3.2.3++
	Language:       English
	
	Description:    Functions for serial comms using commg.dll
	Works with COM ports, USB to Serial converters, Serial to RS424 etc
	
	Functions available:
	_CommGetVersion
	_CommListPorts
	_CommSetPort
	_CommPortConnection
	_CommClearOutputBuffer
	_CommClearInputBuffer
	_CommGetInputcount
	_CommGetOutputcount
	_CommSendString
	_CommGetString
	_CommGetLine
	_CommReadByte
	_CommReadChar
	_CommSendByte
	_CommSendBreak; not tested!!!!!!!!!!
	_CommCloseport
	_CommSwitch
	_CommSendByteArray
	_CommReadByteArray
	
	Author: Martin Gibson
#ce
#include-once

Global $fPortOpen = False
Global $hDll


;===============================================================================
;
; Function Name:  _CommListPorts($iReturnType=1)
; Description:    Gets the list of available ports seperated by '|' or as an array
;
; Parameters:     $iReturnType -  integer:if $iReturnType = 1 then return a string with the list of COM ports seperated by '|'
;                                         if $iReturnType <> 1 then return an array of strings, with element [0] holding the number of COM ports
; Returns;  on success - a string eg 'COM1|COM8', or array eg ['2','COM1','COM2']
;           on failure - an empty string and @error set to 1 if dll could not list any ports
;                                            @error set to 2 id dll not open and couldn't be opened

;===============================================================================
Func _CommListPorts($iReturnType = 1)
	Local $vDllAns, $lpres
	If Not $fPortOpen Then
		$hDll = DllOpen('commg.dll')
		If $hDll = -1 Then
			SetError(2)
			;$sErr = 'Failed to open commg.dll'
			Return 0;failed
		EndIf
		$fPortOpen = True
	EndIf
	If $fPortOpen Then
		$vDllAns = DllCall($hDll, 'str', 'ListPorts')
		If @error = 1 Then
			SetError(1)
			Return ''
		Else
			
			;ConsoleWrite($vDllAns[0] & @CRLF)
			If $iReturnType = 1 Then
				Return $vDllAns[0]
			Else
				Return StringSplit($vDllAns[0], '|')
			EndIf
			
			
		EndIf
	Else
		SetError(1)
		Return ''
	EndIf

	
EndFunc   ;==>_CommListPorts



;===============================================================================
;
; Function Name:  _Commgetversion($iType = 1)
; Description:    Gets the version of the dll if $iType = 1
;                   Or the version of this UDF if $iType = 2
; Parameters:     $iType - integer: = 1 to reurn the commg.dll version
;                                  = 2 to return the UDF version
; Returns;  on success - a string eg 'V1.3'
;           on failure - an empty string and @error set to 1

;===============================================================================


Func _CommGetVersion($iType = 1)
	Local $vDllAns
	If $iType = 2 Then Return $sUDFVersion
	
	If $fPortOpen Then
		$vDllAns = DllCall($hDll, 'str', 'Version')
		
		If @error = 1 Then
			SetError(1)
			ConsoleWrite('error in get version' & @CRLF)
			Return ''
		Else
			;ConsoleWrite('length of version is ' & stringlen($vDllAns[0]) & @CRLF)
			Return $vDllAns[0]
			
		EndIf
	Else
		$vDllAns = DllCall('commg.dll', 'str', 'Version')
		If @error = 1 Then
			SetError(1)
			ConsoleWrite('error in get version' & @CRLF)
			Return ''
		Else
			;ConsoleWrite('length of version is ' & stringlen($vDllAns[0]) & @CRLF)
			Return $vDllAns[0]
		EndIf
	EndIf


EndFunc   ;==>_CommGetVersion

;===============================================================================
;
; Function Name:  _CommSwitch($channel)
;switches functions to operate on channel 1, 2, 3 or 4
;if $channel > 4 then switches to 1
;returns  on succes the channel switched to ie 1 or 2
;         on failure -1
;Remarks  on start up of script channel 1 is selected, so if you only need one COM port
;         you don't need to use _CommSwitch
;         each channel needs to be set up with _CommSetPort
;         The same COM port cannot be used on more than one channel.
;         The channel number is not related to the COM port number, so channel 1 can
;         be set to use COM2 and channel 4 can be set to use COM1 or any available port.
;======================================================================================
Func _CommSwitch($channel)
	Local $vDllAns

	$vDllAns = DllCall($hDll, 'int', 'switch', 'int', $channel)
	If @error <> 0 Then
		SetError(1)
		Return -1
	Else
		Return $vDllAns[0]
	EndIf

EndFunc   ;==>_CommSwitch



;===========================================================================================================
;
; Function Name:    _CommSetport($iPort,ByRef $sErr,$iBaud=9600,$iBits=8,$vDllAnsar=0,$iStop=1,$iFlow=0)
;   Description:    Initialises the port and sets the parameters
;    Parameters:    $iPort - integer = the port or COM number to set. Allowed values are 1 or higher.
;                         NB WIndows refers To COM10 Or higher`as \\.\com10 but only use the number 10, 11 etc
;                  $sErr - string: the string to hold an error message if func fails.
;                  $iBaud - integer: the baud rate required. allowed values are one of
;                         50, 75, 110, 150, 600, 1200, 1800, 2000, 2400, 3600, 4800, 7200, 9600, 10400,
;                         14400, 15625, 19200, 28800, 38400, 56000, 57600, 115200, 128000, 256000
;                  $iBits - integer:  number of bits in code to be transmitted
;                  $iParity - integer: 0=None,1=Odd,2=Even,3=Mark,4=Space
;                  $iStop - integer: number of stop bits, 1=1 stop bit 2 = 2 stop bits, 15 = 1.5 stop bits
;                  $iFlow - integer: 0 sets hardware flow control,
;                                    1 sets XON XOFF control,
;                                    2 sets NONE i.e. no flow control.
; Returns;  on success - returns 1 and sets $sErr to ''
;           on failure - returns 0 and with the error message in $sErr, and sets @error as follows
;                           @error             meaning error with
;                             1               dll call failed
;                             2               dll was not open and could not be opened
;                            -1               $iBaud
;                            -2               $iStop
;                            -4               $iBits
;                            -8               $iPort = 0 not allowed
;                           -16               $iPort not found
;                           -32               $iPort access denied (in use?)
;                           -64               unknown error
;Remarks     You cannot set the same COM port on more than one channel
;===========================================================================================================

Func _CommSetPort($iPort, ByRef $sErr, $iBaud = 9600, $iBits = 8, $iPar = 0, $iStop = 1, $iFlow = 0)
	Local $vDllAns
	Local $sMGBuffer = ''
	$sErr = ''
	If Not $fPortOpen Then
		$hDll = DllOpen('commg.dll')
		If $hDll = -1 Then
			SetError(2)
			$sErr = 'Failed to open commg.dll'
			Return 0;failed
		EndIf
		$fPortOpen = True
	EndIf
	ConsoleWrite('port = ' & $iPort & ', baud = ' & $iBaud & ', bits = ' & $iBits & ', par = ' & $iPar & ', stop = ' & $iStop & ', flow = ' & $iFlow & @CRLF)
	
	$vDllAns = DllCall($hDll, 'int', 'SetPort', 'int', $iPort, 'int', $iBaud, 'int', $iBits, 'int', $iPar, 'int', $iStop, 'int', $iFlow)
	If @error <> 0 Then
		$sErr = 'dll SetPort call failed'
		SetError(1)
		Return 0
	EndIf

	If $vDllAns[0] < 0 Then
		SetError($vDllAns[0])
		Switch $vDllAns[0]
			Case - 1
				$sErr = 'undefined baud rate'
			Case - 2
				$sErr = 'undefined stop bit number'
			Case - 4
				$sErr = 'undefined data size'
			Case - 8
				$sErr = 'port 0 not allowed'
			Case - 16
				$sErr = 'port does not exist'
			Case - 32
				$sErr = 'access denied, maybe port already in use'
			Case - 64
				$sErr = 'unknown error accessing port'
		EndSwitch
		Return 0
	Else
		Return 1
	EndIf
	
EndFunc   ;==>_CommSetPort


;===================================================================================
;
; Function Name:  _CommPortConnection()
; Description:    Gets the port connected to the selected channel - see _CommSwitch
; Parameters:     None
; Returns;  on success - a string eg 'COM5'
;           on failure - an empty string and @error set to the rerror set by DllCall
; Remarks - Can be used to verify the port is connected

;====================================================================================

Func _CommPortConnection()
	Local $vDllAns
	$vDllAns = DllCall($hDll, 'str', 'Connection');reply is port eg COM8

	If @error <> 0 Then
		SetError(@error)
		Return ''
	Else
		Return $vDllAns[0]
	EndIf
	
	
EndFunc   ;==>_CommPortConnection



;=====================================================================================
;
; Function Name:  _CommSendString($sMGString,$iWaitComplete=0)
; Description:    Sends a string to the connected port on the currently selected channel
; Parameters:     $sMGString: the string to send sent without any extra CR or LF added.
;                 $iWaitComplete- integer:0 = do not wait till string sent
;                                        1 = wait till sent
; Returns:  always 1
;           on success-  @error set to 0
;           on failure - @error set to the error returned from DllCall
;======================================================================================

Func _CommSendString($sMGString, $iWaitComplete = 0)
	;sends $sMGString on the currently open port
	;returns 1 if ok, returns 0 if port not open/active
	Local $vDllAns
	$vDllAns = DllCall($hDll, 'int', 'SendString', 'str', $sMGString, 'int', $iWaitComplete)
	If @error <> 0 Then
		SetError(@error)
		Return ''
	Else
		Return $vDllAns[0]
	EndIf

EndFunc   ;==>_CommSendString



;================================================================================
;
; Function Name:  _CommGetstring()
; Description:    Get whatever characters are available received by the port for the selected channel
; Parameters:     none
; Returns:  on success the string and @error is 0
;           if input buffer empty then empty string returned
;           on failure an empty string and @error set to the error set by DllCall
; Notes: Use GetLIne to get a whole line treminated by @CR or a defined character.
;=================================================================================

Func _Commgetstring()
	;get a string NB could be part of a line depending on what is in buffer
	Local $vDllAns
	;$sStr1 = ''
	;$vDllAns = DllCall($hDll,'str','GetByte')
	$vDllAns = DllCall($hDll, 'str', 'GetString')
	
	If @error <> 0 Then
		SetError(1)
		ConsoleWrite('error in _commgetstring' & @CRLF)
		Return ''
	EndIf
	Return $vDllAns[0]
EndFunc   ;==>_Commgetstring


;====================================================================================
;
; Function Name:  _CommGetLine($EndChar = @CR,$maxlen = 10000, $maxtime = 10000)
; Description:    Get a string ending in $lineEnd
; Parameters:     $lineEnd the character to indicate the end of the string to return.
;                     The $lineEnd character is included in the return string.
;                 $MaxLen - integer: the maximum length of a string before
;                                     returning even if $linEnd not received
;                                    If $maxlen is 0 then there is no number of characters
;                  $maxtime - integer:the maximum time in mS to wait for the $EndChar before
;                                     returning even if $linEnd not received.
;                                    If $maxtime is 0 then there is no max time to wait
;
; Returns:  on success the string and @error is 0
;           If $maxlen characters received without the $lineEnd character, then these
;            characters are returned and @error is set To -1.
;           If $maxtime passes without receiving the $lineEnd character, then the characters
;            received so far are returned and @error is set To -2.
;           on failure areturns any characters reeived and sets @error to 1
;======================================================================================
Func _CommGetLine($sEndChar = @CR, $maxlen = 0, $maxtime = 0)
	Local $vDllAns, $sLineRet, $sStr1, $waited, $sNextChar, $iSaveErr

	$sStr1 = ''; $sMGBuffer
	$waited = TimerInit()
	
	While 1;stringinstr($sStr1,$EndChar) = 0
		If TimerDiff($waited) > $maxtime And $maxtime > 0 Then
			SetError(-2)
			Return $sStr1
		EndIf
		
		
		If StringLen($sStr1) >= $maxlen And $maxlen > 0 Then
			SetError(-1)
			Return $sStr1
		EndIf
		;$ic =  _CommGetInputCount()
		$sNextChar = _CommReadChar()
		$iSaveErr = @error
		If $iSaveErr = 0 And $sNextChar <> '' Then
			
			$sStr1 = $sStr1 & $sNextChar
			;ConsoleWrite($sStr1 & @CRLF)
			If $sNextChar = $sEndChar Then ExitLoop
			
		EndIf
		
		If $iSaveErr <> 0 Then
			SetError(1)
			Return $sStr1
		EndIf
		
	WEnd



	Return $sStr1
EndFunc   ;==>_CommGetLine





;============================================================================
;
; Function Name:  _CommGetInputCount()
; Description:    Get the number of characters available to be read from the port.
; Parameters:     none
; Returns:  on success a string conversion of the number of characters.(eg '0', '26')
;           on failure returns an empty string and sets @error to 1
;===============================================================================

Func _CommGetInputCount()
	Local $vDllAns
	$vDllAns = DllCall($hDll, 'str', 'GetInputCount')
	
	If @error <> 0 Then
		SetError(1)
		Return 0
	Else
		Return $vDllAns[0]
		
	EndIf

	
EndFunc   ;==>_CommGetInputCount



;============================================================================
;
; Function Name:  _CommGetOutputCount()
; Description:    Get the number of characters waiting to be sent from the port.
; Parameters:     none
; Returns:  on success a string conversion of the number of characters.(eg '0', '26')
;           on failure returns an empty string and sets @error to 1
;===============================================================================
Func _CommGetOutputCount()
	Local $vDllAns

	$vDllAns = DllCall($hDll, 'str', 'GetOutputCount')
	
	If @error <> 0 Then
		SetError(1)
		Return ''
	Else
		Return $vDllAns[0]
	EndIf

	
EndFunc   ;==>_CommGetOutputCount


;================================================================================================
;
; Function Name:   _CommReadByte($wait = 0)

; Description:    Reads the byte as a string
; Parameters:     $wait:integer if 0 then if no data to read then return -1 and set @error to 1
;                               if <> 0 then does not return untill a byte has been read
; Returns:  on success a string conversion of the value of the byte read.(eg '0', '20')
;           on failure returns empty string and sets @error to 1 if no data to read and $wait is 0
;                      Returns empty string and sets @error to 2 ifDllCall failed
;
;;NB could hang if nothing rec'd when wait is <> 0
;==================================================================================================
Func _CommReadByte($wait = 0)
	Local $iCount, $vDllAns
	If Not $wait Then
		$iCount = _CommGetInputCount()
		If $iCount = 0 Then
			SetError(1)
			Return ''
		EndIf
	EndIf
	
	$vDllAns = DllCall($hDll, 'str', 'GetByte')
	
	If @error <> 0 Then
		SetError(2)
		Return ''
	EndIf
	;ConsoleWrite('byte read was ' & $vDllAns[0] & @CRLF)
	Return $vDllAns[0]
	
EndFunc   ;==>_CommReadByte

;============================================================================
;
; Function Name:   _CommReadChar($wait = 0)

; Description:    Reads the next Character as a string
; Parameters:     $wait:integer if 0 then if no data to read then return -1 and set @error to 1
;                               if <> 0 then does not return untill a byte has been read
; Returns:  on success a string of 1 character
;           on failure returns empty string and sets @error to 1
;
;
;;NB could hang if nothing rec'd when wait is <> 0
;===============================================================================

Func _CommReadChar($wait = 0)
	Local $sChar, $iErr

	$sChar = _CommReadByte($wait)
	$iErr = @error
	If $iErr > 2 Then
		SetError(1)
		Return ''
	EndIf
	If $iErr == 0 Then Return Chr(Execute($sChar))
EndFunc   ;==>_CommReadChar


;============================================================================
; Function Name:   SendByte($byte,$iWaitComplete=0)

; Description:    Sends the byte value of $byte. $byte must be in range 0 to 255
; Parameters:     $byte the byte to send.
;                 $iWaitComplete - integer: if 0 then functions returns without
;                                  waiting for byte to be sent
;                                  If <> 0 then waits till byte sent.
; Returns:  on success returns 1
;           on failure returns -1 and sets @error to 1
;
;;NB could hang if byte cannot be sent and $iWaitComplete <> 0
;===============================================================================
Func _CommSendByte($byte, $iWaitComplete = 0)
	Local $vDllAns

	$vDllAns = DllCall($hDll, 'int', 'SendByte', 'int', $byte, 'int', $iWaitComplete)
	If @error <> 0 Then
		SetError(1)
		Return -1
	Else
		Return $vDllAns[0]
	EndIf
	
EndFunc   ;==>_CommSendByte


;===============================================================================
; Function Name:   _CommSendByteArray($pAddr,$iNum,$iWait)

; Description:    Sends the bytes from address $pAddress
; Parameters:     $iNum the number of bytes to send.
;                 $iWaitComplete - integer: if 0 then functions returns without
;                                  waiting for bytes to be sent
;                                 if <> 0 then waits untill all bytes are sent.
; Returns:  on success returns 1
;           on failure returns -1 and sets @error to 1
;
;;NB could hang if byte cannot be sent and $iWaitComplete <> 0
;    could lose data if you send more bytes than the size of the outbuffer.
;    the output buffer size is 2048
;===============================================================================
Func _CommSendByteArray($pAddr, $iNum, $iWait)
	Local $vDllAns = DllCall($hDll, 'int', 'SendByteArray', 'ptr', $pAddr, 'int', $iNum, 'int', $iWait)
	If @error <> 0 Or $vDllAns[0] = -1 Then
		SetError(1)
		Return -1
	Else
		Return $vDllAns[0]
	EndIf
	
EndFunc   ;==>_CommSendByteArray



;====================================================================================
; Function Name:   _CommReadByteArray($pAddr,$iNum,$iWait)
;
; Description:    Reads bytes and writes them to memory starting at address $pAddress
; Parameters:     $iNum the number of bytes to read.
;                 $iWaitComplete - integer: if 0 and then the functions returns
;                                   with the available bytes up to $iNum.
;                                  if 1 then waits untill the $iNum bytes received.
; Returns:  on success returns the Number of bytes read.
;           on failure returns -1 and sets @error to 1
;
;;NB could hang if bytes are not received and $iWaitComplete <> 0
;    the input buffer size is 4096
;====================================================================================
Func _CommReadByteArray($pAddr, $iNum, $iWait)
	Local $vDllAns = DllCall($hDll, 'int', 'ReadByteArray', 'ptr', $pAddr, 'int', $iNum, 'int', $iWait)
	If @error <> 0 Or $vDllAns[0] = -1 Then
		SetError(1)
		Return -1
	Else
		Return $vDllAns[0]
	EndIf
	
	
	
EndFunc   ;==>_CommReadByteArray




;===============================================================================
; Function Name:   ClearOutputBuffer()

; Description:    Clears any characters in the out put queue5
; Parameters:     none
; Returns:  on success returns 1
;           on failure returns -1 and sets @error to 1
;
;===============================================================================
Func _CommClearOutputBuffer()
	
	Local $vDllAns = DllCall($hDll, 'int', 'ClearOutputBuffer')
	
EndFunc   ;==>_CommClearOutputBuffer

Func _CommClearInputBuffer()
	Local $sMGBuffer = ''
	Local $vDllAns = DllCall($hDll, 'int', 'ClearInputBuffer')
	If @error <> 0 Then
		Return -1
	Else
		Return 1
	EndIf
	
EndFunc   ;==>_CommClearInputBuffer


;===============================================================================
; Function Name:   ClosePort()

; Description:    closes the port

; Parameters:     none

; Returns:  no return value
;===============================================================================
Func _CommClosePort()
	;_CommClearOutputBuffer()
	;_CommClearInputBuffer()
	DllCall($hDll, 'int', 'CloseDown')
	DllClose($hDll)
	$fPortOpen = False
EndFunc   ;==>_CommClosePort



;================================================================================================
; Function Name:   SendBreak($iDowTime,$iUpTime)
; NB Simulates the break signal used by some equipment to indicate the start of a sequence
;     Not tested so might Not work. Any feedback welcome - PM martin on Autoit forum

; Description:    sets the TX line low for $iDowTime, then sets it high for $iUpTime

; Parameters:     $iDowTime - integer: the number of ms to hold the TX line down
;                 $iUpTime   - integer: the number of ms to hold the line up for before returning
;                  if $iDowTime or $iUpTime is zero then does nothing and returns
; Returns:  on success returns 1
;           on failure returns 0 and sets @error to
;                                          = 1 if one of params is zero
;                                          = 2 1 unable to use the DLL file,
;                                          = 3 unknown "return type" from dll
;                                          = 4 "function" not found in the DLL file.

; Notes : Not tested!
;================================================================================================
Func _CommSendBreak($iDowTime, $iUpTime);requires commg.dll v2.0 or later
	Local $vDllAns
	If $iDowTime = 0 Or $iUpTime = 0 Then
		SetError(1)
		Return 0
	EndIf
	
	If Not $fPortOpen Then
		SetError(1)
		Return 0
	EndIf
	$vDllAns = DllCall($hDll, 'int', 'SendBreak', 'int', $iDowTime, 'int', $iUpTime)
	If @error <> 0 Then
		SetError(@error + 1)
		Return 0
	Else
		;ConsoleWrite('done setbreak' & @CRLF)
		Return 1;success
	EndIf
	
EndFunc   ;==>_CommSendBreak
