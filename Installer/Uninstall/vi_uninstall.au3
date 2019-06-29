#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\icon.ico
#AutoIt3Wrapper_Res_requestedExecutionLevel=requireAdministrator
#AutoIt3Wrapper_Run_Tidy=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

Dim $InstallLocation = RegRead("HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Vistumbler", "InstallLocation")
Dim $StartMenu_AllUsers = @ProgramsCommonDir & '\Vistumbler\'
Dim $StartMenu_CurrentUser = @ProgramsDir & '\Vistumbler\'
Dim $Desktop_AllUsers = @DesktopCommonDir & '\Vistumbler.lnk'
Dim $Desktop_CurrentUser = @DesktopDir & '\Vistumbler.lnk'

;Delete Vistumbler files and folders
If FileExists($InstallLocation) Then DirRemove($InstallLocation, 1)
If FileExists($StartMenu_AllUsers) Then DirRemove($StartMenu_AllUsers, 1)
If FileExists($StartMenu_CurrentUser) Then DirRemove($StartMenu_CurrentUser, 1)
If FileExists($Desktop_AllUsers) Then FileDelete($Desktop_AllUsers)
If FileExists($Desktop_CurrentUser) Then FileDelete($Desktop_CurrentUser)

;Delete File Associations
RegDelete("HKCR\.vsz")
RegDelete("HKCR\.vs1")
RegDelete("HKCR\Vistumbler")

;Delete Uninstall Information
RegDelete("HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Vistumbler")

_SelfDelete() ;delete current exe
Exit

Func _SelfDelete($iDelay = 0)
	If StringInStr(@ScriptName, ".au3") = 0 Then
		Local $sCmdFile
		FileDelete(@TempDir & "\scratch.bat")
		$sCmdFile = 'ping -n ' & $iDelay & '127.0.0.1 > nul' & @CRLF _
				 & ':loop' & @CRLF _
				 & 'del "' & @ScriptFullPath & '"' & @CRLF _
				 & 'if exist "' & @ScriptFullPath & '" goto loop' & @CRLF _
				 & 'del ' & @TempDir & '\scratch.bat'
		FileWrite(@TempDir & "\scratch.bat", $sCmdFile)
		Run(@TempDir & "\scratch.bat", @TempDir, @SW_HIDE)
	EndIf
EndFunc   ;==>_SelfDelete
