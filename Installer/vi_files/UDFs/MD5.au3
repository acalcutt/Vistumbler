; -----------------------------------------------------------------------------
; MD5 Hash Machine Code UDF
; Purpose: Provide The Machine Code Version of MD5 Hash Algorithm In AutoIt
; Author: Ward
; url: http://www.autoitscript.com/forum/topic/121985-autoit-machine-code-algorithm-collection/
; -----------------------------------------------------------------------------

#Include-once
#Include <Memory.au3>

Global $_MD5_CodeBuffer, $_MD5_CodeBufferMemory
Global $_MD5_InitOffset, $_MD5_InputOffset, $_MD5_ResultOffset

Global $_HASH_MD5[4] = [16, 88, '_MD5_', '_MD5_']

Func _MD5_Exit()
	$_MD5_CodeBuffer = 0
	_MemVirtualFree($_MD5_CodeBufferMemory, 0, $MEM_RELEASE)
EndFunc

Func _MD5_Startup()
	If Not IsDllStruct($_MD5_CodeBuffer) Then
		If @AutoItX64 Then
			Local $Code = 'BQsAAIkO2+kECRwYhw5XCIPUBK4KD0GcnVYdVZxU/HcAU0iD7ChEiyHHBnoMZwKDWggZEnIECEkTWQMieRBBjbT4eKRqf9c/ifgGaRgx2C5jUV4h8PB8JBT3+PhHAY28OVa3x+j9bP0Q7AQG7t7BKPbBwAfYAfA9IcZ9d0EO94txCMPBxwx0FABEjawe23AgJDmJwzp0sxhQ82M2hCH7YBOKtDPuzjG9wdZcHcOwwxFG8CxjO977MdY+b+sKoIQ4rw98UPWLJNiKvonrxp7GFmo++0Wq7oSAriHzog0AhzcqxocoRwGfKYnzgAox64NGwxHANqwtE0YwUKi9HM2A3/oKjmjufURFDy7jlUb9Nijd6Tw2xRHmuP9We+OhBSBEcQJuXCQMgIwY2JiAVWmGo+t7hD+v94QWK3sgRw4VsVv/NXjb30L3eGzhuCyjcGXduQRDiR6+18+6+s7q74JsUv+mhUcwZSr3QYQiEZBrvzXIkhJ5NGBuiTwkpIkUk3GYunygjjHvdkEPwCHHRQrwCwwB/1A4rvgSRSH4QBI9jkN5ptk9pMVBukE8Avmb+aQy6UmQBtkI0UmbIELawGIlHmX2cs4ogYlm8abpSm/5DcLIi0xC9wSBBVj9D0Bys/iJ/5sy8YlQDc8Mag+8pA4EwScJAUZH7QpRWl4mmRzP1TGHN/fN16qStumNDu4TgA49zM1R+LQgQhi78jBdGxAv1hsyOv75FCw69/tRzyHPQJeMEVOYPWwCHfb4rIHRsO9jQCHvA9MFgeah2GUdLvlRfHTQbJCVihRxaIaBPsj70+ddeQlyAiMImnegBTjmzeFXIX9g/DnWBzdGw6Adhw0j1fTxDA8E7RRaRStRzwt9BAXp46ktCXYCRRiSe6ANOfij71L8g92gBC3ZAm9nOkhlg4pMKrV0i9KKHE16swz+JMjGfYJCOfr/Ac5EA6lFf02gMJo8FDiLRL+GxwTuBgGB9nGHiJJGknJd6A5t0jtT7wtE8YYFCyJhnW2sODTwwPE+DDjl/fTIx9bFiVzpELs+JCIG6r6k/9mDDMa7WmbbF0za321LsCijFG7YyeOpzyLeS9Bb5Y9ghrv2jbB4TQHBSXFUThYJcLy/vggYgYv4MaNQTA2HUonFhbn9CZQQLwYKzVgFiywkEmVR1IA8L4x+myhIzck4xSBrIPonoWbqXvUyJCwvcrQqiGsZCoUw79SyooRJ9X5SBEOoFMcL2YUB72SD2QvOoOkOBR2IUgSSVacxJQiHDGoO6kgUCIUmFx+BNTnQ1NmU5MaQZZr+kDcf5Zkk2+Zrtr0s7UZoGlXGjMD4fCSiH5lPzO5spAQlRCIp9JQFH5aoeokw77CDuqwvlxP/KkNQCWRJFDQQ8UC2MWVWrMSSz8DCOKcjlKvVjQputcb31UJp8TIZ4wxWkyJJ1hsbCc45Kqb0RcbExAb0f8woCeXHSeA2GffQZu0lJYKtOaCT/IWjCkxG5Wzt3bCoxAOkHMNZW2UyIu98bGgAxw/JFAkGgOiuqicAoCuSzAxmj9IVjJAWCQnIicsPL0zTvMTzUKa8F30U9O//b2w640QkCeD7Irzu0RNdhIUVKPw2ENnTEwnriUoQ46qU35J3kg8GPE9+qG/T05Q2quEd+zHrjtmJ1Ggi00nOG0HOgfy0KODmLO6llxR21cgd4zHLwN6NnAcUQ/yjmIuQCmkK+KxwzOZNCVks4E6CoREITkD9AcOr/bHXwd0PULnzCdiQ7KongJcsgn5TUPekrAYuNfI6vd00id7uAZgJzzHfIncBvDO70tcqReQKhwaHhMgJxoCojTQu38k9fHTzJXIMg88cHwVPOZHThgDUwQMC99Hbw76QWggJTNnCAokCi0IEUDf+2Ni1EAiJfkoASIPEKFteX105QVxvCB28p8MYvEmJftVnVArMn8tMCfhmxR1NhcDBi3FQdF/w5j8DTI15QEG+nwwC6wANSQFcJFBIhR7/dEalo+T1KZdH6/A5+3YE9v372/vxM4rYhuq23ONgHEgGKd/osAJqBoP+QHXILGf6'
				$Code &= 'BuGRMPboMAH/41hGdVK6krPrhPRKSBiJ11YIzlPKaMOOjiBJgfh/dn5BkUFQ9OA/IHVHDGZAMe1A+cw+4szp30Q/m+h2r+WDOysGGvg/d+RENEPAOhvDXrtBYmcyVAeHhSbxAV5QkeMghcO9IdMpxUO06DMy75Drue7+u4gzorDx1cZ+NI0uoQtD6cZEUZcY6MejkXCHuFIHJAEjRWfrobCJq82blosgAxkI/ty6mAMRDHZUMhAbqkFAMG8rE5mXGEnYpRKGrCAKmCZmKArLBpB9aTAKAV44v4Cgq79/ZNpnxIFmwdP/mQrGIs1E8kTN99nkkNH10AEJwB74OEKIDBgDdnJIQbikz4H5Y6hqf5jUDSnAMdKaQYI/AUNL4j0W2ZRT9rdzDMMBujhRDzOFpQ1A+ccCkRSpiAQRsACJ0THAwekDKPbCzAzJ80irKq2LZBxRs0CD4gF0HybGBwoUGnIhOFDo0NAltQVDUIn2JXVMk8YOQw046Nb1+p4wQNxFMgxEBAQISBAIIExqDGIHT5CepARP8T9M0v9RKfTDxmADpI17AbIbN+lNhpBmxweohuoC0Da7GulGIwgQEhEEdCHpPmgPlUQykS8iP0hT7yTRbaxrKSAkW4nodBLNCqnfY+kmJhtWfpnPBtZAmsH88wqkX17DEETQMqpjogAA'
		Else
			Local $Code = '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'
				$Code &= 'ZBPqLlhhAXKhu3rrIeAslL+/gYnaKcdM6vk9AfsO/ujjeIrrop75zSqUbATChLIBBuu8cZhL0GA8Gum7UQasEEsHFI1QQMcuYQEjRWe9Du6lH5hCaqvNYO8OCP7cukCYDA12VDIQONYTeoiRcy4CCkS/1ETT5b5DccOydMbcSVBAQf2/jqjNkAr32SHRwJ4JR4gMA4LAAYDYOHZmupFyh8KNe4rqFQOeJAiZvMJCpiJQ8PqSEVR8ut/+e1H2o8zDATC6OD8PhZ7CDffHAqQMn0mJgNjAwekCOfbCmfOrJJ0VAC8BdCrGB6HpJaFmZiFjUe2EEY1DQIiUiyV7UAd90nBrVA+kDv0Dwed2CzsRgtRTPERq7kNQOIfoKPr1gf2ZWwYKRPxGBMgMSBAIIExJDNxkUnSiIFLLJkgDhsPGA7YDewGyN+lVcm4VZscHkhzqAuizK+lRELIbViFTMckgRBjZ+YwgbIGQmmLfpf7RCxggmBhbMelgG1ZXp78kgxCltCHm5C/8BIP5CHInggcBKQKWpElMEfQFEmalgwQLicqTEPPUhxnD4QO5pOu6FgZfXsNXd0QQMDEPttIMaSGHswOtCCF0AwUKqkkhCnX2Uj/8Qk0QQKpfYMMA'
		EndIf
		Local $Opcode = String(_MD5_CodeDecompress($Code))
		$_MD5_InitOffset = (StringInStr($Opcode, "89DB") - 3) / 2
		$_MD5_InputOffset = (StringInStr($Opcode, "87DB") - 3) / 2
		$_MD5_ResultOffset = (StringInStr($Opcode, "09DB") - 3) / 2
		$Opcode = Binary($Opcode)

		$_MD5_CodeBufferMemory = _MemVirtualAlloc(0, BinaryLen($Opcode), $MEM_COMMIT, $PAGE_EXECUTE_READWRITE)
		$_MD5_CodeBuffer = DllStructCreate("byte[" & BinaryLen($Opcode) & "]", $_MD5_CodeBufferMemory)
		DllStructSetData($_MD5_CodeBuffer, 1, $Opcode)
		OnAutoItExitRegister("_MD5_Exit")
	EndIf
