; ====================================================================================================
; <MIDIFunction.au3>
;
;  A MIDI UDF originated by Eynstyne, furthered by Ascend4nt and others (see Changes)
;
; Changes From Original midiUDF:
; *GMK -> cleanup of code, Constants 'cleanup', addition of Drum Map
; *Ascend4nt:
;  - Changed '_NOTEON/OFF' to _ON or _OFF per suggestion by Paulie* repalced with $NOTE_xx constants
;  - Recently Ditched _NOTEON/OFF as the messages weren't correct and weren't using the full
;    expressive capabilities of the MIDI interface
;  - @error checks/returns fixed (still some consistency needed in the module overall though)
;  - x64 compatibility & Structure fixes
;  - Addition of functions: _MidiOutPrepareHeader, _MidiOutUnprepareHeader, _MidiStreamOut
;	 (Still unclear as to MIDI buffer setup, and how _MidiStreamProperty should be called)
;  - fixed 'PrepareHeader' and 'UnprepareHeader' functions, and other functions that
;	 require a 'Prepared' Header (see function definitions for which require it)
;	 (Note: 'PrepareHeader' returns a structure, which must be passed (by reference) to these functions)
;  - fixed 'PrepareHeader' to make buffer part of structure (otherwise buffer is lost on function exit)
;	 (all functions updated to calculate size of structure based on this new format)
;  - added short structure definition for MIDI data..
;  - fixed $E4_OFF value (thx czardas)* also replaced with $NOTE_xx constants
;  - Added WinMM DLL handle for all calls. This speeds up calls and doesn't affect memory usage as
;    the module is imported by AutoIt anyway (i.e. it is preloaded)
;  - Added Full expressive NoteOn/Off functions - with channel and velocity selection
;  - Added nearly all useful MIDI messaging Functions
;  - Added $NOTE_xx constants, $DRUMS_xx constants, CONTROLLER Constants, misc. others
;  - Tidied up, declared locals, got rid of unneeded <Array.au3> dependencies
;  - Added new 'Extended Functions' (Ascend4nt) which expose most of the basic MIDI message interface
;    (there's optional bit-masking in the functions to control bad input, currently commented out)
;
; Basic API Functions (Eynstyne mostly):
;    _MidiOutGetNumDevs()
;    _MidiInGetNumDevs()
;    _MidiOutOpen()
;    _MidiInOpen()
;    _MidiOutSetVolume()
;    _MidiOutGetVolume()
;    _MidiOutReset()
;    _MidiInReset()
;    _MidiInStart()
;    _MidiInStop()
;    _MidiOutClose()
;    _MidiInClose()
;    _MidiOutCacheDrumPatches()
;    _MidiOutCachePatches()
;    _MidiInGetID()
;    _MidiOutGetID()
;    _MidiInGetErrorText()
;    _MidiOutGetErrorText()
;    _MidiOutShortMsg()
;    _MidiOutLongMsg()
;    _MidiOutLongMsg()
;    _MidiOutGetDevCaps()
;    _MidiInGetDevCaps()
;    _MidiConnect()
;    _MidiDisconnect()
;    _MidiInPrepareHeader()
;    _MidiInUnprepareHeader ()
;    _MidiInUnprepareHeader()
;    _MidiOutPrepareHeader()
;    _MidiOutUnprepareHeader ()
;    _MidiOutUnprepareHeader()
;    _MidiInAddBuffer()
;    _MidiInMessage()
;    _MidiOutMessage()
;    _MidiStreamClose()
;    _MidiStreamOpen()
;    _MidiStreamOut()
;    _MidiStreamOut()
;    _MidiStreamPause()
;    _MidiStreamPos()
;    _MidiStreamRestart()
;    _MidiStreamStop()
;    _MidiStreamProperty()
;
; Extended Functions (Ascend4nt):
;	NoteOn()		; Turns on a given note on a given channel at a given velocity
;	NoteAfterTouch(); Applies Aftertouch to a given note on a given channel at given pressure
;	NoteOff()		; Turns off a given note on a given channel
;	PercussionOn()	; Turns on a Percussion instrument at a given velocity
;	PercussionOff() ; Turns off a Percussion instrument
;	NotesAllOff()	; Turns off all notes on a given channel (unless sustain is on)
;	MidiAllSoundOff()		; Turns off all sound on a given channel (even if sustain is on)
;	MidiResetControllers()	; Resets Controllers (Pedals, PitchBend, Modulation, etc)
;	MidiPitchBend()			; Pitch-bends all the notes on a given channel
;	MidiChannelAftertouch() ; Sets Channel Pressure (AfterTouch) - different from NoteAfterTouch()
;	MidiSetInstrument()		; Sets the instrument on a given channel (channel 10 is special though)
;	MidiControlChange() 	; Sends certain Control messages (such as Pan, Modulate, Volume)
;
; Reference:
; MIDI Message Table 1 (Status = low byte, data 1 = upper byte LowWord, 2 = low byte HiWord)
;  @ http://www.midi.org/techspecs/midimessages.php
;
; "Multimedia Functions (Windows)" on MSDN
;  @ http://msdn.microsoft.com/en-us/library/windows/desktop/dd743586%28v=vs.85%29.aspx
;
; MIDI Registry Keys:
;   HKEY_CURRENT_USER\Software\Microsoft\ActiveMovie\devenum\{4EFE2452-168A-11D1-BC76-00C04FB9453B}\Default MidiOut Device
;   HKEY_CURRENT_USER\Software\Microsoft\ActiveMovie\devenum 64-bit\{4EFE2452-168A-11D1-BC76-00C04FB9453B}\Default MidiOut Device
;
;  MIDI Control on Win7:
;   BASS MIDI: http://kode54.net/bassmididrv/
;
; Special note: Callbacks can be done during Streaming. see MidiInProc and MidiOutProc @ MSDN
;
; See also:
; <MIDIConstants.au3>	; MIDI, WINMM Errors, Notes, Instruments, Controller Messages
; <MidiExTest.au3>      ; Simple demonstration of new MIDI capability
;
; Author: Eynstyne, Ascend4nt
; ====================================================================================================

; Speed up DLLCall's (winmm.dll is loaded with all AutoIt programs, so this doesn't hurt):
Global Const $g_MIDI_hWinMMDLL = DllOpen("winmm.dll")


; ------------------------ EXTENDED Functions --------------------------------------

