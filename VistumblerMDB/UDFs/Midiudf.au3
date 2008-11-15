#include <Array.au3>

;======================
;Midi UDF by Eynstyne
;======================

Const $callback_NULL				=	0
Const $callback_Window			=	0x10000
Const $callback_thread			=	0x20000
Const $callback_function		=	0x30000
Const $callback_event			=	0x50000

Const $MMSYSERR_BASE				=	0
Const $MMSYSERR_ALLOCATED		=	($MMSYSERR_BASE + 4)
Const $MMSYSERR_BADDEVICEID	=	($MMSYSERR_BASE + 2)
Const $MMSYSERR_BADERRNUM		=	($MMSYSERR_BASE + 9)
Const $MMSYSERR_ERROR			=	($MMSYSERR_BASE + 1)
Const $MMSYSERR_HANDLEBUSY		=	($MMSYSERR_BASE + 12)
Const $MMSYSERR_INVALFLAG		=	($MMSYSERR_BASE + 10)
Const $MMSYSERR_INVALHANDLE	=	($MMSYSERR_BASE + 5)
Const $MMSYSERR_INVALIDALIAS	=	($MMSYSERR_BASE + 13)
Const $MMSYSERR_INVALPARAM		=	($MMSYSERR_BASE + 11)
Const $MMSYSERR_LASTERROR		=	($MMSYSERR_BASE + 13)
Const $MMSYSERR_NODRIVER		=	($MMSYSERR_BASE + 6)
Const $MMSYSERR_NOERROR			=	0
Const $MMSYSERR_NOMEM			=	($MMSYSERR_BASE + 7)
Const $MMSYSERR_NOTENABLED		=	($MMSYSERR_BASE + 3)
Const $MMSYSERR_NOTSUPPORTED	=	($MMSYSERR_BASE + 8)

Const $MIDI_CACHE_ALL			=	1
Const $MIDI_CACHE_BESTFIT		=	2
Const $MIDI_CACHE_QUERY			=	3
Const $MIDI_UNCACHE				=	4
Const $MIDI_CACHE_VALID			=	($MIDI_CACHE_ALL Or $MIDI_CACHE_BESTFIT Or $MIDI_CACHE_QUERY Or $MIDI_UNCACHE)
Const $MIDI_IO_STATUS			=	0x20
Const $MIDICAPS_CACHE			=	0x4
Const $MIDICAPS_LRVOLUME		=	0x20
Const $MIDICAPS_STREAM			=	0x8
Const $MIDICAPS_VOLUME			=	0x1

Const $MIDIERR_BASE				=	64
Const $MIDIERR_INVALIDSETUP	=	($MIDIERR_BASE + 5)
Const $MIDIERR_LASTERROR		=	($MIDIERR_BASE + 5)
Const $MIDIERR_NODEVICE			=	($MIDIERR_BASE + 4)
Const $MIDIERR_NOMAP				=	($MIDIERR_BASE + 2)
Const $MIDIERR_NOTREADY			=	($MIDIERR_BASE + 3)
Const $MIDIERR_STILLPLAYING	=	($MIDIERR_BASE + 1)
Const $MIDIERR_UNPREPARED		=	($MIDIERR_BASE + 0)
Const $MIDIMAPPER					=	-1
Const $MIDIPROP_GET				=	0x40000000
Const $MIDIPROP_SET				=	0x80000000
Const $MIDIPROP_TEMPO			=	0x2
Const $MIDIPROP_TIMEDIV			=	0x1
Const $MIDISTRM_ERROR			=	-2
Const $MM_MPU401_MIDIOUT		=	10
Const $MM_MPU401_MIDIIN			=	11
Const $MM_MIDI_MAPPER			=	1
Const $MIDIPATCHSIZE				=	128

Const $MM_MIM_CLOSE				=	0x3c2
Const $MM_MIM_DATA				=	0x3c3
Const $MM_MIM_ERROR				=	0x3c5
Const $MM_MIM_LONGDATA			=	0x3c4
Const $MM_MIM_LONGERROR			=	0x3c6
Const $MM_MIM_MOREDATA			=	0x3cc
Const $MM_MIM_OPEN				=	0x3c1
Const $MM_MOM_CLOSE				=	0x3c8
Const $MM_MOM_DONE				=	0x3c9
Const $MM_MOM_OPEN				=	0x3c7
Const $MM_MOM_POSITIONCB		=	0x3ca

Const $MIM_CLOSE					=	($MM_MIM_CLOSE)
Const $MIM_DATA					=	($MM_MIM_DATA)
Const $MIM_ERROR					=	($MM_MIM_ERROR)
Const $MIM_LONGDATA				=	($MM_MIM_LONGDATA)
Const $MIM_LONGERROR				=	($MM_MIM_LONGERROR)
Const $MIM_MOREDATA				=	($MM_MIM_MOREDATA)
Const $MIM_OPEN					=	($MM_MIM_OPEN)
Const $MOM_CLOSE					=	($MM_MOM_CLOSE)
Const $MOM_DONE					=	($MM_MOM_DONE)
Const $MOM_OPEN					=	($MM_MOM_OPEN)
Const $MOM_POSITIONCB			=	($MM_MOM_POSITIONCB)

