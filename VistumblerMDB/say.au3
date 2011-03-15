#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_icon=Icons\icon.ico
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
;License Information------------------------------------
;Copyright (C) 2011 Andrew Calcutt
;This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; Version 2 of the License.
;This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
;You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
;--------------------------------------------------------
;AutoIt Version: v3.3.6.1
$Script_Author = 'Andrew Calcutt'
$Script_Start_Date = '07/19/2008'
$Script_Name = 'SayText'
$Script_Website = 'http://www.Vistumbler.net'
$Script_Function = 'Uses Sound files, Microsoft SAPI, or MIDI sounds to say a number from 0 - 100'
$version = 'v4'
$last_modified = '2011/03/14'
;--------------------------------------------------------
#include <String.au3>
#include "UDFs\Midiudf.au3"

Dim $SoundDir = @ScriptDir & '\Sounds\'
Dim $SettingsDir = @ScriptDir & '\Settings\'
Dim $settings = $SettingsDir & 'vistumbler_settings.ini'
Dim $new_AP_sound = IniRead($settings, 'Sound', 'NewAP_Sound', 'new_ap.wav')
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
		For $l = 1 To $midistringarray[0]
			_PlayMidi($Instrument, $midistringarray[$l], $MidiWaitTime)
		Next
	ElseIf $type = 5 Then
		_SigBasedSound($say)
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
		$PitchOn = $A0_ON
		$PitchOff = $A0_OFF
	ElseIf $Signal >= 10 And $Signal < 15 Then
		$PitchOn = $A0SHARP_ON
		$PitchOff = $A0SHARP_OFF
	ElseIf $Signal = 15 Then
		$PitchOn = $B0_ON
		$PitchOff = $B0_OFF
	ElseIf $Signal = 16 Then
		$PitchOn = $C1_ON
		$PitchOff = $C1_OFF
	ElseIf $Signal = 17 Then
		$PitchOn = $C1SHARP_ON
		$PitchOff = $C1SHARP_OFF
	ElseIf $Signal = 18 Then
		$PitchOn = $D1_ON
		$PitchOff = $D1_OFF
	ElseIf $Signal = 19 Then
		$PitchOn = $D1SHARP_ON
		$PitchOff = $D1SHARP_OFF
	ElseIf $Signal = 20 Then
		$PitchOn = $E1_ON
		$PitchOff = $E1_OFF
	ElseIf $Signal = 21 Then
		$PitchOn = $F1_ON
		$PitchOff = $F1_OFF
	ElseIf $Signal = 22 Then
		$PitchOn = $F1SHARP_ON
		$PitchOff = $F1SHARP_OFF
	ElseIf $Signal = 23 Then
		$PitchOn = $G1_ON
		$PitchOff = $G1_OFF
	ElseIf $Signal = 24 Then
		$PitchOn = $G1SHARP_ON
		$PitchOff = $G1SHARP_OFF
	ElseIf $Signal = 25 Then
		$PitchOn = $A1_ON
		$PitchOff = $A1_OFF
	ElseIf $Signal = 26 Then
		$PitchOn = $A1SHARP_ON
		$PitchOff = $A1SHARP_OFF
	ElseIf $Signal = 27 Then
		$PitchOn = $B1_ON
		$PitchOff = $B1_OFF
	ElseIf $Signal = 28 Then
		$PitchOn = $C2_ON
		$PitchOff = $C2_OFF
	ElseIf $Signal = 29 Then
		$PitchOn = $C2SHARP_ON
		$PitchOff = $C2SHARP_OFF
	ElseIf $Signal = 30 Then
		$PitchOn = $D2_ON
		$PitchOff = $D2_OFF
	ElseIf $Signal = 31 Then
		$PitchOn = $D2SHARP_ON
		$PitchOff = $D2SHARP_OFF
	ElseIf $Signal = 32 Then
		$PitchOn = $E2_ON
		$PitchOff = $E2_OFF
	ElseIf $Signal = 33 Then
		$PitchOn = $F2_ON
		$PitchOff = $F2_OFF
	ElseIf $Signal = 34 Then
		$PitchOn = $F2SHARP_ON
		$PitchOff = $F2SHARP_OFF
	ElseIf $Signal = 35 Then
		$PitchOn = $G2_ON
		$PitchOff = $G2_OFF
	ElseIf $Signal = 36 Then
		$PitchOn = $G2SHARP_ON
		$PitchOff = $G2SHARP_OFF
	ElseIf $Signal = 37 Then
		$PitchOn = $A2_ON
		$PitchOff = $A2_OFF
	ElseIf $Signal = 38 Then
		$PitchOn = $A2SHARP_ON
		$PitchOff = $A2SHARP_OFF
	ElseIf $Signal = 39 Then
		$PitchOn = $B2_ON
		$PitchOff = $B2_OFF
	ElseIf $Signal = 40 Then
		$PitchOn = $C3_ON
		$PitchOff = $C3_OFF
	ElseIf $Signal = 41 Then
		$PitchOn = $C3SHARP_ON
		$PitchOff = $C3SHARP_OFF
	ElseIf $Signal = 42 Then
		$PitchOn = $D3_ON
		$PitchOff = $D3_OFF
	ElseIf $Signal = 43 Then
		$PitchOn = $D3SHARP_ON
		$PitchOff = $D3SHARP_OFF
	ElseIf $Signal = 44 Then
		$PitchOn = $E3_ON
		$PitchOff = $E3_OFF
	ElseIf $Signal = 45 Then
		$PitchOn = $F3_ON
		$PitchOff = $F3_OFF
	ElseIf $Signal = 46 Then
		$PitchOn = $F3SHARP_ON
		$PitchOff = $F3SHARP_OFF
	ElseIf $Signal = 47 Then
		$PitchOn = $G3_ON
		$PitchOff = $G3_OFF
	ElseIf $Signal = 48 Then
		$PitchOn = $G3SHARP_ON
		$PitchOff = $G3SHARP_OFF
	ElseIf $Signal = 49 Then
		$PitchOn = $A3_ON
		$PitchOff = $A3_OFF
	ElseIf $Signal = 50 Then
		$PitchOn = $A3SHARP_ON
		$PitchOff = $A3SHARP_OFF
	ElseIf $Signal = 51 Then
		$PitchOn = $B3_ON
		$PitchOff = $B3_OFF
	ElseIf $Signal = 52 Then
		$PitchOn = $C4_ON
		$PitchOff = $C4_OFF
	ElseIf $Signal = 53 Then
		$PitchOn = $C4SHARP_ON
		$PitchOff = $C4SHARP_OFF
	ElseIf $Signal = 54 Then
		$PitchOn = $D4_ON
		$PitchOff = $D4_OFF
	ElseIf $Signal = 55 Then
		$PitchOn = $D4SHARP_ON
		$PitchOff = $D4SHARP_OFF
	ElseIf $Signal = 56 Then
		$PitchOn = $E4_ON
		$PitchOff = $E4_OFF
	ElseIf $Signal = 57 Then
		$PitchOn = $F4_ON
		$PitchOff = $F4_OFF
	ElseIf $Signal = 58 Then
		$PitchOn = $F4SHARP_ON
		$PitchOff = $F4SHARP_OFF
	ElseIf $Signal = 59 Then
		$PitchOn = $G4_ON
		$PitchOff = $G4_OFF
	ElseIf $Signal = 60 Then
		$PitchOn = $G4SHARP_ON
		$PitchOff = $G4SHARP_OFF
	ElseIf $Signal = 61 Then
		$PitchOn = $A4_ON
		$PitchOff = $A4_OFF
	ElseIf $Signal = 62 Then
		$PitchOn = $A4SHARP_ON
		$PitchOff = $A4SHARP_OFF
	ElseIf $Signal = 63 Then
		$PitchOn = $B4_ON
		$PitchOff = $B4_OFF
	ElseIf $Signal = 64 Then
		$PitchOn = $C5_ON
		$PitchOff = $C5_OFF
	ElseIf $Signal = 65 Then
		$PitchOn = $C5SHARP_ON
		$PitchOff = $C5SHARP_OFF
	ElseIf $Signal = 66 Then
		$PitchOn = $D5_ON
		$PitchOff = $D5_OFF
	ElseIf $Signal = 67 Then
		$PitchOn = $D5SHARP_ON
		$PitchOff = $D5SHARP_OFF
	ElseIf $Signal = 68 Then
		$PitchOn = $E5_ON
		$PitchOff = $E5_OFF
	ElseIf $Signal = 69 Then
		$PitchOn = $F5_ON
		$PitchOff = $F5_OFF
	ElseIf $Signal = 70 Then
		$PitchOn = $F5SHARP_ON
		$PitchOff = $F5SHARP_OFF
	ElseIf $Signal = 71 Then
		$PitchOn = $G5_ON
		$PitchOff = $G5_OFF
	ElseIf $Signal = 72 Then
		$PitchOn = $G5SHARP_ON
		$PitchOff = $G5SHARP_OFF
	ElseIf $Signal = 73 Then
		$PitchOn = $A5_ON
		$PitchOff = $A5_OFF
	ElseIf $Signal = 74 Then
		$PitchOn = $A5SHARP_ON
		$PitchOff = $A5SHARP_OFF
	ElseIf $Signal = 75 Then
		$PitchOn = $B5_ON
		$PitchOff = $B5_OFF
	ElseIf $Signal = 76 Then
		$PitchOn = $C6_ON
		$PitchOff = $C6_OFF
	ElseIf $Signal = 77 Then
		$PitchOn = $C6SHARP_ON
		$PitchOff = $C6SHARP_OFF
	ElseIf $Signal = 78 Then
		$PitchOn = $D6_ON
		$PitchOff = $D6_OFF
	ElseIf $Signal = 79 Then
		$PitchOn = $D6SHARP_ON
		$PitchOff = $D6SHARP_OFF
	ElseIf $Signal = 80 Then
		$PitchOn = $E6_ON
		$PitchOff = $E6_OFF
	ElseIf $Signal = 81 Then
		$PitchOn = $F6_ON
		$PitchOff = $F6_OFF
	ElseIf $Signal = 82 Then
		$PitchOn = $F6SHARP_ON
		$PitchOff = $F6SHARP_OFF
	ElseIf $Signal = 83 Then
		$PitchOn = $G6_ON
		$PitchOff = $G6_OFF
	ElseIf $Signal = 84 Then
		$PitchOn = $G6SHARP_ON
		$PitchOff = $G6SHARP_OFF
	ElseIf $Signal = 85 Then
		$PitchOn = $A6_ON
		$PitchOff = $A6_OFF
	ElseIf $Signal = 86 Then
		$PitchOn = $A6SHARP_ON
		$PitchOff = $A6SHARP_OFF
	ElseIf $Signal = 87 Then
		$PitchOn = $B6_ON
		$PitchOff = $B6_OFF
	ElseIf $Signal = 88 Then
		$PitchOn = $C7_ON
		$PitchOff = $C7_OFF
	ElseIf $Signal = 89 Then
		$PitchOn = $C7SHARP_ON
		$PitchOff = $C7SHARP_OFF
	ElseIf $Signal = 90 Then
		$PitchOn = $D7_ON
		$PitchOff = $D7_OFF
	ElseIf $Signal = 91 Then
		$PitchOn = $D7SHARP_ON
		$PitchOff = $D7SHARP_OFF
	ElseIf $Signal = 92 Then
		$PitchOn = $E7_ON
		$PitchOff = $E7_OFF
	ElseIf $Signal = 93 Then
		$PitchOn = $F7_ON
		$PitchOff = $F7_OFF
	ElseIf $Signal = 94 Then
		$PitchOn = $F7SHARP_ON
		$PitchOff = $F7SHARP_OFF
	ElseIf $Signal = 95 Then
		$PitchOn = $G7_ON
		$PitchOff = $G7_OFF
	ElseIf $Signal = 96 Then
		$PitchOn = $G7SHARP_ON
		$PitchOff = $G7SHARP_OFF
	ElseIf $Signal = 97 Then
		$PitchOn = $A7_ON
		$PitchOff = $A7_OFF
	ElseIf $Signal = 98 Then
		$PitchOn = $A7SHARP_ON
		$PitchOff = $A7SHARP_OFF
	ElseIf $Signal = 99 Then
		$PitchOn = $B7_ON
		$PitchOff = $B7_OFF
	ElseIf $Signal = 100 Then
		$PitchOn = $C8_ON
		$PitchOff = $C8_OFF
	EndIf
	If $PitchOn <> '' And $PitchOff <> '' Then
		$open = _MidiOutOpen()
		_MidiOutShortMsg($open, 256 * $Instrument + 192) ;Select Instrument
		_MidiOutShortMsg($open, $PitchOn);Start playing Instrument
		Sleep($Sleeptime)
		_MidiOutShortMsg($open, $PitchOff);Stop playing Instrument
		_MidiOutClose($open)
	EndIf
EndFunc   ;==>_PlayMidi

Func _SigBasedSound($volume)
		If $volume >= 1 And $volume <= 20 Then
			SoundSetWaveVolume(20)
			SoundPlay($SoundDir & $new_AP_sound, 1)
		ElseIf $volume >= 21 And $volume <= 40 Then
			SoundSetWaveVolume(40)
			SoundPlay($SoundDir & $new_AP_sound, 1)
		ElseIf $volume >= 41 And $volume <= 60 Then
			SoundSetWaveVolume(60)
			SoundPlay($SoundDir & $new_AP_sound, 1)
		ElseIf $volume >= 61 And $volume <= 80 Then
			SoundSetWaveVolume(80)
			SoundPlay($SoundDir & $new_AP_sound, 1)
		ElseIf $volume >= 81 And $volume <= 100 Then
			SoundSetWaveVolume(100)
			SoundPlay($SoundDir & $new_AP_sound, 1)
		EndIf
EndFunc