; ==============================================================================================
; Func NoteOn($hMidiOut, $nNote, $nChannel = 1, $nVelocity = 127)
;
; Turns on, or restarts, $nNote on the given Channel at the given Velocity
;
; $hMidiOut = Handle to a Midi-Out device (retrieved via _MidiOutOpen() )
; $nNote = Note to Turn On. Valid values are 0-127, with 60 representing Middle C (C4)
;  There are 12 gradations of notes pitches (60 + 12 = C5)
; $nChannel = Channel to apply this to. Channels are 1-15, with 10 being percussion-only
; $nVelocity = Velocity to play note at. 127 is maximum volume, 64 is medium, and 0 is silent
;
; Author: Ascend4nt, based on code by Eynstyne [but more flexibility]
; ==============================================================================================
Func NoteOn($hMidiOut, $nNote, $nChannel = 1, $nVelocity = 127)
;~ 	Local Const $NOTE_ON = 0x90
	; Adjust cut-offs for Note and Velocity (0 - 127 for each)
;~ 	$nVelocity = BitAND($nVelocity, 0x7F)
	; Adjust cut-off for Note (0 - 127 for each)
;~ 	$nNote = BitAND($nNote, 0x7F)
	; 0x90 = Note ON
    Return _midiOutShortMsg($hMidiOut, ($nVelocity * 65536) + ($nNote * 256) + 0x90 + BitAND($nChannel - 1, 0xF))
EndFunc

; ==============================================================================================
; Func NoteAfterTouch($hMidiOut, $nNote, $nChannel = 1, $nPressure = 64)
;
; Applies Aftertouch to a given $nNote on the given Channel at the given Velocity
;  "This message is most often sent by pressing down on the key after it 'bottoms out' "
;
; Your MIDI card/controller must support this. Mine doesn't so this needs further testing..
;
; $hMidiOut = Handle to a Midi-Out device (retrieved via _MidiOutOpen() )
; $nNote = Note to apply Aftertouch to. Valid values are 0-127, with 60 representing Middle C (C4)
; $nChannel = Channel to apply this to. Channels are 1-15, with 10 being percussion-only
; $nPressure = Afteroutch 'Pressure' to apply to note. 127 is max, 64 is medium, and 0 is none
;
; Author: Ascend4nt
; ==============================================================================================
Func NoteAfterTouch($hMidiOut, $nNote, $nChannel = 1, $nPressure = 64)
	; Adjust cut-offs for Note and Velocity (0 - 127 for each)
;~ 	$nPressure = BitAND($nPressure, 0x7F)
	; Adjust cut-off for Note (0 - 127 for each)
;~ 	$nNote = BitAND($nNote, 0x7F)
	; 0xA0 = Aftertouch
    Return _midiOutShortMsg($hMidiOut, ($nPressure * 65536) + ($nNote * 256) + 0xA0 + BitAND($nChannel - 1, 0xF))
EndFunc

; ==============================================================================================
; Func NoteOff($hMidiOut, $nNote, $nChannel = 1, $nVelocity = 127)
;
; Turns off $nNote on the given Channel
;
; $hMidiOut = Handle to a Midi-Out device (retrieved via _MidiOutOpen() )
; $nNote = Note to Turn On. Valid values are 0-127, with 60 representing Middle C (C4)
;  There are 12 gradations of notes pitches (60 + 12 = C5)
; $nChannel = Channel to apply this to. Channels are 1-15, with 10 being percussion-only
; $nVelocity = Velocity to use at release. 127 is maximum volume, 64 is medium, and 0 is silent
;	Not sure how this is applied at Note-Off, but it is nonetheless part of the mesage
;
; Author: Ascend4nt, based on code by Eynstyne [but corrected, and w/added ability]
; ==============================================================================================
Func NoteOff($hMidiOut, $nNote, $nChannel = 1, $nVelocity = 127)
;~ 	Local Const $NOTE_OFF = 0x80
	; Adjust cut-off for Velocity (0 - 127)
;~ 	$nVelocity = BitAND($nVelocity, 0x7F)
	; Adjust cut-off for Note (0 - 127 for each)
;~ 	$nNote = BitAND($nNote, 0x7F)
	; 0x80 = Note OFF
    Return _midiOutShortMsg($hMidiOut, ($nVelocity * 65536) + ($nNote * 256) + 0x80 + BitAND($nChannel - 1, 0xF))
Endfunc

; ==============================================================================================
; Func PercussionOn($hMidiOut, $nNote, $nVelocity = 127)
;
; A 'shortcut' to playing percussion instruments on channel 10
;  This is just a wrapper for a call to NoteOn for channel 10
;
; $hMidiOut = Handle to a Midi-Out device (retrieved via _MidiOutOpen() )
; $nNote = Instrument to Turn On. Valid values are 0-127
; $nVelocity = Velocity to play instrument at. 127 is maximum volume, 64 is medium, and 0 is silent
;
; Author: Ascend4nt
; ==============================================================================================

Func PercussionOn($hMidiOut, $nNote, $nVelocity = 127)
	Return _midiOutShortMsg($hMidiOut, ($nVelocity * 65536) + ($nNote * 256) + 0x90 + 9)
;~ 	Return NoteOn($hMidiOut, $nNote, 10, $nVelocity)
EndFunc

; ==============================================================================================
; Func PercussionOff($hMidiOut, $nNote, $nVelocity = 127)
;
; A 'shortcut' to playing percussion instruments on channel 10
;  This is just a wrapper for a call to NoteOff for channel 10
;
; $hMidiOut = Handle to a Midi-Out device (retrieved via _MidiOutOpen() )
; $nNote = Instrument to Turn On. Valid values are 0-127
; $nVelocity = Velocity to use at release. 127 is maximum volume, 64 is medium, and 0 is silent
;	Not sure how this is applied at Note-Off, but it is nonetheless part of the mesage
;
; Author: Ascend4nt
; ==============================================================================================

Func PercussionOff($hMidiOut, $nNote, $nVelocity = 127)
	Return _midiOutShortMsg($hMidiOut, ($nVelocity * 65536) + ($nNote * 256) + 0x80 + 9)
;~ 	Return NoteOff($hMidiOut, $nNote, 10, $nVelocity)
EndFunc

; ==============================================================================================
; Func NotesAllOff($hMidiOut, $nChannel = 1)
;
; This turns off all 'On' notes for a given channel.
;  NOTE however that a 'Sustain' message will continue emitting sound for any notes
;  until either sustain is turned off, or MidiAllSoundOff() is called
;
; $hMidiOut = Handle to a Midi-Out device (retrieved via _MidiOutOpen() )
; $nChannel = Channel to apply this to. Channels are 1-15, with 10 being percussion-only
;
; Author: Ascend4nt
; ==============================================================================================

