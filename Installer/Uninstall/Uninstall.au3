#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\..\VistumblerMDB\Icons\icon.ico
#AutoIt3Wrapper_Res_requestedExecutionLevel=requireAdministrator
#AutoIt3Wrapper_Run_Tidy=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

$TempUninstallEXE = @TempDir & '\vi_uninstall.exe'
FileInstall("vi_uninstall.exe", $TempUninstallEXE, 1)
Run($TempUninstallEXE)
Exit

