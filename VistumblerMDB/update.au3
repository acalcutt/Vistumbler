#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Version=beta
#AutoIt3Wrapper_icon=icon.ico
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
;License Information------------------------------------
;Copyright (C) 2008 Andrew Calcutt
;This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; Version 2 of the License.
;This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
;You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
;--------------------------------------------------------
;AutoIt Version: v3.2.13.7 Beta
$Script_Author = 'Andrew Calcutt'
$Script_Name = 'Vistumbler Updater'
$Script_Website = 'http://www.Vistumbler.net'
$Script_Function = 'Updates Vistumbler from SVN based on version.ini'
$version = 'v1.0'
$last_modified = '09/01/2008'
;--------------------------------------------------------
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#Include <Array.au3>

$CurrentVersionFile = @ScriptDir & '\versions.ini'
$NewVersionFile = @ScriptDir & '\temp\versions.ini'
$VIEWSVN_ROOT = 'http://vistumbler.svn.sourceforge.net/viewvc/vistumbler/VistumblerMDB/'
$data = ''

$UpdateGUI = GUICreate("Updating Vistumbler", 350, 300)
$datalabel = GUICtrlCreateLabel("", 10, 10, 330, 15)
$UpdateEdit = GUICtrlCreateEdit("", 10, 30, 330, 260)

GUISetState(@SW_SHOW)

DirCreate(@ScriptDir & '\temp\')
FileDelete($NewVersionFile)
InetGet($VIEWSVN_ROOT & 'versions.ini', $NewVersionFile)
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
EndIf

$updatemsg = MsgBox(4, 'Done', 'Done. Would you like to load vistumbler?')
If $updatemsg = 6 Then Run(@ScriptDir & '\Vistumbler.exe')

Exit