Func NotesAllOff($hMidiOut, $nChannel = 1)
	; 0xB0 = Channel Mode Message, 7B = All Notes Off
	Return _midiOutShortMsg($hMidiOut, 0x7BB0 + BitAND($nChannel - 1, 0xF))
EndFunc

; ==============================================================================================
; Func MidiAllSoundOff($hMidiOut, $nChannel = 1)
;
; This turns off all sound for a given channel.
;  This differs from NotesAllOff() in that this will additionally turn of sustained notes
;
; $hMidiOut = Handle to a Midi-Out device (retrieved via _MidiOutOpen() )
; $nChannel = Channel to apply this to. Channels are 1-15, with 10 being percussion-only
;
; Author: Ascend4nt
; ==============================================================================================

Func MidiAllSoundOff($hMidiOut, $nChannel = 1)
	; 0xB0 = Channel Mode Message, 78 = All Sound Off
	Return _midiOutShortMsg($hMidiOut, 0x78B0 + BitAND($nChannel - 1, 0xF))
EndFunc

; ==============================================================================================
; Func MidiResetControllers($hMidiOut, $nChannel = 1)
;
; Resets Controllers:
;	Modulation, Channel & Polyphonic Pressure are set to 0
;	Pedals (Sustain (Damper), Portamento, Sostenuto, Soft Pedal) set to 0
;	PitchBend set to center
;
; See 'RP-15: Response to Reset All Controllers'
; @ http://www.midi.org/techspecs/rp15.php
;
; $hMidiOut = Handle to a Midi-Out device (retrieved via _MidiOutOpen() )
; $nChannel = Channel to apply this to. Channels are 1-15, with 10 being percussion-only
;
; Author: Ascend4nt
; ==============================================================================================

Func MidiResetControllers($hMidiOut, $nChannel = 1)
	; 0xB0 = Channel Mode Message, 79 = Reset All Controllers
	Return _midiOutShortMsg($hMidiOut, 0x79B0 + BitAND($nChannel - 1, 0xF))
EndFunc

; ==============================================================================================
; Func MidiPitchBend($hMidiOut, $nBendValue = 8192, $nChannel = 1)
;
; Pitch-Bends all Notes on specified channel
;
; $hMidiOut = Handle to a Midi-Out device (retrieved via _MidiOutOpen() )
; $nBendValue = Value from 0 - 16383. Default (no bend) is 8192 (0x2000)
;	 Lower than 8192 lowers pitch, Higher #'s increase pitch
; $nChannel = Channel to apply this to. Channels are 1-15, with 10 being percussion-only
;
;  The mapping of bytes appears correctly though:
;  [31-24] = 0, [23] = 0, [22 - 16] = Upper 7 Bits, [15] = 0, [14 - 8] = Lower 7 Bits
;
; Author: Ascend4nt
; ==============================================================================================

Func MidiPitchBend($hMidiOut, $nBendValue = 8192, $nChannel = 1)
	; Min-Max Range is 14 bits
	If $nBendValue > 0x3FFF Or $nBendValue < 0 Then Return SetError(1,0,0)
	; Low 7 Bits - Upper Byte of Lower Word
	Local $nLowBend = BitAND($nBendValue, 0x7F) * 256
	; Upper 7 Bits -> Move to Lower Byte of Upper Word
	Local $nHighBend = BitShift($nBendValue, 7) * 65536
;~ 	ConsoleWrite("MidiPitchBend value = 0x" & Hex($nHighBend + $nLowBend + 0xE0 + $nChannel) & @CRLF)
	; 0xE0 = Pitch Bend
	Return _midiOutShortMsg($hMidiOut, $nHighBend + $nLowBend + 0xE0 + BitAND($nChannel - 1, 0xF))
EndFunc

; ==============================================================================================
; Func MidiChannelAftertouch($hMidiOut, $nChannel = 1, $nVelocity = 127)
;
; Adjusts Channel Aftertouch. Different from Note Aftertouch
;
; See: 'MIDI Specification: Channel Pressure'
; @ http://www.blitter.com/~russtopia/MIDI/~jglatt/tech/midispec/pressure.htm
;
; $hMidiOut = Handle to a Midi-Out device (retrieved via _MidiOutOpen() )
; $nChannel = Channel to apply this to. Channels are 1-15, with 10 being percussion-only
; $nVelocity = Velocity, or pressure, value. 127 is maximum volume, 64 is medium, and 0 is none
;
; Author: Ascend4nt
; ==============================================================================================

Func MidiChannelAftertouch($hMidiOut, $nChannel = 1, $nVelocity = 127)
	; Adjust cut-off for Velocity (0 - 127)
;~ 	$nVelocity = BitAND($nVelocity, 0x7F)
	; 0xD0 = Channel Pressure (AfterTouch)
    Return _midiOutShortMsg($hMidiOut, ($nVelocity * 256) + 0xD0 + BitAND($nChannel - 1, 0xF))
EndFunc

; ==============================================================================================
; Func MidiSetInstrument($hMidiOut, $nInstrument, $nChannel = 1)
;
; This sets a given instrument to a particular channel
;
; $hMidiOut = Handle to a Midi-Out device (retrieved via _MidiOutOpen() )
; $nInstrument = Instrument to use for the given Channel. Valid values are 0-127
;  Note that this should have no effect on Channel 10, which is percussive instruments.
; $nChannel = Channel to apply this to. Channels are 1-15, with 10 being percussion-only
;
; Author: Eynstyne, Ascend4nt (added Channel capability, and filtering)
; ==============================================================================================

Func MidiSetInstrument($hMidiOut, $nInstrument, $nChannel = 1)
	; Channels are 1-16 (represented as 0-15). Channel 10 is special- percussion instruments only
	$nChannel = BitAND($nChannel - 1, 0xF)
	; Instruments are 0 - 127
;~ 	$nInstrument = BitAND($nInstrument, 0x7F)
	; 0xC0 = Program Change
    Return _midiOutShortMsg($hMidiOut, ($nInstrument * 256) + 0xC0 + $nChannel)
EndFunc

