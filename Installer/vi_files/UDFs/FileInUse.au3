;===============================================================================
; Function Name:    _FileInUse()
; Description:      Checks if file is in use
; Parameter(s):     $sFilename = File name
; Return Value(s):  1 - file in use (@error contains system error code)
;                   0 - file not in use
; Author:		 	Siao (http://www.autoitscript.com/forum/index.php?showtopic=53994&view=findpost&p=410020)
;===============================================================================
Func _FileInUse($sFilename)
    Local $aRet, $hFile
    $aRet = DllCall("Kernel32.dll", "hwnd", "CreateFile", _
                                    "str", $sFilename, _ ;lpFileName
                                    "dword", 0x80000000, _ ;dwDesiredAccess = GENERIC_READ
                                    "dword", 0, _ ;dwShareMode = DO NOT SHARE
                                    "dword", 0, _ ;lpSecurityAttributes = NULL
                                    "dword", 3, _ ;dwCreationDisposition = OPEN_EXISTING
                                    "dword", 128, _ ;dwFlagsAndAttributes = FILE_ATTRIBUTE_NORMAL
                                    "hwnd", 0) ;hTemplateFile = NULL
    $hFile = $aRet[0]
    If $hFile = -1 Then ;INVALID_HANDLE_VALUE = -1
        $aRet = DllCall("Kernel32.dll", "int", "GetLastError")
        SetError($aRet[0])
        Return 1
    Else
        ;close file handle
        DllCall("Kernel32.dll", "int", "CloseHandle", "hwnd", $hFile)
        Return 0
    EndIf
EndFunc
