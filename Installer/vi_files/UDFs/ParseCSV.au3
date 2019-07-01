; #FUNCTION# ====================================================================================================================
; Name...........: _ParseCSV
; Description ...: Reads a CSV-file
; Syntax.........: _ParseCSV($sFile, $sDelimiters=',', $sQuote='"', $iFormat=0)
; Parameters ....: $sFile       - File to read or string to parse
;                  $sDelimiters - [optional] Fieldseparators of CSV, mulitple are allowed (default: ,;)
;                  $sQuote      - [optional] Character to quote strings (default: ")
;                  $iFormat     - [optional] Encoding of the file (default: 0):
;                  |-1     - No file, plain data given
;                  |0 or 1 - automatic (ASCII)
;                  |2      - Unicode UTF16 Little Endian reading
;                  |3      - Unicode UTF16 Big Endian reading
;                  |4 or 5 - Unicode UTF8 reading
;                  $iAddIndex     - [optional] Adds an index in first column
;                  $AddHeader     - [optional] Adds an automatic header ("Col1", "Col2", ....)
; Return values .: Success - 2D-Array with CSV data (0-based)
;                  Failure - 0, sets @error to:
;                  |1 - could not open file
;                  |2 - error on parsing data
;                  |3 - wrong format chosen
; Author ........: ProgAndy
; Modified.......: funkey (to fit the function to the CSV-Editor)
; Remarks .......:
; Related .......: _WriteCSV
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _ParseCSV($sFile, $sDelimiters = ',;', $sQuote = '"', $iFormat = 0, $iAddIndex = 0, $AddHeader = 0)
    Local Static $aEncoding[6] = [0, 0, 32, 64, 128, 256]
    If $iFormat < -1 Or $iFormat > 6 Then
        Return SetError(3, 0, 0)
    ElseIf $iFormat > -1 Then
        Local $hFile = FileOpen($sFile, $aEncoding[$iFormat]), $sLine, $aTemp, $aCSV[1], $iReserved, $iCount
        If @error Then Return SetError(1, @error, 0)
        $sFile = FileRead($hFile)
        FileClose($hFile)
    EndIf
    If $sDelimiters = "" Or IsKeyword($sDelimiters) Then $sDelimiters = ',;'
    If $sQuote = "" Or IsKeyword($sQuote) Then $sQuote = '"'
    $sQuote = StringLeft($sQuote, 1)
    $iAddIndex = Number($iAddIndex=True)
    $AddHeader = Number($AddHeader=True)
    Local $srDelimiters = StringRegExpReplace($sDelimiters, '[\\\^\-\[\]]', '\\\0')
    Local $srQuote = StringRegExpReplace($sQuote, '[\\\^\-\[\]]', '\\\0')
    Local $sPattern = StringReplace(StringReplace('(?m)(?:^|[,])\h*(["](?:[^"]|["]{2})*["]|[^,\r\n]*)(\v+)?', ',', $srDelimiters, 0, 1), '"', $srQuote, 0, 1)
    Local $aREgex = StringRegExp($sFile, $sPattern, 3)
    If @error Then Return SetError(2, @error, 0)
    $sFile = '' ; save memory
    Local $iBound = UBound($aREgex), $iIndex = $AddHeader, $iSubBound = 1+$iAddIndex, $iSub = $iAddIndex, $sLast='' ;changed
    If $iBound Then $sLast = $aREgex[$iBound-1]
    Local $aResult[$iBound + $iAddIndex][$iSubBound] ;changed
    For $i = 0 To $iBound - 1
        If $iSub = $iSubBound Then
            $iSubBound += 1
            ReDim $aResult[$iBound][$iSubBound]
        EndIf
        Select
            Case StringLeft(StringStripWS($aREgex[$i], 1), 1) = $sQuote
                $aREgex[$i] = StringStripWS($aREgex[$i], 3)
                $aResult[$iIndex][$iSub] = $aREgex[$i]
;~                 $aResult[$iIndex][$iSub] = StringReplace(StringMid($aREgex[$i], 2, StringLen($aREgex[$i])-2), $sQuote&$sQuote, $sQuote, 0, 1)
            Case StringRegExp($aREgex[$i], '^\v+$') ; StringLen($aREgex[$i]) < 3 And StringInStr(@CRLF, $aREgex[$i]) ;new line found
                StringReplace($aREgex[$i], @LF, "", 0, 1)
                $iIndex += @extended
                $iSub = $iAddIndex ;changed
                ContinueLoop
            Case Else
                $aResult[$iIndex][$iSub] = $aREgex[$i]
        EndSelect
        $aREgex[$i] = 0 ; save memory
        $iSub += 1
        If $iAddIndex Then $aResult[$iIndex][0] = $iIndex ;added
    Next
    If Not StringRegExp($sLast, '^\v+$') Then $iIndex+=1
    ReDim $aResult[$iIndex][$iSubBound - 1]
    If $iAddIndex Then $aResult[0][0] = "Index" ;added
    If $AddHeader Then
        For $i = 1 To $iSubBound - 2
            $aResult[0][$i] = "Col" & $i
        Next
    EndIf
    Return $aResult
EndFunc   ;==>_ParseCSV