; ==============================================================================================
; Func MidiControlChange($hMidiOut, $nControlID, $nControlVal, $nChannel = 1)
;
; Performs various control/mode changes on the specified channel
;
; $hMidiOut = Handle to a Midi-Out device (retrieved via _MidiOutOpen() )
; $nControlID = # of the Control Function to use (e.g. 0x0A = Pan)
; $nControlVal = Value to be used with Control Change (0 - 127)
; $nChannel = Channel to apply this to. Channels are 1-15, with 10 being percussion-only
;
; Author: Ascend4nt
; ==============================================================================================

Func MidiControlChange($hMidiOut, $nControlID, $nControlVal, $nChannel = 1)
	; 7-bit cut off for values
	$nControlID = BitAND($nControlID, 0x7F)
	$nControlVal = BitAND($nControlVal, 0x7F)
	; 0xB0 = Control Change
	Return _midiOutShortMsg($hMidiOut, ($nControlVal * 65536) + ($nControlID * 256) + 0xB0 + BitAND($nChannel - 1, 0xF))
EndFunc


; ------------------------ BASIC API FUNCTIONS --------------------------------------

;=======================================================
;Retrieves the number of Midi Output devices which exist
;Parameters - None
;Author : Eynstyne
;Library : Microsoft winmm.dll
;=======================================================
Func _MidiOutGetNumDevs()
	Local $aRet = DllCall($g_MIDI_hWinMMDLL, "long", "midiOutGetNumDevs")
	If @error Then Return SetError(@error, 0, 0)
	Return $aRet[0]
EndFunc   ;==>_MidiOutGetNumDevs

;=======================================================
;Retrieves the number of Midi Input devices which exist
;Parameters - None
;Author : Eynstyne
;Library : Microsoft winmm.dll
;=======================================================
Func _MidiInGetNumDevs() ;Working
	Local $aRet = DllCall($g_MIDI_hWinMMDLL, "long", "midiInGetNumDevs")
	If @error Then Return SetError(@error, 0, 0)
	Return $aRet[0]
EndFunc   ;==>_MidiInGetNumDevs

;=======================================================
;Retrieves a MIDI handle and Opens the Device
;Parameters(Optional) - Device ID, Window Callback,
; instance, flags
;Author : Eynstyne
;Library : Microsoft winmm.dll
;=======================================================
Func _MidiOutOpen($nDevID = 0, $pCallback = 0, $instance = 0, $nFlags = 0)
	Local $aRet = DllCall($g_MIDI_hWinMMDLL, "long", "midiOutOpen", "handle*", 0, "int", $nDevID, "dword_ptr", $pCallback, "dword_ptr", $instance, "long", $nFlags)
	If @error Then Return SetError(@error, 0, 0)
	If $aRet[0] Then Return SetError(-1, $aRet[0], 0)
	Return $aRet[1]
EndFunc   ;==>_MidiOutOpen

;=======================================================
;Retrieves a MIDI handle and Opens the Device
;Parameters(Optional) - Device ID, Window Callback,
; instance, flags
;Author : Eynstyne
;Library : Microsoft winmm.dll
;=======================================================
Func _MidiInOpen($nDevID = 0, $pCallback = 0, $instance = 0, $nFlags = 0)
	Local $aRet = DllCall($g_MIDI_hWinMMDLL, "long", "midiInOpen", "handle*", 0, "int", $nDevID, "dword_ptr", $pCallback, "dword_ptr", $instance, "long", $nFlags)
	If @error Then Return SetError(@error, 0, 0)
	If $aRet[0] Then Return SetError(-1, $aRet[0], 0)
	Return $aRet[1]
EndFunc   ;==>_MidiInOpen

;=======================================================
;Sets the Mixer Volume for MIDI
;Parameters - Volume (0 - 65535)
;Author : Eynstyne
;Library : Microsoft winmm.dll
;=======================================================
Func _MidiOutSetVolume($nVolume, $nDevID = 0)
	Local $aRet = DllCall($g_MIDI_hWinMMDLL, "long", "midiOutSetVolume", "handle", $nDevID, "int", $nVolume)
	If @error Then Return SetError(@error, 0, 0)
	If $aRet[0] Then Return SetError(-1, $aRet[0], 0)
	Return $aRet[0]
EndFunc   ;==>_MidiOutSetVolume

;=======================================================
;Gets the Mixer Volume for MIDI
;Parameters - None
;Author : Eynstyne
;Library : Microsoft winmm.dll
;=======================================================
Func _MidiOutGetVolume($nDevID = 0)
	Local $aRet = DllCall($g_MIDI_hWinMMDLL, "long", "midiOutGetVolume", "handle", $nDevID, "dword*", 0)
	If @error Then Return SetError(@error, 0, 0)
	If $aRet[0] Then Return SetError(-1, $aRet[0], 0)
	Return $aRet[2]
EndFunc   ;==>_MidiOutGetVolume

;=======================================================
;Resets MIDI Output/Input
;Parameters - MidiHandle
;Author : Eynstyne
;Library : Microsoft winmm.dll
;=======================================================
Func _MidiOutReset($hMidiOut)
	Local $aRet = DllCall($g_MIDI_hWinMMDLL, "long", "midiOutReset", "handle", $hMidiOut)
	If @error Then Return SetError(@error, 0, 0)
	If $aRet[0] Then Return SetError(-1, $aRet[0], 0)
	Return $aRet[0]
EndFunc   ;==>_MidiOutReset

Func _MidiInReset($hMidiIn)
	Local $aRet = DllCall($g_MIDI_hWinMMDLL, "long", "midiInReset", "handle", $hMidiIn)
	If @error Then Return SetError(@error, 0, 0)
	If $aRet[0] Then Return SetError(-1, $aRet[0], 0)
	Return $aRet[0]
EndFunc   ;==>_MidiInReset

;=======================================================
;Starts Midi Input
;Parameters - MidiHandle
;Author : Eynstyne
;Library : Microsoft winmm.dll
;=======================================================
Func _MidiInStart($hMidiIn)
	Local $aRet = DllCall($g_MIDI_hWinMMDLL, "long", "midiInStart", "handle", $hMidiIn)
	If @error Then Return SetError(@error, 0, 0)
	If $aRet[0] Then Return SetError(-1, $aRet[0], 0)
	Return $aRet[0]
EndFunc   ;==>_MidiInStart

;=======================================================
;Stops Midi Input
;Parameters - MidiHandle
;Author : Eynstyne
;Library : Microsoft winmm.dll
;=======================================================
Func _MidiInStop($hMidiIn)
	Local $aRet = DllCall($g_MIDI_hWinMMDLL, "long", "midiInStop", "handle", $hMidiIn)
	If @error Then Return SetError(@error, 0, 0)
	If $aRet[0] Then Return SetError(-1, $aRet[0], 0)
	Return $aRet[0]
