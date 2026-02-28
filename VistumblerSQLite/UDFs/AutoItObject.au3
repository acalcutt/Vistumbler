; #INDEX# =======================================================================================================================
; Title .........: AutoItObject v1.2.8.2
; AutoIt Version : 3.3
; Language ......: English (language independent)
; Description ...: Brings Objects to AutoIt.
; Author(s) .....: monoceres, trancexx, Kip, Prog@ndy
; Copyright .....: Copyright (C) The AutoItObject-Team. All rights reserved.
; License .......: Artistic License 2.0, see Artistic.txt
;
; This file is part of AutoItObject.
;
; AutoItObject is free software; you can redistribute it and/or modify
; it under the terms of the Artistic License as published by Larry Wall,
; either version 2.0, or (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
; See the Artistic License for more details.
;
; You should have received a copy of the Artistic License with this Kit,
; in the file named "Artistic.txt".  If not, you can get a copy from
; <http://www.perlfoundation.org/artistic_license_2_0> OR
; <http://www.opensource.org/licenses/artistic-license-2.0.php>
;
; ------------------------ AutoItObject CREDITS: ------------------------
; Copyright (C) by:
; The AutoItObject-Team:
; 	Andreas Karlsson (monoceres)
; 	Dragana R. (trancexx)
; 	Dave Bakker (Kip)
; 	Andreas Bosch (progandy, Prog@ndy)
;
; ===============================================================================================================================
#include-once
#AutoIt3Wrapper_Au3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6


; #CURRENT# =====================================================================================================================
;_AutoItObject_AddDestructor
;_AutoItObject_AddEnum
;_AutoItObject_AddMethod
;_AutoItObject_AddProperty
;_AutoItObject_Class
;_AutoItObject_CLSIDFromString
;_AutoItObject_CoCreateInstance
;_AutoItObject_Create
;_AutoItObject_DllOpen
;_AutoItObject_DllStructCreate
;_AutoItObject_IDispatchToPtr
;_AutoItObject_IUnknownAddRef
;_AutoItObject_IUnknownRelease
;_AutoItObject_ObjCreate
;_AutoItObject_ObjCreateEx
;_AutoItObject_ObjectFromDtag
;_AutoItObject_PtrToIDispatch
;_AutoItObject_RegisterObject
;_AutoItObject_RemoveMember
;_AutoItObject_Shutdown
;_AutoItObject_Startup
;_AutoItObject_UnregisterObject
;_AutoItObject_VariantClear
;_AutoItObject_VariantCopy
;_AutoItObject_VariantFree
;_AutoItObject_VariantInit
;_AutoItObject_VariantRead
;_AutoItObject_VariantSet
;_AutoItObject_WrapperAddMethod
;_AutoItObject_WrapperCreate
; ===============================================================================================================================

; #INTERNAL_NO_DOC# =============================================================================================================
;__Au3Obj_OleUninitialize
;__Au3Obj_IUnknown_AddRef
;__Au3Obj_IUnknown_Release
;__Au3Obj_GetMethods
;__Au3Obj_SafeArrayCreate
;__Au3Obj_SafeArrayDestroy
;__Au3Obj_SafeArrayAccessData
;__Au3Obj_SafeArrayUnaccessData
;__Au3Obj_SafeArrayGetUBound
;__Au3Obj_SafeArrayGetLBound
;__Au3Obj_SafeArrayGetDim
;__Au3Obj_CreateSafeArrayVariant
;__Au3Obj_ReadSafeArrayVariant
;__Au3Obj_CoTaskMemAlloc
;__Au3Obj_CoTaskMemFree
;__Au3Obj_CoTaskMemRealloc
;__Au3Obj_GlobalAlloc
;__Au3Obj_GlobalFree
;__Au3Obj_SysAllocString
;__Au3Obj_SysCopyString
;__Au3Obj_SysReAllocString
;__Au3Obj_SysFreeString
;__Au3Obj_SysStringLen
;__Au3Obj_SysReadString
;__Au3Obj_PtrStringLen
;__Au3Obj_PtrStringRead
;__Au3Obj_FunctionProxy
;__Au3Obj_EnumFunctionProxy
;__Au3Obj_ObjStructGetElements
;__Au3Obj_ObjStructMethod
;__Au3Obj_ObjStructDestructor
;__Au3Obj_ObjStructPointer
;__Au3Obj_PointerCall
;__Au3Obj_Mem_DllOpen
;__Au3Obj_Mem_FixReloc
;__Au3Obj_Mem_FixImports
;__Au3Obj_Mem_LoadLibraryEx
;__Au3Obj_Mem_FreeLibrary
;__Au3Obj_Mem_GetAddress
;__Au3Obj_Mem_VirtualProtect
;__Au3Obj_Mem_Base64Decode
;__Au3Obj_Mem_BinDll
;__Au3Obj_Mem_BinDll_X64
; ===============================================================================================================================

; #DATATYPES# =====================================================================================================================
; none - no value (only valid for return type, equivalent to void in C)
; byte - an unsigned 8 bit integer
; boolean - an unsigned 8 bit integer
; short - a 16 bit integer
; word, ushort - an unsigned 16 bit integer
; int, long - a 32 bit integer
; bool - a 32 bit integer
; dword, ulong, uint - an unsigned 32 bit integer
; hresult - an unsigned 32 bit integer
; int64 - a 64 bit integer
; uint64 - an unsigned 64 bit integer
; ptr - a general pointer (void *)
; hwnd - a window handle (pointer wide)
; handle - an handle (pointer wide)
; float - a single precision floating point number
; double - a double precision floating point number
; int_ptr, long_ptr, lresult, lparam - an integer big enough to hold a pointer when running on x86 or x64 versions of AutoIt
; uint_ptr, ulong_ptr, dword_ptr, wparam - an unsigned integer big enough to hold a pointer when running on x86 or x64 versions of AutoIt
; str - an ANSI string (a minimum of 65536 chars is allocated)
; wstr - a UNICODE wide character string (a minimum of 65536 chars is allocated)
; bstr - a composite data type that consists of a length prefix, a data string and a terminator
; variant - a tagged union that can be used to represent any other data type
; idispatch, object - a composite data type that represents object with IDispatch interface
; ===============================================================================================================================

;--------------------------------------------------------------------------------------------------------------------------------------
#Region Variable definitions

Global Const $gh_AU3Obj_kernel32dll = DllOpen("kernel32.dll")
Global Const $gh_AU3Obj_oleautdll = DllOpen("oleaut32.dll")
Global Const $gh_AU3Obj_ole32dll = DllOpen("ole32.dll")

Global Const $__Au3Obj_X64 = @AutoItX64

Global Const $__Au3Obj_VT_EMPTY = 0
Global Const $__Au3Obj_VT_NULL = 1
Global Const $__Au3Obj_VT_I2 = 2
Global Const $__Au3Obj_VT_I4 = 3
Global Const $__Au3Obj_VT_R4 = 4
Global Const $__Au3Obj_VT_R8 = 5
Global Const $__Au3Obj_VT_CY = 6
Global Const $__Au3Obj_VT_DATE = 7
Global Const $__Au3Obj_VT_BSTR = 8
Global Const $__Au3Obj_VT_DISPATCH = 9
Global Const $__Au3Obj_VT_ERROR = 10
Global Const $__Au3Obj_VT_BOOL = 11
Global Const $__Au3Obj_VT_VARIANT = 12
Global Const $__Au3Obj_VT_UNKNOWN = 13
Global Const $__Au3Obj_VT_DECIMAL = 14
Global Const $__Au3Obj_VT_I1 = 16
Global Const $__Au3Obj_VT_UI1 = 17
Global Const $__Au3Obj_VT_UI2 = 18
Global Const $__Au3Obj_VT_UI4 = 19
Global Const $__Au3Obj_VT_I8 = 20
Global Const $__Au3Obj_VT_UI8 = 21
Global Const $__Au3Obj_VT_INT = 22
Global Const $__Au3Obj_VT_UINT = 23
Global Const $__Au3Obj_VT_VOID = 24
Global Const $__Au3Obj_VT_HRESULT = 25
Global Const $__Au3Obj_VT_PTR = 26
Global Const $__Au3Obj_VT_SAFEARRAY = 27
Global Const $__Au3Obj_VT_CARRAY = 28
Global Const $__Au3Obj_VT_USERDEFINED = 29
Global Const $__Au3Obj_VT_LPSTR = 30
Global Const $__Au3Obj_VT_LPWSTR = 31
Global Const $__Au3Obj_VT_RECORD = 36
Global Const $__Au3Obj_VT_INT_PTR = 37
Global Const $__Au3Obj_VT_UINT_PTR = 38
Global Const $__Au3Obj_VT_FILETIME = 64
Global Const $__Au3Obj_VT_BLOB = 65
Global Const $__Au3Obj_VT_STREAM = 66
Global Const $__Au3Obj_VT_STORAGE = 67
Global Const $__Au3Obj_VT_STREAMED_OBJECT = 68
Global Const $__Au3Obj_VT_STORED_OBJECT = 69
Global Const $__Au3Obj_VT_BLOB_OBJECT = 70
Global Const $__Au3Obj_VT_CF = 71
Global Const $__Au3Obj_VT_CLSID = 72
Global Const $__Au3Obj_VT_VERSIONED_STREAM = 73
Global Const $__Au3Obj_VT_BSTR_BLOB = 0xfff
Global Const $__Au3Obj_VT_VECTOR = 0x1000
Global Const $__Au3Obj_VT_ARRAY = 0x2000
Global Const $__Au3Obj_VT_BYREF = 0x4000
Global Const $__Au3Obj_VT_RESERVED = 0x8000
Global Const $__Au3Obj_VT_ILLEGAL = 0xffff
Global Const $__Au3Obj_VT_ILLEGALMASKED = 0xfff
Global Const $__Au3Obj_VT_TYPEMASK = 0xfff

Global Const $__Au3Obj_tagVARIANT = "word vt;word r1;word r2;word r3;ptr data; ptr"

Global Const $__Au3Obj_VARIANT_SIZE = DllStructGetSize(DllStructCreate($__Au3Obj_tagVARIANT, 1))
Global Const $__Au3Obj_PTR_SIZE = DllStructGetSize(DllStructCreate('ptr', 1))
Global Const $__Au3Obj_tagSAFEARRAYBOUND = "ulong cElements; long lLbound;"

Global $ghAutoItObjectDLL = -1, $giAutoItObjectDLLRef = 0

;===============================================================================
#interface "IUnknown"
Global Const $sIID_IUnknown = "{00000000-0000-0000-C000-000000000046}"
; Definition
Global $dtagIUnknown = "QueryInterface hresult(ptr;ptr*);" & _
		"AddRef dword();" & _
		"Release dword();"
; List
Global $ltagIUnknown = "QueryInterface;" & _
		"AddRef;" & _
		"Release;"
;===============================================================================
;===============================================================================
#interface "IDispatch"
Global Const $sIID_IDispatch = "{00020400-0000-0000-C000-000000000046}"
; Definition
Global $dtagIDispatch = $dtagIUnknown & _
		"GetTypeInfoCount hresult(dword*);" & _
		"GetTypeInfo hresult(dword;dword;ptr*);" & _
		"GetIDsOfNames hresult(ptr;ptr;dword;dword;ptr);" & _
		"Invoke hresult(dword;ptr;dword;word;ptr;ptr;ptr;ptr);"
; List
Global $ltagIDispatch = $ltagIUnknown & _
		"GetTypeInfoCount;" & _
		"GetTypeInfo;" & _
		"GetIDsOfNames;" & _
		"Invoke;"
;===============================================================================

#EndRegion Variable definitions
;--------------------------------------------------------------------------------------------------------------------------------------


;--------------------------------------------------------------------------------------------------------------------------------------
#Region Misc

DllCall($gh_AU3Obj_ole32dll, 'long', 'OleInitialize', 'ptr', 0)
OnAutoItExitRegister("__Au3Obj_OleUninitialize")
Func __Au3Obj_OleUninitialize()
	; Author: Prog@ndy
	DllCall($gh_AU3Obj_ole32dll, 'long', 'OleUninitialize')
	_AutoItObject_Shutdown(True)
EndFunc   ;==>__Au3Obj_OleUninitialize

Func __Au3Obj_IUnknown_AddRef($vObj)
	Local $sType = "ptr"
	If IsObj($vObj) Then $sType = "idispatch"
	Local $tVARIANT = DllStructCreate($__Au3Obj_tagVARIANT)
	; Actual call
	Local $aCall = DllCall($gh_AU3Obj_oleautdll, "long", "DispCallFunc", _
			$sType, $vObj, _
			"dword", $__Au3Obj_PTR_SIZE, _ ; offset (4 for x86, 8 for x64)
			"dword", 4, _ ; CC_STDCALL
			"dword", $__Au3Obj_VT_UINT, _
			"dword", 0, _ ; number of function parameters
			"ptr", 0, _ ; parameters related
			"ptr", 0, _ ; parameters related
			"ptr", DllStructGetPtr($tVARIANT))
	If @error Or $aCall[0] Then Return SetError(1, 0, 0)
	; Collect returned
	Return DllStructGetData(DllStructCreate("dword", DllStructGetPtr($tVARIANT, "data")), 1)
EndFunc   ;==>__Au3Obj_IUnknown_AddRef

Func __Au3Obj_IUnknown_Release($vObj)
	Local $sType = "ptr"
	If IsObj($vObj) Then $sType = "idispatch"
	Local $tVARIANT = DllStructCreate($__Au3Obj_tagVARIANT)
	; Actual call
	Local $aCall = DllCall($gh_AU3Obj_oleautdll, "long", "DispCallFunc", _
			$sType, $vObj, _
			"dword", 2 * $__Au3Obj_PTR_SIZE, _ ; offset (8 for x86, 16 for x64)
			"dword", 4, _ ; CC_STDCALL
			"dword", $__Au3Obj_VT_UINT, _
			"dword", 0, _ ; number of function parameters
			"ptr", 0, _ ; parameters related
			"ptr", 0, _ ; parameters related
			"ptr", DllStructGetPtr($tVARIANT))
	If @error Or $aCall[0] Then Return SetError(1, 0, 0)
	; Collect returned
	Return DllStructGetData(DllStructCreate("dword", DllStructGetPtr($tVARIANT, "data")), 1)
EndFunc   ;==>__Au3Obj_IUnknown_Release

Func __Au3Obj_GetMethods($tagInterface)
	Local $sMethods = StringReplace(StringRegExpReplace($tagInterface, "\h*(\w+)\h*(\w+\*?)\h*(\((.*?)\))\h*(;|;*\z)", "$1\|$2;$4" & @LF), ";" & @LF, @LF)
	If $sMethods = $tagInterface Then $sMethods = StringReplace(StringRegExpReplace($tagInterface, "\h*(\w+)\h*(;|;*\z)", "$1\|" & @LF), ";" & @LF, @LF)
	Return StringTrimRight($sMethods, 1)
EndFunc   ;==>__Au3Obj_GetMethods

Func __Au3Obj_ObjStructGetElements($sTag, ByRef $sAlign)
	Local $sAlignment = StringRegExpReplace($sTag, "\h*(align\h+\d+)\h*;.*", "$1")
	If $sAlignment <> $sTag Then
		$sAlign = $sAlignment
		$sTag = StringRegExpReplace($sTag, "\h*(align\h+\d+)\h*;", "")
	EndIf
	; Return StringRegExp($sTag, "\h*\w+\h*(\w+)\h*", 3) ; DO NOT REMOVE THIS LINE
	Return StringTrimRight(StringRegExpReplace($sTag, "\h*\w+\h*(\w+)\h*(\[\d+\])*\h*(;|;*\z)\h*", "$1;"), 1)
EndFunc   ;==>__Au3Obj_ObjStructGetElements

#EndRegion Misc
;--------------------------------------------------------------------------------------------------------------------------------------


;--------------------------------------------------------------------------------------------------------------------------------------
#Region SafeArray
Func __Au3Obj_SafeArrayCreate($vType, $cDims, $rgsabound)
	; Author: Prog@ndy
	Local $aCall = DllCall($gh_AU3Obj_oleautdll, "ptr", "SafeArrayCreate", "dword", $vType, "uint", $cDims, 'ptr', $rgsabound)
	If @error Then Return SetError(1, 0, 0)
	Return $aCall[0]
EndFunc   ;==>__Au3Obj_SafeArrayCreate

Func __Au3Obj_SafeArrayDestroy($pSafeArray)
	; Author: Prog@ndy
	Local $aCall = DllCall($gh_AU3Obj_oleautdll, "int", "SafeArrayDestroy", "ptr", $pSafeArray)
	If @error Then Return SetError(1, 0, 1)
	Return $aCall[0]
EndFunc   ;==>__Au3Obj_SafeArrayDestroy

Func __Au3Obj_SafeArrayAccessData($pSafeArray, ByRef $pArrayData)
	; Author: Prog@ndy
	Local $aCall = DllCall($gh_AU3Obj_oleautdll, "int", "SafeArrayAccessData", "ptr", $pSafeArray, 'ptr*', 0)
	If @error Then Return SetError(1, 0, 1)
	$pArrayData = $aCall[2]
	Return $aCall[0]
EndFunc   ;==>__Au3Obj_SafeArrayAccessData

Func __Au3Obj_SafeArrayUnaccessData($pSafeArray)
	; Author: Prog@ndy
	Local $aCall = DllCall($gh_AU3Obj_oleautdll, "int", "SafeArrayUnaccessData", "ptr", $pSafeArray)
	If @error Then Return SetError(1, 0, 1)
	Return $aCall[0]
EndFunc   ;==>__Au3Obj_SafeArrayUnaccessData

Func __Au3Obj_SafeArrayGetUBound($pSafeArray, $iDim, ByRef $iBound)
	; Author: Prog@ndy
	Local $aCall = DllCall($gh_AU3Obj_oleautdll, "int", "SafeArrayGetUBound", "ptr", $pSafeArray, 'uint', $iDim, 'long*', 0)
	If @error Then Return SetError(1, 0, 1)
	$iBound = $aCall[3]
	Return $aCall[0]
EndFunc   ;==>__Au3Obj_SafeArrayGetUBound

Func __Au3Obj_SafeArrayGetLBound($pSafeArray, $iDim, ByRef $iBound)
	; Author: Prog@ndy
	Local $aCall = DllCall($gh_AU3Obj_oleautdll, "int", "SafeArrayGetLBound", "ptr", $pSafeArray, 'uint', $iDim, 'long*', 0)
	If @error Then Return SetError(1, 0, 1)
	$iBound = $aCall[3]
	Return $aCall[0]
EndFunc   ;==>__Au3Obj_SafeArrayGetLBound

Func __Au3Obj_SafeArrayGetDim($pSafeArray)
	Local $aResult = DllCall($gh_AU3Obj_oleautdll, "uint", "SafeArrayGetDim", "ptr", $pSafeArray)
	If @error Then Return SetError(1, 0, 0)
	Return $aResult[0]
EndFunc   ;==>__Au3Obj_SafeArrayGetDim

Func __Au3Obj_CreateSafeArrayVariant(ByRef Const $aArray)
	; Author: Prog@ndy
	Local $iDim = UBound($aArray, 0), $pData, $pSafeArray, $bound, $subBound, $tBound
	Switch $iDim
		Case 1
			$bound = UBound($aArray) - 1
			$tBound = DllStructCreate($__Au3Obj_tagSAFEARRAYBOUND)
			DllStructSetData($tBound, 1, $bound + 1)
			$pSafeArray = __Au3Obj_SafeArrayCreate($__Au3Obj_VT_VARIANT, 1, DllStructGetPtr($tBound))
			If 0 = __Au3Obj_SafeArrayAccessData($pSafeArray, $pData) Then
				For $i = 0 To $bound
					_AutoItObject_VariantInit($pData + $i * $__Au3Obj_VARIANT_SIZE)
					_AutoItObject_VariantSet($pData + $i * $__Au3Obj_VARIANT_SIZE, $aArray[$i])
				Next
				__Au3Obj_SafeArrayUnaccessData($pSafeArray)
			EndIf
			Return $pSafeArray
		Case 2
			$bound = UBound($aArray, 1) - 1
			$subBound = UBound($aArray, 2) - 1
			$tBound = DllStructCreate($__Au3Obj_tagSAFEARRAYBOUND & $__Au3Obj_tagSAFEARRAYBOUND)
			DllStructSetData($tBound, 3, $bound + 1)
			DllStructSetData($tBound, 1, $subBound + 1)
			$pSafeArray = __Au3Obj_SafeArrayCreate($__Au3Obj_VT_VARIANT, 2, DllStructGetPtr($tBound))
			If 0 = __Au3Obj_SafeArrayAccessData($pSafeArray, $pData) Then
				For $i = 0 To $bound
					For $j = 0 To $subBound
						_AutoItObject_VariantInit($pData + ($j + $i * ($subBound + 1)) * $__Au3Obj_VARIANT_SIZE)
						_AutoItObject_VariantSet($pData + ($j + $i * ($subBound + 1)) * $__Au3Obj_VARIANT_SIZE, $aArray[$i][$j])
					Next
				Next
				__Au3Obj_SafeArrayUnaccessData($pSafeArray)
			EndIf
			Return $pSafeArray
		Case Else
			Return 0
	EndSwitch
EndFunc   ;==>__Au3Obj_CreateSafeArrayVariant

Func __Au3Obj_ReadSafeArrayVariant($pSafeArray)
	; Author: Prog@ndy
	Local $iDim = __Au3Obj_SafeArrayGetDim($pSafeArray), $pData, $lbound, $bound, $subBound
	Switch $iDim
		Case 1
			__Au3Obj_SafeArrayGetLBound($pSafeArray, 1, $lbound)
			__Au3Obj_SafeArrayGetUBound($pSafeArray, 1, $bound)
			$bound -= $lbound
			Local $array[$bound + 1]
			If 0 = __Au3Obj_SafeArrayAccessData($pSafeArray, $pData) Then
				For $i = 0 To $bound
					$array[$i] = _AutoItObject_VariantRead($pData + $i * $__Au3Obj_VARIANT_SIZE)
				Next
				__Au3Obj_SafeArrayUnaccessData($pSafeArray)
			EndIf
			Return $array
		Case 2
			__Au3Obj_SafeArrayGetLBound($pSafeArray, 2, $lbound)
			__Au3Obj_SafeArrayGetUBound($pSafeArray, 2, $bound)
			$bound -= $lbound
			__Au3Obj_SafeArrayGetLBound($pSafeArray, 1, $lbound)
			__Au3Obj_SafeArrayGetUBound($pSafeArray, 1, $subBound)
			$subBound -= $lbound
			Local $array[$bound + 1][$subBound + 1]
			If 0 = __Au3Obj_SafeArrayAccessData($pSafeArray, $pData) Then
				For $i = 0 To $bound
					For $j = 0 To $subBound
						$array[$i][$j] = _AutoItObject_VariantRead($pData + ($j + $i * ($subBound + 1)) * $__Au3Obj_VARIANT_SIZE)
					Next
				Next
				__Au3Obj_SafeArrayUnaccessData($pSafeArray)
			EndIf
			Return $array
		Case Else
			Return 0
	EndSwitch
EndFunc   ;==>__Au3Obj_ReadSafeArrayVariant

#EndRegion SafeArray
;--------------------------------------------------------------------------------------------------------------------------------------


;--------------------------------------------------------------------------------------------------------------------------------------
#Region Memory

Func __Au3Obj_CoTaskMemAlloc($iSize)
	; Author: Prog@ndy
	Local $aCall = DllCall($gh_AU3Obj_ole32dll, "ptr", "CoTaskMemAlloc", "uint_ptr", $iSize)
	If @error Then Return SetError(1, 0, 0)
	Return $aCall[0]
EndFunc   ;==>__Au3Obj_CoTaskMemAlloc

Func __Au3Obj_CoTaskMemFree($pCoMem)
	; Author: Prog@ndy
	DllCall($gh_AU3Obj_ole32dll, "none", "CoTaskMemFree", "ptr", $pCoMem)
	If @error Then Return SetError(1, 0, 0)
EndFunc   ;==>__Au3Obj_CoTaskMemFree

Func __Au3Obj_CoTaskMemRealloc($pCoMem, $iSize)
	; Author: Prog@ndy
	Local $aCall = DllCall($gh_AU3Obj_ole32dll, "ptr", "CoTaskMemRealloc", 'ptr', $pCoMem, "uint_ptr", $iSize)
	If @error Then Return SetError(1, 0, 0)
	Return $aCall[0]
EndFunc   ;==>__Au3Obj_CoTaskMemRealloc

Func __Au3Obj_GlobalAlloc($iSize, $iFlag)
	Local $aCall = DllCall($gh_AU3Obj_kernel32dll, "ptr", "GlobalAlloc", "dword", $iFlag, "dword_ptr", $iSize)
	If @error Or Not $aCall[0] Then Return SetError(1, 0, 0)
	Return $aCall[0]
EndFunc   ;==>__Au3Obj_GlobalAlloc

Func __Au3Obj_GlobalFree($pPointer)
	Local $aCall = DllCall($gh_AU3Obj_kernel32dll, "ptr", "GlobalFree", "ptr", $pPointer)
	If @error Or $aCall[0] Then Return SetError(1, 0, 0)
	Return 1
EndFunc   ;==>__Au3Obj_GlobalFree

#EndRegion Memory
;--------------------------------------------------------------------------------------------------------------------------------------


;--------------------------------------------------------------------------------------------------------------------------------------
#Region SysString

Func __Au3Obj_SysAllocString($str)
	; Author: monoceres
	Local $aCall = DllCall($gh_AU3Obj_oleautdll, "ptr", "SysAllocString", "wstr", $str)
	If @error Then Return SetError(1, 0, 0)
	Return $aCall[0]
EndFunc   ;==>__Au3Obj_SysAllocString
Func __Au3Obj_SysCopyString($pBSTR)
	; Author: Prog@ndy
	If Not $pBSTR Then Return SetError(2, 0, 0)
	Local $aCall = DllCall($gh_AU3Obj_oleautdll, "ptr", "SysAllocStringLen", "ptr", $pBSTR, "uint", __Au3Obj_SysStringLen($pBSTR))
	If @error Then Return SetError(1, 0, 0)
	Return $aCall[0]
EndFunc   ;==>__Au3Obj_SysCopyString

Func __Au3Obj_SysReAllocString(ByRef $pBSTR, $str)
	; Author: Prog@ndy
	If Not $pBSTR Then Return SetError(2, 0, 0)
	Local $aCall = DllCall($gh_AU3Obj_oleautdll, "int", "SysReAllocString", 'ptr*', $pBSTR, "wstr", $str)
	If @error Then Return SetError(1, 0, 0)
	$pBSTR = $aCall[1]
	Return $aCall[0]
EndFunc   ;==>__Au3Obj_SysReAllocString

Func __Au3Obj_SysFreeString($pBSTR)
	; Author: Prog@ndy
	If Not $pBSTR Then Return SetError(2, 0, 0)
	DllCall($gh_AU3Obj_oleautdll, "none", "SysFreeString", "ptr", $pBSTR)
	If @error Then Return SetError(1, 0, 0)
EndFunc   ;==>__Au3Obj_SysFreeString

Func __Au3Obj_SysStringLen($pBSTR)
	; Author: Prog@ndy
	If Not $pBSTR Then Return SetError(2, 0, 0)
	Local $aCall = DllCall($gh_AU3Obj_oleautdll, "uint", "SysStringLen", "ptr", $pBSTR)
	If @error Then Return SetError(1, 0, 0)
	Return $aCall[0]
EndFunc   ;==>__Au3Obj_SysStringLen

Func __Au3Obj_SysReadString($pBSTR, $iLen = -1)
	; Author: Prog@ndy
	If Not $pBSTR Then Return SetError(2, 0, '')
	If $iLen < 1 Then $iLen = __Au3Obj_SysStringLen($pBSTR)
	If $iLen < 1 Then Return SetError(1, 0, '')
	Return DllStructGetData(DllStructCreate("wchar[" & $iLen & "]", $pBSTR), 1)
EndFunc   ;==>__Au3Obj_SysReadString

Func __Au3Obj_PtrStringLen($pStr)
	; Author: Prog@ndy
	Local $aResult = DllCall($gh_AU3Obj_kernel32dll, 'int', 'lstrlenW', 'ptr', $pStr)
	If @error Then Return SetError(1, 0, 0)
	Return $aResult[0]
EndFunc   ;==>__Au3Obj_PtrStringLen

Func __Au3Obj_PtrStringRead($pStr, $iLen = -1)
	; Author: Prog@ndy
	If $iLen < 1 Then $iLen = __Au3Obj_PtrStringLen($pStr)
	If $iLen < 1 Then Return SetError(1, 0, '')
	Return DllStructGetData(DllStructCreate("wchar[" & $iLen & "]", $pStr), 1)
EndFunc   ;==>__Au3Obj_PtrStringRead

#EndRegion SysString
;--------------------------------------------------------------------------------------------------------------------------------------


;--------------------------------------------------------------------------------------------------------------------------------------
#Region Proxy Functions

Func __Au3Obj_FunctionProxy($FuncName, $oSelf) ; allows binary code to call autoit functions
	Local $arg = $oSelf.__params__ ; fetch params
	If IsArray($arg) Then
		Local $ret = Call($FuncName, $arg) ; Call
		If @error = 0xDEAD And @extended = 0xBEEF Then Return 0
		$oSelf.__error__ = @error ; set error
		$oSelf.__result__ = $ret ; set result
		Return 1
	EndIf
	; return error when params-array could not be created
EndFunc   ;==>__Au3Obj_FunctionProxy

Func __Au3Obj_EnumFunctionProxy($iAction, $FuncName, $oSelf, $pVarCurrent, $pVarResult)
	Local $Current, $ret
	Switch $iAction
		Case 0 ; Next
			$Current = $oSelf.__bridge__(Number($pVarCurrent))
			$ret = Execute($FuncName & "($oSelf, $Current)")
			If @error Then Return False
			$oSelf.__bridge__(Number($pVarCurrent)) = $Current
			$oSelf.__bridge__(Number($pVarResult)) = $ret
			Return 1
		Case 1 ;Skip
			Return False
		Case 2 ; Reset
			$Current = $oSelf.__bridge__(Number($pVarCurrent))
			$ret = Execute($FuncName & "($oSelf, $Current)")
			If @error Or Not $ret Then Return False
			$oSelf.__bridge__(Number($pVarCurrent)) = $Current
			Return True
	EndSwitch
EndFunc   ;==>__Au3Obj_EnumFunctionProxy

#EndRegion Proxy Functions
;--------------------------------------------------------------------------------------------------------------------------------------


;--------------------------------------------------------------------------------------------------------------------------------------
#Region Call Pointer

Func __Au3Obj_PointerCall($sRetType, $pAddress, $sType1 = "", $vParam1 = 0, $sType2 = "", $vParam2 = 0, $sType3 = "", $vParam3 = 0, $sType4 = "", $vParam4 = 0, $sType5 = "", $vParam5 = 0, $sType6 = "", $vParam6 = 0, $sType7 = "", $vParam7 = 0, $sType8 = "", $vParam8 = 0, $sType9 = "", $vParam9 = 0, $sType10 = "", $vParam10 = 0, $sType11 = "", $vParam11 = 0, $sType12 = "", $vParam12 = 0, $sType13 = "", $vParam13 = 0, $sType14 = "", $vParam14 = 0, $sType15 = "", $vParam15 = 0, $sType16 = "", $vParam16 = 0, $sType17 = "", $vParam17 = 0, $sType18 = "", $vParam18 = 0, $sType19 = "", $vParam19 = 0, $sType20 = "", $vParam20 = 0)
	; Author: Ward, Prog@ndy, trancexx
	Local Static $pHook, $hPseudo, $tPtr, $sFuncName = "MemoryCallEntry"
	If $pAddress Then
		If Not $pHook Then
			Local $sDll = "AutoItObject.dll"
			If $__Au3Obj_X64 Then $sDll = "AutoItObject_X64.dll"
			$hPseudo = DllOpen($sDll)
			If $hPseudo = -1 Then
				$sDll = "kernel32.dll"
				$sFuncName = "GlobalFix"
				$hPseudo = DllOpen($sDll)
			EndIf
			Local $aCall = DllCall($gh_AU3Obj_kernel32dll, "ptr", "GetModuleHandleW", "wstr", $sDll)
			If @error Or Not $aCall[0] Then Return SetError(7, @error, 0) ; Couldn't get dll handle
			Local $hModuleHandle = $aCall[0]
			$aCall = DllCall($gh_AU3Obj_kernel32dll, "ptr", "GetProcAddress", "ptr", $hModuleHandle, "str", $sFuncName)
			If @error Then Return SetError(8, @error, 0) ; Wanted function not found
			$pHook = $aCall[0]
			$aCall = DllCall($gh_AU3Obj_kernel32dll, "bool", "VirtualProtect", "ptr", $pHook, "dword", 7 + 5 * $__Au3Obj_X64, "dword", 64, "dword*", 0)
			If @error Or Not $aCall[0] Then Return SetError(9, @error, 0) ; Unable to set MEM_EXECUTE_READWRITE
			If $__Au3Obj_X64 Then
				DllStructSetData(DllStructCreate("word", $pHook), 1, 0xB848)
				DllStructSetData(DllStructCreate("word", $pHook + 10), 1, 0xE0FF)
			Else
				DllStructSetData(DllStructCreate("byte", $pHook), 1, 0xB8)
				DllStructSetData(DllStructCreate("word", $pHook + 5), 1, 0xE0FF)
			EndIf
			$tPtr = DllStructCreate("ptr", $pHook + 1 + $__Au3Obj_X64)
		EndIf
		DllStructSetData($tPtr, 1, $pAddress)
		Local $aRet
		Switch @NumParams
			Case 2
				$aRet = DllCall($hPseudo, $sRetType, $sFuncName)
			Case 4
				$aRet = DllCall($hPseudo, $sRetType, $sFuncName, $sType1, $vParam1)
			Case 6
				$aRet = DllCall($hPseudo, $sRetType, $sFuncName, $sType1, $vParam1, $sType2, $vParam2)
			Case 8
				$aRet = DllCall($hPseudo, $sRetType, $sFuncName, $sType1, $vParam1, $sType2, $vParam2, $sType3, $vParam3)
			Case 10
				$aRet = DllCall($hPseudo, $sRetType, $sFuncName, $sType1, $vParam1, $sType2, $vParam2, $sType3, $vParam3, $sType4, $vParam4)
			Case 12
				$aRet = DllCall($hPseudo, $sRetType, $sFuncName, $sType1, $vParam1, $sType2, $vParam2, $sType3, $vParam3, $sType4, $vParam4, $sType5, $vParam5)
			Case 14
				$aRet = DllCall($hPseudo, $sRetType, $sFuncName, $sType1, $vParam1, $sType2, $vParam2, $sType3, $vParam3, $sType4, $vParam4, $sType5, $vParam5, $sType6, $vParam6)
			Case 16
				$aRet = DllCall($hPseudo, $sRetType, $sFuncName, $sType1, $vParam1, $sType2, $vParam2, $sType3, $vParam3, $sType4, $vParam4, $sType5, $vParam5, $sType6, $vParam6, $sType7, $vParam7)
			Case 18
				$aRet = DllCall($hPseudo, $sRetType, $sFuncName, $sType1, $vParam1, $sType2, $vParam2, $sType3, $vParam3, $sType4, $vParam4, $sType5, $vParam5, $sType6, $vParam6, $sType7, $vParam7, $sType8, $vParam8)
			Case 20
				$aRet = DllCall($hPseudo, $sRetType, $sFuncName, $sType1, $vParam1, $sType2, $vParam2, $sType3, $vParam3, $sType4, $vParam4, $sType5, $vParam5, $sType6, $vParam6, $sType7, $vParam7, $sType8, $vParam8, $sType9, $vParam9)
			Case 22
				$aRet = DllCall($hPseudo, $sRetType, $sFuncName, $sType1, $vParam1, $sType2, $vParam2, $sType3, $vParam3, $sType4, $vParam4, $sType5, $vParam5, $sType6, $vParam6, $sType7, $vParam7, $sType8, $vParam8, $sType9, $vParam9, $sType10, $vParam10)
			Case 24
				$aRet = DllCall($hPseudo, $sRetType, $sFuncName, $sType1, $vParam1, $sType2, $vParam2, $sType3, $vParam3, $sType4, $vParam4, $sType5, $vParam5, $sType6, $vParam6, $sType7, $vParam7, $sType8, $vParam8, $sType9, $vParam9, $sType10, $vParam10, $sType11, $vParam11)
			Case 26
				$aRet = DllCall($hPseudo, $sRetType, $sFuncName, $sType1, $vParam1, $sType2, $vParam2, $sType3, $vParam3, $sType4, $vParam4, $sType5, $vParam5, $sType6, $vParam6, $sType7, $vParam7, $sType8, $vParam8, $sType9, $vParam9, $sType10, $vParam10, $sType11, $vParam11, $sType12, $vParam12)
			Case 28
				$aRet = DllCall($hPseudo, $sRetType, $sFuncName, $sType1, $vParam1, $sType2, $vParam2, $sType3, $vParam3, $sType4, $vParam4, $sType5, $vParam5, $sType6, $vParam6, $sType7, $vParam7, $sType8, $vParam8, $sType9, $vParam9, $sType10, $vParam10, $sType11, $vParam11, $sType12, $vParam12, $sType13, $vParam13)
			Case 30
				$aRet = DllCall($hPseudo, $sRetType, $sFuncName, $sType1, $vParam1, $sType2, $vParam2, $sType3, $vParam3, $sType4, $vParam4, $sType5, $vParam5, $sType6, $vParam6, $sType7, $vParam7, $sType8, $vParam8, $sType9, $vParam9, $sType10, $vParam10, $sType11, $vParam11, $sType12, $vParam12, $sType13, $vParam13, $sType14, $vParam14)
			Case 32
				$aRet = DllCall($hPseudo, $sRetType, $sFuncName, $sType1, $vParam1, $sType2, $vParam2, $sType3, $vParam3, $sType4, $vParam4, $sType5, $vParam5, $sType6, $vParam6, $sType7, $vParam7, $sType8, $vParam8, $sType9, $vParam9, $sType10, $vParam10, $sType11, $vParam11, $sType12, $vParam12, $sType13, $vParam13, $sType14, $vParam14, $sType15, $vParam15)
			Case 34
				$aRet = DllCall($hPseudo, $sRetType, $sFuncName, $sType1, $vParam1, $sType2, $vParam2, $sType3, $vParam3, $sType4, $vParam4, $sType5, $vParam5, $sType6, $vParam6, $sType7, $vParam7, $sType8, $vParam8, $sType9, $vParam9, $sType10, $vParam10, $sType11, $vParam11, $sType12, $vParam12, $sType13, $vParam13, $sType14, $vParam14, $sType15, $vParam15, $sType16, $vParam16)
			Case 36
				$aRet = DllCall($hPseudo, $sRetType, $sFuncName, $sType1, $vParam1, $sType2, $vParam2, $sType3, $vParam3, $sType4, $vParam4, $sType5, $vParam5, $sType6, $vParam6, $sType7, $vParam7, $sType8, $vParam8, $sType9, $vParam9, $sType10, $vParam10, $sType11, $vParam11, $sType12, $vParam12, $sType13, $vParam13, $sType14, $vParam14, $sType15, $vParam15, $sType16, $vParam16, $sType17, $vParam17)
			Case 38
				$aRet = DllCall($hPseudo, $sRetType, $sFuncName, $sType1, $vParam1, $sType2, $vParam2, $sType3, $vParam3, $sType4, $vParam4, $sType5, $vParam5, $sType6, $vParam6, $sType7, $vParam7, $sType8, $vParam8, $sType9, $vParam9, $sType10, $vParam10, $sType11, $vParam11, $sType12, $vParam12, $sType13, $vParam13, $sType14, $vParam14, $sType15, $vParam15, $sType16, $vParam16, $sType17, $vParam17, $sType18, $vParam18)
			Case 40
				$aRet = DllCall($hPseudo, $sRetType, $sFuncName, $sType1, $vParam1, $sType2, $vParam2, $sType3, $vParam3, $sType4, $vParam4, $sType5, $vParam5, $sType6, $vParam6, $sType7, $vParam7, $sType8, $vParam8, $sType9, $vParam9, $sType10, $vParam10, $sType11, $vParam11, $sType12, $vParam12, $sType13, $vParam13, $sType14, $vParam14, $sType15, $vParam15, $sType16, $vParam16, $sType17, $vParam17, $sType18, $vParam18, $sType19, $vParam19)
			Case 42
				$aRet = DllCall($hPseudo, $sRetType, $sFuncName, $sType1, $vParam1, $sType2, $vParam2, $sType3, $vParam3, $sType4, $vParam4, $sType5, $vParam5, $sType6, $vParam6, $sType7, $vParam7, $sType8, $vParam8, $sType9, $vParam9, $sType10, $vParam10, $sType11, $vParam11, $sType12, $vParam12, $sType13, $vParam13, $sType14, $vParam14, $sType15, $vParam15, $sType16, $vParam16, $sType17, $vParam17, $sType18, $vParam18, $sType19, $vParam19, $sType20, $vParam20)
			Case Else
				If Mod(@NumParams, 2) Then Return SetError(4, 0, 0) ; Bad number of parameters
				Return SetError(5, 0, 0) ; Max number of parameters exceeded
		EndSwitch
		Return SetError(@error, @extended, $aRet) ; All went well. Error description and return values like with DllCall()
	EndIf
	Return SetError(6, 0, 0) ; Null address specified
EndFunc   ;==>__Au3Obj_PointerCall

#EndRegion Call Pointer
;--------------------------------------------------------------------------------------------------------------------------------------


;--------------------------------------------------------------------------------------------------------------------------------------
#Region Embedded DLL

Func __Au3Obj_Mem_DllOpen($bBinaryImage = 0, $sSubrogor = "cmd.exe")
	If Not $bBinaryImage Then
		If $__Au3Obj_X64 Then
			$bBinaryImage = __Au3Obj_Mem_BinDll_X64()
		Else
			$bBinaryImage = __Au3Obj_Mem_BinDll()
		EndIf
	EndIf
	; Make structure out of binary data that was passed
	Local $tBinary = DllStructCreate("byte[" & BinaryLen($bBinaryImage) & "]")
	DllStructSetData($tBinary, 1, $bBinaryImage) ; fill the structure
	; Get pointer to it
	Local $pPointer = DllStructGetPtr($tBinary)
	; Start processing passed binary data. 'Reading' PE format follows.
	Local $tIMAGE_DOS_HEADER = DllStructCreate("char Magic[2];" & _
			"word BytesOnLastPage;" & _
			"word Pages;" & _
			"word Relocations;" & _
			"word SizeofHeader;" & _
			"word MinimumExtra;" & _
			"word MaximumExtra;" & _
			"word SS;" & _
			"word SP;" & _
			"word Checksum;" & _
			"word IP;" & _
			"word CS;" & _
			"word Relocation;" & _
			"word Overlay;" & _
			"char Reserved[8];" & _
			"word OEMIdentifier;" & _
			"word OEMInformation;" & _
			"char Reserved2[20];" & _
			"dword AddressOfNewExeHeader", _
			$pPointer)
	; Move pointer
	$pPointer += DllStructGetData($tIMAGE_DOS_HEADER, "AddressOfNewExeHeader") ; move to PE file header
	$pPointer += 4 ; size of skipped $tIMAGE_NT_SIGNATURE structure
	; In place of IMAGE_FILE_HEADER structure
	Local $tIMAGE_FILE_HEADER = DllStructCreate("word Machine;" & _
			"word NumberOfSections;" & _
			"dword TimeDateStamp;" & _
			"dword PointerToSymbolTable;" & _
			"dword NumberOfSymbols;" & _
			"word SizeOfOptionalHeader;" & _
			"word Characteristics", _
			$pPointer)
	; Get number of sections
	Local $iNumberOfSections = DllStructGetData($tIMAGE_FILE_HEADER, "NumberOfSections")
	; Move pointer
	$pPointer += 20 ; size of $tIMAGE_FILE_HEADER structure
	; Determine the type
	Local $tMagic = DllStructCreate("word Magic;", $pPointer)
	Local $iMagic = DllStructGetData($tMagic, 1)
	Local $tIMAGE_OPTIONAL_HEADER
	If $iMagic = 267 Then ; x86 version
		If $__Au3Obj_X64 Then Return SetError(1, 0, -1) ; incompatible versions
		$tIMAGE_OPTIONAL_HEADER = DllStructCreate("word Magic;" & _
				"byte MajorLinkerVersion;" & _
				"byte MinorLinkerVersion;" & _
				"dword SizeOfCode;" & _
				"dword SizeOfInitializedData;" & _
				"dword SizeOfUninitializedData;" & _
				"dword AddressOfEntryPoint;" & _
				"dword BaseOfCode;" & _
				"dword BaseOfData;" & _
				"dword ImageBase;" & _
				"dword SectionAlignment;" & _
				"dword FileAlignment;" & _
				"word MajorOperatingSystemVersion;" & _
				"word MinorOperatingSystemVersion;" & _
				"word MajorImageVersion;" & _
				"word MinorImageVersion;" & _
				"word MajorSubsystemVersion;" & _
				"word MinorSubsystemVersion;" & _
				"dword Win32VersionValue;" & _
				"dword SizeOfImage;" & _
				"dword SizeOfHeaders;" & _
				"dword CheckSum;" & _
				"word Subsystem;" & _
				"word DllCharacteristics;" & _
				"dword SizeOfStackReserve;" & _
				"dword SizeOfStackCommit;" & _
				"dword SizeOfHeapReserve;" & _
				"dword SizeOfHeapCommit;" & _
				"dword LoaderFlags;" & _
				"dword NumberOfRvaAndSizes", _
				$pPointer)
		; Move pointer
		$pPointer += 96 ; size of $tIMAGE_OPTIONAL_HEADER
	ElseIf $iMagic = 523 Then ; x64 version
		If Not $__Au3Obj_X64 Then Return SetError(1, 0, -1) ; incompatible versions
		$tIMAGE_OPTIONAL_HEADER = DllStructCreate("word Magic;" & _
				"byte MajorLinkerVersion;" & _
				"byte MinorLinkerVersion;" & _
				"dword SizeOfCode;" & _
				"dword SizeOfInitializedData;" & _
				"dword SizeOfUninitializedData;" & _
				"dword AddressOfEntryPoint;" & _
				"dword BaseOfCode;" & _
				"uint64 ImageBase;" & _
				"dword SectionAlignment;" & _
				"dword FileAlignment;" & _
				"word MajorOperatingSystemVersion;" & _
				"word MinorOperatingSystemVersion;" & _
				"word MajorImageVersion;" & _
				"word MinorImageVersion;" & _
				"word MajorSubsystemVersion;" & _
				"word MinorSubsystemVersion;" & _
				"dword Win32VersionValue;" & _
				"dword SizeOfImage;" & _
				"dword SizeOfHeaders;" & _
				"dword CheckSum;" & _
				"word Subsystem;" & _
				"word DllCharacteristics;" & _
				"uint64 SizeOfStackReserve;" & _
				"uint64 SizeOfStackCommit;" & _
				"uint64 SizeOfHeapReserve;" & _
				"uint64 SizeOfHeapCommit;" & _
				"dword LoaderFlags;" & _
				"dword NumberOfRvaAndSizes", _
				$pPointer)
		; Move pointer
		$pPointer += 112 ; size of $tIMAGE_OPTIONAL_HEADER
	Else
		Return SetError(1, 0, -1) ; incompatible versions
	EndIf
	; Extract data
	Local $iEntryPoint = DllStructGetData($tIMAGE_OPTIONAL_HEADER, "AddressOfEntryPoint") ; if loaded binary image would start executing at this address
	Local $pOptionalHeaderImageBase = DllStructGetData($tIMAGE_OPTIONAL_HEADER, "ImageBase") ; address of the first byte of the image when it's loaded in memory
	$pPointer += 8 ; skipping IMAGE_DIRECTORY_ENTRY_EXPORT
	; Import Directory
	Local $tIMAGE_DIRECTORY_ENTRY_IMPORT = DllStructCreate("dword VirtualAddress; dword Size", $pPointer)
	; Collect data
	Local $pAddressImport = DllStructGetData($tIMAGE_DIRECTORY_ENTRY_IMPORT, "VirtualAddress")
;~ 	Local $iSizeImport = DllStructGetData($tIMAGE_DIRECTORY_ENTRY_IMPORT, "Size")
	$pPointer += 8 ; size of $tIMAGE_DIRECTORY_ENTRY_IMPORT
	$pPointer += 24 ; skipping IMAGE_DIRECTORY_ENTRY_RESOURCE, IMAGE_DIRECTORY_ENTRY_EXCEPTION, IMAGE_DIRECTORY_ENTRY_SECURITY
	; Base Relocation Directory
	Local $tIMAGE_DIRECTORY_ENTRY_BASERELOC = DllStructCreate("dword VirtualAddress; dword Size", $pPointer)
	; Collect data
	Local $pAddressNewBaseReloc = DllStructGetData($tIMAGE_DIRECTORY_ENTRY_BASERELOC, "VirtualAddress")
	Local $iSizeBaseReloc = DllStructGetData($tIMAGE_DIRECTORY_ENTRY_BASERELOC, "Size")
	$pPointer += 8 ; size of IMAGE_DIRECTORY_ENTRY_BASERELOC
	$pPointer += 40 ; skipping IMAGE_DIRECTORY_ENTRY_DEBUG, IMAGE_DIRECTORY_ENTRY_COPYRIGHT, IMAGE_DIRECTORY_ENTRY_GLOBALPTR, IMAGE_DIRECTORY_ENTRY_TLS, IMAGE_DIRECTORY_ENTRY_LOAD_CONFIG
	$pPointer += 40 ; five more generally unused data directories
	; Load the victim
	Local $pBaseAddress = __Au3Obj_Mem_LoadLibraryEx($sSubrogor, 1) ; "lighter" loading, DONT_RESOLVE_DLL_REFERENCES
	If @error Then Return SetError(2, 0, -1) ; Couldn't load subrogor
	Local $pHeadersNew = DllStructGetPtr($tIMAGE_DOS_HEADER) ; starting address of binary image headers
	Local $iOptionalHeaderSizeOfHeaders = DllStructGetData($tIMAGE_OPTIONAL_HEADER, "SizeOfHeaders") ; the size of the MS-DOS stub, the PE header, and the section headers
	; Set proper memory protection for writting headers (PAGE_READWRITE)
	If Not __Au3Obj_Mem_VirtualProtect($pBaseAddress, $iOptionalHeaderSizeOfHeaders, 4) Then Return SetError(3, 0, -1) ; Couldn't set proper protection for headers
	; Write NEW headers
	DllStructSetData(DllStructCreate("byte[" & $iOptionalHeaderSizeOfHeaders & "]", $pBaseAddress), 1, DllStructGetData(DllStructCreate("byte[" & $iOptionalHeaderSizeOfHeaders & "]", $pHeadersNew), 1))
	; Dealing with sections. Will write them.
	Local $tIMAGE_SECTION_HEADER
	Local $iSizeOfRawData, $pPointerToRawData
	Local $iVirtualSize, $iVirtualAddress
	Local $pRelocRaw
	For $i = 1 To $iNumberOfSections
		$tIMAGE_SECTION_HEADER = DllStructCreate("char Name[8];" & _
				"dword UnionOfVirtualSizeAndPhysicalAddress;" & _
				"dword VirtualAddress;" & _
				"dword SizeOfRawData;" & _
				"dword PointerToRawData;" & _
				"dword PointerToRelocations;" & _
				"dword PointerToLinenumbers;" & _
				"word NumberOfRelocations;" & _
				"word NumberOfLinenumbers;" & _
				"dword Characteristics", _
				$pPointer)
		; Collect data
		$iSizeOfRawData = DllStructGetData($tIMAGE_SECTION_HEADER, "SizeOfRawData")
		$pPointerToRawData = $pHeadersNew + DllStructGetData($tIMAGE_SECTION_HEADER, "PointerToRawData")
		$iVirtualAddress = DllStructGetData($tIMAGE_SECTION_HEADER, "VirtualAddress")
		$iVirtualSize = DllStructGetData($tIMAGE_SECTION_HEADER, "UnionOfVirtualSizeAndPhysicalAddress")
		If $iVirtualSize And $iVirtualSize < $iSizeOfRawData Then $iSizeOfRawData = $iVirtualSize
		; Set MEM_EXECUTE_READWRITE for sections (PAGE_EXECUTE_READWRITE for all for simplicity)
		If Not __Au3Obj_Mem_VirtualProtect($pBaseAddress + $iVirtualAddress, $iVirtualSize, 64) Then
			$pPointer += 40 ; size of $tIMAGE_SECTION_HEADER structure
			ContinueLoop
		EndIf
		; Clean the space
		DllStructSetData(DllStructCreate("byte[" & $iVirtualSize & "]", $pBaseAddress + $iVirtualAddress), 1, DllStructGetData(DllStructCreate("byte[" & $iVirtualSize & "]"), 1))
		; If there is data to write, write it
		If $iSizeOfRawData Then DllStructSetData(DllStructCreate("byte[" & $iSizeOfRawData & "]", $pBaseAddress + $iVirtualAddress), 1, DllStructGetData(DllStructCreate("byte[" & $iSizeOfRawData & "]", $pPointerToRawData), 1))
		; Relocations
		If $iVirtualAddress <= $pAddressNewBaseReloc And $iVirtualAddress + $iSizeOfRawData > $pAddressNewBaseReloc Then $pRelocRaw = $pPointerToRawData + ($pAddressNewBaseReloc - $iVirtualAddress)
		; Imports
		If $iVirtualAddress <= $pAddressImport And $iVirtualAddress + $iSizeOfRawData > $pAddressImport Then __Au3Obj_Mem_FixImports($pPointerToRawData + ($pAddressImport - $iVirtualAddress), $pBaseAddress) ; fix imports in place
		; Move pointer
		$pPointer += 40 ; size of $tIMAGE_SECTION_HEADER structure
	Next
	; Fix relocations
	If $pAddressNewBaseReloc And $iSizeBaseReloc Then __Au3Obj_Mem_FixReloc($pRelocRaw, $iSizeBaseReloc, $pBaseAddress, $pOptionalHeaderImageBase, $iMagic = 523)
	; Entry point address
	Local $pEntryFunc = $pBaseAddress + $iEntryPoint
	; DllMain simulation
	__Au3Obj_PointerCall("bool", $pEntryFunc, "ptr", $pBaseAddress, "dword", 1, "ptr", 0) ; DLL_PROCESS_ATTACH
	; Get pseudo-handle
	Local $hPseudo = DllOpen($sSubrogor)
	__Au3Obj_Mem_FreeLibrary($pBaseAddress) ; decrement reference count
	Return $hPseudo
EndFunc   ;==>__Au3Obj_Mem_DllOpen

Func __Au3Obj_Mem_FixReloc($pData, $iSize, $pAddressNew, $pAddressOld, $fImageX64)
	Local $iDelta = $pAddressNew - $pAddressOld ; dislocation value
	Local $tIMAGE_BASE_RELOCATION, $iRelativeMove
	Local $iVirtualAddress, $iSizeofBlock, $iNumberOfEntries
	Local $tEnries, $iData, $tAddress
	Local $iFlag = 3 + 7 * $fImageX64 ; IMAGE_REL_BASED_HIGHLOW = 3 or IMAGE_REL_BASED_DIR64 = 10
	While $iRelativeMove < $iSize ; for all data available
		$tIMAGE_BASE_RELOCATION = DllStructCreate("dword VirtualAddress; dword SizeOfBlock", $pData + $iRelativeMove)
		$iVirtualAddress = DllStructGetData($tIMAGE_BASE_RELOCATION, "VirtualAddress")
		$iSizeofBlock = DllStructGetData($tIMAGE_BASE_RELOCATION, "SizeOfBlock")
		$iNumberOfEntries = ($iSizeofBlock - 8) / 2
		$tEnries = DllStructCreate("word[" & $iNumberOfEntries & "]", DllStructGetPtr($tIMAGE_BASE_RELOCATION) + 8)
		; Go through all entries
		For $i = 1 To $iNumberOfEntries
			$iData = DllStructGetData($tEnries, 1, $i)
			If BitShift($iData, 12) = $iFlag Then ; check type
				$tAddress = DllStructCreate("ptr", $pAddressNew + $iVirtualAddress + BitAND($iData, 0xFFF)) ; the rest of $iData is offset
				DllStructSetData($tAddress, 1, DllStructGetData($tAddress, 1) + $iDelta) ; this is what's this all about
			EndIf
		Next
		$iRelativeMove += $iSizeofBlock
	WEnd
	Return 1 ; all OK!
EndFunc   ;==>__Au3Obj_Mem_FixReloc

Func __Au3Obj_Mem_FixImports($pImportDirectory, $hInstance)
	Local $hModule, $tFuncName, $sFuncName, $pFuncAddress
	Local $tIMAGE_IMPORT_MODULE_DIRECTORY, $tModuleName
	Local $tBufferOffset2, $iBufferOffset2
	Local $iInitialOffset, $iInitialOffset2, $iOffset
	While 1
		$tIMAGE_IMPORT_MODULE_DIRECTORY = DllStructCreate("dword RVAOriginalFirstThunk;" & _
				"dword TimeDateStamp;" & _
				"dword ForwarderChain;" & _
				"dword RVAModuleName;" & _
				"dword RVAFirstThunk", _
				$pImportDirectory)
		If Not DllStructGetData($tIMAGE_IMPORT_MODULE_DIRECTORY, "RVAFirstThunk") Then ExitLoop ; the end
		$tModuleName = DllStructCreate("char Name[64]", $hInstance + DllStructGetData($tIMAGE_IMPORT_MODULE_DIRECTORY, "RVAModuleName"))
		$hModule = __Au3Obj_Mem_LoadLibraryEx(DllStructGetData($tModuleName, "Name")) ; load the module, full load
		$iInitialOffset = $hInstance + DllStructGetData($tIMAGE_IMPORT_MODULE_DIRECTORY, "RVAFirstThunk")
		$iInitialOffset2 = $hInstance + DllStructGetData($tIMAGE_IMPORT_MODULE_DIRECTORY, "RVAOriginalFirstThunk")
		If $iInitialOffset2 = $hInstance Then $iInitialOffset2 = $iInitialOffset
		$iOffset = 0 ; back to 0
		While 1
			$tBufferOffset2 = DllStructCreate("ptr", $iInitialOffset2 + $iOffset)
			$iBufferOffset2 = DllStructGetData($tBufferOffset2, 1) ; value at that address
			If Not $iBufferOffset2 Then ExitLoop ; zero value is the end
			If BitShift(BinaryMid($iBufferOffset2, $__Au3Obj_PTR_SIZE, 1), 7) Then ; MSB is set for imports by ordinal, otherwise not
				$pFuncAddress = __Au3Obj_Mem_GetAddress($hModule, BitAND($iBufferOffset2, 0xFFFFFF)) ; the rest is ordinal value
			Else
				$tFuncName = DllStructCreate("word Ordinal; char Name[64]", $hInstance + $iBufferOffset2)
				$sFuncName = DllStructGetData($tFuncName, "Name")
				$pFuncAddress = __Au3Obj_Mem_GetAddress($hModule, $sFuncName)
			EndIf
			DllStructSetData(DllStructCreate("ptr", $iInitialOffset + $iOffset), 1, $pFuncAddress) ; and this is what's this all about
			$iOffset += $__Au3Obj_PTR_SIZE ; size of $tBufferOffset2
		WEnd
		$pImportDirectory += 20 ; size of $tIMAGE_IMPORT_MODULE_DIRECTORY
	WEnd
	Return 1 ; all OK!
EndFunc   ;==>__Au3Obj_Mem_FixImports

Func __Au3Obj_Mem_Base64Decode($sData) ; Ward
	Local $bOpcode
	If $__Au3Obj_X64 Then
		$bOpcode = Binary("0x4156415541544D89CC555756534C89C34883EC20410FB64104418800418B3183FE010F84AB00000073434863D24D89C54889CE488D3C114839FE0F84A50100000FB62E4883C601E8B501000083ED2B4080FD5077E2480FBEED0FB6042884C00FBED078D3C1E20241885500EB7383FE020F841C01000031C083FE03740F4883C4205B5E5F5D415C415D415EC34863D24D89C54889CE488D3C114839FE0F84CA0000000FB62E4883C601E85301000083ED2B4080FD5077E2480FBEED0FB6042884C078D683E03F410845004983C501E964FFFFFF4863D24D89C54889CE488D3C114839FE0F84E00000000FB62E4883C601E80C01000083ED2B4080FD5077E2480FBEED0FB6042884C00FBED078D389D04D8D7501C1E20483E03041885501C1F804410845004839FE747B0FB62E4883C601E8CC00000083ED2B4080FD5077E6480FBEED0FB6042884C00FBED078D789D0C1E2064D8D6E0183E03C41885601C1F8024108064839FE0F8536FFFFFF41C7042403000000410FB6450041884424044489E84883C42029D85B5E5F5D415C415D415EC34863D24889CE4D89C6488D3C114839FE758541C7042402000000410FB60641884424044489F04883C42029D85B5E5F5D415C415D415EC341C7042401000000410FB6450041884424044489E829D8E998FEFFFF41C7042400000000410FB6450041884424044489E829D8E97CFEFFFFE8500000003EFFFFFF3F3435363738393A3B3C3DFFFFFFFEFFFFFF000102030405060708090A0B0C0D0E0F10111213141516171819FFFFFFFFFFFF1A1B1C1D1E1F202122232425262728292A2B2C2D2E2F3031323358C3")
	Else
		$bOpcode = Binary("0x5557565383EC1C8B6C243C8B5424388B5C24308B7424340FB6450488028B550083FA010F84A1000000733F8B5424388D34338954240C39F30F848B0100000FB63B83C301E8890100008D57D580FA5077E50FBED20FB6041084C00FBED078D78B44240CC1E2028810EB6B83FA020F841201000031C083FA03740A83C41C5B5E5F5DC210008B4C24388D3433894C240C39F30F84CD0000000FB63B83C301E8300100008D57D580FA5077E50FBED20FB6041084C078DA8B54240C83E03F080283C2018954240CE96CFFFFFF8B4424388D34338944240C39F30F84D00000000FB63B83C301E8EA0000008D57D580FA5077E50FBED20FB6141084D20FBEC278D78B4C240C89C283E230C1FA04C1E004081189CF83C70188410139F374750FB60383C3018844240CE8A80000000FB654240C83EA2B80FA5077E00FBED20FB6141084D20FBEC278D289C283E23CC1FA02C1E006081739F38D57018954240C8847010F8533FFFFFFC74500030000008B4C240C0FB60188450489C82B44243883C41C5B5E5F5DC210008D34338B7C243839F3758BC74500020000000FB60788450489F82B44243883C41C5B5E5F5DC210008B54240CC74500010000000FB60288450489D02B442438E9B1FEFFFFC7450000000000EB99E8500000003EFFFFFF3F3435363738393A3B3C3DFFFFFFFEFFFFFF000102030405060708090A0B0C0D0E0F10111213141516171819FFFFFFFFFFFF1A1B1C1D1E1F202122232425262728292A2B2C2D2E2F3031323358C3")
	EndIf
	Local $tCodeBuffer = DllStructCreate("byte[" & BinaryLen($bOpcode) & "]")
	DllStructSetData($tCodeBuffer, 1, $bOpcode)
	__Au3Obj_Mem_VirtualProtect(DllStructGetPtr($tCodeBuffer), DllStructGetSize($tCodeBuffer), 64)
	If @error Then Return SetError(1, 0, "")
	Local $iLen = StringLen($sData)
	Local $tOut = DllStructCreate("byte[" & $iLen & "]")
	Local $tState = DllStructCreate("byte[16]")
	Local $Call = __Au3Obj_PointerCall("int", DllStructGetPtr($tCodeBuffer), "str", $sData, "dword", $iLen, "ptr", DllStructGetPtr($tOut), "ptr", DllStructGetPtr($tState))
	If @error Then Return SetError(2, 0, "")
	Return BinaryMid(DllStructGetData($tOut, 1), 1, $Call[0])
EndFunc   ;==>__Au3Obj_Mem_Base64Decode

Func __Au3Obj_Mem_LoadLibraryEx($sModule, $iFlag = 0)
	Local $aCall = DllCall($gh_AU3Obj_kernel32dll, "handle", "LoadLibraryExW", "wstr", $sModule, "handle", 0, "dword", $iFlag)
	If @error Or Not $aCall[0] Then Return SetError(1, 0, 0)
	Return $aCall[0]
EndFunc   ;==>__Au3Obj_Mem_LoadLibraryEx

Func __Au3Obj_Mem_FreeLibrary($hModule)
	Local $aCall = DllCall($gh_AU3Obj_kernel32dll, "bool", "FreeLibrary", "handle", $hModule)
	If @error Or Not $aCall[0] Then Return SetError(1, 0, 0)
	Return 1
EndFunc   ;==>__Au3Obj_Mem_FreeLibrary

Func __Au3Obj_Mem_GetAddress($hModule, $vFuncName)
	Local $sType = "str"
	If IsNumber($vFuncName) Then $sType = "int" ; if ordinal value passed
	Local $aCall = DllCall($gh_AU3Obj_kernel32dll, "ptr", "GetProcAddress", "handle", $hModule, $sType, $vFuncName)
	If @error Or Not $aCall[0] Then Return SetError(1, 0, 0)
	Return $aCall[0]
EndFunc   ;==>__Au3Obj_Mem_GetAddress

Func __Au3Obj_Mem_VirtualProtect($pAddress, $iSize, $iProtection)
	Local $aCall = DllCall($gh_AU3Obj_kernel32dll, "bool", "VirtualProtect", "ptr", $pAddress, "dword_ptr", $iSize, "dword", $iProtection, "dword*", 0)
	If @error Or Not $aCall[0] Then Return SetError(1, 0, 0)
	Return 1
EndFunc   ;==>__Au3Obj_Mem_VirtualProtect

Func __Au3Obj_Mem_BinDll()
    Local $sData = "TVpAAAEAAAACAAAA//8AALgAAAAAAAAACgAAAAAAAAAOH7oOALQJzSG4AUzNIVdpbjMyIC5ETEwuDQokQAAAAFBFAABMAQMAmYvVTQAAAAAAAAAA4AACIwsBCgAAOgAAABgAAAAAAABbkwAAABAAAABQAAAAAAAQABAAAAACAAAFAAEAAAAAAAUAAQAAAAAAALAAAAACAAAAAAAAAgAABQAAEAAAEAAAAAAQAAAQAAAAAAAAEAAAAACQAABUAgAAVJIAAAgBAAAAoAAAcAMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAALiSAAAgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAALk1QUkVTUzEAgAAAABAAAAAqAAAAAgAAAAAAAAAAAAAAAAAA4AAA4C5NUFJFU1MyFgYAAACQAAAACAAAACwAAAAAAAAAAAAAAAAAAOAAAOAucnNyYwAAAHADAAAAoAAAAAQAAAA0AAAAAAAAAAAAAAAAAABAAADAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAdjIuMTcIAJopAABVAIvs/3UIagj/ABVYUAAQUP8VSlQM0DXMQgAsBgXIUoPsIIPk8NkAwNlUJBjffCQCEN9sJBCLFrAIQEQCUQhMx+MNkF4oneeRzUECsMhAEhgPAAAAABgY/P///zcIAg3ABBSD0gDraCw65DLYLqMNsI5EARH3wipRh5sNwUWCYRDJw1aLAPGDJgCDZhgAFI1GCBUAgBUAi8ZIXi6xaEAOB1DoQBPOkDVojGD1D1JBqANew4sBwwGNQQjDi0EYZxAAi0UIiUEYXcIFBACLQRwgxgESgBhgdbWY33iHIGA26ANAdyBIaiAIWP8AZokG/xVBiByQeATx5cVF" & _
            "gC4wGIwQ9V/BGw8DhFUBbAT/FQQ+ADCTrCYApHUvDvAAGXyfvYAcRYDO6P//zxOJBriTAABXEIRUAjBKDQacHIEJjUYYUMcGCDxRABAdMItGCECL9QBRCINmCABAXg1CVot1DFczAckzwGaJTfQGAECuRpDV2Ac/AyCdWAR/XGQPAAAADJBYpG92DFDkD2A0f3pcBABOQCAAcFxkDgoz6jDgDmBEtwGsCHACPiM9f0oHwLDYBJEYgCtwAAQAuA5xAsAh9gJAMAP85ZUszAB8EGMTjUgYUf9wDAj/cAxRE3kQi00AFIkBM8mFwA8BlMGLwV3CELNAImoAVkahFmA19wHYG8BAXcIIRA8AAaEmQKQEALgB4B8AVLMOgPDvRLAIYkRwAOCM/hgAYAJglR4zA3wZmDZhhkIAkBiT2BdEsFg0wJBoxLBYJAKBAA4UiUYU0xGlY2Fwo2TYFSLew3AVFPALQmXVKQBcFIAxFvMLAQpSB11RdQiLBlYi/1DMAJEI0xXRBd4Vww45AwODIAAzUcDjQFNlE0YYV2mzJIs9aRP/123jVfwN//+LHV8TTJGYBqEwvWjEoacMbh/QUewGNJFoxCEmIGKqKf0C6/tiMhQAIgZfMl5bhxBZAP82ajITAJyVaJBoRFAaAPhA8p9EsBhEsAhQhbADPYewmCCwSBCYSBDZIDEF2FoQP/N/bMAiBQAAkeMHYeexCDgfwIFbuE3nsEixjH5rCVMPMEc7AX4QcuKNXgwsICBCAACw2FNO0QhghAL1f91ohMSrIDgK0BWwB7gPu2iXAVJov2egMf8zDoO8B7BtUoUxIDDIjgEwtag8GB5gdQXxUCjMA/bCAg8ghbkQwvBAOCKAAADQw9cVUNe2SFDHMeiHgAMoB4AbAEYEM9uDOP0AD5TDM8CF2w8AlcCL+IsGwecABAPHD7cIg/kAFXQZg/kUdBQAg/kadBuD+RMAdBaD+QN0EekA6wUAAGoTagBUUL0DrL0TNnxCCQwQDE4wYAz1T1fgg5Ce" & _
            "YGAOeuYBGASAMIiHAPBACERrAoPAOItNHAH/MVDrbT15PKDxUFjYTEBkkUSChLO+/QUzRPAFEfBQuIQHA4sGLUAeLRA3ABgadCAtEDcAA3QWALgFAAKA6UoMpDfABu8VdSCnODPAl0DSs4cbXakEuKAOSBu40FjUOGAH8x9SgeoEhcB1OU0Ak1UJaBDHAmaJsQZZGZAmkBgUd8ChloAFYZYYFF3AkQiHAT1TgyekSDBojGJFs86YDxNigFAOAJVeZfARgUcSEtlgpI8BAYPAWOvhPXcwIeCy2Icw+AcTi4wwsFgHEqa3pXFHgnwA00OQ/tAUgc9fR8VUCIJBBlhk0QcCdEVGDVhqKGaJDAfo+PjlBJkDE/8AdiCLyP92HP8EdhhW6M4hA+sCDDPAiUd5R6Ays02wM/zA+GAvCIsAfhBHO8cPjQCAHOHHsMhzmNgXgGC2s/xQeIQHtL8jPhDyO8A9S/GMDrb+PUANCTleCA8ohMgmo20CSA+EQl/HAkgPhbMoUbfEUa4wiA8IgThgBELWDJDLAAIwp8AxYJaD8FCYoQVrEisVoJsR+PsCByKwRYGUvEWgNjCgMAO8JVKYHEaQ2ARyRmZGsINBtzDVQptTFATyQtZIdIMANSYgSiucQJD+pJA1MKC01Q5QWHoBDnIB0mgMAheAAnV/D1ALAIsR+YvHkRqD4ALEIWQwAG4wCAyRFS9QCPTfHjAAvEhkjABtpAA8BAQ0998b/wKD5/6DxwJVAokARfQD/o1F8FeG4QEg6RQI2QY5KymW7QT/NsEBK2UD9SX/jCIH8Iw+nSEhCSCJRmAkngDZLbCIhTBYBsAO0DgkkFiEDtBYhA6lFqDGAPFfgWkUEE0MUVAQiUX49WpThdt+EUaLw1UCx0X0OQMAAIld/Itd9IlMRboAMTDshVBRAACLA00YjUQI8IEBYAPYyTHYhgExOAwR8N/EX/f8X5cFANi1segFtliEfxxiBJYcAJBevhB46ZUXeCOZJVCC1EqRgtOHDhXVR+kC"
    $sData &= "hqV1i/i4ga0VZjkHD4US0RdWd9GXANEXBn0GWfUCCASDOP91I5F8Zol1HpIUYeAADRCUqglh0EXDVid7AEwByQSxFiUJ1J4AFaGiGaFfIBh+TbeoYbDYkw9RFHRQFHONHXkGZDapAlkHi3YYAIl19IP+/3Un4J1xShNRGjHYBy9g9Rx9UaSUXtOi0BrQekBUYUlEEEBAp4DrUBwVkNMF8kB4ry/MACZNCMkh6YdeBNHezFCdQpGDH8Ofg6+An4Mvgp+DMZwFkIPGP2gGhgzaDwAEk3KiNmCWaITigmVFAViBIgklxhIxKNAHApDoBZZXQBfX0CDidFBZkv9OCBEBgZUm/f/9fwUD4QMY6wW4GCHMAMnCJOxSHGTvAN4OAeLtAGoSwYBrWDoChX4uo9YAvgTxQGjuIOCDyP9yHLN4HLNurzYhuBGPHtVSELCIPbj/7zeSACBwtciDWfjv/gDPoO4PcmXoMFONTgzofznGAyAaIToeVl4RC0ILGSBI8IUHdDNYZTaIA+BHV7J4xDC1iMMBKxTxAGBQO8EAuwWyvpAS0PjEgI5DppEI4SUhM9s2E3C1CNYTU2EnMYleBIleAwiJXgyJXiyghAEAKFCJXhiJXhwDiV4giV4k/hHlIlFBWBSgBoIuKG+NAAA7w3QLi8jon8qdLbYI8D9VHOBNA2pTAiDwDgJoWAIawAJVP70IV8IasJwj8OWaAZxmEhIVlRNPI8UA7gGQ8yUBYddXFoAeXxbDAFgWlFiEsD6Q2AWE0DXCv8iAmNi0hu8UIJUDULUhi0DgCiD/QGFLEECRuwEkGRJAEboSDxQtEo0WNTL/RfyNCQA7RxByg4tHGIDdAA7/dyCLzv8CdxxQ6HEDtULJkXE2UVH+HvdQaKkwEEQ94RkAdH0xDYNlQPyNA34QQE/HRVH4QgMAIJoBdE5T4hgBXI9UblGH0+iFMsVY+tNYhJ/UGLhllgg1wDxWebtPdbRb9XYZ1WJTtdGz8JUiUFWRAG4Scr1BtQEQ/zZocOIN" & _
            "Bt1q7iPBcQxgIwH/pcohgiGZAGiEhLpAKJZ2FrHODQeccB9gVxHrWb9wQAv3AVoUsS4KB2XIcB9ghBHrhXAADqdiDnBiTxHpeg/iC4Hmx8/3ARIVwUc1HHEsvhYQkDKIb5kBLUkCuAYeBAHGRwgtLWogi/noNJfvghSTqgafqmCvdhdQPVB/YYMSzpUnUTd5N1cMJMDPBFbxCtEqNiSVGgUkFAVPIBAFNNgXdcCnkAZTlBEEEwmbBjuYR8AAcBzAX8BQlwDuJBLCLOL/IU0Ii0EIf0BSGuCSIrImgQtOKSN8IpVGaEjo0DvNmTSQTiGx2kOCxfcBm3yIxqexNUqafLAuBwd8cB+QqQoXVXBACfcBmHCBowoHsHAfcAkXG3AA/AqnDXBiWZaiZAApFoEpgBEjDIP5nHUQ9gJFGAJ1ELh+DhIYRCGnAUUYAevuOioAWUVgxKC3EXQPg/lVm0IMAIEYf4hwBR5LLmkAOVjODpCc9yHRcbKOH3FQ46DJAcdGUgwBIJNexwwJAHVBZQg5UlnIYIkFO8NVBUaCVUVqaOhD7ZIBk9CZb9DSoNpBfOQvAAwVQACadWGLfRyLdwAIg/4CdAmD/ggDD4VIAREHi84AA8kz0maDfMgA8AiNTv4PlcKAPLBtNsiDjPAQUDm8MP1Q+MIJgBIa4D9Ql2CWgwSAQDegJpC1aB0QNSD9TweNzgBA+HozgUSw3jeYL5FZ5+TVEEgI7h5AGIRej5E/8HD4XZVBALEYPACcCSAMDxoiwI0mAXYEi1wIwugz/5RQJ7AIoL/oRHA19U9HIIyPzgqRL4ZZt/eSBOAwApIV4CkQi+4BkQBAlMkSTgRTUgGAxq0aX3HFfJexkgXlEV+HofIQdUq54B0AnTKJACN1Oh0CUYvWndIuBRKwjjSYb1l3VBbUbC4D1hOxzhMXgwMIOBHQsoiHcIVGXoaadGCOIusSrRLojM0M3YEozg/U5fxAagaSgYBQ3UJzEKFm01I2gqDyAwwACGpoxwapHeg76+AZ" & _
            "Px33A5o/sRg8iAQB8D+TnIiQiESQkohEAQzqP2JE4P6ThO4+IPFvx0Aj/3ZTCFSTRQ9BBBY3A8yThj6PoKpu6ENGBIo+aQAAyCEQWjOU45MLL7DYhQAwk2yWs/BAGAtaaTEcRbBT92A2CIAnAEA3cLReEJhhkAgR1EiwBAYAAHXhhcl0AUeSViNAOEgLjUHiPKCmJFASk+jTEuPREjE1B+WsAyUxhECgpVMCtXEk/OmEsOgkeAMIiUAIHDADPPNvliMRQGcDGk4MmQcBETt1Fr0HiRwBPADQSBQgsOiEkEhAoDAoTMADR40gBD+MgABQJ70+NmBZBBoVtBgEoUlkjkPFakEgBBYEQCA9ZGY8XEcyGHCQYwRDV6FqAwFG6SBgEBS1B1TCBLLeZM/DPHUe0FT3AF0SPbduTCgCIzAAdBAqBwGE0a1xEJAQEY/gYRCKPUih2IOIGj+VGEQTGxTIDjDo5xAzwFBQaCThWARAjQoOEaX2/28HxCo9EgxaD1HIFIozQPOfUoFQbpHcbNWHICwAhL0XjXRH/qpIoFJHoDMDfKWmiBToBkkz8SZNFAo0oKbiIRMTuP//xiURQGc9AE4EYDKUqPABEMfdEFUH60EbkRcPdBKLxx0HFzp0E0UHT0UnkisQUAIAAdBI89RoJICBBjYl3wQRLTPbWVRDHR0FWRMYgiMw6Ffir9IPUJdi8QH+CfEAKEb+DWGq1kOBsW4omxqukxoWlpATYAYAiwnC6cwX5g4zYx8tAMCQU4fg9/BPA3QbqGKUtVOHwFcXr94xOQUcRMFBGBxkxMEhg8QUcRXuCBIlFuVZIeYN8V+BLjEi+BGLVfxOF9VYxB9VkG0KBYRE60My1gVQxG9vAijrEVQC26+yg7xRAHyPfY/NXt0aShBQ9A8VFdXNoX4DQLjkU6BY9L+OYIkG6CpZAMnGRYM6/KaoBYY6BmbuGcD6DsC1rJ9BnBCE+hHIqJSNCkAJaJDdxZBdxIDL+gTMWfAJZQ0BFhF0KgOLwVeDfQze"
    $sData &= "E5CDIMBSB6Hmsq41BTgALnUGaixfZokEOEKNBFGhKNpfwBpK5DUwjUgBO04IIHZGNlGgRtBIBKBsEUCGAKNZbsIC+N5HkANgRGDnsOiwyAAQmMhwCLRjRAAjJy+FRAkAWY1MAAoCiT6JLhzhoIMEiQQUgf9GBEJOFTXDAIxTBOG8FOpIc2yAx1amoCUAHk4g4QSJRjSsAjpwpd8BjdZJ4blCCIsEXQyDZQgSH4DxIGBbRDFYRoECOIAogDGVaMST2AXuNAACBuI7BfyJVRiNIgRT5kPCV+fQx5CIgNBINCXdAgjrZACD+Qp0BWaFyTB1WnkC4QoI6Mfk0M4IIzgS3uYMkFgEsY5AMFgGIYkhTRDoNSAVlhiDAmkoQoESOFYW1SrGKaGDEotFGAX/RRSNRGovwaCYBEBCDQE7VfwPhnPP+hTgLEIUABZM1SthwyI2InKrwWTy9QAaTLqVB2HBFCUznYoUMeinLwB2A6bHADQeCmLxXwEBJzhwICwE/z4VFLpY4ZRA6kugrSAuLHGHAbGuoW4CDi4Ci85RHSTg4JJOZizw5+CCxg4uQu7QQrAiyQEXHCI38V+31KDDgusnPQbwTijh0GLNNYIOLea11YoQcWPV51Jp9gL9GSpJ8R/tCp3eOKztAYoe4YkBACBSUvBdW/xLHdhJ/x/Y9L/CXdZYC/8f4PDfQP8MjAIAOEF/gY5CkFjF/92GnwF/EIWfAcqXAdRdhJ8BvzAyA2wbAzhdDBkOuQ34DU6yMZvgoM0QxS0QV4kwXjilDZIeAKJGgb4jFS7scdEcohYBFcPV7WdevmJ6Uq5fy7nh+vUBbg0B0fB/g4YRE6CbcREiI4LGLeMAGl6DoesUg348AAB0E4sHiUZA4xEdeToNC9z/N3UAjRqTKitVl+w+IuvE9ljkPgIA7EyD4gFWdQaE/iNBhxKY3wZRBzIrIIUTNgxhHRBAGIYCIFEFMA8wzlbSPJCDxVMHkLCzzAexgwRR0LdgtjOtUUIKAhwCku4AGlAMixSK" & _
            "gP0Ai0kIAwqJVQTYi9GB4gIiAJgI0ASdV6A0qOwPJ4QLjkKCG/9ACI0AQf+ZK8KL8Fck0f7iF7JorH4xddyH3gUj/v3/b8YEyhfDNqpgkwwmDGAPAAsm+KpgAAG2l2DCD/YAfoBgsFgHnVhE3ghi5O8zAsQUiX3UEYlF4DYw4TiQ0C8BAl5SIZFXgDSITOAP9EAYbucEi00A2Dk5dWKLdeCNtiJxMGBvkAF2JBHPBhj/dPCuDiR3FAeLRGDwlkegYgH8i/PB5gwEjTwGGhWQeTFQx0YeTiB6MNhKClA+UQQuQQeD1DQQjS8aFQEI6yvoZYEGi8iLDsYrReBcoicGBk/ADix+MIEA66aLCQPABo1EwfBQNQCiQ7EI0QS/CAh17I1ESEieFoCjQgkPhRe0xhfRpFcBwhYRYEEhi1UA8FlZaipZD7dIwGYScHWVBWCWqBDszkTFAU30DQBAKjkhRYAIBh4pgI8gQwVmAIN97ACJTfAPIIQEISPsZoP5EQB1N2oB6DPe/0n/vkoAkBUCQNfgBAKg/gRB2pSw/qAWoUYDYNUXkAahqJwETewEiAHpZiU2O5G/cFRn6gHo9t3wKHEA8FLE2+CQfi/iEgQL/Ifz8GvGBVDBDgJ1IgxqAui67BkO9dEhGA6AoyawbsIJEip1OZwgyfkC4YEREC1qEoFwZq5y0SWQmBhWNJEJQIA+hf8CXZkQFDdqE5kgAx0DBOhRK5wvoMkZD2oDmXDQlTCRcAyRABDo7tz0jgBQaJN20f/A3mWULsZlwikURmEQlEACFQ8rhLYkQxAOIssO4eBU1+EwBOFw2eEARewo2RjhUAXwgIBeVwn/Ah4e8FIAf93wctQNbx51YF0H5jRRqcGxrqKmQQesZSEAE4uBISBqAVaJdezqBTKwfnBcxI6iKgD+BXAQAIDuv21vEl0JViJhCgRWNiJQx24jUs1SHyh1U5XwISyVMAIA6GeYlRBdAIvw0KCREmFQFAh1SmEQBQEA6yWxVcAQVWBJMAW+MEEA" & _
            "wXygZyZFzI1FzGZlIagWAjyY6YQpPSAaGA+Eu6UMkRsldRWwWQQe5QBZVHUcahQi6y9sYVInxAYCx2yEBll0FclE3gnRdRKQGEWw3qRWEXwoay0V7I4r4gED6zEhEAkYD4V9vQDxBrXa/1//ViaQEAqinwJxOAkCVnEQZ+CTUg480RyQyJNpswQEiQSZ6YvZAWg0teIIOlYBkEr/wRNk1tIRIBxkjyC5Bmoe62dEgEYFVA06Vw0vwhRodpvtHWgcCvGhIAD2AeHnI5kFd6PhApjiJZBIgxkuUhGxBVURWlQRUnNfwYUOhQCY3m5CkNUIEAiQvkuCrHwQPgZSRC9REDxYdAcEagjrD24GYGgQsgVw8HBLEAzloTLQYE8AIFm5oiqyE/xAeM3q/ARm8oFAKP8UMREPhUDLujyCkNjEPogfsVCXIttAD7cH0gUQ3xdVLuE7QOIrgJDuVydgMIgfUYdC+wpqBYHICGsFdR6ID9Dv0e1li1gEiC/gBxDZiKYJB67lSgGA+QBZGulijKXIuLDBEndIoIkAVoP4Azx1fhk37fECNBAmgaBYUMSenneSAyHhCQTFEmnhrgHs6UtIMuGIFELsIXMEdQjbcPCrCicFMMMJIxVGRYCPQPFQmB9JUcSeyZgYVPBQ6FoVsgLQ3QWEnhGfUNFdhB4V5dwnYKgC6PiJEk1BZDtSHXyQFiRAtk9kN0G2TXtkUYWSH0OmpmSh2iIzQLbSzFdRNUExUkeCB+jI1vISUETQYMWwThEjL9C2QRO2ATFIgmmJAdBDM/8A/03gg33g/w8Qj/32fhNQhJ3YFwat3xhNAzk4dGb+GmDpFSEYU2UKasooYakBdUj0xltQRy5uFnX4UzHoUTUDKkSAewIobAFfDcIW4EsSeinCGqRsiQEF/0gIi8akQ2CeEUDUnmgyYL/IBY8/8HBLBA8/Fb3TCkDevCB4Bt42kpXlSAMcdUREXn/RWATOANBQX1MuG9AlcQPVDRZeoZUIvYAY/3XcxSA5IeuHORJ9"
    $sData &= "0HQqAMBRYSoRgwR9HB50BxjxUTfh8HBr/QdF1GwhJxQgRbR6HpTjx0MHI7DoPLONHtIIsKNxXBcjZiWN8AMv8RIBwaIyIHwBi14Y6FICLQAQDC6w2Mfd2IRCG1UWc+WLA/914FJQPl+Ap7MSZcixAMSBTl9wpMaQ2Ees2lZdGOZ2Aa/aVkZN4JkoFDQAMLOd2AWe08Ut8eCo6rcEM/ZaLtAIQ2SgvBlyGEO/2AQe6QwASKk2FvFAyGwGAEo1KHKLjApRrDFFAwXlBwDqFmamygeEgficoBEDmQoifqHfBPgQDwyUwgvKbkOgUAZMDhAIigliIIDIZIGhkZ7hEj9hFwAdmhpBxGbggASiT1ApUAmab2CWWEDkgJH+gTgCqoQhiChmiwDr4UQg4UPnTgHxClykBifIORBCV04BDA+F440twOkAkFCEkdiE/cBzm1AflR7FBPEKHnVkYxEAYgVC5EAVi0AACFNTav9QU1MWiUXYypCjZeAAHh9oxzQtgCDMif0HxgmBPdU05UUGddBCiKVdBNBVEcfyJdMWMoj/oasHnaCeZQIIHOkNLAAAqQD+JmagWwINMx1BZIISuQpVJhiJ+QOLQE0LyRIcsclSFDVzkEewno0GdBU1I0UPgJRtYRPZXFUGuWMFaNaNFt1oyOVhmgRFuQHNw7CSPiadFcAIH4xf8E/HCMuzjIMgtxixtetoXCAvAWBF5jdAAiV1F2oDxB1JFWDpEi34YlJHR+C7Ae0W9hFworIVVRgnagkuC8BkEUqQhqJhCebZMrUQkjpQxC8cGSKhU/REzmLp4GECcJAJ0PSQgoSvkxFcNRAIWbkWpEUwANX2CYDR1fYa6zi3JhnBEQgTB/LvAgmkVDEydqFCALUM/zSIEX3uHQH2L+8ATihgDLFTxO3xwLilwhnGA6GsA4kd9yVFHD0ddCYxGBUxCAsBi0W8LJApIRmlCgRQDOm6L+Jxks417AIAfgFA7VGHVY7TKUMNHJkizJliHJmCmdC3mSIcdhNQKcFc" & _
            "KeGhQRUAYFaZABJDU4eQte6CmAfxUacRphXwXzfEGykXhLDeoDIg7RHmWn3iNSAxFf91dgFg7CdFE/CNfnZkUAfi6Ac2cuR10DHkJBEVtOM88AW2MrDFqlsDJCAA5EADSiOw/SzoKjQHi8jpqdo0MPMCPGxPBsVUaM0VVKAqA6BgwApGCIvIXelmt2TivXroDYoD0A6A/iTYjZCV5YBEekPSU1AV8W8jJv5UZJswsl9C+gI6YUFqXDjsQBZcpIaEztETpLACrz0QyBURZV4kYX8DVUCUsGLvTDkXlEFBGSkQvazxaRoUrGLqNiI5kAxL++JwIZIT4nDjBzfmRkNBArZGNE4CCkeRF2CFDqVsAY6oRWRVWAAxY68qGP8VQhjdFfg7/nWOrLAO9dMTYJYIkVPHUEcgsWNMRyKYBwFW19YO0R1BQQQSPCDRCD0SdFaFIRY2EApAYbQAi8aNSlo2yM4g7BNurcGgZgTzxQF5ECpUEidRAQElAQ7AsQVmR7IOPlhGDxCwiGDVWEUvFXXyLcwBYMCgWQTCVMAo6gABIiH33iJUAD1SRJ97cCwMNbHQMsDrNgKAC5ESs8gAkQFBT4X2Bj/g9VMIgX0Ircp1UAcTiNDH8O4LAidWagz1/xUkIiCRJtBYFIAApSaChkClbyJvIFSAARxeZGP/WuJeo+969pUwPEdC/RwMEBEmgJYEoHsTFSjWDoEu4OoqgPEMCAh0BWoKWIIWtTBjn1MDLe0HdkYetRM0tUgs4K10ESRGO3QiJy4yIV5dAsNmiwR1AESwDjRvDkSLBo1NCFEnaFCiYWD1LyESdnQQFhGwCP8fBbL+gUddQHg2gSd6kgAYFNIngobQBVBiAuNpGDldDA11EFe+5mKhWwulALDxtV6hTRE5JvRqESRzFun1ACoV0TlAEFPyQKhbGK5IhO/sQcdIQBjqlEIQ8uBosBhqBGiIYiSgo0bQhxA4KWEZlwkgCM6qE5FoU7eRbKHNOzFYCPAiTtBOYkgEAlLAANBYtYXf" & _
            "gsDvIhlcgRFx2FmGsDNfB12I0lgFbyDVWAUuJVgGeQC8AIt18DldEHVeyeESLm6w3pq2sLSscTQ1n1P6T9C0VJkUwG+kOVF1xr0A0BLQWERvlCEcagFT2RKNDCEzhWTIjgtgLgDoUDIaQp+1HtXZ76EcBfJAaAQHcVOCBRDekMaUfkUjJCZCg5YsYHU1sw0HFXsILQBhAT5201NE3VPhlgba9hfRTciqCRiRhL+RNJTxkfQGJoIhAAABAVbonokB3NYYYE4a/ToXULYg5ALoSoKtAVaL+OhCHKCGRGR3Ceg4JLAIrzYFYdcSLCwwSCw4A7aYEEcedqC6Bd4f8V/B5AgQITVIOiwzhPb/p0wmpDECREiABtoTcPVPZs0LFIBGTTPrKByNRdQNABLBEIdEuOGo9ifppDiCWuKRIL4ugVaETTyLdeixDuwFBO8AYCgAeACEB3JC4KgwkmYVkJWV04VA5+cIAohaflCAi6spCmoKMwjSWffxmpCQ2IURKMAAO8N2TL8D9QOCyRj/Nv8VPPYe0ceBUGeTN6NqEIFjdSFYaupDgOPqIKprgLFTJMEhdwwbCVPoQUMIFjaLPTAccf1/Ykfg1gld8KEBMSFKTwSRlS5aJYDThVGX1uBGEFoFAI8L6wkoIsRiWDD7D4T+AsaAZkefK6LoJvEADCjgwhXpIC82uQFN9FFoMIJJF03EUf/QsQThKjP2VRBCfgMikANCpptR8xKKEEHg2gloQFNQoCbgtZ5BZWzVEEDwpgRgP2juP2iM6mQB9I0b+I0L1FJTwWYFYRIAdTvzdGNNLBSNVRjlC1Feu1CXBODkRFfgRMexrkSjCRZwFH4VoCFGDFHGHKAiAv8VcKYPQvYCdP7GGKSUC20dOlVQ2xYPABLpL0E35iQwL1IFaC59AGEs8XkG9ipQLWGWBfjrQokMKpPH3T0sdRz45V0crWSQR0YS4Sz2DIJvpTA02FdSX2ClIMNmoIIBABRl1AtLRVJORUwAMzIuZGxsAGwBc3RyY3B5"
    $sData &= "VyACwFbmdgVwVEYHACX3NhZERiYHUDY3B3CVRlYGMIQWJkf11lQHwEaXJpRHVwYAYCRXVsaUJiaXECaXB0BlVG+oRQDA9BZGxkdFeABXAEZsdXNoRgBpbGVCdWZmZUNyTQByaXRlQBELETBFR4YU5kYGAwBDb21wYXJlUwJ0cmluZ1cVkFcCAENsb3NlnEQFUCbXluYWRlcW3BnRGDHFVlYG1wIRUISXRjf0RgZmGENyZZiXJtL0RhZSx9YO4hTWVpYtQzEWRscmQlEAcnkQVHlwXIBUFgYXnCkBIkFsbG9jYVPEJQBMAQBAWa3wxoZUFkI09NYbCJCUREBkJPfWliIDMBTDNMUz/HCWRMQKAEluaXRpYWxpR3rVElVuaTjIWuwV9JYRUeVWN1dWB0SQVjZXhFcTIVUH5EYOZ09iamVjDnRUYWIJFMEieRJNAm9uaWtlcvxAJRA2t9ZU1lYjMgT0RjhJbnN0YW4EY2UAAERGAfDEhFAUVEUVIhRQEAAQcAsQMAoQoAsQEKALELAbEAAgCRBABRCAAAAQkAAQIAAQoAQAEJABEDABEADwABCgARAQAQAQgAEQcAEQwAAAEHAAENAHEABoNQsKAAEzAAESAAEBRwABPQABQIj4EBBgAxBQARZgEQgifTKFxHQVRAOV1AzSKkDVNEBnA0XTewGgiBCLeAQLAP9QdDWLUAiLADAD8Cvyi96LAkgQK8t0I6pdMAAgP+C/ArwivQAAzRosfgCNLgdgvwC9IE2HMACgnbKwcy9Hji5wuQMAgFWgWg0AgPARAGQQAMSAFTAAoABc99ZiKwoAAIA4TXVli3gAPAP4K8Bmi0cAFAP4g8c/6NbA1FC3BYAeyAMAILAATOeDPo8FVgJpcnR1YWwBBnTRsQQGbnBINyBQVHZRIIB3tYj9D40DEACwYIgHiEcoWBBQVFBU8D+NtQji32rTBXQ9A/hWgUUgi9isCsCw6kEA8V9nTwJ04TwgAnYETlbrCSEBrRhOxgbCJtAGsioDDMwI" & _
            "hFBnv36NfkZIBF+Bx+7yAwCbDqGK6+FlAKth6RSiujjg4jEaJTdG1QMlYDsUAPD/mgO1EQAQZwYmABCuEhpHwABgqAwwyACmDPAF8AUAQAZQBmAGECYAUAfABkDHA1+IkgHwBeBEBXcARSwAblzQph0gZCEGcCEHkEYMZ3RAOlwTBccPcgzQBjDHpUZlVCAH8MYAXVBfvCxQRgm1kA1QpAEHYDfWAWA8AWzq1gbSDDfUykhBzHBGIfUQeWwC4jHRK8PqAQAhBsgCBScAEFwfABoQ4RRqu1AgoNYBMHbdDgAQQzUhYTTg2AAAQBTUJkAG0EQDdABWaDUBZEwGVRdUJEFXXQrCNUQ1InRUUFcFot4qwVb1c1KU0MYGdt0cUAfR1hFQAgEQflIHJNhSbyATAgARwgCJVCTNNTosIMQAJiK+/TVw9SBlUwBXFQMwd7U0ClAPwLNj5SBj1QAZAAB47QP9E9ou/XNB/izw9QIAMUYOGGkAOszEciAAL6rNAnX9IkkUMNMugHdcBMIUZQBTJFB+0RrRAwLgVQcAQBHcMcUEvPUXdCTQNNE4URZBxBbEZk8BQ2xhc3PuFAPIBExvbC4gWW8AdSBmb3VuZCAAdGhlIGVhc3QAZXItZWdnLiB7DZrTUBDQaNubkdYr0JjRRkcFTodxV5wIEGREoFteQdZD5mcDNQNvBQZnu0yaRgRlFUQFQAktsH1shao8UQHdFFEBi9YPsOZWi8ISYSzC1pTEWOrNlT2WJIXWDUzWDVDHTQ0dUGYlIQ0THXI2AOvaL9ATRjN2NSJpFSGs8c82HXIAwV8A0TnXQdkY4U1SjDHXw1JpARA0KaZLAm/lKCzX1OHGI3m2bW1ulSAsA+D4DwAB3E8zQhXGU4K9ARA8pQBEgDwFOFL9d+C0AQDh2oIAsOJyTGzGEgD/74gQAbBAAAIAVBIEMEEgAwTAAEBBAVDhKQQFPOABgPdhmQVsRxA0MwGQME0AAEFgLAX4VYZjwABV3AwAzQDADEDLAFWoDMDJ" & _
            "AJAMQMgAVXwMwMYAYAwAxQBVRAxAwwAkDMDBAFUQDEDAAPzGZsDOAFXgDADNALwMwMoAVZwMgMgAdAwAxgBXUAzAwwAsDGAwMgD/n+EBEEThAOIwYMEDQOghA0QE4sEAMACFZQSpREICIKKqM6BmNgAKMIDDAeUhoQQK4IE0YEknJAYGoOKsxSElo2INwINCggKnoQcPSCNeMgUuDMROAAwD6HAcQBRmIEQ6AAA0oG4HBAREEvgFgpCqxAADAkYDFAM0agADIiAm4gOoRAAsSFZYWFZYAwCgOlIDVG46HggDfHp8COAIJwqAh18gykMhpwKgaAso7KxkIQmgh8WDhMTjIgQg42Cuq8SD5AGgxOOCRSQjzwEAxGFk5ISkwwEgzzHgx1HA5QvAwsHBIzZgJwsgNkCFxMiI4QtABcSDb6VCIQFgQ3FgIqwCCwng4eAgqYNBQgKA4kPmwmLiAQIAgkIyIGChggnCocICxAwmChwAJDYKNJJEMhAAXhYeDhYcQCICLLQ0JVYIADKQBctBcByDQzOIHPMP8AlScP/f2AD//4tF2Il90MdF4AQAAAA5OHRmi8joZRUAAIsYU2oI62r/dQyLdQj/dfSLzv915P91/P91+FPoURgAAP9OCLgngAKA6Q0wAAC+J4ACgP91DItNCP919P915P91/P91+FMAAAAAlYvVTQAAAAB4kAAAAQAAABQAAAAUAAAAKJAAAImQAAApkgAAqkAAAIBAAADCQAAAokMAACZFAABKQAAANEAAAB5AAAB1QQAA2kAAAABBAADBQgAA0UIAAGdAAACBQgAA2EEAAJhAAADhQgAAR0IAACxBAABBdXRvSXRPYmplY3QuZGxsANmQAADhkAAA65AAAPeQAAAQkQAAK5EAAD2RAABQkQAAaJEAAHyRAACQkQAAppEAALWRAADFkQAA0JEAAOCRAADvkQAA/JEAAAeSAAAYkgAAQWRkRW51bQBBZGRNZXRob2QAQWRkUHJvcGVydHkAQXV0b0l0T2Jq"
    $sData &= "ZWN0Q3JlYXRlT2JqZWN0AEF1dG9JdE9iamVjdENyZWF0ZU9iamVjdEV4AENsb25lQXV0b0l0T2JqZWN0AENyZWF0ZUF1dG9JdE9iamVjdABDcmVhdGVBdXRvSXRPYmplY3RDbGFzcwBDcmVhdGVEbGxDYWxsT2JqZWN0AENyZWF0ZVdyYXBwZXJPYmplY3QAQ3JlYXRlV3JhcHBlck9iamVjdEV4AElVbmtub3duQWRkUmVmAElVbmtub3duUmVsZWFzZQBJbml0aWFsaXplAE1lbW9yeUNhbGxFbnRyeQBSZWdpc3Rlck9iamVjdABSZW1vdmVNZW1iZXIAUmV0dXJuVGhpcwBVblJlZ2lzdGVyT2JqZWN0AFdyYXBwZXJBZGRNZXRob2QAAAABAAIAAwAEAAUABgAHAAgACQAKAAsADAANAA4ADwAQABEAEgATAAAAALiSAAAAAAAAAAAAAAyTAAC4kgAAxJIAAAAAAAAAAAAAGZMAAMSSAADMkgAAAAAAAAAAAAAykwAAzJIAANSSAAAAAAAAAAAAAD+TAADUkgAAAAAAAAAAAAAAAAAAAAAAAAAAAADokgAA+5IAAAAAAAAjkwAAAAAAAAUBAIAAAAAAS5MAAAAAAAAAAAAAAAAAAAAAAAAAAEdldE1vZHVsZUhhbmRsZUEAAABHZXRQcm9jQWRkcmVzcwBLRVJORUwzMi5ETEwAb2xlMzIuZGxsAAAAQ29Jbml0aWFsaXplAE9MRUFVVDMyLmRsbABTSExXQVBJLmRsbAAAAFN0clRvSW50NjRFeFcAYOgAAAAAWAWfAgAAizAD8CvAi/5mrcHgDIvIUK0ryAPxi8hXUUmKRDkGiAQxdfaL1ovP6FwAAABeWivAiQQytBAr0CvJO8pzJovZrEEk/jzodfJDg8EErQvAeAY7wnPl6wYDw3jfA8Irw4lG/OvW6AAAAABfgceM////sOmquJsCAACr6AAAAABYBRwCAADpDAIAAFWL7IPsFIoCVjP2Rjl1CIlN" & _
            "8IgBiXX4xkX/AA+G4wEAAFNXgH3/AIoMMnQMikQyAcDpBMDgBArIRoNl9ACITf4PtkX/i30IK/g79w+DoAEAAITJD4kXAQAAgH3/AIscMnQDwesEgeP//w8ARoF9+IEIAACL+3Mg0e/2wwF0FIHn/wcAAAPwgceBAAAAgHX/AetLg+d/60WD4wPB7wKD6wB0N0t0J0t0FUt1MoHn//8DAI10MAGBx0FEAADrz4Hn/z8AAIHHQQQAAEbrEYHn/wMAAAPwg8dB67OD5z9HgH3/AHQJD7ccMsHrBOsMM9tmixwygeP/DwAAD7ZF/4B1/wED8IvDg+APg/gPdAWNWAPrOEaB+/8PAAB0CMHrBIPDEusngH3/AHQNiwQywegEJf//AADrBA+3BDJGjZgRAQAARoH7EAEBAHRfi0X4K8eF23RCi33wA8eJXeyLXfiKCP9F+ED/TeyIDB9174pN/uskgH3/AA+2HDJ0DQ+2RDIBwesEweAEC9iLffiLRfD/RfiIHDhG/0X00OGDffQIiE3+D4ya/v//60kzwDhF/3QTikQy/MZF/wAl/AAAAMHgBUbrDGaLRDL7JcAPAADR4IPhfwPIjUQJCIXAdBaLDDKLXfiLffCDRfgEg8YESIkMH3XqD7ZF/4tNCCvIO/EPgiH+//9fW4tF+F7JwgQA6Vm1//8Aev//YgEAAAAQAAAAgAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" & _
            "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAQAAAAGAAAgAAAAAAAAAAAAAAAAAAAAQABAAAAMAAAgAAAAAAAAAAAAAAAAAAAAQAJBAAASAAAAFigAAAYAwAAAAAAAAAAAAAYAzQAAABWAFMAXwBWAEUAUgBTAEkATwBOAF8ASQBOAEYATwAAAAAAvQTv/gAAAQACAAEAAgAIAAIAAQACAAgAAAAAAAAAAAAEAAAAAgAAAAAAAAAAAAAAAAAAAHYCAAABAFMAdAByAGkAbgBnAEYAaQBsAGUASQBuAGYAbwAAAFICAAABADAANAAwADkAMAA0AEIAMAAAADAACAABAEYAaQBsAGUAVgBlAHIAcwBpAG8AbgAAAAAAMQAuADIALgA4AC4AMgAAADQACAABAFAAcgBvAGQAdQBjAHQAVgBlAHIAcwBpAG8AbgAAADEALgAyAC4AOAAuADIAAAB6ACkAAQBGAGkAbABlAEQAZQBzAGMAcgBpAHAAdABpAG8AbgAAAAAAUAByAG8AdgBpAGQAZQBzACAAbwBiAGoAZQBjAHQAIABmAHUAbgBjAHQAaQBvAG4AYQBsAGkAdAB5ACAAZgBvAHIAIABBAHUAdABvAEkAdAAAAAAAOgANAAEAUAByAG8AZAB1AGMAdABOAGEAbQBlAAAAAABBAHUAdABvAEkAdABPAGIA"
    $sData &= "agBlAGMAdAAAAAAAWAAaAAEATABlAGcAYQBsAEMAbwBwAHkAcgBpAGcAaAB0AAAAKABDACkAIABUAGgAZQAgAEEAdQB0AG8ASQB0AE8AYgBqAGUAYwB0AC0AVABlAGEAbQAAAEoAEQABAE8AcgBpAGcAaQBuAGEAbABGAGkAbABlAG4AYQBtAGUAAABBAHUAdABvAEkAdABPAGIAagBlAGMAdAAuAGQAbABsAAAAAAB6ACMAAQBUAGgAZQAgAEEAdQB0AG8ASQB0AE8AYgBqAGUAYwB0AC0AVABlAGEAbQAAAAAAbQBvAG4AbwBjAGUAcgBlAHMALAAgAHQAcgBhAG4AYwBlAHgAeAAsACAASwBpAHAALAAgAFAAcgBvAGcAQQBuAGQAeQAAAAAARAAAAAEAVgBhAHIARgBpAGwAZQBJAG4AZgBvAAAAAAAkAAQAAABUAHIAYQBuAHMAbABhAHQAaQBvAG4AAAAAAAkEsAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="
    Return __Au3Obj_Mem_Base64Decode($sData)
EndFunc   ;==>__Au3Obj_Mem_BinDll

Func __Au3Obj_Mem_BinDll_X64()
    Local $sData = "TVpAAAEAAAACAAAA//8AALgAAAAAAAAACgAAAAAAAAAOH7oOALQJzSG4AUzNIVdpbjY0IC5ETEwuDQokQAAAAFBFAABkhgMApIvVTQAAAAAAAAAA8AAiIgsCCgAASgAAACAAAAAAAACLwwAAABAAAAAAAIABAAAAABAAAAACAAAFAAIAAAAAAAUAAgAAAAAAAOAAAAACAAAAAAAAAgAAAQAAEAAAAAAAACAAAAAAAAAAABAAAAAAAAAQAAAAAAAAAAAAABAAAAAAwAAAWAIAAFjCAAA4AQAAANAAAHADAAAAkAAAuAIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAC8wgAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAC5NUFJFU1MxALAAAAAQAAAAKgAAAAIAAAAAAAAAAAAAAAAAAOAAAOAuTVBSRVNTMpUOAAAAwAAAABAAAAAsAAAAAAAAAAAAAAAAAADgAADgLnJzcmMAAABwAwAAANAAAAAEAAAAPAAAAAAAAAAAAAAAAAAAQAAAwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAdjIuMTcLAOApAAAAAQAgFf9LwNUagdOS+vXucGtQtg9DS6IQmf+s8pSAof/lzpNbvs5vGDaqkwL0lyayt6KDCqSJQ4o1tatkkGwANofdA4t1w8Ib1+wlEQkEKJCbSipLHHBKr6/Y6mEy+GC/8kjnyRwAZHJdcZTrXuvURTMyEd7xL18vaaxPaKpIVxEN6R1ewTtehzTryXuW5aYS9U2CkNUeS5HPgAZi3C2Dw+FhvjaiZrlQ1oVO3mVxsRfsYRkDLQJHWOoCQDSFK0iJc+hkrvg9EKsx/Rh204M2EBtV4vIh2EB8j1HCY/e0lUmRXtqzblX1lAX+FLwRWycOh1iPPU/ST+jE" & _
            "4av+V/Bfw4egyu5QXFd/C0BzI0KuqclmBNs+gKC15g5R8Q4KN0a6VBjXCWzdY68PGquCwoDBdX1hKMk0t5rJOEcUsj4a3PfiXUrStDAev4XnYPX0cEIUm1x12xEZjyAt4S72+v5Hlgfu1CcYLPoXaKf2blru95fnkt5Q0aQPUohkA/Cih9g3rGU19LFzxem68pJtoJxTY72YWjGcOtbYSFHU/P02tTE8lK+BG+bMPfEppQr+CB122EJ496aVhNw/nVlQSuvpwlIamoIgF/KAmcVCstzT41+LCbwMqbLJJzi4IPuOkLmpiKRYHZfKn87JmUnuO5CSH2CKODE4t0RH6xY2KUnQlM9Iy2x+K0T0HVkqlFJAacrC2ebUelKXoL/OzMMsGkA3S1TWnDwCp3UqTpuvgOCmzJqbCHZ4IbqgrF7QBrCw94U9pOQBZIzbsHom0NpAhB+3SojF8YxewirrYDgQFLYXUwiRm+9qyilPcEFn1ptxME9WXBcxCkxqbvqSvt7Hpr+FCgrqNItPuTfZb0kWsVf3zxgkNxoJUt38BfR+v2GM9P7UuP1NRlg0MwGBhinv/atRz5sdVUK/iCj7SuwVDDPKRiTAqyURAE7ZLLtTPFvK7oj+Fp+vyBFjeDQVU7EuES37VB7C5vML5xxBDPQDxdyCX42LeUiqqk4qnmsI1/8ek6y166AtZlr+Ja94gjustQV/RpJh1nf/ZiJ+SwKrpktO+NgLvs/vAnqtnwBB/1rh/qrOdGTpAYTOq8t0gLw3gUZhtX4NAjk5d6TNK9baalO9o2dWBA8pxyeEarp7J78xk66o0j4FF0Z/93MEMrTBxX6D1UjInCpAAgAIOykfyZo+B9+RPFkbv9U9h81z7vYBISis/TtlcdPo7qU8O/F74iOaMOKzg0qBqj2k6V4RqJi9COy/3+rX+pgTnX/NUfnm0oBrOp/gdEgl2cr7YzC9aL6YEp0SchIEL8FF4Ld1lXBSPOSzihcwkrAQ3n/hqKAVfipWmYPrcBWqELh1" & _
            "8W4+zhf9FnLVQoPDpgLsC88CXh8ppr86W0gTlCtfiOldcvgItCG7YIygWmhALdYWVrytuVwk7KUn/H2550+q2P5GOJUPFJQa/M1Hr2NJ1VK2ybNmETnUE6mK762HprF9RkI9SuBoG4qwxTK/NanKYARLkKncCPORFBusAgkhuvkf5AvED/LIIGovVsrymjDmPDOUOUrL5UmQ2xP3fXh5rNGY5eCaCzTw3mNwbHyrrRZR4pLWWXE1BHUXzdVclaX8eVkYo3kdILj9Clhh4uBaK5XDXTeMroHOlJ0yeUNeQb7MOH68G0F5L6jtng+uYKO5gQIWpbbVjKTs9e/i8xL+QPgG9KwLvUGfHUmBcU9NKDddN4eJKQ7NGX3Ltv1oBZRSSWfwcPplgzNjDNtkmWsxx5niAddn8BY+iTku2pwZsmcY7V82whgLdj0gKZu/lrDYDKOOkb62/QJ5XiQYZxPdyO4tDeWWRsoEMht4QkJ8rAdzrxoRf8xyhit7/buTTP4sERpW1P0VNHstcmQ+1wFD7b1FC7WoFPXclfeSioefT2hWAO/Vouc+Q0hkY2gRkJSCRwLgOxdwQmBD8JaJ4mb3o/vsHyg/zvDyMyhLDHECO1MnBk8ltm3/AE+aNk/J0L7OCJOWTnTC8qOGEpDX0Vk1s6kqrdVai0pvF4GYiCUm5SBGTug8tryOqb9HmktJMvLWD2rOxDLeEU7WniBH2G/B2yE/gxmjbYUPI3cPAtV8GmG3KaRmErU8ScFbTqXlYOQfCLIQPKWvGbKOUSfm61WwyKzyHLWrCptIFOhud+YQKyBrZFDs0gA7H4YZuDwpT328DGNE5pBC8JgRG7+PNoUTOThbF/qeefqcb4uqpoMW2Egul8qfpCrywkTSqudrcvon4VuB7Lno1YP2Us08iAPGUxTi2+/dnWtK06V72GfTyLim3ANLUc0MquuRaSQsAYmZB9sMX7Yq5exJuy1IZIlgNjF99jpYHGqGDIEOZMllZnIMZQ0fDWSCSNwki/TyCgls"
    $sData &= "VZu9oQarvrJ4CdrIUjoQNTMPhyAQd5RXyBOdbsnWGQYPQ9HQ/8WsNo7tmMV4Xk59whuiEKAzYoMjV/BpJ3rz0FWRxAZeU9fSGDCqoLqgMtbYH5WijE5OxcHBk20QpYkw3nniDJ0LB1ZDWUCkW/x50pkJCHflX3AaNCOL1x/dO8cDfvbrZOAs10Kggh+h8/hNvKCRcRMgPpZRQi8i+g//h2igsJ4QkR1PK5EciUrmWLhd7m240wiQdUkdpKydUW0IJvs5j3uuPul/ITq4pgNcg67Y2ILm2QrsgQC4STmZ9YjsV7D2RkFPds9kcsAa2bqyeRy5dQO00Nq7Z7fwWpG65Hg2acd4XKmXvQVhhayEbVaa+F82RoV7eLDMaLdpWctvgCgh5pp3fCrkGx9KFh8m3xat011VzIihSthdH1YMcGhbrkypaX15qMRbUUKG4a1ZvM9R374fJsl/zNGu/DTDiBLUFh0J1sqLTzJ7BPlNaYwwNzL9Z9MC05E0nIFkASIw3OTPphGPj89erNxCAg5xKHc+C2s9VRrG5TbjiZRh0mXhrIITdorKKl+3HmUky62oq5RUO7IqNWMEYfIfhZMIPrfK0oaB5MbSzQsUMMyy6D4uGZIinG8QQqkHxNXYsl2Xqs3jok5ikYomJIul0g41PYCm5n4znrkoHArlk4DDuwJHMsiWbAcwLT2dAnMUiFc4erQYxyGys785ox5ICE6XcVD37eDst2ZbrtxkWaN/lHZUwmQ50nx1SEor/l0sw/mEg7dnnbbNsop+xRjyriNDinKBtiqI5Z+UNp2T1T+1pATYWpYZdlG9Bh2eYt/KGtQazSAmcLcJ1upYHEE/fvflQFVKeqIwONpLGyorFVRMunw60QRBjRcH7+N/+1FKoG67l4ExFhpXT7zQSiymSL3TVr5j/JuCuRN5uB2BaJckm9rvlH2cHYxwd0QoEYa8rgsfOKIkLIaImaMv3lgP0ECjfl7qk676lOe9Gp2gYzDHdiweazDU97egGCU5hiVBnUuk" & _
            "3pPhFUW48xKuUD+KUW+4DYjqJEX31IUijM6kuN8jiMPGk1kQzHWgI3iWVU9Wc9OAON8+ZuC3pP7J1iJAm9hSAmpgPjbujpZw21Sm2nujNeYDe0ILNK3ily1Y7cU4IZe05L/w8NRpXoX7FulX4p1ODFBcNclzGBONPUGT2ybNM2iBG6BuOvG2QIHAZ8a8k2aUoxxw+3xFP658+HEVuBLZgaLKXAJ9YRWT/SKdwUmagrh5VGTxZuzQLSWajcq9UXuiYVpxUz9M1fU5mC++gZVf08iKzpR2P9LbCYpxTY2N0hpVe1apJS/9wNOSTA5uCzuMMyAMzhbHyyjkY3ThKcsW+Q7R2J0q37QN+WfV4/GTLhOgpLAzkDjHwr06DrkASqz5JyySia4HnrEYb+a63YCTJ2vnHr9l29sD/i3L2XH4ycVXumVsHF1T1fsg5zltrWR4NnHweNqt5t+M7XgYTquIc4qQdt63EPskkdzIW5n0/6Dsk0CCnJNVTCFfiNk3sd4o0TE5F1ImmaPVTtoCWRRKYDnJUVksQLKTgISTIOoZI7HS6Mt8eIEqY9EL6iZs63Gmb39sEulvc+HjECxMFysnIbqLvSuBFs2NciPAskvT6kVm7ZU+WdI8vBTWlZhWVHbmGddV9RaWvlIHrwmY13WJ5PlnFzqZU+0t0JpAtkr5oPqS1RDoUmRvQG1QlxD7PLmBWMPYsMyRlzWfRyWmf9bwRQjb7cyvi3n1P6groTeEQOb5MCdmQ/euG3QKt2ZW22RKLbhIg3+jh8XVK/96R94uhNDVba1EFPbnAuvRkSb57/8kWIegmytP+2eDH7/zRcNjvxt71L6L70hQt5qxw9x0i7B1rRTgNETksNi5jTnLjXvAn0YIy9+Oh3uXIdtmY8w+Ifmku1b5nGWidmhP7hRfTODWNUhSPC5UyfD9KesHgtuWcbYVyCNyp7J69xwhjmIakkK2QaoEApG/J9+7uMclP+bCC4K+98ma3czbuLfTqgK4SmQMe+GmnZ5QNcipe6Vd" & _
            "+qitKlCTzKt9Womv2fZ0+EhSOma9XV/O1HyS4xRDcjT8yXEUyY0RR4tEwYXfAmevJdMfHzD1lgLp4wSTI5MkeZr5blgMIlDVnUSchB4Pfp98w2DQT8XN4tmFrGBPFFKGROPudxFsJvXLQtEAc66EJcpO4GuI7txO+q9BORWZnn7uikYozG1bVe0ergtb/lN2BVbEmqOX51gmKSa8zjSTf/zK95U+OTdjw4G6GHlR5aScL9mqptjTEUHOjudRjAVOGAYhdmctDQMhPYeBYvwvcyEgG8wJDmcc/XielYoqhYaLOgYS8VSEUnr6F6dePTjlFRzuRe/NLFNMnSHGvqVog46LGu8BLS2n6lD70oVSZF4iaDKHDNFwKE9/eKAcGWzKfavGqMHBrArkVoSngm/ruFRzvixFbZL3LqNV4zwk1RM2DcPj/FO2vWItkRCdCt2JUG2DdA2djCMjlrSb+WDA7YoO6c31TqRMyOsAUomtNqCJLgCD26fXfB/1ZOkbs/UC6ahiQVws29AZhyhAFM7xNje3QgUIWOAiAgMTpXxsympXjPbQO0cv1x+XNdtHVXbsXJr56+alyF7quU4unpQWA8E1sw9CHTR7GUFezUsZz9LJM20NZEBqOzcUW0CgYrPUP12+2auqMzg9TjFY1xgjk4LaSj1QmoTSEy3+UcBeXa5aDY5095iuYSpIrFWB3QE1Kb6BtJm5RvKV+CDMBhX156cgOLmK4X7MnTfKw0eLWGOVBxBNJYUngL1GtqEc7sUQSL9Ifmj/HtTru0XdTZYNp3BEx7cnC9xlFs61ICgWxUa4ATqJnES8SyFYz6VfLXEWthIdm0It6rMjz8iXZuB2j9odsIMKMBGczm5fgU23mhCsTtLcA4NhUJGtZHp2ST5gAURfMAWRzLlaTTMWSv7D44rN/WimKS67MZQL9Sn/OF1BmhUZLcPmAr7rBF/rsqRI6qFhqxW5mAdWcRlQnQT4ug1XrKuzxbj/bZtS5KBhyOVQ2v0JJ2vB0c35wEweft6x"
    $sData &= "IoiCVbFKKfuL/fhJCdavUNjEjrZTw1csjGqpmZpooI7CRRHG5FtjvyoZPGOSOTaVUBG6AJtumdArrjEHG75pQhydFOKkIgdMQFpEeCyrqP9eFMcXLmuLDsUzcReszulMWofMx7oGUmvJ1raFBIs3tV6sSyUnB6G9A2Kn7QbTQYySAWzyg8T64Nt9FWcucwZMogdEiNMMHv6Ymfj9TlDrgiDb99WNJU/a/XStZNI52CU5FpRqIc18r0fs9rcnB/OWy0e/KCLit6notvu6j1GEitlSBiHrMatqUWbyscgLLInks1I5EoWEl6UUsWtKzFRP6daWM+yTwjWbZEc+MK8tD3vwvsP3zIqxUm6m1xr9EdAnIUyNe6MMe/1/tTUgc6+qOQrNMU3Rn2eKCs2DrzJAWWhoshdcaS04FJyLb2gcfsx0hyfDVB2gCovqqIW5dd7nw3CeCA+0BUOQCdCsHOpKSyZ3KM7Z0EDy2MpdAZ24NYs5a4N3hBK2+iu6pzYgYQsaqeTgcqsBsZDbSAYYli3Zcn6lZtLifFf3Mr8OZVFwqMLCvMM1EU2CAWXRtjQRjl0woeE32jsfZEQWvWFYh+TsQWBulwDVeqr10N1f+2AP0vcgcE+bJCjE1NtIdSXx5eUbPyFItuiKj+RcvWLKo9t4AQFh0Yx661dyZ13aaznFS1xkB2oeaQwF4Y/FJDzu65ghvv0VgNPcxiZmkpnglJ0sNNuwsGWd/ULKhbe6OKUnQNR0CxqOXx1DFCcTRsin9ndXxt5DdetT5HwtNEVnyvbjcoOE2W5EU5t//AB9yXFtjGkHhEteam2mZF6JjFDqlnvcvCx3d1L0BiCv6hJHPBueA9fjRFvvWn2euU+5BEwu6j4wFDWvppIPcNvJPdjjkLeuXYn0HY78F3H2NQHMO5OmcHGroh2Qkf9SWmaZ1Qruqznysd+4Kg1t0Nue3OFSpsQlzOSzDCAdYf3JSmzFtwsZEs+L2fCjBRCjYfep+4yOLdqX8SBzmWMHLyt4QWfkcaOY" & _
            "7i8MgpIEcv7rqlPA4l5DG8v14aPE6G+MbctL1xbgVQoGOBvZWKG0KSFMFu6ScvNjeL9Hb1fJnSdJUNUbqY3vHPsVX2azEuWigsJTEzL2SnjlrkcmgR3RWv0QQiGCD5fjo9yJLcqU/NMtnn/kabSlPrmjmgVH8Rhgmkaa6gCM1trP6+zsehU1LArb2H6rb04XhOO0du3xFSb32KM2pestLIiT5i8Wekxv+6PmQT6OIFdi88RFBSYh4DPgM7SDJciEuABhkJ1tjB2hv36jZkbSVm7KeThPIcv3OeoULow7q+1qSR0v2GS1VbWIokl3x6x2xJIVKjXV2Fj6CO3VXP5tNuxbvrQ7PP9WST35LnXUlXx0ahQB2+zjci73gJkyOFhsFE3wPJomxRcwW2VA/blBMqAAsuf17ZXBrKBMBNG3gIVRlSTCPA3N3r8uJE+aFlvdYxFjhGqk0bkJ4zSqJrCd+sRxZWopdN5sjoeBAvIop021pasvOmwp07M0pYklrfLRg8ts10qX4FxGKgDMdppk2FdlibUHdQwToY7IPfViQ/CD48hIxhivolISsYNWI53Y0Vtd9TTnxWa2fdtUJikJ8H6Oaa5i+vkO614ICcpMU2ercCwFUTZzc5wCcfcv8bKptM/jflB6zS1g7iiFoX27Tnz01dSyhr4aqp6sdJ1wEb3AinNEzKYoBvxy80yXCD77e9J72/n2coEXUbLZVoJKVlMNB+rxOANzUCuK2M0efrFroILCITebdEGUZm7oViNvSqWyn96+Hs9TnzUbAy/kutLUqtkIUG3IEK75PMCxmYgnPMuTUQqdnLNS4zYOdGb+krWtPIGV4KoGIttbPk0ZZ7X8hET8lvdjSkKPrf+CLFw+hl0QGboIqBu8ReQYFTf2tLbYPtLqvAITe9nRZhijjVNL3cyPAccN93DNfPE4W3Whn5qYbddPSJhRdsHrdNzjqPnE76MtTXxaHGcPNnN1c8XlL6DxKGhPEOZjq5d0Bni0ZVAih8zFie0awRoaJ+0G" & _
            "7C0mLbG2iBKsd9Fsvn6z60TeZBDbgKEzfJR1938OXZvS5m+l2rOaLbQYVci8offDjVIS0EEWeUX9CFbNBoqKYkALSM0jGepwayKQDBmQ0iV3VijVNcvZa/2G1MpAbhyr/KbK6JLJZmUULRk8GwfYh53Xj1m+7Q5RvPQXEY7QshErUYPW69non3krtjohk4CnhajPSjVlcKYATVlLP1ft9AzxH+4nsep2zKwuXzmzRmq1Vdu3q2RZKAxT/k7vS66WLjmGBnq0+vvAKNC0hPvPus7SHUv9sfD+mWY5IUC3eYKIWFg0/iQNo0EUg6ISfyafZayYH56ZL2WvkOoUFFdmGYnSjuakCvEquvZWp927eh2F5Mir+qofEOpNmze07pAH5Ix/sIzYjLgbTl9VipdfCSJpK3B4b1wwux6mnIXpYHI7qmvmD7ZsuvFQeecD95L1INynJkbFJN6afu9WlfDxP23KGxEJf52eg9T3g0vUz3iRbLNN/MN3fNtwDhoP7IZ58UPBmrkYkcihaBpkNcwulnXVvPa9yYy8NgXQXcf8TD8bJUwSg6dFfdNZmfDssiiVXA5rnApB6awaTLYyyI5YrCH/i/ru6mE0T1VA69/VSclYLf7U1FKoZkpb0T3GNVEqNt0m6iG+mctKDeL0hjXtF9OgrLHH8asc8fb81dz46hfiSncQU3aT58Ih36n2KG4426gZ+w1WMluRNU2AoO4UwwDw7Avn71qmEDh+gvr5Wj+g6ix1ijtsd8uTwrt+fQ+8AZ+285HNfvZQwZcioG6LH5x9HkKqPcmYSHgm8ypaEY9w2POlh5yP2wevEpgJVhDpuNLIVVjkziS2ATbjZzer/aJCkGDdvGcx+Ft86SWeJeITxo06lHX2oAPFMSKp88y8/mVsUCWPODFIZst9N1Vxpw4k+E+RC+RJVHDveWvIT5HEPK5D4qmVM408On/tooDdjGJbbVACKYFHnONz4omnc5+S6uToRQTY6p3TnlI6hvDqhl+3g9Iqgo+6XmD3yXx8"
    $sData &= "5JtBLMxxY0/qIh3v0/qcbUu2qAJaZ4vfc4tAp9nFq6VBvrZzm5OXw9pKywpgZeo2CpER6fF1D/tyVUJr5nl19OkURSnIuBiAfGJfJ7amMjq2sSLOkHEU5xjAzHyXr+aDWUTvnGt9RxMsVQsTzKhwEZkNuVovfq55FSBTkKCK2jCXDSnmMxJ4zKfHq4Q3z8zqNyldjbPgfBYzlaq/zpxsTLCd2huEZZSH+bLhD5TfKlL4k5hlLUmRnp/IUYaOVfTF12/ajWgE2nKICsyR5O+SPx451518U/kzSsevlh8Aj9xwa+PJjwZ8Ca3rECk30Xm8cIij8RDegArwuRcn4ZXhP6/3JtpaC9kjrE7H8C8a+8HFDdwf+0WbQu0RTMiKL7xroJf17giqsMCgiLjk2I12x93jGKg5HG6HO0HhCIn4IWI24zIfSk3VSDkHhv61NJU5Anxv+8YApS65UY22HQrUNvbSvglOxIPlFSCyubbGzkvGB9ArKKBYxhFep3qAo/Q5nAvtol158F53rBh8rwsAimiMWKMSU8EVLvEvCSW60C+2kgkU4qWIRo4uITTeLjffgixPxdPNEkcAbfoUyKAAzOIIOK3LbIIVVLp8hed0zez7GDJDf7lN7T4pY3jwoo/DIDl28bsAFnK2oLJR8myO2WRtAPvKDsz7uia1oVBOeUqLmIo3GdrLy39pzO5Vzwz+911nSFe0jP6oVkPcpEggIg7VATzW5lekq1+h/lv8bCYHn9rkV9aHnLqDRu1A6tzY3/PL/vnW/w8R1eImyQvIKGdoSY9X0vOt+9bYmy4nrT8iiYlhRV9sz4Aqa1N1SGJv10kXF5hhVgd2pH4g5da9qzEQ3irpy8uIGPshjTbPJDFSqnx81MQsEW8gokCaZmJ9oJtujleTqUyRO5rRiTdJs6W6Vbqe73pd6t6b3WIMVEDTGRWFo94ndzZL2U/o1Ihonc/KMIdXSbq5zoHpp1BENEo0T/G6+SQ4WhWsAVlCcX0iA2DomMgIoVTOKmiB/24i" & _
            "MPKAx0gNGe0b9haXcHHqRyq1lvRZGw91fF0PhAMUjLPqCcrkgPmY2G/qUwAkDOZHyqPUbcr6yvVXz1TxN8WDMhSZ09lnEaQ00ez0NfLhxNBWsv0rw//f2tiKWvDFML2y9nU0VGhYis5S4jBEfjXnj+MiPGfs5TzXp/W90MvAu7P3YfJ1qO3zXwoCRxp25YR10e7knUL775Q0E5MxN4k1Vu8rvD5A9eggX5YfefwA5Q44SYkgBASSQXLXt8gYoeCA8OK51c20j4Asy6+1ZSnntDZd272Wn+QTeVBDHRskA9ae6l+JlRwhrJM4I5KE2iu5jrQ6vRZaO6nYB2M0EXew8bRWfUvVihYrjIiWVR/RS8GgVQvffy+oM7XmNiq3dGM33G5UB93Mkd2x92+LUNbDalOlWafqI4ImtmIaNoqaM92yKmumzoyYQPz8wTnHuSUA0Oa1nHYTx9dHQogoRt/d/074zTIdoW4X6ZDAtY3DFeeew13xTw3keq0PRl0hS8ZIt83VRDZolZOYH/usijiEnqG+6M3XEsPpkaj+2K0coPs79BFVQOL1dlf16Nj3XrYFP3MstiAP6iFNGMRlySexee+GxM1Qa+cPcTFj2LmqO817qjKAyJR91pCxuc8SaoQG3dqYrRioVgKAHmTjGhLpTDu91b8b7fcCGiTxz5Dyk5mmVSoOsPCrPCE/QSTLxkMm1yNvfyJAXHlRL7dUaBxU23IRPvxKf2ZbR0Lho2GYTKdBmpsmMVmpUK7bmX8AtSDgGXGm4lHMvgdc3CKyBVozu1m9dQa01kFTR9Gl/fAx7ymH454WnmFPNYyuv2MaYDRLRUFbdIZw2cPvceUlbxuiBQ8mHlFe7s6icf8Ob9HSh6wxCFBZbzps5fCxTmrV4szNstr0eou24kWrpqcKFAZicMg0/bvfjqCgSrvUugc2xGYmfpuCDqlNWY9hBS6cvw8+0S3/TZGK/V1UmNxRoKgYj+ig2+8gufjcXazK7Jnh0gpD2pxLzchKDB3qaB/7Fblo" & _
            "5WsiAk/jhVZooezywP74czXJ8zc+md5wCJM/HahRW/Uem59n326GAyKDz3P8+swxrlfy8U7DM/hgYcq5pkPOe7vEVPDYUnPDbnUKGZdpKG32Q+s1uj0YSb5jYzM0O4FyZKSkAnwg0HVgUBwoZEqKa+TFYJOA9V7pKVWGN5jMcxcooz4DSi+1tgkY07WgyoJQEnqzbnh6+lPxllfagEzdyRUIghdSI2jHia/UCFrEF8KtsbcAzwI7Qo4MuegkYGZ+DGhjFCSqQpj3zwZ6lweA7BEUQMnw/SQl73oznO7foLoJfMrU76YnzFkJq2sl61qLE+GxYsNs8LheXLlkGc3dwSOY3gt8mFf9UEAvtHJ0FRFnETrXrpXaGj3JeMR3+lwzCM5SAMWTForoQeaAje55/fs1qqE5NVpur2CHxkg/qc+JYhRRprKyigOaJ/jA6Qv5ywoNVuy9fWVB2gdvkX5f5VI66D/M6S21x9vgCNtD7/GqGMcTXzfCUpKKuP2J5XXgV5bOrNg0Mod+q523puaVwX25vfDsKf/kV7fMNB1ShlzhxUGb8+SgD5XeBwhjohTwl5bGjC1+3CseGNSZQuw/WSTlbYDon4N8hZhJiBb5ISr61ueXPFek8b8AFPv6LsalRZgC6GnkVz2OYfp5qaO+p0e96BLw3OxNTezpQCmd2wFGEq/ABnDQoX5f1TyUuBfkaPv0hmQZm+EyINwTRNW5dLJnZAAnYnpYD7uqQRTDYpI4nQcQR6l1Hk6cYaMAX2pM+kLdt9fYyqqW297nd3Wd/AhWQ1u8DCeo1iQn/Ub1BnrVAXPjGpD+istceAWuCLyLlc9dbmM63XEZJuhIeXj/qcTPlMkOdGnURWl+XaPbYihZoXHfSbURuqpIcobGgQ6ID1sbpZU0mqidKDLJQhB0nT4El4W9wKDgy8AQUGeqUjA61dy3d2X91P5YCUk8a6f29emDTnOLJjzRuWuAbM0SrdbwgTUl+MDpVe4Q4iTMlDIFShgk0/D8PmdwTzWiPL3w"
    $sData &= "ZHY3REBrXaQur7kdOD9scHWtN2Ew/Wh5DQ6qViGYNOlIy/Oa/odrB02BDzra8GsQom9epNMDH2/eYq3EIL8AXuFOf5yTlFyqNnuIv5ulAV1BefhycjAuV6WOUMnv28WFgXe+T6bNkgXiWZXoEjfyt7+2k6wrzcYnpqm7G0wjA7IKhYvX0c7D+nnc2KLsKdMezfT/kOfHJbEUaTdOFNlMFxll8fMrWKNHwBHm2rU3Swbt1iqM1KEvPfT4u0veGXCcEJwdulQhmcWWHPvq+biKzaw77Na4rCWkw7iobqA281fIZSsiKdk4c1B0scv33XGRwBx+/7f8eOpLYpnIGQJuKaZJknZnp7H65IpwfxUNNTh2GuW0mSEayO+wB39qfoZ71tuscGXnN+E+gQknKRER20t9v6MLMwhOI2J8wmcISim7xIXczhDn/CbmA1g5FT66ufLAswQ372Pkw+ubGuZCzxcteQ00aC/NcONgQpE05KblBlIbqWYBcjzeL/Ll4KjCrdsy+n3HIYUbpMSIbib0mS1EG39mqsM4FGfVM4QDwkEm//LTl/nz2MRCzzuKcM8Jv6icDDPrW1N6Ee0EMUFefPXCMo956GcVZeS4OQzPBRtddFzbpVHw1yN5Rwx08W64DOf//wSAiBUwiPI3igQV9jOlPnqQYVqjX/41Kv+VTEHwnZILopuoKaYTKqYHli+k24D9YCVLPTp1k/754GVK+6KmDlMgr0KQvTlgOnAdOy5f95i0pGh73HM0FYNBqXmgO/eGQBOKD7jkVlE9wFsEI2PlNByfDwEiaR45JNtJ9rsGmmLEmq8a/iSRL6v5MWzuFD5hbF1kSUXfD3bU8wgJ6vIfi5IuMoHv7s/JT5+hfeCpEGagNKm/4KUDxjiyGdcuLXAWiPWnpqu7Wy4O/u2m8QG6wXKBcBeJS4ev5ECtSC8ad6zl0q1S/mlj8gZfjcFqG0x/8/Dcy+iKDmmyT7VZ2JAnEHEnArl7DdgfL+ykHbcLhANckhNRY2LhYZx8YVDf" & _
            "Q1Tj3R9bLgbccGDQG555FmPK9oYAvzcrIqi1E10zx5mA+hS/jhbbzwKuYHc807w7Q29US3GpDfZiUffWY5+RR1o9THCBAdKvZnBhCDel3PLKtUitxSIP+p+wq+98ZTFq3e0lgqP4B/AQSncoGageTF3VSgp9dckG6b3NVOz2jLP/a8P5FBVoOZ0U7+/knxn8QyhLiKMi+GprPluQfUNelI6Dam2Uvzp4u4bVBoR7o79wmStEdy70zBhe4+iX7QtzK7DyrCKBd0UC7q+cePivkXrB9f5C+HTruO97z6aVga6QuYLzw4CRKT2iZHDzYta6owd8Kv4xA+v43qyfTZs+bfRtgC6uFNQnBE4Xn5bDnPUglBlPoIotQxqn17hE9IOmYGj2A+p49eYiUSJvbpKUH2oD8MKhGLnQOp8NCirFLAGBRzvLmdL0WFloFvrgtO9GeLJUHtqBGFq4jtOvj7JHBNXC1eD5ZTnZ5mpHzNhGRBLLAo0U4dOU5Q1EV3JgLj4rEQsPT9RsZ5faaK9YGafdM/A/iJPOGNuupSdhWrRUpEHGWCXwcCHBsSptxvUmibz8Lw6iQ1W7r7+0oOnzqOjbPR3WwIC8Vc0YZQq+u9MGDPUc51AuJvE/D1XX3mbGvJNAG9VSRs5sPGX8UBMvo89MP1+vgfMiEx/wruSZ9xbB+oZEAHM7L3uECTuKeKQsWb0N4ODqCCCpuik81WK0a7vKywlBTdhiNJDPAmuzfr1grMzj1fomSRCnYkNXYmgxiI+HagIKcWxcbqTWShwOlCYUv5BWjimv/lCHtPRyFh5THt+FvbG+FG8mQPxeU4vCfxPdjaZZ/l3E18dG+zuo1GUENxN3yXDfUOXlKYzZyK0OmT2XIHyy3nX4/yybAueET1obQxbsYt44RUV5PU0h2RehNU3ZDej1yR5RK+z8wKrh2Ur7OWSoqKilQ695z2F3qlK6oF1OdoU1FBHoi//JoYaK+F0fKJ0FECLVQ+EH8Q8DrySOVaUhpo9LLDaag9tewlYa" & _
            "9cAONZ9mGIgDnAqt6kFC5mMvB2gFsrJ+Qgoe7EINUj6L6ZQvHXunVFbnyVbdwV29ll2r8cyp8JpHdPNll3pDtc3mu+BhMTtJLB7pxacHhvzDq72LD5SN2rSQgZaH0g1GBM/e31jNlaQtEMVChZIqo5rXvsUoMCnB0Z8F0ovVqQfD0i6zOlCKfkmRbVblDH+83YDj6MtRbu19XPrGd+IXPvm+IV9iiBfRHAHyeRj+nKx2Ax0Mjg4Ve5G8s+Kv9USiOeqgyxIQPR5j58rNuoDOYdVDpJLIR5f2I042y9lW87TpYR10zxOFLdTppy/3baFMke+hn+8wl6Iy3rodhrTEyfqjnRc0GlGDSWExJOV/+BIJNf/q9emApvKJ8YLzFPkc1de6LEDIX4TZyol85d6ZDF8BAX4Of5e38EM1fQoP4sss571vyqTFUWLnhcd3a3di/oT74/YCWa6k9PCAxYdqsGDM+up87kxmNawjNOqM0r3j7cMdUPYauLthz2B8ZdyPlak2B0jCEJqFrp0Y9jsN8G42+KlP4C2fNtbZVeKzDn0s6q+6myWLXSW7oxKcJD7/oOrf+rS3yideGoS3EU5LTw+SGEoYthiBPkMho0HHRwnzvAa5OK1H7YSA8/ACZ78w2WroAUeAAAAAZjkE+Q+FTQwAAEiLTPkI/xVcUQAAiUUAAAAApIvVTQAAAAB4wAAAAQAAABQAAAAUAAAAKMAAAI3AAAAtwgAAXE8AAExPAABkTwAAeFMAAHBVAAAETwAA4E4AALxOAACQUAAAbE8AAKhPAABUUgAAXFIAADBPAAAAUgAAHFEAAFRPAABkUgAAvFEAAAhQAABBdXRvSXRPYmplY3RfWDY0LmRsbADdwAAA5cAAAO/AAAD7wAAAFMEAAC/BAABBwQAAVMEAAGzBAACAwQAAlMEAAKrBAAC5wQAAycEAANTBAADkwQAA88EAAADCAAALwgAAHMIAAEFkZEVudW0AQWRkTWV0aG9kAEFkZFByb3BlcnR5AEF1dG9J"
    $sData &= "dE9iamVjdENyZWF0ZU9iamVjdABBdXRvSXRPYmplY3RDcmVhdGVPYmplY3RFeABDbG9uZUF1dG9JdE9iamVjdABDcmVhdGVBdXRvSXRPYmplY3QAQ3JlYXRlQXV0b0l0T2JqZWN0Q2xhc3MAQ3JlYXRlRGxsQ2FsbE9iamVjdABDcmVhdGVXcmFwcGVyT2JqZWN0AENyZWF0ZVdyYXBwZXJPYmplY3RFeABJVW5rbm93bkFkZFJlZgBJVW5rbm93blJlbGVhc2UASW5pdGlhbGl6ZQBNZW1vcnlDYWxsRW50cnkAUmVnaXN0ZXJPYmplY3QAUmVtb3ZlTWVtYmVyAFJldHVyblRoaXMAVW5SZWdpc3Rlck9iamVjdABXcmFwcGVyQWRkTWV0aG9kAAAAAQACAAMABAAFAAYABwAIAAkACgALAAwADQAOAA8AEAARABIAEwAAAAC8wgAAAAAAAAAAAABAwwAAvMIAANTCAAAAAAAAAAAAAEnDAADUwgAA5MIAAAAAAAAAAAAAYsMAAOTCAAD0wgAAAAAAAAAAAABvwwAA9MIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHMMAAAAAAAAvwwAAAAAAAAAAAAAAAAAAU8MAAAAAAAAAAAAAAAAAAAUBAAAAAACAAAAAAAAAAAB7wwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABHZXRNb2R1bGVIYW5kbGVBAAAAR2V0UHJvY0FkZHJlc3MAS0VSTkVMMzIAb2xlMzIuZGxsAAAAQ29Jbml0aWFsaXplAE9MRUFVVDMyLmRsbABTSExXQVBJLmRsbAAAAFN0clRvSW50NjRFeFcAV1ZTUVJBUEiNBd4KAABIizBIA/BIK8BIi/5mrcHgDEiLyFCtK8hIA/GLyFdEi8H/yYpEOQaIBDF19UFRVSvArIvIwekEUSQPUKyLyAIMJFBIx8UA/f//SNPlWVhIweAgSAPIWEiL3EiNpGyQ8f//UFFIK8lR" & _
            "UUiLzFFmixfB4gxSV0yNSQhJjUkIVlpIg+wg6MgAAABIi+NdQVleWoHqABAAACvJO8pzSovZrP/BPP91DYoGJP08FXXrrP/B6xc8jXUNigYkxzwFddqs/8HrBiT+POh1z1Fbg8EErQvAeAY7wnPB6wYDw3i7A8Irw4lG/OuySI09Bv///7DpqrjiCgAAq0iNBeIJAACLUAyLeAgL/3Q9SIswSAPwSCvySIveSItIFEgry3Qoi1AQSAPySAP+K8Ar0gvQrMHiB9DocvYL0AvSdAtIA9pIKQtIO/dy4UiNBZQJAADpigkAAEyJTCQgSIlUJBBTVVZXQVRBVUFWQVdIg+woM/ZMi/JIi8GNXgFMjWkMi0kIRIvTi9NMi/5B0+KLSAREit7T4kiLjCSgAAAARCvTK9OL7kSL44lUJAyLEEmJMYlUJAhIiTGLSAQDyroAAwAARIlUJBDT4omcJIAAAACJXCRwgcI2BwAAiVwkBHQNi8pJi/24AAQAAPNmq02Lzk0D8Iv+QYPI/4vOTTvOD4TKCAAAQQ+2AcHnCAPLC/hMA8uD+QV85Eg5tCSYAAAAD4aKCAAAi8VBi/e6CAAAAMHgBEEj8kG6AAAAAUhj2EhjxkgD2EU7wnMaTTvOD4Q/CAAAQQ+2AcHnCEHB4AgL+EmDwQFBD7dMXQBBi8DB6AsPr8E7+A+DtQEAAESLwLgACAAAQboBAAAAK8HB+AVmA8GLykEPttNmQYlEXQCLXCQIi0QkDEkjxyrLSNPqi8tI0+BIA9BIjQRSSMHgCYP9B0mNtAVsDgAAD4y7AAAAQYvESYvPSCvISIuEJJAAAAAPthwIA9tJY8JEi9tBgeMAAQAASWPTSAPQQYH4AAAAAXMaTTvOD4SIBwAAQQ+2AcHnCEHB4AgL+EmDwQEPt4xWAAIAAEGLwMHoCw+vwTv4cyhEi8C4AAgAAEUD0ivBwfgFZgPBZomEVgACAAAzwEQ72A+FmwAAAOsjRCvAK/gPt8FmwegFR41UEgFmK8gzwEQ7" & _
            "2GaJjFYAAgAAdHZBgfoAAQAAfXbpWv///0GB+AAAAAFJY9JzGk07zg+E9AYAAEEPtgHB5whBweAIC/hJg8EBD7cMVkGLwMHoCw+vwTv4cxlEi8C4AAgAACvBwfgFZgPBRQPSZokEVusYRCvAK/gPt8FmwegFR41UEgFmK8hmiQxWQYH6AAEAAHyPSIuEJJAAAABFitpGiBQ4SYPHAYP9BH0JM8CL6OljBgAAg/0KfQiD7QPpVgYAAIPtBulOBgAARCvAK/gPt8FmwegFSGPVZivIRTvCZkGJTF0AcyFNO84PhDwGAABBD7YBwecIQbsBAAAAC/hBweAITQPL6wZBuwEAAABBD7eMVYABAABBi8DB6AsPr8E7+HNRRIvAuAAIAAArwcH4BWYDwYP9B2ZBiYRVgAEAAItEJHBJjZVkBgAAiUQkBIuEJIAAAABEiaQkgAAAAIlEJHC4AwAAAI1Y/Q9Mw41rCOlOAgAARCvAK/gPt8FmwegFZivIRTvCZkGJjFWAAQAAcxlNO84PhJgFAABBD7YBwecIQcHgCAv4TQPLRQ+3lFWYAQAAQYvIwekLQQ+vyjv5D4PIAAAAuAAIAABEi8FBK8LB+AVmQQPCQboAAAABQTvKZkGJhFWYAQAAcxlNO84PhD4FAABBD7YBwecIQcHgCAv4TQPLQQ+3jF3gAQAAQYvAwegLD6/BO/hzVkSLwLgACAAAK8HB+AVmA8FmQYmEXeABAAAzwEw7+A+E9AQAAEiLlCSQAAAAuAsAAACD/QeNSP4PTMFJi8+L6EGLxEgryESKHApGiBw6SYPHAemnBAAARCvAK/gPt8FmwegFZivIZkGJjF3gAQAA6R4BAABBD7fCRCvBK/lmwegFZkQr0GZFiZRVmAEAAEG6AAAAAUU7wnMZTTvOD4R3BAAAQQ+2AcHnCEHB4AgL+E0Dy0EPt4xVsAEAAEGLwMHoCw+vwTv4cyVEi8C4AAgAACvBwfgFZgPBZkGJhFWwAQAAi4QkgAAAAOmaAAAARCvA"
    $sData &= "K/gPt8FmwegFZivIRTvCZkGJjFWwAQAAcxlNO84PhAYEAABBD7YBwecIQcHgCAv4TQPLQQ+3jFXIAQAAQYvAwegLD6/BO/hzH0SLwLgACAAAK8HB+AVmA8FmQYmEVcgBAACLRCRw6yREK8Ar+A+3wWbB6AVmK8iLRCQEZkGJjFXIAQAAi0wkcIlMJASLjCSAAAAAiUwkcESJpCSAAAAARIvgg/0HuAsAAABJjZVoCgAAjWj9D0zFM9tFO8KJBCRzGU07zg+EXwMAAEEPtgHB5whBweAIC/hNA8sPtwpBi8DB6AsPr8E7+HMlRIvAuAAIAABEi9MrwcH4BWYDwWaJAovGweADSGPITI1cSgTraEQrwCv4D7fBZsHoBWYryEU7wmaJCnMZTTvOD4T6AgAAQQ+2AcHnCEHB4AgL+E0Dyw+3SgJBi8DB6AsPr8E7+HMuRIvAuAAIAABEi9UrwcH4BWYDwWaJQgKLxsHgA0hjyEyNnEoEAQAAuwMAAADrIkQrwCv4D7fBZsHoBUyNmgQCAABBuhAAAABmK8iL3WaJSgKL870BAAAAQYH4AAAAAUhj1XMaTTvOD4RmAgAAQQ+2AcHnCEHB4AgL+EmDwQFBD7cMU0GLwMHoCw+vwTv4cxlEi8C4AAgAACvBwfgFZgPBA+1mQYkEU+sYRCvAK/gPt8FmwegFjWwtAWYryGZBiQxTg+4BdZKNRgGLy9PgRCvQiwQkQQPqg/gED42gAQAAg8AHg/0EjV4GiQQkjUYDjVYBD0zFweAGSJhNjZxFYAMAAEGB+AAAAAFMY9JzGk07zg+EvQEAAEEPtgHB5whBweAIC/hJg8EBQw+3DFNBi8DB6AsPr8E7+HMZRIvAuAAIAAArwcH4BWYDwQPSZkOJBFPrGEQrwCv4D7fBZsHoBY1UEgFmK8hmQ4kMU4PrAXWSg+pAg/oERIviD4z7AAAAQYPkAUSL0kHR+kGDzAJBg+oBg/oOfRlBi8pIY8JB0+RBi8xIK8hJjZxNXgUAAOtQQYPq" & _
            "BEGB+AAAAAFzGk07zg+EDwEAAEEPtgHB5whBweAIC/hJg8EBQdHoRQPkQTv4cgdBK/hBg8wBQYPqAXXFSY2dRAYAAEHB5ARBugQAAAC+AQAAAIvWQYH4AAAAAUxj2nMaTTvOD4S5AAAAQQ+2AcHnCEHB4AgL+EmDwQFCD7cMW0GLwMHoCw+vwTv4cxlEi8C4AAgAACvBwfgFZgPBA9JmQokEW+sbRCvAK/gPt8FmwegFjVQSAWYryEQL5mZCiQxbA/ZBg+oBdYxBg8QBdGBBi8SDxQJJY8xJO8d3RkiLlCSQAAAASYvHSCvBSAPCRIoYSIPAAUaIHDpJg8cBg+0BdApMO7wkmAAAAHLiiywkTDu8JJgAAABzFkSLVCQQ6ZT3//+4AQAAAOs4QYvD6zNBgfgAAAABcwlNO8505kmDwQFIi4QkiAAAAEwrTCR4TIkISIuEJKAAAABMiTgzwOsCi8NIg8QoQV9BXkFdQVxfXl1bw+lCjv//iUH///////9DAAAAABAAAACwAAAAAACAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" & _
            "AAAAAAAAAAAAAAAAAAABABAAAAAYAACAAAAAAAAAAAAAAAAAAAABAAEAAAAwAACAAAAAAAAAAAAAAAAAAAABAAkEAABIAAAAWNAAABgDAAAAAAAAAAAAABgDNAAAAFYAUwBfAFYARQBSAFMASQBPAE4AXwBJAE4ARgBPAAAAAAC9BO/+AAABAAIAAQACAAgAAgABAAIACAAAAAAAAAAAAAQAAAACAAAAAAAAAAAAAAAAAAAAdgIAAAEAUwB0AHIAaQBuAGcARgBpAGwAZQBJAG4AZgBvAAAAUgIAAAEAMAA0ADAAOQAwADQAQgAwAAAAMAAIAAEARgBpAGwAZQBWAGUAcgBzAGkAbwBuAAAAAAAxAC4AMgAuADgALgAyAAAANAAIAAEAUAByAG8AZAB1AGMAdABWAGUAcgBzAGkAbwBuAAAAMQAuADIALgA4AC4AMgAAAHoAKQABAEYAaQBsAGUARABlAHMAYwByAGkAcAB0AGkAbwBuAAAAAABQAHIAbwB2AGkAZABlAHMAIABvAGIAagBlAGMAdAAgAGYAdQBuAGMAdABpAG8AbgBhAGwAaQB0AHkAIABmAG8AcgAgAEEAdQB0AG8ASQB0AAAAAAA6AA0AAQBQAHIAbwBkAHUAYwB0AE4AYQBtAGUAAAAAAEEAdQB0AG8ASQB0AE8AYgBqAGUAYwB0AAAAAABYABoAAQBMAGUAZwBhAGwAQwBvAHAAeQByAGkAZwBoAHQAAAAoAEMAKQAgAFQAaABlACAAQQB1AHQAbwBJAHQATwBiAGoAZQBjAHQALQBUAGUAYQBtAAAASgARAAEATwByAGkAZwBpAG4AYQBsAEYAaQBsAGUAbgBhAG0AZQAAAEEAdQB0AG8ASQB0AE8AYgBqAGUAYwB0AC4AZABsAGwAAAAAAHoAIwABAFQAaABlACAAQQB1AHQAbwBJAHQATwBiAGoAZQBjAHQALQBUAGUAYQBtAAAAAABtAG8AbgBvAGMAZQByAGUAcwAsACAAdAByAGEA"
    $sData &= "bgBjAGUAeAB4ACwAIABLAGkAcAAsACAAUAByAG8AZwBBAG4AZAB5AAAAAABEAAAAAQBWAGEAcgBGAGkAbABlAEkAbgBmAG8AAAAAACQABAAAAFQAcgBhAG4AcwBsAGEAdABpAG8AbgAAAAAACQSwBAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=="
    Return __Au3Obj_Mem_Base64Decode($sData)
EndFunc   ;==>__Au3Obj_Mem_BinDll_X64

#EndRegion Embedded DLL
;--------------------------------------------------------------------------------------------------------------------------------------


;--------------------------------------------------------------------------------------------------------------------------------------
#Region DllStructCreate Wrapper

Func __Au3Obj_ObjStructMethod(ByRef $oSelf, $vParam1 = 0, $vParam2 = 0)
	Local $sMethod = $oSelf.__name__
	Local $tStructure = DllStructCreate($oSelf.__tag__, $oSelf.__pointer__)
	Local $vOut
	Switch @NumParams
		Case 1
			$vOut = DllStructGetData($tStructure, $sMethod)
		Case 2
			If $oSelf.__propcall__ Then
				$vOut = DllStructSetData($tStructure, $sMethod, $vParam1)
			Else
				$vOut = DllStructGetData($tStructure, $sMethod, $vParam1)
			EndIf
		Case 3
			$vOut = DllStructSetData($tStructure, $sMethod, $vParam2, $vParam1)
	EndSwitch
	If IsPtr($vOut) Then Return Number($vOut)
	Return $vOut
EndFunc   ;==>__Au3Obj_ObjStructMethod

Func __Au3Obj_ObjStructDestructor(ByRef $oSelf)
	If $oSelf.__new__ Then __Au3Obj_GlobalFree($oSelf.__pointer__)
EndFunc   ;==>__Au3Obj_ObjStructDestructor

Func __Au3Obj_ObjStructPointer(ByRef $oSelf, $vParam = Default)
	If $oSelf.__propcall__ Then Return SetError(1, 0, 0)
	If @NumParams = 1 Or IsKeyword($vParam) Then Return $oSelf.__pointer__
	Return Number(DllStructGetPtr(DllStructCreate($oSelf.__tag__, $oSelf.__pointer__), $vParam))
EndFunc   ;==>__Au3Obj_ObjStructPointer

#EndRegion DllStructCreate Wrapper
;--------------------------------------------------------------------------------------------------------------------------------------


;--------------------------------------------------------------------------------------------------------------------------------------
#Region Public UDFs

Global Enum $ELTYPE_NOTHING, $ELTYPE_METHOD, $ELTYPE_PROPERTY
Global Enum $ELSCOPE_PUBLIC, $ELSCOPE_READONLY, $ELSCOPE_PRIVATE

; #FUNCTION# ====================================================================================================================
; Name...........: _AutoItObject_AddDestructor
; Description ...: Adds a destructor to an AutoIt-object
; Syntax.........: _AutoItObject_AddDestructor(ByRef $oObject, $sAutoItFunc)
; Parameters ....: $oObject     - the object to modify
;                  $sAutoItFunc - the AutoIt-function wich represents this destructor.
; Return values .: Success      - True
;                  Failure      - 0
; Author ........: monoceres (Andreas Karlsson)
; Modified.......:
; Remarks .......: Adding a method that will be called on object destruction. Can be called multiple times.
; Related .......: _AutoItObject_AddProperty, _AutoItObject_AddEnum, _AutoItObject_RemoveMember, _AutoItObject_AddMethod
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _AutoItObject_AddDestructor(ByRef $oObject, $sAutoItFunc)
	Return _AutoItObject_AddMethod($oObject, "~", $sAutoItFunc, True)
EndFunc   ;==>_AutoItObject_AddDestructor

; #FUNCTION# ====================================================================================================================
; Name...........: _AutoItObject_AddEnum
; Description ...: Adds an Enum to an AutoIt-object
; Syntax.........: _AutoItObject_AddEnum(ByRef $oObject, $sNextFunc, $sResetFunc [, $sSkipFunc = ''])
; Parameters ....: $oObject     - the object to modify
;                  $sNextFunc   - The function to be called to get the next entry
;                  $sResetFunc  - The function to be called to reset the enum
;                  $sSkipFunc   - [optional] The function to be called to skip elements (not supported by AutoIt)
; Return values .: Success      - True
;                  Failure      - 0
; Author ........: Prog@ndy
; Modified.......:
; Remarks .......:
; Related .......: _AutoItObject_AddMethod, _AutoItObject_AddProperty, _AutoItObject_RemoveMember
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _AutoItObject_AddEnum(ByRef $oObject, $sNextFunc, $sResetFunc, $sSkipFunc = '')
	; Author: Prog@ndy
	If Not IsObj($oObject) Then Return SetError(2, 0, 0)
	DllCall($ghAutoItObjectDLL, "none", "AddEnum", "idispatch", $oObject, "wstr", $sNextFunc, "wstr", $sResetFunc, "wstr", $sSkipFunc)
	If @error Then Return SetError(1, @error, 0)
	Return True
EndFunc   ;==>_AutoItObject_AddEnum

; #FUNCTION# ====================================================================================================================
; Name...........: _AutoItObject_AddMethod
; Description ...: Adds a method to an AutoIt-object
; Syntax.........: _AutoItObject_AddMethod(ByRef $oObject, $sName, $sAutoItFunc [, $fPrivate = False])
; Parameters ....: $oObject     - the object to modify
;                  $sName       - the name of the method to add
;                  $sAutoItFunc - the AutoIt-function wich represents this method.
;                  $fPrivate    - [optional] Specifies whether the function can only be called from within the object. (default: False)
; Return values .: Success      - True
;                  Failure      - 0
; Author ........: Prog@ndy
; Modified.......:
; Remarks .......: The first parameter of the AutoIt-function is always a reference to the object. ($oSelf)
;                  This parameter will automatically be added and must not be given in the call.
;                  The function called '__default__' is accesible without a name using brackets ($return = $oObject())
; Related .......: _AutoItObject_AddProperty, _AutoItObject_AddEnum, _AutoItObject_RemoveMember
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _AutoItObject_AddMethod(ByRef $oObject, $sName, $sAutoItFunc, $fPrivate = False)
	; Author: Prog@ndy
	If Not IsObj($oObject) Then Return SetError(2, 0, 0)
	Local $iFlags = 0
	If $fPrivate Then $iFlags = $ELSCOPE_PRIVATE
	DllCall($ghAutoItObjectDLL, "none", "AddMethod", "idispatch", $oObject, "wstr", $sName, "wstr", $sAutoItFunc, 'dword', $iFlags)
	If @error Then Return SetError(1, @error, 0)
	Return True
EndFunc   ;==>_AutoItObject_AddMethod

; #FUNCTION# ====================================================================================================================
; Name...........: _AutoItObject_AddProperty
; Description ...: Adds a property to an AutoIt-object
; Syntax.........: _AutoItObject_AddProperty(ByRef $oObject, $sName [, $iFlags = $ELSCOPE_PUBLIC [, $vData = ""]])
; Parameters ....: $oObject     - the object to modify
;                  $sName       - the name of the property to add
;                  $iFlags      - [optional] Specifies the access to the property
;                  $vData       - [optional] Initial data for the property
; Return values .: Success      - True
;                  Failure      - 0
; Author ........: Prog@ndy
; Modified.......:
; Remarks .......: The property called '__default__' is accesible without a name using brackets ($value = $oObject())
;                  + $iFlags can be:
;                  |$ELSCOPE_PUBLIC   - The Property has public access.
;                  |$ELSCOPE_READONLY - The property is read-only and can only be changed from within the object.
;                  |$ELSCOPE_PRIVATE  - The property is private and can only be accessed from within the object.
;                  +
;                  + Initial default value for every new property is nothing (no value).
; Related .......: _AutoItObject_AddMethod, _AutoItObject_AddEnum, _AutoItObject_RemoveMember
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _AutoItObject_AddProperty(ByRef $oObject, $sName, $iFlags = $ELSCOPE_PUBLIC, $vData = "")
	; Author: Prog@ndy
	Local Static $tStruct = DllStructCreate($__Au3Obj_tagVARIANT)
	If Not IsObj($oObject) Then Return SetError(2, 0, 0)
	Local $pData = 0
	If @NumParams = 4 Then
		$pData = DllStructGetPtr($tStruct)
		_AutoItObject_VariantInit($pData)
		$oObject.__bridge__(Number($pData)) = $vData
	EndIf
	DllCall($ghAutoItObjectDLL, "none", "AddProperty", "idispatch", $oObject, "wstr", $sName, 'dword', $iFlags, 'ptr', $pData)
	Local $error = @error
	If $pData Then _AutoItObject_VariantClear($pData)
	If $error Then Return SetError(1, $error, 0)
	Return True
EndFunc   ;==>_AutoItObject_AddProperty

; #FUNCTION# ====================================================================================================================
; Name...........: _AutoItObject_Class
; Description ...: AutoItObject COM wrapper function
; Syntax.........: _AutoItObject_Class()
; Parameters ....:
; Return values .: Success      - object with defined:
;                   -methods:
;                  |	Create([$oParent = 0]) - creates AutoItObject object
;                  |	AddMethod($sName, $sAutoItFunc [, $fPrivate = False]) - adds new method
;                  |	AddProperty($sName, $iFlags = $ELSCOPE_PUBLIC, $vData = 0) - adds new property
;                  |	AddDestructor($sAutoItFunc) - adds destructor
;                  |	AddEnum($sNextFunc, $sResetFunc [, $sSkipFunc = '']) - adds enum
;                  |	RemoveMember($sMember) - removes member
;                   -properties:
;                  |	Object - readonly property representing the last created AutoItObject object
; Author ........: trancexx
; Modified.......:
; Remarks .......: "Object" propery can be accessed only once for one object. After that new AutoItObject object is created.
;                  +Method "Create" will discharge previous AutoItObject object and create a new one.
; Related .......: _AutoItObject_Create
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _AutoItObject_Class()
	Local $aCall = DllCall($ghAutoItObjectDLL, "idispatch", "CreateAutoItObjectClass")
	If @error Then Return SetError(1, @error, 0)
	Return $aCall[0]
EndFunc   ;==>_AutoItObject_Class

; #FUNCTION# ====================================================================================================================
; Name...........: _AutoItObject_CLSIDFromString
; Description ...: Converts a string to a CLSID-Struct (GUID-Struct)
; Syntax.........: _AutoItObject_CLSIDFromString($sString)
; Parameters ....: $sString     - The string to convert
; Return values .: Success      - DLLStruct in format $tagGUID
;                  Failure      - 0
; Author ........: Prog@ndy
; Modified.......:
; Remarks .......:
; Related .......: _AutoItObject_CoCreateInstance
; Link ..........: http://msdn.microsoft.com/en-us/library/ms680589(VS.85).aspx
; Example .......:
; ===============================================================================================================================
Func _AutoItObject_CLSIDFromString($sString)
	Local $tCLSID = DllStructCreate("dword;word;word;byte[8]")
	Local $aResult = DllCall($gh_AU3Obj_ole32dll, 'long', 'CLSIDFromString', 'wstr', $sString, 'ptr', DllStructGetPtr($tCLSID))
	If @error Then Return SetError(1, @error, 0)
	If $aResult[0] <> 0 Then Return SetError(2, $aResult[0], 0)
	Return $tCLSID
EndFunc   ;==>_AutoItObject_CLSIDFromString

; #FUNCTION# ====================================================================================================================
; Name...........: _AutoItObject_CoCreateInstance
; Description ...: Creates a single uninitialized object of the class associated with a specified CLSID.
; Syntax.........: _AutoItObject_CoCreateInstance($rclsid, $pUnkOuter, $dwClsContext, $riid, ByRef $ppv)
; Parameters ....: $rclsid       - The CLSID associated with the data and code that will be used to create the object.
;                  $pUnkOuter    - If NULL, indicates that the object is not being created as part of an aggregate.
;                  +If non-NULL, pointer to the aggregate object's IUnknown interface (the controlling IUnknown).
;                  $dwClsContext - Context in which the code that manages the newly created object will run.
;                  +The values are taken from the enumeration CLSCTX.
;                  $riid         - A reference to the identifier of the interface to be used to communicate with the object.
;                  $ppv          - [out byref] Variable that receives the interface pointer requested in riid.
;                  +Upon successful return, *ppv contains the requested interface pointer. Upon failure, *ppv contains NULL.
; Return values .: Success      - True
;                  Failure      - 0
; Author ........: Prog@ndy
; Modified.......:
; Remarks .......:
; Related .......: _AutoItObject_ObjCreate, _AutoItObject_CLSIDFromString
; Link ..........: http://msdn.microsoft.com/en-us/library/ms686615(VS.85).aspx
; Example .......:
; ===============================================================================================================================
Func _AutoItObject_CoCreateInstance($rclsid, $pUnkOuter, $dwClsContext, $riid, ByRef $ppv)
	$ppv = 0
	Local $aResult = DllCall($gh_AU3Obj_ole32dll, 'long', 'CoCreateInstance', 'ptr', $rclsid, 'ptr', $pUnkOuter, 'dword', $dwClsContext, 'ptr', $riid, 'ptr*', 0)
	If @error Then Return SetError(1, @error, 0)
	$ppv = $aResult[5]
	Return SetError($aResult[0], 0, $aResult[0] = 0)
EndFunc   ;==>_AutoItObject_CoCreateInstance

; #FUNCTION# ====================================================================================================================
; Name...........: _AutoItObject_Create
; Description ...: Creates an AutoIt-object
; Syntax.........: _AutoItObject_Create( [$oParent = 0] )
; Parameters ....: $oParent     - [optional] an AutoItObject whose methods & properties are copied. (default: 0)
; Return values .: Success      - AutoIt-Object
;                  Failure      - 0
; Author ........: Prog@ndy
; Modified.......:
; Remarks .......:
; Related .......: _AutoItObject_Class
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _AutoItObject_Create($oParent = 0)
	; Author: Prog@ndy
	Local $aResult
	Switch IsObj($oParent)
		Case True
			$aResult = DllCall($ghAutoItObjectDLL, "idispatch", "CloneAutoItObject", 'idispatch', $oParent)
		Case Else
			$aResult = DllCall($ghAutoItObjectDLL, "idispatch", "CreateAutoItObject")
	EndSwitch
	If @error Then Return SetError(1, @error, 0)
	Return $aResult[0]
EndFunc   ;==>_AutoItObject_Create

; #FUNCTION# ====================================================================================================================
; Name...........: _AutoItObject_DllOpen
; Description ...: Creates an object associated with specified dll
; Syntax.........: _AutoItObject_DllOpen($sDll [, $sTag = "" [, $iFlag = 0]])
; Parameters ....: $sDll - Dll for which to create an object
;                  $sTag - [optional] String representing function return value and parameters.
;                  $iFlag - [optional] Flag specifying the level of loading. See MSDN about LoadLibraryEx function for details. Default is 0.
; Return values .: Success      - Dispatch-Object
;                  Failure      - 0
; Author ........: trancexx
; Modified.......:
; Remarks .......:
; Related .......: _AutoItObject_WrapperCreate
; Link ..........: http://msdn.microsoft.com/en-us/library/ms684179(VS.85).aspx
; Example .......:
; ===============================================================================================================================
Func _AutoItObject_DllOpen($sDll, $sTag = "", $iFlag = 0)
	Local $sTypeTag = "wstr"
	If $sTag = Default Or Not $sTag Then $sTypeTag = "ptr"
	Local $aCall = DllCall($ghAutoItObjectDLL, "idispatch", "CreateDllCallObject", "wstr", $sDll, $sTypeTag, __Au3Obj_GetMethods($sTag), "dword", $iFlag)
	If @error Or Not IsObj($aCall[0]) Then Return SetError(1, 0, 0)
	Return $aCall[0]
EndFunc   ;==>_AutoItObject_DllOpen

; #FUNCTION# ====================================================================================================================
; Name...........: _AutoItObject_DllStructCreate
; Description ...: Object wrapper for DllStructCreate and related functions
; Syntax.........: _AutoItObject_DllStructCreate($sTag [, $vParam = 0])
; Parameters ....: $sTag     - A string representing the structure to create (same as with DllStructCreate)
;                  $vParam   - [optional] If this parameter is DLLStruct type then it will be copied to newly allocated space and maintained during lifetime of the object. If this parameter is not suplied needed memory allocation is done but content is initialized to zero. In all other cases function will not allocate memory but use parameter supplied as the pointer (same as DllStructCreate)
; Return values .: Success      - Object-structure
;                  Failure      - 0, @error is set to error value of DllStructCreate() function.
; Author ........: trancexx
; Modified.......:
; Remarks .......: AutoIt can't handle pointers properly when passed to or returned from object methods. Use Number() function on pointers before using them with this function.
;                  +Every element of structure must be named. Values are accessed through their names.
;                  +Created object exposes:
;                  +  - set of dynamic methods in names of elements of the structure
;                  +  - readonly properties:
;                  |	__tag__ - a string representing the object-structure
;                  |	__size__ - the size of the struct in bytes
;                  |	__alignment__ - alignment string (e.g. "align 2")
;                  |	__count__ - number of elements of structure
;                  |	__elements__ - string made of element names separated by semicolon (;)
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _AutoItObject_DllStructCreate($sTag, $vParam = 0)
	Local $fNew = False
	Local $tSubStructure = DllStructCreate($sTag)
	If @error Then Return SetError(@error, 0, 0)
	Local $iSize = DllStructGetSize($tSubStructure)
	Local $pPointer = $vParam
	Select
		Case @NumParams = 1
			; Will allocate fixed 128 extra bytes due to possible misalignment and other issues
			$pPointer = __Au3Obj_GlobalAlloc($iSize + 128, 64) ; GPTR
			If @error Then Return SetError(3, 0, 0)
			$fNew = True
		Case IsDllStruct($vParam)
			$pPointer = __Au3Obj_GlobalAlloc($iSize, 64) ; GPTR
			If @error Then Return SetError(3, 0, 0)
			$fNew = True
			DllStructSetData(DllStructCreate("byte[" & $iSize & "]", $pPointer), 1, DllStructGetData(DllStructCreate("byte[" & $iSize & "]", DllStructGetPtr($vParam)), 1))
		Case @NumParams = 2 And $vParam = 0
			Return SetError(3, 0, 0)
	EndSelect
	Local $sAlignment
	Local $sNamesString = __Au3Obj_ObjStructGetElements($sTag, $sAlignment)
	Local $aElements = StringSplit($sNamesString, ";", 2)
	Local $oObj = _AutoItObject_Class()
	For $i = 0 To UBound($aElements) - 1
		$oObj.AddMethod($aElements[$i], "__Au3Obj_ObjStructMethod")
	Next
	$oObj.AddProperty("__tag__", $ELSCOPE_READONLY, $sTag)
	$oObj.AddProperty("__size__", $ELSCOPE_READONLY, $iSize)
	$oObj.AddProperty("__alignment__", $ELSCOPE_READONLY, $sAlignment)
	$oObj.AddProperty("__count__", $ELSCOPE_READONLY, UBound($aElements))
	$oObj.AddProperty("__elements__", $ELSCOPE_READONLY, $sNamesString)
	$oObj.AddProperty("__new__", $ELSCOPE_PRIVATE, $fNew)
	$oObj.AddProperty("__pointer__", $ELSCOPE_READONLY, Number($pPointer))
	$oObj.AddMethod("__default__", "__Au3Obj_ObjStructPointer")
	$oObj.AddDestructor("__Au3Obj_ObjStructDestructor")
	Return $oObj.Object
EndFunc   ;==>_AutoItObject_DllStructCreate

; #FUNCTION# ====================================================================================================================
; Name...........: _AutoItObject_IDispatchToPtr
; Description ...: Returns pointer to AutoIt's object type
; Syntax.........: _AutoItObject_IDispatchToPtr(ByRef $oIDispatch)
; Parameters ....: $oIDispatch  - Object
; Return values .: Success      - Pointer to object
;                  Failure      - 0
; Author ........: monoceres, trancexx
; Modified.......:
; Remarks .......:
; Related .......: _AutoItObject_PtrToIDispatch, _AutoItObject_CoCreateInstance, _AutoItObject_ObjCreate
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _AutoItObject_IDispatchToPtr($oIDispatch)
	Local $aCall = DllCall($ghAutoItObjectDLL, "ptr", "ReturnThis", "idispatch", $oIDispatch)
	If @error Then Return SetError(1, 0, 0)
	Return $aCall[0]
EndFunc   ;==>_AutoItObject_IDispatchToPtr

; #FUNCTION# ====================================================================================================================
; Name...........: _AutoItObject_IUnknownAddRef
; Description ...: Increments the refrence count of an IUnknown-Object
; Syntax.........: _AutoItObject_IUnknownAddRef($vUnknown)
; Parameters ....: $vUnknown    - IUnkown-pointer or object itself
; Return values .: Success      - New reference count.
;                  Failure      - 0, @error is set.
; Author ........: Prog@ndy
; Modified.......:
; Remarks .......:
; Related .......: _AutoItObject_IUnknownRelease
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _AutoItObject_IUnknownAddRef(Const $vUnknown)
	; Author: Prog@ndy
	Local $sType = "ptr"
	If IsObj($vUnknown) Then $sType = "idispatch"
	Local $aCall = DllCall($ghAutoItObjectDLL, "dword", "IUnknownAddRef", $sType, $vUnknown)
	If @error Then Return SetError(1, @error, 0)
	Return $aCall[0]
EndFunc   ;==>_AutoItObject_IUnknownAddRef

; #FUNCTION# ====================================================================================================================
; Name...........: _AutoItObject_IUnknownRelease
; Description ...: Decrements the refrence count of an IUnknown-Object
; Syntax.........: _AutoItObject_IUnknownRelease($vUnknown)
; Parameters ....: $vUnknown    - IUnkown-pointer or object itself
; Return values .: Success      - New reference count.
;                  Failure      - 0, @error is set.
; Author ........: trancexx
; Modified.......:
; Remarks .......:
; Related .......: _AutoItObject_IUnknownAddRef
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _AutoItObject_IUnknownRelease(Const $vUnknown)
	Local $sType = "ptr"
	If IsObj($vUnknown) Then $sType = "idispatch"
	Local $aCall = DllCall($ghAutoItObjectDLL, "dword", "IUnknownRelease", $sType, $vUnknown)
	If @error Then Return SetError(1, @error, 0)
	Return $aCall[0]
EndFunc   ;==>_AutoItObject_IUnknownRelease

; #FUNCTION# ====================================================================================================================
; Name...........: _AutoItObject_ObjCreate
; Description ...: Creates a reference to a COM object
; Syntax.........: _AutoItObject_ObjCreate($sID [, $sRefId = Default [, $tagInterface = Default ]] )
; Parameters ....: $sID - Object identifier. Either string representation of CLSID or ProgID
;                  $sRefId - [optional] String representation of the identifier of the interface to be used to communicate with the object. Default is the value of IDispatch
;                  $tagInterface - [optional] String defining the methods of the Interface, see Remarks for _AutoItObject_WrapperCreate function for details
; Return values .: Success      - Dispatch-Object
;                  Failure      - 0
; Author ........: trancexx
; Modified.......:
; Remarks .......: Prefix object identifier with "cbi:" to create object from ROT.
; Related .......: _AutoItObject_ObjCreateEx, _AutoItObject_WrapperCreate
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _AutoItObject_ObjCreate($sID, $sRefId = Default, $tagInterface = Default)
	Local $sTypeRef = "wstr"
	If $sRefId = Default Or Not $sRefId Then $sTypeRef = "ptr"
	Local $sTypeTag = "wstr"
	If $tagInterface = Default Or Not $tagInterface Then $sTypeTag = "ptr"
	Local $aCall = DllCall($ghAutoItObjectDLL, "idispatch", "AutoItObjectCreateObject", "wstr", $sID, $sTypeRef, $sRefId, $sTypeTag, __Au3Obj_GetMethods($tagInterface))
	If @error Or Not IsObj($aCall[0]) Then Return SetError(1, 0, 0)
	If $sTypeRef = "ptr" And $sTypeTag = "ptr" Then _AutoItObject_IUnknownRelease($aCall[0])
	Return $aCall[0]
EndFunc   ;==>_AutoItObject_ObjCreate

; #FUNCTION# ====================================================================================================================
; Name...........: _AutoItObject_ObjCreateEx
; Description ...: Creates a reference to a COM object
; Syntax.........: _AutoItObject_ObjCreateEx($sModule, $sCLSID [, $sRefId = Default [, $tagInterface = Default [, $fWrapp = False]]] )
; Parameters ....: $sModule - Full path to the module with class (object)
;                  $sCLSID - Object identifier. String representation of CLSID.
;                  $sRefId - [optional] String representation of the identifier of the interface to be used to communicate with the object. Default is the value of IDispatch
;                  $tagInterface - [optional] String defining the methods of the Interface, see Remarks for _AutoItObject_WrapperCreate function for details
;                  $fWrapped - [optional] Specifies whether to wrapp created object.
; Return values .: Success      - Dispatch-Object
;                  Failure      - 0
; Author ........: trancexx
; Modified.......:
; Remarks .......: This function doesn't require any additional registration of the classes and interaces supported in the server module.
;                 +In case $tagInterface is specified $fWrapp parameter is ignored.
;                 +If $sRefId is left default then first supported interface by the coclass is returned (the default dispatch).
;                 +
;                 +If used to for ROT objects $sModule parameter represents the full path to the server (any form: exe, a3x or au3). Default time-out value for the function is 3000ms in that case. If required object isn't created in that time function will return failure.
;                 +This function sends "/StartServer" command to the server to initialize it.
; Related .......: _AutoItObject_ObjCreate, _AutoItObject_WrapperCreate
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _AutoItObject_ObjCreateEx($sModule, $sID, $sRefId = Default, $tagInterface = Default, $fWrapp = False, $iTimeOut = Default)
	Local $sTypeRef = "wstr"
	If $sRefId = Default Or Not $sRefId Then $sTypeRef = "ptr"
	Local $sTypeTag = "wstr"
	If $tagInterface = Default Or Not $tagInterface Then
		$sTypeTag = "ptr"
	Else
		$fWrapp = True
	EndIf
	If $iTimeOut = Default Then $iTimeOut = 0
	Local $aCall = DllCall($ghAutoItObjectDLL, "idispatch", "AutoItObjectCreateObjectEx", "wstr", $sModule, "wstr", $sID, $sTypeRef, $sRefId, $sTypeTag, __Au3Obj_GetMethods($tagInterface), "bool", $fWrapp, "dword", $iTimeOut)
	If @error Or Not IsObj($aCall[0]) Then Return SetError(1, 0, 0)
	If Not $fWrapp Then _AutoItObject_IUnknownRelease($aCall[0])
	Return $aCall[0]
EndFunc   ;==>_AutoItObject_ObjCreateEx

; #FUNCTION# ====================================================================================================================
; Name...........: _AutoItObject_ObjectFromDtag
; Description ...: Creates custom object defined with "dtag" interface description string
; Syntax.........: _AutoItObject_ObjectFromDtag($sFunctionPrefix, $dtagInterface [, $fNoUnknown = False])
; Parameters ....: $sFunctionPrefix  - The prefix of the functions you define as object methods
;                  $dtagInterface - string describing the interface (dtag)
;                  $fNoUnknown - [optional] NOT an IUnkown-Interface. Do not call "Release" method when out of scope (Default: False, meaining to call Release method)
; Return values .: Success      - object type
;                  Failure      - 0
; Author ........: trancexx
; Modified.......:
; Remarks .......: Main purpose of this function is to create custom objects that serve as event handlers for other objects.
;                  +Registered callback functions (defined methods) are left for AutoIt to free at its convenience on exit.
; Related .......: _AutoItObject_ObjCreate, _AutoItObject_ObjCreateEx, _AutoItObject_WrapperCreate
; Link ..........: http://msdn.microsoft.com/en-us/library/ms692727(VS.85).aspx
; Example .......:
; ===============================================================================================================================
Func _AutoItObject_ObjectFromDtag($sFunctionPrefix, $dtagInterface, $fNoUnknown = False)
	Local $sMethods = __Au3Obj_GetMethods($dtagInterface)
	$sMethods = StringReplace(StringReplace(StringReplace(StringReplace($sMethods, "object", "idispatch"), "variant*", "ptr"), "hresult", "long"), "bstr", "ptr")
	Local $aMethods = StringSplit($sMethods, @LF, 3)
	Local $iUbound = UBound($aMethods)
	Local $sMethod, $aSplit, $sNamePart, $aTagPart, $sTagPart, $sRet, $sParams
	; Allocation. Read http://msdn.microsoft.com/en-us/library/ms810466.aspx to see why like this (object + methods):
	Local $tInterface = DllStructCreate("ptr[" & $iUbound + 1 & "]", __Au3Obj_CoTaskMemAlloc($__Au3Obj_PTR_SIZE * ($iUbound + 1)))
	If @error Then Return SetError(1, 0, 0)
	For $i = 0 To $iUbound - 1
		$aSplit = StringSplit($aMethods[$i], "|", 2)
		If UBound($aSplit) <> 2 Then ReDim $aSplit[2]
		$sNamePart = $aSplit[0]
		$sTagPart = $aSplit[1]
		$sMethod = $sFunctionPrefix & $sNamePart
		$aTagPart = StringSplit($sTagPart, ";", 2)
		$sRet = $aTagPart[0]
		$sParams = StringReplace($sTagPart, $sRet, "", 1)
		$sParams = "ptr" & $sParams
		DllStructSetData($tInterface, 1, DllCallbackGetPtr(DllCallbackRegister($sMethod, $sRet, $sParams)), $i + 2) ; Freeing is left to AutoIt.
	Next
	DllStructSetData($tInterface, 1, DllStructGetPtr($tInterface) + $__Au3Obj_PTR_SIZE) ; Interface method pointers are actually pointer size away
	Return _AutoItObject_WrapperCreate(DllStructGetPtr($tInterface), $dtagInterface, $fNoUnknown, True) ; and first pointer is object pointer that's wrapped
EndFunc   ;==>_AutoItObject_ObjectFromDtag

; #FUNCTION# ====================================================================================================================
; Name...........: _AutoItObject_PtrToIDispatch
; Description ...: Converts IDispatch pointer to AutoIt's object type
; Syntax.........: _AutoItObject_PtrToIDispatch($pIDispatch)
; Parameters ....: $pIDispatch  - IDispatch pointer
; Return values .: Success      - object type
;                  Failure      - 0
; Author ........: monoceres, trancexx
; Modified.......:
; Remarks .......:
; Related .......: _AutoItObject_IDispatchToPtr, _AutoItObject_WrapperCreate
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _AutoItObject_PtrToIDispatch($pIDispatch)
	Local $aCall = DllCall($ghAutoItObjectDLL, "idispatch", "ReturnThis", "ptr", $pIDispatch)
	If @error Then Return SetError(1, 0, 0)
	Return $aCall[0]
EndFunc   ;==>_AutoItObject_PtrToIDispatch

; #FUNCTION# ====================================================================================================================
; Name...........: _AutoItObject_RegisterObject
; Description ...: Registers the object to ROT
; Syntax.........: _AutoItObject_RegisterObject($vObject, $sID)
; Parameters ....: $vObject - Object or object pointer.
;                  $sID - Object's desired identifier.
; Return values .: Success      - Handle of the ROT object.
;                  Failure      - 0
; Author ........: trancexx
; Modified.......:
; Remarks .......:
; Related .......: _AutoItObject_UnregisterObject
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _AutoItObject_RegisterObject($vObject, $sID)
	Local $sTypeObj = "ptr"
	If IsObj($vObject) Then $sTypeObj = "idispatch"
	Local $aCall = DllCall($ghAutoItObjectDLL, "dword", "RegisterObject", $sTypeObj, $vObject, "wstr", $sID)
	If @error Or Not $aCall[0] Then Return SetError(1, 0, 0)
	Return $aCall[0]
EndFunc   ;==>_AutoItObject_RegisterObject

; #FUNCTION# ====================================================================================================================
; Name...........: _AutoItObject_RemoveMember
; Description ...: Removes a property or a function from an AutoIt-object
; Syntax.........: _AutoItObject_RemoveMember(ByRef $oObject, $sMember)
; Parameters ....: $oObject     - the object to modify
;                  $sMember     - the name of the member to remove
; Return values .: Success      - True
;                  Failure      - 0
; Author ........: Prog@ndy
; Modified.......:
; Remarks .......:
; Related .......: _AutoItObject_AddMethod, _AutoItObject_AddProperty, _AutoItObject_AddEnum
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _AutoItObject_RemoveMember(ByRef $oObject, $sMember)
	; Author: Prog@ndy
	If Not IsObj($oObject) Then Return SetError(2, 0, 0)
	If $sMember = '__default__' Then Return SetError(3, 0, 0)
	DllCall($ghAutoItObjectDLL, "none", "RemoveMember", "idispatch", $oObject, "wstr", $sMember)
	If @error Then Return SetError(1, @error, 0)
	Return True
EndFunc   ;==>_AutoItObject_RemoveMember

; #FUNCTION# ====================================================================================================================
; Name...........: _AutoItObject_Shutdown
; Description ...: frees the AutoItObject DLL
; Syntax.........: _AutoItObject_Shutdown()
; Parameters ....: $fFinal    - [optional] Force shutdown of the library? (Default: False)
; Return values .: Remaining reference count (one for each call to _AutoItObject_Startup)
; Author ........: Prog@ndy
; Modified.......:
; Remarks .......: Usage of this function is optonal. The World wouldn't end without it.
; Related .......: _AutoItObject_Startup
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _AutoItObject_Shutdown($fFinal = False)
	; Author: Prog@ndy
	If $giAutoItObjectDLLRef <= 0 Then Return 0
	$giAutoItObjectDLLRef -= 1
	If $fFinal Then $giAutoItObjectDLLRef = 0
	If $giAutoItObjectDLLRef = 0 Then DllCall($ghAutoItObjectDLL, "ptr", "Initialize", "ptr", 0, "ptr", 0)
	Return $giAutoItObjectDLLRef
EndFunc   ;==>_AutoItObject_Shutdown

; #FUNCTION# ====================================================================================================================
; Name...........: _AutoItObject_Startup
; Description ...: Initializes AutoItObject
; Syntax.........: _AutoItObject_Startup( [$fLoadDLL = False [, $sDll = "AutoitObject.dll"]] )
; Parameters ....: $fLoadDLL    - [optional] specifies whether an external DLL-file should be used (default: False)
;                  $sDLL        - [optional] the path to the external DLL (default: AutoitObject.dll or AutoitObject_X64.dll)
; Return values .: Success      - True
;                  Failure      - False
; Author ........: trancexx, Prog@ndy
; Modified.......:
; Remarks .......: Automatically switches between 32bit and 64bit mode if no special DLL is specified.
; Related .......: _AutoItObject_Shutdown
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _AutoItObject_Startup($fLoadDLL = False, $sDll = "AutoitObject.dll")
	Local Static $__Au3Obj_FunctionProxy = DllCallbackGetPtr(DllCallbackRegister("__Au3Obj_FunctionProxy", "int", "wstr;idispatch"))
	Local Static $__Au3Obj_EnumFunctionProxy = DllCallbackGetPtr(DllCallbackRegister("__Au3Obj_EnumFunctionProxy", "int", "dword;wstr;idispatch;ptr;ptr"))
	If $ghAutoItObjectDLL = -1 Then
		If $fLoadDLL Then
			If $__Au3Obj_X64 And @NumParams = 1 Then $sDll = "AutoItObject_X64.dll"
			$ghAutoItObjectDLL = DllOpen($sDll)
		Else
			$ghAutoItObjectDLL = __Au3Obj_Mem_DllOpen()
		EndIf
		If $ghAutoItObjectDLL = -1 Then Return SetError(1, 0, False)
	EndIf
	If $giAutoItObjectDLLRef <= 0 Then
		$giAutoItObjectDLLRef = 0
		DllCall($ghAutoItObjectDLL, "ptr", "Initialize", "ptr", $__Au3Obj_FunctionProxy, "ptr", $__Au3Obj_EnumFunctionProxy)
		If @error Then
			DllClose($ghAutoItObjectDLL)
			$ghAutoItObjectDLL = -1
			Return SetError(2, 0, False)
		EndIf
	EndIf
	$giAutoItObjectDLLRef += 1
	Return True
EndFunc   ;==>_AutoItObject_Startup

; #FUNCTION# ====================================================================================================================
; Name...........: _AutoItObject_UnregisterObject
; Description ...: Unregisters the object from ROT
; Syntax.........: _AutoItObject_UnregisterObject($iHandle)
; Parameters ....: $iHandle - Object's ROT handle as returned by _AutoItObject_RegisterObject function.
; Return values .: Success      - 1
;                  Failure      - 0
; Author ........: trancexx
; Modified.......:
; Remarks .......:
; Related .......: _AutoItObject_RegisterObject
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _AutoItObject_UnregisterObject($iHandle)
	Local $aCall = DllCall($ghAutoItObjectDLL, "dword", "UnRegisterObject", "dword", $iHandle)
	If @error Or Not $aCall[0] Then Return SetError(1, 0, 0)
	Return 1
EndFunc   ;==>_AutoItObject_UnregisterObject

; #FUNCTION# ====================================================================================================================
; Name...........: _AutoItObject_VariantClear
; Description ...: Clears the value of a variant
; Syntax.........: _AutoItObject_VariantClear($pvarg)
; Parameters ....: $pvarg       - the VARIANT to clear
; Return values .: Success      - 0
;                  Failure      - nonzero
; Author ........: Prog@ndy
; Modified.......:
; Remarks .......:
; Related .......: _AutoItObject_VariantFree
; Link ..........: http://msdn.microsoft.com/en-us/library/ms221165.aspx
; Example .......:
; ===============================================================================================================================
Func _AutoItObject_VariantClear($pvarg)
	; Author: Prog@ndy
	Local $aCall = DllCall($gh_AU3Obj_oleautdll, "long", "VariantClear", "ptr", $pvarg)
	If @error Then Return SetError(1, 0, 1)
	Return $aCall[0]
EndFunc   ;==>_AutoItObject_VariantClear

; #FUNCTION# ====================================================================================================================
; Name...........: _AutoItObject_VariantCopy
; Description ...: Copies a VARIANT to another
; Syntax.........: _AutoItObject_VariantCopy($pvargDest, $pvargSrc)
; Parameters ....: $pvargDest   - Destionation variant
;                  $pvargSrc    - Source variant
; Return values .: Success      - 0
;                  Failure      - nonzero
; Author ........: Prog@ndy
; Modified.......:
; Remarks .......:
; Related .......: _AutoItObject_VariantRead
; Link ..........: http://msdn.microsoft.com/en-us/library/ms221697.aspx
; Example .......:
; ===============================================================================================================================
Func _AutoItObject_VariantCopy($pvargDest, $pvargSrc)
	; Author: Prog@ndy
	Local $aCall = DllCall($gh_AU3Obj_oleautdll, "long", "VariantCopy", "ptr", $pvargDest, 'ptr', $pvargSrc)
	If @error Then Return SetError(1, 0, 1)
	Return $aCall[0]
EndFunc   ;==>_AutoItObject_VariantCopy

; #FUNCTION# ====================================================================================================================
; Name...........: _AutoItObject_VariantFree
; Description ...: Frees a variant created by _AutoItObject_VariantSet
; Syntax.........: _AutoItObject_VariantFree($pvarg)
; Parameters ....: $pvarg       - the VARIANT to free
; Return values .: Success      - 0
;                  Failure      - nonzero
; Author ........: Prog@ndy
; Modified.......:
; Remarks .......: Use this function on variants created with _AutoItObject_VariantSet function (when first parameter for that function is 0).
; Related .......: _AutoItObject_VariantClear
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _AutoItObject_VariantFree($pvarg)
	; Author: Prog@ndy
	Local $aCall = DllCall($gh_AU3Obj_oleautdll, "long", "VariantClear", "ptr", $pvarg)
	If @error Then Return SetError(1, 0, 1)
	If $aCall[0] = 0 Then __Au3Obj_CoTaskMemFree($pvarg)
	Return $aCall[0]
EndFunc   ;==>_AutoItObject_VariantFree

; #FUNCTION# ====================================================================================================================
; Name...........: _AutoItObject_VariantInit
; Description ...: Initializes a variant.
; Syntax.........: _AutoItObject_VariantInit($pvarg)
; Parameters ....: $pvarg       - the VARIANT to initialize
; Return values .: Success      - 0
;                  Failure      - nonzero
; Author ........: Prog@ndy
; Modified.......:
; Remarks .......:
; Related .......: _AutoItObject_VariantClear
; Link ..........: http://msdn.microsoft.com/en-us/library/ms221402.aspx
; Example .......:
; ===============================================================================================================================
Func _AutoItObject_VariantInit($pvarg)
	; Author: Prog@ndy
	Local $aCall = DllCall($gh_AU3Obj_oleautdll, "long", "VariantInit", "ptr", $pvarg)
	If @error Then Return SetError(1, 0, 1)
	Return $aCall[0]
EndFunc   ;==>_AutoItObject_VariantInit

; #FUNCTION# ====================================================================================================================
; Name...........: _AutoItObject_VariantRead
; Description ...: Reads the value of a VARIANT
; Syntax.........: _AutoItObject_VariantRead($pVariant)
; Parameters ....: $pVariant    - Pointer to VARaINT-structure
; Return values .: Success      - value of the VARIANT
;                  Failure      - 0
; Author ........: monoceres, Prog@ndy
; Modified.......:
; Remarks .......:
; Related .......: _AutoItObject_VariantSet
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _AutoItObject_VariantRead($pVariant)
	; Author: monoceres, Prog@ndy
	Local $var = DllStructCreate($__Au3Obj_tagVARIANT, $pVariant), $data
	; Translate the vt id to a autoit dllcall type
	Local $VT = DllStructGetData($var, "vt"), $type
	Switch $VT
		Case $__Au3Obj_VT_I1, $__Au3Obj_VT_UI1
			$type = "byte"
		Case $__Au3Obj_VT_I2
			$type = "short"
		Case $__Au3Obj_VT_I4
			$type = "int"
		Case $__Au3Obj_VT_I8
			$type = "int64"
		Case $__Au3Obj_VT_R4
			$type = "float"
		Case $__Au3Obj_VT_R8
			$type = "double"
		Case $__Au3Obj_VT_UI2
			$type = 'word'
		Case $__Au3Obj_VT_UI4
			$type = 'uint'
		Case $__Au3Obj_VT_UI8
			$type = 'uint64'
		Case $__Au3Obj_VT_BSTR
			Return __Au3Obj_SysReadString(DllStructGetData($var, "data"))
		Case $__Au3Obj_VT_BOOL
			$type = 'short'
		Case BitOR($__Au3Obj_VT_ARRAY, $__Au3Obj_VT_UI1)
			Local $pSafeArray = DllStructGetData($var, "data")
			Local $bound, $pData, $lbound
			If 0 = __Au3Obj_SafeArrayGetUBound($pSafeArray, 1, $bound) Then
				__Au3Obj_SafeArrayGetLBound($pSafeArray, 1, $lbound)
				$bound += 1 - $lbound
				If 0 = __Au3Obj_SafeArrayAccessData($pSafeArray, $pData) Then
					Local $tData = DllStructCreate("byte[" & $bound & "]", $pData)
					$data = DllStructGetData($tData, 1)
					__Au3Obj_SafeArrayUnaccessData($pSafeArray)
				EndIf
			EndIf
			Return $data
		Case BitOR($__Au3Obj_VT_ARRAY, $__Au3Obj_VT_VARIANT)
			Return __Au3Obj_ReadSafeArrayVariant(DllStructGetData($var, "data"))
		Case $__Au3Obj_VT_DISPATCH
			Return _AutoItObject_PtrToIDispatch(DllStructGetData($var, "data"))
		Case $__Au3Obj_VT_PTR
			Return DllStructGetData($var, "data")
		Case $__Au3Obj_VT_ERROR
			Return Default
		Case Else
			Return SetError(1, 0, '')
	EndSwitch

	$data = DllStructCreate($type, DllStructGetPtr($var, "data"))

	Switch $VT
		Case $__Au3Obj_VT_BOOL
			Return DllStructGetData($data, 1) <> 0
	EndSwitch
	Return DllStructGetData($data, 1)

EndFunc   ;==>_AutoItObject_VariantRead

; #FUNCTION# ====================================================================================================================
; Name...........: _AutoItObject_VariantSet
; Description ...: sets the value of a varaint or creates a new one.
; Syntax.........: _AutoItObject_VariantSet($pVar, $vVal, $iSpecialType = 0)
; Parameters ....: $pVar        - Pointer to the VARIANT to modify (0 if you want to create it new)
;                  $vVal        - Value of the VARIANT
;                  $iSpecialType - [optional] Modify the automatic type. NOT FOR GENERAL USE!
; Return values .: Success      - Pointer to the VARIANT
;                  Failure      - 0
; Author ........: monoceres, Prog@ndy
; Modified.......:
; Remarks .......:
; Related .......: _AutoItObject_VariantRead
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _AutoItObject_VariantSet($pVar, $vVal, $iSpecialType = 0)
	; Author: monoceres, Prog@ndy
	If Not $pVar Then
		$pVar = __Au3Obj_CoTaskMemAlloc($__Au3Obj_VARIANT_SIZE)
		_AutoItObject_VariantInit($pVar)
	Else
		_AutoItObject_VariantClear($pVar)
	EndIf
	Local $tVar = DllStructCreate($__Au3Obj_tagVARIANT, $pVar)
	Local $iType = $__Au3Obj_VT_EMPTY, $vDataType = ''

	Switch VarGetType($vVal)
		Case "Int32"
			$iType = $__Au3Obj_VT_I4
			$vDataType = 'int'
		Case "Int64"
			$iType = $__Au3Obj_VT_I8
			$vDataType = 'int64'
		Case "String", 'Text'
			$iType = $__Au3Obj_VT_BSTR
			$vDataType = 'ptr'
			$vVal = __Au3Obj_SysAllocString($vVal)
		Case "Double"
			$vDataType = 'double'
			$iType = $__Au3Obj_VT_R8
		Case "Float"
			$vDataType = 'float'
			$iType = $__Au3Obj_VT_R4
		Case "Bool"
			$vDataType = 'short'
			$iType = $__Au3Obj_VT_BOOL
			If $vVal Then
				$vVal = 0xffff
			Else
				$vVal = 0
			EndIf
		Case 'Ptr'
			If $__Au3Obj_X64 Then
				$iType = $__Au3Obj_VT_UI8
			Else
				$iType = $__Au3Obj_VT_UI4
			EndIf
			$vDataType = 'ptr'
		Case 'Object'
			_AutoItObject_IUnknownAddRef($vVal)
			$vDataType = 'ptr'
			$iType = $__Au3Obj_VT_DISPATCH
		Case "Binary"
			; ARRAY OF BYTES !
			Local $tSafeArrayBound = DllStructCreate($__Au3Obj_tagSAFEARRAYBOUND)
			DllStructSetData($tSafeArrayBound, 1, BinaryLen($vVal))
			Local $pSafeArray = __Au3Obj_SafeArrayCreate($__Au3Obj_VT_UI1, 1, DllStructGetPtr($tSafeArrayBound))
			Local $pData
			If 0 = __Au3Obj_SafeArrayAccessData($pSafeArray, $pData) Then
				Local $tData = DllStructCreate("byte[" & BinaryLen($vVal) & "]", $pData)
				DllStructSetData($tData, 1, $vVal)
				__Au3Obj_SafeArrayUnaccessData($pSafeArray)
				$vVal = $pSafeArray
				$vDataType = 'ptr'
				$iType = BitOR($__Au3Obj_VT_ARRAY, $__Au3Obj_VT_UI1)
			EndIf
		Case "Array"
			$vDataType = 'ptr'
			$vVal = __Au3Obj_CreateSafeArrayVariant($vVal)
			$iType = BitOR($__Au3Obj_VT_ARRAY, $__Au3Obj_VT_VARIANT)
		Case Else ;"Keyword" ; all keywords and unknown Vartypes will be handled as "default"
			$iType = $__Au3Obj_VT_ERROR
			$vDataType = 'int'
	EndSwitch
	If $vDataType Then
		DllStructSetData(DllStructCreate($vDataType, DllStructGetPtr($tVar, 'data')), 1, $vVal)

		If @NumParams = 3 Then $iType = $iSpecialType
		DllStructSetData($tVar, 'vt', $iType)
	EndIf
	Return $pVar
EndFunc   ;==>_AutoItObject_VariantSet

; #FUNCTION# ====================================================================================================================
; Name...........: _AutoItObject_WrapperAddMethod
; Description ...: Adds additional methods to the Wrapper-Object, e.g if you want alternative parameter types
; Syntax.........: _AutoItObject_WrapperAddMethod(ByRef $oWrapper, $sReturnType, $sName, $sParamTypes, $ivtableIndex)
; Parameters ....: $oWrapper     - The Object you want to modify
;                  $sReturnType  - the return type of the function
;                  $sName        - The name of the function
;                  $sParamTypes  - the parameter types
;                  $ivTableIndex - Index of the function in the object's vTable
; Return values .: Success      - True
;                  Failure      - 0
; Author ........: Prog@ndy
; Modified.......:
; Remarks .......:
; Related .......: _AutoItObject_WrapperCreate
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _AutoItObject_WrapperAddMethod(ByRef $oWrapper, $sReturnType, $sName, $sParamTypes, $ivtableIndex)
	; Author: Prog@ndy
	If Not IsObj($oWrapper) Then Return SetError(2, 0, 0)
	DllCall($ghAutoItObjectDLL, "none", "WrapperAddMethod", 'idispatch', $oWrapper, 'wstr', $sName, "wstr", StringRegExpReplace($sReturnType & ';' & $sParamTypes, "\s|(;+\Z)", ''), 'dword', $ivtableIndex)
	If @error Then Return SetError(1, @error, 0)
	Return True
EndFunc   ;==>_AutoItObject_WrapperAddMethod

; #FUNCTION# ====================================================================================================================
; Name...........: _AutoItObject_WrapperCreate
; Description ...: Creates an IDispatch-Object for COM-Interfaces normally not supporting it.
; Syntax.........: _AutoItObject_WrapperCreate($pUnknown, $tagInterface [, $fNoUnknown = False [, $fCallFree = False]])
; Parameters ....: $pUnknown     - Pointer to an IUnknown-Interface not supporting IDispatch
;                  $tagInterface - String defining the methods of the Interface, see Remarks for details
;                  $fNoUnknown   - [optional] $pUnknown is NOT an IUnkown-Interface. Do not release when out of scope (Default: False)
;                  $fCallFree   - [optional] Internal parameter. Do not use.
; Return values .: Success      - Dispatch-Object
;                  Failure      - 0, @error set
; Author ........: Prog@ndy
; Modified.......:
; Remarks .......: $tagInterface can be a string in the following format (dtag):
;                  +  "FunctionName ReturnType(ParamType1;ParamType2);FunctionName2 ..."
;                  +    - FunctionName is the name of the function you want to call later
;                  +    - ReturnType is the return type (like DLLCall)
;                  +    - ParamType is the type of the parameter (like DLLCall) [do not include the THIS-param]
;                  +
;                  +Alternative Format where only method names are listed (ltag) results in different format for calling the functions/methods later. You must specify the datatypes in the call then:
;                  +  $oObject.function("returntype", "1stparamtype", $1stparam, "2ndparamtype", $2ndparam, ...)
;                  +
;                  +The reuturn value of a call is always an array (except an error occured, then it's 0):
;                  +  - $array[0] - containts the return value
;                  +  - $array[n] - containts the n-th parameter
; Related .......: _AutoItObject_WrapperAddMethod
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _AutoItObject_WrapperCreate($pUnknown, $tagInterface, $fNoUnknown = False, $fCallFree = False)
	If Not $pUnknown Then Return SetError(1, 0, 0)
	Local $sMethods = __Au3Obj_GetMethods($tagInterface)
	Local $aResult
	If $sMethods Then
		$aResult = DllCall($ghAutoItObjectDLL, "idispatch", "CreateWrapperObjectEx", 'ptr', $pUnknown, 'wstr', $sMethods, "bool", $fNoUnknown, "bool", $fCallFree)
	Else
		$aResult = DllCall($ghAutoItObjectDLL, "idispatch", "CreateWrapperObject", 'ptr', $pUnknown, "bool", $fNoUnknown)
	EndIf
	If @error Then Return SetError(2, @error, 0)
	Return $aResult[0]
EndFunc   ;==>_AutoItObject_WrapperCreate

#EndRegion Public UDFs
;--------------------------------------------------------------------------------------------------------------------------------------