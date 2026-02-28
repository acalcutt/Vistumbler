; ========================================================================================================
; <MIDIConstants.au3>
;
; Constants for Use with the MIDIFunctions UDF
;
; Author: Ascend4nt, based on work by Eynstyne
; ========================================================================================================

; ---------------------------- MIDI Callback Constants ----------------------------
Global Const $MIDI_Callback_NULL		=	0
Global Const $MIDI_Callback_Window		=	0x10000
Global Const $MIDI_Callback_Thread		=	0x20000
Global Const $MIDI_Callback_Function	=	0x30000
Global Const $MIDI_Callback_Event		=	0x50000

; ---------------------------- MULTIMEDIA SYSTEM ERRORS ----------------------------
Global Const $MMSYSERR_BASE			    =	0
Global Const $MMSYSERR_ALLOCATED		=	($MMSYSERR_BASE + 4)
Global Const $MMSYSERR_BADDEVICEID		=	($MMSYSERR_BASE + 2)
Global Const $MMSYSERR_BADERRNUM		=	($MMSYSERR_BASE + 9)
Global Const $MMSYSERR_ERROR			=	($MMSYSERR_BASE + 1)
Global Const $MMSYSERR_HANDLEBUSY		=	($MMSYSERR_BASE + 12)
Global Const $MMSYSERR_INVALFLAG		=	($MMSYSERR_BASE + 10)
Global Const $MMSYSERR_INVALHANDLE		=	($MMSYSERR_BASE + 5)
Global Const $MMSYSERR_INVALIDALIAS	    =	($MMSYSERR_BASE + 13)
Global Const $MMSYSERR_INVALPARAM		=	($MMSYSERR_BASE + 11)
Global Const $MMSYSERR_LASTERROR		=	($MMSYSERR_BASE + 13)
Global Const $MMSYSERR_NODRIVER         =	($MMSYSERR_BASE + 6)
Global Const $MMSYSERR_NOERROR			=	0
Global Const $MMSYSERR_NOMEM			=	($MMSYSERR_BASE + 7)
Global Const $MMSYSERR_NOTENABLED		=	($MMSYSERR_BASE + 3)
Global Const $MMSYSERR_NOTSUPPORTED     =	($MMSYSERR_BASE + 8)

; ---------------------------- MIDI MISC Global Constants ----------------------------
Global Const $MIDI_CACHE_ALL		=	1
Global Const $MIDI_CACHE_BESTFIT	=	2
Global Const $MIDI_CACHE_QUERY		=	3
Global Const $MIDI_UNCACHE			=	4
Global Const $MIDI_CACHE_VALID		=	($MIDI_CACHE_ALL Or $MIDI_CACHE_BESTFIT Or $MIDI_CACHE_QUERY Or $MIDI_UNCACHE)
Global Const $MIDI_IO_STATUS		=	0x20
Global Const $MIDICAPS_CACHE		=	0x4
Global Const $MIDICAPS_LRVOLUME	    =	0x20
Global Const $MIDICAPS_STREAM		=	0x8
Global Const $MIDICAPS_VOLUME		=	0x1

Global Const $MIDIERR_BASE				=	64
Global Const $MIDIERR_INVALIDSETUP		=	($MIDIERR_BASE + 5)
Global Const $MIDIERR_LASTERROR		    =	($MIDIERR_BASE + 5)
Global Const $MIDIERR_NODEVICE			=	($MIDIERR_BASE + 4)
Global Const $MIDIERR_NOMAP			    =	($MIDIERR_BASE + 2)
Global Const $MIDIERR_NOTREADY			=	($MIDIERR_BASE + 3)
Global Const $MIDIERR_STILLPLAYING		=	($MIDIERR_BASE + 1)
Global Const $MIDIERR_UNPREPARED		=	($MIDIERR_BASE + 0)
Global Const $MIDIMAPPER				=	-1
Global Const $MIDIPROP_GET				=	0x40000000
Global Const $MIDIPROP_SET				=	0x80000000
Global Const $MIDIPROP_TEMPO			=	0x2
Global Const $MIDIPROP_TIMEDIV			=	0x1
Global Const $MIDISTRM_ERROR			=	-2
Global Const $MM_MPU401_MidiOUT		    =	10
Global Const $MM_MPU401_MidiIN			=	11
Global Const $MM_Midi_MAPPER			=	1
Global Const $MIDIPATCHSIZE			    =	128