;Midi Notes
;==========
Const $A0_NOTEON					=	0x00401590	;1
Const $A0SHARP_NOTEON			=	0x00401690	;2
Const $B0_NOTEON					=	0x00401790	;3
Const $C1_NOTEON					=	0x00401890	;4
Const $C1SHARP_NOTEON			=	0x00401990	;5
Const $D1_NOTEON					=	0x00401A90	;6
Const $D1SHARP_NOTEON			=	0x00401B90	;7
Const $E1_NOTEON					=	0x00401C90	;8
Const $F1_NOTEON					=	0x00401D90	;9
Const $F1SHARP_NOTEON			=	0x00401E90	;10
Const $G1_NOTEON					=	0x00401F90	;11
Const $G1SHARP_NOTEON			=	0x00402090	;12
Const $A1_NOTEON					=	0x00402190	;13
Const $A1SHARP_NOTEON			=	0x00402290	;14
Const $B1_NOTEON					=	0x00402390	;15
Const $C2_NOTEON					=	0x00402490	;16
Const $C2SHARP_NOTEON			=	0x00402590	;17
Const $D2_NOTEON					=	0x00402690	;18
Const $D2SHARP_NOTEON			=	0x00402790	;19
Const $E2_NOTEON					=	0x00402890	;20
Const $F2_NOTEON					=	0x00402990	;21
Const $F2SHARP_NOTEON			=	0x00402A90	;22
Const $G2_NOTEON					=	0x00402B90	;23
Const $G2SHARP_NOTEON			=	0x00402C90	;24
Const $A2_NOTEON					=	0x00402D90	;25
Const $A2SHARP_NOTEON			=	0x00402E90	;26
Const $B2_NOTEON					=	0x00402F90	;27
Const $C3_NOTEON					=	0x00403090	;28
Const $C3SHARP_NOTEON			=	0x00403190	;29
Const $D3_NOTEON					=	0x00403290	;30
Const $D3SHARP_NOTEON			=	0x00403390	;31
Const $E3_NOTEON					=	0x00403490	;32
Const $F3_NOTEON					=	0x00403590	;33
Const $F3SHARP_NOTEON			=	0x00403690	;34
Const $G3_NOTEON					=	0x00403790	;35
Const $G3SHARP_NOTEON			=	0x00403890	;36
Const $A3_NOTEON					=	0x00403990	;37
Const $A3SHARP_NOTEON			=	0x00403A90	;38
Const $B3_NOTEON					=	0x00403B90	;39
Const $C4_NOTEON					=	0x00403C90	;40 - Middle C
Const $C4SHARP_NOTEON			=	0x00403D90	;41
Const $D4_NOTEON					=	0x00403E90	;42
Const $D4SHARP_NOTEON			=	0x00403F90	;43
Const $E4_NOTEON					=	0x00404090	;44
Const $F4_NOTEON					=	0x00404190	;45
Const $F4SHARP_NOTEON			=	0x00404290	;46
Const $G4_NOTEON					=	0x00404390	;47
Const $G4SHARP_NOTEON			=	0x00404490	;48
Const $A4_NOTEON					=	0x00404590	;49
Const $A4SHARP_NOTEON			=	0x00404690	;50
Const $B4_NOTEON					=	0x00404790	;51
Const $C5_NOTEON					=	0x00404890	;52
Const $C5SHARP_NOTEON			=	0x00404990	;53
Const $D5_NOTEON					=	0x00404A90	;54
Const $D5SHARP_NOTEON			=	0x00404B90	;55
Const $E5_NOTEON					=	0x00404C90	;56
Const $F5_NOTEON					=	0x00404D90	;57
Const $F5SHARP_NOTEON			=	0x00404E90	;58
Const $G5_NOTEON					=	0x00404F90	;59
Const $G5SHARP_NOTEON			=	0x00405090	;60
Const $A5_NOTEON					=	0x00405190	;61
Const $A5SHARP_NOTEON			=	0x00405290	;62
Const $B5_NOTEON					=	0x00405390	;63
Const $C6_NOTEON					=	0x00405490	;64
Const $C6SHARP_NOTEON			=	0x00405590	;65
Const $D6_NOTEON					=	0x00405690	;66
Const $D6SHARP_NOTEON			=	0x00405790	;67
Const $E6_NOTEON					=	0x00405890	;68
Const $F6_NOTEON					=	0x00405990	;69
Const $F6SHARP_NOTEON			=	0x00405A90	;70
Const $G6_NOTEON					=	0x00405B90	;71
Const $G6SHARP_NOTEON			=	0x00405C90	;72
Const $A6_NOTEON					=	0x00405D90	;73
Const $A6SHARP_NOTEON			=	0x00405E90	;74
Const $B6_NOTEON					=	0x00405F90	;75
Const $C7_NOTEON					=	0x00406090	;76
Const $C7SHARP_NOTEON			=	0x00406190	;77
Const $D7_NOTEON					=	0x00406290	;78
Const $D7SHARP_NOTEON			=	0x00406390	;79
Const $E7_NOTEON					=	0x00406490	;80
Const $F7_NOTEON					=	0x00406590	;81
Const $F7SHARP_NOTEON			=	0x00406690	;82
Const $G7_NOTEON					=	0x00406790	;83
Const $G7SHARP_NOTEON			=	0x00406890	;84
Const $A7_NOTEON					=	0x00406990	;85
Const $A7SHARP_NOTEON			=	0x00406A90	;86
Const $B7_NOTEON					=	0x00406B90	;87
Const $C8_NOTEON					=	0x00406C90	;88