EndFunc   ;==>_MidiInStop

;=======================================================
;Closes Midi Output/Input devices
;Parameters - MidiHandle
;Author : Eynstyne
;Library : Microsoft winmm.dll
;=======================================================
Func _MidiOutClose($hMidiOut)
	Local $aRet = DllCall($g_MIDI_hWinMMDLL, "long", "midiOutClose", "handle", $hMidiOut)
	If @error Then Return SetError(@error, 0, 0)
	If $aRet[0] Then Return SetError(-1, $aRet[0], 0)
	Return $aRet[0]
EndFunc   ;==>_MidiOutClose

Func _MidiInClose($hMidiIn)
	Local $aRet = DllCall($g_MIDI_hWinMMDLL, "long", "midiInClose", "handle", $hMidiIn)
	If @error Then Return SetError(@error, 0, 0)
	If $aRet[0] Then Return SetError(-1, $aRet[0], 0)
	Return $aRet[0]
EndFunc   ;==>_MidiInClose

;=======================================================
;Cache Drum Patches for Output
;Parameters - MidiHandle,Patch,$patches,Flag
;Author : Eynstyne
;Library : Microsoft winmm.dll
;=======================================================
Func _MidiOutCacheDrumPatches($hMidiOut, $Patch, $patches, $nFlags = 0)
	Local $aRet, $stKeyArray = DllStructCreate("short[128]") ; "short KEYARRAY[MIDIPATCHSIZE]" (MIDIPATCHSIZE=128]
	If Not IsArray($patches) Then Dim $patches[0] = [$patches]
	For $i = 0 To UBound($patches) - 1
		DllStructSetData($stKeyArray, 1, $patches[$i], $i + 1)
	Next
	$aRet = DllCall($g_MIDI_hWinMMDLL, "long", "midiOutCacheDrumPatches", "handle", $hMidiOut, "int", $Patch, "ptr", DllStructGetPtr($stKeyArray), "int", $nFlags)
	If @error Then Return SetError(@error, 0, 0)
	If $aRet[0] Then Return SetError(-1, $aRet[0], 0)
	Return $aRet[0]
EndFunc   ;==>_MidiOutCacheDrumPatches

;=======================================================
;Caches MIDI Patches
;Parameters - MidiHandle, Bank, $patches, Flags
;Author : Eynstyne
;Library : Microsoft winmm.dll
;=======================================================
Func _MidiOutCachePatches($hMidiOut, $nBank, $patches, $nFlags = 0)
	Local $aRet, $stPatchArray = DllStructCreate("short[128]") ; "short PATCHARRAY[MIDIPATCHSIZE]" (MIDIPATCHSIZE=128)
	If Not IsArray($patches) Then Dim $patches[0] = [$patches]
	For $i = 0 To UBound($patches) - 1
		DllStructSetData($stPatchArray, 1, $patches[$i], $i + 1)
	Next
	$aRet = DllCall($g_MIDI_hWinMMDLL, "long", "midiOutCachePatches", "handle", $hMidiOut, "int", $nBank, "ptr", DllStructGetPtr($stPatchArray), "int", $nFlags)
	If @error Then Return SetError(@error, 0, 0)
	If $aRet[0] Then Return SetError(-1, $aRet[0], 0)
	Return $aRet[0]
EndFunc   ;==>_MidiOutCachePatches

;=======================================================
;Gets MIDI DeviceID
;Parameters - MidiHandle
;Author : Eynstyne
;Library : Microsoft winmm.dll
;=======================================================
Func _MidiInGetID($hMidiIn)
	Local $aRet = DllCall($g_MIDI_hWinMMDLL, "long", "midiInGetID", "handle", $hMidiIn, "uint*", 0)
	If @error Then Return SetError(@error, 0, 0)
	If $aRet[0] Then Return SetError(-1, $aRet[0], 0)
	Return $aRet[2]
EndFunc   ;==>_MidiInGetID

Func _MidiOutGetID($hMidiOut)
	Local $aRet = DllCall($g_MIDI_hWinMMDLL, "long", "midiOutGetID", "handle", $hMidiOut, "uint*", 0)
	If @error Then Return SetError(@error, 0, 0)
	If $aRet[0] Then Return SetError(-1, $aRet[0], 0)
	Return $aRet[2]
EndFunc   ;==>_MidiOutGetID

;=======================================================
;Translates Error codes into Plaintext
;Parameters - Error number
;Author : Eynstyne
;Library : Microsoft winmm.dll
;=======================================================
Func _MidiInGetErrorText($nError)
	Local $aRet = DllCall($g_MIDI_hWinMMDLL, "long", "midiInGetErrorTextW", "int", $nError, "wstr", "", "uint", 65536)
	If @error Then Return SetError(@error, 0, 0)
	If $aRet[0] Then Return SetError(-1, $aRet[0], 0)
	MsgBox(0, "MIDI In Error Text", $aRet[2])
	Return $aRet[2]
EndFunc   ;==>_MidiInGetErrorText

Func _MidiOutGetErrorText($nError)
	Local $aRet = DllCall($g_MIDI_hWinMMDLL, "long", "midiOutGetErrorTextW", "int", $nError, "wstr", "", "uint", 65536)
	If @error Then Return SetError(@error, 0, 0)
	If $aRet[0] Then Return SetError(-1, $aRet[0], 0)
	MsgBox(0, "MIDI Out Error Text", $aRet[2])
	Return $aRet[2]
EndFunc   ;==>_MidiOutGetErrorText

;=======================================================
;MIDI Message Send Function
;Parameters - Message as Hexcode or Constant
;Author : Eynstyne
;Library : Microsoft winmm.dll
;=======================================================
Func _MidiOutShortMsg($hMidiOut, $nMsg)
	Local $aRet = DllCall($g_MIDI_hWinMMDLL, "long", "midiOutShortMsg", "handle", $hMidiOut, "long", $nMsg)
	If @error Then Return SetError(@error, 0, 0)
	If $aRet[0] Then Return SetError(-1, $aRet[0], 0)
	Return $aRet[0]
EndFunc   ;==>_MidiOutShortMsg

;=======================================================
; Func _MidiOutLongMsg($hMidiOut, ByRef $stPreparedMidiHdr)
;
; parameters: handle to Midi Out, structure (from _MidiOutPrepareHeader)
;=======================================================

