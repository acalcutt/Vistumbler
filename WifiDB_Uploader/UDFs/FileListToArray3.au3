;  FileListToArray3.au3
#AutoIt3Wrapper_Au3Check_Parameters= -d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6
;===============================================================================
;
; Description:      lists all files and folders in a specified path
; Syntax:           _FileListToArray($s_Path, $s_Filter = "*", $i_Flag = 0)
; Parameter(s):    	$s_Path = Path to generate filelist for
;					$s_Filter = The filter to use. Search the Autoit3 manual for the word "WildCards" For details
;                   $i_Flag = determines whether to return file or folders or both
;						$i_Flag=0(Default) Return both files and folders
;                       $i_Flag=1 Return files Only
;						$i_Flag=2 Return Folders Only
;					$i_Recurse = Indicate whether recursion to subfolders required
;						$i_Recurse=0(Default) No recursion to subfolders
;                       $i_Recurse=1 recursion to subfolders
;					$i_BaseDir = Indicate whether base directory name included in returned elements
;						$i_BaseDir=0 base directory name not included
;                       $i_BaseDir=1 (Default) base directory name included
;					$s_Exclude= The Exclude filter to use.  "WildCards" For details
;
; Requirement(s):   None
; Return Value(s):  On Success - Returns an array containing the list of files and folders in the specified path
;                        On Failure - Returns the an empty string "" if no files are found and sets @Error on errors
;						@Error=1 Path not found or invalid
;						@Error=2 Invalid $s_Filter
;                       @Error=3 Invalid $i_Flag
;                 @Error=4 No File(s) Found
;
; Author(s):        randallc <randallc@ozemail.com.au>; modified from SolidSnake and big_daddy and SmoKE_N and GEOsoft!
; Note(s):			The array returned is one-dimensional and is made up as follows:
;					$array[0] = Number of Files\Folders returned
;					$array[1] = 1st File\Folder
;					$array[2] = 2nd File\Folder
;					$array[3] = 3rd File\Folder
;					$array[n] = nth File\Folder
;
;===============================================================================
Func _FileListToArray3($sPath, $sFilter = "*", $iFlag = 0, $iRecurse = 0, $iBaseDir = 1, $sExclude = "", $i_Options = 1)
	
	;Declare local variables
	Local $sFileString, $asList[1], $sep = "|", $sFileString1, $sFilter1 = $sFilter;$hSearch, $sFile,
	Local $i_ReturnAsString = BitAND($i_Options, 2)
	$i_deleteduplicate = BitAND($i_Options, 1)
	;Set default filter to wildcard
	If $sFilter = -1 Or $sFilter == "" Or $sFilter = Default Then $sFilter = "*"

	;Strip trailing slash from search path
	If StringRight($sPath, 1) == "\"  Then $sPath = StringTrimRight($sPath, 1)
	
	;Ensure search path exists
	If Not FileExists($sPath) Then Return SetError(1, 1, "")
	
	;Return error if special characters are found in filter
	If (StringInStr($sFilter, "\")) Or (StringInStr($sFilter, "/")) Or (StringInStr($sFilter, ":")) Or (StringInStr($sFilter, ">")) Or (StringInStr($sFilter, "<")) Or (StringStripWS($sFilter, 8) = "") Then Return SetError(2, 2, "")

	;Only allow 0,1,2 for flag options 
	If Not ($iFlag = 0 Or $iFlag = 1 Or $iFlag = 2) Then Return SetError(3, 3, "");~     $sFilter = StringReplace("*" & $sFilter & "*", "**", "*")

	;Determine seperator character
	If StringInStr($sFilter, ';') Then $sep = ";" ;$sFilter &= ';'
	If StringInStr($sFilter, ',') Then $sep = "," ;$sFilter &= ';'

	;Append pipe to file filter if no semi-colons and pipe symbols are found
	$sFilter &= $sep
	
	;Declare local variables, Implode file filter
	Local $aFilterSplit = StringSplit(StringStripWS($sFilter, 8), $sep), $sHoldSplit, $arFolders[2] = [$sPath, ""];~     $cw = ConsoleWrite("UBound($aFilterSplit) =" & UBound($aFilterSplit) & @LF)

	If $sExclude <> "" Then $sExclude = "(?i)(" & StringReplace(StringReplace(StringReplace($sExclude, ".", "\."), "*", ".*"), "?", ".") & ")" ;change the filters to RegExp filters
	ConsoleWrite("$sExclude="&$sExclude&@LF)
;~ 	exit
	;If recursion is desired, build an array of all sub-folders in search path (eliminates the need to run a conditional statement against FileAttrib)
	If $iRecurse Then;$cw = ConsoleWrite("UBound($aFilterSplit) =" & UBound($aFilterSplit) & @LF)

		;if folders only,  build string ($sFileString1) of foldernames within search path, recursion and exclusion options are passed from main function
		If $iFlag = 2 Then _FileListToArrayFolders1($sPath, $sFileString1, "*", $iRecurse, $sExclude)

		;if not folders only,  Build string ($sFileString1) of foldernames within search path, recursion (not exclusion, as would exclude some folders from subsequent filesearch) options are passed from main function
		If $iFlag <> 2 And StringTrimRight($sFilter, 1) <> "*"  And StringTrimRight($sFilter, 1) <> "*.*"  Then
			_FileListToArrayFolders1($sPath, $sFileString1, "*", $iRecurse, "")

			;Implode folder string
			$arFolders = StringSplit(StringTrimRight($sFileString1, 1), "*")

			;Store search path in first element
			$arFolders[0] = $sPath
		EndIf
	EndIf
	If $iFlag <> 2 And (StringTrimRight($sFilter, 1) == "*"  Or StringTrimRight($sFilter, 1) == "*.*") And $iRecurse Then
		If $iFlag = 1 Then
			_FileListToArrayRecFiles1($sPath, $sFileString, "*")
		ElseIf $iFlag = 0 Then
			_FileListToArrayRecAll1($sPath, $sFileString, "*")
		EndIf
	Else;If ($iFlag <> 2) then

		;Loop through folder array
		For $iCF = 0 To UBound($arFolders) - 1;    $cw = ConsoleWrite("$iCF=" & $iCF & " $arFolders[$iCF]    =" & @LF & $arFolders[$iCF] & @LF)

			;Verify folder name isn't just whitespace
			If StringStripWS($arFolders[$iCF], 8) = '' Then ContinueLoop

			;Loop through file filters
			For $iCC = 1 To UBound($aFilterSplit) - 1

				;Verify file filter isn't just whitespace
				If StringStripWS($aFilterSplit[$iCC], 8) = '' Then ContinueLoop

				;Append asterisk to file filter if a period is leading
				If StringLeft($aFilterSplit[$iCC], 1) == "."  Then $aFilterSplit[$iCC] = "*" & $aFilterSplit[$iCC] ;, "**", "*")

				;Replace multiple asterisks in file filter
				$sFilter = StringReplace("*" & $sFilter & "*", "**", "*")
				Select; options for not recursing; quicker than filtering after for single directory

					;Below needs work, _FileListToArrayBrief1a and _FileListToArrayBrief2a
					;should be consolidated with an option passed for the files / folders flag [says Ultima -but slower?]

					;Fastest, Not $iRecurse with with files and folders(? was written files only; just Not $iBaseDir), not recursed
					Case Not $iRecurse And Not $iFlag And Not $iBaseDir
						_FileListToArrayBrief2a($arFolders[$iCF], $sFileString, $aFilterSplit[$iCC], $sExclude)

						;Not $iRecurse and  And $iBaseDir ;fast, with files and folders, not recursed
					Case Not $iFlag
						_FileListToArrayBrief1a($arFolders[$iCF], $sFileString, $aFilterSplit[$iCC], $sExclude)

						;Fast, with files only,  not recursed
					Case $iFlag = 1
						_FileListToArrayFiles1($arFolders[$iCF], $sFileString, $aFilterSplit[$iCC], $sExclude)

						;Folders only , not recursed
					Case Not $iRecurse And $iFlag = 2
						_FileListToArrayFolders1($arFolders[$iCF], $sFileString, $aFilterSplit[$iCC], $iRecurse, $sExclude)
				EndSelect;$cw = ConsoleWrite("$iCC=" & $iCC & " $sFileString    =" & @LF & $sFileString & @LF)

				;Append pipe symbol and current file filter onto $sHoldSplit ???????
				If $iCF = 0 Then $sHoldSplit &= $sep & $aFilterSplit[$iCC]; $cw = ConsoleWrite("$iCC=" & $iCC & " $sFileString    =" & @LF & $sFileString & @LF)
			Next

			;Replace multiple asterisks
			If $iCF = 0 Then $sFilter = StringReplace(StringTrimLeft($sHoldSplit, 1), "**", "*");,$cw = ConsoleWrite("$iCC=" & $iCC & " $sFilter    =" & @LF & $sFilter & @LF)
		Next
	EndIf
	;Below needs work....
	
	;If recursive, folders-only, and filter ins't a wildcard
	If $iRecurse And ($iFlag = 2) And StringTrimRight($sFilter, 1) <> "*"  And StringTrimRight($sFilter, 1) <> "*.*"  And Not StringInStr($sFilter, "**") Then ; filter folders -------------------

		;Trim trailing character
		$sFileString1 = StringTrimRight(StringReplace($sFileString1, "*", @LF), 1)

		;Change the filters to RegExp filters
		$sFilter1 = StringReplace(StringReplace(StringReplace($sFilter1, ".", "\."), "*", ".*"), "?", ".")
		Local $pattern = '(?m)(^(?i)' & $sFilter1 & '$)' ;, $cw = ConsoleWrite("$sFilter    =" & @LF & $sFilter1 & @LF), $cw = ConsoleWrite("$pattern    =" & @LF & $pattern & @LF)
		$asList = StringRegExp($sFileString1, $pattern, 3)

		;If only relative file / folder names are desired
		If (Not $iBaseDir) Then

			; past ARRAY.AU3 DEPENDENCY
			$sFileString1 = _ArrayToString1($asList, "*")
			$sFileString1 = StringReplace($sFileString1, $sPath & "\", "", 0, 2)
			$asList = StringSplit($sFileString1, "*")
		EndIf
	ElseIf $iRecurse And ($iFlag = 2) Then
		$sFileString = StringStripCR($sFileString1)
	EndIf;If UBound($asList) > 1 Then ConsoleWrite("$asList[1]     =" & @LF & $asList[1] & @LF);~

	;past ARRAY.AU3 DEPENDENCY
	If IsArray($asList) And UBound($asList) > 0 And $asList[0] <> "" And Not IsNumber($asList[0]) Then _ArrayInsert1($asList, 0, UBound($asList))
	If IsArray($asList) And UBound($asList) > 1 And $asList[0] <> "" Then Return $asList
	If (Not $iBaseDir) Or (Not $iRecurse And Not $iFlag And Not $iBaseDir) Then $sFileString = StringReplace($sFileString, $sPath & "\", "", 0, 2)
	if $i_ReturnAsString then Return StringTrimRight($sFileString, 1)
	Local $arReturn = StringSplit(StringTrimRight($sFileString, 1), "*");~     local $a=ConsoleWrite("$sFileString :"&@lf&StringReplace($sFileString,"|",@crlf)&@lf),$timerstamp1=TimerInit()
	If $i_deleteduplicate And IsArray($arReturn) And UBound($arReturn) > 1 And $arReturn[1] <> "" And Not (UBound($aFilterSplit) = 3 And $aFilterSplit[2] == "") Then _ArrayDeleteDupes1($arReturn);and  $arFolders[1]<>""
	Return $arReturn;~     Return StringSplit(StringTrimRight($sFileString, 1), "*")
EndFunc   ;==>_FileListToArray3
;===============================================================================
;
; Description:  _ArrayDeleteDupes1; deletes duplicates in an Array 1D
; Syntax:           _ArrayDeleteDupes1(ByRef $ar_Array)
; Parameter(s):    	$ar_Array = 1d Array
; Requirement(s):   None
; Return Value(s):  On Success - Returns asorted array with no duplicates
;                        On Failure -
;						@Error=1 P
;						@Error=2
;
; Author(s):        randallc
;===============================================================================
Func _ArrayDeleteDupes1(ByRef $arrItems)
	If @OSTYPE = "WIN32_WINDOWS"  Then Return 0
	Local $i = 0, $objDictionary = ObjCreate("Scripting.Dictionary")
	For $strItem In $arrItems
		If Not $objDictionary.Exists($strItem) Then
			$objDictionary.Add($strItem, $strItem)
		EndIf
	Next
	ReDim $arrItems[$objDictionary.Count]
	For $strKey In $objDictionary.Keys
		$arrItems[$i] = $strKey
		$i += 1
	Next
	$arrItems[0] = $objDictionary.Count - 1
	Return 1
EndFunc   ;==>_ArrayDeleteDupes1
;===============================================================================
;
; Description:      Helper  self-calling func for  _FileListToArray wrapper; lists all  folders in a specified path
; Syntax:           _FileListToArrayFolders1($s_PathF, ByRef $s_FileStringF, $s_FilterF,  $i_RecurseF)
; Parameter(s):    	$s_PathF = Path to generate filelist for
;					$s_FileStringF = The string for lists all folders only in a specified path
;					$s_FilterF = The filter to use. Search the Autoit3 manual for the word "WildCards" For details
;					$i_RecurseF = Indicate whether recursion to subfolders required
;						$i_RecurseF=0(Default) No recursion to subfolders
;                       $i_RecurseF=1 recursion to subfolders
;					$sExcludeF= The Exclude filter to use.  "WildCards" For details
; Requirement(s):   None
; Return Value(s):  On Success - Returns an array containing the list of files and folders in the specified path
;                        On Failure - Returns the an empty string "" if no files are found and sets @Error on errors
;						@Error=1 Path not found or invalid
;						@Error=2 Invalid $s_Filter
;                       @Error=3 Invalid $i_Flag
;                 @Error=4 No File(s) Found
;
; Author(s):        randallc; modified from SolidSnake, SmoKe_N, GEOsoft and big_daddy
;===============================================================================
Func _FileListToArrayFolders1($sPathF, ByRef $sFileStringF, $sFilterF, $iRecurseF, $sExcludeF = "")
	Local $hSearch = FileFindFirstFile($sPathF & "\" & $sFilterF), $sPathF2, $sFileF
	If $hSearch = -1 Then Return SetError(4, 4, "")
	If $sExcludeF == "" Then
		While 1
			$sFileF = FileFindNextFile($hSearch)
			If @error Then ExitLoop

			$sPathF2 = $sPathF & "\" & $sFileF
			If StringInStr(FileGetAttrib($sPathF2), "D") Then ;directories only wanted; and  the attrib shows is  directory
				$sFileStringF &= $sPathF2 & "*" ;this writes the filename to the delimited string with * as delimiter
				If $iRecurseF = 1 Then _FileListToArrayFolders1($sPathF2, $sFileStringF, $sFilterF, $iRecurseF)
			EndIf
		WEnd
	Else
		While 1
			$sFileF = FileFindNextFile($hSearch)
			If @error Then ExitLoop

			$sPathF2 = $sPathF & "\" & $sFileF; if folders only and this pattern matches exclude pattern, no further list or subdir
			If StringRegExp($sPathF2, $sExcludeF) Then ContinueLoop
			If StringInStr(FileGetAttrib($sPathF2), "D") Then ;directories only wanted; and  the attrib shows is  directory
				$sFileStringF &= $sPathF2 & "*" ;this writes the filename to the delimited string with * as delimiter with * as delimiter
				If $iRecurseF = 1 Then _FileListToArrayFolders1($sPathF2, $sFileStringF, $sFilterF, $iRecurseF, $sExcludeF)
			EndIf
		WEnd
	EndIf
	FileClose($hSearch)
EndFunc   ;==>_FileListToArrayFolders1
Func RecursiveFileSearchC($startDir, $RFSpattern = "*", $Exclude = "", $depth = 0)
;~ 	If StringRight($startDir, 1) <> "\"  Then $startDir &= "\"
	If StringRight($startDir, 1) == "\"  Then $startDir = StringTrimRight($startDir, 1)

	If $depth = 0 Then
		;change filters to RegExp filters
		If $RFSpattern <> "" Then $RFSpattern = "(?i)(^" & StringReplace(StringReplace(StringReplace($RFSpattern, ".", "\."), "*", ".*"), "?", ".") & "$)" ;change the filters to RegExp filters
		If $Exclude <> "" Then $Exclude = "(?i)(^" & StringReplace(StringReplace(StringReplace($Exclude, ".", "\."), "*", ".*"), "?", ".") & "$)" ;change the filters to RegExp filters

		;Get count of all files in subfolders
		Local $RFSfilecount = DirGetSize($startDir, 1)
		Global $RFSarray[$RFSfilecount[1] + 1]
	EndIf

	Local $search = FileFindFirstFile($startDir & "\*.*")
	If @error Then Return

	;Search through all files and folders in directory
	While 1
		Local $next = FileFindNextFile($search)
		If @error Then ExitLoop

		;If folder, recurse
		If StringInStr(FileGetAttrib($startDir & "\" & $next), "D") Then
			RecursiveFileSearchC($startDir & "\" & $next, $RFSpattern, $Exclude, $depth + 1)
		Else
			If StringRegExp($next, $RFSpattern, 0) And Not StringRegExp($next, $Exclude, 0) Then
				;Append filename to array
				$RFSarray[$RFSarray[0] + 1] = $startDir & "\" & $next

				;Increment filecount
				$RFSarray[0] += 1
			EndIf
		EndIf
	WEnd
	FileClose($search)

	If $depth = 0 Then
		ReDim $RFSarray[$RFSarray[0] + 1]
		Return $RFSarray
	EndIf
EndFunc   ;==>RecursiveFileSearchC
;
; Description:      Helper  func for  _FileListToArray wrapper; lists all files in a specified path
; Syntax:           _FileListToArrayFiles1($s_PathF, ByRef $s_FileStringF, $s_FilterF) ;quick as not recursive
; Parameter(s):    	$s_PathF = Path to generate filelist for
;					$s_FileStringF = The string for lists all files and folders in a specified path
;					$s_FilterF = The filter to use. Search the Autoit3 manual for the word "WildCards" For details
;					$sExcludeF= The Exclude filter to use.  "WildCards" For details
; Requirement(s):   None
; Return Value(s):  On Success - Returns an array containing the list of files and folders in the specified path
;                        On Failure - Returns the an empty string "" if no files are found and sets @Error on errors
;						@Error=1 Path not found or invalid
;						@Error=2 Invalid $s_Filter
;                 @Error=4 No File(s) Found
;
; Author(s):        randallc; modified from SolidSnake, SmoKe_N, GEOsoft and big_daddy
;===============================================================================
Func _FileListToArrayFiles1($sPathF, ByRef $sFileStringF, $sFilterF, $sExcludeF = "")
	Local $hSearch = FileFindFirstFile($sPathF & "\" & $sFilterF), $sPathF2, $sFileF
	If $hSearch = -1 Then Return SetError(4, 4, "")
	If $sExcludeF == "" Then
		While 1
			$sFileF = FileFindNextFile($hSearch)
			If @error Then ExitLoop

			$sPathF2 = $sPathF & "\" & $sFileF;directories not wanted; and  the attrib shows not  directory
			If Not StringInStr(FileGetAttrib($sPathF2), "D") Then
				$sFileStringF &= $sPathF2 & "*" ;this writes the filename to the delimited string with * as delimiter
			EndIf
		WEnd
	Else
		While 1
			$sFileF = FileFindNextFile($hSearch)
			If @error Then ExitLoop

			$sPathF2 = $sPathF & "\" & $sFileF;directories not wanted; and  the attrib shows not  directory; and filename [only]  does not match exclude
			If Not StringInStr(FileGetAttrib($sPathF2), "D") _
					And Not StringRegExp($sFileF, $sExcludeF) Then $sFileStringF &= $sPathF2 & "*" ;this writes the filename to the delimited string with * as delimiter
		WEnd
	EndIf
	FileClose($hSearch)
EndFunc   ;==>_FileListToArrayFiles1
;===============================================================================
;
; Description:      Helper  self-calling func for  _FileListToArray wrapper; lists all files and folders in a specified path, recursive
; Syntax:           _FileListToArrayRecFiles1($s_PathF, ByRef $s_FileStringF, $s_FilterF) ; recursive
; Parameter(s):    	$s_PathF = Path to generate filelist for
;					$s_FileStringF = The string for lists all files and folders in a specified path
;					$s_FilterF = The filter to use. Search the Autoit3 manual for the word "WildCards" For details
;					$sExcludeF= The Exclude filter to use.  "WildCards" For details
; Requirement(s):   None
; Return Value(s):  On Success - Returns an array containing the list of files and folders in the specified path
;                        On Failure - Returns the an empty string "" if no files are found and sets @Error on errors
;						@Error=1 Path not found or invalid
;						@Error=2 Invalid $s_Filter
;                 @Error=4 No File(s) Found
;
; Author(s):        randallc; modified from SolidSnake, SmoKe_N, GEOsoft and big_daddy
;===============================================================================
Func _FileListToArrayRecAll1($sPathF, ByRef $sFileStringF, $sFilterF, $sExcludeF = "")
	Local $hSearch = FileFindFirstFile($sPathF & "\" & $sFilterF), $sPathF2, $sFileF
	If $hSearch = -1 Then Return SetError(4, 4, "")
	If $sExcludeF == "" Then
		While 1
			$sFileF = FileFindNextFile($hSearch)
			If @error Then ExitLoop

			$sPathF2 = $sPathF & "\" & $sFileF
			$sFileStringF &= $sPathF2 & "*" ;this writes the filename to the delimited string with * as delimiter
			If StringInStr(FileGetAttrib($sPathF2), "D") Then _FileListToArrayRecAll1($sPathF2, $sFileStringF, $sFilterF);, $iFlagF, $iRecurseF)
		WEnd
	Else
		While 1
			$sFileF = FileFindNextFile($hSearch)
			If @error Then ExitLoop

			$sPathF2 = $sPathF & "\" & $sFileF
			If StringInStr(FileGetAttrib($sPathF2), "D") Then
				$sFileStringF &= $sPathF2 & "*" ;this writes the directoryname
				_FileListToArrayRecAll1($sPathF2, $sFileStringF, $sFilterF, $sExcludeF);, $iFlagF, $iRecurseF)
			Else ;if not directory, check Exclude match
				If Not StringRegExp($sFileF, $sExcludeF) Then $sFileStringF &= $sPathF2 & "*" ;this writes the filename to the delimited string with * as delimiter
			EndIf
		WEnd
	EndIf
	FileClose($hSearch)
EndFunc   ;==>_FileListToArrayRecAll1
;===============================================================================
;
; Description:      Helper  self-calling func for  _FileListToArray wrapper; lists all files  in a specified path, recursive
; Syntax:           _FileListToArrayRecFiles1($s_PathF, ByRef $s_FileStringF, $s_FilterF) ; recursive
; Parameter(s):    	$s_PathF = Path to generate filelist for
;					$s_FileStringF = The string for lists all files and folders in a specified path
;					$s_FilterF = The filter to use. Search the Autoit3 manual for the word "WildCards" For details
;					$sExcludeF= The Exclude filter to use.  "WildCards" For details
; Requirement(s):   None
; Return Value(s):  On Success - Returns an array containing the list of files and folders in the specified path
;                        On Failure - Returns the an empty string "" if no files are found and sets @Error on errors
;						@Error=1 Path not found or invalid
;						@Error=2 Invalid $s_Filter
;                 @Error=4 No File(s) Found
;
; Author(s):        randallc; modified from SolidSnake, SmoKe_N, GEOsoft and big_daddy
;===============================================================================
Func _FileListToArrayRecFiles1($sPathF, ByRef $sFileStringF, $sFilterF, $sExcludeF = "")
	Local $hSearch = FileFindFirstFile($sPathF & "\" & $sFilterF), $sPathF2, $sFileF
	If $hSearch = -1 Then Return SetError(4, 4, "")
	If $sExcludeF == "" Then
		While 1
			$sFileF = FileFindNextFile($hSearch)
			If @error Then ExitLoop

			$sPathF2 = $sPathF & "\" & $sFileF
			If StringInStr(FileGetAttrib($sPathF2), "D") Then
				_FileListToArrayRecFiles1($sPathF2, $sFileStringF, $sFilterF);, $iFlagF, $iRecurseF)
			Else
				$sFileStringF &= $sPathF2 & "*" ;this writes the filename to the delimited string with * as delimiter
			EndIf
		WEnd
	Else
		While 1
			$sFileF = FileFindNextFile($hSearch)
			If @error Then ExitLoop

			$sPathF2 = $sPathF & "\" & $sFileF
			If StringInStr(FileGetAttrib($sPathF2), "D") Then
				_FileListToArrayRecFiles1($sPathF2, $sFileStringF, $sFilterF, $sExcludeF);, $iFlagF, $iRecurseF)
			Else
				If Not StringRegExp($sFileF, $sExcludeF) Then $sFileStringF &= $sPathF2 & "*" ;this writes the filename to the delimited string with * as delimiter
			EndIf
		WEnd
	EndIf
	FileClose($hSearch)
EndFunc   ;==>_FileListToArrayRecFiles1
;===============================================================================
;
; Description:      Helper  func for  _FileListToArray wrapper; ;Fastest, Not $iRecurse with with files and folders(? was written files only; just Not $iBaseDir), not recursed
; Syntax:           _FileListToArrayBrief2a($s_PathF, ByRef $s_FileStringF, $s_FilterF) ;quick as not recursive
; Parameter(s):    	$s_PathF = Path to generate filelist for
;					$s_FileStringF = The string for lists all files and folders in a specified path
;					$s_FilterF = The filter to use. Search the Autoit3 manual for the word "WildCards" For details
;					$sExcludeF= The Exclude filter to use.  "WildCards" For details
; Requirement(s):   None
; Return Value(s):  On Success - Returns an array containing the list of files and folders in the specified path
;                        On Failure - Returns the an empty string "" if no files are found and sets @Error on errors
;						@Error=1 Path not found or invalid
;						@Error=2 Invalid $s_Filter
;                 @Error=4 No File(s) Found
;
; Author(s):        randallc; modified from SolidSnake, SmoKe_N, GEOsoft and big_daddy
;===============================================================================
Func _FileListToArrayBrief2a($sPathF, ByRef $sFileStringF, $sFilterF, $sExcludeF = "")
	Local $hSearch = FileFindFirstFile($sPathF & "\" & $sFilterF), $sFileF
	If $hSearch = -1 Then Return SetError(4, 4, "")
	If $sExcludeF == "" Then
		While 1
			$sFileF = FileFindNextFile($hSearch)
			If @error Then ExitLoop

			$sFileStringF &= $sFileF & "*" ;this writes the filename to the delimited string with * as delimiter; only time no full path included
		WEnd
	Else
		While 1
			$sFileF = FileFindNextFile($hSearch)
			If @error Then ExitLoop

			;If not StringRegExp($sFileF,$sExcludeF) then $sFileStringF &= $sPathF2 & "*"
			If Not StringRegExp($sFileF, $sExcludeF) Then $sFileStringF &= $sFileF & "*" ;this writes the filename to the delimited string with * as delimiter; only time no full path included
		WEnd
	EndIf
	FileClose($hSearch)
EndFunc   ;==>_FileListToArrayBrief2a
;===============================================================================
;
; Description:      Helper  func for  _FileListToArray wrapper; lists all files and folders in a specified path, not recursive
; Syntax:           _FileListToArrayBrief1a($s_PathF, ByRef $s_FileStringF, $s_FilterF) ;quick as not recursive
; Parameter(s):    	$s_PathF = Path to generate filelist for
;					$s_FileStringF = The string for lists all files and folders in a specified path
;					$s_FilterF = The filter to use. Search the Autoit3 manual for the word "WildCards" For details
;					$sExcludeF= The Exclude filter to use.  "WildCards" For details
; Requirement(s):   None
; Return Value(s):  On Success - Returns an array containing the list of files and folders in the specified path
;                        On Failure - Returns the an empty string "" if no files are found and sets @Error on errors
;						@Error=1 Path not found or invalid
;						@Error=2 Invalid $s_Filter
;                 @Error=4 No File(s) Found
;
; Author(s):        randallc; modified from SolidSnake, SmoKe_N, GEOsoft and big_daddy
;===============================================================================
Func _FileListToArrayBrief1a($sPathF, ByRef $sFileStringF, $sFilterF, $sExcludeF = "")
	Local $hSearch = FileFindFirstFile($sPathF & "\" & $sFilterF), $sFileF
	If $hSearch = -1 Then Return SetError(4, 4, "")
	If $sExcludeF == "" Then
		While 1
			$sFileF = FileFindNextFile($hSearch)
			If @error Then ExitLoop

			$sFileStringF &= $sPathF & "\" & $sFileF & "*" ;this writes the filename to the delimited string with * as delimiter [remo]
		WEnd
	Else
		While 1
			$sFileF = FileFindNextFile($hSearch)
			If @error Then ExitLoop

			If Not StringRegExp($sFileF, $sExcludeF) Then $sFileStringF &= $sPathF & "\" & $sFileF & "*" ;this writes the filename to the delimited string with * as delimiter [remo]
		WEnd
	EndIf
	FileClose($hSearch)
EndFunc   ;==>_FileListToArrayBrief1a
Func _ArrayToString1(Const ByRef $avArray, $sDelim = "|", $iStart = 0, $iEnd = 0)
	If Not IsArray($avArray) Then Return SetError(1, 0, "")

	Local $sResult, $iUBound = UBound($avArray) - 1

	; Bounds checking
	If $iEnd < 1 Or $iEnd > $iUBound Then $iEnd = $iUBound
	If $iStart < 0 Then $iStart = 0
	If $iStart > $iEnd Then Return SetError(2, 0, "")

	; Combine
	For $i = $iStart To $iEnd
		$sResult &= $avArray[$i] & $sDelim
	Next

	Return StringTrimRight($sResult, StringLen($sDelim))
EndFunc   ;==>_ArrayToString1
Func _ArrayInsert1(ByRef $avArray, $iElement, $vValue = "")
	If Not IsArray($avArray) Then Return SetError(1, 0, 0)

	; Add 1 to the array
	Local $iUBound = UBound($avArray) + 1
	ReDim $avArray[$iUBound]

	; Move all entries over til the specified element
	For $i = $iUBound - 1 To $iElement + 1 Step - 1
		$avArray[$i] = $avArray[$i - 1]
	Next

	; Add the value in the specified element
	$avArray[$iElement] = $vValue
	Return $iUBound
EndFunc   ;==>_ArrayInsert1