;Turn Off the Notes
Const $A0_NOTEOFF					=	0x00001590	;1
Const $A0SHARP_NOTEOFF			=	0x00001690	;2
Const $B0_NOTEOFF					=	0x00001790	;3
Const $C1_NOTEOFF					=	0x00001890	;4
Const $C1SHARP_NOTEOFF			=	0x00001990	;5
Const $D1_NOTEOFF					=	0x00001A90	;6
Const $D1SHARP_NOTEOFF			=	0x00001B90	;7
Const $E1_NOTEOFF					=	0x00001C90	;8
Const $F1_NOTEOFF					=	0x00001D90	;9
Const $F1SHARP_NOTEOFF			=	0x00001E90	;10
Const $G1_NOTEOFF					=	0x00001F90	;11
Const $G1SHARP_NOTEOFF			=	0x00002090	;12
Const $A1_NOTEOFF					=	0x00002190	;13
Const $A1SHARP_NOTEOFF			=	0x00002290	;14
Const $B1_NOTEOFF					=	0x00002390	;15
Const $C2_NOTEOFF					=	0x00002490	;16
Const $C2SHARP_NOTEOFF			=	0x00002590	;17
Const $D2_NOTEOFF					=	0x00002690	;18
Const $D2SHARP_NOTEOFF			=	0x00002790	;19
Const $E2_NOTEOFF					=	0x00002890	;20
Const $F2_NOTEOFF					=	0x00002990	;21
Const $F2SHARP_NOTEOFF			=	0x00002A90	;22
Const $G2_NOTEOFF					=	0x00002B90	;23
Const $G2SHARP_NOTEOFF			=	0x00002C90	;24
Const $A2_NOTEOFF					=	0x00002D90	;25
Const $A2SHARP_NOTEOFF			=	0x00002E90	;26
Const $B2_NOTEOFF					=	0x00002F90	;27
Const $C3_NOTEOFF					=	0x00003090	;28
Const $C3SHARP_NOTEOFF			=	0x00003190	;29
Const $D3_NOTEOFF					=	0x00003290	;30
Const $D3SHARP_NOTEOFF			=	0x00003390	;31
Const $E3_NOTEOFF					=	0x00003490	;32
Const $F3_NOTEOFF					=	0x00003590	;33
Const $F3SHARP_NOTEOFF			=	0x00003690	;34
Const $G3_NOTEOFF					=	0x00003790	;35
Const $G3SHARP_NOTEOFF			=	0x00003890	;36
Const $A3_NOTEOFF					=	0x00003990	;37
Const $A3SHARP_NOTEOFF			=	0x00003A90	;38
Const $B3_NOTEOFF					=	0x00003B90	;39
Const $C4_NOTEOFF					=	0x00003C90	;40 - Middle C
Const $C4SHARP_NOTEOFF			=	0x00003D90	;41
Const $D4_NOTEOFF					=	0x00003E90	;42
Const $D4SHARP_NOTEOFF			=	0x00003F90	;43
Const $E4_NOTEOFF					=	0x00000090	;44
Const $F4_NOTEOFF					=	0x00004190	;45
Const $F4SHARP_NOTEOFF			=	0x00004290	;46
Const $G4_NOTEOFF					=	0x00004390	;47
Const $G4SHARP_NOTEOFF			=	0x00004490	;48
Const $A4_NOTEOFF					=	0x00004590	;49
Const $A4SHARP_NOTEOFF			=	0x00004690	;50
Const $B4_NOTEOFF					=	0x00004790	;51
Const $C5_NOTEOFF					=	0x00004890	;52
Const $C5SHARP_NOTEOFF			=	0x00004990	;53
Const $D5_NOTEOFF					=	0x00004A90	;54
Const $D5SHARP_NOTEOFF			=	0x00004B90	;55
Const $E5_NOTEOFF					=	0x00004C90	;56
Const $F5_NOTEOFF					=	0x00004D90	;57
Const $F5SHARP_NOTEOFF			=	0x00004E90	;58
Const $G5_NOTEOFF					=	0x00004F90	;59
Const $G5SHARP_NOTEOFF			=	0x00005090	;60
Const $A5_NOTEOFF					=	0x00005190	;61
Const $A5SHARP_NOTEOFF			=	0x00005290	;62
Const $B5_NOTEOFF					=	0x00005390	;63
Const $C6_NOTEOFF					=	0x00005490	;64
Const $C6SHARP_NOTEOFF			=	0x00005590	;65
Const $D6_NOTEOFF					=	0x00005690	;66
Const $D6SHARP_NOTEOFF			=	0x00005790	;67
Const $E6_NOTEOFF					=	0x00005890	;68
Const $F6_NOTEOFF					=	0x00005990	;69
Const $F6SHARP_NOTEOFF			=	0x00005A90	;70
Const $G6_NOTEOFF					=	0x00005B90	;71
Const $G6SHARP_NOTEOFF			=	0x00005C90	;72
Const $A6_NOTEOFF					=	0x00005D90	;73
Const $A6SHARP_NOTEOFF			=	0x00005E90	;74
Const $B6_NOTEOFF					=	0x00005F90	;75
Const $C7_NOTEOFF					=	0x00006090	;76
Const $C7SHARP_NOTEOFF			=	0x00006190	;77
Const $D7_NOTEOFF					=	0x00006290	;78
Const $D7SHARP_NOTEOFF			=	0x00006390	;79
Const $E7_NOTEOFF					=	0x00006490	;80
Const $F7_NOTEOFF					=	0x00006590	;81
Const $F7SHARP_NOTEOFF			=	0x00006690	;82
Const $G7_NOTEOFF					=	0x00006790	;83
Const $G7SHARP_NOTEOFF			=	0x00006890	;84
Const $A7_NOTEOFF					=	0x00006990	;85
Const $A7SHARP_NOTEOFF			=	0x00006A90	;86
Const $B7_NOTEOFF					=	0x00006B90	;87
Const $C8_NOTEOFF					=	0x00006C90	;88