Func _MidiOutLongMsg($hMidiOut, ByRef $stPreparedMidiHdr)
	Local $aRet = DllCall($g_MIDI_hWinMMDLL, "long", "midiOutLongMsg", "handle", $hMidiOut, "ptr", DllStructGetPtr($stPreparedMidiHdr), "long", Number(DllStructGetPtr($stPreparedMidiHdr, 10) - DllStructGetPtr($stPreparedMidiHdr)))
	If @error Then Return SetError(@error, 0, 0)
	If $aRet[0] Then Return SetError(-1, $aRet[0], 0)
	Return $aRet[0]
EndFunc   ;==>_MidiOutLongMsg

;=======================================================
;Get the Capabilities of the MIDI Device
;Parameters - DeviceID
;Author : Eynstyne
;Library : Microsoft winmm.dll
;First Value - Manufacturer ID
;Second Value - Product ID
;Third Value - Driver Version
;Fourth Value - Driver Name
;Fifth Value - Type of Device
;Sixth Value - Voices
;Seventh Value - Notes
;eighth Value - Channel Mask
;Ninth Value - Capabilities
;=======================================================
Func _MidiOutGetDevCaps($nDeviceID = 0, $getmmsyserr = 0)
	; MIDIOUTCAPS: Mfr ID, Product ID, DriverVersion, ProductName, Technology, Voices, Notes, ChannelMask, FunctionalitySupport
	Local $aRet, $stMIDIOutCaps = DllStructCreate("ushort;ushort;uint;wchar[32];ushort;ushort;ushort;ushort;uint")
	$aRet = DllCall($g_MIDI_hWinMMDLL, "long", "midiOutGetDevCapsW", "uint_ptr", $nDeviceID, "ptr", DllStructGetPtr($stMIDIOutCaps), "int", DllStructGetSize($stMIDIOutCaps))
	If @error Then Return SetError(@error, 0, 0)
	If $aRet[0] Then Return SetError(-1, $aRet[0], 0)
	If $getmmsyserr = 1 Then
		Return $aRet[0]
	ElseIf $getmmsyserr <> 1 Then
		Dim $aRet[9] = [DllStructGetData($stMIDIOutCaps, 1), DllStructGetData($stMIDIOutCaps, 2), _
				DllStructGetData($stMIDIOutCaps, 3), DllStructGetData($stMIDIOutCaps, 4), DllStructGetData($stMIDIOutCaps, 5), _
				DllStructGetData($stMIDIOutCaps, 6), DllStructGetData($stMIDIOutCaps, 7), DllStructGetData($stMIDIOutCaps, 8), DllStructGetData($stMIDIOutCaps, 9)]
		Return $aRet
	EndIf
EndFunc   ;==>_MidiOutGetDevCaps

;=======================================================
;Get the Capabilities of the MIDI Device Input
;Parameters - DeviceID
;Author : Eynstyne
;Library : Microsoft winmm.dll
;First Value - Manufacturer ID
;Second Value - Product ID
;Third Value - Driver Version
;Fourth Value - Driver Name
;=======================================================
Func _MidiInGetDevCaps($nDeviceID = 0, $getmmsyserr = 0)
	; MIDIINCAPS: Mfr ID, Product ID, DriverVersion, ProductName, FunctionalitySupport
	Local $aRet, $stMIDIInCaps = DllStructCreate("ushort;ushort;uint;wchar[32];dword")
	$aRet = DllCall($g_MIDI_hWinMMDLL, "long", "midiInGetDevCapsW", "uint_ptr", $nDeviceID, "ptr", DllStructGetPtr($stMIDIInCaps), "int", DllStructGetSize($stMIDIInCaps))
	If @error Then Return SetError(@error, 0, 0)
	If $aRet[0] Then Return SetError(-1, $aRet[0], 0)
	If $getmmsyserr = 1 Then
		Return $aRet[0]
	ElseIf $getmmsyserr <> 1 Then
		Dim $aRet[4] = [DllStructGetData($stMIDIInCaps, 1), DllStructGetData($stMIDIInCaps, 2), DllStructGetData($stMIDIInCaps, 3), DllStructGetData($stMIDIInCaps, 4)]
		Return $aRet
	EndIf
EndFunc   ;==>_MidiInGetDevCaps

;========================================================
;Connect/Disconnect the MIDI Device to Application Source
; / Dest.
;Parameters - MidiHandleIn, MidiHandleOut
;Author: Eynstyne
;Library : Microsoft winmm.dll
;========================================================
Func _MidiConnect($hMidiIn, $hMidiOut)
	Local $aRet = DllCall($g_MIDI_hWinMMDLL, "long", "midiConnect", "handle", $hMidiIn, "handle", $hMidiOut, "ptr", 0)
	If @error Then Return SetError(@error, 0, 0)
	If $aRet[0] Then Return SetError(-1, $aRet[0], 0)
	Return $aRet[0]
EndFunc   ;==>_MidiConnect

Func _MidiDisconnect($hMidiIn, $hMidiOut)
	Local $aRet = DllCall($g_MIDI_hWinMMDLL, "long", "midiDisconnect", "handle", $hMidiIn, "handle", $hMidiOut, "ptr", 0)
	If @error Then Return SetError(@error, 0, 0)
	If $aRet[0] Then Return SetError(-1, $aRet[0], 0)
	Return $aRet[0]
EndFunc   ;==>_MidiDisconnect

;========================================================
;Prepare/Unprepare the MIDI IN header
;Parameters - MidiInHandle,Data,Bufferlength,
; BytesRecorded,User,Flags,Getmmsystemerror
;
; Returns:
;	Success: Prepared Header STRUCTURE
;	Failure: 0, @error set
;
;Author:Eynstyne
;Library:Microsoft winmm.dll
;
; Buffer format:
;  MSDN: A series of MIDIEVENT Structures:
; 	struct MIDIEVENT {
;  		DWORD dwDeltaTime;
;  		DWORD dwStreamID;
;  		DWORD dwEvent;
;		DWORD dwParms[];
;	}
;========================================================
Func _MidiInPrepareHeader($hMidiIn, $binData, $nBufferLen, $bytesrecorded, $user, $nFlags)
	; MIDIHDR: BufferPtr,BufferLength,BytesRecorded,UserData,Flags,NextPtr,Reserved,Offset,Reserved[4] (+buffer)
	Local $aRet, $stMIDIHdr = DllStructCreate("ptr;dword;dword;dword_ptr;dword;ptr;dword_ptr;dword;dword_ptr[4];byte[" & $nBufferLen + 1 & "]")
	DllStructSetData($stMIDIHdr, 1, DllStructGetPtr($stMIDIHdr, 10))
	DllStructSetData($stMIDIHdr, 2, $nBufferLen)
	DllStructSetData($stMIDIHdr, 3, $bytesrecorded)
	DllStructSetData($stMIDIHdr, 4, $user)
	DllStructSetData($stMIDIHdr, 5, $nFlags)
