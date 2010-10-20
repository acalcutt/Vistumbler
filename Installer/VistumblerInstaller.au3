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
	$LA_GUI = GUICreate($title & ' - License Agreement', 625, 443)
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
$IO_GUI = GUICreate($title & ' - Install Options', 513, 259)
$IO_Dest = GUICtrlCreateInput($Destination, 16, 32, 385, 21)
$Browse = GUICtrlCreateButton("Browse", 408, 30, 89, 25, $WS_GROUP)
GUICtrlCreateLabel("Vistumbler Install Location", 16, 12, 126, 15)
GUICtrlCreateGroup("Options", 8, 64, 497, 145)
GUICtrlCreateGroup("Create start menu shortcuts", 16, 88, 230, 89)
$SMS_AllUsers = GUICtrlCreateRadio("All Users", 32, 144, 100, 17)
$SMS_CurrentUser = GUICtrlCreateRadio("Current User", 32, 128, 100, 17)
$SMS_None = GUICtrlCreateRadio("None", 32, 112, 100, 17)
GUICtrlSetState($SMS_CurrentUser, $GUI_CHECKED)
GUICtrlCreateGroup("Create desktop shortcuts", 266, 88, 230, 89)
$DS_AllUsers = GUICtrlCreateRadio("All Users", 282, 144, 100, 17)
$DS_CurrentUser  = GUICtrlCreateRadio("Current User", 282, 128, 100, 17)
$DS_None = GUICtrlCreateRadio("None", 282, 112, 100, 17)
GUICtrlSetState($DS_CurrentUser, $GUI_CHECKED)
$RVD_Check = GUICtrlCreateCheckbox("Remove old vistumbler directories (make sure you have a backup of your scans)", 16, 184, 481, 17)
GUICtrlSetState($RVD_Check, $GUI_CHECKED)
$IO_Install = GUICtrlCreateButton("Install", 104, 220, 130, 25, $WS_GROUP)
$IO_Exit = GUICtrlCreateButton("Exit", 272, 220, 130, 25, $WS_GROUP)
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
			Case $Browse
				$instaldir = FileSelectFolder("Choose a folder.", "", 1, GUICtrlRead($IO_Dest))
				If Not @error Then GUICtrlSetData($IO_Dest, $instaldir)
			Case $IO_Install
				Dim $SMS=0, $DS=0, $RVD=0
				;get install folder
				$Destination = GUICtrlRead($IO_Dest)
				;Get start menu shortcut type
				If GUICtrlRead($SMS_AllUsers) = 1 Then
					$SMS = 2
				ElseIf GUICtrlRead($SMS_CurrentUser) = 1 Then
					$SMS = 1
				EndIf
				;Get desktop shortcut type
				If GUICtrlRead($DS_AllUsers) = 1 Then
					$DS = 2
				ElseIf GUICtrlRead($DS_CurrentUser) = 1 Then
					$DS = 1
				EndIf
				;Set remove directories flag
				If GUICtrlRead($RVD_Check) = 1 Then $RVD=1
				;Close Install Options Window
				GUIDelete($IO_GUI)
				;Install files from zip to selected dir
				_Install($TempSourceFiles, $Destination, $RVD, $SMS, $DS)
				ExitLoop
		EndSwitch
	WEnd
EndFunc

Func _Install($source_zip, $dest_dir, $RemOldDir=1, $StartShortcuts=1, $DesktopShortcuts=1)
	ConsoleWrite('$StartShortcuts:' & $StartShortcuts & ' - ' & '$DesktopShortcuts:' & $DesktopShortcuts & @CRLF)
	If $RemOldDir = 1 Then _RemoveOldFiles()
	$Unzip = _Zip_UnzipAll($source_zip, $dest_dir, 272)
	If $Unzip = 0 Then
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