EndFunc

Func _MD5Init()
	If Not IsDllStruct($_MD5_CodeBuffer) Then _MD5_Startup()

	Local $Context = DllStructCreate("byte[" & $_HASH_MD5[1] & "]")
	DllCall("user32.dll", "none", "CallWindowProc", "ptr", DllStructGetPtr($_MD5_CodeBuffer) + $_MD5_InitOffset, _
													"ptr", DllStructGetPtr($Context), _
													"int", 0, _
													"int", 0, _
													"int", 0)

	Return $Context
EndFunc

Func _MD5Input(ByRef $Context, $Data)
	If Not IsDllStruct($_MD5_CodeBuffer) Then _MD5_Startup()
	If Not IsDllStruct($Context) Then Return SetError(1, 0, 0)

	$Data = Binary($Data)
	Local $InputLen = BinaryLen($Data)
	Local $Input = DllStructCreate("byte[" & $InputLen & "]")
	DllStructSetData($Input, 1, $Data)
	DllCall("user32.dll", "none", "CallWindowProc", "ptr", DllStructGetPtr($_MD5_CodeBuffer) + $_MD5_InputOffset, _
													"ptr", DllStructGetPtr($Context), _
													"ptr", DllStructGetPtr($Input), _
													"uint", $InputLen, _
													"int", 0)