;~   DllStructSetData($struct, 6, $next)	; according to MSDN - do NOT use
	DllStructSetData($stMIDIHdr, 7, 0)
	DllStructSetData($stMIDIHdr, 10, $binData)
	$aRet = DllCall($g_MIDI_hWinMMDLL, "long", "midiInPrepareHeader", "handle", $hMidiIn, "ptr", DllStructGetPtr($stMIDIHdr), "long", Number(DllStructGetPtr($stMIDIHdr, 10) - DllStructGetPtr($stMIDIHdr)))
	If @error Then Return SetError(@error, 0, 0)
	If $aRet[0] Then Return SetError(-1, $aRet[0], 0)
	Return $stMIDIHdr
EndFunc   ;==>_MidiInPrepareHeader

;=======================================================
; Func _MidiInUnprepareHeader ($hMidiIn, ByRef $stPreparedMidiHdr)
;
; parameters: handle to Midi In, structure (from _MidiInPrepareHeader)
;=======================================================

Func _MidiInUnprepareHeader($hMidiIn, ByRef $stPreparedMidiHdr)
	Local $aRet = DllCall($g_MIDI_hWinMMDLL, "long", "midiInUnprepareHeader", "handle", $hMidiIn, "ptr", DllStructGetPtr($stPreparedMidiHdr), "long", Number(DllStructGetPtr($stPreparedMidiHdr, 10) - DllStructGetPtr($stPreparedMidiHdr)))
	If @error Then Return SetError(@error, 0, 0)
	If $aRet[0] Then Return SetError(-1, $aRet[0], 0)
	Return $aRet[0]
EndFunc   ;==>_MidiInUnprepareHeader

;========================================================
;Prepare/Unprepare the MIDI OUT header
;Parameters - MidiOutHandle,Data,Bufferlength,
; BytesRecorded,User,Flags
;
; Returns:
;	Success: Prepared Header STRUCTURE
;	Failure: 0, @error set
;
;Author:Eynstyne, Ascend4nt
;Library:Microsoft winmm.dll
;
; Buffer format:
;  MSDN: A series of MIDIEVENT Structures:
; 	struct MIDIEVENT {
;  		DWORD dwDeltaTime;
;  		DWORD dwStreamID;
;  		DWORD dwEvent;
;		DWORD dwParms[];
;	}
;========================================================
Func _MidiOutPrepareHeader($hMidiOut, $binData, $nBufferLen, $bytesrecorded, $user, $nFlags)
	; MIDIHDR: BufferPtr,BufferLength,BytesRecorded,UserData,Flags,NextPtr,Reserved,Offset,Reserved[4] (+buffer)
	Local $aRet, $stMIDIHdr = DllStructCreate("ptr;dword;dword;dword_ptr;dword;ptr;dword_ptr;dword;dword_ptr[4];byte[" & $nBufferLen + 1 & "]")
	DllStructSetData($stMIDIHdr, 1, DllStructGetPtr($stMIDIHdr, 10))
	DllStructSetData($stMIDIHdr, 2, $nBufferLen)
	DllStructSetData($stMIDIHdr, 3, $bytesrecorded)
	DllStructSetData($stMIDIHdr, 4, $user)
	DllStructSetData($stMIDIHdr, 5, $nFlags)
;~   DllStructSetData($struct, 6, $next)	; according to MSDN - do NOT use
	DllStructSetData($stMIDIHdr, 7, 0)
	DllStructSetData($stMIDIHdr, 10, $binData)
	$aRet = DllCall($g_MIDI_hWinMMDLL, "long", "midiOutPrepareHeader", "handle", $hMidiOut, "ptr", DllStructGetPtr($stMIDIHdr), "long", Number(DllStructGetPtr($stMIDIHdr, 10) - DllStructGetPtr($stMIDIHdr)))
	If @error Then Return SetError(@error, 0, 0)
	If $aRet[0] Then Return SetError(-1, $aRet[0], 0)
	Return $stMIDIHdr
EndFunc   ;==>_MidiOutPrepareHeader

;=======================================================
; Func _MidiOutUnprepareHeader ($hMidiOut, ByRef $stPreparedMidiHdr)
;
; parameters: handle to Midi Out, structure (from _MidiOutPrepareHeader)
;=======================================================

Func _MidiOutUnprepareHeader($hMidiOut, ByRef $stPreparedMidiHdr)
	Local $aRet = DllCall($g_MIDI_hWinMMDLL, "long", "midiOutUnprepareHeader", "handle", $hMidiOut, "ptr", DllStructGetPtr($stPreparedMidiHdr), "long", Number(DllStructGetPtr($stPreparedMidiHdr, 10) - DllStructGetPtr($stPreparedMidiHdr)))
	If @error Then Return SetError(@error, 0, 0)
	If $aRet[0] Then Return SetError(-1, $aRet[0], 0)
	Return $aRet[0]
EndFunc   ;==>_MidiOutUnprepareHeader

;========================================================
;Add buffer to Midi Header
;
; parameters: handle to Midi In, structure (from _MidiInPrepareHeader)
;
;Author:Eynstyne
;Library:Microsoft winmm.dll
;========================================================

Func _MidiInAddBuffer($hMidiIn, ByRef $stPreparedMidiHdr)
	Local $aRet = DllCall($g_MIDI_hWinMMDLL, "long", "midiInAddBuffer", "handle", $hMidiIn, "ptr", DllStructGetPtr($stPreparedMidiHdr), "long", Number(DllStructGetPtr($stPreparedMidiHdr, 10) - DllStructGetPtr($stPreparedMidiHdr)))
	If @error Then Return SetError(@error, 0, 0)
	If $aRet[0] Then Return SetError(-1, $aRet[0], 0)
	Return $aRet[0]
EndFunc   ;==>_MidiInAddBuffer

