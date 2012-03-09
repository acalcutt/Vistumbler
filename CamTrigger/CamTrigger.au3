;License Information------------------------------------
;Copyright (C) 2012 Andrew Calcutt
;This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; Version 2 of the License.
;This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
;You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
;--------------------------------------------------------
;AutoIt Version: v3.3.6.1
$Script_Author = 'Andrew Calcutt'
$Script_Name = 'CamTrigger'
$Script_Website = 'http://www.Vistumbler.net'
$Script_Function = 'Trigger cameras using Hivitronix HR0805U4X2 USB Relay board'
$version = 'v0.1'
$last_modified = '2012/03/03'
;--------------------------------------------------------
Global $FTD2XX_Dll = DllOpen(@ScriptDir & "\FTD2XX.dll") ;open ftdi dll
Global $FTD2XX_Dll_ptr = DllStructCreate ("dword") ;Create structure to hold pointer returned from DLL
Global $lpBuffer = DllStructCreate('BYTE[128]') ; buffer that receives the data from the device. or to hold data to write to device
Global $lpdwBytesWritten = DllStructCreate('DWORD') ; variable of type DWORD which receives the number of bytes written to the device.


$ft_open_result = _FT_Open(0, $FTD2XX_Dll_ptr);Open first ftdi device
ConsoleWrite($ft_open_result & @CRLF)
If $ft_open_result = 0 Then
	$FT_HANDLE = DllStructGetData($FTD2XX_Dll_ptr, 1) ;Store pointer (FT_HANDLE) here
	$Do = _FT_SetBitMode($FT_HANDLE, 255, 1) ;Asynchronous Bit Bang, all channels to output

	;For $x = 1 to 10
		;_LoopLights()
		_CamTrigger()
		;Sleep(5000)
	;Next

EndIf

;---------------------------------------------------------
;CamTrigger Functions
;---------------------------------------------------------

Func _CamTrigger()
		DllStructSetData($lpBuffer, 1, 255) ;Set all channels to high
		$Do = _FT_Write($FT_HANDLE, $lpBuffer, 1, $lpdwBytesWritten) ;8 channels = 8-bit is 1 byte only
		Sleep(500)

		DllStructSetData($lpBuffer, 1, 0) ;Set all channels to low
		$Do = _FT_Write($FT_HANDLE, $lpBuffer, 1, $lpdwBytesWritten) ;8 channels = 8-bit is 1 byte only
EndFunc

Func _LoopLights()

		DllStructSetData($lpBuffer, 1, 1) ;Set first relay to high
		$Do = _FT_Write($FT_HANDLE, $lpBuffer, 1, $lpdwBytesWritten) ;8 channels = 8-bit is 1 byte only
		Sleep(50)

		DllStructSetData($lpBuffer, 1, 2) ;Set second relay to high
		$Do = _FT_Write($FT_HANDLE, $lpBuffer, 1, $lpdwBytesWritten) ;8 channels = 8-bit is 1 byte only
		Sleep(50)

		DllStructSetData($lpBuffer, 1, 4) ;Set third relay to high
		$Do = _FT_Write($FT_HANDLE, $lpBuffer, 1, $lpdwBytesWritten) ;8 channels = 8-bit is 1 byte only
		Sleep(50)

		DllStructSetData($lpBuffer, 1, 8) ;Set forth relay to high
		$Do = _FT_Write($FT_HANDLE, $lpBuffer, 1, $lpdwBytesWritten) ;8 channels = 8-bit is 1 byte only
		Sleep(50)

		DllStructSetData($lpBuffer, 1, 16) ;Set firth relay to high
		$Do = _FT_Write($FT_HANDLE, $lpBuffer, 1, $lpdwBytesWritten) ;8 channels = 8-bit is 1 byte only
		Sleep(50)

		DllStructSetData($lpBuffer, 1, 32) ;Set sixth relay to high
		$Do = _FT_Write($FT_HANDLE, $lpBuffer, 1, $lpdwBytesWritten) ;8 channels = 8-bit is 1 byte only
		Sleep(50)

		DllStructSetData($lpBuffer, 1, 64) ;Set seventh relay to high
		$Do = _FT_Write($FT_HANDLE, $lpBuffer, 1, $lpdwBytesWritten) ;8 channels = 8-bit is 1 byte only
		Sleep(50)

		DllStructSetData($lpBuffer, 1, 128);Set eighth relay to high
		$Do = _FT_Write($FT_HANDLE, $lpBuffer, 1, $lpdwBytesWritten) ;8 channels = 8-bit is 1 byte only
		Sleep(50)

		DllStructSetData($lpBuffer, 1, 0) ;Set all channels to low
		$Do = _FT_Write($FT_HANDLE, $lpBuffer, 1, $lpdwBytesWritten) ;8 channels = 8-bit is 1 byte only