;Instruments
#cs
	Piano	
		0		Acoustic Grand Piano
		1		Bright Piano
		2		Electric Grand Piano
		3		Honky-tonk piano
		4		Electric Piano 1
		5		Electric Piano 2
		6		Harpsichord
		7		Clav
	Chromatic Percussion	
		8		Celesta
		9		Glockenspiel
		10		Music Box
		11		Vibraphone
		12		Marimba
		13		Xylophone
		14		Tubular Bells
		15		Dulcimer
	Organ	
		16		Drawbar Organ
		17		Percussive Organ
		18		Rock Organ
		19		Church Organ
		20		Reed Organ
		21		Accordian
		22		Harmonica
		23		Tango Accordian
	Guitar	
		24		Nylon String Guitar
		25		Steel String Guitar
		26		Jazz Guitar
		27		Clean Electric Guitar
		28		Muted Electric Guitar
		29		Overdrive Guitar
		30		Distortion Guitar
		31		Guitar Harmonics
	Bass	
		32		Acoustic Bass
		33		Fingered Bass
		34		Picked Bass
		35		Fretless Bass
		36		Slap Bass 1
		37		Slap Bass 2
		38		Synth Bass 1
		39		Synth Bass 2
	Strings	
		40		Violin
		41		Viola
		42		Cello
		43		Contrabass
		44		Tremolo Strings
		45		Pizzicato Strings
		46		Orchestral Harp
		47		Timpani
	Ensemble	
		48		String Ensemble 1
		49		String Ensemble 2
		50		Synth Strings 1
		51		Synth Strings 2
		52		Choir Ahh
		53		Choir Oohh
		54		Synth Voice
		55		Orchestral Hit
	Brass	
		56		Trumpet
		57		Trombone
		58		Tuba
		59		Muted Trumpet
		60		French Horn
		61		Brass Section
		62		Synth Brass 1
		63		Synth Brass 2
	Reed	
		64		Soprano Sax
		65		Alto Sax
		66		Tenor Sax
		67		Baritone Sax
		68		Oboe
		69		English Horn
		70		Bassoon
		71		Clarinet
	Pipe	
		72		Piccolo
		73		Flute
		74		Recorder
		75		Pan Flute
		76		Blown Bottle
		77		Shakuhachi
		78		Whistle
		79		Ocarina
	Synth Lead	
		80		Square Wav
		81		Sawtooth Wav
		82		Caliope
		83		Chiff
		84		Charang
		85		Voice
		86		Fifth's
		87		Bass&Lead
	Synth Pad	
		88		New Age
		89		Warm
		90		Polysynth
		91		Choir
		92		Bowed
		93		Metallic
		94		Halo
		95		Sweep
	Synth Effects	
		96		FX Rain
		97		FX Soundtrack
		98		FX Crystal
		99		FX Atmosphere
		100	FX Brightness
		101	FX Goblins
		102	FX Echo Drops
		103	FX Star Theme
	Ethnic	
		104	Sitar
		105	Banjo
		106	Shamisen
		107	Koto
		108	Kalimba
		109	Bagpipe
		110	Fiddle
		111	Shanai
	Percussive	
		112	Tinkle Bell
		113	Agogo
		114	Steel Drums
		115	Woodblock
		116	Taiko Drum
		117	Melodic Tom
		118	Synth Drum
		119	Reverse Cymbal
	Sound Effects	
		120	Guitar Fret Noise
		121	Breath Noise
		122	Seashore
		123	Bird Tweet
		124	Telephone Ring
		125	Helicopter
		126	Applause
		127	Gunshot
   
   Drum Notes
		27
		28
		29
		30
		31
		32
		33
		34
		35		Acoustic Bass Drum
		36		Bass Drum 1
		37		Side Stick
		38		Acoustic Snare
		39		Hand Clap
		40		Electric Snare
		41		Low Floor Tom
		42		Closed Hi-Hat
		43		High Floor Tom
		44		Pedal Hi-Hat
		45		Low Tom
		46		Open Hi-Hat
		47		Low-Mid Tom
		48		Hi-Mid Tom
		49		Crash Cymbal 1
		50		High Tom
		51		Ride Cymbal 1
		52		Chinese Cymbal
		53		Ride Bell
		54		Tambourine
		55		Splash Cymbal
		56		Cowbell
		57		Crash Symbol 2
		58		Vibraslap
		59		Ride Cymbal 2
		60		Hi Bongo
		61		Low Bongo
		62		Mute Hi Conga
		63		Open Hi Conga
		64		Low Conga
		65		High Timbale
		66		Low Timbale
		67		High Agogo
		68		Low Agogo
		69		Cabasa
		70		Maracas
		71		Short Whistle
		72		Long Whistle
		73		Short Guiro
		74		Long Guiro
		75		Claves
		76		Hi Wood Block
		77		Low Wood Block
		78		Mute Cuica
		79		Open Cuica
		80		Mute Triangle
		81		Open Triangle
		82		Shaker
		83
		84
		85
		86
		87
