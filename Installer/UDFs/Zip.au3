#include-once
#Tidy_Parameters=/sf
; ===============================================================================================================
;
; Description:      ZIP Functions
; Author:           wraithdu
; Date:             2010-08-27
; Credits:          PsaltyDS for the original idea on which this UDF is based.
;                   torels for the basic framework on which this UDF is based.
;
; NOTES:
;   This UDF attempts to register a COM error handler if one does not exist.  This is done to prevent
;   any fatal COM errors.  If you have implemented your own COM error handler, this WILL NOT replace it.
;
;   The Shell object does not have a delete method, so some workarounds have been implemented.  The
;   options are either an interactive method (as in right-click -> Delete) or a slower method (slow for
;   large files).  The interactive method is the main function, while the slow method is in the internal
;   function section near the bottom.
;
;   When adding a file item to a ZIP archive, if the file exists and the overwrite flag is set, the slower
;   internal delete method is used.  This is the only way to make this step non-interactive.  It will be
;   slow for large files.
;
;   The zipfldr library does not allow overwriting or merging of folders in a ZIP archive.  That means
;   if you try to add a folder and a folder with that name already exists, it will simply fail.  Period.
;   As such, I've disabled that functionality.
;
;   I've also removed the AddFolderContents function.  There are too many pitfalls with that scenario, not
;   the least of which being the above restriction.
;
; ===============================================================================================================

;;; Start COM error Handler
;=====
; if a COM error handler does not already exist, assign one
If Not ObjEvent("AutoIt.Error") Then
    ; MUST assign this to a variable
    Global Const $_Zip_COMErrorHandler = ObjEvent("AutoIt.Error", "_Zip_COMErrorFunc")
EndIf


; #FUNCTION# ====================================================================================================
; Name...........:  _Zip_AddItem
; Description....:  Add a file or folder to a ZIP archive
; Syntax.........:  _Zip_AddItem($sZipFile, $sFileName[, $sDestDir = ""[, $iFlag = 21]])
; Parameters.....:  $sZipFile   - Full path to ZIP file
;                   $sFileName  - Full path to item to add
;                   $sDestDir   - [Optional] Destination subdirectory in which to place the item
;                               + Directory must be formatted similarly: "some\sub\dir"
;                   $iFlag      - [Optional] File copy flags (Default = 1+4+16)
;                               |   1 - Overwrite destination file if it exists
;                               |   4 - No progress box
;                               |   8 - Rename the file if a file of the same name already exists
;                               |  16 - Respond "Yes to All" for any dialog that is displayed
;                               |  64 - Preserve undo information, if possible
;                               | 256 - Display a progress dialog box but do not show the file names
;                               | 512 - Do not confirm the creation of a new directory if the operation requires one to be created
;                               |1024 - Do not display a user interface if an error occurs
;                               |2048 - Version 4.71. Do not copy the security attributes of the file
;                               |4096 - Only operate in the local directory, don't operate recursively into subdirectories
;                               |8192 - Version 5.0. Do not copy connected files as a group, only copy the specified files
;
; Return values..:  Success     - 1
;                   Failure     - 0 and sets @error
;                               | 1 - zipfldr.dll does not exist
;                               | 2 - Library not installed
;                               | 3 - Destination ZIP file not a full path
;                               | 4 - Item to add not a full path
;                               | 5 - Item to add does not exist
;                               | 6 - Destination subdirectory cannot be a full path
;                               | 7 - Destination ZIP file does not exist
;                               | 8 - Destination item exists and is a folder (see Remarks)
;                               | 9 - Destination item exists and overwrite flag not set
;                               |10 - Destination item exists and failed to overwrite
;                               |11 - Failed to create internal directory structure
;
; Author.........:  wraithdu
; Modified.......:
; Remarks........:  Destination folders CANNOT be overwritten or merged.  They must be manually deleted first.
; Related........:
; Link...........:
; Example........:
; ===============================================================================================================
Func _Zip_AddItem($sZipFile, $sFileName, $sDestDir = "", $iFlag = 21)
    If Not _Zip_DllChk() Then Return SetError(@error, 0, 0)
    If Not _IsFullPath($sZipFile) Then Return SetError(3, 0, 0)
    If Not _IsFullPath($sFileName) Then Return SetError(4, 0, 0)
    If Not FileExists($sFileName) Then Return SetError(5, 0, 0)
    If _IsFullPath($sDestDir) Then Return SetError(6, 0, 0)
    ; clean paths
    $sFileName = _Zip_PathStripSlash($sFileName)
    $sDestDir = _Zip_PathStripSlash($sDestDir)
    Local $sNameOnly = _Zip_PathNameOnly($sFileName)
    ; process overwrite flag
    Local $iOverwrite = 0
    If BitAND($iFlag, 1) Then
        $iOverwrite = 1
        $iFlag -= 1
    EndIf
    ; check for overwrite, if target exists...
    Local $sTest = $sZipFile
    If $sDestDir <> "" Then $sTest = $sZipFile & "\" & $sDestDir
    Local $itemExists = _Zip_ItemExists($sTest, $sNameOnly)
    If @error Then Return SetError(7, 0, 0)
    If $itemExists Then
        If @extended Then
            ; get out, cannot overwrite folders... AT ALL
            Return SetError(8, 0, 0)
        Else
            If $iOverwrite Then
                _Zip_InternalDelete($sTest, $sNameOnly)
                If @error Then Return SetError(10, 0, 0)
            Else
                Return SetError(9, 0, 0)
            EndIf
        EndIf
    EndIf
    Local $sTempFile = ""
    If $sDestDir <> "" Then
        $sTempFile = _Zip_AddPath($sZipFile, $sDestDir)
        If @error Then Return SetError(11, 0, 0)
        $sZipFile &= "\" & $sDestDir
    EndIf
    Local $oApp = ObjCreate("Shell.Application")
    Local $oNS = $oApp.NameSpace($sZipFile)
    ; copy the file
    $oNS.CopyHere($sFileName, $iFlag)
    Do
        Sleep(250)
        $oItem = $oNS.ParseName($sNameOnly)
    Until IsObj($oItem)
    If $sTempFile <> "" Then _Zip_InternalDelete($sZipFile, $sTempFile)
    Return 1
