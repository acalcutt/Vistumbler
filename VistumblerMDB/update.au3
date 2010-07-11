#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_icon=Icons\icon.ico
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
;License Information------------------------------------
;Copyright (C) 2010 Andrew Calcutt
;This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; Version 2 of the License.
;This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
;You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
;--------------------------------------------------------
;AutoIt Version: v3.3.6.1
$Script_Author = 'Andrew Calcutt'
$Script_Name = 'Vistumbler Updater'
$Script_Website = 'http://www.Vistumbler.net'
$Script_Function = 'Updates Vistumbler from SVN based on version.ini'
$version = 'v5'
$origional_date = '2010/09/01'
$last_modified = '2010/07/11' ; Happy Birthday Vistumbler!
;--------------------------------------------------------
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#Include <Array.au3>

Dim $Errors
Dim $NewFiles
Dim $LoadVersionFile
Dim $NewVersionFile = @ScriptDir & '\temp\versions.ini'
Dim $CurrentVersionFile = @ScriptDir & '\versions.ini'
Dim $settings = @ScriptDir & '\Settings\vistumbler_settings.ini'
Dim $VIEWSVN_ROOT = 'http://svn.vistumbler.net/viewvc/vistumbler/VistumblerMDB/'
Dim $CheckForBetaUpdates = IniRead($settings, 'Vistumbler', 'CheckForBetaUpdates', 0)
Dim $TextColor = IniRead($settings, 'Vistumbler', 'TextColor', "0x000000")
Dim $BackgroundColor = IniRead($settings, 'Vistumbler', 'BackgroundColor', "0x99B4A1")
Dim $ControlBackgroundColor = IniRead($settings, 'Vistumbler', 'ControlBackgroundColor', "0xD7E4C2")

;Set GUI text based on default language
Dim $LanguageDir = @ScriptDir & '\Languages\'
Dim $DefaultLanguageFile = IniRead($settings, 'Vistumbler', 'LanguageFile', 'English.ini')
Dim $DefaultLanguagePath = $LanguageDir & $DefaultLanguageFile
If FileExists($DefaultLanguagePath) = 0 Then
	$DefaultLanguageFile = 'English.ini'
	$DefaultLanguagePath = $LanguageDir & $DefaultLanguageFile
EndIf
Dim $Text_Done = IniRead($DefaultLanguagePath, 'GuiText', 'Done', 'Done')
Dim $Text_Error = IniRead($DefaultLanguagePath, 'GuiText', 'Error', 'Error')
Dim $Text_Updating = IniRead($DefaultLanguagePath, 'GuiText', 'Updating', 'Updating')
Dim $Text_Downloaded = IniRead($DefaultLanguagePath, 'GuiText', 'Downloaded', 'Downloaded')
Dim $Text_Retry = IniRead($DefaultLanguagePath, 'GuiText', 'Retry', 'Retry')
Dim $Text_Ignore = IniRead($DefaultLanguagePath, 'GuiText', 'Ignore', 'Ignore')
Dim $Text_Yes = IniRead($DefaultLanguagePath, 'GuiText', 'Yes', 'Yes')
Dim $Text_No = IniRead($DefaultLanguagePath, 'GuiText', 'No', 'No')
Dim $Text_LoadingVersionsFile = IniRead($DefaultLanguagePath, 'GuiText', 'LoadingVersionsFile', 'Loading Versions File')
Dim $Text_UsingLocalFile = IniRead($DefaultLanguagePath, 'GuiText', 'UsingLocalFile', 'Using local file')
Dim $Text_DownloadingBetaVerFile = IniRead($DefaultLanguagePath, 'GuiText', 'DownloadingBetaVerFile', 'Downloading beta versions file')
Dim $Text_DownloadingVerFile = IniRead($DefaultLanguagePath, 'GuiText', 'DownloadingVerFile', 'Downloading versions file')
Dim $Text_VerFileDownloaded = IniRead($DefaultLanguagePath, 'GuiText', 'VerFileDownloaded', 'Versions file downloaded')
Dim $Text_ErrDownloadVerFile = IniRead($DefaultLanguagePath, 'GuiText', 'ErrDownloadVerFile', 'Error downloading versions file')
Dim $Text_NewFile = IniRead($DefaultLanguagePath, 'GuiText', 'NewFile', 'New file')
Dim $Text_UpdatedFile = IniRead($DefaultLanguagePath, 'GuiText', 'UpdatedFile', 'Updated File')
Dim $Text_ErrCopyingFile = IniRead($DefaultLanguagePath, 'GuiText', 'ErrCopyingFile', 'Error copying file')
Dim $Text_ErrReplacaingOldFile = IniRead($DefaultLanguagePath, 'GuiText', 'ErrReplacaingOldFile', 'Error replacing old file (Possibly in use)')
Dim $Text_ErrDownloadingNewFile = IniRead($DefaultLanguagePath, 'GuiText', 'ErrDownloadingNewFile', 'Error downloading new file')
Dim $Text_NoChangeInFile = IniRead($DefaultLanguagePath, 'GuiText', 'NoChangeInFile', 'No change in file')
Dim $Text_DeletedFile = IniRead($DefaultLanguagePath, 'GuiText', 'DeletedFile', 'Deleted file')
Dim $Text_ErrDeletingFile = IniRead($DefaultLanguagePath, 'GuiText', 'ErrDeletingFile', 'Error deleting file')
Dim $Text_ErrWouldYouLikeToRetryUpdate = IniRead($DefaultLanguagePath, 'GuiText', 'ErrWouldYouLikeToRetryUpdate', 'Error. Would you like to retry the update?')
Dim $Text_DoneWouldYouLikeToLoadVistumbler = IniRead($DefaultLanguagePath, 'GuiText', 'DoneWouldYouLikeToLoadVistumbler', 'Done. Would you like to load vistumbler?')