#ce

;=======================================================
;Retrieves the number of Midi Output devices which exist
;Parameters - None
;Author : Eynstyne
;Library : Microsoft winmm.dll
;=======================================================
Func _midiOutGetNumDevs()
   $ret = DllCall("winmm.dll", "long", "midiOutGetNumDevs")
   If Not @error Then Return $ret[0]
EndFunc   ;==>_midiOutGetNumDevs

;=======================================================
;Retrieves the number of Midi Input devices which exist
;Parameters - None
;Author : Eynstyne
;Library : Microsoft winmm.dll
;=======================================================
Func _midiInGetNumDevs ($ReturnErrorAsString = 0) ;Working
   $ret = DllCall("winmm.dll", "long", "midiInGetNumDevs")
   If Not @error Then Return $ret[0]
EndFunc   ;==>_midiInGetNumDevs

;=======================================================
;Retrieves a MIDI handle and Opens the Device
;Parameters(Optional) - Device ID, Window Callback,
; instance, flags
;Author : Eynstyne
;Library : Microsoft winmm.dll
;=======================================================
Func _midiOutOpen($devid = 0, $callback = 0, $instance = 0, $flags = 0)
   $struct = DllStructCreate("udword")
   $ret = DllCall("winmm.dll", "long", "midiOutOpen", "ptr", DllStructGetPtr($struct), "int", $devid, "long", $callback, "long", $instance, "long", $flags)
   If Not @error Then
      $Get = DllStructGetData($struct, 1)
      Return $Get
   Else
      Return $ret[0]
   EndIf
EndFunc   ;==>_midiOutOpen

;=======================================================
;Retrieves a MIDI handle and Opens the Device
;Parameters(Optional) - Device ID, Window Callback,
; instance, flags
;Author : Eynstyne
;Library : Microsoft winmm.dll
;=======================================================
Func _midiInOpen ($devid = 0, $callback = 0, $instance = 0, $flags = 0)
   $struct = DllStructCreate("udword")
   $ret = DllCall("winmm.dll", "long", "midiInOpen", "ptr", DllStructGetPtr($struct), "int", $devid, "long", $callback, "long", $instance, "long", $flags)
   If Not @error Then
      $Get = DllStructGetData($struct, 1)
      Return $Get
   Else
      Return $ret[0]
   EndIf
EndFunc   ;==>_midiInOpen

;=======================================================
;Sets the Mixer Volume for MIDI
;Parameters - Volume (0 - 65535)
;Author : Eynstyne
;Library : Microsoft winmm.dll
;=======================================================
Func _MidiOutSetVolume ($volume, $devid = 0)
   $ret = DllCall("winmm.dll", "long", "midiOutSetVolume", "long", $devid, "int", $volume)
   If Not @error Then Return $ret[0]
EndFunc   ;==>_MidiOutSetVolume

;=======================================================
;Gets the Mixer Volume for MIDI
;Parameters - None
;Author : Eynstyne
;Library : Microsoft winmm.dll
;=======================================================
Func _MidiOutGetVolume ($devid = 0)
   $struct = DllStructCreate("ushort")
   $ret = DllCall("winmm.dll", "long", "midiOutGetVolume", "long", $devid, "ptr", DllStructGetPtr($struct))
   If Not @error Then
      $Get = DllStructGetData($struct, 1)
      Return $Get
   EndIf
EndFunc   ;==>_MidiOutGetVolume

;=======================================================
;Resets MIDI Output/Input
;Parameters - MidiHandle
;Author : Eynstyne
;Library : Microsoft winmm.dll
;=======================================================
Func _MidiOutReset ($hmidiout)
   $ret = DllCall("winmm.dll", "long", "midiOutReset", "long", $hmidiout)
   If Not @error Then Return $ret[0]
EndFunc   ;==>_MidiOutReset

Func _MidiInReset ($hmidiin)
   $ret = DllCall("winmm.dll", "long", "midiInReset", "long", $hmidiin)
   If Not @error Then Return $ret[0]
EndFunc   ;==>_MidiInReset

;=======================================================
;Starts Midi Input
;Parameters - MidiHandle
;Author : Eynstyne
;Library : Microsoft winmm.dll
;=======================================================
Func _MidiInStart ($hmidiin)
   $ret = DllCall("winmm.dll", "long", "midiInStart", "long", $hmidiin)
   If Not @error Then Return $ret[0]
EndFunc   ;==>_MidiInStart

;=======================================================
;Stops Midi Input
;Parameters - MidiHandle
;Author : Eynstyne
;Library : Microsoft winmm.dll
;=======================================================
Func _MidiInStop ($hmidiin)
   $ret = DllCall("winmm.dll", "long", "midiInStop", "long", $hmidiin)
   If Not @error Then Return $ret[0]
EndFunc   ;==>_MidiInStop

;=======================================================
;Closes Midi Output/Input devices
;Parameters - MidiHandle
;Author : Eynstyne
;Library : Microsoft winmm.dll
;=======================================================
Func _MidiOutClose ($hmidiout)
   $ret = DllCall("winmm.dll", "long", "midiOutClose", "long", $hmidiout)
   If Not @error Then Return $ret[0]
EndFunc   ;==>_MidiOutClose

Func _MidiInClose ($hmidiin)
   $ret = DllCall("winmm.dll", "long", "midiInClose", "long", $hmidiin)
   If Not @error Then Return $ret[0]
