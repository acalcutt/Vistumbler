#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_icon=icon.ico
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
;License Information------------------------------------
;Copyright (C) 2010 Andrew Calcutt
;This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; Version 2 of the License.
;This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
;You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
;--------------------------------------------------------
;AutoIt Version: v3.3.6.1
$Script_Author = 'Andrew Calcutt'
$Script_Name = 'Vistumbler Installer'
$Script_Website = 'http://www.vistumbler.net'
$Script_Function = 'Zip file based installer for vistumbler.'
$version = 'v1.0'
$Script_Start_Date = '2010/10/18'
$last_modified = '2010/10/19'
;Includes------------------------------------------------
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include "UDFs\Zip.au3"
;--------------------------------------------------------
Dim $TempSourceFiles = @TempDir & '\installfiles.zip'
Dim $TempLicense = @TempDir & '\License.txt'
Dim $TempSettings = @TempDir & '\installsettings.ini'

Dim $Destination = @ProgramFilesDir & '\Vistumbler\'
Dim $StartMenu_AllUsers = @ProgramsCommonDir & '\Vistumbler\'
Dim $StartMenu_CurrentUser = @ProgramsDir & '\Vistumbler\'
Dim $Desktop_AllUsers = @DesktopCommonDir & '\'
Dim $Desktop_CurrentUser = @DesktopDir & '\'

;Install needed files into exe
FileInstall ( "installfiles.zip", $TempSourceFiles, 1)
FileInstall ( "License.txt", $TempLicense, 1)
FileInstall ( "installsettings.ini", $TempSettings, 1)

;Get settings
Dim $ProgramName = IniRead($TempSettings, 'Settings', 'ProgramName', 'Vistumbler')
Dim $ProgramVersion = IniRead($TempSettings, 'Settings', 'ProgramVersion', '')
Dim $ProgramAuthor = IniRead($TempSettings, 'Settings', 'ProgramAuthor', 'Andrew Calcutt')
Dim $title = $ProgramName & ' ' & $ProgramVersion & ' Installer'

;Read in license file
$licensefile = FileOpen("License.txt", 0)
$licensetxt = FileRead($licensefile)
FileClose($licensefile)

;Start Install
_LicenseAgreementGui()

;Clean up temp files and exit
_Exit()


Func _LicenseAgreementGui()
	$LA_GUI = GUICreate('License Agreement - ' & $title, 625, 443)
	$Edit1 = GUICtrlCreateEdit('', 8, 16, 609, 369, BitOr($GUI_SS_DEFAULT_EDIT,$ES_READONLY,$ES_CENTER))
	GUICtrlSetData(-1, $licensetxt)
	$LA_Agree = GUICtrlCreateButton("Agree", 184, 400, 105, 25, $WS_GROUP)
	$LA_Exit = GUICtrlCreateButton("Exit", 304, 400, 105, 25, $WS_GROUP)
	GUISetState(@SW_SHOW)

	While 1
		$nMsg = GUIGetMsg()
		Switch $nMsg
			Case $GUI_EVENT_CLOSE
				GUIDelete($LA_GUI)
				ExitLoop
			Case $LA_Exit
				GUIDelete($LA_GUI)
				ExitLoop
			Case $LA_Agree
				GUIDelete($LA_GUI)
				_InstallOptionsGui()
				ExitLoop
		EndSwitch
	WEnd
EndFunc

