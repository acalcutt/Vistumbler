#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Icons\icon.ico
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
;License Information------------------------------------
;Copyright (C) 2016 Andrew Calcutt
;This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; Version 2 of the License.
;This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
;You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
;--------------------------------------------------------
;AutoIt Version: v3.3.14.3
$Script_Author = 'Andrew Calcutt'
$Script_Start_Date = '07/19/2008'
$Script_Name = 'SayText'
$Script_Website = 'http://www.Vistumbler.net'
$Script_Function = 'Uses Sound files, Microsoft SAPI, or MIDI sounds to say a number from 0 - 100'
$version = 'v5.1'
$last_modified = '2016/03/06'
;--------------------------------------------------------
#include <String.au3>
#include "UDFs\MIDIFunctions.au3"
#include "UDFs\MIDIConstants.au3"

Dim $Default_settings = @ScriptDir & '\Settings\vistumbler_settings.ini'
Dim $Profile_settings = @AppDataDir & '\Vistumbler\vistumbler_settings.ini'
Dim $PortableMode = IniRead($Default_settings, 'Vistumbler', 'PortableMode', 0)
If $PortableMode = 1 Then
	$settings = $Default_settings
Else
	$settings = $Profile_settings
	If FileExists($Default_settings) And FileExists($settings) = 0 Then FileCopy($Default_settings, $settings, 1)
EndIf

