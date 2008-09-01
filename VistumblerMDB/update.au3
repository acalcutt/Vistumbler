#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Version=Beta
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#Include <Array.au3>

$CurrentVersionFile = @ScriptDir & '\versions.ini'
$NewVersionFile = @ScriptDir & '\temp\versions.ini'
$SVN_ROOT = 'http://vistumbler.svn.sourceforge.net/svnroot/vistumbler/VistumblerMDB/'
$VIEWSVN_ROOT = 'http://vistumbler.svn.sourceforge.net/viewvc/vistumbler/VistumblerMDB/'
$data = ''

$UpdateGUI = GUICreate("Updating Vistumbler", 300, 300)
$UpdateEdit = GUICtrlCreateEdit("", 8, 8, 280, 280)

GUISetState(@SW_SHOW)

DirCreate(@ScriptDir & '\temp\')
FileDelete($NewVersionFile)
InetGet($SVN_ROOT & 'versions.ini', $NewVersionFile)
If FileExists($NewVersionFile) Then
	$fv = IniReadSection($NewVersionFile, "FileVersions")
	If Not @error Then 
		For $i = 1 To $fv[0][0]
			$filename = $fv[$i][0]
			$filename_web = StringReplace($filename, '\', '/')
			$version = $fv[$i][1]
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
				$getfile = InetGet($VIEWSVN_ROOT & $filename_web & '?revision=' & $version, @ScriptDir & '\' & $filename)
				If $getfile = 1 Then
					IniWrite($CurrentVersionFile, "FileVersions", $filename, $version)
					$data = 'New File:' & $filename & @CRLF & $data
					GUICtrlSetData($UpdateEdit, $data)
					;ConsoleWrite('New File:' & $filename & @CRLF)
				Else
					$data = 'Error Downloading New File:' & $filename & @CRLF & $data
					GUICtrlSetData($UpdateEdit, $data)
					;ConsoleWrite('Error Downloading New File:' & $filename & @CRLF)
				EndIf
			Else
				$data = 'No Change In File:' & $filename & @CRLF & $data
				GUICtrlSetData($UpdateEdit, $data)
				;ConsoleWrite('No Change In File:' & $filename & @CRLF)
			EndIf
		Next
	EndIf
EndIf

$updatemsg = MsgBox(4, 'Done', 'Done. Would you like to load vistumbler?')
If $updatemsg = 6 Then Run(@ScriptDir & '\Vistumbler.exe')

Exit