; ---------------------------- MIDI Message Constants ----------------------------
Global Const $MM_MIM_CLOSE			=	0x3c2
Global Const $MM_MIM_DATA			=	0x3c3
Global Const $MM_MIM_ERROR			=	0x3c5
Global Const $MM_MIM_LONGDATA		=	0x3c4
Global Const $MM_MIM_LONGERROR		=	0x3c6
Global Const $MM_MIM_MOREDATA		=	0x3cc
Global Const $MM_MIM_OPEN			=	0x3c1
Global Const $MM_MOM_CLOSE			=	0x3c8
Global Const $MM_MOM_DONE			=	0x3c9
Global Const $MM_MOM_OPEN			=	0x3c7
Global Const $MM_MOM_POSITIONCB	    =	0x3ca
Global Const $MIM_CLOSE			    =	($MM_MIM_CLOSE)
Global Const $MIM_DATA				=	($MM_MIM_DATA)
Global Const $MIM_ERROR			    =	($MM_MIM_ERROR)
Global Const $MIM_LONGDATA			=	($MM_MIM_LONGDATA)
Global Const $MIM_LONGERROR		    =	($MM_MIM_LONGERROR)
Global Const $MIM_MOREDATA			=	($MM_MIM_MOREDATA)
Global Const $MIM_OPEN				=	($MM_MIM_OPEN)
Global Const $MOM_CLOSE			    =	($MM_MOM_CLOSE)
Global Const $MOM_DONE				=	($MM_MOM_DONE)
Global Const $MOM_OPEN				=	($MM_MOM_OPEN)
Global Const $MOM_POSITIONCB		=	($MM_MOM_POSITIONCB)