Func _InstallOptionsGui()
	$IO_GUI = GUICreate('Install Options - ' & $title, 558, 218)
	$IO_Dest = GUICtrlCreateInput($Destination, 32, 48, 400, 20)
	$Label1 = GUICtrlCreateLabel("Vistumbler Install Location", 32, 24, 126, 17)
	$Checkbox1 = GUICtrlCreateCheckbox("Add Shortcut on Desktop", 32, 80, 321, 15)
	$Checkbox2 = GUICtrlCreateCheckbox("Add Shortcut in Start Menu (All Users)", 32, 100, 225, 15)
	$Checkbox3 = GUICtrlCreateCheckbox("Add Shortcut in Start Menu (Current Users)", 32, 120, 220, 15)
	$Checkbox4 = GUICtrlCreateCheckbox("Remove old vistumbler directories (make sure you have a backup of your scans)", 32, 140, 400, 15)
	$Button1 = GUICtrlCreateButton("Browse", 440, 45, 81, 25, $WS_GROUP)
	$IO_Install = GUICtrlCreateButton("Install", 160, 168, 113, 25, $WS_GROUP)
	$IO_Exit = GUICtrlCreateButton("Exit", 284, 169, 113, 25, $WS_GROUP)
	GUISetState(@SW_SHOW)

	While 1
		$nMsg = GUIGetMsg()
		Switch $nMsg
			Case $GUI_EVENT_CLOSE
				GUIDelete($IO_GUI)
				ExitLoop
			Case $IO_Exit
				GUIDelete($IO_GUI)
				ExitLoop
			Case $IO_Install
				$Destination = GUICtrlRead($IO_Dest)
				GUIDelete($IO_GUI)
				_Install($TempSourceFiles, $Destination)
				ExitLoop
		EndSwitch
	WEnd
EndFunc

Func _Install($source_zip, $dest_dir, $RemOldDir=1, $StartShortcuts=1, $DesktopShortcuts=1)
	If $RemOldDir = 1 Then _RemoveOldFiles()
	_Zip_UnzipAll($source_zip, $dest_dir, 16)
	If @error Then
		If @error = 1 Then
			$err = "zipfldr.dll does not exist."
		ElseIf @error = 2 Then
			$err = "Library not installed."
		ElseIf @error = 3 Then
			$err = "Not a full path."
		ElseIf @error = 4 Then
			$err = "ZIP file does not exist."
		ElseIf @error = 5 Then
			$err = "Failed to create destination (if necessary)."
		ElseIf @error = 6 Then
			$err = "Failed to open destination."
		ElseIf @error = 7 Then
			$err = "Failed to extract file(s)."
		Else
			$err = "Unknown Error"
		EndIf
		Msgbox(0, "Error", $err & " Make sure vistumbler is not running and try again")
	Else
		;Create Start Menu Shortcuts
		If $StartShortcuts = 2 Then
			DirCreate($StartMenu_AllUsers)
			FileCreateShortcut ($dest_dir & 'Vistumbler.exe', $StartMenu_AllUsers & 'Vistumbler.lnk')
		ElseIf $StartShortcuts = 1 Then 
			DirCreate($StartMenu_CurrentUser)
			FileCreateShortcut ($dest_dir & 'Vistumbler.exe', $StartMenu_CurrentUser & 'Vistumbler.lnk')
		EndIf
		;Create Desktop Shortcuts
		If $DesktopShortcuts = 2 Then
			FileDelete ($Desktop_AllUsers & 'Vistumbler.lnk')
			FileCreateShortcut ($dest_dir & 'Vistumbler.exe', $Desktop_AllUsers & 'Vistumbler.lnk')
		ElseIf $DesktopShortcuts = 1 Then 
			FileDelete ($Desktop_CurrentUser & 'Vistumbler.lnk')
			FileCreateShortcut ($dest_dir & 'Vistumbler.exe', $Desktop_CurrentUser & 'Vistumbler.lnk')
		EndIf
		Msgbox(0, "Done", "Install completed succesfully")
	EndIf
EndFunc

Func _RemoveOldFiles()
	DirRemove ($Destination, 1)
	DirRemove ($StartMenu_AllUsers, 1)
	DirRemove ($StartMenu_CurrentUser, 1)
	FileDelete ($Desktop_CurrentUser & 'Vistumbler.lnk')
	FileDelete ($Desktop_AllUsers & 'Vistumbler.lnk')
	MsgBox(0, "Old files removed", "Click OK to continue")
EndFunc

Func _Exit()
	FileDelete($TempSourceFiles)
	FileDelete($TempLicense)
	FileDelete($TempSettings)
	Exit
EndFunc