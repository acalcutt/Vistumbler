#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_icon=Icons\icon.ico
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
;License Information------------------------------------
;Copyright (C) 2008 Andrew Calcutt
;This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; Version 2 of the License.
;This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
;You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
;--------------------------------------------------------
;AutoIt Version: v3.2.13.11 Beta
$Script_Author = 'Andrew Calcutt'
$Script_Name = 'Vistumbler Updater'
$Script_Website = 'http://www.Vistumbler.net'
$Script_Function = 'Updates Vistumbler from SVN based on version.ini'
$version = 'v2.0'
$origional_date = '09/01/2008'
$last_modified = '6/27/2008'
;--------------------------------------------------------
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#Include <Array.au3>

Dim $LoadVersionFile
Dim $NewVersionFile = @ScriptDir & '\temp\versions.ini'
Dim $CurrentVersionFile = @ScriptDir & '\versions.ini'
Dim $settings = @ScriptDir & '\Settings\vistumbler_settings.ini'
Dim $VIEWSVN_ROOT = 'http://vistumbler.svn.sourceforge.net/viewvc/vistumbler/VistumblerMDB/'
Dim $CheckForBetaUpdates = IniRead($settings, 'Vistumbler', 'CheckForBetaUpdates', 0)
Dim $TextColor = IniRead($settings, 'Vistumbler', 'TextColor', "0x000000")
Dim $BackgroundColor = IniRead($settings, 'Vistumbler', 'BackgroundColor', "0x99B4A1")
Dim $ControlBackgroundColor = IniRead($settings, 'Vistumbler', 'ControlBackgroundColor', "0xD7E4C2")

$data = 'Loading Versions File'
$UpdateGUI = GUICreate("Updating Vistumbler", 350, 300)
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
	$data = 'Using local file : ' & $NewVersionFile & @CRLF & $data
	GUICtrlSetData($UpdateEdit, $data)
Else
	FileDelete($NewVersionFile)
	DirCreate(@ScriptDir & '\temp\')
	If $CheckForBetaUpdates = 1 Then
		$data = 'Downloading Beta Versions File' & @CRLF & $data
		GUICtrlSetData($UpdateEdit, $data)
		$get = InetGet($VIEWSVN_ROOT & 'versions-beta.ini', $NewVersionFile)
		If $get = 0 Then FileDelete($NewVersionFile)
	Else
		$data = 'Downloading Versions File' & @CRLF & $data
		GUICtrlSetData($UpdateEdit, $data)
		$get = InetGet($VIEWSVN_ROOT & 'versions.ini', $NewVersionFile)
		If $get = 0 Then FileDelete($NewVersionFile)
	EndIf
	If FileExists($NewVersionFile) Then
		$data = 'Versions File Downloaded' & @CRLF & $data
		GUICtrlSetData($UpdateEdit, $data)
	Else
		$data = 'Error Downloading Versions File' & @CRLF & $data
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
						InetGet($VIEWSVN_ROOT & $filename_web & '?revision=' & $version, @ScriptDir & '\' & $filename, 1, 1)
						While @InetGetActive
							$txt = 'Updating ' & $filename & '. Downloaded ' & @InetGetBytesRead / 1000 & 'kB'
							GUICtrlSetData($datalabel, $txt)
							Sleep(5)
						Wend
						If @InetGetBytesRead = -1 Then $getfileerror = 1
						If $getfileerror = 0 Then
							IniWrite($CurrentVersionFile, "FileVersions", $filename, $version)
							$data = 'New File:' & $filename & @CRLF & $data
							GUICtrlSetData($UpdateEdit, $data)
							;ConsoleWrite('New File:' & $filename & @CRLF)
						Else
							$data = 'Error Downloading New File:' & $filename & @CRLF & $data
							GUICtrlSetData($UpdateEdit, $data)
							;ConsoleWrite('Error Downloading New File:' & $filename & @CRLF)
						EndIf
						GUICtrlSetData($datalabel, '')
				Else
					$data = 'No Change In File:' & $filename & @CRLF & $data
					GUICtrlSetData($UpdateEdit, $data)
					;ConsoleWrite('No Change In File:' & $filename & @CRLF)
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
					$data = 'Deleted File:' & $filename & @CRLF & $data
					GUICtrlSetData($UpdateEdit, $data)
					IniDelete ($CurrentVersionFile, 'FileVersions' , $filename)
				Else
					$data = 'Error Deleting File:' & $filename & @CRLF & $data
					GUICtrlSetData($UpdateEdit, $data)
				EndIf
			EndIf
		Next
	EndIf
	FileDelete($NewVersionFile)
EndIf

$updatemsg = MsgBox(4, 'Done', 'Done. Would you like to load vistumbler?')
If $updatemsg = 6 Then Run(@ScriptDir & '\Vistumbler.exe')

Exit
