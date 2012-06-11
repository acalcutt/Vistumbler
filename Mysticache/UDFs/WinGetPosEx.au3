; #FUNCTION# =======================================================
; Name...........:  _WinGetPosEx
; Description ...:  Retrieves Window size and position similar to WinGetPos() but regards possible Aero effects on Vista and Win7
; Syntax.........:  _WinGetPosEx($hWnd)
; Parameters ....:  $hWnd - Handle to Window to measure
; Return values .:  Success:    Returns a 4-element array containing the following information:
;                               $array[0] = X position
;                               $array[1] = Y position
;                               $array[2] = Width
;                               $array[3] = Height
;                       Sets @extended  = 0 for Aero effect is OFF for $hWnd
;                                       = 1 for Aero effect is ON for $hWnd
;
;                   Failure:    Returns 0 and sets @error to 1 if windows is not found.
; Author ........: KaFu
; Link ..........; http://msdn.microsoft.com/en-us/library/aa969515%28VS.85%29.aspx
; Example .......; Yes
; ==================================================================
Func _WinGetPosEx($hWnd)
    If Not IsHWnd($hWnd) Then Return SetError(1, 0, 0)
    Local $aPos[4], $tRect = DllStructCreate("int Left;int Top;int Right;int Bottom")
    Local Const $DWMWA_EXTENDED_FRAME_BOUNDS = 9
    DllCall("dwmapi.dll", "hwnd", "DwmGetWindowAttribute", "hwnd", WinGetHandle($hWnd), "dword", $DWMWA_EXTENDED_FRAME_BOUNDS, "ptr", DllStructGetPtr($tRect), "dword", DllStructGetSize($tRect))
    If @error Then Return SetError(0, 0, WinGetPos($hWnd))
    Local $iRectLeft = DllStructGetData($tRect, "Left")
    Local $iRectTop = DllStructGetData($tRect, "Top")
    Local $iRectRight = DllStructGetData($tRect, "Right")
    Local $iRectBottom = DllStructGetData($tRect, "Bottom")
    If Abs($iRectLeft) + Abs($iRectTop) + Abs($iRectRight) + Abs($iRectBottom) > 0 Then
        $aPos[0] = $iRectLeft
        $aPos[1] = $iRectTop
        $aPos[2] = $iRectRight - $iRectLeft
        $aPos[3] = $iRectBottom - $iRectTop
        Return SetError(0, 1, $aPos)
    EndIf
    Return SetError(0, 0, WinGetPos($hWnd))
EndFunc   ;==>_WinGetPosEx
