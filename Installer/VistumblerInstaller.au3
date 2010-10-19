$title = "Vistumbler Installer v1.0"

#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include "UDFs\Zip.au3"

FileInstall ( "installfiles.zip", "installfiles.zip", 1)
FileInstall ( "License.txt", "License.txt", 1)

$licensefile = FileOpen("License.txt", 0)
$licensetxt = FileRead($licensefile)
FileClose($licensefile)

Dim $SourceFile = @ScriptDir & '\installfiles.zip'
Dim $Destination = @ProgramFilesDir & '\Vistumbler\'

;ConsoleWrite($licensetxt & @CRLF)



_LicenseAgreementGui()
Exit


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
	$IO_GUI = GUICreate($title & ' - Install Options', 558, 218)
	$IO_Dest = GUICtrlCreateInput($Destination, 32, 48, 400, 20)
	$Label1 = GUICtrlCreateLabel("Vistumbler Install Location", 32, 24, 126, 17)
	$Checkbox1 = GUICtrlCreateCheckbox("Add Shortcut on Desktop", 32, 80, 321, 15)
	$Checkbox2 = GUICtrlCreateCheckbox("Add Shortcut in Start Menu (All Users)", 32, 100, 225, 15)
	$Checkbox3 = GUICtrlCreateCheckbox("Add Shortcut in Start Menu (Current Users)", 32, 120, 220, 17)
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
				$IO_Dest = GUICtrlRead($IO_Dest)
				GUIDelete($IO_GUI)
				_Install($SourceFile, $IO_Dest)
				ExitLoop
		EndSwitch
	WEnd
EndFunc

Func _Install($source_zip, $dest_dir)
	DirRemove ($dest_dir, 1)
	MsgBox(0, $source_zip, $dest_dir)
	_Zip_UnzipAll($source_zip, $dest_dir, 16)
EndFunc