$UpdateGUI = GUICreate($Script_Name & ' ' & $version, 350, 300, -1, -1, BitOR($WS_OVERLAPPEDWINDOW, $WS_CLIPSIBLINGS))
$data = $Text_LoadingVersionsFile
GUISetBkColor($BackgroundColor)
$datalabel = GUICtrlCreateLabel("", 10, 10, 330, 15)
GUICtrlSetColor(-1, $TextColor)
$UpdateEdit = GUICtrlCreateEdit($data, 10, 30, 330, 260)
GUICtrlSetBkColor(-1, $ControlBackgroundColor)
GUISetState(@SW_SHOW)

For $loop = 1 To $CmdLine[0]
	If StringInStr($CmdLine[$loop], '/s') Then
		$filesplit = StringSplit($CmdLine[$loop], "=")
		If $filesplit[0] = 2 Then $LoadVersionFile = $filesplit[2]
	EndIf
Next

If $LoadVersionFile <> '' And FileExists($LoadVersionFile) Then
	$NewVersionFile = $LoadVersionFile
	$data = $Text_UsingLocalFile & ' : ' & $NewVersionFile & @CRLF & $data
	GUICtrlSetData($UpdateEdit, $data)
Else
	FileDelete($NewVersionFile)
	DirCreate(@ScriptDir & '\temp\')
	If $CheckForBetaUpdates = 1 Then
		$data = $Text_DownloadingBetaVerFile & @CRLF & $data
		GUICtrlSetData($UpdateEdit, $data)
		$get = InetGet($VIEWSVN_ROOT & 'versions-beta.ini', $NewVersionFile)
		If $get = 0 Then FileDelete($NewVersionFile)
	Else
		$data = $Text_DownloadingVerFile & @CRLF & $data
		GUICtrlSetData($UpdateEdit, $data)
		$get = InetGet($VIEWSVN_ROOT & 'versions.ini', $NewVersionFile)
		If $get = 0 Then FileDelete($NewVersionFile)
	EndIf
	If FileExists($NewVersionFile) Then
		$data = $Text_VerFileDownloaded & @CRLF & $data
		GUICtrlSetData($UpdateEdit, $data)
	Else
		$data = $Text_ErrDownloadVerFile & @CRLF & $data
		GUICtrlSetData($UpdateEdit, $data)
	EndIf
EndIf

If FileExists($NewVersionFile) Then
	$fv = IniReadSection($NewVersionFile, "FileVersions")
	If Not @error Then
		For $i = 1 To $fv[0][0]
			$filename = $fv[$i][0]
			$filename_web = StringReplace($filename, '\', '/')
			$version = $fv[$i][1]
			If $filename <> 'update.exe' Then
				If IniRead($CurrentVersionFile, "FileVersions", $filename, '0') <> $version Or FileExists(@ScriptDir & '\' & $filename) = 0 Then
					If StringInStr($filename, '\') Then
						$struct = StringSplit($filename, '\')
						For $cp = 1 to $struct[0] - 1
							If $cp = 1 Then
								$dirstruct = $struct[$cp]
							Else
								$dirstruct &= '\' & $struct[$cp]
							EndIf
							DirCreate(@ScriptDir & '\' & $dirstruct)
						Next
					EndIf
						$getfileerror = 0
						$dfile = InetGet($VIEWSVN_ROOT & $filename_web & '?revision=' & $version, @ScriptDir & '\' & $filename & '.tmp', 1, 1)
						While InetGetInfo();While Download Active
							$txt = 'Updating ' & $filename & '. Downloaded ' & InetGetInfo($dfile, 0) / 1000 & 'kB'
							GUICtrlSetData($datalabel, $txt)
							Sleep(5)
						Wend
						If InetGetInfo($dfile, 3) = False Then $getfileerror = 1
						If $getfileerror = 0 And FileGetSize ($filename & '.tmp') <> 0 Then
							$ExistingFile = 0
							If FileExists(@ScriptDir & '\' & $filename) Then
								$ExistingFile = 1
								FileDelete(@ScriptDir & '\' & $filename)
							EndIf
							If FileMove(@ScriptDir & '\' & $filename & '.tmp', @ScriptDir & '\' & $filename) = 1 Then
								If $ExistingFile = 0 Then
									$data = $Text_NewFile & ':' & $filename & @CRLF & $data
									$NewFiles &= $Text_NewFile & ':' & $filename & @CRLF
								Else
									$data = $Text_UpdatedFile & ':' & $filename & @CRLF & $data
									$NewFiles &= $Text_UpdatedFile & ':' & $filename & @CRLF
								EndIf
								IniWrite($CurrentVersionFile, "FileVersions", $filename, $version)
							Else
								If $ExistingFile = 0 Then
									$data = $Text_ErrCopyingFile & ':' & $filename & @CRLF & $data
									$Errors &= $Text_ErrCopyingFile & ':' & $filename & @CRLF
								Else
									$data = $Text_ErrReplacaingOldFile & ':' & $filename & @CRLF & $data
									$Errors &= $Text_ErrReplacaingOldFile & ':' & $filename & @CRLF
								EndIf
							EndIf
							GUICtrlSetData($UpdateEdit, $data)
						Else
							$data = $Text_ErrDownloadingNewFile & ':' & $filename & @CRLF & $data
							$Errors &= $Text_ErrDownloadingNewFile & ':' & $filename  & @CRLF
							GUICtrlSetData($UpdateEdit, $data)
						EndIf
						If FileExists(@ScriptDir & '\' & $filename & '.tmp') Then FileDelete(@ScriptDir & '\' & $filename & '.tmp')
						GUICtrlSetData($datalabel, '')
				Else
					$data = $Text_NoChangeInFile & ':' & $filename & @CRLF & $data
					GUICtrlSetData($UpdateEdit, $data)
				EndIf
			EndIf
		Next
	EndIf
	$rm = IniReadSection($NewVersionFile, "RemovedFiles")
	If Not @error Then
		For $i = 1 To $rm[0][0]
			$filename = $rm[$i][0]
			$filefullpath = @ScriptDir & '\' & $filename
			If FileExists($filefullpath) Then
				If FileDelete($filefullpath) = 1 Then
					$data = $Text_DeletedFile & ':' & $filename & @CRLF & $data
					$NewFiles &= $Text_DeletedFile & ':' & $filename & @CRLF
					GUICtrlSetData($UpdateEdit, $data)
					IniDelete ($CurrentVersionFile, 'FileVersions' , $filename)
				Else
					$data = $Text_ErrDeletingFile & ':' & $filename & @CRLF & $data
					$Errors &= $Text_ErrDeletingFile & ':' & $filename & @CRLF
					GUICtrlSetData($UpdateEdit, $data)
				EndIf
			EndIf
		Next
	EndIf
	FileDelete($NewVersionFile)
EndIf

GUIDelete($UpdateGUI)

If $Errors <> '' Then
	$errormsg = _MsgBox($Text_Error, $Text_ErrWouldYouLikeToRetryUpdate & @CRLF & @CRLF & $Errors, $Text_Retry, $Text_Ignore)
	If $errormsg = 1 Then
		Run(@ScriptDir & '\update.exe')
		Exit
	EndIf
EndIf

_WriteLanguageINI()

$updatemsg = _MsgBox($Text_Done, $Text_DoneWouldYouLikeToLoadVistumbler & @CRLF & @CRLF & $NewFiles, $Text_Yes, $Text_No)
If $updatemsg = 1 Then Run(@ScriptDir & '\Vistumbler.exe')

Exit

Func _MsgBox($title, $msg, $But1txt, $But2txt)
	$MsgBoxGUI = GUICreate($title, 442, 234, -1, -1, BitOR($WS_OVERLAPPEDWINDOW, $WS_CLIPSIBLINGS))
	GUISetBkColor($BackgroundColor)
	$MsgBox = GUICtrlCreateEdit($msg, 8, 8, 425, 185, $ES_READONLY + $WS_VSCROLL + $WS_HSCROLL)
	GUICtrlSetBkColor(-1, $ControlBackgroundColor)
	$But1 = GUICtrlCreateButton($But1txt, 120, 200, 81, 25)
	$But2 = GUICtrlCreateButton($But2txt, 223, 200, 81, 25)
	GUISetState(@SW_SHOW)
	While 1
		$nMsg = GUIGetMsg()
		Switch $nMsg
			Case $GUI_EVENT_CLOSE
				GUIDelete($MsgBoxGUI)
				Return(0)
			Case $But1
				GUIDelete($MsgBoxGUI)
				Return(1)
			Case $But2
				GUIDelete($MsgBoxGUI)
				Return(2)
		EndSwitch
	WEnd
EndFunc

Func _WriteLanguageINI()
	IniWrite($DefaultLanguagePath, "GuiText", "Done", $Text_Done)
	IniWrite($DefaultLanguagePath, "GuiText", "Error", $Text_Error)
	IniWrite($DefaultLanguagePath, "GuiText", "Updating", $Text_Updating)
	IniWrite($DefaultLanguagePath, "GuiText", "Downloaded", $Text_Downloaded)
	IniWrite($DefaultLanguagePath, "GuiText", "Retry", $Text_Retry)
	IniWrite($DefaultLanguagePath, "GuiText", "Ignore", $Text_Ignore)
	IniWrite($DefaultLanguagePath, "GuiText", "Yes", $Text_Yes)
	IniWrite($DefaultLanguagePath, "GuiText", "No", $Text_No)
	IniWrite($DefaultLanguagePath, "GuiText", "LoadingVersionsFile", $Text_LoadingVersionsFile)
	IniWrite($DefaultLanguagePath, 'GuiText', 'UsingLocalFile', $Text_UsingLocalFile)
	IniWrite($DefaultLanguagePath, 'GuiText', 'DownloadingBetaVerFile', $Text_DownloadingBetaVerFile)
	IniWrite($DefaultLanguagePath, "GuiText", "DownloadingVerFile", $Text_DownloadingVerFile)
	IniWrite($DefaultLanguagePath, "GuiText", "VerFileDownloaded", $Text_VerFileDownloaded)
	IniWrite($DefaultLanguagePath, "GuiText", "ErrDownloadVerFile", $Text_ErrDownloadVerFile)
	IniWrite($DefaultLanguagePath, "GuiText", "NewFile", $Text_NewFile)
	IniWrite($DefaultLanguagePath, "GuiText", "UpdatedFile", $Text_UpdatedFile)
	IniWrite($DefaultLanguagePath, "GuiText", "ErrCopyingFile", $Text_ErrCopyingFile)
	IniWrite($DefaultLanguagePath, "GuiText", "ErrReplacaingOldFile", $Text_ErrReplacaingOldFile)
	IniWrite($DefaultLanguagePath, "GuiText", "ErrDownloadingNewFile", $Text_ErrDownloadingNewFile)
	IniWrite($DefaultLanguagePath, "GuiText", "NoChangeInFile", $Text_NoChangeInFile)
	IniWrite($DefaultLanguagePath, 'GuiText', 'DeletedFile', $Text_DeletedFile)
	IniWrite($DefaultLanguagePath, 'GuiText', 'ErrDeletingFile', $Text_ErrDeletingFile)
	IniWrite($DefaultLanguagePath, "GuiText", "ErrWouldYouLikeToRetryUpdate", $Text_ErrWouldYouLikeToRetryUpdate)
	IniWrite($DefaultLanguagePath, 'GuiText', 'DoneWouldYouLikeToLoadVistumbler', $Text_DoneWouldYouLikeToLoadVistumbler)
EndFunc
