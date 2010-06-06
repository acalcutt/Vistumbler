#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_icon=Icons\icon.ico
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
;License Information------------------------------------
;Copyright (C) 2010 Andrew Calcutt
;This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; Version 2 of the License.
;This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
;You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
;--------------------------------------------------------
;AutoIt Version: v3.3.6.1 Beta
$Script_Author = 'Andrew Calcutt'
$Script_Start_Date = '07/19/2008'
$Script_Name = 'SayText'
$Script_Website = 'http://www.Vistumbler.net'
$Script_Function = 'Uses Sound files, Microsoft SAPI, or MIDI sounds to say a number from 0 - 100'
$version = 'v2.2'
$last_modified = '11/15/2008'
;--------------------------------------------------------
#include <String.au3>
#include "UDFs\Midiudf.au3"

Dim $SoundDir = @ScriptDir & '\Sounds\'
Dim $say = ''
Dim $midistring = ''
Dim $type = 2
Dim $SayPercent = 0
Dim $Instrument = 0
Dim $MidiWaitTime = 500


;<-- Start Command Line Input -->
For $loop = 1 To $CmdLine[0]
	If StringInStr($CmdLine[$loop], '/s') Then
		$saysplit = StringSplit($CmdLine[$loop], '=')
		$say = $saysplit[2]
	EndIf
	If StringInStr($CmdLine[$loop], '/ms') Then
		$midistringsplit = StringSplit($CmdLine[$loop], '=')
		$midistring = $midistringsplit[2]
	EndIf
	If StringInStr($CmdLine[$loop], '/t') Then
		$typesplit = StringSplit($CmdLine[$loop], '=')
		$type = $typesplit[2]
	EndIf
	If StringInStr($CmdLine[$loop], '/p') Then
		$SayPercent = 1
	EndIf
	If StringInStr($CmdLine[$loop], '/i') Then
		$instumentsplit = StringSplit($CmdLine[$loop], '=')
		$Instrument = $instumentsplit[2]
	EndIf
	If StringInStr($CmdLine[$loop], '/w') Then
		$waitsplit = StringSplit($CmdLine[$loop], '=')
		$MidiWaitTime = $waitsplit[2]
	EndIf
	If StringInStr($CmdLine[$loop], '/?') Then
		MsgBox(0, '', '/s="thing to say"' & @CRLF & @CRLF & '/t=1     Vistumbler Sounds' & @CRLF & '/t=2     Microsoft SAPI' & @CRLF & '/t=3     Midi' & @CRLF & @CRLF & '/i=	Midi Instrument number' & @CRLF & @CRLF & '/w=	Midi Instrument play time' & @CRLF & @CRLF & '/p	say percent')
		Exit
	EndIf
Next
;<-- End Command Line Input -->

If $say <> '' Or $midistring <> '' Then
	If $type = 1 Then
		If StringIsInt($say) = 1 And StringLen($say) <= 3 Then _SpeakSignal($say)
	ElseIf $type = 2 Then
		If $SayPercent = 1 Then $say &= '%'
		_TalkOBJ($say)
	ElseIf $type = 3 Then
		_PlayMidi($Instrument, $say, $MidiWaitTime)
	ElseIf $type = 4 Then
		$midistringarray = StringSplit($midistring, '-')
		For $l = 1 to $midistringarray[0]
			_PlayMidi($Instrument, $midistringarray[$l], $MidiWaitTime)
		Next
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