EndFunc   ;==>_MidiInClose

;=======================================================
;Cache Drum Patches for Output
;Parameters - MidiHandle,Patch,Keynumber,Flag
;Author : Eynstyne
;Library : Microsoft winmm.dll
;=======================================================
Func _MidiOutCacheDrumPatches ($hmidiout, $Patch, $keynumber, $flags = 0)
   $struct = DllStructCreate("short")
   $keyarray = _ArrayCreate($keynumber)
   DllStructSetData($struct, 1, $keynumber)
   $ret = DllCall("winmm.dll", "long", "midiOutCacheDrumPatches", "long", $hmidiout, "int", $Patch, "ptr", DllStructGetPtr($struct), "int", $flags)
   If Not @error Then Return $ret[0]
EndFunc   ;==>_MidiOutCacheDrumPatches

;=======================================================
;Caches MIDI Patches
;Parameters - MidiHandle, Bank, PatchNumber, Flags
;Author : Eynstyne
;Library : Microsoft winmm.dll
;=======================================================
Func _MidiOutCachePatches ($hmidiout, $bank, $patchnumber, $flags = 0)
   $struct = DllStructCreate("short")
   $patcharray = _ArrayCreate($patchnumber)
   DllStructSetData($struct, 1, $patchnumber)
   $ret = DllCall("winmm.dll", "long", "midiOutCachePatches", "long", $hmidiout, "int", $bank, "ptr", DllStructGetPtr($struct), "int", $flags)
   If Not @error Then Return $ret[0]
EndFunc   ;==>_MidiOutCachePatches

;=======================================================
;Gets MIDI DeviceID
;Parameters - MidiHandle
;Author : Eynstyne
;Library : Microsoft winmm.dll
;=======================================================
Func _MidiInGetID ($hmidiin)
   $struct = DllStructCreate("uint")
   $ret = DllCall("winmm.dll", "long", "midiInGetID", "long", $hmidiin, "ptr", DllStructGetPtr($struct))
   If Not @error Then
      $Get = DllStructGetData($struct, 1)
      Return $Get
   EndIf
EndFunc   ;==>_MidiInGetID

Func _MidiOutGetID ($hmidiout)
   $struct = DllStructCreate("uint")
   $ret = DllCall("winmm.dll", "long", "midiInGetID", "long", $hmidiout, "ptr", DllStructGetPtr($struct))
   If Not @error Then
      $Get = DllStructGetData($struct, 1)
      Return $Get
   EndIf
EndFunc   ;==>_MidiOutGetID

;=======================================================
;Translates Error codes into Plaintext
;Parameters - Error number
;Author : Eynstyne
;Library : Microsoft winmm.dll
;=======================================================
Func _MidiInGetErrorText ($error)
   $struct = DllStructCreate("char[128]")
   $ret = DllCall("winmm.dll", "long", "midiInGetErrorText", "int", $error, "ptr", DllStructGetPtr($struct), "int", 999)
   $Get = DllStructGetData($struct, 1)
   MsgBox(0, "", $Get)
EndFunc   ;==>_MidiInGetErrorText

Func _MidiOutGetErrorText($error)
   $struct = DllStructCreate("char[128]")
   $ret = DllCall("winmm.dll", "long", "midiOutGetErrorText", "int", $error, "ptr", DllStructGetPtr($struct), "int", 999)
   $Get = DllStructGetData($struct, 1)
   MsgBox(0, "", $Get)
EndFunc   ;==>_MidiOutGetErrorText

;=======================================================
;MIDI Message Send Function
;Parameters - Message as Hexcode or Constant
;Author : Eynstyne
;Library : Microsoft winmm.dll
;=======================================================
Func _MidiOutShortMsg($hmidiout, $msg)
   $ret = DllCall("winmm.dll", "long", "midiOutShortMsg", "long", $hmidiout, "long", $msg)
   If Not @error Then Return $ret[0]
EndFunc   ;==>_MidiOutShortMsg

Func _MidiOutLongMsg ($hmidiout, $data, $bufferlength, $bytesrecorded, $user, $flags, $next, $getmmsyserr = 0)
   $struct = DllStructCreate("char[128];udword;udword;udword;udword;ushort;ushort")
   DllStructSetData($struct, 1, $data)
   DllStructSetData($struct, 2, $bufferlength)
   DllStructSetData($struct, 3, $bytesrecorded)
   DllStructSetData($struct, 4, $user)
   DllStructSetData($struct, 5, $flags)
   DllStructSetData($struct, 6, $next)
   DllStructSetData($struct, 7, 0)
   $ret = DllCall("winmm.dll", "long", "midiInPrepareHeader", "long", $hmidiout, "ptr", DllStructGetPtr($struct), "long", 999)
   If Not @error Then
      If $getmmsyserr = 1 Then
         Return $ret[0]
      ElseIf $getmmsyserr <> 1 Then
         $array = _ArrayCreate($hmidiout, DllStructGetData($struct, 1), DllStructGetData($struct, 2), DllStructGetData($struct, 3), DllStructGetData($struct, 4), DllStructGetData($struct, 5), DllStructGetData($struct, 6), DllStructGetData($struct, 7))
         Return $array
      EndIf
   EndIf
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
Func _MidiOutGetDevCaps($deviceid = 0, $getmmsyserr = 0)
   $struct = DllStructCreate("ushort;ushort;uint;char[128];ushort;ushort;ushort;ushort;uint")
   $ret = DllCall("winmm.dll", "long", "midiOutGetDevCapsA", "long", $deviceid, "ptr", DllStructGetPtr($struct), "int", 999)
   If Not @error Then
      If $getmmsyserr = 1 Then
         Return $ret[0]
      ElseIf $getmmsyserr <> 1 Then
         $array = _ArrayCreate(DllStructGetData($struct, 1), DllStructGetData($struct, 2), DllStructGetData($struct, 3), DllStructGetData($struct, 4), DllStructGetData($struct, 5), DllStructGetData($struct, 6), DllStructGetData($struct, 7), DllStructGetData($struct, 8), DllStructGetData($struct, 9))
         Return $array
      EndIf
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
Func _MidiInGetDevCaps($deviceid = 0, $getmmsyserr = 0)
   $struct = DllStructCreate("ushort;ushort;uint;char[128]")
   $ret = DllCall("winmm.dll", "long", "midiInGetDevCapsA", "long", $deviceid, "ptr", DllStructGetPtr($struct), "int", 999)
   If Not @error Then
      If $getmmsyserr = 1 Then
         Return $ret[0]
      ElseIf $getmmsyserr <> 1 Then
         $array = _ArrayCreate(DllStructGetData($struct, 1), DllStructGetData($struct, 2), DllStructGetData($struct, 3), DllStructGetData($struct, 4))
         Return $array
      EndIf
   EndIf