EndFunc

Func _MD5Result(ByRef $Context)
	If Not IsDllStruct($_MD5_CodeBuffer) Then _MD5_Startup()
	If Not IsDllStruct($Context) Then Return SetError(1, 0, "")

	Local $Digest = DllStructCreate("byte[" & $_HASH_MD5[0] & "]")
	DllCall("user32.dll", "none", "CallWindowProc", "ptr", DllStructGetPtr($_MD5_CodeBuffer) + $_MD5_ResultOffset, _
													"ptr", DllStructGetPtr($Context), _
													"ptr", DllStructGetPtr($Digest), _
													"int", 0, _
													"int", 0)
	Return DllStructGetData($Digest, 1)
EndFunc

Func _MD5($Data)
	Local $Context = _MD5Init()
	_MD5Input($Context, $Data)
	Return _MD5Result($Context)
EndFunc

Func _MD5_CodeDecompress($Code)
	If @AutoItX64 Then
		Local $Opcode = '0x89C04150535657524889CE4889D7FCB28031DBA4B302E87500000073F631C9E86C000000731D31C0E8630000007324B302FFC1B010E85600000010C073F77544AAEBD3E85600000029D97510E84B000000EB2CACD1E8745711C9EB1D91FFC8C1E008ACE8340000003D007D0000730A80FC05730783F87F7704FFC1FFC141904489C0B301564889FE4829C6F3A45EEB8600D275078A1648FFC610D2C331C9FFC1E8EBFFFFFF11C9E8E4FFFFFF72F2C35A4829D7975F5E5B4158C389D24883EC08C70100000000C64104004883C408C389F64156415541544D89CC555756534C89C34883EC20410FB64104418800418B3183FE010F84AB00000073434863D24D89C54889CE488D3C114839FE0F84A50100000FB62E4883C601E8C601000083ED2B4080FD5077E2480FBEED0FB6042884C00FBED078D3C1E20241885500EB7383FE020F841C01000031C083FE03740F4883C4205B5E5F5D415C415D415EC34863D24D89C54889CE488D3C114839FE0F84CA0000000FB62E4883C601E86401000083ED2B4080FD5077E2480FBEED0FB6042884C078D683E03F410845004983C501E964FFFFFF4863D24D89C54889CE488D3C114839FE0F84E00000000FB62E4883C601E81D01000083ED2B4080FD5077E2480FBEED0FB6042884C00FBED078D389D04D8D7501C1E20483E03041885501C1F804410845004839FE747B0FB62E4883C601E8DD00000083ED2B4080FD5077E6480FBEED0FB6042884C00FBED078D789D0C1E2064D8D6E0183E03C41885601C1F8024108064839FE0F8536FFFFFF41C7042403000000410FB6450041884424044489E84883C42029D85B5E5F5D415C415D415EC34863D24889CE4D89C6488D3C114839FE758541C7042402000000410FB60641884424044489F04883C42029D85B5E5F5D415C415D415EC341C7042401000000410FB6450041884424044489E829D8E998FEFFFF41C7042400000000410FB6450041884424044489E829D8E97CFEFFFF56574889CF4889D64C89C1FCF3A45F5EC3E8500000003EFFFFFF3F3435363738393A3B3C3DFFFFFFFEFFFFFF000102030405060708090A0B0C0D0E0F10111213141516171819FFFFFFFFFFFF1A1B1C1D1E1F202122232425262728292A2B2C2D2E2F3031323358C3'
	Else
		Local $Opcode = '0x89C0608B7424248B7C2428FCB28031DBA4B302E86D00000073F631C9E864000000731C31C0E85B0000007323B30241B010E84F00000010C073F7753FAAEBD4E84D00000029D97510E842000000EB28ACD1E8744D11C9EB1C9148C1E008ACE82C0000003D007D0000730A80FC05730683F87F770241419589E8B3015689FE29C6F3A45EEB8E00D275058A164610D2C331C941E8EEFFFFFF11C9E8E7FFFFFF72F2C32B7C2428897C241C61C389D28B442404C70000000000C6400400C2100089F65557565383EC1C8B6C243C8B5424388B5C24308B7424340FB6450488028B550083FA010F84A1000000733F8B5424388D34338954240C39F30F848B0100000FB63B83C301E8CD0100008D57D580FA5077E50FBED20FB6041084C00FBED078D78B44240CC1E2028810EB6B83FA020F841201000031C083FA03740A83C41C5B5E5F5DC210008B4C24388D3433894C240C39F30F84CD0000000FB63B83C301E8740100008D57D580FA5077E50FBED20FB6041084C078DA8B54240C83E03F080283C2018954240CE96CFFFFFF8B4424388D34338944240C39F30F84D00000000FB63B83C301E82E0100008D57D580FA5077E50FBED20FB6141084D20FBEC278D78B4C240C89C283E230C1FA04C1E004081189CF83C70188410139F374750FB60383C3018844240CE8EC0000000FB654240C83EA2B80FA5077E00FBED20FB6141084D20FBEC278D289C283E23CC1FA02C1E006081739F38D57018954240C8847010F8533FFFFFFC74500030000008B4C240C0FB60188450489C82B44243883C41C5B5E5F5DC210008D34338B7C243839F3758BC74500020000000FB60788450489F82B44243883C41C5B5E5F5DC210008B54240CC74500010000000FB60288450489D02B442438E9B1FEFFFFC7450000000000EB9956578B7C240C8B7424108B4C241485C9742FFC83F9087227F7C7010000007402A449F7C702000000740566A583E90289CAC1E902F3A589D183E103F3A4EB02F3A45F5EC3E8500000003EFFFFFF3F3435363738393A3B3C3DFFFFFFFEFFFFFF000102030405060708090A0B0C0D0E0F10111213141516171819FFFFFFFFFFFF1A1B1C1D1E1F202122232425262728292A2B2C2D2E2F3031323358C3'
	EndIf
	Local $AP_Decompress = (StringInStr($Opcode, "89C0") - 3) / 2
	Local $B64D_Init = (StringInStr($Opcode, "89D2") - 3) / 2
	Local $B64D_DecodeData = (StringInStr($Opcode, "89F6") - 3) / 2
	$Opcode = Binary($Opcode)

	Local $CodeBufferMemory = _MemVirtualAlloc(0, BinaryLen($Opcode), $MEM_COMMIT, $PAGE_EXECUTE_READWRITE)
	Local $CodeBuffer = DllStructCreate("byte[" & BinaryLen($Opcode) & "]", $CodeBufferMemory)
	DllStructSetData($CodeBuffer, 1, $Opcode)

	Local $B64D_State = DllStructCreate("byte[16]")
	Local $Length = StringLen($Code)
	Local $Output = DllStructCreate("byte[" & $Length & "]")

	DllCall("user32.dll", "none", "CallWindowProc", "ptr", DllStructGetPtr($CodeBuffer) + $B64D_Init, _
													"ptr", DllStructGetPtr($B64D_State), _
													"int", 0, _
													"int", 0, _
													"int", 0)

	DllCall("user32.dll", "int", "CallWindowProc", "ptr", DllStructGetPtr($CodeBuffer) + $B64D_DecodeData, _
													"str", $Code, _
													"uint", $Length, _
													"ptr", DllStructGetPtr($Output), _
													"ptr", DllStructGetPtr($B64D_State))

	Local $ResultLen = DllStructGetData(DllStructCreate("uint", DllStructGetPtr($Output)), 1)
	Local $Result = DllStructCreate("byte[" & ($ResultLen + 16) & "]")

	Local $Ret = DllCall("user32.dll", "uint", "CallWindowProc", "ptr", DllStructGetPtr($CodeBuffer) + $AP_Decompress, _
													"ptr", DllStructGetPtr($Output) + 4, _
													"ptr", DllStructGetPtr($Result), _
													"int", 0, _
													"int", 0)


	_MemVirtualFree($CodeBufferMemory, 0, $MEM_RELEASE)
	Return BinaryMid(DllStructGetData($Result, 1), 1, $Ret[0])