;========================================================
;Sends Internal MIDI Info to Input / Output device
;Parameters - MidiInHandle,message, parameter1, parameter2
;Author:Eynstyne
;Library:Microsoft winmm.dll
;========================================================
Func _MidiInMessage($hMidiIn, $nMsg, $dw1 = 0, $dw2 = 0)
	Local $aRet = DllCall($g_MIDI_hWinMMDLL, "long", "midiInMessage", "handle", $hMidiIn, "long", $nMsg, "dword_ptr", $dw1, "dword_ptr", $dw2)
	If @error Then Return SetError(@error, 0, 0)
	If $aRet[0] Then Return SetError(-1, $aRet[0], 0)
	Return $aRet[0]
EndFunc   ;==>_MidiInMessage

Func _MidiOutMessage($hMidiOut, $nMsg, $dw1 = 0, $dw2 = 0)
	Local $aRet = DllCall($g_MIDI_hWinMMDLL, "long", "midiOutMessage", "handle", $hMidiOut, "long", $nMsg, "dword_ptr", $dw1, "dword_ptr", $dw2)
	If @error Then Return SetError(@error, 0, 0)
	If $aRet[0] Then Return SetError(-1, $aRet[0], 0)
	Return $aRet[0]
EndFunc   ;==>_MidiOutMessage

;====================
;Stream Functions
;====================
Func _MidiStreamClose($hMidiStream)
	Local $aRet = DllCall($g_MIDI_hWinMMDLL, "long", "midiStreamClose", "handle", $hMidiStream)
	If @error Then Return SetError(@error, 0, 0)
	If $aRet[0] Then Return SetError(-1, $aRet[0], 0)
	Return $aRet[0]
EndFunc   ;==>_MidiStreamClose

Func _MidiStreamOpen($cMidi = 0, $pCallback = 0, $instance = 0, $fdwopen = 0, $getmmsyserr = 0)
	Local $aRet = DllCall($g_MIDI_hWinMMDLL, "long", "midiStreamOpen", "handle*", 0, "uint*", 0, "long", $cMidi, "dword_ptr", $pCallback, "dword_ptr", $instance, "long", $fdwopen)
	If @error Then Return SetError(@error, 0, 0)
	If $aRet[0] Then Return SetError(-1, $aRet[0], 0)
	If $getmmsyserr = 1 Then
		Return $aRet[0]
	ElseIf $getmmsyserr <> 1 Then
		Local $aOut[2] = [$aRet[1], $aRet[2]]
		Return $aOut
	EndIf
EndFunc   ;==>_MidiStreamOpen

;=======================================================
; Func _MidiStreamOut($hMidiStreamOut,ByRef $stPreparedMidiHdr)
;
; Notes: _MidiOutPrepareHeader and _MidiStreamRestart must be called before this
;
; parameters: handle to stream, structure (from _MidiOutPrepareHeader)
;=======================================================

Func _MidiStreamOut($hMidiStreamOut, ByRef $stPreparedMidiHdr)
	Local $aRet = DllCall($g_MIDI_hWinMMDLL, "long", "midiStreamOut", "handle", $hMidiStreamOut, "ptr", DllStructGetPtr($stPreparedMidiHdr), "uint", Number(DllStructGetPtr($stPreparedMidiHdr, 10) - DllStructGetPtr($stPreparedMidiHdr)))
	If @error Then Return SetError(@error, 0, 0)
	If $aRet[0] Then Return SetError(-1, $aRet[0], 0)
	Return $aRet[0]
EndFunc   ;==>_MidiStreamOut

Func _MidiStreamPause($hMidiStream)
	Local $aRet = DllCall($g_MIDI_hWinMMDLL, "long", "midiStreamPause", "handle", $hMidiStream)
	If @error Then Return SetError(@error, 0, 0)
	If $aRet[0] Then Return SetError(-1, $aRet[0], 0)
	Return $aRet[0]
EndFunc   ;==>_MidiStreamPause

Func _MidiStreamPos($hMidiStream, $getmmsyserr = 0)
	; MMTIME: Type, Union (4 dword's max, dependent on Type)
	Local $aRet, $stMMTime = DllStructCreate("uint;dword;dword;dword;dword")
	$aRet = DllCall($g_MIDI_hWinMMDLL, "long", "midiStreamPosition", "handle", $hMidiStream, "ptr", DllStructGetPtr($stMMTime), "long", DllStructGetSize($stMMTime))
	If @error Then Return SetError(@error, 0, 0)
	If $aRet[0] Then Return SetError(-1, $aRet[0], 0)
	If $getmmsyserr = 1 Then
		Return $aRet[0]
	ElseIf $getmmsyserr <> 1 Then
		Dim $aRet[2] = [DllStructGetData($stMMTime, 1), DllStructGetData($stMMTime, 2)]
		Return $aRet
	EndIf
EndFunc   ;==>_MidiStreamPos

Func _MidiStreamRestart($hMidiStream)
	Local $aRet = DllCall($g_MIDI_hWinMMDLL, "long", "midiStreamRestart", "handle", $hMidiStream)
	If @error Then Return SetError(@error, 0, 0)
	If $aRet[0] Then Return SetError(-1, $aRet[0], 0)
	Return $aRet[0]
EndFunc   ;==>_MidiStreamRestart

Func _MidiStreamStop($hMidiStream)
	Local $aRet = DllCall($g_MIDI_hWinMMDLL, "long", "midiStreamStop", "handle", $hMidiStream)
	If @error Then Return SetError(@error, 0, 0)
	If $aRet[0] Then Return SetError(-1, $aRet[0], 0)
	Return $aRet[0]
EndFunc   ;==>_MidiStreamStop

Func _MidiStreamProperty($hMidiStream, $property = 0, $getmmsyserr = 0)
	Local $aRet, $stPropertyData = DllStructCreate("byte") ; should this be an array of bytes? If not, put in DLLCall as "byte*" and retrieve with $aRet[2]
	$aRet = DllCall($g_MIDI_hWinMMDLL, "long", "midiStreamProperty", "handle", $hMidiStream, "ptr", DllStructGetPtr($stPropertyData), "long", $property)
	If @error Then Return SetError(@error, 0, 0)
	If $aRet[0] Then Return SetError(-1, $aRet[0], 0)
	If $getmmsyserr = 1 Then
		Return $aRet[0]
	ElseIf $getmmsyserr <> 1 Then
		Return DllStructGetData($stPropertyData, 1)
	EndIf
EndFunc   ;==>_MidiStreamProperty