EndFunc   ;==>_Zip_AddItem

Func _Zip_COMErrorFunc()
EndFunc   ;==>_Zip_COMErrorFunc

; #FUNCTION# ====================================================================================================
; Name...........:  _Zip_Count
; Description....:  Count items in the root of a ZIP archive (not recursive)
; Syntax.........:  _Zip_Count($sZipFile)
; Parameters.....:  $sZipFile   - Full path to ZIP file
;
; Return values..:  Success     - Item count
;                   Failure     - 0 and sets @error
;                               | 1 - zipfldr.dll does not exist
;                               | 2 - Library not installed
;                               | 3 - Not a full path
;                               | 4 - ZIP file does not exist
; Author.........:  wraithdu, torels
; Modified.......:
; Remarks........:
; Related........:
; Link...........:
; Example........:
; ===============================================================================================================
Func _Zip_Count($sZipFile)
    If Not _Zip_DllChk() Then Return SetError(@error, 0, 0)
    If Not _IsFullPath($sZipFile) Then Return SetError(3, 0, 0)
    Local $oApp = ObjCreate("Shell.Application")
    Local $oNS = $oApp.NameSpace($sZipFile)
    If Not IsObj($oNS) Then Return SetError(4, 0, 0)
    Return $oNS.Items.Count
EndFunc   ;==>_Zip_Count

