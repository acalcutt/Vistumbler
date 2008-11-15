;#AutoIt3Wrapper_au3check_parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6

#include <array.au3>

;_Zip_DeleteFile($zip, "Foo.au3")
; ------------------------------------------------------------------------------
;
; AutoIt Version: 3.2
; Language:       English
; Description:    ZIP Functions.
;
; ------------------------------------------------------------------------------
;===============================================================================
;
; Function Name:    _Zip_Create()
; Description:      Create Empty ZIP file.
; Parameter(s):     $hFilename - Complete path to zip file that will be created
; Requirement(s):   none.
; Return Value(s):  On Success - Returns the Zip file path (to be used as a handle - even though it's not necessary)
;                   On Failure - @error = 1 (file could not be created)
; Author(s):        torels_
;
;===============================================================================
Func _Zip_Create($hFilename)
	$hFp = FileOpen($hFilename, 17)
	$sString = Chr(80) & Chr(75) & Chr(5) & Chr(6) & Chr(0) & Chr(0) & Chr(0) & Chr(0) & Chr(0) & Chr(0) & Chr(0) & Chr(0) & Chr(0) & Chr(0) & Chr(0) & Chr(0) & Chr(0) & Chr(0) & Chr(0) & Chr(0) & Chr(0) & Chr(0)
	FileWrite($hFp, $sString)
	FileClose($hFp)
	
	If Not FileExists($hFilename) Then
		Return SetError(1, 0, 0)
	Else
		Return $hFilename
	EndIf
EndFunc   ;==>_Zip_Create

;===============================================================================
;
; Function Name:    _Zip_AddFile()
; Description:      Add a file to a ZIP Archieve.
; Parameter(s):     $hZipFile - Complete path to zip file that will be created (or handle if existant)
;					$hFile2Add - Complete path to the file that will be added
;					$flag = 4
;					- 4 no progress box
;					- 8 file name changed if already exists
;					- 16 respond "yes to all" for any dialog box displayed
;					- 64 preservw undo information, if possible
;					- 256 progress dialogbox without file names on it
;					- 512 Do not confirm the creation of a directory if the operation requires one to be created
;					- 1024 Do not display a user interface if an error occours
;					- 4096 Don't operate recursively in subdirectories but just in the local directory
; Requirement(s):   none.
; Return Value(s):  On Success - 0
;                   On Failure - sets @error 1~3
;					@error = 1 no Zip file
;					@error = 2 no dll
;					@error = 3 dll isn't registered
;                   On Failure - Returns False
; Author(s):        torels_
; Notes:			The return values will be given once the compressing process is ultimated... it takes some time with big files
;
;===============================================================================
Func _Zip_AddFile($hZipFile, $hFile2Add, $flag = 4)
	Local $DLLChk = _Zip_DllChk()
	If $DLLChk <> 0 Then Return SetError($DLLChk, 0, 0);no dll
	If Not FileExists($hZipFile) Then Return SetError(1, 0, 0) ;no zip file
	
	$oApp = ObjCreate("Shell.Application")
	$on = $oApp.NameSpace($hZipFile).Items.Count
	$copy = $oApp.NameSpace($hZipFile).CopyHere($hFile2Add, $flag)
	
	;With $oApp.Namespace($hZipFile)
	Do
		Sleep(500)
		$nn = $oApp.Namespace($hZipFile).Items.Count
	Until $nn > $on
	;EndWith
	Return SetError(0, 0, 1)
	
EndFunc   ;==>_Zip_AddFile

#cs
Func _Zip_DeleteFile($hZipFile, $hFile2Delete)
	Local $DLLChk = _Zip_DllChk()
	If $DLLChk <> 0 Then Return SetError($DLLChk, 0, 0);no dll
	If Not FileExists($hZipFile) Then Return SetError(1, 0, 0) ;no zip file
	
	$oFso = ObjCreate("Scripting.FileSystemObject")
	
	$oApp = ObjCreate("Shell.Application")
	$oFolderitem = $oApp.NameSpace($hZipFile).items.item(1).delete
	msgbox(0,"",$oFolderitem)
	;$oApp.NameSpace($hZipFile).DeleteFile($oFolderitem)
EndFunc
#ce
	
;===============================================================================
;
; Function Name:    _Zip_AddFolder()
; Description:      Add a folder to a ZIP Archieve.
; Parameter(s):     $hZipFile - Complete path to zip file that will be created (or handle if existant)
;					$hFolder - Complete path to the folder that will be added (possibly including "\" at the end)
;					$flag = 4
;					- 4 no progress box
;					- 8 file name changed if already exists
;					- 16 respond "yes to all" for any dialog box displayed
;					- 64 preservw undo information, if possible
;					- 256 progress dialogbox without file names on it
;					- 512 Do not confirm the creation of a directory if the operation requires one to be created
;					- 1024 Do not display a user interface if an error occours
;					- 4096 Don't operate recursively in subdirectories but just in the local directory
; Requirement(s):   none.
; Return Value(s):  On Success - 0
;                   On Failure - sets @error 1~3
;					@error = 1 no Zip file
;					@error = 2 no dll
;					@error = 3 dll isn't registered
; Author(s):        torels_
; Notes:			The return values will be given once the compressing process is ultimated... it takes some time with big files
;
;===============================================================================
Func _Zip_AddFolder($hZipFile, $hFolder, $flag = 4)
	Local $DLLChk = _Zip_DllChk()
	If $DLLChk <> 0 Then Return SetError($DLLChk, 0, 0);no dll
	If Not FileExists($hZipFile) Then Return SetError(1, 0, 0) ;no zip file
	
	If StringRight($hFolder, 1) <> "\" Then $hFolder &= "\"
	
	$oApp = ObjCreate("Shell.Application")
	$oFolder = $oApp.NameSpace($hFolder)
	$oCopy = $oApp.NameSpace($hZipFile).CopyHere($oFolder.Items, $flag)
	$oFC = $oApp.NameSpace($hFolder).items.count
	
	Do
		Sleep(500)
		$oZC = $oApp.NameSpace($hZipFile).Items.Count
	Until ($oZC < $oFC)
	
	Return SetError(0, 0)
EndFunc   ;==>_Zip_AddFolder

;===============================================================================
;
; Function Name:    _Zip_UnzipAll()
; Description:      Extract all files contained in a ZIP Archieve.
; Parameter(s):     $hZipFile - Complete path to zip file that will be created (or handle if existant)
;					$hDestPath - Complete path to where the files will be extracted
;					$flag = 4
;					- 4 no progress box
;					- 8 file name changed if already exists
;					- 16 respond "yes to all" for any dialog box displayed
;					- 64 preservw undo information, if possible
;					- 256 progress dialogbox without file names on it
;					- 512 Do not confirm the creation of a directory if the operation requires one to be created
;					- 1024 Do not display a user interface if an error occours
;					- 4096 Don't operate recursively in subdirectories but just in the local directory
; Requirement(s):   none.
; Return Value(s):  On Success - 0
;                   On Failure - sets @error 1~3
;					@error = 1 no Zip file
;					@error = 2 no dll
;					@error = 3 dll isn't registered
; Author(s):        torels_
; Notes:			The return values will be given once the extracting process is ultimated... it takes some time with big files
;
;===============================================================================
Func _Zip_UnzipAll($hZipFile, $hDestPath, $flag = 4)
	Local $DLLChk = _Zip_DllChk()
	If $DLLChk <> 0 Then Return SetError($DLLChk, 0, 0);no dll
	If Not FileExists($hZipFile) Then Return SetError(2, 0, 0) ;no zip file
	
	If Not FileExists($hDestPath) Then DirCreate($hDestPath)
	
	Local $aArray[1]
	$oApp = ObjCreate("Shell.Application")
	$oApp.Namespace($hDestPath).CopyHere($oApp.Namespace($hZipFile).Items, $flag)
	
	For $item In $oApp.Namespace($hZipFile).Items
		_ArrayAdd($aArray, $item)
	Next
	
	While 1
		Sleep(500)
		If FileExists($hDestPath & "\" & $aArray[UBound($aArray) - 1]) Then Return SetError(0, 0, 1)
		ExitLoop
	WEnd
	
EndFunc   ;==>_Zip_UnzipAll

;===============================================================================
;
; Function Name:    _Zip_Unzip()
; Description:      Extract a single file contained in a ZIP Archieve.
; Parameter(s):     $hZipFile - Complete path to zip file that will be created (or handle if existant)
;					$hFilename - Name of the element in the zip archive ex. "hello_world.txt"
;					$hDestPath - Complete path to where the files will be extracted
;					$flag = 4
;					- 4 no progress box
;					- 8 file name changed if already exists
;					- 16 respond "yes to all" for any dialog box displayed
;					- 64 preservw undo information, if possible
;					- 256 progress dialogbox without file names on it
;					- 512 Do not confirm the creation of a directory if the operation requires one to be created
;					- 1024 Do not display a user interface if an error occours
;					- 4096 Don't operate recursively in subdirectories but just in the local directory
; Requirement(s):   none.
; Return Value(s):  On Success - 0
;                   On Failure - sets @error 1~3
;					@error = 1 no Zip file
;					@error = 2 no dll
;					@error = 3 dll isn't registered
; Author(s):        torels_
; Notes:			The return values will be given once the extracting process is ultimated... it takes some time with big files
;
;===============================================================================
Func _Zip_Unzip($hZipFile, $hFilename, $hDestPath, $flag = 4)
	Local $DLLChk = _Zip_DllChk()
	If $DLLChk <> 0 Then Return SetError($DLLChk, 0, 0) ;no dll
	If Not FileExists($hZipFile) Then Return SetError(1, 0, 0) ;no zip file
	
	If Not FileExists($hDestPath) Then DirCreate($hDestPath)
	
	$oApp = ObjCreate("Shell.Application")
	$hFolderitem = $oApp.NameSpace($hZipFile).Parsename($hFilename)
	
	$oApp.NameSpace($hDestPath).Copyhere($hFolderitem, $flag)
	
	While 1
		Sleep(500)
		If FileExists($hDestPath & "\" & $hFilename) Then
			SetError(0, 0, 1)
			ExitLoop
		EndIf
	WEnd
	
	
EndFunc   ;==>_Zip_Unzip

;===============================================================================
;
; Function Name:    _Zip_Count()
; Description:      Count files contained in a ZIP Archieve.
; Parameter(s):     $hZipFile - Complete path to zip file that will be created (or handle if existant)
; Requirement(s):   none.
; Return Value(s):  On Success - 0
;                   On Failure - sets @error 1~3
;					@error = 1 no Zip file
;					@error = 2 no dll
;					@error = 3 dll isn't registered
; Author(s):        torels_
;
;===============================================================================
Func _Zip_Count($hZipFile)
	Local $DLLChk = _Zip_DllChk()
	If $DLLChk <> 0 Then Return SetError($DLLChk, 0, 0) ;no dll
	If Not FileExists($hZipFile) Then Return SetError(1, 0, 0) ;no zip file
	
	$oApp = ObjCreate("Shell.Application")
	Return $oApp.Namespace($hZipFile).Items.count
	SetError(0,0,1)
EndFunc   ;==>_Zip_Count

;===============================================================================
;
; Function Name:    _Zip_Count()
; Description:      Returns a collection of all the files contained in a ZIP Archieve.
; Parameter(s):     $hZipFile - Complete path to zip file that will be created (or handle if existant)
; Requirement(s):   none.
; Return Value(s):  On Success - 0
;                   On Failure - sets @error 1~3
;					@error = 1 no Zip file
;					@error = 2 no dll
;					@error = 3 dll isn't registered
; Author(s):        torels_
;
;===============================================================================
Func _Zip_List($hZipFile)
	local $aArray[1]
	Local $DLLChk = _Zip_DllChk()
	If $DLLChk <> 0 Then Return SetError($DLLChk, 0, 0) ;no dll
	If Not FileExists($hZipFile) Then Return SetError(1, 0, 0) ;no zip file
	
	$oApp = ObjCreate("Shell.Application")
	$hList = $oApp.Namespace($hZipFile).Items
	
	For $item in $hList
		_ArrayAdd($aArray,$item.name)
	Next
	$aArray[0] = UBound($aArray) - 1
	Return $aArray
	Return SetError(0,0,1)
EndFunc   ;==>_Zip_List

;===============================================================================
;
; Function Name:    _Zip_Search()
; Description:      Search files in a ZIP Archive.
; Parameter(s):     $hZipFile - Complete path to zip file that will be created (or handle if existant)
;					$sSearchString - name of the file to be searched
; Requirement(s):   none.
; Return Value(s):  On Success - 0
;                   On Failure - sets @error 1 (no file found)
; Author(s):        torels_
; Notes:			none
;
;===============================================================================
Func _Zip_Search($hZipFile, $sSearchString)
	local $aArray
	$list = _Zip_List($hZipFile)
	for $i = 0 to UBound($list) - 1
		if StringInStr($list[$i],$sSearchstring) > 0 Then
			_ArrayAdd($aArray, $list[$i])
		EndIf
	Next
	if UBound($aArray) - 1 = 0 Then
		Return SetError(1,0,1)
	Else
		Return $aArray
	EndIf
EndFunc ;==> _Zip_Search

;===============================================================================
;
; Function Name:    _Zip_SearchInFile()
; Description:      Search files in a ZIP Archive.
; Parameter(s):     $hZipFile - Complete path to zip file that will be created (or handle if existant)
;					$sSearchString - name of the file to be searched
; Requirement(s):   none.
; Return Value(s):  On Success - 0
;                   On Failure - sets @error 1 (no file found)
; Author(s):        torels_
; Notes:			none
;
;===============================================================================
Func _Zip_SearchInFile($hZipFile, $sSearchString)
	local $aArray
	$list = _Zip_List($hZipFile)
	for $i = 0 to UBound($list) - 1
		_Zip_Unzip($hZipFile, "tmp_zip.file", @TempDir)
		;_Zip_Unzip($hZipFile, "tmp_zip.file")
		$file = FileOpen (@TempDir & "\tmp_zip.file", 0)
		$read = FileRead($file)
		if StringInStr($read,$sSearchstring) > 0 Then
			_ArrayAdd($aArray, $list[$i])
		EndIf
	Next
	if UBound($aArray) - 1 = 0 Then
		Return SetError(1,0,1)
	Else
		Return $aArray
	EndIf
EndFunc ;==> _Zip_Search

;===============================================================================
;
; Function Name:    _Zip_DllChk()
; Description:      Internal error handler.
; Parameter(s):     none.
; Requirement(s):   none.
; Return Value(s):  Failure - @extended = 1
; Author(s):        smashley
;
;===============================================================================
Func _Zip_DllChk()
	If Not FileExists(@SystemDir & "\zipfldr.dll") Then Return 2
	If Not RegRead("HKEY_CLASSES_ROOT\CLSID\{E88DCCE0-B7B3-11d1-A9F0-00AA0060FA31}", "") Then Return 3
	Return 0
EndFunc   ;==>_Zip_DllChk