EndFunc   ;==>_MidiInGetDevCaps

;========================================================
;Connect/Disconnect the MIDI Device to Application Source
; / Dest.
;Parameters - MidiHandleIn, MidiHandleOut
;Author: Eynstyne
;Library : Microsoft winmm.dll
;========================================================
Func _MidiConnect($hmidiin, $hmidiout)
   $ret = DllCall("winmm.dll", "long", "midiConnect", "long", $hmidiin, "long", $hmidiout, "int", 0)
   If Not @error Then Return $ret[0]
EndFunc   ;==>_MidiConnect

Func _MidiDisconnect($hmidiin, $hmidiout)
   $ret = DllCall("winmm.dll", "long", "midiDisconnect", "long", $hmidiin, "long", $hmidiout, "int", 0)
   If Not @error Then Return $ret[0]
EndFunc   ;==>_MidiDisconnect

;========================================================
;Prepare/Unprepare the MIDI header
;Parameters - MidiInHandle,Data,Bufferlength,
; BytesRecorded,User,Flags,Next,Getmmsystemerror
;Author:Eynstyne
;Library:Microsoft winmm.dll
;========================================================
Func _MidiInPrepareHeader ($hmidiin, $data, $bufferlength, $bytesrecorded, $user, $flags, $next, $getmmsyserr = 0)
   $struct = DllStructCreate("char[128];udword;udword;udword;udword;ushort;ushort")
   DllStructSetData($struct, 1, $data)
   DllStructSetData($struct, 2, $bufferlength)
   DllStructSetData($struct, 3, $bytesrecorded)
   DllStructSetData($struct, 4, $user)
   DllStructSetData($struct, 5, $flags)
   DllStructSetData($struct, 6, $next)
   DllStructSetData($struct, 7, 0)
   $ret = DllCall("winmm.dll", "long", "midiInPrepareHeader", "long", $hmidiin, "ptr", DllStructGetPtr($struct), "long", 999)
   If Not @error Then
      If $getmmsyserr = 1 Then
         Return $ret[0]
      ElseIf $getmmsyserr <> 1 Then
         $array = _ArrayCreate($hmidiin, DllStructGetData($struct, 1), DllStructGetData($struct, 2), DllStructGetData($struct, 3), DllStructGetData($struct, 4), DllStructGetData($struct, 5), DllStructGetData($struct, 6), DllStructGetData($struct, 7))
         Return $array
      EndIf
   EndIf
EndFunc   ;==>_MidiInPrepareHeader

Func _MidiInUnprepareHeader ($hmidiin, $data, $bufferlength, $bytesrecorded, $user, $flags, $next, $getmmsyserr = 0)
   $struct = DllStructCreate("char[128];udword;udword;udword;udword;ushort;ushort")
   DllStructSetData($struct, 1, $data)
   DllStructSetData($struct, 2, $bufferlength)
   DllStructSetData($struct, 3, $bytesrecorded)
   DllStructSetData($struct, 4, $user)
   DllStructSetData($struct, 5, $flags)
   DllStructSetData($struct, 6, $next)
   DllStructSetData($struct, 7, 0)
   $ret = DllCall("winmm.dll", "long", "midiInUnprepareHeader", "long", $hmidiin, "ptr", DllStructGetPtr($struct), "long", 999)
   If Not @error Then
      If $getmmsyserr = 1 Then
         Return $ret[0]
      ElseIf $getmmsyserr <> 1 Then
         $array = _ArrayCreate($hmidiin, DllStructGetData($struct, 1), DllStructGetData($struct, 2), DllStructGetData($struct, 3), DllStructGetData($struct, 4), DllStructGetData($struct, 5), DllStructGetData($struct, 6), DllStructGetData($struct, 7))
         Return $array
      EndIf
   EndIf
EndFunc   ;==>_MidiInUnprepareHeader