Dim $SoundDir = @ScriptDir & '\Sounds\'
Dim $new_AP_sound = IniRead($settings, 'Sound', 'NewAP_Sound', 'new_ap.wav')
Dim $say = 'test'
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
		ConsoleWrite($say & @CRLF)
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
	$SpeakSplit = StringSplit(StringReverse($SpeakNum), '')
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
	$Pitch = ''
	;Pick Start/Stop Varialbles based on signal
	If $Signal > 0 And $Signal < 10 Then
		$Pitch = $NOTE_A0
	ElseIf $Signal >= 10 And $Signal < 15 Then
		$Pitch = $NOTE_A0SHARP
	ElseIf $Signal = 15 Then
		$Pitch = $NOTE_B0
	ElseIf $Signal = 16 Then
		$Pitch = $NOTE_C1
	ElseIf $Signal = 17 Then
		$Pitch = $NOTE_C1SHARP
	ElseIf $Signal = 18 Then
		$Pitch = $NOTE_D1
	ElseIf $Signal = 19 Then
		$Pitch = $NOTE_D1SHARP
	ElseIf $Signal = 20 Then
		$Pitch = $NOTE_E1
	ElseIf $Signal = 21 Then
		$Pitch = $NOTE_F1
	ElseIf $Signal = 22 Then
		$Pitch = $NOTE_F1SHARP
	ElseIf $Signal = 23 Then
		$Pitch = $NOTE_G1
	ElseIf $Signal = 24 Then
		$Pitch = $NOTE_G1SHARP
	ElseIf $Signal = 25 Then
		$Pitch = $NOTE_A1
	ElseIf $Signal = 26 Then
		$Pitch = $NOTE_A1SHARP
	ElseIf $Signal = 27 Then
		$Pitch = $NOTE_B1
	ElseIf $Signal = 28 Then
		$Pitch = $NOTE_C2
	ElseIf $Signal = 29 Then
		$Pitch = $NOTE_C2SHARP
	ElseIf $Signal = 30 Then
		$Pitch = $NOTE_D2
	ElseIf $Signal = 31 Then
		$Pitch = $NOTE_D2SHARP
	ElseIf $Signal = 32 Then
		$Pitch = $NOTE_E2
	ElseIf $Signal = 33 Then
		$Pitch = $NOTE_F2
	ElseIf $Signal = 34 Then
		$Pitch = $NOTE_F2SHARP
	ElseIf $Signal = 35 Then
		$Pitch = $NOTE_G2
	ElseIf $Signal = 36 Then
		$Pitch = $NOTE_G2SHARP
	ElseIf $Signal = 37 Then
		$Pitch = $NOTE_A2
	ElseIf $Signal = 38 Then
		$Pitch = $NOTE_A2SHARP
	ElseIf $Signal = 39 Then
		$Pitch = $NOTE_B2
	ElseIf $Signal = 40 Then
		$Pitch = $NOTE_C3
	ElseIf $Signal = 41 Then
		$Pitch = $NOTE_C3SHARP
	ElseIf $Signal = 42 Then
		$Pitch = $NOTE_D3
	ElseIf $Signal = 43 Then
		$Pitch = $NOTE_D3SHARP
	ElseIf $Signal = 44 Then
		$Pitch = $NOTE_E3
	ElseIf $Signal = 45 Then
		$Pitch = $NOTE_F3
	ElseIf $Signal = 46 Then
		$Pitch = $NOTE_F3SHARP
	ElseIf $Signal = 47 Then
		$Pitch = $NOTE_G3
	ElseIf $Signal = 48 Then
		$Pitch = $NOTE_G3SHARP
	ElseIf $Signal = 49 Then
		$Pitch = $NOTE_A3
	ElseIf $Signal = 50 Then
		$Pitch = $NOTE_A3SHARP
	ElseIf $Signal = 51 Then
		$Pitch = $NOTE_B3
	ElseIf $Signal = 52 Then
		$Pitch = $NOTE_C4
	ElseIf $Signal = 53 Then
		$Pitch = $NOTE_C4SHARP
	ElseIf $Signal = 54 Then
		$Pitch = $NOTE_D4
	ElseIf $Signal = 55 Then
		$Pitch = $NOTE_D4SHARP
	ElseIf $Signal = 56 Then
		$Pitch = $NOTE_E4
	ElseIf $Signal = 57 Then
		$Pitch = $NOTE_F4
	ElseIf $Signal = 58 Then
		$Pitch = $NOTE_F4SHARP
	ElseIf $Signal = 59 Then
		$Pitch = $NOTE_G4
	ElseIf $Signal = 60 Then
		$Pitch = $NOTE_G4SHARP
	ElseIf $Signal = 61 Then
		$Pitch = $NOTE_A4
	ElseIf $Signal = 62 Then
		$Pitch = $NOTE_A4SHARP
	ElseIf $Signal = 63 Then
		$Pitch = $NOTE_B4
	ElseIf $Signal = 64 Then
		$Pitch = $NOTE_C5
	ElseIf $Signal = 65 Then
		$Pitch = $NOTE_C5SHARP
	ElseIf $Signal = 66 Then
		$Pitch = $NOTE_D5
	ElseIf $Signal = 67 Then
		$Pitch = $NOTE_D5SHARP
	ElseIf $Signal = 68 Then
		$Pitch = $NOTE_E5
	ElseIf $Signal = 69 Then
		$Pitch = $NOTE_F5
	ElseIf $Signal = 70 Then
		$Pitch = $NOTE_F5SHARP
	ElseIf $Signal = 71 Then
		$Pitch = $NOTE_G5
	ElseIf $Signal = 72 Then
		$Pitch = $NOTE_G5SHARP
	ElseIf $Signal = 73 Then
		$Pitch = $NOTE_A5
	ElseIf $Signal = 74 Then
		$Pitch = $NOTE_A5SHARP
	ElseIf $Signal = 75 Then
		$Pitch = $NOTE_B5
	ElseIf $Signal = 76 Then
		$Pitch = $NOTE_C6
	ElseIf $Signal = 77 Then
		$Pitch = $NOTE_C6SHARP
	ElseIf $Signal = 78 Then
		$Pitch = $NOTE_D6
	ElseIf $Signal = 79 Then
		$Pitch = $NOTE_D6SHARP
	ElseIf $Signal = 80 Then
		$Pitch = $NOTE_E6
	ElseIf $Signal = 81 Then
		$Pitch = $NOTE_F6
	ElseIf $Signal = 82 Then
		$Pitch = $NOTE_F6SHARP
	ElseIf $Signal = 83 Then
		$Pitch = $NOTE_G6
	ElseIf $Signal = 84 Then
		$Pitch = $NOTE_G6SHARP
	ElseIf $Signal = 85 Then
		$Pitch = $NOTE_A6
	ElseIf $Signal = 86 Then
		$Pitch = $NOTE_A6SHARP
	ElseIf $Signal = 87 Then
		$Pitch = $NOTE_B6
	ElseIf $Signal = 88 Then
		$Pitch = $NOTE_C7
	ElseIf $Signal = 89 Then
		$Pitch = $NOTE_C7SHARP
	ElseIf $Signal = 90 Then
		$Pitch = $NOTE_D7
	ElseIf $Signal = 91 Then
		$Pitch = $NOTE_D7SHARP
	ElseIf $Signal = 92 Then
		$Pitch = $NOTE_E7
	ElseIf $Signal = 93 Then
		$Pitch = $NOTE_F7
	ElseIf $Signal = 94 Then
		$Pitch = $NOTE_F7SHARP
	ElseIf $Signal = 95 Then
		$Pitch = $NOTE_G7
	ElseIf $Signal = 96 Then
		$Pitch = $NOTE_G7SHARP
	ElseIf $Signal = 97 Then
		$Pitch = $NOTE_A7
	ElseIf $Signal = 98 Then
		$Pitch = $NOTE_A7SHARP
	ElseIf $Signal = 99 Then
		$Pitch = $NOTE_B7
	ElseIf $Signal = 100 Then
		$Pitch = $NOTE_C8
	EndIf
	If $Pitch <> '' Then
		$open = _midiOutOpen()
		MidiSetInstrument($open, $Instrument);Select Instrument
		NoteOn($open, $Pitch, 1, $MIDI_MAX_VALUE)	;Start playing Instrument
		Sleep($Sleeptime)
		NoteOff($open, $Pitch, 1, $MIDI_MAX_VALUE);Stop playing Instrument
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
EndFunc   ;==>_SigBasedSound