Func _PlayMidi($Instrument = 0, $Signal = 0, $Sleeptime = 500)
	$PitchOn = ''
	$PitchOff = ''
	;Pick Start/Stop Varialbles based on signal
	If $Signal > 0 And $Signal < 10 Then
		$PitchOn = $A0_NOTEON
		$PitchOff = $A0_NOTEOFF
	ElseIf $Signal >= 10 And $Signal < 15  Then
		$PitchOn = $A0SHARP_NOTEON
		$PitchOff = $A0SHARP_NOTEOFF
	ElseIf $Signal = 15 Then
		$PitchOn = $B0_NOTEON
		$PitchOff = $B0_NOTEOFF
	ElseIf $Signal = 16 Then
		$PitchOn = $C1_NOTEON
		$PitchOff = $C1_NOTEOFF
	ElseIf $Signal = 17 Then
		$PitchOn = $C1SHARP_NOTEON
		$PitchOff = $C1SHARP_NOTEOFF
	ElseIf $Signal = 18 Then
		$PitchOn = $D1_NOTEON
		$PitchOff = $D1_NOTEOFF
	ElseIf $Signal = 19 Then
		$PitchOn = $D1SHARP_NOTEON
		$PitchOff = $D1SHARP_NOTEOFF
	ElseIf $Signal = 20 Then
		$PitchOn = $E1_NOTEON
		$PitchOff = $E1_NOTEOFF
	ElseIf $Signal = 21 Then
		$PitchOn = $F1_NOTEON
		$PitchOff = $F1_NOTEOFF
	ElseIf $Signal = 22 Then
		$PitchOn = $F1SHARP_NOTEON
		$PitchOff = $F1SHARP_NOTEOFF
	ElseIf $Signal = 23 Then
		$PitchOn = $G1_NOTEON
		$PitchOff = $G1_NOTEOFF
	ElseIf $Signal = 24 Then
		$PitchOn = $G1SHARP_NOTEON
		$PitchOff = $G1SHARP_NOTEOFF
	ElseIf $Signal = 25 Then
		$PitchOn = $A1_NOTEON
		$PitchOff = $A1_NOTEOFF
	ElseIf $Signal = 26 Then
		$PitchOn = $A1SHARP_NOTEON
		$PitchOff = $A1SHARP_NOTEOFF
	ElseIf $Signal = 27 Then
		$PitchOn = $B1_NOTEON
		$PitchOff = $B1_NOTEOFF
	ElseIf $Signal = 28 Then
		$PitchOn = $C2_NOTEON
		$PitchOff = $C2_NOTEOFF
	ElseIf $Signal = 29 Then
		$PitchOn = $C2SHARP_NOTEON
		$PitchOff = $C2SHARP_NOTEOFF
	ElseIf $Signal = 30 Then
		$PitchOn = $D2_NOTEON
		$PitchOff = $D2_NOTEOFF
	ElseIf $Signal = 31 Then
		$PitchOn = $D2SHARP_NOTEON
		$PitchOff = $D2SHARP_NOTEOFF
	ElseIf $Signal = 32 Then
		$PitchOn = $E2_NOTEON
		$PitchOff = $E2_NOTEOFF
	ElseIf $Signal = 33 Then
		$PitchOn = $F2_NOTEON
		$PitchOff = $F2_NOTEOFF
	ElseIf $Signal = 34 Then
		$PitchOn = $F2SHARP_NOTEON
		$PitchOff = $F2SHARP_NOTEOFF
	ElseIf $Signal = 35 Then
		$PitchOn = $G2_NOTEON
		$PitchOff = $G2_NOTEOFF
	ElseIf $Signal = 36 Then
		$PitchOn = $G2SHARP_NOTEON
		$PitchOff = $G2SHARP_NOTEOFF
	ElseIf $Signal = 37 Then
		$PitchOn = $A2_NOTEON
		$PitchOff = $A2_NOTEOFF
	ElseIf $Signal = 38 Then
		$PitchOn = $A2SHARP_NOTEON
		$PitchOff = $A2SHARP_NOTEOFF
	ElseIf $Signal = 39 Then
		$PitchOn = $B2_NOTEON
		$PitchOff = $B2_NOTEOFF
	ElseIf $Signal = 40 Then
		$PitchOn = $C3_NOTEON
		$PitchOff = $C3_NOTEOFF
	ElseIf $Signal = 41 Then
		$PitchOn = $C3SHARP_NOTEON
		$PitchOff = $C3SHARP_NOTEOFF
	ElseIf $Signal = 42 Then
		$PitchOn = $D3_NOTEON
		$PitchOff = $D3_NOTEOFF
	ElseIf $Signal = 43 Then
		$PitchOn = $D3SHARP_NOTEON
		$PitchOff = $D3SHARP_NOTEOFF
	ElseIf $Signal = 44 Then
		$PitchOn = $E3_NOTEON
		$PitchOff = $E3_NOTEOFF
	ElseIf $Signal = 45 Then
		$PitchOn = $F3_NOTEON
		$PitchOff = $F3_NOTEOFF
	ElseIf $Signal = 46 Then
		$PitchOn = $F3SHARP_NOTEON
		$PitchOff = $F3SHARP_NOTEOFF
	ElseIf $Signal = 47 Then
		$PitchOn = $G3_NOTEON
		$PitchOff = $G3_NOTEOFF
	ElseIf $Signal = 48 Then
		$PitchOn = $G3SHARP_NOTEON
		$PitchOff = $G3SHARP_NOTEOFF
	ElseIf $Signal = 49 Then
		$PitchOn = $A3_NOTEON
		$PitchOff = $A3_NOTEOFF
	ElseIf $Signal = 50 Then
		$PitchOn = $A3SHARP_NOTEON
		$PitchOff = $A3SHARP_NOTEOFF
	ElseIf $Signal = 51 Then
		$PitchOn = $B3_NOTEON
		$PitchOff = $B3_NOTEOFF
	ElseIf $Signal = 52 Then
		$PitchOn = $C4_NOTEON
		$PitchOff = $C4_NOTEOFF
	ElseIf $Signal = 53 Then
		$PitchOn = $C4SHARP_NOTEON
		$PitchOff = $C4SHARP_NOTEOFF
	ElseIf $Signal = 54 Then
		$PitchOn = $D4_NOTEON
		$PitchOff = $D4_NOTEOFF
	ElseIf $Signal = 55 Then
		$PitchOn = $D4SHARP_NOTEON
		$PitchOff = $D4SHARP_NOTEOFF
	ElseIf $Signal = 56 Then
		$PitchOn = $E4_NOTEON
		$PitchOff = $E4_NOTEOFF
	ElseIf $Signal = 57 Then
		$PitchOn = $F4_NOTEON
		$PitchOff = $F4_NOTEOFF
	ElseIf $Signal = 58 Then
		$PitchOn = $F4SHARP_NOTEON
		$PitchOff = $F4SHARP_NOTEOFF
	ElseIf $Signal = 59 Then
		$PitchOn = $G4_NOTEON
		$PitchOff = $G4_NOTEOFF
	ElseIf $Signal = 60 Then
		$PitchOn = $G4SHARP_NOTEON
		$PitchOff = $G4SHARP_NOTEOFF
	ElseIf $Signal = 61 Then
		$PitchOn = $A4_NOTEON
		$PitchOff = $A4_NOTEOFF
	ElseIf $Signal = 62 Then
		$PitchOn = $A4SHARP_NOTEON
		$PitchOff = $A4SHARP_NOTEOFF
	ElseIf $Signal = 63 Then
		$PitchOn = $B4_NOTEON
		$PitchOff = $B4_NOTEOFF
	ElseIf $Signal = 64 Then
		$PitchOn = $C5_NOTEON
		$PitchOff = $C5_NOTEOFF
	ElseIf $Signal = 65 Then
		$PitchOn = $C5SHARP_NOTEON
		$PitchOff = $C5SHARP_NOTEOFF
	ElseIf $Signal = 66 Then
		$PitchOn = $D5_NOTEON
		$PitchOff = $D5_NOTEOFF
	ElseIf $Signal = 67 Then
		$PitchOn = $D5SHARP_NOTEON
		$PitchOff = $D5SHARP_NOTEOFF
	ElseIf $Signal = 68 Then
		$PitchOn = $E5_NOTEON
		$PitchOff = $E5_NOTEOFF
	ElseIf $Signal = 69 Then
		$PitchOn = $F5_NOTEON
		$PitchOff = $F5_NOTEOFF
	ElseIf $Signal = 70 Then
		$PitchOn = $F5SHARP_NOTEON
		$PitchOff = $F5SHARP_NOTEOFF
	ElseIf $Signal = 71 Then
		$PitchOn = $G5_NOTEON
		$PitchOff = $G5_NOTEOFF
	ElseIf $Signal = 72 Then
		$PitchOn = $G5SHARP_NOTEON
		$PitchOff = $G5SHARP_NOTEOFF
	ElseIf $Signal = 73 Then
		$PitchOn = $A5_NOTEON
		$PitchOff = $A5_NOTEOFF
	ElseIf $Signal = 74 Then
		$PitchOn = $A5SHARP_NOTEON
		$PitchOff = $A5SHARP_NOTEOFF
	ElseIf $Signal = 75 Then
		$PitchOn = $B5_NOTEON
		$PitchOff = $B5_NOTEOFF
	ElseIf $Signal = 76 Then
		$PitchOn = $C6_NOTEON
		$PitchOff = $C6_NOTEOFF
	ElseIf $Signal = 77 Then
		$PitchOn = $C6SHARP_NOTEON
		$PitchOff = $C6SHARP_NOTEOFF
	ElseIf $Signal = 78 Then
		$PitchOn = $D6_NOTEON
		$PitchOff = $D6_NOTEOFF
	ElseIf $Signal = 79 Then
		$PitchOn = $D6SHARP_NOTEON
		$PitchOff = $D6SHARP_NOTEOFF
	ElseIf $Signal = 80 Then
		$PitchOn = $E6_NOTEON
		$PitchOff = $E6_NOTEOFF
	ElseIf $Signal = 81 Then
		$PitchOn = $F6_NOTEON
		$PitchOff = $F6_NOTEOFF
	ElseIf $Signal = 82 Then
		$PitchOn = $F6SHARP_NOTEON
		$PitchOff = $F6SHARP_NOTEOFF
	ElseIf $Signal = 83 Then
		$PitchOn = $G6_NOTEON
		$PitchOff = $G6_NOTEOFF
	ElseIf $Signal = 84 Then
		$PitchOn = $G6SHARP_NOTEON
		$PitchOff = $G6SHARP_NOTEOFF
	ElseIf $Signal = 85 Then
		$PitchOn = $A6_NOTEON
		$PitchOff = $A6_NOTEOFF
	ElseIf $Signal = 86 Then
		$PitchOn = $A6SHARP_NOTEON
		$PitchOff = $A6SHARP_NOTEOFF
	ElseIf $Signal = 87 Then
		$PitchOn = $B6_NOTEON
		$PitchOff = $B6_NOTEOFF
	ElseIf $Signal = 88 Then
		$PitchOn = $C7_NOTEON
		$PitchOff = $C7_NOTEOFF
	ElseIf $Signal = 89 Then
		$PitchOn = $C7SHARP_NOTEON
		$PitchOff = $C7SHARP_NOTEOFF
	ElseIf $Signal = 90 Then
		$PitchOn = $D7_NOTEON
		$PitchOff = $D7_NOTEOFF
	ElseIf $Signal = 91 Then
		$PitchOn = $D7SHARP_NOTEON
		$PitchOff = $D7SHARP_NOTEOFF
	ElseIf $Signal = 92 Then
		$PitchOn = $E7_NOTEON
		$PitchOff = $E7_NOTEOFF
	ElseIf $Signal = 93 Then
		$PitchOn = $F7_NOTEON
		$PitchOff = $F7_NOTEOFF
	ElseIf $Signal = 94 Then
		$PitchOn = $F7SHARP_NOTEON
		$PitchOff = $F7SHARP_NOTEOFF
	ElseIf $Signal = 95 Then
		$PitchOn = $G7_NOTEON
		$PitchOff = $G7_NOTEOFF
	ElseIf $Signal = 96 Then
		$PitchOn = $G7SHARP_NOTEON
		$PitchOff = $G7SHARP_NOTEOFF
	ElseIf $Signal = 97 Then
		$PitchOn = $A7_NOTEON
		$PitchOff = $A7_NOTEOFF
	ElseIf $Signal = 98 Then
		$PitchOn = $A7SHARP_NOTEON
		$PitchOff = $A7SHARP_NOTEOFF
	ElseIf $Signal = 99 Then
		$PitchOn = $B7_NOTEON
		$PitchOff = $B7_NOTEOFF
	ElseIf $Signal = 100 Then
		$PitchOn = $C8_NOTEON
		$PitchOff = $C8_NOTEOFF
	EndIf
	If $PitchOn <> '' And $PitchOff <> '' Then
		$open = _MidiOutOpen ()
		_MidiOutShortMsg ($open, 256 * $Instrument + 192) ;Select Instrument
		_MidiOutShortMsg ($open, $PitchOn);Start playing Instrument
		Sleep($Sleeptime)
		_MidiOutShortMsg ($open, $PitchOff);Stop playing Instrument
		_MidiOutClose ($open)
	EndIf
EndFunc