EndFunc

; #FUNCTION# ;===============================================================================
; Name...........: _MD5ForFile
; Description ...: Calculates MD5 value for the specific file.
; Syntax.........: _MD5ForFile ($sFile)
; Parameters ....: $sFile - Full path to the file to process.
; Return values .: Success - Returns MD5 value in form of hex string
;                          - Sets @error to 0
;                  Failure - Returns empty string and sets @error:
;                  |1 - CreateFile function or call to it failed.
;                  |2 - CreateFileMapping function or call to it failed.
;                  |3 - MapViewOfFile function or call to it failed.
;                  |4 - MD5Init function or call to it failed.
;                  |5 - MD5Update function or call to it failed.
;                  |6 - MD5Final function or call to it failed.
; Author ........: trancexx
; url ...........: http://www.autoitscript.com/forum/topic/95558-crc32-md4-md5-sha1-for-files/
;==========================================================================================
Func _MD5ForFile($sFile)
    Local $a_hCall = DllCall("kernel32.dll", "hwnd", "CreateFileW", _
            "wstr", $sFile, _
            "dword", 0x80000000, _ ; GENERIC_READ
            "dword", 1, _ ; FILE_SHARE_READ
            "ptr", 0, _
            "dword", 3, _ ; OPEN_EXISTING
            "dword", 0, _ ; SECURITY_ANONYMOUS
            "ptr", 0)

    If @error Or $a_hCall[0] = -1 Then
        Return SetError(1, 0, "")
    EndIf

    Local $hFile = $a_hCall[0]

    $a_hCall = DllCall("kernel32.dll", "ptr", "CreateFileMappingW", _
            "hwnd", $hFile, _
            "dword", 0, _ ; default security descriptor
            "dword", 2, _ ; PAGE_READONLY
            "dword", 0, _
            "dword", 0, _
            "ptr", 0)

    If @error Or Not $a_hCall[0] Then
        DllCall("kernel32.dll", "int", "CloseHandle", "hwnd", $hFile)
        Return SetError(2, 0, "")
    EndIf

    DllCall("kernel32.dll", "int", "CloseHandle", "hwnd", $hFile)

    Local $hFileMappingObject = $a_hCall[0]

    $a_hCall = DllCall("kernel32.dll", "ptr", "MapViewOfFile", _
            "hwnd", $hFileMappingObject, _
            "dword", 4, _ ; FILE_MAP_READ
            "dword", 0, _
            "dword", 0, _
            "dword", 0)

    If @error Or Not $a_hCall[0] Then
        DllCall("kernel32.dll", "int", "CloseHandle", "hwnd", $hFileMappingObject)
        Return SetError(3, 0, "")
    EndIf

    Local $pFile = $a_hCall[0]
    Local $iBufferSize = FileGetSize($sFile)

    Local $tMD5_CTX = DllStructCreate("dword i[2];" & _
            "dword buf[4];" & _
            "ubyte in[64];" & _
            "ubyte digest[16]")

    DllCall("advapi32.dll", "none", "MD5Init", "ptr", DllStructGetPtr($tMD5_CTX))

    If @error Then
        DllCall("kernel32.dll", "int", "UnmapViewOfFile", "ptr", $pFile)
        DllCall("kernel32.dll", "int", "CloseHandle", "hwnd", $hFileMappingObject)
        Return SetError(4, 0, "")
    EndIf

    DllCall("advapi32.dll", "none", "MD5Update", _
            "ptr", DllStructGetPtr($tMD5_CTX), _
            "ptr", $pFile, _
            "dword", $iBufferSize)

    If @error Then
        DllCall("kernel32.dll", "int", "UnmapViewOfFile", "ptr", $pFile)
        DllCall("kernel32.dll", "int", "CloseHandle", "hwnd", $hFileMappingObject)
        Return SetError(5, 0, "")
    EndIf

    DllCall("advapi32.dll", "none", "MD5Final", "ptr", DllStructGetPtr($tMD5_CTX))

    If @error Then
        DllCall("kernel32.dll", "int", "UnmapViewOfFile", "ptr", $pFile)
        DllCall("kernel32.dll", "int", "CloseHandle", "hwnd", $hFileMappingObject)
        Return SetError(6, 0, "")
    EndIf

    DllCall("kernel32.dll", "int", "UnmapViewOfFile", "ptr", $pFile)
    DllCall("kernel32.dll", "int", "CloseHandle", "hwnd", $hFileMappingObject)

    Local $sMD5 = Hex(DllStructGetData($tMD5_CTX, "digest"))

    Return SetError(0, 0, $sMD5)

EndFunc   ;==>_MD5ForFile

