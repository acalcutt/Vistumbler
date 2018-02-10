#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Icons\icon.ico
#AutoIt3Wrapper_Res_requestedExecutionLevel=requireAdministrator
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
;License Information------------------------------------
;Copyright (C) 2018 Andrew Calcutt
;This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; Version 2 of the License.
;This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
;You should have received a copy of the GNU General Public License along with this program; If not, see <http://www.gnu.org/licenses/gpl-2.0.html>.
;--------------------------------------------------------
;AutoIt Version: v3.3.14.3
$Script_Author = 'Andrew Calcutt'
$Script_Name = 'Vistumbler Update Updater'
$Script_Website = 'http://www.Vistumbler.net'
$Script_Function = 'Updates the vistumbler update.exe file from git based on version.ini'
$version = 'v1'
$origional_date = '2015/03/05'
$last_modified = '2015/03/06'
HttpSetUserAgent($Script_Name & ' ' & $version)
;--------------------------------------------------------
Dim $TmpDir = @TempDir & '\Vistumbler\'
DirCreate($TmpDir)

Dim $Default_settings = @ScriptDir & '\Settings\vistumbler_settings.ini'
Dim $Profile_settings = @AppDataDir & '\Vistumbler\vistumbler_settings.ini'
Dim $PortableMode = IniRead($Default_settings, 'Vistumbler', 'PortableMode', 0)
If $PortableMode = 1 Then
	$settings = $Default_settings
Else
	$settings = $Profile_settings
	If FileExists($Default_settings) And FileExists($settings) = 0 Then FileCopy($Default_settings, $settings, 1)
EndIf

Dim $NewVersionFile = $TmpDir & 'versions.ini'
Dim $CurrentVersionFile = @ScriptDir & '\versions.ini'
Dim $GIT_ROOT = 'https://raw.github.com/acalcutt/Vistumbler/'
Dim $CheckForBetaUpdates = IniRead($settings, 'Vistumbler', 'CheckForBetaUpdates', 0)
If FileExists($Default_settings) Then IniWrite($Default_settings, 'Vistumbler', 'CheckForBetaUpdates', $CheckForBetaUpdates)
If FileExists($Profile_settings) Then IniWrite($Profile_settings, 'Vistumbler', 'CheckForBetaUpdates', $CheckForBetaUpdates)

FileDelete($NewVersionFile)
If $CheckForBetaUpdates = 1 Then
	$get = InetGet($GIT_ROOT & 'beta/VistumblerMDB/versions.ini', $NewVersionFile, 1)
	If $get = 0 Then FileDelete($NewVersionFile)
Else
	$get = InetGet($GIT_ROOT & 'master/VistumblerMDB/versions.ini', $NewVersionFile, 1)
	If $get = 0 Then FileDelete($NewVersionFile)
EndIf

If FileExists($NewVersionFile) Then
	$fv = IniReadSection($NewVersionFile, "FileVersions")
	If Not @error Then
		For $i = 1 To $fv[0][0]
			$filename = $fv[$i][0]
			$version = $fv[$i][1]
			If $filename = 'update.exe' Then
				$sourcefile = $GIT_ROOT & $version & '/VistumblerMDB/' & $filename
				$desttmpfile = $TmpDir & $filename & '.tmp'
				$destfile = @ScriptDir & '\' & $filename
				$get = InetGet($sourcefile, $desttmpfile, 1)
				If $get <> 0 And FileGetSize($desttmpfile) <> 0 Then ;Download Successful
					If FileMove($desttmpfile, $destfile, 9) = 1 Then IniWrite($CurrentVersionFile, "FileVersions", $filename, $version)
				EndIf
				FileDelete($desttmpfile)
			EndIf
		Next
	EndIf
	FileDelete($NewVersionFile)
EndIf

$command = @ScriptDir & '\update.exe'
Run(@ComSpec & ' /c start "" "' & $command & '"')