;========================================================
;Add buffer to Midi Header
;Parameters - MidiInHandle,Data,Bufferlength,
; BytesRecorded,User,Flags,Next,Getmmsystemerror
;Author:Eynstyne
;Library:Microsoft winmm.dll
;========================================================
Func _MidiInAddBuffer ($hmidiin, $data, $bufferlength, $bytesrecorded, $user, $flags, $next, $getmmsyserr = 0)
   $struct = DllStructCreate("char[128];udword;udword;udword;udword;ushort;ushort")
   DllStructSetData($struct, 1, $data)
   DllStructSetData($struct, 2, $bufferlength)
   DllStructSetData($struct, 3, $bytesrecorded)
   DllStructSetData($struct, 4, $user)
   DllStructSetData($struct, 5, $flags)
   DllStructSetData($struct, 6, $next)
   DllStructSetData($struct, 7, 0)
   $ret = DllCall("winmm.dll", "long", "midiInAddBuffer", "long", $hmidiin, "ptr", DllStructGetPtr($struct), "long", 999)
   If Not @error Then
      If $getmmsyserr = 1 Then
         Return $ret[0]
      ElseIf $getmmsyserr <> 1 Then
         $array = _ArrayCreate($hmidiin, DllStructGetData($struct, 1), DllStructGetData($struct, 2), DllStructGetData($struct, 3), DllStructGetData($struct, 4), DllStructGetData($struct, 5), DllStructGetData($struct, 6), DllStructGetData($struct, 7))
         Return $array
      EndIf
   EndIf
EndFunc   ;==>_MidiInAddBuffer

;========================================================
;Sends Internal MIDI Info to Input / Output device
;Parameters - MidiInHandle,message, parameter1, parameter2
;Author:Eynstyne
;Library:Microsoft winmm.dll
;========================================================
Func _MidiInMessage($hmidiin, $msg, $dw1 = 0, $dw2 = 0)
   $ret = DllCall("winmm.dll", "long", "midiInMessage", "long", $hmidiin, "long", $msg, "long", $dw1, "long", $dw2)
   If Not @error Then Return $ret[0]
EndFunc   ;==>_MidiInMessage

Func _MidiOutMessage($hmidiout, $msg, $dw1 = 0, $dw2 = 0)
   $ret = DllCall("winmm.dll", "long", "midiOutMessage", "long", $hmidiout, "long", $msg, "long", $dw1, "long", $dw2)
   If Not @error Then Return $ret[0]
EndFunc   ;==>_MidiOutMessage

;====================
;Stream Functions
;====================
Func _midiStreamClose($hmidiStream)
   $ret = DllCall("winmm.dll", "long", "midiStreamClose", "long", $hmidiStream)
   If Not @error Then Return $ret[0]
EndFunc   ;==>_midiStreamClose

Func _midiStreamOpen($cMidi = 0, $callback = 0, $instance = 0, $fdwopen = 0, $getmmsyserr = 0)
   $struct = DllStructCreate("udword;uint")
   $ret = DllCall("winmm.dll", "long", "midiStreamOpen", "ptr", DllStructGetPtr($struct, 1), "ptr", DllStructGetPtr($struct, 2), "long", $cMidi, "long", $callback, "long", $instance, "long", $fdwopen)
   If Not @error Then
      If $getmmsyserr = 1 Then
         Return $ret[0]
      ElseIf $getmmsyserr <> 1 Then
         $array = _ArrayCreate(DllStructGetData($struct, 1), DllStructGetData($struct, 2))
         Return $array
      EndIf
   EndIf
EndFunc   ;==>_midiStreamOpen

Func _midiStreamPause($hmidiStream)
   $ret = DllCall("winmm.dll", "long", "midiStreamPause", "long", $hmidiStream)
   If Not @error Then Return $ret[0]
EndFunc   ;==>_midiStreamPause

Func _midiStreamPos($hmidiStream, $cbmmt = 0, $getmmsyserr = 0)
   $struct = DllStructCreate("ushort;ushort")
   $ret = DllCall("winmm.dll", "long", "midiStreamPause", "long", $hmidiStream, "ptr", DllStructGetPtr($struct), "long", $cbmmt)
   If Not @error Then
      If $getmmsyserr = 1 Then
         Return $ret[0]
      ElseIf $getmmsyserr <> 1 Then
         $array = _ArrayCreate(DllStructGetData($struct, 1), DllStructGetData($struct, 2))
         Return $array
      EndIf
   EndIf
EndFunc   ;==>_midiStreamPos

Func _midiStreamRestart ($hmidiStream)
   $ret = DllCall("winmm.dll", "long", "midiStreamRestart", "long", $hmidiStream)
   If Not @error Then Return $ret[0]
EndFunc   ;==>_midiStreamRestart

Func _midiStreamStop ($hmidiStream)
   $ret = DllCall("winmm.dll", "long", "midiStreamStop", "long", $hmidiStream)
   If Not @error Then Return $ret[0]
EndFunc   ;==>_midiStreamStop

Func _midiStreamProperty ($hmidiStream, $property = 0, $getmmsyserr = 0)
   $struct = DllStructCreate("byte")
   $ret = DllCall("winmm.dll", "long", "midiStreamProperty", "long", $hmidiStream, "ptr", DllStructGetPtr($struct), "long", $property)
   If Not @error Then
      If $getmmsyserr = 1 Then
         Return $ret[0]
      ElseIf $getmmsyserr <> 1 Then
         $Get = DllStructGetData($struct, 1)
         Return $Get
      EndIf
   EndIf
EndFunc   ;==>_midiStreamProperty