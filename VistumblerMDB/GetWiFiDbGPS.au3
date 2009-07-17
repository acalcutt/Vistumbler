#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_icon=Icons\icon.ico
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
;License Information------------------------------------
;Copyright (C) 2009 Andrew Calcutt
;This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; Version 2 of the License.
;This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
;You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
;--------------------------------------------------------
;AutoIt Version: v3.3.0.0
$Script_Author = 'Andrew Calcutt'
$Script_Name = 'Vistumbler Save'
$Script_Website = 'http://www.Vistumbler.net'
$Script_Function = 'Pulls GPS data from WiFiDB and writes it to a file'
$last_modified = '2009/07/16'
;--------------------------------------------------------
#include <INet.au3>
#Include <String.au3>
Dim $filename
Dim $url

For $loop = 1 To $CmdLine[0]
	If StringInStr($CmdLine[$loop], '/f') Then
		$filesplit = StringSplit($CmdLine[$loop], "=")
		If $filesplit[0] = 2 Then $filename = $filesplit[2]
	EndIf
	If StringInStr($CmdLine[$loop], '/u') Then
		$filesplit = StringSplit($CmdLine[$loop], "=")
		If $filesplit[0] = 2 Then $url = _StringEncrypt(0, $filesplit[2], '0', 1)
	EndIf
Next

If $filename <> '' And $url <> '' Then
	FileDelete($filename)
	$webpagesource = _INetGetSource($url)
	If Not @error Then
		FileWrite($filename, $webpagesource)
	EndIf
EndIf

Exit