; ---------------------------- MIDI Instrument Values ----------------------------
; Piano
Global Const $INSTR_AcousticGrandPiano = 0
Global Const $INSTR_BrightPiano        = 1
Global Const $INSTR_ElectricGrandPiano = 2
Global Const $INSTR_HonkyTonkpiano     = 3
Global Const $INSTR_ElectricPiano1     = 4
Global Const $INSTR_ElectricPiano2     = 5
Global Const $INSTR_Harpsichord        = 6
Global Const $INSTR_Clav               = 7
; Chromatic Percussion
Global Const $INSTR_Celesta            = 8
Global Const $INSTR_Glockenspiel       = 9
Global Const $INSTR_MusicBox           = 10
Global Const $INSTR_Vibraphone         = 11
Global Const $INSTR_Marimba            = 12
Global Const $INSTR_Xylophone          = 13
Global Const $INSTR_TubularBells       = 14
Global Const $INSTR_Dulcimer           = 15
; Organ
Global Const $INSTR_DrawbarOrgan       = 16
Global Const $INSTR_PercussiveOrgan    = 17
Global Const $INSTR_RockOrgan          = 18
Global Const $INSTR_ChurchOrgan        = 19
Global Const $INSTR_ReedOrgan          = 20
Global Const $INSTR_Accordian          = 21
Global Const $INSTR_Harmonica          = 22
Global Const $INSTR_TangoAccordian     = 23
; Guitar
Global Const $INSTR_NylonStringGuitar   = 24
Global Const $INSTR_SteelStringGuitar   = 25
Global Const $INSTR_JazzGuitar          = 26
Global Const $INSTR_CleanElectricGuitar = 27
Global Const $INSTR_MutedElectricGuitar = 28
Global Const $INSTR_OverdriveGuitar     = 29
Global Const $INSTR_DistortionGuitar    = 30
Global Const $INSTR_GuitarHarmonics     = 31
; Bass
Global Const $INSTR_AcousticBass       = 32
Global Const $INSTR_FingeredBass       = 33
Global Const $INSTR_PickedBass         = 34
Global Const $INSTR_FretlessBass       = 35
Global Const $INSTR_SlapBass1          = 36
Global Const $INSTR_SlapBass2          = 37
Global Const $INSTR_SynthBass1         = 38
Global Const $INSTR_SynthBass2         = 39
; Strings
Global Const $INSTR_Violin             = 40
Global Const $INSTR_Viola              = 41
Global Const $INSTR_Cello              = 42
Global Const $INSTR_Contrabass         = 43
Global Const $INSTR_TremoloStrings     = 44
Global Const $INSTR_PizzicatoStrings   = 45
Global Const $INSTR_OrchestralHarp     = 46
Global Const $INSTR_Timpani            = 47
; Ensemble
Global Const $INSTR_StringEnsemble1    = 48
Global Const $INSTR_StringEnsemble2    = 49
Global Const $INSTR_SynthStrings1      = 50
Global Const $INSTR_SynthStrings2      = 51
Global Const $INSTR_ChoirAhh           = 52
Global Const $INSTR_ChoirOohh          = 53
Global Const $INSTR_SynthVoice         = 54
Global Const $INSTR_OrchestralHit      = 55
; Brass
Global Const $INSTR_Trumpet            = 56
Global Const $INSTR_Trombone           = 57
Global Const $INSTR_Tuba               = 58
Global Const $INSTR_MutedTrumpet       = 59
Global Const $INSTR_FrenchHorn         = 60
Global Const $INSTR_BrassSection       = 61
Global Const $INSTR_SynthBrass1        = 62
Global Const $INSTR_SynthBrass2        = 63
; Reed
Global Const $INSTR_SopranoSax         = 64
Global Const $INSTR_AltoSax            = 65
Global Const $INSTR_TenorSax           = 66
Global Const $INSTR_BaritoneSax        = 67
Global Const $INSTR_Oboe               = 68
Global Const $INSTR_EnglishHorn        = 69
Global Const $INSTR_Bassoon            = 70
Global Const $INSTR_Clarinet           = 71
; Pipe
Global Const $INSTR_Piccolo            = 72
Global Const $INSTR_Flute              = 73
Global Const $INSTR_Recorder           = 74
Global Const $INSTR_PanFlute           = 75
Global Const $INSTR_BlownBottle        = 76
Global Const $INSTR_Shakuhachi         = 77
Global Const $INSTR_Whistle            = 78
Global Const $INSTR_Ocarina            = 79
; Synth Lead
Global Const $INSTR_SquareWav          = 80
Global Const $INSTR_SawtoothWav        = 81
Global Const $INSTR_Caliope            = 82
Global Const $INSTR_Chiff              = 83
Global Const $INSTR_Charang            = 84
Global Const $INSTR_Voice              = 85
Global Const $INSTR_Fifths             = 86
Global Const $INSTR_BassAndLead        = 87
; Synth Pad
Global Const $INSTR_NewAge             = 88
Global Const $INSTR_Warm               = 89
Global Const $INSTR_Polysynth          = 90
Global Const $INSTR_Choir              = 91
Global Const $INSTR_Bowed              = 92
Global Const $INSTR_Metallic           = 93
Global Const $INSTR_Halo               = 94
Global Const $INSTR_Sweep              = 95
; Synth Effects
Global Const $INSTR_FXRain             = 96
Global Const $INSTR_FXSoundtrack       = 97
Global Const $INSTR_FXCrystal          = 98
Global Const $INSTR_FXAtmosphere       = 99
Global Const $INSTR_FXBrightness       = 100
Global Const $INSTR_FXGoblins          = 101
Global Const $INSTR_FXEchoDrops        = 102
Global Const $INSTR_FXStarTheme        = 103
; Ethnic
Global Const $INSTR_Sitar              = 104
Global Const $INSTR_Banjo              = 105
Global Const $INSTR_Shamisen           = 106
Global Const $INSTR_Koto               = 107
Global Const $INSTR_Kalimba            = 108
Global Const $INSTR_Bagpipe            = 109
Global Const $INSTR_Fiddle             = 110
Global Const $INSTR_Shanai             = 111
; Percussive
Global Const $INSTR_TinkleBell         = 112
Global Const $INSTR_Agogo              = 113
Global Const $INSTR_SteelDrums         = 114
Global Const $INSTR_Woodblock          = 115
Global Const $INSTR_TaikoDrum          = 116
Global Const $INSTR_MelodicTom         = 117
Global Const $INSTR_SynthDrum          = 118
Global Const $INSTR_ReverseCymbal      = 119
; Sound Effects
Global Const $INSTR_GuitarFretNoise    = 120
Global Const $INSTR_BreathNoise        = 121
Global Const $INSTR_Seashore           = 122
Global Const $INSTR_BirdTweet          = 123
Global Const $INSTR_TelephoneRing      = 124
Global Const $INSTR_Helicopter         = 125
Global Const $INSTR_Applause           = 126
Global Const $INSTR_Gunshot            = 127