; #FUNCTION# ====================================================================================================
; Name...........:  _Zip_CountAll
; Description....:  Recursively count items contained in a ZIP archive
; Syntax.........:  _Zip_CountAll($sZipFile)
; Parameters.....:  $sZipFile       - Full path to ZIP file
;                   $iFileCount     - [Internal]
;                   $iFolderCount   - [Internal]
;
; Return values..:  Success         - Array with file and folder count
;                                   [0] - File count
;                                   [1] - Folder count
;                   Failure         - 0 and sets @error
;                                   | 1 - zipfldr.dll does not exist
;                                   | 2 - Library not installed
;                                   | 3 - Not a full path
;                                   | 4 - ZIP file does not exist
; Author.........:  wraithdu
; Modified.......:
; Remarks........:
; Related........:
; Link...........:
; Example........:
; ===============================================================================================================
Func _Zip_CountAll($sZipFile, $iFileCount = 0, $iFolderCount = 0)
    If Not _Zip_DllChk() Then Return SetError(@error, 0, 0)
    If Not _IsFullPath($sZipFile) Then Return SetError(3, 0, 0)
    Local $oApp = ObjCreate("Shell.Application")
    Local $oNS = $oApp.NameSpace($sZipFile)
    If Not IsObj($oNS) Then Return SetError(4, 0, 0)
    Local $oItems = $oNS.Items, $aCount
    For $oItem In $oItems
        If $oItem.IsFolder Then
            ; folder, recurse
            $iFolderCount += 1
            $aCount = _Zip_CountAll($sZipFile & "\" & $oItem.Name, $iFileCount, $iFolderCount)
            $iFileCount = $aCount[0]
            $iFolderCount = $aCount[1]
        Else
            $iFileCount += 1
        EndIf
    Next
    Dim $aCount[2] = [$iFileCount, $iFolderCount]
    Return $aCount
EndFunc   ;==>_Zip_CountAll

; #FUNCTION# ====================================================================================================
; Name...........:  _Zip_Create
; Description....:  Create empty ZIP archive
; Syntax.........:  _Zip_Create($sFileName[, $iOverwrite = 0])
; Parameters.....:  $sFileName  - Name of new ZIP file
;                   $iOverwrite - [Optional] Overwrite flag (Default = 0)
;                               | 0 - Do not overwrite the file if it exists
;                               | 1 - Overwrite the file if it exists
;
; Return values..:  Success     - Name of the new file
;                   Failure     - 0 and sets @error
;                               | 1 - A file with that name already exists and $iOverwrite flag is not set
;                               | 2 - Failed to create new file
; Author.........:  wraithdu, torels
; Modified.......:
; Remarks........:
; Related........:
; Link...........:
; Example........:
; ===============================================================================================================
Func _Zip_Create($sFileName, $iOverwrite = 0)
    If FileExists($sFileName) And Not $iOverwrite Then Return SetError(1, 0, 0)
    Local $hFp = FileOpen($sFileName, 2 + 8 + 16)
    If $hFp = -1 Then Return SetError(2, 0, 0)
    FileWrite($hFp, Binary("0x504B0506000000000000000000000000000000000000"))
    FileClose($hFp)
    Return $sFileName
EndFunc   ;==>_Zip_Create

; #FUNCTION# ====================================================================================================
; Name...........:  _Zip_DeleteItem
; Description....:  Delete a file or folder from a ZIP archive
; Syntax.........:  _Zip_DeleteItem($sZipFile, $sFileName)
; Parameters.....:  $sZipFile   - Full path to the ZIP file
;                   $sFileName  - Name of the item in the ZIP file
;
; Return values..:  Success     - 1
;                   Failure     - 0 and sets @error
;                               | 1 - zipfldr.dll does not exist
;                               | 2 - Library not installed
;                               | 3 - Not a full path
;                               | 4 - ZIP file does not exist
;                               | 5 - Item not found in ZIP file
;                               | 6 - Failed to get list of verbs
;                               | 7 - Failed to delete item
; Author.........:  wraithdu
; Modified.......:
; Remarks........:  $sFileName may be a path to an item from the root of the ZIP archive.
;                   For example, some ZIP file 'test.zip' has a subpath 'some\dir\file.ext'.  Do not include a leading or trailing '\'.
; Related........:
; Link...........:
; Example........:
; ===============================================================================================================
Func _Zip_DeleteItem($sZipFile, $sFileName)
    If Not _Zip_DllChk() Then Return SetError(@error, 0, 0)
    If Not _IsFullPath($sZipFile) Then Return SetError(3, 0, 0)
    ; parse filename
    $sFileName = _Zip_PathStripSlash($sFileName)
    If StringInStr($sFileName, "\") Then
        ; subdirectory, parse out path and filename
        $sZipFile &= "\" & _Zip_PathPathOnly($sFileName)
        $sFileName = _Zip_PathNameOnly($sFileName)
    EndIf
    Local $oApp = ObjCreate("Shell.Application")
    Local $oNS = $oApp.NameSpace($sZipFile)
    If Not IsObj($oNS) Then Return SetError(4, 0, 0)
    Local $oFolderItem = $oNS.ParseName($sFileName)
    If Not IsObj($oFolderItem) Then Return SetError(5, 0, 0)
    Local $oVerbs = $oFolderItem.Verbs
    If Not IsObj($oVerbs) Then Return SetError(6, 0, 0)
    For $oVerb In $oVerbs
        If StringReplace($oVerb.Name, "&", "") = "delete" Then
            $oVerb.DoIt
            Return 1
        EndIf
    Next
    Return SetError(7, 0, 0)
EndFunc   ;==>_Zip_DeleteItem

; #FUNCTION# ====================================================================================================
; Name...........:  _Zip_ItemExists
; Description....:  Determines if an item exists in a ZIP file
; Syntax.........:  _Zip_ItemExists($sZipFile, $sItem)
; Parameters.....:  $sZipFile   - Full path to ZIP file
;                   $sItem      - Name of item
;
; Return values..:  Success     - 1
;                               @extended is set to 1 if the item is a folder, 0 if a file
;                   Failure     - 0 and sets @error
;                               | 1 - zipfldr.dll does not exist
;                               | 2 - Library not installed
;                               | 3 - Not a full path
;                               | 4 - ZIP file does not exist
; Author.........:  wraithdu
; Modified.......:
; Remarks........:  $sItem may be a path to an item from the root of the ZIP archive.
;                   For example, some ZIP file 'test.zip' has a subpath 'some\dir\file.ext'.  Do not include a leading or trailing '\'.
; Related........:
; Link...........:
; Example........:
; ===============================================================================================================
Func _Zip_ItemExists($sZipFile, $sItem)
    If Not _Zip_DllChk() Then Return SetError(@error, 0, 0)
    If Not _IsFullPath($sZipFile) Then Return SetError(3, 0, 0)
    $sItem = _Zip_PathStripSlash($sItem)
    If StringInStr($sItem, "\") Then
        ; subfolder
        $sZipFile &= "\" & _Zip_PathPathOnly($sItem)
        $sItem = _Zip_PathNameOnly($sItem)
    EndIf
    Local $oApp = ObjCreate("Shell.Application")
    Local $oNS = $oApp.NameSpace($sZipFile)
    If Not IsObj($oNS) Then Return SetError(4, 0, 0)
    Local $oItem = $oNS.ParseName($sItem)
    ; @extended holds whether item is a file (0) or folder (1)
    If IsObj($oItem) Then Return SetExtended(Number($oItem.IsFolder), 1)
    Return 0
EndFunc   ;==>_Zip_ItemExists

; #FUNCTION# ====================================================================================================
; Name...........:  _Zip_List
; Description....:  List items in the root of a ZIP archive (not recursive)
; Syntax.........:  _Zip_List($sZipFile)
; Parameters.....:  $sZipFile   - Full path to ZIP file
;
; Return values..:  Success     - Array of items
;                   Failure     - 0 and sets @error
;                               | 1 - zipfldr.dll does not exist
;                               | 2 - Library not installed
;                               | 3 - Not a full path
;                               | 4 - ZIP file does not exist
; Author.........:  wraithdu, torels
; Modified.......:
; Remarks........:  Item count is returned in array[0].
; Related........:
; Link...........:
; Example........:
; ===============================================================================================================
Func _Zip_List($sZipFile)
    If Not _Zip_DllChk() Then Return SetError(@error, 0, 0)
    If Not _IsFullPath($sZipFile) Then Return SetError(3, 0, 0)
    Local $oApp = ObjCreate("Shell.Application")
    Local $oNS = $oApp.NameSpace($sZipFile)
    If Not IsObj($oNS) Then Return SetError(4, 0, 0)
    Local $aArray[1] = [0]
    Local $oList = $oNS.Items
    For $oItem In $oList
        $aArray[0] += 1
        ReDim $aArray[$aArray[0] + 1]
        $aArray[$aArray[0]] = $oItem.Name
    Next
    Return $aArray
EndFunc   ;==>_Zip_List

; #FUNCTION# ====================================================================================================
; Name...........:  _Zip_ListAll
; Description....:  List all files inside a ZIP archive
; Syntax.........:  _Zip_ListAll($sZipFile[, $iFullPath = 1])
; Parameters.....:  $sZipFile   - Full path to ZIP file
;                   $iFullPath  - [Optional] Path flag (Default = 1)
;                               | 0 - Return file names only
;                               | 1 - Return full paths of files from the archive root
;
; Return values..:  Success     - Array of file names / paths
;                   Failure     - 0 and sets @error
;                               | 1 - zipfldr.dll does not exist
;                               | 2 - Library not installed
;                               | 3 - Not a full path
;                               | 4 - ZIP file or subfolder does not exist
; Author.........:  wraithdu
; Modified.......:
; Remarks........:  File count is returned in array[0], does not list folders.
; Related........:
; Link...........:
; Example........:
; ===============================================================================================================
Func _Zip_ListAll($sZipFile, $iFullPath = 1)
    If Not _Zip_DllChk() Then Return SetError(@error, 0, 0)
    If Not _IsFullPath($sZipFile) Then Return SetError(3, 0, 0)
    Local $aArray[1] = [0]
    _Zip_ListAll_Internal($sZipFile, $aArray, $iFullPath)
    If @error Then
        Return SetError(@error, 0, 0)
    Else
        Return $aArray
    EndIf
EndFunc   ;==>_Zip_ListAll

; #FUNCTION# ====================================================================================================
; Name...........:  _Zip_Search
; Description....:  Search for files in a ZIP archive
; Syntax.........:  _Zip_Search($sZipFile, $sSearchString)
; Parameters.....:  $sZipFile       - Full path to ZIP file
;                   $sSearchString  - Substring to search
;
; Return values..:  Success         - Array of matching file paths from the root of the archive
;                   Failure         - 0 and sets @error
;                                   | 1 - zipfldr.dll does not exist
;                                   | 2 - Library not installed
;                                   | 3 - Not a full path
;                                   | 4 - ZIP file or subfolder does not exist
;                                   | 5 - No matching files found
; Author.........:  wraithdu
; Modified.......:
; Remarks........:  Found file count is returned in array[0].
; Related........:
; Link...........:
; Example........:
; ===============================================================================================================
Func _Zip_Search($sZipFile, $sSearchString)
    Local $aList = _Zip_ListAll($sZipFile)
    If @error Then Return SetError(@error, 0, 0)
    Local $aArray[1] = [0], $sName
    For $i = 1 To $aList[0]
        $sName = $aList[$i]
        If StringInStr($sName, "\") Then
            ; subdirectory, isolate file name
            $sName = _Zip_PathNameOnly($sName)
        EndIf
        If StringInStr($sName, $sSearchString) Then
            $aArray[0] += 1
            ReDim $aArray[$aArray[0] + 1]
            $aArray[$aArray[0]] = $aList[$i]
        EndIf
    Next
    If $aArray[0] = 0 Then
        ; no files found
        Return SetError(5, 0, 0)
    Else
        Return $aArray
    EndIf
EndFunc   ;==>_Zip_Search

; #FUNCTION# ====================================================================================================
; Name...........:  _Zip_SearchInFile
; Description....:  Search file contents of files in a ZIP archive
; Syntax.........:  _Zip_SearchInFile($sZipFile, $sSearchString)
; Parameters.....:  $sZipFile       - Full path to ZIP file
;                   $sSearchString  - Substring to search
;
; Return values..:  Success         - Array of matching file paths from the root of the archive
;                   Failure         - 0 and sets @error
;                                   | 1 - zipfldr.dll does not exist
;                                   | 2 - Library not installed
;                                   | 3 - Not a full path
;                                   | 4 - ZIP file or subfolder does not exist
;                                   | 5 - Failed to create temporary directory
;                                   | 6 - Failed to extract ZIP file to temporary directory
;                                   | 7 - No matching files found
; Author.........:  wraithdu
; Modified.......:
; Remarks........:  Found file count is returned in array[0].
; Related........:
; Link...........:
; Example........:
; ===============================================================================================================
Func _Zip_SearchInFile($sZipFile, $sSearchString)
    Local $aList = _Zip_ListAll($sZipFile)
    If @error Then Return SetError(@error, 0, 0)
    Local $sTempDir = _Zip_CreateTempDir()
    If @error Then Return SetError(5, 0, 0)
    _Zip_UnzipAll($sZipFile, $sTempDir) ; flag = 20 -> no dialog, yes to all
    If @error Then
        DirRemove($sTempDir, 1)
        Return SetError(6, 0, 0)
    EndIf
    Local $aArray[1] = [0], $sData
    For $i = 1 To $aList[0]
        $sData = FileRead($sTempDir & "\" & $aList[$i])
        If StringInStr($sData, $sSearchString) Then
            $aArray[0] += 1
            ReDim $aArray[$aArray[0] + 1]
            $aArray[$aArray[0]] = $aList[$i]
        EndIf
    Next
    DirRemove($sTempDir, 1)
    If $aArray[0] = 0 Then
        ; no files found
        Return SetError(7, 0, 0)
    Else
        Return $aArray
    EndIf
EndFunc   ;==>_Zip_SearchInFile

; #FUNCTION# ====================================================================================================
; Name...........:  _Zip_Unzip
; Description....:  Extract a single item from a ZIP archive
; Syntax.........:  _Zip_Unzip($sZipFile, $sFileName, $sDestPath[, $iFlag = 21])
; Parameters.....:  $sZipFile   - Full path to ZIP file
;                   $sFileName  - Name of the item in the ZIP file
;                   $sDestPath  - Full path to the destination
;                   $iFlag      - [Optional] File copy flags (Default = 1+4+16)
;                               |   1 - Overwrite destination file if it exists
;                               |   4 - No progress box
;                               |   8 - Rename the file if a file of the same name already exists
;                               |  16 - Respond "Yes to All" for any dialog that is displayed
;                               |  64 - Preserve undo information, if possible
;                               | 256 - Display a progress dialog box but do not show the file names
;                               | 512 - Do not confirm the creation of a new directory if the operation requires one to be created
;                               |1024 - Do not display a user interface if an error occurs
;                               |2048 - Version 4.71. Do not copy the security attributes of the file
;                               |4096 - Only operate in the local directory, don't operate recursively into subdirectories
;                               |8192 - Version 5.0. Do not copy connected files as a group, only copy the specified files
;
; Return values..:  Success     - 1
;                   Failure     - 0 and sets @error
;                               | 1 - zipfldr.dll does not exist
;                               | 2 - Library not installed
;                               | 3 - Not a full path
;                               | 4 - ZIP file / item path does not exist
;                               | 5 - Item not found in ZIP file
;                               | 6 - Failed to create destination (if necessary)
;                               | 7 - Failed to open destination
;                               | 8 - Failed to delete destination file / folder for overwriting
;                               | 9 - Destination exists and overwrite flag not set
;                               |10 - Failed to extract file
; Author.........:  wraithdu, torels
; Modified.......:
; Remarks........:  $sFileName may be a path to an item from the root of the ZIP archive.
;                   For example, some ZIP file 'test.zip' has a subpath 'some\dir\file.ext'.  Do not include a leading or trailing '\'.
;                   If the overwrite flag is not set and the destination file / folder exists, overwriting is controlled
;                   by the remaining file copy flags ($iFlag) and/or user interaction.
; Related........:
; Link...........:
; Example........:
; ===============================================================================================================
Func _Zip_Unzip($sZipFile, $sFileName, $sDestPath, $iFlag = 21)
    If Not _Zip_DllChk() Then Return SetError(@error, 0, 0)
    If Not _IsFullPath($sZipFile) Or Not _IsFullPath($sDestPath) Then Return SetError(3, 0, 0)
    Local $sTempDir = _Zip_TempDirName($sZipFile)
    ; parse filename
    $sFileName = _Zip_PathStripSlash($sFileName)
    If StringInStr($sFileName, "\") Then
        ; subdirectory, parse out path and filename
        $sZipFile &= "\" & _Zip_PathPathOnly($sFileName)
        $sFileName = _Zip_PathNameOnly($sFileName)
    EndIf
    Local $oApp = ObjCreate("Shell.Application")
    Local $oNS = $oApp.NameSpace($sZipFile)
    If Not IsObj($oNS) Then Return SetError(4, 0, 0)
    Local $oFolderItem = $oNS.ParseName($sFileName)
    If Not IsObj($oFolderItem) Then Return SetError(5, 0, 0)
    $sDestPath = _Zip_PathStripSlash($sDestPath)
    If Not FileExists($sDestPath) Then
        DirCreate($sDestPath)
        If @error Then Return SetError(6, 0, 0)
    EndIf
    Local $oNS2 = $oApp.NameSpace($sDestPath)
    If Not IsObj($oNS2) Then Return SetError(7, 0, 0)
    ; process overwrite flag
    Local $iOverwrite = 0
    If BitAND($iFlag, 1) Then
        $iOverwrite = 1
        $iFlag -= 1
    EndIf
    Local $sDestFullPath = $sDestPath & "\" & $sFileName
    If FileExists($sDestFullPath) Then
        ; destination file exists
        If $iOverwrite Then
            If StringInStr(FileGetAttrib($sDestFullPath), "D") Then
                ; folder
                If Not DirRemove($sDestFullPath, 1) Then Return SetError(8, 0, 0)
            Else
                If Not FileDelete($sDestFullPath) Then Return SetError(8, 0, 0)
            EndIf
        Else
            Return SetError(9, 0, 0)
        EndIf
    EndIf
    $oNS2.CopyHere($oFolderItem, $iFlag)
    DirRemove($sTempDir, 1)
    If FileExists($sDestFullPath) Then
        ; success
        Return 1
    Else
        ; failure
        Return SetError(10, 0, 0)
    EndIf
EndFunc   ;==>_Zip_Unzip

; #FUNCTION# ====================================================================================================
; Name...........:  _Zip_UnzipAll
; Description....:  Extract all files contained in a ZIP archive
; Syntax.........:  _Zip_UnzipAll($sZipFile, $sDestPath[, $iFlag = 20])
; Parameters.....:  $sZipFile   - Full path to ZIP file
;                   $sDestPath  - Full path to the destination
;                   $iFlag      - [Optional] File copy flags (Default = 4+16)
;                               |   4 - No progress box
;                               |   8 - Rename the file if a file of the same name already exists
;                               |  16 - Respond "Yes to All" for any dialog that is displayed
;                               |  64 - Preserve undo information, if possible
;                               | 256 - Display a progress dialog box but do not show the file names
;                               | 512 - Do not confirm the creation of a new directory if the operation requires one to be created
;                               |1024 - Do not display a user interface if an error occurs
;                               |2048 - Version 4.71. Do not copy the security attributes of the file
;                               |4096 - Only operate in the local directory, don't operate recursively into subdirectories
;                               |8192 - Version 5.0. Do not copy connected files as a group, only copy the specified files
;
; Return values..:  Success     - 1
;                   Failure     - 0 and sets @error
;                               | 1 - zipfldr.dll does not exist
;                               | 2 - Library not installed
;                               | 3 - Not a full path
;                               | 4 - ZIP file does not exist
;                               | 5 - Failed to create destination (if necessary)
;                               | 6 - Failed to open destination
;                               | 7 - Failed to extract file(s)
; Author.........:  wraithdu, torels
; Modified.......:
; Remarks........:  Overwriting of destination files is controlled solely by the file copy flags (ie $iFlag = 1 is NOT valid).
; Related........:
; Link...........:
; Example........:
; ===============================================================================================================
Func _Zip_UnzipAll($sZipFile, $sDestPath, $iFlag = 20)
    If Not _Zip_DllChk() Then Return SetError(@error, 0, 0)
    If Not _IsFullPath($sZipFile) Or Not _IsFullPath($sDestPath) Then Return SetError(3, 0, 0)
    Local $sTempDir = _Zip_TempDirName($sZipFile)
    Local $oApp = ObjCreate("Shell.Application")
    Local $oNS = $oApp.NameSpace($sZipFile)
    If Not IsObj($oNS) Then Return SetError(4, 0, 0)
    $sDestPath = _Zip_PathStripSlash($sDestPath)
    If Not FileExists($sDestPath) Then
        DirCreate($sDestPath)
        If @error Then Return SetError(5, 0, 0)
    EndIf
    Local $oNS2 = $oApp.NameSpace($sDestPath)
    If Not IsObj($oNS2) Then Return SetError(6, 0, 0)
    $oNS2.CopyHere($oNS.Items, $iFlag)
    DirRemove($sTempDir, 1)

	;Workaround because windows did not always return file extension for .Name - Andrew Calcutt 10/23/2010
	$testfilesourcepath = $oNS.Items.Item($oNS.Items.Count - 1).path
	$testfiledestpath = $sDestPath & "\" & StringTrimLeft($testfilesourcepath, StringInStr($testfilesourcepath, "\" , 0 , -1))
	;end workaround
    If FileExists($testfiledestpath) Then
        ; success... most likely
        ; checks for existence of last item from source in destination
        Return 1
    Else
        ; failure
        Return SetError(7, 0, 0)
    EndIf
EndFunc   ;==>_Zip_UnzipAll

#Region INTERNAL FUNCTIONS
; #FUNCTION# ====================================================================================================
; Name...........:  _IsFullPath
; Description....:  Determines if a given path is a fully qualified path (well, roughly...)
; Syntax.........:  _IsFullPath($sPath)
; Parameters.....:  $sPath  - Path to check
;
; Return values..:  Success - True
;                   Failure - False
; Author.........:  torels
; Modified.......:
; Remarks........:
; Related........:
; Link...........:
; Example........:
; ===============================================================================================================
Func _IsFullPath($sPath)
    If StringInStr($sPath, ":\") Then
        Return True
    Else
        Return False
    EndIf
EndFunc   ;==>_IsFullPath

; #FUNCTION# ====================================================================================================
; Name...........:  _Zip_AddPath
; Description....:  INTERNAL FUNCTION
; Author.........:  wraithdu
; ===============================================================================================================
Func _Zip_AddPath($sZipFile, $sPath)
    If Not _Zip_DllChk() Then Return SetError(@error, 0, 0)
    If Not _IsFullPath($sZipFile) Then Return SetError(3, 0, 0)
    Local $oApp = ObjCreate("Shell.Application")
    Local $oNS = $oApp.NameSpace($sZipFile)
    If Not IsObj($oNS) Then Return SetError(4, 0, 0)
    ; check and create directory structure
    $sPath = _Zip_PathStripSlash($sPath)
    Local $sFileName = "", $sNewPath = ""
    If $sPath <> "" Then
        ; create temp dir
        Local $sTempDir = _Zip_CreateTempDir()
        If @error Then Return SetError(5, 0, 0)
        Local $oTemp = $oApp.NameSpace($sTempDir)
        Local $aDir = StringSplit($sPath, "\"), $oNS2
        For $i = 1 To $aDir[0]
            $oNS2 = $oApp.NameSpace($sZipFile & "\" & $aDir[$i])
            If Not IsObj($oNS2) Then
                ; create the directory structure
                For $i = $i To $aDir[0]
                    $sNewPath &= "\" & $aDir[$i]
                Next
                DirCreate($sTempDir & $sNewPath)
                $sFileName = _Zip_CreateTempName()
                FileClose(FileOpen($sTempDir & $sNewPath & "\" & $sFileName, 2))
                $oNS.CopyHere($oTemp.Items)
                ; wait for dir structure
                Do
                    Sleep(250)
                    $oNS = $oApp.NameSpace($sZipFile & $sNewPath)
                Until IsObj($oNS)
                ; wait for file
                Do
                    Sleep(250)
                    $oItem = $oNS.ParseName($sFileName)
                Until IsObj($oItem)
                DirRemove($sTempDir, 1)
                ExitLoop
            EndIf
            $sZipFile &= "\" & $aDir[$i]
            $oNS = $oApp.NameSpace($sZipFile)
        Next
    EndIf
    Return $sFileName
EndFunc   ;==>_Zip_AddPath

; #FUNCTION# ====================================================================================================
; Name...........:  _Zip_CreateTempDir
; Description....:  INTERNAL FUNCTION
; Author.........:  wraithdu
; ===============================================================================================================
Func _Zip_CreateTempDir()
    Local $s_TempName
    Do
        $s_TempName = ""
        While StringLen($s_TempName) < 7
            $s_TempName &= Chr(Random(97, 122, 1))
        WEnd
        $s_TempName = @TempDir & "\~" & $s_TempName & ".tmp"
    Until Not FileExists($s_TempName)
    If Not DirCreate($s_TempName) Then Return SetError(1, 0, 0)
    Return $s_TempName
EndFunc   ;==>_Zip_CreateTempDir

; #FUNCTION# ====================================================================================================
; Name...........:  _Zip_CreateTempName
; Description....:  INTERNAL FUNCTION
; Author.........:  wraithdu
; ===============================================================================================================
Func _Zip_CreateTempName()
    Local $GUID = DllStructCreate("dword Data1;word Data2;word Data3;byte Data4[8]")
    DllCall("ole32.dll", "int", "CoCreateGuid", "ptr", DllStructGetPtr($GUID))
    Local $ret = DllCall("ole32.dll", "int", "StringFromGUID2", "ptr", DllStructGetPtr($GUID), "wstr", "", "int", 40)
    If @error Then Return SetError(1, 0, "")
    Return $ret[2]
EndFunc   ;==>_Zip_CreateTempName

; #FUNCTION# ====================================================================================================
; Name...........:  _Zip_DllChk
; Description....:  Checks if the zipfldr library is installed
; Syntax.........:  _Zip_DllChk()
; Parameters.....:  None.
; Return values..:  Success - 1
;                   Failure - 0 and sets @error
;                           | 1 - zipfldr.dll not found
;                           | 2 - Library not installed
; Author.........:  wraithdu, torels
; Modified.......:
; Remarks........:
; Related........:
; Link...........:
; Example........:
; ===============================================================================================================
Func _Zip_DllChk()
    If Not FileExists(@SystemDir & "\zipfldr.dll") Then Return SetError(1, 0, 0)
    If Not RegRead("HKEY_CLASSES_ROOT\CLSID\{E88DCCE0-B7B3-11d1-A9F0-00AA0060FA31}", "") Then Return SetError(2, 0, 0)
    Return 1
EndFunc   ;==>_Zip_DllChk

; #FUNCTION# ====================================================================================================
; Name...........:  _Zip_InternalDelete
; Description....:  INTERNAL FUNCTION
; Author.........:  wraithdu
; ===============================================================================================================
Func _Zip_InternalDelete($sZipFile, $sFileName)
    If Not _Zip_DllChk() Then Return SetError(@error, 0, 0)
    If Not _IsFullPath($sZipFile) Then Return SetError(3, 0, 0)
    ; parse filename
    $sFileName = _Zip_PathStripSlash($sFileName)
    If StringInStr($sFileName, "\") Then
        ; subdirectory, parse out path and filename
        $sZipFile &= "\" & _Zip_PathPathOnly($sFileName)
        $sFileName = _Zip_PathNameOnly($sFileName)
    EndIf
    Local $oApp = ObjCreate("Shell.Application")
    Local $oNS = $oApp.NameSpace($sZipFile)
    If Not IsObj($oNS) Then Return SetError(4, 0, 0)
    Local $oFolderItem = $oNS.ParseName($sFileName)
    If Not IsObj($oFolderItem) Then Return SetError(5, 0, 0)
    ; ## Ugh, this was ultimately a bad solution
    ; move file to a temp directory and remove the directory
    Local $sTempDir = _Zip_CreateTempDir()
    If @error Then Return SetError(6, 0, 0)
    $oApp.NameSpace($sTempDir).MoveHere($oFolderItem, 20)
    DirRemove($sTempDir, 1)
    $oFolderItem = $oNS.ParseName($sFileName)
    If IsObj($oFolderItem) Then
        ; failure
        Return SetError(7, 0, 0)
    Else
        Return 1
    EndIf
EndFunc   ;==>_Zip_InternalDelete

; #FUNCTION# ====================================================================================================
; Name...........:  _Zip_ListAll_Internal
; Description....:  INTERNAL FUNCTION
; Author.........:  wraithdu
; ===============================================================================================================
Func _Zip_ListAll_Internal($sZipFile, ByRef $aArray, $iFullPath, $sPrefix = "")
    Local $oApp = ObjCreate("Shell.Application")
    Local $oNS = $oApp.NameSpace($sZipFile)
    If Not IsObj($oNS) Then Return SetError(4, 0, 0)
    Local $oList = $oNS.Items
    For $oItem In $oList
        If $oItem.IsFolder Then
            ; folder, recurse
            If $iFullPath Then
                ; build path from root of zip
                _Zip_ListAll_Internal($sZipFile & "\" & $oItem.Name, $aArray, $iFullPath, $sPrefix & $oItem.Name & "\")
                If @error Then Return SetError(4)
            Else
                ; just filenames
                _Zip_ListAll_Internal($sZipFile & "\" & $oItem.Name, $aArray, $iFullPath, "")
                If @error Then Return SetError(4)
            EndIf
        Else
            $aArray[0] += 1
            ReDim $aArray[$aArray[0] + 1]
            $aArray[$aArray[0]] = $sPrefix & $oItem.Name
        EndIf
    Next
EndFunc   ;==>_Zip_ListAll_Internal

; #FUNCTION# ====================================================================================================
; Name...........:  _Zip_PathNameOnly
; Description....:  INTERNAL FUNCTION
; Author.........:  wraithdu
; ===============================================================================================================
Func _Zip_PathNameOnly($sPath)
    Return StringRegExpReplace($sPath, ".*\\", "")
EndFunc   ;==>_Zip_PathNameOnly

; #FUNCTION# ====================================================================================================
; Name...........:  _Zip_PathPathOnly
; Description....:  INTERNAL FUNCTION
; Author.........:  wraithdu
; ===============================================================================================================
Func _Zip_PathPathOnly($sPath)
    Return StringRegExpReplace($sPath, "^(.*)\\.*?$", "${1}")
EndFunc   ;==>_Zip_PathPathOnly

; #FUNCTION# ====================================================================================================
; Name...........:  _Zip_PathStripSlash
; Description....:  INTERNAL FUNCTION
; Author.........:  wraithdu
; ===============================================================================================================
Func _Zip_PathStripSlash($sString)
    Return StringRegExpReplace($sString, "(^\\+|\\+$)", "")
EndFunc   ;==>_Zip_PathStripSlash

; #FUNCTION# ====================================================================================================
; Name...........:  _Zip_TempDirName
; Description....:  INTERNAL FUNCTION
; Author.........:  wraithdu, trancexxx
; ===============================================================================================================
Func _Zip_TempDirName($sZipFile)
    Local $i = 0, $sTemp, $sName = _Zip_PathNameOnly($sZipFile)
    Do
        $i += 1
        $sTemp = @TempDir & "\Temporary Directory " & $i & " for " & $sName
    Until Not FileExists($sTemp) ; this folder will be created during extraction
    Return $sTemp
EndFunc   ;==>_Zip_TempDirName
#EndRegion INTERNAL FUNCTIONS