EndFunc


;---------------------------------------------------------
;FTDI Functions
;---------------------------------------------------------

Func _FT_Open($iDevice, $fthandle)
	$v_Result = DllCall($FTD2XX_Dll, 'long', 'FT_Open', 'int', $iDevice, 'ptr', DllStructGetPtr($fthandle))
	$FT_HANDLE = DllStructGetData($fthandle, 1)
	Return $v_Result[0]
EndFunc   ;==>_FT_Open

Func _FT_Write($FT_HANDLE, $lpBuffer, $dwBytesToWrite, $lpdwBytesWritten)
	$v_Result = DllCall($FTD2XX_Dll, 'long', 'FT_Write', 'ptr', $FT_HANDLE, 'ptr', DllStructGetPtr($lpBuffer), 'DWORD', $dwBytesToWrite, 'ptr', DllStructGetPtr($lpdwBytesWritten))
	Return $v_Result[0]
EndFunc   ;==>_FT_Write

Func _FT_SetBitMode($FT_HANDLE, $uMask, $uMode)
 $v_Result = DllCall($FTD2XX_Dll, 'long', 'FT_SetBitMode', 'ptr', $FT_HANDLE, 'byte', $uMask, 'byte', $uMode)
 Return $v_Result[0]
EndFunc

Func _USBFT_ErrorDescription($i_Error)
	Local $i_ErrorCode[21]
	$i_ErrorCode[0] = 'FT_OK'
	$i_ErrorCode[1] = 'FT_INVALID_HANDLE'
	$i_ErrorCode[2] = 'FT_DEVICE_NOT_FOUND'
	$i_ErrorCode[3] = 'FT_DEVICE_NOT_OPENED'
	$i_ErrorCode[4] = 'FT_IO_ERROR'
	$i_ErrorCode[5] = 'FT_INSUFFICIENT_RESOURCES'
	$i_ErrorCode[6] = 'FT_INVALID_PARAMETER'
	$i_ErrorCode[7] = 'FT_INVALID_BAUD_RATE'
	$i_ErrorCode[8] = 'FT_DEVICE_NOT_OPENED_FOR_ERASE'
	$i_ErrorCode[9] = 'FT_DEVICE_NOT_OPENED_FOR_WRITE'
	$i_ErrorCode[10] = 'FT_FAILED_TO_WRITE_DEVICE'
	$i_ErrorCode[11] = 'FT_EEPROM_READ_FAILED'
	$i_ErrorCode[12] = 'FT_EEPROM_WRITE_FAILED'
	$i_ErrorCode[13] = 'FT_EEPROM_ERASE_FAILED'
	$i_ErrorCode[14] = 'FT_EEPROM_NOT_PRESENT'
	$i_ErrorCode[15] = 'FT_EEPROM_NOT_PROGRAMMED'
	$i_ErrorCode[16] = 'FT_INVALID_ARGS'
	$i_ErrorCode[17] = 'FT_NOT_SUPPORTED'
	$i_ErrorCode[18] = 'FT_OTHER_ERROR'
	$i_ErrorCode[19] = 'FT_DEVICE_LIST_NOT_READY'
	If $i_Error > 19 Then Return 'Unknown Error #' & $i_Error
	Return $i_ErrorCode[$i_Error]
EndFunc   ;==>_USBFT_ErrorDescription