; ---------------------------- MIDI Note Values ----------------------------
Global Const $NOTE_A0      = 0x15
Global Const $NOTE_A0SHARP = 0x16
Global Const $NOTE_B0      = 0x17
Global Const $NOTE_C1      = 0x18
Global Const $NOTE_C1SHARP = 0x19
Global Const $NOTE_D1      = 0x1A
Global Const $NOTE_D1SHARP = 0x1B
Global Const $NOTE_E1      = 0x1C
Global Const $NOTE_F1      = 0x1D
Global Const $NOTE_F1SHARP = 0x1E
Global Const $NOTE_G1      = 0x1F
Global Const $NOTE_G1SHARP = 0x20
Global Const $NOTE_A1      = 0x21
Global Const $NOTE_A1SHARP = 0x22
Global Const $NOTE_B1      = 0x23
Global Const $NOTE_C2      = 0x24
Global Const $NOTE_C2SHARP = 0x25
Global Const $NOTE_D2      = 0x26
Global Const $NOTE_D2SHARP = 0x27
Global Const $NOTE_E2      = 0x28
Global Const $NOTE_F2      = 0x29
Global Const $NOTE_F2SHARP = 0x2A
Global Const $NOTE_G2      = 0x2B
Global Const $NOTE_G2SHARP = 0x2C
Global Const $NOTE_A2      = 0x2D
Global Const $NOTE_A2SHARP = 0x2E
Global Const $NOTE_B2      = 0x2F
Global Const $NOTE_C3      = 0x30
Global Const $NOTE_C3SHARP = 0x31
Global Const $NOTE_D3      = 0x32
Global Const $NOTE_D3SHARP = 0x33
Global Const $NOTE_E3      = 0x34
Global Const $NOTE_F3      = 0x35
Global Const $NOTE_F3SHARP = 0x36
Global Const $NOTE_G3      = 0x37
Global Const $NOTE_G3SHARP = 0x38
Global Const $NOTE_A3      = 0x39
Global Const $NOTE_A3SHARP = 0x3A
Global Const $NOTE_B3      = 0x3B
Global Const $NOTE_C4      = 0x3C
Global Const $NOTE_C4SHARP = 0x3D
Global Const $NOTE_D4      = 0x3E
Global Const $NOTE_D4SHARP = 0x3F
Global Const $NOTE_E4      = 0x40
Global Const $NOTE_F4      = 0x41
Global Const $NOTE_F4SHARP = 0x42
Global Const $NOTE_G4      = 0x43
Global Const $NOTE_G4SHARP = 0x44
Global Const $NOTE_A4      = 0x45
Global Const $NOTE_A4SHARP = 0x46
Global Const $NOTE_B4      = 0x47
Global Const $NOTE_C5      = 0x48
Global Const $NOTE_C5SHARP = 0x49
Global Const $NOTE_D5      = 0x4A
Global Const $NOTE_D5SHARP = 0x4B
Global Const $NOTE_E5      = 0x4C
Global Const $NOTE_F5      = 0x4D
Global Const $NOTE_F5SHARP = 0x4E
Global Const $NOTE_G5      = 0x4F
Global Const $NOTE_G5SHARP = 0x50
Global Const $NOTE_A5      = 0x51
Global Const $NOTE_A5SHARP = 0x52
Global Const $NOTE_B5      = 0x53
Global Const $NOTE_C6      = 0x54
Global Const $NOTE_C6SHARP = 0x55
Global Const $NOTE_D6      = 0x56
Global Const $NOTE_D6SHARP = 0x57
Global Const $NOTE_E6      = 0x58
Global Const $NOTE_F6      = 0x59
Global Const $NOTE_F6SHARP = 0x5A
Global Const $NOTE_G6      = 0x5B
Global Const $NOTE_G6SHARP = 0x5C
Global Const $NOTE_A6      = 0x5D
Global Const $NOTE_A6SHARP = 0x5E
Global Const $NOTE_B6      = 0x5F
Global Const $NOTE_C7      = 0x60
Global Const $NOTE_C7SHARP = 0x61
Global Const $NOTE_D7      = 0x62
Global Const $NOTE_D7SHARP = 0x63
Global Const $NOTE_E7      = 0x64
Global Const $NOTE_F7      = 0x65
Global Const $NOTE_F7SHARP = 0x66
Global Const $NOTE_G7      = 0x67
Global Const $NOTE_G7SHARP = 0x68
Global Const $NOTE_A7      = 0x69
Global Const $NOTE_A7SHARP = 0x6A
Global Const $NOTE_B7      = 0x6B
Global Const $NOTE_C8      = 0x6C
; ---------------------------- MIDI Percussion Note Values ----------------------------
Global Const $DRUMS_AcousticBassDrum = 0x23
Global Const $DRUMS_BassDrum1        = 0x24
Global Const $DRUMS_SideStick        = 0x25
Global Const $DRUMS_AcousticSnare    = 0x26
Global Const $DRUMS_HandClap         = 0x27
Global Const $DRUMS_ElectricSnare    = 0x28
Global Const $DRUMS_LowFloorTom      = 0x29
Global Const $DRUMS_ClosedHiHat      = 0x2A
Global Const $DRUMS_HighFloorTom     = 0x2B
Global Const $DRUMS_PedalHiHat       = 0x2C
Global Const $DRUMS_LowTom           = 0x2D
Global Const $DRUMS_OpenHiHat        = 0x2E
Global Const $DRUMS_LowMidTom        = 0x2F
Global Const $DRUMS_HiMidTom         = 0x30
Global Const $DRUMS_CrashCymbal1     = 0x31
Global Const $DRUMS_HighTom          = 0x32
Global Const $DRUMS_RideCymbal1      = 0x33
Global Const $DRUMS_ChineseCymbal    = 0x34
Global Const $DRUMS_RideBell         = 0x35
Global Const $DRUMS_Tambourine       = 0x36
Global Const $DRUMS_SplashCymbal     = 0x37
Global Const $DRUMS_Cowbell          = 0x38
Global Const $DRUMS_CrashSymbol2     = 0x39
Global Const $DRUMS_Vibraslap        = 0x3A
Global Const $DRUMS_RideCymbal2      = 0x3B
Global Const $DRUMS_HiBongo          = 0x3C
Global Const $DRUMS_LowBongo         = 0x3D
Global Const $DRUMS_MuteHiConga      = 0x3E
Global Const $DRUMS_OpenHiConga      = 0x3F
Global Const $DRUMS_LowConga         = 0x40
Global Const $DRUMS_HighTimbale      = 0x41
Global Const $DRUMS_LowTimbale       = 0x42
Global Const $DRUMS_HighAgogo        = 0x43
Global Const $DRUMS_LowAgogo         = 0x44
Global Const $DRUMS_Cabasa           = 0x45
Global Const $DRUMS_Maracas          = 0x46
Global Const $DRUMS_ShortWhistle     = 0x47
Global Const $DRUMS_LongWhistle      = 0x48
Global Const $DRUMS_ShortGuiro       = 0x49
Global Const $DRUMS_LongGuiro        = 0x4A
Global Const $DRUMS_Claves           = 0x4B
Global Const $DRUMS_HiWoodBlock      = 0x4C
Global Const $DRUMS_LowWoodBlock     = 0x4D
Global Const $DRUMS_MuteCuica        = 0x4E
Global Const $DRUMS_OpenCuica        = 0x4F
Global Const $DRUMS_MuteTriangle     = 0x50
Global Const $DRUMS_OpenTriangle     = 0x51
Global Const $DRUMS_Shaker           = 0x52
; ---------------------------- MIDI Channels ----------------------------
Global Const $MIDI_CHANNEL_1  = 1
Global Const $MIDI_CHANNEL_2  = 2
Global Const $MIDI_CHANNEL_3  = 3
Global Const $MIDI_CHANNEL_4  = 4
Global Const $MIDI_CHANNEL_5  = 5
Global Const $MIDI_CHANNEL_6  = 6
Global Const $MIDI_CHANNEL_7  = 7
Global Const $MIDI_CHANNEL_8  = 8
Global Const $MIDI_CHANNEL_9  = 9
Global Const $MIDI_PERCUSSION_CHANNEL = 10	; Drums etc
Global Const $MIDI_CHANNEL_11 = 11
Global Const $MIDI_CHANNEL_12 = 12
Global Const $MIDI_CHANNEL_13 = 13
Global Const $MIDI_CHANNEL_14 = 14
Global Const $MIDI_CHANNEL_15 = 15
Global Const $MIDI_CHANNEL_16 = 16
; ---------------------------- MIDI Range Constants ----------------------------
; Min/Max Values
Global Const $MIDI_MIN_VALUE    = 0
Global Const $MIDI_CENTER_VALUE = 64
Global Const $MIDI_MAX_VALUE    = 0x7F
Global Const $MIDI_PITCH_BEND_MIN    = 0
Global Const $MIDI_PITCH_BEND_CENTER = 0x2000
Global Const $MIDI_PITCH_BEND_MAX    = 0x3FFF
; ---------------------------- MIDI CONTROL Messages ----------------------------
Global Const $MIDI_CONTROL_BANK_SELECT = 0
Global Const $MIDI_CONTROL_MODULATE = 0x01
Global Const $MIDI_CONTROL_BREATH_CONTROLLER = 0x02
; 0x03 = Undefined
Global Const $MIDI_CONTROL_FOOT_CONTROLLER = 0x04
Global Const $MIDI_CONTROL_PORTAMENTO_TIME = 0x05
Global Const $MIDI_CONTROL_DATA_ENTRY_MSB  = 0x06
Global Const $MIDI_CONTROL_CHANNEL_VOLUME  = 0x07
Global Const $MIDI_CONTROL_BALANCE = 0x08
; 0x09 = Undefined
Global Const $MIDI_CONTROL_PAN = 0x0A
Global Const $MIDI_CONTROL_EXPRESSION_CONTROLLER = 0x0B
Global Const $MIDI_CONTROL_EFFECT_CONTROL_1 = 0x0C
Global Const $MIDI_CONTROL_EFFECT_CONTROL_2 = 0x0D
; 0x0E, 0x0F = Undefined
; ----- GENERAL PURPOSE CONTROLLERS ------
Global Const $MIDI_CONTROL_GENERAL_PURPOSE_1 = 0x10
Global Const $MIDI_CONTROL_GENERAL_PURPOSE_2 = 0x11
Global Const $MIDI_CONTROL_GENERAL_PURPOSE_3 = 0x12
Global Const $MIDI_CONTROL_GENERAL_PURPOSE_4 = 0x13
; 0x14 -> 0x1F = Undefined
; ------- PEDALS (4 variants) ---------
Global Const $MIDI_CONTROL_DAMPER_PEDAL     = 0x40	; alternate name for 'Sustain'
Global Const $MIDI_CONTROL_SUSTAIN_PEDAL    = 0x40  ; <= 63 is OFF, >= 64 is ON
Global Const $MIDI_CONTROL_PORTAMENTO_PEDAL = 0x41  ; <= 63 is OFF, >= 64 is ON
Global Const $MIDI_CONTROL_SOSTENUTO_PEDAL  = 0x42  ; <= 63 is OFF, >= 64 is ON
Global Const $MIDI_CONTROL_SOFT_PEDAL = 0x43

