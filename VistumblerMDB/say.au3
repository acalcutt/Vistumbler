#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_icon=icon.ico
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
;License Information------------------------------------
;Copyright (C) 2008 Andrew Calcutt
;This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; Version 2 of the License.
;This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
;You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
;--------------------------------------------------------
;AutoIt Version: v3.2.13.3 Beta
$Script_Author = 'Andrew Calcutt'
$Script_Start_Date = '07/19/2008'
$Script_Name = 'SayText'
$Script_Website = 'http://www.TechIdiots.net'
$Script_Function = 'Uses Sound files to say a number from 0 - 100 or Uses Microsoft SAPI to say anything'
$version = 'v1.0'
$last_modified = '07/19/2008'
;--------------------------------------------------------
#include <String.au3>
Dim $SoundDir = @ScriptDir & '\Sounds\'
Dim $say = ''
Dim $type = 2
Dim $SayPercent

;<-- Start Command Line Input -->
For $loop = 1 To $CmdLine[0]
	If StringInStr($CmdLine[$loop], '/s') Then ;Set ini file
		$saysplit = StringSplit($CmdLine[$loop], '=')
		$say = $saysplit[2]
	EndIf
	If StringInStr($CmdLine[$loop], '/t') Then
		$typesplit = StringSplit($CmdLine[$loop], '=')
		$type = $typesplit[2]
	EndIf
	If StringInStr($CmdLine[$loop], '/?') Then
		MsgBox(0, '', '/s="thing to say"' & @CRLF & @CRLF & '/t=1     Vistumbler Sounds' & @CRLF & '/t=2     Microsoft SAPI')
		Exit
	EndIf
Next
;<-- End Command Line Input -->

If $say <> '' Then
	If $type = 1 Then
		If StringTrimLeft($say, StringLen($say) - 1) = '%' Then
			$sayvis = StringTrimRight($say, 1)
			$SayPercent = 1
		Else
			$sayvis = $say
			$SayPercent = 0
		EndIf
		If StringIsInt($sayvis) = 1 And StringLen($sayvis) <= 3 Then _SpeakSignal($sayvis)
	ElseIf $type = 2 Then
		_TalkOBJ($say)
	EndIf
EndIf

Exit
		
		
Func _TalkOBJ($s_text)
	Local $o_speech = ObjCreate("SAPI.SpVoice")
	$o_speech.Speak($s_text)
	$o_speech = ""
EndFunc   ;==>_TalkOBJ		
		
Func _SpeakSignal($SpeakNum);Says then signal given
	$SpeakSplit = StringSplit(_StringReverse($SpeakNum), '')
	$OnesPlayed = 0
	If $SpeakSplit[0] = 3 Then
		If $SpeakSplit[3] = 1 Then SoundPlay($SoundDir & 'one.wav', 1)
		SoundPlay($SoundDir & 'hundred.wav', 1)
	EndIf
	If $SpeakSplit[0] >= 2 Then
		If $SpeakSplit[2] = 1 Then
			If $SpeakSplit[2] & $SpeakSplit[1] = 10 Then
				SoundPlay($SoundDir & 'ten.wav', 1)
			ElseIf $SpeakSplit[2] & $SpeakSplit[1] = 11 Then
				SoundPlay($SoundDir & 'eleven.wav', 1)
			ElseIf $SpeakSplit[2] & $SpeakSplit[1] = 12 Then
				SoundPlay($SoundDir & 'twelve.wav', 1)
			ElseIf $SpeakSplit[2] & $SpeakSplit[1] = 13 Then
				SoundPlay($SoundDir & 'thirteen.wav', 1)
			ElseIf $SpeakSplit[2] & $SpeakSplit[1] = 14 Then
				SoundPlay($SoundDir & 'fourteen.wav', 1)
			ElseIf $SpeakSplit[2] & $SpeakSplit[1] = 15 Then
				SoundPlay($SoundDir & 'fifteen.wav', 1)
			ElseIf $SpeakSplit[2] & $SpeakSplit[1] = 16 Then
				SoundPlay($SoundDir & 'sixteen.wav', 1)
			ElseIf $SpeakSplit[2] & $SpeakSplit[1] = 17 Then
				SoundPlay($SoundDir & 'seventeen.wav', 1)
			ElseIf $SpeakSplit[2] & $SpeakSplit[1] = 18 Then
				SoundPlay($SoundDir & 'eightteen.wav', 1)
			ElseIf $SpeakSplit[2] & $SpeakSplit[1] = 19 Then
				SoundPlay($SoundDir & 'nineteen.wav', 1)
			EndIf
			$OnesPlayed = 1
		ElseIf $SpeakSplit[2] = 2 Then
			SoundPlay($SoundDir & 'twenty.wav', 1)
		ElseIf $SpeakSplit[2] = 3 Then
			SoundPlay($SoundDir & 'thirty.wav', 1)
		ElseIf $SpeakSplit[2] = 4 Then
			SoundPlay($SoundDir & 'fourty.wav', 1)
		ElseIf $SpeakSplit[2] = 5 Then
			SoundPlay($SoundDir & 'fifty.wav', 1)
		ElseIf $SpeakSplit[2] = 6 Then
			SoundPlay($SoundDir & 'sixty.wav', 1)
		ElseIf $SpeakSplit[2] = 7 Then
			SoundPlay($SoundDir & 'seventy.wav', 1)
		ElseIf $SpeakSplit[2] = 8 Then
			SoundPlay($SoundDir & 'eighty.wav', 1)
		ElseIf $SpeakSplit[2] = 9 Then
			SoundPlay($SoundDir & 'ninety.wav', 1)
		EndIf
	EndIf
	If $SpeakSplit[0] >= 1 Then
		If $OnesPlayed = 0 Then
			If $SpeakSplit[1] = 0 And $SpeakSplit[0] = 1 Then
				SoundPlay($SoundDir & 'zero.wav', 1)
			ElseIf $SpeakSplit[1] = 1 Then
				SoundPlay($SoundDir & 'one.wav', 1)
			ElseIf $SpeakSplit[1] = 2 Then
				SoundPlay($SoundDir & 'two.wav', 1)
			ElseIf $SpeakSplit[1] = 3 Then
				SoundPlay($SoundDir & 'three.wav', 1)
			ElseIf $SpeakSplit[1] = 4 Then
				SoundPlay($SoundDir & 'four.wav', 1)
			ElseIf $SpeakSplit[1] = 5 Then
				SoundPlay($SoundDir & 'five.wav', 1)
			ElseIf $SpeakSplit[1] = 6 Then
				SoundPlay($SoundDir & 'six.wav', 1)
			ElseIf $SpeakSplit[1] = 7 Then
				SoundPlay($SoundDir & 'seven.wav', 1)
			ElseIf $SpeakSplit[1] = 8 Then
				SoundPlay($SoundDir & 'eight.wav', 1)
			ElseIf $SpeakSplit[1] = 9 Then
				SoundPlay($SoundDir & 'nine.wav', 1)
			EndIf
		EndIf
	EndIf
	If $SayPercent = 1 Then SoundPlay($SoundDir & 'percent.wav', 1)
EndFunc   ;==>_SpeakSignal		