Global Const $MIDI_CONTROL_LEGATO_FOOTSWITCH = 0x44	; <= 63 is 'Normal', >= 64 is Legato
Global Const $MIDI_CONTROL_HOLD_2 = 0x45			; <= 63 is OFF, >= 64 is ON
; ------- SOUND CONTROLLERS --------
Global Const $MIDI_CONTROL_SOUND_CONTROLLER_1  = 0x46	; Default: Sound Variation
Global Const $MIDI_CONTROL_SOUND_CONTROLLER_2  = 0x47	; Default: Timbre/Harmonic Intensity
Global Const $MIDI_CONTROL_SOUND_CONTROLLER_3  = 0x48	; Default: Release Time
Global Const $MIDI_CONTROL_SOUND_CONTROLLER_4  = 0x49	; Default: Attack Time
Global Const $MIDI_CONTROL_SOUND_CONTROLLER_5  = 0x4A	; Default: Brightness
Global Const $MIDI_CONTROL_SOUND_CONTROLLER_6  = 0x4B	; Default: Decay Time
Global Const $MIDI_CONTROL_SOUND_CONTROLLER_7  = 0x4C	; Default: Vibrato Rate
Global Const $MIDI_CONTROL_SOUND_CONTROLLER_8  = 0x4D	; Default: Vibrato Depth
Global Const $MIDI_CONTROL_SOUND_CONTROLLER_9  = 0x4E	; Default: Vibrato Delay
Global Const $MIDI_CONTROL_SOUND_CONTROLLER_10 = 0x4F	; No Default defined
; ----- GENERAL PURPOSE CONTROLLERS ------
Global Const $MIDI_CONTROL_GENERAL_PURPOSE_5  = 0x50
Global Const $MIDI_CONTROL_GENERAL_PURPOSE_6  = 0x51
Global Const $MIDI_CONTROL_GENERAL_PURPOSE_7  = 0x52
Global Const $MIDI_CONTROL_GENERAL_PURPOSE_8  = 0x53
Global Const $MIDI_CONTROL_PORTAMENTO_CONTROL = 0x54
; 0x55 - 0x57 = Undefined
Global Const $MIDI_CONTROL_HIGHRES_VELOCITY_PREFIX = 0x58
; 0x59 - 0x5A = Undefined
Global Const $MIDI_CONTROL_EFFECTS_1_DEPTH = 0x5B	; Default: Reverb Send Level (formerly External Effects Depth)
Global Const $MIDI_CONTROL_EFFECTS_2_DEPTH = 0x5C	; (formerly Tremolo Depth)
Global Const $MIDI_CONTROL_EFFECTS_3_DEPTH = 0x5D	; Default: Chorus Send Level (formerly Chorus Depth)
Global Const $MIDI_CONTROL_EFFECTS_4_DEPTH = 0x5E	; (formerly Celeste [Detune] Depth)
Global Const $MIDI_CONTROL_EFFECTS_5_DEPTH = 0x5F	; (formerly Phaser Depth)
; These are used in conjunction with other messages:
Global Const $MIDI_CONTROL_DATA_INCREMENT = 0x60	; Data Entry + 1 **Control Value: 0
Global Const $MIDI_CONTROL_DATA_DECREMENT = 0x61	; Data Entry - 1 **Control Value: 0
; ------ REGISTERED PARAMETER SEQUENCES ------
; These are combined with other messages
Global Const $MIDI_CONTROL_NONREGISTERED_PARAM_NUM = 0x62
; 0x63 = Non-Registered Parameter Number using MSB
Global Const $MIDI_CONTROL_REGISTERED_PARAM_NUM    = 0x64
; 0x65 = Registered Parameter Number using MSB
; 0x66 - 0x77 = Undefined
; ------ CHANNEL MODE MESSAGES ------
Global Const $MIDI_CONTROL_ALL_SOUND_OFF = 0x78			; Control Value: 0
Global Const $MIDI_CONTROL_RESET_ALL_CONTROLLERS = 0x79	; Control Value: 0
Global Const $MIDI_CONTROL_LOCAL_CONTROL = 0x7A		; 0 = Off, 127 = On
Global Const $MIDI_CONTROL_ALL_NOTES_OFF = 0x7B		; Control Value: 0
Global Const $MIDI_CONTROL_OMNI_MODE_OFF = 0x7C		; Additionally sets All Notes OFF **Control Value: 0
Global Const $MIDI_CONTROL_OMNI_MODE_ON  = 0x7D		; Additionally sets All Notes OFF **Control Value: 0
Global Const $MIDI_CONTROL_MONO_MODE_ON  = 0x7E		; Additionally: All Notes OFF, Poly OFF **Control Value: 0?? (see Midi Table)
Global Const $MIDI_CONTROL_POOLY_MODE_ON = 0x7F		; Additionally: All Notes OFF, Mono OFF **Control Value: 0
